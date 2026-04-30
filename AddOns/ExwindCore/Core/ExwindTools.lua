local addonName, addonTable = ...
local ExwindTools = addonTable
_G.ExwindTools = ExwindTools

-- 把 Locale 代理接入 addonTable（ExwindLocale 由 Locale/Init.lua 提前初始化）
ExwindTools.L = _G.ExwindLocale and _G.ExwindLocale.GetProxy() or
    setmetatable({}, { __index = function(_, k) return k end })

local L = ExwindTools.L

--=======================================================================
--========================== 基础属性 ===================================
--=======================================================================
ExwindTools.name = addonName
-- [Core] 版本信息 (从 ExwindTools_Metadata.lua 读取)
local meta = _G.ExwindTools_MetaData or { version = "DEV-Build", gridEngineVersion = "DEV" }
ExwindTools.VERSION = meta.version
ExwindTools.GridEngineVersion = meta.gridEngineVersion

--=======================================================================
--========================== 全局字体准则 ===============================
--=======================================================================
-- [Core] 建立最高优先级的原生字体指针
local nativePath, nativeSize, nativeFlags = _G.GameFontHighlight:GetFont()
ExwindTools.MAIN_FONT = nativePath or STANDARD_TEXT_FONT

-- 针对非中文客户端的解决方案
-- 如果在非中文客户端发现中文字体（AR系列），强行将其设为 MAIN_FONT 以支持 HUD 的 SetFont 渲染。
local currentLocale = GetLocale()
if currentLocale ~= "zhCN" and currentLocale ~= "zhTW" then
    local LSM = LibStub("LibSharedMedia-3.0", true)
    if LSM then
        local cjkFonts = { "AR ZhongkaiGBK Medium", "AR CrystalzcuheiGBK Demibold" }
        for _, name in ipairs(cjkFonts) do
            local path = LSM:Fetch("font", name)
            if path and path ~= "" then
                ExwindTools.MAIN_FONT = path
                break
            end
        end
    end
end

ExwindTools.MAIN_FONT_SIZE = 16
ExwindTools.MAIN_FONT_OUTLINE = "OUTLINE"

--=======================================================================
--========================== 环境判断 ===================================
--=======================================================================
local version, build, date, tocversion = GetBuildInfo()
local isPTR = IsPublicTestClient and IsPublicTestClient()
local isBeta = IsBetaBuild and IsBetaBuild()
local realmID = GetRealmID and GetRealmID() or 0
local isBetaRealm = (realmID == 4608)

-- 只要是测试服环境（PTR / Beta / 指定测试服务器），都认为是 Beta 环境
ExwindTools.IsBeta = isBeta or isPTR or isBetaRealm


--=======================================================================
--========================== 分类定义 ===================================
--=======================================================================
ExwindTools.Cate = {
    [1] = L["工具类"],
    [2] = L["大秘境 (资讯)"],
    [3] = L["大秘境 (战斗)"],
    [4] = L["职业 (通用)"],
    [5] = "PTR/BETA",
}
--如果非beta服务器 抽掉分类4
if not ExwindTools.IsBeta then
    ExwindTools.Cate[5] = nil
end

--=======================================================================
--========================== 模块清单 ===================================
--=======================================================================
-- ⚠️ 警告：此 ModuleList 被多个插件共享
--  严禁删除任何模块条目！只能追加新模块
ExwindTools.ModuleList = {
    ----------------------------------------------------------------------------------------------------------
    ---------------------------------------------工具类 (1)---------------------------------------------------
    ----------------------------------------------------------------------------------------------------------
    { Key = "ExTools.MiniTools", Name = L["常用功能设置"], Desc = L["常用功能合集 (自动卖垃圾/日志/删除确认等)。"], Category = 1 },
    { Key = "ExTools.StreamerTools", Name = L["大秘境小工具"], Desc = L["大秘境常用的小工具整里"], Category = 1 },
    { Key = "ExTools.PlayerPosition", Name = L["玩家角色定位标记"], Desc = L["在屏幕中心显示标记，支持超出距离变色"], Category = 1 },
    { Key = "ExTools.ChatChannelBar", Name = L["聊天频道快捷栏"], Desc = L["快速切换聊天频道的工具栏"], Category = 1 },
    { Key = "ExTools.AutoBuy", Name = L["自动购买"], Desc = L["自动购买指定物品。"], Category = 1 },
    { Key = "ExTools.GossipID", Name = L["对话ID显示"], Desc = L["显示对话 ID，并支持加入自动对话列表。"], Category = 1, new = true },
    { Key = "ExTools.InstanceNote", Name = L["副本笔记备注"], Desc = L["按副本 / 首领显示自定义备注。"], Category = 1, DefaultEnabled = false },
    --{ Key = "ExTools.MicroMenu", Name = "微型选单", Desc = "顶端微型选单：中间显示时间，左右各有可配置的面板快捷图标。", Category = 1 },
    --{ Key = "ExTools.RaidMarkerPanel", Name = "团队标记面板", Desc = "目标标记 + 地面光柱的快捷操作面板。", Category = 1 },
    ----------------------------------------------------------------------------------------------------------
    ---------------------------------------------大秘境资讯 (2)------------------------------------------------
    ----------------------------------------------------------------------------------------------------------
    { Key = "ExM+Info.MDTIconHook", Name = L["MDT 法术图标替换"], Desc = L["将 MDT 地图中怪物头像替换为法术图标。"], Category = 2 },
    { Key = "ExM+Info.MythicIcon", Name = L["大米分数/点击传送"], Desc = L["大秘境图标/分数/点击传送等增强。"], Category = 2 },
    { Key = "ExM+Info.TeleMsg", Name = L["大米传送喊话"], Desc = L["大秘境传送相关聊天喊话/提示。"], Category = 2 },
    { Key = "ExM+Info.SpellInfo", Name = L["大米法术信息查询"], Desc = L["法术信息查询与提示增强。"], Category = 2, HideCfg = true },
    { Key = "ExM+Info.Tooltip", Name = L["大米最佳记录(鼠标提示)"], Desc = L["大秘境相关 Tooltip/交互增强。"], Category = 2, HideCfg = true },
    { Key = "ExM+Info.RunHistory", Name = L["大米赛季记录"], Desc = L["记录/展示大秘境赛季历史数据。"], Category = 2 },
    { Key = "ExM+InfoMythicFrame", Name = L["大秘境统计面板"], Desc = L["大秘境统计面板与展示。"], Category = 2, HideCfg = true },
    { Key = "ExM+InfoSpellData", Name = L["法术数据 (内部)"], Desc = L["内部数据/法术资料库。"], Category = 2, HideCfg = true },
    { Key = "ExM+.MythicDamage", Name = L["大秘境伤害计算"], Desc = L["独立UI，根据层数计算法术实际伤害。"], Category = 2 },
    { Key = "ExTools.PveInfoPanel", Name = L["PVE 扩展面板"], Desc = L["在副本查找器 (PVEFrame) 侧边显示额外信息挂架。"], Category = 2 },
    { Key = "ExTools.PveKeystoneInfo", Name = L["大米队友钥石"], Desc = L["在 PVEFrame 上显示玩家与队友钥石信息。"], Category = 2, new = true },

    ----------------------------------------------------------------------------------------------------------
    ---------------------------------------------大秘境辅助 (3)------------------------------------------------
    ----------------------------------------------------------------------------------------------------------
    { Key = "ExM+.InterruptTracker", Name = L["队友打断监控"], Desc = L["推断并监控队友打断技能 (支持12.0)。"], Category = 3 },
    { Key = "ExM+.MythicCast", Name = L["周围怪物施法监控"], Desc = L["显示周围的怪物施法条 支持可断/钢条分别染色"], Category = 3 },
    ----------------------------------------------------------------------------------------------------------
    ---------------------------------------------职业 (通用) (34)----------------------------------------------
    ----------------------------------------------------------------------------------------------------------
    { Key = "ExTools.SpellQueue", Name = L["全职业延迟容限"], Desc = L["根据当前专精自动调整输入延迟容限。"], Category = 4 },
    { Key = "ExClass.SpellEffectAlpha", Name = L["法术触发透明度"], Desc = L["根据当前专精自动调整法术触发透明度。"], Category = 4 },
    { Key = "ExTools.PlayerStats", Name = L["玩家属性监控"], Desc = L["采集并显示玩家各项战斗属性数据。"], Category = 4 },
    { Key = "ExTools.YYSound", Name = L["嗜血音效"], Desc = L["队友开启嗜血时播放音效 功能测试中"], Category = 4 },
    { Key = "ExTools.TransformTimer", Name = L["噬灭变身计时"], Desc = L["玩家施放指定变身法术后，在屏幕显示持续秒数。"], Category = 4 },
    { Key = "ExTools.CastSequence", Name = L["施法序列"], Desc = L["实时显示你的施法序列，支持读条/引导/瞬发/打断等状态可视化。"], Category = 4 },
    { Key = "ExClass.RangeCheck", Name = L["距离监视"], Desc = L["实时显示目标距离范围。"], Category = 4 },
    { Key = "ExClass.NoMoveSkillAlert", Name = L["位移技能CD提示"], Desc = L["当位移技能冷却中时提示。"], Category = 4 },
    { Key = "ExClass.FocusCast", Name = L["焦点施法提示"], Desc = L["仅监控焦点施法，支持施法条与音效独立提示。"], Category = 4 },
    { Key = "ExClass.BrewmasterStagger", Name = L["酒仙酒池监控"], Desc = L["显示酒仙武僧的酒池百分比，并支持独立满条上限与阈值变色。"], Category = 4 },
    ----------------------------------------------------------------------------------------------------------
    ---------------------------------------------PTR/BETA (5)-------------------------------------------------
    ----------------------------------------------------------------------------------------------------------
    { Key = "ExPTR.MiniTools", Name = L["PTR工具箱"], Desc = L["汇集测试服专用的便捷功能（屏蔽反馈、一键加点等）。"], Category = 5, BlockBeta = true },
    { Key = "ExPTR.SetKey", Name = L["快速设置钥石 (PTR)"], Desc = L["PTR 用：快速制作/设置钥石。"], Category = 5, BlockBeta = true, },
}

--如果非beta服务器 抽掉BlockBeta

if not ExwindTools.IsBeta then
    local i = 1
    while i <= #ExwindTools.ModuleList do
        if ExwindTools.ModuleList[i].BlockBeta then
            table.remove(ExwindTools.ModuleList, i)
        else
            i = i + 1
        end
    end
end

-- Key -> Index 映射
ExwindTools.ModuleIndexByKey = {}
for i, meta in ipairs(ExwindTools.ModuleList) do
    ExwindTools.ModuleIndexByKey[meta.Key] = i
end

--=======================================================================
--========================== 数据库初始化 ===============================
--=======================================================================
_G.ExwindToolsDB = _G.ExwindToolsDB or {}
local db = _G.ExwindToolsDB

db.DBVersion = db.DBVersion or 1
db.ModuleDB = db.ModuleDB or {}
db.LoadByKey = db.LoadByKey or {}
db.Load = {}
db.LoadKeys = {}
db.Minimap = db.Minimap or { hide = false }
db.Locale = db.Locale or { mode = "AUTO" }

local function NormalizeLocaleMode(mode)
    local value = tostring(mode or ""):gsub("%s+", "")
    if value == "zhCN" or value == "enUS" then
        return value
    end
    return "AUTO"
end

db.Locale.mode = NormalizeLocaleMode(db.Locale.mode)

-- 同步模块配置
local validKeys = {}
for i, meta in ipairs(ExwindTools.ModuleList) do
    local key = meta.Key
    validKeys[key] = true
    db.LoadKeys[i] = key
    if db.LoadByKey[key] == nil then db.LoadByKey[key] = (meta.DefaultEnabled ~= false) end
    db.Load[i] = db.LoadByKey[key]
end
for k in pairs(db.LoadByKey) do
    if not validKeys[k] then db.LoadByKey[k] = nil end
end

ExwindTools.DB = db

function ExwindTools:GetLocaleMode()
    db.Locale = db.Locale or { mode = "AUTO" }
    db.Locale.mode = NormalizeLocaleMode(db.Locale.mode)
    return db.Locale.mode
end

function ExwindTools:GetEffectiveLocale(mode)
    local localeAPI = _G.ExwindLocale
    local localeMode = NormalizeLocaleMode(mode or self:GetLocaleMode())
    if localeAPI and localeAPI.ResolveLocale then
        return localeAPI.ResolveLocale(localeMode)
    end
    if localeMode == "AUTO" then
        return GetLocale()
    end
    return localeMode
end

function ExwindTools:SetLocaleMode(mode)
    db.Locale = db.Locale or { mode = "AUTO" }
    db.Locale.mode = NormalizeLocaleMode(mode)

    local localeAPI = _G.ExwindLocale
    if localeAPI and localeAPI.SetLocaleMode then
        localeAPI.SetLocaleMode(db.Locale.mode)
    elseif localeAPI and localeAPI.SetCurrentLocale then
        localeAPI.SetCurrentLocale(self:GetEffectiveLocale(db.Locale.mode))
    end

    return db.Locale.mode
end

local function ApplyCoreCVars()
    local ok = pcall(function()
        if _G.C_CVar and _G.C_CVar.SetCVar then
            _G.C_CVar.SetCVar("Sound_NumChannels", "128")
        elseif _G.SetCVar then
            _G.SetCVar("Sound_NumChannels", "128")
        end
    end)
    return ok
end

ApplyCoreCVars()

local function SyncModuleRegistry()
    wipe(ExwindTools.ModuleIndexByKey)
    wipe(db.Load)
    wipe(db.LoadKeys)

    local validKeys = {}
    for i, meta in ipairs(ExwindTools.ModuleList) do
        local key = meta.Key
        validKeys[key] = true
        ExwindTools.ModuleIndexByKey[key] = i
        db.LoadKeys[i] = key
        if db.LoadByKey[key] == nil then
            db.LoadByKey[key] = (meta.DefaultEnabled ~= false)
        end
        db.Load[i] = db.LoadByKey[key]
    end

    for k in pairs(db.LoadByKey) do
        if not validKeys[k] then
            db.LoadByKey[k] = nil
        end
    end
end

function ExwindTools:RegisterExternalModule(meta)
    if type(meta) ~= "table" or type(meta.Key) ~= "string" or meta.Key == "" then
        return false
    end

    if meta.BlockBeta and not self.IsBeta then
        return false
    end

    local idx = self.ModuleIndexByKey[meta.Key]
    if idx then
        local cur = self.ModuleList[idx]
        for k, v in pairs(meta) do
            cur[k] = v
        end
    else
        self.ModuleList[#self.ModuleList + 1] = meta
    end

    SyncModuleRegistry()

    if self.UI and self.UI.MainFrame and self.UI.MainFrame:IsShown() then
        if self.UI.SidebarFrame and self.UI.BuildNavigationTree then
            self.UI:BuildNavigationTree(self.UI.SidebarFrame)
        end
        if self.UI.RefreshContent then
            self.UI:RefreshContent()
        end
    end

    return true
end

--=======================================================================
--========================== DEBUG 模式 =================================
--=======================================================================
ExwindTools.DebugMode = false

function EXDebug(fmt, ...)
    if not ExwindTools.DebugMode then return end
    local msg = select("#", ...) > 0 and string.format(fmt, ...) or fmt
    print(string.format("|cffff9900[EX-DEBUG]|r %s", msg))
end

_G.EXDebug = EXDebug

--=======================================================================
--========================== 模块状态报告 ===============================
--=======================================================================
ExwindTools.ModuleStatus = {}
ExwindTools.RegisteredLayouts = {}

function ExwindTools:ReportReady(moduleKey)
    self.ModuleStatus[moduleKey] = "ready"
end

--=======================================================================
--========================== 错误日志收集 ===============================
--=======================================================================
ExwindTools.ErrorLog = {}
local MAX_ERROR_LOG = 20

function ExwindTools:LogError(source, message)
    local entry = { time = _G.date("%H:%M:%S"), source = source, message = tostring(message) }
    table.insert(self.ErrorLog, 1, entry)
    while #self.ErrorLog > MAX_ERROR_LOG do table.remove(self.ErrorLog) end
end

--=======================================================================
--========================== 依赖库检测 =================================
--=======================================================================
ExwindTools.LibStatus = {}

local function CheckLibs()
    local libs = {
        { name = "LibStub",  check = function() return _G.LibStub ~= nil end },
        {
            name = "CallbackHandler-1.0",
            check = function()
                return LibStub and LibStub:GetLibrary("CallbackHandler-1.0", true) ~= nil
            end
        },
        {
            name = "LibSharedMedia-3.0",
            check = function()
                return LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true) ~= nil
            end
        },
        { name = "LibAsync", check = function() return LibStub and LibStub:GetLibrary("LibAsync", true) ~= nil end },
        {
            name = "LibCustomGlow-1.0",
            check = function()
                return LibStub and
                    LibStub:GetLibrary("LibCustomGlow-1.0", true) ~= nil
            end
        },
        {
            name = "LibDBIcon-1.0",
            check = function()
                return LibStub and
                    LibStub:GetLibrary("LibDBIcon-1.0", true) ~= nil
            end
        },
        {
            name = "LibDataBroker-1.1",
            check = function()
                return LibStub and
                    LibStub:GetLibrary("LibDataBroker-1.1", true) ~= nil
            end
        },
        { name = "LibDeflate", check = function() return LibStub and LibStub:GetLibrary("LibDeflate", true) ~= nil end },
        {
            name = "LibSerialize",
            check = function()
                return LibStub and
                    LibStub:GetLibrary("LibSerialize", true) ~= nil
            end
        },
    }
    for _, lib in ipairs(libs) do
        local ok, result = pcall(lib.check)
        ExwindTools.LibStatus[lib.name] = (ok and result) and true or false
    end
end
CheckLibs()
C_Timer.After(3, CheckLibs)

--=======================================================================
--========================== 环境信息采集 ===============================
--=======================================================================
function ExwindTools:GetEnvironmentInfo()
    local version, build, buildDate = GetBuildInfo()
    local isPTR = (IsPublicTestClient and IsPublicTestClient()) and "是" or "否"
    local isBeta = (IsBetaBuild and IsBetaBuild()) and "是" or "否"
    local realmID = GetRealmID and GetRealmID() or 0
    local isBetaRealm = (realmID == 4608) and "是" or "否"
    local isBetaEnv = self.IsBeta and "是" or "否"
    local platform = IsWindowsClient() and "Windows" or (IsMacClient() and "Mac" or "Unknown")
    local arch = Is64BitClient() and "64-bit" or "32-bit"
    local gameLocale = GetLocale()
    local regionID = GetCurrentRegion()
    local regionMap = { [1] = "US", [2] = "KR", [3] = "EU", [4] = "TW", [5] = "CN", [90] = "BETA" }

    return {
        addonVersion = self.VERSION,
        dbVersion = db.DBVersion,
        gameVersion = version,
        gameBuild = build,
        buildDate = buildDate,
        isPTR = isPTR,
        isBeta = isBeta,
        realmID = realmID,
        isBetaRealm = isBetaRealm,
        isBetaEnv = isBetaEnv,
        isElvUI = C_AddOns.IsAddOnLoaded("ElvUI") and "是" or "否",
        platform = platform,
        arch = arch,
        locale = gameLocale,
        region = regionMap[regionID] or tostring(regionID),
        serverTime = (function()
            if C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime then
                local t = C_DateAndTime.GetCurrentCalendarTime()
                if t then
                    return string.format("%04d-%02d-%02d %02d:%02d", t.year, t.month, t.monthDay, t.hour, t.minute)
                end
            end
            return "N/A"
        end)(),
    }
end

function ExwindTools:GenerateDiagnosticText()
    local env = self:GetEnvironmentInfo()
    local lines = {
        "=== ExwindTools 诊断信息 ===",
        string.format("插件版本: %s | WTF版本: %d", env.addonVersion, env.dbVersion),
        string.format("游戏版本: %s (Build: %s)", env.gameVersion, env.gameBuild),
        string.format("系统: %s (%s) | 区域: %s | 语言: %s | ElvUI: %s", env.platform, env.arch, env.region, env.locale,
            env.isElvUI),
        string.format("环境: PTR=%s | BetaBuild=%s | RealmID=%s | BetaRealm=%s | 最终IsBeta=%s", env.isPTR, env.isBeta,
            tostring(env.realmID), env.isBetaRealm, env.isBetaEnv),
        "",
        "=== 当前状态 ===",
        string.format("职业: %s | 专精: %s", self.State and self.State.ClassName or "N/A",
            self.State and self.State.SpecName or "N/A"),
        string.format("副本: %s | 战斗: %s", self.State and self.State.InInstance and "是" or "否",
            self.State and self.State.InCombat and "是" or "否"),
        "",
        "=== 依赖库 ===",
    }
    for name, loaded in pairs(self.LibStatus) do
        table.insert(lines, string.format("%s: %s", name, loaded and "OK" or "MISSING"))
    end
    return table.concat(lines, "\n")
end

--=======================================================================
--========================== 模块管理 ===================================
--=======================================================================
local function MergeDefaults(dst, src)
    if type(dst) ~= "table" or type(src) ~= "table" then return end
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = dst[k] or {}
            MergeDefaults(dst[k], v)
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

function ExwindTools:IsModuleEnabled(moduleKey)
    -- 1. 检查配置是否启用
    if db.LoadByKey[moduleKey] ~= true then
        return false
    end

    -- 2. 检查静态定义的屏蔽规则 (BlockBeta)
    local idx = self.ModuleIndexByKey[moduleKey]
    if idx then
        local meta = self.ModuleList[idx]
        if meta and meta.BlockBeta and not self.IsBeta then
            return false -- 如果标记了 BlockBeta 且当前不是 Beta 环境，则视为禁用
        end
    end

    return true
end

function ExwindTools:GetModuleDB(moduleKey, defaults)
    if type(moduleKey) ~= "string" or moduleKey == "" then
        error("GetModuleDB: moduleKey must be non-empty string", 2)
    end
    db.ModuleDB[moduleKey] = db.ModuleDB[moduleKey] or {}
    if type(defaults) == "table" then
        MergeDefaults(db.ModuleDB[moduleKey], defaults)
    end
    return db.ModuleDB[moduleKey]
end

function ExwindTools:RegisterModuleOptions() end -- 兼容层

function ExwindTools:RegisterModuleLayout(moduleKey, layoutData)
    if type(moduleKey) == "string" and type(layoutData) == "table" then
        self.RegisteredLayouts[moduleKey] = layoutData
    end
end

-- =========================================================
-- ========================== HUD 框架注册与编辑模式 ============================
-- =========================================================
ExwindTools.HUDs = {}

--- 注册一个模块的 HUD 框架
--- 注册后将获得：右键跳转设置、统一控制等能力
--- @param moduleKey string 模块 Key
--- @param frame table 对应的 Frame 对象
function ExwindTools:RegisterHUD(moduleKey, frame)
    if not frame then return end

    -- 1. 基础配置确保点击
    frame:EnableMouse(true)

    -- 2. 注入右键跳转逻辑 (使用 Hook 避免覆盖模块原有脚本)
    frame:HookScript("OnMouseDown", function(_, button)
        if button == "RightButton" and self.GlobalEditMode then
            self:OpenConfig(moduleKey)
        end
    end)

    -- 3. 记录到注册表
    table.insert(self.HUDs, { key = moduleKey, frame = frame })

    -- 4. 自动关联全局编辑模式变化
    self:RegisterEditModeCallback(moduleKey .. "_HUD_" .. (frame:GetName() or tostring(frame)), function(enabled)
        if enabled then
            frame:EnableMouse(true)
        end
    end)
end

local function OwnerBelongsToModule(owner, moduleKey)
    if owner == moduleKey then
        return true
    end
    if type(owner) ~= "string" or type(moduleKey) ~= "string" then
        return false
    end

    return string.sub(owner, 1, #moduleKey + 1) == (moduleKey .. ".")
        or string.sub(owner, 1, #moduleKey + 1) == (moduleKey .. "_")
end

function ExwindTools:DisableModuleRuntime(moduleKey)
    if type(moduleKey) ~= "string" or moduleKey == "" then
        return false
    end

    for eventName, handlers in pairs(self.EventHandlers or {}) do
        local ownersToRemove = {}
        for owner in pairs(handlers) do
            if OwnerBelongsToModule(owner, moduleKey) then
                ownersToRemove[#ownersToRemove + 1] = owner
            end
        end
        for _, owner in ipairs(ownersToRemove) do
            self:UnregisterEvent(eventName, owner)
        end
    end

    for stateKey, callbacks in pairs(self.StateCallbacks or {}) do
        local ownersToRemove = {}
        for owner in pairs(callbacks) do
            if OwnerBelongsToModule(owner, moduleKey) then
                ownersToRemove[#ownersToRemove + 1] = owner
            end
        end
        for _, owner in ipairs(ownersToRemove) do
            self:UnwatchState(stateKey, owner)
        end
    end

    for stateKey, watchers in pairs(self.DeltaWatchers or {}) do
        local ownersToRemove = {}
        for owner in pairs(watchers) do
            if OwnerBelongsToModule(owner, moduleKey) then
                ownersToRemove[#ownersToRemove + 1] = owner
            end
        end
        for _, owner in ipairs(ownersToRemove) do
            self:UnwatchStateDelta(stateKey, owner)
        end
    end

    for eventName, moduleWatchers in pairs(self.WatchEvenRegistry or {}) do
        local modulesToRemove = {}
        for owner in pairs(moduleWatchers) do
            if OwnerBelongsToModule(owner, moduleKey) then
                modulesToRemove[#modulesToRemove + 1] = owner
            end
        end
        for _, owner in ipairs(modulesToRemove) do
            self.UnwatchEven(eventName, owner)
        end
    end

    local editCallbacksToRemove = {}
    for owner in pairs(self.EditModeCallbacks or {}) do
        if OwnerBelongsToModule(owner, moduleKey) then
            editCallbacksToRemove[#editCallbacksToRemove + 1] = owner
        end
    end
    for _, owner in ipairs(editCallbacksToRemove) do
        self:UnregisterEditModeCallback(owner)
    end

    for i = #self.HUDs, 1, -1 do
        local entry = self.HUDs[i]
        if entry and entry.key == moduleKey then
            local frame = entry.frame
            if frame then
                pcall(frame.StopMovingOrSizing, frame)
                pcall(frame.SetScript, frame, "OnUpdate", nil)
                pcall(frame.EnableMouse, frame, false)
                pcall(frame.Hide, frame)
            end
            table.remove(self.HUDs, i)
        end
    end

    self.ModuleStatus[moduleKey] = "disabled"
    return true
end

function ExwindTools:SetModuleEnabled(moduleKey, enabled)
    if type(moduleKey) ~= "string" or moduleKey == "" then
        return false
    end

    enabled = enabled and true or false

    if not self.DB or not self.DB.LoadByKey then
        return false
    end

    local currentEnabled = self.DB.LoadByKey[moduleKey] == true
    if currentEnabled == enabled then
        return false
    end

    self.DB.LoadByKey[moduleKey] = enabled

    local idx = self.ModuleIndexByKey[moduleKey]
    if idx and self.DB.Load then
        self.DB.Load[idx] = enabled
    end

    if enabled then
        self.ModuleStatus[moduleKey] = "pending_reload"
    else
        self:DisableModuleRuntime(moduleKey)
    end

    return true
end

local function ShowMissingExwindToolsWarning()
    local exists = C_AddOns and C_AddOns.DoesAddOnExist and C_AddOns.DoesAddOnExist("ExwindTools")
    local loaded = C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("ExwindTools")
    local loadable, reason
    if C_AddOns and C_AddOns.GetAddOnInfo then
        local _, _, _, addonLoadable, addonReason = C_AddOns.GetAddOnInfo("ExwindTools")
        loadable = addonLoadable
        reason = addonReason
    end
    local message

    if not exists then
        message = "你并未安装 ExwindTools，无法打开 ExwindTools 设置面板。"
    elseif not loaded then
        if loadable == false and reason and reason ~= "" then
            message = string.format("ExwindTools 当前未载入，无法打开设置面板。\n原因：%s", tostring(reason))
        else
            message = "ExwindTools 当前未载入，无法打开 ExwindTools 设置面板。"
        end
    else
        return false
    end

    if not StaticPopupDialogs["EXWINDTOOLS_MISSING_WARNING"] then
        StaticPopupDialogs["EXWINDTOOLS_MISSING_WARNING"] = {
            text = "%s",
            button1 = "确定",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
    end

    StaticPopup_Show("EXWINDTOOLS_MISSING_WARNING", message)
    ExwindTools:Print(message)
    return true
end
--===============================EXBOSS 编辑模式右键跳转================================
function ExwindTools:OpenConfig(moduleKey)
    if type(moduleKey) == "string" and string.sub(moduleKey, 1, 7) == "ExBoss." then
        local panel = _G.ExBoss and _G.ExBoss.UI and _G.ExBoss.UI.Panel
        if panel and panel.Show and panel.SetTab then
            if self.UI.MainFrame and self.UI.MainFrame:IsShown() then
                self.UI.MainFrame:Hide()
            end

            local targetTab = "boss"
            local targetGlobalKey = nil

            if moduleKey == "ExBoss.TimerBar" then
                targetTab = "globalsettings"
                targetGlobalKey = "timerbar"
            elseif moduleKey == "ExBoss.BunBar" then
                targetTab = "globalsettings"
                targetGlobalKey = "bunbar"
            elseif moduleKey == "ExBoss.Countdown" then
                targetTab = "globalsettings"
                targetGlobalKey = "countdown"
            elseif moduleKey == "ExBoss.FlashText" then
                targetTab = "globalsettings"
                targetGlobalKey = "flashtext"
            elseif moduleKey == "ExBoss.RingProgress" then
                targetTab = "globalsettings"
                targetGlobalKey = "ringprogress"
            elseif moduleKey == "ExBoss.PrivateAuraOptions" or moduleKey == "ExBoss.BossSpellOptions" then
                targetTab = "boss"
            end

            panel:SetTab(targetTab)
            panel:Show()
            if targetGlobalKey then
                local globalPage = panel.GlobalSettingsPage
                if globalPage and globalPage.SetSelectedKey then
                    globalPage:SetSelectedKey(targetGlobalKey)
                end
            end
            return
        end
    end

    if ShowMissingExwindToolsWarning() then
        return
    end

    if not self.UI or not self.UI.Toggle then return end

    if moduleKey then
        self.UI.CurrentPage = "ModuleSettings"
        self.UI.CurrentModule = moduleKey
    end

    if not self.UI.MainFrame or not self.UI.MainFrame:IsShown() then
        self.UI:Toggle()
    else
        self.UI:RefreshContent()
        -- [v4.7] 确保窗口在最前
        self.UI.MainFrame:Raise()
    end
end

--=======================================================================
--========================== 全局编辑模式系统 ============================
--=======================================================================
-- [v3.1 新增] 全局编辑模式切换功能
-- 允许通过 /EX EDMODE 统一切换所有支持模块的拖动状态
ExwindTools.GlobalEditMode = false
ExwindTools.EditModeCallbacks = {}

--- 注册编辑模式回调
--- @param moduleKey string 模块键名
--- @param callback function 回调函数,接收一个参数: enabled (boolean)
function ExwindTools:RegisterEditModeCallback(moduleKey, callback)
    if type(callback) ~= "function" then
        error("RegisterEditModeCallback: callback must be function", 2)
    end
    self.EditModeCallbacks[moduleKey] = callback
end

--- 注销编辑模式回调
function ExwindTools:UnregisterEditModeCallback(moduleKey)
    self.EditModeCallbacks[moduleKey] = nil
end

--- 切换全局编辑模式
function ExwindTools:ToggleGlobalEditMode(forceState)
    if forceState ~= nil then
        self.GlobalEditMode = forceState
    else
        self.GlobalEditMode = not self.GlobalEditMode
    end

    local status = self.GlobalEditMode and "|cff00ff00[启用]|r" or "|cffff0000[禁用]|r"
    self:Print("全局编辑模式: " .. status)

    -- 1. 触发所有注册的回调
    for moduleKey, callback in pairs(self.EditModeCallbacks) do
        pcall(callback, self.GlobalEditMode)
    end

    -- 2. 同步 UI 按钮文字
    if self.UI and self.UI.EditModeToggleButton then
        self.UI.EditModeToggleButton:SetText(self.GlobalEditMode and "关闭编辑模式" or "启用编辑模式")
    end

    -- 3. [v4.7] 弹窗逻辑
    if self.GlobalEditMode then
        if not StaticPopupDialogs["EXWIND_EDIT_MODE_EXIT"] then
            StaticPopupDialogs["EXWIND_EDIT_MODE_EXIT"] = {
                text = "是否退出编辑模式？",
                button1 = "确定",
                OnAccept = function()
                    ExwindTools:ToggleGlobalEditMode(false) -- 点击确定退出模式
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = false, -- 强制点击确定
                preferredIndex = 3,
            }
        end
        StaticPopup_Show("EXWIND_EDIT_MODE_EXIT")
    else
        StaticPopup_Hide("EXWIND_EDIT_MODE_EXIT")
    end
end

--=======================================================================
--========================== 命令行系统 =================================
--=======================================================================
function ExwindTools:Print(msg, ...)
    print("|cffA330C9ExwindTools|r " .. (select("#", ...) > 0 and string.format(msg, ...) or msg))
end

function ExwindTools:RegisterChatCommand(slash, func)
    local cmd = slash:upper()
    _G["SLASH_" .. cmd .. "1"] = "/" .. slash
    SlashCmdList[cmd] = func
end

-- 核心命令
ExwindTools:RegisterChatCommand("ex", function(input)
    local arg = (input or ""):trim():lower()

    if arg == "" then
        if ExwindTools.UI and ExwindTools.UI.Toggle then
            ExwindTools.UI:Toggle()
        else
            ExwindTools:OpenConfig()
        end
        return
    end

    if arg == "dev" or arg == "edit" then
        ExwindTools.State.DevMode = not ExwindTools.State.DevMode
        print("|cffA330C9[ExwindTools]|r 开发者模式: " ..
            (ExwindTools.State.DevMode and "|cff00ff00[启用]|r" or "|cffff0000[禁用]|r"))
        if ExwindTools.UI and ExwindTools.UI.RefreshContent then ExwindTools.UI:RefreshContent() end
        return
    end

    if arg == "debug" then
        ExwindTools.DebugMode = not ExwindTools.DebugMode
        print("|cffA330C9[ExwindTools]|r DEBUG: " .. (ExwindTools.DebugMode and "|cff00ff00[启用]|r" or "|cffff0000[禁用]|r"))
        return
    end

    if arg == "edmode" then
        ExwindTools:ToggleGlobalEditMode()
        return
    end

    if arg == "re" then
        C_UI.Reload(); return
    end

    ExwindTools:OpenConfig()
end)

ExwindTools:RegisterChatCommand("exwind", function(input)
    local arg = (input or ""):trim()
    if arg == "" and ExwindTools.UI and ExwindTools.UI.Toggle then
        ExwindTools.UI:Toggle()
        return
    end
    ExwindTools:OpenConfig()
end)

ExwindTools:RegisterChatCommand("extre", function()
    _G.ExwindToolsDB = nil
    C_UI.Reload()
end)

-- /rl 快捷重载 (兼容未安装 ACP 的用户，已装 ACP 则被覆盖，功能一致)
ExwindTools:RegisterChatCommand("rl", function()
    C_UI.Reload()
end)

ExwindTools:RegisterChatCommand("exstate", function()
    print("|cffA330C9[ExwindTools] 当前 States:|r")
    if not ExwindTools.State then
        print("  State 未初始化"); return
    end

    local keys = {}
    for k in pairs(ExwindTools.State) do table.insert(keys, k) end
    table.sort(keys)

    for _, k in ipairs(keys) do
        local v = ExwindTools.State[k]
        local vStr = type(v) == "number" and string.format("%.2f", v) or tostring(v)
        print(string.format("  |cffcccccc[%s]|r = |cff00ff00%s|r", k, vStr))
    end
end)



--=======================================================================
--========================== 小地图按钮 (Minimap Button) ================
--=======================================================================
function ExwindTools:IsMinimapButtonHidden()
    db.Minimap = db.Minimap or { hide = false }
    return db.Minimap.hide == true
end

function ExwindTools:SetMinimapButtonHidden(hidden)
    db.Minimap = db.Minimap or { hide = false }
    db.Minimap.hide = hidden and true or false

    local LDBIcon = LibStub("LibDBIcon-1.0", true)
    if not LDBIcon then return end
    if LDBIcon:IsRegistered("ExwindTools") then
        LDBIcon:Refresh("ExwindTools", db.Minimap)
    end
end

local function InitMinimapButton()
    local LDB = LibStub("LibDataBroker-1.1", true)
    local LDBIcon = LibStub("LibDBIcon-1.0", true)
    if not LDB or not LDBIcon then return end

    local EX_LDB = LDB:NewDataObject("ExwindTools", {
        type = "launcher",
        text = "ExwindTools",
        icon = [[Interface\AddOns\ExwindCore\Textures\LOGO\EXUI.jpg]],
        OnClick = function(self, button)
            if button == "LeftButton" then
                ExwindTools:OpenConfig()
            elseif button == "RightButton" then
                -- [v3.1 新增] 右键切换全局编辑模式
                ExwindTools:ToggleGlobalEditMode()
            end
        end,
        OnTooltipShow = function(tt)
            tt:AddLine("|cffA330C9ExwindTools|r " .. ExwindTools.VERSION)
            tt:AddLine(" ")
            tt:AddLine("|cff00ff00左键:|r 打开设置面板")
            tt:AddLine("|cff00ff00右键:|r 切换编辑模式")
        end,
    })

    -- 使用 ExwindToolsDB 存储位置信息
    db.Minimap = db.Minimap or { hide = false }
    LDBIcon:Register("ExwindTools", EX_LDB, db.Minimap)
    LDBIcon:Refresh("ExwindTools", db.Minimap)
end

-- 只有在 DB 初始化后才初始化按钮
C_Timer.After(0.5, InitMinimapButton)

EXDebug("ExwindTools 核心加载完成")
