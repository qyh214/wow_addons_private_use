local addonName, addon = ...

-- Create the death analysis frame
local DeathAnalysisFrame = CreateFrame("Frame", "WowopDeathAnalysisFrame", UIParent, "UIPanelDialogTemplate")
DeathAnalysisFrame:SetSize(400, 270)
DeathAnalysisFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, -100)
DeathAnalysisFrame:SetMovable(true)
DeathAnalysisFrame:EnableMouse(true)
DeathAnalysisFrame:RegisterForDrag("LeftButton")
DeathAnalysisFrame:SetScript("OnDragStart", DeathAnalysisFrame.StartMoving)
DeathAnalysisFrame:SetScript("OnDragStop", DeathAnalysisFrame.StopMovingOrSizing)
DeathAnalysisFrame:Hide()

-- Add title text
DeathAnalysisFrame.title = DeathAnalysisFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
DeathAnalysisFrame.title:SetPoint("TOP", 0, -15)
DeathAnalysisFrame.title:SetText("Death Analysis")

-- Add content text
DeathAnalysisFrame.content = DeathAnalysisFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
DeathAnalysisFrame.content:SetPoint("TOPLEFT", 15, -40)
DeathAnalysisFrame.content:SetPoint("BOTTOMRIGHT", -15, 40)
DeathAnalysisFrame.content:SetJustifyH("LEFT")
DeathAnalysisFrame.content:SetJustifyV("TOP")
DeathAnalysisFrame.content:SetSpacing(3)

-- Add close button
local closeButton = CreateFrame("Button", nil, DeathAnalysisFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", DeathAnalysisFrame, "TOPRIGHT")

-- Near the top with other local variables
local function IsInDungeon()
    local _, instanceType = IsInInstance()
    return instanceType == "party"
end

-- Create event frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

-- Near the top with other local variables
local recentDamageEvents = {}
local DAMAGE_HISTORY_SECONDS = 5
local MAX_SPELL_LOAD_ATTEMPTS = 5
local SPELL_LOAD_RETRY_DELAY = 0.2

-- Add near the top with other local variables
local SPELL_ICONS = {
    tank = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES",
    healer = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES",
    dps = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES"
}

local SPELL_ICON_COORDS = {
    tank = {0, 0.25, 0.25, 0.5},          -- Tank icon
    healer = {0.25, 0.5, 0, 0.25},        -- Healer icon
    dps = {0.25, 0.5, 0.25, 0.5}          -- DPS icon
}

-- Function to clean old damage events
local function CleanOldDamageEvents()
    local currentTime = GetTime()
    local cutoffTime = currentTime - DAMAGE_HISTORY_SECONDS
    
    -- Remove events older than cutoff time
    for i = #recentDamageEvents, 1, -1 do
        if recentDamageEvents[i].timestamp < cutoffTime then
            table.remove(recentDamageEvents, i)
        end
    end
end

-- Function to add damage event
local function AddDamageEvent(spellId, spellName, amount, overkill, timestamp)
    table.insert(recentDamageEvents, {
        spellId = spellId or "melee",
        spellName = spellName or "Melee",
        amount = tonumber(amount) or 0,
        overkill = tonumber(overkill) or 0,
        timestamp = timestamp or GetTime()
    })
    CleanOldDamageEvents()
end

-- Function to try getting spell description with retries
addon.TryGetSpellDescription = function(spellId, callback, attempt)
    attempt = attempt or 1
    
    -- Request the spell data
    C_Spell.RequestLoadSpellData(spellId)
    
    C_Timer.After(SPELL_LOAD_RETRY_DELAY, function()
        local spellDesc = C_Spell.GetSpellDescription(spellId)
        if spellDesc and spellDesc ~= "" then
            -- Success! Call the callback with the description
            callback(spellDesc)
        elseif attempt < MAX_SPELL_LOAD_ATTEMPTS then
            -- Try again
            addon.TryGetSpellDescription(spellId, callback, attempt + 1)
        else
            -- Give up after max attempts
            callback(nil)
        end
    end)
end

-- Function to create role icons
local function CreateRoleIcons(parent, spellInfo)
    -- Create container frame for icons
    local iconsFrame = CreateFrame("Frame", nil, parent)
    iconsFrame:SetSize(200, 20)
    iconsFrame:SetPoint("TOPLEFT", parent.content, "BOTTOMLEFT", 0, -5)

    local iconSize = 16
    local iconSpacing = 2
    local xOffset = 0

    -- Function to create icon with tooltip
    local function CreateIcon(iconType, tooltip)
        local icon = iconsFrame:CreateTexture(nil, "ARTWORK")
        icon:SetSize(iconSize, iconSize)
        icon:SetPoint("LEFT", xOffset, 0)
        icon:SetTexture(SPELL_ICONS[iconType])
        icon:SetTexCoord(unpack(SPELL_ICON_COORDS[iconType]))
        
        -- Create invisible button for tooltip
        local button = CreateFrame("Button", nil, iconsFrame)
        button:SetAllPoints(icon)
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(tooltip, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        
        xOffset = xOffset + iconSize + iconSpacing
        return icon
    end

    -- Add label
    local label = iconsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", 0, 0)
    label:SetText("Counts as Heavy Fail for: ")
    xOffset = label:GetStringWidth() + 5

    -- Add role icons
    if spellInfo.heavy_fail_tank and spellInfo.heavy_fail_tank == 1 then
        CreateIcon("tank", "Tank Mechanic\nTanks need to handle this correctly")
    end
    if spellInfo.heavy_fail_healer and spellInfo.heavy_fail_healer == 1 then
        CreateIcon("healer", "Healer Mechanic\nHealers need to handle this correctly")
    end
    if spellInfo.heavy_fail_dps and spellInfo.heavy_fail_dps == 1 then
        CreateIcon("dps", "DPS Mechanic\nDPS need to handle this correctly")
    end

    return iconsFrame
end

-- Function to show death analysis
local function ShowDeathAnalysis(spellId, mobId)
    -- Check if death popup is disabled in settings
    if not addon:IsDeathPopupEnabled() then
        return
    end

    if not WOWOP_DUNGEON_DATABASE then
        print("WoWOP.io: Error - Dungeon database not loaded!")
        return
    end
    
    -- Find spell info in the dungeon database
    local spellInfo = nil
    local mobName = nil
    
    -- Search all dungeons for the spell
    for dungeonId, dungeonData in pairs(WOWOP_DUNGEON_DATABASE.dungeons) do
        for _, mobData in pairs(dungeonData.mobs) do
            if mobData.spells[spellId] then
                spellInfo = mobData.spells[spellId]
                mobName = mobData.name
                break
            end
        end
        if spellInfo then break end
    end
    
    if not spellInfo then
        print(string.format("WoWOP.io: No information found for spell ID %d", spellId))
        return
    end
    
    if spellInfo.deadly == 1 or spellInfo.heavy_fail_dps == 1 or 
       spellInfo.heavy_fail_healer == 1 or spellInfo.heavy_fail_tank == 1 then
        
        local text = string.format("You died to |cffff0000%s|r cast by %s\n\n", 
            spellInfo.name, mobName)
        
        -- Show frame immediately with loading message
        DeathAnalysisFrame.content:SetText(text .. "Loading spell information...")
        DeathAnalysisFrame:Show()
        
        -- Remove old icons frame if it exists
        if DeathAnalysisFrame.iconsFrame then
            DeathAnalysisFrame.iconsFrame:Hide()
            DeathAnalysisFrame.iconsFrame = nil
        end
        
        -- Try to get spell description
        addon.TryGetSpellDescription(spellId, function(spellDesc)
            if spellDesc then
                text = text .. "Spell Description:\n" .. spellDesc .. "\n\n"
            end
            
            if spellInfo.countermeasures and spellInfo.countermeasures ~= "" then
                text = text .. "|cFF00FF00Countermeasures:|r\n" .. spellInfo.countermeasures
            else
                text = text .. "No specific countermeasures available."
            end
            
            DeathAnalysisFrame.content:SetText(text)

            -- Create role icons after setting the text
            DeathAnalysisFrame.iconsFrame = CreateRoleIcons(DeathAnalysisFrame, spellInfo)
        end)
    else
        print(string.format("WoWOP.io: Spell %d (%s) is not marked as deadly or heavy fail", 
            spellId, spellInfo.name))
    end
end

-- Function to find the most important spell from recent events
local function FindMostImportantSpell()
    local mostImportantSpell = nil
    local highestPriority = -1

    for _, event in ipairs(recentDamageEvents) do
        -- Search through all dungeons for this spell
        for dungeonId, dungeonData in pairs(WOWOP_DUNGEON_DATABASE.dungeons) do
            for _, mobData in pairs(dungeonData.mobs) do
                local spellInfo = mobData.spells[event.spellId]
                if spellInfo then
                    -- Calculate priority (deadly being highest, then heavy fails)
                    local priority = 0
                    if spellInfo.deadly == 1 then priority = priority + 4 end
                    if spellInfo.heavy_fail_dps == 1 then priority = priority + 1 end
                    if spellInfo.heavy_fail_healer == 1 then priority = priority + 1 end
                    if spellInfo.heavy_fail_tank == 1 then priority = priority + 1 end

                    if priority > highestPriority then
                        highestPriority = priority
                        mostImportantSpell = event.spellId
                    end
                end
            end
        end
    end

    return mostImportantSpell
end

-- Add this function near the event registration
local function UpdateCombatLogRegistration()
    if IsInDungeon() then
        -- Only register combat log events when in a dungeon
        eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end

-- Event handler
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        UpdateCombatLogRegistration()
        return
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, 
              destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
        
        -- Early return if the event isn't for the player
        if destGUID ~= UnitGUID("player") then return end
        
        if subevent == "SPELL_DAMAGE" then
            local _, _, _, _, _, _, _, _, _, _, _, spellId, spellName, _, amount, overkill = CombatLogGetCurrentEventInfo()
            AddDamageEvent(spellId, spellName, amount, overkill)
        elseif subevent == "SWING_DAMAGE" then
            -- Melee damage (note: parameters are different for SWING_DAMAGE)
            local meleeAmount = spellId -- in SWING_DAMAGE, the damage is in the spellId position
            local meleeOverkill = spellName -- overkill is in the spellName position for SWING_DAMAGE
            AddDamageEvent(nil, "Melee", meleeAmount, meleeOverkill)
        elseif subevent == "SPELL_PERIODIC_DAMAGE" then
            -- DoT damage
            local _, _, _, _, _, _, _, _, _, _, _, _, _, _, amount, overkill = CombatLogGetCurrentEventInfo()
            AddDamageEvent(spellId, spellName, amount, overkill)
        elseif subevent == "RANGE_DAMAGE" then
            -- Ranged damage
            local _, _, _, _, _, _, _, _, _, _, _, _, _, _, amount, overkill = CombatLogGetCurrentEventInfo()
            AddDamageEvent(spellId, spellName, amount, overkill)
        elseif subevent == "UNIT_DIED" then
            -- Debug output
            print("WoWOP.io: You died. Recent damage events:")
            
            -- Sort events by timestamp, oldest first
            table.sort(recentDamageEvents, function(a, b) 
                return a.timestamp < b.timestamp 
            end)
            
            -- Print recent damage events
            for _, event in ipairs(recentDamageEvents) do
                local timeAgo = GetTime() - event.timestamp
                local damageText = event.amount
                if event.overkill and event.overkill > 0 then
                    damageText = string.format("%d (%d Overkill)", event.amount, event.overkill)
                end
                
                -- Create clickable spell link if it's a spell (not melee)
                local spellText
                if event.spellId ~= "melee" then
                    spellText = string.format("|cff71d5ff|Hspell:%d|h[%s]|h|r", 
                        event.spellId, 
                        event.spellName)
                        
                        -- Check if this spell has countermeasures
                        local foundCountermeasure = false
                        for dungeonId, dungeonData in pairs(WOWOP_DUNGEON_DATABASE.dungeons) do
                            if foundCountermeasure then break end
                            for _, mobData in pairs(dungeonData.mobs) do
                                local spellInfo = mobData.spells[event.spellId]
                                if spellInfo and spellInfo.countermeasures and spellInfo.countermeasures ~= "" then
                                    print(string.format("|cFF00FF00Countermeasure for %s:|r %s", 
                                        spellText, spellInfo.countermeasures))
                                    foundCountermeasure = true
                                    break
                                end
                            end
                        end
                    else
                        spellText = event.spellName
                    end
                    
                    print(string.format("%.1f seconds ago: %s (%s) for %s damage", 
                        timeAgo,
                        spellText,
                        event.spellId == "melee" and "Melee" or "ID: " .. (event.spellId or "unknown"),
                        damageText))
            end
            
            -- Find and analyze the most important spell from recent events
            local importantSpellId = FindMostImportantSpell()
            if importantSpellId and importantSpellId ~= "melee" then
                ShowDeathAnalysis(importantSpellId)
            end
            
            -- Clear the damage events
            recentDamageEvents = {}
        end
    end
end)

-- Add test function to addon namespace
function addon:TestDeathAnalysis(spellId)
    if not spellId then
        print("Usage: /wowop test <spellId>")
        return
    end
    
    spellId = tonumber(spellId)
    if not spellId then
        print("Invalid spell ID")
        return
    end
    
    -- Debug output
    local spellInfo = C_Spell.GetSpellInfo(spellId)
    print(string.format("WoWOP.io Debug: Testing spell: ID=%s, Name=%s", 
        spellId, spellInfo and spellInfo.name or "unknown"))
    
    ShowDeathAnalysis(spellId)
end 