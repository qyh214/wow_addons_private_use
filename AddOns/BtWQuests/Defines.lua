BtWQuests = {
    Constant = {
        Expansions = {
            Classic = LE_EXPANSION_CLASSIC or 0,
            TheBurningCrusade = LE_EXPANSION_BURNING_CRUSADE or 1,
            WrathOfTheLichKing = LE_EXPANSION_WRATH_OF_THE_LICH_KING or 2,
            Cataclysm = LE_EXPANSION_CATACLYSM or 3,
            MistsOfPandaria = LE_EXPANSION_MISTS_OF_PANDARIA or 4,
            WarlordsOfDraenor = LE_EXPANSION_WARLORDS_OF_DRAENOR or 5,
            Legion = LE_EXPANSION_LEGION or 6,
            BattleForAzeroth = LE_EXPANSION_BATTLE_FOR_AZEROTH or 7,
            Shadowlands = LE_EXPANSION_SHADOWLANDS or 8,
            Dragonflight = LE_EXPANSION_DRAGONFLIGHT or 9,
        },
        Faction = {
            Alliance = "Alliance",
            Horde = "Horde",
        },
        Race = {
            Dwarf = "Dwarf",
            Draenei = "Draenei",
            Gnome = "Gnome",
            Human = "Human",
            NightElf = "NightElf",
            Worgen = "Worgen",
            BloodElf = "BloodElf",
            Goblin = "Goblin",
            Orc = "Orc",
            Tauren = "Tauren",
            Scourge = "Scourge",
            Troll = "Troll",
            Pandaren = "Pandaren",
            DarkIronDwarf = "DarkIronDwarf",
        },
        Class = {
            Warrior = 1,
            Paladin = 2,
            Hunter = 3,
            Rogue = 4,
            Priest = 5,
            DeathKnight = 6,
            Shaman = 7,
            Mage = 8,
            Warlock = 9,
            Monk = 10,
            Druid = 11,
            DemonHunter = 12,
        },
        Region = {
            US = 1,
            Korea= 2,
            Europe = 3,
            Taiwan = 4,
            China= 5,
        },
        Timezone = {
            AmericaChicago  = "America/Chicago",
            AmericaLosangelas  = "America/Los_Angeles",
            AmericaNewyork  = "America/New_York",
            AustraliaMelbourn  = "Australia/Melbourne",
            AmericaDenver  = "America/Denver",
            AmericaSaopaulo  = "America/Sao_Paulo",
            EuropeParis  = "Europe/Paris",
            AsiaSeoul  = "Asia/Paris",
            AsiaTaipei  = "Asia/Paris",
        },
        QuestTag = {
            Group = Enum.QuestTag.Group,
            Pvp = Enum.QuestTag.Pvp,
            Raid = Enum.QuestTag.Raid,
            Dungeon = Enum.QuestTag.Dungeon,
            Legendary = Enum.QuestTag.Legendary,
            Heroic = Enum.QuestTag.Heroic,
            Raid10 = Enum.QuestTag.Raid10,
            Raid25 = Enum.QuestTag.Raid25,
            Scenario = Enum.QuestTag.Scenario,
            Account = Enum.QuestTag.Account,
        },
        Category = {
            Classic = {},
            TheBurningCrusade = {},
            WrathOfTheLichKing = {},
            Cataclysm = {},
            MistsOfPandaria = {},
            WarlordsOfDraenor = {},
            BattleForAzeroth = {},
            Shadowlands = {},
            Dragonflight = {},
        },
        Chain = {
            Classic = {},
            TheBurningCrusade = {},
            WrathOfTheLichKing = {},
            Cataclysm = {},
            MistsOfPandaria = {},
            WarlordsOfDraenor = {},
            BattleForAzeroth = {},
            Shadowlands = {},
            Dragonflight = {},
        },
        Restrictions = {
            Alliance = { type = "faction", id = "Alliance" },
            Horde = { type = "faction", id = "Horde" },
        }
    },
    L = {},
};
setmetatable(BtWQuests.L, {
    __index = function (self, key)
		return key;
	end
});

BTWQUESTS_EXPANSION_CLASSIC = LE_EXPANSION_CLASSIC or 0
BTWQUESTS_EXPANSION_THE_BURNING_CRUSADE = LE_EXPANSION_BURNING_CRUSADE or 1
BTWQUESTS_EXPANSION_WRATH_OF_THE_LICH_KING = LE_EXPANSION_WRATH_OF_THE_LICH_KING or 2
BTWQUESTS_EXPANSION_CATACLYSM = LE_EXPANSION_CATACLYSM or 3
BTWQUESTS_EXPANSION_MISTS_OF_PANDARIA = LE_EXPANSION_MISTS_OF_PANDARIA or 4
BTWQUESTS_EXPANSION_WARLORDS_OF_DRAENOR = LE_EXPANSION_WARLORDS_OF_DRAENOR or 5
BTWQUESTS_EXPANSION_LEGION = LE_EXPANSION_LEGION or 6
BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH = LE_EXPANSION_BATTLE_FOR_AZEROTH or 7

BTWQUESTS_CLASS_ID_WARRIOR = 1
BTWQUESTS_CLASS_ID_PALADIN = 2
BTWQUESTS_CLASS_ID_HUNTER = 3
BTWQUESTS_CLASS_ID_ROGUE = 4
BTWQUESTS_CLASS_ID_PRIEST = 5
BTWQUESTS_CLASS_ID_DEATHKNIGHT = 6
BTWQUESTS_CLASS_ID_SHAMAN = 7
BTWQUESTS_CLASS_ID_MAGE = 8
BTWQUESTS_CLASS_ID_WARLOCK = 9
BTWQUESTS_CLASS_ID_MONK = 10
BTWQUESTS_CLASS_ID_DRUID = 11
BTWQUESTS_CLASS_ID_DEMONHUNTER = 12

BTWQUESTS_FACTION_ID_ALLIANCE = "Alliance"
BTWQUESTS_FACTION_ID_HORDE = "Horde"

BTWQUESTS_RACE_ID_DWARF = "Dwarf"
BTWQUESTS_RACE_ID_DRAENEI = "Draenei"
BTWQUESTS_RACE_ID_GNOME = "Gnome"
BTWQUESTS_RACE_ID_HUMAN = "Human"
BTWQUESTS_RACE_ID_NIGHT_ELF = "NightElf"
BTWQUESTS_RACE_ID_WORGEN = "Worgen"
BTWQUESTS_RACE_ID_BLOOD_ELF = "BloodElf"
BTWQUESTS_RACE_ID_GOBLIN = "Goblin"
BTWQUESTS_RACE_ID_ORC = "Orc"
BTWQUESTS_RACE_ID_TAUREN = "Tauren"
BTWQUESTS_RACE_ID_SCOURGE = "Scourge"
BTWQUESTS_RACE_ID_PANDAREN = "Pandaren"

BTWQUESTS_REGION_ID_US = 1
BTWQUESTS_REGION_ID_KOREA = 2
BTWQUESTS_REGION_ID_EUROPE = 3
BTWQUESTS_REGION_ID_TAIWAN = 4
BTWQUESTS_REGION_ID_CHINA = 5

BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO = "America/Chicago"
BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS = "America/Los_Angeles"
BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK = "America/New_York"
BTWQUESTS_TIMEZONE_ID_AUSTRALIA_MELBOURN = "Australia/Melbourne"
BTWQUESTS_TIMEZONE_ID_AMERICA_DENVER = "America/Denver"
BTWQUESTS_TIMEZONE_ID_AMERICA_SAOPAULO = "America/Sao_Paulo"

BTWQUESTS_TIMEZONE_ID_EUROPE_PARIS = "Europe/Paris"
BTWQUESTS_TIMEZONE_ID_ASIA_SEOUL = "Asia/Seoul"
BTWQUESTS_TIMEZONE_ID_ASIA_TAIPEI = "Asia/Taipei"

BTWQUESTS_QUEST_TAG_GROUP = Enum.QuestTag.Group
BTWQUESTS_QUEST_TAG_PVP = Enum.QuestTag.PvP
BTWQUESTS_QUEST_TAG_RAID = Enum.QuestTag.Raid
BTWQUESTS_QUEST_TAG_DUNGEON = Enum.QuestTag.Dungeon
BTWQUESTS_QUEST_TAG_LEGENDARY = Enum.QuestTag.Legendary
BTWQUESTS_QUEST_TAG_HEROIC = Enum.QuestTag.Heroic
BTWQUESTS_QUEST_TAG_RAID10 = Enum.QuestTag.Raid10
BTWQUESTS_QUEST_TAG_RAID25 = Enum.QuestTag.Raid25
BTWQUESTS_QUEST_TAG_SCENARIO = Enum.QuestTag.Scenario
BTWQUESTS_QUEST_TAG_ACCOUNT = Enum.QuestTag.Account