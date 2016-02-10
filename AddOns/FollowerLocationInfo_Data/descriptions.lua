
local _ = FollowerLocationInfoData.descriptions;

local outpost_alternative_info = "You've choosed the other outpost building?|nYou have two alternatives.|n1. Reset your outpost building by talking with an NPC in the outpost.|n2. Buy a contract in your garrison.";


--[=[ 941 Frostfire Ridge ]=]
	_[32] = { -- 941, 32, Dagg
		nil,
		{
			zone = 941,
			{"Location",
				{941, 65.9, 60.8, Images={ {"location1","Image",false} } },
				{941, 39.6, 28.0, Images={ {"location2","Image",false} } }
			},
			{"Quests", {34733, 90, 79492, 971, 54.8, 69.4, Images={ {"quest","Image",true} }}}
		},
		{
			zone = 941,
			{"Location",
				{941, 65.9, 60.8, Images={ {"location1","Image",false} } },
				{941, 39.6, 28.0, Images={ {"location2","Image",false} } }
			},
			{"Quests", {34733, 90, 79492, 976, 57.76, 15.45, Images={ {"quest","Image",true} }}}
		}
	};

--[=[ 946 Talador ]=]
	_[154] = { -- 946, 154, Magister Serenaa (A) / Magister Krelas (H)
		nil,
		{
			zone = 946,
			{"Requirements", {"Outpost", 946, 1}},
			{"Quests",
				{34631, 94, 79133, 946, 69.8, 20.8},
				{34815, 94, 80142, 946, 75, 31},
				--
				{34609, 94, 79392, 946, 84.8, 31},
				{34612, 94, 79392, 946, 84.8, 31},
				{34619, 94, 79392, 946, 84.8, 31},
				{34875, 94, 80260, 946, nil}, -- TODO: location
				{34908, 94, 80966, 946, 69.6, 21},
				--
				{34913, 94, 80607, 946, 62.2, 68.2},
				{34909, 94, 80608, 946, 69.8, 69.4},
				{34910, 94, 80608, 946, 69.8, 69.4},
				{34911, 94, 80608, 946, 69.8, 69.4},
				{34912, 94, 80617, 946, nil}, -- appears on your side if you finished the 3 quests from serena
				{34711, 94, 80617, 946, nil},
				--
				{34993, 94, 80672, 946, 69.6, 20.8}
			},
		},
		{
			zone = 946,
			{"Requirements", {"Outpost", 946, 1}},
			{"Quests",
				{34632, 94, 79176, 946, 71, 29.8},
				{34814, 94, 80142, 946, 75, 31},
				--
				{34634, 94, 79393, 946, 84.2, 30.4},
				{34635, 94, 79393, 946, 84.2, 30.4},
				{34636, 94, 79393, 946, 84.2, 30.4},
				{34874, 94, 80193, 946, nil}, -- TODO: location
				{34878, 94, 80965, 946, 71.2, 39.6},
				{34879, 94, 80396, 946, 62.2, 68.2},
				--
				{34887, 94, 80390, 946, 68.2, 70.2},
				{34889, 94, 80390, 946, 68.2, 70.2},
				{34890, 94, 80389, 946, nil},
				{34712, 94, 80389, 946, nil},
				--
				{34949, 94, 80553, 946, 71.2, 29.8}
			},
		}
	};

	_[155] = { --  946, 155, Miall (A) / Morketh Bladehowl (H)
		nil,
		{
			zone = 946,
			{"Requirements", {"Outpost", 946, 2}},
			{"Quests",
				{34563, 94, 79160, 946, 69.2, 19.2},
				{34571, 94, 79159, 946, 69.2, 19.2},
				{34573, 94, 79329, 946, 70.0, 20.0},
				{34624, 94, 79329, 946, 70.0, 20.0},
				{34578, 94, 79329, 946, 70.0, 20.0},
				{34976, 94, 80627, 946, 62.4, 67.8},
				{34977, 94, 80628, 946, 69.6, 69.8},
				{34980, 94, 80632, 946, 64.4, 81.8},
				{34981, 94, 80630, 946, 64.4, 81.8},
				{34982, 94, 80968, 946, 69.6, 20.8}
			},
		},
		{
			zone = 946,
			{"Requirements", {"Outpost", 946, 2}},
			{"Quests",
				{34579, 94, 79356, 946, 70.8, 30.4},
				{34837, 94, 79356, 946, 70.8, 30.4},
				{34840, 94, 80229, 946, 62.0, 69.2},
				{34855, 94, 80339, 946, 68.6, 70.4},
				{34858, 94, 80339, 946, 68.6, 70.4},
				{34860, 94, 80339, 946, 68.6, 70.4},
				{34870, 94, 80341, 946, "Appears on your position" },
				{34971, 94, 80342, 946, 64.4, 81.6},
				{34972, 94, 80623, 946, 71.2, 29.8}
			},
		}
	};

	_[171] = { --  946, 171, Pleasure-Bot 8000
		nil,
		{
			zone = 946,
			{"Location", {946, 62.9, 50.3, Images={{"location","Image",true}} }},
			{"Quests",
				{34761, 94, 79901, 946, 62.8, 50.2},
				{35239, 94, 79853, 946, 62.8, 50.4}
			}
		},
		{
			zone = 946,
			{"Location", {946, 64.2, 47.8, Images={{"location","Image",true}} }},
			{"Quests",
				{34751, 94, 79870, 946, 64.2, 47.8},
				{35238, 94, 79853, 946, 64.2, 47.8}
			}
		}
	};

	_[190] = { --  946, 190, Image of Archmage Vargoth
		{
			zone=946,
			{"Items",
				{110459, 941, 68.0, 19.0},
				{110469, 949, 39.7, 39.9},
				{110470, 946, 45.3, 37.0},
				{110471, 950, 46.4, 16.0}
			},
			{"Quests", 
				{34472, 100, 86949, 946, 85.0, 31.0},
				{36027, 100, 77853, 946, 84.6, 31.6}
			}
		}
	};

	_[205] = { --  946, 205, Soulbinder Tuulani
		nil,
		{
			zone=946,
			{"Quests", 
				{34240, 95, 75250, 946, 57.2, 77},
				{33958, 95, 75256, 946, 57.2, 76.8},
				{34508, 95, 77869, 946, 50.4, 87.4},
				{33976, 95, 77082, 946, 44.8, 90.6},
				{34326, 95, 77082, 946, 44.8, 90.6},
				{34092, 95, 77799, 946, 43.4, 76},
				{34157, 95, 75392, 946, 43, 76},
				{34154, 95, 77582, 946, 31.2, 73.6},
				{36512, 95, 79434, 946, 46.2, 74},
			}
		},
		{
			zone = 946,
			{"Quests",
				{34242, 95, 75246, 946, 61, 72.4},
				{33958, 95, 75256, 946, 57.2, 76.8},
				{34508, 95, 77869, 946, 50.4, 87.4},
				{33976, 95, 77082, 946, 44.8, 90.6},
				{34326, 95, 77082, 946, 44.8, 90.6},
				{34092, 95, 77799, 946, 43.4, 76},
				{34157, 95, 75392, 946, 43, 76},
				{34154, 95, 77582, 946, 31.2, 73.6},
				{36512, 95, 79434, 946, 46.2, 74},
			}
		}
	};

	_[207] = { --  946, 207, Defender Illona (A) / Aeda Brightdawn (H)
		nil,
		{
			zone=946,
			{"Quests",
				{34777, 94, 79979, 946, 57.5, 51.1},
				{36519, 94, 79978, 946, 57.5, 51.1}
			}
		},
		{
			zone=946,
			{"Quests",
				{34776, 94, 79978, 946, 58.1, 53},
				{36518, 94, 79978, 946, 58.1, 53}
			}
		}
	};

	_[208] = { --  946, 208, Ahm
		nil,
		{
			zone = 946,
			{"Quests",
				{33973, 94, 77031, 946, 56.7, 26, Images={{"location","Image",false}}},
				{36522, 94, 85777, 971, 52.8, 69}
			}
		},
		{
			zone = 946,
			{"Quests",
				{33973, 94, 77031, 946, 56.7, 26, Images={{"location","Image",false}}},
				{36522, 94, 85777, 976, 50.8, 15.8}
			}
		}
	};

	_[466] = { --  946, 466, Garona Halforcen
		{
			zone = 946,
			{"Quests",
				{36007, 100, 83823, 964, 85.2, 31.6},
				{36009, 100, 83823, 964, 85.2, 31.6},
				{36010, 100, 83823, 964, 85.2, 31.6},
				{36012, 100, 83823, 964, 85.2, 31.6},
				{36013, 100, 83823, 964, 85.2, 31.6},
				{36014, 100, 83823, 964, 85.2, 31.6},
				{36016, 100, 83823, 964, 85.2, 31.6},
				{36017, 100, 83823, 964, 85.2, 31.6},
				{37834, 100, 83823, 964, 85.2, 31.6},
				{37836, 100, 83823, 964, 85.2, 31.6},
				{37964, 100, 83823, 964, 85.2, 31.6},
				{37837, 100, 90233, 946, 67.4, 6.6}
			}
		}
	};

--[=[ 947 Shadowmoon Valley ]=]
	_[179] = { --  947, 179, Artificer Romuul (A) / Weaponsmith Na'Shral (H)
		nil,
		{
			zone = 947,
			{"Quests",
				{35614, 90, 74741, 947, 42.8, 40.4, Images={{"quest","Image",true}}}
			}
		},
		{
			zone = 941,
			{"Quests",
				{33838, 90, 74977, 941, 64.9, 39.5, Images={{"quest","Image",true}}},
				{34729, 90, 74977, 941, 64.7, 39.8}
			}
		}
	};

	_[180] = { --  947, 180, Fiona (A) / Shadow Hunter Rala (H)
		nil,
		{
			zone = 947,
			{"Quests",
				{33786, 90, 76200, 947, 57, 57.4},
				{33787, 90, 76204, 947, 53.6, 57.2},
				{33808, 90, 76204, 947, 53.6, 57.2},
				{33788, 90, 76204, 947, 53.6, 57.2},
				{35617, 90, 76204, 947, 53.6, 57.2}
				-- giftstarre
			}
		},
		{
			zone = 976,
			{"Quests",
				{34736, 90, 78487, 976, 48.8, 65, optional=true},
				{34344, 90, 78208, 941, 52.62, 40.41},
				{34345, 90, 78208, 941, 52.62, 40.41},
				{34346, 90, 78209, 941, 52.52, 40.42},
				{34348, 90, 78208, 941, 52.62, 40.41},
				{34731, 90, 78208, 941, 52.62, 40.41}
			}
		}
	};

	_[182] = {	-- 947, 182, Shelly Hamby (A)
		nil,
		{
			zone = 947,
			{"Quests",
				{34820, 90, 80163, 971, 43.8, 53.4},
				{33263, 90, 79966, 947, 39.6, 29.6},
				{33271, 90, 73877, 947, 47, 14.4},
				{35625, 90, 76748, 947, 36.4, 19.2}
			}
		},
		{
			zone = 941,
			{"Requirements",
				{"Unlock", 33527, "First you must unlock the Bladespire Citadel quest row to see Guse."},
			},
			{"Quests",
				-- not enough
				-- 
				{33119, 90, 78222, 941, 24.4, 37.2},
				{33483, 90, 72890, 941, 30.8, 41.4},
				{33484, 90, 79047, 941, 30.6, 41.4},
				{34732, 90, 79047, 941, 30.6, 41.4}
			}
		}
	};

	_[183] = { --  947, 183, Rulkan (A)
		nil,
		{
			zone = 947,
			{"Quests", {35631, 90, 75884, 947, 45.6, 26.2}}
		},
		{
			zone = 941,
			{"Quests", {35341, 90, 79229, 941, 59.4, 31.8}}
		}
	}; -- TODO: incomplete?

	_[184] = {	-- 947, 184, Apprentice Artificer Andren (A) / Kal'gor the Honorable (H)
		nil,	-- 947, 185, Rangari Chel (A) / Lokra (H)
		{		-- 947, 186, Vindicator Onaala (A) / Greatmother Geyah (H)
			collectGroup={184,185,186},
			zone = 947,
			{"Quests",
				{34787, 90, 80078, 947, 56.5, 23.5},
				{35552, 90, 80073, 947, 62.4, 26.2 },
				{34791, 90, 0.233229, 947, 60.9, 24.5},
				{34789, 90, 80073, 946, 62.4, 26.2},
				{34792, 90, 80073, 947, 66.4, 26.2},
				{34788, 90, 80073, 947, 62.4, 26.2}
			},
			alternative = {
				{"Merchant", {88633, 971, 58.4, 60.4}},
				{"Items",
					{119291, id=184},
					{119296, id=185},
					{119292, id=186}
				},
				{"Price", {"Gold", 50000000}},
				visible = {"quest", 34788}
			}
		},
		{
			collectGroup={184,185,186},
			zone=941,
			{"Quests", 
				{33828, 90, 72940, 941, nil, nil, "The Frostwolf Champion will follow you in frostfire ridge"}, -- TODO: check?
				{33493, 90, 72940, 941, nil, nil},
				{37291, 90, 74163, 976, 50, 38.4},
				{34722, 90, 74163, 976, 50, 38.4},
				{33010, 90, 74163, 976, 50, 38.4},
				{34123, 90, 76720, 941, 65.4, 65.6},
				{34124, 90, 76487, 941, 73.4, 58.8},
			},
			alternative = {
				{"Merchant", {88635, 976, 40.32, 51.04}},
				{"Items",
					{122136, id=184},
					{119240, id=185},
					{122135, id=186}
				},
				{"Price", {"Gold", 50000000}},
				visible = {"quest", 34124}
			}
		},
	}; -- TODO: horde version incomplete?

--[=[ 948 Spikes of Arak ]=]
	_[168] = { --  948, 168, Ziri'ak
		nil,
		{
			zone = 948,
			{"Requirements", {"Outpost", 948, 1}},
			{"Merchant", {82459, 948, "summoned in near of the player position"}},
			{"Spell", 170108},
			{"Items", {116915}},
			{"Price", {"Gold", 4000000}},
			alternative = {
				{"Merchant", {88633, 971, 58.4, 60.4}},
				{"Items", {}},
				{"Price", {"Gold", 50000000}},
				visible = true,
				text = outpost_alternative_info
			}
		},
		{
			zone = 948,
			{"Requirements", {"Outpost", 948, 1}},
			{"Merchant", {84243, 948, "summoned in near of the player position"}},
			{"Spell", 170097},
			{"Items", {116915}},
			{"Price", {"Gold", 4000000}},
			alternative = {
				{"Merchant", {88635, 976, 40.32, 51.04}},
				{"Items", {}},
				{"Price", {"Gold", 50000000}},
				visible=true,
				text = outpost_alternative_info
			}
		}
	};

	_[192] = { --  948, 192, Kimzee Pinchwhistle
		nil,
		{
			zone=948,
			{"Quests",
				{35619, 96, 85550, 948, 39.6, 60.6, nil, 36861, 86589, 976, 46, 46.2},
				{35077, 96, 81109, 948, 61.4, 72.8},
				{35080, 96, 81109, 948, 61.4, 72.8},
				{35082, 96, 81773, 948, 59, 79.2},
				{35285, 96, 81784, 948, 59, 79.2},
				{35090, 96, 81972, 948, 58.4, 92.2},
				{35091, 96, 81978, 948, 58.8, 92.8},
				{36384, 96, 81443, 948, 58.4, 92.2},
				{36428, 96, 81443, 948, 58.4, 92.2},
				{35211, 96, 81443, 948, 58.4, 92.2},
				{35298, 96, 81443, 948, 58.4, 92.2},
				{36062, 96, 82468, 948, 61.6, 72.8}
			}
		},
		{
			zone=948,
			{"Quests",
				{35620, 96, 85566, 948, 40, 43.8, nil, 36862, 85514, 971, 46.8, 46.2},
				{35077, 96, 81109, 948, 61.4, 72.8},
				{35080, 96, 81109, 948, 61.4, 72.8},
				{35082, 96, 81773, 948, 59, 79.2},
				{35285, 96, 81784, 948, 59, 79.2},
				{35090, 96, 81972, 948, 58.4, 92.2},
				{35091, 96, 81978, 948, 58.8, 92.8},
				{36384, 96, 81443, 948, 58.4, 92.2},
				{36428, 96, 81443, 948, 58.4, 92.2},
				{35211, 96, 81443, 948, 58.4, 92.2},
				{35298, 96, 81443, 948, 58.4, 92.2},
				{36062, 96, 82468, 948, 61.6, 72.8}
			}
		}
	};

	_[204] = { --  948, 204, Admiral Taylor (A) / Benjamin Gibb (H)
		nil,
		{
			zone=948,
			{"Quests",
				{35293, 96, 81949, 948, 39.8, 60.6},
				{35322, 96, 81961, 948, 39.2, 48.8},
				{35329, 96, 81960, 948, 39, 48.8},
				{35339, 96, 82100, 948, 39, 48.8},
				{35353, 96, 82124, 948, 37.6, 51},
				{35380, 96, 82126, 948, 37.6, 50.8},
				{35407, 96, 82194, 948, 37.6, 53.8},
				{35408, 96, 82212, 948, 37.6, 53.8},
				{35482, 96, 82278, 948, 37.6, 53.8},
				{35549, 96, 82403, 948, 36.8, 56.8},
				{36353, 96, 85050, 948, 40, 60.6}
			}
		},
		{
			zone=948,
			--{"Quests", },
			{"Location", {948, 35.8, 52.2}},
		}
	}; -- TODO: horde version incomplete

	_[218] = {	-- 948, 218, Talonpriest Ishaal
		nil,
		{
			zone=948,
			{"Achievements", 8925}
		},
		{
			zone=948,
			{"Achievements", 8926}
		}
	};

	_[219] = { --  948, 219, Leorajh
		{
			zone = 948,
			{"Location",
				{948, 55.3, 68.5, "Cave on image 1"},
				{948, 55, 65.2, "Hidden cave"}
			},
			--{"Images", {"1","Image 1",false}, {"2","Image 2",false}, {"3","Image 3",false} }
		}
	}; -- TODO: make new images. better path way and air picture from hidden cave

	_[224] = { --  948, 224, Talon Guard Kurekk
		{
			zone = 948,
			{"Achievements", 9072},
			{"Quests",{37144, 100, 80578, 948, 54.1, 37.0}}
		}
	};

	_[453] = { --  948, 453, Hulda Shadowblade (A) / Dark Ranger Velonara (H)
		nil,
		{
			zone=948,
			{"Requirements", {"Outpost", 948, 2}},
			{"Quests", {37281, 96, 88195, 948, 39.6, 60.8}}
		},
		{
			zone=948,
			{"Requirements", {"Outpost", 948, 2}},
			{"Quests", {37276, 96, 88179, 948, 40, 43.2}}
		}
	}; -- TODO: incomplete

--[=[ 949 Gorgrond ]=]
	_[159] = { --  949, 159, Rangani Kaalya (A) / Kaz the Shrieker (H)
		nil,
		{
			zone = 949,
			{"Quests",
				{35225, 94, 81588, 949, 46.0, 76.8},
				{35234, 94, 75710, 949, 47.6, 94.0},
				{35235, 94, 81751, 949, 48.0, 94.2},
				{35262, 94, 81772, 949, 47.6, 93.2},
			},
		},
		{
			zone = 949,
			{"Quests",
				{35511, 94, 82338, 949, 47.6, 93.2},
			},
		}
	}; -- TODO: incomplete

	_[176] = { --  949, 176, Pitfighter Vaandaam (A) / Bruto (H)
		nil,
		{
			zone = 949,
			{"Requirements", {"Outpost", 949, 2}},
			{"Quests",
				{34704, 93, 81076, 949, 53.0, 59.6},
				{34699, 93, 79322, 949, 42.8, 63},
				{34703, 93, 77014, 949, 42.8, 63},
				{35137, 93, 79322, 949, 42.8, 63},
			}
		},
		{
			zone = 949,
			{"Requirements", {"Outpost", 949, 2}},
			--{"Quests", {35882, nil} },
			--{"note", "missing quest row data and quest giver positions... not enough found on wowhead.", "ff9922"}
		}
	}; -- TODO: incomplete

	_[189] = { --  949, 189, Blook
		{
			zone=949,
			{"Location", {949, 42.8, 90.9, "Path to Blook", Images={{"location","Image",false}} }},
			{"Quests", {34279, 93, 78030, 949, 41.2, 91.4}},
		}
	};

	_[193] = { --  949, 193, Tormmok
		{
			zone = 949,
			{"Location", {949, 44.9, 86.6, Images={{"location","Image",false}} }}
		}
	};

	_[211] = { --  949, 211, Glirin (A) / Penny Clobberbottom (H)
		nil,
		{
			zone = 949,
			{"Requirements", {"Outpost", 949, 1}},
			{"Quests", {36828, 92, 85119, 949, 53, 59.4}}
		},
		{
			zone=949,
			{"Requirements", {"Outpost", 949, 1}},
			{"Quests", 
				{35707, 92, 85077, 949, 46.4, 69.6},
				{35506, 92, 82574, 949, 55.8, 71.4},
				{35505, 92, 84811, 949, 55.8, 71.4},
				{35508, 92, 82569, 949, 57, 71.8},
				{35527, 92, 82569, 949, 57, 71.8},
				{35524, 92, 82569, 949, 57, 71.8},
				{36812, 92, 85077, 949, 46.4, 69.6}
			}
		}
	}; -- TODO: incomplete, missing quest row

	_[212] = { --  949, 212, Rangari Erdanii (A) / Spirit of Bony Xuk (H)
		nil,
		{
			zone=949,
			{"Requirements", {"Outpost", 949, 2}},
			{"Quests", {36833, 93, 85278, 949, 53.2, 59.8}} -- Quest: Eiserne Ketten ?
		},
		{
			zone=949,
			{"Requirements", {"Outpost", 949, 2}},
			{"Quests", {36832, 93, 85980, 949, 44, 48.8}} --  Quest: Ist Xais egal ?
		}
	}; -- TODO: incomplete, mission quest row

--[=[ 950 Nagrand ]=]
	_[157] = { --  950, 157, Lantresor of the Blade
		nil,
		{
			zone = 950,
			{"Quests", 
				{34951, 98, 80624, 950, 63.4, 61.8}, -- travel to hallvalor
				{34954, 98, 80161, 950, 85.4, 54.6}, -- the blade itself
				{34955, 98, 80161, 950, 85.4, 54.6}, -- not without my honer
				{34956, 98, 80161, 950, 85.4, 54.6}, -- meet me in the cavern
				{34957, 98, 80319, 950, 89.8, 55.8}, -- Challenge of the Masters

				{34747, 98, 81790, 950, 64.24, 59.54}, -- The Honor of a Blademaster
			}
		},
		{
			zone = 950,
			{"Quests",
				{34818, 98, 80140, 950, 82.8, 44.2}, -- travel to hallvalor
				{34849, 98, 80161, 950, 85.4, 54.6}, -- the blade itself
				{34850, 98, 80161, 950, 85.4, 54.6}, -- not without my honer
				{34866, 98, 80161, 950, 85.4, 54.6}, -- meet me in the cavern
				{34868, 98, 80319, 950, 89.8, 55.8}, -- Challenge of the Masters

				{34770, 98, 81790, 950, 82.6, 46.6}, -- The Honor of a Blademaster
			}
		}
	};

	_[170] = { --  950, 170, Goldmane the Skinner
		{
			zone = 950,
			{"Location", {950, 40.4, 76.2, Images={{"location","Image",false}}}},
			{"Quests", {35596, 100, 80083, 950, 40.4, 76.2}}
		}
	};

	_[209] = { --  950, 209, Abu'gar
		{
			zone=950,
			{"Quests", {36711, 98, 82746, 950, 67.2, 56, Images={ {"npc82746","Image",false} }}},
			{"Items",
				{114243, 950, 85.42, 38.75, Images={ {"item114243","Image",false} }},
				{114242, 950, 65.8, 61.1, Images={ {"item114242","Image",false} }},
				{114245, 950, 38.3, 49.4, Images={ {"item114245","Image",false} }},
			}
		}
	};

--[=[ 971/976 Garrison ]=]
	_[0] = { -- description for all recruitable followers
		nil,
		{
			zone = 971,
			{"Requirements",
				{"Garrison building", 34}
			},
			{"Npc", 84947, 971, {"Garrison building", 34}}
		},
		{
			zone = 976,
			{"Requirements",
				{"Garrison building", 34}
			},
			{"Npc", 87305, 976, {"Garrison building", 34}}
		}
	};

	_[34] = { --  971/976, 34, Qiana Moonshadow (Alliance) / Olin Umberhide (Horde)
		nil,
		{
			zone = 971,
			{"Quests", {34646, 90, 79457, 971, 44, 52.8}},
		},
		{
			zone = 976,
			{"Quests",
				{33815, 90, 76411, 976, 49.2, 50}, -- Farseeker Drek'Thar
				{34402, 90, 78272, 941, 41.8, 69.6}, -- Durotan
				{34364, 90, 70859, 941, 48.6, 65.2}, -- Thrall
				{34375, 90, 78466, 976, 42, 55}, -- Gazlowe
				{34378, 90, 78466, 976, 42, 55}, -- Gazlowe
				{34822, 90, 78466, 976, 42, 55}, -- Gazlowe
				{34461, 90, 78466, 976, 42, 55}, -- Gazlowe
				{34861, 90, 78466, 976, 42, 55}, -- Gazlowe
				{34462, 90, 79740, 976, 53.8, 54.2}, -- Warmaster Zog
			},
		}
	};

	_[153] = { --  971/976, 153, Bruma Swiftstone (A) / Ka'la (H)
		nil,
		{
			zone = 971,
			{"Missions", 66},
		},
		{
			zone = 976,
			{"Missions", 2},
		}
	};

	_[202] = { --  971/976, 202, Nat Pagle
		nil,
		{
			zone = 971,
			{"Requirements",
				{"Garrison building", 135},
				{"Professions", 131474, 700}
			},
			{"Quests",
				{36611, 94, 85984, 971, {"Garrison building", 135}},
				{36616, 94, 85984, 971, {"Garrison building", 135}}
			}
		},
		{
			zone = 976,
			{"Requirements",
				{"Garrison building", 135},
				{"Professions", 131474, 700}
			},
			{"Quests",
				{36611, 94, 85984, 976, {"Garrison building", 135}},
				{36616, 94, 85984, 976, {"Garrison building", 135}}
			}
		}
	};

	_[216] = { --  971/976, 216, Delvar Ironfist (A) / Vivianne (H)
		nil,
		{
			zone = 971,
			{"Quests",
				{36624, 90, 79953, 971, 40.6, 53.6},
				{36626, 90, 86065, 1009, 31.8, 49.6},
				{36629, 90, 86069, 1009, 35.6, 75.4},
				{36630, 90, 86069, 1009, 35.6, 75.4},
				{36633, 90, 86084, 1009, 47.6, 30.6}
			}
		},
		{
			zone = 941,
			{"Quests", 
				{36706, 90, 78466, 976, 52.4, 52.8},
				{36707, 90, 86315, 1011, 45.2, 34.6},
				{36708, 90, 86312, 1011, 44.4, 45.2},
				{36709, 90, 86312, 1011, 44.4, 45.2},
				{35243, 90, 81765, 1011, 61.8, 23.4}
			}
		}
	};

	_[217] = { --  971/976, 217, Thisalee Crow / Choluna
		nil,
		{
			zone = 971,
			{"Quests",
				{36134, 100, 81492, 971, 37.8, 36.8},
				{36341, 100, 84185, 949, 41, 43}
			}
		},
		{
			zone = 976,
			{"Quests",
				{36136, 100, 78487, 976, 45.6, 43.2},
				{36342, 100, 88530, 949, 41, 43}
			}
		}
	}; -- TODO: incomplete

	_[455] = { --  971/976, 455, Millhouse Manastorm
		nil,
		{
			zone = 971,
			{"Requirements",
				{"Garrison building", 34}
			},
			{"Quests", {37179, 100, 88009, 971, {"Garrison building", 34}}}
		},
		{
			zone = 976,
			{"Requirements",
				{"Garrison building", 34}
			},
			{"Quests", {37179, 100, 88009, 976, {"Garrison building", 34}}}
		}
	};

	_[458] = { --  971/976, 458, Vindicator Heluun / Cacklebone
		nil,
		{
			zone = 971,
			{"Requirements",
				{"Garrison building", 144},
				{"Reputation", 1710, 7}
			},
			{"Merchant", {85427, 971, {"Garrison building", 144}}},
			{"Price", {"Gold", 50000000}},
		},
		{
			zone = 976,
			{"Requirements",
				{"Garrison building", 144},
				{"Reputation", 1710, 7}
			},
			{"Merchant", {88493, 976, {"Garrison building", 144}}},
			{"Price", {"Gold", 50000000}},
		}
	};

	_[463] = { --  971/976, 463, Daleera Moonfang (A) / Ulna Thresher (H)
		nil,
		{
			zone = 971,
			{"Missions", 91}
		},
		{
			zone = 976,
			{"Missions", 7}
		}
	};

--[=[ anywhere in draenor ]=]
	_[194] = { --  962, 194, Phylarch the Evergreen
		{
			zone = 962,
			{"Requirements", {"Garrison building", 138} },
			{"Location", {962, nil, nil, "In the near of any large timber that you try to harvest"}}
		}
	};

	_[195] = { --  962, 195, Weldon Barov (A) / Alexi Weldon (H)
		{
			zone = 962,
			{"Requirements",
				{"Garrison building", 40}
			},
			{"Location",
				{949, 51.29, 61.97, Images={{"location949","Image",false} }}, --[=[ Gorgrond ]=]
				{946, 73.93, 28.23, Images={{"location946","Image",false} }}, --[=[ Talador ]=]
				{948, 55.14, 79.51, Images={{"location948","Image",false} }}, --[=[ Spikes of Arak ]=]
				{950, 84.4, 54.26, Images={{"location950","Image",false} }}, --[=[ Nagrand ]=]
			}
		}
	};

	_[203] = { --  962, 203, Meatball
		nil,
		{
			zone = 301,
			{"Requirements", {"Brawler's Guild", 1691, 5}},
			{"Quests", {36702, 100, 86272, 922, 62.21, 25.69, Images={{"location","Image",true}}}}
		},
		{
			zone = 321,
			{"Requirements", {"Brawler's Guild", 1690, 5}}
		}
	};

	_[465] = { --  962, 465, Harrison Jones
		nil,
		{
			zone = 962,
			{"Achievements", 9928, 9825}
		},
		{
			zone = 962,
			{"Achievements", 9901, 9836}
		}
	};

--[=[ dungeons ]=]
	_[177] = { --  964, 177, Croman
		{
			zone = 964,
			zoneType = "dungeon",
			{"Achievements", 9005}
		}
	};

	_[178] = { --  995, 178, Leeroy Jenkins
		{
			zone = 995,
			zoneType = "dungeon",
			{"Achievements", 9058}
		}
	};

--[=[ raids ]=]
	_[225] = { --  988, 225, Aknor Steelbringer
		{
			zone = 988,
			zoneType = "raid",
			{"Achievements", 8929}
		}
	};

	_[474] = { -- 1026, 474, Ariok
		{
			zone = 1026,
			zoneType = "raid",
			{"Achievements", 9972}
		}
	};

--[=[ ashran ]=]
	_[459] = { --  1009/1011, 459, Cleric Maluuf (A) / Karg Bloodfury (H)
		nil,
		{
			zone = 1009,
			{"Requirements", {"Reputation", 1731, 7}},
			{"Merchant", {85932, 1009, 46.6, 76.2}},
			{"Price", {"Gold", 50000000}},
		},
		{
			zone = 1011,
			{"Requirements", {"Reputation", 1445, 7}},
			{"Merchant", {86036, 1011, 53.4, 62.6}},
			{"Price", {"Gold", 50000000}},
		}
	};

	_[460] = { --  1009/1011, 460, Felbast
		nil,
		{
			zone = 1009,
			{"Requirements", {"Reputation", 1711, 7}},
			{"Merchant", {88482, 1009, 43.2, 77.4}},
			{"Price", {"Gold", 50000000}},
		},
		{
			zone = 1011,
			{"Requirements", {"Reputation", 1711, 7}},
			{"Merchant", {88493, 1011, 53.8, 60.8}},
			{"Price", {"Gold", 50000000}},
		}
	};

	_[462] = { --  1009/1011, 462, Dawnseeker Rukaryx
		nil,
		{
			zone = 1009,
			{"Merchant", {86391, 1009, 49.9, 61.4}},
			{"Price", {"Currency", 823, 5000}, {"Gold", 50000000}},
		},
		{
			zone = 1011,
			{"Merchant", {86382, 1011, 64.6, 61.8}},
			{"Price", {"Currency", 823, 5000}, {"Gold", 50000000}},
		}
	};

	_[467] = { --  1009/1011, 467, Fen Tao
		nil,
		{
			zone = 1009,
			{"Location", {1009, 45.3, 70.5, Images={{"location","Image",true}}}}
		},
		{
			zone = 1011,
			{"Location", {1011, 46.9, 45.2, Images={{"location","Image",true}}}}
		}
	};

	--[=[ 945 Tanaan jungle ]=]
	_[468] = { -- 945, 468, Oronok Torn-heart
		{
			zone = 945,
			{"Quests",
				{39395, 100, 92338, 945, 62.8, 27.8}
			}
		}
	}; -- TODO: questrow is longer. need more verified data.

	_[580] = { -- 945, 580, Pallas
		{
			zone = 945,
			{"Requirements", {"Reputation", 1850, 6}},
			{"Merchant", {92805, 945, 55.2, 74.8}},
			{"Items", {128439}},
			{"Price", {"Item", 124099, 100}}
		}
	};

	_[581] = { -- 945, 581, Dowser Bigspark / Dowser Goodwell
		nil,
		{
			zone = 945,
			{"Requirements", {"Reputation", 1847, 6}},
			{"Merchant", {90974, 945, 58.4, 60.4}},
			{"Items", {128445}},
			{"Price", {"Gold", 6000000}}
		},
		{
			zone = 945,
			{"Requirements", {"Reputation", 1848, 6}},
			{"Merchant", {96014, 945, 61.6, 45.6}},
			{"Items", {128445}},
			{"Price", {"Gold", 6000000}}
		}
	};

	_[582] = { -- 945, 582, Solar Priest Vayx
		nil,
		{
			zone = 945,
			{"Requirements", {"Reputation", 1849, 6}},
			{"Merchant", {95424, 945, 57.8, 59.4}},
			{"Items", {128441}},
			{"Price", {"Currency", 823, 1000}}
		},
		{
			zone = 945,
			{"Requirements", {"Reputation", 1849, 6}},
			{"Merchant", {95424, 945, 60.4, 46.6}},
			{"Items", {128441}},
			{"Price", {"Currency", 823, 1000}}
		}
	};






--[=[ some strings for localization collector script ]=]
--[[
	L["Cave on image 1"]
	L["Hidden cave"]
	L["Random location"]
	L["Path to blook"]
	L["You've choosed the other outpost building?|nYou have two alternatives.|n1. Reset your outpost building by talking with an NPC in the outpost.|n2. Buy a contract in your garrison."]
--]]
