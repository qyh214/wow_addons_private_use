local __FILE__=tostring(debugstack(1,2,0):match("(.*):1:")) -- Always check line number in regexp and file, must be 1
local function pp(...) print(GetTime(),"|cff009900",__FILE__:sub(-15),strjoin(",",tostringall(...)),"|r") end
--*TYPE module
--*CONFIG noswitch=false,profile=true,enhancedProfile=true
--*MIXINS "AceHook-3.0","AceEvent-3.0","AceTimer-3.0","AceSerializer-3.0","AceConsole-3.0"
--*MINOR 35
-- Generated on 20/01/2017 08:15:04
local me,ns=...
local addon=ns --#Addon (to keep eclipse happy)
ns=nil
local module=addon:NewSubModule('Matchmaker',"AceHook-3.0","AceEvent-3.0","AceTimer-3.0","AceSerializer-3.0","AceConsole-3.0")  --#Module
function addon:GetMatchmakerModule() return module end
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
local lethalMechanicEffectID = 437;
local cursedMechanicEffectID = 471;
local slowingMechanicEffectID = 428;
local disorientingMechanicEffectID = 472;
local debugMission=0
local function parse(default,rc,...)
	if rc then 
		return ... 
	else
	--[===[@debug@
		error(message,2) 
	--@end-debug@]===]
		return default
	end
end
	
local meta={
__index = function(t,key)
	return function(...) return parse(nil,pcall(C_Garrison[key],...)) end end
}
--upvalues
local assert,ipairs,pairs,wipe,GetFramesRegisteredForEvent=assert,ipairs,pairs,wipe,GetFramesRegisteredForEvent
local select,tinsert,format,pcall,setmetatable,coroutine=select,tinsert,format,pcall,setmetatable,coroutine
local tostringall=tostringall
local followerType=LE_FOLLOWER_TYPE_GARRISON_7_0
local emptyTable={}
local holdEvents
local releaseEvents
local debug=setmetatable({},{__index=function(t,k) rawset(t,k,new()) return t[k] end})
local events={stacklevel=0,frames={}} --#events
function addon:GetDebug()
	return debug
end
function events.hold() --#eventsholdEvents
	if events.stacklevel==0 then
		events.frames={GetFramesRegisteredForEvent('GARRISON_FOLLOWER_LIST_UPDATE')}
		for i=1,#events.frames do
			events.frames[i]:UnregisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
		end
	end
	events.stacklevel=events.stacklevel+1
end
function events.release()
	events.stacklevel=events.stacklevel-1
	assert(events.stacklevel>=0)
	if (events.stacklevel==0) then
		for i=1,#events.frames do
			events.frames[i]:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
		end
		events.frames=nil
	end
end
holdEvents=events.hold
releaseEvents=events.release
local maxtime=3600*24*7
-- Candidate management
local CandidateManager={perc=0,chance=0} --#CandidateManager
local CandidateMeta={__index=CandidateManager}
local emptyCandidate=setmetatable({},CandidateMeta)
local inProgressCandidate=setmetatable({},CandidateMeta)
function CandidateManager:IterateFollowers()
	return ipairs(self)
end
function CandidateManager:Follower(index)
	return self[index]
end
-- Party management
local partyManager={} --#PartyManager
local function newParty()
	return setmetatable(new(),
		{__index=partyManager,
		__call=function(table)  end
		})
end
local parties={}
local function IsLower(cur,base)
	if not cur then
		return 99
	else 
		return cur < base
	end
end
local function IsHigher(cur,base)
	if not cur then
		return 0
	else 
		return cur > base
	end
end

--	addon:RegisterForMenu("mission","SAVETROOPS","SPARE","MAKEITQUICK","MAXIMIZEXP")
function partyManager:Fail(reason,...)
--[===[@debug@
	reason=strjoin(' ',tostringall(reason,...))
--@end-debug@]===]
	return false,reason
end	 
local keys={
'f1',
'f2',
'f3'
}
function partyManager:FillRealFollowers(candidate,dbg)
	candidate.busyUntil=GetTime()
	local troops=new()
	addon:GetAllTroops(troops)			
	for i=1,3 do
		if i > (self.numFollowers or 3) then return end
		local key=keys[i];
		if  candidate[key] then 
			local followerID,classSpec=strsplit(',',candidate['f'..i])
			--GARRISON_FOLLOWER_COMBAT_ALLY
			classSpec=addon:tonumber(classSpec,0)
			if classSpec~=0 then
				local better=(candidate.hasKillTroopsEffect and IsLower or IsHigher)
				local base=better()
				local baseBusy=base
				local found,foundBusy,foundFree
				for t,troop in pairs(troops) do
					local ignore=false
					if troop.classSpec==classSpec then
						if i>1 and troop.followerID==candidate[i-1] then
							ignore=true
						end
						if i>2 and troop.followerID==candidate[i-2] then
							ignore=true
						end
						troop.status=G.GetFollowerStatus(troop.followerID)
						if troop.status then
							if better(troop.durability,baseBusy) and not ignore then
								foundBusy=t
								baseBusy=troop.durability
							end
						else
							troop.busyUntil=0
							if better(troop.durability,base) and not ignore then
								found=t
								base=troop.durability
							end
							if not ignore and not foundFree then
								foundFree=t
							end
						end
					end
				end
				-- SAVETROOPS doesnt allow to have unintended casualties
				if addon:GetBoolean("SAVETROOPS") and candidate.hasKillTroopsEffect and addon:GetFollowerData(followerID,'durability') > 1 then 
					followerID=nil
				else
					if found then
						followerID=troops[found].followerID
					elseif foundFree then
						followerID=troops[foundFree].followerID
					elseif foundBusy then
						followerID=troops[foundBusy].followerID
					else
						followerID=nil
					end
				end
			end
			candidate[i]=followerID
			if followerID then
				candidate.busyUntil=math.max(addon:GetFollowerData(followerID,'busyUntil',0),candidate.busyUntil)
			end
		else
			candidate[i]=nil
		end
	end
	del(troops)		
end
function partyManager:SatisfyCondition(candidate,key,table)
	if type(candidate) ~= "table" then return self:Fail("NOTABLE") end
	local followerID=candidate[key]
	self.lastChecked=followerID
	if not followerID then return self:Fail("No follower id for party slot",key) end
	if addon:GetBoolean("SPARE") and candidate.cost > candidate.baseCost then return self:Fail("SPARE",addon:GetBoolean("SPARE"),candidate.cost , candidate.baseCost) end
	if addon:GetBoolean("MAKEITVERYQUICK") and not candidate.timeIsImproved then return self:Fail("VERYQUICK") end
	if addon:GetBoolean("MAKEITQUICK") and candidate.hasMissionTimeNegativeEffect then return self:Fail("QUICK") end
	if addon:GetBoolean("BONUS") and candidate.hasBonusLootNegativeEffect then return self:Fail("BONUS") end
	local ready=addon:GetFollowerData(followerID,"busyUntil")
	if not ready then return self:Fail("No ready data") end
	local status=G.GetFollowerStatus(followerID)
	if status then 
		if addon:GetBoolean("USEALLY") and status==GARRISON_FOLLOWER_COMBAT_ALLY then
			return true
		end
		return self:Fail("BUSY",status,'G.GetFollowerStatus("' ..followerID..'")')
	end 
	return true,'OK'
end
function partyManager:IterateIndex()
	self:GenerateIndex()
	return ipairs(self.candidatesIndex)
end
local function GetSelectedParty(self,dbg)
	local lastkey
	local bestkey
	local xpkey
	local absolutebestkey
	local busybestkey
	local xpperc=0
	local xpgainers=0
	self:GenerateIndex()
	local maxChamps=addon:GetNumber("MAXCHAMP")
	for i,key in ipairs(self.candidatesIndex) do
		local candidate=self.candidates[key]
		if dbg then
			local a={'f1','f2','f3'}
			local message="key "
			for i=1,#a do
				local f=candidate[a[i]]
				if f then
					local id,troop,name=strsplit(',',f)
					key=key.. id:sub(11) .. C(name,troop==0 and 'orange' or 'cyan') .. ' '
				end
			end
			addon:Print(key)
		end
		if candidate and candidate.champions <=maxChamps  then
			self:FillRealFollowers(candidate,dbg)
			if not absolutebestkey then absolutebestkey=key end
			lastkey=key
			local got=true
			local reason=''
			if type(self.numFollowers) ~= "number" then
				
			end
			for i=1,self.numFollowers do
				local rc,reason = self:SatisfyCondition(candidate,i)
				got=got and rc
				if not got then
--[===[@debug@
					if dbg then
						if reason=="NOTABLE" then
							addon:Print("Received a non table as candidate",type(candidate),candidate)
						else
							addon:Print(candidate['f'..i],C(reason,'RED'))
						end 
					end 
--@end-debug@				]===]
					break 
				end
			end
			if got then
--[===[@debug@
				if dbg then
					addon:Print(C("Satisfy ok","green"))
				end 
--@end-debug@				]===]
				if not bestkey then bestkey=key end
				if addon:GetBoolean("MAXIMIZEXP") then
					if candidate.perc >= 100 and candidate.xpGainers >xpgainers then
						xpkey=key
						xpperc=candidate.perc
						xpgainers=candidate.xpGainers
					end
				else
					candidate.order=i
					candidate.key=key
					return candidate,key
				end
			end
--[===[@debug@
		else
			if dbg then addon:Print("Too many champions:",candidate.champions) end
--@end-debug@			]===]
		end
		
	end
	--[===[@debug@
	if dbg then addon:Print(
		format("Best: %s, Xp: %s, Absolute: %s, Last:%s",tostringall(bestkey,xpkey,absolutebestkey,lastkey))
		)
	end
	print("XPKey,Bestkey,Lastkey",self.missionID,xpkey,bestkey,lastkey)
	--@end-debug@]===]
	if xpkey then 
		return self.candidates[xpkey],xpkey
	end
	if bestkey then 
		return self.candidates[bestkey],bestkey
	end
	if absolutebestkey then 
		return self.candidates[absolutebestkey],absolutebestkey
	end
	if lastkey then 
		--if self.candidates[lastkey].busyUntil <= GetTime() then
			return self.candidates[lastkey],lastkey -- should not return busy followers
		--end
	end
	return setmetatable(self:GetEffects(),CandidateMeta)
end
function partyManager:GetSelectedParty(mission)
	wipe(debug[self.missionID])
	if type(mission)=="table" and mission.inProgress then
--[===[@debug@
		print("inProgress")
--@end-debug@]===]
		if not self.candidates or not self.candidates.progress then
			local candidate=self:GetEffects()
			local followers=mission.followers
			if followers then
				for i =1,#followers do
					candidate[i]=followers[i]
				end
			end	
			self.candidates.progress=setmetatable(candidate,CandidateMeta)		
		end 
		return self.candidates.progress,"progress"	
	end
	if type(mission)=="string" and self.candidates[mission] then
--[===[@debug@
		print("Returning explicity set key ",mission)
--@end-debug@]===]
		return self.candidates[mission],mission
	end
	if not self.ready then
--[===[@debug@
		print("Rebuilding list")
--@end-debug@		]===]
		self:Match()
	end

	local candidate=GetSelectedParty(self)
	self.bestChance=candidate.perc or 0
	self.bestTimeseconds=candidate.timeseconds or 0
	self.totalXP=(self.baseXP+self.rewardXP+(candidate.bonusXP or 0))*(candidate.xpGainers or 0)
	return candidate
end
function partyManager:Remove(...)
	local tbl=...
	if type(tbl)=="table" then
		for _,id in ipairs(tbl) do
			if type(id)=="table" then id=id.followerID end
			local rc,message=pcall(G.RemoveFollowerFromMission,self.missionID,id)
--[===[@debug@
			if not rc then	
				print("Remove failed",message,self.missionID,...) 
			end
--@end-debug@]===]
		end
	else
		for i=1,select('#',...) do
			local rc,message=pcall(G.RemoveFollowerFromMission,self.missionID,(select(i,...)))
--[===[@debug@
			if not rc then	
				print("Remove failed",message,self.missionID,...) 
			end
--@end-debug@]===]
		end
	end	
end
function partyManager:GetEffects()
	local timestring,timeseconds,timeImproved,chance,buffs,missionEffects,xpBonus,materials,gold=G.GetPartyMissionInfo(self.missionID)
	missionEffects.timestring=timestring
	missionEffects.timeseconds=timeseconds
	missionEffects.perc=chance
	missionEffects.timeImproved=timeImproved
	missionEffects.xpBonus=xpBonus
	missionEffects.materials=materials
	missionEffects.gold=gold
	local improvements=5
	if timeImproved then improvements=improvements -1 end  
	if missionEffects.hasMissionTimeNegativeEffect then improvements=improvements+1 end
	missionEffects.baseCost,missionEffects.cost=G.GetMissionCost(self.missionID)
	if missionEffects.baseCost < missionEffects.cost then
		improvements=improvements+2
	elseif missionEffects.baseCost > missionEffects.cost then
		improvements=improvements-1
	end
	if missionEffects.hasKillTroopsEffect then
		improvements=improvements+2
	end
	missionEffects.improvements=improvements
	return missionEffects

end
function partyManager:Build(...)
--[===[@debug@
	print("Build",self.numFollowers,...)
--@end-debug@]===]
	local followers=new()
	if select('#',...)>0 then
		for i=1,self.numFollowers or 3 do
			local follower=select(i,...)
			if not follower then return self:Remove(followers) end
			local followerID=follower.followerID
			local rc,res = pcall(G.AddFollowerToMission,self.missionID,followerID)
			if not rc or not res then
				self:Remove(followers)
				del(followers)
				return
			end
			tinsert(followers,follower) 
		end 
	end
	local missionEffects=self:GetEffects()
	missionEffects.xpGainers=0
	missionEffects.champions=0
	for i=1,#followers do 
		local followerID=followers[i].followerID
		local k='f'..i
		if not followers[i].isTroop then
			local qlevel=addon:GetFollowerData(followerID,'qLevel',0)
			missionEffects.champions=missionEffects.champions+1
			if qlevel < addon.MAXQLEVEL then
				missionEffects.xpGainers=missionEffects.xpGainers+1
			end 
		end
		missionEffects[k]=format("%s,%s",tostringall(followerID,followers[i].isTroop and followers[i].classSpec or "0"))
	--[===[@debug@
		missionEffects[k]=missionEffects [k]..','..addon:GetFollowerData(followerID,'name')
	--@end-debug@]===]
	end
	self.unique=self.unique+1	
	local index=format("%03d:%1d:%1d:%1d:%2d",900-missionEffects.perc,missionEffects.improvements,missionEffects.champions,3-missionEffects.xpGainers,self.unique)
	missionEffects.chance=index	
	self.candidates[index]=setmetatable(missionEffects,CandidateMeta)
	self:Remove(followers)

end	

function partyManager:Match()

	local champs=addon:GetPermutations()
	wipe(self.candidates)
	local totChamps=#champs
	local mission=addon:GetMissionData(self.missionID)
	if not mission then
	 	addon:RebuildMissionCache()
	 	mission=addon:GetMissionData(self.missionID)
	 end
	if not mission then return false end
--[===[@debug@
	OHCDebug:Bump("Parties")
	print("Match started for mission",mission.name)
--@end-debug@]===]
	self.unique=0
	self.numFollowers=mission.numFollowers
	self.missionSort=addon:Reward2Class(mission)
	self.missionClass=mission.missionClass
	self.missionValue=mission.missionValue
	self.baseXP=mission.baseXP or 0
	self.rewardXP=(self.missionClass=="FollowerXP" and self.missionValue) or 0
	self.totalXP=self.baseXP+self.rewardXP
	local t=addon:GetTroopTypes()
	local t1_1,t1_2=addon:GetTroop(t[1],2)
	local t2_1,t2_2=addon:GetTroop(t[2],2)
	local t3_1,t3_2=addon:GetTroop(t[3],2)
	local async=coroutine.running()
	if not async then holdEvents() end
	local n=self.numFollowers or 3
	for i=1,n do
		for _,tuple in pairs(champs[i]) do
			if async then holdEvents() end
			local f1,f2,f3=strsplit(',',tuple)
			f1=empty(f1) and nil or addon:GetFollowerData(f1)
			f2=empty(f1) and nil or addon:GetFollowerData(f2)
			f3=empty(f1) and nil or addon:GetFollowerData(f3)
			print("Match",tuple,f1,f2,f3)
			if i < n then
				if n==3 then
					if i==1 then -- single champ group, adding double follower
						if t1_1 and t1_2 then self:Build(f1,t1_1,t1_2) end -- 2
						if t1_1 and t2_1 then self:Build(f1,t1_1,t2_1) end -- 1 1
						if t1_1 and t3_1 then self:Build(f1,t1_1,t3_1) end -- 1   1
						if t2_1 and t2_2 then self:Build(f1,t2_1,t2_2) end --   2
						if t2_1 and t3_1 then self:Build(f1,t2_1,t3_1) end --   1 1
						if t3_1 and t3_2 then self:Build(f1,t3_1,t3_2) end --     2
					elseif i==2 then -- 2 champ group, adding single follower
						if t1_1 then self:Build(f1,f2,t1_1) end
						if t2_1 then self:Build(f1,f2,t2_1) end
						if t3_1 then self:Build(f1,f2,t3_1) end
					end
				elseif n==2 then
					if t1_1 then self:Build(f1,t1_1) end
					if t2_1 then self:Build(f1,t2_1) end
					if t3_1 then self:Build(f1,t2_1) end
				end
			else
				self:Build(f1,f2,f3) -- Full Champions group
			end
		end
		if async then
			releaseEvents()
			coroutine.yield()
		end
	end
	self:Build()
	if not async then releaseEvents() end
	self.ready=true
	return true
end
function partyManager:GenerateIndex()
	if not self.candidatesIndex then self.candidatesIndex=new() else wipe(self.candidatesIndex) end
	for k,_ in pairs(self.candidates) do
		tinsert(self.candidatesIndex,k)
	end	
	table.sort(self.candidatesIndex)
end	
function module:OnInitialized()
	addon:AddLabel(L["Missions"],L["Configuration for mission party builder"])
	addon:AddBoolean("SAVETROOPS",false,L["Dont kill Troops"],L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"])
	addon:AddBoolean("BONUS",true,L["Keep extra bonus"],L["Always counter no bonus loot threat"])
	addon:AddBoolean("SPARE",false,L["Keep cost low"],L["Always counter increased resource cost"])
	addon:AddBoolean("MAKEITQUICK",true,L["Keep time short"],L["Always counter increased time"])
	addon:AddBoolean("MAKEITVERYQUICK",false,L["Keep time VERY short"],L["Only accept missions with time improved"])
	addon:AddBoolean("MAXIMIZEXP",false,L["Maximize xp gain"],L["Favours leveling follower for xp missions"])
	--addon:AddBoolean("MAXIMIZEMISSIONS",false,L["Maximize filled missions"],L["Attempts to use less champions for missions, in order to fill more missions"])
	addon:AddRange("MAXCHAMP",2,1,3,L["Max champions"],L["Use at most this many champions"])
	addon:AddBoolean("USEALLY",false,L["Use combat ally"],L["Combat ally is proposed for missions so you can consider unassigning him"])
	addon:RegisterForMenu("mission","SAVETROOPS","BONUS","SPARE","MAKEITQUICK","MAKEITVERYQUICK","MAXIMIZEXP",'MAXCHAMP','USEALLY')
	self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED","Refresh")
	self:RegisterEvent("GARRISON_FOLLOWER_UPGRADED","Refresh")
	self:RegisterEvent("GARRISON_FOLLOWER_ADDED","Refresh")
	self:RegisterEvent("GARRISON_MISSION_STARTED","Refresh")
	self:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE","Refresh")	
	self:RegisterEvent("FOLLOWER_LIST_UPDATE","Refresh")	
end
function module:Refresh(event)
	self:ResetParties()
	addon:GetMissionlistModule():SortMissions()
	return addon:RefreshMissions()
end
function module:ResetParties()
	for _,party in pairs(parties) do
		party.ready=false
	end
end
--Public interface
function addon:ApplySAVETROOPS(value)
	return addon:RefreshMissions()
end
function addon:ApplySPARE(value)
	return addon:RefreshMissions()
end
function addon:ApplyMAKEITQUICK(value)
	return addon:RefreshMissions()
end
function addon:ApplyUSEALLY(value)
	return addon:RefreshMissions()
end
function addon:ApplyMAXIMIZEMISSIONS(value)
	return addon:RefreshMissions()
end
function addon:ApplyMAXCHAMP(value)
	return addon:RefreshMissions()
end
function addon:ApplyBONUS(value)
	return addon:RefreshMissions()
end
function addon:ApplyMAKEITVERYQUICK(value)
	return addon:RefreshMissions()
end
function addon:ApplyMAXIMIZEXP(value)
	return addon:RefreshMissions()
end
function addon:HoldEvents()
	return holdEvents()
end
function addon:ReleaseEvents()
	return releaseEvents()
end
function addon:GetSelectedParty(missionID,key)
	return self:GetParties(missionID):GetSelectedParty(key)
end
function addon:ResetParties()
	return module:ResetParties()
end
--[===[@debug@
function addon:TestParty(missionID)
	local parties=self:GetParties(missionID)
	self:Print("Debug for ", missionID,G.GetMissionName(missionID))
	local choosen,choosenkey=GetSelectedParty(parties,true)
	self:Print(choosenkey)
	DevTools_Dump(choosen)
	
	
end
--@end-debug@]===]
function addon:GetParties(missionID)
	if not parties[missionID] then
		parties[missionID]=newParty()
		parties[missionID].missionID=missionID
		parties[missionID].candidates=new()
	end
--[===[@debug@
	local n=0
	for _,_ in pairs(parties) do
		n=n+1
	end
	OHCDebug:Set("NumParties",n)
--@end-debug@	]===]
	return parties[missionID]
end
function addon:GetAllParties()
	return parties
end
function addon:ReFillParties()
	for missionID,_ in pairs(addon:GetMissionData()) do
		self:GetParties(missionID):Match()
	end
end
--[===[@debug@
function addon:SetDebug(id)
	debugMission=id
end
--@end-debug@]===]
