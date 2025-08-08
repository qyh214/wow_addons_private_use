local myname, ns = ...
local _, myfullname = C_AddOns.GetAddOnInfo(myname)

local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes")
local HL = LibStub("AceAddon-3.0"):NewAddon(myname, "AceEvent-3.0")
-- local L = LibStub("AceLocale-3.0"):GetLocale(myname, true)
ns.HL = HL

local HBD = LibStub("HereBeDragons-2.0")

ns.DEBUG = C_AddOns.GetAddOnMetadata(myname, "Version") == '@'..'project-version@'

ns.CLASSIC = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
ns.WARBANDS_AVAILABLE = LE_EXPANSION_LEVEL_CURRENT >= (LE_EXPANSION_WAR_WITHIN or math.huge)

local ATLAS_CHECK, ATLAS_CROSS = "common-icon-checkmark", "common-icon-redx"

local COSMETIC_COLOR = CreateColor(1, 0.5, 1)

ns.run_caches = {}

---------------------------------------------------------
-- Data model stuff:

-- flags for whether to show minimap icons in some zones, if Blizzard ever does the treasure-map thing again
ns.map_spellids = ns.map_spellids or {
    -- zone = spellid
}

ns.currencies = ns.currencies or {
    ANIMA = {
        name = '|cffff8000' .. POWER_TYPE_ANIMA .. '|r',
        texture = select(10, GetAchievementInfo(14339)),
    },
    ARTIFACT = {
        name = '|cffff8000' .. ARTIFACT_POWER .. '|r',
        texture = select(10, GetAchievementInfo(11144)),
    }
}
-- for fallbacks
ns.covenants = ns.covenants or {
    [Enum.CovenantType.Kyrian] = "Kyrian",
    [Enum.CovenantType.Necrolord] = "Necrolords",
    [Enum.CovenantType.NightFae] = "NightFae",
    [Enum.CovenantType.Venthyr] = "Venthyr",
}

ns.groups = ns.groups or {}

ns.hiddenConfig = ns.hiddenConfig or {}

ns.points = {
    --[[ structure:
    [uiMapID] = { -- "_terrain1" etc will be stripped from attempts to fetch this
        [coord] = {
            label=[string], -- label: text that'll be the label, optional
            loot={[id]}, -- itemids
            quest=[id], -- will be checked, for whether character already has it
            currency=[id], -- currencyid
            achievement=[id], -- will be shown in the tooltip
            criteria=[id], -- modifies achievement
            junk=[bool], -- doesn't count for any achievement
            npc=[id], -- related npc id, used to display names in tooltip
            note=[string], -- some text which might be helpful
            hide_before=[id], -- hide if quest not completed
            requires_buff=[id], -- hide if player does not have buff, mostly useful for buff-based zone phasing
            requires_no_buff=[id] -- hide if player has buff, mostly useful for buff-based zone phasing
        },
    },
    --]]
}
ns.POIsToPoints = {}
ns.VignetteIDsToPoints = {}
ns.WorldQuestsToPoints = {}
local function intotable(dest, value_or_table, point)
    if not value_or_table then return end
    if type(value_or_table) == "table" then
        for _, value in ipairs(value_or_table) do
            dest[value] = point
        end
        return
    end
    dest[value_or_table] = point
end
local upgradeloot
do
    local available = {}
    local function upgradelootitem(item)
        if ns.IsObject(item) then
            return item
        end
        if type(item) == "number" then
            return ns.rewards.Item(item)
        end
        local upgrade
        if item.toy then
            upgrade = ns.rewards.Toy(item[1])
        elseif item.mount then
            upgrade = ns.rewards.Mount(item[1], type(item.mount) == "number" and item.mount)
        elseif item.pet then
            upgrade = ns.rewards.Pet(item[1], type(item.pet) == "number" and item.pet)
        elseif item.set then
            upgrade = ns.rewards.Set(item[1], item.set)
        else
            upgrade = ns.rewards.Item(item[1])
        end
        upgrade.quest = item.quest
        upgrade.questComplete = item.questComplete
        upgrade.spell = item.spell
        if item.class then
            table.insert(available, ns.conditions.Class(item.class))
        end
        if item.covenant then
            table.insert(available, ns.conditions.Covenant(item.covenant))
        end
        if item.requires then
            if ns.IsObject(item.requires) then
                table.insert(available, item.requires)
            else
                for i,v in ipairs(item.requires) do
                    table.insert(available, v)
                end
            end
        end
        if #available > 0 then
            upgrade.requires = available
            available = {}
        end
        return upgrade
    end
    function upgradeloot(loot)
        if not loot then return loot end
        for i, item in ipairs(loot) do
            loot[i] = upgradelootitem(item)
        end
        return loot
    end
end
function ns.RegisterPoints(zone, points, defaults)
    if not ns.points[zone] then
        ns.points[zone] = {}
    end
    if defaults then
        local nodeType = ns.nodeMaker(defaults)
        for coord, point in pairs(points) do
            points[coord] = nodeType(point)
        end
    end
    for coord, point in pairs(points) do
        upgradeloot(point.loot)
        if ns.DEBUG and ns.points[zone][coord] then
            print(myname, "point collision", zone, coord)
        end
        ns.points[zone][coord] = point
        point._coord = coord
        point._uiMapID = zone
        point._main = point
        intotable(ns.POIsToPoints, point.areaPoi, point)
        intotable(ns.VignetteIDsToPoints, point.vignette, point)
        intotable(ns.WorldQuestsToPoints, point.worldquest, point)
        if point.route and type(point.route) == "table" then
            -- avoiding a data migration
            point.routes = {point.route}
            point.route = nil
        end
        if point.atlas and point.color then
            point.texture = ns.atlas_texture(point.atlas, point.color)
        end
        local proxy_meta
        if point.path or point.nearby or point.related then
            proxy_meta = {__index=point}
        end
        if point.path then
            local route = type(point.path) == "table" and point.path or {point.path}
            table.insert(route, 1, coord)
            ns.points[zone][route[#route]] = setmetatable({
                label=route.label or (point.npc and ("Path to {npc:%s}"):format(point.npc) or "Path to treasure"),
                atlas=route.atlas or "poi-door", scale=route.scale or 0.95, texture=false,
                minimap=true, worldmap=route.worldmap,
                note=route.note or false,
                loot=upgradeloot(route.loot),
                routes={route},
                _coord=route[#route], _uiMapID=zone,
            }, proxy_meta)
            -- highlight
            point.route = point.route or route[#route]
        end
        if point.nearby then
            local nearby = type(point.nearby) == "table" and point.nearby or {point.nearby}
            for _, ncoord in ipairs(point.nearby) do
                local npoint = setmetatable({
                    label=nearby.label or (point.npc and "Related to nearby NPC" or "Related to nearby treasure"),
                    atlas=nearby.atlas or "playerpartyblip",
                    texture=nearby.texture or false,
                    minimap=true, worldmap=nearby.worldmap, scale=0.95,
                    note=nearby.note or false,
                    loot=upgradeloot(nearby.loot), active=nearby.active,
                    _coord=ncoord, _uiMapID=zone,
                }, proxy_meta)
                if nearby.color then
                    npoint.texture = ns.atlas_texture(npoint.atlas, nearby.color)
                end
                ns.points[zone][ncoord] = npoint
            end
        end
        if point.related then
            local relatedNode = ns.nodeMaker(setmetatable({
                label=point.related.label or (point.npc and "Related to nearby NPC" or "Related to nearby treasure"),
                atlas=point.related.atlas or "playerpartyblip", color=point.related.color, scale=point.related.scale,
                texture=point.related.texture or false, minimap=point.related.minimap,
                note=point.related.note or false,
                loot=upgradeloot(point.related.loot),
                active=point.related.active, requires=point.related.requires, hide_before=point.related.hide_before,
                route=coord,
                _uiMapID=zone,
            }, proxy_meta))
            for rcoord, related in pairs(point.related) do
                if type(rcoord) == "number" then
                    local rpoint = relatedNode(related)
                    upgradeloot(rpoint.loot)
                    rpoint._coord = rcoord
                    if related.color then
                        rpoint.texture = ns.atlas_texture(rpoint.atlas, related.color)
                    end
                    if not point.routes then point.routes = {} end
                    table.insert(point.routes, {rcoord, coord, highlightOnly=true})
                    ns.points[zone][rcoord] = rpoint
                end
            end 
        end
        -- and then variations on "also register this elsewhere":
        if point.translate or point.parent or point.levels then
            local translateTo = {}
            if point.translate then
                for tzone in pairs(point.translate) do
                    if tzone ~= zone then
                        translateTo[tzone] = true
                    end
                end
            end
            if point.parent then
                local mapinfo = C_Map.GetMapInfo(zone)
                if mapinfo and mapinfo.parentMapID and mapinfo.parentMapID ~= 0 then
                    local pzone = mapinfo.parentMapID
                    translateTo[pzone] = true
                end
            end
            if point.levels then
                -- Show on other levels of the same zone
                local groupID = C_Map.GetMapGroupID(zone)
                if groupID then
                    local members = C_Map.GetMapGroupMembersInfo(groupID)
                    if members then
                        for _, member in pairs(members) do
                            if member.mapID ~= zone then
                                translateTo[member.mapID] = true
                            end
                        end
                    end
                end
            end
            local x, y = HandyNotes:getXY(coord)
            for tzone in pairs(translateTo) do
                local tx, ty = HBD:TranslateZoneCoordinates(x, y, zone, tzone)
                if tx and ty then
                    if not ns.points[tzone] then
                        ns.points[tzone] = {}
                    end
                    local tcoord = HandyNotes:getCoord(tx, ty)
                    if ns.DEBUG and ns.points[tzone][tcoord] then
                        print(myname, "translate point collision", zone, coord, "to", tzone, tcoord)
                    end
                    ns.points[tzone][tcoord] = point
                elseif ns.DEBUG then
                    print(myname, "translation failed", x, y, zone, tzone)
                end
            end
        end
        if point.additional then
            -- Extra coordinates to register. This is equivalent to just
            -- registering the same table multiple times on the input, and
            -- should only be used for simple cases -- related points are
            -- going to fall apart here.
            for _,acoord in pairs(point.additional) do
                if ns.DEBUG and ns.points[zone][acoord] then
                    print(myname, "point collision", zone, acoord)
                end
                ns.points[zone][acoord] = point
            end
        end
    end
end
function ns.RegisterVignettes(zone, vignettes, defaults)
    if defaults then
        defaults = ns.nodeMaker(defaults)
    end
    for vignetteID, point in pairs(vignettes) do
        point = defaults and defaults(point) or point

        point._coord = point._coord or 0
        point._uiMapID = zone
        point.vignette = vignetteID
        point.always = true
        point.label = false
        point.loot = upgradeloot(point.loot)

        intotable(ns.POIsToPoints, point.areaPoi, point)
        intotable(ns.VignetteIDsToPoints, point.vignette, point)
        intotable(ns.WorldQuestsToPoints, point.worldquest, point)
    end
end

ns.merge = function(t1, t2)
    if not t2 then return t1 end
    for k, v in pairs(t2) do
        t1[k] = v
    end
    return t1
end

ns.nodeMaker = function(defaults)
    local meta = {__index = defaults}
    return function(details)
        details = details or {}
        if details.note and defaults.note then
            details.note = details.note .. "\n" .. defaults.note
        end
        local meta2 = getmetatable(details)
        if meta2 and meta2.__index then
            return setmetatable(details, {__index = ns.merge(CopyTable(defaults, true), meta2.__index)})
        end
        return setmetatable(details, meta)
    end
end

ns.path = ns.nodeMaker{
    label = "Path to treasure",
    atlas = "poi-door", -- 'PortalPurple' / 'PortalRed'?
    minimap = true,
    scale = 0.95,
}

ns.lootitem = function(item)
    return ns.IsObject(item) and item.id
end

local playerClassLocal, playerClass = UnitClass("player")
ns.playerClass = playerClass
ns.playerClassLocal = playerClassLocal
ns.playerClassColor = RAID_CLASS_COLORS[playerClass]
ns.playerName = UnitName("player")
ns.playerFaction = UnitFactionGroup("player")
ns.playerClassMask = ({
    -- this is 2^(classID - 1)
    WARRIOR = 0x1,
    PALADIN = 0x2,
    HUNTER = 0x4,
    ROGUE = 0x8,
    PRIEST = 0x10,
    DEATHKNIGHT = 0x20,
    SHAMAN = 0x40,
    MAGE = 0x80,
    WARLOCK = 0x100,
    MONK = 0x200,
    DRUID = 0x400,
    DEMONHUNTER = 0x800,
    EVOKER = 0x1000,
})[playerClass] or 0

---------------------------------------------------------
-- All the utility code

ns.Getterize = function(tbl)
    return setmetatable(tbl, {
        __index=function(self, key)
            if self.__get[key] then return self.__get[key](self) end
        end,
    })
end

function ns.IsCosmeticItem(itemInfo)
    if _G.C_Item and C_Item.IsCosmeticItem then
        return C_Item.IsCosmeticItem(itemInfo)
    elseif _G.IsCosmeticItem then
        return IsCosmeticItem(itemInfo)
    end
    return false
end

function ns.GetCriteria(achievement, criteriaid)
    local retOK, criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible = pcall(criteriaid < 100 and GetAchievementCriteriaInfo or GetAchievementCriteriaInfoByID, achievement, criteriaid, true)
    if not retOK then return end
    return criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible
end

local mob_name
if _G.C_TooltipInfo then
    local name_cache = {}
    mob_name = function(id)
        if not name_cache[id] then
            local info = C_TooltipInfo.GetHyperlink(("unit:Creature-0-0-0-0-%d"):format(id))
            if info and info.lines and info.lines[1] then
                if info.lines[1].type == Enum.TooltipDataType.Unit then
                    name_cache[id] = info.lines[1].leftText
                end
            end
        end
        return name_cache[id]
    end
else
    -- pre-10.0.2
    local cache_tooltip = _G["HNTreasuresCacheScanningTooltip"]
    if not cache_tooltip then
        cache_tooltip = CreateFrame("GameTooltip", "HNTreasuresCacheScanningTooltip")
        cache_tooltip:AddFontStrings(
            cache_tooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
            cache_tooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
        )
    end
    local name_cache = {}
    mob_name = function(id)
        if not name_cache[id] then
            -- this doesn't work with just clearlines and the setowner outside of this, and I'm not sure why
            cache_tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
            cache_tooltip:SetHyperlink(("unit:Creature-0-0-0-0-%d"):format(id))
            if cache_tooltip:IsShown() then
                name_cache[id] = HNTreasuresCacheScanningTooltipTextLeft1:GetText()
            end
        end
        return name_cache[id]
    end
end
local function quick_texture_markup(icon)
    -- needs less than CreateTextureMarkup
    return icon and ('|T' .. icon .. ':0:0:1:-1|t') or ''
end
ns.quick_texture_markup = quick_texture_markup
local completeColor = CreateColor(0, 1, 0, 1)
local incompleteColor = CreateColor(1, 0, 0, 1)
local function render_string(s, context)
    if type(s) == "function" then s = s(context) end
    return s:gsub("{([^:}]+):([^:}]+):?([^}]*)}", function(variant, id, fallback)
        local mainid, subid = id:match("(%d+)%.(%d+)")
        mainid, subid = mainid and tonumber(mainid), subid and tonumber(subid)
        id = mainid or tonumber(id)
        -- TODO: multiple variants?
        local mainvariant, subvariant = variant:match("(%l+)%.(%l+)")
        if subvariant then
            variant = mainvariant
        end
        if variant == "item" then
            local name, link, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(id)
            if link and icon then
                if subvariant == "plain" then return name end
                return quick_texture_markup(icon) .. " " .. link:gsub("[%[%]]", "")
            end
        elseif variant == "spell" then
            local name, icon, _
            if C_Spell and C_Spell.GetSpellInfo then
                local info = C_Spell.GetSpellInfo(id)
                if info then
                    name, icon = info.name, info.iconID
                end
            else
                name, _, icon = GetSpellInfo(id)
            end
            if name and icon then
                if subvariant == "plain" then return name end
                return quick_texture_markup(icon) .. " " .. name
            end
        elseif variant == "quest" or variant == "worldquest" or variant == "questname" then
            local name = C_QuestLog.GetTitleForQuestID(id)
            if not (name and name ~= "") then
                -- we bypass the normal fallback mechanism because we want the quest completion status
                name = fallback ~= "" and fallback or (variant .. ':' .. id)
            end
            if variant == "questname" or subvariant == "plain" then return name end
            local completed = C_QuestLog.IsQuestFlaggedCompleted(id)
            return CreateAtlasMarkup(variant == "worldquest" and "worldquest-tracker-questmarker" or "questnormal") ..
                (completed and completeColor or incompleteColor):WrapTextInColorCode(name)
        elseif variant == "questid" then
            if subvariant == "plain" then return id end
            return CreateAtlasMarkup("questnormal") .. (C_QuestLog.IsQuestFlaggedCompleted(id) and completeColor or incompleteColor):WrapTextInColorCode(id)
        elseif variant == "achievement" or variant == "achievementname" then
            if mainid and subid then
                local criteria, _, completed, _, _, completedBy = ns.GetCriteria(mainid, subid)
                if criteria then
                    if variant == "achievementname" or subvariant == "plain" then return criteria end
                    if subvariant == "character" then
                        completed = completedBy == ns.playerName
                    end
                    return (completed and completeColor or incompleteColor):WrapTextInColorCode(criteria)
                end
                id = 'achievement:'..mainid..'.'..subid
            else
                local _, name, _, completed, _, _, _, _, _, _, _, _, wasEarnedByMe = GetAchievementInfo(id)
                if name and name ~= "" then
                    if variant == "achievementname" or subvariant == "plain" then return name end
                    if subvariant == "character" then
                        completed = wasEarnedByMe
                    end
                    return CreateAtlasMarkup("storyheader-cheevoicon") .. " " .. (completed and completeColor or incompleteColor):WrapTextInColorCode(name)
                end
            end
        elseif variant == "npc" then
            local name = mob_name(id)
            if name then
                return name
            end
        elseif variant == "currency" then
            local info = C_CurrencyInfo.GetCurrencyInfo(id)
            if info then
                if subvariant == "plain" then return info.name end
                return quick_texture_markup(info.iconFileID) .. " " .. info.name
            end
        elseif variant == "currencyicon" then
            local info = C_CurrencyInfo.GetCurrencyInfo(id)
            if info then
                return quick_texture_markup(info.iconFileID)
            end
        elseif variant == "covenant" then
            local data = C_Covenants.GetCovenantData(id)
            local name = data and data.name or ns.covenants[id]
            if subvariant == "plain" then return name end
            return COVENANT_COLORS[id]:WrapTextInColorCode(name)
        elseif variant == "majorfaction" then
            local info = C_MajorFactions.GetMajorFactionData(id)
            if info and info.name then
                if subvariant == "plain" then return info.name end
                return CreateAtlasMarkup(("majorFactions_icons_%s512"):format(info.textureKit)) .. " " .. info.name
            end
        elseif variant == "faction" then
            local name
            if C_Reputation and C_Reputation.GetFactionDataByID then
                local info = C_Reputation.GetFactionDataByID(id)
                if info and info.name then
                    name = info.name
                end
            elseif GetFactionInfoByID then
                name = GetFactionInfoByID(id)
            end
            if name then
                if subid then
                    return TEXT_MODE_A_STRING_VALUE_TYPE:format(name, GetText("FACTION_STANDING_LABEL"..subid, UnitSex("player")) or string(subid))
                end
                return name
            end
        elseif variant == "garrisontalent" then
            local info = C_Garrison.GetTalentInfo(id)
            if info then
                if subvariant == "plain" then return info.name end
                return quick_texture_markup(info.icon) .. " " .. (info.researched and completeColor or incompleteColor):WrapTextInColorCode(info.name)
            end
        elseif variant == "profession" then
            local info = C_TradeSkillUI.GetProfessionInfoBySkillLineID(id)
            if (info and info.professionName and info.professionName ~= "") then
                -- there's also info.parentProfessionName for the general case ("Dragon Isles Inscription" vs "Inscription")
                return info.professionName
            end
        elseif variant == "zone" then
            local info = C_Map.GetMapInfo(id)
            if info and info.name then
                return info.name
            end
        elseif variant == "area" then
            -- See: https://wago.tools/db2/AreaTable or C_MapExplorationInfo.GetExploredAreaIDsAtPosition
            local name = C_Map.GetAreaInfo(id)
            if name then
                return name
            end
        end
        return fallback ~= "" and fallback or (variant .. ':' .. id)
    end)
end
local function cache_string(s, context)
    if not s then return end
    if type(s) == "function" then s = s(context) end
    for variant, id, fallback in s:gmatch("{(%l+):(%d+):?([^}]*)}") do
        id = tonumber(id)
        if variant == "item" then
            C_Item.RequestLoadItemDataByID(id)
        elseif variant == "spell" then
            C_Spell.RequestLoadSpellData(id)
        elseif variant == "quest" or variant == "worldquest" or variant == "questname" then
            C_QuestLog.RequestLoadQuestByID(id)
        elseif variant == "npc" then
            mob_name(id)
        end
    end
end
local function cache_loot(loot)
    if not loot then return end
    for _, item in ipairs(loot) do
        item:Cache()
    end
end
local render_string_list
do
    local out = {}
    function render_string_list(point, variant, ...)
        if not ... then return "" end
        if type(...) == "table" then return render_string_list(point, variant, unpack(...)) end
        wipe(out)
        for i=1,select("#", ...) do
            table.insert(out, ("{%s:%d}"):format(variant, (select(i, ...))))
        end
        return render_string(string.join(", ", unpack(out)), point)
    end
end
ns.render_string = render_string
ns.render_string_list = render_string_list

local npc_texture, follower_texture, currency_texture, junk_texture, notable_npc_texture, lessnotable_npc_texture
local icon_cache = {}
local trimmed_icon = function(texture)
    if not icon_cache[texture] then
        icon_cache[texture] = {
            icon = texture,
            tCoordLeft = 0.1,
            tCoordRight = 0.9,
            tCoordTop = 0.1,
            tCoordBottom = 0.9,
        }
    end
    return icon_cache[texture]
end
local atlas_texture = function(atlas, extra, left, right, top, bottom)
    atlas = C_Texture.GetAtlasInfo(atlas)
    if type(extra) == "number" then
        extra = {scale=extra}
    end
    if left and not right then
        -- this is the "trim every side by this" path
        right = 1 - left
        top = left
        bottom = 1 - left
    end
    if left then
        -- An atlas is already cropped into a texture, so we need to treat something else as our 1
        local horizontal = atlas.rightTexCoord - atlas.leftTexCoord
        local vertical = atlas.bottomTexCoord - atlas.topTexCoord
        atlas.rightTexCoord = atlas.leftTexCoord + (right * horizontal)
        atlas.leftTexCoord = atlas.leftTexCoord + (left * horizontal)
        atlas.bottomTexCoord = atlas.topTexCoord + (bottom * vertical)
        atlas.topTexCoord = atlas.topTexCoord + (top * vertical)
    end
    return ns.merge({
        icon = atlas.file,
        tCoordLeft = atlas.leftTexCoord, tCoordRight = atlas.rightTexCoord, tCoordTop = atlas.topTexCoord, tCoordBottom = atlas.bottomTexCoord,
    }, extra)
end
ns.atlas_texture = atlas_texture
local default_textures = {
    --[[
    note to self:
    atlas_texture("delves-scenario-treasure-unavailable", nil, 0, 0.9, 0.1, 1)
    atlas_texture("delves-scenario-treasure-available", nil, 0, 0.9, 0.05, 0.95)
    --]]
    VignetteLoot = atlas_texture("VignetteLoot", 1.1),
    VignetteLootElite = atlas_texture("VignetteLootElite", 1.2),
    Garr_TreasureIcon = atlas_texture("Garr_TreasureIcon", 2.2),
}
local function work_out_label(point)
    local fallback
    if point.label then
        return (render_string(point.label, point))
    end
    if point.achievement and point.criteria and point.criteria ~= true then
        if type(point.criteria) == "table" then
            local t = {}
            for _, criteriaid in ipairs(point.criteria) do
                local criteria = ns.GetCriteria(point.achievement, criteriaid)
                if criteria then
                    table.insert(t, criteria)
                end
            end
            if #t == #point.criteria then
                return string.join(', ', unpack(t))
            end
            fallback = 'achievement:'..point.achievement..'.'..string.join('+', unpack(point.criteria))
        else
            local criteria = ns.GetCriteria(point.achievement, point.criteria)
            if criteria then
                return criteria
            end
            fallback = 'achievement:'..point.achievement..'.'..point.criteria
        end
    end
    if point.follower then
        local follower = C_Garrison.GetFollowerInfo(point.follower)
        if follower then
            return follower.name
        end
        fallback = 'follower:'..point.follower
    end
    if point.npc then
        local name = mob_name(point.npc)
        if name then
            return name
        end
        fallback = 'npc:'..point.npc
    end
    if point.loot and #point.loot > 0 then
        -- handle multiples?
        local name = point.loot[1]:Name(true)
        if name then
            return name
        end
        fallback = 'item:'..point.loot[1].id
    end
    if point.achievement and not point.criteria or point.criteria == true then
        local _, achievement = GetAchievementInfo(point.achievement)
        if achievement then
            return achievement
        end
        fallback = 'achievement:'..point.achievement
    end
    if point.currency then
        if ns.currencies[point.currency] then
            return ns.currencies[point.currency].name
        end
        local info = C_CurrencyInfo.GetCurrencyInfo(point.currency)
        if info then
            return info.name
        end
    end
    return fallback or UNKNOWN
end
local function work_out_texture(point)
    if point.texture then
        return point.texture
    end
    if point.atlas then
        if not icon_cache[point.atlas] then
            icon_cache[point.atlas] = atlas_texture(point.atlas, point.scale)
        end
        return icon_cache[point.atlas]
    end
    if ns.db.icon_item or point.icon then
        if point.icon then
            return trimmed_icon(point.icon)
        end
        if point.loot and #point.loot > 0 then
            local texture = point.loot[1]:Icon()
            if texture then
                return trimmed_icon(texture)
            end
        end
        if point.currency then
            if ns.currencies[point.currency] then
                local texture = ns.currencies[point.currency].texture
                if texture then
                    return trimmed_icon(texture)
                end
            else
                local info = C_CurrencyInfo.GetCurrencyInfo(point.currency)
                if info then
                    return trimmed_icon(info.iconFileID)
                end
            end
        end
        if point.achievement then
            local texture = select(10, GetAchievementInfo(point.achievement))
            if texture then
                return trimmed_icon(texture)
            end
        end
    end
    if point.follower then
        if not follower_texture then
            follower_texture = atlas_texture("GreenCross", 1.5)
        end
        return follower_texture
    end
    if point.npc then
        if not npc_texture then
            if ns.CLASSIC then
                lessnotable_npc_texture = atlas_texture("DungeonSkull", {r=1, g=0.3, b=1, scale=1.1})
                notable_npc_texture = atlas_texture("DungeonSkull", {r=0.5, g=1, b=1, scale=1.1})
            else
                lessnotable_npc_texture = atlas_texture("nazjatar-nagaevent", 1, 0.2)
                notable_npc_texture = atlas_texture("nazjatar-nagaevent", {r=0.5, g=1, b=1}, 0.2)
            end
            npc_texture = atlas_texture("DungeonSkull", 1)
        end
        if ns.db.show_npcs_emphasizeNotable and ns.PointIsNotable(point, true) then
            if (not point.loot) or ns.hasNotableLoot(point.loot, true) then
                -- still notable without transmog
                return notable_npc_texture
            end
            return lessnotable_npc_texture
        else
            return npc_texture
        end
    end
    if point.currency then
        if not currency_texture then
            currency_texture = atlas_texture("Auctioneer", 1.3)
        end
        return currency_texture
    end
    if point.junk then
        if not junk_texture then
            junk_texture = atlas_texture("VignetteLoot", 1)
        end
        return junk_texture
    end
    if not default_textures[ns.db.default_icon] then
        default_textures[ns.db.default_icon] = atlas_texture(ns.db.default_icon, 1.5)
    end
    return default_textures[ns.db.default_icon] or default_textures["VignetteLoot"]
end
ns.work_out_texture = work_out_texture
ns.point_active = function(point)
    if point.IsActive and not point:IsActive() then
        return false
    end
    if not point.active then
        return true
    end
    return ns.conditions.check(point.active)
end
ns.point_upcoming = function(point)
    if point.level and UnitLevel("player") < point.level then
        return true
    end
    if point.hide_before and not ns.conditions.check(point.hide_before) then
        return true
    end
    if point.covenant and point.covenant ~= C_Covenants.GetActiveCovenantID() then
        return true
    end
    return false
end
local inactive_cache = {}
local function get_inactive_texture_variant(icon)
    if not inactive_cache[icon] then
        inactive_cache[icon] = CopyTable(icon)
        if inactive_cache[icon].r then
            inactive_cache[icon].a = 0.5
        else
            inactive_cache[icon].r = 0.5
            inactive_cache[icon].g = 0.5
            inactive_cache[icon].b = 0.5
            inactive_cache[icon].a = 1
        end
    end
    return inactive_cache[icon]
end
local upcoming_cache = {}
local function get_upcoming_texture_variant(icon)
    if not upcoming_cache[icon] then
        upcoming_cache[icon] = CopyTable(icon)
        upcoming_cache[icon].r = 1
        upcoming_cache[icon].g = 0
        upcoming_cache[icon].b = 0
        upcoming_cache[icon].a = 0.7
    end
    return upcoming_cache[icon]
end
local get_point_info = function(point, isMinimap)
    if point then
        local label = work_out_label(point)
        local icon = work_out_texture(point)
        if not ns.point_active(point) then
            icon = get_inactive_texture_variant(icon)
        elseif ns.point_upcoming(point) then
            icon = get_upcoming_texture_variant(icon)
        end
        local category = "treasure"
        if point.npc then
            category = "npc"
        elseif point.junk then
            category = "junk"
        end
        if not isMinimap then
            cache_string(point.label, point)
            cache_string(point.note, point)
            cache_loot(point.loot, point)
        end
        return label, icon, category, point.quest, point.faction, point.scale, point.alpha or 1
    end
end
local get_point_info_by_coord = function(uiMapID, coord)
    return get_point_info(ns.points[uiMapID] and ns.points[uiMapID][coord])
end
local get_point_progress = function(point)
    if type(point.progress) == "number" then
        -- shortcut: if the progress is an objective of the tracking quest
        return select(4, GetQuestObjectiveInfo(point.quest, point.progress, false))
    elseif type(point.progress) == "table" then
        for i, q in ipairs(point.progress) do
            if not C_QuestLog.IsQuestFlaggedCompleted(q) then
                return i - 1, #point.progress
            end
        end
        return #point.progress, #point.progress
    else
        -- function
        return point:progress()
    end
end

local function tooltip_criteria(tooltip, achievement, criteriaid, ignore_quantityString)
    local criteria, _, complete, _, _, completedBy, flags, _, quantityString = ns.GetCriteria(achievement, criteriaid) -- include hidden
    -- by this current character, or by any character if the setting says it's okay
    if completedBy and not complete then
        criteria = TEXT_MODE_A_STRING_VALUE_TYPE:format(criteria, GREEN_FONT_COLOR:WrapTextInColorCode(completedBy))
    end
    local r, g, b = (complete and GREEN_FONT_COLOR or RED_FONT_COLOR):GetRGB()
    if quantityString and not ignore_quantityString then
        local is_progressbar = bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR
        local label = (criteria and #criteria > 0 and not is_progressbar) and criteria or PVP_PROGRESS_REWARDS_HEADER
        tooltip:AddDoubleLine(
            label, quantityString,
            r, g, b, r, g, b
        )
    else
        tooltip:AddDoubleLine(" ", criteria,
            nil, nil, nil,
            r, g, b, r, g, b
        )
    end
end
local function tooltip_achievement(tooltip, achievement, criteria)
    local _, name, _, anyComplete, _, _, _, _, _, _, _, _, completedByMe, earnedBy = GetAchievementInfo(achievement)
    local complete = completedByMe or (ns.db.alts_achievements_count and anyComplete)
    if anyComplete and not complete then
        name = TEXT_MODE_A_STRING_VALUE_TYPE:format(name, GREEN_FONT_COLOR:WrapTextInColorCode(earnedBy or ALT_KEY_TEXT))
    end
    tooltip:AddDoubleLine(BATTLE_PET_SOURCE_6, name or achievement,
        nil, nil, nil,
        (complete and GREEN_FONT_COLOR or RED_FONT_COLOR):GetRGB()
    )
    if criteria then
        if criteria == true then
            local numCriteria = GetAchievementNumCriteria(achievement, true) -- include hidden
            if numCriteria > 10 then
                local numComplete = 0
                for criteria=1, numCriteria do
                    if select(3, GetAchievementCriteriaInfo(achievement, criteria, true)) then
                        numComplete = numComplete + 1
                    end
                end
                tooltip:AddDoubleLine(" ", GENERIC_FRACTION_STRING:format(numComplete, numCriteria),
                    nil, nil, nil,
                    (complete and GREEN_FONT_COLOR or RED_FONT_COLOR):GetRGB()
                )
            else
                for criteria=1, numCriteria do
                    tooltip_criteria(tooltip, achievement, criteria, true)
                end
            end
        elseif type(criteria) == "table" then
            for _, criteria in ipairs(criteria) do
                tooltip_criteria(tooltip, achievement, criteria, true)
            end
        elseif type(criteria) == "number" then
            tooltip_criteria(tooltip, achievement, criteria, true)
        end
    elseif GetAchievementNumCriteria(achievement) == 1 then
        tooltip_criteria(tooltip, achievement, 1)
    end
end
local function tooltip_loot(tooltip, item, force)
    if (ns.db.tooltip_charloot and not IsShiftKeyDown() and not item:MightDrop()) and not force then
        return true
    end
    item:AddToTooltip(tooltip)
end

ns.tooltipHelpers = {
    loot = tooltip_loot,
    achievement = tooltip_achievement,
    criteria = tooltip_criteria,
}

local function handle_tooltip(tooltip, point, skip_label)
    if not point then
        tooltip:SetText(UNKNOWN)
        tooltip:Show()
        return
    end
    -- major:
    if not skip_label and point.label ~= false then
        tooltip:AddLine(work_out_label(point))
    end
    if point.OnTooltipShow then
        point:OnTooltipShow(tooltip)
    end
    if point.follower then
        local follower = C_Garrison.GetFollowerInfo(point.follower)
        if follower then
            local quality = BAG_ITEM_QUALITY_COLORS[follower.quality]
            tooltip:AddDoubleLine(REWARD_FOLLOWER, follower.name,
                0, 1, 0,
                quality.r, quality.g, quality.b
            )
            tooltip:AddDoubleLine(follower.className, UNIT_LEVEL_TEMPLATE:format(follower.level))
        end
    end
    if point.currency then
        local name
        if ns.currencies[point.currency] then
            name = ns.currencies[point.currency].name
        else
            local info = C_CurrencyInfo.GetCurrencyInfo(point.currency)
            name = info and info.name
        end
        tooltip:AddDoubleLine(CURRENCY, name or point.currency)
    end
    if point.achievement then
        tooltip_achievement(tooltip, point.achievement, point.criteria)
    end
    if point.progress then
        local fulfilled, required = get_point_progress(point)
        if fulfilled and required then
            tooltip:AddDoubleLine(PVP_PROGRESS_REWARDS_HEADER, GENERIC_FRACTION_STRING:format(fulfilled, required))
        end
    end
    if point.note then
        tooltip:AddLine(render_string(point.note, point), 1, 1, 1, true)
    end
    if point.loot then
        local hidden
        for _, item in ipairs(point.loot) do
            hidden = tooltip_loot(tooltip, item, point.showallloot) or hidden
        end
        if hidden then
            tooltip:AddLine("Items for other characters hidden", 0, 1, 1)
        end
    end
    if point.covenant then
        local data = C_Covenants.GetCovenantData(point.covenant)
        local active = point.covenant == C_Covenants.GetActiveCovenantID()
        local cname = COVENANT_COLORS[point.covenant]:WrapTextInColorCode(data and data.name or ns.covenants[point.covenant])
        tooltip:AddLine(ITEM_REQ_SKILL:format(cname), (active and GREEN_FONT_COLOR or RED_FONT_COLOR):GetRGB())
    end
    if point.level and point.level > UnitLevel("player") then
        tooltip:AddLine(ITEM_MIN_LEVEL:format(point.level), RED_FONT_COLOR:GetRGB())
    end
    if point.hide_before then
        local isHidden = not ns.conditions.check(point.hide_before)
        if isHidden then
            tooltip:AddLine(COMMUNITY_TYPE_UNAVAILABLE, RED_FONT_COLOR:GetRGB())
        end
        local r, g, b = (isHidden and RED_FONT_COLOR or GREEN_FONT_COLOR):GetRGB()
        tooltip:AddLine(
            ns.render_string(ns.conditions.summarize(point.hide_before), point),
            r, g, b, true
        )
    end
    if point.requires then
        local isHidden = not ns.conditions.check(point.requires)
        if isHidden then
            tooltip:AddLine(COMMUNITY_TYPE_UNAVAILABLE, RED_FONT_COLOR:GetRGB())
        end
        local r, g, b = (isHidden and RED_FONT_COLOR or GREEN_FONT_COLOR):GetRGB()
        tooltip:AddLine(
            ns.render_string(ns.conditions.summarize(point.requires), point),
            r, g, b, true
        )
    end
    if point.active then
        local isActive = ns.point_active(point)
        local r, g, b = (isActive and GREEN_FONT_COLOR or RED_FONT_COLOR):GetRGB()
        tooltip:AddLine(
            ns.render_string(point.active.note or ns.conditions.summarize(point.active), point),
            r, g, b, true
        )
    end

    if point.group then
        tooltip:AddDoubleLine(GROUP, (render_string(ns.groups[point.group] or point.group, point)))
    end

    if point.quest then
        local isAvailable = not ns.allQuestsComplete(point.quest)
        local r, g, b = (isAvailable and GREEN_FONT_COLOR or RED_FONT_COLOR):GetRGB()
        tooltip:AddDoubleLine(
            " ",
            isAvailable and AVAILABLE or GOAL_COMPLETED,
            1, 1, 1, r, g, b, true
        )
        if ns.db.tooltip_questid then
            tooltip:AddDoubleLine("QuestID", render_string_list(point, "questid", point.quest), NORMAL_FONT_COLOR:GetRGB())
        end
    end

    if ns.DEBUG then
        tooltip:AddDoubleLine("Coord", point._coord)
    end

    if (ns.db.tooltip_item or IsShiftKeyDown()) and (point.loot or point.npc or point.spell) then
        local comparison = _G[myname.."ComparisonTooltip"]
        if not comparison then
            comparison = CreateFrame("GameTooltip", myname.."ComparisonTooltip", UIParent, "ShoppingTooltipTemplate")
            if _G.GameTooltipDataMixin then Mixin(comparison, GameTooltipDataMixin) end
            comparison:SetFrameStrata("TOOLTIP")
            comparison:SetClampedToScreen(true)
        end

        do
            local side
            local leftPos = tooltip:GetLeft() or 0
            local rightPos = tooltip:GetRight() or 0
            local rightDist = GetScreenWidth() - rightPos

            if (leftPos and (rightDist < leftPos)) then
                side = "left"
            else
                side = "right"
            end

            -- see if we should slide the tooltip
            if tooltip:GetAnchorType() and tooltip:GetAnchorType() ~= "ANCHOR_PRESERVE" then
                local totalWidth = 0
                if ( primaryItemShown  ) then
                    totalWidth = totalWidth + comparison:GetWidth()
                end

                if ( (side == "left") and (totalWidth > leftPos) ) then
                    tooltip:SetAnchorType(tooltip:GetAnchorType(), (totalWidth - leftPos), 0)
                elseif ( (side == "right") and (rightPos + totalWidth) >  GetScreenWidth() ) then
                    tooltip:SetAnchorType(tooltip:GetAnchorType(), -((rightPos + totalWidth) - GetScreenWidth()), 0)
                end
            end

            comparison:SetOwner(tooltip, "ANCHOR_NONE")
            comparison:ClearAllPoints()

            if ( side and side == "left" ) then
                comparison:SetPoint("TOPRIGHT", tooltip, "TOPLEFT", 0, -10)
            else
                comparison:SetPoint("TOPLEFT", tooltip, "TOPRIGHT", 0, -10)
            end
        end

        if point.loot and #point.loot > 0 then
            point.loot[1]:SetTooltip(comparison)
        elseif point.npc then
            comparison:SetHyperlink(("unit:Creature-0-0-0-0-%d"):format(point.npc))
        elseif point.spell then
            comparison:SetSpellByID(point.spell)
        end
        comparison:Show()
    end

    tooltip:Show()
end
local handle_tooltip_by_coord = function(tooltip, uiMapID, coord)
    return handle_tooltip(tooltip, ns.points[uiMapID] and ns.points[uiMapID][coord])
end

do
    local currentZone, currentPoint
    local function is_valid_related_point(basePoint, point)
        if not (basePoint and point) then return false end
        if basePoint.group and basePoint.group == point.group then return true end
        if basePoint.achievement and basePoint.achievement == point.achievement then return true end
        return false
    end
    local function iter(t, prestate)
        if not t then return nil end
        local state, point = next(t, prestate)
        while state do -- Have we reached the end of this zone?
            if is_valid_related_point(currentPoint, point) then
                return state, point
            end
            state, point = next(t, state) -- Get next data
        end
        return
    end
    function ns.IterateRelatedPointsInZone(uiMapID, point)
        currentPoint = point
        return iter, ns.points[uiMapID], nil
    end
    function ns.PointHasRelatedPointsInZone(uiMapID, point)
        for _, rpoint in ns.IterateRelatedPointsInZone(uiMapID, point) do
            if rpoint ~= point then
                return true
            end
        end
    end
end

---------------------------------------------------------
-- Plugin Handlers to HandyNotes
local HLHandler = {}

function HLHandler:OnEnter(uiMapID, coord)
    local point = ns.points[uiMapID] and ns.points[uiMapID][coord]
    if ns.RouteWorldMapDataProvider and (point.route or point.routes) then
        if point.route and ns.points[uiMapID][point.route] then
            point = ns.points[uiMapID][point.route]
        end
        ns.RouteWorldMapDataProvider:HighlightRoute(point, uiMapID, coord)
    end
    if ns.DecorationWorldMapDataProvider then
        ns.DecorationWorldMapDataProvider:OnMouseEnter(point, uiMapID, coord)
    end
    local tooltip = GameTooltip
    if ns.db.tooltip_pointanchor or self:GetParent() == Minimap then
        if self:GetCenter() > UIParent:GetCenter() then -- compare X coordinate
            tooltip:SetOwner(self, "ANCHOR_LEFT")
        else
            tooltip:SetOwner(self, "ANCHOR_RIGHT")
        end
    else
        tooltip:SetOwner(WorldMapFrame.ScrollContainer, "ANCHOR_NONE")
        local x, y = HandyNotes:getXY(coord)
        if y < 0.5 then
            tooltip:SetPoint("BOTTOMLEFT", WorldMapFrame.ScrollContainer)
        else
            tooltip:SetPoint("TOPLEFT", WorldMapFrame.ScrollContainer)
        end
    end
    handle_tooltip_by_coord(tooltip, uiMapID, coord)
end

local function showAchievement(achievement)
    if OpenAchievementFrameToAchievement then
        OpenAchievementFrameToAchievement(achievement)
    else
        -- probably classic
        if ( not AchievementFrame ) then
            AchievementFrame_LoadUI()
        end
        if ( not AchievementFrame:IsShown() ) then
            AchievementFrame_ToggleAchievementFrame()
        end
        AchievementFrame_SelectAchievement(achievement)
    end
end

local function createWaypoint(uiMapID, coord)
    local x, y = HandyNotes:getXY(coord)
    if MapPinEnhanced and MapPinEnhanced.AddPin then
        MapPinEnhanced:AddPin{
            mapID = uiMapID,
            x = x,
            y = y,
            setTracked = true,
            title = get_point_info_by_coord(uiMapID, coord),
        }
    elseif TomTom then
        TomTom:AddWaypoint(uiMapID, x, y, {
            title = get_point_info_by_coord(uiMapID, coord),
            persistent = nil,
            minimap = true,
            world = true
        })
    elseif C_Map and C_Map.CanSetUserWaypointOnMap and C_Map.CanSetUserWaypointOnMap(uiMapID) then
        local uiMapPoint = UiMapPoint.CreateFromCoordinates(uiMapID, x, y)
        C_Map.SetUserWaypoint(uiMapPoint)
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
    end
end
local createWaypointForAll
do
    local function getDistance(x1, y1, x2, y2)
        local deltaX, deltaY = x2 - x1, y2 - y1
        return ((deltaX ^ 2) + (deltaY ^ 2)) ^ 0.5
    end
    local function distanceSort(lhs, rhs)
        local px, py = HBD:GetPlayerZonePosition()
        return getDistance(px, py, HandyNotes:getXY(lhs)) > getDistance(px, py, HandyNotes:getXY(rhs))
    end
    function createWaypointForAll(button, uiMapID, coord)
        if not TomTom then return end
        local point = ns.points[uiMapID] and ns.points[uiMapID][coord]
        if not point then return end
        local points = {}
        for rcoord, rpoint in ns.IterateRelatedPointsInZone(uiMapID, point) do
            if ns.should_show_point(rcoord, rpoint, uiMapID, false) then
                table.insert(points, rcoord)
            end
        end
        -- Add waypoints in a useful order so we wind up with the closest one
        -- on the arrow. Not just doing TomTom:SetClosestWaypoint because I
        -- want to respect the crazy-arrow settings, and that forces it on.
        table.sort(points, distanceSort)
        for _, rcoord in ipairs(points) do
            local x, y = HandyNotes:getXY(rcoord)
            TomTom:AddWaypoint(uiMapID, x, y, {
                title = get_point_info_by_coord(uiMapID, rcoord),
                persistent = nil,
                minimap = true,
                world = true
            })
        end
    end
end

local function hideNode(uiMapID, coord)
    ns.hidden[uiMapID][coord] = true
    HL:Refresh()
end
local function hideAchievement(achievement)
    ns.db.achievementsHidden[achievement] = true
    HL:Refresh()
end
local function hideGroup(uiMapID, coord)
    local point = ns.points[uiMapID] and ns.points[uiMapID][coord]
    if not (point and point.group) then return end
    ns.db.groupsHidden[point.group] = true
    HL:Refresh()
end
local function hideGroupZone(uiMapID, coord)
    local point = ns.points[uiMapID] and ns.points[uiMapID][coord]
    if not (point and point.group) then return end
    ns.db.groupsHiddenByZone[uiMapID][point.group] = true
    HL:Refresh()
end

local function sendToChat(uiMapID, coord)
    local title = get_point_info_by_coord(uiMapID, coord)
    local x, y = HandyNotes:getXY(coord)
    local message = ("%s|cffffff00|Hworldmap:%d:%d:%d|h[%s]|h|r"):format(
        title and (title .. " ") or "",
        uiMapID,
        x * 10000,
        y * 10000,
        -- Can't do this:
        -- core:GetMobLabel(self.data.id) or UNKNOWN
        -- WoW seems to filter out anything which isn't the standard MAP_PIN_HYPERLINK
        MAP_PIN_HYPERLINK
    )
    PlaySound(SOUNDKIT.UI_MAP_WAYPOINT_CHAT_SHARE)
    -- if you have an open editbox, just paste to it
    if not ChatEdit_InsertLink(message) then
        -- open the chat to whatever it was on and add the text
        ChatFrame_OpenChat(message)
    end
end

do
    local generateMenu = function(owner, rootDescription, uiMapID, coord, point)
        rootDescription:SetTag("MENU_WORLD_MAP_CONTEXT_"..myname)
        rootDescription:CreateTitle(myfullname)
        if point.achievement then
            rootDescription:CreateButton(OBJECTIVES_VIEW_ACHIEVEMENT, showAchievement, point.achievement)
        end
        if TomTom or (C_Map and C_Map.CanSetUserWaypointOnMap and C_Map.CanSetUserWaypointOnMap(uiMapID)) then
            rootDescription:CreateButton("Create waypoint", function() createWaypoint(uiMapID, coord) end)
        end
        -- Specifically for TomTom, since it supports multiples:
        if TomTom and ns.PointHasRelatedPointsInZone(uiMapID, point) then
            rootDescription:CreateButton(
                render_string(("Create waypoint for all %s"):format(point.group and (ns.groups[point.group] or point.group) or ("{achievement:%d}"):format(point.achievement)), point),
                function() createWaypointForAll(uiMapID, coord) end
            )
        end
        if _G.MAP_PIN_HYPERLINK then
            -- Link to chat
            rootDescription:CreateButton(COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT, function() sendToChat(uiMapID, coord) end)
        end
        -- Hide menu item
        rootDescription:CreateButton("Hide this point", function() hideNode(uiMapID, coord) end)
        if point.achievement then
            rootDescription:CreateButton(render_string("Hide {achievement:" .. point.achievement .. "}", point), hideAchievement, point.achievement)
        end
        if point.group then
            if not ns.hiddenConfig.groupsHiddenByZone then
                rootDescription:CreateButton(
                    render_string(("Hide %s only in {zone:%s}"):format(ns.groups[point.group] or point.group, uiMapID), point),
                    function() hideGroupZone(uiMapID, coord) end
                )
            end
            if not ns.hiddenConfig.groupsHidden then
                rootDescription:CreateButton(
                    render_string(("Hide %s in all zones"):format(ns.groups[point.group] or point.group), point),
                    function() hideGroup(uiMapID, coord) end
                )
            end
        end
        -- Close menu item
        rootDescription:CreateButton(CLOSE, function() return MenuResponse.CloseAll end)
    end

    function HLHandler:OnClick(button, down, uiMapID, coord)
        if down then return end
        -- given we're in a click handler, this really *should* exist, but just in case...
        local point = ns.points[uiMapID] and ns.points[uiMapID][coord]
        if point then
            if button == "RightButton" then
                MenuUtil.CreateContextMenu(nil, generateMenu, uiMapID, coord, point)
                return
            end
            if button == "LeftButton" and IsShiftKeyDown() and _G.MAP_PIN_HYPERLINK then
                sendToChat(button, uiMapID, coord)
                return
            end
            if point.OnClick then
                point:OnClick(button, uiMapID, coord)
            end
            if ns.RouteWorldMapDataProvider then
                ns.RouteWorldMapDataProvider:OnMouseClick(point, uiMapID, coord)
            end
            if ns.DecorationWorldMapDataProvider then
                ns.DecorationWorldMapDataProvider:OnMouseClick(point, uiMapID, coord)
            end
        end
    end
end

function HLHandler:OnLeave(uiMapID, coord)
    GameTooltip:Hide()
    if _G[myname.."ComparisonTooltip"] then _G[myname.."ComparisonTooltip"]:Hide() end

    local point = ns.points[uiMapID] and ns.points[uiMapID][coord]
    if ns.RouteWorldMapDataProvider and (point.route or point.routes) then
        if point.route and ns.points[uiMapID][point.route] then
            point = ns.points[uiMapID][point.route]
        end
        ns.RouteWorldMapDataProvider:UnhighlightRoute(point, uiMapID, coord)
    end
    if ns.DecorationWorldMapDataProvider then
        ns.DecorationWorldMapDataProvider:OnMouseLeave(point, uiMapID, coord)
    end
end

do
    -- This is a custom iterator we use to iterate over every node in a given zone
    local currentZone, isMinimap
    local function iter(t, prestate)
        if not t then return nil end
        local state, value = next(t, prestate)
        while state do -- Have we reached the end of this zone?
            if value and ns.should_show_point(state, value, currentZone, isMinimap) then
                local label, icon, _, _, _, scale, alpha = get_point_info(value, isMinimap)
                scale = (scale or 1) * (icon and icon.scale or 1) * ns.db.icon_scale
                return state, nil, icon, scale, ns.db.icon_alpha * alpha
            end
            state, value = next(t, state) -- Get next data
        end
        return nil, nil, nil, nil
    end
    function HLHandler:GetNodes2(uiMapID, minimap)
        -- Debug("GetNodes2", uiMapID, minimap)
        for _, cache in pairs(ns.run_caches) do
            table.wipe(cache)
        end
        HL:RefreshProviders()
        currentZone = uiMapID
        isMinimap = minimap
        return iter, ns.points[uiMapID], nil
    end
end

---------------------------------------------------------
-- Addon initialization, enabling and disabling

function HL:OnInitialize()
    -- Set up our database
    if ns.defaultsOverride then
        ns.merge(ns.defaults.profile, ns.defaultsOverride)
    end
    self.db = LibStub("AceDB-3.0"):New(myname.."DB", ns.defaults)
    ns.db = self.db.profile
    ns.hidden = self.db.char.hidden
    -- Quick upgrade-cycle:
    if ns.db.show_npcs_onlynotable then
        ns.db.show_npcs_filter = "notable"
        ns.db.show_npcs_onlynotable = nil
    end

    -- Initialize our database with HandyNotes
    HandyNotes:RegisterPluginDB(myname:gsub("HandyNotes_", ""), HLHandler, ns.options)

    -- Watch for events... but mitigate spammy events by bucketing in Refresh
    self:RegisterEvent("LOOT_CLOSED", "RefreshOnEvent")
    self:RegisterEvent("ZONE_CHANGED_INDOORS", "RefreshOnEvent")
    self:RegisterEvent("CRITERIA_EARNED", "RefreshOnEvent")
    self:RegisterEvent("BAG_UPDATE", "RefreshOnEvent")
    self:RegisterEvent("QUEST_TURNED_IN", "RefreshOnEvent")
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        self:RegisterEvent("SHOW_LOOT_TOAST", "RefreshOnEvent")
        self:RegisterEvent("GARRISON_FOLLOWER_ADDED", "RefreshOnEvent")
        self:RegisterEvent("UNIT_ENTERING_VEHICLE", "RefreshOnUnitEvent", "player")
        self:RegisterEvent("UNIT_EXITED_VEHICLE", "RefreshOnUnitEvent", "player")
    end
    -- This is sometimes spammy, but is the only thing that tends to get us casts:
    self:RegisterEvent("CRITERIA_UPDATE", "RefreshOnEvent")

    if ns.SetupMapOverlay then
        ns.SetupMapOverlay()
    end

    if ns.RouteWorldMapDataProvider then
        WorldMapFrame:AddDataProvider(ns.RouteWorldMapDataProvider)
    end
    if ns.DecorationWorldMapDataProvider then
        WorldMapFrame:AddDataProvider(ns.DecorationWorldMapDataProvider)
    end

    self:FillCaches()
end

do
    local bucket = CreateFrame("Frame")
    bucket.elapsed = 0
    bucket:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed > 1.5 then
            self.elapsed = 0
            self:Hide()
            HL:Refresh()
        end
    end)
    function HL:Refresh()
        HL:SendMessage("HandyNotes_NotifyUpdate", myname:gsub("HandyNotes_", ""))
    end
    function HL:RefreshOnEvent(event)
        bucket:Show()
    end
    function HL:RefreshOnUnitEvent(requiredUnit, event, unit)
        if unit == requiredUnit then
            bucket:Show()
        end
    end
    function HL:RefreshProviders()
        if ns.RouteWorldMapDataProvider then
            ns.RouteWorldMapDataProvider:RefreshAllData()
        end
        if ns.RouteMiniMapDataProvider then
            ns.RouteMiniMapDataProvider:UpdateMinimapRoutes()
        end
        if ns.DecorationWorldMapDataProvider then
            ns.DecorationWorldMapDataProvider:RefreshAllData()
        end
    end
end

function HL:FillCaches()
    local CacheWalker = coroutine.wrap(function()
        local count = 0
        for uiMapID, coords in pairs(ns.points) do
            for coord, point in pairs(coords) do
                if point.loot then
                    for _, item in pairs(point.loot) do
                        item:Cache()
                    end
                    count = count + 1
                end
                if count % 10 == 0 then
                    coroutine.yield(count, false)
                end
            end
        end
        coroutine.yield(count, true)
    end)
    if ns.DEBUG then print(("%s: starting caching"):format(myname)) end
    local ticker
    ticker = C_Timer.NewTicker(0.1, function()
        local count, finished = CacheWalker()
        if finished then
            ticker:Cancel()
            if ns.DEBUG then print(("%s: done caching %d points"):format(myname, count)) end
        end
    end)
end

hooksecurefunc(AreaPOIPinMixin, "TryShowTooltip", function(self)
    -- if not self.db.profile.show_on_world then return end
    if not self.areaPoiID then return end
    if not ns.POIsToPoints[self.areaPoiID] then return end
    local point = ns.POIsToPoints[self.areaPoiID]
    -- if not ns.should_show_point(point._coord, point, point._uiMapID, false) then return end
    handle_tooltip(GameTooltip, point, true)
end)
hooksecurefunc(AreaPOIPinMixin, "OnMouseLeave", function(self)
    if _G[myname.."ComparisonTooltip"] then _G[myname.."ComparisonTooltip"]:Hide() end
end)

hooksecurefunc(VignettePinMixin, "OnMouseEnter", function(self)
    local vignetteInfo = self.vignetteInfo
    if not (vignetteInfo.vignetteID and ns.VignetteIDsToPoints[vignetteInfo.vignetteID]) then return end
    local point = ns.VignetteIDsToPoints[vignetteInfo.vignetteID]
    -- if not ns.should_show_point(point._coord, point, point._uiMapID, false) then return end
    handle_tooltip(GameTooltip, point, true)
end)
hooksecurefunc(VignettePinMixin, "OnMouseLeave", function(self)
    if _G[myname.."ComparisonTooltip"] then _G[myname.."ComparisonTooltip"]:Hide() end
end)

if _G.TaskPOI_OnEnter then
    hooksecurefunc("TaskPOI_OnEnter", function(self)
        if not self.questID then return end
        if not ns.WorldQuestsToPoints[self.questID] then return end
        local point = ns.WorldQuestsToPoints[self.questID]
        -- if not ns.should_show_point(point._coord, point, point._uiMapID, false) then return end
        handle_tooltip(GameTooltip, point, false)
    end)
    hooksecurefunc("TaskPOI_OnLeave", function(self)
        -- 10.0.2 doesn't hide this by default any more
        if _G[myname.."ComparisonTooltip"] then _G[myname.."ComparisonTooltip"]:Hide() end
    end)
end
