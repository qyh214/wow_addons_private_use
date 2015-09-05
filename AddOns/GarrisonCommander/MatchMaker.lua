local me,ns=...
ns.Configure()
local addon=addon --#addon
local _G=_G
local P=ns.party
--local holdEvents,releaseEvents=addon.holdEvents,addon.releaseEvents
--local new, del, copy =ns.new,ns.del,ns.copy
--upvalue
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
local GARRISON_CURRENCY=GARRISON_CURRENCY
local GARRISON_SHIP_OIL_CURRENCY=GARRISON_SHIP_OIL_CURRENCY
local dbg
local useCap=false
local currentCap=100

local function formatScore(c,r,x,t,maxres,cap)
	c=tonumber(c) or 0
	r=tonumber(r) or 0
	x=tonumber(x) or 0
	t=tonumber(t) or 0
	cap=tonumber(cap) or 100
	if (not maxres) then cap=100 end
	return format("%03d %03d %03d %03d %01d",math.min(c,cap),r,c,x,t),c
end

-- Empty lines to keep line numbers in sync

function addon:MissionScore(mission)
	if (mission) then
		local totalTimeString, totalTimeSeconds, isMissionTimeImproved, successChance, partyBuffs, isEnvMechanicCountered, xpBonus, materialMultiplier,goldMultiplier = G.GetPartyMissionInfo(mission.missionID)
		local x = tonumber(mission.xp)
		if x and x >0 then
			x= xpBonus/mission.xp*100
		else
			x=0
		end
		local r=0
		if type(materialMultiplier)=='table' then
			for _,v in pairs(mission.rewards) do
				if v.currencyID then
					if v.currencyID==0 then
						r=r+goldMultiplier
					else
						r=r+(materialMultiplier[v.currencyID] or 0)
					end
				end
			end
		end
		local t=isMissionTimeImproved and 1 or 0
		return formatScore(successChance,r,x,t,mission.maxable and self:GetBoolean("MAXRES"),self:GetNumber("MAXRESCHANCE"))
	else
		return formatScore(0,1,0,0,false,0)
	end
end


function addon:FollowerScore(mission,followerID)
	local score,chance=self:MissionScore(mission)
	return format("%s %04d",score,followerID and math.min(1000-self:GetFollowerData(followerID,'rank',90),999)),chance
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
function filters.other(followerID,missionID)
	return filters.busy(followerID,missionID) or filters.ignored(followerID,missionID)
end
function filters.xp(followerID,missionID)
	return filters.maxed(followerID,missionID) or filters.other(followerID,missionID)
end
--alias

local nop={addRow=function() end}
local scroller=nop
local function CreateFilter(missionClass)
	local code = [[
	local filters,print,pairs = ...
	local function filterdata(followers,missionID)
		for followerID,_ in pairs(followers) do
			if TEST then
				print("Removing",C_Garrison.GetFollowerName(followerID),"due to TEST", TEST)
				followers[followerID] = nil
			else
				print("Keeping",C_Garrison.GetFollowerName(followerID),"due to TEST", TEST)
			end
		end
	end
	return filterdata
	]]
	code = code:gsub("TEST", " filters." ..missionClass .."(followerID,missionID)")

--[===[@debug@
print("Compiling ",missionClass,"filterOut")
--@end-debug@]===]
	return assert(loadstring(code, "filterOut for " .. missionClass))(filters,print,pairs)
end

local filterTypes = setmetatable({}, {__index=function(self, missionClass)
	local filterOut = CreateFilter(missionClass)
	rawset(self, missionClass, CreateFilter(missionClass))
	return filterOut
end})
local function AddMoreFollowers(self,mission,scores,justdo)
	local missionID=mission.missionID
	local filterOut=filters[mission.class] or filters.other
	local missionScore=self:MissionScore(mission)

	for p=1,P:FreeSlots() do
		if dbg then
			scroller:AddRow("--------------------- Slot " .. P:CurrentSlot() .. " ------------------")
		end
		local candidate=nil
		local candidateScore=missionScore
		for i=1,#scores do
			local score,followerID,chance=strsplit('@',scores[i])
			if (not filterOut(followerID,missionID) and not P:IsIn(followerID)) then
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
local function MatchMaker(self,mission,party,includeBusy,onlyBest)
	local class=mission.class
	local missionID=mission.missionID
	local filterOut=filters[class] or filters.other
	filters.skipMaxed=self:GetBoolean("IGP")
	if (includeBusy==nil) then
		filters.skipBusy=self:GetBoolean("IGM")
	else
		filters.skipBusy=not includeBusy
	end
	local scores=new()
	local fillers=new()
	P:Open(missionID,mission.numFollowers)
	--[[
	local buffed=G.GetBuffedFollowersForMission(missionID)
	local traits=G.GetFollowersTraitsForMission(missionID)
	local buffeds=0
	local mechanics=G.GetMissionUncounteredMechanics(missionID)
	--G.GetFollowerBiasForMission(missionID,followerID)
	for followerID,_ in pairs(buffed) do
		P:AddFollower(followerID)
		-- dirty trick to avoid issue with integer overflow
		local followerScore=self:FollowerScore(mission,followerID)
		tinsert(scores,format("%s1|%s",self:FollowerScore(mission,followerID),followerID))
		P:RemoveFollower(followerID)
		buffeds=buffeds+1
	end
	--]]
	local minchance=floor(currentCap/mission.numFollowers)-mission.numFollowers*mission.numFollowers
	for _,followerID in self:GetAnyIterator(mission.followerTypeID) do
		if self:IsFollowerAvailableForMission(followerID,filters.skipBusy) then
			if P:AddFollower(followerID) then
				local score,chance=self:FollowerScore(mission,followerID)
				if (score~=self:FollowerScore(nil,followerID) and chance >minchance) then
					tinsert(scores,format("%s@%s",score,followerID))
				else
					tinsert(scores,format("%s@%s",score,followerID))
				end
				P:RemoveFollower(followerID)
			end
		end
		--end
	end
	if dbg then
		scroller=self:GetScroller("Score for " .. mission.name .. " Class " .. mission.class)
	end
	if #scores > 0 then
		local firstmember
		table.sort(scores)
		if (dbg) then
			scroller:addRow("Cap Res Cha Xp T Vra Ran")
			for i=1,#scores do
				local score,followerID=strsplit('@',scores[i])
				local t=score .. " " .. addon:GetAnyData(mission.followerTypeID,followerID,'fullname') .. " " .. tostring(G.GetFollowerStatus(followerID))
				scroller:addRow(t)
			end
		else
			scroller=nop
		end
		for i=#scores,1,-1 do
			local score,followerID=strsplit('@',scores[i])
			if not firstmember and not filterOut(followerID,missionID) then
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
				AddMoreFollowers(self,mission,fillers)
			end
		end
	end
	if P:FreeSlots() > 0 then
		if not onlyBest then
			filters.skipMaxed=false
			AddMoreFollowers(self,mission,scores)
		end
	end
	if P:FreeSlots() > 0 then
		filters.skipMaxed=false
		AddMoreFollowers(self,mission,scores,true)
	end
	if P:FreeSlots() > 0 then
		filters.skipMaxed=false
		AddMoreFollowers(self,mission,fillers,true)
	end
	if dbg then
		P:Dump()
		scroller:AddRow("Final score: " .. self:MissionScore(mission))
	end
	if not party.class then
		party.class=class
		party.itemLevel=mission.itemLevel
		party.followerUpgrade=mission.followerUpgrade
		party.xpBonus=mission.xpBonus
		party.gold=mission.gold
		party.resources=mission.resources
		party.oil=mission.oil
		party.apexis=mission.apexis
		party.seal=mission.seal
		party.other=mission.other
		party.rush=mission.rush
	end
	P:StoreFollowers(party.members)
	P:Close(party)
	--del(buffed)
end
function addon:MCMatchMaker(missionID,party,skipEpic,cap)
	local mission=type(missionID)=="table" and missionID or self:GetMissionData(missionID)
	missionID=mission.missionID
	if (not party) then party=addon:GetParty(missionID) end
	useCap=true
	currentCap=cap

--[===[@debug@
print("Using cap data:",useCap,currentCap)
--@end-debug@]===]
	MatchMaker(self,mission,party,false)
	if (skipEpic) then
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
	return party.perc
end
function addon:MatchMaker(missionID,party,includeBusy)
	local mission=type(missionID)=="table" and missionID or self:GetMissionData(missionID)
	missionID=mission.missionID
	if (not party) then party=addon:GetParty(missionID) end
	useCap=self:GetBoolean("MAXRES")
	currentCap= self:GetNumber("MAXRESCHANCE")
	MatchMaker(self,mission,party,includeBusy)
	return party.perc
end
function addon:TestMission(missionID,includeBusy)
	local mission=type(missionID)=="table" and missionID or self:GetMissionData(missionID)
	missionID=mission.missionID
	dbg=true
	local party=new()
	party.members=new()
	self:MatchMaker(mission,party,includeBusy)
--[===[@debug@
	DevTools_Dump(party)
--@end-debug@]===]
	del(party.members)
	del(party)
	scroller=nop
	dbg=false
end
function addon:MCTestMission(missionID,includeBusy,chance)
	local mission=type(missionID)=="table" and missionID or self:GetMissionData(missionID)
	missionID=mission.missionID
	dbg=true
	local party=new()
	party.members=new()
	self:MCMatchMaker(mission,party,includeBusy,true,chance)
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


