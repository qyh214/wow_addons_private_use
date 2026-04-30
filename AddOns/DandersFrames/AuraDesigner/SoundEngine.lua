local addonName, DF = ...

-- ============================================================
-- AURA DESIGNER - SOUND ENGINE
-- Plays looping alert sounds when configured buffs are missing
-- from party/raid members. Runs an independent 1 Hz evaluation
-- ticker separate from the visual indicator pipeline.
--
-- State machine per aura: IDLE → DELAYED → PLAYING
-- Uses CVar-swap technique for per-indicator volume control.
-- ============================================================

local pairs, ipairs, wipe = pairs, ipairs, wipe
local GetTime = GetTime
local GetCVar, SetCVar = GetCVar, SetCVar
local PlaySoundFile = PlaySoundFile
local StopSound = StopSound
local InCombatLockdown = InCombatLockdown
local UnitExists = UnitExists
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsConnected = UnitIsConnected
local IsInGroup = IsInGroup
local tonumber = tonumber

DF.AuraDesigner = DF.AuraDesigner or {}

local SoundEngine = {}
DF.AuraDesigner.SoundEngine = SoundEngine

-- States
local STATE_IDLE    = 0
local STATE_DELAYED = 1
local STATE_PLAYING = 2

-- Per-aura state: { state, delayStart, ticker, lastHandle }
local soundStates = {}

-- Evaluation suppression (instance transitions)
local suppressUntil = 0

-- Reference to adapter (lazy init)
local Adapter

-- Reusable presence table (wiped each evaluation)
local presenceData = {}  -- auraName → { present = N, total = N, soundCfg = cfg }

-- ============================================================
-- SOUND PLAYBACK (CVar-swap for per-indicator volume)
-- ============================================================

function SoundEngine:PlayWithVolume(soundFile, volume)
    if not soundFile or volume <= 0 then return nil, nil end

    local originalVol = tonumber(GetCVar("Sound_SFXVolume")) or 1.0
    local targetVol = originalVol * volume
    if targetVol > 1.0 then targetVol = 1.0 end

    SetCVar("Sound_SFXVolume", targetVol)
    local willPlay, handle = PlaySoundFile(soundFile, "SFX")
    SetCVar("Sound_SFXVolume", originalVol)

    if not willPlay then
        DF:DebugWarn("SoundEngine", "PlaySoundFile failed for: %s", tostring(soundFile))
        return nil, nil
    end

    return willPlay, handle
end

-- ============================================================
-- STATE MACHINE
-- ============================================================

local function StopTicker(state)
    if state.ticker then
        state.ticker:Cancel()
        state.ticker = nil
    end
end

local function StopLastSound(state)
    if state.lastHandle then
        StopSound(state.lastHandle)
        state.lastHandle = nil
    end
end

function SoundEngine:TransitionTo(auraName, newState)
    local s = soundStates[auraName]
    if not s then
        s = { state = STATE_IDLE }
        soundStates[auraName] = s
    end

    -- Cleanup previous state
    if s.state == STATE_PLAYING then
        StopTicker(s)
        StopLastSound(s)
    end

    s.state = newState
    if newState == STATE_IDLE then
        s.delayStart = nil
    end
end

function SoundEngine:StartLoop(auraName, soundCfg)
    local s = soundStates[auraName]
    if not s then return end

    -- Re-read soundCfg fields on every tick so live GUI edits (sound, volume,
    -- loop interval) take effect without requiring the user to disable and
    -- re-enable the sound alert. soundCfg is a reference to the db table, so
    -- field mutations from the Options panel are visible here.
    local function tick()
        -- Re-check global mute each tick. nil = default (enabled) — only an
        -- explicit false means muted. Older profiles predate soundEnabled and
        -- have nil, which would otherwise register as muted.
        local mode = DF:GetCurrentMode()
        local db = DF:GetDB(mode)
        if not db or not db.auraDesigner or db.auraDesigner.soundEnabled == false then
            self:TransitionTo(auraName, STATE_IDLE)
            return
        end

        local soundFile = DF:GetSoundPath(soundCfg.soundLSMKey) or soundCfg.soundFile
        local volume = soundCfg.volume or 0.8
        if not soundFile or volume <= 0 then
            self:TransitionTo(auraName, STATE_IDLE)
            return
        end

        local _, h = self:PlayWithVolume(soundFile, volume)
        s.lastHandle = h

        -- Self-reschedule with the current interval so slider changes apply immediately
        local interval = soundCfg.loopInterval or 3
        s.ticker = C_Timer.NewTimer(interval, tick)
    end

    -- Initial play uses the same path to pick up any last-second config changes
    local soundFile = DF:GetSoundPath(soundCfg.soundLSMKey) or soundCfg.soundFile
    local volume = soundCfg.volume or 0.8
    if not soundFile or volume <= 0 then
        self:TransitionTo(auraName, STATE_IDLE)
        return
    end

    local _, handle = self:PlayWithVolume(soundFile, volume)
    s.lastHandle = handle

    local interval = soundCfg.loopInterval or 3
    s.ticker = C_Timer.NewTimer(interval, tick)
end

-- ============================================================
-- EVALUATE (called per aura from RunEvaluation)
-- ============================================================

function SoundEngine:Evaluate(auraName, soundCfg, isMissing, inCombat)
    -- Volume zero: skip entirely (treat as disabled)
    if (soundCfg.volume or 0.8) <= 0 then
        local s = soundStates[auraName]
        if s and s.state ~= STATE_IDLE then
            self:TransitionTo(auraName, STATE_IDLE)
        end
        return
    end

    -- Combat mode filter
    local combatMode = soundCfg.combatMode or "ALWAYS"
    if combatMode == "IN_COMBAT" and not inCombat then
        isMissing = false
    elseif combatMode == "OUT_OF_COMBAT" and inCombat then
        isMissing = false
    end

    local s = soundStates[auraName]
    if not s then
        s = { state = STATE_IDLE }
        soundStates[auraName] = s
    end

    if s.state == STATE_IDLE then
        if isMissing then
            local delay = soundCfg.startDelay or 2
            if delay <= 0 then
                -- No delay, go straight to playing
                self:TransitionTo(auraName, STATE_PLAYING)
                self:StartLoop(auraName, soundCfg)
            else
                s.state = STATE_DELAYED
                s.delayStart = GetTime()
            end
        end

    elseif s.state == STATE_DELAYED then
        if not isMissing then
            -- Condition cleared during delay — back to idle, no sound played
            self:TransitionTo(auraName, STATE_IDLE)
        else
            local delay = soundCfg.startDelay or 2
            if (GetTime() - s.delayStart) >= delay then
                self:TransitionTo(auraName, STATE_PLAYING)
                self:StartLoop(auraName, soundCfg)
            end
        end

    elseif s.state == STATE_PLAYING then
        if not isMissing then
            self:TransitionTo(auraName, STATE_IDLE)
        end
    end
end

-- ============================================================
-- 1 HZ EVALUATION TICKER
-- Iterates visible frames, queries adapter, evaluates sound state
-- ============================================================

function SoundEngine:RunEvaluation()
    -- Suppression check (instance transitions)
    if GetTime() < suppressUntil then return end

    -- Must be in a group
    if not IsInGroup() then
        self:StopAll()
        return
    end

    -- Lazy init adapter
    if not Adapter then
        Adapter = DF.AuraDesigner.Adapter
    end
    if not Adapter then return end

    local mode = DF:GetCurrentMode()
    local db = DF:GetDB(mode)
    if not db or not db.auraDesigner or not db.auraDesigner.enabled then
        self:StopAll()
        return
    end

    local adDB = db.auraDesigner

    -- Global mute check. nil = default (enabled); only explicit false is muted.
    if adDB.soundEnabled == false then
        self:StopAll()
        return
    end

    -- Resolve spec
    local spec
    if adDB.spec == "auto" then
        spec = Adapter:GetPlayerSpec()
    else
        spec = adDB.spec
    end
    if not spec then return end

    local specAuras = adDB.auras and adDB.auras[spec]
    if not specAuras then return end

    -- Collect which auras have sound configs
    wipe(presenceData)
    local hasSoundAuras = false
    for auraName, auraCfg in pairs(specAuras) do
        if type(auraCfg) == "table" and auraCfg.sound and auraCfg.sound.enabled then
            presenceData[auraName] = { present = 0, total = 0, soundCfg = auraCfg.sound, longestRemaining = 0, longestDuration = 0 }
            hasSoundAuras = true
        end
    end

    if not hasSoundAuras then
        self:StopAll()
        return
    end

    -- Iterate visible frames for the active mode
    local frames
    if mode == "raid" then
        frames = DF:GetAllRaidFrames()
    else
        frames = {}
        if DF.partyHeader then
            local children = { DF.partyHeader:GetChildren() }
            for _, child in ipairs(children) do
                frames[#frames + 1] = child
            end
        end
    end

    for _, frame in ipairs(frames) do
        if frame:IsVisible() and frame.unit and UnitExists(frame.unit) then
            -- Skip dead/disconnected units
            if UnitIsConnected(frame.unit) and not UnitIsDeadOrGhost(frame.unit) then
                local activeAuras = Adapter:GetUnitAuras(frame.unit, spec)

                for auraName, pd in pairs(presenceData) do
                    pd.total = pd.total + 1
                    if activeAuras and activeAuras[auraName] then
                        pd.present = pd.present + 1
                        -- Track longest remaining duration for expire alerts
                        local auraData = activeAuras[auraName]
                        if auraData.expirationTime and auraData.expirationTime > 0 then
                            local remaining = auraData.expirationTime - GetTime()
                            if remaining > pd.longestRemaining then
                                pd.longestRemaining = remaining
                                pd.longestDuration = auraData.duration or 0
                            end
                        end
                    end
                end
            end
        end
    end

    -- Evaluate each sound-configured aura
    local inCombat = InCombatLockdown()
    for auraName, pd in pairs(presenceData) do
        local isMissing
        local triggerMode = pd.soundCfg.triggerMode or "ANY_MISSING"

        if pd.total == 0 then
            isMissing = false
        elseif triggerMode == "ALL_MISSING" then
            isMissing = (pd.present == 0)
        else  -- ANY_MISSING
            isMissing = (pd.present < pd.total)
        end

        self:Evaluate(auraName, pd.soundCfg, isMissing, inCombat)
    end

    -- Evaluate expire alerts (sound when longest remaining duration drops below threshold)
    for auraName, pd in pairs(presenceData) do
        local expireCfg = pd.soundCfg
        if expireCfg.expireEnabled then
            local isExpiring = false
            if pd.present > 0 and pd.longestRemaining > 0 then
                local mode = expireCfg.expireThresholdMode or "SECONDS"
                if mode == "PERCENT" then
                    local pct = (pd.longestDuration > 0) and (pd.longestRemaining / pd.longestDuration * 100) or 100
                    isExpiring = pct <= (expireCfg.expireThreshold or 30)
                else
                    isExpiring = pd.longestRemaining <= (expireCfg.expireThreshold or 5)
                end
            end
            self:Evaluate(auraName .. "|expire", expireCfg, isExpiring, inCombat)
        end
    end

    -- Stop sounds for auras that no longer have sound configs
    for stateKey, s in pairs(soundStates) do
        if s.state ~= STATE_IDLE then
            local baseAura = stateKey:match("^(.+)|expire$") or stateKey
            if not presenceData[baseAura] then
                self:TransitionTo(stateKey, STATE_IDLE)
            end
        end
    end
end

-- ============================================================
-- CLEANUP
-- ============================================================

function SoundEngine:StopAll()
    for auraName, s in pairs(soundStates) do
        if s.state ~= STATE_IDLE then
            self:TransitionTo(auraName, STATE_IDLE)
        end
    end
end

function SoundEngine:StopAura(auraName)
    if soundStates[auraName] and soundStates[auraName].state ~= STATE_IDLE then
        self:TransitionTo(auraName, STATE_IDLE)
    end
    local expireKey = auraName .. "|expire"
    if soundStates[expireKey] and soundStates[expireKey].state ~= STATE_IDLE then
        self:TransitionTo(expireKey, STATE_IDLE)
    end
end

-- ============================================================
-- INITIALIZATION
-- ============================================================

local evaluationTicker

function SoundEngine:Init()
    if evaluationTicker then return end  -- Already initialized

    -- 1 Hz evaluation ticker
    evaluationTicker = C_Timer.NewTicker(1.0, function()
        SoundEngine:RunEvaluation()
    end)

    -- Event frame for cleanup events
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

    eventFrame:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_SPECIALIZATION_CHANGED" then
            SoundEngine:StopAll()
            DF:Debug("SoundEngine", "Spec changed — stopped all sounds")

        elseif event == "GROUP_ROSTER_UPDATE" then
            if not IsInGroup() then
                SoundEngine:StopAll()
                DF:Debug("SoundEngine", "Left group — stopped all sounds")
            end

        elseif event == "PLAYER_ENTERING_WORLD" then
            suppressUntil = GetTime() + 3
            SoundEngine:StopAll()
            DF:Debug("SoundEngine", "Entering world — suppressing evaluation for 3s")
        end
    end)

    DF:Debug("SoundEngine", "Initialized with 1 Hz evaluation ticker")
end
