local me, ns = ...
local _G=_G
local pp=print
local HD=false
--[===[@debug@
	LoadAddOn("Blizzard_DebugTools")
--@end-debug@]===]
local addon=LibStub("LibInit"):NewAddon(me,'AceHook-3.0','AceTimer-3.0','AceEvent-3.0','AceBucket-3.0') --#Addon
local AceGUI=LibStub("AceGUI-3.0")
local D=LibStub("LibDeformat-3.0")
local C=addon:GetColorTable()
local L=addon:GetLocale()
local print=addon:Wrap("Print")
local trace=addon:Wrap("Trace")
local xprint=function() end
local xdump=function() end
local xtrace=function() end
--[===[@debug@
--xprint=function(...) print("DBG",...) end
--xdump=function(d,t) print(t) DevTools_Dump(d) end
--xtrace=trace
--@end-debug@]===]
local pairs=pairs
local select=select
local next=next
local tinsert=tinsert
local tremove=tremove
local setmetatable=setmetatable
local getmetatable=getmetatable
local type=type
local GetAddOnMetadata=GetAddOnMetadata
local CreateFrame=CreateFrame
local wipe=wipe
local format=format
local tostring=tostring
local collectgarbage=collectgarbage
local bigscreen=true
local GMM=false
local MP=false
local MPGoodGuy=false
local MPSwitch
local dbg=false
local trc=false
local pin=false
local baseHeight
local minHeight
if (LibDebug) then LibDebug() end
local function tcopy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[tcopy(k, s)] = tcopy(v, s) end
	return res
end
--@end-debug@
-----------------------------------------------------------------
-- Recycling function from ACE3



local new, del, copy
do
	--[===[@debug@
	local newcount, delcount,createdcount,cached = 0,0,0
	--@end-debug@]===]
	local pool = setmetatable({},{__mode="k"})
	function new()
	--[===[@debug@
		newcount = newcount + 1
	--@end-debug@]===]
		local t = next(pool)
		if t then
			pool[t] = nil
			return t
		else
	--[===[@debug@
			createdcount = createdcount + 1
	--@end-debug@]===]
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
	--[===[@debug@
		delcount = delcount + 1
	--@end-debug@]===]
		wipe(t)
		pool[t] = true
	end
	--[===[@debug@
	function cached()
		local n = 0
		for k in pairs(pool) do
			n = n + 1
		end
		return n
	end
	function addon:CacheStats()
		print("Created:",createdcount)
		print("Aquired:",newcount)
		print("Released:",delcount)
		print("Cached:",cached())
	end
	--@end-debug@]===]
end

local function capitalize(s)
	s=tostring(s)
	return strupper(s:sub(1,1))..strlower(s:sub(2))
end
--- upvalues
--
--local AVAILABLE=AVAILABLE -- "Available"
local BUTTON_INFO=GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS.. " " .. GARRISON_MISSION_PERCENT_CHANCE
--local ENVIRONMENT_SUBHEADER=ENVIRONMENT_SUBHEADER -- "Environment"
local G=C_Garrison
--local GARRISON_BUILDING_SELECT_FOLLOWER_TITLE=GARRISON_BUILDING_SELECT_FOLLOWER_TITLE -- "Select a Follower";
--local GARRISON_BUILDING_SELECT_FOLLOWER_TOOLTIP=GARRISON_BUILDING_SELECT_FOLLOWER_TOOLTIP -- "Click here to assign a Follower";
--local GARRISON_FOLLOWERS=GARRISON_FOLLOWERS -- "Followers"
--local GARRISON_FOLLOWER_CAN_COUNTER=GARRISON_FOLLOWER_CAN_COUNTER -- "This follower can counter:"
--local GARRISON_FOLLOWER_EXHAUSTED=GARRISON_FOLLOWER_EXHAUSTED -- "Recovering (1 Day)"
--local GARRISON_FOLLOWER_INACTIVE=GARRISON_FOLLOWER_INACTIVE --"Inactive"
--local GARRISON_FOLLOWER_IN_PARTY=GARRISON_FOLLOWER_IN_PARTY
--local GARRISON_FOLLOWER_ON_MISSION=GARRISON_FOLLOWER_ON_MISSION -- "On Mission"
--local GARRISON_FOLLOWER_WORKING=GARRISON_FOLLOWER_WORKING -- "Working
local GARRISON_MISSION_PERCENT_CHANCE="%d%%"-- GARRISON_MISSION_PERCENT_CHANCE
--local GARRISON_MISSION_SUCCESS=GARRISON_MISSION_SUCCESS -- "Success"
--local GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS=GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS -- "%d Follower mission";
--local GARRISON_PARTY_NOT_FULL_TOOLTIP=GARRISON_PARTY_NOT_FULL_TOOLTIP -- "You do not have enough followers on this mission."
--local GARRISON_MISSION_CHANCE=GARRISON_MISSION_CHANCE -- Chanche
--local GARRISON_FOLLOWER_BUSY_COLOR=GARRISON_FOLLOWER_BUSY_COLOR
--local GARRISON_FOLLOWER_INACTIVE_COLOR=GARRISON_FOLLOWER_INACTIVE_COLOR
--local GARRISON_CURRENCY=GARRISON_CURRENCY  --824
--local GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY=GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY -- 4
--local GARRISON_FOLLOWER_MAX_LEVEL=GARRISON_FOLLOWER_MAX_LEVEL -- 100
local SHORTDATE=SHORTDATE.. " %s"
local LEVEL=LEVEL -- Level
local MISSING=ADDON_MISSING
local NOT_COLLECTED=NOT_COLLECTED -- not collected
local GMF=GarrisonMissionFrame
local GMFFollowerPage=GMF.FollowerTab
local GMFFollowers=GarrisonMissionFrameFollowers
local GMFMissionPage=GMF.MissionTab.MissionPage
local GMFMissionPageFollowers = GMFMissionPage.Followers
local GMFMissions=GarrisonMissionFrameMissions
local GMFRewardPage=GMF.MissionComplete
local GMFRewardSplash=GMFMissions.CompleteDialog
local GMFMissionsListScrollFrameScrollChild=GarrisonMissionFrameMissionsListScrollFrameScrollChild
local GMFMissionsListScrollFrame=GarrisonMissionFrameMissionsListScrollFrame
local GMFFollowersListScrollFrameScrollChild=GarrisonMissionFrameFollowersListScrollFrameScrollChild
local GMFFollowersListScrollFrame=GarrisonMissionFrameFollowersListScrollFrame
local GMFMissionListButtons=GMF.MissionTab.MissionList.listScroll.buttons
local GarrisonFollowerTooltip=GarrisonFollowerTooltip
local GarrisonMissionFrameMissionsListScrollFrame=GarrisonMissionFrameMissionsListScrollFrame
local IGNORE_UNAIVALABLE_FOLLOWERS=IGNORE.. ' ' .. UNAVAILABLE
local IGNORE_UNAIVALABLE_FOLLOWERS_DETAIL=IGNORE.. ' ' .. GARRISON_FOLLOWER_INACTIVE .. ',' .. GARRISON_FOLLOWER_ON_MISSION ..',' .. GARRISON_FOLLOWER_WORKING.. ' ' .. GARRISON_FOLLOWERS
local PARTY=PARTY -- "Party"
local SPELL_TARGET_TYPE1_DESC=capitalize(SPELL_TARGET_TYPE1_DESC) -- any
local SPELL_TARGET_TYPE4_DESC=capitalize(SPELL_TARGET_TYPE4_DESC) -- party member
local ANYONE='('..SPELL_TARGET_TYPE1_DESC..')'
local UNKNOWN_CHANCE=GARRISON_MISSION_PERCENT_CHANCE:gsub('%%d%%%%',UNKNOWN)
IGNORE_UNAIVALABLE_FOLLOWERS=capitalize(IGNORE_UNAIVALABLE_FOLLOWERS)
IGNORE_UNAIVALABLE_FOLLOWERS_DETAIL=capitalize(IGNORE_UNAIVALABLE_FOLLOWERS_DETAIL)
local UNKNOWN=UNKNOWN -- Unknown
local TYPE=TYPE -- Type
local ALL=ALL -- All
local MAXMISSIONS=8
local MINPERC=20
local BUSY_MESSAGE_FORMAT=L["Only first %1$d missions with over %2$d%% chance of success are shown"]
local BUSY_MESSAGE=format(BUSY_MESSAGE_FORMAT,MAXMISSIONS,MINPERC)

local function splitFormat(base)
	local i,s=base:find("|4.*:.*;")
	if (not i) then
		return base,base
	end
	local m0,m1=base:match("|4(.*):(.*);")
	local G=base
	local G1=G:sub(1,i-1)..m0..G:sub(s+1)
	local G2=G:sub(1,i-1)..m1..G:sub(s+1)
	return G1,G2
end
local function ShowTT(this)
	GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT")
	GameTooltip:SetText(this.tooltip)
	GameTooltip:Show()
end

local GARRISON_DURATION_DAY,GARRISON_DURATION_DAYS=splitFormat(GARRISON_DURATION_DAYS) -- "%d |4day:days;";
local GARRISON_DURATION_DAY_HOURS,GARRISON_DURATION_DAYS_HOURS=splitFormat(GARRISON_DURATION_DAYS_HOURS) -- "%d |4day:days; %d hr";
local GARRISON_DURATION_HOURS=GARRISON_DURATION_HOURS -- "%d hr";
local GARRISON_DURATION_HOURS_MINUTES=GARRISON_DURATION_HOURS_MINUTES -- "%d hr %d min";
local GARRISON_DURATION_MINUTES=GARRISON_DURATION_MINUTES -- "%d min";
local GARRISON_DURATION_SECONDS=GARRISON_DURATION_SECONDS -- "%d sec";
local AGE_HOURS="Expires in " .. GARRISON_DURATION_HOURS_MINUTES
local AGE_DAYS="Expires in " .. GARRISON_DURATION_DAYS_HOURS


-- Panel sizes
local BIGSIZEW=1220
local BIGSIZEH=662
local SIZEW=950
local SIZEH=662
local SIZEV
local GCSIZE=700
local FLSIZE=400
local BIGBUTTON=BIGSIZEW-GCSIZE
local SMALLBUTTON=BIGSIZEW-GCSIZE
local GCF
local GMC
local GMCUsedFollowers={}
local GCFMissions
local GCFBusyStatus
local GameTooltip=GameTooltip
-- Want to know what I call!!
--local GarrisonMissionButton_OnEnter=GarrisonMissionButton_OnEnter
local GarrisonFollowerList_UpdateFollowers=GarrisonFollowerList_UpdateFollowers
local GarrisonMissionList_UpdateMissions=GarrisonMissionList_UpdateMissions
local GarrisonMissionPage_ClearFollower=GarrisonMissionPage_ClearFollower
local GarrisonMissionPage_UpdateMissionForParty=GarrisonMissionPage_UpdateMissionForParty
local GarrisonMissionPage_SetFollower=GarrisonMissionPage_SetFollower
local GarrisonMissionButton_SetRewards=GarrisonMissionButton_SetRewards
local GetItemInfo=GetItemInfo
local type=type
local ITEM_QUALITY_COLORS=ITEM_QUALITY_COLORS
function addon:GetDifficultyColors(perc,usePurple)
	local q=self:GetDifficultyColor(perc,usePurple)
	return q.r,q.g,q.b
end
function addon:GetDifficultyColor(perc,usePurple)
	if(perc >90) then
		return QuestDifficultyColors['standard']
	elseif (perc >74) then
		return QuestDifficultyColors['difficult']
	elseif(perc>49) then
		return QuestDifficultyColors['verydifficult']
	elseif(perc >20) then
		return QuestDifficultyColors['impossible']
	else
		return not usePurple and C.Silver or C.Fuchsia
	end
end
if (LibDebug) then LibDebug() end
----- Local variables
--
-- Forces a table to countain other tables,
local t1={
	__index=function(t,k) rawset(t,k,{}) return t[k] end
}
local t2={
	__index=function(t,k) rawset(t,k,setmetatable({},t1)) return t[k] end
}
local followersCache={}
local followersCacheIndex={}
local dirty=false
local cache
local dbcache
local db
local n=setmetatable({},{
	__index = function(t,k)
		local name=addon:GetFollowerData(k,'fullname')
		if (name) then rawset(t,k,name) return name else return k end
	end
})

-- Counter system
local function cleanicon(stringa)
	return (stringa:lower():gsub("%.blp$",""))
end
local counters=setmetatable({},t2)
local counterThreatIndex=setmetatable({},t2)
local counterFollowerIndex=setmetatable({},t2)
--- Quick backdrop
--
local backdrop = {
	bgFile="Interface\\TutorialFrame\\TutorialFrameBackground",
	edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
	tile=true,
	tileSize=16,
	edgeSize=16,
	insets={bottom=7,left=7,right=7,top=7}
}
local function addBackdrop(f)
	f:SetBackdrop(backdrop)
end

--generic table scan

local function inTable(table, value)
	if (type(table)~='table') then return false end
	if (#table > 0) then
		for i=1,#table do
			if (value==table[i]) then return true end
		end
	else
		for k,v in pairs(table) do
			if v == value then
				return true
			end
		end
	end
	return false
end


--- Parties storage
--
--
local parties=setmetatable({},{
	__index=function(t,k)  rawset(t,k,{members={},perc=0,full=false}) return t[k] end
})
local function inParty(missionID,followerID)
	return inTable(parties[missionID].members,followerID)
end
--- Follower Missions Info
--
local followerMissions=setmetatable({},{
	__index=function(t,k)  rawset(t,k,{}) return t[k] end
})


local holdEvents,releaseEvents
do
	local frames
	function holdEvents()
		frames={GetFramesRegisteredForEvent('GARRISON_FOLLOWER_LIST_UPDATE')}
		for i=1,#frames do
			frames[i]:UnregisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
		end
	end
	function releaseEvents()
		for i=1,#frames do
			frames[i]:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
		end
		frames=nil
	end
end

--
-- Temporary party management
local openParty,partyIgnore,isPartyIgnored,isInParty,pushFollower,removeFollower,fillParty,closeParty,roomInParty,storeFollowers,dumpParty,isPartyEmpty

do
	local ID,maxFollowers,members,ignored=0,1,{},{}
	---@function [parent=#party] openParty
	function openParty(missionID,followers)
		wipe(members)
		maxFollowers=followers
		ID=missionID
		holdEvents()
	end

	---@function [parent=#party] partyIgnore
	function partyIgnore(followerID,soft)
		ignored[followerID]=soft and 1 or 2
	end
	---@function [parent=#party] isPartyIgnored
	function isPartyIgnored(followerID)
		return ignored[followerID]
	end

	---@function [parent=#party] isInParty
	function isInParty(followerID)
		return inTable(members,followerID)
	end

	---@function [parent=#party] roomInParty
	function roomInParty()
		return maxFollowers-#members
	end

	---@function [parent=#party] isPartyEmpty
	function isPartyEmpty()
		return maxFollowers>0 and #members==0
	end

	---@function [parent=#party] dumpParty
	function dumpParty()
		for i=1,3 do
			if (members[i]) then
				xprint(i,addon:GetFollowerData(members[i],'fullname'))
			end
		end
	end

	---@function [parent=#party] pushFollower
	function pushFollower(followerID)
		if (followerID:sub(1,2) ~= '0x') then trace(followerID .. "is not an id") end
		if (roomInParty()>0) then
			local rc,code=pcall (C_Garrison.AddFollowerToMission,ID,followerID)
			if (rc and code) then
				tinsert(members,followerID)
				return true
--[===[@debug@
			else
				xprint("Unable to add", n[followerID],"to",ID,code)
--@end-debug@]===]
			end
		end
	end
	---@function [parent=#party] removeFollowers
	function removeFollower(followerID)
		for i=1,maxFollowers do
			if (followerID==members[i]) then
				tremove(members,i)
				local rc,code=pcall(C_Garrison.RemoveFollowerFromMission,ID,followerID)
--[===[@debug@
				if (not rc) then trace("Unable to remove", n[members[i]],"from",ID,code) end
--@end-debug@]===]
			return true end
		end
	end

	---@function [parent=#party] storeFollowers
	function storeFollowers(table)
		wipe(table)
		for i=1,#members do
			tinsert(table,members[i])
		end
		return #table
	end
	---@function [parent=#party] fillParty
	function fillParty()
		if roomInParty() < 1 then return end
		for followerID,soft in pairs(ignored) do
			if soft==1 then
				if not isInParty(followerID) then
					pushFollower(followerID)
				end
				if (roomInParty()<=0) then
					break
				end
			end
		end
	end

	---@function [parent=#party] closeParty
	function closeParty()
		local perc=select(4,G.GetPartyMissionInfo(ID))
		for i=1,3 do
			if (members[i]) then
				local rc,code=pcall(C_Garrison.RemoveFollowerFromMission,ID,members[i])
--[===[@debug@
				if (not rc) then trace("Unable to pop", members[i]," from ",ID,code) end
--@end-debug@]===]

			else
				break
			end
		end
		releaseEvents()
		wipe(members)
		wipe(ignored)
		return perc or 0
	end
end
--
--[===[@debug@
local origGarrisonMissionButton_OnEnter = _G.GarrisonMissionButton_OnEnter
function _G.GarrisonMissionButton_OnEnter(this,button)
	origGarrisonMissionButton_OnEnter(this,button)
	GameTooltip:AddDoubleLine("ID:",this.info.missionID)
	GameTooltip:Show()
end
--@end-debug@]===]
-- These local will became conf var
-- locally upvalued, doing my best to not interfere with other sorting modules,
-- First time i am called to verride it I save it, so I give other modules a chance to hook it, too
-- Could even do a trick and secureHook it at the expense of a double sort...
local origGarrison_SortMissions

function addon.Garrison_SortMissions_Chance(missionsList)

	local comparison
	do
		function comparison(mission1, mission2)
			if type(mission1)~="table" or type(mission2) ~="table" then return end
			local p1=parties[mission1.missionID]
			local p2=parties[mission2.missionID]
			if (p2.full and not p1.full) then return false end
			if (p1.full and not p2.full) then return true end
			if (p1.perc==p2.perc) then
				return strcmputf8i(mission1.name, mission2.name) < 0
			else
				return p1.perc > p2.perc
			end
		end
	end
	table.sort(missionsList, comparison);
end
function addon.Garrison_SortMissions_Age(missionsList)
	local comparison
	do
		function comparison(mission1, mission2)
			if type(mission1)~="table" or type(mission2) ~="table" then return end
			local p1=parties[mission1.missionID]
			local p2=parties[mission2.missionID]
			if (p2.full and not p1.full) then return false end
			if (p1.full and not p2.full) then return true end
			local age1=tonumber(dbcache.seen[mission1.missionID]) or 0
			local age2=tonumber(dbcache.seen[mission2.missionID]) or 0
			if (age1==age2) then
				return strcmputf8i(mission1.name, mission2.name) < 0
			else
				return age1 < age2
			end
		end
	end
	table.sort(missionsList, comparison);
end
function addon.Garrison_SortMissions_Followers(missionsList)
	local comparison
	do
		function comparison(mission1, mission2)
			if type(mission1)~="table" or type(mission2) ~="table" then return end
			local p1=mission1.numFollowers
			local p2=mission2.numFollowers
			if (p1==p2) then
				return strcmputf8i(mission1.name, mission2.name) < 0
			else
				return p1 < p2
			end
		end
	end
	table.sort(missionsList, comparison);
end
function addon.Garrison_SortMissions_Xp(missionsList)
	local comparison
	do
		function comparison(mission1, mission2)
			if type(mission1)~="table" or type(mission2) ~="table" then return end
			local p1=addon:GetMissionData(mission1.missionID,'globalXp')
			local p2=addon:GetMissionData(mission2.missionID,'globalXp')
			if (p1==p2) then
				return strcmputf8i(mission1.name, mission2.name) < 0
			else
				return p2 < p1
			end
		end
	end
	table.sort(missionsList, comparison);
end

function addon:OnInitialized()
--[===[@debug@
	xprint("OnInitialized")
--@end-debug@]===]
	for _,b in ipairs(GMFMissionsListScrollFrame.buttons) do
		local scale=0.8
		local f,h,s=b.Title:GetFont()
		b.Title:SetFont(f,h*scale,s)
		local f,h,s=b.Summary:GetFont()
		b.Summary:SetFont(f,h*scale,s)
	end
	self:CreatePrivateDb()
	db=self.db.global
	self:SafeRegisterEvent("GARRISON_MISSION_STARTED")
	self:SafeRegisterEvent("GARRISON_MISSION_BONUS_ROLL_LOOT")
	self:SafeRegisterEvent("GARRISON_MISSION_NPC_CLOSED",function(...) GCF:Hide() end)
	self:SafeHookScript("GarrisonMissionFrame","OnShow","SetUp",true)
	self:AddLabel("Appearance")
	self:AddToggle("MOVEPANEL",true,L["Unlock Panel"])
	self:AddToggle("BIGSCREEN",true,L["Use big screen"],L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"])
	self:AddToggle("PIN",true,L["Show Garrison Commander menu"],L["Disable if you dont want the full Garrison Commander Header."])
	self:AddLabel("Mission Panel")
	self:AddToggle("IGM",true,IGNORE_UNAIVALABLE_FOLLOWERS,IGNORE_UNAIVALABLE_FOLLOWERS_DETAIL)
	self:AddToggle("IGP",true,L['Ignore "maxed"'],L["Level 100 epic followers are not used for xp only missions."])
	self:AddToggle("NOFILL",false,L["No mission prefill"],L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"])
	self:AddSelect("MSORT","Garrison_SortMissions_Original",
	{
		Garrison_SortMissions_Original=L["Original method"],
		Garrison_SortMissions_Chance=L["Success Chance"],
		Garrison_SortMissions_Followers=L["Number of followers"],
		Garrison_SortMissions_Age=L["Days since first seen"],
		Garrison_SortMissions_Xp=L["Global approx. xp reward"],
	},
	L["Sort missions by:"],L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"])
	bigscreen=self:GetBoolean("BIGSCREEN")
	self:AddLabel("Followers Panel")
	self:AddSlider("MAXMISSIONS",5,1,8,L["Mission shown for follower"],nil,1)
	self:AddSlider("MINPERC",50,0,100,L["Minimun chance success under which ignore missions"],nil,5)
	self:AddToggle("ILV",true,L["Show weapon/armor level"],L["When checked, show on each follower button weapon and armor level for maxed followers"])
	self:AddPrivateAction("ShowMissionControl",L["Mission control"],L["You can choose some criteria and have GC autosumbit missions for you"])
--[===[@debug@
	self:AddLabel("Developers options")
	self:AddToggle("DBG",false, "Enable Debug")
	self:AddToggle("TRC",false, "Enable Trace")
--@end-debug@]===]

	self:Trigger("MSORT")
	return true
end
function addon:CheckMP()
	if (IsAddOnLoaded("MasterPlan")) then
		if (GetAddOnMetadata("MasterPlan","Version")=="0.18") then
		-- Last well behavioured version
			MPGoodGuy=true
			return
		end
		if GetAddOnMetadata("MasterPlan","Version")>="0.23" then
			-- New compatible version
			self:AddToggle("CKMP",true,L["Use GC Interface"],L["Switches between Garrison Commander and Master Plan mission interface. Tested with MP >0.23"])
			MPGoodGuy=true
			MPSwitch=true
		end
		MP=true
		MPSwitch=true
		self:AddToggle("CKMP",true,L["Use GC Interface"],L["Switches between Garrison Commander and Master Plan mission interface. Tested with MP >0.20"])
	end
end
function addon:CheckGMM()
	if (IsAddOnLoaded("GarrisonMissionManager")) then
		GMM=true
		self:RefreshMission()
	end
end
function addon:ApplyIGM(value)
	self:BuildMissionsCache(false,true)
	self:RefreshMission()
end
function addon:ApplyCKMP(value)
	if (HD) then self:Clock() end
	if (MasterPlanMissionList) then
		if (value) then
			MasterPlanMissionList:Hide()
		else
			MasterPlanMissionList:Show()
		end
	end
	self:RefreshMission()
end
function addon:ApplyDBG(value)
	dbg=value
end
function addon:ApplyPIN(value)
	pin=value
end
function addon:ApplyTRC(value)
	trc=value
end
function addon:ApplyBIGSCREEN(value)
		if (value) then
			wipe(dbcache.ignored) -- we no longer have an interface to change this settings
		end
		self:Popup(L["Must reload interface to apply"],0,
			function(this)
				addon:SetBoolean("BIGSCREEN",value)
				ReloadUI()
			end
		)
end
function addon:ApplyIGP(value)
	self:BuildMissionsCache(false,true)
	self:RefreshMission()
end
function addon:ApplyMSORT(value)
	if (not origGarrison_SortMissions) then
		origGarrison_SortMissions=Garrison_SortMissions
	end
	local func=self[value]
	if (type(func)=="function") then
		_G.Garrison_SortMissions=self[value]
	else
		_G.Garrison_SortMissions=origGarrison_SortMissions
	end
	self:RefreshMission()
end
function addon:ApplyMAXMISSIONS(value)
	MAXMISSIONS=value
	BUSY_MESSAGE=format(BUSY_MESSAGE_FORMAT,MAXMISSIONS,MINPERC)
end
function addon:ApplyMINPERC(value)
	MINPERC=value
	BUSY_MESSAGE=format(BUSY_MESSAGE_FORMAT,MAXMISSIONS,MINPERC)
end


--[[
function addon:RestoreTooltip()
	local self = GMF.MissionTab.MissionList;
	local scrollFrame = self.listScroll;
	local buttons = scrollFrame.buttons;
	for i =1,#buttons do
		buttons[i]:SetScript("OnEnter",GarrisonMissionButton_OnEnter)
	end
end
--]]
--[[
	[12]={
		description="Iron Horde raiders have descended on nearby draenei villages. Find the raiders' camp and raid it. Turnabout, they say, is fair play.",
		cost=15,
		duration="4 hr",
		slots={
			["Minion Swarms"]=1,
			Type=1,
			["Deadly Minions"]=1
		},
		durationSeconds=14400,
		party={
			party2="<empty>",
			party1="<empty>"
		},
		level=100,
		type="Combat",
		counters={
			["0x00000000001BE95D"]={
				[1]={
					counterIcon="Interface\\ICONS\\Ability_Rogue_FanofKnives.blp",
					name="Minion Swarms",
					counterName="Fan of Knives",
					icon="Interface\\ICONS\\Spell_DeathKnight_ArmyOfTheDead.blp",
					description="An enemy with many allies.  Susceptible to area-of-effect damage."
				}
			},
			["0x00000000002D61EB"]={
				[1]={
					counterIcon="Interface\\ICONS\\Spell_Shaman_Hex.blp",
					name="Deadly Minions",
					counterName="Hex",
					icon="Interface\\ICONS\\Achievement_Boss_TwinOrcBrutes.blp",
					description="An enemy with powerful allies that should be neutralized."
				}
			}
		},
		traits={
			["0x00000000001BE95D"]={
				[1]={
					traitID=236,
					icon="Interface\\ICONS\\Item_Hearthstone_Card.blp"
				}
			}
		},
		locPrefix="GarrMissionLocation-Nagrand",
		rewards={
			[795]={
				itemID=120301,
				quantity=1
			}
		},
		numRewards=1,
		numFollowers=2,
		state=-2,
		iLevel=0,
		name="Raiding the Raiders",
		followers={
		},
		location="Nagrand",
		isRare=false,
		typeAtlas="GarrMission_MissionIcon-Combat",
		missionID=380
	}
}
--]]
-- True manda a davani
local function cmp(a,b)

	if (a.mechanic and b.trait) then return true end
	if (a.trait and b.mechanic) then return false end
	if (a.name==a.name) then
		if a.bias==b.bias then
			if (a.rank==b.rank) then
				return a.quality < b.quality
			else
				return a.rank < b.rank
			end
		else
			return a.bias > b.bias
		end
	else
		return a.name < b.name
	end
	--if (a.name~=b.name) then return a.name < b.name end
	--if (a.bias==-1) then return false end
	--if (b.bias==-1) then return true end
	--if (a.bias~=b.bias) then return (a.bias>b.bias) end
	--if (a.rank ~= b.rank) then return (a.rank < b.rank) end
	return a.quality < b.quality
end


function addon:FillCounters(missionID,mission)
	if (not mission) then mission=self:GetMissionData(missionID) end
	local slots=mission.slots
	local missioncounters=counters[missionID]
	wipe(missioncounters)
	local t=G.GetBuffedFollowersForMission(missionID)
	if t then
		for id,d in pairs(t) do
			local rank=self:GetFollowerData(id,'rank')
			local quality=self:GetFollowerData(id,'quality')
			local bias= G.GetFollowerBiasForMission(missionID,id);
			for i,l in pairs(d) do
				-- i is meaningful
				-- l.counterIcon
				-- l.name
				-- l.counterName
				-- l.icon
				-- l.description
				tinsert(missioncounters,{k=cleanicon(l.icon),mechanic=true,name=l.name,followerID=id,bias=bias,rank=rank,quality=quality,icon=l.icon})
				followerMissions[id][missionID]=1+ (tonumber(followerMissions[id][missionID]) or 0)
			end
		end
	end
	t= G.GetFollowersTraitsForMission(missionID)
	if t then
		for id,d in pairs(t) do
			local bias= G.GetFollowerBiasForMission(missionID,id);
			local rank=self:GetFollowerData(id,'rank')
			local quality=self:GetFollowerData(id,'quality')
			for i,l in pairs(d) do
				--l.traitID
				--l.icon
				followerMissions[id][missionID]=1+ (tonumber(followerMissions[id][missionID]) or 0)
				tinsert(missioncounters,{k=cleanicon(l.icon),trait=true,name=l.traitID,followerID=id,bias=bias,rank=rank,quality=quality,icon=l.icon})
			end
		end
		table.sort(missioncounters,cmp)
		local cf=wipe(counterFollowerIndex[missionID])
		local ct=wipe(counterThreatIndex[missionID])
		for i=1,#missioncounters do
			tinsert(cf[missioncounters[i].followerID],i)
			tinsert(ct[missioncounters[i].k],i)
		end
	end
end

--[[
Matchmaker debug for Spell Check
Slots
["Danger Zones"]=1,
Type="Interface\\ICONS\\Achievement_Reputation_Ogre.blp",
["Interface\\ICONS\\Achievement_Reputation_Ogre.blp"]=1,
["Powerful Spell"]=1
[1]={
	name="Danger Zones",
	icon="Interface\\ICONS\\spell_Shaman_Earthquake.blp",
	quality=4,
	bias=-0.66666668653488,
	follower="0x00000000002D57C4",
	rank=96
},
[2]={
	name="Interface\\ICONS\\Achievement_Reputation_Ogre.blp",
	icon="Interface\\ICONS\\Achievement_Reputation_Ogre.blp",
	quality=4,
	bias=0.66666668653488,
	follower="0x00000000001978B6",
	rank=600
},
[3]={
	name="Interface\\ICONS\\Achievement_Reputation_Ogre.blp",
	icon="Interface\\ICONS\\Achievement_Reputation_Ogre.blp",
	quality=4,
	bias=-0.66666668653488,
	follower="0x00000000002D57C4",
	rank=96
},
[4]={
	name="Interface\\ICONS\\Item_Hearthstone_Card.blp",
	icon="Interface\\ICONS\\Item_Hearthstone_Card.blp",
	quality=2,
	bias=0.66666668653488,
	follower="0x00000000001BE95D",
	rank=600
}
Preparying party
Considering  Shelly Hamby for Danger Zones
Considering  Qiana Moonshadow for Interface\ICONS\Achievement_Reputation_Ogre.blp
Considering  Shelly Hamby for Interface\ICONS\Achievement_Reputation_Ogre.blp
Considering  Bruma Swiftstone for Interface\ICONS\Item_Hearthstone_Card.blp
Dopo check per nil
["Danger Zones"]={
},
["Interface\\ICONS\\Achievement_Reputation_Ogre.blp"]={
},
["Interface\\ICONS\\Item_Hearthstone_Card.blp"]={
}
Party filling
Party is not full
Verifying Delvar Ironfist 0 600 3
Verifying Rangari Chel 0 91 3
Party filling
Party is not full
Verifying Rangari Chel 0 91 3
Party filling
Matchmaker end

--]]
--[[
Button fields
LocBG table
HighlightBR table
Highlight table
inProgressFresh boolean
Party table
gcPANEL table
HighlightB table
HighlightTR table
Level table
Expire table
MissionType table
Overlay table
info table
ItemLevel table
id number
HighlightBL table
Rewards table
Threats table
HighlightT table
0 userdata
RareText table
IconBG table
Title table
Projections table
RareOverlay table
Summary table
HighlightTL table
--]]
local function best(fid1,fid2,counters)
	if (not fid1) then return fid2 end
	if (not fid2) then return fid1 end
	local f1,f2=counters[fid1],counters[fid2]
	if (dbg) then
		print("Current",fid1,n[f1.followerID]," vs Candidate",fid2,n[f2.followerID])
	end
	if (isInParty(f1.followerID)) then return fid1 end
	if (f2.bias<0) then return fid1 end
	if (f2.bias>f1.bias) then return fid2 end
	if (f1.bias == f2.bias) then
		if (f2.quality < f1.quality or f2.rank < f1.rank) then return fid2 end
	end
	return fid1
end
local epicMountTrait=221
local extraTrainingTrait=80 --all followers +35
local fastLearnerTrait=29 -- only this follower +50
local hearthStoneProTrait=236 -- all followers +36
local scavengerTrait=79 -- More resources
function addon:AddTraitsToParty(missionID,mission,skipBusy,skipMaxed)
	local t=counters[missionID]
	if (t) then
		for i=1,#t do
			local follower=t[i]
			if (follower.trait and not isPartyIgnored(follower.followerID) and not isInParty(follower.followerID)) then
				if mission.resources > 0 and follower.name==scavengerTrait then
					pushFollower(follower.followerID)
				elseif mission.xpOnly  and (follower.name==extraTrainingTrait or follower.name==hearthStoneProTrait) then
					pushFollower(follower.followerID)
				elseif mission.durationSeconds > GARRISON_LONG_MISSION_TIME  and follower.name==epicMountTrait then
					pushFollower(follower.followerID)
				end
			end
		end
	end
end
function addon:CompleteParty(missionID,mission,skipBusy,skipMaxed)
	local perc=select(4,G.GetPartyMissionInfo(missionID)) -- If percentage is already 100, I'll try and add the most useless character
	local candidateMissions=10000
	local candidateRank=10000
	local candidateQuality=9999
	if (dbg) then
		print("Attemptin to fill party, so far:")
		dumpParty()
	end
	for x=1,roomInParty() do
		local candidate
		local candidatePerc=perc
		local totFollowers=#followersCache
		for i=1,totFollowers do
			local data=followersCache[i]
			local followerID=data.followerID
			if (not isPartyIgnored(followerID) and not isInParty(followerID) and not self:IsIgnored(followerID,missionID) and not(skipMaxed and data.maxed and mission.xpOnly) and not isInParty(followerID) and self:GetFollowerStatusForMission(followerID,skipBusy)) then
				local missions=#followerMissions[followerID]
				local rank=data.rank
				local quality=data.quality
				repeat
					perc=tonumber(perc) or 0
					if ((perc or 0) <100) then
						pushFollower(followerID)
						local newperc=select(4,G.GetPartyMissionInfo(missionID)) or 0
						removeFollower(followerID)
						if (newperc > candidatePerc) then
							candidatePerc=newperc
							candidate=followerID
							candidateMissions=missions
							candidateRank=rank
							candidateQuality=quality
							break -- continue
						elseif (newperc < candidatePerc) then
							break --continue
						end
					end
					-- This candidate is not improving success chance or we are already at 100%, minimize
					if (i < totFollowers  and data.maxed) then
						break  -- Pointless using a maxed follower if we  have more follower to try
					end
					if (missions<candidateMissions) then
						candidate=followerID
						candidateMissions=missions
						candidateRank=rank
						candidateQuality=quality
					elseif(missions==candidateMissions and rank<candidateRank) then
						candidate=followerID
						candidateMissions=missions
						candidateRank=rank
						candidateQuality=quality
					elseif(missions==candidateMissions and rank==candidateRank and quality<candidateQuality) then
						candidate=followerID
						candidateMissions=missions
						candidateRank=rank
						candidateQuality=quality
					elseif (not candidate) then
						candidate=followerID
						candidateMissions=missions
						candidateRank=rank
						candidateQuality=quality
					end
				until true -- A poor man continue implementation using break
			end
		end
		if (candidate) then
			pushFollower(candidate)
			if (dbg) then
				print("Added member to party")
				dumpParty()
			end
			perc=select(4,G.GetPartyMissionInfo(missionID))
		end
	end
end
function addon:MatchMaker(missionID,mission,party,fromGMC)
	if (GMFRewardSplash:IsShown()) then return end
	if (not mission) then mission=self:GetMissionData(missionID) end
	if (not party) then party=parties[missionID] end
	local skipBusy=self:GetBoolean("IGM")
	local skipMaxed=self:GetBoolean("IGP")
	dbg=dbg or missionID==(tonumber(_G.MW) or 0)
	local slots=mission.slots
	local missionCounters=counters[missionID]
	local ct=counterThreatIndex[missionID]
	openParty(missionID,mission.numFollowers)
	-- Preloading skipped ones in party table.
	if (dbg) then print(C("Matchmaking mission","Red"),missionID,mission.name) end
	if (missionCounters) then
		for i=1,#missionCounters do
			local followerID=missionCounters[i].followerID
			if (not followerID) then
				if (dbg) then print("Trying to use [",followerID,"]") end
			else
				if (self:IsIgnored(followerID,missionID)) then
					if (dbg) then print("Skipped",n[followerID],"due to ignored" ) end
					partyIgnore(followerID,true)
				elseif not addon:GetFollowerStatusForMission(followerID,skipBusy) then
					if (dbg) then print("Skipped",n[followerID],"due to busy" ) end
					partyIgnore(followerID)
				elseif (skipMaxed and mission.xpOnly and self:GetFollowerData(followerID,'maxed')) then
					if (dbg) then print("Skipped",n[followerID],"due to busy" ) end
					partyIgnore(followerID,true)
				end
			end
		end
		if (type(slots)=='table') then
			for i=1,#slots do
				local threat=cleanicon(slots[i].icon)
				local candidates=ct[threat]
				local choosen
				for i=1,#candidates do
					local followerID=missionCounters[candidates[i]].followerID
					if followerID then
						if(not isPartyIgnored(followerID)) then
							choosen=best(choosen,candidates[i],missionCounters)
							if (dbg) then print("Taken",n[missionCounters[choosen].followerID]) end
						end
					end
				end
				if (choosen) then
					if (type(missionCounters[choosen]) ~="table") then
						trace(format("%s %s %d %d",mission.name,threat,missionID,tonumber(choosen) or 0))
					end
					pushFollower(missionCounters[choosen].followerID)
				end
				if (roomInParty()==0) then
					break
				end
			end
		else
			xprint("Mission",missionID,"has no slots????")
		end
		if roomInParty() > 0 then self:AddTraitsToParty(missionID,mission) end
	end
	if roomInParty() > 0 then self:CompleteParty(missionID,mission,skipBusy,skipMaxed) end
	if skipMaxed and not fromGMC and roomInParty() > 0  then self:CompleteParty(missionID,mission,skipBusy,skipMaxed) end
	storeFollowers(party.members)
	party.full= roomInParty()==0
	party.perc=closeParty()
end
function addon:IsIgnored(followerID,missionID)
	if (dbcache.ignored[missionID][followerID]) then return true end
	if (dbcache.totallyignored[followerID]) then return true end
end
function addon:GetAllCounters(missionID,threat,table)
	wipe(table)
	if type(counterThreatIndex[missionID]) == "table" then
		local index=counterThreatIndex[missionID][cleanicon(tostring(threat))]
		if (type(index)=="table") then
			for i=1,#index do
				tinsert(table,counters[missionID][index[i]].followerID)
			end
		end
	end
end
function addon:GetCounterBias(missionID,threat)
	local bias=-1
	local who=""
	local index=counterThreatIndex[missionID]
	local data=counters[missionID]
	if (type(index)=="table" and type(counters)=="table") then
		index=index[cleanicon(tostring(threat))]
		if (type(index) == "table") then
			for i=1,#index do
				local follower=data[index[i]]
				if ((tonumber(follower.bias) or -1) > bias) then
					if (inParty(missionID,follower.followerID)) then
						if (dbg) then print("   Choosen",self:GetFollowerData(follower.followerID,'fullname')) end
						bias=follower.bias
						who=follower.name
					end
				end
			end
		end
	end
	return bias,who
end
function addon:AddLine(name,status)
	local r2,g2,b2=C.Red()
	if (status==AVAILABLE) then
		r2,g2,b2=C.Green()
	elseif (status==GARRISON_FOLLOWER_WORKING) then
		r2,g2,b2=C.Orange()
	end
	GameTooltip:AddDoubleLine(name, status,nil,nil,nil,r2,g2,b2)
end
function addon:SetThreatColor(obj,missionID)
	local bias=self:GetCounterBias(missionID,obj.Icon:GetTexture())
	local color=self:GetBiasColor(bias,nil,"Green")
	local c=C[color]
	obj.Border:SetVertexColor(c())
end

function addon:HookedGarrisonMissionButton_AddThreatsToTooltip(missionID)
	if (GMC:IsShown()) then return end
	self:RenderTooltip(missionID)
end
function addon:RenderTooltip(missionID)
	local mission=self:GetMissionData(missionID)
	if (not mission) then
--[===[@debug@
		GameTooltip:AddLine("E dove minchia è finita??")
--@end-debug@]===]
		return
	end
	local f=GarrisonMissionListTooltipThreatsFrame
	if (not f.Env) then
		f.Env=CreateFrame("Frame",nil,f,"GarrisonAbilityCounterTemplate")
		f.Env:SetWidth(20)
		f.Env:SetHeight(20)
		f.Env:SetPoint("LEFT",f)
	end
	local t=f.EnvIcon:GetTexture();
	f.EnvIcon:Hide()
	f.Env.Icon:SetTexture(t)
	f.Env.Icon:SetWidth(20)
	f.Env.Icon:SetHeight(20)
	self:SetThreatColor(f.Env,missionID)
	--local bias,who=self:GetCounterBias(missionID,t)
	--local color=self:GetBiasColor(bias,nil,"Green")
	--local c=C[color]
	--f.Env.Border:SetVertexColor(c())
	for i=1,#f.Threats do
		local th=f.Threats[i]
		self:SetThreatColor(th,missionID)
	end
	-- Adding All available followers
	local fullnames=new()
	local party=new()
	local biascolors=new()
	local partystring=strjoin("|",tostringall(unpack(parties[missionID].members)))
	for followerID,refs in pairs(counterFollowerIndex[missionID]) do
		local fullname= self:GetFollowerData(followerID,'fullname')
		for i=1,#refs do
			fullname=fullname .." |T" .. tostring(counters[missionID][refs[i]].icon) ..":16|t"
		end
		if (not partystring:find(followerID)) then
			tinsert(fullnames,fullname)
		else
			tinsert(party,fullname)
		end
		biascolors[fullname]={self:GetBiasColor(followerID,missionID,"White"),self:GetFollowerStatus(followerID,true)}
	end
	table.sort(fullnames)
	GameTooltip:AddLine(L["Other useful followers"])
	for i=1,#fullnames do
		local fullname=fullnames[i]
		local info=biascolors[fullname]
		self:AddLine(fullname,info[2],info[1])
	end

	del(party)
	del(fullnames)
	del(biascolors)
	local perc=parties[missionID].perc
	local q=self:GetDifficultyColor(perc)
	GameTooltip:AddDoubleLine(GARRISON_MISSION_SUCCESS,format(GARRISON_MISSION_PERCENT_CHANCE,perc),nil,nil,nil,q.r,q.g,q.b)
	for _,i in pairs (dbcache.ignored[missionID]) do
		GameTooltip:AddLine(L["You have ignored followers"])
		break;
	end
	if (dbcache.history[missionID]) then
		local tot,success=0,0
		for d,r in pairs(dbcache.history[missionID]) do
			tot,success=tot+1,success + (r.success and 1 or 0)
		end
		local ratio=floor(success/tot*100)
		if (tot > 0) then
			GameTooltip:AddDoubleLine(format("You performed this mission %d times with a win ratio of",tot),ratio..'%',0,1,0,self:GetDifficultyColors(ratio))
			return
		end
	end
	GameTooltip:AddLine("You never performed this mission",1,0,0)
end

local function switch(flag)
	if (GCF[flag]) then
		local b=GCF[flag]
		if (b:GetChecked()) then
			b.text:SetTextColor(C.Green())
		else
			b.text:SetTextColor(C.Silver())
		end
	end
end
function addon:RefreshMission(missionID)
	if (self:IsAvailableMissionPage()) then
		if (tonumber(missionID)) then
			self:FillCounters(missionID)
			self:MatchMaker(missionID)
		end
		GarrisonMissionList_UpdateMissions()
	end
end

function addon:BuildMissionsCache(fc,mm,OnEvent)
--cache.missions
--[===[@debug@
	local start=GetTime()
	xprint("Start Full Cache Rebuild")
--@end-debug@]===]
	local t=new()
	G.GetAvailableMissions(t)
	for index=1,#t do
		local missionID=t[index].missionID
		if (not	dbcache.seen[missionID]) then
			dbcache.seen[missionID]=(OnEvent and time()) or dbcache.lastseen
		end
		self:BuildMissionCache(missionID,t[index])
		if fc then self:FillCounters(missionID) end
		if mm then self:MatchMaker(missionID) end
	end
	for k,v in pairs(dbcache.seen) do
		if (not cache.missions[k]) then
			local span=time()-(tonumber(v) or time())
			if (span > db.lifespan[k]) then
				db.lifespan[k]=span
			end
			dbcache.seen[k]=nil
		end
	end
	del(t)
	collectgarbage("step",10)
--[===[@debug@
	xprint("Done in",GetTime()-start)
--@end-debug@]===]
end
--[[
GARRISON_DURATION_DAYS = "%d |4day:days;"; changed to dual form
GARRISON_DURATION_DAYS_HOURS = "%d |4day:days; %d hr"; changed to dual form
GARRISON_DURATION_HOURS = "%d hr";
GARRISON_DURATION_HOURS_MINUTES = "%d hr %d min";
GARRISON_DURATION_MINUTES = "%d min";
GARRISON_DURATION_SECONDS = "%d sec";
--]]
local function GarrisonTimeStringToSeconds(text)
	local s = D.Deformat(text,GARRISON_DURATION_SECONDS)
	if (s) then return s end
	local m  = D.Deformat(text,GARRISON_DURATION_MINUTES)
	if m then return m end
	local h,m= D.Deformat(text,GARRISON_DURATION_HOURS_MINUTES)
	if (h) then return h*3600+m*60 end
	local h= D.Deformat(text,GARRISON_DURATION_HOURS)
	if (h) then return h*3600 end
	local d,h=D:Deformat(GARRISON_DURATION_DAY_HOURS)
	if (d) then return d*3600*24 + h*3600 end
	local d,h=D:Deformat(GARRISON_DURATION_DAYS_HOURS)
	if (d) then return d*3600*24 + h*3600 end
	local d=D:Deformat(GARRISON_DURATION_DAYS)
	if (d) then return d*3600*24 end
	local d=D:Deformat(GARRISON_DURATION_DAY)
	if (d) then return d*3600*24 end
	return 3600*24

end
function addon:BuildRunningMissionsCache()
	local t=new()
	G.GetInProgressMissions(t)
	for index=1,#t do
		local mission=t[index]
		local missionID=mission.missionID
		local running =dbcache.running[missionID]
		running.duration=mission.durationSeconds
		running.timeLeft=mission.timeLeft
		if ((tonumber(running.started) or 0)==0) then running.started = time() - GarrisonTimeStringToSeconds(mission.timeLeft) end
		running.followers={}
		for i=1,mission.numFollowers do
			running.followers[i]=mission.followers[i]
			dbcache.runningIndex[mission.followers[i]]=missionID
		end
	end
	del(t)
end
--[[
{
	missionID=0,
	counters={}, calculated
	countered={ calculated
		["*"]={}
	},
	counterers={ calculated
		["*"]={}
	},
	slots={  calculated
		["*"]=0
	},
	numFollowers=0, -> GetMissionMaxFollowers()
	name="<newmission>", GetMissionName
	basePerc=0, 		GetPartyMissionInfo
	durationSeconds=0,  GePartyMissionInfo()
	rewards={},
	level=0,
	iLevel=0,
	rank=0,
	locPrefix=false
}
GetBasicInfo Table Format={
	description="With infernals and felguard invading Talador, the rest of the Burning Legion can't be far behind. Defeat them, and try to find their source.",
	cost=15,
	duration="8 hr",
	durationSeconds=28800,
	level=100,
	type="Combat",
	locPrefix="GarrMissionLocation-Talador",
	rewards={
		[248]={
			itemID=114057,
			quantity=1
		}
	},
	numRewards=1,
	numFollowers=3,
	state=-2,
	iLevel=0,
	name="Burning Legion Vanguard",
	followers={
	},
	location="Talador",
	isRare=false,
	typeAtlas="GarrMission_MissionIcon-Combat",
	missionID=113
}

--]]
function addon:BuildMissionCache(id,data)
	local mission=cache.missions[id]
	if (not mission) then
--@dedbug@
		xprint("Generating new data for ",id)
--@end-debug@
		mission = data or G.GetBasicMissionInfo(id)
		if (not mission) then return end
		cache.missions[id]=mission
		if dbg then print("Retrieved",id,mission.name) end
	end
	local _,xp,type,typeDesc,typeIcon,locPrefix,_,enemies=G.GetMissionInfo(id)
	mission.rank=mission.level < 100 and mission.level or mission.iLevel
	mission.xp=xp
	mission.xpBonus=0
	mission.resources=0
	mission.gold=0
	mission.followerUpgrade=0
	mission.itemLevel=0
	for k,v in pairs(mission.rewards) do
		if (v.followerXP) then mission.xpBonus=mission.xpBonus+v.followerXP end
		if (v.currencyID and v.currencyID==GARRISON_CURRENCY) then mission.resources=v.quantity end
		if (v.currencyID and v.currencyID==0) then mission.gold =mission.gold+v.quantity/10000 end
		if (v.itemID) then
			if (v.itemID~=120205) then
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(v.itemID)
				if (itemName) then
					if (itemLevel > 1 ) then
						mission.itemLevel=itemLevel
					else
						mission.followerUpgrade=itemRarity
					end
				end
			end
		end
	end
	mission.totalXp=(tonumber(mission.xp) or 0) + (tonumber(mission.xpBonus) or 0)
	mission.globalXp=mission.totalXp*mission.numFollowers
	if (mission.resources==0 and mission.gold==0 and mission.itemLevel==0 and mission.followerUpgrade==0) then
		mission.xpOnly=true
	else
		mission.xpOnly=false
	end
	mission.locPrefix=locPrefix
	if (not type) then
--[===[@debug@
		xprint("No type",id,data.name)
--@end-debug@]===]
	else
		if (not self.db.global.types[type]) then
			self.db.global.types[type]={name=type,description=typeDesc,icon=typeIcon}
		end
	end
	mission.slots={}
	local slots=mission.slots

	for i=1,#enemies do
		local mechanics=enemies[i].mechanics
		for i,mechanic in pairs(mechanics) do
			tinsert(slots,mechanic)
			self.db.global.abilities[mechanic.name]=mechanic
		end
	end
	if (type) then
		tinsert(slots,{name=TYPE,key=type,icon=typeIcon})
	end
	--collectgarbage("step",100)
	mission.basePerc=select(4,G.GetPartyMissionInfo(id))

end
function addon:SetDbDefaults(default)
	default.global=default.global or {}
	default.global["*"]={
	}
	default.global.lifespan={["*"]=0}
end
function addon:CreatePrivateDb()
	self.privatedb=self:RegisterDatabase(
		GetAddOnMetadata(me,"X-Database")..'perChar',
		{
			profile={
				seen={},
				ignored={
					["*"]={
					}
				},
				totallyignored={
				},
				history={
					['*']={
					}
				},
				running={
					["*"]={
						followers={},
						started=0,
						duration=0
					}
				},
				runningIndex={
					["*"]=0
				},
				missionControl={
					allowedRewards = {["*"]=true},
					rewardChance={["*"]=100},
					useOneChance=true,
					itemPrio = {},
					minimumChance = 100,
					minDuration = 0,
					maxDuration = 24,
					epicExp = false,
					skipRare=true
				}
			}
		},
		true)
	self.private=self:RegisterDatabase(
		"GACPrivateVolatile",
		{
			profile={
				missions={}
			}
		}
	,
	true)
	dbcache=self.privatedb.profile
	cache=self.private.profile
end
function addon:SetClean()
	dirty=false
end

function addon:WipeMission(missionID)
	cache.missions[missionID]=nil
	counters[missionID]=nil
	dbcache.seen[missionID]=nil
	parties[missionID]=nil
	--collectgarbage("step")


end

---
--@param #string event GARRISON_MISSION_NPC_OPENED
-- Fires after GarrisonMissionFrame OnShow. Pretty useless

function addon:EventGARRISON_MISSION_NPC_OPENED(event,...)
--[===[@debug@
	xprint(event,...)
--@end-debug@]===]
	if (GCF) then GCF:Show() end
end
function addon:EventGARRISON_MISSION_NPC_CLOSED(event,...)
--[===[@debug@
	xprint(event,...)
--@end-debug@]===]
	if (GCF) then
		self:RemoveMenu()
		GCF:Hide()
	end
end
function addon:EventGARRISON_MISSION_LIST_UPDATE(event)
	local n=0
	for _,k in pairs(event) do n=n+1 end
	xprint("GARRISON_MISSION_LIST_UPDATE",n,date("%d/%m/%y %H:%M:%S"))
	local t=new()
	G.GetAvailableMissions(t)
	local justseen={}
	local now=time()
	for i=1,#t do
		justseen[t[i].missionID]=true
	end
	for missionID,_ in pairs(justseen) do
		if (not tonumber(db.seen[missionID])) then db.seen[missionID]=now end
	end
	self:BuildMissionsCache(false,false,true)
	del(t)
end
---
--@param #string event GARRISON_MISSION_STARTED
--@param #number missionID Numeric mission id
-- After this events fires also GARRISON_MISSION_LIST_UPDATE and GARRISON_FOLLOWER_LIST_UPDATE

function addon:EventGARRISON_MISSION_STARTED(event,missionID,...)
--[===[@debug@
	xprint(event,missionID,...)
--@end-debug@]===]
--				running={
--					["*"]={
--						followers={},
--						started=0,
--						duration=0
--					}
--				},
	dbcache.running[missionID].started=time()
	dbcache.running[missionID].duration=select(2,G.GetPartyMissionInfo(missionID))
	wipe(dbcache.running[missionID].followers)
	wipe(dbcache.ignored[missionID])
	for i=1,3 do
		local m=parties[missionID].members[i]
		if (m) then
			tinsert(dbcache.running.followers,m)
			dbcache.runningIndex[m]=missionID
		end
	end
	local v=dbcache.seen[missionID]
	local span=time()-(tonumber(v) or time())
	if (span > db.lifespan[missionID]) then
		db.lifespan[missionID]=span
		-- IF we started it.. it was alive, so it's expire time is at least the time we waited before starting it
	end
	dbcache.seen[missionID]=nil
	counters[missionID]=nil
	parties[missionID]=nil
	self:BuildMissionsCache(true,true)
	self:RefreshFollowerStatus()
end
---
--@param #string event GARRISON_MISSION_FINISHED
--@param #number missionID Numeric mission id
-- Thsi is just a notification, nothing get really changed
-- GetMissionINfo still returns data
-- but GetPartyMissionInfo does no longer return followers.
-- Also timeleft is false
--

function addon:EventGARRISON_MISSION_FINISHED(event,missionID,...)
--[===[@debug@
	xprint(event,missionID,...)
	xdump(G.GetPartyMissionInfo(missionID))
--@end-debug@]===]
end
function addon:EventGARRISON_FOLLOWER_LIST_UPDATE(event)
--We need to update all followers, maybe this could be done in an onupdate handler
	wipe(followersCache)
	wipe(followersCacheIndex)
	xprint("Follower cache cleaned")
end
function addon:EventGARRISON_FOLLOWER_ADDED(event)
	wipe(followersCache)
	wipe(followersCacheIndex)
end
function addon:EventGARRISON_FOLLOWER_REMOVED(event)
	wipe(followersCache)
	wipe(followersCacheIndex)
end

function addon:EventGARRISON_MISSION_BONUS_ROLL_LOOT(event,missionID,completed,success)
--[===[@debug@
	xprint(event,missionID,completed,success)
--@end-debug@]===]
end
---
--@param #number missionID mission identifier
--@param #boolean completed I suppose it always be true...
--@oaram #boolean success Mission was succesfull
--Mission complete Sequence is:
--GARRISON_MISSION_COMPLETE_RESPONSE
--GARRISON_MISSION_BONUS_ROLL_LOOT missionID true
--GARRISON_FOLLOWER_XP_CHANGED (1 or more times
--GARRISON_MISSION_NPC_OPENED ??
--GARRISON_MISSION_BONUS_ROLL_ROLL itemId nil
--
function addon:EventGARRISON_MISSION_COMPLETE_RESPONSE(event,missionID,completed,success)
--[===[@debug@
	xprint(event,missionID)
--@end-debug@]===]
	dbcache.history[missionID][time()]={result=100,success=success}
	dbcache.seen[missionID]=nil
	dbcache.running[missionID]=nil
	dbcache.seen[missionID]=nil
	counters[missionID]=nil
	parties[missionID]=nil
	self:RefreshFollowerStatus()
end
function addon:EventGARRISON_FOLLOWER_REMOVED()
	wipe(followersCache)
	wipe(followersCacheIndex)
end
function addon:EventGARRISON_FOLLOWER_REMOVED()
	wipe(followersCache)
	wipe(followersCacheIndex)
end
-----------------------------------------------------
-- Coroutines data and clock management
-----------------------------------------------------
local coroutines={
	Timers={
		func=false,
		elapsed=60,
		interval=60,
		paused=false
	},
}

local lastmin=0
local MPShown=nil
local dbgFrame
local lastCPU=0
local startTime=GetTime()
-- Keeping it as a nice example of coroutine management.. but not using it anymore
function addon:Clock()
	if (GMFMissions.showInProgress)	 then
		--collectgarbage("collect") --while I fix it....
	else
		--collectgarbage("step",100)
	end
--[===[@debug@
	if (not dbgFrame) then
		dbgFrame=AceGUI:Create("Window")
		dbgFrame:SetTitle("GC Performance")
		dbgFrame:SetPoint("LEFT")
		dbgFrame:SetHeight(80)
		dbgFrame:SetWidth(350)
		dbgFrame:SetLayout("fill")
		dbgFrame.Text=AceGUI:Create("Label")
		dbgFrame.Text:SetColor(1,0,0)
		dbgFrame:AddChild(dbgFrame.Text)
	end
	local h,m=GetGameTime()
	if (m~=lastmin) then
		lastmin=m
	end
	local cpu=GetAddOnCPUUsage("GarrisonCommander")
	dbgFrame.Text:SetText(format("GC Cpu %3.2f/%2.2f/%2.2f Mem %4.3fMB ",
		cpu,
		cpu-lastCPU,cpu/(GetTime()-startTime),
		GetAddOnMemoryUsage("GarrisonCommander")/1024)
	)
	lastCPU=cpu
--@end-debug@]===]
	dbcache.lastseen=time()
	if (not MP or MPGoodGuy) then return  end
	MPShown=not self:GetBoolean("CKMP")
	local children={GMFMissions:GetChildren()}
	for i=1,#children do
		local child=children[i]
		if (child:GetObjectType()=="ScrollFrame") then
			if (child:GetName() ~= "GarrisonMissionFrameMissionsListScrollFrame") then
				if (MPShown) then child:Show() else child:Hide() end
			end
			if (child:GetName() == "GarrisonMissionFrameMissionsListScrollFrame") then
				if (MPShown) then child:Hide() else child:Show() end
			end
		end
	end
	if (MPShown) then
		GarrisonMissionFrameMissionsListScrollFrame:Hide()
	else
		GarrisonMissionFrameMissionsListScrollFrame:Show()
		GarrisonMissionFrameMissionsListScrollFrame:SetParent(GMFMissions)
	end
--[===[@debug@
	for k,d in pairs(coroutines) do
		local  co=coroutines[k]
		if (not co.func) then
			co.func=self["Generate"..k.."Periodic"](self)
			if (type(co.func) ~="function") then
				co.func=function() end
			end
		end
		co.elapsed=co.elapsed+1
		if not co.paused and co.elapsed > co.interval then
			co.elapsed=0
			co.paused=co.func(self)
		end
	end
--@end-debug@]===]
end
function addon:ActivateButton(button,OnClick,Tooltiptext,persistent)
	button:SetScript("OnClick",function(...) self[OnClick](self,...) end )
	if (Tooltiptext) then
		button.tooltip=Tooltiptext
		button:SetScript("OnEnter",ShowTT)
		if persistent then
			button:SetScript("OnLeave",function() GameTooltip:FadeOut() end)
		else
			button:SetScript("OnLeave",function() GameTooltip:Hide() end)
		end
	else
		button:SetScript("OnEnter",nil)
		button:SetScript("OnLeave",nil)
	end
end

function addon:Shrink(button)
	local f=button.Toggle
	local name=f:GetName() or "Unnamed"
	if (f:GetHeight() > 200) then
		f.savedHeight=f:GetHeight()
		f:SetHeight(200)
	else
		f:SetHeight(f.savedHeight)
	end
end
do
	local s=setmetatable({},{__index=function(t,k) return 0 end})
	local FOLLOWER_STATUS_FORMAT=(bigscreen and "Followers status " or "" )..
								C(AVAILABLE..':%d ','green') ..
								C(GARRISON_FOLLOWER_WORKING .. ":%d ",'cyan') ..
								C(GARRISON_FOLLOWER_ON_MISSION .. ":%d ",'red') ..
								C(GARRISON_FOLLOWER_INACTIVE .. ":%d","silver")
	function addon:RefreshFollowerStatus()
		wipe(s)
		for i=1,#followersCache do
			local status=self:GetFollowerStatus(followersCache[i].followerID)
			s[status]=s[status]+1
		end
		if (GMF.FollowerStatusInfo) then
			GMF.FollowerStatusInfo:SetWidth(0)
			GMF.FollowerStatusInfo:SetFormattedText(
				FOLLOWER_STATUS_FORMAT,
				s[AVAILABLE],
				s[GARRISON_FOLLOWER_WORKING],
				s[GARRISON_FOLLOWER_ON_MISSION],
				s[GARRISON_FOLLOWER_INACTIVE]
				)
		end
	end
	function addon:GetTotFollowers(status)
		return s[status] or 0
	end
end
function addon:ShowMissionControl()
	if (not GMC:IsShown()) then
		GarrisonMissionFrame_SelectTab(999)
		GMF.FollowerTab:Hide()
		GMF.FollowerList:Hide()
		GMF.MissionTab:Hide()
		GMF.TitleText:SetText("Garrison Commander Mission Control")
		GMC:Show()
		GMC.startButton:Click()
		GMC.tabMC:SetChecked(true)
	else
		GMC:Hide()
		GMC.tabMC:SetChecked(false)
		GarrisonMissionFrame_SelectTab(1)
	end
end
local helpwindow -- pseudo static
function addon:ShowHelpWindow(button)
	if (not helpwindow) then
		local backdrop = {
				--bgFile="Interface\\TutorialFrame\\TutorialFrameBackground",
				bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
				edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
				tile=true,
				tileSize=16,
				edgeSize=16,
				insets={bottom=7,left=7,right=7,top=7}
		}
		local dialog = {
			bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
			tile=true,
			tileSize=32,
			edgeSize=32,
			insets={bottom=5,left=5,right=5,top=5}
		}
		helpwindow=CreateFrame("Frame",nil,GCF)
		helpwindow:EnableMouse(true)
		helpwindow:SetBackdrop(backdrop)
		helpwindow:SetBackdropColor(1,1,1,1)
		helpwindow:SetFrameStrata("TOOLTIP")
		helpwindow:Show()
		local html=CreateFrame("SimpleHTML",nil,helpwindow)
		html:SetFontObject('h1',MovieSubtitleFont);
		local f=MailTextFontNormal_KO
		html:SetFontObject('h2',f);
		html:SetFontObject('h3',f);
		html:SetFontObject('p',f);
		html:SetTextColor('h1',C.Blue())
		html:SetTextColor('h2',C.Orange())
		html:SetTextColor('h3',C.Red())
		html:SetTextColor('p',C.Yellow())
		local text=[[<html><body>
<h1 align="center">Garrison Commander Help</h1>
<br/>
<p align="center">GC enhances standard Garrison UI by adding a Menu header and useful information in mission button and tooltip.
Since 2.0.2, the "big screen" mode became optional. If you choosed to disable it, some feature described here will not be available
</p>
<br/>
<h2>  Button list:</h2>
<p>
* Success percent with the current followers selection guidelines<br/>
* Time since the first time we saw this mission in log<br/>
* A "Good" party composition. on each member countered mechanics are shown.<br/>
*** Green border means full counter, Orange border low level counter<br/>
</p>
<h2>Tooltip:</h2>
<p>
* Overall mission status<br/>
* All members which can possibly play a role in the mission<br/>
</p>
<h2>Button enhancement:</h2>
<p>
* In rewards, actual quantity is shown (xp, money and resources) ot iLevel (item rewards)<br/>
* Countered status<br/>
</p>
<h2>Menu Header:</h2>
<p>
* Quick selection of which follower ignore for match making<br/>
* Quick mission list order selection<br/>
</p>
<h2>Mission Control:</h2>
<p>Thanks to Motig which donated the code, we have an auto lancher for mission<br/>
You specify some criteria mission should satisfy (success chance, rewards type etc) and matching missions will be autosubmitted<br/>
BE WARNED, FEATURE IS |cffff0000EXPERIMENTAL|r
</p>
]]
if (MP) then
text=text..[[
<p><br/></p>
<h3>Master Plan 0.20 or above detected</h3>
<p>Master Plan hides Garrison Commander interface for available missions<br/>
You can still use Garrison Commander Mission Control<br/>
You can switch between MP and GC interface for missions checking and unchecking "Use GC Interface" checkbox. It usually works :)
</p>
]]
end
if (MPGoodGuy) then
text=text..[[
<p><br/></p>
<h3>Master Plan 0.18 Detected</h3>
<p>This the last known version of Master Plan which leaves Blizzard UI available to other addons<br/>
You loose Garrison Commander Active Mission page, but the one provided by MP is good enough.<br/>
In order to see enhanced tooltips you need to hover on extra button.
</p>
]]
end
if (GMM) then
text=text..[[
<p><br/></p>
<h3>Garrison Mission Manager Detected</h3>
<p>Garrison Mission Manager and Garrison Commander plays reasonably well together.<br/>
The red button to the right of rewards is from GMM. It spills out of button, Yes, it's designed this way. Dunno why. Ask GMM author :)<br/>
Same thing for the three red buttons in mission page.
</p>
]]
end
text=text.."</body></html>"
		--html:SetTextColor('h1',C.Red())
		--html:SetTextColor('h2',C.Orange())
		helpwindow:SetWidth(800)
		helpwindow:SetHeight(590 + ((MP or MPGoodGuy) and 160 or 0) + (GMM and 120 or 0))
		helpwindow:SetPoint("TOPRIGHT",button,"TOPLEFT",0,0)
		html:ClearAllPoints()
		html:SetWidth(helpwindow:GetWidth()-20)
		html:SetHeight(helpwindow:GetHeight()-20)
		html:SetPoint("TOPLEFT",helpwindow,"TOPLEFT",10,-10)
		html:SetPoint("BOTTOMRIGHT",helpwindow,"BOTTOMRIGHT",-10,10)
		html:SetText(text)
		helpwindow:Show()
		return
	end
	if (helpwindow:IsShown()) then helpwindow:Hide() else helpwindow:Show() end
end
function addon:Toggle(button)
	local f=button.Toggle
	local name=f:GetName() or "Unnamed"
	if (f:IsShown()) then  f:Hide() else  f:Show() end
	if (button.SetChecked) then
		button:SetChecked(f:IsShown())
	end
end
-- Unused, experimenting with acegui
function addon:GenerateMissionsWidgets()
	self:GenerateMissionContainer()
	self:GenerateMissionButton()
end
function addon:GenerateMissionContainer()
	do
		local Type="GMCLayer"
		local Version=1
		local function OnRelease(self)
			wipe(self.childs)
		end
		local function OnAcquire(self)
			self.frame:SetParent(UIParent)
			self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
			self.frame:SetHeight(50)
			self.frame:SetWidth(100)
			self.frame:Show()
			self.frame:SetPoint("LEFT")
		end
		local function Show(self)
			self.frame:Show()
		end
		local function Hide(self)
			self.frame:Hide()
			self:Release()
		end
		local function SetScript(self,...)
			self.frame:SetScript(...)
		end
		local function SetParent(self,...)
			self.frame:SetParent(...)
		end
		local function PushChild(self,child,index)
			self.childs[index]=child
			self.scroll:AddChild(child)
		end
		local function RemoveChild(self,index)
			local child=self.childs[index]
			if (child) then
				self.childs[index]=nil
				child:Hide()
				self:DoLayout()
			end
		end
		local function ClearChildren(self)
			wipe(self.childs)
			self:AddScroll()
		end
		local function AddScroll(self)
			if (self.scroll) then
				self:ReleaseChildren()
				self.scroll=nil
			end
			self.scroll=AceGUI:Create("ScrollFrame")
			local scroll=self.scroll
			self:AddChild(scroll)
			scroll:SetLayout("List") -- probably?
			scroll:SetFullWidth(true)
			scroll:SetFullHeight(true)
			scroll:SetPoint("TOPLEFT",self.title,"BOTTOMLEFT",0,0)
			scroll:SetPoint("TOPRIGHT",self.title,"BOTTOMRIGHT",0,0)
			scroll:SetPoint("BOTTOM",self.content,"BOTTOM",0,0)
		end
		local function Constructor()
			local frame=CreateFrame("Frame")
			local title=frame:CreateFontString(nil, "BACKGROUND", "GameFontNormalHugeBlack")
			title:SetJustifyH("CENTER")
			title:SetJustifyV("CENTER")
			title:SetPoint("TOPLEFT")
			title:SetPoint("TOPRIGHT")
			title:SetHeight(0)
			title:SetWidth(0)
			addBackdrop(frame)
			local widget={childs={}}
			widget.title=title
			widget.type=Type
			widget.SetTitle=function(self,...) self.title:SetText(...) end
			widget.SetTitleColor=function(self,...) self.title:SetTextColor(...) end
			widget.SetFormattedTitle=function(self,...) self.title:SetFormattedText(...) end
			widget.SetTitleWidth=function(self,...) self.title:SetWidth(...) end
			widget.SetTitleHeight=function(self,...) self.title:SetHeight(...) end
			widget.frame=frame
			frame.obj=widget
			widget.OnAcquire=OnAcquire
			widget.OnRelease=OnRelease
			widget.Show=Show
			widget.Hide=Hide
			widget.SetScript=SetScript
			widget.SetParent=SetParent
			frame:SetScript("OnHide",function(self) self.obj:Fire('OnClose') end)
			--Container Support
			local content = CreateFrame("Frame",nil,frame)
			widget.content = content
			content.obj = self
			content:SetPoint("TOPLEFT",title,"BOTTOMLEFT")
			content:SetPoint("BOTTOMRIGHT")
			AceGUI:RegisterAsContainer(widget)
			widget.PushChild=PushChild
			widget.RemoveChild=RemoveChild
			widget.ClearChildren=ClearChildren
			widget.AddScroll=AddScroll
			return widget
		end
		AceGUI:RegisterWidgetType(Type,Constructor,Version)
	end
end

function addon:GenerateMissionButton()
	do
		local Type="GMCMissionButton"
		local Version=1
		local unique=0
		local function OnAcquire(self)
			local frame=self.frame
			frame.info=nil
			frame:SetHeight(80)
			self.frame:SetAlpha(1)
			self.frame:Enable()
		end
		local function Show(self)
			self.frame:Show()
		end
		local function Hide(self)
			self.frame:SetHeight(1)
			self.frame:SetAlpha(0)
			self.frame:Disable()
		end
		local function SetScript(self,...)
			self.frame:SetScript(...)
		end
		local function SetMission(self,mission,missionID)
			self.frame.info=mission
			addon:BuildMissionButton(self.frame,true)
			self.frame:EnableMouse(true)
			--self.frame:SetScript("OnEnter",GarrisonMissionPageFollowerFrame_OnEnter)
			--self.frame:SetScript("OnLeave",GarrisonMissionPageFollowerFrame_OnLeave)
			self.frame:SetScript("OnEnter",GarrisonMissionButton_OnEnter)
			self.frame:SetScript("OnLeave",function() GameTooltip:FadeOut() end)
			local party
			for i=1,#GMC.ml.Parties do
				party=GMC.ml.Parties[i]
				if party.missionID==missionID then
					break
				end
			end
			self.frame.Percent:SetFormattedText("%d%%",party.perc)
			self.frame.Percent:SetTextColor(addon:GetDifficultyColors(party.perc))
			local x=1
			for i=1,#party.members do
				x=i+1
				addon:RenderFollowerButton(self.frame.members[i],party.members[i],missionID)
				self.frame.members[i]:SetScript("OnEnter",GarrisonMissionPageFollowerFrame_OnEnter)
				self.frame.members[i]:SetScript("OnLeave",GarrisonMissionPageFollowerFrame_OnLeave)
				self.frame.members[i]:Show()
			end
			for i=x,3 do
				self.frame.members[i]:SetScript("OnEnter",nil)
				self.frame.members[i]:Hide()
			end
		end

		local function Constructor()
			unique=unique+1
			local frame=CreateFrame("Button",nil,nil,"GarrisonMissionListButtonTemplate") --"GarrisonCommanderMissionListButtonTemplate")
			local indicators=CreateFrame("Frame",nil,frame,"GarrisonCommanderIndicators")
			frame.Title:SetFontObject("QuestFont_Shadow_Small")
			frame.Summary:SetFontObject("QuestFont_Shadow_Small")
			if (bigscreen) then
				indicators.Percent:SetJustifyH("RIGHT")
			else
				indicators.Percent:SetJustifyH("LEFT")
			end
			indicators:SetPoint("LEFT",65,0)
			indicators.Age:Hide()
			frame.Percent=indicators.Percent
			frame:SetScript("OnEnter",nil)
			frame:SetScript("OnLeave",nil)
			frame:SetScript("OnClick",function(self,button) self.obj:Fire("OnClick",self,button) end)
			frame.LocBG:SetPoint("LEFT")
			frame.MissionType:SetPoint("TOPLEFT",5,-2)
			frame.members={}
			for i=1,3 do
				local f=CreateFrame("Button",nil,frame,"GarrisonCommanderMissionPageFollowerTemplateSmall" )
				frame.members[i]=f
				f:SetPoint("BOTTOMRIGHT",-65 -65 *i,5)
				f:SetScale(0.8)
			end
			local widget={}
			setmetatable(widget,{__index=frame})
			widget.type=Type
			widget.frame=frame
			frame.obj=widget
			widget.OnAcquire=OnAcquire
			widget.Show=Show
			widget.Hide=Hide
			widget.SetScript=SetScript
			widget.SetMission=SetMission
			return AceGUI:RegisterAsWidget(widget)

		end
		AceGUI:RegisterWidgetType(Type,Constructor,Version)
	end
end
function addon:__GMCBuildMiniMissionButton(frame,i,mission,scale,perc,offset)
	offset=offset or 20
	scale=scale or 0.6
	local panel=frame.Missions[i]
	if (not panel) then
		panel=CreateFrame("Button",nil,frame,"GarrisonCommanderMissionListButtonTemplate")
		panel:SetPoint("TOPLEFT",frame,1,-((i-1)*panel:GetHeight() +offset))
		panel:SetPoint("TOPRIGHT",frame,-1,-((i-1)*panel:GetHeight()-offset))
		panel.orderId=i
		tinsert(frame.Missions,panel)
		--Creo una riga nuova
		panel:SetScale(scale)
		panel.LocBG:SetPoint("LEFT")
	end
	panel.info=mission
	--panel.id=index[missionID]
	self:BuildMissionButton(panel)
	local q=self:GetDifficultyColor(perc)
	panel.Percent:SetFormattedText(GARRISON_MISSION_PERCENT_CHANCE,perc)
	panel.Percent:SetTextColor(q.r,q.g,q.b)
	panel.NumMembers:SetFormattedText(GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS,mission.numFollowers)
	panel:Show()
	return panel
end

function addon:CreateOptionsLayer(...)
	local o=AceGUI:Create("SimpleGroup") -- a transparent frame
	o:SetLayout("Flow")
	o:SetCallback("OnClose",function(widget) widget:Release() end)
	local totsize=0
	for i=1,select('#',...) do
		totsize=totsize+self:AddOptionToOptionsLayer(o,select(i,...))
	end
	return o,totsize
end
function addon:AddOptionToOptionsLayer(o,flag,maxsize)
	maxsize=tonumber(maxsize) or 140
	if (not flag) then return 0 end
	local info=self:GetVarInfo(flag)
	if (info) then
		local data={option=info}
		local widget
		if (info.type=="toggle") then
			widget=AceGUI:Create("CheckBox")
			local value=self:GetBoolean(flag)
			widget:SetValue(value)
			local color=value and "Green" or "Silver"
			widget:SetLabel(C(info.name,color))
			widget:SetWidth(max(widget.text:GetStringWidth(),maxsize))
		elseif(info.type=="select") then
			widget=AceGUI:Create("Dropdown")
			widget:SetValue(self:GetVar(flag))
			widget:SetLabel(info.name)
			widget:SetText(info.values[self:GetVar(flag)])
			widget:SetList(info.values)
			widget:SetWidth(maxsize)
		elseif (info.type=="execute") then
			widget=AceGUI:Create("Button")
			widget:SetText(info.name)
			widget:SetWidth(maxsize)
			widget:SetCallback("OnClick",function(widget,event,value)
				self[info.func](self,data,value)
			end)
		else
			widget=AceGUI:Create("Label")
			widget:SetText(info.name)
			widget:SetWidth(maxsize)
		end
		widget:SetCallback("OnValueChanged",function(widget,event,value)
			if (type(value=='boolean')) then
				local color=value and "Green" or "Silver"
				widget:SetLabel(C(info.name,color))
			end
			self[info.set](self,data,value)
		end)
		widget:SetCallback("OnEnter",function(widget)
			GameTooltip:SetOwner(widget.frame,"ANCHOR_CURSOR")
			GameTooltip:AddLine(info.desc)
			GameTooltip:Show()
		end)
		widget:SetCallback("OnLeave",function(widget)
			GameTooltip:FadeOut()
		end)
		o:AddChildren(widget)
	end
	return maxsize
end

function addon:Options()
	-- Main Garrison Commander Header
	GCF=CreateFrame("Frame","GCF",UIParent,"GarrisonCommanderTitle")
	-- Removing wood corner. I do it here to not derive an xml frame. This shoud play better with ui extensions
	GCF.CloseButton:Hide()
	for _,f in pairs({GCF:GetRegions()}) do
		if (f:GetObjectType()=="Texture" and f:GetAtlas()=="Garr_WoodFrameCorner") then f:Hide() end
	end
	GCF:SetFrameStrata(GMF:GetFrameStrata())
	GCF:SetFrameLevel(GMF:GetFrameLevel()-2)
	if (not bigscreen) then GCF:SetHeight(GCF:GetHeight()+35) end
	baseHeight=GCF:GetHeight()
	minHeight=47
	GCF.CloseButton:SetScript("OnClick",nil)
	GCF.Pin:SetAllPoints(GCF.CloseButton)
	GCF:SetWidth(BIGSIZEW)
	GCF:SetPoint("TOP",UIParent,0,-60)
	if (self:GetBoolean("PIN")) then
		GCF.Pin:SetChecked(true)
	else
		GCF.Pin:SetChecked(false)
	end

	do
		local baseHeight=baseHeight
		local minHeight=minHeight
		local baseStrata=GCF:GetFrameStrata()
		local baseLevel=GCF:GetFrameStrata()
		local speed=3
		local function shrink(this)
			addon:RemoveMenu()
			this:SetScript("OnUpdate",function(me,ts)
				local h=me:GetHeight()
				if (h<=45) then
					me:SetHeight(45)
					me:SetScript("OnUpdate",nil)
					GCF.tooltip=L["You can open the menu clicking on the icon in top right corner"]
				else
					me:SetHeight(h-2)
				end
			end)
		end
		local function grow(this)
			this:SetScript("OnUpdate",function(me,ts)
				local h=me:GetHeight()
				if (h>=baseHeight) then
					me:SetScript("OnUpdate",nil)
					me:SetHeight(baseHeight)
					if (not me.Menu) then addon:AddMenu() end
					GCF.tooltip=nil
					me.Menu:DoLayout()
				else
					me:SetHeight(h+2)
				end
			end)
		end
		GCF.Pin.tooltip=L["Toggles Garrison Commander Menu Header on/off"]
		GCF.Pin:SetScript("OnEnter",ShowTT)
		GCF.Pin:SetScript("OnClick",function(this)
			local value=this:GetChecked()
			this:SetChecked(value)
			addon:SetBoolean("PIN",value)
			if (value) then grow(GCF) else shrink(GCF) end
		end)
	end
	GCF:EnableMouse(true)
	GCF:SetMovable(true)
	GCF:RegisterForDrag("LeftButton")
	GCF:SetScript("OnDragStart",function(frame)if (self:GetBoolean("MOVEPANEL")) then frame:StartMoving() end end)
	GCF:SetScript("OnDragStop",function(frame) frame:StopMovingOrSizing() end)
	if (bigscreen) then
		--MinimizeButton
		-- It's not working well, now I dont have time to fix it
		if (false) then
		local h=CreateFrame("Button",nil,base,"UIPanelCloseButton")
		h:SetFrameLevel(999)
		h:SetNormalTexture("Interface\\BUTTONS\\UI-Panel-CollapseButton-Up")
		h:SetPushedTexture("Interface\\BUTTONS\\UI-Panel-CollapseButton-Down")
		h:SetHeight(32)
		h:SetWidth(32)
		h.Toggle=GMF
		h:SetPoint("TOPRIGHT")
		self:ActivateButton(h,"Shrink",L["Click to toggle Garrison Mission Frame"])
		GCF.gcHIDE=h
		end
		-- Mission list on follower panels
		local ml=CreateFrame("Frame","GCFMissions",GMFFollowers,"GarrisonCommanderFollowerMissionList")
		ml:SetPoint("TOPLEFT",GMFFollowers,"TOPRIGHT")
		ml:SetPoint("BOTTOMLEFT",GMFFollowers,"BOTTOMRIGHT")
		--ml:SetWidth(450)
		ml:Show()
		GCFMissions=ml
		local fs=GMFFollowers:CreateFontString(nil, "BACKGROUND", "GameFontNormalHugeBlack")
		fs:SetPoint("TOPLEFT",GMFFollowers,"TOPRIGHT")
		fs:SetText(AVAILABLE)
		fs:SetWidth(250)
		fs:Show()
		GCFBusyStatus=fs
	end
	self:Trigger("MOVEPANEL")
	self.Options=function() end
end

function addon:ScriptTrace(hook,frame,...)
--[===[@debug@
	xprint("Triggered " .. C(hook,"red").." script on",C(frame,"Azure"),...)
--@end-debug@]===]
end
function addon:IsProgressMissionPage()
	return GMF:IsShown() and GMF.MissionTab and GMF.MissionTab.MissionList.showInProgress
end
function addon:IsAvailableMissionPage()
	return GMF:IsShown() and GMF.MissionTab:IsShown() and not GMF.MissionTab.MissionList.showInProgress
end
function addon:IsFollowerList()
	return GMF:IsShown() and GMFFollowers:IsShown()
end
--GMFMissions.CompleteDialog
function addon:IsRewardPage()
	return GMF:IsShown() and GMF.MissionComplete:IsShown()

end
function addon:IsMissionPage()
	return GMF:IsShown() and GMFMissionPage:IsShown() and GMFFollowers:IsShown()
end
---
-- Switches between missions (1) and followers (others) panels
function addon:HookedGarrisonMissionFrame_SelectTab(id)
	GMC:Hide()
	GMC.tabMC:SetChecked(false)
	self:RefreshFollowerStatus()
	wipe(GMCUsedFollowers)
end
---
-- Switchs between active and availabla missions depending on tab object
do
	local original=GarrisonMissionList_SetTab
		function GarrisonMissionList_SetTab(...)
		-- I dont actually care wich page we are shoing, I know I must redraw missions
		original(...)
		addon:RefreshFollowerStatus()
		for i=1,#GMFMissionListButtons do
			GMFMissionListButtons.lastMissionID=nil
		end
		if (HD) then addon:ResetSinks() end
	end
end
function addon:HookedGarrisonMissionFrame_HideCompleteMissions()
	self:BuildMissionsCache(true,true)
end


function addon:HookedGarrisonFollowerTooltipTemplate_SetGarrisonFollower(...)
	local h=GarrisonFollowerTooltip:GetHeight()
	local ft=GarrisonFollowerTooltip.ft
	if (not ft) then
		local backdrop = {
			bgFile="Interface\\TutorialFrame\\TutorialFrameBackground",
			edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
			tile=true,
			tileSize=16,
			edgeSize=16,
			insets={bottom=3,left=3,right=3,top=3}
		}
		ft=CreateFrame("Frame",nil,GarrisonFollowerTooltip)
		ft:SetBackdrop(backdrop)
		ft:SetBackdropColor(1,1,1,1)
		local fs=ft:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
		GarrisonFollowerTooltip.ft=ft
		fs:SetWidth(0)
		fs:SetHeight(0)
		fs:SetText(L["Left Click to see available missions"].."\n"..L["Right click to open ignore menu"])
		fs:SetTextColor(C.Green())
		ft:SetPoint("TOPLEFT",GarrisonFollowerTooltip,"BOTTOMLEFT",5,5)
		ft:SetPoint("TOPRIGHT",GarrisonFollowerTooltip,"BOTTOMRIGHT",-5,5)
		ft:SetHeight(45)
		fs:SetAllPoints()
	end
	if (self:IsMissionPage()) then
		ft:Hide()
	else
		ft:Show()
	end
end
function addon:HookedGarrisonFollowerButton_UpdateCounters(frame,follower,showCounters)
	if not frame.GCIt then
		if not MP then
			frame.GCTime=frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
			frame.GCTime:SetPoint("TOPLEFT",frame.Status,"TOPRIGHT",5,0)
			frame.GCXp=frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
			frame.GCXp:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",0,2)
		end
		frame.GCIt=frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
		frame.GCIt:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-5,-3)
	end
	if not frame.isCollected then
		if not MP then
			frame.GCTime:Hide()
			frame.GCXp:Hide()
		end
		frame.GCIt:Hide()
		return
	end
	if not MP then
		if (frame.Status:GetText() == GARRISON_FOLLOWER_ON_MISSION) then
			frame.GCTime:SetText(self:GetFollowerStatus(follower.followerID,true,true))
			frame.GCTime:Show()
		else
			frame.GCTime:Hide()
		end
		if (follower.level >= GARRISON_FOLLOWER_MAX_LEVEL and follower.quality >= GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY) then
			frame.GCXp:Hide()
		else
			frame.GCXp:SetFormattedText("Xp to next upgrade: %d",follower.levelXP-follower.xp)
			frame.GCXp:Show()
		end
	end
	if (follower.level >= GARRISON_FOLLOWER_MAX_LEVEL and self:GetToggle("ILV") ) then
		local follower=self:GetFollowerData(follower.followerID)
		local c1=ITEM_QUALITY_COLORS[follower.weaponQuality or 1]
		local c2=ITEM_QUALITY_COLORS[follower.armorQuality or 1]
		frame.GCIt:SetFormattedText("W:%s%3d|r A:%s%3d|r",c1.hex,follower.weaponItemLevel,c2.hex,follower.armorItemLevel)
		frame.GCIt:Show()
	else
		frame.GCIt:Hide()
	end

end
function addon:HookedGarrisonFollowerListButton_OnClick(frame,button)
	if (frame.info.isCollected) then
		if (button=="LeftButton") then
			if (bigscreen)  then self:HookedGarrisonFollowerPage_ShowFollower(frame.info,frame.info.followerID) end
		end
		self:ScheduleTimer("HookedGarrisonFollowerButton_UpdateCounters",0.2,frame,frame.info,false)
	end
end
-- Shamelessly stolen from Blizzard Code
function addon:BuildMissionButton(button,gmc,...)
	local mission=button.info
	if (not mission or not mission.name) then
		if (button.missionID) then
			mission=self:GetMissionData(button.missionID)
		end
	end
	if (not mission) then return end
	button.Title:SetWidth(0);
	button.Title:SetText(mission.name);
	button.Level:SetText(mission.level);
	if ( mission.durationSeconds >= GARRISON_LONG_MISSION_TIME ) then
		local duration = format(GARRISON_LONG_MISSION_TIME_FORMAT, mission.duration);
		button.Summary:SetFormattedText(PARENS_TEMPLATE, duration);
	else
		button.Summary:SetFormattedText(PARENS_TEMPLATE, mission.duration);
	end
	local tw=button:GetWidth() -165
	if ( button.Title:GetWidth() + button.Summary:GetWidth() + 8 < tw - mission.numRewards * 65 ) then
		button.Title:SetPoint("LEFT", 165, 0);
		button.Summary:ClearAllPoints();
		button.Summary:SetPoint("BOTTOMLEFT", button.Title, "BOTTOMRIGHT", 8, 0);
	else
		button.Title:SetPoint("LEFT", 165, 10);
		button.Title:SetWidth(tw - mission.numRewards * 65);
		button.Summary:ClearAllPoints();
		button.Summary:SetPoint("TOPLEFT", button.Title, "BOTTOMLEFT", 0, -4);
	end
	if gmc then button.Title:SetPoint("LEFT",70,25) end
	if ( mission.locPrefix ) then
		button.LocBG:Show();
		button.LocBG:SetAtlas(mission.locPrefix.."-List");
	else
		button.LocBG:Hide();
	end
	if (mission.isRare) then
		button.RareOverlay:Show();
		button.RareText:Show();
		button.IconBG:SetVertexColor(0, 0.012, 0.291, 0.4)
	else
		button.RareOverlay:Hide();
		button.RareText:Hide();
		button.IconBG:SetVertexColor(0, 0, 0, 0.4)
	end
	local showingItemLevel = false;
	if ( mission.level == GARRISON_FOLLOWER_MAX_LEVEL and mission.iLevel > 0 ) then
		button.ItemLevel:SetFormattedText(NUMBER_IN_PARENTHESES, mission.iLevel);
		button.ItemLevel:Show();
		showingItemLevel = true;
	else
		button.ItemLevel:Hide();
	end
	if ( showingItemLevel and mission.isRare ) then
		button.Level:SetPoint("CENTER", button, "TOPLEFT", 40, -22);
	else
		button.Level:SetPoint("CENTER", button, "TOPLEFT", 40, -36);
	end

	--button:Enable();
	if (mission.inProgress) then
		button.Overlay:Show();
		button.Summary:SetText(mission.timeLeft.." "..RED_FONT_COLOR_CODE..GARRISON_MISSION_IN_PROGRESS..FONT_COLOR_CODE_CLOSE);
	else
		button.Overlay:Hide();
	end
	button.MissionType:SetAtlas(mission.typeAtlas);
	GarrisonMissionButton_SetRewards(button,mission.rewards, mission.numRewards);
	button:Show();

end
-- Ripped bleeding from Blizzard code. In mini buttons I cant suffer MP staff
function addon:ClonedGarrisonMissionButton_SetRewards(rewards, numRewards)
	if (numRewards > 0) then
		local index = 1;
		for id, reward in pairs(rewards) do
			if (not self.Rewards[index]) then
				self.Rewards[index] = CreateFrame("Frame", nil, self, "GarrisonMissionListButtonRewardTemplate");
				self.Rewards[index]:SetPoint("RIGHT", self.Rewards[index-1], "LEFT", 0, 0);
			end
			local Reward = self.Rewards[index];
			Reward.Quantity:Hide();
			Reward.itemID = nil;
			Reward.currencyID = nil;
			Reward.tooltip = nil;
			if (reward.itemID) then
				Reward.itemID = reward.itemID;
				GarrisonMissionFrame_SetItemRewardDetails(Reward);
				if ( reward.quantity > 1 ) then
					Reward.Quantity:SetText(reward.quantity);
					Reward.Quantity:Show();
				end
			else
				Reward.Icon:SetTexture(reward.icon);
				Reward.title = reward.title
				if (reward.currencyID and reward.quantity) then
					if (reward.currencyID == 0) then
						Reward.tooltip = GetMoneyString(reward.quantity);
					else
						Reward.currencyID = reward.currencyID;
						Reward.Quantity:SetText(reward.quantity);
						Reward.Quantity:Show();
					end
				else
					Reward.tooltip = reward.tooltip;
				end
			end
			Reward:Show();
			index = index + 1;
		end
	end

	for i = (numRewards + 1), #self.Rewards do
		self.Rewards[i]:Hide();
	end
end
function addon:ClonedGarrisonMissionMechanic_OnEnter(missionID,this,...)
	local tip=GameTooltip
	tip:SetOwner(this, "ANCHOR_CURSOR_RIGHT");
	tip:AddLine(this.info.name,C.White())
	--tip:AddTexture(this.Icon:GetTexture())
	tip:AddLine(this.info.description,C.Orange())
	local t=new()
	self:GetAllCounters(missionID,this.Icon:GetTexture(),t)
	if( #t > 0) then
		tip:AddLine(GARRISON_MISSION_COUNTER_FROM)
		for i=1,#t do
			tip:AddLine(self:GetFollowerData(t[i],'fullname'),C[self:GetBiasColor(t[i],missionID,C.White())]())
		end
	end
	del(t)
	tip:Show()
end
local Busystatusmessage
function addon:HookedGarrisonFollowerPage_ShowFollower(frame,followerID)
	local i=0
	if (not self:IsFollowerList()) then return end
	if (not GCFMissions.Missions) then GCFMissions.Missions={} end
	if (not Busystatusmessage) then Busystatusmessage=C(BUSY_MESSAGE,"Red)") end
	-- frame has every info you can need on a follower, but here I dont really need them, maybe just counters
	--xdump(table.Counters)
	local followerName=self:GetFollowerData(followerID,'name')
	repeat -- a poor man goto
		if (type(frame.followerID)=="number") then
			GCFBusyStatus:SetText(NOT_COLLECTED)
			GCFBusyStatus:SetTextColor(C.Red())
			break
		end

		local index=new()
		local partyIndex=new()

		local status=self:GetFollowerStatus(followerID)
		local list
		local m1,m2,m3,perc,numFollowers=nil,nil,nil,0,""
		if (status ~= AVAILABLE and status ~= GARRISON_FOLLOWER_IN_PARTY) then
			if (status==GARRISON_FOLLOWER_ON_MISSION) then
				local missionID=dbcache.runningIndex[followerID]
				if (not missionID) then return end
				list=GMF.MissionTab.MissionList.inProgressMissions
				m1=followerID
				perc=select(4,G.GetPartyMissionInfo(missionID))
				for j=1,#list do
					index[list[j].missionID]=j
				end
				local pos=index[missionID]
				if (not pos) then return end
				numFollowers=#list[index[missionID]].followers
				tinsert(partyIndex,-missionID)
				GCFBusyStatus:SetText(GARRISON_FOLLOWER_ON_MISSION)
			else
				GCFBusyStatus:SetText(self:GetFollowerStatus(followerID,false,true)) -- no time, colored
			end
			GCFBusyStatus:SetTextColor(C.Red())

		else
			GCFBusyStatus:SetText(Busystatusmessage)
			list=GMF.MissionTab.MissionList.availableMissions
			for j=1,#list do
				index[list[j].missionID]=j
			end
			for k,_ in pairs(parties) do
				tinsert(partyIndex,k)
			end
			table.sort(partyIndex,function(a,b) return parties[a].perc > parties[b].perc end)
		end
		self:RenderFollowerButton(GCFMissions.Header,followerID)
		-- Scanning mission list
		for z = 1,#partyIndex do
			local missionID=partyIndex[z]
			if not(tonumber(missionID)) then
--[===[@debug@
				xprint("missionid not a number",missionID)
				self:Dump("partyIndex table",partyIndex)
--@end-debug@]===]
				perc=-1 --(lowering perc  to ignore this mission
			end

			if (missionID>0) then
				local p=parties[missionID]
				m1,m2,m3,perc=p.members[1],p.members[2],p.members[3],tonumber(p.perc) or 0
				if (m3) then
					numFollowers=3
				elseif(m2) then
					numFollowers=2
				else
					numFollowers=1
				end
			else
				missionID=abs(missionID)
			end
			if (perc>MINPERC and ( m1 == followerID or m2==followerID or m3==followerID)) then
				i=i+1
				local mission=list[index[missionID]]
				local panel=GCFMissions.Missions[i]
				if (not panel) then
					panel=CreateFrame("Button",nil,GCFMissions,"GarrisonCommanderMissionListButtonTemplate")
					self:SafeHookScript(panel,"OnClick","OnClick_GarrisonMissionButton",true)

					if (i==1) then
						panel:SetPoint("TOPLEFT",GCFMissions.Header,"BOTTOMLEFT")
					else
						panel:SetPoint("TOPLEFT",GCFMissions.Missions[i-1],"BOTTOMLEFT")
						panel:SetPoint("TOPRIGHT",GCFMissions.Missions[i-1],"BOTTOMRIGHT")
					end
					tinsert(GCFMissions.Missions,panel)
					--Creo una riga nuova
					panel:SetScale(0.6)
					panel.fromFollowerPage=true
					panel.LocBG:SetPoint("LEFT")
				end
				panel.info=mission
				--panel.id=index[missionID]
				self:BuildMissionButton(panel)
				local q=self:GetDifficultyColor(perc)
				panel.Percent:SetFormattedText(GARRISON_MISSION_PERCENT_CHANCE,perc)
				panel.Percent:SetTextColor(q.r,q.g,q.b)
				panel.NumMembers:SetFormattedText(GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS,numFollowers)
				panel:Show()
				if (i>= MAXMISSIONS) then break end
			end
		end
		del(partyIndex)
		del(index)
	until true
	if (i>0) then
		GCFBusyStatus:SetPoint("TOPLEFT",GCFMissions.Missions[i],"BOTTOMLEFT",0,-5)
	else
		GCFBusyStatus:SetPoint("TOPLEFT",GCFMissions.Header,"BOTTOMLEFT",0,-5)
	end
	i=i+1
	for x=i,#GCFMissions.Missions do GCFMissions.Missions[x]:Hide() end
end
---
--Initial one time setup
function addon:SetUp(...)
--[===[@debug@
	xprint("Setup")
--@end-debug@]===]
--[===[@alpha@
	if (not db.alfa.v220) then
		self:Popup(L["You are using an Alpha version of Garrison Commander. Please post bugs on Curse if you find them"],10)
		db.alfa.v220=true
	end
--@end-alpha@]===]

	SIZEV=GMF:GetHeight()
	self:CheckMP()
	self:CheckGMM()
	self:Options()
	self:GenerateMissionsWidgets()
	self:GMCBuildPanel()
	local tabMC=CreateFrame("CheckButton",nil,GMF,"SpellBookSkillLineTabTemplate")
	tabMC.tooltip="Open Garrison Commander Mission Control"
	--tab:SetNormalTexture("World\\Dungeon\\Challenge\\clockRunes.blp")
	--tab:SetNormalTexture("Interface\\Timer\\Challenges-Logo.blp")
	tabMC:SetNormalTexture("Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_WORKINGOVERTIME.blp")
	self:MarkAsNew(tabMC,'MissionControl','New in 2.2.0! Try automatic mission management!')
	tabMC:Show()
	GMC.tabMC=tabMC
	GMF.FollowerStatusInfo=GMF:CreateFontString(nil, "BORDER", "GameFontNormal")
	GMF.FollowerStatusInfo:SetPoint("TOPRIGHT",-30,-5)
	local tabCF=CreateFrame("Button",nil,GMF,"SpellBookSkillLineTabTemplate")
	tabCF.tooltip="Open Garrison Commander Configuration Screen"
	tabCF:SetNormalTexture("Interface\\ICONS\\Trade_Engineering.blp")
	tabCF:SetPushedTexture("Interface\\ICONS\\Trade_Engineering.blp")
	tabCF:Show()
	local tabHP=CreateFrame("Button",nil,GMF,"SpellBookSkillLineTabTemplate")
	tabHP.tooltip="Open Garrison Commander Help"
	tabHP:SetNormalTexture("Interface\\ICONS\\INV_Misc_QuestionMark.blp")
	tabHP:SetPushedTexture("Interface\\ICONS\\INV_Misc_QuestionMark.blp")
	tabHP:Show()
	tabMC:SetScript("OnClick",function(this,...) addon:ShowMissionControl() end)
	tabCF:SetScript("OnClick",function(this,...) addon:Gui() end)
	tabHP:SetScript("OnClick",function(this,button) addon:ShowHelpWindow(this,button) end)
	tabHP:SetPoint('TOPLEFT',GCF,'TOPRIGHT',0,-10)
	tabCF:SetPoint('TOPLEFT',GCF,'TOPRIGHT',0,-60)
	tabMC:SetPoint('TOPLEFT',GCF,'TOPRIGHT',0,-110)
	self:StartUp()
	--collectgarbage("step",10)
--/Interface/FriendsFrame/UI-Toast-FriendOnlineIcon
end
function addon:AddMenu()
	local menu,size=self:CreateOptionsLayer(MP and 'CKMP' or nil,'BIGSCREEN','MOVEPANEL','IGM','IGP','NOFILL','MSORT')
	--self:AddOptionToOptionsLayer(GCF.Menu,'MSORT')
	--self:AddOptionToOptionsLayer(GCF.Menu,'ShowMissionControl')
--[===[@debug@
	self:AddOptionToOptionsLayer(menu,'DBG')
	self:AddOptionToOptionsLayer(menu,'TRC')
--@end-debug@]===]
	local frame=menu.frame
	frame:Show()
	menu:ClearAllPoints()
	menu:SetPoint("TOPLEFT",GCF,"TOPLEFT",25,-18)
	menu:SetWidth(GCF:GetWidth()-50)
	menu:SetHeight(GCF:GetHeight()-50)
	menu:DoLayout()
	GCF.Menu=menu
end
function addon:RemoveMenu()
	if (GCF.Menu) then
		pcall(GCF.Menu.Release,GCF.Menu)
		GCF.Menu=nil
	end
end
function addon:AddMissionId(b)
	if (b.info and b.info.missionID) then
		GameTooltip:AddDoubleLine("MissionID",b.info.missionID)
		GameTooltip:Show()
	end
end
---
-- Additional setup
-- This method is called every time garrison mission panel is open because
-- when it closes, I remove most of used hooks
function addon:StartUp(...)
--[===[@debug@
	xprint("Startup")
--@end-debug@]===]
	self:GrowPanel()
	self:Unhook(GMF,"OnShow")
	if (self:GetBoolean("PIN")) then
		GCF:SetHeight(baseHeight)
		self:AddMenu()
	else
		GCF:SetHeight(minHeight)
	end
	self:PermanentEvents()
	self:SafeSecureHook("GarrisonMissionButton_AddThreatsToTooltip")
	self:SafeSecureHook("GarrisonMissionButton_SetRewards")
	self:SafeSecureHook("GarrisonFollowerListButton_OnClick") -- used both to update follower mission list and itemlevel display
	if (bigscreen) then
		self:SafeSecureHook("GarrisonFollowerPage_ShowFollower")--,function(...) xprint("GarrisonFollowerPage_ShowFollower",...) end)
		self:SafeSecureHook("GarrisonFollowerTooltipTemplate_SetGarrisonFollower")
	end
	self:SafeSecureHook("GarrisonMissionFrame_HideCompleteMissions")	-- Mission reward completed
	self:SafeSecureHook("GarrisonMissionPage_ShowMission")
	self:SafeSecureHook("GarrisonMissionFrame_SelectTab")
	-- GarrisonMissionList_SetTab is overrided

	self:SafeHookScript(GMFMissions,"OnShow")--,"GrowPanel")
	self:SafeHookScript(GMFFollowers,"OnShow")--,"GrowPanel")
	self:SafeHookScript(GCF,"OnHide","CleanUp",true)

	-- Mission management
	self:SafeHookScript(GMF.MissionComplete.NextMissionButton,"OnClick","OnClick_GarrisonMissionFrame_MissionComplete_NextMissionButton",true)
	-- Hooking mission buttons on click
	for i=1,#GMFMissionListButtons do
		local b=GMFMissionListButtons[i]
		self:SafeHookScript(b,"OnClick","OnClick_GarrisonMissionButton",true)
--[===[@debug@
		self:SafeHookScript(b,"OnEnter","AddMissionId",true)
--@end-debug@]===]
	end
	if HD then self:ScheduleRepeatingTimer("Clock",1) end
	self:BuildMissionsCache(true,true)
	self:BuildRunningMissionsCache()
	self:RefreshFollowerStatus()
	self:Trigger("MSORT")
	self:Trigger("CKMP")
end
function addon:MarkAsNew(obj,key,message)
	if (not db.news[key]) then
		local f=CreateFrame("Frame",nil,obj,"GarrisonCommanderWhatsNew")
		f.tooltip=message
		f:SetPoint("BOTTOMLEFT",obj,"TOPRIGHT")
		f:Show()
	end
end
-- probably not really needed, havenr seen yet them firing out of garrison
function addon:PermanentEvents()
	self:SafeRegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")
	self:SafeRegisterEvent("GARRISON_MISSION_STARTED")
	self:SafeRegisterEvent("GARRISON_MISSION_BONUS_ROLL_LOOT")
	self:SafeRegisterEvent("GARRISON_MISSION_NPC_CLOSED")
	self:SafeRegisterEvent("GARRISON_FOLLOWER_XP_CHANGED")
	self:SafeRegisterEvent("GARRISON_FOLLOWER_ADDED")
	self:SafeRegisterEvent("GARRISON_FOLLOWER_REMOVED")
	self:RegisterBucketEvent("GARRISON_MISSION_LIST_UPDATE",2,"EventGARRISON_MISSION_LIST_UPDATE")
	self:SafeRegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
	-- Follower button enhancement in follower list
	self:SafeSecureHook("GarrisonFollowerButton_UpdateCounters")
--[===[@debug@
	self:DebugEvents()
--@end-debug@]===]
end
function addon:DebugEvents()
	if true then return end
	self:SafeRegisterEvent("GARRISON_MISSION_BONUS_ROLL_LOOT")
	self:SafeRegisterEvent("GARRISON_MISSION_FINISHED")
	self:SafeRegisterEvent("GARRISON_UPDATE")
	self:SafeRegisterEvent("GARRISON_USE_PARTY_GARRISON_CHANGED")
	self:SafeRegisterEvent("GARRISON_MISSION_NPC_OPENED")
	self:SafeSecureHook("GarrisonMissionList_UpdateMissions")
	self:SafeSecureHook("GarrisonMissionFrame_ShowCompleteMissions")
	self:SafeSecureHook("GarrisonMissionFrame_CheckCompleteMissions")
	self:SafeSecureHook("MissionCompletePreload_LoadMission")


end
function addon:checkMethod(method,hook)
	if (type(self[method])=="function") then
--[===[@debug@
		--xprint("Hooking ",hook,"to self:" .. method)
--@end-debug@]===]
		return true
--[===[@debug@
	else
		--xprint("Hooking ",hook,"to print")
--@end-debug@]===]
	end
end
function addon:SafeRegisterEvent(event)
	local method="Event"..event
	if (self:checkMethod(method,event)) then
		return self:RegisterEvent(event,method)
--[===[@debug@
	else
		return self:RegisterEvent(event,xprint)
--@end-debug@]===]
	end
end
function addon:SafeSecureHook(tobehooked,method)
	if (self:IsHooked(tobehooked)) then return end
	method=method or "Hooked"..tobehooked
	if (self:checkMethod(method,tobehooked)) then
		return self:SecureHook(tobehooked,method)
--[===[@debug@
	else
		do
			local hooked=tobehooked
			return self:SecureHook(tobehooked,function(...) xprint(hooked,...) end)
		end
--@end-debug@]===]
	end
end
function addon:SafeHookScript(frame,hook,method,postHook)
	local name="Unknown"
	if (type(frame)=="string") then
		name=frame
		frame=_G[frame]
	else
		if (frame and frame.GetName) then
			name=frame:GetName()
		end
	end
	if (frame) then
		if (self:IsHooked(frame,hook)) then return end
		if (method) then
			if (postHook) then
				self:SecureHookScript(frame,hook,method)
			else
				self:HookScript(frame,hook,method)
			end
		else
			if (postHook) then
				self:SecureHookScript(frame,hook,function(...) self:ScriptTrace(name,hook,...) end)
			else
				self:HookScript(frame,hook,function(...) self:ScriptTrace(name,hook,...) end)
			end
		end
	end
end

function addon:CleanUp()
	self:UnhookAll()
	self:CancelAllTimers()
	self:RemoveMenu()
	self:HookScript(GMF,"OnSHow","StartUp",true)
	self:PermanentEvents() -- Reattaching permanent events
	if (GarrisonFollowerTooltip.fs) then
		GarrisonFollowerTooltip.fs:Hide()
	end
	--collectgarbage("collect")
--[===[@debug@
	xprint("Cleaning up")
--@end-debug@]===]
end
function addon:EventGARRISON_FOLLOWER_XP_CHANGED(event,followerID,iLevel,xp,level,quality)
	local i=followersCacheIndex[followerID]
	if (i) then
		local follower=followersCache[i]
		if follower and follower.checkID and follower.checkID==followerID then
			follower.iLevel=iLevel
			follower.xp=xp
			follower.level=level
			follower.quality=quality
			follower.rank=follower.level==100 and follower.iLevel or follower.level
			follower.coloredname=C(follower.name,tostring(follower.quality))
			follower.fullname=format("%3d %s",follower.rank,follower.coloredname)
			follower.maxed=follower.quality >= GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY and follower.level >=GARRISON_FOLLOWER_MAX_LEVEL
			return -- single updated
		end
	end
	wipe(followersCache)
	self:GetFollowerData(followerID)  -- triggering a full cache refresh
end

function addon:GetFollowerData(key,subkey)
	local k=followersCacheIndex[key]
	if (not followersCache[1]) then
		xprint("Follower cache refresh")
		followersCache=G.GetFollowers()
		for i,follower in pairs(followersCache) do
			if (not follower.isCollected) then
				followersCache[i]=nil
			else
				follower.rank=follower.level==100 and follower.iLevel or follower.level
				follower.coloredname=C(follower.name,tostring(follower.quality))
				follower.fullname=format("%3d %s",follower.rank,follower.coloredname)
				follower.maxed=follower.quality >= GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY and follower.level >=GARRISON_FOLLOWER_MAX_LEVEL
				local weaponItemID, weaponItemLevel, armorItemID, armorItemLevel = G.GetFollowerItems(follower.followerID);
				follower.weaponItemID=weaponItemID
				follower.weaponItemLevel=weaponItemLevel
				follower.armorItemID=armorItemID
				follower.armorItemLevel=armorItemLevel
				follower.weaponQuality=select(3,GetItemInfo(weaponItemID))
				follower.armorQuality=select(3,GetItemInfo(armorItemID))
			end
		end
	end
	local t=followersCache
	if (not k) then
		for i=1,#t do
			if (t[i] and (t[i].followerID == key or t[i].name==key)) then
				followersCacheIndex[t[i].followerID]=i
				followersCacheIndex[t[i].name]=i
				k=i
				break
			end
		end
	end
	if (k) then
		if (subkey) then
			return t[k][subkey]
		else
			return t[k]
		end
	else
		return nil
	end
end
function addon:GetMissionData(missionID,subkey)
	local missionCache=cache.missions[missionID]
	if (not missionCache) then
--[===[@debug@
		xprint("Found a new mission",missionID,"Refreshing it")
--@end-debug@]===]
		self:BuildMissionCache(missionID)
		self:FillCounters(missionID,cache.missions[missionID])
		self:MatchMaker(missionID,cache.missions[missionID])
	end
	if (subkey) then
		if not missionCache then return 0 end
		return missionCache[subkey]
	end
	return missionCache
end
function addon:GetFollowerStatusForMission(followerID,skipbusy)
	if (GMCUsedFollowers[followerID]) then
		return false
	end
	if (not skipbusy) then
		return true
	else
		return self:GetFollowerStatus(followerID) == AVAILABLE
	end
end
function addon:GetFollowerStatus(followerID,withTime,colored)
	if (not followerID) then return UNAVAILABLE end
	local status=G.GetFollowerStatus(followerID)
	if (status and status== GARRISON_FOLLOWER_ON_MISSION and withTime) then
		local running=dbcache.running[dbcache.runningIndex[followerID]]
		status=SecondsToTime(running.started + running.duration - time() ,true)
	end
-- The only case a follower appears in party is after a refused mission due to refresh triggered before GARRISON_FOLLOWER_LIST_UPDATE
	if (status and status~=GARRISON_FOLLOWER_IN_PARTY) then
		return colored and C(status,"Red") or status
	else
		return colored and C(AVAILABLE,"Green") or AVAILABLE
	end
end
function addon:RemoveFromAllMissions(followerID)
	for i=1,#cache.missions do
		pcall(G.RemoveFollowerFromMission,followerID,cache.missions[i])
	end
end
function addon:FillMissionPage(missionInfo)
	if( IsControlKeyDown()) then xprint("Shift key, ignoring mission prefill") return end
	if (self:GetBoolean("NOFILL")) then return end
	local missionID=missionInfo.missionID
--[===[@debug@
	xprint("UpdateMissionPage for",missionID,missionInfo.name,missionInfo.numFollowers)
--@end-debug@]===]
	--xdump(missionInfo)
	--self:BuildMissionData(missionInfo.missionID.missionInfo)
	GarrisonMissionPage_ClearParty()
	local party=parties[missionID]
	if (party) then
		holdEvents()
		local members=party.members
		for i=1,missionInfo.numFollowers do
			local followerID=members[i]
			if (followerID) then
				local status=G.GetFollowerStatus(followerID)
				if (status) then
					if status == GARRISON_FOLLOWER_IN_PARTY then -- Left from a previous assignment?
--[===[@debug@
						xprint(followerID,self:GetFollowerData(followerID,"name"),"was already on mission")
--@end-debug@]===]
						self:RemoveFromAllMissions(followerID)
						GarrisonMissionPage_AddFollower(followerID)
					else
						self:Popup("You attemped to use a busy follower. Please check '" .. IGNORE_UNAIVALABLE_FOLLOWERS .."'",10)
					end
				else
					pcall(G.RemoveFollowerFromMission,missionID,followerID)
					xprint("Adding",followerID,G.GetFollowerName(followerID))
					GarrisonMissionPage_AddFollower(followerID)
				end
			end
		end
		releaseEvents()
	end
	GarrisonMissionPage_UpdateMissionForParty()
end
local firstcall=true

---@function GrowPanel
-- Enforce the new panel sizes
--
function addon:GrowPanel()
	GCF:Show()
	if (bigscreen) then
--		GMF:ClearAllPoints()
--		GMF:SetPoint("TOPLEFT",GCF,"BOTTOMLEFT")
--		GMF:SetPoint("TOPRIGHT",GCF,"BOTTOMRIGHT")
		GMFRewardSplash:ClearAllPoints()
		GMFRewardSplash:SetPoint("TOPLEFT",GCF,"BOTTOMLEFT")
		GMFRewardSplash:SetPoint("TOPRIGHT",GCF,"BOTTOMRIGHT")
		GMFRewardPage:ClearAllPoints()
		GMFRewardPage:SetPoint("TOPLEFT",GCF,"BOTTOMLEFT")
		GMFRewardPage:SetPoint("TOPRIGHT",GCF,"BOTTOMRIGHT")
		GMF:SetHeight(BIGSIZEH)
		GMFMissions:SetPoint("BOTTOMRIGHT",GMF,-25,35)
		GMFFollowers:SetPoint("BOTTOMLEFT",GMF,-35,65)
		GMFMissionsListScrollFrameScrollChild:ClearAllPoints()
		GMFMissionsListScrollFrameScrollChild:SetPoint("TOPLEFT",GMFMissionsListScrollFrame)
		GMFMissionsListScrollFrameScrollChild:SetPoint("BOTTOMRIGHT",GMFMissionsListScrollFrame)
		GMFFollowersListScrollFrameScrollChild:SetPoint("BOTTOMLEFT",GMFFollowersListScrollFrame,-35,35)
		GMF.MissionCompleteBackground:SetWidth(BIGSIZEW)
	else
		GCF:SetWidth(GMF:GetWidth())
--		GMF:ClearAllPoints()
--		GMF:SetPoint("TOPLEFT",GCF,"BOTTOMLEFT",0,-25)
--		GMF:SetPoint("TOPRIGHT",GCF,"BOTTOMRIGHT",0,-25)
	end
	GMF:ClearAllPoints()
	GMF:SetPoint("TOPLEFT",GCF,"BOTTOMLEFT",0,23)
	GMF:SetPoint("TOPRIGHT",GCF,"BOTTOMRIGHT",0,23)
end
---@function
-- Return bias color for follower and mission
-- @param #number bias bias as returned by blizzard interface [optional]
-- @param #string followerID
-- @param #number missionID
function addon:GetBiasColor(followerID,missionID,goodcolor)
	goodcolor=goodcolor or "White"
	local bias=followerID or 0
	if (missionID) then
		local rc,followerBias = pcall(G.GetFollowerBiasForMission,missionID,followerID)
		if (not rc) then
			return goodcolor
		else
			bias=followerBias
		end
	end
	if not tonumber(bias) then return "Yellow" end
	if (bias==-1) then
		return "Red"
	elseif (bias < 0) then
		return "Orange"
	end
	return goodcolor
end
function addon:RenderFollowerButton(frame,followerID,missionID)
	if (not frame) then return end
	if (frame.Threats) then
		for i=1,#frame.Threats do
			if (frame.Threats[i]) then frame.Threats[i]:Hide() end
		end
		frame.NotFull:Hide()
	end
	if (not followerID) then
		if (frame.Name) then
			frame.PortraitFrame.Empty:Show()
			frame.Name:Hide()
			frame.Class:Hide()
			frame.Status:Hide()
		else
			frame.PortraitFrame.Empty:Hide()
			frame.PortraitFrame.Portrait:Show()
			frame.PortraitFrame.LevelBorder:SetAtlas("GarrMission_PortraitRing_iLvlBorder");
			frame.PortraitFrame.LevelBorder:SetWidth(70);
			frame.PortraitFrame.Level:SetText(MISSING)
			frame.PortraitFrame.Level:SetTextColor(1,0,0,0.7)
		end
		frame.PortraitFrame.LevelBorder:SetAtlas("GarrMission_PortraitRing_LevelBorder");
		frame.PortraitFrame.LevelBorder:SetWidth(58);
		GarrisonFollowerPortrait_Set(frame.PortraitFrame.Portrait)
		frame.PortraitFrame.PortraitRingQuality:SetVertexColor(C.Silver());
		frame.PortraitFrame.LevelBorder:SetVertexColor(C.Silver());
		frame.info=nil
		return
	end
	frame.PortraitFrame.Level:SetTextColor(1,1,1,1)
	frame.PortraitFrame.Portrait:Show()
	local info=self:GetFollowerData(followerID)
	if (not info) then return end
	frame.info=info
	frame.missionID=missionID
	if (frame.Name) then
		frame.Name:Show()
		frame.Name:SetText(info.name);
		local color=missionID and self:GetBiasColor(followerID,missionID,"White") or "Yellow"
		frame.Name:SetTextColor(C[color]())
		frame.Status:SetText(self:GetFollowerStatus(followerID,true,true))
		frame.Status:Show()
	end
	if (frame.Class) then
		frame.Class:Show();
		frame.Class:SetAtlas(info.classAtlas);
	end
	frame.PortraitFrame.Empty:Hide();

	local showItemLevel;
	if (info.level == GMF.followerMaxLevel ) then
		frame.PortraitFrame.LevelBorder:SetAtlas("GarrMission_PortraitRing_iLvlBorder");
		frame.PortraitFrame.LevelBorder:SetWidth(70);
		showItemLevel = true;
	else
		frame.PortraitFrame.LevelBorder:SetAtlas("GarrMission_PortraitRing_LevelBorder");
		frame.PortraitFrame.LevelBorder:SetWidth(58);
		showItemLevel = false;
	end
	GarrisonMissionFrame_SetFollowerPortrait(frame.PortraitFrame, info, showItemLevel);
	-- Counters icon
	if (frame.Name) then
		if (missionID and not GMF.MissionTab.MissionList.showInProgress) then
			local tohide=1
			local missionCounters=counters[missionID]
			local index=counterFollowerIndex[missionID][followerID]
			for i=1,#index do
				local k=index[i]
				local t=frame.Threats[i]
				local tx=missionCounters[k].icon
				t.Icon:SetTexture(tx)
				local color=self:GetBiasColor(missionCounters[k].bias,nil,"Green")
				t.Border:SetVertexColor(C[color]())
				t:Show()
				tohide=i+1
			end
		else
			frame.Status:Hide()
		end
	end
end
-- pseudo static
local scale=0.9
function addon:BuildFollowersButtons(button,bg,limit)
	if (bg.Party) then return end
	bg.Party={}
	for numMembers=1,3 do
		local f=CreateFrame("Button",nil,bg,bigscreen and "GarrisonCommanderMissionPageFollowerTemplate" or "GarrisonCommanderMissionPageFollowerTemplateSmall" )
		if (numMembers==1) then
			f:SetPoint("BOTTOMLEFT",button.Rewards[1],"BOTTOMRIGHT",10,0)
		else
			if (bigscreen) then
				f:SetPoint("LEFT",bg.Party[numMembers-1],"RIGHT",10,0)
			else
				f:SetPoint("LEFT",bg.Party[numMembers-1],"LEFT",65,0)
			end
		end
		tinsert(bg.Party,f)
		f:EnableMouse(true)
		f:SetScript("OnEnter",GarrisonMissionPageFollowerFrame_OnEnter)
		f:SetScript("OnLeave",GarrisonMissionPageFollowerFrame_OnLeave)
		f:RegisterForClicks("AnyUp")
		f:SetScript("OnClick",function(...) self:OnClick_PartyMember(...) end)
		if (bigscreen) then
			for numThreats=1,4 do
				local threatFrame =f.Threats[numThreats];
				if ( not threatFrame ) then
					threatFrame = CreateFrame("Frame", nil, f, "GarrisonAbilityCounterTemplate");
					threatFrame:SetPoint("LEFT", f.Threats[numThreats - 1], "RIGHT", 10, 0);
					tinsert(f.Threats, threatFrame);
				end
				threatFrame:Hide()
			end
		end
	end
	for i=1,3 do bg.Party[i]:SetScale(0.9) end
	-- Making room for both GC and MP
	if (button.Expire) then
		button.Expire:ClearAllPoints()
		button.Expire:SetPoint("TOPRIGHT")
	end
	if (button.Threats and button.Threats[1]) then
		button.Threats[1]:ClearAllPoints()
		button.Threats[1]:SetPoint("TOPLEFT",165,0)
	end
end
function addon:RenderExtraButton(button,numRewards)
	local panel=button.gcINDICATOR
	local missionInfo=button.info
	local missionID=missionInfo.missionID
	panel.missionID=missionID
	local mission=missionInfo
	if not mission then print "not yet updated missions" return end -- something went wrong while refreshing
	if (not bigscreen) then
		local index=mission.numFollowers+numRewards-3
		local position=(index * -65) - 130
		button.gcPANEL.Party[1]:ClearAllPoints()
		button.gcPANEL.Party[1]:SetPoint("BOTTOMLEFT",button.Rewards[1],"BOTTOMLEFT", position,0)
	end
	if (GMF.MissionTab.MissionList.showInProgress) then
		local perc=select(4,G.GetPartyMissionInfo(missionID))
		panel.Percent:SetFormattedText(GARRISON_MISSION_PERCENT_CHANCE,perc)
		panel.Percent:SetJustifyV("CENTER")
		panel.Age:Hide()
		panel.Percent:SetTextColor(self:GetDifficultyColors(perc))
		for i=1,3 do
			local frame=button.gcPANEL.Party[i]
			if (missionInfo.followers[i]) then
				self:RenderFollowerButton(frame,missionInfo.followers[i],missionID)
				frame:Show()
			else
				frame:Hide()
			end
		end
		return
	else
		panel.Percent:SetJustifyV("BOTTOM")
	end
	local party=parties[missionID]
	if (#party.members==0) then
		local mission=self:GetMissionData(missionID) -- matchmaker and fillcounters need our enriched mission
		self:FillCounters(missionID,mission)
		self:MatchMaker(missionID,mission,party)
	end
	local perc=party.perc
	local age=tonumber(dbcache.seen[missionID])
	local notFull=false
	for i=1,3 do
		local frame=button.gcPANEL.Party[i]
		if (i>mission.numFollowers) then
			frame:Hide()
		else
			if (party.members[i]) then
				self:RenderFollowerButton(frame,party.members[i],missionID)
				if (bigscreen) then frame.NotFull:Hide() end
			else
				self:RenderFollowerButton(frame,false)
				if (bigscreen) then frame.NotFull:Show() end
			end
			frame:Show()
		end
	end
	panel=button.gcINDICATOR
	panel.Percent:SetFormattedText(GARRISON_MISSION_PERCENT_CHANCE,perc)
	panel.Percent:SetTextColor(self:GetDifficultyColors(perc))
	panel.Percent:SetWidth(80)
	panel.Percent:SetJustifyH("RIGHT")
	if (age) then
		local expire=ns.wowhead[missionID]
		if (expire==9999999) then
			panel.Age:SetText("Expires: Far far away")
			panel.Age:SetTextColor(C.White())
		elseif (expire==0) then
			panel.Age:SetText("Expires: " .. UNKNOWN)
			panel.Age:SetTextColor(C.White())
		else
			local age=(age+(expire*2)-time())/60
			if age < 0 then age=0 end
			local hours=(floor((age/60)/6)+1)*6
			local q=self:GetDifficultyColor(hours+20,true)
			panel.Age:SetFormattedText("Expires in less than %d hr",hours)
			panel.Age:SetTextColor(q.r,q.g,q.b)
		end
	else
		panel.Age:SetText(UNKNOWN)
	end
	panel.Age:Show()
	panel.Percent:Show()
end
function addon:CheckExpire(missionID)
	local age=tonumber(dbcache.seen[missionID])
	local expire=ns.wowhead[missionID]
	print("Age",date("%m/%d/%y %H:%M:%S",age))
	print("Now",date("%m/%d/%y %H:%M:%S"))
	print("Expire",expire)
	print("Age+expire",date("%m/%d/%y %H:%M:%S",age+expire))
	print("Delta",age+expire-time())
end
function addon:BuildExtraButton(button)
	local bg=CreateFrame("Button",nil,button,"GarrisonCommanderMissionButton")
	local indicators=CreateFrame("Frame",nil,button,"GarrisonCommanderIndicators")
	indicators:SetPoint("LEFT",70,0)
	bg:SetPoint("RIGHT")
	bg.button=button
	bg:SetScript("OnEnter",function(this) GarrisonMissionButton_OnEnter(this.button) end)
	bg:SetScript("OnLeave",function() GameTooltip:FadeOut() end)
	bg:RegisterForClicks("AnyUp")
	bg:SetScript("OnClick",function(...) self:OnClick_GCMissionButton(...) end)
	button.gcPANEL=bg
	button.gcINDICATOR=indicators
	if (not bg.Party) then self:BuildFollowersButtons(button,bg,3) end
end
--function addon:GarrisonMissionButton_SetRewards(button,rewards,numrewards)
--end
do
	local menuFrame = CreateFrame("Frame", "GCFollowerDropDOwn", nil, "UIDropDownMenuTemplate")
	local func=function(...) addon:IgnoreFollower(...) end
	local func2=function(...) addon:UnignoreFollower(...) end
	local menu= {
	{ text="Follower", notClickable=true,notCheckable=true,isTitle=true },
	{ text=L["Ignore for this mission"],checked=false, func=func, arg1=0, arg2="none"},
--	{ text=L["Ignore for all missions"],checked=false, func=func, arg1=0, arg2="none"},
	{ text=L["Consider again"], notClickable=true,notCheckable=true,isTitle=true },
	}
	function addon:OnClick_PartyMember(frame,button,down,...)
		local followerID=frame.info and frame.info.followerID or nil
		local missionID=frame.missionID
		if (not followerID) then return end
		if (button=="LeftButton") then
			self:OpenFollowersTab()
			GMF.selectedFollower=followerID
			if (GMF.FollowerTab) then
				GarrisonFollowerPage_ShowFollower(GMF.FollowerTab,followerID)
			end
		else
			menu[1].text=frame.info.name
			menu[2].arg1=missionID
			menu[2].arg2=followerID
			--menu[3].arg2=followerID
			local i=3
			for k,r in pairs(dbcache.ignored[missionID]) do
				if (r) then
					i=i+1
					local v=menu[i] or {}
					v.text=self:GetFollowerData(k,'name')
					v.func=func2
					v.arg1=missionID
					v.arg2=k
					menu[i]=v
				else
					dbcache.ignored[missionID][k]=nil
				end
			end
			if (i>3) then
				i=i+1
				menu[i]={text=ALL,func=func2,arg1=missionID,arg2='all'}
			end
			for x=#menu,i+1,-1 do tremove(menu) end
			EasyMenu(menu,menuFrame,"cursor",0,0,"MENU",5)
		end

	end
end
function addon:IgnoreFollower(table,missionID,followerID,flag)
	if (missionID==0) then
		dbcache.totallyignored[followerID]=true
	else
		dbcache.ignored[missionID][followerID]=true
	end
	-- full ignore disabled for now
	dbcache.totallyignored[followerID]=nil
	self:RefreshMission(missionID)
end
function addon:UnignoreFollower(table,missionID,followerID,flag)
	if (followerID=='all') then
		wipe(dbcache.ignored[missionID])
	else
		dbcache.ignored[missionID][followerID]=nil
	end
	self:RefreshMission(missionID)
end
function addon:OpenFollowersTab()
	GarrisonMissionFrame_SelectTab(2)
end
function addon:OpenMissionsTab()
	GarrisonMissionFrame_SelectTab(1)
end
function addon:OnClick_GarrisonMissionFrame_MissionComplete_NextMissionButton(this,button)
	local frame = GMF.MissionComplete
	if (not frame:IsShown()) then
		self:Trigger("MSORT")
		self:RefreshFollowerStatus()
	end
end
function addon:OnClick_GarrisonMissionButton(tab,button)
	if (GMF.MissionTab.MissionList.showInProgress) then
		return
	end
--[===[@debug@
	xprint("Clicked GarrisonMissionButto")
--@end-debug@]===]
	if (tab.fromFollowerPage) then
		GarrisonMissionFrame_SelectTab(1)
		self:FillMissionPage(tab.info)
	else
--[===[@debug@
		xdump(tab.info)
--@end-debug@]===]
		self:FillMissionPage(tab.info)
	end
end
function addon:OnClick_GCMissionButton(frame,button)
	if (button=="RightButton") then
		self:HookedGarrisonMissionButton_SetRewards(frame:GetParent(),{},0)
	else
		frame.button:Click()
	end
end

function addon:HookedGarrisonMissionButton_SetRewards(button,rewards,numRewards)
	if GMF.MissionTab.MissionList.showInProgress and button.info.missionID==button.lastMissionID then collectgarbage("step",50) return end
	button.lastMissionID=button.info.missionID
	self:RenderButton(button,rewards,numRewards)
end
function addon:RenderButton(button,rewards,numRewards)
	if (not button or not button.Title) then
--[===[@debug@
		error(strconcat("Called on I dunno what ",tostring(button)," ", tostring(button:GetName())))
		return
--@end-debug@]===]
	end
	local missionID=button.info.missionID
	if (bigscreen) then
		local width=GMF.MissionTab.MissionList.showInProgress and BIGBUTTON or SMALLBUTTON
		button:SetWidth(width+600)
		button.Rewards[1]:SetPoint("RIGHT",button,"RIGHT",-500 - (GMM and 40 or 0),0)
	end
	if (not button.xp) then
		button.xp=button:CreateFontString(nil, "ARTWORK", "QuestMaprewardsFont")
		button.xp:SetPoint("TOPRIGHT",button.Rewards[1],"TOPRIGHT")
		button.xp:SetJustifyH("RIGHT")
	end
	button.MissionType:SetPoint("TOPLEFT",5,-2)
	button.xp:SetWidth(0)
	if (not GMF.MissionTab.MissionList.showInProgress) then
		button.xp:SetFormattedText("Xp: %d (approx)",self:GetMissionData(missionID,'globalXp'))
		button.xp:SetTextColor(self:GetDifficultyColors(self:GetMissionData(missionID,'totalXp')/3000*100))
		button.xp:Show()
	else
		button.xp:Hide()
	end
	--button.Title:SetText("123456789012345678901234567890123456789012345678901234567890") -- Used for design
	local offset= bigscreen and (numRewards *65) or (button.info.numFollowers+numRewards) *65
	local tw=button:GetWidth() - 165
	if (button.Title:GetWidth() + button.Summary:GetWidth() + button.xp:GetWidth() < (tw -offset) ) then
		button.Title:SetPoint("LEFT", 165, 5);
		button.Summary:ClearAllPoints();
		button.Summary:SetPoint("BOTTOMLEFT", button.Title, "BOTTOMRIGHT", 8, 0);
	else
		button.Title:SetPoint("LEFT", 165, 25);
		button.Title:SetWidth(tw - offset);
		button.Summary:ClearAllPoints();
		button.Summary:SetPoint("TOPLEFT", button.Title, "BOTTOMLEFT", 0, -4);
	end
	local threatIndex=1
	if (not GMF.MissionTab.MissionList.showInProgress) then
		if (not button.Threats) then -- I am a good guy. If MP present, I dont make my own threat indicator (Only MP <= 1.8)
			if (not button.Env) then
				button.Env=CreateFrame("Frame",nil,button,"GarrisonAbilityCounterTemplate")
				button.Env:SetWidth(20)
				button.Env:SetHeight(20)
				button.Env:SetPoint("BOTTOMLEFT",button,165,8)
				button.GcThreats={}
			end
			local slots=self:GetMissionData(missionID,'slots')
			if (not GMF.MissionTab.MissionList.showInProgress) then
				button.Env:Show()
				for i=1,#slots do
					local slot=slots[i]
					if (slot.name==TYPE) then
						button.Env.Icon:SetTexture(slot.icon)
						self:SetThreatColor(button.Env,missionID)
						button.Env.info=self.db.global.types[slot.key]
						button.Env:SetScript("OnEnter",function(...) addon:ClonedGarrisonMissionMechanic_OnEnter(missionID,...) end)
						button.Env:SetScript("OnLeave",function() GameTooltip:Hide() end)
					else
						local th=button.GcThreats[threatIndex]
						if (not th) then
							th=CreateFrame("Frame",nil,button,"GarrisonAbilityCounterTemplate")
							th:SetWidth(20)
							th:SetHeight(20)
							th:SetPoint("BOTTOMLEFT",button,165 + 35 * threatIndex,8)
							button.GcThreats[threatIndex]=th
						end
						th.info=slot
						threatIndex=threatIndex+1
						th.Icon:SetTexture(slot.icon)
						self:SetThreatColor(th,missionID)
						th:Show()
						th:SetScript("OnEnter",function(...) addon:ClonedGarrisonMissionMechanic_OnEnter(missionID,...) end)
						th:SetScript("OnLeave",function() GameTooltip:Hide() end)
					end
				end
			else
				button.Env:Hide()
			end
		end
		if (numRewards > 0) then
			local index=1
			for id,reward in pairs(rewards) do
				local Reward = button.Rewards[index];
				Reward.Quantity:SetTextColor(C.Yellow())
				if (reward.followerXP) then
					Reward.Quantity:SetText(reward.followerXP)
					Reward.Quantity:Show()
				elseif (reward.currencyID==0) then
					Reward.Quantity:SetFormattedText("%d",reward.quantity/10000)
					Reward.Quantity:Show()
				elseif (reward.itemID and reward.itemID==120205) then
					Reward.Quantity:SetFormattedText("%d",self:GetMissionData(missionID,'xp') or 1)
					Reward.Quantity:Show()
				elseif (reward.itemID and reward.quantity==1) then
					local _,_,q,i=GetItemInfo(reward.itemID)
					Reward.Quantity:SetText(i)
					local c=ITEM_QUALITY_COLORS[q]
					if (not c) then
						Reward.Quantity:SetTextColor(1,1,1)
					else
						Reward.Quantity:SetTextColor(c.r,c.g,c.b)
					end
					Reward.Quantity:Show()
				end
				index=index+1
			end
		end
	else
		if (button.Env) then button.Env:Hide() end
	end
	if (button.GcThreats) then
		for i=threatIndex,#button.GcThreats do
			button.GcThreats[i]:Hide()
		end
	end
	if (button.fromFollowerPage) then
		return
	end
	if (not button.gcPANEL) then
		self:BuildExtraButton(button)
	end
	self:RenderExtraButton(button,numRewards)
end

-- Courtesy of Motig
-- Concept and interface reused with permission
-- Mission building rewritten from scratch
local GMC_G = {}
--GMC_G.frame = CreateFrame('FRAME')
local aMissions={}

function addon:GMCCreateMissionList(workList)
	--First get rid of unwanted rewards and missions that are too long
	local settings=self.privatedb.profile.missionControl
	local ar=settings.allowedRewards
	wipe(workList)
	for missionID,mission in pairs(cache.missions) do
		local discarded=false
		repeat
			if (mission.durationSeconds > settings.maxDuration * 3600 or mission.durationSeconds <  settings.minDuration * 3600) then
				xprint(missionID,"discarded due to len",mission.durationSeconds /3600)
				break
			end -- Mission too long, out of here
			if (mission.isRare and settings.skipRare) then
				xprint(missionID,"discarded due to rarity")
				break
			end
			for k,v in pairs(ar) do
				if (not v) then
					if (mission[k] and mission[k]~=0) then -- we have a forbidden reward
						discarded=true
						break
					end
				end
			end
			if (not discarded) then
				tinsert(workList,missionID)
			end
		until true
	end
	local function msort(i1,i2)
		local m1=addon:GetMissionData(i1)
		local m2=addon:GetMissionData(i2)
		for i=1,#GMC.settings.itemPrio do
			local criterium=GMC.settings.itemPrio[i]
			if (criterium) then
				if (m1[criterium] ~= m2[criterium]) then
					return m1[criterium] > m2[criterium]
				end
			end
		end
		if (parties[m1.missionID].perc and parties[m2.missionID].perc) then
			return parties[m1.missionID].perc > parties[m2.missionID].perc
		end
		return m1.level > m2.level
	end
	table.sort(workList,msort)
	--[===[@debug@
	xprint("Sorted list")
	local x=new()
	for i=1,#workList do
		local mission=self:GetMissionData(workList[i])
		local t=new()
		for i=1,#GMC.settings.itemPrio do
			local criterium=GMC.settings.itemPrio[i]
			tinsert(t,format("%s: %d",criterium,mission[criterium]))
		end
		tinsert(x,mission.name .." "..  strjoin("\t",unpack(t)) .. " Success" ..  tostring(parties[mission.missionID].perc))
		del(t)
	end
	local scroll=self:GetScroller("Sorted missions")
	self:cutePrint(scroll,x)
	del(x)
	--@end-debug@]===]

end
local factory={} --#factory
do
	local nonce=0
	local GetTime=GetTime
	function factory:Slider(father,min,max,current,message)
		local name=tostring(self)..GetTime()*1000 ..nonce
		nonce=nonce+1
		local sl = CreateFrame('Slider',name, father, 'OptionsSliderTemplate')
		sl:SetWidth(128)
		sl:SetHeight(20)
		sl:SetOrientation('HORIZONTAL')
		sl:SetMinMaxValues(min, max)
		sl:SetValue(current)
		sl:SetValueStep(1)
		sl.Low=_G[name ..'Low']
		sl.Low:SetText(min)
		sl.High=_G[name .. 'High']
		sl.High:SetText(max)
		sl.Text=_G[name.. 'Text']
		sl.Text:SetText(message)
		sl.OnValueChanged=function(this,value)
			if (not this.unrounded) then
				value = math.floor(value)
			end
			if (this.isPercent) then
				this.Text:SetFormattedText('%d%%',value)
			else
				this.Text:SetText(value)
			end
			return value
		end
		sl:SetScript("OnValueChanged",sl.OnValueChanged)
		return sl
	end
	function factory:Checkbox(father,current,message)
		local name=tostring(self)..GetTime()*1000 ..nonce
		nonce=nonce+1
		local ck=CreateFrame("CheckButton",name,father,"ChatConfigCheckButtonTemplate")
		ck.Text=_G[name..'Text']
		ck.Text:SetText(message)
		ck:SetChecked(current)
		return ck
	end
end
--- This routine can be called both as coroutin and as a standard one
-- In standard version, delay between group building and submitting is done via a self schedule
--@param #integer missionID Optional, to run a single mission
--@param #bool start Optional, tells that follower already are on mission and that we need just to start it
function addon:GMCRunMission(missionID,start)
	xprint("Asked to start mission",missionID)
	if (start) then
		G.StartMission(missionID)
		PlaySound("UI_Garrison_CommandTable_MissionStart")
		return
	end
	for i=1,#GMC.ml.Parties do
		local party=GMC.ml.Parties[i]
		xprint("Checking",party.missionID)
		if (missionID and party.missionID==missionID or not missionID) then
			GMC.ml.widget:RemoveChild(party.missionID)
			GMC.ml.widget:DoLayout()
			if (party.full) then
				for j=1,#party.members do
					G.AddFollowerToMission(party.missionID, party.members[j])
				end
				if (not missionID) then
					coroutine.yield(true)
					G.StartMission(party.missionID)
					PlaySound("UI_Garrison_CommandTable_MissionStart")
					coroutine.yield(true)
				else
					self:ScheduleTimer("GMCRunMission",0.25,party.missionID,true)
				end
			end
		end
	end
end
do
	local timeElapsed=0
	local currentMission=0
	local x=0
	function addon:GMCCalculateMissions(this,elapsed)
		db.news.MissionControl=true
		timeElapsed = timeElapsed + elapsed
		if (#aMissions == 0 ) then
			if timeElapsed >= 1 then
				currentMission=0
				x=0
				self:Unhook(this,"OnUpdate")
				GMC.ml.widget:SetTitle(READY)
				GMC.ml.widget:SetTitleColor(C.Green())
				this:Enable()
				if (#GMC.ml.Parties>0) then
					GMC.runButton:Enable()
				end
			end
			return
		end
		if (timeElapsed >=0.) then
			currentMission=currentMission+1
			if (currentMission > #aMissions) then
				wipe(aMissions)
				currentMission=0
				x=0
				timeElapsed=0.2
			else
				GMC.ml.widget:SetFormattedTitle("Processing mission %d of %d",currentMission,#aMissions)
				local missionID=aMissions[currentMission]
				if (dbg) then print(C("Processing ","Red"),missionID) end
				local party={members={},perc=0}
				local mission=self:GetMissionData(missionID)
				if (not mission ) then
					if dbg then print ("NO data for",missionID) end
					return
				end
				--function addon:MatchMaker(missionID,mission,party,fromGMC)
				self:MatchMaker(missionID,mission,party,true) -- I need my mission data
				local minimumChance=0
				if (GMC.settings.useOneChance) then
					minimumChance=GMC.settings.minimumChance
				end
				for prio,enabled in pairs(GMC.settings.allowedRewards) do
					if (dbg) then print("Chance from ",prio,"=",GMC.settings.rewardChance[prio],enabled) end
					if (enabled and (tonumber(self:GetMissionData(missionID,prio)) or 0) >0) then
						minimumChance=math.max(GMC.settings.rewardChance[prio],minimumChance)
					end
				end
				if (dbg) then print ("Missionid",missionID,"Chance",minimumChance,"chance",party.perc) end
				if ( party.full and party.perc >= minimumChance) then
					if (dbg) then print("Preparing button for",missionID) end
					local mb=AceGUI:Create("GMCMissionButton")
					for i=1,#party.members do
						GMCUsedFollowers[party.members[i]]=true
					end
					party.missionID=missionID
					tinsert(GMC.ml.Parties,party)
					GMC.ml.widget:PushChild(mb,missionID)
					mb:SetFullWidth(true)
					mb:SetMission(mission)
					mb:SetCallback("OnClick",function(...)
						addon:GMCRunMission(missionID)
						GMC.ml.widget:RemoveChild(missionID)
					end
					)
				end
				timeElapsed=0
			end
		end
	end
end

function addon:GMC_OnClick_Run(this,button)
	this:Disable()
	do
	local elapsed=0
	local co=coroutine.wrap(self.GMCRunMission)
	self:RawHookScript(GMC.runButton,'OnUpdate',function(this,ts)
		elapsed=elapsed+ts
		if (elapsed>0.25) then
			elapsed=0
			local rc=co(self)
			if (not rc) then
				self:Unhook(GMC.runButton,'OnUpdate')
			end
		end
	end
	)
	end
end
function addon:GMC_OnClick_Start(this,button)
	xprint(C("-------------------------------------------------","Yellow"))
	this:Disable()
	GMC.ml.widget:ClearChildren()
	addon:GMCCreateMissionList(aMissions)
	wipe(GMCUsedFollowers)
	wipe(GMC.ml.Parties)
	self:RefreshFollowerStatus()
	if (self:GetTotFollowers(AVAILABLE) == 0) then
		self:Popup("All followers are busy",10)
		this:Enable()
		return
	end
	if (#aMissions>0) then
		GMC.ml.widget:SetFormattedTitle(L["Processing mission %d of %d"],1,#aMissions)
	else
		GMC.ml.widget:SetTitle("No mission matches your criteria")
		GMC.ml.widget:SetTitleColor(C.Red())
	end
	self:RawHookScript(GMC.startButton,'OnUpdate',"GMCCalculateMissions")

end
local chestTexture
function addon:GMCBuildPanel()
	--PanelTemplates_SetNumTabs(GarrisonMissionFrame, 4)
	--PanelTemplates_UpdateTabs(GarrisonMissionFrame)
	chestTexture='GarrMission-'..UnitFactionGroup('player').. 'Chest'
	GMC = CreateFrame('FRAME', 'GMCOptions', GarrisonMissionFrame)
	GMC.settings=dbcache.missionControl
	GMC:SetPoint('CENTER')
	GMC:SetSize(GarrisonMissionFrame:GetWidth(), GarrisonMissionFrame:GetHeight())
	GMC:Hide()
	local chance=self:GMCBuildChance()
	local duration=self:GMCBuildDuration()
	local rewards=self:GMCBuildRewards()
	local priorities=self:GMCBuildPriorities()
	local list=self:GMCBuildMissionList()
	duration:SetPoint("TOPLEFT",0,-50)
	chance:SetPoint("TOPLEFT",duration,"TOPRIGHT",bigscreen and 50 or 10,0)
	priorities:SetPoint("TOPLEFT",duration,"BOTTOMLEFT",25,-40)
	rewards:SetPoint("TOPLEFT",priorities,"TOPRIGHT",bigscreen and 50 or 15,0)
	list:SetPoint("TOPLEFT",chance,"TOPRIGHT",10,0)
	list:SetPoint("BOTTOMRIGHT",GMF,"BOTTOMRIGHT",-25,25)
	GMC.skipRare=factory:Checkbox(GMC,GMC.settings.skipRare,L["Ignore rare missions"])
	GMC.skipRare:SetPoint("TOPLEFT",priorities,"BOTTOMLEFT",0,-10)
	GMC.startButton = CreateFrame('BUTTON',nil,  list.frame, 'GameMenuButtonTemplate')
	GMC.startButton:SetText('Calculate')
	GMC.startButton:SetWidth(148)
	GMC.startButton:SetPoint('TOPLEFT',15,25)
	GMC.startButton:SetScript('OnClick', function(this,button) self:GMC_OnClick_Start(this,button) end)
	GMC.startButton:SetScript('OnEnter', function() GameTooltip:SetOwner(GMC.startButton, 'ANCHOR_TOPRIGHT') GameTooltip:AddLine('Assign your followers to missions.') GameTooltip:Show() end)
	GMC.startButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
	GMC.runButton = CreateFrame('BUTTON', nil,list.frame, 'GameMenuButtonTemplate')
	GMC.runButton:SetText('Send all mission at once')
	GMC.runButton:SetScript('OnEnter', function()
		GameTooltip:SetOwner(GMC.runButton, 'ANCHOR_TOPRIGHT')
		GameTooltip:AddLine('Submit all yopur mission at once. No question asked.')
		GameTooltip:AddLine('You can also send mission one by one clicking on each button.')
		GameTooltip:Show()
	end)
	GMC.runButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
	GMC.runButton:SetWidth(148)
	GMC.runButton:SetPoint('TOPRIGHT',-15,25)
	GMC.runButton:SetScript('OnClick',function(this,button) self:GMC_OnClick_Run(this,button) end)
	GMC.runButton:Disable()
	GMC.Credits=GMC:CreateFontString(nil,"ARTWORK","ReputationDetailFont")
	GMC.Credits:SetWidth(0)
	GMC.Credits:SetFormattedText("Original concept and interface by %s",C("Motig","Red") )
	GMC.Credits:SetPoint("BOTTOMLEFT",25,25)
end
function addon:GMCRewardRefresh()
	local single=GMC.settings.useOneChance
	local ref
	for i=1,#GMC.ignoreFrames do
		local frame=GMC.ignoreFrames[i]
		local allowed=GMC.settings.allowedRewards[frame.key]
		frame.icon:SetDesaturated(not allowed)
		local a1,o,a2,x,y=frame:GetPoint(1)
		if (not single) then
			frame.chest:Show()
			frame.slider:Show()
			frame:SetPoint(a1,o,a2,0,y)
		else
			frame.chest:Hide()
			frame.slider:Hide()
			frame:SetPoint(a1,o,a2,100,y)
		end
		ref=frame
	end
	if (single) then
		GMC.itf2:SetPoint('TOPLEFT',ref,'BOTTOMLEFT', -110, -15)
		GMC.cp:SetDesaturated(false)
		GMC.ct:SetTextColor(C.Green())
	else
		GMC.itf2:SetPoint('TOPLEFT',ref,'BOTTOMLEFT', 10, -15)
		GMC.cp:SetDesaturated(true)
		GMC.ct:SetTextColor(C.Silver())
	end
end
function addon:GMCBuildChance()
	_G['GMC']=GMC
	--Chance
	GMC.cf = CreateFrame('FRAME', nil, GMC)
	GMC.cf:SetSize(256, 150)

	GMC.cp = GMC.cf:CreateTexture(nil, 'BACKGROUND')
	GMC.cp:SetTexture('Interface\\Garrison\\GarrisonMissionUI2.blp')
	GMC.cp:SetAtlas(chestTexture)
	GMC.cp:SetSize((209-(209*0.25))*0.60, (155-(155*0.25))*0.60)
	GMC.cp:SetPoint('CENTER', 0, 20)

	GMC.cc = GMC.cf:CreateFontString()
	GMC.cc:SetFontObject('GameFontNormalHuge')
	GMC.cc:SetText('Success Chance')
	GMC.cc:SetPoint('TOP', 0, 0)
	GMC.cc:SetTextColor(1, 1, 1)

	GMC.ct = GMC.cf:CreateFontString()
	GMC.ct:SetFontObject('ZoneTextFont')
	GMC.ct:SetFormattedText('%d%%',GMC.settings.minimumChance)
	GMC.ct:SetPoint('TOP', 0, -40)
	GMC.ct:SetTextColor(0, 1, 0)

	GMC.cs = factory:Slider(GMC.cf,0,100,GMC.settings.minimumChance,'Minumum chance to start a mission')
	GMC.cs:SetPoint('BOTTOM', 10, 0)
	GMC.cs:SetScript('OnValueChanged', function(self, value)
			local value = math.floor(value)
			GMC.ct:SetText(value..'%')
			GMC.settings.minimumChance = value
	end)
	GMC.cs:SetValue(GMC.settings.minimumChance)
	GMC.ck=factory:Checkbox(GMC.cs,GMC.settings.useOneChance,"Use this percentage for all missions")
	GMC.ck.tooltip="Unchecking this will allow you to set specific success chance for each reward type"
	GMC.ck:SetPoint("TOPLEFT",GMC.cs,"BOTTOMLEFT",-60,-10)
	GMC.ck:SetScript("OnClick",function(this)
		GMC.settings.useOneChance=this:GetChecked()
		addon:GMCRewardRefresh()
	end)
	return GMC.cf
end
local function timeslidechange(this,value)
	local value = math.floor(value)
	if (this.max) then
		GMC.settings.maxDuration = max(value,GMC.settings.minDuration)
		if (value~=GMC.settings.maxDuration) then this:SetValue(GMC.settings.maxDuration) end
	else
		GMC.settings.minDuration = min(value,GMC.settings.maxDuration)
		if (value~=GMC.settings.minDuration) then this:SetValue(GMC.settings.minDuration) end
	end
	local c = 1-(value*(1/24))
	if c < 0.3 then c = 0.3 end
	GMC.mt:SetTextColor(1, c, c)
	GMC.mt:SetFormattedText("%d-%dh",GMC.settings.minDuration,GMC.settings.maxDuration)
end
function addon:GMCBuildDuration()
	-- Duration
	GMC.tf = CreateFrame('FRAME', nil, GMC)
	GMC.tf:SetSize(256, 180)
	GMC.tf:SetPoint('LEFT', 80, 120)

	GMC.bg = GMC.tf:CreateTexture(nil, 'BACKGROUND')
	GMC.bg:SetTexture('Interface\\Timer\\Challenges-Logo.blp')
	GMC.bg:SetSize(100, 100)
	GMC.bg:SetPoint('CENTER', 0, 0)
	GMC.bg:SetBlendMode('ADD')

	GMC.tcf = GMC.tf:CreateTexture(nil, 'BACKGROUND')
	--bb:SetTexture('Interface\\Timer\\Challenges-Logo.blp')
	--bb:SetTexture('dungeons\\textures\\devices\\mm_clockface_01.blp')
	GMC.tcf:SetTexture('World\\Dungeon\\Challenge\\clockRunes.blp')
	GMC.tcf:SetSize(110, 110)
	GMC.tcf:SetPoint('CENTER', 0, 0)
	GMC.tcf:SetBlendMode('ADD')

	GMC.mdt = GMC.tf:CreateFontString()
	GMC.mdt:SetFontObject('GameFontNormalHuge')
	GMC.mdt:SetText('Mission Duration')
	GMC.mdt:SetPoint('TOP', 0, 0)
	GMC.mdt:SetTextColor(1, 1, 1)

	GMC.mt = GMC.tf:CreateFontString()
	GMC.mt:SetFontObject('ZoneTextFont')
	GMC.mt:SetFormattedText('%d-%dh',GMC.settings.minDuration,GMC.settings.maxDuration)
	GMC.mt:SetPoint('CENTER', 0, 0)
	GMC.mt:SetTextColor(1, 1, 1)

	GMC.ms1 = factory:Slider(GMC.tf,0,24,GMC.settings.minDuration,'Minimum mission duration.')
	GMC.ms2 = factory:Slider(GMC.tf,0,24,GMC.settings.maxDuration,'Maximum mission duration.')
	GMC.ms1:SetPoint('BOTTOM', 0, 0)
	GMC.ms2:SetPoint('TOP', GMC.ms1,"BOTTOM",0, -25)
	GMC.ms2.max=true
	GMC.ms1:SetScript('OnValueChanged', timeslidechange)
	GMC.ms2:SetScript('OnValueChanged', timeslidechange)
	timeslidechange(GMC.ms1,GMC.settings.minDuration)
	timeslidechange(GMC.ms2,GMC.settings.maxDuration)
	return GMC.tf
end
function addon:GMCBuildRewards()
	--Allowed rewards
	GMC.aif = CreateFrame('FRAME', nil, GMC)
	GMC.aif:SetPoint('CENTER', 0, 120)

	GMC.itf = GMC.aif:CreateFontString()
	GMC.itf:SetFontObject('GameFontNormalHuge')
	GMC.itf:SetText('Allowed Rewards')
	GMC.itf:SetPoint('TOP', 0, -10)
	GMC.itf:SetTextColor(1, 1, 1)

	GMC.itf2 = GMC.aif:CreateFontString()
	GMC.itf2:SetFontObject('GameFontHighlight')
	GMC.itf2:SetText('Click to enable/disable a reward.')
	GMC.itf2:SetTextColor(1, 1, 1)


	local t = {
		{t = 'Enable/Disable money rewards.', i = 'Interface\\Icons\\inv_misc_coin_01', key = 'gold'},
		{t = 'Enable/Disable other currency awards. (Resources/Seals)', i= 'Interface\\Icons\\inv_garrison_resource', key = 'resources'},
		{t = 'Enable/Disable Follower XP Bonus rewards.', i = 'Interface\\Icons\\XPBonus_Icon', key = 'xpBonus'},
		{t = 'Enable/Disable follower equip enhancement.', i = 'Interface\\ICONS\\Garrison_ArmorUpgrade', key = 'followerUpgrade'},
		{t = 'Enable/Disable item tokens.', i = "Interface\\ICONS\\INV_Bracer_Cloth_Reputation_C_01", key = 'itemLevel'}
	}
	local scale=1.1
	GMC.ignoreFrames = {}
	local ref
	local h=37 -- itemButtonTemplate standard size
	local gap=5
	for i = 1, #t do
			local frame = CreateFrame('BUTTON', nil, GMC.aif, 'ItemButtonTemplate')
			frame:SetScale(scale)
			frame:SetPoint('TOPLEFT', 0,(i) * (-h -gap) * scale)
			frame.icon:SetTexture(t[i].i)
			frame.key=t[i].key
			frame.tooltip=t[i].t
			local allowed=GMC.settings.allowedRewards[frame.key]
			local chance=GMC.settings.rewardChance[frame.key]
			-- Need to resave them asap in order to populate the array for future scans
			GMC.settings.allowedRewards[frame.key]=allowed
			GMC.settings.rewardChance[frame.key]=chance
			frame.slider=factory:Slider(frame,0,100,chance or 100,chance or 100)
			frame.slider:SetWidth(128)
			frame.slider:SetPoint('BOTTOMLEFT',60,0)
			frame.slider.Text:SetFontObject('NumberFont_Outline_Med')
			frame.slider.Text:SetTextColor(C.Green())
			frame.slider.isPercent=true
			frame.slider:SetScript("OnValueChanged",function(this,value)
				GMC.settings.rewardChance[this:GetParent().key]=this:OnValueChanged(value)
				end
			)
			frame.chest = frame:CreateTexture(nil, 'BACKGROUND')
			frame.chest:SetTexture('Interface\\Garrison\\GarrisonMissionUI2.blp')
			frame.chest:SetAtlas(chestTexture)
			frame.chest:SetSize((209-(209*0.25))*0.30, (155-(155*0.25)) * 0.30)
			frame.chest:SetPoint('CENTER',frame.slider, 0, 25)
			frame:SetScript('OnClick', function(this)
				local allowed=  this.icon:IsDesaturated() -- ID it was desaturated, I want it allowed, now
				GMC.settings.allowedRewards[this.key] = allowed
				addon:GMCRewardRefresh()
			end)
			frame:SetScript('OnEnter', function(this)
				GameTooltip:SetOwner(this, 'ANCHOR_BOTTOMRIGHT')
				GameTooltip:AddLine(this.tooltip);
				GameTooltip:Show()
			end)

			frame:SetScript('OnLeave', function() GameTooltip:Hide() end)
			GMC.ignoreFrames[i] = frame
			ref=frame
	end
	self:GMCRewardRefresh()
	GMC.aif:SetSize(256, (scale*h+gap) * #t)
	GMC.itf2:SetPoint('TOPLEFT',ref,'BOTTOMLEFT', 5, -15)
	return GMC.aif
end

local addPriorityRule,prioRefresh,removePriorityRule,prioMenu,prioTitles,prioCheck,prioVoices
do
-- 1 = item, 2 = folitem, 3 = exp, 4 = money, 5 = resource
	prioTitles={
		itemLevel="Gear Items",
		followerUpgrade="Upgrade Items",
		xpBonus="Follower XP Bonus",
		gold="Gold Reward",
		resources="Resource Rewards"
	}
	prioVoices=0
	for _ in pairs(prioTitles) do prioVoices=prioVoices+1 end
	prioMenu={}

	---@function [parent=#GMC] prioRefresh
	function prioRefresh()
		for i=1,prioVoices do
			local group=GMC.prioFrames[i]
			local code=GMC.settings.itemPrio[i]
			if (not code) then
				group.text:Hide()
				group.xbutton:Hide()
				group.nr:Hide()
			else
				group.text:Show()
				group.text:SetText(prioTitles[code])
				group.xbutton:Show()
				group.nr:Show()
			end
		end
		GMC.abutton:Hide()
		for i=1,prioVoices do
			local group=GMC.prioFrames[i]
			if (not group.text:IsShown()) then
				group.nr:Show()
				GMC.abutton:SetPoint("TOPLEFT",group.text)
				GMC.abutton:Show()
				break
			end
		end
	end
	---@function [parent=#GMC] addPriorityRule
	function addPriorityRule(this,key)
		tinsert(GMC.settings.itemPrio,key)
		prioRefresh()
	end
	---@function [parent=#GMC] removePriorityRule
	function removePriorityRule(index)
		tremove(GMC.settings.itemPrio,index)
		prioRefresh()
	end

end
_G.XPRIO=prioRefresh
function addon:GMCBuildPriorities()
	--Prio
	GMC.pf = CreateFrame('FRAME', nil, GMC)
	GMC.pf:SetSize(256, 240)

	GMC.pft = GMC.pf:CreateFontString()
	GMC.pft:SetFontObject('GameFontNormalHuge')
	GMC.pft:SetText('Item Priority')
	GMC.pft:SetPoint('TOP', 0, -10)
	GMC.pft:SetTextColor(1, 1, 1)

	GMC.pft2 = GMC.pf:CreateFontString()
	GMC.pft2:SetFontObject('GameFontNormal')
	GMC.pft2:SetText('Prioritize missions with certain a reward.')
	GMC.pft2:SetPoint('BOTTOM', 0, 16)
	GMC.pft2:SetTextColor(1, 1, 1)
	GMC.pmf = CreateFrame("FRAME", "GMC_PRIO_MENU", GMC.pf, "UIDropDownMenuTemplate")


	GMC.prioFrames = {}
	GMC.prioFrames.selected = 0
	for i = 1, prioVoices do
		GMC.prioFrames[i] = {}
		local this = GMC.prioFrames[i]
		this.f = CreateFrame('FRAME', nil, GMC.pf)
		this.f:SetSize(255, 32)
		this.f:SetPoint('TOP', 0, -38-((i-1)*32))

		this.nr = this.f:CreateFontString()
		this.nr:SetFontObject('GameFontNormalHuge')
		this.nr:SetText(i..'.')
		this.nr:SetPoint('LEFT', 8, 0)
		this.nr:SetTextColor(1, 1, 1)

		this.text = this.f:CreateFontString()
		this.text:SetFontObject('GameFontNormalLarge')
		this.text:SetText('Def')
		this.text:SetPoint('LEFT', 32, 0)
		--this.text:SetTextColor(1, 1, 0)
		this.text:SetJustifyH('LEFT')
		this.text:Hide()

		this.xbutton = CreateFrame('BUTTON', nil, this.f, 'GameMenuButtonTemplate')
		this.xbutton:SetPoint('RIGHT', 0, 0)
		this.xbutton:SetText('X')
		this.xbutton:SetWidth(28)
		this.xbutton:SetScript('OnClick', function() removePriorityRule(i)  end)
		this.xbutton:Hide()
	end

	GMC.abutton = CreateFrame('BUTTON', nil, GMC.pmf, 'GameMenuButtonTemplate')
	GMC.abutton:SetText(L['Add priority rule'])
	GMC.abutton:SetWidth(128)
	GMC.abutton:Hide()
	GMC.abutton:SetScript('OnClick', function()
		wipe(prioMenu)
		tinsert(prioMenu,{text = L["Select an item to add as priority."], isTitle = true, isNotRadio=true,disabled=true, notCheckable=true,notClickable=true})
		for k,v in pairs(prioTitles) do
			tinsert(prioMenu,{text = v, func = addPriorityRule, notCheckable=true, isNotRadio=true, arg1 = k , disabled=inTable(GMC.settings.itemPrio,k)})
		end
		EasyMenu(prioMenu, GMC.pmf, "cursor", 0 , 0, "MENU")
		end
	)
	prioRefresh()
	return GMC.pf
end
function addon:GMCBuildMissionList()
		-- Mission list on follower panels
--		local ml=CreateFrame("Frame",nil,GMC)
--		addBackdrop(ml)
--		ml:Show()
--		ml.Missions={}
--		ml.Parties={}
--		GMC.ml=ml
--		local fs=ml:CreateFontString(nil, "BACKGROUND", "GameFontNormalHugeBlack")
--		fs:SetPoint("TOPLEFT",0,-5)
--		fs:SetPoint("TOPRIGHT",0,-5)
--		fs:SetText(READY)
--		fs:SetTextColor(C.Green())
--		fs:SetHeight(30)
--		fs:SetJustifyV("CENTER")
--		fs:Show()
--		GMC.progressText=fs
--		GMC.ml.Header=fs
--		return GMC.ml
	local ml={widget=AceGUI:Create("GMCLayer"),Parties={}}
	ml.widget:SetTitle(READY)
	ml.widget:SetTitleColor(C.Green())
	ml.widget:SetTitleHeight(40)
	ml.widget:SetParent(GMC)
	ml.widget:Show()
	GMC.ml=ml
	return ml.widget

end

