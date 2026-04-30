local addonName, DF = ...

-- ============================================================
-- OUT OF RANGE ALPHA SYSTEM
-- Fades frames/elements when party members are out of range
--
-- RANGE CHECK STRATEGY (matches Grid2's proven approach):
-- 1. Player → always in range
-- 2. Phased units → always out of range (UnitPhaseReason)
-- 3. Hostile → IsSpellInRange(hostileSpell)
-- 4. Dead friendly → IsSpellInRange(rezSpell)
-- 5. Friendly with spell → IsSpellInRange(friendlySpell)
--    OR CheckInteractDistance out of combat
-- 6. No friendly spell → CheckInteractDistance out of combat,
--    UnitInRange() in combat, default in-range as last resort
--
-- IsSpellInRange returns normal booleans - NOT secret values.
-- We trust the result directly (== true) like Grid2 does.
-- UnitInRange() may return secret values so we still guard that.
--
-- DEBUG: /dfrange debug  - toggle debug output
--        /dfrange stats  - show cache statistics
--        /dfrange clear  - clear cache
--        /dfrange spell  - show current range spell
-- ============================================================

-- Upvalue frequently used globals
local pairs = pairs
local wipe = wipe
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitCanAttack = UnitCanAttack
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsPlayerSpell = IsPlayerSpell
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local CheckInteractDistance = CheckInteractDistance
local C_Spell = C_Spell
local C_Spell_IsSpellInRange = C_Spell.IsSpellInRange
local C_Spell_GetSpellName = C_Spell.GetSpellName
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsConnected = UnitIsConnected
local UnitInRange = UnitInRange
local issecretvalue = issecretvalue  -- nil pre-Midnight, function in Midnight+
local UnitPhaseReason = UnitPhaseReason

-- Player info
local _, playerClass = UnitClass("player")

-- ============================================================
-- SPEC-BASED RANGE SPELLS
-- Indexed by specID - validated with IsPlayerSpell() before use
-- Format: { friendly = spellID, hostile = spellID, range = "description" }
-- ============================================================

local specSpells = {
    -- ==================== DEATH KNIGHT ====================
    -- Death Coil (47541) can only heal undead minions, NOT friendly players.
    -- IsSpellInRange returns nil on player targets → no friendly spell available.
    -- Range falls back to CheckInteractDistance (OOC) or UnitInRange (combat).
    [250] = { -- Blood
        friendly = nil,
        hostile = 47541,    -- Death Coil
        range = "40yd"
    },
    [251] = { -- Frost
        friendly = nil,
        hostile = 47541,
        range = "40yd"
    },
    [252] = { -- Unholy
        friendly = nil,
        hostile = 47541,
        range = "40yd"
    },
    
    -- ==================== DEMON HUNTER ====================
    [577] = { -- Havoc
        friendly = nil,
        hostile = 185123,   -- Throw Glaive
        range = "30yd"
    },
    [581] = { -- Vengeance
        friendly = nil,
        hostile = 185123,
        range = "30yd"
    },
    -- Devourer (new Midnight spec - ranged DPS, 25yd, Intellect-based)
    -- specID TBD - using placeholder, will need update when known
    [1456] = { -- Devourer (specID placeholder - update when known)
        friendly = nil,
        hostile = 452416,   -- Consume (25yd Void spell) - spellID may need update
        range = "25yd"
    },
    
    -- ==================== DRUID ====================
    [102] = { -- Balance
        friendly = 8936,    -- Regrowth (all druids have it in class tree)
        hostile = 8921,     -- Moonfire
        range = "40yd"
    },
    [103] = { -- Feral
        friendly = 8936,    -- Regrowth
        hostile = 8921,
        range = "40yd"
    },
    [104] = { -- Guardian
        friendly = 8936,    -- Regrowth
        hostile = 8921,
        range = "40yd"
    },
    [105] = { -- Restoration
        friendly = 774,     -- Rejuvenation (instant cast, better for healers)
        hostile = 8921,
        range = "40yd"
    },
    
    -- ==================== EVOKER ====================
    [1467] = { -- Devastation
        friendly = 355913,  -- Emerald Blossom (all evokers have this)
        hostile = 361469,   -- Living Flame
        range = "25yd"
    },
    [1468] = { -- Preservation
        friendly = 355913,  -- Emerald Blossom
        hostile = 361469,
        range = "25yd"      -- Note: Evoker has shorter range!
    },
    [1473] = { -- Augmentation
        friendly = 355913,  -- Emerald Blossom
        hostile = 361469,
        range = "25yd"
    },
    
    -- ==================== HUNTER ====================
    [253] = { -- Beast Mastery
        friendly = nil,
        hostile = 193455,   -- Cobra Shot
        range = "40yd"
    },
    [254] = { -- Marksmanship
        friendly = nil,
        hostile = 19434,    -- Aimed Shot
        range = "40yd"
    },
    [255] = { -- Survival
        friendly = nil,
        hostile = 259491,   -- Kill Command (ranged version)
        range = "40yd"
    },
    
    -- ==================== MAGE ====================
    [62] = { -- Arcane
        friendly = 1459,    -- Arcane Intellect
        hostile = 30451,    -- Arcane Blast
        range = "40yd"
    },
    [63] = { -- Fire
        friendly = 1459,
        hostile = 133,      -- Fireball
        range = "40yd"
    },
    [64] = { -- Frost
        friendly = 1459,
        hostile = 116,      -- Frostbolt
        range = "40yd"
    },
    
    -- ==================== MONK ====================
    [268] = { -- Brewmaster
        friendly = 116670,  -- Vivify (all monks)
        hostile = 115546,   -- Provoke
        range = "40yd"
    },
    [269] = { -- Windwalker
        friendly = 116670,
        hostile = 115546,
        range = "40yd"
    },
    [270] = { -- Mistweaver
        friendly = 116670,  -- Vivify
        hostile = 115546,
        range = "40yd"
    },
    
    -- ==================== PALADIN ====================
    [65] = { -- Holy
        friendly = 19750,   -- Flash of Light
        hostile = 62124,    -- Hand of Reckoning
        range = "40yd"
    },
    [66] = { -- Protection
        friendly = 19750,
        hostile = 62124,
        range = "40yd"
    },
    [70] = { -- Retribution
        friendly = 19750,
        hostile = 62124,
        range = "40yd"
    },
    
    -- ==================== PRIEST ====================
    [256] = { -- Discipline
        friendly = 17,      -- Power Word: Shield
        hostile = 585,      -- Smite
        range = "40yd"
    },
    [257] = { -- Holy
        friendly = 2061,    -- Flash Heal
        hostile = 585,
        range = "40yd"
    },
    [258] = { -- Shadow
        friendly = 17,      -- Power Word: Shield
        hostile = 585,
        range = "40yd"
    },
    
    -- ==================== ROGUE ====================
    [259] = { -- Assassination
        friendly = 36554,   -- Shadowstep (if talented)
        hostile = 36554,
        range = "25yd"
    },
    [260] = { -- Outlaw
        friendly = 36554,
        hostile = 185763,   -- Pistol Shot
        range = "20yd"
    },
    [261] = { -- Subtlety
        friendly = 36554,
        hostile = 36554,
        range = "25yd"
    },
    
    -- ==================== SHAMAN ====================
    [262] = { -- Elemental
        friendly = 8004,    -- Healing Surge (all shaman)
        hostile = 188196,   -- Lightning Bolt
        range = "40yd"
    },
    [263] = { -- Enhancement
        friendly = 8004,
        hostile = 188196,
        range = "40yd"
    },
    [264] = { -- Restoration
        friendly = 8004,    -- Healing Surge
        hostile = 188196,
        range = "40yd"
    },
    
    -- ==================== WARLOCK ====================
    [265] = { -- Affliction
        friendly = 20707,   -- Soulstone
        hostile = 686,      -- Shadow Bolt
        range = "40yd"
    },
    [266] = { -- Demonology
        friendly = 20707,
        hostile = 686,
        range = "40yd"
    },
    [267] = { -- Destruction
        friendly = 20707,
        hostile = 29722,    -- Incinerate
        range = "40yd"
    },
    
    -- ==================== WARRIOR ====================
    [71] = { -- Arms
        friendly = nil,
        hostile = 355,      -- Taunt
        range = "30yd"
    },
    [72] = { -- Fury
        friendly = nil,
        hostile = 355,
        range = "30yd"
    },
    [73] = { -- Protection
        friendly = nil,
        hostile = 355,
        range = "30yd"
    },
}

-- Class fallbacks (used if spec not detected or not in table)
local classFallbacks = {
    DEATHKNIGHT = { friendly = nil, hostile = 47541 },
    DEMONHUNTER = { friendly = nil, hostile = 185123 },
    DRUID       = { friendly = 8936, hostile = 8921 },  -- Regrowth (all druids have it)
    EVOKER      = { friendly = 355913, hostile = 361469 },  -- Emerald Blossom
    HUNTER      = { friendly = nil, hostile = 75 },  -- Auto Shot
    MAGE        = { friendly = 1459, hostile = 116 },
    MONK        = { friendly = 116670, hostile = 115546 },
    PALADIN     = { friendly = 19750, hostile = 62124 },
    PRIEST      = { friendly = 2061, hostile = 585 },
    ROGUE       = { friendly = nil, hostile = 36554 },
    SHAMAN      = { friendly = 8004, hostile = 188196 },
    WARLOCK     = { friendly = 20707, hostile = 686 },
    WARRIOR     = { friendly = nil, hostile = 355 },
}

-- ============================================================
-- REZ SPELL TABLE
-- Used for accurate range checking on dead targets.
-- When a friendly target is dead, IsSpellInRange with the healing
-- spell returns nil. We try the class rez spell to give healers
-- accurate rez-range feedback on corpses.
-- Classes without a rez spell (DH, Hunter, Mage, Rogue, Warrior)
-- will fall through to CheckInteractDistance or show as OOR.
-- ============================================================
local rezSpellByClass = {
    DRUID       = 20484,   -- Rebirth (combat rez - IsSpellInRange works regardless of cooldown)
    PRIEST      = 2006,    -- Resurrection
    PALADIN     = 7328,    -- Redemption
    SHAMAN      = 2008,    -- Ancestral Spirit
    MONK        = 115178,  -- Resuscitate
    DEATHKNIGHT = 61999,   -- Raise Ally
    WARLOCK     = 20707,   -- Soulstone
    EVOKER      = 361227,  -- Return
}

-- Resolved once at load time / spec change
local currentRezSpell = rezSpellByClass[playerClass] or nil

-- Current active spell (updated on spec change)
local currentFriendlySpell = nil
local currentHostileSpell = nil
local currentSpecID = nil

-- ============================================================
-- SPELL DETECTION & UPDATES
-- ============================================================

local function UpdateRangeSpell()
    local specIndex = GetSpecialization()
    local specID = specIndex and GetSpecializationInfo(specIndex) or nil
    currentSpecID = specID
    
    -- Check for user override in DB (check party first, then raid)
    local userSpellID = nil
    if DF.db then
        local partyDB = DF.db.party
        local raidDB = DF.db.raid
        -- Use party setting as the primary (both should be the same usually)
        if partyDB and partyDB.rangeCheckSpellID and partyDB.rangeCheckSpellID > 0 then
            userSpellID = partyDB.rangeCheckSpellID
        elseif raidDB and raidDB.rangeCheckSpellID and raidDB.rangeCheckSpellID > 0 then
            userSpellID = raidDB.rangeCheckSpellID
        end
    end
    
    if userSpellID and userSpellID > 0 then
        -- User has set a custom spell - validate it with IsPlayerSpell
        if IsPlayerSpell(userSpellID) then
            currentFriendlySpell = userSpellID
            currentHostileSpell = userSpellID
        else
            -- User spell not known (maybe changed spec/talents) - clear so auto-detect runs next call
            currentFriendlySpell = nil
            currentHostileSpell = nil
        end
        return
    end
    
    -- Try spec-specific spells (validated with IsPlayerSpell)
    if specID and specSpells[specID] then
        local spells = specSpells[specID]
        currentFriendlySpell = spells.friendly and IsPlayerSpell(spells.friendly) and spells.friendly or nil
        currentHostileSpell = spells.hostile and IsPlayerSpell(spells.hostile) and spells.hostile or nil
        if currentFriendlySpell or currentHostileSpell then
            return
        end
    end
    
    -- Fallback to class defaults (validated with IsPlayerSpell)
    if classFallbacks[playerClass] then
        local spells = classFallbacks[playerClass]
        currentFriendlySpell = spells.friendly and IsPlayerSpell(spells.friendly) and spells.friendly or nil
        currentHostileSpell = spells.hostile and IsPlayerSpell(spells.hostile) and spells.hostile or nil
        return
    end
    
    -- Ultimate fallback
    currentFriendlySpell = nil
    currentHostileSpell = nil
end

-- ============================================================
-- DEBUG SYSTEM
-- ============================================================

local debugEnabled = false
local debugStats = {
    checks = 0,
    cacheHits = 0,
    cacheMisses = 0,
    lastReset = time(),
}

local function DebugPrint(...)
    if debugEnabled then
        print("|cFF00FF00[DFRange]|r", ...)
    end
end

local function ResetStats()
    debugStats.checks = 0
    debugStats.cacheHits = 0
    debugStats.cacheMisses = 0
    debugStats.lastReset = time()
end

-- ============================================================
-- CHANGE DETECTION CACHE
-- ============================================================

local rangeCache = {}

-- OOR → in-range transition latch. Parallel non-secret cache: set true when
-- we observe a non-secret OOR result for a unit, cleared (with an aura
-- rescan) when we observe a non-secret in-range result. Survives stretches
-- of secret-boolean values (UnitInRange fallback in combat) which can't be
-- compared with `==` without raising "execution tainted" errors.
local wasOORCache = {}

local function ClearRangeCache()
    wipe(rangeCache)
    wipe(wasOORCache)
end

-- ============================================================
-- RANGE CHECK FUNCTION
-- Returns: inRange (boolean or secret boolean)
--   Spell-based checks return normal booleans (cacheable, fast).
--   UnitInRange fallback may return secret booleans (Midnight+)
--   which propagate through SetAlphaFromBoolean downstream.
--   Falls back to CheckInteractDistance when spells return nil.
-- ============================================================

local function CheckUnitRange(unit)
    if UnitIsUnit(unit, "player") then
        return true
    end

    if not UnitExists(unit) then
        return true
    end

    -- Phased units are always out of range (matches Grid2)
    -- UnitPhaseReason returns nil for same-phase, a number if phased
    if UnitPhaseReason and UnitPhaseReason(unit) then
        return false
    end

    -- Branch on UnitCanAttack (not UnitCanAssist) to handle cross-faction party members.
    -- In the open world, cross-faction group members may have UnitCanAssist=false
    -- but UnitCanAttack is also false (they're in your group). Using UnitCanAttack
    -- ensures they fall through to the friendly path.
    if UnitCanAttack("player", unit) then
        -- HOSTILE UNITS: IsSpellInRange returns clean booleans, trust directly
        if currentHostileSpell then
            local inRange = C_Spell_IsSpellInRange(currentHostileSpell, unit)
            if inRange ~= nil then
                return inRange
            end
        end
        -- No hostile spell or returned nil - assume in range
        return true
    end

    -- FRIENDLY UNITS (party/raid members)
    -- IsSpellInRange returns clean booleans - NOT secret values.
    -- We trust the result directly (== true/false) like Grid2 does.
    if currentFriendlySpell then
        local inRange = C_Spell_IsSpellInRange(currentFriendlySpell, unit)
        if inRange == true then
            return true
        elseif inRange == false then
            -- Spell says OOR; OR with CheckInteractDistance out of combat
            -- for leniency (avoids false OOR from spec/talent edge cases).
            -- Both Grid2 and LibRangeCheck gate this behind !InCombat.
            if not InCombatLockdown() and CheckInteractDistance(unit, 4) then
                return true
            end
            return false
        end
        -- inRange == nil: spell can't target this unit (dead, offline, etc.)
    end

    -- Dead target: try rez spell for accurate range on corpses
    if currentRezSpell and UnitIsDeadOrGhost(unit) then
        local inRange = C_Spell_IsSpellInRange(currentRezSpell, unit)
        if inRange ~= nil then
            return inRange
        end
    end

    -- No spell result available.
    -- Out of combat: CheckInteractDistance (~28yd follow distance)
    -- Both Grid2 and LibRangeCheck avoid CheckInteractDistance in combat.
    if not InCombatLockdown() then
        return CheckInteractDistance(unit, 4) and true or false
    end

    -- IN COMBAT FALLBACKS:

    -- UnitInRange as primary combat fallback (returns secret booleans in Midnight+)
    -- Secret booleans propagate through the pipeline:
    --   dfInRange → GetInRange → SetAlphaFromBoolean → SetAlpha
    -- This gives DK/DH/Hunter/Warrior actual range fading in combat,
    -- AND acts as a safety net when IsSpellInRange returns nil transiently.
    if UnitInRange then
        local inRange = UnitInRange(unit)
        if issecretvalue and issecretvalue(inRange) then
            return inRange  -- Secret boolean, handled by SetAlphaFromBoolean downstream
        end
        if inRange ~= nil then
            return inRange  -- Normal boolean
        end
    end

    -- If UnitInRange also failed (non-grouped unit, or API unavailable),
    -- and we had a friendly spell that returned nil on a living connected
    -- target, they're likely extremely far away — treat as out of range.
    if currentFriendlySpell and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
        DebugPrint("OOR-NIL", unit, "spell AND UnitInRange both failed on alive/connected target in combat")
        return false
    end

    -- No method available or inconclusive — assume in range.
    -- This matches Grid2's approach for classes without friendly spells
    -- in combat: "return InCombat or CheckInteractDistance(unit, 4)"
    -- which always returns true when in combat.
    return true
end

-- ============================================================
-- APPLY RANGE ALPHA TO A FRAME
-- ============================================================

function DF:UpdateRange(frame)
    if not frame or not frame.unit then return end
    
    if DF.PerfTest and not DF.PerfTest.enableRange then return end
    if DF.testMode or DF.raidTestMode then return end
    
    local unit = frame.unit

    -- Player is always in range — skip all checks and cache logic.
    -- dfInRange may hold a secret boolean from a previous UnitInRange
    -- fallback (Midnight+), so check issecretvalue before boolean-testing
    -- it — `not <secret>` raises "execution tainted" and spams errors.
    if UnitIsUnit(unit, "player") then
        local dfSecret = issecretvalue and issecretvalue(frame.dfInRange)
        if dfSecret or frame.dfInRange ~= true then
            frame.dfInRange = true
            if DF.UpdateRangeAppearance then
                DF:UpdateRangeAppearance(frame)
            end
        end
        return
    end

    if not IsInGroup() and not IsInRaid() then
        local dfSecret = issecretvalue and issecretvalue(frame.dfInRange)
        if dfSecret or frame.dfInRange ~= true then
            frame.dfInRange = true
            if DF.UpdateRangeAppearance then
                DF:UpdateRangeAppearance(frame)
            end
        end
        return
    end

    local inRange = CheckUnitRange(unit)
    
    debugStats.checks = debugStats.checks + 1
    
    -- Cache comparison: secret values (from UnitInRange fallback) can't be
    -- compared with == so we always update when secrets are involved.
    -- Spell-based results are normal booleans and cache efficiently.
    local cached = rangeCache[unit]
    local isSecret = issecretvalue and (issecretvalue(inRange) or issecretvalue(cached))
    if not isSecret and cached == inRange then
        debugStats.cacheHits = debugStats.cacheHits + 1
        DebugPrint("SKIP", unit, "cached:", tostring(cached))
        -- Still need to update THIS frame if it hasn't been initialized
        -- (multiple frames can share the same unit, e.g. pinned frames)
        local dfSecret = issecretvalue and issecretvalue(frame.dfInRange)
        if dfSecret or frame.dfInRange ~= inRange then
            frame.dfInRange = inRange
            if DF.UpdateRangeAppearance then
                DF:UpdateRangeAppearance(frame)
            end
        end
        return
    end

    debugStats.cacheMisses = debugStats.cacheMisses + 1
    rangeCache[unit] = inRange
    DebugPrint("UPDATE", unit, "was:", tostring(cached), "now:", tostring(inRange))

    frame.dfInRange = inRange

    if DF.UpdateRangeAppearance then
        DF:UpdateRangeAppearance(frame)
    end

    -- OOR → in-range: rescan the aura cache. While a unit is OOR the
    -- cache freezes (ScanUnitFull's OOR guard preserves stale data on
    -- purpose since the API returns nothing for OOR units), so any
    -- auras that expired during the OOR window stay in the cache and
    -- render as stuck buff icons until /reload. Force a full rescan
    -- now that we can read the unit's auras again.
    --
    -- Use the wasOORCache latch instead of comparing `cached`/`inRange`
    -- directly: those values may be secret booleans (UnitInRange fallback
    -- in combat) and `==` against a secret raises "execution tainted".
    -- The latch is set on any non-secret OOR observation and consumed on
    -- the next non-secret in-range one, so the rescan still fires across
    -- a stretch of secret-only updates.
    local nowOOR     = (not isSecret) and inRange == false
    local nowInRange = (not isSecret) and inRange == true
    if nowInRange and wasOORCache[unit] then
        wasOORCache[unit] = nil
        if DF.ScanUnitFull then DF:ScanUnitFull(unit) end
        if DF.TriggerAuraUpdateForUnit then DF:TriggerAuraUpdateForUnit(unit) end
    elseif nowOOR then
        wasOORCache[unit] = true
    end
end

-- ============================================================
-- PET FRAME RANGE UPDATES
-- ============================================================

function DF:UpdatePetRange(frame)
    if not frame or not frame.unit then return end
    if not UnitExists(frame.unit) then return end
    
    local db = DF:GetFrameDB(frame)
    if not db then return end
    
    local ownerUnit = frame.ownerUnit
    if not ownerUnit then return end
    
    local inRange = true
    if UnitExists(ownerUnit) and not UnitIsUnit(ownerUnit, "player") then
        if IsInGroup() or IsInRaid() then
            inRange = CheckUnitRange(ownerUnit)
        end
    end
    
    local cacheKey = "pet_" .. frame.unit
    local cached = rangeCache[cacheKey]
    local isSecret = issecretvalue and (issecretvalue(inRange) or issecretvalue(cached))
    if not isSecret and cached == inRange then
        return
    end
    rangeCache[cacheKey] = inRange

    frame.dfInRange = inRange

    local outOfRangeAlpha = db.rangeFadeAlpha or 0.55
    -- Use SetAlphaFromBoolean when available to handle secret booleans
    -- from UnitInRange (Midnight+ returns secret values for non-healer specs)
    if frame.SetAlphaFromBoolean then
        frame:SetAlphaFromBoolean(inRange, 1.0, outOfRangeAlpha)
    else
        frame:SetAlpha(inRange and 1.0 or outOfRangeAlpha)
    end
    if frame.healthBar then
        if frame.healthBar.SetAlphaFromBoolean then
            frame.healthBar:SetAlphaFromBoolean(inRange, 1.0, outOfRangeAlpha)
        else
            frame.healthBar:SetAlpha(inRange and 1.0 or outOfRangeAlpha)
        end
    end
end

-- ============================================================
-- PET RANGE HELPER
-- UNIT_IN_RANGE_UPDATE doesn't fire for pet units. When the
-- owner's range event fires we piggyback a pet range update.
-- ============================================================

local function UpdatePetForOwner(ownerUnit)
    if ownerUnit == "player" then
        -- Player's own pet
        if DF.petFrames and DF.petFrames.player then
            local petFrame = DF.petFrames.player
            if not petFrame.dfPetHidden then
                DF:UpdatePetRange(petFrame)
            end
        end
    else
        -- Party/raid pet — parse the index from the owner unit token
        local prefix, index = ownerUnit:match("^(%a+)(%d+)$")
        if not index then return end
        index = tonumber(index)

        if prefix == "party" and DF.partyPetFrames then
            local petFrame = DF.partyPetFrames[index]
            if petFrame and not petFrame.dfPetHidden then
                DF:UpdatePetRange(petFrame)
            end
        elseif prefix == "raid" and DF.raidPetFrames then
            local petFrame = DF.raidPetFrames[index]
            if petFrame and not petFrame.dfPetHidden then
                DF:UpdatePetRange(petFrame)
            end
        end
    end
end

-- ============================================================
-- RANGE UPDATE TIMER
-- Safety-net polling that runs alongside UNIT_IN_RANGE_UPDATE.
-- The event gives instant response for Blizzard's ~38yd range,
-- but doesn't cover spell-based ranges or all edge cases.
-- Both Grid2 and ElvUI use polling; we keep both for reliability.
-- ============================================================

local rangeAnimFrame = CreateFrame("Frame")
local rangeAnimGroup = rangeAnimFrame:CreateAnimationGroup()
local rangeAnim = rangeAnimGroup:CreateAnimation()
rangeAnim:SetDuration(0.5)  -- Default 0.5s. Configurable via options.
rangeAnimGroup:SetLooping("REPEAT")

-- Hoisted callback - avoids creating a new closure every tick
local function RangeCheckFrame(frame)
    if frame and frame:IsShown() then
        DF:UpdateRange(frame)
        if DF.UpdateHealthFade then
            DF:UpdateHealthFade(frame)
        end
    end
end

rangeAnimGroup:SetScript("OnLoop", function()
    if DF.PerfTest and not DF.PerfTest.enableRange then return end
    if not DF.partyHeader then return end

    local contentType = DF:GetContentType()

    if contentType == "arena" then
        -- Arena: only arena frames, no pets, no highlights
        if DF.IterateArenaFrames then
            DF:IterateArenaFrames(RangeCheckFrame)
        end
    elseif contentType then
        -- Raid content (battleground/mythic/instanced/openWorld): raid frames + raid pets
        DF:IterateRaidFrames(RangeCheckFrame)

        -- Raid pinned frames (only if initialized for raid mode and header is shown/enabled)
        if DF.PinnedFrames and DF.PinnedFrames.initialized and DF.PinnedFrames.currentMode == "raid" then
            for setIndex = 1, 2 do
                local header = DF.PinnedFrames.headers[setIndex]
                if header and header:IsShown() then
                    for i = 1, 40 do
                        local child = header:GetAttribute("child" .. i)
                        if child then
                            RangeCheckFrame(child)
                        end
                    end
                end
            end
        end

        if DF.raidPetFrames then
            for i = 1, 40 do
                local frame = DF.raidPetFrames[i]
                if frame and not frame.dfPetHidden then
                    DF:UpdatePetRange(frame)
                    if DF.UpdatePetHealthFade then
                        DF:UpdatePetHealthFade(frame)
                    end
                end
            end
        end
    else
        -- Party/solo: party frames + player pet + party pets
        DF:IteratePartyFrames(RangeCheckFrame)

        -- Party pinned frames (only if initialized for party mode and header is shown/enabled)
        if DF.PinnedFrames and DF.PinnedFrames.initialized and DF.PinnedFrames.currentMode == "party" then
            for setIndex = 1, 2 do
                local header = DF.PinnedFrames.headers[setIndex]
                if header and header:IsShown() then
                    for i = 1, 5 do
                        local child = header:GetAttribute("child" .. i)
                        if child then
                            RangeCheckFrame(child)
                        end
                    end
                end
            end
        end

        if DF.petFrames and DF.petFrames.player then
            local petFrame = DF.petFrames.player
            if not petFrame.dfPetHidden then
                DF:UpdatePetRange(petFrame)
                if DF.UpdatePetHealthFade then
                    DF:UpdatePetHealthFade(petFrame)
                end
            end
        end

        if DF.partyPetFrames then
            for i = 1, 4 do
                local frame = DF.partyPetFrames[i]
                if frame and not frame.dfPetHidden then
                    DF:UpdatePetRange(frame)
                    if DF.UpdatePetHealthFade then
                        DF:UpdatePetHealthFade(frame)
                    end
                end
            end
        end
    end

    -- Pinned boss frames (work in both raid and party content — independent of group type).
    -- Boss units don't fire UNIT_IN_RANGE_UPDATE, so polling is the only way to detect range.
    if contentType and contentType ~= "arena" and DF.PinnedFrames and DF.PinnedFrames.bossFrames then
        for setIndex = 1, 2 do
            local frames = DF.PinnedFrames.bossFrames[setIndex]
            if frames then
                for i = 1, 8 do
                    local f = frames[i]
                    if f and f:IsShown() then
                        RangeCheckFrame(f)
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- EVENT HANDLERS
-- ============================================================

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

-- Lazy-cached reference to unitFrameMap (populated by Headers.lua after load)
local unitFrameMap

-- UNIT_IN_RANGE_UPDATE is routed through the roster unit event dispatcher
-- (RosterEvents.lua) so it only fires for player/partyN/raidN — never for
-- nameplates, target, focus, mouseover, or any other unit token. This is one
-- of only two events Grid2 specifically routes through its dispatcher (the
-- other being UNIT_AURA) because the per-unit cost adds up enough during
-- movement to justify the C++-level filter.
local rangeSubscriber = {}
function rangeSubscriber:OnUnitInRange(event, unit)
    if not unit then return end
    -- Player frame doesn't need range updates (always in range of itself).
    if unit == "player" then return end

    -- Lazy-init the unitFrameMap reference
    if not unitFrameMap then
        unitFrameMap = DF.unitFrameMap
        if not unitFrameMap then return end
    end

    -- Main frame: O(1) lookup
    local frame = unitFrameMap[unit]
    if frame and frame:IsShown() then
        DF:UpdateRange(frame)
    end

    -- Pinned frames: may show the same unit on a second frame
    if DF.PinnedFrames and DF.PinnedFrames.initialized and DF.PinnedFrames.headers then
        for setIndex = 1, 2 do
            local header = DF.PinnedFrames.headers[setIndex]
            if header and header:IsShown() then
                local maxChildren = DF.PinnedFrames.currentMode == "raid" and 40 or 5
                for i = 1, maxChildren do
                    local child = header:GetAttribute("child" .. i)
                    if child and child:IsShown() and child.unit == unit then
                        DF:UpdateRange(child)
                    end
                end
            end
        end
    end

    -- Pinned boss frames: UNIT_IN_RANGE_UPDATE doesn't fire for boss units in
    -- practice, but register here as fallback coverage if Blizzard changes behavior.
    if DF.PinnedFrames and DF.PinnedFrames.bossFrames then
        for setIndex = 1, 2 do
            local frames = DF.PinnedFrames.bossFrames[setIndex]
            if frames then
                for i = 1, 8 do
                    local f = frames[i]
                    if f and f:IsShown() and f.unit == unit then
                        DF:UpdateRange(f)
                    end
                end
            end
        end
    end

    -- Pet frames: UNIT_IN_RANGE_UPDATE doesn't fire for pets,
    -- but pet range is derived from the owner — update it here.
    UpdatePetForOwner(unit)
end
DF:RegisterRosterUnitEvent(rangeSubscriber, "UNIT_IN_RANGE_UPDATE", "OnUnitInRange")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_TALENT_UPDATE" then
        local unit = ...
        -- PLAYER_TALENT_UPDATE fires without a unit arg, so always update
        if event == "PLAYER_TALENT_UPDATE" or unit == "player" then
            UpdateRangeSpell()
            ClearRangeCache()
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Initialize range spell on login/reload
        UpdateRangeSpell()
        ClearRangeCache()
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        -- Clear cache on combat transitions so stale values from a different
        -- combat state don't persist (e.g. CheckInteractDistance results from
        -- out-of-combat shouldn't carry into combat where that API is unavailable)
        ClearRangeCache()
    end
end)

-- ============================================================
-- START TIMER & INITIALIZE
-- ============================================================

-- Also initialize immediately in case we loaded late
UpdateRangeSpell()

C_Timer.After(1, function()
    -- Re-check after 1 second to ensure spec info is available
    UpdateRangeSpell()
    -- Apply configured interval from DB (default 0.5s)
    if DF.db then
        local db = DF:GetDB()
        local interval = db and db.rangeUpdateInterval or 0.5
        rangeAnim:SetDuration(interval)
    end
    rangeAnimGroup:Play()
    DF.RangeTimer = rangeAnimGroup
end)

-- Called by Options panel when user changes the range update interval slider
function DF:SetRangeUpdateInterval(interval)
    interval = interval or 0.5
    rangeAnim:SetDuration(interval)
end

-- ============================================================
-- API FOR OPTIONS UI
-- ============================================================

-- Get list of available spells for dropdown
function DF:GetRangeSpellOptions()
    local options = {
        { value = 0, label = "Auto (Spec Default)" }
    }
    
    -- Helper to get actual spell range from spell data (accounts for talents)
    local function GetSpellRange(spellID, fallback)
        if spellID and C_Spell.GetSpellInfo then
            local spellInfo = C_Spell.GetSpellInfo(spellID)
            if spellInfo and spellInfo.maxRange and spellInfo.maxRange > 0 then
                return math.floor(spellInfo.maxRange) .. "yd"
            end
        end
        return fallback or "?yd"
    end
    
    -- Add spec default info
    if currentSpecID and specSpells[currentSpecID] then
        local spells = specSpells[currentSpecID]
        if spells.friendly then
            local name = C_Spell_GetSpellName(spells.friendly)
            if name then
                options[1].label = "Auto: " .. name .. " (" .. GetSpellRange(spells.friendly, spells.range) .. ")"
            end
        else
            -- Classes without friendly spells (DK, DH, Hunter, Warrior)
            -- use UnitInRange/CheckInteractDistance as fallback
            options[1].label = "Auto: UnitInRange (~40yd)"
        end
    end
    
    -- Common healing spells for manual selection
    local commonSpells = {
        -- Healer spells
        { id = 774,    name = "Rejuvenation",       class = "DRUID" },
        { id = 8936,   name = "Regrowth",            class = "DRUID" },
        { id = 2061,   name = "Flash Heal",          class = "PRIEST" },
        { id = 17,     name = "Power Word: Shield",  class = "PRIEST" },
        { id = 8004,   name = "Healing Surge",       class = "SHAMAN" },
        { id = 19750,  name = "Flash of Light",      class = "PALADIN" },
        { id = 116670, name = "Vivify",              class = "MONK" },
        { id = 355913, name = "Emerald Blossom",     class = "EVOKER" },
        -- Utility spells
        { id = 1459,   name = "Arcane Intellect",    class = "MAGE" },
        { id = 20707,  name = "Soulstone",           class = "WARLOCK" },
    }
    
    -- Filter to show only spells the player knows or all if they want
    for _, spell in ipairs(commonSpells) do
        if IsPlayerSpell(spell.id) or spell.class == playerClass then
            local name = C_Spell_GetSpellName(spell.id) or spell.name
            table.insert(options, {
                value = spell.id,
                label = name .. " (" .. GetSpellRange(spell.id) .. ")"
            })
        end
    end
    
    return options
end

-- Called when user changes the range spell setting
function DF:SetRangeCheckSpell(spellID)
    -- Note: The Options dropdown already sets the value in the mode-specific db
    -- This function just triggers the update
    UpdateRangeSpell()
    ClearRangeCache()
end

-- Get current range spell info for display
function DF:GetCurrentRangeSpellInfo()
    local spellID = currentFriendlySpell or currentHostileSpell
    local spellName, range

    if currentFriendlySpell then
        -- Has a friendly spell - show it with actual range
        spellName = C_Spell_GetSpellName(currentFriendlySpell) or "Unknown"
        if C_Spell.GetSpellInfo then
            local spellInfo = C_Spell.GetSpellInfo(currentFriendlySpell)
            if spellInfo and spellInfo.maxRange and spellInfo.maxRange > 0 then
                range = math.floor(spellInfo.maxRange) .. "yd"
            end
        end
    else
        -- No friendly spell (DK, DH, Hunter, Warrior) - show fallback method
        spellName = "UnitInRange"
        range = "~40yd"
    end

    -- Fallback to hardcoded range if nothing found yet
    if not range and currentSpecID and specSpells[currentSpecID] then
        range = specSpells[currentSpecID].range or "40yd"
    end
    range = range or "Unknown"
    
    -- Check if using custom override or auto
    local isCustom = false
    local userSpellID = nil
    if DF.db then
        local partyDB = DF.db.party
        local raidDB = DF.db.raid
        if partyDB and partyDB.rangeCheckSpellID and partyDB.rangeCheckSpellID > 0 then
            userSpellID = partyDB.rangeCheckSpellID
        elseif raidDB and raidDB.rangeCheckSpellID and raidDB.rangeCheckSpellID > 0 then
            userSpellID = raidDB.rangeCheckSpellID
        end
    end
    
    if userSpellID and userSpellID > 0 then
        isCustom = true
    end
    
    return {
        spellID = spellID,
        spellName = spellName or "None",
        range = range,
        specID = currentSpecID,
        isCustom = isCustom,
    }
end

-- Force update (for options panel)
function DF:RefreshRangeSpell()
    UpdateRangeSpell()
    ClearRangeCache()
end

-- ============================================================
-- SLASH COMMANDS
-- ============================================================

SLASH_DFRANGE1 = "/dfrange"
SlashCmdList["DFRANGE"] = function(msg)
    local cmd = msg:lower():trim()
    
    if cmd == "debug" then
        debugEnabled = not debugEnabled
        print("|cFF00FF00[DFRange]|r Debug:", debugEnabled and "ON" or "OFF")
        
    elseif cmd == "stats" then
        local elapsed = time() - debugStats.lastReset
        local total = debugStats.cacheHits + debugStats.cacheMisses
        local hitRate = total > 0 and math.floor((debugStats.cacheHits / total) * 100) or 0
        
        print("|cFF00FF00[DFRange]|r Stats (last " .. elapsed .. "s):")
        print("  Checks: " .. debugStats.checks)
        print("  Cache hits: |cFF00FF00" .. debugStats.cacheHits .. "|r")
        print("  Cache misses: |cFFFFFF00" .. debugStats.cacheMisses .. "|r")
        print("  Hit rate: |cFF00FFFF" .. hitRate .. "%|r")
        
    elseif cmd == "clear" then
        ClearRangeCache()
        ResetStats()
        print("|cFF00FF00[DFRange]|r Cache cleared")
        
    elseif cmd == "spell" then
        local info = DF:GetCurrentRangeSpellInfo()
        local specIndex = GetSpecialization()
        local specID = specIndex and GetSpecializationInfo(specIndex) or nil
        print("|cFF00FF00[DFRange]|r Current Range Spell:")
        print("  Class: " .. tostring(playerClass))
        print("  Spec Index: " .. tostring(specIndex))
        print("  Spec ID: " .. tostring(specID) .. " (cached: " .. tostring(currentSpecID) .. ")")
        print("  Friendly Spell: " .. tostring(currentFriendlySpell) .. " (" .. (currentFriendlySpell and C_Spell_GetSpellName(currentFriendlySpell) or "none") .. ")")
        print("  Hostile Spell: " .. tostring(currentHostileSpell) .. " (" .. (currentHostileSpell and C_Spell_GetSpellName(currentHostileSpell) or "none") .. ")")
        print("  Rez Spell: " .. tostring(currentRezSpell) .. " (" .. (currentRezSpell and C_Spell_GetSpellName(currentRezSpell) or "none") .. ")")
        print("  Timer Interval: " .. tostring(rangeAnim:GetDuration()) .. "s")
        print("  Display: " .. (info.spellName or "None") .. " (" .. (info.range or "?") .. ")")
        print("  Custom Override: " .. tostring(info.isCustom))
        -- Show DB values
        if DF.db then
            local partyVal = DF.db.party and DF.db.party.rangeCheckSpellID or "nil"
            local raidVal = DF.db.raid and DF.db.raid.rangeCheckSpellID or "nil"
            print("  DB Party: " .. tostring(partyVal) .. ", DB Raid: " .. tostring(raidVal))
        end
        -- Test if the friendly spell works on party1
        if UnitExists("party1") then
            local testResult = currentFriendlySpell and C_Spell_IsSpellInRange(currentFriendlySpell, "party1")
            print("  Test on party1: " .. tostring(testResult))
        end
        
    elseif cmd == "dump" then
        print("|cFF00FF00[DFRange]|r Cache contents:")
        local count = 0
        for unit, inRange in pairs(rangeCache) do
            print("  " .. unit .. " = " .. tostring(inRange))
            count = count + 1
        end
        print("  Total: " .. count)
        
    else
        print("|cFF00FF00[DFRange]|r Commands:")
        print("  /dfrange debug - Toggle debug")
        print("  /dfrange stats - Show statistics")
        print("  /dfrange clear - Clear cache")
        print("  /dfrange spell - Show current spell")
        print("  /dfrange dump  - Dump cache")
    end
end

-- ============================================================
-- LEGACY API
-- ============================================================

function DF:ClearRangeCache()
    ClearRangeCache()
end

-- Clear range cache for a single unit (used when unit assignment changes on a frame)
function DF:ClearRangeCacheForUnit(unit)
    if unit then
        rangeCache[unit] = nil
        rangeCache["pet_" .. unit] = nil  -- Also clear pet cache for this unit
        wasOORCache[unit] = nil
    end
end

function DF:GetRangeCheckerInfo()
    local info = DF:GetCurrentRangeSpellInfo()
    return "IsSpellInRange", info.spellID, info.spellName
end
