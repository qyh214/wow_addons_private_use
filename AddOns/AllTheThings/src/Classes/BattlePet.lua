
-- BattlePet Class (maybe this should move to a MoP Expansion file?)
local _, app = ...

-- Globals
local wipe, setmetatable, rawget, select,pairs
	= wipe, setmetatable, rawget, select,pairs

-- WoW API Cache
local GetItemInfo = app.WOWAPI.GetItemInfo;

-- Module

-- App

-- BattlePet Lib / Species Lib
local KEY, CACHE = "speciesID", "BattlePets"
local CLASSNAME = "BattlePet"
-- TODO: Classic implementation will need some heavily-modified functionality here
if not C_PetBattles or not C_PetJournal then
	app.CreateSpecies = app.CreateUnimplementedClass("BattlePet", KEY);
	app.CreatePetAbility = app.CreateUnimplementedClass("PetAbility", "petAbilityID");
	app.CreatePetType = app.CreateUnimplementedClass("PetType", "petTypeID");
	return
end

local C_PetBattles_GetAbilityInfoByID,C_PetJournal_GetNumCollectedInfo,C_PetJournal_GetPetInfoByPetID,C_PetJournal_GetPetInfoBySpeciesID,C_PetJournal_GetPetInfoByIndex,C_PetJournal_GetNumPets
	= C_PetBattles.GetAbilityInfoByID,C_PetJournal.GetNumCollectedInfo,C_PetJournal.GetPetInfoByPetID,C_PetJournal.GetPetInfoBySpeciesID,C_PetJournal.GetPetInfoByIndex,C_PetJournal.GetNumPets

-- Due to bad Blizzard data being returned from C_PetJournal.GetNumPets
-- we can only use the method of scanning the players collected pets if this API returns the proper number of total
-- pets existing within the game
app.PrintDebug("BattlePet.Load:C_PetJournal_GetNumPets",C_PetJournal_GetNumPets())
local TOTAL_PETS_FOR_SCAN
if app.IsClassic then
	-- TODO: adjust/revise if viable
	TOTAL_PETS_FOR_SCAN = 100
else
	-- updated 11.1
	TOTAL_PETS_FOR_SCAN = 2412
end

local cache = app.CreateCache(KEY);
local function CacheInfo(t, field)
	local _t, id = cache.GetCached(t);
	-- speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, isWild,
	-- canBattle, isTradeable, isUnique, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
	local speciesName, speciesIcon, petType, _, _, tooltipDescription, _, _, _, _, _, creatureDisplayID = C_PetJournal_GetPetInfoBySpeciesID(id);
	if speciesName and speciesIcon and petType and tooltipDescription and creatureDisplayID then
		_t.name = speciesName;
		_t.icon = speciesIcon;
		_t.petTypeID = petType;
		_t.lore = tooltipDescription;
		_t.displayID = creatureDisplayID;
		if not t.itemID or not t.link then
			_t.text = "|cff0070dd"..speciesName.."|r";
		end
	else
		_t.name = UNKNOWN;
		if not t.itemID or not t.link then
			_t.text = "|cff0070dd"..UNKNOWN.."|r";
		end
	end
	if field then return _t[field]; end
end
local function default_link(t)
	if t.itemID then
		local name, link, quality, _, _, _, _, _, _, icon, _, _, _, b = GetItemInfo(t.itemID);
		if link then
			--[[ -- Debug Prints
			local _t, id = cache.GetCached(t);
			print("rawset item info",id,link,name,quality,b)
			--]]
			t = cache.GetCached(t);
			t.link = link;
			t.q = quality;
			if not t.name then
				t.name = name
			end
			if not t.icon then
				t.icon = icon
			end
			if quality > 6 then
				-- heirlooms return as 1 but are technically BoE for our concern
				t.b = 2;
			else
				t.b = b;
			end
			return link;
		end
	end
end
local function default_costCollectibles(t)
	local id = t.itemID
	if not id then return app.EmptyTable end
	local results = app.GetRawField("itemIDAsCost", id);
	if results and #results > 0 then
		-- not sure we need to copy these into another table
		-- app.PrintDebug("default_costCollectibles",id,#results,app:SearchLink(t))
		return results;
	end
	return app.EmptyTable;
end
-- Returns how many of a given speciesID are currently collected
local CollectedSpeciesHelper = setmetatable({}, {
	__index = function(t, key)
		if key and key > 0 then
			local num = C_PetJournal_GetNumCollectedInfo(key)
			-- app.PrintDebug("SPECIES->NUM",key,num)
			if not num then
				app.PrintDebug("SpeciesID " .. key .. " was not found.")
				num = 0
			end
			t[key] = num
			return num
		end
		return 0
	end
});
local PetIDSpeciesIDHelper = setmetatable({}, {
	-- this metafunction seems to never be utilized... but guess it can stay for now
	__index = function(t, key)
		-- PetID are strings
		local speciesID = C_PetJournal_GetPetInfoByPetID(key);
		if speciesID then
			-- app.PrintDebug("PET->SPECIES",key,speciesID)
			t[key] = speciesID;
		end
		return speciesID;
	end
});

app.CreateSpecies = app.CreateClass(CLASSNAME, KEY, {
	CACHE = function() return CACHE end,
	collectible = function(t) return app.Settings.Collectibles[CACHE]; end,
	collected = function(t)
		-- certain Battle Pets are per Character, so we can implicitly check for them as Account-Wide since Battle Pets have no toggle for that
		-- account-wide collected
		return app.TypicalAccountCollected(CACHE, t[KEY])
	end,
	saved = function(t)
		local saved = CollectedSpeciesHelper[t[KEY]] > 0
		-- weird bug where ATT fails to scan battle pets,
		-- can manually make it collected when checking the saved state (i.e. displayed in a row)
		-- character collected
		if saved then
			if not t.collected then
				app.SetThingCollected(KEY, t[KEY], true, true)
			end
			return 1
		end
	end,
	costCollectibles = function(t)
		return cache.GetCachedField(t, "costCollectibles", default_costCollectibles);
	end,
	f = function(t)
		return 101;
	end,
	text = function(t)
		return t.link or cache.GetCachedField(t, "text", CacheInfo);
	end,
	icon = function(t)
		return cache.GetCachedField(t, "icon", CacheInfo);
	end,
	lore = function(t)
		return cache.GetCachedField(t, "lore", CacheInfo);
	end,
	displayID = function(t)
		return cache.GetCachedField(t, "displayID", CacheInfo);
	end,
	petTypeID = function(t)
		return cache.GetCachedField(t, "petTypeID", CacheInfo);
	end,
	name = function(t)
		return cache.GetCachedField(t, "name", CacheInfo);
	end,
	link = function(t)
		return cache.GetCachedField(t, "link", default_link);
	end,
	b = function(t)
		return cache.GetCachedField(t, "b");
	end,
	tsm = function(t)
		return ("p:%d:1:3"):format(t.speciesID);
	end,
});

local PerCharacterSpecies = {
	[280] = true, 	-- Guild Page [A]
	[281] = true, 	-- Guild Page [H]
	[282] = true,	-- Guild Herald [A]
	[283] = true,	-- Guild Herald [H]
	-- ...etc
}
local function RefreshBattlePets()
	app.PrintDebug("RCBP",C_PetJournal_GetNumPets())
	wipe(CollectedSpeciesHelper)
	local acct, char, none = {}, {}, {}
	local count = 0
	local num
	local totalPets, ownedPets = C_PetJournal_GetNumPets()
	-- ownedPets may reflect accurately but the C_PetJournal_GetPetInfoByIndex data will be missing entirely regardless
	ownedPets = (totalPets or 0) >= TOTAL_PETS_FOR_SCAN and ownedPets or 0

	if ownedPets > 0 then
		-- ideally this is the case: we can scan user's actually-collected pets, track the petID's,
		-- and everything is great
		app.PrintDebug("RCBP:Scan")
		local petID, speciesID
		for i=1,ownedPets do
			petID, speciesID = C_PetJournal_GetPetInfoByIndex(i)
			-- app.PrintDebug("RCBP",i,petID,speciesID,speciesID and CollectedSpeciesHelper[speciesID])
			-- apparently some users can have a nil speciesID here...
			if speciesID then
				num = CollectedSpeciesHelper[speciesID]
				if num > 0 then
					if petID then
						PetIDSpeciesIDHelper[petID] = speciesID
					end
					if PerCharacterSpecies[speciesID] then
						char[speciesID] = true
					end
					acct[speciesID] = true
					count = count + 1
				end
			end
		end
		-- when the actual set of learned pets has ACTUALLY been scanned and determined
		-- we can wipe the BattlePet caches to ensure data is accurate
		if count > 0 then
			app.WipeCached(CACHE)
			app.WipeCached(CACHE, true)
		end
	else
		app.PrintDebug("RCBP:Cache")
		-- otherwise we will have to use the ATT speciesID cache to scan collected, and this will mean that
		-- caged pets will fail to be detected as removed immediately and require a refresh to detect
		for speciesID,_ in pairs(app.GetRawFieldContainer("speciesID")) do
			-- app.PrintDebug("RCBP",speciesID,CollectedSpeciesHelper[speciesID])
			num = CollectedSpeciesHelper[speciesID]
			if num > 0 then
				if PerCharacterSpecies[speciesID] then
					char[speciesID] = true
				end
				acct[speciesID] = true
			else
				none[speciesID] = true
			end
		end
	end
	-- Remove unknown
	app.SetBatchCached(CACHE, none)
	app.SetBatchAccountCached(CACHE, none)
	-- Cache all ids which are known
	app.SetBatchCached(CACHE, char, 1)
	app.SetBatchAccountCached(CACHE, acct, 1)
	-- app.PrintDebug("RCBP-Done")
end
app.AddEventHandler("OnRefreshCollections", RefreshBattlePets)
app.AddEventHandler("OnSavedVariablesAvailable", function(currentCharacter, accountWideData)
	if not currentCharacter[CACHE] then currentCharacter[CACHE] = {} end
	if not accountWideData[CACHE] then accountWideData[CACHE] = {} end
end)
-- at some point speciesID began to be included in the Event payload, huzzah!
app.AddEventRegistration("NEW_PET_ADDED", function(petID, speciesID)
	local speciesID = speciesID or PetIDSpeciesIDHelper[petID]
	PetIDSpeciesIDHelper[petID] = speciesID
	-- app.PrintDebug("NEW_PET_ADDED", petID, speciesID)

	if speciesID then
		CollectedSpeciesHelper[speciesID] = nil
		-- if the CollectedSpeciesHelper is exactly 1, then this is newly collected
		if CollectedSpeciesHelper[speciesID] == 1 then
			app.SetThingCollected(KEY, speciesID, true, true)
		end
	end
end)
-- at some point speciesID began to be included in the Event payload, huzzah!
app.AddEventRegistration("PET_JOURNAL_PET_DELETED", function(petID, speciesID)
	local speciesID = speciesID or PetIDSpeciesIDHelper[petID];
	-- app.PrintDebug("PET_JOURNAL_PET_DELETED",petID,speciesID);

	if speciesID then
		CollectedSpeciesHelper[speciesID] = nil
		-- if the CollectedSpeciesHelper is exactly 0, then this is now removed
		if CollectedSpeciesHelper[speciesID] == 0 then
			-- app.PrintDebug("Pet Missing",speciesID);
			app.SetThingCollected(KEY, speciesID, true)
		end
	end
end)
app.AddSimpleCollectibleSwap(CLASSNAME, CACHE)

app.CreatePetAbility = app.CreateClass("PetAbility", "petAbilityID", {
	["text"] = function(t)
		return select(2, C_PetBattles_GetAbilityInfoByID(t.petAbilityID));
	end,
	["icon"] = function(t)
		return select(3, C_PetBattles_GetAbilityInfoByID(t.petAbilityID));
	end,
	["description"] = function(t)
		return select(5, C_PetBattles_GetAbilityInfoByID(t.petAbilityID));
	end,
})

app.CreatePetType = app.CreateClass("PetType", "petTypeID", {
	["text"] = function(t)
		return _G["BATTLE_PET_NAME_" .. t.petTypeID];
	end,
	["icon"] = function(t)
		return app.asset("Icon_PetFamily_"..PET_TYPE_SUFFIX[t.petTypeID]);
	end,
	["filterID"] = function(t)
		return 101;
	end,
})