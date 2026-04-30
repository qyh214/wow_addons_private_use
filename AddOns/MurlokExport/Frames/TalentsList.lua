local _, core = ...

TalentsListFrameMixin = {}
function TalentsListFrameMixin:OnLoad()
	local talentsView = CreateScrollBoxListLinearView()
	talentsView:SetElementInitializer("TalentsListTemplate", function(frame, elementData) self:InitTalentFrame(frame, elementData) end)
	talentsView:SetPadding(25,10,10,10,0)
	ScrollUtil.InitScrollBoxListWithScrollBar(self.TalentsScrollBox, self.TalentsScrollBar, talentsView)
end

function TalentsListFrameMixin:InitTalentFrame(frame, elementData)
	frame.talentBox.EditBox:SetAutoFocus(false)
	frame.talentBox.CharCount:Hide()
	frame.talentBox.EditBox:SetText(elementData.talentString)

	frame.talentIndex:SetText(core:GetRankColor(elementData.index - 1)..elementData.index..".|r")
	frame.tryOutTalentButton.tryOutTalentTexture:SetAtlas(elementData.hero_atlas, true)
	frame.tryOutTalentButton.talentBox = frame.talentBox
end

function TalentsListFrameMixin:OnClick(talents, hero_atlas)
    local talentsDataProvider = CreateDataProvider()
    for index, talentString in ipairs(talents) do
        talentsDataProvider:Insert({
            index = index,
            talentString = talentString,
            hero_atlas = hero_atlas
        })
    end
    self.TalentsScrollBox:SetDataProvider(talentsDataProvider, ScrollBoxConstants.RetainScrollPosition)
end

TalentsTryOutMixin = {}
local function GetSpecIndexForSpecId(specId)
	for specIndex = 1, GetNumSpecializations() do
		if specId == C_SpecializationInfo.GetSpecializationInfo(specIndex) then
			return specIndex
		end
	end
end

function TalentsTryOutMixin:OnClick(button)
	if button == "LeftButton" then
		local classId, specId = core:GetPlayerClassSpecHero()
		if UIMurlokExport.ClassListFrame.activeClassId ~= classId then
			return
		elseif UIMurlokExport.ClassListFrame.activeSpecId ~= specId then
			local specIndex = GetSpecIndexForSpecId(UIMurlokExport.ClassListFrame.activeSpecId)
			C_SpecializationInfo.SetSpecialization(specIndex)
			return
		end
		UIMurlokExport.TraitsTreeFrame.traits:PreviewTraits(self.talentBox.EditBox:GetText())
		if MurlokExportConfig.CompactView then
			UIMurlokExport:TabOnClick(UIMurlokExport:GetTabByText(MURLOKEXPORT_CATEGORY_TRAITS))
		else
			UIMurlokExport.TraitsTreeFrame:SelectedTabOnClick()
		end
	end
end
