-- ListView：ADT 专用滚动列表（独立实现，无外部依赖）

local ADDON_NAME, ADT = ...
local API = ADT.API

local CreateFrame = CreateFrame

local ListViewMixin = {}

-- 创建列表视图
function API.CreateListView(parent)
    local f = CreateFrame('Frame', nil, parent)
    API.Mixin(f, ListViewMixin)
    f:SetClipsChildren(true)

    -- 滚动参考点（内容从此向下排布）
    f.ScrollRef = CreateFrame('Frame', nil, f)
    f.ScrollRef:SetSize(4, 4)
    f.ScrollRef:SetPoint('TOP', f, 'TOP', 0, 0)

    -- 内部状态
    f._templates = {}
    f._content = {}
    f._actives = {}
    f._offset = 0
    f._range = 0
    f._viewport = 0
    f._step = 30
    f._bottomOvershoot = 0
    f._alwaysShowScrollBar = false
    f._showNoContentAlert = false

    -- 无内容提示
    local NoContentAlert = CreateFrame('Frame', nil, f)
    f.NoContentAlert = NoContentAlert
    NoContentAlert:Hide()
    NoContentAlert:SetAllPoints(true)
    local fs = NoContentAlert:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    NoContentAlert.Text = fs
    fs:SetPoint('LEFT', f, 'LEFT', 16, 16)
    fs:SetPoint('RIGHT', f, 'RIGHT', -16, 16)
    fs:SetJustifyH('CENTER')
    fs:SetSpacing(4)
    fs:SetText(ADT.L and ADT.L['List Is Empty'] or 'Empty')

    -- 交互（滚轮与物理滚动由 ADT.Scroll 统一接管）
    f:EnableMouseWheel(true)
    f:SetScript('OnHide', f.OnHide)

    -- 统一附加滚动物理（单一权威）
    if ADT and ADT.Scroll and ADT.Scroll.AttachListView then
        ADT.Scroll.AttachListView(f)
    end
    return f
end

-- 公开方法（接口稳定，供 SettingsPanel 调用）
function ListViewMixin:SetStepSize(px) self._step = px or self._step end
function ListViewMixin:SetBottomOvershoot(v) self._bottomOvershoot = v or 0 end
function ListViewMixin:SetAlwaysShowScrollBar(state) self._alwaysShowScrollBar = not not state end
function ListViewMixin:EnableMouseBlocker(_) end -- 兼容占位
function ListViewMixin:SetShowNoContentAlert(state) self._showNoContentAlert = not not state end
function ListViewMixin:SetNoContentAlertText(text) if self.NoContentAlert then self.NoContentAlert.Text:SetText(text or '') end end

function ListViewMixin:GetScrollRange() return self._range end
function ListViewMixin:IsScrollable() return (self._range or 0) > 0 end
function ListViewMixin:IsAtTop() return (self._offset or 0) <= 0 end
function ListViewMixin:IsAtBottom() return (self._offset or 0) >= (self._range or 0) end

function ListViewMixin:GetOffset() return self._offset end
function ListViewMixin:SetOffset(offset)
    self._offset = offset or 0
    self.ScrollRef:SetPoint('TOP', self, 'TOP', 0, self._offset)
end

-- 视区变化
function ListViewMixin:OnSizeChanged(force)
    self._viewport = math.floor(self:GetHeight() + 0.5)
    self.ScrollRef:SetWidth(math.floor(self:GetWidth() + 0.5))
    if ADT and ADT.Scroll and self._adtScroller and self._SyncScrollRange then self:_SyncScrollRange() end
    if force then self:Render(true) end
end

-- 模板与对象池
function ListViewMixin:AddTemplate(key, createFunc, onAcquire, onRemove)
    -- 新对象池签名：create, onAcquire, onRelease
    self._templates[key] = API.CreateObjectPool(createFunc, onAcquire, onRemove)
end

function ListViewMixin:AcquireObject(key)
    local pool = self._templates[key]
    return pool and pool:Acquire() or nil
end

function ListViewMixin:ReleaseAllObjects()
    self._actives = {}
    for _, pool in pairs(self._templates) do pool:ReleaseAll() end
end

function ListViewMixin:CallObjectMethod(key, method, ...)
    local pool = self._templates[key]
    if not pool then return end
    for _, obj in pool:EnumerateActive() do
        local fn = obj and obj[method]
        if fn then fn(obj, ...) end
    end
end

-- 内容设置：content 为数组，元素包含：
-- { top=number, bottom=number, templateKey=string, setupFunc=function(obj) end }
function ListViewMixin:SetContent(content, retainPosition)
    self._content = content or {}

    local n = #self._content
    if n > 0 then
        -- 计算滚动范围 = 最后一项 bottom - 视区
        local range = (self._content[n].bottom or 0) - (self._viewport or 0)
        if range > 0 then range = range + (self._bottomOvershoot or 0) else range = 0 end
        self._range = range
        self.NoContentAlert:Hide()
    else
        self._range = 0
        if self._showNoContentAlert then self.NoContentAlert:Show() else self.NoContentAlert:Hide() end
    end

    -- 回收旧对象
    self:ReleaseAllObjects()

    -- 保留位置或重置到顶
    if retainPosition then
        local off = math.min(self._offset or 0, self._range or 0)
        self._offset = off
    else
        self._offset = 0
    end

    -- 统一通知滚动物理引擎更新范围（若已附加）
    if ADT and ADT.Scroll and self._adtScroller and self._SyncScrollRange then self:_SyncScrollRange() end

    self:Render(true)
end

-- 渲染当前视区
function ListViewMixin:Render(force)
    local offset = self._offset or 0
    local bottom = offset + (self._viewport or 0)

    -- 计算可见区间的首尾索引（线性扫描，条目数适中即可）
    local first, last
    for i = 1, #self._content do
        local it = self._content[i]
        if not first and (it.bottom >= offset or it.top >= offset) then first = i end
        if it.top <= bottom then last = i else break end
    end
    last = last or #self._content

    -- 释放不可见对象
    for i, obj in pairs(self._actives) do
        if (not first) or i < first or i > last then
            obj:Release()
            self._actives[i] = nil
        end
    end

    -- 获取并布置可见对象
    if first then
        for i = first, last do
            if not self._actives[i] then
                local d = self._content[i]
                local obj = self:AcquireObject(d.templateKey)
                if obj then
                    if d.setupFunc then d.setupFunc(obj) end
                    obj:ClearAllPoints()
                    obj:SetPoint(d.point or 'TOP', self.ScrollRef, d.relativePoint or 'TOP', d.offsetX or 0, -d.top)
                    self._actives[i] = obj
                    if ADT and ADT.DebugPrint then
                        ADT.DebugPrint(string.format('[ListView] acquire i=%d key=%s top=%d bottom=%d', i, tostring(d.templateKey), d.top or -1, d.bottom or -1))
                    end
                end
            end
        end
    end

    -- 更新参考点位置（同步滚动条者可在外部读取 _offset/_range）
    self:SetOffset(offset)
end

-- —————————— 滚动逻辑 ——————————
-- 立即滚动（供内部渲染或需要无动画时调用）
function ListViewMixin:ScrollBy(dy)
    local tgt = (self._offset or 0) + (dy or 0)
    self:ScrollTo(tgt)
end

function ListViewMixin:ScrollTo(offset)
    offset = math.max(0, math.min(offset or 0, self._range or 0))
    self._offset = offset
    self:Render(true)
end

function ListViewMixin:ScrollToTop() self:ScrollTo(0) end

-- 滚轮由 ADT.Scroll 附加后的处理接管；保留占位以兼容旧调用
function ListViewMixin:OnMouseWheel(delta)
    local scroller = self._adtScroller
    if scroller then
        local step = self._step or 30
        if IsShiftKeyDown and IsShiftKeyDown() then step = step * 2 end
        scroller:ScrollBy(-delta * step)
    else
        -- 未附加时退化为立即滚动
        self:ScrollBy(-(delta or 0) * (self._step or 30))
    end
end

function ListViewMixin:OnHide()
    -- 隐藏时通知物理滚动停止
    if self._adtScroller and self._adtScroller.Stop then self._adtScroller:Stop() end
end

-- 创建后附加统一滚动物理引擎
hooksecurefunc(ADT.Scroll or {}, 'AttachListView', function() end) -- 防御：确保 ADT.Scroll 已加载
if ADT and ADT.Scroll and ADT.Scroll.AttachListView then
    -- 在 API.CreateListView 底部调用（见下）
end
