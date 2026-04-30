-- =============================================================
-- [[ 副本笔记备注 ]]
-- { Key = "ExTools.InstanceNote", Name = "副本笔记备注", Desc = "按副本 / 首领显示自定义备注。", Category = 1 },
-- =============================================================

local ExwindTools = _G.ExwindTools
local EXDB = _G.EXDB
if not ExwindTools or not EXDB then return end

local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })
local EXState = ExwindTools.State or {}
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)

local EXWIND_MODULE_KEY = "ExTools.InstanceNote"

local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local strtrim = _G.strtrim or function(text)
    text = tostring(text or "")
    text = text:gsub("^%s+", "")
    text = text:gsub("%s+$", "")
    return text
end

local EX_DEFAULTS = {
    enabled = false,
    panelVisible = true,
    selectedInstanceMapID = 0,
    selectedEncounterID = 0,
    instanceNotes = {},
    encounterNotes = {},
    frameWidth = 520,
    frameMinHeight = 90,
    posX = 0,
    posY = -210,
    showBackground = true,
    backgroundTexture = "Solid",
    backgroundColorR = 0,
    backgroundColorG = 0,
    backgroundColorB = 0,
    backgroundColorA = 0.82,
    showBorder = true,
    borderTexture = "1 Pixel",
    borderColorR = 0.65,
    borderColorG = 0.45,
    borderColorB = 0.12,
    borderColorA = 0.90,
    borderSize = 1,
    borderPadding = 2,
    noteFont = {
        font = "默认",
        size = 16,
        r = 1,
        g = 1,
        b = 1,
        a = 1,
        outline = "",
        shadow = true,
        shadowColor = { 0, 0, 0, 1 },
        shadowX = 1,
        shadowY = -1,
        x = 0,
        y = 0,
    },
}

local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EX_DEFAULTS)

local INSTANCE_CATEGORIES = {
    { key = "mplus_s1", label = L["12.0 第一赛季大米"] },
    { key = "raid_s1", label = L["12.0 第一赛季团本"] },
    { key = "other_1200", label = L["12.0其他副本"] },
}

local function GetFirstInstanceMapID()
    local first = EXDB.InstanceNoteInstanceList and EXDB.InstanceNoteInstanceList[1]
    return first and first.mapID or 0
end

local function GetLocalizedName(nameCN, nameEN)
    local locale = (_G.GetLocale and _G.GetLocale()) or "zhCN"
    if locale == "zhCN" or locale == "zhTW" then
        return nameCN or nameEN or L["未知"]
    end
    return nameEN or nameCN or "Unknown"
end

local function GetInstanceNoteMetaByMapID(mapID)
    mapID = tonumber(mapID) or 0
    if EXDB.GetInstanceNoteMetaByMapID then
        return EXDB:GetInstanceNoteMetaByMapID(mapID)
    end
    return EXDB.InstanceNoteByMapID and EXDB.InstanceNoteByMapID[mapID] or nil
end

local function GetInstanceNoteMetaByInstanceID(instanceID)
    instanceID = tonumber(instanceID) or 0
    if EXDB.GetInstanceNoteMetaByInstanceID then
        return EXDB:GetInstanceNoteMetaByInstanceID(instanceID)
    end
    return EXDB.InstanceNoteByInstanceID and EXDB.InstanceNoteByInstanceID[instanceID] or nil
end

local function GetEncounterNoteMeta(encounterID)
    encounterID = tonumber(encounterID) or 0
    if EXDB.GetEncounterNoteMeta then
        return EXDB:GetEncounterNoteMeta(encounterID)
    end
    return EXDB.InstanceNoteEncounterByID and EXDB.InstanceNoteEncounterByID[encounterID] or nil
end

local function GetEncounterNotesByMapID(mapID)
    mapID = tonumber(mapID) or 0
    if EXDB.GetEncounterNotesByMapID then
        return EXDB:GetEncounterNotesByMapID(mapID)
    end
    return EXDB.InstanceNoteEncountersByMapID and EXDB.InstanceNoteEncountersByMapID[mapID] or {}
end

local function GetLocalizedInstanceNoteName(mapIDOrMeta)
    local meta = mapIDOrMeta
    if type(meta) ~= "table" then
        meta = GetInstanceNoteMetaByMapID(mapIDOrMeta) or GetInstanceNoteMetaByInstanceID(mapIDOrMeta)
    end
    if not meta then
        return L["未知副本"]
    end
    return GetLocalizedName(meta.name, meta.nameEN)
end

local function GetLocalizedEncounterNoteName(encounterIDOrMeta)
    local meta = encounterIDOrMeta
    if type(meta) ~= "table" then
        meta = GetEncounterNoteMeta(encounterIDOrMeta)
    end
    if not meta then
        return L["未知首领"]
    end
    return GetLocalizedName(meta.name, meta.nameEN)
end

local function GetFirstEncounterIDForMap(mapID)
    local list = GetEncounterNotesByMapID(mapID)
    local first = list and list[1]
    return first and first.encounterID or 0
end

local function EnsureRootTables()
    if type(EX_DB.instanceNotes) ~= "table" then
        EX_DB.instanceNotes = {}
    end
    if type(EX_DB.encounterNotes) ~= "table" then
        EX_DB.encounterNotes = {}
    end
end

local function EnsureInstanceNoteConfig(mapID)
    mapID = tonumber(mapID) or 0
    EnsureRootTables()
    if mapID <= 0 then
        return nil
    end

    local config = EX_DB.instanceNotes[mapID]
    if type(config) ~= "table" then
        config = {
            hideInInstance = false,
            hideOnBoss = false,
            text = "",
        }
        EX_DB.instanceNotes[mapID] = config
    else
        if config.hideInInstance == nil then
            config.hideInInstance = false
        end
        if config.hideOnBoss == nil then
            config.hideOnBoss = false
        end
        config.showInInstance = nil
        config.showOnBoss = nil
        if config.text == nil then config.text = "" end
    end

    return config
end

local function EnsureEncounterNoteConfig(encounterID)
    encounterID = tonumber(encounterID) or 0
    EnsureRootTables()
    if encounterID <= 0 then
        return nil
    end

    local config = EX_DB.encounterNotes[encounterID]
    if type(config) ~= "table" then
        config = {
            text = "",
        }
        EX_DB.encounterNotes[encounterID] = config
    else
        config.showInInstance = nil
        config.showOnBoss = nil
        if config.text == nil then config.text = "" end
    end

    return config
end

local function NormalizeSelections()
    local selectedMapID = tonumber(EX_DB.selectedInstanceMapID) or 0
    if selectedMapID <= 0 or not GetInstanceNoteMetaByMapID(selectedMapID) then
        selectedMapID = GetFirstInstanceMapID()
        EX_DB.selectedInstanceMapID = selectedMapID
    end

    local selectedEncounterID = tonumber(EX_DB.selectedEncounterID) or 0
    local validEncounter = (selectedEncounterID > 0) and GetEncounterNoteMeta(selectedEncounterID)
    if validEncounter and validEncounter.mapID ~= selectedMapID then
        validEncounter = nil
    end

    if not validEncounter then
        selectedEncounterID = GetFirstEncounterIDForMap(selectedMapID)
        EX_DB.selectedEncounterID = selectedEncounterID
    end

    EnsureInstanceNoteConfig(selectedMapID)
    EnsureEncounterNoteConfig(selectedEncounterID)

    return selectedMapID, selectedEncounterID
end

local function GetLocalizedInstanceLabel(meta)
    if not meta then
        return L["未知副本"]
    end
    return string.format("%s (%d)", GetLocalizedInstanceNoteName(meta), meta.mapID or 0)
end

local function GetLocalizedEncounterLabel(meta)
    if not meta then
        return L["未知首领"]
    end
    return string.format("%s (%d)", GetLocalizedEncounterNoteName(meta), meta.encounterID or 0)
end

function ExwindTools.GetInstanceNoteInstanceItems()
    local items = {}

    for _, category in ipairs(INSTANCE_CATEGORIES) do
        local groupItems = {}
        for _, meta in ipairs(EXDB.InstanceNoteInstanceList or {}) do
            if meta.category == category.key then
                groupItems[#groupItems + 1] = { GetLocalizedInstanceLabel(meta), meta.mapID }
            end
        end
        if #groupItems > 0 then
            items[#items + 1] = {
                isMenu = true,
                text = category.label,
                menu = groupItems,
            }
        end
    end

    return items
end

function ExwindTools.GetInstanceNoteEncounterItems()
    local items = {}
    local selectedMapID = tonumber(EX_DB.selectedInstanceMapID) or 0
    local encounters = GetEncounterNotesByMapID(selectedMapID)

    for _, meta in ipairs(encounters) do
        items[#items + 1] = { GetLocalizedEncounterLabel(meta), meta.encounterID }
    end

    if #items == 0 then
        items[1] = { L["当前副本无首领数据"], 0 }
    end
    return items
end

local function GetInstanceInfoText(meta)
    if not meta then
        return L["未找到副本信息。"]
    end
    local kindText = (meta.kind == "raid") and L["团队副本"] or L["地下城"]
    return string.format("%s\nMapID: %d / InstanceID: %d", kindText, meta.mapID or 0, meta.instanceID or 0)
end

local function GetEncounterInfoText(meta)
    if not meta then
        return L["当前副本无首领数据。"]
    end
    return string.format("%s\nEncounterID: %d", GetLocalizedInstanceNoteName(meta.mapID), meta.encounterID or 0)
end

local noteFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
noteFrame:SetSize(EX_DB.frameWidth or 520, 120)
noteFrame:SetPoint("TOP", UIParent, "TOP", tonumber(EX_DB.posX) or 0, tonumber(EX_DB.posY) or -210)
noteFrame:SetClampedToScreen(true)
noteFrame:SetFrameStrata("DIALOG")
noteFrame:EnableMouse(true)
noteFrame:SetMovable(true)
noteFrame:RegisterForDrag("LeftButton")
noteFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true,
    tileSize = 16,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
})
noteFrame:Hide()

noteFrame.instanceText = noteFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
noteFrame.instanceText:SetJustifyH("LEFT")
noteFrame.instanceText:SetJustifyV("TOP")
noteFrame.instanceText:SetSpacing(4)

noteFrame.divider = noteFrame:CreateTexture(nil, "ARTWORK")
noteFrame.divider:SetHeight(1)
noteFrame.divider:SetColorTexture(1, 1, 1, 0.18)
noteFrame.divider:Hide()

noteFrame.encounterText = noteFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
noteFrame.encounterText:SetJustifyH("LEFT")
noteFrame.encounterText:SetJustifyV("TOP")
noteFrame.encounterText:SetSpacing(4)

noteFrame.closeButton = CreateFrame("Button", nil, noteFrame, "UIPanelCloseButton")
noteFrame.closeButton:SetSize(22, 22)
noteFrame.closeButton:SetPoint("TOPRIGHT", 2, 2)
noteFrame.closeButton:SetScript("OnClick", function()
    EX_DB.panelVisible = false
    noteFrame:Hide()
end)

noteFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

noteFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local frameCenterX, frameCenterY = self:GetCenter()
    local uiCenterX, uiCenterY = UIParent:GetCenter()
    if frameCenterX and frameCenterY and uiCenterX and uiCenterY then
        EX_DB.posX = math.floor(frameCenterX - uiCenterX + 0.5)
        EX_DB.posY = math.floor(frameCenterY - uiCenterY + 0.5)
    end
end)

local function HasText(text)
    return strtrim(text or "") ~= ""
end

local function GetBackgroundTexture()
    if not EX_DB.showBackground then
        return nil
    end

    if LSM and EX_DB.backgroundTexture and EX_DB.backgroundTexture ~= "None" then
        return LSM:Fetch("background", EX_DB.backgroundTexture)
    end

    return "Interface\\Buttons\\WHITE8X8"
end

local function GetBorderTexture()
    if not EX_DB.showBorder then
        return nil
    end

    if LSM and EX_DB.borderTexture and EX_DB.borderTexture ~= "None" then
        return LSM:Fetch("border", EX_DB.borderTexture)
    end

    return "Interface\\Buttons\\WHITE8X8"
end

local function UpdateNoteFrameVisuals()
    local frameWidth = math.max(280, tonumber(EX_DB.frameWidth) or 520)
    local bgFile = GetBackgroundTexture()
    local edgeFile = GetBorderTexture()
    local borderSize = math.max(1, tonumber(EX_DB.borderSize) or 1)
    local contentPad = math.max(0, tonumber(EX_DB.borderPadding) or 0)

    noteFrame:SetWidth(frameWidth)
    noteFrame:SetBackdrop({
        bgFile = bgFile,
        edgeFile = edgeFile,
        tile = true,
        tileSize = 16,
        edgeSize = borderSize,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })

    if bgFile then
        noteFrame:SetBackdropColor(
            EX_DB.backgroundColorR or 0,
            EX_DB.backgroundColorG or 0,
            EX_DB.backgroundColorB or 0,
            EX_DB.backgroundColorA or 0.82
        )
    else
        noteFrame:SetBackdropColor(0, 0, 0, 0)
    end

    if edgeFile then
        noteFrame:SetBackdropBorderColor(
            EX_DB.borderColorR or 1,
            EX_DB.borderColorG or 1,
            EX_DB.borderColorB or 1,
            EX_DB.borderColorA or 1
        )
    else
        noteFrame:SetBackdropBorderColor(0, 0, 0, 0)
    end

    if ExwindTools.DB_Static and EX_DB.noteFont then
        ExwindTools.DB_Static:ApplyFont(noteFrame.instanceText, EX_DB.noteFont)
        ExwindTools.DB_Static:ApplyFont(noteFrame.encounterText, EX_DB.noteFont)
    end

    noteFrame.instanceText:SetWidth(frameWidth - 32 - (contentPad * 2))
    noteFrame.encounterText:SetWidth(frameWidth - 32 - (contentPad * 2))
end

local function SetNoteFrameText(instanceText, encounterText)
    local instanceBody = strtrim(instanceText or "")
    local encounterBody = strtrim(encounterText or "")
    local hasInstance = instanceBody ~= ""
    local hasEncounter = encounterBody ~= ""
    local contentPad = math.max(0, tonumber(EX_DB.borderPadding) or 0)
    local leftInset = 16 + contentPad
    local rightInset = 16 + contentPad
    local topInset = 14 + contentPad

    UpdateNoteFrameVisuals()

    noteFrame.instanceText:SetText(instanceBody)
    noteFrame.encounterText:SetText(encounterBody)
    noteFrame.instanceText:ClearAllPoints()
    noteFrame.encounterText:ClearAllPoints()
    noteFrame.divider:ClearAllPoints()

    if hasInstance then
        noteFrame.instanceText:SetPoint("TOPLEFT", noteFrame, "TOPLEFT", leftInset, -topInset)
        noteFrame.instanceText:SetPoint("TOPRIGHT", noteFrame, "TOPRIGHT", -rightInset, -topInset)
    end

    local instanceHeight = hasInstance and (noteFrame.instanceText:GetStringHeight() or 0) or 0
    local encounterHeight = hasEncounter and (noteFrame.encounterText:GetStringHeight() or 0) or 0
    local currentBottomAnchor = nil

    if hasEncounter then
        if hasInstance then
            noteFrame.divider:SetPoint("TOPLEFT", noteFrame.instanceText, "BOTTOMLEFT", 0, -10)
            noteFrame.divider:SetPoint("TOPRIGHT", noteFrame.instanceText, "BOTTOMRIGHT", 0, -10)
            noteFrame.divider:Show()
            noteFrame.encounterText:SetPoint("TOPLEFT", noteFrame.divider, "BOTTOMLEFT", 0, -10)
            noteFrame.encounterText:SetPoint("TOPRIGHT", noteFrame.divider, "BOTTOMRIGHT", 0, -10)
            currentBottomAnchor = noteFrame.encounterText
        else
            noteFrame.divider:Hide()
            noteFrame.encounterText:SetPoint("TOPLEFT", noteFrame, "TOPLEFT", leftInset, -topInset)
            noteFrame.encounterText:SetPoint("TOPRIGHT", noteFrame, "TOPRIGHT", -rightInset, -topInset)
            currentBottomAnchor = noteFrame.encounterText
        end
    else
        noteFrame.divider:Hide()
        currentBottomAnchor = hasInstance and noteFrame.instanceText or nil
    end

    local frameHeight = 36 + instanceHeight + encounterHeight + (contentPad * 2)
    if hasInstance and hasEncounter then
        frameHeight = frameHeight + 20
    end
    if not hasInstance and not hasEncounter then
        frameHeight = tonumber(EX_DB.frameMinHeight) or 90
    else
        frameHeight = math.max(tonumber(EX_DB.frameMinHeight) or 90, math.ceil(frameHeight))
    end
    noteFrame:SetHeight(frameHeight)
end

local function GetCurrentInstanceMeta()
    local mapID = tonumber(EXState.MapID) or 0
    if mapID > 0 then
        local byMap = GetInstanceNoteMetaByMapID(mapID)
        if byMap then
            return byMap
        end
    end

    local instanceID = tonumber(EXState.InstanceID) or 0
    if instanceID > 0 then
        return GetInstanceNoteMetaByInstanceID(instanceID) or GetInstanceNoteMetaByMapID(instanceID)
    end

    return nil
end

local function ShouldShowInstanceNote(config)
    if not config or not HasText(config.text) then
        return false
    end

    if not EXState.InInstance then
        return false
    end

    if config.hideInInstance then
        return false
    end

    if config.hideOnBoss and EXState.IsBossEncounter then
        return false
    end

    return true
end

local function ShouldShowEncounterNote(config, encounterID)
    if not config or not HasText(config.text) then
        return false
    end

    return EXState.InInstance
        and EXState.IsBossEncounter
        and (tonumber(EXState.EncounterID) or 0) == (tonumber(encounterID) or 0)
end

local function BuildDisplayText(instanceMeta)
    local instanceConfig = EnsureInstanceNoteConfig(instanceMeta.mapID)
    local instanceBody = ""
    local encounterBody = ""
    local activeEncounterMeta = GetEncounterNoteMeta(tonumber(EXState.EncounterID) or 0)

    if ShouldShowInstanceNote(instanceConfig) then
        instanceBody = strtrim(instanceConfig.text or "")
    end

    if activeEncounterMeta and activeEncounterMeta.mapID == instanceMeta.mapID then
        local encounterConfig = EnsureEncounterNoteConfig(activeEncounterMeta.encounterID)
        if ShouldShowEncounterNote(encounterConfig, activeEncounterMeta.encounterID) then
            encounterBody = strtrim(encounterConfig.text or "")
        end
    end

    return instanceBody, encounterBody
end

local function UpdateDisplay()
    if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) or not EX_DB.enabled then
        noteFrame:Hide()
        return
    end

    if EX_DB.panelVisible == false then
        noteFrame:Hide()
        return
    end

    if not EXState.InInstance then
        noteFrame:Hide()
        return
    end

    local instanceMeta = GetCurrentInstanceMeta()
    if not instanceMeta then
        noteFrame:Hide()
        return
    end

    local instanceBody, encounterBody = BuildDisplayText(instanceMeta)
    if not HasText(instanceBody) and not HasText(encounterBody) then
        noteFrame:Hide()
        return
    end

    SetNoteFrameText(instanceBody, encounterBody)
    noteFrame:Show()
end

local function RebuildLayout()
    local selectedMapID, selectedEncounterID = NormalizeSelections()
    local selectedInstance = GetInstanceNoteMetaByMapID(selectedMapID)
    local selectedEncounter = GetEncounterNoteMeta(selectedEncounterID)

    local layout = {
        { key = "header", type = "header", x = 2, y = 1, w = 50, h = 2, label = L["副本笔记备注"], labelSize = 25 },
        { key = "desc", type = "description", x = 2, y = 4, w = 52, h = 2, label = L["为指定副本或首领写备注，输入的内容会直接显示在屏幕上的备注框内。"] },
        { key = "enabled", type = "checkbox", x = 2, y = 7, w = 14, h = 2, label = L["启用功能"] },
        { key = "panelVisible", type = "checkbox", x = 18, y = 7, w = 14, h = 2, label = L["显示面板"] },

        { key = "sub_display", type = "subheader", x = 2, y = 10, w = 50, h = 1, label = L["屏幕显示设置"] },
        { key = "frameWidth", type = "slider", x = 2, y = 13, w = 14, h = 2, label = L["宽度"], min = 280, max = 900, step = 10 },
        { key = "frameMinHeight", type = "slider", x = 18, y = 13, w = 14, h = 2, label = L["最小高度"], min = 90, max = 500, step = 10 },
        { key = "showBackground", type = "checkbox", x = 34, y = 13, w = 14, h = 2, label = L["显示背景"] },
        { key = "showBorder", type = "checkbox", x = 2, y = 17, w = 14, h = 2, label = L["显示边框"] },
        { key = "backgroundTexture", type = "lsm_background", x = 18, y = 17, w = 15, h = 2, label = L["背景材质"] },
        { key = "backgroundColor", type = "color", x = 35, y = 17, w = 16, h = 2, label = L["背景颜色"] },
        { key = "borderTexture", type = "lsm_border", x = 2, y = 21, w = 15, h = 2, label = L["边框材质"] },
        { key = "borderColor", type = "color", x = 19, y = 21, w = 15, h = 2, label = L["边框颜色"] },
        { key = "borderSize", type = "slider", x = 36, y = 21, w = 15, h = 2, label = L["边框粗细"], min = 1, max = 16, step = 1 },
        { key = "borderPadding", type = "slider", x = 2, y = 25, w = 15, h = 2, label = L["边框间距 (Padding)"], min = 0, max = 12, step = 1 },
        { key = "noteFont", type = "fontgroup", x = 1, y = 29, w = 53, h = 17, label = L["内容字体"] },

        { key = "sub_instance", type = "subheader", x = 2, y = 48, w = 50, h = 1, label = L["副本备注"] },
        { key = "selectedInstanceMapID", type = "dropdown", x = 2, y = 51, w = 20, h = 2, label = L["选择副本"], items = "func:ExwindTools.GetInstanceNoteInstanceItems" },
        { key = "instanceInfo", type = "description", x = 24, y = 51, w = 26, h = 3, label = function() return
            GetInstanceInfoText(selectedInstance) end },
        {
            key = "instanceEditor",
            type = "TableGroup",
            x = 1,
            y = 1,
            w = 1,
            h = 1,
            label = "--[[ Function ]]",
            parentKey = "instanceNotes." .. selectedMapID,
            children = {
                { key = "hideInInstance", type = "checkbox", x = 2, y = 55, w = 14, h = 2, label = L["该副本隐藏"] },
                { key = "hideOnBoss", type = "checkbox", x = 18, y = 55, w = 14, h = 2, label = L["首领战隐藏"] },
                { key = "text", type = "input", x = 2, y = 58, w = 48, h = 10, label = L["备注内容"], labelPos = "top" },
            },
        },

        { key = "sub_boss", type = "subheader", x = 2, y = 70, w = 50, h = 1, label = L["首领备注"] },
        { key = "selectedEncounterID", type = "dropdown", x = 2, y = 73, w = 20, h = 2, label = L["选择首领"], items = "func:ExwindTools.GetInstanceNoteEncounterItems" },
        { key = "encounterInfo", type = "description", x = 24, y = 73, w = 26, h = 3, label = function() return
            GetEncounterInfoText(selectedEncounter) end },
    }

    if selectedEncounterID > 0 and selectedEncounter then
        layout[#layout + 1] = {
            key = "encounterEditor",
            type = "TableGroup",
            x = 1,
            y = 1,
            w = 1,
            h = 1,
            label = "--[[ Function ]]",
            parentKey = "encounterNotes." .. selectedEncounterID,
            children = {
                { key = "text", type = "input", x = 2, y = 77, w = 48, h = 10, label = L["备注内容"], labelPos = "top" },
            },
        }
    else
        layout[#layout + 1] = {
            key = "noEncounterInfo",
            type = "description",
            x = 2,
            y = 77,
            w = 48,
            h = 2,
            label = L["当前副本没有可编辑的首领数据。"],
        }
    end

    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end

NormalizeSelections()
RebuildLayout()
UpdateNoteFrameVisuals()

if ExwindTools.RegisterHUD then
    ExwindTools:RegisterHUD(EXWIND_MODULE_KEY, noteFrame)
end

if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then
    return
end

ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function(info)
    local fullPath = tostring(info and info.fullPath or "")

    if fullPath == "selectedInstanceMapID" then
        NormalizeSelections()
        RebuildLayout()
        if ExwindTools.UI and ExwindTools.UI.RefreshContent then
            ExwindTools.UI:RefreshContent()
        end
    elseif fullPath == "selectedEncounterID" then
        EnsureEncounterNoteConfig(EX_DB.selectedEncounterID)
        RebuildLayout()
        if ExwindTools.UI and ExwindTools.UI.RefreshContent then
            ExwindTools.UI:RefreshContent()
        end
    end

    UpdateNoteFrameVisuals()
    UpdateDisplay()
end)

ExwindTools:WatchState("InInstance", EXWIND_MODULE_KEY, UpdateDisplay)
ExwindTools:WatchState("InstanceID", EXWIND_MODULE_KEY, UpdateDisplay)
ExwindTools:WatchState("MapID", EXWIND_MODULE_KEY, UpdateDisplay)
ExwindTools:WatchState("IsBossEncounter", EXWIND_MODULE_KEY, UpdateDisplay)
ExwindTools:WatchState("EncounterID", EXWIND_MODULE_KEY, UpdateDisplay)

UpdateDisplay()
