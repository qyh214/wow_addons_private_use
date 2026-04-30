-- PreyQuestData.lua
-- Static lookup table mapping every prey questID to its difficulty index and achievement criteriaID.
-- Difficulty: 1 = Normal, 2 = Hard, 3 = Nightmare
-- Usage: PreyQuestData[questID] = { difficultyIndex, criteriaID }
--
-- These IDs are sourced from WoW game data and match the criteria inside the
-- three primary hunt achievement series:
--   Normal:    42701 (Prey: Normal Mode III)
--   Hard:      42702 (Prey: Hard Mode III)
--   Nightmare: 42703 (Prey: Nightmare Mode III)
--
-- To check completion: GetAchievementCriteriaInfoByID(PREY_HUNT_ACHIEVEMENT_IDS[difficultyIndex], criteriaID)

local addonName, addon = ...

-- The three achievement IDs used for per-target completion checks.
-- Index maps to difficulty: [1]=Normal, [2]=Hard, [3]=Nightmare
addon.PREY_HUNT_ACHIEVEMENT_IDS = { 42701, 42702, 42703 }

-- Per-difficulty progression achievements (I/II/III).
-- These are checked against quest criteria at runtime; entries with no matching
-- quest criteria are ignored for per-row reporting.
addon.PREY_HUNT_MODE_ACHIEVEMENT_IDS_BY_DIFFICULTY = {
    [1] = { 61387, 61386, 42701 }, -- Normal I, II, III
    [2] = { 61389, 61388, 42702 }, -- Hard I, II, III
    [3] = { 61392, 61391, 42703 }, -- Nightmare I, II, III
}

-- Additional per-quest achievements explicitly tracked in issues/achievements.md.
-- Meta/overall achievements are intentionally excluded.
addon.PREY_HUNT_ACHIEVEMENTS_BY_QUEST = {
    [91210] = { 62144 }, [91212] = { 62144 },
    [91214] = { 62153 }, [91216] = { 62153 },
    [91218] = { 62154 }, [91220] = { 62154 },
    [91222] = { 62155 }, [91224] = { 62155 },
    [91226] = { 62156 }, [91228] = { 62156 },
    [91230] = { 62157 }, [91232] = { 62157 },
    [91234] = { 62158 }, [91236] = { 62158 },
    [91238] = { 62159 }, [91240] = { 62159 },
    [91242] = { 62160 }, [91243] = { 62160 },
    [91244] = { 62161 }, [91245] = { 62161 },
    [91246] = { 62162 }, [91247] = { 62162 },
    [91248] = { 62163 }, [91249] = { 62163 },
    [91250] = { 62164 }, [91251] = { 62164 },
    [91252] = { 62165 }, [91253] = { 62165 },
    [91254] = { 62166 }, [91255] = { 62166 },
    [91211] = { 62167 }, [91213] = { 62167 },
    [91215] = { 62168 }, [91217] = { 62168 },
    [91219] = { 62169 }, [91221] = { 62169 },
    [91223] = { 62173 }, [91225] = { 62173 },
    [91227] = { 62174 }, [91229] = { 62174 },
    [91231] = { 62175 }, [91233] = { 62175 },
    [91235] = { 62176 }, [91237] = { 62176 },
    [91239] = { 62177 }, [91241] = { 62177 },
    [91256] = { 62178 }, [91257] = { 62178 },
    [91258] = { 62179 }, [91259] = { 62179 },
    [91260] = { 62180 }, [91261] = { 62180 },
    [91262] = { 62181 }, [91263] = { 62181 },
    [91264] = { 62182 }, [91265] = { 62182 },
    [91266] = { 62183 }, [91267] = { 62183 },
    [91268] = { 62184 }, [91269] = { 62184 },
}

-- [questID] = { difficultyIndex, criteriaID }
addon.PreyQuestData = {
    -- Normal (difficulty 1)
    [91095] = { 1, 105912 }, -- Magister Sunbreaker (Normal)
    [91096] = { 1, 105913 }, -- Magistrix Emberlash (Normal)
    [91097] = { 1, 105914 }, -- Senior Tinker Ozwold (Normal)
    [91098] = { 1, 105915 }, -- L-N-0R the Recycler (Normal)
    [91099] = { 1, 105916 }, -- Mordril Shadowfell (Normal)
    [91100] = { 1, 105917 }, -- Deliah Gloomsong (Normal)
    [91101] = { 1, 105918 }, -- Phaseblade Talasha (Normal)
    [91102] = { 1, 105919 }, -- Nexus-Edge Hadim (Normal)
    [91103] = { 1, 105920 }, -- Jo'zolo the Breaker (Normal)
    [91104] = { 1, 105921 }, -- Zadu, Fist of Nalorakk (Normal)
    [91105] = { 1, 105922 }, -- The Talon of Jan'alai (Normal)
    [91106] = { 1, 105923 }, -- The Wing of Akil'zon (Normal)
    [91107] = { 1, 105924 }, -- Ranger Swiftglade (Normal)
    [91108] = { 1, 105925 }, -- Lieutenant Blazewing (Normal)
    [91109] = { 1, 105926 }, -- Petyoll the Razorleaf (Normal)
    [91110] = { 1, 105927 }, -- Lamyne of the Undercroft (Normal)
    [91111] = { 1, 105928 }, -- High Vindicator Vureem (Normal)
    [91112] = { 1, 105929 }, -- Crusader Luxia Maxwell (Normal)
    [91113] = { 1, 105930 }, -- Praetor Singularis (Normal)
    [91114] = { 1, 105931 }, -- Consul Nebulor (Normal)
    [91115] = { 1, 105932 }, -- Executor Kaenius (Normal)
    [91116] = { 1, 105933 }, -- Imperator Enigmalia (Normal)
    [91117] = { 1, 105934 }, -- Knight-Errant Bloodshatter (Normal)
    [91118] = { 1, 105935 }, -- Vylenna the Defector (Normal)
    [91119] = { 1, 105936 }, -- Lost Theldrin (Normal)
    [91120] = { 1, 105937 }, -- Neydra the Starving (Normal)
    [91121] = { 1, 105938 }, -- Thornspeaker Edgath (Normal)
    [91122] = { 1, 105939 }, -- Thorn-Witch Liset (Normal)
    [91123] = { 1, 105940 }, -- Grothoz, the Burning Shadow (Normal)
    [91124] = { 1, 105941 }, -- Dengzag, the Darkened Blaze (Normal)

    -- Hard (difficulty 2)
    [91210] = { 2, 105942 }, -- Magister Sunbreaker (Hard)
    [91212] = { 2, 105943 }, -- Magistrix Emberlash (Hard)
    [91214] = { 2, 105944 }, -- Senior Tinker Ozwold (Hard)
    [91216] = { 2, 105945 }, -- L-N-0R the Recycler (Hard)
    [91218] = { 2, 105946 }, -- Mordril Shadowfell (Hard)
    [91220] = { 2, 105947 }, -- Deliah Gloomsong (Hard)
    [91222] = { 2, 105948 }, -- Phaseblade Talasha (Hard)
    [91224] = { 2, 105949 }, -- Nexus-Edge Hadim (Hard)
    [91226] = { 2, 105950 }, -- Jo'zolo the Breaker (Hard)
    [91228] = { 2, 105951 }, -- Zadu, Fist of Nalorakk (Hard)
    [91230] = { 2, 105952 }, -- The Talon of Jan'alai (Hard)
    [91232] = { 2, 105953 }, -- The Wing of Akil'zon (Hard)
    [91234] = { 2, 105954 }, -- Ranger Swiftglade (Hard)
    [91236] = { 2, 105955 }, -- Lieutenant Blazewing (Hard)
    [91238] = { 2, 105956 }, -- Petyoll the Razorleaf (Hard)
    [91240] = { 2, 105957 }, -- Lamyne of the Undercroft (Hard)
    [91242] = { 2, 105958 }, -- High Vindicator Vureem (Hard)
    [91243] = { 2, 105959 }, -- Crusader Luxia Maxwell (Hard)
    [91244] = { 2, 105960 }, -- Praetor Singularis (Hard)
    [91245] = { 2, 105961 }, -- Consul Nebulor (Hard)
    [91246] = { 2, 105962 }, -- Executor Kaenius (Hard)
    [91247] = { 2, 105963 }, -- Imperator Enigmalia (Hard)
    [91248] = { 2, 105964 }, -- Knight-Errant Bloodshatter (Hard)
    [91249] = { 2, 105965 }, -- Vylenna the Defector (Hard)
    [91250] = { 2, 105966 }, -- Lost Theldrin (Hard)
    [91251] = { 2, 105967 }, -- Neydra the Starving (Hard)
    [91252] = { 2, 105968 }, -- Thornspeaker Edgath (Hard)
    [91253] = { 2, 105969 }, -- Thorn-Witch Liset (Hard)
    [91254] = { 2, 105970 }, -- Grothoz, the Burning Shadow (Hard)
    [91255] = { 2, 105971 }, -- Dengzag, the Darkened Blaze (Hard)

    -- Nightmare (difficulty 3)
    [91211] = { 3, 105972 }, -- Magister Sunbreaker (Nightmare)
    [91213] = { 3, 105973 }, -- Magistrix Emberlash (Nightmare)
    [91215] = { 3, 105974 }, -- Senior Tinker Ozwold (Nightmare)
    [91217] = { 3, 105975 }, -- L-N-0R the Recycler (Nightmare)
    [91219] = { 3, 105976 }, -- Mordril Shadowfell (Nightmare)
    [91221] = { 3, 105977 }, -- Deliah Gloomsong (Nightmare)
    [91223] = { 3, 105978 }, -- Phaseblade Talasha (Nightmare)
    [91225] = { 3, 105979 }, -- Nexus-Edge Hadim (Nightmare)
    [91227] = { 3, 105980 }, -- Jo'zolo the Breaker (Nightmare)
    [91229] = { 3, 105981 }, -- Zadu, Fist of Nalorakk (Nightmare)
    [91231] = { 3, 105982 }, -- The Talon of Jan'alai (Nightmare)
    [91233] = { 3, 105983 }, -- The Wing of Akil'zon (Nightmare)
    [91235] = { 3, 105984 }, -- Ranger Swiftglade (Nightmare)
    [91237] = { 3, 105985 }, -- Lieutenant Blazewing (Nightmare)
    [91239] = { 3, 105986 }, -- Petyoll the Razorleaf (Nightmare)
    [91241] = { 3, 105987 }, -- Lamyne of the Undercroft (Nightmare)
    [91256] = { 3, 105988 }, -- High Vindicator Vureem (Nightmare)
    [91257] = { 3, 105989 }, -- Crusader Luxia Maxwell (Nightmare)
    [91258] = { 3, 105990 }, -- Praetor Singularis (Nightmare)
    [91259] = { 3, 105991 }, -- Consul Nebulor (Nightmare)
    [91260] = { 3, 105992 }, -- Executor Kaenius (Nightmare)
    [91261] = { 3, 105993 }, -- Imperator Enigmalia (Nightmare)
    [91262] = { 3, 105994 }, -- Knight-Errant Bloodshatter (Nightmare)
    [91263] = { 3, 105995 }, -- Vylenna the Defector (Nightmare)
    [91264] = { 3, 105996 }, -- Lost Theldrin (Nightmare)
    [91265] = { 3, 105997 }, -- Neydra the Starving (Nightmare)
    [91266] = { 3, 105998 }, -- Thornspeaker Edgath (Nightmare)
    [91267] = { 3, 105999 }, -- Thorn-Witch Liset (Nightmare)
    [91268] = { 3, 106000 }, -- Grothoz, the Burning Shadow (Nightmare)
    [91269] = { 3, 106001 }, -- Dengzag, the Darkened Blaze (Nightmare)
}
