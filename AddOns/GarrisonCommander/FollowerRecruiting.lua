local me,ns=...
ns.Configure()
local addon=addon
local GRF=GarrisonRecruiterFrame.Pick
local module=addon:NewSubClass("RecruitingPage") --#module
function module:OnInitialize()
end
local origGarrisonRecruiterFrame_AddEntryToDropdown=GarrisonRecruiterFrame_AddEntryToDropdown
function _G.GarrisonRecruiterFrame_AddEntryToDropdown(entry,info,level)
	info.text = entry.name;
	info.value = entry.id;
	info.checked = (GRF.dropDownValue == info.value);
	if (entry.id) then
		local list=GRF.Title2:GetText()==GARRISON_CHOOSE_THREAT and addon:GetFollowersWithCounterFor(entry.id) or addon:GetFollowersWithTrait(entry.id)
		if list then
			info.text=("%s (%d)"):format(entry.name,#list)
			info.tooltipText=entry.description.."\n"
			for i=1,#list do
				info.tooltipText=info.tooltipText.."\n"..addon:GetFollowerData(list[i],'fullname',L["Some follower"]) .. " " .. addon:GetFollowerStatus(list[i],false,true)
			end

		end
	end
	UIDropDownMenu_AddButton(info, level);
end
