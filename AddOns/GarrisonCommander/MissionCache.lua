local me,ns=...
local addon=ns.addon --#addon
local holdEvents,releaseEvents=addon.holdEvents,addon.releaseEvents
local xdump=ns.xdump
--upvalue
local G=C_Garrison
local GMF=GarrisonMissionFrame
local GMFMissions=GarrisonMissionFrameMissions
local type=type
local select=select
local pairs=pairs
local tonumber=tonumber
local tinsert=tinsert
local wipe=wipe
local GARRISON_CURRENCY=GARRISON_CURRENCY
local GARRISON_FOLLOWER_MAX_LEVEL=GARRISON_FOLLOWER_MAX_LEVEL
local Mbase = GMFMissions
-- self=Mbase
--	C_Garrison.GetInProgressMissions(self.inProgressMissions);
--	C_Garrison.GetAvailableMissions(self.availableMissions);
local Index={}
local sorted={}
local AddExtraData
local function keyToIndex(key)
	local idx=Index[key]
	if (idx and idx <= #Mbase.availableMissions) then
		if Mbase.availableMissions[idx].missionID==key then
			return idx
		else
			idx=nil
		end
	end
	wipe(Index)
	wipe(sorted)
	for i=1,#Mbase.availableMissions do
		Index[Mbase.availableMissions[i].missionID]=i
		tinsert(sorted,i)
		if Mbase.availableMissions[i].missionID==key then
			idx=i
		end
	end
	return idx
end
function addon:GetMissionData(missionID,key,default)
	local idx=keyToIndex(missionID)
	local mission=Mbase.availableMissions[idx]
	if not mission then
		for i=1,#Mbase.inProgressMissions do
			if missionID==Mbase.inProgressMissions[i].missionID then
				mission=Mbase.inProgressMissions[i]
				break
			end
		end
	end
	if (key==nil) then
		return mission
	end
	if (type(mission[key])~='nil') then
		return mission[key]
	end
	if (key=='rank') then
		mission.rank=mission.level < GARRISON_FOLLOWER_MAX_LEVEL and mission.level or mission.iLevel
		return mission.rank
	elseif(key=='basePerc') then
		mission.basePerc=select(4,G.GetPartyMissionInfo(missionID))
		return mission.basePerc
	else
		AddExtraData(mission)
		return mission[key] or default
	end
end
function AddExtraData(mission)
	local _
	_,mission.xp,mission.type,mission.typeDesc,mission.typeIcon,mission.locPrefix,_,mission.enemies=G.GetMissionInfo(mission.missionID)
	mission.rank=mission.level < GARRISON_FOLLOWER_MAX_LEVEL and mission.level or mission.iLevel
	mission.resources=0
	mission.gold=0
	mission.followerUpgrade=0
	mission.itemLevel=0
	mission.xpBonus=0
	local numrewards=0
	for k,v in pairs(mission.rewards) do
		numrewards=numrewards+1
		if (k==615 and v.followerXP) then mission.xpBonus=mission.xpBonus+v.followerXP end
		if (v.currencyID and v.currencyID==GARRISON_CURRENCY) then mission.resources=v.quantity end
		if (v.currencyID and v.currencyID==0) then mission.gold =mission.gold+v.quantity/10000 end
		if (v.icon=="Interface\\Icons\\XPBonus_Icon" and v.followerXP) then
			mission.xpBonus=mission.xpBonus+v.followerXP
		elseif (v.itemID) then
			if (v.itemID~=120205) then
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(v.itemID)
				if (itemName and (not v.quantity or v.quantity==1) and not v.followerXP ) then
					if (itemLevel > 1 and itemMinLevel >=90 ) then
						mission.itemLevel=itemLevel
					else
						mission.followerUpgrade=itemRarity
					end
				end
			end
		end
	end
	if (mission.resources==0 and mission.gold==0 and mission.itemLevel==0 and mission.followerUpgrade==0 and numrewards <2) then
		mission.xpOnly=true
		mission.class="xp"
	else
		mission.xpOnly=false
		if mission.resources > 0 then
			mission.class='resources'
		elseif mission.gold >0 then
			mission.class='gold'
		elseif mission.itemLevel >0 then
			mission.class='equip'
		elseif mission.followerUpgrade>0 then
			mission.class='followerEquip'
		elseif mission.itemLevel>=645 then
			mission.class='epic'
		else
			mission.class='generic'
		end
	end
	mission.globalXp=(mission.xp+mission.xpBonus+(addon:GetParty(mission.missionID)['xpBonus'] or 0) )*mission.numFollowers

end
function addon:OnAllMissions(func,inProgress)
	local list=inProgress and Mbase.inProgressMissions or Mbase.availableMissions
	if type(list)=='table' then
		for i=1,#list do
			func(list[i].missionID)
		end
	end
end
local sorters={}

function addon:GetMissionIterator(func)
	if (func) then
		table.sort(sorted,sorters[func])
	end
	local f=Mbase.availableMissions
	return function(sorted,i)
		i=i+1
		local x = sorted[i]
		if x then
			local v=f[x] and f[x].missionID or nil
			if v then
				return i,v
			end
		end
	end,sorted,0
end
