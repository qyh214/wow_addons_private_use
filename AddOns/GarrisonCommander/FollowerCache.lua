local me,ns=...
ns.Configure()
--[===[@debug@
print("loaded")
--@end-debug@]===]
local addon=addon --#addon
--local holdEvents,releaseEvents=addon.holdEvents,addon.releaseEvents
--upvalue
local type=type
local select=select
local pairs=pairs
local tonumber=tonumber
local tinsert=tinsert
local tContains=tContains
local wipe=wipe
local Mbase = {}
local GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY=GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY
local GARRISON_FOLLOWER_MAX_LEVEL=GARRISON_FOLLOWER_MAX_LEVEL
local format=format
local tostring=tostring
local GetItemInfo=GetItemInfo
local LE_FOLLOWER_TYPE_GARRISON_6_0=_G.LE_FOLLOWER_TYPE_GARRISON_6_0
local LE_FOLLOWER_TYPE_SHIPYARD_6_2=_G.LE_FOLLOWER_TYPE_SHIPYARD_6_2
local maxrank=GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY*1000+GARRISON_FOLLOWER_MAX_LEVEL
local module=addon:NewSubClass('FollowerCache')
local cache={} --#cache
local followerTypes={}
local EMPTY={}
function module:OnInitialized()
	self:RegisterEvent("GARRISON_FOLLOWER_REMOVED","OnEvent")
	self:RegisterEvent("GARRISON_FOLLOWER_ADDED","OnEvent")
	self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE","OnEvent")
	self:RegisterEvent("GARRISON_FOLLOWER_UPGRADED","OnEvent")
	self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED","OnEvent")
	self.followerCache=cache:new(LE_FOLLOWER_TYPE_GARRISON_6_0)
	self.shipCache=cache:new(LE_FOLLOWER_TYPE_SHIPYARD_6_2)
end
function module:OnEvent(event,...)
	local followerID=...
	if self.shipCache.cache[followerID].followerID then
		self.shipCache:OnEvent(event,...)
	elseif self.followerCache.cache[followerID].followerID then
		self.followerCache:OnEvent(event,...)
	else
		self.followerCache:Wipe()
		self.shipCache:Wipe()
	end

--[===[@debug@
print(event,...)
--@end-debug@]===]
end
function cache:new(type)
	local rc=setmetatable({type=type,names={},sorted={},threats={},traits={},cache={}},{__index=self})
	setmetatable(rc.cache,{__index=function(t,k) return EMPTY end})
	return rc
end
function cache:OnEvent(event,...)

--[===[@debug@
print(event,...)
--@end-debug@]===]
	if event=="GARRISON_FOLLOWER_UPGRADED" or event=="GARRISON_FOLLOWER_XP_CHANGED" then
		local followerID=...
		if (self.cache[followerID]) then
			self:AddExtraData(self.cache[followerID])
			if event=="GARRISON_FOLLOWER_UPGRADED" then
				self:AddAbilities(self.cache[followerID])
			end
		end
	else
		self:Wipe()
	end
end
function cache:Wipe()
	wipe(self.sorted)
	wipe(self.names)
	wipe(self.threats)
	wipe(self.traits)
	wipe(self.cache)
end
function cache:Refresh()
	if next(self.cache) then return end
	self:Wipe()
	for _,follower in pairs(G.GetFollowers(self.type)) do
		followerTypes[follower.followerID]=follower.followerTypeID
		if follower.isCollected then
			self:AddExtraData(follower)
			self:AddAbilities(follower)
			local i=follower.followerID
			self.names[follower.name]=i
			tinsert(self.sorted,i)
			self.cache[i]=follower
		end

	end
end
function cache:AddAbilities(follower)
	if (follower.abilities) then
		local followerID=follower.followerID
		for _,ability in pairs(follower.abilities) do
			local t=self.traits[ability.id]
			if t then
				for i=1,#t do if t[i]==followerID then tremove(t,i) break end end
			end
			if (not ability.isTrait) then
				for id,_ in pairs(ability.counters) do
					local t=self.threats[id]
					if t then
						for i=1,#t do if t[i]==followerID then tremove(t,i) break end end
					end
				end
			end
		end
		follower.abilities=nil
	end
	follower.abilities=G.GetFollowerAbilities(follower.followerID)
	if (follower.abilities) then
		local followerID=follower.followerID
		for _,ability in pairs(follower.abilities) do
			self.traits[ability.id]=self.traits[ability.id]or {}
			tinsert(self.traits[ability.id],followerID)
			if (not ability.isTrait) then
				for id,_ in pairs(ability.counters) do
					self.threats[id]=self.threats[id]or {}
					tinsert(self.threats[id],followerID)
				end
			end
		end
	end

end
function cache:AddExtraData(follower)
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
end

function cache:HasTrait(followerID,trait)
	local list=self.traits[trait]
	if list then return tContains(list,followerID) end
end
function cache:HasAbility(followerID,trait)
	return self:HasTrait(followerID,trait)
end
function cache:CanCounter(followerID,threat)
	local list=self.threats[threat]
	if list then return tContains(list,followerID) end
end
function cache:GetFollowerData(followerID,key,default)
	self:Refresh()
	if type(followerID)~="string" then return self.cache end
	if (followerID:sub(1,2)~="0x") then
		followerID=self.names[followerID]
	end
--[===[@debug@
	assert(followerID)
--@end-debug@]===]
	if not followerID then
		return key and default or EMPTY
	end
	if not key then
		return self.cache[followerID]
	else
		return self.cache[followerID][key] or default
	end
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
function cache:GetFollowersIterator(func)
	self:Refresh()
	if type(func)=="function" then
		table.sort(self.sorted,sorters[func])
	end
	local f=self.cache
	return function(sorted,i)
		i=i+1
		local x = sorted[i]
		if x then
			local v=f[x] and f[x].followerID or nil
			if v then
				return i,v
			end
		end
	end,self.sorted,0
end
function cache:GetFollowersWithTrait(trait)
	self:Refresh()
	return self.traits[trait]
end
function cache:GetFollowersWithCounterFor(threat)
	self:Refresh()
	return self.threats[threat]
end

-- Addon level proxies
function addon:GetAnyData(followerType,...)
	if followerType==0 then
		followerType=self:GetFollowerType(...)
	end
	if followerType== LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
		return self:GetShipData(...)
	else
		return self:GetFollowerData(...)
	end
end
function addon:GetFollowerData(followerID,key,default)
	return module.followerCache:GetFollowerData(followerID,key,default)
end
function addon:GetShipData(followerID,key,default)
	return module.shipCache:GetFollowerData(followerID,key,default)
end
function addon:GetFollowersWithTrait(trait)
	return module.followerCache:GetFollowersWithTrait(trait)
end
function addon:GetFollowersWithCounterFor(threat)
	return module.followerCache:GetFollowersWithCounterFor(threat)
end
function addon:GetFollowersIterator(func)
	return module.followerCache:GetFollowersIterator(func)
end
function addon:GetShipsIterator(func)
	return module.shipCache:GetFollowersIterator(func)
end
function addon:GetAnyIterator(followerType,func)
	if followerType==LE_FOLLOWER_TYPE_GARRISON_6_0 then
		return self:GetFollowersIterator(func)
	else
		return self:GetShipsIterator(func)
	end
end
function addon:GetFollowerType(followerID)
	return followerTypes[followerID] or 0
end