local _, addon = ...;

local MainFrame, ScrollFrame, Tooltip, ButtonHighlight, ActionButton;

local FadeFrame = NarciFadeUI.Fade;
local GetEnchantText = NarciAPI.GetEnchantTextByEnchantID;
local GetItemQualityColor = NarciAPI.GetItemQualityColor;
local GetGemBonus = NarciAPI.GetGemBonus;
local GetShardBonus = NarciAPI.GetDominationShardBonus;

local GetSpellInfo = GetSpellInfo;
local GetSpellDescription = GetSpellDescription;
local GetItemCount = GetItemCount;
local GetItemIcon = GetItemIcon;
local GetItemInfo = GetItemInfo;
local IsMouseButtonDown = IsMouseButtonDown;

local EventListener = CreateFrame("Frame");
EventListener.t = 0;
EventListener:SetScript("OnEvent", function(self, event, ...)
    if event == "SPELL_DATA_LOAD_RESULT" then
        local spellID, success = ...
        if self.spellQueue[spellID] and success then
            for _, button in pairs(self.spellQueue[spellID]) do
                if button.spellID == spellID then
                    self.spellQueue[spellID] = nil;
                    local name = GetSpellInfo(spellID);
                    button.Text1:SetText(name);
                    button:ShowLoadingIcon(false);
                    button.itemName = name;
                    break
                end
            end
        end
    elseif event == "ITEM_DATA_LOAD_RESULT" then
        local itemID, success = ...
        if self.itemQueue[itemID] and success then
            for _, button in pairs(self.itemQueue[itemID]) do
                if button.itemID == itemID then
                    self.itemQueue[itemID] = nil;
                    local quality = C_Item.GetItemQualityByID(itemID);
                    local r, g, b = GetItemQualityColor(quality);
                    button.Text2:SetTextColor(r, g, b, 1);
                    if not button:IsEnabled() then
                        button.Text2:SetVertexColor(0.5, 0.5, 0.5);
                    end
                    local name = GetItemInfo(itemID);
                    if button.isShard then
                        button:SetButtonText(GetShardBonus(itemID), name);
                    else
                        button:SetButtonText(GetGemBonus(itemID), name);
                    end
                    button:ShowLoadingIcon(false);
                    button.itemName = name;
                    break
                end
            end
        end
    end
end);

local function EventListener_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    if self.t >= 0.5 then
        local numEnchants = 0;
        for enchantID, object in pairs(self.enchantQueue) do
            numEnchants = numEnchants + 1;
            object[2] = object[2] + 0.5;
            if object[2] >= 0.5 then
                object[2] = 0;
                if object[1]:SetEnchantText(enchantID) or object[3] > 3 then
                    numEnchants = numEnchants - 1;
                    self.enchantQueue[enchantID] = nil;
                else
                    object[3] = object[3] + 1;
                end
            end
        end
        if numEnchants <= 0 then
            self:SetScript("OnUpdate", nil);
            self.t = 0;
        end
    end
end

function EventListener:AddEnchant(enchantID, button)
    if not self.enchantQueue then
        self.enchantQueue = {};
    end
    self.enchantQueue[enchantID] = {button, 0, 0};  --{button, duration, repeat}
    self:SetScript("OnUpdate", EventListener_OnUpdate);
end

function EventListener:AddSpell(spellID, button)
    if not self.spellQueue then
        self.spellQueue = {};
    end
    if not self.spellQueue[spellID] then
        self.spellQueue[spellID] = {};
    end
    tinsert(self.spellQueue[spellID], button);
    C_Spell.RequestLoadSpellData(spellID);
    self:RegisterEvent("SPELL_DATA_LOAD_RESULT");
end

function EventListener:AddItem(itemID, button)
    if not self.itemQueue then
        self.itemQueue = {};
    end
    if not self.itemQueue[itemID] then
        self.itemQueue[itemID] = {};
    end
    tinsert(self.itemQueue[itemID], button);
    C_Item.RequestLoadItemDataByID(itemID);
    self:RegisterEvent("ITEM_DATA_LOAD_RESULT");
end

function EventListener:Wipe()
    if self.itemQueue then
        wipe(self.itemQueue);
    end
    if self.enchantQueue then
        wipe(self.enchantQueue);
    end
    if self.spellQueue then
        wipe(self.spellQueue);
    end
    self:UnregisterEvent("ITEM_DATA_LOAD_RESULT");
    self:UnregisterEvent("SPELL_DATA_LOAD_RESULT");
    self:SetScript("OnUpdate", nil);
end


local function AssignWidgets()
    MainFrame = Narci_EquipmentOption;
    ActionButton = NarciEquipmentOptionActionButton;
    ScrollFrame = MainFrame.ItemList;
    Tooltip = ScrollFrame.Tooltip;
end


NarciEquipmentEnchantButtonMixin = {};

function NarciEquipmentEnchantButtonMixin:OnLoad()
    if AssignWidgets then
        AssignWidgets();
        AssignWidgets = nil;
    end
    self:OnEnable();
end

function NarciEquipmentEnchantButtonMixin:OnEnter()
    --FadeFrame(self.BorderLeft, 0.5, 0.5);
    --FadeFrame(self.BorderRight, 0.5, 0.5);
    ButtonHighlight:SetParentButton(self);
    --self.Highlight.Anim:Play();
    --self:SetAlpha(1);
    if self:IsEnabled() then
        self.Icon:SetVertexColor(1, 1, 1);
    else
        self.Icon:SetVertexColor(0.72, 0.72, 0.72);
    end
    if not ScrollFrame:IsScrolling() then
        if not IsMouseButtonDown() then
            if not ScrollFrame:ScrollToWidget(self) then
                Tooltip:AnchorToButton(self);
            end
        end
    end
end

function NarciEquipmentEnchantButtonMixin:OnLeave()
    --FadeFrame(self.BorderLeft, 0.5, 0.25);
    --FadeFrame(self.BorderRight, 0.5, 0.25);
    ButtonHighlight:Hide();
    --self.Highlight.Anim:Stop();
    if self:IsEnabled() then
        self.Icon:SetVertexColor(0.8, 0.8, 0.8);
        --self:SetAlpha(0.8);
    else
        self.Icon:SetVertexColor(0.5, 0.5, 0.5);
        --self:SetAlpha(0.8);
    end
    Tooltip:FadeOut();
end

function NarciEquipmentEnchantButtonMixin:OnEnable()
    self.Icon:SetDesaturation(0);
    self.Text1:SetTextColor(0.920, 0.920, 0.920);
    self.ItemCount:SetTextColor(0.920, 0.920, 0.920);
    self.IconBorder:SetVertexColor(1, 1, 1);
    self.Icon:SetVertexColor(0.8, 0.8, 0.8);
    self.Text2:SetAlpha(1);
end

function NarciEquipmentEnchantButtonMixin:OnDisable()
    self.Icon:SetDesaturation(0.5);
    self.Text1:SetTextColor(0.6, 0.6, 0.6);
    self.ItemCount:SetTextColor(1, 0.33, 0.33);
    self.IconBorder:SetVertexColor(0.5, 0.5, 0.5);
    self.Icon:SetVertexColor(0.5, 0.5, 0.5);
    self.Text2:SetAlpha(0.6);
end

function NarciEquipmentOptionButtonMixin:OnMouseDown()
    self.AnimPushed:Stop();
    self.AnimPushed.Hold:SetDuration(20);
    self.AnimPushed:Play();
end

function NarciEquipmentEnchantButtonMixin:OnMouseUp(button)
    self.AnimPushed.Hold:SetDuration(0);
    if button == "RightButton" then
        MainFrame:ShowMenu();
    end
end

function NarciEquipmentEnchantButtonMixin:OnClick()
    ActionButton:InitFromButton(self);
end

function NarciEquipmentEnchantButtonMixin:ShowLoadingIcon(state)
    if state then
        self.LoadingIndicator:Show();
        self.LoadingIndicator.Rotate:Play();
    else
        self.LoadingIndicator:Hide();
        self.LoadingIndicator.Rotate:Stop();
    end
end

function NarciEquipmentEnchantButtonMixin:SetButtonText(text1, text2)
    self.Text1:SetText(text1);
    self.Text2:SetText(text2);

    if text2 then
        self.Text1:ClearAllPoints();
        self.Text1:SetPoint("BOTTOMLEFT", self.Icon, "RIGHT", 7, 1);
        self.Text1:SetJustifyV("BOTTOM");
        self.Text1:SetMaxLines(1);
        if text1 then
            self.Text2:Show();
        end
    else
        self.Text2:Hide();
        if text1 then
            self.Text1:ClearAllPoints();
            self.Text1:SetPoint("LEFT", self.Icon, "RIGHT", 7, 0);
            self.Text1:SetJustifyV("MIDDLE");
            self.Text1:SetMaxLines(2);
        end
    end
end

function NarciEquipmentEnchantButtonMixin:SetEnchantData(spellID, itemID, enchantID, iconFileID)
    if spellID ~= self.spellID then
        self.spellID = spellID;
    else
        if not spellID then
            self:Hide();
        end
        return
    end
    self.isShard = nil;

    if spellID then
        self.itemID = itemID;
        self:SetItemCount(itemID);
        self.Icon:SetTexture(iconFileID or 463531);
        self.Text2:SetTextColor(0.5, 0.5, 0.5);
        local name = GetSpellInfo(spellID);
        local enchantText = GetEnchantText(enchantID);
        if not enchantText then
            EventListener:AddEnchant(enchantID, self);
        end
        if name and name ~= "" then
            if name == enchantText then
                enchantText = nil;
            end
            self.itemName = name;
            self:SetButtonText(name, enchantText);
            self:ShowLoadingIcon(false);
        else
            EventListener:AddSpell(spellID, self);
            self:ShowLoadingIcon(true);
        end
        self:Show();
    else
        self:Hide();
    end
end

function NarciEquipmentEnchantButtonMixin:SetItemCount(itemID)
    if itemID then
        local count = GetItemCount(itemID);
        if count > 0 then
            self:Enable();
            self:OnEnable();
        else
            self:Disable();
            self:OnDisable();
        end
        self.ItemCount:SetText(count);
        self.ItemCount:Show();
        self.ItemCountBackdrop:Show();
    else
        self.ItemCount:Hide();
        self.ItemCountBackdrop:Hide();
    end
end

function NarciEquipmentEnchantButtonMixin:SetEnchantText(enchantID)
    if not self.spellID then
        return
    end

    local name = GetSpellInfo(self.spellID);
    local enchantText = GetEnchantText(enchantID);
    if name and name ~= "" and enchantText then
        if name == enchantText then
            enchantText = nil;
        end
        self:SetButtonText(name, enchantText);
        self:ShowLoadingIcon(false);
        return true
    else
        EventListener:AddEnchant(enchantID, self);
        self:ShowLoadingIcon(true);
    end
end

function NarciEquipmentEnchantButtonMixin:SetGemData(itemID)
    if itemID ~= self.itemID then
        self.itemID = itemID;
    else
        if not itemID then
            self:Hide();
        end
        return
    end

    if itemID then
        local icon = GetItemIcon(itemID);
        self.Icon:SetTexture(icon);
        local name = GetItemInfo(itemID);
        local gemBonus = GetGemBonus(itemID);
        if name and name ~= "" and gemBonus and gemBonus ~= "" then
            local quality = C_Item.GetItemQualityByID(itemID);
            local r, g, b = GetItemQualityColor(quality);
            self.Text2:SetTextColor(r, g, b, 1);
            self:SetButtonText(gemBonus, name);
            self:ShowLoadingIcon(false);
            self.itemName = name;
        else
            EventListener:AddItem(itemID, self);
            self:ShowLoadingIcon(true);
        end
        self:SetItemCount(itemID);
        self:Show();
    else
        self:Hide();
    end
    self.spellID = nil;
    self.isShard = nil;
end

function NarciEquipmentEnchantButtonMixin:SetDominationShardData(itemID)
    if itemID ~= self.itemID then
        self.itemID = itemID;
    else
        if not itemID then
            self:Hide();
        end
        return
    end
    if itemID then
        self.isShard = true;
        local icon = GetItemIcon(itemID);
        self.Icon:SetTexture(icon);
        local name = GetItemInfo(itemID);
        if name and name ~= "" then
            local quality = C_Item.GetItemQualityByID(itemID);
            local r, g, b = GetItemQualityColor(quality);
            self.Text2:SetTextColor(r, g, b, 1);
            self:SetButtonText(GetShardBonus(itemID), name);
            self:ShowLoadingIcon(false);
            self.itemName = name;
        else
            EventListener:AddItem(itemID, self);
            self:ShowLoadingIcon(true);
        end
        self:SetItemCount(itemID);
        self:Show();
    else
        self.isShard = nil;
        self:Hide();
    end
    self.spellID = nil;
end

function NarciEquipmentEnchantButtonMixin:WipeData()
    self.itemID = nil;
    self.spellID = nil;
end

NarciItemListButtonHighlightMixin = {};

function NarciItemListButtonHighlightMixin:OnLoad()
    ButtonHighlight = self;
end

function NarciItemListButtonHighlightMixin:SetParentButton(button)
    self:ClearAllPoints();
    --self:SetParent(button);
    --self:SetPoint("TOPLEFT", button, "TOPLEFT", -4, 0);
    --self:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, 0);
    self:SetPoint("CENTER", button, "CENTER", 0, 0);
    self:Show();
    if button:IsEnabled() then
        self.Highlight:SetColorTexture(0.2, 0.2, 0.2);
    else
        self.Highlight:SetColorTexture(0.25, 0, 0);
    end
    self.IconRight:SetTexture(button.Icon:GetTexture());
    self.IconRight.FlyIn:Stop();
    self.IconRight.FlyIn:Play();
end