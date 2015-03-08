local me,ns=...
local pp=print
local addon=ns.addon --#addon
local C=ns.C
local P=ns.party
local _G=_G
local holdEvents,releaseEvents=addon.holdEvents,addon.releaseEvents
local new, del, copy =ns.new,ns.del,ns.copy
--upvalue
local G=C_Garrison
local GMFRewardSplash=GarrisonMissionFrameMissions.CompleteDialog
local pairs=pairs
local format=format
local tonumber=tonumber
local tinsert=tinsert
local tremove=tremove
local loadstring=loadstring
local assert=assert
local rawset=rawset
local strsplit=strsplit
local epicMountTrait=221
local extraTrainingTrait=80 --all followers +35
local fastLearnerTrait=29 -- only this follower +50
local hearthStoneProTrait=236 -- all followers +36
local scavengerTrait=79 -- More resources
local dbg
local xprint=function(...) if dbg then ns.xprint(...) end end
local xdump=function(...) if dbg then ns.xdump(...) end end
function addon:MissionScore(mission)
	local totalTimeString, totalTimeSeconds, isMissionTimeImproved, successChance, partyBuffs, isEnvMechanicCountered, xpBonus, materialMultiplier,goldMultiplier = G.GetPartyMissionInfo(mission.missionID)
	local r=mission.class=='resource' and materialMultiplier or xpBonus/10
	local t=isMissionTimeImproved and 1 or 0
	if r > 9999 then r= 999 end
	return format("%03d%03d%01d",successChance,r,t)
end
function addon:FollowerScore(mission,followerID)
	local totalTimeString, totalTimeSeconds, isMissionTimeImproved, successChance, partyBuffs, isEnvMechanicCountered, xpBonus, materialMultiplier,goldMultiplier = G.GetPartyMissionInfo(mission.missionID)
	local r=0
	if mission.class=='resource' then r=materialMultiplier
	--elseif mission.class=='xp' then r= xpBonus -- all time bonus
	elseif mission.class=='gold' then r= goldMultiplier
	else r=xpBonus>0 and 1 or 0
	end

	local t=isMissionTimeImproved and 1 or 0
	local c=(isEnvMechanicCountered and 1 or 0)+#partyBuffs
	return format("%03d%01d%01d%01d%04d",successChance,r,c,t,10000-self:GetFollowerData(followerID,'rank',0))
end
local filters={skipMaxed=false,skipBusy=false}
function filters.nop(followerID)
	return true
end
function filters.maxed(followerID,missionID)
	return filters.skipMaxed and addon:GetFollowerData(followerID,'maxed') or false
end
function filters.busy(followerID,missionID)
	return not addon:IsFollowerAvailableForMission(followerID,filters.skipBusy)
end
function filters.ignored(followerID,missionID)
	return addon:IsIgnored(followerID,missionID)
end
function filters.generic(followerID,missionID)
	return filters.busy(followerID,missionID) or filters.ignored(followerID,missionID)
end
function filters.xp(followerID,missionID)
	return filters.maxed(followerID,missionID) or filters.generic(followerID,missionID)
end
--alias
filters.resources=filters.generic
filters.gold=filters.generic
filters.equip=filters.generic
filters.followerEquip=filters.generic
filters.epic=filters.generic
local nop={addRow=function() end}
local scroller=nop
local function CreateFilter(missionClass)
	local code = [[
	local filters,xprint,pairs = ...
	local function filterdata(followers,missionID)
		for followerID,_ in pairs(followers) do
			if TEST then
				xprint("Removing",C_Garrison.GetFollowerName(followerID),"due to TEST", TEST)
				followers[followerID] = nil
			else
				xprint("Keeping",C_Garrison.GetFollowerName(followerID),"due to TEST", TEST)
			end
		end
	end
	return filterdata
	]]
	code = code:gsub("TEST", " filters." ..missionClass .."(followerID,missionID)")
	xprint("Compiling ",missionClass,"filter")
	return assert(loadstring(code, "Filter for " .. missionClass))(filters,xprint,pairs)
end

local filterTypes = setmetatable({}, {__index=function(self, missionClass)
	local filter = CreateFilter(missionClass)
	rawset(self, missionClass, CreateFilter(missionClass))
	return filter
end})
local function AddMoreFollowers(self,mission,scores,justdo)
	local missionID=mission.missionID
	local filter=filters[mission.class]
	local missionScore=self:MissionScore(mission)

	for p=1,P:FreeSlots() do
		if dbg then
			scroller:AddRow("--------------------- Slot " .. P:CurrentSlot() .. " ------------------")
		end
		local candidate=nil
		local candidateScore=missionScore
		for i=1,#scores do
			local score,followerID=strsplit('|',scores[i])
			if (not filter(followerID,missionID) and not P:IsIn(followerID)) then
				P:AddFollower(followerID)
				local newScore=self:MissionScore(mission)
				if dbg then
					local c1,c2="green","red"
					if newScore > candidateScore or justdo then
						c1="red"
						c2="green"
					end
					scroller:AddRow(addon:GetFollowerData(followerID,'fullname') .." changes score from " .. C(candidateScore,c1).." to "..C(newScore,c2))
				end
				if (newScore > candidateScore or justdo) then
					candidate=followerID
					candidateScore=newScore
				end
				P:RemoveFollower(followerID)
			end
		end
		if candidate then
			local slot=P:CurrentSlot()
			if P:AddFollower(candidate) and dbg then
				scroller:addRow(C("Slot " .. slot..":","Green").. " " .. addon:GetFollowerData(candidate,'fullname'))
			end
			candidate=nil
		end
	end
end
local function MatchMaker(self,missionID,party,includeBusy,onlyBest)
	local mission=self:GetMissionData(missionID)
	local class=self:GetMissionData(missionID,'class')
	xprint(C(format("MATCHMAKER %s (%d) class: %s",mission.name,missionID,class),'Orange'),includeBusy and "Busy" or "Ready")
	local filter=filters[class]
	filters.skipMaxed=self:GetBoolean("IGP")
	if (includeBusy==nil) then
		filters.skipBusy=self:GetBoolean("IGM")
	else
		filters.skipBusy=not includeBusy
	end
	local scores=new()
	local buffed=G.GetBuffedFollowersForMission(missionID)
	local traits=G.GetFollowersTraitsForMission(missionID)
	local buffeds=0
	local mechanics=G.GetMissionUncounteredMechanics(missionID)
	P:Open(missionID,mission.numFollowers)
	--G.GetFollowerBiasForMission(missionID,followerID)
	for followerID,_ in pairs(buffed) do
		P:AddFollower(followerID)
		tinsert(scores,format("%010d1|%s",self:FollowerScore(mission,followerID),followerID))
		P:RemoveFollower(followerID)
		buffeds=buffeds+1
	end
	for _,followerID in self:GetFollowerIterator() do
		if (not buffed[followerID]) then
			P:AddFollower(followerID)
			tinsert(scores,format("%010d0|%s",self:FollowerScore(mission,followerID),followerID))
			P:RemoveFollower(followerID)
		end
	end
	if #scores > 0 then
		local firstmember
		table.sort(scores)
		if (dbg) then
			for i=1,#scores do
				local score,followerID=strsplit('|',scores[i])
				local t=score:gsub("(%d%d%d)(%d)(%d)(%d)(%d*)","%1%% r:%2 t:%3d b:%4 Rank:%5 ") .. addon:GetFollowerData(followerID,'fullname') .. " " .. tostring(G.GetFollowerStatus(followerID))
				scroller:addRow(t)
			end
		else
			scroller=nop
		end
		for i=#scores,1,-1 do
			local score,followerID=strsplit('|',scores[i])
			if not firstmember and not filter(followerID,missionID) then
				firstmember=followerID
				break
			end
		end
		if firstmember then
			if P:AddFollower(firstmember) and dbg then
				scroller:AddRow(C("Slot 1:","Green").. " " .. addon:GetFollowerData(firstmember,'fullname'))
			end
			if mission.numFollowers > 1 then
				AddMoreFollowers(self,mission,scores)
			end
		end
	end
	if P:FreeSlots() > 0 then
		if not onlyBest then
			filters.skipMaxed=false
			xprint("           AddMore 1 with skipmaxed false",filters.skipMaxed)
			AddMoreFollowers(self,mission,scores)
		end
	end
	if P:FreeSlots() > 0 then
		filters.skipMaxed=false
		xprint("           AddMore 1 with just do true")
		AddMoreFollowers(self,mission,scores,true)
	end
	if dbg then P:Dump() end
	xprint("Final score",self:MissionScore(mission))
	if not party.class then
		party.class=class
		party.itemLevel=mission.itemLevel
		party.followerUpgrade=mission.followerUpgrade
		party.xpBonus=mission.xpBonus
		party.gold=mission.gold
		party.resources=mission.resources
	end
	P:StoreFollowers(party.members)
	P:Close(party)
	del(buffed)
end
function addon:MCMatchMaker(missionID,party)
	MatchMaker(self,missionID,party,false)
	if (self:GetMissionData(missionID,'class')=='xp') then
		for i=1,#party.members do
			if not self:GetFollowerData(party.members[i],'maxed') then
				return
			end
		end
		party.full=false
		wipe(party.members)
	end
end
function addon:MatchMaker(missionID,party,includeBusy)
	if (not party) then party=self:GetParty(missionID) end
	MatchMaker(self,missionID,party,includeBusy)
end
function addon:TestMission(missionID,includeBusy)
	dbg=true
	scroller=self:GetScroller("Scores")
	local party=new()
	party.members=new()
	self:MatchMaker(missionID,party,includeBusy)
--[===[@debug@
	DevTools_Dump(party)
--@end-debug@]===]
	del(party.members)
	del(party)
	scroller=nop
	dbg=false
end
function addon:MatchDebug(d)
	dbg=d
end


