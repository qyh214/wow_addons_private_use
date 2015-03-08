local me, ns = ...
local addon=ns.addon --#addon
local L=ns.L
local D=ns.D
local C=ns.C
local P=ns.party
local AceGUI=ns.AceGUI
local xprint=ns.xprint
local _G=_G
local pp=print
local HD=false
local print=ns.print
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
ns.bigscreen=true
-- Blizzard functions override support
local orig={} --#originals
local over={} --#overridden
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
local function tcopy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[tcopy(k, s)] = tcopy(v, s) end
	return res
end

local parties


local lastTab=1
local new, del, copy =ns.new,ns.del,ns.copy

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
local GARRISON_CURRENCY=GARRISON_CURRENCY
local GetMoneyString=GetMoneyString
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
local IGNORE_UNAIVALABLE_FOLLOWERS_DETAIL= GARRISON_FOLLOWER_ON_MISSION ..',' .. GARRISON_FOLLOWER_WORKING .. ' ' .. GARRISON_FOLLOWERS .. '. ' .. GARRISON_FOLLOWER_INACTIVE .. " are always ignored"
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
local GCFMissions
local GCFBusyStatus
local GameTooltip=GameTooltip
-- Want to know what I call!!
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
	__index=function(t,k) if k then rawset(t,k,{}) return t[k] end end
}
local t2={
	__index=function(t,k) if k then rawset(t,k,setmetatable({},t1)) return t[k] end end
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
		if (name and k) then rawset(t,k,name) return name else return k end
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
local function addBackdrop(f,color)
	f:SetBackdrop(backdrop)
	f:SetBackdropBorderColor(C[color or 'Yellow']())
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



--

-- These local will became conf var
-- locally upvalued, doing my best to not interfere with other sorting modules,
-- First time i am called to verride it I save it, so I give other modules a chance to hook it, too
-- Could even do a trick and secureHook it at the expense of a double sort...
local origGarrison_SortMissions
local sorters={}
sorters.EndTime=function (mission1, mission2)
	if type(mission1)~="table" or type(mission2) ~="table" then return end
	local p1=G.GetFollowerMissionTimeLeftSeconds(mission1.followers[1])
	local p2=G.GetFollowerMissionTimeLeftSeconds(mission2.followers[1])
	if (p1==p2) then
		return strcmputf8i(mission1.name, mission2.name) < 0
	else
		return p1 < p2
	end
end
sorters.Chance=function (mission1, mission2)
	if type(mission1)~="table" or type(mission2) ~="table" then return end
	local p1=addon:GetParty(mission1.missionID)
	local p2=addon:GetParty(mission2.missionID)
	if (p2.full and not p1.full) then return false end
	if (p1.full and not p2.full) then return true end
	if (p1.perc==p2.perc) then
		return strcmputf8i(mission1.name, mission2.name) < 0
	else
		return p1.perc > p2.perc
	end
end
sorters.Age=function (mission1, mission2)
	if type(mission1)~="table" or type(mission2) ~="table" then return end
	local p1=addon:GetMissionData(mission1.missionID,'offerEndTime')
	local p2=addon:GetMissionData(mission2.missionID,'offerEndTime')
	if (p1==p2) then
		return strcmputf8i(mission1.name, mission2.name) < 0
	else
		return p1 < p2
	end
end
sorters.Followers=function(mission1, mission2)
	if type(mission1)~="table" or type(mission2) ~="table" then return end
	local p1=addon:GetMissionData(mission1.missionID,'numFollowers')
	local p2=addon:GetMissionData(mission2.missionID,'numFollowers')
	if (p1==p2) then
		return strcmputf8i(mission1.name, mission2.name) < 0
	else
		return p1 < p2
	end
end
sorters.Xp=function (mission1, mission2)
	if type(mission1)~="table" or type(mission2) ~="table" then return end

	local p1=addon:GetMissionData(mission1.missionID,'globalXp')
	local p2=addon:GetMissionData(mission2.missionID,'globalXp')
	if (p1==p2) then
		return strcmputf8i(mission1.name, mission2.name) < 0
	else
		return p2 < p1
	end
end
function addon.Garrison_SortMissions_Chance(missionsList)
	xprint("Sorting on chance")
	addon:OnAllMissions(function(missionID) addon:MatchMaker(missionID) end)
	table.sort(missionsList, sorters.Chance);
end
function addon.Garrison_SortMissions_Age(missionsList)
	xprint("Sorting on age")
	addon:OnAllMissions(function(missionID) addon:MatchMaker(missionID) end)
	table.sort(missionsList, sorters.Age);
end
function addon.Garrison_SortMissions_Followers(missionsList)
	xprint("Sorting on followers")
	addon:OnAllMissions(function(missionID) addon:MatchMaker(missionID) end)
	table.sort(missionsList, sorters.Followers);
end
function addon.Garrison_SortMissions_Xp(missionsList)
	xprint("Sorting on xp")
	addon:OnAllMissions(function(missionID) addon:MatchMaker(missionID) end)
	table.sort(missionsList, sorters.Xp);
end
function addon.Garrison_SortMissions_Original(missionsList)
	xprint("Sorting on original")
	addon:OnAllMissions(function(missionID) addon:MatchMaker(missionID) end)
	origGarrison_SortMissions(missionsList)
end

function addon:OnInitialized()
--[===[@debug@
	ns.xprint("OnInitialized")
	self.evdebug=CreateFrame("Frame")
	self.evdebug:SetScript("OnEvent",function(...) return print('|cffff2020event|r',...) end)
--@end-debug@]===]
	--parties=self:GetParty()
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
		Garrison_SortMissions_Age=L["Expiration Time"],
		Garrison_SortMissions_Xp=L["Global approx. xp reward"],
	},
	L["Sort missions by:"],L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"])
	ns.bigscreen=self:GetBoolean("BIGSCREEN")
	self:AddLabel("Followers Panel")
	self:AddSlider("MAXMISSIONS",5,1,8,L["Mission shown for follower"],nil,1)
	self:AddSlider("MINPERC",50,0,100,L["Minimun chance success under which ignore missions"],nil,5)
	self:AddToggle("ILV",true,L["Show weapon/armor level"],L["When checked, show on each follower button weapon and armor level for maxed followers"])
	self:AddToggle("IXP",true,L["Show xp to next level"],L["When checked, show on each follower button missing xp to next level"])
	--self:AddPrivateAction("ShowMissionControl",L["Mission control"],L["You can choose some criteria and have GC autosumbit missions for you"])
--[===[@debug@
	self:AddLabel("Developers options")
	self:AddToggle("DBG",false, "Enable Debug")
	self:AddToggle("TRC",false, "Enable Trace")
--@end-debug@]===]
	self:Trigger("MSORT")
	LoadAddOn("GarrisonCommander-Broker")
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
		self:RefreshMissions()
	end
end
function addon:ApplyIGM(value)
	self:RefreshMissions()
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
	self:RefreshMissions()
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
	self:RefreshMissions()
end
function addon:ApplyMSORT(value)
	ns.xprint("Sorting by ",value)
	if (not origGarrison_SortMissions) then
		origGarrison_SortMissions=Garrison_SortMissions
	end
	local func=self[value]
	if (type(func)=="function") then
		_G.Garrison_SortMissions=self[value]
	else
		print("Could not found ",value," in addon")
		_G.Garrison_SortMissions=origGarrison_SortMissions
	end
	self:RefreshMissions()
end
function addon:ApplyMAXMISSIONS(value)
	MAXMISSIONS=value
	BUSY_MESSAGE=format(BUSY_MESSAGE_FORMAT,MAXMISSIONS,MINPERC)
end
function addon:ApplyMINPERC(value)
	MINPERC=value
	BUSY_MESSAGE=format(BUSY_MESSAGE_FORMAT,MAXMISSIONS,MINPERC)
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
					if (tContains(self:GetParty(missionID).members,follower.followerID)) then
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
function addon:SetThreatColor(obj,threat)
	if type(threat)=="string" then
		local _,_,bias,follower,name=strsplit(":",threat)
		local color=self:GetBiasColor(tonumber(bias) or -1,nil,"Green")
		local c=C[color]
		obj.Border:SetVertexColor(c())
	else
		obj.Border:SetVertexColor(C.red())
	end

end

function addon:HookedGarrisonMissionButton_AddThreatsToTooltip(missionID)
	if (GMC:IsShown()) then return end
	return self:RenderTooltip(missionID)
end
function addon:AddFollowersToTooltip(missionID)
	--local f=GarrisonMissionListTooltipThreatsFrame
	-- Adding All available followers
	local party=self:GetParty(missionID)
	local members=party.members
	local partystring=strjoin("|",tostringall(unpack(members)))
	GameTooltip:AddLine(L["Other useful followers"])
	for followerID,_ in pairs(G.GetFollowersTraitsForMission(missionID)) do
		if not tContains(members,followerID) and G.GetFollowerBiasForMission(missionID,followerID) > -0.1 then
			GameTooltip:AddDoubleLine(self:GetFollowerData(followerID,'fullname','none'),self:GetFollowerStatus(followerID,true,true))
		end
	end
	GameTooltip:AddLine("---------------------------------------")
	for followerID,_ in pairs(G.GetBuffedFollowersForMission(missionID)) do
		if not tContains(members,followerID) and G.GetFollowerBiasForMission(missionID,followerID) > -0.1 then
			GameTooltip:AddDoubleLine(self:GetFollowerData(followerID,'fullname','none'),self:GetFollowerStatus(followerID,true,true))
		end
	end
	local perc=party.perc
	local q=self:GetDifficultyColor(perc)
	GameTooltip:AddDoubleLine(GARRISON_MISSION_SUCCESS,format(GARRISON_MISSION_PERCENT_CHANCE,perc),nil,nil,nil,q.r,q.g,q.b)
	for _,i in pairs (dbcache.ignored[missionID]) do
		GameTooltip:AddLine(L["You have ignored followers"])
		break;
	end
	if party.goldMultiplier>1 and party.class=='gold' then
		GameTooltip:AddDoubleLine(L["Gold incremented!"],party.goldMultiplier..'x',C.Green())
	end
	if party.materialMultiplier>1 and party.class == 'resources' then
		GameTooltip:AddDoubleLine(L["Resource incremented!"],party.materialMultiplier..'x',C.Green())
	end
	if party.xpBonus>0 then
		GameTooltip:AddDoubleLine(L["Xp incremented!"],'+'..party.xpBonus,C.Green())
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
function addon:RefreshMissions(missionID)
	GarrisonMissionList_UpdateMissions()
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
function addon:SetDbDefaults(default)
	default.global=default.global or {}
	default.global["*"]={}
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
				missionControl={
					allowedRewards = {
						followerEquip=true,
						gold=true,
						equip=true,
						resources=true,
						xp=true
					},
					rewardChance={
						followerEquip=100,
						gold=100,
						equip=100,
						resources=100,
						xp=100
					},
					useOneChance=true,
					itemPrio = {},
					minimumChance = 100,
					minDuration = 0,
					maxDuration = 24,
					epicExp = false,
					skipRare=true,
					skipEpic=true
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
	cache.running=nil
	cache.runningIndex=nil
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
	ns.xprint(event,...)
--@end-debug@]===]
	if (GCF) then GCF:Show() end
end
function addon:EventGARRISON_MISSION_NPC_CLOSED(event,...)
--[===[@debug@
	ns.xprint(event,...)
--@end-debug@]===]
	if (GCF) then
		self:RemoveMenu()
		GCF:Hide()
	end
end
function addon:EventGARRISON_MISSION_LIST_UPDATE(event)
	local n=0
	for _,k in pairs(event) do n=n+1 end
	ns.xprint("GARRISON_MISSION_LIST_UPDATE",n,date("%d/%m/%y %H:%M:%S"))
	local t=new()
	G.GetAvailableMissions(t)
	local now=time()
	for i=1,#t do
		local missionID=t[i].missionID
		if (not tonumber(db.seen[missionID])) then db.seen[missionID]=now end
	end
	del(t)
end
---
--@param #string event GARRISON_MISSION_STARTED
--@param #number missionID Numeric mission id
-- After this events fires also GARRISON_MISSION_LIST_UPDATE and GARRISON_FOLLOWER_LIST_UPDATE

function addon:EventGARRISON_MISSION_STARTED(event,missionID,...)
--[===[@debug@
	ns.xprint(event,missionID,...)
--@end-debug@]===]
	wipe(dbcache.ignored[missionID])
	local party=self:GetParty(missionID)
	wipe(party.members) -- I remove preset party, so PartyCache will refill it with the ones from the actual mission
	local v=dbcache.seen[missionID]
	local span=time()-(tonumber(v) or time())
	if (span > db.lifespan[missionID]) then
		db.lifespan[missionID]=span
		-- IF we started it.. it was alive, so it's expire time is at least the time we waited before starting it
	end
	dbcache.seen[missionID]=nil
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
	ns.xprint(event,missionID,...)
	ns.xdump(G.GetPartyMissionInfo(missionID))
--@end-debug@]===]
end
function addon:EventGARRISON_FOLLOWER_LIST_UPDATE(event)
--We need to update all followers, maybe this could be done in an onupdate handle
end

function addon:EventGARRISON_MISSION_BONUS_ROLL_LOOT(event,missionID,completed,success)
--[===[@debug@
	ns.xprint('evt',event,missionID,completed,success)
--@end-debug@]===]
	self:RefreshFollowerStatus()
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
--GARRISON_MISSION_BONUS_ROLL_LOOY missionID nil
--
function addon:EventGARRISON_MISSION_COMPLETE_RESPONSE(event,missionID,completed,rewards)
--[===[@debug@
	ns.xprint('evt',event,missionID,completed,rewards)
--@end-debug@]===]
	dbcache.history[missionID][time()]={result=100,success=rewards}
	dbcache.seen[missionID]=nil
	dbcache.seen[missionID]=nil
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

local MPShown=nil
-- Keeping it as a nice example of coroutine management.. but not using it anymore
function addon:Clock()
	if (GMFMissions.showInProgress)	 then
		--collectgarbage("collect") --while I fix it....
	else
		--collectgarbage("step",100)
	end
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
			button:SetScript("OnLeave",ns.OnLeave)
		else
			button:SetScript("OnLeave",ns.OnLeave)
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
	local FOLLOWER_STATUS_FORMAT=(ns.bigscreen and "Followers status " or "" )..
								C(AVAILABLE..':%d ','green') ..
								C(GARRISON_FOLLOWER_WORKING .. ":%d ",'cyan') ..
								C(GARRISON_FOLLOWER_ON_MISSION .. ":%d ",'red') ..
								C(GARRISON_FOLLOWER_INACTIVE .. ":%d","silver")
	function addon:RefreshFollowerStatus()

		wipe(s)
		for _,followerID in self:GetFollowerIterator() do
			local status=self:GetFollowerStatus(followerID)
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
	ns.xprint("Click1")
	--if ns.missionautocompleting then return end
	ns.xprint("Click2")
	if (not GMC:IsShown()) then
		GarrisonMissionFrame_SelectTab(999)
		GMF.FollowerTab:Hide()
		GMF.FollowerList:Hide()
		GMF.MissionTab:Hide()
		GMF.TitleText:SetText("Garrison Commander Mission Control")
		GMC:Show()
		GMC.startButton:Click()
		GMF.tabMC:SetChecked(true)
	else
		GMC:Hide()
		GMF.tabMC:SetChecked(false)
		GarrisonMissionFrame_SelectTab(1)
	end
end
local helpwindow -- pseudo static
function addon:ShowHelpWindow(button)
	if (not helpwindow) then
		helpwindow=CreateFrame("Frame",nil,GCF)
		helpwindow:EnableMouse(true)
		helpwindow:SetBackdrop(backdrop)
		helpwindow:SetBackdropColor(1,1,1,1)
		helpwindow:SetFrameStrata("TOOLTIP")
		helpwindow:Show()
		local html=CreateFrame("SimpleHTML",nil,helpwindow)
		html:SetFontObject('h1',MovieSubtitleFont);
		local f=GameFontNormalLarge
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
do
local generated
function addon:GenerateContainer()
	if generated then return end
	generated=true
	do
		local Type="GCGUIContainer"
		local Version=1
		local m={}
		function m:OnAcquire()
			self.frame:EnableMouse(true)
			self:SetTitleColor(C.Yellow())
			self.frame:SetFrameStrata("HIGH")
			self.frame:SetFrameLevel(999)
		end
		function m:SetContentWidth(x)
			self.content:SetWidth(x)
		end
		local function Constructor()
			local frame=CreateFrame("Frame",nil,nil,"GarrisonUITemplate")
			for _,f in pairs({frame:GetRegions()}) do
				if (f:GetObjectType()=="Texture" and f:GetAtlas()=="Garr_WoodFrameCorner") then f:Hide() end
			end
			local widget={frame=frame,missions={}}
			widget.type=Type
			widget.SetTitle=function(self,...) self.frame.TitleText:SetText(...) end
			widget.SetTitleColor=function(self,...) self.frame.TitleText:SetTextColor(...) end
			for k,v in pairs(m) do widget[k]=v end
			frame:SetScript("OnHide",function(self) self.obj:Fire('OnClose') end)
			frame.obj=widget
			--Container Support
			local content = CreateFrame("Frame",nil,frame)
			widget.content = content
			--addBackdrop(content,'Green')
			content.obj = widget
			content:SetPoint("TOPLEFT",25,-25)
			content:SetPoint("BOTTOMRIGHT",-25,25)
			AceGUI:RegisterAsContainer(widget)
			return widget
		end
		AceGUI:RegisterWidgetType(Type,Constructor,Version)
	end
end
end
function addon:GenerateMissionContainer()
	do
		local Type="GMCLayer"
		local Version=1
		local function OnRelease(self)
			wipe(self.childs)
		end
		local m={}
		function m:OnAcquire()
			self.frame:SetParent(UIParent)
			self.frame:SetFrameStrata("HIGH")
			self.frame:SetHeight(50)
			self.frame:SetWidth(100)
			self.frame:Show()
			self.frame:SetPoint("LEFT")
		end
		function m:Show()
			return self.frame:Show()
		end
		function m:Hide()
			self.frame:Hide()
			self:Release()
		end
		function m:SetScript(...)
			return self.frame:SetScript(...)
		end
		function m:SetParent(...)
			return self.frame:SetParent(...)
		end
		function m:PushChild(child,index)
			self.childs[index]=child
			self.scroll:AddChild(child)
		end
		function m:RemoveChild(index)
			local child=self.childs[index]
			if (child) then
				self.childs[index]=nil
				child:Hide()
				self:DoLayout()
			end
		end
		function m:ClearChildren()
			wipe(self.childs)
			self:AddScroll()
		end
		function m:AddScroll()
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
			for k,v in pairs(m) do widget[k]=v end
			frame:SetScript("OnHide",function(self) self.obj:Fire('OnClose') end)
			--Container Support
			local content = CreateFrame("Frame",nil,frame)
			widget.content = content
			content.obj = self
			content:SetPoint("TOPLEFT",title,"BOTTOMLEFT")
			content:SetPoint("BOTTOMRIGHT")
			AceGUI:RegisterAsContainer(widget)
			return widget
		end
		AceGUI:RegisterWidgetType(Type,Constructor,Version)
	end
end

function addon:GenerateMissionButton()
	do
		local Type1="GMCMissionButton"
		local Type2="GMCSlimMissionButton"
		local Version=1
		local unique=0
		local m={}
		function m:OnAcquire()
			local frame=self.frame
			frame.info=nil
			frame:SetHeight(self.type==Type1 and 80 or 80)
			frame:SetAlpha(1)
			frame:Enable()
			for i=1,#self.scripts do
				frame:SetScript(self.scripts[i],nil)
			end
			for i=1,#frame.Rewards do
				frame.Rewards[i].Icon:SetDesaturated(false)
			end
			wipe(self.scripts)
			return self.frame:SetScale(1.0)
		end
		function m:Show()
			return self.frame:Show()
		end
		function m:SetHeight(h)
			return self.frame:SetHeight(h)
		end
		function m:Hide()
			self.frame:SetHeight(1)
			self.frame:SetAlpha(0)
			return self.frame:Disable()
		end
		function m:SetScript(name,method)
			tinsert(self.scripts,name)
			return self.frame:SetScript(name,method)
		end
		function m:SetScale(s)
			return self.frame:SetScale(s)
		end
		function m:SetMission(mission,party)
			self.frame.info=mission
			self.frame.fromFollowerPage=true
			self.frame:EnableMouse(true)
			self.frame.party=party
			if self.type==Type1 then
				addon:DrawSingleButton(false,self.frame,false,false)
				self.frame:SetScript("OnEnter",GarrisonMissionButton_OnEnter)
				self.frame:SetScript("OnLeave",ns.OnLeave)
			else
				addon:DrawSingleSlimButton(false,self.frame,false,false)
				self.frame:SetScript("OnEnter",nil)
				self.frame:SetScript("OnLeave",nil)
			end
			if self.type==Type2 then
				self.frame.Percent:SetFormattedText("%d%%",party.perc)
				self.frame.Percent:SetTextColor(addon:GetDifficultyColors(party.perc))
				_G.AX=self.frame
			end
		end

		local function Constructor()
			unique=unique+1
			local frame=CreateFrame("Button",nil,nil,"GarrisonMissionListButtonTemplate") --"GarrisonCommanderMissionListButtonTemplate")
			frame.Title:SetFontObject("QuestFont_Shadow_Small")
			frame.Summary:SetFontObject("QuestFont_Shadow_Small")
			frame:SetScript("OnEnter",nil)
			frame:SetScript("OnLeave",nil)
			frame:SetScript("OnClick",function(self,button) return self.obj:Fire("OnClick",self,button) end)
			frame.LocBG:SetPoint("LEFT")
			frame.MissionType:SetPoint("TOPLEFT",5,-2)
			--[[
			frame.members={}
			for i=1,3 do
				local f=CreateFrame("Button",nil,frame,"GarrisonCommanderMissionPageFollowerTemplateSmall" )
				frame.members[i]=f
				f:SetPoint("BOTTOMRIGHT",-65 -65 *i,5)
				f:SetScale(0.8)
			end
			--]]
			local widget={}
			setmetatable(widget,{__index=frame})
			widget.frame=frame
			widget.scripts={}
			frame.obj=widget
			for k,v in pairs(m) do widget[k]=v end
			return widget
		end
		local function Constructor1()
			local widget=Constructor()
			widget.type=Type1
			return AceGUI:RegisterAsWidget(widget)
		end
		local function Constructor2()
			local widget=Constructor()
			local frame=widget.frame
			widget.type=Type2
			local indicators=CreateFrame("Frame",nil,frame,"GarrisonCommanderIndicators")
			indicators.Percent:SetJustifyH("LEFT")
			indicators.Percent:SetJustifyV("CENTER")
			indicators:SetPoint("LEFT",70,0)
			indicators.Age:Hide()
			frame.Indicators=indicators
			frame.Percent=indicators.Percent
			frame.Failure=frame:CreateFontString()
			frame.Success=frame:CreateFontString()
			frame.Failure:SetFontObject("GameFontRedLarge")
			frame.Success:SetFontObject("GameFontGreenLarge")
			frame.Failure:SetText(FAILED)
			frame.Success:SetText(SUCCESS)
			frame.Failure:Hide()
			frame.Success:Hide()
			frame.Title:SetPoint("TOPLEFT",frame.Indicators,"TOPRIGHT",0,0)
			frame.Success:SetPoint("BOTTOMLEFT",frame.Indicators,"BOTTOMRIGHT",0,10)
			frame.Failure:SetPoint("BOTTOMLEFT",frame.Indicators,"BOTTOMRIGHT",0,10)

			--widget.frame.MissionType:Hide()
			--widget.frame.IconBG:Hide()
			return AceGUI:RegisterAsWidget(widget)
		end
		AceGUI:RegisterWidgetType(Type1,Constructor1,Version)
		AceGUI:RegisterWidgetType(Type2,Constructor2,Version)

	end
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
	local signature=me .. " " .. self.version
	GCF.Signature:SetText(signature)
	-- Removing wood corner. I do it here to not derive an xml frame. This shoud play better with ui extensions
	GCF.CloseButton:Hide()
	for _,f in pairs({GCF:GetRegions()}) do
		if (f:GetObjectType()=="Texture" and f:GetAtlas()=="Garr_WoodFrameCorner") then f:Hide() end
	end
	GCF:SetFrameStrata(GMF:GetFrameStrata())
	GCF:SetFrameLevel(GMF:GetFrameLevel()-2)
	if (not ns.bigscreen) then GCF:SetHeight(GCF:GetHeight()+35) end
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
	if (ns.bigscreen) then
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
	ns.xprint("Triggered " .. C(hook,"red").." script on",C(frame,"Azure"),...)
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
	return GMF:IsShown() and GMFMissions.CompleteDialog:IsShown()

end
function addon:IsMissionPage()
	return GMF:IsShown() and GMFMissionPage:IsShown() and GMFFollowers:IsShown()
end
---
-- Switches between missions (1) and followers (others) panels
function addon:HookedGarrisonMissionFrame_SelectTab(id)
	GMC:Hide()
	GMF.tabMC:SetChecked(false)
	self:RefreshFollowerStatus()
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
	xprint("Complete missions closed")
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
	return self:RenderFollowerPageFollowerButton(frame,follower,showCounters)
end
function addon:RenderFollowerPageFollowerButton(frame,follower,showCounters)
	if not frame.GCIt then
		frame.GCIt=frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
		frame.GCIt:SetPoint("BOTTOMLEFT",frame.Name,"TOPLEFT",0,2)
		frame.GCXp=frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
	end
	if not frame.isCollected then
		frame.GCXp:Hide()
		frame.GCIt:Hide()
		return
	end
	if self:GetToggle("IXP") then
		if (follower.level < GARRISON_FOLLOWER_MAX_LEVEL or follower.quality < GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY) then
			frame.GCXp:SetFormattedText(L["To go: %d"],follower.levelXP-follower.xp)
			frame.GCXp:Show()
		else
			frame.GCXp:Hide()
		end
	end
	if self:GetToggle("ILV") then
		if (follower.level >= GARRISON_FOLLOWER_MAX_LEVEL) then
			local c1=ITEM_QUALITY_COLORS[follower.weaponQuality or 1]
			local c2=ITEM_QUALITY_COLORS[follower.armorQuality or 1]
			frame.GCIt:SetFormattedText("W:%s%3d|r A:%s%3d|r",c1.hex,self:GetFollowerData(follower.followerID,"weaponItemLevel"),c2.hex,self:GetFollowerData(follower.followerID,"armorItemLevel"))
			frame.GCIt:Show()
			frame.GCXp:SetPoint("LEFT",frame.GCIt,"RIGHT",2,0)
		else
			frame.GCIt:Hide()
			frame.GCXp:SetPoint("LEFT",frame.Name,"LEFT",0,20)
		end
	end
end
function addon:HookedGarrisonFollowerListButton_OnClick(frame,button)
	if (frame.info.isCollected) then
		if (button=="LeftButton") then
			if (ns.bigscreen and frame and frame.info and frame.info.followerID)  then self:HookedGarrisonFollowerPage_ShowFollower(frame.info,frame.info.followerID) end
		end
		self:ScheduleTimer("HookedGarrisonFollowerButton_UpdateCounters",0.2,frame,frame.info,false)
	end
end
-- Shamelessly stolen from Blizzard Code
local fakepage={newMissionIDs={}}
function addon:BuildMissionButton(button,gmc,...)
	if true then return self:DrawSingleButton(fakepage,button,false,false) end
	local mission=button.info
	if (not mission or not mission.name) then
		if (button.missionID) then
			mission=self:GetMissionData(button.missionID)
		end
	end
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
	if (not mission) then return end
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
function addon.ClonedGarrisonMissionMechanic_OnEnter(this)
	local tip=GameTooltip
	local button=this:GetParent()
	tip:SetOwner(button, "ANCHOR_CURSOR_RIGHT");
	tip:AddLine(this.Name,C.White())
	tip:AddTexture(this.Icon:GetTexture())
	tip:AddLine(this.Description,C.Orange())
	tip:Show()
end
function addon:HookedGarrisonFollowerPage_ShowFollower(frame,followerID,force)
	return self:RenderFollowerPageMissionList(frame,followerID,force)
end
do
	local Busystatusmessage
	local lastFollowerID=""
	local ml=nil
	local partyIndex={}
	local tContains=tContains
	local function MissionOnClick(this,...)
		GarrisonMissionButton_OnClick(this.frame,"LeftUp")
		if (PanelTemplates_GetSelectedTab(GMF) ~= 1) then
			addon:OpenMissionsTab()
		end
		addon:OnClick_GarrisonMissionButton(this.frame,"Leftup")
		lastTab=2
	end
	function addon:RenderFollowerPageMissionList(frame,followerID,force)
		if not ns.bigscreen then return end
		if not GMFFollowers:IsShown() then return end
		if (not ml) then
			ml=AceGUI:Create("GMCLayer")
			ml:SetTitle("Ninso")
			ml:SetTitleColor(C.Orange())
			ml:SetTitleHeight(40)
			ml:SetParent(GMFFollowers)
			ml:Show()
			ml:ClearAllPoints()
			ml:SetWidth(200)
			ml:SetHeight(600)
			ml:SetPoint("TOP",GCFMissions.Header,"BOTTOM")
			ml:SetPoint("LEFT",GMFFollowers,"RIGHT")
			ml:SetPoint("RIGHT",GMF.FollowerTab,"LEFT")
			ml:SetPoint("BOTTOM",GMF,0,25)
		end
		self:RenderFollowerButton(GCFMissions.Header,followerID)
		ml:ClearChildren()
		if (type(frame.followerID)=="number") then
			ml:SetTitle(NOT_COLLECTED)
			ml:SetTitleColor(C.Silver())
			return
		end
		local status=self:GetFollowerStatus(followerID,true)
		ml:SetTitle(status)
		if (status==GARRISON_FOLLOWER_WORKING) then
			ml:SetTitleColor(C.Cyan())
			return
		elseif (status==AVAILABLE) then
			ml:SetTitleColor(C.Green())
		else
			ml:SetTitleColor(C.Red())
			return
		end
		wipe(partyIndex)
		local parties=self:GetParty()
		for missionID,party in pairs(parties) do
			if (tContains(party.members,followerID)) then ns.xprint("Found mission",missionID) tinsert(partyIndex,missionID) end
		end
		table.sort(partyIndex,function(a,b) return parties[a].perc > parties[b].perc end)
		for i=1,#partyIndex do
			local missionID=partyIndex[i]
			local party=parties[missionID]
			local mission=self:GetMissionData(missionID)
			if (mission) then
				local mb=AceGUI:Create("GMCMissionButton")
				mb:SetScale(0.6)
				ml:PushChild(mb,missionID)
				mb:SetFullWidth(true)
				mb:SetMission(mission,party)
				mb:SetCallback("OnClick",MissionOnClick)
			end
		end
	end
end
---
--Initial one time setup
function addon:SetUp(...)
	self:FollowerCacheInit()
--[===[@debug@
	ns.dprint("Setup")
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
	GMC=self:GMCBuildPanel(ns.bigscreen)
	local tabMC=CreateFrame("CheckButton",nil,GMF,"SpellBookSkillLineTabTemplate")
	GMF.tabMC=tabMC
	tabMC.tooltip="Open Garrison Commander Mission Control"
	--tab:SetNormalTexture("World\\Dungeon\\Challenge\\clockRunes.blp")
	--tab:SetNormalTexture("Interface\\Timer\\Challenges-Logo.blp")
	tabMC:SetNormalTexture("Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_WORKINGOVERTIME.blp")
	self:MarkAsNew(tabMC,'MissionControl','New in 2.2.0! Try automatic mission management!')
	tabMC:Show()
	GMF.FollowerStatusInfo=GMF:CreateFontString(nil, "BORDER", "GameFontNormal")
	GMF.FollowerStatusInfo:SetPoint("TOPRIGHT",-30,-5)
	local tabCF=CreateFrame("Button",nil,GMF,"SpellBookSkillLineTabTemplate")
	GMF.tabCF=tabCF
	tabCF.tooltip="Open Garrison Commander Configuration Screen"
	tabCF:SetNormalTexture("Interface\\ICONS\\Trade_Engineering.blp")
	tabCF:SetPushedTexture("Interface\\ICONS\\Trade_Engineering.blp")
	tabCF:Show()
	local tabHP=CreateFrame("Button",nil,GMF,"SpellBookSkillLineTabTemplate")
	GMF.tabHP=tabHP
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
	local ref=GMFMissions.CompleteDialog.BorderFrame.ViewButton
	local bt = CreateFrame('BUTTON',nil, ref, 'UIPanelButtonTemplate')
	bt:SetWidth(300)
	bt:SetText(L["Garrison Comander Quick Mission Completion"])
	bt:SetPoint("CENTER",0,-50)
	addon:ActivateButton(bt,"MissionComplete","Complete all missions without confirmation")
	return self:StartUp()
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
	frame:SetParent(GCF)
	frame:SetFrameStrata(GCF:GetFrameStrata())
	frame:SetFrameLevel(GCF:GetFrameLevel()+2)
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
	ns.dprint("Startup")
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
	--self:SafeSecureHook("GarrisonMissionButton_AddThreatsToTooltip")
	self:SafeSecureHook("GarrisonFollowerListButton_OnClick") -- used both to update follower mission list and itemlevel display
	if (ns.bigscreen) then
		self:SafeSecureHook("GarrisonFollowerPage_ShowFollower")--,function(...) ns.xprint("GarrisonFollowerPage_ShowFollower",...) end)
		self:SafeSecureHook("GarrisonFollowerTooltipTemplate_SetGarrisonFollower")
	end
	self:SafeSecureHook("GarrisonMissionFrame_HideCompleteMissions")	-- Mission reward completed
	self:SafeSecureHook("GarrisonMissionPage_ShowMission")
	self:SafeSecureHook("GarrisonMissionFrame_SelectTab")
	-- GarrisonMissionList_SetTab is overrided

	self:SafeHookScript(GMFMissions,"OnShow")--,"GrowPanel")
	self:SafeHookScript(GMFFollowers,"OnShow")--,"GrowPanel")
	self:SafeHookScript(GCF,"OnHide","CleanUp",true)
	self:SafeHookScript(GMF.FollowerTab,"OnShow","OnShow_FollowerPage",true)

	-- Mission management
	self:SafeHookScript(GMF.MissionComplete.NextMissionButton,"OnClick","OnClick_GarrisonMissionFrame_MissionComplete_NextMissionButton",true)
	-- Hooking mission buttons on click
	for i=1,#GMFMissionListButtons do
		local b=GMFMissionListButtons[i]
		self:SafeHookScript(b,"OnClick","OnClick_GarrisonMissionButton",true)
	end
	--self:ScheduleRepeatingTimer("Clock",1)
	self:RefreshFollowerStatus()
	self:Trigger("MSORT")
	self:Trigger("CKMP")
	GMFMissions.listScroll.update = over.GarrisonMissionList_Update
	return self:RefreshMissions()
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
	self:SafeRegisterEvent("GARRISON_MISSION_FINISHED")
	self:SafeRegisterEvent("GARRISON_MISSION_BONUS_ROLL_LOOT")
	self:SafeRegisterEvent("GARRISON_MISSION_NPC_CLOSED")
	self:SafeRegisterEvent("GARRISON_FOLLOWER_XP_CHANGED")
	self:SafeRegisterEvent("GARRISON_FOLLOWER_ADDED")
	self:SafeRegisterEvent("GARRISON_FOLLOWER_REMOVED")
	self:RegisterBucketEvent("GARRISON_MISSION_LIST_UPDATE",2,"EventGARRISON_MISSION_LIST_UPDATE")
	self:SafeRegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
	-- Follower button enhancement in follower list
	self:SafeSecureHook("GarrisonFollowerButton_UpdateCounters")
end
function addon:checkMethod(method,hook)
	if (type(self[method])=="function") then
--[===[@debug@
		--ns.xprint("Hooking ",hook,"to self:" .. method)
--@end-debug@]===]
		return true
--[===[@debug@
	else
		--ns.xprint("Hooking ",hook,"to print")
--@end-debug@]===]
	end
end
function addon:SafeRegisterEvent(event)
--[===[@debug@
	if not self.evdebug:IsEventRegistered(event) then
		self.evdebug:RegisterEvent(event)
	end
--@end-debug@]===]
	local method="Event"..event
	if (self:checkMethod(method,event)) then
		return self:RegisterEvent(event,method)
--[===[@debug@
	else
		return self:RegisterEvent(event,ns.xprint)
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
			return self:SecureHook(tobehooked,function(...) ns.xprint(hooked,...) end)
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
	ns.xprint("Cleaning up")
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
			self:RecalculateFollower(follower)
			return -- single updated
		end
	end
	wipe(followersCache)
	self:GetFollowerData(followerID)  -- triggering a full cache refresh
end
function addon:IsFollowerAvailableForMission(followerID,skipbusy)
	if self:GMCBusy(followerID) then
		return false
	end
	if (not skipbusy) then
		return self:GetFollowerStatus(followerID) ~= GARRISON_FOLLOWER_WORKING
	else
		return self:GetFollowerStatus(followerID) == AVAILABLE
	end
end

function addon:GetFollowerStatus(followerID,withTime,colored)
	--C_Garrison.GetFollowerMissionTimeLeftSeconds(follower.followerID)
	if (not followerID) then return UNAVAILABLE end
	local status=G.GetFollowerStatus(followerID)
	if (status and status== GARRISON_FOLLOWER_ON_MISSION and withTime) then
		status=G.GetFollowerMissionTimeLeft(followerID)
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
	if type(missionInfo)=="number" then missionInfo=self:GetMissionData(missionInfo) end
	if not missionInfo then return end
	if( IsControlKeyDown()) then ns.xprint("Shift key, ignoring mission prefill") return end
	if (self:GetBoolean("NOFILL")) then return end
	local missionID=missionInfo.missionID
--[===[@debug@
	ns.xprint("UpdateMissionPage for",missionID,missionInfo.name,missionInfo.numFollowers)
--@end-debug@]===]
	self:holdEvents()
	GarrisonMissionPage_ClearParty()
	local party=self:GetParty(missionID)
	if (party) then
		local members=party.members
		for i=1,missionInfo.numFollowers do
			local followerID=members[i]
			if (followerID) then
				local status=G.GetFollowerStatus(followerID)
				if (false and status) then
					if status == GARRISON_FOLLOWER_IN_PARTY then -- Left from a previous assignment?
--[===[@debug@
						ns.xprint(followerID,self:GetFollowerData(followerID,"name"),"was already on mission")
--@end-debug@]===]
						self:RemoveFromAllMissions(followerID)
						GarrisonMissionPage_AddFollower(followerID)
					else
						self:Popup("You attemped to use a busy follower. Please check '" .. IGNORE_UNAIVALABLE_FOLLOWERS .."'",10)
					end
				else
					pcall(G.RemoveFollowerFromMission,missionID,followerID)
					ns.xprint("Adding",followerID,G.GetFollowerName(followerID))
					GarrisonMissionPage_AddFollower(followerID)
				end
			end
		end
	end
	GarrisonMissionPage_UpdateParty()
	self:releaseEvents()
end
local firstcall=true

---@function GrowPanel
-- Enforce the new panel sizes
--
function addon:GrowPanel()
	GCF:Show()
	if (ns.bigscreen) then
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
function addon:RenderFollowerButton(frame,followerID,missionID,b,t)
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
	frame:EnableMouse(true)
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
	GarrisonMissionFrame_SetFollowerPortrait(frame.PortraitFrame, info, false);
	-- Counters icon
	if (frame.Name and frame.Threats) then
		if (missionID and not GMFMissions.showInProgress) then
			local tohide=1
			if b and b[followerID] then
				for i=1,#b[followerID] do
					local th=frame.Threats[tohide]
					th.Icon:SetTexture(b[followerID][i].icon)
					th:Show()
					tohide=tohide+1
				end
			end
			if t and t[followerID] then
				for i=1,#t[followerID] do
					if tohide>#frame.Threats then break end
					local th=frame.Threats[tohide]
					th.Icon:SetTexture(t[followerID][i].icon)
					th:Show()
					tohide=tohide+1
				end
			end
		else
			frame.Status:Hide()
		end
	end
end
-- pseudo static
local scale=0.9

function addon:BuildFollowersButtons(button,bg,limit,bigscreen)
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
		f.missionID=button.info.missionID
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
function addon:CheckExpire(missionID)
	local age=tonumber(dbcache.seen[missionID])
	local expire=ns.wowhead[missionID]
	print("Age",date("%m/%d/%y %H:%M:%S",age))
	print("Now",date("%m/%d/%y %H:%M:%S"))
	print("Expire",expire)
	print("Age+expire",date("%m/%d/%y %H:%M:%S",age+expire))
	print("Delta",age+expire-time())
end
function addon:BuildExtraButton(button,bigscreen)

end
function addon:OnShow_FollowerPage(page)
	if not GCFMissions then return end
	ns.xprint("Onshow")
	if type(GCFMissions.Header.info)=="table" then
		self:HookedGarrisonFollowerPage_ShowFollower(page,GCFMissions.Header.info.followerID,true)
--		local s =self:GetScroller("GFCMissions.Header")
--		self:cutePrint(s,GCFMissions.Header)
	end
end
--function addon:GarrisonMissionButtHeaderon_SetRewards(button,rewards,numrewards)
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
	self:RefreshMissions(missionID)
end
function addon:UnignoreFollower(table,missionID,followerID,flag)
	if (followerID=='all') then
		wipe(dbcache.ignored[missionID])
	else
		dbcache.ignored[missionID][followerID]=nil
	end
	self:RefreshMissions(missionID)
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
	lastTab=1
	if (GMF.MissionTab.MissionList.showInProgress) then
		return
	end
	if (type(tab.info)~="table") then return end
--[===[@debug@
	ns.xprint("Clicked GarrisonMissionButton")
--@end-debug@]===]
	if (tab.fromFollowerPage) then
		if (#tab.info.followers>0) then
			return
		end
		GarrisonMissionFrame_SelectTab(1)
		self:FillMissionPage(tab.info)
	else
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

--[[
addon.oldSetUp=addon.SetUp
function addon:ExperimentalSetUp()

end
addon.SetUp=addon.ExperimentalSetUp
--]]


-- Blizzard functions override
local function override(blizfunc)
	if not orig[blizfunc] then
		orig[blizfunc]=_G[blizfunc]
		_G[blizfunc]=over[blizfunc]
	end
--[===[@debug@
	print("Overriding ",blizfunc)
--@end-debug@]===]
end
function over.StolenGarrisonMissionPageFollowerFrame_OnEnter(self)
	if not self.info then
		return;
	end

	GarrisonFollowerTooltip:ClearAllPoints();
	GarrisonFollowerTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT");
	GarrisonFollowerTooltip_Show(self.info.garrFollowerID,
		self.info.isCollected,
		C_Garrison.GetFollowerQuality(self.info.followerID),
		C_Garrison.GetFollowerLevel(self.info.followerID),
		C_Garrison.GetFollowerXP(self.info.followerID),
		C_Garrison.GetFollowerLevelXP(self.info.followerID),
		C_Garrison.GetFollowerItemLevelAverage(self.info.followerID),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 1),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 2),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 3),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 4),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 1),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 2),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 3),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 4),
		true,
		C_Garrison.GetFollowerBiasForMission(self.missionID, self.info.followerID) < 0.0
		);
end

function over.GarrisonMissionFrame_SetFollowerPortrait(portraitFrame, followerInfo, forMissionPage)
	local color = ITEM_QUALITY_COLORS[followerInfo.quality];
	portraitFrame.PortraitRingQuality:SetVertexColor(color.r, color.g, color.b);
	portraitFrame.LevelBorder:SetVertexColor(color.r, color.g, color.b);
	if ( forMissionPage ) then
		local boosted = false;
		local followerLevel = followerInfo.level;
		if ( MISSION_PAGE_FRAME.mentorLevel and MISSION_PAGE_FRAME.mentorLevel > followerLevel ) then
			followerLevel = MISSION_PAGE_FRAME.mentorLevel;
			boosted = true;
		end
		if ( MISSION_PAGE_FRAME.showItemLevel and followerLevel == GarrisonMissionFrame.followerMaxLevel ) then
			local followerItemLevel = followerInfo.iLevel;
			if ( MISSION_PAGE_FRAME.mentorItemLevel and MISSION_PAGE_FRAME.mentorItemLevel > followerItemLevel ) then
				followerItemLevel = MISSION_PAGE_FRAME.mentorItemLevel;
				boosted = true;
			end
			portraitFrame.Level:SetFormattedText(GARRISON_FOLLOWER_ITEM_LEVEL, followerItemLevel);
			portraitFrame.LevelBorder:SetAtlas("GarrMission_PortraitRing_iLvlBorder");
			portraitFrame.LevelBorder:SetWidth(70);
		else
			portraitFrame.Level:SetText(followerLevel);
			portraitFrame.LevelBorder:SetAtlas("GarrMission_PortraitRing_LevelBorder");
			portraitFrame.LevelBorder:SetWidth(58);
		end
		local followerBias = C_Garrison.GetFollowerBiasForMission(MISSION_PAGE_FRAME.missionInfo.missionID, followerInfo.followerID);
		if ( followerBias == -1 ) then
			portraitFrame.Level:SetTextColor(1, 0.1, 0.1);
		elseif ( followerBias < 0 ) then
			portraitFrame.Level:SetTextColor(1, 0.5, 0.25);
		elseif ( boosted ) then
			portraitFrame.Level:SetTextColor(0.1, 1, 0.1);
		else
			portraitFrame.Level:SetTextColor(1, 1, 1);
		end
		portraitFrame.Caution:SetShown(followerBias < 0);

	else
		portraitFrame.Level:SetText(followerInfo.level);
	end
	if ( followerInfo.displayID ) then
		GarrisonFollowerPortrait_Set(portraitFrame.Portrait, followerInfo.portraitIconID);
	end
end

function over.GarrisonMissionPage_Close(self)
	GarrisonMissionPage_ClearParty();
	GarrisonMissionFrame.MissionTab.MissionPage:Hide();
	GarrisonMissionFrame.followerCounters = nil;
	GarrisonMissionFrame.MissionTab.MissionPage.missionInfo = nil;
	if (lastTab) then
		GarrisonMissionFrame_SelectTab(lastTab)
	end
	-- I hooked this handler, so I dont want it to be called in the middle of cleanup operations
	GarrisonMissionFrame.MissionTab.MissionList:Show();
end
function over.GarrisonMissionButton_SetRewards(self, rewards, numRewards)
	if (numRewards > 0) then
		local index = 1;
		local party=self.party
		local mission=self.info
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
			Reward.Quantity:SetTextColor(C.White())
			if (reward.itemID) then
				Reward.itemID = reward.itemID;
				GarrisonMissionFrame_SetItemRewardDetails(Reward);
				if ( reward.quantity > 1 ) then
					Reward.Quantity:SetText(reward.quantity);
					Reward.Quantity:Show();
				elseif reward.itemID==120205 then
					Reward.Quantity:SetText(self.info.xp);
					Reward.Quantity:Show();
				else
					local name,link,quality,iLevel,level=GetItemInfo(reward.itemID)
					if (name) then
						Reward.Quantity:SetText(iLevel==1 and level or iLevel);
						Reward.Quantity:SetTextColor(ITEM_QUALITY_COLORS[quality].r,ITEM_QUALITY_COLORS[quality].g,ITEM_QUALITY_COLORS[quality].b)
						Reward.Quantity:Show();
					end

				end
			else
				Reward.Icon:SetTexture(reward.icon);
				Reward.title = reward.title
				if (reward.currencyID and reward.quantity) then
					if (reward.currencyID == 0) then
						local multi=party.goldMultiplier or 1
						Reward.tooltip = GetMoneyString(reward.quantity);
						Reward.Quantity:SetText(reward.quantity/10000 *multi);
						Reward.Quantity:Show();
						if multi >1 then
							Reward.Quantity:SetTextColor(C:Green())
						else
							Reward.Quantity:SetTextColor(C:Gold())
						end
					elseif (reward.currencyID == GARRISON_CURRENCY) then
						local multi=party.materialMultiplier or 1
						Reward.tooltip = GetMoneyString(reward.quantity);
						Reward.Quantity:SetText(reward.quantity * multi);
						Reward.Quantity:Show();
						if multi >1 then
							Reward.Quantity:SetTextColor(C:Green())
						else
							Reward.Quantity:SetTextColor(C:Gold())
						end
					else
						Reward.currencyID = reward.currencyID;
						Reward.Quantity:SetText(reward.quantity);
						Reward.Quantity:Show();
						Reward.Quantity:SetTextColor(C:Gold())
					end
				else
					if reward.followerXP then
						Reward.Quantity:SetText(reward.followerXP);
						Reward.Quantity:Show();
						if party.xpBonus and party.xpBonus > 0 then
							Reward.Quantity:SetTextColor(C:Green())
						else
							Reward.Quantity:SetTextColor(C:Gold())
						end
					end
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
do
	local lastcall=math.floor(GetTime()*10)
	local progressing
	function over.GarrisonMissionList_Update()
		local self = GarrisonMissionFrame.MissionTab.MissionList;
		local missions;
		if (self.showInProgress) then
			-- Ten times in a second is enough...
			local tick=math.floor(GetTime()*10)
			if (tick == lastcall) then
			else
				collectgarbage("step",500)
				lastcall=tick
				return
			end
			table.sort(self.inProgressMissions,sorters.EndTime)
			missions = self.inProgressMissions;
		else
			progressing=false
			missions = self.availableMissions;
		end
		local numMissions = #missions;
		local scrollFrame = self.listScroll;
		local offset = HybridScrollFrame_GetOffset(scrollFrame);
		local buttons = scrollFrame.buttons;
		local numButtons = #buttons;

		if (numMissions == 0) then
			self.EmptyListString:Show();
		else
			self.EmptyListString:Hide();
		end
		for i = 1, numButtons do
			dbg=i==1
			local button = buttons[i];
			local index = offset + i; -- adjust index
			if ( index <= numMissions) then
				local mission = missions[index];
				button.id = index;
				button.info = mission;
				button.party=addon:GetParty(mission.missionID)
			else
				button.id=0
				button.info=nil
				button.party=nil
			end
			addon:DrawSingleButton(self,button,false,ns.bigscreen)
		end
		local totalHeight = numMissions * scrollFrame.buttonHeight;
		local displayedHeight = numButtons * scrollFrame.buttonHeight;
		HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
	end
end
function over.GarrisonMissionPageFollowerFrame_OnEnter(self)
	if not self.info then
		return;
	end
	if ns.missionautocompleting then
		return
	end
	GarrisonFollowerTooltip:ClearAllPoints();
	GarrisonFollowerTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT");
	GarrisonFollowerTooltip_Show(self.info.garrFollowerID,
		self.info.isCollected,
		C_Garrison.GetFollowerQuality(self.info.followerID),
		C_Garrison.GetFollowerLevel(self.info.followerID),
		C_Garrison.GetFollowerXP(self.info.followerID),
		C_Garrison.GetFollowerLevelXP(self.info.followerID),
		C_Garrison.GetFollowerItemLevelAverage(self.info.followerID),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 1),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 2),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 3),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 4),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 1),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 2),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 3),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 4),
		true,
		self.missionID and self.info.followerID and
		C_Garrison.GetFollowerBiasForMission(self.missionID, self.info.followerID) < 0.0
		or false
		);
end
function over.GarrisonMissionButton_OnEnter(self, button)
	if (self.info == nil) then
		return;
	end
	collectgarbage("step",100)

	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");

	if(self.info.inProgress) then
		GarrisonMissionButton_SetInProgressTooltip(self.info)
	else
		GameTooltip:SetText(self.info.name);
		GameTooltip:AddLine(string.format(GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS, self.info.numFollowers), 1, 1, 1);
		GarrisonMissionButton_AddThreatsToTooltip(self.info.missionID);
		--if (self.info.isRare) then
		GameTooltip:AddLine(GARRISON_MISSION_AVAILABILITY);
		GameTooltip:AddLine(self.info.offerTimeRemaining, 1, 1, 1);
		if not C_Garrison.IsOnGarrisonMap() then
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(GARRISON_MISSION_TOOLTIP_RETURN_TO_START, nil, nil, nil, 1);
		end
		addon:AddFollowersToTooltip(self.info.missionID)
		GameTooltip:Show()
	end
--[===[@debug@
	GameTooltip:AddDoubleLine("MissionID",self.info.missionID)
--@end-debug@]===]
	GameTooltip:Show();
	GarrisonMissionFrame.MissionTab.MissionList.newMissionIDs[self.info.missionID] = nil
	--GarrisonMissionList_Update();
end
---@function
-- Main mission button draw routine.
-- @param page GarrisonMissionFrameMissions or nil.
-- @param button scrolllist element
-- @param progressing true if at second iteration of progress page
-- @param bigscreen enlarge button or not

function addon:DrawSingleButton(page,button,progressing,bigscreen)
	local mission=button.info
	if mission then
		local missionID=mission.missionID
		if not button.party then button.party=self:GetParty(missionID) end
		self:AddStandardDataToButton(page,button,mission,missionID,bigscreen)
		self:AddIndicatorToButton(button,mission,missionID,bigscreen)
		over.GarrisonMissionButton_SetRewards(button, mission.rewards, mission.numRewards);
		self:AddFollowersToButton(button,mission,missionID,bigscreen)
		if page and not self:IsRewardPage() then
			addon:AddThreatsToButton(button,mission,missionID,bigscreen)
		end
		local a1,f,a2,h,v=button.Title:GetPoint(1)
		if page then
			v=v+10
			button.Title:ClearAllPoints()
			button.Title:SetPoint(a1,f,a2,h,v)
		else
			v=v+20
			button.Title:ClearAllPoints()
			button.Title:SetPoint(a1,f,a2,h,v)
			button.Summary:ClearAllPoints()
			button.Summary:SetPoint("TOPLEFT",button.Title,"BOTTOMLEFT",0,-5)
		end
		button:Show();

	else
		button:Hide();
		button.info=nil
	end
end
function addon:DrawSingleSlimButton(page,button,progressing,bigscreen)
	local mission=button.info
	if mission then
		local missionID=mission.missionID
		local frame=button
		self:AddStandardDataToButton(page,button,mission,missionID,bigscreen)
		over.GarrisonMissionButton_SetRewards(button, mission.rewards, mission.numRewards);
		self:AddFollowersToButton(button,mission,missionID,bigscreen)
		frame.Title:SetPoint("TOPLEFT",frame.Indicators,"TOPRIGHT",0,-5)
		frame.Success:SetPoint("LEFT",frame.Indicators,"RIGHT",0,0)
		frame.Failure:SetPoint("LEFT",frame.Indicators,"RIGHT",0,0)
		frame.Summary:ClearAllPoints()
		frame.Summary:SetPoint("TOPLEFT",frame.Title,"BOTTOMLEFT",0,-10)
		button:Show();
	else
		button:Hide();
		button.info=nil
	end
end
function addon:AddStandardDataToButton(page,button,mission,missionID,bigscreen)
	button.Title:SetWidth(0);
	button.Title:SetText(mission.name);
	button.Level:SetText(mission.level);
	if ( mission.durationSeconds >= GARRISON_LONG_MISSION_TIME ) then
		local duration = format(GARRISON_LONG_MISSION_TIME_FORMAT, mission.duration);
		button.Summary:SetFormattedText(PARENS_TEMPLATE, duration);
	else
		button.Summary:SetFormattedText(PARENS_TEMPLATE, mission.duration);
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

	button:Enable();
	if (mission.inProgress) then
		button.Overlay:Show();
		button.Summary:SetText(mission.timeLeft.." "..RED_FONT_COLOR_CODE..GARRISON_MISSION_IN_PROGRESS..FONT_COLOR_CODE_CLOSE);
	else
		button.Overlay:Hide();
	end
	if (bigscreen) then
		button.Rewards[1]:SetPoint("RIGHT",button,"RIGHT",-500 - (GMM and 40 or 0),0)
		local width=GMF.MissionTab.MissionList.showInProgress and BIGBUTTON or SMALLBUTTON
		button:SetWidth(width+600)
		button.Rewards[1]:SetPoint("RIGHT",button,"RIGHT",-500 - (GMM and 40 or 0),0)
	end
	button.MissionType:SetPoint("TOPLEFT",5,-2)
	if page then
		local isNewMission = page.newMissionIDs[mission.missionID];
		if (isNewMission) then
			if (not button.NewHighlight) then
				button.NewHighlight = CreateFrame("Frame", nil, button, "GarrisonMissionListButtonNewHighlightTemplate");
				button.NewHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
				button.NewHighlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0);
			end
			button.NewHighlight:Show();
		else
			if (button.NewHighlight) then
				button.NewHighlight:Hide();
			end
		end
	end
	local n=mission.numRewards
	local w=button:GetWidth()-175 -- 655 for standard 830 button
	if button:GetWidth()<1000 then n=n+mission.numFollowers end
	ns.xprint(format("%d %d %d %d",w,button.Title:GetWidth() + button.Summary:GetWidth() + 8,n,w - n * 65))
	if ( button.Title:GetWidth() + button.Summary:GetWidth() + 8 < w - n * 65 ) then
		button.Title:SetPoint("LEFT", 165, 0);
		button.Summary:ClearAllPoints();
		button.Summary:SetPoint("BOTTOMLEFT", button.Title, "BOTTOMRIGHT", 8, 0);
	else
		button.Title:SetPoint("LEFT", 165, 10);
		button.Title:SetWidth(w - n * 65);
		button.Summary:ClearAllPoints();
		button.Summary:SetPoint("TOPLEFT", button.Title, "BOTTOMLEFT", 0, -4);
	end
	button.MissionType:SetAtlas(mission.typeAtlas);
end

function addon:AddThreatsToButton(button,mission,missionID,bigscreen)
	local threatIndex=1
	if (not GMF.MissionTab.MissionList.showInProgress) then
		if (not button.Threats) then -- I am a good guy. If MP present, I dont make my own threat indicator (Only MP <= 1.8)
			if (not GMF.MissionTab.MissionList.showInProgress) then
				if (not button.Env) then
					button.Env=CreateFrame("Frame",nil,button,"GarrisonAbilityCounterTemplate")
					button.Env:SetWidth(20)
					button.Env:SetHeight(20)
					button.Env:SetPoint("BOTTOMLEFT",button,165,8)
					button.GcThreats={}
				end
				local party=self:GetParty(missionID)
				if mission.typeIcon then
					button.Env.IsEnv=true
					button.Env:Show()
					button.Env.Icon:SetTexture(mission.typeIcon)
					if (party.isEnvMechanicCountered) then
						button.Env.Border:SetVertexColor(C.Green())
					else
						button.Env.Border:SetVertexColor(C.Red())
					end
					button.Env.Description=mission.typeDesc
					button.Env.Name=mission.type
					button.Env:SetScript("OnEnter",addon.ClonedGarrisonMissionMechanic_OnEnter)
					button.Env:SetScript("OnLeave",function() GameTooltip:Hide() end)
				else
					button.Env:SetScript("OnEnter",nil)
					button.Env:Hide()
				end
				for i=1,#mission.enemies do
					local enemy=mission.enemies[i]
					for mechanicID, mechanic in pairs(enemy.mechanics) do
						local th=button.GcThreats[threatIndex]
						if (not th) then
							th=CreateFrame("Frame",nil,button,"GarrisonAbilityCounterTemplate")
							th:SetWidth(20)
							th:SetHeight(20)
							th:SetPoint("BOTTOMLEFT",button,165 + 35 * threatIndex,8)
							button.GcThreats[threatIndex]=th
						end
						self:SetThreatColor(th,self:GetParty(missionID,'threats')[threatIndex])
						th.Icon:SetTexture(mechanic.icon)
						th.Name=mechanic.name
						th.Description=mechanic.description
						--GarrisonMissionButton_CheckTooltipThreat(th,missionID,mechanicID,counteredThreats)
						th:Show()
						th:SetScript("OnEnter",addon.ClonedGarrisonMissionMechanic_OnEnter)
						th:SetScript("OnLeave",function() GameTooltip:Hide() end)
						threatIndex=threatIndex+1
					end
				end
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
end

function addon:AddIndicatorToButton(button,mission,missionID,bigscreen)
	if not button.gcINDICATOR then
		local indicators=CreateFrame("Frame",nil,button,"GarrisonCommanderIndicators")
		indicators:SetPoint("LEFT",70,0)
		button.gcINDICATOR=indicators
	end
	local panel=button.gcINDICATOR
	local perc=select(4,G.GetPartyMissionInfo(missionID))
	if button.party then perc=button.party.perc end
	panel.Percent:SetFormattedText(GARRISON_MISSION_PERCENT_CHANCE,perc)
	panel.Percent:SetTextColor(self:GetDifficultyColors(perc))
	panel.Percent:SetWidth(80)
	panel.Percent:Show()
	if (GMFMissions.showInProgress) then
		panel.Percent:SetJustifyV("CENTER")
		panel.Age:Hide()
	else
		panel.Percent:SetJustifyH("RIGHT")
		panel.Age:SetFormattedText("Expires in \n%s",mission.offerTimeRemaining or self:CalculateAge(missionID))
		panel.Age:SetTextColor(C.White())
		local age=(mission.offerEndTime or GetTime() + 3600*24) -GetTime()
		if age < 0 then age=0 end
		local hours=floor(age/3600)
		local q=self:GetDifficultyColor(hours+20,true)
		panel.Age:SetTextColor(q.r,q.g,q.b)
		panel.Age:Show()
	end
-- XP display
	if (not GMFMissions.showInProgress) then
		if (not button.xp) then
			button.xp=button:CreateFontString(nil, "ARTWORK", "QuestMaprewardsFont")
			button.xp:SetPoint("TOP",button.Rewards[1],"TOP")
			button.xp:SetJustifyH("CENTER")
		end
		button.xp:SetWidth(0)
		local xp=(self:GetMissionData(missionID,'xp')+self:GetMissionData(missionID,'xpBonus')+(self:GetParty(missionID)['xpBonus'] or 0) )*button.info.numFollowers
		button.xp:SetFormattedText("Xp: %d",xp)
		button.xp:SetTextColor(self:GetDifficultyColors(xp/3000*100))
		button.xp:Show()
	else
		if button.xp then
			button.xp:Hide()
		end
	end
end
function addon:AddFollowersToButton(button,mission,missionID,bigscreen)
	if (not button.gcPANEL) then
		local bg=CreateFrame("Button",nil,button,"GarrisonCommanderMissionButton")
		bg:SetPoint("RIGHT")
		bg.button=button
		bg:SetScript("OnEnter",function(this) GarrisonMissionButton_OnEnter(this.button) end)
		bg:SetScript("OnLeave",function() GameTooltip:FadeOut() end)
		bg:RegisterForClicks("AnyUp")
		bg:SetScript("OnClick",function(...) self:OnClick_GCMissionButton(...) end)
		button.gcPANEL=bg
		if (not bg.Party) then self:BuildFollowersButtons(button,bg,3,bigscreen) end
	end
	local missionInfo=button.info
	local missionID=missionInfo.missionID
	local mission=missionInfo
	if not mission then ns.print("Non ho la missione") return end -- something went wrong while refreshing
	if (not bigscreen) then
		local index=mission.numFollowers+mission.numRewards-3
		local position=(index * -65) - 130
		button.gcPANEL.Party[1]:ClearAllPoints()
		button.gcPANEL.Party[1]:SetPoint("BOTTOMLEFT",button.Rewards[1],"BOTTOMLEFT", position,0)
	end
	local party=button.party
	if not party then party=self:GetParty(missionID) end
	local t,b
	if not GMFMissions.showInProgress then
		b=G.GetBuffedFollowersForMission(missionID)
		t=G.GetFollowersTraitsForMission(missionID)
	end
	for i=1,3 do
		local frame=button.gcPANEL.Party[i]
		if (i>mission.numFollowers) then
			frame:Hide()
		else
			if (party.members[i]) then
				self:RenderFollowerButton(frame,party.members[i],missionID,b,t)
				if (frame.NotFull) then frame.NotFull:Hide() end
			else
				self:RenderFollowerButton(frame,false)
				if (frame.NotFull) then frame.NotFull:Show() end
			end
			frame:Show()
		end
	end
end

--hooksecurefunc("GarrisonMissionList_Update",function(...)print("Original GarrisonMissionList_Update",...)end)
override("GarrisonMissionPage_Close")
override("GarrisonMissionList_Update")
override("GarrisonMissionButton_SetRewards")
override("GarrisonMissionButton_OnEnter")
override("GarrisonMissionPageFollowerFrame_OnEnter")

GMF.MissionTab.MissionPage.CloseButton:SetScript("OnClick",over.GarrisonMissionPage_Close)
for i=1,#GMFMissionListButtons do
	local b=GMFMissionListButtons[i]
	b:SetScript("OnEnter",over.GarrisonMissionButton_OnEnter)
end
