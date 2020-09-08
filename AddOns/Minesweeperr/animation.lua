local L = LibStub ("AceLocale-3.0"):GetLocale("Minesweeperr", true)
local MS = Minesweeperr
MS.Animation = {}

function MS.Animation:setUnderlineAnimation(f, width, anchor)
    f.hover = false
    local underline = CreateFrame("Frame", nil, f)
    underline:SetSize(width, 1)
    if not anchor then
        anchor = "BOTTOM"
    end
    underline:SetPoint(anchor, f, anchor, 0, -2)
    MS.Frame:setFrameTexture(underline, 1)
    MS.Frame:setFrameColor(underline, 0.95, 0.85, 0.6, 0.95, 0.15, 0.15, 0.16, 0)
    underline:SetAlpha(0)
    local ag = underline:CreateAnimationGroup()    
    local alpha = ag:CreateAnimation("Alpha")
    alpha:SetToAlpha(1)
    alpha:SetDuration(0.1)
    underline.ag = ag
    f.underline = underline

    f:EnableMouse(true)
    f:SetScript("OnEnter", function(self)
        if not f.hover then
            f.hover = true
            f.underline.ag:Play()
        end
    end)
    f.underline.ag:SetScript("OnFinished", function(self)
        if f.hover then
            f.underline:SetAlpha(1)
        end
    end)
    f:SetScript("OnLeave", function(self)
        f.hover = false
        f.underline:SetAlpha(0)
    end)
end

function MS.Animation:setColorAnimation(f)
    local ag = f:CreateAnimationGroup()    
    local scale = ag:CreateAnimation("Scale")
    scale:SetScale(1.3, 1.3)
    scale:SetDuration(0.2)
    f.ag = ag

    f:EnableMouse(true)
    f:SetScript("OnEnter", function(self)
        MS.Frame:setFrameColor(f, 0.95, 0.85, 0.75, 1, 0.15, 0.15, 0.16, 0)
    end)
    f:SetScript("OnLeave", function(self)
        MS.Frame:setFrameColor(f, 0.4, 0.4, 0.4, 1, 0.15, 0.15, 0.16, 0)
    end)
end

function MS.Animation:setupAnimations()
    local mainFrame = MS.Frame.mainFrame
    self:setUnderlineAnimation(mainFrame.titleText, 70)
    self:setUnderlineAnimation(mainFrame.closeText, 25)
    self:setUnderlineAnimation(mainFrame.refreshText, 25)
    self:setUnderlineAnimation(mainFrame.historyText, 25)

    for idx, panel in pairs(MS.Frame.panels) do
        self:setUnderlineAnimation(panel.achiText, 35, "BOTTOMLEFT")
        self:setUnderlineAnimation(panel.ilvlTextValue, 15, "BOTTOMLEFT")
        self:setUnderlineAnimation(panel.slotTextValue, 10, "BOTTOMLEFT")
        self:setUnderlineAnimation(panel.corrTextValue, 10, "BOTTOMLEFT")
        self:setUnderlineAnimation(panel.currentKeyTextValue, 10, "BOTTOMRIGHT")
        self:setUnderlineAnimation(panel.maxInTimeTextValue, 10, "BOTTOMRIGHT")
        
    end
    MS.Animation:setColorAnimation(MS.Frame.historyFrame.closeBtn)
    MS.Animation:setUnderlineAnimation(MS.Frame.qcFrame.closeBtn, 20)

end