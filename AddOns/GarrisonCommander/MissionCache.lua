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
local GMF=GMF
local GSF=GSF
local GMFMissions=GMFMissions
local GSFMissions=GSFMissions
local newcache=true
local rushOrders="interface\\icons\\inv_scroll_12.blp"
local rawget=rawget
local time=time
local empty={}
local index={}
local classes
-- Mission caching is a bit different fron follower caching mission appears and disappears on a regular basis
local module=addon:NewSubClass('MissionCache') --#module
function module:OnInitialized()
--[===[@debug@
	print("OnInitialized")
--@end-debug@]===]
end
local function scan(t,s)
	if type(t)=="table" then
		for i=1,#t do
			index[t[i].missionID]=format("%s@%d",s,i)
		end
	end
end
function module:GetMission(id,noretry)
	local mission
	if index[id] then
		local type,ix=strsplit("@",index[id])
		ix=tonumber(ix)
		if type=="a" then
			mission=GMFMissions.availableMissions[ix]
			if mission and mission.missionID==id then return mission end
		elseif type=="p" then
			mission=GMFMissions.inProgressMissions[ix]
			if mission and mission.missionID==id then return mission end
		elseif type=="s" then
			mission=GSFMissions.missions[ix]
			if mission and mission.missionID==id then return mission end
		end
	end
	if noretry then return end
	wipe(index)
	scan(GMFMissions.availableMissions,'a')
	scan(GMFMissions.inProgressMissions,'p')
	scan(GSFMissions.missions,'s')
	return self:GetMission(id,true)
end
function module:AddExtraData(mission)
	local rewards=mission.rewards
	if not rewards then
		rewards=G.GetMissionRewardInfo(mission.missionID)
	end
	for i=1,#classes do
		mission[classes[i].key]=0
	end
	mission.numrewards=0
	mission.xpBonus=0
	for k,v in pairs(rewards) do
		if k==615 and v.followerXP then mission.xpBonus=mission.xpBonus+v.followerXP end
		mission.numrewards=mission.numrewards+1
		for i,c in ipairs(classes) do
			local value=c.func(c,k,v)
			if value then
				mission[c.key]=mission[c.key]+value
				if  not mission.class or mission.class=="xp" then
					mission.class=c.key
					mission.maxable=c.maxable
					mission.mat=c.mat
				end
				break
			end
		end
	end
end
function module:AddExtraDataOld(mission)
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
	mission.primalspirit=0
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
			if v.itemID==120205 then -- xp item
			elseif v.itemID==120945 then -- Primal Spirit
					mission.primalspirit=v.quantity
			else
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(v.itemID)
				if (not itemName or not itemTexture) then
					mission.class="retry"
					return
				end
				if itemTexture:lower()==rushOrders then
					mission.rush=mission.rush+v.quantity
				elseif itemName and (not v.quantity or v.quantity==1) and not v.followerXP then
					itemLevel=addon:GetTrueLevel(v.itemID,itemLevel)
					if (addon:IsFollowerUpgrade(v.itemID)) then
						mission.followerUpgrade=itemRarity
					elseif itemLevel > 500 and itemMinLevel >=90 then
						mission.itemLevel=itemLevel
					elseif itemLevel >=655 then
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
	elseif mission.primalspirit > 0 then
		mission.class='primalspirit'
		mission.maxable=false
		mission.mat=false
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
		local partyXP=tonumber(addon:GetParty(mission.missionID,'xpBonus',0))
		mission.globalXp=(mission.xp+mission.xpBonus+partyXP)*mission.numFollowers
	end

end
function module:GetMissionIterator(followerType)
	local list
	if followerType==LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
		list=GSFMissions.missions
	else
		list=GMFMissions.availableMissions
	end

--[===[@debug@
print("Iterator called, list is",list)
--@end-debug@]===]
	return function(sorted,i)
		i=i+1
		if type(sorted[i])=="table" then
			return i,sorted[i].missionID
		end
	end,list,0
end
function module:OnAllGarrisonMissions(func,inProgress,missionType)
	local list=inProgress and GMFMissions.inProgressMissions or GMFMissions.availableMissions
	if type(list)=='table' then
		for i=1,#list do
			func(list[i].missionID)
		end
	end
end

-- Old cache to be removed


local Mbase = GMFMissions

-- self=Mbase
--	C_Garrison.GetInProgressMissions(self.inProgressMissions);
--	C_Garrison.GetAvailableMissions(self.availableMissions);
local Index={}
local sorted={}
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
	local mission=module:GetMission(missionID)
	if mission and not mission.class then
			self:AddExtraData(mission)
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

--[===[@debug@
print("Could not find info for mission",missionID,G.GetMissionName(missionID))
--@end-debug@]===]
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
		if type(default)=="number" and type(mission[key])~="number" then return default end
		return mission[key] or default
	end
end
function addon:AddExtraData(mission)
	return module:AddExtraData(mission)
end

function addon:OnAllGarrisonMissions(func,inProgress)
	return module:OnAllGarrisonMissions(func,inProgress)
end
local sorters={}

function addon:GetMissionIterator(followerType,func)
	return module:GetMissionIterator(followerType,func)
end
local function inList(self,id,reward)
	if self.key=='xp'  then
		if reward.followerXP then return reward.followerXP end
	elseif self.key=='followerUpgrade' then
		if not reward.itemID then return false end
		local level=addon:IsFollowerUpgrade(reward.itemID)
		if level then
			return tonumber(level) or 0
		end
	elseif self.key=='itemLevel' then
		if not reward.itemID then return false end
		local quality,level,minLevel=select(3,GetItemInfo(reward.itemID))
		if quality then
			level=addon:GetTrueLevel(reward.itemID,level)
			if (level > 500 and minLevel >=90) or level >654 then
				return level
			end
		else
			return -1
		end
	elseif self.key=='other' then
		return reward.quantity or 0
	elseif reward.currencyID and tContains(self.list,-reward.currencyID) then
		return reward.quantity or 1
	elseif reward.itemID and tContains(self.list,reward.itemID) then
		return reward.quantity or 1
	end
	return false
end
local function isGearToken(self,id,reward)
end
local function isValid(self)
	print(self.key,self.t)
	for i=1,#self.list do
		local id=self.list[i]
		if id < 10000 then
			print(GetCurrencyInfo(id))
		else
			print(GetItemInfo(id))
		end
	end
end
local c={}
local function newMissionType(key,name,icon,maxable,mat,func,...)
	return{
		key=key,
		t=name,
		func=func or inList,
		list={...},
		i='Interface\\Icons\\' .. icon,
		maxable=maxable,
		mat=mat,
		validate=isValid
	}
end
classes={
	newMissionType('xp',L['Follower experience'],'XPBonus_icon',false,false,nil,0),
	newMissionType('resources',GetCurrencyInfo(GARRISON_CURRENCY),'inv_garrison_resource',true,true,nil,-GARRISON_CURRENCY),
	newMissionType('oil',GetCurrencyInfo(GARRISON_SHIP_OIL_CURRENCY),'garrison_oil',true,true,nil,-GARRISON_SHIP_OIL_CURRENCY),
	newMissionType('rush',L['Rush orders'],'INV_Scroll_12',false,false,nil,122595,122594,122596,122592,122590,122593,122591,122576),
	newMissionType('apexis',GetCurrencyInfo(823),'inv_apexis_draenor',false,false,nil,-823),
	newMissionType('seal',GetCurrencyInfo(994),'ability_animusorbs',false,false,nil,-994),
	newMissionType('gold',BONUS_ROLL_REWARD_MONEY,'inv_misc_coin_01',false,false,nil,0),
	newMissionType('followerUpgrade',L['Follower equipment set or upgrade'],'Garrison_ArmorUpgrade',false,false,nil,0),
	newMissionType('primalspirit',L['Reagents'],'6BF_Explosive_shard',false,false,nil,118472,120945,113261,113262,113263,113264),
	newMissionType('ark',L['Archaelogy'],'achievement_character_orc_male',false,false,nil,-829,-828,-821,108439,109585,109584), -- Fragments and completer
	newMissionType('training',L['Follower Training'],'Spell_Holy_WeaponMastery',false,false,nil,123858,118354,118475,122582,122583,122580,122584,118474),
	newMissionType('legendary',L['Legendary Items'],'INV_Relics_Runestone',false,false,nil,115510,115280,128693,115981),
	newMissionType('toys',L['Toys and Mounts'],'INV_LesserGronnMount_Red',false,false,nil,128310,127748,128311),
	newMissionType('reputation',L['Reputation Items'],'Spell_Shadow_DemonicCircleTeleport',false,false,nil,117492,128315),
	newMissionType('itemLevel',L['Item Tokens'],'INV_Bracer_Cloth_Reputation_C_01',false,false,nil,0),
	newMissionType('other',L['Other rewards'],'INV_Box_02',false,false,nil,0),
}
function addon:GetRewardClasses()
	return classes
end
function addon:TestMissionExtra(id)
	local data={missionID=id}
	module:AddExtraData(data)
	return data
end
