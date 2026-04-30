
-------------------------------------
-- 物品等級顯示 Author: M
-------------------------------------
-- 兼容性补丁：防止旧版神器圣物函数报错
if not IsArtifactRelicItem then
    IsArtifactRelicItem = function(link)
        if not link then return false end
        return C_ArtifactUI and C_ArtifactUI.IsArtifactRelicItem and C_ArtifactUI.IsArtifactRelicItem(link)
    end
end

local LibEvent = LibStub:GetLibrary("LibEvent.7000")
local LibItemGem = LibStub:GetLibrary("LibItemGem.7000")
local LibSchedule = LibStub:GetLibrary("LibSchedule.7000")
local LibItemInfo = LibStub:GetLibrary("LibItemInfo.7000")

local ARMOR = ARMOR or "Armor"
local WEAPON = WEAPON or "Weapon"
local MOUNTS = MOUNTS or "Mount"
local RELICSLOT = RELICSLOT or "Relic"
local ARTIFACT_POWER = ARTIFACT_POWER or "Artifact"
if (GetLocale():sub(1,2) == "zh") then ARTIFACT_POWER = "能量" end

--fixed for 8.x
local GetLootInfoByIndex = EJ_GetLootInfoByIndex
if (C_EncounterJournal and C_EncounterJournal.GetLootInfoByIndex) then
    GetLootInfoByIndex = C_EncounterJournal.GetLootInfoByIndex
end


--fixed for 10.x
local GetContainerItemLink = GetContainerItemLink or function() end
if (C_Container and C_Container.GetContainerItemInfo) then
    GetContainerItemLink = function(bag, id)
        local info = C_Container.GetContainerItemInfo(bag, id)
        return info and info.hyperlink
    end
end

local GetItemStats = GetItemStats or C_Item.GetItemStats
local GetInventoryItemDurability = GetInventoryItemDurability

local function SafeNumber(value, fallback)
    if (type(value) ~= "number") then
        return fallback
    end
    local ok, normalized = pcall(function()
        return value + 0
    end)
    if (ok and type(normalized) == "number") then
        return normalized
    end
    return fallback
end

local function SafeGetSize(frame, fallbackW, fallbackH)
    local w, h = fallbackW, fallbackH
    if (frame and frame.GetSize) then
        local ok, fw, fh = pcall(frame.GetSize, frame)
        if (ok) then
            w = SafeNumber(fw, w)
            h = SafeNumber(fh, h)
        end
    end
    return w, h
end

local function SafeIsEquippableItem(link)
    if (not IsEquippableItem or type(link) ~= "string") then
        return false
    end
    local ok, equippable = pcall(IsEquippableItem, link)
    return ok and equippable or false
end


--框架 #category Bag|Bank|Merchant|Trade|GuildBank|Auction|AltEquipment|PaperDoll|Loot
local function GetItemLevelFrame(self, category)
    if (not self.ItemLevelFrame) then
        local fontAdjust = GetLocale():sub(1,2) == "zh" and 0 or -3
        local anchor = self.IconBorder or self
        local w, h = SafeGetSize(self, 32, 32)
        local ww, hh = SafeGetSize(anchor, w, h)
        if (ww <= 0 or hh <= 0) then
            anchor = self.Icon or self.icon or self
            w, h = SafeGetSize(anchor, w, h)
        else
            w, h = min(w, ww), min(h, hh)
        end
        if (w <= 0) then w = 32 end
        if (h <= 0) then h = 32 end
        self.ItemLevelFrame = CreateFrame("Frame", nil, self)
        self.ItemLevelFrame:SetScale(max(0.75, h<32 and h/32 or 1))
        self.ItemLevelFrame:SetFrameLevel(110)
        self.ItemLevelFrame:SetSize(w, h)
        self.ItemLevelFrame:SetPoint("CENTER", anchor, "CENTER", 0, 0)
        self.ItemLevelFrame.slotString = self.ItemLevelFrame:CreateFontString(nil, "OVERLAY")
        self.ItemLevelFrame.slotString:SetFont(STANDARD_TEXT_FONT, 10+fontAdjust, "OUTLINE")
        self.ItemLevelFrame.slotString:SetPoint("BOTTOMRIGHT", 1, 2)
        self.ItemLevelFrame.slotString:SetTextColor(1, 1, 1)
        self.ItemLevelFrame.slotString:SetJustifyH("RIGHT")
        self.ItemLevelFrame.slotString:SetWidth(30)
        self.ItemLevelFrame.slotString:SetHeight(0)
        self.ItemLevelFrame.levelString = self.ItemLevelFrame:CreateFontString(nil, "OVERLAY")
        self.ItemLevelFrame.levelString:SetFont(STANDARD_TEXT_FONT, 14+fontAdjust, "OUTLINE")
        self.ItemLevelFrame.levelString:SetPoint("TOP")
        self.ItemLevelFrame.levelString:SetTextColor(1, 0.82, 0)
        LibEvent:trigger("ITEMLEVEL_FRAME_CREATED", self.ItemLevelFrame, self)
    end
    if (TinyInspectRemakeDB and TinyInspectRemakeDB.EnableItemLevel) then
        self.ItemLevelFrame:Show()
        LibEvent:trigger("ITEMLEVEL_FRAME_SHOWN", self.ItemLevelFrame, self, category or "")
    else
        self.ItemLevelFrame:Hide()
    end
    if (category) then
        self.ItemLevelCategory = category
    end
    return self.ItemLevelFrame
end

--設置裝等文字
local function SetItemLevelString(self, text, quality, link)
    if (quality and TinyInspectRemakeDB and TinyInspectRemakeDB.ShowColoredItemLevelString) then
        local r, g, b, hex = GetItemQualityColor(quality)
        text = format("|c%s%s|r", hex, text)
    end
    self:SetText(text)
end

--設置部位文字
local function SetItemSlotString(self, class, equipSlot, link)
    local slotText = ""
    if (TinyInspectRemakeDB and TinyInspectRemakeDB.ShowItemSlotString) then
        if (equipSlot and string.find(equipSlot, "INVTYPE_") and (not link or SafeIsEquippableItem(link))) then
            slotText = _G[equipSlot] or ""
        elseif (class == ARMOR and (not link or SafeIsEquippableItem(link))) then
            slotText = class
        elseif (link and IsArtifactPowerItem(link)) then
            slotText = ARTIFACT_POWER
        elseif (link and IsArtifactRelicItem(link)) then
            slotText = RELICSLOT
        end
    end
    self:SetText(slotText)
end

--部分裝備無法一次讀取
local function SetItemLevelScheduled(button, ItemLevelFrame, link)
    if (not string.match(link, "item:(%d+):")) then return end
    LibSchedule:AddTask({
        identity  = link,
        elasped   = 1,
        expired   = GetTime() + 3,
        frame     = ItemLevelFrame,
        button    = button,
        onExecute = function(self)
            if (self.button.PendingItemLevelLink ~= self.identity) then
                return true
            end
            local count, level, _, _, quality, _, _, class, _, _, equipSlot = LibItemInfo:GetItemInfo(self.identity)
            if (count == 0) then
                SetItemLevelString(self.frame.levelString, level > 0 and level or "", quality)
                SetItemSlotString(self.frame.slotString, class, equipSlot, link)
                self.button.OrigItemLevel = (level and level > 0) and level or ""
                self.button.OrigItemQuality = quality
                self.button.OrigItemClass = class
                self.button.OrigItemEquipSlot = equipSlot
                self.button.OrigItemLink = self.identity
                self.button.PendingItemLevelLink = nil
                return true
            end
        end,
    })
end

--設置物品等級
local function SetItemLevel(self, link, category, BagID, SlotID)
    if (not self) then return end
    local frame = GetItemLevelFrame(self, category)
    if (tonumber(link)) then
        link = select(2, GetItemInfo(link))
    end
    if (not link or type(link) ~= "string" or not string.match(link, "item:(%d+):")) then
        self.PendingItemLevelLink = nil
        SetItemLevelString(frame.levelString, "")
        SetItemSlotString(frame.slotString)
        self.OrigItemLink = nil
        self.OrigItemLevel = ""
        self.OrigItemQuality = nil
        self.OrigItemClass = nil
        self.OrigItemEquipSlot = nil
        return
    end
    if (self.OrigItemLink == link) then
        SetItemLevelString(frame.levelString, self.OrigItemLevel, self.OrigItemQuality, link)
        SetItemSlotString(frame.slotString, self.OrigItemClass, self.OrigItemEquipSlot, self.OrigItemLink)
    else
        local level = ""
        local _, count, quality, class, subclass, equipSlot, linklevel
        if (link and string.match(link, "item:(%d+):")) then
            _, _, quality, _, _, class, subclass, _, equipSlot = GetItemInfo(link)
            --除了装备和圣物外,其它不显示装等
            if (((equipSlot and string.find(equipSlot, "INVTYPE_")) and SafeIsEquippableItem(link))
                or (subclass and string.find(subclass, RELICSLOT))
                or (category == "AltEquipment")) then
                count, level = LibItemInfo:GetItemInfo(link, nil, true)
            else
                count = 0
                level = ""
            end
            --坐骑还是要显示的
            if (subclass and subclass == MOUNTS) then
                class = subclass
            end
            if (count > 0) then
                self.PendingItemLevelLink = link
                SetItemLevelString(frame.levelString, "...")
                SetItemSlotString(frame.slotString)
                return SetItemLevelScheduled(self, frame, link)
            else
                self.PendingItemLevelLink = nil
                if (tonumber(level) == 0) then level = "" end
                SetItemLevelString(frame.levelString, level, quality, link)
                SetItemSlotString(frame.slotString, class, equipSlot, link)
            end
        end
        self.OrigItemLink = link
        self.OrigItemLevel = level
        self.OrigItemQuality = quality
        self.OrigItemClass = class
        self.OrigItemEquipSlot = equipSlot
    end
end

local function GetButtonBagAndSlot(button)
    if (not button) then return end
    local bag = button.bagID or button.BagID or button.bag
    if (not bag and button.GetBagID) then
        bag = button:GetBagID()
    end
    local slot = button.slot or button.slotID or button.Slot
    if (not slot and button.GetSlotID) then
        slot = button:GetSlotID()
    end
    if (not slot and button.GetID) then
        slot = button:GetID()
    end
    bag = tonumber(bag)
    slot = tonumber(slot)
    if (bag and slot) then
        return bag, slot
    end
end

local function ResolveContainerLink(button, itemIDOrLink)
    if (button and button.itemLocation and C_Item and C_Item.GetItemLink) then
        local ok, link = pcall(C_Item.GetItemLink, button.itemLocation)
        if (ok and link) then
            return link
        end
    end
    local bag, slot = GetButtonBagAndSlot(button)
    if (bag and slot) then
        local link = GetContainerItemLink(bag, slot)
        if (link) then
            return link, bag, slot
        end
    end
end

--[[ All ]]
hooksecurefunc("SetItemButtonQuality", function(self, quality, itemIDOrLink, suppressOverlays, isBound)
    if (self.ItemLevelCategory or self.isBag) then return end
    local frame = GetItemLevelFrame(self)
    if (TinyInspectRemakeDB and not TinyInspectRemakeDB.EnableItemLevelOther) then
        return frame:Hide()
    end
    
    if (itemIDOrLink) then
        local link
        --Artifact
        if (IsArtifactRelicItem(itemIDOrLink) or IsArtifactPowerItem(itemIDOrLink)) then
            SetItemLevel(self)
        --QuestInfo
        elseif (self.type and self.objectType == "item") then
            if (QuestInfoFrame and QuestInfoFrame.questLog) then
                link = LibItemInfo:GetQuestItemlink(self.type, self:GetID())
            else
                link = GetQuestItemLink(self.type, self:GetID())
            end
            -- Some quest bonus rewards  are not real item links.
            -- Falling back to numeric itemIDOrLink can resolve to unrelated equippable items.
            if (not link and type(itemIDOrLink) == "string" and string.match(itemIDOrLink, "item:(%d+):")) then
                link = itemIDOrLink
            end
            SetItemLevel(self, link)
        --EncounterJournal
        elseif (self.encounterID and self.link) then
            local itemInfo = GetLootInfoByIndex(self.index)
            SetItemLevel(self, itemInfo.link or self.link)
        --EmbeddedItemTooltip
        elseif (self.Tooltip) then
            link = select(2, self.Tooltip:GetItem())
            SetItemLevel(self, link)
        --(Bag/Bank container buttons)
        elseif (tonumber(itemIDOrLink) and (self.itemLocation or self.bagID or self.BagID or self.bag or self.slot or self.slotID or self.GetBagID or self.GetSlotID)) then
            local bag, slot
            link, bag, slot = ResolveContainerLink(self, itemIDOrLink)
            SetItemLevel(self, link, nil, bag, slot)
        else    --if (string.match(itemIDOrLink,"item:%d+:")) then
            if (type(itemIDOrLink) == "string") then
                SetItemLevel(self, itemIDOrLink)
            else
                SetItemLevel(self, nil)
            end
        end
    else
        SetItemLevelString(frame.levelString, "")
        SetItemSlotString(frame.slotString)
    end
end)

-- ALT
if (EquipmentFlyout_DisplayButton) then
    local EquipmentManager_GetLocationData = EquipmentManager_GetLocationData
    local UnpackLocation = EquipmentManager_UnpackLocation or (C_EquipmentSet and C_EquipmentSet.UnpackLocation)
    local ItemLocation = ItemLocation
    local Item = Item
    local EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION = EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION
    local function TryUnpackLocation(location)
        if (not UnpackLocation and LoadAddOn) then
            pcall(LoadAddOn, "Blizzard_EquipmentManager")
            UnpackLocation = EquipmentManager_UnpackLocation or (C_EquipmentSet and C_EquipmentSet.UnpackLocation)
        end
        if (UnpackLocation) then
            return UnpackLocation(location)
        end
    end
    local function SetItemLevelFromItemLocation(button, itemLocation)
        if (not itemLocation) then return false end
        if (C_Item and C_Item.GetItemLink) then
            local link = C_Item.GetItemLink(itemLocation)
            if (link) then
                SetItemLevel(button, link, "AltEquipment")
                return true
            end
        end
        if (Item and Item.CreateFromItemLocation) then
            local item = Item:CreateFromItemLocation(itemLocation)
            item:ContinueOnItemLoad(function()
                local link = item:GetItemLink()
                SetItemLevel(button, link, "AltEquipment")
            end)
            return true
        end
        return false
    end
    local function GetItemLocationFromButton(button)
        if (button.itemLocation) then
            return button.itemLocation
        end
        if (type(button.location) == "number"
            and (not EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION or button.location < EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION)
            and EquipmentManager_GetLocationData
            and ItemLocation
            and ItemLocation.CreateFromBagAndSlot
            and ItemLocation.CreateFromEquipmentSlot) then
            local data = EquipmentManager_GetLocationData(button.location)
            if (data) then
                if (data.isBags) then
                    return ItemLocation:CreateFromBagAndSlot(data.bag, data.slot)
                else
                    return ItemLocation:CreateFromEquipmentSlot(data.slot)
                end
            end
        end
    end
    hooksecurefunc("EquipmentFlyout_DisplayButton", function(button, paperDollItemSlot)
        local itemLocation = GetItemLocationFromButton(button)
        if (itemLocation and SetItemLevelFromItemLocation(button, itemLocation)) then
            return
        end
        local location = button.location
        if (not location) then return end
        local player, bank, bags, voidStorage, slot, bag, tab, voidSlot = TryUnpackLocation(location)
        if (not player and not bank and not bags and not voidStorage) then return end
        if (voidStorage) then
            SetItemLevel(button, nil, "AltEquipment")
        elseif (bags) then
            local link = GetContainerItemLink(bag, slot)
            SetItemLevel(button, link, "AltEquipment", bag, slot)
        else
            local link = GetInventoryItemLink("player", slot)
            SetItemLevel(button, link, "AltEquipment")
        end
    end)
end

-- GuildNews
LibEvent:attachEvent("ADDON_LOADED", function(self, addonName)
    if (addonName == "Blizzard_Communities" and GuildNewsButton_SetText) then
        GuildNewsItemCache = {}
        hooksecurefunc("GuildNewsButton_SetText", function(button, text_color, text, text1, text2, ...)
            if (not TinyInspectRemakeDB or 
                not TinyInspectRemakeDB.EnableItemLevel or 
                not TinyInspectRemakeDB.EnableItemLevelGuildNews) then
              return
            end
            if (text2 and type(text2) == "string") then
                local link = string.match(text2, "|H(item:%d+:.-)|h.-|h")
                if (link) then
                    local level = GuildNewsItemCache[link] or select(2, LibItemInfo:GetItemInfo(link))
                    if (level > 0) then
                        GuildNewsItemCache[link] = level
                        text2 = text2:gsub("(%|Hitem:%d+:.-%|h%[)(.-)(%]%|h)", "%1"..level..":%2%3")
                        button.text:SetFormattedText(text, text1, text2, ...)
                    end
                end
            end
        end)
    end
end)

-- Merchant
local function UpdateMerchantItemLevel()
    if (not TinyInspectRemakeDB
        or not TinyInspectRemakeDB.EnableItemLevel
        or not TinyInspectRemakeDB.EnableItemLevelMerchant) then
        return
    end
    if (not MerchantFrame) then return end
    local page = MerchantFrame.page or 1
    local perPage = MERCHANT_ITEMS_PER_PAGE or 12
    local numItems = GetMerchantNumItems and GetMerchantNumItems() or 0
    local buttonPool = MerchantFrame.itemButtons
        or (MerchantFrame.MerchantItemList and MerchantFrame.MerchantItemList.itemButtons)
    for i = 1, perPage do
        local index = (page - 1) * perPage + i
        local link = GetMerchantItemLink(index)
        local button = (buttonPool and buttonPool[i])
            or _G["MerchantItem"..i.."ItemButton"]
            or _G["MerchantItem"..i]
        if (button) then
            if (numItems > 0 and index <= numItems) then
                SetItemLevel(button, link, "Merchant")
            else
                SetItemLevel(button, nil, "Merchant")
            end
        end
    end
end

if (MerchantFrame_UpdateMerchantInfo) then
    hooksecurefunc("MerchantFrame_UpdateMerchantInfo", UpdateMerchantItemLevel)
end
if (MerchantFrame_Update) then
    hooksecurefunc("MerchantFrame_Update", UpdateMerchantItemLevel)
end
LibEvent:attachEvent("MERCHANT_SHOW", UpdateMerchantItemLevel)
LibEvent:attachEvent("MERCHANT_UPDATE", UpdateMerchantItemLevel)

-------------------
--   PaperDoll  --
-------------------

local CharacterPaperDollButtons = {
    CharacterHeadSlot, CharacterNeckSlot, CharacterShoulderSlot, CharacterBackSlot, CharacterChestSlot, CharacterWristSlot,
    CharacterHandsSlot, CharacterWaistSlot, CharacterLegsSlot, CharacterFeetSlot, CharacterFinger0Slot, CharacterFinger1Slot,
    CharacterTrinket0Slot, CharacterTrinket1Slot, CharacterMainHandSlot, CharacterSecondaryHandSlot
}

local function SetFrameTextAnchor(fontString, parent, anchorPoint)
    anchorPoint = anchorPoint or "BOTTOM"
    local x, y = 0, 0
    if (string.find(anchorPoint, "LEFT")) then
        x = 2
    elseif (string.find(anchorPoint, "RIGHT")) then
        x = -2
    end
    if (string.find(anchorPoint, "TOP")) then
        y = -2
    elseif (string.find(anchorPoint, "BOTTOM")) then
        y = 2
    end
    fontString:ClearAllPoints()
    fontString:SetWidth(0)
    fontString:SetPoint(anchorPoint, parent, anchorPoint, x, y)
end

local function GetDurabilityFrame(button)
    if (not button) then return end
    if (not button.TinyInspectDurabilityFrame) then
        local fontAdjust = GetLocale():sub(1,2) == "zh" and 0 or -2
        local anchor = button.IconBorder or button
        local w, h = SafeGetSize(button, 32, 32)
        local ww, hh = SafeGetSize(anchor, w, h)
        if (ww <= 0 or hh <= 0) then
            anchor = button.Icon or button.icon or button
            w, h = SafeGetSize(anchor, w, h)
        else
            w, h = min(w, ww), min(h, hh)
        end
        if (w <= 0) then w = 32 end
        if (h <= 0) then h = 32 end
        button.TinyInspectDurabilityFrame = CreateFrame("Frame", nil, button)
        button.TinyInspectDurabilityFrame:SetScale(max(0.75, h<32 and h/32 or 1))
        button.TinyInspectDurabilityFrame:SetFrameLevel(111)
        button.TinyInspectDurabilityFrame:SetSize(w, h)
        button.TinyInspectDurabilityFrame:SetPoint("CENTER", anchor, "CENTER", 0, 0)
        button.TinyInspectDurabilityFrame.text = button.TinyInspectDurabilityFrame:CreateFontString(nil, "OVERLAY")
        button.TinyInspectDurabilityFrame.text:SetFont(STANDARD_TEXT_FONT, 11+fontAdjust, "OUTLINE")
        button.TinyInspectDurabilityFrame.text:SetHeight(0)
    end
    return button.TinyInspectDurabilityFrame
end

local function ClearPaperDollDurability(button)
    local frame = button and button.TinyInspectDurabilityFrame
    if (frame and frame.text) then
        frame.text:SetText("")
    end
end

local function SetDurabilityTextColor(fontString, percentage)
    if (percentage > 66) then
        fontString:SetTextColor(0, 1, 0)
    elseif (percentage > 33) then
        fontString:SetTextColor(1, 1, 0)
    else
        fontString:SetTextColor(1, 0, 0)
    end
end

local function SetPaperDollDurability(button)
    if (not button) then return end
    if (TinyInspectRemakeDB and TinyInspectRemakeDB.ShowGearDurability == false) then
        ClearPaperDollDurability(button)
        return
    end
    if (not GetInventoryItemDurability) then return end
    local frame = GetDurabilityFrame(button)
    if (not frame or not frame.text) then return end

    local current, maxDurability = GetInventoryItemDurability(button:GetID())
    if (not current or not maxDurability or maxDurability <= 0) then
        frame.text:SetText("")
        return
    end

    local percentage = (current / maxDurability) * 100
    SetFrameTextAnchor(frame.text, frame, TinyInspectRemakeDB and TinyInspectRemakeDB.GearDurabilityAnchorPoint or "BOTTOM")
    SetDurabilityTextColor(frame.text, percentage)
    frame.text:SetFormattedText("%.0f%%", percentage)
end

local function CharacterPaperDollDurabilityUpdate()
    for _, button in ipairs(CharacterPaperDollButtons) do
        SetPaperDollDurability(button)
    end
end

local function SetPaperDollItemLevel(self, unit)
    if (not self) then return end
    local id = self:GetID()
    local frame = GetItemLevelFrame(self, "PaperDoll")
    if (unit and GetInventoryItemTexture(unit, id)) then
        local count, level, _, link, quality, _, _, class, _, _, equipSlot = LibItemInfo:GetUnitItemInfo(unit, id)
        SetItemLevelString(frame.levelString, level > 0 and level or "", quality, link)
        SetItemSlotString(frame.slotString, class, equipSlot)
        if (id == 16 or id == 17) then
            local _, mlevel, _, _, mquality = LibItemInfo:GetUnitItemInfo(unit, 16)
            local _, olevel, _, _, oquality = LibItemInfo:GetUnitItemInfo(unit, 17)
            if (mlevel > 0 and olevel > 0 and (mquality == 6 or oquality == 6)) then
                SetItemLevelString(frame.levelString, max(mlevel,olevel), mquality or oquality, link)
            end
        end
    else
        SetItemLevelString(frame.levelString, "")
        SetItemSlotString(frame.slotString)
    end
    if (unit == "player") then
        SetItemSlotString(frame.slotString)
    end
end

local function CharacterPaperDollItemUpdate()
    for _, button in ipairs(CharacterPaperDollButtons) do
        SetPaperDollItemLevel(button, "player")
    end
    CharacterPaperDollDurabilityUpdate()
end
PaperDollFrame:HookScript("OnShow", function(self)
    CharacterPaperDollItemUpdate()
end)
LibEvent:attachEvent("PLAYER_EQUIPMENT_CHANGED", function(self)
    if (CharacterFrame:IsShown()) then
        CharacterPaperDollItemUpdate()
    end
end)
LibEvent:attachEvent("UPDATE_INVENTORY_DURABILITY", function(self)
    if (CharacterFrame:IsShown()) then
        CharacterPaperDollDurabilityUpdate()
    end
end)
LibEvent:attachTrigger("GEAR_DURABILITY_DISPLAY_CHANGED", function(self)
    if (CharacterFrame:IsShown()) then
        CharacterPaperDollDurabilityUpdate()
    end
end)
LibEvent:attachTrigger("ANCHOR_POINT_CHANGED", function(self, anchorkey)
    if (anchorkey == "GearDurabilityAnchorPoint" and CharacterFrame:IsShown()) then
        CharacterPaperDollDurabilityUpdate()
    end
end)

LibEvent:attachTrigger("UNIT_INSPECT_READY", function(self, data)
    if (InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == data.guid) then
        for _, button in ipairs({
             InspectHeadSlot,InspectNeckSlot,InspectShoulderSlot,InspectBackSlot,InspectChestSlot,InspectWristSlot,
             InspectHandsSlot,InspectWaistSlot,InspectLegsSlot,InspectFeetSlot,InspectFinger0Slot,InspectFinger1Slot,
             InspectTrinket0Slot,InspectTrinket1Slot,InspectMainHandSlot,InspectSecondaryHandSlot
            -- , InspectShirtSlot, InspectTabardSlot
            }) do
            SetPaperDollItemLevel(button, InspectFrame.unit)
        end
    end
end)

LibEvent:attachEvent("ADDON_LOADED", function(self, addonName)
    if (addonName == "Blizzard_InspectUI") then
        hooksecurefunc(InspectFrame, "Hide", function()
            for _, button in ipairs({
                 InspectHeadSlot,InspectNeckSlot,InspectShoulderSlot,InspectBackSlot,InspectChestSlot,InspectWristSlot,
                 InspectHandsSlot,InspectWaistSlot,InspectLegsSlot,InspectFeetSlot,InspectFinger0Slot,InspectFinger1Slot,
                 InspectTrinket0Slot,InspectTrinket1Slot,InspectMainHandSlot,InspectSecondaryHandSlot
                 , InspectShirtSlot, InspectTabardSlot
                }) do
                SetPaperDollItemLevel(button)
            end
        end)
    end
end)

----------------------
--  Chat ItemLevel  --
----------------------

local Caches = {}

local function ShouldShowChatItemLevel(link, class, subclass, equipSlot)
    return (((equipSlot and string.find(equipSlot, "INVTYPE_")) and SafeIsEquippableItem(link))
        or (subclass and string.find(subclass, RELICSLOT)))
end

local function ChatItemLevel(Hyperlink)
    local originalHyperlink = Hyperlink
    if (Caches[originalHyperlink]) then
        return Caches[originalHyperlink]
    end
    local link = string.match(Hyperlink, "|H(.-)|h")
    local displayText = string.match(Hyperlink, "|h%[(.-)%]|h")
    local count, level, name, _, quality, _, _, class, subclass, _, equipSlot = LibItemInfo:GetItemInfo(link)
    if (tonumber(level) and level > 0 and ShouldShowChatItemLevel(link, class, subclass, equipSlot)) then
        if (equipSlot == "INVTYPE_CLOAK" or equipSlot == "INVTYPE_TRINKET" or equipSlot == "INVTYPE_FINGER" or equipSlot == "INVTYPE_NECK") then
            level = format("%s(%s)", level, _G[equipSlot] or equipSlot)
        elseif (equipSlot and string.find(equipSlot, "INVTYPE_")) then
            level = format("%s(%s-%s)", level, subclass or "", _G[equipSlot] or equipSlot)
        elseif (class == ARMOR) then
            level = format("%s(%s-%s)", level, subclass or "", class)
        elseif (subclass and string.find(subclass, RELICSLOT)) then
            level = format("%s(%s)", level, RELICSLOT)
        else
            level = nil
        end
        if (level) then
            local n, stats = 0, GetItemStats(link) or {}
            for key, num in pairs(stats) do
                if (string.find(key, "EMPTY_SOCKET_")) then
                    n = n + num
                end
            end
            local gem = string.rep("|TInterface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic:0|t", n)
            if (quality == 6 and class == WEAPON) then gem = "" end
            Hyperlink = Hyperlink:gsub("|h%[(.-)%]|h", "|h["..level..":"..(displayText or name or "").."]|h"..gem)
        end
    elseif (subclass and subclass == MOUNTS) then
        Hyperlink = Hyperlink:gsub("|h%[(.-)%]|h", "|h[("..subclass..")%1]|h")
    end
    if (count == 0) then
        Caches[originalHyperlink] = Hyperlink
    end
    return Hyperlink
end

local function filter(self, event, msg, ...)
    if (TinyInspectRemakeDB and TinyInspectRemakeDB.EnableItemLevelChat) then
        msg = msg:gsub("(|Hitem:%d+:.-|h.-|h)", ChatItemLevel)
    end
    return false, msg, ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", filter)

--[[据说首次拾取大秘钥匙是个item:180653:
function firstLootKeystone(Hyperlink)
    local map, level = string.match(Hyperlink, "|Hitem:180653::::::::%d*:%d*:%d*:%d*:%d*:(%d+):(%d+):")
    if (map and level) then
        local name = C_ChallengeMode.GetMapUIInfo(map)
        if name then
            Hyperlink = Hyperlink:gsub("|h%[(.-)%]|h", "|h["..format(CHALLENGE_MODE_KEYSTONE_HYPERLINK, name, level).."]|h")
        end
    end
    return Hyperlink
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", function(self, event, msg, ...)
    if (string.find(msg, "item:180653:")) then
        msg = msg:gsub("(|Hitem:180653:.-|h.-|h)", firstLootKeystone)
    end
    return false, msg, ...
end)
]]

-- 位置設置
LibEvent:attachTrigger("ITEMLEVEL_FRAME_SHOWN", function(self, frame, parent, category)
    if (TinyInspectRemakeDB and not TinyInspectRemakeDB["EnableItemLevel"..category]) then
        return frame:Hide()
    end
    if (TinyInspectRemakeDB and TinyInspectRemakeDB.PaperDollItemLevelOutsideString) then
        return
    end
    local anchorPoint = TinyInspectRemakeDB and TinyInspectRemakeDB.ItemLevelAnchorPoint
    if (frame.anchorPoint ~= anchorPoint) then
        frame.anchorPoint = anchorPoint
        frame.levelString:ClearAllPoints()
        frame.levelString:SetPoint(anchorPoint or "TOP")
    end
end)

-- OutsideString For PaperDoll ItemLevel
LibEvent:attachTrigger("ITEMLEVEL_FRAME_CREATED", function(self, frame, parent)
    if (TinyInspectRemakeDB and TinyInspectRemakeDB.PaperDollItemLevelOutsideString) then
        local name = parent:GetName()
        if (name and string.match(name, "^[IC].+Slot$")) then
            local id = parent:GetID()
            frame:ClearAllPoints()
            frame.levelString:ClearAllPoints()
            if (id <= 5 or id == 9 or id == 15 or id == 19) then
                frame:SetPoint("LEFT", parent, "RIGHT", 7, -1)
                frame.levelString:SetPoint("TOPLEFT")
                frame.levelString:SetJustifyH("LEFT")
            elseif (id == 17) then
                frame:SetPoint("LEFT", parent, "RIGHT", 5, 1)
                frame.levelString:SetPoint("TOPLEFT")
                frame.levelString:SetJustifyH("LEFT")
            elseif (id == 16) then
                frame:SetPoint("RIGHT", parent, "LEFT", -5, 1)
                frame.levelString:SetPoint("TOPRIGHT")
                frame.levelString:SetJustifyH("RIGHT")
            else
                frame:SetPoint("RIGHT", parent, "LEFT", -7, -1)
                frame.levelString:SetPoint("TOPRIGHT")
                frame.levelString:SetJustifyH("RIGHT")
            end
        end
    end
end)
