---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local wowEx = addon.Utils.WoWEx
local trinketsTracker = addon.Core.TrinketsTracker
local instanceOptions = addon.Core.InstanceOptions
local frames = addon.Core.Frames

-- Loaded before this file in TOC order.
local fcdTalents = addon.Modules.Cooldowns.Talents
local rules = addon.Modules.Cooldowns.Rules

addon.Modules.FriendlyCooldowns = addon.Modules.FriendlyCooldowns or {}

---@class FriendlyCooldownDisplay
local D = {}
addon.Modules.FriendlyCooldowns.Display = D

---@type Db
local db
local testModeActive = false

-- C_Spell.GetSpellTexture follows spell overrides: if the local player has a
-- talent that replaces spell X with spell Y, then GetSpellTexture(X) returns Y's
-- icon even when we are asking on behalf of a party member who does NOT have the
-- override. This corrupts the displayed icon for abilities whose base spell is
-- overridden locally (e.g. Holy Paladin Avenging Wrath being replaced by
-- Avenging Crusader when the *viewing* player is specced into AC).
--
-- C_Spell.GetSpellInfo(spellId).originalIconID returns the canonical, non-
-- overridden icon, so we prefer it and only fall back to GetSpellTexture when
-- the new API is unavailable or returns nil.
local function GetSpellIcon(spellId)
	local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellId)
	return (info and info.originalIconID) or C_Spell.GetSpellTexture(spellId)
end

local function GetAnchorOptions()
	local m = db and db.Modules.FriendlyCooldownTrackerModule
	if not m then
		return nil
	end
	return instanceOptions:IsRaid() and m.Raid or m.Default
end

-- Scratch table reused by UpdateDisplay to avoid per-call allocation.
local slotsScratch = {}

-- Cache: unit -> { specId, hideExternalDefensives, result } - invalidated by the talent callback.
local staticAbilitiesCache = {}

local function IsInArena()
	local inInstance, instanceType = IsInInstance()
	return inInstance and instanceType == "arena"
end

---@class FcdStaticAbility
---@field SpellId number
---@field IsOffensive boolean
---@field MaxCharges number? Effective max charges (nil = single charge)

---Returns ordered list of abilities for a unit's known spells (spec rules first, then class fallback).
---Used to populate static icon slots that are always visible regardless of cooldown state.
---@param unit string
---@return FcdStaticAbility[]
local function GetStaticAbilities(unit)
	local _, classToken = UnitClass(unit)
	if not classToken then
		return {}
	end

	local specId = fcdTalents:GetUnitSpecId(unit)

	local _, instanceType = IsInInstance()
	local hideExternalDefensives = instanceOptions:IsRaid() or instanceType == "pvp"
	local inPvpContext = instanceType == "arena" or instanceType == "pvp" or UnitIsPVP(unit)

	local cached = staticAbilitiesCache[unit]
	if cached and cached.specId == specId and cached.hideExternalDefensives == hideExternalDefensives and cached.inPvpContext == inPvpContext then
		return cached.result
	end

	local seen = {}
	local result = {}

	local disabledSpells = db and db.Modules and db.Modules.FriendlyCooldownTrackerModule and db.Modules.FriendlyCooldownTrackerModule.DisabledSpells or {}

	local function addRules(ruleList)
		if not ruleList then
			return
		end
		for _, rule in ipairs(ruleList) do
			if rule.SpellId and not seen[rule.SpellId] and not disabledSpells[rule.SpellId]
				and not (hideExternalDefensives and rule.ExternalDefensive)
				and not (rule.PvPOnly and not inPvpContext)
			then
				local excluded = false
				if rule.ExcludeIfTalent then
					if type(rule.ExcludeIfTalent) == "table" then
						for _, talentId in ipairs(rule.ExcludeIfTalent) do
							if fcdTalents:UnitHasTalent(unit, talentId, specId) then excluded = true; break end
						end
					else
						excluded = fcdTalents:UnitHasTalent(unit, rule.ExcludeIfTalent, specId)
					end
				end
				local required = false
				if rule.RequiresTalent then
					if type(rule.RequiresTalent) == "table" then
						required = true
						for _, talentId in ipairs(rule.RequiresTalent) do
							if fcdTalents:UnitHasTalent(unit, talentId, specId) then required = false; break end
						end
					else
						required = not fcdTalents:UnitHasTalent(unit, rule.RequiresTalent, specId)
					end
				end
				if not excluded and not required then
					seen[rule.SpellId] = true
					local maxCharges = nil
					local ruleBaseCharges = rule.BaseCharges or 1
					if (rule.MaxCharges or ruleBaseCharges) > 1 then
						local mc = fcdTalents:GetUnitMaxCharges(unit, specId, classToken, rule.SpellId)
						maxCharges = math.max(ruleBaseCharges, mc)
					end
					result[#result + 1] = {
						SpellId = rule.SpellId,
						IsOffensive = rules.OffensiveSpellIds[rule.SpellId] == true,
						MaxCharges = maxCharges,
					}
				end
			end
		end
	end

	addRules(specId and rules.BySpec[specId])
	addRules(rules.ByClass[classToken])

	if specId then
		staticAbilitiesCache[unit] = { specId = specId, hideExternalDefensives = hideExternalDefensives, inPvpContext = inPvpContext, result = result }
	end
	return result
end

---Builds the slot list shown in test mode.
local function BuildTestSlots(showTrinket, showTooltips, iconOptions, predictiveGlow)
	local now = GetTime()
	local slots = {}
	if showTrinket then
		slots[#slots + 1] = {
			Texture = trinketsTracker:GetDefaultIcon(),
			DurationObject = wowEx:CreateDuration(now - 45, 120),
			Alpha = 1,
			ReverseCooldown = false,
			Glow = false,
			Desaturate = iconOptions.DesaturateOnCooldown,
			FontScale = db.FontScale,
		}
	end
	local testSpells = {
		{ SpellId = 642,   StartOffset = 60,  Cooldown = 300 }, -- Divine Shield
		{ SpellId = 33206, StartOffset = 30,  Cooldown = 180 }, -- Pain Suppression
		{ SpellId = 45438, StartOffset = 120, Cooldown = 240 }, -- Ice Block
	}
	for _, t in ipairs(testSpells) do
		local texture = GetSpellIcon(t.SpellId)
		if texture then
			slots[#slots + 1] = {
				Texture = texture,
				SpellId = showTooltips and t.SpellId or nil,
				DurationObject = wowEx:CreateDuration(now - t.StartOffset, t.Cooldown),
				Alpha = 1,
				ReverseCooldown = iconOptions.ReverseCooldown,
				Desaturate = iconOptions.DesaturateOnCooldown,
				FontScale = db.FontScale,
			}
		end
	end
	-- Predictive test spells: buff is active, cooldown not yet committed.
	-- Shows the glow + buff countdown behaviour before the CD swipe starts.
	local testPredictiveSpells = {
		{ SpellId = 288613, StartOffset = 5, BuffDuration = 17 }, -- Trueshot (MM Hunter)
		{ SpellId = 190319, StartOffset = 3, BuffDuration = 15 }, -- Combustion (Fire Mage)
	}
	for _, t in ipairs(testPredictiveSpells) do
		local texture = GetSpellIcon(t.SpellId)
		if texture then
			slots[#slots + 1] = {
				Texture = texture,
				SpellId = showTooltips and t.SpellId or nil,
				DurationObject = predictiveGlow and wowEx:CreateDuration(now - t.StartOffset, t.BuffDuration) or nil,
				Alpha = 1,
				ReverseCooldown = iconOptions.ReverseCooldown,
				Desaturate = false,
				Glow = predictiveGlow and true or nil,
				FontScale = db.FontScale,
			}
		end
	end
	return slots
end

---Appends always-visible static ability slots, with a cooldown swipe when active.
local function AppendStaticSlots(slots, entry, now, showTooltips, iconOptions, predictiveGlow)
	local staticAbilities = GetStaticAbilities(entry.Unit)
	for _, ability in ipairs(staticAbilities) do
		local texture = GetSpellIcon(ability.SpellId)
		local cd = entry.ActiveCooldowns[ability.SpellId]
		if texture then
			local durationObject = nil
			local glow = nil
			local onCooldown = false
			local chargeText = nil
			if cd then
				-- For multi-charge abilities, derive the effective start from the earliest charge's
				-- stored expiry so the timer reflects sequential recharge (not raw use time).
				local startTime = cd.UsedCharges and cd.UsedCharges[1]
					and (cd.UsedCharges[1].Expiry - cd.Cooldown)
					or cd.StartTime
				if now < startTime + cd.Cooldown then
					-- Confirmed cooldown running: show the CD swipe from the earliest charge.
					durationObject = wowEx:CreateDuration(startTime, cd.Cooldown)
					if cd.MaxCharges and cd.MaxCharges > 1 then
						local usedCount = cd.UsedCharges and #cd.UsedCharges or 1
						local available = cd.MaxCharges - usedCount
						onCooldown = available == 0
						chargeText = tostring(available)
					else
						onCooldown = true
					end
				end
			end
			if predictiveGlow and entry.PredictedGlows[ability.SpellId] then
				-- Buff is active: always glow, regardless of whether a charge is also recharging.
				-- When no CD is running yet, also show the aura duration countdown.
				glow = true
				if not durationObject then
					durationObject = entry.PredictedGlowDurations[ability.SpellId]
				end
			elseif not durationObject then
				if ability.MaxCharges and ability.MaxCharges > 1 then
					-- All charges available: show the max charge count.
					chargeText = tostring(ability.MaxCharges)
				end
			end
			slots[#slots + 1] = {
				Texture = texture,
				SpellId = showTooltips and ability.SpellId or nil,
				DurationObject = durationObject,
				Alpha = 1,
				ReverseCooldown = iconOptions.ReverseCooldown,
				Desaturate = iconOptions.DesaturateOnCooldown and onCooldown,
				Glow = glow,
				FontScale = db.FontScale,
				ChargeText = chargeText,
			}
		end
	end
end

---Appends string-keyed (non-static) active-cooldown slots, pruning expired entries.
local function AppendDynamicSlots(slots, entry, now, showTooltips, iconOptions)
	for cdKey, cd in pairs(entry.ActiveCooldowns) do
		if type(cdKey) == "string" then
			if now >= cd.StartTime + cd.Cooldown then
				entry.ActiveCooldowns[cdKey] = nil
			else
				local texture = GetSpellIcon(cd.SpellId)
				if texture then
					slots[#slots + 1] = {
						Texture = texture,
						SpellId = showTooltips and cd.SpellId or nil,
						DurationObject = wowEx:CreateDuration(cd.StartTime, cd.Cooldown),
						Alpha = 1,
						ReverseCooldown = iconOptions.ReverseCooldown,
						Desaturate = iconOptions.DesaturateOnCooldown,
						FontScale = db.FontScale,
					}
				end
			end
		end
	end
end

---Populates an entry's icon container with the current cooldown/trinket slots.
---@param entry FcdWatchEntry
local function UpdateDisplay(entry)
	local anchorOptions = GetAnchorOptions()
	if not anchorOptions then
		return
	end

	-- ExcludeSelf: container is intentionally hidden; don't populate it.
	if anchorOptions.ExcludeSelf and UnitIsUnit(entry.Unit, "player") then
		return
	end

	local container = entry.Container
	local showTooltips = anchorOptions.ShowTooltips
	local iconOptions = anchorOptions.Icons
	local showTrinket = anchorOptions.ShowTrinket ~= false
	local predictiveGlow = anchorOptions.Predictive ~= false

	if testModeActive then
		local testSlots = BuildTestSlots(showTrinket, showTooltips, iconOptions, predictiveGlow)
		local usedCount = math.min(#testSlots, container.Count)
		for i = 1, usedCount do
			container:SetSlot(i, testSlots[i])
		end
		for i = usedCount + 1, container.Count do
			container:SetSlotUnused(i)
		end
		return
	end

	-- Reuse the scratch table to avoid per-call allocation.
	local slots = slotsScratch
	for i = 1, #slots do
		slots[i] = nil
	end

	local now = GetTime()

	-- Trinket: always slot 1 in arena so it lands at the priority position determined by InvertLayout.
	if showTrinket and IsInArena() then
		local durationData = trinketsTracker:GetUnitDuration(entry.Unit)
		slots[1] = {
			Texture = trinketsTracker:GetDefaultIcon(),
			DurationObject = durationData,
			Alpha = true,
			ReverseCooldown = false,
			Glow = false,
			Desaturate = iconOptions.DesaturateOnCooldown,
			FontScale = db.FontScale,
		}
	end

	AppendStaticSlots(slots, entry, now, showTooltips, iconOptions, predictiveGlow)
	AppendDynamicSlots(slots, entry, now, showTooltips, iconOptions)

	local usedCount = math.min(#slots, container.Count)
	for i = 1, usedCount do
		container:SetSlot(i, slots[i])
	end
	for i = usedCount + 1, container.Count do
		container:SetSlotUnused(i)
	end
end

---Positions an entry's container frame relative to its anchor.
---@param entry FcdWatchEntry
local function AnchorContainer(entry)
	local options = GetAnchorOptions()
	if not options then
		return
	end

	local frame = entry.Container.Frame
	local anchor = entry.Anchor

	frame:ClearAllPoints()
	frame:SetAlpha(1)
	local strata = (frames:IsBlizzardPartyFrame(anchor) or frames:IsVuhDoFrame(anchor))
		and frames:GetNextStrata(anchor:GetFrameStrata())
		or anchor:GetFrameStrata()
	frame:SetFrameStrata(strata)
	local level = anchor:GetFrameLevel() + 10
	frame:SetFrameLevel(level)

	local rowsEnabled = options.Icons.Rows and options.Icons.Rows > 1

	local grow = options.Grow
	local isGrowDown = grow == "DOWN"

	if rowsEnabled then
		local size = tonumber(options.Icons.Size) or 32
		local yOffset = options.Offset.Y + size / 2

		if grow == "LEFT" then
			frame:SetPoint("TOPRIGHT", anchor, "LEFT", options.Offset.X, yOffset)
		elseif grow == "RIGHT" then
			frame:SetPoint("TOPLEFT", anchor, "RIGHT", options.Offset.X, yOffset)
		elseif grow == "DOWN" then
			frame:SetPoint("TOP", anchor, "BOTTOM", options.Offset.X, options.Offset.Y)
		else
			frame:SetPoint("TOP", anchor, "CENTER", options.Offset.X, yOffset)
		end
	else
		if grow == "LEFT" then
			frame:SetPoint("RIGHT", anchor, "LEFT", options.Offset.X, options.Offset.Y)
		elseif grow == "RIGHT" then
			frame:SetPoint("LEFT", anchor, "RIGHT", options.Offset.X, options.Offset.Y)
		elseif grow == "DOWN" then
			frame:SetPoint("TOP", anchor, "BOTTOM", options.Offset.X, options.Offset.Y)
		else
			frame:SetPoint("CENTER", anchor, "CENTER", options.Offset.X, options.Offset.Y)
		end
	end

	entry.Container:SetGrowDown(isGrowDown)
	entry.Container:SetColumns(options.Icons.Columns)
end

---Must be called once from M:Init before any display functions are used.
function D:Init()
	db = mini:GetSavedVars()
end

---@param active boolean
function D:SetTestMode(active)
	testModeActive = active
end

---@param entry FcdWatchEntry
function D:UpdateDisplay(entry)
	UpdateDisplay(entry)
end

---@param entry FcdWatchEntry
function D:AnchorContainer(entry)
	AnchorContainer(entry)
end

---Invalidates the static-abilities cache for a unit so the next UpdateDisplay rebuilds it.
---@param unit string
function D:InvalidateStaticAbilitiesCache(unit)
	staticAbilitiesCache[unit] = nil
end

---Clears the entire static-abilities cache (e.g. on PLAYER_SPECIALIZATION_CHANGED).
function D:ResetStaticAbilitiesCache()
	staticAbilitiesCache = {}
end
