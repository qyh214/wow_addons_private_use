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
local module=addon:NewSubModule('Cache',"AceHook-3.0","AceEvent-3.0","AceTimer-3.0")  --#Module
function addon:GetCacheModule() return module end
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
local GARRISON_LANDING_COMPLETED=GARRISON_LANDING_COMPLETED:match( "(.-)%s*$")
local CATEGORY_INFO_FORMAT=ORDER_HALL_COMMANDBAR_CATEGORY_COUNT .. ' (' .. GARRISON_LANDING_COMPLETED ..')'
local pairs,math,wipe,tinsert,GetTime,next,ipairs,type,OHCDebug=
		pairs,math,wipe,tinsert,GetTime,next,ipairs,type,OHCDebug
local GARRISON_FOLLOWER_INACTIVE=GARRISON_FOLLOWER_INACTIVE
local missionsRefresh,followersRefresh=0,0
local volatile={
followers={
xp=G.GetFollowerXP,
levelXP=G.GetFollowerLevelXP,
quality=G.GetFollowerQuality,
level=G.GetFollowerLevel,
isMaxLevel=function(followerID)	return G.GetFollowerLevelXP(followerID)==0 end,
prettyName=G.GetFollowerLink,
iLevel=G.GetFollowerItemLevelAverage,
status=G.GetFollowerStatus,
busyUntil=function(followerID) return GetTime() + (G.GetFollowerMissionTimeLeftSeconds(followerID) or 0) end
},
missions={
}
}--- Caches
-- 
local currency
local currencyName
local currencyTexture
local resources=0
local id2index={f={},m={}}
local avgLevel,avgIlevel=0,0
local cachedFollowers={}
local cachedMissions={}
local categoryInfo
local shipmentInfo={}
local emptyTable={}
local permutations={
	{},
	{},
	{}
}
local methods={available='GetAvailableMissions',inProgress='GetInProgressMissions',completed='GetCompleteMissions'}
local catPool={}
local troopTypes={}
local function fillCachedMission(mission,time)
	if not time then time=GetTime() end
	local _,baseXP,_,_,_,_,exhausting,enemies=G.GetMissionInfo(mission.missionID)
	mission.exhausting=exhausting
	mission.baseXP=baseXP
	mission.enemies=enemies
	mission.lastUpdate=time
	mission.available=not mission.inProgress
	addon:Reward2Class(mission)
end
local function getCachedMissions()
	if not next(cachedMissions) then
--[===[@debug@
		OHCDebug:Bump("Missions")
--@end-debug@	]===]
		local time=GetTime()
		for property,method in pairs(methods) do
			local missions=G[method](followerType)
			for _,mission in ipairs(missions) do
				mission[property]=true
				fillCachedMission(mission,time)
				cachedMissions[mission.missionID]=mission
			end
		end
	end
	return cachedMissions
end	
local function getCachedFollowers()
	
	if empty(cachedFollowers) then
--[===[@debug@
		OHCDebug:Bump("Followers")
--@end-debug@	]===]
		local followers=G.GetFollowers(followerType)
		if type(followers)=="table" then
			local time=GetTime()
			for _,follower in ipairs(followers) do
				if follower.isCollected and follower.status ~= GARRISON_FOLLOWER_INACTIVE then
					cachedFollowers[follower.followerID]=follower
					cachedFollowers[follower.followerID].lastUpdate=time
					cachedFollowers[follower.followerID].busyUntil=volatile.followers.busyUntil(follower.followerID)
				end
			end
		end
	end
	return cachedFollowers 
end
function module:GetAverageLevels(cached)
	if avgLevel==0 or not cached then
		local level,ilevel,tot=0,0,0
		local f=getCachedFollowers()
		for i,d in pairs(f) do
			if d.isCollected and not d.isTroop then
				tot=tot+1
				level=level+self:GetKey(d,'level',0)
				ilevel=ilevel+self:GetKey(d,'iLevel',0)
			end
		end
		avgLevel,avgIlevel=math.floor(level/tot),math.floor(ilevel/tot)
	end
	return avgLevel,avgIlevel
end
function addon:GetPermutations()
	local champs=new()
	addon:GetAllChampions(champs)
	local k=#champs
	local refresh=false
	for i=1,k do
		if permutations[1][i]~=champs[i] then refresh=true end
	end
	if refresh then
		wipe(permutations[1])
		wipe(permutations[2])
		wipe(permutations[3])
		for i=1,k do
			tinsert(permutations[1],champs[i].followerID)
			for j=i+1,k do
				tinsert(permutations[2],strjoin(',',tostringall(champs[i].followerID,champs[j].followerID)))
				for z=j+1,k do
					tinsert(permutations[3],strjoin(',',tostringall(champs[i].followerID,champs[j].followerID,champs[z].followerID)))
				end
			end
		end
	end
	del(champs)
	return permutations
end
function module:DeleteFollower(followerID)
	if followerID and cachedFollowers[followerID] then
		del(cachedFollowers[followerID])
	end
end
function module:BuildFollower(followerID)
	local f=getCachedFollowers()
	if f[followerID] then 
		f[followerID].busyUntil=volatile.followers.busyUntil(followerID)
		return 
	end
	local rc,data=pcall(G.GetFollowerInfo,followerID)
	if rc then
		if data and data.isCollected then
			data.lastUpdate=GetTime()
			data.busyUntil=volatile.followers.busyUntil(data.followerID)
			cachedFollowers[followerID]=data
		elseif data then
			del(data,true)
		end
	end
end
function module:BuildMission(missionIDfollowerID)
	local rc,data=pcall(G.GetFollowerInfo,followerID)
	if rc then
		if data and data.isCollected then
			data.lastUpdate=GetTime()
			data.busyUntil=volatile.followers.busyUntil(data.followerID)
			cachedFollowers[followerID]=data
		elseif data then
			del(data,true)
		end
	end
end
function module:refreshMission(data)
	--local runtime,runtimesec,inProgress,duration,durationsec,bool1,string1=G.GetMissionTimes(data.missionID)
end
function module:refreshFollower(data)
	if (data.lastUpdate or 0) < followersRefresh then
		-- stale data, refresh volatile fields
		local id=data.followerID
		local rc,name=pcall(G.GetFollowerName,id)
		if rc and name then
			for field,func in pairs(volatile.followers) do
				data[field]=func(id)
			end
			data.lastUpdate=followersRefresh
		else
			del(data,true)
			data=nil
		end
	end	
end
--[===[@debug@
function module:GetFollower(key)
	if (key:sub(1,2)=='0x') then
		key="0x" .. ("0000000000000000" ..key:sub(3)):sub(-16)
		return self:GetFollowerData(key)
	end
	for _,data in pairs(getCachedFollowers()) do
		if data.name:find(key)==1 then
			return data
		end
	end
end
--@end-debug@]===]
function module:GetFollowerData(...)
	local id,key,defaultvalue=...
	local f=getCachedFollowers()
	if not id then
		for _,data in pairs(f) do
			self:refreshFollower(data)
		end
		return f
	end
	local data=f[id] 
	if data then
		self:refreshFollower(data) 
	end
	if data then
		if key then
			return self:GetKey(data,key,defaultvalue)
		else
			return data
		end
	else
		if select('#',...) > 2 then
			return defaultvalue
		else
			return emptyTable
		end
	end
end
function module:SetMissionStatus(missionID,status)
	local mission=getCachedMissions()[missionID]
	if mission then
		mission.inProgress=nil
		mission.available=nil
		mission.completed=nil
	end
	mission[status]=true
end
function module:GetMissionData(...)
	local id,key,defaultvalue=...
	local f=getCachedMissions()
	if not id then
		return f
	end
	local data=f[id]
	if data and not data.numFollowers then
		del(data)
		data=nil
	end
	if not data then
		local rc,data=pcall(G.GetBasicMissionInfo,id)
		if rc and data then 
			self:refreshMission(data)
			fillCachedMission(data,GetTime(time))			
			f[id]=data
		else
			if select('#',...) > 2 then
				return defaultvalue
			else
				return emptyTable
			end
		end
	end
	if data then
		if key then
			return self:GetKey(data,key,defaultvalue)
		else
			return data
		end
	end
end


function module:GetKey(data,key,defaultvalue)
-- some keys need to be fresh only if champions is not maxed
	
	if volatile[key] and not data[key] then
		data[key]=volatile[key](data.followerID)
	end
	if key=='status' and data.status=="refresh" then
		data.status=G.GetFollowerStatus(data.followerID)
	end
	if data[key] then return data[key] end
	-- pseudokeys 
	if key=="qLevel" then 
		return data.isMaxLevel and data.quality+data.level or data.level
	end
	assert("Invalid pseudo key " .. tostring(key))
	return defaultvalue
end
function module:Clear()
	wipe(cachedFollowers)
	wipe(cachedMissions)
end
local function alertSetup(frame,name,...)
	GarrisonFollowerAlertFrame_SetUp(frame,FAKE_FOLLOWERID,...)
	frame.Title:SetText(name)
	return frame
end
function module:RefreshTroopTypes()
	wipe(troopTypes)
	local t=new()
	for i,v in pairs(getCachedFollowers()) do
		if v.isTroop then
			t[v.classSpec]=true
		end
	end
	for i,_ in pairs(t) do
		tinsert(troopTypes,i)
	end
end
local TroopsHeader
function module:GetTroopsFrame()
	if not TroopsHeader then
		local frame=CreateFrame("Frame",nil,OrderHallMissionFrame,"TooltipBorderedFrameTemplate")
		frame.Background:Hide()
		frame.Top=frame:CreateTexture(nil,"BACKGROUND",nil,-1)
		frame.Top:SetPoint("TOPLEFT")
		frame.Top:SetPoint("BOTTOMRIGHT")
		frame.Top:SetAtlas("_StoneFrameTile-Top")
		frame:SetHeight(35)
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT",OrderHallMissionFrame,"TOPLEFT",0,-2)
		frame:SetPoint("BOTTOMRIGHT",OrderHallMissionFrame,"TOPRIGHT",2,-2)
		frame:SetFrameLevel(OrderHallMissionFrame:GetFrameLevel()-1)
		frame:Show()
		TroopsHeader=frame
	end
	return TroopsHeader
end

function module:ParseFollowers()
	self:RefreshTroopTypes()
	categoryInfo = G.GetClassSpecCategoryInfo(followerType)
	if empty(categoryInfo) then
		G.RequestClassSpecCategoryInfo(followerType)
		self:ScheduleTimer("ParseFollowers",1)
		return
	end
	G.RequestLandingPageShipmentInfo();
	if not OHF:IsVisible() then return end
	local main=self:GetTroopsFrame()
	local numCategories = #categoryInfo;
	local prevCategory, firstCategory;
	local xSpacing = 20;	-- space between categories
	for i, category in ipairs(categoryInfo) do
		local index=category.classSpec
		if not catPool[index] then
			catPool[index]=CreateFrame("Frame","FollowerIcon",main,"OrderHallClassSpecCategoryTemplate")
		end
		local categoryInfoFrame = catPool[index];
		if not shipmentInfo[category.icon] then
			shipmentInfo[category.icon]={0,0}
		end
		categoryInfoFrame.Icon:SetTexture(category.icon);
		categoryInfoFrame.Icon:SetTexCoord(0, 1, 0.25, 0.75)
		categoryInfoFrame.TroopPortraitCover:Hide()		
		categoryInfoFrame.Icon:SetHeight(15)
		categoryInfoFrame.Icon:SetWidth(35)
		categoryInfoFrame.name = category.name;
		categoryInfoFrame.description = category.description;
		categoryInfoFrame.Count:SetFormattedText(
			CATEGORY_INFO_FORMAT, 
			category.count, category.limit,unpack(shipmentInfo[category.icon]));
		categoryInfoFrame.Count:SetWidth(categoryInfoFrame.Count:GetStringWidth()+10)			
		categoryInfoFrame:ClearAllPoints();
		local w=35 + categoryInfoFrame.Count:GetWidth()
		categoryInfoFrame:SetWidth(w)
		categoryInfoFrame:SetPoint("TOPLEFT",60 +(w+10) *(i-1), 0);
		categoryInfoFrame:Show();
	end
end
function addon:ParseFollowers()
	return module:ParseFollowers()
end
local OrderHallCommanderAlertSystem=AlertFrame:AddSimpleAlertFrameSubSystem("OHCAlertFrameTemplate", alertSetup)
local shownAlerts={}
function module:GARRISON_LANDINGPAGE_SHIPMENTS(...)
	if not addon:GetBoolean('TROOPALERT') then return end
	if (not G.IsPlayerInGarrison(garrisonType)) then return end
	local followerShipments = C_Garrison.GetFollowerShipments(garrisonType);
	for _,t in pairs(shipmentInfo) do
		t[1]=0
		t[2]=0
	end		
	for i = 1, #followerShipments do
	   local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, _, _, _, _, followerID = C_Garrison.GetLandingPageShipmentInfoByContainerID(followerShipments[i]);
	   if name and shipmentCapacity > 0 then
			shipmentInfo[texture]=shipmentInfo[texture] or {}
			shipmentInfo[texture][1]=shipmentsReady
			shipmentInfo[texture][2]=shipmentsTotal
			local signature=strjoin(':',name,shipmentsReady)
			if not shownAlerts[signature] then shownAlerts[signature]=GetTime()+15 end
			if shipmentsReady > 0 then
				if GetTime()>shownAlerts[signature] then
					shownAlerts[signature]=GetTime()+60
					OrderHallCommanderAlertSystem:AddAlert(name, GARRISON_LANDING_COMPLETED:format(shipmentsReady,shipmentsTotal), 110, 0, false, 
						{isTroop=true,followerTypeID=4,portraitIconID=texture,quality=1}
					)
				end
			end	
		end
	end

end

function module:Refresh(event,...)
--[===[@debug@
	OHCDebug.CacheRefresh:SetText(event:sub(10))
--@end-debug@]===]
	addon:RefreshFollowerStatus()
	if (event == "CURRENCY_DISPLAY_UPDATE") then
		resources = select(2,GetCurrencyInfo(currency))		
		return
	end
	if event=="GARRISON_FOLLOWER_REMOVED" then
		local currentType=... -- alas, we dont have followerId here
		if currentType==followerType then
			followersRefresh=GetTime()
			return self:ParseFollowers()
		end
	elseif event=="GARRISON_FOLLOWER_CATEGORIES_UPDATED" then
		return self:ParseFollowers()
	elseif event=="GARRISON_FOLLOWER_ADDED" then
		local followerID, name, class, level, quality, isUpgraded, texPrefix, currentType = ...	
		if currentType==followerType  then
			self:BuildFollower(followerID) -- kicks rebuild
			return self:ParseFollowers()
		end
	elseif event=="GARRISON_FOLLOWER_XP_CHANGED"  then
		local currentType,followerID,xp=...
		if currentType==followerType and xp > 0 then
			local data=cachedFollowers[followerID]
			if data then 
				data.lastUpdate=0
				self:refreshFollower(data)
--[===[@debug@
				addon:PushEvent("CURRENT_FOLLOWER_XP",4,followerID,0,data.xp,data.level,data.quality)
--@end-debug@]===]

			end
		end
	elseif event=="GARRISON_FOLLOWER_UPGRADED"then
		local followerID=...
		local follower=cachedFollowers[followerID]
		if follower and follower.followerTypeID==followerType then
			self:refreshFollower(follower)
		end
	elseif event=="GARRISON_FOLLOWER_DURABILITY_CHANGED" then
		local currentType,followerID,durability=...
		if currentType==followerType then
			if durability==0 then
				self:DeleteFollower(followerID)
			else
				local follower=cachedFollowers[followerID]
				if follower then
					follower.durability=durability
					follower.lastUpdate=GetTime()
				else
					self:BuildFollower(followerID) -- kicks rebuild
				end
			end
		end
	elseif event=="GARRISON_FOLLOWER_LIST_UPDATE" or event=="GARRISON_MISSION_STARTED" or event=="GARRISON_MISSION_FINISHED" or event=="GARRISON_MISSION_LIST_UPDATE" then
		local currentType=...
		if currentType==followerType then
			followersRefresh=GetTime()
		end
	elseif event=="GARRISON_MISSION_COMPLETE_RESPONSE" then
		-- alas, no followerType here
		followersRefresh=GetTime()
	end
end
function module:OnInitialized()
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE","Refresh")
	self:RegisterEvent("GARRISON_FOLLOWER_REMOVED","Refresh")
	self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE","Refresh")
	self:RegisterEvent("GARRISON_FOLLOWER_ADDED","Refresh")
	self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE","Refresh")
	self:RegisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED","Refresh") 
	self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED","Refresh")
	self:RegisterEvent("GARRISON_FOLLOWER_DURABILITY_CHANGED","Refresh")
	self:RegisterEvent("GARRISON_MISSION_STARTED","Refresh")
	self:RegisterEvent("GARRISON_MISSION_FINISHED","Refresh")
	self:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE","Refresh")	
	self:RegisterEvent("GARRISON_MISSION_LIST_UPDATE","Refresh")	
	self:RegisterEvent("GARRISON_LANDINGPAGE_SHIPMENTS")	
	currency, _ = C_Garrison.GetCurrencyTypes(garrisonType);
	currencyName, resources, currencyTexture = GetCurrencyInfo(currency);
	addon.resourceFormat=COSTS_LABEL .." %d " .. currencyName
	self:ParseFollowers()
	
end
---- Public Interface
-- 
function addon:GetResources()
	return resources,currencyName
end
function addon:GetMissionData(...)
	return module:GetMissionData(...)
end
function addon:GetFollowerData(...)
	return module:GetFollowerData(...)
end
function addon:GetFollower(...)
	return module:GetFollower(...)
end
function addon:GetFollowerCounts()
	local t,c=0,0
	for _,follower in pairs(getCachedFollowers()) do
		if follower.isTroop then
			t=t+1
		else
			c=c+1
		end
	end
	return c,t
end
function addon:GetAllChampions(table)
	for _,follower in pairs(getCachedFollowers()) do
		if not follower.isTroop then
			tinsert(table,follower)
		end
	end
	return table
end
function addon:GetAllTroops(table)
	for _,follower in pairs(getCachedFollowers()) do
		if follower.isTroop then
			tinsert(table,follower)
		end
	end
	return table
end
local function isInParty(followerID)
	return G.GetFollowerStatus(followerID)==GARRISON_FOLLOWER_IN_PARTY
end
local troops={}
function addon:GetTroop(troopType,qt,skipBusy)
	if type(qt)=="boolean" then skipBusy=qt qt=1 end
	qt=self:tonumber(qt,1)
	local found=0
	wipe(troops)
	for _,follower in pairs(getCachedFollowers()) do
		if follower.isTroop and follower.classSpec==troopType and (not skipBusy or not follower.status) then
			tinsert(troops,follower)
			found=found+1
			if found>=qt then
				break
			end
		end
	end
	return unpack(troops)
end
function addon:GetTroopTypes()
	return troopTypes
end

function addon:RebuildMissionCache()
	wipe(cachedMissions)
	getCachedMissions()
end
function addon:RebuildFollowerCache()
	wipe(cachedFollowers)
	getCachedFollowers()
	module:RefreshTroopTypes()
end
function addon:RebuildAllCaches()
	self:RebuildFollowerCache()
	self:RebuildMissionCache()
end

function addon:GetAverageLevels(...)
	return module:GetAverageLevels(...)
end
