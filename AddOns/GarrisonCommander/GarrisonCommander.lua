local __FILE__=tostring(debugstack(1,2,0):match("(.*):1:")) -- MUST BE LINE 1
local toc=select(4,GetBuildInfo())
local me, ns = ...
local pp=print
if (LibDebug) then LibDebug() end
local L=LibStub("AceLocale-3.0"):GetLocale(me,true)
local C=LibStub("AlarCrayon-3.0"):GetColorTable()
local addon=LibStub("AlarLoader-3.0")(__FILE__,me,ns):CreateAddon(me,true) --#Addon
local print=ns.print or print
local debug=ns.debug or print
local dump=ns.dump or print
--[===[@debug@
ns.debugEnable('on')
local function tcopy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[tcopy(k, s)] = tcopy(v, s) end
	return res
end
--@end-debug@]===]
-----------------------------------------------------------------
-- Recycling function from ACE3
----newcount, delcount,createdcount,cached = 0,0,0
local new, del, copy
do
	local pool = setmetatable({},{__mode="k"})
	function new()
		--newcount = newcount + 1
		local t = next(pool)
		if t then
			pool[t] = nil
			return t
		else
			--createdcount = createdcount + 1
			return {}
		end
	end
	function copy(t)
		local c = new()
		for k, v in pairs(t) do
			c[k] = v
		end
		return c
	end
	function del(t)
		--delcount = delcount + 1
		wipe(t)
		pool[t] = true
	end
--	function cached()
--		local n = 0
--		for k in pairs(pool) do
--			n = n + 1
--		end
--		return n
--	end
end
local function capitalize(s)
	s=tostring(s)
	return strupper(s:sub(1,1))..strlower(s:sub(2))
end
local masterplan
local followers
local successes={}
local requested={}
local threats={}
local availableFollowers=0
local skipBusy
local GMF=GarrisonMissionFrame
local GMFFollowers=GarrisonMissionFrameFollowers
local GMFMissions=GarrisonMissionFrameMissions
local GMFMissionPage=GMF.MissionTab
local GMFRewardPage
local GMFFollowerPage=GMF.FollowerTab
local GMFTab1=GarrisonMissionFrameTab1
local GMFTab2=GarrisonMissionFrameTab2
local GMFMissionsTab1=GarrisonMissionFrameMissionsTab1
local GMFMissionsTab2=GarrisonMissionFrameMissionsTab2
local GARRISON_FOLLOWER_WORKING=GARRISON_FOLLOWER_WORKING -- "Working
local GARRISON_FOLLOWER_ON_MISSION=GARRISON_FOLLOWER_ON_MISSION -- "On Mission"
local GARRISON_FOLLOWER_INACTIVE=GARRISON_FOLLOWER_INACTIVE --"Inactive"
local GARRISON_FOLLOWER_EXHAUSTED=GARRISON_FOLLOWER_EXHAUSTED -- "Recovering (1 Day)"
local GARRISON_FOLLOWER_IN_PARTY=GARRISON_FOLLOWER_IN_PARTY
local GARRISON_BUILDING_SELECT_FOLLOWER_TITLE=GARRISON_BUILDING_SELECT_FOLLOWER_TITLE -- "Select a Follower";
local GARRISON_BUILDING_SELECT_FOLLOWER_TOOLTIP=GARRISON_BUILDING_SELECT_FOLLOWER_TOOLTIP -- "Click here to assign a Follower";
local GARRISON_FOLLOWER_CAN_COUNTER=GARRISON_FOLLOWER_CAN_COUNTER -- "This follower can counter:"
local GARRISON_MISSION_SUCCESS=GARRISON_MISSION_SUCCESS -- "Success"
local GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS=GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS -- "%d Follower mission";
local UNKNOWN_CHANCE=GARRISON_MISSION_PERCENT_CHANCE:gsub('%%d%%%%',UNKNOWN)
local GARRISON_MISSION_PERCENT_CHANCE=GARRISON_MISSION_PERCENT_CHANCE .. " (Estimated)"
local BUTTON_INFO=GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS.. " " .. GARRISON_MISSION_PERCENT_CHANCE
local GARRISON_FOLLOWERS=GARRISON_FOLLOWERS -- "Followers"
local GARRISON_PARTY_NOT_FULL_TOOLTIP=GARRISON_PARTY_NOT_FULL_TOOLTIP -- "You do not have enough followers on this mission."
local AVAILABLE=AVAILABLE -- "Available"
local PARTY=PARTY -- "Party"
local ENVIRONMENT_SUBHEADER=ENVIRONMENT_SUBHEADER -- "Environment"
local SPELL_TARGET_TYPE4_DESC=capitalize(SPELL_TARGET_TYPE4_DESC) -- party member
local SPELL_TARGET_TYPE1_DESC=capitalize(SPELL_TARGET_TYPE1_DESC) -- any
local ANYONE='('..SPELL_TARGET_TYPE1_DESC..')'
local IGNORE_UNAIVALABLE_FOLLOWERS=IGNORE.. ' ' .. UNAVAILABLE .. ' ' .. GARRISON_FOLLOWERS
local IGNORE_UNAIVALABLE_FOLLOWERS_DETAIL=IGNORE.. ' ' .. GARRISON_FOLLOWER_INACTIVE .. ',' .. GARRISON_FOLLOWER_ON_MISSION ..',' .. GARRISON_FOLLOWER_WORKING.. ','.. GARRISON_FOLLOWER_EXHAUSTED .. ' ' .. GARRISON_FOLLOWERS
IGNORE_UNAIVALABLE_FOLLOWERS=capitalize(IGNORE_UNAIVALABLE_FOLLOWERS)
IGNORE_UNAIVALABLE_FOLLOWERS_DETAIL=capitalize(IGNORE_UNAIVALABLE_FOLLOWERS_DETAIL)
local GameTooltip=GameTooltip
local GetItemQualityColor=GetItemQualityColor
local hookedListUpdate
local timers={}
function addon:AddLine(icon,name,status,quality,...)
	local r2,g2,b2=C.Red()
	local q=ITEM_QUALITY_COLORS[quality or 1] or {}
	if (status==AVAILABLE) then
		r2,g2,b2=C.Green()
	elseif (status==GARRISON_FOLLOWER_WORKING) then
		r2,g2,b2=C.Orange()
	end
	--GameTooltip:AddDoubleLine(name, status or AVAILABLE,r,g,b,r2,g2,b2)
	--GameTooltip:AddTexture(icon)
	GameTooltip:AddDoubleLine(icon and "|T" .. tostring(icon) .. ":0|t  " .. name or name, status,q.r,q.g,q.b,r2,g2,b2)
end
function addon:GetDifficultyColor(perc)
	local difficulty='trivial'
	if(perc >90) then
		difficulty='standard'
	elseif (perc >74) then
		difficulty='difficult'
	elseif(perc>49) then
		difficulty='verydifficult'
	elseif(perc >20) then
		difficulty='impossible'
	end
	return QuestDifficultyColors[difficulty]
end
function addon:RestoreTooltip()
	local self = GMF.MissionTab.MissionList;
	local scrollFrame = self.listScroll;
	local buttons = scrollFrame.buttons;
	for i =1,#buttons do
		buttons[i]:SetScript("OnEnter",GarrisonMissionButton_OnEnter)
	end
end
local openParty,isInParty,pushFollower,closeParty,roomInParty

do
	local ID,frames,members,max=0,{},{},1
	function openParty(missionID,maxfollowers)
		max=maxfollowers
		frames={GetFramesRegisteredForEvent('GARRISON_FOLLOWER_LIST_UPDATE')}
		for i=1,#frames do
			frames[i]:UnregisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
		end
		ID=missionID
	end
	function isInParty(followerID)
		for i=1,max do
			if (followerID==members[i]) then return true end
		end
	end
	function roomInParty()
		return not members[max]
	end
	function pushFollower(followerID)
		if (roomInParty()) then
			local rc,code=pcall (C_Garrison.AddFollowerToMission,ID,followerID)
			if (rc and code) then
				tinsert(members,followerID)
				return true
			end
		end
	end
	function closeParty()
		for i=1,3 do
			if (members[i]) then
				C_Garrison.RemoveFollowerFromMission(ID,members[i])
			else
				break
			end
		end
		for i=1,#frames do
			frames[i]:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
		end
		wipe(frames)
		wipe(members)
	end
end

-- This is a ugly hack while I rewrite this code for 2.0
function addon:TooltipAdder(missionID,skipTT)
--[===[@debug@
	if (not skipTT) then GameTooltip:AddLine("ID:" .. tostring(missionID)) end
--@end-debug@]===]
	self:GetRunningMissionData()
	local perc=select(4,C_Garrison.GetPartyMissionInfo(missionID))
	local q=self:GetDifficultyColor(perc)
	if (not skipTT) then GameTooltip:AddDoubleLine(GARRISON_MISSION_SUCCESS,format(GARRISON_MISSION_PERCENT_CHANCE,perc),nil,nil,nil,q.r,q.g,q.b) end
	local buffed=new()
	local traited=new()
	local buffs=new()
	local traits=new()
	local fellas=new()
	local fullname=new()
	for id,d in pairs(C_Garrison.GetBuffedFollowersForMission(missionID)) do
		buffed[id]=d
	end
	for id,d in pairs(C_Garrison.GetFollowersTraitsForMission(missionID)) do
		for x,y in pairs(d) do
--[===[@debug@
			self.db.global.traits[y.traitID]=y.icon
--@end-debug@]===]
			if (y.traitID~=236) then --Ignore hearthstone traits
				traited[id]=d
				break
			end
		end
	end
	availableFollowers=0
	for index=1,#followers do
		local follower=followers[index]
		follower.rank=follower.level < 100 and follower.level or follower.iLevel
		if (not follower.isCollected) then break end
		follower.status=C_Garrison.GetFollowerStatus(follower.followerID)
		followers[index].status=follower.status		
		if (not follower.status) then
			availableFollowers=availableFollowers+1
		end
		if (follower.status and skipBusy) then
		else
			local id=follower.followerID
			local b=buffed[id]
			local t=traited[id]
			local followerBias = C_Garrison.GetFollowerBiasForMission(missionID,id);
			follower.bias=followerBias
			local formato=C("%3d","White")
			if (followerBias==-1) then
				formato=C("%3d","Red")
			elseif (followerBias < 0) then
				formato=C("%3d","Orange")
			end
			formato=formato.." %s"
--[===[@debug@
			formato=formato .. " 0x+(0*8)  " .. id:sub(11)
--@end-debug@]===]
			if (b) then
				if (not buffs[id]) then
					buffs[id]=index
					fullname[id]=format(formato,follower.rank,follower.name)
				end
				for _,ability in pairs(b) do
					fullname[id]=fullname[id] .. " |T" .. tostring(ability.icon) .. ":0|t"
					if (not follower.status or not skipBusy) then
						local aname=ability.name
						if (tonumber(fellas[aname])) then
							local previous=followers[tonumber(fellas[aname])]
							if (previous.rank>=follower.rank) then
								break
							end
						end
						fellas[aname]=index
					end
				end
			end
			if (t) then
				if (not traits[id]) then
					traits[id]=index
					fullname[id]=format(formato,follower.rank,follower.name)
				end
				for _,ability in pairs(t) do
					fullname[id]=fullname[id] .. " |T" .. tostring(ability.icon) .. ":0|t"
				end
			end
		end
	end
	local maxfollowers=C_Garrison.GetMissionMaxFollowers(missionID)
	requested[missionID]=maxfollowers
	local partyshown=false
	local perc=0
	local menaces=0
	openParty(missionID,maxfollowers)
	if (next(traits) or next(buffs) ) then
		if (not skipTT) then GameTooltip:AddLine(GARRISON_FOLLOWER_CAN_COUNTER) end
		for id,i in pairs(buffs) do
			local v=followers[i]
			local status=(v.status == GARRISON_FOLLOWER_ON_MISSION and (timers[id] or GARRISON_FOLLOWER_ON_MISSION)) or v.status
			if (not skipTT) then self:AddLine(nil,fullname[id],status or AVAILABLE,v.quality) end
		end
		for id,i in pairs(traits) do
			local v=followers[i]
			local status=(v.status == GARRISON_FOLLOWER_ON_MISSION and (timers[id] or GARRISON_FOLLOWER_ON_MISSION)) or v.status
			if (not skipTT) then self:AddLine(nil,fullname[id],status or AVAILABLE,v.quality) end
		end
		if (not skipTT) then GameTooltip:AddLine(PARTY,C.White()) end
		partyshown=true
		local enemies = select(8,C_Garrison.GetMissionInfo(missionID))
		--local missionInfo=C_Garrison.GetBasicMissionInfo(missionID)
--[===[@debug@
		--DevTools_Dump(fellas)
--@end-debug@]===]
		for _,enemy in pairs(enemies) do
			for i,mechanic in pairs(enemy.mechanics) do
--[===[@debug@
				self.db.global.abilities[i .. '.' .. mechanic.name]=mechanic.description
--@end-debug@]===]
				local menace=mechanic.name
				local res
				menaces=menaces+1
				if (fellas[menace]) then
					local follower=followers[fellas[menace]]
					if (follower.status and skipBusy) then
					elseif (pushFollower(follower.followerID)) then
						res=fullname[follower.followerID]
					end
				end
				if (not skipTT) then
					if (res) then
						GameTooltip:AddDoubleLine(menace,res,0,1,0)
					else
						GameTooltip:AddDoubleLine(menace,' ',1,0,0)
					end
				end
			end
		end
		if (roomInParty() and next(traits))  then
			for id,i in pairs(traits) do
				local follower=followers[i]
				if (follower.status and skipBusy) then
				elseif (pushFollower(id)) then
					if (not skipTT) then GameTooltip:AddDoubleLine(ENVIRONMENT_SUBHEADER,fullname[id],0,1,0) end
					break
				end
			end
		end
	end
	-- And then fill the roster
	if (roomInParty())  then
		for index=1,#followers do
			local follower=followers[index]
			if (follower.status and skipBusy) then
			elseif (pushFollower(follower.followerID)) then
				if (not partyshown) then
					if (not skipTT) then GameTooltip:AddLine(PARTY,1) end
					partyshown=true
				end
				if (not skipTT) then
					GameTooltip:AddDoubleLine(SPELL_TARGET_TYPE4_DESC,follower.name,C.Orange.r,C.Orange.g,C.Orange.b)--SPELL_TARGET_TYPE1_DESC)
				end
				if (not roomInParty()) then break end
			end
		end
	end
	perc=select(4,C_Garrison.GetPartyMissionInfo(missionID))
	local q=self:GetDifficultyColor(perc)
	if (not partyshown) then
		if (not skipTT) then GameTooltip:AddDoubleLine(PARTY,ANYONE,C.White.r,C.White.g,C.White.b) end
	end
	if (not skipTT) then GameTooltip:AddDoubleLine(GARRISON_MISSION_SUCCESS,format(GARRISON_MISSION_PERCENT_CHANCE,perc),nil,nil,nil,q.r,q.g,q.b) end
	local b=GameTooltip:GetOwner()
	successes[missionID]=perc
	threats[missionID]=menaces
	if (availableFollowers < maxfollowers) then
		if (not skipTT) then GameTooltip:AddLine(GARRISON_PARTY_NOT_FULL_TOOLTIP,C:Red()) end
	end
	--if (not skipTT) then self:AddPerc(GameTooltip:GetOwner()) end
	closeParty()
	-- Add a signature
	--local r,g,b=C:Silver()
	--GameTooltip:AddDoubleLine("GarrisonCommander",self.version,r,g,b,r,g,b)
--[===[@debug@
	--DevTools_Dump(fellas)
--@end-debug@]===]
	del(buffed)
	del(traited)
	del(buffs)
	del(traits)
	del(fellas)
end
function addon:FillFollowersList()
	if (GarrisonFollowerList_UpdateFollowers) then
		GarrisonFollowerList_UpdateFollowers(GarrisonMissionFrame.FollowerList)
	end
end
function addon:CacheFollowers()
	followers=C_Garrison.GetFollowers()
	for i=1,#followers do
		if  (not followers[i].isCollected) then
			followers[i]=nil
		end
	end
end
function addon:GetRunningMissionData()
	local list=GarrisonMissionFrame.MissionTab.MissionList
	C_Garrison.GetInProgressMissions(list.inProgressMissions);
	--C_Garrison.GetAvailableMissions(list.availableMissions);
	if (#list.inProgressMissions > 0) then
		for i,mission in pairs(list.inProgressMissions) do
			for _,id in pairs(mission.followers) do
				timers[id]=mission.timeLeft
			end
		end
	end
end
function addon:ADDON_LOADED(event,addon)
	if (addon=="Blizzard_GarrisonUI") then
		self:UnregisterEvent("ADDON_LOADED")
		self:Init()
	end
end
function addon:ApplyIGM(value)
	skipBusy=value
	if (not GMF) then return end
	if (skipBusy) then
		GMF.GCIgnore.text:SetTextColor(C:Green())
	else
		GMF.GCIgnore.text:SetTextColor(C:Red())
	end
	self:RefreshMissions()
end
function addon:ApplyMOVEPANEL(value)
	if (not GMF) then return end
	if (value) then
		GMF.GCLock.text:SetTextColor(C:Green())
		GMF:SetMovable(true)
		GMF:RegisterForDrag("LeftButton")
		GMF:SetScript("OnDragStart",function(frame) frame:StartMoving() end)
		GMF:SetScript("OnDragStop",function(frame) frame:StopMovingOrSizing() end)
	else
		GMF.GCLock.text:SetTextColor(C:Red())
		GMF:SetScript("OnDragStart",nil)
		GMF:SetScript("OnDragStop",nil)
		GMF:ClearAllPoints()
		GMF:SetPoint("CENTER",UIParent)
		GMF:SetMovable(false)
	end
end
function addon:OnInitialized()
--[===[@debug@
	LoadAddOn("Blizzard_DebugTools")
--@end-debug@]===]
	self.OptionsTable.args.on=nil
	self.OptionsTable.args.off=nil
	self.OptionsTable.args.standby=nil
	self:AddToggle("MOVEPANEL",true,L["Makes Garrison Mission Panel Movable"]).width="full"
	self:AddToggle("IGM",false,IGNORE_UNAIVALABLE_FOLLOWERS,IGNORE_UNAIVALABLE_FOLLOWERS_DETAIL).width="full"
	self:loadHelp()
	self.DbDefaults.global["*"]={}
	self.db:RegisterDefaults(self.DbDefaults)
	skipBusy=self:GetBoolean("IGM")
	self:MasterPlanDetection(true)
	self:FillFollowersList()
	self:CacheFollowers()
	self:SecureHook("GarrisonMissionButton_AddThreatsToTooltip",function(id) self:TooltipAdder(id) end)
	self:SecureHook("GarrisonMissionButton_SetRewards","AddPerc")
	self:HookScript(GMF,"OnHide","CleanUp")
	local f=GMF:CreateFontString()
	f:SetFontObject(GameFontNormalSmall)
	--f:SetHeight(32)
	f:SetText(me .. L[" Options:"])
	--f:SetTextColor(C:Azure())
	f:Show()
	GMF.GCLabel=f
	local b=CreateFrame("CheckButton","GACOptions",GMF,"UICheckButtonTemplate")
	b.text:SetText(L["Ignore busy followers"])
	b:SetChecked(self:GetBoolean('IGM'))
	b:SetScript("OnCLick",function(b) self:ApplyIGM(b:GetChecked()) end)
	b:Show()
	GMF.GCIgnore=b
	self:ApplyIGM(self:GetBoolean('IGM'))
	local l=CreateFrame("CheckButton","GACLock",GMF,"UICheckButtonTemplate")
	l.text:SetText(L["Unlock Panel"])
	l:SetChecked(self:GetBoolean('MOVEPANEL'))
	l:SetScript("OnCLick",function(b) self:ApplyMOVEPANEL(b:GetChecked()) end)
	l:Show()
	f:SetPoint("BOTTOMLEFT",GMF,"TOPLEFT",10,15)
	b:SetPoint("TOPLEFT",f,"TOPRIGHT",10,10)
	l:SetPoint("TOPLEFT",b,"TOPRIGHT",10+b.text:GetWidth(),0)
	GMF.GCLock=l
	self:ApplyMOVEPANEL(self:GetBoolean("MOVEPANEL"))
	-- Forcing refresh when needed without possibly disrupting Blizzard Logic
	self:SecureHook("GarrisonMissionPage_Close","RefreshMissions") -- Missino started
	self:SecureHook("GarrisonMissionFrame_HideCompleteMissions","RefreshMissions")	-- Mission reward completed
	self:CacheFollowers()

--[===[@debug@
	--Only Used for development
	self:RegisterEvent("GARRISON_MISSION_LIST_UPDATE",print)
	self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE",print) --This event is quite useless, fires too often
	self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGEDE",print)
	self:RegisterEvent("GARRISON_MISSION_STARTED",print)
	self:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_LOOT",print)
	self:RegisterEvent("GARRISON_MISSION_FINISHED",print)
	self:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE",print)
	self:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE",print)
	self:SafeHookScript("GarrisonMissionFrameTab1","OnCLick")
	self:SafeHookScript("GarrisonMissionFrameTab2","OnCLick")
	self:SafeHookScript("GarrisonMissionFrameTab3","OnCLick")
	self:SafeHookScript("GarrisonMissionFrameMissionsTab1","OnCLick")
	self:SafeHookScript("GarrisonMissionFrameMissionsTab3","OnCLick")
	self:SafeHookScript(GMFMissions,"OnShow","SetUp")
	self:SafeHookScript("GarrisonMissionFrameFollowers","OnShow")
	--self:SafeHookScript("GarrisonMissionFrameFollowers","OnHide")
	self:SafeHookScript(GMFFollowers,"OnHide")
	self:SafeHookScript(GMF.MissionTab.MissionPage.CloseButton,"OnClick")
--@end-debug@]===]
	return true
end

function addon:ScriptTrace(hook,frame,...)
--[===[@debug@
	print("Triggered " .. C(hook,"red").." script on",C(frame,"Azure"),...)
--@end-debug@]===]
end
function addon:IsProgressMission()
	return GMF:IsShown() and GarrisonMissionFrameMissionsListScrollFrameScrollChild:IsShown() and GMFMissions.showInProgress
end
function addon:IsAvailableMission()
	return GMF:IsShown() and GarrisonMissionFrameMissionsListScrollFrameScrollChild:IsShown() and not GMFMissions.showInProgress
end
function addon:IsFollowerList()
	return GMF:IsShown() and GMFFollowers:IsShown()
end
function addon:IsRewardPage()
	return GMF:IsShown()
end
function addon:IsMissionPage()
	return GMF:IsShown() and GMFMissionPage:IsSHown()
end
function addon:AddPerc(b,...)
	if (GMFMissions.CompleteDialog:IsShown()) then return end
	if (b and b.info and b.info.missionID and b.info.missionID ) then
		if (GMF.MissionTab.MissionList.showInProgress) then
			if (b.ProgressHidden) then
				return
			else
				b.ProgressHidden=true
				if (b.Success) then
					b.Success:Hide()
				end
				if (b.NotEnough) then
					b.NotEnough:Hide()
				end
				return
			end

		end
		local missionID=b.info.missionID
		local Perc=successes[missionID] or -2
		if (not b.Success) then
			b.Success=b:CreateFontString()
			b.Success:SetFontObject("GameFontNormalLarge2")
			if (masterplan) then
				b.Success:SetPoint("TOPLEFT",b.Title,"BOTTOMLEFT",200,-3)
			else
				b.Success:SetPoint("BOTTOMLEFT",b.Title,"TOPLEFT",0,3)
			end
		end
		if (not b.NotEnough) then
			b.NotEnough=b:CreateFontString()
			if (masterplan) then
				b.NotEnough:SetFontObject("GameFontNormalSmall2")
				b.NotEnough:SetPoint("BOTTOMLEFT",b.Title,"TOPLEFT",0,3)
			else
				b.NotEnough:SetFontObject("GameFontNormalSmall")
				b.NotEnough:SetPoint("TOPLEFT",b.Title,"BOTTOMLEFT",0,-3)
			end
			b.NotEnough:SetText("(".. GARRISON_PARTY_NOT_FULL_TOOLTIP .. ")")
			b.NotEnough:SetTextColor(C:Red())
		end
		if (Perc <0) then
			self:TooltipAdder(missionID,true)
			Perc=successes[missionID] or -2
		end
		if (Perc>=0) then
			if (masterplan) then
				b.Success:SetFormattedText(GARRISON_MISSION_PERCENT_CHANCE,successes[missionID])
			else
				b.Success:SetFormattedText(BUTTON_INFO,C_Garrison.GetMissionMaxFollowers(missionID),successes[missionID])
			end
			local q=self:GetDifficultyColor(successes[missionID])
			b.Success:SetTextColor(q.r,q.g,q.b)
		else
			b.Success:SetText(UNKNOWN_CHANCE)
			b.Success:SetTextColor(1,1,1)
		end
		b.Success:Show()
		if (not requested[missionID]) then
			requested[missionID]=C_Garrison.GetMissionMaxFollowers(missionID)
		end
		if (requested[missionID]>availableFollowers) then
			b.NotEnough:Show()
		else
			b.NotEnough:Hide()
		end
		b.ProgressHidden=false
	end
end
function addon:CleanUp()
	collectgarbage("step",10)
end
function addon:RefreshMissions()
--[===[@debug@
	print("Refresh missions called")
--@end-debug@]===]
	if (self:IsAvailableMission()) then
		self:CacheFollowers()
		wipe(successes)
		GarrisonMissionList_UpdateMissions()
	end
end
function addon:SafeHookScript(frame,hook,method)
	local name="Unknown"
	if (type(frame)=="string") then
		name=frame
		frame=_G[frame]
	else
		if (frame and frame.GetName) then
			name=frame:GetName()
		end
	end
--[===[@debug@
	print("DummyHook:",name,hook)
--@end-debug@]===]
	if (frame) then
		if (method) then
			self:HookScript(frame,hook,method)
		else
			self:HookScript(frame,hook,function(...) self:ScriptTrace(name,hook,...) end)
		end
--[===[@debug@
	else
		print(C("Attempted hook for non exixtent:","red"),name,hook)
--@end-debug@]===]
	end
end
function addon:FixButtons()
	local self = GMF.MissionTab.MissionList
	local scrollFrame = self.listScroll
	local buttons = scrollFrame.buttons
	if (masterplan) then
		for i =1,#buttons do
			local b=buttons[i]
			b.Success:ClearAllPoints()
			if (b.Expire) then
				b.Success:SetPoint("TOPLEFT",b.Expire,"TOPRIGHT",5,0)
			else
				b.Success:SetPoint("TOPLEFT",b.Title,"BOTTOMLEFT",200,-3)
			end
			b.NotEnough:SetFontObject("GameFontNormalSmall2")
			b.NotEnough:ClearAllPoints()
			b.NotEnough:SetPoint("BOTTOMLEFT",b.Title,"TOPLEFT",0,3)
		end
	else
		for i =1,#buttons do
			local b=buttons[i]
			b.Success:ClearAllPoints()
			b.Success:SetPoint("BOTTOMLEFT",b.Title,"TOPLEFT",0,3)
			b.NotEnough:SetFontObject("GameFontNormalSmall")
			b.NotEnough:SetPoint("TOPLEFT",b.Title,"BOTTOMLEFT",0,-3)
		end
	end
end
function addon:FixForSure()
	local rc=pcall(self.FixButtons,self)
	if (not rc) then
		self:ScheduleTimer("FixForSure",1)
	end
end
function addon:MasterPlanDetection(novar,...)
	local _,_,_,loadable,reason=GetAddOnInfo("MasterPlan")
	masterplan=false
	if (loadable or reason=="DEMAND_LOADED") then
		masterplan=true
		print("Rehooking tooltip")
		self:SecureHook("GarrisonMissionList_UpdateMissions","RestoreTooltip")
		self:FixForSure()
	end
end

