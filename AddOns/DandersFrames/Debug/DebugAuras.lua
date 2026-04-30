-- DandersFrames Debug Aura Bar
-- Tool for testing and exploring WoW aura APIs

local addonName, DF = ...
local issecretvalue = issecretvalue or function() return false end

DF.DebugAuras = {}
local DA = DF.DebugAuras

-- Debug settings (not saved, reset on reload)
DA.enabled = false

-- API Filter flags
DA.filterHelpful = true
DA.filterHarmful = false
DA.filterPlayer = false
DA.filterRaid = false
DA.filterCancelable = false
DA.filterNotCancelable = false
DA.filterIncludeNameplateOnly = false
DA.filterMaw = false

-- New API Filter flags (11.1+)
DA.filterCrowdControl = false
DA.filterBigDefensive = false
DA.filterRaidPlayerDispellable = false
DA.filterRaidInCombat = false

-- Display settings
DA.maxIcons = 8
DA.iconSize = 24
DA.showCount = true
DA.showTooltip = true

-- Post-fetch filters
DA.usePlayerOnly = false
DA.useBigDefensivePostFilter = false

-- ============================================================
-- FILTER STRING BUILDER
-- ============================================================

function DA:BuildFilterString()
    local parts = {}
    
    -- Base filter (HELPFUL or HARMFUL, at least one required)
    if DA.filterHelpful then table.insert(parts, "HELPFUL") end
    if DA.filterHarmful then table.insert(parts, "HARMFUL") end
    
    -- Default to HELPFUL if neither selected
    if #parts == 0 then 
        table.insert(parts, "HELPFUL")
        DA.filterHelpful = true
    end
    
    -- Standard filters
    if DA.filterPlayer then table.insert(parts, "PLAYER") end
    if DA.filterRaid then table.insert(parts, "RAID") end
    if DA.filterCancelable then table.insert(parts, "CANCELABLE") end
    if DA.filterNotCancelable then table.insert(parts, "NOT_CANCELABLE") end
    if DA.filterIncludeNameplateOnly then table.insert(parts, "INCLUDENAMEPLATEONLY") end
    if DA.filterMaw then table.insert(parts, "MAW") end
    
    -- New 11.1+ filters from AuraUtil.AuraFilters
    if AuraUtil and AuraUtil.AuraFilters then
        if DA.filterCrowdControl and AuraUtil.AuraFilters.CrowdControl then
            table.insert(parts, AuraUtil.AuraFilters.CrowdControl)
        end
        if DA.filterBigDefensive and AuraUtil.AuraFilters.BigDefensive then
            table.insert(parts, AuraUtil.AuraFilters.BigDefensive)
        end
        if DA.filterRaidPlayerDispellable and AuraUtil.AuraFilters.RaidPlayerDispellable then
            table.insert(parts, AuraUtil.AuraFilters.RaidPlayerDispellable)
        end
        if DA.filterRaidInCombat and AuraUtil.AuraFilters.RaidInCombat then
            table.insert(parts, AuraUtil.AuraFilters.RaidInCombat)
        end
    end
    
    return table.concat(parts, " ")
end

-- ============================================================
-- FRAME DETECTION
-- ============================================================

-- Get all DandersFrames unit frames
function DA:GetAllFrames()
    local frames = {}
    local seen = {}  -- Avoid duplicates
    
    local function AddFrame(frame)
        if frame and not seen[frame] and type(frame) == "table" and frame.IsVisible then
            seen[frame] = true
            table.insert(frames, frame)
        end
    end
    
    -- SecureGroupHeaderTemplate names children as: HeaderNameUnitButton1, HeaderNameUnitButton2, etc.
    
    -- Party header children: DandersPartyHeaderUnitButton1, etc.
    for i = 1, 5 do
        local frame = _G["DandersPartyHeaderUnitButton" .. i]
        if frame then
            AddFrame(frame)
        end
    end
    
    -- Raid combined header children: DandersRaidCombinedHeaderUnitButton1, etc.
    for i = 1, 40 do
        local frame = _G["DandersRaidCombinedHeaderUnitButton" .. i]
        if frame then
            AddFrame(frame)
        end
    end
    
    -- Raid group headers (groups 1-8): DandersRaidGroup1HeaderUnitButton1, etc.
    for group = 1, 8 do
        for i = 1, 5 do
            local frame = _G["DandersRaidGroup" .. group .. "HeaderUnitButton" .. i]
            if frame then
                AddFrame(frame)
            end
        end
    end
    
    -- Raid player header: DandersRaidPlayerHeaderUnitButton1
    local raidPlayerFrame = _G["DandersRaidPlayerHeaderUnitButton1"]
    if raidPlayerFrame then
        AddFrame(raidPlayerFrame)
    end
    
    -- Also try GetChildren method as backup
    if DF.partyHeader then
        local children = {DF.partyHeader:GetChildren()}
        for _, child in ipairs(children) do
            AddFrame(child)
        end
    end
    
    if DF.FlatRaidFrames and DF.FlatRaidFrames.header then
        local children = {DF.FlatRaidFrames.header:GetChildren()}
        for _, child in ipairs(children) do
            AddFrame(child)
        end
    end
    
    -- Legacy frames (if they exist)
    if DF.playerFrame then
        AddFrame(DF.playerFrame)
    end
    if DF.partyFrames then
        for i = 1, 4 do
            AddFrame(DF.partyFrames[i])
        end
    end
    
    -- Test frames (if in test mode)
    if DF.testMode or DF.testPartyFrames then
        if DF.testPartyFrames then
            for i = 0, 4 do
                AddFrame(DF.testPartyFrames[i])
            end
        end
        if DF.testRaidFrames then
            for i = 1, 40 do
                AddFrame(DF.testRaidFrames[i])
            end
        end
    end
    
    return frames
end

-- ============================================================
-- DEBUG ICON CREATION
-- ============================================================

local function CreateDebugIcon(parent, index)
    local icon = CreateFrame("Frame", nil, parent)
    icon:SetSize(DA.iconSize, DA.iconSize)
    
    -- Border (cyan to distinguish from regular auras)
    icon.border = icon:CreateTexture(nil, "BACKGROUND")
    icon.border:SetPoint("TOPLEFT", -1, 1)
    icon.border:SetPoint("BOTTOMRIGHT", 1, -1)
    icon.border:SetColorTexture(0, 0.7, 1, 0.9)
    
    -- Icon texture
    icon.texture = icon:CreateTexture(nil, "ARTWORK")
    icon.texture:SetAllPoints()
    icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    -- Cooldown
    icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
    icon.cooldown:SetAllPoints(icon.texture)
    icon.cooldown:SetDrawEdge(false)
    icon.cooldown:SetDrawSwipe(true)
    icon.cooldown:SetReverse(true)
    icon.cooldown:SetHideCountdownNumbers(false)
    
    -- Count text
    icon.count = icon:CreateFontString(nil, "OVERLAY")
    DF.GUI:SetSettingsFont(icon.count, 10, "OUTLINE")
    icon.count:SetPoint("BOTTOMRIGHT", 0, 0)
    
    -- Index label
    icon.indexText = icon:CreateFontString(nil, "OVERLAY")
    DF.GUI:SetSettingsFont(icon.indexText, 8, "OUTLINE")
    icon.indexText:SetPoint("TOPLEFT", 1, -1)
    icon.indexText:SetText(index)
    icon.indexText:SetTextColor(1, 1, 0, 1)
    
    icon.index = index
    icon:Hide()
    
    -- Tooltip on hover
    icon:EnableMouse(true)
    icon:SetScript("OnEnter", function(self)
        if self.auraData and DA.showTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            -- Wrap in pcall in case values are secret
            pcall(function()
                if self.auraData.auraInstanceID then
                    GameTooltip:SetUnitAura(self.unit, self.auraData.auraInstanceID)
                elseif self.auraData.name then
                    GameTooltip:SetText(self.auraData.name)
                    if self.auraData.duration and self.auraData.duration > 0 then
                        GameTooltip:AddLine(string.format("Duration: %.1fs", self.auraData.duration), 1, 1, 1)
                    end
                else
                    GameTooltip:SetText("Aura (secret data)")
                end
            end)
            GameTooltip:Show()
        end
    end)
    icon:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    return icon
end

-- ============================================================
-- DEBUG BAR CREATION
-- ============================================================

function DA:CreateDebugBar(frame)
    if frame.debugAuraBar then return end
    
    local bar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    bar:SetSize(250, DA.iconSize + 4)
    bar:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2)
    bar:SetFrameLevel(frame:GetFrameLevel() + 100)
    
    -- Background
    bar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    bar:SetBackdropColor(0, 0, 0, 0.7)
    bar:SetBackdropBorderColor(0, 0.7, 1, 0.8)
    
    -- Label showing current filter
    bar.label = bar:CreateFontString(nil, "OVERLAY")
    DF.GUI:SetSettingsFont(bar.label, 9, "OUTLINE")
    bar.label:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 2, 2)
    bar.label:SetText("Debug Auras")
    bar.label:SetTextColor(0, 1, 1, 1)
    
    -- Create icons
    bar.icons = {}
    for i = 1, 16 do
        bar.icons[i] = CreateDebugIcon(bar, i)
    end
    
    bar:Hide()
    frame.debugAuraBar = bar
end

-- ============================================================
-- DEBUG BAR UPDATE
-- ============================================================

function DA:UpdateDebugBar(frame)
    if not frame or not DA.enabled then
        if frame and frame.debugAuraBar then
            frame.debugAuraBar:Hide()
        end
        return
    end
    
    -- Only show bar if frame is visible and has a unit
    local unit = frame.unit
    if not unit or not UnitExists(unit) or not frame:IsVisible() then
        if frame.debugAuraBar then
            frame.debugAuraBar:Hide()
        end
        return
    end
    
    -- Create bar if needed
    if not frame.debugAuraBar then
        DA:CreateDebugBar(frame)
    end
    
    local bar = frame.debugAuraBar
    if not bar then return end
    
    bar:Show()
    
    -- Build filter string
    local filterString = DA:BuildFilterString()
    
    -- Get auras using multiple approaches for compatibility
    local auras = {}
    local method = "None"
    
    -- Try GetAuraDataByIndex (most reliable)
    for i = 1, 40 do
        local auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, filterString)
        if auraData then
            table.insert(auras, auraData)
        else
            break
        end
    end
    method = "ByIndex"
    
    -- Apply post-fetch filters
    local originalCount = #auras
    
    -- Player-only filter (wrap in pcall for secret values)
    if DA.usePlayerOnly and #auras > 0 then
        local filtered = {}
        for _, aura in ipairs(auras) do
            local isPlayer = false
            pcall(function()
                isPlayer = aura.isFromPlayerOrPlayerPet == true
            end)
            if isPlayer then
                table.insert(filtered, aura)
            end
        end
        auras = filtered
        method = method .. "+Player"
    end
    
    -- BigDefensive post-filter (using API function)
    if DA.useBigDefensivePostFilter and #auras > 0 and C_UnitAuras.AuraIsBigDefensive then
        local filtered = {}
        for _, aura in ipairs(auras) do
            local isBigDef = false
            pcall(function()
                if aura.auraInstanceID then
                    isBigDef = C_UnitAuras.AuraIsBigDefensive(unit, aura.auraInstanceID)
                end
            end)
            if isBigDef then
                table.insert(filtered, aura)
            end
        end
        auras = filtered
        method = method .. "+BigDef"
    end
    
    -- Update label
    local filterDisplay = filterString:gsub("HELPFUL", "H"):gsub("HARMFUL", "D"):gsub("PLAYER", "P"):gsub("RAID", "R")
    bar.label:SetText(string.format("[%s] %d/%d | %s", filterDisplay, #auras, originalCount, method))
    
    -- Position and show icons
    local shown = 0
    for i, icon in ipairs(bar.icons) do
        if i <= DA.maxIcons and auras[i] then
            local auraData = auras[i]
            
            icon:ClearAllPoints()
            icon:SetPoint("LEFT", bar, "LEFT", 2 + (i - 1) * (DA.iconSize + 2), 0)
            icon:SetSize(DA.iconSize, DA.iconSize)
            
            -- Set texture (wrap in pcall for secret values)
            pcall(function()
                if auraData.icon then
                    icon.texture:SetTexture(auraData.icon)
                end
            end)
            
            -- Set cooldown (secret-safe via Duration objects)
            pcall(function()
                if unit and auraData.auraInstanceID
                   and C_UnitAuras.GetAuraDuration
                   and icon.cooldown.SetCooldownFromDurationObject then
                    local durationObj = C_UnitAuras.GetAuraDuration(unit, auraData.auraInstanceID)
                    if durationObj then
                        icon.cooldown:SetCooldownFromDurationObject(durationObj)
                        return
                    end
                end
                -- Fallback for non-secret values
                if auraData.expirationTime and auraData.duration
                   and not issecretvalue(auraData.expirationTime) and not issecretvalue(auraData.duration)
                   and auraData.duration > 0 then
                    if icon.cooldown.SetCooldownFromExpirationTime then
                        icon.cooldown:SetCooldownFromExpirationTime(auraData.expirationTime, auraData.duration)
                    end
                else
                    icon.cooldown:Clear()
                end
            end)
            
            -- Set count (wrap in pcall for secret values)
            pcall(function()
                if DA.showCount and auraData.applications and auraData.applications > 1 then
                    icon.count:SetText(auraData.applications)
                else
                    icon.count:SetText("")
                end
            end)
            
            -- Store data for tooltip
            icon.auraData = auraData
            icon.unit = unit
            
            icon:Show()
            shown = shown + 1
        else
            icon:Hide()
        end
    end
    
    -- Resize bar
    bar:SetWidth(math.max(100, 4 + shown * (DA.iconSize + 2)))
end

-- ============================================================
-- UPDATE ALL
-- ============================================================

function DA:UpdateAll()
    if not DA.enabled then return end
    
    local frames = DA:GetAllFrames()
    local updated = 0
    for _, frame in ipairs(frames) do
        if frame:IsVisible() and frame.unit and UnitExists(frame.unit) then
            DA:UpdateDebugBar(frame)
            updated = updated + 1
        end
    end
    return updated
end

function DA:Toggle()
    DA.enabled = not DA.enabled
    
    if DA.enabled then
        -- Register for updates
        if DA.updateFrame then
            DA.updateFrame:RegisterEvent("UNIT_AURA")
            DA.updateFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        end
        
        -- Debug: print what we found
        print("|cff00ccffDebug Auras:|r Searching for frames...")
        
        -- Check headers exist and their children
        print("  DF.partyHeader: " .. (DF.partyHeader and "exists" or "nil"))
        if DF.partyHeader then
            local children = {DF.partyHeader:GetChildren()}
            print("    Children: " .. #children)
        end
        
        print("  DF.FlatRaidFrames.header: " .. (DF.FlatRaidFrames and DF.FlatRaidFrames.header and "exists" or "nil"))
        if DF.FlatRaidFrames and DF.FlatRaidFrames.header then
            local children = {DF.FlatRaidFrames.header:GetChildren()}
            print("    Children: " .. #children)
        end
        
        -- Update bars
        local frames = DA:GetAllFrames()
        local visibleCount = 0
        for _, frame in ipairs(frames) do
            if frame:IsVisible() then
                visibleCount = visibleCount + 1
            end
        end
        DA:UpdateAll()
        
        print("|cff00ccffDandersFrames Debug Auras:|r |cff00ff00Enabled|r - Found " .. #frames .. " frames (" .. visibleCount .. " visible)")
    else
        -- Unregister events
        if DA.updateFrame then
            DA.updateFrame:UnregisterAllEvents()
        end
        
        -- Hide all bars
        local frames = DA:GetAllFrames()
        for _, frame in ipairs(frames) do
            if frame.debugAuraBar then
                frame.debugAuraBar:Hide()
            end
        end
        
        print("|cff00ccffDandersFrames Debug Auras:|r |cffff0000Disabled|r")
    end
end

-- ============================================================
-- OPTIONS PANEL
-- ============================================================

function DA:CreateOptionsPanel()
    if DA.optionsFrame then return end
    
    local frame = CreateFrame("Frame", "DFDebugAurasOptions", UIParent, "BackdropTemplate")
    frame:SetSize(400, 580)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    frame:SetBackdropColor(0.1, 0.1, 0.12, 0.95)
    frame:SetBackdropBorderColor(0, 0.7, 1, 1)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:Hide()
    
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
    title:SetPoint("TOP", 0, -15)
    title:SetText("|cff00ccffDebug Aura Explorer|r")
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", -8, -8)
    closeBtn:SetNormalTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    closeBtn:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7)
    closeBtn:SetScript("OnEnter", function(self) self:GetNormalTexture():SetVertexColor(1, 0.3, 0.3) end)
    closeBtn:SetScript("OnLeave", function(self) self:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7) end)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
    
    local yOffset = -45
    
    -- Helper to create checkbox
    local function CreateCheckbox(parent, x, y, text, getter, setter)
        local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", x, y)
        cb:SetSize(24, 24)
        cb.text:SetText(text)
        cb.text:SetTextColor(0.9, 0.9, 0.9)
        cb:SetChecked(getter())
        cb:SetScript("OnClick", function(self)
            setter(self:GetChecked())
            DA:UpdateAll()
        end)
        return cb
    end
    
    -- Enable toggle
    local enableCB = CreateCheckbox(frame, 20, yOffset, "|cff00ff00Enable Debug Bars|r", 
        function() return DA.enabled end,
        function(v) DA:Toggle() end)
    yOffset = yOffset - 30
    
    -- ======== BASE FILTERS ========
    local baseHeader = frame:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    baseHeader:SetPoint("TOPLEFT", 20, yOffset)
    baseHeader:SetText("|cff88ff88--- Base Filters ---|r")
    yOffset = yOffset - 22
    
    CreateCheckbox(frame, 20, yOffset, "HELPFUL (Buffs)", 
        function() return DA.filterHelpful end,
        function(v) DA.filterHelpful = v end)
    CreateCheckbox(frame, 180, yOffset, "HARMFUL (Debuffs)", 
        function() return DA.filterHarmful end,
        function(v) DA.filterHarmful = v end)
    yOffset = yOffset - 24
    
    -- ======== STANDARD FILTERS ========
    local stdHeader = frame:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    stdHeader:SetPoint("TOPLEFT", 20, yOffset)
    stdHeader:SetText("|cffffcc00--- Standard Filters ---|r")
    yOffset = yOffset - 22
    
    CreateCheckbox(frame, 20, yOffset, "PLAYER", 
        function() return DA.filterPlayer end,
        function(v) DA.filterPlayer = v end)
    CreateCheckbox(frame, 180, yOffset, "RAID", 
        function() return DA.filterRaid end,
        function(v) DA.filterRaid = v end)
    yOffset = yOffset - 24
    
    CreateCheckbox(frame, 20, yOffset, "CANCELABLE", 
        function() return DA.filterCancelable end,
        function(v) DA.filterCancelable = v end)
    CreateCheckbox(frame, 180, yOffset, "NOT_CANCELABLE", 
        function() return DA.filterNotCancelable end,
        function(v) DA.filterNotCancelable = v end)
    yOffset = yOffset - 24
    
    CreateCheckbox(frame, 20, yOffset, "INCLUDENAMEPLATEONLY", 
        function() return DA.filterIncludeNameplateOnly end,
        function(v) DA.filterIncludeNameplateOnly = v end)
    CreateCheckbox(frame, 180, yOffset, "MAW", 
        function() return DA.filterMaw end,
        function(v) DA.filterMaw = v end)
    yOffset = yOffset - 28
    
    -- ======== NEW 11.1+ FILTERS ========
    local newHeader = frame:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    newHeader:SetPoint("TOPLEFT", 20, yOffset)
    newHeader:SetText("|cff00ccff--- New API Filters (use Dump to check) ---|r")
    yOffset = yOffset - 22
    
    -- All checkboxes enabled - BuildFilterString will skip if not available
    CreateCheckbox(frame, 20, yOffset, "CROWD_CONTROL", 
        function() return DA.filterCrowdControl end,
        function(v) DA.filterCrowdControl = v end)
    
    CreateCheckbox(frame, 180, yOffset, "BIG_DEFENSIVE", 
        function() return DA.filterBigDefensive end,
        function(v) DA.filterBigDefensive = v end)
    yOffset = yOffset - 24
    
    CreateCheckbox(frame, 20, yOffset, "RAID_PLAYER_DISPELLABLE", 
        function() return DA.filterRaidPlayerDispellable end,
        function(v) DA.filterRaidPlayerDispellable = v end)
    yOffset = yOffset - 24
    
    CreateCheckbox(frame, 20, yOffset, "RAID_IN_COMBAT", 
        function() return DA.filterRaidInCombat end,
        function(v) DA.filterRaidInCombat = v end)
    yOffset = yOffset - 28
    
    -- ======== POST-FETCH FILTERS ========
    local postHeader = frame:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    postHeader:SetPoint("TOPLEFT", 20, yOffset)
    postHeader:SetText("|cffff8800--- Post-Fetch Filters ---|r")
    yOffset = yOffset - 22
    
    CreateCheckbox(frame, 20, yOffset, "Player-cast only", 
        function() return DA.usePlayerOnly end,
        function(v) DA.usePlayerOnly = v end)
    yOffset = yOffset - 24
    
    CreateCheckbox(frame, 20, yOffset, "BigDefensive (via API check)", 
        function() return DA.useBigDefensivePostFilter end,
        function(v) DA.useBigDefensivePostFilter = v end)
    yOffset = yOffset - 28
    
    -- ======== DISPLAY OPTIONS ========
    local dispHeader = frame:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    dispHeader:SetPoint("TOPLEFT", 20, yOffset)
    dispHeader:SetText("|cffaaaaaa--- Display Options ---|r")
    yOffset = yOffset - 22
    
    -- Max icons slider
    local maxLabel = frame:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    maxLabel:SetPoint("TOPLEFT", 20, yOffset)
    maxLabel:SetText("Max Icons: " .. DA.maxIcons)
    
    local maxSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
    maxSlider:SetPoint("TOPLEFT", 140, yOffset)
    maxSlider:SetWidth(200)
    maxSlider:SetMinMaxValues(1, 16)
    maxSlider:SetValue(DA.maxIcons)
    maxSlider:SetValueStep(1)
    maxSlider:SetObeyStepOnDrag(true)
    maxSlider.Low:SetText("1")
    maxSlider.High:SetText("16")
    maxSlider:SetScript("OnValueChanged", function(self, value)
        DA.maxIcons = math.floor(value)
        maxLabel:SetText("Max Icons: " .. DA.maxIcons)
        DA:UpdateAll()
    end)
    yOffset = yOffset - 35
    
    -- Icon size slider
    local sizeLabel = frame:CreateFontString(nil, "OVERLAY", "DFFontHighlight")
    sizeLabel:SetPoint("TOPLEFT", 20, yOffset)
    sizeLabel:SetText("Icon Size: " .. DA.iconSize)
    
    local sizeSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
    sizeSlider:SetPoint("TOPLEFT", 140, yOffset)
    sizeSlider:SetWidth(200)
    sizeSlider:SetMinMaxValues(16, 40)
    sizeSlider:SetValue(DA.iconSize)
    sizeSlider:SetValueStep(2)
    sizeSlider:SetObeyStepOnDrag(true)
    sizeSlider.Low:SetText("16")
    sizeSlider.High:SetText("40")
    sizeSlider:SetScript("OnValueChanged", function(self, value)
        DA.iconSize = math.floor(value)
        sizeLabel:SetText("Icon Size: " .. DA.iconSize)
        -- Recreate bars with new size
        local frames = DA:GetAllFrames()
        for _, f in ipairs(frames) do
            if f.debugAuraBar then
                f.debugAuraBar:Hide()
                f.debugAuraBar = nil
            end
        end
        DA:UpdateAll()
    end)
    yOffset = yOffset - 35
    
    CreateCheckbox(frame, 20, yOffset, "Show Tooltips", 
        function() return DA.showTooltip end,
        function(v) DA.showTooltip = v end)
    yOffset = yOffset - 30
    
    -- ======== UTILITY BUTTONS ========
    local utilHeader = frame:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    utilHeader:SetPoint("TOPLEFT", 20, yOffset)
    utilHeader:SetText("|cff8888ff--- Utilities ---|r")
    yOffset = yOffset - 25
    
    -- Dump AuraFilters button
    local dumpBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    dumpBtn:SetSize(160, 24)
    dumpBtn:SetPoint("TOPLEFT", 20, yOffset)
    dumpBtn:SetText("Dump AuraFilters")
    dumpBtn:SetScript("OnClick", function()
        print("|cff00ccff=== AuraUtil.AuraFilters ===|r")
        if AuraUtil and AuraUtil.AuraFilters then
            local count = 0
            for name, value in pairs(AuraUtil.AuraFilters) do
                count = count + 1
                print(string.format("  |cffffcc00%s|r = |cff88ff88\"%s\"|r", name, tostring(value)))
            end
            print("|cff00ccffTotal filters: " .. count .. "|r")
        else
            print("  |cffff0000AuraUtil.AuraFilters not available|r")
            print("  AuraUtil exists: " .. tostring(AuraUtil ~= nil))
        end
        
        -- Also check C_UnitAuras functions
        print("|cff00ccff=== C_UnitAuras Functions ===|r")
        print("  AuraIsBigDefensive: " .. tostring(C_UnitAuras.AuraIsBigDefensive ~= nil))
        print("  GetAuraDataByIndex: " .. tostring(C_UnitAuras.GetAuraDataByIndex ~= nil))
        print("  IsAuraFilteredOutByInstanceID: " .. tostring(C_UnitAuras.IsAuraFilteredOutByInstanceID ~= nil))
    end)
    
    -- Test API button
    local testBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    testBtn:SetSize(160, 24)
    testBtn:SetPoint("TOPLEFT", 200, yOffset)
    testBtn:SetText("Test APIs")
    testBtn:SetScript("OnClick", function()
        DA:TestAPIs()
    end)
    yOffset = yOffset - 30
    
    -- Refresh button
    local refreshBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    refreshBtn:SetSize(160, 24)
    refreshBtn:SetPoint("TOPLEFT", 20, yOffset)
    refreshBtn:SetText("Refresh Bars")
    refreshBtn:SetScript("OnClick", function()
        -- Reset bars
        local frames = DA:GetAllFrames()
        for _, f in ipairs(frames) do
            if f.debugAuraBar then
                f.debugAuraBar:Hide()
                f.debugAuraBar = nil
            end
        end
        DA:UpdateAll()
        print("|cff00ccffDandersFrames Debug Auras:|r Refreshed " .. #frames .. " frames")
    end)
    
    DA.optionsFrame = frame
end

-- ============================================================
-- API TESTING
-- ============================================================

function DA:TestAPIs()
    local unit = "player"
    if not UnitExists(unit) then
        print("|cffff0000No unit to test on|r")
        return
    end
    
    print("|cff00ccff========== API Test Results ==========|r")
    
    -- Test filter string
    local filterString = DA:BuildFilterString()
    print("|cffffcc00Filter:|r " .. filterString)
    
    -- Count auras with current filter
    local count = 0
    for i = 1, 40 do
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, filterString)
        if aura then
            count = count + 1
        else
            break
        end
    end
    print("|cffffcc00Auras found:|r " .. count)
    
    -- Test each new filter individually
    print("|cff00ccff--- Testing New Filters ---|r")
    if AuraUtil and AuraUtil.AuraFilters then
        for filterName, filterValue in pairs(AuraUtil.AuraFilters) do
            local testFilter = "HELPFUL " .. filterValue
            local testCount = 0
            for i = 1, 40 do
                local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, testFilter)
                if aura then
                    testCount = testCount + 1
                else
                    break
                end
            end
            print(string.format("  |cff88ff88%s|r (%s): %d buffs", filterName, filterValue, testCount))
        end
    end
    
    -- Test BigDefensive API
    print("|cff00ccff--- C_UnitAuras.AuraIsBigDefensive ---|r")
    if C_UnitAuras.AuraIsBigDefensive then
        local bigDefCount = 0
        for i = 1, 40 do
            local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
            if aura and aura.auraInstanceID then
                if C_UnitAuras.AuraIsBigDefensive(unit, aura.auraInstanceID) then
                    bigDefCount = bigDefCount + 1
                    print(string.format("    |cff00ff00BigDef:|r %s", aura.name or "Unknown"))
                end
            else
                break
            end
        end
        print(string.format("  Total BigDefensive: %d", bigDefCount))
    else
        print("  |cffff0000Function not available|r")
    end
    
    print("|cff00ccff========================================|r")
end

-- ============================================================
-- TOGGLE OPTIONS
-- ============================================================

function DA:ToggleOptions()
    if not DA.optionsFrame then
        DA:CreateOptionsPanel()
    end
    
    if DA.optionsFrame:IsShown() then
        DA.optionsFrame:Hide()
    else
        DA.optionsFrame:Show()
    end
end

-- ============================================================
-- EVENT HANDLING
-- ============================================================

local updateFrame = CreateFrame("Frame")
DA.updateFrame = updateFrame

updateFrame:SetScript("OnEvent", function(self, event, unit)
    if not DA.enabled then return end
    
    if event == "UNIT_AURA" then
        -- Find frame for this unit and update
        local frames = DA:GetAllFrames()
        for _, frame in ipairs(frames) do
            if frame.unit == unit then
                DA:UpdateDebugBar(frame)
            end
        end
    elseif event == "GROUP_ROSTER_UPDATE" then
        -- Refresh all frames when group changes
        C_Timer.After(0.1, function()
            if DA.enabled then
                DA:UpdateAll()
            end
        end)
    end
end)

-- ============================================================
-- SLASH COMMAND
-- ============================================================

SLASH_DFDA1 = "/dfda"
SlashCmdList["DFDA"] = function(msg)
    DA:ToggleOptions()
end

print("|cff00ccffDandersFrames:|r Debug Aura module loaded. Use |cffeda55f/dfda|r to open options.")
