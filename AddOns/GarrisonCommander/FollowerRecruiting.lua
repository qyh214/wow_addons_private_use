local me,ns=...
local addon=ns.addon
--[===[@debug@
if LibDebug then LibDebug() end
--@end-debug@]===]
local GBF=GarrisonBuildingFrame
local GBFMap=GBF.MapFrame
local G=C_Garrison
local CreateFrame=CreateFrame
local GARRISON_FOLLOWER_MAX_LEVEL=GARRISON_FOLLOWER_MAX_LEVEL
local L=ns.L
local D=ns.D
local C=ns.C
local new,del=ns.new,ns.del
local GRF=GarrisonRecruiterFrame.Pick
local module=addon:NewModule("RecruitingPage",addon) --#module
function module:OnInitialize()
end
local origGarrisonRecruiterFrame_AddEntryToDropdown=GarrisonRecruiterFrame_AddEntryToDropdown
function _G.GarrisonRecruiterFrame_AddEntryToDropdown(entry,info,level)
	info.text = entry.name;
	info.value = entry.id;
	info.checked = (GarrisonRecruiterFrame.Pick.dropDownValue == info.value);
	if (entry.id) then
		local list=GRF.Title2:GetText()==GARRISON_CHOOSE_THREAT and addon:GetFollowersWithCounterFor(entry.id) or addon:GetFollowersWithTrait(entry.id)
		if list then
			info.text=format("%s (%d)",entry.name,#list)
			info.tooltipText=entry.description.."\n"
			for i=1,#list do
				info.tooltipText=info.tooltipText.."\n"..addon:GetFollowerData(list[i],'fullname',L["Some follower"]) .. " " .. addon:GetFollowerStatus(list[i],false,true)
			end

		end
	end
	UIDropDownMenu_AddButton(info, level);
end
