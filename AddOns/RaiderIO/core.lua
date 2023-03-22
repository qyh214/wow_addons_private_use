if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then return end

local addonName = ... ---@type string @The name of the addon.
local ns = select(2, ...) ---@type ns @The addon namespace.
local L = ns.L

local arshift = bit.arshift
local band = bit.band
local bnot = bit.bnot
local bor = bit.bor
local bxor = bit.bxor
local lshift = bit.lshift
local mod = bit.mod
local rshift = bit.rshift

local ScrollBoxUtil do

    ScrollBoxUtil = {}

    ---@class CallbackRegistryMixin
    ---@field public RegisterCallback fun(event: string|any, callback: fun())

    ---@class ScrollBoxBaseMixin : CallbackRegistryMixin
    ---@field public GetFrames fun(): Frame[]
    ---@field public Update fun()

    ---@param scrollBox ScrollBoxBaseMixin
    ---@param callback fun(frames: Button[], scrollBox: ScrollBoxBaseMixin)
    function ScrollBoxUtil:OnViewFramesChanged(scrollBox, callback)
        if not scrollBox then
            return
        end
        if scrollBox.buttons then -- TODO: legacy 9.X support
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

    ---@param scrollBox ScrollBoxBaseMixin
    ---@param callback fun(self: ScrollBoxBaseMixin)
    function ScrollBoxUtil:OnViewScrollChanged(scrollBox, callback)
        if not scrollBox then
            return
        end
        local function wrappedCallback()
            callback(scrollBox)
        end
        if scrollBox.update then -- TODO: legacy 9.X support
            hooksecurefunc(scrollBox, "update", wrappedCallback)
            return 1
        end
        if scrollBox.RegisterCallback then
            scrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnScroll, wrappedCallback)
            return true
        end
        return false
    end

end

local HookUtil do

    HookUtil = {}

    local hooked = {}

    ---@param frame Frame
    ---@param callback fun(self: Frame, ...)
    ---@param ... string
    function HookUtil:On(frame, callback, ...)
        local hook = hooked[frame]
        if not hook then
            hook = {}
            hooked[frame] = hook
        end
        for _, key in ipairs({...}) do
            local keyHook = hook[key]
            if not keyHook then
                keyHook = {}
                hook[key] = keyHook
            end
            if not keyHook[callback] then
                keyHook[callback] = true
                frame:HookScript(key, callback)
            end
        end
    end

    ---@param frames Frame[]
    ---@param callback fun(self: Frame, ...)
    ---@param ... string
    function HookUtil:OnAll(frames, callback, ...)
        for _, frame in ipairs(frames) do
            HookUtil:On(frame, callback, ...)
        end
    end

    ---@param object Frame[]|Frame
    ---@param map table<string, fun()>
    function HookUtil:MapOn(object, map)
        if type(object) ~= "table" then
            return
        end
        if type(object.GetObjectType) == "function" then
            for key, callback in pairs(map) do
                HookUtil:On(object, callback, key)
            end
            return 1
        end
        for key, callback in pairs(map) do
            HookUtil:OnAll(object, callback, key)
        end
        return true
    end

end

-- constants.lua (ns)
-- dependencies: none
do

    ---@class ns
    ---@field public Print function @Prints yellow text to the default chat frame. Behaves otherwise same way as AddMessage does
    ---@field public EXPANSION number @The currently accessible expansion to the playerbase
    ---@field public MAX_LEVEL number @The currently accessible expansion max level to the playerbase
    ---@field public REGION_TO_LTD string[] @Region ID to LTD conversion table
    ---@field public FACTION_TO_ID number[] @Faction group string to ID conversion table
    ---@field public PLAYER_REGION string @`us`, `kr`, `eu`, `tw`, `cn`
    ---@field public PLAYER_REGION_ID number @`1` (us), `2` (kr), `3` (eu), `4` (tw), `5` (cn)
    ---@field public PLAYER_FACTION number @`1` (alliance), `2` (horde), `3` (neutral)
    ---@field public PLAYER_FACTION_TEXT string @`Alliance`, `Horde`, `Neutral`
    ---@field public PLAYER_NAME string @The name of the player character
    ---@field public PLAYER_REALM string @The realm of the player character
    ---@field public PLAYER_REALM_SLUG string @The realm slug of the player character
    ---@field public OUTDATED_CUTOFF number @Seconds before we start looking at the data as out-of-date
    ---@field public OUTDATED_BLOCK_CUTOFF number @Seconds before we block future score showing
    ---@field public PROVIDER_DATA_TYPE number[] @Data Type enum
    ---@field public LOOKUP_MAX_SIZE number @The maximum index we can use in a table before we start to get errors
    ---@field public CURRENT_SEASON number @The current mythic keystone season
    ---@field public HEADLINE_MODE table<string, number> @Enum over headline modes
    ---@field public ROLE_ICONS RoleIcons @Collection of roles and their icons
    ---@field public KEYSTONE_LEVEL_PATTERN table<number, string> @Table over patterns matching keystone levels in strings
    ---@field public KEYSTONE_LEVEL_TO_SCORE table<number, number> @Table over keystone levels and the base score for that level
    ---@field public RAID_DIFFICULTY table<number, RaidDifficulty> @Table of 1=normal, 2=heroic, 3=mythic difficulties and their names and colors
    ---@field public PREVIOUS_SEASON_SCORE_RELEVANCE_THRESHOLD number @Threshold that current season must surpass from previous season to be considered better and shown as primary in addon
    ---@field public PREVIOUS_SEASON_MAIN_SCORE_RELEVANCE_THRESHOLD number @Threshold that current season current character must surpass from previous season main to be considered better and shown as primary in addon
    ---@field public CUSTOM_ICONS table<string, table<string, CustomIcon>> @Map over custom icons separated by file. Each icon supports a custom metatable for request handling
    ---@field public REGIONS_RESET_TIME table<string, number> @Maps each region string to their weekly reset timer
    ---@field public KEYSTONE_AFFIX_SCHEDULE number[] @Maps each weekly rotation, primarily for Tyrannical (`9`) and Fortified (`10`) tracking
    ---@field public KEYSTONE_AFFIX_INTERNAL table<number, string> @Maps each affix ID to a internal string version like `tyrannical` (`9`) and `fortified` (`10`)
    ---@field public KEYSTONE_AFFIX_TEXTURE table<number, string> @Maps each affix to a texture string Tyrannical (`9`/`-9`) and Fortified (`10`/`-10`)
    ---@field public RECRUITMENT_ENTITY_TYPES table<string, number> @Table over recruitment entity types.
    ---@field public RECRUITMENT_ENTITY_TYPE_URL_SUFFIX table<number, string> @Table over recruitment entity type profile url suffixes.
    ---@field public RECRUITMENT_ACTIVITY_TYPES table<string, number> @Table over recruitment activity types.
    ---@field public RECRUITMENT_ACTIVITY_TYPE_ICONS table<number, string|number> @Table over recruitment activity type icons.
    ---@field public RECRUITMENT_ROLE_ICONS table<string, string> @Table over recruitment role icons.

    ns.Print = function(text, r, g, b, ...)
        r, g, b = r or 1, g or 1, b or 0
        DEFAULT_CHAT_FRAME:AddMessage(tostring(text), r, g, b, ...)
    end
    ns.EXPANSION = max(GetServerExpansionLevel(), GetMinimumExpansionLevel(), GetExpansionLevel()) - 1
    ns.MAX_LEVEL = GetMaxLevelForExpansionLevel(ns.EXPANSION)
    ns.REGION_TO_LTD = {"us", "kr", "eu", "tw", "cn"}
    ns.FACTION_TO_ID = {Alliance = 1, Horde = 2, Neutral = 3}
    ns.PLAYER_REGION = nil
    ns.PLAYER_REGION_ID = nil
    ns.PLAYER_FACTION = nil
    ns.PLAYER_FACTION_TEXT = nil
    ns.OUTDATED_CUTOFF = 86400 * 3 -- number of seconds before we start warning about stale data (warning the user should update their addon)
    ns.OUTDATED_BLOCK_CUTOFF = 86400 * 7 -- number of seconds before we hide the data (block showing score as its most likely inaccurate)
    ns.PROVIDER_DATA_TYPE = {MythicKeystone = 1, Raid = 2, Recruitment = 3, PvP = 4}
    ns.LOOKUP_MAX_SIZE = floor(2^18-1)
    ns.CURRENT_SEASON = 1
    ns.RAIDERIO_ADDON_DOWNLOAD_URL = "https://rio.gg/addon"

    ns.HEADLINE_MODE = {
        CURRENT_SEASON = 0,
        BEST_SEASON = 1,
        BEST_RUN = 2
    }

    -- threshold for comparing current character's previous season score to current score
    -- meaning: once current score exceeds this fraction of previous season, then show current season
    local PREVIOUS_SEASON_NUM_DUNGEONS = 10
    local DUNGEONS = ns.DUNGEONS or ns.dungeons -- DEPRECATED: ns.dungeons
    ns.PREVIOUS_SEASON_SCORE_RELEVANCE_THRESHOLD = min((#DUNGEONS / PREVIOUS_SEASON_NUM_DUNGEONS) * 0.9, 0.9)
    ns.PREVIOUS_SEASON_MAIN_SCORE_RELEVANCE_THRESHOLD = min((#DUNGEONS / PREVIOUS_SEASON_NUM_DUNGEONS) * 0.9, 0.9)

    ---Use `ns.CUSTOM_ICONS.FILENAME.KEY` to get the raw icon table.
    ---
    ---Use `ns.CUSTOM_ICONS.FILENAME.KEY("Texture")` to retrieve the `CustomIconTexture` for the icon.
    ---
    ---Use `ns.CUSTOM_ICONS.FILENAME.KEY("TextureMarkup")` to retrieve the texture markup `string` for the icon.
    ns.CUSTOM_ICONS = {
        affixes = {
            TYRANNICAL_OFF = { 32, 32, 0, 0, 16/32, 32/32, 16/32, 32/32, 0, 0 },
            FORTIFIED_OFF = { 32, 32, 0, 0, 16/32, 32/32, 0/32, 16/32, 0, 0 },
            TYRANNICAL_ON = { 32, 32, 0, 0, 0/32, 16/32, 16/32, 32/32, 0, 0 },
            FORTIFIED_ON = { 32, 32, 0, 0, 0/32, 16/32, 0/32, 16/32, 0, 0 },
        },
        icons = {
            RAIDERIO_COLOR_CIRCLE = { 256, 256, 0, 0, 0/256, 64/256, 0/256, 64/256, 0, 0 },
            RAIDERIO_WHITE_CIRCLE = { 256, 256, 0, 0, 64/256, 128/256, 0/256, 64/256, 0, 0 },
            RAIDERIO_BLACK_CIRCLE = { 256, 256, 0, 0, 128/256, 192/256, 0/256, 64/256, 0, 0 },
            RAIDERIO_COLOR = { 256, 256, 0, 0, 0/256, 64/256, 64/256, 128/256, 0, 0 },
            RAIDERIO_WHITE = { 256, 256, 0, 0, 64/256, 128/256, 64/256, 128/256, 0, 0 },
            RAIDERIO_BLACK = { 256, 256, 0, 0, 128/256, 192/256, 64/256, 128/256, 0, 0 },
        },
    }

    -- Finalize the `ns.CUSTOM_ICONS` table
    do

        ---@class CustomIcon
        ---@field public filePath string

        ---@class CustomIconTexture
        ---@field public width number @The requested width that we should use for the texture.
        ---@field public height number @The requested height that we should use for the texture.
        ---@field public texture string @The texture filepath for use with `:SetTexture(...)`
        ---@field public texCoord table @The texture coordinates for use with `:SetTexCoord(unpack(...))`
        ---@field public textureWidth number @The real texture width.
        ---@field public textureHeight number @The real texture height.

        local Handlers = {
            ---@param self CustomIcon
            ---@param left number
            ---@param right number
            ---@param top number
            ---@param bottom number
            ---@return CustomIconTexture
            Texture = function(self, _, _, width, height, left, right, top, bottom)
                return {
                    width = width,
                    height = height,
                    texture = self.filePath,
                    texCoord = { left, right, top, bottom },
                    textureWidth = self[3],
                    textureHeight = self[4],
                }
            end,
            ---@param self CustomIcon
            TextureMarkup = function(self, ...)
                return CreateTextureMarkup(self.filePath, ...)
            end,
        }

        local Utils = {
            GetSize = function(size, fallback)
                if type(fallback) ~= "number" then
                    fallback = 0
                end
                if type(size) ~= "number" or size <= 0 then
                    return fallback
                end
                return size
            end,
            GetKey = function(key, size)
                if size > 0 then
                    return format("%s_%d", key, size)
                end
                return key
            end,
            GetKeySize = function(self, key, size)
                size = self.GetSize(size, 0)
                return self.GetKey(key, size), size
            end,
        }

        local Metatable = {
            __metatable = false,
            __call = function(self, key, ...)
                local handler = Handlers[key]
                if not handler then
                    return
                end
                local rawKey, size = Utils:GetKeySize(key, ...)
                local rawVal = rawget(self, rawKey)
                if rawVal ~= nil then
                    return rawVal
                end
                local fileWidth, fileHeight, width, height, left, right, top, bottom, xOffset, yOffset = unpack(self)
                local realWidth = (right * fileWidth) - (left * fileWidth)
                local realHeight = (bottom * fileHeight) - (top * fileHeight)
                if realWidth >= size or realHeight >= size then
                    width, height = size, size
                else
                    rawKey = key
                end
                rawVal = handler(self, fileWidth, fileHeight, width, height, left, right, top, bottom, xOffset, yOffset)
                rawset(self, rawKey, rawVal)
                return rawVal
            end,
        }

        for fileName, fileIcons in pairs(ns.CUSTOM_ICONS) do
            for _, iconInfo in pairs(fileIcons) do
                iconInfo.filePath = "Interface\\AddOns\\RaiderIO\\icons\\" .. fileName
                setmetatable(iconInfo, Metatable)
            end
        end

    end

    ns.REGIONS_RESET_TIME = {
        us = 1135695600,
        eu = 1135753200,
        tw = 1135810800,
        kr = 1135810800,
        cn = 1135810800,
    }

    ns.KEYSTONE_AFFIX_SCHEDULE = {
        9,  -- Tyrannical
        10, -- Fortified
    }

    ns.KEYSTONE_AFFIX_INTERNAL = {
        [9] = "tyrannical",
        [10] = "fortified",
    }

    ns.KEYSTONE_AFFIX_TEXTURE = {
        [-9] = ns.CUSTOM_ICONS.affixes.TYRANNICAL_OFF("TextureMarkup"),
        [-10] = ns.CUSTOM_ICONS.affixes.FORTIFIED_OFF("TextureMarkup"),
        [9] = ns.CUSTOM_ICONS.affixes.TYRANNICAL_ON("TextureMarkup"),
        [10] = ns.CUSTOM_ICONS.affixes.FORTIFIED_ON("TextureMarkup"),
    }

    ---@class RoleIcon
    ---@field full string @The full icon in "|T|t" syntax
    ---@field partial string @The partial icon in "|T|t" syntax

    ---@class RoleIcons
    ---@field public dps RoleIcon
    ---@field public healer RoleIcon
    ---@field public tank RoleIcon

    ns.ROLE_ICONS = {
        dps = {
            full = "|TInterface\\AddOns\\RaiderIO\\icons\\roles:14:14:0:0:64:64:0:18:0:18|t",
            partial = "|TInterface\\AddOns\\RaiderIO\\icons\\roles:14:14:0:0:64:64:0:18:36:54|t"
        },
        healer = {
            full = "|TInterface\\AddOns\\RaiderIO\\icons\\roles:14:14:0:0:64:64:19:37:0:18|t",
            partial = "|TInterface\\AddOns\\RaiderIO\\icons\\roles:14:14:0:0:64:64:19:37:36:54|t"
        },
        tank = {
            full = "|TInterface\\AddOns\\RaiderIO\\icons\\roles:14:14:0:0:64:64:38:56:0:18|t",
            partial = "|TInterface\\AddOns\\RaiderIO\\icons\\roles:14:14:0:0:64:64:38:56:36:54|t"
        }
    }

    ns.KEYSTONE_LEVEL_PATTERN = {
        "(%d+)%+",
        "%+%s*(%d+)",
        "(%d+)%s*%+",
        "(%d+)"
    }

    ns.KEYSTONE_LEVEL_TO_SCORE = {
        [2] = 40,
        [3] = 45,
        [4] = 55,
        [5] = 60,
        [6] = 65,
        [7] = 75,
        [8] = 80,
        [9] = 85,
        [10] = 100,
        [11] = 105,
        [12] = 110,
        [13] = 115,
        [14] = 120,
        [15] = 125,
        [16] = 130,
        [17] = 135,
        [18] = 140,
        [19] = 145,
        [20] = 150,
        [21] = 155,
        [22] = 160,
        [23] = 165,
        [24] = 170,
        [25] = 175,
        [26] = 180,
        [27] = 185,
        [28] = 190,
        [29] = 195,
        [30] = 200
    }

    ---@class RaidDifficultyColor : table
    ---@field public pos1 number @red (0-1.0) - this table can be unpacked to get r, g, b
    ---@field public pos2 number @green (0-1.0) - this table can be unpacked to get r, g, b
    ---@field public pos3 number @blue (0-1.0) - this table can be unpacked to get r, g, b
    ---@field public hex string @hex (000000-ffffff) - this table can be unpacked to get r, g, b

    ---@class RaidDifficulty
    ---@field public suffix string
    ---@field public name string
    ---@field public color RaidDifficultyColor

    ns.RAID_DIFFICULTY = {
        [1] = {
            suffix = L.RAID_DIFFICULTY_SUFFIX_NORMAL,
            name = L.RAID_DIFFICULTY_NAME_NORMAL,
            color = { 0.12, 1.00, 0.00, hex = "1eff00" }
        },
        [2] = {
            suffix = L.RAID_DIFFICULTY_SUFFIX_HEROIC,
            name = L.RAID_DIFFICULTY_NAME_HEROIC,
            color = { 0.00, 0.44, 0.87, hex = "0070dd" }
        },
        [3] = {
            suffix = L.RAID_DIFFICULTY_SUFFIX_MYTHIC,
            name = L.RAID_DIFFICULTY_NAME_MYTHIC,
            color = { 0.64, 0.21, 0.93, hex = "a335ee" }
        }
    }

    ns.RECRUITMENT_ENTITY_TYPES = {
        character = 0,
        guild = 1,
        team = 2
    }

    ns.RECRUITMENT_ENTITY_TYPE_URL_SUFFIX = {
        [ns.RECRUITMENT_ENTITY_TYPES.guild] = "guild-recruitment",
        [ns.RECRUITMENT_ENTITY_TYPES.character] = "recruitment",
        [ns.RECRUITMENT_ENTITY_TYPES.team] = "team-recruitment"
    }

    ns.RECRUITMENT_ACTIVITY_TYPES = {
        guildraids = 0,
        guildpvp = 1,
        guildsocial = 2,
        guildkeystone = 3,
        teamkeystone = 4
    }

    ns.RECRUITMENT_ACTIVITY_TYPE_ICONS = {
        [ns.RECRUITMENT_ACTIVITY_TYPES.guildraids] = 4062765, -- achievement_raid_torghastraid
        [ns.RECRUITMENT_ACTIVITY_TYPES.guildpvp] = 236329, -- achievement_arena_2v2_7
        [ns.RECRUITMENT_ACTIVITY_TYPES.guildsocial] = 1495827, -- inv_7xp_inscription_talenttome01
        [ns.RECRUITMENT_ACTIVITY_TYPES.guildkeystone] = 255346, -- achievement_dungeon_gloryoftheraider
        [ns.RECRUITMENT_ACTIVITY_TYPES.teamkeystone] = 255345 -- achievement_dungeon_gloryofthehero
    }

    ns.RECRUITMENT_ROLE_ICONS = {
        dps = "|T2202478:14:16:0:0:128:32:0:32:2:30|t",
        healer = "|T2202478:14:16:0:0:128:32:33:65:2:30|t",
        tank = "|T2202478:14:16:0:0:128:32:67:99:2:30|t"
    }

end

-- data.lua (ns)
-- dependencies: constants
do

    ---@class CharacterProfile
    ---@field public name string
    ---@field public realm string
    ---@field public faction string @"alliance", "horde"
    ---@field public race number
    ---@field public class number

    ---@class CharacterMythicKeystoneRun
    ---@field public zone_id number
    ---@field public level number
    ---@field public upgrades number
    ---@field public fraction number
    ---@field public score number
    ---@field public url string

    ---@class CharacterCollection
    ---@field public profile CharacterProfile
    ---@field public mythic_keystone CharacterCollectionKeystones

    ---@class CharacterCollectionKeystones
    ---@field public all CharacterCollectionKeystoneProfile

    ---@class CharacterCollectionKeystoneProfile
    ---@field public score number
    ---@field public best CharacterMythicKeystoneRun
    ---@field public runs CharacterMythicKeystoneRun[]

    ---@class Character

    ---@return Character<string, CharacterCollection>
    function ns:GetClientData()
        return ns.CLIENT_CHARACTERS
    end

    ---@class ScoreColor
    ---@field public score number
    ---@field public color number[]

    ---@class ScoreColorCollection

    ---@return ScoreColorCollection<number, ScoreColor>
    function ns:GetClientColorData()
        return ns.CLIENT_COLORS
    end

    ---@class GuildProfile
    ---@field public name string
    ---@field public realm string
    ---@field public faction string @"alliance", "horde"

    ---@class GuildMythicKeystoneRunMember
    ---@field public name string
    ---@field public role string @"tank", "heal", "dps"
    ---@field public class_id number

    ---@class GuildMythicKeystoneRun
    ---@field public zone_id number
    ---@field public level number
    ---@field public upgrades number
    ---@field public fraction number
    ---@field public clear_time string
    ---@field public party GuildMythicKeystoneRunMember[]

    ---@class GuildCollection
    ---@field public profile GuildProfile
    ---@field public season_best GuildMythicKeystoneRun[]
    ---@field public weekly_best GuildMythicKeystoneRun[]

    ---@class Guild

    ---@return Guild<string, GuildCollection>
    function ns:GetClientGuildData()
        return ns.GUILD_BEST_DATA
    end

    ---@class ClientConfig
    ---@field public lastModified string @A date like "2017-06-03T00:41:07Z"
    ---@field public enableCombatLogTracking boolean
    ---@field public syncMode string @"all"
    ---@field public syncAmericasHorde boolean
    ---@field public syncEuropeHorde boolean
    ---@field public syncKoreaHorde boolean
    ---@field public syncTaiwanHorde boolean
    ---@field public syncAmericasAlliance boolean
    ---@field public syncEuropeAlliance boolean
    ---@field public syncKoreaAlliance boolean
    ---@field public syncTaiwanAlliance boolean

    ---@return ClientConfig
    function ns:GetClientConfig()
        return ns.CLIENT_CONFIG
    end

    ---@class DungeonInstance
    ---@field public id number
    ---@field public instance_map_id number
    ---@field public lfd_activity_ids number[]
    ---@field public name string
    ---@field public shortName string
    ---@field public shortNameLocale string @Assigned dynamically based on the user preference regarding the short dungeon names.
    ---@field public index number @Assigned dynamically based on the index of the dungeon/raid in the table.

    ---@class Dungeon : DungeonInstance
    ---@field public keystone_instance number

    ---@class DungeonRaid : DungeonInstance

    ---@type Dungeon[]
    local DUNGEONS = ns.DUNGEONS or ns.dungeons -- DEPRECATED: ns.dungeons

    for i = 1, #DUNGEONS do
        local dungeon = DUNGEONS[i] ---@type Dungeon
        dungeon.index = i
    end

    ---@type DungeonRaid[]
    local RAIDS = ns.RAIDS or ns.raids -- DEPRECATED: ns.raids

    for i = 1, #RAIDS do
        local raid = RAIDS[i] ---@type DungeonRaid
        raid.index = i
    end

    ---@return Dungeon[]
    function ns:GetDungeonData()
        return DUNGEONS
    end

    ---@return DungeonRaid[]
    function ns:GetDungeonRaidData()
        return RAIDS
    end

    ---@class RealmCollection

    ---@return RealmCollection<string, string>
    function ns:GetRealmData()
        return ns.REALMS or ns.realmSlugs -- DEPRECATED: ns.realmSlugs
    end

    ---@class RegionCollection

    ---@return RegionCollection<number, number>
    function ns:GetRegionData()
        return ns.REGIONS or ns.regionIDs -- DEPRECATED: ns.regionIDs
    end

    ---@class ScoreStatsCollection

    ---@return ScoreStatsCollection<number, number>
    function ns:GetScoreStatsData()
        return ns.SCORE_STATS or ns.scoreLevelStats -- DEPRECATED: ns.scoreLevelStats
    end

    ---@return ScoreColorCollection<number, ScoreColor>
    function ns:GetScoreTiersData()
        return ns.SCORE_TIERS or ns.scoreTiers -- DEPRECATED: ns.scoreTiers
    end

    ---@class ScoreTierSimple
    ---@field public score number
    ---@field public quality number

    ---@class ScoreTiersSimpleCollection

    ---@return ScoreTiersSimpleCollection<number, ScoreTierSimple>
    function ns:GetScoreTiersSimpleData()
        return ns.SCORE_TIERS_SIMPLE or ns.scoreTiersSimple -- DEPRECATED: ns.scoreTiersSimple
    end

    ---@return ScoreColorCollection<number, ScoreColor>
    function ns:GetScoreTiersPrevData()
        return ns.SCORE_TIERS_PREV or ns.previousScoreTiers -- DEPRECATED ns.previousScoreTiers
    end

    ---@return ScoreTiersSimpleCollection<number, ScoreTierSimple>
    function ns:GetScoreTiersSimplePrevData()
        return ns.SCORE_TIERS_SIMPLE_PREV or ns.previousScoreTiersSimple -- DEPRECATED: ns.previousScoreTiersSimple
    end

    ---@class RecruitmentTitle
    ---@field public [1] string
    ---@field public [2] number?

    ---@class RecruitmentTitlesCollection

    ---@return RecruitmentTitlesCollection<number, RecruitmentTitle>
    function ns:GetRecruitmentTitles()
        return ns.CUSTOM_TITLES
    end

end

-- module.lua (ns)
-- dependencies: none
do

    ---@type table<string, Module>
    local modules = {}
    local moduleIndex = 0

    ---@class Module
    -- private properties for internal use only
    ---@field public id string @Required and unique string to identify the module.
    ---@field public index number @Automatically assigned a number based on the creation order.
    ---@field public loaded boolean @Flag indicates if the module is loaded.
    ---@field public enabled boolean @Flag indicates if the module is enabled.
    ---@field public dependencies string[] @List over dependencies before we can Load the module.
    -- private functions that should never be called
    ---@field public SetLoaded function @Internal function should not be called manually.
    ---@field public Load function @Internal function should not be called manually.
    ---@field public SetEnabled function @Internal function should not be called manually.
    -- protected functions that can be called but should never be overridden
    ---@field public IsLoaded function @Internal function, can be called but do not override.
    ---@field public IsEnabled function @Internal function, can be called but do not override.
    ---@field public Enable function @Internal function, can be called but do not override.
    ---@field public Disable function @Internal function, can be called but do not override.
    ---@field public SetDependencies function @Internal function, can be called but do not override.
    ---@field public HasDependencies function @Internal function, can be called but do not override.
    ---@field public GetDependencies function @Internal function, can be called but do not override. Returns a table using the same order as the dependencies table. Returns the modules or nil depending if they are available or not.
    -- public functions that can be overridden
    ---@field public CanLoad function @If it returns true the module will be loaded, otherwise postponed for later. Override to define your modules load criteria that have to be met before loading.
    ---@field public OnLoad function @Once the module loads this function is executed. Use this to setup further logic for your module. The args provided are the module references as described in the dependencies table.
    ---@field public OnEnable function @This function is executed when the module is set to enabled state. Use this to setup and prepare.
    ---@field public OnDisable function @This function is executed when the module is set to disabled state. Use this for cleanup purposes.

    ---@type Module
    local module = {}

    ---@return nil
    function module:SetLoaded(state)
        self.loaded = state
    end

    ---@return boolean
    function module:Load()
        if not self:CanLoad() then
            return false
        end
        self:SetLoaded(true)
        self:OnLoad(unpack(self:GetDependencies()))
        return true
    end

    ---@return nil
    function module:SetEnabled(state)
        self.enabled = state
    end

    ---@return boolean
    function module:IsLoaded()
        return self.loaded
    end

    ---@return boolean
    function module:IsEnabled()
        return self.enabled
    end

    ---@return boolean
    function module:Enable()
        if self:IsEnabled() then
            return false
        end
        self:SetEnabled(true)
        self:OnEnable()
        return true
    end

    ---@return boolean
    function module:Disable()
        if not self:IsEnabled() then
            return false
        end
        self:SetEnabled(false)
        self:OnDisable()
        return true
    end

    ---@return nil
    function module:SetDependencies(dependencies)
        self.dependencies = dependencies
    end

    ---@return boolean
    function module:HasDependencies()
        if type(self.dependencies) == "string" then
            local m = modules[self.dependencies]
            return m and m:IsLoaded()
        end
        if type(self.dependencies) == "table" then
            for _, id in ipairs(self.dependencies) do
                local m = modules[id]
                if not m or not m:IsLoaded() then
                    return false
                end
            end
        end
        return true
    end

    ---@return Module[]
    function module:GetDependencies()
        local temp = {}
        local index = 0
        if type(self.dependencies) == "string" then
            index = index + 1
            temp[index] = modules[self.dependencies]
        end
        if type(self.dependencies) == "table" then
            for _, id in ipairs(self.dependencies) do
                index = index + 1
                temp[index] = modules[id]
            end
        end
        return temp
    end

    ---@return boolean
    function module:CanLoad()
        return not self:IsLoaded()
    end

    ---@vararg Module
    ---@return nil
    function module:OnLoad(...)
        self:Enable()
    end

    ---@return nil
    function module:OnEnable()
    end

    ---@return nil
    function module:OnDisable()
    end

    ---@param id string @Unique module ID reference.
    ---@param data? Module @Optional table with properties to copy into the newly created module.
    function ns:NewModule(id, data)
        assert(type(id) == "string", "Raider.IO Module expects NewModule(id[, data]) where id is a string, data is optional table.")
        assert(not modules[id], "Raider.IO Module expects NewModule(id[, data]) where id is a string, that is unique and not already taken.")
        ---@type Module
        local m = {}
        for k, v in pairs(module) do
            m[k] = v
        end
        moduleIndex = moduleIndex + 1
        m.index = moduleIndex
        m.id = id
        m:SetLoaded(false)
        m:SetEnabled(false)
        m:SetDependencies()
        if type(data) == "table" then
            for k, v in pairs(data) do
                m[k] = v
            end
        end
        modules[id] = m
        return m
    end

    ---@param a Module
    ---@param b Module
    local function SortModules(a, b)
        return a.index < b.index
    end

    ---@return Module[]
    function ns:GetModules()
        local ordered = {}
        local index = 0
        for _, module in pairs(modules) do
            index = index + 1
            ordered[index] = module
        end
        table.sort(ordered, SortModules)
        return ordered
    end

    ---@param id string @Unique module ID reference.
    ---@param silent? boolean @Ommit to throw if module doesn't exists.
    function ns:GetModule(id, silent)
        assert(type(id) == "string", "Raider.IO Module expects GetModule(id) where id is a string.")
        for _, module in pairs(modules) do
            if module.id == id then
                return module
            end
        end
        assert(silent, "Raider.IO Module expects GetModule(id) where id is a string, and the module must exists, or the silent param must be set to avoid this throw.")
    end

end

-- callback.lua
-- dependencies: module
do

    ---@class CallbackModule : Module
    local callback = ns:NewModule("Callback") ---@type CallbackModule

    local callbacks = {}
    local callbackOnce = {}

    local handler = CreateFrame("Frame")

    handler:SetScript("OnEvent", function(handler, event, ...)
        if event == "COMBAT_LOG_EVENT_UNFILTERED" or event == "COMBAT_LOG_EVENT" then
            callback:SendEvent(event, CombatLogGetCurrentEventInfo())
        else
            callback:SendEvent(event, ...)
        end
    end)

    ---@param callbackFunc function
    function callback:RegisterEvent(callbackFunc, ...)
        assert(type(callbackFunc) == "function", "Raider.IO Callback expects RegisterEvent(callback[, ...events])")
        local events = {...}
        for _, event in ipairs(events) do
            if not callbacks[event] then
                callbacks[event] = {}
            end
            table.insert(callbacks[event], callbackFunc)
            pcall(handler.RegisterEvent, handler, event)
        end
    end

    ---@param callbackFunc function
    ---@param event string
    function callback:RegisterUnitEvent(callbackFunc, event, ...)
        assert(type(callbackFunc) == "function" and type(event) == "string", "Raider.IO Callback expects RegisterUnitEvent(callback, event, ...units)")
        if not callbacks[event] then
            callbacks[event] = {}
        end
        table.insert(callbacks[event], callbackFunc)
        handler:RegisterUnitEvent(event, ...)
    end

    function callback:UnregisterEvent(callbackFunc, ...)
        assert(type(callbackFunc) == "function", "Raider.IO Callback expects UnregisterEvent(callback, ...events)")
        local events = {...}
        callbackOnce[callbackFunc] = nil
        for _, event in ipairs(events) do
            local eventCallbacks = callbacks[event]
            for i = #eventCallbacks, 1, -1 do
                local eventCallback = eventCallbacks[i]
                if eventCallback == callbackFunc then
                    table.remove(eventCallbacks, i)
                end
            end
            if not eventCallbacks[1] then
                pcall(handler.UnregisterEvent, handler, event)
            end
        end
    end

    ---@param callbackFunc function
    function callback:UnregisterCallback(callbackFunc)
        assert(type(callbackFunc) == "function", "Raider.IO Callback expects UnregisterCallback(callback)")
        for event, _ in pairs(callbacks) do
            self:UnregisterEvent(callbackFunc, event)
        end
    end

    ---@param event string
    function callback:SendEvent(event, ...)
        assert(type(event) == "string", "Raider.IO Callback expects SendEvent(event[, ...args])")
        local eventCallbacks = callbacks[event]
        if not eventCallbacks then
            return
        end
        -- execute in correct sequence but note if any are to be removed later
        local remove
        for i = 1, #eventCallbacks do
            local callbackFunc = eventCallbacks[i]
            callbackFunc(event, ...)
            if callbackOnce[callbackFunc] then
                callbackOnce[callbackFunc] = nil
                if not remove then
                    remove = {}
                end
                table.insert(remove, i)
            end
        end
        -- if we have callbacks to remove iterate backwards and remove those indices
        if remove then
            for i = #remove, 1, -1 do
                table.remove(eventCallbacks, remove[i])
            end
        end
    end

    ---@param callbackFunc function
    function callback:RegisterEventOnce(callbackFunc, ...)
        assert(type(callbackFunc) == "function", "Raider.IO Callback expects RegisterEventOnce(callback[, ...events])")
        callbackOnce[callbackFunc] = true
        callback:RegisterEvent(callbackFunc, ...)
    end

end

-- config.lua
-- dependencies: module, callback
do

    ---@class ConfigModule : Module
    ---@field public SavedVariablesLoaded boolean This is etonce the SV are loaded to indicate we are ready to read from the settings table.
    local config = ns:NewModule("Config") ---@type ConfigModule
    local callback = ns:GetModule("Callback") ---@type CallbackModule

    -- fallback saved variables
    local fallbackConfig = {
        enableUnitTooltips = true,
        enableLFGTooltips = true,
        enableFriendsTooltips = true,
        enableLFGDropdown = true,
        enableWhoTooltips = true,
        enableWhoMessages = true,
        enableGuildTooltips = true,
        enableKeystoneTooltips = true,
        mplusHeadlineMode = 1,
        useEnglishAbbreviations = false,
        showMainsScore = true,
        showMainBestScore = true,
        showDropDownCopyURL = true,
        showSimpleScoreColors = false,
        showScoreInCombat = true,
        showScoreModifier = false, -- NEW in 9.0
        disableScoreColors = false,
        enableClientEnhancements = true,
        showClientGuildBest = true,
        displayWeeklyGuildBest = false,
        allowClientToControlCombatLog = true,
        enableCombatLogTracking = false,
        showRaiderIOProfile = true,
        hidePersonalRaiderIOProfile = false,
        showRaidEncountersInProfile = true,
        enableProfileModifier = true,
        inverseProfileModifier = false,
        positionProfileAuto = true,
        lockProfile = false,
        showRoleIcons = true,
        profilePoint = { point = nil, x = 0, y = 0 },
        debugMode = false,
        rwfMode = false, -- NEW in 9.1
        rwfBackgroundMode = true, -- NEW in 9.2
        rwfBackgroundRemindAt = 10, -- NEW in 9.2
        rwfMiniPoint = { point = nil, x = 0, y = 0 }, -- NEW in 9.2
        showMedalsInsteadOfText = false,-- NEW in 9.1.5
    }

    -- fallback metatable looks up missing keys into the fallback config table
    local fallbackMetatable = {
        __index = function(_, key)
            return fallbackConfig[key]
        end
    }

    -- the global saved variables table used when setting up fresh installations
    RaiderIO_Config = setmetatable({}, fallbackMetatable)

    local function OnPlayerLogin()
        if type(RaiderIO_Config) ~= "table" then
            RaiderIO_Config = {}
        end
        setmetatable(RaiderIO_Config, fallbackMetatable)
        config:Enable()
        if config:Get("debugMode") then
            ns.Print(format(L.WARNING_DEBUG_MODE_ENABLE, addonName))
        end
        if config:Get("rwfMode") then
            ns.Print(format(L.WARNING_RWF_MODE_ENABLE, addonName))
        end
        callback:SendEvent("RAIDERIO_CONFIG_READY")
    end

    function config:CanLoad()
        return not self:IsLoaded() and self.SavedVariablesLoaded
    end

    function config:OnLoad()
        callback:RegisterEventOnce(OnPlayerLogin, "RAIDERIO_PLAYER_LOGIN")
    end

    function config:Set(key, val)
        assert(self:IsEnabled(), "Raider.IO Config expects Set(key, val) to only be used after the addon saved variables have been loaded.")
        RaiderIO_Config[key] = val
    end

    function config:Get(key, fallback)
        assert(self:IsEnabled(), "Raider.IO Config expects Get(key[, fallback]) to only be used after the addon saved variables have been loaded.")
        local val = RaiderIO_Config[key]
        if val == nil then
            return fallback
        end
        return val
    end

end

-- util.lua
-- dependencies: module, config
do

    ---@class UtilModule : Module
    local util = ns:NewModule("Util") ---@type UtilModule
    local callback =  ns:GetModule("Callback") ---@type CallbackModule
    local config = ns:GetModule("Config") ---@type ConfigModule

    local DUNGEONS = ns:GetDungeonData()
    local RAIDS = ns:GetDungeonRaidData()

    local SORTED_DUNGEONS = {} ---@type Dungeon[]
    do
        for i = 1, #DUNGEONS do
            SORTED_DUNGEONS[i] = DUNGEONS[i]
        end
    end

    local SORTED_RAIDS = {} ---@type DungeonRaid[]
    do
        for i = 1, #RAIDS do
            SORTED_RAIDS[i] = RAIDS[i]
        end
    end

    -- update the dungeon properties for shortNameLocale at the appropriate events
    local function OnSettingsChanged()
        if not config:IsEnabled() then
            return
        end
        local useEnglishAbbreviations = config:Get("useEnglishAbbreviations")
        for i = 1, #DUNGEONS do
            local dungeon = DUNGEONS[i]
            if useEnglishAbbreviations then
                dungeon.shortNameLocale = dungeon.shortName
            else
                dungeon.shortNameLocale = L["DUNGEON_SHORT_NAME_" .. dungeon.shortName] or dungeon.shortName
            end
        end
        for i = 1, #RAIDS do
            local raid = RAIDS[i]
            if useEnglishAbbreviations then
                raid.shortNameLocale = raid.shortName
            else
                raid.shortNameLocale = raid.shortName -- TODO: L["RAID_SHORT_NAME_" .. raid.shortName]
            end
        end
        ---@param a Dungeon|DungeonRaid
        ---@param b Dungeon|DungeonRaid
        local function SortByLocaleName(a, b)
            return a.shortNameLocale < b.shortNameLocale
        end
        table.sort(SORTED_DUNGEONS, SortByLocaleName)
        table.sort(SORTED_RAIDS, SortByLocaleName)
    end
    callback:RegisterEvent(OnSettingsChanged, "RAIDERIO_CONFIG_READY")
    callback:RegisterEvent(OnSettingsChanged, "RAIDERIO_SETTINGS_SAVED")

    ---@return Dungeon[]
    function util:GetSortedDungeons()
        return SORTED_DUNGEONS
    end

    ---@return Dungeon|nil
    function util:GetDungeonByIndex(index)
        return DUNGEONS[index]
    end

    ---@return Dungeon|nil
    function util:GetDungeonByLFDActivityID(id)
        for i = 1, #DUNGEONS do
            local dungeon = DUNGEONS[i]
            for j = 1, #dungeon.lfd_activity_ids do
                local activityID = dungeon.lfd_activity_ids[j]
                if activityID == id then
                    return dungeon
                end
            end
        end
    end

    ---@return Dungeon|nil
    function util:GetDungeonByKeyValue(key, value)
        for i = 1, #DUNGEONS do
            local dungeon = DUNGEONS[i]
            if dungeon[key] == value then
                return dungeon
            end
        end
    end

    ---@return Dungeon|nil
    function util:GetDungeonByID(id)
        return util:GetDungeonByKeyValue("id", id)
    end

    ---@return Dungeon|nil
    function util:GetDungeonByInstanceMapID(id)
        return util:GetDungeonByKeyValue("instance_map_id", id)
    end

    ---@return Dungeon|nil
    function util:GetDungeonByKeystoneID(id)
        return util:GetDungeonByKeyValue("keystone_instance", id)
    end

    ---@return Dungeon|nil
    function util:GetDungeonByName(name)
        return util:GetDungeonByKeyValue("name", name)
    end

    ---@return Dungeon|nil
    function util:GetDungeonByShortName(name)
        return util:GetDungeonByKeyValue("shortName", name) or util:GetDungeonByKeyValue("shortNameLocale", name)
    end

    ---@return DungeonRaid[]
    function util:GetSortedRaids()
        return SORTED_RAIDS
    end

    ---@return DungeonRaid|nil
    function util:GetRaidByIndex(index)
        return RAIDS[index]
    end

    ---@return DungeonRaid|nil
    function util:GetRaidByLFDActivityID(id)
        for i = 1, #RAIDS do
            local raid = RAIDS[i]
            for j = 1, #raid.lfd_activity_ids do
                local activityID = raid.lfd_activity_ids[j]
                if activityID == id then
                    return raid
                end
            end
        end
    end

    ---@return DungeonRaid|nil
    function util:GetRaidByKeyValue(key, value)
        for i = 1, #RAIDS do
            local raid = RAIDS[i]
            if raid[key] == value then
                return raid
            end
        end
    end

    ---@return DungeonRaid|nil
    function util:GetRaidByID(id)
        return util:GetRaidByKeyValue("id", id)
    end

    ---@return DungeonRaid|nil
    function util:GetRaidByInstanceMapID(id)
        return util:GetRaidByKeyValue("instance_map_id", id)
    end

    ---@return DungeonRaid|nil
    function util:GetRaidByName(name)
        return util:GetRaidByKeyValue("name", name)
    end

    ---@return DungeonRaid|nil
    function util:GetRaidByShortName(name)
        return util:GetRaidByKeyValue("shortName", name) or util:GetRaidByKeyValue("shortNameLocale", name)
    end

    ---@param object Region @Any interface widget object that supports the methods GetScript.
    ---@param handler string @The script handler like OnEnter, OnClick, etc.
    ---@return boolean|nil @If successfully executed returns true, otherwise false if nothing has been called. nil if the widget had no handler to execute.
    function util:ExecuteWidgetHandler(object, handler, ...)
        if type(object) ~= "table" or type(object.GetScript) ~= "function" then
            return false
        end
        local func = object:GetScript(handler)
        if type(func) ~= "function" then
            return
        end
        if not pcall(func, object, ...) then
            return false
        end
        return true
    end

    ---@param frame Region
    ---@param parent Region
    local function IsParentedBy(frame, parent)
        if type(frame) ~= "table" or type(parent) ~= "table" or type(frame.GetParent) ~= "function" or type(parent.GetParent) ~= "function" then
            return
        end
        local current = frame ---@type Region?
        while current do
            ---@diagnostic disable-next-line: need-check-nil
            current = current:GetParent() ---@type Region?
            if not current then
                return false
            elseif current == parent then
                return true
            end
        end
    end

    ---@param frame Region @Any interface widget object that supports the methods GetScript.
    ---@param onEnter fun() @Any function originating from the OnEnter handler.
    ---@return boolean|nil @If the provided object is not a region or has no function we return `nil`, otherwise `true` that it is safe to call, and `false` that it is unsafe to call its function.
    local function IsOnEnterSafe(frame, onEnter)
        if type(frame) ~= "table" or type(frame.GetScript) ~= "function" or type(onEnter) ~= "function" then
            return
        end
        -- profile.lua
        if frame == _G[addonName .. "_ProfileTooltipAnchor"] then return end
        -- guildweekly.lua
        if frame == _G[addonName .. "_GuildWeeklyFrame"] then return true end
        -- whotooltip.lua
        if IsParentedBy(frame, WhoFrame.ScrollBox) then return true end
        -- guildtooltip.lua
        if IsParentedBy(frame, GuildRosterContainer) then return true end
        -- communitytooltip.lua
        if CommunitiesFrame and ClubFinderGuildFinderFrame and ClubFinderCommunityAndGuildFinderFrame then
            if IsParentedBy(frame, CommunitiesFrame.MemberList.ScrollBox) then return true end
            if IsParentedBy(frame, ClubFinderGuildFinderFrame.CommunityCards.ScrollBox) then return true end
            if IsParentedBy(frame, ClubFinderGuildFinderFrame.PendingCommunityCards.ScrollBox) then return true end
            if IsParentedBy(frame, ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ScrollBox) then return true end
            if IsParentedBy(frame, ClubFinderCommunityAndGuildFinderFrame.PendingCommunityCards.ScrollBox) then return true end
        end
        -- anything else is assumed unsafe (we want to minimize the taint risks)
        return false
    end

    ---@alias ExecuteWidgetOnEnterSafelyStatus
    ---| 0 #Region is invalid or doesn't have a script handler.
    ---| 1 #Script handler ignored due to safety concerns.
    ---| 2 #Script handler executed successfully.
    ---| 3 #Script handler executed but silently errored.

    ---@param object Region @Any interface widget object that supports the methods GetScript.
    ---@param before? fun() @Optional function to run right before the OnEnter script executes.
    ---@return ExecuteWidgetOnEnterSafelyStatus @Returns a status enum to indicate the outcome of the call.
    function util:ExecuteWidgetOnEnterSafely(object, before)
        if type(object) ~= "table" or type(object.GetScript) ~= "function" then
            return 0
        end
        local func = object:GetScript("OnEnter")
        if type(func) ~= "function" then
            return 0
        end
        if not IsOnEnterSafe(object, func) then
            return 1
        end
        if type(before) == "function" then
            before()
        end
        if not pcall(func, object) then
            return 3
        end
        return 2
    end

    ---@param object Region @Any interface widget object that supports the methods GetOwner.
    ---@param owner Region @Any interface widget object.
    ---@param anchor string @`ANCHOR_TOPLEFT`, `ANCHOR_NONE`, `ANCHOR_CURSOR`, etc.
    ---@param offsetX? number @Optional offset X for some of the anchors.
    ---@param offsetY? number @Optional offset Y for some of the anchors.
    ---@return boolean|nil, boolean|nil, boolean|nil @If owner was set arg1 is true. If owner was updated arg2 is true. Otherwise both will be set to face to indicate we did not update the Owner of the widget. If the owner is set to the preferred owner arg3 is true.
    function util:SetOwnerSafely(object, owner, anchor, offsetX, offsetY)
        if type(object) ~= "table" or type(object.GetOwner) ~= "function" then
            return
        end
        local currentOwner = object:GetOwner()
        if not currentOwner then
            object:SetOwner(owner, anchor, offsetX, offsetY)
            return true, false, true
        end
        offsetX, offsetY = offsetX or 0, offsetY or 0
        local currentAnchor, currentOffsetX, currentOffsetY = object:GetAnchorType()
        currentOffsetX, currentOffsetY = currentOffsetX or 0, currentOffsetY or 0
        if currentAnchor ~= anchor or (currentOffsetX ~= offsetX and abs(currentOffsetX - offsetX) > 0.01) or (currentOffsetY ~= offsetY and abs(currentOffsetY - offsetY) > 0.01) then
            object:SetOwner(owner, anchor, offsetX, offsetY)
            return true, true, true
        end
        return false, true, currentOwner == owner
    end

    ---@param text string @The format string like "Greetings %s! How are you?"
    ---@return string|nil @Returns a pattern like "Greetings (.-)%! How are you%?"
    function util:FormatToPattern(text)
        if type(text) ~= "string" then
            return
        end
        text = text:gsub("%%", "%%%%")
        text = text:gsub("%.", "%%%.")
        text = text:gsub("%?", "%%%?")
        text = text:gsub("%+", "%%%+")
        text = text:gsub("%-", "%%%-")
        text = text:gsub("%(", "%%%(")
        text = text:gsub("%)", "%%%)")
        text = text:gsub("%[", "%%%[")
        text = text:gsub("%]", "%%%]")
        text = text:gsub("%%%%s", "(.-)")
        text = text:gsub("%%%%d", "(%%d+)")
        text = text:gsub("%%%%%%[%d%.%,]+f", "([%%d%%.%%,]+)")
        return text
    end

    ---@param ts? number @A time() number
    ---@return number @seconds difference between time and utc
    function util:GetTimeZoneOffset(ts)
        local utc = date("!*t", ts)
        local loc = date("*t", ts)
        loc.isdst = false
        return difftime(time(loc), time(utc)) ---@diagnostic disable-line: param-type-mismatch
    end

    ---@param dateString string @A date like "2017-06-03T00:41:07Z"
    ---@return number @A time() number
    function util:GetTimeFromDateString(dateString)
        local year, month, day, hours, minutes, seconds = dateString:match("^(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+).*Z$")
        return time({ year = year, month = month, day = day, hour = hours, min = minutes, sec = seconds })
    end

    local REGION = ns:GetRegionData()

    ---@return boolean|string|nil, number|nil @arg1 can be nil (no data), false (server is unknown), string (the ltd). arg2 can be nil (no data), or region ID.
    function util:GetRegion()
        local guid = UnitGUID("player")
        if not guid then
            return
        end
        local serverId = tonumber(strmatch(guid, "^Player%-(%d+)") or 0) or 0
        local regionId = REGION[serverId]
        if not regionId then
            regionId = GetCurrentRegion()
            if not IsOnTournamentRealm() then
                ns.Print(format(L.UNKNOWN_SERVER_FOUND, addonName, guid or "N/A", GetNormalizedRealmName() or "N/A"))
            end
        end
        if not regionId then
            return false
        end
        local ltd = ns.REGION_TO_LTD[regionId]
        if not ltd then
            return false, regionId
        end
        return ltd, regionId
    end

    ---@return boolean|string|nil, number|nil @arg1 can be nil (no data), false (server is unknown), string (the ltd). arg2 can be nil (no data), or region ID.
    function util:GetRegionForServerId(serverId)
        if not serverId then
            return
        end
        local regionId = REGION[serverId]
        if not regionId then
            return
        end
        local ltd = ns.REGION_TO_LTD[regionId]
        if not ltd then
            return false, regionId
        end
        return ltd, regionId
    end

    ---@return number|nil, string|nil @arg1 is the faction ID or nil if no faction is appropriate. arg2 is the faction localized text for display purposes.
    function util:GetFaction(unit)
        if not unit or not UnitExists(unit) or not UnitIsPlayer(unit) then
            return
        end
        local faction, localizedFaction = UnitFactionGroup(unit)
        if not faction then
            return
        end
        return ns.FACTION_TO_ID[faction], localizedFaction
    end

    local CLIENT_RACE_TO_FACTION_ID = {}

    do
        for i = 1, 100 do
            local raceInfo = C_CreatureInfo.GetRaceInfo(i)
            if raceInfo and raceInfo.clientFileString ~= "Pandaren" then -- this is ambiguous so we better not assume
                local factionInfo = C_CreatureInfo.GetFactionInfo(raceInfo.raceID)
                if factionInfo then
                    CLIENT_RACE_TO_FACTION_ID[raceInfo.clientFileString] = ns.FACTION_TO_ID[factionInfo.groupTag]
                end
            end
        end
    end

    ---@param race string
    ---@param fallback? any
    ---@return number|any @arg1 is the faction ID or nil if no faction is appropriate
    function util:GetFactionFromRace(race, fallback)
        return CLIENT_RACE_TO_FACTION_ID[race] or fallback
    end

    local REALMS = ns:GetRealmData()

    function util:GetRealmSlug(realm, fallback)
        local realmSlug = REALMS[realm]
        if fallback == true then
            return realmSlug or realm
        elseif fallback then
            return realmSlug or fallback
        end
        return realmSlug
    end

    local UNIT_TOKENS = {
        mouseover = true,
        player = true,
        target = true,
        focus = true,
        pet = true,
        vehicle = true,
    }

    do
        for i = 1, 40 do
            UNIT_TOKENS["raid" .. i] = true
            UNIT_TOKENS["raidpet" .. i] = true
            UNIT_TOKENS["nameplate" .. i] = true
        end

        for i = 1, 4 do
            UNIT_TOKENS["party" .. i] = true
            UNIT_TOKENS["partypet" .. i] = true
        end

        for i = 1, 5 do
            UNIT_TOKENS["arena" .. i] = true
            UNIT_TOKENS["arenapet" .. i] = true
        end

        for i = 1, MAX_BOSS_FRAMES do
            UNIT_TOKENS["boss" .. i] = true
        end

        for k, _ in pairs(UNIT_TOKENS) do
            UNIT_TOKENS[k .. "target"] = true
        end
    end

    ---@return boolean @If the unit provided is a unit token this returns true, otherwise false
    function util:IsUnitToken(unit)
        return type(unit) == "string" and UNIT_TOKENS[unit]
    end

    ---@param arg1 string @"unit", "name", or "name-realm"
    ---@param arg2 string|any @"realm" or nil
    ---@return boolean, boolean, boolean @If the args used in the call makes it out to be a proper unit, arg1 is true and only then is arg2 true if unit exists and arg3 is true if unit is a player.
    function util:IsUnit(arg1, arg2)
        if not arg2 and type(arg1) == "string" and arg1:find("-", nil, true) then
            arg2 = true
        end
        local isUnit = not arg2 or util:IsUnitToken(arg1)
        return isUnit, isUnit and UnitExists(arg1), isUnit and UnitIsPlayer(arg1)
    end

    ---@param arg1 string @"unit", "name", or "name-realm"
    ---@param arg2? string @"realm" or nil
    ---@return string, string, string @name, realm, unit
    function util:GetNameRealm(arg1, arg2)
        local unit, name, realm
        local _, unitExists, unitIsPlayer = util:IsUnit(arg1, arg2)
        if unitExists then
            unit = arg1
            if unitIsPlayer then
                name, realm = UnitNameUnmodified(arg1)
                realm = realm and realm ~= "" and realm or GetNormalizedRealmName()
            end
            return name, realm, unit ---@diagnostic disable-line: return-type-mismatch
        end
        if type(arg1) == "string" then
            if arg1:find("-", nil, true) then
                name, realm = ("-"):split(arg1)
            else
                name = arg1 -- assume this is the name
            end
            if not realm or realm == "" then
                if type(arg2) == "string" and arg2 ~= "" then
                    realm = arg2
                else
                    realm = GetNormalizedRealmName() -- assume they are on our realm
                end
            end
        end
        return name, realm, unit ---@diagnostic disable-line: return-type-mismatch
    end

    ---@param level number @The level to test
    ---@param fallback? boolean @If level isn't provided, we'll fallback to this boolean
    function util:IsMaxLevel(level, fallback)
        if level and type(level) == "number" then
            return level >= ns.MAX_LEVEL
        end
        return fallback
    end

    ---@param unit string
    ---@param fallback? boolean @If unit isn't valid (doesn't exists or not a player), we'll fallback to this number
    function util:IsUnitMaxLevel(unit, fallback)
        if unit and UnitExists(unit) and UnitIsPlayer(unit) then
            return util:IsMaxLevel(UnitLevel(unit), fallback)
        end
        return fallback
    end

    ---@param arg1 string @"unit", "name", or "name-realm"
    ---@param arg2? string @"realm" or nil
    ---@param region? string @Optional "us","kr","eu","tw","cn"
    ---@return boolean
    function util:IsUnitPlayer(arg1, arg2, region)
        local name, realm = util:GetNameRealm(arg1, arg2)
        return name == ns.PLAYER_NAME and realm == ns.PLAYER_REALM and (not region or region == ns.PLAYER_REGION)
    end

    ---@param bnetIDAccount number @BNet Account ID
    ---@param getAllChars? boolean @true = table, false = character as varargs
    ---@return table|string|nil, string?, number? @Returns either a table with all characters, or the specific character varargs with name, faction and level.
    function util:GetNameRealmForBNetFriend(bnetIDAccount, getAllChars)
        local index = BNGetFriendIndex(bnetIDAccount)
        if not index then
            return
        end
        local collection = {}
        local collectionIndex = 0
        for i = 1, C_BattleNet.GetFriendNumGameAccounts(index), 1 do
            local accountInfo = C_BattleNet.GetFriendGameAccountInfo(index, i)
            if accountInfo and accountInfo.clientProgram == BNET_CLIENT_WOW and (not accountInfo.wowProjectID or accountInfo.wowProjectID == WOW_PROJECT_MAINLINE) then
                if accountInfo.realmName then
                    accountInfo.characterName = accountInfo.characterName .. "-" .. accountInfo.realmName:gsub("%s+", "")
                end
                collectionIndex = collectionIndex + 1
                collection[collectionIndex] = { accountInfo.characterName, ns.FACTION_TO_ID[accountInfo.factionName], tonumber(accountInfo.characterLevel) }
            end
        end
        if not getAllChars then
            for i = 1, collectionIndex do
                local profile = collection[collectionIndex]
                local name, faction, level = profile[1], profile[2], profile[3]
                if util:IsMaxLevel(level) then
                    return name, faction, level
                end
            end
            return
        end
        return collection
    end

    ---@param playerLink string @The player link can be any valid clickable chat link for messaging
    ---@return string?, string?, number? @Returns the name and realm, or nil for both if invalid
    function util:GetNameRealmFromPlayerLink(playerLink)
        local linkString, linkText = LinkUtil.SplitLink(playerLink)
        local linkType, linkData = ExtractLinkData(linkString)
        if linkType == "player" then
            local name, realm, unit = util:GetNameRealm(linkData) ---@diagnostic disable-line: param-type-mismatch
            return name, realm
        elseif linkType == "BNplayer" then
            local _, bnetIDAccount = strsplit(":", linkData) ---@diagnostic disable-line: param-type-mismatch
            if bnetIDAccount then
                bnetIDAccount = tonumber(bnetIDAccount)
            end
            if bnetIDAccount then
                local fullName, _, level = util:GetNameRealmForBNetFriend(bnetIDAccount)
                local name, realm = util:GetNameRealm(fullName) ---@diagnostic disable-line: param-type-mismatch
                return name, realm, level
            end
        end
    end

    ---@param factionId number @The wow factiongroup id
    ---@return number @The RaiderIO Faction Id
    function util:FactionGroupToFactionId(factionId)
        -- We've got alliance as 1, and horde as 2
        -- WoW has alliance as 1, but horde as 0
        if factionId == 1 then
            return 1
        end
        return 2
    end

    ---@param text string @The text that might contain the keystone level
    ---@param fallback? number @The fallback value in case we can't read the keystone level
    ---@return number|nil @The keystone level we think is detected or nil if we don't know
    function util:GetKeystoneLevelFromText(text, fallback)
        if type(text) ~= "string" then
            return
        end
        for _, pattern in ipairs(ns.KEYSTONE_LEVEL_PATTERN) do
            local level = text:match(pattern)
            if level then
                level = tonumber(level)
                if level and level > 0 and level < 100 then
                    return level
                end
            end
        end
        return fallback
    end

    ---@class LFDStatusResult
    ---@field dungeon Dungeon
    ---@field resultID number

    ---@class LFDStatus
    ---@field dungeon? Dungeon|DungeonRaid
    ---@field hosting boolean
    ---@field queued boolean
    ---@field self LFDStatusResult[] @The LFDStatus itself is also a iterable table with the LFDStatusResult entries.

    ---@return LFDStatus?
    function util:GetLFDStatus()
        ---@type LFDStatus
        local temp = {
            dungeon = nil,
            hosting = false,
            queued = false,
        }
        local index = 0
        local activityInfo = C_LFGList.GetActiveEntryInfo()
        if activityInfo and activityInfo.activityID then
            temp.dungeon = util:GetDungeonByLFDActivityID(activityInfo.activityID) or util:GetRaidByLFDActivityID(activityInfo.activityID)
            temp.hosting = true
        end
        local applications = C_LFGList.GetApplications() ---@type number[]
        for _, resultID in ipairs(applications) do
            local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
            if searchResultInfo and searchResultInfo.activityID and not searchResultInfo.isDelisted then
                local dungeon = util:GetDungeonByLFDActivityID(searchResultInfo.activityID) or util:GetRaidByLFDActivityID(searchResultInfo.activityID)
                if dungeon then
                    local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(resultID)
                    if not pendingStatus and (appStatus == "applied" or appStatus == "invited") then
                        temp.dungeon = dungeon
                        temp.queued = true
                        index = index + 1
                        temp[index] = {
                            dungeon = dungeon,
                            resultID = resultID
                        }
                    end
                end
            end
        end
        if temp.dungeon or temp[1] then
            return temp
        end
    end

    ---@return Dungeon|DungeonRaid|nil
    function util:GetInstanceStatus()
        local _, instanceType, _, _, _, _, _, instanceMapID = GetInstanceInfo()
        if instanceType ~= "party" then
            return
        end
        return util:GetDungeonByInstanceMapID(instanceMapID) or util:GetRaidByInstanceMapID(instanceMapID)
    end

    function util:GetLFDStatusForCurrentActivity(activityID)
        ---@type Dungeon|DungeonRaid|nil
        local focusDungeon
        if activityID then
            focusDungeon = util:GetDungeonByLFDActivityID(activityID) or util:GetRaidByLFDActivityID(activityID)
        end
        if not focusDungeon then
            local lfd = util:GetLFDStatus()
            if lfd then
                focusDungeon = lfd.dungeon
            end
        end
        if not focusDungeon then
            local instanceDungeon = util:GetInstanceStatus()
            if instanceDungeon then
                focusDungeon = instanceDungeon
            end
        end
        return focusDungeon
    end

    ---@param raid DungeonRaid
    local function IsRaidFated(raid)
        if not raid then
            return
        end
        local modInfo = C_ModifiedInstance.GetModifiedInstanceInfoFromMapID(raid.instance_map_id)
        if not modInfo then
            return
        end
        if modInfo.uiTextureKit ~= "ui-ej-icon-empoweredraid" then
            return
        end
        return modInfo.uiTextureKit
    end

    ---@param raid DungeonRaid
    function util:IsRaidFated(raid)
        return IsRaidFated(raid)
    end

    ---@param asMap? boolean
    function util:GetFatedRaids(asMap)
        local raids = {} ---@type DungeonRaid[]
        local index = 0
        for i = 1, #RAIDS do
            local raid = RAIDS[i]
            local fated = IsRaidFated(raid)
            if fated then
                if asMap then
                    raids[raid] = fated or ""
                else
                    index = index + 1
                    raids[index] = raid
                end
            end
        end
        return raids
    end

    local SCORE_TIER = ns:GetScoreTiersData()
    local SCORE_TIER_SIMPLE = ns:GetScoreTiersSimpleData()
    local SCORE_TIER_PREV = ns:GetScoreTiersPrevData()
    local SCORE_TIER_PREV_SIMPLE = ns:GetScoreTiersSimplePrevData()
    local SCORE_STATS = ns:GetScoreStatsData()

    ---@param score number @the score amount we wish to get a color for.
    ---@param isPreviousSeason? boolean @true to show colors based on the previous season color scheme, otherwise false to use this seasons color scheme.
    ---@return number, number, number @r, g, b
    function util:GetScoreColor(score, isPreviousSeason)
        -- if no or empty score or the settings do not let us color scores return white color
        if not config:IsEnabled() or not score or score == 0 or config:Get("disableScoreColors") then
            return 1, 1, 1
        end
        -- pick the current or previous season color data
        local colors = isPreviousSeason and SCORE_TIER_PREV or SCORE_TIER
        local colorsSimple = isPreviousSeason and SCORE_TIER_PREV_SIMPLE or SCORE_TIER_SIMPLE
        -- if simple colors are enabled we use the simple color table
        if config:Get("showSimpleScoreColors") then
            local quality = 1
            for i = 1, #colorsSimple do
                local tier = colorsSimple[i]
                if score >= tier.score then
                    quality = tier.quality
                    break
                end
            end
            local r, g, b = GetItemQualityColor(quality)
            return r, g, b
        end
        -- otherwise we use regular color table
        for i = 1, #colors do
            local tier = colors[i]
            if score >= tier.score then
                return tier.color[1], tier.color[2], tier.color[3]
            end
        end
        -- fallback to gray color if nothing else returned anything
        return 0.62, 0.62, 0.62
    end

    ---@type table<string, string|number>
    local MEDAL_TEXTURE = {
        none = 982414,
        none2 = 982414,
        bronze = 627120,
        bronze2 = 627121,
        silver = 627125,
        silver2 = 607862,
        gold = 627122,
        gold2 = 607858,
        plat = 627123,
        plat2 = 627124,
    }

    for k, v in pairs(MEDAL_TEXTURE) do
        MEDAL_TEXTURE[k] = CreateTextureMarkup(v, 64, 64, 10, 10, 20/64, (20+22)/64, 20/64, (20+22)/64, -2, 0) -- 20 left/top and 22 width/height looks pretty good
    end

    ---@param chests number @the amount of chests/upgrades at the end of the keystone run. returns a string containing stars representing each chest/upgrade.
    function util:GetNumChests(chests, isInactive)
        if config:Get("showMedalsInsteadOfText") then -- TODO: isInactive
            if not chests or chests < 1 then
                return MEDAL_TEXTURE.none
            elseif chests > 3 then
                return MEDAL_TEXTURE.plat
            elseif chests > 2 then
                return MEDAL_TEXTURE.gold
            elseif chests > 1 then
                return MEDAL_TEXTURE.silver
            end
            return MEDAL_TEXTURE.bronze
        end
        if not chests or chests < 1 then
            return ""
        end
        local stars = {
            isInactive and "|cffb28d2e" or "|cffffcf40",
        }
        for i = 1, chests do
            stars[i + 1] = "+"
        end
        stars[chests + 2] = "|r"
        return table.concat(stars, "")
    end

    ---@param chests number @the amount of chests/upgrades at the end of the keystone run. returns the color representing the depletion or timed result.
    function util:GetKeystoneChestColor(chests, asHex)
        if not chests or chests < 1 then
            if asHex then
                return "808080"
            end
            return 0.5, 0.5, 0.5
        end
        if asHex then
            return "FFFFFF"
        end
        return 1, 1, 1
    end

    ---@param level number @The keystone level.
    function util:GetKeystoneAverageScoreForLevel(level)
        return SCORE_STATS[level]
    end

    ---@param weekOffset? number @optional weekly offset. set this to 1 for next week affixes.
    ---@return number, string @`affixID`, `affixInternal`
    function util:GetWeeklyAffix(weekOffset)
        local timestamp = (time() - util:GetTimeZoneOffset()) + 604800 * (weekOffset or 0)
        local timestampWeeklyReset = ns.REGIONS_RESET_TIME[ns.PLAYER_REGION]
        local diff = difftime(timestamp, timestampWeeklyReset)
        local index = floor(diff / 604800) % #ns.KEYSTONE_AFFIX_SCHEDULE + 1
        local affixID = ns.KEYSTONE_AFFIX_SCHEDULE[index]
        return affixID, affixID and ns.KEYSTONE_AFFIX_INTERNAL[affixID]
    end

    ---@type FontString
    local TOOLTIP_TEXT_FONTSTRING do
        TOOLTIP_TEXT_FONTSTRING = UIParent:CreateFontString(nil, nil, "GameTooltipText")
        local fontWidget = _G.GameTooltipTextRight2 ---@type FontString
        local fontObject = fontWidget:GetFontObject()
        if fontObject then
            TOOLTIP_TEXT_FONTSTRING:SetFontObject(fontObject)
        else
            TOOLTIP_TEXT_FONTSTRING:SetFont(fontWidget:GetFont())
        end
    end

    ---@param text string @The text to measure the width in pixels. Assumes standard tooltip font when calculating.
    ---@return number @Text width of the text in pixels.
    function util:GetTooltipTextWidth(text)
        TOOLTIP_TEXT_FONTSTRING:SetText(text)
        TOOLTIP_TEXT_FONTSTRING:Show()
        local width = TOOLTIP_TEXT_FONTSTRING:GetUnboundedStringWidth()
        TOOLTIP_TEXT_FONTSTRING:Hide()
        return width or 0
    end

    ---@param width number @The width of the transparent texture.
    ---@param height? number @Optional height, defaults to 1px if ommited, not required, but available if needed.
    ---@return string @String containing texture escape sequence. If width provided is 0 or less, the return is an empty string.
    function util:GetTextPaddingTexture(width, height)
        if not width or width <= 0 then
            return ""
        end
        return format("|T982414:%d:%d:0:0:64:64:0:1:0:1|t", height or 1, width)
    end

    function util:GetRaiderIOProfileUrl(...)
        local name, realm = util:GetNameRealm(...)
        local realmSlug = util:GetRealmSlug(realm, true)
        local region = select(3, ...)
        region = region and type(region) == "string" and region:len() > 0 and region or ns.PLAYER_REGION
        return format("https://raider.io/characters/%s/%s/%s?utm_source=addon", region, realmSlug, name), name, realm, realmSlug
    end

    function util:GetRaiderIORecruitmentProfileUrl(urlSuffix, ...)
        local name, realm = util:GetNameRealm(...)
        local realmSlug = util:GetRealmSlug(realm, true)
        return format("https://raider.io/characters/%s/%s/%s/%s?utm_source=addon", ns.PLAYER_REGION, realmSlug, name, urlSuffix), name, realm, realmSlug
    end

    ---@class InternalStaticPopupDialog
    ---@field public id string
    ---@field public which? string
    ---@field public text string|fun(): string
    ---@field public button1? string
    ---@field public button2? string
    ---@field public EditBoxOnEscapePressed? fun(self: InternalStaticPopupDialog)
    ---@field public editBoxWidth? number
    ---@field public hasEditBox? boolean
    ---@field public hasWideEditBox? boolean
    ---@field public hideOnEscape? boolean
    ---@field public OnAccept? fun(self: InternalStaticPopupDialog)
    ---@field public OnCancel? fun(self: InternalStaticPopupDialog)
    ---@field public OnShow? fun(self: InternalStaticPopupDialog)
    ---@field public OnHide? fun(self: InternalStaticPopupDialog)
    ---@field public preferredIndex? number
    ---@field public timeout? number
    ---@field public whileDead? boolean

    ---@param popup InternalStaticPopupDialog
    ---@param ... any
    function util:ShowStaticPopupDialog(popup, ...)
        local id = popup.id
        if not StaticPopupDialogs[id] then
            if type(popup.text) == "function" then
                popup.text = popup.text()
            end
            if not popup.which then
                popup.which = popup.id
            end
            StaticPopupDialogs[id] = popup
        end
        return StaticPopup_Show(id, ...)
    end

    ---@type InternalStaticPopupDialog
    local COPY_PROFILE_URL_POPUP = {
        id = "RAIDERIO_COPY_URL",
        text = "%s",
        button2 = CLOSE,
        hasEditBox = true,
        hasWideEditBox = true,
        editBoxWidth = 350,
        preferredIndex = 3,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        OnShow = function(self)
            self:SetWidth(420)
            local editBox = _G[self:GetName() .. "WideEditBox"] or _G[self:GetName() .. "EditBox"]
            editBox:SetText(self.text.text_arg2)
            editBox:SetFocus()
            editBox:HighlightText()
            local button = _G[self:GetName() .. "Button2"]
            button:ClearAllPoints()
            button:SetWidth(200)
            button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
        OnHide = nil,
        OnAccept = nil,
        OnCancel = nil
    }

    function util:ShowCopyRaiderIOProfilePopup(...)
        local url, name, realm = util:GetRaiderIOProfileUrl(...)
        if IsModifiedClick("CHATLINK") then
            local editBox = ChatFrame_OpenChat(url, DEFAULT_CHAT_FRAME)
            editBox:HighlightText()
        else
            util:ShowStaticPopupDialog(COPY_PROFILE_URL_POPUP, format("%s (%s)", name, realm), url)
        end
    end

    function util:ShowCopyRaiderIORecruitmentProfilePopup(recruitmentEntityType, ...)
        local recruitmentSuffix = ns.RECRUITMENT_ENTITY_TYPE_URL_SUFFIX[recruitmentEntityType]
        local url, name, realm = util:GetRaiderIORecruitmentProfileUrl(recruitmentSuffix, ...)
        if IsModifiedClick("CHATLINK") then
            local editBox = ChatFrame_OpenChat(url, DEFAULT_CHAT_FRAME)
            editBox:HighlightText()
        else
            util:ShowStaticPopupDialog(COPY_PROFILE_URL_POPUP, format("%s (%s)", name, realm), url)
        end
    end

    ---@param frame Frame
    ---@param icon CustomIcon
    function util:CreateTextureFromIcon(frame, icon)
        local info = icon("Texture") ---@type CustomIconTexture
        local texture = frame:CreateTexture()
        texture:SetTexture(info.texture)
        texture:SetTexCoord(info.texCoord[1], info.texCoord[2], info.texCoord[3], info.texCoord[4])
        return texture, info
    end

    ---@param button Button
    ---@param icon CustomIcon
    function util:SetButtonTextureFromIcon(button, icon)
        local info = icon("Texture") ---@type CustomIconTexture
        if not button.normalTexture then
            button.normalTexture = util:CreateTextureFromIcon(button, icon)
        end
        if not button.pushedTexture then
            button.pushedTexture = util:CreateTextureFromIcon(button, icon)
        end
        if not button.disabledTexture then
            button.disabledTexture = util:CreateTextureFromIcon(button, icon)
            button.disabledTexture:SetDesaturation(1)
        end
        button:SetNormalTexture(button.normalTexture)
        button:SetPushedTexture(button.pushedTexture)
        button:SetDisabledTexture(button.disabledTexture)
        return info
    end

end

-- json.lua
-- dependencies: module, callback, util
do

    ---@class JSONModule : Module
    local json = ns:NewModule("JSON") ---@type JSONModule
    local callback = ns:GetModule("Callback") ---@type CallbackModule
    local util = ns:GetModule("Util") ---@type UtilModule

    local function IsArray(o)
        if not o[1] then
            return false
        end
        local i
        for k = 1, #o do
            local v = o[k]
            if type(k) ~= "number" then
                return false
            end
            if i and i ~= k - 1 then
                return false
            end
            i = k
        end
        return true
    end

    local function IsMap(o)
        return not not (not IsArray(o) and next(o))
    end

    local TableToJSON

    local function WrapValue(o)
        local t = type(o)
        local s = ""
        if t == "nil" then
            s = "null"
        elseif t == "number" then
            s = tostring(o)
        elseif t == "boolean" then
            s = o and "true" or "false"
        elseif t == "table" then
            s = TableToJSON(o)
        else
            s = "\"" .. tostring(o) .. "\""
        end
        return s
    end

    function TableToJSON(o)
        if type(o) == "table" then
            local s = ""
            if IsMap(o) then
                s = s .. "{"
                for k, v in pairs(o) do
                    s = s .. "\"" .. tostring(k) .. "\":" .. WrapValue(v) .. ","
                end
                if s:sub(-1) == "," then
                    s = s:sub(1, -2)
                end
                s = s .. "}"
            else
                s = s .. "["
                for i = 1, #o do
                    local v = o[i]
                    s = s .. WrapValue(v) .. ","
                end
                if s:sub(-1) == "," then
                    s = s:sub(1, -2)
                end
                s = s .. "]"
            end
            return s
        end
        return o
    end

    ---@type InternalStaticPopupDialog
    local EXPORT_GROUP_JSON_POPUP = {
        id = "RAIDERIO_EXPORTJSON_DIALOG",
        text = L.EXPORTJSON_COPY_TEXT,
        button2 = CLOSE,
        hasEditBox = true,
        hasWideEditBox = true,
        editBoxWidth = 350,
        preferredIndex = 3,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        OnShow = function() json:OpenCopyDialog() end,
        OnHide = function() json:CloseCopyDialog() end,
        OnAccept = nil,
        OnCancel = nil,
        EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end
    }

    local exportButton

    local RoleNameToBit = {
        TANK = 4,
        HEALER = 2,
        DAMAGER = 1,
        NONE = 0
    }

    local function GetUnitRole(unit)
        local role = UnitGroupRolesAssigned(unit)
        return role and RoleNameToBit[role] or RoleNameToBit.NONE
    end

    local function GetQueuedRole(tank, heal, dps)
        local role1 = tank and "TANK" or (heal and "HEALER" or (dps and "DAMAGER"))
        local role2 = (tank and heal and "HEALER") or ((tank or heal) and dps and "DAMAGER")
        local role3 = tank and heal and dps and "DAMAGER"
        local role = RoleNameToBit.NONE
        if role1 == "TANK" or role2 == "TANK" or role3 == "TANK" then
            if band(role, RoleNameToBit.TANK) ~= RoleNameToBit.TANK then
                role = bor(role, RoleNameToBit.TANK)
            end
        end
        if role1 == "HEALER" or role2 == "HEALER" or role3 == "HEALER" then
            if band(role, RoleNameToBit.HEALER) ~= RoleNameToBit.HEALER then
                role = bor(role, RoleNameToBit.HEALER)
            end
        end
        if role1 == "DAMAGER" or role2 == "DAMAGER" or role3 == "DAMAGER" then
            if band(role, RoleNameToBit.DAMAGER) ~= RoleNameToBit.DAMAGER then
                role = bor(role, RoleNameToBit.DAMAGER)
            end
        end
        return role
    end

    local function GetGroupData(unitPrefix, startIndex, endIndex)
        local group = {}
        local index = 0
        for i = startIndex, endIndex do
            local unit = i == 0 and "player" or unitPrefix .. i
            if util:IsUnitMaxLevel(unit) then
                local name, realm = util:GetNameRealm(unit)
                if name then
                    index = index + 1
                    group[index] = format("%d-%s-%s", GetUnitRole(unit), name, util:GetRealmSlug(realm, true))
                end
            end
        end
        if index > 0 then
            return group
        end
    end

    local function GetApplicantsData()
        local group = {}
        local index = 0
        local applicants = C_LFGList.GetApplicants()
        for i = 1, #applicants do
            local applicantInfo = C_LFGList.GetApplicantInfo(applicants[i])
            local applicantGroup
            for j = 1, applicantInfo.numMembers do
                local fullName, class, localizedClass, level, itemLevel, honorLevel, tank, healer, damage, assignedRole, relationship = C_LFGList.GetApplicantMemberInfo(applicantInfo.applicantID, j)
                local name, realm = util:GetNameRealm(fullName)
                if name then
                    local role = GetQueuedRole(tank, healer, damage)
                    if not applicantGroup then
                        applicantGroup = {}
                    end
                    applicantGroup[#applicantGroup + 1] = format("%d-%s-%s", role, name, util:GetRealmSlug(realm, true))
                end
            end
            if applicantGroup then
                index = index + 1
                if applicantGroup[2] then
                    group[index] = applicantGroup
                else
                    group[index] = applicantGroup[1]
                end
            end
        end
        if index > 0 then
            return group
        end
    end

    local function GetJSON()
        local data = {
            activity = 0,
            region = ns.PLAYER_REGION
        }
        local unitPrefix
        local startIndex = 1
        local endIndex = GetNumGroupMembers() ---@type number
        if IsInRaid() then
            unitPrefix = "raid"
        elseif IsInGroup() then
            unitPrefix = "party"
            startIndex = 0
            endIndex = endIndex - 1
        end
        if unitPrefix then
            data.group = GetGroupData(unitPrefix, startIndex, endIndex)
        end
        local entry = C_LFGList.GetActiveEntryInfo()
        if entry and entry.activityID then
            data.activity = entry.activityID
            data.queue = GetApplicantsData()
        end
        return TableToJSON(data)
    end

    local function CanShowCopyDialog()
        local hasGroupMembers = (IsInRaid() or IsInGroup()) and GetNumGroupMembers() > 1
        local entry = C_LFGList.GetActiveEntryInfo()
        local _, numApplicants = C_LFGList.GetNumApplications()
        return not not (hasGroupMembers or entry or numApplicants > 0)
    end

    local function UpdateCopyDialog()
        local canShow = CanShowCopyDialog()
        exportButton:SetShown(canShow)
        if not canShow then
            json:CloseCopyDialog()
            return false
        end
        local frameName, frame = StaticPopup_Visible(EXPORT_GROUP_JSON_POPUP.id)
        if not frame then
            return false
        end
        local editBox = _G[frameName .. "WideEditBox"] or _G[frameName .. "EditBox"]
        frame:SetWidth(420)
        editBox:SetText(canShow and GetJSON() or "")
        editBox:SetFocus()
        editBox:HighlightText()
        local button = _G[frameName .. "Button2"]
        button:ClearAllPoints()
        button:SetWidth(200)
        button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
        return true
    end

    local function CreateExportButton()
        local button = CreateFrame("Button", addonName .. "_ExportButton", _G.LFGListFrame)
        button:SetPoint("BOTTOMRIGHT", button:GetParent(), "BOTTOM", -12, 7) ---@diagnostic disable-line: param-type-mismatch
        button:SetSize(16, 16)
        -- script handlers
        button:SetScript("OnEnter", function() button.Border:SetVertexColor(1, 1, 1) end)
        button:SetScript("OnLeave", function() button.Border:SetVertexColor(.8, .8, .8) end)
        button:SetScript("OnClick", function() json:ToggleCopyDialog() end)
        -- icon
        do
            button.Icon = button:CreateTexture(nil, "BACKGROUND")
            button.Icon:SetAllPoints()
            button.Icon:SetMask("Interface\\Minimap\\UI-Minimap-Background")
            button.Icon:SetTexture("Interface\\Minimap\\Tracking\\None")
        end
        -- border
        do
            button.Border = button:CreateTexture(nil, "BORDER")
            button.Border:SetPoint("TOPLEFT", -2, 2)
            button.Border:SetSize(32, 32)
            button.Border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
            button.Border:SetVertexColor(.8, .8, .8)
        end
        -- return button widget
        return button
    end

    function json:CanLoad()
        return not exportButton and _G.LFGListFrame
    end

    function json:OnLoad()
        self:Enable()
        exportButton = CreateExportButton()
        callback:RegisterEvent(UpdateCopyDialog, "GROUP_ROSTER_UPDATE", "LFG_LIST_ACTIVE_ENTRY_UPDATE", "LFG_LIST_APPLICANT_LIST_UPDATED", "LFG_LIST_APPLICANT_UPDATED", "PLAYER_ENTERING_WORLD", "PLAYER_ROLES_ASSIGNED", "PLAYER_SPECIALIZATION_CHANGED")
    end

    function json:TableToJSON(data)
        return TableToJSON(data)
    end

    function json:ToggleCopyDialog()
        if not self:IsEnabled() then
            return
        end
        if not StaticPopup_Visible(EXPORT_GROUP_JSON_POPUP.id) then
            json:OpenCopyDialog()
        else
            json:CloseCopyDialog()
        end
    end

    function json:OpenCopyDialog()
        if not self:IsEnabled() then
            return
        end
        local _, frame = StaticPopup_Visible(EXPORT_GROUP_JSON_POPUP.id)
        if frame then
            UpdateCopyDialog()
            return
        end
        frame = util:ShowStaticPopupDialog(EXPORT_GROUP_JSON_POPUP)
    end

    function json:CloseCopyDialog()
        if not self:IsEnabled() then
            return
        end
        local _, frame = StaticPopup_Visible(EXPORT_GROUP_JSON_POPUP.id)
        if not frame then
            return
        end
        StaticPopup_Hide(EXPORT_GROUP_JSON_POPUP.id)
    end

end

-- provider.lua
-- dependencies: module, callback, config, util
do

    ---@class ProviderModule : Module
    local provider = ns:NewModule("Provider") ---@type ProviderModule
    local callback = ns:GetModule("Callback") ---@type CallbackModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule

    ---@class DatabaseRaid
    ---@field public id number
    ---@field public mapId number
    ---@field public ordinal number
    ---@field public name string
    ---@field public shortName string
    ---@field public bossCount number
    ---@field public dungeon? DungeonRaid

    ---@class DataProviderMythicKeystone
    ---@field public currentSeasonId number
    ---@field public numCharacters number
    ---@field public recordSizeInBytes number
    ---@field public encodingOrder number[]

    -- hack to implement both keystone and raid classes on the dataprovider below so we do this weird inheritance
    ---@class DataProviderRaid : DataProviderMythicKeystone
    ---@field public currentRaid DatabaseRaid
    ---@field public previousRaid DatabaseRaid
    ---@field public currentRaids DatabaseRaid[]
    ---@field public previousRaids DatabaseRaid[]

    ---@class DataProvider : DataProviderRaid
    ---@field public name string
    ---@field public data number @1 (mythic_keystone), 2 (raid), 3 (recruitment), 4 (pvp)
    ---@field public region string @"eu", "kr", "tw", "us"
    ---@field public date string @"2017-06-03T00:41:07Z"
    ---@field public db table
    ---@field public lookup table
    ---@field public queued boolean @Added dynamically in AddProvider - true when added, later set to false once past the queue check
    ---@field public desynced boolean @Added dynamically in AddProvider - nil or true if provider tables are desynced
    ---@field public outdated number @Added dynamically in AddProvider - nil or number of seconds past our time()
    ---@field public blocked number @Added dynamically in AddProvider - nil or number of seconds past our time()
    ---@field public blockedPurged boolean @Added dynamically in AddProvider - if true it means the provider is just an empty shell without any data

    ---@type DataProvider[]
    local providers = {}

    local function InjectTestBuildData()
        local REGIONS = ns:GetRegionData()
        local REALMS = ns:GetRealmData()
        -- unique client string
        local clientversion = format("PTR_%s", GetBuildInfo())
        -- player region fallback
        ns.PLAYER_REGION = ns.PLAYER_REGION or "us"
        ns.PLAYER_REGION_ID = ns.PLAYER_REGION_ID or 1
        -- region fallback for test realms
        REGIONS[969] = REGIONS[969] or ns.PLAYER_REGION_ID -- 969 = Nobundo-US (PTR)
        REGIONS[3299] = REGIONS[3299] or ns.PLAYER_REGION_ID -- 3299 = Broxigar-US (PTR) | Lycanthoth-US (PTR)
        REGIONS[3296] = REGIONS[3296] or ns.PLAYER_REGION_ID -- 3296 = Anasterian-US (PTR) | Benedictus-US (PTR)
        -- realm fallback
        ns.PLAYER_REALM_SLUG = ns.PLAYER_REALM_SLUG or format("%s_%s", clientversion, ns.PLAYER_REALM)
        REALMS[ns.PLAYER_REALM] = REALMS[ns.PLAYER_REALM] or ns.PLAYER_REALM_SLUG
        -- first available providers matching our faction and region
        local firstKeystoneProvider = provider:GetProviderByType(ns.PROVIDER_DATA_TYPE.MythicKeystone, ns.PLAYER_REGION)
        local firstRaidProvider = provider:GetProviderByType(ns.PROVIDER_DATA_TYPE.Raid, ns.PLAYER_REGION)
        local firstRecruitmentProvider = provider:GetProviderByType(ns.PROVIDER_DATA_TYPE.Recruitment, ns.PLAYER_REGION)
        local firstPvpProvider = provider:GetProviderByType(ns.PROVIDER_DATA_TYPE.PvP, ns.PLAYER_REGION)
        -- create and append proxy providers (fallback to false to avoid nil gaps in the table for the ipairs)
        local aliasRealm
        for _, aliasProvider in ipairs({
            firstKeystoneProvider or false,
            firstRaidProvider or false,
            firstRecruitmentProvider or false,
            firstPvpProvider or false,
        }) do
            if aliasProvider then
                if not aliasRealm and aliasProvider.db then
                    local names = {}
                    for name, _ in pairs(aliasProvider.db) do
                        names[#names + 1] = name
                    end
                    table.sort(names, function(a, b) return strcmputf8i(a, b) < 0 end)
                    aliasRealm = names[1]
                end
                if aliasRealm then
                    aliasProvider.name = format("%s_%s", aliasProvider.name, clientversion)
                    local db = aliasProvider.db
                    if db then
                        db[ns.PLAYER_REALM] = db[aliasRealm]
                    end
                end
            end
        end
        -- print result of this injection
        if aliasRealm then
            ns.Print(format("|cffFFFFFF%s|r Test client detected. Because |cffFFFFFF%s|r doesn't exist we are borrowing data from |cffFFFFFF%s|r. Region is set to |cffFFFFFF%s|r.", addonName, ns.PLAYER_REALM, aliasRealm, ns.PLAYER_REGION))
        else
            ns.Print(format("|cffFFFFFF%s|r Test client detected. Couldn't borrow test data from anywhere as no providers appear to be loaded for the region |cffFFFFFF%s|r.", addonName, ns.PLAYER_REGION))
        end
    end

    local function CheckQueuedProviders()
        local desynced
        local outdated
        local blocked
        for i = #providers, 1, -1 do
            local provider = providers[i]
            if provider.queued then
                provider.queued = false
                if provider.desynced then
                    desynced = true
                end
                if provider.blocked then
                    blocked = true
                elseif provider.outdated then
                    outdated = outdated and max(outdated, provider.outdated) or provider.outdated
                end
                if not config:Get("debugMode") then
                    if provider.region ~= ns.PLAYER_REGION then
                        DisableAddOn(provider.name)
                        table.wipe(provider)
                        table.remove(providers, i)
                    elseif provider.blocked and provider.data == ns.PROVIDER_DATA_TYPE.MythicKeystone and false then -- TODO: do not purge the data just keep it labeled as blocked this way we can always lookup the players own data and still show the warning that its expired
                        provider.blockedPurged = true
                        if provider.db then table.wipe(provider.db) end
                        if provider.lookup then table.wipe(provider.lookup) end
                    end
                end
            end
            if not provider.desynced and not provider.blocked and provider.data == ns.PROVIDER_DATA_TYPE.MythicKeystone then
                ns.CURRENT_SEASON = max(ns.CURRENT_SEASON, provider.currentSeasonId)
            end
        end
        if desynced then
            ns.Print(format(L.OUT_OF_SYNC_DATABASE_S, addonName))
        elseif blocked or outdated then
            ns.Print(format(L.OUTDATED_EXPIRED_ALERT, addonName, ns.RAIDERIO_ADDON_DOWNLOAD_URL))
        elseif not providers[1] then
            if not IsOnTournamentRealm() then
                ns.Print(format(L.PROVIDER_NOT_LOADED, addonName, ns.PLAYER_FACTION_TEXT))
            end
        end
    end

    local function RequestMythicPlusData()
        C_MythicPlus.RequestCurrentAffixes()
        C_MythicPlus.RequestMapInfo()
    end

    local function OnPlayerLogin()
        if IsTestBuild() and config:Get("debugMode") then
            InjectTestBuildData()
        end
        CheckQueuedProviders()
        RequestMythicPlusData()
        provider:Enable()
    end

    function provider:OnLoad()
        callback:RegisterEventOnce(OnPlayerLogin, "RAIDERIO_PLAYER_LOGIN")
    end

    function provider:GetProviders()
        return providers
    end

    function provider:GetProviderByType(dataType, optionalRegion)
        for i = 1, #providers do
            local provider = providers[i]
            if provider.data == dataType and (not optionalRegion or provider.region == optionalRegion) then
                return provider
            end
        end
    end

    function provider:GetProvidersDates()
        local keystoneDate, raidDate, recruitmentDate, pvpDate
        for i = 1, #providers do
            local provider = providers[i]
            if provider.data == ns.PROVIDER_DATA_TYPE.MythicKeystone then
                if not keystoneDate or keystoneDate < provider.date then
                    keystoneDate = provider.date
                end
            elseif provider.data == ns.PROVIDER_DATA_TYPE.Raid then
                if not raidDate or raidDate < provider.date then
                    raidDate = provider.date
                end
            elseif provider.data == ns.PROVIDER_DATA_TYPE.Recruitment then
                if not recruitmentDate or recruitmentDate < provider.date then
                    recruitmentDate = provider.date
                end
            elseif provider.data == ns.PROVIDER_DATA_TYPE.PvP then
                if not pvpDate or pvpDate < provider.date then
                    pvpDate = provider.date
                end
            end
        end
        return keystoneDate, raidDate, recruitmentDate, pvpDate
    end

    ---@param dateString string @The date string from the provider
    ---@return number?, boolean? @arg1 is seconds difference between now and the date in the provider. arg2 is true if we should block from showing data from this provider
    local function GetOutdatedAndBlockState(dateString)
        local dateAsTime = util:GetTimeFromDateString(dateString)
        local tzOffset = util:GetTimeZoneOffset(dateAsTime)
        local timeDiff = time() - dateAsTime - tzOffset
        if timeDiff > ns.OUTDATED_CUTOFF then
            if timeDiff > ns.OUTDATED_BLOCK_CUTOFF then
                return timeDiff - ns.OUTDATED_BLOCK_CUTOFF, timeDiff > ns.OUTDATED_BLOCK_CUTOFF
            end
            return timeDiff - ns.OUTDATED_CUTOFF
        end
    end

    local function GetExistingProvider(dataType, region)
        for i = 1, #providers do
            local provider = providers[i]
            if provider.data == dataType and provider.region == region then
                return provider
            end
        end
    end

    ---@param data DataProvider
    function provider:AddProvider(data)
        -- we only add providers until we enter the world, then we stop accepting additional providers as we are considered done loading
        if self:IsEnabled() then
            return false
        end
        -- sanity check that the data structure is as we expect it to be
        assert(type(data) == "table", "Raider.IO Provider expects Add(data) where data is a table.")
        assert(type(data.name) == "string" and type(data.data) == "number" and type(data.region) == "string" and type(data.date) == "string", "Raider.IO Provider expects AddProvider(data) where data is a table and has the appropriate structure expected of a data provider.")
        -- expand with additional information
        data.outdated, data.blocked = GetOutdatedAndBlockState(data.date)
        data.queued = true
        -- find existing provider table and expand it, otherwise insert new table
        local provider = GetExistingProvider(data.data, data.region)
        if provider then
            if provider.date ~= data.date then
                provider.desynced = true
            end
            for k, v in pairs(data) do
                provider[k] = provider[k] or v
            end
            table.wipe(data)
            if provider.data == ns.PROVIDER_DATA_TYPE.Raid then
                ---@param raid DatabaseRaid
                local function PopulateRaidWithDungeon(raid)
                    if not raid or not raid.id or raid.dungeon then
                        return
                    end
                    raid.dungeon = util:GetRaidByID(raid.id)
                end
                for _, raid in ipairs({ provider.currentRaid, provider.previousRaid }) do
                    PopulateRaidWithDungeon(raid)
                end
                for _, raids in ipairs({ provider.currentRaids, provider.previousRaids }) do
                    if raids then
                        for _, raid in ipairs(raids) do
                            PopulateRaidWithDungeon(raid)
                        end
                    end
                end
            end
        else
            table.insert(providers, data)
        end
        -- we successfully added the new provider
        return true
    end

    local function BinarySearchGetIndexFromName(data, name, startIndex, endIndex)
        local minIndex = startIndex
        local maxIndex = endIndex
        local mid, current, cmp

        while minIndex <= maxIndex do
            mid = floor((maxIndex + minIndex) / 2)
            current = data[mid]
            cmp = strcmputf8i(current, name)
            if cmp == 0 then
                return mid, current
            elseif cmp < 0 then
                minIndex = mid + 1
            else
                maxIndex = mid - 1
            end
        end
    end

    -- TODO: can this be part of the provider? we can see if we can make a more dynamic system
    local ENCODER_MYTHICPLUS_FIELDS = {
        CURRENT_SCORE       = 1,  -- current season score
        CURRENT_ROLES       = 2,  -- current season roles
        PREVIOUS_SCORE      = 3,  -- previous season score
        PREVIOUS_ROLES      = 4,  -- previous season roles
        MAIN_CURRENT_SCORE  = 5,  -- main's current season score
        MAIN_CURRENT_ROLES  = 6,  -- main's current season roles
        MAIN_PREVIOUS_SCORE = 7,  -- main's previous season score
        MAIN_PREVIOUS_ROLES = 8,  -- main's previous season roles
        DUNGEON_RUN_COUNTS  = 9,  -- number of runs this season for 5+, 10+, 15+, and 20+
        DUNGEON_LEVELS      = 10, -- dungeon levels and stars for each dungeon completed
        DUNGEON_BEST_INDEX  = 11  -- best dungeon index
    }

    -- TODO: can this be part of the provider? we can see if we can make a more dynamic system
    local ENCODER_RECRUITMENT_FIELDS = {
        TITLE                 = 0, -- custom recruitment title index
        ENTITY_TYPE           = 1, -- character, guild, team
        -- ACTIVITY_TYPE         = 2, -- guildraids, guildpvp, guildsocial, guildkeystones, teamkeystones
        ROLES                 = 3, -- dps = 1, healer = 2, tank = 4 (see `ENCODER_RECRUITMENT_ROLES`)
    }
    local ENCODER_RECRUITMENT_ROLES = {
        dps = 1,
        healer = 2,
        tank = 4,
    }

    -- TODO: can this be part of the provider? we can see if we can make a more dynamic system
    local ENCODER_RAIDING_FIELDS = {
        CURRENT_FULL_PROGRESS = 1,
        PREVIOUS_FULL_PROGRESS = 2,
        PREVIOUS_SUMMARY_PROGRESS = 3,
        MAINS_CURRENT_SUMMARY_PROGRESS = 4,
    }

    ---@param provider DataProvider
    ---@return table?, number?, string?, string?, string?
    local function SearchForBucketByName(provider, lookup, data, name, realm)
        local internalRealm = realm
        local realmData = data[realm]
        if not realmData then
            for rn, rd in pairs(data) do
                if rn ~= realm and strcmputf8i(rn, realm) == 0 then
                    internalRealm = rn
                    realmData = rd
                    break
                end
            end
        end
        if not realmData then
            return
        end
        local nameIndex, internalName = BinarySearchGetIndexFromName(realmData, name, 2, #realmData)
        if not nameIndex then
            return
        end
        local bucket, baseOffset, guid
        if provider.data == ns.PROVIDER_DATA_TYPE.MythicKeystone then
            local bucketID = 1
            bucket = lookup[bucketID]
            baseOffset = 1 + realmData[1] + (nameIndex - 2) * provider.recordSizeInBytes
            guid = provider.data .. ":" .. provider.region .. ":" .. bucketID .. ":" .. baseOffset
        elseif provider.data == ns.PROVIDER_DATA_TYPE.Raid then
            local bucketID = 1
            bucket = lookup[bucketID]
            baseOffset = 1 + realmData[1] + (nameIndex - 2) * provider.recordSizeInBytes
            guid = provider.data .. ":" .. provider.region .. ":" .. bucketID .. ":" .. baseOffset
        elseif provider.data == ns.PROVIDER_DATA_TYPE.Recruitment then
            local bucketID = 1
            bucket = lookup[bucketID]
            baseOffset = 1 + realmData[1] + (nameIndex - 2) * provider.recordSizeInBytes
            guid = provider.data .. ":" .. provider.region .. ":" .. bucketID .. ":" .. baseOffset
        elseif provider.data == ns.PROVIDER_DATA_TYPE.PvP then
            -- TODO
        end
        return bucket, baseOffset, guid, internalName, internalRealm
    end

    local function ReadBitsFromString(data, offset, length)
        local value = 0
        local readOffset = 0
        local firstByteShift = offset % 8
        local bytesToRead = ceil((length + firstByteShift) / 8)
        while readOffset < length do
            local byte = strbyte(data, 1 + floor((offset + readOffset) / 8))
            local bitsRead = 0
            if readOffset == 0 then
                if bytesToRead == 1 then
                    local availableBits = length - readOffset
                    value = band(rshift(byte, firstByteShift), ((lshift(1, availableBits)) - 1))
                    bitsRead = length
                else
                    value = rshift(byte, firstByteShift)
                    bitsRead = 8 - firstByteShift
                end
            else
                local availableBits = length - readOffset
                if availableBits < 8 then
                    value = value + lshift(band(byte, (lshift(1, availableBits) - 1)), readOffset)
                    bitsRead = bitsRead + availableBits
                else
                    value = value + lshift(byte, readOffset)
                    bitsRead = bitsRead + min(8, length)
                end
            end
            readOffset = readOffset + bitsRead
        end
        return value, offset + readOffset
    end

    local function DecodeBits6(value)
        if value < 10 then
            return value
        end
        return 10 + (value - 10) * 5
    end

    local function DecodeBits7(value)
        if value < 20 then
            return value
        end
        return 20 + (value - 20) * 4
    end

    local function DecodeBits8(value)
        if value < 200 then
            return value
        end
        return 200 + (value - 200) * 2
    end

    local DECODE_BITS_2_TABLE = { 0, 1, 2, 5 }

    local function DecodeBits2(value)
        return DECODE_BITS_2_TABLE[1 + value] or 0
    end

    -- TODO: can this be part of the provider? we can see if we can make a more dynamic system
    ---@class OrderedRolesItem
    ---@field public pos1 string @"tank","healer","dps"
    ---@field public pos2 string @"full","partial"
    local ORDERED_ROLES = {
        { },
        { {"dps","full"}, },
        { {"dps","full"}, {"healer","full"}, },
        { {"dps","full"}, {"healer","full"}, {"tank","full"}, },
        { {"dps","full"}, {"healer","full"}, {"tank","partial"}, },
        { {"dps","full"}, {"healer","partial"}, },
        { {"dps","full"}, {"healer","partial"}, {"tank","full"}, },
        { {"dps","full"}, {"healer","partial"}, {"tank","partial"}, },
        { {"dps","full"}, {"tank","full"}, },
        { {"dps","full"}, {"tank","full"}, {"healer","full"}, },
        { {"dps","full"}, {"tank","full"}, {"healer","partial"}, },
        { {"dps","full"}, {"tank","partial"}, },
        { {"dps","full"}, {"tank","partial"}, {"healer","full"}, },
        { {"dps","full"}, {"tank","partial"}, {"healer","partial"}, },
        { {"dps","partial"}, },
        { {"dps","partial"}, {"healer","full"}, },
        { {"dps","partial"}, {"healer","full"}, {"tank","full"}, },
        { {"dps","partial"}, {"healer","full"}, {"tank","partial"}, },
        { {"dps","partial"}, {"healer","partial"}, },
        { {"dps","partial"}, {"healer","partial"}, {"tank","full"}, },
        { {"dps","partial"}, {"healer","partial"}, {"tank","partial"}, },
        { {"dps","partial"}, {"tank","full"}, },
        { {"dps","partial"}, {"tank","full"}, {"healer","full"}, },
        { {"dps","partial"}, {"tank","full"}, {"healer","partial"}, },
        { {"dps","partial"}, {"tank","partial"}, },
        { {"dps","partial"}, {"tank","partial"}, {"healer","full"}, },
        { {"dps","partial"}, {"tank","partial"}, {"healer","partial"}, },
        { {"healer","full"}, },
        { {"healer","full"}, {"dps","full"}, },
        { {"healer","full"}, {"dps","full"}, {"tank","full"}, },
        { {"healer","full"}, {"dps","full"}, {"tank","partial"}, },
        { {"healer","full"}, {"dps","partial"}, },
        { {"healer","full"}, {"dps","partial"}, {"tank","full"}, },
        { {"healer","full"}, {"dps","partial"}, {"tank","partial"}, },
        { {"healer","full"}, {"tank","full"}, },
        { {"healer","full"}, {"tank","full"}, {"dps","full"}, },
        { {"healer","full"}, {"tank","full"}, {"dps","partial"}, },
        { {"healer","full"}, {"tank","partial"}, },
        { {"healer","full"}, {"tank","partial"}, {"dps","full"}, },
        { {"healer","full"}, {"tank","partial"}, {"dps","partial"}, },
        { {"healer","partial"}, },
        { {"healer","partial"}, {"dps","full"}, },
        { {"healer","partial"}, {"dps","full"}, {"tank","full"}, },
        { {"healer","partial"}, {"dps","full"}, {"tank","partial"}, },
        { {"healer","partial"}, {"dps","partial"}, },
        { {"healer","partial"}, {"dps","partial"}, {"tank","full"}, },
        { {"healer","partial"}, {"dps","partial"}, {"tank","partial"}, },
        { {"healer","partial"}, {"tank","full"}, },
        { {"healer","partial"}, {"tank","full"}, {"dps","full"}, },
        { {"healer","partial"}, {"tank","full"}, {"dps","partial"}, },
        { {"healer","partial"}, {"tank","partial"}, },
        { {"healer","partial"}, {"tank","partial"}, {"dps","full"}, },
        { {"healer","partial"}, {"tank","partial"}, {"dps","partial"}, },
        { {"tank","full"}, },
        { {"tank","full"}, {"dps","full"}, },
        { {"tank","full"}, {"dps","full"}, {"healer","full"}, },
        { {"tank","full"}, {"dps","full"}, {"healer","partial"}, },
        { {"tank","full"}, {"dps","partial"}, },
        { {"tank","full"}, {"dps","partial"}, {"healer","full"}, },
        { {"tank","full"}, {"dps","partial"}, {"healer","partial"}, },
        { {"tank","full"}, {"healer","full"}, },
        { {"tank","full"}, {"healer","full"}, {"dps","full"}, },
        { {"tank","full"}, {"healer","full"}, {"dps","partial"}, },
        { {"tank","full"}, {"healer","partial"}, },
        { {"tank","full"}, {"healer","partial"}, {"dps","full"}, },
        { {"tank","full"}, {"healer","partial"}, {"dps","partial"}, },
        { {"tank","partial"}, },
        { {"tank","partial"}, {"dps","full"}, },
        { {"tank","partial"}, {"dps","full"}, {"healer","full"}, },
        { {"tank","partial"}, {"dps","full"}, {"healer","partial"}, },
        { {"tank","partial"}, {"dps","partial"}, },
        { {"tank","partial"}, {"dps","partial"}, {"healer","full"}, },
        { {"tank","partial"}, {"dps","partial"}, {"healer","partial"}, },
        { {"tank","partial"}, {"healer","full"}, },
        { {"tank","partial"}, {"healer","full"}, {"dps","full"}, },
        { {"tank","partial"}, {"healer","full"}, {"dps","partial"}, },
        { {"tank","partial"}, {"healer","partial"}, },
        { {"tank","partial"}, {"healer","partial"}, {"dps","full"}, },
        { {"tank","partial"}, {"healer","partial"}, {"dps","partial"}, },
    }

    ---@class DataProviderMythicKeystoneScore
    ---@field public season number @The previous season number, otherwise nil if current season
    ---@field public score number @The score amount
    ---@field public originalScore number @If set to a number, it means we did override the score but kept a backup of the original here
    ---@field public roles OrderedRolesItem[] @table of roles associated with the score

    ---@class DataProviderMythicKeystoneProfile
    ---@field public outdated number|nil @number or nil
    ---@field public hasRenderableData boolean @True if we have any actual data to render in the tooltip without the profile appearing incomplete or empty.
    ---@field public hasOverrideScore boolean @True if we override the score shown using in-game score data for the profile tooltip.
    ---@field public hasOverrideDungeonRuns boolean @True if we override the dungeon runs shown using in-game data for the profile tooltip.
    ---@field public blocked number|nil @number or nil
    ---@field public blockedPurged boolean|nil @True if the provider has been blocked and purged
    ---@field public softBlocked number|nil @number or nil - Only defined when the profile looked up is the players own profile
    ---@field public isEnhanced boolean|nil @true if client enhanced data (fractionalTime and .dungeonTimes are 1 for timed and 3 for depleted, but when enhanced it's the actual time fraction)
    ---@field public currentScore number
    ---@field public originalCurrentScore number @If set to a number, it means we did override the score but kept a backup of the original here
    ---@field public currentRoleOrdinalIndex number
    ---@field public previousScore number
    ---@field public previousScoreSeason number
    ---@field public previousRoleOrdinalIndex number
    ---@field public mainCurrentScore number
    ---@field public mainCurrentRoleOrdinalIndex number
    ---@field public mainPreviousScore number
    ---@field public mainPreviousScoreSeason number
    ---@field public mainPreviousRoleOrdinalIndex number
    ---@field public keystoneFivePlus number
    ---@field public keystoneTenPlus number
    ---@field public keystoneFifteenPlus number
    ---@field public keystoneTwentyPlus number
    ---@field public fortifiedDungeons number[]
    ---@field public fortifiedDungeonUpgrades number[]
    ---@field public fortifiedDungeonTimes number[]
    ---@field public tyrannicalDungeons number[]
    ---@field public tyrannicalDungeonUpgrades number[]
    ---@field public tyrannicalDungeonTimes number[]
    ---@field public dungeons number[] @Proxy table that looks up the correct weekly affix table if used. Use `fortifiedDungeons` and `tyrannicalDungeons` when possible.
    ---@field public dungeonUpgrades number[] @Proxy table that looks up the correct weekly affix table if used. Use `fortifiedDungeonUpgrades` and `tyrannicalDungeonUpgrades` when possible.
    ---@field public dungeonTimes number[] @Proxy table that looks up the correct weekly affix table if used. Use `fortifiedDungeonTimes` and `tyrannicalDungeonTimes` when possible.
    ---@field public fortifiedMaxDungeonIndex number
    ---@field public fortifiedMaxDungeonLevel number
    ---@field public fortifiedMaxDungeon? Dungeon
    ---@field public tyrannicalMaxDungeonIndex number
    ---@field public tyrannicalMaxDungeonLevel number
    ---@field public tyrannicalMaxDungeon? Dungeon
    ---@field public maxDungeonIndex number @Proxy table that looks up the correct weekly affix table if used. Use `fortifiedMaxDungeonIndex` and `tyrannicalMaxDungeonIndex` when possible.
    ---@field public maxDungeonLevel number @Proxy table that looks up the correct weekly affix table if used. Use `fortifiedMaxDungeonLevel` and `tyrannicalMaxDungeonLevel` when possible.
    ---@field public maxDungeon Dungeon @Proxy table that looks up the correct weekly affix table if used. Use `fortifiedMaxDungeon` and `tyrannicalMaxDungeon` when possible.
    ---@field public maxDungeonUpgrades number @Proxy table that looks up the correct weekly affix table if used. Part of the override score functionality, possibly client data as well.
    ---@field public sortedDungeons SortedDungeon[]
    ---@field public sortedMilestones SortedMilestone[]
    ---@field public mplusCurrent DataProviderMythicKeystoneScore
    ---@field public mplusPrevious DataProviderMythicKeystoneScore
    ---@field public mplusMainCurrent DataProviderMythicKeystoneScore
    ---@field public mplusMainPrevious DataProviderMythicKeystoneScore

    ---@class SortedDungeon
    ---@field public dungeon Dungeon
    ---@field public level number @Proxy table that looks up the correct weekly affix table if used. Use `fortifiedLevel` and `tyrannicalLevel` when possible.
    ---@field public chests number @Proxy table that looks up the correct weekly affix table if used. Use `fortifiedChests` and `tyrannicalChests` when possible.
    ---@field public fractionalTime number @Proxy table that looks up the correct weekly affix table if used. Use `fortifiedFractionalTime` and `tyrannicalFractionalTime` when possible. If we have client data `isEnhanced` is set and the values are then `0.0` to `1.0` is within the timer, anything above is depleted over the timer. If `isEnhanced` is false then this value is 0 to 3 where 3 is depleted, and the rest is in time.
    ---@field public sortOrder string @Proxy table that looks up the correct weekly affix table if used. Use `fortifiedSortOrder` and `tyrannicalSortOrder` when possible.
    ---@field public fortifiedLevel number @Keystone level
    ---@field public fortifiedChests number @Number of medals where 1=Bronze, 2=Silver, 3=Gold
    ---@field public fortifiedFractionalTime number @If we have client data `isEnhanced` is set and the values are then `0.0` to `1.0` is within the timer, anything above is depleted over the timer. If `isEnhanced` is false then this value is 0 to 3 where 3 is depleted, and the rest is in time.
    ---@field public fortifiedSortOrder string @The sorting weight assigned this entry. Combination of level, chests and name of the dungeon.
    ---@field public tyrannicalLevel number @Keystone level
    ---@field public tyrannicalChests number @Number of medals where 1=Bronze, 2=Silver, 3=Gold
    ---@field public tyrannicalFractionalTime number @If we have client data `isEnhanced` is set and the values are then `0.0` to `1.0` is within the timer, anything above is depleted over the timer. If `isEnhanced` is false then this value is 0 to 3 where 3 is depleted, and the rest is in time.
    ---@field public tyrannicalSortOrder string @The sorting weight assigned this entry. Combination of level, chests and name of the dungeon.

    ---@class SortedMilestone
    ---@field public level number
    ---@field public label string
    ---@field public text string

    local CLIENT_CHARACTERS = ns:GetClientData()
    local DUNGEONS = ns:GetDungeonData()

    ---@param a SortedDungeon
    ---@param b SortedDungeon
    local function SortDungeons(a, b)
        return strcmputf8i(a.sortOrder, b.sortOrder) < 0
    end

    ---@param results DataProviderMythicKeystoneProfile
    local function ApplyWeeklyAffixForDungeons(results, bucket, bitOffset, weeklyAffixInternal)
        local dungeons = {}
        local dungeonUpgrades = {}
        local dungeonTimes = {}
        for i = 1, #DUNGEONS do
            dungeons[i], bitOffset = ReadBitsFromString(bucket, bitOffset, 6)
            dungeonUpgrades[i], bitOffset = ReadBitsFromString(bucket, bitOffset, 2)
            dungeonTimes[i] = 3 - dungeonUpgrades[i]
            results.hasRenderableData = results.hasRenderableData or dungeons[i] > 0
        end
        results[weeklyAffixInternal .. "Dungeons"] = dungeons
        results[weeklyAffixInternal .. "DungeonUpgrades"] = dungeonUpgrades
        results[weeklyAffixInternal .. "DungeonTimes"] = dungeonTimes
        return bitOffset
    end

    ---@param results DataProviderMythicKeystoneProfile
    local function ApplyWeeklyAffixForDungeonBest(results, bucket, bitOffset, weeklyAffixInternal)
        local value, bitOffset = ReadBitsFromString(bucket, bitOffset, 4)
        local maxDungeonIndex = 1 + value
        if maxDungeonIndex > #DUNGEONS then
            maxDungeonIndex = 1
        end
        results[weeklyAffixInternal .. "MaxDungeonIndex"] = maxDungeonIndex
        results[weeklyAffixInternal .. "MaxDungeonLevel"] = results[weeklyAffixInternal .. "Dungeons"][maxDungeonIndex]
        results[weeklyAffixInternal .. "MaxDungeon"] = DUNGEONS[maxDungeonIndex]
        return bitOffset
    end

    ---@param results DataProviderMythicKeystoneProfile
    local function ApplyWeeklyAffixWrapper(results)
        local dynamicKeys = {
            dungeons = true,
            dungeonUpgrades = true,
            dungeonTimes = true,
            maxDungeonIndex = true,
            maxDungeonLevel = true,
            maxDungeon = true,
        }
        setmetatable(results, {
            __metatable = false,
            __index = function(self, key)
                if not dynamicKeys[key] then
                    return
                end
                local _, weeklyAffixInternal = util:GetWeeklyAffix()
                local destKey = key:sub(1, 1):upper() .. key:sub(2)
                return self[weeklyAffixInternal .. destKey]
            end,
        })
    end

    ---@param results DataProviderMythicKeystoneProfile
    local function ApplySortedDungeonsForAffix(results, weeklyAffixInternal)
        ---@param sortedDungeon SortedDungeon
        local function getSortOrderForAffix(sortedDungeon, weeklyAffixInternal)
            local index = sortedDungeon.dungeon.index
            local level = results[weeklyAffixInternal .. "Dungeons"][index]
            local chests = results[weeklyAffixInternal .. "DungeonUpgrades"][index]
            -- local fractionalTime = results[weeklyAffixInternal .. "DungeonTimes"][index]
            return format("%02d-%02d", 99 - level, 99 - chests)
        end
        ---@param sortedDungeon SortedDungeon
        ---@param focusAffix? number @`nil` = consider both affixes when making the weights, `1` = focus on primary affix, `2` = focus on secondary affix
        local function getSortOrder(sortedDungeon, primaryAffixInternal, secondaryAffixInternal, focusAffix)
            local primaryOrder
            if focusAffix == nil or focusAffix == 1 then
                primaryOrder = getSortOrderForAffix(sortedDungeon, primaryAffixInternal)
                if focusAffix == 1 then
                    return format("%s-%s", primaryOrder, sortedDungeon.dungeon.shortNameLocale)
                end
            end
            local secondaryOrder
            if focusAffix == nil or focusAffix == 2 then
                secondaryOrder = getSortOrderForAffix(sortedDungeon, secondaryAffixInternal)
                if focusAffix == 2 then
                    return format("%s-%s", secondaryOrder, sortedDungeon.dungeon.shortNameLocale)
                end
            end
            return format("%s-%s-%s", primaryOrder, secondaryOrder, sortedDungeon.dungeon.shortNameLocale)
        end
        local sortedDungeonMetatable = {
            __metatable = false,
            __index = function(self, key)
                local index = self.dungeon.index
                local _, weeklyAffixInternal = util:GetWeeklyAffix()
                if key == "level" then
                    return results[weeklyAffixInternal .. "Dungeons"][index]
                elseif key == "chests" then
                    return results[weeklyAffixInternal .. "DungeonUpgrades"][index]
                elseif key == "fractionalTime" then
                    return results[weeklyAffixInternal .. "DungeonTimes"][index]
                elseif key == "fortifiedLevel" then
                    return results.fortifiedDungeons[index]
                elseif key == "fortifiedChests" then
                    return results.fortifiedDungeonUpgrades[index]
                elseif key == "fortifiedFractionalTime" then
                    return results.fortifiedDungeonTimes[index]
                elseif key == "tyrannicalLevel" then
                    return results.tyrannicalDungeons[index]
                elseif key == "tyrannicalChests" then
                    return results.tyrannicalDungeonUpgrades[index]
                elseif key == "tyrannicalFractionalTime" then
                    return results.tyrannicalDungeonTimes[index]
                elseif key == "sortOrder" then
                    return getSortOrder(self, weeklyAffixInternal, weeklyAffixInternal == "fortified" and "tyrannical" or "fortified")
                -- elseif key == "sortOrder1" then
                --     return getSortOrder(self, weeklyAffixInternal, weeklyAffixInternal == "fortified" and "tyrannical" or "fortified", 1)
                -- elseif key == "sortOrder2" then
                --     return getSortOrder(self, weeklyAffixInternal == "fortified" and "tyrannical" or "fortified", weeklyAffixInternal, 2)
                elseif key == "fortifiedSortOrder" then
                    return getSortOrder(self, "fortified", "tyrannical")
                -- elseif key == "fortifiedSortOrder1" then
                --     return getSortOrder(self, "fortified", "tyrannical", 1)
                -- elseif key == "fortifiedSortOrder2" then
                --     return getSortOrder(self, "fortified", "tyrannical", 2)
                elseif key == "tyrannicalSortOrder" then
                    return getSortOrder(self, "tyrannical", "fortified")
                -- elseif key == "tyrannicalSortOrder1" then
                --     return getSortOrder(self, "tyrannical", "fortified", 1)
                -- elseif key == "tyrannicalSortOrder2" then
                --     return getSortOrder(self, "tyrannical", "fortified", 2)
                end
            end,
        }
        results.sortedDungeons = {}
        local dungeonKey = "dungeons"
        local dungeonUpgradeKey = "dungeonUpgrades"
        local dungeonTimeKey = "dungeonTimes"
        if weeklyAffixInternal then
            dungeonKey = weeklyAffixInternal .. "Dungeons"
            dungeonUpgradeKey = weeklyAffixInternal .. "DungeonUpgrades"
            dungeonTimeKey = weeklyAffixInternal .. "DungeonTimes"
        end
        for i = 1, #DUNGEONS do
            local dungeon = DUNGEONS[i]
            if weeklyAffixInternal then
                results.sortedDungeons[i] = setmetatable({
                    dungeon = dungeon,
                    level = results[dungeonKey][i],
                    chests = results[dungeonUpgradeKey][dungeon.index],
                    fractionalTime = results[dungeonTimeKey][dungeon.index],
                }, sortedDungeonMetatable)
            else
                results.sortedDungeons[i] = setmetatable({
                    dungeon = dungeon,
                }, sortedDungeonMetatable)
            end
        end
        table.sort(results.sortedDungeons, SortDungeons)
    end

    ---@param results DataProviderMythicKeystoneProfile
    local function ApplySortedMilestonesForAffix(results, weeklyAffixInternal)
        results.sortedMilestones = {}
        if results.keystoneTwentyPlus > 0 then
            results.sortedMilestones[#results.sortedMilestones + 1] = {
                level = 20,
                label = L.TIMED_20_RUNS,
                text = results.keystoneTwentyPlus .. (results.keystoneTwentyPlus > 10 and "+" or "")
            }
        end
        if results.keystoneFifteenPlus > 0 then
            results.sortedMilestones[#results.sortedMilestones + 1] = {
                level = 15,
                label = L.TIMED_15_RUNS,
                text = results.keystoneFifteenPlus .. (results.keystoneFifteenPlus > 10 and "+" or "")
            }
        end
        if results.keystoneTenPlus > 0 then
            results.sortedMilestones[#results.sortedMilestones + 1] = {
                level = 10,
                label = L.TIMED_10_RUNS,
                text = results.keystoneTenPlus .. (results.keystoneTenPlus > 10 and "+" or "")
            }
        end
        if results.keystoneFivePlus > 0 then
            results.sortedMilestones[#results.sortedMilestones + 1] = {
                level = 5,
                label = L.TIMED_5_RUNS,
                text = results.keystoneFivePlus .. (results.keystoneFivePlus > 10 and "+" or "")
            }
        end
        results.mplusCurrent = {
            score = results.currentScore or 0,
            roles = ORDERED_ROLES[results.currentRoleOrdinalIndex] or ORDERED_ROLES[1]
        }
        results.mplusPrevious = {
            season = results.previousScoreSeason,
            score = results.previousScore or 0,
            roles = ORDERED_ROLES[results.previousRoleOrdinalIndex] or ORDERED_ROLES[1]
        }
        results.mplusMainCurrent = {
            score = results.mainCurrentScore or 0,
            roles = ORDERED_ROLES[results.mainCurrentRoleOrdinalIndex] or ORDERED_ROLES[1]
        }
        results.mplusMainPrevious = {
            season = results.mainPreviousScoreSeason,
            score = results.mainPreviousScore or 0,
            roles = ORDERED_ROLES[results.mainPreviousRoleOrdinalIndex] or ORDERED_ROLES[1]
        }
    end

    ---@param results DataProviderMythicKeystoneProfile
    local function ApplyClientDataToMythicKeystoneData(results, name, realm)
        if not CLIENT_CHARACTERS or not config:Get("enableClientEnhancements") then
            return
        end
        local nameAndRealm = name .. "-" .. realm
        local clientData = CLIENT_CHARACTERS[nameAndRealm]
        if not clientData then
            return
        end
        local keystoneData = clientData.mythic_keystone
        results.isEnhanced = true
        results.currentScore = keystoneData.all.score
        local maxDungeonIndex = 0
        local maxDungeonTime = 999
        local maxDungeonLevel = 0
        local maxDungeonScore = 0
        local maxDungeonUpgrades = 0
        for i = 1, #keystoneData.all.runs do
            local run = keystoneData.all.runs[i]
            results.dungeons[i] = run.level
            results.dungeonUpgrades[i] = run.upgrades
            results.dungeonTimes[i] = run.fraction
            if run.upgrades > 0 and (run.score > maxDungeonScore or (run.score == maxDungeonScore and run.fraction < maxDungeonTime)) then
                maxDungeonIndex = i
                maxDungeonTime = run.fraction
                maxDungeonLevel = run.level
                maxDungeonScore = run.score
                maxDungeonUpgrades = run.upgrades
            end
        end
        if maxDungeonIndex > 0 then
            results.maxDungeon = DUNGEONS[maxDungeonIndex]
            results.maxDungeonLevel = maxDungeonLevel
            results.maxDungeonUpgrades = maxDungeonUpgrades
        end
    end

    ---@param bucket table
    ---@param baseOffset number
    ---@param encodingOrder number[]
    ---@param providerOutdated number
    ---@param providerBlocked number
    ---@param name? string
    ---@param realm? string
    ---@param region? string
    local function UnpackMythicKeystoneData(bucket, baseOffset, encodingOrder, providerOutdated, providerBlocked, name, realm, region)
        ---@type DataProviderMythicKeystoneProfile
        local results = { outdated = providerOutdated, hasRenderableData = false }
        if providerBlocked then
            if name and util:IsUnitPlayer(name, realm, region) then
                results.softBlocked = providerBlocked
            else
                results.blocked = providerBlocked
                return results
            end
        end
        local bitOffset = (baseOffset - 1) * 8
        local value
        for encoderIndex = 1, #encodingOrder do
            local field = encodingOrder[encoderIndex]
            if field == ENCODER_MYTHICPLUS_FIELDS.CURRENT_SCORE then
                results.currentScore, bitOffset = ReadBitsFromString(bucket, bitOffset, 12)
                results.hasRenderableData = results.hasRenderableData or results.currentScore > 0
            elseif field == ENCODER_MYTHICPLUS_FIELDS.CURRENT_ROLES then
                value, bitOffset = ReadBitsFromString(bucket, bitOffset, 7)
                results.currentRoleOrdinalIndex = 1 + value -- indexes are one-based
            elseif field == ENCODER_MYTHICPLUS_FIELDS.PREVIOUS_SCORE then
                results.previousScore, bitOffset = ReadBitsFromString(bucket, bitOffset, 12)
                results.previousScoreSeason, bitOffset = ReadBitsFromString(bucket, bitOffset, 2)
                results.hasRenderableData = results.hasRenderableData or results.previousScore > 0
            elseif field == ENCODER_MYTHICPLUS_FIELDS.PREVIOUS_ROLES then
                value, bitOffset = ReadBitsFromString(bucket, bitOffset, 7)
                results.previousRoleOrdinalIndex = 1 + value -- indexes are one-based
            elseif field == ENCODER_MYTHICPLUS_FIELDS.MAIN_CURRENT_SCORE then
                results.mainCurrentScore, bitOffset = ReadBitsFromString(bucket, bitOffset, 12)
                results.hasRenderableData = results.hasRenderableData or results.mainCurrentScore > 0
            elseif field == ENCODER_MYTHICPLUS_FIELDS.MAIN_CURRENT_ROLES then
                value, bitOffset = ReadBitsFromString(bucket, bitOffset, 7)
                results.mainCurrentRoleOrdinalIndex = 1 + value -- indexes are one-based
            elseif field == ENCODER_MYTHICPLUS_FIELDS.MAIN_PREVIOUS_SCORE then
                value, bitOffset = ReadBitsFromString(bucket, bitOffset, 10)
                results.mainPreviousScore = 10 * value
                results.mainPreviousScoreSeason, bitOffset = ReadBitsFromString(bucket, bitOffset, 2)
                results.hasRenderableData = results.hasRenderableData or results.mainPreviousScore > 0
            elseif field == ENCODER_MYTHICPLUS_FIELDS.MAIN_PREVIOUS_ROLES then
                value, bitOffset = ReadBitsFromString(bucket, bitOffset, 7)
                results.mainPreviousRoleOrdinalIndex = 1 + value -- indexes are one-based
            elseif field == ENCODER_MYTHICPLUS_FIELDS.DUNGEON_RUN_COUNTS then
                value, bitOffset = ReadBitsFromString(bucket, bitOffset, 8)
                results.keystoneFivePlus = DecodeBits8(value)
                value, bitOffset = ReadBitsFromString(bucket, bitOffset, 8)
                results.keystoneTenPlus = DecodeBits8(value)
                value, bitOffset = ReadBitsFromString(bucket, bitOffset, 8)
                results.keystoneFifteenPlus = DecodeBits8(value)
                value, bitOffset = ReadBitsFromString(bucket, bitOffset, 8)
                results.keystoneTwentyPlus = DecodeBits8(value)
                results.hasRenderableData = results.hasRenderableData or results.keystoneFivePlus > 0 or results.keystoneTenPlus > 0 or results.keystoneFifteenPlus > 0 or results.keystoneTwentyPlus > 0
            elseif field == ENCODER_MYTHICPLUS_FIELDS.DUNGEON_LEVELS then
                bitOffset = ApplyWeeklyAffixForDungeons(results, bucket, bitOffset, "fortified")
                bitOffset = ApplyWeeklyAffixForDungeons(results, bucket, bitOffset, "tyrannical")
            elseif field == ENCODER_MYTHICPLUS_FIELDS.DUNGEON_BEST_INDEX then
                bitOffset = ApplyWeeklyAffixForDungeonBest(results, bucket, bitOffset, "fortified")
                bitOffset = ApplyWeeklyAffixForDungeonBest(results, bucket, bitOffset, "tyrannical")
            end
        end
        ApplyWeeklyAffixWrapper(results)
        ApplySortedDungeonsForAffix(results)
        ApplySortedMilestonesForAffix(results)
        -- ApplyClientDataToMythicKeystoneData(results, name, realm) -- TODO: weekly affix handling so we disable this until we know what kind of data we expect here
        return results
    end

    ---@class DataProviderRaidProgress
    ---@field public progressCount number
    ---@field public difficulty number
    ---@field public killsPerBoss number[]
    ---@field public raid DatabaseRaid

    ---@class DataProviderRaidProfile
    ---@field public outdated number|nil @number or nil
    ---@field public hasRenderableData boolean @True if we have any actual data to render in the tooltip without the profile appearing incomplete or empty.
    ---@field public progress DataProviderRaidProgress[]
    ---@field public mainProgress? DataProviderRaidProgress[]
    ---@field public previousProgress? DataProviderRaidProgress[]
    ---@field public sortedProgress SortedRaidProgress[]
    ---@field public raidProgress RaidProgress[]

    ---@class SortedRaidProgress
    ---@field public obsolete boolean If this evaluates truthy we hide it unless tooltip is expanded on purpose.
    ---@field public tier number Weighted number based on current or previous raid, difficulty and boss kill count.
    ---@field public isProgress boolean
    ---@field public isProgressPrev boolean
    ---@field public isMainProgress boolean
    ---@field public progress DataProviderRaidProgress

    ---@class RaidProgress
    ---@field public current boolean
    ---@field public raid DatabaseRaid
    ---@field public progress RaidProgressGroup[]
    ---@field public isMainProgress boolean

    ---@class RaidProgressGroup
    ---@field public difficulty number
    ---@field public progress RaidProgressBossInfo[]
    ---@field public kills number
    ---@field public cleared boolean
    ---@field public obsolete boolean

    ---@class RaidProgressBossInfo
    ---@field public difficulty number
    ---@field public index number
    ---@field public count number
    ---@field public killed boolean

    ---@class RaidProgressExtended
    ---@field public progress RaidProgress
    ---@field public focused boolean @`true` if the raid is focused due to LFD status or instance location, otherwise `false`.
    ---@field public fated? string @The fated `texture` if the raid is fated, otherwise `nil` if it's not. Requires to append `-small` or `-large` at the end of the atlas string for it to resolve into a proper texture.
    ---@field public show boolean @Dynamically assigned based on the situation. It's set to `true` to display the line in the tooltip, otherwise `false` to hide.

    ---@param a SortedRaidProgress
    ---@param b SortedRaidProgress
    local function SortRaidProgress(a, b)
        return a.tier < b.tier
    end

    ---@param a SortedRaidProgress
    ---@param b SortedRaidProgress
    local function SortRaidProgressMainLast(a, b)
        if a.isMainProgress == b.isMainProgress then
            return a.tier < b.tier
        end
        return not a.isMainProgress and b.isMainProgress
    end

    ---@param a RaidProgress
    ---@param b RaidProgress
    local function SortRaidProgressByOrdinal(a, b)
        return a.raid.ordinal < b.raid.ordinal
    end

    ---@param a RaidProgressGroup
    ---@param b RaidProgressGroup
    local function SortRaidProgressGroupByDifficulty(a, b)
        return a.difficulty < b.difficulty
    end

    ---@param results DataProviderRaidProfile
    ---@param provider DataProvider
    local function SummarizeRaidProgress(results, provider)
        local sortedProgress = results.sortedProgress
        local raidProgress = results.raidProgress
        ---@param isMainProgress boolean
        local function populateRaidProgress(isMainProgress)
            for raidsIndex, raids in ipairs({ provider.currentRaids, provider.previousRaids }) do
                local isCurrentRaid = raidsIndex == 1
                for i = 1, #raids do
                    local raid = raids[i]
                    ---@type RaidProgress
                    local raidProg = {
                        current = isCurrentRaid,
                        raid = raid,
                        progress = {},
                        isMainProgress = false,
                    }
                    local diffToIndexMap = {} ---@type number[]
                    local diffNextIndex = 1
                    ---@param difficulty number
                    ---@param index number
                    ---@param count number
                    local function appendBossInfo(difficulty, index, count)
                        ---@type RaidProgressBossInfo
                        local bossInfo = {
                            difficulty = difficulty,
                            index = index,
                            count = count,
                            killed = count > 0,
                        }
                        local diffIndex = diffToIndexMap[bossInfo.difficulty]
                        if not diffIndex then
                            diffIndex = diffNextIndex
                            diffNextIndex = diffNextIndex + 1
                            diffToIndexMap[bossInfo.difficulty] = diffIndex
                        end
                        local diffGroup = raidProg.progress[diffIndex]
                        if not diffGroup then
                            ---@type RaidProgressGroup
                            diffGroup = {
                                difficulty = difficulty,
                                progress = {},
                            }
                            raidProg.progress[diffIndex] = diffGroup
                        end
                        diffGroup.progress[#diffGroup.progress + 1] = bossInfo
                    end
                    for j = 1, #sortedProgress do
                        local prog = sortedProgress[j]
                        local progProgress = prog.progress
                        if progProgress.raid == raid and (not not isMainProgress == not not prog.isMainProgress) and (isMainProgress or ((isCurrentRaid and prog.isProgress) or (not isCurrentRaid and prog.isProgressPrev))) then
                            if prog.isMainProgress then
                                raidProg.isMainProgress = true
                            end
                            if progProgress.killsPerBoss then
                                for k = 1, #progProgress.killsPerBoss do
                                    local killsPerBoss = progProgress.killsPerBoss[k]
                                    appendBossInfo(progProgress.difficulty, k, killsPerBoss)
                                end
                            else
                                for k = 1, progProgress.raid.bossCount do
                                    local killsPerBoss = progProgress.progressCount >= k and 1 or 0
                                    appendBossInfo(progProgress.difficulty, k, killsPerBoss)
                                end
                            end
                        end
                    end
                    if raidProg.progress[2] then
                        table.sort(raidProg.progress, SortRaidProgressGroupByDifficulty)
                    end
                    for j = #raidProg.progress, 1, -1 do
                        local group = raidProg.progress[j]
                        local bossKills = 0
                        for _, bossInfo in ipairs(group.progress) do
                            if bossInfo.killed then
                                bossKills = bossKills + 1
                            end
                        end
                        group.kills = bossKills
                        group.cleared = bossKills == raidProg.raid.bossCount
                        local nextGroup = raidProg.progress[j + 1]
                        group.obsolete = not not (nextGroup and (nextGroup.obsolete or nextGroup.cleared))
                    end
                    if raidProg.progress[1] then
                        raidProgress[#raidProgress + 1] = raidProg
                    end
                end
            end
        end
        populateRaidProgress(false)
        populateRaidProgress(true)
        if raidProgress[2] then
            table.sort(raidProgress, SortRaidProgressByOrdinal)
        end
    end

    ---@param bucket table
    ---@param raid DatabaseRaid
    ---@param offset number
    ---@param results DataProviderRaidProfile
    ---@param field "mainProgress"|"previousProgress"|"progress"
    local function UnpackSummaryRaidProgress(bucket, raid, offset, results, field)
        local prog = { raid = raid } ---@type DataProviderRaidProgress
        local bitOffset = offset
        prog.difficulty, bitOffset = ReadBitsFromString(bucket, bitOffset, 2)
        prog.progressCount, bitOffset = ReadBitsFromString(bucket, bitOffset, 4)
        if prog.progressCount > 0 then
            local temp = results[field]
            if not temp then
                temp = {}
                results[field] = temp
            end
            temp[#temp + 1] = prog
        end
        return bitOffset
    end

    ---@param bucket table
    ---@param raid DatabaseRaid
    ---@param offset number
    ---@param results DataProviderRaidProfile
    local function UnpackFullRaidProgress(bucket, raid, offset, results)
        local prog = { raid = raid, progressCount = 0 } ---@type DataProviderRaidProgress
        local bitOffset = offset
        local value
        prog.difficulty, bitOffset = ReadBitsFromString(bucket, bitOffset, 2)
        prog.killsPerBoss = {}
        for i = 1, raid.bossCount do
            value, bitOffset = ReadBitsFromString(bucket, bitOffset, 2)
            prog.killsPerBoss[i] = DecodeBits2(value)
            if prog.killsPerBoss[i] > 0 then
                prog.progressCount = prog.progressCount + 1
            end
        end
        if prog.progressCount > 0 then
            results.progress[#results.progress + 1] = prog
        end
        return bitOffset
    end

    ---@param bucket table
    ---@param baseOffset number
    ---@param provider DataProvider
    local function UnpackRaidData(bucket, baseOffset, provider)
        local encodingOrder = provider.encodingOrder
        local bitOffset = (baseOffset - 1) * 8
        ---@type DataProviderRaidProfile
        local results = {
            outdated = provider.outdated,
            progress = {},
            previousProgress = nil,
            mainProgress = nil,
            sortedProgress = {},
            raidProgress = {},
            hasRenderableData = false
        }
        local value
        local numCurrentRaids = #provider.currentRaids
        local numPreviousRaids = #provider.previousRaids
        for encoderIndex = 1, #encodingOrder do
            local field = encodingOrder[encoderIndex]
            if field == ENCODER_RAIDING_FIELDS.CURRENT_FULL_PROGRESS then
                for raidIndex = 1, numCurrentRaids do
                    for i = 1, 2 do
                        bitOffset = UnpackFullRaidProgress(bucket, provider.currentRaids[raidIndex], bitOffset, results)
                    end
                end
            elseif field == ENCODER_RAIDING_FIELDS.PREVIOUS_FULL_PROGRESS then
                for raidIndex = 1, numPreviousRaids do
                    bitOffset = UnpackFullRaidProgress(bucket, provider.previousRaids[raidIndex], bitOffset, results)
                end
            elseif field == ENCODER_RAIDING_FIELDS.PREVIOUS_SUMMARY_PROGRESS then
                for raidIndex = 1, numPreviousRaids do
                    local previousRaid = provider.previousRaids[raidIndex]
                    for i = 1, 2 do
                        bitOffset = UnpackSummaryRaidProgress(bucket, previousRaid, bitOffset, results, "previousProgress")
                    end
                end
            elseif field == ENCODER_RAIDING_FIELDS.MAINS_CURRENT_SUMMARY_PROGRESS then
                for raidIndex = 1, numCurrentRaids do
                    local currentRaid = provider.currentRaids[raidIndex]
                    for i = 1, 2 do
                        bitOffset = UnpackSummaryRaidProgress(bucket, currentRaid, bitOffset, results, "mainProgress")
                    end
                end
            end
        end
        if results.progress then
            for i = 1, #results.progress do
                local prog = results.progress[i]
                results.sortedProgress[#results.sortedProgress + 1] = {
                    tier = 1000000 + prog.raid.ordinal * 10000 + (3 - prog.difficulty) * 100 + (99 - prog.progressCount),
                    progress = prog,
                    isProgress = true
                }
            end
        end
        if results.mainProgress then
            for i = 1, #results.mainProgress do
                local prog = results.mainProgress[i]
                results.sortedProgress[#results.sortedProgress + 1] = {
                    tier = 1000000 + prog.raid.ordinal * 10000 + (3 - prog.difficulty) * 100 + (99 - prog.progressCount),
                    progress = prog,
                    isMainProgress = true
                }
            end
        end
        if results.previousProgress then
            for i = 1, #results.previousProgress do
                local prog = results.previousProgress[i]
                results.sortedProgress[#results.sortedProgress + 1] = {
                    tier = 2000000 + prog.raid.ordinal * 10000 + (3 - prog.difficulty) * 100 + (99 - prog.progressCount),
                    progress = prog,
                    isProgressPrev = true
                }
            end
        end
        table.sort(results.sortedProgress, SortRaidProgress)
        for i = 2, #results.sortedProgress do
            local prog = results.sortedProgress[i]
            local prevProg = results.sortedProgress[i - 1]
            if prevProg.obsolete then
                prog.obsolete = true
            elseif prog.progress.raid == prevProg.progress.raid then
                if prevProg.progress.difficulty >= prog.progress.difficulty and prevProg.progress.progressCount >= prog.progress.progressCount then
                    prog.obsolete = true
                end
            elseif prog.tier > prevProg.tier then
                if prevProg.progress.progressCount > 0 then
                    prog.obsolete = true
                end
            end
        end
        table.sort(results.sortedProgress, SortRaidProgressMainLast)
        if results.sortedProgress[1] then
            results.sortedProgress[1].obsolete = false
        end
        for i = 1, #results.sortedProgress do
            local prog = results.sortedProgress[i]
            if not prog.obsolete and prog.progress.progressCount > 0 then
                results.hasRenderableData = true
                break
            end
        end
        SummarizeRaidProgress(results, provider)
        return results
    end

    ---@class DataProviderRecruitmentProfile
    ---@field public outdated number|nil @number or nil
    ---@field public hasRenderableData boolean @True if we have any actual data to render in the tooltip without the profile appearing incomplete or empty.
    ---@field public titleIndex number
    ---@field public title RecruitmentTitle
    ---@field public entityType number @`0` (character), `1` (guild), `2` (team) - use `ns.RECRUITMENT_ENTITY_TYPES` for lookups
    ---@field public tank? boolean
    ---@field public healer? boolean
    ---@field public dps? boolean

    local RECRUITMENT_TITLES = ns:GetRecruitmentTitles()

    ---@param provider DataProvider
    local function UnpackRecruitmentData(bucket, baseOffset, provider)
        ---@type DataProviderRecruitmentProfile
        local results = { outdated = provider.outdated, hasRenderableData = false }
        local encodingOrder = provider.encodingOrder
        local bitOffset = (baseOffset - 1) * 8
        local value
        for encoderIndex = 1, #encodingOrder do
            local field = encodingOrder[encoderIndex]
            if field == ENCODER_RECRUITMENT_FIELDS.TITLE then
                value, bitOffset = ReadBitsFromString(bucket, bitOffset, 8)
                results.titleIndex = value
                results.title = value and RECRUITMENT_TITLES[value]
            elseif field == ENCODER_RECRUITMENT_FIELDS.ENTITY_TYPE then
                value, bitOffset = ReadBitsFromString(bucket, bitOffset, 2)
                results.entityType = value
            elseif field == ENCODER_RECRUITMENT_FIELDS.ROLES then
                value, bitOffset = ReadBitsFromString(bucket, bitOffset, 3)
                results.dps = band(value, ENCODER_RECRUITMENT_ROLES.dps) == ENCODER_RECRUITMENT_ROLES.dps
                results.healer = band(value, ENCODER_RECRUITMENT_ROLES.healer) == ENCODER_RECRUITMENT_ROLES.healer
                results.tank = band(value, ENCODER_RECRUITMENT_ROLES.tank) == ENCODER_RECRUITMENT_ROLES.tank
            end
        end
        results.hasRenderableData = results.title and results.entityType and true or false
        return results
    end

    ---@class DataProviderPvpProfile
    ---@field public outdated number|nil @number or nil
    ---@field public hasRenderableData boolean @True if we have any actual data to render in the tooltip without the profile appearing incomplete or empty.

    ---@param provider DataProvider
    local function UnpackPvpData(bucket, baseOffset, provider)
        ---@type DataProviderPvpProfile
        local results = { outdated = provider.outdated, hasRenderableData = false }
        -- TODO: NYI
        return results
    end

    ---@class DataProviderCharacterProfile
    ---@field public success boolean
    ---@field public guid string @Unique string `region faction realm name`
    ---@field public name string
    ---@field public realm string
    ---@field public faction number
    ---@field public region string
    ---@field public mythicKeystoneProfile DataProviderMythicKeystoneProfile
    ---@field public raidProfile DataProviderRaidProfile
    ---@field public recruitmentProfile DataProviderRecruitmentProfile
    ---@field public pvpProfile DataProviderPvpProfile

    -- cache mythic keystone profiles for re-use after first query
    ---@type DataProviderMythicKeystoneProfile[]
    local mythicKeystoneProfileCache = {}

    -- cache raid profiles for re-use after first query
    ---@type DataProviderRaidProfile[]
    local raidProfileCache = {}

    -- cache recruitment profiles for re-use after first query
    ---@type DataProviderRecruitmentProfile[]
    local recruitmentProfileCache = {}

    -- cache pvp profiles for re-use after first query
    ---@type DataProviderPvpProfile[]
    local pvpProfileCache = {}

    -- cache profiles for re-use after first query
    ---@type DataProviderCharacterProfile[]
    local profileCache = {}

    ---@param provider DataProvider
    local function GetMythicKeystoneProfile(provider, ...)
        if provider.blockedPurged then
            local _, _, name, realm = ...
            local guid = provider.data .. ":" .. provider.region .. ":-1:-1:blockedPurged"
            local cache = mythicKeystoneProfileCache[guid]
            if cache then
                return cache
            end
            local profile = UnpackMythicKeystoneData(nil, nil, nil, true, true, name, realm, provider.region) ---@diagnostic disable-line: param-type-mismatch
            profile.blockedPurged = true
            mythicKeystoneProfileCache[guid] = profile
            return profile
        end
        local bucket, baseOffset, guid, name, realm = SearchForBucketByName(provider, ...)
        if not bucket or not baseOffset or not guid then
            return
        end
        local cache = mythicKeystoneProfileCache[guid]
        if cache then
            return cache
        end
        local profile = UnpackMythicKeystoneData(bucket, baseOffset, provider.encodingOrder, provider.outdated, provider.blocked, name, realm, provider.region)
        mythicKeystoneProfileCache[guid] = profile
        return profile
    end

    ---@param provider DataProvider
    local function GetRaidProfile(provider, ...)
        local bucket, baseOffset, guid = SearchForBucketByName(provider, ...)
        if not bucket or not baseOffset or not guid then
            return
        end
        local cache = raidProfileCache[guid]
        if cache then
            return cache
        end
        local profile = UnpackRaidData(bucket, baseOffset, provider)
        raidProfileCache[guid] = profile
        return profile
    end

    ---@param provider DataProvider
    local function GetRecruitmentProfile(provider, ...)
        local bucket, baseOffset, guid = SearchForBucketByName(provider, ...)
        if not bucket or not baseOffset or not guid then
            return
        end
        local cache = recruitmentProfileCache[guid]
        if cache then
            return cache
        end
        local profile = UnpackRecruitmentData(bucket, baseOffset, provider)
        recruitmentProfileCache[guid] = profile
        return profile
    end

    ---@param provider DataProvider
    local function GetPvpProfile(provider, ...)
        local bucket, baseOffset, guid = SearchForBucketByName(provider, ...)
        if not bucket or not baseOffset or not guid then
            return
        end
        local cache = pvpProfileCache[guid]
        if cache then
            return cache
        end
        local profile = UnpackPvpData(bucket, baseOffset, provider)
        pvpProfileCache[guid] = profile
        return profile
    end

    local function CreateEmptyMythicKeystoneData()
        ---@type DataProviderMythicKeystoneProfile
        local results = {
            currentScore = 0,
            mplusCurrent = {
                score = 0,
                roles = {}
            },
            mplusPrevious = {
                score = 0,
                roles = {}
            },
            mplusMainCurrent = {
                score = 0,
                roles = {}
            },
            mplusMainPrevious = {
                score = 0,
                roles = {}
            },
            fortifiedDungeons = {},
            fortifiedDungeonUpgrades = {},
            fortifiedDungeonTimes = {},
            fortifiedMaxDungeonIndex = 1,
            fortifiedMaxDungeonLevel = 0,
            fortifiedMaxDungeon = nil,
            fortifiedMaxDungeonUpgrades = 0,
            tyrannicalDungeons = {},
            tyrannicalDungeonUpgrades = {},
            tyrannicalDungeonTimes = {},
            tyrannicalMaxDungeonIndex = 1,
            tyrannicalMaxDungeonLevel = 0,
            tyrannicalMaxDungeon = nil,
            tyrannicalMaxDungeonUpgrades = 0,
            sortedMilestones = {}
        }
        ApplyWeeklyAffixWrapper(results)
        for i = 1, #DUNGEONS do
            results.fortifiedDungeons[i] = 0
            results.fortifiedDungeonUpgrades[i] = 0
            results.fortifiedDungeonTimes[i] = 999
            results.tyrannicalDungeons[i] = 0
            results.tyrannicalDungeonUpgrades[i] = 0
            results.tyrannicalDungeonTimes[i] = 999
        end
        ApplySortedDungeonsForAffix(results)
        return results
    end

    ---@class BlizzardKeystoneAffixInfo
    ---@field public name string @Affix name.
    ---@field public level number @Run keystone level.
    ---@field public score number @Score earned from keystone.
    ---@field public overTime boolean @Is the run depleted?
    ---@field public durationSec number @Run duration in seconds.

    ---@class BlizzardKeystoneRun
    ---@field public bestRunDurationMS number @Timer in milliseconds
    ---@field public bestRunLevel number @Keystone level
    ---@field public challengeModeID number @Keystone instance ID
    ---@field public finishedSuccess boolean @If the run was timed or not
    ---@field public mapScore number @The score worth for the run
    ---@field public fortified BlizzardKeystoneAffixInfo @Fortified affix data. Only accessible for the players own profile override.
    ---@field public tyrannical BlizzardKeystoneAffixInfo @Tyrannical affix data. Only accessible for the players own profile override.

    -- override or inject cache entry for tooltip rendering for this character with their BIO score and keystune run data
    ---@param name string @Character name
    ---@param realm string @Realm name
    ---@param overallScore number @BIO score directly from the game.
    ---@param keystoneRuns? BlizzardKeystoneRun[] @BIO runs directly from the game.
    function provider:OverrideProfile(name, realm, overallScore, keystoneRuns)
        if type(name) ~= "string" or type(realm) ~= "string" or (type(overallScore) ~= "number" and type(keystoneRuns) ~= "table") then
            return
        end
        local region = ns.PLAYER_REGION
        local guid = region .. " " .. realm .. " " .. name
        local cache = provider:GetProfile(name, realm, region)
        local mythicKeystoneProfile
        if cache and cache.success and cache.mythicKeystoneProfile and not cache.mythicKeystoneProfile.blocked and cache.mythicKeystoneProfile.hasRenderableData then
            mythicKeystoneProfile = cache.mythicKeystoneProfile
        end
        if not mythicKeystoneProfile then
            mythicKeystoneProfile = CreateEmptyMythicKeystoneData()
        end
        if type(overallScore) == "number" and overallScore > 0 and overallScore > mythicKeystoneProfile.currentScore then
            if not mythicKeystoneProfile.hasOverrideScore then
                mythicKeystoneProfile.hasOverrideScore = true
                mythicKeystoneProfile.originalCurrentScore = mythicKeystoneProfile.currentScore
                mythicKeystoneProfile.mplusCurrent.originalScore = mythicKeystoneProfile.mplusCurrent.score
            end
            mythicKeystoneProfile.currentScore = overallScore
            mythicKeystoneProfile.mplusCurrent.score = overallScore
        end
        if type(keystoneRuns) == "table" and keystoneRuns[1] then
            local isPlayer = util:IsUnitPlayer(name, realm)
            local _, realWeeklyAffixInternal = util:GetWeeklyAffix()
            local weeklyAffixInternals = { realWeeklyAffixInternal }
            if isPlayer then
                weeklyAffixInternals[1] = "fortified"
                weeklyAffixInternals[2] = "tyrannical"
            end
            for _, weeklyAffixInternal in pairs(weeklyAffixInternals) do
                local weekDungeons = mythicKeystoneProfile[weeklyAffixInternal .. "Dungeons"] ---@type number[]
                local weekDungeonUpgrades = mythicKeystoneProfile[weeklyAffixInternal .. "DungeonUpgrades"] ---@type number[]
                local weekDungeonTimes = mythicKeystoneProfile[weeklyAffixInternal .. "DungeonTimes"] ---@type number[]
                local maxDungeonIndex = 0
                -- local maxDungeonTime = 999
                -- local maxDungeonScore = 0
                local maxDungeonLevel = 0
                local maxDungeonUpgrades = 0
                local maxDungeonRunTimer = 2
                local needsMaxDungeonUpgrade
                for i = 1, #keystoneRuns do
                    local run = keystoneRuns[i]
                    local runAffixData = run[weeklyAffixInternal] ---@type BlizzardKeystoneAffixInfo
                    local dungeonIndex ---@type number|nil
                    local dungeon ---@type Dungeon|nil
                    for j = 1, #DUNGEONS do
                        dungeon = DUNGEONS[j]
                        if dungeon.keystone_instance == run.challengeModeID then
                            dungeonIndex = j
                            break
                        end
                        dungeon = nil
                    end
                    if dungeonIndex and (not isPlayer or runAffixData) then
                        local runBestRunLevel = run.bestRunLevel
                        local runBestRunDurationMS = run.bestRunDurationMS
                        local runFinishedSuccess = run.finishedSuccess
                        -- local runMapScore = run.mapScore
                        if runAffixData then
                            runBestRunLevel = runAffixData.level
                            runBestRunDurationMS = runAffixData.durationSec * 1000
                            runFinishedSuccess = not runAffixData.overTime
                        end
                        if dungeonIndex and weekDungeons[dungeonIndex] <= runBestRunLevel then
                            mythicKeystoneProfile.hasOverrideDungeonRuns = true
                            local _, _, dungeonTimeLimit = C_ChallengeMode.GetMapUIInfo(run.challengeModeID)
                            local goldTimeLimit, silverTimeLimit, bronzeTimeLimit = -1, -1, dungeonTimeLimit
                            if dungeon and dungeon.timers then
                                goldTimeLimit, silverTimeLimit, bronzeTimeLimit = dungeon.timers[1], dungeon.timers[2], dungeonTimeLimit or dungeon.timers[3] -- TODO: always prefer the game data time limit for bronze or the addons time limit?
                            end
                            local runSeconds = runBestRunDurationMS / 1000
                            local runNumUpgrades = 0
                            if runFinishedSuccess then
                                runNumUpgrades = 1
                                if runSeconds <= goldTimeLimit then
                                    runNumUpgrades = 3
                                elseif runSeconds <= silverTimeLimit then
                                    runNumUpgrades = 2
                                end
                            end
                            local runTimerAsFraction = runSeconds / (dungeonTimeLimit and dungeonTimeLimit > 0 and dungeonTimeLimit or 1) -- convert game timer to a fraction (1 or below is timed, above is depleted)
                            local fractionalTime = runFinishedSuccess and (mythicKeystoneProfile.isEnhanced and runTimerAsFraction or (3 - runNumUpgrades)) or 3 -- the data here depends if we are using client enhanced data or not
                            needsMaxDungeonUpgrade = true
                            weekDungeons[dungeonIndex] = runBestRunLevel
                            weekDungeonUpgrades[dungeonIndex] = runNumUpgrades
                            weekDungeonTimes[dungeonIndex] = fractionalTime
                            -- if runNumUpgrades > 0 and (runMapScore > maxDungeonScore or (runMapScore == maxDungeonScore and fractionalTime < maxDungeonTime)) then
                            if runNumUpgrades > 0 and (runBestRunLevel > maxDungeonLevel or (runBestRunLevel == maxDungeonLevel and runTimerAsFraction < maxDungeonRunTimer)) then
                                maxDungeonIndex = dungeonIndex
                                -- maxDungeonTime = fractionalTime
                                -- maxDungeonScore = runMapScore
                                maxDungeonLevel = runBestRunLevel
                                maxDungeonUpgrades = runNumUpgrades
                                maxDungeonRunTimer = runTimerAsFraction
                            end
                        end
                    end
                end
                if needsMaxDungeonUpgrade then
                    mythicKeystoneProfile[weeklyAffixInternal .. "MaxDungeon"] = DUNGEONS[maxDungeonIndex]
                    mythicKeystoneProfile[weeklyAffixInternal .. "MaxDungeonLevel"] = maxDungeonLevel
                    mythicKeystoneProfile[weeklyAffixInternal .. "MaxDungeonIndex"] = maxDungeonIndex
                    mythicKeystoneProfile[weeklyAffixInternal .. "MaxDungeonUpgrades"] = maxDungeonUpgrades
                end
            end
            table.sort(mythicKeystoneProfile.sortedDungeons, SortDungeons)
        end
        if mythicKeystoneProfile.hasOverrideScore or mythicKeystoneProfile.hasOverrideDungeonRuns then
            mythicKeystoneProfile.blocked = nil
            mythicKeystoneProfile.blockedPurged = nil
            mythicKeystoneProfile.softBlocked = nil
            mythicKeystoneProfile.outdated = nil
            mythicKeystoneProfile.hasRenderableData = true
        end
        if not cache then
            cache = {
                guid = guid,
                name = name,
                realm = realm,
                region = region
            }
        end
        cache.success = true
        cache.mythicKeystoneProfile = mythicKeystoneProfile
        profileCache[guid] = cache
        return cache
    end

    ---@param name string
    ---@param realm string
    ---@param region? string @Optional, will use players own region if ommited. Include to avoid ambiguity during debug mode.
    ---@return DataProviderCharacterProfile? @Return value is nil if not found
    function provider:GetProfile(name, realm, region)
        if type(name) ~= "string" or type(realm) ~= "string" then
            return
        end
        region = region or ns.PLAYER_REGION
        local guid = region .. " " .. realm .. " " .. name
        local cache = profileCache[guid]
        if cache then
            if not cache.success then
                return
            end
            return cache
        end
        local mythicKeystoneProfile ---@type DataProviderMythicKeystoneProfile|nil
        local raidProfile ---@type DataProviderRaidProfile|nil
        local recruitmentProfile ---@type DataProviderRecruitmentProfile|nil
        local pvpProfile ---@type DataProviderPvpProfile|nil
        for i = 1, #providers do
            local provider = providers[i]
            if provider.region == region then
                local lookup = provider.lookup
                local data = provider.db
                if lookup and data then
                    if provider.data == ns.PROVIDER_DATA_TYPE.MythicKeystone then
                        if provider.blockedPurged then
                            local tempMythicKeystoneProfile = GetMythicKeystoneProfile(provider, lookup, data, name, realm)
                            if tempMythicKeystoneProfile and (not mythicKeystoneProfile or mythicKeystoneProfile.blockedPurged) then
                                mythicKeystoneProfile = tempMythicKeystoneProfile
                            end
                        elseif not mythicKeystoneProfile then
                            mythicKeystoneProfile = GetMythicKeystoneProfile(provider, lookup, data, name, realm)
                        end
                    elseif provider.data == ns.PROVIDER_DATA_TYPE.Raid then
                        if not raidProfile then
                            raidProfile = GetRaidProfile(provider, lookup, data, name, realm)
                        end
                    elseif provider.data == ns.PROVIDER_DATA_TYPE.Recruitment then
                        if not recruitmentProfile then
                            recruitmentProfile = GetRecruitmentProfile(provider, lookup, data, name, realm)
                        end
                    elseif provider.data == ns.PROVIDER_DATA_TYPE.PvP then
                        if not pvpProfile then
                            pvpProfile = GetPvpProfile(provider, lookup, data, name, realm)
                        end
                    end
                    if mythicKeystoneProfile and raidProfile and pvpProfile then
                        break
                    end
                end
            end
        end
        if mythicKeystoneProfile and (not mythicKeystoneProfile.hasRenderableData and mythicKeystoneProfile.blocked) and not raidProfile and not recruitmentProfile and not pvpProfile then -- TODO: if we don't use blockedPurged functionality we have to then purge when the data is blocked and no rendering is available instead of checking the blockedPurged property
            mythicKeystoneProfile = nil
        end
        cache = {
            success = (mythicKeystoneProfile or raidProfile or recruitmentProfile or pvpProfile) and true or false,
            guid = guid,
            name = name,
            realm = realm,
            region = region,
            mythicKeystoneProfile = mythicKeystoneProfile,
            raidProfile = raidProfile,
            recruitmentProfile = recruitmentProfile,
            pvpProfile = pvpProfile
        }
        profileCache[guid] = cache
        if not cache.success then
            _G.RaiderIO_MissingCharacters[format("%s-%s-%s", ns.PLAYER_REGION, name, util:GetRealmSlug(realm, true))] = true
            return
        end
        return cache
    end

    ---@param bioSummary MythicPlusRatingSummary
    local function ExpandSummaryWithChallengeModeMapData(bioSummary)
        local mapIDs = C_ChallengeMode.GetMapTable()
        for _, mapID in ipairs(mapIDs) do
            local affixScores, bestOverAllScore
            local mapRun ---@type MythicPlusRatingMapSummary
            for _, run in ipairs(bioSummary.runs) do
                if mapID == run.challengeModeID then
                    affixScores, bestOverAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID)
                    mapRun = run
                    break
                end
            end
            if affixScores and mapRun then
                for _, data in pairs(affixScores) do
                    if data.name == "Fortified" then
                        mapRun.fortified = data
                    elseif data.name == "Tyrannical" then
                        mapRun.tyrannical = data
                    end
                end
            end
        end
    end

    local function OverridePlayerData()
        local bioSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player") ---@type MythicPlusRatingSummary
        if bioSummary and bioSummary.currentSeasonScore then
            ExpandSummaryWithChallengeModeMapData(bioSummary)
            provider:OverrideProfile(ns.PLAYER_NAME, ns.PLAYER_REALM, bioSummary.currentSeasonScore, bioSummary.runs)
        end
    end

    local function OnPlayerEnteringWorld()
        table.wipe(mythicKeystoneProfileCache)
        table.wipe(raidProfileCache)
        table.wipe(pvpProfileCache)
        table.wipe(profileCache)
        OverridePlayerData()
    end

    callback:RegisterEvent(OnPlayerEnteringWorld, "PLAYER_ENTERING_WORLD")
    callback:RegisterEvent(OverridePlayerData, "CHALLENGE_MODE_MAPS_UPDATE", "MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")

    function provider:WipeCache()
        OnPlayerEnteringWorld()
    end

end

-- loader.lua (internal)
-- dependencies: module, callback, config, util
do

    local callback = ns:GetModule("Callback") ---@type CallbackModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule

    local loadingAgainSoon
    local LoadModules

    function LoadModules()
        local modules = ns:GetModules()
        local numLoaded = 0
        local numPending = 0
        for _, module in ipairs(modules) do
            if not module:IsLoaded() and module:CanLoad() then
                if module:HasDependencies() then
                    numLoaded = numLoaded + 1
                    module:Load()
                else
                    numPending = numPending + 1
                end
            end
        end
        if not loadingAgainSoon and numLoaded > 0 and numPending > 0 then
            loadingAgainSoon = true
            C_Timer.After(1, function()
                loadingAgainSoon = false
                LoadModules()
            end)
        end
    end

    local function OnPlayerLogin()
        ns.PLAYER_REGION, ns.PLAYER_REGION_ID = util:GetRegion() ---@diagnostic disable-line: assign-type-mismatch
        ns.PLAYER_FACTION, ns.PLAYER_FACTION_TEXT = util:GetFaction("player") ---@diagnostic disable-line: assign-type-mismatch
        ns.PLAYER_NAME, ns.PLAYER_REALM = util:GetNameRealm("player")
        ns.PLAYER_REALM_SLUG = util:GetRealmSlug(ns.PLAYER_REALM)
        _G.RaiderIO_LastCharacter = format("%s-%s-%s", ns.PLAYER_REGION, ns.PLAYER_NAME, ns.PLAYER_REALM_SLUG or ns.PLAYER_REALM)
        _G.RaiderIO_MissingCharacters = {}
        _G.RaiderIO_MissingServers = {}
        if type(_G.RaiderIO_RWF) ~= "table" then _G.RaiderIO_RWF = {} end
        callback:SendEvent("RAIDERIO_PLAYER_LOGIN")
        LoadModules()
    end

    local function OnAddOnLoaded(_, name)
        if name == addonName then
            config.SavedVariablesLoaded = true
        end
        LoadModules()
        if name == addonName then
            if not IsLoggedIn() then
                callback:RegisterEventOnce(OnPlayerLogin, "PLAYER_LOGIN")
            else
                OnPlayerLogin()
            end
        end
    end

    callback:RegisterEvent(OnAddOnLoaded, "ADDON_LOADED")

    local function OnExpansionChanged()
        ns.EXPANSION = max(GetServerExpansionLevel(), GetMinimumExpansionLevel(), GetExpansionLevel()) - 1
        ns.MAX_LEVEL = GetMaxLevelForExpansionLevel(ns.EXPANSION)
    end

    callback:RegisterEvent(OnExpansionChanged, "UPDATE_EXPANSION_LEVEL")

    -- HOTFIX: at the time of writing there was no event associated with GetServerExpansionLevel() so this delays the update at login to happen when data is loaded after a cold-boot
    C_Timer.After(1, OnExpansionChanged)

end

-- render.lua
-- dependencies: module, callback, config, util, provider
do

    ---@class RenderModule : Module
    local render = ns:NewModule("Render") ---@type RenderModule
    local callback = ns:GetModule("Callback") ---@type CallbackModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule
    local provider = ns:GetModule("Provider") ---@type ProviderModule

    ---@return string, string, string, number, number, table, string @Always call as `render.GetQuery(...)`. Returns the following args: unit, name, realm, faction, options, args
    function render.GetQuery(...)
        local arg1, arg2, arg3, arg4, arg5, arg6 = ...
        local name, realm, unit = util:GetNameRealm(arg1, arg2)
        local faction, options, args, region
        if not faction and type(arg2) == "number" then
            if arg2 < 4 then
                faction = arg2
            end
        end
        if not faction and type(arg3) == "number" then
            if arg3 < 4 then
                faction = arg3
            end
        end
        if not options and type(arg2) == "number" then
            if arg2 > 3 then
                options = arg2
            end
        end
        if not options and type(arg3) == "number" then
            if arg3 > 3 then
                options = arg3
            end
        end
        if not options and type(arg4) == "number" then
            if arg4 > 3 then
                options = arg4
            end
        end
        if not args and type(arg2) == "table" then
            args = arg2
        end
        if not args and type(arg3) == "table" then
            args = arg3
        end
        if not args and type(arg4) == "table" then
            args = arg4
        end
        if not args and type(arg5) == "table" then
            args = arg5
        end
        if not region and type(arg3) == "string" then
            region = arg3
        end
        if not region and type(arg4) == "string" then
            region = arg4
        end
        if not region and type(arg5) == "string" then
            region = arg5
        end
        if not region and type(arg6) == "string" then
            region = arg6
        end
        return unit, name, realm, faction, options, args, region
    end

    render.Flags = {
        -- modifier states
        MOD = 4,
        MOD_STICKY = 8,
        -- data types to include
        MYTHIC_KEYSTONE = 16,
        RAID = 32,
        -- tooltip types
        UNIT_TOOLTIP = 64,
        PROFILE_TOOLTIP = 128,
        KEYSTONE_TOOLTIP = 256,
        -- additional visual tweaks
        SHOW_PADDING = 512,
        SHOW_HEADER = 1024,
        SHOW_FOOTER = 2048,
        SHOW_NAME = 4096,
        SHOW_LFD = 8192,
        -- ignore modifier state logic processing
        IGNORE_MOD = 16384
    }

    ---@class RenderPreset
    ---@field public Unit function @for use when drawing unit tooltip. automatically evaluates the modifier flag.
    ---@field public Profile function @for use when drawing a complete profile tooltip. automatically evaluates the modifier flag.
    ---@field public Keystone function @for use when drawing a keystone tooltip. automatically evaluates the modifier flag.
    ---@field public UnitNoPadding function @same as Unit, but also removes the padding flag.
    ---@field public UnitSmartPadding function @same as Unit, but if arg1 is set, padding flag is added, otherwise removed.

    ---@type RenderPreset
    render.Preset = {
        Unit = bor(render.Flags.MYTHIC_KEYSTONE, render.Flags.RAID, render.Flags.UNIT_TOOLTIP, render.Flags.SHOW_PADDING, render.Flags.SHOW_HEADER, render.Flags.SHOW_FOOTER, render.Flags.SHOW_LFD),
        Profile = bor(render.Flags.MYTHIC_KEYSTONE, render.Flags.RAID, render.Flags.PROFILE_TOOLTIP, render.Flags.MOD_STICKY, render.Flags.SHOW_PADDING, render.Flags.SHOW_HEADER, render.Flags.SHOW_FOOTER, render.Flags.SHOW_NAME, render.Flags.SHOW_LFD),
        Keystone = bor(render.Flags.MYTHIC_KEYSTONE, render.Flags.KEYSTONE_TOOLTIP, render.Flags.SHOW_PADDING, render.Flags.SHOW_HEADER, render.Flags.SHOW_LFD),
    }

    render.Preset.UnitNoPadding = bxor(render.Preset.Unit, render.Flags.SHOW_PADDING) ---@diagnostic disable-line: param-type-mismatch

    local function IsModifierKeyDownOrAlwaysExtend()
        return IsModifierKeyDown() or config:Get("alwaysExtendTooltip")
    end

    for k, v in pairs(render.Preset) do
        render.Preset[k] = function(additional)
            local IsModKeyDown = IsModifierKeyDown
            if k == "Unit" or k == "UnitNoPadding" then
                IsModKeyDown = IsModifierKeyDownOrAlwaysExtend
            end
            if type(additional) == "number" then
                if additional < 0 then
                    additional = bxor(v, -additional)
                end
                return bor(v, additional, IsModKeyDown() and render.Flags.MOD or 0)
            end
            return bor(v, IsModKeyDown() and render.Flags.MOD or 0)
        end
    end

    render.Preset.UnitSmartPadding = function(ownerExisted)
        return bxor(render.Preset.Unit(), not ownerExisted and render.Flags.SHOW_PADDING or 0)
    end

    local StateType = {
        Profile = 1,
        Keystone = 2
    }

    ---@class TooltipState
    ---@field public type number
    ---@field public unit string
    ---@field public name string
    ---@field public realm string
    ---@field public faction number @1 (alliance), 2 (horde), 3 (neutral)
    ---@field public region string @"us","kr","eu","tw","cn"
    ---@field public options number @render.Flags

    ---@class TooltipStates

    ---@type TooltipStates<table, TooltipState>
    local tooltipStates = {}

    ---@param tooltip GameTooltip
    function render:GetTooltipState(tooltip)
        ---@type TooltipState
        local state = tooltipStates[tooltip]
        if not state then
            state = {}
            tooltipStates[tooltip] = state
        end
        return state
    end

    ---@param tooltip GameTooltip
    ---@return boolean @Returns true if the tooltip was successfully updated with data, otherwise false if we couldn't.
    function render:ShowProfile(tooltip, ...)
        local state = render:GetTooltipState(tooltip)
        state.type = StateType.Profile
        local unit, name, realm, faction, options, args, region = render.GetQuery(...)
        state.unit, state.name, state.realm, state.faction, state.options, state.args, state.region = unit, name, realm, faction, options, args, region
        state.faction = state.faction or util:GetFaction(state.unit)
        state.options = state.options or render.Preset.Unit()
        state.args = state.args or args
        state.region = state.region or ns.PLAYER_REGION
        state.success = render:UpdateTooltip(tooltip, state)
        tooltip:Show()
        return state.success
    end

    ---@class KeystoneInfo
    ---@field public link string @Required as we need to know how to re-draw the tooltip when needed using the proper link
    ---@field public item number @itemID or keystoneID from the link itself
    ---@field public instance number @instanceID
    ---@field public level number @level 2 and higher
    ---@field public affix1 number @optional affix ID
    ---@field public affix2 number @optional affix ID
    ---@field public affix3 number @optional affix ID
    ---@field public affix4 number @optional affix ID

    ---@param tooltip GameTooltip
    ---@param keystone KeystoneInfo
    ---@return boolean @Returns true if the tooltip was successfully updated with data, otherwise false if we couldn't.
    function render:ShowKeystone(tooltip, keystone)
        local state = render:GetTooltipState(tooltip)
        state.type = StateType.Keystone
        state.unit, state.name, state.realm, state.faction, state.options = nil
        state.args = state.args or keystone
        state.options = render.Preset.Keystone()
        state.success = render:UpdateTooltip(tooltip, state)
        tooltip:Show()
        return state.success
    end

    ---@param tooltip GameTooltip
    function render:ClearTooltip(tooltip)
        local state = render:GetTooltipState(tooltip)
        table.wipe(state)
    end

    ---@param tooltip GameTooltip
    function render:HideTooltip(tooltip)
        render:ClearTooltip(tooltip)
        tooltip:Hide()
    end

    local function Has(flag, mask)
        return band(flag, mask) == mask
    end

    local EASTER_EGG = {
        ["eu"] = {
            ["TarrenMill"] = {
                ["Vladinator"] = "Raider.IO AddOn Author"
            },
            ["Ysondre"] = {
                ["Isakem"] = "Raider.IO Developer"
            }
        },
        ["us"] = {
            ["Skullcrusher"] = {
                ["Aspyrio"] = "Raider.IO Creator",
                ["Ulsoga"] = "Raider.IO Creator",
                ["Mccaffrey"] = "Killing Keys Since 1977!",
                ["Oscassey"] = "Master of dis guys",
                ["Rhoma"] = "Plays an MDI Champion on TV"
            },
            ["Thrall"] = {
                ["Firstclass"] = "Author of mythicpl.us"
            },
            ["Tichondrius"] = {
                ["Johnsamdi"] = "Raider.IO Developer"
            }
        }
    }

    local function GetSeasonLabel(label, seasonId)
        if not seasonId then
            seasonId = ns.CURRENT_SEASON
        end
        return format(label, L["SEASON_LABEL_" .. (1 + seasonId)] or "")
    end

    ---@param data DataProviderMythicKeystoneScore
    local function GetScoreText(data, isApproximated)
        local score = (isApproximated and "±" or "") .. data.score
        if not config:Get("showRoleIcons") then
            return score
        end
        local icons = {}
        for i = 1, #data.roles do
            local role = data.roles[i]
            local k, v = role[1], role[2]
            icons[i] = ns.ROLE_ICONS[k][v]
        end
        return table.concat(icons, "") .. " " .. score
    end

    ---Takes tripples of `Dungeon, Level, Chests` args, returns the best run back.
    ---@return Dungeon?, number, number @`arg1`= the Dungeon, `arg2` = keystone level, `arg3` = chests
    local function GetBestRunOfDungeons(...)
        local bestDungeon ---@type Dungeon|nil
        local bestLevel = 0 ---@type number
        local bestChests = 0 ---@type number
        local args = {...}
        for i = 1, #args, 3 do
            local dungeon = args[i] ---@type Dungeon|nil
            local level = args[i + 1] ---@type number
            local chests = args[i + 2] ---@type number
            if dungeon and dungeon.keystone_instance and (level > bestLevel or (level >= bestLevel and chests > bestChests)) then
                bestDungeon, bestLevel, bestChests = dungeon, level, chests
            end
        end
        return bestDungeon, bestLevel, bestChests
    end

    ---@class BestRun
    ---@field public dungeon Dungeon|nil @The dungeon.
    ---@field public level number @The keystone level.
    ---@field public chests number @The amount of chests/medals earned.

    ---@param tooltip GameTooltip
    ---@param keystoneProfile DataProviderMythicKeystoneProfile
    ---@param state TooltipState
    ---@param isHeader? boolean
    ---@return boolean|nil @Returns true if this is a header and it has added data to the tooltip, otherwise false, or nil if it's not a header request.
    local function AppendBestRunToTooltip(tooltip, keystoneProfile, state, isHeader)
        local options = state.options
        local showLFD = Has(options, render.Flags.SHOW_LFD)
        local best = { dungeon = nil, level = 0, chests = 0 } ---@type BestRun
        local overallBest = { dungeon = nil, level = 0, chests = 0 } ---@type BestRun
        overallBest.dungeon,
        overallBest.level,
        overallBest.chests = GetBestRunOfDungeons(
            keystoneProfile.fortifiedMaxDungeon,
            keystoneProfile.fortifiedMaxDungeonLevel,
            keystoneProfile.fortifiedDungeonUpgrades[keystoneProfile.fortifiedMaxDungeonIndex],
            keystoneProfile.tyrannicalMaxDungeon,
            keystoneProfile.tyrannicalMaxDungeonLevel,
            keystoneProfile.tyrannicalDungeonUpgrades[keystoneProfile.tyrannicalMaxDungeonIndex]
        )
        if showLFD then
            local focusDungeon = util:GetLFDStatusForCurrentActivity(state.args and state.args.activityID)
            if focusDungeon then
                best.dungeon,
                best.level,
                best.chests = GetBestRunOfDungeons(
                    focusDungeon,
                    keystoneProfile.fortifiedDungeons[focusDungeon.index],
                    keystoneProfile.fortifiedDungeonUpgrades[focusDungeon.index],
                    focusDungeon,
                    keystoneProfile.tyrannicalDungeons[focusDungeon.index],
                    keystoneProfile.tyrannicalDungeonUpgrades[focusDungeon.index]
                )
            end
        end
        local hasHeaderData = false
        if overallBest.level > 0 and (not best.dungeon or best.dungeon ~= overallBest.dungeon) then
            local label, r, g, b
            if isHeader then
                hasHeaderData = true
                label, r, g, b = L.RAIDERIO_BEST_RUN, 1, 0.85, 0
            else
                label, r, g, b = L.BEST_RUN, 1, 1, 1
            end
            tooltip:AddDoubleLine(label, util:GetNumChests(overallBest.chests) .. "|cffffffff" .. overallBest.level .. "|r " .. overallBest.dungeon.shortNameLocale, r, g, b, util:GetScoreColor(keystoneProfile.mplusCurrent.score))
        end
        if best.dungeon and best.level > 0 then
            local label, r, g, b = L.BEST_FOR_DUNGEON, 1, 1, 1
            hasHeaderData = isHeader ---@diagnostic disable-line: cast-local-type
            if best.dungeon == keystoneProfile.maxDungeon then
                if isHeader then
                    label, r, g, b = L.RAIDERIO_BEST_RUN, 1, 0.85, 0
                else
                    label, r, g, b = L.BEST_FOR_DUNGEON, 0, 1, 0
                end
            end
            tooltip:AddDoubleLine(label, util:GetNumChests(best.chests) .. "|cffffffff" .. best.level .. "|r " .. best.dungeon.shortNameLocale, r, g, b, util:GetScoreColor(keystoneProfile.mplusCurrent.score))
        end
        if isHeader then
            return hasHeaderData
        end
    end

    ---@class PartyMember
    ---@field public unit string
    ---@field public level number
    ---@field public name string
    ---@field public chests number

    ---@param a PartyMember
    ---@param b PartyMember
    local function SortGroupMembers(a, b)
        if a.level == b.level then
            return a.name < b.name
        end
        return a.level > b.level
    end

    ---@param keystone KeystoneInfo
    ---@param dungeon Dungeon
    local function AppendGroupLevelsToTooltip(tooltip, keystone, dungeon)
        local numMembers = GetNumGroupMembers()
        if numMembers > 5 then
            return
        end
        ---@type PartyMember[]
        local members = {}
        local index = 0
        for i = 0, numMembers do
            local unit = i == 0 and "player" or "party" .. i
            local name, realm = util:GetNameRealm(unit)
            local profile = provider:GetProfile(name, realm)
            if profile and profile.mythicKeystoneProfile and not profile.mythicKeystoneProfile.blocked then
                local level = profile.mythicKeystoneProfile.dungeons[dungeon.index]
                if level > 0 then
                    index = index + 1
                    members[index] = {
                        unit = unit,
                        level = level,
                        name = UnitNameUnmodified(unit), ---@diagnostic disable-line: assign-type-mismatch
                        chests = profile.mythicKeystoneProfile.dungeonUpgrades[dungeon.index]
                    }
                end
            end
        end
        if index > 1 then
            table.sort(members, SortGroupMembers)
        end
        for i = 1, index do
            local member = members[i]
            tooltip:AddDoubleLine(UnitNameUnmodified(member.unit), util:GetNumChests(member.chests) .. member.level .. " " .. dungeon.shortNameLocale, 1, 1, 1, util:GetKeystoneChestColor(member.chests))
        end
    end

    ---@param sortedDungeons SortedDungeon[]
    local function GetSortedDungeonsTooltipText(sortedDungeons, weeklyAffixInternal, currentWeeklyAffixInternal)
        local isActive = not currentWeeklyAffixInternal or weeklyAffixInternal == currentWeeklyAffixInternal
        local lines = {}
        local lineWidth = {}
        local maxWidth = 0
        for i = 1, #sortedDungeons do
            local sortedDungeon = sortedDungeons[i]
            local chests = sortedDungeon[weeklyAffixInternal .. "Chests"]
            local level = sortedDungeon[weeklyAffixInternal .. "Level"]
            -- local fractionalTime = sortedDungeon[weeklyAffixInternal .. "FractionalTime"]
            local text = {
                util:GetNumChests(chests, not isActive),
                "|cff",
                isActive and util:GetKeystoneChestColor(chests, true) or "bfbfbf",
                level > 0 and level or "-",
                "|r",
            }
            text = table.concat(text) ---@diagnostic disable-line: cast-local-type
            lines[i] = text
            local width = util:GetTooltipTextWidth(text)
            lineWidth[i] = width
            if width > maxWidth then
                maxWidth = width
            end
        end
        return lines, lineWidth, maxWidth
    end

    ---@type table<DungeonRaid, string>|nil
    local CACHED_FATED_RAIDS_MAP

    ---@return table<DungeonRaid, string>|nil
    local function InitCachedFatedRaidsMap()
        local cache = CACHED_FATED_RAIDS_MAP
        if cache then
            return cache
        end
        CACHED_FATED_RAIDS_MAP = util:GetFatedRaids(true)
        cache = CACHED_FATED_RAIDS_MAP
        if not next(cache) then
            return
        end
        return cache
    end

    ---@param raids any[]
    local function CanSortRaids(raids)
        if not raids or type(raids) ~= "table" then
            return false
        end
        return #raids > 1
    end

    ---@param raids DatabaseRaid[]
    local function ProcessFatedRaidsProfile(raids)
        if not CanSortRaids(raids) then
            return
        end
        local cache = InitCachedFatedRaidsMap()
        if not cache then
            return
        end
        table.sort(raids, function(a, b)
            local f1 = a.id ~= a.mapId and cache[a.dungeon] and 1 or 0
            local f2 = b.id ~= b.mapId and cache[b.dungeon] and 1 or 0
            if f1 == f2 then
                return a.ordinal < b.ordinal
            end
            return f1 > f2
        end)
    end

    ---@param tooltip GameTooltip
    ---@param raids DatabaseRaid[]
    ---@param raidProfile DataProviderRaidProfile
    ---@param state TooltipState
    ---@param showHeader boolean
    ---@param showLFD boolean
    local function AppendRaidProfileToTooltip(tooltip, raids, raidProfile, state, showHeader, showLFD)
        if not raids then
            return
        end
        local numRaids = #raids
        if numRaids < 1 then
            return
        end
        local sortedRaids = {} ---@type DatabaseRaid[]
        for i = 1, numRaids do
            sortedRaids[i] = raids[i]
        end
        ProcessFatedRaidsProfile(sortedRaids)
        if showHeader and numRaids == 1 then
            tooltip:AddLine(L.RAID_ENCOUNTERS_DEFEATED_TITLE, 1, 0.85, 0)
        end
        local focusDungeon = false ---@type Dungeon|DungeonRaid|nil|false
        for i = 1, numRaids do
            local raid = sortedRaids[i]
            if showHeader and numRaids > 1 then
                if showLFD and focusDungeon == false then
                    focusDungeon = util:GetLFDStatusForCurrentActivity(state.args and state.args.activityID)
                end
                local focused = focusDungeon and focusDungeon == raid.dungeon
                local fated = raid.id and raid.id ~= raid.mapId and util:IsRaidFated(raid.dungeon)
                local r, g, b = 1, 0.85, 0
                if focused then
                    r, g, b = 0, 1, 0
                end
                local fatedTexture = fated and format("|A:%s-small:0:0:0:1|a", fated) or ""
                tooltip:AddLine(format("%s %s", raid.name, fatedTexture), r, g, b) -- TODO: raid.dungeon?.nameLocale
            end
            for j = 1, raid.bossCount do
                local progressFound = false
                for k = 1, #raidProfile.progress do
                    local progress = raidProfile.progress[k]
                    if raid == progress.raid then
                        local bossKills = progress.killsPerBoss[j]
                        if bossKills > 0 then
                            progressFound = true
                            local difficulty = ns.RAID_DIFFICULTY[progress.difficulty]
                            tooltip:AddDoubleLine(format("|cff%s%s|r %s", difficulty.color.hex, difficulty.suffix, L[format("RAID_BOSS_%s_%d", raid.shortName, j)]), bossKills, 1, 1, 1, 1, 1, 1)
                        end
                        if progressFound then
                            break
                        end
                    end
                end
                if not progressFound then
                    tooltip:AddDoubleLine(L[format("RAID_BOSS_%s_%d", raid.shortName, j)], "-", 0.5, 0.5, 0.5, 0.5, 0.5, 0.5)
                end
            end
        end
    end

    ---@param raidProgress RaidProgress[]
    local function ProcessFatedRaids(raidProgress)
        if not CanSortRaids(raidProgress) then
            return
        end
        local cache = InitCachedFatedRaidsMap()
        if not cache then
            return
        end
        table.sort(raidProgress, function(a, b)
            if not a.isMainProgress ~= not b.isMainProgress then
                return not a.isMainProgress and b.isMainProgress
            end
            local r1 = a.raid
            local r2 = b.raid
            local f1 = a.current and cache[r1.dungeon] and 1 or 0
            local f2 = b.current and cache[r2.dungeon] and 1 or 0
            if f1 == f2 then
                return r1.ordinal < r2.ordinal
            end
            return f1 > f2
        end)
    end

    ---@param tooltip GameTooltip
    ---@param raidProfile DataProviderRaidProfile
    ---@param state TooltipState
    ---@param hasModOrSticky boolean
    ---@param showLFD boolean
    local function AppendRaidProgressToTooltip(tooltip, raidProfile, state, hasModOrSticky, showLFD)
        local raidProgress = raidProfile.raidProgress
        ProcessFatedRaids(raidProgress)
        local focusDungeon = showLFD and util:GetLFDStatusForCurrentActivity(state.args and state.args.activityID)
        local raidGroups = {} ---@type RaidProgressExtended[]
        local hasShown = false ---@type boolean|nil
        for i = 1, #raidProgress do
            local progress = raidProgress[i]
            ---@type RaidProgressExtended
            local raidGroup = {
                progress = progress,
            }
            raidGroups[i] = raidGroup
            local groupProgress = raidGroup.progress
            raidGroup.focused = focusDungeon and focusDungeon == groupProgress.raid.dungeon
            if groupProgress.current then
                raidGroup.fated = util:IsRaidFated(groupProgress.raid.dungeon)
            else
                raidGroup.fated = nil
            end
            raidGroup.show = not not (hasModOrSticky or (groupProgress.progress[1] and (raidGroup.focused or raidGroup.fated)))
            hasShown = hasShown or raidGroup.show
        end
        for i = 1, #raidGroups do
            local raidGroup = raidGroups[i]
            if raidGroup.show or hasShown == false then
                local groupProgress = raidGroup.progress
                local tempIndex = 0
                local temp = {}
                for j = 1, #groupProgress.progress do
                    local group = groupProgress.progress[j]
                    if not group.obsolete then
                        hasShown = nil
                        local raidDiff = ns.RAID_DIFFICULTY[group.difficulty]
                        tempIndex = tempIndex + 1
                        temp[tempIndex] = format("|cff%s%s|r %d/%d", raidDiff.color.hex, raidDiff.suffix, group.kills, groupProgress.raid.bossCount)
                    end
                end
                if tempIndex > 0 then
                    local r, g, b = 1, 1, 1
                    if raidGroup.focused then
                        r, g, b = 0, 1, 0
                    end
                    local prefixText = groupProgress.isMainProgress and format("%s ", L.MAINS_RAID_PROGRESS) or ""
                    local fatedTexture = raidGroup.fated and format("|A:%s-small:0:0:0:1|a", raidGroup.fated) or ""
                    tooltip:AddDoubleLine(format("%s%s %s", prefixText, groupProgress.raid.shortName, fatedTexture), table.concat(temp, " "), r, g, b, 1, 1, 1) -- TODO: groupProgress.raid.dungeon?.shortNameLocale
                end
            end
        end
    end

    ---@param tooltip GameTooltip
    ---@param state TooltipState
    function render:UpdateTooltip(tooltip, state)
        -- we will in most cases always pass the state but if we don't we will retrieve it
        if not state then
            state = render:GetTooltipState(tooltip)
        end
        -- we are looking up a specific player
        if state.type == StateType.Profile then
            local profile = provider:GetProfile(state.name, state.realm, state.region)
            if profile then
                local keystoneProfile = profile.mythicKeystoneProfile
                local raidProfile = profile.raidProfile
                local recruitmentProfile = profile.recruitmentProfile
                local pvpProfile = profile.pvpProfile
                local isExtendedProfile = Has(state.options, render.Flags.PROFILE_TOOLTIP)
                local isKeystoneBlockShown = keystoneProfile and ((isExtendedProfile or keystoneProfile.hasRenderableData) and not keystoneProfile.blocked)
                local isBlocked = keystoneProfile and (keystoneProfile.blocked or keystoneProfile.softBlocked)
                local isOutdated = keystoneProfile and keystoneProfile.outdated
                local showRaidEncounters = config:Get("showRaidEncountersInProfile")
                local isRaidBlockShown = raidProfile and ((isExtendedProfile and showRaidEncounters) or raidProfile.hasRenderableData) and (not isExtendedProfile or showRaidEncounters)
                local isRecruitmentBlockShown = recruitmentProfile and recruitmentProfile.hasRenderableData
                local isPvpBlockShown = pvpProfile and pvpProfile.hasRenderableData
                local isAnyBlockShown = isKeystoneBlockShown or isRaidBlockShown or isRecruitmentBlockShown or isPvpBlockShown
                local isUnitTooltip = Has(state.options, render.Flags.UNIT_TOOLTIP)
                local hasMod = Has(state.options, render.Flags.MOD)
                local hasModSticky = Has(state.options, render.Flags.MOD_STICKY)
                local showHeader = Has(state.options, render.Flags.SHOW_HEADER)
                local showFooter = Has(state.options, render.Flags.SHOW_FOOTER)
                local showPadding = Has(state.options, render.Flags.SHOW_PADDING)
                local showName = Has(state.options, render.Flags.SHOW_NAME)
                local showLFD = Has(state.options, render.Flags.SHOW_LFD)
                local showTopLine = isAnyBlockShown or isBlocked or isOutdated
                local showTopLinePadding = showTopLine and not isUnitTooltip and isExtendedProfile and showPadding
                if showTopLine then
                    if isUnitTooltip then
                        if showPadding then
                            tooltip:AddLine(" ")
                        end
                        if showName then
                            tooltip:AddLine(format("%s (%s)", profile.name, profile.realm), 1, 1, 1)
                        end
                    elseif isExtendedProfile then
                        if showName then
                            tooltip:AddLine(format("%s (%s)", profile.name, profile.realm), 1, 1, 1)
                        end
                        if showPadding then
                            tooltip:AddLine(" ")
                        end
                    end
                end
                if isKeystoneBlockShown then
                    local headlineMode = config:Get("mplusHeadlineMode")
                    if showHeader then
                        if headlineMode == ns.HEADLINE_MODE.BEST_SEASON then
                            if ns.PREVIOUS_SEASON_SCORE_RELEVANCE_THRESHOLD * keystoneProfile.mplusPrevious.score > keystoneProfile.mplusCurrent.score then
                                tooltip:AddDoubleLine(GetSeasonLabel(L.RAIDERIO_MP_BEST_SCORE, keystoneProfile.mplusPrevious.season), GetScoreText(keystoneProfile.mplusPrevious, true), 1, 0.85, 0, util:GetScoreColor(keystoneProfile.mplusPrevious.score, true))
                                if keystoneProfile.mplusCurrent.score > 0 then
                                    tooltip:AddDoubleLine(GetSeasonLabel(L.CURRENT_SCORE), GetScoreText(keystoneProfile.mplusCurrent), 1, 1, 1, util:GetScoreColor(keystoneProfile.mplusCurrent.score))
                                end
                            else
                                tooltip:AddDoubleLine(GetSeasonLabel(L.RAIDERIO_MP_SCORE), GetScoreText(keystoneProfile.mplusCurrent), 1, 0.85, 0, util:GetScoreColor(keystoneProfile.mplusCurrent.score))
                            end
                        elseif headlineMode == ns.HEADLINE_MODE.BEST_RUN then
                            local r, g, b = 1, 0.85, 0
                            if AppendBestRunToTooltip(tooltip, keystoneProfile, state, true) then
                                r, g, b = 1, 1, 1
                            end
                            if keystoneProfile.mplusCurrent.score > 0 then
                                tooltip:AddDoubleLine(GetSeasonLabel(L.CURRENT_SCORE), GetScoreText(keystoneProfile.mplusCurrent), r, g, b, util:GetScoreColor(keystoneProfile.mplusCurrent.score))
                            end
                            if ns.PREVIOUS_SEASON_SCORE_RELEVANCE_THRESHOLD * keystoneProfile.mplusPrevious.score > keystoneProfile.mplusCurrent.score then
                                tooltip:AddDoubleLine(GetSeasonLabel(L.PREVIOUS_SCORE, keystoneProfile.mplusPrevious.season), GetScoreText(keystoneProfile.mplusPrevious, true), r, g, b, util:GetScoreColor(keystoneProfile.mplusPrevious.score, true))
                            end
                        else -- if headlineMode == ns.HEADLINE_MODE.CURRENT_SEASON then
                            tooltip:AddDoubleLine(GetSeasonLabel(L.RAIDERIO_MP_SCORE), GetScoreText(keystoneProfile.mplusCurrent), 1, 0.85, 0, util:GetScoreColor(keystoneProfile.mplusCurrent.score))
                            if ns.PREVIOUS_SEASON_SCORE_RELEVANCE_THRESHOLD * keystoneProfile.mplusPrevious.score > keystoneProfile.mplusCurrent.score then
                                tooltip:AddDoubleLine(GetSeasonLabel(L.PREVIOUS_SCORE, keystoneProfile.mplusPrevious.season), GetScoreText(keystoneProfile.mplusPrevious, true), 1, 1, 1, util:GetScoreColor(keystoneProfile.mplusPrevious.score, true))
                            end
                        end
                    end
                    if config:Get("showMainsScore") then
                        if not config:Get("showMainBestScore") then
                            if keystoneProfile.mplusMainCurrent.score > keystoneProfile.mplusCurrent.score then
                                tooltip:AddDoubleLine(L.MAINS_SCORE, GetScoreText(keystoneProfile.mplusMainCurrent), 1, 1, 1, util:GetScoreColor(keystoneProfile.mplusMainCurrent.score))
                            end
                        elseif keystoneProfile.mplusMainCurrent.score > keystoneProfile.mplusCurrent.score or (ns.PREVIOUS_SEASON_MAIN_SCORE_RELEVANCE_THRESHOLD * keystoneProfile.mplusMainPrevious.score) > keystoneProfile.mplusCurrent.score then
                            if keystoneProfile.mplusMainCurrent.score < (ns.PREVIOUS_SEASON_MAIN_SCORE_RELEVANCE_THRESHOLD * keystoneProfile.mplusMainPrevious.score) then
                                tooltip:AddDoubleLine(GetSeasonLabel(L.MAINS_BEST_SCORE_BEST_SEASON, keystoneProfile.mplusMainPrevious.season), GetScoreText(keystoneProfile.mplusMainPrevious, true), 1, 1, 1, util:GetScoreColor(keystoneProfile.mplusMainPrevious.score, true))
                            elseif keystoneProfile.mplusMainCurrent.score > 0 or hasMod or hasModSticky then
                                tooltip:AddDoubleLine(L.CURRENT_MAINS_SCORE, GetScoreText(keystoneProfile.mplusMainCurrent), 1, 1, 1, util:GetScoreColor(keystoneProfile.mplusMainCurrent.score))
                            end
                        end
                    end
                    do
                        AppendBestRunToTooltip(tooltip, keystoneProfile, state)
                    end
                    for i = 1, #keystoneProfile.sortedMilestones do
                        if i >= 2 and (not hasMod and not hasModSticky) then
                            break
                        end
                        local sortedMilestone = keystoneProfile.sortedMilestones[i]
                        tooltip:AddDoubleLine(sortedMilestone.label, sortedMilestone.text, 1, 1, 1, 1, 1, 1)
                    end
                    if isExtendedProfile and (hasMod or hasModSticky) and keystoneProfile.sortedDungeons[1] then
                        local hasBestDungeons = false
                        for i = 1, #keystoneProfile.sortedDungeons do
                            local sortedDungeon = keystoneProfile.sortedDungeons[i]
                            if sortedDungeon.level > 0 then
                                hasBestDungeons = true
                                break
                            end
                        end
                        if hasBestDungeons or true then -- HOTFIX: we prefer to always display this in the expanded profile so even empty profiles can display what dungeons there are for the player to complete
                            local focusDungeon = showLFD and util:GetLFDStatusForCurrentActivity(state.args and state.args.activityID)
                            local fortifiedLines, fortifiedLinesWidth, fortifiedMaxWidth = GetSortedDungeonsTooltipText(keystoneProfile.sortedDungeons, "fortified")
                            local tyrannicalLines, tyrannicalLinesWidth, tyrannicalMaxWidth = GetSortedDungeonsTooltipText(keystoneProfile.sortedDungeons, "tyrannical")
                            local paddingBetweenColumns = 15 -- additional column padding in order to avoid the columns appearing glued together
                            tyrannicalMaxWidth = tyrannicalMaxWidth + paddingBetweenColumns
                            if showHeader then
                                if showPadding then
                                    tooltip:AddLine(" ")
                                end
                                local weeklyAffixID = util:GetWeeklyAffix()
                                local leftHeaderText = ns.KEYSTONE_AFFIX_TEXTURE[weeklyAffixID == 10 and 10 or -10]
                                local rightHeaderText = ns.KEYSTONE_AFFIX_TEXTURE[weeklyAffixID == 9 and 9 or -9]
                                local rightHeaderTextWidth = util:GetTooltipTextWidth(rightHeaderText)
                                if rightHeaderTextWidth > tyrannicalMaxWidth then
                                    tyrannicalMaxWidth = rightHeaderTextWidth + paddingBetweenColumns
                                end
                                local paddingTexture = util:GetTextPaddingTexture(tyrannicalMaxWidth - rightHeaderTextWidth)
                                local text = { leftHeaderText, paddingTexture, rightHeaderText }
                                tooltip:AddDoubleLine(L.PROFILE_BEST_RUNS, table.concat(text, ""), 1, 0.85, 0, 1, 0.85, 0)
                            end
                            for i = 1, #keystoneProfile.sortedDungeons do
                                local sortedDungeon = keystoneProfile.sortedDungeons[i]
                                local r, g, b = 1, 1, 1
                                if sortedDungeon.dungeon == focusDungeon then
                                    r, g, b = 0, 1, 0
                                end
                                local paddingTexture = util:GetTextPaddingTexture(tyrannicalMaxWidth - tyrannicalLinesWidth[i])
                                if sortedDungeon.fortifiedLevel > 0 or sortedDungeon.tyrannicalLevel > 0 then
                                    local text = { fortifiedLines[i], paddingTexture, tyrannicalLines[i] }
                                    tooltip:AddDoubleLine(sortedDungeon.dungeon.shortNameLocale, table.concat(text, ""), r, g, b, 0.5, 0.5, 0.5)
                                else
                                    local text = { "-", paddingTexture, "-" }
                                    tooltip:AddDoubleLine(sortedDungeon.dungeon.shortNameLocale, table.concat(text, ""), r, g, b, 0.5, 0.5, 0.5)
                                end
                            end
                        end
                    end
                end
                if isRaidBlockShown then
                    if showPadding and isKeystoneBlockShown then
                        tooltip:AddLine(" ")
                    end
                    if showHeader and not isExtendedProfile then
                        tooltip:AddLine(L.RAIDING_DATA_HEADER, 1, 0.85, 0)
                    end
                    if isExtendedProfile then
                        if showRaidEncounters then
                            local raidProvider = provider:GetProviderByType(ns.PROVIDER_DATA_TYPE.Raid, state.region)
                            if raidProvider then
                                AppendRaidProfileToTooltip(tooltip, raidProvider.currentRaids, raidProfile, state, showHeader, showLFD)
                            end
                        end
                    else
                        AppendRaidProgressToTooltip(tooltip, raidProfile, state, hasMod or hasModSticky, showLFD)
                    end
                end
                if isRecruitmentBlockShown then
                    if showPadding and (isKeystoneBlockShown or isRaidBlockShown) then
                        tooltip:AddLine(" ")
                    end
                    local titleLocale, titleOptionalArg = recruitmentProfile.title[1], recruitmentProfile.title[2]
                    local titleText = format(L[titleLocale], titleOptionalArg)
                    local icons = { recruitmentProfile.tank and ns.RECRUITMENT_ROLE_ICONS.tank or "", recruitmentProfile.healer and ns.RECRUITMENT_ROLE_ICONS.healer or "", recruitmentProfile.dps and ns.RECRUITMENT_ROLE_ICONS.dps or "" }
                    tooltip:AddDoubleLine(titleText, table.concat(icons, ""), 0.9, 0.8, 0.5, 1, 1, 1)
                end
                if isPvpBlockShown then
                    if showPadding and (isKeystoneBlockShown or isRaidBlockShown or isRecruitmentBlockShown) then
                        tooltip:AddLine(" ")
                    end
                    if showHeader then
                        tooltip:AddLine(L.PVP_DATA_HEADER, 1, 0.85, 0)
                    end
                    -- TODO: NYI
                end
                if showFooter then
                    local easterEgg = EASTER_EGG[ns.PLAYER_REGION]
                    if easterEgg then
                        easterEgg = easterEgg[profile.realm]
                        if easterEgg then
                            easterEgg = easterEgg[profile.name] ---@diagnostic disable-line: cast-local-type
                        end
                    end
                    if showPadding and (not showTopLinePadding or isAnyBlockShown) and (isBlocked or isOutdated or easterEgg) then
                        tooltip:AddLine(" ")
                    end
                    if isBlocked then
                        tooltip:AddLine(L.OUTDATED_EXPIRED_TITLE, 1, 0.85, 0)
                        tooltip:AddLine(format(L.OUTDATED_DOWNLOAD_LINK, ns.RAIDERIO_ADDON_DOWNLOAD_URL), 1, 1, 1)
                        if showPadding and easterEgg then
                            tooltip:AddLine(" ")
                        end
                    elseif isOutdated then
                        local secondsRemainingUntilBlocked = ns.OUTDATED_BLOCK_CUTOFF - isOutdated - ns.OUTDATED_CUTOFF
                        local numDays = floor(secondsRemainingUntilBlocked / 86400 + 0.5)
                        local numHours = floor(secondsRemainingUntilBlocked / 3600 + 0.5)
                        local numMinutes = floor(secondsRemainingUntilBlocked / 60 + 0.5)
                        if numDays >= 2 then
                            tooltip:AddLine(format(L.OUTDATED_EXPIRES_IN_DAYS, numDays), 1, 0.85, 0)
                        elseif numHours > 1 then
                            tooltip:AddLine(format(L.OUTDATED_EXPIRES_IN_HOURS, numHours), 1, 0.85, 0)
                        elseif numMinutes > 0 then
                            tooltip:AddLine(format(L.OUTDATED_EXPIRES_IN_MINUTES, numMinutes), 1, 0.85, 0)
                        else
                            tooltip:AddLine(L.OUTDATED_EXPIRED_TITLE, 1, 0.85, 0)
                        end
                        tooltip:AddLine(format(L.OUTDATED_DOWNLOAD_LINK, ns.RAIDERIO_ADDON_DOWNLOAD_URL), 1, 1, 1)
                        if showPadding and easterEgg then
                            tooltip:AddLine(" ")
                        end
                    end
                    if easterEgg then
                        tooltip:AddLine(easterEgg, 0.9, 0.8, 0.5)
                    end
                end
                -- profile added to tooltip successfully
                return true
            end
        end
        -- we are display keystone information
        if state.type == StateType.Keystone then
            ---@type KeystoneInfo
            local keystone = state.args
            if keystone and keystone.link then
                local baseScore = ns.KEYSTONE_LEVEL_TO_SCORE[keystone.level]
                if baseScore then
                    tooltip:AddLine(" ")
                    tooltip:AddDoubleLine(L.RAIDERIO_MP_BASE_SCORE, baseScore, 1, 0.85, 0, 1, 1, 1)
                    local avgScore = util:GetKeystoneAverageScoreForLevel(keystone.level)
                    if avgScore and config:Get("showAverageScore") then
                        tooltip:AddDoubleLine(format(L.RAIDERIO_AVERAGE_PLAYER_SCORE, keystone.level), avgScore, 1, 1, 1, util:GetScoreColor(avgScore))
                    end
                    if keystone.instance then
                        local dungeon = util:GetDungeonByKeystoneID(keystone.instance)
                        if dungeon then
                            AppendGroupLevelsToTooltip(tooltip, keystone, dungeon)
                        end
                    end
                    -- keystone information added to tooltip successfully
                    return true
                end
            end
        end
        -- we couldn't add a profile to the tooltip
        return false
    end

    ---@param tooltip GameTooltip
    ---@param state TooltipState
    local function UpdateTooltip(tooltip, state)
        -- if unit simply refresh the unit and the original hook will force update the tooltip with the desired behavior
        local _, tooltipUnit = tooltip:GetUnit()
        if tooltipUnit then
            tooltip:SetUnit(tooltipUnit)
            return
        end
        -- backup the state and update the modifier state in the options flag
        local stateType, unit, name, realm, faction, options, args, region = state.type, state.unit, state.name, state.realm, state.faction, state.options, state.args, state.region
        if IsModifierKeyDown() then
            options = bor(options, render.Flags.MOD)
        else
            options = bxor(options, render.Flags.MOD)
        end
        -- get the current tooltip owner, position and anchor
        local o1, o2, o3, o4 = tooltip:GetOwner()
        local p1, p2, p3, p4, p5 = tooltip:GetPoint(1)
        local a1, a2, a3 = tooltip:GetAnchorType()
        -- if the owner exists, and has a OnEnter function we simply call that again to force the tooltip to reload and our original hook will update the tooltip with the desired behavior
        if o1 then
            local status = util:ExecuteWidgetOnEnterSafely(o1, function() tooltip:Hide() end)
            if status == 1 then
                return false
            elseif status == 2 or status == 3 then
                return
            end
        end
        -- if the owner is the UIParent we must beware as it might be the fading out unit tooltips that linger, we do not wish to update these as we do not have a valid unit anymore for reference so we just don't do anything instead
        if o1 == UIParent then
            return
        end
        -- if we get this far, we know it's not a unit, not a owner with a OnEnter, and it's not a parent of UIParent, so we clear the tooltip, then re-apply the owner, position and anchor, and force it to draw the profile once more on the tooltip
        tooltip:Hide()
        if o1 then
            o2 = a1
            if p4 then
                o3 = p4 ---@diagnostic disable-line: cast-local-type
            end
            if p5 then
                o4 = p5 ---@diagnostic disable-line: cast-local-type
            end
            tooltip:SetOwner(o1, o2, o3, o4) ---@diagnostic disable-line: param-type-mismatch
        end
        if p1 then
            tooltip:SetPoint(p1, p2, p3, p4, p5)
        end
        if not o1 and a1 then
            tooltip:SetAnchorType(a1, a2, a3)
        end
        -- based on the type, call the appropriate function, and in worst case scenario we hide the tooltip
        if stateType == StateType.Profile then
            if UnitExists(unit) then
                render:ShowProfile(tooltip, unit, options, args, region)
            else
                render:ShowProfile(tooltip, name, realm, options, args, region)
            end
        elseif stateType == StateType.Keystone then
            tooltip:SetHyperlink(args.link)
        else
            tooltip:Hide()
        end
    end

    local function OnModifierStateChanged()
        for tooltip, state in pairs(tooltipStates) do
            -- we only want to update tooltips that have a valid state (i.e. in use and visible)
            if state.success and tooltip:IsShown() then
                UpdateTooltip(tooltip, state)
            end
        end
    end

    callback:RegisterEvent(OnModifierStateChanged, "MODIFIER_STATE_CHANGED")

end

-- public.lua (global)
-- dependencies: module, util, provider, render
do

    local util = ns:GetModule("Util") ---@type UtilModule
    local provider = ns:GetModule("Provider") ---@type ProviderModule
    local render = ns:GetModule("Render") ---@type RenderModule

    -- TODO: we have a long road a head of us... debugstack(0)
    local function IsSafeCall()
        return true
    end

    local unsafe = false

    local function IsSafe()
        if unsafe then
            return false
        end
        if not IsSafeCall() then
            unsafe = true
            ns.Print("Error: Another AddOn has modified Raider.IO and is most likely forcing it to return invalid data. Please disable other addons until this message disappears.")
            return false
        end
        return true
    end

    local function IsReady()
        return ns.PLAYER_REGION ~= nil -- GetProfile will fail if called too early before the player info is properly loaded so we avoid doing that by safely checking if we're loaded ready
    end

    local pristine = {
        AddProvider = function(...)
            return provider:AddProvider(...)
        end,
        GetProfile = function(arg1, arg2, ...)
            if not IsReady() then
                return
            end
            local name, realm = arg1, arg2
            local _, _, unitIsPlayer = util:IsUnit(arg1, arg2)
            if unitIsPlayer then
                name, realm = util:GetNameRealm(arg1)
            elseif type(arg1) == "string" then
                if arg1:find("-", nil, true) then
                    name, realm = util:GetNameRealm(arg1)
                    return provider:GetProfile(name, realm, ...)
                else
                    name, realm = util:GetNameRealm(arg1, arg2)
                end
            end
            return provider:GetProfile(name, realm, ...)
        end,
        ShowProfile = function(tooltip, ...)
            if not IsReady() then
                return
            end
            if type(tooltip) ~= "table" or type(tooltip.GetObjectType) ~= "function" or tooltip:GetObjectType() ~= "GameTooltip" then
                return
            end
            return render:ShowProfile(tooltip, ...)
        end,
        GetScoreColor = function(score, ...)
            if type(score) ~= "number" then
                score = 0
            end
            return util:GetScoreColor(score, ...)
        end,
        GetScoreForKeystone = function(level)
            if not level then return end
            local base = ns.KEYSTONE_LEVEL_TO_SCORE[level]
            local average = util:GetKeystoneAverageScoreForLevel(level)
            return base, average
        end
    }

    local private = {
        AddProvider = function(...)
            if not IsSafe() then
                return
            end
            return pristine.AddProvider(...)
        end,
        GetProfile = function(...)
            if not IsSafe() then
                return
            end
            return pristine.GetProfile(...)
        end,
        ShowProfile = function(...)
            if not IsSafe() then
                return
            end
            return pristine.ShowProfile(...)
        end,
        GetScoreColor = function(...)
            if not IsSafe() then
                return
            end
            return pristine.GetScoreColor(...)
        end,
        GetScoreForKeystone = function(...)
            if not IsSafe() then
                return
            end
            return pristine.GetScoreForKeystone(...)
        end,
        -- DEPRECATED: these are here just to help mitigate the transition but do avoid using these as they will probably go away during Shadowlands
        ProfileOutput = setmetatable({}, { __index = function() return 0 end }), -- returns 0 for any query
        TooltipProfileOutput = setmetatable({}, { __index = function() return 0 end }), -- returns 0 for any query
        DataProvider = setmetatable({}, { __index = function() return 0 end }), -- returns 0 for any query
        HasPlayerProfile = function(...) return _G.RaiderIO.GetProfile(...) end, -- passes the request to the GetProfile API (if its there then it exists)
        GetPlayerProfile = function(mask, ...) return _G.RaiderIO.GetProfile(...) end, -- skips the mask and passes the rest to the GetProfile API
        ShowTooltip = function(tooltip, mask, ...) return _G.RaiderIO.ShowProfile(tooltip, ...) end, -- skips the mask and passes the rest to the ShowProfile API
        GetRaidDifficultyColor = function(difficulty) local rd = ns.RAID_DIFFICULTY[difficulty] local t if rd then t = { rd.color[1], rd.color[2], rd.color[3], rd.color.hex } end return t end, -- returns the color table for the queried raid difficulty
        GetScore = function() end, -- deprecated early BfA so we just return nothing
    }

    ---@class RaiderIOInterface
    ---@field public AddProvider function @For internal RaiderIO use only. Please do not call this function.
    ---@field public GetProfile function @Returns a table containing the characters profile and data from the different data providers like mythic keystones, raiding and pvp. Usage: `RaiderIO.GetProfile(name, realm, faction[, region])` or `RaiderIO.GetProfile(unit)`
    ---@field public ShowProfile function @Returns true or false depending if the profile could be drawn on the provided tooltip. `RaiderIO.ShowProfile(tooltip, name, realm, faction[, region])` or `RaiderIO.ShowProfile(tooltip, unit, faction[, region])`
    ---@field public GetScoreColor function @Returns the color (r, g, b) for a given score. `RaiderIO.GetScoreColor(score[, isPreviousSeason])`

    ---@type RaiderIOInterface
    _G.RaiderIO = setmetatable({}, {
        __metatable = false,
        __newindex = function()
        end,
        __index = function(self, key)
            return private[key]
        end,
        __call = function(self, key, ...)
            local func = pristine[key]
            if not func then
                return
            end
            return func(...)
        end
    })

end

-- gametooltip.lua
-- dependencies: module, config, util, provider, render
do

    ---@class GameTooltipModule : Module
    local tooltip = ns:NewModule("GameTooltip") ---@type GameTooltipModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule
    local provider = ns:GetModule("Provider") ---@type ProviderModule
    local render = ns:GetModule("Render") ---@type RenderModule

    local function OnTooltipSetUnit(self)
        if self ~= GameTooltip or not tooltip:IsEnabled() or not config:Get("enableUnitTooltips") then
            return
        end
        if (config:Get("showScoreModifier") and not IsModifierKeyDown()) or (not config:Get("showScoreModifier") and not config:Get("showScoreInCombat") and InCombatLockdown()) then
            return
        end
        local _, unit = self:GetUnit()
        if not unit or not UnitIsPlayer(unit) then
            return
        end
        if util:IsUnitMaxLevel(unit) then
            local bioSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
            if bioSummary and bioSummary.currentSeasonScore then
                local name, realm = util:GetNameRealm(unit)
                provider:OverrideProfile(name, realm, bioSummary.currentSeasonScore, bioSummary.runs)
            end
            render:ShowProfile(self, unit)
        end
    end

    local function OnTooltipCleared(self)
        render:ClearTooltip(self)
    end

    local function OnHide(self)
        render:HideTooltip(self)
    end

    function tooltip:CanLoad()
        return config:IsEnabled()
    end

    function tooltip:OnLoad()
        self:Enable()
        if TooltipDataProcessor then -- TODO: DF
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)
        else
            GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
        end
        GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
        GameTooltip:HookScript("OnHide", OnHide)
    end

end

-- friendtooltip.lua
-- dependencies: module, config, util, render
do

    ---@class FriendTooltipModule : Module
    local tooltip = ns:NewModule("FriendTooltip") ---@type FriendTooltipModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule
    local render = ns:GetModule("Render") ---@type RenderModule

    local function FriendsTooltip_Show(self)
        if not tooltip:IsEnabled() or not config:Get("enableFriendsTooltips") then
            return
        end
        local button = self.button
        local fullName, faction, level
        if button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
            local bnetIDAccountInfo = C_BattleNet.GetFriendAccountInfo(button.id)
            if bnetIDAccountInfo then
                fullName, faction, level = util:GetNameRealmForBNetFriend(bnetIDAccountInfo.bnetAccountID)
            end
        elseif button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
            local friendInfo = C_FriendList.GetFriendInfoByIndex(button.id)
            if friendInfo then
                fullName, level = friendInfo.name, friendInfo.level
                faction = ns.PLAYER_FACTION
            end
        end
        if not fullName or not util:IsMaxLevel(level) then ---@diagnostic disable-line: param-type-mismatch
            return
        end
        local ownerSet, ownerExisted, ownerSetSame = util:SetOwnerSafely(GameTooltip, FriendsTooltip, "ANCHOR_BOTTOMRIGHT", -FriendsTooltip:GetWidth(), -4)
        -- HOTFIX: attempt to fix the issue with a bnet friend with a notification causes the update to be called each frame without a proper hide event and this makes it so we append an empty line due to the smart padding check
        do
            local firstText = GameTooltipTextLeft1:GetText()
            if not firstText or firstText == "" or firstText == " " then
                ownerExisted = false
            end
        end
        if render:ShowProfile(GameTooltip, fullName, render.Preset.UnitSmartPadding(ownerExisted)) then
            return
        end
        if ownerSet and not ownerExisted and ownerSetSame then
            GameTooltip:Hide()
        end
    end

    local function FriendsTooltip_Hide()
        if not tooltip:IsEnabled() or not config:Get("enableFriendsTooltips") then
            return
        end
        GameTooltip:Hide()
    end

    function tooltip:OnLoad()
        self:Enable()
        hooksecurefunc(FriendsTooltip, "Show", FriendsTooltip_Show)
        hooksecurefunc(FriendsTooltip, "Hide", FriendsTooltip_Hide)
    end

end

-- whotooltip.lua
-- dependencies: module, config, util, render
do

    ---@class WhoTooltipModule : Module
    local tooltip = ns:NewModule("WhoTooltip") ---@type WhoTooltipModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule
    local render = ns:GetModule("Render") ---@type RenderModule

    local function OnEnter(self)
        if not self.index or not config:Get("enableWhoTooltips") then
            return
        end
        local info = C_FriendList.GetWhoInfo(self.index)
        if not info or not info.fullName or not util:IsMaxLevel(info.level) then
            return
        end
        local ownerSet, ownerExisted, ownerSetSame = util:SetOwnerSafely(GameTooltip, self, "ANCHOR_LEFT")
        if render:ShowProfile(GameTooltip, info.fullName, render.Preset.UnitSmartPadding(ownerExisted)) then
            return
        end
        if ownerSet and not ownerExisted and ownerSetSame then
            GameTooltip:Hide()
        end
    end

    local function OnLeave(self)
        if not self.index or not config:Get("enableWhoTooltips") then
            return
        end
        GameTooltip:Hide()
    end

    local function OnScroll()
        if not config:Get("enableWhoTooltips") then
            return
        end
        GameTooltip:Hide()
        util:ExecuteWidgetOnEnterSafely(GetMouseFocus())
    end

    function tooltip:OnLoad()
        self:Enable()
        local hookMap = { OnEnter = OnEnter, OnLeave = OnLeave }
        ScrollBoxUtil:OnViewFramesChanged(WhoFrame.ScrollBox, function(buttons) HookUtil:MapOn(buttons, hookMap) end)
        ScrollBoxUtil:OnViewScrollChanged(WhoFrame.ScrollBox, OnScroll)
    end

end

-- whochatframe.lua
-- dependencies: module, config, util, provider
do

    ---@class WhoChatFrameModule : Module
    local chatframe = ns:NewModule("WhoChatFrame") ---@type WhoChatFrameModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule
    local provider = ns:GetModule("Provider") ---@type ProviderModule

    local RAIDERIO_MP_SCORE = L.RAIDERIO_MP_SCORE:gsub("%.", "|cffffffff|r.") -- TODO: make it part of the locale file like L.RAIDERIO_MP_SCORE_WHOCHAT

    local FORMAT_GUILD = "^" .. util:FormatToPattern(WHO_LIST_GUILD_FORMAT) .. "$"
    local FORMAT = "^" .. util:FormatToPattern(WHO_LIST_FORMAT) .. "$"

    ---@param profile DataProviderCharacterProfile
    local function GetScore(profile)
        local keystoneProfile = profile.mythicKeystoneProfile
        if not keystoneProfile or keystoneProfile.blocked then
            return
        end
        local currentScore = keystoneProfile.mplusCurrent.score
        local mainCurrentScore = keystoneProfile.mplusMainCurrent.score
        local text
        if currentScore > 0 then
            text = RAIDERIO_MP_SCORE .. ": " .. currentScore .. ". "
        end
        if mainCurrentScore > currentScore and config:Get("showMainsScore") then
            text = (text or "") .. "(" .. L.MAINS_SCORE .. ": " .. mainCurrentScore .. "). "
        end
        return text
    end

    local function EventFilter(self, event, text, ...)
        if event ~= "CHAT_MSG_SYSTEM" or not config:Get("enableWhoMessages") then
            return false
        end
        local nameLink, name, level, race, class, guild, zone = text:match(FORMAT_GUILD)
        if not nameLink then
            return false
        end
        if not zone then
            guild = nil
            nameLink, name, level, race, class, zone = text:match(FORMAT)
        end
        if not nameLink or not level or not util:IsMaxLevel(tonumber(level)) then ---@diagnostic disable-line: param-type-mismatch
            return false
        end
        local name, realm = util:GetNameRealm(nameLink)
        local profile = provider:GetProfile(name, realm)
        if not profile or not profile.mythicKeystoneProfile or profile.mythicKeystoneProfile.blocked then
            return false
        end
        local score = GetScore(profile)
        if not score then
            return false
        end
        return false, text .. " - " .. score, ...
    end

    function chatframe:CanLoad()
        return config:IsEnabled()
    end

    function chatframe:OnLoad()
        self:Enable()
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", EventFilter)
    end

end

-- fanfare.lua (requires debug mode)
-- dependencies: module, config, util, provider
do

    ---@class FanfareModule : Module
    local fanfare = ns:NewModule("Fanfare") ---@type FanfareModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule
    local provider = ns:GetModule("Provider") ---@type ProviderModule

    local KEYSTONE_DATE

    local function GetGroupMembers()
        ---@type DataProviderCharacterProfile[]
        local profiles = {}
        local index = 0
        local fromIndex, toIndex = IsInRaid() and 1 or 0, GetNumGroupMembers()
        for i = fromIndex, toIndex do
            local unit = i == 0 and "player" or (IsInRaid() and "raid" or "party") .. i
            if UnitExists(unit) then
                local name, realm = util:GetNameRealm(unit)
                if name then
                    index = index + 1
                    profiles[index] = provider:GetProfile(name, realm) or false ---@diagnostic disable-line: assign-type-mismatch
                end
            end
        end
        return profiles
    end

    ---@class DungeonDifference
    ---@field public member DataProviderCharacterProfile
    ---@field public confidence number @The confidence score for this prediction. 1 = guaranteed, 2 = possibly (should check website), 3 = must check website
    ---@field public levelDiff number @The difference between current and the latest run
    ---@field public fractionalTimeDiff number @The difference between current and the latest run
    ---@field public isUpgrade boolean @If this diff is an improvement in score

    ---@param level1 number
    ---@param level2 number
    ---@param fractionalTime1 number
    ---@param fractionalTime2 number
    ---@return number, number, number, number @`arg1 = 1=left/2=right`, `arg2 = level`, `arg3 = fractionalTime`, `arg4 = confidence`
    local function CompareLevelAndFractionalTime(level1, level2, fractionalTime1, fractionalTime2)
        if not level1 or not fractionalTime1 then
            return 2, level2, fractionalTime2, 3
        elseif not level2 or not fractionalTime2 then
            return 1, level1, fractionalTime1, 3
        elseif (level1 == level2 and fractionalTime1 < fractionalTime2) or (level1 > level2 and fractionalTime1 <= (1 + (level1 - level2) * 0.1)) then
            return 1, level1, fractionalTime1, level1 == level2 and 1 or 2
        end
        return 2, level2, fractionalTime2, level1 == level2 and 1 or 2
    end

    ---@param run? SortedDungeon
    ---@param currentRun? SortedDungeon
    local function GetDungeonUpgrade(run, currentRun)
        if not run or not currentRun then
            return
        end
        local side, _, _, confidence = CompareLevelAndFractionalTime(run.level, currentRun.level, run.fractionalTime, currentRun.fractionalTime)
        ---@type DungeonDifference
        local diff = {}
        diff.confidence = confidence
        diff.levelDiff = 0
        diff.fractionalTimeDiff = 0
        if side == 1 then
            diff.levelDiff = currentRun.level - run.level
            diff.fractionalTimeDiff = currentRun.fractionalTime - run.fractionalTime
        end
        diff.isUpgrade = diff.levelDiff > 0 or (diff.levelDiff == 0 and diff.fractionalTimeDiff < 0)
        return diff
    end

    ---@param run1? SortedDungeon
    ---@param diff1? DungeonDifference
    ---@param run2? SortedDungeon
    ---@param diff2? DungeonDifference
    ---@return SortedDungeon?, DungeonDifference?
    local function CompareDungeonUpgrades(run1, diff1, run2, diff2)
        if not run2 then
            if not run1 or not run1.level then
                return
            end
            return run1, diff1
        elseif not run1 then
            if not run2 or not run2.level then
                return
            end
            return run2, diff2
        end
        local side = CompareLevelAndFractionalTime(run1.level, run2.level, run1.fractionalTime, run2.fractionalTime)
        if side == 1 then
            return run1, diff1
        end
        return run2, diff2
    end

    ---@param member DataProviderCharacterProfile
    ---@param dungeon Dungeon
    local function GetSortedDungeonForMember(member, dungeon)
        for i = 1, #member.mythicKeystoneProfile.sortedDungeons do
            local sortedDungeon = member.mythicKeystoneProfile.sortedDungeons[i]
            if sortedDungeon.dungeon == dungeon then
                if sortedDungeon.level > 0 then
                    return sortedDungeon
                end
                return
            end
        end
    end

    ---@param run SortedDungeon
    local function CopyRun(run)
        local r = {}
        r.dungeon = run.dungeon
        r.chests = run.chests
        r.level = run.level
        r.fractionalTime = run.fractionalTime
        return r
    end

    ---@param member DataProviderCharacterProfile
    ---@param currentRun SortedDungeon
    ---@return SortedDungeon, DungeonDifference @`arg1 = isUpgrade`, `arg2 = SortedDungeon`, `arg3 = DungeonDifference`
    local function GetCachedRunAndUpgrade(member, currentRun)
        local cachedRuns = _G.RaiderIO_CachedRuns
        if not cachedRuns then
            cachedRuns = {}
            _G.RaiderIO_CachedRuns = cachedRuns
        end
        if not cachedRuns.date then
            cachedRuns.date = KEYSTONE_DATE
        end
        if KEYSTONE_DATE > cachedRuns.date then
            table.wipe(cachedRuns)
        end
        local memberCachedRuns = cachedRuns[member.guid]
        if not memberCachedRuns then
            memberCachedRuns = {}
            cachedRuns[member.guid] = memberCachedRuns
        end
        local dbRun = GetSortedDungeonForMember(member, currentRun.dungeon)
        local dbRunUpgrade = GetDungeonUpgrade(dbRun, currentRun)
        local cacheRun = memberCachedRuns[currentRun.dungeon.index] ---@type SortedDungeon
        local cacheUpgrade = GetDungeonUpgrade(cacheRun, currentRun)
        local bestRun, bestUpgrade = CompareDungeonUpgrades(dbRun, dbRunUpgrade, cacheRun, cacheUpgrade)
        local bestIsCurrentRun
        if not bestRun or not bestRun.level then
            bestIsCurrentRun = true
            bestRun = CopyRun(currentRun)
            bestUpgrade = {}
        elseif bestRun == dbRun then
            bestRun = CopyRun(dbRun) ---@diagnostic disable-line: param-type-mismatch
        end
        memberCachedRuns[currentRun.dungeon.index] = bestRun
        local side = CompareLevelAndFractionalTime(bestRun.level, currentRun.level, bestRun.fractionalTime, currentRun.fractionalTime)
        if bestIsCurrentRun or side == 2 then
            bestUpgrade.confidence = 1
            if bestIsCurrentRun then
                bestUpgrade.levelDiff = currentRun.level
                bestUpgrade.fractionalTimeDiff = -currentRun.fractionalTime
            else
                bestUpgrade.levelDiff = currentRun.level - bestRun.level
                bestUpgrade.fractionalTimeDiff = currentRun.fractionalTime - bestRun.fractionalTime
            end
            bestUpgrade.isUpgrade = bestIsCurrentRun or bestUpgrade.levelDiff > 0 or (bestUpgrade.levelDiff == 0 and bestUpgrade.fractionalTimeDiff < 0) ---@diagnostic disable-line: need-check-nil
            bestRun.chests = currentRun.chests
            bestRun.level = currentRun.level
            bestRun.fractionalTime = currentRun.fractionalTime
        end
        return bestRun, bestUpgrade ---@diagnostic disable-line: return-type-mismatch
    end

    ---@param members DataProviderCharacterProfile[] @Table of group member profiles
    ---@param currentRun SortedDungeon
    local function GetDungeonUpgrades(members, currentRun)
        ---@type DungeonDifference[]
        local upgrades = {}
        local index = 0
        local hasAnyUpgrades
        for i = 1, #members do
            local member = members[i]
            if member and member.mythicKeystoneProfile and not member.mythicKeystoneProfile.blocked then
                local run, upgrade = GetCachedRunAndUpgrade(member, currentRun)
                hasAnyUpgrades = hasAnyUpgrades or upgrade.isUpgrade
                upgrade.member = member
                index = index + 1
                upgrades[index] = upgrade
            end
        end
        return upgrades, hasAnyUpgrades
    end

    local LEVEL_UP_EFFECT = {
        yellow = 166464, -- spells/levelup/levelup.m2 (yellow)
        green = 166698, -- spells/reputationlevelup.m2 (green)
        red = 240947, -- spells/levelup_red.m2 (red)
        blue = 340883, -- spells/levelup_blue.m2 (blue)
        x = -18,
        y = 0,
        z = -10,
        facing = 0,
        duration = 1.5
    }

    local function DecorationFrame_OnShow(self)
        self:SetAlpha(0)
        self.AnimIn:Play()
        if self.model then
            self.Sparks:Show()
            self.Sparks:SetModel(self.model)
        end
    end

    local function DecorationFrame_OnHide(self)
        self.AnimIn:Stop()
        self.Sparks:Hide()
    end

    local function DecorationFrame_AnimIn_Sparks_OnFinished(self)
        self.frame.Sparks:Hide()
    end

    local PERCENTILE_LOWEST = 0.01 -- 0.01%
    local PERCENTILE_LOWEST_DECIMAL = PERCENTILE_LOWEST/100 -- % to decimal

    ---@param upgrade DungeonDifference
    local function DecorationFrame_SetUp(self, upgrade)
        if upgrade.isUpgrade then
            if not upgrade.confidence or upgrade.confidence > 1 then
                self.model = LEVEL_UP_EFFECT.yellow
                self.Texture:SetAtlas("loottoast-arrow-orange")
            else
                self.model = LEVEL_UP_EFFECT.green
                self.Texture:SetAtlas("loottoast-arrow-green")
            end
            --[=[
            if upgrade.levelDiff and upgrade.levelDiff > 0 then
                self.Text:SetText(upgrade.levelDiff .. (upgrade.levelDiff > 1 and " levels" or " level") .. " higher") -- TODO: locale
            elseif upgrade.fractionalTimeDiff and upgrade.fractionalTimeDiff < 0 then
                local p = floor(upgrade.fractionalTimeDiff * -10000) / 100
                if p > 0 then
                    self.Text:SetText(p .. "% faster") -- TODO: locale
                else
                    self.Text:SetText("~" .. PERCENTILE_LOWEST .. "% faster") -- TODO: locale
                end
            else
                self.Text:SetText()
            end
            --]=]
        else
            self.model = nil
            self.Texture:SetTexture()
            --[=[
            if upgrade.levelDiff and upgrade.levelDiff < 0 then
                self.Text:SetText((-upgrade.levelDiff) .. (upgrade.levelDiff > 1 and " levels" or " level") .. " lower") -- TODO: locale
            elseif upgrade.levelDiff == 0 and upgrade.fractionalTimeDiff and upgrade.fractionalTimeDiff > 0 then
                local p = floor(upgrade.fractionalTimeDiff * 10000) / 100
                if p > 0 then
                    self.Text:SetText(p .. "% slower") -- TODO: locale
                else
                    self.Text:SetText("~" .. PERCENTILE_LOWEST .. "% slower") -- TODO: locale
                end
            elseif upgrade.levelDiff == 0 and upgrade.fractionalTimeDiff and upgrade.fractionalTimeDiff <= PERCENTILE_LOWEST_DECIMAL then
                self.Text:SetText("No change") -- TODO: locale
            else
                self.Text:SetText()
            end
            --]=]
        end
    end

    local function CreateDecorationFrame()
        local frame = CreateFrame("Frame")
        frame:Hide()
        frame:SetScript("OnShow", DecorationFrame_OnShow)
        frame:SetScript("OnHide", DecorationFrame_OnHide)
        frame.SetUp = DecorationFrame_SetUp
        do
            frame.Texture = frame:CreateTexture(nil, "ARTWORK")
            frame.Texture:SetPoint("CENTER")
            frame.Texture:SetSize(32, 32)
            frame.Texture:SetTexture(nil) ---@diagnostic disable-line: param-type-mismatch
        end
        do
            frame.Text = frame:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
            frame.Text:SetAllPoints()
            frame.Text:SetJustifyH("CENTER")
            frame.Text:SetJustifyV("MIDDLE")
            frame.Text:SetText()
        end
        do
            frame.Sparks = CreateFrame("PlayerModel", nil, frame)
            frame.Sparks:Hide()
            frame.Sparks:SetAllPoints()
            frame.Sparks:SetModel(LEVEL_UP_EFFECT.yellow)
            frame.Sparks:SetPortraitZoom(1)
            frame.Sparks:ClearTransform()
            frame.Sparks:SetPosition(LEVEL_UP_EFFECT.x, LEVEL_UP_EFFECT.y, LEVEL_UP_EFFECT.z)
            frame.Sparks:SetFacing(LEVEL_UP_EFFECT.facing)
        end
        do
            frame.AnimIn = frame:CreateAnimationGroup()
            frame.AnimIn:SetToFinalAlpha(true)
            local alpha = frame.AnimIn:CreateAnimation("Alpha")
            alpha:SetOrder(1)
            alpha:SetStartDelay(0.2)
            alpha:SetDuration(0.25)
            alpha:SetFromAlpha(0)
            alpha:SetToAlpha(1)
            local scale = frame.AnimIn:CreateAnimation("Scale")
            scale:SetOrder(1)
            scale:SetStartDelay(0.2)
            scale:SetDuration(0.25)
            scale:SetScaleFrom(5, 5)
            scale:SetScaleTo(1, 1)
            local sparks = frame.AnimIn:CreateAnimation("Scale")
            sparks:SetOrder(1)
            sparks:SetStartDelay(0)
            sparks:SetDuration(LEVEL_UP_EFFECT.duration)
            sparks:SetScaleFrom(1, 1)
            sparks:SetScaleTo(1, 1)
            sparks.frame = frame
            sparks:SetScript("OnFinished", DecorationFrame_AnimIn_Sparks_OnFinished)
        end
        return frame
    end

    local frameHooks = {}
    local frames = {}

    local function OnFrameHidden()
        for _, frame in pairs(frames) do
            frame:Hide()
        end
    end

    ---@param upgrade DungeonDifference
    local function DecoratePartyMember(partyMember, upgrade)
        if not partyMember then
            return
        end
        local frame = frames[partyMember]
        if not frame then
            frame = CreateDecorationFrame()
            frame:SetParent(partyMember)
            frame:SetAllPoints()
            frames[partyMember] = frame
        end
        frame:SetUp(upgrade)
        frame:Show()
    end

    ---@param upgrade DungeonDifference
    local function ShowUpgrade(frame, upgrade)
        local sortedUnitTokens = frame:GetSortedPartyMembers()
        for i = 1, #sortedUnitTokens do
            local unit = sortedUnitTokens[i]
            local name, realm = util:GetNameRealm(unit)
            if name and name == upgrade.member.name and realm == upgrade.member.realm then
                DecoratePartyMember(frame.PartyMembers[i], upgrade)
                break
            end
        end
    end

    ---@param dungeon Dungeon
    local function GetCurrentRun(dungeon, level, fractionalTime, keystoneUpgradeLevels)
        ---@type SortedDungeon
        local run = {}
        run.chests = keystoneUpgradeLevels
        run.dungeon = dungeon
        run.fractionalTime = fractionalTime
        run.level = level
        return run
    end

    ---@class ChallengeModeCompleteBannerData
    ---@field public mapID number @Keystone instance ID
    ---@field public level number @Keystone level
    ---@field public time number @Run duration in seconds
    ---@field public onTime number @true if on time, otherwise false if depleted
    ---@field public keystoneUpgradeLevels number @The amount of chests/level upgrades
    ---@field public oldDungeonScore number
    ---@field public newDungeonScore number
    ---@field public isAffixRecord boolean
    ---@field public isMapRecord boolean
    ---@field public primaryAffix number
    ---@field public isEligibleForScore boolean
    ---@field public upgradeMembers ChallengeModeCompletionMemberInfo[]

    ---@param bannerData ChallengeModeCompleteBannerData
    local function OnChallengeModeCompleteBannerPlay(frame, bannerData)
        if not KEYSTONE_DATE or not bannerData or not bannerData.mapID or not bannerData.time or not bannerData.level then
            return
        end
        if not fanfare:IsEnabled() then
            return
        end
        local dungeon = util:GetDungeonByKeystoneID(bannerData.mapID)
        if not dungeon then
            return
        end
        local _, _, timeLimit = C_ChallengeMode.GetMapUIInfo(bannerData.mapID)
        if not timeLimit or timeLimit == 0 then
            return
        end
        local fractionalTime = bannerData.time/timeLimit
        local members = GetGroupMembers()
        local currentRun = GetCurrentRun(dungeon, bannerData.level, fractionalTime, bannerData.keystoneUpgradeLevels)
        local upgrades, hasAnyUpgrades = GetDungeonUpgrades(members, currentRun)
        if not frameHooks[frame] then
            frameHooks[frame] = true
            frame:HookScript("OnHide", OnFrameHidden)
        end
        for i = 1, #upgrades do
            ShowUpgrade(frame, upgrades[i])
        end
    end

    local hooked

    local function TopBannerManager_Show(self)
        if hooked then
            return
        end
        local frame = _G.ChallengeModeCompleteBanner
        if not frame or frame ~= self then
            return
        end
        hooked = true
        hooksecurefunc(frame, "PlayBanner", OnChallengeModeCompleteBannerPlay)
        local mapID, level, time, onTime, keystoneUpgradeLevels, practiceRun, oldDungeonScore, newDungeonScore, isAffixRecord, isMapRecord, primaryAffix, isEligibleForScore, upgradeMembers = C_ChallengeMode.GetCompletionInfo()
        if not practiceRun then
            local bannerData = { mapID = mapID, level = level, time = time, onTime = onTime, keystoneUpgradeLevels = keystoneUpgradeLevels or 0, oldDungeonScore = oldDungeonScore, newDungeonScore = newDungeonScore, isAffixRecord = isAffixRecord, isMapRecord = isMapRecord, primaryAffix = primaryAffix, isEligibleForScore = isEligibleForScore, upgradeMembers = upgradeMembers } ---@type ChallengeModeCompleteBannerData
            OnChallengeModeCompleteBannerPlay(frame, bannerData)
        end
    end

    local function CheckCachedData()
        local cachedRuns = _G.RaiderIO_CachedRuns
        if not cachedRuns then
            return
        end
        if KEYSTONE_DATE and cachedRuns.date and KEYSTONE_DATE > cachedRuns.date then
            table.wipe(cachedRuns)
            return
        end
        local dungeons = ns:GetDungeonData()
        for _, memberCachedRuns in pairs(cachedRuns) do
            if type(memberCachedRuns) == "table" then
                for i = 1, #dungeons do
                    ---@type SortedDungeon
                    local cachedRun = memberCachedRuns[i]
                    if cachedRun then
                        cachedRun.dungeon = dungeons[i]
                    end
                end
            end
        end
    end

    function fanfare:CanLoad()
        return config:IsEnabled() and config:Get("debugMode") -- TODO: do not load this module by default (it's not yet tested well enough) but we do load it if debug mode is enabled
    end

    function fanfare:OnLoad()
        self:Enable()
        KEYSTONE_DATE = provider:GetProvidersDates()
        CheckCachedData()
        hooksecurefunc("TopBannerManager_Show", TopBannerManager_Show)
    end

    -- DEBUG: force show the end screen for MIST+15 (1800/1440/1080 is the timer)
    -- /run wipe(RaiderIO_CachedRuns)
    -- /run C_ChallengeMode.GetCompletionInfo=function()return 375, 15, 1800, true, 1, false, 123, 234, true, true, 9, nil end
    -- /run for _,f in ipairs({GetFramesRegisteredForEvent("CHALLENGE_MODE_COMPLETED")})do f:GetScript("OnEvent")(f,"CHALLENGE_MODE_COMPLETED")end

end

-- profile.lua
-- dependencies: module, callback, config, render
do

    ---@class ProfileModule : Module
    local profile = ns:NewModule("Profile") ---@type ProfileModule
    local callback = ns:GetModule("Callback") ---@type CallbackModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local render = ns:GetModule("Render") ---@type RenderModule

    local function IsFrame(widget)
        return type(widget) == "table" and type(widget.GetObjectType) == "function" and widget
    end

    local STRATA_MAP = {
        "TOOLTIP",
        "FULLSCREEN_DIALOG",
        "FULLSCREEN",
        "DIALOG",
        "HIGH",
        "MEDIUM",
        "LOW",
        "BACKGROUND",
    }

    for k, v in ipairs(STRATA_MAP) do
        STRATA_MAP[v] = k
    end

    local function GetHighestStrata(...)
        local s, o
        for _, v in ipairs({...}) do
            if type(v) == "string" then
                local c = STRATA_MAP[v]
                if not o or o > c then
                    s, o = v, c
                end
            end
        end
        return s
    end

    local fallbackFrame = _G.UIParent
    local fallbackStrata = "LOW"

    local tooltipAnchor
    local tooltip

    local tooltipAnchorPriority = {
        -- this entry is updated with the latest anchor from previous `profile:ShowProfile(anchor, ...)` call so that we can prioritize this anchor above all others
        {
            name = nil,
            strata = "TOOLTIP",
        },
        -- overrides the default PVEFrame anchor behavior when Premade Groups Filter is loaded
        {
            name = "PremadeGroupsFilterDialog",
            hook = function(anchor, frame, updatePosition)
                if not anchor.toggleHooked and IsFrame(frame.MoveableToggle) then
                    anchor.toggleHooked = true
                    frame.MoveableToggle:HookScript("OnClick", updatePosition)
                end
            end,
            usable = function(anchor, frame)
                return frame:IsShown() and (not frame.MoveableToggle or not frame.MoveableToggle:GetChecked())
            end,
        },
        -- the default PVEFrame player profile and anchor behavior
        {
            name = "PVEFrame",
            show = function(anchor, frame)
                if not frame:IsShown() or not config:Get("showRaiderIOProfile") then
                    return
                end
                profile:ShowProfile(false, "player")
            end,
            hide = function()
                profile:HideProfile()
            end,
        },
    }

    local hookedFrames = {}

    local function Eval(o, f, ...)
        if type(o) == "function" then
            return o(...)
        end
        return o or f
    end

    local function GetAnchorPoint(anchor, frame)
        return
            Eval(anchor.point, "TOPLEFT", anchor, frame),
            Eval(anchor.rpoint, "TOPRIGHT", anchor, frame),
            Eval(anchor.x, -16, anchor, frame),
            Eval(anchor.y, 0, anchor, frame),
            Eval(anchor.strata, fallbackStrata, anchor, frame)
    end

    ---@return Frame? frame, string? strata Returns the used frame and strata after logical checks have been performed on the provided frame and strata values.
    local function SetAnchor()
        for _, anchor in ipairs(tooltipAnchorPriority) do
            local frame = anchor.name
            if frame then
                frame = IsFrame(frame) or IsFrame(_G[frame])
                if frame then
                    local usable = anchor.usable
                    if usable == nil then
                        usable = true
                    elseif type(usable) == "function" then
                        usable = anchor.usable(anchor, frame)
                    end
                    if usable then
                        local p, rp, x, y, strata = GetAnchorPoint(anchor, frame)
                        strata = GetHighestStrata(strata, frame:GetFrameStrata())
                        tooltipAnchor:SetParent(frame)
                        tooltipAnchor:ClearAllPoints()
                        tooltipAnchor:SetPoint(p, frame, rp, x, y)
                        tooltipAnchor:SetFrameStrata(strata)
                        tooltip:SetFrameStrata(strata)
                        return frame, strata
                    end
                end
            end
        end
    end

    ---@class ConfigProfilePoint
    ---@field public point string|nil
    ---@field public x number|nil
    ---@field public y number|nil

    ---@return Frame frame, string strata Returns the used frame and strata after logical checks have been performed on the provided frame and strata values.
    local function SetUserAnchor()
        local profilePoint = config:Get("profilePoint") ---@type ConfigProfilePoint
        local p = profilePoint.point or "CENTER"
        local x = profilePoint.x or 0
        local y = profilePoint.y or 0
        tooltipAnchor:SetParent(fallbackFrame)
        tooltipAnchor:ClearAllPoints()
        tooltipAnchor:SetPoint(p, fallbackFrame, p, x, y)
        tooltipAnchor:SetFrameStrata(fallbackStrata)
        tooltip:SetFrameStrata(fallbackStrata)
        return fallbackFrame, fallbackStrata
    end

    ---@param isDraggable boolean
    ---@return boolean @true if frame is draggable, otherwise false.
    local function SetDraggable(self, isDraggable)
        self:EnableMouse(isDraggable)
        self:SetMovable(isDraggable)
        self.Indicator:SetShown(isDraggable)
        self.Icon:SetShown(isDraggable)
        return isDraggable
    end

    ---@return boolean isAutoPosition, Frame? frame, string? strata @arg1 returns true if position is automatic, otherwise false. `arg2+` are the same as returned from `SetAnchor` or `SetUserAnchor`.
    local function UpdatePosition(anchor, frame)
        if anchor and frame then
            if frame:IsShown() and anchor.show and type(anchor.show) == "function" then
                anchor.show(anchor, frame)
            elseif not frame:IsShown() and anchor.hide and type(anchor.hide) == "function" then
                anchor.hide(anchor, frame)
            end
        end
        SetDraggable(tooltipAnchor, not config:Get("positionProfileAuto") and not config:Get("lockProfile"))
        if config:Get("positionProfileAuto") then
            return true, SetAnchor()
        else
            return false, SetUserAnchor()
        end
    end

    local function UpdateAnchorHooks()
        for _, anchor in ipairs(tooltipAnchorPriority) do
            local frame = anchor.name
            if frame then
                frame = IsFrame(frame) or IsFrame(_G[frame])
                if frame and not hookedFrames[frame] then
                    hookedFrames[frame] = true
                    local function updatePosition() return UpdatePosition(anchor, frame) end
                    frame:HookScript("OnShow", updatePosition)
                    frame:HookScript("OnHide", updatePosition)
                    if anchor.hook and type(anchor.hook) == "function" then
                        anchor.hook(anchor, frame, updatePosition)
                    end
                end
            end
        end
    end

    local function OnDragStart(self)
        self:StartMoving()
    end

    local function OnDragStop(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint() -- TODO: improve this to store a corner so that when the tip is resized the corner is the anchor point and not the center as that makes it very wobbly and unpleasant to look at
        local profilePoint = config:Get("profilePoint") ---@type ConfigProfilePoint
        config:Set("profilePoint", profilePoint)
        profilePoint.point, profilePoint.x, profilePoint.y = point, x, y
    end

    local function CreateTooltipAnchor()
        local frame = CreateFrame("Frame", addonName .. "_ProfileTooltipAnchor", fallbackFrame)
        frame:SetFrameStrata(fallbackStrata)
        frame:SetFrameLevel(100)
        frame:SetClampedToScreen(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", OnDragStart)
        frame:SetScript("OnDragStop", OnDragStop)
        frame:SetSize(16, 16)
        frame.Indicator = frame:CreateTexture(nil, "BACKGROUND")
        frame.Indicator:SetAllPoints()
        frame.Indicator:SetColorTexture(0.3, 0.3, 0.3)
        frame.Icon = frame:CreateTexture(nil, "ARTWORK")
        frame.Icon:SetAllPoints()
        frame.Icon:SetTexture(386863)
        frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L.PROFILE_TOOLTIP_ANCHOR_TOOLTIP, 1, 1, 1)
            GameTooltip:Show()
        end)
        frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        return frame
    end

    local function CreateTooltip()
        local tooltip = CreateFrame("GameTooltip", addonName .. "_ProfileTooltip", tooltipAnchor, "GameTooltipTemplate")
        tooltip:SetClampedToScreen(true)
        tooltip:SetOwner(tooltipAnchor, "ANCHOR_NONE")
        tooltip:ClearAllPoints()
        tooltip:SetPoint("TOPLEFT", tooltipAnchor, "TOPRIGHT", 0, 0)
        tooltip:SetFrameStrata(fallbackStrata)
        tooltip:SetFrameLevel(100)
        return tooltip
    end

    local function OnSettingsSaved()
        if not profile:IsEnabled() then
            return
        end
        UpdatePosition()
    end

    local showProfileArgs

    local function OnModifierStateChanged()
        if not showProfileArgs or not showProfileArgs[1] or not showProfileArgs[2] then
            return
        end
        return profile:ShowProfile(unpack(showProfileArgs))
    end

    function profile:CanLoad()
        return not tooltip and config:IsEnabled() and _G.PVEFrame
    end

    function profile:OnLoad()
        self:Enable()
        tooltipAnchor = CreateTooltipAnchor()
        tooltip = CreateTooltip()
        UpdateAnchorHooks()
        UpdatePosition()
        callback:RegisterEvent(OnSettingsSaved, "RAIDERIO_SETTINGS_SAVED")
        callback:RegisterEvent(UpdateAnchorHooks, "ADDON_LOADED")
        callback:RegisterEvent(OnModifierStateChanged, "MODIFIER_STATE_CHANGED")
    end

    ---@return boolean, boolean? @arg1 is true if the toggle was successfull, otherwise false if we can't toggle right now. arg2 is set to true if the frame is now draggable, otherwise false for locked.
    function profile:ToggleDrag()
        if not profile:IsEnabled() then
            return false
        end
        if config:Get("positionProfileAuto") then
            ns.Print(L.WARNING_LOCK_POSITION_FRAME_AUTO)
            return false
        end
        local isLocking = not config:Get("lockProfile")
        config:Set("lockProfile", isLocking)
        if isLocking then
            ns.Print(L.LOCKING_PROFILE_FRAME)
        else
            ns.Print(L.UNLOCKING_PROFILE_FRAME)
        end
        return true, SetDraggable(tooltipAnchor, not isLocking)
    end

    local function IsPlayer(unit, name, realm, region)
        if unit and UnitExists(unit) then
            return UnitIsUnit(unit, "player")
        end
        return name == ns.PLAYER_NAME and realm == ns.PLAYER_REALM and (not region or region == ns.PLAYER_REGION)
    end

    ---@return boolean
    function profile:ShowProfile(anchor, ...)
        if not profile:IsEnabled() or not config:Get("showRaiderIOProfile") then
            return ---@diagnostic disable-line: missing-return-value
        end
        showProfileArgs = { anchor, ... }
        tooltipAnchorPriority[1].name = anchor
        UpdateAnchorHooks()
        UpdatePosition()
        local unit, name, realm, _, options, args, region = render.GetQuery(...)
        options = options or render.Preset.Profile()
        local isPlayer = IsPlayer(unit, name, realm, region)
        if not isPlayer and config:Get("enableProfileModifier") and band(options, render.Flags.IGNORE_MOD) ~= render.Flags.IGNORE_MOD then
            if config:Get("inverseProfileModifier") == (config:Get("alwaysExtendTooltip") or band(options, render.Flags.MOD) == render.Flags.MOD) then
                unit, name, realm = "player", nil, nil ---@diagnostic disable-line: cast-local-type
            end
        end
        tooltip:SetOwner(tooltipAnchor, "ANCHOR_NONE")
        tooltip:SetPoint("TOPLEFT", tooltipAnchor, "TOPRIGHT", 0, 0)
        local success
        if not isPlayer or not config:Get("hidePersonalRaiderIOProfile") then
            if unit and UnitExists(unit) then
                success = render:ShowProfile(tooltip, unit, options, args, region)
            else
                success = render:ShowProfile(tooltip, name, realm, options, args, region)
            end
        end
        if not success then
            profile:HideProfile()
        end
        return success
    end

    function profile:HideProfile()
        if not profile:IsEnabled() then
            return
        end
        if showProfileArgs then
            table.wipe(showProfileArgs)
        end
        render:HideTooltip(tooltip)
    end

end

-- lfgtooltip.lua
-- dependencies: module, config, util, render, profile
do

    ---@class LfgTooltipModule : Module
    local tooltip = ns:NewModule("LfgTooltip") ---@type LfgTooltipModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule
    local render = ns:GetModule("Render") ---@type RenderModule
    local profile = ns:GetModule("Profile") ---@type ProfileModule
    local provider = ns:GetModule("Provider") ---@type ProviderModule

    ---@class LfgResult
    ---@field public activityID number|nil
    ---@field public leaderName string
    ---@field public keystoneLevel number

    ---@type LfgResult
    local currentResult = {}

    local hooked = {}
    local OnEnter
    local OnLeave
    local cleanupPending

    local function SetSearchEntry(tooltip, resultID, autoAcceptOption)
        if not config:Get("enableLFGTooltips") then
            return
        end
        local entry = C_LFGList.GetSearchResultInfo(resultID)
        if not entry or not entry.leaderName then
            table.wipe(currentResult)
            return
        end
        local leaderFaction = util:FactionGroupToFactionId(entry.leaderFactionGroup)
        local activityInfo = C_LFGList.GetActivityInfoTable(entry.activityID, nil, entry.isWarMode)
        if activityInfo and activityInfo.isMythicPlusActivity and entry.leaderOverallDungeonScore then
            local leaderName, leaderRealm = util:GetNameRealm(entry.leaderName)
            provider:OverrideProfile(leaderName, leaderRealm, entry.leaderOverallDungeonScore)
        end
        currentResult.activityID = entry.activityID
        currentResult.leaderName = entry.leaderName
        currentResult.leaderFaction = leaderFaction
        currentResult.keystoneLevel = util:GetKeystoneLevelFromText(entry.title) or util:GetKeystoneLevelFromText(entry.description) or 0
        local success1 = render:ShowProfile(tooltip, currentResult.leaderName, render.Preset.Unit(render.Flags.MOD_STICKY), currentResult)
        local success2 = profile:ShowProfile(tooltip, currentResult.leaderName, currentResult)
        if success1 or success2 then
            if not hooked[tooltip] then
                hooked[tooltip] = true
                tooltip:HookScript("OnHide", function()
                    if not cleanupPending then
                        return
                    end
                    cleanupPending = nil
                    OnLeave()
                end)
            end
            cleanupPending = true
        end
    end

    local function HookApplicantButtons(buttons)
        for _, button in pairs(buttons) do
            if not hooked[button] then
                hooked[button] = true
                button:HookScript("OnEnter", OnEnter)
                button:HookScript("OnLeave", OnLeave)
            end
        end
    end

    local function ShowApplicantProfile(parent, applicantID, memberIdx)
        local fullName, _, _, _, _, _, _, _, _, _, _, dungeonScore, _, factionGroup = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx)
        if not fullName then
            return false
        end
        if dungeonScore then
            local name, realm = util:GetNameRealm(fullName)
            provider:OverrideProfile(name, realm, dungeonScore)
        end
        local ownerSet, ownerExisted, ownerSetSame = util:SetOwnerSafely(GameTooltip, parent, "ANCHOR_NONE", 0, 0)
        if render:ShowProfile(GameTooltip, fullName, render.Preset.Unit(render.Flags.MOD_STICKY), currentResult) then
            return true, fullName
        end
        if ownerSet and not ownerExisted and ownerSetSame then
            GameTooltip:Hide()
        end
        return false
    end

    local function OnScroll()
        GameTooltip:Hide()
        util:ExecuteWidgetOnEnterSafely(GetMouseFocus())
    end

    function OnEnter(self)
        local entry = C_LFGList.GetActiveEntryInfo()
        if entry then
            currentResult.activityID = entry.activityID
        end
        if not currentResult.activityID or not config:Get("enableLFGTooltips") then
            return
        end
        if self.applicantID and self.Members then
            HookApplicantButtons(self.Members)
        elseif self.memberIdx then
            local shown, fullName = ShowApplicantProfile(self, self:GetParent().applicantID, self.memberIdx)
            local success
            if shown then
                success = profile:ShowProfile(GameTooltip, fullName, currentResult)
            else
                success = profile:ShowProfile(false, "player", currentResult)
            end
            if not success then
                profile:HideProfile()
            end
        end
    end

    function OnLeave(self)
        GameTooltip:Hide()
        profile:HideProfile()
        profile:ShowProfile(false, "player")
    end

    function tooltip:CanLoad()
        return profile:IsEnabled() and LFGListFrame and LFGListFrame.SearchPanel and LFGListFrame.ApplicationViewer
    end

    function tooltip:OnLoad()
        self:Enable()
        -- the player looking at groups
        hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", SetSearchEntry)
        local hookMap = { OnEnter = OnEnter, OnLeave = OnLeave }
        ScrollBoxUtil:OnViewFramesChanged(LFGListFrame.SearchPanel.ScrollBox, function(buttons) HookUtil:MapOn(buttons, hookMap) end)
        ScrollBoxUtil:OnViewScrollChanged(LFGListFrame.SearchPanel.ScrollBox, OnScroll)
        -- the player hosting a group looking at applicants
        ScrollBoxUtil:OnViewFramesChanged(LFGListFrame.ApplicationViewer.ScrollBox, function(buttons) HookUtil:MapOn(buttons, hookMap) end)
        ScrollBoxUtil:OnViewScrollChanged(LFGListFrame.ApplicationViewer.ScrollBox, OnScroll)
        -- remove the shroud and allow hovering over people even when not the group leader
        do
            local f = _G.LFGListFrame.ApplicationViewer.UnempoweredCover
            f:EnableMouse(false)
            f:EnableMouseWheel(false)
            f:SetToplevel(false)
        end
    end

end

-- guildtooltip.lua
-- dependencies: module, config, util, render
do

    ---@class GuildTooltipModule : Module
    local tooltip = ns:NewModule("GuildTooltip") ---@type GuildTooltipModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule
    local render = ns:GetModule("Render") ---@type RenderModule

    local function OnEnter(self)
        if not self.guildIndex or not config:Get("enableGuildTooltips") then
            return
        end
        local fullName, _, _, level = GetGuildRosterInfo(self.guildIndex)
        if not fullName or not util:IsMaxLevel(level) then ---@diagnostic disable-line: param-type-mismatch
            return
        end
        local ownerSet, ownerExisted, ownerSetSame = util:SetOwnerSafely(GameTooltip, self, "ANCHOR_TOPLEFT", 0, 0)
        if render:ShowProfile(GameTooltip, fullName, render.Preset.UnitSmartPadding(ownerExisted)) then
            return
        end
        if ownerSet and not ownerExisted and ownerSetSame then
            GameTooltip:Hide()
        end
    end

    local function OnLeave(self)
        if not self.guildIndex or not config:Get("enableGuildTooltips") then
            return
        end
        GameTooltip:Hide()
    end

    local function OnScroll()
        if not config:Get("enableGuildTooltips") then
            return
        end
        GameTooltip:Hide()
        util:ExecuteWidgetOnEnterSafely(GetMouseFocus())
    end

    function tooltip:CanLoad()
        return GuildRosterContainer
    end

    function tooltip:OnLoad()
        self:Enable()
        local hookMap = { OnEnter = OnEnter, OnLeave = OnLeave }
        ScrollBoxUtil:OnViewFramesChanged(GuildRosterContainer, function(buttons) HookUtil:MapOn(buttons, hookMap) end)
        ScrollBoxUtil:OnViewScrollChanged(GuildRosterContainer, OnScroll)
    end

end

-- communitytooltip.lua
-- dependencies: module, config, util, render
do

    ---@class CommunityTooltipModule : Module
    local tooltip = ns:NewModule("CommunityTooltip") ---@type CommunityTooltipModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule
    local render = ns:GetModule("Render") ---@type RenderModule

    local hooked = {}
    local completed

    local function OnEnter(self)
        if not config:Get("enableGuildTooltips") then
            return
        end
        local clubType
        local nameAndRealm
        local level
        local faction = ns.PLAYER_FACTION
        if type(self.GetMemberInfo) == "function" then
            local info = self:GetMemberInfo()
            -- function exists but returns null when on "Pending Invites" header
            if not info then
                return
            end
            clubType = info.clubType
            nameAndRealm = info.name
            level = info.level
        elseif type(self.cardInfo) == "table" then
            nameAndRealm = util:GetNameRealm(self.cardInfo.guildLeader)
            if self.cardInfo.isCrossFaction then
                -- TODO: NYI
            end
        else
            return
        end
        if type(self.GetLastPosterGUID) == "function" then
            local playerGUID = self:GetLastPosterGUID()
            if playerGUID then
                local _, _, _, race = GetPlayerInfoByGUID(playerGUID)
                if race then
                    faction = util:GetFactionFromRace(race, faction)
                end
            end
        end
        if (clubType and clubType ~= Enum.ClubType.Guild and clubType ~= Enum.ClubType.Character) or not nameAndRealm or not util:IsMaxLevel(level, true) then
            return
        end
        local ownerSet, ownerExisted, ownerSetSame = util:SetOwnerSafely(GameTooltip, self, "ANCHOR_LEFT", 0, 0)
        if render:ShowProfile(GameTooltip, nameAndRealm, render.Preset.UnitSmartPadding(ownerExisted)) then
            return
        end
        if ownerSet and not ownerExisted and ownerSetSame then
            GameTooltip:Hide()
        end
    end

    local function OnLeave(self)
        if not config:Get("enableGuildTooltips") then
            return
        end
        GameTooltip:Hide()
    end

    local function SmartHookButtons(buttons)
        if not buttons then
            return
        end
        local numButtons = 0
        for _, button in pairs(buttons) do
            numButtons = numButtons + 1
            if not hooked[button] then
                hooked[button] = true
                button:HookScript("OnEnter", OnEnter)
                button:HookScript("OnLeave", OnLeave)
                if type(button.OnEnter) == "function" then hooksecurefunc(button, "OnEnter", OnEnter) end
                if type(button.OnLeave) == "function" then hooksecurefunc(button, "OnLeave", OnLeave) end
                -- TODO: NYI button.RequestJoin
            end
        end
        return numButtons > 0
    end

    local function OnRefreshApplyHooks()
        if completed then
            return
        end
        SmartHookButtons(_G.ClubFinderGuildFinderFrame.GuildCards.Cards)
        SmartHookButtons(_G.ClubFinderGuildFinderFrame.PendingGuildCards.Cards)
        SmartHookButtons(_G.ClubFinderCommunityAndGuildFinderFrame.GuildCards.Cards)
        SmartHookButtons(_G.ClubFinderCommunityAndGuildFinderFrame.PendingGuildCards.Cards)
        return true
    end

    local function OnScroll()
        if not config:Get("enableGuildTooltips") then
            return
        end
        GameTooltip:Hide()
        util:ExecuteWidgetOnEnterSafely(GetMouseFocus())
    end

    function tooltip:CanLoad()
        return CommunitiesFrame and ClubFinderGuildFinderFrame and ClubFinderCommunityAndGuildFinderFrame
    end

    function tooltip:OnLoad()
        self:Enable()
        ScrollBoxUtil:OnViewFramesChanged(CommunitiesFrame.MemberList.ScrollBox, SmartHookButtons) -- TODO: DF
        ScrollBoxUtil:OnViewScrollChanged(CommunitiesFrame.MemberList.ScrollBox, OnScroll) -- TODO: DF
        ScrollBoxUtil:OnViewFramesChanged(ClubFinderGuildFinderFrame.CommunityCards.ScrollBox, SmartHookButtons) -- TODO: DF
        ScrollBoxUtil:OnViewScrollChanged(ClubFinderGuildFinderFrame.CommunityCards.ScrollBox, OnScroll) -- TODO: DF
        ScrollBoxUtil:OnViewFramesChanged(ClubFinderGuildFinderFrame.PendingCommunityCards.ScrollBox, SmartHookButtons) -- TODO: DF
        ScrollBoxUtil:OnViewScrollChanged(ClubFinderGuildFinderFrame.PendingCommunityCards.ScrollBox, OnScroll) -- TODO: DF
        ScrollBoxUtil:OnViewFramesChanged(ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ScrollBox, SmartHookButtons) -- TODO: DF
        ScrollBoxUtil:OnViewScrollChanged(ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ScrollBox, OnScroll) -- TODO: DF
        ScrollBoxUtil:OnViewFramesChanged(ClubFinderCommunityAndGuildFinderFrame.PendingCommunityCards.ScrollBox, SmartHookButtons) -- TODO: DF
        ScrollBoxUtil:OnViewScrollChanged(ClubFinderCommunityAndGuildFinderFrame.PendingCommunityCards.ScrollBox, OnScroll) -- TODO: DF
        hooksecurefunc(ClubFinderGuildFinderFrame.GuildCards, "RefreshLayout", OnRefreshApplyHooks)
        hooksecurefunc(ClubFinderGuildFinderFrame.PendingGuildCards, "RefreshLayout", OnRefreshApplyHooks)
        hooksecurefunc(ClubFinderCommunityAndGuildFinderFrame.GuildCards, "RefreshLayout", OnRefreshApplyHooks)
        hooksecurefunc(ClubFinderCommunityAndGuildFinderFrame.PendingGuildCards, "RefreshLayout", OnRefreshApplyHooks)
    end

end

-- keystonetooltip.lua
-- dependencies: module, config, render
do

    ---@class KeystoneTooltipModule : Module
    local tooltip = ns:NewModule("KeystoneTooltip") ---@type KeystoneTooltipModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local render = ns:GetModule("Render") ---@type RenderModule

    local KEYSTONE_PATTERN = "keystone:(%d+):(.-):(.-):(.-):(.-):(.-):(.-)"
    local KEYSTONE_ITEM_PATTERN_1 = "item:(187786):.-:.-:.-:.-:.-:.-:.-:.-:.-:.-:.-:.-:(%d+):(%d+):(%d+):(%d+):(%d+):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-)"
    local KEYSTONE_ITEM_PATTERN_2 = "item:(180653):.-:.-:.-:.-:.-:.-:.-:.-:.-:.-:.-:.-:(%d+):(%d+):(%d+):(%d+):(%d+):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-)"

    ---@type table<table, KeystoneInfo>
    local currentKeystone = {}

    local function GetKeystoneInfo(link)
        local item, instance, level, affix1, affix2, affix3, affix4, _ = link:match(KEYSTONE_PATTERN)
        if not item then
            item, _, _, instance, _, level, _, affix1, _, affix2, _, affix3, _, affix4 = link:match(KEYSTONE_ITEM_PATTERN_1)
        end
        if not item then
            item, _, _, instance, _, level, _, affix1, _, affix2, _, affix3, _, affix4 = link:match(KEYSTONE_ITEM_PATTERN_2)
        end
        if item then
            item, instance, level, affix1, affix2, affix3, affix4 = tonumber(item), tonumber(instance), tonumber(level), tonumber(affix1), tonumber(affix2), tonumber(affix3), tonumber(affix4)
        end
        return item, instance, level, affix1, affix2, affix3, affix4
    end

    ---@param keystone KeystoneInfo
    local function UpdateKeystoneInfo(keystone, link)
        keystone.link = link
        keystone.item, keystone.instance, keystone.level, keystone.affix1, keystone.affix2, keystone.affix3, keystone.affix4 = GetKeystoneInfo(link)
        return keystone.link and keystone.level
    end

    local function OnTooltipSetItem(self)
        if self ~= GameTooltip and self ~= ItemRefTooltip then
            return
        end
        if not config:Get("enableKeystoneTooltips") then
            return
        end
        local _, link = self:GetItem()
        if not link or type(link) ~= "string" then
            return
        end
        local keystone = currentKeystone[self]
        if not keystone then
            keystone = {}
            currentKeystone[self] = keystone
        end
        if not UpdateKeystoneInfo(keystone, link) then
            return
        end
        render:ShowKeystone(self, keystone)
    end

    local function OnTooltipCleared(self)
        render:ClearTooltip(self)
    end

    local function OnHide(self)
        render:HideTooltip(self)
    end

    function tooltip:OnLoad()
        self:Enable()
        if TooltipDataProcessor then -- TODO: DF
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
        else
            GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
            ItemRefTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
        end
        GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
        GameTooltip:HookScript("OnHide", OnHide)
        ItemRefTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
        ItemRefTooltip:HookScript("OnHide", OnHide)
    end

end

-- guildweekly.lua
-- dependencies: module, callback, config, util
do

    ---@class GuildWeeklyModule : Module
    local guildweekly = ns:NewModule("GuildWeekly") ---@type GuildWeeklyModule
    local callback = ns:GetModule("Callback") ---@type CallbackModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule

    local CLASS_FILENAME_TO_ID = {
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
        DEMONHUNTER = 12
    }

    ---@param runInfo ChallengeModeGuildTopAttempt
    local function ConvertRunData(runInfo)
        local dungeon = util:GetDungeonByKeystoneID(runInfo.mapChallengeModeID)
        ---@type GuildMythicKeystoneRun
        local runData = {
            zone_id = dungeon and dungeon.id or 0, ---@diagnostic disable-line: need-check-nil
            level = runInfo.keystoneLevel or 0,
            upgrades = 0,
            party = {},
        }
        for i = 1, #runInfo.members do
            local member = runInfo.members[i]
            runData.party[i] = {
                name = member.name,
                class_id = CLASS_FILENAME_TO_ID[member.classFileName] or 0
            }
        end
        return runData
    end

    ---@return GuildCollection
    local function GetGuildScoreboard()
        local scoreboard = C_ChallengeMode.GetGuildLeaders()
        local data = {}
        for i = 1, #scoreboard do
            data[#data + 1] = ConvertRunData(scoreboard[i])
        end
        return { weekly_best = data }
    end

    local function GetGuildFullName(unit)
        local guildName, _, _, guildRealm = GetGuildInfo(unit)
        if not guildName then
            return
        end
        if not guildRealm then
            _, guildRealm = util:GetNameRealm(unit)
        end
        return guildName .. "-" .. guildRealm
    end

    ---@class GuildWeeklyFrameMixin
    ---@field public offset number @The scroll offset.
    ---@field public Refresh function @Refreshes the frame with new data.
    ---@field public SetUp function @Prepares the frame by loading it with data from our guild.
    ---@field public Reset function @Resets the frame back to empty.
    ---@field public SwitchBestRun function @Toggles between this week and overall for the season.
    ---@field public OnMouseWheel function @When scrolled list goes up or down.

    ---@class GuildWeeklyRunMixin
    ---@field public SetUp function @Sets up the run using the provided info.

    ---@class GuildWeeklyBestNoRun
    ---@field public Text FontString

    ---@class GuildWeeklyRun : GuildWeeklyRunMixin
    ---@field public CharacterName FontString
    ---@field public Level FontString

    ---@class GuildWeeklyFrame : GuildWeeklyFrameMixin
    ---@field public maxVisible number
    ---@field public Title FontString
    ---@field public SubTitle FontString
    ---@field public GuildBestNoRun GuildWeeklyBestNoRun
    ---@field public SwitchGuildBest CheckButton
    ---@field public GuildBests GuildWeeklyRun[]

    ---@type GuildWeeklyFrame
    local frame

    ---@type GuildWeeklyRunMixin
    local GuildWeeklyRunMixin = {}

    ---@param runInfo GuildMythicKeystoneRun
    ---@return boolean? @true if successfull, otherwise false if we can't display this run
    function GuildWeeklyRunMixin:SetUp(runInfo)
        self.runInfo = runInfo
        if not runInfo then
            return
        end
        runInfo.dungeon = runInfo.dungeon or util:GetDungeonByID(runInfo.zone_id)
        if not runInfo.dungeon then
            return
        end
        runInfo.dungeonName = C_ChallengeMode.GetMapUIInfo(runInfo.dungeon.keystone_instance) or runInfo.dungeon.name
        self.CharacterName:SetText(runInfo.dungeonName)
        self.Level:SetText(util:GetNumChests(runInfo.upgrades) .. runInfo.level)
        if runInfo.clear_time and runInfo.upgrades == 0 then
            self.Level:SetTextColor(0.62, 0.62, 0.62)
        else
            self.Level:SetTextColor(1, 1, 1)
        end
        self:Show()
    end

    local function RunFrame_OnEnter(self)
        local runInfo = self.runInfo ---@type GuildMythicKeystoneRun
        if not runInfo then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(runInfo.dungeonName, 1, 1, 1)
        local chestsText = ""
        if runInfo.upgrades > 0 then
            chestsText = " (" .. util:GetNumChests(runInfo.upgrades) .. ")"
        end
        GameTooltip:AddLine(MYTHIC_PLUS_POWER_LEVEL:format(runInfo.level) .. chestsText, 1, 1, 1)
        if runInfo.clear_time then
            GameTooltip:AddLine(runInfo.clear_time, 1, 1, 1)
        end
        if runInfo.party then
            GameTooltip:AddLine(" ")
            for _, member in ipairs(runInfo.party) do
                local classInfo = C_CreatureInfo.GetClassInfo(member.class_id)
                local color = (classInfo and RAID_CLASS_COLORS[classInfo.classFile]) or NORMAL_FONT_COLOR
                local texture
                if member.role == "tank" or member.role == "TANK" then
                    texture = CreateAtlasMarkup("roleicon-tiny-tank")
                elseif member.role == "dps" or member.role == "DAMAGER" then
                    texture = CreateAtlasMarkup("roleicon-tiny-dps")
                elseif member.role == "healer" or member.role == "HEALER" then
                    texture = CreateAtlasMarkup("roleicon-tiny-healer")
                end
                if texture then
                    GameTooltip:AddLine(MYTHIC_PLUS_LEADER_BOARD_NAME_ICON:format(texture, member.name), color.r, color.g, color.b)
                else
                    GameTooltip:AddLine(member.name, color.r, color.g, color.b)
                end
            end
        end
        GameTooltip:Show()
    end

    local function CreateRunFrame()
        ---@type GuildWeeklyRun
        local frame = CreateFrame("Frame")
        -- inherit from the mixin
        for k, v in pairs(GuildWeeklyRunMixin) do
            frame[k] = v
        end
        -- character name
        do
            frame.CharacterName = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalTiny2")
            frame.CharacterName:SetJustifyH("LEFT")
            frame.CharacterName:SetSize(70, 13)
            frame.CharacterName:SetPoint("LEFT")
            frame.CharacterName:SetTextColor(1, 1, 1)
        end
        -- keystone level
        do
            frame.Level = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalTiny2")
            frame.Level:SetJustifyH("RIGHT")
            frame.Level:SetSize(25, 13)
            frame.Level:SetPoint("RIGHT")
            frame.Level:SetTextColor(1, 1, 1)
        end
        -- the look and feel, anchoring and final touches
        do
            frame:SetSize(95, 13)
            frame:SetScript("OnEnter", RunFrame_OnEnter)
            frame:SetScript("OnLeave", GameTooltip_Hide)
        end
        -- finalize and return the frame
        return frame
    end

    ---@type GuildWeeklyFrameMixin
    local GuildWeeklyFrameMixin = {}

    function GuildWeeklyFrameMixin:Refresh()
        local guildName = GetGuildFullName("player")
        if not guildName then
            self:Hide()
            self:Reset()
            return
        end
        self:Show()
        self:SetUp(guildName)
    end

    function GuildWeeklyFrameMixin:SetUp(guildName)
        self:Reset()

        local guildsData = ns:GetClientGuildData()
        local guildData = guildsData and guildsData[guildName] ---@type GuildCollection

        local keyBest = "season_best"
        local title = L.GUILD_BEST_SEASON
        local blizzScoreboard

        if not guildData or config:Get("displayWeeklyGuildBest") then
            if not guildData then
                blizzScoreboard = true
                guildData = GetGuildScoreboard() ---@type GuildCollection
            end
            keyBest = "weekly_best"
            title = L.GUILD_BEST_WEEKLY
        end

        self.SubTitle:SetText(title)
        self.SwitchGuildBest:SetShown(guildData and not blizzScoreboard)

        local switchShown = self.SwitchGuildBest:IsShown()
        local switchHeight = self.SwitchGuildBest:GetHeight()
        local switchRealHeight = switchShown and switchHeight or 0
        local currentRuns = guildData and guildData[keyBest] ---@type GuildMythicKeystoneRun[]

        if not currentRuns or not currentRuns[1] then
            self.GuildBestNoRun:Show()
            self:SetHeight(35 + 15 + switchRealHeight)
            return
        end

        local numRuns = #currentRuns

        if numRuns <= self.maxVisible then
            self.offset = 0
        end

        local numVisibleRuns = min(numRuns, self.maxVisible)

        for i = 1, numVisibleRuns do
            self.GuildBests[i]:SetUp(currentRuns[i + self.offset])
        end

        if self:IsMouseOver() then
            local focus = GetMouseFocus()
            if focus and focus ~= GameTooltip:GetOwner() then
                util:ExecuteWidgetOnEnterSafely(focus)
            end
        end

        self:SetHeight(35 + (numVisibleRuns > 0 and numVisibleRuns * self.GuildBests[1]:GetHeight() or 0) + switchRealHeight)

        return numRuns, numVisibleRuns
    end

    function GuildWeeklyFrameMixin:Reset()
        self.offset = 0
        self.GuildBestNoRun:Hide()
        self.GuildBestNoRun.Text:SetText(L.NO_GUILD_RECORD)
        for _, frame in ipairs(self.GuildBests) do
            frame:Hide()
            frame:SetUp()
        end
    end

    function GuildWeeklyFrameMixin:SwitchBestRun()
        local displayWeeklyGuildBest = not config:Get("displayWeeklyGuildBest")
        config:Set("displayWeeklyGuildBest", displayWeeklyGuildBest)
        self:Refresh()
    end

    local function GuildWeeklyFrame_OnMouseWheel(self, delta)
        self.offset = max(0, min(self.maxVisible, delta > 0 and -1 or 1))
        self:Refresh()
    end

    local function GuildWeeklyFrameSwitch_OnShow(self)
        self:SetChecked(config:Get("displayWeeklyGuildBest"))
    end

    local function GuildWeeklyFrameSwitch_OnClick(self)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        self:GetParent():SwitchBestRun()
    end

    local function CreateGuildWeeklyFrame()
        ---@type GuildWeeklyFrame
        local frame = CreateFrame("Frame", addonName .. "_GuildWeeklyFrame", ChallengesFrame, BackdropTemplateMixin and "BackdropTemplate")
        frame.maxVisible = 5
        -- inherit from the mixin
        for k, v in pairs(GuildWeeklyFrameMixin) do
            frame[k] = v
        end
        -- title
        do
            frame.Title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalTiny2")
            frame.Title:SetJustifyH("CENTER")
            frame.Title:SetPoint("TOPLEFT", 10, -8)
            frame.Title:SetTextColor(1, 0.85, 0)
            frame.Title:SetShadowColor(0, 0, 0)
            frame.Title:SetShadowOffset(1, -1)
            frame.Title:SetText(L.GUILD_BEST_TITLE)
        end
        -- sub title
        do
            frame.SubTitle = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalTiny2")
            frame.SubTitle:SetJustifyH("CENTER")
            frame.SubTitle:SetPoint("TOPLEFT", 10, -18)
            frame.SubTitle:SetTextColor(1, 0.85, 0, 0.8)
            frame.SubTitle:SetShadowColor(0, 0, 0)
            frame.SubTitle:SetShadowOffset(1, -1)
        end
        -- no runs available overlay
        do
            frame.GuildBestNoRun = CreateFrame("Frame", nil, frame) ---@diagnostic disable-line: param-type-mismatch
            frame.GuildBestNoRun:SetSize(95, 13)
            frame.GuildBestNoRun:SetPoint("TOPLEFT", frame.Title, "BOTTOMLEFT", 0, -14)
            frame.GuildBestNoRun.Text = frame.GuildBestNoRun:CreateFontString(nil, "ARTWORK", "GameFontNormalTiny2")
            frame.GuildBestNoRun.Text:SetJustifyH("LEFT")
            frame.GuildBestNoRun.Text:SetSize(150, 0)
            frame.GuildBestNoRun.Text:SetPoint("LEFT")
            frame.GuildBestNoRun.Text:SetTextColor(1, 1, 1)
        end
        -- toggle between weekly and season best
        do
            frame.SwitchGuildBest = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate") ---@diagnostic disable-line: param-type-mismatch
            frame.SwitchGuildBest:SetSize(15, 15)
            frame.SwitchGuildBest:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 8, 5) ---@diagnostic disable-line: param-type-mismatch
            frame.SwitchGuildBest:SetScript("OnShow", GuildWeeklyFrameSwitch_OnShow)
            frame.SwitchGuildBest:SetScript("OnClick", GuildWeeklyFrameSwitch_OnClick)
            frame.SwitchGuildBest.text:SetFontObject("GameFontNormalTiny2")
            frame.SwitchGuildBest.text:SetJustifyH("LEFT")
            frame.SwitchGuildBest.text:SetPoint("LEFT", 15, 0)
            frame.SwitchGuildBest.text:SetText(L.CHECKBOX_DISPLAY_WEEKLY)
        end
        -- create the guild best run frames
        do
            ---@type GuildWeeklyRun[]
            frame.GuildBests = {}
            for i = 1, 20 do
                local runFrame = CreateRunFrame()
                runFrame:SetParent(frame)
                if i == 1 then
                    runFrame:SetPoint("TOPLEFT", frame.Title, "BOTTOMLEFT", 0, -13)
                else
                    local prevRun = frame.GuildBests[i - 1]
                    runFrame:SetPoint("TOP", prevRun, "BOTTOM")
                end
                frame.GuildBests[i] = runFrame
            end
        end
        -- the look and feel, anchoring and final touches
        do
            -- look and feel
            frame:SetScale(1.2)
            frame:SetFrameStrata("MEDIUM")
            frame:SetSize(115, 115)
            if frame.SetBackdrop then
                frame:SetBackdrop(BACKDROP_TUTORIAL_16_16)
                frame:SetBackdropBorderColor(1, 1, 1, 1)
                frame:SetBackdropColor(0, 0, 0, 0.6)
            end
            -- update anchor
            frame:ClearAllPoints()
            if IsAddOnLoaded("AngryKeystones") then
                frame:SetPoint("TOPRIGHT", ChallengesFrame, "TOPRIGHT", -6, -22)
            else
                frame:SetPoint("BOTTOMLEFT", ChallengesFrame.DungeonIcons[1], "TOPLEFT", 2, 12)
            end
            -- mousewheel scrolling
            frame:EnableMouseWheel(true)
            frame:SetScript("OnMouseWheel", GuildWeeklyFrame_OnMouseWheel)
        end
        -- finalize and return the frame
        frame:Reset()
        return frame
    end

    local function UpdateShown()
        if config:Get("showClientGuildBest") then
            frame:Refresh()
        else
            frame:Hide()
        end
    end

    function guildweekly:CanLoad()
        return not frame and config:IsEnabled() and _G.PVEFrame and _G.ChallengesFrame
    end

    function guildweekly:OnLoad()
        self:Enable()
        frame = CreateGuildWeeklyFrame()
        UpdateShown()
        callback:RegisterEvent(UpdateShown, "RAIDERIO_SETTINGS_SAVED")
        PVEFrame:HookScript("OnShow", UpdateShown)
        ChallengesFrame:HookScript("OnShow", UpdateShown)
        callback:RegisterEvent(UpdateShown, "CHALLENGE_MODE_LEADERS_UPDATE")
    end

end

-- search.lua
-- dependencies: module, config, util, provider, render, profile
do

    ---@class SearchModule : Module
    local search = ns:NewModule("Search") ---@type SearchModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule
    local provider = ns:GetModule("Provider") ---@type ProviderModule
    local render = ns:GetModule("Render") ---@type RenderModule
    local profile = ns:GetModule("Profile") ---@type ProfileModule

    local function SortByName(a, b)
        return strcmputf8i(a.name, b.name) < 0
    end

    local PROVIDERS = provider:GetProviders()
    local REGIONS

    local function GetCachedRegions()
        if REGIONS then
            return REGIONS
        end
        REGIONS = {}
        local unique = {}
        for _, dataProvider in ipairs(PROVIDERS) do
            local regionName = dataProvider.region
            if not unique[regionName] then
                unique[regionName] = true
                REGIONS[#REGIONS + 1] = {
                    name = regionName,
                    priority = 7
                }
            end
        end
        table.sort(REGIONS, SortByName)
        return REGIONS
    end

    local function GetRegions(text, maxResults, cursorPosition)
        text = text:lower()
        local regions = GetCachedRegions()
        local temp = {}
        local unique = {}
        local count = 0
        for _, region in ipairs(regions) do
            if count >= maxResults then
                break
            end
            local regionName = region.name
            if not unique[regionName] and regionName:find(text, nil, true) == 1 then
                unique[regionName] = true
                count = count + 1
                temp[count] = {
                    name = regionName,
                    priority = 7
                }
            end
        end
        table.wipe(unique)
        return temp
    end

    local searchFrame
    local searchRegionBox
    local searchRealmBox
    local searchNameBox
    local searchTooltip

    local function GetRegionName()
        return (searchRegionBox:GetText() and searchRegionBox:GetText() ~= "") and searchRegionBox:GetText() or ns.PLAYER_REGION
    end

    local function GetRegionProviders()
        local regionName = GetRegionName()
        local temp ---@type DataProvider[]
        for i = 1, #PROVIDERS do
            local dataProvider = PROVIDERS[i]
            if dataProvider.region == regionName then
                if not temp then temp = {} end
                temp[#temp + 1] = dataProvider
            end
        end
        return temp
    end

    local function GetRealms(text, maxResults, cursorPosition)
        local providers = GetRegionProviders()
        if not providers then
            return
        end
        text = text:lower()
        local temp = {}
        local count = 0
        local unique = {}
        local data
        local kl
        for x = 1, #providers do
            if count >= maxResults then
                break
            end
            local dataProvider = providers[x]
            data = dataProvider.db
            if data then
                for k, _ in pairs(data) do
                    if count >= maxResults then
                        break
                    end
                    kl = k:lower()
                    if not unique[kl] and kl:find(text, nil, true) == 1 then
                        unique[kl] = true
                        count = count + 1
                        temp[count] = {
                            name = k,
                            priority = 7
                        }
                    end
                end
            end
        end
        table.wipe(unique)
        table.sort(temp, SortByName)
        return temp
    end

    local function GetNames(text, maxResults, cursorPosition)
        local providers = GetRegionProviders()
        if not providers then
            return
        end
        text = text:lower()
        local realm = searchRealmBox:GetText()
        if not realm or strlenutf8(realm) < 1 then return end
        local temp = {}
        local rcount = 0
        local data
        local count
        local name
        local namel
        local unique = {}
        for x = 1, #providers do
            if rcount >= maxResults then
                break
            end
            local dataProvider = providers[x]
            data = dataProvider.db
            if data then
                data = data[realm]
                if data then
                    count = #data
                    for j = 2, count do
                        if rcount >= maxResults then
                            break
                        end
                        name = data[j]
                        namel = name:lower()
                        if not unique[namel] and namel:find(text, nil, true) == 1 then
                            rcount = rcount + 1
                            unique[namel] = true
                            temp[rcount] = {
                                name = name,
                                priority = 7
                            }
                        end
                    end
                end
            end
        end
        table.sort(temp, SortByName)
        return temp
    end

    local function CreateEditBox()
        local f = CreateFrame("EditBox", nil, UIParent, "AutoCompleteEditBoxTemplate")
        -- autocomplete
        f.autoComplete = AutoCompleteBox
        f.autoCompleteParams = { include = AUTOCOMPLETE_FLAG_ALL, exclude = AUTOCOMPLETE_FLAG_NONE }
        -- onload
        f:SetFontObject("ChatFontNormal")
        f:SetSize(256, 32)
        f:SetAutoFocus(false)
        f:SetAltArrowKeyMode(true)
        f:SetHistoryLines(32)
        f:SetMaxLetters(32)
        f:SetMaxBytes(256)
        -- background
        f.texLeft = f:CreateTexture(nil, "BACKGROUND")
        f.texLeft:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Left2")
        f.texLeft:SetSize(32, 32)
        f.texLeft:SetPoint("LEFT", -16, 0)
        f.texRight = f:CreateTexture(nil, "BACKGROUND")
        f.texRight:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Right2")
        f.texRight:SetSize(32, 32)
        f.texRight:SetPoint("RIGHT", 16, 0)
        f.texMid = f:CreateTexture(nil, "BACKGROUND")
        f.texMid:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Mid2")
        f.texMid:SetSize(0, 32)
        f.texMid:SetPoint("TOPLEFT", f.texLeft, "TOPRIGHT", 0, 0)
        f.texMid:SetPoint("TOPRIGHT", f.texRight, "TOPLEFT", 0, 0)
        -- border
        f.texFocusLeft = f:CreateTexture(nil, "BORDER")
        f.texFocusLeft:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorderFocus-Left")
        f.texFocusLeft:SetSize(32, 32)
        f.texFocusLeft:SetPoint("LEFT", -16, 0)
        f.texFocusRight = f:CreateTexture(nil, "BORDER")
        f.texFocusRight:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorderFocus-Right")
        f.texFocusRight:SetSize(32, 32)
        f.texFocusRight:SetPoint("RIGHT", 16, 0)
        f.texFocusMid = f:CreateTexture(nil, "BORDER")
        f.texFocusMid:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorderFocus-Mid")
        f.texFocusMid:SetSize(0, 32)
        f.texFocusMid:SetPoint("TOPLEFT", f.texFocusLeft, "TOPRIGHT", 0, 0)
        f.texFocusMid:SetPoint("TOPRIGHT", f.texFocusRight, "TOPLEFT", 0, 0)
        -- placeholder label
        f.placeholder = f:CreateFontString(nil, "ARTWORK", "GameTooltipText")
        f.placeholder:SetPoint("LEFT", f.texLeft, "LEFT", 16, 0)
        f.placeholder:SetTextColor(0.5, 0.5, 0.5)
        -- make placeholder invisible once field is populated (and highlight the label when in focus for clarity)
        local function updateAlpha(self) self.placeholder:SetAlpha(self:GetText():len() > 0 and 0 or 1) end
        f:HookScript("OnTextChanged", updateAlpha)
        f:HookScript("OnEditFocusLost", function(self) self.placeholder:SetTextColor(0.5, 0.5, 0.5) updateAlpha(self) end)
        f:HookScript("OnEditFocusGained", function(self) self.placeholder:SetTextColor(0.8, 0.8, 0.8) updateAlpha(self) end)
        return f
    end

    local function CreateTooltip()
        return CreateFrame("GameTooltip", addonName .. "_SearchTooltip", UIParent, "GameTooltipTemplate")
    end

    local function CreateSearchFrame()
        GetCachedRegions() -- cache the regions from the loaded providers

        local regionBox = CreateEditBox()
        local realmBox = CreateEditBox()
        local nameBox = CreateEditBox()
        local t = CreateTooltip()

        regionBox.placeholder:SetText(L.SEARCH_REGION_LABEL)
        realmBox.placeholder:SetText(L.SEARCH_REALM_LABEL)
        nameBox.placeholder:SetText(L.SEARCH_NAME_LABEL)

        regionBox.autoCompleteFunction = GetRegions
        regionBox:SetText(ns.PLAYER_REGION)
        realmBox.autoCompleteFunction = GetRealms
        nameBox.autoCompleteFunction = GetNames

        local Frame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
        do
            Frame:Hide()
            Frame:EnableMouse(true)
            Frame:SetFrameStrata("DIALOG")
            Frame:SetToplevel(true)
            Frame:SetSize(310, config:Get("debugMode") and 115 or 100)
            Frame:SetPoint("CENTER")
            if Frame.SetBackdrop then
                Frame:SetBackdrop(BACKDROP_TUTORIAL_16_16) ---@diagnostic disable-line: param-type-mismatch
                Frame:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR:GetRGB()) ---@diagnostic disable-line: param-type-mismatch
                Frame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR:GetRGB()) ---@diagnostic disable-line: param-type-mismatch
                Frame:SetBackdropColor(0, 0, 0, 1) ---@diagnostic disable-line: param-type-mismatch
            end
            Frame.header = Frame:CreateFontString(nil, nil, "ChatFontNormal")
            Frame.header:SetPoint("TOPLEFT", 16, -12)
            Frame.header:SetText("Enter realm and character name:")
            Frame:SetMovable(true)
            Frame:RegisterForDrag("LeftButton")
            Frame:SetClampedToScreen(true)
            Frame:SetScript("OnDragStart", function() Frame:StartMoving() end)
            Frame:SetScript("OnDragStop", function() Frame:StopMovingOrSizing() end)
            Frame:SetScript("OnShow", function() search:ShowProfile(regionBox:GetText(), realmBox:GetText(), nameBox:GetText()) end)
            Frame:SetScript("OnHide", function() search:ShowProfile() end)
            Frame.close = CreateFrame("Button", nil, Frame, "UIPanelCloseButtonNoScripts") ---@diagnostic disable-line: param-type-mismatch
            Frame.close:SetPoint("TOPRIGHT", -5, -3)
            Frame.close:SetScript("OnClick", function() search:Hide() end)
            Frame.copyUrl = CreateFrame("Button", nil, Frame, "UIPanelCloseButtonNoScripts") ---@diagnostic disable-line: param-type-mismatch
            Frame.copyUrl:SetScale(0.67)
            util:SetButtonTextureFromIcon(Frame.copyUrl, ns.CUSTOM_ICONS.icons.RAIDERIO_COLOR_CIRCLE) ---@diagnostic disable-line: param-type-mismatch
            Frame.copyUrl:SetPoint("RIGHT", Frame.close, "LEFT", -5, 0) ---@diagnostic disable-line: param-type-mismatch
            Frame.copyUrl:SetScript("OnClick", function() util:ShowCopyRaiderIOProfilePopup(nameBox:GetText(), realmBox:GetText(), regionBox:GetText()) end)
            Frame.copyUrl:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT") GameTooltip:AddLine(L.COPY_RAIDERIO_PROFILE_URL) GameTooltip:Show() end)
            Frame.copyUrl:SetScript("OnLeave", GameTooltip_Hide)
            Frame.copyUrl:HookScript("OnEnable", function(self) self:GetDisabledTexture():SetDesaturated(false) end)
            Frame.copyUrl:HookScript("OnDisable", function(self) self:GetDisabledTexture():SetDesaturated(true) end)
        end

        local activeBoxes = {}
        if config:Get("debugMode") then
            regionBox:SetParent(Frame) ---@diagnostic disable-line: param-type-mismatch
            table.insert(activeBoxes, regionBox)
        end
        realmBox:SetParent(Frame) ---@diagnostic disable-line: param-type-mismatch
        nameBox:SetParent(Frame) ---@diagnostic disable-line: param-type-mismatch
        table.insert(activeBoxes, realmBox)
        table.insert(activeBoxes, nameBox)

        for i = 1, #activeBoxes do
            local box = activeBoxes[i]
            local prevBox = activeBoxes[i - 1]
            if prevBox then
                box:SetPoint("TOPLEFT", prevBox, "BOTTOMLEFT", 0, 11)
            else
                box:SetPoint("TOPLEFT", Frame.header, "BOTTOMLEFT", 10, -5)
            end
        end

        local function OnTabPressed(self)
            if self.autoComplete:IsShown() then
                return
            end
            self:ClearFocus()
            local backwards = IsShiftKeyDown()
            for i = 1, #activeBoxes do
                local box = activeBoxes[i]
                if box == self then
                    local nextBox = activeBoxes[i + (backwards and -1 or 1)]
                    if not nextBox then
                        nextBox = activeBoxes[backwards and #activeBoxes or 1]
                    end
                    nextBox:SetFocus()
                    nextBox:HighlightText()
                    break
                end
            end
        end

        local function OnEditFocusLost(self)
            self:HighlightText(0, 0)
        end

        local function OnEnterPressed(self)
            for i = 1, #activeBoxes do
                local box = activeBoxes[i]
                if box == self then
                    local nextBox = activeBoxes[i + 1]
                    if nextBox then
                        self:ClearFocus()
                        nextBox:SetFocus()
                        nextBox:HighlightText()
                    else
                        self:ClearFocus()
                        self:HighlightText(0, 0)
                    end
                    break
                end
            end
            search:ShowProfile(regionBox:GetText(), realmBox:GetText(), nameBox:GetText())
        end

        local function OnEscapePressed(self)
            self:ClearFocus()
        end

        local function AreActiveBoxesPopulated()
            for i = 1, #activeBoxes do
                local box = activeBoxes[i]
                if box:GetText():len() < 1 then
                    return false
                end
            end
            return true
        end

        local function OnTextChanged(self, userInput)
            Frame.copyUrl:SetEnabled(AreActiveBoxesPopulated())
            if not userInput then return end
            local text = self:GetText()
            if text:len() > 0 then
                AutoCompleteEditBox_SetAutoCompleteSource(self, self.autoCompleteFunction)
                AutoComplete_Update(self, text, #text)
            end
        end

        for i = 1, #activeBoxes do
            local box = activeBoxes[i]
            box:HookScript("OnTabPressed", OnTabPressed)
            box:HookScript("OnEditFocusLost", OnEditFocusLost)
            box:HookScript("OnEnterPressed", OnEnterPressed)
            box:HookScript("OnEscapePressed", OnEscapePressed)
            box:HookScript("OnTextChanged", OnTextChanged)
        end

        return Frame, regionBox, realmBox, nameBox, t
    end

    function search:CanLoad()
        return not searchFrame and profile:IsLoaded()
    end

    function search:OnLoad()
        self:Enable()
        searchFrame, searchRegionBox, searchRealmBox, searchNameBox, searchTooltip = CreateSearchFrame()
    end

    function search:ShowProfile(region, realm, name)
        if not self:IsEnabled() then
            return
        end
        if not region or not realm or not name or strlenutf8(realm) < 1 or strlenutf8(name) < 1 then
            searchTooltip:Hide()
            profile:HideProfile()
            return
        end
        searchTooltip:SetParent(searchFrame)
        searchTooltip:SetOwner(searchFrame, "ANCHOR_BOTTOM", 0, -8)
        local playerProfile = provider:GetProfile(name, realm, region)
        local shown
        if playerProfile then
            shown = render:ShowProfile(searchTooltip, name, realm, bor(render.Preset.UnitNoPadding(), render.Flags.MOD_STICKY), region)
        end
        if not shown then
            render:ShowProfile(searchTooltip)
            searchTooltip:SetParent(searchFrame)
            searchTooltip:SetOwner(searchFrame, "ANCHOR_BOTTOM", 0, -8)
            searchTooltip:AddLine(ERR_FRIEND_NOT_FOUND, 1, 1, 1)
            searchTooltip:Show()
        end
        if shown then
            profile:ShowProfile(searchFrame, name, realm, render.Preset.Profile(render.Flags.IGNORE_MOD), region)
        else
            profile:HideProfile()
        end
        return shown
    end

    function search:Search(query)
        if not self:IsEnabled() then
            return
        end
        local pattern = config:Get("debugMode") and "^(%S+)%s*(%S*)%s*(%S*)$" or "^(%S+)%s*(%S*)$"
        local arg1, arg2, arg3 = query:match(pattern)
        arg1, arg2, arg3 = (arg1 or ""):trim(), (arg2 or ""):trim(), (arg3 or ""):trim()
        arg2 = arg2 ~= "" and arg2 or GetNormalizedRealmName()
        arg3 = arg3 ~= "" and arg3 or ns.PLAYER_REGION
        local arg3q = GetRegions(arg3, 1)
        if arg3q and arg3q[1] and arg3q[1].name then
            arg3 = arg3q[1].name
        end
        searchRegionBox:SetText(arg3)
        local arg2q = GetRealms(arg2, 1)
        if arg2q and arg2q[1] and arg2q[1].name then
            arg2 = arg2q[1].name
        end
        searchRealmBox:SetText(arg2)
        local arg1q = GetNames(arg1, 1)
        if arg1q and arg1q[1] and arg1q[1].name then
            arg1 = arg1q[1].name
        end
        searchNameBox:SetText(arg1)
        return search:ShowProfile(arg3, arg2, arg1)
    end

    function search:SearchAndShowProfile(region, realm, name)
        searchRegionBox:SetText(region)
        searchRealmBox:SetText(realm)
        searchNameBox:SetText(name)
        return search:ShowProfile(region, realm, name)
    end

    function search:Toggle()
        if not self:IsEnabled() then
            return
        end
        if searchFrame:IsShown() then
            search:Hide()
        else
            search:Show()
        end
    end

    function search:Show()
        if not self:IsEnabled() then
            return
        end
        searchFrame:Show()
    end

    function search:Hide()
        if not self:IsEnabled() then
            return
        end
        searchFrame:Hide()
    end

    function search:IsShown()
        return searchFrame:IsShown()
    end

end

-- dropdown.lua
-- dependencies: module, config, util + LibDropDownExtension, provider, search
do

    ---@class DropDownModule : Module
    local dropdown = ns:NewModule("DropDown") ---@type DropDownModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule
    local provider = ns:GetModule("Provider") ---@type ProviderModule
    local search = ns:GetModule("Search") ---@type SearchModule

    local validTypes = {
        ARENAENEMY = true,
        BN_FRIEND = true,
        CHAT_ROSTER = true,
        COMMUNITIES_GUILD_MEMBER = true,
        COMMUNITIES_WOW_MEMBER = true,
        FOCUS = true,
        FRIEND = true,
        GUILD = true,
        GUILD_OFFLINE = true,
        PARTY = true,
        PLAYER = true,
        RAID = true,
        RAID_PLAYER = true,
        SELF = true,
        TARGET = true,
        WORLD_STATE_SCORE = true
    }

    -- if the dropdown is a valid type of dropdown then we mark it as acceptable to check for a unit on it
    local function IsValidDropDown(bdropdown)
        return (bdropdown == LFGListFrameDropDown and config:Get("enableLFGDropdown")) or (type(bdropdown.which) == "string" and validTypes[bdropdown.which])
    end

    -- get name and realm from dropdown or nil if it's not applicable
    local function GetNameRealmForDropDown(bdropdown)
        local unit = bdropdown.unit
        local bnetIDAccount = bdropdown.bnetIDAccount
        local menuList = bdropdown.menuList
        local quickJoinMember = bdropdown.quickJoinMember
        local quickJoinButton = bdropdown.quickJoinButton
        local clubMemberInfo = bdropdown.clubMemberInfo
        local tempName, tempRealm = bdropdown.name, bdropdown.server
        local name, realm, level, faction
        -- unit
        if not name and UnitExists(unit) then
            if UnitIsPlayer(unit) then
                name, realm = util:GetNameRealm(unit)
                level = UnitLevel(unit)
                faction = util:GetFaction(unit)
            end
            -- if it's not a player it's pointless to check further
            return name, realm, level, unit, faction
        end
        -- bnet friend
        if not name and bnetIDAccount then
            local fullName, charFaction, charLevel = util:GetNameRealmForBNetFriend(bnetIDAccount)
            if fullName then
                name, realm = util:GetNameRealm(fullName) ---@diagnostic disable-line: param-type-mismatch
                level = charLevel
                faction = charFaction
            end
            -- if it's a bnet friend we assume if eligible the name and realm is set, otherwise we assume it's not eligible for a url
            return name, realm, level, nil, faction
        end
        -- lfd
        if not name and menuList then
            for i = 1, #menuList do
                local whisperButton = menuList[i]
                if whisperButton and (whisperButton.text == _G.WHISPER_LEADER or whisperButton.text == _G.WHISPER) then
                    name, realm = util:GetNameRealm(whisperButton.arg1)
                    faction = ns.PLAYER_FACTION
                    break
                end
            end
        end
        -- quick join
        if not name and (quickJoinMember or quickJoinButton) then
            local memberInfo = quickJoinMember or quickJoinButton.Members[1]
            if memberInfo.playerLink then
                name, realm, level = util:GetNameRealmFromPlayerLink(memberInfo.playerLink)
                faction = ns.PLAYER_FACTION
            end
        end
        -- dropdown by name and realm
        if not name and tempName then
            name, realm = util:GetNameRealm(tempName, tempRealm)
            if clubMemberInfo and clubMemberInfo.level and (clubMemberInfo.clubType == Enum.ClubType.Guild or clubMemberInfo.clubType == Enum.ClubType.Character) then
                level = clubMemberInfo.level
                faction = ns.PLAYER_FACTION
            end
        end
        -- if we don't got both we return nothing
        if not name or not realm then
            return
        end
        -- fallback to our own faction if we're unsure at this point
        if not faction then
            faction = ns.PLAYER_FACTION
        end
        -- return whatever information we have available
        return name, realm, level, nil, faction
    end

    -- tracks the currently active dropdown name and realm for lookup
    local selectedName, selectedRealm, selectedLevel, selectedUnit, selectedFaction

    ---@type CustomDropDownOption[]
    local unitOptions

    ---@param options CustomDropDownOption[]
    local function OnToggle(bdropdown, event, options, level, data)
        if event == "OnShow" then
            if not config:Get("showDropDownCopyURL") then
                return
            end
            if not IsValidDropDown(bdropdown) then
                return
            end
            selectedName, selectedRealm, selectedLevel, selectedUnit, selectedFaction = GetNameRealmForDropDown(bdropdown)
            if not selectedName or not util:IsMaxLevel(selectedLevel, true) then ---@diagnostic disable-line: param-type-mismatch
                return
            end
            if not options[1] then
                local index = 0
                for i = 1, #unitOptions do
                    local option = unitOptions[i]
                    if not option.show or option.show() then
                        index = index + 1
                        options[index] = option
                    end
                end
                return true
            end
        elseif event == "OnHide" then
            if options[1] then
                for i = #options, 1, -1 do
                    options[i] = nil
                end
                return true
            end
        end
    end

    local function DropDownOptionModifiedClickHandler()
        if not IsControlKeyDown() and not IsAltKeyDown() then
            return
        end
        local shown = search:IsShown()
        if not shown then
            search:Show()
        end
        if search:SearchAndShowProfile(ns.PLAYER_REGION, selectedRealm, selectedName) then
            return true -- indicates we are showing the search dialog and we don't want to show the static popup
        elseif not shown then
            search:Hide()
        end
    end

    local function GetRecruitmentProfileForDropDown()
        local profile = provider:GetProfile(selectedName, selectedRealm)
        if not profile or not profile.recruitmentProfile or not profile.recruitmentProfile.hasRenderableData then
            return
        end
        return profile
    end

    ---@type LibDropDownExtension
    local LibDropDownExtension = LibStub and LibStub:GetLibrary("LibDropDownExtension-1.0", true)

    function dropdown:CanLoad()
        return LibDropDownExtension
    end

    function dropdown:OnLoad()
        self:Enable()
        unitOptions = {
            {
                text = L.COPY_RAIDERIO_PROFILE_URL,
                func = function()
                    if DropDownOptionModifiedClickHandler() then
                        return
                    end
                    util:ShowCopyRaiderIOProfilePopup(selectedName, selectedRealm)
                end
            },
            {
                text = L.COPY_RAIDERIO_RECRUITMENT_URL,
                func = function()
                    if DropDownOptionModifiedClickHandler() then
                        return
                    end
                    local profile = GetRecruitmentProfileForDropDown()
                    if profile then
                        util:ShowCopyRaiderIORecruitmentProfilePopup(profile.recruitmentProfile.entityType, selectedName, selectedRealm)
                    end
                end,
                show = function()
                    return GetRecruitmentProfileForDropDown()
                end
            }
        }
        LibDropDownExtension:RegisterEvent("OnShow OnHide", OnToggle, 1, dropdown)
    end

end

-- rwf.lua (requires rwf mode)
-- dependencies: module, callback, config, util
do

    ---@class RaceWorldFirstModule : Module
    local rwf = ns:NewModule("RaceWorldFirst") ---@type RaceWorldFirstModule
    local callback = ns:GetModule("Callback") ---@type CallbackModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule

    local LOCATION = {}
    local LOOT_FRAME

    local TRACKING_EVENTS = {
        -- TODO: disable these loot related events since we currently only support the guild news related loot events
        -- "LOOT_READY",
        -- "LOOT_HISTORY_FULL_UPDATE",
        -- "LOOT_HISTORY_ROLL_COMPLETE",
        -- "CHAT_MSG_LOOT",
        -- "CHAT_MSG_CURRENCY",
    }

    local HEX_COLOR_QUALITY = {
        ["9d9d9d"] = 0,
        ["ffffff"] = 1,
        ["1eff00"] = 2,
        ["0070dd"] = 3,
        ["a335ee"] = 4,
        ["ff8000"] = 5,
        ["e6cc80"] = 6,
        ["00ccff"] = 7,
    }

    local function GetItemFromText(text)
        if not text or type(text) ~= "string" then
            return
        end
        local linkHexColor, linkType, linkArg1, linkArg2N, linkText, trailingText = text:match("|cff(......)|H([^:]-):(%d+)(.-)|h%[(.-)%]|h|r(.*)")
        if not linkHexColor then
            return
        end
        local link = format("|cff%s|H%s:%s%s|h[%s]|h|r", linkHexColor, linkType, linkArg1, linkArg2N, linkText)
        local linkCount
        if trailingText ~= "" then
            local trailingCount, trailingText2 = trailingText:match("%s*[Xx](%d+)(.*)")
            if trailingCount then
                linkCount = tonumber(trailingCount)
            end
        end
        return linkType, linkArg1, link, linkCount, HEX_COLOR_QUALITY[linkHexColor]
    end

    -- Vault of the Incarnates
    local LOG_FILTER = {
        GUILD_NEWS = { "item:.-:1:28:215[89]:", "item:.-:1:28:216[01]:" },
        ITEM_LEVEL = 376,
    }

    local LOG_TYPE = {
        Loot = 1,
        Roll = 2,
        Chat = 3,
        News = 4,
    }

    local LOG_TYPE_LABEL = {
        [1] = "Loot",
        [2] = "Roll",
        [3] = "Chat",
        [4] = "News",
    }

    local function GetNestedTable(db, ...)
        local args = {...}
        if args[1] == nil then
            return
        end
        local path = {}
        local i = 0
        local temp = db
        for _, k in ipairs(args) do
            if k == nil then
                return nil, path, temp
            end
            local o = temp[k]
            if not o then
                o = {}
                temp[k] = o
            end
            temp = o
            i = i + 1
            path[i] = temp
        end
        if i ~= #args then
            return false, path, temp
        end
        return true, path, temp
    end

    local function CountItems(t)
        local count = 0
        for _, _ in pairs(t) do
            count = count + 1
        end
        return count
    end

    ---@class RWFLootEntry
    ---@field public guildName string
    ---@field public guildRealm string
    ---@field public guildRegion string
    ---@field public type number
    ---@field public isNew boolean
    ---@field public timestamp number
    ---@field public isUpdated boolean
    ---@field public itemLevel number
    ---@field public id number
    ---@field public itemType string
    ---@field public itemSubType string
    ---@field public itemEquipLoc string
    ---@field public itemIcon number
    ---@field public itemClassID number
    ---@field public itemSubClassID number
    ---@field public link string
    ---@field public index number
    ---@field public guid string
    ---@field public count number
    ---@field public who string
    ---@field public sources table<number, number>
    ---@field public hasNewSources boolean
    ---@field public addLoot boolean

    ---@return RWFLootEntry|boolean|nil
    local function LogItemLink(logType, linkType, id, link, count, sources, useTimestamp, additionalInfo)
        local isLogging, instanceName, instanceDifficulty, instanceID = rwf:GetLocation()
        if logType == LOG_TYPE.News then
            instanceName = _G.GUILD_NEWS or _G.GUILD_NEWS_TITLE
            instanceID, instanceDifficulty = 0, 0
        end
        if not instanceID or not instanceDifficulty then
            return
        end
        local linkAsKey = link:gsub("%[[^%]]*%]", "")
        local success, tables = GetNestedTable(_G.RaiderIO_RWF, instanceID, instanceDifficulty, logType, linkAsKey)
        if not success or not tables then
            return false
        end
        local guildName, _, _, guildRealmName = GetGuildInfo("player")
        tables[1].name = instanceName
        local lootEntry = tables[4] ---@type RWFLootEntry
        local timestamp = useTimestamp or GetServerTime()
        lootEntry.guildName = guildName
        lootEntry.guildRealm = guildRealmName or ns.PLAYER_REALM
        lootEntry.guildRegion = ns.PLAYER_REGION
        lootEntry.type = logType
        lootEntry.isNew = not lootEntry.timestamp
        lootEntry.timestamp = lootEntry.timestamp or timestamp
        lootEntry.isUpdated = timestamp - lootEntry.timestamp > 60
        lootEntry.itemLevel = GetDetailedItemLevelInfo(link) ---@diagnostic disable-line: assign-type-mismatch
        lootEntry.id, lootEntry.itemType, lootEntry.itemSubType, lootEntry.itemEquipLoc, lootEntry.itemIcon, lootEntry.itemClassID, lootEntry.itemSubClassID = GetItemInfoInstant(link)
        lootEntry.link = link
        lootEntry.index = lootEntry.index or CountItems(tables[3]) -- keep same index or count (our item is already included in the count)
        lootEntry.guid = lootEntry.guid or format("%05d %010d %s", lootEntry.index, lootEntry.timestamp, linkAsKey) -- attempt to create unique loot guid when the item is inserted into the SV
        if logType == LOG_TYPE.Chat then
            lootEntry.count = (lootEntry.count or 0) + (count or 0)
        elseif logType == LOG_TYPE.News then
            lootEntry.count = count or 0
        else
            lootEntry.count = 1
        end
        lootEntry.sources = lootEntry.sources or {}
        lootEntry.hasNewSources = false
        if logType == LOG_TYPE.Loot then
            for k, v in pairs(sources) do
                if not lootEntry.sources[k] then
                    lootEntry.hasNewSources = true
                end
                lootEntry.sources[k] = (lootEntry.sources[k] or 0) + v
            end
        end
        lootEntry.addLoot = lootEntry.isNew or lootEntry.hasNewSources -- lootEntry.isUpdated
        -- Additional info for dedup in backend
        if additionalInfo then
            for key, value in pairs(additionalInfo) do
                lootEntry[key] = value
            end
        end
        return lootEntry
    end

    local LOG_ITEM_TRIM_IF_OLDER = 259200 -- 3 days
    local LOG_ITEM_LOG_IF_NEWER = 172800 -- 2 days

    local function TrimHistoryFromSV()
        local now = time()
        local remove
        for instanceID, instanceData in pairs(_G.RaiderIO_RWF) do
            for instanceDifficulty, instanceDifficultyData in pairs(instanceData) do
                if type(instanceDifficultyData) == "table" then
                    for logType, logTypeData in pairs(instanceDifficultyData) do
                        ---@type RWFLootEntry
                        for key, lootEntry in pairs(logTypeData) do
                            if now - lootEntry.timestamp >= LOG_ITEM_TRIM_IF_OLDER then
                                if not remove then
                                    remove = {}
                                end
                                remove[key] = true
                            end
                        end
                        if remove then
                            for key, _ in pairs(remove) do
                                logTypeData[key] = nil
                            end
                            remove = nil
                        end
                    end
                end
            end
        end
    end

    local LOG_GUILD_NEWS_TYPES = {
        [NEWS_ITEM_LOOTED] = 1,
        [NEWS_LEGENDARY_LOOTED] = 1,
    }

    local function CanLogItem(itemLink, itemType, itemQuality, itemLinkFilter)
        if itemType == "currency" then
            return false
        end
        if itemQuality and itemQuality == Enum.ItemQuality.Poor then
            return false
        end
        if itemLinkFilter then
            if type(itemLinkFilter) == "table" then
                for _, filter in pairs(itemLinkFilter) do
                    if itemLink:find(filter) then
                        return true
                    end
                end
            elseif itemLink:find(itemLinkFilter) then
                return true
            end
        end
        -- local _, _, _, itemEquipLoc = GetItemInfoInstant(itemLink)
        -- if itemEquipLoc and itemEquipLoc == "" then
        --     return true
        -- end
        -- local effectiveILvl = GetDetailedItemLevelInfo(itemLink)
        -- if effectiveILvl and effectiveILvl >= LOG_FILTER.ITEM_LEVEL then
        --     return true
        -- end
    end

    ---@param lootEntry RWFLootEntry
    local function PrepareLootEntryForSV(lootEntry)
        -- lootEntry.isNew, lootEntry.isUpdated, lootEntry.hasNewSources, lootEntry.addLoot = nil -- TODO: if we uncomment we'll keep adding old processed loot to the frame and we don't want that so let this be in the SV file we can afford that
    end

    ---@param lootEntry RWFLootEntry|false|nil
    local function HandleLootEntry(lootEntry)
        if not lootEntry then
            return
        end
        if lootEntry.addLoot then
            LOOT_FRAME:AddLoot(lootEntry)
        else
            PrepareLootEntryForSV(lootEntry)
        end
    end

    local function GetGuildNewsItems()
        local t = {} ---@type GuildNewsInfo[]
        local i = 0
        local n = 0
        local newsInfo ---@type GuildNewsInfo
        repeat
            i = i + 1
            newsInfo = C_GuildInfo.GetGuildNewsInfo(i)
            if not newsInfo then
                break
            elseif LOG_GUILD_NEWS_TYPES[newsInfo.newsType] then
                n = n + 1
                t[n] = newsInfo
            end
        until false
        return t, n
    end

    ---@class Ticker
    ---@field public CalledDuringScan boolean @Private. Set if the guild news gets scanned while we have an active ticker.
    ---@field public Cancel fun(self: Ticker)
    ---@field public IsCancelled fun(self: Ticker)

    local guildNewsTicker ---@type Ticker?
    local guildNewsCount ---@type number

    local function GetGuildNews()
        local items, count = GetGuildNewsItems()
        local diff = guildNewsCount and abs(count - guildNewsCount) or 0
        return items, count, diff
    end

    ---@param newsInfo GuildNewsInfo
    local function HandleGuildNewsInfo(newsInfo, now)
        local itemType, itemID, itemLink, itemCount, itemQuality = GetItemFromText(newsInfo.whatText)
        if itemType and CanLogItem(itemLink, itemType, itemQuality, LOG_FILTER.GUILD_NEWS) then
            newsInfo.year = newsInfo.year + 2000
            newsInfo.month = newsInfo.month + 1
            newsInfo.day = newsInfo.day + 1
            local timestamp = time(newsInfo) ---@diagnostic disable-line: param-type-mismatch
            if now - timestamp <= LOG_ITEM_LOG_IF_NEWER then
                HandleLootEntry(LogItemLink(LOG_TYPE.News, itemType, itemID, itemLink, itemCount or 1, nil, timestamp, { who = newsInfo.whoText }))
                return true
            end
            return false
        end
    end

    local SCAN_NUM_ITEMS_PER_FRAME = 100
    local SCAN_INTERVAL_BETWEEN_CYCLES = 0.05

    local function ScanGuildNews()
        if guildNewsTicker then
            guildNewsTicker.CalledDuringScan = true
            return
        end
        local co = coroutine.create(function()
            local items, count, diff = GetGuildNews()
            if guildNewsCount == count then
                return
            end
            guildNewsCount = count
            local now = time()
            for i, newsInfo in ipairs(items) do
                if HandleGuildNewsInfo(newsInfo, now) and i % SCAN_NUM_ITEMS_PER_FRAME == 0 then
                    coroutine.yield()
                end
            end
            if not guildNewsTicker or not guildNewsTicker.CalledDuringScan then
                return
            end
            items, count, diff = GetGuildNews()
            if guildNewsCount == count then
                return
            end
            guildNewsCount = count
            for i, newsInfo in ipairs(items) do
                if i > diff then
                    break
                end
                HandleGuildNewsInfo(newsInfo, now)
            end
        end)
        LOOT_FRAME.MiniFrame:StartScanning()
        ---@type Ticker
        guildNewsTicker = C_Timer.NewTicker(SCAN_INTERVAL_BETWEEN_CYCLES, function()
            if not coroutine.resume(co) then
                if guildNewsTicker then
                    guildNewsTicker:Cancel()
                end
                guildNewsTicker = nil
                LOOT_FRAME.MiniFrame:StopScanning()
                return
            end
        end)
    end

    local LOOT_SLOT_ITEM = LOOT_SLOT_ITEM or Enum.LootSlotType.Item ---@diagnostic disable-line: undefined-global
    local LOOT_SLOT_CURRENCY = LOOT_SLOT_CURRENCY or Enum.LootSlotType.Currency ---@diagnostic disable-line: undefined-global

    local function OnEvent(event, ...)
        if event == "LOOT_READY" then
            for i = 1, GetNumLootItems() do
                local slotType = GetLootSlotType(i)
                if slotType == LOOT_SLOT_ITEM or slotType == LOOT_SLOT_CURRENCY then
                    local lootLink = GetLootSlotLink(i)
                    local itemType, itemID, itemLink, itemCount, itemQuality = GetItemFromText(lootLink)
                    if itemType and CanLogItem(itemLink, itemType, itemQuality) then
                        local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(i)
                        local lootSources = {GetLootSourceInfo(i)}
                        local itemSources = {}
                        for j = 1, #lootSources, 2 do
                            local guid, quantity = lootSources[j], lootSources[j + 1]
                            itemSources[guid] = quantity
                        end
                        HandleLootEntry(LogItemLink(LOG_TYPE.Loot, itemType, itemID, lootLink, lootQuantity or itemCount or 1, itemSources))
                    end
                end
            end
        elseif event == "LOOT_HISTORY_FULL_UPDATE" or event == "LOOT_HISTORY_ROLL_COMPLETE" then
            for i = 1, C_LootHistory.GetNumItems() do
                local rollID, rollLink, numPlayers, isDone, winnerIdx, isMasterLoot, isCurrency = C_LootHistory.GetItem(i)
                local itemType, itemID, itemLink, itemCount, itemQuality = GetItemFromText(rollLink)
                if itemType and CanLogItem(itemLink, itemType, itemQuality) then
                    HandleLootEntry(LogItemLink(LOG_TYPE.Roll, itemType, itemID, rollLink, itemCount or 1))
                end
            end
        elseif event == "CHAT_MSG_LOOT" or event == "CHAT_MSG_CURRENCY" then
            local text = ...
            local itemType, itemID, itemLink, itemCount, itemQuality = GetItemFromText(text)
            if itemType and CanLogItem(itemLink, itemType, itemQuality) then
                HandleLootEntry(LogItemLink(LOG_TYPE.Chat, itemType, itemID, itemLink, itemCount or 1))
            end
        elseif event == "GUILD_NEWS_UPDATE" then
            ScanGuildNews()
        end
        if LOOT_FRAME:IsShown() then
            LOOT_FRAME:OnShow()
        end
    end

    local function OnZoneEvent()
        rwf:CheckLocation()
    end

    local function CreateLootFrame()

        local function CreateCounter(initialCount)
            local count = initialCount or 0
            return function()
                count = count + 1
                return count
            end
        end

        local frame = CreateFrame("Frame", addonName .. "_RWFFrame", UIParent, "ButtonFrameTemplate")
        frame:SetSize(400, 250)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("HIGH")
        ButtonFrameTemplate_HidePortrait(frame)
        frame:SetMovable(true)
        frame:SetResizable(true)
        frame:EnableMouse(true)
        frame:SetClampedToScreen(true)
        frame.showingArguments = true
        frame.showingTimestamp = true
        frame.loadTime = GetTime()
        frame.idCounter = CreateCounter()
        frame.logDataProvider = CreateDataProvider()
        frame.frameCounter = 0

        -- TODO: DF
        if frame.TitleText then
            frame.TitleText:SetText(L.RWF_TITLE)
        else
            frame:SetTitle(L.RWF_TITLE)
        end

        frame.TitleBar = CreateFrame("Frame", nil, frame, "PanelDragBarTemplate") ---@diagnostic disable-line: param-type-mismatch
        frame.TitleBar:OnLoad()
        frame.TitleBar:SetHeight(24)
        frame.TitleBar:SetPoint("TOPLEFT", 0, 0)
        frame.TitleBar:SetPoint("TOPRIGHT", 0, 0)
        frame.TitleBar:Init(frame)

        frame.Log = CreateFrame("Frame", nil, frame) ---@diagnostic disable-line: param-type-mismatch
        frame.Log:SetPoint("TOPLEFT", frame.TitleBar, "BOTTOMLEFT", 8, -32 + 24) ---@diagnostic disable-line: param-type-mismatch
        frame.Log:SetPoint("BOTTOMRIGHT", -9, 28)

        frame.Log.Bar = CreateFrame("Frame", nil, frame.Log)
        frame.Log.Bar:SetHeight(24)
        frame.Log.Bar:SetPoint("TOPLEFT", 0, 0)
        frame.Log.Bar:SetPoint("TOPRIGHT", 0, 0)

        frame.Log.Events = CreateFrame("Frame", nil, frame.Log)
        frame.Log.Events:SetPoint("TOPLEFT", frame.Log.Bar, "BOTTOMLEFT", 0, -2)
        frame.Log.Events:SetPoint("BOTTOMRIGHT", 0, 0)

        frame.Log.Events.ScrollBox = CreateFrame("Frame", nil, frame.Log.Events, "WowScrollBoxList")
        frame.Log.Events.ScrollBox:OnLoad()
        frame.Log.Events.ScrollBox:SetPoint("TOPLEFT", 0, -8) -- 0, 0
        frame.Log.Events.ScrollBox:SetPoint("BOTTOMRIGHT", -25, 0)
        frame.Log.Events.ScrollBox.bgTexture = frame.Log.Events.ScrollBox:CreateTexture(nil, "BACKGROUND")
        frame.Log.Events.ScrollBox.bgTexture:SetColorTexture(0.03, 0.03, 0.03)

        frame.Log.Events.ScrollBar = CreateFrame("EventFrame", nil, frame.Log.Events, "WowTrimScrollBar")
        frame.Log.Events.ScrollBar:OnLoad()
        frame.Log.Events.ScrollBar:SetPoint("TOPLEFT", frame.Log.Events.ScrollBox, "TOPRIGHT", 0, 3) -- 0, -3
        frame.Log.Events.ScrollBar:SetPoint("BOTTOMLEFT", frame.Log.Events.ScrollBox, "BOTTOMRIGHT", 0, 0)

        frame.SubTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.SubTitle:SetWordWrap(false)
        frame.SubTitle:SetJustifyH("CENTER")
        frame.SubTitle:SetJustifyV("MIDDLE")
        frame.SubTitle:SetPoint("TOPLEFT", frame.TitleBar, "BOTTOMLEFT", 0, 0) ---@diagnostic disable-line: param-type-mismatch
        frame.SubTitle:SetPoint("BOTTOMRIGHT", frame.Log.Events, "TOPRIGHT", 0, 0)

        frame.EnableModule = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate") ---@diagnostic disable-line: param-type-mismatch
        frame.EnableModule:SetSize(80, 22)
        frame.EnableModule:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 3) ---@diagnostic disable-line: param-type-mismatch
        frame.EnableModule:SetScript("OnClick", function() config:Set("rwfMode", true) ReloadUI() end)
        frame.EnableModule:SetText(L.ENABLE_RWF_MODE_BUTTON)
        frame.EnableModule.tooltip = L.ENABLE_RWF_MODE_BUTTON_TOOLTIP
        frame.EnableModule.GetAppropriateTooltip = UIButtonMixin.GetAppropriateTooltip
        frame.EnableModule:SetScript("OnEnter", UIButtonMixin.OnEnter)
        frame.EnableModule:SetScript("OnLeave", UIButtonMixin.OnLeave)

        frame.DisableModule = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate") ---@diagnostic disable-line: param-type-mismatch
        frame.DisableModule:SetSize(80, 22)
        frame.DisableModule:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 3) ---@diagnostic disable-line: param-type-mismatch
        frame.DisableModule:SetScript("OnClick", function() config:Set("rwfMode", false) _G.RaiderIO_RWF = {} ReloadUI() end)
        frame.DisableModule:SetText(L.DISABLE_RWF_MODE_BUTTON)
        frame.DisableModule.tooltip = L.DISABLE_RWF_MODE_BUTTON_TOOLTIP
        frame.DisableModule.GetAppropriateTooltip = UIButtonMixin.GetAppropriateTooltip
        frame.DisableModule:SetScript("OnEnter", UIButtonMixin.OnEnter)
        frame.DisableModule:SetScript("OnLeave", UIButtonMixin.OnLeave)

        frame.ReloadUI = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate") ---@diagnostic disable-line: param-type-mismatch
        frame.ReloadUI:SetSize(80, 22)
        frame.ReloadUI:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 5, 3) ---@diagnostic disable-line: param-type-mismatch
        frame.ReloadUI:SetScript("OnClick", ReloadUI)
        frame.ReloadUI:SetText(L.RELOAD_RWF_MODE_BUTTON)
        frame.ReloadUI.tooltip = L.RELOAD_RWF_MODE_BUTTON_TOOLTIP
        frame.ReloadUI.GetAppropriateTooltip = UIButtonMixin.GetAppropriateTooltip
        frame.ReloadUI:SetScript("OnEnter", UIButtonMixin.OnEnter)
        frame.ReloadUI:SetScript("OnLeave", UIButtonMixin.OnLeave)

        frame.WipeLog = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate") ---@diagnostic disable-line: param-type-mismatch
        frame.WipeLog:SetSize(80, 22)
        frame.WipeLog:SetPoint("RIGHT", frame.DisableModule, "LEFT", 2, 0) ---@diagnostic disable-line: param-type-mismatch
        frame.WipeLog:SetScript("OnClick", function() _G.RaiderIO_RWF = {} ReloadUI() end)
        frame.WipeLog:SetText(L.WIPE_RWF_MODE_BUTTON)
        frame.WipeLog.tooltip = L.WIPE_RWF_MODE_BUTTON_TOOLTIP
        frame.WipeLog.GetAppropriateTooltip = UIButtonMixin.GetAppropriateTooltip
        frame.WipeLog:SetScript("OnEnter", UIButtonMixin.OnEnter)
        frame.WipeLog:SetScript("OnLeave", UIButtonMixin.OnLeave)

        frame.MiniFrame = CreateFrame("Button", addonName .. "_RWFMiniFrame", UIParent, "UIPanelButtonTemplate")
        frame.MiniFrame:SetFrameLevel(100)
        frame.MiniFrame:SetClampedToScreen(true)
        frame.MiniFrame:SetSize(32, 32)
        frame.MiniFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        local miniPoint = config:Get("rwfMiniPoint") ---@type ConfigProfilePoint
        frame.MiniFrame:SetPoint(miniPoint.point or "CENTER", miniPoint.point and _G.UIParent or frame, miniPoint.point or "CENTER", miniPoint.point and miniPoint.x or -10, miniPoint.point and miniPoint.y or 0) ---@diagnostic disable-line: param-type-mismatch
        frame.MiniFrame:EnableMouse(true)
        frame.MiniFrame:SetMovable(true)
        frame.MiniFrame:RegisterForDrag("LeftButton")
        frame.MiniFrame:SetScript("OnDragStart", frame.MiniFrame.StartMoving)
        frame.MiniFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            local point, _, _, x, y = self:GetPoint() -- TODO: improve this to store a corner so that when the tip is resized the corner is the anchor point and not the center as that makes it very wobbly and unpleasant to look at
            local miniPoint = config:Get("rwfMiniPoint") ---@type ConfigProfilePoint
            config:Set("rwfMiniPoint", miniPoint)
            miniPoint.point, miniPoint.x, miniPoint.y = point, x, y
            if self.arrow1 then
                self:UpdateArrow()
            end
        end)
        frame.MiniFrame.Text:SetPoint("TOP", frame.MiniFrame, "BOTTOM", 0, -5)
        frame.MiniFrame:SetDisabledFontObject(_G.GameFontHighlightHuge)
        frame.MiniFrame:SetHighlightFontObject(_G.GameFontHighlightHuge)
        frame.MiniFrame:SetNormalFontObject(_G.GameFontHighlightHuge)
        frame.MiniFrame.tooltip = L.RWF_MINIBUTTON_TOOLTIP
        frame.MiniFrame.GetAppropriateTooltip = UIButtonMixin.GetAppropriateTooltip
        frame.MiniFrame:SetScript("OnEnter", UIButtonMixin.OnEnter)
        frame.MiniFrame:SetScript("OnLeave", UIButtonMixin.OnLeave)
        frame.MiniFrame:SetMotionScriptsWhileDisabled(true)
        frame.MiniFrame.Left:Hide()
        frame.MiniFrame.Right:Hide()
        frame.MiniFrame.Middle:Hide()
        util:SetButtonTextureFromIcon(frame.MiniFrame, ns.CUSTOM_ICONS.icons.RAIDERIO_COLOR_CIRCLE) ---@diagnostic disable-line: param-type-mismatch
        frame.MiniFrame:Hide()

        frame.MiniFrame.Spinner = CreateFrame("Button", nil, frame.MiniFrame) ---@diagnostic disable-line: param-type-mismatch
        frame.MiniFrame.Spinner:SetAllPoints()
        util:SetButtonTextureFromIcon(frame.MiniFrame.Spinner, ns.CUSTOM_ICONS.icons.RAIDERIO_COLOR_CIRCLE)
        frame.MiniFrame.Spinner:Hide()
        frame.MiniFrame.Spinner.Anim = frame.MiniFrame.Spinner:CreateAnimationGroup()
        frame.MiniFrame.Spinner.Anim.Rotation = frame.MiniFrame.Spinner.Anim:CreateAnimation("Rotation")
        frame.MiniFrame.Spinner.Anim.Rotation:SetDuration(1)
        frame.MiniFrame.Spinner.Anim.Rotation:SetOrder(1)
        frame.MiniFrame.Spinner.Anim.Rotation:SetOrigin("CENTER", 0, 0)
        frame.MiniFrame.Spinner.Anim.Rotation:SetRadians(math.pi * 2)
        frame.MiniFrame.Spinner.Anim:SetScript("OnFinished", frame.MiniFrame.Spinner.Anim.Play)
        frame.MiniFrame.Spinner:SetScript("OnShow", function(self) self.Anim:Play() end)
        frame.MiniFrame.Spinner:SetScript("OnHide", function(self) self.Anim:Stop() end)

        frame.MiniFrame:HookScript("OnShow", function(self)
            self:UpdateState()
        end)

        frame.MiniFrame:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                local numItems = frame:GetNumLootItems(LOG_TYPE.News)
                if numItems > 0 then
                    if not InCombatLockdown() then
                        ReloadUI()
                    end
                else
                    -- frame:Show()
                end
            else
                frame:Show()
            end
        end)

        if config:Get("rwfBackgroundMode") then
            frame.MiniFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
            frame.MiniFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
            frame.MiniFrame:SetScript("OnEvent", function(self, event)
                self:UpdateState((event == "PLAYER_REGEN_DISABLED" and true) or (event == "PLAYER_REGEN_ENABLED" and false))
            end)
        end

        local ARROW_CONFIG = {
            LEFT = {
                atlas = "NPE_ArrowLeft",
                atlasGlow = "NPE_ArrowLeftGlow",
                pointDir = "RIGHT",
                pointX = 23,
                pointY = 0,
                transX = -50,
                transY = 0,
                size = 64,
                offsetX = 64,
                offsetY = 0,
            },
            RIGHT = {
                atlas = "NPE_ArrowRight",
                atlasGlow = "NPE_ArrowRightGlow",
                pointDir = "LEFT",
                pointX = -23,
                pointY = 0,
                transX = 50,
                transY = 0,
                size = 64,
                offsetX = -64,
                offsetY = 0,
            },
        }

        local function SetArrowDir(self, arrow)
            self:SetSize(arrow.size, arrow.size)
            self:ClearAllPoints()
            self:SetPoint(arrow.pointDir, arrow.pointX + arrow.offsetX, arrow.pointY + arrow.offsetY)
            self.arrow:SetAtlas(arrow.atlas)
            self.arrowGlow:SetAtlas(arrow.atlasGlow)
            self.Anim.Translation:SetOffset(arrow.transX, arrow.transY)
        end

        local function CreateArrow(parent)
            local arrow = CreateFrame("Frame", nil, parent)
            arrow.SetArrowDir = SetArrowDir
            arrow:Hide()
            arrow:SetAlpha(0)
            arrow.arrow = arrow:CreateTexture(nil, "BACKGROUND")
            arrow.arrow:SetAllPoints()
            arrow.arrowGlow = arrow:CreateTexture(nil, "OVERLAY")
            arrow.arrowGlow:SetAllPoints()
            arrow.arrowGlow:SetAlpha(0.75)
            arrow.arrowGlow:SetBlendMode("ADD")
            arrow.Anim = arrow:CreateAnimationGroup()
            arrow.Anim.Translation = arrow.Anim:CreateAnimation("Translation")
            arrow.Anim.Translation:SetDuration(1)
            arrow.Anim.Translation:SetOrder(1)
            arrow.Anim.Translation:SetSmoothing("OUT")
            arrow.Anim.Alpha1 = arrow.Anim:CreateAnimation("Alpha")
            arrow.Anim.Alpha1:SetFromAlpha(0)
            arrow.Anim.Alpha1:SetToAlpha(1)
            arrow.Anim.Alpha1:SetDuration(0.1)
            arrow.Anim.Alpha1:SetOrder(1)
            arrow.Anim.Alpha2 = arrow.Anim:CreateAnimation("Alpha")
            arrow.Anim.Alpha2:SetFromAlpha(1)
            arrow.Anim.Alpha2:SetToAlpha(0)
            arrow.Anim.Alpha2:SetDuration(0.9)
            arrow.Anim.Alpha2:SetStartDelay(0.1)
            arrow.Anim.Alpha2:SetOrder(1)
            arrow.Anim.Alpha2:SetSmoothing("IN")
            arrow.Anim:SetScript("OnFinished", arrow.Anim.Play)
            return arrow
        end

        function frame.MiniFrame:UpdateArrow()
            local px = _G.UIParent:GetCenter()
            local cx = self:GetCenter()
            local arrow = cx >= px and ARROW_CONFIG.RIGHT or ARROW_CONFIG.LEFT
            self.arrow1:SetArrowDir(arrow)
            self.arrow2:SetArrowDir(arrow)
        end

        function frame.MiniFrame:UpdateState(isInCombat)
            if type(isInCombat) ~= "boolean" then
                isInCombat = not not InCombatLockdown()
            end
            if isInCombat == true then
                self:Hide()
            elseif isInCombat == false then
                self:SetShown(not frame:IsShown())
            end
            local numItems = frame:GetNumLootItems(LOG_TYPE.News)
            self:SetText(numItems > 0 and numItems or "")
            -- self:SetEnabled(numItems > 0)
            if not self.isGlowing and numItems >= config:Get("rwfBackgroundRemindAt") then
                self.isGlowing = true
                _G.ActionButton_ShowOverlayGlow(self)
                if not self.arrow1 then
                    self.arrow1 = CreateArrow(self)
                    self.arrow2 = CreateArrow(self)
                end
                self:UpdateArrow()
                self.arrow1:Show()
                self.arrow1.Anim:Play()
                C_Timer.NewTimer(0.5, function() self.arrow2:Show() self.arrow2.Anim:Play() end)
            end
        end

        local scanningTicker

        function frame.MiniFrame:StartScanning()
            if scanningTicker then
                return
            end
            scanningTicker = C_Timer.NewTicker(3, function() self.Spinner:Show() end, 1)
        end

        function frame.MiniFrame:StopScanning()
            if scanningTicker then
                scanningTicker:Cancel()
                scanningTicker = nil
            end
            self.Spinner:Hide()
        end

        function frame:OnShow()
            local isEnabled = config:Get("rwfMode")
            local isLogging, instanceName = rwf:GetLocation()
            local isLoggingGuildNews = true -- always logging guild news
            if not isLogging and isLoggingGuildNews then
                instanceName = _G.GUILD_NEWS or _G.GUILD_NEWS_TITLE
            end
            self.SubTitle:SetText(format("%s |cff%s%s|r", instanceName or "", (isLogging or isLoggingGuildNews) and "55ff55" or "ff55ff", isLogging and L.RWF_SUBTITLE_LOGGING_LOOT or L.RWF_SUBTITLE_LOGGING_FILTERED_LOOT))
            self.EnableModule:SetShown(not isEnabled)
            self.DisableModule:SetShown(isEnabled)
            local numItems = self:GetNumLootItems()
            self.ReloadUI:SetEnabled(numItems > 0)
            self.WipeLog:SetEnabled(numItems == 0)
        end

        local NEWS_TICKER = {
            Timer = 30,
            Tick = function()
                if InCombatLockdown() then
                    return
                end
                QueryGuildNews()
                GuildNewsSort(0)
            end,
            Start = function(self)
                self:Tick()
                if self.handle then
                    return
                end
                self:Stop()
                self.handle = C_Timer.NewTicker(self.Timer, self.Tick)
            end,
            Stop = function(self)
                if not self.handle then
                    return
                end
                self.handle:Cancel()
                self.handle = nil
            end,
        }

        frame:HookScript("OnShow", function()
            frame:OnShow()
            if config:Get("rwfBackgroundMode") then
                frame.MiniFrame:Hide()
            else
                NEWS_TICKER:Start()
            end
        end)

        frame:HookScript("OnHide", function()
            if config:Get("rwfBackgroundMode") then
                frame.MiniFrame:Show()
            else
                NEWS_TICKER:Stop()
            end
        end)

        local function OnSettingsChanged()
            if not config:IsEnabled() then
                return
            end
            frame:OnShow()
            if config:Get("rwfBackgroundMode") then
                frame.MiniFrame:SetShown(not frame:IsShown())
                NEWS_TICKER:Start()
            else
                frame.MiniFrame:Hide()
                if frame:IsShown() then
                    NEWS_TICKER:Start()
                else
                    NEWS_TICKER:Stop()
                end
            end
        end
        callback:RegisterEvent(OnSettingsChanged, "RAIDERIO_CONFIG_READY")
        callback:RegisterEvent(OnSettingsChanged, "RAIDERIO_SETTINGS_SAVED")

        local function CalculateEventDelta(oldTimestamp, oldFrameCounter, currentTimestamp, currentFrameCounter)
            if oldTimestamp ~= currentTimestamp then
                return ("(%.3fs, %d)"):format(currentTimestamp - oldTimestamp, currentFrameCounter - oldFrameCounter)
            end
        end

        function frame:GenerateTimestampData()
            local systemTimestamp = GetTime()
            local relativeTimestamp = systemTimestamp - self.loadTime
            local eventDelta
            local endElement = self.logDataProvider:Find(self.logDataProvider:GetSize())
            if endElement then
                eventDelta = CalculateEventDelta(endElement.relativeTimestamp, endElement.frameCounter, relativeTimestamp, self.frameCounter)
            end
            return systemTimestamp, relativeTimestamp, eventDelta
        end

        local MaxEvents = 1000

        local function TrimDataProvider(dataProvider)
            local dataProviderSize = dataProvider:GetSize()
            if dataProviderSize > MaxEvents then
                local extra = 100
                local overflow = dataProviderSize - MaxEvents
                dataProvider:RemoveIndexRange(1, overflow + extra)
            end
        end

        local function CountSources(sources)
            if not sources then
                return
            end
            local count = 0
            for _, _ in pairs(sources) do
                count = count + 1
            end
            if count < 2 then
                return
            end
            return format(" from %d %s", count, count == 0 or count > 1 and "sources" or "source")
        end

        local function GetDisplayText(elementData)
            local lootEntry = elementData.lootEntry ---@type RWFLootEntry
            local timeText = lootEntry.timestamp and date(lootEntry.type == LOG_TYPE.News and "%Y/%m/%d --:--:--" or "%Y/%m/%d %H:%M:%S", lootEntry.timestamp) or "----/--/-- --:--:--"
            local typeText = lootEntry.type and LOG_TYPE_LABEL[lootEntry.type] or "Unknown"
            local linkText = lootEntry.count and lootEntry.count > 1 and format("%sx%d", lootEntry.link, lootEntry.count) or lootEntry.link
            local sourcesText = lootEntry.sources and CountSources(lootEntry.sources) or ""
            return format("%s | %s | %s%s%s", timeText, typeText, linkText, sourcesText, lootEntry.who and format(" (%s)", lootEntry.who) or "")
        end

        local function GetHyperlink(elementData)
            local lootEntry = elementData.lootEntry ---@type RWFLootEntry
            return lootEntry.link
        end

        local function UpdateLootEntryLink(elementData, event)
            local lootEntry = elementData.lootEntry ---@type RWFLootEntry
            if lootEntry.link and not lootEntry.link:find("[]", nil, true) then return end
            local _, link = GetItemInfo(lootEntry.link)
            if not link then return end
            lootEntry.link = link
            return true
        end

        local function UpdateButtonText(button)
            local elementData = button.elementData
            elementData.text = GetDisplayText(elementData)
            button.LeftLabel:SetText(elementData.text)
        end

        function frame:CreateButtonAndInit(button, elementData)
            button.elementData = elementData
            if not button.isInit then
                button.isInit = true
                button:SetHeight(20)
                local function OnEvent(self, event, itemID, success)
                    if event ~= "GET_ITEM_INFO_RECEIVED" or not success or itemID ~= self.elementData.lootEntry.id then return end
                    if not UpdateLootEntryLink(self.elementData, event) then return end
                    UpdateButtonText(self)
                end
                local function OnClick(self)
                    local elementData = self.elementData
                    local link = GetHyperlink(elementData)
                    if not link then
                        return
                    end
                    SetItemRef(link, link, GetMouseButtonClicked() or "LeftButton", ChatEdit_GetActiveWindow())
                end
                local function OnEnter(self)
                    local elementData = self.elementData
                    local link = GetHyperlink(elementData)
                    if not link then
                        return
                    end
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetHyperlink(link)
                    GameTooltip:Show()
                end
                local function OnLeave(self)
                    GameTooltip:Hide()
                end
                button:RegisterEvent("GET_ITEM_INFO_RECEIVED")
                button:SetScript("OnEvent", OnEvent)
                button:SetScript("OnClick", OnClick)
                button:SetScript("OnEnter", OnEnter)
                button:SetScript("OnLeave", OnLeave)
                button.RightLabel = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                button.RightLabel:SetWordWrap(false)
                button.RightLabel:SetJustifyH("RIGHT")
                button.RightLabel:SetHeight(20)
                button.RightLabel:SetPoint("RIGHT", 0, -5)
                button.LeftLabel = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                button.LeftLabel:SetWordWrap(false)
                button.LeftLabel:SetJustifyH("LEFT")
                button.LeftLabel:SetHeight(20)
                button.LeftLabel:SetPoint("LEFT", 24 - 20, 0)
                button.LeftLabel:SetPoint("RIGHT", button.RightLabel, "LEFT", -5, 0)
            end
            UpdateLootEntryLink(elementData, self:IsShown())
            UpdateButtonText(button)
        end

        function frame:GetNumLootItems(lootEntryType)
            if not lootEntryType then
                return self.logDataProvider:GetSize()
            end
            local count = 0
            self.logDataProvider:ForEach(function(elementData)
                local lootEntry = elementData.lootEntry ---@type RWFLootEntry
                if lootEntry.type == lootEntryType then
                    count = count + 1
                end
            end)
            return count
        end

        ---@param lootEntry RWFLootEntry
        function frame:AddLoot(lootEntry, showFrame)
            if showFrame then
                self:Show()
            end
            PrepareLootEntryForSV(lootEntry)
            local preInsertAtScrollEnd = self.Log.Events.ScrollBox:IsAtEnd()
            local preInsertScrollable = self.Log.Events.ScrollBox:HasScrollableExtent()
            local systemTimestamp, relativeTimestamp, eventDelta = self:GenerateTimestampData()
            local elementData = { lootEntry = lootEntry, text = lootEntry.link }
            elementData.id = self.idCounter()
            elementData.systemTimestamp = systemTimestamp
            elementData.relativeTimestamp = relativeTimestamp
            elementData.frameCounter = self.frameCounter
            elementData.eventDelta = eventDelta
            self.logDataProvider:Insert(elementData)
            TrimDataProvider(self.logDataProvider)
            if preInsertAtScrollEnd or (not preInsertScrollable and self.Log.Events.ScrollBox:HasScrollableExtent()) then
                self.Log.Events.ScrollBox:ScrollToEnd(ScrollBoxConstants.NoScrollInterpolation)
            end
            frame.MiniFrame:UpdateState()
        end

        local function SetScrollBoxButtonAlternateState(scrollBox)
            local index = scrollBox:GetDataIndexBegin()
            scrollBox:ForEachFrame(function(button)
                -- button:SetAlternateOverlayShown(index % 2 == 1)
                index = index + 1
            end)
        end

        frame.Log.Events.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnDataRangeChanged, function(sortPending) SetScrollBoxButtonAlternateState(frame.Log.Events.ScrollBox) end, frame)

        local view = CreateScrollBoxListLinearView()
        view:SetElementExtent(20)
        view:SetElementInitializer("Button", function(button, elementData) frame:CreateButtonAndInit(button, elementData) end)

        local pad, spacing = 2
        view:SetPadding(pad, pad, pad, pad, spacing)
        ScrollUtil.InitScrollBoxListWithScrollBar(frame.Log.Events.ScrollBox, frame.Log.Events.ScrollBar, view)
        frame.Log.Events.ScrollBox:SetDataProvider(frame.logDataProvider)

        frame:Hide()
        OnSettingsChanged() -- jumpstart
        return frame
    end

    function rwf:CheckLocation()
        if not config:Get("rwfMode") then
            return
        end
        local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
        -- if config:Get("debugMode") then instanceType, difficultyID = "raid", 16 end -- DEBUG: treat any zone as a loggable zone
        if instanceType == "raid" and difficultyID == 16 then
            LOCATION.logging, LOCATION.instanceName, LOCATION.instanceDifficulty, LOCATION.instanceID = true, name, difficultyID, instanceID
            self:Enable()
        else
            LOCATION.logging = false
            self:Disable()
        end
    end

    function rwf:GetLocation()
        return LOCATION.logging, LOCATION.instanceName, LOCATION.instanceDifficulty, LOCATION.instanceID
    end

    function rwf:CanLoad()
        return config:IsEnabled() and config:Get("rwfMode")
    end

    function rwf:OnLoad()
        -- if config:Get("debugMode") then LOG_FILTER.GUILD_NEWS, LOG_FILTER.ITEM_LEVEL = "item:", 0 end -- DEBUG: any kind of loot and ilvl
        TrimHistoryFromSV()
        LOOT_FRAME = CreateLootFrame()
        self:CheckLocation()
        callback:RegisterEvent(OnEvent, "GUILD_NEWS_UPDATE")
        callback:RegisterEvent(OnZoneEvent, "PLAYER_ENTERING_WORLD", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA")
    end

    function rwf:OnEnable()
        LOOT_FRAME:OnShow()
        callback:RegisterEvent(OnEvent, unpack(TRACKING_EVENTS))
    end

    function rwf:OnDisable()
        LOOT_FRAME:OnShow()
        callback:UnregisterEvent(OnEvent, unpack(TRACKING_EVENTS))
    end

    function rwf:ToggleFrame()
        LOOT_FRAME:SetShown(not LOOT_FRAME:IsShown())
    end

    function rwf:ShowFrame()
        LOOT_FRAME:Show()
    end

    function rwf:HideFrame()
        LOOT_FRAME:Hide()
    end

end

-- settings.lua
-- dependencies: module, callback, json, config, util, profile, search
do

    ---@class SettingsModule : Module
    local settings = ns:NewModule("Settings") ---@type SettingsModule
    local callback = ns:GetModule("Callback") ---@type CallbackModule
    local json = ns:GetModule("JSON") ---@type JSONModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule
    local profile = ns:GetModule("Profile") ---@type ProfileModule
    local search = ns:GetModule("Search") ---@type SearchModule
    local rwf = ns:GetModule("RaceWorldFirst") ---@type RaceWorldFirstModule

    ---@type InternalStaticPopupDialog
    local RELOAD_POPUP = {
        id = "RAIDERIO_RELOADUI_CONFIRM",
        text = L.CHANGES_REQUIRES_UI_RELOAD,
        button1 = L.RELOAD_NOW,
        button2 = L.RELOAD_LATER,
        hasEditBox = false,
        preferredIndex = 3,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        OnShow = nil,
        OnHide = nil,
        OnAccept = ReloadUI,
        OnCancel = nil
    }

    ---@type InternalStaticPopupDialog
    local DEBUG_POPUP = {
        id = "RAIDERIO_DEBUG_CONFIRM",
        text = function() return config:Get("debugMode") and L.DISABLE_DEBUG_MODE_RELOAD or L.ENABLE_DEBUG_MODE_RELOAD end,
        button1 = L.CONFIRM,
        button2 = L.CANCEL,
        hasEditBox = false,
        preferredIndex = 3,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        OnShow = nil,
        OnHide = nil,
        OnAccept = function ()
            config:Set("debugMode", not config:Get("debugMode"))
            ReloadUI()
        end,
        OnCancel = nil
    }

    ---@type InternalStaticPopupDialog
    local RTWF_POPUP = {
        id = "RAIDERIO_RWF_CONFIRM",
        text = function() return config:Get("rwfMode") and L.DISABLE_RWF_MODE_RELOAD or L.ENABLE_RWF_MODE_RELOAD end,
        button1 = L.CONFIRM,
        button2 = L.CANCEL,
        hasEditBox = false,
        preferredIndex = 3,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        OnShow = nil,
        OnHide = nil,
        OnAccept = function ()
            config:Set("rwfMode", not config:Get("rwfMode"))
            ReloadUI()
        end,
        OnCancel = nil
    }

    local settingsFrame

    ---@class RaiderIOSettingsModuleColumn
    ---@field public icon number|string
    ---@field public text string
    ---@field public check "checkButton"|"checkButton2"|"checkButton3"
    ---@field public addon "addon1"|"addon2"|"addon3"

    ---@type RaiderIOSettingsModuleColumn[]
    local databaseModuleColumns = {
        { icon = 525134, text = L.DB_MODULES_HEADER_MYTHIC_PLUS, check = "checkButton", addon = "addon1" }, -- 525134 = inv_relics_hourglass
        { icon = 254652, text = L.DB_MODULES_HEADER_RAIDING, check = "checkButton2", addon = "addon2" }, -- 254652 = achievement_boss_ragnaros
        { icon = 442272, text = L.DB_MODULES_HEADER_RECRUITMENT, check = "checkButton3", addon = "addon3" }, -- 442272 = achievement_guildperk_everybodysfriend
    }

    local function CreateOptions()
        local configParentFrame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
        configParentFrame:SetSize(400, 600)
        configParentFrame:SetPoint("CENTER")

        local configHeaderFrame = CreateFrame("Frame", nil, configParentFrame) ---@diagnostic disable-line: param-type-mismatch
        configHeaderFrame:SetPoint("TOPLEFT", 00, -30)
        configHeaderFrame:SetPoint("TOPRIGHT", 00, 30)
        configHeaderFrame:SetHeight(40)

        local configScrollFrame = CreateFrame("ScrollFrame", nil, configParentFrame) ---@diagnostic disable-line: param-type-mismatch
        configScrollFrame:SetPoint("TOPLEFT", configHeaderFrame, "BOTTOMLEFT")
        configScrollFrame:SetPoint("TOPRIGHT", configHeaderFrame, "BOTTOMRIGHT")
        configScrollFrame:SetHeight(475)
        configScrollFrame:EnableMouseWheel(true)
        configScrollFrame:SetClampedToScreen(true)
        configScrollFrame:SetClipsChildren(true)

        local configButtonFrame = CreateFrame("Frame", nil, configParentFrame) ---@diagnostic disable-line: param-type-mismatch
        configButtonFrame:SetPoint("TOPLEFT", configScrollFrame, "BOTTOMLEFT", 0, -10)
        configButtonFrame:SetPoint("TOPRIGHT", configScrollFrame, "BOTTOMRIGHT")
        configButtonFrame:SetHeight(50)

        local configSliderFrame = CreateFrame("Slider", nil, configScrollFrame, "UIPanelScrollBarTemplate")
        configSliderFrame:SetPoint("TOPLEFT", configScrollFrame, "TOPRIGHT", -35, -18)
        configSliderFrame:SetPoint("BOTTOMLEFT", configScrollFrame, "BOTTOMRIGHT", -35, 18)
        configSliderFrame:SetMinMaxValues(1, 1)
        configSliderFrame:SetValueStep(50)
        configSliderFrame.scrollStep = 50
        configSliderFrame:SetValue(0)
        configSliderFrame:SetWidth(16)
        configSliderFrame:SetScript("OnValueChanged", function (self, value)
            self:GetParent():SetVerticalScroll(value)
        end)

        configScrollFrame:HookScript("OnMouseWheel", function(self, delta)
            local currentValue = configSliderFrame:GetValue()
            local changes = -delta * 50
            configSliderFrame:SetValue(currentValue + changes)
        end)

        local configFrame = CreateFrame("Frame", nil, configScrollFrame)
        configFrame:SetSize(400, 600) -- resized to proper value below
        configParentFrame.scrollframe = configScrollFrame
        configParentFrame.scrollbar = configSliderFrame
        configScrollFrame.content = configFrame
        configScrollFrame:SetScrollChild(configFrame)
        configParentFrame:Hide()

        local configOptions

        local function WidgetHelp_OnEnter(self)
            if not self.tooltip then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:AddLine(self.tooltip, 1, 1, 1, true)
            GameTooltip:Show()
        end

        local function WidgetButton_OnEnter(self)
            if self.SetBackdrop then
                self:SetBackdropColor(0.3, 0.3, 0.3, 1)
                self:SetBackdropBorderColor(1, 1, 1, 1)
            end
        end

        local function WidgetButton_OnLeave(self)
            if self.SetBackdrop then
                self:SetBackdropColor(0, 0, 0, 1)
                self:SetBackdropBorderColor(1, 1, 1, 0.3)
            end
        end

        local function Close_OnClick()
            configParentFrame:SetShown(not configParentFrame:IsShown())
        end

        local function Save_OnClick()
            Close_OnClick()
            local reload
            for i = 1, #configOptions.modules do
                local f = configOptions.modules[i]
                if f.isModuleToggle then
                    for _, column in ipairs(databaseModuleColumns) do
                        local check = f[column.check]
                        local addon = f[column.addon]
                        local checked = check:GetChecked()
                        local loaded = IsAddOnLoaded(addon)
                        if checked then
                            if not loaded then
                                reload = 1
                                EnableAddOn(addon)
                            end
                        elseif loaded then
                            reload = 1
                            DisableAddOn(addon)
                        end
                    end
                end
            end
            for i = 1, #configOptions.options do
                local f = configOptions.options[i]
                local checked = f.checkButton:GetChecked()
                local enabled = config:Get(f.cvar)
                config:Set(f.cvar, not not checked)
                if ((not enabled and checked) or (enabled and not checked)) then
                    if f.needReload then
                        reload = 1
                    end
                    if f.callback then
                        f.callback()
                    end
                end
            end
            for cvar in pairs(configOptions.radios) do
                local radios = configOptions.radios[cvar]
                for i = 1, #radios do
                    local f = radios[i]
                    local checked = f.checkButton:GetChecked()
                    local currentValue = config:Get(f.cvar)

                    if checked then
                        config:Set(f.cvar, f.valueRadio)

                        if currentValue ~= f.valueRadio and f.needReload then
                            reload = 1
                        end
                    end
                end
            end
            if reload then
                util:ShowStaticPopupDialog(RELOAD_POPUP)
            end
            callback:SendEvent("RAIDERIO_SETTINGS_SAVED")
        end

        configOptions = {
            modules = {},
            options = {},
            radios = {},
            backdrop = { -- TODO: 9.0
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            }
        }

        function configOptions.UpdateWidgetStates(self)
            for i = 1, #self.options do
                local f = self.options[i]
                if f.isDisabled then
                    if f:isDisabled() then
                        f.text:SetVertexColor(0.5, 0.5, 0.5)
                        f.help.icon:SetVertexColor(0.5, 0.5, 0.5)
                        f.checkButton:SetEnabled(false)
                        f.checkButton2:SetEnabled(false)
                    else
                        f.text:SetVertexColor(1, 1, 1)
                        f.help.icon:SetVertexColor(1, 1, 1)
                        f.checkButton:SetEnabled(true)
                        f.checkButton2:SetEnabled(true)
                    end
                end
                if f.isFakeChecked then
                    local useFakeCheckMark, useGrayCheckMark = f:isFakeChecked()
                    if useFakeCheckMark then
                        if useGrayCheckMark then
                            f.checkButton.fakeCheck:SetVertexColor(0.5, 0.5, 0.5)
                        else
                            f.checkButton.fakeCheck:SetVertexColor(1, 1, 1)
                        end
                        f.checkButton.fakeCheck:Show()
                    else
                        f.checkButton.fakeCheck:Hide()
                    end
                end
            end
        end

        function configOptions.Update(self)
            for i = 1, #self.modules do
                local f = self.modules[i]
                if f.isModuleToggle then
                    for _, column in ipairs(databaseModuleColumns) do
                        local check = f[column.check]
                        local addon = f[column.addon]
                        check:SetChecked(IsAddOnLoaded(addon))
                        local _, addonTitle = GetAddOnInfo(addon)
                        check:SetShown(addonTitle ~= nil)
                    end
                end
            end
            for i = 1, #self.options do
                local f = self.options[i]
                f.checkButton:SetChecked(config:Get(f.cvar) ~= false)
            end
            for cvar in pairs(self.radios) do
                local radios = configOptions.radios[cvar]
                for i = 1, #radios do
                    local f = radios[i]
                    f.checkButton:SetChecked(f.valueRadio == config:Get(f.cvar))
                end
            end
        end

        ---@class RaiderIOSettingsBaseWidget
        ---@field public bg Texture
        ---@field public text FontString
        ---@field public checkButton CheckButton
        ---@field public checkButton2 CheckButton
        ---@field public checkButton3 CheckButton
        ---@field public help Frame
        ---@field public tooltip? string

        function configOptions.CreateWidget(self, widgetType, height, parentFrame)

            ---@type RaiderIOSettingsBaseWidget
            local widget = CreateFrame(widgetType, nil, parentFrame or configFrame, BackdropTemplateMixin and "BackdropTemplate")

            if self.lastWidget then
                widget:SetPoint("TOPLEFT", self.lastWidget, "BOTTOMLEFT", 0, -24)
                widget:SetPoint("BOTTOMRIGHT", self.lastWidget, "BOTTOMRIGHT", 0, -4)
            else
                widget:SetPoint("TOPLEFT", parentFrame or configFrame, "TOPLEFT", 16, 0)
                widget:SetPoint("BOTTOMRIGHT", parentFrame or configFrame, "TOPRIGHT", -40, -16)
            end

            widget.bg = widget:CreateTexture()
            widget.bg:SetAllPoints()
            widget.bg:SetColorTexture(0, 0, 0, 0.5)

            widget.text = widget:CreateFontString(nil, nil, "GameFontNormal")
            widget.text:SetPoint("LEFT", 8, 0)
            widget.text:SetPoint("RIGHT", -8, 0)
            widget.text:SetJustifyH("LEFT")

            widget.checkButton = CreateFrame("CheckButton", nil, widget, "UICheckButtonTemplate") ---@diagnostic disable-line: param-type-mismatch
            widget.checkButton:Hide()
            widget.checkButton:SetPoint("RIGHT", -4, 0)
            widget.checkButton:SetScale(0.7)

            widget.checkButton2 = CreateFrame("CheckButton", nil, widget, "UICheckButtonTemplate") ---@diagnostic disable-line: param-type-mismatch
            widget.checkButton2:Hide()
            widget.checkButton2:SetPoint("RIGHT", widget.checkButton, "LEFT", -4, 0)
            widget.checkButton2:SetScale(0.7)

            widget.checkButton3 = CreateFrame("CheckButton", nil, widget, "UICheckButtonTemplate") ---@diagnostic disable-line: param-type-mismatch
            widget.checkButton3:Hide()
            widget.checkButton3:SetPoint("RIGHT", widget.checkButton2, "LEFT", -4, 0)
            widget.checkButton3:SetScale(0.7)

            widget.checkButton.fakeCheck = widget.checkButton:CreateTexture(nil, "OVERLAY")
            widget.checkButton.fakeCheck:Hide()
            widget.checkButton.fakeCheck:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
            widget.checkButton.fakeCheck:SetAllPoints()

            widget.help = CreateFrame("Frame", nil, widget) ---@diagnostic disable-line: param-type-mismatch
            widget.help:Hide()
            widget.help:SetPoint("LEFT", widget.checkButton, "LEFT", -20, 0)
            widget.help:SetSize(16, 16)
            widget.help:SetScale(0.9)
            widget.help.icon = widget.help:CreateTexture()
            widget.help.icon:SetAllPoints()
            widget.help.icon:SetTexture("Interface\\GossipFrame\\DailyActiveQuestIcon")

            widget.help:SetScript("OnEnter", WidgetHelp_OnEnter)
            widget.help:SetScript("OnLeave", GameTooltip_Hide)

            if widgetType == "Button" then
                widget.bg:Hide()
                widget.text:SetTextColor(1, 1, 1)
                if widget.SetBackdrop then
                    widget:SetBackdrop(self.backdrop)
                    widget:SetBackdropColor(0, 0, 0, 1)
                    widget:SetBackdropBorderColor(1, 1, 1, 0.3)
                end
                widget:SetScript("OnEnter", WidgetButton_OnEnter)
                widget:SetScript("OnLeave", WidgetButton_OnLeave)
            end

            if not parentFrame then
                self.lastWidget = widget
            end

            return widget
        end

        function configOptions.CreatePadding(self)
            ---@type RaiderIOSettingsBaseWidget
            local frame = self:CreateWidget("Frame")
            local _, lastWidget = frame:GetPoint(1)
            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -14)
            frame:SetPoint("BOTTOMRIGHT", lastWidget, "BOTTOMRIGHT", 0, -4)
            frame.bg:Hide()
            return frame
        end

        function configOptions.CreateHeadline(self, text, parentFrame)
            ---@type RaiderIOSettingsBaseWidget
            local frame = self:CreateWidget("Frame", nil, parentFrame)
            frame.bg:Hide()
            frame.text:SetText(text)
            return frame
        end

        ---@class RaiderIOSettingsModuleToggleWidget : RaiderIOSettingsBaseWidget
        ---@field public isModuleToggle boolean
        ---@field public addon1? string
        ---@field public addon2? string
        ---@field public addon3? string

        function configOptions.CreateModuleToggle(self, name, ...)
            ---@type RaiderIOSettingsModuleToggleWidget
            local frame = self:CreateWidget("Frame")
            frame.isModuleToggle = true
            frame.text:SetTextColor(1, 1, 1)
            frame.text:SetText(name)
            ---@type string[]
            local addonNames = {...}
            for i = #addonNames, 1, -1 do
                local addonName = addonNames[i]
                frame["addon" .. i] = addonName
                local check = "checkButton" .. (i > 1 and i or "")
                check = frame[check]
                if check then
                    check:SetShown(addonName)
                end
            end
            self.modules[#self.modules + 1] = frame
            return frame
        end

        ---@class RaiderIOSettingsToggleWidget : RaiderIOSettingsBaseWidget
        ---@field public tooltip string
        ---@field public cvar string
        ---@field public needReload boolean
        ---@field public isDisabled? boolean
        ---@field public isFakeChecked? boolean
        ---@field public callback? function

        function configOptions.CreateToggle(self, label, description, cvar, configOptions)
            ---@type RaiderIOSettingsToggleWidget
            local frame = self:CreateWidget("Frame")
            frame.text:SetTextColor(1, 1, 1)
            frame.text:SetText(label)
            frame.tooltip = description
            frame.cvar = cvar
            frame.needReload = (configOptions and configOptions.needReload) or false
            frame.isDisabled = (configOptions and configOptions.isDisabled) or nil
            frame.isFakeChecked = (configOptions and configOptions.isFakeChecked) or nil
            frame.callback = (configOptions and configOptions.callback) or nil
            frame.help.tooltip = description
            frame.help:Show()
            frame.checkButton:Show()
            return frame
        end

        function configOptions.CreateOptionToggle(self, label, description, cvar, configOptions)
            ---@type RaiderIOSettingsToggleWidget
            local frame = self:CreateToggle(label, description, cvar, configOptions)
            frame.checkButton:SetScript("OnClick", function ()
                self:UpdateWidgetStates()
            end)
            self.options[#self.options + 1] = frame
            return frame
        end

        ---@class RaiderIOSettingsRadioToggleWidget : RaiderIOSettingsToggleWidget
        ---@field public valueRadio any

        function configOptions.CreateRadioToggle(self, label, description, cvar, value, configOptions)
            ---@type RaiderIOSettingsRadioToggleWidget
            local frame = self:CreateToggle(label, description, cvar, configOptions)

            frame.valueRadio = value

            if self.radios[cvar] == nil then
                self.radios[cvar] = {}
            end

            self.radios[cvar][#self.radios[cvar] +1] = frame

            frame.checkButton:SetScript("OnClick", function ()
                -- Disable unchecking radio (to avoid having nothing chosen)
                if not frame.checkButton:GetChecked() then
                    frame.checkButton:SetChecked(true)
                end
                -- Uncheck every other radio for same cvar
                for i = 1, #self.radios[cvar] do
                    local f = self.radios[cvar][i]
                    if f.valueRadio ~= frame.valueRadio then
                        f.checkButton:SetChecked(false)
                    end
                end
            end)

            return frame
        end

        -- customize the look and feel
        do
            local function ConfigFrame_OnShow(self)
                if not InCombatLockdown() then
                    if SettingsPanel:IsShown() then
                        SettingsPanel:Open()
                    end
                    HideUIPanel(GameMenuFrame)
                end
                configOptions:Update()
                configOptions:UpdateWidgetStates()
            end

            local function ConfigFrame_OnDragStart(self)
                self:StartMoving()
            end

            local function ConfigFrame_OnDragStop(self)
                self:StopMovingOrSizing()
            end

            local function ConfigFrame_OnEvent(self, event)
                if event == "PLAYER_REGEN_ENABLED" then
                    if self.combatHidden then
                        self.combatHidden = nil
                        self:Show()
                    end
                elseif event == "PLAYER_REGEN_DISABLED" then
                    if self:IsShown() then
                        self.combatHidden = true
                        self:Hide()
                    end
                end
            end

            configParentFrame:SetFrameStrata("DIALOG")
            configParentFrame:SetFrameLevel(255)

            configParentFrame:EnableMouse(true)
            configParentFrame:SetClampedToScreen(true)
            configParentFrame:SetDontSavePosition(true)
            configParentFrame:SetMovable(true)
            configParentFrame:RegisterForDrag("LeftButton")

            if configParentFrame.SetBackdrop then
                configParentFrame:SetBackdrop(configOptions.backdrop) ---@diagnostic disable-line: param-type-mismatch
                configParentFrame:SetBackdropColor(0, 0, 0, 0.8) ---@diagnostic disable-line: param-type-mismatch
                configParentFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8) ---@diagnostic disable-line: param-type-mismatch
            end

            configParentFrame:SetScript("OnShow", ConfigFrame_OnShow)
            configParentFrame:SetScript("OnDragStart", ConfigFrame_OnDragStart)
            configParentFrame:SetScript("OnDragStop", ConfigFrame_OnDragStop)
            configParentFrame:SetScript("OnEvent", ConfigFrame_OnEvent)

            configParentFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
            configParentFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

            -- add widgets
            local header = configOptions:CreateHeadline(L.RAIDERIO_MYTHIC_OPTIONS .. "\nVersion: " .. tostring(GetAddOnMetadata(addonName, "Version")), configHeaderFrame)
            header.text:SetFont(header.text:GetFont(), 16, "OUTLINE")

            configOptions:CreateHeadline(L.CHOOSE_HEADLINE_HEADER)
            configOptions:CreateRadioToggle(L.SHOW_BEST_SEASON, L.SHOW_BEST_SEASON_DESC, "mplusHeadlineMode", 1)
            configOptions:CreateRadioToggle(L.SHOW_CURRENT_SEASON, L.SHOW_CURRENT_SEASON_DESC, "mplusHeadlineMode", 0)
            configOptions:CreateRadioToggle(L.SHOW_BEST_RUN, L.SHOW_BEST_RUN_DESC, "mplusHeadlineMode", 2)

            configOptions:CreatePadding()
            configOptions:CreateHeadline(L.GENERAL_TOOLTIP_OPTIONS)
            configOptions:CreateOptionToggle(L.SHOW_MAINS_SCORE, L.SHOW_MAINS_SCORE_DESC, "showMainsScore")
            configOptions:CreateOptionToggle(L.SHOW_BEST_MAINS_SCORE, L.SHOW_BEST_MAINS_SCORE_DESC, "showMainBestScore")
            configOptions:CreateOptionToggle(L.SHOW_ROLE_ICONS, L.SHOW_ROLE_ICONS_DESC, "showRoleIcons")
            configOptions:CreateOptionToggle(L.ENABLE_SIMPLE_SCORE_COLORS, L.ENABLE_SIMPLE_SCORE_COLORS_DESC, "showSimpleScoreColors")
            configOptions:CreateOptionToggle(L.ENABLE_NO_SCORE_COLORS, L.ENABLE_NO_SCORE_COLORS_DESC, "disableScoreColors")
            -- configOptions:CreateOptionToggle(L.SHOW_CHESTS_AS_MEDALS, L.SHOW_CHESTS_AS_MEDALS_DESC, "showMedalsInsteadOfText")
            configOptions:CreateOptionToggle(L.SHOW_KEYSTONE_INFO, L.SHOW_KEYSTONE_INFO_DESC, "enableKeystoneTooltips")
            configOptions:CreateOptionToggle(L.SHOW_AVERAGE_PLAYER_SCORE_INFO, L.SHOW_AVERAGE_PLAYER_SCORE_INFO_DESC, "showAverageScore")
            configOptions:CreateOptionToggle(L.SHOW_SCORE_IN_COMBAT, L.SHOW_SCORE_IN_COMBAT_DESC, "showScoreInCombat")
            configOptions:CreateOptionToggle(L.SHOW_SCORE_WITH_MODIFIER, L.SHOW_SCORE_WITH_MODIFIER_DESC, "showScoreModifier")
            configOptions:CreateOptionToggle(L.USE_ENGLISH_ABBREVIATION, L.USE_ENGLISH_ABBREVIATION_DESC, "useEnglishAbbreviations")

            configOptions:CreatePadding()
            configOptions:CreateHeadline(L.CONFIG_WHERE_TO_SHOW_TOOLTIPS)
            configOptions:CreateOptionToggle(L.SHOW_ON_PLAYER_UNITS, L.SHOW_ON_PLAYER_UNITS_DESC, "enableUnitTooltips")
            configOptions:CreateOptionToggle(L.SHOW_IN_LFD, L.SHOW_IN_LFD_DESC, "enableLFGTooltips")
            configOptions:CreateOptionToggle(L.SHOW_IN_FRIENDS, L.SHOW_IN_FRIENDS_DESC, "enableFriendsTooltips")
            configOptions:CreateOptionToggle(L.SHOW_ON_GUILD_ROSTER, L.SHOW_ON_GUILD_ROSTER_DESC, "enableGuildTooltips")
            configOptions:CreateOptionToggle(L.SHOW_IN_WHO_UI, L.SHOW_IN_WHO_UI_DESC, "enableWhoTooltips")
            configOptions:CreateOptionToggle(L.SHOW_IN_SLASH_WHO_RESULTS, L.SHOW_IN_SLASH_WHO_RESULTS_DESC, "enableWhoMessages")

            configOptions:CreatePadding()
            configOptions:CreateHeadline(L.TOOLTIP_PROFILE)
            configOptions:CreateOptionToggle(L.SHOW_RAIDERIO_PROFILE, L.SHOW_RAIDERIO_PROFILE_DESC, "showRaiderIOProfile")
            configOptions:CreateOptionToggle(L.HIDE_OWN_PROFILE, L.HIDE_OWN_PROFILE_DESC, "hidePersonalRaiderIOProfile")
            configOptions:CreateOptionToggle(L.SHOW_RAID_ENCOUNTERS_IN_PROFILE, L.SHOW_RAID_ENCOUNTERS_IN_PROFILE_DESC, "showRaidEncountersInProfile")
            configOptions:CreateOptionToggle(L.SHOW_LEADER_PROFILE, L.SHOW_LEADER_PROFILE_DESC, "enableProfileModifier")
            configOptions:CreateOptionToggle(L.INVERSE_PROFILE_MODIFIER, L.INVERSE_PROFILE_MODIFIER_DESC, "inverseProfileModifier")
            configOptions:CreateOptionToggle(L.ENABLE_AUTO_FRAME_POSITION, L.ENABLE_AUTO_FRAME_POSITION_DESC, "positionProfileAuto")
            configOptions:CreateOptionToggle(L.ENABLE_LOCK_PROFILE_FRAME, L.ENABLE_LOCK_PROFILE_FRAME_DESC, "lockProfile")

            configOptions:CreatePadding()
            configOptions:CreateHeadline(L.RAIDERIO_CLIENT_CUSTOMIZATION)
            configOptions:CreateOptionToggle(L.ENABLE_RAIDERIO_CLIENT_ENHANCEMENTS, L.ENABLE_RAIDERIO_CLIENT_ENHANCEMENTS_DESC, "enableClientEnhancements", { needReload = true })
            configOptions:CreateOptionToggle(L.SHOW_CLIENT_GUILD_BEST, L.SHOW_CLIENT_GUILD_BEST_DESC, "showClientGuildBest")

            configOptions:CreatePadding()
            configOptions:CreateHeadline(L.RAIDERIO_LIVE_TRACKING)
            local allowClientToControlCombatLogFrame = configOptions:CreateOptionToggle(L.USE_RAIDERIO_CLIENT_LIVE_TRACKING_SETTINGS, L.USE_RAIDERIO_CLIENT_LIVE_TRACKING_SETTINGS_DESC, "allowClientToControlCombatLog")
            local allowClientToControlCombatLogFrameIsChecked = function() return allowClientToControlCombatLogFrame.checkButton:GetChecked() end
            local clientConfig = ns:GetClientConfig()
            local isClientAutoCombatLoggingEnabled = function()
                if not allowClientToControlCombatLogFrameIsChecked() then
                    return
                end
                return clientConfig and clientConfig.enableCombatLogTracking, config:Get("enableCombatLogTracking")
            end
            configOptions:CreateOptionToggle(L.AUTO_COMBATLOG, L.AUTO_COMBATLOG_DESC, "enableCombatLogTracking", { isDisabled = allowClientToControlCombatLogFrameIsChecked, isFakeChecked = isClientAutoCombatLoggingEnabled })

            configOptions:CreatePadding()
            configOptions:CreateHeadline(L.COPY_RAIDERIO_PROFILE_URL)
            configOptions:CreateOptionToggle(L.ALLOW_ON_PLAYER_UNITS, L.ALLOW_ON_PLAYER_UNITS_DESC, "showDropDownCopyURL")
            configOptions:CreateOptionToggle(L.ALLOW_IN_LFD, L.ALLOW_IN_LFD_DESC, "enableLFGDropdown")

            configOptions:CreatePadding()
            configOptions:CreateHeadline(L.DB_MODULES)
            local modulesHeader = configOptions:CreateModuleToggle(L.MODULE_AMERICAS, "RaiderIO_DB_US_M", "RaiderIO_DB_US_R", "RaiderIO_DB_US_F")
            configOptions:CreateModuleToggle(L.MODULE_EUROPE, "RaiderIO_DB_EU_M", "RaiderIO_DB_EU_R", "RaiderIO_DB_EU_F")
            configOptions:CreateModuleToggle(L.MODULE_KOREA, "RaiderIO_DB_KR_M", "RaiderIO_DB_KR_R", "RaiderIO_DB_KR_F")
            configOptions:CreateModuleToggle(L.MODULE_TAIWAN, "RaiderIO_DB_TW_M", "RaiderIO_DB_TW_R", "RaiderIO_DB_TW_F")

            -- add save button and cancel buttons
            local buttons = configOptions:CreateWidget("Frame", 4, configButtonFrame)
            buttons:ClearAllPoints()
            buttons:SetPoint("TOPLEFT", configButtonFrame, "TOPLEFT", 16, 0)
            buttons:SetPoint("BOTTOMRIGHT", configButtonFrame, "TOPRIGHT", -16, -10)
            buttons:Hide()
            local save = configOptions:CreateWidget("Button", 4, configButtonFrame)
            local cancel = configOptions:CreateWidget("Button", 4, configButtonFrame)
            save:ClearAllPoints()
            save:SetPoint("LEFT", buttons, "LEFT", 0, -12)
            save:SetSize(96, 28)
            save.text:SetText(SAVE)
            save.text:SetJustifyH("CENTER")
            save:SetScript("OnClick", Save_OnClick)
            cancel:ClearAllPoints()
            cancel:SetPoint("RIGHT", buttons, "RIGHT", 0, -12)
            cancel:SetSize(96, 28)
            cancel.text:SetText(CANCEL)
            cancel.text:SetJustifyH("CENTER")
            cancel:SetScript("OnClick", Close_OnClick)

            -- adjust frame height dynamically
            local children = {configFrame:GetChildren()}
            local height = 0
            for i = 1, #children do
                height = height + children[i]:GetHeight() + 3.5
            end

            configSliderFrame:SetMinMaxValues(1, height - 440)
            configFrame:SetHeight(height)

            -- adjust frame width dynamically (add padding based on the largest option label string)
            local maxWidth = 0
            for i = 1, #configOptions.options do
                local option = configOptions.options[i]
                if option.text and option.text:GetObjectType() == "FontString" then
                    maxWidth = max(maxWidth, option.text:GetStringWidth())
                end
            end
            configFrame:SetWidth(160 + maxWidth)
            configParentFrame:SetWidth(160 + maxWidth)

            -- add type indicator headers over the database modules
            for _, column in ipairs(databaseModuleColumns) do
                local check = modulesHeader[column.check]
                local addon = modulesHeader[column.addon]
                local icon = format("|T%s:0:0:0:0:16:16:1:15:1:15|t", column.icon)
                local headline = configOptions:CreateHeadline(icon)
                headline:ClearAllPoints()
                headline:SetPoint("BOTTOM", check, "TOP", 2, -5)
                headline:SetSize(32, 32)
                headline:SetShown(addon)
                if column.text then
                    headline.tooltip = column.text
                    headline.help.tooltip = column.text
                    headline.help:SetAllPoints(headline.text)
                    headline.help:SetAlpha(0)
                    headline.help:Show()
                end
            end
        end

        return configParentFrame
    end

    local function SmartLoad()
        if settingsFrame then
            return true
        end
        if not settings:CanLoad() then
            return false
        end
        settings:OnLoad()
        return true
    end

    local function CreateInterfacePanel()
        local function Button_OnClick()
            if not InCombatLockdown() then
                if not SmartLoad() then
                    return
                end
                settingsFrame:SetShown(not settingsFrame:IsShown())
            end
        end

        local panel = CreateFrame("Frame", addonName .. "_SettingsPanel")
        panel.name = addonName
        panel:Hide()

        local button = CreateFrame("Button", "$parentButton", panel, "UIPanelButtonTemplate")
        button:SetText(L.OPEN_CONFIG)
        button:SetWidth(button:GetTextWidth() + 18)
        button:SetPoint("TOPLEFT", 16, -16)
        button:SetScript("OnClick", Button_OnClick)

        InterfaceOptions_AddCategory(panel, true)
    end

    local function CreateSlashCommand()
        _G["SLASH_" .. addonName .. "1"] = "/raiderio"
        _G["SLASH_" .. addonName .. "2"] = "/rio"

        local function handler(text)
            if not SmartLoad() then
                return
            end

            if type(text) == "string" then

                if text:find("^%s*[Ll][Oo][Cc][Kk]") then
                    profile:ToggleDrag()
                    return
                end

                if text:find("^%s*[Dd][Ee][Bb][Uu][Gg]") then
                    util:ShowStaticPopupDialog(DEBUG_POPUP)
                    return
                end

                if text:find("^%s*[Rr][Ww][Ff]") then
                    if rwf:IsLoaded() and config:Get("rwfMode") then
                        rwf:ToggleFrame()
                    else
                        util:ShowStaticPopupDialog(RTWF_POPUP)
                    end
                    return
                end

                if text:find("^%s*[Gg][Rr][Oo][Uu][Pp]") then
                    json:OpenCopyDialog()
                    return
                end

                local searchQuery = text:match("^%s*[Ss][Ee][Aa][Rr][Cc][Hh]%s*(.-)$")
                if searchQuery then
                    if strlenutf8(searchQuery) > 0 then
                        search:Show()
                        search:Search(searchQuery)
                    else
                        search:Toggle()
                    end
                    return
                end

            end

            -- resume regular routine
            if not InCombatLockdown() then
                settingsFrame:SetShown(not settingsFrame:IsShown())
            end
        end

        SlashCmdList[addonName] = handler
    end

    local function OnConfigReady()
        settings:Enable()
        settingsFrame = CreateOptions()
    end

    function settings:OnLoad()
        callback:RegisterEvent(OnConfigReady, "RAIDERIO_CONFIG_READY")
    end

    function settings:Show()
        if not self:IsEnabled() then
            return
        end
        settingsFrame:Show()
    end

    function settings:Hide()
        if not self:IsEnabled() then
            return
        end
        settingsFrame:Hide()
    end

    -- always have the interface panel and slash commands available
    CreateInterfacePanel()
    CreateSlashCommand()

end

-- combatlog.lua
-- dependencies: module, callback, config
do

    ---@class CombatLogModule : Module
    local combatlog = ns:NewModule("CombatLog") ---@type CombatLogModule
    local callback = ns:GetModule("Callback") ---@type CallbackModule
    local config = ns:GetModule("Config") ---@type ConfigModule

    local clientConfig = ns:GetClientConfig()

    local function UpdateModuleState()
        local enableCombatLogTracking
        if config:Get("allowClientToControlCombatLog") then
            enableCombatLogTracking = clientConfig and clientConfig.enableCombatLogTracking
        end
        if enableCombatLogTracking == nil then
            enableCombatLogTracking = config:Get("enableCombatLogTracking")
        end
        if enableCombatLogTracking then
            C_CVar.SetCVar("advancedCombatLogging", "1")
            combatlog:Enable()
        else
            combatlog:Disable()
        end
    end

    function combatlog:CanLoad()
        return config:IsEnabled()
    end

    function combatlog:OnLoad()
        UpdateModuleState()
        callback:RegisterEvent(UpdateModuleState, "RAIDERIO_SETTINGS_SAVED")
    end

    local LibCombatLogging = LibStub and LibStub:GetLibrary("LibCombatLogging-1.0", true) ---@type LibCombatLogging
    local LoggingCombat = LibCombatLogging and function(...) return LibCombatLogging.LoggingCombat("Raider.IO", ...) end or _G.LoggingCombat

    local autoLogFromMapID do
        ---@param instances DungeonInstance[]
        local function getLowestMapIdForInstances(instances)
            local mapID
            for _, instance in ipairs(instances) do
                if not mapID or mapID > instance.instance_map_id then
                    mapID = instance.instance_map_id
                end
            end
            return mapID
        end
        local raidMapID = getLowestMapIdForInstances(ns:GetDungeonRaidData())
        local keystoneMapID = getLowestMapIdForInstances(ns:GetDungeonData())
        if raidMapID and keystoneMapID then
            autoLogFromMapID = keystoneMapID > raidMapID and raidMapID or keystoneMapID
        elseif raidMapID then
            autoLogFromMapID = raidMapID
        elseif keystoneMapID then
            autoLogFromMapID = keystoneMapID
        else
            autoLogFromMapID = 0
        end
    end

    local alwaysLogDifficultyIDs = {
        -- scenario
        [167] = true, -- Torghast
        -- party
        [23] = true, -- Mythic
        [8] = true, -- Mythic Keystone
    }

    local canLogDifficultyIDs = {
        -- raid
        [14] = true, -- Normal
        [15] = true, -- Heroic
        [16] = true, -- Mythic
    }

    local lastActive
    local previouslyEnabledLogging
    local function CheckInstance(newModuleState)
        local _, _, difficultyID, _, _, _, _, instanceMapID = GetInstanceInfo()
        if not difficultyID or not instanceMapID then
            return
        end
        local isActive = not not (alwaysLogDifficultyIDs[difficultyID] or (instanceMapID >= autoLogFromMapID and canLogDifficultyIDs[difficultyID]))
        if isActive == lastActive then
            return
        end
        lastActive = isActive
        local isLogging = LoggingCombat()
        local setLogging
        if isActive and isLogging and newModuleState == true then
            setLogging = true
        elseif isActive and isLogging and newModuleState == false then
            setLogging = false
        elseif isActive and not isLogging then
            setLogging = true
        elseif not isActive and isLogging then
            setLogging = false
        end
        if setLogging == nil then
            return
        end
        if not setLogging and not previouslyEnabledLogging then
            return
        end
        previouslyEnabledLogging = setLogging
        config:Set("previouslyEnabledLogging", setLogging)
        LoggingCombat(setLogging)
        if not LibCombatLogging then
            local info = ChatTypeInfo.SYSTEM
            DEFAULT_CHAT_FRAME:AddMessage("|cffFFFFFFRaider.IO|r: " .. (setLogging and COMBATLOGENABLED or COMBATLOGDISABLED), info.r, info.g, info.b, info.id)
        end
    end

    function combatlog:OnEnable()
        previouslyEnabledLogging = config:Get("previouslyEnabledLogging")
        CheckInstance(true)
        callback:RegisterEvent(CheckInstance, "PLAYER_ENTERING_WORLD", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "ZONE_CHANGED_INDOORS", "RAID_INSTANCE_WELCOME")
    end

    function combatlog:OnDisable()
        lastActive = nil
        CheckInstance(false)
        callback:UnregisterCallback(CheckInstance)
        lastActive = nil
    end

end

-- serverlog.lua (requires debug mode)
-- dependencies: module, callback, config, util
do

    ---@class ServerLogModule : Module
    local serverlog = ns:NewModule("ServerLog") ---@type ServerLogModule
    local callback = ns:GetModule("Callback") ---@type CallbackModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local util = ns:GetModule("Util") ---@type UtilModule

    local TRACKING_EVENTS = {
        "COMBAT_LOG_EVENT_UNFILTERED",
        "UNIT_AURA",
        "UNIT_FLAGS",
        "UNIT_MODEL_CHANGED",
        "UNIT_NAME_UPDATE",
        "UNIT_PHASE",
        "UNIT_SPELLCAST_CHANNEL_START",
        "UNIT_SPELLCAST_CHANNEL_STOP",
        "UNIT_SPELLCAST_START",
        "UNIT_SPELLCAST_STOP",
        "UNIT_TARGET",
    }

    local COMBATLOG_OBJECT_AFFILIATION_MINE = _G.COMBATLOG_OBJECT_AFFILIATION_MINE or 0x00000001
    local COMBATLOG_OBJECT_AFFILIATION_OUTSIDER = _G.COMBATLOG_OBJECT_AFFILIATION_OUTSIDER or 0x00000008
    local COMBATLOG_OBJECT_CONTROL_PLAYER = _G.COMBATLOG_OBJECT_CONTROL_PLAYER or 0x00000100
    local COMBATLOG_OBJECT_TYPE_PLAYER = _G.COMBATLOG_OBJECT_TYPE_PLAYER or 0x00000400

    local MINE = bor(COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_CONTROL_PLAYER)
    local OTHER_PLAYER = bor(COMBATLOG_OBJECT_AFFILIATION_OUTSIDER, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PLAYER)

    local CHECKED = {}

    ---@return boolean @`true` if the provided guid is another player (context assumes we do check the flags for this information, if flags is nil we only care that guid exists).
    local function IsOtherPlayerGUID(guid, flags)
        if not guid then
            return false
        end
        if flags ~= nil and (band(flags, MINE) == MINE or band(flags, OTHER_PLAYER) ~= OTHER_PLAYER) then
            return false
        end
        return true
    end

    ---@return nil @The provided guid is checked if it's a player, and if the serverId is unknown, if that's the case we will log it into the SV and map it to our known regionId.
    local function InspectPlayerGUID(guid)
        if not guid then
            return
        end
        local guidType, serverId = strsplit("-", guid)
        if guidType ~= "Player" then
            return
        end
        if CHECKED[serverId] then
            return
        end
        CHECKED[serverId] = true
        serverId = tonumber(serverId) or 0
        if serverId < 1 then
            return
        end
        local ltd, regionId = util:GetRegionForServerId(serverId)
        if ltd or regionId then
            return
        end
        local cache = _G.RaiderIO_MissingServers[serverId]
        if cache ~= nil then
            return
        end
        _G.RaiderIO_MissingServers[serverId] = ns.PLAYER_REGION_ID
    end

    local function OnEvent(event, ...)
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            local _, _, _, sourceGUID, _, sourceFlags, _, destGUID, _, destFlags = ...
            if IsOtherPlayerGUID(sourceGUID, sourceFlags) then
                InspectPlayerGUID(sourceGUID)
            end
            if IsOtherPlayerGUID(destGUID, destFlags) then
                InspectPlayerGUID(destGUID)
            end
        else
            local unit = ...
            if not unit or not UnitIsPlayer(unit) or UnitIsUnit(unit, "player") then
                return
            end
            local guid = UnitGUID(unit)
            if guid then
                InspectPlayerGUID(guid)
            end
        end
    end

    function serverlog:CanLoad()
        return config:IsEnabled() and config:Get("debugMode") -- TODO: do not load this module by default (it's not yet tested well enough) but we do load it if debug mode is enabled
    end

    function serverlog:OnLoad()
        self:Enable()
        InspectPlayerGUID(UnitGUID("player")) -- in case we are on a missing server we will ensure we log it with this call
    end

    function serverlog:OnEnable()
        callback:RegisterEvent(OnEvent, unpack(TRACKING_EVENTS))
    end

    function serverlog:OnDisable()
        callback:UnregisterEvent(OnEvent, unpack(TRACKING_EVENTS))
    end

end

-- tests.lua (requires debug mode)
-- dependencies: module, config, provider
do

    ---@class TestsModule : Module
    local tests = ns:NewModule("Tests") ---@type TestsModule
    local config = ns:GetModule("Config") ---@type ConfigModule
    local provider = ns:GetModule("Provider") ---@type ProviderModule

    ---@class TestData @This can either be a `table` object with the structure as described in the class, or a `function` we call that returns `status` and `explanation` if there is something to report.
    ---@field public skip boolean @Set `true` to skip this test.
    ---@field public region string @`eu`, `us`, etc.
    ---@field public realm string @The character realm same format as the whisper friendly `GetNormalizedRealmName()` format.
    ---@field public name string @The character name.
    ---@field public success boolean @Set `true` if the profile exists and contains data, otherwise `false` to ensure it is empty or missing.
    ---@field public exists boolean @Set `true` if the test expects the profile to exist, otherwise `false` to ensure it doesn't exist
    -- private fields
    ---@field public profile DataProviderCharacterProfile @Private. Set internally once the test runs and the profile is attempted retrieved.
    ---@field public status boolean @Private. Set internally to `true` if the test passed, otherwise `false` if something went wrong.
    ---@field public explanation string @Private. Set internally to describe what went wrong, or what went right depending on the test.

    ---@param guid1 any
    ---@param guid2 any
    ---@return boolean? @If the GUID strings match (strcmputf8i) we return `true` otherwise `false`, if `nil` it means one GUID is missing from the call.
    local function CompareProfileGUIDs(guid1, guid2)
        if type(guid1) ~= "string" or type(guid2) ~= "string" then
            return
        end
        return guid1 == guid2 or strcmputf8i(guid1, guid2) == 0
    end

    ---@param profile1 DataProviderCharacterProfile?
    ---@param profile2 DataProviderCharacterProfile?
    ---@return boolean? @If the profiles reference the same person we return `true` otherwise `false` for different people, `nil` if one profile is missing from the call.
    local function CompareProfiles(profile1, profile2)
        if type(profile1) ~= "table" or type(profile2) ~= "table" then
            return
        end
        return profile1 == profile2 or (profile1.mythicKeystoneProfile and profile1.mythicKeystoneProfile == profile2.mythicKeystoneProfile) or (profile1.raidProfile and profile1.raidProfile == profile2.raidProfile) or (profile1.pvpProfile and profile1.pvpProfile == profile2.pvpProfile)
    end

    ---@param collection TestData[]
    local function CheckBothTestsAboveForSameProfiles(collection, id)
        local id1 = id - 2
        local id2 = id - 1
        local test1 = collection[id1]
        local test2 = collection[id2]
        if not test1 or not test2 then
            return nil, format("Test#%d/#%d missing.", id1, id2)
        elseif test1.skip or test2.skip then
            return nil, format("Test#%d/#%d marked for skipping.", id1, id2)
        elseif test1.status and test2.status and CompareProfiles(test1.profile, test2.profile) then
            return true, format("Test#%d/#%d looked up the same profile.", id1, id2)
        elseif test1.status and test2.status and test1.exists ~= nil and test2.exists ~= nil and (test1.exists and CompareProfiles(test1.profile, test2.profile) or not CompareProfiles(test1.profile, test2.profile)) then
            return true, format("Test#%d/#%d looked up %s profile.", id1, id2, test1.exists and "existing" or "missing")
        elseif not test1.status or not test2.status then
            return nil, format("Test#%d/#%d failed.", id1, id2)
        elseif not CompareProfiles(test1.profile, test2.profile) then
            return false, format("Test#%d/#%d looked up different profiles.", id1, id2)
        end
        return false, format("Unhandled logic branch.", id)
    end

    ---@type TestData[]
    local collection = {
        -- { region = "eu", realm = "TarrenMill", name = "Vladinator", success = true },
        -- { region = "eu", realm = "tArReNmIlL", name = "vLaDiNaToR", success = true },
        -- CheckBothTestsAboveForSameProfiles,
        -- { region = "eu", realm = "Ysondre", name = "Isak", success = true },
        -- { region = "eu", realm = "ySoNdRe", name = "iSaK", success = true },
        -- CheckBothTestsAboveForSameProfiles,
        -- { region = "us", realm = "tichondrius", name = "proview", success = true },
        -- { region = "us", realm = "TiChOnDrIuS", name = "pRoViEw", success = true },
        -- CheckBothTestsAboveForSameProfiles,
        -- { region = "eu", realm = "СвежевательДуш", name = "Хитей", success = true },
        -- { region = "eu", realm = "СВЕЖЕВАТЕЛЬДУШ", name = "ХИТЕЙ", success = true },
        -- CheckBothTestsAboveForSameProfiles,
        -- { region = "eu", realm = "Kazzak", name = "Donskís", success = true },
        -- { region = "eu", realm = "KAZZAK", name = "DONSKÍS", success = true },
        -- CheckBothTestsAboveForSameProfiles,
        -- { region = "kr", realm = "윈드러너", name = "갊깖읾옮짊맒", success = true },
        -- { region = "kr", realm = "윈드러너", name = "갊깖읾옮짊맒", success = true },
        -- CheckBothTestsAboveForSameProfiles,
    }

    local providers = provider:GetProviders()

    local function AppendTestsFromProviders(callback, progress)

        local utf8 = ns.utf8

        if not utf8 then
            ns.Print("|cffFFFFFFRaiderIO|r Unable to append excessive tests because utf8 is not available.")
            return false
        end

        local utf8lower = utf8.utf8upper
        local utf8upper = utf8.utf8lower

        local index = #collection

        local function CreateTestFromDB(_, region, db)
            if not db then
                return
            end
            for realmName, realmData in pairs(db) do
                local realmNameLC = utf8lower(realmName)
                local realmNameUC
                if strcmputf8i(realmNameLC, realmName) == 0 then
                    realmNameUC = utf8upper(realmName)
                else
                    realmNameLC = nil
                end
                for i = 2, #realmData do
                    local characterName = realmData[i]
                    local characterNameLC = utf8lower(characterName)
                    local characterNameUC
                    if strcmputf8i(characterNameLC, characterName) == 0 then
                        characterNameUC = utf8upper(characterName)
                    else
                        characterNameLC = nil
                    end
                    index = index + 3
                    collection[index - 2] = { region = region, realm = realmNameLC or realmName, name = characterNameLC or characterName, success = true }
                    collection[index - 1] = { region = region, realm = realmNameUC or realmName, name = characterNameUC or characterName, success = true }
                    collection[index] = CheckBothTestsAboveForSameProfiles
                end
            end
        end

        local function RunQueuedTest(self)
            wipe(collection)
            index = 0
            for i = #self, #self - (3 * 1000) + 1, -1 do
                local task = table.remove(self, i)
                if not task then
                    break
                end
                index = index + 1
                collection[index] = task
            end
            tests:RunTests(true, true)
            provider:WipeCache()
            return index > 0
        end

        local frame = CreateFrame("Frame")
        local co, cq, ch, cc, cp
        local queue, qindex = {}, 0
        local testqueue, tqindex = {}, 0

        frame:SetScript("OnUpdate", function(frame)
            frame:Hide()
            if co then
                coroutine.resume(co, cq)
            end
        end)

        local function OnUpdate(self, ...)
            while 1 do
                if ch == CreateTestFromDB then
                    local args = table.remove(self, 1)
                    if not args then
                        break
                    end
                    ch(self, args[1], args[2])
                    if cp then
                        cp(self, args)
                    end
                else
                    local continue = ch(self)
                    if cp then
                        cp(self)
                    end
                    if not continue then
                        break
                    end
                end
                frame:Show()
                coroutine.yield()
            end
            co = nil
            if cc then
                cc()
            end
        end

        for _, provider in pairs(providers) do
            qindex = qindex + 1
            queue[qindex] = { provider.region, provider.db }
        end

        local function OnCreateSuccess()
            for _, test in ipairs(collection) do
                tqindex = tqindex + 1
                testqueue[tqindex] = test
            end
            wipe(collection)
            co = coroutine.create(OnUpdate)
            cq = testqueue
            ch = RunQueuedTest
            cc = callback
            cp = progress
            coroutine.resume(co, cq)
        end

        ns.Print("|cffFFFFFFRaiderIO|r Running excessive built-in tests:")

        co = coroutine.create(OnUpdate)
        cq = queue
        ch = CreateTestFromDB
        cc = OnCreateSuccess
        cp = progress
        coroutine.resume(co, cq)

        return true

    end

    local function OnAppendProviderTestsCompleted()
        provider:WipeCache()
        ns.Print("|cffFFFFFFRaiderIO|r Done!")
    end

    local function CountProfilesInDataSet(data)
        if type(data) ~= "table" then
            return 0
        end
        local count = 0
        for _, items in pairs(data) do
            if type(items) == "table" then
                count = count + #items - 1
            end
        end
        return count
    end

    local function OnAppendProviderTestsProgress(queue, args)
        if not args or type(args) ~= "table" then
            ns.Print(format("[#%d] remaining...", #queue + 1))
        else
            ns.Print(format("[#%d] Checking |cffFFFFFF%s %s|r (%d profiles)", #queue + 1, tostring(args[1]), tostring(args[2]), CountProfilesInDataSet(args[3])))
        end
    end

    local function HasRegionData(region)
        for _, provider in pairs(providers) do
            if provider.region == region then
                return true
            end
        end
        return false
    end

    function tests:RunTests(showOnlyFailed, noHeaderOrFooter)
        if not noHeaderOrFooter then
            ns.Print(format("|cffFFFFFFRaiderIO|r Running %d built-in tests:", #collection))
        end
        local printed
        for id, test in ipairs(collection) do
            local status, explanation
            if type(test) == "function" then
                status, explanation = test(collection, id)
            elseif type(test) == "table" then
                if not test.skip and HasRegionData(test.region) then
                    test.profile = provider:GetProfile(test.name, test.realm, test.region)
                    if test.profile and not test.profile.success and test.success == true then
                        test.status = false
                        test.explanation = "Profile exists, no data."
                    elseif test.profile and test.profile.success and test.success == false then
                        test.status = false
                        test.explanation = "Profile exists, has data."
                    elseif not test.profile and test.success ~= nil then
                        test.status = false
                        test.explanation = "Profile doesn't exist."
                    elseif not test.profile and test.exists == true then
                        test.status = false
                        test.explanation = "Profile doesn't exist."
                    elseif test.profile and test.exists == false then
                        test.status = false
                        test.explanation = "Profile exists exist."
                    else
                        test.status = true
                    end
                    if test.status == false and test.explanation then
                        test.explanation = format("%s |cffFFFFFF(%s-%s-%s)|r", test.explanation, test.region, test.realm, test.name)
                    end
                    status, explanation = test.status, test.explanation
                end
            else
                printed = true
                ns.Print(format("|cffFFFFFFRaiderIO|r Test#%d is not supported, skipping.", id))
            end
            if status ~= nil and (not showOnlyFailed or not status) then
                printed = true
                ns.Print(format("|cffFFFFFFRaiderIO|r Test#%d |cff%s%s|r", id, status and "55FF55" or "FF5555", explanation or (status and "Passed!" or "Failed!")))
            end
        end
        if not noHeaderOrFooter then
            ns.Print(format("|cffFFFFFFRaiderIO|r Done! %s", printed and "" or "|cff55FF55Nothing to report.|r"))
        end
    end

    function tests:CanLoad()
        return config:IsEnabled() and config:Get("debugMode") -- TODO: do not load this module by default as we only care if tests pass or fail when in debug mode
    end

    function tests:OnLoad()
        self:Enable()
        self:RunTests(true)
        provider:WipeCache()
        -- AppendTestsFromProviders(OnAppendProviderTestsCompleted, OnAppendProviderTestsProgress) -- DEBUG: excessive testing so we might wanna comment this out when it's not required
    end

end
