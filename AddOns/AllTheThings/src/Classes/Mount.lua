
local app = select(2, ...);

-- Global locals
local ipairs, pairs, rawset, rawget, math_floor, select, tonumber
	= ipairs, pairs, rawset, rawget, math.floor, select, tonumber;

local C_MountJournal_GetMountInfoExtraByID,C_MountJournal_GetMountInfoByID,C_MountJournal_GetMountIDs
	= C_MountJournal.GetMountInfoExtraByID,C_MountJournal.GetMountInfoByID,C_MountJournal.GetMountIDs

-- WoW API Cache
local GetItemInfo = app.WOWAPI.GetItemInfo;
local GetSpellName = app.WOWAPI.GetSpellName;
local GetSpellIcon = app.WOWAPI.GetSpellIcon;
local GetSpellLink = app.WOWAPI.GetSpellLink;

-- App locals
local Colorize = app.Modules.Color.Colorize;
local GetRawField
	= app.GetRawField

-- Mount Lib
do
	-- Ugh really annoying that Mounts have a unique ID and we use their SpellID instead, assuming this is because in Classic they
	-- haven't made them MountID yet... bah
	local KEY, CACHE, SETTING = "mountID", "Mounts", "Mounts"
	local CLASSNAME = "Mount"

	local SpellIDToMountID = setmetatable({}, { __index = function(t, id)
		local allMountIDs = C_MountJournal_GetMountIDs();
		if allMountIDs and #allMountIDs > 0 then
			local spellID;
			for i,mountID in ipairs(allMountIDs) do
				spellID = select(2, C_MountJournal_GetMountInfoByID(mountID));
				if spellID then t[spellID] = mountID; end
			end
			setmetatable(t, nil);
			return rawget(t, id);
		end
	end });
	local cache = app.CreateCache("spellID");
	local function CacheInfo(t, field)
		local itemID = t.itemID;
		local _t, id = cache.GetCached(t);
		local mountID = SpellIDToMountID[id];
		if mountID then
			local displayID, lore = C_MountJournal_GetMountInfoExtraByID(mountID);
			_t.displayID = displayID;
			_t.lore = lore;
			_t.name = C_MountJournal_GetMountInfoByID(mountID);
			_t.mountJournalID = mountID;
		end
		local name, icon = GetSpellName(id), GetSpellIcon(id);
		if name then
			_t.name = name
			_t.icon = icon;
		end
		if itemID then
			local itemLink = select(2, GetItemInfo(itemID));
			-- item info might not be available on first request, so don't cache the data
			if itemLink then
				_t.link = itemLink;
			end
		else
			_t.link = GetSpellLink(id);
		end
		-- track retries on caching mount info... some mounts just never return info
		local retries = _t.retries or 0;
		retries = retries + 1;
		if retries > 20 then
			local name = (itemID and ("Item #%d"):format(itemID)) or
						(id and ("Spell #%d"):format(id));
			_t.name = _t.name or name;
			_t.icon = _t.icon or 134400;	-- question mark
			_t.link = GetSpellLink(id);
		end
		_t.retries = retries;
		if field then return _t[field]; end
	end
	local function default_costCollectibles(t)
		local id = t.itemID;
		if id then
			local results = GetRawField("itemIDAsCost", id);
			if results and #results > 0 then
				-- app.PrintDebug("default_costCollectibles",t.hash,id,#results)
				return results;
			end
		end
		return app.EmptyTable;
	end

	app.CreateMount = app.CreateClass(CLASSNAME, KEY, {
		CACHE = function() return CACHE end,
		_cache = function(t)
			return cache;
		end,
		-- Mounts use special text coloring instead of default text
		text = function(t)
			local name = t.name
			if name then
				return Colorize(name, app.Colors.Mount)
			end
			return t.link
		end,
		icon = function(t)
			return cache.GetCachedField(t, "icon", CacheInfo);
		end,
		link = function(t)
			return cache.GetCachedField(t, "link", CacheInfo);
		end,
		lore = function(t)
			return cache.GetCachedField(t, "lore", CacheInfo);
		end,
		displayID = function(t)
			return cache.GetCachedField(t, "displayID", CacheInfo);
		end,
		name = function(t)
			return cache.GetCachedField(t, "name", CacheInfo);
		end,
		mountJournalID = function(t)
			return cache.GetCachedField(t, "mountJournalID", CacheInfo);
		end,
		costCollectibles = function(t)
			return cache.GetCachedField(t, "costCollectibles", default_costCollectibles);
		end,
		f = function(t)
			return 100;
		end,
		collectibleAsCost = app.CollectibleAsCost,
		collectible = function(t) return app.Settings.Collectibles[SETTING]; end,
		collected = function(t)
			local id = t[KEY]
			-- character collected
			if app.IsCached(CACHE, id) then return 1; end
			-- account-wide collected
			if app.IsAccountCached(CACHE, id, SETTING) then return 1; end
		end,
		saved = function(t)
			return app.IsCached(CACHE, t.spellID)
		end,
		b = function(t)
			return (t.parent and t.parent.b) or 1;
		end,
		spellID = function(t)
			return t.mountID;
		end,
		tsm = function(t)
			if t.itemID then return ("i:%d"):format(t.itemID); end
			if t.parent and t.parent.itemID then return ("i:%d"):format(t.parent.itemID); end
		end,
	})
	local PerCharacterMountSpells = {
		[148970] = 1,	-- Felsteed (Green)
		[148972] = 1,	-- Dreadsteed (Green)
		[241857] = 1,	-- Druid Lunarwing
		[231437] = 1,	-- Druid Lunarwing (Owl)
	}
	app.AddEventHandler("OnRefreshCollections", function()
		local acct, char, none = {}, {}, {}
		local IsSpellKnown = app.IsSpellKnownHelper
		for _,mountID in ipairs(C_MountJournal_GetMountIDs()) do
			local _, spellID, _, _, _, _, _, _, _, _, isCollected = C_MountJournal_GetMountInfoByID(mountID);
			if spellID then
				 -- also used to have a questID check... is that really needed?
				if isCollected or IsSpellKnown(spellID) then
					if PerCharacterMountSpells[spellID] then
						char[spellID] = true;
					else
						acct[spellID] = true;
					end
				else
					none[spellID] = true
				end
			else
				app.PrintDebug("Mount with no spell",mountID)
			end
		end

		-- Spell-based Mounts (don't appear in Mount Journal)
		for spellID,_ in pairs(PerCharacterMountSpells) do
			if IsSpellKnown(spellID) then
				char[spellID] = true;
			else
				none[spellID] = true
			end
		end

		-- Character Cache
		app.SetBatchCached(CACHE, char, 1)
		app.SetBatchCached(CACHE, none)
		-- Remove old storage of Mounts within Character Spell cache
		app.SetBatchCached("Spells", acct)
		app.SetBatchCached("Spells", char)
		app.SetBatchCached("Spells", none)
		-- Account Cache (removals handled by Sync)
		app.SetBatchAccountCached(CACHE, acct, 1)
	end);
	app.AddEventHandler("OnSavedVariablesAvailable", function(currentCharacter, accountWideData)
		if not currentCharacter[CACHE] then currentCharacter[CACHE] = {} end
		if not accountWideData[CACHE] then accountWideData[CACHE] = {} end
	end);
	app.AddEventRegistration("NEW_MOUNT_ADDED", function(id)
		local _, spellID = C_MountJournal_GetMountInfoByID(id)
		app.SetThingCollected("spellID", spellID, not PerCharacterMountSpells[spellID], true)
	end);
	app.AddSimpleCollectibleSwap(CLASSNAME, SETTING)
end