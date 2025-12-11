
BuildEnv(...)

local ApplicantItem = Addon:NewClass('ApplicantItem', GUI:GetClass('ItemButton'))

function ApplicantItem:Constructor()
    self:SetCheckedTexture([[Interface\HelpFrame\HelpFrameButton-Highlight]])
    self:GetCheckedTexture():SetTexCoord(0, 1, 0, 0.57)

    self:SetHighlightTexture([[Interface\HelpFrame\HelpFrameButton-Highlight]], 'ADD')
    self:GetHighlightTexture():SetTexCoord(0, 1, 0, 0.57)

    local bg = self:CreateTexture(nil, 'BACKGROUND') do
        bg:SetPoint('TOPLEFT', 0, -1)
        bg:SetPoint('BOTTOMRIGHT', 0, 1)
        bg:SetColorTexture(1, 1, 1)
        bg:Hide()
    end

    self.bg = bg
end

function ApplicantItem:SetAlpha(alpha, button)
    self.bg:SetAlpha(alpha)
    self.bg:SetPoint('BOTTOMRIGHT', button)
    self.bg:Show()
end

function ApplicantItem:SetBackground(enable)
    self.bg:SetShown(enable)
end

function ApplicantItem:IsBackgroundShown()
    return self.bg:IsShown()
end

function ApplicantItem:UpdateSortValue()
  local Leader = self:GetName()
  if Leader then
    if not string.find(Leader, "-") then
      Leader = Leader .. '-' .. GetRealmName()
    end
  end

  local LocomotiveLevel = 0
  local regimentData = GetRegimentData(Leader)
  if regimentData and regimentData.level ~= nil and regimentData.level ~= -1 then
    LocomotiveLevel = regimentData.level
  end

  self._baseSortValue = tostring(9 - LocomotiveLevel)
end

function ApplicantItem:BaseSortHandler()
    if not self._baseSortValue then
        self:UpdateSortValue()
    end
    return self._baseSortValue
end
