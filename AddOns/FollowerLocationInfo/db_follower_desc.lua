
local _, ns = ...;

local desc = {
	[32] = {
		enUS = "Liberate him twice from captivity. Then return to your garrison and you'll find him outside the fortress walls.",
		deDE = "Befreie ihn zweimal aus Gefangenschaft. Dann kehre zu deiner Garnison zurück und du wirst ihn ausserhalb der Festungsmauern finden.",
		zhTW = "從囚禁中解放了他兩次。然後返回到您的要塞，你會發現他在堡壘城牆外。",
		zhCN = "从囚禁中解放了他两次。然后返回到您的要塞，你会发现他在堡垒城墙外。",
	},
	[171] = {
		enUS = "After the quest, you get him as a quest reward. The charging process takes a while so you should not run away after completing the quest...",
		deDE = "Nach der Quest bekommt man ihn als Belohnung. Der Ladevorgang dauert etwas, daher sollte man nach Abschluss des Quests nicht weglaufen...",
		zhTW = "在此任務之後，您會得到他作為任務獎勵。裝載的過程需要一會兒，所以你不應該在完成任務後跑開...",
		zhCN = "在此任务之后，您会得到他作为任务奖励。装载的过程需要一会儿，所以你不应该在完成任务后跑开...",
	},
	[195] = {
		enUS = "Barov is located at a random position in Draenor under a felled tree. With the ability of the sawmill Barov you can free. Then he offers his following.",
		deDE = "Barov liegt an einer zufälligen Position in Draenor unter einem gefällten Baum. Mit der Fähigkeit des Sägewerks kannst du Barov befreien. Danach bietet er seine Gefolgschaft an.",
		zhTW = "巴羅夫位於在一個隨機的位置，在德拉諾一棵伐倒的樹之下。使用伐木的技能你可以解放巴羅夫。然後他會追隨你。",
		zhCN = "巴罗夫位于在一个随机的位置，在德拉诺一棵伐倒的树之下。使用伐木的技能你可以解放巴罗夫。然后他会追随你。",
	}
};

ns.followers = {
	--[=[ frostfire ridge ]=]
	[32] =  { -- 941,  32, Dagg
		false,
		{
			zone = 941,
			{"pos", {941, 65.9, 60.8}, {941, 39.6, 28.0}},
			{"quest", {34733, 79492, 971, 54.8, 69.4}},
			{"desc", desc[32] },
		},
		{
			zone = 941,
			{"pos", {941, 65.9, 60.8}, {941, 39.6, 28.0}},
			{"quest", {34733, 79492, 976, 48.8, 17.2}},
			{"desc", desc[32] },
		}
	},

	--[=[ Talador ]=]
	[154] = { -- 946, 154, Magister Serenaa (A) / Magister Krelas (H)
		false,
		{
			zone = 946,
			{"requirements", "Arcane sanctum in talador outpost"},
			{"quest", {34993, 80672, 946, 69.6, 20.8}},
		},
		{
			zone = 946,
			{"requirements", "Arcane sanctum in talador outpost"},
			{"quest", {34949, 80553, 946, 71.2, 29.8}}, 
		}
	},
	[155] = { -- 946, 155, Miall (A) / Morketh Bladehowl (H)
		false,
		{
			zone = 946,
			{"questrow",
				{34563, 79160, 946, 69.2, 19.2},
				{34571, 79159, 946, 69.2, 19.2},
				{34573, 79329, 946, 70.0, 20.0},
				{34624, 79329, 946, 70.0, 20.0},
				{34578, 79329, 946, 70.0, 20.0},
				{34976, 80627, 946, 62.4, 67.8},
				{34977, 80628, 946, 69.6, 69.8},
				{34980, 80632, 946, 64.4, 81.8},
				{34981, 80630, 946, 64.4, 81.8},
				{34982, 80968, 946, 69.6, 20.8}
			},
		},
		{
			zone = 946,
			{"questrow",
				{34972, 79356, 946, 70.8, 30.4},
				{34837, 79356, 946, 70.8, 30.4},
				{34840, 80229, 946, 62.0, 69.2},
				{34855, 80339, 946, 68.6, 70.4},
				{34870, 80341, 946, "Appears on your position" },
				{34971, 80342, 946, 64.4, 81.6},
				{34972, 80623, 946, 71.2, 29.8}
			},
		}
	},
	[171] = { -- 946, 171, Pleasure-Bot 8000
		false,
		{
			zone = 946,
			{"pos", {946, 62.9, 50.3}},
			{"questrow",
				{34761, 79901, 946, 62.8, 50.2},
				{35239, 79853, 946, 62.8, 50.4}
			},
			{"desc", desc[171] },
		},
		{
			zone = 946,
			{"pos", {946}},
			{"questrow",
				{34751, 79870, 946, 64.2, 47.8},
				{35238, 79853, 946, 64.2, 47.8}
			},
			{"desc", desc[171] }
		}
	},
	[207] = { -- 946, 207, Defender Illona (A) / Aeda Brightdawn (H)
		false,
		{
			zone=946,
			{"quest", {34777, 79979, 946, 57.5, 51.1 }, {36519, 79978, 946, 57.5, 51.1 }}
		},
		{
			zone=946,
			{"quest", {34776, 79978, 946, 58.1, 53}, {36518, 79978, 946, 58.1, 53 }}
		}
	},
	[208] = { -- 946, 208, Ahm
		true,
		{
			zone = 946,
			{"quest", {33973, 77031, 946, 56.7, 26}},
			{"desc", {
				enUS = "Gained after an optional quest started by Ahm in Archenon Siegeyard. On your next visit to your garrison, Ahm will be waiting for you near the graveyard. (Tritox/WoWHead)",
				zhTW = "開始於Archenon Siegeyard的阿哈姆其中一個任務完成後後獲得，在您下次訪問您的要塞時，阿哈姆會在墓地附近等候您。",
				zhCN = "开始于Archenon Siegeyard的阿哈姆其中一个任务完成后后获得，在您下次访问您的要塞时，阿哈姆会在墓地附近等候您。",
			}}
		}
	},
	[190] = { -- 946, 190, Image of Archmage Vargoth
		true,
		{
			zone=946,
			{"questrow", 
				{34463, "o229330", 949, 39.7, 39.9},
				{34464, "o229333", 941, 68.0, 19.0},
				{34465, "o229331", 946, 45.3, 37.0},
				{34466, "o229344", 950, 46.4, 16.0},
				{34472, 86949, 946, 85.0, 31.0},
				{36027, 77853, 946, 84.6, 31.6}
			},
			{"desc", {
				enUS = "Found the four mysterious items and bring it to Zooti Fizzlefury for the ritual.",
				deDE = "Finde die vier mysteriösen Gegenstände und bringe sie zu Zooti Zappenduster für das Ritual.",
				zhTW = "發現四個神秘的物品，並把它交給祖提.嘶怒用作進行祈福儀式。",
				zhCN = "发现四个神秘的物品，并把它交给祖提.嘶怒用作进行祈福仪式。",
			}},
		}
	},
	[205] = { -- 946, 205, Soulbinder Tuulani
		true,
		{
			zone=0,
			-- 34458,
			-- 35249,
			-- 34351,
		},
		{
			zone=0,
		}
	}, --- incomplete

	--[=[ shadowmoon valley ]=]
	[179] = { -- 947, 179, Artificer Romuul (A) / Weaponsmith Na'Shral (H)
		false,
		{
			zone = 947,
			{"event", {33038, 74741, 947, 42.8, 40.4}},
			{"quest", {35614, 74741, 947, 42.8, 40.4}},
			{"desc", {
				enUS = "Romuul starts an event where you have to protect him until he does his work.",
				deDE = "Romuul startet ein Ereignis, bei dem man ihn beschützen muss bis er seine Arbeit erledigt hat.",
				zhTW = "羅穆爾開始一個事件時必須要保護他，直到他完成他的工作。",
				zhCN = "罗穆尔开始一个事件时必须要保护他，直到他完成他的工作。",
			}},
			{"img", "1"},
		},
		{
			zone = 941,
			{"quest", {34729, 74977, 941, 65, 39.4}}
		}
	}, --- horde version incomplete
	[180] = { -- 947, 180, Fiona (A) / Shadow Hunter Rala (H)
		false,
		{
			zone = 947,
			{"questrow",
				{33786, 76200, 947, 57, 57.4},
				{33787, 76204, 947, 53.6, 57.2},
				{33808, 76204, 947, 53.6, 57.2},
				{33788, 76204, 947, 53.6, 57.2},
				{35617, 76204, 947, 53.6, 57.2}
			}
		},
		{
			zone = 976,
			{"questrow",
				{34736, 78487, 976, 48.8, 65},
				{34344, 78208, 941, 52.6, 40.4},
				{34345, 78208, 941, 52.6, 40.4},
				{34348, 78208, 941, 52.6, 40.4},
				{34731, 78208, 941, 52.6, 40.4}
			}
		}
	},
	[182] = { -- 947, 182, Shelly Hamby (A)
		false,
		{
			zone = 947,
			{"questrow",
				{34820, 80163, 971, 43.8, 53.4},
				{33263, 79966, 947, 39.6, 29.6},
				{33271, 73877, 947, 47, 14.4},
				{35625, 76748, 947, 36.4, 19.2}
			}
		},
		{
			zone = 941,
		}
	}, --- horde version incomplete
	[183] = { -- 947, 183, Rulkan (A)
		false,
		{
			zone = 947,
			{"quest", {35631, 75884, 947, 45.6, 26.2}}
		},
		{
			zone = 941,
		}
	}, --- incomplete
	--[[
	[186] = { -- 947, 186, Vindicator Onaala (A) / Greatmother Geyah (H)
		false,
		{
			collectGroup="184.185.186",
			zone = 947,
			{"questrow",
				{34787, 80078, 947, 56.5, 23.5},
				{35552, 80073, 947, 62.4, 26.2 },
				{34791, "o233229", 947, 60.9, 24.5},
				{34789, 80073, 946, 62.4, 26.2},
				{34792, 80073, 947, 66.4, 26.2},
				{34788, 80073, 947, 62.4, 26.2}
			},
			{"desc", {
				enUS = "Gained afte completing the Elodor questline. You have to choose between Andren, Chel and Onaala. (Tritox/WoWHead)",
				zhTW = "完成埃羅多爾任務線後獲得的，你需要在三個追隨者之間做出一個選擇。",
				zhCN = "完成埃罗多尔任务线后获得的，你需要在三个追随者之间做出一个选择。",
			}}
		},
		{
			ignore=true,
			collectGroup="184.185.186",
			zone=941,
			{"questrow", 
				{33828, 72940, 941, nil, nil},
				{33493, 72940, 941, nil, nil},
				{37291, 74163, 976, 50, 38.4},
				{34722, 74163, 976, 50, 38.4},
				{33010, 74163, 976, 50, 38.4},
				{34123, 76720, 941, 65.4, 65.6},
				{34124, 76487, 941, 73.4, 58.8},
			}
		}
	}, --- horde version incomplete
	[185] = { -- 947, 185, Rangari Chel (A) / Lokra (H)
		false,
		{
			collectGroup="184.185.186",
			zone = 947,
			{"questrow",
				{34787, 80078, 947, 56.5, 23.5},
				{35552, 80073, 947, 62.4, 26.2 },
				{34791, "o233229", 947, 60.9, 24.5},
				{34789, 80073, 946, 62.4, 26.2},
				{34792, 80073, 947, 66.4, 26.2},
				{34788, 80073, 947, 62.4, 26.2}
			},
			{"desc", {
				enUS = "Gained afte completing the Elodor questline. You have to choose between Andren, Chel and Onaala. (Tritox/WoWHead)",
				zhTW = "完成埃羅多爾任務線後獲得的，你需要在三個追隨者之間做出一個選擇。",
				zhCN = "完成埃罗多尔任务线后获得的，你需要在三个追随者之间做出一个选择。",
			}}
		},
		{
			ignore=true,
			collectGroup="184.185.186",
			zone=941,
			{"questrow", 
				{33828, 72940, 941, nil, nil},
				{33493, 72940, 941, nil, nil},
				{37291, 74163, 976, 50, 38.4},
				{34722, 74163, 976, 50, 38.4},
				{33010, 74163, 976, 50, 38.4},
				{34123, 76720, 941, 65.4, 65.6},
				{34124, 76487, 941, 73.4, 58.8},
			}
		}
	}, --- horde version incomplete
	--]]
	[184] = { -- 947, 184, Apprentice Artificer Andren (A) / Kal'gor the Honorable (H)
		false,
		{
			collectGroup="184.185.186",
			zone = 947,
			{"questrow",
				{34787, 80078, 947, 56.5, 23.5},
				{35552, 80073, 947, 62.4, 26.2 },
				{34791, "o233229", 947, 60.9, 24.5},
				{34789, 80073, 946, 62.4, 26.2},
				{34792, 80073, 947, 66.4, 26.2},
				{34788, 80073, 947, 62.4, 26.2}
			},
			{"desc", {
				enUS = "Gained afte completing the Elodor questline. You have to choose between Andren, Chel and Onaala. (Tritox/WoWHead)",
				zhTW = "完成埃羅多爾任務線後獲得的，你需要在三個追隨者之間做出一個選擇。",
				zhCN = "完成埃罗多尔任务线后获得的，你需要在三个追随者之间做出一个选择。",
			}},
		},
		{
			ignore=true,
			collectGroup="184.185.186",
			zone=941,
			{"questrow", 
				{33828, 72940, 941, nil, nil},
				{33493, 72940, 941, nil, nil},
				{37291, 74163, 976, 50, 38.4},
				{34722, 74163, 976, 50, 38.4},
				{33010, 74163, 976, 50, 38.4},
				{34123, 76720, 941, 65.4, 65.6},
				{34124, 76487, 941, 73.4, 58.8},
			}
		}
	}, --- horde version incomplete?

	--[=[ spikes of arak ]=]
	[168] = { -- 948, 168, Unknown...
		false,
		{
			zone = 948,
		},
		{
			zone = 948,
		}
	}, --- incomplete
	[219] = { -- 948, 219,Leorajh
		true,
		{
			zone = 948,
			{"pos", {948, 55.3, 68.5, "Cave on image 1"}, {948, 55, 65.2, "Hidden cave"}},
			{"desc", {
				enUS = "Find Leorajh's cave at the foot of the mountain. Climb up to the hidden cave and rescue Leorajh.",
				deDE = "Finde Leorajh's Höhle am Fuße des Berges. Steige auf zur versteckten Höhle und rette Leorajh.",
			}},
			{"img", "1", "2", "3"},
		}
	},
	[453] = { -- 948, 453, Hulda Shadowblade (A) / Dark Ranger Velonara (H)
		false,
		{
			zone=948,
			{"requirements", "Brewery in Spikes of Arak outpost"},
			{"quest", {37281, 88195, 948, 39.6, 60.8}}
		},
		{
			zone=948,
			{"requirements", "Brewery in Spikes of Arak outpost"},
			{"quest", {37276, 88179, 948, 40, 43.2}}
		}
	}, --- incomplete
	[192] = { -- 948, 192, Kimzee Pinchwhistle
		false,
		{
			zone=948,
			{"questrow",
				{35619, 85550, 948, 39.6, 60.6, nil, 36861, 86589, 976, 46, 46.2},
				{35077, 81109, 948, 61.4, 72.8},
				{35080, 81109, 948, 61.4, 72.8},
				{35082, 81773, 948, 59, 79.2},
				{35285, 81784, 948, 59, 79.2},
				{35090, 81972, 948, 58.4, 92.2},
				{35091, 81978, 948, 58.8, 92.8},
				{36384, 81443, 948, 58.4, 92.2},
				{36428, 81443, 948, 58.4, 92.2},
				{35211, 81443, 948, 58.4, 92.2},
				{35298, 81443, 948, 58.4, 92.2},
				{36062, 82468, 948, 61.6, 72.8}
			}
		},
		{
			zone=948,
			{"questrow",
				{35620, 85566, 948, 40, 43.8, nil, 36862, 85514, 971, 46.8, 46.2},
				{35077, 81109, 948, 61.4, 72.8},
				{35080, 81109, 948, 61.4, 72.8},
				{35082, 81773, 948, 59, 79.2},
				{35285, 81784, 948, 59, 79.2},
				{35090, 81972, 948, 58.4, 92.2},
				{35091, 81978, 948, 58.8, 92.8},
				{36384, 81443, 948, 58.4, 92.2},
				{36428, 81443, 948, 58.4, 92.2},
				{35211, 81443, 948, 58.4, 92.2},
				{35298, 81443, 948, 58.4, 92.2},
				{36062, 82468, 948, 61.6, 72.8}
			}
		}
	},
	[204] = { -- 948, 204, Admiral Taylor (A) / Benjamin Gibb (H)
		false,
		{
			zone=948,
		},
		{
			zone=948,
		}
	}, --- incomplete
	[224] = { -- 948, 224, Talon Guard Kurekk
		true,
		{
			zone = 948,
			{"achievement", 9072}
		},
	},
	[218] = { -- 948, 218, Talonpriest Ishaal
		true,
		{
			zone=948,
			{"achievement", 8925}
		},
		{
			zone=948,
			{"achievement", 8926}
		}
	},

	--[=[ garrison ]=]
	[153] = { -- 971/976, 153, Bruma Swiftstone (A) / Ka'la (H)
		false,
		{
			zone = 971,
			{"mission", 66},
		},
		{
			zone = 976,
			{"mission", 2},
		}
	},
	[455] = { -- 971/976, 455, Millhouse Manastorm
		false,
		{
			zone = 971,
			{"requirements", "Lunarfall Inn"},
			{"quest", {37179, 88009, 971, "Lunarfall Inn"}}
		},
		{
			zone = 976,
			{"requirements", "Frostwall Tavern"}, 
			{"quest", {37179, 88009, 976, "Frostwall Tavern"}}
		}
	},
	[202] = { -- 971/976, 202, Nat Pagle
		false,
		{
			zone = 971,
			{"requirements", "Fishing Shack 3", "Fishing skill 700"},
			{"questrow",
				{36611, 85984, 971, "Fishing Shack"},
				{36616, 85984, 971, "Fishing Shack"}
			}
		},
		{
			zone = 976,
			{"requirements", "Fishing Shack 3", "Fishing skill 700"},
			{"questrow",
				{36611, 85984, 976, "Fishing Shack"},
				{36616, 85984, 976, "Fishing Shack"}
			}
		}
	},
	[216] = { -- 971/976, 216, Delvar Ironfist (A) / Vivianne (H)
		false,
		{
			zone = 971,
			{"desc", {
				enUS = "Follow the quest row starting with \"Ashran Appearance\" and at the end Delvar Ironfist will offer its following",
			}},
			{"questrow",
				{36624, 79953, 971, 40.6, 53.6},
				{36626, 86065, 1009, 31.8, 49.6},
				{36629, 86069, 1009, 35.6, 75.4},
				{36630, 86069, 1009, 35.6, 75.4},
				{36633, 86084, 1009, 47.6, 30.6}
			}
		},
		{
			zone = 941,
			{"desc", {
				enUS = "Follow the quest row starting with \"Ashran Appearance\" and at the end Vivianne will offer his following",
			}},
			{"questrow", 
				{36706, 78466, 976, 52.4, 52.8},
				{36707, 86315, 1011, 45.2, 34.6},
				{36708, 86312, 1011, 44.4, 45.2},
				{36709, 86312, 1011, 44.4, 45.2},
				{35243, 81765, 1011, 61.8, 23.4}
			}
		}
	},
	[34] =  { -- 971/976, 34, Qiana Moonshadow (Alliance) / Olin Umberhide (Horde)
		false,
		{
			zone = 971,
			{"quest", {34646, 79457, 971, 44, 52.8}},
		},
		{
			zone = 976,
			{"questrow",
				{33868, 0, 976, 0, 0}, 
				{33815, 76411, 976, 49.2, 50}, -- Farseeker Drek'Thar
				{34402, 78272, 941, 41.8, 69.6}, -- Durotan
				{34364, 70859, 941, 48.6, 65.2}, -- Thrall
				{34375, 78466, 976, 42, 55}, -- Gazlowe
				{34378, 78466, 976, 42, 55}, -- Gazlowe
				{34822, 78466, 976, 42, 55}, -- Gazlowe
				{34461, 78466, 976, 42, 55}, -- Gazlowe
				{34861, 78466, 976, 42, 55}, -- Gazlowe
				{34462, 79740, 976, 53.8, 54.2}, -- Warmaster Zog
			},
		}
	}, --- incomplete
	[458] = { -- 971/976, 458, Vindicator Heluun / Cacklebone
		false,
		{
			zone = 971,
			{"vendor", {85427, 971, "Trading Post"}},
			{"requirements", "Trading Post 2"},
			{"reputation", {1710, 7}},
			{"payment", {"gold", 50000000}},
		},
		{
			zone = 976,
			{"vendor", {88493, 976, "Trading Post"}},
			{"requirements", "Trading Post 2"},
			{"reputation", {1708, 7}},
			{"payment", {"gold", 50000000}},
		}
	},
	[463] = { -- 971/976, 463, Daleera Moonfang (A) / Ulna Thresher (H)
		false,
		{
			zone = 971,
			{"mission", 91},
		},
		{
			zone = 976,
			{"mission", 7},
		}
	},
	[217] = { -- 971/976, 217, Thisalee Crow / Choluna
		false,
		{
			zone = 0,
		},
		{
			zone = 0,
		}
	}, --- incomplete

	--[=[ anywhere in draenor ]=]
	[203] = { -- 962, 203, Meatball
		true,
		{
			zone = 962,
			{"requirements", "Brawler's Guild Rank 5"}
		}
	},
	[194] = { -- 962, 194, Phylarch the Evergreen
		true,
		{
			zone = 962,
			{"pos", {962, nil, nil, "Random location"}},
			{"requirements", "Lumber mill (Level 3)"},
			{"desc", {
				enUS = "In cases of trees being attacked by him. He disappears with little life. This is a few times until he surrenders.",
				deDE = "Beim fällen von Bäumen wird man von ihm angegriffen. Er verschwindet mit wenig Leben. Das geht ein paar mal so bis er sich ergibt.",
				zhTW = "在被他被追趕的情況下開始攻擊。他只剩一點血時會消失。持續好幾次，直到他投降。",
				zhCN = "在被他被追赶的情况下开始攻击。他只剩一点血时会消失。持续好几次，直到他投降。",
			}}
		}
	},
	[195] = { -- 962, 195, Weldon Barov (A) / Alexi Weldon (H)
		false,
		{
			zone = 962,
			{"pos", {962, nil, nil, "Random location"}},
			{"requirements", "Lumber mill"},
			{"img", "1"},
			{"desc", desc[195]}
		},
		{
			zone = 962,
			{"pos", {962, nil, nil, "Random location"}},
			{"requirements", "Lumber mill"},
			{"img", "1"},
			{"desc", desc[195] }
		}
	},

	--[=[ raids ]=]
	[225] = { -- 988, 225, Aknor Steelbringer
		true,
		{
			zone = 988,
			{"achievement", 8929}
		},
	},

	--[=[ dungeons ]=]
	[177] = { -- 964, 177, Croman
		true,
		{
			zone = 964,
			{"pos", {964, "Dungeon type: Herioc, coordinations unknown..."}},
			{"achievement", 9005}
		}
	},
	[178] = { -- 995, 178, Leeroy Jenkins
		true,
		{
			zone = 995,
			{"achievement", 9058}
		}
	},

	--[=[ gorgrond ]=]
	[159] = { -- 949, 159, Rangani Kaalya (A) / Kaz the Shrieker (H)
		false,
		{
			zone = 949,
			{"questrow",
				{35225, 81588, 949, 46.0, 76.8},
				{35234, 75710, 949, 47.6, 94.0},
				{35235, 81751, 949, 48.0, 94.2},
				{35262, 81772, 949, 47.6, 93.2},
			},
		},
		{
			zone = 949,
			{"quest",
				{35511, 82338, 949, 47.6, 93.2},
			},
		}
	}, --- incomplete
	[176] = { -- 949, 176, Pitfighter Vaandaam (A) / Bruto (H)
		false,
		{
			zone = 949,
			{"requirements", "Sparring Arena in gorgrond outpost"},
			{"questrow",
				{34704, 81076, 949, 53.0, 59.6},
				{34699, 79322, 949, 42.8, 63},
				{34703, 77014, 949, 42.8, 63},
				{35137, 0, 949, 0, 0},
			}
		},
		{
			zone = 949,
		}
	}, --- incomplete
	[189] = { -- 949, 189, Blook
		true,
		{
			zone=949,
			{"pos", {949, 42.8, 90.9, "Beginning of the path to blook"}},
			{"quest", {34279, 78030, 949, 41.2, 91.4}},
		}
	}, --- add screenshots
	[193] = { -- 949, 193, Tormmok
		true,
		{
			zone = 949,
			{"pos", {949, 44.9, 86.6}},
			{"desc", {
				enUS = "Help him to defend himself. Then he is friendly and can be recruited.",
				deDE = "Helft ihm sich zu verteidigen. Danach wird er freundlich und kann rekrutiert werden.",
				zhTW = "幫助他與保護他，然後他會是友好的，并且可以被招募。",
				zhCN = "帮助他与保护他，然后他会是友好的，并且可以被招募。",
			}}
		}
	}, --- add screenshots
	[211] = { -- 949, 211, Glirin (A) / Penny Clobberbottom (H)
		false,
		{
			zone = 949,
			{"requirements", "Lumber mill in gorgrond outpost"},
			{"quest", {36828, 85119, 949, 53, 59.4}}
		},
		{
			zone=949,
			{"requirements", "Lumber mill in gorgrond outpost"},
			{"questrow", 
				{35707, 85077, 949, 46.4, 69.6},
				{35506, 82574, 949, 55.8, 71.4},
				{35505, 84811, 949, 55.8, 71.4},
				{35508, 82569, 949, 57, 71.8},
				{35527, 82569, 949, 57, 71.8},
				{35524, 82569, 949, 57, 71.8},
				{36812, 85077, 949, 46.4, 69.6}
			}
		}
	}, --- incomplete, missing quest row
	[212] = { -- 949, 212, Rangari Erdanii (A) / Spirit of Bony Xuk (H)
		false,
		{
			zone=949,
			{"quest", {36833, 85278, 949, 53.2, 59.8}} -- Quest: Eiserne Ketten ?
		},
		{
			zone=949,
			{"quest", {36832, 85980, 949, 44, 48.8}} --  Quest: Ist Xais egal ?
		}
	},

	--[=[ nagrand ]=]
	[157] = { -- 950, 157, Lantresor of the Blade
		false,
		{
			zone = 950,
			modelRace = "OrcM",
			{"questrow", 
				{34951, 80624, 950, 63.4, 61.8},
				{34954, 80161, 950, 85.4, 54.6},
				{34955, 80161, 950, 85.4, 54.6},
				{35148, 79954, 950, 63.4, 61.8},
				{34593, 79282, 950, 78.8, 69.2},
				{34956, 80161, 950, 85.4, 54.6},
				{35061, 81086, 950, 55.4, 42.2},
				{34596, 81144, 950, 84, 76.8},
				{34957, 80319, 950, 89.8, 55.8},
				{35062, 81039, 950, 62, 40.4},
				{35169, 79576, 950, 63.6, 61.8},
			},
			{"desc", {
				enUS = "You can find Lantresort after completing the quest line near the outpost.",
				deDE = "Du findest Lantresor nach Abschluss der Questreihe in der Nähe des Außenpostens.",
			}}
		},
		{
			zone = 950,
		}
	}, --- incomplete
	[170] = { -- 950, 170, Goldmane the Skinner
		true,
		{
			zone = 950,
			{"pos", {950, 40.4, 76.2}},
			{"quest", {35596, 80083, 950, 40.4, 76.2}},
			{"desc", {
				enUS = "Kill Bolkar the Cruel and loot the key for Goldmane's cage. Than open the cage and Goldmane will offer you his following.",
				deDE = "Töte 'Bolkar der Grausame' und erbeute den Schlüssel zu Goldmähne's Käfig. Dann öffne den Käfig und Goldmähne wird seine Gefolgschaft anbieten."
			}}
		}
	},
	[209] = { -- 950, 209, Abu'gar
		true,
		{
			zone=950,
			{"pos",
				{950, 38.3, 49.4, "Abu'Gar's Favorite Lure"},
				{950, 65.8, 61.1, "Abu'Gar's Vitality"},
				{950, 85.4, 38.7, "Abu'Gar's Finest Reel"},
				{950, 67.2, 56, "Abu'gar himself"},
			},
			{"desc", {
				enUS = "Collect Abu'Gar's fishing equipment and bring it him",
				deDE = "Sammel Abu'gars Angelausrüstung und bringe sie ihm",
			}}
		},
	},

	--[=[ ashran ]=]
	[459] = { -- 1009/1011, 459, Cleric Maluuf (A) / Karg Bloodfury (H)
		false,
		{
			zone = 1009,
			{"vendor", {85932, 1009, 46.6, 76.2}},
			{"reputation", {1731, 7}},
			{"payment", {"gold", 50000000}},
		},
		{
			zone = 1011,
			{"vendor", {86036, 1011, 53.4, 62.6}},
			{"reputation", {1445, 7}},
			{"payment", {"gold", 50000000}},
		}
	},
	[460] = { -- 1009/1011, 460, Felbast
		false,
		{
			zone = 1009,
			{"vendor", {88482, 1009, 43.2, 77.4}},
			{"reputation", {1711, 7}},
			{"payment", {"gold", 50000000}},
		},
		{
			zone = 1011,
			{"vendor", {88493, 1011, 53.8, 60.8}},
			{"reputation", {1711, 7}},
			{"payment", {"gold", 50000000}},
		}
	},
	[462] = { -- 1009/1011, 462, Dawnseeker Rukaryx
		false,
		{
			zone = 1009,
			{"vendor", {86391, 1009, 49.9, 61.4}},
			{"payment", {823,5000}, {"gold", 50000000}},
		},
		{
			zone = 1011,
			{"vendor", {86382, 1011, 64.6, 61.8}},
			{"payment", {823,5000}, {"gold", 50000000}},
		}
	},
};

-- collection group members data copy
ns.followers[185] = ns.followers[184];
ns.followers[186] = ns.followers[184];


--[=[ some strings for localization collector script ]=]
--[[
	L["Arcane sanctum in talador outpost"]
	L["Appears on your position"]
	L["Cave on image 1"]
	L["Hidden cave"]
	L["Brewery in Spikes of Arak outpost"]
	L["Random location"]
	L["Lumber mill"]
	L["Lumber mill (Level 3)"]
	L["Brawler's Guild Rank 5"]
	L["Trading Post"]
	L["Trading Post 2"]
	L["Fishing Shack 3"]
	L["Fishing skill 700"]
	L["Lunarfall Inn"]
	L["Frostwall Tavern"]
	L["Dungeon type: Herioc, coordinations unknown..."]
	L["Beginning of the path to blook"]
	L["Sparring Arena in gorgrond outpost"]
	L["Abu'Gar's Favorite Lure"]
	L["Abu'Gar's Vitality"]
	L["Abu'Gar's Finest Reel"]
	L["Abu'gar himself"]
	L["Lumber mill in gorgrond outpost"]
--]]
