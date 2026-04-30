local addonName, DF = ...

-- Get module namespace
local CC = DF.ClickCast

-- EVENT HANDLING
-- ============================================================

function CC:RegisterEvents()
    local eventFrame = CreateFrame("Frame")
    self.eventFrame = eventFrame
    
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
    eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    
    -- Talent/Loadout events for profile auto-switching
    eventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
    eventFrame:RegisterEvent("TRAIT_CONFIG_CREATED")
    eventFrame:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")
    eventFrame:RegisterEvent("ACTIVE_COMBAT_CONFIG_CHANGED")  -- Fires when loadout is switched
    -- Events for dynamic frames (boss/arena)
    eventFrame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
    eventFrame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
    
    -- Nameplate events for click-casting on nameplates
    eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    
    eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_REGEN_ENABLED" then
            -- Out of combat - process pending operations
            CC:OnCombatEnd()
        elseif event == "PLAYER_REGEN_DISABLED" then
            -- Entered combat (no action needed)
        elseif event == "PLAYER_SPECIALIZATION_CHANGED" or event == "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" then
            -- Spec changed - check for profile switch
            CC:OnSpecChanged()
        elseif event == "TRAIT_CONFIG_UPDATED" or event == "TRAIT_CONFIG_CREATED" or event == "ACTIVE_COMBAT_CONFIG_CHANGED" then
            -- Loadout/talent changed - check for profile switch and reapply bindings (with debounce)
            if not InCombatLockdown() then
                -- Debounce: wait before checking to ensure API data is ready
                if CC.loadoutCheckTimer then
                    CC.loadoutCheckTimer:Cancel()
                end
                CC.loadoutCheckTimer = C_Timer.NewTimer(0.5, function()
                    CC.loadoutCheckTimer = nil
                    CC:CheckLoadoutProfileSwitch()
                    -- Reapply bindings to pick up spell overrides from talent changes
                    CC:ApplyBindings()
                    -- Also refresh UI in case talents changed
                    C_Timer.After(0.3, function()
                        CC:RefreshClickCastingUI()
                    end)
                end)
            else
                CC.pendingLoadoutCheck = true
                CC.needsBindingRefresh = true
            end
        elseif event == "PLAYER_LEVEL_UP" then
            -- Level up - may have learned new spells, reapply bindings
            if not InCombatLockdown() then
                CC:ApplyBindings()
                C_Timer.After(0.2, function()
                    CC:RefreshClickCastingUI()
                end)
            else
                CC.needsBindingRefresh = true
            end
        elseif event == "PLAYER_EQUIPMENT_CHANGED" then
            -- Equipment changed - refresh items tab if visible
            if CC.activeTab == "items" then
                CC:RefreshSpellGrid()
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            -- Initial load or reload
            C_Timer.After(0.5, function()
                -- Run one-time migration to convert bindings to root spells
                CC:MigrateBindingsToRootSpells()
                
                CC:RegisterAllFrames()
                -- Register Blizzard frames if any binding needs them
                if CC:AnyBindingNeedsBlizzardFrames() then
                    CC:RegisterBlizzardFrames()
                end
                -- Register all currently visible nameplates
                CC:RegisterAllNameplates()
                -- Apply hovercast bindings
                CC:ApplyGlobalBindings()
                
                -- Check for loadout-based profile on initial load
                C_Timer.After(1, function()
                    if not InCombatLockdown() then
                        CC:CheckLoadoutProfileSwitch()
                    end
                end)
            end)
        elseif event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" then
            -- Arena frames should now exist
            CC:OnArenaPrep()
        elseif event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
            -- Boss frames should now exist
            CC:OnBossEngage()
        elseif event == "NAME_PLATE_UNIT_ADDED" then
            -- A nameplate was added
            local unitToken = ...
            CC:OnNamePlateAdded(unitToken)
        elseif event == "NAME_PLATE_UNIT_REMOVED" then
            -- A nameplate was removed
            local unitToken = ...
            CC:OnNamePlateRemoved(unitToken)
        end
    end)
end

function CC:OnCombatEnd()
    local needsUIRefresh = false
    
    -- Process pending profile switch first
    if self.pendingProfileSwitch then
        local profileName = self.pendingProfileSwitch
        self.pendingProfileSwitch = nil
        if self:SetActiveProfile(profileName) then
            self:ApplyBindings()
            needsUIRefresh = true
        end
    end
    
    -- Check for pending loadout-based profile switch
    if self.pendingLoadoutCheck then
        self.pendingLoadoutCheck = nil
        self:CheckLoadoutProfileSwitch()
        needsUIRefresh = true
    end
    
    -- Process pending registrations
    if self.pendingRegistrations then
        for frame in pairs(self.pendingRegistrations) do
            self:RegisterFrame(frame)
        end
        self.pendingRegistrations = nil
    end
    
    -- Process pending unregistrations
    if self.pendingUnregistrations then
        for frame in pairs(self.pendingUnregistrations) do
            self:UnregisterFrame(frame)
        end
        self.pendingUnregistrations = nil
    end
    
    -- Full registration if needed
    if self.needsFullRegistration then
        self:RegisterAllFrames()
        self.needsFullRegistration = nil
    end
    
    -- Refresh bindings if needed
    if self.needsBindingRefresh then
        self:ApplyBindings()
        self.needsBindingRefresh = nil
        needsUIRefresh = true
    end
    
    -- Blizzard frame registration if needed
    if self.needsBlizzardRegistration then
        self:RegisterBlizzardFrames()
        self.needsBlizzardRegistration = nil
    end
    
    -- Blizzard frame unregistration if needed
    if self.needsBlizzardUnregistration then
        self:UnregisterBlizzardFrames()
        self.needsBlizzardUnregistration = nil
    end
    
    -- Refresh UI if needed (after a short delay for everything to settle)
    if needsUIRefresh then
        C_Timer.After(0.2, function()
            self:RefreshClickCastingUI()
        end)
    end
end

function CC:OnSpecChanged()
    -- Spec changed - check for profile switch based on new spec/loadout
    if not InCombatLockdown() then
        self:CheckLoadoutProfileSwitch()
        self:ApplyBindings()
        -- Refresh UI after a short delay to ensure spell data is ready
        C_Timer.After(0.3, function()
            self:RefreshClickCastingUI()
        end)
    else
        self.pendingLoadoutCheck = true
        self.needsBindingRefresh = true
    end
end

function CC:OnArenaPrep()
    if self.db.options.globalEnabled then
        -- Arena frames should now exist, try to register
        C_Timer.After(0.1, function()
            if not InCombatLockdown() then
                self:RegisterBlizzardFrames()
            else
                self.needsBlizzardRegistration = true
            end
        end)
    end
end

function CC:OnBossEngage()
    if self.db.options.globalEnabled then
        -- Boss frames should now exist
        C_Timer.After(0.1, function()
            if not InCombatLockdown() then
                self:RegisterBlizzardFrames()
            else
                self.needsBlizzardRegistration = true
            end
        end)
    end
end

-- ============================================================

-- NAMEPLATE HANDLING
-- ============================================================

-- Track registered nameplates
CC.registeredNameplates = CC.registeredNameplates or {}

-- Called when a nameplate is added
function CC:OnNamePlateAdded(unitToken)
    if not self.db or not self.db.enabled then return end
    if not self.db.options.globalEnabled then return end
    
    -- Get the nameplate frame
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitToken)
    if not nameplate then return end
    
    -- Debug output
    if self.db.options.debugBindings then
        local name = UnitName(unitToken) or "Unknown"
        print("|cff33cc66DF Nameplate:|r Added for " .. name .. " (" .. unitToken .. ")")
    end
    
    -- Get the actual clickable button from the nameplate
    -- Different nameplate addons structure this differently
    local clickableFrame = self:GetNameplateClickableFrame(nameplate, unitToken)
    
    if clickableFrame then
        -- Mark as a nameplate frame
        clickableFrame.dfIsNameplate = true
        clickableFrame.dfNameplateUnit = unitToken
        
        -- Track it
        self.registeredNameplates[unitToken] = clickableFrame
        
        -- Register for click-casting
        if not InCombatLockdown() then
            self:RegisterFrame(clickableFrame)
            
            if self.db.options.debugBindings then
                local frameName = clickableFrame:GetName() or "unnamed"
                print("|cff33cc66DF Nameplate:|r Registered frame: " .. frameName)
            end
        else
            -- Queue for after combat
            self.pendingRegistrations = self.pendingRegistrations or {}
            self.pendingRegistrations[clickableFrame] = true
        end
    else
        if self.db.options.debugBindings then
            print("|cffff6666DF Nameplate:|r Could not find clickable frame for " .. unitToken)
        end
    end
end

-- Called when a nameplate is removed
function CC:OnNamePlateRemoved(unitToken)
    local frame = self.registeredNameplates[unitToken]
    
    if frame then
        if self.db.options.debugBindings then
            print("|cff33cc66DF Nameplate:|r Removed for " .. unitToken)
        end
        
        -- Unregister from click-casting
        if not InCombatLockdown() then
            self:UnregisterFrame(frame)
        else
            -- Queue for after combat
            self.pendingUnregistrations = self.pendingUnregistrations or {}
            self.pendingUnregistrations[frame] = true
        end
        
        self.registeredNameplates[unitToken] = nil
    end
end

-- Get the clickable frame from a nameplate
-- This handles different nameplate addon structures
function CC:GetNameplateClickableFrame(nameplate, unitToken)
    if not nameplate then return nil end
    
    -- Debug helper
    local function debugFrame(label, frame)
        if self.db.options.debugBindings and frame then
            local name = frame:GetName() or "unnamed"
            local objType = frame:GetObjectType()
            local isButton = frame:IsObjectType("Button")
            local hasRegister = frame.RegisterForClicks ~= nil
            local unit = frame:GetAttribute("unit") or frame.unit
            print("  [Debug " .. label .. "] " .. name .. " (" .. objType .. ") isButton=" .. tostring(isButton) .. " hasRegister=" .. tostring(hasRegister) .. " unit=" .. tostring(unit))
        end
    end
    
    -- Try to find the UnitFrame child (Blizzard default structure)
    local unitFrame = nameplate.UnitFrame
    if unitFrame then
        debugFrame("UnitFrame", unitFrame)
        -- Check if it's a Button or has RegisterForClicks
        if unitFrame:IsObjectType("Button") or unitFrame.RegisterForClicks then
            local unit = unitFrame:GetAttribute("unit") or unitFrame.unit
            if unit then
                return unitFrame
            end
        end
    end
    
    -- Try the nameplate itself
    debugFrame("nameplate", nameplate)
    if nameplate:IsObjectType("Button") or nameplate.RegisterForClicks then
        local unit = nameplate:GetAttribute("unit")
        if unit then
            return nameplate
        end
    end
    
    -- Try common nameplate addon patterns
    -- Plater
    if nameplate.unitFrame then
        debugFrame("Plater unitFrame", nameplate.unitFrame)
        if nameplate.unitFrame:IsObjectType("Button") or nameplate.unitFrame.RegisterForClicks then
            return nameplate.unitFrame
        end
    end
    
    -- Plater alternate structure
    if nameplate.PlaterFrame then
        debugFrame("PlaterFrame", nameplate.PlaterFrame)
        return nameplate.PlaterFrame
    end
    
    -- KuiNameplates
    if nameplate.kui then
        local kuiFrame = nameplate.kui
        debugFrame("KuiFrame", kuiFrame)
        if kuiFrame.HealthBar then
            return kuiFrame
        end
    end
    
    -- TidyPlates / ThreatPlates
    if nameplate.TPFrame then
        debugFrame("TPFrame", nameplate.TPFrame)
        return nameplate.TPFrame
    end
    
    -- NeatPlates
    if nameplate.carrier then
        debugFrame("NeatPlates carrier", nameplate.carrier)
        return nameplate.carrier
    end
    
    -- Fallback: search all children for a Button with unit attribute
    for _, child in ipairs({nameplate:GetChildren()}) do
        if child:IsObjectType("Button") then
            debugFrame("Child Button", child)
            local childUnit = child:GetAttribute("unit") or child.unit
            if childUnit then
                return child
            end
        end
    end
    
    -- Last resort: search for any frame with RegisterForClicks
    for _, child in ipairs({nameplate:GetChildren()}) do
        if child.RegisterForClicks then
            debugFrame("Child with RegisterForClicks", child)
            local childUnit = child:GetAttribute("unit") or child.unit
            if childUnit or not InCombatLockdown() then
                -- Set unit if missing
                if not child:GetAttribute("unit") and not InCombatLockdown() then
                    child:SetAttribute("unit", unitToken)
                end
                return child
            end
        end
    end
    
    -- Very last resort: if the nameplate's UnitFrame exists but isn't a Button,
    -- we can still try to use it with SecureActionButton behavior
    if unitFrame and not InCombatLockdown() then
        debugFrame("Fallback UnitFrame", unitFrame)
        -- Try to set it up for click-casting
        if not unitFrame:GetAttribute("unit") then
            unitFrame:SetAttribute("unit", unitToken)
        end
        return unitFrame
    end
    
    if self.db.options.debugBindings then
        print("  [Debug] No suitable clickable frame found for nameplate")
    end
    
    return nil
end

-- Register all currently visible nameplates
function CC:RegisterAllNameplates()
    if not self.db or not self.db.enabled then return end
    if not self.db.options.globalEnabled then return end
    
    -- Get all visible nameplates
    local nameplates = C_NamePlate.GetNamePlates()
    
    if self.db.options.debugBindings then
        print("|cff33cc66DF Nameplate:|r Registering " .. #nameplates .. " visible nameplates")
    end
    
    for _, nameplate in ipairs(nameplates) do
        local unitToken = nameplate.namePlateUnitToken
        if unitToken then
            self:OnNamePlateAdded(unitToken)
        end
    end
end

-- ============================================================
