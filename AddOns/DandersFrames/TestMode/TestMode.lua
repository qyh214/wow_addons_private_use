local addonName, DF = ...
local L = DF.L

-- ============================================================
-- FRAMES TEST MODE MODULE
-- Contains test mode data, functions, and test panel
-- ============================================================

-- ============================================================
-- TEST MODE DATA
-- ============================================================

DF.TestData = {
    units = {
        {name = "Tankerino", class = "WARRIOR", role = "TANK", specID = 73, health = 1.0, maxHealth = 100000, absorb = 0.20, healAbsorb = 0, healPrediction = 0.15, status = nil, outOfRange = false, isLeader = true, raidTarget = 8, dispelType = nil, centerStatus = nil, isMainTank = true, isAFK = false, isPhased = false, inVehicle = false, hasMyBuff = true},  -- Skull marker, leader, main tank, has HoT
        {name = "Healsworth", class = "PRIEST", role = "HEALER", specID = 257, health = 0.95, maxHealth = 85000, absorb = 0.10, healAbsorb = 0, healPrediction = 0.05, status = nil, outOfRange = false, isAssist = true, raidTarget = nil, dispelType = "Magic", centerStatus = "summon", isMainAssist = true, isAFK = false, isPhased = false, inVehicle = false, hasMyBuff = false},  -- Assistant, main assist, summon pending
        {name = "Мишок", class = "MAGE", role = "DAMAGER", specID = 63, health = 0.60, maxHealth = 75000, absorb = 0, healAbsorb = 0.15, healPrediction = 0.15, status = nil, outOfRange = true, raidTarget = 1, dispelType = "Curse", centerStatus = nil, isAFK = true, isPhased = false, inVehicle = false, hasMyBuff = true},  -- Star marker, AFK, has HoT
        {name = "Alexandrosthegreat", class = "PALADIN", role = "DAMAGER", specID = 70, health = 0, maxHealth = 90000, absorb = 0, healAbsorb = 0, healPrediction = 0, status = "Dead", outOfRange = false, raidTarget = nil, dispelType = nil, centerStatus = "resurrect", isAFK = false, isPhased = false, inVehicle = false, hasMyBuff = false},  -- Dead unit, being resurrected
        {name = "Xx", class = "ROGUE", role = "DAMAGER", specID = 260, health = 0.30, maxHealth = 70000, absorb = 0.05, healAbsorb = 0.12, healPrediction = 0.25, status = nil, outOfRange = false, raidTarget = nil, dispelType = "Poison", centerStatus = nil, isAFK = false, isPhased = true, inVehicle = true, hasMyBuff = true},  -- Phased, in vehicle, has HoT
    },
    -- Test aura data - expanded for testing layouts
    buffs = {
        {icon = "Interface\\Icons\\Spell_Holy_PowerWordShield", name = "Power Word: Shield", duration = 30, stacks = 0},
        {icon = "Interface\\Icons\\Spell_Nature_Rejuvenation", name = "Rejuvenation", duration = 12, stacks = 0},
        {icon = "Interface\\Icons\\Spell_Holy_Renew", name = "Renew", duration = 15, stacks = 3},
        {icon = "Interface\\Icons\\Spell_Holy_BlessingOfProtection", name = "Blessing of Protection", duration = 10, stacks = 0},
        {icon = "Interface\\Icons\\Spell_Nature_Regenerate", name = "Regrowth", duration = 12, stacks = 0},
        {icon = "Interface\\Icons\\Spell_Holy_Restoration", name = "Restoration", duration = 8, stacks = 0},
        {icon = "Interface\\Icons\\Spell_Holy_GreaterHeal", name = "Greater Heal", duration = 6, stacks = 2},
        {icon = "Interface\\Icons\\Spell_Nature_LightningShield", name = "Lightning Shield", duration = 600, stacks = 9},
        {icon = "Interface\\Icons\\Spell_Holy_SealOfRighteousness", name = "Seal of Righteousness", duration = 0, stacks = 0},
        {icon = "Interface\\Icons\\Spell_Magic_GreaterBlessingOfKings", name = "Blessing of Kings", duration = 0, stacks = 0},
    },
    debuffs = {
        {icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain", name = "Shadow Word: Pain", duration = 18, stacks = 0, debuffType = "Magic"},
        {icon = "Interface\\Icons\\Spell_Nature_NullifyPoison", name = "Deadly Poison", duration = 8, stacks = 2, debuffType = "Poison"},
        {icon = "Interface\\Icons\\Spell_Shadow_CurseOfTongues", name = "Curse of Tongues", duration = 30, stacks = 0, debuffType = "Curse"},
        {icon = "Interface\\Icons\\Ability_Rogue_Garrote", name = "Garrote", duration = 18, stacks = 0, debuffType = nil},
        {icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy", name = "Disease", duration = 21, stacks = 0, debuffType = "Disease"},
        {icon = "Interface\\Icons\\Spell_Fire_Immolation", name = "Immolate", duration = 15, stacks = 0, debuffType = "Magic"},
        {icon = "Interface\\Icons\\Ability_Druid_Rake", name = "Rake", duration = 15, stacks = 0, debuffType = nil},
        {icon = "Interface\\Icons\\Spell_Nature_Slow", name = "Slow", duration = 12, stacks = 0, debuffType = "Magic"},
        {icon = "Interface\\Icons\\Ability_Creature_Disease_05", name = "Plague", duration = 24, stacks = 3, debuffType = "Disease"},
        {icon = "Interface\\Icons\\Spell_Shadow_Possession", name = "Fear", duration = 8, stacks = 0, debuffType = "Magic"},
    },
    -- Boss debuffs (Private Auras) - these simulate what boss mechanics look like
    bossDebuffs = {
        {icon = "Interface\\Icons\\Spell_Shadow_ShadesOfDarkness", name = "Ethereal Shackles", duration = 8, debuffType = "Magic"},
        {icon = "Interface\\Icons\\Spell_Fire_FelFlameBreath", name = "Searing Brand", duration = 12, debuffType = "Magic"},
        {icon = "Interface\\Icons\\Ability_Warlock_ShadowFlame", name = "Shadow Burn", duration = 6, debuffType = nil},
        {icon = "Interface\\Icons\\Spell_Shadow_DevouringPlague", name = "Devouring Void", duration = 10, debuffType = "Magic"},
    },
    animationTimer = nil,
    animationPhase = 0,
}

-- Get test unit data for a frame index
-- For party: index 0 = player, 1-4 = party members
-- For raid: index 1-40 = raid members
function DF:GetTestUnitData(index, isRaid, isBoss)
    local db = isRaid and DF:GetRaidDB() or DF:GetDB()

    -- Friendly Boss NPC test data (for pinned frame boss mode).
    -- Boss NPCs don't have classes or roles — we return a minimal fake unit
    -- so the frame renders a health bar with a readable name.
    if isBoss then
        local bossNames = {
            "Fiery Treant", "Charred Bramble", "Smoldering Sapling", "Ember Root",
            "Blazing Thorn", "Ashen Oak", "Cinder Vine", "Glowing Grove",
        }
        local i = index
        local basePercent = (0.9 - (i - 1) * 0.08)  -- slight descending stagger
        if basePercent < 0.25 then basePercent = 0.25 end

        local result = {
            index = index,
            name = bossNames[i] or ("Friendly Boss " .. i),
            class = nil,
            role = nil,
            specID = 0,
            healthPercent = basePercent,
            maxHealth = 500000,
            currentHealth = math.floor(basePercent * 500000),
            powerPercent = 0,
            absorbPercent = 0,
            healAbsorbPercent = 0,
            healPredictionPercent = 0,
            status = nil,
            outOfRange = false,
            isLeader = false,
            raidTarget = nil,
            dispelType = nil,
            centerStatus = nil,
            hasMyBuff = false,
            isMainTank = false,
            isMainAssist = false,
            isAFK = false,
            isPhased = false,
            inVehicle = false,
        }

        -- Animate health if enabled on either DB
        if db.testAnimateHealth and DF.TestData.animationPhase then
            local phase = DF.TestData.animationPhase
            local offset = (i * 0.13) % 1
            local wave = math.sin((phase + offset) * math.pi * 2)
            result.healthPercent = math.max(0.1, math.min(1, basePercent + wave * 0.15))
            result.currentHealth = math.floor(result.healthPercent * result.maxHealth)
        end

        return result
    end

    -- For raid frames, generate deterministic test data
    if isRaid then
        local testNames = {
            "Tankadin", "Healbot", "Magefire", "Stabbymc", "Huntard",
            "Shammywow", "Dkfrost", "Warlockz", "Monkbrew", "Priestess",
            "Druidtree", "Palaheals", "Rogueshadow", "Warriorfury", "Huntermark",
            "Magearcane", "Warlockaff", "Shamanrest", "Monkmist", "Priestshadow",
            "Dkblood", "Demonhunter", "Evokerdev", "Tankwarrior", "Tankdruid",
            "Holypriest", "Discpriest", "Restoshaman", "Mistweaver", "Holypaladin",
            "Boomkin", "Feral", "Enhance", "Elemental", "Retribution",
            "Windwalker", "Havoc", "Devastation", "Arms", "Assassination"
        }
        local testClasses = {
            "PALADIN", "PRIEST", "MAGE", "ROGUE", "HUNTER",
            "SHAMAN", "DEATHKNIGHT", "WARLOCK", "MONK", "PRIEST",
            "DRUID", "PALADIN", "ROGUE", "WARRIOR", "HUNTER",
            "MAGE", "WARLOCK", "SHAMAN", "MONK", "PRIEST",
            "DEATHKNIGHT", "DEMONHUNTER", "EVOKER", "WARRIOR", "DRUID",
            "PRIEST", "PRIEST", "SHAMAN", "MONK", "PALADIN",
            "DRUID", "DRUID", "SHAMAN", "SHAMAN", "PALADIN",
            "MONK", "DEMONHUNTER", "EVOKER", "WARRIOR", "ROGUE"
        }
        local testRoles = {
            "TANK", "HEALER", "DAMAGER", "DAMAGER", "DAMAGER",
            "HEALER", "DAMAGER", "DAMAGER", "TANK", "HEALER",
            "HEALER", "HEALER", "DAMAGER", "DAMAGER", "DAMAGER",
            "DAMAGER", "DAMAGER", "HEALER", "HEALER", "DAMAGER",
            "TANK", "DAMAGER", "DAMAGER", "TANK", "TANK",
            "HEALER", "HEALER", "HEALER", "HEALER", "HEALER",
            "DAMAGER", "DAMAGER", "DAMAGER", "DAMAGER", "DAMAGER",
            "DAMAGER", "DAMAGER", "DAMAGER", "DAMAGER", "DAMAGER"
        }
        -- Spec IDs matching each class/role for accurate melee/ranged separation
        local testSpecs = {
            66,   -- 1  PALADIN/TANK      - Protection
            257,  -- 2  PRIEST/HEALER     - Holy
            63,   -- 3  MAGE/DAMAGER      - Fire (ranged)
            260,  -- 4  ROGUE/DAMAGER     - Outlaw (melee)
            254,  -- 5  HUNTER/DAMAGER    - Marksmanship (ranged)
            264,  -- 6  SHAMAN/HEALER     - Restoration
            251,  -- 7  DEATHKNIGHT/DPS   - Frost (melee)
            265,  -- 8  WARLOCK/DAMAGER   - Affliction (ranged)
            268,  -- 9  MONK/TANK         - Brewmaster
            256,  -- 10 PRIEST/HEALER     - Discipline
            105,  -- 11 DRUID/HEALER      - Restoration
            65,   -- 12 PALADIN/HEALER    - Holy
            259,  -- 13 ROGUE/DAMAGER     - Assassination (melee)
            71,   -- 14 WARRIOR/DAMAGER   - Arms (melee)
            255,  -- 15 HUNTER/DAMAGER    - Survival (melee)
            64,   -- 16 MAGE/DAMAGER      - Frost (ranged)
            266,  -- 17 WARLOCK/DAMAGER   - Demonology (ranged)
            264,  -- 18 SHAMAN/HEALER     - Restoration
            270,  -- 19 MONK/HEALER       - Mistweaver
            258,  -- 20 PRIEST/DAMAGER    - Shadow (ranged)
            250,  -- 21 DEATHKNIGHT/TANK  - Blood
            577,  -- 22 DEMONHUNTER/DPS   - Havoc (melee)
            1467, -- 23 EVOKER/DAMAGER    - Devastation (ranged)
            73,   -- 24 WARRIOR/TANK      - Protection
            104,  -- 25 DRUID/TANK        - Guardian
            257,  -- 26 PRIEST/HEALER     - Holy
            256,  -- 27 PRIEST/HEALER     - Discipline
            264,  -- 28 SHAMAN/HEALER     - Restoration
            270,  -- 29 MONK/HEALER       - Mistweaver
            65,   -- 30 PALADIN/HEALER    - Holy
            102,  -- 31 DRUID/DAMAGER     - Balance (ranged)
            103,  -- 32 DRUID/DAMAGER     - Feral (melee)
            263,  -- 33 SHAMAN/DAMAGER    - Enhancement (melee)
            262,  -- 34 SHAMAN/DAMAGER    - Elemental (ranged)
            70,   -- 35 PALADIN/DAMAGER   - Retribution (melee)
            269,  -- 36 MONK/DAMAGER      - Windwalker (melee)
            577,  -- 37 DEMONHUNTER/DPS   - Havoc (melee)
            1473, -- 38 EVOKER/DAMAGER    - Augmentation (ranged)
            72,   -- 39 WARRIOR/DAMAGER   - Fury (melee)
            261,  -- 40 ROGUE/DAMAGER     - Subtlety (melee)
        }
        local testHealthPercents = {
            0.95, 0.88, 0.72, 0.65, 0.80,
            0.92, 0.58, 0.75, 0.85, 0.70,
            0.90, 0.82, 0.68, 0.55, 0.78,
            0.88, 0.62, 0.95, 0.72, 0.60,
            0.98, 0.75, 0.82, 0.90, 0.85,
            0.78, 0.92, 0.65, 0.88, 0.70,
            0.82, 0.75, 0.68, 0.95, 0.58,
            0.85, 0.72, 0.80, 0.65, 0.90
        }
        local testPowerPercents = {
            0.85, 0.92, 0.78, 0.65, 0.70,
            0.88, 0.55, 0.82, 0.95, 0.72,
            0.80, 0.68, 0.90, 0.75, 0.85,
            0.62, 0.95, 0.70, 0.88, 0.78,
            0.92, 0.65, 0.85, 0.72, 0.80,
            0.90, 0.75, 0.82, 0.68, 0.95,
            0.78, 0.85, 0.70, 0.88, 0.62,
            0.80, 0.92, 0.75, 0.68, 0.85
        }
        
        local i = index
        local baseHealth = testHealthPercents[i] or 0.75
        local basePower = testPowerPercents[i] or 0.80
        
        -- Determine if this frame should be dead (frames 9, 17, 29)
        local isDead = (i == 9 or i == 17 or i == 29)
        
        -- Determine dispel type - pattern designed to overlap with some OOR frames
        -- OOR frames are 3, 7, 11, 15, 19, 23, 27, 31, 35, 39
        -- This pattern gives dispels to frames: 1,6,11,16,21,26,31,36 (Magic), 3,8,13,18,23,28,33,38 (Curse), 5,10,15,20,25,30,35,40 (Poison)
        local dispelType = nil
        if not isDead then  -- Dead frames don't show dispels
            if i % 5 == 1 then
                dispelType = "Magic"
            elseif i % 5 == 3 then
                dispelType = "Curse"
            elseif i % 5 == 0 then
                dispelType = "Poison"
            elseif i % 7 == 0 then
                dispelType = "Disease"  -- Frames 7, 14, 21, 28, 35
            end
        end
        
        local result = {
            index = index,  -- Include index for test mode features
            name = testNames[i] or ("Player" .. i),
            class = testClasses[i] or "WARRIOR",
            role = testRoles[i] or "DAMAGER",
            specID = testSpecs[i] or 0,
            healthPercent = isDead and 0 or baseHealth,
            maxHealth = 100000,
            currentHealth = isDead and 0 or math.floor(baseHealth * 100000),
            powerPercent = isDead and 0 or basePower,
            absorbPercent = isDead and 0 or ((i % 3 == 0) and 0.15 or ((i % 5 == 0) and 0.10 or 0)),
            healAbsorbPercent = isDead and 0 or ((i % 7 == 0) and 0.15 or 0),
            healPredictionPercent = isDead and 0 or ((i % 2 == 0) and 0.12 or ((i % 3 == 1) and 0.08 or 0)),  -- Show heal prediction on some frames
            status = isDead and "Dead" or nil,
            outOfRange = (i % 4 == 3) and not isDead,  -- Every 4th frame starting at 3, but not dead frames
            isLeader = (i == 1),
            raidTarget = (i <= 8) and i or nil,
            dispelType = dispelType,
            centerStatus = isDead and "resurrect" or ((i == 2 or i == 6) and "summon" or nil),  -- Dead get resurrect, frames 2 and 6 get summon
            hasMyBuff = (i % 3 == 1) and not isDead,  -- Every 3rd frame starting at 1 (1, 4, 7, 10...), but not dead
            -- New icon states
            isMainTank = (i == 1 or i == 25),  -- First frame and frame 25
            isMainAssist = (i == 2 or i == 26),  -- Second frame and frame 26
            isAFK = (i == 3 or i == 15),  -- Frames 3 and 15
            isPhased = (i == 4 or i == 20),  -- Frames 4 and 20
            inVehicle = (i == 5 or i == 30),  -- Frames 5 and 30
        }
        
        -- Apply animation if enabled
        if db.testAnimateHealth and DF.TestData.animationPhase then
            local phase = DF.TestData.animationPhase
            local offset = (i * 0.15) % 1
            local wave = math.sin((phase + offset) * math.pi * 2)
            
            result.healthPercent = math.max(0.1, math.min(1, baseHealth + wave * 0.15))
            result.currentHealth = math.floor(result.healthPercent * result.maxHealth)
        end
        
        return result
    end
    
    -- Party test data (original logic)
    local data = DF.TestData.units[index + 1]
    if not data then return nil end
    
    local result = {
        index = index,  -- Include index for test mode features
        name = data.name,
        class = data.class,
        role = data.role,
        specID = data.specID or 0,
        healthPercent = data.health,
        maxHealth = data.maxHealth,
        currentHealth = math.floor(data.health * data.maxHealth),
        powerPercent = 0.8,  -- Default power for party
        absorbPercent = data.absorb,
        healAbsorbPercent = data.healAbsorb,
        healPredictionPercent = data.healPrediction or 0,
        status = data.status,
        outOfRange = data.outOfRange,
        isLeader = data.isLeader,
        isAssist = data.isAssist,
        raidTarget = data.raidTarget,
        dispelType = data.dispelType,
        centerStatus = data.centerStatus,
        hasMyBuff = data.hasMyBuff,
        -- New icon states
        isMainTank = data.isMainTank,
        isMainAssist = data.isMainAssist,
        isAFK = data.isAFK,
        isPhased = data.isPhased,
        inVehicle = data.inVehicle,
    }
    
    -- Don't animate dead or offline units
    if data.status then
        result.healthPercent = 0
        result.currentHealth = 0
        result.absorbPercent = 0
        result.healAbsorbPercent = 0
        result.healPredictionPercent = 0
        return result
    end
    
    -- Apply animation if enabled (only for alive units) - health only, not absorbs
    if db.testAnimateHealth and DF.TestData.animationPhase then
        local phase = DF.TestData.animationPhase
        local offset = (index * 0.2) % 1
        local wave = math.sin((phase + offset) * math.pi * 2)
        
        result.healthPercent = 0.65 + (wave * 0.35)
        result.currentHealth = math.floor(result.healthPercent * result.maxHealth)
        -- Note: Absorbs use static values from test data, not animated
    end
    
    return result
end

-- Start test mode animation
function DF:StartTestAnimation()
    if DF.TestData.animationTimer then return end
    
    DF.TestData.animationPhase = 0
    DF.TestData.animationTimer = C_Timer.NewTicker(0.05, function()
        DF.TestData.animationPhase = (DF.TestData.animationPhase + 0.02) % 1
        
        -- Update party test frames (lightweight - health only)
        if DF.testMode then
            for i = 0, 4 do
                local frame = DF.testPartyFrames[i]
                if frame and frame:IsShown() then
                    DF:UpdateTestFrameHealthOnly(frame, i)
                end
            end
        end
        
        -- Update raid test frames (lightweight - health only)
        if DF.raidTestMode then
            local db = DF:GetRaidDB()
            local testFrameCount = db.raidTestFrameCount or 10
            for i = 1, testFrameCount do
                local frame = DF.testRaidFrames[i]
                if frame and frame:IsShown() then
                    DF:UpdateTestFrameHealthOnly(frame, i)
                end
            end
        end

        -- Update pinned test frames (mock non-secure frames — same for
        -- both player-mode and boss-mode pinned sets). Lightweight.
        if DF.PinnedFrames and DF.PinnedFrames.IsTestModeActive
            and DF.PinnedFrames:IsTestModeActive() then
            for setIndex = 1, 2 do
                local pool = DF.PinnedFrames.testFrames[setIndex]
                if pool then
                    for i = 1, #pool do
                        local f = pool[i]
                        if f and f:IsShown() and f.dfTestIndex then
                            DF:UpdateTestFrameHealthOnly(f, f.dfTestIndex)
                        end
                    end
                end
            end
        end
    end)
end

-- Lightweight animation update - updates health and repositions bars
function DF:UpdateTestFrameHealthOnly(frame, index)
    if not frame or not frame.healthBar then return end

    local isRaid = frame.isRaidFrame
    local isBoss = frame.isPinnedBossFrame
    local testData = DF:GetTestUnitData(index, isRaid, isBoss)
    if not testData then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Dead or offline units should always show 0 health - no animation
    if testData.status then
        frame.healthBar:SetValue(0)
        frame.testAnimatedHealth = 0
        if frame.healthText and frame.healthText:IsShown() then
            frame.healthText:SetText("")
        end
        return
    end
    
    -- Calculate animated health (alive units only)
    local baseHealth = testData.healthPercent or testData.health or 0.75
    local phase = DF.TestData.animationPhase or 0
    local variation = math.sin(phase * math.pi * 2 + (index or 0)) * 0.15
    local health = math.max(0.1, math.min(1.0, baseHealth + variation))
    
    -- Store animated health for bar updates
    frame.testAnimatedHealth = health
    
    -- Update health bar
    frame.healthBar:SetValue(health)

    -- Re-evaluate health fade threshold with animated health value
    if db.healthFadeEnabled then
        local healthPct = health * 100
        local threshold = db.healthFadeThreshold or 100
        local isAbove = (healthPct >= threshold - 0.5)
        if isAbove and db.hfCancelOnDispel and frame.dfDispelOverlay and frame.dfDispelOverlay:IsShown() then
            isAbove = false
        end
        if not db.oorEnabled then
            frame:SetAlpha(isAbove and (db.healthFadeAlpha or 0.5) or 1.0)
        end
    end

    -- Update missing health bar if enabled
    if frame.missingHealthBar then
        local backgroundMode = db.backgroundMode or "BACKGROUND"
        if backgroundMode == "MISSING_HEALTH" or backgroundMode == "BOTH" then
            local missingHealth = 1 - health  -- In test mode, we can calculate directly
            frame.missingHealthBar:SetMinMaxValues(0, 1)
            frame.missingHealthBar:SetValue(missingHealth)
            
            -- Handle color mode
            local colorMode = db.missingHealthColorMode or "CUSTOM"
            local r, g, b, a
            if colorMode == "PERCENT" then
                local color = DF:GetHealthGradientColor(health, db, testData.class, "missingHealthColor")
                if color then
                    r, g, b = color.r, color.g, color.b
                else
                    r, g, b = 0.5, 0, 0
                end
                a = db.missingHealthGradientAlpha or 0.8
            elseif colorMode == "CLASS" and testData.class then
                local classColor = DF:GetClassColor(testData.class)
                if classColor then
                    r, g, b = classColor.r, classColor.g, classColor.b
                else
                    r, g, b = 0.5, 0, 0
                end
                a = db.missingHealthClassAlpha or 0.8
            else
                local missingColor = db.missingHealthColor or {r = 0.5, g = 0, b = 0, a = 0.8}
                r, g, b, a = missingColor.r, missingColor.g, missingColor.b, missingColor.a or 0.8
            end
            frame.missingHealthBar:SetStatusBarColor(r, g, b, a)
            
            -- Handle texture
            local texture = db.missingHealthTexture
            if not texture or texture == "" then
                texture = db.healthTexture or "Interface\\TargetingFrame\\UI-StatusBar"
            end
            frame.missingHealthBar:SetStatusBarTexture(texture)
            
            frame.missingHealthBar:Show()
        else
            frame.missingHealthBar:Hide()
        end
    end
    
    -- Update health bar color if using PERCENT (gradient) mode
    -- Only update RGB, alpha is managed by UpdateTestFrame
    -- Skip if aggro color override is active
    if db.healthColorMode == "PERCENT" and not frame.dfAggroActive then
        local color = DF:GetHealthGradientColor(health, db, testData.class)
        if color then
            frame.healthBar:SetStatusBarColor(color.r, color.g, color.b)
        end
    end
    
    -- Update health text if visible
    if frame.healthText and frame.healthText:IsShown() then
        local maxHP = testData.maxHealth or 100000
        local currentHP = math.floor(maxHP * health)
        local deficit = currentHP - maxHP
        local pct = health * 100
        local format = db.healthTextFormat or "DEFICIT"
        local abbreviate = db.healthTextAbbreviate
        
        local function FormatVal(val)
            if abbreviate then
                return DF:FormatNumber(val)
            end
            return tostring(val)
        end
        
        local text = ""
        if format == "CURRENT" then
            text = FormatVal(currentHP)
        elseif format == "PERCENT" then
            text = string.format("%.0f%%", pct)
        elseif format == "DEFICIT" then
            if deficit < 0 then
                text = FormatVal(deficit)
            else
                text = ""
            end
        elseif format == "CURRENT_MAX" or format == "CURRENTMAX" then
            text = FormatVal(currentHP) .. "/" .. FormatVal(maxHP)
        elseif format == "CURRENT_PERCENT" then
            text = FormatVal(currentHP) .. " " .. string.format("%.0f%%", pct)
        end
        frame.healthText:SetText(text)
    end
    
    -- Update bars to follow animated health (use animated health value)
    local animatedTestData = {}
    for k, v in pairs(testData) do
        animatedTestData[k] = v
    end
    animatedTestData.healthPercent = health
    
    -- Update absorb bars if enabled
    if db.testShowAbsorbs then
        DF:UpdateTestAbsorb(frame, animatedTestData)
        DF:UpdateTestHealAbsorb(frame, animatedTestData)
    end
    
    -- Update heal prediction if enabled
    if db.testShowHealPrediction ~= false then
        DF:UpdateTestHealPrediction(frame, animatedTestData)
    end
    
    -- Update dispel gradient if it's tracking health
    if frame.dfDispelOverlay and frame.dfDispelOverlay.gradientTracksHealth then
        frame.dfDispelOverlay.gradient:SetMinMaxValues(0, 1)
        frame.dfDispelOverlay.gradient:SetValue(health)
    end
end

-- Stop test mode animation
function DF:StopTestAnimation()
    if DF.TestData.animationTimer then
        DF.TestData.animationTimer:Cancel()
        DF.TestData.animationTimer = nil
    end
end

-- Update a frame with test data (works for both party and raid)
function DF:UpdateTestFrame(frame, index, applyLayout)
    if not frame or not frame.healthBar then return end

    local isRaid = frame.isRaidFrame
    local isBoss = frame.isPinnedBossFrame
    local testData = DF:GetTestUnitData(index, isRaid, isBoss)
    if not testData then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Set dfInRange for test mode - this is used by ApplyAuraLayout and other systems
    -- If testShowOutOfRange is enabled and this unit is marked as out of range, set false
    -- Otherwise set true (in range)
    local isTestOutOfRange = db.testShowOutOfRange and testData.outOfRange and not testData.status
    frame.dfInRange = not isTestOutOfRange
    
    -- Store applyLayout flag for UpdateTestAuras to use
    frame.dfTestApplyLayout = applyLayout
    
    -- Update health bar (use 0-1 range for test mode)
    frame.healthBar:SetMinMaxValues(0, 1)
    local healthValue = testData.healthPercent
    
    if db.smoothBars and Enum and Enum.StatusBarInterpolation then
        frame.healthBar:SetValue(healthValue, Enum.StatusBarInterpolation.ExponentialEaseOut)
    else
        frame.healthBar:SetValue(healthValue)
    end
    
    -- Update missing health bar if enabled
    if frame.missingHealthBar then
        local backgroundMode = db.backgroundMode or "BACKGROUND"
        if backgroundMode == "MISSING_HEALTH" or backgroundMode == "BOTH" then
            local missingHealth = 1 - healthValue  -- In test mode, we can calculate directly
            frame.missingHealthBar:SetMinMaxValues(0, 1)
            if db.smoothBars and Enum and Enum.StatusBarInterpolation then
                frame.missingHealthBar:SetValue(missingHealth, Enum.StatusBarInterpolation.ExponentialEaseOut)
            else
                frame.missingHealthBar:SetValue(missingHealth)
            end
            
            -- Handle color mode
            local colorMode = db.missingHealthColorMode or "CUSTOM"
            local r, g, b, a
            
            -- Check for dead/offline with custom dead color (same as Core.lua)
            local isDeadOrOfflineForColor = testData.status == "Dead" or testData.status == "Offline"
            local useDeadColor = isDeadOrOfflineForColor and db.fadeDeadFrames and db.fadeDeadUseCustomColor
            
            if useDeadColor then
                -- Use custom dead color (same as background uses)
                local c = db.fadeDeadBackgroundColor or {r = 0.3, g = 0, b = 0}
                r, g, b = c.r, c.g, c.b
                a = db.fadeDeadBackground or 0.4
            elseif colorMode == "PERCENT" then
                local color = DF:GetHealthGradientColor(healthValue, db, testData.class, "missingHealthColor")
                if color then
                    r, g, b = color.r, color.g, color.b
                else
                    r, g, b = 0.5, 0, 0
                end
                a = db.missingHealthGradientAlpha or 0.8
            elseif colorMode == "CLASS" and testData.class then
                local classColor = DF:GetClassColor(testData.class)
                if classColor then
                    r, g, b = classColor.r, classColor.g, classColor.b
                else
                    r, g, b = 0.5, 0, 0
                end
                a = db.missingHealthClassAlpha or 0.8
            else
                local missingColor = db.missingHealthColor or {r = 0.5, g = 0, b = 0, a = 0.8}
                r, g, b, a = missingColor.r, missingColor.g, missingColor.b, missingColor.a or 0.8
            end
            frame.missingHealthBar:SetStatusBarColor(r, g, b, a)
            
            -- Handle texture
            local texture = db.missingHealthTexture
            if not texture or texture == "" then
                texture = db.healthTexture or "Interface\\TargetingFrame\\UI-StatusBar"
            end
            frame.missingHealthBar:SetStatusBarTexture(texture)
            
            frame.missingHealthBar:Show()
        else
            frame.missingHealthBar:Hide()
        end
    end
    
    -- Update health text with proper formatting
    local format = db.healthTextFormat or "PERCENT"
    local currentHealth = testData.currentHealth
    local maxHealth = testData.maxHealth
    local deficit = maxHealth - currentHealth
    local abbreviate = db.healthTextAbbreviate
    
    local function FormatValue(val)
        if abbreviate then
            if AbbreviateNumbers then
                return AbbreviateNumbers(val)
            elseif AbbreviateLargeNumbers then
                return AbbreviateLargeNumbers(val)
            end
            -- Manual abbreviation fallback when abbreviate is true
            if val >= 1000000 then
                return string.format("%.1fM", val / 1000000)
            elseif val >= 1000 then
                return string.format("%.0fK", val / 1000)
            end
        end
        -- No abbreviation - return full number with comma formatting
        return tostring(val)
    end
    
    local pctFmt = db.healthTextHidePercent and "%.0f" or "%.0f%%"
    if format == "PERCENT" then
        frame.healthText:SetFormattedText(pctFmt, healthValue * 100)
    elseif format == "CURRENT" then
        frame.healthText:SetText(FormatValue(currentHealth))
    elseif format == "CURRENTMAX" then
        frame.healthText:SetText(FormatValue(currentHealth) .. "/" .. FormatValue(maxHealth))
    elseif format == "DEFICIT" then
        if deficit > 0 then
            frame.healthText:SetText("-" .. FormatValue(deficit))
        else
            frame.healthText:SetText("")
        end
    elseif format == "NONE" then
        frame.healthText:SetText("")
    else
        frame.healthText:SetFormattedText(pctFmt, healthValue * 100)
    end
    
    -- Update name
    local displayName = testData.name
    if displayName then
        local maxLen = db.nameTextLength or 0
        local truncMode = db.nameTextTruncateMode or "ELLIPSIS"
        
        if maxLen > 0 and DF:UTF8Len(displayName) > maxLen then
            if truncMode == "CUT" then
                displayName = DF:UTF8Sub(displayName, 1, maxLen)
            else
                displayName = DF:UTF8Sub(displayName, 1, maxLen) .. "..."
            end
        end
    end
    frame.nameText:SetText(displayName)
    
    -- Determine if this frame should show out-of-range effects
    -- OOR takes priority over dead fade (they should never multiply)
    local isOutOfRange = db.testShowOutOfRange and testData.outOfRange
    
    -- Calculate per-element alphas for out-of-range
    local healthBarAlpha = 1.0
    local backgroundAlpha = 1.0
    local nameAlpha = 1.0
    local healthTextAlpha = 1.0
    local aurasAlpha = 1.0
    local iconsAlpha = 1.0
    local powerBarAlpha = 1.0
    local dispelAlpha = 1.0
    local targetedSpellAlpha = 1.0
    
    if isOutOfRange then
        if db.oorEnabled then
            -- Element-specific alpha mode
            healthBarAlpha = db.oorHealthBarAlpha or 0.55
            backgroundAlpha = db.oorBackgroundAlpha or 0.55
            nameAlpha = db.oorNameTextAlpha or 0.55
            healthTextAlpha = db.oorHealthTextAlpha or 0.55
            aurasAlpha = db.oorAurasAlpha or 0.55
            iconsAlpha = db.oorIconsAlpha or 0.55
            powerBarAlpha = db.oorPowerBarAlpha or 0.55
            dispelAlpha = db.oorDispelOverlayAlpha or 0.55
            targetedSpellAlpha = db.oorTargetedSpellAlpha or 0.5
        else
            -- Simple frame-level alpha mode
            local alpha = db.rangeFadeAlpha or db.rangeAlpha or 0.55
            healthBarAlpha = alpha
            backgroundAlpha = alpha
            nameAlpha = alpha
            healthTextAlpha = alpha
            aurasAlpha = alpha
            iconsAlpha = alpha
            powerBarAlpha = alpha
            dispelAlpha = alpha
            targetedSpellAlpha = alpha
        end
    end
    
    -- Store alpha values for use by UpdateTestIcons and UpdateTestPowerBar
    frame.dfTestOORAlphas = {
        icons = iconsAlpha,
        power = powerBarAlpha,
        dispel = dispelAlpha,
        targetedSpell = targetedSpellAlpha,
    }
    
    -- Check if this is a dead/offline unit for dead fade handling
    local isDeadOrOffline = testData.status == "Dead" or testData.status == "Offline"
    local applyDeadFade = isDeadOrOffline and db.fadeDeadFrames and not isOutOfRange
    
    -- Store dead fade alphas for use by UpdateTestIcons and UpdateTestPowerBar
    -- OOR takes priority: skip dead fade storage when out of range
    if applyDeadFade then
        frame.dfTestDeadFadeAlphas = {
            icons = db.fadeDeadIcons or 1.0,
            power = db.fadeDeadPowerBar or 0.4,
            auras = db.fadeDeadAuras or 1.0,
        }
    else
        frame.dfTestDeadFadeAlphas = nil
    end
    
    -- Health-based fading (above threshold): only when in range, alive, and option enabled
    local healthPct = (testData.healthPercent or 1) * 100
    local threshold = db.healthFadeThreshold or 100
    local isAboveHealthThreshold = not isOutOfRange and not applyDeadFade
        and db.healthFadeEnabled
        and (healthPct >= threshold - 0.5)
    if isAboveHealthThreshold and db.hfCancelOnDispel and frame.dfDispelOverlay and frame.dfDispelOverlay:IsShown() then
        isAboveHealthThreshold = false
    end
    
    if isAboveHealthThreshold then
        local hfAlpha = db.healthFadeAlpha or 0.5
        healthBarAlpha = hfAlpha
        backgroundAlpha = hfAlpha
        nameAlpha = hfAlpha
        healthTextAlpha = hfAlpha
        aurasAlpha = hfAlpha
        iconsAlpha = hfAlpha
        powerBarAlpha = hfAlpha
        dispelAlpha = hfAlpha
        targetedSpellAlpha = hfAlpha
        frame.dfTestHealthFadeAlphas = {
            icons = iconsAlpha,
            power = powerBarAlpha,
            dispel = dispelAlpha,
            targetedSpell = targetedSpellAlpha,
        }
    else
        frame.dfTestHealthFadeAlphas = nil
    end
    
    -- Update name color with appropriate alpha
    -- Priority: OOR > dead fade > health-based fade
    local finalNameAlpha = nameAlpha
    if not isOutOfRange and applyDeadFade then
        finalNameAlpha = db.fadeDeadName or 1.0
    end
    
    if db.nameTextUseClassColor then
        local classColor = DF:GetClassColor(testData.class)
        if classColor then
            frame.nameText:SetTextColor(classColor.r, classColor.g, classColor.b, finalNameAlpha)
        end
    else
        local c = db.nameTextColor or {r=1, g=1, b=1}
        frame.nameText:SetTextColor(c.r, c.g, c.b, finalNameAlpha)
    end
    
    -- Update health bar color based on mode
    -- Use RGB only (no alpha in SetStatusBarColor) so we can control alpha externally
    -- Skip if aggro color override is active
    local classColorAlpha = db.classColorAlpha or 1.0
    if not frame.dfAggroActive then
        if db.healthColorMode == "CLASS" then
            local classColor = DF:GetClassColor(testData.class)
            if classColor then
                frame.healthBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
            end
        elseif db.healthColorMode == "PERCENT" then
            local color = DF:GetHealthGradientColor(healthValue, db, testData.class)
            if color then
                frame.healthBar:SetStatusBarColor(color.r, color.g, color.b)
            end
        elseif db.healthColorMode == "CUSTOM" then
            local c = db.healthColor or {r=0, g=1, b=0}
            frame.healthBar:SetStatusBarColor(c.r, c.g, c.b)
        end
    end
    
    -- Apply combined alpha to health bar texture (classColorAlpha * OOR alpha)
    -- Dead fade overrides health bar alpha if applicable
    if frame.healthBar then
        local tex = frame.healthBar:GetStatusBarTexture()
        if tex then 
            local finalAlpha = classColorAlpha * healthBarAlpha
            if applyDeadFade then
                finalAlpha = db.fadeDeadHealthBar or 0.4
            end
            tex:SetAlpha(finalAlpha) 
        end
    end
    
    -- Update background color and texture
    local bgMode = db.backgroundColorMode or "CUSTOM"
    local bgTexture = db.backgroundTexture or "Solid"
    
    -- Determine background color for dead fade
    local deadBgColor = nil
    local deadBgAlpha = db.fadeDeadBackground or 0.4
    if applyDeadFade and db.fadeDeadUseCustomColor then
        deadBgColor = db.fadeDeadBackgroundColor or {r = 0.3, g = 0, b = 0}
    end
    
    if frame.background then
        -- In test mode, ALWAYS force-apply the texture to avoid cache inconsistencies
        -- Test mode doesn't update as frequently so performance is not a concern
        if bgTexture == "Solid" or bgTexture == "" then
            -- Solid color mode - use SetColorTexture
            frame.dfCurrentBgTexture = "Solid"
            
            if applyDeadFade and deadBgColor then
                -- Dead fade with custom color
                frame.background:SetColorTexture(deadBgColor.r, deadBgColor.g, deadBgColor.b, deadBgAlpha)
            elseif applyDeadFade then
                -- Dead fade without custom color - use normal color but with dead fade alpha
                if bgMode == "CUSTOM" then
                    local c = db.backgroundColor or {r=0.1, g=0.1, b=0.1, a=0.8}
                    frame.background:SetColorTexture(c.r, c.g, c.b, deadBgAlpha)
                elseif bgMode == "CLASS" then
                    local classColor = DF:GetClassColor(testData.class)
                    if classColor then
                        frame.background:SetColorTexture(classColor.r, classColor.g, classColor.b, deadBgAlpha)
                    else
                        frame.background:SetColorTexture(0, 0, 0, deadBgAlpha)
                    end
                else
                    frame.background:SetColorTexture(0, 0, 0, deadBgAlpha)
                end
            elseif bgMode == "CUSTOM" then
                local c = db.backgroundColor or {r=0.1, g=0.1, b=0.1, a=0.8}
                -- Multiply configured alpha by OOR alpha
                local finalAlpha = (c.a or 0.8) * backgroundAlpha
                frame.background:SetColorTexture(c.r, c.g, c.b, finalAlpha)
            elseif bgMode == "CLASS" then
                local classColor = DF:GetClassColor(testData.class)
                local bgAlpha = db.backgroundClassAlpha or 0.3
                local finalAlpha = bgAlpha * backgroundAlpha
                if classColor then
                    frame.background:SetColorTexture(classColor.r, classColor.g, classColor.b, finalAlpha)
                else
                    frame.background:SetColorTexture(0, 0, 0, 0.8 * backgroundAlpha)
                end
            else
                frame.background:SetColorTexture(0, 0, 0, 0.8 * backgroundAlpha)
            end
        else
            -- Textured background
            -- ALWAYS apply the texture in test mode (no caching) to ensure it's set correctly
            frame.background:SetTexture(bgTexture)
            frame.background:SetHorizTile(false)
            frame.background:SetVertTile(false)
            frame.dfCurrentBgTexture = bgTexture
            
            -- For textured backgrounds, SetAlpha MUST be 1.0 so vertex color alpha works
            frame.background:SetAlpha(1.0)
            
            -- Control alpha ONLY via SetVertexColor
            if applyDeadFade and deadBgColor then
                -- Dead fade with custom color
                frame.background:SetVertexColor(deadBgColor.r, deadBgColor.g, deadBgColor.b, deadBgAlpha)
            elseif applyDeadFade then
                -- Dead fade without custom color - use normal color but with dead fade alpha
                if bgMode == "CUSTOM" then
                    local c = db.backgroundColor or {r=0.1, g=0.1, b=0.1, a=0.8}
                    frame.background:SetVertexColor(c.r, c.g, c.b, deadBgAlpha)
                elseif bgMode == "CLASS" then
                    local classColor = DF:GetClassColor(testData.class)
                    if classColor then
                        frame.background:SetVertexColor(classColor.r, classColor.g, classColor.b, deadBgAlpha)
                    else
                        frame.background:SetVertexColor(0, 0, 0, deadBgAlpha)
                    end
                else
                    frame.background:SetVertexColor(0, 0, 0, deadBgAlpha)
                end
            elseif bgMode == "CUSTOM" then
                local c = db.backgroundColor or {r=0.1, g=0.1, b=0.1, a=0.8}
                local finalAlpha = (c.a or 0.8) * backgroundAlpha
                frame.background:SetVertexColor(c.r, c.g, c.b, finalAlpha)
            elseif bgMode == "CLASS" then
                local classColor = DF:GetClassColor(testData.class)
                local bgAlpha = db.backgroundClassAlpha or 0.3
                local finalAlpha = bgAlpha * backgroundAlpha
                if classColor then
                    frame.background:SetVertexColor(classColor.r, classColor.g, classColor.b, finalAlpha)
                else
                    frame.background:SetVertexColor(0, 0, 0, 0.8 * backgroundAlpha)
                end
            else
                frame.background:SetVertexColor(0, 0, 0, 0.8 * backgroundAlpha)
            end
        end
    end
    
    -- Frame-level alpha when not using element-specific OOR (same as live UpdateFrameAppearance)
    if not db.oorEnabled then
        if isOutOfRange then
            frame:SetAlpha(db.rangeFadeAlpha or db.rangeAlpha or 0.55)
        elseif isAboveHealthThreshold then
            frame:SetAlpha(db.healthFadeAlpha or 0.5)
        else
            frame:SetAlpha(1)
        end
    else
        frame:SetAlpha(1)
    end
    
    -- Apply alpha to health text
    if frame.healthText then
        if db.healthTextUseClassColor then
            local classColor = DF:GetClassColor(testData.class)
            if classColor then
                frame.healthText:SetTextColor(classColor.r, classColor.g, classColor.b, healthTextAlpha)
            end
        else
            local htc = db.healthTextColor or {r=1, g=1, b=1}
            frame.healthText:SetTextColor(htc.r, htc.g, htc.b, healthTextAlpha)
        end
    end
    
    -- Update absorb bars
    if db.testShowAbsorbs then
        DF:UpdateTestAbsorb(frame, testData)
        DF:UpdateTestHealAbsorb(frame, testData)
    else
        if frame.dfAbsorbBar then frame.dfAbsorbBar:Hide() end
        if frame.dfHealAbsorbBar then frame.dfHealAbsorbBar:Hide() end
        if frame.absorbOvershieldGlow then frame.absorbOvershieldGlow:Hide() end
        if frame.healAbsorbOvershieldGlow then frame.healAbsorbOvershieldGlow:Hide() end
        -- Hide attached textures used for ATTACHED mode test display
        if frame.absorbAttachedTexture then frame.absorbAttachedTexture:Hide() end
        if frame.healAbsorbAttachedTexture then frame.healAbsorbAttachedTexture:Hide() end
        -- Hide overflow bar
        if frame.absorbOverflowBar then frame.absorbOverflowBar:Hide() end
    end
    
    -- Update heal prediction (check test mode setting)
    if db.testShowHealPrediction ~= false then
        DF:UpdateTestHealPrediction(frame, testData)
    else
        if frame.dfHealPredictionBar then frame.dfHealPredictionBar:Hide() end
    end
    
    -- Update power/resource bar
    DF:UpdateTestPowerBar(frame, testData)
    
    -- Update test auras
    if db.testShowAuras then
        DF:UpdateTestAuras(frame)
    else
        if frame.buffIcons then
            for _, icon in ipairs(frame.buffIcons) do icon:Hide() end
        end
        if frame.debuffIcons then
            for _, icon in ipairs(frame.debuffIcons) do icon:Hide() end
        end
    end
    
    -- Update test boss debuffs (independent of testShowAuras - has its own testShowBossDebuffs toggle)
    DF:UpdateTestBossDebuffs(frame)
    
    -- Update status text (Dead, Offline, etc.)
    if testData.status then
        if db.statusTextEnabled ~= false then
            DF:StyleStatusText(frame)
            frame.statusText:SetText(testData.status)
            frame.statusText:Show()
            frame.healthText:Hide()
        end
        DF:ApplyDeadFade(frame, testData.status, true)  -- true = forceApply for test mode
        frame.dfTestOutOfRange = false
    else
        if frame.statusText then
            frame.statusText:Hide()
        end
        if db.showHealthText ~= false then
            frame.healthText:Show()
        end
        frame.dfDeadFadeApplied = false
        
        -- Apply out of range effect to auras
        local buffAlpha = db.buffAlpha or 1
        local debuffAlpha = db.debuffAlpha or 1
        if isOutOfRange then
            if frame.buffIcons then
                for _, icon in ipairs(frame.buffIcons) do
                    icon:SetAlpha(aurasAlpha * buffAlpha)
                end
            end
            if frame.debuffIcons then
                for _, icon in ipairs(frame.debuffIcons) do
                    icon:SetAlpha(aurasAlpha * debuffAlpha)
                end
            end
            frame.dfTestOutOfRange = true
        else
            if frame.buffIcons then
                for _, icon in ipairs(frame.buffIcons) do
                    icon:SetAlpha(buffAlpha)
                end
            end
            if frame.debuffIcons then
                for _, icon in ipairs(frame.debuffIcons) do
                    icon:SetAlpha(debuffAlpha)
                end
            end
            frame.dfTestOutOfRange = false
        end
    end
    
    -- Update test icons (role, leader, raid target)
    if db.testShowIcons ~= false then
        DF:UpdateTestIcons(frame, testData)
    else
        -- Hide only role/leader/target icons when disabled (not status icons)
        if frame.roleIcon then frame.roleIcon:Hide() end
        if frame.leaderIcon then frame.leaderIcon:Hide() end
        if frame.raidTargetIcon then frame.raidTargetIcon:Hide() end
    end
    
    -- Always update status icons (they have their own checkbox testShowStatusIcons)
    DF:UpdateTestStatusIcons(frame, testData)
    
    -- Update dispel overlay if enabled (uses real dispel system which has test mode support)
    -- OOR alpha is now handled inside UpdateDispelOverlay for test mode
    if db.testShowDispelGlow then
        if DF.UpdateDispelOverlay then
            DF:UpdateDispelOverlay(frame)
        end
    else
        -- Hide dispel overlay when test checkbox is off
        if frame.dfDispelOverlay then
            local overlay = frame.dfDispelOverlay
            if overlay.borderTop then overlay.borderTop:Hide() end
            if overlay.borderBottom then overlay.borderBottom:Hide() end
            if overlay.borderLeft then overlay.borderLeft:Hide() end
            if overlay.borderRight then overlay.borderRight:Hide() end
            if overlay.gradient then overlay.gradient:Hide() end
            if overlay.icons then
                for _, icon in pairs(overlay.icons) do
                    icon:Hide()
                end
            end
        end
    end
    
    -- Update missing buff icon if enabled
    if db.testShowMissingBuff then
        DF:UpdateTestMissingBuff(frame)
    else
        if frame.missingBuffFrame then
            frame.missingBuffFrame:Hide()
        end
    end
    
    -- Update defensive icon if enabled
    if db.testShowExternalDef then
        DF:UpdateTestDefensiveBar(frame, testData)
    else
        if frame.defensiveIcon then
            frame.defensiveIcon:Hide()
        end
    end
    
    -- Update class power pips for test mode
    if db.classPowerEnabled and db.testShowClassPower ~= false then
        if DF.UpdateTestClassPower then
            testData.index = index
            DF:UpdateTestClassPower(frame, testData)
        end
    else
        if DF.HideTestClassPower then
            DF:HideTestClassPower(frame)
        end
    end

    -- Update Aura Designer test indicators
    if db.testShowAuraDesigner and db.auraDesigner and db.auraDesigner.enabled then
        local ADEngine = DF.AuraDesigner and DF.AuraDesigner.Engine
        if ADEngine and ADEngine.UpdateTestFrame then
            ADEngine:UpdateTestFrame(frame)
        end
    else
        local ADEngine = DF.AuraDesigner and DF.AuraDesigner.Engine
        if ADEngine then ADEngine:ClearFrame(frame) end
    end

    -- Update selection and aggro highlights for test mode
    -- UpdateHighlights now handles test mode internally
    if DF.UpdateHighlights then
        DF:UpdateHighlights(frame)
    end
end

-- Update test icons for a frame (accepts testData directly for unified approach)
function DF:UpdateTestIcons(frame, testData)
    if not frame then return end
    if not testData then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Role Icon
    if frame.roleIcon then
        local role = testData.role
        local shouldShow = true
        
        -- In test mode (out of combat), if "Only Apply Settings in Combat" is checked, show all icons
        local applySettings = not db.roleIconOnlyInCombat
        
        if applySettings then
            if role == "TANK" then
                shouldShow = db.roleIconShowTank ~= false
            elseif role == "HEALER" then
                shouldShow = db.roleIconShowHealer ~= false
            elseif role == "DAMAGER" then
                shouldShow = db.roleIconShowDPS ~= false
            end
        end
        
        if shouldShow then
            local tex, l, r, t, b = DF:GetRoleIconTexture(db, role)
            frame.roleIcon.texture:SetTexture(tex)
            frame.roleIcon.texture:SetTexCoord(l, r, t, b)
            
            frame.roleIcon:Show()
            local scale = db.roleIconScale or 1.0
            local anchor = db.roleIconAnchor or "TOPLEFT"
            local x = db.roleIconX or 2
            local y = db.roleIconY or -2
            frame.roleIcon:SetScale(scale)
            frame.roleIcon:ClearAllPoints()
            frame.roleIcon:SetPoint(anchor, frame, anchor, x, y)
            
            -- Apply frame level
            local frameLevel = db.roleIconFrameLevel or 0
            if frameLevel > 0 then
                frame.roleIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
            end
        else
            frame.roleIcon:Hide()
        end
    end
    
    -- Leader Icon
    if frame.leaderIcon then
        if not db.leaderIconEnabled then
            frame.leaderIcon:Hide()
        elseif testData.isLeader then
            frame.leaderIcon.texture:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
            frame.leaderIcon.texture:SetTexCoord(0, 1, 0, 1)
            frame.leaderIcon:Show()
            
            local scale = db.leaderIconScale or 1.0
            local anchor = db.leaderIconAnchor or "TOPLEFT"
            local x = db.leaderIconX or -2
            local y = db.leaderIconY or 2
            frame.leaderIcon:SetScale(scale)
            frame.leaderIcon:ClearAllPoints()
            frame.leaderIcon:SetPoint(anchor, frame, anchor, x, y)
            
            -- Apply frame level
            local frameLevel = db.leaderIconFrameLevel or 0
            if frameLevel > 0 then
                frame.leaderIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
            end
        elseif testData.isAssist then
            frame.leaderIcon.texture:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
            frame.leaderIcon.texture:SetTexCoord(0, 1, 0, 1)
            frame.leaderIcon:Show()
            
            local scale = db.leaderIconScale or 1.0
            local anchor = db.leaderIconAnchor or "TOPLEFT"
            local x = db.leaderIconX or -2
            local y = db.leaderIconY or 2
            frame.leaderIcon:SetScale(scale)
            frame.leaderIcon:ClearAllPoints()
            frame.leaderIcon:SetPoint(anchor, frame, anchor, x, y)
            
            -- Apply frame level
            local frameLevel = db.leaderIconFrameLevel or 0
            if frameLevel > 0 then
                frame.leaderIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
            end
        else
            frame.leaderIcon:Hide()
        end
    end
    
    -- Raid Target Icon
    if frame.raidTargetIcon then
        if not db.raidTargetIconEnabled then
            frame.raidTargetIcon:Hide()
        elseif testData.raidTarget then
            frame.raidTargetIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
            SetRaidTargetIconTexture(frame.raidTargetIcon.texture, testData.raidTarget)
            
            local scale = db.raidTargetIconScale or 1.5
            local anchor = db.raidTargetIconAnchor or "TOP"
            local x = db.raidTargetIconX or 0
            local y = db.raidTargetIconY or 2
            frame.raidTargetIcon:SetScale(scale)
            frame.raidTargetIcon:ClearAllPoints()
            frame.raidTargetIcon:SetPoint(anchor, frame, anchor, x, y)
            frame.raidTargetIcon:Show()
            
            -- Apply frame level
            local frameLevel = db.raidTargetIconFrameLevel or 0
            if frameLevel > 0 then
                frame.raidTargetIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
            end
        else
            frame.raidTargetIcon:Hide()
        end
    end
    
    -- Ready Check Icon (show on leader frame only for demo)
    if frame.readyCheckIcon then
        if not db.readyCheckIconEnabled or db.testShowStatusIcons == false then
            frame.readyCheckIcon:Hide()
        elseif testData.isLeader then
            frame.readyCheckIcon.texture:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
            
            local scale = db.readyCheckIconScale or 1.0
            local anchor = db.readyCheckIconAnchor or "CENTER"
            local x = db.readyCheckIconX or 0
            local y = db.readyCheckIconY or 0
            frame.readyCheckIcon:SetScale(scale)
            frame.readyCheckIcon:ClearAllPoints()
            frame.readyCheckIcon:SetPoint(anchor, frame, anchor, x, y)
            frame.readyCheckIcon:Show()
            
            -- Apply frame level
            local frameLevel = db.readyCheckIconFrameLevel or 0
            if frameLevel > 0 then
                frame.readyCheckIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
            end
        else
            frame.readyCheckIcon:Hide()
        end
    end
    
    -- Center Status Icon (show if testData has centerStatus)
    if frame.centerStatusIcon then
        if not db.centerStatusIconEnabled or db.testShowStatusIcons == false then
            frame.centerStatusIcon:Hide()
        elseif testData.centerStatus then
            local texture = nil
            if testData.centerStatus == "resurrect" then
                texture = "Interface\\RaidFrame\\Raid-Icon-Rez"
            elseif testData.centerStatus == "summon" then
                texture = "Interface\\RaidFrame\\Raid-Icon-SummonPending"
            end
            
            if texture then
                frame.centerStatusIcon.texture:SetTexture(texture)
                
                local scale = db.centerStatusIconScale or 1.0
                local anchor = db.centerStatusIconAnchor or "CENTER"
                local x = db.centerStatusIconX or 0
                local y = db.centerStatusIconY or 0
                
                frame.centerStatusIcon:SetScale(scale)
                frame.centerStatusIcon:ClearAllPoints()
                frame.centerStatusIcon:SetPoint(anchor, frame, anchor, x, y)
                frame.centerStatusIcon:Show()
                
                -- Apply frame level
                local frameLevel = db.centerStatusIconFrameLevel or 0
                if frameLevel > 0 then
                    frame.centerStatusIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
                end
            else
                frame.centerStatusIcon:Hide()
            end
        else
            frame.centerStatusIcon:Hide()
        end
    end
    
    -- Apply alpha to icons - check dead fade first, then health-based fade, then OOR alpha
    local alpha = 1.0
    if frame.dfTestDeadFadeAlphas and frame.dfTestDeadFadeAlphas.icons then
        alpha = frame.dfTestDeadFadeAlphas.icons
    elseif frame.dfDeadFadeApplied then
        return
    elseif frame.dfTestHealthFadeAlphas and frame.dfTestHealthFadeAlphas.icons then
        alpha = frame.dfTestHealthFadeAlphas.icons
    elseif frame.dfTestOORAlphas and frame.dfTestOORAlphas.icons then
        alpha = frame.dfTestOORAlphas.icons
    end
    
    if frame.roleIcon and frame.roleIcon:IsShown() then
        frame.roleIcon:SetAlpha(alpha)
    end
    if frame.leaderIcon and frame.leaderIcon:IsShown() then
        frame.leaderIcon:SetAlpha(alpha)
    end
    if frame.raidTargetIcon and frame.raidTargetIcon:IsShown() then
        frame.raidTargetIcon:SetAlpha(alpha)
    end
    if frame.readyCheckIcon and frame.readyCheckIcon:IsShown() then
        frame.readyCheckIcon:SetAlpha(alpha)
    end
    if frame.centerStatusIcon and frame.centerStatusIcon:IsShown() then
        frame.centerStatusIcon:SetAlpha(alpha)
    end
end

-- Helper function to show icon as text or texture in test mode
local function ShowTestIconAsText(icon, text, showText, db, prefix)
    if not icon then return end
    if showText then
        if icon.texture then icon.texture:Hide() end
        if icon.text then
            icon.text:SetText(text)
            
            -- Apply font settings if db is provided
            if db then
                local font = db.statusIconFont or "Fonts\\FRIZQT__.TTF"
                local fontSize = db.statusIconFontSize or 12
                local outline = db.statusIconFontOutline or "OUTLINE"
                
                -- Handle SHADOW and NONE outlines (WoW SetFont rejects "NONE")
                local actualOutline = outline
                if outline == "SHADOW" or outline == "NONE" then
                    actualOutline = ""
                end
                
                -- Get font path from SharedMedia if available
                local fontPath = font
                if DF.GetFont then
                    fontPath = DF:GetFont(font) or font
                end
                
                icon.text:SetFont(fontPath, fontSize, actualOutline)
                
                -- Apply shadow if needed
                if outline == "SHADOW" then
                    local shadowX = db.fontShadowOffsetX or 1
                    local shadowY = db.fontShadowOffsetY or -1
                    local shadowColor = db.fontShadowColor or {r = 0, g = 0, b = 0, a = 1}
                    icon.text:SetShadowOffset(shadowX, shadowY)
                    icon.text:SetShadowColor(shadowColor.r or 0, shadowColor.g or 0, shadowColor.b or 0, shadowColor.a or 1)
                else
                    icon.text:SetShadowOffset(0, 0)
                end
                
                -- Apply text color if prefix is provided
                if prefix then
                    local textColor = db[prefix .. "TextColor"]
                    if textColor then
                        icon.text:SetTextColor(textColor.r or 1, textColor.g or 1, textColor.b or 1, 1)
                    end
                end
            end
            
            icon.text:Show()
        end
    else
        if icon.text then icon.text:Hide() end
        if icon.texture then icon.texture:Show() end
    end
end

-- Also apply font/color to timer text (for AFK icon)
local function ApplyTestIconTimerFont(icon, db, prefix)
    if not icon or not icon.timerText or not db then return end
    
    local font = db.statusIconFont or "Fonts\\FRIZQT__.TTF"
    local fontSize = (db.statusIconFontSize or 12) - 2  -- Slightly smaller for timer
    local outline = db.statusIconFontOutline or "OUTLINE"
    
    local actualOutline = outline
    if outline == "SHADOW" or outline == "NONE" then
        actualOutline = ""
    end

    local fontPath = font
    if DF.GetFont then
        fontPath = DF:GetFont(font) or font
    end

    icon.timerText:SetFont(fontPath, fontSize, actualOutline)

    if outline == "SHADOW" then
        local shadowX = db.fontShadowOffsetX or 1
        local shadowY = db.fontShadowOffsetY or -1
        local shadowColor = db.fontShadowColor or {r = 0, g = 0, b = 0, a = 1}
        icon.timerText:SetShadowOffset(shadowX, shadowY)
        icon.timerText:SetShadowColor(shadowColor.r or 0, shadowColor.g or 0, shadowColor.b or 0, shadowColor.a or 1)
    else
        icon.timerText:SetShadowOffset(0, 0)
    end
    
    -- Timer text uses same color as main text
    if prefix then
        local textColor = db[prefix .. "TextColor"]
        if textColor then
            icon.timerText:SetTextColor(textColor.r or 1, textColor.g or 1, textColor.b or 1, 1)
        end
    end
end

-- Format seconds as M:SS for AFK timer
local function FormatTestAFKTime(seconds)
    if seconds < 3600 then
        return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
    else
        local hours = math.floor(seconds / 3600)
        local mins = math.floor((seconds % 3600) / 60)
        return string.format("%d:%02d:%02d", hours, mins, seconds % 60)
    end
end

-- Track test AFK start times
local testAFKStartTimes = {}

-- Update only status icons (ready check, center status) - separated from role/leader icons
function DF:UpdateTestStatusIcons(frame, testData)
    if not frame then return end
    if not testData then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Ready Check Icon (show on leader frame only for demo)
    if frame.readyCheckIcon then
        if not db.readyCheckIconEnabled or db.testShowStatusIcons == false then
            frame.readyCheckIcon:Hide()
        elseif testData.isLeader then
            frame.readyCheckIcon.texture:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
            
            local scale = db.readyCheckIconScale or 1.0
            local anchor = db.readyCheckIconAnchor or "CENTER"
            local x = db.readyCheckIconX or 0
            local y = db.readyCheckIconY or 0
            frame.readyCheckIcon:SetScale(scale)
            frame.readyCheckIcon:ClearAllPoints()
            frame.readyCheckIcon:SetPoint(anchor, frame, anchor, x, y)
            frame.readyCheckIcon:SetAlpha(db.readyCheckIconAlpha or 1)
            frame.readyCheckIcon:Show()
            
            -- Apply frame level
            local frameLevel = db.readyCheckIconFrameLevel or 0
            if frameLevel > 0 then
                frame.readyCheckIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
            end
        else
            frame.readyCheckIcon:Hide()
        end
    end
    
    -- Summon Icon
    if frame.summonIcon then
        if not db.summonIconEnabled or db.testShowStatusIcons == false then
            frame.summonIcon:Hide()
        elseif testData.centerStatus == "summon" then
            frame.summonIcon.texture:SetTexture("Interface\\RaidFrame\\Raid-Icon-SummonPending")
            
            local scale = db.summonIconScale or 1.0
            local anchor = db.summonIconAnchor or "CENTER"
            local x = db.summonIconX or 0
            local y = db.summonIconY or 0
            frame.summonIcon:SetScale(scale)
            frame.summonIcon:ClearAllPoints()
            frame.summonIcon:SetPoint(anchor, frame, anchor, x, y)
            frame.summonIcon:SetAlpha(db.summonIconAlpha or 1)
            
            -- Show as text or icon (with font and color settings)
            ShowTestIconAsText(frame.summonIcon, db.summonIconTextPending or "Summon", db.summonIconShowText, db, "summonIcon")
            frame.summonIcon:Show()
            
            local frameLevel = db.summonIconFrameLevel or 0
            if frameLevel > 0 then
                frame.summonIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
            end
        else
            frame.summonIcon:Hide()
        end
    end
    
    -- Resurrection Icon
    if frame.resurrectionIcon then
        if not db.resurrectionIconEnabled or db.testShowStatusIcons == false then
            frame.resurrectionIcon:Hide()
        elseif testData.centerStatus == "resurrect" then
            frame.resurrectionIcon.texture:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
            frame.resurrectionIcon.texture:SetVertexColor(0, 1, 0)  -- Green = being cast
            
            local scale = db.resurrectionIconScale or 1.0
            local anchor = db.resurrectionIconAnchor or "CENTER"
            local x = db.resurrectionIconX or 0
            local y = db.resurrectionIconY or 0
            frame.resurrectionIcon:SetScale(scale)
            frame.resurrectionIcon:ClearAllPoints()
            frame.resurrectionIcon:SetPoint(anchor, frame, anchor, x, y)
            frame.resurrectionIcon:SetAlpha(db.resurrectionIconAlpha or 1)
            
            -- Show as text or icon (with font and color settings)
            ShowTestIconAsText(frame.resurrectionIcon, db.resurrectionIconTextCasting or "Res...", db.resurrectionIconShowText, db, "resurrectionIcon")
            frame.resurrectionIcon:Show()
            
            local frameLevel = db.resurrectionIconFrameLevel or 0
            if frameLevel > 0 then
                frame.resurrectionIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
            end
        else
            frame.resurrectionIcon:Hide()
        end
    end
    
    -- Phased Icon
    if frame.phasedIcon then
        if not db.phasedIconEnabled or db.testShowStatusIcons == false then
            frame.phasedIcon:Hide()
        elseif testData.isPhased then
            frame.phasedIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
            
            local scale = db.phasedIconScale or 1.0
            local anchor = db.phasedIconAnchor or "TOPRIGHT"
            local x = db.phasedIconX or 0
            local y = db.phasedIconY or 0
            frame.phasedIcon:SetScale(scale)
            frame.phasedIcon:ClearAllPoints()
            frame.phasedIcon:SetPoint(anchor, frame, anchor, x, y)
            frame.phasedIcon:SetAlpha(db.phasedIconAlpha or 1)
            
            -- Show as text or icon (with font and color settings)
            ShowTestIconAsText(frame.phasedIcon, db.phasedIconText or "Phased", db.phasedIconShowText, db, "phasedIcon")
            frame.phasedIcon:Show()
            
            local frameLevel = db.phasedIconFrameLevel or 0
            if frameLevel > 0 then
                frame.phasedIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
            end
        else
            frame.phasedIcon:Hide()
        end
    end
    
    -- AFK Icon with timer support
    if frame.afkIcon then
        if not db.afkIconEnabled or db.testShowStatusIcons == false then
            frame.afkIcon:Hide()
            if frame.afkIcon.timerText then frame.afkIcon.timerText:Hide() end
        elseif testData.isAFK then
            frame.afkIcon.texture:SetTexture("Interface\\FriendsFrame\\StatusIcon-Away")
            
            local scale = db.afkIconScale or 1.0
            local anchor = db.afkIconAnchor or "CENTER"
            local x = db.afkIconX or 0
            local y = db.afkIconY or 0
            frame.afkIcon:SetScale(scale)
            frame.afkIcon:ClearAllPoints()
            frame.afkIcon:SetPoint(anchor, frame, anchor, x, y)
            frame.afkIcon:SetAlpha(db.afkIconAlpha or 1)
            
            -- Track AFK start time for test mode
            local frameKey = tostring(frame)
            if not testAFKStartTimes[frameKey] then
                testAFKStartTimes[frameKey] = GetTime()
            end
            
            local statusText = db.afkIconText or "AFK"
            local showTimer = db.afkIconShowTimer ~= false
            
            -- Calculate timer if enabled
            if showTimer and testAFKStartTimes[frameKey] then
                local elapsed = math.floor(GetTime() - testAFKStartTimes[frameKey])
                local timerStr = FormatTestAFKTime(elapsed)
                
                if db.afkIconShowText then
                    -- Text mode: show "AFK 1:23"
                    statusText = statusText .. " " .. timerStr
                    if frame.afkIcon.timerText then frame.afkIcon.timerText:Hide() end
                else
                    -- Icon mode: show timer below icon
                    if frame.afkIcon.timerText then
                        frame.afkIcon.timerText:SetText(timerStr)
                        frame.afkIcon.timerText:Show()
                        -- Apply font/color to timer text
                        ApplyTestIconTimerFont(frame.afkIcon, db, "afkIcon")
                    end
                end
            else
                if frame.afkIcon.timerText then frame.afkIcon.timerText:Hide() end
            end
            
            -- Show as text or icon (with font and color settings)
            ShowTestIconAsText(frame.afkIcon, statusText, db.afkIconShowText, db, "afkIcon")
            frame.afkIcon:Show()
            
            local frameLevel = db.afkIconFrameLevel or 0
            if frameLevel > 0 then
                frame.afkIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
            end
        else
            frame.afkIcon:Hide()
            if frame.afkIcon.timerText then frame.afkIcon.timerText:Hide() end
            -- Clear AFK start time
            testAFKStartTimes[tostring(frame)] = nil
        end
    end
    
    -- Vehicle Icon
    if frame.vehicleIcon then
        if not db.vehicleIconEnabled or db.testShowStatusIcons == false then
            frame.vehicleIcon:Hide()
        elseif testData.inVehicle then
            frame.vehicleIcon.texture:SetTexture("Interface\\Vehicles\\UI-Vehicles-Raid-Icon")
            
            local scale = db.vehicleIconScale or 1.0
            local anchor = db.vehicleIconAnchor or "BOTTOMRIGHT"
            local x = db.vehicleIconX or 0
            local y = db.vehicleIconY or 0
            frame.vehicleIcon:SetScale(scale)
            frame.vehicleIcon:ClearAllPoints()
            frame.vehicleIcon:SetPoint(anchor, frame, anchor, x, y)
            frame.vehicleIcon:SetAlpha(db.vehicleIconAlpha or 1)
            
            -- Show as text or icon (with font and color settings)
            ShowTestIconAsText(frame.vehicleIcon, db.vehicleIconText or "Vehicle", db.vehicleIconShowText, db, "vehicleIcon")
            frame.vehicleIcon:Show()
            
            local frameLevel = db.vehicleIconFrameLevel or 0
            if frameLevel > 0 then
                frame.vehicleIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
            end
        else
            frame.vehicleIcon:Hide()
        end
    end
    
    -- Raid Role Icon (MT/MA)
    if frame.raidRoleIcon then
        if not db.raidRoleIconEnabled or db.testShowStatusIcons == false then
            frame.raidRoleIcon:Hide()
        elseif testData.isMainTank and db.raidRoleIconShowTank ~= false then
            frame.raidRoleIcon.texture:SetTexture("Interface\\GroupFrame\\UI-Group-MainTankIcon")
            
            local scale = db.raidRoleIconScale or 1.0
            local anchor = db.raidRoleIconAnchor or "BOTTOMLEFT"
            local x = db.raidRoleIconX or 0
            local y = db.raidRoleIconY or 0
            frame.raidRoleIcon:SetScale(scale)
            frame.raidRoleIcon:ClearAllPoints()
            frame.raidRoleIcon:SetPoint(anchor, frame, anchor, x, y)
            frame.raidRoleIcon:SetAlpha(db.raidRoleIconAlpha or 1)
            
            -- Show as text or icon (with font and color settings)
            ShowTestIconAsText(frame.raidRoleIcon, db.raidRoleIconTextTank or "MT", db.raidRoleIconShowText, db, "raidRoleIcon")
            frame.raidRoleIcon:Show()
            
            local frameLevel = db.raidRoleIconFrameLevel or 0
            if frameLevel > 0 then
                frame.raidRoleIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
            end
        elseif testData.isMainAssist and db.raidRoleIconShowAssist ~= false then
            frame.raidRoleIcon.texture:SetTexture("Interface\\GroupFrame\\UI-Group-MainAssistIcon")
            
            local scale = db.raidRoleIconScale or 1.0
            local anchor = db.raidRoleIconAnchor or "BOTTOMLEFT"
            local x = db.raidRoleIconX or 0
            local y = db.raidRoleIconY or 0
            frame.raidRoleIcon:SetScale(scale)
            frame.raidRoleIcon:ClearAllPoints()
            frame.raidRoleIcon:SetPoint(anchor, frame, anchor, x, y)
            frame.raidRoleIcon:SetAlpha(db.raidRoleIconAlpha or 1)
            
            -- Show as text or icon (with font and color settings)
            ShowTestIconAsText(frame.raidRoleIcon, db.raidRoleIconTextAssist or "MA", db.raidRoleIconShowText, db, "raidRoleIcon")
            frame.raidRoleIcon:Show()
            
            local frameLevel = db.raidRoleIconFrameLevel or 0
            if frameLevel > 0 then
                frame.raidRoleIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
            end
        else
            frame.raidRoleIcon:Hide()
        end
    end
    
    -- Legacy Center Status Icon (for backward compatibility)
    -- Only show if individual summon/res icons are disabled
    if frame.centerStatusIcon then
        local showCenterStatus = db.centerStatusIconEnabled and db.testShowStatusIcons ~= false
        -- Don't show centerStatus for summon if summonIcon is enabled
        if testData.centerStatus == "summon" and db.summonIconEnabled then
            showCenterStatus = false
        end
        -- Don't show centerStatus for resurrect if resurrectionIcon is enabled
        if testData.centerStatus == "resurrect" and db.resurrectionIconEnabled then
            showCenterStatus = false
        end
        
        if not showCenterStatus then
            frame.centerStatusIcon:Hide()
        elseif testData.centerStatus then
            local texture = nil
            if testData.centerStatus == "resurrect" then
                texture = "Interface\\RaidFrame\\Raid-Icon-Rez"
            elseif testData.centerStatus == "summon" then
                texture = "Interface\\RaidFrame\\Raid-Icon-SummonPending"
            end
            
            if texture then
                frame.centerStatusIcon.texture:SetTexture(texture)
                
                local scale = db.centerStatusIconScale or 1.0
                local anchor = db.centerStatusIconAnchor or "CENTER"
                local x = db.centerStatusIconX or 0
                local y = db.centerStatusIconY or 0
                
                frame.centerStatusIcon:SetScale(scale)
                frame.centerStatusIcon:ClearAllPoints()
                frame.centerStatusIcon:SetPoint(anchor, frame, anchor, x, y)
                frame.centerStatusIcon:Show()
                
                -- Apply frame level
                local frameLevel = db.centerStatusIconFrameLevel or 0
                if frameLevel > 0 then
                    frame.centerStatusIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
                end
            else
                frame.centerStatusIcon:Hide()
            end
        else
            frame.centerStatusIcon:Hide()
        end
    end
    
    -- Apply alpha to status icons based on dead / health-based / OOR fade
    local alpha = 1.0
    if frame.dfTestDeadFadeAlphas and frame.dfTestDeadFadeAlphas.icons then
        alpha = frame.dfTestDeadFadeAlphas.icons
    elseif frame.dfDeadFadeApplied then
        return
    elseif frame.dfTestHealthFadeAlphas and frame.dfTestHealthFadeAlphas.icons then
        alpha = frame.dfTestHealthFadeAlphas.icons
    elseif frame.dfTestOORAlphas and frame.dfTestOORAlphas.icons then
        alpha = frame.dfTestOORAlphas.icons
    end
    
    -- Apply fade alpha to all status icons
    if frame.readyCheckIcon and frame.readyCheckIcon:IsShown() then
        local baseAlpha = db.readyCheckIconAlpha or 1
        frame.readyCheckIcon:SetAlpha(baseAlpha * alpha)
    end
    if frame.summonIcon and frame.summonIcon:IsShown() then
        local baseAlpha = db.summonIconAlpha or 1
        frame.summonIcon:SetAlpha(baseAlpha * alpha)
    end
    if frame.resurrectionIcon and frame.resurrectionIcon:IsShown() then
        local baseAlpha = db.resurrectionIconAlpha or 1
        frame.resurrectionIcon:SetAlpha(baseAlpha * alpha)
    end
    if frame.phasedIcon and frame.phasedIcon:IsShown() then
        local baseAlpha = db.phasedIconAlpha or 1
        frame.phasedIcon:SetAlpha(baseAlpha * alpha)
    end
    if frame.afkIcon and frame.afkIcon:IsShown() then
        local baseAlpha = db.afkIconAlpha or 1
        frame.afkIcon:SetAlpha(baseAlpha * alpha)
    end
    if frame.vehicleIcon and frame.vehicleIcon:IsShown() then
        local baseAlpha = db.vehicleIconAlpha or 1
        frame.vehicleIcon:SetAlpha(baseAlpha * alpha)
    end
    if frame.raidRoleIcon and frame.raidRoleIcon:IsShown() then
        local baseAlpha = db.raidRoleIconAlpha or 1
        frame.raidRoleIcon:SetAlpha(baseAlpha * alpha)
    end
    if frame.centerStatusIcon and frame.centerStatusIcon:IsShown() then
        frame.centerStatusIcon:SetAlpha(alpha)
    end
end

-- Lightweight aura update - only updates content, not layout
-- Layout is only applied when frame.dfTestApplyLayout is true
function DF:UpdateTestAuras(frame)
    if not frame then return end
    
    -- Apply layout only if explicitly requested (e.g., on test mode start)
    if frame.dfTestApplyLayout then
        local db = DF:GetFrameDB(frame)
        DF:ApplyAuraLayout(frame, "BUFF")
        DF:ApplyAuraLayout(frame, "DEBUFF")
        frame.dfTestApplyLayout = nil  -- Clear flag after applying
    end
    
    DF:UpdateTestAurasContent(frame)
end

-- Update test aura content only (no layout changes)
function DF:UpdateTestAurasContent(frame)
    if not frame then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Ensure aura layouts are applied (fonts set) before using icons
    -- This is a safety check in case frames were created before fonts were ready
    if frame.buffIcons and frame.buffIcons[1] then
        local testIcon = frame.buffIcons[1]
        if testIcon.count then
            local hasFont = false
            local success, result = pcall(function() return testIcon.count:GetFont() end)
            if success and result then
                hasFont = true
            end
            if not hasFont then
                -- Fonts not set yet, apply aura layout now
                DF:ApplyAuraLayout(frame, "BUFF")
                DF:ApplyAuraLayout(frame, "DEBUFF")
            end
        end
    end
    
    -- Show test buffs - use testBuffCount to limit how many are shown
    local maxBuffs = db.buffMax or 4
    local testBuffCount = db.testBuffCount or 3
    local buffLimit = math.min(testBuffCount, #DF.TestData.buffs, maxBuffs)
    
    if frame.buffIcons then
        for i, icon in ipairs(frame.buffIcons) do
            local buffData = DF.TestData.buffs[i]
            if buffData and i <= buffLimit and db.showBuffs ~= false then
                icon.texture:SetTexture(buffData.icon)
                
                -- Ensure count FontString has a font before calling SetText
                if icon.count then
                    local hasFont = false
                    local success, result = pcall(function() return icon.count:GetFont() end)
                    if success and result then hasFont = true end
                    if not hasFont then
                        DF:SafeSetFont(icon.count, "Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
                    end
                    
                    if buffData.stacks and buffData.stacks > 1 then
                        icon.count:SetText(buffData.stacks)
                    else
                        icon.count:SetText("")
                    end
                end
                -- Set a fake cooldown for visual effect
                if icon.cooldown and buffData.duration then
                    local startTime = GetTime() - (buffData.duration * 0.3)
                    icon.cooldown:SetCooldown(startTime, buffData.duration)
                    
                    -- Apply swipe visibility from settings
                    local hideSwipe = db.buffHideSwipe or false
                    icon.cooldown:SetDrawSwipe(not hideSwipe)
                    
                    -- Apply duration visibility from settings
                    local showDuration = db.buffShowDuration ~= false
                    icon.cooldown:SetHideCountdownNumbers(not showDuration)
                    
                    -- Discover native cooldown text if not already cached
                    if not icon.nativeCooldownText then
                        local regions = {icon.cooldown:GetRegions()}
                        for _, region in ipairs(regions) do
                            if region and region.GetObjectType and region:GetObjectType() == "FontString" then
                                icon.nativeCooldownText = region
                                icon.nativeTextReparented = false
                                break
                            end
                        end
                    end
                    
                    -- Apply duration text styling from settings
                    if icon.nativeCooldownText then
                        -- Hide/show based on setting
                        if not showDuration then
                            icon.nativeCooldownText:Hide()
                        else
                            icon.nativeCooldownText:Show()
                            
                            local durationScale = db.buffDurationScale or 1.0
                            local durationFont = db.buffDurationFont or "Fonts\\FRIZQT__.TTF"
                            local durationOutline = db.buffDurationOutline or "OUTLINE"
                            if durationOutline == "NONE" then durationOutline = "" end
                            local durationX = db.buffDurationX or 0
                            local durationY = db.buffDurationY or 0
                            local durationAnchor = db.buffDurationAnchor or "CENTER"
                            local durationSize = 10 * durationScale
                            
                            DF:SafeSetFont(icon.nativeCooldownText, durationFont, durationSize, durationOutline)
                            icon.nativeCooldownText:ClearAllPoints()
                            icon.nativeCooldownText:SetPoint(durationAnchor, icon, durationAnchor, durationX, durationY)
                            
                            -- Reparent to textOverlay if needed (above swipe)
                            if icon.textOverlay and not icon.nativeTextReparented then
                                icon.nativeCooldownText:SetParent(icon.textOverlay)
                                icon.nativeTextReparented = true
                            end
                            
                            -- Apply color - either fixed or by time remaining
                            if db.buffDurationColorByTime then
                                -- Calculate remaining percentage for color (30% elapsed = 70% remaining)
                                local percentRemaining = 0.7
                                local r, g, b = DF:GetDurationColorByPercent(percentRemaining)
                                icon.nativeCooldownText:SetTextColor(r, g, b, 1)
                            else
                                local durationColor = db.buffDurationColor or {r = 1, g = 1, b = 1}
                                icon.nativeCooldownText:SetTextColor(durationColor.r, durationColor.g, durationColor.b, 1)
                            end
                        end
                    end
                end
                
                -- Border visibility
                if icon.border then
                    if db.buffBorderEnabled ~= false then
                        icon.border:SetColorTexture(0, 0, 0, 0.8)
                        icon.border:Show()
                    else
                        icon.border:Hide()
                    end
                end
                
                -- Expiring indicators for test mode (simulate based on elapsed time)
                -- In test mode, show expiring indicator on first buff regardless of buffExpiringEnabled
                -- so users can preview what it looks like
                local isExpiring = (i == 1)  -- First buff shows as expiring for testing
                
                -- Tint overlay - show in test mode if tint is enabled (regardless of master switch)
                local showTint = isExpiring and db.buffExpiringTintEnabled
                if icon.expiringTint and showTint then
                    local tc = db.buffExpiringTintColor or {r = 1, g = 0.3, b = 0.3, a = 0.3}
                    icon.expiringTint:SetColorTexture(tc.r, tc.g, tc.b, tc.a)
                    icon.expiringTint:Show()
                elseif icon.expiringTint then
                    icon.expiringTint:Hide()
                end
                
                -- Border - show in test mode if border is enabled (regardless of master switch)
                local showBorder = isExpiring and db.buffExpiringBorderEnabled
                if icon.expiringBorderAlphaContainer and showBorder then
                    local bc = db.buffExpiringBorderColor or {r = 1, g = 0.5, b = 0, a = 1}
                    if icon.expiringBorderTop then
                        icon.expiringBorderTop:SetColorTexture(bc.r, bc.g, bc.b, bc.a or 1)
                        icon.expiringBorderBottom:SetColorTexture(bc.r, bc.g, bc.b, bc.a or 1)
                        icon.expiringBorderLeft:SetColorTexture(bc.r, bc.g, bc.b, bc.a or 1)
                        icon.expiringBorderRight:SetColorTexture(bc.r, bc.g, bc.b, bc.a or 1)
                    end
                    icon.expiringBorderAlphaContainer:SetAlpha(1)
                    icon.expiringBorderAlphaContainer:Show()
                    
                    -- Pulsate animation
                    if db.buffExpiringBorderPulsate and icon.expiringBorderPulse then
                        if not icon.expiringBorderPulse:IsPlaying() then
                            icon.expiringBorderPulse:Play()
                        end
                    elseif icon.expiringBorderPulse and icon.expiringBorderPulse:IsPlaying() then
                        icon.expiringBorderPulse:Stop()
                        icon.expiringBorderContainer:SetAlpha(1)
                    end
                elseif icon.expiringBorderAlphaContainer then
                    icon.expiringBorderAlphaContainer:Hide()
                    if icon.expiringBorderPulse and icon.expiringBorderPulse:IsPlaying() then
                        icon.expiringBorderPulse:Stop()
                    end
                end
                
                icon.testAuraData = buffData
                icon:Show()
            else
                icon.testAuraData = nil
                if icon.expiringTint then icon.expiringTint:Hide() end
                if icon.expiringBorderAlphaContainer then
                    icon.expiringBorderAlphaContainer:Hide()
                    if icon.expiringBorderPulse and icon.expiringBorderPulse:IsPlaying() then
                        icon.expiringBorderPulse:Stop()
                    end
                end
                icon:Hide()
            end
        end
    end
    
    -- Show test debuffs - use testDebuffCount to limit how many are shown
    local maxDebuffs = db.debuffMax or 4
    local testDebuffCount = db.testDebuffCount or 3
    local debuffLimit = math.min(testDebuffCount, #DF.TestData.debuffs, maxDebuffs)
    
    if frame.debuffIcons then
        for i, icon in ipairs(frame.debuffIcons) do
            local debuffData = DF.TestData.debuffs[i]
            if debuffData and i <= debuffLimit and db.showDebuffs ~= false then
                icon.texture:SetTexture(debuffData.icon)
                -- Store debuff type for lightweight color updates
                icon.debuffType = debuffData.debuffType
                
                -- Ensure count FontString has a font before calling SetText
                if icon.count then
                    local hasFont = false
                    local success, result = pcall(function() return icon.count:GetFont() end)
                    if success and result then hasFont = true end
                    if not hasFont then
                        DF:SafeSetFont(icon.count, "Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
                    end
                    
                    if debuffData.stacks and debuffData.stacks > 1 then
                        icon.count:SetText(debuffData.stacks)
                    else
                        icon.count:SetText("")
                    end
                end
                
                -- Border visibility and color
                if icon.border then
                    if db.debuffBorderEnabled ~= false then
                        -- Use custom dispel type colors if enabled
                        if db.debuffBorderColorByType ~= false then
                            local dispelName = debuffData.debuffType
                            local color
                            if dispelName == "Magic" then
                                color = db.debuffBorderColorMagic or {r = 0.2, g = 0.6, b = 1.0}
                            elseif dispelName == "Curse" then
                                color = db.debuffBorderColorCurse or {r = 0.6, g = 0.0, b = 1.0}
                            elseif dispelName == "Disease" then
                                color = db.debuffBorderColorDisease or {r = 0.6, g = 0.4, b = 0.0}
                            elseif dispelName == "Poison" then
                                color = db.debuffBorderColorPoison or {r = 0.0, g = 0.6, b = 0.0}
                            elseif dispelName == "Bleed" or dispelName == "Enrage" then
                                color = db.debuffBorderColorBleed or {r = 1.0, g = 0.0, b = 0.0}
                            else
                                color = db.debuffBorderColorNone or {r = 0.8, g = 0.0, b = 0.0}
                            end
                            icon.border:SetColorTexture(color.r, color.g, color.b, 0.8)
                        else
                            icon.border:SetColorTexture(0.8, 0, 0, 0.8)
                        end
                        icon.border:Show()
                    else
                        icon.border:Hide()
                    end
                end
                
                -- Set a fake cooldown for visual effect
                if icon.cooldown and debuffData.duration then
                    local startTime = GetTime() - (debuffData.duration * 0.5)
                    icon.cooldown:SetCooldown(startTime, debuffData.duration)
                    
                    -- Apply swipe visibility from settings
                    local hideSwipe = db.debuffHideSwipe or false
                    icon.cooldown:SetDrawSwipe(not hideSwipe)
                    
                    -- Apply duration visibility from settings
                    local showDuration = db.debuffShowDuration ~= false
                    icon.cooldown:SetHideCountdownNumbers(not showDuration)
                    
                    -- Discover native cooldown text if not already cached
                    if not icon.nativeCooldownText then
                        local regions = {icon.cooldown:GetRegions()}
                        for _, region in ipairs(regions) do
                            if region and region.GetObjectType and region:GetObjectType() == "FontString" then
                                icon.nativeCooldownText = region
                                icon.nativeTextReparented = false
                                break
                            end
                        end
                    end
                    
                    -- Apply duration text styling from settings
                    if icon.nativeCooldownText then
                        -- Hide/show based on setting
                        if not showDuration then
                            icon.nativeCooldownText:Hide()
                        else
                            icon.nativeCooldownText:Show()
                            
                            local durationScale = db.debuffDurationScale or 1.0
                            local durationFont = db.debuffDurationFont or "Fonts\\FRIZQT__.TTF"
                            local durationOutline = db.debuffDurationOutline or "OUTLINE"
                            if durationOutline == "NONE" then durationOutline = "" end
                            local durationX = db.debuffDurationX or 0
                            local durationY = db.debuffDurationY or 0
                            local durationAnchor = db.debuffDurationAnchor or "CENTER"
                            local durationSize = 10 * durationScale
                            
                            DF:SafeSetFont(icon.nativeCooldownText, durationFont, durationSize, durationOutline)
                            icon.nativeCooldownText:ClearAllPoints()
                            icon.nativeCooldownText:SetPoint(durationAnchor, icon, durationAnchor, durationX, durationY)
                            
                            -- Reparent to textOverlay if needed (above swipe)
                            if icon.textOverlay and not icon.nativeTextReparented then
                                icon.nativeCooldownText:SetParent(icon.textOverlay)
                                icon.nativeTextReparented = true
                            end
                            
                            -- Apply color - either fixed or by time remaining
                            if db.debuffDurationColorByTime then
                                -- Calculate remaining percentage for color (50% elapsed = 50% remaining)
                                local percentRemaining = 0.5
                                local r, g, b = DF:GetDurationColorByPercent(percentRemaining)
                                icon.nativeCooldownText:SetTextColor(r, g, b, 1)
                            else
                                local durationColor = db.debuffDurationColor or {r = 1, g = 1, b = 1}
                                icon.nativeCooldownText:SetTextColor(durationColor.r, durationColor.g, durationColor.b, 1)
                            end
                        end
                    end
                end
                
                -- Hide expiring indicators for debuffs (not supported)
                if icon.expiringTint then icon.expiringTint:Hide() end
                if icon.expiringBorderAlphaContainer then
                    icon.expiringBorderAlphaContainer:Hide()
                    if icon.expiringBorderPulse and icon.expiringBorderPulse:IsPlaying() then
                        icon.expiringBorderPulse:Stop()
                    end
                end
                
                icon.testAuraData = debuffData
                icon:Show()
            else
                icon.testAuraData = nil
                if icon.expiringTint then icon.expiringTint:Hide() end
                if icon.expiringBorderAlphaContainer then
                    icon.expiringBorderAlphaContainer:Hide()
                    if icon.expiringBorderPulse and icon.expiringBorderPulse:IsPlaying() then
                        icon.expiringBorderPulse:Stop()
                    end
                end
                icon:Hide()
            end
        end
        
        -- Store displayed count and reposition for center growth
        frame.debuffDisplayedCount = debuffLimit
        local debuffGrowth = db.debuffGrowth or "RIGHT_UP"
        local debuffPrimary = strsplit("_", debuffGrowth)
        if debuffPrimary == "CENTER" and debuffLimit > 0 and DF.RepositionCenterGrowthIcons then
            DF:RepositionCenterGrowthIcons(frame, frame.debuffIcons, "DEBUFF", debuffLimit)
        end
    end
    
    -- Also store buff count and reposition (buff loop is earlier, do it here for consistency)
    if frame.buffIcons then
        frame.buffDisplayedCount = buffLimit
        local buffGrowth = db.buffGrowth or "LEFT_UP"
        local buffPrimary = strsplit("_", buffGrowth)
        if buffPrimary == "CENTER" and buffLimit > 0 and DF.RepositionCenterGrowthIcons then
            DF:RepositionCenterGrowthIcons(frame, frame.buffIcons, "BUFF", buffLimit)
        end
    end
end

-- Update test boss debuffs (simulated Private Auras)
-- Uses the real SetupPrivateAuraAnchors for positioning so test mode
-- is a pixel-perfect preview of live behavior.
function DF:UpdateTestBossDebuffs(frame)
    if not frame then return end

    local db = DF:GetFrameDB(frame)

    -- Check if boss debuffs are enabled (both feature and test mode toggle)
    if not db.bossDebuffsEnabled or not db.testShowBossDebuffs then
        DF:HideTestBossDebuffs(frame)
        return
    end

    -- Use the real private aura system for positioning.
    -- Override unit to "player" so the API call succeeds (player always exists).
    local savedUnit = frame.unit
    local savedHideTooltip = db.bossDebuffsHideTooltip
    db.bossDebuffsHideTooltip = false  -- prevent 0.001px sizing; test icons are real frames, not C-side rendered
    frame.unit = "player"
    DF:SetupPrivateAuraAnchors(frame)
    frame.unit = savedUnit
    db.bossDebuffsHideTooltip = savedHideTooltip

    -- Now frame.bossDebuffFrames has positioned frames.
    -- Parent test icon visuals to each frame.

    local maxIcons = db.bossDebuffsMax or 4
    local showCountdown = db.bossDebuffsShowCountdown ~= false
    local showNumbers = db.bossDebuffsShowNumbers ~= false

    -- Create test icon frames if they don't exist
    if not frame.testBossDebuffIcons then
        frame.testBossDebuffIcons = {}
    end

    local displayCount = math.min(maxIcons, #DF.TestData.bossDebuffs)

    for i = 1, maxIcons do
        local container = frame.bossDebuffFrames and frame.bossDebuffFrames[i]
        local bossDebuffData = DF.TestData.bossDebuffs[i]

        if container and i <= displayCount and bossDebuffData then
            local icon = frame.testBossDebuffIcons[i]
            if not icon then
                icon = CreateFrame("Frame", nil, container)

                -- Icon texture
                icon.texture = icon:CreateTexture(nil, "ARTWORK")
                icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

                -- Cooldown
                icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
                icon.cooldown:SetDrawEdge(false)
                icon.cooldown:SetDrawSwipe(true)
                icon.cooldown:SetReverse(true)

                -- Debug background
                icon.debugBg = icon:CreateTexture(nil, "BORDER")
                icon.debugBg:SetAllPoints()
                local colors = {{1,0,0,0.3}, {0,1,0,0.3}, {0,0,1,0.3}, {1,1,0,0.3}}
                local c = colors[i] or colors[1]
                icon.debugBg:SetColorTexture(c[1], c[2], c[3], c[4])
                icon.debugBg:Hide()

                frame.testBossDebuffIcons[i] = icon
            end

            -- Re-parent to this container
            icon:SetParent(container)
            icon:ClearAllPoints()
            icon:SetAllPoints(container)

            -- Anchor sub-elements to fill the icon frame
            icon.texture:SetAllPoints()
            icon.cooldown:SetAllPoints(icon.texture)

            -- Set icon texture
            icon.texture:SetTexture(bossDebuffData.icon)

            -- Set cooldown
            if showCountdown and bossDebuffData.duration then
                icon.cooldown:Clear()
                icon.cooldown:SetHideCountdownNumbers(not showNumbers)

                local startTime = GetTime() - (bossDebuffData.duration * 0.3)
                icon.cooldown:SetCooldown(startTime, bossDebuffData.duration)
                icon.cooldown:Show()
            else
                icon.cooldown:Hide()
            end

            icon:Show()
        else
            -- Hide icon if no container or no data
            local icon = frame.testBossDebuffIcons[i]
            if icon then
                icon:Hide()
            end
        end
    end

    -- Hide any extra icons beyond maxIcons
    if frame.testBossDebuffIcons then
        for i = maxIcons + 1, #frame.testBossDebuffIcons do
            frame.testBossDebuffIcons[i]:Hide()
        end
    end
end

-- Hide test boss debuffs when exiting test mode
function DF:HideTestBossDebuffs(frame)
    if not frame then return end

    -- Hide test icons
    if frame.testBossDebuffIcons then
        for _, icon in ipairs(frame.testBossDebuffIcons) do
            icon:Hide()
            if icon.cooldown then
                icon.cooldown:Clear()
            end
        end
    end
end

-- Update all test boss debuffs (for live preview during slider dragging)
function DF:UpdateAllTestBossDebuffs()
    -- Only update if in test mode
    if not DF.testMode and not DF.raidTestMode then return end
    
    local mode = DF.GUI and DF.GUI.SelectedMode or "party"
    
    if mode == "raid" and DF.raidTestMode then
        -- Update raid test frames
        if DF.testRaidFrames then
            for _, frame in pairs(DF.testRaidFrames) do
                if frame and frame:IsShown() then
                    DF:UpdateTestBossDebuffs(frame)
                end
            end
        end
    elseif DF.testMode then
        -- Update party test frames
        if DF.testPartyFrames then
            for _, frame in pairs(DF.testPartyFrames) do
                if frame and frame:IsShown() then
                    DF:UpdateTestBossDebuffs(frame)
                end
            end
        end
    end
end

-- Update test absorb bar (unified for party and raid)
function DF:UpdateTestAbsorb(frame, testData)
    if not frame or not frame.healthBar then return end
    
    local db = DF:GetFrameDB(frame)
    local absorbPercent = testData.absorbPercent or 0
    local healthPercent = testData.healthPercent or 0.75
    
    -- Create bar if needed
    if not frame.dfAbsorbBar then
        frame.dfAbsorbBar = CreateFrame("StatusBar", nil, frame)
        frame.dfAbsorbBar:SetMinMaxValues(0, 1)
        frame.dfAbsorbBar:EnableMouse(false)
        local bg = frame.dfAbsorbBar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(true)
        bg:SetColorTexture(0, 0, 0, 0.5)
        frame.dfAbsorbBar.bg = bg
    end
    
    local customBar = frame.dfAbsorbBar
    local absorbMode = db.absorbBarMode or "OVERLAY"
    local absorbColor = db.absorbBarColor or {r = 0, g = 0.835, b = 1, a = 0.7}
    
    -- Set texture exactly like live code (only when texture changes)
    local tex = db.absorbBarTexture or "Interface\\Buttons\\WHITE8x8"
    if customBar.currentTexture ~= tex then
        customBar.currentTexture = tex
        if tex == "Interface\\RaidFrame\\Shield-Overlay" then
            customBar:SetStatusBarTexture(tex)
            local barTex = customBar:GetStatusBarTexture()
            if barTex then
                barTex:SetHorizTile(true)
                barTex:SetVertTile(true)
                barTex:SetTexCoord(0, 2, 0, 1)
                barTex:SetDesaturated(true)
            end
        else
            customBar:SetStatusBarTexture(tex)
            local barTex = customBar:GetStatusBarTexture()
            if barTex then
                barTex:SetHorizTile(false)
                barTex:SetVertTile(false)
                barTex:SetTexCoord(0, 1, 0, 1)
                barTex:SetDesaturated(false)
            end
        end
    end
    
    if absorbPercent > 0 then
        customBar:SetStatusBarColor(absorbColor.r, absorbColor.g, absorbColor.b, absorbColor.a or 0.7)
        customBar:SetAlpha(1)  -- Reset frame alpha (may have been set to 0 by ATTACHED_OVERFLOW mode)
        
        if absorbMode == "ATTACHED" then
            -- ATTACHED mode: Use a plain texture with proper TexCoords for texture alignment
            -- This ensures the absorb bar texture continues seamlessly from the health bar
            
            -- Hide the StatusBar immediately - we use a plain texture for ATTACHED mode
            customBar:Hide()
            if customBar.bg then customBar.bg:Hide() end
            
            local inset = 0
            if db.showFrameBorder ~= false then
                inset = db.borderSize or 1
            end
            
            local barWidth = frame.healthBar:GetWidth() - (inset * 2)
            local barHeight = frame.healthBar:GetHeight() - (inset * 2)
            local healthOrient = db.healthOrientation or "HORIZONTAL"
            
            -- Calculate how much space is available (missing health)
            local missingPercent = 1 - healthPercent
            -- Clamp absorb to not exceed max health
            local clampedAbsorbPercent = math.min(absorbPercent, missingPercent)
            local isClamped = absorbPercent > missingPercent
            
            -- Get the health fill texture to anchor to
            local healthFillTexture = frame.healthBar:GetStatusBarTexture()
            
            -- Calculate absorb bar size - only scale in the direction of the bar
            -- For horizontal bars: scale width, use full height
            -- For vertical bars: use full width, scale height
            local isHorizontal = (healthOrient == "HORIZONTAL" or healthOrient == "HORIZONTAL_INV")
            local absorbWidth = isHorizontal and (barWidth * clampedAbsorbPercent) or barWidth
            local absorbHeight = isHorizontal and barHeight or (barHeight * clampedAbsorbPercent)
            
            -- Create or reuse attached texture for proper alignment
            if not frame.absorbAttachedTexture then
                frame.absorbAttachedTexture = frame.healthBar:CreateTexture(nil, "ARTWORK", nil, 2)
            end
            local attachedTex = frame.absorbAttachedTexture
            
            -- Only hide when health is truly full (no space for absorbs) or bar would be too small to render
            -- Check the relevant dimension based on orientation
            local relevantSize = isHorizontal and absorbWidth or absorbHeight
            if missingPercent < 0.001 or relevantSize < 1 then
                attachedTex:Hide()
            else
                -- Use the same texture as the absorb bar
                local absorbTexture = db.absorbBarTexture or "Interface\\TargetingFrame\\UI-StatusBar"
                if type(absorbTexture) == "table" then
                    absorbTexture = absorbTexture.path or "Interface\\TargetingFrame\\UI-StatusBar"
                end
                attachedTex:SetTexture(absorbTexture)
                attachedTex:SetVertexColor(absorbColor.r, absorbColor.g, absorbColor.b, absorbColor.a or 0.7)
                
                -- Apply blend mode
                local blendMode = db.absorbBarBlendMode or "BLEND"
                attachedTex:SetBlendMode(blendMode)
                
                attachedTex:ClearAllPoints()
                
                -- Calculate proper texture coordinates to continue from health bar
                -- healthPercent = where health ends, clampedAbsorbPercent = how much absorb to show
                local texStart = healthPercent
                local texEnd = healthPercent + clampedAbsorbPercent
                
                if healthFillTexture then
                    if healthOrient == "HORIZONTAL" then
                        attachedTex:SetPoint("TOPLEFT", healthFillTexture, "TOPRIGHT", 0, 0)
                        attachedTex:SetPoint("BOTTOMLEFT", healthFillTexture, "BOTTOMRIGHT", 0, 0)
                        attachedTex:SetWidth(absorbWidth)
                        -- TexCoord: left, right, top, bottom
                        attachedTex:SetTexCoord(texStart, texEnd, 0, 1)
                    elseif healthOrient == "HORIZONTAL_INV" then
                        attachedTex:SetPoint("TOPRIGHT", healthFillTexture, "TOPLEFT", 0, 0)
                        attachedTex:SetPoint("BOTTOMRIGHT", healthFillTexture, "BOTTOMLEFT", 0, 0)
                        attachedTex:SetWidth(absorbWidth)
                        -- For reversed, flip the texture coords
                        attachedTex:SetTexCoord(1 - texStart, 1 - texEnd, 0, 1)
                    elseif healthOrient == "VERTICAL" then
                        attachedTex:SetPoint("BOTTOMLEFT", healthFillTexture, "TOPLEFT", 0, 0)
                        attachedTex:SetPoint("BOTTOMRIGHT", healthFillTexture, "TOPRIGHT", 0, 0)
                        attachedTex:SetHeight(absorbHeight)
                        -- Vertical: adjust top/bottom coords
                        attachedTex:SetTexCoord(0, 1, 1 - texEnd, 1 - texStart)
                    elseif healthOrient == "VERTICAL_INV" then
                        attachedTex:SetPoint("TOPLEFT", healthFillTexture, "BOTTOMLEFT", 0, 0)
                        attachedTex:SetPoint("TOPRIGHT", healthFillTexture, "BOTTOMRIGHT", 0, 0)
                        attachedTex:SetHeight(absorbHeight)
                        attachedTex:SetTexCoord(0, 1, texStart, texEnd)
                    end
                else
                    -- Fallback: position manually
                    local healthWidth = barWidth * healthPercent
                    local healthHeight = barHeight * healthPercent
                    
                    if healthOrient == "HORIZONTAL" then
                        attachedTex:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", inset + healthWidth, -inset)
                        attachedTex:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", inset + healthWidth, inset)
                        attachedTex:SetWidth(absorbWidth)
                        attachedTex:SetTexCoord(texStart, texEnd, 0, 1)
                    elseif healthOrient == "HORIZONTAL_INV" then
                        attachedTex:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", -inset - healthWidth, -inset)
                        attachedTex:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", -inset - healthWidth, inset)
                        attachedTex:SetWidth(absorbWidth)
                        attachedTex:SetTexCoord(1 - texStart, 1 - texEnd, 0, 1)
                    elseif healthOrient == "VERTICAL" then
                        attachedTex:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", inset, inset + healthHeight)
                        attachedTex:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", -inset, inset + healthHeight)
                        attachedTex:SetHeight(absorbHeight)
                        attachedTex:SetTexCoord(0, 1, 1 - texEnd, 1 - texStart)
                    elseif healthOrient == "VERTICAL_INV" then
                        attachedTex:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", inset, -inset - healthHeight)
                        attachedTex:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", -inset, -inset - healthHeight)
                        attachedTex:SetHeight(absorbHeight)
                        attachedTex:SetTexCoord(0, 1, texStart, texEnd)
                    end
                end
                
                attachedTex:Show()
            end
            
            -- Handle overshield glow in test mode - show when clamped
            if db.absorbBarShowOvershield then
                if not frame.absorbOvershieldGlow then
                    frame.absorbOvershieldGlow = frame.healthBar:CreateTexture(nil, "OVERLAY", nil, 7)
                end
                
                local glow = frame.absorbOvershieldGlow
                local glowStyle = db.absorbBarOvershieldStyle or "SPARK"
                local glowColor = db.absorbBarOvershieldColor or absorbColor
                local glowAlpha = db.absorbBarOvershieldAlpha or 0.8
                local reversePos = db.absorbBarOvershieldReverse or false
                
                local isHorizontal = (healthOrient == "HORIZONTAL" or healthOrient == "HORIZONTAL_INV")
                local isReversed = (healthOrient == "HORIZONTAL_INV" or healthOrient == "VERTICAL_INV")
                local atMaxHP = not reversePos
                local atEnd = (atMaxHP ~= isReversed)
                
                glow:ClearAllPoints()
                glow:SetRotation(0)
                glow:SetTexCoord(0, 1, 0, 1)
                glow:SetBlendMode("ADD")
                
                local glowWidth = glowStyle == "LINE" and 2 or (glowStyle == "SPARK" and 5 or (glowStyle == "GLOW" and 10 or 20))
                
                if isHorizontal then
                    glow:SetTexture(glowStyle == "LINE" and "Interface\\Buttons\\WHITE8x8" or ("Interface\\AddOns\\DandersFrames\\Media\\" .. (atEnd and "DF_Gradient_H_Rev" or "DF_Gradient_H")))
                    if atEnd then
                        glow:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", 0, 0)
                        glow:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", 0, 0)
                    else
                        glow:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 0, 0)
                        glow:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", 0, 0)
                    end
                    glow:SetWidth(glowWidth)
                else
                    glow:SetTexture(glowStyle == "LINE" and "Interface\\Buttons\\WHITE8x8" or ("Interface\\AddOns\\DandersFrames\\Media\\" .. (atEnd and "DF_Gradient_V_Rev" or "DF_Gradient_V")))
                    if atEnd then
                        glow:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 0, 0)
                        glow:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", 0, 0)
                    else
                        glow:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", 0, 0)
                        glow:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", 0, 0)
                    end
                    glow:SetHeight(glowWidth)
                end
                
                glow:SetVertexColor(glowColor.r, glowColor.g, glowColor.b, 1)
                -- Show glow only when absorb is clamped (would exceed max health)
                if isClamped then
                    glow:SetAlpha(glowAlpha)
                    glow:Show()
                else
                    glow:Hide()
                end
            elseif frame.absorbOvershieldGlow then
                frame.absorbOvershieldGlow:Hide()
            end
            
            -- Hide overflow bar for regular ATTACHED mode
            if frame.absorbOverflowBar then frame.absorbOverflowBar:Hide() end
            
        elseif absorbMode == "ATTACHED_OVERFLOW" then
            -- ATTACHED_OVERFLOW mode: Shows attached texture when not clamped, overlay when clamped
            
            -- Hide the StatusBar - we use plain texture for attached display
            customBar:Hide()
            if customBar.bg then customBar.bg:Hide() end
            
            -- Hide glow (we use overflow overlay instead)
            if frame.absorbOvershieldGlow then frame.absorbOvershieldGlow:Hide() end
            
            local inset = 0
            if db.showFrameBorder ~= false then
                inset = db.borderSize or 1
            end
            
            local barWidth = frame.healthBar:GetWidth() - (inset * 2)
            local barHeight = frame.healthBar:GetHeight() - (inset * 2)
            local healthOrient = db.healthOrientation or "HORIZONTAL"
            
            -- Calculate clamped values
            local missingPercent = 1 - healthPercent
            local clampedAbsorbPercent = math.min(absorbPercent, missingPercent)
            local isClamped = absorbPercent > missingPercent
            
            local healthFillTexture = frame.healthBar:GetStatusBarTexture()
            
            -- Calculate absorb bar size - only scale in the direction of the bar
            local isHorizontal = (healthOrient == "HORIZONTAL" or healthOrient == "HORIZONTAL_INV")
            local absorbWidth = isHorizontal and (barWidth * clampedAbsorbPercent) or barWidth
            local absorbHeight = isHorizontal and barHeight or (barHeight * clampedAbsorbPercent)
            
            -- Create or reuse attached texture for proper alignment (same as ATTACHED mode)
            if not frame.absorbAttachedTexture then
                frame.absorbAttachedTexture = frame.healthBar:CreateTexture(nil, "ARTWORK", nil, 2)
            end
            local attachedTex = frame.absorbAttachedTexture
            
            -- Handle overflow bar (shown when clamped)
            if not frame.absorbOverflowBar then
                frame.absorbOverflowBar = CreateFrame("StatusBar", nil, frame.healthBar)
                frame.absorbOverflowBar:SetMinMaxValues(0, 1)
                frame.absorbOverflowBar:EnableMouse(false)
            end
            local overflowBar = frame.absorbOverflowBar
            
            if isClamped then
                -- Hide attached texture, show overflow bar
                attachedTex:Hide()
                
                local healthLevel = frame.healthBar:GetFrameLevel()
                overflowBar:ClearAllPoints()
                -- Keep overflow bar below dispel overlay (+6) and highlights (+9)
                overflowBar:SetFrameLevel(healthLevel + 3)
                
                -- Apply same texture/color as main absorb bar
                local texture = db.absorbBarTexture or "Interface\\TargetingFrame\\UI-StatusBar"
                if type(texture) == "table" then
                    texture = texture.path or "Interface\\TargetingFrame\\UI-StatusBar"
                end
                overflowBar:SetStatusBarTexture(texture)
                overflowBar:SetStatusBarColor(absorbColor.r, absorbColor.g, absorbColor.b, absorbColor.a or 0.7)
                
                local overflowTex = overflowBar:GetStatusBarTexture()
                if overflowTex then
                    overflowTex:SetHorizTile(false)
                    overflowTex:SetVertTile(false)
                end
                
                -- Position like OVERLAY mode
                overflowBar:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", inset, -inset)
                overflowBar:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", -inset, inset)
                
                local maxHealth = testData.maxHealth or 100000
                overflowBar:SetMinMaxValues(0, maxHealth)
                
                local overlayReverse = db.absorbBarOverlayReverse or false
                
                if healthOrient == "HORIZONTAL" then
                    overflowBar:SetOrientation("HORIZONTAL")
                    overflowBar:SetReverseFill(not overlayReverse)
                elseif healthOrient == "HORIZONTAL_INV" then
                    overflowBar:SetOrientation("HORIZONTAL")
                    overflowBar:SetReverseFill(overlayReverse)
                elseif healthOrient == "VERTICAL" then
                    overflowBar:SetOrientation("VERTICAL")
                    overflowBar:SetReverseFill(not overlayReverse)
                elseif healthOrient == "VERTICAL_INV" then
                    overflowBar:SetOrientation("VERTICAL")
                    overflowBar:SetReverseFill(overlayReverse)
                end
                
                overflowBar:SetAlpha(1)
                overflowBar:SetValue(absorbPercent * maxHealth)
                overflowBar:Show()
            else
                -- Show attached texture, hide overflow bar
                overflowBar:SetAlpha(0)
                overflowBar:Hide()
                
                -- Only hide when health is truly full or bar would be too small to render
                local relevantSize = isHorizontal and absorbWidth or absorbHeight
                if missingPercent < 0.001 or relevantSize < 1 then
                    attachedTex:Hide()
                else
                    -- Use the same texture as the absorb bar
                    local absorbTexture = db.absorbBarTexture or "Interface\\TargetingFrame\\UI-StatusBar"
                    if type(absorbTexture) == "table" then
                        absorbTexture = absorbTexture.path or "Interface\\TargetingFrame\\UI-StatusBar"
                    end
                    attachedTex:SetTexture(absorbTexture)
                    attachedTex:SetVertexColor(absorbColor.r, absorbColor.g, absorbColor.b, absorbColor.a or 0.7)
                    
                    -- Apply blend mode
                    local blendMode = db.absorbBarBlendMode or "BLEND"
                    attachedTex:SetBlendMode(blendMode)
                    
                    attachedTex:ClearAllPoints()
                    
                    -- Calculate proper texture coordinates to continue from health bar
                    local texStart = healthPercent
                    local texEnd = healthPercent + clampedAbsorbPercent
                    
                    if healthFillTexture then
                        if healthOrient == "HORIZONTAL" then
                            attachedTex:SetPoint("TOPLEFT", healthFillTexture, "TOPRIGHT", 0, 0)
                            attachedTex:SetPoint("BOTTOMLEFT", healthFillTexture, "BOTTOMRIGHT", 0, 0)
                            attachedTex:SetWidth(absorbWidth)
                            attachedTex:SetTexCoord(texStart, texEnd, 0, 1)
                        elseif healthOrient == "HORIZONTAL_INV" then
                            attachedTex:SetPoint("TOPRIGHT", healthFillTexture, "TOPLEFT", 0, 0)
                            attachedTex:SetPoint("BOTTOMRIGHT", healthFillTexture, "BOTTOMLEFT", 0, 0)
                            attachedTex:SetWidth(absorbWidth)
                            attachedTex:SetTexCoord(1 - texStart, 1 - texEnd, 0, 1)
                        elseif healthOrient == "VERTICAL" then
                            attachedTex:SetPoint("BOTTOMLEFT", healthFillTexture, "TOPLEFT", 0, 0)
                            attachedTex:SetPoint("BOTTOMRIGHT", healthFillTexture, "TOPRIGHT", 0, 0)
                            attachedTex:SetHeight(absorbHeight)
                            attachedTex:SetTexCoord(0, 1, 1 - texEnd, 1 - texStart)
                        elseif healthOrient == "VERTICAL_INV" then
                            attachedTex:SetPoint("TOPLEFT", healthFillTexture, "BOTTOMLEFT", 0, 0)
                            attachedTex:SetPoint("TOPRIGHT", healthFillTexture, "BOTTOMRIGHT", 0, 0)
                            attachedTex:SetHeight(absorbHeight)
                            attachedTex:SetTexCoord(0, 1, texStart, texEnd)
                        end
                    else
                        -- Fallback: position manually
                        local healthWidth = barWidth * healthPercent
                        local healthHeight = barHeight * healthPercent
                        
                        if healthOrient == "HORIZONTAL" then
                            attachedTex:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", inset + healthWidth, -inset)
                            attachedTex:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", inset + healthWidth, inset)
                            attachedTex:SetWidth(absorbWidth)
                            attachedTex:SetTexCoord(texStart, texEnd, 0, 1)
                        elseif healthOrient == "HORIZONTAL_INV" then
                            attachedTex:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", -inset - healthWidth, -inset)
                            attachedTex:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", -inset - healthWidth, inset)
                            attachedTex:SetWidth(absorbWidth)
                            attachedTex:SetTexCoord(1 - texStart, 1 - texEnd, 0, 1)
                        elseif healthOrient == "VERTICAL" then
                            attachedTex:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", inset, inset + healthHeight)
                            attachedTex:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", -inset, inset + healthHeight)
                            attachedTex:SetHeight(absorbHeight)
                            attachedTex:SetTexCoord(0, 1, 1 - texEnd, 1 - texStart)
                        elseif healthOrient == "VERTICAL_INV" then
                            attachedTex:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", inset, -inset - healthHeight)
                            attachedTex:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", -inset, -inset - healthHeight)
                            attachedTex:SetHeight(absorbHeight)
                            attachedTex:SetTexCoord(0, 1, texStart, texEnd)
                        end
                    end
                    
                    attachedTex:Show()
                end
            end
            
        elseif absorbMode == "OVERLAY" then
            -- Hide overshield glow for non-ATTACHED modes
            if frame.absorbOvershieldGlow then frame.absorbOvershieldGlow:Hide() end
            -- Hide overflow bar for OVERLAY mode
            if frame.absorbOverflowBar then frame.absorbOverflowBar:Hide() end
            -- Hide the attached texture (used for ATTACHED mode test display)
            if frame.absorbAttachedTexture then frame.absorbAttachedTexture:Hide() end
            
            -- Overlay mode: fills from right edge toward left (reverse fill)
            -- Clear any existing anchors first
            customBar:ClearAllPoints()
            
            -- Set parent to health bar for overlay mode
            customBar:SetParent(frame.healthBar)
            customBar:SetFrameStrata(frame:GetFrameStrata())
            
            -- Set frame level above health bar but below dispel overlay (+6) and highlights (+9)
            local healthLevel = frame.healthBar:GetFrameLevel()
            customBar:SetFrameLevel(healthLevel + 2)
            
            -- Inset by border size if frame border is enabled to avoid overlap
            local inset = 0
            if db.showFrameBorder ~= false then
                inset = db.borderSize or 1
            end
            customBar:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", inset, -inset)
            customBar:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", -inset, inset)
            if customBar.bg then customBar.bg:Hide() end
            
            local healthOrient = db.healthOrientation or "HORIZONTAL"
            local overlayReverse = db.absorbBarOverlayReverse or false
            
            -- Match real code logic exactly
            if healthOrient == "HORIZONTAL" then
                customBar:SetOrientation("HORIZONTAL")
                customBar:SetReverseFill(not overlayReverse)
            elseif healthOrient == "HORIZONTAL_INV" then
                customBar:SetOrientation("HORIZONTAL")
                customBar:SetReverseFill(overlayReverse)
            elseif healthOrient == "VERTICAL" then
                customBar:SetOrientation("VERTICAL")
                customBar:SetReverseFill(not overlayReverse)
            elseif healthOrient == "VERTICAL_INV" then
                customBar:SetOrientation("VERTICAL")
                customBar:SetReverseFill(overlayReverse)
            end
            
            local maxHealth = testData.maxHealth or 100000
            customBar:SetMinMaxValues(0, maxHealth)
            customBar:SetValue(absorbPercent * maxHealth)
            customBar:Show()
        else
            -- Hide overshield glow for non-ATTACHED modes
            if frame.absorbOvershieldGlow then frame.absorbOvershieldGlow:Hide() end
            -- Hide overflow bar for FLOATING mode
            if frame.absorbOverflowBar then frame.absorbOverflowBar:Hide() end
            -- Hide the attached texture (used for ATTACHED mode test display)
            if frame.absorbAttachedTexture then frame.absorbAttachedTexture:Hide() end
            
            -- Floating mode
            -- Clear any existing anchors first
            customBar:ClearAllPoints()
            customBar:SetParent(frame)
            
            -- Hide briefly to force strata change to take effect
            local wasShown = customBar:IsShown()
            if wasShown then customBar:Hide() end
            
            -- Apply strata setting
            local strata = db.absorbBarStrata or "MEDIUM"
            if strata ~= "SANDWICH" and strata ~= "SANDWICH_LOW" then
                customBar:SetFrameStrata(strata)
            else
                customBar:SetFrameStrata(frame:GetFrameStrata())
            end
            
            -- Apply frame level setting
            local floatingLevel = db.absorbBarFrameLevel or 10
            customBar:SetFrameLevel(floatingLevel)
            
            if wasShown then customBar:Show() end
            
            -- Dimensions & Orientation
            local orientation = db.absorbBarOrientation or "HORIZONTAL"
            customBar:SetOrientation(orientation)
            customBar:SetReverseFill(db.absorbBarReverse or false)
            
            local w = db.absorbBarWidth or 50
            local h = db.absorbBarHeight or 6
            
            if orientation == "VERTICAL" then
                customBar:SetWidth(h)
                customBar:SetHeight(w)
            else
                customBar:SetWidth(w)
                customBar:SetHeight(h)
            end
            
            local anchor = db.absorbBarAnchor or "CENTER"
            local x = db.absorbBarX or 0
            local y = db.absorbBarY or 0
            customBar:SetPoint(anchor, frame, anchor, x, y)
            
            customBar:SetMinMaxValues(0, 1)
            customBar:SetValue(absorbPercent)
            
            if customBar.bg then 
                customBar.bg:Show()
                local bgC = db.absorbBarBackgroundColor or {r = 0, g = 0, b = 0, a = 0.5}
                customBar.bg:SetColorTexture(bgC.r, bgC.g, bgC.b, bgC.a)
            end
            customBar:Show()
        end
        
        -- Hide attached texture when not in ATTACHED or ATTACHED_OVERFLOW mode
        if frame.absorbAttachedTexture and absorbMode ~= "ATTACHED" and absorbMode ~= "ATTACHED_OVERFLOW" then
            frame.absorbAttachedTexture:Hide()
        end
    else
        customBar:Hide()
        -- Also hide the attached texture used for ATTACHED mode
        if frame.absorbAttachedTexture then
            frame.absorbAttachedTexture:Hide()
        end
    end
end

-- Update test heal absorb bar (unified for party and raid)
function DF:UpdateTestHealAbsorb(frame, testData)
    if not frame or not frame.healthBar then return end
    
    local db = DF:GetFrameDB(frame)
    local healAbsorbPercent = testData.healAbsorbPercent or 0
    local healthPercent = testData.healthPercent or 0.75
    
    -- Create bar if needed
    if not frame.dfHealAbsorbBar then
        frame.dfHealAbsorbBar = CreateFrame("StatusBar", nil, frame)
        frame.dfHealAbsorbBar:SetMinMaxValues(0, 1)
        frame.dfHealAbsorbBar:EnableMouse(false)
        local bg = frame.dfHealAbsorbBar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(true)
        bg:SetColorTexture(0, 0, 0, 0.5)
        frame.dfHealAbsorbBar.bg = bg
    end
    
    local customBar = frame.dfHealAbsorbBar
    local healAbsorbMode = db.healAbsorbBarMode or "OVERLAY"
    local healAbsorbColor = db.healAbsorbBarColor or {r = 0.4, g = 0.1, b = 0.1, a = 0.7}
    
    -- Set texture exactly like live code (only when texture changes)
    local tex = db.healAbsorbBarTexture or "Interface\\Buttons\\WHITE8x8"
    if customBar.currentTexture ~= tex then
        customBar.currentTexture = tex
        if tex == "Interface\\RaidFrame\\Shield-Overlay" then
            customBar:SetStatusBarTexture(tex)
            local barTex = customBar:GetStatusBarTexture()
            if barTex then
                barTex:SetHorizTile(true)
                barTex:SetVertTile(true)
                barTex:SetTexCoord(0, 2, 0, 1)
                barTex:SetDesaturated(true)
            end
        else
            customBar:SetStatusBarTexture(tex)
            local barTex = customBar:GetStatusBarTexture()
            if barTex then
                barTex:SetHorizTile(false)
                barTex:SetVertTile(false)
                barTex:SetTexCoord(0, 1, 0, 1)
                barTex:SetDesaturated(false)
            end
        end
    end
    
    if healAbsorbPercent > 0 then
        customBar:SetStatusBarColor(healAbsorbColor.r, healAbsorbColor.g, healAbsorbColor.b, healAbsorbColor.a or 0.7)
        
        if healAbsorbMode == "ATTACHED" then
            -- ATTACHED mode: Use a plain texture with proper TexCoords for texture alignment
            -- This ensures the heal absorb bar texture continues seamlessly from the health bar
            
            -- Hide the StatusBar immediately - we use a plain texture for ATTACHED mode
            customBar:Hide()
            if customBar.bg then customBar.bg:Hide() end
            
            -- Hide any existing overshield glow (not used for heal absorbs)
            if frame.healAbsorbOvershieldGlow then
                frame.healAbsorbOvershieldGlow:Hide()
            end
            
            local inset = 0
            if db.showFrameBorder ~= false then
                inset = db.borderSize or 1
            end
            
            local barWidth = frame.healthBar:GetWidth() - (inset * 2)
            local barHeight = frame.healthBar:GetHeight() - (inset * 2)
            local healthOrient = db.healthOrientation or "HORIZONTAL"
            
            -- Clamp heal absorb at current health (can't go past 0)
            local clampedHealAbsorbPercent = math.min(healAbsorbPercent, healthPercent)
            
            -- Get the health fill texture to anchor to
            local healthFillTexture = frame.healthBar:GetStatusBarTexture()
            
            -- Calculate heal absorb bar size - only scale in the direction of the bar
            local isHorizontal = (healthOrient == "HORIZONTAL" or healthOrient == "HORIZONTAL_INV")
            local healAbsorbWidth = isHorizontal and (barWidth * clampedHealAbsorbPercent) or barWidth
            local healAbsorbHeight = isHorizontal and barHeight or (barHeight * clampedHealAbsorbPercent)
            
            -- Create or reuse attached texture for proper alignment
            if not frame.healAbsorbAttachedTexture then
                frame.healAbsorbAttachedTexture = frame.healthBar:CreateTexture(nil, "ARTWORK", nil, 3)
            end
            local attachedTex = frame.healAbsorbAttachedTexture
            
            -- Only hide when health is essentially 0 (no bar to anchor to) or bar would be too small to render
            local relevantSize = isHorizontal and healAbsorbWidth or healAbsorbHeight
            if healthPercent < 0.001 or relevantSize < 1 then
                attachedTex:Hide()
            else
                -- Use the same texture as the heal absorb bar
                local healAbsorbTexture = db.healAbsorbBarTexture or "Interface\\TargetingFrame\\UI-StatusBar"
                if type(healAbsorbTexture) == "table" then
                    healAbsorbTexture = healAbsorbTexture.path or "Interface\\TargetingFrame\\UI-StatusBar"
                end
                attachedTex:SetTexture(healAbsorbTexture)
                attachedTex:SetVertexColor(healAbsorbColor.r, healAbsorbColor.g, healAbsorbColor.b, healAbsorbColor.a or 0.7)
                
                -- Apply blend mode
                local blendMode = db.healAbsorbBarBlendMode or "BLEND"
                attachedTex:SetBlendMode(blendMode)
                
                attachedTex:ClearAllPoints()
                
                -- Calculate proper texture coordinates
                -- Heal absorb extends INWARD from health fill edge toward 0
                -- texStart = where heal absorb starts (at health edge), texEnd = where it ends (toward 0)
                local texStart = healthPercent - clampedHealAbsorbPercent
                local texEnd = healthPercent
                
                if healthFillTexture then
                    if healthOrient == "HORIZONTAL" then
                        -- Heal absorb at right edge of health fill, extending left
                        attachedTex:SetPoint("TOPRIGHT", healthFillTexture, "TOPRIGHT", 0, 0)
                        attachedTex:SetPoint("BOTTOMRIGHT", healthFillTexture, "BOTTOMRIGHT", 0, 0)
                        attachedTex:SetWidth(healAbsorbWidth)
                        attachedTex:SetTexCoord(texStart, texEnd, 0, 1)
                    elseif healthOrient == "HORIZONTAL_INV" then
                        -- Heal absorb at left edge of health fill, extending right
                        attachedTex:SetPoint("TOPLEFT", healthFillTexture, "TOPLEFT", 0, 0)
                        attachedTex:SetPoint("BOTTOMLEFT", healthFillTexture, "BOTTOMLEFT", 0, 0)
                        attachedTex:SetWidth(healAbsorbWidth)
                        attachedTex:SetTexCoord(1 - texEnd, 1 - texStart, 0, 1)
                    elseif healthOrient == "VERTICAL" then
                        -- Heal absorb at top edge of health fill, extending down
                        attachedTex:SetPoint("TOPLEFT", healthFillTexture, "TOPLEFT", 0, 0)
                        attachedTex:SetPoint("TOPRIGHT", healthFillTexture, "TOPRIGHT", 0, 0)
                        attachedTex:SetHeight(healAbsorbHeight)
                        attachedTex:SetTexCoord(0, 1, 1 - texEnd, 1 - texStart)
                    elseif healthOrient == "VERTICAL_INV" then
                        -- Heal absorb at bottom edge of health fill, extending up
                        attachedTex:SetPoint("BOTTOMLEFT", healthFillTexture, "BOTTOMLEFT", 0, 0)
                        attachedTex:SetPoint("BOTTOMRIGHT", healthFillTexture, "BOTTOMRIGHT", 0, 0)
                        attachedTex:SetHeight(healAbsorbHeight)
                        attachedTex:SetTexCoord(0, 1, texStart, texEnd)
                    end
                else
                    -- Fallback: position manually
                    local healthWidth = barWidth * healthPercent
                    local healthHeight = barHeight * healthPercent
                    
                    if healthOrient == "HORIZONTAL" then
                        attachedTex:SetPoint("TOPRIGHT", frame.healthBar, "TOPLEFT", inset + healthWidth, -inset)
                        attachedTex:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMLEFT", inset + healthWidth, inset)
                        attachedTex:SetWidth(healAbsorbWidth)
                        attachedTex:SetTexCoord(texStart, texEnd, 0, 1)
                    elseif healthOrient == "HORIZONTAL_INV" then
                        attachedTex:SetPoint("TOPLEFT", frame.healthBar, "TOPRIGHT", -inset - healthWidth, -inset)
                        attachedTex:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMRIGHT", -inset - healthWidth, inset)
                        attachedTex:SetWidth(healAbsorbWidth)
                        attachedTex:SetTexCoord(1 - texEnd, 1 - texStart, 0, 1)
                    elseif healthOrient == "VERTICAL" then
                        attachedTex:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", inset, inset + healthHeight)
                        attachedTex:SetPoint("TOPRIGHT", frame.healthBar, "BOTTOMRIGHT", -inset, inset + healthHeight)
                        attachedTex:SetHeight(healAbsorbHeight)
                        attachedTex:SetTexCoord(0, 1, 1 - texEnd, 1 - texStart)
                    elseif healthOrient == "VERTICAL_INV" then
                        attachedTex:SetPoint("BOTTOMLEFT", frame.healthBar, "TOPLEFT", inset, -inset - healthHeight)
                        attachedTex:SetPoint("BOTTOMRIGHT", frame.healthBar, "TOPRIGHT", -inset, -inset - healthHeight)
                        attachedTex:SetHeight(healAbsorbHeight)
                        attachedTex:SetTexCoord(0, 1, texStart, texEnd)
                    end
                end
                
                attachedTex:Show()
            end
            
        elseif healAbsorbMode == "OVERLAY" then
            -- Hide overshield glow for non-ATTACHED modes
            if frame.healAbsorbOvershieldGlow then frame.healAbsorbOvershieldGlow:Hide() end
            -- Hide attached texture for non-ATTACHED modes
            if frame.healAbsorbAttachedTexture then frame.healAbsorbAttachedTexture:Hide() end
            
            -- Clear any existing anchors first
            customBar:ClearAllPoints()
            
            -- Set parent to health bar for overlay mode
            customBar:SetParent(frame.healthBar)
            customBar:SetFrameStrata(frame:GetFrameStrata())
            
            -- Set frame level above health bar
            local healthLevel = frame.healthBar:GetFrameLevel()
            customBar:SetFrameLevel(healthLevel + 2)
            
            -- Inset by border size if frame border is enabled to avoid overlap
            local inset = 0
            if db.showFrameBorder ~= false then
                inset = db.borderSize or 1
            end
            customBar:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", inset, -inset)
            customBar:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", -inset, inset)
            if customBar.bg then customBar.bg:Hide() end
            
            -- Match real code logic exactly - heal absorbs fill from low HP side
            local healthOrient = db.healthOrientation or "HORIZONTAL"
            local overlayReverse = db.healAbsorbBarOverlayReverse or false
            
            if healthOrient == "HORIZONTAL" then
                customBar:SetOrientation("HORIZONTAL")
                customBar:SetReverseFill(overlayReverse)
            elseif healthOrient == "HORIZONTAL_INV" then
                customBar:SetOrientation("HORIZONTAL")
                customBar:SetReverseFill(not overlayReverse)
            elseif healthOrient == "VERTICAL" then
                customBar:SetOrientation("VERTICAL")
                customBar:SetReverseFill(overlayReverse)
            elseif healthOrient == "VERTICAL_INV" then
                customBar:SetOrientation("VERTICAL")
                customBar:SetReverseFill(not overlayReverse)
            end
            
            local maxHealth = testData.maxHealth or 100000
            customBar:SetMinMaxValues(0, maxHealth)
            customBar:SetValue(healAbsorbPercent * maxHealth)
            customBar:Show()
        else
            -- Hide overshield glow for non-ATTACHED modes
            if frame.healAbsorbOvershieldGlow then frame.healAbsorbOvershieldGlow:Hide() end
            -- Hide attached texture for non-ATTACHED modes
            if frame.healAbsorbAttachedTexture then frame.healAbsorbAttachedTexture:Hide() end
            
            -- FLOATING mode
            customBar:ClearAllPoints()
            customBar:SetParent(frame)
            customBar:SetFrameStrata(frame:GetFrameStrata())
            
            local floatingLevel = db.healAbsorbBarFrameLevel or 10
            customBar:SetFrameLevel(floatingLevel)
            
            local orientation = db.healAbsorbBarOrientation or "HORIZONTAL"
            customBar:SetOrientation(orientation)
            customBar:SetReverseFill(db.healAbsorbBarReverse or false)
            
            local w = db.healAbsorbBarWidth or 50
            local h = db.healAbsorbBarHeight or 6
            
            if orientation == "VERTICAL" then
                customBar:SetWidth(h)
                customBar:SetHeight(w)
            else
                customBar:SetWidth(w)
                customBar:SetHeight(h)
            end
            
            local anchor = db.healAbsorbBarAnchor or "CENTER"
            local x = db.healAbsorbBarX or 0
            local y = db.healAbsorbBarY or 0
            customBar:SetPoint(anchor, frame, anchor, x, y)
            
            customBar:SetMinMaxValues(0, 1)
            customBar:SetValue(healAbsorbPercent)
            if customBar.bg then customBar.bg:Show() end
            customBar:Show()
        end
    else
        customBar:Hide()
        -- Also hide the attached texture used for ATTACHED mode
        if frame.healAbsorbAttachedTexture then
            frame.healAbsorbAttachedTexture:Hide()
        end
    end
end

-- Update test heal prediction bar (unified for party and raid)
function DF:UpdateTestHealPrediction(frame, testData)
    if not frame or not frame.healthBar then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Check if heal prediction is enabled
    if not db.healPredictionEnabled then
        if frame.dfHealPredictionBar then
            frame.dfHealPredictionBar:Hide()
        end
        return
    end
    
    local healPredictionPercent = testData.healPredictionPercent or 0
    local healthPercent = testData.healthPercent or 0.75
    
    -- Create bar if needed
    if not frame.dfHealPredictionBar then
        frame.dfHealPredictionBar = CreateFrame("StatusBar", nil, frame)
        frame.dfHealPredictionBar:SetMinMaxValues(0, 1)
        frame.dfHealPredictionBar:EnableMouse(false)
        local bg = frame.dfHealPredictionBar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(true)
        bg:SetColorTexture(0, 0, 0, 0.5)
        frame.dfHealPredictionBar.bg = bg
    end
    
    local customBar = frame.dfHealPredictionBar
    local mode = db.healPredictionMode or "OVERLAY"
    local showMode = db.healPredictionShowMode or "ALL"
    
    -- Get color based on show mode
    local color
    if showMode == "MINE" then
        color = db.healPredictionMyColor or {r = 0.0, g = 0.8, b = 0.2, a = 0.7}
    elseif showMode == "OTHERS" then
        color = db.healPredictionOthersColor or {r = 0.0, g = 0.5, b = 0.8, a = 0.7}
    else
        color = db.healPredictionAllColor or {r = 0.0, g = 0.7, b = 0.4, a = 0.7}
    end
    
    -- Show heal prediction if there's incoming heals AND either:
    -- 1. Health is not full, OR
    -- 2. Show overheal is enabled
    local showOverheal = db.healPredictionShowOverheal
    if healPredictionPercent > 0 and (healthPercent < 1 or showOverheal) then
        -- Set texture exactly like live code (only when texture changes)
        local tex = db.healPredictionTexture or "Interface\\Buttons\\WHITE8x8"
        if customBar.currentTexture ~= tex then
            customBar.currentTexture = tex
            customBar:SetStatusBarTexture(tex)
            local barTex = customBar:GetStatusBarTexture()
            if barTex then
                barTex:SetHorizTile(false)
                barTex:SetVertTile(false)
                barTex:SetTexCoord(0, 1, 0, 1)
            end
        end
        customBar:SetStatusBarColor(color.r, color.g, color.b, color.a or 0.7)
        
        if mode == "OVERLAY" then
            -- OVERLAY mode: Anchor to health fill texture like absorbs do in ATTACHED
            customBar:ClearAllPoints()
            
            -- Parent to frame (not healthBar) to avoid clipping when showing overheal
            customBar:SetParent(frame)
            customBar:SetFrameStrata(frame:GetFrameStrata())
            
            -- For OVERLAY mode, disable tiling in narrow bars (like ATTACHED absorbs)
            local overlayBarTex = customBar:GetStatusBarTexture()
            if overlayBarTex then
                overlayBarTex:SetHorizTile(false)
                overlayBarTex:SetVertTile(false)
                overlayBarTex:SetTexCoord(0, 1, 0, 1)
            end
            
            -- Set frame level above health bar but below resource bar (which is at +2)
            local healthLevel = frame.healthBar:GetFrameLevel()
            customBar:SetFrameLevel(healthLevel + 1)
            
            -- Inset by border size if frame border is enabled to avoid overlap
            local inset = 0
            if db.showFrameBorder ~= false then
                inset = db.borderSize or 1
            end
            
            local barWidth = frame.healthBar:GetWidth() - (inset * 2)
            local barHeight = frame.healthBar:GetHeight() - (inset * 2)
            
            local healthOrient = db.healthOrientation or "HORIZONTAL"
            
            -- Calculate the missing health and clamp heal to not exceed it (unless showOverheal is enabled)
            local missingPercent = 1 - healthPercent
            local clampedHealPercent
            if showOverheal then
                clampedHealPercent = healPredictionPercent  -- Show full overheal
            else
                clampedHealPercent = math.min(healPredictionPercent, missingPercent)
            end
            
            -- Get the health fill texture to anchor to
            local healthFillTexture = frame.healthBar:GetStatusBarTexture()
            
            -- Calculate heal prediction bar size
            local healWidth = barWidth * clampedHealPercent
            local healHeight = barHeight * clampedHealPercent
            
            if healthFillTexture then
                -- Anchor to health fill texture edge using two-point anchoring for exact height match
                if healthOrient == "HORIZONTAL" then
                    customBar:SetOrientation("HORIZONTAL")
                    customBar:SetReverseFill(false)
                    customBar:SetWidth(healWidth)
                    customBar:SetPoint("TOPLEFT", healthFillTexture, "TOPRIGHT", 0, 0)
                    customBar:SetPoint("BOTTOMLEFT", healthFillTexture, "BOTTOMRIGHT", 0, 0)
                elseif healthOrient == "HORIZONTAL_INV" then
                    customBar:SetOrientation("HORIZONTAL")
                    customBar:SetReverseFill(true)
                    customBar:SetWidth(healWidth)
                    customBar:SetPoint("TOPRIGHT", healthFillTexture, "TOPLEFT", 0, 0)
                    customBar:SetPoint("BOTTOMRIGHT", healthFillTexture, "BOTTOMLEFT", 0, 0)
                elseif healthOrient == "VERTICAL" then
                    customBar:SetOrientation("VERTICAL")
                    customBar:SetReverseFill(false)
                    customBar:SetHeight(healHeight)
                    customBar:SetPoint("BOTTOMLEFT", healthFillTexture, "TOPLEFT", 0, 0)
                    customBar:SetPoint("BOTTOMRIGHT", healthFillTexture, "TOPRIGHT", 0, 0)
                elseif healthOrient == "VERTICAL_INV" then
                    customBar:SetOrientation("VERTICAL")
                    customBar:SetReverseFill(true)
                    customBar:SetHeight(healHeight)
                    customBar:SetPoint("TOPLEFT", healthFillTexture, "BOTTOMLEFT", 0, 0)
                    customBar:SetPoint("TOPRIGHT", healthFillTexture, "BOTTOMRIGHT", 0, 0)
                end
            else
                -- Fallback: calculate position manually with two-point anchoring
                local healthWidth = barWidth * healthPercent
                local healthHeight = barHeight * healthPercent
                
                if healthOrient == "HORIZONTAL" then
                    customBar:SetOrientation("HORIZONTAL")
                    customBar:SetReverseFill(false)
                    customBar:SetWidth(healWidth)
                    customBar:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", inset + healthWidth, -inset)
                    customBar:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", inset + healthWidth, inset)
                elseif healthOrient == "HORIZONTAL_INV" then
                    customBar:SetOrientation("HORIZONTAL")
                    customBar:SetReverseFill(true)
                    customBar:SetWidth(healWidth)
                    customBar:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", -inset - healthWidth, -inset)
                    customBar:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", -inset - healthWidth, inset)
                elseif healthOrient == "VERTICAL" then
                    customBar:SetOrientation("VERTICAL")
                    customBar:SetReverseFill(false)
                    customBar:SetHeight(healHeight)
                    customBar:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", inset, inset + healthHeight)
                    customBar:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", -inset, inset + healthHeight)
                elseif healthOrient == "VERTICAL_INV" then
                    customBar:SetOrientation("VERTICAL")
                    customBar:SetReverseFill(true)
                    customBar:SetHeight(healHeight)
                    customBar:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", inset, -inset - healthHeight)
                    customBar:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", -inset, -inset - healthHeight)
                end
            end
            
            customBar:SetMinMaxValues(0, 1)
            customBar:SetValue(1)
            if customBar.bg then customBar.bg:Hide() end
        else
            -- Floating mode - need to set position and size
            customBar:ClearAllPoints()
            customBar:SetParent(frame)
            customBar:SetFrameStrata(frame:GetFrameStrata())
            
            local healthLevel = frame.healthBar:GetFrameLevel()
            local floatingLevel = db.healPredictionFrameLevel or 12
            customBar:SetFrameLevel(floatingLevel)
            
            local orientation = db.healPredictionOrientation or "HORIZONTAL"
            customBar:SetOrientation(orientation)
            customBar:SetReverseFill(db.healPredictionReverse or false)
            
            local w = db.healPredictionWidth or 50
            local h = db.healPredictionHeight or 6
            
            if orientation == "VERTICAL" then
                customBar:SetWidth(h)
                customBar:SetHeight(w)
            else
                customBar:SetWidth(w)
                customBar:SetHeight(h)
            end
            
            local anchor = db.healPredictionAnchor or "CENTER"
            local x = db.healPredictionX or 0
            local y = db.healPredictionY or 0
            customBar:SetPoint(anchor, frame, anchor, x, y)
            
            customBar:SetMinMaxValues(0, 1)
            customBar:SetValue(healPredictionPercent)
            
            if customBar.bg then 
                customBar.bg:Show() 
                local bgC = db.healPredictionBackgroundColor or {r = 0, g = 0, b = 0, a = 0.5}
                customBar.bg:SetColorTexture(bgC.r, bgC.g, bgC.b, bgC.a)
            end
        end
        customBar:Show()
    else
        customBar:Hide()
    end
end

-- Update test power bar (unified for party and raid)
function DF:UpdateTestPowerBar(frame, testData)
    if not frame then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Check if resource bar should be shown
    if not db.resourceBarEnabled then
        if frame.dfPowerBar then frame.dfPowerBar:Hide() end
        return
    end
    
    -- Check role-based filtering
    local showBar = true
    local hasAnyRoleFilter = db.resourceBarShowHealer or db.resourceBarShowTank or db.resourceBarShowDPS
    if hasAnyRoleFilter then
        if testData.role == "HEALER" then
            showBar = db.resourceBarShowHealer == true
        elseif testData.role == "TANK" then
            showBar = db.resourceBarShowTank == true
        else
            showBar = db.resourceBarShowDPS == true
        end
    else
        showBar = false
    end

    -- Check class-based filtering
    if showBar then
        local classFilter = db.resourceBarClassFilter
        if classFilter and testData.class and classFilter[testData.class] == false then
            showBar = false
        end
    end

    if not showBar then
        if frame.dfPowerBar then frame.dfPowerBar:Hide() end
        return
    end
    
    -- Power bar should already exist from Frames/Create.lua
    if not frame.dfPowerBar then return end
    
    local bar = frame.dfPowerBar
    local powerHeight = db.resourceBarHeight or 4
    local powerAnchor = db.resourceBarAnchor or "BOTTOM"
    
    -- Position power bar (floating style - anchored to a point, not spanning frame)
    bar:ClearAllPoints()

    local orientation = db.resourceBarOrientation or "HORIZONTAL"
    bar:SetOrientation(orientation)
    bar:SetReverseFill(db.resourceBarReverseFill or false)

    local isVertical = (orientation == "VERTICAL")
    local length = db.resourceBarWidth or 50
    local thickness = db.resourceBarHeight or 4

    if db.pixelPerfect and DF.PixelPerfect then
        length = DF:PixelPerfect(length)
        thickness = DF:PixelPerfect(thickness)
    end

    -- Compute health bar dimensions from settings (not GetWidth/GetHeight which
    -- can return stale values before WoW layout processes anchor changes)
    local padding = db.framePadding or 0
    local frameWidth = db.frameWidth or 120
    local frameHeight = db.frameHeight or 50
    if db.pixelPerfect and DF.PixelPerfect then
        frameWidth = DF:PixelPerfect(frameWidth)
        frameHeight = DF:PixelPerfect(frameHeight)
        padding = DF:PixelPerfect(padding)
    end
    local healthBarWidth = frameWidth - (2 * padding)
    local healthBarHeight = frameHeight - (2 * padding)

    if isVertical then
        bar:SetWidth(thickness)
        bar:SetHeight(length)
        if db.resourceBarMatchWidth then
            if healthBarHeight > 1 then
                bar:SetHeight(healthBarHeight)
            end
        end
    else
        bar:SetWidth(length)
        bar:SetHeight(thickness)
        if db.resourceBarMatchWidth then
            if healthBarWidth > 1 then
                bar:SetWidth(healthBarWidth)
            end
        end
    end

    local offsetX = db.resourceBarX or 0
    local offsetY = db.resourceBarY or 0
    bar:SetPoint(powerAnchor, frame, powerAnchor, offsetX, offsetY)
    
    -- Set value
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(testData.powerPercent or 0.8)
    
    -- Set color based on role using customizable power colors
    local powerToken
    if testData.role == "HEALER" then
        powerToken = "MANA"
    elseif testData.role == "TANK" then
        powerToken = "RAGE"
    else
        powerToken = "ENERGY"
    end

    local classColor = db.resourceBarClassColor and testData.class and DF:GetClassColor(testData.class)
    if classColor then
        bar:SetStatusBarColor(classColor.r, classColor.g, classColor.b, 1)
    else
        local powerColor = DF:GetPowerColor(powerToken)
        bar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b, 1)
    end
    
    -- Background visibility and color
    if bar.bg then
        if db.resourceBarBackgroundEnabled ~= false then
            bar.bg:Show()
            local bgC = db.resourceBarBackgroundColor or {r = 0.1, g = 0.1, b = 0.1, a = 0.8}
            bar.bg:SetColorTexture(bgC.r, bgC.g, bgC.b, bgC.a or 0.8)
        else
            bar.bg:Hide()
        end
    end
    
    -- Frame level - relative to main frame, not health bar
    local frameLevelOffset = db.resourceBarFrameLevel or 2
    bar:SetFrameLevel(frame:GetFrameLevel() + frameLevelOffset)
    
    -- Border visibility, color, and frame level
    if bar.border then
        bar.border:SetFrameLevel(bar:GetFrameLevel() + 1)
        if db.resourceBarBorderEnabled then
            bar.border:Show()
            local borderC = db.resourceBarBorderColor or {r = 0, g = 0, b = 0, a = 1}
            bar.border:SetBackdropBorderColor(borderC.r, borderC.g, borderC.b, borderC.a or 1)
        else
            bar.border:Hide()
        end
    end
    
    -- Apply dead / health-based / OOR alpha
    local alpha = 1.0
    if frame.dfTestDeadFadeAlphas and frame.dfTestDeadFadeAlphas.power then
        alpha = frame.dfTestDeadFadeAlphas.power
    elseif frame.dfTestHealthFadeAlphas and frame.dfTestHealthFadeAlphas.power then
        alpha = frame.dfTestHealthFadeAlphas.power
    elseif frame.dfTestOORAlphas and frame.dfTestOORAlphas.power then
        alpha = frame.dfTestOORAlphas.power
    end
    bar:SetAlpha(alpha)
    bar:Show()
end


function DF:ShowTestFrames(silent)
    if InCombatLockdown() then
        print("|cffff9900DandersFrames:|r " .. L["Cannot enter test mode during combat."])
        return
    end

    -- Respect mode-enable flag: party test requires party frames
    if DF.db and DF.db.partyEnabled == false then
        print("|cffff9900DandersFrames:|r " .. L["Party frames are disabled. Enable them in General settings to use party test mode."])
        return
    end

    local db = DF:GetDB()
    DF.testMode = true
    
    -- Ensure test frame pool is created
    if not DF.testFramePoolInitialized then
        DF:CreateTestFramePool()
    end
    
    -- Hide ALL live frames via state drivers (combat-safe)
    -- If combat starts, state drivers auto-show the correct live frames
    DF:SetTestModeStateDrivers()
    
    -- Hide test raid container if showing party test
    if DF.testRaidContainer then
        DF.testRaidContainer:Hide()
    end
    
    -- Position and show test party container
    DF:PositionTestPartyContainer()
    DF.testPartyContainer:Show()
    
    -- Get test frame count
    local testFrameCount = db.testFrameCount or 5
    
    -- Show and update test frames
    for i = 0, 4 do
        local frame = DF.testPartyFrames[i]
        if frame then
            if i < testFrameCount then
                frame:Show()
                DF:ApplyTestFrameLayout(frame)
                DF:UpdateTestFrame(frame, i, true)  -- true = apply layout
            else
                frame:Hide()
            end
        end
    end
    
    -- Position test frames
    DF:LightweightPositionPartyTestFrames(testFrameCount)
    
    -- Start animation if enabled
    if db.testAnimateHealth then
        DF:StartTestAnimation()
    end
    
    -- Initialize and update test pet frames
    if DF.InitializeTestPetFrames then
        DF:InitializeTestPetFrames()
        DF:UpdateAllPetFrames(true)
    end

    -- Update dispel overlays for test mode
    if DF.UpdateAllTestDispelGlow then
        C_Timer.After(0.1, function()
            DF:UpdateAllTestDispelGlow()
        end)
    end
    
    -- Update my buff indicators for test mode
    if DF.UpdateAllTestMyBuffIndicator then
        C_Timer.After(0.1, function()
            DF:UpdateAllTestMyBuffIndicator()
        end)
    end
    
    -- Update targeted spells for test mode
    if DF.UpdateAllTestTargetedSpell then
        C_Timer.After(0.1, function()
            DF:UpdateAllTestTargetedSpell()
        end)
    end
    
    -- Refresh class power (show/hide based on testShowClassPower)
    if DF.RefreshClassPower then
        DF:RefreshClassPower()
    end
    
    if not silent then
        print("|cff00ff00DandersFrames:|r " .. L["Test mode enabled."])
    end

    -- Update permanent mover for party test mode
    C_Timer.After(0.1, function()
        DF:UpdatePermanentMoverVisibility()
        DF:UpdatePermanentMoverAnchor("party")
    end)

    -- Populate enabled boss-mode pinned sets with fake data
    if DF.PinnedFrames and DF.PinnedFrames.EnterTestMode then
        DF.PinnedFrames:EnterTestMode()
    end
end

-- Refresh all test frames (call this when settings change in test mode)
function DF:RefreshTestFrames()
    if not DF.testMode and not DF.raidTestMode then return end
    
    local db = DF:GetDB()
    local raidDb = DF:GetRaidDB()
    
    -- Update party test frames
    if DF.testMode then
        local testFrameCount = db.testFrameCount or 5
        
        for i = 0, 4 do
            local frame = DF.testPartyFrames[i]
            if frame and frame:IsShown() then
                DF:UpdateTestFrame(frame, i)
            end
        end
    end
    
    -- Update raid test frames
    if DF.raidTestMode then
        local testFrameCount = raidDb.raidTestFrameCount or 10
        for i = 1, testFrameCount do
            local frame = DF.testRaidFrames[i]
            if frame and frame:IsShown() then
                DF:UpdateTestFrame(frame, i)
            end
        end
    end
end

-- Apply layout/style settings to a test frame (fonts, sizes, textures, borders, etc.)
-- This should be called when visual settings change, not just when data changes
function DF:ApplyTestFrameLayout(frame)
    if not frame then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Apply frame size
    local frameWidth = db.frameWidth or 120
    local frameHeight = db.frameHeight or 50
    if db.pixelPerfect then
        frameWidth = DF:PixelPerfect(frameWidth)
        frameHeight = DF:PixelPerfect(frameHeight)
    end
    frame:SetSize(frameWidth, frameHeight)
    
    -- Apply health bar settings
    if frame.healthBar then
        -- Texture
        local healthTex = db.healthTexture or "Interface\\TargetingFrame\\UI-StatusBar"
        frame.healthBar:SetStatusBarTexture(healthTex)
        
        -- Orientation
        local orientation = db.healthOrientation or "HORIZONTAL"
        if orientation == "HORIZONTAL" then
            frame.healthBar:SetOrientation("HORIZONTAL")
            frame.healthBar:SetReverseFill(false)
            frame.healthBar:SetRotatesTexture(false)
        elseif orientation == "HORIZONTAL_INV" then
            frame.healthBar:SetOrientation("HORIZONTAL")
            frame.healthBar:SetReverseFill(true)
            frame.healthBar:SetRotatesTexture(false)
        elseif orientation == "VERTICAL" then
            frame.healthBar:SetOrientation("VERTICAL")
            frame.healthBar:SetReverseFill(false)
            frame.healthBar:SetRotatesTexture(true)
        elseif orientation == "VERTICAL_INV" then
            frame.healthBar:SetOrientation("VERTICAL")
            frame.healthBar:SetReverseFill(true)
            frame.healthBar:SetRotatesTexture(true)
        end
        
        -- Also apply to missing health bar
        if frame.missingHealthBar then
            local missingTex = db.missingHealthTexture
            if not missingTex or missingTex == "" then
                missingTex = healthTex
            end
            frame.missingHealthBar:SetStatusBarTexture(missingTex)
            
            if orientation == "HORIZONTAL" then
                frame.missingHealthBar:SetOrientation("HORIZONTAL")
                frame.missingHealthBar:SetReverseFill(true)
                frame.missingHealthBar:SetRotatesTexture(false)
            elseif orientation == "HORIZONTAL_INV" then
                frame.missingHealthBar:SetOrientation("HORIZONTAL")
                frame.missingHealthBar:SetReverseFill(false)
                frame.missingHealthBar:SetRotatesTexture(false)
            elseif orientation == "VERTICAL" then
                frame.missingHealthBar:SetOrientation("VERTICAL")
                frame.missingHealthBar:SetReverseFill(true)
                frame.missingHealthBar:SetRotatesTexture(true)
            elseif orientation == "VERTICAL_INV" then
                frame.missingHealthBar:SetOrientation("VERTICAL")
                frame.missingHealthBar:SetReverseFill(false)
                frame.missingHealthBar:SetRotatesTexture(true)
            end
        end
    end
    
    -- Apply frame border
    if frame.border then
        local showBorder = db.showFrameBorder ~= false
        local borderSize = db.borderSize or 1
        local borderColor = db.borderColor or {r = 0, g = 0, b = 0, a = 1}
        
        if db.pixelPerfect then
            borderSize = DF:PixelPerfect(borderSize)
        end
        
        if showBorder and frame.border.top then
            frame.border.top:SetHeight(borderSize)
            frame.border.top:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            frame.border.top:Show()
            
            frame.border.bottom:SetHeight(borderSize)
            frame.border.bottom:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            frame.border.bottom:Show()
            
            frame.border.left:SetWidth(borderSize)
            frame.border.left:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            frame.border.left:Show()
            
            frame.border.right:SetWidth(borderSize)
            frame.border.right:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            frame.border.right:Show()
        elseif frame.border.top then
            frame.border.top:Hide()
            frame.border.bottom:Hide()
            frame.border.left:Hide()
            frame.border.right:Hide()
        end
    end
    
    -- Apply fonts using ApplyFrameStyle (handles name, health, status text fonts)
    if DF.ApplyFrameStyle then
        DF:ApplyFrameStyle(frame)
    end
    
    -- Apply aura layouts (handles aura fonts, sizes, positions, swipe settings)
    if DF.ApplyAuraLayout then
        DF:ApplyAuraLayout(frame, "BUFF")
        DF:ApplyAuraLayout(frame, "DEBUFF")
    end
    
    -- Apply power bar layout (delegate to shared function which handles
    -- match-width, role filtering, background, border, frame level, etc.)
    if DF.ApplyResourceBarLayout then
        DF:ApplyResourceBarLayout(frame)
    end
end

-- Full refresh with layout application (use on test mode start or when settings change)
function DF:RefreshTestFramesWithLayout()
    if not DF.testMode and not DF.raidTestMode then return end
    
    local db = DF:GetDB()
    local raidDb = DF:GetRaidDB()
    
    -- Update party test frames with full layout
    if DF.testMode then
        local testFrameCount = db.testFrameCount or 5
        
        for i = 0, 4 do
            local frame = DF.testPartyFrames[i]
            if frame then
                -- Apply layout settings first
                DF:ApplyTestFrameLayout(frame)
                
                if frame:IsShown() then
                    DF:UpdateTestFrame(frame, i, true)  -- true = apply aura layout
                end
            end
        end
        
        -- Re-position frames (handles sorting and arrangement)
        DF:LightweightPositionPartyTestFrames(testFrameCount)
    end
    
    -- Update raid test frames with full layout
    if DF.raidTestMode then
        local testFrameCount = raidDb.raidTestFrameCount or 10
        
        for i = 1, 40 do
            local frame = DF.testRaidFrames[i]
            if frame then
                -- Apply layout settings first
                DF:ApplyTestFrameLayout(frame)
                
                if frame:IsShown() then
                    DF:UpdateTestFrame(frame, i, true)
                end
            end
        end
        
        -- Re-position raid frames (LightweightPositionRaidTestFrames handles both group and flat layout)
        DF:LightweightPositionRaidTestFrames(testFrameCount)

        -- Re-anchor group labels to the (potentially re-sorted) first frame of each group
        if raidDb.raidUseGroups and raidDb.groupLabelEnabled and DF.UpdateRaidGroupLabels then
            DF:UpdateRaidGroupLabels()
        end
    end

    -- Update highlights
    if DF.testMode or DF.raidTestMode then
        DF:UpdateAllTestHighlights()
    end

    -- Re-anchor permanent mover to updated test frames
    if DF.testMode then
        DF:UpdatePermanentMoverAnchor("party")
    end
    if DF.raidTestMode then
        DF:UpdatePermanentMoverAnchor("raid")
    end
end

-- Throttled layout refresh for slider changes (avoids flickering)
DF.lastLayoutRefresh = 0
function DF:RefreshTestFramesWithLayoutThrottled()
    local now = GetTime()
    -- Only apply layout once every 0.3 seconds to prevent flickering during slider drags
    if now - DF.lastLayoutRefresh < 0.3 then
        -- Just do a regular refresh without layout
        DF:RefreshTestFrames()
        return
    end
    DF.lastLayoutRefresh = now
    DF:RefreshTestFramesWithLayout()
end

function DF:HideTestFrames(silent)
    DF.testMode = false
    
    -- Stop animation only if raid test mode isn't using it
    local raidDb = DF:GetRaidDB()
    if not (DF.raidTestMode and raidDb.testAnimateHealth) then
        DF:StopTestAnimation()
    end
    
    -- Hide all test party frames and clean up test elements
    local ADEngine = DF.AuraDesigner and DF.AuraDesigner.Engine
    for i = 0, 4 do
        local frame = DF.testPartyFrames[i]
        if frame then
            -- Clear Aura Designer indicators (borders are parented to UIParent
            -- and survive frame:Hide, so they must be explicitly cleared)
            if ADEngine then ADEngine:ClearFrame(frame) end
            frame:Hide()
            -- Clean up test mode visuals
            if frame.absorbAttachedTexture then frame.absorbAttachedTexture:Hide() end
            if frame.healAbsorbAttachedTexture then frame.healAbsorbAttachedTexture:Hide() end
            if frame.absorbOverflowBar then frame.absorbOverflowBar:Hide() end
            if frame.defensiveIcon then frame.defensiveIcon:Hide() end
            DF:HideTestBossDebuffs(frame)
            if DF.HideAllTargetedSpells then
                DF:HideAllTargetedSpells(frame)
            end
            if DF.HideTestClassPower then
                DF:HideTestClassPower(frame)
            end
        end
    end

    -- Hide test container
    if DF.testPartyContainer then
        DF.testPartyContainer:Hide()
    end

    -- Hide test pet frames
    if DF.HideAllTestPetFrames then
        DF:HideAllTestPetFrames()
    end

    -- Hide personal targeted spell test icons
    if DF.HideTestPersonalTargetedSpells then
        DF:HideTestPersonalTargetedSpells()
    end

    -- Hide Targeted List demo bars
    if DF.HideTestTargetedList then
        DF:HideTestTargetedList()
    end
    
    -- Restore live frame visibility
    -- Clear state drivers so UpdateHeaderVisibility manages normally
    DF:ClearTestModeStateDrivers()
    if not InCombatLockdown() then
        if DF.UpdateHeaderVisibility then
            DF:UpdateHeaderVisibility()
        end
        if DF.RefreshClassPower then
            DF:RefreshClassPower()
        end
    end
    
    -- Update dispel overlays based on real unit data
    if DF.UpdateAllDispelOverlays then
        C_Timer.After(0.2, function()
            DF:UpdateAllDispelOverlays()
        end)
    end
    
    -- Update missing buff icons immediately when leaving test mode
    if not InCombatLockdown() and DF.UpdateAllMissingBuffIcons then
        C_Timer.After(0.1, function()
            if not InCombatLockdown() then
                DF:UpdateAllMissingBuffIcons()
            end
        end)
    end
    
    -- Update pet frames based on real unit data
    if DF.UpdateAllPetFrames then
        C_Timer.After(0.1, function()
            DF:UpdateAllPetFrames(true)
        end)
    end
    
    if not silent then
        print("|cff00ff00DandersFrames:|r " .. L["Test mode disabled."])
    end

    -- Update permanent mover after exiting party test mode
    C_Timer.After(0.1, function()
        DF:UpdatePermanentMoverVisibility()
        DF:UpdatePermanentMoverAnchor("party")
    end)

    -- Exit boss-mode pinned test only if raid test isn't still running
    if DF.PinnedFrames and DF.PinnedFrames.ExitTestMode
        and not DF.raidTestMode then
        DF.PinnedFrames:ExitTestMode()
    end
end

-- Toggle test mode (mode-aware based on GUI.SelectedMode)
function DF:ToggleTestMode()
    -- Cannot toggle test mode during combat (secure frame restrictions)
    if InCombatLockdown() then
        print("|cffff9900DandersFrames:|r " .. L["Cannot toggle test mode during combat."])
        return
    end

    local isRaidMode = DF.GUI and DF.GUI.SelectedMode == "raid"

    if isRaidMode then
        local db = DF:GetRaidDB()
        -- Don't allow toggling test mode off while frames are unlocked
        if not db.raidLocked and DF.raidTestMode then
            print("|cffff9900DandersFrames:|r " .. L["Cannot disable test mode while frames are unlocked. Lock frames first."])
            return
        end

        -- Toggle raid test mode
        if DF.raidTestMode then
            DF:HideRaidTestFrames()
        else
            DF:ShowRaidTestFrames()
        end
    else
        local db = DF:GetDB()
        -- Don't allow toggling test mode off while frames are unlocked
        if not db.locked and DF.testMode then
            print("|cffff9900DandersFrames:|r " .. L["Cannot disable test mode while frames are unlocked. Lock frames first."])
            return
        end

        -- Toggle party test mode
        if DF.testMode then
            DF:HideTestFrames()
        else
            DF:ShowTestFrames()
        end
    end
end

-- Show raid test frames
function DF:ShowRaidTestFrames()
    if InCombatLockdown() then
        print("|cffff9900DandersFrames:|r " .. L["Cannot enter test mode during combat."])
        return
    end

    -- Respect mode-enable flag: raid test requires raid frames
    if DF.db and DF.db.raidEnabled == false then
        print("|cffff9900DandersFrames:|r " .. L["Raid frames are disabled. Enable them in General settings to use raid test mode."])
        return
    end

    local db = DF:GetRaidDB()
    DF.raidTestMode = true
    
    -- Ensure test frame pool is created
    if not DF.testFramePoolInitialized then
        DF:CreateTestFramePool()
    end
    
    -- Hide ALL live frames via state drivers (combat-safe)
    -- If combat starts, state drivers auto-show the correct live frames
    DF:SetTestModeStateDrivers()
    
    -- Hide test party container if showing raid test
    if DF.testPartyContainer then
        DF.testPartyContainer:Hide()
    end
    
    -- Hide party pet frames (both live and test)
    if DF.petFrames and DF.petFrames.player then
        DF.petFrames.player:Hide()
    end
    for i = 1, 4 do
        if DF.partyPetFrames and DF.partyPetFrames[i] then
            DF.partyPetFrames[i]:Hide()
        end
    end
    if DF.HideAllTestPetFrames then
        DF:HideAllTestPetFrames()
    end
    
    -- Position and show test raid container
    DF:PositionTestRaidContainer()
    DF.testRaidContainer:Show()
    
    -- Update raid frames with test data
    DF:UpdateRaidTestFrames()
    
    -- Update group labels for test mode
    if DF.UpdateRaidGroupLabels then
        C_Timer.After(0.05, function()
            DF:UpdateRaidGroupLabels()
        end)
    end
    
    -- Start animation if enabled
    if db.testAnimateHealth then
        DF:StartTestAnimation()
    end
    
    -- Initialize and update test raid pet frames
    if DF.InitializeTestRaidPetFrames then
        DF:InitializeTestRaidPetFrames()
        DF:UpdateAllRaidPetFrames(true)
    end

    -- Update dispel overlays for test mode
    if DF.UpdateAllTestDispelGlow then
        C_Timer.After(0.1, function()
            DF:UpdateAllTestDispelGlow()
        end)
    end

    -- Update my buff indicators for test mode
    if DF.UpdateAllTestMyBuffIndicator then
        C_Timer.After(0.1, function()
            DF:UpdateAllTestMyBuffIndicator()
        end)
    end

    -- Update targeted spells for test mode
    if DF.UpdateAllTestTargetedSpell then
        C_Timer.After(0.1, function()
            DF:UpdateAllTestTargetedSpell()
        end)
    end

    -- Update GUI
    if DF.GUI and DF.GUI.UpdateThemeColors then
        DF.GUI.UpdateThemeColors()
    end

    -- Update permanent mover for raid test mode
    C_Timer.After(0.1, function()
        DF:UpdatePermanentMoverVisibility()
        DF:UpdatePermanentMoverAnchor("raid")
    end)

    -- Populate enabled boss-mode pinned sets with fake data
    if DF.PinnedFrames and DF.PinnedFrames.EnterTestMode then
        DF.PinnedFrames:EnterTestMode()
    end
end

-- Hide raid test frames
function DF:HideRaidTestFrames()
    DF.raidTestMode = false
    
    -- Stop animation if party test mode isn't using it
    local partyDb = DF:GetDB()
    if not (DF.testMode and partyDb.testAnimateHealth) then
        DF:StopTestAnimation()
    end
    
    -- Hide all test raid frames and clean up test elements
    local ADEngine = DF.AuraDesigner and DF.AuraDesigner.Engine
    for i = 1, 40 do
        local frame = DF.testRaidFrames[i]
        if frame then
            -- Clear Aura Designer indicators (borders are parented to UIParent
            -- and survive frame:Hide, so they must be explicitly cleared)
            if ADEngine then ADEngine:ClearFrame(frame) end
            frame:Hide()
            -- Clean up test mode visuals
            if frame.absorbAttachedTexture then frame.absorbAttachedTexture:Hide() end
            if frame.healAbsorbAttachedTexture then frame.healAbsorbAttachedTexture:Hide() end
            if frame.absorbOverflowBar then frame.absorbOverflowBar:Hide() end
            if frame.defensiveIcon then frame.defensiveIcon:Hide() end
            DF:HideTestBossDebuffs(frame)
            if DF.HideAllTargetedSpells then
                DF:HideAllTargetedSpells(frame)
            end
            if DF.HideTestClassPower then
                DF:HideTestClassPower(frame)
            end
        end
    end

    -- Hide test container
    if DF.testRaidContainer then
        DF.testRaidContainer:Hide()
    end

    -- Hide test raid pet frames
    if DF.HideAllTestRaidPetFrames then
        DF:HideAllTestRaidPetFrames()
    end

    -- Hide personal targeted spell test icons
    if DF.HideTestPersonalTargetedSpells then
        DF:HideTestPersonalTargetedSpells()
    end

    -- Hide Targeted List demo bars
    if DF.HideTestTargetedList then
        DF:HideTestTargetedList()
    end

    -- Hide group labels (they will be re-shown by UpdateRaidLayout if needed)
    if DF.raidGroupLabels then
        for g = 1, 8 do
            if DF.raidGroupLabels[g] then
                DF.raidGroupLabels[g]:Hide()
                if DF.raidGroupLabels[g].shadow then
                    DF.raidGroupLabels[g].shadow:Hide()
                end
            end
        end
    end
    
    -- Restore live frame visibility
    -- Clear state drivers so UpdateHeaderVisibility manages normally
    DF:ClearTestModeStateDrivers()
    if not InCombatLockdown() then
        if DF.UpdateHeaderVisibility then
            DF:UpdateHeaderVisibility()
        end
    end
    
    -- Update dispel overlays based on real unit data
    if DF.UpdateAllDispelOverlays then
        C_Timer.After(0.2, function()
            DF:UpdateAllDispelOverlays()
        end)
    end
    
    -- Update raid pet frames based on real unit data
    if DF.UpdateAllRaidPetFrames then
        C_Timer.After(0.1, function()
            DF:UpdateAllRaidPetFrames(true)
        end)
    end
    
    -- Update GUI
    if DF.GUI and DF.GUI.UpdateThemeColors then
        DF.GUI.UpdateThemeColors()
    end

    -- Update permanent mover after exiting raid test mode
    C_Timer.After(0.1, function()
        DF:UpdatePermanentMoverVisibility()
        DF:UpdatePermanentMoverAnchor("party")
    end)

    -- Exit boss-mode pinned test only if party test isn't still running
    if DF.PinnedFrames and DF.PinnedFrames.ExitTestMode
        and not DF.testMode then
        DF.PinnedFrames:ExitTestMode()
    end
end

-- Update raid test frames with test data
function DF:UpdateRaidTestFrames()
    local db = DF:GetRaidDB()
    local testFrameCount = db.raidTestFrameCount or 10
    
    -- Show/hide test frames (respecting group visibility settings)
    for i = 1, 40 do
        local frame = DF.testRaidFrames[i]
        if frame then
            if i <= testFrameCount then
                -- Check if this frame's group is visible
                local groupNum = math.ceil(i / 5)
                local showGroup = db.raidGroupVisible and db.raidGroupVisible[groupNum]
                if showGroup == nil then showGroup = true end
                if showGroup then
                    frame:Show()
                else
                    frame:Hide()
                end
            else
                frame:Hide()
            end
        end
    end
    
    -- Position test frames
    DF:LightweightPositionRaidTestFrames(testFrameCount)
    
    -- Apply test data to visible frames
    for i = 1, testFrameCount do
        local frame = DF.testRaidFrames[i]
        if frame then
            -- Use unified UpdateTestFrame with layout (true = apply aura layout)
            DF:ApplyTestFrameLayout(frame)
            DF:UpdateTestFrame(frame, i, true)
        end
    end
    
    -- Update group labels if enabled (only in group-based layout)
    if db.raidUseGroups and db.groupLabelEnabled and DF.UpdateRaidGroupLabels then
        DF:UpdateRaidGroupLabels()
    end
    
    -- Handle animation
    if db.testAnimateHealth then
        DF:StartTestAnimation()
    else
        -- Don't stop animation if party test mode is also active and animating
        local partyDb = DF:GetDB()
        if not (DF.testMode and partyDb.testAnimateHealth) then
            DF:StopTestAnimation()
        end
    end
end

-- Lightweight version for frame count changes during dragging
-- Shows/hides frames and repositions them without full layout recalculation
-- Note: This only applies to test mode - frame count slider is only visible in test mode
function DF:LightweightUpdateTestFrameCount()
    local isRaidMode = DF.GUI and DF.GUI.SelectedMode == "raid"
    
    -- Only works in test mode
    if isRaidMode then
        if not DF.raidTestMode then return end
    else
        if not DF.testMode then return end
    end
    
    if isRaidMode then
        local db = DF:GetRaidDB()
        local testFrameCount = db.raidTestFrameCount or 10
        
        -- First pass: show/hide test frames (respecting group visibility settings)
        for i = 1, 40 do
            local frame = DF.testRaidFrames[i]
            if frame then
                if i <= testFrameCount then
                    -- Check if this frame's group is visible
                    local groupNum = math.ceil(i / 5)
                    local showGroup = db.raidGroupVisible and db.raidGroupVisible[groupNum]
                    if showGroup == nil then showGroup = true end
                    if showGroup then
                        frame:Show()
                        -- Update test data without layout
                        DF:UpdateTestFrame(frame, i, false)
                    else
                        frame:Hide()
                    end
                else
                    frame:Hide()
                end
            end
        end
        
        -- Second pass: reposition visible frames using layout logic
        DF:LightweightPositionRaidTestFrames(testFrameCount)
    else
        -- Party mode
        local db = DF:GetDB()
        local testFrameCount = db.testFrameCount or 5
        
        -- Test party frames (indices 0-4)
        for i = 0, 4 do
            local frame = DF.testPartyFrames[i]
            if frame then
                if i < testFrameCount then
                    frame:Show()
                    DF:UpdateTestFrame(frame, i, false)
                else
                    frame:Hide()
                end
            end
        end
        
        -- Reposition party frames
        DF:LightweightPositionPartyTestFrames(testFrameCount)
    end
end

-- Lightweight positioning for raid test frames
-- Includes support for groupAnchor, playerAnchor, and groupOrder
function DF:LightweightPositionRaidTestFrames(testFrameCount)
    local db = DF:GetRaidDB()
    if not DF.testRaidContainer then return end
    
    -- Check if using flat grid layout instead of group-based
    if not db.raidUseGroups then
        return DF:LightweightPositionRaidTestFramesFlat(testFrameCount)
    end
    
    -- Use SecureSort's group positioning functions
    local SecureSort = DF.SecureSort
    if not SecureSort then
        print("|cffff9900[DF SecureSort]|r SecureSort not available. Using flat layout.")
        return DF:LightweightPositionRaidTestFramesFlat(testFrameCount)
    end
    
    -- Update group layout params from current settings
    SecureSort:UpdateRaidGroupLayoutParams()
    local lp = SecureSort.raidGroupLayoutParams

    -- [LEAK-TEST] Simulates the proposed patch's mutation. Only writes when the tester
    -- opts in with: /run DandersFrames.debugLeakTestSimulate = true
    -- Purpose: verify whether the flag survives the next UpdateRaidGroupLayoutParams call
    -- and leaks into the live-frame positioning path.
    if DF.debugLeakTestSimulate then
        lp.testMode = true
        if DF.debugLeakTest then
            print("|cffffa500[DF LEAK-TEST]|r TestMode SIMULATED patch mutation: lp.testMode = true written")
        end
    end

    if DF.debugLeakTest then
        print(string.format(
            "|cffffa500[DF LEAK-TEST]|r LightweightPositionRaidTestFrames entered  lp.testMode=%s",
            tostring(lp.testMode)
        ))
    end

    -- Build frame list with test data for sorting
    local frameList = {}
    for i = 1, testFrameCount do
        local frame = DF.testRaidFrames[i]
        if frame and frame:IsShown() then
            local testData = DF:GetTestUnitData(i, true)  -- true = isRaid
            local groupNum = math.ceil(i / 5)  -- Test mode: 5 per group
            table.insert(frameList, {
                frame = frame,
                index = i,
                isPlayer = (i == 1),
                testData = testData,
                groupNum = groupNum
            })
            -- Set frame size
            frame:SetSize(lp.frameWidth, lp.frameHeight)
        end
    end
    
    -- Apply sorting if enabled (mirrors secure sort behavior)
    if db.sortEnabled and DF.Sort and DF.Sort.SortFrameList then
        frameList = DF.Sort:SortFrameList(frameList, db, true)  -- true = isTestMode
    end
    
    -- Build group membership from sorted frame list
    local groupPlayerCounts = {}  -- groupNum -> count of players
    local activeGroups = {}       -- groupNum -> true if has players
    local activeGroupList = {}    -- ordered list of active group numbers
    local groupCurrentPos = {}    -- groupNum -> current position (for sorted placement)
    
    for _, entry in ipairs(frameList) do
        local groupNum = entry.groupNum
        groupPlayerCounts[groupNum] = (groupPlayerCounts[groupNum] or 0) + 1
        
        if not activeGroups[groupNum] then
            activeGroups[groupNum] = true
            table.insert(activeGroupList, groupNum)
        end
    end
    
    -- Sort activeGroupList using custom display order from settings
    local displayOrder = db.raidGroupDisplayOrder or {1, 2, 3, 4, 5, 6, 7, 8}
    -- Build reverse lookup: group number -> display position
    local displayPos = {}
    for pos, groupNum in ipairs(displayOrder) do
        displayPos[groupNum] = pos
    end
    table.sort(activeGroupList, function(a, b)
        return (displayPos[a] or a) < (displayPos[b] or b)
    end)
    
    -- Calculate and set container size
    local totalWidth, totalHeight = SecureSort:CalculateRaidGroupContainerSize(#activeGroupList, lp)
    DF.testRaidContainer:SetSize(totalWidth, totalHeight)
    DF:SyncRaidMoverToContainer()

    -- Track which frame lands in the first slot of each group (for group label anchoring)
    DF.testGroupFirstFrame = DF.testGroupFirstFrame or {}
    wipe(DF.testGroupFirstFrame)

    -- Position each frame in sorted order (this applies sorting within groups)
    for _, entry in ipairs(frameList) do
        local frame = entry.frame
        local groupNum = entry.groupNum
        local playersInGroup = groupPlayerCounts[groupNum]

        -- Get position within group (increments for each frame in the group)
        local posInGroup = groupCurrentPos[groupNum] or 0
        groupCurrentPos[groupNum] = posInGroup + 1

        -- Store the first frame of each group for label anchoring
        if posInGroup == 0 then
            DF.testGroupFirstFrame[groupNum] = frame
        end

        -- Position using shared function
        SecureSort:PositionRaidFrameToGroupSlot(
            frame,
            groupNum,
            posInGroup,
            playersInGroup,
            activeGroupList,
            lp,
            DF.testRaidContainer
        )
    end
end

-- Lightweight positioning for raid test frames in flat (non-group) layout mode
function DF:LightweightPositionRaidTestFramesFlat(testFrameCount)
    local db = DF:GetRaidDB()
    if not DF.testRaidContainer then return end
    
    -- Use SecureSort's shared positioning function
    local SecureSort = DF.SecureSort
    if SecureSort then
        -- Update raid layout params from current settings
        SecureSort:UpdateRaidLayoutParams()
        
        -- Calculate container size (for max 40 players)
        local lp = SecureSort.raidLayoutParams
        local playersPerRow = lp.playersPerRow or 5
        local maxNumRows, maxNumCols
        if lp.horizontal then
            maxNumCols = playersPerRow
            maxNumRows = math.ceil(40 / playersPerRow)
        else
            maxNumRows = playersPerRow
            maxNumCols = math.ceil(40 / playersPerRow)
        end
        local maxWidth = maxNumCols * lp.frameWidth + (maxNumCols - 1) * lp.hSpacing
        local maxHeight = maxNumRows * lp.frameHeight + (maxNumRows - 1) * lp.vSpacing
        
        -- Size the container
        DF.testRaidContainer:SetSize(maxWidth, maxHeight)
        DF:SyncRaidMoverToContainer()

        -- Build frame list with test data for sorting
        local frameList = {}
        for i = 1, testFrameCount do
            local frame = DF.testRaidFrames[i]
            if frame and frame:IsShown() then
                local testData = DF:GetTestUnitData(i, true)  -- true = isRaid
                table.insert(frameList, {
                    frame = frame,
                    index = i,
                    isPlayer = (i == 1),  -- First frame is "player" in test mode
                    testData = testData
                })
                -- Set frame size
                frame:SetSize(lp.frameWidth, lp.frameHeight)
            end
        end
        
        -- Apply sorting if enabled (mirrors secure sort behavior)
        if db.sortEnabled and DF.Sort and DF.Sort.SortFrameList then
            frameList = DF.Sort:SortFrameList(frameList, db, true)  -- true = isTestMode
        end
        
        -- Position frames in sorted order using SecureSort positioning
        for slotIndex, entry in ipairs(frameList) do
            local slot = slotIndex - 1  -- Convert to 0-based slot
            SecureSort:PositionRaidFrameToSlot(entry.frame, slot, testFrameCount, lp, DF.testRaidContainer)
        end
        return
    end
    
    -- TODO: CLEANUP - Remove old positioning code below once SecureSort raid positioning is fully tested
    --[[ OLD POSITIONING CODE - COMMENTED OUT
    local frameWidth = db.frameWidth or 80
    local frameHeight = db.frameHeight or 35
    local playersPerRow = db.raidPlayersPerRow or 5
    local hSpacing = db.raidFlatHorizontalSpacing or 2
    local vSpacing = db.raidFlatVerticalSpacing or 2
    local growDirection = db.growDirection or "HORIZONTAL"
    local gridAnchor = db.raidFlatPlayerAnchor or "START"
    local reverseFill = db.raidFlatReverseFillOrder
    
    -- Apply pixel-perfect adjustments
    if db.pixelPerfect then
        frameWidth = DF:PixelPerfect(frameWidth)
        frameHeight = DF:PixelPerfect(frameHeight)
        hSpacing = DF:PixelPerfect(hSpacing)
        vSpacing = DF:PixelPerfect(vSpacing)
    end
    
    local horizontal = (growDirection == "HORIZONTAL")
    
    -- Calculate grid dimensions for visible players
    local numRows, numCols
    if horizontal then
        numCols = math.min(playersPerRow, testFrameCount)
        numRows = math.ceil(testFrameCount / playersPerRow)
    else
        numRows = math.min(playersPerRow, testFrameCount)
        numCols = math.ceil(testFrameCount / playersPerRow)
    end
    
    -- Calculate MAX grid dimensions for full 40-player raid (for container sizing)
    local maxNumRows, maxNumCols
    if horizontal then
        maxNumCols = playersPerRow
        maxNumRows = math.ceil(40 / playersPerRow)
    else
        maxNumRows = playersPerRow
        maxNumCols = math.ceil(40 / playersPerRow)
    end
    
    -- Calculate sizes
    local visibleWidth = numCols * frameWidth + (numCols - 1) * hSpacing
    local visibleHeight = numRows * frameHeight + (numRows - 1) * vSpacing
    local maxWidth = maxNumCols * frameWidth + (maxNumCols - 1) * hSpacing
    local maxHeight = maxNumRows * frameHeight + (maxNumRows - 1) * vSpacing
    
    -- Size the container to full 40-player size
    DF.raidContainer:SetSize(maxWidth, maxHeight)
    
    -- Position each visible frame
    for i = 1, testFrameCount do
        local frame = DF.raidFrames[i]
        if frame and frame:IsShown() then
            local pos = i - 1  -- 0-based position
            
            local row, col
            if horizontal then
                row = math.floor(pos / playersPerRow)
                col = pos % playersPerRow
                if reverseFill then
                    col = (playersPerRow - 1) - col
                end
            else
                col = math.floor(pos / playersPerRow)
                row = pos % playersPerRow
                if reverseFill then
                    row = (playersPerRow - 1) - row
                end
            end
            
            frame:ClearAllPoints()
            
            -- Position based on anchor
            if gridAnchor == "START" then
                local x = col * (frameWidth + hSpacing)
                local y = -row * (frameHeight + vSpacing)
                frame:SetPoint("TOPLEFT", DF.raidContainer, "TOPLEFT", x, y)
            elseif gridAnchor == "CENTER" then
                local halfGridWidth = visibleWidth / 2
                local halfGridHeight = visibleHeight / 2
                local x = -halfGridWidth + col * (frameWidth + hSpacing) + frameWidth / 2
                local y = halfGridHeight - row * (frameHeight + vSpacing) - frameHeight / 2
                frame:SetPoint("CENTER", DF.raidContainer, "CENTER", x, y)
            else  -- END
                local x = -col * (frameWidth + hSpacing)
                local y = row * (frameHeight + vSpacing)
                frame:SetPoint("BOTTOMRIGHT", DF.raidContainer, "BOTTOMRIGHT", x, y)
            end
            
            frame:SetSize(frameWidth, frameHeight)
        end
    end
    --]] -- END OLD POSITIONING CODE
end

-- Lightweight positioning for party test frames
function DF:LightweightPositionPartyTestFrames(testFrameCount)
    local db = DF:GetDB()
    if not DF.testPartyContainer then return end
    
    -- Use SecureSort's shared positioning function
    local SecureSort = DF.SecureSort
    if SecureSort then
        -- Update party layout params from current settings
        SecureSort:UpdateLayoutParams("party")
        local lp = SecureSort.layoutParams
        
        -- Calculate container size (max possible size for 5 frames)
        local containerWidth, containerHeight
        if lp.horizontal then
            containerWidth = 5 * lp.frameWidth + 4 * lp.spacing
            containerHeight = lp.frameHeight
        else
            containerWidth = lp.frameWidth
            containerHeight = 5 * lp.frameHeight + 4 * lp.spacing
        end
        
        -- Update container size
        DF.testPartyContainer:SetSize(containerWidth, containerHeight)
        
        -- Build frame list with test data for sorting
        local frameList = {}
        
        -- Test party frames (indices 0-4)
        for i = 0, 4 do
            local frame = DF.testPartyFrames[i]
            if frame and i < testFrameCount then
                local testData = DF:GetTestUnitData(i, false)  -- false = not raid
                table.insert(frameList, {
                    frame = frame,
                    index = i,
                    isPlayer = (i == 0),
                    testData = testData
                })
                frame:SetSize(lp.frameWidth, lp.frameHeight)
            end
        end
        
        -- Apply sorting if enabled (mirrors secure sort behavior)
        if db.sortEnabled and DF.Sort and DF.Sort.SortFrameList then
            frameList = DF.Sort:SortFrameList(frameList, db, true)  -- true = isTestMode
        end
        
        -- Position frames in sorted order using SecureSort positioning
        for slotIndex, entry in ipairs(frameList) do
            local slot = slotIndex - 1  -- Convert to 0-based slot
            SecureSort:PositionFrameToSlot(entry.frame, slot, #frameList, lp, DF.testPartyContainer)
        end
        return
    end
    
    -- Fallback: Old positioning code if SecureSort not available
    local frameWidth = db.frameWidth or 100
    local frameHeight = db.frameHeight or 50
    local spacing = db.frameSpacing or 2
    local growDirection = db.growDirection or "VERTICAL"
    local growthAnchor = db.growthAnchor or "START"
    
    -- Apply pixel-perfect adjustments
    if db.pixelPerfect then
        frameWidth = DF:PixelPerfect(frameWidth)
        frameHeight = DF:PixelPerfect(frameHeight)
        spacing = DF:PixelPerfect(spacing)
    end
    
    local horizontal = (growDirection == "HORIZONTAL")
    
    -- Calculate total size needed for visible frames
    local totalWidth, totalHeight
    if horizontal then
        totalWidth = testFrameCount * frameWidth + (testFrameCount - 1) * spacing
        totalHeight = frameHeight
    else
        totalWidth = frameWidth
        totalHeight = testFrameCount * frameHeight + (testFrameCount - 1) * spacing
    end
    
    -- Calculate container size (max possible size for 5 frames)
    local containerWidth, containerHeight
    if horizontal then
        containerWidth = 5 * frameWidth + 4 * spacing
        containerHeight = frameHeight
    else
        containerWidth = frameWidth
        containerHeight = 5 * frameHeight + 4 * spacing
    end
    
    -- Update container size
    DF.testPartyContainer:SetSize(containerWidth, containerHeight)
    
    -- Calculate starting offset based on growthAnchor
    local startX, startY = 0, 0
    if horizontal then
        -- Horizontal layout - growthAnchor controls left/center/right alignment
        if growthAnchor == "START" then
            startX = 0
        elseif growthAnchor == "CENTER" then
            startX = (containerWidth - totalWidth) / 2
        else -- END
            startX = containerWidth - totalWidth
        end
    else
        -- Vertical layout - growthAnchor controls top/center/bottom alignment
        if growthAnchor == "START" then
            startY = 0
        elseif growthAnchor == "CENTER" then
            startY = -(containerHeight - totalHeight) / 2
        else -- END
            startY = -(containerHeight - totalHeight)
        end
    end
    
    -- Position test frames
    for i = 0, 4 do
        local frame = DF.testPartyFrames[i]
        if frame and i < testFrameCount then
            frame:ClearAllPoints()
            if horizontal then
                local x = startX + i * (frameWidth + spacing)
                frame:SetPoint("TOPLEFT", DF.testPartyContainer, "TOPLEFT", x, 0)
            else
                local y = startY - i * (frameHeight + spacing)
                frame:SetPoint("TOPLEFT", DF.testPartyContainer, "TOPLEFT", 0, y)
            end
            frame:SetSize(frameWidth, frameHeight)
        end
    end
end

-- Throttled version of UpdateRaidTestFrames for slider callbacks
-- Now integrates with the targeted update system (no timers)
function DF:ThrottledUpdateRaidTestFrames()
    if DF.sliderDragging then
        if DF.sliderLightweightFunc then
            -- During drag, only call the lightweight update function
            DF.sliderLightweightFunc()
        end
        -- If no lightweight func, skip entirely until release
        return
    end
    
    -- Not dragging - update directly
    if DF.raidTestMode then
        DF:UpdateRaidTestFrames()
    end
end

-- Apply test preset
function DF:ApplyTestPreset(preset)
    local isRaidMode = DF.GUI and DF.GUI.SelectedMode == "raid"
    local db = isRaidMode and DF:GetRaidDB() or DF:GetDB()
    
    if preset == "STATIC" then
        db.testAnimateHealth = false
        db.testShowAuras = false
        db.testShowAbsorbs = false
        db.testShowOutOfRange = false
        db.testShowDispelGlow = false
        db.testShowMissingBuff = false
        db.testShowExternalDef = false
        db.testShowTargetedList = false
        db.testShowBossDebuffs = false
        db.testShowIcons = true
    elseif preset == "COMBAT" then
        db.testAnimateHealth = true
        db.testShowAuras = true
        db.testShowAbsorbs = true
        db.testShowOutOfRange = false
        db.testShowDispelGlow = true
        db.testShowMissingBuff = false
        db.testShowExternalDef = false
        db.testShowTargetedList = false
        db.testShowBossDebuffs = true
        db.testShowIcons = true
    elseif preset == "HEALER" then
        db.testAnimateHealth = true
        db.testShowAuras = true
        db.testShowAbsorbs = true
        db.testShowOutOfRange = false
        db.testShowDispelGlow = true
        db.testShowMissingBuff = true
        db.testShowExternalDef = true
        db.testShowTargetedList = true
        db.testShowBossDebuffs = true
        db.testShowIcons = true
    elseif preset == "FULL" then
        db.testAnimateHealth = true
        db.testShowAuras = true
        db.testShowAbsorbs = true
        db.testShowOutOfRange = true
        db.testShowDispelGlow = true
        db.testShowMissingBuff = true
        db.testShowExternalDef = true
        db.testShowTargetedList = true
        db.testShowIcons = true
    end
    
    db.testPreset = preset
    
    -- Update appropriate frames
    if isRaidMode and DF.raidTestMode then
        DF:UpdateRaidTestFrames()
    elseif not isRaidMode and DF.testMode then
        DF:StopTestAnimation()
        if db.testAnimateHealth then
            DF:StartTestAnimation()
        end
        DF:UpdateAllFrames()
    end
end


-- ============================================================
-- TEST MODE HELPER FUNCTIONS
-- ============================================================

-- Test dispel glow - uses the real dispel overlay system
function DF:UpdateTestDispelGlow(frame, dispelType)
    -- The real dispel overlay system already handles test mode
    -- Just call it directly
    if DF.UpdateDispelOverlay then
        DF:UpdateDispelOverlay(frame)
    end
end

function DF:ClearTestDispelGlow(frame)
    -- Hide the real dispel overlay
    if frame and frame.dfDispelOverlay then
        local overlay = frame.dfDispelOverlay
        if overlay.borderTop then overlay.borderTop:Hide() end
        if overlay.borderBottom then overlay.borderBottom:Hide() end
        if overlay.borderLeft then overlay.borderLeft:Hide() end
        if overlay.borderRight then overlay.borderRight:Hide() end
        if overlay.gradient then overlay.gradient:Hide() end
        -- Hide edge gradients (EDGE style)
        if overlay.gradientTop then overlay.gradientTop:Hide() end
        if overlay.gradientBottom then overlay.gradientBottom:Hide() end
        if overlay.gradientLeft then overlay.gradientLeft:Hide() end
        if overlay.gradientRight then overlay.gradientRight:Hide() end
        if overlay.icons then
            for _, icon in pairs(overlay.icons) do
                icon:Hide()
            end
        end
    end
end

function DF:UpdateAllTestDispelGlow()
    -- Safety check - Dispel module may not be loaded yet
    if not DF.UpdateDispelOverlay then return end
    
    -- Update party test frames
    if DF.testMode then
        for i = 0, 4 do
            local frame = DF.testPartyFrames[i]
            if frame then
                DF:UpdateDispelOverlay(frame)
            end
        end
    end
    
    -- Update raid test frames
    if DF.raidTestMode then
        for i = 1, 40 do
            local frame = DF.testRaidFrames[i]
            if frame then
                DF:UpdateDispelOverlay(frame)
            end
        end
    end
end

function DF:UpdateAllTestMyBuffIndicator()
    -- Safety check - MyBuffIndicators module may not be loaded yet
    if not DF.UpdateMyBuffIndicator then return end
    
    -- Update party test frames
    if DF.testMode then
        for i = 0, 4 do
            local frame = DF.testPartyFrames[i]
            if frame then
                DF:UpdateMyBuffIndicator(frame)
            end
        end
    end
    
    -- Update raid test frames
    if DF.raidTestMode then
        for i = 1, 40 do
            local frame = DF.testRaidFrames[i]
            if frame then
                DF:UpdateMyBuffIndicator(frame)
            end
        end
    end
end

-- Update all test frame highlights (selection, aggro, etc.)
function DF:UpdateAllTestHighlights()
    -- Safety check - Highlights module may not be loaded yet
    if not DF.UpdateHighlights then return end
    
    -- Update party test frames
    if DF.testMode then
        for i = 0, 4 do
            local frame = DF.testPartyFrames[i]
            if frame and frame:IsShown() then
                DF:UpdateHighlights(frame)
            end
        end
    end
    
    -- Update raid test frames
    if DF.raidTestMode then
        for i = 1, 40 do
            local frame = DF.testRaidFrames[i]
            if frame and frame:IsShown() then
                DF:UpdateHighlights(frame)
            end
        end
    end
end

-- Test missing buff icon
function DF:UpdateTestMissingBuff(frame)
    if not frame or not frame.missingBuffFrame then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Show a test missing buff icon
    if db.missingBuffIconEnabled then
        -- Use Arcane Intellect as test icon
        frame.missingBuffIcon:SetTexture("Interface\\Icons\\Spell_Holy_MagicalSentry")
        
        -- Apply settings
        local iconSize = db.missingBuffIconSize or 24
        local scale = db.missingBuffIconScale or 1.5
        local anchor = db.missingBuffIconAnchor or "CENTER"
        local x = db.missingBuffIconX or 0
        local y = db.missingBuffIconY or 0
        local borderSize = db.missingBuffIconBorderSize or 2
        local bc = db.missingBuffIconBorderColor or {r = 1, g = 0, b = 0, a = 1}
        
        -- Apply pixel perfect
        if db.pixelPerfect then
            iconSize = DF:PixelPerfect(iconSize)
            borderSize = DF:PixelPerfect(borderSize)
        end
        
        -- Set icon size
        frame.missingBuffFrame:SetSize(iconSize, iconSize)
        
        -- Apply border if enabled
        local showBorder = db.missingBuffIconShowBorder ~= false
        if showBorder then
            -- Set color on all border edges
            if frame.missingBuffBorderLeft then
                frame.missingBuffBorderLeft:SetColorTexture(bc.r, bc.g, bc.b, bc.a or 1)
                frame.missingBuffBorderLeft:SetWidth(borderSize)
                frame.missingBuffBorderLeft:Show()
            end
            if frame.missingBuffBorderRight then
                frame.missingBuffBorderRight:SetColorTexture(bc.r, bc.g, bc.b, bc.a or 1)
                frame.missingBuffBorderRight:SetWidth(borderSize)
                frame.missingBuffBorderRight:Show()
            end
            if frame.missingBuffBorderTop then
                frame.missingBuffBorderTop:SetColorTexture(bc.r, bc.g, bc.b, bc.a or 1)
                frame.missingBuffBorderTop:SetHeight(borderSize)
                frame.missingBuffBorderTop:ClearAllPoints()
                frame.missingBuffBorderTop:SetPoint("TOPLEFT", borderSize, 0)
                frame.missingBuffBorderTop:SetPoint("TOPRIGHT", -borderSize, 0)
                frame.missingBuffBorderTop:Show()
            end
            if frame.missingBuffBorderBottom then
                frame.missingBuffBorderBottom:SetColorTexture(bc.r, bc.g, bc.b, bc.a or 1)
                frame.missingBuffBorderBottom:SetHeight(borderSize)
                frame.missingBuffBorderBottom:ClearAllPoints()
                frame.missingBuffBorderBottom:SetPoint("BOTTOMLEFT", borderSize, 0)
                frame.missingBuffBorderBottom:SetPoint("BOTTOMRIGHT", -borderSize, 0)
                frame.missingBuffBorderBottom:Show()
            end
            
            frame.missingBuffIcon:ClearAllPoints()
            frame.missingBuffIcon:SetPoint("TOPLEFT", borderSize, -borderSize)
            frame.missingBuffIcon:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
        else
            -- Hide all border edges
            if frame.missingBuffBorderLeft then frame.missingBuffBorderLeft:Hide() end
            if frame.missingBuffBorderRight then frame.missingBuffBorderRight:Hide() end
            if frame.missingBuffBorderTop then frame.missingBuffBorderTop:Hide() end
            if frame.missingBuffBorderBottom then frame.missingBuffBorderBottom:Hide() end
            frame.missingBuffIcon:ClearAllPoints()
            frame.missingBuffIcon:SetPoint("TOPLEFT", 0, 0)
            frame.missingBuffIcon:SetPoint("BOTTOMRIGHT", 0, 0)
        end
        
        frame.missingBuffFrame:SetScale(scale)
        frame.missingBuffFrame:ClearAllPoints()
        frame.missingBuffFrame:SetPoint(anchor, frame, anchor, x, y)
        
        -- Apply frame level (controls layering within strata)
        local frameLevel = db.missingBuffIconFrameLevel or 0
        if frameLevel == 0 then
            -- "Auto" - use default relative to content overlay
            frame.missingBuffFrame:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 10)
        else
            frame.missingBuffFrame:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
        end
        
        frame.missingBuffFrame:Show()
    else
        frame.missingBuffFrame:Hide()
    end
end

function DF:UpdateAllTestMissingBuff()
    local function UpdateFrame(frame)
        if not frame then return end
        local db = DF:GetFrameDB(frame)
        
        if db.testShowMissingBuff then
            DF:UpdateTestMissingBuff(frame)
        else
            if frame.missingBuffFrame then
                frame.missingBuffFrame:Hide()
            end
        end
    end
    
    -- Update party test frames
    if DF.testMode then
        for i = 0, 4 do
            local frame = DF.testPartyFrames[i]
            if frame then
                UpdateFrame(frame)
            end
        end
    end
    
    -- Update raid test frames
    if DF.raidTestMode then
        for i = 1, 40 do
            local frame = DF.testRaidFrames[i]
            if frame then
                UpdateFrame(frame)
            end
        end
    end
end

-- Test defensive spell textures (variety for multi-icon display)
local TEST_DEFENSIVE_SPELLS = {
    135936,   -- Pain Suppression
    102342,   -- Ironbark
    6940,     -- Blessing of Sacrifice
    116849,   -- Life Cocoon
}

-- Render a single test defensive icon with all styling
local function RenderTestDefensiveIcon(icon, db, textureID, iconSize, borderSize, borderColor, showBorder, showDuration, durationScale, durationFont, durationOutline, durationX, durationY, durationColor, elapsed, duration)
    -- Set texture
    local texture = nil
    if C_Spell and C_Spell.GetSpellTexture then
        texture = C_Spell.GetSpellTexture(textureID)
    end
    if not texture then
        texture = textureID
    end
    icon.texture:SetTexture(texture)

    -- Set a looping cooldown
    local startTime = GetTime() - elapsed
    icon.cooldown:SetCooldown(startTime, duration)
    icon.cooldown:Show()
    icon.cooldown:SetHideCountdownNumbers(not showDuration)

    -- Swipe toggle
    local showSwipe = not db.defensiveIconHideSwipe
    icon.cooldown:SetDrawSwipe(showSwipe)

    -- Find and style the native cooldown text
    if not icon.nativeCooldownText then
        local regions = {icon.cooldown:GetRegions()}
        for _, region in ipairs(regions) do
            if region and region.GetObjectType and region:GetObjectType() == "FontString" then
                icon.nativeCooldownText = region
                break
            end
        end
    end

    -- Apply duration text styling
    if icon.nativeCooldownText then
        local durationSize = 10 * durationScale
        DF:SafeSetFont(icon.nativeCooldownText, durationFont, durationSize, durationOutline)
        icon.nativeCooldownText:ClearAllPoints()
        icon.nativeCooldownText:SetPoint("CENTER", icon, "CENTER", durationX, durationY)

        -- Color by time remaining
        if db.defensiveIconDurationColorByTime then
            local percentRemaining = 1 - (elapsed / duration)
            local r, g, b = DF:GetDurationColorByPercent(percentRemaining)
            icon.nativeCooldownText:SetTextColor(r, g, b, 1)
        else
            icon.nativeCooldownText:SetTextColor(durationColor.r, durationColor.g, durationColor.b, 1)
        end
    end

    -- Apply border if enabled
    if showBorder then
        if icon.borderLeft then
            icon.borderLeft:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a or 1)
            icon.borderLeft:SetWidth(borderSize)
            icon.borderLeft:Show()
        end
        if icon.borderRight then
            icon.borderRight:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a or 1)
            icon.borderRight:SetWidth(borderSize)
            icon.borderRight:Show()
        end
        if icon.borderTop then
            icon.borderTop:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a or 1)
            icon.borderTop:SetHeight(borderSize)
            icon.borderTop:ClearAllPoints()
            icon.borderTop:SetPoint("TOPLEFT", borderSize, 0)
            icon.borderTop:SetPoint("TOPRIGHT", -borderSize, 0)
            icon.borderTop:Show()
        end
        if icon.borderBottom then
            icon.borderBottom:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a or 1)
            icon.borderBottom:SetHeight(borderSize)
            icon.borderBottom:ClearAllPoints()
            icon.borderBottom:SetPoint("BOTTOMLEFT", borderSize, 0)
            icon.borderBottom:SetPoint("BOTTOMRIGHT", -borderSize, 0)
            icon.borderBottom:Show()
        end
        icon.texture:ClearAllPoints()
        icon.texture:SetPoint("TOPLEFT", borderSize, -borderSize)
        icon.texture:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
    else
        if icon.borderLeft then icon.borderLeft:Hide() end
        if icon.borderRight then icon.borderRight:Hide() end
        if icon.borderTop then icon.borderTop:Hide() end
        if icon.borderBottom then icon.borderBottom:Hide() end
        icon.texture:ClearAllPoints()
        icon.texture:SetPoint("TOPLEFT", 0, 0)
        icon.texture:SetPoint("BOTTOMRIGHT", 0, 0)
    end

    -- Size
    icon:SetSize(iconSize, iconSize)

    -- Clear stack count (ensure font is set first)
    if icon.count then
        local hasFont = false
        local success, result = pcall(function() return icon.count:GetFont() end)
        if success and result then hasFont = true end
        if not hasFont then
            DF:SafeSetFont(icon.count, "Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        end
        icon.count:SetText("")
    end

    -- Disable clicks
    if not InCombatLockdown() then
        if icon.SetMouseClickEnabled then
            icon:SetMouseClickEnabled(false)
        end
    end

    icon:Show()
end

-- Growth direction helper for test defensive bar positioning
local function GetTestDefGrowthOffset(direction, iconSize, pad)
    if direction == "LEFT" then
        return -(iconSize + pad), 0
    elseif direction == "RIGHT" then
        return iconSize + pad, 0
    elseif direction == "UP" then
        return 0, iconSize + pad
    elseif direction == "DOWN" then
        return 0, -(iconSize + pad)
    end
    return 0, 0
end

-- Test defensive icon — supports multiple icons with growth/wrap layout
function DF:UpdateTestDefensiveBar(frame, testData)
    if not frame or not frame.defensiveIcon then return end

    local db = DF:GetFrameDB(frame)

    -- Show on specific test frames (e.g. tank and healer)
    local showIcon = testData and (testData.role == "TANK" or testData.role == "HEALER")

    if db.defensiveIconEnabled and showIcon then
        local iconSize = db.defensiveIconSize or 24
        local borderSize = db.defensiveIconBorderSize or 2
        local borderColor = db.defensiveIconBorderColor or {r = 0, g = 0.8, b = 0, a = 1}
        local anchor = db.defensiveIconAnchor or "CENTER"
        local baseX = db.defensiveIconX or 0
        local baseY = db.defensiveIconY or 0
        local scale = db.defensiveIconScale or 1.0
        local showDuration = db.defensiveIconShowDuration ~= false
        local showBorder = db.defensiveIconShowBorder ~= false

        -- Apply pixel perfect to border size
        if db.pixelPerfect then
            borderSize = DF:PixelPerfect(borderSize)
            iconSize = DF:PixelPerfect(iconSize)
        end

        -- Duration text settings
        local durationScale = db.defensiveIconDurationScale or 1.0
        local durationFont = db.defensiveIconDurationFont or "Fonts\\FRIZQT__.TTF"
        local durationOutline = db.defensiveIconDurationOutline or "OUTLINE"
        if durationOutline == "NONE" then durationOutline = "" end
        local durationX = db.defensiveIconDurationX or 0
        local durationY = db.defensiveIconDurationY or 0
        local durationColor = db.defensiveIconDurationColor or {r = 1, g = 1, b = 1}

        -- Layout settings for multi-icon
        local maxDefs = db.defensiveBarMax or 4
        local spacing = db.defensiveBarSpacing or 2
        local growth = db.defensiveBarGrowth or "RIGHT_DOWN"
        local wrap = db.defensiveBarWrap or 5

        -- Determine how many defensives to show based on role
        -- Tanks show more defensives, healers show fewer
        local numDefs
        if testData.role == "TANK" then
            numDefs = math.min(3, maxDefs)
        else
            numDefs = math.min(1, maxDefs)
        end

        -- Parse compound growth direction
        local primary, secondary = strsplit("_", growth)
        primary = primary or "RIGHT"
        secondary = secondary or "DOWN"

        local scaledSize = iconSize * scale
        local primaryX, primaryY = GetTestDefGrowthOffset(primary, iconSize, spacing)
        local secondaryX, secondaryY = GetTestDefGrowthOffset(secondary, iconSize, spacing)

        -- Render each test defensive icon
        for i = 1, numDefs do
            local icon = DF:GetOrCreateDefensiveBarIcon(frame, i)
            if icon then
                -- Each icon gets a different spell texture and staggered cooldown timing
                local spellIndex = ((i - 1) % #TEST_DEFENSIVE_SPELLS) + 1
                local duration = 6 + (i * 2)  -- Stagger durations: 8, 10, 12, 14
                local elapsed = GetTime() % duration

                RenderTestDefensiveIcon(icon, db, TEST_DEFENSIVE_SPELLS[spellIndex], iconSize, borderSize, borderColor, showBorder, showDuration, durationScale, durationFont, durationOutline, durationX, durationY, durationColor, elapsed, duration)

                -- Position the icon using wrap grid layout
                local idx = i - 1  -- 0-based
                local row = math.floor(idx / wrap)
                local col = idx % wrap

                local offsetX = (col * primaryX) + (row * secondaryX)
                local offsetY = (col * primaryY) + (row * secondaryY)

                icon:SetScale(scale)
                icon:ClearAllPoints()
                icon:SetPoint(anchor, frame, anchor, baseX + offsetX, baseY + offsetY)

                -- Frame level
                local frameLevel = db.defensiveIconFrameLevel or 0
                if frameLevel == 0 then
                    icon:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 15)
                else
                    icon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
                end
            end
        end

        -- CENTER growth: second pass to center icons within each row/column
        -- Mirrors DF:RepositionCenterGrowthIcons from Features/Auras.lua
        if primary == "CENTER" and numDefs > 0 then
            local isHorizontalGrowth = (secondary == "LEFT" or secondary == "RIGHT")

            if isHorizontalGrowth then
                -- Vertical stacking (centered), horizontal column growth
                local secX = secondaryX
                for i = 1, numDefs do
                    local icon = DF:GetOrCreateDefensiveBarIcon(frame, i)
                    if icon then
                        local idx = i - 1
                        local col = math.floor(idx / wrap)
                        local row = idx % wrap
                        local iconsInCol = math.min(wrap, numDefs - (col * wrap))
                        local centerOffset = (iconsInCol - 1) * (iconSize + spacing) / 2
                        local x = baseX + (col * secX)
                        local y = baseY - (row * (iconSize + spacing)) + centerOffset
                        icon:ClearAllPoints()
                        icon:SetPoint(anchor, frame, anchor, x, y)
                    end
                end
            else
                -- Horizontal stacking (centered), vertical row growth
                local secY = secondaryY
                for i = 1, numDefs do
                    local icon = DF:GetOrCreateDefensiveBarIcon(frame, i)
                    if icon then
                        local idx = i - 1
                        local row = math.floor(idx / wrap)
                        local col = idx % wrap
                        local iconsInRow = math.min(wrap, numDefs - (row * wrap))
                        local centerOffset = (iconsInRow - 1) * (iconSize + spacing) / 2
                        local x = baseX + (col * (iconSize + spacing)) - centerOffset
                        local y = baseY + (row * secY)
                        icon:ClearAllPoints()
                        icon:SetPoint(anchor, frame, anchor, x, y)
                    end
                end
            end
        end

        -- Hide remaining icons beyond what we're showing
        for i = numDefs + 1, maxDefs do
            if i == 1 then
                frame.defensiveIcon:Hide()
            elseif frame.defensiveBarIcons and frame.defensiveBarIcons[i] then
                frame.defensiveBarIcons[i]:Hide()
            end
        end
    else
        -- Hide all defensive icons
        frame.defensiveIcon:Hide()
        if frame.defensiveBarIcons then
            for _, icon in pairs(frame.defensiveBarIcons) do
                icon:Hide()
            end
        end
    end
end

-- Legacy wrapper for backwards compatibility
function DF:UpdateTestExternalDef(frame, testData)
    DF:UpdateTestDefensiveBar(frame, testData)
end

function DF:UpdateAllTestDefensiveBar()
    local function UpdateFrame(frame, testData)
        if not frame then return end
        local db = DF:GetFrameDB(frame)
        
        if db.testShowExternalDef then
            DF:UpdateTestDefensiveBar(frame, testData)
        else
            if frame.defensiveIcon then
                frame.defensiveIcon:Hide()
                -- Clear cooldown
                if frame.defensiveIcon.cooldown then
                    frame.defensiveIcon.cooldown:Clear()
                end
            end
            -- Also hide multi-defensive bar icons
            if frame.defensiveBarIcons then
                for _, icon in pairs(frame.defensiveBarIcons) do
                    icon:Hide()
                    if icon.cooldown then icon.cooldown:Clear() end
                end
            end
        end
    end
    
    -- Update party test frames
    if DF.testMode then
        for i = 0, 4 do
            local frame = DF.testPartyFrames[i]
            if frame then
                local testData = DF:GetTestUnitData(i, false)
                UpdateFrame(frame, testData)
            end
        end
    end
    
    -- Update raid test frames
    if DF.raidTestMode then
        local raidDb = DF:GetRaidDB()
        local testFrameCount = raidDb.raidTestFrameCount or 10
        for i = 1, testFrameCount do
            local frame = DF.testRaidFrames[i]
            if frame then
                local testData = DF:GetTestUnitData(i, true)
                UpdateFrame(frame, testData)
            end
        end
    end
end

-- Legacy wrapper for backwards compatibility
function DF:UpdateAllTestExternalDef()
    DF:UpdateAllTestDefensiveBar()
end


-- ============================================================
-- TEST MODE: TARGETED SPELLS
-- ============================================================

function DF:UpdateTestTargetedSpell(frame, testData)
    if not frame then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Show icons on all frames in test mode
    local showIcon = testData ~= nil
    
    if db.targetedSpellEnabled and showIcon then
        -- Use max icons setting, with variation per frame based on index
        local maxIcons = db.targetedSpellMaxIcons or 5
        local frameIndex = testData.index or 0
        -- Each frame shows between 1 and maxIcons (varies by frame for visual variety)
        local numTestIcons = math.max(1, ((frameIndex % maxIcons) + 1))
        
        -- Ensure icon pool exists using the proper creation function
        if DF.EnsureTargetedSpellIconPool then
            DF:EnsureTargetedSpellIconPool(frame, numTestIcons)
        else
            -- Fallback if function not available yet
            if not frame.targetedSpellIcons then
                frame.targetedSpellIcons = {}
            end
            if not frame.dfActiveTargetedSpells then
                frame.dfActiveTargetedSpells = {}
            end
        end
        
        -- Test spells - include important, non-important, and one interrupted
        local testSpells = {
            {id = 686, name = "Shadow Bolt", texture = "Interface\\Icons\\Spell_Shadow_ShadowBolt", isImportant = true, isInterrupted = false},
            {id = 348, name = "Immolate", texture = "Interface\\Icons\\Spell_Fire_Immolation", isImportant = false, isInterrupted = false},
            {id = 172, name = "Corruption", texture = "Interface\\Icons\\Spell_Shadow_AbominationExplosion", isImportant = true, isInterrupted = true},  -- Interrupted example
            {id = 980, name = "Agony", texture = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras", isImportant = false, isInterrupted = false},
            {id = 30108, name = "Unstable Affliction", texture = "Interface\\Icons\\Spell_Shadow_UnstableAffliction_3", isImportant = true, isInterrupted = false},
        }
        
        -- Get all settings
        local borderColor = db.targetedSpellBorderColor or {r = 1, g = 0.3, b = 0}
        local borderSize = db.targetedSpellBorderSize or 2
        local showBorder = db.targetedSpellShowBorder ~= false
        local showSwipe = not db.targetedSpellHideSwipe
        local showDuration = db.targetedSpellShowDuration ~= false
        local durationFont = db.targetedSpellDurationFont or "Fonts\\FRIZQT__.TTF"
        local durationScale = db.targetedSpellDurationScale or 1.0
        local durationOutline = db.targetedSpellDurationOutline or "OUTLINE"
        local durationX = db.targetedSpellDurationX or 0
        local durationY = db.targetedSpellDurationY or 0
        local durationColor = db.targetedSpellDurationColor or {r = 1, g = 1, b = 1}
        local alpha = db.targetedSpellAlpha or 1.0
        
        -- Apply health-based or OOR alpha in test mode
        if frame.dfTestHealthFadeAlphas and frame.dfTestHealthFadeAlphas.targetedSpell then
            alpha = alpha * frame.dfTestHealthFadeAlphas.targetedSpell
        elseif frame.dfTestOORAlphas and frame.dfTestOORAlphas.targetedSpell then
            alpha = alpha * frame.dfTestOORAlphas.targetedSpell
        end
        
        local iconSize = db.targetedSpellSize or 28
        local scale = db.targetedSpellScale or 1.0
        local anchor = db.targetedSpellAnchor or "LEFT"
        local x = db.targetedSpellX or -30
        local y = db.targetedSpellY or 0
        local growthDirection = db.targetedSpellGrowth or "DOWN"
        local spacing = db.targetedSpellSpacing or 2
        local frameLevel = db.targetedSpellFrameLevel or 0
        local highlightImportant = db.targetedSpellHighlightImportant ~= false
        local highlightStyle = db.targetedSpellHighlightStyle or "glow"
        local highlightColor = db.targetedSpellHighlightColor or {r = 1, g = 0.8, b = 0}
        local highlightSize = db.targetedSpellHighlightSize or 3
        local highlightInset = db.targetedSpellHighlightInset or 0
        
        if durationOutline == "NONE" then durationOutline = "" end
        
        -- Apply pixel perfect
        if db.pixelPerfect then
            iconSize = DF:PixelPerfect(iconSize)
            spacing = DF:PixelPerfect(spacing)
            borderSize = DF:PixelPerfect(borderSize)
        end
        
        -- Apply scale
        local scaledSize = iconSize * scale
        local scaledSpacing = spacing * scale
        local fontSize = 10 * durationScale
        
        for i = 1, numTestIcons do
            local testGUID = "test-caster-" .. i
            
            local icon = frame.targetedSpellIcons[i]
            if not icon then
                -- Icon pool wasn't created properly, skip
                break
            end
            
            local spell = testSpells[i] or testSpells[1]  -- Fall back to first spell if index exceeds
            
            -- Get texture
            local texture = spell.texture
            if C_Spell and C_Spell.GetSpellTexture then
                local spellTexture = C_Spell.GetSpellTexture(spell.id)
                if spellTexture then texture = spellTexture end
            end
            
            icon.icon:SetTexture(texture)
            icon.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            
            -- Handle interrupted spell differently
            local showInterrupted = db.targetedSpellShowInterrupted and spell.isInterrupted
            
            if showInterrupted then
                -- Show as interrupted
                icon.icon:SetDesaturated(true)
                
                -- Get interrupted visual settings
                local tintColor = db.targetedSpellInterruptedTintColor or {r = 1, g = 0, b = 0}
                local tintAlpha = db.targetedSpellInterruptedTintAlpha or 0.5
                local showX = db.targetedSpellInterruptedShowX ~= false
                local xColor = db.targetedSpellInterruptedXColor or {r = 1, g = 0, b = 0}
                local xSize = db.targetedSpellInterruptedXSize or 16
                
                -- Apply tint
                if icon.interruptTint then
                    icon.interruptTint:SetColorTexture(tintColor.r, tintColor.g, tintColor.b, tintAlpha)
                end
                
                -- Apply X mark settings
                if icon.interruptX then
                    if showX then
                        icon.interruptX:Show()
                        icon.interruptX:SetTextColor(xColor.r, xColor.g, xColor.b, 1)
                        DF:SafeSetFont(icon.interruptX, nil, xSize, "OUTLINE")
                    else
                        icon.interruptX:Hide()
                    end
                end
                
                if icon.interruptOverlay then
                    icon.interruptOverlay:Show()
                end
                
                -- Hide cooldown and duration for interrupted
                if icon.cooldown then
                    icon.cooldown:Clear()
                end
                if icon.durationText then
                    icon.durationText:Hide()
                end
            else
                -- Normal spell display
                icon.icon:SetDesaturated(false)
                
                if icon.interruptOverlay then
                    icon.interruptOverlay:Hide()
                end
                
                -- Cooldown on icon
                if icon.cooldown then
                    local duration = 3
                    local elapsed = (GetTime() + i * 0.5) % duration  -- Offset each icon
                    local startTime = GetTime() - elapsed
                    icon.cooldown:SetCooldown(startTime, duration)
                    icon.cooldown:SetDrawSwipe(showSwipe)
                    icon.cooldown:SetHideCountdownNumbers(true)  -- We use custom text
                end
                
                -- Custom duration text
                if icon.durationText then
                    if showDuration then
                        icon.durationText:Show()
                        DF:SafeSetFont(icon.durationText, durationFont, fontSize, durationOutline)
                        icon.durationText:ClearAllPoints()
                        icon.durationText:SetPoint("CENTER", icon.iconFrame, "CENTER", durationX, durationY)
                        
                        -- Show sample duration for preview
                        local remaining = 3 - ((GetTime() + i * 0.5) % 3)
                        icon.durationText:SetText(string.format("%.1f", remaining))
                        
                        -- Apply duration color
                        icon.durationText:SetTextColor(durationColor.r, durationColor.g, durationColor.b, 1)
                    else
                        icon.durationText:Hide()
                    end
                end
            end
            
            -- Apply important spell highlight (show on important spells, including interrupted ones)
            if icon.highlightFrame then
                -- Calculate position with inset
                local offset = borderSize + highlightSize - highlightInset
                
                -- Hide all styles first - always do this
                if icon.highlight then icon.highlight:Hide() end
                if DF.HideSolidBorder then DF.HideSolidBorder(icon.highlightFrame) end
                if DF.HideGlowBorder then DF.HideGlowBorder(icon.highlightFrame) end
                if DF.HideAnimatedBorder then DF.HideAnimatedBorder(icon.highlightFrame) end
                if icon.highlightFrame.pulseAnim then icon.highlightFrame.pulseAnim:Stop() end
                -- Remove from animator
                if DF.TargetedSpellAnimator then
                    DF.TargetedSpellAnimator.frames[icon.highlightFrame] = nil
                end
                
                -- Only show if highlighting is enabled, spell is important, and style is not "none"
                local shouldShowHighlight = highlightImportant and spell.isImportant and highlightStyle and highlightStyle ~= "none"
                
                if shouldShowHighlight then
                    icon.highlightFrame:ClearAllPoints()
                    icon.highlightFrame:SetPoint("TOPLEFT", icon.iconFrame, "TOPLEFT", -offset, offset)
                    icon.highlightFrame:SetPoint("BOTTOMRIGHT", icon.iconFrame, "BOTTOMRIGHT", offset, -offset)
                    icon.highlightFrame:SetAlpha(1)
                    icon.highlightFrame:Show()
                    
                    -- Apply style using edge-based borders
                    if highlightStyle == "glow" then
                        -- Glow border with ADD blend mode
                        if DF.InitGlowBorder and DF.UpdateGlowBorder then
                            DF.InitGlowBorder(icon.highlightFrame)
                            DF.UpdateGlowBorder(icon.highlightFrame, highlightSize, highlightColor.r, highlightColor.g, highlightColor.b, 0.8)
                        end
                    elseif highlightStyle == "pulse" then
                        -- Pulsing glow with animation
                        if DF.InitGlowBorder and DF.UpdateGlowBorder and DF.InitPulseAnimation then
                            DF.InitGlowBorder(icon.highlightFrame)
                            DF.UpdateGlowBorder(icon.highlightFrame, highlightSize, highlightColor.r, highlightColor.g, highlightColor.b, 0.8)
                            DF.InitPulseAnimation(icon.highlightFrame)
                            -- Store color for pulse animation to use
                            icon.highlightFrame.pulseR = highlightColor.r
                            icon.highlightFrame.pulseG = highlightColor.g
                            icon.highlightFrame.pulseB = highlightColor.b
                            if icon.highlightFrame.pulseAnim then
                                icon.highlightFrame.pulseAnim:Play()
                            end
                        end
                    elseif highlightStyle == "marchingAnts" then
                        -- Animated marching ants border
                        if DF.InitAnimatedBorder and DF.TargetedSpellAnimator then
                            DF.InitAnimatedBorder(icon.highlightFrame)
                            icon.highlightFrame.animThickness = math.max(1, highlightSize)
                            icon.highlightFrame.animR = highlightColor.r
                            icon.highlightFrame.animG = highlightColor.g
                            icon.highlightFrame.animB = highlightColor.b
                            icon.highlightFrame.animA = 1
                            DF.TargetedSpellAnimator.frames[icon.highlightFrame] = true
                        end
                    elseif highlightStyle == "solidBorder" then
                        -- Solid border
                        if DF.InitSolidBorder and DF.UpdateSolidBorder then
                            DF.InitSolidBorder(icon.highlightFrame)
                            DF.UpdateSolidBorder(icon.highlightFrame, highlightSize, highlightColor.r, highlightColor.g, highlightColor.b, 1)
                        end
                    end
                else
                    icon.highlightFrame:Hide()
                end
            end
            
            -- Apply border settings - 4 edge textures (consistent with live code)
            if showBorder then
                if icon.borderLeft then
                    icon.borderLeft:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, 1)
                    icon.borderLeft:SetWidth(borderSize)
                    icon.borderLeft:Show()
                end
                if icon.borderRight then
                    icon.borderRight:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, 1)
                    icon.borderRight:SetWidth(borderSize)
                    icon.borderRight:Show()
                end
                if icon.borderTop then
                    icon.borderTop:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, 1)
                    icon.borderTop:SetHeight(borderSize)
                    icon.borderTop:ClearAllPoints()
                    icon.borderTop:SetPoint("TOPLEFT", borderSize, 0)
                    icon.borderTop:SetPoint("TOPRIGHT", -borderSize, 0)
                    icon.borderTop:Show()
                end
                if icon.borderBottom then
                    icon.borderBottom:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, 1)
                    icon.borderBottom:SetHeight(borderSize)
                    icon.borderBottom:ClearAllPoints()
                    icon.borderBottom:SetPoint("BOTTOMLEFT", borderSize, 0)
                    icon.borderBottom:SetPoint("BOTTOMRIGHT", -borderSize, 0)
                    icon.borderBottom:Show()
                end
                
                -- Adjust icon texture position for border
                if icon.icon then
                    icon.icon:ClearAllPoints()
                    icon.icon:SetPoint("TOPLEFT", icon.iconFrame, "TOPLEFT", borderSize, -borderSize)
                    icon.icon:SetPoint("BOTTOMRIGHT", icon.iconFrame, "BOTTOMRIGHT", -borderSize, borderSize)
                end
                
                -- Adjust cooldown to match
                if icon.cooldown then
                    icon.cooldown:ClearAllPoints()
                    icon.cooldown:SetPoint("TOPLEFT", icon.iconFrame, "TOPLEFT", borderSize, -borderSize)
                    icon.cooldown:SetPoint("BOTTOMRIGHT", icon.iconFrame, "BOTTOMRIGHT", -borderSize, borderSize)
                end
            else
                -- Hide all border edges
                if icon.borderLeft then icon.borderLeft:Hide() end
                if icon.borderRight then icon.borderRight:Hide() end
                if icon.borderTop then icon.borderTop:Hide() end
                if icon.borderBottom then icon.borderBottom:Hide() end
                
                -- Full size icon when no border
                if icon.icon then
                    icon.icon:ClearAllPoints()
                    icon.icon:SetPoint("TOPLEFT", icon.iconFrame, "TOPLEFT", 0, 0)
                    icon.icon:SetPoint("BOTTOMRIGHT", icon.iconFrame, "BOTTOMRIGHT", 0, 0)
                end
                
                -- Adjust cooldown to match
                if icon.cooldown then
                    icon.cooldown:ClearAllPoints()
                    icon.cooldown:SetPoint("TOPLEFT", icon.iconFrame, "TOPLEFT", 0, 0)
                    icon.cooldown:SetPoint("BOTTOMRIGHT", icon.iconFrame, "BOTTOMRIGHT", 0, 0)
                end
            end
            
            icon:SetAlpha(alpha)
            icon:Show()
            
            -- Hide cast bar (removed feature)
            if icon.castBar then
                icon.castBar:Hide()
            end
            
            frame.dfActiveTargetedSpells[testGUID] = i
        end
        
        -- Position all icons
        for i = 1, numTestIcons do
            local icon = frame.targetedSpellIcons[i]
            if icon then
                local offsetX, offsetY = 0, 0
                local index = i - 1
                
                if growthDirection == "UP" then
                    offsetY = index * (scaledSize + scaledSpacing)
                elseif growthDirection == "DOWN" then
                    offsetY = -index * (scaledSize + scaledSpacing)
                elseif growthDirection == "LEFT" then
                    offsetX = -index * (scaledSize + scaledSpacing)
                elseif growthDirection == "RIGHT" then
                    offsetX = index * (scaledSize + scaledSpacing)
                elseif growthDirection == "CENTER_H" then
                    -- Grow horizontally from center
                    local centerOffset = (numTestIcons - 1) * (scaledSize + scaledSpacing) / 2
                    offsetX = index * (scaledSize + scaledSpacing) - centerOffset
                elseif growthDirection == "CENTER_V" then
                    -- Grow vertically from center
                    local centerOffset = (numTestIcons - 1) * (scaledSize + scaledSpacing) / 2
                    offsetY = index * (scaledSize + scaledSpacing) - centerOffset
                end
                
                icon:ClearAllPoints()
                icon:SetPoint(anchor, frame, anchor, x + offsetX, y + offsetY)
                icon:SetSize(scaledSize, scaledSize)
                
                -- Set frame level
                icon:SetFrameLevel(frame:GetFrameLevel() + 30 + frameLevel + i)
                
                icon.iconFrame:SetSize(scaledSize, scaledSize)
                icon.iconFrame:ClearAllPoints()
                icon.iconFrame:SetPoint("CENTER", icon, "CENTER", 0, 0)
                
                -- Hide cast bar (removed feature)
                if icon.castBar then
                    icon.castBar:Hide()
                end
            end
        end
        
        -- Hide extra icons beyond numTestIcons
        if frame.targetedSpellIcons then
            for i = numTestIcons + 1, #frame.targetedSpellIcons do
                local icon = frame.targetedSpellIcons[i]
                if icon then
                    icon:Hide()
                end
            end
        end
    else
        -- Hide all test icons
        if frame.targetedSpellIcons then
            for _, icon in ipairs(frame.targetedSpellIcons) do
                icon:Hide()
            end
        end
        if frame.dfActiveTargetedSpells then
            wipe(frame.dfActiveTargetedSpells)
        end
    end
end

-- Targeted List demo bars in test mode. This is a single global
-- container (not per-frame), so the update function just toggles the
-- show/hide helpers on the feature module. Safe to call with the
-- feature gate off — both helpers are no-ops on stable builds.
function DF:UpdateAllTestTargetedList()
    local db = DF:GetDB()
    if db and db.testShowTargetedList and DF.ShowTestTargetedList then
        DF:ShowTestTargetedList()
    elseif DF.HideTestTargetedList then
        DF:HideTestTargetedList()
    end
end

function DF:UpdateAllTestTargetedSpell()
    local function UpdateFrame(frame, testData)
        if not frame then return end
        local db = DF:GetFrameDB(frame)

        if db.testShowTargetedSpell then
            DF:UpdateTestTargetedSpell(frame, testData)
        else
            -- Hide all icons and their highlights (new multi-icon system)
            if frame.targetedSpellIcons then
                for _, icon in ipairs(frame.targetedSpellIcons) do
                    icon:Hide()
                    -- Also hide pinned frame if it exists
                    if icon.highlightFrame then
                        icon.highlightFrame:Hide()
                        -- Stop any animations
                        if icon.highlightFrame.pulseAnim and icon.highlightFrame.pulseAnim:IsPlaying() then
                            icon.highlightFrame.pulseAnim:Stop()
                        end
                        -- Unregister from animator
                        if DF.TargetedSpellAnimator then
                            DF.TargetedSpellAnimator.frames[icon.highlightFrame] = nil
                        end
                    end
                end
            end
            if frame.dfActiveTargetedSpells then
                wipe(frame.dfActiveTargetedSpells)
            end
        end
    end
    
    -- Update party test frames
    if DF.testMode then
        for i = 0, 4 do
            local frame = DF.testPartyFrames[i]
            if frame then
                local testData = DF:GetTestUnitData(i, false)
                UpdateFrame(frame, testData)
            end
        end
        
        -- Update personal targeted spells display in test mode
        local db = DF:GetDB()
        if db.personalTargetedSpellEnabled and DF.ShowTestPersonalTargetedSpells then
            DF:ShowTestPersonalTargetedSpells()
        elseif DF.HideTestPersonalTargetedSpells then
            DF:HideTestPersonalTargetedSpells()
        end

        -- Update Targeted List demo bars in test mode
        if DF.UpdateAllTestTargetedList then
            DF:UpdateAllTestTargetedList()
        end
    end

    -- Update raid test frames
    if DF.raidTestMode then
        local raidDb = DF:GetRaidDB()
        local testFrameCount = raidDb.raidTestFrameCount or 10
        for i = 1, testFrameCount do
            local frame = DF.testRaidFrames[i]
            if frame then
                local testData = DF:GetTestUnitData(i, true)
                UpdateFrame(frame, testData)
            end
        end
        
        -- Also show personal targeted spells in raid test mode
        local db = DF:GetDB()
        if db.personalTargetedSpellEnabled and DF.ShowTestPersonalTargetedSpells then
            DF:ShowTestPersonalTargetedSpells()
        elseif DF.HideTestPersonalTargetedSpells then
            DF:HideTestPersonalTargetedSpells()
        end
    end
end


-- ============================================================
-- AURA DESIGNER TEST MODE
-- Iterates all visible test frames and calls the AD Engine's
-- test path to show/hide configured indicators with mock data.
-- ============================================================

function DF:UpdateAllTestAuraDesigner()
    local ADEngine = DF.AuraDesigner and DF.AuraDesigner.Engine
    if not ADEngine then return end

    local function UpdateFrame(frame)
        if not frame or not frame:IsShown() then return end
        local db = DF:GetFrameDB(frame)
        if db and db.testShowAuraDesigner and db.auraDesigner and db.auraDesigner.enabled then
            ADEngine:UpdateTestFrame(frame)
        else
            ADEngine:ClearFrame(frame)
        end
    end

    if DF.testMode then
        for i = 0, 4 do
            local frame = DF.testPartyFrames and DF.testPartyFrames[i]
            if frame then UpdateFrame(frame) end
        end
    end

    if DF.raidTestMode then
        local raidDb = DF:GetRaidDB()
        local testFrameCount = raidDb and raidDb.raidTestFrameCount or 10
        for i = 1, testFrameCount do
            local frame = DF.testRaidFrames and DF.testRaidFrames[i]
            if frame then UpdateFrame(frame) end
        end
    end
end

-- ============================================================
-- FLOATING TEST PANEL
-- ============================================================

function DF:CreateTestPanel()
    if DF.TestPanel then return DF.TestPanel end

    -- ============================================================
    -- COLOUR CONSTANTS
    -- ============================================================
    local C_PARTY    = {r = 0.45, g = 0.45, b = 0.95, a = 1}
    local C_RAID     = {r = 1.0,  g = 0.5,  b = 0.2,  a = 1}
    local C_BG       = {r = 0.08, g = 0.08, b = 0.08, a = 0.95}
    local C_PANEL    = {r = 0.12, g = 0.12, b = 0.12, a = 1}
    local C_ELEMENT  = {r = 0.18, g = 0.18, b = 0.18, a = 1}
    local C_BORDER   = {r = 0.25, g = 0.25, b = 0.25, a = 1}
    local C_HOVER    = {r = 0.22, g = 0.22, b = 0.22, a = 1}
    local C_TEXT     = {r = 0.9,  g = 0.9,  b = 0.9,  a = 1}
    local C_TEXT_DIM = {r = 0.6,  g = 0.6,  b = 0.6,  a = 1}

    local PANEL_WIDTH   = 320
    local CONTENT_WIDTH = PANEL_WIDTH - 24  -- 12px padding each side
    local HEADER_TOP    = 108  -- Space used by title + toggle button + description + separator

    local function GetThemeColor()
        local isRaidMode = DF.GUI and DF.GUI.SelectedMode == "raid"
        return isRaidMode and C_RAID or C_PARTY
    end

    local function IsTestActive()
        local isRaidMode = DF.GUI and DF.GUI.SelectedMode == "raid"
        return isRaidMode and DF.raidTestMode or DF.testMode
    end

    -- ============================================================
    -- MAIN PANEL FRAME
    -- ============================================================
    local panel = CreateFrame("Frame", "DandersFramesTestPanel", UIParent, "BackdropTemplate")
    panel:SetSize(PANEL_WIDTH, 420)
    panel:SetPoint("CENTER", UIParent, "CENTER", 300, 0)
    panel:SetFrameStrata("FULLSCREEN_DIALOG")
    panel:SetFrameLevel(100)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    panel:SetBackdropColor(C_BG.r, C_BG.g, C_BG.b, C_BG.a)
    panel:SetBackdropBorderColor(0, 0, 0, 1)
    panel:Hide()

    local function ApplyScale(self)
        local guiScale = DF.db and DF.db.party and DF.db.party.guiScale or 1.0
        self:SetScale(guiScale)
    end

    panel:SetScript("OnHide", function()
        if DF.testMode then
            local db = DF:GetDB()
            if db.locked then DF:HideTestFrames() end
        end
        if DF.raidTestMode then
            local db = DF:GetRaidDB()
            if db.raidLocked then DF:HideRaidTestFrames() end
        end
        if DF.GUI and DF.GUI.UpdateTestButtonState then
            DF.GUI.UpdateTestButtonState()
        end
    end)

    tinsert(UISpecialFrames, "DandersFramesTestPanel")

    -- ============================================================
    -- HEADER
    -- ============================================================
    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    title:SetPoint("TOPLEFT", 12, -10)
    title:SetText("Test Mode")
    panel.title = title

    -- Mode badge
    local badge = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    badge:SetSize(40, 18)
    badge:SetPoint("LEFT", title, "RIGHT", 8, 0)
    badge:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    badge.text = badge:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    badge.text:SetPoint("CENTER", 0, 0)
    badge.text:SetText("Party")
    panel.badge = badge

    -- Close button
    local closeBtn = CreateFrame("Button", nil, panel, "BackdropTemplate")
    closeBtn:SetSize(22, 22)
    closeBtn:SetPoint("TOPRIGHT", -8, -6)
    closeBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    closeBtn:SetBackdropColor(1, 1, 1, 0.04)
    closeBtn:SetBackdropBorderColor(0, 0, 0, 0)
    closeBtn.Text = closeBtn:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
    closeBtn.Text:SetPoint("CENTER", 0, 0)
    closeBtn.Text:SetText("×")
    closeBtn.Text:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    closeBtn:SetScript("OnClick", function() panel:Hide() end)
    closeBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.85, 0.24, 0.24, 0.25)
        self.Text:SetTextColor(0.9, 0.33, 0.33)
    end)
    closeBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(1, 1, 1, 0.04)
        self.Text:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    end)

    -- Separator below header
    local headerSep = panel:CreateTexture(nil, "ARTWORK")
    headerSep:SetPoint("TOPLEFT", 0, -32)
    headerSep:SetPoint("TOPRIGHT", 0, -32)
    headerSep:SetHeight(1)
    headerSep:SetColorTexture(1, 1, 1, 0.06)

    -- ============================================================
    -- TOGGLE BUTTON
    -- ============================================================
    local toggleBtn = CreateFrame("Button", nil, panel, "BackdropTemplate")
    toggleBtn:SetPoint("TOPLEFT", 12, -38)
    toggleBtn:SetSize(CONTENT_WIDTH, 30)
    toggleBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    toggleBtn.Text = toggleBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    toggleBtn.Text:SetPoint("CENTER")
    toggleBtn.Text:SetText("Enable Test Mode")
    toggleBtn:SetScript("OnClick", function()
        DF:ToggleTestMode()
        panel:UpdateState()
    end)
    panel.toggleBtn = toggleBtn

    -- Description text
    local desc = panel:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    desc:SetPoint("TOPLEFT", 12, -74)
    desc:SetPoint("TOPRIGHT", -12, -74)
    desc:SetJustifyH("LEFT")
    desc:SetSpacing(2)
    desc:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 0.8)
    desc:SetText("Expand sections to toggle features. Click label text to jump to its settings page.")

    -- ============================================================
    -- THEMED CHECKBOX HELPER
    -- ============================================================
    local function CreateThemedCheckbox(parent, text, dbKey, callback, pageId)
        local container = CreateFrame("Frame", nil, parent)
        container:SetSize(CONTENT_WIDTH / 2 - 4, 22)

        -- Checkbox square
        local box = CreateFrame("Button", nil, container, "BackdropTemplate")
        box:SetSize(16, 16)
        box:SetPoint("LEFT", 0, 0)
        box:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        box:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        box:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.7)
        container.box = box

        -- Checkmark texture (solid square, same pattern as GUI:CreateCheckbox)
        local mark = box:CreateTexture(nil, "OVERLAY")
        mark:SetTexture("Interface\\Buttons\\WHITE8x8")
        mark:SetPoint("CENTER")
        mark:SetSize(10, 10)
        mark:Hide()
        container.mark = mark

        -- State
        container.checked = false
        container.dbKey = dbKey

        container.SetChecked = function(self, val)
            self.checked = val and true or false
            if self.checked then
                local c = GetThemeColor()
                self.mark:SetVertexColor(c.r, c.g, c.b)
                self.mark:Show()
                self.box:SetBackdropBorderColor(c.r, c.g, c.b, 0.5)
                self.box:SetBackdropColor(c.r * 0.15, c.g * 0.15, c.b * 0.15, 1)
            else
                self.mark:Hide()
                self.box:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.7)
                self.box:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
            end
        end

        container.GetChecked = function(self)
            return self.checked
        end

        -- Label
        if pageId then
            local labelBtn = CreateFrame("Button", nil, container)
            labelBtn:SetPoint("LEFT", box, "RIGHT", 6, 0)
            labelBtn:SetHeight(18)
            local labelText = labelBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            labelText:SetPoint("LEFT", 0, 0)
            labelText:SetText(text)
            labelText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            local arrow = labelBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            arrow:SetPoint("LEFT", labelText, "RIGHT", 2, 0)
            arrow:SetText("›")
            arrow:SetTextColor(0.4, 0.4, 0.4, 0.6)
            labelBtn:SetWidth(labelText:GetStringWidth() + 14)
            labelBtn:SetScript("OnEnter", function(self)
                labelText:SetTextColor(1, 0.82, 0)
                arrow:SetTextColor(1, 0.82, 0)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Click to open settings", 1, 1, 1)
                GameTooltip:Show()
            end)
            labelBtn:SetScript("OnLeave", function(self)
                labelText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
                arrow:SetTextColor(0.4, 0.4, 0.4, 0.6)
                GameTooltip:Hide()
            end)
            labelBtn:SetScript("OnClick", function()
                if DF.GUI and DF.GUI.SelectTab then
                    if DF.GUIFrame and not DF.GUIFrame:IsShown() then DF.GUIFrame:Show() end
                    DF.GUI.SelectTab(pageId)
                end
            end)
            container.labelText = labelText
        else
            local labelText = container:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
            labelText:SetPoint("LEFT", box, "RIGHT", 6, 0)
            labelText:SetText(text)
            labelText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            container.labelText = labelText
        end

        -- Click the box to toggle
        box:SetScript("OnClick", function()
            container:SetChecked(not container.checked)
            local isRaidMode = DF.GUI and DF.GUI.SelectedMode == "raid"
            local db = isRaidMode and DF:GetRaidDB() or DF:GetDB()
            db[dbKey] = container.checked
            if callback then callback(container.checked, isRaidMode) end
            if isRaidMode and DF.raidTestMode then
                DF:UpdateRaidTestFrames()
            elseif not isRaidMode and DF.testMode then
                DF:UpdateAllFrames()
                if DF.RefreshTestFrames then DF:RefreshTestFrames() end
            end
            -- Update badge on parent section
            if container.section and container.section.UpdateBadge then
                container.section:UpdateBadge()
            end
        end)

        -- Hover on whole container toggles too
        container:EnableMouse(true)
        container:SetScript("OnMouseDown", function()
            box:GetScript("OnClick")(box)
        end)
        container:SetScript("OnEnter", function()
            box:SetBackdropBorderColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 0.8)
        end)
        container:SetScript("OnLeave", function()
            if container.checked then
                local c = GetThemeColor()
                box:SetBackdropBorderColor(c.r, c.g, c.b, 0.5)
            else
                box:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.7)
            end
        end)

        return container
    end

    -- ============================================================
    -- THEMED MINI-SLIDER HELPER
    -- Matches addon slider style: track + fill + thumb, no Blizzard template
    -- ============================================================
    local function CreateThemedSlider(parent, width, minVal, maxVal, step)
        local container = CreateFrame("Frame", nil, parent)
        container:SetSize(width, 8)

        -- Background track
        local track = CreateFrame("Frame", nil, container, "BackdropTemplate")
        track:SetAllPoints()
        track:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        track:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        track:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)

        -- Fill track (coloured portion)
        local fill = track:CreateTexture(nil, "ARTWORK")
        fill:SetPoint("LEFT", 1, 0)
        fill:SetHeight(6)
        local c = GetThemeColor()
        fill:SetColorTexture(c.r, c.g, c.b, 0.8)
        fill:SetWidth(1)

        -- Actual slider control (invisible, overlays the track)
        local slider = CreateFrame("Slider", nil, container)
        slider:SetAllPoints()
        slider:SetOrientation("HORIZONTAL")
        slider:SetMinMaxValues(minVal, maxVal)
        slider:SetValueStep(step)
        slider:SetObeyStepOnDrag(true)
        slider:SetHitRectInsets(-4, -4, -8, -8)

        -- Thumb
        local thumb = slider:CreateTexture(nil, "OVERLAY")
        thumb:SetSize(10, 14)
        thumb:SetColorTexture(c.r, c.g, c.b, 1)
        slider:SetThumbTexture(thumb)

        local trackWidth = width - 2  -- Account for border insets

        local function UpdateFill()
            local val = slider:GetValue()
            local pct = (val - minVal) / (maxVal - minVal)
            fill:SetWidth(math.max(1, pct * trackWidth))
        end

        slider:HookScript("OnValueChanged", function()
            UpdateFill()
        end)

        -- Expose for theme updates
        container.slider = slider
        container.fill = fill
        container.thumb = thumb
        container.UpdateFill = UpdateFill

        container.UpdateTheme = function()
            local nc = GetThemeColor()
            thumb:SetColorTexture(nc.r, nc.g, nc.b, 1)
            fill:SetColorTexture(nc.r, nc.g, nc.b, 0.8)
        end

        -- Forward slider API to container for convenience
        container.SetValue = function(self, v) slider:SetValue(v) end
        container.GetValue = function(self) return slider:GetValue() end
        container.SetMinMaxValues = function(self, lo, hi)
            slider:SetMinMaxValues(lo, hi)
            minVal = lo
            maxVal = hi
            trackWidth = width - 2
        end
        container.SetScript = function(self, event, fn) slider:SetScript(event, fn) end
        container.HookScript = function(self, event, fn) slider:HookScript(event, fn) end

        return container
    end

    -- ============================================================
    -- COLLAPSIBLE SECTION HELPER
    -- ============================================================
    local allSections = {}

    local function CreateSection(parentFrame, sectionTitle, sectionKey)
        local section = CreateFrame("Frame", nil, parentFrame)
        section:SetSize(CONTENT_WIDTH, 30)  -- Height updated by RecalculateLayout
        section.sectionKey = sectionKey
        section.expanded = false  -- Default collapsed
        section.checkboxes = {}
        section.extraWidgets = {}  -- {widget, height}

        -- Header bar
        local header = CreateFrame("Button", nil, section, "BackdropTemplate")
        header:SetSize(CONTENT_WIDTH, 26)
        header:SetPoint("TOPLEFT", 0, 0)
        header:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        header:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 0.8)
        header:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.3)
        section.header = header

        -- Chevron (starts collapsed)
        local chevron = header:CreateTexture(nil, "OVERLAY")
        chevron:SetSize(12, 12)
        chevron:SetPoint("LEFT", 8, 0)
        chevron:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\chevron_right")
        chevron:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        section.chevron = chevron

        -- Title
        local titleText = header:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        titleText:SetPoint("LEFT", 26, 0)
        titleText:SetText(string.upper(sectionTitle))
        titleText:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        section.titleText = titleText

        -- Active count badge
        local badgeText = header:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        badgeText:SetPoint("RIGHT", -8, 0)
        badgeText:SetText("")
        section.badgeText = badgeText

        -- Content container (starts hidden since collapsed by default)
        local content = CreateFrame("Frame", nil, section)
        content:SetPoint("TOPLEFT", 0, -28)
        content:SetWidth(CONTENT_WIDTH)
        content:Hide()
        section.content = content

        -- Grid for checkboxes (2 columns)
        local gridRow = 0
        local gridCol = 0
        local COL_WIDTH = (CONTENT_WIDTH - 8) / 2

        section.AddCheckbox = function(self, text, dbKey, callback, pageId)
            local cb = CreateThemedCheckbox(content, text, dbKey, callback, pageId)
            cb.section = self
            local xOff = gridCol * COL_WIDTH + 4
            local yOff = -(gridRow * 24 + 4)
            cb:SetPoint("TOPLEFT", content, "TOPLEFT", xOff, yOff)
            table.insert(self.checkboxes, cb)
            -- Advance grid position
            gridCol = gridCol + 1
            if gridCol >= 2 then
                gridCol = 0
                gridRow = gridRow + 1
            end
            return cb
        end

        -- Returns the Y offset below the checkbox grid
        local function GetGridBottom()
            local rows = math.ceil(#section.checkboxes / 2)
            return -(rows * 24 + 4)
        end

        section.AddWidget = function(self, widget, height)
            widget:SetParent(content)
            local yOff = GetGridBottom()
            -- Account for previous extra widgets
            for _, entry in ipairs(self.extraWidgets) do
                yOff = yOff - entry.height
            end
            widget:SetPoint("TOPLEFT", content, "TOPLEFT", 4, yOff - 2)
            widget:SetWidth(CONTENT_WIDTH - 8)
            table.insert(self.extraWidgets, {widget = widget, height = height})
        end

        section.GetContentHeight = function(self)
            local rows = math.ceil(#self.checkboxes / 2)
            local h = rows * 24 + 8  -- Grid height + padding
            for _, entry in ipairs(self.extraWidgets) do
                h = h + entry.height
            end
            return h
        end

        section.GetTotalHeight = function(self)
            if self.expanded then
                return 26 + self:GetContentHeight() + 4  -- header + content + gap
            end
            return 26 + 4  -- Just header + gap
        end

        section.UpdateBadge = function(self)
            local count = 0
            for _, cb in ipairs(self.checkboxes) do
                if cb.checked then count = count + 1 end
            end
            if count > 0 then
                local c = GetThemeColor()
                self.badgeText:SetText(tostring(count))
                self.badgeText:SetTextColor(c.r, c.g, c.b, 0.8)
            else
                self.badgeText:SetText("")
            end
        end

        section.SetExpanded = function(self, expanded)
            self.expanded = expanded
            if self.expanded then
                self.chevron:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\expand_more")
                self.content:Show()
            else
                self.chevron:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\chevron_right")
                self.content:Hide()
            end
        end

        section.Toggle = function(self)
            self:SetExpanded(not self.expanded)
            -- Save collapsed state to DB
            if self.sectionKey and DF.db then
                if not DF.db.testPanelSections then DF.db.testPanelSections = {} end
                DF.db.testPanelSections[self.sectionKey] = self.expanded
            end
            panel:RecalculateLayout()
        end

        -- Hover effects on header
        header:SetScript("OnEnter", function(self)
            self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 0.8)
        end)
        header:SetScript("OnLeave", function(self)
            self:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 0.8)
        end)
        header:SetScript("OnClick", function()
            section:Toggle()
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        end)

        -- Set content height
        content:SetHeight(1)  -- Will be updated

        table.insert(allSections, section)
        return section
    end

    -- ============================================================
    -- CREATE SECTIONS
    -- ============================================================

    -- --- GENERAL ---
    local secGeneral = CreateSection(panel, "General", "general")

    panel.showPetsCheck = secGeneral:AddCheckbox("Show Pets", "testShowPets", function(enabled, isRaidMode)
        if isRaidMode then
            if DF.raidTestMode then
                if enabled then
                    if DF.InitializeTestRaidPetFrames then DF:InitializeTestRaidPetFrames() end
                    if DF.UpdateAllRaidPetFrames then DF:UpdateAllRaidPetFrames(true) end
                else
                    if DF.HideAllTestRaidPetFrames then DF:HideAllTestRaidPetFrames() end
                end
            end
        else
            if DF.testMode then
                if enabled then
                    if DF.InitializeTestPetFrames then DF:InitializeTestPetFrames() end
                    if DF.UpdateAllPetFrames then DF:UpdateAllPetFrames(true) end
                else
                    if DF.HideAllTestPetFrames then DF:HideAllTestPetFrames() end
                end
            end
        end
    end, "display_pets")

    panel.animHealthCheck = secGeneral:AddCheckbox("Animate Health", "testAnimateHealth", function(enabled, isRaidMode)
        if isRaidMode then
            if DF.raidTestMode then
                if enabled then DF:StartTestAnimation()
                else
                    local partyDb = DF:GetDB()
                    if not (DF.testMode and partyDb.testAnimateHealth) then DF:StopTestAnimation() end
                end
            end
        else
            if DF.testMode then
                if enabled then DF:StartTestAnimation()
                else
                    local raidDb = DF:GetRaidDB()
                    if not (DF.raidTestMode and raidDb.testAnimateHealth) then DF:StopTestAnimation() end
                end
            end
        end
    end)

    -- Frame count slider (below checkboxes)
    local fcRow = CreateFrame("Frame", nil, secGeneral.content)
    fcRow:SetHeight(28)
    local fcLabel = fcRow:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    fcLabel:SetPoint("LEFT", 0, 0)
    fcLabel:SetText("Frame Count")
    fcLabel:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    local fcValue = fcRow:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    fcValue:SetPoint("LEFT", fcLabel, "RIGHT", 6, 0)
    panel.frameCountValue = fcValue

    local frameCountSlider = CreateThemedSlider(fcRow, 140, 1, 5, 1)
    frameCountSlider:SetPoint("LEFT", fcValue, "RIGHT", 8, 0)

    local frameCountDragging = false
    frameCountSlider:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            frameCountDragging = true
            DF:OnSliderDragStart(function()
                if DF.LightweightUpdateTestFrameCount then DF:LightweightUpdateTestFrameCount() end
            end)
        end
    end)
    frameCountSlider:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and frameCountDragging then
            frameCountDragging = false
            DF:OnSliderDragStop()
        end
    end)
    frameCountSlider:HookScript("OnValueChanged", function(self, value)
        local isRaidMode = DF.GUI and DF.GUI.SelectedMode == "raid"
        local db = isRaidMode and DF:GetRaidDB() or DF:GetDB()
        local dbKey = isRaidMode and "raidTestFrameCount" or "testFrameCount"
        db[dbKey] = math.floor(value)
        fcValue:SetText(tostring(db[dbKey]))
        if isRaidMode and DF.raidTestMode then
            DF:ThrottledUpdateRaidTestFrames()
            if not DF.sliderDragging and DF.UpdateAllRaidPetFrames then DF:UpdateAllRaidPetFrames(true) end
        elseif not isRaidMode and DF.testMode then
            DF:ThrottledUpdateAll()
            if not DF.sliderDragging and DF.UpdateAllPetFrames then DF:UpdateAllPetFrames(true) end
        end
        -- Re-anchor permanent mover when frame count changes
        C_Timer.After(0.1, function()
            DF:UpdatePermanentMoverAnchor(isRaidMode and "raid" or "party")
        end)
    end)
    panel.frameCountSlider = frameCountSlider
    secGeneral:AddWidget(fcRow, 28)

    -- --- BARS & OVERLAYS ---
    local secBars = CreateSection(panel, "Bars & Overlays", "bars")
    panel.showAbsorbsCheck = secBars:AddCheckbox("Absorbs", "testShowAbsorbs", nil, "bars_absorb")
    panel.showHealPredictCheck = secBars:AddCheckbox("Heal Prediction", "testShowHealPrediction", nil, "bars_healpred")
    panel.showClassPowerCheck = secBars:AddCheckbox("Class Power", "testShowClassPower", function(enabled)
        if enabled then
            if DF.UpdateAllTestClassPower then DF:UpdateAllTestClassPower() end
        else
            if DF.CleanupTestClassPower then DF:CleanupTestClassPower() end
        end
    end, "bars_classpower")
    panel.showOutOfRangeCheck = secBars:AddCheckbox("Out of Range", "testShowOutOfRange", nil, "display_fading")

    -- --- AURAS ---
    local secAuras = CreateSection(panel, "Auras", "auras")
    panel.showAurasCheck = secAuras:AddCheckbox("Show Auras", "testShowAuras", function(enabled, isRaidMode)
        if enabled and not isRaidMode and DF.testMode then DF:RefreshTestFramesWithLayout() end
    end, "auras_buffs")
    panel.showBossDebuffsCheck = secAuras:AddCheckbox("Boss Debuffs", "testShowBossDebuffs", function(enabled, isRaidMode)
        if isRaidMode then
            if DF.raidTestMode then
                for i = 1, 40 do
                    local frame = DF.testRaidFrames[i]
                    if frame then
                        if enabled then DF:UpdateTestBossDebuffs(frame)
                        else DF:HideTestBossDebuffs(frame) end
                    end
                end
            end
        else
            if DF.testMode then
                for i = 0, 4 do
                    local frame = DF.testPartyFrames[i]
                    if frame then
                        if enabled then DF:UpdateTestBossDebuffs(frame)
                        else DF:HideTestBossDebuffs(frame) end
                    end
                end
            end
        end
    end, "auras_bossdebuffs")
    panel.showDispelGlowCheck = secAuras:AddCheckbox("Dispel Overlay", "testShowDispelGlow", function()
        if DF.testMode or DF.raidTestMode then DF:UpdateAllTestDispelGlow() end
    end, "auras_dispel")
    panel.showMissingBuffCheck = secAuras:AddCheckbox("Missing Buff", "testShowMissingBuff", function()
        if DF.testMode or DF.raidTestMode then DF:UpdateAllTestMissingBuff() end
    end, "auras_missingbuffs")
    panel.showADCheck = secAuras:AddCheckbox("Aura Designer", "testShowAuraDesigner", function(enabled)
        if DF.testMode or DF.raidTestMode then DF:UpdateAllTestAuraDesigner() end
    end, "auras_auradesigner")

    -- Buff/Debuff count sliders
    local auraSliderRow = CreateFrame("Frame", nil, secAuras.content)
    auraSliderRow:SetHeight(18)

    local buffLabel = auraSliderRow:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    buffLabel:SetPoint("LEFT", 0, 0)
    buffLabel:SetText("Buffs:")
    buffLabel:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)

    local buffSlider = CreateThemedSlider(auraSliderRow, 55, 0, 5, 1)
    buffSlider:SetPoint("LEFT", buffLabel, "RIGHT", 5, 0)
    local buffValue = auraSliderRow:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    buffValue:SetPoint("LEFT", buffSlider, "RIGHT", 4, 0)
    buffValue:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    panel.buffValueText = buffValue

    local debuffLabel = auraSliderRow:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    debuffLabel:SetPoint("LEFT", buffValue, "RIGHT", 12, 0)
    debuffLabel:SetText("Debuffs:")
    debuffLabel:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)

    local debuffSlider = CreateThemedSlider(auraSliderRow, 55, 0, 5, 1)
    debuffSlider:SetPoint("LEFT", debuffLabel, "RIGHT", 5, 0)
    local debuffValue = auraSliderRow:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    debuffValue:SetPoint("LEFT", debuffSlider, "RIGHT", 4, 0)
    debuffValue:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    panel.debuffValueText = debuffValue

    -- Buff slider callbacks
    local buffSliderDragging = false
    buffSlider:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            buffSliderDragging = true
            DF:OnSliderDragStart(function() if DF.RefreshTestFrames then DF:RefreshTestFrames() end end)
        end
    end)
    buffSlider:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and buffSliderDragging then
            buffSliderDragging = false
            DF:OnSliderDragStop()
        end
    end)
    buffSlider:HookScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        local isRaidMode = DF.raidTestMode
        local db = isRaidMode and DF:GetRaidDB() or DF:GetDB()
        db.testBuffCount = value
        buffValue:SetText(value)
        if DF.raidTestMode then DF:ThrottledUpdateRaidTestFrames()
        elseif DF.testMode then DF:ThrottledUpdateAll() end
    end)
    panel.buffSlider = buffSlider

    -- Debuff slider callbacks
    local debuffSliderDragging = false
    debuffSlider:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            debuffSliderDragging = true
            DF:OnSliderDragStart(function() if DF.RefreshTestFrames then DF:RefreshTestFrames() end end)
        end
    end)
    debuffSlider:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and debuffSliderDragging then
            debuffSliderDragging = false
            DF:OnSliderDragStop()
        end
    end)
    debuffSlider:HookScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        local isRaidMode = DF.raidTestMode
        local db = isRaidMode and DF:GetRaidDB() or DF:GetDB()
        db.testDebuffCount = value
        debuffValue:SetText(value)
        if DF.raidTestMode then DF:ThrottledUpdateRaidTestFrames()
        elseif DF.testMode then DF:ThrottledUpdateAll() end
    end)
    panel.debuffSlider = debuffSlider

    secAuras:AddWidget(auraSliderRow, 22)

    -- --- INDICATORS & ICONS ---
    local secIndicators = CreateSection(panel, "Indicators & Icons", "indicators")
    panel.showExternalDefCheck = secIndicators:AddCheckbox("Defensive Icon", "testShowExternalDef", function()
        if DF.testMode or DF.raidTestMode then DF:UpdateAllTestDefensiveBar() end
    end, "auras_defensiveicon")
    -- "Targeted Spell" was the old group-frame icon display that
    -- Blizzard's 2026-04-07 hotfix killed. The checkbox slot is now
    -- repurposed for the Targeted List (alpha/beta-only feature).
    panel.showTargetedListCheck = secIndicators:AddCheckbox("Targeted List", "testShowTargetedList", function()
        if DF.testMode or DF.raidTestMode then DF:UpdateAllTestTargetedList() end
    end, "indicators_targetedlist")
    panel.animTargetedListCheck = secIndicators:AddCheckbox("Animate Targeted List", "testAnimateTargetedList", function()
        if DF.testMode or DF.raidTestMode then DF:UpdateAllTestTargetedList() end
    end)
    panel.showStatusIconsCheck = secIndicators:AddCheckbox("Status / Ready", "testShowStatusIcons", function()
        if DF.testMode or DF.raidTestMode then DF:RefreshTestFrames() end
    end, "indicators_icons")
    panel.showIconsCheck = secIndicators:AddCheckbox("Role / Leader", "testShowIcons", nil, "indicators_icons")

    -- --- HIGHLIGHTS ---
    local secHighlights = CreateSection(panel, "Highlights", "highlights")
    panel.showSelectionCheck = secHighlights:AddCheckbox("Selection", "testShowSelection", function()
        if DF.UpdateAllTestHighlights then DF:UpdateAllTestHighlights() end
    end, "indicators_highlights")
    panel.showAggroCheck = secHighlights:AddCheckbox("Aggro", "testShowAggro", function()
        if DF.UpdateAllTestHighlights then DF:UpdateAllTestHighlights() end
    end, "indicators_highlights")

    -- ============================================================
    -- PRESETS FOOTER
    -- ============================================================
    local presetsFooter = CreateFrame("Frame", nil, panel)
    presetsFooter:SetPoint("BOTTOMLEFT", 0, 0)
    presetsFooter:SetPoint("BOTTOMRIGHT", 0, 0)
    presetsFooter:SetHeight(58)

    local presetSep = presetsFooter:CreateTexture(nil, "ARTWORK")
    presetSep:SetPoint("TOPLEFT", 0, 0)
    presetSep:SetPoint("TOPRIGHT", 0, 0)
    presetSep:SetHeight(1)
    presetSep:SetColorTexture(1, 1, 1, 0.06)

    local presetLabel = presetsFooter:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    presetLabel:SetPoint("TOPLEFT", 12, -8)
    presetLabel:SetText("QUICK PRESETS")
    presetLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 0.7)
    panel.presetLabel = presetLabel

    local presets = {"STATIC", "COMBAT", "HEALER", "FULL"}
    local presetNames = {STATIC = "Static", COMBAT = "Combat", HEALER = "Healer", FULL = "Full"}
    local btnSpacing = 4
    local btnCount = #presets
    local btnWidth = math.floor((CONTENT_WIDTH - (btnSpacing * (btnCount - 1))) / btnCount)
    panel.presetBtns = {}

    for i, preset in ipairs(presets) do
        local btn = CreateFrame("Button", nil, presetsFooter, "BackdropTemplate")
        btn:SetSize(btnWidth, 24)
        btn:SetPoint("TOPLEFT", 12 + (i - 1) * (btnWidth + btnSpacing), -26)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        btn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        btn.Text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
        btn.Text:SetPoint("CENTER")
        btn.Text:SetText(presetNames[preset])
        btn.preset = preset
        btn:SetScript("OnClick", function(self)
            DF:ApplyTestPreset(self.preset)
            panel:UpdateState()
        end)
        btn:SetScript("OnEnter", function(self)
            local themeColor = GetThemeColor()
            self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 0.7)
        end)
        btn:SetScript("OnLeave", function(self)
            local isRaidMode = DF.GUI and DF.GUI.SelectedMode == "raid"
            local db = isRaidMode and DF:GetRaidDB() or DF:GetDB()
            local themeColor = GetThemeColor()
            if self.preset == db.testPreset then
                self:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
            else
                self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
            end
        end)
        panel.presetBtns[i] = btn
    end

    -- ============================================================
    -- LAYOUT CALCULATION
    -- ============================================================
    function panel:RecalculateLayout()
        local y = -HEADER_TOP
        for _, sec in ipairs(allSections) do
            sec:ClearAllPoints()
            sec:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, y)
            sec.content:SetHeight(sec:GetContentHeight())
            sec:SetHeight(sec:GetTotalHeight())  -- Section needs valid height for children to render
            y = y - sec:GetTotalHeight()
        end
        -- Set panel height: sections + header + presets footer
        local totalHeight = HEADER_TOP + math.abs(y - (-HEADER_TOP)) + 62  -- 62 = presets footer
        self:SetHeight(math.max(totalHeight, 200))
    end

    -- ============================================================
    -- UPDATE STATE
    -- ============================================================
    local function UpdateStateInternal(self, callbackEnabled)
        local isRaidMode = DF.GUI and DF.GUI.SelectedMode == "raid"
        local db = isRaidMode and DF:GetRaidDB() or DF:GetDB()
        local themeColor = GetThemeColor()
        local testActive = IsTestActive()

        -- Title
        self.title:SetText("Test Mode")
        self.title:SetTextColor(themeColor.r, themeColor.g, themeColor.b)

        -- Badge
        local badgeLabel = isRaidMode and "Raid" or "Party"
        self.badge.text:SetText(badgeLabel)
        self.badge:SetSize(self.badge.text:GetStringWidth() + 14, 18)
        self.badge:SetBackdropColor(themeColor.r * 0.15, themeColor.g * 0.15, themeColor.b * 0.15, 1)
        self.badge:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 0.3)
        self.badge.text:SetTextColor(themeColor.r, themeColor.g, themeColor.b)

        -- Toggle button
        if testActive then
            self.toggleBtn:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
            self.toggleBtn:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
            self.toggleBtn.Text:SetText("Disable Test Mode")
            self.toggleBtn.Text:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
        else
            self.toggleBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
            self.toggleBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
            self.toggleBtn.Text:SetText("Enable Test Mode")
            self.toggleBtn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        end

        -- Frame count slider
        local maxFrames = isRaidMode and 40 or 5
        local fcKey = isRaidMode and "raidTestFrameCount" or "testFrameCount"
        local currentCount = db[fcKey] or (isRaidMode and 10 or 5)
        self.frameCountSlider:SetMinMaxValues(1, maxFrames)
        self.frameCountSlider:SetValue(currentCount)
        if self.frameCountSlider.UpdateTheme then self.frameCountSlider:UpdateTheme() end
        self.frameCountValue:SetText(tostring(currentCount))
        self.frameCountValue:SetTextColor(themeColor.r, themeColor.g, themeColor.b)

        -- Checkboxes from DB
        self.animHealthCheck:SetChecked(db.testAnimateHealth)
        self.showPetsCheck:SetChecked(db.testShowPets ~= false)
        self.showAbsorbsCheck:SetChecked(db.testShowAbsorbs)
        self.showHealPredictCheck:SetChecked(db.testShowHealPrediction ~= false)
        self.showClassPowerCheck:SetChecked(db.testShowClassPower ~= false)
        self.showOutOfRangeCheck:SetChecked(db.testShowOutOfRange)
        self.showAurasCheck:SetChecked(db.testShowAuras)
        self.showBossDebuffsCheck:SetChecked(db.testShowBossDebuffs)
        self.showDispelGlowCheck:SetChecked(db.testShowDispelGlow)
        self.showMissingBuffCheck:SetChecked(db.testShowMissingBuff)
        self.showADCheck:SetChecked(db.testShowAuraDesigner)
        self.showExternalDefCheck:SetChecked(db.testShowExternalDef)
        self.showTargetedListCheck:SetChecked(db.testShowTargetedList)
        self.animTargetedListCheck:SetChecked(db.testAnimateTargetedList)
        self.showStatusIconsCheck:SetChecked(db.testShowStatusIcons ~= false)
        self.showIconsCheck:SetChecked(db.testShowIcons ~= false)
        self.showSelectionCheck:SetChecked(db.testShowSelection)
        self.showAggroCheck:SetChecked(db.testShowAggro)

        -- Buff/Debuff sliders
        local buffCount = db.testBuffCount or 3
        self.buffSlider:SetValue(buffCount)
        self.buffValueText:SetText(buffCount)
        if self.buffSlider.UpdateTheme then self.buffSlider:UpdateTheme() end
        local debuffCount = db.testDebuffCount or 3
        self.debuffSlider:SetValue(debuffCount)
        self.debuffValueText:SetText(debuffCount)
        if self.debuffSlider.UpdateTheme then self.debuffSlider:UpdateTheme() end

        -- Restore section collapsed states from DB and update badges
        local savedSections = DF.db and DF.db.testPanelSections
        for _, sec in ipairs(allSections) do
            if savedSections and sec.sectionKey and savedSections[sec.sectionKey] ~= nil then
                sec:SetExpanded(savedSections[sec.sectionKey])
            end
            sec:UpdateBadge()
        end

        -- Preset buttons
        for _, btn in ipairs(self.presetBtns) do
            if btn.preset == db.testPreset then
                btn:SetBackdropColor(themeColor.r * 0.3, themeColor.g * 0.3, themeColor.b * 0.3, 1)
                btn:SetBackdropBorderColor(themeColor.r, themeColor.g, themeColor.b, 1)
                btn.Text:SetTextColor(themeColor.r, themeColor.g, themeColor.b)
            else
                btn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
                btn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
                btn.Text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
            end
        end

        -- Recalculate layout
        self:RecalculateLayout()

        if callbackEnabled and DF.GUI and DF.GUI.UpdateTestButtonState then
            DF.GUI.UpdateTestButtonState()
        end
    end

    function panel:UpdateState()
        UpdateStateInternal(self, true)
    end

    function panel:UpdateStateNoCallback()
        UpdateStateInternal(self, false)
    end

    -- ============================================================
    -- ONSHOW
    -- ============================================================
    panel:SetScript("OnShow", function(self)
        ApplyScale(self)
        self:UpdateState()
    end)

    DF.TestPanel = panel
    return panel
end

function DF:ToggleTestPanel()
    local panel = DF:CreateTestPanel()
    if panel:IsShown() then
        panel:Hide()
    else
        panel:UpdateState()
        panel:Show()
        
        -- Auto-enable test mode when panel opens
        local isRaidMode = DF.GUI and DF.GUI.SelectedMode == "raid"
        if isRaidMode then
            if not DF.raidTestMode then
                DF:ShowRaidTestFrames()
                panel:UpdateState()
            end
        else
            if not DF.testMode then
                DF:ShowTestFrames()
                panel:UpdateState()
            end
        end
    end
end
