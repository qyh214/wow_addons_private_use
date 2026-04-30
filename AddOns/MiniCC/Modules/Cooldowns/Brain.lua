---@type string, Addon
local _, addon = ...

-- Loaded before this file in TOC order.
local rules = addon.Modules.Cooldowns.Rules
local fcdTalents = addon.Modules.Cooldowns.Talents
local units = addon.Utils.Units

addon.Modules.Cooldowns = addon.Modules.Cooldowns or {}

---@class CooldownBrain
local B = {}
addon.Modules.Cooldowns.Brain = B

-- Seconds of timing tolerance when matching a measured buff duration to a rule.
-- Covers frame-rate jitter, network latency, and slight timestamp rounding.
local tolerance = 0.5
-- Seconds within which a UNIT_SPELLCAST_SUCCEEDED counts as cast evidence, and as a tiebreaker
-- when multiple watched units match the same rule (e.g. two Paladins, both can produce BoP).
-- Must be >= evidenceTolerance so the deferred backfill can still catch late-arriving cast events.
-- Both castWindow and evidenceTolerance are kept equal for this reason.
local castWindow = 0.15
-- How long (seconds) to wait for concurrent evidence after a buff appears.
-- For cross-unit spells (e.g. BoF, BoP), UNIT_SPELLCAST_SUCCEEDED on the caster can arrive
-- after UNIT_AURA on the target by one or more server ticks.
local evidenceTolerance = 0.15
-- unit -> timestamp of most recent HARMFUL aura addition (Forbearance indicates Divine Shield).
local lastDebuffTime = {}
-- unit -> timestamp of most recent absorb change (absorb application indicates Divine Protection).
local lastShieldTime = {}
-- unit -> timestamp of most recent UNIT_SPELLCAST_SUCCEEDED (self-cast evidence e.g. Alter Time).
local lastCastTime = {}
-- unit -> list of { SpellId, Time } for recent non-secret cast spell IDs within castWindow.
-- Stored as a list because a single keypress can fire multiple UNIT_SPELLCAST_SUCCEEDED events
-- (e.g. Desperate Prayer triggers procs or follow-up spells), and we must check all of them.
-- Only populated for the local player (UNIT_SPELLCAST_SUCCEEDED provides non-secret IDs locally).
local lastCastSpellIds = {}
-- unit -> timestamp of most recent UNIT_FLAGS (unit combat/immune flags changed e.g. Aspect of the Turtle).
local lastUnitFlagsTime = {}
-- unit -> timestamp of most recent feign death activation (UnitIsFeignDeath transition false->true).
local lastFeignDeathTime = {}
-- unit -> last known feign death state, used to detect false->true transitions.
local lastFeignDeathState = {}
-- Classes for which Precognition (a 4s IMPORTANT PvP gem buff) is not a concern.
-- Melee/physical classes cannot produce the kind of IMPORTANT auras that Precognition mimics.
-- All other classes (MAGE, PRIEST, WARLOCK, PALADIN, DRUID, MONK, SHAMAN, EVOKER) are
-- excluded: in arena/pvp a sudden IMPORTANT aura on them could be Precognition, not their
-- actual cooldown, so no-evidence predictions are suppressed for those classes in PvP.
local precogIgnoreClasses = {
	WARRIOR     = true,
	DEATHKNIGHT = true,
	ROGUE       = true,
	HUNTER      = true,
	DEMONHUNTER = true,
}
-- Module-level scratch table reused by FindBestCandidate to avoid per-call allocation.
local candidateEvidenceScratch = {}
-- unit -> boolean: whether the unit's class can feign death (Hunter only).
-- Populated lazily in RecordUnitFlagsChange so UnitIsFeignDeath is never called for units
-- that cannot feign, avoiding a pointless API call on every UNIT_FLAGS event in a raid.
local unitCanFeign = {}
-- Callback fired when a buff ends and a matching rule is found.
-- Signature: fn(ruleUnit, cdKey, cdData, detectedFromEntry)
-- cdData fields: StartTime, Cooldown, Remaining, SpellId, IsOffensive
local cooldownCallback = nil
-- Callback fired when a tracked defensive aura ends and a cooldown is committed,
-- so the detected entry's display (which may differ from the caster's entry) can update.
-- Signature: fn(entry)
local displayCallback = nil
-- Callback fired when a new non-external aura is detected and a predictive spell match is found.
-- Signature: fn(entry, spellId)
local predictiveGlowCallback = nil
-- Callback fired when a predictively-matched aura is removed.
-- Signature: fn(entry, spellId)
local predictiveGlowEndCallback = nil
-- Lookup function returning a unit's ActiveCooldowns table, or nil if the unit is not watched.
-- Registered by Module so Brain has no direct dependency on Module.
-- Signature: fn(unit) -> table?
local activeCooldownsLookup = nil
-- Callback fired when an active predicted-glow aura's duration changes (e.g. Combustion extended
-- by a talent proc, Avatar extended by a proc).  Lets Module refresh PredictedGlowDurations.
-- Signature: fn(entry, spellId, casterUnit, durationObject)
local predictiveGlowDurationChangedCallback = nil

---@class EvidenceSet
---@field Debuff     boolean?  a HARMFUL aura appeared near detectionTime (e.g. Forbearance from Divine Shield)
---@field Shield     boolean?  an absorb change appeared near detectionTime (e.g. Divine Protection)
---@field UnitFlags  boolean?  unit combat/immune flags changed near detectionTime (e.g. Aspect of the Turtle); suppressed when FeignDeath is the source
---@field FeignDeath boolean?  unit entered feign death near detectionTime; mutually exclusive with UnitFlags to prevent false AoT matches
---@field Cast       boolean?  the local player cast a spell near detectionTime (UNIT_SPELLCAST_SUCCEEDED fires locally only)

---Collects all concurrent evidence types for a unit near detectionTime.
---Returns an EvidenceSet or nil if no evidence was found.
---Multiple types can be present simultaneously when several events fire in the same window;
---callers check for specific keys rather than comparing a single string.
---@param unit string
---@param detectionTime number
---@return EvidenceSet?
local function BuildEvidenceSet(unit, detectionTime)
	---@type EvidenceSet?
	local ev = nil
	if lastDebuffTime[unit] and math.abs(lastDebuffTime[unit] - detectionTime) <= evidenceTolerance then
		ev = ev or {}
		ev.Debuff = true
	end
	if lastShieldTime[unit] and math.abs(lastShieldTime[unit] - detectionTime) <= evidenceTolerance then
		ev = ev or {}
		ev.Shield = true
	end
	-- FeignDeath and UnitFlags are mutually exclusive: if feign death is the source of the flags
	-- change, UnitFlags is suppressed to prevent false Aspect of the Turtle detections.
	if lastFeignDeathTime[unit] and math.abs(lastFeignDeathTime[unit] - detectionTime) <= castWindow then
		ev = ev or {}
		ev.FeignDeath = true
	elseif lastUnitFlagsTime[unit] and math.abs(lastUnitFlagsTime[unit] - detectionTime) <= castWindow then
		ev = ev or {}
		ev.UnitFlags = true
	end
	if lastCastTime[unit] and math.abs(lastCastTime[unit] - detectionTime) <= castWindow then
		ev = ev or {}
		ev.Cast = true
	end
	return ev
end

local function AuraTypesSignature(auraTypes)
	local s = ""
	if auraTypes["BIG_DEFENSIVE"] then
		s = s .. "B"
	end
	if auraTypes["EXTERNAL_DEFENSIVE"] then
		s = s .. "E"
	end
	if auraTypes["IMPORTANT"] then
		s = s .. "I"
	end
	if auraTypes["CROWD_CONTROL"] then
		s = s .. "C"
	end
	return s
end

---Returns true if every defined flag on the rule matches the aura's type set.
--- true  -> type must be present
--- false -> type must be absent
--- nil   -> type is unconstrained
---@param auraTypes table<string,boolean>
local function AuraTypeMatchesRule(auraTypes, rule)
	if rule.BigDefensive == true and not auraTypes["BIG_DEFENSIVE"] then
		return false
	end
	if rule.BigDefensive == false and auraTypes["BIG_DEFENSIVE"] then
		return false
	end
	if rule.ExternalDefensive == true and not auraTypes["EXTERNAL_DEFENSIVE"] then
		return false
	end
	if rule.ExternalDefensive == false and auraTypes["EXTERNAL_DEFENSIVE"] then
		return false
	end
	if rule.Important == true and not auraTypes["IMPORTANT"] then
		return false
	end
	if rule.CrowdControl == true and not auraTypes["CROWD_CONTROL"] then
		return false
	end
	if rule.CrowdControl == false and auraTypes["CROWD_CONTROL"] then
		return false
	end
	return true
end

---Returns true if evidence satisfies a RequiresEvidence value.
---  nil         -> no constraint (always ok)
---  false       -> requires no evidence present
---  string      -> that key must be present in evidence
---  string[]    -> ALL listed keys must be present in evidence
---@param req any
---@param evidence EvidenceSet?
---@return boolean
local function EvidenceMatchesReq(req, evidence)
	if req == nil then
		return true
	end
	if req == false then
		return not evidence or not next(evidence)
	end
	if type(req) == "string" then
		return evidence ~= nil and evidence[req] == true
	end
	if type(req) == "table" then
		if not evidence then
			return false
		end
		for _, k in ipairs(req) do
			if not evidence[k] then
				return false
			end
		end
		return true
	end
	return false
end

---Returns true when spellId has an active cooldown entry with no charges remaining.
---Handles both table-valued entries (MaxCharges/UsedCharges fields) and raw truthy values.
---@param activeCooldowns table?
---@param spellId number?
---@return boolean
local function IsSpellOnCooldown(activeCooldowns, spellId)
	if not activeCooldowns or not spellId then return false end
	local cdEntry = activeCooldowns[spellId]
	if cdEntry == nil then return false end
	if type(cdEntry) ~= "table" then return true end
	return not cdEntry.MaxCharges or not cdEntry.UsedCharges
		or #cdEntry.UsedCharges >= cdEntry.MaxCharges
end

---Returns true when rule passes all talent gate checks for the given unit.
---ignoreTalentReqs: when true (enemy tracking path), skips RequiresTalent and instead
---checks ExcludeFromEnemyTracking.  Pass nil/false for the normal (friendly) path.
local function RulePassesTalentGates(rule, unit, specId, ignoreTalentReqs)
	if ignoreTalentReqs then
		if rule.ExcludeFromEnemyTracking then return false end
	else
		if rule.RequiresTalent then
			if type(rule.RequiresTalent) == "table" then
				local anyFound = false
				for _, id in ipairs(rule.RequiresTalent) do
					if fcdTalents:UnitHasTalent(unit, id, specId) then anyFound = true; break end
				end
				if not anyFound then return false end
			else
				if not fcdTalents:UnitHasTalent(unit, rule.RequiresTalent, specId) then return false end
			end
		end
	end
	if rule.ExcludeIfTalent then
		if type(rule.ExcludeIfTalent) == "table" then
			for _, id in ipairs(rule.ExcludeIfTalent) do
				if fcdTalents:UnitHasTalent(unit, id, specId) then return false end
			end
		else
			if fcdTalents:UnitHasTalent(unit, rule.ExcludeIfTalent, specId) then return false end
		end
	end
	return true
end

---Finds the first rule for the given spellId that passes talent checks and aura type constraints.
---Used by the cast-spell-ID fast path in both MatchRule and PredictRule: having a non-secret
---spell ID from UNIT_SPELLCAST_SUCCEEDED means duration and evidence checks can be skipped.
---Returns the matching rule, or nil if none is found.
---@param unit string
---@param specId number?
local function CastSpellIdMatches(castSpellId, spellId)
	if type(castSpellId) == "table" then
		for _, id in ipairs(castSpellId) do
			if id == spellId then return true end
		end
		return false
	end
	return castSpellId == spellId
end

---@param auraTypes table<string,boolean>
---@param spellId number
---@return table?
local function FindRuleBySpellId(unit, specId, auraTypes, spellId)
	local _, classToken = UnitClass(unit)
	if not classToken then return nil end

	local function checkList(ruleList)
		if not ruleList then return nil end
		for _, rule in ipairs(ruleList) do
			if rule.SpellId == spellId or CastSpellIdMatches(rule.CastSpellId, spellId) then
				if RulePassesTalentGates(rule, unit, specId, nil) and AuraTypeMatchesRule(auraTypes, rule) then
					return rule
				end
			end
		end
		return nil
	end

	return checkList(specId and rules.BySpec[specId]) or checkList(rules.ByClass[classToken])
end

---Returns true when the local player cast an EXT-matching spell within the detection window.
---Returns false when the player provably did not cast one (no snapshot or no match found).
---@param castSpellIdSnapshot table<string,{SpellId:number,Time:number}[]>?
---@param startTime number
---@param auraTypes table<string,boolean>
---@return boolean
local function PlayerHasExtCastInWindow(castSpellIdSnapshot, startTime, auraTypes)
	local playerCasts = castSpellIdSnapshot and castSpellIdSnapshot["player"]
	if not playerCasts then return false end
	local playerSpecId = fcdTalents:GetUnitSpecId("player")
	for _, cast in ipairs(playerCasts) do
		if math.abs(cast.Time - startTime) <= castWindow then
			if FindRuleBySpellId("player", playerSpecId, auraTypes, cast.SpellId) then
				return true
			end
		end
	end
	return false
end

---Checks whether unit (or its GUID) has already been seen.
---If not, marks both the unit string and its GUID as seen and returns true.
---Returns false when the unit was already present.
---@param seen table<string,boolean>
---@param unit string
---@return boolean
local function AddIfUnseen(seen, unit)
	if seen[unit] then return false end
	local guid = UnitGUID(unit)
	local guidKey = guid and not issecretvalue(guid) and guid
	if guidKey and seen[guidKey] then return false end
	seen[unit] = true
	if guidKey then seen[guidKey] = true end
	return true
end

---Finds the first rule matching the aura type and measured duration.
---Tries spec-level rules first for precision, falls back to class-level rules.
---@param unit string   caster unit for EXTERNAL_DEFENSIVE, recipient unit for BIG_DEFENSIVE/IMPORTANT
---@param auraTypes table<string,boolean>
---@param measuredDuration number
---@param context MatchRuleContext?
---@return table?
local function MatchRule(unit, auraTypes, measuredDuration, context)
	local _, classToken = UnitClass(unit)
	if not classToken then
		return nil
	end

	local specId = fcdTalents:GetUnitSpecId(unit)
	local evidence = context and context.Evidence
	local activeCooldowns = context and context.ActiveCooldowns
	-- When the caller has confirmed the aura was actually present (ECD aura-based matching),
	-- talent requirements are redundant - the buff's existence proves the ability was used.
	-- Enemy PvP talent data is never available via PvPTalentSync, so RequiresTalent would
	-- always fail for enemies even when they demonstrably have the talent (e.g. Nether Ward).
	local ignoreTalentReqs = context and context.IgnoreTalentRequirements

	-- Fast path: non-secret spell IDs from UNIT_SPELLCAST_SUCCEEDED skip duration and evidence
	-- checks when an ID matches a tracked rule.  Falls through to normal matching when none match:
	-- MatchRule has MinCancelDuration and duration/evidence guards that correctly reject short proc
	-- buffs, so returning nil here would only create false negatives (e.g. Desperate Prayer).
	-- Multiple IDs are checked because one keypress can fire several UNIT_SPELLCAST_SUCCEEDED events.
	local knownSpellIds = context and context.KnownSpellIds
	if knownSpellIds then
		for _, sid in ipairs(knownSpellIds) do
			local fastRule = FindRuleBySpellId(unit, specId, auraTypes, sid)
			if fastRule then return fastRule end
		end
	end

	local function tryRuleList(ruleList)
		if not ruleList then
			return nil
		end
		local fallback = nil
		for _, rule in ipairs(ruleList) do
			if RulePassesTalentGates(rule, unit, specId, ignoreTalentReqs) then
				local expectedDuration = rule.SpellId
						and fcdTalents:GetUnitBuffDuration(unit, specId, classToken, rule.SpellId, rule.BuffDuration)
					or rule.BuffDuration
				local typeMatch = AuraTypeMatchesRule(auraTypes, rule)
				if typeMatch then
					local req = rule.RequiresEvidence
					local evidenceOk = EvidenceMatchesReq(req, evidence)
					if evidenceOk then
						local durationOk
						if rule.MinDuration then
							durationOk = measuredDuration >= expectedDuration - tolerance
						elseif rule.CanCancelEarly == true then
							durationOk = measuredDuration <= expectedDuration + tolerance
								and (not rule.MinCancelDuration or measuredDuration >= rule.MinCancelDuration)
						else
							durationOk = math.abs(measuredDuration - expectedDuration) <= tolerance
						end
						if durationOk then
							if not IsSpellOnCooldown(activeCooldowns, rule.SpellId) then
								return rule
							elseif not fallback then
								fallback = rule
							end
						end
					end
				end
			end
		end
		return fallback
	end

	-- Spec rules take priority; fall through to class rules if no match.
	return tryRuleList(specId and rules.BySpec[specId]) or tryRuleList(rules.ByClass[classToken])
end

---Returns true when 'unit' has at least one CastableOnOthers rule that matches 'auraTypes'
---and requires Shield evidence.  Used to grant selective synthetic Cast to candidates that
---can only win via a Shield-requiring spell (e.g. AMS from Spellwarding), so a Paladin whose
---BoF does not require Shield is never mistakenly promoted via the same bypass.
---@param unit string
---@param auraTypes table<string,boolean>
---@return boolean
local function CandidateHasShieldRule(unit, auraTypes)
	local _, classToken = UnitClass(unit)
	if not classToken then return false end
	local specId = fcdTalents:GetUnitSpecId(unit)
	local function checkList(ruleList)
		if not ruleList then return false end
		for _, rule in ipairs(ruleList) do
			if rule.CastableOnOthers and AuraTypeMatchesRule(auraTypes, rule) then
				local req = rule.RequiresEvidence
				if req then
					if type(req) == "table" then
						for _, r in ipairs(req) do
							if r == "Shield" then return true end
						end
					elseif req == "Shield" then
						return true
					end
				end
			end
		end
		return false
	end
	if specId and checkList(rules.BySpec[specId]) then return true end
	return checkList(rules.ByClass[classToken])
end

---Tries to match auraTypes + evidence against a single unit's rule lists.
---Returns the matched SpellId and whether that spell is currently on cooldown, or nil.
---Stops at the FIRST matching rule (the intended ability) rather than falling through to
---alternatives - a fallback to a different spell would cause false ambiguity in PredictRule
---when compared against other candidates who correctly matched the primary spell.
---@param unit string
---@param auraTypes table<string,boolean>
---@param evidence EvidenceSet?
---@param castableFilter string?  nil = no filter; "only" = only CastableOnOthers rules; "exclude" = exclude CastableOnOthers rules
---@return number? spellId
---@return boolean isOnCooldown
local function PredictSpellIdForUnit(unit, auraTypes, evidence, castableFilter)
	local _, classToken = UnitClass(unit)
	if not classToken then
		return nil
	end

	local specId = fcdTalents:GetUnitSpecId(unit)
	local activeCooldowns = activeCooldownsLookup and activeCooldownsLookup(unit)

	local function tryRuleList(ruleList)
		if not ruleList then
			return nil
		end
		for _, rule in ipairs(ruleList) do
			if rule.SpellId then
				if not ((castableFilter == "only" or castableFilter == "only_evidence") and not rule.CastableOnOthers)
				and not (castableFilter == "exclude" and rule.CastableOnOthers)
				and not (castableFilter == "only_evidence" and rule.RequiresEvidence == nil)
				and not rule.ExcludeFromPrediction then
					if RulePassesTalentGates(rule, unit, specId, nil) then
						if AuraTypeMatchesRule(auraTypes, rule)
						and EvidenceMatchesReq(rule.RequiresEvidence, evidence) then
							-- Return the first match plus its CD state.  Do NOT fall through to
							-- other rules: if this spell is on CD this candidate is ineligible
							-- rather than being attributed to a different spell, which would
							-- produce false ambiguity against candidates who matched correctly.
							return rule.SpellId, IsSpellOnCooldown(activeCooldowns, rule.SpellId), rule
						end
					end
				end
			end
		end
		return nil
	end

	-- Spec rules take priority.  Explicit branch rather than `or` so both return values
	-- (spellId, isOnCooldown) are forwarded correctly - `or` only propagates one value.
	local spellId, onCd, specRule = tryRuleList(specId and rules.BySpec[specId])
	if spellId ~= nil then
		-- Cross-level ambiguity: when the spec rule has no evidence requirement, a class rule
		-- with a different spell ID is an equally plausible match (e.g. Blood DK Vampiric Blood
		-- vs Icebound Fortitude or Anti-Magic Shell).  Suppress prediction so the caller does not
		-- commit to the spec-rule spell without cast evidence.
		-- When the spec rule has a specific RequiresEvidence, that evidence uniquely identifies it
		-- (e.g. Ice Block requiring Debuff+UnitFlags), so a more permissive class rule matching
		-- the same aura is not a genuine alternative candidate.
		if specRule.RequiresEvidence == nil then
			local classSpellId, classOnCd, classRule = tryRuleList(rules.ByClass[classToken])
			if classSpellId ~= nil and not classOnCd and classSpellId ~= spellId then
				-- Genuine ambiguity only when the class rule explicitly covers every aura-type
				-- dimension that the spec rule requires.  If the spec rule declares CrowdControl=true
				-- but the class rule leaves it nil, the class rule is not a real alternative for a
				-- CC aura (e.g. Dispersion vs Desperate Prayer).
				if (specRule.BigDefensive ~= true or classRule.BigDefensive == true)
				and (specRule.ExternalDefensive ~= true or classRule.ExternalDefensive == true)
				and (specRule.Important ~= true or classRule.Important == true)
				and (specRule.CrowdControl ~= true or classRule.CrowdControl == true) then
					-- If the class rule requires specific evidence (e.g. Shield for AMS) but the
					-- spec rule does not, the evidence is a positive signal for the class rule.
					-- Defer to it rather than treating the result as ambiguous.
					if classRule.RequiresEvidence ~= nil then
						return classSpellId, classOnCd
					end
					return nil, false
				end
			end
		end
		return spellId, onCd
	end
	return tryRuleList(rules.ByClass[classToken])
end

---Returns "player" when the candidate is the local player appearing under an alias unit ID
---(e.g. "raid2" in a 2v2 arena), otherwise returns the candidate unchanged.
local function ResolveSnapshotUnit(candidate)
	if candidate == "player" then return candidate end
	local guid = UnitGUID(candidate)
	if guid and not issecretvalue(guid) then
		local playerGuid = UnitGUID("player")
		if playerGuid and not issecretvalue(playerGuid) and guid == playerGuid then
			return "player"
		end
	end
	return candidate
end

---Fast-path prediction from a known non-secret cast spell ID.
---Only applicable for non-EXTERNAL_DEFENSIVE auras where the target's UNIT_SPELLCAST_SUCCEEDED
---was recorded.  Returns spellId, true when a rule matches; nil, true when IDs were present in
---the window but none matched (definitive no-match - do not fall through to evidence inference);
---nil, false when the fast path does not apply and normal logic should continue.
---@param targetUnit string
---@param auraTypes table<string,boolean>
---@param castSpellIdSnapshot table<string,{SpellId:number,Time:number}[]>?
---@param detectionTime number
---@return number? spellId
---@return boolean handled
local function TryPredictFromKnownCastId(targetUnit, auraTypes, castSpellIdSnapshot, detectionTime)
	if auraTypes["EXTERNAL_DEFENSIVE"] then return nil, false end
	-- The local player may appear under a raid/party alias; resolve to "player" for snapshot lookup.
	local snapshotUnit = ResolveSnapshotUnit(targetUnit)
	local knownCasts = castSpellIdSnapshot and castSpellIdSnapshot[snapshotUnit]
	if not knownCasts then return nil, false end
	-- Check whether any entry falls within the detection window.  A single keypress can produce
	-- multiple UNIT_SPELLCAST_SUCCEEDED events, so the list may contain several spell IDs.
	local anyInWindow = false
	for _, cast in ipairs(knownCasts) do
		if math.abs(cast.Time - detectionTime) <= castWindow then
			anyInWindow = true; break
		end
	end
	if not anyInWindow then return nil, false end
	local specId = fcdTalents:GetUnitSpecId(targetUnit)
	for _, cast in ipairs(knownCasts) do
		if math.abs(cast.Time - detectionTime) <= castWindow then
			local fastRule = FindRuleBySpellId(targetUnit, specId, auraTypes, cast.SpellId)
			if fastRule then
				-- Return the rule's canonical SpellId, not the raw cast ID - these differ
				-- when CastSpellId is used (e.g. Alter Time: cast=342247, rule.SpellId=342246).
				return fastRule.SpellId, true
			end
		end
	end
	-- IDs were in the window but none matched a tracked rule (e.g. Fade -> Phase Shift proc).
	-- Don't fall through to indirect evidence matching: we know what was cast.
	return nil, true
end

-- Maximum duration (seconds) that Precognition can last.
local precognitionMaxDuration = 4.0

---Returns true when the aura could be Precognition rather than a real cooldown.
---Precognition (PvP gem) grants a short IMPORTANT buff when the player is interrupted.
---Used as the predict-path gate for all IMPORTANT auras in pvp/arena: without a cast
---snapshot, a sudden IMPORTANT aura on a caster class is ambiguous with Precognition.
---EXTERNAL_DEFENSIVE auras are routed through searchExternal before this check so they
---are excluded here as a safety net only.
---Melee classes (precogIgnoreClasses) are exempt: Precognition only targets casters.
---UnitIsPVP covers open-world War Mode where IsInInstance does not report "pvp"/"arena".
---measuredDuration: when provided, auras longer than Precognition's max are excluded.
---evidence: when provided, UnitFlags must be present (the interrupt that triggers Precognition
---fires UNIT_FLAGS; real cooldowns like Doomwinds do not).  Nil on the predict path where
---evidence may not have arrived yet.
---@param auraTypes table<string,boolean>
---@param targetUnit string
---@param measuredDuration number?
---@param evidence EvidenceSet?
---@return boolean
local function IsProbablyPrecognition(auraTypes, targetUnit, measuredDuration, evidence)
	if not auraTypes["IMPORTANT"] then return false end
	if auraTypes["BIG_DEFENSIVE"] or auraTypes["EXTERNAL_DEFENSIVE"] then return false end
	if measuredDuration and measuredDuration > precognitionMaxDuration + tolerance then return false end
	if evidence and not evidence.UnitFlags then return false end
	local _, instanceType = IsInInstance()
	local inPvpContext = instanceType == "arena" or instanceType == "pvp" or UnitIsPVP(targetUnit)
	if not inPvpContext then return false end
	local _, classToken = UnitClass(targetUnit)
	return classToken == nil or precogIgnoreClasses[classToken] ~= true
end

-- PvP talent spell IDs that grant Grounding Totem (one per shaman spec).
local groundingTotemPvPTalentIds = { 3620, 3622, 715 }

-- Maximum duration (seconds) that Grounding Totem can last, used to rule it out
-- when the measured aura duration is clearly longer than GT could ever be.
-- Set slightly above the stated 3s cap to absorb server/client timing jitter.
local groundingTotemMaxDuration = 3.5

---Returns true when a non-shaman unit's IMPORTANT aura is probably Grounding Totem spillover.
---Grounding Totem (spell 204336) always affects the shaman and passively affects nearby allies.
---The shaman's own aura is handled by the GT rule directly; this suppresses false commits/predictions
---for non-shaman allies who received the buff without casting anything themselves.
---measuredDuration: when provided (commit path), auras longer than GT's max are excluded.
---evidence: when provided, Shield evidence rules out GT spillover (GT grants no absorb to allies).
---castSpellIdSnapshot/startTime: when provided, used to disambiguate two-shaman scenarios via
---UNIT_SPELLCAST_SUCCEEDED (fires for local player only on 12.0.5+).
---@param auraTypes table<string,boolean>
---@param targetUnit string
---@param candidateUnits string[]
---@param measuredDuration number?
---@param evidence EvidenceSet?
---@param castSpellIdSnapshot table<string,{SpellId:number,Time:number}[]>?
---@param startTime number?
---@return boolean
local function IsProbablyGroundingTotem(auraTypes, targetUnit, candidateUnits, measuredDuration, evidence, castSpellIdSnapshot, startTime)
	if not auraTypes["IMPORTANT"] then return false end
	if auraTypes["BIG_DEFENSIVE"] or auraTypes["EXTERNAL_DEFENSIVE"] then return false end
	-- If the aura lasted longer than GT's maximum possible duration it can't be GT.
	if measuredDuration and measuredDuration > groundingTotemMaxDuration + tolerance then return false end
	-- GT grants no absorb shield to allies; Shield evidence means this is a different spell.
	if evidence and evidence.Shield then return false end
	local _, instanceType = IsInInstance()
	local inPvpContext = instanceType == "arena" or instanceType == "pvp" or UnitIsPVP(targetUnit)
	if not inPvpContext then return false end

	local function shamanHasGroundingTotem(unit)
		local _, cls = UnitClass(unit)
		if cls ~= "SHAMAN" then return false end
		for _, talentId in ipairs(groundingTotemPvPTalentIds) do
			if fcdTalents:UnitHasTalent(unit, talentId) then return true end
		end
		return false
	end

	-- When the target is a shaman (their own GT aura), use cast evidence to disambiguate
	-- two-shaman scenarios.  UNIT_SPELLCAST_SUCCEEDED only fires for the local player, so:
	--   Case A: local player is the target, no GT cast in their snapshot, and another GT shaman
	--           is a candidate -> local player did not press GT; suppress to let the other shaman
	--           be attributed.
	--   Case B: target is a remote shaman, local player's snapshot proves THEY pressed GT, and
	--           local player also has GT talent -> remote shaman's aura is GT spillover from the
	--           local player; suppress the remote shaman's commit.
	--   Tiebreaker: no cast evidence (e.g. 3rd-party observer watching two GT shamans).  Suppress
	--           this shaman if another GT shaman candidate sorts earlier by unit string, mirroring
	--           BoF's first-candidate-wins behaviour when two paladins compete for the same entry.
	if shamanHasGroundingTotem(targetUnit) then
		local groundingTotemSpellId = 204336
		if ResolveSnapshotUnit(targetUnit) == "player" then
			-- Case A: local player is the shaman target.  If they have no GT cast in the window
			-- and another GT shaman is in the candidate list, the other shaman pressed it.
			local localCasts = castSpellIdSnapshot and castSpellIdSnapshot["player"]
			local localPressedGT = false
			if localCasts and startTime then
				for _, cast in ipairs(localCasts) do
					if cast.SpellId == groundingTotemSpellId and math.abs(cast.Time - startTime) <= castWindow then
						localPressedGT = true
						break
					end
				end
			end
			if localPressedGT then
				return false  -- local player provably pressed GT; skip tiebreaker
			end
			for _, candidate in ipairs(candidateUnits) do
				if ResolveSnapshotUnit(candidate) ~= "player" and shamanHasGroundingTotem(candidate) then
					return true
				end
			end
		elseif castSpellIdSnapshot and startTime then
			-- Case B: target is a remote shaman.  If the local player's snapshot proves they pressed
			-- GT within the window and they also have GT talent, the remote shaman's aura is spillover.
			local localCasts = castSpellIdSnapshot["player"]
			if localCasts and shamanHasGroundingTotem("player") then
				for _, cast in ipairs(localCasts) do
					if cast.SpellId == groundingTotemSpellId and math.abs(cast.Time - startTime) <= castWindow then
						return true
					end
				end
			end
		end
		-- Tiebreaker: suppress this shaman if another GT shaman candidate sorts earlier by unit
		-- string.  The "smallest" unit wins the commit; all others are suppressed.
		-- Exception: when the earlier candidate is the local player, only count them if their
		-- snapshot proves they pressed GT.  An absent or empty snapshot means they provably did
		-- not press GT (UNIT_SPELLCAST_SUCCEEDED always fires for "player" on 12.0.5+).
		for _, candidate in ipairs(candidateUnits) do
			local resolvedCandidate = ResolveSnapshotUnit(candidate)
			if resolvedCandidate ~= ResolveSnapshotUnit(targetUnit)
				and shamanHasGroundingTotem(candidate)
				and candidate < targetUnit then
				local eligible = true
				if resolvedCandidate == "player" then
					eligible = false
					local localCasts = castSpellIdSnapshot and castSpellIdSnapshot["player"]
					if localCasts and startTime then
						for _, cast in ipairs(localCasts) do
							if cast.SpellId == groundingTotemSpellId and math.abs(cast.Time - startTime) <= castWindow then
								eligible = true; break
							end
						end
					end
				end
				if eligible then return true end
			end
		end
		return false
	end

	for _, candidate in ipairs(candidateUnits) do
		if shamanHasGroundingTotem(candidate) then
			return true
		end
	end
	return false
end

---Returns the predicted SpellId and caster unit for a newly-detected aura, or nil.
---For non-external auras, matches against the target unit itself (which is the caster).
---For EXTERNAL_DEFENSIVE, searches candidateUnits for a unit with recent cast evidence and a matching rule.
---Returns spellId, casterUnit - casterUnit is nil for self-cast auras (caster == target).
---@param targetUnit string
---@param auraTypes table<string,boolean>
---@param evidence EvidenceSet?
---@param castSnapshot table<string,number>
---@param castSpellIdSnapshot table<string,{SpellId:number,Time:number}>
---@param detectionTime number
---@param candidateUnits string[]
---@return number?, string?
local function PredictRule(targetUnit, auraTypes, evidence, castSnapshot, castSpellIdSnapshot, detectionTime, candidateUnits)
	-- Fast path: if the target's UNIT_SPELLCAST_SUCCEEDED was recorded, use it directly.
	-- Bypasses all evidence inference - a known spell ID is a stronger signal than any evidence.
	-- BoF/CastableOnOthers ambiguity and the EXT path both require the full candidate loop instead.
	local fastSpellId, handled = TryPredictFromKnownCastId(targetUnit, auraTypes, castSpellIdSnapshot, detectionTime)
	if handled then return fastSpellId, nil end

	local matchSpellId, matchCasterUnit, matchCastDiff, ambiguous = nil, nil, nil, false

	-- Evaluates one candidate and records the match (or ambiguity) into the outer locals.
	-- castableFilter: nil = no filter, "only" = CastableOnOthers rules only, "exclude" = exclude them.
	local function consider(candidate, useSnapshot, castableFilter)
		if ambiguous then return end
		local candidateEvidence = evidence
		local castTime = nil
		-- Resolve to "player" when this candidate is the local player appearing under a raid/party
		-- alias (e.g. "raid2" in a 2v2 arena).  Cast snapshots are keyed only under "player", so
		-- using the alias key would miss the local player's real cast evidence.
		local snapshotUnit = ResolveSnapshotUnit(candidate)
		if useSnapshot then
			castTime = castSnapshot[snapshotUnit]
			if not castTime or math.abs(castTime - detectionTime) > castWindow then
				return
			end
		end
		-- When non-secret spell IDs are available for this candidate, use them as a negative
		-- signal: if any fall within the cast window but none match a rule for this aura type,
		-- the candidate demonstrably cast something else and cannot be the caster.
		-- On 12.0.5+ only the local player has entries in castSpellIdSnapshot, so in practice
		-- this only excludes "player" from EXTERNAL_DEFENSIVE attribution when they cast another
		-- spell at the same time.  Pre-12.0.5 it applies to any candidate whose IDs were recorded.
		-- knownCasts come from snapshotUnit's cast snapshot, so rule verification uses
		-- snapshotUnit's spec/class data (e.g. "player" rather than its "raid2" alias).
		local knownCasts = castSpellIdSnapshot and castSpellIdSnapshot[snapshotUnit]
		if knownCasts then
			local specId = fcdTalents:GetUnitSpecId(snapshotUnit)
			local anyInWindow, anyMatch = false, false
			for _, cast in ipairs(knownCasts) do
				if math.abs(cast.Time - detectionTime) <= castWindow then
					anyInWindow = true
					if FindRuleBySpellId(snapshotUnit, specId, auraTypes, cast.SpellId) then
						anyMatch = true; break
					end
				end
			end
			if anyInWindow and not anyMatch then return end
		end
		if useSnapshot then
			candidateEvidence = { Cast = true }
			if evidence then
				for k, v in pairs(evidence) do
					if k ~= "Cast" then candidateEvidence[k] = v end
				end
			end
		end
		-- Use snapshotUnit for talent/class lookup: when candidate is a local player alias
		-- (e.g. "raid2"), snapshotUnit ("player") carries the correct spec data.
		-- matchCasterUnit is still set to candidate (the group-frame unit string, not "player").
		local spellId, isOnCd = PredictSpellIdForUnit(snapshotUnit, auraTypes, candidateEvidence, castableFilter)
		-- nil  -> no rule matched this aura for this candidate at all
		-- true -> rule matched but spell is on CD; candidate is ineligible, not ambiguous
		if not spellId or isOnCd then return end
		-- Reject self-cast predictions for rules marked SelfCastable=false (e.g. Blessing of
		-- Sacrifice).  Re-lookup the rule via spellId to read the flag; PredictSpellIdForUnit
		-- returns only the ID, not the rule object itself.
		if candidate == targetUnit then
			local specId = fcdTalents:GetUnitSpecId(snapshotUnit)
			local selfRule = FindRuleBySpellId(snapshotUnit, specId, auraTypes, spellId)
			if selfRule and selfRule.SelfCastable == false then return end
		end
		if matchSpellId == nil then
			matchSpellId = spellId
			matchCasterUnit = (candidate ~= targetUnit) and candidate or nil
			matchCastDiff = castTime and math.abs(castTime - detectionTime) or nil
		elseif matchSpellId ~= spellId then
			ambiguous = true
		else
			-- Same spell matched by a different candidate.  Prefer whoever's cast was closest
			-- to the moment the buff appeared - disambiguates e.g. two Paladins who both had
			-- recent casts but only one actually pressed BoP.
			local diff = castTime and math.abs(castTime - detectionTime) or nil
			if diff and (not matchCastDiff or diff < matchCastDiff) then
				matchCasterUnit = (candidate ~= targetUnit) and candidate or nil
				matchCastDiff = diff
			end
		end
	end

	-- Searches all non-target candidates for an EXT caster, then runs the self-cast fallback
	-- when no non-target matched with real cast evidence.
	local function searchExternal()
		-- Primary pass: candidates with real cast snapshot (definitively attributable).
		-- GUIDs deduplicate players who appear under multiple unit IDs simultaneously.
		local seen = {}
		for _, candidate in ipairs(candidateUnits) do
			if AddIfUnseen(seen, candidate) then
				if candidate ~= targetUnit then
					consider(candidate, true, nil)
				end
			end
		end
		-- Self-cast fallback (snapshot-based): the target may be both caster and recipient
		-- (e.g. Disc Priest self-casting Pain Suppression, Ret Paladin self-casting BoP,
		-- Monk self-casting Life Cocoon).  Only runs when no non-target matched or when no
		-- real cast time was found, so the target gets a chance to resolve ambiguity
		-- (e.g. Monk self-casting LC vs a Paladin's BoS).
		if (not matchSpellId or matchCastDiff == nil) and not ambiguous then
			consider(targetUnit, true, nil)
		end
		-- Evidence-only fallback: when no definitive cast snapshot is available (12.0.5+
		-- no longer fires UNIT_SPELLCAST_SUCCEEDED for non-local units), match candidates
		-- using only non-Cast evidence (Debuff/Shield/UnitFlags).  This restores EXT spell
		-- discrimination (e.g. BoS requires Shield, Ironbark does not) without injecting
		-- synthetic Cast evidence.
		if not matchSpellId and not ambiguous then
			local seen2 = {}
			for _, candidate in ipairs(candidateUnits) do
				if AddIfUnseen(seen2, candidate) then
					if candidate ~= targetUnit then
						-- Skip the local player as a non-target EXT candidate when they have no EXT
						-- cast in the snapshot window.  UNIT_SPELLCAST_SUCCEEDED fires for "player",
						-- so empty CastSpellIdSnapshot means they provably cast nothing relevant.
						local snapshotUnit = ResolveSnapshotUnit(candidate)
						if snapshotUnit == "player"
						and not PlayerHasExtCastInWindow(castSpellIdSnapshot, detectionTime, auraTypes) then
							-- skip: player cast no EXT spell
						else
							consider(candidate, false, nil)
						end
					end
				end
			end
			-- Self-cast EXT fallback: apply the same playerCastNoExt guard used for the snapshot
			-- path.  If targetUnit="player" and they have no EXT cast in the snapshot, they did
			-- not cast the EXT spell, so suppress self-attribution.
			if (not matchSpellId or matchCastDiff == nil) and not ambiguous then
				local skipSelfCast = targetUnit == "player"
					and not PlayerHasExtCastInWindow(castSpellIdSnapshot, detectionTime, auraTypes)
				if not skipSelfCast then
					consider(targetUnit, false, nil)
				end
			end
		end
	end

	-- Checks the target's own self-cast rules, then checks cross-unit CastableOnOthers casters.
	local function searchNonExternal()
		-- Self-only rules for the target (e.g. Barkskin, Ice Block).
		-- IsProbablyPrecognition already guards the entire searchNonExternal call for the
		-- IMPORTANT+UnitFlags+pvp case, so no additional suppression is needed here.
		consider(targetUnit, false, "exclude")
		-- CastableOnOthers rules via cast snapshot: if the spellId differs from the self-cast
		-- result, the prediction is ambiguous (e.g. Paladin self-casting BoF vs Avenging Crusader).
		consider(targetUnit, true, "only")
		-- Cross-unit candidates: only CastableOnOthers rules, so self-only spells like
		-- Avenging Crusader are never returned as the caster of a buff on a different unit.
		-- GUIDs deduplicate players who appear under multiple unit IDs simultaneously.
		local seen = {}
		AddIfUnseen(seen, targetUnit)
		for _, candidate in ipairs(candidateUnits) do
			if AddIfUnseen(seen, candidate) then
				consider(candidate, true, "only")
			end
		end
		-- Evidence-only fallback for CastableOnOthers cross-unit candidates (12.0.5+):
		-- when no cast snapshot exists for non-local units, try matching them without a
		-- snapshot so spells like AMS Spellwarding and Rescue can still be attributed via
		-- their RequiresEvidence constraint alone.  Restricted to rules that have a non-nil
		-- RequiresEvidence ("only_evidence" filter) so that no-evidence-required spells like
		-- BoF cannot falsely match any IMPORTANT aura when a Paladin is in the group.
		-- Must run even when matchSpellId is already set: if a cross-unit evidence-constrained
		-- candidate matches a different spell (e.g. DK's AMS vs Paladin's self-cast AW), the
		-- result is genuinely ambiguous and the self-cast prediction must be suppressed.
		if not ambiguous then
			local seen2 = {}
			AddIfUnseen(seen2, targetUnit)
			for _, candidate in ipairs(candidateUnits) do
				if AddIfUnseen(seen2, candidate) then
					consider(candidate, false, "only_evidence")
				end
			end
		end
		-- For remote targets (12.0.5+, no cast-ID snapshot), also check the target's own
		-- CastableOnOthers rules without a snapshot.  A remote Paladin self-casting BoF
		-- produces an IMPORTANT aura that is indistinguishable from AW (also IMPORTANT,
		-- self-only) when there is no cast evidence.  If a CastableOnOthers rule matches a
		-- different spell than the self-only match (matchSpellId), the prediction is ambiguous
		-- and correctly suppressed.  Only runs when something already matched (matchSpellId ~= nil)
		-- so that the IsProbablyPrecognition outer gate is respected and this pass
		-- cannot introduce a false match when nothing else would have predicted.  Skipped for the
		-- local player (snapshotUnit == "player") because their actual cast IDs are always
		-- available via castSpellIdSnapshot and empty-snapshot means they provably cast nothing.
		if not ambiguous and matchSpellId ~= nil and ResolveSnapshotUnit(targetUnit) ~= "player" then
			consider(targetUnit, false, "only")
		end
	end

	if auraTypes["EXTERNAL_DEFENSIVE"] then
		searchExternal()
	elseif IsProbablyPrecognition(auraTypes, targetUnit) then
		-- Aura has the IMPORTANT+UnitFlags+pvp signature of Precognition.  Suppress the
		-- entire non-external search so no spell is falsely predicted.
		return nil, nil
	elseif IsProbablyGroundingTotem(auraTypes, targetUnit, candidateUnits, nil, evidence, castSpellIdSnapshot, detectionTime) then
		-- Non-shaman ally received Grounding Totem's AoE buff; suppress to avoid false predictions.
		return nil, nil
	else
		searchNonExternal()
	end

	if ambiguous then return nil, nil end
	return matchSpellId, matchCasterUnit
end

---Builds the per-candidate evidence set used by FindBestCandidate's consider() function.
---Copies non-Cast evidence from tracked.Evidence, then sets Cast when the candidate has a
---real CastSnapshot entry within the cast window.
---Returns the evidence table (pointing at the shared scratch buffer) and the in-window castTime.
---castTime is nil when the snapshot entry is outside the cast window; callers use it for
---betterByTime/betterCOO, so stale times (e.g. a spell cast seconds before this aura appeared)
---must not be forwarded — they would set bestTime non-nil and prevent betterCOO from firing.
---@param snapshotUnit string  candidate remapped to "player" when it is the local player's alias
---@param tracked table  FcdTrackedAura
---@return EvidenceSet? candidateEvidence
---@return number? castTime  nil when outside castWindow
local function BuildCandidateEvidence(snapshotUnit, tracked)
	local scratch = candidateEvidenceScratch
	scratch.Debuff     = nil
	scratch.Shield     = nil
	scratch.UnitFlags  = nil
	scratch.FeignDeath = nil
	scratch.Cast       = nil
	local hasEvidence  = false
	if tracked.Evidence then
		for k, v in pairs(tracked.Evidence) do
			if k ~= "Cast" then scratch[k] = v; hasEvidence = true end
		end
	end
	local rawCastTime = tracked.CastSnapshot[snapshotUnit]
	local castTime = rawCastTime and math.abs(rawCastTime - tracked.StartTime) <= castWindow and rawCastTime or nil
	if castTime then
		scratch.Cast = true
		hasEvidence  = true
	end
	return hasEvidence and scratch or nil, castTime
end

---Extracts spell IDs from a CastSpellIdSnapshot entry that fall within the cast window.
---Returns a list of matching spell IDs, or nil when none were found.
---@param snapshot table<string,{SpellId:number,Time:number}[]>?
---@param unit string
---@param startTime number
---@return number[]?
local function GetKnownSpellIdsInWindow(snapshot, unit, startTime)
	local dataList = snapshot and snapshot[unit]
	if not dataList then return nil end
	local result = nil
	for _, data in ipairs(dataList) do
		if math.abs(data.Time - startTime) <= castWindow then
			result = result or {}
			result[#result + 1] = data.SpellId
		end
	end
	return result
end

---Evaluates all candidate units and returns the best-matching rule and caster unit.
---candidateUnits is supplied by Observer from its internal watched-entry map so Brain
---has no direct dependency on Module.
---Uses the same candidate-ordering logic as PredictRule, with the addition of a duration
---gate (MatchRule) that PredictRule omits.
---Primary tiebreaker: most recent cast evidence wins (distinguishes caster from recipient).
---Secondary tiebreaker: for non-EXTERNAL_DEFENSIVE, a non-target matching a different
---CastableOnOthers rule wins over the target self-matching a CastableOnOthers rule.
---@param candidateUnits string[]  list of unit strings from all active watch entries
---@return table? rule
---@return string ruleUnit
local function FindBestCandidate(entry, tracked, measuredDuration, candidateUnits, opts)
	local rule, ruleUnit         = nil, entry.Unit
	local bestTime, bestIsTarget = nil, false
	local isExternal             = tracked.AuraTypes["EXTERNAL_DEFENSIVE"]
	local ambiguous              = false
	local ignoreTalentReqs       = opts and opts.IgnoreTalentRequirements

	local function consider(candidate, isTarget)
		local snapshotUnit = ResolveSnapshotUnit(candidate)
		local candidateEvidence, castTime = BuildCandidateEvidence(snapshotUnit, tracked)

		-- If spell IDs were snapshotted in the window but none match a rule for this aura type,
		-- the candidate demonstrably cast something else - skip before MatchRule's duration check.
		-- On 12.0.5+ this only fires for "player"; pre-12.0.5 it applies to any recorded candidate.
		local knownSpellIds = GetKnownSpellIdsInWindow(
			tracked.CastSpellIdSnapshot, snapshotUnit, tracked.StartTime)
		if knownSpellIds then
			local specId = fcdTalents:GetUnitSpecId(snapshotUnit)
			local anyMatch = false
			for _, sid in ipairs(knownSpellIds) do
				if FindRuleBySpellId(snapshotUnit, specId, tracked.AuraTypes, sid) then
					anyMatch = true; break
				end
			end
			if not anyMatch then return end
		end

		-- Use snapshotUnit for talent/class-based lookup: when the candidate is a local player
		-- alias (e.g. "raid2"), snapshotUnit ("player") carries the correct spec.
		local candidateRule = MatchRule(
			snapshotUnit, tracked.AuraTypes, measuredDuration,
			{ Evidence = candidateEvidence, ActiveCooldowns = entry.ActiveCooldowns,
			  KnownSpellIds = knownSpellIds, IgnoreTalentRequirements = ignoreTalentReqs }
		)
		if not candidateRule then return end

		-- For non-EXT auras, a non-target candidate is only relevant as a CastableOnOthers caster
		-- (e.g. Paladin casting BoF on party2).  Self-only rules (e.g. Hunter's Aspect of the Turtle)
		-- on non-target candidates would create false ambiguity with a legitimate CastableOnOthers
		-- match, so they are skipped here.  This mirrors PredictRule's castableFilter="only" for
		-- the cross-unit candidate loop.
		if not isExternal and not isTarget and not candidateRule.CastableOnOthers then return end

		-- EXT non-target: skip the local player when they have no cast snapshot.
		-- UNIT_SPELLCAST_SUCCEEDED still fires for "player" in 12.0.5, so an empty snapshot
		-- proves the player cast nothing in the window.  Without this guard, a local Druid
		-- (no cast) would match Ironbark (no RequiresEvidence) and create false attributions
		-- or ambiguity with the Monk self-cast fallback.
		if isExternal and not isTarget and snapshotUnit == "player" and not castTime then return end

		-- An EXT rule marked SelfCastable=false (e.g. BoS) cannot be self-cast.  Block self-
		-- attribution so the match falls through to the correct non-target caster.  Skipped on
		-- the enemy-tracking path where self-cast is the only attribution available.
		if isTarget and candidateRule.SelfCastable == false and not ignoreTalentReqs then return end

		local betterByTime = castTime ~= nil and (bestTime == nil or castTime > bestTime)
		-- A non-target matching a DIFFERENT CastableOnOthers rule (e.g. DK's AMS) beats a
		-- target self-matching a CastableOnOthers rule (e.g. Paladin self-matching BoF).
		-- Guard: do NOT let a no-evidence rule displace an evidence-constrained match via
		-- betterCOO.  When the existing rule requires evidence (e.g. Spellwarding AMS) and
		-- the new one does not (e.g. BoF), evidence takes priority and the elseif branch
		-- handles it correctly.  betterCOO still fires when evidence favours the new rule
		-- (existing has none, new has some) or when both sides are equivalent.
		local betterCOO    = not castTime and not bestTime
			and not isExternal and not isTarget and bestIsTarget
			and rule.CastableOnOthers and candidateRule ~= rule
			and not (rule.RequiresEvidence ~= nil and candidateRule.RequiresEvidence == nil)
		if not rule or betterByTime or betterCOO then
			rule, ruleUnit, bestTime, bestIsTarget = candidateRule, candidate, castTime, isTarget
		elseif not castTime and not bestTime then
			-- Two candidates with no real cast evidence.  Same SpellId -> keep first (committed
			-- cooldown is identical regardless of attribution, mirrors PredictRule's tiebreaker).
			-- Different SpellId: normally ambiguous, but when one rule has RequiresEvidence and the
			-- other does not, prefer the evidence-constrained match.  This prevents BoF (no evidence
			-- requirement) from creating false ambiguity with AMS (Shield required): if DK matched
			-- AMS first and Paladin matches BoF, BoF is spurious.  Works symmetrically: if BoF
			-- matched first and then AMS is evaluated, AMS replaces BoF (betterEvidence path).
			local sameSpell = rule.SpellId ~= nil and candidateRule.SpellId == rule.SpellId
			if not sameSpell then
				-- For non-EXT: prefer evidence-constrained rules over no-evidence rules.
				-- This prevents BoF (no RequiresEvidence) from creating false ambiguity with
				-- AMS Spellwarding (RequiresEvidence="Shield").  Symmetric: whichever is evaluated
				-- first, the evidence-constrained rule wins.
				-- For EXT: both candidates represent distinct spells that may genuinely coexist
				-- (e.g. Ironbark and BoS), so always treat them as ambiguous.
				if not isExternal then
					local ruleHasEvidence = rule.RequiresEvidence ~= nil
					local newHasEvidence  = candidateRule.RequiresEvidence ~= nil
					if ruleHasEvidence == newHasEvidence then
						-- Both constrained or both unconstrained: genuinely ambiguous.
						ambiguous = true
					elseif newHasEvidence then
						-- New candidate has evidence-constrained match; replace.
						rule, ruleUnit, bestTime, bestIsTarget = candidateRule, candidate, castTime, isTarget
					end
					-- else: existing rule has evidence constraint, new doesn't; keep existing.
				else
					ambiguous = true
				end
			end
		end
	end

	local function searchExternal()
		-- Non-target candidates first; target is excluded here so the self-cast fallback below
		-- can evaluate it with isTarget=true.  GUIDs deduplicate multi-ID players.
		local seenUnits = {}
		for _, unit in ipairs(candidateUnits) do
			if AddIfUnseen(seenUnits, unit) and unit ~= entry.Unit then
				consider(unit, false)
			end
		end
		-- Self-cast fallback: target may be both caster and recipient (Disc Priest self-casting PS,
		-- Ret Paladin self-casting BoP, Monk self-casting Life Cocoon).  Also fires when bestTime
		-- is nil (no real cast evidence) to catch e.g. Monk vs Paladin BoS when both lack a snapshot.
		-- For the local player as target: skip when they provably cast no EXT spell (the buff came
		-- from a non-target), to avoid false self-attribution.
		if (not rule or bestTime == nil) and not ambiguous then
			local skipFallback = entry.Unit == "player"
				and not PlayerHasExtCastInWindow(tracked.CastSpellIdSnapshot, tracked.StartTime, tracked.AuraTypes)
			if not skipFallback then consider(entry.Unit, true) end
		end
	end

	local function searchNonExternal()
		-- Aura has the IMPORTANT+UnitFlags+pvp signature of Precognition.  Suppress the
		-- entire commit so no cooldown is falsely recorded.  Real BoF does not produce
		-- UnitFlags evidence (tested), so this only fires for Precognition.
		if IsProbablyPrecognition(tracked.AuraTypes, entry.Unit, measuredDuration, tracked.Evidence or {}) then return end
		if IsProbablyGroundingTotem(tracked.AuraTypes, entry.Unit, candidateUnits, measuredDuration, tracked.Evidence, tracked.CastSpellIdSnapshot, tracked.StartTime) then return end
		consider(entry.Unit, true)
		-- Skip the cross-unit loop when the target already matched a non-CastableOnOthers rule:
		-- self-only rules (e.g. Barkskin, Ice Block) on non-target candidates cannot be the source.
		if not rule or rule.CastableOnOthers then
			local seenUnits = {}
			AddIfUnseen(seenUnits, entry.Unit)
			for _, unit in ipairs(candidateUnits) do
				if AddIfUnseen(seenUnits, unit) then consider(unit, false) end
			end
		end
	end

	if isExternal then searchExternal() else searchNonExternal() end

	if ambiguous then return nil, nil end
	return rule, ruleUnit
end

---Fires the cooldown callback so Module can store the cooldown and update all affected entries.
local function CommitCooldown(entry, tracked, rule, ruleUnit, measuredDuration)
	if not cooldownCallback then
		return
	end

	-- Apply talent-based cooldown reduction and look up max charges.
	local cooldown = rule.Cooldown
	local maxCharges = nil
	if rule.SpellId then
		local specId = fcdTalents:GetUnitSpecId(ruleUnit)
		local _, classToken = UnitClass(ruleUnit)
		if classToken then
			cooldown =
				fcdTalents:GetUnitCooldown(ruleUnit, specId, classToken, rule.SpellId, cooldown, measuredDuration)
			local ruleBaseCharges = rule.BaseCharges or 1
			if (rule.MaxCharges or ruleBaseCharges) > 1 then
				local charges = fcdTalents:GetUnitMaxCharges(ruleUnit, specId, classToken, rule.SpellId)
				-- Use the higher of: talent-computed charges (starts at 1 + talent bonuses) and
				-- the rule's BaseCharges (for spells that inherently have >1 charge with no talent).
				maxCharges = math.max(ruleBaseCharges, charges)
			end
		end
	end

	local auraTypesKey = tracked.AuraTypes["BIG_DEFENSIVE"] and "BIG_DEFENSIVE"
		or tracked.AuraTypes["EXTERNAL_DEFENSIVE"] and "EXTERNAL_DEFENSIVE"
		or "IMPORTANT"
	local cdKey = rule.SpellId or (auraTypesKey .. "_" .. rule.BuffDuration .. "_" .. rule.Cooldown)
	local cdData = {
		StartTime = tracked.StartTime,
		Cooldown = cooldown,
		Remaining = cooldown - measuredDuration,
		SpellId = tracked.SpellId,
		IsOffensive = rule.SpellId ~= nil and rules.OffensiveSpellIds[rule.SpellId] == true,
		MaxCharges = maxCharges,
	}

	cooldownCallback(ruleUnit, cdKey, cdData, entry)
end

---Called when a tracked aura instance disappears.
---Measures elapsed time and starts a cooldown entry if a rule matches.
---@param entry FcdWatchEntry
---@param tracked FcdTrackedAura
---@param now number
---@param candidateUnits string[]
---Returns true if a cooldown was committed, false if no rule matched.
local function OnAuraRemoved(entry, tracked, now, candidateUnits)
	local measuredDuration = now - tracked.StartTime
	local rule, ruleUnit = FindBestCandidate(entry, tracked, measuredDuration, candidateUnits)

	if not rule then
		return false
	end

	CommitCooldown(entry, tracked, rule, ruleUnit, measuredDuration)
	return true
end

---Builds a table of current aura instance IDs -> { AuraTypes } from the watcher.
---GetDefensiveState doesn't expose which filter each aura came from, so each aura is
---re-checked via IsAuraFilteredOutByInstanceID to classify EXTERNAL_DEFENSIVE vs BIG_DEFENSIVE.
---CROWD_CONTROL is also probed: spells like Dispersion are both BIG_DEFENSIVE and CC,
---which lets rules use CrowdControl=true to distinguish them from non-CC BIG spells.
---Both HARMFUL|CROWD_CONTROL (hostile CCs like Dispersion on self) and HELPFUL|CROWD_CONTROL
---(friendly CCs like Time Stop applied to an ally) are checked.
local function BuildCurrentAuraIds(unit, watcher)
	local currentIds = {}
	local function applyCC(id, auraTypes)
		local isHarmful = not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, id, "HARMFUL|CROWD_CONTROL")
		local isHelpful = not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, id, "HELPFUL|CROWD_CONTROL")
		if isHarmful or isHelpful then
			auraTypes["CROWD_CONTROL"] = true
			if isHarmful then auraTypes["CC_HARMFUL"] = true end
			if isHelpful then auraTypes["CC_HELPFUL"] = true end
		end
	end
	for _, aura in ipairs(watcher:GetDefensiveState()) do
		local id = aura.AuraInstanceID
		if id then
			local isExt = not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, id, "HELPFUL|EXTERNAL_DEFENSIVE")
			local isImportant = not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, id, "HELPFUL|IMPORTANT")
			local auraType = isExt and "EXTERNAL_DEFENSIVE" or "BIG_DEFENSIVE"
			local auraTypes = { [auraType] = true }
			if isImportant then auraTypes["IMPORTANT"] = true end
			applyCC(id, auraTypes)
			currentIds[id] = { AuraTypes = auraTypes, DurationObject = aura.DurationObject }
		end
	end
	-- Auras already added from GetDefensiveState are excluded from GetImportantState by the
	-- watcher's seen-set; IMPORTANT was already probed above via IsAuraFilteredOutByInstanceID.
	for _, aura in ipairs(watcher:GetImportantState()) do
		local id = aura.AuraInstanceID
		if id then
			if currentIds[id] then
				currentIds[id].AuraTypes["IMPORTANT"] = true
			else
				local auraTypes = { IMPORTANT = true }
				applyCC(id, auraTypes)
				currentIds[id] = { AuraTypes = auraTypes, DurationObject = aura.DurationObject }
			end
		end
	end
	return currentIds
end

---Begins tracking a newly detected aura: records evidence and a cast snapshot,
---then schedules a deferred backfill for events that may arrive after UNIT_AURA.
local function TrackNewAura(entry, trackedAuras, id, info, now, candidateUnits)
	local unit = entry.Unit

	-- candidateUnits is a shared scratch table in Observer that is reused on every aura event.
	-- Copy it now so the deferred timer closure has a stable snapshot of the current candidates.
	local candidatesCopy = {}
	for i = 1, #candidateUnits do
		candidatesCopy[i] = candidateUnits[i]
	end
	candidateUnits = candidatesCopy

	-- Collect concurrent Debuff/Shield/UnitFlags evidence (HARMFUL auras fire in the same
	-- UNIT_AURA batch). Cast evidence is intentionally excluded here - it is derived
	-- per-candidate from CastSnapshot in OnAuraRemoved so a cast by unit A cannot satisfy
	-- RequiresEvidence="Cast" when evaluating unit B.
	local evidence = BuildEvidenceSet(unit, now)

	-- Snapshot cast times so OnAuraRemoved can attribute the cooldown to the correct
	-- caster even after lastCastTime has been overwritten by subsequent casts.
	local castSnapshot = {}
	for snapshotUnit, snapshotTime in pairs(lastCastTime) do
		castSnapshot[snapshotUnit] = snapshotTime
	end

	-- Snapshot non-secret cast spell IDs (local player only).  Used by PredictRule as a
	-- definitive signal when the player's own UNIT_SPELLCAST_SUCCEEDED is available.
	-- Stored as a list per unit so all events from a single keypress are captured.
	local castSpellIdSnapshot = {}
	for snapshotUnit, list in pairs(lastCastSpellIds) do
		local filtered = {}
		for _, data in ipairs(list) do
			if math.abs(data.Time - now) <= castWindow then
				filtered[#filtered + 1] = data
			end
		end
		if #filtered > 0 then
			castSpellIdSnapshot[snapshotUnit] = filtered
		end
	end

	trackedAuras[id] = {
		StartTime = now,
		AuraTypes = info.AuraTypes,
		Evidence = evidence,
		CastSnapshot = castSnapshot,
		CastSpellIdSnapshot = castSpellIdSnapshot,
		DurationObject = info.DurationObject,
	}
	-- Deferred backfill: UNIT_SPELLCAST_SUCCEEDED and UNIT_ABSORB_AMOUNT_CHANGED can arrive
	-- slightly after UNIT_AURA. Augment Evidence and CastSnapshot once the window elapses.
	C_Timer.After(evidenceTolerance, function()
		local tracked = trackedAuras[id]
		if not tracked then
			return
		end
		local ev = BuildEvidenceSet(unit, now)
		if ev then
			tracked.Evidence = tracked.Evidence or {}
			for k in pairs(ev) do
				tracked.Evidence[k] = true
			end
		end
		-- Backfill casters whose UNIT_SPELLCAST_SUCCEEDED arrived after UNIT_AURA.
		-- Guard with castWindow to avoid picking up unrelated later casts.
		for snapshotUnit, snapshotTime in pairs(lastCastTime) do
			if math.abs(snapshotTime - now) <= castWindow and not tracked.CastSnapshot[snapshotUnit] then
				tracked.CastSnapshot[snapshotUnit] = snapshotTime
			end
		end
		-- Backfill non-secret cast spell IDs that arrived after UNIT_AURA.
		for snapshotUnit, list in pairs(lastCastSpellIds) do
			for _, data in ipairs(list) do
				if math.abs(data.Time - now) <= castWindow then
					local existing = tracked.CastSpellIdSnapshot[snapshotUnit]
					if not existing then
						tracked.CastSpellIdSnapshot[snapshotUnit] = { data }
					else
						local found = false
						for _, e in ipairs(existing) do
							if e.SpellId == data.SpellId and e.Time == data.Time then found = true; break end
						end
						if not found then existing[#existing + 1] = data end
					end
				end
			end
		end

		-- Predictive glow: identify the spell by aura type + talent + evidence.
		-- For EXTERNAL_DEFENSIVE, searches candidateUnits for the caster via cast snapshot.
		if not tracked.PredictedSpellId then
			local spellId, casterUnit = PredictRule(unit, info.AuraTypes, tracked.Evidence, tracked.CastSnapshot, tracked.CastSpellIdSnapshot, now, candidateUnits)
			if spellId and predictiveGlowCallback then
				tracked.PredictedSpellId = spellId
				tracked.PredictedCasterUnit = casterUnit
				predictiveGlowCallback(entry, spellId, casterUnit, tracked.DurationObject)
			end
		end
	end)
end

---Processes a watcher state change for an entry. Called via the Observer's aura-changed callback.
---entry.IsExcludedSelf: set by Module; when true, bypasses the container-visibility guard so
---  externals cast by the player are still captured even though the container is hidden.
---candidateUnits: supplied by Observer from its internal watched-entry map.
---@param entry FcdWatchEntry
---@param watcher Watcher
---@param candidateUnits string[]
local function OnWatcherChanged(entry, watcher, candidateUnits)
	if not entry.IsExcludedSelf and not entry.Container.Frame:IsVisible() then
		return
	end

	local now = GetTime()
	local trackedAuras = entry.TrackedAuras
	local currentIds = BuildCurrentAuraIds(entry.Unit, watcher)

	-- Collect new IDs (present in currentIds but not yet tracked) for heuristic reconciliation.
	-- On full updates the server reassigns aura instance IDs, so a tracked ID disappearing does
	-- not necessarily mean the buff dropped. We match orphaned entries to new IDs by AuraTypes
	-- signature - the only non-secret identity information available to us.
	local unmatchedNewIds = {}
	for id in pairs(currentIds) do
		if not trackedAuras[id] then
			unmatchedNewIds[#unmatchedNewIds + 1] = id
		end
	end

	-- Group unmatched new IDs by their AuraTypes signature.
	local newIdsBySignature = {}
	for _, id in ipairs(unmatchedNewIds) do
		local sig = AuraTypesSignature(currentIds[id].AuraTypes)
		newIdsBySignature[sig] = newIdsBySignature[sig] or {}
		newIdsBySignature[sig][#newIdsBySignature[sig] + 1] = id
	end

	local cooldownCommitted = false
	for id, tracked in pairs(trackedAuras) do
		if not currentIds[id] then
			local sig = AuraTypesSignature(tracked.AuraTypes)
			local candidates = newIdsBySignature[sig]
			if candidates and #candidates > 0 then
				-- Carry tracking forward under the new instance ID.
				local reassignedId = table.remove(candidates, 1)
				trackedAuras[reassignedId] = tracked
			else
				-- Fire glow-end before OnAuraRemoved so that when UpdateDisplay runs the glow is already cleared.
				if tracked.PredictedSpellId and predictiveGlowEndCallback then
					predictiveGlowEndCallback(entry, tracked.PredictedSpellId, tracked.PredictedCasterUnit)
				end
				if OnAuraRemoved(entry, tracked, now, candidateUnits) then
					cooldownCommitted = true
				end
			end
			trackedAuras[id] = nil
		elseif tracked.PredictedSpellId and predictiveGlowDurationChangedCallback then
			-- Aura is still active: refresh DurationObject so the glow icon tracks any
			-- duration extensions (e.g. Combustion extended by talents, Avatar by procs).
			local newDuration = currentIds[id].DurationObject
			if newDuration then
				tracked.DurationObject = newDuration
				predictiveGlowDurationChangedCallback(entry, tracked.PredictedSpellId, tracked.PredictedCasterUnit, newDuration)
			end
		end
	end

	for id, info in pairs(currentIds) do
		if not trackedAuras[id] then
			TrackNewAura(entry, trackedAuras, id, info, now, candidateUnits)
		end
	end

	-- Only update the detected entry's display when a cooldown was actually committed.
	-- The caster entry is updated immediately in the cooldownCallback; this covers the
	-- case where the detected entry differs from the caster entry (e.g. external defensives).
	if displayCallback and cooldownCommitted then
		displayCallback(entry)
	end
end

local function RecordCast(unit, spellId)
	-- In 12.0.5+ the local player can appear under a raid/party alias (e.g. "raid1").
	-- Resolve to "player" via GUID so cast evidence is always stored under the canonical key.
	local effectiveUnit = ResolveSnapshotUnit(unit)
	if effectiveUnit ~= "player" then return end
	local now = GetTime()
	if lastCastTime[effectiveUnit] ~= now then
		lastCastTime[effectiveUnit] = now
	end
	-- Also record under the alias so BuildEvidenceSet keyed by the alias finds Cast evidence.
	if unit ~= effectiveUnit and lastCastTime[unit] ~= now then
		lastCastTime[unit] = now
	end
	-- Store the spell ID only when non-secret (i.e. the local player).  Remote players'
	-- UNIT_SPELLCAST_SUCCEEDED spell IDs are secret values that cannot be used for matching.
	-- Appended to a list (rather than overwriting) because one keypress can fire multiple events.
	if spellId and not issecretvalue(spellId) then
		local list = lastCastSpellIds[effectiveUnit]
		if not list then
			list = {}
			lastCastSpellIds[effectiveUnit] = list
		end
		list[#list + 1] = { SpellId = spellId, Time = now }
		-- Prune entries outside the cast window to bound list size.
		local cutoff = now - castWindow
		local keep = 1
		for i = 1, #list do
			if list[i].Time >= cutoff then
				if i ~= keep then list[keep] = list[i] end
				keep = keep + 1
			end
		end
		for i = keep, #list do list[i] = nil end
	end
end

local function RecordShield(unit)
	lastShieldTime[unit] = GetTime()
end

local function RecordUnitFlagsChange(unit)
	local now = GetTime()
	-- Populate canFeign lazily: only Hunters can feign death, so skip UnitIsFeignDeath for
	-- every other class. UNIT_FLAGS fires frequently in raids for mundane combat-state changes
	-- and calling UnitIsFeignDeath for 19 non-Hunter players on each event is wasted work.
	local canFeign = unitCanFeign[unit]
	if canFeign == nil then
		local _, classToken = UnitClass(unit)
		canFeign = classToken == "HUNTER"
		unitCanFeign[unit] = canFeign
	end
	local isFeign = canFeign and UnitIsFeignDeath(unit) or false
	if isFeign and not lastFeignDeathState[unit] then
		lastFeignDeathTime[unit] = now
	end
	lastFeignDeathState[unit] = isFeign
	if not isFeign then
		lastUnitFlagsTime[unit] = now
	end
end

local function TryRecordDebuffEvidence(unit, updateInfo)
	if updateInfo and not updateInfo.isFullUpdate and updateInfo.addedAuras then
		for _, aura in ipairs(updateInfo.addedAuras) do
			if
				aura.auraInstanceID
				and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HARMFUL")
			then
				lastDebuffTime[unit] = GetTime()
				break
			end
		end
	end
end

---Registers the callback fired when a buff ends and a cooldown rule is matched.
---fn(ruleUnit, cdKey, cdData, detectedFromEntry)
---cdData: { StartTime, Cooldown, Remaining, SpellId, IsOffensive }
---@param fn fun(ruleUnit: string, cdKey: number|string, cdData: table, detectedFromEntry: FcdWatchEntry)
function B:RegisterCooldownCallback(fn)
	cooldownCallback = fn
end

---Registers the callback fired when the display should update after a watcher pass.
---fn(entry)
---@param fn fun(entry: FcdWatchEntry)
function B:RegisterDisplayCallback(fn)
	displayCallback = fn
end

---Registers a lookup function that returns the ActiveCooldowns table for a given unit.
---Used by PredictSpellIdForUnit to skip rules whose spell is already on cooldown.
---@param fn fun(unit: string): table?
function B:RegisterActiveCooldownsLookup(fn)
	activeCooldownsLookup = fn
end

---Registers the callback fired when a new aura is matched to a predicted spell.
---entry is the detecting (target) entry. casterUnit is the predicted caster unit string,
---or nil when the caster is the target unit itself (self-cast auras).
---durationObject is the aura's DurationObject at detection time, for driving the countdown display.
---fn(entry, spellId, casterUnit, durationObject)
---@param fn fun(entry: FcdWatchEntry, spellId: number, casterUnit: string?, durationObject: table?)
function B:RegisterPredictiveGlowCallback(fn)
	predictiveGlowCallback = fn
end

---Registers the callback fired when a predictively-matched aura is removed.
---Mirrors RegisterPredictiveGlowCallback - casterUnit is nil for self-cast auras.
---fn(entry, spellId, casterUnit)
---@param fn fun(entry: FcdWatchEntry, spellId: number, casterUnit: string?)
function B:RegisterPredictiveGlowEndCallback(fn)
	predictiveGlowEndCallback = fn
end

---Registers the callback fired when an active predicted-glow aura's duration changes.
---Fired on every UNIT_AURA update while the glow is live, so callers should be cheap.
---fn(entry, spellId, casterUnit, durationObject)
---@param fn fun(entry: FcdWatchEntry, spellId: number, casterUnit: string?, durationObject: table?)
function B:RegisterPredictiveGlowDurationChangedCallback(fn)
	predictiveGlowDurationChangedCallback = fn
end

-- Clears all per-unit timestamp state. Called by tests between cases so state
-- from one test cannot bleed into the next.
function B._TestReset()
	for k in pairs(lastDebuffTime)      do lastDebuffTime[k]      = nil end
	for k in pairs(lastShieldTime)      do lastShieldTime[k]      = nil end
	for k in pairs(lastCastTime)        do lastCastTime[k]        = nil end
	for k in pairs(lastCastSpellIds)    do lastCastSpellIds[k]    = nil end
	for k in pairs(lastUnitFlagsTime)   do lastUnitFlagsTime[k]   = nil end
	for k in pairs(lastFeignDeathTime)  do lastFeignDeathTime[k]  = nil end
	for k in pairs(lastFeignDeathState) do lastFeignDeathState[k] = nil end
	for k in pairs(unitCanFeign)        do unitCanFeign[k]        = nil end
end

---Wires Brain into an observer. Called by FriendlyCooldowns Module during Init.
---Brain has no direct observer dependency; the caller supplies whichever observer to use.
---@param obs FriendlyCooldownObserver
function B:RegisterWithObserver(obs)
	obs:RegisterAuraChangedCallback(function(entry, watcher, candidateUnits)
		OnWatcherChanged(entry, watcher, candidateUnits)
	end)
	obs:RegisterCastCallback(RecordCast)
	obs:RegisterShieldCallback(RecordShield)
	obs:RegisterUnitFlagsCallback(RecordUnitFlagsChange)
	obs:RegisterDebuffEvidenceCallback(TryRecordDebuffEvidence)
end

-- Public API used by EnemyCooldowns module to share rule-matching logic.

---Matches a rule for the given unit using duration + evidence + talent checks.
---@param unit string
---@param auraTypes table<string,boolean>
---@param measuredDuration number
---@param context MatchRuleContext?
---@return table?
function B:MatchRule(unit, auraTypes, measuredDuration, context)
	return MatchRule(unit, auraTypes, measuredDuration, context)
end

---Finds the best-matching rule and caster unit for a tracked aura removal.
---entry must have Unit (string) and ActiveCooldowns (table) fields.
---tracked must have AuraTypes, Evidence?, StartTime, CastSnapshot (table<string,number>), and optionally CastSpellIdSnapshot.
---candidateUnits lists units to check as casters in addition to entry.Unit (always checked first).
---opts.IgnoreTalentRequirements skips RequiresTalent checks (e.g. for enemies where talent data is unavailable).
---@param entry table  { Unit: string, ActiveCooldowns: table }
---@param tracked table  { AuraTypes, Evidence?, StartTime, CastSnapshot, CastSpellIdSnapshot? }
---@param measuredDuration number
---@param candidateUnits string[]
---@param opts table?  { IgnoreTalentRequirements: boolean? }
---@return table? rule
---@return string ruleUnit
function B:FindBestCandidate(entry, tracked, measuredDuration, candidateUnits, opts)
	return FindBestCandidate(entry, tracked, measuredDuration, candidateUnits, opts)
end

---Predicts the first matching spell ID for a unit given aura types and evidence.
---Does NOT consult the module-level activeCooldownsLookup; pass activeCooldowns directly.
---@param unit string
---@param auraTypes table<string,boolean>
---@param evidence EvidenceSet?
---@param activeCooldowns table?  active cooldowns keyed by SpellId; nil = no cooldown filter
---@return number? spellId
---@return boolean isOnCooldown
function B:PredictSpellId(unit, auraTypes, evidence, activeCooldowns)
	local _, classToken = UnitClass(unit)
	if not classToken then return nil, false end

	local specId = fcdTalents:GetUnitSpecId(unit)

	local function tryRuleList(ruleList)
		if not ruleList then return nil, false end
		for _, rule in ipairs(ruleList) do
			if rule.SpellId and RulePassesTalentGates(rule, unit, specId, nil) then
				if AuraTypeMatchesRule(auraTypes, rule) and EvidenceMatchesReq(rule.RequiresEvidence, evidence) then
					return rule.SpellId, IsSpellOnCooldown(activeCooldowns, rule.SpellId)
				end
			end
		end
		return nil, false
	end

	local spellId, onCd = tryRuleList(specId and rules.BySpec[specId])
	if spellId ~= nil then return spellId, onCd end
	return tryRuleList(rules.ByClass[classToken])
end
