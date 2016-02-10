
FollowerLocationInfoData = {};
local D = FollowerLocationInfoData;
local addon,ns = ...;

local function count(t,v,d)
	if(t[v]==nil)then t[v]=0; end
	t[v]=t[v]+d;
end

D.locale = GetLocale();

D.Locale = setmetatable({
	Traits = GARRISON_TRAITS,
	Abilities = ABILITIES,
	Achievements = ACHIEVEMENTS,
	Missions = GARRISON_MISSIONS,
	Quests = QUESTS_LABEL,
	Reputation = REPUTATION,
	Merchant = MERCHANT
},{
	__index=function(t,k)
		local v=tostring(k);
		rawset(t,k,v);
		return v;
	end
});
local L = D.Locale;

-- Fetch some localizations from blizzards functions
L["Brawler's Guild"] = GetCategoryInfo(15202);
L["Classes"] = strtrim(gsub(ITEM_CLASSES_ALLOWED, ((LOCALE_zhCN or LOCALE_zhTW) and "\154%%s") or ": %%s", ""));
L["Requirements"] = strtrim(gsub(QUEST_TOOLTIP_REQUIREMENTS, ((LOCALE_zhCN or LOCALE_zhTW) and "\154") or ":", ""));
--

D.Faction = UnitFactionGroup("player");

D.faction = (D.Faction=="Alliance") and 1 or 2;

D.classes = {};
D.ClassName2ID={};
for i=1, GetNumClasses() do
	local classDisplayName, classTag, classID = GetClassInfo(i);
	D.classes[classID]={classID,classTag:lower(),classDisplayName};
	D.ClassName2ID[classTag:lower()] = classID;
end

-- player class specs to follower class specs
D.playerSpec = {
	{35,37,38}, -- 1 WARRIOR
	{20,21,22}, -- 2 PALADIN
	{10,11,12}, -- 3 HUNTER
	{26,27,28}, -- 4 ROGUE
	{23,24,25}, -- 5 PRIEST
	{2,3,4}, -- 6 DEATHKNIGHT
	{29,30,31}, -- 7 SHAMAN
	{14,15,16}, -- 8 MAGE
	{32,33,34}, -- 9 WARLOCK
	{17,18,19}, -- 10 MONK
	{5,7,8,9}, -- 11 DRUID
};
D.playerTraits = {};
local playerTraitSpells = {
	[2018]=55,[2108]=60,[2259]=54,[2575]=52,[2366]=53,[3908]=61,[4036]=57,
	[7411]=56,[8613]=62,[25229]=59,[45357]=58,[78670]=256,[131474]=227,
	--[1804] = "Lockpicking",[2656] = "Smelting",[3273]  = "First Aid",[2550]  = "Cooking",[53428] = "Runeforging",
}
for id,traitId in pairs(playerTraitSpells) do
	local name = GetSpellInfo(id);
	D.playerTraits[name]=traitId;
end

D.qualities = {};
for k,v in pairs(ITEM_QUALITY_COLORS)do
	local K = string.format("ITEM_QUALITY%d_DESC",k);
	if _G[K] then
		tinsert(D.qualities,{k,_G[K]});
	end
end

--[[
-- faction zone order
-- > leveling
-- > custom sections ( 0.1 = Dungeons, 0.2 = Raids, 0.3 = Recruitment, 0.4 = Without description)
--]]
D.zoneOrder = (D.Faction=="Alliance")
	--[=[ Alliance zone order ]=] and {
		301, -- brawlers guild / alliance main city
		962,947,971,949,946,948,950,941,945,978,1009, -- draenor zones
		0.1,0.2,0.3,0.4 -- custom sections
		}
	
	--[=[ Horde zone order ]=] or {
		321, -- brawlers guild / horde main city
		962,941,976,949,946,948,950,947,945,978,1011, -- draenor zones
		0.1,0.2,0.3,0.4 -- custom sections
	};
D.zone2zoneGroup = {
	--[=[ dungeons ]=]
	--[[ WoD ]] [964]=0.1,[969]=0.1,[984]=0.1,[987]=0.1,[989]=0.1,[993]=0.1,[995]=0.1,[1008]=0.1,
	--[=[ Raids]=]
	--[[ WoD ]] [994]=0.2,[988]=0.2,[1026]=0.2
}

D.counter = {blizz=0,collectables={0,0},recruitables={0,0},class={},classspec={},abilities={},counters={},traits={},qualities={}};
D.followerIDs = {};
D.followerByZone = {};
D.classSpec = {};
D.abilities = {};
D.counters = {};
D.unknown = {};
D.collected = {};
D.collectGroups = {};
D.ability2counters = {};
D.counters2ability = {};
D.traits = {};
D.errors = {};

D.otherFiltersOrder = {};
D.otherFilters={
	Achievements = {},
	Missions = {},
	Quests = {},
	Merchant = {},
	Reputation = {},
	["Garrison building"] = {},
	Outpost = {}
};

D.otherFiltersCount = {
	Achievements = {0,0},
	Missions = {0,0},
	Quests = {0,0},
	Merchant = {0,0},
	Reputation = {0,0},
	["Garrison building"] = {0,0},
	Outpost = {0,0}
}

-- metatables
D.zoneNames = setmetatable({},{
	__index=function(t,k)
		local v;
		if(type(k)=="number")then
			if(k<1)then
				v =  (k==0.1 and DUNGEONS)
				  or (k==0.2 and RAIDS)
				  or (k==0.3 and GUILDINFOTAB_RECRUITMENT)
				  or (k==0.4 and L["Without description"])
				  or UNKNOWN;
			else
				v = GetMapNameByID(k);
			end
		elseif type(k)=="string" then
			v = L[k];
		end
		if(type(v)=="string")then
			rawset(t,k,v);
			return v;
		else
			return L["Error: Could not get zone name."];
		end
	end
});


local levelI,qualityI,classI,classSpecI,portraitI,modelI,modelHeightI,modelScaleI,abilitiesI,countersI,traitsI,isCollectableI = 1,2,3,4,5,6,7,8,9,10,11,12;
D.basics = setmetatable({},{
	__newindex=function(t,k,v)
		count(D.counter[(v[isCollectableI] and "collectables" or "recruitables")],1,1);
		if(D.counter.class[v[classI]]==nil)then
			D.counter.class[v[classI]] = {0,0};
		end
		if(D.counter.classspec[v[classSpecI]]==nil)then
			D.counter.classspec[v[classSpecI]] = {0,0};
		end
		if(D.counter.qualities[v[qualityI]]==nil)then
			D.counter.qualities[v[qualityI]] = {0,0};
		end
		for i=1, #v[abilitiesI] do
			if(D.counter.abilities[v[abilitiesI][i]]==nil)then
				D.counter.abilities[v[abilitiesI][i]] = {0,0};
			end
		end
		for i=1, #v[countersI] do
			if(D.counter.counters[v[countersI][i]]==nil)then
				D.counter.counters[v[countersI][i]] = {0,0};
			end
		end
		for i=1, #v[traitsI] do
			if(D.counter.traits[v[traitsI][i]]==nil)then
				D.counter.traits[v[traitsI][i]] = {0,0};
			end
		end
		if v[isCollectableI] then
			count(D.counter.class[v[classI]],1,1);
			count(D.counter.classspec[v[classSpecI]],1,1);
			count(D.counter.qualities[v[qualityI]],1,1);
			for i=1, #v[abilitiesI] do
				count(D.counter.abilities[v[abilitiesI][i]],1,1);
			end
			for i=1, #v[countersI] do
				count(D.counter.counters[v[countersI][i]],1,1);
			end
			for i=1, #v[traitsI] do
				count(D.counter.traits[v[traitsI][i]],1,1);
			end
		end
		tinsert(D.followerIDs,k);
		rawset(t,k,v);
	end
});

D.outposts = setmetatable({},{
	__newindex=function(t,k,v)
		rawset(t,k,{
			buildingName = D.Locale[v[1]],
			Location = {k,v[2],v[3],GetMapNameByID(k) .. " " .. D.Locale["Outpost"]}
		});
	end
});

do
	local _rawset = function(t,k,v,f)
		if(v.zone and D.followerByZone[v.zone]==nil)then
			D.followerByZone[v.zone]={};
		end
		if(v.zone)then
			tinsert(D.followerByZone[v.zone],k);
		end
		for _,obj in ipairs(v)do
			if(obj[1]=="Requirements")then
				for i=2, #obj do
					local subObj = obj[i];
					if(D.otherFilters[subObj[1]])then
						D.otherFilters[subObj[1]][k]=true;
						count(D.otherFiltersCount[subObj[1]],1,1);
					end
				end
			elseif(D.otherFilters[obj[1]])then
				D.otherFilters[obj[1]][k]=true;
				count(D.otherFiltersCount[obj[1]],1,1);
			end
		end
		local LKeyFormat = "desc_%d_%s";
		local KeyF,KeyN = LKeyFormat:format(k,f),LKeyFormat:format(k,"neutral");
		local Key0F,Key0N = LKeyFormat:format(0,f),LKeyFormat:format(0,"neutral");
		if( rawget(L,KeyF)~=nil )then
			tinsert(v,{"Description", KeyF});
		elseif( rawget(L,KeyN)~=nil )then
			tinsert(v,{"Description", KeyN});
		elseif( v[isCollectableI]==false )then
			if( rawget(L,Key0F)~=nil )then
				tinsert(v,{"Description", Key0F});
			elseif( rawget(L,Key0N)~=nil )then
				tinsert(v,{"Description", Key0N});
			end
		end
		rawset(t,k,v);
	end;
	D.descriptions = setmetatable({},{
		__newindex=function(t,k,v)
			local V,f = v[1],"neutral";
			if(V==nil)then
				V = v[D.faction+1];
				f = D.faction==1 and "alliance" or "horde";
			end
			if(V.collectGroup)then 
				for i=1,#V.collectGroup do
					_rawset(t,tonumber(V.collectGroup[i]),V,f);
				end
			else
				_rawset(t,k,V,f);
			end
		end
	});
end

D.QuestName = setmetatable({},{
	__index=function(t,k)
		local v = false;
		if FollowerLocationInfoDataDB.questNames[k] then
			v = FollowerLocationInfoDataDB.questNames[k];
		end
		local ld = ns.GetLinkData("quest:"..k);
		if ld and type(ld[1])=="string" and strlen(ld[1])>0 then
			v = ld[1];
			FollowerLocationInfoDataDB.questNames[k] = ld[1];
		end
		if v then
			rawset(t,k,v);
		end
		return v;
	end
});

D.NpcTitle = {};
D.NpcName = setmetatable({},{
	__index=function(t,k)
		local v = false;
		if FollowerLocationInfoDataDB.npcNames[k] then
			v = FollowerLocationInfoDataDB.npcNames[k];
		end
		if FollowerLocationInfoDataDB.npcTitles[k] then
			D.NpcTitle[k] = FollowerLocationInfoDataDB.npcTitles[k];
		end
		local ld = ns.GetLinkData("unit:Creature-0-970-1-1-"..k.."-0");
		if ld and type(ld[1])=="string" and strlen(ld[1])>0 then
			v = ld[1];
			FollowerLocationInfoDataDB.npcNames[k] = ld[1];
			if type(ld[2])=="string" and not ld[2]:match("^"..LEVEL) then
				FollowerLocationInfoDataDB.npcTitles[k] = ld[2];
				D.NpcTitle[k] = ld[2];
			end
		end
		if v then
			rawset(t,k,v);
		end
		return v;
	end
});

D.ObjectName = setmetatable({},{
	__index=function(t,k)
		local v;
		local K = gsub(tostring(k),"^0%.","");
		if FollowerLocationInfoDataDB.objectNames[K] then
			v = FollowerLocationInfoDataDB.objectNames[K];
		end
		local ld = ns.GetLinkData("unit:GameObject-0-970-1-1-"..K.."-0");
		if ld and type(ld[1])=="string" and strlen(ld[1])>0 then
			v = ld[1];
			FollowerLocationInfoDataDB.objectNames[K] = ld[1];
		end
		if(not v and rawget(L,"object_"..K))then
			return L["object_"..K];
		end
		if v then
			rawset(t,k,v);
			return v;
		end
	end
});
