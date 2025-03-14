-- Create addon namespace
local addonName, addon = ...

-- Create tables for each region's database if they don't exist
-- We only declare the variables, but don't initialize them with empty tables
local WOWOP_DATABASE_EU
local WOWOP_DATABASE_US
local WOWOP_DATABASE_CN
local WOWOP_DATABASE_TW_KR
local WOWOP_DATABASE = {}  -- This will hold the active region's database
local WOWOP_SPEC_PERFORMANCE = {}  -- This will hold the spec performance database

-- Near the top of the file, simplify the cache to just store data without timestamps
local playerCache = {}

-- Add this near the top of the file with other local variables
local CACHE_TIMEOUT = 60  -- Cache entries expire after 60 seconds

-- Add this near other local variables at the top
local starttime = nil
local endtime = nil
local challenge_mode_duration = nil
local challenge_mode_frame = nil

-- Add this function to load the spec performance database
local function LoadSpecPerformanceDatabase()
    -- The database is loaded from database_spec_performance.lua into WOWOP_SPEC_PERFORMANCE
    if _G.WOWOP_SPEC_PERFORMANCE then
        WOWOP_SPEC_PERFORMANCE = _G.WOWOP_SPEC_PERFORMANCE
        -- Add debug logging
        local count = 0
        for dungeon_id, dungeon_data in pairs(WOWOP_SPEC_PERFORMANCE) do
            count = count + 1
        end
        print(string.format("|cffff0000WoWOP.io:|r Debug - Loaded spec performance database with %d dungeons", count))
        return true
    end
    print("|cffff0000WoWOP.io:|r Debug - Failed to load spec performance database")
    return false
end

-- Add this near the top of the file with other local variables
local WOWOP_DUNGEON_DATABASE = {}  -- This will hold the dungeon database

-- Add this right after the utility functions and before GetPlayerScore
local function ExpandPlayerData(compactData)
    if not compactData then return nil end
    
    local expanded = {
        specs = {},
        score = compactData.o and (compactData.o / 10) or 0,  -- Overall score from database, divided by 10
        total_runs = 0
    }
    
    -- Process each spec
    for spec_id, spec_data in pairs(compactData) do
        if type(spec_id) == "number" then  -- Skip 'o' field which is a string
            local spec_name = WOWOP_LOOKUPS.specs[spec_id]
            if spec_name then
                expanded.specs[spec_name] = {
                    score = spec_data.s / 10,  -- Divide score by 10
                    run_count = spec_data.r,
                    brackets = {},
                    score_details = {}
                }
                
                -- Add to total runs
                expanded.total_runs = expanded.total_runs + spec_data.r
                
                -- Expand brackets
                if spec_data.b then
                    for bracketId, score in pairs(spec_data.b) do
                        expanded.specs[spec_name].brackets[WOWOP_LOOKUPS.brackets[bracketId]] = score / 10  -- Divide bracket scores by 10
                    end
                end
                
                -- Expand score details
                if spec_data.d then
                    for metricId, value in pairs(spec_data.d) do
                        expanded.specs[spec_name].score_details[WOWOP_LOOKUPS.metrics[metricId]] = value / 10  -- Divide detail scores by 10
                    end
                end
            end
        end
    end
    
    return expanded
end

-- Add this function to load the dungeon database
local function LoadDungeonDatabase()
    -- The database is loaded from database_dungeons.lua into WOWOP_DUNGEON_DATABASE
    if WOWOP_DUNGEON_DATABASE then
        -- Make it available to the addon namespace
        addon.database_dungeons = WOWOP_DUNGEON_DATABASE
        return true
    end
    return false
end

-- Function to determine player's region
local function GetPlayerRegion()
    local region = GetCurrentRegion()
    local regionName
    
    if region == 1 then
        regionName = "US"
    elseif region == 2 or region == 4 then  -- KR or TW
        regionName = "TW_KR"  -- Changed to use combined database
    elseif region == 3 then
        regionName = "EU"
    elseif region == 5 then
        regionName = "CN"  
    else
        regionName = "US"
    end
    
    return regionName, region  -- Return both the region name and the numeric region
end

-- Function to load the correct database file
local function LoadRegionDatabase()
    local regionName, numericRegion = GetPlayerRegion()
    print("|cffff0000WoWOP.io:|r |cffff9933Loading database for region|r " .. regionName)
    
    -- First, get the correct database from _G
    local regionDB
    if numericRegion == 2 or numericRegion == 4 then
        -- For TW/KR regions, load the combined database
        regionDB = _G["WOWOP_DATABASE_TW_KR"]
        WOWOP_DATABASE_TW_KR = regionDB
        WOWOP_DATABASE = regionDB
    else
        -- For other regions, load their specific database
        regionDB = _G["WOWOP_DATABASE_" .. regionName]
        -- Set the local reference to match the global one
        if regionName == "EU" then
            WOWOP_DATABASE_EU = regionDB
        elseif regionName == "US" then
            WOWOP_DATABASE_US = regionDB
        elseif regionName == "CN" then
            WOWOP_DATABASE_CN = regionDB
        end
        WOWOP_DATABASE = regionDB
    end
    
    if regionDB and next(regionDB) then  -- Check if database exists and is not empty
        -- Now that we have loaded the correct database, clear the others
        if regionName ~= "EU" then
            WOWOP_DATABASE_EU = nil
            _G["WOWOP_DATABASE_EU"] = nil
        end
        if regionName ~= "US" then
            WOWOP_DATABASE_US = nil
            _G["WOWOP_DATABASE_US"] = nil
        end
        if regionName ~= "CN" then
            WOWOP_DATABASE_CN = nil
            _G["WOWOP_DATABASE_CN"] = nil
        end
        if regionName ~= "TW_KR" then
            WOWOP_DATABASE_TW_KR = nil
            _G["WOWOP_DATABASE_TW_KR"] = nil
        end
        
        collectgarbage("collect")  -- Force garbage collection
        
        -- Count entries for logging
        local count = 0
        local specCount = 0
        for realmName, realmData in pairs(WOWOP_DATABASE) do
            for playerName, playerData in pairs(realmData) do
                count = count + 1
                for key, _ in pairs(playerData) do
                    if type(key) == "number" then
                        specCount = specCount + 1
                    end
                end
            end
        end
        
        print(string.format("|cffff0000WoWOP.io:|r |cffff9933Database loaded with|r %d |cffff9933players and|r %d |cffff9933specs|r", count, specCount))
        return true
    else
        print("|cffff0000WoWOP.io:|r |cffff9933WARNING - Database not found for region|r " .. regionName .. ", |cffff9933creating empty database|r")
        WOWOP_DATABASE = {}
        return false
    end
end

-- Initialize frame and register events
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("CHALLENGE_MODE_START")
frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")

-- Create our custom tooltip frame for LFG applicants
local ApplicantTooltip = CreateFrame("GameTooltip", "WowopApplicantTooltip", UIParent, "GameTooltipTemplate")
ApplicantTooltip:SetClampedToScreen(true)

-- Add these utility functions near the top of the file
local ScrollBoxUtil = {}

function ScrollBoxUtil:OnViewFramesChanged(scrollBox, callback)
    if not scrollBox then
        return
    end
    if scrollBox.buttons then -- legacy support
        callback(scrollBox.buttons, scrollBox)
        return 1
    end
    if scrollBox.RegisterCallback then
        local frames = scrollBox:GetFrames()
        if frames and frames[1] then
            callback(frames, scrollBox)
        end
        scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnUpdate, function()
            frames = scrollBox:GetFrames()
            callback(frames, scrollBox)
        end)
        return true
    end
    return false
end

function ScrollBoxUtil:OnViewScrollChanged(scrollBox, callback)
    if not scrollBox then
        return
    end
    local function wrappedCallback()
        callback(scrollBox)
    end
    if scrollBox.update then -- legacy support
        hooksecurefunc(scrollBox, "update", wrappedCallback)
        return 1
    end
    if scrollBox.RegisterCallback then
        scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnScroll, wrappedCallback)
        return true
    end
    return false
end

local HookUtil = {}

function HookUtil:MapOn(object, map)
    if type(object) ~= "table" then
        return
    end
    if type(object.GetObjectType) == "function" then
        for key, callback in pairs(map) do
            if not object.wowopHooked then
                object:HookScript(key, callback)
                object.wowopHooked = true
            end
        end
        return 1
    end
    for key, callback in pairs(map) do
        for _, frame in pairs(object) do
            if not frame.wowopHooked then
                frame:HookScript(key, callback)
                frame.wowopHooked = true
            end
        end
    end
    return true
end

-- Add this helper function near the top
local function GetObjOwnerName(self)
    local owner, owner_name = self:GetOwner()
    if owner then
        owner_name = owner:GetName()
        if not owner_name then
            owner_name = owner:GetDebugName()
        end
    end
    return owner, owner_name
end

-- Function to get player score with caching
local function GetPlayerScore(playerName, realmName)
    -- If realm is empty, use player's realm
    if not realmName or realmName == "" then
        realmName = GetRealmName()
    end
    
    -- Normalize realm name by removing spaces and dashes
    realmName = realmName:gsub("[-%s]", "")
    
    -- Create cache key
    local cacheKey = playerName .. "-" .. realmName
    
    -- Check cache first
    if playerCache[cacheKey] then
        return playerCache[cacheKey]
    end
    
    -- Get the realm data first
    if not WOWOP_DATABASE[realmName] then
        playerCache[cacheKey] = nil  -- Cache the nil result
        return nil
    end
    
    -- Get player data from the realm
    local playerData = WOWOP_DATABASE[realmName][playerName]
    if not playerData then
        playerCache[cacheKey] = nil  -- Cache the nil result
        return nil
    end
    
    -- Expand the data
    local expandedData = ExpandPlayerData(playerData)
    
    -- Cache the result
    playerCache[cacheKey] = expandedData
    
    return expandedData
end

-- Function to get color for score (0-100)
local function GetScoreColor(score)
    if not score then return 1, 1, 1 end -- white for no score
    
    -- Convert hex colors to RGB (0-1 range)
    if score < 25 then
        -- Grey (#666666)
        return 0.4, 0.4, 0.4
    elseif score < 50 then
        -- Green (#1eff00)
        return 0.12, 1, 0
    elseif score < 75 then
        -- Blue (#0070ff)
        return 0, 0.44, 1
    elseif score < 95 then
        -- Epic Purple (#a335ee)
        return 0.64, 0.21, 0.93
    elseif score < 99 then
        -- Orange (#ff8000)
        return 1, 0.5, 0
    elseif score < 100 then
        -- Pink (#e268a8)
        return 0.89, 0.41, 0.66
    else
        -- Gold (#e5cc80)
        return 0.90, 0.80, 0.50
    end
end

-- Function to format score details based on role
local function FormatScoreDetails(scoreDetails, specName)
    if not scoreDetails then return "" end
    
    -- Determine role based on spec name (you might want to maintain a proper spec->role mapping)
    local role = "DPS"
    if specName:match("Restoration") or specName:match("Holy") or specName:match("Discipline") or specName:match("Mistweaver") or specName:match("Preservation") then
        role = "HEALER"
    elseif specName:match("Protection") or specName:match("Blood") or specName:match("Vengeance") or specName:match("Guardian") or specName:match("Brewmaster") then
        role = "TANK"
    end
    
    local lines = {}
    
    -- Format based on role
    if role == "HEALER" then
        if scoreDetails.damage then
            table.insert(lines, string.format("Damage: %.1f", scoreDetails.damage))
        end
    elseif role == "TANK" then
        if scoreDetails.damage then
            table.insert(lines, string.format("Damage: %.1f", scoreDetails.damage))
        end
        if scoreDetails.deaths then
            table.insert(lines, string.format("Survivability: %.1f", scoreDetails.deaths))
        end
    else -- DPS
        if scoreDetails.damage then
            table.insert(lines, string.format("Damage: %.1f", scoreDetails.damage))
        end
    end
    
    -- Common metrics for all roles
    if scoreDetails.interrupts then
        table.insert(lines, string.format("Interrupts: %.1f", scoreDetails.interrupts))
    end
    if scoreDetails.heavy_fails then
        table.insert(lines, string.format("Mechanics: %.1f", scoreDetails.heavy_fails))
    end
    
    return lines
end

-- Function to add stats to tooltip
local function AddStatsToTooltip(tooltip, name, realm, forceShowAll)
    -- If no realm is specified, use the player's realm
    if not realm or realm == "" then
        realm = GetRealmName()
    end
    
    -- Get the player data
    local playerData = GetPlayerScore(name, realm)
    
    -- Add data to tooltip
    if playerData then
        tooltip:AddLine(" ")  -- Empty line for spacing
        tooltip:AddLine("WoWOP.io Stats:", 0.27, 0.74, 0.98)
        
        -- Add overall score with color
        if playerData.score then
            local r, g, b = GetScoreColor(playerData.score)
            -- Calculate total runs by summing up runs from all specs
            local total_runs = 0
            if playerData.specs then
                for _, specData in pairs(playerData.specs) do
                    total_runs = total_runs + (specData.run_count or 0)
                end
            end
            
            tooltip:AddDoubleLine(
                string.format("Overall Score (%d Runs):", total_runs),
                string.format("%.1f", playerData.score),
                1, 1, 1,  -- white for text
                r, g, b   -- colored score
            )
            
            -- Add karma if it exists and is greater than 0
            if playerData.karma and playerData.karma > 0 then
                tooltip:AddLine(string.format("Karma: +%d", playerData.karma), 0.41, 0.8, 1)  -- Light blue color for karma
            end
        end
        
        -- Show detailed stats when holding shift, when forceShowAll is true, or when alwaysExpandTooltips is enabled
        if addon:ShouldExpandTooltips() or forceShowAll then
            if playerData.specs then
                tooltip:AddLine(" ")  -- Spacing
                tooltip:AddLine("Spec Scores:", 0.27, 0.74, 0.98)
                
                for specName, specData in pairs(playerData.specs) do
                    local r, g, b = GetScoreColor(specData.score)
                    -- Show spec name in white, only color the score
                    tooltip:AddDoubleLine(specName .. 
                        string.format(" (%d Runs):", specData.run_count or 0),
                        string.format("%.1f", specData.score), 
                        1, 1, 1,  -- white for spec name
                        r, g, b)  -- colored score
                    
                    -- Add score details if available
                    if specData.score_details then
                        local detailLines = FormatScoreDetails(specData.score_details, specName)
                        for _, line in ipairs(detailLines) do
                            local label, value = line:match("([^:]+): ([%d%.]+)")
                            if label and value then
                                local r, g, b = GetScoreColor(tonumber(value))
                                tooltip:AddDoubleLine(label .. ":", value,
                                    0.8, 0.8, 0.8,  -- Light gray for label
                                    r, g, b)        -- Colored score
                            end
                        end
                    end
                    
                    -- Modify the bracket score checks to include nil checks
                    if specData.brackets then
                        -- Check "8-11" bracket
                        local bracket_8_11 = specData.brackets["8-11"]
                        if bracket_8_11 and bracket_8_11 > 0 then
                            local r, g, b = GetScoreColor(bracket_8_11)
                            tooltip:AddDoubleLine("Bracket 8-11:", 
                                string.format("%.1f", bracket_8_11),
                                1, 1, 1,  -- white for bracket text
                                r, g, b)  -- colored score
                        end
                        
                        -- Check "12-13" bracket
                        local bracket_12_13 = specData.brackets["12-13"]
                        if bracket_12_13 and bracket_12_13 > 0 then
                            local r, g, b = GetScoreColor(bracket_12_13)
                            tooltip:AddDoubleLine("Bracket 12-13:", 
                                string.format("%.1f", bracket_12_13),
                                1, 1, 1,  -- white for bracket text
                                r, g, b)  -- colored score
                        end
                        
                        -- Check "14+" bracket
                        local bracket_14_plus = specData.brackets["14+"]
                        if bracket_14_plus and bracket_14_plus > 0 then
                            local r, g, b = GetScoreColor(bracket_14_plus)
                            tooltip:AddDoubleLine("Bracket 14+:", 
                                string.format("%.1f", bracket_14_plus),
                                1, 1, 1,  -- white for bracket text
                                r, g, b)  -- colored score
                        end
                    end
                    tooltip:AddLine(" ") -- Add empty line between specs
                end
            end
        else
            -- When not showing expanded tooltips, show hint
            tooltip:AddLine("Hold SHIFT to show detailed scores", 0.5, 0.5, 0.5)
        end
        
        tooltip:AddLine(" ")  -- Empty line for spacing
    else
        tooltip:AddLine(" ")  -- Empty line for spacing
        tooltip:AddLine("WoWOP.io Stats: N/A", 0.27, 0.74, 0.98)
        tooltip:AddLine(" ")  -- Empty line for spacing
    end
end

-- Function to handle mouse enter on LFG list items 
local function OnEnter(self)
    if self.applicantID then
        for i = 1, #self.Members do
            local member = self.Members[i]
            local name = member.Name:GetText()
            if name then
                local playerName, realm = name:match("([^-]+)-?(.*)")
                if playerName then
                    GameTooltip:SetOwner(member, "ANCHOR_RIGHT")
                    GameTooltip:AddLine(name)
                    GameTooltip:Show()
                    AddStatsToTooltip(GameTooltip, playerName, realm, true)
                end
            end
        end
    end
end

-- Function to handle mouse leave
local function OnLeave(self)
    GameTooltip:Hide()
    ApplicantTooltip:Hide()
end

-- Function to handle scroll events
local function OnScroll()
    GameTooltip:Hide()
end

-- Hook into all possible tooltip types
local function HookTooltips()
    -- Unit tooltips (nameplates, character frames)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
        local unit = select(2, tooltip:GetUnit())
        if not unit then return end
        
        -- Only show stats for players
        if not UnitIsPlayer(unit) then return end
        
        local name, realm = UnitName(unit)
        if not name then return end
        
        AddStatsToTooltip(tooltip, name, realm)
    end)

    -- LFG tooltips
    hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", function(tooltip, resultID, autoAcceptOption)
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
        if not searchResultInfo or not searchResultInfo.leaderName then return end
        
        local name, realm = searchResultInfo.leaderName:match("([^-]+)-?(.*)")
        if name then
            AddStatsToTooltip(tooltip, name, realm, true)
        end
    end)

    -- Guild roster tooltips
    if CommunitiesFrame then
        hooksecurefunc(CommunitiesFrame.MemberList, "RefreshLayout", function()
            local scrollTarget = CommunitiesFrame.MemberList.ScrollBox.ScrollTarget
            if scrollTarget then
                for _, child in ipairs({scrollTarget:GetChildren()}) do
                    if child.NameFrame and not child.wowopHooked then
                        child:HookScript("OnEnter", function(self)
                            if self.memberInfo and self.memberInfo.name then
                                local name, realm = self.memberInfo.name:match("([^-]+)-?(.*)")
                                if name then
                                    if realm == "" then realm = GetRealmName() end
                                    AddStatsToTooltip(GameTooltip, name, realm)
                                    GameTooltip:Show()
                                end
                            end
                        end)
                        child.wowopHooked = true
                    end
                end
            end
        end)
    end

    -- Add LFG frame integration
    if LFGListFrame then
        -- Hook search panel (when looking at groups)
        if LFGListFrame.SearchPanel and LFGListFrame.SearchPanel.ScrollBox then
            local hookMap = { OnEnter = OnEnter, OnLeave = OnLeave }
            ScrollBoxUtil:OnViewFramesChanged(LFGListFrame.SearchPanel.ScrollBox, function(buttons) 
                HookUtil:MapOn(buttons, hookMap)
            end)
            ScrollBoxUtil:OnViewScrollChanged(LFGListFrame.SearchPanel.ScrollBox, OnScroll)
        end

        -- Hook applicant viewer tooltips
        hooksecurefunc(GameTooltip, "SetText", function(self, text)
            local owner, owner_name = GetObjOwnerName(self)
            if not owner or not owner_name then return end
            
            if owner_name:find("LFGListApplicationViewer") or 
               owner_name:find("LFGListFrame.ApplicationViewer") then
                local button = owner
                while button and not button.applicantID do
                    button = button:GetParent()
                end
                
                if button and button.applicantID and owner.memberIdx then
                    local name = C_LFGList.GetApplicantMemberInfo(button.applicantID, owner.memberIdx)
                    if name then
                        local playerName, realm = name:match("([^-]+)-?(.*)")
                        if playerName then
                            AddStatsToTooltip(self, playerName, realm, true)
                        end
                    end
                end
            end
        end)
    end
end

-- Function to format player stats for chat output
local function FormatPlayerStats(playerData, playerName)
    if not playerData then return playerName .. ": No data found" end
    
    local output = playerName .. " - Overall Score: " .. playerData.score
    if playerData.specs then
        for specName, specData in pairs(playerData.specs) do
            output = output .. "\n  " .. specName .. ": " .. specData.score
            
            -- Add score details if available
            if specData.score_details then
                local role = "DPS"
                if specName:match("Restoration") or specName:match("Holy") or specName:match("Discipline") or 
                   specName:match("Mistweaver") or specName:match("Preservation") then
                    role = "HEALER"
                elseif specName:match("Protection") or specName:match("Blood") or specName:match("Vengeance") or 
                       specName:match("Guardian") or specName:match("Brewmaster") then
                    role = "TANK"
                end
                
                -- Format details based on role with colors
                if role == "HEALER" then
                    if specData.score_details.healing then
                        local r, g, b = GetScoreColor(specData.score_details.healing)
                        output = output .. string.format("\n    Healing: |cff%02x%02x%02x%.1f|r", 
                            r*255, g*255, b*255, specData.score_details.healing)
                    end
                    if specData.score_details.damage then
                        local r, g, b = GetScoreColor(specData.score_details.damage)
                        output = output .. string.format("\n    Damage: |cff%02x%02x%02x%.1f|r", 
                            r*255, g*255, b*255, specData.score_details.damage)
                    end
                elseif role == "TANK" then
                    if specData.score_details.damage then
                        local r, g, b = GetScoreColor(specData.score_details.damage)
                        output = output .. string.format("\n    Damage: |cff%02x%02x%02x%.1f|r", 
                            r*255, g*255, b*255, specData.score_details.damage)
                    end
                    if specData.score_details.deaths then
                        local r, g, b = GetScoreColor(specData.score_details.deaths)
                        output = output .. string.format("\n    Survivability: |cff%02x%02x%02x%.1f|r", 
                            r*255, g*255, b*255, specData.score_details.deaths)
                    end
                    if specData.score_details.healing then
                        local r, g, b = GetScoreColor(specData.score_details.healing)
                        output = output .. string.format("\n    Self Healing: |cff%02x%02x%02x%.1f|r", 
                            r*255, g*255, b*255, specData.score_details.healing)
                    end
                else -- DPS
                    if specData.score_details.damage then
                        local r, g, b = GetScoreColor(specData.score_details.damage)
                        output = output .. string.format("\n    Damage: |cff%02x%02x%02x%.1f|r", 
                            r*255, g*255, b*255, specData.score_details.damage)
                    end
                end
                
                -- Common metrics for all roles
                if specData.score_details.interrupts then
                    local r, g, b = GetScoreColor(specData.score_details.interrupts)
                    output = output .. string.format("\n    Interrupts: |cff%02x%02x%02x%.1f|r", 
                        r*255, g*255, b*255, specData.score_details.interrupts)
                end
                if specData.score_details.heavy_fails then
                    local r, g, b = GetScoreColor(specData.score_details.heavy_fails)
                    output = output .. string.format("\n    Mechanics: |cff%02x%02x%02x%.1f|r", 
                        r*255, g*255, b*255, specData.score_details.heavy_fails)
                end
            end
        end
    end
    return output
end

-- Function to post party stats to party chat
local function PostPartyStats()
    if not IsInGroup() then
        print("|cffff0000WoWOP.io:|r |cffff9933You are not in a group|r")
        return
    end
    
    -- Determine the appropriate chat channel
    local channel = IsInRaid() and "RAID" or "PARTY"
    
    -- Post own stats first
    local playerName = UnitName("player")
    local playerData = GetPlayerScore(playerName, GetRealmName())
    if playerData then
        SendChatMessage("|cffff0000WoWOP.io Scores:|r", channel)
        SendChatMessage(FormatPlayerStats(playerData, playerName), channel)
    end
    
    -- Loop through party/raid members
    local numMembers = IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()
    for i = 1, numMembers do
        local unit = IsInRaid() and "raid"..i or "party"..i
        local name, realm = UnitName(unit)
        if name then
            local playerData = GetPlayerScore(name, realm or GetRealmName())
            if playerData then
                SendChatMessage(FormatPlayerStats(playerData, name), channel)
            end
        end
    end
end

-- Function to lookup player stats from current region
local function LookupPlayerStats(playerFullName)
    if not playerFullName then
        print("|cffff0000WoWOP.io:|r |cffff9933Usage:|r /wowop lookup playername-realmname")
        print("|cffff0000WoWOP.io:|r |cffff9933Example:|r /wowop lookup Maxxpower-Malygos")
        return
    end
    
    -- Split the player-realm string (without converting to lowercase)
    local playerName, realmName = strmatch(playerFullName, "([^-]+)-(.+)")
    if not playerName or not realmName then
        print("|cffff0000WoWOP.io:|r |cffff9933Invalid format. Use:|r playername-realmname")
        print("|cffff0000WoWOP.io:|r |cffff9933Example:|r /wowop lookup Maxxpower-Malygos")
        return
    end
    
    -- Look up the player in current database
    local playerData = GetPlayerScore(playerName, realmName)
    
    if not playerData then
        print("|cffff0000WoWOP.io:|r |cffff9933No data found for|r " .. playerFullName)
        return
    end
    
    -- Print the results
    print("|cffff0000WoWOP.io Stats for|r " .. playerFullName .. ":")
    
    -- Color the overall score
    local r, g, b = GetScoreColor(playerData.score)
    local coloredScore = string.format("|cff%02x%02x%02x%.1f|r", r*255, g*255, b*255, playerData.score)
    print("|cffff0000Overall Score:|r " .. coloredScore)
    
    if playerData.specs then
        print("|cffff0000Spec Scores:|r")
        for specName, specData in pairs(playerData.specs) do
            -- Color the spec score
            local r, g, b = GetScoreColor(specData.score)
            local coloredSpecScore = string.format("|cff%02x%02x%02x%.1f|r", r*255, g*255, b*255, specData.score)
            print("  " .. specName .. ": " .. coloredSpecScore)
            
            -- Add score details if available
            if specData.score_details then
                for metric, value in pairs(specData.score_details) do
                    local r, g, b = GetScoreColor(value)
                    local coloredValue = string.format("|cff%02x%02x%02x%.1f|r", r*255, g*255, b*255, value)
                    print(string.format("    %s: %s", metric:gsub("^%l", string.upper), coloredValue))
                end
            end
            
            -- Color the bracket scores
            if specData.brackets then
                if specData.brackets["8-11"] > 0 then
                    local r, g, b = GetScoreColor(specData.brackets["8-11"])
                    local coloredBracketScore = string.format("|cff%02x%02x%02x%.1f|r", r*255, g*255, b*255, specData.brackets["8-11"])
                    print("    Bracket 8-11: " .. coloredBracketScore)
                end
                if specData.brackets["12-13"] > 0 then
                    local r, g, b = GetScoreColor(specData.brackets["12-13"])
                    local coloredBracketScore = string.format("|cff%02x%02x%02x%.1f|r", r*255, g*255, b*255, specData.brackets["12-13"])
                    print("    Bracket 12-13: " .. coloredBracketScore)
                end
                if specData.brackets["14+"] > 0 then
                    local r, g, b = GetScoreColor(specData.brackets["14+"])
                    local coloredBracketScore = string.format("|cff%02x%02x%02x%.1f|r", r*255, g*255, b*255, specData.brackets["14+"])
                    print("    Bracket 14+: " .. coloredBracketScore)
                end
            end
        end
    end
end

-- Add test command to the existing slash command handler
local function TestDeathAnalysis(spellId)
    if not spellId then
        print("|cffff0000Usage:|r /wowop test <spellId>")
        return
    end
    
    spellId = tonumber(spellId)
    if not spellId then
        print("|cffff0000Invalid spell ID|r")
        return
    end
    
    if not WOWOP_DUNGEON_DATABASE then
        print("|cffff0000WoWOP.io:|r |cffff9933Error - Dungeon database not loaded!|r")
        return
    end
    
    -- Use the ShowDeathAnalysis function from death_analysis.lua
    addon:TestDeathAnalysis(spellId)
end

-- Function to get overall data from Details!
local function GetDetailsOverallData()
    -- Check if Details! exists
    local Details = _G._detalhes
    if not Details then 
        print("|cffff0000WoWOP.io:|r Details! not found. Please make sure Details! is installed and enabled.")
        return nil 
    end
    
    -- Get the overall combat object
    local overall = Details:GetCombat(-1)
    if not overall then 
        print("|cffff0000WoWOP.io:|r No combat data available.")
        return nil 
    end
    
    -- Get current dungeon info
    local current_zone_id = C_Map.GetBestMapForUnit("player")
    if not current_zone_id then
        print("|cffff0000WoWOP.io:|r Could not determine current dungeon.")
        return nil
    end
    
    -- Get current instance ID
    local _, _, _, _, _, _, _, instance_id = GetInstanceInfo()
    if not instance_id then
        print("|cffff0000WoWOP.io:|r Could not determine current instance.")
        return nil
    end
    
    
    -- Convert instance ID to game_zone_id using our lookup table
    local game_zone_id = WOWOP_SPEC_PERFORMANCE[instance_id] and instance_id or WOWOP_LOOKUPS.instance_to_zone[instance_id]
    if not game_zone_id then
        print(string.format("|cffff0000WoWOP.io:|r No mapping found for instance ID: %d", instance_id))
        return nil
    end
    
    
    -- Get keystone level from the challenge mode info
    local keystone_level = (C_ChallengeMode.GetActiveKeystoneInfo() or 0)
    
    -- Use challenge mode duration if available, otherwise fall back to combat time
    local dungeon_time = challenge_mode_duration or overall:GetCombatTime()
    
    -- Reset challenge_mode_duration for next run
    challenge_mode_duration = nil
    
    local data = {
        damage = {},
        healing = {},
        interrupts = {},
        deaths = {},
        zone_id = game_zone_id,  -- Use the mapped game_zone_id instead of current_zone_id
        keystone_level = keystone_level,
        duration = dungeon_time
    }
    
    -- Helper function to get standardized spec info
    local function GetStandardizedSpecInfo(actor)
        -- Get spec ID from the spec field instead of spec_id
        local spec_id = actor.spec
        
        
        -- Get English class name (Details! uses English internally)
        local class_name = actor.classe
        
        -- Get English spec name from Details
        local spec_name = actor.spec
        if not spec_name then
            -- If spec name not available, try to get it from Details' spec info
            local spec_info = Details.class_specs_coords[spec_id]
            if spec_info then
                spec_name = spec_info.spec_name_local
            end
        end
        
        -- Return standardized format
        return {
            spec_id = spec_id,  -- This will now be the correct spec ID
            class_name = class_name,
            spec_name = spec_name,
            spec_key = class_name .. "-" .. (spec_name or "Unknown")
        }
    end
    
    -- Get damage data
    local damage_container = overall:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
    if damage_container then
        for _, actor in damage_container:ListActors() do
            if actor:IsPlayer() then
                local spec_info = GetStandardizedSpecInfo(actor)
                data.damage[actor:Name()] = {
                    total = actor.total,
                    dps = actor.total / dungeon_time,
                    class = actor.classe,
                    spec_id = spec_info.spec_id,
                    spec_name = spec_info.spec_name,
                    spec_key = spec_info.spec_key
                }
                -- Initialize deaths data for this player
                data.deaths[actor:Name()] = {
                    total = 0,
                    class = actor.classe,
                    spec_id = spec_info.spec_id,
                    spec_name = spec_info.spec_name,
                    spec_key = spec_info.spec_key
                }
            end
        end
    end
    
    -- Get healing data
    local healing_container = overall:GetContainer(DETAILS_ATTRIBUTE_HEAL)
    if healing_container then
        for _, actor in healing_container:ListActors() do
            if actor:IsPlayer() then
                local spec_info = GetStandardizedSpecInfo(actor)
                data.healing[actor:Name()] = {
                    total = actor.total,
                    hps = actor.total / dungeon_time,
                    class = actor.classe,
                    spec_id = spec_info.spec_id,
                    spec_name = spec_info.spec_name,
                    spec_key = spec_info.spec_key
                }
            end
        end
    end
    
    -- Get interrupt data from misc container
    local misc_container = overall:GetContainer(DETAILS_ATTRIBUTE_MISC)
    if misc_container then
        for _, actor in misc_container:ListActors() do
            if actor:IsPlayer() then
                local spec_info = GetStandardizedSpecInfo(actor)
                local total_interrupts = actor.interrupt or 0
                
                data.interrupts[actor:Name()] = {
                    total = total_interrupts,
                    ipm = (dungeon_time > 0) and (total_interrupts / (dungeon_time / 60)) or 0,
                    class = actor.classe,
                    spec_id = spec_info.spec_id,
                    spec_name = spec_info.spec_name,
                    spec_key = spec_info.spec_key
                }
            end
        end
    end
    
    -- Get deaths from the death log
    if overall.last_events_tables then
        for _, death_table in ipairs(overall.last_events_tables) do
            local player_name = death_table[3] -- Index 3 contains the player name
            if player_name and data.deaths[player_name] then
                data.deaths[player_name].total = (data.deaths[player_name].total or 0) + 1
                data.deaths[player_name].dph = data.deaths[player_name].total / (dungeon_time / 3600)
            end
        end
    end
    
    return data
end

-- Function to get performance comparison
local function GetPerformanceComparison(current_value, average_value)
    if not average_value or average_value == 0 then return 0, "white" end
    
    local diff_percent = ((current_value - average_value) / average_value) * 100
    local color
    if diff_percent > 20 then
        color = "00ff00" -- Green
    elseif diff_percent > 0 then
        color = "99ff99" -- Light green
    elseif diff_percent > -20 then
        color = "ff9999" -- Light red
    else
        color = "ff0000" -- Red
    end
    
    return diff_percent, color
end

-- Add near the top with other frame declarations
local OverallFrame = CreateFrame("Frame", "WowopOverallFrame", UIParent, "BasicFrameTemplateWithInset")
OverallFrame:SetSize(600, 400)
OverallFrame:SetPoint("CENTER")
OverallFrame:SetFrameStrata("HIGH")
OverallFrame:Hide()

-- Title text
OverallFrame.title = OverallFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
OverallFrame.title:SetPoint("TOP", 0, -5)
OverallFrame.title:SetText("WoWOP.io Overall Data")

-- Create scrolling content frame
OverallFrame.ScrollFrame = CreateFrame("ScrollFrame", nil, OverallFrame, "UIPanelScrollFrameTemplate")
OverallFrame.ScrollFrame:SetPoint("TOPLEFT", 12, -30)
OverallFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

OverallFrame.ScrollChild = CreateFrame("Frame")
OverallFrame.ScrollFrame:SetScrollChild(OverallFrame.ScrollChild)
OverallFrame.ScrollChild:SetWidth(OverallFrame:GetWidth() - 40)
OverallFrame.ScrollChild:SetHeight(1) -- Will be adjusted dynamically

-- Function to create a header row
local function CreateHeaderRow(parent, text, yOffset)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 10, yOffset)
    header:SetText(text)
    return header
end

-- Function to create a data row
local function CreateDataRow(parent, yOffset)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(parent:GetWidth() - 20, 20)
    row:SetPoint("TOPLEFT", 10, yOffset)
    
    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.name:SetPoint("LEFT", 0, 0)
    row.name:SetWidth(150)
    row.name:SetJustifyH("LEFT")
    
    row.value = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.value:SetPoint("LEFT", row.name, "RIGHT", 10, 0)
    row.value:SetWidth(120)
    row.value:SetJustifyH("RIGHT")
    
    row.avgValue = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.avgValue:SetPoint("LEFT", row.value, "RIGHT", 10, 0)
    row.avgValue:SetWidth(120)
    row.avgValue:SetJustifyH("RIGHT")
    
    row.comparison = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.comparison:SetPoint("LEFT", row.avgValue, "RIGHT", 10, 0)
    row.comparison:SetWidth(80)
    row.comparison:SetJustifyH("RIGHT")
    
    return row
end

-- Function to update the overall frame with data
local function UpdateOverallFrame(data, db_data)
    if not data or not db_data then return end
    
    -- Recreate the ScrollChild frame to ensure it's clean
    if OverallFrame.ScrollChild then
        OverallFrame.ScrollChild:Hide()
        OverallFrame.ScrollChild:SetParent(nil)
    end
    
    OverallFrame.ScrollChild = CreateFrame("Frame")
    OverallFrame.ScrollFrame:SetScrollChild(OverallFrame.ScrollChild)
    OverallFrame.ScrollChild:SetWidth(OverallFrame:GetWidth() - 40)
    OverallFrame.ScrollChild:SetHeight(1) -- Will be adjusted dynamically
    
    local yOffset = -10
    local rows = {}
    
    -- Dungeon Info Header
    local dungeonInfo = CreateHeaderRow(OverallFrame.ScrollChild, 
        string.format("%s (Level %d)", db_data.dungeon_name, data.keystone_level), 
        yOffset)
    yOffset = yOffset - 30
    
    -- Column Headers
    local headerRow = CreateDataRow(OverallFrame.ScrollChild, yOffset)
    headerRow.name:SetText("Name")
    headerRow.value:SetText("Player")
    headerRow.avgValue:SetText("Spec Average")
    headerRow.comparison:SetText("Difference")
    yOffset = yOffset - 25
    
    -- Damage Section
    local damageHeader = CreateHeaderRow(OverallFrame.ScrollChild, "Damage", yOffset)
    yOffset = yOffset - 25
    
    for name, info in pairs(data.damage) do
        local row = CreateDataRow(OverallFrame.ScrollChild, yOffset)
        local class_color = RAID_CLASS_COLORS[info.class] or RAID_CLASS_COLORS["PRIEST"]
        local db_spec = db_data.specs[info.spec_id]
        local db_level = db_spec and db_spec.keystone_levels[data.keystone_level]
        local avg_dps = db_level and db_level.avg_dps or 0
        
        local dps_diff, dps_color = GetPerformanceComparison(info.dps, avg_dps)
        
        row.name:SetText(string.format("|c%s%s|r", class_color.colorStr or "ffffffff", name))
        row.value:SetText(string.format("%.1fk", info.dps / 1000))
        row.avgValue:SetText(string.format("%.1fk", avg_dps / 1000))
        row.comparison:SetText(string.format("|cff%s(%+.1f%%)|r", dps_color, dps_diff))
        
        yOffset = yOffset - 20
        table.insert(rows, row)
    end
    
    -- Healing Section
    yOffset = yOffset - 20
    local healingHeader = CreateHeaderRow(OverallFrame.ScrollChild, "Healing", yOffset)
    yOffset = yOffset - 25
    
    for name, info in pairs(data.healing) do
        local row = CreateDataRow(OverallFrame.ScrollChild, yOffset)
        local class_color = RAID_CLASS_COLORS[info.class] or RAID_CLASS_COLORS["PRIEST"]
        local db_spec = db_data.specs[info.spec_id]
        local db_level = db_spec and db_spec.keystone_levels[data.keystone_level]
        local avg_hps = db_level and db_level.avg_hps or 0
        
        local hps_diff, hps_color = GetPerformanceComparison(info.hps, avg_hps)
        
        row.name:SetText(string.format("|c%s%s|r", class_color.colorStr or "ffffffff", name))
        row.value:SetText(string.format("%.1fk", info.hps / 1000))
        row.avgValue:SetText(string.format("%.1fk", avg_hps / 1000))
        row.comparison:SetText(string.format("|cff%s(%+.1f%%)|r", hps_color, hps_diff))
        
        yOffset = yOffset - 20
        table.insert(rows, row)
    end
    
    -- Interrupts Section
    yOffset = yOffset - 20
    local interruptsHeader = CreateHeaderRow(OverallFrame.ScrollChild, "Interrupts", yOffset)
    yOffset = yOffset - 25
    
    for name, info in pairs(data.interrupts) do
        if info.total and info.total > 0 then
            local row = CreateDataRow(OverallFrame.ScrollChild, yOffset)
            local class_color = RAID_CLASS_COLORS[info.class] or RAID_CLASS_COLORS["PRIEST"]
            local db_spec = db_data.specs[info.spec_id]
            local db_level = db_spec and db_spec.keystone_levels[data.keystone_level]
            local avg_interrupts = db_level and db_level.avg_interrupts or 0
            
            local int_diff, int_color = GetPerformanceComparison(info.total, avg_interrupts)
            
            row.name:SetText(string.format("|c%s%s|r", class_color.colorStr or "ffffffff", name))
            row.value:SetText(tostring(math.floor(info.total + 0.5)))
            row.avgValue:SetText(string.format("%.1f", avg_interrupts))
            row.comparison:SetText(string.format("|cff%s(%+.1f%%)|r", int_color, int_diff))
            
            yOffset = yOffset - 20
            table.insert(rows, row)
        end
    end
    
    -- Deaths Section
    local has_deaths = false
    for _, info in pairs(data.deaths) do
        if info.total and info.total > 0 then
            has_deaths = true
            break
        end
    end
    
    if has_deaths then
        yOffset = yOffset - 20
        local deathsHeader = CreateHeaderRow(OverallFrame.ScrollChild, "Deaths", yOffset)
        yOffset = yOffset - 25
        
        for name, info in pairs(data.deaths) do
            if info.total and info.total > 0 then
                local row = CreateDataRow(OverallFrame.ScrollChild, yOffset)
                local class_color = RAID_CLASS_COLORS[info.class] or RAID_CLASS_COLORS["PRIEST"]
                local db_spec = db_data.specs[info.spec_id]
                local db_level = db_spec and db_spec.keystone_levels[data.keystone_level]
                local avg_deaths = db_level and db_level.avg_deaths or 0
                
                local death_diff, death_color = GetPerformanceComparison(info.total, avg_deaths)
                death_color = death_color == "00ff00" and "ff0000" or death_color == "ff0000" and "00ff00" or death_color
                
                row.name:SetText(string.format("|c%s%s|r", class_color.colorStr or "ffffffff", name))
                row.value:SetText(tostring(math.floor(info.total + 0.5)))
                row.avgValue:SetText(string.format("%.1f", avg_deaths))
                row.comparison:SetText(string.format("|cff%s(%+.1f%%)|r", death_color, death_diff))
                
                yOffset = yOffset - 20
                table.insert(rows, row)
            end
        end
    end
    
    -- Update scroll child height
    OverallFrame.ScrollChild:SetHeight(math.abs(yOffset) + 20)
end

-- Modify the PrintOverallData function to use the popup
local function PrintOverallData()
    local data = GetDetailsOverallData()
    if not data then return end
    
    -- Get database averages for current dungeon and key level
    local db_data = WOWOP_SPEC_PERFORMANCE[data.zone_id]
    if not db_data then
        print(string.format("|cffff0000WoWOP.io:|r No database information available for this dungeon (zone_id: %d).", data.zone_id))
        return
    end
    
    UpdateOverallFrame(data, db_data)
    OverallFrame:Show()
end

-- Update the existing slash command handler
SLASH_WOWOP1 = "/wowop"
SlashCmdList["WOWOP"] = function(msg)
    local command, rest = strmatch(msg, "^(%S*)%s*(.-)%s*$")
    command = command:lower()  -- Only convert the command to lowercase, not the arguments
    
    if command == "" or command == "guide" then
        if addon.ToggleDungeonGuide then
            addon.ToggleDungeonGuide()
        else
            print("|cffff0000WoWOP.io:|r |cffff9933Error - Guide module not loaded properly|r")
            print("|cffff0000Please report this error to the addon author|r")
        end
    elseif command == "post" then
        PostPartyStats()
    elseif command == "lookup" then
        LookupPlayerStats(rest)  -- Pass the rest of the string without converting to lowercase
    elseif command == "test" then
        TestDeathAnalysis(rest)
    elseif command == "overall" then
        PrintOverallData()
    else
        print("|cffff0000WoWOP.io:|r |cffff9933Available commands:|r")
        print("/wowop - Show this help message")
        print("/wowop post - Post group member scores to party/raid chat")
        print("/wowop guide - Open the WoWOP.io Mythic+ Guide")
        print("/wowop lookup Playername-Realm - Look up a player's scores")
        print("/wowop test spellId - Test death analysis for a specific spell")
        print("/wowop overall - Show overall damage/healing/interrupt/death data from Details!")
    end
end

-- Modify the OnEvent function to ensure database is loaded
local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        LoadRegionDatabase()
        LoadDungeonDatabase()
        LoadSpecPerformanceDatabase()
        if LoadDungeonDatabase() then
            print("|cffff0000WoWOP.io addon loaded!|r")
        else
            print("|cffff0000WoWOP.io addon loaded, but dungeon database failed to load!|r")
        end
        print("|cffff0000WoWOP.io:|r |cffff9933IMPORTANT!|r Please visit the website |cff00ccffhttps://wowop.io|r to download our log uploader, so your runs can be processed.")
        print("|cffff0000WoWOP.io:|r We had to change the way we process logs, so the only option is, that at least 1 person in your group has our Desktop App installed.")
        print("|cffff0000WoWOP.io:|r If you don't want to do that, you can still use the website to see your own stats, but only if another person from your group has our Desktop App installed.")
        -- Hook all tooltips
        HookTooltips()
    elseif event == "CHALLENGE_MODE_START" then
        -- set the start time of the key (and add 10 seconds, because there's a 10 second timer)
        starttime = GetTime() + 10
        -- set the end time of the key to nil
        endtime = nil
        print(string.format("|cffff0000WoWOP.io:|r M+ run started. Start Time: %f", starttime))
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        -- set the end time of the key
        endtime = GetTime()
        -- calculate the duration of the key
        challenge_mode_duration = endtime - starttime
        
        -- reset start and end time
        starttime = nil
        endtime = nil

        -- Only show the scoreboard automatically if the setting is enabled
        if addon:IsAutoMPlusPopupEnabled() then
            C_Timer.After(1, function()
                PrintOverallData()
            end)
        else
            print("|cffff0000WoWOP.io:|r Automatic scoreboard disabled. Use /wowop overall to show it manually.")
        end
    end
end

frame:SetScript("OnEvent", OnEvent)
  
  