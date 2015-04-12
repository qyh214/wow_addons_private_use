local me,ns=...
local addon=ns.addon --#addon
local holdEvents,releaseEvents=addon.holdEvents,addon.releaseEvents
local xdump=ns.xdump
--upvalue
local C=ns.C
local G=C_Garrison
local GMF=GarrisonMissionFrame
local type=type
local select=select
local pairs=pairs
local tonumber=tonumber
local tinsert=tinsert
local Mbase = GarrisonMissionFrameFollowers
local GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY=GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY
local GARRISON_FOLLOWER_MAX_LEVEL=GARRISON_FOLLOWER_MAX_LEVEL
local format=format
local tostring=tostring
local GetItemInfo=GetItemInfo
local index={}
local names={}
local sorted={}
local threats={}
local traits={}
local function keyToIndex(key)
	if (not Mbase.followers or not next(Mbase.followers)) then
		Mbase.dirtyList=false
		Mbase.followers = G.GetFollowers();
	end
	local idx=key and index[key] or nil
	if (idx and idx <= #Mbase.followers) then
		if Mbase.followers[idx].followerID==key then
			return idx
		else
			idx=nil
		end
	end
	wipe(index)
	wipe(sorted)
	wipe(names)
	wipe(threats)
	wipe(traits)
	for i=1,#Mbase.followers do
		if Mbase.followers[i].isCollected then
			local follower=Mbase.followers[i]
			names[follower.name]=i
			index[follower.followerID]=i
			tinsert(sorted,i)
			if follower.followerID==key or follower.name==key then
				idx=i
			end
			if (follower.abilities) then
				for _,ability in pairs(follower.abilities) do
					traits[ability.id]=traits[ability.id]or {}
					tinsert(traits[ability.id],follower.followerID)
					if (not ability.isTrait) then
						for id,_ in pairs(ability.counters) do
							threats[id]=threats[id]or {}
							tinsert(threats[id],follower.followerID)
						end
					end
				end
			end
		end
	end
	return idx
end
local maxrank=GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY*1000+GARRISON_FOLLOWER_MAX_LEVEL
local function AddExtraData(follower,refreshrank)
	follower.rank=follower.level < GARRISON_FOLLOWER_MAX_LEVEL and follower.level or follower.iLevel
	follower.qLevel=follower.quality*1000+follower.level
	follower.coloredname=C(follower.name,tostring(follower.quality))
	follower.fullname=format("%3d %s",follower.rank,follower.coloredname)
	follower.maxed=follower.qLevel>=maxrank
	local weaponItemID, weaponItemLevel, armorItemID, armorItemLevel = G.GetFollowerItems(follower.followerID);
	follower.weaponItemID=weaponItemID
	follower.weaponItemLevel=weaponItemLevel
	follower.armorItemID=armorItemID
	follower.armorItemLevel=armorItemLevel
	follower.weaponQuality=select(3,GetItemInfo(weaponItemID))
	follower.armorQuality=select(3,GetItemInfo(armorItemID))
	follower.abilities=G.GetFollowerAbilities(follower.followerID)
end
function addon:FollowerCacheInit()
	pcall(GarrisonFollowerList_UpdateFollowers,Mbase)
end
function addon:CanCounter(followerID,id)
	local abilities=self:GetFollowerData(followerID,'abilities')
	for i=1,#abilities do
		local ability=abilities[i]
		for k,v in pairs(ability.counter) do
			if (k==trait or v.name==trait) then
				return true
			end
		end
	end
end
function addon:HasTrait(followerID,trait)
	local list=traits[trait]
	if list then return tContains(list,followerID) end
end
function addon:HasAbility(followerID,trait)
	return self:HasTrait(followerID,trait)
end
function addon:CanCounter(followerID,threat)
	local list=threats[threat]
	if list then return tContains(list,followerID) end
end
function addon:GetFollowerData(followerID,key,default)
	local idx=keyToIndex(followerID)
	local follower=Mbase.followers[idx]
	if (not follower) then
--[===[@debug@
		ns.xprint("Not found",followerID,key,"at",idx,"len",#Mbase.followers)
		print(debugstack())
--@end-debug@]===]
		return default
	end
	if (key==nil) then
		return follower
	end
	if (type(follower[key])~='nil') then
		return follower[key]
	end
	AddExtraData(follower)
	return follower[key] or default
end
local sorters={}
sorters.leveldesc = function(a,b)
	return (Mbase.followers[a].iLevel * 10 + Mbase.followers[a].level) >  (Mbase.followers[b].iLevel * 10 + Mbase.followers[b].level)
end
sorters.levelasc = function(a,b)
	return (Mbase.followers[a].iLevel * 10 + Mbase.followers[a].level) <  (Mbase.followers[b].iLevel * 10 + Mbase.followers[b].level)
end


---@function
-- Iterator function
-- @param func type of sorting (can be mitted if we dont care)
--
function addon:GetFollowerIterator(func)
	keyToIndex()
	if (func) then
		table.sort(sorted,sorters[func])
	end
	local f=Mbase.followers
	return function(sorted,i)
		i=i+1
		local x = sorted[i]
		if x then
			local v=f[x] and f[x].followerID or nil
			if v then
				return i,v
			end
		end
	end,sorted,0
end
function addon:GetFollowersWithTrait(trait)
	return traits[trait]
end
function addon:GetFollowersWithCounterFor(threat)
	return threats[threat]
end