local L = Narci.L;
local GetItemQualityColor = NarciAPI.GetItemQualityColor;
local Narci_GemInfo = Narci_GemInfo;
local GetGemBonus = NarciAPI.GetGemBonus; --(Gem's itemID or hyperlink)
local max = math.max;
local min = math.min;
local floor = math.floor;
local format = string.format;

--[[ Blizzard APIs:
PickupItem(item)            --Place the item on the cursor
ClickSocketButton(id)       --Put the picked-up item into SocketButton
CursorHasItem()
GetCursorInfo()
GetItemCount(item)
GetContainerNumSlots(bagID) 0-4
GetContainerItemID(bag, slot)
SocketInventoryItem(slot)

Item:CreateFromItemID(itemID)
local itemLocation = ItemLocation:CreateFromEquipmentSlot(slotId)
ItemMixin:GetItemLocation()
ItemLocationMixin:GetBagAndSlot
PlaySound(SOUNDKIT.JEWEL_CRAFTING_FINALIZE);

Events:

ITEM_UNLOCKED
ITEM_LOCK_CHANGED

local function GetBagPosition(itemLink)
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            if(GetContainerItemLink(bag, slot) == itemLink) then
                return bag, slot
            end
        end
    end
end

local GemBorderTexture = {
	[1]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Unique",
	[2]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Green",
	[3]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Unique",
	[4]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Unique",
	[5]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Orange",
	[6]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Purple",
    [7]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Yellow",
	[8]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Blue",	
	[9]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot",
	[10] = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Unique",
	[11] = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot",
}
--]]

local ItemBorderTexture = {
    [1] = {0,     0.125},        --Krazken
    [2] = {0.75,  0.875},        --Green
    [3] = {0.875,     1},        --White
    [4] = {0.875,     1},        --Meta
    [5] = {0.125,  0.25},        --Orange
    [6] = {0.5,   0.625},        --Purple
    [7] = {0.25,  0.375},        --Yellow
    [8] = {0.375,   0.5},        --Blue
    [9] = {0.875,     1},        --White
    [10] = {0.625,  0.75},       --Red
}

local GetGemBorderTexture = NarciAPI.GetGemBorderTexture

local function GetBorderTexCoord(itemSubClassID, itemID)
    local _, index = GetGemBorderTexture(itemSubClassID, itemID);
    return ItemBorderTexture[index][1], ItemBorderTexture[index][2];
end

local function ShowFlyoutBlack(bool)
    if Narci_EquipmentFlyoutFrame:IsShown() then return; end
	Narci_FlyoutBlack.AnimFrame:Hide();
	Narci_FlyoutBlack.AnimFrame.OppoDirection = not bool;
	Narci_FlyoutBlack.AnimFrame:Show();
end

local GemIDList, GemTypesByID = {}, {};

local GetContainerItemID = GetContainerItemID;
local GetItemCount = GetItemCount;
local numBags = NUM_BAG_SLOTS;
local FadeFrame = NarciAPI_FadeFrame;

local function StatAbbreviationToFullForm(abbr)
    if abbr == "crit" then
        abbr = NARCI_CRITICAL_STRIKE;
    elseif abbr == "haste" then
        abbr = STAT_HASTE;
    elseif abbr == "versatility" then
        abbr = STAT_VERSATILITY;
    elseif abbr == "mastery" then
        abbr = STAT_MASTERY;
    elseif abbr == "EXP" then
        abbr = POWER_TYPE_EXPERIENCE;
    elseif abbr == "MSPD" then
        abbr = STAT_MOVEMENT_SPEED;
    elseif abbr == "STR" then
        abbr = NARCI_STAT_STRENGTH;
    elseif abbr == "AGI" then
        abbr = NARCI_STAT_AGILITY;
    elseif abbr == "INT" then
        abbr = SPEC_FRAME_PRIMARY_STAT_INTELLECT;
    end
    return abbr;
end

for GemID, info in pairs(Narci_GemInfo) do
    tinsert(GemIDList, GemID);
    GemTypesByID[GemID] = StatAbbreviationToFullForm(info[1]);
end

local function SortedByID(a, b) return a > b; end
table.sort(GemIDList, SortedByID);

local GemCountList = {};
local BUTTON_HEIGHT = 48 --buttons[1] and buttons[1]:GetHeight()
local NUM_BUTTONS_PER_PAGE = 4;
local hasCounted = false;   --Only calculate once, until a Socketing succeed event fires
local function GetTypeCount(CheckList)
    local count = 0;
    local i = 0;
    for k, itemID in pairs(CheckList) do
        count = GetItemCount(itemID);
        if count ~= 0 then
            i = i + 1;
        end
    end
    return i;
end

local function GetMatchCount(CheckList, OutputList)
    wipe(OutputList);
    local count = 0;
    local i = 1;
    local types = {};
    for k, itemID in pairs(CheckList) do
        count = GetItemCount(itemID);
        if count ~= 0 then
            OutputList[i] = {itemID, count};
            if i < 3 then
                tinsert(types, GemTypesByID[itemID] );
            end
            i = i + 1;
        end
    end
    
    return (i - 1), types[1], types[2]
end

local function AjustShadowHeight(frame, numButtons)
    local tex = frame.Shadow; 
    if numButtons == 1 then
        tex:SetTexCoord(0, 0.37109375, 0.75, 1);
    elseif numButtons == 2 then
        tex:SetTexCoord(0.62890625, 1, 0.625, 1);
    elseif numButtons == 3 then
        tex:SetTexCoord(0.62890625, 1, 0, 0.5);
    elseif numButtons == 4 then
        tex:SetTexCoord(0, 0.37109375, 0, 0.671875);
    elseif numButtons == 0 then
        tex:SetTexCoord(0, 0, 0, 0);
    else
        tex:SetTexCoord(0, 0.37109375, 0, 0.671875);
    end
end

local SocektedItemLvl = 1208;    --the ilvl of the item that's currently being socketed
local function DisplayButtons(itemCountList, disabledID, rootFrame, buttonTemplate)
    local texCoord1, texCoord2, button, itemID, count, bonus, minLevel;
    local rootFrame = rootFrame or Narci_ItemSocketing;
    local scrollchild = rootFrame.ScrollFrame.scrollChild or Narci_ItemSocketing.ScrollFrame.scrollChild;
    local buttonTemplate = buttonTemplate or "Narci_GearEnhancement_Template"
    if not rootFrame.buttons then
        rootFrame.buttons = {};
    end
    local buttons = rootFrame.buttons;
    local numGems = #itemCountList;
    local numMax = max(#buttons, numGems);
    for i = 1, numMax do
        button = buttons[i];
        if not button then
            button = CreateFrame("BUTTON", nil, scrollchild, buttonTemplate);
            button.index = i;
            if i == 1 then
                button:SetPoint("TOPLEFT", scrollchild, "TOPLEFT", 0 , 0);
                button.TopDivider:Hide();
            else
                button:SetPoint("TOPLEFT", buttons[i-1], "BOTTOMLEFT", 0 , 0);
            end
            tinsert(buttons, button);
        end

        if i == numMax then button.BottomDivider:Hide(); end
        
        if i > numGems then
            button:Hide();
        else
            itemID = itemCountList[i][1];
            count = itemCountList[i][2];
            local _, _, _, _, icon, _, itemSubClassID = GetItemInfoInstant(itemID);
            local name = C_Item.GetItemNameByID(itemID);
            local quality = C_Item.GetItemQualityByID(itemID);
            local r, g, b = GetItemQualityColor(quality);
            button.r, button.g, button.b = r, g, b;
            button.GemID = itemID;
            button.ColorID = itemSubClassID;
            button.ItemName:SetText(name);
            button.Icon:SetTexture(icon);
            button.Icon2:SetTexture(icon);
            button.Icon3:SetTexture(icon);
            button.Count:SetText(count);
            bonus, minLevel = GetGemBonus(itemID);
            button.Bonus:SetText(bonus);

            texCoord1, texCoord2 = GetBorderTexCoord(itemSubClassID, itemID);
            button.Border0:SetTexCoord(texCoord1, texCoord2, 0, 0.5);
            button.Border1:SetTexCoord(texCoord1, texCoord2, 0.5, 1);
            if itemID == disabledID or (minLevel and minLevel > SocektedItemLvl) then
                --Irrelevent Item Alpha
                button.ItemName:SetTextColor(0.44, 0.44, 0.44, 1);
                button:Disable();
            else
                button.ItemName:SetTextColor(r, g, b, 1);
                button:Enable();
            end
            button:Show();
        end
    end

    --Scroll Frame
    local ScrollFrame = rootFrame.ScrollFrame;

    local range = max( (numGems- NUM_BUTTONS_PER_PAGE - 0.35)*BUTTON_HEIGHT, 0);
    local numButtons = NUM_ACTIVE_BUTTONS;

    local scrollBar = ScrollFrame.scrollBar;
    scrollBar:SetMinMaxValues(0, range);
    ScrollFrame.range = range;
    scrollBar:SetShown(range ~= 0);
    local TotalButtons = min(numGems, NUM_BUTTONS_PER_PAGE + 0.4);
    rootFrame:SetHeight(TotalButtons*BUTTON_HEIGHT);
    AjustShadowHeight(rootFrame, TotalButtons);
end

local function GetBagPosition(itemID)
    for bagID = 0, numBags do
        for slotID = 1, GetContainerNumSlots(bagID) do
            if(GetContainerItemID(bagID, slotID) == itemID) then
                return bagID, slotID
            end
        end
    end
end

local function AutoSocket(slotID, GemID)
    --local item = Item:CreateFromItemID(itemID)
    ClearCursor()
    if not slotID or not GemID then return; end
    local bagID, slotIndex = GetBagPosition(GemID);

    if not(bagID and slotIndex) then return; end
    PickupContainerItem(bagID, slotIndex);
    SocketInventoryItem(slotID);
    ClickSocketButton(1);
    AcceptSockets();
    ClearCursor();
    --CloseSocketInfo();
end

local function UpdateInnerShadowStates(self)
	local currValue = self:GetValue();
    local minVal, maxVal = self:GetMinMaxValues();
    
	if ( currValue >= maxVal -20) then
		self.BottomShadow:Hide();
    else
        self.BottomShadow:Show();
    end
    
	if ( currValue <= minVal +20) then
		self.TopShadow:Hide();
    else
        self.TopShadow:Show();
	end
end

function Narci_ItemSocketing_ScrollFrame_OnLoad(self)
    local TabHeight = BUTTON_HEIGHT;
    local TotalTab = 5;
    local TotalHeight = floor(TotalTab * TabHeight + 0.5);
    local MaxScroll = floor((TotalTab-1) * TabHeight + 0.5);
    self.buttonHeight = TotalHeight;
    self.range = MaxScroll;
    self.scrollBar:SetScript("OnValueChanged", function(self, value)
        --HybridScrollFrame_SetOffset(self:GetParent(), value);
        self:GetParent():SetVerticalScroll(value);
        UpdateInnerShadowStates(self);
    end)
    NarciAPI_SmoothScroll_Initialization(self, nil, nil, 1/(TotalTab), 0.14, 0.4);      --(self, updatedList, updateFunc, deltaRatio, timeRatio, minOffset) 
end


function Narci_ItemSocketing_Succeed()
    FadeFrame(Narci_ItemSocketing, 0.5, "OUT");
    ShowFlyoutBlack(false);
    HideUIPanel(ItemSocketingFrame);
    Narci_ItemSocketing_GemFrame.Flare.Rotate:Play();
    PlaySound(84378);
    C_Timer.After(0.25, function()
        local slot = Narci_ItemSocketing.anchorSlot;
        slot:Refresh();
        hasCounted = false;
    end)
end

NarciGemListButtonMixin = {};

function NarciGemListButtonMixin:OnEnter()
    UIFrameFadeIn(self.Icon3, 0.12, self.Icon3:GetAlpha(), 0.66);
end

function NarciGemListButtonMixin:OnLeave()
    UIFrameFadeIn(self.Icon3, 0.2, self.Icon3:GetAlpha(), 0);
end

function NarciGemListButtonMixin:OnClick()

end

function NarciGemListButtonMixin:ConfirmSocketing()
    local slot = Narci_ItemSocketing.anchorSlot;
    local slotID = slot:GetID();
    if not slotID then return; end

    Narci_ItemSocketing:RegisterEvent("UI_ERROR_MESSAGE");
    Narci_AlertFrame_Autohide:SetAnchor(Narci_ItemSocketing_GemFrame, -14, true);
    AutoSocket(slotID, self.GemID);
end

function NarciGemListButtonMixin:OnDoubleClick()
    self:ConfirmSocketing()
    --self.ButtonHighlight.animQuickFill:Play();
    self.ButtonFill.animFill:Stop();
end

function NarciGemListButtonMixin:OnMouseDown()
    if self:IsEnabled() then
        self.ButtonFill.animFill:Play();
    end
end

function NarciGemListButtonMixin:OnMouseUp()
    self.ButtonFill.animFill:Stop();
end

--------------------------------------
--[[
local Finder = CreateFrame("Frame")
Finder:RegisterEvent("ITEM_LOCKED");
Finder:RegisterEvent("SOCKET_INFO_UPDATE");
Finder:RegisterEvent("SOCKET_INFO_CLOSE");
Finder:RegisterEvent("SOCKET_INFO_BIND_CONFIRM");
Finder:RegisterEvent("SOCKET_INFO_ACCEPT");
Finder:RegisterEvent("SOCKET_INFO_SUCCESS");
Finder:RegisterEvent("SOCKET_INFO_FAILURE");
Finder:RegisterEvent("ADDON_LOADED");
Finder:SetScript("OnEvent", function(self,event,...)
    print(event)
    if event == "ITEM_LOCKED" then
        local bagOrSlotIndex, slotIndex = ...;
        if slotIndex ~= nil then
            --print("bag: "..bagOrSlotIndex.."  slotIndex: "..slotIndex)
        else
            --print("bag: "..bagOrSlotIndex)
        end
    end
end)
--]]


---------------------------------------
NarciGemSlotMixin = {};

function NarciGemSlotMixin:CountGems()
    local numGems, type1, type2 = GetMatchCount(GemIDList, GemCountList);
    self.numGems = numGems;
    return numGems, type1, type2;
end

function NarciGemSlotMixin:OnEnter()
    if Narci_ItemSocketing:IsShown() then
		return;
    end
    local link = self:GetParent().GemLink;
    local tooltip = Narci_GearEnhancement_Tooltip;

    --Show optional gem types in your inventory
    local numGems, type1, type2 = GetMatchCount(GemIDList, GemCountList);
    self.numGems = numGems;

    local text;     --Show how many types of gems in bags
    if numGems > 0 then
        if numGems == 1 then
            text = type1;
        else
            if type1 == type2 then
                type1 = type1.."+";    --Greater +40/+30 Versa
            end
            if numGems == 2 then
                text = format( L["Gem Tooltip Format1"], type1, type2);
            elseif numGems > 2 then
                text = format( L["Gem Tooltip Format2"], type1, type2, (numGems - 2) );
            end
        end
        tooltip.OtherGems.Text:SetText(text);
        tooltip.OtherGems:Show();
    else
        tooltip.OtherGems:Hide();
    end

    local _, bonus, name, quality, icon;
    if link then
        bonus = GetGemBonus(link);
        name, _, quality, _, _, _, _, _, _, icon = GetItemInfo(link);
    else
        bonus = text or L["No Available Gem"];
        tooltip.OtherGems:Hide();
        name = EMPTY;
        quality = 0;
        icon = 458977;
    end

	local r, g, b = GetItemQualityColor(quality);

	tooltip.ArtFrame.Icon:SetTexture(icon);
	tooltip.ArtFrame.ItemName:SetText(name);
	tooltip.ArtFrame.ItemName:SetTextColor(r, g, b);
	tooltip.ArtFrame.Bonus:SetText(bonus);

	tooltip:ClearAllPoints();
	tooltip:SetParent(self);
	tooltip:SetFrameStrata("TOOLTIP");

	if self:GetParent().isRight then
		tooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", 1, 10);
	else
		tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", -1, 10);
	end

    tooltip:SetMouseMotionEnabled(false);
	FadeFrame(tooltip, 0.15, "IN");
end


function NarciGemSlotMixin:OnLeave()
    FadeFrame(Narci_GearEnhancement_Tooltip, 0.25, "OUT");
end

function NarciGemSlotMixin:OnClick()
    local frame = Narci_ItemSocketing;
    local GemFrame = Narci_ItemSocketing_GemFrame;
    frame.anchorSlot = self:GetParent();
    if frame:IsShown() then
        frame:Hide();
        ShowFlyoutBlack(false);
        HideUIPanel(ItemSocketingFrame);
    else
        SocektedItemLvl= self.ItemLevel;
        if self.numGems == 0 then return; end;
        DisplayButtons(GemCountList, self.ItemID);
        frame:ClearAllPoints();
        GemFrame:ClearAllPoints();
        --local scale = self:GetEffectiveScale();
        --frame:SetScale(scale);
        --GemFrame:SetScale(scale); 
        frame:SetParent(Narci_Character);
        GemFrame:SetParent(Narci_Character);   
        frame:SetFrameLevel(20);
        GemFrame:SetPoint("CENTER", self, "CENTER");
        GemFrame.GemBorder:SetTexture(self.GemBorder:GetTexture());
        GemFrame.GemIcon:SetTexture(self.GemIcon:GetTexture());
        if self.isRight then
            frame:SetPoint("TOPRIGHT", self, "TOPLEFT", 1 ,10);
            GemFrame.GemBorder:SetTexCoord(1, 0, 0, 1);
            GemFrame.Bling:SetTexCoord(0.5, 0, 0, 1);
            GemFrame.GemIcon:SetPoint("CENTER", self, "CENTER", -3, 0);
        else
            frame:SetPoint("TOPLEFT", self, "TOPRIGHT", -1 ,10);
            GemFrame.GemBorder:SetTexCoord(0, 1, 0, 1);
            GemFrame.Bling:SetTexCoord(0, 0.5, 0, 1);
            GemFrame.GemIcon:SetPoint("CENTER", self, "CENTER", 3, 0);
        end
        frame:SetAlpha(1);
        frame:Show();
        GemFrame:SetFrameStrata("TOOLTIP");
        GemFrame:Show();
        ShowFlyoutBlack(true);
        FadeFrame(Narci_GearEnhancement_Tooltip, 0.15, "OUT");
    end
    Narci:HideButtonTooltip();
end

function Narci_ItemSocketing_Close()
    Narci_ItemSocketing:Hide();
    ShowFlyoutBlack(false);
    HideUIPanel(ItemSocketingFrame);
end
---------------------------------------------
--------For Blizzard ItemSocketing UI--------
---------------------------------------------
local currentSocketingItemLink;
local currentSocketingItemGemID = 1208;

local function GetCurrentSocketingItem(bag, slot)
    local itemlocation;
    if not bag then
        itemlocation = ItemLocation:CreateFromEquipmentSlot(slot);
    else
        itemlocation = ItemLocation:CreateFromBagAndSlot(bag, slot);
    end
    return C_Item.GetItemLink(itemlocation);
end

local function GetCurrentGemID(itemLink, gemIndex)
    if not itemLink then return; end
    local index = gemIndex or 1;
    local _, gemLink = GetItemGem(itemLink, index);
    if not gemLink or type(gemLink) ~= "string" then return; end
    local itemID = GetItemInfoInstant(gemLink)
    return itemID;
end

function Narci_ItemSocketing_OnEvent(self, event, ...)
    local buttons = self.buttons;
    if not buttons then return; end
    local button, count, id;
    C_Timer.After(0.6, function()
        for i = 1, #buttons do
            button = buttons[i]
            id = button.GemID
            if not id then return; end
            count = GetItemCount(id);
            button.Count:SetText(count);
            if count == 0 then
                --Irrelevent Item Alpha
                button:Disable();
            end
        end
    end)
end

function Narci_OptionalGems_OnClick(self)
    if not self.GemID then return; end
    ClearCursor();
    local bagID, slotIndex = GetBagPosition(self.GemID);
    if not(bagID and slotIndex) then return; end
    PickupContainerItem(bagID, slotIndex);
    ClickSocketButton(1)
    ClearCursor();
end

hooksecurefunc("SocketInventoryItem", function(slot)
    currentSocketingItemLink = GetCurrentSocketingItem(nil, slot)
end)

hooksecurefunc("SocketContainerItem", function(bag, slot)
    currentSocketingItemLink = GetCurrentSocketingItem(bag, slot)
end)

hooksecurefunc("ItemSocketingFrame_LoadUI", function(name)
    if not Narci_Character or Narci_Character:IsShown() or not NarcissusDB or not NarcissusDB.GemManager then return; end
    local frame;
    if not Narci_ItemSocketing_ForBlizzardUI then
        frame = CreateFrame("Frame", "Narci_ItemSocketing_ForBlizzardUI", ItemSocketingFrame, "Narci_ItemSocketing_ForBlizzardUI_Template")
    end
    frame = Narci_ItemSocketing_ForBlizzardUI;
    if frame:IsShown() then return; end
    GetMatchCount(GemIDList, GemCountList)
    if #GemCountList == 0 then return; end
    DisplayButtons(GemCountList, 1208, frame, "Narci_OptionalGems_Template")
    C_Timer.After(0.5, function()
        currentSocketingItemGemID = GetCurrentGemID(currentSocketingItemLink)
        DisplayButtons(GemCountList, currentSocketingItemGemID, frame, "Narci_OptionalGems_Template")
    end)
    frame:SetAlpha(1)
    frame:ClearAllPoints();
    frame:SetPoint("TOPLEFT", ItemSocketingFrame, "TOPRIGHT", 4 ,0)
    local UIScale = UIParent:GetEffectiveScale()
    frame:SetScale(math.max(UIScale, 0.75));
    frame:Show();
end)

