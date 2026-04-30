local appName, app = ...
---@class AbilityTimeline
local private = app
-- Utility: Encounter registration and Encounter Journal integration
-- Keeps reminders keyed by numeric encounterID and allows copying defaults from Data/ when available.

local function copyDefaultsToEncounter(encounterID, meta)
    if not meta or not meta.instanceID then return end
    local inst = private.Instances and private.Instances[meta.instanceID]
    if not inst or not inst.encounters then return end
    -- find encounter index within instance encounters
    local encounterIndex
    for idx, v in ipairs(inst.encounters) do
        if v == encounterID then
            encounterIndex = idx
            break
        end
    end
    if not encounterIndex then return end
    -- If default spell data exists for this instance/encounter, copy it.
    -- Data format may vary; attempt to copy if present as inst.spells[encounterIndex]
    if inst.spells and inst.spells[encounterIndex] then
        private.db.profile.reminders[encounterID] = private.db.profile.reminders[encounterID] or {}
        for _, spellDef in ipairs(inst.spells[encounterIndex]) do
            table.insert(private.db.profile.reminders[encounterID], spellDef)
        end
        private.Debug("Copied default spells for encounter " .. tostring(encounterID))
    end
end

-- Public: Register an encounter by numeric encounterID. Optionally merge metadata and copy defaults.
private.RegisterEncounter = function(encounterID, meta, copyDefaults)
    if not encounterID then return false end
    encounterID = tonumber(encounterID)
    if not encounterID then return false end
    private.db.profile.reminders[encounterID] = private.db.profile.reminders[encounterID] or {}
    -- If reminders already exist and copyDefaults requested, ask user whether to append defaults (non-destructive)
    if copyDefaults and private.db.profile.reminders[encounterID] and #private.db.profile.reminders[encounterID] > 0 then
        copyDefaultsToEncounter(encounterID, meta)
    end
    if meta then
        meta = meta or {}
        meta.name = meta.name or (select(1, EJ_GetEncounterInfo(encounterID)) or "Unknown")
        meta.instanceID = meta.instanceID or select(6, EJ_GetEncounterInfo(encounterID))
        meta.source = meta.source or "ej"
    end
    -- If copyDefaults requested but there were no existing reminders, copy immediately
    if copyDefaults and (#private.db.profile.reminders[encounterID] == 0) then
        copyDefaultsToEncounter(encounterID, meta)
    end
    private.Debug("Registered encounter " .. tostring(encounterID) .. " to AbilityTimeline")
    return true
end

-- Hook Encounter Journal display to add a button for adding the displayed encounter to AbilityTimeline
local createdBtn = false
local lastDisplayedEncounter = nil

local function ensureEJButton()
    if createdBtn then return end
    if not EncounterJournal or not hooksecurefunc then
        return
    end
    -- Hook the display call so we can show a button for the currently shown encounter
    hooksecurefunc("EncounterJournal_DisplayEncounter", function(encounterIndexOrID)
        -- Try to resolve passed value as either a journalEncounterID, a dungeonEncounterID, or an encounter index.
        -- Prefer the dungeonEncounterID (the numeric id fired by ENCOUNTER_START) when available.
        local name, _, journalEncounterID, _, _, journalInstanceID, dungeonEncounterID = EJ_GetEncounterInfo(
        encounterIndexOrID)
        if not journalEncounterID then
            -- get currently selected instance in EJ
            name, _, journalEncounterID, _, _, journalInstanceID, dungeonEncounterID = EJ_GetInstanceInfo()
        end
        -- Update module-level lastDisplayedEncounter so the persistent button's OnClick reads fresh values
        lastDisplayedEncounter = {
            name = name,
            journalEncounterID = journalEncounterID,
            journalInstanceID = journalInstanceID,
            dungeonEncounterID = dungeonEncounterID,
            raw = encounterIndexOrID,
        }
        if not EncounterJournal or not EncounterJournal.encounter then return end
        local infoFrame = EncounterJournal.encounter.info or _G["EncounterJournalEncounterFrameInfo"]
        if not infoFrame then return end
        if not infoFrame.AbilityTimelineAddButton then
            local btn = CreateFrame("Button", "AbilityTimelineEJAddButton", infoFrame, "EncounterTabTemplate")
            btn:SetPoint("TOP", EncounterJournalEncounterFrameInfoModelTab, "BOTTOM", 0, 0)

            btn.texture = btn:CreateTexture(nil, "OVERLAY")
            btn.texture:SetAllPoints()

            -- for some reason the texture sometimes randomly vanishes so we just reset it on show TODO fix properly
            local function applyTexture()
                btn.texture:SetTexture("Interface\\AddOns\\AbilityTimeline\\Media\\Textures\\logo_transparent.tga")
                btn.texture:Show()

                -- match skinning of EJ tabs if relevant for elvui
                if C_AddOns.IsAddOnLoaded("ElvUI") and ElvUI then
                    btn:CreateBackdrop('Transparent')
                    btn.backdrop:SetInside(nil, 2, 2)
                    btn:SetNormalTexture(0)
                    btn:SetPushedTexture(0)
                    btn:SetDisabledTexture(0)
                    local E, L, V, P, G = unpack(ElvUI)
                    local HighlightTexture = btn:GetHighlightTexture()
                    local r, g, b = unpack(E.media.rgbvaluecolor)
                    HighlightTexture:SetColorTexture(r, g, b, .2)
                    HighlightTexture:SetInside(btn.backdrop)
                end

            end
            
            applyTexture()
            btn:HookScript("OnShow", applyTexture)

            btn.tooltip = private.getLocalisation("EditRemindersForEncounter")
            btn:SetText(private.getLocalisation("EditRemindersForEncounter"))
            btn:SetScript("OnClick", function()
                local entry = lastDisplayedEncounter
                if not entry or (not entry.journalEncounterID and not entry.dungeonEncounterID and not entry.raw) then
                    StaticPopupDialogs["ABILITYTIMELINE_CANNOT_RESOLVE"] = StaticPopupDialogs
                    ["ABILITYTIMELINE_CANNOT_RESOLVE"] or {
                        text = private.getLocalisation and private.getLocalisation("CannotResolveEncounter") or
                        "Could not resolve encounter",
                        button1 = OKAY,
                        timeout = 0,
                        whileDead = true,
                        hideOnEscape = true,
                    }
                    StaticPopup_Show("ABILITYTIMELINE_CANNOT_RESOLVE")
                    return
                end
                -- Register encounter and open editor using explicit EJ ids
                local key = entry.dungeonEncounterID or entry.journalEncounterID or entry.raw
                key = tonumber(key) or key
                private.RegisterEncounter(key,
                    { name = entry.name, instanceID = entry.journalInstanceID, journalID = entry.journalEncounterID },
                    true)
                local params = {
                    journalEncounterID = entry.journalEncounterID,
                    journalInstanceID = entry.journalInstanceID,
                    dungeonEncounterID = entry.dungeonEncounterID or key,
                }
                private.openTimingsEditor(params)
            end)
            EncounterJournalEncounterFrameInfoModelTab:HookScript("OnDisable", function(self)
                btn:DesaturateHierarchy(100)
                btn:Disable()
            end)
            EncounterJournalEncounterFrameInfoModelTab:HookScript("OnEnable", function(self)
                btn:DesaturateHierarchy(0)
                btn:Enable()
                -- Reapply texture after desaturation
                applyTexture()
            end)
            infoFrame.AbilityTimelineAddButton = btn
        else
            infoFrame.AbilityTimelineAddButton:Show()
        end
    end)

    createdBtn = true
end


local ejListener = CreateFrame("Frame")
ejListener:RegisterEvent("ADDON_LOADED")
ejListener:SetScript("OnEvent", function(self, event, name)
    if name == "Blizzard_EncounterJournal" then
        ensureEJButton()
    end
end)
