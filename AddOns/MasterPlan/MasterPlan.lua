local addonName, T = ...
if T.Mark ~= 50 then
	local m = T.Mark == nil and "You must restart World of Warcraft after installing this update." or ADDON_INCOMPATIBLE
	if type(T.L) == "table" and type(T.L[m]) == "string" then m = T.L[m] end
	return print("|cffffffff[Master Plan]: |cffff8000" .. m)
end

local L = newproxy(true) do
	local LL = type(T.L) == "table" and T.L or {}
	getmetatable(L).__call = function(_, k)
		return LL[k] or k
	end
	T.L = L
end

local EV, conf, api = T.Evie, setmetatable({}, {__index={
	availableMissionSort="reward",
	sortFollowers=true,
	riskReward=1,
	xpPerCopper=1e-5,
	xpPerResource=5e-1,
	xpWithToken=1,
	xpCapGrace=2000,
	goldRewardThreshold=100e4,
	levelDecay=0.9,
	currencyWasteThreshold=0.20,
	legendStep=0,
	timeHorizon=0,
	timeHorizonMin=300,
	crateLevelGrace=25,
	interestMask=0,
	ship1=100, ship2=90, ship3=80, ship4=50,
	moC=0, moE=0, moV=0, moN=0, goldCollected=0,
	allowShipXP=true,
	ignore={},
}})
T.config, api = conf, setmetatable({}, {__index={GarrisonAPI=T.Garrison}})

function EV:ADDON_LOADED(addon)
	if addon ~= addonName then
		return
	end
	function EV:PLAYER_LOGOUT()
		MasterPlanPC, conf.ignore, conf.complete = conf, next(conf.ignore) and conf.ignore, securecall(T._GetMissionSeenTable)
	end
	
	local pc
	if type(MasterPlanPC) == "table" then
		pc, MasterPlanPC = MasterPlanPC
	else
		pc = {}
	end
	
	for k,v in pairs(pc) do
		local tv = type(v)
		if k ~= "ignore" and k ~= "complete" and tv == type(conf[k]) then
			conf[k] = v
		elseif k == "ignore" and tv == "table" then
			for k,v in pairs(v) do
				conf.ignore[k] = v
			end
		end
	end
	T._SetMissionSeenTable(pc.complete)
	conf.version = GetAddOnMetadata(addonName, "Version")
	EV("MP_SETTINGS_CHANGED")
	
	return "remove"
end

function api:GetSortFollowers()
	return conf.sortFollowers
end
function api:SetSortFollowers(sort)
	assert(type(sort) == "boolean", 'Syntax: MasterPlan:SetSortFollowers(sort)')
	conf.sortFollowers = sort
	EV("MP_SETTINGS_CHANGED", "sortFollowers")
end

function api:SetMissionOrder(order)
	assert(type(order) == "string", 'Syntax: MasterPlan:SetMissionOrder("order")')
	conf.availableMissionSort = order
	EV("MP_SETTINGS_CHANGED", "availableMissionSort")
end
function api:GetMissionOrder()
	return conf.availableMissionSort
end
function api:SetTimeHorizon(sec)
	assert(type(sec) == "number" and sec >= 0, 'Syntax: MasterPlan:SetTimeHorizon(sec)')
	conf.timeHorizon = sec
	EV("MP_SETTINGS_CHANGED", "timeHorizon")
end

function api:IsFollowerIgnored(fid)
	return not not conf.ignore[fid]
end
function api:SetFollowerIgnored(fid, ignore)
	assert(type(fid) == "string", 'Syntax: MasterPlan:SetFollowerIgnored("followerID", ignore)')
	conf.ignore[fid] = ignore and 1 or nil
end

MasterPlan = api