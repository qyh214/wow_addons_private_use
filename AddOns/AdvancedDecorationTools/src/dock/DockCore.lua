
-- 为 GUI（指挥坞）提供所有必需的 API 函数

local ADDON_NAME, ADT = ...

ADT = ADT or {}
ADT.L = ADT.L or {}

-- 核心 API 模块
ADT.API = ADT.API or {}
local API = ADT.API

-- Mixin
function API.Mixin(object, ...)
    for i = 1, select('#', ...) do
        local mixin = select(i, ...)
        for k, v in pairs(mixin) do
            object[k] = v
        end
    end
    return object
end

-- 数学函数
function API.Round(n)
    return math.floor((n or 0) + 0.5)
end

function API.Clamp(value, min, max)
    if value > max then return max
    elseif value < min then return min
    end
    return value
end

function API.Saturate(x)
    if x < 0 then return 0 elseif x > 1 then return 1 else return x end
end

function API.Lerp(a, b, t)
    return (1 - t) * a + t * b
end

-- 纹理锐化控制
function API.DisableSharpening(obj)
    if not obj then return end
    if obj.SetSnapToPixelGrid then pcall(obj.SetSnapToPixelGrid, obj, false) end
    if obj.SetTexelSnappingBias then pcall(obj.SetTexelSnappingBias, obj, 0) end
end

-- 字符串处理
function API.StringTrim(str)
    if not str or str == "" then return nil end
    return str:match("^%s*(.-)%s*$")
end

-- 兼容函数：判断 ToC 版本
function ADT.IsToCVersionEqualOrNewerThan(target)
    local _, _, _, toc = GetBuildInfo()
    toc = tonumber(toc or 0)
    return toc >= (tonumber(target) or 0)
end

-- 缓动函数（动画用）
ADT.EasingFunctions = ADT.EasingFunctions or {}
function ADT.EasingFunctions.outQuart(t, b, c, d)
    t = t / d - 1
    return -c * (t*t*t*t - 1) + b
end
function ADT.EasingFunctions.outQuint(t, b, c, d)
    t = t / d - 1
    return c * (t*t*t*t*t + 1) + b
end

-- 物理弹簧（简易、稳定）：x'' = -k(x-target) - c x'
-- 说明：
--  - 采用半隐式欧拉积分，帧间 dt 夹紧到 [0, 1/30] 以避免卡顿时的不稳定。
--  - stiffness(刚度) 与 damping(阻尼) 为可调参数，便于统一动效风格。
--  - 返回更新后的 x、v；调用方可据此设置 UI 偏移。
function API.SpringStep(x, v, target, stiffness, damping, dt)
    stiffness = tonumber(stiffness) or 260
    damping   = tonumber(damping)   or 28
    dt = math.min(math.max(dt or 0, 0), 1/30)
    local a = -stiffness * (x - target) - damping * v
    v = v + a * dt
    x = x + v * dt
    return x, v
end

-- 创建标准弹簧驱动器
-- 用法：
--   local s = API.CreateSpringDriver({x=initial, stiffness=280, damping=30}, function(x)
--       -- 根据 x 更新 UI 偏移
--   end)
--   s:SetTarget(0) / s:SetTarget(200)
--   s:AttachFrame(frame)  -- 自动注册/卸载 OnUpdate
function API.CreateSpringDriver(opts, onUpdate)
    local driver = {}
    driver.x = (opts and opts.x) or 0
    driver.v = 0
    driver.target = (opts and opts.target) or driver.x
    driver.stiffness = (opts and opts.stiffness) or 280
    driver.damping = (opts and opts.damping) or 30
    driver.onUpdate = onUpdate

    function driver:SetTarget(t)
        self.target = tonumber(t) or 0
        self:_ensureTick()
    end

    function driver:_tick(_, elapsed)
        local nx, nv = API.SpringStep(self.x, self.v, self.target, self.stiffness, self.damping, elapsed)
        self.x, self.v = nx, nv
        if self.onUpdate then pcall(self.onUpdate, self.x) end
        -- 静止阈值：位置<0.5px 且速度很小即停表
        if math.abs(self.x - self.target) < 0.5 and math.abs(self.v) < 2 then
            self.x = self.target; self.v = 0
            if self.onUpdate then pcall(self.onUpdate, self.x) end
            self:_stopTick()
        end
    end

    function driver:_ensureTick()
        if self.frame and not self.ticking then
            self.ticking = true
            self.frame:SetScript("OnUpdate", function(_, e) driver:_tick(_, e) end)
        end
    end

    function driver:_stopTick()
        if self.frame and self.ticking then
            self.ticking = false
            self.frame:SetScript("OnUpdate", nil)
        end
    end

    function driver:AttachFrame(frame)
        self.frame = frame
        if self.ticking then
            self.frame:SetScript("OnUpdate", function(_, e) driver:_tick(_, e) end)
        end
    end

    return driver
end

-- UI 声音
ADT.UI = ADT.UI or {}
-- PlaySoundCue：统一 UI 声音触发接口
function ADT.UI.PlaySoundCue(key)
    local kit = SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or 1204
    if key == 'ui.checkbox.off' then
        kit = SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF or 1203
    elseif key == 'ui.scroll.step' or key == 'ui.scroll.thumb' then
        kit = SOUNDKIT and SOUNDKIT.IG_MINIMAP_OPEN or 891
    elseif key == 'ui.tab.switch' then
        kit = SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION or 857
    end
    if PlaySound then pcall(PlaySound, kit) end
end

-- API.CreateObjectPool：重新实现为最简对象池（与参考插件无关的独立实现）
function API.CreateObjectPool(createFunc, onAcquire, onRelease)
    local pool = {}
    local free, used = {}, {}

    local function attachRelease(obj)
        obj.Release = function(o)
            for i, v in ipairs(used) do
                if v == o then
                    table.remove(used, i)
                    if onRelease then onRelease(o) end
                    o:Hide(); o:ClearAllPoints()
                    free[#free+1] = o
                    break
                end
            end
        end
    end

    function pool:Acquire()
        local obj = table.remove(free)
        if not obj then obj = createFunc() end
        used[#used+1] = obj
        attachRelease(obj)
        obj:Show()
        if onAcquire then onAcquire(obj) end
        return obj
    end

    function pool:ReleaseAll()
        if #used == 0 then return end
        for i = #used, 1, -1 do
            local obj = used[i]
            if onRelease then onRelease(obj) end
            obj:Hide(); obj:ClearAllPoints()
            free[#free+1] = obj
            used[i] = nil
        end
    end

    function pool:EnumerateActive()
        return ipairs(used)
    end

    function pool:CallMethod(method, ...)
        for _, obj in ipairs(used) do
            local fn = obj and obj[method]
            if fn then fn(obj, ...) end
        end
    end

    return pool
end

-- 历史别名说明：不再暴露任何额外别名，统一直接使用 API.CreateObjectPool

-- 已移除自定义九宫格面板代码：统一使用暴雪内置 Atlas 与现有边框贴图即可。




-- Settings 面板最小依赖
function ADT.AnyShownModuleOptions() return false end
function ADT.CloseAllModuleOptions() return false end

-- CommandDock 模块注册
local CommandDock = ADT.CommandDock or {}
ADT.CommandDock = CommandDock

local L = ADT.L

-- 内部：构建默认模块，并初始化映射
local function buildModules()
    local modules = {}
    local function dbgToggle(dbKey, state)
        if ADT and ADT.DebugPrint then
            ADT.DebugPrint(string.format("[Toggle] %s=%s", tostring(dbKey), tostring(state)))
        end
    end
    
    -- 进入编辑模式自动打开 Dock（控制中心）
    local moduleEditorAutoOpen = {
        name = (L and L["Auto Open Dock in Editor"]) or "Open Dock on entering editor",
        dbKey = 'EnableDockAutoOpenInEditor',
        description = (L and L["Auto Open Dock in Editor tooltip"]) or "Open ADT Dock automatically when entering the editor; manual Ctrl+Q or /adt unaffected.",
        -- 无需 toggleFunc：改为订阅 ADT.Settings（见 DockUI 绑定）
        categoryKeys = { 'Housing' },
        uiOrder = 0,
    }

    -- 住宅快捷键设置模块（4 个独立开关）
    local moduleRepeat = {
        name = (L and L["Enable Duplicate"]) or "启用复制",
        dbKey = 'EnableDupe',
        description = (L and L["Enable Duplicate tooltip"]) or "悬停装饰时按 CTRL+D 可快速放置相同装饰",
        -- 统一持久化 + 模块订阅，无需 toggleFunc
        categoryKeys = { 'Housing' },
        uiOrder = 1,
    }
    
    local moduleCopy = {
        name = (L and L["Enable Copy"]) or "启用复制",
        dbKey = 'EnableCopy',
        description = (L and L["Enable Copy tooltip"]) or "悬停或选中装饰时按 CTRL+C 可复制到剪切板",
        categoryKeys = { 'Housing' },
        uiOrder = 2,
    }
    
    local moduleCut = {
        name = (L and L["Enable Cut"]) or "启用剪切",
        dbKey = 'EnableCut',
        description = (L and L["Enable Cut tooltip"]) or "选中装饰时按 CTRL+X 可剪切（移除并复制到剪切板）",
        categoryKeys = { 'Housing' },
        uiOrder = 3,
    }
    
    local modulePaste = {
        name = (L and L["Enable Paste"]) or "启用粘贴",
        dbKey = 'EnablePaste',
        description = (L and L["Enable Paste tooltip"]) or "按 CTRL+V 可从剪切板粘贴装饰",
        categoryKeys = { 'Housing' },
        uiOrder = 4,
    }
    
    local moduleBatchPlace = {
        name = (L and L["Enable Batch Place"]) or "启用批量放置",
        dbKey = 'EnableBatchPlace',
        description = (L and L["Enable Batch Place tooltip"]) or "选中装饰后按住 CTRL 点击可连续放置多个相同装饰",
        categoryKeys = { 'Housing' },
        uiOrder = 5,
    }


    -- 启用 T 重置默认属性
    local moduleResetT = {
        name = (L and L["Enable T Reset"]) or "启用 T 重置默认属性",
        dbKey = 'EnableResetT',
        description = (L and L["Enable T Reset tooltip"]) or "在专家模式下按 T 将重置当前子模式的变换；关闭后仅保留 Ctrl+T 的全部重置。",
        categoryKeys = { 'Housing' },
        uiOrder = 6,
    }

    -- 启用 Ctrl+T 全部重置
    local moduleResetAll = {
        name = (L and L["Enable CTRL+T Reset All"]) or "启用 CTRL+T 全部重置",
        dbKey = 'EnableResetAll',
        description = (L and L["Enable CTRL+T Reset All tooltip"]) or "在专家模式下按 Ctrl+T 将重置所有变换；关闭后不再显示提示且禁用该热键。",
        categoryKeys = { 'Housing' },
        uiOrder = 7,
    }

    -- 启用 L 锁定/解锁
    local moduleLock = {
        name = (L and L["Enable L Lock"]) or "启用 L 以锁定装饰",
        dbKey = 'EnableLock',
        description = (L and L["Enable L Lock tooltip"]) or "按 L 锁定/解锁当前悬停的装饰；关闭后隐藏提示并禁用该热键。",
        toggleFunc = function(state)
            if ADT and ADT.SetDBValue then ADT.SetDBValue('EnableLock', state) end
            dbgToggle('EnableLock', state)
            if ADT and ADT.Housing and ADT.Housing.UpdateHintVisibility then ADT.Housing:UpdateHintVisibility() end
            if ADT and ADT.Housing and ADT.Housing.RefreshOverrides then ADT.Housing:RefreshOverrides() end
        end,
        categoryKeys = { 'Housing' },
        uiOrder = 8,
    }

    -- 启用 Q/E 旋转 90°
    local moduleQERotate = {
        name = (L and L["Enable Q/E Rotate"]) or "启用 Q/E 旋转",
        dbKey = 'EnableQERotate',
        description = (L and L["Enable Q/E Rotate tooltip"]) or "在住宅编辑器内按 Q / E 将当前抓起/选中的装饰旋转 -90° / +90°；关闭后禁用该热键并隐藏相关提示。",
        toggleFunc = function(state)
            if ADT and ADT.SetDBValue then ADT.SetDBValue('EnableQERotate', state) end
            dbgToggle('EnableQERotate', state)
            if ADT and ADT.Housing and ADT.Housing.UpdateHintVisibility then ADT.Housing:UpdateHintVisibility() end
            if ADT and ADT.Housing and ADT.Housing.RefreshOverrides then ADT.Housing:RefreshOverrides() end
        end,
        categoryKeys = { 'Housing' },
        uiOrder = 9,
    }
    
    -- 语言选择下拉菜单模块
    local moduleLanguage = {
        name = (L and L["Language"]) or "语言 / Language",
        dbKey = 'SelectedLanguage',
        type = 'dropdown',  -- 下拉菜单类型
        options = {
            { value = nil, text = (L and L["Language Auto"]) or "自动 (跟随客户端)" },
            { value = "zhCN", text = "中文" },
            { value = "enUS", text = "English" },
        },
        description = (L and L["Language Reload Hint"]) or "部分文字可能需要 /reload 后更新",
        toggleFunc = function(newValue)
            if ADT and ADT.SetDBValue then ADT.SetDBValue('SelectedLanguage', newValue) end
            -- 立即应用新语言
            if ADT and ADT.ApplyLocale then
                local locale = newValue or ADT.GetActiveLocale()
                ADT.ApplyLocale(locale)
            end
            -- 重新构建设置模块并刷新当前 UI
            if ADT and ADT.CommandDock then
                local CC = ADT.CommandDock
                if CC and CC.RebuildModules then
                    CC:RebuildModules()
                else
                    -- 旧版本兜底：直接清空，下次访问会重建
                    CC._sorted = nil
                    CC._dbKeyMap = nil
                    CC._providersApplied = nil
                end
                local Main = CC.SettingsPanel
                local canRefresh = Main and Main.ModuleTab and Main.ModuleTab.ScrollView
                if canRefresh then
                    if Main.RefreshCategoryList then Main:RefreshCategoryList() end
                    -- 避免切到“混排视图”，保持当前分类的“单分类渲染”
                    local key = (ADT and ADT.GetDBValue and ADT.GetDBValue('LastCategoryKey')) or Main.currentSettingsCategory or Main.currentDecorCategory or Main.currentAboutCategory
                    local cat = key and CC:GetCategoryByKey(key) or nil
                    if cat and cat.categoryType == 'decorList' and Main.ShowDecorListCategory then
                        Main:ShowDecorListCategory(key)
                    elseif cat and cat.categoryType == 'about' and Main.ShowAboutCategory then
                        Main:ShowAboutCategory(key)
                    else
                        -- 默认/设置类：采用单分类渲染
                        local targetKey = key
                        if not (cat and cat.categoryType == 'settings') then
                            -- 找到第一个设置类分类作为回退
                            for _, info in ipairs(CC:GetSortedModules()) do
                                if info.categoryType == 'settings' then targetKey = info.key break end
                            end
                        end
                        if targetKey and Main.ShowSettingsCategory then
                            Main:ShowSettingsCategory(targetKey)
                        elseif Main.RefreshFeatureList then
                            -- 极端兜底：仍可用混排视图
                            Main:RefreshFeatureList()
                        end
                    end
                    if Main.RefreshLanguageLayout then Main:RefreshLanguageLayout(true) end
                end
            end
            -- 通知 Housing 模块刷新右侧提示文本
            if ADT and ADT.Housing and ADT.Housing.OnLocaleChanged then
                ADT.Housing:OnLocaleChanged()
            end
            -- 通知 Favorites 同步标题/下拉文案
            if ADT and ADT.Favorites and ADT.Favorites.OnLocaleChanged then
                ADT.Favorites:OnLocaleChanged()
            end
        end,
        categoryKeys = { 'Housing' },
        uiOrder = 100,  -- 放在最后
    }

    modules[1] = {
        key = 'Housing',
        categoryName = (L and L['SC Housing']) or '通用',
        categoryType = 'settings', -- 设置类分类
        modules = { moduleEditorAutoOpen, moduleRepeat, moduleCopy, moduleCut, modulePaste, moduleBatchPlace, moduleResetT, moduleResetAll, moduleLock, moduleQERotate, moduleLanguage },
        numModules = 11,
    }

    -- 临时板分类（装饰列表类）
    modules[2] = {
        key = 'Clipboard',
        categoryName = (L and L['SC Clipboard']) or '临时板',
        categoryType = 'decorList', -- 装饰列表类分类
        modules = {},
        numModules = 0,
        -- 获取列表数据的回调
        getListData = function()
            if ADT and ADT.Clipboard and ADT.Clipboard.GetAll then
                return ADT.Clipboard:GetAll() or {}
            end
            return {}
        end,
        -- 点击装饰项的回调
        onItemClick = function(decorID, button)
            if button == 'RightButton' then
                -- 右键：从列表移除
                if ADT and ADT.Clipboard then
                    local list = ADT.Clipboard:GetAll()
                    for i, item in ipairs(list) do
                        if item.decorID == decorID then
                            ADT.Clipboard:RemoveAt(i)
                            break
                        end
                    end
                end
            else
                -- 左键：开始放置
                if ADT and ADT.Clipboard and ADT.Clipboard.StartPlacing then
                    ADT.Clipboard:StartPlacing(decorID)
                end
            end
        end,
        -- 空列表提示
        emptyText = string.format("%s\n%s", (L and L['Clipboard Empty Line1']) or '临时板为空', (L and L['Clipboard Empty Line2']) or 'Ctrl+S 存入；Ctrl+R 取出'),
    }

    -- 最近放置分类（装饰列表类）
    modules[3] = {
        key = 'History',
        categoryName = (L and L['SC History']) or '最近放置',
        categoryType = 'decorList', -- 装饰列表类分类
        modules = {},
        numModules = 0,
        -- 获取列表数据的回调
        getListData = function()
            if ADT and ADT.History and ADT.History.GetAll then
                return ADT.History:GetAll() or {}
            end
            return {}
        end,
        -- 点击装饰项的回调
        onItemClick = function(decorID, button)
            if button == 'RightButton' then
                -- 右键：暂不支持从历史移除单项
                return
            else
                -- 左键：开始放置
                if ADT and ADT.History and ADT.History.StartPlacing then
                    ADT.History:StartPlacing(decorID)
                end
            end
        end,
        -- 空列表提示
        emptyText = string.format("%s\n%s", (L and L['History Empty Line1']) or '暂无放置记录', (L and L['History Empty Line2']) or '放置装饰后会自动记录'),
    }

    -- 自动旋转分类（设置类）——需位于“信息”之上
    modules[4] = {
        key = 'AutoRotate',
        categoryName = (L and L['SC AutoRotate']) or '自动旋转',
        categoryType = 'settings', -- 设置类分类
        modules = {},
        numModules = 0,
    }

    -- 信息分类（关于插件的信息）
    modules[5] = {
        key = 'About',
        categoryName = (L and L['SC About']) or '信息',
        categoryType = 'about', -- 关于信息类分类
        modules = {},
        numModules = 0,
        -- 获取插件信息
        getInfoText = function()
            local ver = "未知"
            if C_AddOns and C_AddOns.GetAddOnMetadata then
                ver = C_AddOns.GetAddOnMetadata("AdvancedDecorationTools", "Version") or ver
            elseif GetAddOnMetadata then
                ver = GetAddOnMetadata("AdvancedDecorationTools", "Version") or ver
            end
            -- 文本本地化：除“瑟小瑟”保留中文外，其他均跟随语言表
            local name = (L and L['Addon Full Name']) or '高级装修工具'
            local versionLabelFmt = (L and L['Version Label']) or '版本：%s'
            local creditsLabel = (L and L['Credits Label']) or '制作信息'
            local biliLabel = (L and L['Bilibili Label']) or 'bilibili:'
            local qqLabel = (L and L['QQ Group Label']) or 'QQ Group:'
            -- 不使用空行，避免产生多余分隔符
            return string.format(
                "|cffffcc00%s|r\n" ..
                "|cffaaaaaa" .. versionLabelFmt .. "|r\n" ..
                "|cffcccccc%s|r\n" ..
                "|cff00aaff%s|r 瑟小瑟\n" ..
                "|cff00aaff%s|r 980228474",
                name,
                ver,
                creditsLabel,
                biliLabel,
                qqLabel
            )
        end,
    }

    -- 初始化映射（6 个设置模块）
    CommandDock._dbKeyMap = {
        [moduleRepeat.dbKey] = moduleRepeat,
        [moduleCopy.dbKey] = moduleCopy,
        [moduleCut.dbKey] = moduleCut,
        [modulePaste.dbKey] = modulePaste,
        [moduleBatchPlace.dbKey] = moduleBatchPlace,
        [moduleLanguage.dbKey] = moduleLanguage,
    }
    return modules
end

local function ensureSorted(self)
    -- 若未构建，先构建基础模块（语言、剪切板等）
    if not self._sorted then self._sorted = buildModules() end
    if not self._dbKeyMap then self._dbKeyMap = {} end

    -- 语言切换会清空 _sorted/_dbKeyMap；为保持“单一权威 + DRY”，
    -- 通过“模块提供者”在每次 ensureSorted() 时重新注入外部功能模块（如自动旋转）。
    -- 提供者是一个函数：function(providerCommandDock) ... end
    if self._moduleProviders and not self._providersApplied then
        -- 注意：provider 里通常会调用 CommandDock:AddModule，而该函数内部又会
        -- 调用 ensureSorted()。如果此处在“调用 provider 之后”才设置
        -- _providersApplied=true，就会导致重入，再次触发 provider 循环，
        -- 形成递归/堆栈溢出或把 _sorted 状态弄乱，表现为“切到某分类后
        -- 中央列表为空，且其它分类也无法再渲染”。
        -- 解决：在进入 provider 循环之前，先将 _providersApplied 置为 true，
        -- 把本次“应用提供者”的过程视为已开始，从而阻止重入。
        self._providersApplied = true
        for _, provider in ipairs(self._moduleProviders) do
            if type(provider) == 'function' then
                -- 安全调用，避免某个模块异常导致整体失败
                pcall(provider, self)
            end
        end
        -- 如需在 provider 失败时重试，可在外部显式调用 RebuildModules()。
    end
end

function CommandDock:GetSortedModules()
    ensureSorted(self)
    return self._sorted
end

local function getCategoryDisplayName(key)
    if key == 'Housing' then
        return (L and L['SC Housing']) or '通用'
    elseif key == 'Clipboard' then
        return (L and L['SC Clipboard']) or '临时板'
    elseif key == 'History' then
        return (L and L['SC History']) or '最近放置'
    elseif key == 'AutoRotate' then
        return (L and L['SC AutoRotate']) or '自动旋转'
    elseif key == 'About' then
        return (L and L['SC About']) or '信息'
    end
    return tostring(key)
end

local function sortCategory(cat)
    table.sort(cat.modules, function(a, b)
        local ao, bo = tonumber(a.uiOrder) or 9999, tonumber(b.uiOrder) or 9999
        if ao ~= bo then return ao < bo end
        local at, bt = tonumber(a.moduleAddedTime) or 0, tonumber(b.moduleAddedTime) or 0
        if at ~= bt then return at > bt end
        local an, bn = tostring(a.name or ''), tostring(b.name or '')
        return an < bn
    end)
    cat.numModules = #cat.modules
end

-- 动态注册模块（供各功能文件调用）
function CommandDock:AddModule(moduleData)
    if type(moduleData) ~= 'table' then return end
    ensureSorted(self)

    local dbKey = moduleData.dbKey
    if dbKey and self._dbKeyMap and self._dbKeyMap[dbKey] then
        -- 已存在则先从原分类移除，保证单一权威（DRY）
        for _, cat in ipairs(self._sorted) do
            for i, m in ipairs(cat.modules) do
                if m.dbKey == dbKey then
                    table.remove(cat.modules, i)
                    sortCategory(cat)
                    break
                end
            end
        end
    end

    local catKey = (moduleData.categoryKeys and moduleData.categoryKeys[1]) or 'Misc'
    local category
    for _, cat in ipairs(self._sorted) do
        if cat.key == catKey then category = cat break end
    end
    if not category then
        category = {
            key = catKey,
            categoryName = getCategoryDisplayName(catKey),
            modules = {},
            numModules = 0,
        }
        table.insert(self._sorted, category)
    end

    table.insert(category.modules, moduleData)
    sortCategory(category)
    if dbKey then self._dbKeyMap[dbKey] = moduleData end
end

-- 注册模块提供者（用于在语言切换等“重建分类”场景下，重新注入外部模块）
function CommandDock:RegisterModuleProvider(providerFunc)
    if type(providerFunc) ~= 'function' then return end
    self._moduleProviders = self._moduleProviders or {}
    table.insert(self._moduleProviders, providerFunc)
end

-- 触发重建：供外部在重大状态变更（如语言切换）后调用
function CommandDock:RebuildModules()
    self._sorted = nil
    self._dbKeyMap = nil
    self._providersApplied = nil
    -- 下次访问 GetSortedModules() 时会自动重建并重新注入
end

function CommandDock:GetModule(dbKey)
    ensureSorted(self)
    return dbKey and self._dbKeyMap and self._dbKeyMap[dbKey]
end

function CommandDock:GetModuleCategoryName(dbKey)
    ensureSorted(self)
    if not dbKey then return end
    for _, cat in ipairs(self._sorted) do
        for _, m in ipairs(cat.modules) do
            if m.dbKey == dbKey then
                return cat.categoryName
            end
        end
    end
end

function CommandDock:UpdateCurrentSortMethod() return 1 end
function CommandDock:SetCurrentSortMethod(_) end
function CommandDock:GetNumFilters() return 1 end
function CommandDock:AnyNewFeatureMarker() return false end
function CommandDock:FlagCurrentNewFeatureMarkerSeen() end

-- 获取指定 key 的分类信息（包括装饰列表分类）
function CommandDock:GetCategoryByKey(key)
    ensureSorted(self)
    if not key then return nil end
    for _, cat in ipairs(self._sorted) do
        if cat.key == key then
            return cat
        end
    end
    return nil
end

-- 获取装饰列表分类的列表项数量（用于角标显示）
function CommandDock:GetDecorListCount(key)
    local cat = self:GetCategoryByKey(key)
    if cat and cat.categoryType == 'decorList' and cat.getListData then
        local list = cat.getListData()
        return type(list) == 'table' and #list or 0
    end
    return 0
end

function CommandDock:GetSearchResult(text)
    ensureSorted(self)
    text = string.lower(tostring(text or ''))
    if text == '' then return self:GetSortedModules() end
    local results = {}
    for _, cat in ipairs(self._sorted) do
        local matched = { key = cat.key, categoryName = cat.categoryName, modules = {}, numModules = 0 }
        for _, m in ipairs(cat.modules) do
            local hay = table.concat({
                m.name or '',
                m.description or '',
                table.concat(m.searchTags or {}, ' '),
                cat.categoryName or '',
            }, ' ')
            if string.find(string.lower(hay), text, 1, true) then
                table.insert(matched.modules, m)
            end
        end
        if #matched.modules > 0 then
            matched.numModules = #matched.modules
            table.insert(results, matched)
        end
    end
    return results
end
