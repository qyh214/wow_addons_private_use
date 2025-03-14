local myname, ns = ...

local GetPlayerAuraBySpellID = C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID or _G.GetPlayerAuraBySpellID

ns.defaults = {
    profile = {
        default_icon = "VignetteLoot",
        show_on_world = true,
        show_on_minimap = false,
        show_npcs = true,
        show_npcs_filter = "lootable", -- [lootable, notable]
        show_npcs_emphasizeNotable = true,
        show_treasure = true,
        show_treasure_filter = "lootable", -- [lootable, notable]
        -- show_treasure_emphasizeNotable = true,
        show_routes = true,
        upcoming = true,
        found = false,
        alts_achievements_count = false,
        -- notability!
        achievement_notable = true,
        mount_notable = true,
        toy_notable = true,
        pet_notable = true,
        transmog_notable = true,
        quest_notable = true,
        transmog_specific = true, -- consider whether you know the appearance from *this* item specifically
        -- icon stuff
        icon_scale = 1.0,
        icon_alpha = 1.0,
        icon_item = false,
        tooltip_charloot = true,
        tooltip_pointanchor = false,
        tooltip_item = true,
        tooltip_questid = false,
        groupsHidden = {},
        groupsHiddenByZone = {['*']={},},
        zonesHidden = {},
        achievementsHidden = {},
        worldmapoverlay = true,
    },
    char = {
        hidden = {
            ['*'] = {},
        },
    },
}

ns.options = {
    type = "group",
    name = myname:gsub("HandyNotes_", ""),
    get = function(info) return ns.db[info[#info]] end,
    set = function(info, v)
        ns.db[info[#info]] = v
        ns.HL:Refresh()
    end,
    hidden = function(info)
        return ns.hiddenConfig[info[#info]]
    end,
    childGroups = "tab",
    args = {
        common = {
            type = "group",
            name = "Common",
            args = {
                icon = {
                    type = "group",
                    name = "Icons",
                    inline = true,
                    order = 10,
                    args = {
                        desc = {
                            name = "These settings control the look and feel of the icon.",
                            type = "description",
                            order = 0,
                        },
                        icon_scale = {
                            type = "range",
                            name = "Icon Scale",
                            desc = "The scale of the icons",
                            min = 0.25, max = 2, step = 0.01,
                            order = 20,
                        },
                        icon_alpha = {
                            type = "range",
                            name = "Icon Alpha",
                            desc = "The alpha transparency of the icons",
                            min = 0, max = 1, step = 0.01,
                            order = 30,
                        },
                        show_on_world = {
                            type = "toggle",
                            name = "World Map",
                            desc = "Show icons on world map",
                            order = 40,
                        },
                        show_on_minimap = {
                            type = "toggle",
                            name = "Minimap",
                            desc = "Show all icons on the minimap",
                            order = 50,
                        },
                        default_icon = {
                            type = "select",
                            name = "Default Icon",
                            values = {
                                VignetteLoot = CreateAtlasMarkup("VignetteLoot", 20, 20) .. " Chest",
                                VignetteLootElite = CreateAtlasMarkup("VignetteLootElite", 20, 20) .. " Chest with star",
                                Garr_TreasureIcon = CreateAtlasMarkup("Garr_TreasureIcon", 20, 20) .. " Shiny chest",
                            },
                            order = 60,
                        },
                        worldmapoverlay = {
                            type = "toggle",
                            name = "Add button to world map",
                            desc = "Put a button on the world map for quick access to these options",
                            set = function(info, v)
                                ns.db[info[#info]] = v
                                if WorldMapFrame.RefreshOverlayFrames then
                                    WorldMapFrame:RefreshOverlayFrames()
                                end
                            end,
                            hidden = function(info)
                                if not ns.SetupMapOverlay then
                                    return true
                                end
                                return ns.options.hidden(info)
                            end,
                            order = 70,
                        },
                    },
                },
                display = {
                    type = "group",
                    name = "What to display",
                    inline = true,
                    order = 20,
                    args = {
                        npcs = {
                            type = "group",
                            inline = true,
                            name = "NPCs",
                            args = {
                                show_npcs = {
                                    type = "toggle",
                                    name = "Show NPCs",
                                    desc = "Show rare NPCs, generally to be killed for items or achievements",
                                    order = 10,
                                    dropdownHidden = true,
                                },
                                show_npcs_filter = {
                                    type = "select",
                                    name = "Filter",
                                    desc = "Show rare NPCs, generally to be killed for items or achievements",
                                    values = {
                                        all = ALL,
                                        lootable = "Will drop loot",
                                        notable = "Will drop notable loot",
                                    },
                                    sorting = {"all", "lootable", "notable"},
                                    order = 20,
                                },
                                show_npcs_emphasizeNotable = {
                                    type = "toggle",
                                    name = "Emphasize notable NPCs",
                                    desc = "Put more emphasis on NPCs that you can still get something from: achievements, transmogs, mounts, pets, toys",
                                    order = 30,
                                },

                            },
                            order = 10,
                        },
                        treasure = {
                            type = "group",
                            inline = true,
                            name = "Treasure",
                            args = {
                                show_treasure = {
                                    type = "toggle",
                                    name = "Show Treasure",
                                    desc = "Show treasures that can be found in the world",
                                    order = 10,
                                    dropdownHidden = true,
                                },
                                show_treasure_filter = {
                                    type = "select",
                                    name = "Filter",
                                    desc = "Show treasures that can be found in the world",
                                    values = {
                                        all = ALL,
                                        lootable = "Will drop loot",
                                        notable = "Will drop notable loot",
                                    },
                                    sorting = {"all", "lootable", "notable"},
                                    order = 20,
                                },
                                -- show_treasure_emphasizeNotable = {
                                --     type = "toggle",
                                --     name = "Emphasize notable NPCs",
                                --     desc = "Put more emphasis on NPCs that you can still get something from: achievements, transmogs, mounts, pets, toys",
                                --     order = 30,
                                -- },

                            },
                            order = 20,
                        },
                        unhide = {
                            type = "execute",
                            name = "Reset hidden nodes",
                            desc = "Show all nodes that you manually hid by right-clicking on them and choosing \"hide\".",
                            func = function()
                                for _, coords in pairs(ns.hidden) do
                                    wipe(coords)
                                end
                                ns.HL:Refresh()
                            end,
                            order = 50,
                        },
                    },
                },
                -- the "found" cluster
                found = {
                    type = "group",
                    name = "Found...",
                    inline = true,
                    order = 30,
                    args = {
                        found = {
                            type = "toggle",
                            name = "Show found",
                            desc = "Show waypoints for items you've already found?",
                            order = 20,
                        },
                    },
                },
                tooltips = {
                    type = "group",
                    name = "Tooltips",
                    desc = "Settings about how tooltips are displayed",
                    inline = true,
                    args = {
                        tooltip_item = {
                            type = "toggle",
                            name = "Use item tooltips",
                            desc = "Show the full tooltips for items",
                            order = 10,
                        },
                        tooltip_charloot = {
                            type = "toggle",
                            name = "Loot for this character only",
                            desc = "Only show loot that should drop for the current character",
                            order = 12,
                        },
                        tooltip_pointanchor = {
                            type = "toggle",
                            name = "Anchor tooltips to points",
                            desc = "Whether to anchor the tooltips to the individual points or to the map",
                            order = 15,
                        },
                        tooltip_questid = {
                            type = "toggle",
                            name = "Show quest ids",
                            desc = "Show the internal id of the quest associated with this node. Handy if you want to report a problem with it.",
                            order = 40,
                        },
                    },
                    order = 25,
                },
                notable = {
                    type = "group",
                    name = "What's notable?",
                    desc = "Define exactly what counts as being \"notable\"",
                    inline = true,
                    args = {
                        achievement_notable = {
                            type = "toggle",
                            name = TRANSMOG_SOURCE_5,
                            desc = "Count unlearned achievement-progress as notable",
                            order = 10,
                        },
                        mount_notable = {
                            type = "toggle",
                            name = MOUNT,
                            desc = "Count unlearned mounts as notable loot",
                            order = 10,
                        },
                        toy_notable = {
                            type = "toggle",
                            name = TOY,
                            desc = "Count unlearned toys as notable loot",
                            order = 20,
                        },
                        pet_notable = {
                            type = "toggle",
                            name = TOOLTIP_BATTLE_PET,
                            desc = "Count uncaught pets as notable loot",
                            order = 30,
                        },
                        transmog_notable = {
                            type = "toggle",
                            name = "Transmog",
                            desc = "Count unlearned transmogrification appearances as notable loot",
                            order = 40,
                        },
                        quest_notable = {
                            type = "toggle",
                            name = "Quest-attached",
                            desc = "Count items with attached uncompleted quests as notable loot (this includes a lot of \"learnable\" items, weekly reputation drops, etc)",
                            order = 50,
                        },
                    },
                    order = 40,
                },
                fiddly = {
                    type = "group",
                    name = "Fiddly details",
                    desc = "Quirky small tweaks",
                    inline = true,
                    args = {
                        icon_item = {
                            type = "toggle",
                            name = "Use item icons",
                            desc = "Show the icons for items, if known; otherwise, the achievement icon will be used",
                            order = 10,
                        },
                        upcoming = {
                            type = "toggle",
                            name = "Show inaccessible",
                            desc = "Show waypoints for items you can't get yet (max level, gated quests, etc); they'll be tinted red to indicate this",
                            order = 25,
                        },
                        show_routes = {
                            type = "toggle",
                            name = "Show routes",
                            desc = "Show relevant routes between points ",
                            disabled = function() return not ns.RouteWorldMapDataProvider end,
                            order = 37,
                        },
                        transmog_specific = {
                            type = "toggle",
                            name = "Transmog exact items",
                            desc = "For transmog appearances, only count them as known if you know them from that exact item, rather than from another sharing the same appearance",
                            order = 45,
                        },
                        alts_achievements_count = {
                            type = "toggle",
                            name = "Alts achievements count",
                            desc = "Consider achievement-related things done if you have it completed on another character already. Lots of achievement criteria are warband-shared, in which case this setting won't make a difference.",
                            order = 55,
                        },
                    },
                    order = 50,
                },
            },
        },
        data = {
            name = "Data",
            type = "group",
            args = {
                achievementsHidden = {
                    type = "multiselect",
                    name = "Show achievements",
                    desc = "Toggle whether you want to show points for a given achievement",
                    get = function(info, key) return not ns.db[info[#info]][key] end,
                    set = function(info, key, value)
                        ns.db[info[#info]][key] = not value
                        ns.HL:Refresh()
                    end,
                    values = function(info)
                        local values = {}
                        for uiMapID, points in pairs(ns.points) do
                            for coord, point in pairs(points) do
                                if point.achievement and not values[point.achievement] then
                                    local _, achievement = GetAchievementInfo(point.achievement)
                                    values[point.achievement] = achievement or ('achievement:'..point.achievement)
                                end
                            end
                        end
                        -- replace ourself with the built values table
                        info.option.values = values
                        return values
                    end,
                    hidden = function(info)
                        for uiMapID, points in pairs(ns.points) do
                            for coord, point in pairs(points) do
                                if point.achievement then
                                    info.option.hidden = nil
                                    return ns.options.hidden(info)
                                end
                            end
                        end
                        info.option.hidden = true
                        return true
                    end,
                    order = 30,
                },
                zonesHidden = {
                    type = "multiselect",
                    name = "Show in zones",
                    desc = "Toggle whether you want to show points in a given zone",
                    get = function(info, key) return not ns.db[info[#info]][key] end,
                    set = function(info, key, value)
                        ns.db[info[#info]][key] = not value
                        ns.HL:Refresh()
                    end,
                    values = function(info)
                        local values = {}
                        for uiMapID in pairs(ns.points) do
                            if not values[uiMapID] then
                                local info = C_Map.GetMapInfo(uiMapID)
                                if info and info.mapType == 3 then
                                    -- zones only
                                    values[uiMapID] = info.name
                                end
                            end
                        end
                        -- replace ourself with the built values table
                        info.option.values = values
                        return values
                    end,
                    order = 35,
                },
                groupsHidden = {
                    type = "multiselect",
                    name = "Show groups",
                    desc = "Toggle whether to show certain groups of points",
                    get = function(info, key) return not ns.db[info[#info]][key] end,
                    set = function(info, key, value)
                        ns.db[info[#info]][key] = not value
                        ns.HL:Refresh()
                    end,
                    values = function(info)
                        local values = {}
                        for uiMapID, points in pairs(ns.points) do
                            for coord, point in pairs(points) do
                                if point.group and not values[point.group] then
                                    values[point.group] = ns.render_string(ns.groups[point.group] or point.group)
                                end
                            end
                        end
                        -- replace ourself with the built values table
                        info.option.values = values
                        return values
                    end,
                    hidden = function(info)
                        for uiMapID, points in pairs(ns.points) do
                            for coord, point in pairs(points) do
                                if point.group then
                                    info.option.hidden = nil
                                    return ns.options.hidden(info)
                                end
                            end
                        end
                        info.option.hidden = true
                        return true
                    end,
                    order = 40,
                },
            },
        },
    },
}

local function doTestAll(test, input, ...)
    for _, value in ipairs(input) do
        if not test(value, ...) then
            return false
        end
    end
    return true
end
local function doTestAny(test, input, ...)
    for _, value in ipairs(input) do
        if test(value, ...) then
            return true
        end
    end
    return false
end
local doTest, doTestDefaultAny
do
    local function doTestMaker(default)
        return function(test, input, ...)
            if ns.xtype(input) == "table" then
                if input.any then return doTestAny(test, input, ...) end
                if input.all then return doTestAll(test, input, ...) end
                return default(test, input, ...)
            else
                return test(input, ...)
            end
        end
    end
    doTest = doTestMaker(doTestAll)
    doTestDefaultAny = doTestMaker(doTestAny)
end
ns.doTest = doTest
ns.doTestDefaultAny = doTestDefaultAny
local function testMaker(test, override)
    return function(...)
        return (override or doTest)(test, ...)
    end
end

local itemInBags = testMaker(function(item) return C_Item.GetItemCount(item, true) > 0 end)
local allQuestsComplete = testMaker(function(quest) return C_QuestLog.IsQuestFlaggedCompleted(quest) end)
ns.allQuestsComplete = allQuestsComplete

local temp_criteria = {}
local allCriteriaComplete = testMaker(function(criteria, achievement)
    local _, _, completed, _, _, completedBy = ns.GetCriteria(achievement, criteria)
    -- by this current character, or by any character if the setting says it's okay
    return completed and (not completedBy or completedBy == ns.playerName or ns.db.alts_achievements_count)
end, function(test, input, achievement, ...)
    if input == true then
        wipe(temp_criteria)
        for i=1,GetAchievementNumCriteria(achievement) do
            table.insert(temp_criteria, i)
        end
        input = temp_criteria
    end
    return doTest(test, input, achievement, ...)
end)

local hasNotableLoot = testMaker(function(item, notransmog)
    if item:Notable() then
        if notransmog and ns.IsA(item, ns.rewards.Item) then
            -- still notable without transmog involved?
            return item:IsTransmog() == false
        end
        return true
    end
    return false
end, doTestAny)
ns.hasNotableLoot = hasNotableLoot
local hasKnowableLoot = testMaker(function(item, droppable)
    if ns.CLASSIC then return false end
    if droppable and not item:MightDrop() then
        -- a non-droppable item *counts* as unknowable
        return false
    end
    return item:Obtained(true) ~= nil
end, doTestAny)
local allLootKnown = testMaker(function(item, droppable)
    -- This returns true if all loot is known-or-unknowable
    -- If the "no knowable loot" case matters this should be gated behind hasKnowableLoot
    if droppable and not item:MightDrop() then
        -- a non-droppable item counts as known regardless of whether it really is
        return true
    end
    -- true-or-nil means known or not-knowable
    return item:Obtained(true) ~= false
end)

local function isAchieved(point)
    if point.criteria and point.criteria ~= true then
        return allCriteriaComplete(point.criteria, point.achievement)
    end
    local _, _, _, complete, _, _, _, _, _, _, _, _, completedByMe = GetAchievementInfo(point.achievement)
    return completedByMe or (ns.db.alts_achievements_count and complete)
end
local function isNotable(point, lootable)
    -- A point is notable if it has loot you can use, or is tied to an
    -- achievement you can still earn
    if lootable and point.quest and allQuestsComplete(point.quest) then
        -- asked for only notable points that are currently lootable, which
        -- means questless or quest-incomplete
        return false
    end
    if ns.db.achievement_notable and point.achievement and not isAchieved(point) then
        return true
    end
    if point.loot and hasNotableLoot(point.loot) then
        return true
    end
    if point.follower and not C_Garrison.IsFollowerCollected(point.follower) then
        return true
    end
end
ns.PointIsNotable = isNotable

local zoneHidden
zoneHidden = function(uiMapID)
    if ns.db.zonesHidden[uiMapID] then
        return true
    end
    local info = C_Map.GetMapInfo(uiMapID)
    if info and info.parentMapID then
        return zoneHidden(info.parentMapID)
    end
    return false
end
local achievementHidden = function(achievement)
    if not achievement then return false end
    return ns.db.achievementsHidden[achievement]
end

local checkPois
do
    local poi_expirations = {}
    local poi_zone_expirations = {}
    local pois_byzone = {}
    local function refreshPois(zone)
        local now = time()
        if not poi_zone_expirations[zone] or now > poi_zone_expirations[zone] then
            pois_byzone[zone] = wipe(pois_byzone[zone] or {})
            for _, poi in ipairs(C_AreaPoiInfo.GetAreaPOIForMap(zone)) do
                pois_byzone[zone][poi] = true
                poi_expirations[poi] = now + (C_AreaPoiInfo.GetAreaPOISecondsLeft(poi) or 60)
            end
            poi_zone_expirations[zone] = now + 1
        end
    end
    function checkPois(pois)
        for _, data in ipairs(pois) do
            local zone, poi = unpack(data)
            local now = time()
            if now > (poi_expirations[poi] or 0) then
                refreshPois(zone)
                poi_expirations[poi] = poi_expirations[poi] or (now + 60)
            end
            if pois_byzone[zone][poi] then
                return true
            end
        end
    end
end

local checkArt = testMaker(function(artid, uiMapID) return artid == C_Map.GetMapArtID(uiMapID) end, doTestDefaultAny)

local function showOnMapType(point, uiMapID, isMinimap)
    -- nil means to respect the preferences, but points can override
    if isMinimap then
        if point.minimap ~= nil then return point.minimap end
        if ns.map_spellids[uiMapID] then
            if ns.map_spellids[uiMapID] == true or GetPlayerAuraBySpellID(ns.map_spellids[uiMapID]) then
                return false
            end
        end
        return ns.db.show_on_minimap
    end
    if point.worldmap ~= nil then return point.worldmap end
    return ns.db.show_on_world
end

local function PointIsFound(point)
    if ns.db.found or point.always then return false end

    -- these are overrides:
    if point.inbag and itemInBags(point.inbag) then
        return true
    end
    if point.onquest and C_QuestLog.IsOnQuest(type(point.onquest) == "number" and point.onquest or point.quest) then
        return true
    end
    if point.hide_quest and C_QuestLog.IsQuestFlaggedCompleted(point.hide_quest) then
        -- This is distinct from point.quest as it's supposed to be for
        -- other trackers that make the point not _complete_ but still
        -- hidden (Draenor treasure maps, so far):
        return true
    end

    -- from here on it's actually found:
    local found
    if point.loot and hasKnowableLoot(point.loot, true) then
        -- has knowable loot that might drop
        if not allLootKnown(point.loot, true) then
            return false
        end
        found = true
    end
    if point.achievement and not point.achievementNotFound then
        if not isAchieved(point) then
            return false
        end
        found = true
    end
    if point.follower then
        if not C_Garrison.IsFollowerCollected(point.follower) then
            return false
        end
        found = true
    end
    if point.quest then
        if not allQuestsComplete(point.quest) then
            return false
        end
        found = true
    end
    if point.found then
        if not ns.conditions.check(point.found) then
            return false
        end
        found = true
    end
    return found, found ~= nil -- gets us a true/false/nil found/notfound/unfindable
end

ns.should_show_point = function(coord, point, currentZone, isMinimap)
    if not coord or coord < 0 then return false end
    if not showOnMapType(point, currentZone, isMinimap) then
        return false
    end
    if point.force ~= nil then
        return point.force
    end
    if ns.hidden[currentZone] and ns.hidden[currentZone][coord] then
        return false
    end
    if zoneHidden(currentZone) then
        return false
    end
    if achievementHidden(point.achievement) then
        return false
    end
    if point.group and ns.db.groupsHidden[point.group] or ns.db.groupsHiddenByZone[currentZone][point.group] then
        return false
    end
    if point.ShouldShow then
        local show = point:ShouldShow()
        if show ~= nil then
            return show
        end
    end
    if point.outdoors_only and IsIndoors() then
        return false
    end
    if point.art and not checkArt(point.art, currentZone) then
        return false
    end
    if point.poi and not checkPois(point.poi) then
        return false
    end
    if point.faction and point.faction ~= ns.playerFaction then
        return false
    end

    if point.follower then
        if not ns.db.found and isFound then
            return false
        end
    elseif point.npc then
        -- only npcs that are questless or that have an uncompleted quest
        if not ns.db.show_npcs then
            return false
        end
        if ns.db.show_npcs_filter == "notable" and not isNotable(point) then
            -- notable npcs have loot you can use or have an incomplete achievement
            return point.always
        end
        if
            (ns.db.show_npcs_filter == "lootable" or ns.db.show_npcs_filter == "notable")
            -- rewarding npcs either have no affiliated quest, or their quest is incomplete
            and point.quest and allQuestsComplete(point.quest) and not ns.db.found
        then
            return point.always
        end
    elseif point.loot or point.currency then
        -- Not an NPC, not a follower, must be treasure if it has some sort of loot
        if not ns.db.show_treasure then
            return false
        end
        if ns.db.show_treasure_filter == "notable" and not isNotable(point) then
            -- notable npcs have loot you can use or have an incomplete achievement
            return point.always
        end
        if
            (ns.db.show_treasure_filter == "lootable" or ns.db.show_treasure_filter == "notable")
            -- rewarding treasure either has no affiliated quest, or their quest is incomplete
            and point.quest and allQuestsComplete(point.quest) and not ns.db.found
        then
            return point.always
        end
    end
    if not ns.db.found then
        local isFound = PointIsFound(point)
        local isFindable = isFound ~= nil
        if isFindable and isFound then
            return false
        end
    end
    if point.requires_buff and not doTest(GetPlayerAuraBySpellID, point.requires_buff) then
        return false
    end
    if point.requires_no_buff and doTest(GetPlayerAuraBySpellID, point.requires_no_buff) then
        return false
    end
    if point.requires_item and not itemInBags(point.requires_item) then
        return false
    end
    if point.requires_worldquest and not (C_TaskQuest.IsActive(point.requires_worldquest) or C_QuestLog.IsQuestFlaggedCompleted(point.requires_worldquest)) then
        return false
    end
    if point.requires and not ns.conditions.check(point.requires) then
        return false
    end
    if not ns.db.upcoming or point.upcoming == false then
        if not ns.point_active(point) then
            return false
        end
        if ns.point_upcoming(point) then
            return false
        end
    end
    return true
end
