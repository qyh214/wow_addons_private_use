local addonName, DF = ...

-- Get module namespace
local CC = DF.ClickCast

-- Local aliases for shared constants (defined in Constants.lua)
local DEFAULT_BINDING = CC.DEFAULT_BINDING

-- Local aliases for helper functions (defined in Profiles.lua)
local GetCombatCondition = function(b) return CC.GetCombatCondition(b) end
local BuildModifierPrefix = function(m) return CC.BuildModifierPrefix(m) end
local GetButtonNumber = function(b) return CC.GetButtonNumber(b) end

-- BUG #10 / BUG #860 FIX: Combat-conditional type attribute via RegisterAttributeDriver.
-- SecureHandlerWrapScript on PreClick can't block type="target" or type="togglemenu"
-- because SecureActionButton_OnClick reads attributes keyed off the ORIGINAL mouse
-- button, not any value the PreClick prescript returns. RegisterAttributeDriver
-- solves this natively: it evaluates a macro conditional and writes the result to
-- the named attribute, re-evaluating whenever relevant events fire (e.g. combat
-- entry/exit). It runs in the restricted environment, so it works during lockdown.
--
-- For a "combat only" target binding:  [combat] target;     → "target" in combat, "" out
-- For a "nocombat only" target binding: [nocombat] target;   → "target" out of combat, "" in
--
-- Tracks registered driver attribute names on frame.dfAttrDriverList so they can
-- be unregistered when bindings change.
local function AddCombatConditional(frame, typeAttr, realType, combatCond)
    local macro = "[" .. combatCond .. "] " .. realType .. ";"
    RegisterAttributeDriver(frame, typeAttr, macro)
    frame.dfAttrDriverList = frame.dfAttrDriverList or {}
    table.insert(frame.dfAttrDriverList, typeAttr)
end

-- BINDING APPLICATION
-- ============================================================

-- Helper to check if a spell is known/usable (used at bind-time for fallback selection)
local function IsSpellKnownByName(spellName, spellId)
    if not spellName then return false end

    local bookType = Enum.SpellBookSpellBank.Player

    -- If we have a stored spell ID, check the override chain first
    -- This handles spec-specific variants (e.g. Remove Corruption -> Nature's Cure)
    -- where the stored name may not match the current spec's version
    if spellId and C_Spell.GetOverrideSpell then
        local overrideId = C_Spell.GetOverrideSpell(spellId)
        if overrideId then
            if C_SpellBook and C_SpellBook.IsSpellInSpellBook then
                if C_SpellBook.IsSpellInSpellBook(overrideId, bookType, true) then
                    return true
                end
            end
        end
    end

    -- Try by name (original behavior)
    local spellInfo = C_Spell.GetSpellInfo(spellName)
    if not spellInfo then return false end

    local resolvedId = spellInfo.spellID
    if not resolvedId then return false end

    -- Use IsSpellInSpellBook with includeOverrides=true to handle hero talent overrides
    -- (e.g., Chrono Flames which overrides Living Flame)
    if C_SpellBook and C_SpellBook.IsSpellInSpellBook then
        return C_SpellBook.IsSpellInSpellBook(resolvedId, bookType, true)
    end

    -- Fallback for older API
    if C_SpellBook and C_SpellBook.IsSpellKnownOrInSpellBook then
        return C_SpellBook.IsSpellKnownOrInSpellBook(resolvedId, bookType, true)
    end

    return false
end

-- Get the current display info for a spell, accounting for talent overrides
-- Returns: name, icon, spellId (all for the CURRENT form of the spell)
-- Used for UI display only - binding still uses base spell name for casting
local function GetSpellDisplayInfo(baseSpellId, baseSpellName)
    local displayName = baseSpellName
    local displayIcon = nil
    local displaySpellId = baseSpellId
    
    -- Try to get override spell if we have a base ID
    if baseSpellId and C_Spell.GetOverrideSpell then
        local overrideId = C_Spell.GetOverrideSpell(baseSpellId)
        if overrideId and overrideId ~= baseSpellId then
            displaySpellId = overrideId
            local overrideInfo = C_Spell.GetSpellInfo(overrideId)
            if overrideInfo then
                -- Debug: Log when an override is found
                -- print("|cffff00ffDF Override:|r " .. tostring(baseSpellId) .. " -> " .. tostring(overrideId) .. " (" .. tostring(overrideInfo.name) .. ")")
                displayName = overrideInfo.name or displayName
                displayIcon = overrideInfo.iconID
            end
        end
    end
    
    -- If no override or no icon yet, get from base spell
    if not displayIcon then
        if baseSpellId then
            local spellInfo = C_Spell.GetSpellInfo(baseSpellId)
            if spellInfo then
                displayIcon = spellInfo.iconID
                if not displayName then
                    displayName = spellInfo.name
                end
            end
        elseif baseSpellName then
            displayIcon = C_Spell.GetSpellTexture(baseSpellName)
        end
    end
    
    return displayName, displayIcon, displaySpellId
end

-- Export to CC namespace for use in UI files
CC.GetSpellDisplayInfo = GetSpellDisplayInfo

-- BINDING MIGRATION
-- ============================================================
-- Migrate bindings to use root spell IDs instead of override spell IDs
-- This ensures bindings survive talent changes (e.g., Chrono Flames -> Living Flame)

local MIGRATION_VERSION = 1  -- Increment this when adding new migrations

function CC:MigrateBindingsToRootSpells()
    -- Check if we have access to the saved data
    if not DandersFrames_ClickCastDB then return end
    
    local _, classId = UnitClassBase("player")
    if not classId then return end
    
    local classData = DandersFrames_ClickCastDB[classId]
    if not classData or not classData.profiles then return end
    
    -- Check if migration already done for this class
    local currentMigration = classData.migrationVersion or 0
    
    if currentMigration >= MIGRATION_VERSION then
        return  -- Already migrated
    end
    
    local totalMigrated = 0
    
    -- Migrate ALL profiles for this class
    for profileName, profile in pairs(classData.profiles) do
        if profile.bindings then
            local profileMigrated = 0
            
            for i, binding in ipairs(profile.bindings) do
                if binding.spellName and binding.spellId then
                    -- Check if this spell has a root spell
                    if C_Spell.GetBaseSpell then
                        local rootId = C_Spell.GetBaseSpell(binding.spellId)
                        if rootId and rootId ~= binding.spellId then
                            -- Get the root spell's name
                            local rootInfo = C_Spell.GetSpellInfo(rootId)
                            if rootInfo and rootInfo.name then
                                local oldName = binding.spellName
                                
                                -- Update binding to use root spell
                                binding.spellName = rootInfo.name
                                binding.spellId = rootId
                                
                                profileMigrated = profileMigrated + 1
                                print("|cff33cc66DandersFrames:|r [" .. profileName .. "] Migrated '" .. oldName .. "' -> '" .. rootInfo.name .. "'")
                            end
                        end
                    end
                end
            end
            
            totalMigrated = totalMigrated + profileMigrated
        end
    end
    
    -- Mark migration as complete for this class
    classData.migrationVersion = MIGRATION_VERSION
    
    if totalMigrated > 0 then
        print("|cff33cc66DandersFrames:|r Migrated " .. totalMigrated .. " binding(s) to use root spells for better talent compatibility.")
        -- Refresh the active profile's bindings reference
        if self.profile and self.db then
            self.db.bindings = self.profile.bindings
        end
    end
end

-- Check if a binding should be active based on load conditions
function CC:ShouldBindingLoad(binding)
    if not binding.enabled then return false end
    
    -- Check spec condition
    if binding.loadSpec then
        local currentSpec = GetSpecialization()
        local specMatch = false
        for _, specId in ipairs(binding.loadSpec) do
            if specId == currentSpec then
                specMatch = true
                break
            end
        end
        if not specMatch then return false end
    end
    
    -- Combat conditions are checked dynamically via state drivers
    -- For now, we apply all bindings and let the macro conditionals handle combat
    
    return true
end

-- Clear all click-cast bindings from a frame
function CC:ClearBindingsFromFrame(frame)
    if not frame then return end
    if InCombatLockdown() then return end

    -- Check if this frame is currently being hovered
    local isCurrentlyHovered = (self.currentHoveredFrame == frame) or (frame.IsMouseOver and frame:IsMouseOver())

    -- Debug: warn if clearing bindings on a hovered frame
    local frameName = frame:GetName() or "unnamed"
    if isCurrentlyHovered then
        DF:DebugWarn("CLICK", "ClearBindings on HOVERED frame %s (preserving snippet/overrides)", frameName)
    else
        DF:Debug("CLICK", "ClearBindings %s", frameName)
    end
    
    -- Check if this is a Blizzard frame - we need to preserve default behavior for these
    local isBlizzardFrame = frame.dfIsBlizzardFrame == true
    local isDandersFrame = frame.dfIsDandersFrame == true
    
    -- Clear the binding snippet used by secure handlers
    -- BUT: if frame is currently hovered, DON'T clear - we want to preserve bindings
    if not isCurrentlyHovered then
        frame:SetAttribute("dfBindingSnippet", "")
    end
    
    -- Clear any bindings set by secure handlers (SetBindingClick style)
    -- BUT: if frame is currently hovered, DON'T clear
    if frame.ClearBindings and not isCurrentlyHovered then
        pcall(function() frame:ClearBindings() end)
    end
    
    -- Clear applied bindings
    if frame.dfAppliedBindings then
        for _, attrs in pairs(frame.dfAppliedBindings) do
            if attrs.typeAttr then frame:SetAttribute(attrs.typeAttr, "") end
            if attrs.spellAttr then frame:SetAttribute(attrs.spellAttr, nil) end
            if attrs.macroAttr then frame:SetAttribute(attrs.macroAttr, nil) end
            if attrs.helpbuttonAttr then frame:SetAttribute(attrs.helpbuttonAttr, nil) end
            if attrs.harmbuttonAttr then frame:SetAttribute(attrs.harmbuttonAttr, nil) end
        end
        frame.dfAppliedBindings = nil
    end
    
    -- Clear virtual button attributes (6-50 for keyboard bindings)
    for btn = 6, 50 do
        frame:SetAttribute("type" .. btn, "")
        frame:SetAttribute("spell" .. btn, nil)
        frame:SetAttribute("macro" .. btn, nil)
        frame:SetAttribute("macrotext" .. btn, nil)
    end
    
    -- Clear modifier combinations for mouse buttons (1-5)
    -- Order must be: alt-ctrl-shift-meta (per WoW SecureActionButtonTemplate)
    -- Only DandersFrames should have base type1/type2 cleared.
    -- Blizzard frames AND third-party addon frames (QUI, ElvUI, etc.) must preserve
    -- their base type1/type2 so click-to-target continues to work.
    local modifiers
    if isDandersFrame then
        -- For DandersFrames, clear everything including base bindings
        modifiers = {"alt-", "ctrl-", "shift-", "meta-", "alt-ctrl-", "alt-shift-", "alt-meta-", "ctrl-shift-", "ctrl-meta-", "shift-meta-", "alt-ctrl-shift-", "alt-ctrl-meta-", "alt-shift-meta-", "ctrl-shift-meta-", "alt-ctrl-shift-meta-", ""}
    else
        -- For Blizzard and third-party frames, only clear modifier combinations, not base button bindings
        modifiers = {"alt-", "ctrl-", "shift-", "meta-", "alt-ctrl-", "alt-shift-", "alt-meta-", "ctrl-shift-", "ctrl-meta-", "shift-meta-", "alt-ctrl-shift-", "alt-ctrl-meta-", "alt-shift-meta-", "ctrl-shift-meta-", "alt-ctrl-shift-meta-"}
    end
    local buttons = {"1", "2", "3", "4", "5"}
    
    for _, mod in ipairs(modifiers) do
        for _, btn in ipairs(buttons) do
            frame:SetAttribute(mod .. "type" .. btn, "")
            frame:SetAttribute(mod .. "spell" .. btn, nil)
            frame:SetAttribute(mod .. "macro" .. btn, nil)
            frame:SetAttribute(mod .. "macrotext" .. btn, nil)
        end
    end
    
    -- BUG #10 / #860 FIX: Unregister any combat-conditional attribute drivers.
    if frame.dfAttrDriverList then
        for _, attr in ipairs(frame.dfAttrDriverList) do
            UnregisterAttributeDriver(frame, attr)
        end
        frame.dfAttrDriverList = nil
    end
    
    -- Also clear any existing override bindings on this frame (but not if hovered)
    if not isCurrentlyHovered then
        pcall(function() ClearOverrideBindings(frame) end)
    end
end

-- Restore Blizzard default click behavior to a frame
function CC:RestoreBlizzardDefaults(frame)
    if not frame then return end
    if InCombatLockdown() then return end
    
    -- Clear any custom bindings tracking first
    frame.dfAppliedBindings = nil
    
    -- Clear ALL modifier combinations we may have set (but NOT the base type1/type2)
    -- Order must be: alt-ctrl-shift-meta (per WoW SecureActionButtonTemplate)
    local modifiers = {"alt-", "ctrl-", "shift-", "meta-", "alt-ctrl-", "alt-shift-", "alt-meta-", "ctrl-shift-", "ctrl-meta-", "shift-meta-", "alt-ctrl-shift-", "alt-ctrl-meta-", "alt-shift-meta-", "ctrl-shift-meta-", "alt-ctrl-shift-meta-"}
    local buttons = {"1", "2", "3", "4", "5"}
    
    for _, mod in ipairs(modifiers) do
        for _, btn in ipairs(buttons) do
            frame:SetAttribute(mod .. "type" .. btn, nil)
            frame:SetAttribute(mod .. "spell" .. btn, nil)
            frame:SetAttribute(mod .. "macro" .. btn, nil)
            frame:SetAttribute(mod .. "macrotext" .. btn, nil)
        end
    end
    
    -- Clear non-modified buttons 3, 4, 5 (but not 1 and 2 which we'll set to defaults)
    for _, btn in ipairs({"3", "4", "5"}) do
        frame:SetAttribute("type" .. btn, nil)
        frame:SetAttribute("spell" .. btn, nil)
        frame:SetAttribute("macro" .. btn, nil)
        frame:SetAttribute("macrotext" .. btn, nil)
    end
    
    -- Also clear spell/macro for buttons 1 and 2
    frame:SetAttribute("spell1", nil)
    frame:SetAttribute("spell2", nil)
    frame:SetAttribute("macro1", nil)
    frame:SetAttribute("macro2", nil)
    frame:SetAttribute("macrotext1", nil)
    frame:SetAttribute("macrotext2", nil)
    
    -- Clear virtual button attributes (6-50 for keyboard bindings)
    for btn = 6, 50 do
        frame:SetAttribute("type" .. btn, nil)
        frame:SetAttribute("spell" .. btn, nil)
        frame:SetAttribute("macro" .. btn, nil)
        frame:SetAttribute("macrotext" .. btn, nil)
    end
    
    -- Clear override bindings
    ClearOverrideBindings(frame)
    
    -- Clear the binding snippet so OnEnter won't apply any bindings
    frame:SetAttribute("dfBindingSnippet", "")
    
    -- Set standard Blizzard unit frame behavior
    -- type1 = left click = target
    -- type2 = right click = togglemenu
    frame:SetAttribute("type1", "target")
    frame:SetAttribute("type2", "togglemenu")
    
    -- Reset to standard click registration (AnyUp is default)
    if frame.RegisterForClicks then
        frame:RegisterForClicks("AnyUp")
    end
end

-- Apply bindings to a single frame
-- Check if a binding should apply to a specific frame based on frames checkboxes
function CC:ShouldBindingApplyToFrame(binding, frame)
    if not binding or not frame then return false end
    
    -- Get frames settings (with defaults for backwards compatibility)
    local frames = binding.frames or { dandersFrames = true, otherFrames = true }
    
    -- Determine if this is a DandersFrames frame or an "other" frame
    -- DandersFrames = frames created by our addon (marked with dfIsDandersFrame)
    -- Other frames = Blizzard frames AND third-party addon frames
    local isDandersFrame = frame.dfIsDandersFrame == true
    
    -- Check if binding applies to this frame type
    if isDandersFrame then
        return frames.dandersFrames == true
    else
        return frames.otherFrames == true
    end
end

-- Apply bindings to all registered frames
-- Non-pinned frames are applied immediately.
-- Pinned frames are deferred to avoid "script ran too long" errors,
-- since each frame requires ~500 SetAttribute calls to clear+reapply bindings
-- and highlight headers pre-create up to 40 frames each (80 total).
function CC:ApplyBindings()
    if InCombatLockdown() then
        self.needsBindingRefresh = true
        return
    end
    
    -- Cancel any pending batch binding pass from a previous call
    if self.batchBindingTimer then
        self.batchBindingTimer:Cancel()
        self.batchBindingTimer = nil
    end
    
    -- Migrate existing macro bindings to have no fallbacks
    if self.db and self.db.bindings then
        for _, binding in ipairs(self.db.bindings) do
            if binding.actionType == "macro" or binding.macroId then
                -- Force macros to have no fallbacks
                binding.fallback = {
                    mouseover = false,
                    target = false,
                    selfCast = false,
                }
            end
        end
    end
    
    -- Build unified macro map (all bindings converted to macros)
    self.unifiedMacroMap = self:BuildUnifiedMacroMap()

    -- Set up hovercast button attributes for third-party frame support
    self:SetupHovercastButtonAttributes()

    -- IMPORTANT: Clear Blizzard click-casting BEFORE applying our bindings
    -- This ensures our bindings take precedence and aren't overwritten
    if self.db.enabled then
        self:RefreshBlizzardClickCastClearing()
    end

    -- Apply bindings to all registered frames in batches to avoid "script ran too long".
    -- With ElvUI or other addons, 100-150+ frames can be registered. Each frame requires
    -- ~300+ SetAttribute calls, so processing them all synchronously exceeds Lua's time limit.
    -- Frames are processed in batches of 10 with a yield between each batch.
    if self.registeredFrames then
        local allFrames = {}
        for frame in pairs(self.registeredFrames) do
            allFrames[#allFrames + 1] = frame
        end

        if #allFrames > 0 then
            local BATCH_SIZE = 10
            local batchIndex = 0

            local function ProcessNextBatch()
                if InCombatLockdown() then
                    -- Combat started during batch - flag for retry after combat
                    CC.needsBindingRefresh = true
                    CC.batchBindingTimer = nil
                    return
                end

                local startIdx = batchIndex * BATCH_SIZE + 1
                local endIdx = math.min(startIdx + BATCH_SIZE - 1, #allFrames)

                for i = startIdx, endIdx do
                    CC:ApplyBindingsToFrameUnified(allFrames[i], true)
                end

                batchIndex = batchIndex + 1

                if endIdx < #allFrames then
                    -- More batches to process
                    CC.batchBindingTimer = C_Timer.NewTimer(0, ProcessNextBatch)
                else
                    -- All frames processed - refresh keyboard bindings once for all frames
                    CC.batchBindingTimer = nil
                    CC:RefreshKeyboardBindings()
                end
            end

            -- Process first batch immediately (synchronous), defer the rest
            ProcessNextBatch()
        end
    end

    -- Apply global bindings (hovercast and global scopes)
    self:ApplyGlobalBindings()
end

-- ============================================================

-- GLOBAL BINDING SUPPORT (On Hover & Global Scopes)
-- ============================================================

-- Pool of secure action buttons for global bindings
CC.globalBindingButtons = CC.globalBindingButtons or {}
CC.globalBindingCount = CC.globalBindingCount or 0

-- ============================================================

-- HOVERCAST GLOBAL BUTTON (Exact Clique-style approach)
-- ============================================================

-- Create the single global button used for all hovercast bindings
function CC:CreateHovercastButton()
    if self.hovercastButton then return end
    
    -- Don't create during combat
    if InCombatLockdown() then
        C_Timer.After(1, function()
            if not InCombatLockdown() then
                self:CreateHovercastButton()
            end
        end)
        return
    end
    
    -- Create the button with BOTH templates like Clique does
    -- SecureActionButtonTemplate provides the action execution
    -- SecureHandlerBaseTemplate provides Execute() for secure snippets
    local success = pcall(function()
        self.hovercastButton = CreateFrame("Button", "DFHovercastButton", UIParent, "SecureActionButtonTemplate, SecureHandlerBaseTemplate")
    end)
    
    if not success or not self.hovercastButton then
        -- Fallback: try without SecureHandlerBaseTemplate
        success = pcall(function()
            self.hovercastButton = CreateFrame("Button", "DFHovercastButton", UIParent, "SecureActionButtonTemplate")
        end)
    end
    
    if not success or not self.hovercastButton then
        print("|cffff9900DandersFrames:|r Warning: Could not create hovercast button")
        return
    end
    
    self.hovercastButton:SetSize(1, 1)
    self.hovercastButton:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -100, -100)
    self.hovercastButton:Show()
    self.hovercastButton:EnableMouse(false)
    
    -- Register for BOTH down and up clicks to work regardless of ActionButtonUseKeyDown CVar
    -- This ensures the button receives the click whether WoW is set to fire on key down or key up
    self.hovercastButton:RegisterForClicks("AnyDown", "AnyUp")
    
    -- Debug hooks to see if button receives clicks
    self.hovercastButton:HookScript("PreClick", function(btn, mouseButton, isDown)
        if CC.debugClicksEnabled then
            print("|cff00ffff[DF Debug]|r PreClick: button=" .. tostring(mouseButton) .. " isDown=" .. tostring(isDown))
            local typeAttr = btn:GetAttribute("type-" .. (mouseButton or ""))
            local macroAttr = btn:GetAttribute("macrotext-" .. (mouseButton or ""))
            print("|cff00ffff[DF Debug]|r  type-" .. tostring(mouseButton) .. "=" .. tostring(typeAttr))
            print("|cff00ffff[DF Debug]|r  macrotext-" .. tostring(mouseButton) .. "=" .. tostring(macroAttr and macroAttr:sub(1,50)))
        end
    end)
    
    self.hovercastButton:HookScript("PostClick", function(btn, mouseButton, isDown)
        if CC.debugClicksEnabled then
            print("|cff00ffff[DF Debug]|r PostClick: button=" .. tostring(mouseButton) .. " isDown=" .. tostring(isDown))
        end
    end)
end

-- Set up the hovercast button with spell attributes for third-party frame click casting
-- This is called after bindings are built so the hovercast button can handle redirected clicks
function CC:SetupHovercastButtonAttributes()
    if not self.hovercastButton then return end
    if InCombatLockdown() then return end
    
    local btn = self.hovercastButton
    
    -- Clear existing attributes
    for i = 1, 5 do
        btn:SetAttribute("type" .. i, nil)
        btn:SetAttribute("spell" .. i, nil)
        btn:SetAttribute("macrotext" .. i, nil)
    end
    
    if not self.unifiedMacroMap then return end
    
    -- Set up attributes for each mouse binding
    for keyString, data in pairs(self.unifiedMacroMap) do
        local binding = data.templateBinding
        local bindType = binding.bindType or "mouse"
        
        if bindType == "mouse" and binding.button then
            local virtualBtn = self:GetVirtualButtonName(binding)
            local actionType = binding.actionType or self.ACTION_TYPES.SPELL
            
            -- Check if this should be treated as a special action
            local isSpecialAction = data.isSpecialAction
            if isSpecialAction == nil then
                isSpecialAction = (actionType == "menu" or actionType == "target" or 
                                   actionType == "focus" or actionType == "assist" or
                                   actionType == self.ACTION_TYPES.MENU or 
                                   actionType == self.ACTION_TYPES.FOCUS or
                                   actionType == self.ACTION_TYPES.ASSIST)
            end
            
            if isSpecialAction then
                if actionType == "menu" or actionType == self.ACTION_TYPES.MENU then
                    local typeAttr = "type-" .. virtualBtn
                    btn:SetAttribute(typeAttr, "togglemenu")
                    -- BUG #10 FIX: state-driver-based combat conditional
                    local combatCond = GetCombatCondition(binding)
                    if combatCond then
                        AddCombatConditional(btn, typeAttr, "togglemenu", combatCond)
                    end
                elseif actionType == "target" then
                    local typeAttr = "type-" .. virtualBtn
                    btn:SetAttribute(typeAttr, "target")
                    -- BUG #860 FIX: state-driver-based combat conditional
                    local combatCond = GetCombatCondition(binding)
                    if combatCond then
                        AddCombatConditional(btn, typeAttr, "target", combatCond)
                    end
                elseif actionType == "focus" or actionType == self.ACTION_TYPES.FOCUS then
                    btn:SetAttribute("type-" .. virtualBtn, "focus")
                elseif actionType == "assist" or actionType == self.ACTION_TYPES.ASSIST then
                    btn:SetAttribute("type-" .. virtualBtn, "assist")
                end
            else
                -- Use macro for all spell/macro bindings
                -- This supports smart res, combat conditionals, fallbacks, etc.
                btn:SetAttribute("type-" .. virtualBtn, "macro")
                btn:SetAttribute("macrotext-" .. virtualBtn, data.macroText)
            end
        end
    end
end

-- Get the suffix for a binding (like Clique's GetBindingPrefixSuffix)
-- For global bindings, returns something like "dfbuttonshiftf" or "dfmouseshift3"
function CC:GetHovercastSuffix(binding)
    local keyString = self:GetBindingKeyString(binding)
    if not keyString then return nil end
    
    -- Parse out modifiers and key
    local mods, key
    
    -- Special case: minus key (conflicts with modifier separator)
    if keyString == "-" then
        key = "-"
        mods = ""
    elseif keyString:sub(-2) == "--" then
        -- Modifier(s) + minus key (e.g., "SHIFT--", "CTRL-ALT--")
        key = "-"
        mods = keyString:sub(1, -3)  -- Strip the trailing "--"
    else
        -- Normal parsing for all other keys
        mods, key = keyString:match("^(.-)([^%-]+)$")
        if mods and mods:sub(-1, -1) == "-" then
            mods = mods:sub(1, -2)
        end
    end
    
    -- Safety check in case parsing still fails
    if not key then return nil end
    
    -- Normalize modifiers (lowercase, no separators)
    local modKey = (mods or ""):lower():gsub("[%-]", "")
    
    -- Check if it's a mouse button
    local buttonNum = key:match("^BUTTON(%d+)$")
    if buttonNum then
        -- Mouse button
        return "dfmouse" .. modKey .. buttonNum
    else
        -- Keyboard/scroll key
        return "dfbutton" .. modKey .. key:lower()
    end
end

-- Build the setup script that sets both attributes AND bindings
-- This is the key insight from Clique: everything happens in one Execute() call
function CC:BuildHovercastSetupScript()
    local lines = {
        "local button = self",  -- Reference to the button
    }
    local clearLines = {
        "local button = self",  -- Must also define button in clear script!
    }
    
    -- Use the unified macro map
    if not self.unifiedMacroMap then
        self.unifiedMacroMap = self:BuildUnifiedMacroMap()
        -- Refresh keyboard bindings on all frames since map was just built
        self:RefreshKeyboardBindings()
    end
    
    -- Track unique bindings to avoid duplicates
    local uniqueKeys = {}
    
    for keyString, data in pairs(self.unifiedMacroMap) do
        local binding = data.templateBinding
        -- Use globalMacroText for global bindings (respects fallback settings only)
        local macroText = data.globalMacroText or data.macroText
        
        if binding.enabled ~= false and macroText then
            -- Check if binding explicitly needs global/onhover handling
            local scope = binding.scope or "unitframes"
            local needsGlobal = (scope == "onhover" or scope == "global")
            
            -- ALSO need global hovercast if binding has mouseover, target or self fallbacks
            -- These fallbacks only work when NOT hovering a frame, so we need
            -- the key binding to be active globally, not just when hovering
            local fallback = binding.fallback or {}
            local hasFallbackThatNeedsGlobal = fallback.mouseover or fallback.target or fallback.selfCast
            
            -- Check for useGlobalBind flag (for items/macros that need to work everywhere)
            local hasGlobalBindFlag = binding.useGlobalBind == true
            
            -- For unitframes scope with target/self fallbacks, we need BOTH:
            -- 1. Frame-specific bindings (handled by WrapScript OnEnter)
            -- 2. Global bindings (for when not hovering any frame)
            
            if needsGlobal or hasFallbackThatNeedsGlobal or hasGlobalBindFlag then
                if self:ShouldBindingLoad(binding) then
                    local suffix = self:GetHovercastSuffix(binding)
                    
                    if keyString and suffix and keyString ~= "" then
                        -- Skip unmodified left/right click (would break normal clicking)
                        if keyString ~= "BUTTON1" and keyString ~= "BUTTON2" then
                            if not uniqueKeys[keyString] then
                                uniqueKeys[keyString] = true
                                
                                -- Set the macro attributes
                                table.insert(lines, string.format(
                                    [[button:SetAttribute("type-%s", "macro")]],
                                    suffix
                                ))
                                table.insert(lines, string.format(
                                    [[button:SetAttribute("macrotext-%s", %q)]],
                                    suffix, macroText
                                ))
                                
                                -- Add clear commands
                                table.insert(clearLines, string.format([[button:SetAttribute("type-%s", nil)]], suffix))
                                table.insert(clearLines, string.format([[button:SetAttribute("macrotext-%s", nil)]], suffix))
                                
                                -- Now add the SetBindingClick call
                                -- Note: SetBindingClick needs frame NAME (string), not frame reference
                                table.insert(lines, string.format(
                                    [[self:SetBindingClick(true, %q, button:GetName(), %q)]],
                                    keyString, suffix
                                ))
                                
                                -- Add clear binding
                                table.insert(clearLines, string.format(
                                    [[self:ClearBinding(%q)]],
                                    keyString
                                ))
                            end
                        end
                    end
                end
            end
        end
    end
    
    return table.concat(lines, "\n"), table.concat(clearLines, "\n")
end

-- Apply global keybindings (for "onhover" and "targetcast" scopes)
-- Uses exact Clique-style approach: Execute() to set both attributes and bindings
function CC:ApplyGlobalBindings()
    if InCombatLockdown() then return end
    
    if not self.db or not self.db.enabled then 
        self:ClearGlobalBindings()
        return 
    end
    
    -- Create the hovercast button if needed
    self:CreateHovercastButton()
    
    if not self.hovercastButton then
        print("|cffff0000DF Error:|r Failed to create on hover button")
        return
    end
    
    -- First clear any existing bindings
    self:ClearGlobalBindings()
    
    -- Build the setup and clear scripts
    local setupScript, clearScript = self:BuildHovercastSetupScript()
    
    -- Store the clear script for later
    self.hovercastButton.clearScript = clearScript
    self.hovercastButton.setupScript = setupScript
    
    -- Execute the setup script to set all the bindings
    -- This runs in a secure environment where SetBindingClick is allowed
    if setupScript and setupScript ~= "" and setupScript ~= "local button = self" then
        -- Check if Execute is available
        if not self.hovercastButton.Execute then
            if self.db.options and self.db.options.debugBindings then
                print("|cff33cc66DF OnHover:|r Hovercast button missing Execute method")
            end
        else
            -- Use pcall in case secure handler isn't working
            local execSuccess = pcall(function()
                self.hovercastButton:Execute(setupScript)
            end)
            
            if not execSuccess then
                print("|cffff9900DandersFrames:|r Warning: Could not execute hovercast setup script")
            end
            
            if execSuccess and self.db.options and self.db.options.debugBindings then
                print("|cff33cc66DF OnHover:|r Executed setup script")
                -- Count and show bindings
                local count = 0
                for line in setupScript:gmatch("[^\n]+") do
                    if line:find("SetBindingClick") then
                        count = count + 1
                    end
                end
                print("|cff33cc66DF OnHover:|r Set " .. count .. " bindings via Execute()")
                
                -- Show the script for debugging
                print("|cff888888Script:|r")
                for line in setupScript:gmatch("[^\n]+") do
                    print("  " .. line)
                end
            end
        end
    else
        if self.db.options and self.db.options.debugBindings then
            print("|cff33cc66DF OnHover:|r No onhover bindings to set")
        end
    end
end

-- Clear all global bindings
function CC:ClearGlobalBindings()
    if InCombatLockdown() then return end
    
    -- Clear using the hovercast button's Execute
    if self.hovercastButton and self.hovercastButton.Execute and self.hovercastButton.clearScript and self.hovercastButton.clearScript ~= "" then
        pcall(function()
            self.hovercastButton:Execute(self.hovercastButton.clearScript)
        end)
    end
    
    -- Also clear legacy global binding buttons
    for i, button in ipairs(self.globalBindingButtons) do
        if button and button.isActive then
            ClearOverrideBindings(button)
            button.isActive = false
            button.bindingKey = nil
        end
    end
end

-- Get the WoW key string for a binding
function CC:GetBindingKeyString(binding)
    local key = ""
    
    -- Add modifiers in WoW's expected order: ALT-CTRL-SHIFT-META
    if binding.modifiers then
        local mods = binding.modifiers:upper()
        if mods:find("ALT") then key = key .. "ALT-" end
        if mods:find("CTRL") then key = key .. "CTRL-" end
        if mods:find("SHIFT") then key = key .. "SHIFT-" end
        if mods:find("META") then key = key .. "META-" end
    end
    
    -- Add the actual key
    if binding.bindType == "mouse" then
        if not binding.button then return nil end
        -- Convert mouse button names to WoW binding format
        local buttonMap = {
            ["LeftButton"] = "BUTTON1",
            ["RightButton"] = "BUTTON2",
            ["MiddleButton"] = "BUTTON3",
            ["Button4"] = "BUTTON4",
            ["Button5"] = "BUTTON5",
        }
        -- Check for Button6-Button31 (gaming mice)
        local mapped = buttonMap[binding.button]
        if not mapped then
            local num = binding.button:match("Button(%d+)")
            if num then
                mapped = "BUTTON" .. num
            else
                mapped = binding.button:upper():gsub("BUTTON", "BUTTON")
            end
        end
        key = key .. mapped
    elseif binding.bindType == "scroll" then
        -- Scroll wheel
        if binding.key == "SCROLLUP" then
            key = key .. "MOUSEWHEELUP"
        elseif binding.key == "SCROLLDOWN" then
            key = key .. "MOUSEWHEELDOWN"
        else
            return nil
        end
    else
        -- Keyboard key
        if not binding.key then return nil end
        key = key .. binding.key
    end
    
    return key
end

-- ============================================================

-- BINDING MANAGEMENT API
-- ============================================================

-- Check if a duplicate binding already exists
-- Returns the index of the duplicate if found, nil otherwise
function CC:FindDuplicateBinding(newBinding, excludeIndex)
    if not self.db or not self.db.bindings then return nil end
    
    for i, existing in ipairs(self.db.bindings) do
        -- Skip the binding we're editing
        if i ~= excludeIndex then
            -- Check if it's the same key combo
            local sameKey = false
            if newBinding.bindType == "mouse" and existing.bindType == "mouse" then
                sameKey = (newBinding.button == existing.button)
            elseif (newBinding.bindType == "key" or newBinding.bindType == "scroll") and 
                   (existing.bindType == "key" or existing.bindType == "scroll") then
                sameKey = (newBinding.key == existing.key)
            end
            
            -- Check if same modifiers
            local sameMods = (newBinding.modifiers or "") == (existing.modifiers or "")
            
            -- Check if same action/spell
            local sameAction = false
            if newBinding.actionType == existing.actionType then
                if newBinding.actionType == CC.ACTION_TYPES.SPELL then
                    -- For spells, check spell name or ID
                    sameAction = (newBinding.spellName and newBinding.spellName == existing.spellName) or
                                 (newBinding.spellId and newBinding.spellId == existing.spellId)
                elseif newBinding.actionType == CC.ACTION_TYPES.MACRO then
                    -- For macros, check macro ID or name
                    sameAction = (newBinding.macroId and newBinding.macroId == existing.macroId) or
                                 (newBinding.macroName and newBinding.macroName == existing.macroName)
                elseif newBinding.actionType == CC.ACTION_TYPES.ITEM then
                    -- For items, check item ID or slot
                    if newBinding.itemType == "slot" and existing.itemType == "slot" then
                        sameAction = (newBinding.itemSlot == existing.itemSlot)
                    else
                        sameAction = (newBinding.itemId and newBinding.itemId == existing.itemId)
                    end
                else
                    -- For other actions (target, menu, etc.), same type is enough
                    sameAction = true
                end
            end
            
            if sameKey and sameMods and sameAction then
                return i
            end
        end
    end
    
    return nil
end

-- Find bindings that use the same key combo but with different actions
-- Returns a table of conflicting bindings (not exact duplicates)
function CC:FindKeyConflicts(newBinding, excludeIndex)
    if not self.db or not self.db.bindings then return {} end
    
    local conflicts = {}
    
    for i, existing in ipairs(self.db.bindings) do
        -- Skip the binding we're editing
        if i ~= excludeIndex then
            -- Check if it's the same key combo
            local sameKey = false
            if newBinding.bindType == "mouse" and existing.bindType == "mouse" then
                sameKey = (newBinding.button == existing.button)
            elseif (newBinding.bindType == "key" or newBinding.bindType == "scroll") and 
                   (existing.bindType == "key" or existing.bindType == "scroll") then
                sameKey = (newBinding.key == existing.key)
            end
            
            -- Check if same modifiers
            local sameMods = (newBinding.modifiers or "") == (existing.modifiers or "")
            
            if sameKey and sameMods then
                table.insert(conflicts, {
                    index = i,
                    binding = existing
                })
            end
        end
    end
    
    return conflicts
end

function CC:AddBinding(bindingData)
    local binding = CopyTable(DEFAULT_BINDING)
    
    -- Copy provided data
    if bindingData then
        for k, v in pairs(bindingData) do
            binding[k] = v
        end
    end
    
    -- Check for duplicates
    local duplicateIndex = self:FindDuplicateBinding(binding)
    if duplicateIndex then
        print("|cffff9900DandersFrames:|r That binding already exists.")
        return nil
    end
    
    table.insert(self.db.bindings, binding)
    self:ApplyBindings()
    
    return #self.db.bindings
end

-- Update a binding
function CC:UpdateBinding(index, bindingData)
    if not index or not self.db.bindings[index] then return false end
    
    -- Create a merged binding to check for duplicates
    local mergedBinding = CopyTable(self.db.bindings[index])
    for k, v in pairs(bindingData) do
        mergedBinding[k] = v
    end
    
    -- Check for duplicates (exclude the binding being updated)
    local duplicateIndex = self:FindDuplicateBinding(mergedBinding, index)
    if duplicateIndex then
        print("|cffff9900DandersFrames:|r That binding already exists.")
        return false
    end
    
    for k, v in pairs(bindingData) do
        self.db.bindings[index][k] = v
    end
    
    self:ApplyBindings()
    return true
end

-- Get all bindings
function CC:GetBindings()
    return self.db.bindings
end

-- Get a single binding
function CC:GetBinding(index)
    return self.db.bindings[index]
end

-- Enable/disable click-casting
-- Static popup for reload confirmation after toggling click-casting
StaticPopupDialogs["DANDERSFRAMES_CLICKCAST_RELOAD"] = {
    text = "Click-casting changes require a UI reload to take effect.\n\nReload now?",
    button1 = "Reload",
    button2 = "Later",
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

function CC:SetEnabled(enabled)
    -- Track whether the state is actually changing (callers may set db.enabled
    -- before calling this, so compare against the profile copy which is the
    -- last value committed by this function)
    local wasEnabled = self.profile and self.profile.options and self.profile.options.enabled

    self.db.enabled = enabled
    if self.profile and self.profile.options then
        self.profile.options.enabled = enabled
    end

    -- Update the header attribute so secure snippets know whether to run
    -- This is critical for allowing Clique/Clicked to work when we're disabled
    if self.header then
        if not InCombatLockdown() then
            self.header:SetAttribute("dfClickCastEnabled", enabled)
        end
    end

    -- Only prompt for reload when the state actually changes.
    -- Prevents a spurious reload popup on every login when the user has
    -- ignored the conflict warning (Clicked coexistence).
    if enabled ~= wasEnabled then
        StaticPopup_Show("DANDERSFRAMES_CLICKCAST_RELOAD")
    end
end

-- Check if click-casting is enabled
function CC:IsEnabled()
    return self.db.enabled
end

-- ============================================================

-- UTILITY FUNCTIONS
-- ============================================================

-- Get display string for a binding's key combination
function CC:GetBindingKeyText(binding, includeCombatState)
    if not binding then return "Unknown" end
    
    local parts = {}
    
    -- Add modifiers (they come in as "shift-ctrl-alt-" format)
    if binding.modifiers and binding.modifiers ~= "" then
        for mod in binding.modifiers:gmatch("(%w+)%-?") do
            table.insert(parts, mod:sub(1,1):upper() .. mod:sub(2))
        end
    end
    
    -- Add button/key based on bind type
    local bindType = binding.bindType or "mouse"
    local keyName
    
    if bindType == "key" then
        -- Keyboard binding
        local key = binding.key or "?"
        keyName = CC.KEY_DISPLAY_NAMES[key] or key
    elseif bindType == "scroll" then
        -- Scroll wheel binding
        local key = binding.key or "?"
        keyName = CC.SCROLL_DISPLAY_NAMES[key] or key
    else
        -- Mouse binding
        keyName = CC.BUTTON_DISPLAY_NAMES[binding.button] or binding.button
    end
    
    table.insert(parts, keyName)
    
    -- Use "+ " (with space) so text can wrap at + symbols
    local result = table.concat(parts, "+ ")
    
    -- Add combat state indicator if requested
    if includeCombatState then
        local combatSetting = binding.combat or "always"
        if combatSetting == "incombat" then
            result = result .. " [C]"
        elseif combatSetting == "outofcombat" then
            result = result .. " [OoC]"
        end
    end
    
    return result
end

-- Get display string for a binding's action (spell name, macro name, etc.)
function CC:GetBindingActionText(binding)
    if not binding then return "Unknown" end
    
    local actionType = binding.actionType
    
    if actionType == self.ACTION_TYPES.SPELL then
        return binding.spellName or "Unknown Spell"
    elseif actionType == self.ACTION_TYPES.MACRO then
        return binding.macroName or "Unknown Macro"
    elseif actionType == self.ACTION_TYPES.ITEM then
        return binding.itemName or "Unknown Item"
    elseif actionType == self.ACTION_TYPES.TARGET then
        return "Target Unit"
    elseif actionType == self.ACTION_TYPES.MENU then
        return "Open Menu"
    elseif actionType == self.ACTION_TYPES.FOCUS then
        return "Focus Unit"
    elseif actionType == self.ACTION_TYPES.FOLLOW then
        return "Follow Unit"
    elseif actionType == self.ACTION_TYPES.ASSIST then
        return "Assist Unit"
    else
        return actionType or "Unknown"
    end
end

-- Get display string for a binding
function CC:GetBindingDisplayString(binding)
    if not binding then return "Unknown" end
    
    local parts = {}
    
    -- Add modifiers (they come in as "shift-ctrl-alt-" format)
    if binding.modifiers and binding.modifiers ~= "" then
        for mod in binding.modifiers:gmatch("(%w+)%-?") do
            table.insert(parts, mod:sub(1,1):upper() .. mod:sub(2))
        end
    end
    
    -- Add button/key based on bind type
    local bindType = binding.bindType or "mouse"
    local keyName
    
    if bindType == "key" then
        local key = binding.key or "?"
        keyName = CC.KEY_DISPLAY_NAMES[key] or key
    elseif bindType == "scroll" then
        local key = binding.key or "?"
        keyName = CC.SCROLL_DISPLAY_NAMES[key] or key
    else
        keyName = CC.BUTTON_DISPLAY_NAMES[binding.button] or binding.button
    end
    
    table.insert(parts, keyName)
    
    return table.concat(parts, " + ")
end

-- Get display string for a binding's action
function CC:GetActionDisplayString(binding)
    if not binding then return "Unknown" end
    
    if binding.actionType == CC.ACTION_TYPES.SPELL then
        -- Get current display name (accounts for talent overrides)
        local displayName = GetSpellDisplayInfo(binding.spellId, binding.spellName)
        return displayName or binding.spellName or "No Spell"
    elseif binding.actionType == CC.ACTION_TYPES.MACRO then
        -- Try to get macro name from stored macro or binding
        if binding.macroId then
            local macro = CC:GetMacroById(binding.macroId)
            if macro then
                return macro.name
            end
        end
        return binding.macroName or "Macro"
    elseif binding.actionType == CC.ACTION_TYPES.ITEM then
        -- Item binding
        if binding.itemType == "slot" then
            return binding.itemName or "Slot " .. (binding.itemSlot or "?")
        else
            return binding.itemName or "Item"
        end
    elseif binding.actionType == CC.ACTION_TYPES.TARGET or binding.actionType == "target" then
        return "Target Unit"
    elseif binding.actionType == CC.ACTION_TYPES.MENU or binding.actionType == "menu" then
        return "Unit Menu"
    elseif binding.actionType == CC.ACTION_TYPES.FOCUS or binding.actionType == "focus" then
        return "Set Focus"
    elseif binding.actionType == CC.ACTION_TYPES.ASSIST or binding.actionType == "assist" then
        return "Assist"
    end
    
    return "Unknown"
end

-- Alias for GetBindingDisplayString
function CC:GetBindingDisplayText(binding)
    return self:GetBindingDisplayString(binding)
end

-- Get spell icon
function CC:GetSpellIcon(spellIdOrName)
    if not spellIdOrName then return nil end
    
    local spellInfo = C_Spell.GetSpellInfo(spellIdOrName)
    if spellInfo then
        return spellInfo.iconID
    end
    
    return nil
end

-- Auto-detect icon from macro body by finding spell names
function CC:GetIconFromMacroBody(macroBody)
    if not macroBody or macroBody == "" then return nil end
    
    -- Common patterns to find spell names in macros
    -- /cast SpellName
    -- /cast [conditions] SpellName
    -- /use SpellName
    -- #showtooltip SpellName
    
    local patterns = {
        "#showtooltip%s+([%w%s:']+)",          -- #showtooltip Spell Name
        "/cast%s+%[?[^%]]*%]?%s*([%w%s:']+)",  -- /cast [conditions] Spell Name
        "/use%s+%[?[^%]]*%]?%s*([%w%s:']+)",   -- /use [conditions] Spell Name
    }
    
    for _, pattern in ipairs(patterns) do
        local spellName = macroBody:match(pattern)
        if spellName then
            -- Clean up the spell name
            spellName = spellName:trim()
            -- Remove any trailing semicolons or conditions
            spellName = spellName:gsub(";.*$", ""):trim()
            spellName = spellName:gsub("%[.*$", ""):trim()
            
            if spellName ~= "" then
                local icon = self:GetSpellIcon(spellName)
                if icon then
                    return icon
                end
            end
        end
    end
    
    return nil
end

-- Close all macro-related dialogs
function CC:CloseAllMacroDialogs()
    if _G["DFMacroEditorDialog"] then _G["DFMacroEditorDialog"]:Hide() end
    if _G["DFImportMacroDialog"] then _G["DFImportMacroDialog"]:Hide() end
    if _G["DFQuickMacroDialog"] then _G["DFQuickMacroDialog"]:Hide() end
    if _G["DFIconPickerDialog"] then _G["DFIconPickerDialog"]:Hide() end
end

-- Search player's spellbook for spells
function CC:SearchSpellbook(searchText)
    local results = {}
    searchText = searchText and searchText:lower() or ""
    
    -- Track spells by displaySpellId, preferring "root" spells over override spells
    -- Root spells are those where baseSpellId != displaySpellId (they're being overridden)
    -- These are preferred because they always exist regardless of talents
    local spellsByDisplayId = {}  -- displaySpellId -> {spell data, isRoot}
    
    -- Get book type
    local bookType = Enum.SpellBookSpellBank.Player
    
    -- Get number of skill lines (tabs)
    local numTabs = C_SpellBook.GetNumSpellBookSkillLines()
    
    for tabIndex = 1, numTabs do
        local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(tabIndex)
        
        if skillLineInfo and not skillLineInfo.shouldHide then
            local offset = skillLineInfo.itemIndexOffset
            local numSlots = skillLineInfo.numSpellBookItems
            
            -- Iterate through spells in this tab
            for i = 1, numSlots do
                local slotIndex = offset + i
                
                local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(slotIndex, bookType)
                
                -- Only include regular spells (not FutureSpell, Flyout, PetAction)
                if spellBookItemInfo and spellBookItemInfo.itemType == Enum.SpellBookItemType.Spell then
                    local isPassive = C_SpellBook.IsSpellBookItemPassive(slotIndex, bookType)
                    local baseSpellId = spellBookItemInfo.spellID
                    
                    -- Use IsSpellInSpellBook with includeOverrides=true to properly detect
                    -- both regular known spells AND override spells (like Chrono Flames)
                    local isKnown = baseSpellId and C_SpellBook.IsSpellInSpellBook and 
                        C_SpellBook.IsSpellInSpellBook(baseSpellId, bookType, true)
                    
                    if baseSpellId and not isPassive and isKnown then
                        -- Get display info which handles override spells (e.g., Living Flame -> Chrono Flames)
                        local displayName, displayIcon, displaySpellId = GetSpellDisplayInfo(baseSpellId, nil)
                        
                        if displayName then
                            -- Find the TRUE root spell using GetBaseSpell
                            -- This handles cases where the spellbook entry itself is an override
                            -- e.g., Chrono Flames (431443) -> Living Flame (361469)
                            local trueRootId = baseSpellId
                            if C_Spell.GetBaseSpell then
                                local baseId = C_Spell.GetBaseSpell(baseSpellId)
                                if baseId and baseId ~= baseSpellId then
                                    trueRootId = baseId
                                end
                            end
                            
                            -- Get spell name for binding (use true root spell)
                            local rootInfo = C_Spell.GetSpellInfo(trueRootId)
                            local baseName = rootInfo and rootInfo.name or displayName
                            
                            -- Check if matches search - search against BOTH base name and override name
                            local matchesSearch = searchText == "" or 
                                displayName:lower():find(searchText, 1, true) or
                                baseName:lower():find(searchText, 1, true)
                            
                            if matchesSearch then
                                -- Determine if this is a "root" spell
                                -- Either the spellbook entry itself is being overridden (baseSpellId != displaySpellId)
                                -- OR the spellbook entry has a deeper root (trueRootId != baseSpellId)
                                local isRoot = (baseSpellId ~= displaySpellId) or (trueRootId ~= baseSpellId)
                                
                                local existing = spellsByDisplayId[displaySpellId]
                                
                                -- Add if we haven't seen this displaySpellId, OR if this is a root spell
                                -- and the existing one isn't (prefer root spells)
                                if not existing or (isRoot and not existing.isRoot) then
                                    spellsByDisplayId[displaySpellId] = {
                                        spell = {
                                            name = baseName,           -- Root spell name for binding
                                            displayName = displayName, -- Override name for display
                                            icon = displayIcon,
                                            spellId = trueRootId,      -- Use true root spell ID
                                        },
                                        isRoot = isRoot,
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Convert to results array
    for displaySpellId, data in pairs(spellsByDisplayId) do
        table.insert(results, data.spell)
    end
    
    -- Sort by name
    table.sort(results, function(a, b) return a.name < b.name end)
    
    -- Limit results to avoid overwhelming the UI
    if #results > 50 then
        local limited = {}
        for i = 1, 50 do
            limited[i] = results[i]
        end
        results = limited
    end
    
    return results
end

-- Get all player spells (for the spell grid)
function CC:GetAllPlayerSpells()
    local results = {}
    
    -- Track spells by displaySpellId, preferring "root" spells over override spells
    -- Root spells are those where baseSpellId != displaySpellId (they're being overridden)
    -- These are preferred because they always exist regardless of talents
    local spellsByDisplayId = {}  -- displaySpellId -> {spell data, isRoot}
    
    -- Get book type
    local bookType = Enum.SpellBookSpellBank.Player
    
    -- Get number of skill lines (tabs)
    local numTabs = C_SpellBook.GetNumSpellBookSkillLines()
    
    -- Get current spec name for identification
    local currentSpecIndex = GetSpecialization()
    local currentSpecName = currentSpecIndex and select(2, GetSpecializationInfo(currentSpecIndex)) or ""
    
    for tabIndex = 1, numTabs do
        local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(tabIndex)
        
        if skillLineInfo and not skillLineInfo.shouldHide then
            local offset = skillLineInfo.itemIndexOffset
            local numSlots = skillLineInfo.numSpellBookItems
            local tabName = skillLineInfo.name or ""
            
            -- Determine category priority (lower = higher priority)
            local categoryPriority = 4 -- Default: other
            local category = "other"
            
            if tabName == currentSpecName then
                categoryPriority = 1
                category = "spec"
            elseif skillLineInfo.isGuildPerkTab then
                categoryPriority = 5
                category = "guild"
            else
                -- Check if it's a class tab (usually the class name)
                local _, className = UnitClass("player")
                local localizedClassName = UnitClass("player")
                if tabName == localizedClassName or tabName == className then
                    categoryPriority = 2
                    category = "class"
                elseif tabName == "Racial" or tabName:find("Racial") then
                    categoryPriority = 3
                    category = "racial"
                elseif tabName == "General" then
                    categoryPriority = 4
                    category = "general"
                end
            end
            
            -- Iterate through spells in this tab
            for i = 1, numSlots do
                local slotIndex = offset + i
                
                -- Get spell book item info first
                local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(slotIndex, bookType)
                
                if spellBookItemInfo then
                    local itemType = spellBookItemInfo.itemType
                    local baseSpellId = spellBookItemInfo.spellID
                    
                    -- Include regular spells only - if it's in spellbook as "Spell" type, it's usable
                    -- Skip FutureSpell (not yet learned), Flyout (spell groups), PetAction
                    if itemType == Enum.SpellBookItemType.Spell and baseSpellId then
                        local isPassive = C_SpellBook.IsSpellBookItemPassive(slotIndex, bookType)
                        
                        -- Use IsSpellInSpellBook with includeOverrides=true to properly detect
                        -- both regular known spells AND override spells (like Chrono Flames)
                        local isKnown = C_SpellBook.IsSpellInSpellBook and 
                            C_SpellBook.IsSpellInSpellBook(baseSpellId, bookType, true)
                        
                        if not isPassive and isKnown then
                            -- Get display info which handles override spells (e.g., Living Flame -> Chrono Flames)
                            local displayName, displayIcon, displaySpellId = GetSpellDisplayInfo(baseSpellId, nil)
                            
                            if displayName then
                                -- Find the TRUE root spell using GetBaseSpell
                                -- This handles cases where the spellbook entry itself is an override
                                -- e.g., Chrono Flames (431443) -> Living Flame (361469)
                                local trueRootId = baseSpellId
                                if C_Spell.GetBaseSpell then
                                    local baseId = C_Spell.GetBaseSpell(baseSpellId)
                                    if baseId and baseId ~= baseSpellId then
                                        trueRootId = baseId
                                    end
                                end
                                
                                -- Get spell name for binding (use true root spell)
                                local rootInfo = C_Spell.GetSpellInfo(trueRootId)
                                local baseName = rootInfo and rootInfo.name or displayName
                                
                                -- Determine if this is a "root" spell
                                -- Either the spellbook entry itself is being overridden (baseSpellId != displaySpellId)
                                -- OR the spellbook entry has a deeper root (trueRootId != baseSpellId)
                                local isRoot = (baseSpellId ~= displaySpellId) or (trueRootId ~= baseSpellId)
                                
                                local existing = spellsByDisplayId[displaySpellId]
                                
                                -- Add if we haven't seen this displaySpellId, OR if this is a root spell
                                -- and the existing one isn't (prefer root spells)
                                if not existing or (isRoot and not existing.isRoot) then
                                    -- When replacing, preserve the better category (lower priority = better)
                                    local useCategory = category
                                    local useCategoryPriority = categoryPriority
                                    local useTabName = tabName
                                    
                                    if existing and isRoot and not existing.isRoot then
                                        -- We're replacing an override spell with a root spell
                                        -- Keep the better category from the override spell if it has one
                                        if existing.spell.categoryPriority < categoryPriority then
                                            useCategory = existing.spell.category
                                            useCategoryPriority = existing.spell.categoryPriority
                                            useTabName = existing.spell.tabName
                                        end
                                    end
                                    
                                    spellsByDisplayId[displaySpellId] = {
                                        spell = {
                                            name = baseName,           -- Root spell name for binding
                                            displayName = displayName, -- Override name for display
                                            icon = displayIcon,
                                            spellId = trueRootId,      -- Use true root spell ID
                                            category = useCategory,
                                            categoryPriority = useCategoryPriority,
                                            tabName = useTabName,
                                        },
                                        isRoot = isRoot,
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Convert to results array
    for displaySpellId, data in pairs(spellsByDisplayId) do
        table.insert(results, data.spell)
    end
    
    -- Sort by category priority first, then by name
    table.sort(results, function(a, b)
        if a.categoryPriority ~= b.categoryPriority then
            return a.categoryPriority < b.categoryPriority
        end
        return a.name < b.name
    end)
    
    return results
end

-- ============================================================
-- MACRO MANAGEMENT FUNCTIONS
-- ============================================================

-- Generate unique macro ID
function CC:GenerateMacroId()
    return "df_macro_" .. time() .. "_" .. math.random(1000, 9999)
end

-- Get all stored macros (custom + imported)
function CC:GetAllMacros(includeAutoGenerated)
    if not self.db or not self.db.customMacros then return {} end
    
    -- By default, hide auto-generated macros from the UI
    if includeAutoGenerated then
        return self.db.customMacros
    end
    
    local visible = {}
    for _, macro in ipairs(self.db.customMacros) do
        if not macro.autoGenerated then
            table.insert(visible, macro)
        end
    end
    return visible
end

-- Get macros filtered by source
function CC:GetMacrosBySource(source, includeAutoGenerated)
    local macros = self:GetAllMacros(includeAutoGenerated)
    if source == "all" then return macros end
    
    local filtered = {}
    for _, macro in ipairs(macros) do
        if macro.source == source then
            table.insert(filtered, macro)
        end
    end
    return filtered
end

-- Get macro by ID (always searches all macros including auto-generated)
function CC:GetMacroById(macroId)
    if not macroId then return nil end
    -- Must include auto-generated macros when looking up by ID
    for _, macro in ipairs(self:GetAllMacros(true)) do
        if macro.id == macroId then
            return macro
        end
    end
    return nil
end

-- Save a macro (create or update)
function CC:SaveMacro(macroData)
    if not self.db.customMacros then self.db.customMacros = {} end
    
    -- If updating existing
    if macroData.id then
        for i, macro in ipairs(self.db.customMacros) do
            if macro.id == macroData.id then
                self.db.customMacros[i] = macroData
                return macroData
            end
        end
    end
    
    -- Creating new
    if not macroData.id then
        macroData.id = self:GenerateMacroId()
    end
    table.insert(self.db.customMacros, macroData)
    return macroData
end

-- Delete a macro
function CC:DeleteMacro(macroId)
    if not self.db.customMacros then return false end
    
    for i, macro in ipairs(self.db.customMacros) do
        if macro.id == macroId then
            -- Also remove any bindings that use this macro
            self:ClearBindingsForMacro(macroId)
            table.remove(self.db.customMacros, i)
            return true
        end
    end
    return false
end

-- Get bindings for a specific macro
function CC:GetBindingsForMacro(macroId)
    local bindings = {}
    if not self.db or not self.db.bindings then return bindings end
    
    for _, binding in ipairs(self.db.bindings) do
        if binding.actionType == CC.ACTION_TYPES.MACRO and binding.macroId == macroId then
            table.insert(bindings, binding)
        end
    end
    return bindings
end

-- Clear all bindings for a macro
function CC:ClearBindingsForMacro(macroId)
    if not self.db or not self.db.bindings then return end
    
    for i = #self.db.bindings, 1, -1 do
        if self.db.bindings[i].actionType == CC.ACTION_TYPES.MACRO and self.db.bindings[i].macroId == macroId then
            table.remove(self.db.bindings, i)
        end
    end
    self:ApplyBindings()
end

-- ============================================================
-- UNIFIED MACRO-BASED BINDING SYSTEM
-- ============================================================
-- All bindings are converted to macros at configuration time.
-- This simplifies the code and provides consistent behavior.
-- Inspired by the Clicked addon's approach.
-- ============================================================

-- Resolve the localized spell name from a spell ID
local function GetLocalizedSpellName(spellId)
    if not spellId then return nil end
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellId)
        return info and info.name
    end
    return nil
end

-- Get the player's available resurrection spells (returns localized names)
function CC:GetPlayerResurrectionSpells()
    local _, playerClass = UnitClass("player")
    local classSpells = self.RESURRECTION_SPELLS[playerClass]
    if not classSpells then return nil end

    local available = {}

    -- Helper to check if spell is known (works with spell ID)
    local function IsSpellAvailable(spellData)
        if not spellData then return false end
        local spellId = spellData.id
        if not spellId then return false end

        -- Use IsSpellInSpellBook with includeOverrides for proper override detection
        if C_SpellBook and C_SpellBook.IsSpellInSpellBook then
            return C_SpellBook.IsSpellInSpellBook(spellId, Enum.SpellBookSpellBank.Player, true)
        end
        return false
    end

    -- Check normal res — resolve localized name from spell ID
    if classSpells.normal and IsSpellAvailable(classSpells.normal) then
        available.normal = GetLocalizedSpellName(classSpells.normal.id) or classSpells.normal.name
    end

    -- Check mass res (healer specs only usually)
    if classSpells.mass and IsSpellAvailable(classSpells.mass) then
        available.mass = GetLocalizedSpellName(classSpells.mass.id) or classSpells.mass.name
    end

    -- Check combat res
    if classSpells.combat and IsSpellAvailable(classSpells.combat) then
        available.combat = GetLocalizedSpellName(classSpells.combat.id) or classSpells.combat.name
    end

    return available
end

-- Check if a spell is already a resurrection spell (locale-safe, uses spell ID)
function CC:IsResurrectionSpell(spellName, spellId)
    if spellId and self.RESURRECTION_SPELL_IDS[spellId] then
        return true
    end
    -- Fallback: resolve spell name to ID and check
    if spellName and C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellName)
        if info and info.spellID and self.RESURRECTION_SPELL_IDS[info.spellID] then
            return true
        end
    end
    return false
end

-- Debug command to test resurrection spell detection
-- Note: If this doesn't work, use /dfrestest instead (defined in Core.lua)
SLASH_DFCCRES1 = "/dfccres"
SlashCmdList["DFCCRES"] = function(msg)
    -- Safety check
    if not CC or not CC.RESURRECTION_SPELL_NAMES then
        print("|cffff0000DF Error:|r ClickCasting module not fully loaded.")
        print("Try using |cff00ff00/dfrestest|r instead for diagnostics.")
        return
    end
    
    local spellName = msg and msg ~= "" and msg or nil
    print("|cff33cc66=== DF Resurrection Spell Debug ===|r")
    
    if spellName then
        local isRes = CC:IsResurrectionSpell(spellName)
        print("Testing spell: |cffffffff" .. spellName .. "|r")
        print("IsResurrectionSpell: " .. (isRes and "|cff00ff00YES|r" or "|cffff0000NO|r"))
        print("Expected condition: " .. (isRes and ",dead" or ",nodead"))
    else
        print("Known resurrection spells:")
        for name, _ in pairs(CC.RESURRECTION_SPELL_NAMES) do
            print("  - " .. name)
        end
        print("")
        print("Usage: /dfccres <spell name>")
        print("Example: /dfccres Resurrection")
    end
    
    -- Also show current bindings with res spells
    if CC.db and CC.db.bindings then
        print("")
        print("Your res spell bindings:")
        local found = false
        for i, binding in ipairs(CC.db.bindings) do
            if binding.spellName and CC:IsResurrectionSpell(binding.spellName) then
                found = true
                print("  " .. (binding.spellName or "?") .. " -> detected as res spell")
            end
        end
        if not found then
            print("  (none found)")
        end
    end
end

-- Build smart resurrection macro parts
-- Returns array of macro condition strings to INSERT AT THE BEGINNING
-- Combat res takes highest priority for dead targets
function CC:GetSmartResurrectionParts(spellName, targetType, mountedStr)
    local mode = self.profile and self.profile.options and self.profile.options.smartResurrection or "disabled"
    mountedStr = mountedStr or ""
    
    -- Debug
    -- print("[DF SmartRes] mode:", mode, "spellName:", spellName, "targetType:", targetType)
    
    if mode == "disabled" then return nil end
    
    -- Don't add smart res to spells that are already resurrection spells
    if self:IsResurrectionSpell(spellName) then return nil end
    
    -- Only apply to friendly targets
    if targetType == "hostile" then return nil end
    
    local resSpells = self:GetPlayerResurrectionSpells()
    if not resSpells then 
        -- print("[DF SmartRes] No res spells available")
        return nil 
    end
    
    -- print("[DF SmartRes] Available res spells - normal:", resSpells.normal or "nil", "mass:", resSpells.mass or "nil", "combat:", resSpells.combat or "nil")
    
    local parts = {}
    
    -- Combat res FIRST (highest priority for dead targets in combat)
    if mode == "normal+combat" and resSpells.combat then
        table.insert(parts, "[@mouseover,help,exists,dead,combat" .. mountedStr .. "] " .. resSpells.combat)
    end
    
    -- Out of combat res (mass res preferred, then normal res)
    if resSpells.mass then
        table.insert(parts, "[@mouseover,help,exists,dead,nocombat" .. mountedStr .. "] " .. resSpells.mass)
    elseif resSpells.normal then
        table.insert(parts, "[@mouseover,help,exists,dead,nocombat" .. mountedStr .. "] " .. resSpells.normal)
    end
    
    if #parts == 0 then return nil end
    
    return parts
end

-- ============================================================
-- ITEM HELPER FUNCTIONS
-- ============================================================

-- Get item info for an equipment slot
function CC:GetSlotItemInfo(slotId)
    local itemId = GetInventoryItemID("player", slotId)
    if itemId then
        local itemName, _, _, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(itemId)
        local spellName = GetItemSpell(itemId)
        return {
            itemId = itemId,
            name = itemName,
            icon = itemIcon,
            hasOnUse = spellName ~= nil,
            onUseSpell = spellName,
        }
    end
    return nil
end

-- Get item info for an item ID (consumables)
function CC:GetItemInfoById(itemId)
    if not itemId then return nil end
    local itemName, _, _, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(itemId)
    if itemName then
        local spellName = GetItemSpell(itemId)
        return {
            itemId = itemId,
            name = itemName,
            icon = itemIcon,
            hasOnUse = spellName ~= nil,
            onUseSpell = spellName,
        }
    end
    return nil
end

-- Get item count in bags
function CC:GetItemCount(itemId)
    if not itemId then return 0 end
    return C_Item.GetItemCount(itemId) or GetItemCount(itemId) or 0
end

-- Build macro text for a single binding
-- This handles all action types and conditions
-- forGlobalBinding: if true, only use fallback settings (not appliesToFrames) for targeting
function CC:BuildMacroTextForBinding(binding, forGlobalBinding)
    if not binding then return nil end
    
    local actionType = binding.actionType or self.ACTION_TYPES.SPELL
    local targetType = binding.targetType or "all"
    local fallback = binding.fallback or {}
    local combatCond = GetCombatCondition(binding)
    
    -- Check if we should add nomounted/noflying condition
    -- noflying catches druid flight form (which isn't considered "mounted")
    local mountedStr = ""
    if self.db and self.db.global and self.db.global.disableWhileMounted then
        mountedStr = ",nomounted,noflying"
    end
    
    -- Build combat condition string
    local combatStr = ""
    if combatCond == "combat" then
        combatStr = ",combat"
    elseif combatCond == "nocombat" then
        combatStr = ",nocombat"
    end
    
    -- Build target type condition (help/harm)
    local targetStr = ""
    if targetType == "friendly" then
        targetStr = ",help"
    elseif targetType == "hostile" then
        targetStr = ",harm"
    end
    
    -- Handle different action types
    if actionType == self.ACTION_TYPES.SPELL then
        -- Resolve current spell name for the active locale.
        -- Bindings store the spell name from the language the client was using at
        -- creation time.  We must re-resolve via spell ID so the macro contains
        -- the name WoW's parser expects on the current client language.
        -- IMPORTANT: Always use the BASE spell name, never the override name.
        -- WoW's /cast command is override-aware and will automatically resolve
        -- base spells to their current form (e.g. /cast Flash of Light will cast
        -- Benediction when the proc is active). Using the override name in the
        -- macro causes "spell not learned" errors when the proc expires.
        local spellName = binding.spellName
        if binding.spellId then
            local localizedName = GetLocalizedSpellName(binding.spellId)
            if localizedName then
                spellName = localizedName
            end
        end
        if not spellName then return nil end
        
        local parts = {}
        
        -- Check if this is a resurrection spell - res spells need "dead" instead of "nodead"
        local isResSpell = self:IsResurrectionSpell(spellName, binding.spellId)
        local lifeCondition = isResSpell and ",dead" or ",nodead"
        
        -- SMART RESURRECTION FIRST (dead targets take priority)
        -- This must come before living target conditions
        -- Skip smart res logic if the spell itself is already a res spell
        if not isResSpell then
            local smartResParts = self:GetSmartResurrectionParts(spellName, targetType, mountedStr)
            if smartResParts then
                for _, part in ipairs(smartResParts) do
                    table.insert(parts, part)
                end
            end
        end
        
        -- Check what fallback options are enabled
        -- For frame click-casting to work, we ALWAYS need @mouseover when binding applies to frames
        -- because WoW sets the frame's unit as mouseover when you hover/click it
        -- BUT for global bindings (when not hovering frames), only use explicit fallback settings
        local frames = binding.frames or { dandersFrames = true, otherFrames = true }
        local appliesToFrames = frames.dandersFrames or frames.otherFrames
        local hasMouseover
        if forGlobalBinding then
            -- Global binding: only include @mouseover if explicitly enabled as fallback
            hasMouseover = fallback.mouseover == true
        else
            -- Frame binding: always need @mouseover for frame click-casting to work
            hasMouseover = appliesToFrames or fallback.mouseover == true
        end
        local hasTarget = fallback.target
        local hasSelf = fallback.selfCast and targetType ~= "hostile"
        
        -- Add mouseover (required for frames, optional fallback for world units)
        -- Use "dead" for res spells, "nodead" for everything else
        if hasMouseover then
            table.insert(parts, "[@mouseover" .. targetStr .. ",exists" .. lifeCondition .. combatStr .. mountedStr .. "] " .. spellName)
        end
        
        -- Target fallback - for when not hovering anything but have a target
        if hasTarget then
            table.insert(parts, "[@target" .. targetStr .. ",exists" .. lifeCondition .. combatStr .. mountedStr .. "] " .. spellName)
        end
        
        -- Self-cast fallback (only for friendly or all targets)
        if hasSelf then
            table.insert(parts, "[@player" .. combatStr .. mountedStr .. "] " .. spellName)
        end
        
        -- If no fallbacks enabled, just cast normally (will use WoW's default targeting)
        if #parts == 0 then
            table.insert(parts, spellName)
        end

        local macroText = "/cast " .. table.concat(parts, "; ")
        local fallbackTbl = binding.fallback or {}
        if fallbackTbl.stopSpellTarget then
            macroText = macroText .. "\n/stopspelltarget"
        end
        return macroText
        
    elseif actionType == self.ACTION_TYPES.MACRO then
        -- For custom macros, just return the macro body
        local macro = self:GetMacroById(binding.macroId)
        if macro and macro.body then
            return macro.body
        end
        return nil
        
    elseif actionType == "target" then
        -- Target action uses native type="target"
        -- This requires the frame to have a "unit" attribute set
        -- For frames without a unit attribute, we need to set unit="mouseover"
        return nil
        
    elseif actionType == "focus" then
        local parts = {}
        local frames = binding.frames or { dandersFrames = true, otherFrames = true }
        local appliesToFrames = frames.dandersFrames or frames.otherFrames
        local hasMouseover
        if forGlobalBinding then
            hasMouseover = fallback.mouseover == true
        else
            hasMouseover = appliesToFrames or fallback.mouseover == true
        end
        if hasMouseover then
            table.insert(parts, "[@mouseover" .. targetStr .. ",exists" .. combatStr .. "]")
        end
        if fallback.target then
            table.insert(parts, "[@target" .. targetStr .. ",exists" .. combatStr .. "]")
        end
        -- If no fallbacks and no frames, default to mouseover for basic functionality
        if #parts == 0 then
            table.insert(parts, "[@mouseover" .. targetStr .. ",exists" .. combatStr .. "]")
        end
        return "/focus " .. table.concat(parts, "; ")
        
    elseif actionType == "assist" then
        local parts = {}
        local frames = binding.frames or { dandersFrames = true, otherFrames = true }
        local appliesToFrames = frames.dandersFrames or frames.otherFrames
        local hasMouseover
        if forGlobalBinding then
            hasMouseover = fallback.mouseover == true
        else
            hasMouseover = appliesToFrames or fallback.mouseover == true
        end
        if hasMouseover then
            table.insert(parts, "[@mouseover" .. targetStr .. ",exists" .. combatStr .. "]")
        end
        if fallback.target then
            table.insert(parts, "[@target" .. targetStr .. ",exists" .. combatStr .. "]")
        end
        -- If no fallbacks and no frames, default to mouseover for basic functionality
        if #parts == 0 then
            table.insert(parts, "[@mouseover" .. targetStr .. ",exists" .. combatStr .. "]")
        end
        return "/assist " .. table.concat(parts, "; ")
        
    elseif actionType == self.ACTION_TYPES.ITEM then
        -- Item binding (equipment slot or consumable)
        if binding.itemType == "slot" then
            -- Equipment slot: /use 13 (slot number)
            local slotNum = binding.itemSlot
            if not slotNum then return nil end
            return "/use " .. slotNum
        else
            -- Consumable item: /use ItemName (prefer name over ID for readability)
            local itemRef = binding.itemName or binding.itemId
            if not itemRef then return nil end
            return "/use " .. itemRef
        end
        
    elseif actionType == "menu" then
        -- Can't do menu via macro, will need special handling
        return nil
    end
    
    return nil
end

-- Build combined macro text for multiple bindings on the same key
-- Groups by target type and combat condition to create optimal macro
function CC:BuildCombinedMacroForBindings(bindings, forGlobalBinding)
    if not bindings or #bindings == 0 then return nil end
    
    -- Categorize bindings
    local friendly = {}
    local hostile = {}
    local any = {}
    
    for _, item in ipairs(bindings) do
        local b = item.binding or item
        if self:ShouldBindingLoad(b) then
            local targetType = b.targetType or "all"
            if targetType == "friendly" then
                table.insert(friendly, b)
            elseif targetType == "hostile" then
                table.insert(hostile, b)
            else
                table.insert(any, b)
            end
        end
    end
    
    -- Sort each category by priority
    local function sortByPriority(a, b)
        return (a.priority or 5) < (b.priority or 5)
    end
    table.sort(friendly, sortByPriority)
    table.sort(hostile, sortByPriority)
    table.sort(any, sortByPriority)
    
    -- Find best spell for each category (first known spell)
    local function findBestSpell(list)
        for _, b in ipairs(list) do
            if b.actionType == self.ACTION_TYPES.SPELL and b.spellName then
                if IsSpellKnownByName and IsSpellKnownByName(b.spellName, b.spellId) then
                    return b
                end
            end
        end
        -- Fallback to first spell even if not confirmed known
        for _, b in ipairs(list) do
            if b.actionType == self.ACTION_TYPES.SPELL and b.spellName then
                return b
            end
        end
        -- Check for macros
        for _, b in ipairs(list) do
            if b.actionType == self.ACTION_TYPES.MACRO then
                return b
            end
        end
        return nil
    end
    
    local friendlyBinding = findBestSpell(friendly)
    local hostileBinding = findBestSpell(hostile)
    local anyBinding = findBestSpell(any)
    
    -- If we only have one type, just build macro for that binding
    if not friendlyBinding and not hostileBinding and anyBinding then
        return self:BuildMacroTextForBinding(anyBinding, forGlobalBinding), anyBinding
    end
    
    -- If we have only friendly or only hostile (no split)
    if friendlyBinding and not hostileBinding and not anyBinding then
        return self:BuildMacroTextForBinding(friendlyBinding, forGlobalBinding), friendlyBinding
    end
    if hostileBinding and not friendlyBinding and not anyBinding then
        return self:BuildMacroTextForBinding(hostileBinding, forGlobalBinding), hostileBinding
    end
    
    -- Build combined help/harm macro
    local parts = {}
    
    -- SMART RESURRECTION FIRST (dead targets take priority)
    -- Check friendly binding first, then any binding
    local smartResSpell = nil
    local smartResTargetType = nil
    if friendlyBinding and friendlyBinding.spellName then
        smartResSpell = friendlyBinding.spellName
        smartResTargetType = "friendly"
    elseif anyBinding and anyBinding.spellName then
        smartResSpell = anyBinding.spellName
        smartResTargetType = "all"
    end
    
    if smartResSpell then
        local smartResParts = self:GetSmartResurrectionParts(smartResSpell, smartResTargetType)
        if smartResParts then
            for _, part in ipairs(smartResParts) do
                table.insert(parts, part)
            end
        end
    end
    
    -- Friendly conditions
    if friendlyBinding and friendlyBinding.spellName then
        local spell = GetLocalizedSpellName(friendlyBinding.spellId) or friendlyBinding.spellName
        local fb = friendlyBinding.fallback or {}
        local combatCond = GetCombatCondition(friendlyBinding)
        local combatStr = combatCond == "combat" and ",combat" or (combatCond == "nocombat" and ",nocombat" or "")
        
        -- Check if this is a resurrection spell
        local isResSpell = CC:IsResurrectionSpell(spell)
        local lifeCondition = isResSpell and ",dead" or ",nodead"
        
        -- Check if binding applies to frames (if so, always need mouseover - unless forGlobalBinding)
        local frames = friendlyBinding.frames or { dandersFrames = true, otherFrames = true }
        local appliesToFrames = frames.dandersFrames or frames.otherFrames
        
        -- Mouseover help (required for frames, optional for world units)
        local hasMouseover = forGlobalBinding and fb.mouseover == true or (not forGlobalBinding and (appliesToFrames or fb.mouseover == true))
        if hasMouseover then
            table.insert(parts, "[@mouseover,help,exists" .. lifeCondition .. combatStr .. "] " .. spell)
        end
        -- Target help fallback
        if fb.target then
            table.insert(parts, "[@target,help,exists" .. lifeCondition .. combatStr .. "] " .. spell)
        end
    end
    
    -- Hostile conditions
    if hostileBinding and hostileBinding.spellName then
        local spell = GetLocalizedSpellName(hostileBinding.spellId) or hostileBinding.spellName
        local fb = hostileBinding.fallback or {}
        local combatCond = GetCombatCondition(hostileBinding)
        local combatStr = combatCond == "combat" and ",combat" or (combatCond == "nocombat" and ",nocombat" or "")

        -- Check if this is a resurrection spell (e.g., Soulstone can be used on hostile? unlikely but consistent)
        local isResSpell = CC:IsResurrectionSpell(spell)
        local lifeCondition = isResSpell and ",dead" or ",nodead"
        
        -- Check if binding applies to frames (if so, always need mouseover - unless forGlobalBinding)
        local frames = hostileBinding.frames or { dandersFrames = true, otherFrames = true }
        local appliesToFrames = frames.dandersFrames or frames.otherFrames
        
        -- Mouseover harm (required for frames, optional for world units)
        local hasMouseover = forGlobalBinding and fb.mouseover == true or (not forGlobalBinding and (appliesToFrames or fb.mouseover == true))
        if hasMouseover then
            table.insert(parts, "[@mouseover,harm,exists" .. lifeCondition .. combatStr .. "] " .. spell)
        end
        -- Target harm fallback (default on for hostile)
        if fb.target ~= false then
            table.insert(parts, "[@target,harm,exists" .. lifeCondition .. combatStr .. "] " .. spell)
        end
    end
    
    -- Any target fallback (no help/harm conditions)
    if anyBinding and anyBinding.spellName then
        local anySpell = GetLocalizedSpellName(anyBinding.spellId) or anyBinding.spellName
        local fb = anyBinding.fallback or {}

        -- Check if this is a resurrection spell
        local isResSpell = CC:IsResurrectionSpell(anySpell)
        local lifeCondition = isResSpell and ",dead" or ",nodead"
        
        -- Check if binding applies to frames (if so, always need mouseover - unless forGlobalBinding)
        local frames = anyBinding.frames or { dandersFrames = true, otherFrames = true }
        local appliesToFrames = frames.dandersFrames or frames.otherFrames
        
        -- Check what fallbacks are enabled for "any" binding
        local hasMouseover = forGlobalBinding and fb.mouseover == true or (not forGlobalBinding and (appliesToFrames or fb.mouseover == true))
        if hasMouseover then
            table.insert(parts, "[@mouseover,exists" .. lifeCondition .. "] " .. anySpell)
        end
        if fb.target then
            table.insert(parts, "[@target,exists" .. lifeCondition .. "] " .. anySpell)
        end
        -- If no specific fallbacks and no frames (or forGlobalBinding with no fallbacks), use empty condition
        if forGlobalBinding then
            if not fb.mouseover and not fb.target then
                table.insert(parts, "[] " .. anySpell)
            end
        else
            if not appliesToFrames and not fb.mouseover and not fb.target then
                table.insert(parts, "[] " .. anySpell)
            end
        end
    end
    
    -- Self-cast as final fallback for friendly
    if friendlyBinding and friendlyBinding.spellName then
        local fb = friendlyBinding.fallback or {}
        if fb.selfCast then
            local friendlySpell = GetLocalizedSpellName(friendlyBinding.spellId) or friendlyBinding.spellName
            local combatCond = GetCombatCondition(friendlyBinding)
            local combatStr = combatCond == "combat" and ",combat" or (combatCond == "nocombat" and ",nocombat" or "")
            table.insert(parts, "[@player" .. combatStr .. "] " .. friendlySpell)
        end
    end
    
    if #parts == 0 then return nil end

    -- Check if any contributing binding has stopSpellTarget enabled
    local useStopSpellTarget = false
    for _, b in ipairs({friendlyBinding, hostileBinding, anyBinding}) do
        if b and b.fallback and b.fallback.stopSpellTarget then
            useStopSpellTarget = true
            break
        end
    end

    local macroText = "/cast " .. table.concat(parts, "; ")
    if useStopSpellTarget then
        macroText = macroText .. "\n/stopspelltarget"
    end
    return macroText, friendlyBinding or hostileBinding or anyBinding
end

-- Process all bindings and build unified macro map
-- Returns: { [keyString] = { macroText = "...", templateBinding = binding } }
function CC:BuildUnifiedMacroMap()
    local macroMap = {}
    
    -- Group all bindings by their key string
    local keyGroups = {}
    for i, binding in ipairs(self.db.bindings) do
        if binding.enabled ~= false then
            local keyString = self:GetBindingKeyString(binding)
            if keyString then
                if not keyGroups[keyString] then
                    keyGroups[keyString] = {}
                end
                table.insert(keyGroups[keyString], {binding = binding, index = i})
            end
        end
    end
    
    -- Build macro for each key group
    for keyString, group in pairs(keyGroups) do
        -- Check if this group contains any special actions or items (these don't combine)
        local specialBinding = nil
        local itemBinding = nil
        for _, item in ipairs(group) do
            local actionType = item.binding.actionType
            if actionType == "target" or actionType == "menu" or 
               actionType == "focus" or actionType == "assist" or
               actionType == self.ACTION_TYPES.MENU or
               actionType == self.ACTION_TYPES.FOCUS or
               actionType == self.ACTION_TYPES.ASSIST then
                specialBinding = item.binding
                break
            elseif actionType == self.ACTION_TYPES.ITEM then
                itemBinding = item.binding
                break
            end
        end
        
        if specialBinding then
            -- Special actions (target, menu, focus, assist) always use native WoW handling
            -- NOTE: We don't add smart res to target action because:
            -- 1. WoW's native type="target" works for cross-instance players
            -- 2. Macro-based targeting (/target) does NOT work for cross-instance players
            -- 3. PreClick handlers can't check unit state (UnitIsDeadOrGhost not available in restricted Lua)
            -- Smart res still works on healing spell bindings - click dead player with heal = casts res
            macroMap[keyString] = {
                macroText = nil,
                templateBinding = specialBinding,
                keyString = keyString,
                isSpecialAction = true,
            }
            
            if self.db.options and self.db.options.debugBindings then
                print("|cff00ff00DF Special:|r " .. keyString .. " -> " .. (specialBinding.actionType or "?"))
            end
        elseif itemBinding then
            -- Item binding - build simple /use macro
            local macroText = self:BuildMacroTextForBinding(itemBinding)
            local globalMacroText = self:BuildMacroTextForBinding(itemBinding, true)
            if macroText then
                macroMap[keyString] = {
                    macroText = macroText,
                    globalMacroText = globalMacroText,
                    templateBinding = itemBinding,
                    keyString = keyString,
                }
                
                if self.db.options and self.db.options.debugBindings then
                    print("|cff00ff00DF Item:|r " .. keyString)
                    print("|cff888888" .. macroText .. "|r")
                end
            end
        else
            -- Normal spell/macro binding - try to build combined macro
            local macroText, templateBinding = self:BuildCombinedMacroForBindings(group)
            local globalMacroText = self:BuildCombinedMacroForBindings(group, true)
            if macroText and templateBinding then
                macroMap[keyString] = {
                    macroText = macroText,
                    globalMacroText = globalMacroText,
                    templateBinding = templateBinding,
                    keyString = keyString,
                }
                
                if self.db.options and self.db.options.debugBindings then
                    print("|cff00ff00DF Macro:|r " .. keyString)
                    print("|cff888888" .. macroText .. "|r")
                end
            end
        end
    end
    
    return macroMap
end

-- ============================================================
-- SIMPLIFIED BINDING APPLICATION
-- ============================================================

-- Apply all bindings to a frame using unified macro approach
-- skipKeyboardUpdate: when true, skip UpdateFrameBindingAttributes (caller will batch it)
function CC:ApplyBindingsToFrameUnified(frame, skipKeyboardUpdate)
    if not frame then return end
    if InCombatLockdown() then return end
    
    -- If click-casting is disabled, restore Blizzard defaults
    if not self.db.enabled then
        self:RestoreBlizzardDefaults(frame)
        return
    end
    
    local frameName = frame:GetName()
    if not frameName then return end

    -- Debug: track when bindings are reapplied (helps diagnose unexpected clears)
    local isHovered = (self.currentHoveredFrame == frame) or (frame.IsMouseOver and frame:IsMouseOver())
    DF:Debug("CLICK", "ApplyBindings %s hovered=%s", frameName, tostring(isHovered))
    if isHovered then
        DF:DebugWarn("CLICK", "ApplyBindings on HOVERED frame %s — bindings may flicker! caller: %s",
            frameName, debugstack(2, 1, 0) or "unknown")
    end

    -- Clear existing bindings first
    self:ClearBindingsFromFrame(frame)
    
    -- Build unified macro map if not already built
    if not self.unifiedMacroMap then
        self.unifiedMacroMap = self:BuildUnifiedMacroMap()
        -- Refresh keyboard bindings on all frames since map was just built
        self:RefreshKeyboardBindings()
    end
    
    -- Check if this frame has ANY bindings that apply to it
    local hasAnyBindings = false
    local isDandersFrame = frame.dfIsDandersFrame == true
    local isBlizzardFrame = frame.dfIsBlizzardFrame == true

    for keyString, data in pairs(self.unifiedMacroMap) do
        local binding = data.templateBinding
        if self:ShouldBindingApplyToFrame(binding, frame) then
            hasAnyBindings = true
            break
        end
    end

    -- If no bindings apply to this frame
    if not hasAnyBindings then
        if isDandersFrame then
            -- For DandersFrames, completely disable clicks when no bindings apply
            -- Our own frames get type1/type2 set in InitializeHeaderChild as a safety net
            if frame.RegisterForClicks then
                frame:RegisterForClicks()  -- Empty = no clicks registered
            end
        else
            -- For Blizzard frames AND third-party addon frames (QUI, ElvUI, etc.),
            -- restore default behavior (target/menu). These frames rely on type1/type2
            -- for basic click-to-target functionality and must not have clicks disabled.
            self:RestoreBlizzardDefaults(frame)
        end
        return
    end
    
    -- Register for clicks based on castOnDown option
    if frame.RegisterForClicks then
        local castOnDown = self.profile and self.profile.options and self.profile.options.castOnDown
        if castOnDown then
            frame:RegisterForClicks("AnyDown")
        else
            frame:RegisterForClicks("AnyUp")
        end
    end

    -- Enable mouse wheel for scroll bindings (like Clique does)
    if frame.EnableMouseWheel then
        frame:EnableMouseWheel(true)
    end
    
    -- Track which base (no modifier) mouse buttons get a binding applied to THIS frame.
    -- Used to restore defaults for uncovered buttons on non-DandersFrames.
    local coveredBaseButtons = {}

    -- Apply each macro binding (these will override defaults where bindings exist)
    for keyString, data in pairs(self.unifiedMacroMap) do
        local binding = data.templateBinding
        
        -- Check if this binding should apply to this frame
        if self:ShouldBindingApplyToFrame(binding, frame) then
            local bindType = binding.bindType or "mouse"
            local actionType = binding.actionType or self.ACTION_TYPES.SPELL
            
            -- Check if this should be treated as a special action
            -- If macroMap has macroText for target (smart res), treat it like a spell macro
            local isSpecialAction = data.isSpecialAction
            if isSpecialAction == nil then
                -- Fallback for backwards compatibility
                isSpecialAction = (actionType == "menu" or actionType == "target" or
                                   actionType == "focus" or actionType == "assist" or
                                   actionType == self.ACTION_TYPES.MENU or 
                                   actionType == self.ACTION_TYPES.FOCUS or
                                   actionType == self.ACTION_TYPES.ASSIST)
            end
            
            -- Check if this is a third-party frame (not DandersFrames or Blizzard)
            local isThirdPartyFrame = not frame.dfIsDandersFrame and not frame.dfIsBlizzardFrame
            
            -- Check if this is a third-party frame that needs virtual button approach
            local needsVirtualBtn = isThirdPartyFrame
            
            if bindType == "mouse" then
                -- Mouse binding: use frame attributes
                local buttonNum = GetButtonNumber(binding.button)
                local modPrefix = BuildModifierPrefix(binding.modifiers)

                -- Track base (no modifier) mouse buttons that get a binding on this frame
                if modPrefix == "" then
                    coveredBaseButtons[buttonNum] = true
                end

                local typeAttr = modPrefix .. "type" .. buttonNum
                local spellAttr = modPrefix .. "spell" .. buttonNum
                local macroAttr = modPrefix .. "macrotext" .. buttonNum
                
                -- Check if this is a third-party frame that needs virtual button approach
                local needsVirtualBtn = isThirdPartyFrame
                
                -- Also need virtual button for META bindings (Mac Command key)
                -- because meta- frame attributes don't work properly on Mac
                local hasMetaMod = binding.modifiers and binding.modifiers:lower():find("meta")
                local needsMetaVirtualBtn = hasMetaMod
                
                if isSpecialAction then
                    -- Use direct attribute types for special actions
                    if actionType == "menu" or actionType == self.ACTION_TYPES.MENU then
                        frame:SetAttribute(typeAttr, "togglemenu")
                        local vBtn
                        if needsVirtualBtn or needsMetaVirtualBtn then
                            vBtn = self:GetVirtualButtonName(binding)
                            frame:SetAttribute("type-" .. vBtn, "togglemenu")
                        end
                        -- BUG #10 FIX: state-driver-based combat conditional
                        local combatCond = GetCombatCondition(binding)
                        if combatCond then
                            AddCombatConditional(frame, typeAttr, "togglemenu", combatCond)
                            if vBtn then
                                AddCombatConditional(frame, "type-" .. vBtn, "togglemenu", combatCond)
                            end
                        end
                    elseif actionType == "target" then
                        frame:SetAttribute(typeAttr, "target")
                        -- For Blizzard frames, also set unit="mouseover" to ensure targeting works.
                        -- Native type="target" uses the frame's unit attribute, but some frames
                        -- may not have it properly accessible.
                        if frame.dfIsBlizzardFrame then
                            local unitAttr = modPrefix .. "unit" .. buttonNum
                            frame:SetAttribute(unitAttr, "mouseover")
                        end
                        local vBtn
                        if needsVirtualBtn or needsMetaVirtualBtn then
                            vBtn = self:GetVirtualButtonName(binding)
                            frame:SetAttribute("type-" .. vBtn, "target")
                            frame:SetAttribute("unit-" .. vBtn, "mouseover")
                        end
                        -- BUG #860 FIX: state-driver-based combat conditional
                        local combatCond = GetCombatCondition(binding)
                        if combatCond then
                            AddCombatConditional(frame, typeAttr, "target", combatCond)
                            if vBtn then
                                AddCombatConditional(frame, "type-" .. vBtn, "target", combatCond)
                            end
                        end
                    elseif actionType == "focus" or actionType == self.ACTION_TYPES.FOCUS then
                        frame:SetAttribute(typeAttr, "focus")
                        if needsVirtualBtn or needsMetaVirtualBtn then
                            local virtualBtn = self:GetVirtualButtonName(binding)
                            frame:SetAttribute("type-" .. virtualBtn, "focus")
                        end
                    elseif actionType == "assist" or actionType == self.ACTION_TYPES.ASSIST then
                        frame:SetAttribute(typeAttr, "assist")
                        if needsVirtualBtn or needsMetaVirtualBtn then
                            local virtualBtn = self:GetVirtualButtonName(binding)
                            frame:SetAttribute("type-" .. virtualBtn, "assist")
                        end
                    end
                else
                    -- Use macro for all spell/macro/target bindings
                    -- This supports smart res, combat conditionals, fallbacks, etc.
                    frame:SetAttribute(typeAttr, "macro")
                    frame:SetAttribute(macroAttr, data.macroText)
                    
                    -- For third-party frames OR META bindings, also set virtual button attributes
                    -- META bindings need this because meta- frame attributes don't work on Mac
                    if needsVirtualBtn or needsMetaVirtualBtn then
                        local virtualBtn = self:GetVirtualButtonName(binding)
                        frame:SetAttribute("type-" .. virtualBtn, "macro")
                        frame:SetAttribute("macrotext-" .. virtualBtn, data.macroText)
                    end
                end
                
            elseif bindType == "key" or bindType == "scroll" then
                -- Keyboard/scroll: use virtual button approach
                local virtualBtn = self:GetVirtualButtonName(binding)
                
                if isSpecialAction then
                    if actionType == "menu" or actionType == self.ACTION_TYPES.MENU then
                        local typeAttr = "type-" .. virtualBtn
                        frame:SetAttribute(typeAttr, "togglemenu")
                        -- BUG #10 FIX: state-driver-based combat conditional
                        local combatCond = GetCombatCondition(binding)
                        if combatCond then
                            AddCombatConditional(frame, typeAttr, "togglemenu", combatCond)
                        end
                    elseif actionType == "target" then
                        local typeAttr = "type-" .. virtualBtn
                        frame:SetAttribute(typeAttr, "target")
                        -- Mirror the mouse path: only set unit="mouseover" on
                        -- Blizzard / third-party frames, where the frame's main
                        -- "unit" attribute may not be reliably exposed.
                        -- DandersFrames already have a real unit token (party1,
                        -- raid3, etc.) on their "unit" attribute — the secure
                        -- target action picks that up and targets via the unit
                        -- token, which works at any range. Forcing unit-virtualBtn
                        -- to "mouseover" routed through name-based targeting and
                        -- reintroduced the /target out-of-range limitation.
                        if not frame.dfIsDandersFrame then
                            frame:SetAttribute("unit-" .. virtualBtn, "mouseover")
                        end
                        -- BUG #860 FIX: state-driver-based combat conditional
                        local combatCond = GetCombatCondition(binding)
                        if combatCond then
                            AddCombatConditional(frame, typeAttr, "target", combatCond)
                        end
                    elseif actionType == "focus" or actionType == self.ACTION_TYPES.FOCUS then
                        frame:SetAttribute("type-" .. virtualBtn, "focus")
                    elseif actionType == "assist" or actionType == self.ACTION_TYPES.ASSIST then
                        frame:SetAttribute("type-" .. virtualBtn, "assist")
                    end
                else
                    -- Use macro for all spell/macro bindings
                    frame:SetAttribute("type-" .. virtualBtn, "macro")
                    frame:SetAttribute("macrotext-" .. virtualBtn, data.macroText)
                end
            end
        end
    end
    
    -- For non-DandersFrames, restore default behavior for any base mouse buttons
    -- that weren't covered by a binding on this frame. ClearBlizzardClickCastFromFrame
    -- wipes type1/type2 to "" when ANY binding targets other frames, but individual
    -- bindings may be DandersFrames-only. Without this, right-click menu (or left-click
    -- target) breaks on Blizzard frames when the binding doesn't apply to them.
    if not isDandersFrame then
        local defaults = { [1] = "target", [2] = "togglemenu" }
        for btn, defaultType in pairs(defaults) do
            if not coveredBaseButtons[btn] then
                local currentType = frame:GetAttribute("type" .. btn)
                if not currentType or currentType == "" then
                    frame:SetAttribute("type" .. btn, defaultType)
                end
            end
        end
    end

    -- Mark this frame as having had bindings applied (for optimization in ClearBindingsFromFrame)
    frame.dfBindingsEverApplied = true

    -- Debug: confirm final attribute state after apply
    local finalType1 = frame:GetAttribute("type1")
    local finalMacro1 = frame:GetAttribute("macrotext1")
    DF:Debug("CLICK", "ApplyBindings DONE %s type1=%s macro1=%s",
        frameName, tostring(finalType1), finalMacro1 and finalMacro1:sub(1, 50) or "nil")

    -- Update keyboard binding snippet for WrapScript to use
    -- Skip when caller will batch-refresh all frames (e.g. ApplyBindings)
    if not skipKeyboardUpdate then
        self:UpdateFrameBindingAttributes(frame)
    end
end

-- ============================================================

-- AUTO-GENERATED MACROS FOR HELP/HARM SPLITS
-- ============================================================

-- Check if two combat conditions can overlap (both could be active at same time)
function CC:CombatConditionsOverlap(combat1, combat2)
    -- nil or "always" means active in all states
    local c1 = combat1 or "always"
    local c2 = combat2 or "always"
    
    -- If either is "always", they overlap
    if c1 == "always" or c2 == "always" then
        return true
    end
    
    -- "combat" and "nocombat" never overlap
    if (c1 == "combat" and c2 == "nocombat") or (c1 == "nocombat" and c2 == "combat") then
        return false
    end
    
    -- Same condition = overlap
    return true
end

-- Build macro body for a help/harm split
-- Now accepts full binding objects to access fallback settings
function CC:BuildHelpHarmMacroBody(friendlyBinding, hostileBinding, anyBinding)
    local parts = {}
    
    -- Friendly spell with [help] condition
    if friendlyBinding and friendlyBinding.spellName then
        local spellName = GetLocalizedSpellName(friendlyBinding.spellId) or friendlyBinding.spellName
        local fallback = friendlyBinding.fallback or {}
        local combatCond = GetCombatCondition(friendlyBinding)

        -- Check if this is a resurrection spell
        local isResSpell = self:IsResurrectionSpell(spellName, friendlyBinding.spellId)
        local lifeCondition = isResSpell and ",dead" or ",nodead"
        
        -- Build combat condition string for reuse
        local combatStr = ""
        if combatCond == "combat" then
            combatStr = ",combat"
        elseif combatCond == "nocombat" then
            combatStr = ",nocombat"
        end
        
        -- Mouseover help (primary)
        table.insert(parts, "[@mouseover,help" .. lifeCondition .. combatStr .. "] " .. spellName)
        
        -- Target help fallback (if enabled)
        if fallback.target then
            table.insert(parts, "[@target,help" .. lifeCondition .. combatStr .. "] " .. spellName)
        end
    end
    
    -- Hostile spell with [harm] condition
    if hostileBinding and hostileBinding.spellName then
        local spellName = GetLocalizedSpellName(hostileBinding.spellId) or hostileBinding.spellName
        local fallback = hostileBinding.fallback or {}
        local combatCond = GetCombatCondition(hostileBinding)

        -- Check if this is a resurrection spell
        local isResSpell = self:IsResurrectionSpell(spellName, hostileBinding.spellId)
        local lifeCondition = isResSpell and ",dead" or ",nodead"
        
        -- Build combat condition string for reuse
        local combatStr = ""
        if combatCond == "combat" then
            combatStr = ",combat"
        elseif combatCond == "nocombat" then
            combatStr = ",nocombat"
        end
        
        -- Mouseover harm (primary)
        table.insert(parts, "[@mouseover,harm" .. lifeCondition .. combatStr .. "] " .. spellName)
        
        -- Target harm fallback (if enabled OR by default for hostile spells)
        if fallback.target ~= false then  -- Default true for hostile
            table.insert(parts, "[@target,harm" .. lifeCondition .. combatStr .. "] " .. spellName)
        end
    end
    
    -- Any target fallback
    if anyBinding and anyBinding.spellName then
        local anySpell = GetLocalizedSpellName(anyBinding.spellId) or anyBinding.spellName
        table.insert(parts, "[] " .. anySpell)
    end

    -- Self-cast fallback for friendly spell (at the very end)
    if friendlyBinding and friendlyBinding.spellName then
        local fallback = friendlyBinding.fallback or {}
        if fallback.selfCast then
            local friendlySpell = GetLocalizedSpellName(friendlyBinding.spellId) or friendlyBinding.spellName
            local combatCond = GetCombatCondition(friendlyBinding)
            local combatStr = ""
            if combatCond == "combat" then
                combatStr = ",combat"
            elseif combatCond == "nocombat" then
                combatStr = ",nocombat"
            end
            table.insert(parts, "[@player" .. combatStr .. "] " .. friendlySpell)
        end
    end

    -- Check if any contributing binding has stopSpellTarget enabled
    local useStopSpellTarget = false
    for _, b in ipairs({friendlyBinding, hostileBinding, anyBinding}) do
        if b and b.fallback and b.fallback.stopSpellTarget then
            useStopSpellTarget = true
            break
        end
    end

    local macroText = "/cast " .. table.concat(parts, "; ")
    if useStopSpellTarget then
        macroText = macroText .. "\n/stopspelltarget"
    end
    return macroText
end

-- Get or create an auto-generated macro for a specific key combination
function CC:GetOrCreateAutoMacro(keyIdentifier, macroBody)
    if not self.db.customMacros then self.db.customMacros = {} end
    
    local autoMacroName = "_auto_" .. keyIdentifier:gsub("[^%w]", "_")
    
    -- Look for existing auto-macro with this name
    for i, macro in ipairs(self.db.customMacros) do
        if macro.autoGenerated and macro.name == autoMacroName then
            -- Update body if changed
            if macro.body ~= macroBody then
                macro.body = macroBody
            end
            return macro
        end
    end
    
    -- Create new auto-macro
    local newMacro = {
        id = self:GenerateMacroId(),
        name = autoMacroName,
        body = macroBody,
        icon = nil,
        autoGenerated = true,
        keyIdentifier = keyIdentifier,
    }
    table.insert(self.db.customMacros, newMacro)
    
    if self.db.options and self.db.options.debugBindings then
        print("|cff00ff00DF Auto-Macro:|r Created '" .. autoMacroName .. "'")
        print("|cff888888Body:|r " .. macroBody)
    end
    
    return newMacro
end

-- Cleanup orphaned auto-macros that are no longer needed
function CC:CleanupOrphanedAutoMacros(neededAutoMacroIds)
    if not self.db.customMacros then return end
    
    for i = #self.db.customMacros, 1, -1 do
        local macro = self.db.customMacros[i]
        if macro.autoGenerated and not neededAutoMacroIds[macro.id] then
            if self.db.options and self.db.options.debugBindings then
                print("|cff00ff00DF Auto-Macro:|r Removed orphaned '" .. macro.name .. "'")
            end
            table.remove(self.db.customMacros, i)
        end
    end
end

-- Helper to find best known spell binding from a list
function CC:FindBestKnownSpellBinding(bindings)
    -- Sort by priority first
    table.sort(bindings, function(a, b)
        return (a.binding.priority or 5) < (b.binding.priority or 5)
    end)
    
    for _, item in ipairs(bindings) do
        local b = item.binding
        if b.actionType == self.ACTION_TYPES.SPELL and b.spellName then
            if IsSpellKnownByName(b.spellName, b.spellId) then
                return b
            end
        end
    end
    
    -- Fallback to first spell even if not known
    for _, item in ipairs(bindings) do
        local b = item.binding
        if b.actionType == self.ACTION_TYPES.SPELL and b.spellName then
            return b
        end
    end
    
    return nil
end


-- Get WoW global macros
function CC:GetWoWGlobalMacros()
    local macros = {}
    local numGlobal, numPerChar = GetNumMacros()
    
    for i = 1, numGlobal do
        local name, icon, body = GetMacroInfo(i)
        if name then
            table.insert(macros, {
                wowIndex = i,
                name = name,
                icon = icon,
                body = body,
                macroType = "global",
            })
        end
    end
    return macros
end

-- Get WoW character macros
function CC:GetWoWCharacterMacros()
    local macros = {}
    local numGlobal, numPerChar = GetNumMacros()
    
    -- Character macros start after global ones (index 121+)
    local startIndex = MAX_ACCOUNT_MACROS + 1
    for i = startIndex, startIndex + numPerChar - 1 do
        local name, icon, body = GetMacroInfo(i)
        if name then
            table.insert(macros, {
                wowIndex = i,
                name = name,
                icon = icon,
                body = body,
                macroType = "character",
            })
        end
    end
    return macros
end

-- Import a WoW macro (creates a copy in our storage)
function CC:ImportWoWMacro(wowMacro)
    local source = wowMacro.macroType == "global" and "global_import" or "char_import"
    
    -- Check if already imported
    for _, existing in ipairs(self:GetAllMacros()) do
        if existing.originalName == wowMacro.name and existing.source == source then
            -- Update existing import
            existing.body = wowMacro.body
            existing.icon = wowMacro.icon
            existing.lastSynced = time()
            return existing, "updated"
        end
    end
    
    -- Create new import
    local newMacro = {
        id = self:GenerateMacroId(),
        name = wowMacro.name,
        icon = wowMacro.icon,
        body = wowMacro.body,
        source = source,
        originalName = wowMacro.name,
        lastSynced = time(),
    }
    
    return self:SaveMacro(newMacro), "imported"
end

-- Sync an imported macro with its WoW original
function CC:SyncImportedMacro(macroId)
    local macro = self:GetMacroById(macroId)
    if not macro or not macro.originalName then return false, "Not an imported macro" end
    
    local wowMacros
    if macro.source == "global_import" then
        wowMacros = self:GetWoWGlobalMacros()
    else
        wowMacros = self:GetWoWCharacterMacros()
    end
    
    for _, wowMacro in ipairs(wowMacros) do
        if wowMacro.name == macro.originalName then
            macro.body = wowMacro.body
            macro.icon = wowMacro.icon
            macro.lastSynced = time()
            return true, "Synced successfully"
        end
    end
    
    return false, "Original macro not found"
end

-- Check if an imported macro is out of sync
function CC:IsMacroOutOfSync(macroId)
    local macro = self:GetMacroById(macroId)
    if not macro or not macro.originalName then return false end
    
    local wowMacros
    if macro.source == "global_import" then
        wowMacros = self:GetWoWGlobalMacros()
    else
        wowMacros = self:GetWoWCharacterMacros()
    end
    
    for _, wowMacro in ipairs(wowMacros) do
        if wowMacro.name == macro.originalName then
            return wowMacro.body ~= macro.body
        end
    end
    
    -- Original not found - definitely out of sync
    return true
end

-- Convert an imported macro to a custom one (breaks link to original)
function CC:ConvertToCustomMacro(macroId)
    local macro = self:GetMacroById(macroId)
    if not macro then return false end
    
    macro.source = "custom"
    macro.originalName = nil
    macro.lastSynced = nil
    return true
end

-- Quick macro builder - generate macro text from spell and pattern
function CC:BuildQuickMacro(spellName, pattern, options)
    options = options or {}
    local lines = {}
    
    if options.showTooltip ~= false then
        table.insert(lines, "#showtooltip")
    end
    
    if options.stopCasting then
        table.insert(lines, "/stopcasting")
    end
    
    -- Check if this is a resurrection spell
    local isResSpell = self:IsResurrectionSpell(spellName)
    local lifeCondition = isResSpell and "dead" or "nodead"
    
    local conditions = ""
    if pattern == "mouseover_target_self" then
        conditions = "[@mouseover,help," .. lifeCondition .. "][@target,help," .. lifeCondition .. "][@player]"
    elseif pattern == "mouseover_only" then
        conditions = "[@mouseover,help," .. lifeCondition .. "]"
    elseif pattern == "focus_mouseover_target" then
        conditions = "[@focus,help," .. lifeCondition .. "][@mouseover,help," .. lifeCondition .. "][@target,help," .. lifeCondition .. "]"
    elseif pattern == "mouseover_target" then
        conditions = "[@mouseover,help," .. lifeCondition .. "][@target,help," .. lifeCondition .. "]"
    elseif pattern == "harm_mouseover_target" then
        conditions = "[@mouseover,harm," .. lifeCondition .. "][@target,harm," .. lifeCondition .. "]"
    elseif pattern == "custom" and options.customConditions then
        conditions = options.customConditions
    end
    
    table.insert(lines, "/cast " .. conditions .. " " .. spellName)
    
    return table.concat(lines, "\n")
end

-- Common icon IDs for the icon picker
CC.COMMON_MACRO_ICONS = {
    -- Question mark / default
    134400, -- INV_Misc_QuestionMark
    -- Healing
    135915, -- Spell_Holy_FlashHeal
    135913, -- Spell_Holy_GreaterHeal  
    136041, -- Spell_Holy_Renew
    135907, -- Spell_Holy_HolyBolt
    -- Damage
    135812, -- Spell_Fire_FireBolt02
    135846, -- Spell_Shadow_ShadowBolt
    136197, -- Spell_Frost_FrostBolt02
    136048, -- Spell_Nature_Lightning
    -- Utility
    135894, -- Spell_Holy_DispelMagic
    136071, -- Spell_Nature_RemoveCurse
    135996, -- Spell_Nature_NullifyDisease
    135886, -- Spell_Holy_Resurrection
    -- Buffs
    135932, -- Spell_Holy_PowerWordFortitude
    135987, -- Spell_Nature_Regeneration
    135933, -- Spell_Holy_PowerWordShield
    136085, -- Spell_Nature_Slow
    -- Combat
    132355, -- Ability_Warrior_Charge
    132337, -- Ability_Rogue_Sprint
    132351, -- Ability_Vanish
    132336, -- Ability_Kick
    -- Misc
    136243, -- Spell_Nature_Polymorph
    136175, -- Spell_Frost_FreezingBreath
    135736, -- Spell_Holy_SealOfMight
    135940, -- Spell_Holy_SurgeOfLight
    132320, -- Ability_DualWield
    134414, -- INV_Misc_Bag_10
    133784, -- INV_Potion_54
    136235, -- Spell_Nature_TimeStop
}

-- ============================================================
-- DEBUG SLASH COMMAND
-- ============================================================

SLASH_DFSPELLDUMP1 = "/dfspelldump"
SlashCmdList["DFSPELLDUMP"] = function(msg)
    local searchTerm = msg and msg:lower() or ""
    print("|cff33cc66=== DF Spellbook Dump ===|r")
    if searchTerm ~= "" then
        print("|cff33cc66Filtering for:|r " .. searchTerm)
    end
    
    local bookType = Enum.SpellBookSpellBank.Player
    local numTabs = C_SpellBook.GetNumSpellBookSkillLines()
    print("|cff33cc66Total tabs:|r " .. numTabs)
    
    local totalSpells = 0
    local matchedSpells = 0
    
    for tabIndex = 1, numTabs do
        local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(tabIndex)
        if skillLineInfo then
            local offset = skillLineInfo.itemIndexOffset
            local numSlots = skillLineInfo.numSpellBookItems
            local tabName = skillLineInfo.name or "Unknown"
            local shouldHide = skillLineInfo.shouldHide
            
            print("|cffaaaaaa--- Tab " .. tabIndex .. ": " .. tabName .. " (slots: " .. numSlots .. ", hide: " .. tostring(shouldHide) .. ") ---|r")
            
            for i = 1, numSlots do
                local slotIndex = offset + i
                local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(slotIndex, bookType)
                
                if spellBookItemInfo then
                    local baseSpellId = spellBookItemInfo.spellID
                    local itemType = spellBookItemInfo.itemType
                    local itemTypeName = "Unknown"
                    
                    if itemType == Enum.SpellBookItemType.Spell then
                        itemTypeName = "Spell"
                    elseif itemType == Enum.SpellBookItemType.FutureSpell then
                        itemTypeName = "FutureSpell"
                    elseif itemType == Enum.SpellBookItemType.Flyout then
                        itemTypeName = "Flyout"
                    elseif itemType == Enum.SpellBookItemType.PetAction then
                        itemTypeName = "PetAction"
                    end
                    
                    local spellInfo = baseSpellId and C_Spell.GetSpellInfo(baseSpellId)
                    local spellName = spellInfo and spellInfo.name or "nil"
                    
                    -- Check for override
                    local overrideId = baseSpellId and C_Spell.GetOverrideSpell and C_Spell.GetOverrideSpell(baseSpellId)
                    local overrideName = nil
                    if overrideId and overrideId ~= baseSpellId then
                        local overrideInfo = C_Spell.GetSpellInfo(overrideId)
                        overrideName = overrideInfo and overrideInfo.name
                    end
                    
                    local isPassive = C_SpellBook.IsSpellBookItemPassive(slotIndex, bookType)
                    local isKnown = baseSpellId and C_SpellBook.IsSpellInSpellBook and 
                        C_SpellBook.IsSpellInSpellBook(baseSpellId, bookType, true)
                    
                    -- Check if matches search
                    local matchesSearch = searchTerm == "" or 
                        (spellName and spellName:lower():find(searchTerm, 1, true)) or
                        (overrideName and overrideName:lower():find(searchTerm, 1, true))
                    
                    totalSpells = totalSpells + 1
                    
                    if matchesSearch then
                        matchedSpells = matchedSpells + 1
                        local color = isKnown and "|cff00ff00" or "|cffff0000"
                        local passiveStr = isPassive and " [PASSIVE]" or ""
                        local overrideStr = overrideName and (" -> |cffff00ff" .. overrideName .. "|r") or ""
                        print(color .. spellName .. "|r (ID: " .. tostring(baseSpellId) .. ", Type: " .. itemTypeName .. ", Known: " .. tostring(isKnown) .. passiveStr .. ")" .. overrideStr)
                    end
                end
            end
        end
    end
    
    print("|cff33cc66=== Total: " .. totalSpells .. " spells, Matched: " .. matchedSpells .. " ===|r")
end

-- ============================================================
-- CLICK CASTING DEBUG TOOLS
-- ============================================================

-- Debug: Toggle debug mode
SLASH_DFCCDEBUG1 = "/dfccdebug"
SlashCmdList["DFCCDEBUG"] = function()
    CC.debugMode = not CC.debugMode
    if CC.debugMode then
        print("|cff33cc66[DF Click Casting]|r Debug mode |cff00ff00ENABLED|r")
        print("  You will now see debug messages in chat.")
    else
        print("|cff33cc66[DF Click Casting]|r Debug mode |cffff0000DISABLED|r")
    end
end

-- Debug: Show current mouseover state
SLASH_DFCCMOUSEOVER1 = "/dfccmouseover"
SlashCmdList["DFCCMOUSEOVER"] = function()
    print("|cff33cc66=== DF Click Cast Mouseover Debug ===|r")
    
    -- Check WoW's mouseover
    local moUnit = UnitExists("mouseover") and "mouseover" or nil
    local moName = moUnit and UnitName("mouseover") or "none"
    local moGUID = moUnit and UnitGUID("mouseover") or "none"
    print("WoW mouseover unit: " .. (moUnit or "nil") .. " (" .. moName .. ")")
    print("WoW mouseover GUID: " .. moGUID)
    
    -- Check what frame is under mouse
    local focus = GetMouseFocus and GetMouseFocus()
    if not focus and GetMouseFoci then
        local foci = GetMouseFoci()
        focus = foci and foci[1]
    end
    
    if focus then
        local frameName = focus:GetName() or "unnamed"
        local frameUnit = (focus.GetAttribute and focus:GetAttribute("unit")) or focus.unit or "none"
        local frameType = focus:GetObjectType()
        print("Frame under mouse: " .. frameName .. " (" .. frameType .. ")")
        print("Frame unit attr: " .. tostring(frameUnit))
        
        -- Check if it's a registered frame
        local isRegistered = CC.registeredFrames and CC.registeredFrames[focus]
        print("Is registered: " .. tostring(isRegistered))
        
        -- Check if secure OnEnter snippet actually ran (it sets these attributes)
        if focus.GetAttribute then
            local secureRan = focus:GetAttribute("dfSecureOnEnterRan")
            local secureBindingsSet = focus:GetAttribute("dfSecureBindingsSet")
            print("|cffff9900dfSecureOnEnterRan:|r " .. tostring(secureRan))
            print("|cffff9900dfSecureBindingsSet:|r " .. tostring(secureBindingsSet))
            if not secureRan then
                print("|cffff0000WARNING: Secure OnEnter snippet has NOT run on this frame!|r")
            elseif secureRan == "disabled" then
                print("|cffff0000WARNING: Snippet ran but dfClickCastEnabled was false!|r")
            end
            
            -- Show the binding snippet stored on the frame (Cell approach)
            local bindingSnippet = focus:GetAttribute("dfBindingSnippet")
            if bindingSnippet and bindingSnippet ~= "" then
                print("|cff00ff00--- Frame Binding Snippet (Cell-style) ---")
                local bindCount = 0
                for _ in bindingSnippet:gmatch("SetBindingClick") do
                    bindCount = bindCount + 1
                end
                print("|cff00ff00SetBindingClick calls: " .. bindCount .. "|r")
                print(bindingSnippet)
                print("--- End Snippet ---|r")
            else
                print("|cffff6666No dfBindingSnippet set on frame|r")
            end
            
            -- Show _onenter attribute
            local onenter = focus:GetAttribute("_onenter")
            if onenter then
                print("|cff00ff00_onenter attribute IS set|r")
            else
                print("|cffff6666_onenter attribute NOT set - frame may not support SecureHandlerEnterLeaveTemplate|r")
            end
        end
        
        -- Show the OnEnter snippet from header (old approach, for reference)
        if CC.header then
            local headerSnippet = CC.header:GetAttribute("df_setup_onenter")
            local dfEnabled = CC.header:GetAttribute("dfClickCastEnabled")
            print("|cff00ff00dfClickCastEnabled on header:|r " .. tostring(dfEnabled))
            
            if headerSnippet and headerSnippet ~= "" then
                print("|cff00ff00--- Header OnEnter Snippet ---")
                -- Count SetBindingClick calls
                local bindCount = 0
                for _ in headerSnippet:gmatch("SetBindingClick") do
                    bindCount = bindCount + 1
                end
                print("|cff00ff00SetBindingClick calls in snippet: " .. bindCount .. "|r")
                
                -- Show snippet (truncate middle if too long)
                if #headerSnippet > 1500 then
                    print(headerSnippet:sub(1, 700))
                    print("|cffff6666... (" .. (#headerSnippet - 1400) .. " chars omitted) ...|r")
                    print(headerSnippet:sub(-700))
                else
                    print(headerSnippet)
                end
                print("--- End Snippet ---|r")
            else
                print("|cffff6666No df_setup_onenter set on header|r")
            end
        else
            print("|cffff6666CC.header is nil!|r")
        end
        
        -- Show the old dfBindingSnippet if it exists (for comparison)
        if focus.GetAttribute then
            local snippet = focus:GetAttribute("dfBindingSnippet")
            if snippet and snippet ~= "" then
                print("|cffffff00--- Old Frame Binding Snippet (deprecated) ---")
                print(snippet)
                print("--- End Old Snippet ---|r")
            end
        end
        
        -- Show relevant attributes
        if focus.GetAttribute then
            print("--- Frame Attributes ---")
            for i = 1, 5 do
                local typeAttr = focus:GetAttribute("type" .. i)
                local spellAttr = focus:GetAttribute("spell" .. i)
                local macroAttr = focus:GetAttribute("macrotext" .. i)
                if typeAttr then
                    print("  type" .. i .. " = " .. tostring(typeAttr))
                    if spellAttr then print("  spell" .. i .. " = " .. tostring(spellAttr)) end
                    if macroAttr then print("  macrotext" .. i .. " = " .. tostring(macroAttr:sub(1, 80))) end
                end
            end
            -- Check shift-type1 etc
            local shiftType1 = focus:GetAttribute("shift-type1")
            if shiftType1 then
                print("  shift-type1 = " .. tostring(shiftType1))
                local shiftMacro = focus:GetAttribute("shift-macrotext1")
                if shiftMacro then print("  shift-macrotext1 = " .. tostring(shiftMacro:sub(1, 80))) end
            end
            
            -- Check virtual button attributes for keyboard bindings
            print("--- Virtual Button Attributes (for keyboard bindings) ---")
            -- Check common key names (not prefixed with "key")
            local virtButtons = {"Q", "F", "E", "R", "T", "G", "1", "2", "3", "4", "5",
                                 "shiftQ", "shiftF", "ctrlQ", "ctrlF", "altQ", "altF"}
            for _, vb in ipairs(virtButtons) do
                local vbType = focus:GetAttribute("type-" .. vb)
                if vbType then
                    local vbMacro = focus:GetAttribute("macrotext-" .. vb)
                    print("  type-" .. vb .. " = " .. tostring(vbType))
                    if vbMacro then print("  macrotext-" .. vb .. " = " .. tostring(vbMacro:sub(1, 60))) end
                end
            end
        end
    else
        print("No frame under mouse")
    end
end

-- Debug: Show current override bindings
SLASH_DFCCKEYBINDS1 = "/dfcckeybinds"
SlashCmdList["DFCCKEYBINDS"] = function()
    print("|cff33cc66=== DF Override Binding Check ===|r")
    
    -- Check specific keys
    local keysToCheck = {"Q", "F", "E", "R", "T", "G", "1", "2", "3", "4", "5", 
                         "SHIFT-Q", "SHIFT-F", "CTRL-Q", "CTRL-F"}
    
    for _, key in ipairs(keysToCheck) do
        local action, owner = GetBindingAction(key, true)  -- true = check override bindings
        if action and action ~= "" then
            local ownerName = owner and owner:GetName() or "unknown"
            print(key .. " -> " .. action .. " (owner: " .. ownerName .. ")")
        end
    end
    
    -- Also check what frame is under mouse and its bindings
    local focus = GetMouseFocus and GetMouseFocus()
    if not focus and GetMouseFoci then
        local foci = GetMouseFoci()
        focus = foci and foci[1]
    end
    
    if focus and focus.dfActiveKeyboardBindings then
        print("--- Frame's tracked keyboard bindings ---")
        for _, bindKey in ipairs(focus.dfActiveKeyboardBindings) do
            print("  " .. bindKey)
        end
    end
end

-- Debug: Enable live click debugging
CC.debugClicksEnabled = false

SLASH_DFCCDEBUGCLICKS1 = "/dfccdebugclicks"
SlashCmdList["DFCCDEBUGCLICKS"] = function()
    CC.debugClicksEnabled = not CC.debugClicksEnabled
    if CC.debugClicksEnabled then
        print("|cff33cc66DF Click Debug:|r ENABLED - will print info on each click")
        -- Hook PreClick on all registered frames
        if CC.registeredFrames then
            for frame in pairs(CC.registeredFrames) do
                if not frame.dfDebugClickHooked then
                    frame:HookScript("PreClick", function(self, button, down)
                        if not CC.debugClicksEnabled then return end
                        local unit = self:GetAttribute("unit") or self.unit or "none"
                        local moExists = UnitExists("mouseover")
                        local moName = moExists and UnitName("mouseover") or "none"
                        local frameName = self:GetName() or "unnamed"
                        print("|cffff9900[PreClick]|r " .. frameName .. " btn=" .. button .. " down=" .. tostring(down))
                        print("  frame.unit=" .. tostring(unit) .. " mouseover=" .. moName .. " (exists=" .. tostring(moExists) .. ")")
                        
                        -- Show the attribute that will be used
                        local typeAttr = self:GetAttribute("type1")
                        local macroAttr = self:GetAttribute("macrotext1")
                        if button == "RightButton" then
                            typeAttr = self:GetAttribute("type2")
                            macroAttr = self:GetAttribute("macrotext2")
                        end
                        print("  type=" .. tostring(typeAttr) .. " macro=" .. tostring(macroAttr and macroAttr:sub(1, 60)))
                    end)
                    frame:HookScript("PostClick", function(self, button, down)
                        if not CC.debugClicksEnabled then return end
                        local moExists = UnitExists("mouseover")
                        local moName = moExists and UnitName("mouseover") or "none"
                        print("|cff00ff00[PostClick]|r mouseover=" .. moName .. " (exists=" .. tostring(moExists) .. ")")
                    end)
                    frame.dfDebugClickHooked = true
                end
            end
        end
    else
        print("|cff33cc66DF Click Debug:|r DISABLED")
    end
end

-- Debug: Show all bindings and their macro text
SLASH_DFCCBINDINGS1 = "/dfccbindings"
SlashCmdList["DFCCBINDINGS"] = function()
    print("|cff33cc66=== DF Click Cast Bindings ===|r")
    
    if not CC.db or not CC.db.bindings then
        print("No bindings found")
        return
    end
    
    for i, binding in ipairs(CC.db.bindings) do
        if binding.enabled ~= false then
            local keyStr = CC:GetBindingKeyString(binding)
            local actionType = binding.actionType or "spell"
            local spellName = binding.spellName or binding.macroId or "?"
            local fallback = binding.fallback or {}
            local fallbackStr = ""
            if fallback.mouseover then fallbackStr = fallbackStr .. "MO " end
            if fallback.target then fallbackStr = fallbackStr .. "TGT " end
            if fallback.selfCast then fallbackStr = fallbackStr .. "SELF " end
            if fallbackStr == "" then fallbackStr = "none" end
            
            print("|cff00ff00" .. (keyStr or "?") .. "|r -> " .. actionType .. ": " .. spellName .. " [fallback: " .. fallbackStr .. "]")
            
            -- Show generated macro
            if CC.unifiedMacroMap and CC.unifiedMacroMap[keyStr] then
                local macro = CC.unifiedMacroMap[keyStr].macroText
                if macro then
                    print("  |cff888888" .. macro:gsub("\n", " / ") .. "|r")
                end
            end
        end
    end
end

-- Debug: Test if macro conditional would pass right now
SLASH_DFCCTESTMACRO1 = "/dfcctestmacro"
SlashCmdList["DFCCTESTMACRO"] = function(msg)
    print("|cff33cc66=== DF Macro Conditional Test ===|r")
    
    -- Show current state
    local moExists = UnitExists("mouseover")
    local moName = moExists and UnitName("mouseover") or "none"
    local moHelp = moExists and UnitIsFriend("player", "mouseover")
    local moHarm = moExists and UnitCanAttack("player", "mouseover")
    local moDead = moExists and UnitIsDeadOrGhost("mouseover")
    
    print("mouseover exists: " .. tostring(moExists))
    print("mouseover name: " .. moName)
    print("mouseover help: " .. tostring(moHelp))
    print("mouseover harm: " .. tostring(moHarm))
    print("mouseover dead: " .. tostring(moDead))
    
    local tgtExists = UnitExists("target")
    local tgtName = tgtExists and UnitName("target") or "none"
    print("target exists: " .. tostring(tgtExists))
    print("target name: " .. tgtName)
    
    -- Simulate macro conditionals
    print("--- Conditional Results ---")
    print("[@mouseover,exists] = " .. tostring(moExists))
    print("[@mouseover,help,exists] = " .. tostring(moExists and moHelp))
    print("[@mouseover,help,exists,nodead] = " .. tostring(moExists and moHelp and not moDead))
    print("[@mouseover,harm,exists,nodead] = " .. tostring(moExists and moHarm and not moDead))
end

-- Debug command: Check actual override bindings for common keys
SLASH_DFCCBINDCHECK1 = "/dfccbindcheck"
SlashCmdList["DFCCBINDCHECK"] = function()
    print("|cff00ff00[DF CC]|r Checking override bindings for keys 1-9:")
    
    for i = 1, 9 do
        local key = tostring(i)
        local action = GetBindingAction(key, true)  -- true = check override bindings first
        print(string.format("  Key %s: action=%s", key, tostring(action)))
    end
    
    print("--- Checking hovered frame's bindings ---")
    local frame = CC.currentHoveredFrame
    if frame then
        local frameName = frame:GetName()
        print("Frame: " .. frameName)
    else
        print("No hovered frame")
    end
end

-- Debug command: Show binding attributes on hovered frame
SLASH_DFCCFRAMEATTRS1 = "/dfccframeattrs"
SlashCmdList["DFCCFRAMEATTRS"] = function()
    local frame = CC.currentHoveredFrame
    if not frame then
        print("|cffff6600[DF CC]|r No frame currently hovered")
        return
    end
    
    local frameName = frame:GetName() or "unnamed"
    print("|cff00ff00[DF CC]|r Frame Attributes for: " .. frameName)
    
    -- Event counters
    print("--- Secure Event Counters ---")
    print("  _onenter fired: " .. tostring(frame:GetAttribute("dfOnEnterAttrCount") or 0))
    print("  _onenter ran snippet: " .. tostring(frame:GetAttribute("dfOnEnterRanSnippet") or "n/a"))
    print("  _onleave fired: " .. tostring(frame:GetAttribute("dfOnLeaveAttrCount") or 0))
    print("  WrapScript OnEnter: " .. tostring(frame:GetAttribute("dfWrapEnterCount") or 0))
    
    -- Check keyboard binding snippet
    local snippet = frame:GetAttribute("dfBindingSnippet") or ""
    local lineCount = 0
    for _ in snippet:gmatch("[^\n]+") do lineCount = lineCount + 1 end
    print("--- Binding Snippet (" .. lineCount .. " lines) ---")
    if snippet ~= "" then
        for line in snippet:gmatch("[^\n]+") do
            print("  " .. line)
        end
    else
        print("  (empty)")
    end
    
    -- Check actual bindings for keys in snippet
    print("--- Actual Bindings (GetBindingAction) ---")
    if snippet ~= "" then
        for line in snippet:gmatch("[^\n]+") do
            local key = line:match('SetBindingClick%(true,%s*"([^"]+)"')
            if key then
                local action = GetBindingAction(key, true)
                if action and action ~= "" then
                    print(string.format("  %s -> %s", key, action))
                else
                    print(string.format("  %s -> (none/actionbar)", key))
                end
            end
        end
    else
        print("  (no snippet)")
    end
    
    print("--- Frame State ---")
    print("  registered=" .. tostring(frame.dfClickCastRegistered) .. 
          ", isDandersFrame=" .. tostring(frame.dfIsDandersFrame) ..
          ", handlersSetup=" .. tostring(frame.dfKeyboardHandlersSetup))
end

-- Debug loadout profile switching
SLASH_DFCCLOADOUT1 = "/dfccloadout"
SlashCmdList["DFCCLOADOUT"] = function()
    print("|cff00ffffDandersFrames Click-Casting Loadout Debug:|r")
    
    -- These are functions, not methods - don't use : syntax
    local specIndex = CC.GetCurrentSpec and CC.GetCurrentSpec() or GetSpecialization() or 0
    local loadoutID = CC.GetCurrentLoadoutConfigID and CC.GetCurrentLoadoutConfigID() or 0
    local loadoutName = CC.GetLoadoutName and CC.GetLoadoutName(loadoutID) or "Unknown"
    local currentProfile = CC:GetActiveProfileName()
    local assignedProfile, isSpecific = CC:GetProfileForLoadout(specIndex, loadoutID)
    
    print("  Current Spec Index: " .. tostring(specIndex))
    print("  Current Loadout ID: " .. tostring(loadoutID))
    print("  Current Loadout Name: " .. tostring(loadoutName))
    print("  Current Active Profile: " .. tostring(currentProfile))
    print("  Assigned Profile for Loadout: " .. tostring(assignedProfile or "none"))
    print("  Is Specific Assignment: " .. tostring(isSpecific))
    
    -- Show all loadout assignments for current spec
    local classData = CC:GetClassData()
    if classData and classData.loadoutAssignments and classData.loadoutAssignments[specIndex] then
        print("  All assignments for spec " .. specIndex .. ":")
        for lid, profile in pairs(classData.loadoutAssignments[specIndex]) do
            local lname = CC.GetLoadoutName and CC.GetLoadoutName(lid) or tostring(lid)
            print("    Loadout " .. tostring(lid) .. " (" .. lname .. ") -> " .. profile)
        end
    else
        print("  No loadout assignments found for this spec")
    end
    
    -- Manually trigger a check
    print("  Triggering CheckLoadoutProfileSwitch...")
    CC:CheckLoadoutProfileSwitch()
end

-- Debug: Toggle click debugging on hovercast button
SLASH_DFCCCLICKDEBUG1 = "/dfccclickdebug"
SlashCmdList["DFCCCLICKDEBUG"] = function()
    CC.debugClicksEnabled = not CC.debugClicksEnabled
    if CC.debugClicksEnabled then
        print("|cff00ff00[DF CC]|r Click debug ENABLED - press your bound key and watch for PreClick/PostClick messages")
        print("|cff00ff00[DF CC]|r If you see PreClick but spell doesn't cast, the issue is with the macro/spell")
        print("|cff00ff00[DF CC]|r If you see NOTHING, the binding isn't triggering the click")
    else
        print("|cff00ff00[DF CC]|r Click debug disabled")
    end
end

-- Debug: Comprehensive keyboard fallback diagnosis
SLASH_DFCCKBFALLBACK1 = "/dfcckbfallback"
SlashCmdList["DFCCKBFALLBACK"] = function()
    print("|cff33cc66=== DF Keyboard Fallback Debug ===|r")
    
    -- 1. Check if click-casting is enabled
    print("|cff00ff00[1] Click-Casting Status:|r")
    print("  Enabled: " .. tostring(CC.db and CC.db.enabled))
    
    -- 2. Check hovercast button
    print("|cff00ff00[2] Hovercast Button:|r")
    local hcButton = CC.hovercastButton
    if hcButton then
        print("  Button exists: yes")
        print("  Button name: " .. tostring(hcButton:GetName()))
        print("  Parent: " .. tostring(hcButton:GetParent() and hcButton:GetParent():GetName()))
        print("  Has Execute method: " .. tostring(hcButton.Execute ~= nil))
        
        -- Check setupScript/clearScript
        if hcButton.setupScript then
            local lineCount = 0
            local bindingCount = 0
            for line in hcButton.setupScript:gmatch("[^\n]+") do 
                lineCount = lineCount + 1
                if line:find("SetBindingClick") then
                    bindingCount = bindingCount + 1
                end
            end
            print("  setupScript: " .. lineCount .. " lines, " .. bindingCount .. " SetBindingClick calls")
        else
            print("  setupScript: nil")
        end
        
        -- Try to find what virtual button names are used
        -- Parse setupScript to find attribute names
        if hcButton.setupScript then
            print("  Checking attributes from setupScript...")
            local foundAttrs = 0
            for suffix in hcButton.setupScript:gmatch('type%-([^"]+)') do
                local typeAttr = hcButton:GetAttribute("type-" .. suffix)
                local macroAttr = hcButton:GetAttribute("macrotext-" .. suffix)
                if typeAttr then
                    foundAttrs = foundAttrs + 1
                    print("    " .. suffix .. ": type=" .. tostring(typeAttr) .. ", macro=" .. (macroAttr and macroAttr:sub(1, 40) or "nil") .. "...")
                else
                    print("    " .. suffix .. ": MISSING (script has it but attribute not set!)")
                end
            end
            if foundAttrs == 0 then
                print("    NO ATTRIBUTES FOUND - Execute() likely failed!")
            end
        end
    else
        print("  Button exists: NO - this is a problem!")
    end
    
    -- 3. Check global bindings with fallbacks
    print("|cff00ff00[3] Bindings with Fallbacks:|r")
    if CC.db and CC.db.bindings then
        local fallbackCount = 0
        for i, binding in ipairs(CC.db.bindings) do
            if binding.enabled ~= false then
                local fb = binding.fallback or {}
                if fb.mouseover or fb.target or fb.selfCast then
                    fallbackCount = fallbackCount + 1
                    local keyStr = CC:GetBindingKeyString(binding)
                    local fbStr = ""
                    if fb.mouseover then fbStr = fbStr .. "MO " end
                    if fb.target then fbStr = fbStr .. "TGT " end
                    if fb.selfCast then fbStr = fbStr .. "SELF " end
                    print("  " .. (keyStr or "?") .. " -> " .. (binding.spellName or "?") .. " [" .. fbStr .. "]")
                    
                    -- Check if this binding has global macro in unified map
                    if CC.unifiedMacroMap and CC.unifiedMacroMap[keyStr] then
                        local data = CC.unifiedMacroMap[keyStr]
                        print("    macroText: " .. (data.macroText and data.macroText:sub(1, 60) or "nil"))
                        print("    globalMacroText: " .. (data.globalMacroText and data.globalMacroText:sub(1, 60) or "nil"))
                    else
                        print("    NOT in unifiedMacroMap!")
                    end
                end
            end
        end
        if fallbackCount == 0 then
            print("  No bindings with fallbacks found")
        end
    end
    
    -- 4. Check actual override bindings
    print("|cff00ff00[4] Override Bindings (GetBindingAction):|r")
    local keysToCheck = {"Q", "E", "R", "T", "F", "G", "1", "2", "3", "4", "5",
                         "SHIFT-Q", "SHIFT-E", "CTRL-Q", "CTRL-E"}
    local foundOurs = false
    for _, key in ipairs(keysToCheck) do
        local action = GetBindingAction(key, true)
        if action and action ~= "" then
            local isOurs = action:find("DFHovercastButton") or action:find("dfbutton")
            if isOurs then
                foundOurs = true
                print("  " .. key .. " -> " .. action .. " (OURS)")
            else
                print("  " .. key .. " -> " .. action)
            end
        end
    end
    if not foundOurs then
        print("  WARNING: No keys bound to DFHovercastButton!")
        print("  This means Execute() failed or script wasn't run")
    end
    
    -- 5. Check current unit state
    print("|cff00ff00[5] Current Unit State:|r")
    local moExists = UnitExists("mouseover")
    local tgtExists = UnitExists("target")
    print("  mouseover: " .. (moExists and UnitName("mouseover") or "none"))
    print("  target: " .. (tgtExists and UnitName("target") or "none"))
    
    -- 6. Check if currently hovering a frame
    print("|cff00ff00[6] Currently Hovered Frame:|r")
    local hoveredFrame = CC.currentHoveredFrame
    if hoveredFrame then
        print("  Frame: " .. tostring(hoveredFrame:GetName()))
    else
        print("  None (fallbacks should be active if set)")
    end
    
    -- 7. Try to manually execute the setup script and report result
    print("|cff00ff00[7] Manual Execute Test:|r")
    if hcButton and hcButton.Execute and hcButton.setupScript then
        local success, err = pcall(function()
            hcButton:Execute(hcButton.setupScript)
        end)
        if success then
            print("  Execute() succeeded")
            -- Check if attributes are now set
            local foundAfter = false
            for suffix in hcButton.setupScript:gmatch('type%-([^"]+)') do
                local typeAttr = hcButton:GetAttribute("type-" .. suffix)
                if typeAttr then
                    foundAfter = true
                    print("  After Execute: " .. suffix .. " = " .. tostring(typeAttr))
                end
            end
            if not foundAfter then
                print("  Execute returned success but attributes STILL not set!")
                print("  This suggests SecureHandlerBaseTemplate isn't working")
            end
        else
            print("  Execute() FAILED: " .. tostring(err))
        end
    else
        print("  Cannot test - missing button, Execute, or setupScript")
    end
    
    print("|cff888888Tip: If fallbacks aren't working, check that:|r")
    print("|cff888888  1. Section [7] shows attributes are set after Execute|r")
    print("|cff888888  2. Section [4] shows keys bound to DFHovercastButton|r")
end
