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
        [3] = {6, 7, 5, 10, 11, 8, 9, 12}, -- not sure
        [4] = {7, 8, 6, 11, 10, 12, 5, 9}, -- not sure
        [5] = {2, 0, 3, 1, 4},
        [6] = {2, 3, 0, 4, 1},
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
        [11] = {0, 2, 1, 3, 4}, -- not sure
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
			['Points'] = 350,
			['SpellID'] = 1,
			['EffectIndex'] = 0,
			['TargetType'] = 24,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 1
		}
	},
	[2] = {
		[1] = {
			['Points'] = 0.2,
			['SpellID'] = 2,
			['EffectIndex'] = 0,
			['TargetType'] = 22,
			['Period'] = 2,
			['Flags'] = 1,
			['Effect'] = 19,
			['ID'] = 2
		},
		[2] = {
			['Points'] = 1,
			['SpellID'] = 2,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 4,
			['ID'] = 120
		}
	},
	[3] = {
		[1] = {
			['Points'] = 45.2,
			['SpellID'] = 3,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 2,
			['ID'] = 3
		},
		[2] = {
			['Points'] = 90.4,
			['SpellID'] = 3,
			['EffectIndex'] = 1,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 1,
			['ID'] = 4
		}
	},
	[4] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 4,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 7
		},
		[2] = {
			['Points'] = 0.5,
			['SpellID'] = 4,
			['EffectIndex'] = 1,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 8
		}
	},
	[5] = {
		[1] = {
			['Points'] = 0.1,
			['SpellID'] = 5,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 9
		}
	},
	[6] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 6,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 10
		}
	},
	[7] = {
		[1] = {
			['Points'] = 0.1,
			['SpellID'] = 7,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 11
		}
	},
	[8] = {
		[1] = {
			['Points'] = 10,
			['SpellID'] = 8,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 12
		}
	},
	[9] = {
		[1] = {
			['Points'] = 0.05,
			['SpellID'] = 9,
			['EffectIndex'] = 0,
			['TargetType'] = 6,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 4,
			['ID'] = 13
		}
	},
	[10] = {
		[1] = {
			['Points'] = 0.2,
			['SpellID'] = 10,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 3,
			['ID'] = 14
		},
		[2] = {
			['Points'] = 0.03,
			['SpellID'] = 10,
			['EffectIndex'] = 1,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 7,
			['ID'] = 15
		},
		[3] = {
			['Points'] = 0.01,
			['SpellID'] = 10,
			['EffectIndex'] = 2,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 8,
			['ID'] = 16
		}
	},
	[11] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 11,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 17
		}
	},
	[12] = {
		[1] = {
			['Points'] = 0.2,
			['SpellID'] = 12,
			['EffectIndex'] = 0,
			['TargetType'] = 6,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 18
		}
	},
	[13] = {
		[1] = {
			['Points'] = 10,
			['SpellID'] = 13,
			['EffectIndex'] = 0,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 2,
			['ID'] = 19
		}
	},
	[14] = {
		[1] = {
			['Points'] = 0.1,
			['SpellID'] = 14,
			['EffectIndex'] = 0,
			['TargetType'] = 6,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 20
		}
	},
	[15] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 15,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 21
		}
	},
	[16] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 16,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 22
		}
	},
	[17] = {
		[1] = {
			['Points'] = 0.1,
			['SpellID'] = 17,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 23
		},
		[2] = {
			['Points'] = 1,
			['SpellID'] = 17,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 2,
			['ID'] = 24
		}
	},
	[18] = {
		[1] = {
			['Points'] = 0.2,
			['SpellID'] = 18,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 26
		},
		[2] = {
			['Points'] = 0.2,
			['SpellID'] = 18,
			['EffectIndex'] = 1,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 27
		},
		[3] = {
			['Points'] = 0.2,
			['SpellID'] = 18,
			['EffectIndex'] = 2,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 28
		}
	},
	[19] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 19,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 29
		}
	},
	[20] = {
		[1] = {
			['Points'] = 0.7,
			['SpellID'] = 20,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 30
		}
	},
	[21] = {
		[1] = {
			['Points'] = 0.15,
			['SpellID'] = 21,
			['EffectIndex'] = 0,
			['TargetType'] = 6,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 8,
			['ID'] = 31
		}
	},
	[22] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 22,
			['EffectIndex'] = 0,
			['TargetType'] = 9,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 32
		},
		[2] = {
			['Points'] = 0.1,
			['SpellID'] = 22,
			['EffectIndex'] = 1,
			['TargetType'] = 9,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 7,
			['ID'] = 33
		}
	},
	[23] = {
		[1] = {
			['Points'] = 11,
			['SpellID'] = 23,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 10,
			['ID'] = 34
		},
		[2] = {
			['Points'] = 0.1,
			['SpellID'] = 23,
			['EffectIndex'] = 1,
			['TargetType'] = 11,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 7,
			['ID'] = 92
		}
	},
	[24] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 24,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 35
		},
		[2] = {
			['Points'] = 0.2,
			['SpellID'] = 24,
			['EffectIndex'] = 1,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 36
		}
	},
	[25] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 25,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 37
		},
		[2] = {
			['Points'] = 0.2,
			['SpellID'] = 25,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 12,
			['ID'] = 38
		}
	},
	[26] = {
		[1] = {
			['Points'] = 0.25,
			['SpellID'] = 26,
			['EffectIndex'] = 0,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 39
		},
		[2] = {
			['Points'] = 0.2,
			['SpellID'] = 26,
			['EffectIndex'] = 1,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 18,
			['ID'] = 40
		}
	},
	[27] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 27,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 41
		}
	},
	[28] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 28,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 42
		}
	},
	[29] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 29,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 43
		}
	},
	[30] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 30,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 44
		}
	},
	[31] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 31,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 45
		}
	},
	[32] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 32,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 46
		}
	},
	[33] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 33,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 47
		}
	},
	[34] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 34,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 48
		}
	},
	[35] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 35,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 49
		}
	},
	[36] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 36,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 50
		}
	},
	[37] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 37,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 51
		}
	},
	[38] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 38,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 52
		}
	},
	[39] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 39,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 53
		}
	},
	[40] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 40,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 54
		}
	},
	[41] = {
		[1] = {
			['Points'] = 0.25,
			['SpellID'] = 41,
			['EffectIndex'] = 0,
			['TargetType'] = 9,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 7,
			['ID'] = 55
		}
	},
	[42] = {
		[1] = {
			['Points'] = 0.1,
			['SpellID'] = 42,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 16,
			['ID'] = 56
		}
	},
	[43] = {
		[1] = {
			['Points'] = 0.25,
			['SpellID'] = 43,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 57
		},
		[2] = {
			['Points'] = 0.2,
			['SpellID'] = 43,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 58
		}
	},
	[44] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 44,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 59
		},
		[2] = {
			['Points'] = 0.25,
			['SpellID'] = 44,
			['EffectIndex'] = 1,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 60
		}
	},
	[45] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 45,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 61
		},
		[2] = {
			['Points'] = 0.25,
			['SpellID'] = 45,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 62
		}
	},
	[46] = {
		[1] = {
			['Points'] = -0.1,
			['SpellID'] = 46,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 63
		},
		[2] = {
			['Points'] = -0.1,
			['SpellID'] = 46,
			['EffectIndex'] = 1,
			['TargetType'] = 16,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 64
		}
	},
	[47] = {
		[1] = {
			['Points'] = -0.2,
			['SpellID'] = 47,
			['EffectIndex'] = 0,
			['TargetType'] = 6,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 65
		}
	},
	[48] = {
		[1] = {
			['Points'] = 0,
			['SpellID'] = 48,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 10,
			['ID'] = 66
		},
		[2] = {
			['Points'] = 0.2,
			['SpellID'] = 48,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 67
		}
	},
	[49] = {
		[1] = {
			['Points'] = 0.33,
			['SpellID'] = 49,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 68
		}
	},
	[50] = {
		[1] = {
			['Points'] = 1.2,
			['SpellID'] = 50,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 69
		}
	},
	[51] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 51,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 70
		}
	},
	[52] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 52,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 71
		}
	},
	[53] = {
		[1] = {
			['Points'] = 0.1,
			['SpellID'] = 53,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 2,
			['Flags'] = 1,
			['Effect'] = 7,
			['ID'] = 72
		},
		[2] = {
			['Points'] = -0.2,
			['SpellID'] = 53,
			['EffectIndex'] = 1,
			['TargetType'] = 7,
			['Period'] = 2,
			['Flags'] = 1,
			['Effect'] = 12,
			['ID'] = 73
		}
	},
	[54] = {
		[1] = {
			['Points'] = 0.45,
			['SpellID'] = 54,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 74
		},
		[2] = {
			['Points'] = 0.45,
			['SpellID'] = 54,
			['EffectIndex'] = 1,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 75
		}
	},
	[55] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 55,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 76
		}
	},
	[56] = {
		[1] = {
			['Points'] = 1.25,
			['SpellID'] = 56,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 77
		}
	},
	[57] = {
		[1] = {
			['Points'] = 0.4,
			['SpellID'] = 57,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 7,
			['ID'] = 78
		}
	},
	[58] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 58,
			['EffectIndex'] = 0,
			['TargetType'] = 9,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 79
		}
	},
	[59] = {
		[1] = {
			['Points'] = 0.4,
			['SpellID'] = 59,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 80
		}
	},
	[60] = {
		[1] = {
			['Points'] = 0.4,
			['SpellID'] = 60,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 81
		}
	},
	[61] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 61,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 82
		}
	},
	[62] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 62,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 83
		}
	},
	[63] = {
		[1] = {
			['Points'] = 0.6,
			['SpellID'] = 63,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 84
		},
		[2] = {
			['Points'] = -0.2,
			['SpellID'] = 63,
			['EffectIndex'] = 1,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 85
		}
	},
	[64] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 64,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 86
		}
	},
	[65] = {
		[1] = {
			['Points'] = 0.65,
			['SpellID'] = 65,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 87
		}
	},
	[66] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 66,
			['EffectIndex'] = 0,
			['TargetType'] = 13,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 88
		}
	},
	[67] = {
		[1] = {
			['Points'] = 1.2,
			['SpellID'] = 67,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 89
		}
	},
	[68] = {
		[1] = {
			['Points'] = 0.2,
			['SpellID'] = 68,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 90
		},
		[2] = {
			['Points'] = -0.8,
			['SpellID'] = 68,
			['EffectIndex'] = 1,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 91
		}
	},
	[69] = {
		[1] = {
			['Points'] = 50,
			['SpellID'] = 69,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 2,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 95
		},
		[2] = {
			['Points'] = 0.2,
			['SpellID'] = 69,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 2,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 96
		},
		[3] = {
			['Points'] = 50,
			['SpellID'] = 69,
			['EffectIndex'] = 2,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 1,
			['ID'] = 97
		},
		[4] = {
			['Points'] = 0.2,
			['SpellID'] = 69,
			['EffectIndex'] = 3,
			['TargetType'] = 0,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 3,
			['ID'] = 98
		}
	},
	[71] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 71,
			['EffectIndex'] = 0,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 2,
			['ID'] = 99
		}
	},
	[72] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 72,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 100
		},
		[2] = {
			['Points'] = 0.3,
			['SpellID'] = 72,
			['EffectIndex'] = 1,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 101
		}
	},
	[73] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 73,
			['EffectIndex'] = 0,
			['TargetType'] = 13,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 102
		}
	},
	[74] = {
		[1] = {
			['Points'] = -0.4,
			['SpellID'] = 74,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 103
		},
		[2] = {
			['Points'] = -0.4,
			['SpellID'] = 74,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 104
		}
	},
	[75] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 75,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 105
		}
	},
	[76] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 76,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 106
		}
	},
	[77] = {
		[1] = {
			['Points'] = 0.2,
			['SpellID'] = 77,
			['EffectIndex'] = 0,
			['TargetType'] = 6,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 19,
			['ID'] = 107
		}
	},
	[78] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 78,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 108
		}
	},
	[79] = {
		[1] = {
			['Points'] = 0.2,
			['SpellID'] = 79,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 109
		},
		[2] = {
			['Points'] = 0.2,
			['SpellID'] = 79,
			['EffectIndex'] = 1,
			['TargetType'] = 6,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 110
		}
	},
	[80] = {
		[1] = {
			['Points'] = 0.6,
			['SpellID'] = 80,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 111
		},
		[2] = {
			['Points'] = 0.2,
			['SpellID'] = 80,
			['EffectIndex'] = 1,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 7,
			['ID'] = 112
		}
	},
	[81] = {
		[1] = {
			['Points'] = 3,
			['SpellID'] = 81,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 15,
			['ID'] = 113
		}
	},
	[82] = {
		[1] = {
			['Points'] = 0.25,
			['SpellID'] = 82,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 16,
			['ID'] = 114
		}
	},
	[83] = {
		[1] = {
			['Points'] = 1.2,
			['SpellID'] = 83,
			['EffectIndex'] = 0,
			['TargetType'] = 9,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 115
		}
	},
	[84] = {
		[1] = {
			['Points'] = -1,
			['SpellID'] = 84,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 116
		}
	},
	[85] = {
		[1] = {
			['Points'] = -50,
			['SpellID'] = 85,
			['EffectIndex'] = 0,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 117
		}
	},
	[86] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 86,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 118
		}
	},
	[87] = {
		[1] = {
			['Points'] = 0.6,
			['SpellID'] = 87,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 119
		}
	},
	[88] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 88,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 121
		},
		[2] = {
			['Points'] = 0.4,
			['SpellID'] = 88,
			['EffectIndex'] = 1,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 123
		}
	},
	[89] = {
		[1] = {
			['Points'] = 0.4,
			['SpellID'] = 89,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 1,
			['Flags'] = 3,
			['Effect'] = 7,
			['ID'] = 124
		}
	},
	[90] = {
		[1] = {
			['Points'] = 0.2,
			['SpellID'] = 90,
			['EffectIndex'] = 0,
			['TargetType'] = 8,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 125
		}
	},
	[91] = {
		[1] = {
			['Points'] = -0.6,
			['SpellID'] = 91,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 11,
			['ID'] = 126
		}
	},
	[92] = {
		[1] = {
			['Points'] = 0.4,
			['SpellID'] = 92,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 1,
			['Flags'] = 3,
			['Effect'] = 7,
			['ID'] = 127
		}
	},
	[93] = {
		[1] = {
			['Points'] = 0.2,
			['SpellID'] = 93,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 128
		},
		[2] = {
			['Points'] = 0.8,
			['SpellID'] = 93,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 129
		}
	},
	[94] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 94,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 1,
			['Flags'] = 1,
			['Effect'] = 7,
			['ID'] = 130
		}
	},
	[95] = {
		[1] = {
			['Points'] = 1.2,
			['SpellID'] = 95,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 131
		},
		[2] = {
			['Points'] = 0.3,
			['SpellID'] = 95,
			['EffectIndex'] = 1,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 132
		}
	},
	[96] = {
		[1] = {
			['Points'] = 0.4,
			['SpellID'] = 96,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 133
		},
		[2] = {
			['Points'] = -0.2,
			['SpellID'] = 96,
			['EffectIndex'] = 1,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 134
		}
	},
	[97] = {
		[1] = {
			['Points'] = 0.9,
			['SpellID'] = 97,
			['EffectIndex'] = 0,
			['TargetType'] = 11,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 135
		}
	},
	[98] = {
		[1] = {
			['Points'] = 1.2,
			['SpellID'] = 98,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 136
		}
	},
	[99] = {
		[1] = {
			['Points'] = 1.4,
			['SpellID'] = 99,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 137
		}
	},
	[100] = {
		[1] = {
			['Points'] = 0.4,
			['SpellID'] = 100,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 138
		}
	},
	[101] = {
		[1] = {
			['Points'] = 0.6,
			['SpellID'] = 101,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 139
		},
		[2] = {
			['Points'] = 0.2,
			['SpellID'] = 101,
			['EffectIndex'] = 1,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 140
		}
	},
	[102] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 102,
			['EffectIndex'] = 0,
			['TargetType'] = 13,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 141
		}
	},
	[103] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 103,
			['EffectIndex'] = 0,
			['TargetType'] = 22,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 142
		}
	},
	[104] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 104,
			['EffectIndex'] = 0,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 2,
			['ID'] = 143
		},
		[2] = {
			['Points'] = -0.1,
			['SpellID'] = 104,
			['EffectIndex'] = 1,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 144
		}
	},
	[105] = {
		[1] = {
			['Points'] = -0.1,
			['SpellID'] = 105,
			['EffectIndex'] = 0,
			['TargetType'] = 6,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 145
		}
	},
	[106] = {
		[1] = {
			['Points'] = 0.4,
			['SpellID'] = 106,
			['EffectIndex'] = 0,
			['TargetType'] = 9,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 146
		}
	},
	[107] = {
		[1] = {
			['Points'] = 0.4,
			['SpellID'] = 107,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 3,
			['Effect'] = 7,
			['ID'] = 147
		},
		[2] = {
			['Points'] = 0.3,
			['SpellID'] = 107,
			['EffectIndex'] = 1,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 3,
			['Effect'] = 20,
			['ID'] = 148
		}
	},
	[108] = {
		[1] = {
			['Points'] = 0.4,
			['SpellID'] = 108,
			['EffectIndex'] = 0,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 149
		},
		[2] = {
			['Points'] = 0.1,
			['SpellID'] = 108,
			['EffectIndex'] = 1,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 2,
			['Effect'] = 18,
			['ID'] = 150
		}
	},
	[109] = {
		[1] = {
			['Points'] = 0.6,
			['SpellID'] = 109,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 16,
			['ID'] = 151
		}
	},
	[110] = {
		[1] = {
			['Points'] = 0.4,
			['SpellID'] = 110,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 152
		}
	},
	[111] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 111,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 153
		}
	},
	[112] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 112,
			['EffectIndex'] = 0,
			['TargetType'] = 8,
			['Period'] = 0,
			['Flags'] = 3,
			['Effect'] = 19,
			['ID'] = 154
		}
	},
	[113] = {
		[1] = {
			['Points'] = 1.2,
			['SpellID'] = 113,
			['EffectIndex'] = 0,
			['TargetType'] = 11,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 155
		}
	},
	[114] = {
		[1] = {
			['Points'] = 0.6,
			['SpellID'] = 114,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 2,
			['ID'] = 156
		}
	},
	[115] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 115,
			['EffectIndex'] = 0,
			['TargetType'] = 9,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 157
		}
	},
	[116] = {
		[1] = {
			['Points'] = 1.2,
			['SpellID'] = 116,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 158
		}
	},
	[117] = {
		[1] = {
			['Points'] = 0.4,
			['SpellID'] = 117,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 159
		}
	},
	[118] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 118,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 160
		}
	},
	[119] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 119,
			['EffectIndex'] = 0,
			['TargetType'] = 11,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 161
		}
	},
	[120] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 120,
			['EffectIndex'] = 0,
			['TargetType'] = 20,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 12,
			['ID'] = 162
		}
	},
	[121] = {
		[1] = {
			['Points'] = -0.5,
			['SpellID'] = 121,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 12,
			['ID'] = 163
		}
	},
	[122] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 122,
			['EffectIndex'] = 0,
			['TargetType'] = 21,
			['Period'] = 3,
			['Flags'] = 1,
			['Effect'] = 7,
			['ID'] = 164
		}
	},
	[123] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 123,
			['EffectIndex'] = 0,
			['TargetType'] = 14,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 165
		}
	},
	[124] = {
		[1] = {
			['Points'] = 0.6,
			['SpellID'] = 124,
			['EffectIndex'] = 0,
			['TargetType'] = 9,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 166
		}
	},
	[125] = {
		[1] = {
			['Points'] = 0.6,
			['SpellID'] = 125,
			['EffectIndex'] = 0,
			['TargetType'] = 20,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 167
		},
		[2] = {
			['Points'] = -0.5,
			['SpellID'] = 125,
			['EffectIndex'] = 1,
			['TargetType'] = 0,
			['Period'] = 1,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 168
		}
	},
	[126] = {
		[1] = {
			['Points'] = 0.2,
			['SpellID'] = 126,
			['EffectIndex'] = 0,
			['TargetType'] = 14,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 169
		}
	},
	[127] = {
		[1] = {
			['Points'] = 0.6,
			['SpellID'] = 127,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 170
		}
	},
	[128] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 128,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 171
		}
	},
	[129] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 129,
			['EffectIndex'] = 0,
			['TargetType'] = 6,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 172
		},
		[2] = {
			['Points'] = 0.5,
			['SpellID'] = 129,
			['EffectIndex'] = 1,
			['TargetType'] = 6,
			['Period'] = 1,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 173
		}
	},
	[130] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 130,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 16,
			['ID'] = 174
		}
	},
	[131] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 131,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 175
		}
	},
	[132] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 132,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 176
		},
		[2] = {
			['Points'] = -0.25,
			['SpellID'] = 132,
			['EffectIndex'] = 1,
			['TargetType'] = 15,
			['Period'] = 1,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 177
		}
	},
	[133] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 133,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 178
		},
		[2] = {
			['Points'] = 0.75,
			['SpellID'] = 133,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 179
		}
	},
	[134] = {
		[1] = {
			['Points'] = 0.25,
			['SpellID'] = 134,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 14,
			['ID'] = 180
		}
	},
	[135] = {
		[1] = {
			['Points'] = 3,
			['SpellID'] = 135,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 181
		}
	},
	[136] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 136,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 3,
			['Flags'] = 1,
			['Effect'] = 7,
			['ID'] = 182
		}
	},
	[137] = {
		[1] = {
			['Points'] = 0.25,
			['SpellID'] = 137,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 183
		}
	},
	[138] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 138,
			['EffectIndex'] = 0,
			['TargetType'] = 9,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 184
		}
	},
	[139] = {
		[1] = {
			['Points'] = 4,
			['SpellID'] = 139,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 185
		}
	},
	[140] = {
		[1] = {
			['Points'] = 0.6,
			['SpellID'] = 140,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 186
		},
		[2] = {
			['Points'] = -0.1,
			['SpellID'] = 140,
			['EffectIndex'] = 1,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 187
		}
	},
	[141] = {
		[1] = {
			['Points'] = -0.5,
			['SpellID'] = 141,
			['EffectIndex'] = 0,
			['TargetType'] = 6,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 188
		}
	},
	[142] = {
		[1] = {
			['Points'] = 0.7,
			['SpellID'] = 142,
			['EffectIndex'] = 0,
			['TargetType'] = 10,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 189
		}
	},
	[143] = {
		[1] = {
			['Points'] = 0.25,
			['SpellID'] = 143,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 2,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 190
		}
	},
	[144] = {
		[1] = {
			['Points'] = -0.75,
			['SpellID'] = 144,
			['EffectIndex'] = 0,
			['TargetType'] = 22,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 191
		}
	},
	[145] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 145,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 192
		}
	},
	[146] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 146,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 193
		}
	},
	[147] = {
		[1] = {
			['Points'] = -0.5,
			['SpellID'] = 147,
			['EffectIndex'] = 0,
			['TargetType'] = 22,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 194
		}
	},
	[148] = {
		[1] = {
			['Points'] = 1.25,
			['SpellID'] = 148,
			['EffectIndex'] = 0,
			['TargetType'] = 14,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 195
		}
	},
	[149] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 149,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 196
		}
	},
	[150] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 150,
			['EffectIndex'] = 0,
			['TargetType'] = 11,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 197
		}
	},
	[151] = {
		[1] = {
			['Points'] = 0.2,
			['SpellID'] = 151,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 198
		}
	},
	[152] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 152,
			['EffectIndex'] = 0,
			['TargetType'] = 22,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 199
		},
		[2] = {
			['Points'] = 0.5,
			['SpellID'] = 152,
			['EffectIndex'] = 1,
			['TargetType'] = 22,
			['Period'] = 1,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 200
		}
	},
	[153] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 153,
			['EffectIndex'] = 0,
			['TargetType'] = 11,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 201
		}
	},
	[154] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 154,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 16,
			['ID'] = 202
		}
	},
	[155] = {
		[1] = {
			['Points'] = -0.75,
			['SpellID'] = 155,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 203
		}
	},
	[156] = {
		[1] = {
			['Points'] = 0.4,
			['SpellID'] = 156,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 204
		}
	},
	[157] = {
		[1] = {
			['Points'] = 0.8,
			['SpellID'] = 157,
			['EffectIndex'] = 0,
			['TargetType'] = 9,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 205
		}
	},
	[158] = {
		[1] = {
			['Points'] = 3,
			['SpellID'] = 158,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 206
		}
	},
	[159] = {
		[1] = {
			['Points'] = -0.25,
			['SpellID'] = 159,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 2,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 207
		}
	},
	[160] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 160,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 208
		}
	},
	[161] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 161,
			['EffectIndex'] = 0,
			['TargetType'] = 6,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 209
		},
		[2] = {
			['Points'] = 0.25,
			['SpellID'] = 161,
			['EffectIndex'] = 1,
			['TargetType'] = 6,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 210
		}
	},
	[162] = {
		[1] = {
			['Points'] = -0.5,
			['SpellID'] = 162,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 211
		}
	},
	[163] = {
		[1] = {
			['Points'] = 4,
			['SpellID'] = 163,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 212
		}
	},
	[164] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 164,
			['EffectIndex'] = 0,
			['TargetType'] = 11,
			['Period'] = 3,
			['Flags'] = 3,
			['Effect'] = 7,
			['ID'] = 213
		}
	},
	[165] = {
		[1] = {
			['Points'] = 3,
			['SpellID'] = 165,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 214
		}
	},
	[166] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 166,
			['EffectIndex'] = 0,
			['TargetType'] = 21,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 215
		},
		[2] = {
			['Points'] = 0.5,
			['SpellID'] = 166,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 216
		}
	},
	[167] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 167,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 217
		}
	},
	[168] = {
		[1] = {
			['Points'] = -0.5,
			['SpellID'] = 168,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 218
		}
	},
	[169] = {
		[1] = {
			['Points'] = 0.65,
			['SpellID'] = 169,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 219
		},
		[2] = {
			['Points'] = 0.5,
			['SpellID'] = 169,
			['EffectIndex'] = 1,
			['TargetType'] = 3,
			['Period'] = 3,
			['Flags'] = 3,
			['Effect'] = 7,
			['ID'] = 220
		}
	},
	[170] = {
		[1] = {
			['Points'] = 0.6,
			['SpellID'] = 170,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 221
		}
	},
	[171] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 171,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 222
		}
	},
	[172] = {
		[1] = {
			['Points'] = 0.2,
			['SpellID'] = 172,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 223
		},
		[2] = {
			['Points'] = -0.5,
			['SpellID'] = 172,
			['EffectIndex'] = 1,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 224
		}
	},
	[173] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 173,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 225
		},
		[2] = {
			['Points'] = -0.25,
			['SpellID'] = 173,
			['EffectIndex'] = 1,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 226
		}
	},
	[174] = {
		[1] = {
			['Points'] = 0.4,
			['SpellID'] = 174,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 16,
			['ID'] = 227
		}
	},
	[175] = {
		[1] = {
			['Points'] = 1.2,
			['SpellID'] = 175,
			['EffectIndex'] = 0,
			['TargetType'] = 19,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 228
		}
	},
	[176] = {
		[1] = {
			['Points'] = 0.25,
			['SpellID'] = 176,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 229
		}
	},
	[177] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 177,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 230
		}
	},
	[178] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 178,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 231
		},
		[2] = {
			['Points'] = 0.5,
			['SpellID'] = 178,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 232
		}
	},
	[179] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 179,
			['EffectIndex'] = 0,
			['TargetType'] = 6,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 233
		},
		[2] = {
			['Points'] = 0.5,
			['SpellID'] = 179,
			['EffectIndex'] = 1,
			['TargetType'] = 6,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 234
		}
	},
	[180] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 180,
			['EffectIndex'] = 0,
			['TargetType'] = 20,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 235
		}
	},
	[181] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 181,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 236
		}
	},
	[182] = {
		[1] = {
			['Points'] = -0.5,
			['SpellID'] = 182,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 237
		}
	},
	[183] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 183,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 238
		}
	},
	[184] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 184,
			['EffectIndex'] = 0,
			['TargetType'] = 11,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 239
		}
	},
	[185] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 185,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 240
		}
	},
	[186] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 186,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 241
		}
	},
	[187] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 187,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 2,
			['Flags'] = 3,
			['Effect'] = 7,
			['ID'] = 242
		}
	},
	[188] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 188,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 243
		},
		[2] = {
			['Points'] = -0.5,
			['SpellID'] = 188,
			['EffectIndex'] = 1,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 244
		}
	},
	[189] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 189,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 245
		}
	},
	[190] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 190,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 246
		}
	},
	[191] = {
		[1] = {
			['Points'] = 0.2,
			['SpellID'] = 191,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 1,
			['ID'] = 247
		},
		[2] = {
			['Points'] = 0.1,
			['SpellID'] = 191,
			['EffectIndex'] = 1,
			['TargetType'] = 6,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 2,
			['ID'] = 248
		}
	},
	[192] = {
		[1] = {
			['Points'] = 1.6,
			['SpellID'] = 192,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 249
		}
	},
	[193] = {
		[1] = {
			['Points'] = 3,
			['SpellID'] = 193,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 250
		},
		[2] = {
			['Points'] = 0.5,
			['SpellID'] = 193,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 251
		}
	},
	[194] = {
		[1] = {
			['Points'] = 0.4,
			['SpellID'] = 194,
			['EffectIndex'] = 0,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 19,
			['ID'] = 252
		},
		[2] = {
			['Points'] = -0.2,
			['SpellID'] = 194,
			['EffectIndex'] = 1,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 14,
			['ID'] = 253
		},
		[3] = {
			['Points'] = 0.2,
			['SpellID'] = 194,
			['EffectIndex'] = 2,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 254
		}
	},
	[195] = {
		[1] = {
			['Points'] = 0.8,
			['SpellID'] = 195,
			['EffectIndex'] = 0,
			['TargetType'] = 11,
			['Period'] = 1,
			['Flags'] = 3,
			['Effect'] = 7,
			['ID'] = 255
		}
	},
	[196] = {
		[1] = {
			['Points'] = 1.2,
			['SpellID'] = 196,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 256
		},
		[2] = {
			['Points'] = 0.9,
			['SpellID'] = 196,
			['EffectIndex'] = 1,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 257
		},
		[3] = {
			['Points'] = 0.6,
			['SpellID'] = 196,
			['EffectIndex'] = 2,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 258
		},
		[4] = {
			['Points'] = 0.3,
			['SpellID'] = 196,
			['EffectIndex'] = 3,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 259
		}
	},
	[197] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 197,
			['EffectIndex'] = 0,
			['TargetType'] = 8,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 260
		}
	},
	[198] = {
		[1] = {
			['Points'] = -0.5,
			['SpellID'] = 198,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 13,
			['ID'] = 261
		},
		[2] = {
			['Points'] = 0.5,
			['SpellID'] = 198,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 16,
			['ID'] = 262
		}
	},
	[199] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 199,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 263
		}
	},
	[200] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 200,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 264
		},
		[2] = {
			['Points'] = -0.5,
			['SpellID'] = 200,
			['EffectIndex'] = 1,
			['TargetType'] = 3,
			['Period'] = 1,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 265
		}
	},
	[201] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 201,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 266
		}
	},
	[202] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 202,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 9,
			['ID'] = 267
		}
	},
	[203] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 203,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 268
		}
	},
	[204] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 204,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 269
		},
		[2] = {
			['Points'] = -0.5,
			['SpellID'] = 204,
			['EffectIndex'] = 1,
			['TargetType'] = 3,
			['Period'] = 2,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 270
		}
	},
	[205] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 205,
			['EffectIndex'] = 0,
			['TargetType'] = 14,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 271
		}
	},
	[206] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 206,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 272
		}
	},
	[207] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 207,
			['EffectIndex'] = 0,
			['TargetType'] = 13,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 273
		}
	},
	[208] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 208,
			['EffectIndex'] = 0,
			['TargetType'] = 21,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 9,
			['ID'] = 274
		}
	},
	[209] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 209,
			['EffectIndex'] = 0,
			['TargetType'] = 21,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 275
		}
	},
	[210] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 210,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 276
		}
	},
	[211] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 211,
			['EffectIndex'] = 0,
			['TargetType'] = 11,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 277
		}
	},
	[212] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 212,
			['EffectIndex'] = 0,
			['TargetType'] = 19,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 278
		}
	},
	[213] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 213,
			['EffectIndex'] = 0,
			['TargetType'] = 10,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 279
		}
	},
	[214] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 214,
			['EffectIndex'] = 0,
			['TargetType'] = 11,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 280
		}
	},
	[215] = {
		[1] = {
			['Points'] = 3,
			['SpellID'] = 215,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 281
		}
	},
	[216] = {
		[1] = {
			['Points'] = 3,
			['SpellID'] = 216,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 10,
			['ID'] = 282
		}
	},
	[217] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 217,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 283
		}
	},
	[218] = {
		[1] = {
			['Points'] = -0.5,
			['SpellID'] = 218,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 284
		}
	},
	[219] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 219,
			['EffectIndex'] = 0,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 285
		},
		[2] = {
			['Points'] = -0.5,
			['SpellID'] = 219,
			['EffectIndex'] = 1,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 286
		}
	},
	[220] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 220,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 287
		}
	},
	[221] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 221,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 10,
			['ID'] = 288
		}
	},
	[222] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 222,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 289
		},
		[2] = {
			['Points'] = 0.3,
			['SpellID'] = 222,
			['EffectIndex'] = 1,
			['TargetType'] = 3,
			['Period'] = 2,
			['Flags'] = 3,
			['Effect'] = 7,
			['ID'] = 290
		}
	},
	[223] = {
		[1] = {
			['Points'] = 0.1,
			['SpellID'] = 223,
			['EffectIndex'] = 0,
			['TargetType'] = 23,
			['Period'] = 1,
			['Flags'] = 1,
			['Effect'] = 7,
			['ID'] = 291
		}
	},
	[224] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 224,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 292
		}
	},
	[225] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 225,
			['EffectIndex'] = 0,
			['TargetType'] = 11,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 293
		}
	},
	[226] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 226,
			['EffectIndex'] = 0,
			['TargetType'] = 11,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 294
		}
	},
	[227] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 227,
			['EffectIndex'] = 0,
			['TargetType'] = 20,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 3,
			['ID'] = 295
		}
	},
	[228] = {
		[1] = {
			['Points'] = 10,
			['SpellID'] = 228,
			['EffectIndex'] = 0,
			['TargetType'] = 23,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 296
		}
	},
	[229] = {
		[1] = {
			['Points'] = -0.5,
			['SpellID'] = 229,
			['EffectIndex'] = 0,
			['TargetType'] = 21,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 297
		}
	},
	[230] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 230,
			['EffectIndex'] = 0,
			['TargetType'] = 24,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 298
		}
	},
	[231] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 231,
			['EffectIndex'] = 0,
			['TargetType'] = 20,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 299
		}
	},
	[232] = {
		[1] = {
			['Points'] = -0.5,
			['SpellID'] = 232,
			['EffectIndex'] = 0,
			['TargetType'] = 20,
			['Period'] = 3,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 300
		}
	},
	[233] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 233,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 301
		}
	},
	[234] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 234,
			['EffectIndex'] = 0,
			['TargetType'] = 21,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 302
		}
	},
	[235] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 235,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 303
		}
	},
	[236] = {
		[1] = {
			['Points'] = -0.5,
			['SpellID'] = 236,
			['EffectIndex'] = 0,
			['TargetType'] = 6,
			['Period'] = 2,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 304
		}
	},
	[237] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 237,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 305
		}
	},
	[238] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 238,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 9,
			['ID'] = 306
		}
	},
	[239] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 239,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 307
		}
	},
	[240] = {
		[1] = {
			['Points'] = 0.25,
			['SpellID'] = 240,
			['EffectIndex'] = 0,
			['TargetType'] = 13,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 308
		}
	},
	[241] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 241,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 309
		},
		[2] = {
			['Points'] = -0.5,
			['SpellID'] = 241,
			['EffectIndex'] = 1,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 310
		}
	},
	[242] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 242,
			['EffectIndex'] = 0,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 311
		},
		[2] = {
			['Points'] = 0.75,
			['SpellID'] = 242,
			['EffectIndex'] = 1,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 312
		}
	},
	[243] = {
		[1] = {
			['Points'] = 0,
			['SpellID'] = 243,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 9,
			['ID'] = 313
		},
		[2] = {
			['Points'] = -0.5,
			['SpellID'] = 243,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 314
		}
	},
	[244] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 244,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 19,
			['ID'] = 315
		},
		[2] = {
			['Points'] = 0.3,
			['SpellID'] = 244,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 20,
			['ID'] = 316
		},
		[3] = {
			['Points'] = 0.3,
			['SpellID'] = 244,
			['EffectIndex'] = 2,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 317
		}
	},
	[245] = {
		[1] = {
			['Points'] = 1.2,
			['SpellID'] = 245,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 318
		}
	},
	[246] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 246,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 319
		}
	},
	[247] = {
		[1] = {
			['Points'] = 0.1,
			['SpellID'] = 247,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 320
		},
		[2] = {
			['Points'] = 0.2,
			['SpellID'] = 247,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 321
		}
	},
	[248] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 248,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 322
		},
		[2] = {
			['Points'] = 0.15,
			['SpellID'] = 248,
			['EffectIndex'] = 1,
			['TargetType'] = 3,
			['Period'] = 1,
			['Flags'] = 1,
			['Effect'] = 7,
			['ID'] = 323
		}
	},
	[249] = {
		[1] = {
			['Points'] = 0.6,
			['SpellID'] = 249,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 324
		},
		[2] = {
			['Points'] = -0.5,
			['SpellID'] = 249,
			['EffectIndex'] = 1,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 325
		}
	},
	[250] = {
		[1] = {
			['Points'] = 0.8,
			['SpellID'] = 250,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 326
		}
	},
	[251] = {
		[1] = {
			['Points'] = -0.2,
			['SpellID'] = 251,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 327
		}
	},
	[252] = {
		[1] = {
			['Points'] = 0.6,
			['SpellID'] = 252,
			['EffectIndex'] = 0,
			['TargetType'] = 9,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 328
		},
		[2] = {
			['Points'] = 0.25,
			['SpellID'] = 252,
			['EffectIndex'] = 1,
			['TargetType'] = 9,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 329
		}
	},
	[253] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 253,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 330
		}
	},
	[254] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 254,
			['EffectIndex'] = 0,
			['TargetType'] = 22,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 16,
			['ID'] = 331
		}
	},
	[255] = {
		[1] = {
			['Points'] = -0.5,
			['SpellID'] = 255,
			['EffectIndex'] = 0,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 332
		}
	},
	[256] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 256,
			['EffectIndex'] = 0,
			['TargetType'] = 11,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 333
		}
	},
	[257] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 257,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 10,
			['ID'] = 334
		}
	},
	[258] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 258,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 335
		},
		[2] = {
			['Points'] = 0.5,
			['SpellID'] = 258,
			['EffectIndex'] = 1,
			['TargetType'] = 3,
			['Period'] = 3,
			['Flags'] = 3,
			['Effect'] = 7,
			['ID'] = 336
		}
	},
	[259] = {
		[1] = {
			['Points'] = 0.3,
			['SpellID'] = 259,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 3,
			['Flags'] = 1,
			['Effect'] = 7,
			['ID'] = 337
		}
	},
	[260] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 260,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 3,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 338
		}
	},
	[261] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 261,
			['EffectIndex'] = 0,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 339
		}
	},
	[262] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 262,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 340
		}
	},
	[263] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 263,
			['EffectIndex'] = 0,
			['TargetType'] = 11,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 341
		}
	},
	[264] = {
		[1] = {
			['Points'] = 3,
			['SpellID'] = 264,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 342
		}
	},
	[265] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 265,
			['EffectIndex'] = 0,
			['TargetType'] = 13,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 343
		}
	},
	[266] = {
		[1] = {
			['Points'] = 10,
			['SpellID'] = 266,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 344
		}
	},
	[267] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 267,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 345
		}
	},
	[268] = {
		[1] = {
			['Points'] = -0.3,
			['SpellID'] = 268,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 346
		}
	},
	[269] = {
		[1] = {
			['Points'] = 1.2,
			['SpellID'] = 269,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 347
		}
	},
	[270] = {
		[1] = {
			['Points'] = -0.5,
			['SpellID'] = 270,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 348
		}
	},
	[271] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 271,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 7,
			['ID'] = 349
		}
	},
	[272] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 272,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 350
		}
	},
	[273] = {
		[1] = {
			['Points'] = -0.5,
			['SpellID'] = 273,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 351
		}
	},
	[274] = {
		[1] = {
			['Points'] = 1.2,
			['SpellID'] = 274,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 352
		}
	},
	[275] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 275,
			['EffectIndex'] = 0,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 353
		}
	},
	[276] = {
		[1] = {
			['Points'] = 0.25,
			['SpellID'] = 276,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 354
		},
		[2] = {
			['Points'] = 0.5,
			['SpellID'] = 276,
			['EffectIndex'] = 1,
			['TargetType'] = 5,
			['Period'] = 3,
			['Flags'] = 3,
			['Effect'] = 7,
			['ID'] = 355
		}
	},
	[277] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 277,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 356
		}
	},
	[278] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 278,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 357
		}
	},
	[279] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 279,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 358
		}
	},
	[280] = {
		[1] = {
			['Points'] = 2.5,
			['SpellID'] = 280,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 359
		}
	},
	[281] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 281,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 3,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 360
		}
	},
	[282] = {
		[1] = {
			['Points'] = 10,
			['SpellID'] = 282,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 361
		}
	},
	[283] = {
		[1] = {
			['Points'] = 0.75,
			['SpellID'] = 283,
			['EffectIndex'] = 0,
			['TargetType'] = 13,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 362
		}
	},
	[284] = {
		[1] = {
			['Points'] = -0.5,
			['SpellID'] = 284,
			['EffectIndex'] = 0,
			['TargetType'] = 22,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 363
		}
	},
	[285] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 285,
			['EffectIndex'] = 0,
			['TargetType'] = 7,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 364
		}
	},
	[286] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 286,
			['EffectIndex'] = 0,
			['TargetType'] = 2,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 12,
			['ID'] = 365
		}
	},
	[287] = {
		[1] = {
			['Points'] = -0.5,
			['SpellID'] = 287,
			['EffectIndex'] = 0,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 366
		}
	},
	[288] = {
		[1] = {
			['Points'] = 0.6,
			['SpellID'] = 288,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 367
		}
	},
	[289] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 289,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 3,
			['Flags'] = 3,
			['Effect'] = 7,
			['ID'] = 368
		}
	},
	[290] = {
		[1] = {
			['Points'] = 1.5,
			['SpellID'] = 290,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 3,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 369
		}
	},
	[291] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 291,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 3,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 370
		}
	},
	[292] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 292,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 371
		},
		[2] = {
			['Points'] = 0.75,
			['SpellID'] = 292,
			['EffectIndex'] = 1,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 372
		}
	},
	[293] = {
		[1] = {
			['Points'] = 0.6,
			['SpellID'] = 293,
			['EffectIndex'] = 0,
			['TargetType'] = 15,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 373
		}
	},
	[294] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 294,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 374
		}
	},
	[295] = {
		[1] = {
			['Points'] = 0.5,
			['SpellID'] = 295,
			['EffectIndex'] = 0,
			['TargetType'] = 3,
			['Period'] = 2,
			['Flags'] = 0,
			['Effect'] = 14,
			['ID'] = 375
		}
	},
	[296] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 296,
			['EffectIndex'] = 0,
			['TargetType'] = 17,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 376
		}
	},
	[297] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 297,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 377
		},
		[2] = {
			['Points'] = 0.3,
			['SpellID'] = 297,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 378
		}
	},
	[298] = {
		[1] = {
			['Points'] = 1,
			['SpellID'] = 298,
			['EffectIndex'] = 0,
			['TargetType'] = 21,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 379
		},
		[2] = {
			['Points'] = 0.3,
			['SpellID'] = 298,
			['EffectIndex'] = 1,
			['TargetType'] = 1,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 4,
			['ID'] = 380
		}
	},
	[299] = {
		[1] = {
			['Points'] = 2,
			['SpellID'] = 299,
			['EffectIndex'] = 0,
			['TargetType'] = 5,
			['Period'] = 0,
			['Flags'] = 1,
			['Effect'] = 3,
			['ID'] = 381
		}
	},
	[300] = {
		[1] = {
			['Points'] = 0.05,
			['SpellID'] = 300,
			['EffectIndex'] = 0,
			['TargetType'] = 23,
			['Period'] = 1,
			['Flags'] = 1,
			['Effect'] = 7,
			['ID'] = 383
		}
	},
	[301] = {
		[1] = {
			['Points'] = 0.1,
			['SpellID'] = 301,
			['EffectIndex'] = 0,
			['TargetType'] = 20,
			['Period'] = 0,
			['Flags'] = 0,
			['Effect'] = 3,
			['ID'] = 384
		}
	}
}

CMH.DataTables = DataTables
