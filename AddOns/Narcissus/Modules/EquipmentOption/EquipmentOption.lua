local _, addon = ...

local EnchantDataProvider = addon.EnchantDataProvider;
local GemDataProvider = addon.GemDataProvider;

local L = Narci.L;

local DataProvider = GemDataProvider;

local MainFrame, Tooltip, ButtonHighlight;

local BUTTON_HEIGHT = 48;
local MAX_VISIBLE_BUTTONS = 4;
local TOOLTIP_PADDING = 12;

local TOOLTIP_PREFIX;
if UnitLevel("player") < 60 then
    TOOLTIP_PREFIX  = string.format(L["At Level"], 60).." ";
else
    TOOLTIP_PREFIX = "";
end

local GetSpellDescription = GetSpellDescription;
local GetItemSpell = GetItemSpell;

local gsub = string.gsub;

local tinsert = table.insert;
local tremove = table.remove;

local FadeFrame = NarciFadeUI.Fade;
local IsItemDominationShard = NarciAPI.IsItemDominationShard;
local RemoveColorString = NarciAPI.RemoveColorString;
local GetCachedItemTooltipTextByLine = NarciAPI.GetCachedItemTooltipTextByLine;

local sin = math.sin;
local cos = math.cos;
local pi = math.pi;
local pow = math.pow;
local floor = math.floor;


local function inOutSine(t, b, e, d)
	return (b - e) / 2 * (cos(pi * t / d) - 1) + b
end

local function outSine(t, b, e, d)
	return (e - b) * sin(t / d * (pi / 2)) + b
end

local function outQuart(t, b, e, d)
    t = t / d - 1;
    return (b - e) * (pow(t, 4) - 1) + b
end

local animFrame = CreateFrame("Frame");
animFrame.duration = 0.5;
animFrame:Hide();
animFrame:SetScript("OnUpdate", function(self, elapsed)
    self.t = self.t + elapsed;
    local offsetX;
    if self.t > self.duration then
        offsetX = self.toX;
        self:Hide();
    else
        offsetX = outQuart(self.t, self.fromX, self.toX, self.duration);
    end
    self.object:SetPoint("TOPRIGHT", self.objectAnchor, "TOPRIGHT", offsetX, 0);
end);

function animFrame:In()
    self.t = 0;
    local _;
    _, _, _, self.fromX = self.object:GetPoint();
    self.toX = 0;
    self:Show();
end

function animFrame:Out()
    self.t = 0;
    local _;
    _, _, _, self.fromX = self.object:GetPoint();
    self.toX = 48;
    self:Show();
end


local function SetButtonEnchant(button, ...)
    button:SetEnchantData(...);
end

local function SetButtonGem(button, ...)
    button:SetGemData(...);
end

local function SetButtonShard(button, ...)
    button:SetDominationShardData(...);
end

SetButtonData = SetButtonEnchant;


local ViewUpdator = {};
ViewUpdator.buttons = {};
ViewUpdator.b = 0;

function ViewUpdator:WipeButtonData()
    for _, button in pairs(self.buttons) do
        button:WipeData();
    end
end

function ViewUpdator:UpdateVisibleArea(offsetY, forcedUpdate)
    if forcedUpdate then
        for i = 1, self.numButtons do
            self.buttons[i]:SetPoint("TOPLEFT", 0, -(self.b + i - 1) * BUTTON_HEIGHT);
            SetButtonData(self.buttons[i], DataProvider:GetDataByIndex(i + self.b));
        end
        MainFrame:StopAnimating();
    else
        local b = floor( offsetY / BUTTON_HEIGHT + 0.5) - 1;
        if b ~= self.b then --last offset
            local buttons = self.buttons;
            if b > self.b then
                local topButton = tremove(buttons, 1);
                tinsert(buttons, topButton);
            else
                local bottomButton = tremove(buttons);
                tinsert(buttons, 1, bottomButton);
            end
            for i = 1, self.numButtons do
                buttons[i]:SetPoint("TOPLEFT", 0, -(b + i - 1) * BUTTON_HEIGHT);
                SetButtonData(buttons[i], DataProvider:GetDataByIndex(i + b));
            end
            self.b = b;
        end
    end
end

function ViewUpdator:FindFocusedButton()
    if not MainFrame:IsMouseOver(0, 0, 0, -8) then
        return
    end
    for _, button in pairs(self.buttons) do
        if button:IsMouseOver() then
            if button:IsVisible() then
                return button;
            end
            break
        end
    end
end


local buttonData = {
    {1030900, "AUCTION_HOUSE_FILTER_CATEGORY_EQUIPMENT", 1},
    {136244, "ENCHANTS", 2},
    {134071, "AUCTION_CATEGORY_GEMS", 3},
};



NarciEquipmentListFilterButtonMixin = {};

function NarciEquipmentListFilterButtonMixin:OnLoad()
    self:OnLeave();
    self:SetLabelText("Owned");
    self.needUpdate = true;
end

function NarciEquipmentListFilterButtonMixin:OnEnter()
    self.Label:SetTextColor(0.92, 0.92, 0.92);
    self.Square:SetVertexColor(0.8, 0.8, 0.8);
    self.Check:SetVertexColor(1, 1, 1);
end

function NarciEquipmentListFilterButtonMixin:OnLeave()
    self.Label:SetTextColor(0.5, 0.5, 0.5);
    self.Square:SetVertexColor(0.5, 0.5, 0.5);
    self.Check:SetVertexColor(0.8, 0.8, 0.8);
end

function NarciEquipmentListFilterButtonMixin:OnShow()
    if self.needUpdate then
        self.needUpdate = nil;
        self:UpdateState();
    end
    self.FlyUp:Play();
    self.Label.FadeIn:Play();
end

function NarciEquipmentListFilterButtonMixin:OnClick()
    NarcissusDB.OnlyShowOwnedUpgradeItem = not NarcissusDB.OnlyShowOwnedUpgradeItem;
    self:UpdateState();
    MainFrame:UpdateCurrentList();
end

function NarciEquipmentListFilterButtonMixin:UpdateState()
    local isEnabled = NarcissusDB.OnlyShowOwnedUpgradeItem;
    self.Check:SetShown(isEnabled);
    if isEnabled and self:IsVisible() then
        self.Check.AnimIn:Play();
    end
end

function NarciEquipmentListFilterButtonMixin:SetLabelText(text)
    self.Label:SetText(text);
    local width = self.Label:GetWidth();
    if width < 72 then
        width = 72;
    end
    self:SetWidth(width);
    self.Shadow:SetWidth(width + 24);
end


NarciEquipmentOptionMixin = CreateFromMixins(NarciAnimatedSizingFrameMixin);

function NarciEquipmentOptionMixin:SetAnchor(object, direction)
    self.Pointer:ClearAllPoints();
    if direction == "LEFT" then
        self.Pointer:SetTexCoord(0.25, 0.5, 0.25, 0.5);
        self.PointerBackdrop:SetTexCoord(0.5, 0.75, 0.25, 0.5);
        self.Pointer:SetPoint("CENTER", self, "TOPRIGHT", 0, -24);
    elseif direction == "RIGHT" then
        self.Pointer:SetTexCoord(0.5, 0.25, 0.25, 0.5);
        self.PointerBackdrop:SetTexCoord(0.75, 0.5, 0.25, 0.5);
        self.Pointer:SetPoint("CENTER", self, "TOPLEFT", 0, -24);
    elseif direction == "TOP" then
        self.Pointer:SetTexCoord(0.25, 0.5, 0.5, 0.75);
        self.PointerBackdrop:SetTexCoord(0.5, 0.75, 0.5, 0.75);
        self.Pointer:SetPoint("CENTER", self, "BOTTOM", 0, 0);
    elseif direction == "BOTTOM" then
        self.Pointer:SetTexCoord(0.25, 0.5, 0.75, 0.5);
        self.PointerBackdrop:SetTexCoord(0.5, 0.75, 0.75, 0.5);
        self.Pointer:SetPoint("CENTER", self, "TOP", 0, 0);
    else
        self.Pointer:Hide();
        self.PointerBackdrop:Hide();
        return
    end
    self.Pointer:Show();
    self.PointerBackdrop:Show();
end

function NarciEquipmentOptionMixin:SetBackdropColor(r, g, b, alpha)
    alpha = alpha or 1;
    self.Backdrop:SetColorTexture(r, g, b, alpha);
    self.PointerBackdrop:SetVertexColor(r, g, b, alpha);
end

function NarciEquipmentOptionMixin:SetFromSlotButton(slotButton)
    self.slotButton = slotButton;
    self.slotID = slotButton.slotID;
    self.isDominationItem = slotButton.isDominationItem;

    self:SetPoint("TOPLEFT", slotButton, "TOPRIGHT", -2, -12);
    self:SetAlpha(0);
    FadeFrame(self, 0.15, 1);
    Narci_EquipmentFlyoutFrame:Hide();
    Narci_FlyoutBlack:In();
    Narci:HideButtonTooltip();

    local equipmentTable = {};
    GetInventoryItemsForSlot(self.slotID, equipmentTable);
    local numEquipment = 0;
    for location, hyperlink in pairs(equipmentTable) do
        numEquipment = numEquipment + 1;
    end
    equipmentTable = nil;

    EnchantDataProvider:SetSubset(self.slotID);
    GemDataProvider:SetSubset();
end

function NarciEquipmentOptionMixin:OnLoad()
    MainFrame = self;

    self.maxHeight = BUTTON_HEIGHT * (MAX_VISIBLE_BUTTONS + 0.5);
    self:SetBackdropColor(0, 0, 0);
    self:SetBorderColor(0.5, 0.5, 0.5);
    self:SetFrameSize(240, 48 * 3);
    self:SetAnchor(nil, "LEFT");
    self:Init();

    animFrame.object = self.ArtFrame.Stain;
    animFrame.objectAnchor = self.ArtFrame;
end

function NarciEquipmentOptionMixin:Init()
    self.ItemList.NoItemText:SetText(L["No Item Alert"]);
    local button;
    for i = 1, 3 do
        button = CreateFrame("Button", nil, self.Menu, "NarciEquipmentOptionButtonTemplate");
        button:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -48 * (i - 1));
        button.Icon:SetTexture(buttonData[i][1]);
        button:SetButtonText(_G[buttonData[i][2]]);
        button.type = buttonData[i][3];
    end

    NarciAPI.CreateSmoothScroll(self.ItemList);
    self.ItemList:SetStepSize(48);
    self.ItemList:SetOnValueChangedFunc(function(value)
        ViewUpdator:UpdateVisibleArea(value);
    end);
    self.ItemList:SetOnResetFunc(function()
        ViewUpdator:WipeButtonData();
        ViewUpdator:UpdateVisibleArea(0, true);
    end);
    self.ItemList:SetOnScrollStartedFunc(function()
        Tooltip:ClearAllPoints();
        Tooltip:FadeOut();
    end);
    self.ItemList:SetOnScrollFinishedFunc(function()
        local focusedButton = ViewUpdator:FindFocusedButton();
        if focusedButton then
            Tooltip:AnchorToButton(focusedButton);
        end
    end);
    self.ItemList:SetScript("OnMouseUp", function(f, mouseButton)
        if mouseButton == "RightButton" then
            self:ShowMenu();
        end
    end);
end

function NarciEquipmentOptionMixin:ShowMenu()
    animFrame:In();
    self.Menu:Show();
    self.ItemList:Hide();
    self:StopAnimating();
    self:AnimateSize(240, 3*BUTTON_HEIGHT, 0.25);
end

function NarciEquipmentOptionMixin:ShowEquipment()
    Narci_EquipmentFlyoutFrame:SetItemSlot(self.slotButton, true);
    FadeFrame(self, 0.12, 0);
end

function NarciEquipmentOptionMixin:ShowItemList(listType)
    if self.CreateList then
        self:CreateList();
    end
    animFrame:Out();
    self.Menu:Hide();
    self.ItemList:Show();
    if listType ~= self.listType then
        self.listType = listType;
        self.ItemList:SetOffset(0);
    end
    self:UpdateCurrentList();
end

function NarciEquipmentOptionMixin:ShowGemList()
    DataProvider = GemDataProvider;
    if self.isDominationItem then
        SetButtonData = SetButtonShard;
    else
        SetButtonData = SetButtonGem;
    end
    self:ShowItemList("gem");
end

function NarciEquipmentOptionMixin:ShowEnchantList()
    DataProvider = EnchantDataProvider;
    SetButtonData = SetButtonEnchant;
    self:ShowItemList("enchant");
end

function NarciEquipmentOptionMixin:ShowTempUpgradeList()

end

function NarciEquipmentOptionMixin:UpdateCurrentList(resetOffset)
    local numItems = DataProvider:ApplyFilter(NarcissusDB.OnlyShowOwnedUpgradeItem);
    if numItems > 4 then
        self.ItemList:SetScrollRange(BUTTON_HEIGHT*(numItems - MAX_VISIBLE_BUTTONS - 0.5));
        self:AnimateSize(240, BUTTON_HEIGHT * 4.5, 0.25);
    else
        self.ItemList:SetScrollRange(0);
    end
    self.ItemList.NoItemText:SetShown(numItems == 0);
    if resetOffset then
        self.ItemList:SetOffset(0);
    end
    self.ItemList:Reset();
end

function NarciEquipmentOptionMixin:CreateList()
    local numButtons = 6;
    for i = 1, numButtons do
        local button = CreateFrame("Button", nil, self.ItemList.ScrollChild, "NarciEquipmentEnchantButtonTemplate");
        button:SetPoint("TOPLEFT", self.ItemList.ScrollChild, "TOPLEFT", 0, -48*(i-1));
        tinsert(ViewUpdator.buttons, button);
    end
    ViewUpdator.numButtons = numButtons;
    self.CreateList = nil;
end

NarciEquipmentOptionButtonMixin = {};

function NarciEquipmentOptionButtonMixin:OnLoad()
    self:OnLeave();
end

function NarciEquipmentOptionButtonMixin:OnEnter()
    --FadeFrame(self.BorderLeft, 0.5, 0.5);
    --FadeFrame(self.BorderRight, 0.5, 0.5);
    --self.Highlight.Anim:Play();
    self:SetAlpha(1);
end

function NarciEquipmentOptionButtonMixin:OnLeave()
    --FadeFrame(self.BorderLeft, 0.5, 0.25);
    --FadeFrame(self.BorderRight, 0.5, 0.25);
    --self.Highlight.Anim:Stop();
    self:SetAlpha(0.8);
end

function NarciEquipmentOptionButtonMixin:OnMouseDown()
    self.AnimPushed:Stop();
    self.AnimPushed.Hold:SetDuration(20);
    self.AnimPushed:Play();
end

function NarciEquipmentOptionButtonMixin:OnMouseUp()
    self.AnimPushed.Hold:SetDuration(0);
end

function NarciEquipmentOptionButtonMixin:OnClick()
    if MainFrame.CreateList then
        MainFrame:CreateList();
    end
    if self.type == 1 then
        MainFrame:ShowEquipment();
    elseif self.type == 2 then
        MainFrame:ShowEnchantList();
    elseif self.type == 3 then
        MainFrame:ShowGemList();
    elseif self.type == 4 then
        MainFrame:ShowTempUpgradeList();
    end
end

function NarciEquipmentOptionButtonMixin:SetButtonText(text1, text2)
    self.Text1:SetText(text1);
    self.Text2:SetText(text2);

    if text2 then
        self.Text1:ClearAllPoints();
        self.Text1:SetPoint("BOTTOMLEFT", self.Icon, "RIGHT", 6, 1);
        self.Text1:SetJustifyV("BOTTOM");
        self.Text1:SetMaxLines(1);
        if text1 then
            self.Text2:Show();
        end
    else
        self.Text2:Hide();
        if text1 then
            self.Text1:ClearAllPoints();
            self.Text1:SetPoint("LEFT", self.Icon, "RIGHT", 6, 0);
            self.Text1:SetJustifyV("MIDDLE");
            self.Text1:SetMaxLines(2);
        end
    end
end



NarciEquipmentListTooltipMixin = CreateFromMixins(NarciAnimatedSizingFrameMixin);

function NarciEquipmentListTooltipMixin:OnLoad()
    Tooltip = self;
    self.ClipFrame.Description:SetPoint("TOPLEFT", self, "TOPLEFT", TOOLTIP_PADDING, -TOOLTIP_PADDING);
    self.duration = 0;
    self:SetBackdropColor(0.08, 0.08, 0.08, 0.9);
end

function NarciEquipmentListTooltipMixin:OnHide()
    self:SetScript("OnUpdate", nil);
    self:UnregisterEvent("SPELL_DATA_LOAD_RESULT");
    self:SetAlpha(0);
end

function NarciEquipmentListTooltipMixin:SetSpell(spellID)
    self.spellID = spellID;
    self.itemID = nil;
    if not spellID then
        self:Hide();
    end
    local text = GetSpellDescription(spellID);
    local f = self.ClipFrame;
    if text and text ~= "" then
        --text = gsub(text, "(%d[%d,%%]*)","|cffFFFFFF%1|r");   --Make numbers green
        text = TOOLTIP_PREFIX..text;
        f.Description:SetSize(0, 0);
        f.Description:SetText(text);
        f.Icon:Show();
        f.Description:Show();
        self:UpdateSize();
        self:OnDataReceived();
    else
        f.Description:Hide();
        f.Icon:Hide();
        self:LoadSpell(spellID);
    end
    self:FadeIn();
end

function NarciEquipmentListTooltipMixin:OnDataReceived()
    self.pendingID = nil;
    self:UnregisterEvent("SPELL_DATA_LOAD_RESULT");
    self:UnregisterEvent("ITEM_DATA_LOAD_RESULT");
    self.ClipFrame.LoadingIndicator:Hide();
    if not self.ClipFrame.Description:IsShown() then
        self.ClipFrame.Description.FadeIn:Play();
        self.ClipFrame.Description:Show();
    end
end

function NarciEquipmentListTooltipMixin:UpdateSize()
    local f = self.ClipFrame;
    local textWidth = math.min(f.Description:GetWidth(), 240 - 2*TOOLTIP_PADDING);
    f.Description:SetWidth(textWidth + 0.2);
    textWidth = f.Description:GetWrappedWidth();
    local textHeight = f.Description:GetHeight();
    local frameHeight = textHeight + 2*TOOLTIP_PADDING;
    self:AnimateSize(textWidth + 2*TOOLTIP_PADDING, frameHeight);
    f.Icon:SetSize(frameHeight, frameHeight);
end

function NarciEquipmentListTooltipMixin:SetItem(itemID)
    self.itemID = itemID;
    self.spellID = nil;
    if itemID then
        if not C_Item.IsItemDataCachedByID(itemID) then
            self:LoadItem(itemID);
            self:FadeIn();
            return
        end
        local name, spellID = GetItemSpell(itemID);
        if spellID then
            self:SetSpell(spellID);
        else
            local line;
            if IsItemDominationShard(itemID) then
                line = 5;
            else
                line = 3;
            end
            self.ClipFrame.Description:SetSize(0, 0);
            local tooltipText, isCached = GetCachedItemTooltipTextByLine(itemID, line, function(newText)
                if self.itemID == itemID and self:IsTurningVisible() then
                    self:SetItem(itemID);
                end
            end);
            if isCached then
                self.ClipFrame.Description:SetText(RemoveColorString(tooltipText));
                self:OnDataReceived();
            else
                self.ClipFrame.Description:Hide();
                self:StartLoading();
            end
            self.pendingID = nil;
            self:UpdateSize();
            self:FadeIn();
        end
    else
        self:Hide();
    end
end

function NarciEquipmentListTooltipMixin:OnEvent(event, ...)
    if event == "SPELL_DATA_LOAD_RESULT" then
        local spellID, success = ...
        if spellID == self.pendingID and success then
            self:SetSpell(spellID);
        end
    elseif event == "ITEM_DATA_LOAD_RESULT" then
        local itemID, success = ...
        if itemID == self.pendingID and success then
            self:SetItem(itemID);
        end
    end
end

function NarciEquipmentListTooltipMixin:StartLoading()
    self.ClipFrame.LoadingIndicator.Rotate:Play();
    self.ClipFrame.LoadingIndicator:Show();
end

function NarciEquipmentListTooltipMixin:LoadSpell(spellID)
    C_Spell.RequestLoadSpellData(spellID);
    self:UnregisterEvent("ITEM_DATA_LOAD_RESULT")
    self:RegisterEvent("SPELL_DATA_LOAD_RESULT");
    self.pendingID = spellID;
    self:StartLoading();
end

function NarciEquipmentListTooltipMixin:LoadItem(itemID)
    C_Item.RequestLoadItemDataByID(itemID);
    self:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    self:UnregisterEvent("SPELL_DATA_LOAD_RESULT");
    self.pendingID = itemID;
    self:StartLoading();
end

function NarciEquipmentListTooltipMixin:FadeIn()
    self.turningVisible = true;
    FadeFrame(self, 0.15, 1);
end

function NarciEquipmentListTooltipMixin:FadeOut()
    self.turningVisible = false;
    FadeFrame(self, 0.2, 0);
end

function NarciEquipmentListTooltipMixin:IsTurningVisible()
    return self.turningVisible
end

function NarciEquipmentListTooltipMixin:OnShow()

end

function NarciEquipmentListTooltipMixin:AnchorToButton(button)
    self:ClearAllPoints();
    self:SetPoint("TOPLEFT", button, "TOPRIGHT", 4, 0);
    self.ClipFrame.Icon:SetTexture(button.Icon:GetTexture());
    if self:IsShown() then
        self.duration = 0.25;
     else
         self.duration = 0;
     end
    if button.spellID then
        self:SetSpell(button.spellID);
    elseif button.itemID then
        self:SetItem(button.itemID);
    else
        return
    end
end