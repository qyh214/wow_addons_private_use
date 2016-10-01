local me,ns=...
ns.Configure()
local addon=addon
local GRF=GarrisonRecruiterFrame.Pick
local module=addon:NewSubClass("RecruitingPage") --#module
local function changetext(this)
	--securecall(print,"secure?",issecure(),this:GetText())
end
local function HookedGarrisonRecruiterFrame_AddEntryToDropdown(entry,info,level)
	if ( not level ) then
		return
	end
	local listFrame = _G["DropDownList"..level]
	local index = listFrame.numButtons
	local listFrameName = listFrame:GetName();
	local button = _G[listFrameName.."Button"..index];
	if (entry.id) then
		local list=GRF.Title2:GetText()==GARRISON_CHOOSE_THREAT and addon:GetFollowersWithCounterFor(entry.id) or addon:GetFollowersWithTrait(entry.id)
		if list then
			info.text=("%s (%d)"):format(entry.name,#list)
			info.tooltipText=entry.description.."\n"
			for i=1,#list do
				info.tooltipText=info.tooltipText.."\n"..addon:GetFollowerData(list[i],'fullname',L["Some follower"]) .. " " .. addon:GetFollowerStatus(list[i],false,true)
			end
			if ( info.colorCode ) then
				--button:SetText(info.colorCode..info.text.."|r");
			else
				button:SetText(info.text);
			end
			button.tooltipText=info.tooltipText
			--button.tooltipTitle=GARRISON_FOLLOWERS
		end
	end
end
function module:OnInitialize()
	--self:SafeSecureHook("GarrisonRecruiterFrame_AddEntryToDropdown")
	hooksecurefunc("GarrisonRecruiterFrame_AddEntryToDropdown",HookedGarrisonRecruiterFrame_AddEntryToDropdown)
end
