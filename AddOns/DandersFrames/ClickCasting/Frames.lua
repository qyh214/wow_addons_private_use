local addonName, DF = ...

-- Get module namespace
local CC = DF.ClickCast

-- Fallback for issecretvalue (may not exist in all WoW versions)
-- If it doesn't exist, create a function that returns false
local issecretvalue = issecretvalue or function(val) return false end

-- Local aliases for shared constants (defined in Constants.lua)
local DB_VERSION = CC.DB_VERSION
local PROFILE_TEMPLATE = CC.PROFILE_TEMPLATE
local GLOBAL_SETTINGS_TEMPLATE = CC.GLOBAL_SETTINGS_TEMPLATE
local DEFAULT_BINDING_COMBAT = CC.DEFAULT_BINDING_COMBAT
local BLIZZARD_FRAMES = CC.BLIZZARD_FRAMES
local BLIZZARD_BOSS_FRAMES = CC.BLIZZARD_BOSS_FRAMES
local BLIZZARD_ARENA_FRAMES = CC.BLIZZARD_ARENA_FRAMES

-- Local aliases for helper functions (defined in Profiles.lua)
local GetPlayerClass = function() return CC.GetPlayerClass() end
local GetDefaultProfileName = function() return CC.GetDefaultProfileName() end

-- INITIALIZATION
-- ============================================================

function CC:Initialize()
    -- Check if we're in combat - secure frames can't be created during combat
    if InCombatLockdown() then
        print("|cffff9900DandersFrames Click Casting:|r Loaded during combat - click casting will initialize when combat ends.")
        -- Still initialize saved variables so settings are accessible
        self:InitializeSavedVariables()
        -- Register for combat end to retry
        local retryFrame = CreateFrame("Frame")
        retryFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        retryFrame:SetScript("OnEvent", function(f)
            f:UnregisterAllEvents()
            -- Retry initialization after combat
            C_Timer.After(0.5, function()
                if not self.secureFramesInitialized then
                    print("|cff33cc33DandersFrames:|r Combat ended - initializing click casting...")
                    self:InitializeSecureFrames()
                end
            end)
        end)
        return
    end
    
    self:InitializeSavedVariables()
    self:InitializeSecureFrames()
end

-- Separate saved variables initialization (safe to call in combat)
function CC:InitializeSavedVariables()
    if self.savedVariablesInitialized then return end
    
    -- Initialize saved variables if needed
    if not DandersFramesClickCastingDB then
        DandersFramesClickCastingDB = {
            dbVersion = DB_VERSION,
            global = CopyTable(GLOBAL_SETTINGS_TEMPLATE),
            classes = {},
        }
    end
    
    self.db = DandersFramesClickCastingDB
    
    -- Ensure global settings exist
    if not self.db.global then
        self.db.global = CopyTable(GLOBAL_SETTINGS_TEMPLATE)
    end
    
    -- Ensure new global options exist (migration for existing users)
    if self.db.global.disableWhileMounted == nil then
        self.db.global.disableWhileMounted = false
    end
    
    -- Ensure classes table exists
    if not self.db.classes then
        self.db.classes = {}
    end
    
    -- ============================================================
    -- MIGRATION: Old flat DB to new profile-based structure
    -- ============================================================
    if not self.db.dbVersion or self.db.dbVersion < DB_VERSION then
        -- Check if we have old-style data to migrate
        if self.db.bindings or self.db.customMacros or self.db.options then
            print("|cff33cc33DandersFrames:|r Migrating to new profile system...")
            
            -- Create a Default profile with the existing data
            local class = GetPlayerClass()
            local defaultName = GetDefaultProfileName()
            if not self.db.classes[class] then
                self.db.classes[class] = {
                    profiles = {},
                    loadoutAssignments = {},
                    activeProfile = defaultName,
                }
            end
            
            -- Move existing data into the Default profile
            local defaultProfile = CopyTable(PROFILE_TEMPLATE)
            
            -- Migrate bindings
            if self.db.bindings then
                defaultProfile.bindings = CopyTable(self.db.bindings)
            end
            
            -- Migrate custom macros
            if self.db.customMacros then
                defaultProfile.customMacros = CopyTable(self.db.customMacros)
            end
            
            -- Migrate options
            if self.db.options then
                for k, v in pairs(self.db.options) do
                    if PROFILE_TEMPLATE.options[k] ~= nil or k == "enabled" or k == "castOnDown" or 
                       k == "viewLayout" or k == "viewSort" or k == "quickBindEnabled" or k == "smartResurrection" then
                        defaultProfile.options[k] = v
                    end
                end
            end
            
            -- Migrate global settings
            if self.db.options and self.db.options.debugBindings then
                self.db.global.debugBindings = self.db.options.debugBindings
            end
            
            -- Migrate enabled state
            if self.db.enabled ~= nil then
                defaultProfile.options.enabled = self.db.enabled
            end
            
            -- Save the migrated profile with class-specific name
            self.db.classes[class].profiles[defaultName] = defaultProfile
            
            -- Clean up old top-level data
            self.db.bindings = nil
            self.db.customMacros = nil
            self.db.options = nil
            self.db.enabled = nil
            
            print("|cff33cc33DandersFrames:|r Migration complete. Your bindings are now in the '" .. defaultName .. "' profile.")
        end
        
        self.db.dbVersion = DB_VERSION
    end
    
    -- ============================================================
    -- MIGRATION: Rename old "Default" profile to class-specific name
    -- ============================================================
    local classData = self:GetClassData()
    local defaultName = GetDefaultProfileName()
    
    -- Check if old "Default" profile exists but new class-specific default doesn't
    if classData.profiles["Default"] and not classData.profiles[defaultName] then
        -- Rename "Default" to class-specific name
        classData.profiles[defaultName] = classData.profiles["Default"]
        classData.profiles["Default"] = nil
        
        -- Update active profile if it was "Default"
        if classData.activeProfile == "Default" then
            classData.activeProfile = defaultName
        end
        
        -- Update loadout assignments
        if classData.loadoutAssignments then
            for specIndex, loadouts in pairs(classData.loadoutAssignments) do
                for loadoutID, assignedProfile in pairs(loadouts) do
                    if assignedProfile == "Default" then
                        loadouts[loadoutID] = defaultName
                    end
                end
            end
        end
        
        print("|cff33cc33DandersFrames:|r Renamed 'Default' profile to '" .. defaultName .. "'")
    end
    
    -- ============================================================
    -- Set up profile references
    -- ============================================================
    
    -- Ensure class-specific default profile exists
    if not classData.profiles[defaultName] then
        classData.profiles[defaultName] = self:CreateEmptyProfile()
    end
    
    -- Ensure active profile is valid
    if not classData.profiles[classData.activeProfile] then
        classData.activeProfile = defaultName
    end
    
    -- Get active profile
    self.profile = classData.profiles[classData.activeProfile]
    
    -- Set up legacy references for compatibility (point to profile data)
    self.db.bindings = self.profile.bindings
    self.db.customMacros = self.profile.customMacros
    self.db.options = self.profile.options
    
    -- Ensure all default options exist in active profile
    if self.profile.options.enabled == nil then self.profile.options.enabled = false end  -- Disabled by default, opt-in
    if self.profile.options.castOnDown == nil then self.profile.options.castOnDown = true end
    if self.profile.options.quickBindEnabled == nil then self.profile.options.quickBindEnabled = true end
    if not self.profile.options.smartResurrection then self.profile.options.smartResurrection = "disabled" end
    if not self.profile.options.viewLayout then self.profile.options.viewLayout = "grid" end
    if not self.profile.options.viewSort then self.profile.options.viewSort = "sectioned" end
    
    -- Sync enabled state to legacy location
    self.db.enabled = self.profile.options.enabled
    
    -- Ensure consumables list exists
    if not self.profile.consumables then
        self.profile.consumables = {}
    end
    
    -- ============================================================
    -- Migrate bindings within the profile (same as before)
    -- ============================================================
    for _, binding in ipairs(self.profile.bindings) do
        -- Migrate old scope to new frames/fallback structure
        if binding.scope and not binding.frames then
            local oldScope = binding.scope
            
            if oldScope == "hovercast" then oldScope = "onhover" end
            if oldScope == "global" then oldScope = "targetcast" end
            
            if oldScope == "unitframes" then
                binding.frames = { dandersFrames = true, otherFrames = false }
                binding.fallback = { mouseover = false, target = false, selfCast = false }
            elseif oldScope == "blizzard" then
                binding.frames = { dandersFrames = true, otherFrames = true }
                binding.fallback = { mouseover = false, target = false, selfCast = false }
            elseif oldScope == "onhover" then
                binding.frames = { dandersFrames = true, otherFrames = true }
                binding.fallback = { mouseover = true, target = false, selfCast = false }
            elseif oldScope == "targetcast" then
                binding.frames = { dandersFrames = false, otherFrames = false }
                binding.fallback = { mouseover = false, target = true, selfCast = false }
            else
                binding.frames = { dandersFrames = true, otherFrames = true }
                binding.fallback = { mouseover = false, target = false, selfCast = false }
            end
            binding.scope = nil
        end
        
        -- Ensure frames and fallback exist
        if not binding.frames then
            binding.frames = { dandersFrames = true, otherFrames = true }
        end
        if not binding.fallback then
            binding.fallback = { mouseover = false, target = false, selfCast = false }
        end
        
        -- Migrate old loadCombat to new combat field
        if binding.loadCombat and not binding.combat then
            if binding.loadCombat == "combat" then
                binding.combat = "incombat"
            elseif binding.loadCombat == "nocombat" then
                binding.combat = "outofcombat"
            else
                binding.combat = "always"
            end
            binding.loadCombat = nil
        end
        
        if not binding.combat then
            binding.combat = DEFAULT_BINDING_COMBAT
        end
    end
    
    -- Add default bindings on first load (if no bindings exist)
    if #self.profile.bindings == 0 then
        table.insert(self.profile.bindings, {
            enabled = true,
            bindType = "mouse",
            button = "LeftButton",
            modifiers = "",
            actionType = "target",
            combat = "always",
            frames = { dandersFrames = true, otherFrames = true },
            fallback = { mouseover = true, target = false, selfCast = false },
        })
        table.insert(self.profile.bindings, {
            enabled = true,
            bindType = "mouse",
            button = "RightButton",
            modifiers = "",
            actionType = "menu",
            combat = "always",
            frames = { dandersFrames = true, otherFrames = true },
            fallback = { mouseover = true, target = false, selfCast = false },
        })
    end
    
    self.savedVariablesInitialized = true
end

-- Secure frame initialization (must be called out of combat)
function CC:InitializeSecureFrames()
    if self.secureFramesInitialized then return end
    
    if InCombatLockdown() then
        -- Queue for after combat
        local retryFrame = CreateFrame("Frame")
        retryFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        retryFrame:SetScript("OnEvent", function(f)
            f:UnregisterAllEvents()
            C_Timer.After(0.5, function()
                if not self.secureFramesInitialized then
                    self:InitializeSecureFrames()
                end
            end)
        end)
        return
    end
    
    -- Create the secure header frame
    self:CreateClickCastHeader()
    
    -- Create the hovercast button for global bindings (Clique-style)
    self:CreateHovercastButton()
    
    -- Set up frame ref so secure snippets can access the hovercast button
    if self.header and self.header.SetFrameRef and self.hovercastButton then
        self.header:SetFrameRef("hovercastButton", self.hovercastButton)
    end
    
    -- Set up ClickCastFrames global for addon compatibility
    self:SetupClickCastFramesGlobal()
    
    -- Check for conflicting addons
    self:CheckForConflictingAddons()
    
    -- Show conflict popup on load if enabled with conflicts
    if self.db.enabled and self.hasConflictingAddons and self.conflictingAddons then
        -- Delay slightly to ensure UI is ready
        C_Timer.After(1.5, function()
            if CC.db.enabled and CC.hasConflictingAddons then
                CC:ShowClickCastConflictPopup(CC.conflictingAddons, CC.enableCb)
            end
        end)
    end
    
    -- Disable Blizzard's built-in click casting when our click casting is enabled
    self:DisableBlizzardClickCasting()
    
    -- Register for spec change events
    self:RegisterEvents()
    
    -- Set up hooks for dynamic Blizzard frames (boss/arena)
    self:SetupDynamicFrameHooks()
    
    -- Mark as initialized BEFORE processing pending registrations
    self.secureFramesInitialized = true
    
    -- Process any pending frame registrations (from reload in combat)
    if self.pendingRegistrations then
        for frame in pairs(self.pendingRegistrations) do
            self:RegisterFrame(frame)
        end
        self.pendingRegistrations = nil
    end
    
    -- Apply bindings
    self:ApplyBindings()
    
    -- Register Blizzard frames if any binding needs them (delayed to ensure frames exist)
    C_Timer.After(0.5, function()
        if self:AnyBindingNeedsBlizzardFrames() then
            self:RegisterBlizzardFrames()
        end
        
        -- Check if we should auto-switch profile based on current loadout
        -- (delayed to ensure talent data is available)
        C_Timer.After(0.5, function()
            self:CheckLoadoutProfileSwitch()
        end)
    end)
end

-- ============================================================

-- SECURE HEADER FRAME
-- ============================================================

function CC:CreateClickCastHeader()
    -- The ClickCastHeader is a secure frame that wraps unit frame OnEnter/OnLeave
    -- This is the approach used by Cell and Clique for in-combat keyboard bindings
    
    if self.header then return end
    
    -- Don't create during combat
    if InCombatLockdown() then
        C_Timer.After(1, function()
            if not InCombatLockdown() then
                self:CreateClickCastHeader()
            end
        end)
        return
    end
    
    -- Create the header frame with SecureHandlerStateTemplate for WrapScript capability
    local header
    
    -- Try creating with the template
    local success = pcall(function()
        header = CreateFrame("Frame", "DandersFramesClickCastHeader", UIParent, "SecureHandlerStateTemplate")
    end)
    
    if not success or not header then
        -- Fallback: try SecureHandlerBaseTemplate
        success = pcall(function()
            header = CreateFrame("Frame", "DandersFramesClickCastHeader", UIParent, "SecureHandlerBaseTemplate")
        end)
    end
    
    if not success or not header then
        -- Last resort: plain frame (keyboard bindings won't work in combat)
        print("|cffff9900DandersFrames:|r Warning: Could not create secure header, keyboard bindings limited")
        header = CreateFrame("Frame", "DandersFramesClickCastHeader", UIParent)
    end
    
    self.header = header
    self.header:SetSize(1, 1)
    self.header:Hide()
    
    -- Set the enabled attribute (checked by OnEnter snippets to allow Clique/Clicked when disabled)
    self.header:SetAttribute("dfClickCastEnabled", self.db and self.db.enabled or false)
    
    -- Initialize secure environment variables
    -- mouseoverbutton tracks the currently hovered frame (Cell's pattern)
    if self.header.Execute then
        pcall(function()
            self.header:Execute([[
                mouseoverbutton = nil
            ]])
        end)
    end
    
    -- === MOUSEOVERSTATE DRIVER ===
    -- Clears bindings when there's no mouseover unit (e.g., a Blizzard panel
    -- opens over the frame, stealing focus without firing WrapScript OnLeave).
    --
    -- Guard uses IsUnderMouse() now that Blizzard fixed the API bug where it
    -- incorrectly returned false for parent frames that were actually under
    -- the mouse. That bug was the root cause of the false-clears we worked
    -- around with GetMousePosition() — unit buttons are parents with child
    -- regions (health bar, name text, icons), so when the cursor was over a
    -- child texture, IsUnderMouse() on the parent returned nil even though
    -- the mouse was clearly over the frame.
    self.header:SetAttribute("_onstate-mouseoverstate", [[
        if newstate == "false" and mouseoverbutton then
            local underMouse = mouseoverbutton:IsUnderMouse()

            -- Store diagnostics
            mouseoverbutton:SetAttribute("dfStateDriverCount", (mouseoverbutton:GetAttribute("dfStateDriverCount") or 0) + 1)
            mouseoverbutton:SetAttribute("dfStateDriverUnderMouse", tostring(underMouse))

            -- If mouse is no longer over the frame, clear bindings
            if not underMouse then
                mouseoverbutton:SetAttribute("dfClearedBy", "statedriver")
                mouseoverbutton:ClearBindings()
                mouseoverbutton:SetAttribute("dfBindingsActive", nil)
                mouseoverbutton:SetAttribute("dfIsSecureMouseover", nil)
                mouseoverbutton = nil
            end
        end
    ]])
    RegisterStateDriver(self.header, "mouseoverstate", "[@mouseover, exists] true; false")

    --[[ FALLBACK: GetMousePosition() variant — keep around in case Blizzard's
         IsUnderMouse() fix regresses. Swap the SetAttribute call above for this
         one and update the OnEnter / diagnostic logs accordingly.

    self.header:SetAttribute("_onstate-mouseoverstate", [=[
        if newstate == "false" and mouseoverbutton then
            local x, y = mouseoverbutton:GetMousePosition()

            -- Store diagnostics
            mouseoverbutton:SetAttribute("dfStateDriverCount", (mouseoverbutton:GetAttribute("dfStateDriverCount") or 0) + 1)
            mouseoverbutton:SetAttribute("dfSDMouseX", x)
            mouseoverbutton:SetAttribute("dfSDMouseY", y)

            -- If mouse is outside frame bounds (or position unavailable), clear bindings
            if not x or x < 0 or x > 1 or y < 0 or y > 1 then
                mouseoverbutton:SetAttribute("dfClearedBy", "statedriver")
                mouseoverbutton:ClearBindings()
                mouseoverbutton:SetAttribute("dfBindingsActive", nil)
                mouseoverbutton:SetAttribute("dfIsSecureMouseover", nil)
                mouseoverbutton = nil
            end
        end
    ]=])
    --]]
    
    -- Track registered frames
    self.registeredFrames = {}
    
    -- Store reference to module in header for secure snippets
    self.header.module = self
end

-- ============================================================

-- ADDON CONFLICT DETECTION
-- ============================================================

function CC:CheckForConflictingAddons()
    local conflicts = {}
    
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        if C_AddOns.IsAddOnLoaded("Clique") then
            table.insert(conflicts, "Clique")
        end
        if C_AddOns.IsAddOnLoaded("Clicked") then
            table.insert(conflicts, "Clicked")
        end
    elseif IsAddOnLoaded then
        if IsAddOnLoaded("Clique") then
            table.insert(conflicts, "Clique")
        end
        if IsAddOnLoaded("Clicked") then
            table.insert(conflicts, "Clicked")
        end
    end
    
    if #conflicts > 0 then
        -- Don't print warning - let the UI popup handle it
        self.hasConflictingAddons = true
        self.conflictingAddons = conflicts
        return true
    end
    
    self.hasConflictingAddons = false
    self.conflictingAddons = nil
    return false
end

-- ============================================================

-- DISABLE BLIZZARD CLICK CASTING
-- ============================================================

function CC:DisableBlizzardClickCasting()
    if not self.db.enabled then return end
    
    -- Blizzard's click casting is set via SetUnitFrameClickCastConfig
    -- and creates overlay frames. We need to clear/hide them.
    -- Only clear from frames that the user has configured bindings for.
    
    -- Hook into Blizzard's click cast system to prevent conflicts
    if not self.blizzardClickCastDisabled then
        -- Reset Blizzard's click-casting profile on first run (if user chose to clear)
        -- This completely removes any Blizzard click-cast bindings
        if self.db.clearBlizzardOnEnable and C_ClickBindings and C_ClickBindings.ResetCurrentProfile then
            C_ClickBindings.ResetCurrentProfile()
        end
        
        -- Clear any existing Blizzard click cast config on our frames
        if SetUnitFrameClickCastConfig then
            -- Hook to prevent Blizzard from setting click casts on frames we manage
            hooksecurefunc("SetUnitFrameClickCastConfig", function(frame, ...)
                if CC.db and CC.db.enabled and frame then
                    -- Check if this is a frame we've registered AND if we should clear it
                    if CC.registeredFrames and CC.registeredFrames[frame] then
                        if CC:ShouldClearBlizzardFromFrame(frame) then
                            -- Clear immediately and re-apply our bindings
                            CC:ClearBlizzardClickCastFromFrame(frame)
                            CC:ApplyBindingsToFrameUnified(frame)
                            -- And again on next frame in case Blizzard does something after
                            C_Timer.After(0, function()
                                if not InCombatLockdown() then
                                    CC:ClearBlizzardClickCastFromFrame(frame)
                                    CC:ApplyBindingsToFrameUnified(frame)
                                end
                            end)
                        end
                    end
                end
            end)
        end
        
        -- Also hook UnitFrame_OnEnter to catch any click-cast setup on hover
        if UnitFrame_OnEnter then
            hooksecurefunc("UnitFrame_OnEnter", function(frame)
                if CC.db and CC.db.enabled and frame then
                    if CC.registeredFrames and CC.registeredFrames[frame] then
                        if CC:ShouldClearBlizzardFromFrame(frame) then
                            CC:ClearBlizzardClickCastFromFrame(frame)
                            CC:ApplyBindingsToFrameUnified(frame)
                        end
                    end
                end
            end)
        end
        
        -- Hook ClickBindingFrame if it exists (Blizzard's click-cast overlay system)
        if ClickBindingFrame and ClickBindingFrame.RegisterForClicks then
            -- Prevent ClickBindingFrame from registering clicks when over our frames
            hooksecurefunc(ClickBindingFrame, "Show", function(self)
                if CC.db and CC.db.enabled then
                    local mouseoverFrame = GetMouseFocus()
                    if mouseoverFrame and CC.registeredFrames and CC.registeredFrames[mouseoverFrame] then
                        if CC:ShouldClearBlizzardFromFrame(mouseoverFrame) then
                            self:Hide()
                        end
                    end
                end
            end)
        end
        
        self.blizzardClickCastDisabled = true
    end
    
    -- Clear Blizzard click cast from registered frames (only those that need it)
    if self.registeredFrames then
        for frame in pairs(self.registeredFrames) do
            if self:ShouldClearBlizzardFromFrame(frame) then
                self:ClearBlizzardClickCastFromFrame(frame)
            end
        end
    end
    
    -- Re-apply our bindings to ensure they take precedence
    if self.secureFramesInitialized then
        C_Timer.After(0.1, function()
            if not InCombatLockdown() then
                CC:ApplyBindings()
            end
        end)
    end
end

-- Clear Blizzard's click cast overlay/settings from a specific frame
function CC:ClearBlizzardClickCastFromFrame(frame)
    if not frame then return end
    if InCombatLockdown() then return end
    
    -- Clear Blizzard's click-cast attributes
    -- Use empty string "" not nil - SecureUnitButtonTemplate defaults kick in with nil
    -- Setting to "" overrides the template defaults with "do nothing"
    frame:SetAttribute("type1", "")
    frame:SetAttribute("type2", "")
    frame:SetAttribute("unit1", nil)
    frame:SetAttribute("unit2", nil)
    
    -- Also clear common modifiers with empty string
    local modifiers = {"shift-", "ctrl-", "alt-", "shift-ctrl-", "shift-alt-", "ctrl-alt-", "shift-ctrl-alt-"}
    for _, mod in ipairs(modifiers) do
        frame:SetAttribute(mod .. "type1", "")
        frame:SetAttribute(mod .. "type2", "")
    end
    
    -- Aggressively disable click cast overlay frames
    -- These sit on top of unit frames and intercept clicks
    local function DisableOverlayPermanently(overlay)
        if not overlay then return end
        
        overlay:Hide()
        overlay:EnableMouse(false)
        overlay:SetAlpha(0)
        
        -- Hook Show to prevent Blizzard from re-showing
        if not overlay.dfShowHooked then
            overlay.dfShowHooked = true
            hooksecurefunc(overlay, "Show", function(self)
                if CC.db and CC.db.enabled then
                    self:Hide()
                end
            end)
        end
        
        -- Hook EnableMouse to prevent Blizzard from re-enabling
        if not overlay.dfEnableMouseHooked then
            overlay.dfEnableMouseHooked = true
            hooksecurefunc(overlay, "EnableMouse", function(self, enable)
                if CC.db and CC.db.enabled and enable then
                    self:EnableMouse(false)
                end
            end)
        end
    end
    
    -- Disable clickCastFrame overlay
    if frame.clickCastFrame then
        DisableOverlayPermanently(frame.clickCastFrame)
    end
    
    -- Disable ClickCastOverlay
    if frame.ClickCastOverlay then
        DisableOverlayPermanently(frame.ClickCastOverlay)
    end
    
    -- Check child frames for click cast overlays
    local children = {frame:GetChildren()}
    for _, child in ipairs(children) do
        local name = child:GetName()
        if name and (name:find("ClickCast") or name:find("clickcast")) then
            DisableOverlayPermanently(child)
        end
    end
end

-- Refresh Blizzard click-cast clearing based on current binding settings
-- Called when bindings are added/updated/removed to ensure correct frames are cleared
function CC:RefreshBlizzardClickCastClearing()
    if not self.db.enabled then return end
    if InCombatLockdown() then return end
    
    -- Clear Blizzard click cast from registered frames that need it
    if self.registeredFrames then
        for frame in pairs(self.registeredFrames) do
            if self:ShouldClearBlizzardFromFrame(frame) then
                self:ClearBlizzardClickCastFromFrame(frame)
            end
        end
    end
end

-- ============================================================

-- CLICKCASTFRAMES GLOBAL TABLE
-- ============================================================

function CC:SetupClickCastFramesGlobal()
    -- If our click casting is disabled, DON'T set up our metatable
    -- This allows Clique/Clicked to set up their own metatable and work normally
    if not self.db or not self.db.enabled then
        -- Just ensure ClickCastFrames exists as a plain table
        if not ClickCastFrames then
            ClickCastFrames = {}
        end
        -- Don't interfere - Clique/Clicked can set up their own metatable
        return
    end
    
    -- Save any existing ClickCastFrames entries BEFORE we replace with metatable
    local existingFrames = {}
    if ClickCastFrames then
        for frame, enabled in pairs(ClickCastFrames) do
            if enabled and type(frame) == "table" then
                existingFrames[frame] = true
            end
        end
    end
    
    -- Create new metatable that auto-registers/unregisters frames
    -- This only runs when our click casting is ENABLED
    ClickCastFrames = setmetatable({}, {
        __newindex = function(t, frame, enabled)
            -- Always store the value in the table
            rawset(t, frame, enabled)
            
            -- Process registration since our click casting is enabled
            if CC.db and CC.db.enabled then
                if enabled == nil or enabled == false then
                    CC:UnregisterFrame(frame)
                else
                    CC:RegisterFrame(frame)
                end
            end
        end
    })
    
    -- Re-register any frames that were already in ClickCastFrames
    for frame, enabled in pairs(existingFrames) do
        if enabled then
            rawset(ClickCastFrames, frame, true)
            CC:RegisterFrame(frame)
        end
    end
    
    -- Global reference for addon compatibility (like Clique)
    ClickCastHeader = self.header
    
    -- Schedule a delayed scan for third-party frames that might have been created
    -- This catches frames from addons that loaded before us or used different registration methods
    C_Timer.After(1, function()
        CC:ScanForThirdPartyFrames()
    end)
    
    -- Also scan when player enters world (in case frames are created late)
    C_Timer.After(3, function()
        CC:ScanForThirdPartyFrames()
    end)
end

-- Scan for known third-party unit frame addons and register their frames
function CC:ScanForThirdPartyFrames()
    if InCombatLockdown() then
        C_Timer.After(1, function() CC:ScanForThirdPartyFrames() end)
        return
    end
    
    -- Known frame name patterns from popular unit frame addons
    local knownFramePatterns = {
        -- Unhalted Unit Frames
        "UUF_Player", "UUF_Target", "UUF_TargetTarget", "UUF_Pet", "UUF_Focus",
        "UUF_Boss1", "UUF_Boss2", "UUF_Boss3", "UUF_Boss4", "UUF_Boss5",
        
        -- NephUI (common patterns)
        "NephUI_Player", "NephUI_Target", "NephilemUI_Player", "NephilemUI_Target",
        
        -- SUF (Shadowed Unit Frames)
        "SUFUnitplayer", "SUFUnittarget", "SUFUnitfocus", "SUFUnitpet",
        "SUFUnittargettarget",
        
        -- Pitbull
        "PitBull4_Frames_Player", "PitBull4_Frames_Target",
        
        -- Z-Perl / X-Perl
        "XPerl_Player", "XPerl_Target", "XPerl_Focus",
        
        -- ElvUI (oUF based)
        "ElvUF_Player", "ElvUF_Target", "ElvUF_Focus", "ElvUF_Pet",
        "ElvUF_TargetTarget",
        
        -- Generic oUF patterns
        "oUF_Player", "oUF_Target", "oUF_Focus", "oUF_Pet",
    }
    
    local registered = 0
    for _, frameName in ipairs(knownFramePatterns) do
        local frame = _G[frameName]
        if frame and type(frame) == "table" and frame.GetAttribute then
            -- Check if it's a valid unit frame with a unit attribute
            local unit = frame:GetAttribute("unit")
            if unit and not self.registeredFrames[frame] then
                -- Check if it's a protected secure frame
                local isProtected = frame.IsProtected and frame:IsProtected()
                -- Bail if secret value (can't do boolean operations on it)
                if issecretvalue(isProtected) then
                    -- Skip this frame
                elseif isProtected then
                    self:RegisterFrame(frame)
                    rawset(ClickCastFrames, frame, true)
                    registered = registered + 1
                end
            end
        end
    end
    
    -- Also scan ClickCastFrames in case something was added via rawset
    if ClickCastFrames then
        for frame, enabled in pairs(ClickCastFrames) do
            if enabled and type(frame) == "table" and not self.registeredFrames[frame] then
                self:RegisterFrame(frame)
                registered = registered + 1
            end
        end
    end
    
    if registered > 0 and self.db and self.db.options and self.db.options.debugBindings then
        print("|cff00ff00DandersFrames:|r Registered " .. registered .. " third-party frames")
    end
end

-- ============================================================

-- BLIZZARD FRAME REGISTRATION (Global Click-Casting)
-- ============================================================

-- Check if any binding requires Blizzard frames (now "Other Frames")
function CC:AnyBindingNeedsBlizzardFrames()
    for _, binding in ipairs(self.db.bindings) do
        if binding.enabled and self:ShouldBindingLoad(binding) then
            -- Check if binding applies to other frames
            local frames = binding.frames or { dandersFrames = true, otherFrames = true }
            if frames.otherFrames then
                return true
            end
            
            -- Check if binding has any fallback options (needs global keybinds)
            local fallback = binding.fallback or {}
            if fallback.mouseover or fallback.target or fallback.selfCast then
                return true
            end
        end
    end
    return false
end

-- Check if any binding applies to DandersFrames
function CC:AnyBindingNeedsDandersFrames()
    for _, binding in ipairs(self.db.bindings) do
        if binding.enabled and self:ShouldBindingLoad(binding) then
            local frames = binding.frames or { dandersFrames = true, otherFrames = true }
            if frames.dandersFrames then
                return true
            end
        end
    end
    return false
end

-- Check if any binding applies to Other Frames (non-DandersFrames)
function CC:AnyBindingNeedsOtherFrames()
    for _, binding in ipairs(self.db.bindings) do
        if binding.enabled and self:ShouldBindingLoad(binding) then
            local frames = binding.frames or { dandersFrames = true, otherFrames = true }
            if frames.otherFrames then
                return true
            end
        end
    end
    return false
end

-- Check if we should clear Blizzard click-casting from a specific frame
-- When click-casting is enabled:
--   - Always clear from DandersFrames (our frames should be controlled by us)
--   - Only clear from Other Frames if user has bindings configured for them
function CC:ShouldClearBlizzardFromFrame(frame)
    if not frame then return false end
    if not self.db or not self.db.enabled then return false end
    
    local isDandersFrame = frame.dfIsDandersFrame == true
    
    if isDandersFrame then
        -- DandersFrames never have Blizzard click-casting applied to them.
        -- Our own ClearBindingsFromFrame (inside ApplyBindingsToFrameUnified)
        -- already handles full cleanup. Clearing type1 here would race with
        -- the batch processing that re-applies it, leaving frames with type1=""
        -- if combat starts before the batch reaches them.
        return false
    else
        -- Only clear from Other frames if user has bindings that apply to them
        return self:AnyBindingNeedsOtherFrames()
    end
end

-- ============================================================
-- BLIZZARD FRAME HEALTH/MANA BAR FIX
-- ============================================================
-- Blizzard frames have child frames (HealthBar, ManaBar) that intercept mouse events.
-- This prevents click-casting from working when hovering over those bars.
-- Solution: Use SetPropagateMouseMotion(true) to pass mouse events to parent frame.

-- Recursively search a frame's table for HealthBar and ManaBar keys
function CC:FindHealthManaBars(obj)
    local checked = {}
    local health = nil
    local mana = nil
    
    local function traverse(current)
        if type(current) ~= "table" then return end
        if checked[current] then return end
        
        checked[current] = true
        if not pcall(next, current) then return end
        for key, value in pairs(current) do
            if key == "HealthBar" or key == "healthBar" then
                health = value
            elseif key == "ManaBar" or key == "manaBar" or key == "PowerBar" or key == "powerBar" then
                mana = value
            elseif type(value) == "table" and key ~= "__index" then
                traverse(value)
            end
        end
    end
    
    traverse(obj)
    return health, mana
end

-- Fix a Blizzard frame so clicks on health/mana bars propagate to the parent
function CC:FixBlizzardFrameStatusBars(frame)
    if not frame then return end
    
    local health, mana = self:FindHealthManaBars(frame)
    
    if health then
        if health.SetPropagateMouseMotion then health:SetPropagateMouseMotion(true) end
        if health.SetPropagateMouseClicks then health:SetPropagateMouseClicks(true) end
    end
    if mana then
        if mana.SetPropagateMouseMotion then mana:SetPropagateMouseMotion(true) end
        if mana.SetPropagateMouseClicks then mana:SetPropagateMouseClicks(true) end
    end
    
    -- Also fix any child frames that might intercept mouse events/clicks
    -- This handles cases like PetFrame where anonymous children sit on top and eat clicks
    self:PropagateMouseOnChildren(frame)
end

-- Recursively set mouse propagation on all children of Blizzard unit frames
-- so that clicks pass through child overlays to reach the parent secure button.
-- This is only called on Blizzard unit frames (PlayerFrame, PetFrame, etc.)
-- so we can safely propagate on all non-forbidden children unconditionally —
-- none of the children (health bars, mana bars, portraits, anonymous overlays)
-- need to handle clicks independently.
function CC:PropagateMouseOnChildren(frame)
    if not frame or not frame.GetChildren then return end
    
    local children = {frame:GetChildren()}
    for _, child in ipairs(children) do
        -- Skip forbidden frames — these can't be touched at all
        if child.IsForbidden and child:IsForbidden() then
            -- Skip
        else
            if child.SetPropagateMouseMotion then
                child:SetPropagateMouseMotion(true)
            end
            if child.SetPropagateMouseClicks then
                child:SetPropagateMouseClicks(true)
            end
            
            -- Recurse into children
            self:PropagateMouseOnChildren(child)
        end
    end
end

function CC:RegisterBlizzardFrames()
    if InCombatLockdown() then
        self.needsBlizzardRegistration = true
        return
    end
    
    -- Helper to validate and register a Blizzard frame
    local function registerBlizzardFrame(frameName)
        local frame = _G[frameName]
        if not frame then return end
        
        -- Never allow forbidden frames
        local forbidden = frame.IsForbidden and frame:IsForbidden()
        if forbidden then return end
        
        -- Validate frame is suitable for click-casting
        local buttonish = frame.RegisterForClicks ~= nil
        local protected = frame.IsProtected and frame:IsProtected()
        local name = frame.GetName and frame:GetName()
        local anchorRestricted = frame.IsAnchoringRestricted and frame:IsAnchoringRestricted()
        
        -- Bail out if any values are secret (can't do boolean operations on them)
        if issecretvalue(protected) or issecretvalue(name) or issecretvalue(anchorRestricted) then
            return
        end
        
        local nameplateish = name and type(name) == "string" and name:match("^NamePlate")
        
        -- A frame must be a button, and must be protected, and must not be a nameplate or anchor restricted
        local valid = buttonish and protected and (not nameplateish) and (not anchorRestricted)
        
        if not valid then
            return
        end
        
        frame.dfIsBlizzardFrame = true
        -- Fix health/mana bar mouse event propagation
        CC:FixBlizzardFrameStatusBars(frame)
        self:RegisterFrame(frame)
    end
    
    -- Register static frames
    for _, frameName in ipairs(BLIZZARD_FRAMES) do
        registerBlizzardFrame(frameName)
    end
    
    -- Register boss frames (if they exist)
    for _, frameName in ipairs(BLIZZARD_BOSS_FRAMES) do
        registerBlizzardFrame(frameName)
    end
    
    -- Register arena frames (if they exist)
    for _, frameName in ipairs(BLIZZARD_ARENA_FRAMES) do
        registerBlizzardFrame(frameName)
    end
    
    self.blizzardFramesRegistered = true
end

function CC:UnregisterBlizzardFrames()
    if InCombatLockdown() then
        self.needsBlizzardUnregistration = true
        return
    end
    
    -- Unregister static frames
    for _, frameName in ipairs(BLIZZARD_FRAMES) do
        local frame = _G[frameName]
        if frame then
            self:UnregisterFrame(frame)
        end
    end
    
    -- Unregister boss frames
    for _, frameName in ipairs(BLIZZARD_BOSS_FRAMES) do
        local frame = _G[frameName]
        if frame then
            self:UnregisterFrame(frame)
        end
    end
    
    -- Unregister arena frames
    for _, frameName in ipairs(BLIZZARD_ARENA_FRAMES) do
        local frame = _G[frameName]
        if frame then
            self:UnregisterFrame(frame)
        end
    end
    
    self.blizzardFramesRegistered = false
end

-- Update Blizzard frame registration based on current bindings
function CC:UpdateBlizzardFrameRegistration()
    local needsBlizzard = self:AnyBindingNeedsBlizzardFrames()
    
    if needsBlizzard and not self.blizzardFramesRegistered then
        if not InCombatLockdown() then
            self:RegisterBlizzardFrames()
        else
            self.needsBlizzardRegistration = true
        end
    elseif not needsBlizzard and self.blizzardFramesRegistered then
        if not InCombatLockdown() then
            self:UnregisterBlizzardFrames()
        else
            self.needsBlizzardUnregistration = true
        end
    end
    
    -- Also check for nameplate needs
    if needsNameplates then
        if not InCombatLockdown() then
        else
        end
    end
end

-- ============================================================

-- DYNAMIC FRAME HOOKS (Boss/Arena frames that appear mid-combat)
-- ============================================================

function CC:SetupDynamicFrameHooks()
    -- Hook boss frame show events
    for _, frameName in ipairs(BLIZZARD_BOSS_FRAMES) do
        local frame = _G[frameName]
        if frame and not frame.dfHooked then
            frame:HookScript("OnShow", function(self)
                if CC.db.options.globalEnabled then
                    if InCombatLockdown() then
                        CC.pendingRegistrations = CC.pendingRegistrations or {}
                        CC.pendingRegistrations[self] = true
                    else
                        CC:RegisterFrame(self)
                    end
                end
            end)
            frame.dfHooked = true
        end
    end
    
    -- Hook arena frame show events
    for _, frameName in ipairs(BLIZZARD_ARENA_FRAMES) do
        local frame = _G[frameName]
        if frame and not frame.dfHooked then
            frame:HookScript("OnShow", function(self)
                if CC.db.options.globalEnabled then
                    if InCombatLockdown() then
                        CC.pendingRegistrations = CC.pendingRegistrations or {}
                        CC.pendingRegistrations[self] = true
                    else
                        CC:RegisterFrame(self)
                    end
                end
            end)
            frame.dfHooked = true
        end
    end
    
    -- Also try again after a delay (frames may load later)
    C_Timer.After(2, function()
        CC:SetupDynamicFrameHooks()
    end)
end

-- Build a virtual button name from binding (like Cell's approach: "shiftQ", "ctrlF1", etc.)
function CC:GetVirtualButtonName(binding)
    local parts = {}
    
    -- Add modifiers in lowercase (Cell's format)
    if binding.modifiers and binding.modifiers ~= "" then
        local mods = binding.modifiers:lower()
        if mods:find("alt") then table.insert(parts, "alt") end
        if mods:find("ctrl") then table.insert(parts, "ctrl") end
        if mods:find("shift") then table.insert(parts, "shift") end
        if mods:find("meta") then table.insert(parts, "meta") end  -- Mac Command key
    end
    
    -- Add the key/button
    local key = ""
    if binding.bindType == "mouse" and binding.button then
        -- Mouse binding - convert to "mouse1", "mouse2", etc.
        local buttonNum
        if binding.button == "LeftButton" then
            buttonNum = "1"
        elseif binding.button == "RightButton" then
            buttonNum = "2"
        elseif binding.button == "MiddleButton" then
            buttonNum = "3"
        else
            buttonNum = binding.button:match("Button(%d+)") or binding.button:match("button(%d+)")
        end
        
        if buttonNum then
            key = "mouse" .. buttonNum
        else
            key = binding.button:lower()
        end
    elseif binding.bindType == "scroll" then
        key = binding.key == "SCROLLUP" and "scrollup" or "scrolldown"
    else
        -- Keyboard binding - prefix with "key" to avoid conflict with mouse button numbers
        -- e.g., key "5" becomes "key5", key "Q" becomes "keyq"
        key = "key" .. (binding.key or ""):lower()
    end
    table.insert(parts, key)
    
    return table.concat(parts, "")
end

-- ============================================================

-- FRAME REGISTRATION
-- ============================================================

-- Register a unit frame for click-casting
function CC:RegisterFrame(frame)
    if not frame then return end

    -- Don't do anything if our click casting is disabled
    -- This allows Clique/Clicked to fully control the frame
    if not self.db or not self.db.enabled then
        return
    end

    -- Ensure registeredFrames table exists (may be called before full init)
    if not self.registeredFrames then
        self.registeredFrames = {}
    end

    if self.registeredFrames[frame] then return end

    -- Don't register during combat OR if secure frames aren't initialized yet
    if InCombatLockdown() or not self.secureFramesInitialized then
        -- Queue for later
        self.pendingRegistrations = self.pendingRegistrations or {}
        self.pendingRegistrations[frame] = true
        return
    end
    
    -- Store original click bindings if not already stored
    if not frame.dfOriginalClickBindings then
        frame.dfOriginalClickBindings = {}
    end
    
    -- Mark as registered
    self.registeredFrames[frame] = true
    frame.dfClickCastRegistered = true
    
    -- Hook OnEnter to hide Blizzard's ClickBindingFrame when hovering our frames
    if not frame.dfClickBindingHooked then
        frame.dfClickBindingHooked = true
        frame:HookScript("OnEnter", function(self)
            if CC.db and CC.db.enabled then
                -- Hide Blizzard's global click-cast overlay
                if ClickBindingFrame and ClickBindingFrame:IsShown() then
                    ClickBindingFrame:Hide()
                end
                -- Also disable it from showing while we're hovered
                if ClickBindingFrame then
                    ClickBindingFrame:EnableMouse(false)
                end
            end
        end)
        frame:HookScript("OnLeave", function(self)
            -- Re-enable ClickBindingFrame when leaving (for other addons/frames)
            if ClickBindingFrame then
                ClickBindingFrame:EnableMouse(true)
            end
        end)
    end
    
    -- Clear any Blizzard click casting on this frame (only non-DandersFrames need this)
    if self:ShouldClearBlizzardFromFrame(frame) then
        self:ClearBlizzardClickCastFromFrame(frame)
    end
    
    -- IMPORTANT: Build macro map FIRST so we have bindings to apply
    if not self.unifiedMacroMap then
        self.unifiedMacroMap = self:BuildUnifiedMacroMap()
    end
    
    -- Set up secure handlers for keyboard bindings using WrapScript
    -- This creates the WrapScript that reads binding attributes at runtime
    self:SetupSecureHandlers(frame)
    
    -- Apply mouse bindings (type1, macrotext1, etc.)
    self:ApplyBindingsToFrameUnified(frame)
    
    -- Apply keyboard binding attributes (dfBind1Key, dfBind1Btn, etc.)
    -- The WrapScript will read these when OnEnter fires
    self:UpdateFrameBindingAttributes(frame)
end

-- ============================================================
-- BINDING STATE DIAGNOSTIC TICKER
-- Read-only observer that polls dfBindingsActive every 200ms while hovering.
-- Logs the exact moment bindings transition from active to cleared,
-- helping pinpoint the Blizzard WrapScript bug.
-- No protected function calls — purely reads attributes and logs.
-- ============================================================

local DIAG_INTERVAL = 0.2  -- seconds between polls

function CC:StartDiagnosticTicker(frame)
    self:StopDiagnosticTicker()

    local frameName = frame:GetName() or "unnamed"
    self.diagTickerFrame = frame
    self.diagLastBindState = frame:GetAttribute("dfBindingsActive") and true or false
    self.diagTickCount = 0

    self.diagTicker = C_Timer.NewTicker(DIAG_INTERVAL, function()
        -- Stop if frame is no longer hovered
        if CC.currentHoveredFrame ~= frame then
            CC:StopDiagnosticTicker()
            return
        end

        CC.diagTickCount = (CC.diagTickCount or 0) + 1
        local bindingsActive = frame:GetAttribute("dfBindingsActive") and true or false
        local wrapEnterCount = frame:GetAttribute("dfWrapEnterCount") or 0
        local wrapLeaveCount = frame:GetAttribute("dfWrapLeaveCount") or 0

        -- Check if the restricted environment still considers this frame the mouseoverbutton
        -- dfIsSecureMouseover is set to true on WrapScript OnEnter, cleared when another frame enters
        local isSecureMouseover = frame:GetAttribute("dfIsSecureMouseover") and true or false

        -- Detect transition: bindings were active, now they're not
        if CC.diagLastBindState and not bindingsActive then
            DF:DebugError("CLICK", "BINDINGS VANISHED on %s at tick %d! wrapEnter=%d wrapLeave=%d isSecureMO=%s visible=%s mouseOver=%s combat=%s",
                frameName, CC.diagTickCount, wrapEnterCount, wrapLeaveCount, tostring(isSecureMouseover),
                tostring(frame:IsVisible()), tostring(frame:IsMouseOver()), tostring(InCombatLockdown()))
        end

        -- Detect mouseoverbutton desync: we think we're hovering this frame,
        -- but the restricted environment no longer considers it the mouseoverbutton
        -- (some other frame's WrapScript OnEnter fired and took ownership)
        if not isSecureMouseover then
            if not CC.diagDesyncReported then
                CC.diagDesyncReported = true
                DF:DebugError("CLICK", "MOUSEOVERBUTTON DESYNC on %s at tick %d! dfIsSecureMouseover=nil wrapEnter=%d wrapLeave=%d kbActive=%s",
                    frameName, CC.diagTickCount, wrapEnterCount, wrapLeaveCount, tostring(bindingsActive))
            end
        else
            CC.diagDesyncReported = nil
        end

        CC.diagLastBindState = bindingsActive
    end)
end

function CC:StopDiagnosticTicker()
    if self.diagTicker then
        self.diagTicker:Cancel()
        self.diagTicker = nil
    end
    self.diagTickerFrame = nil
    self.diagTickCount = nil
    self.diagLastBindState = nil
    self.diagDesyncReported = nil
end

-- Set up keyboard binding handlers for a frame using override bindings
-- This uses SetOverrideBindingClick to temporarily bind keyboard keys when hovering
function CC:SetupSecureHandlers(frame)
    if not frame then return end
    if InCombatLockdown() then return end
    
    -- Skip if already set up
    if frame.dfKeyboardHandlersSetup then return end
    
    local frameName = frame:GetName()
    if not frameName then return end
    
    -- === WrapScript Approach ===
    -- With SetPropagateMouseMotion(true) on child elements (auras, defensive icons),
    -- OnLeave only fires when truly leaving to the 3D world, not when hovering children.
    -- This allows us to safely clear bindings on OnLeave.
    
    if self.header and self.header.WrapScript then
        -- WrapScript OnEnter: Set up bindings
        -- Also clears previous frame's bindings to avoid stacking
        local onEnterSnippet = [[
            -- Phase 0: Reset tracking for this enter cycle
            -- dfBindingsActive is cleared FIRST so a stale true from the previous
            -- enter can't fool us. It only gets set back to true at the very end.
            self:SetAttribute("dfBindingsActive", nil)
            self:SetAttribute("dfClearedBy", nil)
            self:SetAttribute("dfStateDriverCount", nil)
            self:SetAttribute("dfStateDriverUnderMouse", nil)
            -- self:SetAttribute("dfSDMouseX", nil)  -- GetMousePosition() fallback
            -- self:SetAttribute("dfSDMouseY", nil)  -- GetMousePosition() fallback
            self:SetAttribute("dfEnterPhase", 0)

            -- Phase 1: increment WrapScript enter counter
            local wrapCount = (self:GetAttribute("dfWrapEnterCount") or 0) + 1
            self:SetAttribute("dfWrapEnterCount", wrapCount)
            self:SetAttribute("dfEnterPhase", 1)

            -- Phase 2: store what mouseoverbutton was before we change it
            if mouseoverbutton then
                self:SetAttribute("dfSecurePrevMouseover", mouseoverbutton:GetAttribute("dfFrameName") or "unknown")
            else
                self:SetAttribute("dfSecurePrevMouseover", "nil")
            end
            self:SetAttribute("dfEnterPhase", 2)

            -- Phase 3: Clear bindings from previous button if any
            if mouseoverbutton and mouseoverbutton ~= self then
                mouseoverbutton:ClearBindings()
                mouseoverbutton:SetAttribute("dfBindingsActive", nil)
                mouseoverbutton:SetAttribute("dfIsSecureMouseover", nil)
            end
            self:SetAttribute("dfEnterPhase", 3)

            -- Phase 4: Set mouseoverbutton
            mouseoverbutton = self
            self:SetAttribute("dfIsSecureMouseover", true)
            self:SetAttribute("dfEnterPhase", 4)

            -- Phase 5: Clear our own bindings first then re-apply
            self:ClearBindings()
            self:SetAttribute("dfEnterPhase", 5)

            -- Phase 6: Run the binding snippet
            local snippet = self:GetAttribute("dfBindingSnippet")
            if snippet and snippet ~= "" then
                self:Run(snippet)
                self:SetAttribute("dfBindingsActive", true)
                self:SetAttribute("dfEnterPhase", 6)
            else
                self:SetAttribute("dfBindingsActive", false)
                self:SetAttribute("dfEnterPhase", -1)
            end

            -- Phase 7: Post-completion verification
            -- Check that mouseoverbutton still points to self after everything ran
            if mouseoverbutton == self then
                self:SetAttribute("dfPostCheck", "ok")
            elseif mouseoverbutton then
                -- mouseoverbutton changed to a DIFFERENT frame during OnEnter
                self:SetAttribute("dfPostCheck", mouseoverbutton:GetAttribute("dfFrameName") or "other")
            else
                -- mouseoverbutton is nil — something wiped it during OnEnter
                self:SetAttribute("dfPostCheck", "nil")
            end
            self:SetAttribute("dfEnterPhase", 7)
        ]]

        -- WrapScript OnLeave: Clear bindings when leaving frame
        -- With SetPropagateMouseMotion(true) on child elements (auras),
        -- OnLeave only fires when truly leaving to the 3D world
        local onLeaveSnippet = [[
            -- Debug: increment WrapScript leave counter
            local leaveCount = (self:GetAttribute("dfWrapLeaveCount") or 0) + 1
            self:SetAttribute("dfWrapLeaveCount", leaveCount)

            -- Debug: store who mouseoverbutton actually points to when leave fires
            if mouseoverbutton then
                self:SetAttribute("dfMouseoverOnLeave", mouseoverbutton:GetAttribute("dfFrameName") or "unknown")
            else
                self:SetAttribute("dfMouseoverOnLeave", "nil")
            end
            -- Store whether the mouseoverbutton==self check will pass
            self:SetAttribute("dfLeaveCheckPassed", mouseoverbutton == self)

            if mouseoverbutton == self then
                self:SetAttribute("dfClearedBy", "onleave")
                self:ClearBindings()
                self:SetAttribute("dfBindingsActive", nil)
                self:SetAttribute("dfIsSecureMouseover", nil)
                mouseoverbutton = nil
            end
        ]]
        
        -- WrapScript OnHide: Clear bindings when frame is hidden during combat
        -- This runs in the restricted (secure) environment, so it can call
        -- ClearBindings() even during combat — unlike HookScript OnHide.
        -- Covers the case where a frame is hidden while hovered (e.g., party
        -- member leaves group, pet dies) and OnLeave doesn't fire.
        local onHideSnippet = [[
            if mouseoverbutton == self then
                self:SetAttribute("dfClearedBy", "onhide")
                self:ClearBindings()
                self:SetAttribute("dfBindingsActive", nil)
                self:SetAttribute("dfIsSecureMouseover", nil)
                mouseoverbutton = nil
            end
        ]]

        local wrapSuccess = pcall(function()
            -- Standard WrapScript - our bindings run in pre script (before other handlers)
            -- Note: Previously tried post parameter for Clicked compatibility, but it broke
            -- click casting entirely. Reverted 2025-01-20.
            self.header:WrapScript(frame, "OnEnter", onEnterSnippet)
            self.header:WrapScript(frame, "OnLeave", onLeaveSnippet)
            self.header:WrapScript(frame, "OnHide", onHideSnippet)
        end)
        
        if not wrapSuccess then
            -- WrapScript failed
            frame.dfKeyboardHandlersSetup = true
            return
        end
    end
    
    -- Diagnostic logging for OnHide (insecure side)
    -- Actual binding cleanup is handled by WrapScript OnHide above (secure, works in combat)
    frame:HookScript("OnHide", function(self)
        local wasHovered = (CC.currentHoveredFrame == self)
        if wasHovered then
            local clearedBy = self:GetAttribute("dfClearedBy") or "?"
            DF:DebugWarn("CLICK", "OnHide %s while HOVERED — clearedBy=%s combat=%s",
                self:GetName() or "unnamed", clearedBy, tostring(InCombatLockdown()))
            CC.currentHoveredFrame = nil
        end
    end)
    
    -- Set frame type and identity attributes
    frame:SetAttribute("dfIsDandersFrame", frame.dfIsDandersFrame == true)
    frame:SetAttribute("dfIsBlizzardFrame", frame.dfIsBlizzardFrame == true)
    frame:SetAttribute("dfFrameName", frame:GetName() or "unnamed")  -- readable from WrapScript
    
    -- Track current hovered frame for click-casting + diagnostic logging
    frame:HookScript("OnEnter", function(self)
        CC.currentHoveredFrame = self

        -- Debug: verify WrapScript set up bindings and check attribute state
        local bindingsActive = self:GetAttribute("dfBindingsActive")
        local snippet = self:GetAttribute("dfBindingSnippet") or ""
        local hasKeyboardBindings = snippet ~= ""
        local frameName = self:GetName() or "unnamed"
        local unit = self:GetAttribute("unit") or self.unit or "?"
        local type1 = self:GetAttribute("type1")
        local wrapEnterCount = self:GetAttribute("dfWrapEnterCount") or 0
        local wrapLeaveCount = self:GetAttribute("dfWrapLeaveCount") or 0

        -- Store the wrap count we expect; if it didn't increment, WrapScript didn't fire
        local prevWrapEnterCount = self.dfLastWrapEnterCount or 0
        local prevWrapLeaveCount = self.dfLastWrapLeaveCount or 0
        self.dfLastWrapEnterCount = wrapEnterCount
        self.dfLastWrapLeaveCount = wrapLeaveCount

        local wrapEnterFired = wrapEnterCount > prevWrapEnterCount

        local enterPhase = self:GetAttribute("dfEnterPhase") or -99
        local prevMouseover = self:GetAttribute("dfSecurePrevMouseover") or "?"
        local postCheck = self:GetAttribute("dfPostCheck") or "?"

        DF:Debug("CLICK", "OnEnter %s unit=%s kbActive=%s hasKB=%s type1=%s wrapEnter=%s(%d) wrapLeave=%d phase=%d prev=%s postCheck=%s",
            frameName, tostring(unit), tostring(bindingsActive),
            tostring(hasKeyboardBindings), tostring(type1),
            tostring(wrapEnterFired), wrapEnterCount, wrapLeaveCount,
            enterPhase, prevMouseover, postCheck)

        -- Key diagnostic: mouseoverbutton was not self after OnEnter completed
        if wrapEnterFired and postCheck ~= "ok" then
            DF:DebugError("CLICK", "POST-CHECK FAILED on %s! mouseoverbutton=%s after phase 7 — self reference lost during OnEnter",
                frameName, postCheck)
        end

        -- Key diagnostic: WrapScript didn't complete all phases
        if wrapEnterFired and enterPhase < 7 and hasKeyboardBindings then
            DF:DebugError("CLICK", "WRAPSCRIPT INCOMPLETE on %s! phase=%d (expected 7) prev=%s",
                frameName, enterPhase, prevMouseover)
        end

        -- Key diagnostic: hover is on but WrapScript didn't activate keyboard bindings
        if hasKeyboardBindings and not bindingsActive then
            DF:DebugWarn("CLICK", "HOVER BUT NO KB BINDINGS on %s! Key presses will go to action bar (phase=%d)", frameName, enterPhase)
            if not wrapEnterFired then
                DF:DebugWarn("CLICK", "  WrapScript OnEnter DID NOT FIRE (enterCount=%d leaveCount=%d)", wrapEnterCount, wrapLeaveCount)
                DF:DebugWarn("CLICK", "  frame visible=%s shown=%s mouseOver=%s combat=%s",
                    tostring(self:IsVisible()), tostring(self:IsShown()),
                    tostring(self:IsMouseOver()), tostring(InCombatLockdown()))
                -- Check if header still owns this frame
                local parent = self:GetParent()
                DF:DebugWarn("CLICK", "  parent=%s headerRef=%s",
                    parent and parent:GetName() or "nil",
                    CC.header and CC.header:GetName() or "nil")
            else
                DF:DebugWarn("CLICK", "  WrapScript fired (enterCount=%d phase=%d) but dfBindingsActive=%s snippet=%d chars",
                    wrapEnterCount, enterPhase, tostring(bindingsActive), #snippet)
                DF:DebugWarn("CLICK", "  snippet preview: %s", snippet:sub(1, 200))
            end
            DF:DebugWarn("CLICK", "  handlersSetup=%s registered=%s",
                tostring(self.dfKeyboardHandlersSetup), tostring(self.dfClickCastRegistered))
        end

        -- Warn if mouse click-cast attributes are missing
        if not type1 or type1 == "" then
            DF:DebugWarn("CLICK", "NO TYPE1 on %s - left-click won't cast!", frameName)
        end

        -- Start diagnostic ticker to monitor binding state while hovering
        if hasKeyboardBindings then
            CC:StartDiagnosticTicker(self)
        end
    end)

    frame:HookScript("OnLeave", function(self)
        local wasTracked = (CC.currentHoveredFrame == self)
        CC.currentHoveredFrame = nil

        -- Stop the diagnostic ticker
        CC:StopDiagnosticTicker()

        local frameName = self:GetName() or "unnamed"
        local wrapLeaveCount = self:GetAttribute("dfWrapLeaveCount") or 0
        local prevWrapLeaveCount = self.dfLastWrapLeaveCount or 0
        local wrapLeaveFired = wrapLeaveCount > prevWrapLeaveCount
        self.dfLastWrapLeaveCount = wrapLeaveCount

        local bindingsActive = self:GetAttribute("dfBindingsActive")

        DF:Debug("CLICK", "OnLeave %s wrapLeave=%s(%d) kbStillActive=%s",
            frameName, tostring(wrapLeaveFired), wrapLeaveCount, tostring(bindingsActive))

        if not wasTracked then
            DF:DebugWarn("CLICK", "OnLeave %s but wasn't tracked as hovered — possible orphan leave", frameName)
        end

        -- Warn if WrapScript OnLeave didn't fire (bindings may not have been cleared)
        if not wrapLeaveFired and wasTracked then
            DF:DebugWarn("CLICK", "WrapScript OnLeave DID NOT FIRE for %s! leaveCount=%d kbActive=%s",
                frameName, wrapLeaveCount, tostring(bindingsActive))
        end

        -- Warn if bindings are still active after leave (WrapScript should have cleared them)
        if bindingsActive then
            -- Read the frame attributes set by WrapScript OnLeave to see what happened
            local mouseoverOnLeave = self:GetAttribute("dfMouseoverOnLeave") or "?"
            local leaveCheckPassed = self:GetAttribute("dfLeaveCheckPassed")
            local isSecureMouseover = self:GetAttribute("dfIsSecureMouseover")
            local postCheck = self:GetAttribute("dfPostCheck") or "?"
            local clearedBy = self:GetAttribute("dfClearedBy") or "nobody"
            local stateDriverCount = self:GetAttribute("dfStateDriverCount") or 0
            local stateDriverUnderMouse = self:GetAttribute("dfStateDriverUnderMouse")
            -- GetMousePosition() fallback diagnostics:
            -- local sdMouseX = self:GetAttribute("dfSDMouseX")
            -- local sdMouseY = self:GetAttribute("dfSDMouseY")
            DF:DebugError("CLICK", "BINDINGS STILL ACTIVE after OnLeave %s! wrapLeave=%s mouseoverbutton=%s checkPassed=%s isSecureMO=%s postCheck=%s",
                frameName, tostring(wrapLeaveFired), mouseoverOnLeave, tostring(leaveCheckPassed), tostring(isSecureMouseover), postCheck)
            DF:DebugError("CLICK", "  clearedBy=%s stateDriverFired=%d underMouse=%s",
                clearedBy, stateDriverCount, tostring(stateDriverUnderMouse))
        end
    end)

    -- Debug: PreClick hook to log click state and detect binding mismatches
    frame:HookScript("PreClick", function(self, button, down)
        local frameName = self:GetName() or "unnamed"
        local unit = self:GetAttribute("unit") or self.unit or "?"
        local hovered = self.dfIsHovered

        -- Determine which attributes handle this click
        local typeAttr, macroAttr
        if button == "LeftButton" then
            typeAttr = self:GetAttribute("type1")
            macroAttr = self:GetAttribute("macrotext1")
        elseif button == "RightButton" then
            typeAttr = self:GetAttribute("type2")
            macroAttr = self:GetAttribute("macrotext2")
        elseif button == "MiddleButton" then
            typeAttr = self:GetAttribute("type3")
            macroAttr = self:GetAttribute("macrotext3")
        else
            -- Virtual button from keyboard override binding (e.g., "dfbuttonshift1")
            typeAttr = self:GetAttribute("type-" .. button)
            macroAttr = self:GetAttribute("macrotext-" .. button)
        end

        DF:Debug("CLICK", "PreClick %s btn=%s unit=%s hovered=%s type=%s macro=%s",
            frameName, button, tostring(unit), tostring(hovered), tostring(typeAttr),
            macroAttr and macroAttr:sub(1, 50) or "nil")

        -- Warn if click-cast type is missing for this button
        if not typeAttr or typeAttr == "" then
            local bindingsActive = self:GetAttribute("dfBindingsActive")
            local snippet = self:GetAttribute("dfBindingSnippet") or ""
            local wrapEnterCount = self:GetAttribute("dfWrapEnterCount") or 0
            local wrapLeaveCount = self:GetAttribute("dfWrapLeaveCount") or 0
            local isHovered = (CC.currentHoveredFrame == self)

            DF:DebugWarn("CLICK", "MISSING TYPE for btn=%s on %s - click won't cast!", button, frameName)
            DF:DebugWarn("CLICK", "  kbActive=%s snippet=%d chars combat=%s isHovered=%s",
                tostring(bindingsActive), #snippet, tostring(InCombatLockdown()), tostring(isHovered))
            DF:DebugWarn("CLICK", "  wrapEnter=%d wrapLeave=%d visible=%s mouseOver=%s",
                wrapEnterCount, wrapLeaveCount, tostring(self:IsVisible()), tostring(self:IsMouseOver()))
        end
    end)

    frame.dfKeyboardHandlersSetup = true
end

-- Set up WrapScript on child elements (auras, defensive icons) so mouseoverbutton
-- Update the binding attributes stored on a frame
-- Builds a snippet string with SetBindingClick calls (Cell-style approach)
-- The _onenter attribute runs this snippet on every hover
function CC:UpdateFrameBindingAttributes(frame)
    if not frame or InCombatLockdown() then return end
    
    local frameName = frame:GetName()
    if not frameName then return end
    
    -- Build the snippet with SetBindingClick calls
    local snippetLines = {}
    
    if self.unifiedMacroMap then
        for keyString, data in pairs(self.unifiedMacroMap) do
            local binding = data.templateBinding
            local bindType = binding.bindType or "mouse"
            
            -- Check if this is a META mouse binding (Mac Command key)
            -- These need SetBindingClick because frame attributes don't work for meta- on Mac
            local isMetaMouseBinding = (bindType == "mouse") and 
                binding.modifiers and binding.modifiers:lower():find("meta")
            
            -- Process keyboard, scroll, AND meta mouse bindings with SetBindingClick
            -- Regular mouse bindings are handled via frame attributes (type1, spell1, etc.)
            if bindType == "key" or bindType == "scroll" or isMetaMouseBinding then
                -- Check if this binding should apply to this frame
                if self:ShouldBindingApplyToFrame(binding, frame) then
                    local bindKey
                    local virtualBtn = self:GetVirtualButtonName(binding)
                    
                    if isMetaMouseBinding then
                        -- Build binding key for mouse button (e.g., "META-BUTTON1", "ALT-META-BUTTON3")
                        local buttonNum
                        if binding.button == "LeftButton" then
                            buttonNum = "BUTTON1"
                        elseif binding.button == "RightButton" then
                            buttonNum = "BUTTON2"
                        elseif binding.button == "MiddleButton" then
                            buttonNum = "BUTTON3"
                        else
                            local num = binding.button:match("Button(%d+)")
                            buttonNum = num and ("BUTTON" .. num) or binding.button:upper()
                        end
                        bindKey = self:BuildBindingKey(binding.modifiers, buttonNum)
                    else
                        -- Keyboard/scroll binding
                        bindKey = self:BuildBindingKey(binding.modifiers, 
                            bindType == "scroll" and (binding.key == "SCROLLUP" and "MOUSEWHEELUP" or "MOUSEWHEELDOWN") or binding.key)
                    end
                    
                    -- Build SetBindingClick call - FRAME owns bindings, targets SELF
                    table.insert(snippetLines, string.format(
                        [[self:SetBindingClick(true, %q, self, %q)]],
                        bindKey, virtualBtn
                    ))
                end
            end
        end
    end
    
    -- Store the snippet - _onenter will run this on every hover
    local snippet = table.concat(snippetLines, "\n")
    frame:SetAttribute("dfBindingSnippet", snippet)
end

-- Legacy alias for compatibility
-- Refresh binding attributes on all registered frames
-- Call this when bindings change
function CC:RefreshKeyboardBindings()
    if InCombatLockdown() then 
        self.pendingKeyboardRefresh = true
        return 
    end
    
    -- Update binding attributes on all registered frames
    if self.registeredFrames then
        for frame in pairs(self.registeredFrames) do
            if frame.dfKeyboardHandlersSetup then
                self:UpdateFrameBindingAttributes(frame)
            end
        end
    end
    
    -- Also update DandersFrames
    if DF and DF.unitFrames then
        for _, frame in pairs(DF.unitFrames) do
            if frame.dfKeyboardHandlersSetup then
                self:UpdateFrameBindingAttributes(frame)
            end
        end
    end
    
    self.pendingKeyboardRefresh = false
end

-- Legacy function - now calls RefreshKeyboardBindings
function CC:BuildKeyboardBindingSnippets()
    self:RefreshKeyboardBindings()
end

-- Set up click wrapping for a frame (enables click casting on third-party frames)
-- This sets up the hovercast button's unit attribute when hovering so global bindings work
-- NOTE: This function is currently NOT CALLED - keeping for potential future use
-- Sets up WrapScript for click-casting (alternative approach to keyboard bindings)
function CC:SetupClickWrapping(frame)
    if not frame then return end
    if InCombatLockdown() then return end
    if frame.dfClickWrapSetup then return end
    
    local frameName = frame:GetName()
    if not frameName then return end
    
    -- Check if we have the header with required methods and hovercast button
    if not self.header or not self.header.SetFrameRef or not self.header.WrapScript or not self.hovercastButton then return end
    
    -- Store reference to our button in the header for secure access
    self.header:SetFrameRef("hovercastButton", self.hovercastButton)
    
    -- Try to wrap OnEnter to set up the hovercast button's unit
    -- This is in ADDITION to the keyboard binding setup
    local onEnterClickSnippet = [[
        -- Get the unit from this frame
        local unit = self:GetAttribute("unit")
        if unit then
            -- Get reference to our hovercast button
            local btn = owner:GetFrameRef("hovercastButton")
            if btn then
                -- Set the unit attribute on our button so global bindings target this unit
                btn:SetAttribute("unit", unit)
            end
        end
    ]]
    
    -- Also set up on PreClick for immediate action
    local preClickSnippet = [[
        local unit = self:GetAttribute("unit")
        if unit then
            local btn = owner:GetFrameRef("hovercastButton")
            if btn then
                btn:SetAttribute("unit", unit)
            end
        end
    ]]
    
    -- Try to wrap - this enables click casting via our global bindings
    local wrapSuccess = pcall(function()
        -- Wrap OnEnter to set unit when hovering
        self.header:WrapScript(frame, "OnEnter", onEnterClickSnippet, nil)
        -- Wrap PreClick to ensure unit is set right before click
        self.header:WrapScript(frame, "PreClick", preClickSnippet)
    end)
    
    if wrapSuccess then
        frame.dfClickWrapSetup = true
    end
    
    -- For third-party frames (not DandersFrames or Blizzard), add Lua hooks
    -- to set up mouse click redirects OUT OF COMBAT
    if not frame.dfIsDandersFrame and not frame.dfIsBlizzardFrame then
        self:SetupThirdPartyMouseRedirect(frame)
    end
end

-- Set up mouse click redirect for third-party frames using Lua hooks (out of combat only)
-- NOTE: This is currently DISABLED. We're trying Clique's approach of just setting
-- type1/spell1 attributes directly on the frame without any redirect.
-- If this doesn't work, we can re-enable the redirect.
function CC:SetupThirdPartyMouseRedirect(frame)
    if not frame or frame.dfMouseRedirectSetup then return end
    
    local frameName = frame:GetName()
    if not frameName then return end
    
    -- Store reference to CC for the hooks
    local CC = self
    
    -- DISABLED: Just set up unit tracking on hovercast button for now
    -- but don't redirect clicks - let the frame handle them directly
    frame:HookScript("OnEnter", function(self)
        if InCombatLockdown() then return end
        if not CC.db or not CC.db.enabled then return end
        
        -- Set unit on hovercast button (for global/hovercast bindings)
        local unit = self:GetAttribute("unit")
        if unit and CC.hovercastButton then
            CC.hovercastButton:SetAttribute("unit", unit)
        end
    end)
    
    frame.dfMouseRedirectSetup = true
end

-- Build a WoW binding key string from modifiers and key
function CC:BuildBindingKey(modifiers, key)
    if not modifiers or modifiers == "" then
        return key:upper()
    end
    
    -- Parse modifiers and rebuild in WoW's expected order: ALT-CTRL-SHIFT-META-KEY
    local hasShift = modifiers:lower():find("shift") ~= nil
    local hasCtrl = modifiers:lower():find("ctrl") ~= nil
    local hasAlt = modifiers:lower():find("alt") ~= nil
    local hasMeta = modifiers:lower():find("meta") ~= nil
    
    local parts = {}
    if hasAlt then table.insert(parts, "ALT") end
    if hasCtrl then table.insert(parts, "CTRL") end
    if hasShift then table.insert(parts, "SHIFT") end
    if hasMeta then table.insert(parts, "META") end
    table.insert(parts, key:upper())
    
    return table.concat(parts, "-")
end

-- Unregister a unit frame from click-casting
function CC:UnregisterFrame(frame)
    if not frame then return end
    if not self.registeredFrames then return end
    if not self.registeredFrames[frame] then return end
    
    -- Don't unregister during combat
    if InCombatLockdown() then
        self.pendingUnregistrations = self.pendingUnregistrations or {}
        self.pendingUnregistrations[frame] = true
        return
    end
    
    -- Restore Blizzard default behavior
    self:RestoreBlizzardDefaults(frame)
    
    -- Mark as unregistered
    self.registeredFrames[frame] = nil
    frame.dfClickCastRegistered = nil
end

-- Register all DandersFrames unit frames
function CC:RegisterAllFrames()
    if InCombatLockdown() then
        self.needsFullRegistration = true
        return
    end
    
    -- Register party frames (includes player when in party/solo)
    if DF.partyHeader then
        for i = 1, 5 do
            local child = DF.partyHeader:GetAttribute("child" .. i)
            if child then
                self:RegisterFrame(child)
            end
        end
    end
    
    -- Register raid frames from separated headers
    if DF.raidSeparatedHeaders then
        for g = 1, 8 do
            local header = DF.raidSeparatedHeaders[g]
            if header then
                for i = 1, 5 do
                    local child = header:GetAttribute("child" .. i)
                    if child then
                        self:RegisterFrame(child)
                    end
                end
            end
        end
    end
    
    -- Register raid frames from FlatRaidFrames header (flat mode)
    if DF.FlatRaidFrames and DF.FlatRaidFrames.header then
        for i = 1, 40 do
            local child = DF.FlatRaidFrames.header:GetAttribute("child" .. i)
            if child then
                self:RegisterFrame(child)
            end
        end
    end
    
    -- Register pet frames
    if DF.petFrames then
        for _, frame in pairs(DF.petFrames) do
            self:RegisterFrame(frame)
        end
    end
    
    -- Also check ClickCastFrames global (for third-party addon support)
    if ClickCastFrames then
        for frame, enabled in pairs(ClickCastFrames) do
            if enabled and frame:GetObjectType() == "Button" or frame:GetObjectType() == "Frame" then
                self:RegisterFrame(frame)
            end
        end
    end
end

-- ============================================================
