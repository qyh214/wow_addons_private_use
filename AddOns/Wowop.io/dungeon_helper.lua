-- Dungeon Helper Module
-- Provides a popup showing helpful spells when entering mythic dungeons

local addonName, addon = ...

local DungeonHelper = {}
addon.DungeonHelper = DungeonHelper

-- Local variables
local frame = CreateFrame("Frame")
local playerClass, playerSpec
local isInMythicDungeon = false
local mythicChallengeStarted = false
local currentDungeonId = nil
local spellCheckCache = {}
local popupTimer = nil
local debugMode = false  -- Set to false by default to reduce log spam
local lastZoneCheck = 0  -- Timestamp of the last zone check for debouncing

-- Constants
local SPELL_TYPE_LABELS = {
    ["dispel"] = "Dispel Effects",
    ["stun"] = "Stun Abilities",
    ["stop"] = "Stop/Slow Effects",
    ["skip"] = "Skip Abilities",
    ["interrupt"] = "Interrupts",
    ["defensive"] = "Defensive Cooldowns",
    ["purge"] = "Purge Effects"
}

local SPELL_SUBTYPE_LABELS = {
    ["curse"] = "Curses",
    ["disease"] = "Diseases",
    ["poison"] = "Poisons",
    ["magic"] = "Magic",
    ["bleed"] = "Bleeds",
    ["single"] = "Single Target",
    ["aoe"] = "Area of Effect",
    ["cc"] = "Crowd Control",
    ["party"] = "Party-wide",
    ["personal"] = "Personal",
    ["external"] = "External",
    ["enrage"] = "Enrage"
}

-- Debug print function that only prints if debug mode is enabled
local function DebugPrint(...)
    if debugMode then
        -- Only show debug messages for guild members of "Raid in Peace"
        local guildName = GetGuildInfo("player")
        if guildName and guildName == "Raid in Peace" then
            print("|cffff00ffDungeonHelper Debug:|r", ...)
        end
    end
end

-- Function to generate lookup tables (to be called during initialization)
function DungeonHelper:generate_lookup_table()
    -- No longer need to build tables from local variables since they're in the database
    -- Just validate that the required tables exist
    if not WOWOP_DUNGEON_DATABASE then
        return false
    end
    
    if not WOWOP_DUNGEON_DATABASE.talent_spell_types or
       not WOWOP_DUNGEON_DATABASE.talent_class_spec or
       not WOWOP_DUNGEON_DATABASE.dungeon_talents then
        return false
    end
    
    return true
end

-- Get current player's class and spec IDs
function DungeonHelper:GetPlayerClassAndSpec()
    -- Use a more reliable method to get class ID
    local _, classFileName, classId = UnitClass("player")
    
    -- Get specialization information
    local currentSpec = GetSpecialization()
    local specId = 0
    
    if currentSpec then
        specId = GetSpecializationInfo(currentSpec)
    end
    
    -- Make sure we have valid values
    if not classId or classId < 1 then
        classId = 1 -- Default to Warrior if we can't detect
    end
    
    -- For debugging: Map class file name to class ID
    local classIdMapping = {
        WARRIOR = 1,
        PALADIN = 2,
        HUNTER = 3,
        ROGUE = 4,
        PRIEST = 5,
        DEATHKNIGHT = 6,
        SHAMAN = 7,
        MAGE = 8,
        WARLOCK = 9,
        MONK = 10,
        DRUID = 11,
        DEMONHUNTER = 12,
        EVOKER = 13
    }
    
    local expectedClassId = classIdMapping[classFileName]
    if expectedClassId and expectedClassId ~= classId then
        classId = expectedClassId
    end
    
    return classId, specId
end

-- Check if player knows a spell
function DungeonHelper:PlayerKnowsSpell(spellId)
    if not spellId then return false end
    
    if spellCheckCache[spellId] ~= nil then
        return spellCheckCache[spellId]
    end
    
    local knows = false
    
    -- Special case for known spells that might not be detected properly
    local specialCaseSpells = {
        [202168] = true, -- Impending Victory
    }
    
    -- Use simpler detection methods that work across all WoW versions
    if specialCaseSpells[spellId] then
        -- For special cases, we'll try a few more methods
        -- But skip the spellbook scanning which uses unavailable APIs
        if IsPlayerSpell(spellId) then
            knows = true
        elseif C_Spell and C_Spell.IsSpellKnown then
            knows = C_Spell.IsSpellKnown(spellId)
        end
    end
    
    -- Standard detection method
    if not knows then
        if IsSpellKnown(spellId) then
            knows = true
        elseif IsPlayerSpell(spellId) then
            knows = true
        elseif IsSpellKnownOrOverridesKnown and IsSpellKnownOrOverridesKnown(spellId) then
            -- Some versions of WoW might not have this function
            knows = true
        end
    end
    
    spellCheckCache[spellId] = knows
    return knows
end

-- Function to determine if we're in a mythic dungeon
function DungeonHelper:IsInMythicDungeon()
    local _, instanceType, difficultyID = GetInstanceInfo()
    -- We want to show the popup in Mythic Keystone dungeons (23) before the challenge starts
    return instanceType == "party" and difficultyID == 23
end

-- Function to get the current dungeon ID from the zone ID
function DungeonHelper:GetDungeonIdFromZone()
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then 
        DebugPrint("GetDungeonIdFromZone: No map ID found")
        return nil 
    end
    
    DebugPrint("GetDungeonIdFromZone: Map ID =", mapID)
    
    local zoneId = WOWOP_LOOKUPS.instance_to_zone[mapID]
    if not zoneId then 
        DebugPrint("GetDungeonIdFromZone: No zone ID found for map ID", mapID)
        return nil 
    end
    
    DebugPrint("GetDungeonIdFromZone: Zone ID =", zoneId)
    
    -- Find the dungeon with this zone ID
    for dungeonId, dungeonData in pairs(WOWOP_DUNGEON_DATABASE.dungeons) do
        if dungeonData.game_zone_id == zoneId then
            DebugPrint("GetDungeonIdFromZone: Found match - Dungeon ID =", dungeonId, "Name =", dungeonData.name)
            return dungeonId
        end
    end
    
    DebugPrint("GetDungeonIdFromZone: No matching dungeon found for zone ID", zoneId)
    return nil
end

-- Create the popup frame
local popupFrame = CreateFrame("Frame", "DungeonHelperPopup", UIParent, "BackdropTemplate")
popupFrame:Hide()
popupFrame:SetFrameStrata("DIALOG")
popupFrame:SetPoint("CENTER", 0, 0)
popupFrame:SetSize(500, 600) -- Increased size for better visibility
popupFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
popupFrame:SetBackdropColor(0, 0, 0, 0.8)
popupFrame:EnableMouse(true)
popupFrame:SetMovable(true)
popupFrame:RegisterForDrag("LeftButton")
popupFrame:SetScript("OnDragStart", popupFrame.StartMoving)
popupFrame:SetScript("OnDragStop", popupFrame.StopMovingOrSizing)
popupFrame.currentDungeonId = nil

-- Function to handle talent updates
local function OnPopupEvent(self, event, ...)
    if event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
        -- Only update if we have dungeon information
        if self.currentDungeonId then
            -- Clear spell check cache
            spellCheckCache = {}
            -- Refresh the popup
            DungeonHelper:ShowSpellPopup(self.currentDungeonId)
        end
    end
end

-- Register talent events directly on the popup frame
popupFrame:SetScript("OnEvent", OnPopupEvent)
popupFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
popupFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

-- Add special handling for when the popup is shown and hidden
popupFrame:SetScript("OnShow", function(self)
    -- Ensure events are registered when the popup is shown
    self:SetScript("OnEvent", OnPopupEvent)
    self:RegisterEvent("PLAYER_TALENT_UPDATE")
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    
    -- Create a talent counter based on spell availability to detect changes
    -- This helps when events aren't firing reliably
    if self.talentCounter then
        self.talentCounter:Cancel()
    end
    
    self.knownTalentCount = 0
    
    -- Count how many talent spells the player currently knows
    self.talentCounter = C_Timer.NewTicker(2, function()
        -- Skip if no dungeon ID
        if not self.currentDungeonId then return end
        
        local classId, specId = DungeonHelper:GetPlayerClassAndSpec()
        if not classId then return end
        
        -- Count how many spells the player currently knows
        local currentKnownCount = 0
        
        -- Check all spells for the player's class/spec
        if WOWOP_DUNGEON_DATABASE and WOWOP_DUNGEON_DATABASE.talent_class_spec then
            for _, entry in pairs(WOWOP_DUNGEON_DATABASE.talent_class_spec) do
                if entry.wow_class_id == classId and 
                   (entry.wow_spec_id == 0 or entry.wow_spec_id == specId) then
                    -- Check if player knows this spell now (directly check, don't use cache)
                    if IsSpellKnown(entry.spell_id) or IsPlayerSpell(entry.spell_id) or 
                       (IsSpellKnownOrOverridesKnown and IsSpellKnownOrOverridesKnown(entry.spell_id)) then
                        currentKnownCount = currentKnownCount + 1
                    end
                end
            end
        end
        
        -- If this is the first check, just record the known count
        if self.knownTalentCount == 0 then
            self.knownTalentCount = currentKnownCount
        -- Otherwise, check if the count has changed
        elseif self.knownTalentCount ~= currentKnownCount then
            -- Talent changes detected - update display
            spellCheckCache = {}
            DungeonHelper:ShowSpellPopup(self.currentDungeonId)
            -- Update the stored count
            self.knownTalentCount = currentKnownCount
        end
    end)
end)

popupFrame:SetScript("OnHide", function(self)
    -- Cancel the talent counter when the popup is hidden
    if self.talentCounter then
        self.talentCounter:Cancel()
        self.talentCounter = nil
    end
end)

-- Create title text
local titleText = popupFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
titleText:SetPoint("TOP", 0, -15)
titleText:SetText("Helpful Spells for this Dungeon")
titleText:SetFont(titleText:GetFont(), 16, "OUTLINE")

-- Create refresh button
local refreshButton = CreateFrame("Button", nil, popupFrame, "UIPanelButtonTemplate")
refreshButton:SetSize(80, 22)
refreshButton:SetPoint("TOPRIGHT", -30, -15)
refreshButton:SetText("Refresh")
refreshButton:SetScript("OnClick", function()
    if popupFrame.currentDungeonId then
        -- Clear the spell cache and redraw the popup
        spellCheckCache = {}
        DungeonHelper:ShowSpellPopup(popupFrame.currentDungeonId)
    end
end)

-- Add tooltip to the refresh button
refreshButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Refresh Talent Information")
    GameTooltip:AddLine("Click to update the display after changing talents", 1, 1, 1, true)
    GameTooltip:Show()
end)

refreshButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- Create simple tab buttons using basic frames instead of templates
local currentTab = 1 -- 1 = My Talents only now
local tabWidth = 120
local tabHeight = 24

-- We'll remove all tab navigation for now to simplify the UI
-- Just create a simple header instead
local headerLabel = popupFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
headerLabel:SetPoint("TOPLEFT", 20, -30)
headerLabel:SetText("Class Talents")
headerLabel:SetFont(headerLabel:GetFont(), 12, "OUTLINE")
headerLabel:SetTextColor(1, 1, 1)

-- Create close button
local closeButton = CreateFrame("Button", nil, popupFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", -5, -5)
closeButton:SetScript("OnClick", function() popupFrame:Hide() end)

-- Create scroll frame for the content
local scrollFrame = CreateFrame("ScrollFrame", nil, popupFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 15, -60) -- Adjusted to make room for tabs
scrollFrame:SetPoint("BOTTOMRIGHT", -35, 15)

local contentFrame = CreateFrame("Frame", nil, scrollFrame)
contentFrame:SetSize(scrollFrame:GetWidth(), 1) -- Height will be adjusted dynamically
scrollFrame:SetScrollChild(contentFrame)

-- Event handler function
local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        -- Initialize when addon is loaded
        DungeonHelper:generate_lookup_table()
        
        -- Register for events
        frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        frame:RegisterEvent("CHALLENGE_MODE_START")
        frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:RegisterEvent("PLAYER_TALENT_UPDATE")
        frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
        frame:RegisterEvent("SPELLS_CHANGED")
        
        -- Make sure our functions are properly exposed to the addon namespace
        for k, v in pairs(DungeonHelper) do
            if type(v) == "function" then
                addon.DungeonHelper[k] = v
            end
        end
        
        -- Clear event to avoid duplicate initialization
        frame:UnregisterEvent("ADDON_LOADED")
        DebugPrint("Initialized DungeonHelper module")
        
        -- After addon is loaded, do a single check with a short delay
        -- to ensure all other addon components are fully initialized
        C_Timer.After(2, function()
            DebugPrint("Checking initial dungeon status (ADDON_LOADED)")
            DungeonHelper:DirectZoneCheck()
        end)
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        -- Use debouncing to prevent double checks when both events fire together
        local now = GetTime()
        if now - lastZoneCheck < 3 then -- Increased debounce to 3 seconds
            DebugPrint("Zone check debounced - too soon after previous check (from " .. event .. ")")
            
            -- Even if we debounce due to time, still schedule retries to ensure popup shows
            -- after map ID is finalized
            C_Timer.After(3, function()
                DungeonHelper:DirectZoneCheck()
            end)
            
            return
        end
        
        lastZoneCheck = now
        DebugPrint("Zone changed from event: " .. event)
        -- Check after a very short delay to ensure zone info is updated
        C_Timer.After(0.2, function()
            DungeonHelper:DirectZoneCheck()
        end)
    elseif event == "CHALLENGE_MODE_START" then
        -- Challenge mode has started, hide popup if it's shown
        DebugPrint("Challenge mode started, hiding popup")
        mythicChallengeStarted = true
        popupFrame:Hide()
        
        -- Cancel any pending popup timers
        if popupTimer then
            popupTimer:Cancel()
            popupTimer = nil
        end
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        -- Only update if already in a mythic dungeon with popup shown
        if isInMythicDungeon and not mythicChallengeStarted and currentDungeonId and popupFrame:IsShown() then
            DebugPrint("Spec changed, updating popup")
            spellCheckCache = {}
            DungeonHelper:ShowSpellPopup(currentDungeonId)
        end
    end
end

-- Set up the frame and register for events
frame:SetScript("OnEvent", OnEvent)
frame:RegisterEvent("ADDON_LOADED")

-- Initialize the module immediately as well
-- This ensures the module is available right away
addon.DungeonHelper = DungeonHelper

-- Function to scan party/raid members for class and spec info
function DungeonHelper:GetGroupMembersInfo()
    local groupMembers = {}
    local isInRaid = IsInRaid()
    local groupSize = isInRaid and GetNumGroupMembers() or GetNumGroupMembers(LE_PARTY_CATEGORY_HOME)
    
    -- Include player in the list
    local playerName = UnitName("player")
    local _, playerClass = UnitClass("player")
    local playerClassID = select(3, UnitClass("player"))
    local currentSpec = GetSpecialization()
    local specID = currentSpec and GetSpecializationInfo(currentSpec) or 0
    local specName = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "Unknown"
    
    table.insert(groupMembers, {
        name = playerName,
        class = playerClass,
        classID = playerClassID,
        specID = specID,
        specName = specName,
        isPlayer = true
    })
    
    -- Get info for other group members
    if groupSize > 0 then
        local prefix = isInRaid and "raid" or "party"
        for i = 1, groupSize do
            if isInRaid or i > 0 then -- Skip party1 which is the player in a party
                local unit = prefix .. i
                if UnitExists(unit) and not UnitIsUnit(unit, "player") then
                    local name = UnitName(unit)
                    local _, class = UnitClass(unit)
                    local classID = select(3, UnitClass(unit))
                    
                    -- Try to get spec info - may not be available for all party members
                    local specID = 0
                    local specName = "Unknown"
                    local inspectGUID = UnitGUID(unit)
                    
                    -- Note: Inspecting may not always return spec data immediately,
                    -- but we'll use what we can get for now
                    if inspectGUID then
                        -- Try to get from talent inspection if possible
                        -- We'll just show what we can determine without waiting for inspect data
                        specID = GetInspectSpecialization(unit) or 0
                        if specID > 0 then
                            -- Try to get spec name from ID if available
                            local id, name = GetSpecializationInfoByID(specID)
                            if name then
                                specName = name
                            end
                        end
                    end
                    
                    table.insert(groupMembers, {
                        name = name,
                        class = class,
                        classID = classID,
                        specID = specID,
                        specName = specName,
                        isPlayer = false
                    })
                end
            end
        end
    end
    
    return groupMembers
end

-- Function to get available spells for a specific class/spec
function DungeonHelper:GetSpellsForClassSpec(classId, specId, talentTypeIds)
    local spells = {}
    
    -- Find spells of these types for the specified class/spec
    if WOWOP_DUNGEON_DATABASE and WOWOP_DUNGEON_DATABASE.talent_class_spec then
        for _, entry in pairs(WOWOP_DUNGEON_DATABASE.talent_class_spec) do
            -- Get the class and spec IDs from the entry
            local entryClassId = entry.wow_class_id
            
            -- Check if this entry matches our class and spec
            if entryClassId == classId and 
               (entry.wow_spec_id == 0 or entry.wow_spec_id == specId) then
                for _, talentTypeId in ipairs(talentTypeIds) do
                    if entry.spell_type_id == talentTypeId then
                        -- Add this spell to our list
                        local alreadyAdded = false
                        for _, existingSpell in ipairs(spells) do
                            if existingSpell.spell_id == entry.spell_id then
                                alreadyAdded = true
                                break
                            end
                        end
                        
                        if not alreadyAdded then
                            table.insert(spells, {
                                spell_id = entry.spell_id,
                                spell_name = entry.spell_name,
                                spell_type_id = entry.spell_type_id
                            })
                        end
                    end
                end
            end
        end
    end
    
    return spells
end

-- Function to show the popup with spell information
function DungeonHelper:ShowSpellPopup(dungeonId)
    -- STRICT VALIDATION: Double check all necessary conditions before showing
    -- This ensures we never show the popup in the wrong circumstances
    
    -- Clear frame content even if it's already visible to prevent overlapping elements
    -- This ensures we don't have elements from previous dungeons still visible
    local shouldReuseFrame = popupFrame:IsShown()
    
    -- Don't show if we don't have a valid dungeon ID
    if not dungeonId or not WOWOP_DUNGEON_DATABASE.dungeon_talents[dungeonId] then 
        DebugPrint("Popup aborted - invalid dungeon ID:", dungeonId)
        return 
    end
    
    -- Check if the dungeon helper is disabled in settings
    if addon:IsDungeonHelperDisabled() then
        DebugPrint("Popup aborted - feature disabled in settings")
        return
    end
    
    -- Double-check that we're in a mythic+ dungeon
    local _, instanceType, difficultyID = GetInstanceInfo()
    if instanceType ~= "party" or difficultyID ~= 23 then
        DebugPrint("Popup aborted - not in a Mythic Keystone dungeon. Instance type:", instanceType, "Difficulty:", difficultyID)
        return
    end
    
    -- Check if challenge mode is active - don't show if it is
    if self:IsChallengeModeActive() then
        DebugPrint("Popup aborted - challenge mode is active")
        return
    end
    
    -- Store current dungeon ID globally and on the frame itself
    currentDungeonId = dungeonId
    popupFrame.currentDungeonId = dungeonId
    
    local classId, specId = self:GetPlayerClassAndSpec()
    if not classId then 
        DebugPrint("Popup aborted - could not determine class information")
        return 
    end
    
    -- Get dungeon name
    local dungeonName = WOWOP_DUNGEON_DATABASE.dungeons[dungeonId] and WOWOP_DUNGEON_DATABASE.dungeons[dungeonId].name or "Unknown Dungeon"
    titleText:SetText("Helpful Spells for " .. dungeonName)
    
    -- Completely reset the content frame to prevent layout issues when switching tabs
    -- First, remove all existing content and destroy all widgets
    for _, child in pairs({contentFrame:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
        child:ClearAllPoints()
    end
    
    -- Also clean up any FontStrings in the content frame (these aren't captured by GetChildren)
    for _, region in pairs({contentFrame:GetRegions()}) do
        if region:GetObjectType() == "FontString" then
            region:Hide()
            region:SetParent(nil)
            region:ClearAllPoints()
        end
    end
    
    -- Reset content frame size and scroll position
    contentFrame:SetSize(scrollFrame:GetWidth(), 1)
    scrollFrame:SetVerticalScroll(0)
    
    -- Create new content
    local yOffset = 10
    
    -- Add info about disabling the feature in settings
    local settingsInfo = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsInfo:SetPoint("TOP", 0, -yOffset)
    settingsInfo:SetWidth(contentFrame:GetWidth() - 20)
    settingsInfo:SetJustifyH("CENTER")
    settingsInfo:SetText("This feature can be disabled in the WoWOP.io settings")
    settingsInfo:SetTextColor(0.7, 0.7, 1)
    yOffset = yOffset + 25
    
    local numCategories = 0
    
    -- Get the talent types needed for this dungeon
    local relevantTalentTypes = {}
    
    -- First add dungeon-specific talent types
    for _, talentTypeId in ipairs(WOWOP_DUNGEON_DATABASE.dungeon_talents[dungeonId]) do
        if WOWOP_DUNGEON_DATABASE.talent_spell_types[talentTypeId] then
            table.insert(relevantTalentTypes, talentTypeId)
        end
    end
    
    -- Then add common abilities (from dungeon_id 0) if available
    if dungeonId ~= 0 and WOWOP_DUNGEON_DATABASE.dungeon_talents[0] then
        for _, talentTypeId in ipairs(WOWOP_DUNGEON_DATABASE.dungeon_talents[0]) do
            if WOWOP_DUNGEON_DATABASE.talent_spell_types[talentTypeId] then
                -- Check if this talent type is already in the list
                local exists = false
                for _, existingTypeId in ipairs(relevantTalentTypes) do
                    if existingTypeId == talentTypeId then
                        exists = true
                        break
                    end
                end
                
                if not exists then
                    table.insert(relevantTalentTypes, talentTypeId)
                end
            end
        end
    end
    
    -- Sort by category for better organization
    table.sort(relevantTalentTypes, function(a, b)
        local typeA = WOWOP_DUNGEON_DATABASE.talent_spell_types[a].talent_type
        local typeB = WOWOP_DUNGEON_DATABASE.talent_spell_types[b].talent_type
        if typeA == typeB then
            return WOWOP_DUNGEON_DATABASE.talent_spell_types[a].talent_subtype < WOWOP_DUNGEON_DATABASE.talent_spell_types[b].talent_subtype
        end
        return typeA < typeB
    end)
    
    -- Group by category
    local categories = {}
    for _, talentTypeId in ipairs(relevantTalentTypes) do
        local talentType = WOWOP_DUNGEON_DATABASE.talent_spell_types[talentTypeId].talent_type
        local talentSubtype = WOWOP_DUNGEON_DATABASE.talent_spell_types[talentTypeId].talent_subtype
        
        if not categories[talentType] then
            categories[talentType] = {}
        end
        
        if not categories[talentType][talentSubtype] then
            categories[talentType][talentSubtype] = {}
        end
        
        table.insert(categories[talentType][talentSubtype], talentTypeId)
    end
    
    -- Now create the UI elements for each category
    local categoriesShown = false
    
    -- Now create the UI elements for each category
    for categoryType, subtypes in pairs(categories) do
        local categoryHasSpells = false
        local subtypesWithSpells = {}
        
        -- Pre-check if this category has spells for the player
        for subtypeName, talentTypeIds in pairs(subtypes) do
            local subtypeHasSpells = false
            local spellsForPlayer = {}
            
            -- Find spells of this type for the player's class/spec
            for _, entry in pairs(WOWOP_DUNGEON_DATABASE.talent_class_spec) do
                -- Get the class and spec IDs from the entry
                local entryClassId = entry.wow_class_id
                
                -- Check if this entry matches our class and spec
                if entryClassId == classId and 
                   (entry.wow_spec_id == 0 or entry.wow_spec_id == specId) then
                    for _, talentTypeId in ipairs(talentTypeIds) do
                        if entry.spell_type_id == talentTypeId then
                            -- Add this spell to our list
                            local alreadyAdded = false
                            for _, existingSpell in ipairs(spellsForPlayer) do
                                if existingSpell.spell_id == entry.spell_id then
                                    alreadyAdded = true
                                    break
                                end
                            end
                            
                            if not alreadyAdded then
                                table.insert(spellsForPlayer, {
                                    spell_id = entry.spell_id,
                                    spell_name = entry.spell_name
                                })
                                subtypeHasSpells = true
                                categoryHasSpells = true
                            end
                        end
                    end
                end
            end
            
            if subtypeHasSpells then
                subtypesWithSpells[subtypeName] = {
                    talentTypeIds = talentTypeIds,
                    spells = spellsForPlayer
                }
            end
        end
        
        -- Only show categories that have spells for the player
        if categoryHasSpells then
            categoriesShown = true
            
            -- Category header
            local categoryLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            categoryLabel:SetPoint("TOPLEFT", 5, -yOffset)
            categoryLabel:SetText(SPELL_TYPE_LABELS[categoryType] or categoryType)
            categoryLabel:SetFont(categoryLabel:GetFont(), 14, "OUTLINE")
            categoryLabel:SetTextColor(1, 0.82, 0)
            yOffset = yOffset + 25
            
            -- List each subtype that has spells
            for subtypeName, subtypeData in pairs(subtypesWithSpells) do
                -- Subtype header
                local subtypeLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                subtypeLabel:SetPoint("TOPLEFT", 15, -yOffset)
                subtypeLabel:SetText(SPELL_SUBTYPE_LABELS[subtypeName] or subtypeName)
                subtypeLabel:SetFont(subtypeLabel:GetFont(), 12)
                subtypeLabel:SetTextColor(0.9, 0.9, 0.9)
                yOffset = yOffset + 20
                
                -- Add the spells to the UI
                for _, spellInfo in ipairs(subtypeData.spells) do
                    local spellId = spellInfo.spell_id
                    local spellName = spellInfo.spell_name
                    local knowsSpell = self:PlayerKnowsSpell(spellId)
                    
                    -- Create a row for this spell
                    local spellRow = CreateFrame("Frame", nil, contentFrame)
                    spellRow:SetSize(contentFrame:GetWidth() - 40, 24)
                    spellRow:SetPoint("TOPLEFT", 30, -yOffset)
                    
                    -- Add spell icon
                    local spellIcon = spellRow:CreateTexture(nil, "ARTWORK")
                    spellIcon:SetSize(20, 20)
                    spellIcon:SetPoint("LEFT", 0, 0)
                    
                    -- Use a simpler approach to get spell icons that works across WoW versions
                    -- Set a default question mark icon
                    spellIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
                    
                    -- Try to set icon via C_Spell if available (WoW 10.0+)
                    if C_Spell and C_Spell.GetSpellTexture then
                        local iconTexture = C_Spell.GetSpellTexture(spellId)
                        if iconTexture then
                            spellIcon:SetTexture(iconTexture)
                        end
                    end
                    
                    -- Add status icon (checkmark or X)
                    local statusTexture = spellRow:CreateTexture(nil, "OVERLAY")
                    statusTexture:SetSize(16, 16)
                    statusTexture:SetPoint("LEFT", spellIcon, "RIGHT", 5, 0)
                    
                    -- Add spell name
                    local spellLabel = spellRow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    spellLabel:SetPoint("LEFT", statusTexture, "RIGHT", 5, 0)
                    spellLabel:SetText(spellName)
                    
                    -- Set color based on whether player knows the spell
                    if knowsSpell then
                        spellLabel:SetTextColor(0, 1, 0)
                        statusTexture:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
                    else
                        spellLabel:SetTextColor(1, 0, 0)
                        statusTexture:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")
                    end
                    
                    -- Make the spell row interactive
                    spellRow:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        
                        -- Safer tooltip approach
                        if spellId then 
                            -- Try to use the ID directly, which is the modern approach
                            if GameTooltip.SetSpellByID then
                                GameTooltip:SetSpellByID(spellId)
                            -- Fallback to setting by name if the ID approach isn't available
                            elseif C_Spell and C_Spell.GetSpellLink then
                                local spellLink = C_Spell.GetSpellLink(spellId)
                                if spellLink then
                                    GameTooltip:SetHyperlink(spellLink)
                                else
                                    GameTooltip:SetText(spellName or "Unknown Spell")
                                end
                            else
                                GameTooltip:SetText(spellName or "Unknown Spell")
                            end
                        else
                            GameTooltip:SetText(spellName or "Unknown Spell")
                        end
                        
                        GameTooltip:Show()
                    end)
                    
                    spellRow:SetScript("OnLeave", function(self)
                        GameTooltip:Hide()
                    end)
                    
                    yOffset = yOffset + 24
                end
                
                yOffset = yOffset + 5
            end
            
            yOffset = yOffset + 15
            numCategories = numCategories + 1
        end
    end
    
    -- If no categories were shown for the player, display a message
    if not categoriesShown then
        local noSpellsLabel = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        noSpellsLabel:SetPoint("CENTER", 0, 0)
        noSpellsLabel:SetText("No relevant spells found for your class/spec in this dungeon")
        noSpellsLabel:SetTextColor(1, 1, 1)
    end
    
    -- Adjust content frame height
    contentFrame:SetHeight(math.max(yOffset, scrollFrame:GetHeight()))
    
    -- Show the popup
    popupFrame:Show()
end

-- Function to check if a keystone challenge is active
function DungeonHelper:IsChallengeModeActive()
    -- Check multiple APIs to ensure we detect the challenge in all WoW versions
    if C_ChallengeMode then
        -- Most reliable method in recent versions
        if C_ChallengeMode.IsChallengeModeActive and type(C_ChallengeMode.IsChallengeModeActive) == "function" then
            return C_ChallengeMode.IsChallengeModeActive()
        end
        
        -- Alternative methods
        if C_ChallengeMode.GetActiveKeystoneInfo and type(C_ChallengeMode.GetActiveKeystoneInfo) == "function" then
            local dungeonID = C_ChallengeMode.GetActiveKeystoneInfo()
            return dungeonID ~= nil and dungeonID > 0
        elseif C_ChallengeMode.GetActiveKeyInfo and type(C_ChallengeMode.GetActiveKeyInfo) == "function" then
            local _, _, challengeMapID = C_ChallengeMode.GetActiveKeyInfo()
            return challengeMapID ~= nil and challengeMapID > 0
        end
    end
    
    -- If we couldn't determine, default to not active
    return false
end

-- Add a special debug slash command
SLASH_DHCHECK1 = "/dhcheck"
SlashCmdList["DHCHECK"] = function(msg)
    if msg == "debug" then
        debugMode = not debugMode
        print("|cffff00ffDungeonHelper:|r Debug mode", debugMode and "enabled" or "disabled")
        return
    elseif msg == "debug off" then
        debugMode = false
        print("|cffff00ffDungeonHelper:|r Debug mode disabled")
        return
    elseif msg == "debug on" then
        debugMode = true
        print("|cffff00ffDungeonHelper:|r Debug mode enabled")
        return
    elseif msg == "dungeons" then
        print("|cffff00ffDungeonHelper:|r Listing all dungeons in database:")
        for dungeonId, dungeonData in pairs(WOWOP_DUNGEON_DATABASE.dungeons) do
            print(string.format("ID: %d, Name: %s, Zone ID: %s", 
                dungeonId, dungeonData.name or "Unknown", dungeonData.game_zone_id or "nil"))
        end
        return
    elseif msg:match("^fix%s+(%d+)%s+(%d+)$") then
        local mapId, dungeonId = msg:match("^fix%s+(%d+)%s+(%d+)$")
        mapId = tonumber(mapId)
        dungeonId = tonumber(dungeonId)
        
        if mapId and dungeonId then
            print(string.format("|cffff00ffDungeonHelper:|r Adding manual correction: Map ID %d -> Dungeon ID %d", 
                mapId, dungeonId))
            
            -- The correction will only last for this session until reload
            -- You'll need to add it to the code for a permanent fix
            DungeonHelper._manualCorrections = DungeonHelper._manualCorrections or {}
            DungeonHelper._manualCorrections[mapId] = dungeonId
            
            print("|cffff00ffDungeonHelper:|r Correction added. Use /reload to apply permanently.")
        else
            print("|cffff00ffDungeonHelper:|r Invalid parameters. Format: /dhcheck fix [mapId] [dungeonId]")
        end
        return
    end
    
    print("|cffff00ffDungeonHelper:|r Checking dungeon status...")
    
    -- Check if we're in a mythic dungeon
    local inMythicDungeon = DungeonHelper:IsInMythicDungeon()
    print("|cffff00ffDungeonHelper:|r In mythic dungeon:", inMythicDungeon)
    
    -- Get zone info
    local mapID = C_Map.GetBestMapForUnit("player")
    local _, instanceType, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()
    
    print("|cffff00ffDungeonHelper:|r Map ID:", mapID)
    print("|cffff00ffDungeonHelper:|r Instance type:", instanceType)
    print("|cffff00ffDungeonHelper:|r Difficulty ID:", difficultyID)
    print("|cffff00ffDungeonHelper:|r Instance ID:", instanceID)
    
    -- Check if we got a dungeon ID
    local dungeonId = DungeonHelper:GetDungeonIdFromZone()
    print("|cffff00ffDungeonHelper:|r Dungeon ID:", dungeonId)
    
    if dungeonId and WOWOP_DUNGEON_DATABASE.dungeons[dungeonId] then
        print("|cffff00ffDungeonHelper:|r Dungeon name:", WOWOP_DUNGEON_DATABASE.dungeons[dungeonId].name)
    end
    
    -- Check if challenge mode is active
    local challengeActive = DungeonHelper:IsChallengeModeActive()
    print("|cffff00ffDungeonHelper:|r Challenge active:", challengeActive)
    
    -- Lookup zone info in the mapping table
    local zoneId = WOWOP_LOOKUPS.instance_to_zone[mapID]
    print("|cffff00ffDungeonHelper:|r Map ID", mapID, "maps to zone ID:", zoneId)
    
    -- Force dungeon detection process
    if inMythicDungeon and dungeonId and not challengeActive then
        print("|cffff00ffDungeonHelper:|r Conditions met for showing popup, requesting display...")
        spellCheckCache = {}
        
        -- Make sure we don't have multiple popups queued
        if popupTimer then
            popupTimer:Cancel()
        end
        
        -- Show popup immediately
        DungeonHelper:ShowSpellPopup(dungeonId)
    else
        print("|cffff00ffDungeonHelper:|r Conditions not met for showing popup")
    end
end

-- Direct zone check function - simplified and focused on immediate zone information
function DungeonHelper:DirectZoneCheck(attemptCount)
    attemptCount = attemptCount or 1
    DebugPrint("Performing direct zone check (attempt " .. attemptCount .. ")")
    
    -- Check if the dungeon helper is disabled in settings
    if addon:IsDungeonHelperDisabled() then
        DebugPrint("Dungeon helper disabled in settings")
        return
    end
    
    -- Cancel any existing popup timer
    if popupTimer then
        DebugPrint("Cancelling existing popup timer")
        popupTimer:Cancel()
        popupTimer = nil
    end
    
    -- Get detailed instance info
    local _, instanceType, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()
    DebugPrint("Instance info: type =", instanceType, "difficulty =", difficultyID, "instance ID =", instanceID)
    
    -- Capture map ID for diagnostic purposes
    local currentMapID = C_Map.GetBestMapForUnit("player")
    DebugPrint("Current map ID =", currentMapID, "(before condition checks)")
    
    -- FIRST CONDITION: Must be in a party (dungeon) instance with Mythic Keystone difficulty (23)
    if instanceType ~= "party" or difficultyID ~= 23 then
        DebugPrint("Not in a Mythic Keystone dungeon")
        
        -- Reset state if we were previously in a mythic dungeon
        if isInMythicDungeon then
            DebugPrint("Leaving mythic dungeon, cleaning up")
            isInMythicDungeon = false
            mythicChallengeStarted = false
            currentDungeonId = nil
            popupFrame:Hide()
        end
        return
    end
    
    -- SECOND CONDITION: Challenge must not be active
    local challengeActive = self:IsChallengeModeActive()
    DebugPrint("Challenge active:", challengeActive)
    
    if challengeActive then
        DebugPrint("Challenge is active, won't show popup")
        mythicChallengeStarted = true
        
        -- Hide popup if it's showing
        if popupFrame:IsShown() then
            popupFrame:Hide()
        end
        return
    end
    
    -- THIRD CONDITION: Must have a valid dungeon ID
    local dungeonId = self:GetDungeonIdFromZone()
    DebugPrint("Dungeon ID:", dungeonId)
    
    if not dungeonId then
        DebugPrint("Could not determine dungeon ID, will retry")
        
        -- Always retry multiple times if we're in a dungeon
        if attemptCount < 5 then  -- Increased to 5 attempts
            local delaySeconds = attemptCount * 1.5  -- Slightly shorter delays, more attempts
            DebugPrint("Will retry dungeon detection in " .. delaySeconds .. " seconds (attempt " .. attemptCount .. " of 5)")
            
            C_Timer.After(delaySeconds, function()
                -- Force a UI update to help with map ID resolution
                if attemptCount == 1 then
                    DebugPrint("Requesting UI update to help with map resolution")
                    collectgarbage("collect")  -- This sometimes helps with API state
                end
                
                self:DirectZoneCheck(attemptCount + 1)
            end)
        else
            DebugPrint("Giving up automatic detection after " .. attemptCount .. " attempts")
            DebugPrint("Use /dhcheck to manually trigger detection")
        end
        
        return
    end
    
    -- FOURTH CONDITION: Dungeon ID must be in our database
    if not WOWOP_DUNGEON_DATABASE.dungeons[dungeonId] then
        DebugPrint("Invalid dungeon ID, not in database:", dungeonId)
        return
    end
    
    DebugPrint("Valid dungeon:", WOWOP_DUNGEON_DATABASE.dungeons[dungeonId].name)
    
    -- All conditions passed - we're in a mythic dungeon with no active challenge
    isInMythicDungeon = true
    currentDungeonId = dungeonId
    mythicChallengeStarted = false
    
    -- Clear spell cache
    spellCheckCache = {}
    
    -- Show popup if not already shown
    if not popupFrame:IsShown() then
        DebugPrint("All conditions met, showing popup")
        self:ShowSpellPopup(dungeonId)
    end
end
