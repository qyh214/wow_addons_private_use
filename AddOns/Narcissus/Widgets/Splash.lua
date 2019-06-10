function Narci_Splash_OnShow(self)
    local CameraFollowStyle = GetCVar("cameraSmoothStyle");
    if CameraFollowStyle == "0" then		--auto-follow disabled
        self.Text1:SetText(NARCI_SPLASH_MESSAGE1.."\n\n"..NARCI_SPLASH_MESSAGE1_CONDITIONAL_LINE)
    else
        self.Text1:SetText(NARCI_SPLASH_MESSAGE1)
    end
end

function Narci_ExtraInfoButton_OnClick(self)
    self:Disable();
    self.Text:SetText(NARCI_SPLASH_MESSAGE1_EXTRA_LINE);
    self:SetHeight(self.Text:GetHeight() + 16);
end