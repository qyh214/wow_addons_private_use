-- =============================================================
-- [[ PVE 钥石信息 ]]
-- { Key = "ExTools.PveKeystoneInfo", Name = "大米队友钥石", Desc = "在 PVEFrame 上显示玩家与队友钥石信息。", Category = 4 },
-- =============================================================

local ExwindTools = _G.ExwindTools
local EXDB = _G.EXDB
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

local EXWIND_MODULE_KEY = "ExTools.PveKeystoneInfo"
local PartySync = ExwindTools.PartySync
local LibOpenRaid = _G.LibStub and _G.LibStub("LibOpenRaid-1.0", true)

local EX_DEFAULTS = {
    enabled = false,
    offsetX = 156,
    offsetY = -107,
    playerFont = {
        a = 1,
        b = 1,
        font = nil,
        g = 0.23137256503105,
        outline = "THICKOUTLINE",
        r = 0.89411771297455,
        shadow = false,
        shadowX = -1.1000003814697,
        shadowY = -1.1000003814697,
        size = 20,
        x = 22,
        y = -134,
    },
    partyNameFont = {
        a = 1,
        b = 1,
        font = nil,
        g = 1,
        outline = "OUTLINE",
        r = 1,
        shadow = true,
        shadowX = 1,
        shadowY = -1,
        size = 15,
        x = 23,
        y = 0,
    },
    partyKeyFont = {
        a = 1,
        b = 1,
        font = nil,
        g = 1,
        outline = "OUTLINE",
        r = 1,
        shadow = true,
        shadowX = 1,
        shadowY = -1,
        size = 15,
        x = 148,
        y = 0,
    },
    previewMode = false,
    side = "RIGHT",
}

local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EX_DEFAULTS)
local infoFrame
local previewData
local openRaidReceiver = {}
local openRaidRegistered = false
local lastKnownKeystones = {
    player = nil,
    party = {},
}
local PLAYER_BASE_Y = 0
local PARTY_NAME_BASE_Y = -32
local PARTY_KEY_BASE_Y = -32
local Refresh
local DEFAULT_MAP_NAMES = {
    [239] = "执政",
    [556] = "萨隆",
    [161] = "通天",
    [402] = "学院",
    [557] = "风行",
    [558] = "魔导",
    [560] = "洞窟",
    [559] = "节点",
    [525] = "水闸",
    [499] = "隐修",
    [505] = "破晨",
    [503] = "回响",
    [542] = "生态",
    [378] = "赎罪",
    [392] = "宏图",
    [391] = "天街",
}

local function EX_RegisterLayout()
    local layout = {
        { key = "header", type = "header", x = 1, y = 1, w = 55, h = 2, label = L["大米队友钥石"], labelSize = 25 },
        { key = "enabled", type = "checkbox", x = 1, y = 5, w = 12, h = 2, label = L["启用模块"] },
        { key = "side", type = "select", x = 15, y = 5, w = 12, h = 2, label = L["依附侧"], options = { ["LEFT"] = L["左侧"], ["RIGHT"] = L["右侧"] } },
        { key = "offsetX", type = "slider", x = 1, y = 10, w = 15, h = 2, label = L["水平偏移 (X)"], min = -300, max = 300, step = 1 },
        { key = "offsetY", type = "slider", x = 18, y = 10, w = 15, h = 2, label = L["垂直偏移 (Y)"], min = -500, max = 500, step = 1 },
        { key = "previewMode", type = "checkbox", x = 35, y = 10, w = 12, h = 2, label = L["预览模式"] },
        { key = "playerFont", type = "fontgroup", x = 1, y = 13, w = 55, h = 18, label = L["玩家文字设置"], labelSize = 20 },
        { key = "partyNameFont", type = "fontgroup", x = 1, y = 34, w = 55, h = 18, label = L["队友名称设置"], labelSize = 20 },
        { key = "partyKeyFont", type = "fontgroup", x = 1, y = 55, w = 55, h = 18, label = L["队友钥石设置"], labelSize = 20 },
    }
    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout()

if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

local function NormalizePlayerName(name)
    if type(name) ~= "string" or name == "" then return nil end
    return _G.Ambiguate(name, "short")
end

local function TryAcquireOpenRaid()
    if not LibOpenRaid and _G.LibStub then
        LibOpenRaid = _G.LibStub("LibOpenRaid-1.0", true)
    end
    return LibOpenRaid
end

local function EnsureOpenRaidBridge()
    local lib = TryAcquireOpenRaid()
    if not lib or openRaidRegistered or not lib.RegisterCallback then
        return
    end

    function openRaidReceiver.OnKeystoneUpdate()
        if infoFrame and infoFrame:IsShown() and Refresh then
            Refresh()
        end
    end

    lib.RegisterCallback(openRaidReceiver, "KeystoneUpdate", "OnKeystoneUpdate")
    openRaidRegistered = true
end

local function GetOpenRaidKeystone(unit)
    local lib = TryAcquireOpenRaid()
    if not lib or not lib.GetKeystoneInfo or not unit or not _G.UnitExists(unit) then
        return 0, 0, false
    end

    local keystoneInfo = lib.GetKeystoneInfo(unit)
    if type(keystoneInfo) ~= "table" then
        return 0, 0, false
    end

    local keyLevel = tonumber(keystoneInfo.level) or 0
    local keyMapID = tonumber(keystoneInfo.challengeMapID) or tonumber(keystoneInfo.mythicPlusMapID) or tonumber(keystoneInfo.mapID) or 0
    return keyLevel, keyMapID, keyLevel > 0 and keyMapID > 0
end

local function GetUnitCacheKey(unit)
    if unit == "player" then
        return "player"
    end
    local fullName = _G.GetUnitName(unit, true) or _G.UnitName(unit)
    return type(fullName) == "string" and fullName ~= "" and fullName or unit
end

local function HasResolvedKeystoneData(keyLevel, keyMapID)
    if type(keyLevel) ~= "number" then
        return false
    end
    if keyLevel < 0 then
        return true
    end
    return keyLevel > 0 and type(keyMapID) == "number" and keyMapID > 0
end

local function StoreKeystoneSnapshot(cacheKey, keyLevel, keyMapID)
    if not cacheKey or not HasResolvedKeystoneData(keyLevel, keyMapID) then
        return
    end

    local snapshot = {
        keyLevel = keyLevel,
        keyMapID = keyMapID or 0,
        ts = _G.GetTime and _G.GetTime() or 0,
    }

    if cacheKey == "player" then
        lastKnownKeystones.player = snapshot
    else
        lastKnownKeystones.party[cacheKey] = snapshot
    end
end

local function GetKeystoneSnapshot(cacheKey)
    if cacheKey == "player" then
        return lastKnownKeystones.player
    end
    return cacheKey and lastKnownKeystones.party[cacheKey] or nil
end

local function GetSpecIconMarkup(specID, size)
    specID = tonumber(specID) or 0
    if specID <= 0 then
        return ""
    end

    local icon = EXDB and EXDB.SpecByID and EXDB.SpecByID[specID] and EXDB.SpecByID[specID].icon
    if (not icon or icon == 0) and _G.GetSpecializationInfoForSpecID then
        local _, _, _, specIcon = _G.GetSpecializationInfoForSpecID(specID)
        icon = specIcon
    end
    if not icon or icon == 0 then
        return ""
    end

    size = size or 14
    return string.format("|T%d:%d:%d:0:0:64:64:5:59:5:59|t", icon, size, size)
end

local function GetClassColorHex(classTag)
    local classColors = _G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS
    local color = classColors and classTag and classColors[classTag]
    if not color then
        return "ffffffff"
    end
    if color.colorStr then
        return tostring(color.colorStr):gsub("^|c", "")
    end
    return string.format("ff%02x%02x%02x",
        math.floor((color.r or 1) * 255 + 0.5),
        math.floor((color.g or 1) * 255 + 0.5),
        math.floor((color.b or 1) * 255 + 0.5))
end

local function GetShortMapName(mapID)
    local custom = DEFAULT_MAP_NAMES[mapID]
    return custom and L[custom] or "?"
end

local function GetMapIconMarkup(keyMapID, size)
    local _, _, _, icon = _G.C_ChallengeMode.GetMapUIInfo(keyMapID or 0)
    return _G.CreateSimpleTextureMarkup(icon or 136116, size or 14, size or 14)
end

local function FormatMapLevel(keyLevel, keyMapID, withIcon, waiting, blocked, useShortName)
    if blocked then
        return string.format("|cff666666%s|r", L["无缓存"])
    end
    if waiting then
        return string.format("|cff888888%s|r", L["等待同步"])
    end
    if keyLevel and keyLevel < 0 then
        return string.format("|cff888888%s|r", L["已隐藏"])
    end
    if keyLevel and keyMapID and keyLevel > 0 and keyMapID > 0 then
        local fullName = _G.C_ChallengeMode.GetMapUIInfo(keyMapID)
        local mapName = useShortName and GetShortMapName(keyMapID) or (fullName or GetShortMapName(keyMapID))
        local rarity = _G.C_ChallengeMode.GetKeystoneLevelRarityColor(keyLevel)
        local hex = (rarity and rarity.GenerateHexColor and rarity:GenerateHexColor()) or "ffffffff"
        local iconMarkup = withIcon and (GetMapIconMarkup(keyMapID, 14) .. " ") or ""
        return string.format("%s|c%s%s(%d)|r", iconMarkup, hex, mapName, keyLevel)
    end
    return string.format("|cff888888%s|r", L["无钥石"])
end

local function BuildPartyNameText(displayName, classTag, specID)
    local colorHex = GetClassColorHex(classTag)
    local iconMarkup = GetSpecIconMarkup(specID, 14)
    if iconMarkup ~= "" then
        return string.format("%s |c%s%s|r", iconMarkup, colorHex, displayName)
    end
    return string.format("|c%s%s|r", colorHex, displayName)
end

local function BuildPartyMemberPrefix(unit)
    local displayName = NormalizePlayerName(_G.GetUnitName(unit, true)) or (_G.UnitName(unit) or L["队友"])
    local member = PartySync and PartySync:GetMember(unit)
    local classTag = member and member.class
    local specID = member and member.specID

    if (not classTag or classTag == "") and _G.UnitExists(unit) then
        local _, unitClassTag = _G.UnitClass(unit)
        classTag = unitClassTag
    end

    return BuildPartyNameText(displayName, classTag, specID)
end

local function BuildPreviewData()
    local maps = _G.C_ChallengeMode and _G.C_ChallengeMode.GetMapTable and _G.C_ChallengeMode.GetMapTable() or {}
    local pool = {}
    if type(maps) == "table" and #maps > 0 then
        for i = 1, #maps do
            pool[#pool + 1] = maps[i]
        end
    else
        for mapID in pairs(DEFAULT_MAP_NAMES) do
            pool[#pool + 1] = mapID
        end
        table.sort(pool)
    end

    for i = #pool, 2, -1 do
        local j = math.random(i)
        pool[i], pool[j] = pool[j], pool[i]
    end

    local name = NormalizePlayerName(_G.GetUnitName("player", true)) or (_G.UnitName("player") or L["玩家"])
    local _, classTag = _G.UnitClass("player")
    local specID = (_G.GetSpecialization and _G.GetSpecialization()) and _G.GetSpecializationInfo(_G.GetSpecialization()) or
        0

    previewData = {
        player = {
            name = name,
            classTag = classTag,
            specID = specID,
            keyLevel = math.random(8, 14),
            keyMapID = pool[1] or 399,
        },
        party = {},
    }

    for i = 1, 4 do
        previewData.party[i] = {
            name = name,
            classTag = classTag,
            specID = specID,
            keyLevel = math.random(8, 14),
            keyMapID = pool[i + 1] or pool[1] or 399,
        }
    end
end

local function EnsurePreviewData()
    if not previewData then
        BuildPreviewData()
    end
end

local function ShouldShow()
    if not EX_DB.enabled then return false end
    if not _G.PVEFrame or not _G.PVEFrame:IsShown() then return false end
    return _G.PanelTemplates_GetSelectedTab(_G.PVEFrame) == 3
end

local function IsAuraSecretsActive()
    local state = ExwindTools.State
    return state and state.AuraSecretsActive or false
end

local function HasRealPartyMembers()
    if PartySync and PartySync.HasRealPartyMembers then
        return PartySync:HasRealPartyMembers()
    end

    if not (_G.IsInGroup and _G.IsInGroup()) then
        return false
    end

    for i = 1, 4 do
        local unit = "party" .. i
        if _G.UnitExists(unit) and _G.UnitIsPlayer(unit) then
            return true
        end
    end

    return false
end

local function UpdatePosition()
    if not infoFrame or not _G.PVEFrame then return end

    infoFrame:ClearAllPoints()
    local side = EX_DB.side or "RIGHT"
    local offX = EX_DB.offsetX or 0
    local offY = EX_DB.offsetY or 0

    if side == "LEFT" then
        infoFrame:SetPoint("TOPLEFT", _G.PVEFrame, "TOPLEFT", 28 + offX, -78 + offY)
    else
        infoFrame:SetPoint("TOPRIGHT", _G.PVEFrame, "TOPRIGHT", -38 + offX, -78 + offY)
    end
end

local function ApplyFonts()
    if not infoFrame then return end

    EXDB:ApplyFont(infoFrame.playerText, EX_DB.playerFont)
    EXDB:ApplyFont(infoFrame.partyNameText, EX_DB.partyNameFont or EX_DB.partyFont or EX_DEFAULTS.partyNameFont)
    EXDB:ApplyFont(infoFrame.partyKeyText, EX_DB.partyKeyFont or EX_DB.partyFont or EX_DEFAULTS.partyKeyFont)

    infoFrame.playerText:ClearAllPoints()
    infoFrame.playerText:SetPoint("TOPLEFT", infoFrame, "TOPLEFT",
        EX_DB.playerFont.x or 0,
        PLAYER_BASE_Y + (EX_DB.playerFont.y or 0))
    infoFrame.playerText:SetWidth(340)
    infoFrame.playerText:SetJustifyH("LEFT")
    infoFrame.playerText:SetSpacing(2)

    infoFrame.partyNameText:ClearAllPoints()
    infoFrame.partyNameText:SetPoint("TOPLEFT", infoFrame, "TOPLEFT",
        (EX_DB.partyNameFont and EX_DB.partyNameFont.x) or 0,
        PARTY_NAME_BASE_Y + ((EX_DB.partyNameFont and EX_DB.partyNameFont.y) or 0))
    infoFrame.partyNameText:SetWidth(160)
    infoFrame.partyNameText:SetJustifyH("LEFT")
    infoFrame.partyNameText:SetSpacing(2)

    infoFrame.partyKeyText:ClearAllPoints()
    infoFrame.partyKeyText:SetPoint("TOPLEFT", infoFrame, "TOPLEFT",
        (EX_DB.partyKeyFont and EX_DB.partyKeyFont.x) or 170,
        PARTY_KEY_BASE_Y + ((EX_DB.partyKeyFont and EX_DB.partyKeyFont.y) or 0))
    infoFrame.partyKeyText:SetWidth(180)
    infoFrame.partyKeyText:SetJustifyH("LEFT")
    infoFrame.partyKeyText:SetSpacing(2)
end

local function UpdateDisplay()
    if not infoFrame then return end

    local ownLevel, ownMapID = 0, 0
    if EX_DB.previewMode then
        EnsurePreviewData()
        ownLevel = previewData.player.keyLevel
        ownMapID = previewData.player.keyMapID
    else
        if PartySync and not IsAuraSecretsActive() then
            ownLevel, ownMapID = PartySync:GetKeystone("player")
        end

        if not HasResolvedKeystoneData(ownLevel, ownMapID) then
            ownMapID = _G.C_MythicPlus.GetOwnedKeystoneChallengeMapID()
            ownLevel = _G.C_MythicPlus.GetOwnedKeystoneLevel()
        end

        if HasResolvedKeystoneData(ownLevel, ownMapID) then
            StoreKeystoneSnapshot("player", ownLevel, ownMapID)
        else
            local ownSnapshot = GetKeystoneSnapshot("player")
            if ownSnapshot then
                ownLevel = ownSnapshot.keyLevel
                ownMapID = ownSnapshot.keyMapID
            end
        end
    end
    infoFrame.playerText:SetText(string.format("%s %s", GetMapIconMarkup(ownMapID, 14),
        FormatMapLevel(ownLevel, ownMapID, false, false, false, false)))

    local partyNameLines = {}
    local partyKeyLines = {}

    if EX_DB.previewMode then
        EnsurePreviewData()
        for i = 1, 4 do
            local entry = previewData.party[i]
            partyNameLines[#partyNameLines + 1] = BuildPartyNameText(entry.name, entry.classTag, entry.specID)
            partyKeyLines[#partyKeyLines + 1] = FormatMapLevel(entry.keyLevel, entry.keyMapID, true, false, false, true)
        end
    elseif HasRealPartyMembers() then
        EnsureOpenRaidBridge()
        local auraSecretsActive = IsAuraSecretsActive()
        local blocked = auraSecretsActive or (PartySync and not PartySync:IsPartyCommAllowed())
        for i = 1, _G.GetNumSubgroupMembers() do
            local unit = "party" .. i
            if _G.UnitExists(unit) and _G.UnitIsPlayer(unit) then
                local keyLevel, keyMapID = 0, 0
                local knownKeyState = false
                local cacheKey = GetUnitCacheKey(unit)
                local member = PartySync and PartySync:GetMember(unit)
                if PartySync and not auraSecretsActive then
                    keyLevel, keyMapID = PartySync:GetKeystone(unit)
                    knownKeyState = member and (member.keyTS or 0) > 0 or false
                end

                if knownKeyState and HasResolvedKeystoneData(keyLevel, keyMapID) then
                    StoreKeystoneSnapshot(cacheKey, keyLevel, keyMapID)
                end

                if not HasResolvedKeystoneData(keyLevel, keyMapID) then
                    local openRaidLevel, openRaidMapID, openRaidKnown = GetOpenRaidKeystone(unit)
                    if openRaidKnown then
                        keyLevel = openRaidLevel
                        keyMapID = openRaidMapID
                        knownKeyState = true
                        StoreKeystoneSnapshot(cacheKey, keyLevel, keyMapID)
                    end
                end

                if not HasResolvedKeystoneData(keyLevel, keyMapID) then
                    local snapshot = GetKeystoneSnapshot(cacheKey)
                    if snapshot then
                        keyLevel = snapshot.keyLevel
                        keyMapID = snapshot.keyMapID
                        knownKeyState = true
                    end
                end

                partyNameLines[#partyNameLines + 1] = BuildPartyMemberPrefix(unit)
                partyKeyLines[#partyKeyLines + 1] = FormatMapLevel(
                    keyLevel,
                    keyMapID,
                    true,
                    not blocked and not knownKeyState,
                    blocked and not knownKeyState,
                    true
                )
            end
        end
    end

    infoFrame.partyNameText:SetText(table.concat(partyNameLines, "\n"))
    infoFrame.partyKeyText:SetText(table.concat(partyKeyLines, "\n"))

    local partyHeight = math.max(
        infoFrame.partyNameText:GetStringHeight() or 0,
        infoFrame.partyKeyText:GetStringHeight() or 0
    )
    local playerHeight = infoFrame.playerText:GetStringHeight() or 18
    infoFrame:SetHeight(math.max(
        120,
        math.abs(PLAYER_BASE_Y) + playerHeight + 20,
        math.abs(PARTY_NAME_BASE_Y) + partyHeight + 20,
        math.abs(PARTY_KEY_BASE_Y) + partyHeight + 20
    ))
end

Refresh = function()
    if not infoFrame then return end
    UpdatePosition()
    ApplyFonts()
    UpdateDisplay()
end

local function RequestData()
    if EX_DB.previewMode then
        return
    end
    if IsAuraSecretsActive() then
        return
    end
    if not HasRealPartyMembers() then
        return
    end
    EnsureOpenRaidBridge()
    if PartySync and PartySync.RequestPartyData then
        PartySync:RequestPartyData()
    end
    local lib = TryAcquireOpenRaid()
    if lib then
        if lib.RequestAllData then
            lib.RequestAllData()
        end
        if lib.RequestKeystoneDataFromParty then
            lib.RequestKeystoneDataFromParty()
        end
    end
end

local function CreateFrameIfNeeded()
    if infoFrame or not _G.PVEFrame then return end

    infoFrame = CreateFrame("Frame", "ExPVEKeystoneInfoFrame", _G.PVEFrame)
    infoFrame:SetSize(360, 160)
    infoFrame:EnableMouse(false)
    infoFrame:SetFrameStrata("HIGH")

    local playerText = infoFrame:CreateFontString(nil, "OVERLAY")
    infoFrame.playerText = playerText

    local partyNameText = infoFrame:CreateFontString(nil, "OVERLAY")
    infoFrame.partyNameText = partyNameText

    local partyKeyText = infoFrame:CreateFontString(nil, "OVERLAY")
    infoFrame.partyKeyText = partyKeyText

    ApplyFonts()
    UpdatePosition()
    infoFrame:Hide()
end

local function UpdateVisibility()
    if not infoFrame then
        CreateFrameIfNeeded()
    end
    if not infoFrame then return end

    if ShouldShow() then
        infoFrame:Show()
        RequestData()
        Refresh()
    else
        infoFrame:Hide()
    end
end

local function HookPVE()
    if not _G.PVEFrame then return end

    CreateFrameIfNeeded()

    _G.PVEFrame:HookScript("OnShow", function()
        _G.C_Timer.After(0.1, UpdateVisibility)
    end)
    _G.PVEFrame:HookScript("OnHide", function()
        if infoFrame then infoFrame:Hide() end
    end)

    if _G.PVEFrame_ShowFrame then
        _G.hooksecurefunc("PVEFrame_ShowFrame", UpdateVisibility)
    end

    UpdateVisibility()
end

ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function()
    EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EX_DEFAULTS)
    previewData = nil
    if not EX_DB.enabled then
        if infoFrame then infoFrame:Hide() end
        return
    end
    if not infoFrame then
        CreateFrameIfNeeded()
    end
    UpdateVisibility()
end)

ExwindTools:WatchState("AuraSecretsActive", EXWIND_MODULE_KEY, function()
    if infoFrame and infoFrame:IsShown() then
        UpdateVisibility()
    end
end)

ExwindTools:RegisterEvent("GROUP_ROSTER_UPDATE", EXWIND_MODULE_KEY, function()
    if infoFrame and infoFrame:IsShown() then
        RequestData()
        Refresh()
    end
end)

ExwindTools:RegisterEvent("EX_PARTY_INFO_UPDATED", EXWIND_MODULE_KEY, function()
    if infoFrame and infoFrame:IsShown() then
        Refresh()
    end
end)

ExwindTools:RegisterEvent("BAG_UPDATE_DELAYED", EXWIND_MODULE_KEY, function()
    if infoFrame and infoFrame:IsShown() then
        Refresh()
    end
end)

ExwindTools:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE", EXWIND_MODULE_KEY, function()
    if infoFrame and infoFrame:IsShown() then
        Refresh()
    end
end)

ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", EXWIND_MODULE_KEY, function()
    _G.C_Timer.After(0.3, function()
        if infoFrame or _G.PVEFrame then
            UpdateVisibility()
        end
    end)
end)

if _G.PVEFrame then
    HookPVE()
else
    ExwindTools:RegisterEvent("ADDON_LOADED", EXWIND_MODULE_KEY, function(_, addonName)
        if addonName == "Blizzard_GroupFinder" then
            HookPVE()
        end
    end)
end

_G.C_Timer.After(1, function()
    if EX_DB.enabled then
        CreateFrameIfNeeded()
        UpdateVisibility()
    end
end)

ExwindTools:ReportReady(EXWIND_MODULE_KEY)
