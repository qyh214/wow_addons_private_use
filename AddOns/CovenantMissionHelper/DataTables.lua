CovenantMissionHelper, CMH = ...

local DataTables = {}
DataTables.EffectType = {
    [0] = "for spellID = 17 only",
    [1] = "damage",
    [2] = "heal",
    [3] = "damage",
    [4] = "heal",
    [7] = "DoT",
    [8] = "HoT",
    [9] = "Taunt",
    [10] = "Untargetable",
    [11] = "Damage dealt multiplier",
    [12] = "Damage dealt multiplier",
    [13] = "Damage taken multiplier",
    [14] = "Damage taken multiplier",
    [15] = "Reflect",
    [16] = "Reflect",
    [18] = "Maximum health multiplier",
    [19] = "Additional damage dealt",
    [20] = "Additional receive damage"
}

DataTables.EffectTypeEnum = {
    ["Unknown_0"] = 0,
    ["Damage"] = 1,
    ["Heal"] = 2,
    ["Damage_2"] = 3,
    ["Heal_2"] = 4,
    ["DoT"] = 7,
    ["HoT"] = 8,
    ["Taunt"] = 9,
    ["Untargetable"] = 10,
    ["DamageDealtMultiplier"] = 11,
    ["DamageDealtMultiplier_2"] = 12,
    ["DamageTakenMultiplier"] = 13,
    ["DamageTakenMultiplier_2"] = 14,
    ["Reflect"] = 15,
    ["Reflect_2"] = 16,
    ["MaxHPMultiplier"] = 18,
    ["AdditionalDamageDealt"] = 19,
    ["AdditionalTakenDamage"] = 20,
	["Died"] = 100,
	["ApplyAura"] = 105,
	["RemoveAura"] = 110
}

DataTables.TargetTypeEnum = {
    ["lastTarget"] = 0,
    ["self"] = 1,
    ["adjacentAlly"] = 2,
    ["closestEnemy"] = 3,
    ["furthestEnemy"] = 5,
    ["allAllies"] = 6,
    ["allEnemies"] = 7,
    ["allAdjacentAllies"] = 8,
    ["allAdjacentEnemies"] = 9,
    ["closestAllyCone"] = 10,
    ["closestEnemyCone"] = 11,
    ["closestEnemyLine"] = 13,
    ["frontLineAllies"] = 14,
    ["frontLineEnemies"] = 15,
    ["backLineAllies"] = 16,
    ["backLineEnemies"] = 17,
    ["randomEnemy_2"] = 19, -- ?
    ["randomEnemy"] = 20,
    ["randomAlly"] = 21,
    ["allAllies_2"] = 22,
    ["allAllies_3"] = 23,
    ["unknown"] = 24,
}

DataTables.EffectFlags = {
    [1] = "USE_ATTACK_FOR_POINTS",
    [2] = "EXTRA_INITIAL_PERIOD",
    [3] = "1+2"
}

DataTables.UnknownTargetType = {0, 24}

DataTables.TargetPriorityByType = {
    [1] = { -- self
        [0] = {0},
        [1] = {1},
        [2] = {2},
        [3] = {3},
        [4] = {4},
        [5] = {5},
        [6] = {6},
        [7] = {7},
        [8] = {8},
        [9] = {9},
        [10] = {10},
        [11] = {11},
        [12] = {12}
    },
    [2] = { -- adjacent ally
        [0] = {2, 3, 1, 4, 0},
        [1] = {0, 3, 4, 2, 1},
        [2] = {0, 3, 1, 4, 2},
        [3] = {2, 0, 1, 4, 3},
        [4] = {3, 1, 2, 0, 4},
        [5] = {9, 6, 10, 7, 11, 8, 12, 5}, -- not sure
        [6] = {5, 10, 7, 9, 11, 8, 12, 6}, -- not sure
        [7] = {6, 8, 11, 10, 12, 5, 9, 7}, -- not sure
        [8] = {7, 12, 10, 6, 11, 5, 9, 8}, -- not sure
        [9] = {5, 6, 10, 7, 11, 8, 12, 9}, -- not sure
        [10] = {6, 11, 9, 5, 7, 8, 12, 10}, -- not sure
        [11] = {10, 7, 12, 6, 8, 5, 9, 11}, -- not sure
        [12] = {8, 11, 7, 10, 6, 9, 5, 12} -- not sure
    },
    [3] =  { -- closest enemy
        [0] = {5, 6, 10, 7, 9, 11, 8, 12},
        [1] = {6, 7, 11, 8, 10, 12, 5, 9},
        [2] = {5, 6, 9, 10, 7, 11, 8, 12},
        [3] = {6, 7, 5, 9, 10, 11, 8, 12}, -- not sure
        [4] = {7, 8, 6, 11, 10, 12, 5, 9}, -- not sure
        [5] = {2, 0, 3, 1, 4},
        [6] = {2, 3, 0, 1, 4},
        [7] = {3, 4, 2, 0, 1},
        [8] = {4, 3, 1, 2, 0}, -- not sure
        [9] = {2, 3, 0, 1, 4},
        [10] = {2, 3, 4, 0, 1},
        [11] = {2, 3, 4, 0, 1},
        [12] = {3, 4, 1, 2, 0} -- not sure
    },
    [5] = { -- furthest enemy
        [0] = {12, 8, 9, 11, 10, 5, 7, 6},
        [1] = {9, 5, 10, 12, 11, 6, 8, 7}, -- not sure
        [2] = {12, 8, 11, 7, 9, 10, 5, 6},
        [3] = {9, 12, 5, 8, 10, 11, 6, 7},
        [4] = {9, 5, 10, 6, 11, 12, 7, 8},
        [5] = {4, 1, 3, 0, 2}, -- not sure
        [6] = {4, 1, 0, 2, 3},
        [7] = {2, 0, 1, 3, 4},
        [8] = {2, 0, 1, 3, 4},
        [9] = {4, 1, 0, 3, 2}, -- not sure
        [10] = {1, 0, 4, 2, 3}, -- not sure
        [11] = {0, 1, 2, 3, 4}, -- not sure
        [12] = {2, 0, 1, 3, 4} -- not sure
    }
}

-- adjacent allies indexes
DataTables.AdjacentAllies = {
    [0] = {2, 3, 1},
    [1] = {0, 3, 4},
    [2] = {0, 3},
    [3] = {0, 1, 2, 4},
    [4] = {1, 3},
    [5] = {6, 9, 10},
    [6] = {5, 9, 10, 11, 7},
    [7] = {6, 10, 11, 12, 8},
    [8] = {7, 11, 12},
    [9] = {5, 6, 10},
    [10] = {5, 6, 7, 9, 11},
    [11] = {6, 7, 8, 10, 12},
    [12] = {7, 8, 11}
}

DataTables.AdjacentEnemies = {
	[0] = {
		["blockerUnits"] = {5, 6},
		["aliveBlockerUnitGroup"] = {5, 6},
		["deadBlockerUnitGroup"] = {5, 7, 9, 10, 11},
		["aloneUnits"] = {8, 12}
	},
	[1] = {
		["blockerUnits"] = {7},
		["aliveBlockerUnitGroup"] = {6, 7},
		["deadBlockerUnitGroup"] = {6, 8, 10, 11, 12},
		["aloneUnits"] = {5, 9}
	},
	[2] = {
		["blockerUnits"] = {5, 6},
		["aliveBlockerUnitGroup"] = {5, 6},
		["deadBlockerUnitGroup"] = {7, 9, 10, 11},
		["aloneUnits"] = {8, 12}
	},
	[3] = {
		["blockerUnits"] = {6, 7},
		["aliveBlockerUnitGroup"] = {6, 7},
		["deadBlockerUnitGroup"] = {5, 7, 9, 10, 11},
		["aloneUnits"] = {8, 12}
	},
	[4] = {
		["blockerUnits"] = {7, 8},
		["aliveBlockerUnitGroup"] = {7, 8},
		["deadBlockerUnitGroup"] = {6, 10, 11, 12},
		["aloneUnits"] = {5, 9}
	},
	-- try to make more target for unproven data. Better predict false lose than false win
	[5] = {
		["blockerUnits"] = {2},
		["aliveBlockerUnitGroup"] = {2},
		["deadBlockerUnitGroup"] = {{0, 3}, {1, 4}},
		["aloneUnits"] = {}
	},
	[6] = {
		["blockerUnits"] = {2, 3},
		["aliveBlockerUnitGroup"] = {2, 3}, -- proved
		["deadBlockerUnitGroup"] = {0, 1, 2},
		["aloneUnits"] = {}
	}
	-- 6 -> 2,3. 7 -> 3,4.
	,
	[7] = {
		["blockerUnits"] = {3, 4},
		["aliveBlockerUnitGroup"] = {3, 4}, -- proved
		["deadBlockerUnitGroup"] = {0, 1, 2},
		["aloneUnits"] = {}
	},
	[8] = {
		["blockerUnits"] = {4},
		["aliveBlockerUnitGroup"] = {4},
		["deadBlockerUnitGroup"] = {{1, 3}, {0, 2}},
		["aloneUnits"] = {}
	},
	[9] = {
		["blockerUnits"] = {2},
		["aliveBlockerUnitGroup"] = {2},
		["deadBlockerUnitGroup"] = {{0, 3}, {1, 4}},
		["aloneUnits"] = {}
	},
	[10] = {
		["blockerUnits"] = {2, 3},
		["aliveBlockerUnitGroup"] = {2, 3},
		["deadBlockerUnitGroup"] = {0, 1, 2},
		["aloneUnits"] = {}
	}
	-- 6 -> 2,3. 7 -> 3,4.
	,
	[11] = {
		["blockerUnits"] = {3, 4},
		["aliveBlockerUnitGroup"] = {3, 4},
		["deadBlockerUnitGroup"] = {0, 1, 2},
		["aloneUnits"] = {}
	},
	[12] = {
		["blockerUnits"] = {4},
		["aliveBlockerUnitGroup"] = {4},
		["deadBlockerUnitGroup"] = {{1, 3}, {0, 2}},
		["aloneUnits"] = {}
	}
}

--TODO: test it
-- garrMission.ID = 2224
DataTables.ConeAllies = {
    [0] = {0},
    [1] = {1},
    [2] = {2},
    [3] = {3},
    [4] = {4},
    [5] = {5},
    [6] = {6},
    [7] = {7},
    [8] = {8},
    [9] = {9},
    [10] = {10},
    [11] = {11},
    [12] = {12}
}

-- key = main target, value = all targets
DataTables.ConeEnemies = {
    [0] = {0},
    [1] = {1},
    [2] = {2, 0},
    [3] = {3, 0, 1},
    [4] = {4, 1},
    [5] = {5, 9, 10},
    [6] = {6, 9, 10, 11},
    [7] = {7, 10, 11, 12},
    [8] = {8, 11, 12},
    [9] = {9},
    [10] = {10},
    [11] = {11},
    [12] = {12}
}

-- key = main target, value = all targets
DataTables.LineEnemies = {
    [0] = {0},
    [1] = {1},
    [2] = {2},
    [3] = {3},
    [4] = {4},
    [5] = {5, 9},
    [6] = {6, 10},
    [7] = {7, 11},
    [8] = {8, 12},
    [9] = {9},
    [10] = {10},
    [11] = {11},
    [12] = {12}
}

DataTables.startsOnCooldownSpells = {2, 68, 84, 85, 118, 139, 144, 152, 158, 163, 172, 181, 186, 228, 244, 247, 250, 254, 282, 285, 296}

-- Attack type isn't match with unit role
-- key = combatantID, value = attackType
DataTables.UnusualAttackType = {
	-- melee
	[1288] = 15, [3684889] = 15,
	-- ranged_physical
	[1323] = 11, [1324] = 11, [3852840] = 11, [3852830] = 11, [3852829] = 11, [3852831] = 11, [3852834] = 11,
	[3852908] = 11, [3580935] = 11,
	-- ranged_magic
	[175299] = 11, [3852909] = 11, [3852843] = 11, [3852835] = 11, [3583223] = 11,
	[3856480] = 11, [3921251] = 11, [175948] = 11,
	-- heal_support
	[3517256] = 11, [1212] = 11, [1258] = 11, [1311] = 11, [3852839] = 11, [3852877] = 11, [3852848] = 11,
	[3852889] = 11, [3485232] = 11, [165562] = 11, [3684894] = 11, [3852627] = 11
}

-- key - spellID, value - list of skill's effect ordered by EffectIndex
DataTables.SpellEffects = {
	[1] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 1,
			['Period'] = 0,
			['Points'] = 350,
			['SpellID'] = 1,
			['TargetType'] = 24
		}
	},
	[2] = {
		[1] = {
			['Effect'] = 19,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 2,
			['Period'] = 2,
			['Points'] = 0.2,
			['SpellID'] = 2,
			['TargetType'] = 22
		},
		[2] = {
			['Effect'] = 4,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 120,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 2,
			['TargetType'] = 1
		}
	},
	[3] = {
		[1] = {
			['Effect'] = 2,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 3,
			['Period'] = 0,
			['Points'] = 45.2,
			['SpellID'] = 3,
			['TargetType'] = 1
		},
		[2] = {
			['Effect'] = 1,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 4,
			['Period'] = 0,
			['Points'] = 90.4,
			['SpellID'] = 3,
			['TargetType'] = 3
		}
	},
	[4] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 7,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 4,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 3,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 8,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 4,
			['TargetType'] = 3
		}
	},
	[5] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 9,
			['Period'] = 0,
			['Points'] = 0.1,
			['SpellID'] = 5,
			['TargetType'] = 7
		}
	},
	[6] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 10,
			['Period'] = 0,
			['Points'] = 0.6,
			['SpellID'] = 6,
			['TargetType'] = 17
		}
	},
	[7] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 11,
			['Period'] = 0,
			['Points'] = 0.1,
			['SpellID'] = 7,
			['TargetType'] = 3
		}
	},
	[8] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 12,
			['Period'] = 0,
			['Points'] = 10,
			['SpellID'] = 8,
			['TargetType'] = 3
		}
	},
	[9] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 13,
			['Period'] = 0,
			['Points'] = 0.05,
			['SpellID'] = 9,
			['TargetType'] = 6
		}
	},
	[10] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 14,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 10,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 7,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 15,
			['Period'] = 0,
			['Points'] = 0.03,
			['SpellID'] = 10,
			['TargetType'] = 7
		},
		[3] = {
			['Effect'] = 8,
			['EffectIndex'] = 2,
			['Flags'] = 0,
			['ID'] = 16,
			['Period'] = 0,
			['Points'] = 0.01,
			['SpellID'] = 10,
			['TargetType'] = 1
		}
	},
	[11] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 17,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 11,
			['TargetType'] = 3
		}
	},
	[12] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 18,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 12,
			['TargetType'] = 6
		}
	},
	[13] = {
		[1] = {
			['Effect'] = 2,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 19,
			['Period'] = 0,
			['Points'] = 10,
			['SpellID'] = 13,
			['TargetType'] = 2
		}
	},
	[14] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 20,
			['Period'] = 0,
			['Points'] = 0.1,
			['SpellID'] = 14,
			['TargetType'] = 6
		}
	},
	[15] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 21,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 15,
			['TargetType'] = 5
		}
	},
	[16] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 22,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 16,
			['TargetType'] = 5
		}
	},
	[17] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 23,
			['Period'] = 0,
			['Points'] = 0.1,
			['SpellID'] = 17,
			['TargetType'] = 7
		},
		[2] = {
			['Effect'] = 2,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 24,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 17,
			['TargetType'] = 1
		}
	},
	[18] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 26,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 18,
			['TargetType'] = 15
		},
		[2] = {
			['Effect'] = 3,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 27,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 18,
			['TargetType'] = 15
		},
		[3] = {
			['Effect'] = 3,
			['EffectIndex'] = 2,
			['Flags'] = 1,
			['ID'] = 28,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 18,
			['TargetType'] = 15
		}
	},
	[19] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 29,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 19,
			['TargetType'] = 3
		}
	},
	[20] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 30,
			['Period'] = 0,
			['Points'] = 0.7,
			['SpellID'] = 20,
			['TargetType'] = 17
		}
	},
	[21] = {
		[1] = {
			['Effect'] = 8,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 31,
			['Period'] = 0,
			['Points'] = 0.25,
			['SpellID'] = 21,
			['TargetType'] = 6
		}
	},
	[22] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 32,
			['Period'] = 0,
			['Points'] = 0.9,
			['SpellID'] = 22,
			['TargetType'] = 9
		},
		[2] = {
			['Effect'] = 7,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 33,
			['Period'] = 0,
			['Points'] = 0.1,
			['SpellID'] = 22,
			['TargetType'] = 9
		}
	},
	[23] = {
		[1] = {
			['Effect'] = 10,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 34,
			['Period'] = 0,
			['Points'] = 11,
			['SpellID'] = 23,
			['TargetType'] = 1
		},
		[2] = {
			['Effect'] = 7,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 92,
			['Period'] = 0,
			['Points'] = 0.1,
			['SpellID'] = 23,
			['TargetType'] = 11
		}
	},
	[24] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 35,
			['Period'] = 0,
			['Points'] = 1.8,
			['SpellID'] = 24,
			['TargetType'] = 5
		},
		[2] = {
			['Effect'] = 4,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 36,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 24,
			['TargetType'] = 2
		}
	},
	[25] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 37,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 25,
			['TargetType'] = 15
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 38,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 25,
			['TargetType'] = 1
		}
	},
	[26] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 39,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 26,
			['TargetType'] = 2
		},
		[2] = {
			['Effect'] = 18,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 40,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 26,
			['TargetType'] = 2
		}
	},
	[27] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 41,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 27,
			['TargetType'] = 3
		}
	},
	[28] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 42,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 28,
			['TargetType'] = 3
		}
	},
	[29] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 43,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 29,
			['TargetType'] = 3
		}
	},
	[30] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 44,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 30,
			['TargetType'] = 3
		}
	},
	[31] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 45,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 31,
			['TargetType'] = 3
		}
	},
	[32] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 46,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 32,
			['TargetType'] = 3
		}
	},
	[33] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 47,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 33,
			['TargetType'] = 3
		}
	},
	[34] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 48,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 34,
			['TargetType'] = 7
		}
	},
	[35] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 49,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 35,
			['TargetType'] = 7
		}
	},
	[36] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 50,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 36,
			['TargetType'] = 7
		}
	},
	[37] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 51,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 37,
			['TargetType'] = 7
		}
	},
	[38] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 52,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 38,
			['TargetType'] = 7
		}
	},
	[39] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 53,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 39,
			['TargetType'] = 7
		}
	},
	[40] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 54,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 40,
			['TargetType'] = 7
		}
	},
	[41] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 55,
			['Period'] = 0,
			['Points'] = 0.25,
			['SpellID'] = 41,
			['TargetType'] = 9
		}
	},
	[42] = {
		[1] = {
			['Effect'] = 16,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 56,
			['Period'] = 0,
			['Points'] = 0.1,
			['SpellID'] = 42,
			['TargetType'] = 1
		}
	},
	[43] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 57,
			['Period'] = 0,
			['Points'] = 0.25,
			['SpellID'] = 43,
			['TargetType'] = 5
		},
		[2] = {
			['Effect'] = 4,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 58,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 43,
			['TargetType'] = 1
		}
	},
	[44] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 59,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 44,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 3,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 60,
			['Period'] = 0,
			['Points'] = 0.25,
			['SpellID'] = 44,
			['TargetType'] = 3
		}
	},
	[45] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 61,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 45,
			['TargetType'] = 5
		},
		[2] = {
			['Effect'] = 4,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 62,
			['Period'] = 0,
			['Points'] = 0.25,
			['SpellID'] = 45,
			['TargetType'] = 1
		}
	},
	[46] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 63,
			['Period'] = 0,
			['Points'] = -0.1,
			['SpellID'] = 46,
			['TargetType'] = 1
		},
		[2] = {
			['Effect'] = 14,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 64,
			['Period'] = 0,
			['Points'] = -0.1,
			['SpellID'] = 46,
			['TargetType'] = 16
		}
	},
	[47] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 65,
			['Period'] = 0,
			['Points'] = -0.2,
			['SpellID'] = 47,
			['TargetType'] = 6
		}
	},
	[48] = {
		[1] = {
			['Effect'] = 10,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 66,
			['Period'] = 0,
			['Points'] = 0,
			['SpellID'] = 48,
			['TargetType'] = 1
		},
		[2] = {
			['Effect'] = 4,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 67,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 48,
			['TargetType'] = 1
		}
	},
	[49] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 68,
			['Period'] = 0,
			['Points'] = 0.33,
			['SpellID'] = 49,
			['TargetType'] = 17
		}
	},
	[50] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 69,
			['Period'] = 0,
			['Points'] = 1.2,
			['SpellID'] = 50,
			['TargetType'] = 5
		}
	},
	[51] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 70,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 51,
			['TargetType'] = 15
		}
	},
	[52] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 71,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 52,
			['TargetType'] = 17
		}
	},
	[53] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 72,
			['Period'] = 2,
			['Points'] = 0.1,
			['SpellID'] = 53,
			['TargetType'] = 7
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 73,
			['Period'] = 2,
			['Points'] = -0.2,
			['SpellID'] = 53,
			['TargetType'] = 7
		}
	},
	[54] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 74,
			['Period'] = 0,
			['Points'] = 0.9,
			['SpellID'] = 54,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 3,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 75,
			['Period'] = 0,
			['Points'] = 0.9,
			['SpellID'] = 54,
			['TargetType'] = 5
		}
	},
	[55] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 76,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 55,
			['TargetType'] = 15
		}
	},
	[56] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 77,
			['Period'] = 0,
			['Points'] = 1.25,
			['SpellID'] = 56,
			['TargetType'] = 5
		}
	},
	[57] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 78,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 57,
			['TargetType'] = 3
		}
	},
	[58] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 79,
			['Period'] = 0,
			['Points'] = 0.7,
			['SpellID'] = 58,
			['TargetType'] = 9
		}
	},
	[59] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 80,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 59,
			['TargetType'] = 17
		}
	},
	[60] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 81,
			['Period'] = 0,
			['Points'] = 0.4,
			['SpellID'] = 60,
			['TargetType'] = 5
		}
	},
	[61] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 82,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 61,
			['TargetType'] = 3
		}
	},
	[62] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 83,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 62,
			['TargetType'] = 15
		}
	},
	[63] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 84,
			['Period'] = 0,
			['Points'] = 0.6,
			['SpellID'] = 63,
			['TargetType'] = 7
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 85,
			['Period'] = 0,
			['Points'] = -0.2,
			['SpellID'] = 63,
			['TargetType'] = 7
		}
	},
	[64] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 86,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 64,
			['TargetType'] = 7
		}
	},
	[65] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 87,
			['Period'] = 0,
			['Points'] = 0.65,
			['SpellID'] = 65,
			['TargetType'] = 3
		}
	},
	[66] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 88,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 66,
			['TargetType'] = 13
		}
	},
	[67] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 89,
			['Period'] = 0,
			['Points'] = 1.2,
			['SpellID'] = 67,
			['TargetType'] = 5
		}
	},
	[68] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 90,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 68,
			['TargetType'] = 15
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 91,
			['Period'] = 0,
			['Points'] = -0.8,
			['SpellID'] = 68,
			['TargetType'] = 15
		}
	},
	[69] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 95,
			['Period'] = 2,
			['Points'] = 50,
			['SpellID'] = 69,
			['TargetType'] = 1
		},
		[2] = {
			['Effect'] = 3,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 96,
			['Period'] = 2,
			['Points'] = 0.2,
			['SpellID'] = 69,
			['TargetType'] = 1
		},
		[3] = {
			['Effect'] = 1,
			['EffectIndex'] = 2,
			['Flags'] = 0,
			['ID'] = 97,
			['Period'] = 0,
			['Points'] = 50,
			['SpellID'] = 69,
			['TargetType'] = 1
		},
		[4] = {
			['Effect'] = 3,
			['EffectIndex'] = 3,
			['Flags'] = 0,
			['ID'] = 98,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 69,
			['TargetType'] = 0
		}
	},
	[71] = {
		[1] = {
			['Effect'] = 2,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 99,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 71,
			['TargetType'] = 2
		}
	},
	[72] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 100,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 72,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 3,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 101,
			['Period'] = 0,
			['Points'] = 0.4,
			['SpellID'] = 72,
			['TargetType'] = 17
		}
	},
	[73] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 102,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 73,
			['TargetType'] = 13
		}
	},
	[74] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 103,
			['Period'] = 0,
			['Points'] = -0.4,
			['SpellID'] = 74,
			['TargetType'] = 1
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 104,
			['Period'] = 0,
			['Points'] = -0.4,
			['SpellID'] = 74,
			['TargetType'] = 1
		}
	},
	[75] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 105,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 75,
			['TargetType'] = 5
		}
	},
	[76] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 106,
			['Period'] = 0,
			['Points'] = 2.25,
			['SpellID'] = 76,
			['TargetType'] = 5
		}
	},
	[77] = {
		[1] = {
			['Effect'] = 19,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 107,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 77,
			['TargetType'] = 6
		}
	},
	[78] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 108,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 78,
			['TargetType'] = 15
		}
	},
	[79] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 109,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 79,
			['TargetType'] = 7
		},
		[2] = {
			['Effect'] = 4,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 110,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 79,
			['TargetType'] = 6
		}
	},
	[80] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 111,
			['Period'] = 0,
			['Points'] = 1.2,
			['SpellID'] = 80,
			['TargetType'] = 5
		},
		[2] = {
			['Effect'] = 7,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 112,
			['Period'] = 0,
			['Points'] = 0.4,
			['SpellID'] = 80,
			['TargetType'] = 5
		}
	},
	[81] = {
		[1] = {
			['Effect'] = 15,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 113,
			['Period'] = 0,
			['Points'] = 3,
			['SpellID'] = 81,
			['TargetType'] = 1
		}
	},
	[82] = {
		[1] = {
			['Effect'] = 16,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 114,
			['Period'] = 0,
			['Points'] = 0.25,
			['SpellID'] = 82,
			['TargetType'] = 1
		}
	},
	[83] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 115,
			['Period'] = 0,
			['Points'] = 1.2,
			['SpellID'] = 83,
			['TargetType'] = 9
		}
	},
	[84] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 116,
			['Period'] = 0,
			['Points'] = -1,
			['SpellID'] = 84,
			['TargetType'] = 7
		}
	},
	[85] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 117,
			['Period'] = 0,
			['Points'] = -50,
			['SpellID'] = 85,
			['TargetType'] = 2
		}
	},
	[86] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 118,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 86,
			['TargetType'] = 3
		}
	},
	[87] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 119,
			['Period'] = 0,
			['Points'] = 0.6,
			['SpellID'] = 87,
			['TargetType'] = 17
		}
	},
	[88] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 121,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 88,
			['TargetType'] = 1
		},
		[2] = {
			['Effect'] = 3,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 123,
			['Period'] = 0,
			['Points'] = 0.4,
			['SpellID'] = 88,
			['TargetType'] = 7
		}
	},
	[89] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 3,
			['ID'] = 124,
			['Period'] = 1,
			['Points'] = 0.4,
			['SpellID'] = 89,
			['TargetType'] = 5
		}
	},
	[90] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 125,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 90,
			['TargetType'] = 8
		}
	},
	[91] = {
		[1] = {
			['Effect'] = 11,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 126,
			['Period'] = 0,
			['Points'] = -0.6,
			['SpellID'] = 91,
			['TargetType'] = 5
		}
	},
	[92] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 3,
			['ID'] = 127,
			['Period'] = 1,
			['Points'] = 0.4,
			['SpellID'] = 92,
			['TargetType'] = 17
		}
	},
	[93] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 128,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 93,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 4,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 129,
			['Period'] = 0,
			['Points'] = 0.8,
			['SpellID'] = 93,
			['TargetType'] = 1
		}
	},
	[94] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 130,
			['Period'] = 1,
			['Points'] = 0.3,
			['SpellID'] = 94,
			['TargetType'] = 15
		}
	},
	[95] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 131,
			['Period'] = 0,
			['Points'] = 1.2,
			['SpellID'] = 95,
			['TargetType'] = 5
		},
		[2] = {
			['Effect'] = 3,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 132,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 95,
			['TargetType'] = 17
		}
	},
	[96] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 133,
			['Period'] = 0,
			['Points'] = 0.4,
			['SpellID'] = 96,
			['TargetType'] = 5
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 134,
			['Period'] = 0,
			['Points'] = -0.2,
			['SpellID'] = 96,
			['TargetType'] = 5
		}
	},
	[97] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 135,
			['Period'] = 0,
			['Points'] = 0.9,
			['SpellID'] = 97,
			['TargetType'] = 11
		}
	},
	[98] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 136,
			['Period'] = 0,
			['Points'] = 1.2,
			['SpellID'] = 98,
			['TargetType'] = 5
		}
	},
	[99] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 137,
			['Period'] = 0,
			['Points'] = 1.4,
			['SpellID'] = 99,
			['TargetType'] = 15
		}
	},
	[100] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 138,
			['Period'] = 0,
			['Points'] = 0.4,
			['SpellID'] = 100,
			['TargetType'] = 1
		}
	},
	[101] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 139,
			['Period'] = 0,
			['Points'] = 0.6,
			['SpellID'] = 101,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 14,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 140,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 101,
			['TargetType'] = 3
		}
	},
	[102] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 141,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 102,
			['TargetType'] = 13
		}
	},
	[103] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 142,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 103,
			['TargetType'] = 22
		}
	},
	[104] = {
		[1] = {
			['Effect'] = 2,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 143,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 104,
			['TargetType'] = 2
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 144,
			['Period'] = 0,
			['Points'] = -0.1,
			['SpellID'] = 104,
			['TargetType'] = 2
		}
	},
	[105] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 145,
			['Period'] = 0,
			['Points'] = -0.1,
			['SpellID'] = 105,
			['TargetType'] = 6
		}
	},
	[106] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 146,
			['Period'] = 0,
			['Points'] = 0.4,
			['SpellID'] = 106,
			['TargetType'] = 9
		}
	},
	[107] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 3,
			['ID'] = 147,
			['Period'] = 0,
			['Points'] = 0.4,
			['SpellID'] = 107,
			['TargetType'] = 7
		},
		[2] = {
			['Effect'] = 20,
			['EffectIndex'] = 1,
			['Flags'] = 3,
			['ID'] = 148,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 107,
			['TargetType'] = 3
		}
	},
	[108] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 149,
			['Period'] = 0,
			['Points'] = 0.4,
			['SpellID'] = 108,
			['TargetType'] = 2
		},
		[2] = {
			['Effect'] = 18,
			['EffectIndex'] = 1,
			['Flags'] = 2,
			['ID'] = 150,
			['Period'] = 0,
			['Points'] = 0.1,
			['SpellID'] = 108,
			['TargetType'] = 2
		}
	},
	[109] = {
		[1] = {
			['Effect'] = 16,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 151,
			['Period'] = 0,
			['Points'] = 0.6,
			['SpellID'] = 109,
			['TargetType'] = 1
		}
	},
	[110] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 152,
			['Period'] = 0,
			['Points'] = 0.4,
			['SpellID'] = 110,
			['TargetType'] = 1
		}
	},
	[111] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 153,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 111,
			['TargetType'] = 15
		}
	},
	[112] = {
		[1] = {
			['Effect'] = 19,
			['EffectIndex'] = 0,
			['Flags'] = 3,
			['ID'] = 154,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 112,
			['TargetType'] = 8
		}
	},
	[113] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 155,
			['Period'] = 0,
			['Points'] = 1.2,
			['SpellID'] = 113,
			['TargetType'] = 11
		}
	},
	[114] = {
		[1] = {
			['Effect'] = 2,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 156,
			['Period'] = 0,
			['Points'] = 0.6,
			['SpellID'] = 114,
			['TargetType'] = 1
		}
	},
	[115] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 157,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 115,
			['TargetType'] = 9
		}
	},
	[116] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 158,
			['Period'] = 0,
			['Points'] = 1.2,
			['SpellID'] = 116,
			['TargetType'] = 3
		}
	},
	[117] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 159,
			['Period'] = 0,
			['Points'] = 0.4,
			['SpellID'] = 117,
			['TargetType'] = 15
		}
	},
	[118] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 160,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 118,
			['TargetType'] = 5
		}
	},
	[119] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 161,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 119,
			['TargetType'] = 11
		}
	},
	[120] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 162,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 120,
			['TargetType'] = 20
		}
	},
	[121] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 163,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 121,
			['TargetType'] = 7
		}
	},
	[122] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 164,
			['Period'] = 3,
			['Points'] = 0.3,
			['SpellID'] = 122,
			['TargetType'] = 21
		}
	},
	[123] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 165,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 123,
			['TargetType'] = 14
		}
	},
	[124] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 166,
			['Period'] = 0,
			['Points'] = 0.6,
			['SpellID'] = 124,
			['TargetType'] = 9
		}
	},
	[125] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 167,
			['Period'] = 0,
			['Points'] = 0.6,
			['SpellID'] = 125,
			['TargetType'] = 20
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 168,
			['Period'] = 1,
			['Points'] = -0.5,
			['SpellID'] = 125,
			['TargetType'] = 0
		}
	},
	[126] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 169,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 126,
			['TargetType'] = 14
		}
	},
	[127] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 170,
			['Period'] = 0,
			['Points'] = 0.6,
			['SpellID'] = 127,
			['TargetType'] = 15
		}
	},
	[128] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 171,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 128,
			['TargetType'] = 17
		}
	},
	[129] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 172,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 129,
			['TargetType'] = 6
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 173,
			['Period'] = 1,
			['Points'] = 0.5,
			['SpellID'] = 129,
			['TargetType'] = 6
		}
	},
	[130] = {
		[1] = {
			['Effect'] = 16,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 174,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 130,
			['TargetType'] = 1
		}
	},
	[131] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 175,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 131,
			['TargetType'] = 17
		}
	},
	[132] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 176,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 132,
			['TargetType'] = 15
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 177,
			['Period'] = 1,
			['Points'] = -0.25,
			['SpellID'] = 132,
			['TargetType'] = 15
		}
	},
	[133] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 178,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 133,
			['TargetType'] = 17
		},
		[2] = {
			['Effect'] = 4,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 179,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 133,
			['TargetType'] = 1
		}
	},
	[134] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 180,
			['Period'] = 0,
			['Points'] = 0.25,
			['SpellID'] = 134,
			['TargetType'] = 7
		}
	},
	[135] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 181,
			['Period'] = 0,
			['Points'] = 3,
			['SpellID'] = 135,
			['TargetType'] = 17
		}
	},
	[136] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 182,
			['Period'] = 3,
			['Points'] = 1.5,
			['SpellID'] = 136,
			['TargetType'] = 3
		}
	},
	[137] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 183,
			['Period'] = 0,
			['Points'] = 0.25,
			['SpellID'] = 137,
			['TargetType'] = 1
		}
	},
	[138] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 184,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 138,
			['TargetType'] = 9
		}
	},
	[139] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 185,
			['Period'] = 0,
			['Points'] = 4,
			['SpellID'] = 139,
			['TargetType'] = 17
		}
	},
	[140] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 186,
			['Period'] = 0,
			['Points'] = 0.6,
			['SpellID'] = 140,
			['TargetType'] = 17
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 187,
			['Period'] = 0,
			['Points'] = -0.1,
			['SpellID'] = 140,
			['TargetType'] = 17
		}
	},
	[141] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 188,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 141,
			['TargetType'] = 6
		}
	},
	[142] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 189,
			['Period'] = 0,
			['Points'] = 0.7,
			['SpellID'] = 142,
			['TargetType'] = 10
		}
	},
	[143] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 190,
			['Period'] = 2,
			['Points'] = 0.25,
			['SpellID'] = 143,
			['TargetType'] = 1
		}
	},
	[144] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 191,
			['Period'] = 0,
			['Points'] = -0.75,
			['SpellID'] = 144,
			['TargetType'] = 22
		}
	},
	[145] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 192,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 145,
			['TargetType'] = 3
		}
	},
	[146] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 193,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 146,
			['TargetType'] = 5
		}
	},
	[147] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 194,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 147,
			['TargetType'] = 22
		}
	},
	[148] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 195,
			['Period'] = 0,
			['Points'] = 1.25,
			['SpellID'] = 148,
			['TargetType'] = 14
		}
	},
	[149] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 196,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 149,
			['TargetType'] = 15
		}
	},
	[150] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 197,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 150,
			['TargetType'] = 11
		}
	},
	[151] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 198,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 151,
			['TargetType'] = 3
		}
	},
	[152] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 199,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 152,
			['TargetType'] = 22
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 200,
			['Period'] = 1,
			['Points'] = 0.5,
			['SpellID'] = 152,
			['TargetType'] = 22
		}
	},
	[153] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 201,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 153,
			['TargetType'] = 11
		}
	},
	[154] = {
		[1] = {
			['Effect'] = 16,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 202,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 154,
			['TargetType'] = 1
		}
	},
	[155] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 203,
			['Period'] = 0,
			['Points'] = -0.75,
			['SpellID'] = 155,
			['TargetType'] = 7
		}
	},
	[156] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 204,
			['Period'] = 0,
			['Points'] = 0.4,
			['SpellID'] = 156,
			['TargetType'] = 7
		}
	},
	[157] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 205,
			['Period'] = 0,
			['Points'] = 0.8,
			['SpellID'] = 157,
			['TargetType'] = 9
		}
	},
	[158] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 206,
			['Period'] = 0,
			['Points'] = 3,
			['SpellID'] = 158,
			['TargetType'] = 17
		}
	},
	[159] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 207,
			['Period'] = 2,
			['Points'] = -0.25,
			['SpellID'] = 159,
			['TargetType'] = 7
		}
	},
	[160] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 208,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 160,
			['TargetType'] = 7
		}
	},
	[161] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 209,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 161,
			['TargetType'] = 6
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 210,
			['Period'] = 0,
			['Points'] = 0.25,
			['SpellID'] = 161,
			['TargetType'] = 6
		}
	},
	[162] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 211,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 162,
			['TargetType'] = 7
		}
	},
	[163] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 212,
			['Period'] = 0,
			['Points'] = 4,
			['SpellID'] = 163,
			['TargetType'] = 7
		}
	},
	[164] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 3,
			['ID'] = 213,
			['Period'] = 3,
			['Points'] = 2,
			['SpellID'] = 164,
			['TargetType'] = 11
		}
	},
	[165] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 214,
			['Period'] = 0,
			['Points'] = 3,
			['SpellID'] = 165,
			['TargetType'] = 3
		}
	},
	[166] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 215,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 166,
			['TargetType'] = 21
		},
		[2] = {
			['Effect'] = 4,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 216,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 166,
			['TargetType'] = 1
		}
	},
	[167] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 217,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 167,
			['TargetType'] = 5
		}
	},
	[168] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 218,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 168,
			['TargetType'] = 3
		}
	},
	[169] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 219,
			['Period'] = 0,
			['Points'] = 0.65,
			['SpellID'] = 169,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 7,
			['EffectIndex'] = 1,
			['Flags'] = 3,
			['ID'] = 220,
			['Period'] = 3,
			['Points'] = 0.5,
			['SpellID'] = 169,
			['TargetType'] = 3
		}
	},
	[170] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 221,
			['Period'] = 0,
			['Points'] = 0.6,
			['SpellID'] = 170,
			['TargetType'] = 15
		}
	},
	[171] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 222,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 171,
			['TargetType'] = 5
		}
	},
	[172] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 223,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 172,
			['TargetType'] = 15
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 224,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 172,
			['TargetType'] = 15
		}
	},
	[173] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 225,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 173,
			['TargetType'] = 5
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 226,
			['Period'] = 0,
			['Points'] = -0.25,
			['SpellID'] = 173,
			['TargetType'] = 5
		}
	},
	[174] = {
		[1] = {
			['Effect'] = 16,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 227,
			['Period'] = 0,
			['Points'] = 0.4,
			['SpellID'] = 174,
			['TargetType'] = 1
		}
	},
	[175] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 228,
			['Period'] = 0,
			['Points'] = 1.2,
			['SpellID'] = 175,
			['TargetType'] = 19
		}
	},
	[176] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 229,
			['Period'] = 0,
			['Points'] = 0.25,
			['SpellID'] = 176,
			['TargetType'] = 7
		}
	},
	[177] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 230,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 177,
			['TargetType'] = 3
		}
	},
	[178] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 231,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 178,
			['TargetType'] = 5
		},
		[2] = {
			['Effect'] = 4,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 232,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 178,
			['TargetType'] = 1
		}
	},
	[179] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 233,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 179,
			['TargetType'] = 6
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 234,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 179,
			['TargetType'] = 6
		}
	},
	[180] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 235,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 180,
			['TargetType'] = 20
		}
	},
	[181] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 236,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 181,
			['TargetType'] = 17
		}
	},
	[182] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 237,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 182,
			['TargetType'] = 7
		}
	},
	[183] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 238,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 183,
			['TargetType'] = 15
		}
	},
	[184] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 239,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 184,
			['TargetType'] = 11
		}
	},
	[185] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 240,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 185,
			['TargetType'] = 7
		}
	},
	[186] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 241,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 186,
			['TargetType'] = 15
		}
	},
	[187] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 3,
			['ID'] = 242,
			['Period'] = 2,
			['Points'] = 0.5,
			['SpellID'] = 187,
			['TargetType'] = 7
		}
	},
	[188] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 243,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 188,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 244,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 188,
			['TargetType'] = 3
		}
	},
	[189] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 245,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 189,
			['TargetType'] = 3
		}
	},
	[190] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 246,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 190,
			['TargetType'] = 15
		}
	},
	[191] = {
		[1] = {
			['Effect'] = 1,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 247,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 191,
			['TargetType'] = 7
		},
		[2] = {
			['Effect'] = 2,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 248,
			['Period'] = 0,
			['Points'] = 0.1,
			['SpellID'] = 191,
			['TargetType'] = 6
		}
	},
	[192] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 249,
			['Period'] = 0,
			['Points'] = 1.6,
			['SpellID'] = 192,
			['TargetType'] = 5
		}
	},
	[193] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 250,
			['Period'] = 0,
			['Points'] = 3,
			['SpellID'] = 193,
			['TargetType'] = 15
		},
		[2] = {
			['Effect'] = 3,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 251,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 193,
			['TargetType'] = 1
		}
	},
	[194] = {
		[1] = {
			['Effect'] = 19,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 252,
			['Period'] = 0,
			['Points'] = 0.4,
			['SpellID'] = 194,
			['TargetType'] = 2
		},
		[2] = {
			['Effect'] = 14,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 253,
			['Period'] = 0,
			['Points'] = -0.2,
			['SpellID'] = 194,
			['TargetType'] = 2
		},
		[3] = {
			['Effect'] = 3,
			['EffectIndex'] = 2,
			['Flags'] = 1,
			['ID'] = 254,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 194,
			['TargetType'] = 1
		}
	},
	[195] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 3,
			['ID'] = 255,
			['Period'] = 1,
			['Points'] = 0.8,
			['SpellID'] = 195,
			['TargetType'] = 11
		}
	},
	[196] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 256,
			['Period'] = 0,
			['Points'] = 1.2,
			['SpellID'] = 196,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 3,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 257,
			['Period'] = 0,
			['Points'] = 0.9,
			['SpellID'] = 196,
			['TargetType'] = 3
		},
		[3] = {
			['Effect'] = 3,
			['EffectIndex'] = 2,
			['Flags'] = 1,
			['ID'] = 258,
			['Period'] = 0,
			['Points'] = 0.6,
			['SpellID'] = 196,
			['TargetType'] = 3
		},
		[4] = {
			['Effect'] = 3,
			['EffectIndex'] = 3,
			['Flags'] = 1,
			['ID'] = 259,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 196,
			['TargetType'] = 3
		}
	},
	[197] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 260,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 197,
			['TargetType'] = 8
		}
	},
	[198] = {
		[1] = {
			['Effect'] = 13,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 261,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 198,
			['TargetType'] = 1
		},
		[2] = {
			['Effect'] = 16,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 262,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 198,
			['TargetType'] = 1
		}
	},
	[199] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 263,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 199,
			['TargetType'] = 15
		}
	},
	[200] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 264,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 200,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 265,
			['Period'] = 1,
			['Points'] = -0.5,
			['SpellID'] = 200,
			['TargetType'] = 3
		}
	},
	[201] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 266,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 201,
			['TargetType'] = 17
		}
	},
	[202] = {
		[1] = {
			['Effect'] = 9,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 267,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 202,
			['TargetType'] = 7
		}
	},
	[203] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 268,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 203,
			['TargetType'] = 15
		}
	},
	[204] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 269,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 204,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 270,
			['Period'] = 2,
			['Points'] = -0.5,
			['SpellID'] = 204,
			['TargetType'] = 3
		}
	},
	[205] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 271,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 205,
			['TargetType'] = 14
		}
	},
	[206] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 272,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 206,
			['TargetType'] = 3
		}
	},
	[207] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 273,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 207,
			['TargetType'] = 13
		}
	},
	[208] = {
		[1] = {
			['Effect'] = 9,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 274,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 208,
			['TargetType'] = 21
		}
	},
	[209] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 275,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 209,
			['TargetType'] = 21
		}
	},
	[210] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 276,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 210,
			['TargetType'] = 7
		}
	},
	[211] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 277,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 211,
			['TargetType'] = 11
		}
	},
	[212] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 278,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 212,
			['TargetType'] = 19
		}
	},
	[213] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 279,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 213,
			['TargetType'] = 10
		}
	},
	[214] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 280,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 214,
			['TargetType'] = 11
		}
	},
	[215] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 281,
			['Period'] = 0,
			['Points'] = 3,
			['SpellID'] = 215,
			['TargetType'] = 3
		}
	},
	[216] = {
		[1] = {
			['Effect'] = 10,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 282,
			['Period'] = 0,
			['Points'] = 3,
			['SpellID'] = 216,
			['TargetType'] = 1
		}
	},
	[217] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 283,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 217,
			['TargetType'] = 17
		}
	},
	[218] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 284,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 218,
			['TargetType'] = 1
		}
	},
	[219] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 285,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 219,
			['TargetType'] = 2
		},
		[2] = {
			['Effect'] = 14,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 286,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 219,
			['TargetType'] = 2
		}
	},
	[220] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 287,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 220,
			['TargetType'] = 15
		}
	},
	[221] = {
		[1] = {
			['Effect'] = 10,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 288,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 221,
			['TargetType'] = 1
		}
	},
	[222] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 289,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 222,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 7,
			['EffectIndex'] = 1,
			['Flags'] = 3,
			['ID'] = 290,
			['Period'] = 2,
			['Points'] = 0.3,
			['SpellID'] = 222,
			['TargetType'] = 3
		}
	},
	[223] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 291,
			['Period'] = 1,
			['Points'] = 0.1,
			['SpellID'] = 223,
			['TargetType'] = 23
		}
	},
	[224] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 292,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 224,
			['TargetType'] = 15
		}
	},
	[225] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 293,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 225,
			['TargetType'] = 11
		}
	},
	[226] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 294,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 226,
			['TargetType'] = 11
		}
	},
	[227] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 295,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 227,
			['TargetType'] = 20
		}
	},
	[228] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 296,
			['Period'] = 0,
			['Points'] = 10,
			['SpellID'] = 228,
			['TargetType'] = 23
		}
	},
	[229] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 297,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 229,
			['TargetType'] = 21
		}
	},
	[230] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 298,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 230,
			['TargetType'] = 24
		}
	},
	[231] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 299,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 231,
			['TargetType'] = 20
		}
	},
	[232] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 300,
			['Period'] = 3,
			['Points'] = -0.5,
			['SpellID'] = 232,
			['TargetType'] = 20
		}
	},
	[233] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 301,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 233,
			['TargetType'] = 3
		}
	},
	[234] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 302,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 234,
			['TargetType'] = 21
		}
	},
	[235] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 303,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 235,
			['TargetType'] = 5
		}
	},
	[236] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 304,
			['Period'] = 2,
			['Points'] = -0.5,
			['SpellID'] = 236,
			['TargetType'] = 6
		}
	},
	[237] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 305,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 237,
			['TargetType'] = 15
		}
	},
	[238] = {
		[1] = {
			['Effect'] = 9,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 306,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 238,
			['TargetType'] = 7
		}
	},
	[239] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 307,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 239,
			['TargetType'] = 17
		}
	},
	[240] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 308,
			['Period'] = 0,
			['Points'] = 0.25,
			['SpellID'] = 240,
			['TargetType'] = 13
		}
	},
	[241] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 309,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 241,
			['TargetType'] = 5
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 310,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 241,
			['TargetType'] = 5
		}
	},
	[242] = {
		[1] = {
			['Effect'] = 4,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 311,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 242,
			['TargetType'] = 2
		},
		[2] = {
			['Effect'] = 14,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 312,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 242,
			['TargetType'] = 2
		}
	},
	[243] = {
		[1] = {
			['Effect'] = 9,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 313,
			['Period'] = 0,
			['Points'] = 0,
			['SpellID'] = 243,
			['TargetType'] = 7
		},
		[2] = {
			['Effect'] = 14,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 314,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 243,
			['TargetType'] = 1
		}
	},
	[244] = {
		[1] = {
			['Effect'] = 19,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 315,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 244,
			['TargetType'] = 1
		},
		[2] = {
			['Effect'] = 20,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 316,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 244,
			['TargetType'] = 1
		},
		[3] = {
			['Effect'] = 3,
			['EffectIndex'] = 2,
			['Flags'] = 1,
			['ID'] = 317,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 244,
			['TargetType'] = 3
		}
	},
	[245] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 318,
			['Period'] = 0,
			['Points'] = 1.2,
			['SpellID'] = 245,
			['TargetType'] = 3
		}
	},
	[246] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 319,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 246,
			['TargetType'] = 3
		}
	},
	[247] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 320,
			['Period'] = 0,
			['Points'] = 0.1,
			['SpellID'] = 247,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 4,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 321,
			['Period'] = 0,
			['Points'] = 0.2,
			['SpellID'] = 247,
			['TargetType'] = 1
		}
	},
	[248] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 322,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 248,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 7,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 323,
			['Period'] = 1,
			['Points'] = 0.15,
			['SpellID'] = 248,
			['TargetType'] = 3
		}
	},
	[249] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 324,
			['Period'] = 0,
			['Points'] = 0.6,
			['SpellID'] = 249,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 325,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 249,
			['TargetType'] = 3
		}
	},
	[250] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 326,
			['Period'] = 0,
			['Points'] = 0.8,
			['SpellID'] = 250,
			['TargetType'] = 5
		}
	},
	[251] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 327,
			['Period'] = 0,
			['Points'] = -0.2,
			['SpellID'] = 251,
			['TargetType'] = 7
		}
	},
	[252] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 328,
			['Period'] = 0,
			['Points'] = 0.6,
			['SpellID'] = 252,
			['TargetType'] = 9
		},
		[2] = {
			['Effect'] = 14,
			['EffectIndex'] = 1,
			['Flags'] = 0,
			['ID'] = 329,
			['Period'] = 0,
			['Points'] = 0.25,
			['SpellID'] = 252,
			['TargetType'] = 9
		}
	},
	[253] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 330,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 253,
			['TargetType'] = 15
		}
	},
	[254] = {
		[1] = {
			['Effect'] = 16,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 331,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 254,
			['TargetType'] = 22
		}
	},
	[255] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 332,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 255,
			['TargetType'] = 2
		}
	},
	[256] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 333,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 256,
			['TargetType'] = 11
		}
	},
	[257] = {
		[1] = {
			['Effect'] = 10,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 334,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 257,
			['TargetType'] = 1
		}
	},
	[258] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 335,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 258,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 7,
			['EffectIndex'] = 1,
			['Flags'] = 3,
			['ID'] = 336,
			['Period'] = 3,
			['Points'] = 0.5,
			['SpellID'] = 258,
			['TargetType'] = 3
		}
	},
	[259] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 337,
			['Period'] = 3,
			['Points'] = 0.3,
			['SpellID'] = 259,
			['TargetType'] = 3
		}
	},
	[260] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 338,
			['Period'] = 3,
			['Points'] = 1.5,
			['SpellID'] = 260,
			['TargetType'] = 5
		}
	},
	[261] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 339,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 261,
			['TargetType'] = 2
		}
	},
	[262] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 340,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 262,
			['TargetType'] = 15
		}
	},
	[263] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 341,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 263,
			['TargetType'] = 11
		}
	},
	[264] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 342,
			['Period'] = 0,
			['Points'] = 3,
			['SpellID'] = 264,
			['TargetType'] = 5
		}
	},
	[265] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 343,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 265,
			['TargetType'] = 13
		}
	},
	[266] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 344,
			['Period'] = 0,
			['Points'] = 10,
			['SpellID'] = 266,
			['TargetType'] = 3
		}
	},
	[267] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 345,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 267,
			['TargetType'] = 5
		}
	},
	[268] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 346,
			['Period'] = 0,
			['Points'] = -0.3,
			['SpellID'] = 268,
			['TargetType'] = 15
		}
	},
	[269] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 347,
			['Period'] = 0,
			['Points'] = 1.2,
			['SpellID'] = 269,
			['TargetType'] = 15
		}
	},
	[270] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 348,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 270,
			['TargetType'] = 3
		}
	},
	[271] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 349,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 271,
			['TargetType'] = 5
		}
	},
	[272] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 350,
			['Period'] = 0,
			['Points'] = 1.5,
			['SpellID'] = 272,
			['TargetType'] = 5
		}
	},
	[273] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 351,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 273,
			['TargetType'] = 3
		}
	},
	[274] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 352,
			['Period'] = 0,
			['Points'] = 1.2,
			['SpellID'] = 274,
			['TargetType'] = 15
		}
	},
	[275] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 353,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 275,
			['TargetType'] = 2
		}
	},
	[276] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 354,
			['Period'] = 0,
			['Points'] = 0.25,
			['SpellID'] = 276,
			['TargetType'] = 5
		},
		[2] = {
			['Effect'] = 7,
			['EffectIndex'] = 1,
			['Flags'] = 3,
			['ID'] = 355,
			['Period'] = 3,
			['Points'] = 0.5,
			['SpellID'] = 276,
			['TargetType'] = 5
		}
	},
	[277] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 356,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 277,
			['TargetType'] = 1
		}
	},
	[278] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 357,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 278,
			['TargetType'] = 5
		}
	},
	[279] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 358,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 279,
			['TargetType'] = 17
		}
	},
	[280] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 359,
			['Period'] = 0,
			['Points'] = 2.5,
			['SpellID'] = 280,
			['TargetType'] = 15
		}
	},
	[281] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 360,
			['Period'] = 3,
			['Points'] = 1.5,
			['SpellID'] = 281,
			['TargetType'] = 5
		}
	},
	[282] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 361,
			['Period'] = 0,
			['Points'] = 10,
			['SpellID'] = 282,
			['TargetType'] = 3
		}
	},
	[283] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 362,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 283,
			['TargetType'] = 13
		}
	},
	[284] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 363,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 284,
			['TargetType'] = 22
		}
	},
	[285] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 364,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 285,
			['TargetType'] = 7
		}
	},
	[286] = {
		[1] = {
			['Effect'] = 12,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 365,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 286,
			['TargetType'] = 2
		}
	},
	[287] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 366,
			['Period'] = 0,
			['Points'] = -0.5,
			['SpellID'] = 287,
			['TargetType'] = 1
		}
	},
	[288] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 367,
			['Period'] = 0,
			['Points'] = 0.6,
			['SpellID'] = 288,
			['TargetType'] = 17
		}
	},
	[289] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 3,
			['ID'] = 368,
			['Period'] = 3,
			['Points'] = 1,
			['SpellID'] = 289,
			['TargetType'] = 5
		}
	},
	[290] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 369,
			['Period'] = 3,
			['Points'] = 1.5,
			['SpellID'] = 290,
			['TargetType'] = 5
		}
	},
	[291] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 370,
			['Period'] = 3,
			['Points'] = 1,
			['SpellID'] = 291,
			['TargetType'] = 15
		}
	},
	[292] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 371,
			['Period'] = 0,
			['Points'] = 0.5,
			['SpellID'] = 292,
			['TargetType'] = 3
		},
		[2] = {
			['Effect'] = 3,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 372,
			['Period'] = 0,
			['Points'] = 0.75,
			['SpellID'] = 292,
			['TargetType'] = 3
		}
	},
	[293] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 373,
			['Period'] = 0,
			['Points'] = 0.6,
			['SpellID'] = 293,
			['TargetType'] = 15
		}
	},
	[294] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 374,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 294,
			['TargetType'] = 3
		}
	},
	[295] = {
		[1] = {
			['Effect'] = 14,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 375,
			['Period'] = 2,
			['Points'] = 0.5,
			['SpellID'] = 295,
			['TargetType'] = 3
		}
	},
	[296] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 376,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 296,
			['TargetType'] = 17
		}
	},
	[297] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 377,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 297,
			['TargetType'] = 5
		},
		[2] = {
			['Effect'] = 4,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 378,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 297,
			['TargetType'] = 1
		}
	},
	[298] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 379,
			['Period'] = 0,
			['Points'] = 1,
			['SpellID'] = 298,
			['TargetType'] = 21
		},
		[2] = {
			['Effect'] = 4,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 380,
			['Period'] = 0,
			['Points'] = 0.3,
			['SpellID'] = 298,
			['TargetType'] = 1
		}
	},
	[299] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 381,
			['Period'] = 0,
			['Points'] = 2,
			['SpellID'] = 299,
			['TargetType'] = 5
		}
	},
	[300] = {
		[1] = {
			['Effect'] = 7,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 383,
			['Period'] = 1,
			['Points'] = 0.05,
			['SpellID'] = 300,
			['TargetType'] = 23
		}
	},
	[301] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 0,
			['ID'] = 384,
			['Period'] = 0,
			['Points'] = 0.1,
			['SpellID'] = 301,
			['TargetType'] = 20
		}
	},
	[302] = {
		[1] = {
			['Effect'] = 3,
			['EffectIndex'] = 0,
			['Flags'] = 1,
			['ID'] = 385,
			['Period'] = 2,
			['Points'] = 0.2,
			['SpellID'] = 302,
			['TargetType'] = 7
		},
		[2] = {
			['Effect'] = 12,
			['EffectIndex'] = 1,
			['Flags'] = 1,
			['ID'] = 386,
			['Period'] = 0,
			['Points'] = -0.2,
			['SpellID'] = 302,
			['TargetType'] = 7
		}
	}
}

CMH.DataTables = DataTables
