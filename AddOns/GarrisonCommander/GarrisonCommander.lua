local me, ns = ...
local addon=LibStub("LibInit"):NewAddon(me,'AceHook-3.0','AceTimer-3.0','AceEvent-3.0') --#Addon
local AceGUI=LibStub("AceGUI-3.0")
local D=LibStub("LibDeformat-3.0")
local C=addon:GetColorTable()
local L=addon:GetLocale()
local print=addon:Wrap("Print")
local trace=addon:Wrap("Trace")
local xprint=function() end
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

--[===[@debug@
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
-- Name is here just for doc, I will be using the localized one

local abilities={
	{
		["name"] = "Wild Aggression",
		["icon"] = "Interface\\ICONS\\Spell_Nature_Reincarnation.blp",
	}, -- [1]
	{
		["name"] = "Massive Strike",
		["icon"] = "Interface\\ICONS\\Ability_Warrior_SavageBlow.blp",
	}, -- [2]
	{
		["name"] = "Group Damage",
		["icon"] = "Interface\\ICONS\\Spell_Fire_SelfDestruct.blp",
	}, -- [3]
	{
		["name"] = "Magic Debuff",
		["icon"] = "Interface\\ICONS\\Spell_Shadow_ShadowWordPain.blp",
	}, -- [4]
	nil, -- [5]
	{
		["name"] = "Danger Zones",
		["icon"] = "Interface\\ICONS\\spell_Shaman_Earthquake.blp",
	}, -- [6]
	{
		["name"] = "Minion Swarms",
		["icon"] = "Interface\\ICONS\\Spell_DeathKnight_ArmyOfTheDead.blp",
	}, -- [7]
	{
		["name"] = "Powerful Spell",
		["icon"] = "Interface\\ICONS\\Spell_Shadow_ShadowBolt.blp",
	}, -- [8]
	{
		["name"] = "Deadly Minions",
		["icon"] = "Interface\\ICONS\\Achievement_Boss_TwinOrcBrutes.blp",
	}, -- [9]
	{
		["name"] = "Timed Battle",
		["icon"] = "Interface\\ICONS\\SPELL_HOLY_BORROWEDTIME.BLP",
	}, -- [10]
}

local function getAbilityName(texture)
	for i=1,#abilities do
		if (abilities[i] and abilities[i].icon==texture) then
			return abilities[i].name
		end
	end
	return "unknown"
end
--- upvalues
local AVAILABLE=AVAILABLE -- "Available"
local BUTTON_INFO=GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS.. " " .. GARRISON_MISSION_PERCENT_CHANCE
local ENVIRONMENT_SUBHEADER=ENVIRONMENT_SUBHEADER -- "Environment"
local G=C_Garrison
local GARRISON_BUILDING_SELECT_FOLLOWER_TITLE=GARRISON_BUILDING_SELECT_FOLLOWER_TITLE -- "Select a Follower";
local GARRISON_BUILDING_SELECT_FOLLOWER_TOOLTIP=GARRISON_BUILDING_SELECT_FOLLOWER_TOOLTIP -- "Click here to assign a Follower";
local GARRISON_FOLLOWERS=GARRISON_FOLLOWERS -- "Followers"
local GARRISON_FOLLOWER_CAN_COUNTER=GARRISON_FOLLOWER_CAN_COUNTER -- "This follower can counter:"
local GARRISON_FOLLOWER_EXHAUSTED=GARRISON_FOLLOWER_EXHAUSTED -- "Recovering (1 Day)"
local GARRISON_FOLLOWER_INACTIVE=GARRISON_FOLLOWER_INACTIVE --"Inactive"
local GARRISON_FOLLOWER_IN_PARTY=GARRISON_FOLLOWER_IN_PARTY
local GARRISON_FOLLOWER_ON_MISSION=GARRISON_FOLLOWER_ON_MISSION -- "On Mission"
local GARRISON_FOLLOWER_WORKING=GARRISON_FOLLOWER_WORKING -- "Working
local GARRISON_MISSION_PERCENT_CHANCE="%d%%"-- GARRISON_MISSION_PERCENT_CHANCE
local GARRISON_MISSION_SUCCESS=GARRISON_MISSION_SUCCESS -- "Success"
local GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS=GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS -- "%d Follower mission";
local GARRISON_PARTY_NOT_FULL_TOOLTIP=GARRISON_PARTY_NOT_FULL_TOOLTIP -- "You do not have enough followers on this mission."
local GARRISON_MISSION_CHANCE=GARRISON_MISSION_CHANCE -- Chanche
local GARRISON_FOLLOWER_BUSY_COLOR=GARRISON_FOLLOWER_BUSY_COLOR
local GARRISON_FOLLOWER_INACTIVE_COLOR=GARRISON_FOLLOWER_INACTIVE_COLOR
local GARRISON_CURRENCY=GARRISON_CURRENCY  --824
local GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY=GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY -- 4
local GARRISON_FOLLOWER_MAX_LEVEL=GARRISON_FOLLOWER_MAX_LEVEL -- 100

local LEVEL=LEVEL -- Level
local NOT_COLLECTED=NOT_COLLECTED -- not collected
local GMF=GarrisonMissionFrame
local GMFFollowerPage=GMF.FollowerTab
local GMFFollowers=GarrisonMissionFrameFollowers
local GMFMissionPage=GMF.MissionTab
local GMFMissionPageFollowers = GMFMissionPage.MissionPage.Followers
local GMFMissions=GarrisonMissionFrameMissions
local GMFMissionsTab1=GarrisonMissionFrameMissionsTab1
local GMFMissionsTab2=GarrisonMissionFrameMissionsTab2
local GMFMissionsTab3=GarrisonMissionFrameMissionsTab2
local GMFRewardPage=GMF.MissionComplete
local GMFRewardSplash=GMFMissions.CompleteDialog
local GMFMissionsListScrollFrameScrollChild=GarrisonMissionFrameMissionsListScrollFrameScrollChild
local GMFMissionsListScrollFrame=GarrisonMissionFrameMissionsListScrollFrame
local GMFFollowersListScrollFrameScrollChild=GarrisonMissionFrameFollowersListScrollFrameScrollChild
local GMFFollowersListScrollFrame=GarrisonMissionFrameFollowersListScrollFrame
local GMFTab1=GarrisonMissionFrameTab1
local GMFTab2=GarrisonMissionFrameTab2
local GMFTab3=_G.GarrisonMissionFrameTab3
local GarrisonFollowerTooltip=GarrisonFollowerTooltip
local GarrisonMissionFrameMissionsListScrollFrame=GarrisonMissionFrameMissionsListScrollFrame
local IGNORE_UNAIVALABLE_FOLLOWERS=IGNORE.. ' ' .. UNAVAILABLE .. ' ' .. GARRISON_FOLLOWERS
local IGNORE_UNAIVALABLE_FOLLOWERS_DETAIL=IGNORE.. ' ' .. GARRISON_FOLLOWER_INACTIVE .. ',' .. GARRISON_FOLLOWER_ON_MISSION ..',' .. GARRISON_FOLLOWER_WORKING.. ','.. GARRISON_FOLLOWER_EXHAUSTED .. ' ' .. GARRISON_FOLLOWERS
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

local GARRISON_DURATION_DAY,GARRISON_DURATION_DAYS=splitFormat(GARRISON_DURATION_DAYS) -- "%d |4day:days;";
local GARRISON_DURATION_DAY_HOURS,GARRISON_DURATION_DAYS_HOURS=splitFormat(GARRISON_DURATION_DAYS_HOURS) -- "%d |4day:days; %d hr";
local GARRISON_DURATION_HOURS=GARRISON_DURATION_HOURS -- "%d hr";
local GARRISON_DURATION_HOURS_MINUTES=GARRISON_DURATION_HOURS_MINUTES -- "%d hr %d min";
local GARRISON_DURATION_MINUTES=GARRISON_DURATION_MINUTES -- "%d min";
local GARRISON_DURATION_SECONDS=GARRISON_DURATION_SECONDS -- "%d sec";
local AGE_HOURS="First seen " .. GARRISON_DURATION_HOURS_MINUTES .. " ago"
local AGE_DAYS="First seen " .. GARRISON_DURATION_DAYS_HOURS .. " ago"


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
local GCFMissions
local GCFBusyStatus
local GameTooltip=GameTooltip
-- Want to know what I call!!
local GarrisonMissionButton_OnEnter=GarrisonMissionButton_OnEnter
local GarrisonFollowerList_UpdateFollowers=GarrisonFollowerList_UpdateFollowers
local GarrisonMissionList_UpdateMissions=GarrisonMissionList_UpdateMissions
local GarrisonMissionPage_ClearFollower=GarrisonMissionPage_ClearFollower
local GarrisonMissionPage_UpdateMissionForParty=GarrisonMissionPage_UpdateMissionForParty
local GarrisonMissionPage_SetFollower=GarrisonMissionPage_SetFollower
local GarrisonMissionButton_SetRewards=GarrisonMissionButton_SetRewards
local GetItemInfo=GetItemInfo
local type=type
local ITEM_QUALITY_COLORS=ITEM_QUALITY_COLORS
function addon:GetDifficultyColor(perc)
	if(perc >90) then
		return QuestDifficultyColors['standard']
	elseif (perc >74) then
		return QuestDifficultyColors['difficult']
	elseif(perc>49) then
		return QuestDifficultyColors['verydifficult']
	elseif(perc >20) then
		return QuestDifficultyColors['impossible']
	else
		return QuestDifficultyColors['trivial']
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
local masterplan
local followersCache={}
local followersCacheIndex={}
local dirty=false
local cache
local dbcache
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
local function genIteratorByFollower(missionID,followerID,tbl)
	do
		local tt=counters[missionID]
		local tx=counterFollowerIndex[missionID][followerID]
		setmetatable(tbl,{
			__index=function(t,k) return tt[tx[k]] end,
			__call=function(t) return #tx end
			}
		)
		return tbl
	end
end
local function genIteratorByThreat(missionID,threat,tbl)
	do
		local tt=counters[missionID]
		local tx=counterThreatIndex[missionID][threat]
		setmetatable(tbl,{
			__index=function(t,k) return tt[tx[k]] end,
			__call=function(t)  return #tx end
			}
		)
		return tbl
	end
end

--- Parties storage
--
--
local parties=setmetatable({},{
	__index=function(t,k) rawset(t,k,{members={},perc=0,full=false}) return t[k] end
})
local function inParty(missionID,followerID)
	local members=parties[missionID].members
	for i=1,#members do
		return members[i]==followerID
	end
end
--- Follower Missions Info
--
local followerMissions=setmetatable({},{
	__index=function(t,k) rawset(t,k,{}) return t[k] end
})

--
-- Temporary party management
local openParty,isInParty,pushFollower,removeFollower,closeParty,roomInParty,storeFollowers,dumpParty

do
	local ID,frames,members,maxFollowers=0,{},{},1
	---@function [parent=#local] openParty
	function openParty(missionID,followers)
		if (#frames > 0 or #members > 0) then
			error(format("Unbalanced openParty/closeParty %d %d",#frames,#members))
		end
		maxFollowers=followers
		frames={GetFramesRegisteredForEvent('GARRISON_FOLLOWER_LIST_UPDATE')}
		for i=1,#frames do
			frames[i]:UnregisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
		end
		ID=missionID
	end
	---@function [parent=#local] isInParty
	function isInParty(followerID)
		for i=1,maxFollowers do
			if (followerID==members[i]) then return true end
		end
	end

	---@function [parent=#local] roomInParty
	function roomInParty()
		return maxFollowers-#members
	end

	---@function [parent=#local] dumpParty
	function dumpParty()
		for i=1,3 do
			if (members[i]) then
				print(i,addob:GetFollowerData(members[i],'fullname'))
			end
		end
	end

	---@function [parent=#local] pushFollower
	function pushFollower(followerID)
		if (followerID:sub(1,2) ~= '0x') then trace(followerID .. "is not an id") end
		if (roomInParty()>0) then
			local rc,code=pcall (C_Garrison.AddFollowerToMission,ID,followerID)
			if (rc and code) then
				tinsert(members,followerID)
				return true
--[===[@debug@
			else
				trace("Unable to add", n[followerID],"to",ID,code)
--@end-debug@]===]
			end
		end
	end
	---@function [parent=#local] removeFollowers
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

	---@function [parent=#local] storeFollowers
	function storeFollowers(table)
		wipe(table)
		for i=1,#members do
			tinsert(table,members[i])
		end
		return #table
	end

	---@function [parent=#local] closeParty
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
		for i=1,#frames do
			frames[i]:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")

		end
		wipe(frames)
		wipe(members)
		return perc
	end
end
-- These local will became conf var
-- locally upvalued, doing my best to not interfere with other sorting modules,
-- First time i am called to verride it I save it, so I give other modules a chance to hook it, too
-- Could even do a trick and secureHook it at the expense of a double sort...
local origGarrison_SortMissions

function addon.Garrison_SortMissions_Chance(missionsList)
	local comparison
	do
		function comparison(mission1, mission2)
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
function addon.Garrison_SortMissions_Followers(missionsList)
	local comparison
	do
		function comparison(mission1, mission2)
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

function addon:OnInitialized()
--[===[@debug@
	print("OnInitialized")
	LoadAddOn("Blizzard_DebugTools")
	self:DebugEvents()
--@end-debug@]===]
	self:CreatePrivateDb()
	self:SafeRegisterEvent("GARRISON_MISSION_STARTED")
	self:SafeRegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE")
	self:SafeRegisterEvent("GARRISON_MISSION_NPC_CLOSED",function(...) GCF:Hide() end)
	self:SafeHookScript("GarrisonMissionFrame","OnShow","SetUp",true)
	self:AddToggle("MOVEPANEL",true,L["Unlock Garrison Panel"])
	self:AddToggle("IGM",true,IGNORE_UNAIVALABLE_FOLLOWERS,IGNORE_UNAIVALABLE_FOLLOWERS_DETAIL)
	self:AddToggle("IGP",true,L["Ignore epic quality level 100 followers"],L["Level 100 epic followers are not used for match making. Useful when you level"])
	self:AddSelect("MSORT","Garrison_SortMissions_Original",
	{
		Garrison_SortMissions_Original=L["Original method"],
		Garrison_SortMissions_Chance=L["Success Chance"],
		Garrison_SortMissions_Followers=L["Number of followers"],
	},
	L["Sort missions by:"],L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"])
--self:AddSlider("RESTIMER",5,1,10,"Enable res timer","Shows a timer for battlefield resser",1)
	self:AddSlider("MAXMISSIONS",5,1,8,L["Mission shown for follower"],nil,1)
	self:AddSlider("MINPERC",50,0,100,L["Minimun chance success under which ignore missions"],nil,5)
	self:Trigger("MSORT")
	return true
end
function addon:ApplyIGM(value)
	self:BuildMissionsCache(false,true)
	GarrisonMissionList_UpdateMissions()
end
function addon:ApplyIGP(value)
	self:BuildMissionsCache(false,true)
	GarrisonMissionList_UpdateMissions()
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
	GarrisonMissionList_UpdateMissions()
end
function addon:ApplyMAXMISSIONS(value)
	MAXMISSIONS=value
	BUSY_MESSAGE=format(BUSY_MESSAGE_FORMAT,MAXMISSIONS,MINPERC)

end
function addon:ApplyMINPERC(value)
	MINPERC=value
	BUSY_MESSAGE=format(BUSY_MESSAGE_FORMAT,MAXMISSIONS,MINPERC)
end



function addon:RestoreTooltip()
	local self = GMF.MissionTab.MissionList;
	local scrollFrame = self.listScroll;
	local buttons = scrollFrame.buttons;
	for i =1,#buttons do
		buttons[i]:SetScript("OnEnter",GarrisonMissionButton_OnEnter)
	end
end



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
	for id,d in pairs(G.GetBuffedFollowersForMission(missionID)) do
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
	for id,d in pairs(G.GetFollowersTraitsForMission(missionID)) do
		local level=self:GetFollowerData(id,'level')
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
function addon:Check(missionID)

end
function addon:ThreatDisplayer()
	TF="0x00000000000C2C1B"
	if (not AXE) then
		local AXE=CreateFrame("Frame","AXE",UIParent,"GarrisonAbilityLargeCounterTemplate")
		AXI=CreateFrame("Frame","AXI",UIParent,"GarrisonAbilityCounterTemplate")
	end
	if (not BUBU) then
		CreateFrame("CheckButton","BUBU",AXE,"UICheckButtonTemplate")
	end

	BUBU:SetPoint("CENTER")
	BUBU:SetChecked(true)
	BUBU:GetCheckedTexture():SetVertexColor(1,0,0)

	AXE:SetPoint("CENTER",-100.0)
	AXI:SetPoint("CENTER",100,0)
	AXE:Show()
	AXI:Show()
	local id=154
	local env=select(5,C_Garrison.GetMissionInfo(id))
	AXI.Icon:SetTexture(env)
	AXI.Border:SetVertexColor(1,0,0)
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
local dbg=false
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
			if (not self:IsIgnored(followerID,missionID) and not(skipMaxed and data.maxed) and not isInParty(followerID) and self:GetFollowerStatusForMission(followerID,skipBusy)) then
				local missions=#followerMissions[followerID]
				local rank=data.rank
				local quality=data.quality
				repeat
					if (perc<100) then
						pushFollower(followerID)
						local newperc=select(4,G.GetPartyMissionInfo(missionID))
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
					-- This candidate is not improving success chance, minimize
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
function addon:MatchMaker(missionID,mission,party)
	if (GMFRewardSplash:IsShown()) then return end
	if (not mission) then mission=self:GetMissionData(missionID) end
	if (not party) then party=parties[missionID] end
	local skipBusy=addon:GetBoolean("IGM")
	local skipMaxed=self:GetBoolean("IGP")
	dbg=missionID==(tonumber(_G.MW) or 0)
	local slots=mission.slots
	local missionCounters=counters[missionID]
	local ct=counterThreatIndex[missionID]
	openParty(missionID,mission.numFollowers)
	for i=1,#slots do
		local threat=cleanicon(slots[i].icon)
		local candidates=ct[threat]
		local choosen
		for i=1,#candidates do
			local followerID=missionCounters[candidates[i]].followerID
			if (self:IsIgnored(followerID,missionID)) then
				if (dbg) then print("Skipped",n[followerID],"due to ignored" ) end
			elseif(not addon:GetFollowerStatusForMission(followerID,skipBusy)) then
				if (dbg) then print("Skipped",n[followerID],"due to skipbusy" ) end
			elseif (skipMaxed and self:GetFollowerData(followerID,'maxed')) then
				if (dbg) then print("Skipped",n[followerID],"due to maxed" ) end
			else
				choosen=best(choosen,candidates[i],missionCounters)
				if (dbg) then print("Taken",n[missionCounters[choosen].followerID]) end
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
	self:CompleteParty(missionID,mission,skipBusy,skipMaxed)
	storeFollowers(party.members)
	party.full= roomInParty()==0
	party.perc=closeParty()
end
function addon:IsIgnored(followerID,missionID)
	if (dbcache.ignored[missionID][followerID]) then return true end
	if (dbcache.totallyignored[followerID]) then return true end
end
function addon:GetCounterBias(missionID,threat)
	local bias=-1
	local who=""
	local iter=genIteratorByThreat(missionID,cleanicon(tostring(threat)),new())
	for i=1,iter() do
		if (iter[i]) then
			if (iter[i].bias > bias) then
				if (inParty(missionID,iter[i].followerID)) then
					bias=iter[i].bias
					who=iter[i].name
				end
			end
		end
	end
	del(iter)
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

function addon:HookedGarrisonMissionButton_AddThreatsToTooltip(missionID)
	local mission=self:GetMissionData(missionID)
	local button=GetMouseFocus()
--[===[@debug@
	GameTooltip:AddLine("ID:" .. tostring(missionID))
	if (not mission) then GameTooltip:AddLine("E dove minchia è finita??") return end
--@end-debug@]===]
	if (true) then
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
		local bias,who=self:GetCounterBias(missionID,t)
		local color=self:GetBiasColor(bias,nil,"Green")
		local c=C[color]
		f.Env.Border:SetVertexColor(c())
		for i=1,#f.Threats do
			local th=f.Threats[i]
			local bias=self:GetCounterBias(missionID,th.Icon:GetTexture())
			local color=self:GetBiasColor(bias,nil,"Green")
			local c=C[color]
			th.Border:SetVertexColor(c())
		end
	end
	-- Adding All available followers
	GameTooltip:AddLine(L["Other useful followers"])
	local fullnames=new()
	local biascolors=new()
	local partystring=strjoin("|",tostringall(unpack(parties[missionID].members)))
	for followerID,refs in pairs(counterFollowerIndex[missionID]) do
		if (not partystring:find(followerID)) then
			local fullname= self:GetFollowerData(followerID,'fullname')
			for i=1,#refs do
				fullname=fullname .." |T" .. tostring(counters[missionID][refs[i]].icon) ..":16|t"
			end
			tinsert(fullnames,fullname)
			biascolors[fullname]={self:GetBiasColor(followerID,missionID,"White"),self:GetFollowerStatus(followerID,true)}
		end
	end
	table.sort(fullnames)
	for i=1,#fullnames do
		local fullname=fullnames[i]
		local info=biascolors[fullname]
		self:AddLine(fullname,info[2],info[1])
	end

--	for i=1,#mission.slots do
--		local slot=mission.slots[i]
--		local indexes=counterThreatIndex[missionID][cleanicon(slot.icon)]
--		local name=C(NONE,"Red")
--		if (indexes and #indexes > 0) then
--			local fid=counters[missionID][indexes[1]].followerID
--			name=fullnames[fid]
--		end
--		GameTooltip:AddDoubleLine(slot.name==TYPE and ENVIRONMENT_SUBHEADER or slot.name,name,nil,nil,nil,C.Green())
--	end
	del(fullnames)
	del(biascolors)
	local perc=parties[missionID].perc
	local q=self:GetDifficultyColor(perc)
	GameTooltip:AddDoubleLine(GARRISON_MISSION_SUCCESS,format(GARRISON_MISSION_PERCENT_CHANCE,perc),nil,nil,nil,q.r,q.g,q.b)
	for _,i in pairs (dbcache.ignored[missionID]) do
		GameTooltip:AddLine(L["You have ignored followers"])
		break;
	end
end

function addon:FillFollowersList()
	if (GarrisonFollowerList_UpdateFollowers) then
		GarrisonFollowerList_UpdateFollowers(GMF.FollowerList)
	end
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
function addon:RefreshLayout()
	for i=1,#GarrisonMissionFrameMissionsListScrollFrame.buttons do
		local b=GarrisonMissionFrameMissionsListScrollFrame.buttons[i]
		if (b.Party) then
			for j=1,3 do
				DevTools_Dump(b.Party[1])
			end
		end
	end
end
function addon:BuildMissionsCache(fc,mm)
--[===[@debug@
	local start=GetTime()
	print("Start Full Cache Rebuild")
--@end-debug@]===]
	local t=new()
	G.GetAvailableMissions(t)
	for index=1,#t do
		local missionID=t[index].missionID
		self:BuildMissionCache(missionID,t[index])
		if fc then self:FillCounters(missionID) end
		if mm then self:MatchMaker(missionID) end
	end
	del(t)
--[===[@debug@
	print("Done in",GetTime()-start)
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
function addon:UpdateRunningMissionCache(missionId,destroy)
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
--]]
function addon:BuildMissionCache(id,data)
	if (not	dbcache.seen[id]) then
		dbcache.seen[id]=time()
	end
	local mission=cache.missions[id]
	if (mission.name=="<newmission>") then
		if (not data) then
			mission.name=G.GetMissionName(id)
			mission.numFollowers=G.GetMissionMaxFollowers(id)
			mission.durationSeconds=select(5,G.GetMissionTimers(id))
		else
			mission.name=data.name
			mission.numFollowers=data.numFollowers
			mission.durationSeconds=data.durationSeconds
		end
		mission.rank=mission.level < 100 and mission.level or mission.iLevel
		mission.xp=true
		mission.resources=false
		for k,v in pairs(G.GetMissionRewardInfo(id)) do
			if (not v.followerXP) then mission.xp=false end
			if (v.currencyID and v.currencyID==GARRISON_CURRENCY) then mission.resource=false end
		end
		local _,xp,type,typeDesc,typeIcon,locPrefix,_,enemies=G.GetMissionInfo(id)
		mission.locPrefix=locPrefix
		if (not type) then
--[===[@debug@
			print(true,"No type",id,data.name)
--@end-debug@]===]
		else
			self.db.global.types[type]={name=typeDesc,icon=typeIcon}
		end
		wipe(mission.slots)
		local slots=mission.slots

		for i=1,#enemies do
			local mechanics=enemies[i].mechanics
			for i,mechanic in pairs(mechanics) do
				tinsert(slots,{name=mechanic.name,icon=mechanic.icon})
				self.db.global.abilities[mechanic.name]={desc=mechanic.description,icon=mechanic.icon}
			end
		end
		if (type) then
			tinsert(slots,{name=TYPE,icon=typeIcon})
		end
	end
	mission.basePerc=select(4,G.GetPartyMissionInfo(id))
end
function addon:SetDbDefaults(default)
	default.global=default.global or {}
	default.global["*"]={
	}
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
				}
			}
		},
		true)
	self.private=self:RegisterDatabase(
		"GACPrivateVolatile",
		{
			profile={
				missions={
					["*"]={
						counters={},
						slots={},
						missionID=0,
						numFollowers=0,
						name="<newmission>",
						basePerc=0,
						durationSeconds=0,
						level=0,
						iLevel=0,
						rank=0,
						locPrefix=false
					}
				}
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
function addon:wipe(i)
	DevTools_Dump(i)
	privatedb:ResetDB()
end
function addon:WipeMission(missionID)
	cache.missions[missionID]=nil
	counters[missionID]=nil
	dbcache.seen[missionID]=nil
	parties[missionID]=nil
	collectgarbage("step")


end

---
--@param #string event GARRISON_MISSION_NPC_OPENED
-- Fires after GarrisonMissionFrame OnShow. Pretty useless

function addon:EventGARRISON_MISSION_NPC_OPENED(event,...)
--[===[@debug@
	print(event,...)
--@end-debug@]===]
	GCF:Show()
end
function addon:EventGARRISON_MISSION_NPC_CLOSED(event,...)
--[===[@debug@
	print(event,...)
--@end-debug@]===]
	GCF:Hide()
end
---
--@param #string event GARRISON_MISSION_STARTED
--@param #number missionID Numeric mission id
-- After this events fires also GARRISON_MISSION_LIST_UPDATE and GARRISON_FOLLOWER_LIST_UPDATE

function addon:EventGARRISON_MISSION_STARTED(event,missionID,...)
--[===[@debug@
	print(event,missionID,...)
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
	for i=1,3 do
		local m=parties[missionID].members[i]
		if (m) then
			tinsert(dbcache.running.followers,m)
			dbcache.runningIndex[m]=missionID
		end
	end
	dbcache.seen[missionID]=nil
	counters[missionID]=nil
	parties[missionID]=nil
	self:BuildMissionsCache(true,true)
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
	print(event,missionID,...)
	DevTools_Dump(G.GetPartyMissionInfo(missionID))
--@end-debug@]===]
end

function addon:EventGARRISON_MISSION_BONUS_ROLL_COMPLETE(event,missionID,completed,success)
--[===[@debug@
	print(event,missionID,completed,success)
--@end-debug@]===]
end
---
--@param #number missionID mission identifier
--@param #boolean completed I suppose it always be true...
--@oaram #boolean success Mission was succesfull
--Mission complete Sequence is:
--GARRISON_MISSION_COMPLETE_RESPONSE
--GARRISON_MISSION_BONUS_ROLL_COMPLETE missionID true
--GARRISON_FOLLOWER_XP_CHANGED (1 or more times
--GARRISON_MISSION_NPC_OPENED ??
--GARRISON_MISSION_BONUS_ROLL_COMPLETE missionID nil
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
end

function addon:OptionOnClick(checkbox)
	self:SetBoolean(checkbox.flag,checkbox:GetChecked())
	trace(checkbox.flag)
	self:Trigger(checkbox.flag)
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
-- Keeping it as a nice example of coroutine management.. but not using it anymore
function addon:Clock()
	collectgarbage("step")
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
--[===[@debug@
	local h,m=GetGameTime()
	if (m~=lastmin) then
		lastmin=m
		UpdateAddOnCPUUsage()
		UpdateAddOnMemoryUsage()
		print("GC Usage",GetAddOnCPUUsage("GarrisonCommander"),GetAddOnMemoryUsage("GarrisonCommander"))
	end
--@end-debug@]===]
end
function addon:ActivateButton(button,OnClick,Tooltiptext,persistent)
	button:SetScript("OnClick",function(...) self[OnClick](self,...) end )
	if (Tooltiptext) then
		button.tooltip=Tooltiptext
		button:SetScript("OnEnter",function(...) self:ShowTT(...) end )
		button:SetScript("OnLeave",function() GameTooltip:FadeOut() end)
	else
		button:SetScript("OnEnter",nil)
		button:SetScript("OnLeave",nil)
	end
end
function addon:ShowTT(this)
	GameTooltip:SetOwner(this, "ANCHOR_CURSOR_RIGHT")
	GameTooltip:SetText(this.tooltip)
	GameTooltip:Show()
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
local helpwindow -- pseudo static
function addon:ShowHelpWindow(button)
	if (not helpwindow) then
		local backdrop = {
				bgFile="Interface\\TutorialFrame\\TutorialFrameBackground",
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
		helpwindow=CreateFrame("Frame","GCHelp",GCF)
		helpwindow:SetBackdrop(backdrop)
		helpwindow:SetBackdropColor(1,1,1,1)
		helpwindow:SetFrameStrata("TOOLTIP")
		helpwindow:Show()
		local html=CreateFrame("SimpleHTML","GCHelpHtml",helpwindow)
		html:SetFontObject('h1',MovieSubtitleFont);
		local f=MailTextFontNormal_KO
		html:SetFontObject('h2',f);
		html:SetFontObject('h3',f);
		html:SetFontObject('p',f);
		html:SetTextColor('h1',C.Red())
		html:SetTextColor('h2',C.Orange())
		html:SetTextColor('h3',C.Yellow())
		html:SetTextColor('p',C.Yellow())
		local text=[[<html><body>
<h1 align="center">Garrison Commander Help</h1>
<br/>
<p>  GC enhances standard Garrison UI by adding a Menu header and  a secondary list of mission button to the right of the standard list.</p>
<br/>
<h2>  Secondary button list:</h2>
<p>
	* Time since the first time we saw this mission in log<br/>
	* Success percent with the current followers selection guidelines<br/>
	* A "Good" party composition, on each member countered mechanics are shown.<br/>
	*** Green border means full counter, Orange border low level counter<br/>
</p>
<h2>Tooltip:</h2>
<p>
 * Overall mission status<br/>
 * All members which can possibly play a role in the mission<br/>
</p>
<h2>Standard button enhancement:</h2>
<p>
 * In rewards, actual quantity is shown (xp, money and resources) ot iLevel (item rewards)<br/>
 * Countered status<br/>
</p>
<h2>Menu Header:</h2>
<p>
 * Quick selection of which follower ignore for match making<br/>
 * Quick mission list order selection<br/>
</p>
</body></html>
]]
		--html:SetTextColor('h1',C.Red())
		--html:SetTextColor('h2',C.Orange())
		helpwindow:SetWidth(600)
		helpwindow:SetHeight(600)
		html:SetPoint("TOPLEFT",5,-5)
		html:SetWidth(590)
		html:SetHeight(590)
		helpwindow:SetPoint("TOPLEFT",button,"TOPRIGHT",0,-20)
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
local function GFC_Constructor()
	local widget=setmetatable({},{__index=AceGUI:Create("SimpleGroup")})
	function widget:DrawOn(frame,l,r)
		self.frame:ClearAllPoints()
		self.frame:SetPoint("TOPLEFT",frame,"TOPLEFT",l,0)
		self.frame:SetPoint("BOTTOMRIGHT",frame,"TOPRIGHT",r,0)
	end
	function widget:OnRelease()
		self.frame:ClearAllPoints()
	end
	if (false) then
		AceGUI:RegisterWidgetType("GarrisonCommanderHeader",GFC_Constructor,1)
		local layer=AceGUI:Create("GarrisonCommanderHeader")
		layer:DrawOn(GCF)
		layer:SetLayout("flow")
		LibStub("AceConfigDialog-3.0"):Open(me,layer)
	end
	return widget
end
function addon:Select(obj,rel,name,text)
	local b=CreateFrame("Frame","MSORT",obj,"GarrisonCommanderMenu")
	b.Text:SetFormattedText("%s: %s",C("Sort: ","Yellow"),C("Not yet implemented","Red"))
	b.menu={
		{text="Not yet implemented",notCheckable=true,notClickable=true},
		{text="Example",func=print,arg1="arg1",arg2="arg2"}
	}
	b:SetPoint("LEFT",rel,"RIGHT",10,0)
	b:SetWidth(400)
	b:SetHeight(20)
	b:Show()
	return b
end
function addon:Option(obj,rel,name,text)
	local b=CreateFrame("CheckButton",nil,obj,"UICheckButtonTemplate")
	b.text:SetText(text)
	b.flag=name
	b:SetScript("OnCLick",function(...) self:OptionOnClick(...) end)
	obj[name]=b
	b:SetChecked(self:GetBoolean(name))
	switch(name,self:GetBoolean(name))
	b:SetPoint("LEFT",rel,"RIGHT",10,0)
	b:Show()
	return b.text
end
function addon:Menu(obj,rel,name,text,table)
end
function addon:CreateOptionsLayer(...)
	local o=AceGUI:Create("SimpleGroup") -- a transparent frame
	o:SetLayout("Flow")
	o:SetCallback("OnClose",function(widget) widget.frame:SetScale(1.0) widget:Release() end)
	for i=1,select('#',...) do
		local flag=select(i,...)
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
			elseif(info.type=="select") then
				widget=AceGUI:Create("Dropdown")
				widget:SetValue(self:GetVar(flag))
				widget:SetLabel(info.name)
				widget:SetText(info.values[self:GetVar(flag)])
				widget:SetList(info.values)
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
	end
	_G.TEST=o
	local frame=setmetatable({},{__index=o})
	function frame:Show() self.frame:Show() end
	return frame
end
function addon:Options()
	-- Main Garrison Commander Header
	local base=CreateFrame("Frame",nil,UIParent,"GarrisonCommanderTitle")
	GCF=base
	GCF:SetWidth(BIGSIZEW)
	GCF:SetPoint("TOP",UIParent,0,-60)
	base:SetHeight(40)
	base:EnableMouse(true)
	GCF:SetMovable(true)
	GCF:RegisterForDrag("LeftButton")
	GCF:SetScript("OnDragStart",function(frame)if (self:GetBoolean("MOVEPANEL")) then frame:StartMoving() end end)
	GCF:SetScript("OnDragStop",function(frame) frame:StopMovingOrSizing() end)
	-- Adding a signture
	local rel=base.Signature
	--rel=self:Option(base,rel,'IGM',L["Ignore busy followers"])
	--rel=self:Option(base,rel,'IGP',L["Try not to use epic quality level 100 followers"])
	--rel=self:Option(base,rel,'MOVEPANEL',L["Unlock Panel"])
	--rel=self:Select(base,rel,'MSORT',"Pippo")
	--HelpButton
	local h=CreateFrame("Button",nil,base,"UIPanelCloseButton")
	h:SetFrameLevel(999)
	h:SetNormalTexture("interface\\buttons\\ui-microbutton-help-up")
	h:SetPushedTexture("interface\\buttons\\ui-microbutton-help-down")
	h:SetHeight(64)
	h:SetWidth(32)
	h:SetPoint("BOTTOMLEFT")
	self:ActivateButton(h,"ShowHelpWindow",L["Click to toggle Help page"])
	GCF.gcHELP=h
	--MinimizeButton
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
	self:Trigger("MOVEPANEL")
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
	self.Options=function() end
end

function addon:ScriptTrace(hook,frame,...)
--[===[@debug@
	print("Triggered " .. C(hook,"red").." script on",C(frame,"Azure"),...)
--@end-debug@]===]
end
function addon:IsProgressMissionPage()
	return GMF:IsShown() and GarrisonMissionFrameMissionsListScrollFrame:IsShown() and GMFMissions.showInProgress and not GMFFollowers:IsShown() and not GMF.MissionComplete:IsShown()
end
function addon:IsAvailableMissionPage()
	return GMF:IsShown() and GarrisonMissionFrameMissionsListScrollFrame:IsShown() and not GMFMissions.showInProgress  and not GMFFollowers:IsShown() and not GMF.MissionComplete:IsShown()
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
function addon:_AddPerc(b,...)
	if (b and b.info and b.info.missionID and b.info.missionID ) then
		if (GMF.MissionTab.MissionList.showInProgress) then
			self:RenderButton(b)
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
			if (masterplan) then
				b.Success:SetFontObject("GameFontNormal")
			else
				b.Success:SetFontObject("GameFontNormalLarge2")
			end
			b.Success:SetPoint("BOTTOMLEFT",b.Title,"TOPLEFT",0,3)
		end
		if (not b.NotEnough) then
			b.NotEnough=b:CreateFontString()
			if (masterplan) then
				b.NotEnough:SetFontObject("GameFontNormal")
				b.NotEnough:SetPoint("TOPLEFT",b.Title,"BOTTOMLEFT",150,-3)
			else
				b.NotEnough:SetFontObject("GameFontNormalSmall2")
				b.NotEnough:SetPoint("TOPLEFT",b.Title,"BOTTOMLEFT",0,-3)
			end
			b.NotEnough:SetText("(".. GARRISON_PARTY_NOT_FULL_TOOLTIP .. ")")
			b.NotEnough:SetTextColor(C:Red())
		end
		if (Perc <0 and not b:IsMouseOver()) then
			self:TooltipAdder(missionID,true)
			Perc=successes[missionID] or -2
		end
		if (Perc>=0) then
			if (masterplan) then
				b.Success:SetFormattedText(GARRISON_MISSION_PERCENT_CHANCE,successes[missionID])
			else
				b.Success:SetFormattedText(BUTTON_INFO,G.GetMissionMaxFollowers(missionID),successes[missionID])
			end
			local q=self:GetDifficultyColor(successes[missionID])
			b.Success:SetTextColor(q.r,q.g,q.b)
		else
			b.Success:SetText(UNKNOWN_CHANCE)
			b.Success:SetTextColor(1,1,1)
		end
		b.Success:Show()
		if (not requested[missionID]) then
			requested[missionID]=G.GetMissionMaxFollowers(missionID)
		end
		if (requested[missionID]>availableFollowers) then
			b.NotEnough:Show()
		else
			b.NotEnough:Hide()
		end
		b.ProgressHidden=false
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
function addon:HookedGarrisonFollowerListButton_OnClick(frame,button)
--[===[@debug@
	trace("Click",button,GarrisonMissionFrame.FollowerTab.Model:IsShown())
--@end-debug@]===]
	if (button=="LeftButton" and GarrisonMissionFrame.FollowerTab.FollowerID ~= frame.info.followerID) then
		if (frame.info.isCollected) then
			self:HookedGarrisonFollowerPage_ShowFollower(frame.info,frame.info.followerID)
		end
	end
end
-- Shamelessly stolen from Blizzard Code
function addon:FillMissionButton(button)
	local mission=button.info
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
	self.ClonedGarrisonMissionButton_SetRewards(button, mission.rewards, mission.numRewards);
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

local Busystatusmessage
function addon:HookedGarrisonFollowerPage_ShowFollower(frame,followerID)
	local i=0
	if (not self:IsFollowerList()) then return end
	if (not GCFMissions.Missions) then GCFMissions.Missions={} end
	if (not Busystatusmessage) then Busystatusmessage=C(BUSY_MESSAGE,"Red)") end
	-- frame has every info you can need on a follower, but here I dont really need them, maybe just counters
	--DevTools_Dump(table.Counters)
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
		self:FillFollowerButton(GCFMissions.Header,followerID)
		-- Scanning mission list
		for z = 1,#partyIndex do
			local missionID=partyIndex[z]
			if not(tonumber(missionID)) then
--[===[@debug@
				print("missionid not a number",missionID)
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
				panel.id=index[missionID]
				self:FillMissionButton(panel)
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
	print("Setup")
--@end-debug@]===]
	SIZEV=GMF:GetHeight()
	self:Options()
	self:StartUp()
end
---
-- Additional setup
-- This method is called every time garrison mission panel is open because
-- when it closes, I remove most of used hooks
function addon:StartUp(...)
--[===[@debug@
	print("Startup")
--@end-debug@]===]
	self:Unhook(GMF,"OnShow")
	self:PermanentEvents()
	GCF.Menu=self:CreateOptionsLayer('IGM','IGP','MOVEPANEL','MSORT')
	GCF.Menu:SetParent(GCF)
	GCF.Menu.frame:SetScale(0.6)
	GCF.Menu:SetPoint("TOPLEFT",GCF.Signature,"TOPRIGHT",10,10)
	GCF.Menu:SetPoint("BOTTOMRIGHT",GCF,"BOTTOMRIGHT",-30,0)
	GCF.Menu:Show()
	self:GrowPanel()
	self:SafeSecureHook("GarrisonMissionButton_OnClick","OnClick_GarrisonMissionButton")
	self:SafeSecureHook("GarrisonMissionFrame_CheckCompleteMissions")
	self:SafeSecureHook("GarrisonMissionButton_AddThreatsToTooltip")
	self:SafeSecureHook("GarrisonMissionButton_SetRewards")
	self:SafeSecureHook("GarrisonFollowerListButton_OnClick")--,function(...) xprint("GarrisonFollowerListButton_OnClick",...) end)
	self:SafeSecureHook("GarrisonFollowerPage_ShowFollower")--,function(...) xprint("GarrisonFollowerPage_ShowFollower",...) end)
	self:SafeSecureHook("GarrisonFollowerTooltipTemplate_SetGarrisonFollower")
	self:SafeSecureHook("GarrisonMissionFrame_HideCompleteMissions")	-- Mission reward completed
	self:SafeSecureHook("GarrisonMissionPage_ShowMission")
	self:SafeSecureHook("GarrisonMissionList_UpdateMissions")
	self:SafeHookScript(GMFMissions,"OnShow")--,"GrowPanel")
	self:SafeHookScript(GMFFollowers,"OnShow")--,"GrowPanel")
	self:SafeHookScript(GCF,"OnHide","CleanUp",true)
	self:ScheduleRepeatingTimer("Clock",1)
	self:BuildMissionsCache(true,true)
	self:BuildRunningMissionsCache()
	GarrisonMissionList_UpdateMissions();
end
-- probably not really needed, haven seen yet them firing out of garrison
function addon:PermanentEvents()
	self:SafeRegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")
	self:SafeRegisterEvent("GARRISON_MISSION_STARTED")
	self:SafeRegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE")
	self:SafeRegisterEvent("GARRISON_MISSION_NPC_CLOSED")
	self:SafeRegisterEvent("GARRISON_FOLLOWER_XP_CHANGED")
--[===[@debug@
	self:DebugEvents()
--@end-debug@]===]
end
function addon:DebugEvents()
	self:SafeRegisterEvent("GARRISON_MISSION_LIST_UPDATE")
	self:SafeRegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE") -- Should be used only when has true as parameter
	self:SafeRegisterEvent("GARRISON_FOLLOWER_ADDED")
	self:SafeRegisterEvent("GARRISON_FOLLOWER_REMOVED")
	self:SafeRegisterEvent("GARRISON_MISSION_BONUS_ROLL_LOOT")
	self:SafeRegisterEvent("GARRISON_MISSION_FINISHED")
	self:SafeRegisterEvent("GARRISON_UPDATE")
	self:SafeRegisterEvent("GARRISON_USE_PARTY_GARRISON_CHANGED")
	self:SafeRegisterEvent("GARRISON_MISSION_NPC_OPENED")
end
function addon:checkMethod(method,hook)
	if (type(self[method])=="function") then
--[===[@debug@
		--print("Hooking ",hook,"to self:" .. method)
--@end-debug@]===]
		return true
--[===[@debug@
	else
		--print("Hooking ",hook,"to print")
--@end-debug@]===]
	end
end
function addon:SafeRegisterEvent(event)
	local method="Event"..event
	if (self:checkMethod(method,event)) then
		return self:RegisterEvent(event,method)
--[===[@debug@
	else
		return self:RegisterEvent(event,print)
--@end-debug@]===]
	end
end
function addon:SafeSecureHook(tobehooked,method)
	method=method or "Hooked"..tobehooked
	if (self:checkMethod(method,tobehooked)) then
		return self:SecureHook(tobehooked,method)
--[===[@debug@
	else
		do
			local hooked=tobehooked
			return self:SecureHook(tobehooked,function(...) print(hooked,...) end)
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
	GCF.Menu:Release()
	self:HookScript(GMF,"OnSHow","StartUp",true)
	self:PermanentEvents() -- Reattaching permanent events
	if (GarrisonFollowerTooltip.fs) then
		GarrisonFollowerTooltip.fs:Hide()
	end
	collectgarbage("collect")
--[===[@debug@
	print("Cleaning up")
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
		followersCache=G.GetFollowers()
		for i,follower in pairs(followersCache) do
			if (not follower.isCollected) then
				followersCache[i]=nil
			else
			follower.rank=follower.level==100 and follower.iLevel or follower.level
			follower.coloredname=C(follower.name,tostring(follower.quality))
			follower.fullname=format("%3d %s",follower.rank,follower.coloredname)
			follower.maxed=follower.quality >= GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY and follower.level >=GARRISON_FOLLOWER_MAX_LEVEL
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
	if (missionCache.name=="<newmission>") then
--[===[@debug@
		print("Found a new mission",missionID,"Refreshing mission list")
--@end-debug@]===]
		self:BuildMissionsCache()
		self:FillCounters(missionID,cache.missions[missionID])
		self:MatchMaker(missionID,cache.missions[missionID])
	end
	if (subkey) then
		return missionCache[subkey]
	end
	return missionCache
end
function addon:GetFollowerStatusForMission(followerID,skipbusy)
	if (not skipbusy) then
		return true
	else
		return self:GetFollowerStatus(followerID) == AVAILABLE
	end
end
function addon:GetFollowerStatus(followerID,withTime,colored)
	local status=G.GetFollowerStatus(followerID)
	if (status and status== GARRISON_FOLLOWER_ON_MISSION and withTime) then
		local running=dbcache.running[dbcache.runningIndex[followerID]]
		status=SecondsToTime(time()  - running.started + running.duration,true)
	end
-- The only case a follower appears in party is after a refused mission due to refresh triggered before GARRISON_FOLLOWER_LIST_UPDATE
	if (status and status~=GARRISON_FOLLOWER_IN_PARTY) then
		return colored and C(status,"Red") or status
	else
		return colored and C(AVAILABLE,"Green") or AVAILABLE
	end
end

function addon:HookedGarrisonMissionPage_ShowMission(missionInfo)
	if( IsShiftKeyDown()) then print("Shift key, ignoring mission prefill") return end
	local missionID=missionInfo.missionID
--[===[@debug@
	print("UpdateMissionPage for",missionID,missionInfo.name,missionInfo.numFollowers)
--@end-debug@]===]
	--DevTools_Dump(missionInfo)
	--self:BuildMissionData(missionInfo.missionID.missionInfo)
	for i=1,3 do
		GarrisonMissionPage_ClearFollower(GMFMissionPageFollowers[i])
	end
	local party=parties[missionID]
	if (party) then
		local members=party.members
		for i=1,missionInfo.numFollowers do
			local followerID=members[i]
			if (followerID) then
				local info=self:GetFollowerData(followerID)
--[===[@debug@
				print("Adding follower",info.name)
--@end-debug@]===]
				GarrisonMissionPage_SetFollower(GMFMissionPageFollowers[i],info)
			end
		end
	end
	GarrisonMissionPage_UpdateMissionForParty()
end
local firstcall=true

---@function GrowPanel
-- Enforce the new panel sizes
--
function addon:GrowPanel()
	GCF:Show()
	GMF:ClearAllPoints()
	GMF:SetPoint("TOPLEFT",GCF,"BOTTOMLEFT")
	GMF:SetPoint("TOPRIGHT",GCF,"BOTTOMRIGHT")
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
function addon:FillFollowerButton(frame,followerID,missionID)
	if (not frame) then return end
	for i=1,#frame.Threats do
		if (frame.Threats[i]) then frame.Threats[i]:Hide() end
	end
	frame.NotFull:Hide()
	if (not followerID) then
		frame.PortraitFrame.Empty:Show()
		frame.Name:Hide()
		frame.Class:Hide()
		frame.Status:Hide()
		frame.PortraitFrame.LevelBorder:SetAtlas("GarrMission_PortraitRing_LevelBorder");
		frame.PortraitFrame.LevelBorder:SetWidth(58);
		frame.PortraitFrame.Level:SetText("")
		--frame:SetScript("OnEnter",nil)
		GarrisonFollowerPortrait_Set(frame.PortraitFrame.Portrait)
		return
	end
	local info=G.GetFollowerInfo(followerID)
	--local info=followers[ID]
	frame.info=info
	frame.missionID=missionID
	frame.Name:Show();
	frame.Name:SetText(info.name);
	local color=missionID and self:GetBiasColor(followerID,missionID,"White") or "Yellow"
	frame.Name:SetTextColor(C[color]())
	frame.Status:SetText(self:GetFollowerStatus(followerID,true,true))
	frame.Status:Show()
	if (frame.Class) then
		frame.Class:Show();
		frame.Class:SetAtlas(info.classAtlas);
	end
	frame.PortraitFrame.Empty:Hide();

	local showItemLevel;
	if (info.level == GarrisonMissionFrame.followerMaxLevel ) then
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
-- pseudo static
local scale=0.9
function addon:BuildFollowersButtons(button,bg,limit)
	if (bg.Party) then return end
	bg.Party={}
	for numMembers=1,3 do
		local f=CreateFrame("Button",nil,bg,"GarrisonCommanderMissionPageFollowerTemplate")
		if (numMembers==1) then
			f:SetPoint("BOTTOMLEFT",bg.Percent,"BOTTOMRIGHT",10,0)
		else
			f:SetPoint("LEFT",bg.Party[numMembers-1],"RIGHT",10,0)
		end
		tinsert(bg.Party,f)
		f:EnableMouse(true)
		f:SetScript("OnEnter",GarrisonMissionPageFollowerFrame_OnEnter)
		f:SetScript("OnLeave",GarrisonMissionPageFollowerFrame_OnLeave)
		f:RegisterForClicks("AnyUp")
		f:SetScript("OnClick",function(...) self:OnClick_PartyMember(...) end)
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
function addon:BuildExtraButton(button)
	local bg=CreateFrame("Button",nil,button,"GarrisonCommanderMissionButton")
	bg:SetPoint("TOPLEFT",button,"TOPRIGHT")
	bg:SetPoint("RIGHT",GarrisonMissionFrameMissionsListScrollFrame,"RIGHT",-25,0)
	bg.button=button
	bg:SetScript("OnEnter",function(this) GarrisonMissionButton_OnEnter(this.button) end)
	bg:SetScript("OnLeave",function() GameTooltip:FadeOut() end)
	bg:RegisterForClicks("AnyUp")
	bg:SetScript("OnClick",function(...) self:OnClick_GCMissionButton(...) end)
	button.gcPANEL=bg
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
		local ignore=self.privatedb.profile.ignored

			menu[1].text=frame.info.name
			menu[2].arg1=missionID
			menu[2].arg2=followerID
			--menu[3].arg2=followerID
			local i=4
			for k,r in pairs(dbcache.ignored[missionID]) do
				if (r) then
					local v=menu[i] or {}
					v.text=self:GetFollowerData(k,'name')
					v.func=func2
					v.arg1=missionID
					v.arg2=k
					menu[i]=v
					i=i+1
				else
					dbcache.ignored[missionID]=nil
				end
			end
			if (i>4) then
				i=i+1
				menu[i]={text=ALL,func=func2,arg1=missionID,arg2='all'}
			end
			for x=#menu,i,-1 do tremove(menu) end
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
function addon:OnClick_GarrisonMissionButton(tab,button)
	trace("Clicked")
	if (tab.fromFollowerPage) then
		GarrisonMissionFrame_SelectTab(1)
	end
end
function addon:OnClick_GCMissionButton(frame,button)
	if (button=="RightButton") then
		self:HookedGarrisonMissionButton_SetRewards(frame:GetParent(),{},0)
		_G.DBG=frame.button.info.missionID
	else
		frame.button:Click()
	end
end

function addon:HookedGarrisonMissionButton_SetRewards(button,rewards,numRewards)
	if (not button or not button.Title) then
--[===[@debug@
		error(strconcat("Called on I dunno what ",tostring(button)," ", tostring(button:GetName())))
		return
--@end-debug@]===]
	end
	--if (self:IsRewardPage()) then return end
	local tw=button:GetWidth()-165
	if ( button.Title:GetWidth() + button.Summary:GetWidth() + 8 < tw - numRewards * 65 ) then
		button.Title:SetPoint("LEFT", 165, 0);
		button.Summary:ClearAllPoints();
		button.Summary:SetPoint("BOTTOMLEFT", button.Title, "BOTTOMRIGHT", 8, 0);
	else
		button.Title:SetPoint("LEFT", 165, 10);
		button.Title:SetWidth(tw - numRewards * 65);
		button.Summary:ClearAllPoints();
		button.Summary:SetPoint("TOPLEFT", button.Title, "BOTTOMLEFT", 0, -4);
	end
	button.LocBG:SetPoint("LEFT")
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
			elseif (reward.itemID and reward.quantity==1) then
				local _,_,q,i=GetItemInfo(reward.itemID)
				local c=ITEM_QUALITY_COLORS[q]
				if (not c) then c={r=1,g=1,b=1} end
				Reward.Quantity:SetText(i)
				Reward.Quantity:SetTextColor(c.r,c.g,c.b)
				Reward.Quantity:Show()
			end
			index=index+1
		end
	end
	if (button.fromFollowerPage) then
		--button.Title:ClearAllPoints()
		--button.Title:SetPoint("TOPLEFT",165,-5)
		--button.Summary:ClearAllPoints()
		--button.Summary:SetPoint("BOTTOMLEFT",165,5)
		--button:SetHeight(70)
		return
	end
	local width=GMF.MissionTab.MissionList.showInProgress and BIGBUTTON or SMALLBUTTON
	button:SetWidth(width)
	if (not button.gcPANEL) then
		self:BuildExtraButton(button)
	end
	local panel=button.gcPANEL
	local missionInfo=button.info
	local missionID=missionInfo.missionID
	if (GMF.MissionTab.MissionList.showInProgress) then
		if (not button.inProgressFresh) then
			local perc=select(4,G.GetPartyMissionInfo(missionID))
			panel.Percent:SetFormattedText(GARRISON_MISSION_PERCENT_CHANCE,perc)
			panel.Age:Hide()
			local q=self:GetDifficultyColor(perc)
			panel.Percent:SetTextColor(q.r,q.g,q.b)
			button.inProgressFresh=true
			for i=1,3 do
				local frame=panel.Party[i]
				if (missionInfo.followers[i]) then
					self:FillFollowerButton(frame,missionInfo.followers[i],missionID)
					frame:Show()
				else
					frame:Hide()
				end
			end
		end
		return
	end
	button.inProgressFresh=false
	local mission=self:GetMissionData(missionID)
	local party=parties[missionID]
	if (#party.members==0) then
		self:FillCounters(missionID,mission)
		self:MatchMaker(missionID,mission,party)
	end
	local perc=party.perc
	local notFull=false
	for i=1,3 do
		local frame=button.gcPANEL.Party[i]
		if (i>mission.numFollowers) then
			frame:Hide()
		else
			if (party.members[i]) then
				self:FillFollowerButton(frame,party.members[i],missionID)
				frame.NotFull:Hide()
			else
				self:FillFollowerButton(frame,false)
				frame.NotFull:Show()
			end
			frame:Show()
		end
	end
	if ( mission.locPrefix ) then
		panel.LocBG:Show();
		panel.LocBG:SetAtlas(mission.locPrefix.."-List");
	else
		panel.LocBG:Hide();
	end
	panel.Percent:SetFormattedText(GARRISON_MISSION_PERCENT_CHANCE,perc)
	local q=self:GetDifficultyColor(perc)
	panel.Percent:SetTextColor(q.r,q.g,q.b)
	panel.Percent:SetWidth(80)
	panel.Percent:SetJustifyH("RIGHT")
	local age=tonumber(dbcache.seen[missionID])
	if (age) then
		local day=60*24
		age=floor((time()-age)/60)
		local days=floor(age/day)
		if (days==0) then
			local hours=floor(age/60)
			panel.Age:SetFormattedText(AGE_HOURS,hours, age  -hours*60 )
		else
			panel.Age:SetFormattedText(AGE_DAYS,days,(age-days*day)/60)
		end
	else
		panel.Age:SetText(UNKNOWN)
	end
	panel.Age:Show()
	panel.Percent:Show()
end

