--[[
    ExwindState.lua - 状态管理系统

    职责：
    1. State 表维护 (InCombat, SpecID, PStat_* 等)
    2. 状态订阅与回调 (WatchState / UpdateState)
    3. 差值监控 (WatchStateDelta) - 12.0.5 起停用
    4. 玩家属性采集 (PStat_* 系列)
    5. 职业/专精信息采集

    可用的内置 State 键：
    - InCombat (boolean)
    - InInstance (boolean)
    - InstanceType (string)
    - InstanceID (number)
    - MapID (number)
    - MapGroup (number, 无分组时等于 MapID)
    - ZoneText (string, GetMinimapZoneText 返回的本地化区域名)
    - DifficultyID (number)
    - InMythicPlus (boolean)
    - IsMounted (boolean)
    - MythicPlusForcesCurrent (number)
    - MythicPlusForcesTotal (number)
    - MythicPlusForcesPercent (number)
    - MythicPlusForcesText (string)
    - MythicPlusForcesValid (boolean)
    - ClassID (number)
    - ClassName (string)
    - SpecID (number)
    - SpecName (string)
    - RoleKey (string: tank/heal/dps/unknown)
    - RoleName (string)
    - DevMode (boolean)
    - PStat_Str, PStat_Agi, PStat_Sta, PStat_Int (主属性)
    - PStat_Major (智能主属性)
    - PStat_Crit, PStat_Haste, PStat_Mastery, PStat_Versa (二级属性 %)
    - PStat_Leech, PStat_Avoidance, PStat_Speed (三级属性)
    - PStat_Armor, PStat_Dodge, PStat_Parry, PStat_Block (防御属性)
    - PStat_EquippedItemLevel, PStat_MaxHealth, PStat_Movement, PStat_Durability
    - DungeonBossKilledCount (number)
    - DungeonBossProgressIndex (number, 1=1号前, 2=2号前 ...)
--]]

local ExwindTools = _G.ExwindTools
if not ExwindTools then
    error("[ExwindState] ExwindTools 核心未加载！请检查 .toc 加载顺序。")
    return
end

--=======================================================================
--========================== STATE 表定义 ===============================
--=======================================================================

ExwindTools.State = {
    -- 核心状态
    InCombat = false,
    InInstance = false,
    InstanceType = "none",
    InstanceID = 0, --副本ID

    MapID = 0,      --地图ID
    MapGroup = 0,   --地图组
    ZoneText = "",  --当前小地图区域名（本地化文本）
    DifficultyID = 0,
    InMythicPlus = false,
    IsMounted = false,
    MythicPlusForcesCurrent = 0,
    MythicPlusForcesTotal = 0,
    MythicPlusForcesPercent = 0,
    MythicPlusForcesText = "",
    MythicPlusForcesValid = false,
    IsInParty = false,
    IsInRaid = false,
    AuraSecretsActive = false,
    -- 首领战状态
    IsBossEncounter = false,
    EncounterID = 0,
    DungeonBossKilledCount = 0,
    DungeonBossProgressIndex = 0,

    -- 身份状态
    ClassID = 0,
    ClassName = "未知",
    SpecID = 0,
    SpecName = "未知",
    RoleKey = "unknown",
    RoleName = "未知职责",
    Level = 0,
    PlayerName = "",
    RealmName = "",

    -- 开发者模式
    DevMode = false,

    -- 玩家属性 (PStat_*)
    PStat_Str = 0,
    PStat_Agi = 0,
    PStat_Sta = 0,
    PStat_Int = 0,
    PStat_Major = 0,
    PStat_Crit = 0,
    PStat_Haste = 0,
    PStat_Mastery = 0,
    PStat_Versa = 0,
    PStat_VersaText = "",
    PStat_VersaRatingBonus = 0,
    PStat_VersaAuraBonus = 0,
    PStat_Leech = 0,
    PStat_Avoidance = 0,
    PStat_Speed = 0,
    PStat_Armor = 0,
    PStat_Dodge = 0,
    PStat_Parry = 0,
    PStat_Block = 0,
    PStat_EquippedItemLevel = 0,
    PStat_MaxHealth = 0,
    PStat_Movement = 0,
    PStat_MovementText = "",
    PStat_Durability = 100,

    -- 打断技能状态
    InterruptReady = true,
}


ExwindTools.StateCallbacks = {}
ExwindTools.StateDeltaDisabled = true

local function IsSecretValue(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

-- ENCOUNTER_START 在 /reload 后不会重放，缓存最近一次首领战信息用于重载恢复
local EX_STATE_DB = ExwindTools:GetModuleDB("ExwindState", {
    encounter = {
        inProgress = false,
        id = 0,
        instanceID = 0,
        ts = 0,
    },
})

local function SetEncounterState(isInProgress, encounterID)
    local id = isInProgress and (tonumber(encounterID) or 0) or 0
    local instanceID = tonumber((select(8, GetInstanceInfo()))) or 0

    ExwindTools:UpdateState("IsBossEncounter", isInProgress and true or false)
    ExwindTools:UpdateState("EncounterID", id)

    local e = EX_STATE_DB.encounter or {}
    EX_STATE_DB.encounter = e
    e.inProgress = isInProgress and true or false
    e.id = id
    e.instanceID = instanceID
    e.ts = (GetServerTime and GetServerTime()) or time()
end

local function QueryCurrentEncounterID()
    local id = 0

    if C_EncounterJournal and type(C_EncounterJournal.GetCurrentEncounterInfo) == "function" then
        local ok, a, b, c = pcall(C_EncounterJournal.GetCurrentEncounterInfo)
        if ok then
            -- 常见返回: name, description, encounterID, ...
            id = tonumber(c) or 0
            if id <= 0 and type(a) == "table" then
                id = tonumber(a.encounterID or a.id) or 0
            end
        end
    end

    if id <= 0 and type(EJ_GetCurrentEncounterInfo) == "function" then
        local ok, a, b, c = pcall(EJ_GetCurrentEncounterInfo)
        if ok then
            id = tonumber(c) or tonumber(a) or 0
        end
    end

    if id > 0 then return id end
    return 0
end

local function TryGetScenarioCriteriaInfo(index)
    if C_ScenarioInfo and type(C_ScenarioInfo.GetCriteriaInfo) == "function" then
        local ok, info = pcall(C_ScenarioInfo.GetCriteriaInfo, index)
        if ok and type(info) == "table" then
            return info
        end
    end

    if C_Scenario and type(C_Scenario.GetCriteriaInfo) == "function" then
        local ok, info = pcall(C_Scenario.GetCriteriaInfo, index)
        if ok and type(info) == "table" then
            return info
        end
    end

    if type(GetCriteriaInfo) == "function" then
        local ok, description, _, _, quantityString, currentQuantity, totalQuantity = pcall(GetCriteriaInfo, index)
        if ok then
            return {
                description = description,
                quantityString = quantityString,
                quantity = currentQuantity,
                totalQuantity = totalQuantity,
            }
        end
    end
end

local function IsBossScenarioCriteria(info)
    if type(info) ~= "table" then
        return false
    end
    local description = tostring(info.description or info.criteriaString or info.name or "")
    if description == "" then
        return false
    end
    if description:find("击败", 1, true) ~= 1 then
        return false
    end
    local totalQuantity = tonumber(info.totalQuantity or info.maxQuantity or 0) or 0
    if totalQuantity > 0 and totalQuantity ~= 1 then
        return false
    end
    return true
end

local MPLUS_FORCES_KEYWORDS = {
    "enemy forces",
    "forces",
    "敌军",
    "部队",
    "兵力",
}

local function ParseForcesNumber(value)
    if value == nil then
        return nil
    end
    local text = tostring(value or "")
    text = text:gsub("%%", "")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return tonumber(text)
end

local function ParseForcesQuantityString(text)
    text = tostring(text or "")
    local a, b = text:match("(%d+%.?%d*)%s*/%s*(%d+%.?%d*)")
    if a and b then
        return tonumber(a), tonumber(b)
    end
    return ParseForcesNumber(text), nil
end

local function NormalizeForcesCriteriaRecord(info)
    if type(info) ~= "table" then
        return nil
    end
    local description = tostring(info.description or info.criteriaString or info.name or "")
    local quantityString = tostring(info.quantityString or "")
    local current = ParseForcesNumber(info.quantity or info.curQuantity or info.currentQuantity)
    local total = ParseForcesNumber(info.totalQuantity or info.maxQuantity)
    local parsedCurrent, parsedTotal = ParseForcesQuantityString(quantityString)
    current = parsedCurrent or current
    total = total or parsedTotal
    if not current or not total or total <= 0 then
        return nil
    end
    return {
        description = description,
        quantityString = quantityString,
        current = current,
        total = total,
        percent = current / total * 100,
    }
end

local function MatchesForcesCriteria(info)
    local haystack = string.lower(tostring(info and info.description or "") .. " " .. tostring(info and info.quantityString or ""))
    for _, keyword in ipairs(MPLUS_FORCES_KEYWORDS) do
        if haystack:find(keyword, 1, true) then
            return true
        end
    end
    return false
end

local function GetLiveMythicPlusForcesInfo()
    local fallback = nil
    local nilCount = 0
    for idx = 1, 16 do
        local raw = TryGetScenarioCriteriaInfo(idx)
        if not raw then
            nilCount = nilCount + 1
            if nilCount >= 3 then
                break
            end
        else
            nilCount = 0
            local info = NormalizeForcesCriteriaRecord(raw)
            if info then
                if MatchesForcesCriteria(info) then
                    return info
                end
                if not fallback and tonumber(info.total) and tonumber(info.total) >= 100 then
                    fallback = info
                end
            end
        end
    end
    return fallback
end

local function RefreshMythicPlusForcesState()
    local state = ExwindTools and ExwindTools.State or nil
    local inMythicPlus = state and state.InMythicPlus == true
    local info = inMythicPlus and GetLiveMythicPlusForcesInfo() or nil
    if not info then
        ExwindTools:UpdateState("MythicPlusForcesCurrent", 0)
        ExwindTools:UpdateState("MythicPlusForcesTotal", 0)
        ExwindTools:UpdateState("MythicPlusForcesPercent", 0)
        ExwindTools:UpdateState("MythicPlusForcesText", "")
        ExwindTools:UpdateState("MythicPlusForcesValid", false)
        return
    end
    ExwindTools:UpdateState("MythicPlusForcesCurrent", tonumber(info.current) or 0)
    ExwindTools:UpdateState("MythicPlusForcesTotal", tonumber(info.total) or 0)
    ExwindTools:UpdateState("MythicPlusForcesPercent", tonumber(info.percent) or 0)
    ExwindTools:UpdateState("MythicPlusForcesText", tostring(info.quantityString or ""))
    ExwindTools:UpdateState("MythicPlusForcesValid", true)
end

local SPECIAL_DUNGEON_BOSS_PROGRESS_ORDERS = {
    -- 艾杰斯亚学院：常规路线是 3号 -> 2号 -> 1号 -> 4号。
    -- DungeonBossProgressIndex 仍表示路线阶段：1=路线第1个BOSS前，2=路线第2个BOSS前...
    [2526] = { 3, 2, 1, 4 },
}

local function GetSpecialDungeonBossProgressOrder(instanceID, mapID, mapGroup)
    local iid = tonumber(instanceID) or 0
    local mid = tonumber(mapID) or 0
    local mgid = tonumber(mapGroup) or 0
    return SPECIAL_DUNGEON_BOSS_PROGRESS_ORDERS[iid]
        or SPECIAL_DUNGEON_BOSS_PROGRESS_ORDERS[mid]
        or SPECIAL_DUNGEON_BOSS_PROGRESS_ORDERS[mgid]
end

local function ResolveDungeonBossProgressFromOrder(bossCriteria, order)
    if type(bossCriteria) ~= "table" or type(order) ~= "table" then
        return nil, nil
    end
    for routeIndex = 1, #order do
        local criteriaIndex = tonumber(order[routeIndex]) or 0
        local info = bossCriteria[criteriaIndex]
        if type(info) ~= "table" then
            return nil, nil
        end
        if info.completed ~= true then
            return routeIndex - 1, routeIndex
        end
    end
    return #order, #order + 1
end

local function RefreshDungeonBossProgressState()
    local state = ExwindTools and ExwindTools.State or nil
    local inInstance = state and state.InInstance == true
    local instanceType = tostring(state and state.InstanceType or "none")
    if inInstance ~= true or (instanceType ~= "party" and instanceType ~= "scenario") then
        ExwindTools:UpdateState("DungeonBossKilledCount", 0)
        ExwindTools:UpdateState("DungeonBossProgressIndex", 0)
        return
    end

    local killedCount = 0
    local bossCriteriaCount = 0
    local bossCriteria = {}
    local nilCount = 0
    for idx = 1, 16 do
        local info = TryGetScenarioCriteriaInfo(idx)
        if not info then
            nilCount = nilCount + 1
            if nilCount >= 3 then
                break
            end
        else
            nilCount = 0
            if IsBossScenarioCriteria(info) then
                bossCriteriaCount = bossCriteriaCount + 1
                bossCriteria[bossCriteriaCount] = info
                if info.completed == true then
                    killedCount = killedCount + 1
                end
            end
        end
    end

    if bossCriteriaCount <= 0 then
        ExwindTools:UpdateState("DungeonBossKilledCount", 0)
        ExwindTools:UpdateState("DungeonBossProgressIndex", 0)
        return
    end

    local order = GetSpecialDungeonBossProgressOrder(state and state.InstanceID, state and state.MapID, state and state.MapGroup)
    local orderedKilledCount, orderedProgressIndex = ResolveDungeonBossProgressFromOrder(bossCriteria, order)
    if orderedKilledCount and orderedProgressIndex then
        ExwindTools:UpdateState("DungeonBossKilledCount", orderedKilledCount)
        ExwindTools:UpdateState("DungeonBossProgressIndex", orderedProgressIndex)
        return
    end

    ExwindTools:UpdateState("DungeonBossKilledCount", killedCount)
    ExwindTools:UpdateState("DungeonBossProgressIndex", killedCount + 1)
end

local _bossProgressRefreshPending = false
local function ScheduleDungeonBossProgressRefresh(delaySec)
    if _bossProgressRefreshPending then
        return
    end
    _bossProgressRefreshPending = true
    C_Timer.After(tonumber(delaySec) or 1.0, function()
        _bossProgressRefreshPending = false
        RefreshDungeonBossProgressState()
    end)
end

--=======================================================================
--========================== 状态订阅系统 ===============================
--=======================================================================

--- 订阅状态变化
--- @param key string 状态键名
--- @param owner string 模块标识
--- @param func function 回调函数 func(newValue, oldValue)
function ExwindTools:WatchState(key, owner, func)
    if not self.StateCallbacks[key] then
        self.StateCallbacks[key] = {}
    end
    self.StateCallbacks[key][owner] = func
end

--- 取消订阅状态变化
--- @param key string 状态键名
--- @param owner string 模块标识
function ExwindTools:UnwatchState(key, owner)
    if self.StateCallbacks[key] then
        self.StateCallbacks[key][owner] = nil
    end
end

--- 更新状态值（会触发普通回调；差值回调系统已停用）
--- @param key string 状态键名
--- @param newValue any 新值
function ExwindTools:UpdateState(key, newValue)
    local oldValue = self.State[key]

    -- secret value 禁止插件侧比较；只对普通值做相等跳过
    if not IsSecretValue(oldValue) and not IsSecretValue(newValue) and oldValue == newValue then return end

    self.State[key] = newValue

    -- 1. 触发普通回调
    self:TriggerCallbacks(key, newValue, oldValue)

    if self.StateDeltaDisabled then
        return
    end

    -- 2. 检查差值订阅（仅对数值类型）
    if type(newValue) == "number" and type(oldValue) == "number" then
        local delta = newValue - oldValue

        -- [Refactor] 支持自定义差值计算逻辑 (如极速的乘法计算)
        if self.DeltaCalculators and self.DeltaCalculators[key] then
            delta = self.DeltaCalculators[key](newValue, oldValue)
        end

        self:CheckDeltaWatchers(key, delta, newValue, oldValue)
    end
end

-- =======================================================================
-- 自定义差值计算器 (解决乘法叠加属性的增量识别问题)
-- =======================================================================
ExwindTools.DeltaCalculators = {
    ["PStat_Haste"] = function(newVal, oldVal)
        -- 极速在 WoW 中是乘法叠乘的: (1+H_new) = (1+H_old) * (1+Buff)
        -- 增量 Buff = (1+H_new)/(1+H_old) - 1
        if newVal >= oldVal then
            -- Buff 获得
            return ((100 + newVal) / (100 + oldVal) - 1) * 100
        else
            -- Buff 消失
            -- 为了保持消失时的 Delta 绝对值与获得时一致，采用反向比率
            return -(((100 + oldVal) / (100 + newVal) - 1) * 100)
        end
    end
}

--- 触发状态回调
function ExwindTools:TriggerCallbacks(key, newValue, oldValue)
    local callbacks = self.StateCallbacks[key]
    if not callbacks then return end

    for owner, func in pairs(callbacks) do
        local ok, err = pcall(func, newValue, oldValue)
        if not ok then
            local source = string.format("State[%s][%s]", key, tostring(owner))
            if self.LogError then self:LogError(source, err) end
            print(string.format("|cffff0000[ExwindState] 回调错误 [%s][%s]: %s|r",
                key, tostring(owner), tostring(err)))
        end
    end
end

--- 性能压测：单纯测试当前属性采集逻辑的耗时
function ExwindTools:TestStatePerformance()
    print("|cff00ffff[ExwindState]|r 12.0.5 起属性可能为 secret value，已停用属性运算压测")
end

--=======================================================================
--========================== 差值监控系统 ===============================
--=======================================================================
-- 用于通过属性变化量检测 BUFF 触发（12.0 大秘境无法直接监控 BUFF）

ExwindTools.DeltaWatchers = {}     -- { [state] = { [owner] = config } }
ExwindTools.DeltaMinThreshold = {} -- { [state] = 所有订阅中最小的 min 值 }

--- 注册差值监控
--- @param state string 状态键名 (如 "PStat_Crit")
--- @param owner string 模块标识
--- @param config table|number 配置表 { min, max, onTrigger, onFade } 或直接传入最小阈值(数值)
--- @param onTrigger function (仅当 config 为数值时必填) 触发回调
--- @param onFade function (仅当 config 为数值时可选) 消失回调
function ExwindTools:WatchStateDelta(state, owner, config, arg4, arg5, arg6)
    if self.StateDeltaDisabled then
        EXDebug("差值监控已停用: %s [%s]", tostring(state), tostring(owner))
        return false
    end

    -- [Refactor] 深度增强调用模式:
    -- 1. 极简数值模式: (state, owner, 30, callback)
    -- 2. 平铺自定义模式: (state, owner, 30, 0.05, callback) -> 直接传阈值和误差
    -- 3. 表格自定义模式: (state, owner, {30, 0.05}, callback)
    -- 4. 原始标准模式: (state, owner, {min, max, ...})

    local threshold, margin, onTrigger, onFade

    if type(config) == "number" then
        threshold = config
        -- 判定第四个参数是 误差(number) 还是 回调(function)
        if type(arg4) == "number" then
            margin = arg4
            onTrigger = arg5
            onFade = arg6
        else
            margin = 0.1 -- 默认 10%
            onTrigger = arg4
            onFade = arg5
        end
    elseif type(config) == "table" and config[1] and not config.min then
        threshold = config[1]
        margin = config[2] or 0.1
        onTrigger = arg4
        onFade = arg5
    end

    -- 如果命中了简化模式，则构造标准 config 表
    if threshold then
        config = {
            min = threshold * (1 - margin),
            max = threshold * (1 + margin) * 2,
            onTrigger = onTrigger,
            onFade = onFade
        }
    end

    if type(config) ~= "table" or not config.min or not config.max then
        error("ExwindTools:WatchStateDelta: config 必须包含 min 和 max", 2)
    end

    if not self.DeltaWatchers[state] then
        self.DeltaWatchers[state] = {}
    end
    self.DeltaWatchers[state][owner] = config

    -- 更新最小阈值缓存
    self:UpdateDeltaMinThreshold(state)

    EXDebug("差值监控注册: %s [%s] 范围 %.1f-%.1f", state, owner, config.min, config.max)
end

--- 取消差值监控
--- @param state string 状态键名
--- @param owner string 模块标识
function ExwindTools:UnwatchStateDelta(state, owner)
    if self.DeltaWatchers[state] then
        self.DeltaWatchers[state][owner] = nil

        -- 检查是否还有订阅者
        local count = 0
        for _ in pairs(self.DeltaWatchers[state]) do count = count + 1 end

        if count == 0 then
            self.DeltaWatchers[state] = nil
            self.DeltaMinThreshold[state] = nil
        else
            self:UpdateDeltaMinThreshold(state)
        end
    end
end

--- 更新某个 State 的最小阈值缓存
function ExwindTools:UpdateDeltaMinThreshold(state)
    if self.StateDeltaDisabled then
        self.DeltaMinThreshold[state] = nil
        return
    end

    local watchers = self.DeltaWatchers[state]
    if not watchers then
        self.DeltaMinThreshold[state] = nil
        return
    end

    local minVal = math.huge
    for _, config in pairs(watchers) do
        if config.min < minVal then
            minVal = config.min
        end
    end
    self.DeltaMinThreshold[state] = minVal
end

--- 检查差值订阅并触发回调
function ExwindTools:CheckDeltaWatchers(key, delta, newVal, oldVal)
    if self.StateDeltaDisabled then
        return
    end

    local watchers = self.DeltaWatchers[key]
    if not watchers then return end

    local absDelta = math.abs(delta)
    local minThreshold = self.DeltaMinThreshold[key]

    -- ⚡ 第一级过滤：普通算术差值太小，直接跳过
    if minThreshold and absDelta < minThreshold then
        return
    end

    -- ⚡ 第二级处理：如果定义了逻辑计算器（如极速），则统一计算一次逻辑差值
    local logicalDelta = delta
    if self.DeltaCalculators and self.DeltaCalculators[key] then
        logicalDelta = self.DeltaCalculators[key](newVal, oldVal)
        absDelta = math.abs(logicalDelta) -- 重新评估绝对值

        -- 再次利用最小阈值过滤（针对逻辑后的数值）
        if minThreshold and absDelta < minThreshold then
            return
        end
    end

    -- 遍历具体订阅 (此时 logicalDelta 已确定，不再重复计算)
    for owner, config in pairs(watchers) do
        if logicalDelta > 0 and logicalDelta >= config.min and logicalDelta <= config.max then
            -- 正差值触发 (BUFF 获得)
            if config.onTrigger then
                local ok, err = pcall(config.onTrigger, logicalDelta, newVal, oldVal)
                if not ok then
                    print(string.format("|cffff0000[ExwindState] Delta 回调错误 [%s][%s]: %s|r",
                        key, owner, tostring(err)))
                end
            end
        elseif logicalDelta < 0 and (-logicalDelta) >= config.min and (-logicalDelta) <= config.max then
            -- 负差值触发 (BUFF 消失)
            if config.onFade then
                local ok, err = pcall(config.onFade, logicalDelta, newVal, oldVal)
                if not ok then
                    print(string.format("|cffff0000[ExwindState] Delta Fade 回调错误 [%s][%s]: %s|r",
                        key, owner, tostring(err)))
                end
            end
        end
    end
end

--=======================================================================
--========================== 状态采集初始化 =============================
--=======================================================================

local function InitializeStateMonitors()
    local OWNER = "ExwindState"

    local function NormalizeRoleKey(role)
        local r = tostring(role or ""):lower()
        if r == "tank" then return "tank" end
        if r == "heal" or r == "healer" then return "heal" end
        if r == "dps" or r == "damage" or r == "damager" then return "dps" end
        return "unknown"
    end

    local function RoleNameFromKey(roleKey)
        if roleKey == "tank" then return "坦克" end
        if roleKey == "heal" then return "治疗" end
        if roleKey == "dps" then return "输出" end
        return "未知职责"
    end

    local function ResolveRoleFromSpec(specID, specIndex)
        local roleKey = "unknown"

        if _G.EXDB and type(_G.EXDB.GetSpecRoleKey) == "function" then
            roleKey = NormalizeRoleKey(_G.EXDB:GetSpecRoleKey(specID))
        elseif _G.EXDB and type(_G.EXDB.SpecRoleKeyByID) == "table" then
            roleKey = NormalizeRoleKey(_G.EXDB.SpecRoleKeyByID[specID])
        end

        -- 兜底：仍然只按当前专精，不读取组队职责
        if roleKey == "unknown" and type(GetSpecializationRole) == "function" and specIndex and specIndex > 0 then
            roleKey = NormalizeRoleKey(GetSpecializationRole(specIndex))
        end

        return roleKey, RoleNameFromKey(roleKey)
    end

    local function IsMythicPlusContext(inInstance, instanceType, difficultyID)
        if not inInstance or instanceType ~= "party" then
            return false
        end

        local diff = tonumber(difficultyID) or 0
        if diff == 8 then
            return true
        end

        if C_ChallengeMode and type(C_ChallengeMode.GetActiveChallengeMapID) == "function" then
            local mapID = tonumber(C_ChallengeMode.GetActiveChallengeMapID()) or 0
            if mapID > 0 then
                return true
            end
        end

        return false
    end

    local function GetPlayerMapState(unitToken)
        local token = unitToken or "player"
        local mapID = 0
        local mapGroup = 0

        if C_Map and type(C_Map.GetBestMapForUnit) == "function" then
            mapID = tonumber(C_Map.GetBestMapForUnit(token)) or 0
        end

        if mapID > 0 and C_Map and type(C_Map.GetMapGroupID) == "function" then
            local ok, groupID = pcall(C_Map.GetMapGroupID, mapID)
            if ok then
                mapGroup = tonumber(groupID) or 0
            end
        end

        -- 智能兜底：无 MapGroup 时使用 MapID
        if mapGroup <= 0 then
            mapGroup = mapID
        end

        return mapID, mapGroup
    end

    local function GetCurrentZoneText()
        if type(GetMinimapZoneText) ~= "function" then
            return ""
        end
        local ok, text = pcall(GetMinimapZoneText)
        if not ok then
            return ""
        end
        text = tostring(text or "")
        text = text:gsub("^%s+", ""):gsub("%s+$", "")
        text = text:gsub("%s+", " ")
        return text
    end

    local function UpdateSecretState()
        local auraSecretsActive = false

        if _G.C_Secrets and type(_G.C_Secrets.ShouldAurasBeSecret) == "function" then
            local ok, value = pcall(_G.C_Secrets.ShouldAurasBeSecret)
            if ok then
                auraSecretsActive = value and true or false
            end
        end

        ExwindTools:UpdateState("AuraSecretsActive", auraSecretsActive)
    end

    --===================================================================
    -- 1. 基础状态监听 (战斗/副本/天赋)
    --===================================================================

    local function UpdateBaseState(event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
            ExwindTools:UpdateState("InCombat", true)
        elseif event == "PLAYER_REGEN_ENABLED" then
            ExwindTools:UpdateState("InCombat", false)
        elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" or event == "UNIT_AURA" then
            local unit = ...
            if event == "UNIT_AURA" and unit and unit ~= "player" then
                return
            end
            ExwindTools:UpdateState("IsMounted", IsMounted() and true or false)
        elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA"
            or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS"
            or event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_DIFFICULTY_CHANGED"
            or event == "CHALLENGE_MODE_START" or event == "CHALLENGE_MODE_RESET"
            or event == "CHALLENGE_MODE_COMPLETED" then
            local inInstance, instanceType = IsInInstance()
            local _, _, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()
            local mapID, mapGroup = GetPlayerMapState("player")

            local oldIT = ExwindTools.State.InstanceType
            local oldIID = ExwindTools.State.InstanceID
            local oldDI = ExwindTools.State.DifficultyID
            local oldII = ExwindTools.State.InInstance
            local oldMapID = ExwindTools.State.MapID
            local oldMapGroup = ExwindTools.State.MapGroup
            local oldZoneText = ExwindTools.State.ZoneText
            local oldIMP = ExwindTools.State.InMythicPlus
            local oldIP = ExwindTools.State.IsInParty
            local oldIR = ExwindTools.State.IsInRaid

            local inGroup = IsInGroup()
            local inRaid = IsInRaid()
            local inMythicPlus = IsMythicPlusContext(inInstance, instanceType, difficultyID)
            local zoneText = GetCurrentZoneText()

            ExwindTools:UpdateState("InInstance", inInstance)
            ExwindTools:UpdateState("InstanceType", instanceType)
            ExwindTools:UpdateState("InstanceID", instanceID or 0)
            ExwindTools:UpdateState("MapID", mapID)
            ExwindTools:UpdateState("MapGroup", mapGroup)
            ExwindTools:UpdateState("ZoneText", zoneText)
            ExwindTools:UpdateState("DifficultyID", difficultyID)
            ExwindTools:UpdateState("InMythicPlus", inMythicPlus)
            ExwindTools:UpdateState("IsInParty", inGroup)
            ExwindTools:UpdateState("IsInRaid", inRaid)
            UpdateSecretState()
            RefreshMythicPlusForcesState()

            -- 触发变更回调
            if inInstance ~= oldII then ExwindTools:TriggerCallbacks("InInstance", inInstance, oldII) end
            if instanceType ~= oldIT then ExwindTools:TriggerCallbacks("InstanceType", instanceType, oldIT) end
            if (instanceID or 0) ~= (oldIID or 0) then
                ExwindTools:TriggerCallbacks("InstanceID", instanceID or 0,
                    oldIID or 0)
            end
            if mapID ~= oldMapID then ExwindTools:TriggerCallbacks("MapID", mapID, oldMapID) end
            if mapGroup ~= oldMapGroup then ExwindTools:TriggerCallbacks("MapGroup", mapGroup, oldMapGroup) end
            if zoneText ~= oldZoneText then ExwindTools:TriggerCallbacks("ZoneText", zoneText, oldZoneText) end
            if difficultyID ~= oldDI then ExwindTools:TriggerCallbacks("DifficultyID", difficultyID, oldDI) end
            if inMythicPlus ~= oldIMP then ExwindTools:TriggerCallbacks("InMythicPlus", inMythicPlus, oldIMP) end
            if inGroup ~= oldIP then ExwindTools:TriggerCallbacks("IsInParty", inGroup, oldIP) end
            if inRaid ~= oldIR then ExwindTools:TriggerCallbacks("IsInRaid", inRaid, oldIR) end
        end
    end

    ExwindTools:RegisterEvent("PLAYER_REGEN_DISABLED", OWNER, UpdateBaseState)
    ExwindTools:RegisterEvent("PLAYER_REGEN_ENABLED", OWNER, UpdateBaseState)
    ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", OWNER, UpdateBaseState)
    ExwindTools:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED", OWNER, UpdateBaseState)
    ExwindTools:RegisterEvent("UNIT_AURA", OWNER .. "_Mounted", UpdateBaseState)
    ExwindTools:RegisterEvent("ZONE_CHANGED_NEW_AREA", OWNER, UpdateBaseState)
    ExwindTools:RegisterEvent("ZONE_CHANGED", OWNER, UpdateBaseState)
    ExwindTools:RegisterEvent("ZONE_CHANGED_INDOORS", OWNER, UpdateBaseState)
    ExwindTools:RegisterEvent("GROUP_ROSTER_UPDATE", OWNER, UpdateBaseState)
    ExwindTools:RegisterEvent("PLAYER_DIFFICULTY_CHANGED", OWNER, UpdateBaseState)
    ExwindTools:RegisterEvent("CHALLENGE_MODE_START", OWNER, UpdateBaseState)
    ExwindTools:RegisterEvent("CHALLENGE_MODE_RESET", OWNER, UpdateBaseState)
    ExwindTools:RegisterEvent("CHALLENGE_MODE_COMPLETED", OWNER, UpdateBaseState)
    ExwindTools:RegisterEvent("SCENARIO_UPDATE", OWNER, UpdateBaseState)

    --===================================================================
    -- 2. 职业/专精采集 (带重试机制)
    --===================================================================
    local MAX_SPEC_RETRIES = 20
    local isSpecRetrying = false

    local function UpdateSpecInfo(retryCount)
        -- (保持原有逻辑不变)...
        if type(retryCount) ~= "number" then retryCount = 0 end -- 兼容 event 调用

        local _, classEN, classID = UnitClass("player")
        local specIndex = GetSpecialization()
        local specID = (specIndex and specIndex > 0) and GetSpecializationInfo(specIndex) or 0

        local isComplete = (classID and classID > 0) and (specID and specID > 0)

        if not isComplete then
            if retryCount < MAX_SPEC_RETRIES then
                if retryCount == 0 and isSpecRetrying then return end
                isSpecRetrying = true
                C_Timer.After(2, function() UpdateSpecInfo(retryCount + 1) end)
            else
                isSpecRetrying = false
            end
        else
            isSpecRetrying = false
        end

        -- 从 EXDB 获取中文名称
        local specName = "未知"
        local className = "未知"

        if classID and _G.EXDB and _G.EXDB.Classes[classID] then
            className = _G.EXDB.Classes[classID].name
        end
        if specID and specID > 0 and _G.EXDB and _G.EXDB.SpecByID[specID] then
            specName = _G.EXDB.SpecByID[specID].name
        end

        local roleKey, roleName = ResolveRoleFromSpec(specID, specIndex)

        ExwindTools:UpdateState("ClassID", classID or 0)
        ExwindTools:UpdateState("ClassName", className)
        ExwindTools:UpdateState("SpecID", specID or 0)
        ExwindTools:UpdateState("SpecName", specName)
        ExwindTools:UpdateState("RoleKey", roleKey)
        ExwindTools:UpdateState("RoleName", roleName)
        ExwindTools:UpdateState("Level", UnitLevel("player") or 0)
        ExwindTools:UpdateState("PlayerName", UnitName("player") or "")
        ExwindTools:UpdateState("RealmName", GetRealmName() or "")

        if isComplete and retryCount > 0 then
            EXDebug("职业专精信息获取成功: %s (%s)", className, specName)
        end
    end

    ExwindTools:RegisterEvent("PLAYER_TALENT_UPDATE", OWNER, UpdateSpecInfo)
    ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", OWNER .. "_Spec", UpdateSpecInfo)
    ExwindTools:RegisterEvent("PLAYER_LEVEL_UP", OWNER, function(_, newLevel)
        ExwindTools:UpdateState("Level", newLevel or UnitLevel("player") or 0)
    end)

    --===================================================================
    -- 3. 玩家属性采集 (PStat_*)
    --===================================================================
    --后续更新计划 使用并测试更详细的事件绑定更新属性 (比如闪避事件只更新闪避)
    --需要大量测试证实 所以短期内先使用全量刷新

    -- 精细化属性采集逻辑（使用分段更新；玩家 UNIT_AURA 走全量刷新以覆盖属性类 Buff）
    local function UpdateDurabilityStat()
        local totalCurrent = 0
        local totalMax = 0

        -- 仅统计“已装备且有耐久”的部位，输出整体耐久百分比
        for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
            local current, maxValue = GetInventoryItemDurability(slot)
            if current and maxValue and maxValue > 0 then
                totalCurrent = totalCurrent + current
                totalMax = totalMax + maxValue
            end
        end

        local durability = 100
        if totalMax > 0 then
            durability = (totalCurrent / totalMax) * 100
        end

        ExwindTools:UpdateState("PStat_Durability", durability)
    end

    -- 装等在部分版本中会晚于 PLAYER_EQUIPMENT_CHANGED 更新，补一轮延迟重采样
    local function UpdateEquippedItemLevel(event)
        local function Sample()
            local _, ilvl = GetAverageItemLevel()
            if not IsSecretValue(ilvl) and type(ilvl) == "number" and ilvl > 0 then
                ExwindTools:UpdateState("PStat_EquippedItemLevel", ilvl)
            end
        end

        Sample()

        if event == "PLAYER_EQUIPMENT_CHANGED" or event == "PLAYER_ENTERING_WORLD" or event == "TRAIT_CONFIG_UPDATED" then
            local retryDelays = { 0.10, 0.35, 0.80 }
            for _, delay in ipairs(retryDelays) do
                C_Timer.After(delay, Sample)
            end
        end
    end

    local function UpdatePrimaryStats()
        local _, str = UnitStat("player", 1)
        local _, agi = UnitStat("player", 2)
        local _, sta = UnitStat("player", 3)
        local _, int = UnitStat("player", 4)

        ExwindTools:UpdateState("PStat_Str", str)
        ExwindTools:UpdateState("PStat_Agi", agi)
        ExwindTools:UpdateState("PStat_Sta", sta)
        ExwindTools:UpdateState("PStat_Int", int)

        local primaryStat = _G.EXDB and _G.EXDB.GetPlayerPrimaryStat and _G.EXDB:GetPlayerPrimaryStat()
        if primaryStat == "力量" then
            ExwindTools:UpdateState("PStat_Major", str)
        elseif primaryStat == "敏捷" then
            ExwindTools:UpdateState("PStat_Major", agi)
        elseif primaryStat == "智力" then
            ExwindTools:UpdateState("PStat_Major", int)
        end
    end

    local function UpdateVersatilityStats()
        local ratingBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
        local auraBonus = GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)

        ExwindTools:UpdateState("PStat_VersaRatingBonus", ratingBonus)
        ExwindTools:UpdateState("PStat_VersaAuraBonus", auraBonus)

        local ratingSecret = IsSecretValue(ratingBonus)
        local auraSecret = IsSecretValue(auraBonus)

        if ratingSecret or auraSecret then
            ExwindTools:UpdateState("PStat_VersaText", string.format("%.1f%% + %.1f%%", ratingBonus, auraBonus))
        elseif type(ratingBonus) == "number" and type(auraBonus) == "number" then
            ExwindTools:UpdateState("PStat_Versa", ratingBonus + auraBonus)
            ExwindTools:UpdateState("PStat_VersaText", string.format("%.1f%%", ratingBonus + auraBonus))
        end
    end

    local function UpdatePlayerStats(event, unit)
        -- 仅对 UNIT_* 事件做 unit 过滤；其他事件第二参数可能是 slot 等非 unit 值
        if (event == "UNIT_STATS" or event == "UNIT_MAXHEALTH" or event == "UNIT_AURA") and unit and unit ~= "player" then
            return
        end

        if event == "MASTERY_UPDATE" then
            ExwindTools:UpdateState("PStat_Mastery", GetMasteryEffect())
        elseif event == "COMBAT_RATING_UPDATE" then
            UpdateVersatilityStats()
            ExwindTools:UpdateState("PStat_Crit", GetSpellCritChance())
            ExwindTools:UpdateState("PStat_Haste", GetHaste())
        elseif event == "UNIT_STATS" then
            UpdatePrimaryStats()
        elseif event == "UNIT_MAXHEALTH" then
            ExwindTools:UpdateState("PStat_MaxHealth", UnitHealthMax("player"))
        elseif event == "AVOIDANCE_UPDATE" then
            ExwindTools:UpdateState("PStat_Avoidance", GetAvoidance())
        elseif event == "LIFESTEAL_UPDATE" then
            ExwindTools:UpdateState("PStat_Leech", GetLifesteal())
        elseif event == "UPDATE_INVENTORY_DURABILITY" then
            UpdateDurabilityStat()
        else
            -- 全量刷新 (PEW, 装备变更、玩家 UNIT_AURA 等)
            UpdatePrimaryStats()

            ExwindTools:UpdateState("PStat_Crit", GetSpellCritChance())
            ExwindTools:UpdateState("PStat_Haste", GetHaste())
            ExwindTools:UpdateState("PStat_Mastery", GetMasteryEffect())
            UpdateVersatilityStats()
            ExwindTools:UpdateState("PStat_Leech", GetLifesteal())
            ExwindTools:UpdateState("PStat_Avoidance", GetAvoidance())
            ExwindTools:UpdateState("PStat_Speed", GetSpeed())

            local _, armor = UnitArmor("player")
            ExwindTools:UpdateState("PStat_Armor", armor)
            ExwindTools:UpdateState("PStat_Dodge", GetDodgeChance())
            ExwindTools:UpdateState("PStat_Parry", GetParryChance())
            ExwindTools:UpdateState("PStat_Block", GetBlockChance())

            UpdateEquippedItemLevel(event)
            ExwindTools:UpdateState("PStat_MaxHealth", UnitHealthMax("player"))
            UpdateDurabilityStat()
        end
    end

    -- 移速计时器 (每秒更新一次，脱离事件以降低开销)
    C_Timer.NewTicker(1, function()
        local _, runSpeed = GetUnitSpeed("player")
        ExwindTools:UpdateState("PStat_Movement", runSpeed)
        if IsSecretValue(runSpeed) then
            ExwindTools:UpdateState("PStat_MovementText", string.format("%.1f", runSpeed))
        elseif type(runSpeed) == "number" then
            ExwindTools:UpdateState("PStat_MovementText", string.format("%.0f%%", (runSpeed / 7) * 100))
        end
    end)

    local statEvents = {
        "COMBAT_RATING_UPDATE", "AVOIDANCE_UPDATE", "LIFESTEAL_UPDATE", "MASTERY_UPDATE",
        "PLAYER_ENTERING_WORLD", "PLAYER_EQUIPMENT_CHANGED", "UNIT_STATS", "UNIT_MAXHEALTH", "UNIT_AURA",
        "UPDATE_INVENTORY_DURABILITY", "TRAIT_CONFIG_UPDATED", "PLAYER_AVG_ITEM_LEVEL_UPDATE"
    }
    for _, e in ipairs(statEvents) do
        ExwindTools:RegisterEvent(e, OWNER, UpdatePlayerStats)
    end

    --===================================================================
    -- 3.5 玩家打断技能状态监控
    --===================================================================
    ExwindTools:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", OWNER .. "_Interrupt", function(event, unit, castID, spellID)
        if unit ~= "player" then return end

        -- 获取当前专精
        local specIndex = GetSpecialization()
        local specID = (specIndex and specIndex > 0) and GetSpecializationInfo(specIndex) or 0

        if _G.EXDB and _G.EXDB.InterruptData and _G.EXDB.InterruptData[specID] then
            local interruptID = _G.EXDB.InterruptData[specID].id
            local cdDuration = _G.EXDB.InterruptData[specID].cd
            if interruptID > 0 and spellID == interruptID then
                if cdDuration and cdDuration > 0 then
                    -- 完美避开 12.0 API 对 duration/startTime 保护引发的 Secret Number 比较错误
                    -- 强制直接采用玩家数据库事先整理好的固定 CD 参数计算
                    ExwindTools:UpdateState("InterruptStartTime", GetTime())
                    ExwindTools:UpdateState("InterruptDuration", cdDuration)
                    ExwindTools:UpdateState("InterruptReady", false)

                    C_Timer.After(cdDuration, function()
                        ExwindTools:UpdateState("InterruptReady", true)
                    end)
                end
            end
        end
    end)

    --===================================================================
    -- 4. 首领战监控 (Encounter Tracking)
    --===================================================================
    ExwindTools:RegisterEvent("ENCOUNTER_START", OWNER, function(event, encounterID)
        local id = encounterID or 0
        SetEncounterState(true, id)
        RefreshMythicPlusForcesState()
        ScheduleDungeonBossProgressRefresh(1.0)
        EXDebug("进入首领战: %d", id)
    end)

    ExwindTools:RegisterEvent("ENCOUNTER_END", OWNER, function(event)
        SetEncounterState(false, 0)
        RefreshMythicPlusForcesState()
        ScheduleDungeonBossProgressRefresh(1.0)
        EXDebug("离开首领战")
    end)

    ExwindTools:RegisterEvent("BOSS_KILL", OWNER .. "_BossProgress", function()
        RefreshMythicPlusForcesState()
        ScheduleDungeonBossProgressRefresh(1.0)
    end)

    ExwindTools:RegisterEvent("SCENARIO_UPDATE", OWNER .. "_ScenarioProgress", function()
        RefreshMythicPlusForcesState()
        ScheduleDungeonBossProgressRefresh(1.0)
    end)

    ExwindTools:RegisterEvent("CRITERIA_UPDATE", OWNER .. "_CriteriaProgress", function()
        RefreshMythicPlusForcesState()
        ScheduleDungeonBossProgressRefresh(1.0)
    end)

    ExwindTools:RegisterEvent("SCENARIO_CRITERIA_UPDATE", OWNER .. "_ScenarioCriteriaProgress", function()
        RefreshMythicPlusForcesState()
        ScheduleDungeonBossProgressRefresh(1.0)
    end)

    --===================================================================
    -- 5. 初始同步
    --===================================================================
    ExwindTools:UpdateState("InCombat", InCombatLockdown())

    local inInstance, instanceType = IsInInstance()
    local _, _, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()
    local mapID, mapGroup = GetPlayerMapState("player")
    local inMythicPlus = IsMythicPlusContext(inInstance, instanceType, difficultyID)
    ExwindTools:UpdateState("InInstance", inInstance)
    ExwindTools:UpdateState("InstanceType", instanceType)
    ExwindTools:UpdateState("InstanceID", instanceID or 0)
    ExwindTools:UpdateState("MapID", mapID)
    ExwindTools:UpdateState("MapGroup", mapGroup)
    ExwindTools:UpdateState("ZoneText", GetCurrentZoneText())
    ExwindTools:UpdateState("DifficultyID", difficultyID)
    ExwindTools:UpdateState("InMythicPlus", inMythicPlus)
    ExwindTools:UpdateState("IsMounted", IsMounted() and true or false)
    ExwindTools:UpdateState("IsInParty", IsInGroup())
    ExwindTools:UpdateState("IsInRaid", IsInRaid())
    if _G.C_Secrets and type(_G.C_Secrets.ShouldAurasBeSecret) == "function" then
        local ok, value = pcall(_G.C_Secrets.ShouldAurasBeSecret)
        ExwindTools:UpdateState("AuraSecretsActive", ok and value and true or false)
    else
    ExwindTools:UpdateState("AuraSecretsActive", false)
    end
    RefreshMythicPlusForcesState()

    -- 重载恢复首领战状态：如果战斗中 /reload，恢复上一段 EncounterID
    do
        local inProgress = (type(IsEncounterInProgress) == "function") and IsEncounterInProgress() or false
        local currentInstanceID = tonumber((select(8, GetInstanceInfo()))) or 0
        local cached = EX_STATE_DB.encounter or {}
        local cachedID = tonumber(cached.id) or 0
        local cachedInstanceID = tonumber(cached.instanceID) or 0
        local liveEncounterID = QueryCurrentEncounterID()

        if inProgress and liveEncounterID > 0 then
            SetEncounterState(true, liveEncounterID)
            EXDebug("实时恢复首领战状态: encounterID=%d", liveEncounterID)
        elseif inProgress and cachedID > 0 and (cachedInstanceID == 0 or currentInstanceID == 0 or cachedInstanceID == currentInstanceID) then
            SetEncounterState(true, cachedID)
            EXDebug("重载恢复首领战状态: encounterID=%d", cachedID)
        elseif inProgress then
            -- 能确定在首领战中，但缺少可靠 encounterID
            SetEncounterState(true, 0)
            EXDebug("首领战进行中，但未能恢复 EncounterID")
        else
            SetEncounterState(false, 0)
        end
    end

    -- 强制触发一次全量更新
    UpdateSpecInfo()
    UpdatePlayerStats()
    RefreshMythicPlusForcesState()
    RefreshDungeonBossProgressState()

    -- 额外延迟检查，防止登录瞬间数据未就绪
    C_Timer.After(2, function()
        UpdateSpecInfo()
        UpdatePlayerStats()
        RefreshMythicPlusForcesState()
        RefreshDungeonBossProgressState()
        EXDebug("二次状态同步完成")
    end)

    EXDebug("ExwindState 初始化完成")
end

-- 延迟初始化（确保 ExwindTools 核心已完全加载）
C_Timer.After(0.5, InitializeStateMonitors)
