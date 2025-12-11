-- Scroll.lua
-- 单一权威：ADT 统一滚动物理引擎


local ADDON_NAME, ADT = ...
ADT = ADT or {}

ADT.Scroll = ADT.Scroll or {}
local Scroll = ADT.Scroll

-- 可调参数（手感收敛到参考实现）
local TUNING = {
    blend = 0.15,     -- DeltaLerp 收敛速率（与参考一致）
    tick = 1/30,      -- 视图更新节流（约 30 FPS 渲染更新）
}

local function clamp(v, a, b) if v < a then return a elseif v > b then return b else return v end end

local function NewDriver()
    local f = CreateFrame('Frame')
    f:Hide()
    return f
end

-- 统一滚动器（目标位移 + 缓动 / 连续滚动）
-- adapter 需要实现：
--   getRange() -> number        最大滚动范围（px，>=0）
--   getPosition() -> number     当前显示位置（px）
--   setPosition(pos)            即时设置显示位置（px）
--   render?()                   可选：节流的内容回收/填充（如虚拟列表 Render）
local function CreateScroller(adapter)
    local self = {
        a = adapter,
        x = 0,            -- 当前显示位置（offset）
        t = 0,            -- 目标位置（scrollTarget）
        running = false,
        steady = false,   -- 是否处于连续滚动（用于“按住箭头/摇杆”）
        speed = 0,        -- 连续滚动速度（px/s）
        driver = NewDriver(),
        acc = 0,          -- 渲染节流累积时长
    }

    function self:_apply(pos)
        local r = math.max(0, self.a.getRange())
        self.x = clamp(pos, 0, r)
        self.a.setPosition(self.x)
    end

    function self:_renderTick(dt)
        -- 节流 render 调用频率，避免过度重建对象
        if not self.a.render then return end
        self.acc = self.acc + dt
        if self.acc >= TUNING.tick then
            self.acc = 0
            self.a.render()
        end
    end

    function self:_onUpdate(_, dt)
        if dt and dt > 0.05 then dt = 0.05 end
        if not dt or dt <= 0 then return end

        local r = math.max(0, self.a.getRange())

        if self.steady then
            -- 连续滚动：匀速推进，触边后退出 steady
            local nx = self.x + self.speed * dt
            if nx <= 0 then nx = 0; self.steady = false
            elseif nx >= r then nx = r; self.steady = false end
            self:_apply(nx)
            self.t = self.x
            if not self.steady then return self:Stop() end
            self:_renderTick(dt)
            return
        end

        -- 目标缓动：DeltaLerp 收敛到目标
        self.x = ADT.API.DeltaLerp(self.x, self.t, TUNING.blend, dt)
        self:_apply(self.x)

        -- 接近目标即吸附并停止
        local d = self.x - self.t; if d < 0 then d = -d end
        if d < 0.4 then
            self.x = clamp(self.t, 0, r)
            self:_apply(self.x)
            if self.a.render then self.a.render() end
            return self:Stop()
        end

        self:_renderTick(dt)
    end

    function self:Start()
        if self.running then return end
        self.running = true
        self.driver:Show()
        self.driver:SetScript('OnUpdate', function(_, dt) self:_onUpdate(_, dt) end)
    end

    function self:Stop()
        self.running = false
        self.steady = false
        self.driver:SetScript('OnUpdate', nil)
        self.driver:Hide()
    end

    function self:SyncFromHost()
        self.x = self.a.getPosition()
        self.t = self.x
    end

    function self:SyncRange()
        local r = math.max(0, self.a.getRange())
        if self.x > r then self.x = r end
        if self.t > r then self.t = r end
        if self.x < 0 then self.x = 0 end
        if self.t < 0 then self.t = 0 end
        self:_apply(self.x)
    end

    function self:ScrollTo(value)
        local r = math.max(0, self.a.getRange())
        local v = clamp(value or 0, 0, r)
        if v ~= self.t then
            self.t = v
            self.steady = false
            self:Start()
        end
    end

    function self:ScrollBy(delta)
        self:ScrollTo((self.t or 0) + (delta or 0))
    end

    function self:SnapTo(value)
        local r = math.max(0, self.a.getRange())
        self.t = clamp(value or 0, 0, r)
        self.x = self.t
        self:_apply(self.x)
        if self.a.render then self.a.render() end
        self:Stop()
    end

    -- 连续滚动（用于“按住箭头/摇杆”）：strength ∈ [-1, 1]
    function self:SteadyScroll(strength)
        local s = tonumber(strength) or 0
        if s > 0.8 then
            self.speed = 80 + 600 * (s - 0.8)
        elseif s < -0.8 then
            self.speed = -80 + 600 * (s + 0.8)
        else
            self.speed = 100 * s
        end
        if self.speed > -4 and self.speed < 4 then
            return self:StopSteadyScroll()
        end
        self.steady = true
        self:Start()
    end

    function self:StopSteadyScroll()
        if self.steady then
            self.steady = false
            self:Stop()
        end
    end

    return self
end

-- 适配：ListView（支持视觉超界）
function Scroll.AttachListView(view)
    if not view or view._adtScroller then return end

    local adapter = {
        getRange = function() return math.max(0, view._range or 0) end,
        getPosition = function() return view._offset or 0 end,
        setPosition = function(p) view:SetOffset(p or 0) end,
        render = function() view:Render() end,
    }
    local scroller = CreateScroller(adapter)
    view._adtScroller = scroller

    -- 统一鼠标滚轮 → 目标滚动
    view:EnableMouseWheel(true)
    view:SetScript('OnMouseWheel', function(self, delta)
        if not delta or delta == 0 then return end
        -- 到边界时阻断无效滚动（与参考一致）
        if (delta > 0 and scroller.t <= 0) or (delta < 0 and scroller.t >= (view._range or 0)) then
            return
        end
        local step = self._step or 30
        if IsShiftKeyDown and IsShiftKeyDown() then step = step * 2 end
        scroller:ScrollBy(-delta * step)
    end)

    -- 隐藏时停止
    local origOnHide = view:GetScript('OnHide')
    view:SetScript('OnHide', function(self)
        scroller:Stop()
        if origOnHide then origOnHide(self) end
    end)

    -- 尺寸/内容变化时更新范围（由外部在 SetContent/OnSizeChanged 后调用）
    function view:_SyncScrollRange()
        scroller:SyncRange()
    end
end

-- 适配：UIPanelScrollFrame（不支持视觉超界，仅呈现钳制位置）
function Scroll.AttachScrollFrame(scrollFrame)
    if not scrollFrame or scrollFrame._adtScroller then return end
    local child = scrollFrame:GetScrollChild()
    local adapter = {
        getRange = function()
            local r = 0
            if scrollFrame.GetVerticalScrollRange then r = scrollFrame:GetVerticalScrollRange() or 0 end
            return math.max(0, r)
        end,
        getPosition = function()
            if scrollFrame.GetVerticalScroll then return scrollFrame:GetVerticalScroll() or 0 end
            return 0
        end,
        setPosition = function(p)
            local r = 0
            if scrollFrame.GetVerticalScrollRange then r = scrollFrame:GetVerticalScrollRange() or 0 end
            local v = clamp(p or 0, 0, r)
            if scrollFrame.SetVerticalScroll then scrollFrame:SetVerticalScroll(v) end
        end,
    }
    local scroller = CreateScroller(adapter)
    scrollFrame._adtScroller = scroller

    -- 统一鼠标滚轮
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript('OnMouseWheel', function(self, delta)
        if not delta or delta == 0 then return end
        local r = 0; if scrollFrame.GetVerticalScrollRange then r = scrollFrame:GetVerticalScrollRange() or 0 end
        if (delta > 0 and scroller.t <= 0) or (delta < 0 and scroller.t >= r) then
            return
        end
        local step = 32
        if IsShiftKeyDown and IsShiftKeyDown() then step = step * 2 end
        scroller:ScrollBy(-delta * step)
    end)

    -- 内容变更后外部可调用以校正范围
    function scrollFrame:_SyncScrollRange()
        scroller:SyncRange(); scroller:SyncFromHost()
    end

    local origOnHide = scrollFrame:GetScript('OnHide')
    scrollFrame:SetScript('OnHide', function(self)
        scroller:Stop()
        if origOnHide then origOnHide(self) end
    end)
end
