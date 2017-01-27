local __FILE__=tostring(debugstack(1,2,0):match("(.*):1:")) -- Always check line number in regexp and file, must be 1
local function pp(...) print(GetTime(),"|cff009900",__FILE__:sub(-15),strjoin(",",tostringall(...)),"|r") end
--*TYPE module
--*CONFIG noswitch=false,profile=true,enhancedProfile=true
--*MIXINS "AceHook-3.0","AceEvent-3.0","AceTimer-3.0"
--*MINOR 35
-- Generated on 20/01/2017 08:15:04
local me,ns=...
local addon=ns --#Addon (to keep eclipse happy)
ns=nil
local module=addon:NewSubModule('Missionlist',"AceHook-3.0","AceEvent-3.0","AceTimer-3.0")  --#Module
function addon:GetMissionlistModule() return module end
-- Template
local G=C_Garrison
local _
local AceGUI=LibStub("AceGUI-3.0")
local C=addon:GetColorTable()
local L=addon:GetLocale()
local new=addon.NewTable
local del=addon.DelTable
local kpairs=addon:GetKpairs()
local empty=addon:GetEmpty()
local OHF=OrderHallMissionFrame
local OHFMissionTab=OrderHallMissionFrame.MissionTab --Container for mission list and single mission
local OHFMissions=OrderHallMissionFrame.MissionTab.MissionList -- same as OrderHallMissionFrameMissions Call Update on this to refresh Mission Listing
local OHFFollowerTab=OrderHallMissionFrame.FollowerTab -- Contains model view
local OHFFollowerList=OrderHallMissionFrame.FollowerList -- Contains follower list (visible in both follower and mission mode)
local OHFFollowers=OrderHallMissionFrameFollowers -- Contains scroll list
local OHFMissionPage=OrderHallMissionFrame.MissionTab.MissionPage -- Contains mission description and party setup 
local OHFMapTab=OrderHallMissionFrame.MapTab -- Contains quest map
local followerType=LE_FOLLOWER_TYPE_GARRISON_7_0
local garrisonType=LE_GARRISON_TYPE_7_0
local FAKE_FOLLOWERID="0x0000000000000000"
local MAXLEVEL=110

local ShowTT=OrderHallCommanderMixin.ShowTT
local HideTT=OrderHallCommanderMixin.HideTT

local dprint=print
local ddump
--[===[@debug@
LoadAddOn("Blizzard_DebugTools")
ddump=DevTools_Dump
LoadAddOn("LibDebug")

if LibDebug then LibDebug() dprint=print end
local safeG=addon.safeG

--@end-debug@]===]
--@non-debug@
dprint=function() end
ddump=function() end
local print=function() end
--@end-non-debug@

-- End Template - DO NOT MODIFY ANYTHING BEFORE THIS LINE
--*BEGIN 
-- Additonal frames
local GARRISON_MISSION_AVAILABILITY2=GARRISON_MISSION_AVAILABILITY .. " %s"
local GARRISON_MISSION_ID="MissionID: %d"
local missionstats=setmetatable({}, {__mode = "v"})
local missionmembers=setmetatable({}, {__mode = "v"})
local missionthreats=setmetatable({}, {__mode = "v"})
local missionIDS={}
local spinners=setmetatable({}, {__mode = "v"})
local parties=setmetatable({}, {__mode = "v"})
local buttonlist={}
local oGarrison_SortMissions=Garrison_SortMissions
local function nop() end
local Current_Sorter
local sorters={
		Garrison_SortMissions_Original=nop,
		Garrison_SortMissions_Chance=function(a,b) 
			local aparty=addon:GetParties(a.missionID) 
			local bparty=addon:GetParties(b.missionID)
			return aparty.bestChance>bparty.bestChance 
		end,
		Garrison_SortMissions_Level=function(a,b) return a.level==b.level and a.iLevel>b.iLevel or a.level >b.level end,
		Garrison_SortMissions_Age=function(a,b) return (a.offerEndTime or 0) < (b.offerEndTime or 0) end,
		Garrison_SortMissions_Xp=function(a,b) 
			local aparty=addon:GetParties(a.missionID) 
			local bparty=addon:GetParties(b.missionID)
			return aparty.totalXP>bparty.totalXP 
		end,
		Garrison_SortMissions_Duration=function(a,b) 
			local aparty=addon:GetParties(a.missionID) 
			local bparty=addon:GetParties(b.missionID)
			return aparty.bestTimeseconds<bparty.bestTimeseconds 
		end,
		Garrison_SortMissions_Class=function(a,b)
			local a=addon:GetMissionData(a.missionID) 
			local b=addon:GetMissionData(b.missionID)
			return (a.missionSort or 0)>(b.missionSort or 0)
		end,
}
--[===[@debug@
local function Garrison_SortMissions_PostHook()
   print("Riordino le missioni")
   table.sort(OrderHallMissionFrame.MissionTab.MissionList.availableMissions,function(a,b) return a.name < b.name end)
end
--@end-debug@]===]
function module:OnInitialized()
-- Dunno why but every attempt of changing sort starts a memory leak
	local sorters={
		Garrison_SortMissions_Original=L["Original method"],
		Garrison_SortMissions_Chance=L["Success Chance"],
		Garrison_SortMissions_Level=L["Level"],
		Garrison_SortMissions_Age=L["Expiration Time"],
		Garrison_SortMissions_Xp=L["Global approx. xp reward"],
		Garrison_SortMissions_Duration=L["Duration Time"],
		Garrison_SortMissions_Class=L["Reward type"],
	}
	addon:AddSelect("SORTMISSION","Garrison_SortMissions_Original",sorters,	L["Sort missions by:"],L["Changes the sort order of missions in Mission panel"])
	addon:AddPrivateAction("HardRefreshMissions","Recalculate",L["Recalculate all parties"])
	addon:RegisterForMenu("mission","SORTMISSION","HardRefreshMissions")
	self:LoadButtons()
	self:RegisterEvent("GARRISON_MISSION_STARTED",function() wipe(missionIDS) wipe(parties) end)	
	Current_Sorter=addon:GetString("SORTMISSION")
	self:SecureHookScript(OHF--[[MissionTab--]],"OnShow","InitialSetup")
	--[===[@debug@
	pp("Current sorter",Current_Sorter)
	--@end-debug@]===]
	--hooksecurefunc("Garrison_SortMissions",Garrison_SortMissions_PostHook)--function(missions) module:SortMissions(missions) end)
	--self:SecureHook("Garrison_SortMissions",function(missionlist) print("Sorting",#missionlist,"missions") end)
	--function(missions) module:SortMissions(missions) end)
	self:SecureHookScript(OrderHallMissionFrameMissionsTab1,"OnClick","SortMissions")
	self:SecureHookScript(OrderHallMissionFrameMissionsTab2,"OnClick","SortMissions")
end
function module:Print(...)
	print(...)
end
function module:LoadButtons(...)
	buttonlist=OHFMissions.listScroll.buttons
	for i=1,#buttonlist do
		local b=buttonlist[i]	
		self:SecureHookScript(b,"OnEnter","AdjustMissionTooltip")
		self:SecureHookScript(b,"OnClick","PostMissionClick")
		b:RegisterForClicks("AnyDown")
		local scale=0.8
		local f,h,s=b.Title:GetFont()
		b.Title:SetFont(f,h*scale,s)
		local f,h,s=b.Summary:GetFont()
		b.Summary:SetFont(f,h*scale,s)		
	end
end
-- This method is called also when overing on tooltips
-- keeps a reference to the mission currently bound to this button
function module:OnUpdate()
	local tipOwner=GameTooltip:GetOwner()
	tipOwner=tipOwner and tipOwner:GetName() or "none"
	local skipDataRefresh=tipOwner:find("OrderHallMissionFrameMissionsListScrollFrameButto")==1
--[===[@debug@
	print("OnUpdate")
--@end-debug@	]===]
	for _,frame in pairs(buttonlist) do
		if frame:IsVisible() then
			self:AdjustPosition(frame)
			if not skipDataRefresh  and frame.info.missionID ~= missionIDS[frame] then
				self:AdjustMissionButton(frame)
				missionIDS[frame]=frame.info.missionID
			end
		end
	end
end
-- called when needed a full upodate (reload mission data)
function module:OnUpdateMissions(...)
	if OHFMissions:IsVisible() then
		addon:ResetParties()
		--self:SortMissions()
		--OHFMissions:Update()
		--for _,frame in pairs(buttonlist) do
		--	if frame:IsVisible() then
		--		self:AdjustMissionButton(frame,frame.info.rewards)
		--	end
		--end
	end
end
local function sortfunc1(a,b)
	return a.timeLeftSeconds < b.timeLeftSeconds
end
local prova={
	{followerTypeID=1},
	{followerTypeID=2},
}
function module:SortMissions()
	if OHFMissions:IsVisible() then
		if OHFMissions.inProgress then
			table.sort(OHFMissions.inProgressMissions,sortfunc1)
		else
			table.sort(OrderHallMissionFrame.MissionTab.MissionList.availableMissions,sorters[Current_Sorter])
			--Garrison_SortMissions(OHFMissions.availableMissions)
			--Garrison_SortMissions(prova)
		end
		OHFMissions:Update()
	end
end
function addon:ApplySORTMISSION(value)
	Current_Sorter=value
	module:SortMissions()
end
function addon:HardRefreshMissions()
--[===[@debug@
	print("Called hard refresh")
--@end-debug@]===]
	self:RebuildAllCaches()
	collectgarbage()
	self:RefreshMissions()
end
local timer
function addon:RefreshMissions()
	if OHFMissionPage:IsVisible() then
		module:PostMissionClick(OHFMissionPage)
	else	
		if timer then self:CancelTimer(timer) end 
		timer=self:ScheduleTimer("EffectiveRefresh",0.1)
	end
end
function addon:EffectiveRefresh()
	timer=nil
	wipe(parties)
	wipe(missionIDS)
	module:OnUpdate()
end
local function ToggleSet(this,value)
	return addon:ToggleSet(this.flag,this.tipo,value)
end
local function ToggleGet(this)
	return addon:ToggleGet(this.flag,this.tipo)
	
end
local function PreToggleSet(this)
	return ToggleSet(this,this:GetChecked())
end
local pin
local close
local menu
local button
local function OpenMenu()
	addon.db.profile.showmenu=true
	button:Hide()
	menu:Show()		
end
local function CloseMenu()
	addon.db.profile.showmenu=false
	button:Show()
	menu:Hide()		
end
function module:Menu()
	local previous
	local factory=addon:GetFactory()
	for _,v in pairs(addon:GetRegisteredForMenu("mission")) do
		local flag,icon=strsplit(',',v)
		local f=factory:Option(addon,menu,flag)
		if type(f)=="table" and f.GetObjectType then
			if flag=="MAXCHAMP" then f:SetStep(1) end
			if previous then 
				f:SetPoint("TOPLEFT",previous,"BOTTOMLEFT",0,-10)
			else
				f:SetPoint("TOPLEFT",menu,"TOPLEFT",32,-30)
			end
			previous=f
		end
	end 
end

function module:InitialSetup(this)
	if type(addon.db.global.warn01_seen)~="number" then	addon.db.global.warn01_seen =0 end
	if type(addon.db.global.warn02_seen)~="number" then	addon.db.global.warn02_seen =0 end
	if GetAddOnEnableState(UnitName("player"),"GarrisonCommander") > 0 then
		if addon.db.global.warn02_seen  < 3 then
			addon.db.global.warn02_seen=addon.db.global.warn02_seen+1
			addon:Popup(L["OrderHallCommander overrides GarrisonCommander for Order Hall Management.\n You can revert to GarrisonCommander simply disabling OrderhallCommander.\nIf instead you like OrderHallCommander remember to add it to Curse client and keep it updated"],20)
		end
	end 
	menu=CreateFrame("Frame",nil,OHFMissionTab,"OHCMenu")
	menu.Title:SetText(me .. ' ' .. addon.version)
	menu.Title:SetTextColor(C:Yellow())
	close=menu.CloseButton
	button=CreateFrame("Button",nil,OHFMissionTab,"OHCPin")
	button.tooltip=L["Show/hide OrderHallCommander mission menu"]
	close:SetScript("OnClick",CloseMenu)
	button:SetScript("OnClick",OpenMenu)
	button:GetNormalTexture():SetRotation(math.rad(270))
	button:GetHighlightTexture():SetRotation(math.rad(270))
	self:Menu()
	if addon.db.profile.showmenu then OpenMenu() else CloseMenu() end
	addon.MAXLEVEL=OHF.followerMaxLevel
	addon.MAXQUALITY=OHF.followerMaxQuality
	addon.MAXQLEVEL=addon.MAXLEVEL+addon.MAXQUALITY
	self:Unhook(this,"OnShow")
	self:SecureHookScript(this,"OnShow","MainOnShow")	
	self:SecureHookScript(this,"OnHide","MainOnHide")	
	OHF.FollowerStatusInfo=OHF:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	OHF.FollowerStatusInfo:SetPoint("TOPRIGHT",-45,-5)
	OHF.FollowerStatusInfo:SetText("")
	self:MainOnShow()
end
function module:MainOnShow()
	self:SecureHook(OHFMissions,"Update","OnUpdate")
	self:Hook(OHFMissions,"UpdateMissions","OnUpdateMissions",true)
	--self:SecureHook(OHFMissions,"UpdateCombatAllyMission",function() pp("Called inside updatemissions") pp("\n",debugstack(1)) end)
	self:OnUpdate()
	addon:ApplySORTMISSION(addon:GetString("SORTMISSION"))
	addon:RefreshFollowerStatus()
	addon:ParseFollowers()
end
function module:MainOnHide()
	self:Unhook(OHFMissions,"UpdateCombatAllyMission")
	self:Unhook(OHFMissions,"UpdateMissions")
	self:Unhook(OHFMissions,"Update")
	self:Unhook(OHFMissions,"OnUpdate")
end
function module:AdjustPosition(frame)
	local mission=frame.info
	frame.Title:ClearAllPoints()
	if  mission.isResult then
		frame.Title:SetPoint("TOPLEFT",165,15)
	elseif  mission.inProgress then
		--frame.Title:SetPoint("TOPLEFT",165,-10)
	else
		frame.Title:SetPoint("TOPLEFT",165,-7)
	end
	if mission.isRare then 
		frame.Title:SetTextColor(frame.RareText:GetTextColor())
	else
		frame.Title:SetTextColor(C:White())
	end
	frame.RareText:Hide()
	-- Compacting mission time and level
	frame.RareText:Hide()
	frame.Level:ClearAllPoints()
	frame.MissionType:ClearAllPoints()
	frame.ItemLevel:Hide()
	frame.Level:SetPoint("LEFT",5,0)
	frame.MissionType:SetPoint("LEFT",5,0)		
	if mission.isMaxLevel then
		frame.Level:SetText(mission.iLevel)
	else
		frame.Level:SetText(mission.level)
	end
	local missionID=mission.missionID
end
function module:AdjustMissionButton(frame)
	if not OHF:IsVisible() then return end
	local mission=frame.info
	local missionID=mission and mission.missionID
	if not missionID then return end
	missionIDS[frame]=missionID
	-- Adding stats frame (expiration date and chance)
	if not missionstats[frame] then
		missionstats[frame]=CreateFrame("Frame",nil,frame,"OHCStats")
--[===[@debug@
		self:RawHookScript(missionstats[frame],"OnEnter","MissionTip")
--@end-debug@		]===]
	end
	local stats=missionstats[frame]
	local aLevel,aIlevel=addon:GetAverageLevels()
	if mission.isMaxLevel then
		frame.Level:SetText(mission.iLevel)
		frame.Level:SetTextColor(addon:GetDifficultyColors(math.floor((aIlevel-750)/(mission.iLevel-750)*100)))
	else
		frame.Level:SetText(mission.level)
		frame.Level:SetTextColor(addon:GetDifficultyColors(math.floor(aLevel/mission.level*100)))
	end
	if mission.inProgress then
		stats:SetPoint("LEFT",48,14)
		stats.Expire:Hide()
		addon:GetCacheModule():SetMissionStatus(missionID,'inProgress')
	else
		stats.Expire:SetFormattedText("%s\n%s",GARRISON_MISSION_AVAILABILITY,mission.offerTimeRemaining)
		stats.Expire:SetTextColor(addon:GetAgeColor(mission.offerEndTime))		
		stats:SetPoint("LEFT",48,0)
		stats.Expire:Show()
	end
	stats.Chance:Show()
	if not missionmembers[frame] then
		missionmembers[frame]=CreateFrame("Frame",nil,frame,"OHCMembers")
	end
	if not missionthreats[frame] then
		missionthreats[frame]=CreateFrame("Frame",nil,frame,"OHCThreats")
	end
	self:AddMembers(frame)
end
function module:AddMembers(frame)
	local start=GetTime()
	local mission=frame.info
	local nrewards=#mission.rewards
	local missionID=mission and mission.missionID
	local followers=mission.followers
	local key
	local party
	if not key then
		party,key=addon:GetSelectedParty(missionID,mission)
		parties[missionID]=key
--[===[@debug@
		print("Party recalculated",party)
--@end-debug@		]===]
	else
--[===[@debug@
		print(key,"Party retrieved",party)
--@end-debug@		]===]
		party=addon:GetSelectedParty(missionID,key)
	end
	local members=missionmembers[frame]
	members:SetNotReady()
	local stats=missionstats[frame]
	members:SetPoint("RIGHT",frame.Rewards[nrewards],"LEFT",-5,0)
	for i=1,mission.numFollowers do
		if party:Follower(i) then
			members.Champions[i]:SetFollower(party:Follower(i),not mission.inProgress)
		else
			members.Champions[i]:SetEmpty()
		end
		members.Champions[i]:Show()
	end
	for i=mission.numFollowers+1,3 do
			members.Champions[i]:Hide()
		
	end
		
	local perc=party.perc or 0
	if perc==0 then
		stats.Chance:SetText("N/A")
	else
		stats.Chance:SetFormattedText(PERCENTAGE_STRING,perc)
	end		
	stats.Chance:SetTextColor(addon:GetDifficultyColors(perc))

	local threats=missionthreats[frame]
	if frame.info.inProgress then
		frame.Overlay:SetFrameLevel(20)
		threats:Hide()
		return
	else
		threats:Show()
	end
	threats:SetPoint("TOPLEFT",frame.Title,"BOTTOMLEFT",0,-5)
	local enemies=addon:GetMissionData(missionID,'enemies')
	if type(enemies)~="table" then 
		enemies=select(8,G.GetMissionInfo(missionID))
	end
	local mechanics=new()
	local counters=new()
	local biases=new()
	for _,enemy in pairs(enemies) do
		if type(enemy.mechanics)=="table" then
		   for mechanicID,mechanic in pairs(enemy.mechanics) do
	   	-- icon=enemy.mechanics[id].icon
	   		mechanic.id=mechanicID
	   		mechanic.bias=-1
				tinsert(mechanics,mechanic)
	   	end
   	end
   end
   for _,followerID in party:IterateFollowers() do
   	if not G.GetFollowerIsTroop(followerID) then
		   local followerBias = G.GetFollowerBiasForMission(missionID,followerID)
		   tinsert(counters,("%04d,%s,%s,%f"):format(1000-(followerBias*100),followerID,G.GetFollowerName(followerID),followerBias))
	   end
   end
   table.sort(counters)
   for _,data in pairs(counters) do
   	local _,followerID,_,bias=strsplit(",",data)
      local abilities=G.GetFollowerAbilities(followerID)
      for _,ability in pairs(abilities) do
         for counter,info in pairs(ability.counters) do
         	for _,mechanic in pairs(mechanics) do
         		if mechanic.id==counter and not biases[mechanic] then
         			biases[mechanic]=tonumber(bias)
         			break
         		end
         	end
         end
		end
   end
   local color="Yellow"
   local baseCost, cost = party.baseCost ,party.cost
	if cost<baseCost then
		color="Green"
	elseif cost>baseCost then
		color="Red"
	end
	if frame.IsCustom or OHFMissions.showInProgress then
		cost=-1
	end
   if not threats:AddIconsAndCost(mechanics,biases,cost,color,cost > addon:GetResources()) then
   	addon:RefreshMissions()
   end
   del(mechanics)
   del(counters)
   del(biases)
end
function module:MissionTip(this)
	local tip=GameTooltip
	tip:SetOwner(this,"ANCHOR_CURSOR")	
	tip:AddLine(me)
	tip:AddDoubleLine(addon:GetAverageLevels())
--[===[@debug@
	local info=this:GetParent().info
	OrderHallCommanderMixin.DumpData(tip,info)
	tip:AddLine("Followers")
	for i,id in ipairs(info.followers) do
		tip:AddDoubleLine(id,pcall(G.GetFollowerName,id))
	end
	tip:AddLine("Rewards")
	for i,d in pairs(info.rewards) do
		tip:AddLine('['..i..']')
		OrderHallCommanderMixin.DumpData(tip,info.rewards[i])
	end
	tip:AddLine("OverRewards")
	for i,d in pairs(info.overmaxRewards) do
		tip:AddLine('['..i..']')
		OrderHallCommanderMixin.DumpData(tip,info.overmaxRewards[i])
	end
	tip:AddDoubleLine("MissionID",info.missionID)
	local mission=addon:GetMissionData(info.missionID)
	tip:AddDoubleLine("MissionClass",mission.missionClass)
	tip:AddDoubleLine("MissionValue",mission.missionValue)
	tip:AddDoubleLine("MissionSort",mission.missionSort)
	
--@end-debug@	]===]
	tip:Show()
end
local bestTimes={}
local bestTimesIndex={}
local nobonusloot=G.GetFollowerAbilityDescription(471)
local increasedcost=G.GetFollowerAbilityDescription(472)
local increasedduration=G.GetFollowerAbilityDescription(428)
local killtroops=G.GetFollowerAbilityDescription(437)
function module:AdjustMissionTooltip(this,...)
	if this.info.inProgress or this.info.completed then return end
	local missionID=this.info.missionID
	local tip=GameTooltip
	if not this.info.isRare then
		GameTooltip:AddLine(GARRISON_MISSION_AVAILABILITY);
		GameTooltip:AddLine(this.info.offerTimeRemaining, 1, 1, 1);
	end
--[===[@debug@
	tip:AddDoubleLine("MissionID",missionID)
--@end-debug@	]===]
	local party=addon:GetParties(missionID)
	local key=parties[missionID]
	if party then
		local candidate =party:GetSelectedParty(key)
		if candidate then
			if candidate.hasBonusLootNegativeEffect then
				GameTooltip:AddLine(nobonusloot,C:Red())
			end
			if candidate.hasKillTroopsEffect then
				GameTooltip:AddLine(killtroops,C:Red())
			end
			if candidate.hasResurrectTroopsEffect then
				GameTooltip:AddLine(L["Resurrect troops effect"],C:Green())
			end
			if candidate.cost > candidate.baseCost then
				GameTooltip:AddLine(increasedcost,C:Red())
			end
			if candidate.hasMissionTimeNegativeEffect then
				GameTooltip:AddLine(increasedduration,C:Red())
			end
			if candidate.timeImproved then
				GameTooltip:AddLine(L["Duration reduced"],C:Green())
			end
			-- Not important enough to be specifically shown
			-- hasSuccessChanceNegativeEffect
			-- hasUncounterableSuccessChanceNegativeEffect
		end
	end
	-- Mostrare per ogni tempo di attesa solo la percentuale migliore
	wipe(bestTimes)
	wipe(bestTimesIndex)
	key=key or "999999999999999999999"
	if key then
		for _,otherkey in party:IterateIndex() do
			if otherkey < key then
				local candidate=party:GetSelectedParty(otherkey)
				local duration=math.max((candidate.busyUntil or 0)-GetTime(),0)
				if duration > 0 then
					if not bestTimes[duration] or bestTimes[duration] < candidate.perc then
						bestTimes[duration]=candidate.perc
					end
				end
			end
		end
		for t,p in pairs(bestTimes) do
			tinsert(bestTimesIndex,t)
		end
		if #bestTimesIndex > 0 then
			tip:AddLine(me)
			tip:AddLine(L["Better parties available in next future"])
			table.sort(bestTimesIndex)
			local bestChance=0
			for i=1,#bestTimesIndex do
				local key=bestTimesIndex[i]
				if bestTimes[key] > bestChance then
					bestChance=bestTimes[key]
					tip:AddDoubleLine(SecondsToTime(key),GARRISON_MISSION_PERCENT_CHANCE:format(bestChance),C.Orange.r,C.Orange.g,C.Orange.b,addon:GetDifficultyColors(bestChance))
				end
			end
		end
--[===[@debug@
		tip:AddLine("-----------------------------------------------")
		OrderHallCommanderMixin.DumpData(tip,addon:GetParties(this.info.missionID):GetSelectedParty(key))
--@end-debug@]===]
	end
	tip:Show()
	
end
function module:PostMissionClick(this,button)
	local mission=this.info or this.missionInfo -- callable also from mission page
--[===[@debug@
	addon:Print(button)
	if button=="MiddleButton" then
		addon:TestParty(mission.missionID)
		return
	end
--@end-debug@]===]
	addon:GetMissionpageModule():FillMissionPage(mission,parties[mission.missionID])
end
do
	local s=setmetatable({},{__index=function(t,k) return 0 end})
	local FOLLOWER_STATUS_FORMAT= L["Followers status "] ..
								C(AVAILABLE..':%d ','green') ..
								C(GARRISON_FOLLOWER_COMBAT_ALLY .. ":%d ",'cyan') ..
								C(GARRISON_FOLLOWER_ON_MISSION .. ":%d ",'red') ..
								C(GARRISON_FOLLOWER_INACTIVE .. ":%d","silver")
	function addon:RefreshFollowerStatus()
		if not OHF:IsVisible() then return end
		if empty(addon:GetFollowerData()) then return end
		wipe(s)
		for followerID,_ in pairs(addon:GetFollowerData()) do
			local rc,status=pcall(G.GetFollowerStatus,followerID) -- Follower could have been exhasted and still present in cache
			if rc then
				status=status or AVAILABLE
				s[status]=s[status]+1
			end
		end
		if (OHF.FollowerStatusInfo) then
			OHF.FollowerStatusInfo:SetWidth(0)
			OHF.FollowerStatusInfo:SetFormattedText(
				FOLLOWER_STATUS_FORMAT,
				s[AVAILABLE],
				s[GARRISON_FOLLOWER_COMBAT_ALLY],
				s[GARRISON_FOLLOWER_ON_MISSION],
				s[GARRISON_FOLLOWER_INACTIVE]
				)
		end
	end
	function addon:GetTotFollowers(status)
		if not status then
			return s[AVAILABLE]+
				s[GARRISON_FOLLOWER_WORKING]+
				s[GARRISON_FOLLOWER_ON_MISSION]
		else
			return s[status] or 0
		end
	end
end

