local AS, L, S, R = unpack(AddOnSkins)

if not AS:CheckAddOn('AchieveIt') then return end

function R:AchieveIt(event, addon)
	if addon == 'Blizzard_AchievementUI' or IsAddOnLoaded('Blizzard_AchievementUI') then
		AS:Delay(1, function()
			for i = 1, 20 do
				local frame = _G['AchievementFrameCategoriesContainerButton'..i]
				S:StripTextures(frame)
				S:StyleButton(frame)
			end
			AchieveIt_Locate_Button.label:ClearAllPoints()
			AchieveIt_Locate_Button.label:SetJustifyH('CENTER')
			AchieveIt_Locate_Button.label:SetPoint('CENTER') 
			S:HandleButton(AchieveIt_Locate_Button, true)
			AchieveIt_Locate_Button:ClearAllPoints()
			AchieveIt_Locate_Button:SetPoint('TOPLEFT', AchievementFrame, 250, 5)
		end)

		AS:UnregistSkinEvent('ADDON_LOADED')
	end
end

AS:RegisterSkin('AchieveIt', R.AchieveIt, 'ADDON_LOADED')
