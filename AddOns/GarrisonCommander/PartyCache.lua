local me,ns=...
local pp=print
ns.Configure()
local addon=addon --#addon
--upvalue
local setmetatable=setmetatable
local rawset=rawset
local tContains=tContains
local wipe=wipe
local tremove=tremove
local tinsert=tinsert
local pcall=pcall
local type=type
local pairs=pairs
local format=format
-- Temporary party management
local empty={}
local parties=setmetatable({},{
	__index=function(t,k)  rawset(t,k,
		{
			members={},
			threats={},
			perc=0,
			itemLevel=0,
			followerUpgrade=0,
			xpBonus=0,
			gold=0,
			goldMultiplier=1,
			partyBuffs=empty,
			materialMultiplier=empty,
			resources=0,
			totalTimeString="Not Running",
			totalTimeSeconds=0
		}) return t[k] end
})
function ns.inParty(missionID,followerID)
	return tContains(ns.parties[missionID].members,followerID)
end
--- Follower Missions Info
--
local followerMissions=setmetatable({},{
	__index=function(t,k)  rawset(t,k,{}) return t[k] end
})
local function addPartyMissionInfo(desttable,missionID)
	if type(desttable) == "table" then
		desttable.totalTimeString,
		desttable.totalTimeSeconds,
		desttable.isMissionTimeImproved,
		desttable.perc,
		desttable.partyBuffs,
		desttable.isEnvMechanicCountered,
		desttable.xpBonus,
		desttable.materialMultiplier,
		desttable.goldMultiplier = G.GetPartyMissionInfo(missionID)
	end
end
ns.party={}
local party=ns.party --#party
local ID,maxFollowers,members,ignored,threats=0,1,{},{},{}
function party:Open(missionID,followers)
	maxFollowers=followers
	ID=missionID
	local enemies=select(8,G.GetMissionInfo(ID))
	if (type(enemies)=="table") then
		for enemy,data in pairs(enemies) do
			for menace,more in pairs(data.mechanics) do
				tinsert(threats,format("%d:%d",enemy,menace))
			end
		end
	end
	holdEvents()
end
function party:Ignore(followerID)
	ignored[followerID]=true
end
function party:IsIgnored(followerID)
	return ignored[followerID]
end

function party:IsIn(followerID)
	return tContains(members,followerID)
end
function party:MaxSlots()
	return maxFollowers
end
function party:FreeSlots()
	return maxFollowers-#members
end
function party:CurrentSlot()
	return #members +1
end
function party:IsEmpty()
	return maxFollowers>0 and #members==0
end
function party:IsFull()
	return maxFollowers and #members>=maxFollowers
end

function party:Dump()
--[===[@debug@
	print("Dumping party for mission",ID)
	for i=1,#members do
		print(addon:GetFollowerData(members[i],'fullname'),G.GetFollowerStatus(members[i] or 1))
	end
	print(G.GetPartyMissionInfo(ID))
--@end-debug@]===]
end

function party:AddFollower(followerID)
	if (followerID:sub(1,2) ~= '0x') then ns.xtrace(followerID .. "is not an id") end
	if (self:FreeSlots()>0) then
		local rc,code=pcall (G.AddFollowerToMission,ID,followerID)
		if (not rc and code==false) then
			pcall(G.RemoveFollowerFromMission,ID,followerID)
			rc,code=pcall (G.AddFollowerToMission,ID,followerID)
		end
		if (rc and code) then
			tinsert(members,followerID)
			return true
		end
	end
end
function party:RemoveFollower(followerID)
	for i=1,maxFollowers do
		if (followerID==members[i]) then
			tremove(members,i)
			local rc,code=pcall(G.RemoveFollowerFromMission,ID,followerID)
--[===[@debug@
			if (not rc) then trace("Unable to remove", G.GetFollowerName(members[i]),"from",ID,code) end
--@end-debug@]===]
		return true end
	end
end

function party:StoreFollowers(table)
	wipe(table)
	for i=1,#members do
		tinsert(table,members[i])
	end
	return #table
end
local function fsort(a,b)
	--return addon:GetFollowerData(a,"rank")>addon:GetFollowerData(b,"rank")
	local rank1=addon:GetAnyData(0,a,"rank")
	local rank2=addon:GetAnyData(0,b,"rank")
	if tonumber(rank1) and tonumber(rank2) then
		return rank1 < rank2
	else
--[===[@debug@
		print(a,rank1)
		print(b,rank2)
		print(G.GetFollowerName(a))
		print(G.GetFollowerName(b))
--@end-debug@]===]
		return 0
	end
end
function party:Close(desttable)
	local perc
	table.sort(members,fsort)
	for i=1,#members do
		local bias=G.GetFollowerBiasForMission(ID,members[i])
		for _id,ability in pairs(G.GetFollowerAbilities(members[i])) do
			if not ability.isTrait then
				for counter,data in pairs(ability.counters) do
					for j=1,#threats do
						local enemy,threat,oldbias,follower,name=strsplit(":",threats[j])
						oldbias=tonumber(oldbias) or -2
						if bias >oldbias and tonumber(threat)==tonumber(counter) then
							threats[j]=format("%d:%d:%f:%s:%s",enemy,threat,bias or -2,members[i],G.GetFollowerName(members[i]))
						end
					end
				end
			end
		end
	end
	if (desttable) then
		addPartyMissionInfo(desttable,ID)
		desttable.full=self:FreeSlots()==0
		desttable.threats=desttable.threats or {}
		wipe(desttable.threats)
		for i=1,#threats do
			tinsert(desttable.threats,threats[i])
		end
		perc=desttable.perc
	else
		perc=select(4,G.GetPartyMissionInfo(ID))
	end
	for i=1,3 do
		if (members[i]) then
			local rc,code=pcall(G.RemoveFollowerFromMission,ID,members[i])
--[===[@debug@
			if (not rc) then print("Unable to pop", G.GetFollowerName(members[i])," from ",ID,code,debugstack()) end
--@end-debug@]===]

		else
			break
		end
	end
	releaseEvents()
	wipe(members)
	wipe(ignored)
	wipe(threats)
	return perc or 0
end
function addon:GetParties()
	return self:GetParty()
end

function addon:GetParty(missionID,key,default)
	if not missionID then return parties end
	local party=parties[missionID]
	party.missionID=missionID
	if not party then
--[===[@debug@
		print(GetTime(),missionID,G.GetMissionName(missionID),"Empty")
--@end-debug@]===]
	end
	if not party then return default end
	if #party.members==0 and self:GetMissionData(missionID,'inProgress') then
		party.perc=G.GetMissionSuccessChance(missionID)
		party.full=true
		local followers=self:GetMissionData(missionID,'followers')
		if followers then
			for i=1,#followers do
				party.members[i]=followers[i]
			end
		end
	end
	if key then
		if type(default)=="number" and type(party[key])~="number" then return default end
		return party[key] or default
	else
		return party
	end

end
