-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------
local FOLDER_NAME, private = ...

private.DRAGON_GLYPHS = {
	--Thaldraszus
	[16100] = { zoneID = 2025, artID = { 1708 }, x = 3558, y = 8551 }; --Dragon Glyphs: South Hold Gate
	[16102] = { zoneID = 2025, artID = { 1708 }, x = 4990, y = 4030 }; --Dragon Glyphs: Algeth'era
	[16107] = { zoneID = 2025, artID = { 1708 }, x = 7290, y = 6920 }; --Dragon Glyphs: Thaldrazsus Apex
	[16099] = { zoneID = 2025, artID = { 1708 }, x = 4610, y = 7400 }; --Dragon Glyphs: Stormshroud Peak
	[16104] = { zoneID = 2025, artID = { 1708 }, x = 6240, y = 4050 }; --Dragon Glyphs: Algeth'ar Academy
	[16101] = { zoneID = {
			[2025] = { x = 4126, y = 5813, artID = { 1708 } };
			[2112] = { x = 5922, y = 3795, artID = { 1748 } };
		  }}; --Dragon Glyphs: Valdrakken
	[16106] = { zoneID = 2025, artID = { 1708 }, x = 7200, y = 5200 }; --Dragon Glyphs: Vault of the Incarnates
	[16103] = { zoneID = 2025, artID = { 1708 }, x = 6157, y = 5660 }; --Dragon Glyphs: Tyrhold
	[16098] = { zoneID = 2025, artID = { 1708 }, x = 6600, y = 8230 }; --Dragon Glyphs: Temporal Conflux
	[16105] = { zoneID = 2025, artID = { 1708 }, x = 6710, y = 1180 }; --Dragon Glyphs: Veiled Ossuary
	[16666] = { zoneID = 2025, artID = { 1708 }, x = 5267, y = 6742 }; --Dragon Glyphs: Gelikyr Overlook
	[16667] = { zoneID = 2025, artID = { 1708 }, x = 5573, y = 7225 }; --Dragon Glyphs: Passage of Time
	
	-- The Walking Shores
	[15991] = { zoneID = 2022, artID = { 1706 }, x = 5769, y = 5490 }; --Dragon Glyphs: Crumbling Life Archway
	[16051] = { zoneID = 2022, artID = { 1706 }, x = 6933, y = 4618 }; --Dragon Glyphs: Dragonheart Outpost
	[15989] = { zoneID = 2022, artID = { 1706 }, x = 4640, y = 5211 }; --Dragon Glyphs: The Overflowing Spring
	[15986] = { zoneID = 2022, artID = { 1706 }, x = 7491, y = 3745 }; --Dragon Glyphs: Wingrest Embassy
	[15988] = { zoneID = 2022, artID = { 1706 }, x = 5446, y = 7419 }; --Dragon Glyphs: Ruby Life Pools
	[15990] = { zoneID = 2022, artID = { 1706 }, x = 5264, y = 1715 }; --Dragon Glyphs: Life-Binder Observatory
	[15985] = { zoneID = 2022, artID = { 1706 }, x = 7530, y = 5710 }; --Dragon Glyphs: Skytop Observatory
	[15987] = { zoneID = 2022, artID = { 1706 }, x = 4097, y = 7188 }; --Dragon Glyphs: Obsidian Bulwark
	[16053] = { zoneID = 2022, artID = { 1706 }, x = 2201, y = 5100 }; --Dragon Glyphs: Obsidian Throne
	[16052] = { zoneID = 2022, artID = { 1706 }, x = 7300, y = 2000 }; --Dragon Glyphs: Scalecracker Peak
	[16668] = { zoneID = 2022, artID = { 1706 }, x = 7437, y = 5751 }; --Dragon Glyphs: Skytop Observatory Rostrum
	[16669] = { zoneID = 2022, artID = { 1706 }, x = 5809, y = 7858 }; --Dragon Glyphs: Flashfrost Enclave
	[16670] = { zoneID = 2022, artID = { 1706 }, x = 4884, y = 8680 }; --Dragon Glyphs: Rubyscale Outpost
	
	-- The Azure Span
	[16065] = { zoneID = 2024, artID = { 1707 }, x = 3930, y = 6312 }; --Dragon Glyphs: Azure Archive
	[16072] = { zoneID = 2024, artID = { 1707 }, x = 6760, y = 2910 }; --Dragon Glyphs: Kalthraz Fortress
	[16071] = { zoneID = 2024, artID = { 1707 }, x = 5300, y = 4900 }; --Dragon Glyphs: Zelthrak Outpost
	[16070] = { zoneID = 2024, artID = { 1707 }, x = 6060, y = 7000 }; --Dragon Glyphs: Imbu
	[16068] = { zoneID = 2024, artID = { 1707 }, x = 1040, y = 3600 }; --Dragon Glyphs: Brackenhide Hollow
	[16069] = { zoneID = 2024, artID = { 1707 }, x = 2673, y = 3167 }; --Dragon Glyphs: Creektooth Den
	[16064] = { zoneID = 2024, artID = { 1707 }, x = 4580, y = 2560 }; --Dragon Glyphs: Cobalt Assembly
	[16067] = { zoneID = 2024, artID = { 1707 }, x = 7060, y = 4630 }; --Dragon Glyphs: Lost Ruins
	[16066] = { zoneID = 2024, artID = { 1707 }, x = 6860, y = 6040 }; --Dragon Glyphs: Ruins of Karnthar
	[16073] = { zoneID = 2024, artID = { 1707 }, x = 7259, y = 3970 }; --Dragon Glyphs: Vakthros Range
	[16672] = { zoneID = 2024, artID = { 1707 }, x = 3633, y = 2878 }; --Dragon Glyphs: Forkriver Crossing
	[16673] = { zoneID = 2024, artID = { 1707 }, x = 5681, y = 1612 }; --Dragon Glyphs: The Fallen Course
	
	-- Ohn'ahran Plains
	[16061] = { zoneID = 2023, artID = { 1705 }, x = 8440, y = 7760 }; --Dragon Glyphs: Dragonsprings Summit
	[16057] = { zoneID = 2023, artID = { 1705 }, x = 2950, y = 7510 }; --Dragon Glyphs: The Eternal Kurgans
	[16059] = { zoneID = 2023, artID = { 1705 }, x = 4700, y = 7200 }; --Dragon Glyphs: Mirror of the Sky
	[16054] = { zoneID = 2023, artID = { 1705 }, x = 5780, y = 3100 }; --Dragon Glyphs: Ohn'ahra's Roost
	[16063] = { zoneID = 2023, artID = { 1705 }, x = 6150, y = 6430 }; --Dragon Glyphs: Windsong Rise
	[16060] = { zoneID = 2023, artID = { 1705 }, x = 5730, y = 8030 }; --Dragon Glyphs: Ohn'iri Springs
	[16055] = { zoneID = 2023, artID = { 1705 }, x = 3050, y = 3600 }; --Dragon Glyphs: Nokhudon Hold
	[16056] = { zoneID = 2023, artID = { 1705 }, x = 3010, y = 6130 }; --Dragon Glyphs: Emerald Gardens
	[16062] = { zoneID = 2023, artID = { 1705 }, x = 8647, y = 3944 }; --Dragon Glyphs: Rusza'thar Reach
	[16058] = { zoneID = 2023, artID = { 1705 }, x = 4460, y = 6480 }; --Dragon Glyphs: Szar Skeleth
	[16671] = { zoneID = 2023, artID = { 1705 }, x = 7831, y = 2131 }; --Dragon Glyphs: Mirewood Fen
	
	-- Forbidden Reach
	[17398] = { zoneID = 2151, artID = { 1781 }, x = 1838, y = 1320, parent = 17411 }; --Dragon Glyphs: Winglord's Perch
	[17400] = { zoneID = 2151, artID = { 1781 }, x = 6254, y = 3238, parent = 17411 }; --Dragon Glyphs: Froststone Peak
	[17402] = { zoneID = 2151, artID = { 1781 }, x = 7729, y = 5510, parent = 17411 }; --Dragon Glyphs: Stormsunder Mountain
	[17404] = { zoneID = 2151, artID = { 1781 }, x = 5905, y = 6508, parent = 17411 }; --Dragon Glyphs: Talonlords' Perch
	[17399] = { zoneID = 2151, artID = { 1781 }, x = 2056, y = 9140, parent = 17411 }; --Dragon Glyphs: Talon's Watch
	[17401] = { zoneID = 2151, artID = { 1781 }, x = 7946, y = 3261, parent = 17411 }; --Dragon Glyphs: Dragonskull Island
	[17403] = { zoneID = 2151, artID = { 1781 }, x = 4851, y = 6897, parent = 17411 }; --Dragon Glyphs: The Frosted Spine
	[17405] = { zoneID = 2151, artID = { 1781 }, x = 3769, y = 3069, parent = 17411 }; --Dragon Glyphs: Caldera of the Menders
	
	-- Zaralek Cavern
	[17510] = { zoneID = 2133, artID = { 1775 }, x = 4169, y = 8036, parent = 18150 }; --Dragon Glyphs: Glimmerogg
	[17512] = { zoneID = 2133, artID = { 1775 }, x = 5471, y = 5484, parent = 18150 }; --Dragon Glyphs: Loamm
	[17514] = { zoneID = 2133, artID = { 1775 }, x = 5526, y = 2787, parent = 18150 }; --Dragon Glyphs: Slitherdrake Roost
	[17516] = { zoneID = 2133, artID = { 1775 }, x = 4738, y = 3676, parent = 18150 }; --Dragon Glyphs: Acidbite Ravin
	[17511] = { zoneID = 2133, artID = { 1775 }, x = 6269, y = 7033, parent = 18150 }; --Dragon Glyphs: Nal ks'kol
	[17513] = { zoneID = 2133, artID = { 1775 }, x = 3046, y = 4529, parent = 18150 }; --Dragon Glyphs: Zaqali Caldera
	[17515] = { zoneID = 2133, artID = { 1775 }, x = 7207, y = 4843, parent = 18150 }; --Dragon Glyphs: The Throughway
	[17517] = { zoneID = 2133, artID = { 1775 }, x = 4810, y = 0432, parent = 18150 }; --Dragon Glyphs: Aberrus Approach
	
	-- Emerald Dream
	[19296] = { zoneID = 2200, artID = { 1806 }, x = 6034, y = 3013, parent = 19306 }; --Dragon Glyphs: Eye of Ysera
	[19297] = { zoneID = 2200, artID = { 1806 }, x = 2121, y = 2676, parent = 19306 }; --Dragon Glyphs: Smoldering Ascent
	[19298] = { zoneID = 2200, artID = { 1806 }, x = 3379, y = 4564, parent = 19306 }; --Dragon Glyphs: Smoldering Copse
	[19299] = { zoneID = 2200, artID = { 1806 }, x = 2990, y = 2125, parent = 19306 }; --Dragon Glyphs: Cinder Summit
	[19300] = { zoneID = 2200, artID = { 1806 }, x = 4551, y = 4581, parent = 19306 }; --Dragon Glyphs: Dreamsurge Basin
	[19301] = { zoneID = 2200, artID = { 1806 }, x = 4999, y = 6433, parent = 19306 }; --Dragon Glyphs: Amirdrassil
	[19302] = { zoneID = 2200, artID = { 1806 }, x = 3174, y = 8074, parent = 19306 }; --Dragon Glyphs: Whorlwing basin
	[19303] = { zoneID = 2200, artID = { 1806 }, x = 6167, y = 7548, parent = 19306 }; --Dragon Glyphs: Wakeful Vista
}