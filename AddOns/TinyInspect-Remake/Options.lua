
--------------
-- 配置面板 --
--------------

local LibEvent = LibStub:GetLibrary("LibEvent.7000")

local VERSION = 3.0

local addon, ns = ...

local L = ns.L or {}

setmetatable(L, { __index = function(_, k)
    return k:gsub("([a-z])([A-Z])", "%1 %2")
end})

local DefaultDB = {
    version = VERSION,                    --配置的版本號
    ShowItemBorder = false,               --物品直角邊框 #暂停用#
    EnableItemLevel  = true,              --物品等級
      ShowColoredItemLevelString = false, --裝等文字隨物品品質
      ShowItemSlotString = true,          --物品部位文字
        EnableItemLevelBag = true,
        EnableItemLevelBank = true,
        EnableItemLevelMerchant = true,
        EnableItemLevelTrade = true,
        EnableItemLevelGuildBank = true,
        EnableItemLevelAuction = true,
        EnableItemLevelAltEquipment = true,
        EnableItemLevelPaperDoll = true,
        EnableItemLevelGuildNews = true,
        EnableItemLevelChat = false,
        EnableItemLevelLoot = true,
        EnableItemLevelOther = true,
    ShowInspectAngularBorder = false,     --觀察面板直角邊框
    ShowInspectColoredLabel = true,       --觀察面板高亮橙裝武器標簽
    ShowCharacterItemSheet = true,        --顯示玩家自己裝備列表
    ShowInspectItemSheet = true,          --顯示观察对象装备列表 --20190318Added
        ShowOwnFrameWhenInspecting = false,   --觀察同時顯示自己裝備列表
        ShowItemStats = false,                --顯示裝備屬性統計
        ShowUpgradeInfo = true,               --顯示升級路徑信息
    EnablePartyItemLevel = true,          --小隊裝等
        SendPartyItemLevelToSelf = true,  --發送小隊裝等到自己面板
        SendPartyItemLevelToParty = false, --發送小隊裝等到隊伍頻道
        ShowPartySpecialization = true,   --顯示隊友天賦
    EnableRaidItemLevel = false,          --團隊裝等
    EnableMouseItemLevel = false,         --鼠標裝等
    EnableMouseSpecialization = true,     --鼠標天賦
    EnableMouseWeaponLevel = true,        --鼠標武器等級
    PaperDollItemLevelOutsideString = false, --PaperDoll文字外邊顯示(沒有在配置面板)
    ItemLevelAnchorPoint = "TOP",         --裝等位置
    ShowGearDurability = true,            --裝備耐久度顯示
    GearDurabilityAnchorPoint = "BOTTOM", --裝備耐久度位置
    ShowPluginGreenState = false,         --裝備綠字屬性前綴顯示
    ShowGemAndEnchant = true,             --显示宝石和附魔
}

local options = {
    --{ key = "ShowItemBorder" },
    { key = "ShowGemAndEnchant" },
    { key = "EnableItemLevel",
      child = {
        { key = "ShowColoredItemLevelString" },
        { key = "ShowItemSlotString" },
      },
      subtype = {
        xpos = 490, ypos = -50,
        { key = "Other" },
        { key = "AltEquipment" },
        { key = "GuildNews" },
        { key = "Chat" },
        -- { key = "Bag" },
        -- { key = "Bank" },
        -- { key = "GuildBank" },
        -- { key = "Merchant" },
        -- { key = "Trade" },
        { key = "PaperDoll" },
        -- { key = "Loot" },
      },
      anchors = {
        { key = "ItemLevelAnchorPoint", xpos = 488, ypos = 44 },
        { key = "GearDurabilityAnchorPoint", xpos = 598, ypos = 44 },
      },
    },
    { key = "ShowGearDurability",
        checkedFunc = function() LibEvent:trigger("GEAR_DURABILITY_DISPLAY_CHANGED") end,
        uncheckedFunc = function() LibEvent:trigger("GEAR_DURABILITY_DISPLAY_CHANGED") end,
    },
    { key = "ShowInspectAngularBorder" },
    { key = "ShowInspectColoredLabel" },
    { key = "ShowCharacterItemSheet" },
    { key = "ShowInspectItemSheet",
        child = {
            { key = "ShowOwnFrameWhenInspecting" },
            { key = "ShowItemStats" },
            { key = "ShowUpgradeInfo" },
        }
    },
    { key = "EnablePartyItemLevel",
      child = {
        { key = "ShowPartySpecialization" },
        { key = "SendPartyItemLevelToSelf" },
        { key = "SendPartyItemLevelToParty" },
      }
    },
    { key = "EnableRaidItemLevel",
        checkedFunc = function() TinyInspectRaidFrame:Show() end,
        uncheckedFunc = function() TinyInspectRaidFrame:Hide() end,
    },
    { key = "EnableMouseItemLevel",
      child = {
        { key = "EnableMouseSpecialization" },
        { key = "EnableMouseWeaponLevel" },
      }
    },
}

if (GetLocale():sub(1,2) == "zh") then
    tinsert(options, { key = "ShowPluginGreenState" })
end

TinyInspectRemakeDB = DefaultDB

local function CallCustomFunc(self)
    local checked = self:GetChecked()
    if (checked and self.checkedFunc) then
        self.checkedFunc(self)
    end
    if (not checked and self.uncheckedFunc) then
        self.uncheckedFunc(self)
    end
end

local function StatusSubCheckbox(self, status)
    local checkbox
    for i = 1, self:GetNumChildren() do
        checkbox = select(i, self:GetChildren())
        if (checkbox.key) then
            checkbox:SetEnabled(status)
            StatusSubCheckbox(checkbox, status)
        end
    end
    if (status and self.SubtypeFrame) then
        self.SubtypeFrame:Show()
    elseif (not status and self.SubtypeFrame) then
        self.SubtypeFrame:Hide()
    end
end

local function OnClickCheckbox(self)
    local status = self:GetChecked()
    TinyInspectRemakeDB[self.key] = status
    StatusSubCheckbox(self, status)
    CallCustomFunc(self)
end

local function CreateSubtypeFrame(list, parent, xpos, ypos)
    if (not list) then return end
    if (not parent.SubtypeFrame) then
        parent.SubtypeFrame = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
        parent.SubtypeFrame:SetScale(0.92)
        parent.SubtypeFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", xpos or 300, ypos or 20)
        parent.SubtypeFrame:SetBackdrop({
            bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile     = true,
            tileSize = 8,
            edgeSize = 16,
            insets   = {left = 4, right = 4, top = 4, bottom = 4}
        })
        parent.SubtypeFrame:SetBackdropColor(0, 0, 0, 0.6)
        parent.SubtypeFrame:SetBackdropBorderColor(0.6, 0.6, 0.6)
        parent.SubtypeFrame.title = parent.SubtypeFrame:CreateFontString(nil, "BORDER", "GameFontNormalOutline")
        parent.SubtypeFrame.title:SetPoint("TOPLEFT", 16, -18)
        parent.SubtypeFrame.title:SetText(L[parent.key])
    end
    local checkbox
    for i, v in ipairs(list) do
        checkbox = CreateFrame("CheckButton", nil, parent.SubtypeFrame, "InterfaceOptionsCheckButtonTemplate")
        checkbox.key = parent.key .. v.key
        checkbox.checkedFunc = v.checkedFunc
        checkbox.uncheckedFunc = v.uncheckedFunc
        checkbox.Text:SetText(L[v.key])
        checkbox:SetScript("OnClick", OnClickCheckbox)
        checkbox:SetPoint("TOPLEFT", parent.SubtypeFrame, "TOPLEFT", 16, -46-(i-1)*30)
    end
    parent.SubtypeFrame:SetSize(168, #list*30+58)
end

local AnchorFrames = {}
local AnchorPoints = {
    "TOPLEFT", "LEFT", "BOTTOMLEFT",
    "TOP", "BOTTOM",
    "TOPRIGHT", "RIGHT", "BOTTOMRIGHT",
    "CENTER",
}

local function UpdateAnchorFrame(frame)
    if (not frame or not frame.anchorkey) then return end
    local anchorPoint = TinyInspectRemakeDB and TinyInspectRemakeDB[frame.anchorkey]
    for _, point in ipairs(AnchorPoints) do
        if (frame[point]) then
            frame[point]:GetNormalTexture():SetVertexColor(1, 1, 1)
        end
    end
    if (anchorPoint and frame[anchorPoint]) then
        frame[anchorPoint]:GetNormalTexture():SetVertexColor(1, 0.2, 0.1)
    end
end

local function CreateAnchorFrame(anchorInfo, parent)
    if (not anchorInfo) then return end
    if (type(anchorInfo) ~= "table") then
        anchorInfo = { key = anchorInfo }
    end
    local anchorkey = anchorInfo.key
    if (not anchorkey) then return end
    local CreateAnchorButton = function(frame, anchorPoint)
        local button = CreateFrame("Button", nil, frame)
        button.anchorPoint = anchorPoint
        button:SetSize(12, 12)
        button:SetPoint(anchorPoint)
        button:SetNormalTexture("Interface\\Buttons\\WHITE8X8")
        button:SetScript("OnClick", function(self)
            local parent = self:GetParent()
            local anchorPoint = self.anchorPoint
            TinyInspectRemakeDB[parent.anchorkey] = anchorPoint
            UpdateAnchorFrame(parent)
            LibEvent:trigger("ANCHOR_POINT_CHANGED", parent.anchorkey, anchorPoint)
        end)
        frame[anchorPoint] = button
    end
    local frame = CreateFrame("Frame", nil, parent.SubtypeFrame or parent, BackdropTemplateMixin and "BackdropTemplate" or "ThinBorderTemplate")
    frame.anchorkey = anchorkey
    frame:SetBackdrop({
            bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile     = true, tileSize = 8, edgeSize = 16,
            insets   = {left = 4, right = 4, top = 4, bottom = 4}
    })
    frame:SetBackdropColor(0, 0, 0, 0.7)
    frame:SetBackdropBorderColor(1, 1, 1, 0)
    frame:SetSize(80, 80)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", anchorInfo.xpos or 530, anchorInfo.ypos or 44)
    frame.title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    frame.title:SetPoint("BOTTOM", frame, "TOP", 0, 3)
    frame.title:SetWidth(anchorInfo.labelWidth or 100)
    frame.title:SetText(L[anchorInfo.labelKey or anchorkey])
    for _, point in ipairs(AnchorPoints) do
        CreateAnchorButton(frame, point)
    end
    UpdateAnchorFrame(frame)
    tinsert(AnchorFrames, frame)
end

local function CreateCheckbox(list, parent, anchor, offsetx, offsety)
    local checkbox, subbox
    local stepx, stepy = 20, 25
    if (not list) then return offsety end
    for i, v in ipairs(list) do
        checkbox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
        checkbox.key = v.key
        checkbox.checkedFunc = v.checkedFunc
        checkbox.uncheckedFunc = v.uncheckedFunc
        checkbox.Text:SetText(L[v.key])
        checkbox:SetScript("OnClick", OnClickCheckbox)
        checkbox:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", offsetx, -6-offsety)
        offsety = offsety + stepy
        offsety = CreateCheckbox(v.child, checkbox, anchor, offsetx+stepx, offsety)
        CreateSubtypeFrame(v.subtype, checkbox, v.subtype and v.subtype.xpos, v.subtype and v.subtype.ypos)
        if (v.anchors) then
            for _, anchorInfo in ipairs(v.anchors) do
                CreateAnchorFrame(anchorInfo, checkbox)
            end
        else
            CreateAnchorFrame(v.anchorkey, checkbox)
        end
    end
    return offsety
end

local function InitCheckbox(parent)
    local checkbox
    for i = 1, parent:GetNumChildren() do
        checkbox = select(i, parent:GetChildren())
        if (checkbox.key) then
            checkbox:SetChecked(TinyInspectRemakeDB[checkbox.key])
            StatusSubCheckbox(checkbox, checkbox:GetChecked())
            CallCustomFunc(checkbox)
            InitCheckbox(checkbox)
        end
    end
    if (parent.SubtypeFrame) then
        InitCheckbox(parent.SubtypeFrame)
    end
end

local frame = CreateFrame("Frame", nil, UIParent)
local displayName = "TinyInspect-Remake"
frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.title:SetPoint("TOPLEFT", 18, -16)
frame.title:SetText(displayName)
frame.name = displayName

CreateCheckbox(options, frame, frame.title, 18, 9)

LibEvent:attachEvent("VARIABLES_LOADED", function()
    if (not TinyInspectRemakeDB or not TinyInspectRemakeDB.version) then
        TinyInspectRemakeDB = DefaultDB
    elseif (TinyInspectRemakeDB.version <= DefaultDB.version) then
        TinyInspectRemakeDB.version = DefaultDB.version
        for k, v in pairs(DefaultDB) do
            if (TinyInspectRemakeDB[k] == nil) then
                TinyInspectRemakeDB[k] = v
            end
        end
    end
    TinyInspectRemakeDB.ShowCorruptedMark = nil
    TinyInspectRemakeDB.EnchantParts = nil
    InitCheckbox(frame)
    for _, anchorFrame in ipairs(AnchorFrames) do
        UpdateAnchorFrame(anchorFrame)
    end
end)

if InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(frame)
elseif Settings then
    local category = Settings.RegisterCanvasLayoutCategory(frame, displayName)
    frame.category = category
    Settings.RegisterAddOnCategory(category)
end

SLASH_TinyInspect1 = "/tinyinspect"
SLASH_TinyInspect2 = "/ti"
function SlashCmdList.TinyInspect(msg, editbox)
    if (msg == "raid") then
        return ToggleFrame(TinyInspectRaidFrame)
    end
    if InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(frame)
    elseif Settings then
        Settings.OpenToCategory(frame.category.ID)
    end
end
