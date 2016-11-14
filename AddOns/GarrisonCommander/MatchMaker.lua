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
local LE_FOLLOWER_TYPE_GARRISON_6_0=_G.LE_FOLLOWER_TYPE_GARRISON_6_0 -- 1
local LE_FOLLOWER_TYPE_SHIPYARD_6_2=_G.LE_FOLLOWER_TYPE_SHIPYARD_6_2 -- 2
local LE_FOLLOWER_TYPE_GARRISON_7_0=_G.LE_FOLLOWER_TYPE_GARRISON_7_0 -- 4
local dbg
local useCap=false
local currentCap=100
local testID=0

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
		if not totalTimeString then
			return formatScore(0,1,0,0,false,0)
		end
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
	return format("%s %d %04d",score,self:GetAnyData(0,followerID,'durability',0),followerID and math.min(1000-self:GetAnyData(0,followerID,'rank',90),999)),chance
end
local filters={skipMaxed=false,skipBusy=false}
function filters.nop(followerID)
	return true
end
function filters.maxed(followerID,missionID)
	return filters.skipMaxed and addon:GetAnyData(0,followerID,'maxed') or false
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
--[[
local filters={skipMaxed=false,skipBusy=true,skipTroops=false,skipIgnored=true}
setmetatable(filters,{
	__call=function(t,followerID,missionID)
		local follower=addon:GetAnyData(0,followerID)
		if t.skipMaxed then return follower.maxed end
		if t.skipTroops then return follower.isTroop end
		if t.skipBusy then return addon:IsFollowerAvailableForMission(followerID,t.skipBusy) end
		if t.skipIgnored then return addon:IsIgnored(followerID,missionID) end
	end,
	__index=function(t,key) return t end
}
)
--]]
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
local function AddMoreFollowers(self,mission,scores,justdo,max)
	if #scores==0 then return end
	local missionID=mission.missionID
	local filterOut=filters[mission.class] or filters.other
	local missionScore=self:MissionScore(mission)
--[===[@debug@
	if missionID==testID then
		print("AddMoreFollowers called with ",#scores,justdo,justone,P:FreeSlots())
	end
	if dbg then
		scroller:AddRow("AddMore")
	end
--@end-debug@]===]
	max=max or P:FreeSlots()
	for p=1,math.min(max,P:FreeSlots()) do
--[===[@debug@
		if dbg then
			scroller:AddRow("--------------------- Slot " .. P:CurrentSlot() .. " ------------------")
		end
--@end-debug@]===]
		local candidate=nil
		local candidateScore=missionScore
		for i=1,#scores do
			local score,followerID,name=strsplit('@',scores[i])
--[===[@debug@
			if missionID==testID then
				print("Checking",i,followerID,name,score)
			end
--@end-debug@]===]
			if (not filterOut(followerID,missionID) and not P:IsIn(followerID)) then
				P:AddFollower(followerID)
				local newScore=self:MissionScore(mission)
--[===[@debug@
				if missionID==testID then
					print("Temp add",followerID,P:FreeSlots())
				end
				if dbg then
					local c1,c2="green","red"
					if newScore > candidateScore or justdo then
						c1="red"
						c2="green"
					end
					scroller:AddRow(addon:GetAnyData(0,followerID,'fullname') .." changes score from " .. C(candidateScore,c1).." to "..C(newScore,c2))
				end
--@end-debug@]===]
				if (newScore > candidateScore or justdo) then
					candidate=followerID
					candidateScore=newScore
				end
				P:RemoveFollower(followerID)
--[===[@debug@
				if missionID==testID then
					print("Remove:",followerID,P:FreeSlots())
				end
--@end-debug@]===]
			end
		end
		if candidate then
			local slot=P:CurrentSlot()
			if P:AddFollower(candidate,scroller) and dbg then
--[===[@debug@
				if missionID==testID then
					print("Added",candidate,addon:GetAnyData(0,candidate,'fullname'))
				end
--@end-debug@]===]
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
	local followerType=mission.followerTypeID
	local hallMission=followerType==LE_FOLLOWER_TYPE_GARRISON_7_0
	if followerType==LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
		filters.skipMaxed=false
	end

	if (includeBusy==nil) then
		filters.skipBusy=self:GetBoolean("IGM")
	else
		filters.skipBusy=not includeBusy
	end
	local scores=new()
	local troops=new()
	P:Open(missionID,mission.numFollowers)
	local missionTypeID=mission.followerTypeID
	for _,followerID in self:GetAnyIterator(missionTypeID) do
		if self:IsFollowerAvailableForMission(followerID,filters.skipBusy) then
			if P:AddFollower(followerID) then
				local score,chance=self:FollowerScore(mission,followerID)
				if hallMission and self:GetHeroData(followerID,'isTroop') then
					tinsert(troops,format("%s@%s@%s",score,followerID,self:GetAnyData(missionTypeID,followerID,'fullname')))
				else
					tinsert(scores,format("%s@%s@%s",score,followerID,self:GetAnyData(missionTypeID,followerID,'fullname')))
				end
				P:RemoveFollower(followerID)
			end
		end
	end
--[===[@debug@
	if dbg then
		scroller=self:GetScroller("Score for " .. mission.name .. " Class " .. mission.class)
	end
	if missionID == testID then
		print("Scores")
		for i=1,#scores do print(scores[i]) end
		print("Troops")
		for i=1,#troops do print(troops[i]) end
	end
--@end-debug@]===]
	table.sort(scores)
	table.sort(troops)
	local firstmember
	if #scores > 0 then
--[===[@debug@
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
--@end-debug@]===]
		for i=#scores,1,-1 do
			local score,followerID=strsplit('@',scores[i])
			if not filterOut(followerID,missionID) then
				firstmember=followerID
				break
			end
		end
		if firstmember then
			if P:AddFollower(firstmember) and dbg then
--[===[@debug@
				scroller:addRow(C("Slot 1:","Green").. " " .. addon:GetAnyData(0,firstmember,'fullname'))
--@end-debug@]===]
			end
			if mission.numFollowers > 1 then
				if missionTypeID== LE_FOLLOWER_TYPE_GARRISON_7_0 then
					local nf=#scores
					local nt=#troops
					local total=#GHFMissions.availableMissions
					local maxtroops=0
					if total==1 then
						AddMoreFollowers(self,mission,scores)
						AddMoreFollowers(self,mission,troops)
					else
						local mm=math.floor((nt+nt)/3)
						if mm==1 then
							maxtroops=0
						else
							maxtroops=1
						end
						AddMoreFollowers(self,mission,troops,false,maxtroops)
					end
				else
					AddMoreFollowers(self,mission,scores)
				end
			end
		end
		if P:FreeSlots() > 0 then
			if not onlyBest then
				filters.skipMaxed=false
				AddMoreFollowers(self,mission,scores)
				AddMoreFollowers(self,mission,troops)
			end
		end
		if P:FreeSlots() > 0 then
			filters.skipMaxed=false
			AddMoreFollowers(self,mission,scores,true)
			AddMoreFollowers(self,mission,troops,true)
		end
--[===[@debug@
		if dbg then
			scroller:addRow("Final score: " .. self:MissionScore(mission))
		end
--@end-debug@]===]
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
	del(scores)
	del(troops)
end
function addon:MCMatchMaker(missionID,party,skipEpic,cap)
	local mission=type(missionID)=="table" and missionID or self:GetMissionData(missionID)
	missionID=mission.missionID
	if (not party) then party=addon:GetParty(missionID) end
--[===[@debug@
	print("Using cap data:",cap)
--@end-debug@]===]
	MatchMaker(self,mission,party,false,true,cap)
	if (skipEpic) then
		if (self:GetMissionData(missionID,'class')=='xp') then
			for i=1,#party.members do
				if not self:GetAnyData(0,party.members[i],'maxed') then
					return
				end
			end
			party.full=false
			wipe(party.members)
		end
	end
	return party.perc
end
function addon:MatchMaker(missionID,party,includeBusy,useCap,currentCap)
	self:SetTest(1052)
	local mission=type(missionID)=="table" and missionID or self:GetMissionData(missionID)
	if not mission then return 0 end
	missionID=mission.missionID
	if (not party) then party=addon:GetParty(missionID) end
	useCap=useCap or self:GetBoolean("MAXRES")
	currentCap=currentCap or self:GetNumber("MAXRESCHANCE")
--[===[@debug@
	if missionID==testID then
		print("Matchmaker start",missionID,mission.name,mission.class,useCap,currentCap)
		pcall(party)
	end
--@end-debug@]===]
	MatchMaker(self,mission,party,includeBusy)
	if (missionID==testID) then
		for i=1,#party.members do
			print(party.members[i],self:GetAnyData(0,party.members[i],'fullname'))
		end
	end
	return party.perc
end
function addon:SetTest(num)
	testID=num
end
function addon:TestMission(missionID,includeBusy)
	local mission=type(missionID)=="table" and missionID or self:GetMissionData(missionID)
	missionID=mission.missionID
	dbg=true
	local party=new()
	party.members=new()
	self:MatchMaker(mission,party,includeBusy)
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
	del(party.members)
	del(party)
	scroller=nop
	dbg=false
end
function addon:MatchDebug(d)
	dbg=d
end


