
local addonName, private = ...
local addon = private.addon
---@type detailsframework
local detailsFramework = DetailsFramework

private.Details = Details

--["5"] = "2026-03-27 15:00:23| Error on CreateRunInfo():  Interface/AddOns/Details_MythicPlus/rundata.lua:102: attempt to index local 'damageContainer' (a nil value) ",

---@class keystone_info : table
---@field keystoneLevel number
---@field keystoneMapId number
---@field keystoneIcon number

local keystoneDefaultTexture = 4352494 --when no keystone is found, this texture is shown

---@param playerName string
---@return keystone_info
function private.GetKeystoneInfo(playerName)
    local returnTable = {
        keystoneLevel = 0,
        keystoneMapId = 0,
        keystoneIcon = keystoneDefaultTexture,
    }

    local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
    local playerKeystoneInfo = openRaidLib and openRaidLib.GetKeystoneInfo(playerName)

    if (playerKeystoneInfo) then
        returnTable.keystoneLevel = playerKeystoneInfo.level
        returnTable.keystoneMapId = playerKeystoneInfo.challengeMapID
        ---@type details_instanceinfo
        local instanceInfo = private.Details:GetInstanceInfo(playerKeystoneInfo.mapID)
        if (instanceInfo) then
            returnTable.keystoneIcon = instanceInfo.iconLore
        end
    end

    local playerInfo = GetPlayerInfo(playerName)
    if playerInfo then
        local keystoneInfo = playerInfo.keystoneInfo
        if keystoneInfo then
            returnTable.keystoneLevel = keystoneInfo.level
            returnTable.keystoneMapId = keystoneInfo.mythicPlusMapID
            ---@type details_instanceinfo
            local instanceInfo = private.Details:GetInstanceInfo(keystoneInfo.mapID)
            if (instanceInfo) then
                returnTable.keystoneIcon = instanceInfo.iconLore
            end

            --keystoneInfo.level
            --keystoneInfo.mapID
            --keystoneInfo.challengeMapID
            --keystoneInfo.classID
            --keystoneInfo.rating
            --keystoneInfo.mythicPlusMapID
            --keystoneInfo.specID
        end
    end

    return returnTable
end

---@type table<string, number>
private.KeystoneLevels = {}
---@type table<string, number>
private.PlayerRatings = {}

private.SaveGroupMembersKeystoneAndRatingLevel = function()
    wipe(private.KeystoneLevels)
    wipe(private.PlayerRatings)

    for i = 1, GetNumGroupMembers()-1 do
        local unitId = "party" .. i
        if (UnitExists(unitId)) then
            local unitName = private.Details:GetFullName(unitId)
            local unitKeystoneInfo = private.GetKeystoneInfo(unitName)
            if (unitKeystoneInfo) then
                private.KeystoneLevels[unitName] = unitKeystoneInfo.level
            end

			local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unitName)
			if (summary) then
				private.PlayerRatings[unitName] = summary.currentSeasonScore
			end
        end
    end

    local unitId = "player"
    if (UnitExists(unitId)) then
        local unitName = private.Details:GetFullName(unitId)
        local unitKeystoneInfo = private.GetKeystoneInfo(unitName)
        if (unitKeystoneInfo) then
            private.KeystoneLevels[unitName] = unitKeystoneInfo.level
        end

		local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unitName)
		if (summary) then
			private.PlayerRatings[unitName] = summary.currentSeasonScore
		end
    end
end


local abbreviateOptionsDamage =
{
    {
        breakpoint = 1000000000,
        abbreviation = "THIRD_NUMBER_CAP_NO_SPACE",
        significandDivisor = 10000000,
        fractionDivisor = 100,
        --abbreviationIsGlobal = false
    },
    {
        breakpoint = 1000000,
        --abbreviation = "SECOND_NUMBER_CAP_NO_SPACE",
        abbreviation = "M",
        significandDivisor = 10000,
        fractionDivisor = 100,
        abbreviationIsGlobal = false
    },
    {
        breakpoint = 10000,
        --abbreviation = "FIRST_NUMBER_CAP_NO_SPACE",
        abbreviation = "K",
        significandDivisor = 1000,
        fractionDivisor = 1,
        abbreviationIsGlobal = false,
    },
    {
        breakpoint = 1000,
        --abbreviation = "FIRST_NUMBER_CAP_NO_SPACE",
        abbreviation = "K",
        significandDivisor = 100,
        fractionDivisor = 10,
        abbreviationIsGlobal = false,
    },
    {
        breakpoint = 1,
        abbreviation = "",
        significandDivisor = 1,
        fractionDivisor = 1,
        abbreviationIsGlobal = false
    },
}

local abbreviateOptionsDPS =
{
    {
        breakpoint = 1000000000,
        abbreviation = "THIRD_NUMBER_CAP_NO_SPACE",
        significandDivisor = 10000000,
        fractionDivisor = 100,
        abbreviationIsGlobal = false
    },
    {
        breakpoint = 1000000,
        --abbreviation = "SECOND_NUMBER_CAP_NO_SPACE",
        abbreviation = "M",
        significandDivisor = 10000,
        fractionDivisor = 100,
        abbreviationIsGlobal = false
    },
    {
        breakpoint = 1000,
        --abbreviation = "FIRST_NUMBER_CAP_NO_SPACE",
        abbreviation = "K",
        significandDivisor = 100,
        fractionDivisor = 10,
        abbreviationIsGlobal = false,
    },
    {
        breakpoint = 1,
        abbreviation = "",
        significandDivisor = 1,
        fractionDivisor = 1,
        abbreviationIsGlobal = false
    },
}

local abbreviateSettingsDamage
local abbreviateSettingsDPS

if CreateAbbreviateConfig then
    abbreviateSettingsDamage = CreateAbbreviateConfig(abbreviateOptionsDamage)
    abbreviateSettingsDamage = {config = abbreviateSettingsDamage}
    private.abbreviateOptionsDamage = abbreviateSettingsDamage

    abbreviateSettingsDPS = CreateAbbreviateConfig(abbreviateOptionsDPS)
    abbreviateSettingsDPS = {config = abbreviateSettingsDPS}
    private.abbreviateOptionsDPS = abbreviateSettingsDPS
end

if private.Details then
    return
end

private.Details = {
    CreatePlayerPortrait = function(Details, parent, name)
        if (not C_AddOns.IsAddOnLoaded("Blizzard_ChallengesUI")) then
            C_AddOns.LoadAddOn("Blizzard_ChallengesUI")
        end

        if C_AddOns.IsAddOnLoaded("Blizzard_ChallengesUI") then
            --this template is from Blizzard_ChallengesUI.xml
            local template = "ChallengeModeBannerPartyMemberTemplate"
            local playerBanner = CreateFrame("frame", name, parent, template)
            playerBanner:SetAlpha(1)
            playerBanner:EnableMouse(true)
            playerBanner:SetFrameLevel(parent:GetFrameLevel()+2)

            return playerBanner
        end
    end,

    GetSpellInfo = function(spellId) --there is no self
        local spellInfo = C_Spell.GetSpellInfo(spellId)
        if (spellInfo) then
            return spellInfo.name, nil, spellInfo.iconID
        end
    end,

    AddTooltipBackgroundStatusbar = function(Details, side, value, useSpark, statusBarColor)
		Details.tooltip.background [4] = 0.8
		Details.tooltip.icon_size.W = Details.tooltip.line_height
		Details.tooltip.icon_size.H = Details.tooltip.line_height

		useSpark = value ~= 100
		GameCooltip:SetOption("SparkTexture", [[Interface\Buttons\WHITE8X8]])
		GameCooltip:SetOption("SparkWidth", 1)
		GameCooltip:SetOption("SparkHeight", 20)
		GameCooltip:SetOption("SparkColor", Details.tooltip.divisor_color)
		GameCooltip:SetOption("SparkAlpha", 0.15)
		GameCooltip:SetOption("SparkPositionXOffset", 5)

		value = value or 100

		if (not side) then
			local r, g, b, a = unpack(Details.tooltip.bar_color)
			if (statusBarColor) then
				r, g, b, a = detailsFramework:ParseColors(statusBarColor)
			end
			local rBG, gBG, bBG, aBG = unpack(Details.tooltip.background)
			GameCooltip:AddStatusBar(value, 1, r, g, b, a, useSpark, {value = 100, color = {rBG, gBG, bBG, aBG}, texture = [[Interface\AddOns\Details_MythicPlus\Assets\Textures\bar_serenity]]})
		else
			GameCooltip:AddStatusBar(value, 2, unpack(Details.tooltip.bar_color))
		end
    end,

    tooltip = {
        fontface = "Friz Quadrata TT",
        fontsize = 10,
        fontsize_title = 10,
        fontcolor = {1, 1, 1, 1},
        fontcolor_right = {1, 0.7, 0, 1}, --{1, 0.9254, 0.6078, 1}
        fontshadow = true,
        fontcontour = {0, 0, 0, 1},
        bar_color = {0.3960, 0.3960, 0.3960, 0.8700},
        background = {0.0941, 0.0941, 0.0941, 0.8},
        divisor_color = {1, 1, 1, 1},
        abbreviation = 2, -- 2 = ToK I Upper 5 = ToK I Lower -- was 8
        maximize_method = 1,
        show_amount = false,
        commands = {},
        header_text_color = {1, 0.9176, 0, 1}, --{1, 0.7, 0, 1}
        header_statusbar = {0.3, 0.3, 0.3, 0.8, false, false, "WorldState Score"},
        submenu_wallpaper = true,

        rounded_corner = true,

        anchored_to = 1,
        anchor_screen_pos = {507.700, -350.500},
        anchor_point = "bottom",
        anchor_relative = "top",
        anchor_offset = {0, 0},

        border_texture = "Details BarBorder 3",
        border_color = {0, 0, 0, 1},
        border_size = 14,

        tooltip_max_abilities = 6,
        tooltip_max_targets = 2,
        tooltip_max_pets = 2,

        grow_direction = "down",

        --menus_bg_coords = {331/512, 63/512, 109/512, 143/512}, --with gradient on right side
        menus_bg_coords = {0.309777336120606, 0.924000015258789, 0.213000011444092, 0.279000015258789},
        menus_bg_color = {.8, .8, .8, 0.2},
        menus_bg_texture = [[Interface\SPELLBOOK\Spellbook-Page-1]],

        icon_border_texcoord = {L = 5/64, R = 59/64, T = 5/64, B = 59/64},
        icon_size = {W = 13, H = 13},

        --height used on tooltips at displays such as damage taken by spell
        line_height = 17,

        show_border_shadow = true, --from spell tooltips from the main window

        --apocalypse
        show_header = true,
        show_percent_column = true,
        show_dps_column = true,
        show_help = true,
        show_help_count = 0, --when reaches MAX_TOOLTIP_HELP, set show_help to false
        apocalypse_width = 300,
        apocalypse_width_useline = false,
    },

    death_tooltip_texture = "Details Serenity",

    Format = function(Details, totalDamage)
        return AbbreviateNumbers(totalDamage, Details.abbreviateOptionsDamage)
    end,

    GetSpecFromSerial = function(Details, guid)
        return nil
    end,

    GetItemLevelFromGuid = function(Details, guid)
        return 0
    end,

    playerRatings = {}, --[unitName] = rating

    UnpackDeathTable = function(Details, thisDeathTable)
        return nil, nil, nil, nil, nil, nil, nil, nil, nil
    end,

    UnpackDeathEvent = function(Details, thisEvent)
        return nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
    end,

    GetCoreVersion = function(Details)
        return 167
    end,

    GetCombatByUID = function(Details, combatUID)
        return nil
    end,

    OpenSpecificBreakdownWindow = function(Details, combat, playerName, mainAttribute, subAttribute)
        return nil
    end,

    class_coords = CLASS_ICON_TCOORDS,

    GetClassIcon = function(Details, class)
        if (not class) then
			class = "UNKNOW"
		end

		if (class == "UNKNOW") then
			return [[Interface\LFGFRAME\LFGROLE_BW]], 0.25, 0.5, 0, 1

		elseif (class == "UNGROUPPLAYER") then
			return [[Interface\ICONS\Achievement_Character_Orc_Male]], 0, 1, 0, 1

		elseif (class == "PET") then
			return [[Interface\AddOns\Details_MythicPlus\Assets\Textures\classes_small]], 0.25, 0.49609375, 0.75, 1

		else
			local classTCoords = private.Details.class_coords[class]
            return [[Interface\AddOns\Details_MythicPlus\Assets\Textures\classes_small]], unpack(classTCoords)
		end
        return nil, nil, nil, nil, nil
    end,

    GetFullName = function(Details, id) -- copied over from Details, which does Details.GetFullName = Details.GetCLName
        local name, realm = UnitName(id)
        if (name) then
            if issecretvalue and issecretvalue(realm) then
                --return GetUnitName(id, true)
            end
            if (realm and realm ~= "") then
                name = name .. "-" .. realm
            end
            return name
        end
    end,

	-----@param unitId any
	-----@param ambiguateString any
	--GetFullName = function(Details, unitId, ambiguateString) --not in use, get replace by Details.GetCLName a few lines below
	--	--UnitFullName is guarantee to return the realm name of the unit queried
	--	local playerName, realmName = UnitFullName(unitId)
	--	if (playerName) then
	--		if (not realmName) then
	--			realmName = GetRealmName()
	--		end
	--		realmName = realmName:gsub("[%s-]", "")
	--
	--		playerName = playerName .. "-" .. realmName
	--
	--		if (ambiguateString) then
	--			playerName = Ambiguate(playerName, ambiguateString)
	--		end
	--
	--		return playerName
	--	end
	--end,

    GetInstanceInfo = function(Details, mapID)
        --to be implemented, require ejid cache
    end,


}
