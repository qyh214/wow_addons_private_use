--[[
    Character data handling
]]

local _, Internal = ...;
local L = Internal.L;

local UnitSex = UnitSex
local UnitRace = UnitRace
local UnitClass = UnitClass
local UnitFullName = UnitFullName
local GetRealmName = GetRealmName
local GetClassInfo = GetClassInfo
local GetNumClasses = GetNumClasses
local GetTalentInfoByID = GetTalentInfoByID
local GetSpecialization = GetSpecialization
local GetPvpTalentSlotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo;
local GetNumSpecializations = GetNumSpecializations
local GetSpecializationInfo = GetSpecializationInfo
local GetTalentInfoBySpecialization = GetTalentInfoBySpecialization
local GetNumSpecializationsForClassID = GetNumSpecializationsForClassID
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID
local GetEssenceInfo = C_AzeriteEssence.GetEssenceInfo;

local roles = {"TANK", "HEALER", "DAMAGER"};
local roleIndexes = {["TANK"] = 1, ["HEALER"] = 2, ["DAMAGER"] = 3};
local classInfo = {};
local classInfoBySpecID = {};
function Internal.Roles()
    return ipairs(roles)
end
function Internal.GetClassInfo(class)
	return classInfo[class]
end
function Internal.GetClassInfoBySpecID(spec)
	return classInfoBySpecID[spec]
end
function Internal.GetClassID(class)
	return classInfo[class] and classInfo[class].classID;
end
function Internal.GetClassFile(class)
	return classInfo[class] and classInfo[class].classFile;
end
function Internal.IsClassRoleValid(class, role)
	return (classInfo[class] and classInfo[class].roles[role]) and true or false;
end
function Internal.UpdateClassInfo()
    for classIndex=1,GetNumClasses() do
		if GetNumSpecializationsForClassID(classIndex) > 0 then
			local info = C_CreatureInfo.GetClassInfo(classIndex);
			local classID = info.classID;
			
			info.specs, info.roles = {}, {};
			for specIndex=1,GetNumSpecializationsForClassID(classID) do
				local id, _, _, _, role = GetSpecializationInfoForClassID(classID, specIndex);

				info.specs[specIndex] = id;
				info.roles[role] = true;
				
				classInfoBySpecID[id] = info;
			end

			classInfo[classID] = info;
			classInfo[info.classFile] = info;
		end
    end
end

local treesByClassID = {
    [1] = { 60, 61, 62 }, -- Warrior
    [2] = { 48, 49, 50 }, -- Paladin
    [3] = { 42, 43, 44 }, -- Hunter
    [4] = { 51, 52, 53 }, -- Rogue
    [5] = { 18, 19, 20 }, -- Priest
    [6] = { 31, 32, 33 }, -- Death Knight
    [7] = { 54, 55, 56 }, -- Shaman
    [8] = { 39, 40, 41 }, -- Mage
    [9] = { 57, 58, 59 }, -- Warlock
    [10] = { 64, 65, 66 }, -- Monk
    [11] = { 21, 22, 23, 24 }, -- Druid
    [12] = { 34, 35 }, -- Demon Hunter
    [13] = { 36, 37, 38 }, -- Evoker
}
local treesBySpecID = {
    [62] = { 39, 40 }, -- Arcane
    [63] = { 39, 41 }, -- Fire
    [64] = { 40, 41 }, -- Frost
    [65] = { 49, 50 }, -- Holy
    [66] = { 48, 49 }, -- Protection
    [70] = { 48, 50 }, -- Retribution
    [71] = { 60, 62 }, -- Arms
    [72] = { 60, 61 }, -- Fury
    [73] = { 61, 62 }, -- Protection
    [102] = { 23, 24 }, -- Balance
    [103] = { 21, 22 }, -- Feral
    [104] = { 21, 24 }, -- Guardian
    [105] = { 22, 23 }, -- Restoration
    [250] = { 31, 33 }, -- Blood
    [251] = { 32, 33 }, -- Frost
    [252] = { 31, 32 }, -- Unholy
    [253] = { 43, 44 }, -- Beast Mastery
    [254] = { 42, 44 }, -- Marksmanship
    [255] = { 42, 43 }, -- Survival
    [256] = { 18, 20 }, -- Discipline
    [257] = { 19, 20 }, -- Holy
    [258] = { 18, 19 }, -- Shadow
    [259] = { 52, 53 }, -- Assassination
    [260] = { 51, 52 }, -- Outlaw
    [261] = { 51, 53 }, -- Subtlety
    [262] = { 55, 56 }, -- Elemental
    [263] = { 54, 55 }, -- Enhancement
    [264] = { 54, 56 }, -- Restoration
    [265] = { 57, 58 }, -- Affliction
    [266] = { 57, 59 }, -- Demonology
    [267] = { 58, 59 }, -- Destruction
    [268] = { 65, 66 }, -- Brewmaster
    [269] = { 64, 65 }, -- Windwalker
    [270] = { 64, 66 }, -- Mistweaver
    [577] = { 34, 35 }, -- Havoc
    [581] = { 34, 35 }, -- Vengeance
    [1467] = { 36, 37 }, -- Devastation
    [1468] = { 37, 38 }, -- Preservation
    [1473] = { 36, 38 }, -- Augmentation
}
local specsByTreeID = {
    [18] = { 256, 258 }, -- Voidweaver
    [19] = { 257, 258 }, -- Archon
    [20] = { 256, 257 }, -- Oracle
    [21] = { 103, 104 }, -- Druid of the Claw
    [22] = { 103, 105 }, -- Wildstalker
    [23] = { 102, 105 }, -- Keeper of the Grove
    [24] = { 102, 104 }, -- Elune's Chosen
    [31] = { 250, 252 }, -- San'layn
    [32] = { 251, 252 }, -- Rider of the Apocalypse
    [33] = { 250, 251 }, -- Deathbringer
    [34] = { 577, 581 }, -- Fel-Scarred
    [35] = { 577, 581 }, -- Aldrachi Reaver
    [36] = { 1467, 1473 }, -- Scalecommander
    [37] = { 1467, 1468 }, -- Flameshaper
    [38] = { 1468, 1473 }, -- Chronowarden
    [39] = { 62, 63 }, -- Sunfury
    [40] = { 62, 64 }, -- Spellslinger
    [41] = { 63, 64 }, -- Frostfire
    [42] = { 254, 255 }, -- Sentinel
    [43] = { 253, 255 }, -- Pack Leader
    [44] = { 253, 254 }, -- Dark Ranger
    [48] = { 66, 70 }, -- Templar
    [49] = { 65, 66 }, -- Lightsmith
    [50] = { 65, 70 }, -- Herald of the Sun
    [51] = { 260, 261 }, -- Trickster
    [52] = { 259, 260 }, -- Fatebound
    [53] = { 259, 261 }, -- Deathstalker
    [54] = { 263, 264 }, -- Totemic
    [55] = { 262, 263 }, -- Stormbringer
    [56] = { 262, 264 }, -- Farseer
    [57] = { 265, 266 }, -- Soul Harvester
    [58] = { 265, 267 }, -- Hellcaller
    [59] = { 266, 267 }, -- Diabolist
    [60] = { 71, 72 }, -- Slayer
    [61] = { 72, 73 }, -- Mountain Thane
    [62] = { 71, 73 }, -- Colossus
    [64] = { 269, 270 }, -- Conduit of the Celestials
    [65] = { 268, 269 }, -- Shado-Pan
    [66] = { 268, 270 }, -- Master of Harmony
}
local classByTreeID = {
    [18] = 5, -- Voidweaver
    [19] = 5, -- Archon
    [20] = 5, -- Oracle
    [21] = 11, -- Druid of the Claw
    [22] = 11, -- Wildstalker
    [23] = 11, -- Keeper of the Grove
    [24] = 11, -- Elune's Chosen
    [31] = 6, -- San'layn
    [32] = 6, -- Rider of the Apocalypse
    [33] = 6, -- Deathbringer
    [34] = 12, -- Fel-Scarred
    [35] = 12, -- Aldrachi Reaver
    [36] = 13, -- Scalecommander
    [37] = 13, -- Flameshaper
    [38] = 13, -- Chronowarden
    [39] = 8, -- Sunfury
    [40] = 8, -- Spellslinger
    [41] = 8, -- Frostfire
    [42] = 3, -- Sentinel
    [43] = 3, -- Pack Leader
    [44] = 3, -- Dark Ranger
    [48] = 2, -- Templar
    [49] = 2, -- Lightsmith
    [50] = 2, -- Herald of the Sun
    [51] = 4, -- Trickster
    [52] = 4, -- Fatebound
    [53] = 4, -- Deathstalker
    [54] = 7, -- Totemic
    [55] = 7, -- Stormbringer
    [56] = 7, -- Farseer
    [57] = 9, -- Soul Harvester
    [58] = 9, -- Hellcaller
    [59] = 9, -- Diabolist
    [60] = 1, -- Slayer
    [61] = 1, -- Mountain Thane
    [62] = 1, -- Colossus
    [64] = 10, -- Conduit of the Celestials
    [65] = 10, -- Shado-Pan
    [66] = 10, -- Master of Harmony
}
function Internal.IsHeroTalentTreeValidForSpecID(treeID, specID)
    for _,id in ipairs(specsByTreeID[treeID]) do
        if id == specID then
            return true
        end
    end
    return false
end
function Internal.GetClassIDByHeroTalentTreeID(treeID)
    return classByTreeID[treeID]
end
function Internal.GetSpecIDsByHeroTalentTreeID(treeID)
    return specsByTreeID[treeID]
end
function Internal.GetHeroTalentTreeIDsByClassID(classID)
	return treesByClassID[classID]
end
function Internal.GetHeroTalentTreeIDsBySpecID(specID)
    return treesBySpecID[specID]
end

-- In very niche situations UnitFullName will not correctly respond with the realm
-- but since player realm cant change while logged in we can just reuse the previous value
local playerNameCache, playerRealmCache
function Internal.GetCharacterSlug()
	local name, realm = UnitFullName("player");

	playerNameCache = name or playerNameCache
	playerRealmCache = realm or playerRealmCache

	return playerRealmCache .. "-" .. playerNameCache
end

local GetSpecInfoVersion;
local VerifyTalentForSpec;
local VerifyPvPTalentForSpec;
local GetTalentInfoForSpecID;
local GetPvpTalentSlotInfoForSpecID;
do
	local specInfo
	if Internal.Is110100 then
		specInfo = {
			version = 15,

			-- Warrior
			[71] = { -- Arms
				talents = {
					{22624, 22360, 22371},
					{19676, 22372, 22789},
					{22380, 22489, 19138},
					{15757, 22627, 22628},
					{22392, 22391, 22362},
					{22394, 22397, 22399},
					{21204, 22407, 21667},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							28,   31,   33,
							34, 3534, 5372,
							5547, 5625, 5630,
							5679, 5701,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							28,   31,   33,
							34, 3534, 5372,
							5547, 5625, 5630,
							5679, 5701,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							28,   31,   33,
							34, 3534, 5372,
							5547, 5625, 5630,
							5679, 5701,
						}
					},
				},
			},
			[72] = { -- Fury
				talents = {
					{22632, 22633, 22491},
					{19676, 22625, 23093},
					{22379, 22381, 23372},
					{23097, 22627, 22382},
					{22383, 22393, 19140},
					{22396, 22398, 22400},
					{22405, 22402, 16037},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							177,  179, 3528,
							3533, 3735, 5373,
							5548, 5624, 5628,
							5678, 5702,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							177,  179, 3528,
							3533, 3735, 5373,
							5548, 5624, 5628,
							5678, 5702,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							177,  179, 3528,
							3533, 3735, 5373,
							5548, 5624, 5628,
							5678, 5702,
						}
					},
				},
			},
			[73] = { -- Protection
				talents = {
					{15760, 15759, 15774},
					{19676, 22629, 22409},
					{22378, 22626, 23260},
					{23096, 22627, 22488},
					{22384, 22631, 22800},
					{22395, 22544, 22401},
					{23455, 22406, 23099},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							24,  168,  171,
							173,  175,  831,
							833,  845, 5374,
							5626, 5627, 5629,
							5703,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							24,  168,  171,
							173,  175,  831,
							833,  845, 5374,
							5626, 5627, 5629,
							5703,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							24,  168,  171,
							173,  175,  831,
							833,  845, 5374,
							5626, 5627, 5629,
							5703,
						}
					},
				},
			},
			-- Paladin
			[65] = { -- Holy
				talents = {
					{17565, 17567, 17569},
					{22176, 17575, 17577},
					{22179, 22180, 21811},
					{22433, 22434, 17593},
					{17597, 17599, 17601},
					{23191, 23680, 22484},
					{21201, 21671, 23681},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							85,   86,   87,
							640,  642, 3618,
							5583, 5618, 5663,
							5665, 5674, 5676,
							5692,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							85,   86,   87,
							640,  642, 3618,
							5583, 5618, 5663,
							5665, 5674, 5676,
							5692,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							85,   86,   87,
							640,  642, 3618,
							5583, 5618, 5663,
							5665, 5674, 5676,
							5692,
						}
					},
				},
			},
			[66] = { -- Protection
				talents = {
					{22428, 22558, 23469},
					{22431, 22604, 23468},
					{22179, 22180, 21811},
					{22433, 22434, 22435},
					{17597, 17599, 17601},
					{22189, 22438, 23087},
					{23457, 21202, 22645},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							90,   91,   92,
							94,   97,  844,
							860,  861, 3474,
							5582, 5664, 5667,
							5677,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							90,   91,   92,
							94,   97,  844,
							860,  861, 3474,
							5582, 5664, 5667,
							5677,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							90,   91,   92,
							94,   97,  844,
							860,  861, 3474,
							5582, 5664, 5667,
							5677,
						}
					},
				},
			},
			[70] = { -- Retribution
				talents = {
					{22590, 22557, 23467},
					{22319, 22592, 23466},
					{22179, 22180, 21811},
					{22433, 22434, 22183},
					{17597, 17599, 17601},
					{23167, 22483, 23086},
					{23456, 22215, 22634},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							81,  752,  753,
							5535, 5572, 5573,
							5584, 5666, 5675,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							81,  752,  753,
							5535, 5572, 5573,
							5584, 5666, 5675,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							81,  752,  753,
							5535, 5572, 5573,
							5584, 5666, 5675,
						}
					},
				},
			},
			-- Hunter
			[253] = { -- Beast Mastery
				talents = {
					{22291, 22280, 22282},
					{22500, 22266, 22290},
					{19347, 19348, 23100},
					{22441, 22347, 22269},
					{22268, 22276, 22499},
					{19357, 22002, 23044},
					{22273, 21986, 22295},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							693,  824,  825,
							1214, 3599, 3604,
							3730, 5441, 5444,
							5534, 5689,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							693,  824,  825,
							1214, 3599, 3604,
							3730, 5441, 5444,
							5534, 5689,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							693,  824,  825,
							1214, 3599, 3604,
							3730, 5441, 5444,
							5534, 5689,
						}
					},
				},
			},
			[254] = { -- Marksmanship
				talents = {
					{22279, 22501, 22289},
					{22495, 22497, 22498},
					{19347, 19348, 23100},
					{22267, 22286, 21998},
					{22268, 22276, 23463},
					{23063, 23104, 22287},
					{22274, 22308, 22288},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							651,  653,  659,
							660, 3729, 5440,
							5533, 5688, 5700,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							651,  653,  659,
							660, 3729, 5440,
							5533, 5688, 5700,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							651,  653,  659,
							660, 3729, 5440,
							5533, 5688, 5700,
						}
					},
				},
			},
			[255] = { -- Survival
				talents = {
					{22275, 22283, 22296},
					{21997, 22769, 22297},
					{19347, 19348, 23100},
					{22277, 19361, 22299},
					{22268, 22276, 22499},
					{22300, 22278, 22271},
					{22272, 22301, 23105},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							661,  662,  664,
							665,  686, 3607,
							3609, 5443, 5532,
							5690,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							661,  662,  664,
							665,  686, 3607,
							3609, 5443, 5532,
							5690,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							661,  662,  664,
							665,  686, 3607,
							3609, 5443, 5532,
							5690,
						}
					},
				},
			},
			-- Rogue
			[259] = { -- Assassination
				talents = {
					{22337, 22338, 22339},
					{22331, 22332, 23022},
					{19239, 19240, 19241},
					{22340, 22122, 22123},
					{19245, 23037, 22115},
					{22343, 23015, 22344},
					{21186, 22133, 23174},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5530,
							5550, 5697,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5530,
							5550, 5697,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5530,
							5550, 5697,
						}
					},
				},
			},
			[260] = { -- Outlaw
				talents = {
					{22118, 22119, 22120},
					{23470, 19237, 19238},
					{19239, 19240, 19241},
					{22121, 22122, 22123},
					{23077, 22114, 22115},
					{21990, 23128, 19250},
					{22125, 23075, 23175},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							129,  138,  139,
							145,  853, 1208,
							3421, 3483, 3619,
							5549, 5699,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							129,  138,  139,
							145,  853, 1208,
							3421, 3483, 3619,
							5549, 5699,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							129,  138,  139,
							145,  853, 1208,
							3421, 3483, 3619,
							5549, 5699,
						}
					},
				},
			},
			[261] = { -- Subtlety
				talents = {
					{19233, 19234, 19235},
					{22331, 22332, 22333},
					{19239, 19240, 19241},
					{22128, 22122, 22123},
					{23078, 23036, 22115},
					{22335, 19249, 22336},
					{22132, 23183, 21188},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							146,  846,  856,
							1209, 3447, 3462,
							5406, 5409, 5411,
							5529, 5698,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							146,  846,  856,
							1209, 3447, 3462,
							5406, 5409, 5411,
							5529, 5698,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							146,  846,  856,
							1209, 3447, 3462,
							5406, 5409, 5411,
							5529, 5698,
						}
					},
				},
			},
			-- Priest
			[256] = { -- Discipline
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							100,  109,  111,
							114,  123,  126,
							855, 5416, 5480,
							5487, 5570, 5635,
							5640,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							100,  109,  111,
							114,  123,  126,
							855, 5416, 5480,
							5487, 5570, 5635,
							5640,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							100,  109,  111,
							114,  123,  126,
							855, 5416, 5480,
							5487, 5570, 5635,
							5640,
						}
					},
				},
			},
			[257] = { -- Holy
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							101,  108,  112,
							124,  127, 1927,
							5365, 5366, 5479,
							5485, 5569, 5634,
							5639,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							101,  108,  112,
							124,  127, 1927,
							5365, 5366, 5479,
							5485, 5569, 5634,
							5639,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							101,  108,  112,
							124,  127, 1927,
							5365, 5366, 5479,
							5485, 5569, 5634,
							5639,
						}
					},
				},
			},
			[258] = { -- Shadow
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							106,  113,  763,
							5381, 5447, 5481,
							5486, 5568, 5636,
							5638,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							106,  113,  763,
							5381, 5447, 5481,
							5486, 5568, 5636,
							5638,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							106,  113,  763,
							5381, 5447, 5481,
							5486, 5568, 5636,
							5638,
						}
					},
				},
			},
			-- Death Knight
			[250] = { -- Blood
				talents = {
					{19165, 19166, 23454},
					{19218, 19219, 19220},
					{19221, 22134, 22135},
					{22013, 22014, 22015},
					{19227, 19226, 19228},
					{19230, 19231, 19232},
					{21207, 21208, 21209},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							204,  206,  608,
							609,  841, 3441,
							3511, 5587, 5592,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							204,  206,  608,
							609,  841, 3441,
							3511, 5587, 5592,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							204,  206,  608,
							609,  841, 3441,
							3511, 5587, 5592,
						}
					},
				},
			},
			[251] = { -- Frost
				talents = {
					{22016, 22017, 22018},
					{22019, 22020, 22021},
					{22515, 22517, 22519},
					{22521, 22523, 22525},
					{22527, 22530, 23373},
					{22531, 22533, 22535},
					{22023, 22109, 22537},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							701,  702, 3439,
							3512, 5429, 5435,
							5510, 5586, 5591,
							5693,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							701,  702, 3439,
							3512, 5429, 5435,
							5510, 5586, 5591,
							5693,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							701,  702, 3439,
							3512, 5429, 5435,
							5510, 5586, 5591,
							5693,
						}
					},
				},
			},
			[252] = { -- Unholy
				talents = {
					{22024, 22025, 22026},
					{22027, 22028, 22029},
					{22516, 22518, 22520},
					{22522, 22524, 22526},
					{22528, 22529, 23373},
					{22532, 22534, 22536},
					{22030, 22110, 22538},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							40,   41,  149,
							152, 3746, 5430,
							5436, 5511, 5585,
							5590,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							40,   41,  149,
							152, 3746, 5430,
							5436, 5511, 5585,
							5590,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							40,   41,  149,
							152, 3746, 5430,
							5436, 5511, 5585,
							5590,
						}
					},
				},
			},
			-- Shaman
			[262] = { -- Elemental
				talents = {
					{22356, 22357, 22358},
					{23108, 23460, 23190},
					{23162, 23163, 23164},
					{19271, 19272, 19273},
					{22144, 22172, 21966},
					{22145, 19266, 23111},
					{21198, 22153, 21675},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							727, 3488, 3490,
							3491, 3620, 5574,
							5659, 5660, 5681,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							727, 3488, 3490,
							3491, 3620, 5574,
							5659, 5660, 5681,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							727, 3488, 3490,
							3491, 3620, 5574,
							5659, 5660, 5681,
						}
					},
				},
			},
			[263] = { -- Enhancement
				talents = {
					{22354, 22355, 22353},
					{22636, 23462, 23109},
					{23165, 19260, 23166},
					{23089, 23090, 22171},
					{22144, 22149, 21966},
					{21973, 22352, 22351},
					{21970, 22977, 21972},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							722, 3487, 3489,
							3492, 3622, 5438,
							5575, 5596, 5658,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							722, 3487, 3489,
							3492, 3622, 5438,
							5575, 5596, 5658,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							722, 3487, 3489,
							3492, 3622, 5438,
							5575, 5596, 5658,
						}
					},
				},
			},
			[264] = { -- Restoration
				talents = {
					{19262, 19263, 19264},
					{19259, 23461, 21963},
					{19275, 23110, 22127},
					{22152, 22322, 22323},
					{22144, 19269, 21966},
					{19265, 21971, 21968},
					{21969, 21199, 22359},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							708,  714,  715,
							3755, 5388, 5437,
							5567, 5576, 5704,
							5705,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							708,  714,  715,
							3755, 5388, 5437,
							5567, 5576, 5704,
							5705,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							708,  714,  715,
							3755, 5388, 5437,
							5567, 5576, 5704,
							5705,
						}
					},
				},
			},
			-- Mage
			[62] = { -- Arcane
				talents = {
					{22458, 22461, 22464},
					{23072, 22443, 16025},
					{22444, 22445, 22447},
					{22453, 22467, 22470},
					{22907, 22448, 22471},
					{22455, 22449, 22474},
					{21630, 21144, 21145},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							635,  637, 3529,
							5397, 5488, 5491,
							5589, 5601, 5661,
							5707,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							635,  637, 3529,
							5397, 5488, 5491,
							5589, 5601, 5661,
							5707,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							635,  637, 3529,
							5397, 5488, 5491,
							5589, 5601, 5661,
							5707,
						}
					},
				},
			},
			[63] = { -- Fire
				talents = {
					{22456, 22459, 22462},
					{23071, 22443, 23074},
					{22444, 22445, 22447},
					{22450, 22465, 22468},
					{22904, 22448, 22471},
					{22451, 23362, 22472},
					{21631, 22220, 21633},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							644,  648, 5389,
							5489, 5495, 5588,
							5602, 5621, 5685,
							5706,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							644,  648, 5389,
							5489, 5495, 5588,
							5602, 5621, 5685,
							5706,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							644,  648, 5389,
							5489, 5495, 5588,
							5602, 5621, 5685,
							5706,
						}
					},
				},
			},
			[64] = { -- Frost
				talents = {
					{22457, 22460, 22463},
					{22442, 22443, 23073},
					{22444, 22445, 22447},
					{22452, 22466, 22469},
					{22446, 22448, 22471},
					{22454, 23176, 22473},
					{21632, 22309, 21634},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							66,  632,  634,
							5390, 5490, 5496,
							5497, 5581, 5600,
							5622, 5708,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							66,  632,  634,
							5390, 5490, 5496,
							5497, 5581, 5600,
							5622, 5708,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							66,  632,  634,
							5390, 5490, 5496,
							5497, 5581, 5600,
							5622, 5708,
						}
					},
				},
			},
			-- Warlock
			[265] = { -- Affliction
				talents = {
					{22039, 23140, 23141},
					{22044, 21180, 22089},
					{19280, 19285, 19286},
					{19279, 19292, 22046},
					{22047, 19291, 23465},
					{23139, 23159, 19295},
					{19284, 19281, 19293},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							15,   16,   18,
							19, 5379, 5386,
							5392, 5546, 5579,
							5608, 5662, 5695,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							15,   16,   18,
							19, 5379, 5386,
							5392, 5546, 5579,
							5608, 5662, 5695,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							15,   16,   18,
							19, 5379, 5386,
							5392, 5546, 5579,
							5608, 5662, 5695,
						}
					},
				},
			},
			[266] = { -- Demonology
				talents = {
					{19290, 22048, 23138},
					{22045, 21694, 23158},
					{19280, 19285, 19286},
					{22477, 22042, 23160},
					{22047, 19291, 23465},
					{23147, 23146, 21717},
					{23161, 22479, 23091},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							162, 1213, 3506,
							3624, 5394, 5545,
							5577, 5606, 5694,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							162, 1213, 3506,
							3624, 5394, 5545,
							5577, 5606, 5694,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							162, 1213, 3506,
							3624, 5394, 5545,
							5577, 5606, 5694,
						}
					},
				},
			},
			[267] = { -- Destruction
				talents = {
					{22038, 22090, 22040},
					{23148, 21695, 23157},
					{19280, 19285, 19286},
					{22480, 22043, 23143},
					{22047, 19291, 23465},
					{23155, 23156, 19295},
					{19284, 23144, 23092},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							157,  164, 3508,
							5382, 5393, 5401,
							5580, 5607, 5696,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							157,  164, 3508,
							5382, 5393, 5401,
							5580, 5607, 5696,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							157,  164, 3508,
							5382, 5393, 5401,
							5580, 5607, 5696,
						}
					},
				},
			},
			-- Monk
			[268] = { -- Brewmaster
				talents = {
					{23106, 19820, 20185},
					{19304, 19818, 19302},
					{22099, 22097, 19992},
					{19993, 19994, 19995},
					{20174, 23363, 20175},
					{19819, 20184, 22103},
					{22106, 22104, 22108},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							666,  667,  668,
							669,  670,  672,
							673,  765,  843,
							1958, 5417, 5538,
							5541,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							666,  667,  668,
							669,  670,  672,
							673,  765,  843,
							1958, 5417, 5538,
							5541,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							666,  667,  668,
							669,  670,  672,
							673,  765,  843,
							1958, 5417, 5538,
							5541,
						}
					},
				},
			},
			[270] = { -- Mistweaver
				talents = {
					{19823, 19820, 20185},
					{19304, 19818, 19302},
					{22168, 22167, 22166},
					{19993, 22219, 19995},
					{23371, 20173, 20175},
					{23107, 22101, 0},
					{22218, 22169, 22170},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							70,  679,  683,
							1928, 3732, 5395,
							5398, 5539, 5565,
							5603, 5642, 5645,
							5669,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							70,  679,  683,
							1928, 3732, 5395,
							5398, 5539, 5565,
							5603, 5642, 5645,
							5669,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							70,  679,  683,
							1928, 3732, 5395,
							5398, 5539, 5565,
							5603, 5642, 5645,
							5669,
						}
					},
				},
			},
			[269] = { -- Windwalker
				talents = {
					{23106, 19820, 20185},
					{19304, 19818, 19302},
					{22098, 19771, 22096},
					{19993, 23364, 19995},
					{23258, 20173, 20175},
					{22093, 23122, 22102},
					{22107, 22105, 21191},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							77,  675, 3052,
							3737, 3744, 3745,
							5448, 5610, 5641,
							5643, 5644,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							77,  675, 3052,
							3737, 3744, 3745,
							5448, 5610, 5641,
							5643, 5644,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							77,  675, 3052,
							3737, 3744, 3745,
							5448, 5610, 5641,
							5643, 5644,
						}
					},
				},
			},
			-- Druid
			[102] = { -- Balance
				talents = {
					{22385, 22386, 22387},
					{19283, 18570, 18571},
					{22163, 22157, 22159},
					{21778, 18576, 18577},
					{18580, 21706, 21702},
					{22389, 21712, 22165},
					{21648, 21193, 21655},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							180,  182,  184,
							185,  822,  834,
							836, 3058, 3728,
							3731, 5383, 5407,
							5515, 5604, 5646,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							180,  182,  184,
							185,  822,  834,
							836, 3058, 3728,
							3731, 5383, 5407,
							5515, 5604, 5646,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							180,  182,  184,
							185,  822,  834,
							836, 3058, 3728,
							3731, 5383, 5407,
							5515, 5604, 5646,
						}
					},
				},
			},
			[103] = { -- Feral
				talents = {
					{22363, 22364, 22365},
					{19283, 18570, 18571},
					{22163, 22158, 22159},
					{21778, 18576, 18577},
					{21708, 18579, 21704},
					{21714, 21711, 22370},
					{21646, 21649, 21653},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							201,  203,  601,
							611,  612,  620,
							820, 3053, 3751,
							5384, 5647,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							201,  203,  601,
							611,  612,  620,
							820, 3053, 3751,
							5384, 5647,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							201,  203,  601,
							611,  612,  620,
							820, 3053, 3751,
							5384, 5647,
						}
					},
				},
			},
			[104] = { -- Guardian
				talents = {
					{22419, 22418, 0},
					{19283, 18570, 18571},
					{22163, 22156, 22159},
					{21778, 18576, 18577},
					{21709, 21707, 22388},
					{22423, 21713, 22390},
					{22426, 22427, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							49,   51,   52,
							194,  195,  196,
							197,  842, 1237,
							3750, 5410, 5648,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							49,   51,   52,
							194,  195,  196,
							197,  842, 1237,
							3750, 5410, 5648,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							49,   51,   52,
							194,  195,  196,
							197,  842, 1237,
							3750, 5410, 5648,
						}
					},
				},
			},
			[105] = { -- Restoration
				talents = {
					{18569, 18574, 18572},
					{19283, 18570, 18571},
					{22366, 22367, 22160},
					{21778, 18576, 18577},
					{21710, 21705, 22421},
					{21716, 18585, 22422},
					{22403, 21651, 22404},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							59,  692,  697,
							700,  838, 1215,
							5514, 5649, 5668,
							5687,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							59,  692,  697,
							700,  838, 1215,
							5514, 5649, 5668,
							5687,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							59,  692,  697,
							700,  838, 1215,
							5514, 5649, 5668,
							5687,
						}
					},
				},
			},
			-- Demon Hunter
			[577] = { -- Havoc
				talents = {
					{21854, 22493, 22416},
					{21857, 22765, 22799},
					{22909, 22494, 21862},
					{21863, 21864, 21865},
					{21866, 21867, 21868},
					{21869, 21870, 22767},
					{21900, 21901, 22547},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							805,  806,  811,
							812,  813, 1206,
							1218, 5433, 5523,
							5691,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							805,  806,  811,
							812,  813, 1206,
							1218, 5433, 5523,
							5691,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							805,  806,  811,
							812,  813, 1206,
							1218, 5433, 5523,
							5691,
						}
					},
				},
			},
			[581] = { -- Vengeance
				talents = {
					{22502, 22503, 22504},
					{22505, 22766, 22507},
					{22324, 22541, 22540},
					{22508, 22509, 22770},
					{22546, 22510, 22511},
					{22512, 22513, 22768},
					{22543, 23464, 21902},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							814,  815,  816,
							819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5520,
							5521, 5522,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							814,  815,  816,
							819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5520,
							5521, 5522,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							814,  815,  816,
							819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5520,
							5521, 5522,
						}
					},
				},
			},
			-- Evoker
			[1467] = { -- Devastation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5556, 5617,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5556, 5617,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5556, 5617,
						}
					},
				},
			},
			[1468] = { -- Preservation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5455, 5459, 5461,
							5463, 5465, 5468,
							5470, 5595, 5616,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5455, 5459, 5461,
							5463, 5465, 5468,
							5470, 5595, 5616,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5455, 5459, 5461,
							5463, 5465, 5468,
							5470, 5595, 5616,
						}
					},
				},
			},
			[1473] = { -- Augmentation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5454, 5557, 5558,
							5560, 5561, 5562,
							5563, 5564, 5612,
							5615, 5619,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5454, 5557, 5558,
							5560, 5561, 5562,
							5563, 5564, 5612,
							5615, 5619,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5454, 5557, 5558,
							5560, 5561, 5562,
							5563, 5564, 5612,
							5615, 5619,
						}
					},
				},
			},
		}
	elseif Internal.Is110002 or Internal.Is110007 then
		specInfo = {
			version = 14,

			-- Warrior
			[71] = { -- Arms
				talents = {
					{22624, 22360, 22371},
					{19676, 22372, 22789},
					{22380, 22489, 19138},
					{15757, 22627, 22628},
					{22392, 22391, 22362},
					{22394, 22397, 22399},
					{21204, 22407, 21667},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							28,   29,   31,
							32,   33,   34,
							3534, 5372, 5376,
							5547, 5625, 5630,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							28,   29,   31,
							32,   33,   34,
							3534, 5372, 5376,
							5547, 5625, 5630,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							28,   29,   31,
							32,   33,   34,
							3534, 5372, 5376,
							5547, 5625, 5630,
						}
					},
				},
			},
			[72] = { -- Fury
				talents = {
					{22632, 22633, 22491},
					{19676, 22625, 23093},
					{22379, 22381, 23372},
					{23097, 22627, 22382},
					{22383, 22393, 19140},
					{22396, 22398, 22400},
					{22405, 22402, 16037},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							166,  170,  177,
							179, 3528, 3533,
							3735, 5373, 5431,
							5548, 5624, 5628,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							166,  170,  177,
							179, 3528, 3533,
							3735, 5373, 5431,
							5548, 5624, 5628,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							166,  170,  177,
							179, 3528, 3533,
							3735, 5373, 5431,
							5548, 5624, 5628,
						}
					},
				},
			},
			[73] = { -- Protection
				talents = {
					{15760, 15759, 15774},
					{19676, 22629, 22409},
					{22378, 22626, 23260},
					{23096, 22627, 22488},
					{22384, 22631, 22800},
					{22395, 22544, 22401},
					{23455, 22406, 23099},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							24,  168,  171,
							173,  175,  178,
							831,  833,  845,
							5374, 5432, 5626,
							5627, 5629,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							24,  168,  171,
							173,  175,  178,
							831,  833,  845,
							5374, 5432, 5626,
							5627, 5629,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							24,  168,  171,
							173,  175,  178,
							831,  833,  845,
							5374, 5432, 5626,
							5627, 5629,
						}
					},
				},
			},
			-- Paladin
			[65] = { -- Holy
				talents = {
					{17565, 17567, 17569},
					{22176, 17575, 17577},
					{22179, 22180, 21811},
					{22433, 22434, 17593},
					{17597, 17599, 17601},
					{23191, 23680, 22484},
					{21201, 21671, 23681},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							85,   86,   87,
							88,  640,  642,
							3618, 5583, 5618,
							5651, 5657,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							85,   86,   87,
							88,  640,  642,
							3618, 5583, 5618,
							5651, 5657,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							85,   86,   87,
							88,  640,  642,
							3618, 5583, 5618,
							5651, 5657,
						}
					},
				},
			},
			[66] = { -- Protection
				talents = {
					{22428, 22558, 23469},
					{22431, 22604, 23468},
					{22179, 22180, 21811},
					{22433, 22434, 22435},
					{17597, 17599, 17601},
					{22189, 22438, 23087},
					{23457, 21202, 22645},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							90,   91,   92,
							94,   97,  844,
							860,  861, 3474,
							5554, 5582, 5652,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							90,   91,   92,
							94,   97,  844,
							860,  861, 3474,
							5554, 5582, 5652,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							90,   91,   92,
							94,   97,  844,
							860,  861, 3474,
							5554, 5582, 5652,
						}
					},
				},
			},
			[70] = { -- Retribution
				talents = {
					{22590, 22557, 23467},
					{22319, 22592, 23466},
					{22179, 22180, 21811},
					{22433, 22434, 22183},
					{17597, 17599, 17601},
					{23167, 22483, 23086},
					{23456, 22215, 22634},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							81,  752,  753,
							754,  756, 5535,
							5572, 5573, 5584,
							5653,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							81,  752,  753,
							754,  756, 5535,
							5572, 5573, 5584,
							5653,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							81,  752,  753,
							754,  756, 5535,
							5572, 5573, 5584,
							5653,
						}
					},
				},
			},
			-- Hunter
			[253] = { -- Beast Mastery
				talents = {
					{22291, 22280, 22282},
					{22500, 22266, 22290},
					{19347, 19348, 23100},
					{22441, 22347, 22269},
					{22268, 22276, 22499},
					{19357, 22002, 23044},
					{22273, 21986, 22295},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							693,  824,  825,
							1214, 3599, 3604,
							3730, 5441, 5444,
							5534,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							693,  824,  825,
							1214, 3599, 3604,
							3730, 5441, 5444,
							5534,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							693,  824,  825,
							1214, 3599, 3604,
							3730, 5441, 5444,
							5534,
						}
					},
				},
			},
			[254] = { -- Marksmanship
				talents = {
					{22279, 22501, 22289},
					{22495, 22497, 22498},
					{19347, 19348, 23100},
					{22267, 22286, 21998},
					{22268, 22276, 23463},
					{23063, 23104, 22287},
					{22274, 22308, 22288},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							651,  653,  658,
							659,  660, 3729,
							5440, 5442, 5531,
							5533,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							651,  653,  658,
							659,  660, 3729,
							5440, 5442, 5531,
							5533,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							651,  653,  658,
							659,  660, 3729,
							5440, 5442, 5531,
							5533,
						}
					},
				},
			},
			[255] = { -- Survival
				talents = {
					{22275, 22283, 22296},
					{21997, 22769, 22297},
					{19347, 19348, 23100},
					{22277, 19361, 22299},
					{22268, 22276, 22499},
					{22300, 22278, 22271},
					{22272, 22301, 23105},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							661,  662,  664,
							665,  686, 3607,
							3609, 5443, 5532,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							661,  662,  664,
							665,  686, 3607,
							3609, 5443, 5532,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							661,  662,  664,
							665,  686, 3607,
							3609, 5443, 5532,
						}
					},
				},
			},
			-- Rogue
			[259] = { -- Assassination
				talents = {
					{22337, 22338, 22339},
					{22331, 22332, 23022},
					{19239, 19240, 19241},
					{22340, 22122, 22123},
					{19245, 23037, 22115},
					{22343, 23015, 22344},
					{21186, 22133, 23174},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
				},
			},
			[260] = { -- Outlaw
				talents = {
					{22118, 22119, 22120},
					{23470, 19237, 19238},
					{19239, 19240, 19241},
					{22121, 22122, 22123},
					{23077, 22114, 22115},
					{21990, 23128, 19250},
					{22125, 23075, 23175},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							129,  135,  138,
							139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							129,  135,  138,
							139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							129,  135,  138,
							139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
				},
			},
			[261] = { -- Subtlety
				talents = {
					{19233, 19234, 19235},
					{22331, 22332, 22333},
					{19239, 19240, 19241},
					{22128, 22122, 22123},
					{23078, 23036, 22115},
					{22335, 19249, 22336},
					{22132, 23183, 21188},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							136,  146,  153,
							846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							136,  146,  153,
							846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							136,  146,  153,
							846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
				},
			},
			-- Priest
			[256] = { -- Discipline
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							100,  109,  111,
							114,  123,  126,
							855, 5416, 5480,
							5487, 5570, 5635,
							5640,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							100,  109,  111,
							114,  123,  126,
							855, 5416, 5480,
							5487, 5570, 5635,
							5640,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							100,  109,  111,
							114,  123,  126,
							855, 5416, 5480,
							5487, 5570, 5635,
							5640,
						}
					},
				},
			},
			[257] = { -- Holy
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							101,  108,  112,
							124,  127, 1927,
							5365, 5366, 5479,
							5485, 5569, 5620,
							5634, 5639,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							101,  108,  112,
							124,  127, 1927,
							5365, 5366, 5479,
							5485, 5569, 5620,
							5634, 5639,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							101,  108,  112,
							124,  127, 1927,
							5365, 5366, 5479,
							5485, 5569, 5620,
							5634, 5639,
						}
					},
				},
			},
			[258] = { -- Shadow
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							106,  113,  763,
							5381, 5447, 5481,
							5486, 5568, 5636,
							5638,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							106,  113,  763,
							5381, 5447, 5481,
							5486, 5568, 5636,
							5638,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							106,  113,  763,
							5381, 5447, 5481,
							5486, 5568, 5636,
							5638,
						}
					},
				},
			},
			-- Death Knight
			[250] = { -- Blood
				talents = {
					{19165, 19166, 23454},
					{19218, 19219, 19220},
					{19221, 22134, 22135},
					{22013, 22014, 22015},
					{19227, 19226, 19228},
					{19230, 19231, 19232},
					{21207, 21208, 21209},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							204,  205,  206,
							608,  609,  841,
							3441, 3511, 5587,
							5592,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							204,  205,  206,
							608,  609,  841,
							3441, 3511, 5587,
							5592,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							204,  205,  206,
							608,  609,  841,
							3441, 3511, 5587,
							5592,
						}
					},
				},
			},
			[251] = { -- Frost
				talents = {
					{22016, 22017, 22018},
					{22019, 22020, 22021},
					{22515, 22517, 22519},
					{22521, 22523, 22525},
					{22527, 22530, 23373},
					{22531, 22533, 22535},
					{22023, 22109, 22537},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							701,  702, 3439,
							3512, 3743, 5429,
							5435, 5510, 5586,
							5591,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							701,  702, 3439,
							3512, 3743, 5429,
							5435, 5510, 5586,
							5591,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							701,  702, 3439,
							3512, 3743, 5429,
							5435, 5510, 5586,
							5591,
						}
					},
				},
			},
			[252] = { -- Unholy
				talents = {
					{22024, 22025, 22026},
					{22027, 22028, 22029},
					{22516, 22518, 22520},
					{22522, 22524, 22526},
					{22528, 22529, 23373},
					{22532, 22534, 22536},
					{22030, 22110, 22538},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							40,   41,  149,
							152, 3746, 5430,
							5436, 5511, 5585,
							5590,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							40,   41,  149,
							152, 3746, 5430,
							5436, 5511, 5585,
							5590,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							40,   41,  149,
							152, 3746, 5430,
							5436, 5511, 5585,
							5590,
						}
					},
				},
			},
			-- Shaman
			[262] = { -- Elemental
				talents = {
					{22356, 22357, 22358},
					{23108, 23460, 23190},
					{23162, 23163, 23164},
					{19271, 19272, 19273},
					{22144, 22172, 21966},
					{22145, 19266, 23111},
					{21198, 22153, 21675},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							727, 3488, 3490,
							3491, 3620, 5571,
							5574, 5659, 5660,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							727, 3488, 3490,
							3491, 3620, 5571,
							5574, 5659, 5660,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							727, 3488, 3490,
							3491, 3620, 5571,
							5574, 5659, 5660,
						}
					},
				},
			},
			[263] = { -- Enhancement
				talents = {
					{22354, 22355, 22353},
					{22636, 23462, 23109},
					{23165, 19260, 23166},
					{23089, 23090, 22171},
					{22144, 22149, 21966},
					{21973, 22352, 22351},
					{21970, 22977, 21972},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							721,  722, 3487,
							3489, 3492, 3622,
							5438, 5575, 5596,
							5658,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							721,  722, 3487,
							3489, 3492, 3622,
							5438, 5575, 5596,
							5658,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							721,  722, 3487,
							3489, 3492, 3622,
							5438, 5575, 5596,
							5658,
						}
					},
				},
			},
			[264] = { -- Restoration
				talents = {
					{19262, 19263, 19264},
					{19259, 23461, 21963},
					{19275, 23110, 22127},
					{22152, 22322, 22323},
					{22144, 19269, 21966},
					{19265, 21971, 21968},
					{21969, 21199, 22359},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							707,  708,  714,
							715, 3755, 5388,
							5437, 5567, 5576,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							707,  708,  714,
							715, 3755, 5388,
							5437, 5567, 5576,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							707,  708,  714,
							715, 3755, 5388,
							5437, 5567, 5576,
						}
					},
				},
			},
			-- Mage
			[62] = { -- Arcane
				talents = {
					{22458, 22461, 22464},
					{23072, 22443, 16025},
					{22444, 22445, 22447},
					{22453, 22467, 22470},
					{22907, 22448, 22471},
					{22455, 22449, 22474},
					{21630, 21144, 21145},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							635,  637, 3517,
							3529, 5397, 5488,
							5491, 5589, 5601,
							5661,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							635,  637, 3517,
							3529, 5397, 5488,
							5491, 5589, 5601,
							5661,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							635,  637, 3517,
							3529, 5397, 5488,
							5491, 5589, 5601,
							5661,
						}
					},
				},
			},
			[63] = { -- Fire
				talents = {
					{22456, 22459, 22462},
					{23071, 22443, 23074},
					{22444, 22445, 22447},
					{22450, 22465, 22468},
					{22904, 22448, 22471},
					{22451, 23362, 22472},
					{21631, 22220, 21633},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							644,  648, 5389,
							5489, 5495, 5588,
							5602, 5621, 5656,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							644,  648, 5389,
							5489, 5495, 5588,
							5602, 5621, 5656,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							644,  648, 5389,
							5489, 5495, 5588,
							5602, 5621, 5656,
						}
					},
				},
			},
			[64] = { -- Frost
				talents = {
					{22457, 22460, 22463},
					{22442, 22443, 23073},
					{22444, 22445, 22447},
					{22452, 22466, 22469},
					{22446, 22448, 22471},
					{22454, 23176, 22473},
					{21632, 22309, 21634},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							66,  632,  634,
							5390, 5490, 5496,
							5497, 5581, 5600,
							5622,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							66,  632,  634,
							5390, 5490, 5496,
							5497, 5581, 5600,
							5622,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							66,  632,  634,
							5390, 5490, 5496,
							5497, 5581, 5600,
							5622,
						}
					},
				},
			},
			-- Warlock
			[265] = { -- Affliction
				talents = {
					{22039, 23140, 23141},
					{22044, 21180, 22089},
					{19280, 19285, 19286},
					{19279, 19292, 22046},
					{22047, 19291, 23465},
					{23139, 23159, 19295},
					{19284, 19281, 19293},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							15,   16,   18,
							19, 5379, 5386,
							5392, 5543, 5546,
							5579, 5608, 5662,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							15,   16,   18,
							19, 5379, 5386,
							5392, 5543, 5546,
							5579, 5608, 5662,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							15,   16,   18,
							19, 5379, 5386,
							5392, 5543, 5546,
							5579, 5608, 5662,
						}
					},
				},
			},
			[266] = { -- Demonology
				talents = {
					{19290, 22048, 23138},
					{22045, 21694, 23158},
					{19280, 19285, 19286},
					{22477, 22042, 23160},
					{22047, 19291, 23465},
					{23147, 23146, 21717},
					{23161, 22479, 23091},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							162,  165, 1213,
							3506, 3624, 5394,
							5545, 5577, 5606,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							162,  165, 1213,
							3506, 3624, 5394,
							5545, 5577, 5606,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							162,  165, 1213,
							3506, 3624, 5394,
							5545, 5577, 5606,
						}
					},
				},
			},
			[267] = { -- Destruction
				talents = {
					{22038, 22090, 22040},
					{23148, 21695, 23157},
					{19280, 19285, 19286},
					{22480, 22043, 23143},
					{22047, 19291, 23465},
					{23155, 23156, 19295},
					{19284, 23144, 23092},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							157,  164, 3508,
							5382, 5393, 5401,
							5544, 5580, 5607,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							157,  164, 3508,
							5382, 5393, 5401,
							5544, 5580, 5607,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							157,  164, 3508,
							5382, 5393, 5401,
							5544, 5580, 5607,
						}
					},
				},
			},
			-- Monk
			[268] = { -- Brewmaster
				talents = {
					{23106, 19820, 20185},
					{19304, 19818, 19302},
					{22099, 22097, 19992},
					{19993, 19994, 19995},
					{20174, 23363, 20175},
					{19819, 20184, 22103},
					{22106, 22104, 22108},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							666,  667,  668,
							669,  670,  672,
							673,  765,  843,
							1958, 5417, 5538,
							5541, 5552,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							666,  667,  668,
							669,  670,  672,
							673,  765,  843,
							1958, 5417, 5538,
							5541, 5552,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							666,  667,  668,
							669,  670,  672,
							673,  765,  843,
							1958, 5417, 5538,
							5541, 5552,
						}
					},
				},
			},
			[270] = { -- Mistweaver
				talents = {
					{19823, 19820, 20185},
					{19304, 19818, 19302},
					{22168, 22167, 22166},
					{19993, 22219, 19995},
					{23371, 20173, 20175},
					{23107, 22101, 0},
					{22218, 22169, 22170},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							70,  679,  680,
							683, 1928, 3732,
							5395, 5398, 5402,
							5539, 5551, 5565,
							5603, 5642, 5645,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							70,  679,  680,
							683, 1928, 3732,
							5395, 5398, 5402,
							5539, 5551, 5565,
							5603, 5642, 5645,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							70,  679,  680,
							683, 1928, 3732,
							5395, 5398, 5402,
							5539, 5551, 5565,
							5603, 5642, 5645,
						}
					},
				},
			},
			[269] = { -- Windwalker
				talents = {
					{23106, 19820, 20185},
					{19304, 19818, 19302},
					{22098, 19771, 22096},
					{19993, 23364, 19995},
					{23258, 20173, 20175},
					{22093, 23122, 22102},
					{22107, 22105, 21191},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							77,  675,  852,
							3052, 3737, 3744,
							3745, 5448, 5610,
							5641, 5643, 5644,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							77,  675,  852,
							3052, 3737, 3744,
							3745, 5448, 5610,
							5641, 5643, 5644,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							77,  675,  852,
							3052, 3737, 3744,
							3745, 5448, 5610,
							5641, 5643, 5644,
						}
					},
				},
			},
			-- Druid
			[102] = { -- Balance
				talents = {
					{22385, 22386, 22387},
					{19283, 18570, 18571},
					{22163, 22157, 22159},
					{21778, 18576, 18577},
					{18580, 21706, 21702},
					{22389, 21712, 22165},
					{21648, 21193, 21655},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							180,  182,  184,
							185,  822,  834,
							836, 3058, 3728,
							3731, 5383, 5407,
							5515, 5604, 5646,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							180,  182,  184,
							185,  822,  834,
							836, 3058, 3728,
							3731, 5383, 5407,
							5515, 5604, 5646,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							180,  182,  184,
							185,  822,  834,
							836, 3058, 3728,
							3731, 5383, 5407,
							5515, 5604, 5646,
						}
					},
				},
			},
			[103] = { -- Feral
				talents = {
					{22363, 22364, 22365},
					{19283, 18570, 18571},
					{22163, 22158, 22159},
					{21778, 18576, 18577},
					{21708, 18579, 21704},
					{21714, 21711, 22370},
					{21646, 21649, 21653},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							201,  203,  601,
							602,  611,  612,
							620,  820, 3053,
							3751, 5384, 5647,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							201,  203,  601,
							602,  611,  612,
							620,  820, 3053,
							3751, 5384, 5647,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							201,  203,  601,
							602,  611,  612,
							620,  820, 3053,
							3751, 5384, 5647,
						}
					},
				},
			},
			[104] = { -- Guardian
				talents = {
					{22419, 22418, 0},
					{19283, 18570, 18571},
					{22163, 22156, 22159},
					{21778, 18576, 18577},
					{21709, 21707, 22388},
					{22423, 21713, 22390},
					{22426, 22427, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							49,   51,   52,
							194,  195,  196,
							197,  842, 1237,
							3750, 5410, 5648,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							49,   51,   52,
							194,  195,  196,
							197,  842, 1237,
							3750, 5410, 5648,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							49,   51,   52,
							194,  195,  196,
							197,  842, 1237,
							3750, 5410, 5648,
						}
					},
				},
			},
			[105] = { -- Restoration
				talents = {
					{18569, 18574, 18572},
					{19283, 18570, 18571},
					{22366, 22367, 22160},
					{21778, 18576, 18577},
					{21710, 21705, 22421},
					{21716, 18585, 22422},
					{22403, 21651, 22404},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							59,  691,  692,
							697,  700,  835,
							838, 1215, 5387,
							5514, 5649,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							59,  691,  692,
							697,  700,  835,
							838, 1215, 5387,
							5514, 5649,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							59,  691,  692,
							697,  700,  835,
							838, 1215, 5387,
							5514, 5649,
						}
					},
				},
			},
			-- Demon Hunter
			[577] = { -- Havoc
				talents = {
					{21854, 22493, 22416},
					{21857, 22765, 22799},
					{22909, 22494, 21862},
					{21863, 21864, 21865},
					{21866, 21867, 21868},
					{21869, 21870, 22767},
					{21900, 21901, 22547},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							805,  806,  811,
							812,  813, 1206,
							1218, 5433, 5523,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							805,  806,  811,
							812,  813, 1206,
							1218, 5433, 5523,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							805,  806,  811,
							812,  813, 1206,
							1218, 5433, 5523,
						}
					},
				},
			},
			[581] = { -- Vengeance
				talents = {
					{22502, 22503, 22504},
					{22505, 22766, 22507},
					{22324, 22541, 22540},
					{22508, 22509, 22770},
					{22546, 22510, 22511},
					{22512, 22513, 22768},
					{22543, 23464, 21902},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							814,  815,  816,
							819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5520,
							5521, 5522,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							814,  815,  816,
							819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5520,
							5521, 5522,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							814,  815,  816,
							819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5520,
							5521, 5522,
						}
					},
				},
			},
			-- Evoker
			[1467] = { -- Devastation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5556,
							5599, 5617,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5556,
							5599, 5617,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5556,
							5599, 5617,
						}
					},
				},
			},
			[1468] = { -- Preservation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5595,
							5598, 5616,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5595,
							5598, 5616,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5595,
							5598, 5616,
						}
					},
				},
			},
			[1473] = { -- Augmentation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5557, 5558, 5559,
							5560, 5561, 5562,
							5563, 5564, 5612,
							5613, 5615, 5619,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5557, 5558, 5559,
							5560, 5561, 5562,
							5563, 5564, 5612,
							5613, 5615, 5619,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5557, 5558, 5559,
							5560, 5561, 5562,
							5563, 5564, 5612,
							5613, 5615, 5619,
						}
					},
				},
			},
		}
	elseif Internal.Is110000 then
		specInfo = {
			version = 13,

			-- Warrior
			[71] = { -- Arms
				talents = {
					{22624, 22360, 22371},
					{19676, 22372, 22789},
					{22380, 22489, 19138},
					{15757, 22627, 22628},
					{22392, 22391, 22362},
					{22394, 22397, 22399},
					{21204, 22407, 21667},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							28,   29,   31,
							32,   33,   34,
							3534, 5372, 5376,
							5547, 5625, 5630,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							28,   29,   31,
							32,   33,   34,
							3534, 5372, 5376,
							5547, 5625, 5630,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							28,   29,   31,
							32,   33,   34,
							3534, 5372, 5376,
							5547, 5625, 5630,
						}
					},
				},
			},
			[72] = { -- Fury
				talents = {
					{22632, 22633, 22491},
					{19676, 22625, 23093},
					{22379, 22381, 23372},
					{23097, 22627, 22382},
					{22383, 22393, 19140},
					{22396, 22398, 22400},
					{22405, 22402, 16037},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							166,  170,  177,
							179, 3528, 3533,
							3735, 5373, 5431,
							5548, 5624, 5628,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							166,  170,  177,
							179, 3528, 3533,
							3735, 5373, 5431,
							5548, 5624, 5628,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							166,  170,  177,
							179, 3528, 3533,
							3735, 5373, 5431,
							5548, 5624, 5628,
						}
					},
				},
			},
			[73] = { -- Protection
				talents = {
					{15760, 15759, 15774},
					{19676, 22629, 22409},
					{22378, 22626, 23260},
					{23096, 22627, 22488},
					{22384, 22631, 22800},
					{22395, 22544, 22401},
					{23455, 22406, 23099},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							24,  168,  171,
							173,  175,  178,
							831,  833,  845,
							5374, 5432, 5626,
							5627, 5629,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							24,  168,  171,
							173,  175,  178,
							831,  833,  845,
							5374, 5432, 5626,
							5627, 5629,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							24,  168,  171,
							173,  175,  178,
							831,  833,  845,
							5374, 5432, 5626,
							5627, 5629,
						}
					},
				},
			},
			-- Paladin
			[65] = { -- Holy
				talents = {
					{17565, 17567, 17569},
					{22176, 17575, 17577},
					{22179, 22180, 21811},
					{22433, 22434, 17593},
					{17597, 17599, 17601},
					{23191, 23680, 22484},
					{21201, 21671, 23681},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							85,   86,   87,
							88,  640,  642,
							3618, 5583, 5618,
							5651, 5657,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							85,   86,   87,
							88,  640,  642,
							3618, 5583, 5618,
							5651, 5657,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							85,   86,   87,
							88,  640,  642,
							3618, 5583, 5618,
							5651, 5657,
						}
					},
				},
			},
			[66] = { -- Protection
				talents = {
					{22428, 22558, 23469},
					{22431, 22604, 23468},
					{22179, 22180, 21811},
					{22433, 22434, 22435},
					{17597, 17599, 17601},
					{22189, 22438, 23087},
					{23457, 21202, 22645},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							90,   91,   92,
							94,   97,  844,
							860,  861, 3474,
							5554, 5582, 5652,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							90,   91,   92,
							94,   97,  844,
							860,  861, 3474,
							5554, 5582, 5652,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							90,   91,   92,
							94,   97,  844,
							860,  861, 3474,
							5554, 5582, 5652,
						}
					},
				},
			},
			[70] = { -- Retribution
				talents = {
					{22590, 22557, 23467},
					{22319, 22592, 23466},
					{22179, 22180, 21811},
					{22433, 22434, 22183},
					{17597, 17599, 17601},
					{23167, 22483, 23086},
					{23456, 22215, 22634},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							81,  752,  753,
							754,  756, 5535,
							5572, 5573, 5584,
							5653,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							81,  752,  753,
							754,  756, 5535,
							5572, 5573, 5584,
							5653,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							81,  752,  753,
							754,  756, 5535,
							5572, 5573, 5584,
							5653,
						}
					},
				},
			},
			-- Hunter
			[253] = { -- Beast Mastery
				talents = {
					{22291, 22280, 22282},
					{22500, 22266, 22290},
					{19347, 19348, 23100},
					{22441, 22347, 22269},
					{22268, 22276, 22499},
					{19357, 22002, 23044},
					{22273, 21986, 22295},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							693,  824,  825,
							1214, 3599, 3604,
							3730, 5441, 5444,
							5534,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							693,  824,  825,
							1214, 3599, 3604,
							3730, 5441, 5444,
							5534,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							693,  824,  825,
							1214, 3599, 3604,
							3730, 5441, 5444,
							5534,
						}
					},
				},
			},
			[254] = { -- Marksmanship
				talents = {
					{22279, 22501, 22289},
					{22495, 22497, 22498},
					{19347, 19348, 23100},
					{22267, 22286, 21998},
					{22268, 22276, 23463},
					{23063, 23104, 22287},
					{22274, 22308, 22288},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							651,  653,  658,
							659,  660, 3729,
							5440, 5442, 5531,
							5533,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							651,  653,  658,
							659,  660, 3729,
							5440, 5442, 5531,
							5533,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							651,  653,  658,
							659,  660, 3729,
							5440, 5442, 5531,
							5533,
						}
					},
				},
			},
			[255] = { -- Survival
				talents = {
					{22275, 22283, 22296},
					{21997, 22769, 22297},
					{19347, 19348, 23100},
					{22277, 19361, 22299},
					{22268, 22276, 22499},
					{22300, 22278, 22271},
					{22272, 22301, 23105},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							661,  662,  664,
							665,  686, 3607,
							3609, 5443, 5532,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							661,  662,  664,
							665,  686, 3607,
							3609, 5443, 5532,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							661,  662,  664,
							665,  686, 3607,
							3609, 5443, 5532,
						}
					},
				},
			},
			-- Rogue
			[259] = { -- Assassination
				talents = {
					{22337, 22338, 22339},
					{22331, 22332, 23022},
					{19239, 19240, 19241},
					{22340, 22122, 22123},
					{19245, 23037, 22115},
					{22343, 23015, 22344},
					{21186, 22133, 23174},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
				},
			},
			[260] = { -- Outlaw
				talents = {
					{22118, 22119, 22120},
					{23470, 19237, 19238},
					{19239, 19240, 19241},
					{22121, 22122, 22123},
					{23077, 22114, 22115},
					{21990, 23128, 19250},
					{22125, 23075, 23175},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							129,  135,  138,
							139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							129,  135,  138,
							139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							129,  135,  138,
							139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
				},
			},
			[261] = { -- Subtlety
				talents = {
					{19233, 19234, 19235},
					{22331, 22332, 22333},
					{19239, 19240, 19241},
					{22128, 22122, 22123},
					{23078, 23036, 22115},
					{22335, 19249, 22336},
					{22132, 23183, 21188},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							136,  146,  153,
							846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							136,  146,  153,
							846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							136,  146,  153,
							846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
				},
			},
			-- Priest
			[256] = { -- Discipline
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							100,  109,  111,
							114,  123,  126,
							855, 5416, 5480,
							5487, 5570, 5635,
							5640,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							100,  109,  111,
							114,  123,  126,
							855, 5416, 5480,
							5487, 5570, 5635,
							5640,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							100,  109,  111,
							114,  123,  126,
							855, 5416, 5480,
							5487, 5570, 5635,
							5640,
						}
					},
				},
			},
			[257] = { -- Holy
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							101,  108,  112,
							124,  127, 1927,
							5365, 5366, 5479,
							5485, 5569, 5620,
							5634, 5639,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							101,  108,  112,
							124,  127, 1927,
							5365, 5366, 5479,
							5485, 5569, 5620,
							5634, 5639,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							101,  108,  112,
							124,  127, 1927,
							5365, 5366, 5479,
							5485, 5569, 5620,
							5634, 5639,
						}
					},
				},
			},
			[258] = { -- Shadow
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							106,  113,  763,
							5381, 5447, 5481,
							5486, 5568, 5636,
							5638,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							106,  113,  763,
							5381, 5447, 5481,
							5486, 5568, 5636,
							5638,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							106,  113,  763,
							5381, 5447, 5481,
							5486, 5568, 5636,
							5638,
						}
					},
				},
			},
			-- Death Knight
			[250] = { -- Blood
				talents = {
					{19165, 19166, 23454},
					{19218, 19219, 19220},
					{19221, 22134, 22135},
					{22013, 22014, 22015},
					{19227, 19226, 19228},
					{19230, 19231, 19232},
					{21207, 21208, 21209},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							204,  205,  206,
							608,  609,  841,
							3441, 3511, 5513,
							5587, 5592,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							204,  205,  206,
							608,  609,  841,
							3441, 3511, 5513,
							5587, 5592,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							204,  205,  206,
							608,  609,  841,
							3441, 3511, 5513,
							5587, 5592,
						}
					},
				},
			},
			[251] = { -- Frost
				talents = {
					{22016, 22017, 22018},
					{22019, 22020, 22021},
					{22515, 22517, 22519},
					{22521, 22523, 22525},
					{22527, 22530, 23373},
					{22531, 22533, 22535},
					{22023, 22109, 22537},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							701,  702, 3439,
							3512, 3743, 5429,
							5435, 5510, 5512,
							5586, 5591,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							701,  702, 3439,
							3512, 3743, 5429,
							5435, 5510, 5512,
							5586, 5591,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							701,  702, 3439,
							3512, 3743, 5429,
							5435, 5510, 5512,
							5586, 5591,
						}
					},
				},
			},
			[252] = { -- Unholy
				talents = {
					{22024, 22025, 22026},
					{22027, 22028, 22029},
					{22516, 22518, 22520},
					{22522, 22524, 22526},
					{22528, 22529, 23373},
					{22532, 22534, 22536},
					{22030, 22110, 22538},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							40,   41,  149,
							152, 3437, 3746,
							5430, 5436, 5511,
							5585, 5590,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							40,   41,  149,
							152, 3437, 3746,
							5430, 5436, 5511,
							5585, 5590,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							40,   41,  149,
							152, 3437, 3746,
							5430, 5436, 5511,
							5585, 5590,
						}
					},
				},
			},
			-- Shaman
			[262] = { -- Elemental
				talents = {
					{22356, 22357, 22358},
					{23108, 23460, 23190},
					{23162, 23163, 23164},
					{19271, 19272, 19273},
					{22144, 22172, 21966},
					{22145, 19266, 23111},
					{21198, 22153, 21675},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							727, 3488, 3490,
							3491, 3620, 5571,
							5574, 5659, 5660,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							727, 3488, 3490,
							3491, 3620, 5571,
							5574, 5659, 5660,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							727, 3488, 3490,
							3491, 3620, 5571,
							5574, 5659, 5660,
						}
					},
				},
			},
			[263] = { -- Enhancement
				talents = {
					{22354, 22355, 22353},
					{22636, 23462, 23109},
					{23165, 19260, 23166},
					{23089, 23090, 22171},
					{22144, 22149, 21966},
					{21973, 22352, 22351},
					{21970, 22977, 21972},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							721,  722, 3487,
							3489, 3492, 3622,
							5438, 5575, 5596,
							5658,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							721,  722, 3487,
							3489, 3492, 3622,
							5438, 5575, 5596,
							5658,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							721,  722, 3487,
							3489, 3492, 3622,
							5438, 5575, 5596,
							5658,
						}
					},
				},
			},
			[264] = { -- Restoration
				talents = {
					{19262, 19263, 19264},
					{19259, 23461, 21963},
					{19275, 23110, 22127},
					{22152, 22322, 22323},
					{22144, 19269, 21966},
					{19265, 21971, 21968},
					{21969, 21199, 22359},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							707,  708,  714,
							715, 3755, 5388,
							5437, 5567, 5576,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							707,  708,  714,
							715, 3755, 5388,
							5437, 5567, 5576,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							707,  708,  714,
							715, 3755, 5388,
							5437, 5567, 5576,
						}
					},
				},
			},
			-- Mage
			[62] = { -- Arcane
				talents = {
					{22458, 22461, 22464},
					{23072, 22443, 16025},
					{22444, 22445, 22447},
					{22453, 22467, 22470},
					{22907, 22448, 22471},
					{22455, 22449, 22474},
					{21630, 21144, 21145},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							635,  637, 3517,
							3529, 5397, 5488,
							5491, 5589, 5601,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							635,  637, 3517,
							3529, 5397, 5488,
							5491, 5589, 5601,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							635,  637, 3517,
							3529, 5397, 5488,
							5491, 5589, 5601,
						}
					},
				},
			},
			[63] = { -- Fire
				talents = {
					{22456, 22459, 22462},
					{23071, 22443, 23074},
					{22444, 22445, 22447},
					{22450, 22465, 22468},
					{22904, 22448, 22471},
					{22451, 23362, 22472},
					{21631, 22220, 21633},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							644,  648, 5389,
							5489, 5495, 5588,
							5602, 5621, 5656,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							644,  648, 5389,
							5489, 5495, 5588,
							5602, 5621, 5656,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							644,  648, 5389,
							5489, 5495, 5588,
							5602, 5621, 5656,
						}
					},
				},
			},
			[64] = { -- Frost
				talents = {
					{22457, 22460, 22463},
					{22442, 22443, 23073},
					{22444, 22445, 22447},
					{22452, 22466, 22469},
					{22446, 22448, 22471},
					{22454, 23176, 22473},
					{21632, 22309, 21634},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							66,  632,  634,
							5390, 5490, 5496,
							5497, 5581, 5600,
							5622,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							66,  632,  634,
							5390, 5490, 5496,
							5497, 5581, 5600,
							5622,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							66,  632,  634,
							5390, 5490, 5496,
							5497, 5581, 5600,
							5622,
						}
					},
				},
			},
			-- Warlock
			[265] = { -- Affliction
				talents = {
					{22039, 23140, 23141},
					{22044, 21180, 22089},
					{19280, 19285, 19286},
					{19279, 19292, 22046},
					{22047, 19291, 23465},
					{23139, 23159, 19295},
					{19284, 19281, 19293},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							15,   16,   18,
							19, 5379, 5386,
							5392, 5543, 5546,
							5579, 5608,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							15,   16,   18,
							19, 5379, 5386,
							5392, 5543, 5546,
							5579, 5608,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							15,   16,   18,
							19, 5379, 5386,
							5392, 5543, 5546,
							5579, 5608,
						}
					},
				},
			},
			[266] = { -- Demonology
				talents = {
					{19290, 22048, 23138},
					{22045, 21694, 23158},
					{19280, 19285, 19286},
					{22477, 22042, 23160},
					{22047, 19291, 23465},
					{23147, 23146, 21717},
					{23161, 22479, 23091},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							162,  165, 1213,
							3506, 3624, 5394,
							5545, 5577, 5606,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							162,  165, 1213,
							3506, 3624, 5394,
							5545, 5577, 5606,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							162,  165, 1213,
							3506, 3624, 5394,
							5545, 5577, 5606,
						}
					},
				},
			},
			[267] = { -- Destruction
				talents = {
					{22038, 22090, 22040},
					{23148, 21695, 23157},
					{19280, 19285, 19286},
					{22480, 22043, 23143},
					{22047, 19291, 23465},
					{23155, 23156, 19295},
					{19284, 23144, 23092},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							157,  164, 3508,
							5382, 5393, 5401,
							5544, 5580, 5607,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							157,  164, 3508,
							5382, 5393, 5401,
							5544, 5580, 5607,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							157,  164, 3508,
							5382, 5393, 5401,
							5544, 5580, 5607,
						}
					},
				},
			},
			-- Monk
			[268] = { -- Brewmaster
				talents = {
					{23106, 19820, 20185},
					{19304, 19818, 19302},
					{22099, 22097, 19992},
					{19993, 19994, 19995},
					{20174, 23363, 20175},
					{19819, 20184, 22103},
					{22106, 22104, 22108},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							666,  667,  668,
							669,  670,  672,
							673,  765,  843,
							1958, 5417, 5538,
							5541, 5552,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							666,  667,  668,
							669,  670,  672,
							673,  765,  843,
							1958, 5417, 5538,
							5541, 5552,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							666,  667,  668,
							669,  670,  672,
							673,  765,  843,
							1958, 5417, 5538,
							5541, 5552,
						}
					},
				},
			},
			[270] = { -- Mistweaver
				talents = {
					{19823, 19820, 20185},
					{19304, 19818, 19302},
					{22168, 22167, 22166},
					{19993, 22219, 19995},
					{23371, 20173, 20175},
					{23107, 22101, 0},
					{22218, 22169, 22170},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							70,  679,  680,
							683, 1928, 3732,
							5395, 5398, 5402,
							5539, 5551, 5565,
							5603, 5642, 5645,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							70,  679,  680,
							683, 1928, 3732,
							5395, 5398, 5402,
							5539, 5551, 5565,
							5603, 5642, 5645,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							70,  679,  680,
							683, 1928, 3732,
							5395, 5398, 5402,
							5539, 5551, 5565,
							5603, 5642, 5645,
						}
					},
				},
			},
			[269] = { -- Windwalker
				talents = {
					{23106, 19820, 20185},
					{19304, 19818, 19302},
					{22098, 19771, 22096},
					{19993, 23364, 19995},
					{23258, 20173, 20175},
					{22093, 23122, 22102},
					{22107, 22105, 21191},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							77,  675,  852,
							3052, 3737, 3744,
							3745, 5448, 5610,
							5641, 5643, 5644,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							77,  675,  852,
							3052, 3737, 3744,
							3745, 5448, 5610,
							5641, 5643, 5644,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							77,  675,  852,
							3052, 3737, 3744,
							3745, 5448, 5610,
							5641, 5643, 5644,
						}
					},
				},
			},
			-- Druid
			[102] = { -- Balance
				talents = {
					{22385, 22386, 22387},
					{19283, 18570, 18571},
					{22163, 22157, 22159},
					{21778, 18576, 18577},
					{18580, 21706, 21702},
					{22389, 21712, 22165},
					{21648, 21193, 21655},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							180,  182,  184,
							185,  822,  834,
							836, 3058, 3728,
							3731, 5383, 5407,
							5515, 5604, 5646,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							180,  182,  184,
							185,  822,  834,
							836, 3058, 3728,
							3731, 5383, 5407,
							5515, 5604, 5646,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							180,  182,  184,
							185,  822,  834,
							836, 3058, 3728,
							3731, 5383, 5407,
							5515, 5604, 5646,
						}
					},
				},
			},
			[103] = { -- Feral
				talents = {
					{22363, 22364, 22365},
					{19283, 18570, 18571},
					{22163, 22158, 22159},
					{21778, 18576, 18577},
					{21708, 18579, 21704},
					{21714, 21711, 22370},
					{21646, 21649, 21653},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							201,  203,  601,
							602,  611,  612,
							620,  820, 3053,
							3751, 5384, 5647,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							201,  203,  601,
							602,  611,  612,
							620,  820, 3053,
							3751, 5384, 5647,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							201,  203,  601,
							602,  611,  612,
							620,  820, 3053,
							3751, 5384, 5647,
						}
					},
				},
			},
			[104] = { -- Guardian
				talents = {
					{22419, 22418, 0},
					{19283, 18570, 18571},
					{22163, 22156, 22159},
					{21778, 18576, 18577},
					{21709, 21707, 22388},
					{22423, 21713, 22390},
					{22426, 22427, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							49,   51,   52,
							194,  195,  196,
							197,  842, 1237,
							3750, 5410, 5648,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							49,   51,   52,
							194,  195,  196,
							197,  842, 1237,
							3750, 5410, 5648,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							49,   51,   52,
							194,  195,  196,
							197,  842, 1237,
							3750, 5410, 5648,
						}
					},
				},
			},
			[105] = { -- Restoration
				talents = {
					{18569, 18574, 18572},
					{19283, 18570, 18571},
					{22366, 22367, 22160},
					{21778, 18576, 18577},
					{21710, 21705, 22421},
					{21716, 18585, 22422},
					{22403, 21651, 22404},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							59,  691,  692,
							697,  700,  835,
							838, 1215, 5387,
							5514, 5649,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							59,  691,  692,
							697,  700,  835,
							838, 1215, 5387,
							5514, 5649,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							59,  691,  692,
							697,  700,  835,
							838, 1215, 5387,
							5514, 5649,
						}
					},
				},
			},
			-- Demon Hunter
			[577] = { -- Havoc
				talents = {
					{21854, 22493, 22416},
					{21857, 22765, 22799},
					{22909, 22494, 21862},
					{21863, 21864, 21865},
					{21866, 21867, 21868},
					{21869, 21870, 22767},
					{21900, 21901, 22547},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							805,  806,  809,
							811,  812,  813,
							1206, 1218, 5433,
							5523,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							805,  806,  809,
							811,  812,  813,
							1206, 1218, 5433,
							5523,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							805,  806,  809,
							811,  812,  813,
							1206, 1218, 5433,
							5523,
						}
					},
				},
			},
			[581] = { -- Vengeance
				talents = {
					{22502, 22503, 22504},
					{22505, 22766, 22507},
					{22324, 22541, 22540},
					{22508, 22509, 22770},
					{22546, 22510, 22511},
					{22512, 22513, 22768},
					{22543, 23464, 21902},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							814,  815,  816,
							819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
							5520, 5521, 5522,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							814,  815,  816,
							819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
							5520, 5521, 5522,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							814,  815,  816,
							819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
							5520, 5521, 5522,
						}
					},
				},
			},
			-- Evoker
			[1467] = { -- Devastation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5556,
							5599, 5617,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5556,
							5599, 5617,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5556,
							5599, 5617,
						}
					},
				},
			},
			[1468] = { -- Preservation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5595,
							5598, 5616,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5595,
							5598, 5616,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5595,
							5598, 5616,
						}
					},
				},
			},
			[1473] = { -- Augmentation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5557, 5558, 5559,
							5560, 5561, 5562,
							5563, 5564, 5612,
							5613, 5615, 5619,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5557, 5558, 5559,
							5560, 5561, 5562,
							5563, 5564, 5612,
							5613, 5615, 5619,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5557, 5558, 5559,
							5560, 5561, 5562,
							5563, 5564, 5612,
							5613, 5615, 5619,
						}
					},
				},
			},
		}
	elseif Internal.Is100200 then
		specInfo = {
			version = 9,

			-- Warrior
			[71] = { -- Arms
				talents = {
					{22624, 22360, 22371},
					{19676, 22372, 22789},
					{22380, 22489, 19138},
					{15757, 22627, 22628},
					{22392, 22391, 22362},
					{22394, 22397, 22399},
					{21204, 22407, 21667},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  28,   29,   31,
							  32,   33,   34,
							3522, 3534, 5372,
							5376, 5547, 5625,
							5630,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  28,   29,   31,
							  32,   33,   34,
							3522, 3534, 5372,
							5376, 5547, 5625,
							5630,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  28,   29,   31,
							  32,   33,   34,
							3522, 3534, 5372,
							5376, 5547, 5625,
							5630,
						}
					},
				},
			},
			[72] = { -- Fury
				talents = {
					{22632, 22633, 22491},
					{19676, 22625, 23093},
					{22379, 22381, 23372},
					{23097, 22627, 22382},
					{22383, 22393, 19140},
					{22396, 22398, 22400},
					{22405, 22402, 16037},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  25,  166,  170,
							 172,  177,  179,
							3528, 3533, 3735,
							5373, 5431, 5548,
							5623, 5624, 5628,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  25,  166,  170,
							 172,  177,  179,
							3528, 3533, 3735,
							5373, 5431, 5548,
							5623, 5624, 5628,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  25,  166,  170,
							 172,  177,  179,
							3528, 3533, 3735,
							5373, 5431, 5548,
							5623, 5624, 5628,
						}
					},
				},
			},
			[73] = { -- Protection
				talents = {
					{15760, 15759, 15774},
					{19676, 22629, 22409},
					{22378, 22626, 23260},
					{23096, 22627, 22488},
					{22384, 22631, 22800},
					{22395, 22544, 22401},
					{23455, 22406, 23099},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  24,  168,  171,
							 173,  175,  178,
							 831,  833,  845,
							5374, 5432, 5626,
							5627, 5629,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  24,  168,  171,
							 173,  175,  178,
							 831,  833,  845,
							5374, 5432, 5626,
							5627, 5629,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  24,  168,  171,
							 173,  175,  178,
							 831,  833,  845,
							5374, 5432, 5626,
							5627, 5629,
						}
					},
				},
			},
			-- Paladin
			[65] = { -- Holy
				talents = {
					{17565, 17567, 17569},
					{22176, 17575, 17577},
					{22179, 22180, 21811},
					{22433, 22434, 17593},
					{17597, 17599, 17601},
					{23191, 23680, 22484},
					{21201, 21671, 23681},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  82,   85,   86,
							  87,   88,  640,
							 642, 3618, 5421,
							5583, 5614, 5618,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  82,   85,   86,
							  87,   88,  640,
							 642, 3618, 5421,
							5583, 5614, 5618,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  82,   85,   86,
							  87,   88,  640,
							 642, 3618, 5421,
							5583, 5614, 5618,
						}
					},
				},
			},
			[66] = { -- Protection
				talents = {
					{22428, 22558, 23469},
					{22431, 22604, 23468},
					{22179, 22180, 21811},
					{22433, 22434, 22435},
					{17597, 17599, 17601},
					{22189, 22438, 23087},
					{23457, 21202, 22645},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  90,   91,   92,
							  93,   94,   97,
							 844,  860,  861,
							3474, 5554, 5582,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  90,   91,   92,
							  93,   94,   97,
							 844,  860,  861,
							3474, 5554, 5582,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  90,   91,   92,
							  93,   94,   97,
							 844,  860,  861,
							3474, 5554, 5582,
						}
					},
				},
			},
			[70] = { -- Retribution
				talents = {
					{22590, 22557, 23467},
					{22319, 22592, 23466},
					{22179, 22180, 21811},
					{22433, 22434, 22183},
					{17597, 17599, 17601},
					{23167, 22483, 23086},
					{23456, 22215, 22634},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  81,  752,  753,
							 754,  756, 5422,
							5535, 5572, 5573,
							5584,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  81,  752,  753,
							 754,  756, 5422,
							5535, 5572, 5573,
							5584,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  81,  752,  753,
							 754,  756, 5422,
							5535, 5572, 5573,
							5584,
						}
					},
				},
			},
			-- Hunter
			[253] = { -- Beast Mastery
				talents = {
					{22291, 22280, 22282},
					{22500, 22266, 22290},
					{19347, 19348, 23100},
					{22441, 22347, 22269},
					{22268, 22276, 22499},
					{19357, 22002, 23044},
					{22273, 21986, 22295},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 693,  824,  825,
							1214, 3599, 3604,
							3730, 5418, 5441,
							5444, 5534,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 693,  824,  825,
							1214, 3599, 3604,
							3730, 5418, 5441,
							5444, 5534,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 693,  824,  825,
							1214, 3599, 3604,
							3730, 5418, 5441,
							5444, 5534,
						}
					},
				},
			},
			[254] = { -- Marksmanship
				talents = {
					{22279, 22501, 22289},
					{22495, 22497, 22498},
					{19347, 19348, 23100},
					{22267, 22286, 21998},
					{22268, 22276, 23463},
					{23063, 23104, 22287},
					{22274, 22308, 22288},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 651,  653,  658,
							 659,  660, 3729,
							5419, 5440, 5442,
							5531, 5533,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 651,  653,  658,
							 659,  660, 3729,
							5419, 5440, 5442,
							5531, 5533,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 651,  653,  658,
							 659,  660, 3729,
							5419, 5440, 5442,
							5531, 5533,
						}
					},
				},
			},
			[255] = { -- Survival
				talents = {
					{22275, 22283, 22296},
					{21997, 22769, 22297},
					{19347, 19348, 23100},
					{22277, 19361, 22299},
					{22268, 22276, 22499},
					{22300, 22278, 22271},
					{22272, 22301, 23105},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 661,  662,  664,
							 665,  686, 3607,
							3609, 5420, 5443,
							5532,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 661,  662,  664,
							 665,  686, 3607,
							3609, 5420, 5443,
							5532,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 661,  662,  664,
							 665,  686, 3607,
							3609, 5420, 5443,
							5532,
						}
					},
				},
			},
			-- Rogue
			[259] = { -- Assassination
				talents = {
					{22337, 22338, 22339},
					{22331, 22332, 23022},
					{19239, 19240, 19241},
					{22340, 22122, 22123},
					{19245, 23037, 22115},
					{22343, 23015, 22344},
					{21186, 22133, 23174},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
				},
			},
			[260] = { -- Outlaw
				talents = {
					{22118, 22119, 22120},
					{23470, 19237, 19238},
					{19239, 19240, 19241},
					{22121, 22122, 22123},
					{23077, 22114, 22115},
					{21990, 23128, 19250},
					{22125, 23075, 23175},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 129,  135,  138,
							 139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 129,  135,  138,
							 139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 129,  135,  138,
							 139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
				},
			},
			[261] = { -- Subtlety
				talents = {
					{19233, 19234, 19235},
					{22331, 22332, 22333},
					{19239, 19240, 19241},
					{22128, 22122, 22123},
					{23078, 23036, 22115},
					{22335, 19249, 22336},
					{22132, 23183, 21188},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 136,  146,  153,
							 846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 136,  146,  153,
							 846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 136,  146,  153,
							 846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
				},
			},
			-- Priest
			[256] = { -- Discipline
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 100,  109,  111,
							 114,  123,  126,
							 855, 5416, 5480,
							5487, 5570, 5635,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 100,  109,  111,
							 114,  123,  126,
							 855, 5416, 5480,
							5487, 5570, 5635,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 100,  109,  111,
							 114,  123,  126,
							 855, 5416, 5480,
							5487, 5570, 5635,
						}
					},
				},
			},
			[257] = { -- Holy
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 101,  108,  112,
							 124,  127, 1927,
							5365, 5366, 5479,
							5485, 5569, 5620,
							5634,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 101,  108,  112,
							 124,  127, 1927,
							5365, 5366, 5479,
							5485, 5569, 5620,
							5634,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 101,  108,  112,
							 124,  127, 1927,
							5365, 5366, 5479,
							5485, 5569, 5620,
							5634,
						}
					},
				},
			},
			[258] = { -- Shadow
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 106,  113,  763,
							5381, 5447, 5481,
							5486, 5568, 5636,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 106,  113,  763,
							5381, 5447, 5481,
							5486, 5568, 5636,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 106,  113,  763,
							5381, 5447, 5481,
							5486, 5568, 5636,
						}
					},
				},
			},
			-- Death Knight
			[250] = { -- Blood
				talents = {
					{19165, 19166, 23454},
					{19218, 19219, 19220},
					{19221, 22134, 22135},
					{22013, 22014, 22015},
					{19227, 19226, 19228},
					{19230, 19231, 19232},
					{21207, 21208, 21209},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 204,  205,  206,
							 608,  609,  841,
							3441, 3511, 5513,
							5587, 5592,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 204,  205,  206,
							 608,  609,  841,
							3441, 3511, 5513,
							5587, 5592,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 204,  205,  206,
							 608,  609,  841,
							3441, 3511, 5513,
							5587, 5592,
						}
					},
				},
			},
			[251] = { -- Frost
				talents = {
					{22016, 22017, 22018},
					{22019, 22020, 22021},
					{22515, 22517, 22519},
					{22521, 22523, 22525},
					{22527, 22530, 23373},
					{22531, 22533, 22535},
					{22023, 22109, 22537},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 701,  702, 3439,
							3512, 3743, 5429,
							5435, 5510, 5512,
							5586, 5591,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 701,  702, 3439,
							3512, 3743, 5429,
							5435, 5510, 5512,
							5586, 5591,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 701,  702, 3439,
							3512, 3743, 5429,
							5435, 5510, 5512,
							5586, 5591,
						}
					},
				},
			},
			[252] = { -- Unholy
				talents = {
					{22024, 22025, 22026},
					{22027, 22028, 22029},
					{22516, 22518, 22520},
					{22522, 22524, 22526},
					{22528, 22529, 23373},
					{22532, 22534, 22536},
					{22030, 22110, 22538},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  40,   41,  149,
							 152, 3437, 3746,
							5430, 5436, 5511,
							5585, 5590,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  40,   41,  149,
							 152, 3437, 3746,
							5430, 5436, 5511,
							5585, 5590,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  40,   41,  149,
							 152, 3437, 3746,
							5430, 5436, 5511,
							5585, 5590,
						}
					},
				},
			},
			-- Shaman
			[262] = { -- Elemental
				talents = {
					{22356, 22357, 22358},
					{23108, 23460, 23190},
					{23162, 23163, 23164},
					{19271, 19272, 19273},
					{22144, 22172, 21966},
					{22145, 19266, 23111},
					{21198, 22153, 21675},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 727,  730, 3488,
							3490, 3491, 3620,
							5415, 5571, 5574,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 727,  730, 3488,
							3490, 3491, 3620,
							5415, 5571, 5574,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 727,  730, 3488,
							3490, 3491, 3620,
							5415, 5571, 5574,
						}
					},
				},
			},
			[263] = { -- Enhancement
				talents = {
					{22354, 22355, 22353},
					{22636, 23462, 23109},
					{23165, 19260, 23166},
					{23089, 23090, 22171},
					{22144, 22149, 21966},
					{21973, 22352, 22351},
					{21970, 22977, 21972},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 721,  722, 3487,
							3489, 3492, 3622,
							5414, 5438, 5527,
							5575, 5596,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 721,  722, 3487,
							3489, 3492, 3622,
							5414, 5438, 5527,
							5575, 5596,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 721,  722, 3487,
							3489, 3492, 3622,
							5414, 5438, 5527,
							5575, 5596,
						}
					},
				},
			},
			[264] = { -- Restoration
				talents = {
					{19262, 19263, 19264},
					{19259, 23461, 21963},
					{19275, 23110, 22127},
					{22152, 22322, 22323},
					{22144, 19269, 21966},
					{19265, 21971, 21968},
					{21969, 21199, 22359},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 707,  708,  714,
							 715, 3755, 5388,
							5437, 5528, 5566,
							5567, 5576,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 707,  708,  714,
							 715, 3755, 5388,
							5437, 5528, 5566,
							5567, 5576,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 707,  708,  714,
							 715, 3755, 5388,
							5437, 5528, 5566,
							5567, 5576,
						}
					},
				},
			},
			-- Mage
			[62] = { -- Arcane
				talents = {
					{22458, 22461, 22464},
					{23072, 22443, 16025},
					{22444, 22445, 22447},
					{22453, 22467, 22470},
					{22907, 22448, 22471},
					{22455, 22449, 22474},
					{21630, 21144, 21145},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 635,  637, 3517,
							3529, 5397, 5488,
							5491, 5589, 5601,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 635,  637, 3517,
							3529, 5397, 5488,
							5491, 5589, 5601,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 635,  637, 3517,
							3529, 5397, 5488,
							5491, 5589, 5601,
						}
					},
				},
			},
			[63] = { -- Fire
				talents = {
					{22456, 22459, 22462},
					{23071, 22443, 23074},
					{22444, 22445, 22447},
					{22450, 22465, 22468},
					{22904, 22448, 22471},
					{22451, 23362, 22472},
					{21631, 22220, 21633},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 644,  647,  648,
							5389, 5489, 5495,
							5588, 5602, 5621,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 644,  647,  648,
							5389, 5489, 5495,
							5588, 5602, 5621,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 644,  647,  648,
							5389, 5489, 5495,
							5588, 5602, 5621,
						}
					},
				},
			},
			[64] = { -- Frost
				talents = {
					{22457, 22460, 22463},
					{22442, 22443, 23073},
					{22444, 22445, 22447},
					{22452, 22466, 22469},
					{22446, 22448, 22471},
					{22454, 23176, 22473},
					{21632, 22309, 21634},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  66,  632,  634,
							5390, 5490, 5496,
							5497, 5581, 5600,
							5622,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  66,  632,  634,
							5390, 5490, 5496,
							5497, 5581, 5600,
							5622,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  66,  632,  634,
							5390, 5490, 5496,
							5497, 5581, 5600,
							5622,
						}
					},
				},
			},
			-- Warlock
			[265] = { -- Affliction
				talents = {
					{22039, 23140, 23141},
					{22044, 21180, 22089},
					{19280, 19285, 19286},
					{19279, 19292, 22046},
					{22047, 19291, 23465},
					{23139, 23159, 19295},
					{19284, 19281, 19293},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  12,   15,   16,
							  18,   19, 5379,
							5386, 5392, 5543,
							5546, 5579, 5608,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  12,   15,   16,
							  18,   19, 5379,
							5386, 5392, 5543,
							5546, 5579, 5608,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  12,   15,   16,
							  18,   19, 5379,
							5386, 5392, 5543,
							5546, 5579, 5608,
						}
					},
				},
			},
			[266] = { -- Demonology
				talents = {
					{19290, 22048, 23138},
					{22045, 21694, 23158},
					{19280, 19285, 19286},
					{22477, 22042, 23160},
					{22047, 19291, 23465},
					{23147, 23146, 21717},
					{23161, 22479, 23091},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 162,  165, 1213,
							3506, 3624, 5394,
							5400, 5545, 5577,
							5606,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 162,  165, 1213,
							3506, 3624, 5394,
							5400, 5545, 5577,
							5606,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 162,  165, 1213,
							3506, 3624, 5394,
							5400, 5545, 5577,
							5606,
						}
					},
				},
			},
			[267] = { -- Destruction
				talents = {
					{22038, 22090, 22040},
					{23148, 21695, 23157},
					{19280, 19285, 19286},
					{22480, 22043, 23143},
					{22047, 19291, 23465},
					{23155, 23156, 19295},
					{19284, 23144, 23092},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 157,  164, 3508,
							5382, 5393, 5401,
							5544, 5580, 5607,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 157,  164, 3508,
							5382, 5393, 5401,
							5544, 5580, 5607,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 157,  164, 3508,
							5382, 5393, 5401,
							5544, 5580, 5607,
						}
					},
				},
			},
			-- Monk
			[268] = { -- Brewmaster
				talents = {
					{23106, 19820, 20185},
					{19304, 19818, 19302},
					{22099, 22097, 19992},
					{19993, 19994, 19995},
					{20174, 23363, 20175},
					{19819, 20184, 22103},
					{22106, 22104, 22108},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 666,  667,  668,
							 669,  670,  672,
							 673,  765,  843,
							1958, 5417, 5538,
							5541, 5552,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 666,  667,  668,
							 669,  670,  672,
							 673,  765,  843,
							1958, 5417, 5538,
							5541, 5552,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 666,  667,  668,
							 669,  670,  672,
							 673,  765,  843,
							1958, 5417, 5538,
							5541, 5552,
						}
					},
				},
			},
			[270] = { -- Mistweaver
				talents = {
					{19823, 19820, 20185},
					{19304, 19818, 19302},
					{22168, 22167, 22166},
					{19993, 22219, 19995},
					{23371, 20173, 20175},
					{23107, 22101, 0},
					{22218, 22169, 22170},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  70,  679,  680,
							 683, 1928, 3732,
							5395, 5398, 5402,
							5539, 5551, 5565,
							5603,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  70,  679,  680,
							 683, 1928, 3732,
							5395, 5398, 5402,
							5539, 5551, 5565,
							5603,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  70,  679,  680,
							 683, 1928, 3732,
							5395, 5398, 5402,
							5539, 5551, 5565,
							5603,
						}
					},
				},
			},
			[269] = { -- Windwalker
				talents = {
					{23106, 19820, 20185},
					{19304, 19818, 19302},
					{22098, 19771, 22096},
					{19993, 23364, 19995},
					{23258, 20173, 20175},
					{22093, 23122, 22102},
					{22107, 22105, 21191},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  77,  675,  852,
							3050, 3052, 3734,
							3737, 3744, 3745,
							5448, 5540, 5610,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  77,  675,  852,
							3050, 3052, 3734,
							3737, 3744, 3745,
							5448, 5540, 5610,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  77,  675,  852,
							3050, 3052, 3734,
							3737, 3744, 3745,
							5448, 5540, 5610,
						}
					},
				},
			},
			-- Druid
			[102] = { -- Balance
				talents = {
					{22385, 22386, 22387},
					{19283, 18570, 18571},
					{22163, 22157, 22159},
					{21778, 18576, 18577},
					{18580, 21706, 21702},
					{22389, 21712, 22165},
					{21648, 21193, 21655},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 180,  182,  184,
							 185,  822,  834,
							 836, 3058, 3728,
							3731, 5383, 5407,
							5515, 5604,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 180,  182,  184,
							 185,  822,  834,
							 836, 3058, 3728,
							3731, 5383, 5407,
							5515, 5604,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 180,  182,  184,
							 185,  822,  834,
							 836, 3058, 3728,
							3731, 5383, 5407,
							5515, 5604,
						}
					},
				},
			},
			[103] = { -- Feral
				talents = {
					{22363, 22364, 22365},
					{19283, 18570, 18571},
					{22163, 22158, 22159},
					{21778, 18576, 18577},
					{21708, 18579, 21704},
					{21714, 21711, 22370},
					{21646, 21649, 21653},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 201,  203,  601,
							 602,  611,  612,
							 620,  820, 3053,
							3751, 5384, 5593,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 201,  203,  601,
							 602,  611,  612,
							 620,  820, 3053,
							3751, 5384, 5593,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 201,  203,  601,
							 602,  611,  612,
							 620,  820, 3053,
							3751, 5384, 5593,
						}
					},
				},
			},
			[104] = { -- Guardian
				talents = {
					{22419, 22418, 0},
					{19283, 18570, 18571},
					{22163, 22156, 22159},
					{21778, 18576, 18577},
					{21709, 21707, 22388},
					{22423, 21713, 22390},
					{22426, 22427, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  49,   51,   52,
							 194,  195,  196,
							 197,  842, 1237,
							3750, 5410,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  49,   51,   52,
							 194,  195,  196,
							 197,  842, 1237,
							3750, 5410,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  49,   51,   52,
							 194,  195,  196,
							 197,  842, 1237,
							3750, 5410,
						}
					},
				},
			},
			[105] = { -- Restoration
				talents = {
					{18569, 18574, 18572},
					{19283, 18570, 18571},
					{22366, 22367, 22160},
					{21778, 18576, 18577},
					{21710, 21705, 22421},
					{21716, 18585, 22422},
					{22403, 21651, 22404},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  59,  691,  692,
							 697,  700,  835,
							 838, 1215, 5387,
							5514, 5637,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  59,  691,  692,
							 697,  700,  835,
							 838, 1215, 5387,
							5514, 5637,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  59,  691,  692,
							 697,  700,  835,
							 838, 1215, 5387,
							5514, 5637,
						}
					},
				},
			},
			-- Demon Hunter
			[577] = { -- Havoc
				talents = {
					{21854, 22493, 22416},
					{21857, 22765, 22799},
					{22909, 22494, 21862},
					{21863, 21864, 21865},
					{21866, 21867, 21868},
					{21869, 21870, 22767},
					{21900, 21901, 22547},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 805,  806,  809,
							 811,  812,  813,
							1206, 1218, 5433,
							5523,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 805,  806,  809,
							 811,  812,  813,
							1206, 1218, 5433,
							5523,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 805,  806,  809,
							 811,  812,  813,
							1206, 1218, 5433,
							5523,
						}
					},
				},
			},
			[581] = { -- Vengeance
				talents = {
					{22502, 22503, 22504},
					{22505, 22766, 22507},
					{22324, 22541, 22540},
					{22508, 22509, 22770},
					{22546, 22510, 22511},
					{22512, 22513, 22768},
					{22543, 23464, 21902},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 814,  815,  816,
							 819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
							5520, 5521, 5522,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 814,  815,  816,
							 819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
							5520, 5521, 5522,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 814,  815,  816,
							 819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
							5520, 5521, 5522,
						}
					},
				},
			},
			-- Evoker
			[1467] = { -- Devastation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5556,
							5599, 5617,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5556,
							5599, 5617,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5556,
							5599, 5617,
						}
					},
				},
			},
			[1468] = { -- Preservation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5595,
							5598, 5616,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5595,
							5598, 5616,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5595,
							5598, 5616,
						}
					},
				},
			},
			[1473] = { -- Augmentation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5557, 5558, 5559,
							5560, 5561, 5562,
							5563, 5564, 5612,
							5613, 5615, 5619,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5557, 5558, 5559,
							5560, 5561, 5562,
							5563, 5564, 5612,
							5613, 5615, 5619,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5557, 5558, 5559,
							5560, 5561, 5562,
							5563, 5564, 5612,
							5613, 5615, 5619,
						}
					},
				},
			},
		}
	elseif Internal.Is100100 then
		specInfo = {
			version = 8,

			-- Warrior
			[71] = { -- Arms
				talents = {
					{22624, 22360, 22371},
					{19676, 22372, 22789},
					{22380, 22489, 19138},
					{15757, 22627, 22628},
					{22392, 22391, 22362},
					{22394, 22397, 22399},
					{21204, 22407, 21667},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  28,   29,   31,
							  32,   33,   34,
							3522, 3534, 5372,
							5376, 5547,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  28,   29,   31,
							  32,   33,   34,
							3522, 3534, 5372,
							5376, 5547,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  28,   29,   31,
							  32,   33,   34,
							3522, 3534, 5372,
							5376, 5547,
						}
					},
				},
			},
			[72] = { -- Fury
				talents = {
					{22632, 22633, 22491},
					{19676, 22625, 23093},
					{22379, 22381, 23372},
					{23097, 22627, 22382},
					{22383, 22393, 19140},
					{22396, 22398, 22400},
					{22405, 22402, 16037},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  25,  166,  170,
							 172,  177,  179,
							3528, 3533, 3735,
							5373, 5431, 5548,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  25,  166,  170,
							 172,  177,  179,
							3528, 3533, 3735,
							5373, 5431, 5548,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  25,  166,  170,
							 172,  177,  179,
							3528, 3533, 3735,
							5373, 5431, 5548,
						}
					},
				},
			},
			[73] = { -- Protection
				talents = {
					{15760, 15759, 15774},
					{19676, 22629, 22409},
					{22378, 22626, 23260},
					{23096, 22627, 22488},
					{22384, 22631, 22800},
					{22395, 22544, 22401},
					{23455, 22406, 23099},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  24,  168,  171,
							 173,  175,  178,
							 831,  833,  845,
							5374, 5432,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  24,  168,  171,
							 173,  175,  178,
							 831,  833,  845,
							5374, 5432,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  24,  168,  171,
							 173,  175,  178,
							 831,  833,  845,
							5374, 5432,
						}
					},
				},
			},
			-- Paladin
			[65] = { -- Holy
				talents = {
					{17565, 17567, 17569},
					{22176, 17575, 17577},
					{22179, 22180, 21811},
					{22433, 22434, 17593},
					{17597, 17599, 17601},
					{23191, 23680, 22484},
					{21201, 21671, 23681},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  82,   85,   86,
							  87,   88,  640,
							 642, 3618, 5421,
							5553, 5583,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  82,   85,   86,
							  87,   88,  640,
							 642, 3618, 5421,
							5553, 5583,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  82,   85,   86,
							  87,   88,  640,
							 642, 3618, 5421,
							5553, 5583,
						}
					},
				},
			},
			[66] = { -- Protection
				talents = {
					{22428, 22558, 23469},
					{22431, 22604, 23468},
					{22179, 22180, 21811},
					{22433, 22434, 22435},
					{17597, 17599, 17601},
					{22189, 22438, 23087},
					{23457, 21202, 22645},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  90,   91,   92,
							  93,   94,   97,
							 844,  860,  861,
							3474, 5554, 5582,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  90,   91,   92,
							  93,   94,   97,
							 844,  860,  861,
							3474, 5554, 5582,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  90,   91,   92,
							  93,   94,   97,
							 844,  860,  861,
							3474, 5554, 5582,
						}
					},
				},
			},
			[70] = { -- Retribution
				talents = {
					{22590, 22557, 23467},
					{22319, 22592, 23466},
					{22179, 22180, 21811},
					{22433, 22434, 22183},
					{17597, 17599, 17601},
					{23167, 22483, 23086},
					{23456, 22215, 22634},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  81,  752,  753,
							 754,  756, 5422,
							5535, 5572, 5573,
							5584,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  81,  752,  753,
							 754,  756, 5422,
							5535, 5572, 5573,
							5584,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  81,  752,  753,
							 754,  756, 5422,
							5535, 5572, 5573,
							5584,
						}
					},
				},
			},
			-- Hunter
			[253] = { -- Beast Mastery
				talents = {
					{22291, 22280, 22282},
					{22500, 22266, 22290},
					{19347, 19348, 23100},
					{22441, 22347, 22269},
					{22268, 22276, 22499},
					{19357, 22002, 23044},
					{22273, 21986, 22295},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 693,  824,  825,
							1214, 3599, 3604,
							3730, 5418, 5441,
							5444, 5534,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 693,  824,  825,
							1214, 3599, 3604,
							3730, 5418, 5441,
							5444, 5534,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 693,  824,  825,
							1214, 3599, 3604,
							3730, 5418, 5441,
							5444, 5534,
						}
					},
				},
			},
			[254] = { -- Marksmanship
				talents = {
					{22279, 22501, 22289},
					{22495, 22497, 22498},
					{19347, 19348, 23100},
					{22267, 22286, 21998},
					{22268, 22276, 23463},
					{23063, 23104, 22287},
					{22274, 22308, 22288},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 651,  653,  658,
							 659,  660, 3729,
							5419, 5440, 5442,
							5531, 5533,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 651,  653,  658,
							 659,  660, 3729,
							5419, 5440, 5442,
							5531, 5533,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 651,  653,  658,
							 659,  660, 3729,
							5419, 5440, 5442,
							5531, 5533,
						}
					},
				},
			},
			[255] = { -- Survival
				talents = {
					{22275, 22283, 22296},
					{21997, 22769, 22297},
					{19347, 19348, 23100},
					{22277, 19361, 22299},
					{22268, 22276, 22499},
					{22300, 22278, 22271},
					{22272, 22301, 23105},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 661,  662,  664,
							 665,  686, 3607,
							3609, 5420, 5443,
							5532,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 661,  662,  664,
							 665,  686, 3607,
							3609, 5420, 5443,
							5532,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 661,  662,  664,
							 665,  686, 3607,
							3609, 5420, 5443,
							5532,
						}
					},
				},
			},
			-- Rogue
			[259] = { -- Assassination
				talents = {
					{22337, 22338, 22339},
					{22331, 22332, 23022},
					{19239, 19240, 19241},
					{22340, 22122, 22123},
					{19245, 23037, 22115},
					{22343, 23015, 22344},
					{21186, 22133, 23174},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
				},
			},
			[260] = { -- Outlaw
				talents = {
					{22118, 22119, 22120},
					{23470, 19237, 19238},
					{19239, 19240, 19241},
					{22121, 22122, 22123},
					{23077, 22114, 22115},
					{21990, 23128, 19250},
					{22125, 23075, 23175},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 129,  135,  138,
							 139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 129,  135,  138,
							 139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 129,  135,  138,
							 139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
				},
			},
			[261] = { -- Subtlety
				talents = {
					{19233, 19234, 19235},
					{22331, 22332, 22333},
					{19239, 19240, 19241},
					{22128, 22122, 22123},
					{23078, 23036, 22115},
					{22335, 19249, 22336},
					{22132, 23183, 21188},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 136,  146,  153,
							 846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 136,  146,  153,
							 846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 136,  146,  153,
							 846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
				},
			},
			-- Priest
			[256] = { -- Discipline
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  98,  100,  109,
							 111,  114,  123,
							 126,  855, 5416,
							5480, 5487, 5570,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  98,  100,  109,
							 111,  114,  123,
							 126,  855, 5416,
							5480, 5487, 5570,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  98,  100,  109,
							 111,  114,  123,
							 126,  855, 5416,
							5480, 5487, 5570,
						}
					},
				},
			},
			[257] = { -- Holy
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 101,  108,  112,
							 124,  127, 1927,
							5365, 5366, 5476,
							5478, 5479, 5485,
							5569,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 101,  108,  112,
							 124,  127, 1927,
							5365, 5366, 5476,
							5478, 5479, 5485,
							5569,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 101,  108,  112,
							 124,  127, 1927,
							5365, 5366, 5476,
							5478, 5479, 5485,
							5569,
						}
					},
				},
			},
			[258] = { -- Shadow
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 106,  113,  763,
							5381, 5447, 5477,
							5481, 5486, 5568,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 106,  113,  763,
							5381, 5447, 5477,
							5481, 5486, 5568,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 106,  113,  763,
							5381, 5447, 5477,
							5481, 5486, 5568,
						}
					},
				},
			},
			-- Death Knight
			[250] = { -- Blood
				talents = {
					{19165, 19166, 23454},
					{19218, 19219, 19220},
					{19221, 22134, 22135},
					{22013, 22014, 22015},
					{19227, 19226, 19228},
					{19230, 19231, 19232},
					{21207, 21208, 21209},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 204,  205,  206,
							 608,  609,  841,
							3441, 3511, 5513,
							5587, 5592,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 204,  205,  206,
							 608,  609,  841,
							3441, 3511, 5513,
							5587, 5592,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 204,  205,  206,
							 608,  609,  841,
							3441, 3511, 5513,
							5587, 5592,
						}
					},
				},
			},
			[251] = { -- Frost
				talents = {
					{22016, 22017, 22018},
					{22019, 22020, 22021},
					{22515, 22517, 22519},
					{22521, 22523, 22525},
					{22527, 22530, 23373},
					{22531, 22533, 22535},
					{22023, 22109, 22537},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 701,  702, 3439,
							3512, 3743, 5429,
							5435, 5510, 5512,
							5586, 5591,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 701,  702, 3439,
							3512, 3743, 5429,
							5435, 5510, 5512,
							5586, 5591,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 701,  702, 3439,
							3512, 3743, 5429,
							5435, 5510, 5512,
							5586, 5591,
						}
					},
				},
			},
			[252] = { -- Unholy
				talents = {
					{22024, 22025, 22026},
					{22027, 22028, 22029},
					{22516, 22518, 22520},
					{22522, 22524, 22526},
					{22528, 22529, 23373},
					{22532, 22534, 22536},
					{22030, 22110, 22538},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  40,   41,  149,
							 152, 3437, 3746,
							3747, 5430, 5436,
							5511, 5585, 5590,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  40,   41,  149,
							 152, 3437, 3746,
							3747, 5430, 5436,
							5511, 5585, 5590,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  40,   41,  149,
							 152, 3437, 3746,
							3747, 5430, 5436,
							5511, 5585, 5590,
						}
					},
				},
			},
			-- Shaman
			[262] = { -- Elemental
				talents = {
					{22356, 22357, 22358},
					{23108, 23460, 23190},
					{23162, 23163, 23164},
					{19271, 19272, 19273},
					{22144, 22172, 21966},
					{22145, 19266, 23111},
					{21198, 22153, 21675},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 727,  730, 3488,
							3490, 3491, 3620,
							5415, 5571, 5574,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 727,  730, 3488,
							3490, 3491, 3620,
							5415, 5571, 5574,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 727,  730, 3488,
							3490, 3491, 3620,
							5415, 5571, 5574,
						}
					},
				},
			},
			[263] = { -- Enhancement
				talents = {
					{22354, 22355, 22353},
					{22636, 23462, 23109},
					{23165, 19260, 23166},
					{23089, 23090, 22171},
					{22144, 22149, 21966},
					{21973, 22352, 22351},
					{21970, 22977, 21972},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 721,  722, 3487,
							3489, 3492, 3622,
							5414, 5438, 5527,
							5575, 5596,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 721,  722, 3487,
							3489, 3492, 3622,
							5414, 5438, 5527,
							5575, 5596,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 721,  722, 3487,
							3489, 3492, 3622,
							5414, 5438, 5527,
							5575, 5596,
						}
					},
				},
			},
			[264] = { -- Restoration
				talents = {
					{19262, 19263, 19264},
					{19259, 23461, 21963},
					{19275, 23110, 22127},
					{22152, 22322, 22323},
					{22144, 19269, 21966},
					{19265, 21971, 21968},
					{21969, 21199, 22359},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 707,  708,  714,
							 715, 3755, 5388,
							5437, 5528, 5566,
							5567, 5576,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 707,  708,  714,
							 715, 3755, 5388,
							5437, 5528, 5566,
							5567, 5576,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 707,  708,  714,
							 715, 3755, 5388,
							5437, 5528, 5566,
							5567, 5576,
						}
					},
				},
			},
			-- Mage
			[62] = { -- Arcane
				talents = {
					{22458, 22461, 22464},
					{23072, 22443, 16025},
					{22444, 22445, 22447},
					{22453, 22467, 22470},
					{22907, 22448, 22471},
					{22455, 22449, 22474},
					{21630, 21144, 21145},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 635,  637, 3517,
							3529, 5397, 5488,
							5491, 5589, 5601,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 635,  637, 3517,
							3529, 5397, 5488,
							5491, 5589, 5601,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 635,  637, 3517,
							3529, 5397, 5488,
							5491, 5589, 5601,
						}
					},
				},
			},
			[63] = { -- Fire
				talents = {
					{22456, 22459, 22462},
					{23071, 22443, 23074},
					{22444, 22445, 22447},
					{22450, 22465, 22468},
					{22904, 22448, 22471},
					{22451, 23362, 22472},
					{21631, 22220, 21633},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 644,  646,  647,
							 648, 5389, 5489,
							5495, 5588, 5602,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 644,  646,  647,
							 648, 5389, 5489,
							5495, 5588, 5602,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 644,  646,  647,
							 648, 5389, 5489,
							5495, 5588, 5602,
						}
					},
				},
			},
			[64] = { -- Frost
				talents = {
					{22457, 22460, 22463},
					{22442, 22443, 23073},
					{22444, 22445, 22447},
					{22452, 22466, 22469},
					{22446, 22448, 22471},
					{22454, 23176, 22473},
					{21632, 22309, 21634},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  66,  632,  634,
							5390, 5490, 5496,
							5497, 5581, 5600,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  66,  632,  634,
							5390, 5490, 5496,
							5497, 5581, 5600,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  66,  632,  634,
							5390, 5490, 5496,
							5497, 5581, 5600,
						}
					},
				},
			},
			-- Warlock
			[265] = { -- Affliction
				talents = {
					{22039, 23140, 23141},
					{22044, 21180, 22089},
					{19280, 19285, 19286},
					{19279, 19292, 22046},
					{22047, 19291, 23465},
					{23139, 23159, 19295},
					{19284, 19281, 19293},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  12,   15,   16,
							  18,   19, 5379,
							5386, 5392, 5543,
							5546, 5579, 5608,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  12,   15,   16,
							  18,   19, 5379,
							5386, 5392, 5543,
							5546, 5579, 5608,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  12,   15,   16,
							  18,   19, 5379,
							5386, 5392, 5543,
							5546, 5579, 5608,
						}
					},
				},
			},
			[266] = { -- Demonology
				talents = {
					{19290, 22048, 23138},
					{22045, 21694, 23158},
					{19280, 19285, 19286},
					{22477, 22042, 23160},
					{22047, 19291, 23465},
					{23147, 23146, 21717},
					{23161, 22479, 23091},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 162,  165, 1213,
							3506, 3624, 5394,
							5400, 5545, 5577,
							5606,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 162,  165, 1213,
							3506, 3624, 5394,
							5400, 5545, 5577,
							5606,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 162,  165, 1213,
							3506, 3624, 5394,
							5400, 5545, 5577,
							5606,
						}
					},
				},
			},
			[267] = { -- Destruction
				talents = {
					{22038, 22090, 22040},
					{23148, 21695, 23157},
					{19280, 19285, 19286},
					{22480, 22043, 23143},
					{22047, 19291, 23465},
					{23155, 23156, 19295},
					{19284, 23144, 23092},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 157,  164, 3508,
							5382, 5393, 5401,
							5544, 5580, 5607,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 157,  164, 3508,
							5382, 5393, 5401,
							5544, 5580, 5607,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 157,  164, 3508,
							5382, 5393, 5401,
							5544, 5580, 5607,
						}
					},
				},
			},
			-- Monk
			[268] = { -- Brewmaster
				talents = {
					{23106, 19820, 20185},
					{19304, 19818, 19302},
					{22099, 22097, 19992},
					{19993, 19994, 19995},
					{20174, 23363, 20175},
					{19819, 20184, 22103},
					{22106, 22104, 22108},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 666,  667,  668,
							 669,  670,  672,
							 673,  765,  843,
							1958, 5417, 5538,
							5541, 5552,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 666,  667,  668,
							 669,  670,  672,
							 673,  765,  843,
							1958, 5417, 5538,
							5541, 5552,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 666,  667,  668,
							 669,  670,  672,
							 673,  765,  843,
							1958, 5417, 5538,
							5541, 5552,
						}
					},
				},
			},
			[270] = { -- Mistweaver
				talents = {
					{19823, 19820, 20185},
					{19304, 19818, 19302},
					{22168, 22167, 22166},
					{19993, 22219, 19995},
					{23371, 20173, 20175},
					{23107, 22101, 0},
					{22218, 22169, 22170},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  70,  679,  680,
							 682,  683, 1928,
							3732, 5395, 5398,
							5402, 5539, 5551,
							5565, 5603,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  70,  679,  680,
							 682,  683, 1928,
							3732, 5395, 5398,
							5402, 5539, 5551,
							5565, 5603,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  70,  679,  680,
							 682,  683, 1928,
							3732, 5395, 5398,
							5402, 5539, 5551,
							5565, 5603,
						}
					},
				},
			},
			[269] = { -- Windwalker
				talents = {
					{23106, 19820, 20185},
					{19304, 19818, 19302},
					{22098, 19771, 22096},
					{19993, 23364, 19995},
					{23258, 20173, 20175},
					{22093, 23122, 22102},
					{22107, 22105, 21191},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  77,  675,  852,
							3050, 3052, 3734,
							3737, 3744, 3745,
							5448, 5540, 5610,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  77,  675,  852,
							3050, 3052, 3734,
							3737, 3744, 3745,
							5448, 5540, 5610,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  77,  675,  852,
							3050, 3052, 3734,
							3737, 3744, 3745,
							5448, 5540, 5610,
						}
					},
				},
			},
			-- Druid
			[102] = { -- Balance
				talents = {
					{22385, 22386, 22387},
					{19283, 18570, 18571},
					{22163, 22157, 22159},
					{21778, 18576, 18577},
					{18580, 21706, 21702},
					{22389, 21712, 22165},
					{21648, 21193, 21655},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 180,  182,  184,
							 185,  822,  834,
							 836, 3058, 3728,
							3731, 5383, 5407,
							5515, 5604,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 180,  182,  184,
							 185,  822,  834,
							 836, 3058, 3728,
							3731, 5383, 5407,
							5515, 5604,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 180,  182,  184,
							 185,  822,  834,
							 836, 3058, 3728,
							3731, 5383, 5407,
							5515, 5604,
						}
					},
				},
			},
			[103] = { -- Feral
				talents = {
					{22363, 22364, 22365},
					{19283, 18570, 18571},
					{22163, 22158, 22159},
					{21778, 18576, 18577},
					{21708, 18579, 21704},
					{21714, 21711, 22370},
					{21646, 21649, 21653},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 201,  203,  601,
							 602,  611,  612,
							 620,  820, 3053,
							3751, 5384, 5593,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 201,  203,  601,
							 602,  611,  612,
							 620,  820, 3053,
							3751, 5384, 5593,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 201,  203,  601,
							 602,  611,  612,
							 620,  820, 3053,
							3751, 5384, 5593,
						}
					},
				},
			},
			[104] = { -- Guardian
				talents = {
					{22419, 22418, 0},
					{19283, 18570, 18571},
					{22163, 22156, 22159},
					{21778, 18576, 18577},
					{21709, 21707, 22388},
					{22423, 21713, 22390},
					{22426, 22427, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  49,   51,   52,
							 194,  195,  196,
							 197,  842, 1237,
							3750, 5410,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  49,   51,   52,
							 194,  195,  196,
							 197,  842, 1237,
							3750, 5410,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  49,   51,   52,
							 194,  195,  196,
							 197,  842, 1237,
							3750, 5410,
						}
					},
				},
			},
			[105] = { -- Restoration
				talents = {
					{18569, 18574, 18572},
					{19283, 18570, 18571},
					{22366, 22367, 22160},
					{21778, 18576, 18577},
					{21710, 21705, 22421},
					{21716, 18585, 22422},
					{22403, 21651, 22404},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  59,  691,  692,
							 697,  700,  835,
							 838, 1215, 3048,
							5387, 5514,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  59,  691,  692,
							 697,  700,  835,
							 838, 1215, 3048,
							5387, 5514,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  59,  691,  692,
							 697,  700,  835,
							 838, 1215, 3048,
							5387, 5514,
						}
					},
				},
			},
			-- Demon Hunter
			[577] = { -- Havoc
				talents = {
					{21854, 22493, 22416},
					{21857, 22765, 22799},
					{22909, 22494, 21862},
					{21863, 21864, 21865},
					{21866, 21867, 21868},
					{21869, 21870, 22767},
					{21900, 21901, 22547},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 805,  806,  809,
							 811,  812,  813,
							1206, 1218, 5433,
							5523,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 805,  806,  809,
							 811,  812,  813,
							1206, 1218, 5433,
							5523,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 805,  806,  809,
							 811,  812,  813,
							1206, 1218, 5433,
							5523,
						}
					},
				},
			},
			[581] = { -- Vengeance
				talents = {
					{22502, 22503, 22504},
					{22505, 22766, 22507},
					{22324, 22541, 22540},
					{22508, 22509, 22770},
					{22546, 22510, 22511},
					{22512, 22513, 22768},
					{22543, 23464, 21902},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 814,  815,  816,
							 819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
							5520, 5521, 5522,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 814,  815,  816,
							 819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
							5520, 5521, 5522,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 814,  815,  816,
							 819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
							5520, 5521, 5522,
						}
					},
				},
			},
			-- Evoker
			[1467] = { -- Devastation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5556,
							5599,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5556,
							5599,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5556,
							5599,
						}
					},
				},
			},
			[1468] = { -- Preservation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5595,
							5598,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5595,
							5598,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5595,
							5598,
						}
					},
				},
			},
		}
	elseif Internal.Is100005 then
		specInfo = {
			version = 7,

			-- Warrior
			[71] = { -- Arms
				talents = {
					{22624, 22360, 22371},
					{19676, 22372, 22789},
					{22380, 22489, 19138},
					{15757, 22627, 22628},
					{22392, 22391, 22362},
					{22394, 22397, 22399},
					{21204, 22407, 21667},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  28,   29,   31,
							  32,   33,   34,
							3522, 3534, 5372,
							5376, 5547,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  28,   29,   31,
							  32,   33,   34,
							3522, 3534, 5372,
							5376, 5547,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  28,   29,   31,
							  32,   33,   34,
							3522, 3534, 5372,
							5376, 5547,
						}
					},
				},
			},
			[72] = { -- Fury
				talents = {
					{22632, 22633, 22491},
					{19676, 22625, 23093},
					{22379, 22381, 23372},
					{23097, 22627, 22382},
					{22383, 22393, 19140},
					{22396, 22398, 22400},
					{22405, 22402, 16037},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  25,  166,  170,
							 172,  177,  179,
							3528, 3533, 3735,
							5373, 5431, 5548,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  25,  166,  170,
							 172,  177,  179,
							3528, 3533, 3735,
							5373, 5431, 5548,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  25,  166,  170,
							 172,  177,  179,
							3528, 3533, 3735,
							5373, 5431, 5548,
						}
					},
				},
			},
			[73] = { -- Protection
				talents = {
					{15760, 15759, 15774},
					{19676, 22629, 22409},
					{22378, 22626, 23260},
					{23096, 22627, 22488},
					{22384, 22631, 22800},
					{22395, 22544, 22401},
					{23455, 22406, 23099},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  24,  167,  168,
							 171,  173,  175,
							 178,  831,  833,
							 845, 5374, 5432,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  24,  167,  168,
							 171,  173,  175,
							 178,  831,  833,
							 845, 5374, 5432,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  24,  167,  168,
							 171,  173,  175,
							 178,  831,  833,
							 845, 5374, 5432,
						}
					},
				},
			},
			-- Paladin
			[65] = { -- Holy
				talents = {
					{17565, 17567, 17569},
					{22176, 17575, 17577},
					{22179, 22180, 21811},
					{22433, 22434, 17593},
					{17597, 17599, 17601},
					{23191, 23680, 22484},
					{21201, 21671, 23681},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  82,   85,   86,
							  87,   88,  640,
							 642,  859, 3618,
							5421, 5501, 5537,
							5553,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  82,   85,   86,
							  87,   88,  640,
							 642,  859, 3618,
							5421, 5501, 5537,
							5553,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  82,   85,   86,
							  87,   88,  640,
							 642,  859, 3618,
							5421, 5501, 5537,
							5553,
						}
					},
				},
			},
			[66] = { -- Protection
				talents = {
					{22428, 22558, 23469},
					{22431, 22604, 23468},
					{22179, 22180, 21811},
					{22433, 22434, 22435},
					{17597, 17599, 17601},
					{22189, 22438, 23087},
					{23457, 21202, 22645},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  90,   91,   92,
							  93,   94,   97,
							 844,  860,  861,
							3474, 3475, 5536,
							5554,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  90,   91,   92,
							  93,   94,   97,
							 844,  860,  861,
							3474, 3475, 5536,
							5554,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  90,   91,   92,
							  93,   94,   97,
							 844,  860,  861,
							3474, 3475, 5536,
							5554,
						}
					},
				},
			},
			[70] = { -- Retribution
				talents = {
					{22590, 22557, 23467},
					{22319, 22592, 23466},
					{22179, 22180, 21811},
					{22433, 22434, 22183},
					{17597, 17599, 17601},
					{23167, 22483, 23086},
					{23456, 22215, 22634},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  81,  641,  751,
							 752,  753,  754,
							 755,  756,  757,
							 858, 5422, 5535,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  81,  641,  751,
							 752,  753,  754,
							 755,  756,  757,
							 858, 5422, 5535,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  81,  641,  751,
							 752,  753,  754,
							 755,  756,  757,
							 858, 5422, 5535,
						}
					},
				},
			},
			-- Hunter
			[253] = { -- Beast Mastery
				talents = {
					{22291, 22280, 22282},
					{22500, 22266, 22290},
					{19347, 19348, 23100},
					{22441, 22347, 22269},
					{22268, 22276, 22499},
					{19357, 22002, 23044},
					{22273, 21986, 22295},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 693,  824,  825,
							1214, 3599, 3600,
							3604, 3612, 3730,
							5418, 5441, 5444,
							5534,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 693,  824,  825,
							1214, 3599, 3600,
							3604, 3612, 3730,
							5418, 5441, 5444,
							5534,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 693,  824,  825,
							1214, 3599, 3600,
							3604, 3612, 3730,
							5418, 5441, 5444,
							5534,
						}
					},
				},
			},
			[254] = { -- Marksmanship
				talents = {
					{22279, 22501, 22289},
					{22495, 22497, 22498},
					{19347, 19348, 23100},
					{22267, 22286, 21998},
					{22268, 22276, 23463},
					{23063, 23104, 22287},
					{22274, 22308, 22288},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 649,  651,  653,
							 658,  659,  660,
							3614, 3729, 5419,
							5440, 5442, 5531,
							5533,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 649,  651,  653,
							 658,  659,  660,
							3614, 3729, 5419,
							5440, 5442, 5531,
							5533,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 649,  651,  653,
							 658,  659,  660,
							3614, 3729, 5419,
							5440, 5442, 5531,
							5533,
						}
					},
				},
			},
			[255] = { -- Survival
				talents = {
					{22275, 22283, 22296},
					{21997, 22769, 22297},
					{19347, 19348, 23100},
					{22277, 19361, 22299},
					{22268, 22276, 22499},
					{22300, 22278, 22271},
					{22272, 22301, 23105},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 661,  662,  663,
							 664,  665,  686,
							3607, 3609, 3610,
							5420, 5443, 5532,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 661,  662,  663,
							 664,  665,  686,
							3607, 3609, 3610,
							5420, 5443, 5532,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 661,  662,  663,
							 664,  665,  686,
							3607, 3609, 3610,
							5420, 5443, 5532,
						}
					},
				},
			},
			-- Rogue
			[259] = { -- Assassination
				talents = {
					{22337, 22338, 22339},
					{22331, 22332, 23022},
					{19239, 19240, 19241},
					{22340, 22122, 22123},
					{19245, 23037, 22115},
					{22343, 23015, 22344},
					{21186, 22133, 23174},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
				},
			},
			[260] = { -- Outlaw
				talents = {
					{22118, 22119, 22120},
					{23470, 19237, 19238},
					{19239, 19240, 19241},
					{22121, 22122, 22123},
					{23077, 22114, 22115},
					{21990, 23128, 19250},
					{22125, 23075, 23175},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 129,  135,  138,
							 139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 129,  135,  138,
							 139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 129,  135,  138,
							 139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
				},
			},
			[261] = { -- Subtlety
				talents = {
					{19233, 19234, 19235},
					{22331, 22332, 22333},
					{19239, 19240, 19241},
					{22128, 22122, 22123},
					{23078, 23036, 22115},
					{22335, 19249, 22336},
					{22132, 23183, 21188},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 136,  146,  153,
							 846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 136,  146,  153,
							 846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 136,  146,  153,
							 846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
				},
			},
			-- Priest
			[256] = { -- Discipline
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  98,  100,  109,
							 111,  114,  117,
							 123,  126,  855,
							5416, 5475, 5480,
							5483, 5487, 5498,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  98,  100,  109,
							 111,  114,  117,
							 123,  126,  855,
							5416, 5475, 5480,
							5483, 5487, 5498,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  98,  100,  109,
							 111,  114,  117,
							 123,  126,  855,
							5416, 5475, 5480,
							5483, 5487, 5498,
						}
					},
				},
			},
			[257] = { -- Holy
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 101,  108,  112,
							 115,  124,  127,
							1927, 5365, 5366,
							5476, 5478, 5479,
							5482, 5485, 5499,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 101,  108,  112,
							 115,  124,  127,
							1927, 5365, 5366,
							5476, 5478, 5479,
							5482, 5485, 5499,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 101,  108,  112,
							 115,  124,  127,
							1927, 5365, 5366,
							5476, 5478, 5479,
							5482, 5485, 5499,
						}
					},
				},
			},
			[258] = { -- Shadow
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 106,  113,  739,
							 763, 5381, 5447,
							5474, 5477, 5481,
							5484, 5486, 5500,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 106,  113,  739,
							 763, 5381, 5447,
							5474, 5477, 5481,
							5484, 5486, 5500,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 106,  113,  739,
							 763, 5381, 5447,
							5474, 5477, 5481,
							5484, 5486, 5500,
						}
					},
				},
			},
			-- Death Knight
			[250] = { -- Blood
				talents = {
					{19165, 19166, 23454},
					{19218, 19219, 19220},
					{19221, 22134, 22135},
					{22013, 22014, 22015},
					{19227, 19226, 19228},
					{19230, 19231, 19232},
					{21207, 21208, 21209},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 204,  205,  206,
							 607,  608,  609,
							 841, 3441, 3511,
							5425, 5513,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 204,  205,  206,
							 607,  608,  609,
							 841, 3441, 3511,
							5425, 5513,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 204,  205,  206,
							 607,  608,  609,
							 841, 3441, 3511,
							5425, 5513,
						}
					},
				},
			},
			[251] = { -- Frost
				talents = {
					{22016, 22017, 22018},
					{22019, 22020, 22021},
					{22515, 22517, 22519},
					{22521, 22523, 22525},
					{22527, 22530, 23373},
					{22531, 22533, 22535},
					{22023, 22109, 22537},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 701,  702, 3439,
							3512, 3743, 5424,
							5429, 5435, 5510,
							5512,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 701,  702, 3439,
							3512, 3743, 5424,
							5429, 5435, 5510,
							5512,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 701,  702, 3439,
							3512, 3743, 5424,
							5429, 5435, 5510,
							5512,
						}
					},
				},
			},
			[252] = { -- Unholy
				talents = {
					{22024, 22025, 22026},
					{22027, 22028, 22029},
					{22516, 22518, 22520},
					{22522, 22524, 22526},
					{22528, 22529, 23373},
					{22532, 22534, 22536},
					{22030, 22110, 22538},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  40,   41,  149,
							 152, 3437, 3746,
							3747, 5423, 5430,
							5436, 5511,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  40,   41,  149,
							 152, 3437, 3746,
							3747, 5423, 5430,
							5436, 5511,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  40,   41,  149,
							 152, 3437, 3746,
							3747, 5423, 5430,
							5436, 5511,
						}
					},
				},
			},
			-- Shaman
			[262] = { -- Elemental
				talents = {
					{22356, 22357, 22358},
					{23108, 23460, 23190},
					{23162, 23163, 23164},
					{19271, 19272, 19273},
					{22144, 22172, 21966},
					{22145, 19266, 23111},
					{21198, 22153, 21675},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 727,  728,  730,
							3062, 3488, 3490,
							3491, 3620, 3621,
							5415, 5457, 5519,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 727,  728,  730,
							3062, 3488, 3490,
							3491, 3620, 3621,
							5415, 5457, 5519,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 727,  728,  730,
							3062, 3488, 3490,
							3491, 3620, 3621,
							5415, 5457, 5519,
						}
					},
				},
			},
			[263] = { -- Enhancement
				talents = {
					{22354, 22355, 22353},
					{22636, 23462, 23109},
					{23165, 19260, 23166},
					{23089, 23090, 22171},
					{22144, 22149, 21966},
					{21973, 22352, 22351},
					{21970, 22977, 21972},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 721,  722,  725,
							1944, 3487, 3489,
							3492, 3519, 3622,
							3623, 5414, 5438,
							5518, 5527,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 721,  722,  725,
							1944, 3487, 3489,
							3492, 3519, 3622,
							3623, 5414, 5438,
							5518, 5527,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 721,  722,  725,
							1944, 3487, 3489,
							3492, 3519, 3622,
							3623, 5414, 5438,
							5518, 5527,
						}
					},
				},
			},
			[264] = { -- Restoration
				talents = {
					{19262, 19263, 19264},
					{19259, 23461, 21963},
					{19275, 23110, 22127},
					{22152, 22322, 22323},
					{22144, 19269, 21966},
					{19265, 21971, 21968},
					{21969, 21199, 22359},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 707,  708,  712,
							 714,  715, 1930,
							3520, 3755, 5388,
							5437, 5458, 5528,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 707,  708,  712,
							 714,  715, 1930,
							3520, 3755, 5388,
							5437, 5458, 5528,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 707,  708,  712,
							 714,  715, 1930,
							3520, 3755, 5388,
							5437, 5458, 5528,
						}
					},
				},
			},
			-- Mage
			[62] = { -- Arcane
				talents = {
					{22458, 22461, 22464},
					{23072, 22443, 16025},
					{22444, 22445, 22447},
					{22453, 22467, 22470},
					{22907, 22448, 22471},
					{22455, 22449, 22474},
					{21630, 21144, 21145},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  61,  635,  637,
							3442, 3517, 3529,
							3531, 5397, 5488,
							5491, 5492,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  61,  635,  637,
							3442, 3517, 3529,
							3531, 5397, 5488,
							5491, 5492,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  61,  635,  637,
							3442, 3517, 3529,
							3531, 5397, 5488,
							5491, 5492,
						}
					},
				},
			},
			[63] = { -- Fire
				talents = {
					{22456, 22459, 22462},
					{23071, 22443, 23074},
					{22444, 22445, 22447},
					{22450, 22465, 22468},
					{22904, 22448, 22471},
					{22451, 23362, 22472},
					{21631, 22220, 21633},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  53,  644,  646,
							 647,  648,  828,
							5389, 5489, 5493,
							5495,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  53,  644,  646,
							 647,  648,  828,
							5389, 5489, 5493,
							5495,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  53,  644,  646,
							 647,  648,  828,
							5389, 5489, 5493,
							5495,
						}
					},
				},
			},
			[64] = { -- Frost
				talents = {
					{22457, 22460, 22463},
					{22442, 22443, 23073},
					{22444, 22445, 22447},
					{22452, 22466, 22469},
					{22446, 22448, 22471},
					{22454, 23176, 22473},
					{21632, 22309, 21634},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  66,  632,  634,
							3443, 3532, 5390,
							5490, 5494, 5496,
							5497,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  66,  632,  634,
							3443, 3532, 5390,
							5490, 5494, 5496,
							5497,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  66,  632,  634,
							3443, 3532, 5390,
							5490, 5494, 5496,
							5497,
						}
					},
				},
			},
			-- Warlock
			[265] = { -- Affliction
				talents = {
					{22039, 23140, 23141},
					{22044, 21180, 22089},
					{19280, 19285, 19286},
					{19279, 19292, 22046},
					{22047, 19291, 23465},
					{23139, 23159, 19295},
					{19284, 19281, 19293},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  11,   12,   15,
							  16,   17,   18,
							  19,   20, 5379,
							5386, 5392, 5506,
							5543, 5546,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  11,   12,   15,
							  16,   17,   18,
							  19,   20, 5379,
							5386, 5392, 5506,
							5543, 5546,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  11,   12,   15,
							  16,   17,   18,
							  19,   20, 5379,
							5386, 5392, 5506,
							5543, 5546,
						}
					},
				},
			},
			[266] = { -- Demonology
				talents = {
					{19290, 22048, 23138},
					{22045, 21694, 23158},
					{19280, 19285, 19286},
					{22477, 22042, 23160},
					{22047, 19291, 23465},
					{23147, 23146, 21717},
					{23161, 22479, 23091},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 156,  158,  162,
							 165, 1213, 3505,
							3506, 3624, 3625,
							3626, 5394, 5400,
							5505, 5545,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 156,  158,  162,
							 165, 1213, 3505,
							3506, 3624, 3625,
							3626, 5394, 5400,
							5505, 5545,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 156,  158,  162,
							 165, 1213, 3505,
							3506, 3624, 3625,
							3626, 5394, 5400,
							5505, 5545,
						}
					},
				},
			},
			[267] = { -- Destruction
				talents = {
					{22038, 22090, 22040},
					{23148, 21695, 23157},
					{19280, 19285, 19286},
					{22480, 22043, 23143},
					{22047, 19291, 23465},
					{23155, 23156, 19295},
					{19284, 23144, 23092},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 157,  159,  164,
							3502, 3508, 3509,
							3510, 5382, 5393,
							5401, 5507, 5544,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 157,  159,  164,
							3502, 3508, 3509,
							3510, 5382, 5393,
							5401, 5507, 5544,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 157,  159,  164,
							3502, 3508, 3509,
							3510, 5382, 5393,
							5401, 5507, 5544,
						}
					},
				},
			},
			-- Monk
			[268] = { -- Brewmaster
				talents = {
					{23106, 19820, 20185},
					{19304, 19818, 19302},
					{22099, 22097, 19992},
					{19993, 19994, 19995},
					{20174, 23363, 20175},
					{19819, 20184, 22103},
					{22106, 22104, 22108},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 666,  667,  668,
							 669,  670,  671,
							 672,  673,  765,
							 843, 1958, 5417,
							5538, 5541, 5542,
							5552,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 666,  667,  668,
							 669,  670,  671,
							 672,  673,  765,
							 843, 1958, 5417,
							5538, 5541, 5542,
							5552,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 666,  667,  668,
							 669,  670,  671,
							 672,  673,  765,
							 843, 1958, 5417,
							5538, 5541, 5542,
							5552,
						}
					},
				},
			},
			[270] = { -- Mistweaver
				talents = {
					{19823, 19820, 20185},
					{19304, 19818, 19302},
					{22168, 22167, 22166},
					{19993, 22219, 19995},
					{23371, 20173, 20175},
					{23107, 22101, 0},
					{22218, 22169, 22170},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  70,  678,  679,
							 680,  682,  683,
							1928, 3732, 5395,
							5398, 5402, 5508,
							5539, 5551,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  70,  678,  679,
							 680,  682,  683,
							1928, 3732, 5395,
							5398, 5402, 5508,
							5539, 5551,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  70,  678,  679,
							 680,  682,  683,
							1928, 3732, 5395,
							5398, 5402, 5508,
							5539, 5551,
						}
					},
				},
			},
			[269] = { -- Windwalker
				talents = {
					{23106, 19820, 20185},
					{19304, 19818, 19302},
					{22098, 19771, 22096},
					{19993, 23364, 19995},
					{23258, 20173, 20175},
					{22093, 23122, 22102},
					{22107, 22105, 21191},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  77,  675,  852,
							3050, 3052, 3734,
							3737, 3744, 3745,
							5448, 5540,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  77,  675,  852,
							3050, 3052, 3734,
							3737, 3744, 3745,
							5448, 5540,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  77,  675,  852,
							3050, 3052, 3734,
							3737, 3744, 3745,
							5448, 5540,
						}
					},
				},
			},
			-- Druid
			[102] = { -- Balance
				talents = {
					{22385, 22386, 22387},
					{19283, 18570, 18571},
					{22155, 22157, 22159},
					{21778, 18576, 18577},
					{18580, 21706, 21702},
					{22389, 21712, 22165},
					{21648, 21193, 21655},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 180,  182,  184,
							 185,  822,  834,
							 836, 3058, 3728,
							3731, 5383, 5407,
							5503, 5515, 5526,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 180,  182,  184,
							 185,  822,  834,
							 836, 3058, 3728,
							3731, 5383, 5407,
							5503, 5515, 5526,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 180,  182,  184,
							 185,  822,  834,
							 836, 3058, 3728,
							3731, 5383, 5407,
							5503, 5515, 5526,
						}
					},
				},
			},
			[103] = { -- Feral
				talents = {
					{22363, 22364, 22365},
					{19283, 18570, 18571},
					{22163, 22158, 22159},
					{21778, 18576, 18577},
					{21708, 18579, 21704},
					{21714, 21711, 22370},
					{21646, 21649, 21653},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 201,  203,  601,
							 602,  611,  612,
							 620,  820, 3053,
							3751, 5384, 5525,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 201,  203,  601,
							 602,  611,  612,
							 620,  820, 3053,
							3751, 5384, 5525,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 201,  203,  601,
							 602,  611,  612,
							 620,  820, 3053,
							3751, 5384, 5525,
						}
					},
				},
			},
			[104] = { -- Guardian
				talents = {
					{22419, 22418, 22420},
					{19283, 18570, 18571},
					{22163, 22156, 22159},
					{21778, 18576, 18577},
					{21709, 21707, 22388},
					{22423, 21713, 22390},
					{22426, 22427, 22425},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  49,   50,   51,
							  52,  192,  193,
							 194,  195,  196,
							 197,  842, 1237,
							3750, 5410, 5524,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  49,   50,   51,
							  52,  192,  193,
							 194,  195,  196,
							 197,  842, 1237,
							3750, 5410, 5524,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  49,   50,   51,
							  52,  192,  193,
							 194,  195,  196,
							 197,  842, 1237,
							3750, 5410, 5524,
						}
					},
				},
			},
			[105] = { -- Restoration
				talents = {
					{18569, 18574, 18572},
					{19283, 18570, 18571},
					{22366, 22367, 22160},
					{21778, 18576, 18577},
					{21710, 21705, 22421},
					{21716, 18585, 22422},
					{22403, 21651, 22404},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  59,  691,  692,
							 697,  700,  835,
							 838, 1215, 3048,
							5387, 5504, 5514,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  59,  691,  692,
							 697,  700,  835,
							 838, 1215, 3048,
							5387, 5504, 5514,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  59,  691,  692,
							 697,  700,  835,
							 838, 1215, 3048,
							5387, 5504, 5514,
						}
					},
				},
			},
			-- Demon Hunter
			[577] = { -- Havoc
				talents = {
					{21854, 22493, 22416},
					{21857, 22765, 22799},
					{22909, 22494, 21862},
					{21863, 21864, 21865},
					{21866, 21867, 21868},
					{21869, 21870, 22767},
					{21900, 21901, 22547},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 805,  806,  809,
							 811,  812,  813,
							1206, 1218, 5433,
							5523,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 805,  806,  809,
							 811,  812,  813,
							1206, 1218, 5433,
							5523,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 805,  806,  809,
							 811,  812,  813,
							1206, 1218, 5433,
							5523,
						}
					},
				},
			},
			[581] = { -- Vengeance
				talents = {
					{22502, 22503, 22504},
					{22505, 22766, 22507},
					{22324, 22541, 22540},
					{22508, 22509, 22770},
					{22546, 22510, 22511},
					{22512, 22513, 22768},
					{22543, 23464, 21902},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 814,  815,  816,
							 819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
							5520, 5521, 5522,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 814,  815,  816,
							 819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
							5520, 5521, 5522,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 814,  815,  816,
							 819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
							5520, 5521, 5522,
						}
					},
				},
			},
			-- Evoker
			[1467] = { -- Devastation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5509,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5509,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5509,
						}
					},
				},
			},
			[1468] = { -- Preservation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5502,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5502,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5502,
						}
					},
				},
			},
		}
	elseif Internal.Is100000 then
		specInfo = {
			version = 6,

			-- Warrior
			[71] = { -- Arms
				talents = {
					{22624, 22360, 22371},
					{19676, 22372, 22789},
					{22380, 22489, 19138},
					{15757, 22627, 22628},
					{22392, 22391, 22362},
					{22394, 22397, 22399},
					{21204, 22407, 21667},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  28,   29,   31,
							  32,   33,   34,
							3522, 3534, 5372,
							5376, 5547,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  28,   29,   31,
							  32,   33,   34,
							3522, 3534, 5372,
							5376, 5547,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  28,   29,   31,
							  32,   33,   34,
							3522, 3534, 5372,
							5376, 5547,
						}
					},
				},
			},
			[72] = { -- Fury
				talents = {
					{22632, 22633, 22491},
					{19676, 22625, 23093},
					{22379, 22381, 23372},
					{23097, 22627, 22382},
					{22383, 22393, 19140},
					{22396, 22398, 22400},
					{22405, 22402, 16037},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  25,  166,  170,
							 172,  177,  179,
							3528, 3533, 3735,
							5373, 5431, 5548,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  25,  166,  170,
							 172,  177,  179,
							3528, 3533, 3735,
							5373, 5431, 5548,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  25,  166,  170,
							 172,  177,  179,
							3528, 3533, 3735,
							5373, 5431, 5548,
						}
					},
				},
			},
			[73] = { -- Protection
				talents = {
					{15760, 15759, 15774},
					{19676, 22629, 22409},
					{22378, 22626, 23260},
					{23096, 22627, 22488},
					{22384, 22631, 22800},
					{22395, 22544, 22401},
					{23455, 22406, 23099},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  24,  167,  168,
							 171,  173,  175,
							 178,  831,  833,
							 845, 5374, 5432,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  24,  167,  168,
							 171,  173,  175,
							 178,  831,  833,
							 845, 5374, 5432,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  24,  167,  168,
							 171,  173,  175,
							 178,  831,  833,
							 845, 5374, 5432,
						}
					},
				},
			},
			-- Paladin
			[65] = { -- Holy
				talents = {
					{17565, 17567, 17569},
					{22176, 17575, 17577},
					{22179, 22180, 21811},
					{22433, 22434, 17593},
					{17597, 17599, 17601},
					{23191, 23680, 22484},
					{21201, 21671, 23681},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  82,   85,   86,
							  87,   88,  640,
							 642,  859, 3618,
							5421, 5501, 5537,
							5553,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  82,   85,   86,
							  87,   88,  640,
							 642,  859, 3618,
							5421, 5501, 5537,
							5553,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  82,   85,   86,
							  87,   88,  640,
							 642,  859, 3618,
							5421, 5501, 5537,
							5553,
						}
					},
				},
			},
			[66] = { -- Protection
				talents = {
					{22428, 22558, 23469},
					{22431, 22604, 23468},
					{22179, 22180, 21811},
					{22433, 22434, 22435},
					{17597, 17599, 17601},
					{22189, 22438, 23087},
					{23457, 21202, 22645},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  90,   91,   92,
							  93,   94,   97,
							 844,  860,  861,
							3474, 3475, 5536,
							5554,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  90,   91,   92,
							  93,   94,   97,
							 844,  860,  861,
							3474, 3475, 5536,
							5554,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  90,   91,   92,
							  93,   94,   97,
							 844,  860,  861,
							3474, 3475, 5536,
							5554,
						}
					},
				},
			},
			[70] = { -- Retribution
				talents = {
					{22590, 22557, 23467},
					{22319, 22592, 23466},
					{22179, 22180, 21811},
					{22433, 22434, 22183},
					{17597, 17599, 17601},
					{23167, 22483, 23086},
					{23456, 22215, 22634},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  81,  641,  751,
							 752,  753,  754,
							 755,  756,  757,
							 858, 5422, 5535,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  81,  641,  751,
							 752,  753,  754,
							 755,  756,  757,
							 858, 5422, 5535,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  81,  641,  751,
							 752,  753,  754,
							 755,  756,  757,
							 858, 5422, 5535,
						}
					},
				},
			},
			-- Hunter
			[253] = { -- Beast Mastery
				talents = {
					{22291, 22280, 22282},
					{22500, 22266, 22290},
					{19347, 19348, 23100},
					{22441, 22347, 22269},
					{22268, 22276, 22499},
					{19357, 22002, 23044},
					{22273, 21986, 22295},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 693,  824,  825,
							1214, 3599, 3600,
							3604, 3612, 3730,
							5418, 5441, 5444,
							5534,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 693,  824,  825,
							1214, 3599, 3600,
							3604, 3612, 3730,
							5418, 5441, 5444,
							5534,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 693,  824,  825,
							1214, 3599, 3600,
							3604, 3612, 3730,
							5418, 5441, 5444,
							5534,
						}
					},
				},
			},
			[254] = { -- Marksmanship
				talents = {
					{22279, 22501, 22289},
					{22495, 22497, 22498},
					{19347, 19348, 23100},
					{22267, 22286, 21998},
					{22268, 22276, 23463},
					{23063, 23104, 22287},
					{22274, 22308, 22288},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 649,  651,  653,
							 658,  659,  660,
							3614, 3729, 5419,
							5440, 5442, 5531,
							5533,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 649,  651,  653,
							 658,  659,  660,
							3614, 3729, 5419,
							5440, 5442, 5531,
							5533,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 649,  651,  653,
							 658,  659,  660,
							3614, 3729, 5419,
							5440, 5442, 5531,
							5533,
						}
					},
				},
			},
			[255] = { -- Survival
				talents = {
					{22275, 22283, 22296},
					{21997, 22769, 22297},
					{19347, 19348, 23100},
					{22277, 19361, 22299},
					{22268, 22276, 22499},
					{22300, 22278, 22271},
					{22272, 22301, 23105},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 661,  662,  663,
							 664,  665,  686,
							3607, 3609, 3610,
							5420, 5443, 5532,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 661,  662,  663,
							 664,  665,  686,
							3607, 3609, 3610,
							5420, 5443, 5532,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 661,  662,  663,
							 664,  665,  686,
							3607, 3609, 3610,
							5420, 5443, 5532,
						}
					},
				},
			},
			-- Rogue
			[259] = { -- Assassination
				talents = {
					{22337, 22338, 22339},
					{22331, 22332, 23022},
					{19239, 19240, 19241},
					{22340, 22122, 22123},
					{19245, 23037, 22115},
					{22343, 23015, 22344},
					{21186, 22133, 23174},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 141,  147,  830,
							3448, 3479, 3480,
							5405, 5408, 5517,
							5530, 5550,
						}
					},
				},
			},
			[260] = { -- Outlaw
				talents = {
					{22118, 22119, 22120},
					{23470, 19237, 19238},
					{19239, 19240, 19241},
					{22121, 22122, 22123},
					{23077, 22114, 22115},
					{21990, 23128, 19250},
					{22125, 23075, 23175},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 129,  135,  138,
							 139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 129,  135,  138,
							 139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 129,  135,  138,
							 139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5516,
							5549,
						}
					},
				},
			},
			[261] = { -- Subtlety
				talents = {
					{19233, 19234, 19235},
					{22331, 22332, 22333},
					{19239, 19240, 19241},
					{22128, 22122, 22123},
					{23078, 23036, 22115},
					{22335, 19249, 22336},
					{22132, 23183, 21188},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 136,  146,  153,
							 846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 136,  146,  153,
							 846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 136,  146,  153,
							 846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411, 5529,
						}
					},
				},
			},
			-- Priest
			[256] = { -- Discipline
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  98,  100,  109,
							 111,  114,  117,
							 123,  126,  855,
							1244, 5416, 5475,
							5480, 5483, 5487,
							5498,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  98,  100,  109,
							 111,  114,  117,
							 123,  126,  855,
							1244, 5416, 5475,
							5480, 5483, 5487,
							5498,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  98,  100,  109,
							 111,  114,  117,
							 123,  126,  855,
							1244, 5416, 5475,
							5480, 5483, 5487,
							5498,
						}
					},
				},
			},
			[257] = { -- Holy
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 101,  108,  112,
							 115,  124,  127,
							1927, 5365, 5366,
							5476, 5478, 5479,
							5482, 5485, 5499,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 101,  108,  112,
							 115,  124,  127,
							1927, 5365, 5366,
							5476, 5478, 5479,
							5482, 5485, 5499,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 101,  108,  112,
							 115,  124,  127,
							1927, 5365, 5366,
							5476, 5478, 5479,
							5482, 5485, 5499,
						}
					},
				},
			},
			[258] = { -- Shadow
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 106,  113,  739,
							 763, 5381, 5447,
							5474, 5477, 5481,
							5484, 5486, 5500,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 106,  113,  739,
							 763, 5381, 5447,
							5474, 5477, 5481,
							5484, 5486, 5500,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 106,  113,  739,
							 763, 5381, 5447,
							5474, 5477, 5481,
							5484, 5486, 5500,
						}
					},
				},
			},
			-- Death Knight
			[250] = { -- Blood
				talents = {
					{19165, 19166, 23454},
					{19218, 19219, 19220},
					{19221, 22134, 22135},
					{22013, 22014, 22015},
					{19227, 19226, 19228},
					{19230, 19231, 19232},
					{21207, 21208, 21209},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 204,  205,  206,
							 607,  608,  609,
							 841, 3441, 3511,
							5425, 5513,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 204,  205,  206,
							 607,  608,  609,
							 841, 3441, 3511,
							5425, 5513,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 204,  205,  206,
							 607,  608,  609,
							 841, 3441, 3511,
							5425, 5513,
						}
					},
				},
			},
			[251] = { -- Frost
				talents = {
					{22016, 22017, 22018},
					{22019, 22020, 22021},
					{22515, 22517, 22519},
					{22521, 22523, 22525},
					{22527, 22530, 23373},
					{22531, 22533, 22535},
					{22023, 22109, 22537},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 701,  702, 3439,
							3512, 3743, 5424,
							5429, 5435, 5510,
							5512,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 701,  702, 3439,
							3512, 3743, 5424,
							5429, 5435, 5510,
							5512,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 701,  702, 3439,
							3512, 3743, 5424,
							5429, 5435, 5510,
							5512,
						}
					},
				},
			},
			[252] = { -- Unholy
				talents = {
					{22024, 22025, 22026},
					{22027, 22028, 22029},
					{22516, 22518, 22520},
					{22522, 22524, 22526},
					{22528, 22529, 23373},
					{22532, 22534, 22536},
					{22030, 22110, 22538},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  40,   41,  149,
							 152, 3437, 3746,
							3747, 5423, 5430,
							5436, 5511,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  40,   41,  149,
							 152, 3437, 3746,
							3747, 5423, 5430,
							5436, 5511,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  40,   41,  149,
							 152, 3437, 3746,
							3747, 5423, 5430,
							5436, 5511,
						}
					},
				},
			},
			-- Shaman
			[262] = { -- Elemental
				talents = {
					{22356, 22357, 22358},
					{23108, 23460, 23190},
					{23162, 23163, 23164},
					{19271, 19272, 19273},
					{22144, 22172, 21966},
					{22145, 19266, 23111},
					{21198, 22153, 21675},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 727,  728,  730,
							3062, 3488, 3490,
							3491, 3620, 3621,
							5415, 5457, 5519,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 727,  728,  730,
							3062, 3488, 3490,
							3491, 3620, 3621,
							5415, 5457, 5519,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 727,  728,  730,
							3062, 3488, 3490,
							3491, 3620, 3621,
							5415, 5457, 5519,
						}
					},
				},
			},
			[263] = { -- Enhancement
				talents = {
					{22354, 22355, 22353},
					{22636, 23462, 23109},
					{23165, 19260, 23166},
					{23089, 23090, 22171},
					{22144, 22149, 21966},
					{21973, 22352, 22351},
					{21970, 22977, 21972},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 721,  722,  725,
							1944, 3487, 3489,
							3492, 3519, 3622,
							3623, 5414, 5438,
							5518, 5527,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 721,  722,  725,
							1944, 3487, 3489,
							3492, 3519, 3622,
							3623, 5414, 5438,
							5518, 5527,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 721,  722,  725,
							1944, 3487, 3489,
							3492, 3519, 3622,
							3623, 5414, 5438,
							5518, 5527,
						}
					},
				},
			},
			[264] = { -- Restoration
				talents = {
					{19262, 19263, 19264},
					{19259, 23461, 21963},
					{19275, 23110, 22127},
					{22152, 22322, 22323},
					{22144, 19269, 21966},
					{19265, 21971, 21968},
					{21969, 21199, 22359},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 707,  708,  712,
							 714,  715, 1930,
							3520, 3755, 3756,
							5388, 5437, 5458,
							5528,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 707,  708,  712,
							 714,  715, 1930,
							3520, 3755, 3756,
							5388, 5437, 5458,
							5528,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 707,  708,  712,
							 714,  715, 1930,
							3520, 3755, 3756,
							5388, 5437, 5458,
							5528,
						}
					},
				},
			},
			-- Mage
			[62] = { -- Arcane
				talents = {
					{22458, 22461, 22464},
					{23072, 22443, 16025},
					{22444, 22445, 22447},
					{22453, 22467, 22470},
					{22907, 22448, 22471},
					{22455, 22449, 22474},
					{21630, 21144, 21145},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  61,  635,  637,
							3442, 3517, 3529,
							3531, 5397, 5488,
							5491, 5492,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  61,  635,  637,
							3442, 3517, 3529,
							3531, 5397, 5488,
							5491, 5492,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  61,  635,  637,
							3442, 3517, 3529,
							3531, 5397, 5488,
							5491, 5492,
						}
					},
				},
			},
			[63] = { -- Fire
				talents = {
					{22456, 22459, 22462},
					{23071, 22443, 23074},
					{22444, 22445, 22447},
					{22450, 22465, 22468},
					{22904, 22448, 22471},
					{22451, 23362, 22472},
					{21631, 22220, 21633},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  53,  644,  646,
							 647,  648,  828,
							5389, 5489, 5493,
							5495,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  53,  644,  646,
							 647,  648,  828,
							5389, 5489, 5493,
							5495,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  53,  644,  646,
							 647,  648,  828,
							5389, 5489, 5493,
							5495,
						}
					},
				},
			},
			[64] = { -- Frost
				talents = {
					{22457, 22460, 22463},
					{22442, 22443, 23073},
					{22444, 22445, 22447},
					{22452, 22466, 22469},
					{22446, 22448, 22471},
					{22454, 23176, 22473},
					{21632, 22309, 21634},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  66,  632,  634,
							3443, 3532, 5390,
							5490, 5494, 5496,
							5497,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  66,  632,  634,
							3443, 3532, 5390,
							5490, 5494, 5496,
							5497,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  66,  632,  634,
							3443, 3532, 5390,
							5490, 5494, 5496,
							5497,
						}
					},
				},
			},
			-- Warlock
			[265] = { -- Affliction
				talents = {
					{22039, 23140, 23141},
					{22044, 21180, 22089},
					{19280, 19285, 19286},
					{19279, 19292, 22046},
					{22047, 19291, 23465},
					{23139, 23159, 19295},
					{19284, 19281, 19293},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  11,   12,   15,
							  16,   17,   18,
							  19,   20, 5379,
							5386, 5392, 5506,
							5543, 5546,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  11,   12,   15,
							  16,   17,   18,
							  19,   20, 5379,
							5386, 5392, 5506,
							5543, 5546,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  11,   12,   15,
							  16,   17,   18,
							  19,   20, 5379,
							5386, 5392, 5506,
							5543, 5546,
						}
					},
				},
			},
			[266] = { -- Demonology
				talents = {
					{19290, 22048, 23138},
					{22045, 21694, 23158},
					{19280, 19285, 19286},
					{22477, 22042, 23160},
					{22047, 19291, 23465},
					{23147, 23146, 21717},
					{23161, 22479, 23091},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 156,  158,  162,
							 165, 1213, 3505,
							3506, 3624, 3625,
							3626, 5394, 5400,
							5505, 5545,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 156,  158,  162,
							 165, 1213, 3505,
							3506, 3624, 3625,
							3626, 5394, 5400,
							5505, 5545,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 156,  158,  162,
							 165, 1213, 3505,
							3506, 3624, 3625,
							3626, 5394, 5400,
							5505, 5545,
						}
					},
				},
			},
			[267] = { -- Destruction
				talents = {
					{22038, 22090, 22040},
					{23148, 21695, 23157},
					{19280, 19285, 19286},
					{22480, 22043, 23143},
					{22047, 19291, 23465},
					{23155, 23156, 19295},
					{19284, 23144, 23092},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 157,  159,  164,
							3502, 3508, 3509,
							3510, 5382, 5393,
							5401, 5507, 5544,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 157,  159,  164,
							3502, 3508, 3509,
							3510, 5382, 5393,
							5401, 5507, 5544,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 157,  159,  164,
							3502, 3508, 3509,
							3510, 5382, 5393,
							5401, 5507, 5544,
						}
					},
				},
			},
			-- Monk
			[268] = { -- Brewmaster
				talents = {
					{23106, 19820, 20185},
					{19304, 19818, 19302},
					{22099, 22097, 19992},
					{19993, 19994, 19995},
					{20174, 23363, 20175},
					{19819, 20184, 22103},
					{22106, 22104, 22108},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 666,  667,  668,
							 669,  670,  671,
							 672,  673,  765,
							 843, 1958, 5417,
							5538, 5541, 5542,
							5552,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 666,  667,  668,
							 669,  670,  671,
							 672,  673,  765,
							 843, 1958, 5417,
							5538, 5541, 5542,
							5552,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 666,  667,  668,
							 669,  670,  671,
							 672,  673,  765,
							 843, 1958, 5417,
							5538, 5541, 5542,
							5552,
						}
					},
				},
			},
			[270] = { -- Mistweaver
				talents = {
					{19823, 19820, 20185},
					{19304, 19818, 19302},
					{22168, 22167, 22166},
					{19993, 22219, 19995},
					{23371, 20173, 20175},
					{23107, 22101, 0},
					{22218, 22169, 22170},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  70,  678,  679,
							 680,  682,  683,
							1928, 3732, 5395,
							5398, 5402, 5508,
							5539, 5551,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  70,  678,  679,
							 680,  682,  683,
							1928, 3732, 5395,
							5398, 5402, 5508,
							5539, 5551,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  70,  678,  679,
							 680,  682,  683,
							1928, 3732, 5395,
							5398, 5402, 5508,
							5539, 5551,
						}
					},
				},
			},
			[269] = { -- Windwalker
				talents = {
					{23106, 19820, 20185},
					{19304, 19818, 19302},
					{22098, 19771, 22096},
					{19993, 23364, 19995},
					{23258, 20173, 20175},
					{22093, 23122, 22102},
					{22107, 22105, 21191},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  77,  675,  852,
							3050, 3052, 3734,
							3737, 3744, 3745,
							5448, 5540,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  77,  675,  852,
							3050, 3052, 3734,
							3737, 3744, 3745,
							5448, 5540,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  77,  675,  852,
							3050, 3052, 3734,
							3737, 3744, 3745,
							5448, 5540,
						}
					},
				},
			},
			-- Druid
			[102] = { -- Balance
				talents = {
					{22385, 22386, 22387},
					{19283, 18570, 18571},
					{22155, 22157, 22159},
					{21778, 18576, 18577},
					{18580, 21706, 21702},
					{22389, 21712, 22165},
					{21648, 21193, 21655},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 180,  182,  184,
							 185,  822,  834,
							 836, 3058, 3728,
							3731, 5383, 5407,
							5503, 5515, 5526,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 180,  182,  184,
							 185,  822,  834,
							 836, 3058, 3728,
							3731, 5383, 5407,
							5503, 5515, 5526,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 180,  182,  184,
							 185,  822,  834,
							 836, 3058, 3728,
							3731, 5383, 5407,
							5503, 5515, 5526,
						}
					},
				},
			},
			[103] = { -- Feral
				talents = {
					{22363, 22364, 22365},
					{19283, 18570, 18571},
					{22163, 22158, 22159},
					{21778, 18576, 18577},
					{21708, 18579, 21704},
					{21714, 21711, 22370},
					{21646, 21649, 21653},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 201,  203,  601,
							 602,  611,  612,
							 620,  820, 3053,
							3751, 5384, 5525,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 201,  203,  601,
							 602,  611,  612,
							 620,  820, 3053,
							3751, 5384, 5525,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 201,  203,  601,
							 602,  611,  612,
							 620,  820, 3053,
							3751, 5384, 5525,
						}
					},
				},
			},
			[104] = { -- Guardian
				talents = {
					{22419, 22418, 22420},
					{19283, 18570, 18571},
					{22163, 22156, 22159},
					{21778, 18576, 18577},
					{21709, 21707, 22388},
					{22423, 21713, 22390},
					{22426, 22427, 22425},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  49,   50,   51,
							  52,  192,  193,
							 194,  195,  196,
							 197,  842, 1237,
							3750, 5410, 5524,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  49,   50,   51,
							  52,  192,  193,
							 194,  195,  196,
							 197,  842, 1237,
							3750, 5410, 5524,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  49,   50,   51,
							  52,  192,  193,
							 194,  195,  196,
							 197,  842, 1237,
							3750, 5410, 5524,
						}
					},
				},
			},
			[105] = { -- Restoration
				talents = {
					{18569, 18574, 18572},
					{19283, 18570, 18571},
					{22366, 22367, 22160},
					{21778, 18576, 18577},
					{21710, 21705, 22421},
					{21716, 18585, 22422},
					{22403, 21651, 22404},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							  59,  691,  692,
							 697,  700,  835,
							 838, 1215, 3048,
							5387, 5504, 5514,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							  59,  691,  692,
							 697,  700,  835,
							 838, 1215, 3048,
							5387, 5504, 5514,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							  59,  691,  692,
							 697,  700,  835,
							 838, 1215, 3048,
							5387, 5504, 5514,
						}
					},
				},
			},
			-- Demon Hunter
			[577] = { -- Havoc
				talents = {
					{21854, 22493, 22416},
					{21857, 22765, 22799},
					{22909, 22494, 21862},
					{21863, 21864, 21865},
					{21866, 21867, 21868},
					{21869, 21870, 22767},
					{21900, 21901, 22547},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 805,  806,  809,
							 810,  811,  812,
							 813, 1204, 1206,
							1218, 5433, 5523,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 805,  806,  809,
							 810,  811,  812,
							 813, 1204, 1206,
							1218, 5433, 5523,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 805,  806,  809,
							 810,  811,  812,
							 813, 1204, 1206,
							1218, 5433, 5523,
						}
					},
				},
			},
			[581] = { -- Vengeance
				talents = {
					{22502, 22503, 22504},
					{22505, 22766, 22507},
					{22324, 22541, 22540},
					{22508, 22509, 22770},
					{22546, 22510, 22511},
					{22512, 22513, 22768},
					{22543, 23464, 21902},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							 814,  815,  816,
							 819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
							5520, 5521, 5522,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							 814,  815,  816,
							 819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
							5520, 5521, 5522,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							 814,  815,  816,
							 819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
							5520, 5521, 5522,
						}
					},
				},
			},
			-- Evoker
			[1467] = { -- Devastation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5473,
							5509,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5473,
							5509,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5456, 5460, 5462,
							5464, 5466, 5467,
							5469, 5471, 5473,
							5509,
						}
					},
				},
			},
			[1468] = { -- Preservation
				talents = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5472,
							5502,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5472,
							5502,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							5454, 5455, 5459,
							5461, 5463, 5465,
							5468, 5470, 5472,
							5502,
						}
					},
				},
			},
		}
	else
		specInfo = {
			version = 4,

			-- Warrior
			[71] = { -- Arms
				talents = {
					{22624, 22360, 22371},
					{19676, 22372, 22789},
					{22380, 22489, 19138},
					{15757, 22627, 22628},
					{22392, 22391, 22362},
					{22394, 22397, 22399},
					{21204, 22407, 21667},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							28,   29,   31,
							32,   33,   34,
							3522, 3534, 5372,
							5376,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							28,   29,   31,
							32,   33,   34,
							3522, 3534, 5372,
							5376,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							28,   29,   31,
							32,   33,   34,
							3522, 3534, 5372,
							5376,
						}
					},
				},
			},
			[72] = { -- Fury
				talents = {
					{22632, 22633, 22491},
					{19676, 22625, 23093},
					{22379, 22381, 23372},
					{23097, 22627, 22382},
					{22383, 22393, 19140},
					{22396, 22398, 22400},
					{22405, 22402, 16037},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							25,  166,  170,
							172,  177,  179,
							3528, 3533, 3735,
							5373, 5431,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							25,  166,  170,
							172,  177,  179,
							3528, 3533, 3735,
							5373, 5431,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							25,  166,  170,
							172,  177,  179,
							3528, 3533, 3735,
							5373, 5431,
						}
					},
				},
			},
			[73] = { -- Protection
				talents = {
					{15760, 15759, 15774},
					{19676, 22629, 22409},
					{22378, 22626, 23260},
					{23096, 22627, 22488},
					{22384, 22631, 22800},
					{22395, 22544, 22401},
					{23455, 22406, 23099},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							24,  167,  168,
							171,  173,  175,
							178,  831,  833,
							845, 5374, 5432,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							24,  167,  168,
							171,  173,  175,
							178,  831,  833,
							845, 5374, 5432,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							24,  167,  168,
							171,  173,  175,
							178,  831,  833,
							845, 5374, 5432,
						}
					},
				},
			},
			-- Paladin
			[65] = { -- Holy
				talents = {
					{17565, 17567, 17569},
					{22176, 17575, 17577},
					{22179, 22180, 21811},
					{22433, 22434, 17593},
					{17597, 17599, 17601},
					{23191, 22190, 22484},
					{21201, 21671, 21203},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							82,   85,   86,
							87,   88,  640,
							642,  689,  859,
							3618, 5421,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							82,   85,   86,
							87,   88,  640,
							642,  689,  859,
							3618, 5421,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							82,   85,   86,
							87,   88,  640,
							642,  689,  859,
							3618, 5421,
						}
					},
				},
			},
			[66] = { -- Protection
				talents = {
					{22428, 22558, 23469},
					{22431, 22604, 23468},
					{22179, 22180, 21811},
					{22433, 22434, 22435},
					{17597, 17599, 17601},
					{22189, 22438, 23087},
					{23457, 21202, 22645},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							90,   91,   92,
							93,   94,   97,
							844,  860,  861,
							3474, 3475,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							90,   91,   92,
							93,   94,   97,
							844,  860,  861,
							3474, 3475,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							90,   91,   92,
							93,   94,   97,
							844,  860,  861,
							3474, 3475,
						}
					},
				},
			},
			[70] = { -- Retribution
				talents = {
					{22590, 22557, 23467},
					{22319, 22592, 23466},
					{22179, 22180, 21811},
					{22433, 22434, 22183},
					{17597, 17599, 17601},
					{23167, 22483, 23086},
					{23456, 22215, 22634},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							81,  641,  751,
							752,  753,  754,
							755,  756,  757,
							858, 5422,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							81,  641,  751,
							752,  753,  754,
							755,  756,  757,
							858, 5422,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							81,  641,  751,
							752,  753,  754,
							755,  756,  757,
							858, 5422,
						}
					},
				},
			},
			-- Hunter
			[253] = { -- Beast Mastery
				talents = {
					{22291, 22280, 22282},
					{22500, 22266, 22290},
					{19347, 19348, 23100},
					{22441, 22347, 22269},
					{22268, 22276, 22499},
					{19357, 22002, 23044},
					{22273, 21986, 22295},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							693,  824,  825,
							1214, 3599, 3600,
							3604, 3605, 3612,
							3730, 5418, 5441,
							5444,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							693,  824,  825,
							1214, 3599, 3600,
							3604, 3605, 3612,
							3730, 5418, 5441,
							5444,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							693,  824,  825,
							1214, 3599, 3600,
							3604, 3605, 3612,
							3730, 5418, 5441,
							5444,
						}
					},
				},
			},
			[254] = { -- Marksmanship
				talents = {
					{22279, 22501, 22289},
					{22495, 22497, 22498},
					{19347, 19348, 23100},
					{22267, 22286, 21998},
					{22268, 22276, 23463},
					{23063, 23104, 22287},
					{22274, 22308, 22288},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							649,  651,  653,
							656,  657,  658,
							659,  660, 3614,
							3729, 5419, 5440,
							5442,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							649,  651,  653,
							656,  657,  658,
							659,  660, 3614,
							3729, 5419, 5440,
							5442,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							649,  651,  653,
							656,  657,  658,
							659,  660, 3614,
							3729, 5419, 5440,
							5442,
						}
					},
				},
			},
			[255] = { -- Survival
				talents = {
					{22275, 22283, 22296},
					{21997, 22769, 22297},
					{19347, 19348, 23100},
					{22277, 19361, 22299},
					{22268, 22276, 22499},
					{22300, 22278, 22271},
					{22272, 22301, 23105},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							661,  662,  663,
							664,  665,  686,
							3606, 3607, 3609,
							3610, 5420, 5443,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							661,  662,  663,
							664,  665,  686,
							3606, 3607, 3609,
							3610, 5420, 5443,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							661,  662,  663,
							664,  665,  686,
							3606, 3607, 3609,
							3610, 5420, 5443,
						}
					},
				},
			},
			-- Rogue
			[259] = { -- Assassination
				talents = {
					{22337, 22338, 22339},
					{22331, 22332, 23022},
					{19239, 19240, 19241},
					{22340, 22122, 22123},
					{19245, 23037, 22115},
					{22343, 23015, 22344},
					{21186, 22133, 23174},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							130,  141,  144,
							147,  830, 3448,
							3479, 3480, 5405,
							5408,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							130,  141,  144,
							147,  830, 3448,
							3479, 3480, 5405,
							5408,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							130,  141,  144,
							147,  830, 3448,
							3479, 3480, 5405,
							5408,
						}
					},
				},
			},
			[260] = { -- Outlaw
				talents = {
					{22118, 22119, 22120},
					{23470, 19237, 19238},
					{19239, 19240, 19241},
					{22121, 22122, 22123},
					{23077, 22114, 22115},
					{21990, 23128, 19250},
					{22125, 23075, 23175},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							129,  135,  138,
							139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5413,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							129,  135,  138,
							139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5413,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							129,  135,  138,
							139,  145,  853,
							1208, 3421, 3483,
							3619, 5412, 5413,
						}
					},
				},
			},
			[261] = { -- Subtlety
				talents = {
					{19233, 19234, 19235},
					{22331, 22332, 22333},
					{19239, 19240, 19241},
					{22128, 22122, 22123},
					{23078, 23036, 22115},
					{22335, 19249, 22336},
					{22132, 23183, 21188},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							136,  146,  153,
							846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							136,  146,  153,
							846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							136,  146,  153,
							846,  856, 1209,
							3447, 3462, 5406,
							5409, 5411,
						}
					},
				},
			},
			-- Priest
			[256] = { -- Discipline
				talents = {
					{19752, 22313, 22329},
					{22315, 22316, 19758},
					{22440, 22094, 19755},
					{19759, 19769, 19761},
					{22330, 19765, 19766},
					{22161, 19760, 19763},
					{21183, 21184, 22976},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							98,  100,  109,
							111,  114,  117,
							123,  126,  855,
							1244, 5403, 5416,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							98,  100,  109,
							111,  114,  117,
							123,  126,  855,
							1244, 5403, 5416,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							98,  100,  109,
							111,  114,  117,
							123,  126,  855,
							1244, 5403, 5416,
						}
					},
				},
			},
			[257] = { -- Holy
				talents = {
					{22312, 19753, 19754},
					{22325, 22326, 19758},
					{22487, 22095, 22562},
					{21750, 21977, 19761},
					{19764, 22327, 21754},
					{19767, 19760, 19763},
					{21636, 21644, 23145},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							101,  108,  112,
							115,  118,  124,
							127, 1242, 1927,
							5365, 5366, 5404,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							101,  108,  112,
							115,  118,  124,
							127, 1242, 1927,
							5365, 5366, 5404,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							101,  108,  112,
							115,  118,  124,
							127, 1242, 1927,
							5365, 5366, 5404,
						}
					},
				},
			},
			[258] = { -- Shadow
				talents = {
					{22328, 22136, 22314},
					{22315, 23374, 21976},
					{23125, 23126, 23127},
					{23137, 23375, 21752},
					{22310, 22311, 21755},
					{21718, 21719, 21720},
					{21637, 21978, 21979},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							102,  106,  113,
							128,  739,  763,
							3753, 5380, 5381,
							5446, 5447,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							102,  106,  113,
							128,  739,  763,
							3753, 5380, 5381,
							5446, 5447,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							102,  106,  113,
							128,  739,  763,
							3753, 5380, 5381,
							5446, 5447,
						}
					},
				},
			},
			-- Death Knight
			[250] = { -- Blood
				talents = {
					{19165, 19166, 23454},
					{19218, 19219, 19220},
					{19221, 22134, 22135},
					{22013, 22014, 22015},
					{19227, 19226, 19228},
					{19230, 19231, 19232},
					{21207, 21208, 21209},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							204,  205,  206,
							607,  608,  609,
							841, 3441, 3511,
							5425, 5426,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							204,  205,  206,
							607,  608,  609,
							841, 3441, 3511,
							5425, 5426,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							204,  205,  206,
							607,  608,  609,
							841, 3441, 3511,
							5425, 5426,
						}
					},
				},
			},
			[251] = { -- Frost
				talents = {
					{22016, 22017, 22018},
					{22019, 22020, 22021},
					{22515, 22517, 22519},
					{22521, 22523, 22525},
					{22527, 22530, 23373},
					{22531, 22533, 22535},
					{22023, 22109, 22537},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							701,  702,  706,
							3439, 3512, 3743,
							5424, 5427, 5429,
							5435,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							701,  702,  706,
							3439, 3512, 3743,
							5424, 5427, 5429,
							5435,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							701,  702,  706,
							3439, 3512, 3743,
							5424, 5427, 5429,
							5435,
						}
					},
				},
			},
			[252] = { -- Unholy
				talents = {
					{22024, 22025, 22026},
					{22027, 22028, 22029},
					{22516, 22518, 22520},
					{22522, 22524, 22526},
					{22528, 22529, 23373},
					{22532, 22534, 22536},
					{22030, 22110, 22538},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							40,   41,  149,
							152, 3437, 3746,
							3747, 5423, 5428,
							5430, 5436,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							40,   41,  149,
							152, 3437, 3746,
							3747, 5423, 5428,
							5430, 5436,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							40,   41,  149,
							152, 3437, 3746,
							3747, 5423, 5428,
							5430, 5436,
						}
					},
				},
			},
			-- Shaman
			[262] = { -- Elemental
				talents = {
					{22356, 22357, 22358},
					{23108, 23460, 23190},
					{23162, 23163, 23164},
					{19271, 19272, 19273},
					{22144, 22172, 21966},
					{22145, 19266, 23111},
					{21198, 22153, 21675},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							727,  728,  730,
							731, 3062, 3488,
							3490, 3491, 3620,
							3621, 5415,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							727,  728,  730,
							731, 3062, 3488,
							3490, 3491, 3620,
							3621, 5415,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							727,  728,  730,
							731, 3062, 3488,
							3490, 3491, 3620,
							3621, 5415,
						}
					},
				},
			},
			[263] = { -- Enhancement
				talents = {
					{22354, 22355, 22353},
					{22636, 23462, 23109},
					{23165, 19260, 23166},
					{23089, 23090, 22171},
					{22144, 22149, 21966},
					{21973, 22352, 22351},
					{21970, 22977, 21972},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							721,  722,  725,
							1944, 3487, 3489,
							3492, 3519, 3622,
							3623, 5414, 5438,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							721,  722,  725,
							1944, 3487, 3489,
							3492, 3519, 3622,
							3623, 5414, 5438,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							721,  722,  725,
							1944, 3487, 3489,
							3492, 3519, 3622,
							3623, 5414, 5438,
						}
					},
				},
			},
			[264] = { -- Restoration
				talents = {
					{19262, 19263, 19264},
					{19259, 23461, 21963},
					{19275, 23110, 22127},
					{22152, 22322, 22323},
					{22144, 19269, 21966},
					{19265, 21971, 21968},
					{21969, 21199, 22359},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							707,  708,  712,
							713,  714,  715,
							1930, 3520, 3755,
							3756, 5388, 5437,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							707,  708,  712,
							713,  714,  715,
							1930, 3520, 3755,
							3756, 5388, 5437,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							707,  708,  712,
							713,  714,  715,
							1930, 3520, 3755,
							3756, 5388, 5437,
						}
					},
				},
			},
			-- Mage
			[62] = { -- Arcane
				talents = {
					{22458, 22461, 22464},
					{23072, 22443, 16025},
					{22444, 22445, 22447},
					{22453, 22467, 22470},
					{22907, 22448, 22471},
					{22455, 22449, 22474},
					{21630, 21144, 21145},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							61,   62,  635,
							637, 3442, 3517,
							3529, 3531, 5397,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							61,   62,  635,
							637, 3442, 3517,
							3529, 3531, 5397,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							61,   62,  635,
							637, 3442, 3517,
							3529, 3531, 5397,
						}
					},
				},
			},
			[63] = { -- Fire
				talents = {
					{22456, 22459, 22462},
					{23071, 22443, 23074},
					{22444, 22445, 22447},
					{22450, 22465, 22468},
					{22904, 22448, 22471},
					{22451, 23362, 22472},
					{21631, 22220, 21633},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							53,  643,  644,
							645,  646,  647,
							648,  828, 5389,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							53,  643,  644,
							645,  646,  647,
							648,  828, 5389,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							53,  643,  644,
							645,  646,  647,
							648,  828, 5389,
						}
					},
				},
			},
			[64] = { -- Frost
				talents = {
					{22457, 22460, 22463},
					{22442, 22443, 23073},
					{22444, 22445, 22447},
					{22452, 22466, 22469},
					{22446, 22448, 22471},
					{22454, 23176, 22473},
					{21632, 22309, 21634},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							66,   67,   68,
							632,  633,  634,
							3443, 3532, 5390,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							66,   67,   68,
							632,  633,  634,
							3443, 3532, 5390,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							66,   67,   68,
							632,  633,  634,
							3443, 3532, 5390,
						}
					},
				},
			},
			-- Warlock
			[265] = { -- Affliction
				talents = {
					{22039, 23140, 23141},
					{22044, 21180, 22089},
					{19280, 19285, 19286},
					{19279, 19292, 22046},
					{22047, 19291, 23465},
					{23139, 23159, 19295},
					{19284, 19281, 19293},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							11,   12,   15,
							16,   17,   18,
							19,   20, 3740,
							5370, 5379, 5386,
							5392,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							11,   12,   15,
							16,   17,   18,
							19,   20, 3740,
							5370, 5379, 5386,
							5392,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							11,   12,   15,
							16,   17,   18,
							19,   20, 3740,
							5370, 5379, 5386,
							5392,
						}
					},
				},
			},
			[266] = { -- Demonology
				talents = {
					{19290, 22048, 23138},
					{22045, 21694, 23158},
					{19280, 19285, 19286},
					{22477, 22042, 23160},
					{22047, 19291, 23465},
					{23147, 23146, 21717},
					{23161, 22479, 23091},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							156,  158,  162,
							165, 1213, 3505,
							3506, 3507, 3624,
							3625, 3626, 5394,
							5400,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							156,  158,  162,
							165, 1213, 3505,
							3506, 3507, 3624,
							3625, 3626, 5394,
							5400,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							156,  158,  162,
							165, 1213, 3505,
							3506, 3507, 3624,
							3625, 3626, 5394,
							5400,
						}
					},
				},
			},
			[267] = { -- Destruction
				talents = {
					{22038, 22090, 22040},
					{23148, 21695, 23157},
					{19280, 19285, 19286},
					{22480, 22043, 23143},
					{22047, 19291, 23465},
					{23155, 23156, 19295},
					{19284, 23144, 23092},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							157,  159,  164,
							3502, 3504, 3508,
							3509, 3510, 5382,
							5393, 5401,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							157,  159,  164,
							3502, 3504, 3508,
							3509, 3510, 5382,
							5393, 5401,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							157,  159,  164,
							3502, 3504, 3508,
							3509, 3510, 5382,
							5393, 5401,
						}
					},
				},
			},
			-- Monk
			[268] = { -- Brewmaster
				talents = {
					{23106, 19820, 20185},
					{19304, 19818, 19302},
					{22099, 22097, 19992},
					{19993, 19994, 19995},
					{20174, 23363, 20175},
					{19819, 20184, 22103},
					{22106, 22104, 22108},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							666,  667,  668,
							669,  670,  671,
							672,  673,  765,
							843, 1958, 5417,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							666,  667,  668,
							669,  670,  671,
							672,  673,  765,
							843, 1958, 5417,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							666,  667,  668,
							669,  670,  671,
							672,  673,  765,
							843, 1958, 5417,
						}
					},
				},
			},
			[270] = { -- Mistweaver
				talents = {
					{19823, 19820, 20185},
					{19304, 19818, 19302},
					{22168, 22167, 22166},
					{19993, 22219, 19995},
					{23371, 20173, 20175},
					{23107, 22101, 22214},
					{22218, 22169, 22170},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							70,  678,  679,
							680,  682,  683,
							1928, 3732, 5395,
							5398, 5402,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							70,  678,  679,
							680,  682,  683,
							1928, 3732, 5395,
							5398, 5402,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							70,  678,  679,
							680,  682,  683,
							1928, 3732, 5395,
							5398, 5402,
						}
					},
				},
			},
			[269] = { -- Windwalker
				talents = {
					{23106, 19820, 20185},
					{19304, 19818, 19302},
					{22098, 19771, 22096},
					{19993, 23364, 19995},
					{23258, 20173, 20175},
					{22093, 23122, 22102},
					{22107, 22105, 21191},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							77,  675,  852,
							3050, 3052, 3734,
							3737, 3744, 3745,
							5448,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							77,  675,  852,
							3050, 3052, 3734,
							3737, 3744, 3745,
							5448,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							77,  675,  852,
							3050, 3052, 3734,
							3737, 3744, 3745,
							5448,
						}
					},
				},
			},
			-- Druid
			[102] = { -- Balance
				talents = {
					{22385, 22386, 22387},
					{19283, 18570, 18571},
					{22155, 22157, 22159},
					{21778, 18576, 18577},
					{18580, 21706, 21702},
					{22389, 21712, 22165},
					{21648, 21193, 21655},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							180,  182,  184,
							185,  822,  834,
							836, 3058, 3728,
							3731, 5383, 5407,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							180,  182,  184,
							185,  822,  834,
							836, 3058, 3728,
							3731, 5383, 5407,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							180,  182,  184,
							185,  822,  834,
							836, 3058, 3728,
							3731, 5383, 5407,
						}
					},
				},
			},
			[103] = { -- Feral
				talents = {
					{22363, 22364, 22365},
					{19283, 18570, 18571},
					{22163, 22158, 22159},
					{21778, 18576, 18577},
					{21708, 18579, 21704},
					{21714, 21711, 22370},
					{21646, 21649, 21653},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							201,  203,  601,
							602,  611,  612,
							620,  820, 3053,
							3751, 5384,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							201,  203,  601,
							602,  611,  612,
							620,  820, 3053,
							3751, 5384,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							201,  203,  601,
							602,  611,  612,
							620,  820, 3053,
							3751, 5384,
						}
					},
				},
			},
			[104] = { -- Guardian
				talents = {
					{22419, 22418, 22420},
					{19283, 18570, 18571},
					{22163, 22156, 22159},
					{21778, 18576, 18577},
					{21709, 21707, 22388},
					{22423, 21713, 22390},
					{22426, 22427, 22425},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							49,   50,   51,
							52,  192,  193,
							194,  195,  196,
							197,  842, 1237,
							3750, 5410,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							49,   50,   51,
							52,  192,  193,
							194,  195,  196,
							197,  842, 1237,
							3750, 5410,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							49,   50,   51,
							52,  192,  193,
							194,  195,  196,
							197,  842, 1237,
							3750, 5410,
						}
					},
				},
			},
			[105] = { -- Restoration
				talents = {
					{18569, 18574, 18572},
					{19283, 18570, 18571},
					{22366, 22367, 22160},
					{21778, 18576, 18577},
					{21710, 21705, 22421},
					{21716, 18585, 22422},
					{22403, 21651, 22404},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							59,  691,  692,
							697,  700,  835,
							838, 1215, 3048,
							3752, 5387,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							59,  691,  692,
							697,  700,  835,
							838, 1215, 3048,
							3752, 5387,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							59,  691,  692,
							697,  700,  835,
							838, 1215, 3048,
							3752, 5387,
						}
					},
				},
			},
			-- Demon Hunter
			[577] = { -- Havoc
				talents = {
					{21854, 22493, 22416},
					{21857, 22765, 22799},
					{22909, 22494, 21862},
					{21863, 21864, 21865},
					{21866, 21867, 21868},
					{21869, 21870, 22767},
					{21900, 21901, 22547},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							805,  806,  809,
							810,  811,  812,
							813, 1204, 1206,
							1218, 5433, 5445,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							805,  806,  809,
							810,  811,  812,
							813, 1204, 1206,
							1218, 5433, 5445,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							805,  806,  809,
							810,  811,  812,
							813, 1204, 1206,
							1218, 5433, 5445,
						}
					},
				},
			},
			[581] = { -- Vengeance
				talents = {
					{22502, 22503, 22504},
					{22505, 22766, 22507},
					{22324, 22541, 22540},
					{22508, 22509, 22770},
					{22546, 22510, 22511},
					{22512, 22513, 22768},
					{22543, 23464, 21902},
				},
				pvptalentslots = {
					{
						level = 20,
						availableTalentIDs = {
							814,  815,  816,
							819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
						}
					},
					{
						level = 30,
						availableTalentIDs = {
							814,  815,  816,
							819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
						}
					},
					{
						level = 40,
						availableTalentIDs = {
							814,  815,  816,
							819, 1220, 1948,
							3423, 3429, 3430,
							3727, 5434, 5439,
						}
					},
				},
			},
		}
	end

	if type(specInfo.version) ~= "number" then
		error("MISSING SPEC INFO VERSION NUMBER")
	end
	
	function GetSpecInfoVersion()
		return specInfo.version
	end
	function VerifyTalentForSpec(specID, talentID)
		if specInfo[specID] then
			for tier,talents in ipairs(specInfo[specID].talents) do
				for column,talent in ipairs(talents) do
					if talent == talentID then
						return tier, column
					end
				end
			end
		end
	end
	function VerifyPvPTalentForSpec(specID, talentID)
		if specInfo[specID] then
			for _,slot in ipairs(specInfo[specID].pvptalentslots) do
				for _,talent in ipairs(slot.availableTalentIDs) do
					if talent == talentID then
						return true
					end
				end
			end
		end
	end
	function GetTalentInfoForSpecID(specID, tier, column)
		for specIndex=1,GetNumSpecializations() do
			local playerSpecID = GetSpecializationInfo(specIndex);
			if playerSpecID == specID then
				return GetTalentInfoBySpecialization(specIndex, tier, column);
			end
		end

		if BtWLoadoutsSpecInfo[specID] then
			return GetTalentInfoByID(BtWLoadoutsSpecInfo[specID].talents[tier][column]);
		end

		if specInfo[specID] then
			return GetTalentInfoByID(specInfo[specID].talents[tier][column]);
		end
	end
	function GetPvpTalentSlotInfoForSpecID(specID, index)
		local playerSpecID = GetSpecializationInfo(GetSpecialization());
		if playerSpecID == specID then
			local slotInfo = GetPvpTalentSlotInfo(index);
			return slotInfo
		end

		if BtWLoadoutsSpecInfo[specID] and BtWLoadoutsSpecInfo[specID].pvptalentslots and BtWLoadoutsSpecInfo[specID].pvptalentslots[index] then
			return BtWLoadoutsSpecInfo[specID].pvptalentslots[index];
		end

		if specInfo[specID] and specInfo[specID].pvptalentslots and specInfo[specID].pvptalentslots[index] then
			return specInfo[specID].pvptalentslots[index];
		end
	end
	Internal.GetSpecInfoVersion = GetSpecInfoVersion
	Internal.VerifyTalentForSpec = VerifyTalentForSpec
	Internal.VerifyPvPTalentForSpec = VerifyPvPTalentForSpec
	Internal.GetTalentInfoForSpecID = GetTalentInfoForSpecID
	Internal.GetPvpTalentSlotInfoForSpecID = GetPvpTalentSlotInfoForSpecID
end
local GetEssenceInfoByID, GetEssenceInfoForRole;
do
	local essenceInfo = {
		nil, -- [1]
		{
			["ID"] = 2,
			["name"] = "Azeroth's Undying Gift",
			["icon"] = 2967107,
		}, -- [2]
		{
			["ID"] = 3,
			["name"] = "Sphere of Suppression",
			["icon"] = 2065602,
		}, -- [3]
		{
			["ID"] = 4,
			["name"] = "Worldvein Resonance",
			["icon"] = 1830317,
		}, -- [4]
		{
			["ID"] = 5,
			["name"] = "Essence of the Focusing Iris",
			["icon"] = 2967111,
		}, -- [5]
		{
			["ID"] = 6,
			["name"] = "Purification Protocol",
			["icon"] = 2967103,
		}, -- [6]
		{
			["ID"] = 7,
			["name"] = "Anima of Life and Death",
			["icon"] = 2967105,
		}, -- [7]
		nil, -- [8]
		nil, -- [9]
		nil, -- [10]
		nil, -- [11]
		{
			["ID"] = 12,
			["name"] = "The Crucible of Flame",
			["icon"] = 3015740,
		}, -- [12]
		{
			["ID"] = 13,
			["name"] = "Nullification Dynamo",
			["icon"] = 3015741,
		}, -- [13]
		{
			["ID"] = 14,
			["name"] = "Condensed Life-Force",
			["icon"] = 2967113,
		}, -- [14]
		{
			["ID"] = 15,
			["name"] = "Ripple in Space",
			["icon"] = 2967109,
		}, -- [15]
		{
			["ID"] = 16,
			["name"] = "Unwavering Ward",
			["icon"] = 3193842,
		}, -- [16]
		{
			["ID"] = 17,
			["name"] = "The Ever-Rising Tide",
			["icon"] = 2967108,
		}, -- [17]
		{
			["ID"] = 18,
			["name"] = "Artifice of Time",
			["icon"] = 2967112,
		}, -- [18]
		{
			["ID"] = 19,
			["name"] = "The Well of Existence",
			["icon"] = 516796,
		}, -- [19]
		{
			["ID"] = 20,
			["name"] = "Life-Binder's Invocation",
			["icon"] = 2967106,
		}, -- [20]
		{
			["ID"] = 21,
			["name"] = "Vitality Conduit",
			["icon"] = 2967100,
		}, -- [21]
		{
			["ID"] = 22,
			["name"] = "Vision of Perfection",
			["icon"] = 3015743,
		}, -- [22]
		{
			["ID"] = 23,
			["name"] = "Blood of the Enemy",
			["icon"] = 2032580,
		}, -- [23]
		{
			["ID"] = 24,
			["name"] = "Spirit of Preservation",
			["icon"] = 2967101,
		}, -- [24]
		{
			["ID"] = 25,
			["name"] = "Aegis of the Deep",
			["icon"] = 2967110,
		}, -- [25]
		nil, -- [26]
		{
			["ID"] = 27,
			["name"] = "Memory of Lucid Dreams",
			["icon"] = 2967104,
		}, -- [27]
		{
			["ID"] = 28,
			["name"] = "The Unbound Force",
			["icon"] = 2967102,
		}, -- [28]
		nil, -- [29]
		nil, -- [30]
		nil, -- [31]
		{
			["ID"] = 32,
			["name"] = "Conflict and Strife",
			["icon"] = 3015742,
		}, -- [32]
		{
			["ID"] = 33,
			["name"] = "Touch of the Everlasting",
			["icon"] = 3193847,
		}, -- [33]
		{
			["ID"] = 34,
			["name"] = "Strength of the Warden",
			["icon"] = 3193846,
		}, -- [34]
		{
			["ID"] = 35,
			["name"] = "Breath of the Dying",
			["icon"] = 3193844,
		}, -- [35]
		{
			["ID"] = 36,
			["name"] = "Spark of Inspiration",
			["icon"] = 3193843,
		}, -- [36]
		{
			["ID"] = 37,
			["name"] = "The Formless Void",
			["icon"] = 3193845,
		}, -- [37]
	}
	local roleInfo = {
		["DAMAGER"] = {
			["essences"] = {
				23, -- [1]
				35, -- [2]
				14, -- [3]
				32, -- [4]
				5, -- [5]
				27, -- [6]
				6, -- [7]
				15, -- [8]
				36, -- [9]
				12, -- [10]
				37, -- [11]
				28, -- [12]
				22, -- [13]
				4, -- [14]
			},
		},
		["TANK"] = {
			["essences"] = {
				25, -- [1]
				7, -- [2]
				2, -- [3]
				32, -- [4]
				27, -- [5]
				13, -- [6]
				15, -- [7]
				3, -- [8]
				34, -- [9]
				12, -- [10]
				37, -- [11]
				33, -- [12]
				22, -- [13]
				4, -- [14]
			},
		},
		["HEALER"] = {
			["essences"] = {
				18, -- [1]
				32, -- [2]
				20, -- [3]
				27, -- [4]
				15, -- [5]
				24, -- [6]
				12, -- [7]
				17, -- [8]
				37, -- [9]
				19, -- [10]
				16, -- [11]
				22, -- [12]
				21, -- [13]
				4, -- [14]
			},
		},
	};
	function GetEssenceInfoByID(essenceID)
		local essence = GetEssenceInfo(essenceID);
		if not essence then
			essence = BtWLoadoutsEssenceInfo and BtWLoadoutsEssenceInfo[essenceID] or essenceInfo[essenceID];
		end
		return essence;
	end
	function GetEssenceInfoForRole(role, index)
		if BtWLoadoutsRoleInfo[role] and BtWLoadoutsRoleInfo[role].essences and BtWLoadoutsRoleInfo[role].essences[index] then
			return GetEssenceInfoByID(BtWLoadoutsRoleInfo[role].essences[index]);
		end

		if roleInfo[role] and roleInfo[role].essences and roleInfo[role].essences[index] then
			return GetEssenceInfoByID(roleInfo[role].essences[index]);
		end
	end
	Internal.GetEssenceInfoByID = GetEssenceInfoByID
	Internal.GetEssenceInfoForRole = GetEssenceInfoForRole
end
do
	local traitInfoVersion, trees, nodes = Internal.dftalents.version, Internal.dftalents.trees, Internal.dftalents.nodes

	for _,node in pairs(nodes) do
		for _,edge in ipairs(node.edges) do
			local target = nodes[edge.targetNode];
			target.incomingEdges = target.incomingEdges or {};
			target.incomingEdges[#target.incomingEdges+1] = node.ID;
		end
	end
	function Internal.GetTraitInfoVersion()
		return traitInfoVersion;
	end
	function Internal.GetTreeInfoBySpecID(specID)
		local result = BtWLoadoutsTraitsInfo.trees[specID] or trees[specID];
		if not result then
			C_ClassTalents.InitializeViewLoadout(specID, GetMaxLevelForPlayerExpansion());
			C_ClassTalents.ViewLoadout({});
			Internal.UpdateTraitInfoFromConfig(specID, Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID);

			result = BtWLoadoutsTraitsInfo.trees[specID] or trees[specID];
		end
		result.buttonSize = 40;
		result.minZoom = 0.75;
		result.maxZoom = 0.75;
		return result;
	end
	function Internal.GetNodeInfo(nodeID)
		return BtWLoadoutsTraitsInfo.nodes[nodeID] or nodes[nodeID];
	end
	function Internal.GetNodeInfoBySpecID(specID, nodeID)
		local tree = Internal.GetTreeInfoBySpecID(specID);
		local result = BtWLoadoutsTraitsInfo.nodes[nodeID] and CopyTable(BtWLoadoutsTraitsInfo.nodes[nodeID], false) or nodes[nodeID];
		if not result then
			error("Missing Node " .. nodeID);
		end
		result.isVisible = tree.visibleNodes[nodeID] and true or false;
		if tContains(tree.grantedNodes, nodeID) then
			result.activeRank = result.maxRanks;
			result.currentRank = result.maxRanks;
		else
			result.activeRank = 0;
			result.currentRank = 0;
		end
		result.ranksPurchased = 0;
		if not result.activeEntry and #result.entryIDs == 1 then
			result.activeEntry = {
				entryID = result.entryIDs[1],
				rank = 1,
			}
		end
		if result.edgesBySpecID and result.edgesBySpecID[specID] then
			result.visibleEdges = result.edgesBySpecID[specID];
		else
			result.visibleEdges = {}
		end
		return result;
	end
	function Internal.UpdateTraitInfoFromPlayer()
		local specID = GetSpecializationInfo(GetSpecialization());
		C_ClassTalents.InitializeViewLoadout(specID, GetMaxLevelForPlayerExpansion());

		local success = C_ClassTalents.ViewLoadout({});
		if not success then
--[==[@debug@
			print(format(L["[BtWLoadouts]: failed to update trait information for %s, could not initialize trait tree."], select(2, GetSpecializationInfoByID(specID))));
--@end-debug@]==]
			return
		end
		
		local configID = Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID; -- C_ClassTalents.GetActiveConfigID();
		if not configID then
--[==[@debug@
			print(format(L["[BtWLoadouts]: failed to update trait information for %s, missing active config id."], select(2, GetSpecializationInfoByID(specID))));
--@end-debug@]==]
			return
		end

		return Internal.UpdateTraitInfoFromConfig(specID, configID)
	end
	function Internal.UpdateTraitInfoFromConfig(specID, configID)
		if not C_ClassTalents then
--[==[@debug@
			print(format(L["[BtWLoadouts]: failed to update trait information for %s, missing C_ClassTalents."], select(2, GetSpecializationInfoByID(specID))));
--@end-debug@]==]
			return
		end

        local configInfo = C_Traits.GetConfigInfo(configID);
		local treeID = C_ClassTalents.GetTraitTreeForSpec(specID);
		local tree = C_Traits.GetTreeInfo(configID, treeID);
		local nodeIDs = C_Traits.GetTreeNodes(treeID);
		local currencies = C_Traits.GetTreeCurrencyInfo(configID, treeID, true);
		local incomingEdgesByNodeID = {}
		
--[==[@debug@
		print(format(L["[BtWLoadouts]: updating trait information for %s, configID: %d, treeID: %d."], select(2, GetSpecializationInfoByID(specID)), configID, treeID));
--@end-debug@]==]

		local conditions = setmetatable({}, {
			__index = function (self, key)
				if type(key) == "number" then
					local result = C_Traits.GetConditionInfo(configID, key)
					self[key] = result;
					return result;
				end
			end
		});

		for _,gate in ipairs(tree.gates) do
			local condInfo = conditions[gate.conditionID];
			gate.traitCurrencyID = condInfo.traitCurrencyID;
			gate.spentAmountRequired = condInfo.spentAmountRequired;
		end

		tree.hideSingleRankNumbers = nil;
		tree.buttonSize = nil;
		tree.maxZoom = nil;
		tree.minZoom = nil;

		for _,currency in ipairs(currencies) do
			currency.quantity = nil;
			currency.spent = nil;
		end

		tree.nodes = nodeIDs;
		tree.currencies = currencies;

		local visibleNodes = {};
		local grantedNodes = {};

		for _,nodeID in ipairs(nodeIDs) do
			local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID);
			if nodeInfo and nodeInfo.isVisible then
				visibleNodes[nodeID] = true;

				for _,condID in ipairs(nodeInfo.conditionIDs) do
					local condInfo = conditions[condID];
					if condInfo.ranksGranted and (condInfo.specSetID == nil or tContains(C_SpecializationInfo.GetSpecIDs(condInfo.specSetID), specID)) then
						grantedNodes[#grantedNodes+1] = nodeID;
					end
				end

				if not incomingEdgesByNodeID[nodeID] then
					incomingEdgesByNodeID[nodeID] = {};
				end

				nodeInfo.canPurchaseRank = nil;
				nodeInfo.canRefundRank = nil;
				nodeInfo.isAvailable = nil;
				nodeInfo.isCascadeRepurchasable = nil;
				nodeInfo.isDisplayError = nil;
				nodeInfo.isVisible = nil;
				nodeInfo.meetsEdgeRequirements = nil;
				
				nodeInfo.activeRank = nil;
				nodeInfo.currentRank = nil;
				nodeInfo.ranksPurchased = nil;
				nodeInfo.activeEntry = nil;
				nodeInfo.entryIDsWithCommittedRanks = nil;

				for _,edge in ipairs(nodeInfo.visibleEdges) do
					edge.isActive = nil;
					
					if not incomingEdgesByNodeID[edge.targetNode] then
						incomingEdgesByNodeID[edge.targetNode] = {};
					end
					incomingEdgesByNodeID[edge.targetNode][#incomingEdgesByNodeID[edge.targetNode]+1] = nodeID;
				end

				local savedNodeInfo = Internal.GetNodeInfo(nodeID);

				nodeInfo.edgesBySpecID = savedNodeInfo and savedNodeInfo.edgesBySpecID or {};
				nodeInfo.edgesBySpecID[specID] = nodeInfo.visibleEdges;

				nodeInfo.incomingEdges = savedNodeInfo and savedNodeInfo.incomingEdges;
				nodeInfo.incomingEdgesBySpecID = savedNodeInfo and savedNodeInfo.incomingEdgesBySpecID or {};
				nodeInfo.incomingEdgesBySpecID[specID] = incomingEdgesByNodeID[nodeID];

				nodeInfo.visibleEdges = nil;
				
				local costs = C_Traits.GetNodeCost(configID, nodeID);
				nodeInfo.costs = costs;

				BtWLoadoutsTraitsInfo.nodes[nodeID] = nodeInfo;
			elseif not BtWLoadoutsTraitsInfo.nodes[nodeID] then
				nodeInfo.canPurchaseRank = nil;
				nodeInfo.canRefundRank = nil;
				nodeInfo.isAvailable = nil;
				nodeInfo.isCascadeRepurchasable = nil;
				nodeInfo.isVisible = nil;
				nodeInfo.meetsEdgeRequirements = nil;
				
				nodeInfo.activeRank = nil;
				nodeInfo.currentRank = nil;
				nodeInfo.ranksPurchased = nil;
				nodeInfo.activeEntry = nil;
				nodeInfo.entryIDsWithCommittedRanks = nil;

				BtWLoadoutsTraitsInfo.nodes[nodeID] = nodeInfo;
			end
		end

		tree.visibleNodes = visibleNodes;
		tree.grantedNodes = grantedNodes;

		BtWLoadoutsTraitsInfo.trees[specID] = tree;
	end
end
function Internal.GetCharacterInfo(character)
	return BtWLoadoutsCharacterInfo and BtWLoadoutsCharacterInfo[character];
end
function Internal.GetFormattedCharacterName(slug, includeRealm)
	local characterInfo = Internal.GetCharacterInfo(slug)
	if characterInfo then
		local classColor = C_ClassColor.GetClassColor(characterInfo.class)
		if includeRealm then
			return format("%s - %s", classColor:WrapTextInColorCode(characterInfo.name), characterInfo.realm)
		else
			return classColor:WrapTextInColorCode(characterInfo.name)
		end
	end
	return slug
end
local characterIteratorTemp = {}
function Internal.CharacterIterator()
	wipe(characterIteratorTemp);
	for character in pairs(BtWLoadoutsCharacterInfo or {}) do
		characterIteratorTemp[#characterIteratorTemp+1] = character
	end
	table.sort(characterIteratorTemp, function (a, b)
		return a < b
	end)
	return ipairs(characterIteratorTemp)
end
-- EnumerateRealms
do
	local unique, list = {}, {}
	function Internal.EnumerateRealms()
		wipe(unique)
		wipe(list)
		for _,character in pairs(BtWLoadoutsCharacterInfo or {}) do
			unique[character.realm] = true
		end
		for realm in pairs(unique) do
			list[#list+1] = realm
		end
		table.sort(list, function (a, b)
			return a < b
		end)
		return ipairs(list)
	end
end
-- EnumerateCharactersForRealm
do
	local list = {}
	function Internal.EnumerateCharactersForRealm(realm)
		wipe(list)
		for slug,character in pairs(BtWLoadoutsCharacterInfo or {}) do
			if character.realm == realm then
				list[#list+1] = slug
			end
		end
		table.sort(list, function (a, b)
			return a < b
		end)
		return ipairs(list)
	end
end
function Internal.DeleteCharacter(slug)
	Internal.Call("CharacterDeleted", slug)
	BtWLoadoutsCharacterInfo[slug] = nil
	BtWLoadoutsFrame:Update();
end
function Internal.UpdatePlayerInfo()
    local name, realm = UnitFullName("player");
    local class = select(2, UnitClass("player"));
    local race = select(3, UnitRace("player"));
    local sex = UnitSex("player") - 2;

    BtWLoadoutsCharacterInfo[realm .. "-" .. name] = {name = name, realm = GetRealmName(), class = class, race = race, sex = sex};
end
-- Checks if the player can switch to specID, used to check if loadouts are valid
function Internal.CanSwitchToSpecialization(specID)
	local playerClass = select(2, UnitClass("player"));
	local specClass = select(6, GetSpecializationInfoByID(specID));
	if playerClass ~= specClass then
		return false
	end
	local specIndex = GetSpecialization()
	if specIndex == nil then
		return false
	end

	if select(2, GetInstanceInfo()) == "arena" then
		-- Can not switch specs in arena
		return GetSpecializationInfo(specIndex) == specID
	elseif select(2, GetInstanceInfo()) == "battleground" then
		-- You can only switch specs in bgs unless you go from or to healer
		local currentRole = GetSpecializationRole(specIndex)
		local targetRole = GetSpecializationRoleByID(specID)

		return (currentRole == targetRole) or not (currentRole == "HEALER" or targetRole == "HEALER")
	end

	return true
end
function Internal.HasJailersChains()
	return GetPlayerAuraBySpellID(338906) ~= nil
end