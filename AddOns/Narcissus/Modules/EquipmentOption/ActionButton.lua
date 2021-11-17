local GetItemQualityColorByItemID = NarciAPI.GetItemQualityColorByItemID;
local FadeFrame = NarciFadeUI.Fade;


local SelectionOverlay;

NarciEquipmentOptionActionButtonMixin = {};

function NarciEquipmentOptionActionButtonMixin:InitFromButton(button)
    self:Clear();
    button:Hide();
    --button.FadeOut:Play();
    --FadeFrame(button, 0.2, 0);
    self.sourceButton = button;
    self.ItemName:SetText(button.itemName);
    if button.itemID then
        self.ItemName:SetTextColor(GetItemQualityColorByItemID(button.itemID));
    else
        self.ItemName:SetTextColor(1, 1, 1);
    end
    self:ClearAllPoints();
    self:SetPoint("CENTER", button, "CENTER", 0, 0);
    self:SetScale(button:GetEffectiveScale())
    self:Show();
    NarciSecureFrameContainer:Show();

    self:StopAnimating();
    --self.FlyIn:Play();
    self.Backdrop.Shine:Play();
    self.Header.FlyIn:Play();
    self.ItemName.FlyIn:Play();
    if not SelectionOverlay then
        SelectionOverlay = Narci_EquipmentOption.ItemList.SelectionOverlay;
    end
    FadeFrame(SelectionOverlay, 0.2, 1);
    self.ClipFrame.Blink.FlyBy:Play();
end

function NarciEquipmentOptionActionButtonMixin:Clear()
    if self.sourceButton then
        FadeFrame(self.sourceButton, 0.2, 1, 0);
    end
    self:StopAnimating();
    self:Hide();

    if SelectionOverlay then
        FadeFrame(SelectionOverlay, 0.25, 0);
    end
end

function NarciEquipmentOptionActionButtonMixin:PostClick(button)
    if button == "RightButton" then
        self:Clear();
    end
end

function NarciEquipmentOptionActionButtonMixin:OnLeave()

end