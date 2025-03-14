
-- Spell Class
local _, app = ...
local L = app.L

-- Global locals
local pairs, select, rawget
	= pairs, select, rawget

-- App locals
local IsQuestFlaggedCompleted, SearchForFieldContainer, GetFixedItemSpecInfo, SearchForField
	= app.IsQuestFlaggedCompleted, app.SearchForFieldContainer, app.GetFixedItemSpecInfo, app.SearchForField

-- WoW API Cache
local GetItemInfo = app.WOWAPI.GetItemInfo;
local GetSpellLink = app.WOWAPI.GetSpellLink;

local IsSpellKnown, IsPlayerSpell, GetNumSpellTabs, GetSpellTabInfo, IsSpellKnownOrOverridesKnown
---@diagnostic disable-next-line: deprecated
	= IsSpellKnown, IsPlayerSpell, GetNumSpellTabs, GetSpellTabInfo, IsSpellKnownOrOverridesKnown

-- Consolidates some spell checking
---@param spellID number
---@param rank? number
---@param ignoreHigherRanks? boolean
---@return boolean isKnown
local IsSpellKnownHelper = function(spellID, rank, ignoreHigherRanks)
	if IsPlayerSpell(spellID) or IsSpellKnown(spellID) or IsSpellKnown(spellID, true)
		or IsSpellKnownOrOverridesKnown(spellID) or IsSpellKnownOrOverridesKnown(spellID, true) then
		return true;
	end
	if spellID == 390631 and IsQuestFlaggedCompleted(66444) then	-- Ottuk Taming returning false for the above functions
		return true;
	end
	if (spellID == 241857 or spellID == 231437) and IsQuestFlaggedCompleted(46319) then	-- Lunarwing returning false for the above functions
		return true;
	end
	if (spellID == 148972 or spellID == 148970) and IsQuestFlaggedCompleted(32325) then	-- Green Dread/Fel-Steed returning false for the above functions
		return true;
	end
end
app.IsSpellKnownHelper = IsSpellKnownHelper;

local SpellIDToSpellName = {};
local SpellNameToSpellID;

-- WoW API Cache
local _GetSpellName = app.WOWAPI.GetSpellName;
local GetSpellIcon = app.WOWAPI.GetSpellIcon;
local GetSpellName = function(spellID)
	local spellName = SpellIDToSpellName[spellID];
	if spellName then return spellName; end
	spellName = _GetSpellName(spellID);
	if spellName and spellName ~= "" then
		SpellIDToSpellName[spellID] = spellName;
		SpellNameToSpellID[spellName] = spellID;
		return spellName;
	end
end
app.GetSpellName = GetSpellName;
SpellNameToSpellID = setmetatable(L.SPELL_NAME_TO_SPELL_ID, {
	__index = function(t, key)
		local cache = SearchForFieldContainer("spellID");
		for spellID,g in pairs(cache) do
			GetSpellName(spellID);
		end
		for _,spellID in pairs(app.SkillIDToSpellID) do
			GetSpellName(spellID);
		end
		for specID,spellID in pairs(app.SpecializationSpellIDs) do
			GetSpellName(spellID);
		end
		local numSpellTabs, offset, lastSpellName, currentSpellRank = GetNumSpellTabs(), select(4, GetSpellTabInfo(1)), "", 1;
		for spellTabIndex=2,numSpellTabs do
			local numSpells = select(4, GetSpellTabInfo(spellTabIndex));
			for spellIndex=1,numSpells do
				local spellName, _, _, _, _, _, spellID = GetSpellInfo(offset + spellIndex, BOOKTYPE_SPELL);
				if spellName then
					if lastSpellName == spellName then
						currentSpellRank = currentSpellRank + 1;
					else
						lastSpellName = spellName;
						currentSpellRank = 1;
					end
					---@diagnostic disable-next-line: redundant-parameter
					GetSpellName(spellID, currentSpellRank);
					SpellNameToSpellID[spellName] = spellID;
				-- else
				-- 	print("GetSpellName:Failed",offset + spellIndex);
				end
			end
			offset = offset + numSpells;
		end
		return rawget(t, key);
	end
});
app.SpellNameToSpellID = SpellNameToSpellID;
-- Represents a small lookup of a select set of Profession/Skill-related icons
local SkillIcons = setmetatable({
	[2720] = 2915722,	-- Junkyard Tinkering
	[2891] = 3054888,	-- Ascension Crafting
	[2811] = 2578727,	-- Stygia Crafting
	[2819] = 3747898,	-- Protoform Synthesis
	[2847] = 4638460,	-- Tuskarr Fishing Gear
	[2886] = 1394946,	-- Supply Shipments
}, { __index = function(t, key)
	if not key then return; end
	local skillSpellID = app.SkillIDToSpellID[key];
	if skillSpellID then
		return GetSpellIcon(skillSpellID);
	end
end
});

local cache = app.CreateCache("_cachekey");
local function default_costCollectibles(t)
	local id = t.spellID
	if id then
		local results = SearchForField("spellIDAsCost", id)
		if #results > 0 then
			-- app.PrintDebug("default_costCollectibles",t.hash,#results)
			return results
		end
	end
	return app.EmptyTable
end
local function CacheInfo(t, field)
	local _t, id = cache.GetCached(t);
	if t.itemID then
		local name, link, _, _, _, _, _, _, _, icon = GetItemInfo(t.itemID);
		if link then
			_t.name = name;
			_t.link = link;
			_t.icon = icon;
		end
	else
		local name, icon = GetSpellName(id), GetSpellIcon(id);
		_t.name = name;
		-- typically, the profession's spell icon will be a better representation of the spell if the spell is tied to a skill
		_t.icon = SkillIcons[t.skillID] or icon;
		local link = GetSpellLink(id);
		_t.link = link;
	end
	-- track number of attempts to cache data for fallback to default values
	local retries = (_t.retries or 0) + 1;
	if retries > app.MaximumItemInfoRetries then
		_t.name = t.itemID and "Item #"..t.itemID or "Spell #"..t.spellID;
		-- fallback to skill icon if possible
		_t.icon = SkillIcons[t.skillID] or 136243;	-- Trade_engineering
		_t.link = _t.name;
	end
	_t.retries = retries;
	if field then return _t[field]; end
end

-- Spell Lib
do
	local KEY, CACHE = "spellID", "Spells"
	app.CreateSpell = app.CreateClass("Spell", KEY, {
		CACHE = function() return CACHE end,
		_cachekey = function(t)
			return t[KEY];
		end,
		name = function(t)
			return cache.GetCachedField(t, "name", CacheInfo);
		end,
		link = function(t)
			return cache.GetCachedField(t, "link", CacheInfo);
		end,
		icon = function(t)
			return cache.GetCachedField(t, "icon", CacheInfo) or 136243;	-- Trade_engineering
		end,
		saved = function(t)
			local id = t[KEY];
			-- character known
			if app.IsCached(CACHE, id) then return true; end
		end,
		collectible = app.ReturnFalse,
		collected = function(t)
			return app.TypicalCharacterCollected(CACHE, t[KEY])
		end,
		skillID = function(t)
			return t.requireSkill;
		end,
		costCollectibles = function(t)
			return cache.GetCachedField(t, "costCollectibles", default_costCollectibles);
		end,
	},
	"WithItem", {
		_cachekey = function(t)
			return t[KEY] + (t.itemID / 1000000)
		end,
		specs = function(t)
			return GetFixedItemSpecInfo(t.itemID)
		end,
		tsm = function(t)
			return ("i:%d"):format(t.itemID)
		end,
	},
	function(t) return t.itemID end)

	local CheckRecipeLearned
	if C_TradeSkillUI then
		-- local C_TradeSkillUI = C_TradeSkillUI
		CheckRecipeLearned = function(recipeID)
			-- TODO: currently this bricks the game instantly. thanks blizz
			-- local spellRecipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
			-- app.PrintTable(spellRecipeInfo)
			-- recipe is learned, so cache that it's learned regardless of being craftable
			-- if app.TEST and spellRecipeInfo and spellRecipeInfo.learned then
			-- 	-- Shadowlands recipes are weird...
			-- 	-- local rank = spellRecipeInfo.unlockedRecipeLevel or 0
			-- 	-- if rank > 0 then
			-- 	-- 	-- when the recipeID specifically is available, it will show as available for ALL possible ranks
			-- 	-- 	-- so we can check if the next known rank is also considered available for this recipeID
			-- 	-- 	spellRecipeInfo = C_TradeSkillUI_GetRecipeInfo(recipeID, rank + 1)
			-- 	-- 	app.PrintDebug("NextRankCheck",recipeID,rank + 1, spellRecipeInfo.learned)
			-- 	-- end
			-- 	return spellRecipeInfo.learned
			-- end
		end
	else
		CheckRecipeLearned = app.EmptyFunction
	end

	app.AddEventHandler("OnRefreshCollections", function()
		local state
		local saved, none = {}, {}
		local IsAccountCached = app.IsAccountCached
		for id,_ in pairs(app.GetRawFieldContainer(KEY)) do
			-- Don't cache other cached spells within Spells, they're handled separately
			if not IsAccountCached("Mounts", id) then
				state = IsSpellKnownHelper(id) or CheckRecipeLearned(id)
				if state ~= nil then
					saved[id] = true
				else
					-- for now, don't uncache learned Spells for the character...
					-- Recipes are weird, and can only properly be refreshed via a TradeSkill window (without crashing the game anyway...)
					-- none[id] = true
				end
			else
				-- Remove other Spells
				none[id] = true
			end
		end
		-- Character Cache
		app.SetBatchCached(CACHE, saved, 1)
		app.SetBatchCached(CACHE, none)
		-- Account Cache (removals handled by Sync)
		app.SetBatchAccountCached(CACHE, saved, 1)
	end);
	app.AddEventHandler("OnSavedVariablesAvailable", function(currentCharacter, accountWideData)
		if not currentCharacter[CACHE] then currentCharacter[CACHE] = {} end
		if not accountWideData[CACHE] then accountWideData[CACHE] = {} end
	end);
	-- No known 'on learned' Event
end

-- Recipe Lib
do
	local KEY, CACHE, SETTING = "recipeID", "Spells", "Recipes"
	app.CreateRecipe = app.ExtendClass("Spell", "Recipe", KEY, {
		spellID = function(t)
			return t[KEY]
		end,
		f = function(t)
			return 200;
		end,
		collectible = function(t)
			return app.Settings.Collectibles[SETTING];
			-- TODO: revise? this prevents showing a BoP, wrong-profession Recipe under a BoE used to obtain it, when within a Popout and NOT tracking Account-Wide Recipes
			-- return app.Settings.Collectibles.Recipes and
			-- 	(
			--	-- If tracking Account-Wide, then all Recipes are inherently collectible
			-- 	app.Settings.AccountWide.Recipes or
			--	-- Otherwise must be learnable by the Character specifically
			-- 	app.CurrentCharacter.Professions[t.requireSkill]
			-- 	);
		end,
		collected = function(t)
			return app.TypicalCharacterCollected(CACHE, t[KEY], SETTING)
		end,
		b = function(t)
			-- If not tracking Recipes Account-Wide, then pretend that every Recipe is BoP
			return 1;
		end,
	},
	"WithItem", {
		b = function(t)
			-- If not tracking Recipes Account-Wide, then pretend that every Recipe is BoP
			return app.Settings.AccountWide[SETTING] and 2 or 1;
		end,
		-- Extended Classes don't inherit Variant versions of their Base Class automatically
		-- i.e. RecipeWithItem doesn't extend SpellWithItem, it extends Spell
		_cachekey = function(t)
			return t[KEY] + (t.itemID / 1000000)
		end,
		specs = function(t)
			return GetFixedItemSpecInfo(t.itemID)
		end,
		tsm = function(t)
			return ("i:%d"):format(t.itemID)
		end,
	},
	function(t) return t.itemID end);
	-- onrefresh handled by Spell
	-- saved vars handled by Spell
	app.AddEventRegistration("NEW_RECIPE_LEARNED", function(spellID, rank, previousSpellID)
		if spellID then
			app.SetThingCollected("spellID", spellID, false, true)
		end
	end);
end