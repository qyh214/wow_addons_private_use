-- At the very top of the file
local addonName, addon = ...

-- Forward declare all functions we'll need
local CheckSpellData
local CreateScrollFrame
local CreateListButton
local PopulateSpells
local PopulateMobs
local PopulateDungeons
local CreateMainFrame

-- Variables
local isSpellDataLoaded = false
local pendingSpellCheck = false
local hasInitialized = false
local DungeonGuideFrame
local dungeonList, dungeonScroll, mobList, mobScroll, spellList, spellScroll

-- Add at the top with other variables
local SPELL_ICONS = {
    deadly = "Interface\\EncounterJournal\\UI-EJ-Icons",
    important = "Interface\\EncounterJournal\\UI-EJ-Icons",
    interruptible = "Interface\\EncounterJournal\\UI-EJ-Icons",
    avoidable = "Interface\\EncounterJournal\\UI-EJ-Icons",
    tank = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES",
    healer = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES",
    dps = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES"
}

local SPELL_ICON_COORDS = {
    deadly = {0.25, 0.5, 0.5, 0.75},      -- Skull icon
    important = {0.5, 0.75, 0.5, 0.75},   -- Exclamation mark
    interruptible = {0.75, 1, 0.5, 0.75}, -- Hand icon
    avoidable = {0, 0.25, 0.5, 0.75},     -- Arrow icon
    tank = {0, 0.25, 0.25, 0.5},          -- Tank icon
    healer = {0.25, 0.5, 0, 0.25},        -- Healer icon
    dps = {0.25, 0.5, 0.25, 0.5}          -- DPS icon
}

-- Add tag colors
local TAG_COLORS = {
    deadly = "FF0000",      -- Red
    important = "FFA500",   -- Orange
    interruptible = "00FFFF", -- Cyan
    avoidable = "00FF00"    -- Green
}

-- Function to create a proper scroll frame with scroll bar
CreateScrollFrame = function(parent, name, width, height)
    local frame = CreateFrame("ScrollFrame", name, parent, "UIPanelScrollFrameTemplate")
    frame:SetSize(width - 16, height) -- Reduce width to account for scrollbar
    
    -- Create the scroll child
    local scrollChild = CreateFrame("Frame", name.."ScrollChild", frame)
    scrollChild:SetSize(width - 16, 1) -- Width same as frame minus scrollbar, height will be dynamic
    frame:SetScrollChild(scrollChild)
    
    -- Adjust scrollbar position
    local scrollBar = _G[frame:GetName().."ScrollBar"]
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint("TOPLEFT", frame, "TOPRIGHT", 1, -16)
    scrollBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 1, 16)
    
    return frame, scrollChild
end

-- Function to create a button with highlight
CreateListButton = function(parent, width, height, spellId)
    local button = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
    button:SetSize(width, height)
    
    -- Set up backdrop
    button:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    button:SetBackdropColor(0, 0, 0, 0)
    
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.2)
    
    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", 8, 0)
    text:SetPoint("RIGHT", -8, 0)
    text:SetJustifyH("LEFT")
    button.text = text
    
    return button
end

-- Function to populate spell list for a mob
PopulateSpells = function(dungeonId, selectedMobId)
    -- Clear existing content
    for _, child in pairs({spellScroll:GetChildren()}) do
        child:Hide()
    end
    
    -- Get spells either from specific mob or all dungeon spells
    local spells_to_show = {}
    local dungeon = WOWOP_DUNGEON_DATABASE.dungeons[dungeonId]
    
    if selectedMobId then
        -- Get spells from specific mob
        if dungeon and dungeon.mobs[selectedMobId] then
            for spellId, spell in pairs(dungeon.mobs[selectedMobId].spells) do
                spells_to_show[spellId] = {
                    spell = spell,
                    mob_name = dungeon.mobs[selectedMobId].name
                }
            end
        end
    else
        -- Get all spells from all mobs in the dungeon
        if dungeon then
            for mobId, mob in pairs(dungeon.mobs) do
                for spellId, spell in pairs(mob.spells) do
                    spells_to_show[spellId] = {
                        spell = spell,
                        mob_name = mob.name
                    }
                end
            end
        end
    end
    
    if next(spells_to_show) == nil then
        -- No spells found
        local text = spellScroll:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER")
        text:SetText(selectedMobId and "No spells found for this mob" or "No spells found in this dungeon")
        return
    end
    
    -- Sort spells by importance
    local sorted_spells = {}
    for spellId, data in pairs(spells_to_show) do
        table.insert(sorted_spells, {
            id = spellId,
            data = data,
            priority = (data.spell.deadly and 3 or 0) + 
                      (data.spell.important and 2 or 0) + 
                      (data.spell.interruptible and 1 or 0)
        })
    end
    table.sort(sorted_spells, function(a, b) 
        return a.priority > b.priority 
    end)
    
    -- Pre-load all spell descriptions
    local spellsToLoad = #sorted_spells
    local loadedSpells = 0
    local spellDescriptions = {}
    
    -- Create loading message
    local loadingText = spellScroll:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    loadingText:SetPoint("CENTER")
    loadingText:SetText("Loading spell information...")
    
    -- Function to create spell frames once all descriptions are loaded
    local function CreateSpellFrames()
        loadingText:Hide()
        local yOffset = 0
        
        for _, spell_data in ipairs(sorted_spells) do
            local spellId = spell_data.id
            local spell = spell_data.data.spell
            
            local frame = CreateFrame("Frame", nil, spellScroll)
            frame:SetSize(360, 1) -- Start with height 1, will adjust later
            frame:SetPoint("TOPLEFT", 0, -yOffset)
            
            -- Create spell icon
            local icon = frame:CreateTexture(nil, "ARTWORK")
            icon:SetSize(32, 32)
            icon:SetPoint("TOPLEFT", 8, -8)
            
            -- Get spell info
            if C_Spell then
                local spellInfo = C_Spell.GetSpellInfo(spellId)
                if type(spellInfo) == "table" then
                    spellName = spellInfo.name
                    spellIcon = spellInfo.icon
                else
                    spellName = spell.name -- Fallback to our database name
                end
                if spellIcon then
                    icon:SetTexture(spellIcon)
                end
            end
            
            -- Create spell header (mob name and spell name)
            local headerFrame = CreateFrame("Frame", nil, frame)
            headerFrame:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, 0)
            headerFrame:SetPoint("RIGHT", frame, "RIGHT", -8, 0)
            headerFrame:SetHeight(40)
            
            -- Create the spell name in gold color like WoW tooltips
            local nameText = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            nameText:SetPoint("TOPLEFT", 0, -4)
            nameText:SetWidth(headerFrame:GetWidth()) -- Set width instead of right anchor
            nameText:SetText("|cffffd100" .. (spellName or spell.name) .. "|r")
            
            -- Show mob name if showing all spells
            local mobText
            if not selectedMobId then
                mobText = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                mobText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
                mobText:SetWidth(headerFrame:GetWidth()) -- Set width instead of right anchor
                mobText:SetText("|cFF888888Cast by: " .. spell_data.data.mob_name .. "|r")
            end
            
            -- Create icons container
            local iconsFrame = CreateFrame("Frame", nil, headerFrame)
            iconsFrame:SetSize(200, 20)
            iconsFrame:SetPoint("TOPLEFT", selectedMobId and nameText or mobText, "BOTTOMLEFT", 0, -2)
            
            local iconSize = 16
            local iconSpacing = 2
            local xOffset = 0
            
            -- Function to create icon with tooltip
            local function CreateIcon(parent, iconType, tooltip)
                local icon = parent:CreateTexture(nil, "ARTWORK")
                icon:SetSize(iconSize, iconSize)
                icon:SetPoint("LEFT", xOffset, 0)
                icon:SetTexture(SPELL_ICONS[iconType])
                icon:SetTexCoord(unpack(SPELL_ICON_COORDS[iconType]))
                
                -- Create invisible button for tooltip
                local button = CreateFrame("Button", nil, parent)
                button:SetAllPoints(icon)
                button:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:AddLine(tooltip, 1, 1, 1, true) -- true enables word wrap
                    GameTooltip:Show()
                end)
                button:SetScript("OnLeave", function(self)
                    GameTooltip:Hide()
                end)
                
                xOffset = xOffset + iconSize + iconSpacing
                return icon
            end
            
            -- Add role icons
            if spell.heavy_fail_tank and spell.heavy_fail_tank == 1 then
                CreateIcon(iconsFrame, "tank", "Tank Mechanic\nTanks need to handle this correctly")
            end
            if spell.heavy_fail_healer and spell.heavy_fail_healer == 1 then
                CreateIcon(iconsFrame, "healer", "Healer Mechanic\nHealers need to handle this correctly")
            end
            if spell.heavy_fail_dps and spell.heavy_fail_dps == 1 then
                CreateIcon(iconsFrame, "dps", "DPS Mechanic\nDPS need to handle this correctly")
            end
            
            -- Create description
            local descText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            descText:SetPoint("TOPLEFT", iconsFrame, "BOTTOMLEFT", 0, -4)
            descText:SetWidth(frame:GetWidth() - 16)
            descText:SetJustifyH("LEFT")
            descText:SetWordWrap(true)
            descText:SetText("|cFFFFFFFF" .. (spellDescriptions[spellId] or "(No description available)") .. "|r")
            
            -- Create tags container
            local tagsText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            tagsText:SetPoint("TOPLEFT", descText, "BOTTOMLEFT", 0, -4)
            tagsText:SetWidth(frame:GetWidth() - 16)
            tagsText:SetJustifyH("LEFT")
            
            -- Build tags string
            local tags = {}
            if spell.deadly and spell.deadly == 1 then
                table.insert(tags, "|cFF" .. TAG_COLORS.deadly .. "Deadly|r")
            end
            if spell.important and spell.important == 1 then
                table.insert(tags, "|cFF" .. TAG_COLORS.important .. "Important|r")
            end
            if spell.interruptible and spell.interruptible == 1 then
                table.insert(tags, "|cFF" .. TAG_COLORS.interruptible .. "Interruptible|r")
            end
            if spell.avoidable and spell.avoidable == 1 then
                table.insert(tags, "|cFF" .. TAG_COLORS.avoidable .. "Avoidable|r")
            end
            
            if #tags > 0 then
                tagsText:SetText(table.concat(tags, "  "))
            end
            
            -- Add countermeasures if available
            local counterText
            local frameHeight = 100  -- Default height without countermeasures
            
            if spell.countermeasures and spell.countermeasures ~= "" then
                counterText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                counterText:SetPoint("TOPLEFT", tagsText, "BOTTOMLEFT", 0, -4)
                counterText:SetPoint("RIGHT", frame, "RIGHT", -8, 0)
                counterText:SetJustifyH("LEFT")
                counterText:SetWordWrap(true)
                counterText:SetText("|cFF00FF00Countermeasures:|r " .. spell.countermeasures)
                frameHeight = 200  -- Increased height with countermeasures
            end
            
            -- Calculate actual height needed
            local height = 40 -- Header height
            height = height + descText:GetStringHeight() + 4
            if tagsText:GetText() then
                height = height + tagsText:GetStringHeight() + 4
            end
            if counterText then
                height = height + counterText:GetStringHeight() + 4
            end
            height = height + 8 -- padding
            
            frame:SetHeight(height)
            frame:Show()
            yOffset = yOffset + height + 8
        end
        
        spellScroll:SetSize(360, yOffset)
        spellList:UpdateScrollChildRect()
    end
    
    -- Load all spell descriptions
    for _, spell_data in ipairs(sorted_spells) do
        local spellId = spell_data.id
        addon.TryGetSpellDescription(spellId, function(spellDesc)
            spellDescriptions[spellId] = spellDesc or ""
            loadedSpells = loadedSpells + 1
            
            if loadedSpells == spellsToLoad then
                CreateSpellFrames()
            end
        end)
    end
end

-- Function to populate mob list for a dungeon
PopulateMobs = function(dungeonId)
    -- Clear existing content
    for _, child in pairs({mobScroll:GetChildren()}) do
        child:Hide()
    end
    
    local yOffset = 0
    local buttonHeight = 24
    
    -- Create "All Spells" button first
    local allButton = CreateListButton(mobScroll, 190, buttonHeight)
    allButton:SetPoint("TOPLEFT", 0, -yOffset)
    allButton.text:SetText("All Spells")
    allButton:SetBackdropColor(0.2, 0.2, 0.8, 0.3) -- Highlight by default
    
    allButton:SetScript("OnClick", function(self)
        -- Unhighlight all buttons
        for _, child in pairs({mobScroll:GetChildren()}) do
            if child.SetBackdropColor then
                child:SetBackdropColor(0, 0, 0, 0)
            end
        end
        -- Highlight this button
        self:SetBackdropColor(0.2, 0.2, 0.8, 0.3)
        PopulateSpells(dungeonId) -- Show all spells (no mob filter)
    end)
    
    allButton:Show()
    yOffset = yOffset + buttonHeight
    
    -- Get mobs from the dungeon
    local dungeon = WOWOP_DUNGEON_DATABASE.dungeons[dungeonId]
    if dungeon then
        -- Sort mobs by name
        local sorted_mobs = {}
        for mobId, mob in pairs(dungeon.mobs) do
            table.insert(sorted_mobs, {id = mobId, mob = mob})
        end
        table.sort(sorted_mobs, function(a, b) 
            return a.mob.name < b.mob.name 
        end)
        
        -- Create buttons for each mob
        for _, mob_data in ipairs(sorted_mobs) do
            local button = CreateListButton(mobScroll, 190, buttonHeight)
            button:SetPoint("TOPLEFT", 0, -yOffset)
            button.text:SetText(mob_data.mob.name)
            button.mobId = mob_data.id
            
            button:SetScript("OnClick", function(self)
                -- Unhighlight all buttons
                for _, child in pairs({mobScroll:GetChildren()}) do
                    if child.SetBackdropColor then
                        child:SetBackdropColor(0, 0, 0, 0)
                    end
                end
                -- Highlight this button
                self:SetBackdropColor(0.2, 0.2, 0.8, 0.3)
                PopulateSpells(dungeonId, self.mobId)
            end)
            
            button:Show()
            yOffset = yOffset + buttonHeight
        end
    end
    
    mobScroll:SetSize(190, yOffset) -- Set width and total content height
    mobList:UpdateScrollChildRect()
    
    -- Show all spells by default
    PopulateSpells(dungeonId)
end

-- Function to populate dungeon list
PopulateDungeons = function()
    local yOffset = 0
    local buttonHeight = 24
    
    for dungeonId, dungeon in pairs(WOWOP_DUNGEON_DATABASE.dungeons) do
        local button = CreateListButton(dungeonScroll, 190, buttonHeight)
        button:SetPoint("TOPLEFT", 0, -yOffset)
        button.text:SetText(dungeon.name)
        button.dungeonId = dungeonId
        
        button:SetScript("OnClick", function(self)
            PopulateMobs(self.dungeonId)
            PopulateSpells(self.dungeonId)
        end)
        
        yOffset = yOffset + buttonHeight
    end
    
    dungeonScroll:SetSize(190, yOffset) -- Set width and total content height
    dungeonList:UpdateScrollChildRect()
end

-- Function to create the main frame and all its components
CreateMainFrame = function()
    DungeonGuideFrame = CreateFrame("Frame", "WowopDungeonGuide", UIParent, "UIPanelDialogTemplate")
    DungeonGuideFrame:Hide()
    DungeonGuideFrame:SetSize(800, 600)
    DungeonGuideFrame:SetPoint("CENTER")
    DungeonGuideFrame.Title:SetText("WoWOP.io Dungeon Guide")
    DungeonGuideFrame:SetMovable(true)
    DungeonGuideFrame:EnableMouse(true)
    DungeonGuideFrame:RegisterForDrag("LeftButton")
    DungeonGuideFrame:SetScript("OnDragStart", DungeonGuideFrame.StartMoving)
    DungeonGuideFrame:SetScript("OnDragStop", DungeonGuideFrame.StopMovingOrSizing)
    
    -- Create scroll frames with adjusted widths
    dungeonList, dungeonScroll = CreateScrollFrame(DungeonGuideFrame, "WowopDungeonList", 190, 520)
    dungeonList:SetPoint("TOPLEFT", 12, -32)
    
    mobList, mobScroll = CreateScrollFrame(DungeonGuideFrame, "WowopMobList", 190, 520)
    mobList:SetPoint("TOPLEFT", dungeonList, "TOPRIGHT", 8, 0)
    
    spellList, spellScroll = CreateScrollFrame(DungeonGuideFrame, "WowopSpellList", 360, 520)
    spellList:SetPoint("TOPLEFT", mobList, "TOPRIGHT", 8, 0)
end

-- Function to check if spell data is loaded
CheckSpellData = function()
    if not pendingSpellCheck and not isSpellDataLoaded then
        pendingSpellCheck = true
        
        -- Use C_Spell API to check if spell data is loaded
        if C_Spell then
            local spellInfo = C_Spell.GetSpellInfo(133)  -- Fireball
            if spellInfo then
                isSpellDataLoaded = true
                print("WoWOP.io: Spell data loaded successfully")
                
                -- Initialize the dungeon list if the frame is shown
                if DungeonGuideFrame and DungeonGuideFrame:IsShown() and not hasInitialized then
                    PopulateDungeons()
                    hasInitialized = true
                end
                
                return true
            end
        end
        
        print("WoWOP.io: Waiting for spell system initialization...")
        C_Timer.After(0.5, CheckSpellData)  -- Try again in 0.5 seconds
        pendingSpellCheck = false
        return false
    end
    return isSpellDataLoaded
end

-- Function to toggle the guide window
addon.ToggleDungeonGuide = function()
    
    if not DungeonGuideFrame then
        CreateMainFrame()
    end
    
    if DungeonGuideFrame:IsShown() then
        DungeonGuideFrame:Hide()
    else
        DungeonGuideFrame:Show()
        if not hasInitialized then
            if isSpellDataLoaded then
                PopulateDungeons()
                hasInitialized = true
            else
                if C_Spell then
                    C_Spell.RequestLoadSpellData(133)
                end
                CheckSpellData()
            end
        end
    end
end

 