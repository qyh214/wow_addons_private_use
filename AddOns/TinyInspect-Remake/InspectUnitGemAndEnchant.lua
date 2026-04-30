
-------------------------------------
-- 顯示寶石和附魔信息
-- @Author: M
-- @DepandsOn: InspectUnit.lua
-------------------------------------

local addon, ns = ...

local LibItemGem = LibStub:GetLibrary("LibItemGem.7000")
local LibSchedule = LibStub:GetLibrary("LibSchedule.7000")
local LibItemEnchant = LibStub:GetLibrary("LibItemEnchant.7000")

local GetItemInfo = GetItemInfo or C_Item.GetItemInfo
local CItemRequestLoadItemDataByID = C_Item and C_Item.RequestLoadItemDataByID

local DEFAULT_ENCHANT_ICON = 7548963
local ENCHANT_ICON_BY_ID = {
    [7934] = 5931426, -- 阳炎丝绸魔线 (1星)
    [7935] = 5931426, -- 阳炎丝绸魔线 (2星)
    [7936] = 5931153, -- 奥纹魔线 (1星)
    [7937] = 5931153, -- 奥纹魔线 (2星)
    [7938] = 5931150, -- 光明亚麻魔线 (1星)
    [7939] = 5931150, -- 光明亚麻魔线 (2星)
    [8158] = 7549196, -- 森林猎手护甲片 (1星)
    [8159] = 7549196, -- 森林猎手护甲片 (2星)
    [8160] = 7549218, -- 萨拉斯斥候护甲片 (1星)
    [8161] = 7549218, -- 萨拉斯斥候护甲片 (2星)
    [8162] = 7549219, -- 血骑士护甲片 (1星)
    [8163] = 7549219, -- 血骑士护甲片 (2星)
}

local DK_RUNE_ICON_BY_ID = {
    [3368] = 135882, -- 堕落十字军
    [3370] = 135842, -- 冰封符文 (冰锋符文)
    [3847] = 237480, -- 岩肤石像鬼
    [6241] = 1778226, -- 鲜红符文
    [6242] = 425952, -- 护咒符文
    [6244] = 3163621, -- 无尽渴求符文
    [6245] = 237535, -- 天启符文
}

local ENCHANT_SLOT_NAMES = {
    [1]  = "HEADSLOT",
    [3]  = "SHOULDERSLOT",
    [5]  = "CHESTSLOT",
    [7]  = "LEGSSLOT",
    [8]  = "FEETSLOT",
    [11] = "FINGER0SLOT",
    [12] = "FINGER1SLOT",
    [16] = "MAINHANDSLOT",
    [17] = "SECONDARYHANDSLOT",
}

local function GetEnchantIcon(enchantID, isDeathKnight)
    if (isDeathKnight and enchantID and DK_RUNE_ICON_BY_ID[enchantID]) then
        return DK_RUNE_ICON_BY_ID[enchantID]
    end
    if (enchantID and ENCHANT_ICON_BY_ID[enchantID]) then
        return ENCHANT_ICON_BY_ID[enchantID]
    end
    return DEFAULT_ENCHANT_ICON
end

local function GetItemIDFromLink(itemLink)
    if (type(itemLink) == "string") then
        return tonumber(string.match(itemLink, "item:(%d+):"))
    end
    return nil
end

--創建圖標框架
local function CreateIconFrame(frame, index)
    local icon = CreateFrame("Button", nil, frame)
    icon.index = index
    icon:Hide()
    icon:SetSize(16, 16)
    icon:SetScript("OnEnter", function(self)
        if (self.itemLink) then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(self.itemLink)
            GameTooltip:Show()
        elseif (self.spellID) then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(self.spellID)
            GameTooltip:Show()
        elseif (self.title) then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.title)
            GameTooltip:Show()
        end
    end)
    icon:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    icon:SetScript("OnDoubleClick", function(self)
        if (self.itemLink or self.title) then
            ChatEdit_ActivateChat(ChatEdit_ChooseBoxForSend())
            ChatEdit_InsertLink(self.itemLink or self.title)
        end
    end)
    icon.bg = icon:CreateTexture(nil, "BACKGROUND")
    icon.bg:SetSize(16, 16)
    icon.bg:SetPoint("CENTER")
    icon.bg:SetTexture("Interface\\AddOns\\"..addon.."\\texture\\GemBg")
    icon.texture = icon:CreateTexture(nil, "BORDER")
    icon.texture:SetSize(12, 12)
    icon.texture:SetPoint("CENTER")
    icon.texture:SetMask("Interface\\FriendsFrame\\Battlenet-Portrait")
    frame["xicon"..index] = icon
    return frame["xicon"..index]
end

--隱藏所有圖標框架
local function HideAllIconFrame(frame)
    local index = 1 
    while (frame["xicon"..index]) do
        frame["xicon"..index].title = nil
        frame["xicon"..index].itemLink = nil
        frame["xicon"..index].spellID = nil
        frame["xicon"..index]:Hide()
        index = index + 1
    end
    LibSchedule:RemoveTask("InspectGemAndEnchant", true)
end

--獲取可用的圖標框架
local function GetIconFrame(frame)
    local index = 1
    while (frame["xicon"..index]) do
        if (not frame["xicon"..index]:IsShown()) then
            return frame["xicon"..index]
        end
        index = index + 1
    end
    return CreateIconFrame(frame, index)
end

--執行圖標更新
local function onExecute(self)
    local _, itemLink, quality, _, _, _, _, _, _, texture = GetItemInfo(self.data)
    if (texture) then
        local r, g, b = GetItemQualityColor(quality or 0)
        self.icon.bg:SetVertexColor(r, g, b)
        self.icon.texture:SetTexture(texture)
        if (not self.icon.itemLink) then
            self.icon.itemLink = itemLink
        end
        return true
    end
end

--Schedule模式更新圖標
local function UpdateIconTexture(icon, texture, data)
    if (not texture) then
        if (CItemRequestLoadItemDataByID) then
            local itemID = type(data) == "number" and data or GetItemIDFromLink(data)
            if (itemID) then
                CItemRequestLoadItemDataByID(itemID)
            end
        end
        LibSchedule:AddTask({
            identity  = "InspectGemAndEnchant" .. icon.index,
            timer     = 0,
            elasped   = 0.2,
            expired   = GetTime() + 12,
            onExecute = onExecute,
            icon      = icon,
            data      = data,
        })
    end
end

--讀取並顯示圖標
local function ShowGemAndEnchant(frame, ItemLink, anchorFrame, itemframe, isDeathKnight)
    if (not ItemLink) then return 0 end
    local num, info, qty = LibItemGem:GetItemGemInfo(ItemLink)
    local _, quality, texture, icon, r, g, b
    for i, v in ipairs(info) do
        icon = GetIconFrame(frame)
        if (v.link) then
            _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(v.link)
            r, g, b = GetItemQualityColor(quality or 0)
            icon.bg:SetVertexColor(r, g, b)
            icon.texture:SetTexture(texture or "Interface\\Cursor\\Quest")
            UpdateIconTexture(icon, texture, v.link)
        else
            icon.bg:SetVertexColor(1, 0.82, 0, 0.5)
            icon.texture:SetTexture("Interface\\Cursor\\Quest")
        end
        icon.title = v.name
        icon.itemLink = v.link
        icon:ClearAllPoints()
        icon:SetPoint("LEFT", anchorFrame, "RIGHT", i == 1 and 6 or 1, 0)
        icon:Show()
        anchorFrame = icon
    end
    local enchantItemID, enchantID = LibItemEnchant:GetEnchantItemID(ItemLink)
    local enchantSpellID = LibItemEnchant:GetEnchantSpellID(ItemLink)
    local enchantSlotName = ENCHANT_SLOT_NAMES[itemframe.index]
    if (enchantItemID) then
        num = num + 1
        icon = GetIconFrame(frame)
        _, ItemLink = GetItemInfo(enchantItemID)
        icon.bg:SetVertexColor(1, 0.82, 0)
        icon.texture:SetTexture(GetEnchantIcon(enchantID, isDeathKnight))
        icon.itemLink = ItemLink or ("item:" .. enchantItemID)
        icon:ClearAllPoints()
        icon:SetPoint("LEFT", anchorFrame, "RIGHT", num == 1 and 6 or 1, 0)
        icon:Show()
        anchorFrame = icon
    elseif (enchantSpellID) then
        num = num + 1
        icon = GetIconFrame(frame)
        icon.bg:SetVertexColor(1,0.82,0)
        icon.texture:SetTexture(GetEnchantIcon(enchantID, isDeathKnight))
        icon.spellID = enchantSpellID
        icon:ClearAllPoints()
        icon:SetPoint("LEFT", anchorFrame, "RIGHT", num == 1 and 6 or 1, 0)
        icon:Show()
        anchorFrame = icon
    elseif (enchantID) then
        num = num + 1
        icon = GetIconFrame(frame)
        icon.title = "#" .. enchantID
        icon.bg:SetVertexColor(1, 0.82, 0)
        icon.texture:SetTexture(GetEnchantIcon(enchantID, isDeathKnight))
        icon:ClearAllPoints()
        icon:SetPoint("LEFT", anchorFrame, "RIGHT", num == 1 and 6 or 1, 0)
        icon:Show()
        anchorFrame = icon
    elseif (not enchantID and enchantSlotName) then
        if (qty == 6 and (itemframe.index==2 or itemframe.index==16 or itemframe.index==17)) then else
            num = num + 1
            icon = GetIconFrame(frame)
            icon.title = ENCHANTS .. ": " .. (_G[enchantSlotName] or enchantSlotName)
            icon.bg:SetVertexColor(1, 0.2, 0.2, 0.6)
            icon.texture:SetTexture("Interface\\Cursor\\Quest") --QuestRepeatable
            icon:ClearAllPoints()
            icon:SetPoint("LEFT", anchorFrame, "RIGHT", num == 1 and 6 or 1, 0)
            icon:Show()
            anchorFrame = icon
        end
    end
    return num * 18
end

--功能附着
hooksecurefunc("ShowInspectItemListFrame", function(unit, parent, itemLevel, maxLevel)
    local frame = parent.inspectFrame
    if (not frame) then return end
    if (TinyInspectRemakeDB and TinyInspectRemakeDB.ShowGemAndEnchant) then
        local _, class = UnitClass(unit)
        local isDeathKnight = (class == "DEATHKNIGHT")
        local i = 1
        local itemframe
        local width, iconWidth = frame:GetWidth(), 0
        HideAllIconFrame(frame)
        while (frame["item"..i]) do
            itemframe = frame["item"..i]
            iconWidth = ShowGemAndEnchant(frame, itemframe.link, itemframe.itemString, itemframe, isDeathKnight)
            if (width < itemframe.width + iconWidth + 36) then
                width = itemframe.width + iconWidth + 36
            end
            i = i + 1
        end
        if (width > frame:GetWidth()) then
            frame:SetWidth(width)
        end
    else
        HideAllIconFrame(frame)
    end
end)
