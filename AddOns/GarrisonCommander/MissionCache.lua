local me,ns=...
ns.Configure()
local addon=addon --#addon
--local holdEvents,releaseEvents=addon.holdEvents,addon.releaseEvents
local type=type
local select=select
local pairs=pairs
local tonumber=tonumber
local tinsert=tinsert
local tcontains=tContains
local wipe=wipe
local GARRISON_CURRENCY=GARRISON_CURRENCY
local GARRISON_SHIP_OIL_CURRENCY=GARRISON_SHIP_OIL_CURRENCY
local GARRISON_FOLLOWER_MAX_LEVEL=GARRISON_FOLLOWER_MAX_LEVEL
local LE_FOLLOWER_TYPE_GARRISON_6_0=_G.LE_FOLLOWER_TYPE_GARRISON_6_0
local LE_FOLLOWER_TYPE_SHIPYARD_6_2=_G.LE_FOLLOWER_TYPE_SHIPYARD_6_2
local newcache=true
local cache={}
-- Mission caching is a bit different fron follower caching mission appears and disappears on a regular basis
local module=addon:NewSubClass('MissionCache') --#module
function module:OnInitialized()
	self:HookScript(GMF,"OnShow","PanelOpened",false)
	self:HookScript(GMF,"OnHide","PanelClosed",false)
	self:HookScript(GSF,"OnShow","PanelOpened",false)
	self:HookScript(GSF,"OnHide","PanelOpened",fakse)
end
local function load(t,inProgress)
	for i=1,#t do
		local missionID=t[i].missionID
		if type(cache[missionID]) ~="table" then
			cache[missionID]={followerType=t[i].followerType,missionID=missionID}
			module:AddExtraData(cache[missionID])
		end
		cache[missionID].index=i
		cache[missionID].inProgress=inProgress
	end
end
function module:PanelOpened(frame,...)
	local followerType=LE_FOLLOWER_TYPE_SHIPYARD_6_2
	if (frame:GetName()=="GarrisonMissionFrame") then
		followerType=LE_FOLLOWER_TYPE_GARRISON_6_0
		local t=new()
		G.GetAvailableMissions(t,followerType)
		load(t,false)
		wipe(t)
		G.GetInProgressMissions(t,followerType)
		load(t,true)
		del(t)
	end
end
function module:PanelClosed(frame,...)

end
function addon:GetMission(id)
	return cache[id]
end
function module:AddExtraData(mission)
	local _
	_,mission.xp,mission.type,mission.typeDesc,mission.typeIcon,mission.locPrefix,_,mission.enemies=G.GetMissionInfo(mission.missionID)
	if mission.level then
		mission.rank=mission.level < GARRISON_FOLLOWER_MAX_LEVEL and mission.level or mission.iLevel
	end
	mission.resources=0
	mission.oil=0
	mission.apexis=0
	mission.seal=0
	mission.gold=0
	mission.followerUpgrade=0
	mission.itemLevel=0
	mission.xpBonus=0
	mission.others=0
	mission.xp=mission.xp or 0
	mission.rush=0
	mission.chanceCap=100
	local numrewards=0
	local rewards=mission.rewards
	if not rewards then
		rewards=G.GetMissionRewardInfo(mission.missionID)
	end
	for k,v in pairs(rewards) do
		numrewards=numrewards+1
		if k==615 and v.followerXP then mission.xpBonus=mission.xpBonus+v.followerXP end
		if v.currencyID and v.currencyID==GARRISON_CURRENCY then mission.resources=v.quantity end
		if v.currencyID and v.currencyID==GARRISON_SHIP_OIL_CURRENCY then mission.oil=v.quantity end
		if v.currencyID and v.currencyID==823 then mission.apexis =mission.apexis+v.quantity end
		if v.currencyID and v.currencyID==994 then mission.seal =mission.seal+v.quantity end
		if v.currencyID and v.currencyID==0 then mission.gold =mission.gold+v.quantity/10000 end
		if v.icon=="Interface\\Icons\\XPBonus_Icon" and v.followerXP then
			mission.xpBonus=mission.xpBonus+v.followerXP
		elseif (v.itemID) then
			if v.itemID~=120205 then -- xp item
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(v.itemID)
				if (not itemName or not itemTexture) then
					mission.class="retry"
					return
				end
				if itemTexture:lower()==rushOrders then
					mission.rush=mission.rush+v.quantity
				elseif itemName and (not v.quantity or v.quantity==1) and not v.followerXP then
					itemLevel=addon:GetTrueLevel(v.itemID,itemLevel)
					if mission.missionID==364 then print(4,itemLevel) end
					if (addon:IsFollowerUpgrade(v.itemID)) then
						mission.followerUpgrade=itemRarity
					elseif itemLevel > 500 and itemMinLevel >=90 then
						mission.itemLevel=itemLevel
					else
						mission.others=mission.others+v.quantity
					end
				else
					mission.others=mission.others+v.quantity
				end
			end
		end
	end
	mission.xpOnly=false
	if mission.resources > 0 then
		mission.class='resources'
		mission.maxable=true
		mission.mat=true
	elseif mission.oil > 0 then
		mission.class='oil'
		mission.maxable=true
		mission.mat=true
	elseif mission.apexis > 0 then
		mission.class='apexis'
		mission.maxable=true
		mission.mat=true
	elseif mission.seal > 0 then
		mission.class='seal'
		mission.maxable=fase
		mission.mat=false
	elseif mission.gold >0 then
		mission.class='gold'
		mission.maxable=true
		mission.mat=true
	elseif mission.itemLevel >0 then
		mission.class='itemLevel'
	elseif mission.followerUpgrade>0 then
		mission.class='followerUpgrade'
	elseif mission.rush>0 then
		mission.class='rush'
	elseif mission.others >0 or numrewards > 1 then
		mission.class='other'
	else
		mission.class='xp'
		mission.xpOnly=true
	end
	if (mission.numFollowers) then
		mission.globalXp=(mission.xp+mission.xpBonus+(addon:GetParty(mission.missionID)['xpBonus'] or 0) )*mission.numFollowers
	end

end


local Mbase = GMFMissions

-- self=Mbase
--	C_Garrison.GetInProgressMissions(self.inProgressMissions);
--	C_Garrison.GetAvailableMissions(self.availableMissions);
local Index={}
local sorted={}
local rushOrders="interface\\icons\\inv_scroll_12.blp"
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
	if not mission then
		mission=self:GetModule("MissionCompletion"):GetMission(missionID)
		if mission then
			if type(mission.improvedDurationSeconds)~='number' then
				mission.improvedDurationSeconds=mission.durationSeconds
			end
			mission.improvedDurationSeconds=mission.isMissionTimeImproved and mission.improvedDurationSeconds/2 or mission.improvedDurationSeconds
		end
	end
	if not mission then
		mission=G.GetMissionInfo(missionID)
	end
	if not mission then
		print("Could not find info for mission",missionID,G.GetMissionName(missionID))
		return default
	end
	if (key==nil) then
		if (mission.class=="retry" or not mission.globalXp or key=="globalXp") then
			self:AddExtraData(mission)
		end
		return mission
	end
	if not mission then
		return default
	end
	if (type(mission[key])~='nil') then
		return mission[key]
	end
	if key=='improvedDurationSeconds' then
		if type(mission.durationSeconds) ~= 'number' then return default end
		if self:GetParty(missionID,'isMissionTimeImproved') then
			return mission.durationSeconds/2
		else
			return mission.durationSeconds
		end
	end
	if (key=='rank') then
		mission.rank=mission.level < GARRISON_FOLLOWER_MAX_LEVEL and mission.level or mission.iLevel
		return mission.rank or default
	elseif(key=='basePerc') then
		mission.basePerc=select(4,G.GetPartyMissionInfo(missionID))
		return mission.basePerc or default
	else
		--AddExtraData(mission)
		return mission[key] or default
	end
end
function addon:AddExtraData(mission)
	local _
	_,mission.xp,mission.type,mission.typeDesc,mission.typeIcon,mission.locPrefix,_,mission.enemies=G.GetMissionInfo(mission.missionID)
	mission.rank=mission.level < GARRISON_FOLLOWER_MAX_LEVEL and mission.level or mission.iLevel
	mission.resources=0
	mission.oil=0
	mission.apexis=0
	mission.seal=0
	mission.gold=0
	mission.followerUpgrade=0
	mission.itemLevel=0
	mission.xpBonus=0
	mission.others=0
	mission.xp=mission.xp or 0
	mission.rush=0
	mission.chanceCap=100
	local numrewards=0
	for k,v in pairs(mission.rewards) do
		numrewards=numrewards+1
		if k==615 and v.followerXP then mission.xpBonus=mission.xpBonus+v.followerXP end
		if v.currencyID and v.currencyID==GARRISON_CURRENCY then mission.resources=v.quantity end
		if v.currencyID and v.currencyID==GARRISON_SHIP_OIL_CURRENCY then mission.oil=v.quantity end
		if v.currencyID and v.currencyID==823 then mission.apexis =mission.apexis+v.quantity end
		if v.currencyID and v.currencyID==994 then mission.seal =mission.seal+v.quantity end
		if v.currencyID and v.currencyID==0 then mission.gold =mission.gold+v.quantity/10000 end
		if v.icon=="Interface\\Icons\\XPBonus_Icon" and v.followerXP then
			mission.xpBonus=mission.xpBonus+v.followerXP
		elseif (v.itemID) then
			if v.itemID~=120205 then -- xp item
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(v.itemID)
				if (not itemName or not itemTexture) then
					mission.class="retry"
					return
				end
				if itemTexture:lower()==rushOrders then
					mission.rush=mission.rush+v.quantity
				elseif itemName and (not v.quantity or v.quantity==1) and not v.followerXP then
					itemLevel=addon:GetTrueLevel(v.itemID,itemLevel)
					if mission.missionID==364 then print(4,itemLevel) end
					if (addon:IsFollowerUpgrade(v.itemID)) then
						mission.followerUpgrade=itemRarity
					elseif itemLevel > 500 and itemMinLevel >=90 then
						mission.itemLevel=itemLevel
					else
						mission.others=mission.others+v.quantity
					end
				else
					mission.others=mission.others+v.quantity
				end
			end
		end
	end
	mission.xpOnly=false
	if mission.resources > 0 then
		mission.class='resources'
		mission.maxable=true
		mission.mat=true
	elseif mission.oil > 0 then
		mission.class='oil'
		mission.maxable=true
		mission.mat=true
	elseif mission.apexis > 0 then
		mission.class='apexis'
		mission.maxable=true
		mission.mat=true
	elseif mission.seal > 0 then
		mission.class='seal'
		mission.maxable=fase
		mission.mat=false
	elseif mission.gold >0 then
		mission.class='gold'
		mission.maxable=true
		mission.mat=true
	elseif mission.itemLevel >0 then
		mission.class='itemLevel'
	elseif mission.followerUpgrade>0 then
		mission.class='followerUpgrade'
	elseif mission.rush>0 then
		mission.class='rush'
	elseif mission.others >0 or numrewards > 1 then
		mission.class='other'
	else
		mission.class='xp'
		mission.xpOnly=true
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
