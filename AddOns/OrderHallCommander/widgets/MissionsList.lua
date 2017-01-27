local me,addon=...
local C=addon:GetColorTable()
local module=addon:GetWidgetsModule()
local Type,Version,unique="OHCMissionsList",1,0
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end
local C=addon:GetColorTable()
local G=C_Garrison
local GARRISON_FOLLOWER_XP_ADDED_ZONE_SUPPORT=GARRISON_FOLLOWER_XP_ADDED_ZONE_SUPPORT:gsub('%%d',C('%%d','Yellow'))
local GARRISON_FOLLOWER_XP_ADDED_ZONE_SUPPORT_LEVEL_UP=GARRISON_FOLLOWER_XP_ADDED_ZONE_SUPPORT_LEVEL_UP:gsub('%%d',C('%%d','Green'))
local	GARRISON_FOLLOWER_XP_LEFT=GARRISON_FOLLOWER_XP_LEFT:gsub('%%d',C('%%d','Orange'))
local COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED=COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED:gsub('%%d',C('%%d','Green'))
local GARRISON_FOLLOWER_XP_UPGRADE_STRING=GARRISON_FOLLOWER_XP_UPGRADE_STRING
local GARRISON_FOLLOWER_XP_STRING=GARRISON_FOLLOWER_XP_STRING
local GARRISON_FOLLOWER_DISBANDED=GARRISON_FOLLOWER_DISBANDED
local BONUS_LOOT_LABEL=C(" (".. BONUS_LOOT_LABEL .. ")","Green")
local m={} --#Widget
function m:ScrollDown()
	local obj=self.scroll
	if (#self.missions >1 and obj.scrollbar and obj.scrollbar:IsShown()) then
		obj:SetScroll(80)
		obj.scrollbar.ScrollDownButton:Click()
	end
end
function m:OnAcquire()
	wipe(self.missions)
end
function m:Show()
	self.frame:Show()
end
function m:Hide()
	self.frame:Hide()
	self:Release()
end
function m:AddButton(text,action)
	local obj=self.scroll
	local b=AceGUI:Create("Label")
	b:SetFullWidth(true)
	b:SetText(text)
	b:SetColor(C.yellow.r,C.yellow.g,C.yellow.b)
	--b:SetCallback("OnClick",action)
	obj:AddChild(b)
end
function m:AddMissionButton(mission,followers,perc,source)
	if not self.missions[mission.missionID] then
		local obj=self.scroll
		local b=AceGUI:Create("OHCMissionButton")
		b:SetMission(mission,followers,perc,source)
		b:SetScale(0.7)
		b:SetFullWidth(true)
		b:RunSpinner(true)
		self.missions[mission.missionID]=b
		obj:AddChild(b)
	end

end
function m:AddMissionResult(missionID,success)
	local mission=self.missions[missionID]
	if mission then
		local frame=mission.frame
		mission:RunSpinner(false)
		if success then
			if success > 3 then
				mission.Result:SetText(GARRISON_MISSION_SUCCESS .. ' ' .. BONUS_LOOT_LABEL)
			else
				mission.Result:SetText(GARRISON_MISSION_SUCCESS)
			end			
			mission.Result:SetTextColor(C:Green())
			for i=1,#frame.Rewards do
				frame.Rewards[i].Icon:SetDesaturated(false)
				frame.Rewards[i].Quantity:Show()
			end
		else
			mission.Result:SetText(GARRISON_MISSION_FAILED)
			mission.Result:SetTextColor(C:Red())
			
			for i=1,#frame.Rewards do
				frame.Rewards[i].Icon:SetDesaturated(true)
				frame.Rewards[i].Quantity:Hide()
			end
		end
		frame.Title:ClearAllPoints()
		frame.Title:SetPoint("TOPLEFT",165,-7)
		mission.Result:Show()
	end
end
function m:AddRow(data,...)
	local obj=self.scroll
	local l=AceGUI:Create("InteractiveLabel")
	l:SetFontObject(GameFontNormalSmall)
	l:SetText(data)
	l:SetColor(...)
	l:SetFullWidth(true)
	obj:AddChild(l)

end
function m:AddPlayerXP(xpgain)
	if xpgain>0 then
		self:AddRow(COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED:format(xpgain))
	end

end
function m:AddFollower(followerID,xp,levelup,portrait,fullname)
	if xp < 0 then
		return self:AddFollowerIcon(portrait,format(GARRISON_FOLLOWER_DISBANDED,fullname))
	end
	local isMaxLevel=addon:GetFollowerData(followerID,'isMaxLevel',false)
	if isMaxLevel and not levelup then
		return
--			return self:AddFollowerIcon(followerType,follower.portraitIconID,format("%s is already at maximum xp",follower.fullname))
	end
	if levelup then
		PlaySound("UI_Garrison_CommandTable_Follower_LevelUp");
	end
	
	local message=GARRISON_FOLLOWER_XP_ADDED_ZONE_SUPPORT:format(fullname,xp)
	local quality=addon:GetFollowerData(followerID,'quality')
	local level=addon:GetFollowerData(followerID,'level')
	local XP=addon:GetFollowerData(followerID,'xp',0) 
	local levelXP=addon:GetFollowerData(followerID,'levelXP',0)
	if levelup then
		message=message..' ' .. GARRISON_FOLLOWER_XP_ADDED_ZONE_SUPPORT_LEVEL_UP:format(fullname,level)
	end
	if levelXP > 0 then
		message=message .. ' ' ..
			GARRISON_FOLLOWER_XP_LEFT:format(levelXP-addon:GetFollowerData(followerID,'xp',levelXP)) ..
			' ' ..
			(isMaxLevel and GARRISON_FOLLOWER_XP_UPGRADE_STRING or GARRISON_FOLLOWER_XP_STRING)
	end		
	return self:AddFollowerIcon(portrait,message)
end
function m:AddFollowerIcon(icon,text)
	local l=self:AddIconText(icon,text)
end
function m:AddIconText(icon,text,qt,isBonus)
	local obj=self.scroll
	local l=AceGUI:Create("Label")
	l:SetFontObject(GameFontNormalSmall)
	if (qt) then
		l:SetText(format("%s x %s %s",text,qt,isBonus and BONUS_LOOT_LABEL or ''))
	else
		l:SetText(text)
	end
	l:SetImage(icon)
	l:SetImageSize(24,24)
	l:SetHeight(26)
	l:SetFullWidth(true)
	obj:AddChild(l)
	if (obj.scrollbar and obj.scrollbar:IsShown()) then
		obj:SetScroll(80)
		obj.scrollbar.ScrollDownButton:Click()
	end
	return l
end
function m:AddItem(itemID,qt,isBonus)
	local obj=self.scroll
	local _,itemlink,itemquality,_,_,_,_,_,_,itemtexture=GetItemInfo(itemID)
	if not itemlink then
		self:AddIconText(itemtexture,itemID,qt,isBonus)
	else
		self:AddIconText(itemtexture,itemlink,qt,isBonus)
	end
end
function m._Constructor()
	local widget=AceGUI:Create("OHCGUIContainer")
	widget:SetLayout("Fill")
	widget.missions={}
	local scroll = AceGUI:Create("ScrollFrame")
	scroll:SetLayout("List") -- probably?
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	widget:AddChild(scroll)
	for k,v in pairs(m) do widget[k]=v end
	widget._Constructor=nil
	widget:Show()
	widget.scroll=scroll
	widget.type=Type
	return widget
end
AceGUI:RegisterWidgetType(Type,m._Constructor,Version)
