-- TraitSpellIDs.lua

local _, addon = ...; 

addon.SpellIDByRelic = {
	-- Burden of Vigilance
	["128306.136973"] = 186396, -- G'Hanir, the Mother Tree (Persistence)
	["128826.136973"] = 190503, -- Thas'dorah, Legacy of the Windrunners (Healing Shell)
	["128825.136973"] = 196489, -- T'uure, Beacon of the Naaru (Power of the Naaru)
	["128937.136973"] = 199365, -- Sheilun, Staff of the Mists (Shroud of Mist)
	["128821.136973"] = 200400, -- Claws of Ursoc (Wildflesh)
	["128823.136973"] = 200327, -- The Silver Hand (Share the Burden)
	["128858.136973"] = 202302, -- Scythe of Elune (Bladed Feathers)
	["128911.136973"] = 207351, -- Sharas'dal, Scepter of Tides (Ghost in the Mist)
	["128860.136973"] = 210557, -- Fangs of Ashamane (Honed Instincts)
	["128938.136973"] = 213047, -- Fu Zan, the Wanderer's Companion (Potent Kick)
	-- Empowerment of Thunder
	["128935.136974"] = 191582, -- The Fist of Ra-den (Shamanistic Healing)
	["128826.136974"] = 190514, -- Thas'dorah, Legacy of the Windrunners (Survival of the Fittest)
	["128940.136974"] = 195380, -- Fists of the Heavens (Healing Winds)
	["128861.136974"] = 197138, -- Titanstrike (Natural Reflexes)
	["128819.136974"] = 198248, -- Doomhammer (Elemental Healing)
	["128937.136974"] = 199384, -- Sheilun, Staff of the Mists (Spirit Tether)
	["128908.136974"] = 200859, -- Warswords of the Valarjar (Bloodcraze)
	["128872.136974"] = 202533, -- The Dreadblades (Ghostly Shell)
	["128808.136974"] = 203749, -- Talonclaw, Spear of the Wild Gods (Hunter's Bounty)
	["128938.136974"] = 213116, -- Fu Zan, the Wanderer's Companion (Face Palm)
	-- Stormfury Diamond
	["128935.137008"] = 191598, -- The Fist of Ra-den (Earthen Attunement)
	["128826.137008"] = 190567, -- Thas'dorah, Legacy of the Windrunners (Gust of Wind)
	["128819.137008"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128937.137008"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128908.137008"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128872.137008"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.137008"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128940.137008"] = 195267, -- Fists of the Heavens (Strength of Xuen)
	["128861.137008"] = 206910, -- Titanstrike (Unleash the Beast)
	["128938.137008"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Faronaar Prayer Beads
	["120978.132983"] = 186945, -- Ashbringer (Wrath of the Ashbringer)
	["128825.132983"] = 196418, -- T'uure, Beacon of the Naaru (Reverence)
	["128868.132983"] = 197716, -- Light's Wrath (Burst of Light)
	["128823.132983"] = 200296, -- The Silver Hand (Expel the Darkness)
	["128866.132983"] = 209226, -- Truthguard (Righteous Crusader)
	-- Abandoned Highborne Mana Crystal
	["127857.132984"] = 187264, -- Aluneth, Greatstaff of the Magna (Aegwynn's Imperative)
	["128820.132984"] = 210182, -- Felo'melorn (Blue Flame Special)
	["128862.132984"] = 195323, -- Ebonchill, Greatstaff of Alodi (Orbital Strike)
	["128861.132984"] = 197139, -- Titanstrike (Focus of the Titans)
	["128858.132984"] = 202433, -- Scythe of Elune (Scythe of the Stars)
	["128866.132984"] = 209226, -- Truthguard (Righteous Crusader)
	["128832.132984"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	-- Blood of the Vanquished Highborne
	["128289.132985"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128403.132985"] = 224466, -- Apocalypse (Runic Tattoos)
	["128402.132985"] = 192457, -- Maw of the Damned (Veinrender)
	["128826.132985"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128870.132985"] = 192326, -- The Kingslayers (Balanced Blades)
	["128827.132985"] = 193645, -- Xal'atath, Blade of the Black Empire (Death's Embrace)
	["128942.132985"] = 199152, -- Ulthalesh, the Deadwind Harvester (Inherently Unstable)
	["128821.132985"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128872.132985"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.132985"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128910.132985"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128860.132985"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	-- Pulsing Infernal Shard
	["128941.132986"] = 196227, -- Scepter of Sargeras (Residual Flames)
	["128476.132986"] = 197235, -- Fangs of the Devourer (Precision Strike)
	["127829.132986"] = 201457, -- Twinblades of the Deceiver (Sharpened Glaives)
	["128943.132986"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	["128832.132986"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	-- Everburning Ruin Ember
	["120978.132987"] = 186945, -- Ashbringer (Wrath of the Ashbringer)
	["128289.132987"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128403.132987"] = 224466, -- Apocalypse (Runic Tattoos)
	["128820.132987"] = 210182, -- Felo'melorn (Blue Flame Special)
	["128941.132987"] = 196227, -- Scepter of Sargeras (Residual Flames)
	["128819.132987"] = 198292, -- Doomhammer (Wind Strikes)
	["128821.132987"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128908.132987"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128943.132987"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	-- The Dreadlord's Chill Eye
	["127857.132988"] = 187264, -- Aluneth, Greatstaff of the Magna (Aegwynn's Imperative)
	["128292.132988"] = 189164, -- Blades of the Fallen Prince (Dead of Winter)
	["128306.132988"] = 189757, -- G'Hanir, the Mother Tree (Infusion of Nature)
	["128935.132988"] = 191740, -- The Fist of Ra-den (Firestorm)
	["128862.132988"] = 195323, -- Ebonchill, Greatstaff of Alodi (Orbital Strike)
	["128937.132988"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128911.132988"] = 207206, -- Sharas'dal, Scepter of Tides (Wavecrash)
	["128860.132988"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	-- Legion Iron Nugget
	["128289.132989"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128402.132989"] = 192457, -- Maw of the Damned (Veinrender)
	["128870.132989"] = 192326, -- The Kingslayers (Balanced Blades)
	["128940.132989"] = 195266, -- Fists of the Heavens (Death Art)
	["128861.132989"] = 197139, -- Titanstrike (Focus of the Titans)
	["128819.132989"] = 198292, -- Doomhammer (Wind Strikes)
	["128908.132989"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128872.132989"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.132989"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128866.132989"] = 209226, -- Truthguard (Righteous Crusader)
	["128910.132989"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128832.132989"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	["128938.132989"] = 213062, -- Fu Zan, the Wanderer's Companion (Dark Side of the Moon)
	-- Fel-Resistant Clipping
	["128306.132990"] = 189757, -- G'Hanir, the Mother Tree (Infusion of Nature)
	["128826.132990"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128825.132990"] = 196418, -- T'uure, Beacon of the Naaru (Reverence)
	["128937.132990"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128821.132990"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128823.132990"] = 200296, -- The Silver Hand (Expel the Darkness)
	["128858.132990"] = 202433, -- Scythe of Elune (Scythe of the Stars)
	["128911.132990"] = 207206, -- Sharas'dal, Scepter of Tides (Wavecrash)
	["128860.132990"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	["128938.132990"] = 213062, -- Fu Zan, the Wanderer's Companion (Dark Side of the Moon)
	-- Mortiferous' Corruption
	["128292.132991"] = 189164, -- Blades of the Fallen Prince (Dead of Winter)
	["128403.132991"] = 224466, -- Apocalypse (Runic Tattoos)
	["128402.132991"] = 192457, -- Maw of the Damned (Veinrender)
	["128870.132991"] = 192326, -- The Kingslayers (Balanced Blades)
	["128827.132991"] = 193645, -- Xal'atath, Blade of the Black Empire (Death's Embrace)
	["128476.132991"] = 197235, -- Fangs of the Devourer (Precision Strike)
	["128868.132991"] = 197716, -- Light's Wrath (Burst of Light)
	["128942.132991"] = 199152, -- Ulthalesh, the Deadwind Harvester (Inherently Unstable)
	["127829.132991"] = 201457, -- Twinblades of the Deceiver (Sharpened Glaives)
	["128910.132991"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128943.132991"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	-- Nethrandamus' Zephyr
	["128935.132993"] = 191740, -- The Fist of Ra-den (Firestorm)
	["128826.132993"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128940.132993"] = 195266, -- Fists of the Heavens (Death Art)
	["128861.132993"] = 197139, -- Titanstrike (Focus of the Titans)
	["128819.132993"] = 198292, -- Doomhammer (Wind Strikes)
	["128937.132993"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128908.132993"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128872.132993"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.132993"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128938.132993"] = 213062, -- Fu Zan, the Wanderer's Companion (Dark Side of the Moon)
	-- Lost Grace of the Nightborne
	["120978.132994"] = 186944, -- Ashbringer (Protector of the Ashen Blade)
	["128825.132994"] = 196430, -- T'uure, Beacon of the Naaru (Words of Healing)
	["128868.132994"] = 197762, -- Light's Wrath (Borrowed Time)
	["128866.132994"] = 209216, -- Truthguard (Bastion of Truth)
	["128823.132994"] = 200482, -- The Silver Hand (Second Sunrise)
	-- Faronaar Arcane Power-Core
	["127857.132995"] = 187287, -- Aluneth, Greatstaff of the Magna (Aegwynn's Fury)
	["128820.132995"] = 194239, -- Felo'melorn (Pyroclasmic Paranoia)
	["128862.132995"] = 195352, -- Ebonchill, Greatstaff of Alodi (The Storm Rages)
	["128858.132995"] = 202464, -- Scythe of Elune (Empowerment)
	["128861.132995"] = 206910, -- Titanstrike (Unleash the Beast)
	["128866.132995"] = 209216, -- Truthguard (Bastion of Truth)
	["128832.132995"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	-- Cursed Felstalker Flesh
	["128289.132996"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128402.132996"] = 192464, -- Maw of the Damned (All-Consuming Rot)
	["128826.132996"] = 190567, -- Thas'dorah, Legacy of the Windrunners (Gust of Wind)
	["128870.132996"] = 192376, -- The Kingslayers (Poison Knives)
	["128827.132996"] = 194002, -- Xal'atath, Blade of the Black Empire (Creeping Shadows)
	["128942.132996"] = 199163, -- Ulthalesh, the Deadwind Harvester (Shadowy Incantations)
	["128821.132996"] = 200415, -- Claws of Ursoc (Sharpened Instincts)
	["128872.132996"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.132996"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128403.132996"] = 208598, -- Apocalypse (Eternal Agony)
	["128910.132996"] = 209494, -- Strom'kar, the Warbreaker (Exploit the Weakness)
	["128860.132996"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	-- Legion Camp Reactor Core
	["128941.132997"] = 196258, -- Scepter of Sargeras (Fire From the Sky)
	["128476.132997"] = 197239, -- Fangs of the Devourer (Energetic Stabbing)
	["127829.132997"] = 201464, -- Twinblades of the Deceiver (Overwhelming Power)
	["128943.132997"] = 211099, -- Skull of the Man'ari (Maw of Shadows)
	["128832.132997"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	-- The Sufferer's Fury
	["120978.132998"] = 186944, -- Ashbringer (Protector of the Ashen Blade)
	["128289.132998"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128820.132998"] = 194239, -- Felo'melorn (Pyroclasmic Paranoia)
	["128941.132998"] = 196258, -- Scepter of Sargeras (Fire From the Sky)
	["128819.132998"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128821.132998"] = 200415, -- Claws of Ursoc (Sharpened Instincts)
	["128908.132998"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128403.132998"] = 208598, -- Apocalypse (Eternal Agony)
	["128943.132998"] = 211099, -- Skull of the Man'ari (Maw of Shadows)
	-- Preserved Highborne Warrior's Fist
	["127857.132999"] = 187287, -- Aluneth, Greatstaff of the Magna (Aegwynn's Fury)
	["128292.132999"] = 189097, -- Blades of the Fallen Prince (Over-Powered)
	["128306.132999"] = 189744, -- G'Hanir, the Mother Tree (Blessing of the World Tree)
	["128935.132999"] = 191598, -- The Fist of Ra-den (Earthen Attunement)
	["128862.132999"] = 195352, -- Ebonchill, Greatstaff of Alodi (The Storm Rages)
	["128937.132999"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128911.132999"] = 207348, -- Sharas'dal, Scepter of Tides (Floodwaters)
	["128860.132999"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	-- Stalwart Faronaar Keystone
	["128289.133000"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128402.133000"] = 192464, -- Maw of the Damned (All-Consuming Rot)
	["128870.133000"] = 192376, -- The Kingslayers (Poison Knives)
	["128819.133000"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128908.133000"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128872.133000"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.133000"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128940.133000"] = 195267, -- Fists of the Heavens (Strength of Xuen)
	["128861.133000"] = 206910, -- Titanstrike (Unleash the Beast)
	["128866.133000"] = 209216, -- Truthguard (Bastion of Truth)
	["128910.133000"] = 209494, -- Strom'kar, the Warbreaker (Exploit the Weakness)
	["128832.133000"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	["128938.133000"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Soul Fragment of a Faronaar Innocent
	["128306.133001"] = 189744, -- G'Hanir, the Mother Tree (Blessing of the World Tree)
	["128826.133001"] = 190567, -- Thas'dorah, Legacy of the Windrunners (Gust of Wind)
	["128825.133001"] = 196430, -- T'uure, Beacon of the Naaru (Words of Healing)
	["128937.133001"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128821.133001"] = 200415, -- Claws of Ursoc (Sharpened Instincts)
	["128858.133001"] = 202464, -- Scythe of Elune (Empowerment)
	["128911.133001"] = 207348, -- Sharas'dal, Scepter of Tides (Floodwaters)
	["128860.133001"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	["128823.133001"] = 200482, -- The Silver Hand (Second Sunrise)
	["128938.133001"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Coalesced Shadows
	["128292.133002"] = 189097, -- Blades of the Fallen Prince (Over-Powered)
	["128402.133002"] = 192464, -- Maw of the Damned (All-Consuming Rot)
	["128870.133002"] = 192376, -- The Kingslayers (Poison Knives)
	["128827.133002"] = 194002, -- Xal'atath, Blade of the Black Empire (Creeping Shadows)
	["128476.133002"] = 197239, -- Fangs of the Devourer (Energetic Stabbing)
	["128868.133002"] = 197762, -- Light's Wrath (Borrowed Time)
	["128942.133002"] = 199163, -- Ulthalesh, the Deadwind Harvester (Shadowy Incantations)
	["127829.133002"] = 201464, -- Twinblades of the Deceiver (Overwhelming Power)
	["128403.133002"] = 208598, -- Apocalypse (Eternal Agony)
	["128910.133002"] = 209494, -- Strom'kar, the Warbreaker (Exploit the Weakness)
	["128943.133002"] = 211099, -- Skull of the Man'ari (Maw of Shadows)
	-- Swirling Demonic Whispers
	["128935.133004"] = 191598, -- The Fist of Ra-den (Earthen Attunement)
	["128826.133004"] = 190567, -- Thas'dorah, Legacy of the Windrunners (Gust of Wind)
	["128819.133004"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128937.133004"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128908.133004"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128872.133004"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.133004"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128940.133004"] = 195267, -- Fists of the Heavens (Strength of Xuen)
	["128861.133004"] = 206910, -- Titanstrike (Unleash the Beast)
	["128938.133004"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Blessed Llothien Stone
	["120978.133006"] = 184759, -- Ashbringer (Sharpened Edge)
	["128825.133006"] = 196358, -- T'uure, Beacon of the Naaru (Say Your Prayers)
	["128868.133006"] = 197713, -- Light's Wrath (Pain is in Your Mind)
	["128823.133006"] = 200316, -- The Silver Hand (Justice through Sacrifice)
	["128866.133006"] = 209217, -- Truthguard (Stern Judgment)
	-- Everlasting Construct Core
	["127857.133007"] = 187258, -- Aluneth, Greatstaff of the Magna (Blasting Rod)
	["128820.133007"] = 194234, -- Felo'melorn (Reignition Overdrive)
	["128862.133007"] = 195317, -- Ebonchill, Greatstaff of Alodi (Ice Age)
	["128861.133007"] = 197047, -- Titanstrike (Furious Swipes)
	["128858.133007"] = 202386, -- Scythe of Elune (Twilight Glow)
	["128832.133007"] = 207347, -- The Aldrachi Warblades (Aura of Pain)
	["128866.133007"] = 209217, -- Truthguard (Stern Judgment)
	-- Azurewing Blood
	["128289.133008"] = 216272, -- Scale of the Earth-Warder (Rage of the Fallen)
	["128403.133008"] = 191442, -- Apocalypse (Rotten Touch)
	["128402.133008"] = 192453, -- Maw of the Damned (Meat Shield)
	["128826.133008"] = 190457, -- Thas'dorah, Legacy of the Windrunners (Windrunner's Guidance)
	["128870.133008"] = 192315, -- The Kingslayers (Serrated Edge)
	["128827.133008"] = 193643, -- Xal'atath, Blade of the Black Empire (Mind Shattering)
	["128942.133008"] = 199112, -- Ulthalesh, the Deadwind Harvester (Hideous Corruption)
	["128821.133008"] = 200399, -- Claws of Ursoc (Ursoc's Endurance)
	["128872.133008"] = 202507, -- The Dreadblades (Blade Dancer)
	["128808.133008"] = 203577, -- Talonclaw, Spear of the Wild Gods (My Beloved Monster)
	["128910.133008"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128860.133008"] = 210571, -- Fangs of Ashamane (Feral Power)
	-- Corrupted Ley-Crystal
	["128941.133009"] = 196217, -- Scepter of Sargeras (Chaotic Instability)
	["128476.133009"] = 197233, -- Fangs of the Devourer (Demon's Kiss)
	["127829.133009"] = 201455, -- Twinblades of the Deceiver (Critical Chaos)
	["128832.133009"] = 207347, -- The Aldrachi Warblades (Aura of Pain)
	["128943.133009"] = 211126, -- Skull of the Man'ari (Legionwrath)
	-- Azure Flame
	["120978.133010"] = 184759, -- Ashbringer (Sharpened Edge)
	["128289.133010"] = 216272, -- Scale of the Earth-Warder (Rage of the Fallen)
	["128403.133010"] = 191442, -- Apocalypse (Rotten Touch)
	["128820.133010"] = 194234, -- Felo'melorn (Reignition Overdrive)
	["128941.133010"] = 196217, -- Scepter of Sargeras (Chaotic Instability)
	["128819.133010"] = 198236, -- Doomhammer (Forged in Lava)
	["128821.133010"] = 200399, -- Claws of Ursoc (Ursoc's Endurance)
	["128908.133010"] = 216273, -- Warswords of the Valarjar (Wild Slashes)
	["128943.133010"] = 211126, -- Skull of the Man'ari (Legionwrath)
	-- Leyhollow Frost
	["127857.133011"] = 187258, -- Aluneth, Greatstaff of the Magna (Blasting Rod)
	["128292.133011"] = 189092, -- Blades of the Fallen Prince (Ambidexterity)
	["128306.133011"] = 189768, -- G'Hanir, the Mother Tree (Seeds of the World Tree)
	["128935.133011"] = 191499, -- The Fist of Ra-den (The Ground Trembles)
	["128862.133011"] = 195317, -- Ebonchill, Greatstaff of Alodi (Ice Age)
	["128937.133011"] = 199366, -- Sheilun, Staff of the Mists (Way of the Mistweaver)
	["128911.133011"] = 207092, -- Sharas'dal, Scepter of Tides (Buffeting Waves)
	["128860.133011"] = 210571, -- Fangs of Ashamane (Feral Power)
	-- Senegos' Resolve
	["128289.133012"] = 216272, -- Scale of the Earth-Warder (Rage of the Fallen)
	["128402.133012"] = 192453, -- Maw of the Damned (Meat Shield)
	["128870.133012"] = 192315, -- The Kingslayers (Serrated Edge)
	["128940.133012"] = 195263, -- Fists of the Heavens (Rising Winds)
	["128861.133012"] = 197047, -- Titanstrike (Furious Swipes)
	["128819.133012"] = 198236, -- Doomhammer (Forged in Lava)
	["128908.133012"] = 216273, -- Warswords of the Valarjar (Wild Slashes)
	["128872.133012"] = 202507, -- The Dreadblades (Blade Dancer)
	["128808.133012"] = 203577, -- Talonclaw, Spear of the Wild Gods (My Beloved Monster)
	["128832.133012"] = 207347, -- The Aldrachi Warblades (Aura of Pain)
	["128866.133012"] = 209217, -- Truthguard (Stern Judgment)
	["128910.133012"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128938.133012"] = 227687, -- Fu Zan, the Wanderer's Companion (Hot Blooded)
	-- Reinvigorating Crystal
	["128306.133013"] = 189768, -- G'Hanir, the Mother Tree (Seeds of the World Tree)
	["128826.133013"] = 190457, -- Thas'dorah, Legacy of the Windrunners (Windrunner's Guidance)
	["128825.133013"] = 196358, -- T'uure, Beacon of the Naaru (Say Your Prayers)
	["128937.133013"] = 199366, -- Sheilun, Staff of the Mists (Way of the Mistweaver)
	["128821.133013"] = 200399, -- Claws of Ursoc (Ursoc's Endurance)
	["128823.133013"] = 200316, -- The Silver Hand (Justice through Sacrifice)
	["128858.133013"] = 202386, -- Scythe of Elune (Twilight Glow)
	["128911.133013"] = 207092, -- Sharas'dal, Scepter of Tides (Buffeting Waves)
	["128860.133013"] = 210571, -- Fangs of Ashamane (Feral Power)
	["128938.133013"] = 227687, -- Fu Zan, the Wanderer's Companion (Hot Blooded)
	-- Senegos' Despair
	["128292.133014"] = 189092, -- Blades of the Fallen Prince (Ambidexterity)
	["128403.133014"] = 191442, -- Apocalypse (Rotten Touch)
	["128402.133014"] = 192453, -- Maw of the Damned (Meat Shield)
	["128870.133014"] = 192315, -- The Kingslayers (Serrated Edge)
	["128827.133014"] = 193643, -- Xal'atath, Blade of the Black Empire (Mind Shattering)
	["128476.133014"] = 197233, -- Fangs of the Devourer (Demon's Kiss)
	["128868.133014"] = 197713, -- Light's Wrath (Pain is in Your Mind)
	["128942.133014"] = 199112, -- Ulthalesh, the Deadwind Harvester (Hideous Corruption)
	["127829.133014"] = 201455, -- Twinblades of the Deceiver (Critical Chaos)
	["128910.133014"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128943.133014"] = 211126, -- Skull of the Man'ari (Legionwrath)
	-- Ley-Pool Essence
	-- Azurewing Guile
	["128935.133016"] = 191499, -- The Fist of Ra-den (The Ground Trembles)
	["128826.133016"] = 190457, -- Thas'dorah, Legacy of the Windrunners (Windrunner's Guidance)
	["128940.133016"] = 195263, -- Fists of the Heavens (Rising Winds)
	["128861.133016"] = 197047, -- Titanstrike (Furious Swipes)
	["128819.133016"] = 198236, -- Doomhammer (Forged in Lava)
	["128937.133016"] = 199366, -- Sheilun, Staff of the Mists (Way of the Mistweaver)
	["128908.133016"] = 216273, -- Warswords of the Valarjar (Wild Slashes)
	["128872.133016"] = 202507, -- The Dreadblades (Blade Dancer)
	["128808.133016"] = 203577, -- Talonclaw, Spear of the Wild Gods (My Beloved Monster)
	["128938.133016"] = 227687, -- Fu Zan, the Wanderer's Companion (Hot Blooded)
	-- Gale Wind of the Order
	["128935.142064"] = 191493, -- The Fist of Ra-den (Call the Thunder)
	["128826.142064"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128940.142064"] = 195243, -- Fists of the Heavens (Inner Peace)
	["128861.142064"] = 197038, -- Titanstrike (Wilderness Expert)
	["128819.142064"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128937.142064"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128908.142064"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128872.142064"] = 216230, -- The Dreadblades (Black Powder)
	["128808.142064"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128938.142064"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Dusk of the Order
	["128292.142063"] = 189080, -- Blades of the Fallen Prince (Cold as Ice)
	["128403.142063"] = 191419, -- Apocalypse (Deadliest Coil)
	["128402.142063"] = 192450, -- Maw of the Damned (Iron Heart)
	["128870.142063"] = 192310, -- The Kingslayers (Toxic Blades)
	["128827.142063"] = 194093, -- Xal'atath, Blade of the Black Empire (Unleash the Shadows)
	["128476.142063"] = 197231, -- Fangs of the Devourer (The Quiet Knife)
	["128868.142063"] = 197708, -- Light's Wrath (Confession)
	["128942.142063"] = 199111, -- Ulthalesh, the Deadwind Harvester (Inimitable Agony)
	["127829.142063"] = 201454, -- Twinblades of the Deceiver (Contained Fury)
	["128910.142063"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128943.142063"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Prosperity of the Order
	["128306.142062"] = 189772, -- G'Hanir, the Mother Tree (Knowledge of the Ancients)
	["128826.142062"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128825.142062"] = 196434, -- T'uure, Beacon of the Naaru (Holy Guidance)
	["128937.142062"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128821.142062"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128823.142062"] = 200326, -- The Silver Hand (Focused Healing)
	["128858.142062"] = 202384, -- Scythe of Elune (Dark Side of the Moon)
	["128911.142062"] = 207088, -- Sharas'dal, Scepter of Tides (Tidal Chains)
	["128860.142062"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	["128938.142062"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Azsuna Package 3 - Holy 1 - Unused
	["120978.133018"] = 186941, -- Ashbringer (Highlord's Judgment)
	["128825.133018"] = 196434, -- T'uure, Beacon of the Naaru (Holy Guidance)
	["128868.133018"] = 197708, -- Light's Wrath (Confession)
	["128823.133018"] = 200326, -- The Silver Hand (Focused Healing)
	["128866.133018"] = 209229, -- Truthguard (Hammer Time)
	-- Iron Will of the Order
	["128289.142061"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128402.142061"] = 192450, -- Maw of the Damned (Iron Heart)
	["128870.142061"] = 192310, -- The Kingslayers (Toxic Blades)
	["128940.142061"] = 195243, -- Fists of the Heavens (Inner Peace)
	["128861.142061"] = 197038, -- Titanstrike (Wilderness Expert)
	["128819.142061"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128908.142061"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128872.142061"] = 216230, -- The Dreadblades (Black Powder)
	["128808.142061"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128832.142061"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128866.142061"] = 209229, -- Truthguard (Hammer Time)
	["128910.142061"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128938.142061"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Icy Core of the Order
	["127857.142060"] = 187304, -- Aluneth, Greatstaff of the Magna (Torrential Barrage)
	["128292.142060"] = 189080, -- Blades of the Fallen Prince (Cold as Ice)
	["128306.142060"] = 189772, -- G'Hanir, the Mother Tree (Knowledge of the Ancients)
	["128935.142060"] = 191493, -- The Fist of Ra-den (Call the Thunder)
	["128862.142060"] = 195315, -- Ebonchill, Greatstaff of Alodi (Icy Caress)
	["128937.142060"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128911.142060"] = 207088, -- Sharas'dal, Scepter of Tides (Tidal Chains)
	["128860.142060"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	-- Flame of the Order
	["120978.142059"] = 186941, -- Ashbringer (Highlord's Judgment)
	["128289.142059"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128403.142059"] = 191419, -- Apocalypse (Deadliest Coil)
	["128820.142059"] = 194224, -- Felo'melorn (Fire at Will)
	["128941.142059"] = 196211, -- Scepter of Sargeras (Master of Disaster)
	["128819.142059"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128821.142059"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128908.142059"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128943.142059"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Fel Ward of the Order
	["128941.142058"] = 196211, -- Scepter of Sargeras (Master of Disaster)
	["128476.142058"] = 197231, -- Fangs of the Devourer (The Quiet Knife)
	["127829.142058"] = 201454, -- Twinblades of the Deceiver (Contained Fury)
	["128832.142058"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128943.142058"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Jewel of Nar'thalas
	["127857.133019"] = 187304, -- Aluneth, Greatstaff of the Magna (Torrential Barrage)
	["128820.133019"] = 194224, -- Felo'melorn (Fire at Will)
	["128862.133019"] = 195315, -- Ebonchill, Greatstaff of Alodi (Icy Caress)
	["128861.133019"] = 197038, -- Titanstrike (Wilderness Expert)
	["128858.133019"] = 202384, -- Scythe of Elune (Dark Side of the Moon)
	["128832.133019"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128866.133019"] = 209229, -- Truthguard (Hammer Time)
	-- Heartbeat of the Order
	["128289.142057"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128403.142057"] = 191419, -- Apocalypse (Deadliest Coil)
	["128402.142057"] = 192450, -- Maw of the Damned (Iron Heart)
	["128826.142057"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128870.142057"] = 192310, -- The Kingslayers (Toxic Blades)
	["128827.142057"] = 194093, -- Xal'atath, Blade of the Black Empire (Unleash the Shadows)
	["128942.142057"] = 199111, -- Ulthalesh, the Deadwind Harvester (Inimitable Agony)
	["128821.142057"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128872.142057"] = 216230, -- The Dreadblades (Black Powder)
	["128808.142057"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128910.142057"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128860.142057"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	-- Arcanum of the Order
	["127857.142056"] = 187304, -- Aluneth, Greatstaff of the Magna (Torrential Barrage)
	["128820.142056"] = 194224, -- Felo'melorn (Fire at Will)
	["128862.142056"] = 195315, -- Ebonchill, Greatstaff of Alodi (Icy Caress)
	["128861.142056"] = 197038, -- Titanstrike (Wilderness Expert)
	["128858.142056"] = 202384, -- Scythe of Elune (Dark Side of the Moon)
	["128832.142056"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128866.142056"] = 209229, -- Truthguard (Hammer Time)
	-- Light of the Order
	["120978.142055"] = 186941, -- Ashbringer (Highlord's Judgment)
	["128825.142055"] = 196434, -- T'uure, Beacon of the Naaru (Holy Guidance)
	["128868.142055"] = 197708, -- Light's Wrath (Confession)
	["128823.142055"] = 200326, -- The Silver Hand (Focused Healing)
	["128866.142055"] = 209229, -- Truthguard (Hammer Time)
	-- Blood of the Snake
	["128289.133020"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128403.133020"] = 191419, -- Apocalypse (Deadliest Coil)
	["128402.133020"] = 192450, -- Maw of the Damned (Iron Heart)
	["128826.133020"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128870.133020"] = 192310, -- The Kingslayers (Toxic Blades)
	["128827.133020"] = 194093, -- Xal'atath, Blade of the Black Empire (Unleash the Shadows)
	["128942.133020"] = 199111, -- Ulthalesh, the Deadwind Harvester (Inimitable Agony)
	["128821.133020"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128872.133020"] = 216230, -- The Dreadblades (Black Powder)
	["128808.133020"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128910.133020"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128860.133020"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	-- Intro to Fel Magic - Pocket Edition
	["128941.133021"] = 196211, -- Scepter of Sargeras (Master of Disaster)
	["128476.133021"] = 197231, -- Fangs of the Devourer (The Quiet Knife)
	["127829.133021"] = 201454, -- Twinblades of the Deceiver (Contained Fury)
	["128832.133021"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128943.133021"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Eternal Mage Flame
	["120978.133022"] = 186941, -- Ashbringer (Highlord's Judgment)
	["128289.133022"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128403.133022"] = 191419, -- Apocalypse (Deadliest Coil)
	["128820.133022"] = 194224, -- Felo'melorn (Fire at Will)
	["128941.133022"] = 196211, -- Scepter of Sargeras (Master of Disaster)
	["128819.133022"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128821.133022"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128908.133022"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128943.133022"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Depths Shard Ice Crystal
	["127857.133023"] = 187304, -- Aluneth, Greatstaff of the Magna (Torrential Barrage)
	["128292.133023"] = 189080, -- Blades of the Fallen Prince (Cold as Ice)
	["128306.133023"] = 189772, -- G'Hanir, the Mother Tree (Knowledge of the Ancients)
	["128935.133023"] = 191493, -- The Fist of Ra-den (Call the Thunder)
	["128862.133023"] = 195315, -- Ebonchill, Greatstaff of Alodi (Icy Caress)
	["128937.133023"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128911.133023"] = 207088, -- Sharas'dal, Scepter of Tides (Tidal Chains)
	["128860.133023"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	-- Oracle's Sharpening Stone
	["128289.133024"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128402.133024"] = 192450, -- Maw of the Damned (Iron Heart)
	["128870.133024"] = 192310, -- The Kingslayers (Toxic Blades)
	["128940.133024"] = 195243, -- Fists of the Heavens (Inner Peace)
	["128861.133024"] = 197038, -- Titanstrike (Wilderness Expert)
	["128819.133024"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128908.133024"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128872.133024"] = 216230, -- The Dreadblades (Black Powder)
	["128808.133024"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128832.133024"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128866.133024"] = 209229, -- Truthguard (Hammer Time)
	["128910.133024"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128938.133024"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Enchanted El'dranil Frond
	["128306.133025"] = 189772, -- G'Hanir, the Mother Tree (Knowledge of the Ancients)
	["128826.133025"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128825.133025"] = 196434, -- T'uure, Beacon of the Naaru (Holy Guidance)
	["128937.133025"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128821.133025"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128823.133025"] = 200326, -- The Silver Hand (Focused Healing)
	["128858.133025"] = 202384, -- Scythe of Elune (Dark Side of the Moon)
	["128911.133025"] = 207088, -- Sharas'dal, Scepter of Tides (Tidal Chains)
	["128860.133025"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	["128938.133025"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Cursed Dissection Blade
	["128292.133026"] = 189080, -- Blades of the Fallen Prince (Cold as Ice)
	["128403.133026"] = 191419, -- Apocalypse (Deadliest Coil)
	["128402.133026"] = 192450, -- Maw of the Damned (Iron Heart)
	["128870.133026"] = 192310, -- The Kingslayers (Toxic Blades)
	["128827.133026"] = 194093, -- Xal'atath, Blade of the Black Empire (Unleash the Shadows)
	["128476.133026"] = 197231, -- Fangs of the Devourer (The Quiet Knife)
	["128868.133026"] = 197708, -- Light's Wrath (Confession)
	["128942.133026"] = 199111, -- Ulthalesh, the Deadwind Harvester (Inimitable Agony)
	["127829.133026"] = 201454, -- Twinblades of the Deceiver (Contained Fury)
	["128910.133026"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128943.133026"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Petrified Starfish
	-- Gale of Azshara
	["128935.133028"] = 191493, -- The Fist of Ra-den (Call the Thunder)
	["128826.133028"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128940.133028"] = 195243, -- Fists of the Heavens (Inner Peace)
	["128861.133028"] = 197038, -- Titanstrike (Wilderness Expert)
	["128819.133028"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128937.133028"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128908.133028"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128872.133028"] = 216230, -- The Dreadblades (Black Powder)
	["128808.133028"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128938.133028"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Dathrohan's Signet
	["120978.133029"] = 186941, -- Ashbringer (Highlord's Judgment)
	["128825.133029"] = 196434, -- T'uure, Beacon of the Naaru (Holy Guidance)
	["128868.133029"] = 197708, -- Light's Wrath (Confession)
	["128823.133029"] = 200326, -- The Silver Hand (Focused Healing)
	["128866.133029"] = 209229, -- Truthguard (Hammer Time)
	-- 'Procured' Kirin Tor Wand Tip
	["127857.133030"] = 187313, -- Aluneth, Greatstaff of the Magna (Arcane Purification)
	["128820.133030"] = 194313, -- Felo'melorn (Great Balls of Fire)
	["128862.133030"] = 195345, -- Ebonchill, Greatstaff of Alodi (Frozen Veins)
	["128861.133030"] = 197140, -- Titanstrike (Spitting Cobras)
	["128858.133030"] = 202445, -- Scythe of Elune (Falling Star)
	["128866.133030"] = 209223, -- Truthguard (Scatter the Shadows)
	["128832.133030"] = 212816, -- The Aldrachi Warblades (Embrace the Pain)
	-- Rare White Tiger Heart
	["128289.133031"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128403.133031"] = 191488, -- Apocalypse (The Darkest Crusade)
	["128402.133031"] = 192544, -- Maw of the Damned (Vampiric Fangs)
	["128826.133031"] = 190529, -- Thas'dorah, Legacy of the Windrunners (Marked for Death)
	["128870.133031"] = 192349, -- The Kingslayers (Master Assassin)
	["128827.133031"] = 194016, -- Xal'atath, Blade of the Black Empire (Void Corruption)
	["128942.133031"] = 199158, -- Ulthalesh, the Deadwind Harvester (Perdition)
	["128821.133031"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128872.133031"] = 202530, -- The Dreadblades (Fortune Strikes)
	["128808.133031"] = 203670, -- Talonclaw, Spear of the Wild Gods (Explosive Force)
	["128910.133031"] = 209492, -- Strom'kar, the Warbreaker (Precise Strikes)
	["128860.133031"] = 210637, -- Fangs of Ashamane (Sharpened Claws)
	-- Fel-Fire Demon Claw
	["128941.133032"] = 196258, -- Scepter of Sargeras (Fire From the Sky)
	["128476.133032"] = 197239, -- Fangs of the Devourer (Energetic Stabbing)
	["127829.133032"] = 201464, -- Twinblades of the Deceiver (Overwhelming Power)
	["128943.133032"] = 211099, -- Skull of the Man'ari (Maw of Shadows)
	["128832.133032"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	-- Sorceror's Ember
	["120978.133033"] = 186934, -- Ashbringer (Embrace the Light)
	["128289.133033"] = 188632, -- Scale of the Earth-Warder (Toughness)
	["128403.133033"] = 191565, -- Apocalypse (Deadly Durability)
	["128820.133033"] = 194318, -- Felo'melorn (Cauterizing Blink)
	["128941.133033"] = 196301, -- Scepter of Sargeras (Devourer of Life)
	["128819.133033"] = 198296, -- Doomhammer (Spiritual Healing)
	["128821.133033"] = 200400, -- Claws of Ursoc (Wildflesh)
	["128908.133033"] = 200857, -- Warswords of the Valarjar (Battle Scars)
	["128943.133033"] = 211144, -- Skull of the Man'ari (Open Link)
	-- Were-Yeti Paw
	["127857.133034"] = 210716, -- Aluneth, Greatstaff of the Magna (Mana Shield)
	["128306.133034"] = 186320, -- G'Hanir, the Mother Tree (Grovewalker)
	["128935.133034"] = 191582, -- The Fist of Ra-den (Shamanistic Healing)
	["128862.133034"] = 214626, -- Ebonchill, Greatstaff of Alodi (Jouster)
	["128937.133034"] = 199384, -- Sheilun, Staff of the Mists (Spirit Tether)
	["128292.133034"] = 204875, -- Blades of the Fallen Prince (Frozen Skin)
	["128911.133034"] = 207354, -- Sharas'dal, Scepter of Tides (Caress of the Tidemother)
	["128860.133034"] = 210590, -- Fangs of Ashamane (Attuned to Nature)
	-- Myzrael Shard
	["128289.133035"] = 216272, -- Scale of the Earth-Warder (Rage of the Fallen)
	["128402.133035"] = 192453, -- Maw of the Damned (Meat Shield)
	["128870.133035"] = 192315, -- The Kingslayers (Serrated Edge)
	["128940.133035"] = 195263, -- Fists of the Heavens (Rising Winds)
	["128861.133035"] = 197047, -- Titanstrike (Furious Swipes)
	["128819.133035"] = 198236, -- Doomhammer (Forged in Lava)
	["128908.133035"] = 216273, -- Warswords of the Valarjar (Wild Slashes)
	["128872.133035"] = 202507, -- The Dreadblades (Blade Dancer)
	["128808.133035"] = 203577, -- Talonclaw, Spear of the Wild Gods (My Beloved Monster)
	["128832.133035"] = 207347, -- The Aldrachi Warblades (Aura of Pain)
	["128866.133035"] = 209217, -- Truthguard (Stern Judgment)
	["128910.133035"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128938.133035"] = 227687, -- Fu Zan, the Wanderer's Companion (Hot Blooded)
	-- Ravenous Seed
	["128306.133036"] = 189760, -- G'Hanir, the Mother Tree (Essence of Nordrassil)
	["128826.133036"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128825.133036"] = 196416, -- T'uure, Beacon of the Naaru (Serenity Now)
	["128937.133036"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128821.133036"] = 208762, -- Claws of Ursoc (Mauler)
	["128823.133036"] = 200315, -- The Silver Hand (Shock Treatment)
	["128858.133036"] = 202426, -- Scythe of Elune (Solar Stabbing)
	["128911.133036"] = 210029, -- Sharas'dal, Scepter of Tides (Pull of the Sea)
	["128860.133036"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	["128938.133036"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Zandalari Voodoo Totem
	["128292.133037"] = 189164, -- Blades of the Fallen Prince (Dead of Winter)
	["128403.133037"] = 224466, -- Apocalypse (Runic Tattoos)
	["128402.133037"] = 192457, -- Maw of the Damned (Veinrender)
	["128870.133037"] = 192326, -- The Kingslayers (Balanced Blades)
	["128827.133037"] = 193645, -- Xal'atath, Blade of the Black Empire (Death's Embrace)
	["128476.133037"] = 197235, -- Fangs of the Devourer (Precision Strike)
	["128868.133037"] = 197716, -- Light's Wrath (Burst of Light)
	["128942.133037"] = 199152, -- Ulthalesh, the Deadwind Harvester (Inherently Unstable)
	["127829.133037"] = 201457, -- Twinblades of the Deceiver (Sharpened Glaives)
	["128910.133037"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128943.133037"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	-- Breath of Al'Akir
	["128935.133039"] = 191572, -- The Fist of Ra-den (Molten Blast)
	["128826.133039"] = 190520, -- Thas'dorah, Legacy of the Windrunners (Precision)
	["128940.133039"] = 195269, -- Fists of the Heavens (Power of a Thousand Cranes)
	["128861.133039"] = 197140, -- Titanstrike (Spitting Cobras)
	["128819.133039"] = 198299, -- Doomhammer (Gathering Storms)
	["128937.133039"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128908.133039"] = 200856, -- Warswords of the Valarjar (Uncontrolled Rage)
	["128872.133039"] = 202524, -- The Dreadblades (Fatebringer)
	["128808.133039"] = 203669, -- Talonclaw, Spear of the Wild Gods (Fluffy, Go)
	["128938.133039"] = 213055, -- Fu Zan, the Wanderer's Companion (Staggering Around)
	-- Teardrop of Elune
	["120978.133040"] = 186934, -- Ashbringer (Embrace the Light)
	["128825.133040"] = 196489, -- T'uure, Beacon of the Naaru (Power of the Naaru)
	["128868.133040"] = 197711, -- Light's Wrath (Vestments of Discipline)
	["128823.133040"] = 200327, -- The Silver Hand (Share the Burden)
	["128866.133040"] = 209224, -- Truthguard (Resolve of Truth)
	-- Radiating Ley Crystal
	["127857.133041"] = 187301, -- Aluneth, Greatstaff of the Magna (Everywhere At Once)
	["128820.133041"] = 194318, -- Felo'melorn (Cauterizing Blink)
	["128862.133041"] = 195354, -- Ebonchill, Greatstaff of Alodi (Shield of Alodi)
	["128861.133041"] = 197160, -- Titanstrike (Mimiron's Shell)
	["128858.133041"] = 202302, -- Scythe of Elune (Bladed Feathers)
	["128866.133041"] = 209224, -- Truthguard (Resolve of Truth)
	["128832.133041"] = 212821, -- The Aldrachi Warblades (Devour Souls)
	-- Ley-Infused Blood
	["128289.133042"] = 188632, -- Scale of the Earth-Warder (Toughness)
	["128403.133042"] = 191565, -- Apocalypse (Deadly Durability)
	["128402.133042"] = 192514, -- Maw of the Damned (Dance of Darkness)
	["128826.133042"] = 190503, -- Thas'dorah, Legacy of the Windrunners (Healing Shell)
	["128870.133042"] = 192323, -- The Kingslayers (Fade into Shadows)
	["128827.133042"] = 193642, -- Xal'atath, Blade of the Black Empire (From the Shadows)
	["128942.133042"] = 199212, -- Ulthalesh, the Deadwind Harvester (Shadows of the Flesh)
	["128821.133042"] = 200400, -- Claws of Ursoc (Wildflesh)
	["128872.133042"] = 202521, -- The Dreadblades (Fortune's Strike)
	["128808.133042"] = 224764, -- Talonclaw, Spear of the Wild Gods (Bird of Prey)
	["128910.133042"] = 209483, -- Strom'kar, the Warbreaker (Tactical Advance)
	["128860.133042"] = 210557, -- Fangs of Ashamane (Honed Instincts)
	-- Fel-Touched Mana Gems
	["128941.133043"] = 196301, -- Scepter of Sargeras (Devourer of Life)
	["128476.133043"] = 210147, -- Fangs of the Devourer (Catlike Reflexes)
	["127829.133043"] = 201459, -- Twinblades of the Deceiver (Illidari Knowledge)
	["128943.133043"] = 211144, -- Skull of the Man'ari (Open Link)
	["128832.133043"] = 212821, -- The Aldrachi Warblades (Devour Souls)
	-- Stellagosa's Rage
	["120978.133044"] = 186934, -- Ashbringer (Embrace the Light)
	["128289.133044"] = 188632, -- Scale of the Earth-Warder (Toughness)
	["128403.133044"] = 191565, -- Apocalypse (Deadly Durability)
	["128820.133044"] = 194318, -- Felo'melorn (Cauterizing Blink)
	["128941.133044"] = 196301, -- Scepter of Sargeras (Devourer of Life)
	["128819.133044"] = 198296, -- Doomhammer (Spiritual Healing)
	["128821.133044"] = 200400, -- Claws of Ursoc (Wildflesh)
	["128908.133044"] = 200857, -- Warswords of the Valarjar (Battle Scars)
	["128943.133044"] = 211144, -- Skull of the Man'ari (Open Link)
	-- Senegos' Breath
	["127857.133045"] = 187321, -- Aluneth, Greatstaff of the Magna (Aegwynn's Wrath)
	["128292.133045"] = 189086, -- Blades of the Fallen Prince (Blast Radius)
	["128306.133045"] = 189760, -- G'Hanir, the Mother Tree (Essence of Nordrassil)
	["128935.133045"] = 191504, -- The Fist of Ra-den (Lava Imbued)
	["128862.133045"] = 195322, -- Ebonchill, Greatstaff of Alodi (Let It Go)
	["128937.133045"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128911.133045"] = 210029, -- Sharas'dal, Scepter of Tides (Pull of the Sea)
	["128860.133045"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	-- Fortified Ancient Dragonscale
	["128289.133046"] = 188632, -- Scale of the Earth-Warder (Toughness)
	["128402.133046"] = 192514, -- Maw of the Damned (Dance of Darkness)
	["128870.133046"] = 192323, -- The Kingslayers (Fade into Shadows)
	["128940.133046"] = 195244, -- Fists of the Heavens (Light on Your Feet)
	["128861.133046"] = 197160, -- Titanstrike (Mimiron's Shell)
	["128819.133046"] = 198296, -- Doomhammer (Spiritual Healing)
	["128908.133046"] = 200857, -- Warswords of the Valarjar (Battle Scars)
	["128872.133046"] = 202521, -- The Dreadblades (Fortune's Strike)
	["128808.133046"] = 224764, -- Talonclaw, Spear of the Wild Gods (Bird of Prey)
	["128866.133046"] = 209224, -- Truthguard (Resolve of Truth)
	["128910.133046"] = 209483, -- Strom'kar, the Warbreaker (Tactical Advance)
	["128832.133046"] = 212821, -- The Aldrachi Warblades (Devour Souls)
	["128938.133046"] = 213047, -- Fu Zan, the Wanderer's Companion (Potent Kick)
	-- Crystallized Whelp Egg
	["128306.133047"] = 186396, -- G'Hanir, the Mother Tree (Persistence)
	["128826.133047"] = 190503, -- Thas'dorah, Legacy of the Windrunners (Healing Shell)
	["128825.133047"] = 196489, -- T'uure, Beacon of the Naaru (Power of the Naaru)
	["128937.133047"] = 199365, -- Sheilun, Staff of the Mists (Shroud of Mist)
	["128821.133047"] = 200400, -- Claws of Ursoc (Wildflesh)
	["128823.133047"] = 200327, -- The Silver Hand (Share the Burden)
	["128858.133047"] = 202302, -- Scythe of Elune (Bladed Feathers)
	["128911.133047"] = 207351, -- Sharas'dal, Scepter of Tides (Ghost in the Mist)
	["128860.133047"] = 210557, -- Fangs of Ashamane (Honed Instincts)
	["128938.133047"] = 213047, -- Fu Zan, the Wanderer's Companion (Potent Kick)
	-- Wretched Draining Essence
	["128292.133048"] = 189154, -- Blades of the Fallen Prince (Ice in Your Veins)
	["128403.133048"] = 191565, -- Apocalypse (Deadly Durability)
	["128402.133048"] = 192514, -- Maw of the Damned (Dance of Darkness)
	["128870.133048"] = 192323, -- The Kingslayers (Fade into Shadows)
	["128827.133048"] = 193642, -- Xal'atath, Blade of the Black Empire (From the Shadows)
	["128476.133048"] = 210147, -- Fangs of the Devourer (Catlike Reflexes)
	["128868.133048"] = 197711, -- Light's Wrath (Vestments of Discipline)
	["128942.133048"] = 199212, -- Ulthalesh, the Deadwind Harvester (Shadows of the Flesh)
	["127829.133048"] = 201459, -- Twinblades of the Deceiver (Illidari Knowledge)
	["128910.133048"] = 209483, -- Strom'kar, the Warbreaker (Tactical Advance)
	["128943.133048"] = 211144, -- Skull of the Man'ari (Open Link)
	-- Crystalline Flow
	-- Gale of the Blues
	["128935.133050"] = 191569, -- The Fist of Ra-den (Protection of the Elements)
	["128826.133050"] = 190503, -- Thas'dorah, Legacy of the Windrunners (Healing Shell)
	["128940.133050"] = 195244, -- Fists of the Heavens (Light on Your Feet)
	["128861.133050"] = 197160, -- Titanstrike (Mimiron's Shell)
	["128819.133050"] = 198296, -- Doomhammer (Spiritual Healing)
	["128937.133050"] = 199365, -- Sheilun, Staff of the Mists (Shroud of Mist)
	["128908.133050"] = 200857, -- Warswords of the Valarjar (Battle Scars)
	["128872.133050"] = 202521, -- The Dreadblades (Fortune's Strike)
	["128808.133050"] = 224764, -- Talonclaw, Spear of the Wild Gods (Bird of Prey)
	["128938.133050"] = 213047, -- Fu Zan, the Wanderer's Companion (Potent Kick)
	-- Azsuna Package 3 - Holy 2 - Unused
	["120978.133051"] = 184843, -- Ashbringer (Righteous Blade)
	["128825.133051"] = 196416, -- T'uure, Beacon of the Naaru (Serenity Now)
	["128868.133051"] = 197715, -- Light's Wrath (The Edge of Dark and Light)
	["128823.133051"] = 200315, -- The Silver Hand (Shock Treatment)
	["128866.133051"] = 209220, -- Truthguard (Unflinching Defense)
	-- Instructor's Crystal Head
	["127857.133052"] = 187321, -- Aluneth, Greatstaff of the Magna (Aegwynn's Wrath)
	["128820.133052"] = 194312, -- Felo'melorn (Burning Gaze)
	["128862.133052"] = 195322, -- Ebonchill, Greatstaff of Alodi (Let It Go)
	["128861.133052"] = 197080, -- Titanstrike (Pack Leader)
	["128858.133052"] = 202426, -- Scythe of Elune (Solar Stabbing)
	["128832.133052"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128866.133052"] = 209220, -- Truthguard (Unflinching Defense)
	-- Crystallized Shard of Sciallax
	["127857.134076"] = 187313, -- Aluneth, Greatstaff of the Magna (Arcane Purification)
	["128292.134076"] = 189144, -- Blades of the Fallen Prince (Nothing but the Boots)
	["128306.134076"] = 189754, -- G'Hanir, the Mother Tree (Armor of the Ancients)
	["128935.134076"] = 191572, -- The Fist of Ra-den (Molten Blast)
	["128862.134076"] = 195345, -- Ebonchill, Greatstaff of Alodi (Frozen Veins)
	["128937.134076"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128911.134076"] = 207255, -- Sharas'dal, Scepter of Tides (Empowered Droplets)
	["128860.134076"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	-- Resilient Skrog Blood
	["128289.133053"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128403.133053"] = 191485, -- Apocalypse (Plaguebearer)
	["128402.133053"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128826.133053"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128870.133053"] = 192318, -- The Kingslayers (Master Alchemist)
	["128827.133053"] = 193644, -- Xal'atath, Blade of the Black Empire (To the Pain)
	["128942.133053"] = 199120, -- Ulthalesh, the Deadwind Harvester (Drained to a Husk)
	["128821.133053"] = 208762, -- Claws of Ursoc (Mauler)
	["128872.133053"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.133053"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128910.133053"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128860.133053"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	-- Glowing Shard of Sciallax
	["120978.134077"] = 186934, -- Ashbringer (Embrace the Light)
	["128289.134077"] = 188632, -- Scale of the Earth-Warder (Toughness)
	["128403.134077"] = 191565, -- Apocalypse (Deadly Durability)
	["128820.134077"] = 194318, -- Felo'melorn (Cauterizing Blink)
	["128941.134077"] = 196301, -- Scepter of Sargeras (Devourer of Life)
	["128819.134077"] = 198296, -- Doomhammer (Spiritual Healing)
	["128821.134077"] = 200400, -- Claws of Ursoc (Wildflesh)
	["128908.134077"] = 200857, -- Warswords of the Valarjar (Battle Scars)
	["128943.134077"] = 211144, -- Skull of the Man'ari (Open Link)
	-- Fel Flame Burner
	["128941.133054"] = 196222, -- Scepter of Sargeras (Fire and the Flames)
	["128476.133054"] = 197234, -- Fangs of the Devourer (Gutripper)
	["127829.133054"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128832.133054"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128943.133054"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Dark Shard of Sciallax
	["128292.134078"] = 189086, -- Blades of the Fallen Prince (Blast Radius)
	["128403.134078"] = 191485, -- Apocalypse (Plaguebearer)
	["128402.134078"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128870.134078"] = 192318, -- The Kingslayers (Master Alchemist)
	["128827.134078"] = 193644, -- Xal'atath, Blade of the Black Empire (To the Pain)
	["128476.134078"] = 197234, -- Fangs of the Devourer (Gutripper)
	["128868.134078"] = 197715, -- Light's Wrath (The Edge of Dark and Light)
	["128942.134078"] = 199120, -- Ulthalesh, the Deadwind Harvester (Drained to a Husk)
	["127829.134078"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128910.134078"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128943.134078"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Azshara's Ire
	["120978.133055"] = 184843, -- Ashbringer (Righteous Blade)
	["128289.133055"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128403.133055"] = 191485, -- Apocalypse (Plaguebearer)
	["128820.133055"] = 194312, -- Felo'melorn (Burning Gaze)
	["128941.133055"] = 196222, -- Scepter of Sargeras (Fire and the Flames)
	["128819.133055"] = 198247, -- Doomhammer (Wind Surge)
	["128821.133055"] = 208762, -- Claws of Ursoc (Mauler)
	["128908.133055"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128943.133055"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Ardent Shard of Sciallax
	["128306.134079"] = 186320, -- G'Hanir, the Mother Tree (Grovewalker)
	["128826.134079"] = 190514, -- Thas'dorah, Legacy of the Windrunners (Survival of the Fittest)
	["128825.134079"] = 196355, -- T'uure, Beacon of the Naaru (Trust in the Light)
	["128937.134079"] = 199384, -- Sheilun, Staff of the Mists (Spirit Tether)
	["128821.134079"] = 200440, -- Claws of Ursoc (Vicious Bites)
	["128823.134079"] = 200302, -- The Silver Hand (Knight of the Silver Hand)
	["128858.134079"] = 203018, -- Scythe of Elune (Touch of the Moon)
	["128911.134079"] = 207354, -- Sharas'dal, Scepter of Tides (Caress of the Tidemother)
	["128860.134079"] = 210590, -- Fangs of Ashamane (Attuned to Nature)
	["128938.134079"] = 213116, -- Fu Zan, the Wanderer's Companion (Face Palm)
	-- Azshara's Tempest
	["127857.133056"] = 187321, -- Aluneth, Greatstaff of the Magna (Aegwynn's Wrath)
	["128292.133056"] = 189086, -- Blades of the Fallen Prince (Blast Radius)
	["128306.133056"] = 189760, -- G'Hanir, the Mother Tree (Essence of Nordrassil)
	["128935.133056"] = 191504, -- The Fist of Ra-den (Lava Imbued)
	["128862.133056"] = 195322, -- Ebonchill, Greatstaff of Alodi (Let It Go)
	["128937.133056"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128911.133056"] = 210029, -- Sharas'dal, Scepter of Tides (Pull of the Sea)
	["128860.133056"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	-- Etched Talisman of Nar'thalas
	["128289.133057"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128402.133057"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128870.133057"] = 192318, -- The Kingslayers (Master Alchemist)
	["128940.133057"] = 218607, -- Fists of the Heavens (Tiger Claws)
	["128861.133057"] = 197080, -- Titanstrike (Pack Leader)
	["128819.133057"] = 198247, -- Doomhammer (Wind Surge)
	["128908.133057"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128872.133057"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.133057"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128832.133057"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128866.133057"] = 209220, -- Truthguard (Unflinching Defense)
	["128910.133057"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128938.133057"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Adamant Shard of Sciallax
	["128289.134081"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128402.134081"] = 192464, -- Maw of the Damned (All-Consuming Rot)
	["128870.134081"] = 192376, -- The Kingslayers (Poison Knives)
	["128819.134081"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128908.134081"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128872.134081"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.134081"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128940.134081"] = 195267, -- Fists of the Heavens (Strength of Xuen)
	["128861.134081"] = 206910, -- Titanstrike (Unleash the Beast)
	["128866.134081"] = 209216, -- Truthguard (Bastion of Truth)
	["128910.134081"] = 209494, -- Strom'kar, the Warbreaker (Exploit the Weakness)
	["128832.134081"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	["128938.134081"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Life-Giving Pearl
	["128306.133058"] = 189760, -- G'Hanir, the Mother Tree (Essence of Nordrassil)
	["128826.133058"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128825.133058"] = 196416, -- T'uure, Beacon of the Naaru (Serenity Now)
	["128937.133058"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128821.133058"] = 208762, -- Claws of Ursoc (Mauler)
	["128823.133058"] = 200315, -- The Silver Hand (Shock Treatment)
	["128858.133058"] = 202426, -- Scythe of Elune (Solar Stabbing)
	["128911.133058"] = 210029, -- Sharas'dal, Scepter of Tides (Pull of the Sea)
	["128860.133058"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	["128938.133058"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Corrupted Farondis House Insignia
	["128292.133059"] = 189086, -- Blades of the Fallen Prince (Blast Radius)
	["128403.133059"] = 191485, -- Apocalypse (Plaguebearer)
	["128402.133059"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128870.133059"] = 192318, -- The Kingslayers (Master Alchemist)
	["128827.133059"] = 193644, -- Xal'atath, Blade of the Black Empire (To the Pain)
	["128476.133059"] = 197234, -- Fangs of the Devourer (Gutripper)
	["128868.133059"] = 197715, -- Light's Wrath (The Edge of Dark and Light)
	["128942.133059"] = 199120, -- Ulthalesh, the Deadwind Harvester (Drained to a Husk)
	["127829.133059"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128910.133059"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128943.133059"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Neptulon Waters
	-- Heron's Grace
	["128935.133061"] = 191504, -- The Fist of Ra-den (Lava Imbued)
	["128826.133061"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128940.133061"] = 218607, -- Fists of the Heavens (Tiger Claws)
	["128861.133061"] = 197080, -- Titanstrike (Pack Leader)
	["128819.133061"] = 198247, -- Doomhammer (Wind Surge)
	["128937.133061"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128908.133061"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128872.133061"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.133061"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128938.133061"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Roar of the Ocean
	["127857.141257"] = 187258, -- Aluneth, Greatstaff of the Magna (Blasting Rod)
	["128292.141257"] = 189092, -- Blades of the Fallen Prince (Ambidexterity)
	["128306.141257"] = 189768, -- G'Hanir, the Mother Tree (Seeds of the World Tree)
	["128935.141257"] = 191499, -- The Fist of Ra-den (The Ground Trembles)
	["128862.141257"] = 195317, -- Ebonchill, Greatstaff of Alodi (Ice Age)
	["128937.141257"] = 199366, -- Sheilun, Staff of the Mists (Way of the Mistweaver)
	["128911.141257"] = 207092, -- Sharas'dal, Scepter of Tides (Buffeting Waves)
	["128860.141257"] = 210571, -- Fangs of Ashamane (Feral Power)
	-- Whirlpool Seed
	["128935.141258"] = 191598, -- The Fist of Ra-den (Earthen Attunement)
	["128826.141258"] = 190567, -- Thas'dorah, Legacy of the Windrunners (Gust of Wind)
	["128819.141258"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128937.141258"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128908.141258"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128872.141258"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.141258"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128940.141258"] = 195267, -- Fists of the Heavens (Strength of Xuen)
	["128861.141258"] = 206910, -- Titanstrike (Unleash the Beast)
	["128938.141258"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Shieldmaiden's Prayer
	["120978.141260"] = 186945, -- Ashbringer (Wrath of the Ashbringer)
	["128825.141260"] = 196418, -- T'uure, Beacon of the Naaru (Reverence)
	["128868.141260"] = 197716, -- Light's Wrath (Burst of Light)
	["128823.141260"] = 200296, -- The Silver Hand (Expel the Darkness)
	["128866.141260"] = 209226, -- Truthguard (Righteous Crusader)
	-- Empowered Lifespring Crystal
	["127857.133070"] = 187304, -- Aluneth, Greatstaff of the Magna (Torrential Barrage)
	["128820.133070"] = 194224, -- Felo'melorn (Fire at Will)
	["128862.133070"] = 195315, -- Ebonchill, Greatstaff of Alodi (Icy Caress)
	["128861.133070"] = 197038, -- Titanstrike (Wilderness Expert)
	["128858.133070"] = 202384, -- Scythe of Elune (Dark Side of the Moon)
	["128832.133070"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128866.133070"] = 209229, -- Truthguard (Hammer Time)
	-- Rivermanes' Sacrifice
	["128289.133071"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128403.133071"] = 191419, -- Apocalypse (Deadliest Coil)
	["128402.133071"] = 192450, -- Maw of the Damned (Iron Heart)
	["128826.133071"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128870.133071"] = 192310, -- The Kingslayers (Toxic Blades)
	["128827.133071"] = 194093, -- Xal'atath, Blade of the Black Empire (Unleash the Shadows)
	["128942.133071"] = 199111, -- Ulthalesh, the Deadwind Harvester (Inimitable Agony)
	["128821.133071"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128872.133071"] = 216230, -- The Dreadblades (Black Powder)
	["128808.133071"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128910.133071"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128860.133071"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	-- Dargrul's Arrogance
	["128941.133072"] = 196211, -- Scepter of Sargeras (Master of Disaster)
	["128476.133072"] = 197231, -- Fangs of the Devourer (The Quiet Knife)
	["127829.133072"] = 201454, -- Twinblades of the Deceiver (Contained Fury)
	["128832.133072"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128943.133072"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Jale's Fury
	["120978.133073"] = 186941, -- Ashbringer (Highlord's Judgment)
	["128289.133073"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128403.133073"] = 191419, -- Apocalypse (Deadliest Coil)
	["128820.133073"] = 194224, -- Felo'melorn (Fire at Will)
	["128941.133073"] = 196211, -- Scepter of Sargeras (Master of Disaster)
	["128819.133073"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128821.133073"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128908.133073"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128943.133073"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Snow of the Earthmother
	["127857.133074"] = 187304, -- Aluneth, Greatstaff of the Magna (Torrential Barrage)
	["128292.133074"] = 189080, -- Blades of the Fallen Prince (Cold as Ice)
	["128306.133074"] = 189772, -- G'Hanir, the Mother Tree (Knowledge of the Ancients)
	["128935.133074"] = 191493, -- The Fist of Ra-den (Call the Thunder)
	["128862.133074"] = 195315, -- Ebonchill, Greatstaff of Alodi (Icy Caress)
	["128937.133074"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128911.133074"] = 207088, -- Sharas'dal, Scepter of Tides (Tidal Chains)
	["128860.133074"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	-- Crageater Heart
	["128289.133075"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128402.133075"] = 192450, -- Maw of the Damned (Iron Heart)
	["128870.133075"] = 192310, -- The Kingslayers (Toxic Blades)
	["128940.133075"] = 195243, -- Fists of the Heavens (Inner Peace)
	["128861.133075"] = 197038, -- Titanstrike (Wilderness Expert)
	["128819.133075"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128908.133075"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128872.133075"] = 216230, -- The Dreadblades (Black Powder)
	["128808.133075"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128832.133075"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128866.133075"] = 209229, -- Truthguard (Hammer Time)
	["128910.133075"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128938.133075"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Lifespring Mushroom
	["128306.133076"] = 189772, -- G'Hanir, the Mother Tree (Knowledge of the Ancients)
	["128826.133076"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128825.133076"] = 196434, -- T'uure, Beacon of the Naaru (Holy Guidance)
	["128937.133076"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128821.133076"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128823.133076"] = 200326, -- The Silver Hand (Focused Healing)
	["128858.133076"] = 202384, -- Scythe of Elune (Dark Side of the Moon)
	["128911.133076"] = 207088, -- Sharas'dal, Scepter of Tides (Tidal Chains)
	["128860.133076"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	["128938.133076"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Vestiges of Gelmogg
	["128292.133077"] = 189080, -- Blades of the Fallen Prince (Cold as Ice)
	["128403.133077"] = 191419, -- Apocalypse (Deadliest Coil)
	["128402.133077"] = 192450, -- Maw of the Damned (Iron Heart)
	["128870.133077"] = 192310, -- The Kingslayers (Toxic Blades)
	["128827.133077"] = 194093, -- Xal'atath, Blade of the Black Empire (Unleash the Shadows)
	["128476.133077"] = 197231, -- Fangs of the Devourer (The Quiet Knife)
	["128868.133077"] = 197708, -- Light's Wrath (Confession)
	["128942.133077"] = 199111, -- Ulthalesh, the Deadwind Harvester (Inimitable Agony)
	["127829.133077"] = 201454, -- Twinblades of the Deceiver (Contained Fury)
	["128910.133077"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128943.133077"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Jale's Pride
	-- Jale's Relief
	["128935.133079"] = 191493, -- The Fist of Ra-den (Call the Thunder)
	["128826.133079"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128940.133079"] = 195243, -- Fists of the Heavens (Inner Peace)
	["128861.133079"] = 197038, -- Titanstrike (Wilderness Expert)
	["128819.133079"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128937.133079"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128908.133079"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128872.133079"] = 216230, -- The Dreadblades (Black Powder)
	["128808.133079"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128938.133079"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Hope of the Forest
	["120978.141271"] = 186927, -- Ashbringer (Deliver the Justice)
	["128825.141271"] = 196422, -- T'uure, Beacon of the Naaru (Holy Hands)
	["128868.141271"] = 197727, -- Light's Wrath (Doomsayer)
	["128823.141271"] = 200294, -- The Silver Hand (Deliver the Light)
	["128866.141271"] = 209223, -- Truthguard (Scatter the Shadows)
	-- Manathirster Focus
	["127857.133081"] = 187301, -- Aluneth, Greatstaff of the Magna (Everywhere At Once)
	["128820.133081"] = 194318, -- Felo'melorn (Cauterizing Blink)
	["128862.133081"] = 195354, -- Ebonchill, Greatstaff of Alodi (Shield of Alodi)
	["128861.133081"] = 197160, -- Titanstrike (Mimiron's Shell)
	["128858.133081"] = 202302, -- Scythe of Elune (Bladed Feathers)
	["128866.133081"] = 209224, -- Truthguard (Resolve of Truth)
	["128832.133081"] = 212821, -- The Aldrachi Warblades (Devour Souls)
	-- Gelmogg's Petrified Heart
	["128289.133082"] = 188632, -- Scale of the Earth-Warder (Toughness)
	["128403.133082"] = 191565, -- Apocalypse (Deadly Durability)
	["128402.133082"] = 192514, -- Maw of the Damned (Dance of Darkness)
	["128826.133082"] = 190503, -- Thas'dorah, Legacy of the Windrunners (Healing Shell)
	["128870.133082"] = 192323, -- The Kingslayers (Fade into Shadows)
	["128827.133082"] = 193642, -- Xal'atath, Blade of the Black Empire (From the Shadows)
	["128942.133082"] = 199212, -- Ulthalesh, the Deadwind Harvester (Shadows of the Flesh)
	["128821.133082"] = 200400, -- Claws of Ursoc (Wildflesh)
	["128872.133082"] = 202521, -- The Dreadblades (Fortune's Strike)
	["128808.133082"] = 224764, -- Talonclaw, Spear of the Wild Gods (Bird of Prey)
	["128910.133082"] = 209483, -- Strom'kar, the Warbreaker (Tactical Advance)
	["128860.133082"] = 210557, -- Fangs of Ashamane (Honed Instincts)
	-- Fel-Touched Riverstone
	["128941.133083"] = 196301, -- Scepter of Sargeras (Devourer of Life)
	["128476.133083"] = 210147, -- Fangs of the Devourer (Catlike Reflexes)
	["127829.133083"] = 201459, -- Twinblades of the Deceiver (Illidari Knowledge)
	["128943.133083"] = 211144, -- Skull of the Man'ari (Open Link)
	["128832.133083"] = 212821, -- The Aldrachi Warblades (Devour Souls)
	-- Drogbar Kindling
	["120978.133084"] = 186934, -- Ashbringer (Embrace the Light)
	["128289.133084"] = 188632, -- Scale of the Earth-Warder (Toughness)
	["128403.133084"] = 191565, -- Apocalypse (Deadly Durability)
	["128820.133084"] = 194318, -- Felo'melorn (Cauterizing Blink)
	["128941.133084"] = 196301, -- Scepter of Sargeras (Devourer of Life)
	["128819.133084"] = 198296, -- Doomhammer (Spiritual Healing)
	["128821.133084"] = 200400, -- Claws of Ursoc (Wildflesh)
	["128908.133084"] = 200857, -- Warswords of the Valarjar (Battle Scars)
	["128943.133084"] = 211144, -- Skull of the Man'ari (Open Link)
	-- Whitewater Lake Ice
	["127857.133085"] = 187301, -- Aluneth, Greatstaff of the Magna (Everywhere At Once)
	["128292.133085"] = 189154, -- Blades of the Fallen Prince (Ice in Your Veins)
	["128306.133085"] = 186396, -- G'Hanir, the Mother Tree (Persistence)
	["128935.133085"] = 191569, -- The Fist of Ra-den (Protection of the Elements)
	["128862.133085"] = 195354, -- Ebonchill, Greatstaff of Alodi (Shield of Alodi)
	["128937.133085"] = 199365, -- Sheilun, Staff of the Mists (Shroud of Mist)
	["128911.133085"] = 207351, -- Sharas'dal, Scepter of Tides (Ghost in the Mist)
	["128860.133085"] = 210557, -- Fangs of Ashamane (Honed Instincts)
	-- Gelmogg's Fractured Skull
	["128289.133086"] = 188632, -- Scale of the Earth-Warder (Toughness)
	["128402.133086"] = 192514, -- Maw of the Damned (Dance of Darkness)
	["128870.133086"] = 192323, -- The Kingslayers (Fade into Shadows)
	["128940.133086"] = 195244, -- Fists of the Heavens (Light on Your Feet)
	["128861.133086"] = 197160, -- Titanstrike (Mimiron's Shell)
	["128819.133086"] = 198296, -- Doomhammer (Spiritual Healing)
	["128908.133086"] = 200857, -- Warswords of the Valarjar (Battle Scars)
	["128872.133086"] = 202521, -- The Dreadblades (Fortune's Strike)
	["128808.133086"] = 224764, -- Talonclaw, Spear of the Wild Gods (Bird of Prey)
	["128866.133086"] = 209224, -- Truthguard (Resolve of Truth)
	["128910.133086"] = 209483, -- Strom'kar, the Warbreaker (Tactical Advance)
	["128832.133086"] = 212821, -- The Aldrachi Warblades (Devour Souls)
	["128938.133086"] = 213047, -- Fu Zan, the Wanderer's Companion (Potent Kick)
	-- Whitewater Carp Eggs
	["128306.133087"] = 186396, -- G'Hanir, the Mother Tree (Persistence)
	["128826.133087"] = 190503, -- Thas'dorah, Legacy of the Windrunners (Healing Shell)
	["128825.133087"] = 196489, -- T'uure, Beacon of the Naaru (Power of the Naaru)
	["128937.133087"] = 199365, -- Sheilun, Staff of the Mists (Shroud of Mist)
	["128821.133087"] = 200400, -- Claws of Ursoc (Wildflesh)
	["128823.133087"] = 200327, -- The Silver Hand (Share the Burden)
	["128858.133087"] = 202302, -- Scythe of Elune (Bladed Feathers)
	["128911.133087"] = 207351, -- Sharas'dal, Scepter of Tides (Ghost in the Mist)
	["128860.133087"] = 210557, -- Fangs of Ashamane (Honed Instincts)
	["128938.133087"] = 213047, -- Fu Zan, the Wanderer's Companion (Potent Kick)
	-- Creel's Sorrow
	["128292.133088"] = 189154, -- Blades of the Fallen Prince (Ice in Your Veins)
	["128403.133088"] = 191565, -- Apocalypse (Deadly Durability)
	["128402.133088"] = 192514, -- Maw of the Damned (Dance of Darkness)
	["128870.133088"] = 192323, -- The Kingslayers (Fade into Shadows)
	["128827.133088"] = 193642, -- Xal'atath, Blade of the Black Empire (From the Shadows)
	["128476.133088"] = 210147, -- Fangs of the Devourer (Catlike Reflexes)
	["128868.133088"] = 197711, -- Light's Wrath (Vestments of Discipline)
	["128942.133088"] = 199212, -- Ulthalesh, the Deadwind Harvester (Shadows of the Flesh)
	["127829.133088"] = 201459, -- Twinblades of the Deceiver (Illidari Knowledge)
	["128910.133088"] = 209483, -- Strom'kar, the Warbreaker (Tactical Advance)
	["128943.133088"] = 211144, -- Skull of the Man'ari (Open Link)
	-- Whitewater Froth
	-- Whitewater Breeze
	["128935.133090"] = 191569, -- The Fist of Ra-den (Protection of the Elements)
	["128826.133090"] = 190503, -- Thas'dorah, Legacy of the Windrunners (Healing Shell)
	["128940.133090"] = 195244, -- Fists of the Heavens (Light on Your Feet)
	["128861.133090"] = 197160, -- Titanstrike (Mimiron's Shell)
	["128819.133090"] = 198296, -- Doomhammer (Spiritual Healing)
	["128937.133090"] = 199365, -- Sheilun, Staff of the Mists (Shroud of Mist)
	["128908.133090"] = 200857, -- Warswords of the Valarjar (Battle Scars)
	["128872.133090"] = 202521, -- The Dreadblades (Fortune's Strike)
	["128808.133090"] = 224764, -- Talonclaw, Spear of the Wild Gods (Bird of Prey)
	["128938.133090"] = 213047, -- Fu Zan, the Wanderer's Companion (Potent Kick)
	-- Netherwhisper Arcanum
	["128292.141282"] = 189086, -- Blades of the Fallen Prince (Blast Radius)
	["128403.141282"] = 191485, -- Apocalypse (Plaguebearer)
	["128402.141282"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128870.141282"] = 192318, -- The Kingslayers (Master Alchemist)
	["128827.141282"] = 193644, -- Xal'atath, Blade of the Black Empire (To the Pain)
	["128476.141282"] = 197234, -- Fangs of the Devourer (Gutripper)
	["128868.141282"] = 197715, -- Light's Wrath (The Edge of Dark and Light)
	["128942.141282"] = 199120, -- Ulthalesh, the Deadwind Harvester (Drained to a Husk)
	["127829.141282"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128910.141282"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128943.141282"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Honor of the Skyhorn
	["120978.133092"] = 186927, -- Ashbringer (Deliver the Justice)
	["128825.133092"] = 196422, -- T'uure, Beacon of the Naaru (Holy Hands)
	["128868.133092"] = 197727, -- Light's Wrath (Doomsayer)
	["128823.133092"] = 200294, -- The Silver Hand (Deliver the Light)
	["128866.133092"] = 209223, -- Truthguard (Scatter the Shadows)
	-- Crawliac Charming Draught
	["127857.133093"] = 187313, -- Aluneth, Greatstaff of the Magna (Arcane Purification)
	["128820.133093"] = 194313, -- Felo'melorn (Great Balls of Fire)
	["128862.133093"] = 195345, -- Ebonchill, Greatstaff of Alodi (Frozen Veins)
	["128861.133093"] = 197140, -- Titanstrike (Spitting Cobras)
	["128858.133093"] = 202445, -- Scythe of Elune (Falling Star)
	["128866.133093"] = 209223, -- Truthguard (Scatter the Shadows)
	["128832.133093"] = 212816, -- The Aldrachi Warblades (Embrace the Pain)
	-- Heart of the Witchqueen
	["128289.133094"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128403.133094"] = 191494, -- Apocalypse (Scourge the Unbeliever)
	["128402.133094"] = 192460, -- Maw of the Damned (Coagulopathy)
	["128826.133094"] = 190520, -- Thas'dorah, Legacy of the Windrunners (Precision)
	["128870.133094"] = 192329, -- The Kingslayers (Gushing Wound)
	["128827.133094"] = 194007, -- Xal'atath, Blade of the Black Empire (Touch of Darkness)
	["128942.133094"] = 199153, -- Ulthalesh, the Deadwind Harvester (Seeds of Doom)
	["128821.133094"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128872.133094"] = 202524, -- The Dreadblades (Fatebringer)
	["128808.133094"] = 203669, -- Talonclaw, Spear of the Wild Gods (Fluffy, Go)
	["128910.133094"] = 209481, -- Strom'kar, the Warbreaker (Deathblow)
	["128860.133094"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	-- Crawliac Death Scream
	["128941.133095"] = 196236, -- Scepter of Sargeras (Soulsnatcher)
	["128476.133095"] = 197369, -- Fangs of the Devourer (Fortune's Bite)
	["127829.133095"] = 201458, -- Twinblades of the Deceiver (Demon Rage)
	["128943.133095"] = 211105, -- Skull of the Man'ari (Dirty Hands)
	["128832.133095"] = 212816, -- The Aldrachi Warblades (Embrace the Pain)
	-- Scorched Skyhorn Shawl
	["120978.133096"] = 186927, -- Ashbringer (Deliver the Justice)
	["128289.133096"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128403.133096"] = 191494, -- Apocalypse (Scourge the Unbeliever)
	["128820.133096"] = 194313, -- Felo'melorn (Great Balls of Fire)
	["128941.133096"] = 196236, -- Scepter of Sargeras (Soulsnatcher)
	["128819.133096"] = 198299, -- Doomhammer (Gathering Storms)
	["128821.133096"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128908.133096"] = 200856, -- Warswords of the Valarjar (Uncontrolled Rage)
	["128943.133096"] = 211105, -- Skull of the Man'ari (Dirty Hands)
	-- Haglands Ice Shard
	["127857.133097"] = 187313, -- Aluneth, Greatstaff of the Magna (Arcane Purification)
	["128292.133097"] = 189144, -- Blades of the Fallen Prince (Nothing but the Boots)
	["128306.133097"] = 189754, -- G'Hanir, the Mother Tree (Armor of the Ancients)
	["128935.133097"] = 191572, -- The Fist of Ra-den (Molten Blast)
	["128862.133097"] = 195345, -- Ebonchill, Greatstaff of Alodi (Frozen Veins)
	["128937.133097"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128911.133097"] = 207255, -- Sharas'dal, Scepter of Tides (Empowered Droplets)
	["128860.133097"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	-- Rockcrawler Jaw
	["128289.133098"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128402.133098"] = 192460, -- Maw of the Damned (Coagulopathy)
	["128870.133098"] = 192329, -- The Kingslayers (Gushing Wound)
	["128940.133098"] = 195269, -- Fists of the Heavens (Power of a Thousand Cranes)
	["128861.133098"] = 197140, -- Titanstrike (Spitting Cobras)
	["128819.133098"] = 198299, -- Doomhammer (Gathering Storms)
	["128908.133098"] = 200856, -- Warswords of the Valarjar (Uncontrolled Rage)
	["128872.133098"] = 202524, -- The Dreadblades (Fatebringer)
	["128808.133098"] = 203669, -- Talonclaw, Spear of the Wild Gods (Fluffy, Go)
	["128866.133098"] = 209223, -- Truthguard (Scatter the Shadows)
	["128910.133098"] = 209481, -- Strom'kar, the Warbreaker (Deathblow)
	["128832.133098"] = 212816, -- The Aldrachi Warblades (Embrace the Pain)
	["128938.133098"] = 213055, -- Fu Zan, the Wanderer's Companion (Staggering Around)
	-- Darkfeather Seedling
	["128306.133099"] = 189754, -- G'Hanir, the Mother Tree (Armor of the Ancients)
	["128826.133099"] = 190520, -- Thas'dorah, Legacy of the Windrunners (Precision)
	["128825.133099"] = 196422, -- T'uure, Beacon of the Naaru (Holy Hands)
	["128937.133099"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128821.133099"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128823.133099"] = 200294, -- The Silver Hand (Deliver the Light)
	["128858.133099"] = 202445, -- Scythe of Elune (Falling Star)
	["128911.133099"] = 207255, -- Sharas'dal, Scepter of Tides (Empowered Droplets)
	["128860.133099"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	["128938.133099"] = 213055, -- Fu Zan, the Wanderer's Companion (Staggering Around)
	-- Crawliac Hexrune
	["128292.133100"] = 189144, -- Blades of the Fallen Prince (Nothing but the Boots)
	["128403.133100"] = 191494, -- Apocalypse (Scourge the Unbeliever)
	["128402.133100"] = 192460, -- Maw of the Damned (Coagulopathy)
	["128870.133100"] = 192329, -- The Kingslayers (Gushing Wound)
	["128827.133100"] = 194007, -- Xal'atath, Blade of the Black Empire (Touch of Darkness)
	["128476.133100"] = 197369, -- Fangs of the Devourer (Fortune's Bite)
	["128868.133100"] = 197727, -- Light's Wrath (Doomsayer)
	["128942.133100"] = 199153, -- Ulthalesh, the Deadwind Harvester (Seeds of Doom)
	["127829.133100"] = 201458, -- Twinblades of the Deceiver (Demon Rage)
	["128910.133100"] = 209481, -- Strom'kar, the Warbreaker (Deathblow)
	["128943.133100"] = 211105, -- Skull of the Man'ari (Dirty Hands)
	-- Haglands Snowmelt
	-- Julan's Suppressing Wind
	["128935.133102"] = 191572, -- The Fist of Ra-den (Molten Blast)
	["128826.133102"] = 190520, -- Thas'dorah, Legacy of the Windrunners (Precision)
	["128940.133102"] = 195269, -- Fists of the Heavens (Power of a Thousand Cranes)
	["128861.133102"] = 197140, -- Titanstrike (Spitting Cobras)
	["128819.133102"] = 198299, -- Doomhammer (Gathering Storms)
	["128937.133102"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128908.133102"] = 200856, -- Warswords of the Valarjar (Uncontrolled Rage)
	["128872.133102"] = 202524, -- The Dreadblades (Fatebringer)
	["128808.133102"] = 203669, -- Talonclaw, Spear of the Wild Gods (Fluffy, Go)
	["128938.133102"] = 213055, -- Fu Zan, the Wanderer's Companion (Staggering Around)
	-- Lasan's Hope
	["120978.133103"] = 185368, -- Ashbringer (Might of the Templar)
	["128825.133103"] = 196429, -- T'uure, Beacon of the Naaru (Hallowed Ground)
	["128868.133103"] = 197729, -- Light's Wrath (Shield of Faith)
	["128823.133103"] = 200298, -- The Silver Hand (Blessings of the Silver Hand)
	["128866.133103"] = 209218, -- Truthguard (Consecration in Flame)
	-- Errant Mana
	["127857.133104"] = 187276, -- Aluneth, Greatstaff of the Magna (Ethereal Sensitivity)
	["128820.133104"] = 194314, -- Felo'melorn (Everburning Consumption)
	["128862.133104"] = 195351, -- Ebonchill, Greatstaff of Alodi (Clarity of Thought)
	["128861.133104"] = 197162, -- Titanstrike (Jaws of Thunder)
	["128858.133104"] = 202466, -- Scythe of Elune (Sunfire Burns)
	["128866.133104"] = 209218, -- Truthguard (Consecration in Flame)
	["128832.133104"] = 212817, -- The Aldrachi Warblades (Fiery Demise)
	-- Skyhorn Survivalist's Blood
	["128289.133105"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128403.133105"] = 191488, -- Apocalypse (The Darkest Crusade)
	["128402.133105"] = 192544, -- Maw of the Damned (Vampiric Fangs)
	["128826.133105"] = 190529, -- Thas'dorah, Legacy of the Windrunners (Marked for Death)
	["128870.133105"] = 192349, -- The Kingslayers (Master Assassin)
	["128827.133105"] = 194016, -- Xal'atath, Blade of the Black Empire (Void Corruption)
	["128942.133105"] = 199158, -- Ulthalesh, the Deadwind Harvester (Perdition)
	["128821.133105"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128872.133105"] = 202530, -- The Dreadblades (Fortune Strikes)
	["128808.133105"] = 203670, -- Talonclaw, Spear of the Wild Gods (Explosive Force)
	["128910.133105"] = 209492, -- Strom'kar, the Warbreaker (Precise Strikes)
	["128860.133105"] = 210637, -- Fangs of Ashamane (Sharpened Claws)
	-- Shaladrassil's Blossom
	["128306.139249"] = 189749, -- G'Hanir, the Mother Tree (Natural Mending)
	["128826.139249"] = 190529, -- Thas'dorah, Legacy of the Windrunners (Marked for Death)
	["128825.139249"] = 196429, -- T'uure, Beacon of the Naaru (Hallowed Ground)
	["128937.139249"] = 199380, -- Sheilun, Staff of the Mists (Infusion of Life)
	["128821.139249"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128823.139249"] = 200298, -- The Silver Hand (Blessings of the Silver Hand)
	["128858.139249"] = 202466, -- Scythe of Elune (Sunfire Burns)
	["128911.139249"] = 207285, -- Sharas'dal, Scepter of Tides (Queen Ascendant)
	["128860.139249"] = 210637, -- Fangs of Ashamane (Sharpened Claws)
	["128938.139249"] = 213133, -- Fu Zan, the Wanderer's Companion (Healthy Appetite)
	-- Fleshrender Roc Essence
	["128941.133106"] = 196432, -- Scepter of Sargeras (Burning Hunger)
	["128476.133106"] = 197386, -- Fangs of the Devourer (Soul Shadows)
	["127829.133106"] = 201460, -- Twinblades of the Deceiver (Unleashed Demons)
	["128943.133106"] = 211119, -- Skull of the Man'ari (Infernal Furnace)
	["128832.133106"] = 212817, -- The Aldrachi Warblades (Fiery Demise)
	-- Nightmare Engulfed Jewel
	["128292.138226"] = 189164, -- Blades of the Fallen Prince (Dead of Winter)
	["128403.138226"] = 224466, -- Apocalypse (Runic Tattoos)
	["128402.138226"] = 192457, -- Maw of the Damned (Veinrender)
	["128870.138226"] = 192326, -- The Kingslayers (Balanced Blades)
	["128827.138226"] = 193645, -- Xal'atath, Blade of the Black Empire (Death's Embrace)
	["128476.138226"] = 197235, -- Fangs of the Devourer (Precision Strike)
	["128868.138226"] = 197716, -- Light's Wrath (Burst of Light)
	["128942.138226"] = 199152, -- Ulthalesh, the Deadwind Harvester (Inherently Unstable)
	["127829.138226"] = 201457, -- Twinblades of the Deceiver (Sharpened Glaives)
	["128910.138226"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128943.138226"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	-- Unwaking Slumber
	["127857.139250"] = 187313, -- Aluneth, Greatstaff of the Magna (Arcane Purification)
	["128292.139250"] = 189144, -- Blades of the Fallen Prince (Nothing but the Boots)
	["128306.139250"] = 189754, -- G'Hanir, the Mother Tree (Armor of the Ancients)
	["128935.139250"] = 191572, -- The Fist of Ra-den (Molten Blast)
	["128862.139250"] = 195345, -- Ebonchill, Greatstaff of Alodi (Frozen Veins)
	["128937.139250"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128911.139250"] = 207255, -- Sharas'dal, Scepter of Tides (Empowered Droplets)
	["128860.139250"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	-- Cinderwitch Flame-Song
	["120978.133107"] = 185368, -- Ashbringer (Might of the Templar)
	["128289.133107"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128403.133107"] = 191488, -- Apocalypse (The Darkest Crusade)
	["128820.133107"] = 194314, -- Felo'melorn (Everburning Consumption)
	["128941.133107"] = 196432, -- Scepter of Sargeras (Burning Hunger)
	["128819.133107"] = 198349, -- Doomhammer (Gathering of the Maelstrom)
	["128821.133107"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128908.133107"] = 200860, -- Warswords of the Valarjar (Unrivaled Strength)
	["128943.133107"] = 211119, -- Skull of the Man'ari (Infernal Furnace)
	-- Entrancing Stone
	["127857.138227"] = 187258, -- Aluneth, Greatstaff of the Magna (Blasting Rod)
	["128820.138227"] = 194234, -- Felo'melorn (Reignition Overdrive)
	["128862.138227"] = 195317, -- Ebonchill, Greatstaff of Alodi (Ice Age)
	["128861.138227"] = 197047, -- Titanstrike (Furious Swipes)
	["128858.138227"] = 202386, -- Scythe of Elune (Twilight Glow)
	["128832.138227"] = 207347, -- The Aldrachi Warblades (Aura of Pain)
	["128866.138227"] = 209217, -- Truthguard (Stern Judgment)
	-- Despoiled Dragonscale
	["128292.139251"] = 189092, -- Blades of the Fallen Prince (Ambidexterity)
	["128403.139251"] = 191442, -- Apocalypse (Rotten Touch)
	["128402.139251"] = 192453, -- Maw of the Damned (Meat Shield)
	["128870.139251"] = 192315, -- The Kingslayers (Serrated Edge)
	["128827.139251"] = 193643, -- Xal'atath, Blade of the Black Empire (Mind Shattering)
	["128476.139251"] = 197233, -- Fangs of the Devourer (Demon's Kiss)
	["128868.139251"] = 197713, -- Light's Wrath (Pain is in Your Mind)
	["128942.139251"] = 199112, -- Ulthalesh, the Deadwind Harvester (Hideous Corruption)
	["127829.139251"] = 201455, -- Twinblades of the Deceiver (Critical Chaos)
	["128910.139251"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128943.139251"] = 211126, -- Skull of the Man'ari (Legionwrath)
	-- Frosted Great Eagle Egg
	["127857.133108"] = 187276, -- Aluneth, Greatstaff of the Magna (Ethereal Sensitivity)
	["128292.133108"] = 189147, -- Blades of the Fallen Prince (Bad to the Bone)
	["128306.133108"] = 189749, -- G'Hanir, the Mother Tree (Natural Mending)
	["128935.133108"] = 191577, -- The Fist of Ra-den (Electric Discharge)
	["128862.133108"] = 195351, -- Ebonchill, Greatstaff of Alodi (Clarity of Thought)
	["128937.133108"] = 199380, -- Sheilun, Staff of the Mists (Infusion of Life)
	["128911.133108"] = 207285, -- Sharas'dal, Scepter of Tides (Queen Ascendant)
	["128860.133108"] = 210637, -- Fangs of Ashamane (Sharpened Claws)
	-- Bioluminescent Mushroom
	["128306.138228"] = 189772, -- G'Hanir, the Mother Tree (Knowledge of the Ancients)
	["128826.138228"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128825.138228"] = 196434, -- T'uure, Beacon of the Naaru (Holy Guidance)
	["128937.138228"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128821.138228"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128823.138228"] = 200326, -- The Silver Hand (Focused Healing)
	["128858.138228"] = 202384, -- Scythe of Elune (Dark Side of the Moon)
	["128911.138228"] = 207088, -- Sharas'dal, Scepter of Tides (Tidal Chains)
	["128860.138228"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	["128938.138228"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Preserved Worldseed
	["120978.139252"] = 184843, -- Ashbringer (Righteous Blade)
	["128825.139252"] = 196416, -- T'uure, Beacon of the Naaru (Serenity Now)
	["128868.139252"] = 197715, -- Light's Wrath (The Edge of Dark and Light)
	["128823.139252"] = 200315, -- The Silver Hand (Shock Treatment)
	["128866.139252"] = 209220, -- Truthguard (Unflinching Defense)
	-- Lasan's Determination
	["128289.133109"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128402.133109"] = 192544, -- Maw of the Damned (Vampiric Fangs)
	["128870.133109"] = 192349, -- The Kingslayers (Master Assassin)
	["128940.133109"] = 195291, -- Fists of the Heavens (Fists of the Wind)
	["128861.133109"] = 197162, -- Titanstrike (Jaws of Thunder)
	["128819.133109"] = 198349, -- Doomhammer (Gathering of the Maelstrom)
	["128908.133109"] = 200860, -- Warswords of the Valarjar (Unrivaled Strength)
	["128872.133109"] = 202530, -- The Dreadblades (Fortune Strikes)
	["128808.133109"] = 203670, -- Talonclaw, Spear of the Wild Gods (Explosive Force)
	["128866.133109"] = 209218, -- Truthguard (Consecration in Flame)
	["128910.133109"] = 209492, -- Strom'kar, the Warbreaker (Precise Strikes)
	["128832.133109"] = 212817, -- The Aldrachi Warblades (Fiery Demise)
	["128938.133109"] = 213133, -- Fu Zan, the Wanderer's Companion (Healthy Appetite)
	-- Nightmare - Boss 3 - Relic STORM
	["128935.138229"] = 191577, -- The Fist of Ra-den (Electric Discharge)
	["128826.138229"] = 190529, -- Thas'dorah, Legacy of the Windrunners (Marked for Death)
	["128940.138229"] = 195291, -- Fists of the Heavens (Fists of the Wind)
	["128861.138229"] = 197162, -- Titanstrike (Jaws of Thunder)
	["128819.138229"] = 198349, -- Doomhammer (Gathering of the Maelstrom)
	["128937.138229"] = 199380, -- Sheilun, Staff of the Mists (Infusion of Life)
	["128908.138229"] = 200860, -- Warswords of the Valarjar (Unrivaled Strength)
	["128872.138229"] = 202530, -- The Dreadblades (Fortune Strikes)
	["128808.138229"] = 203670, -- Talonclaw, Spear of the Wild Gods (Explosive Force)
	["128938.138229"] = 213133, -- Fu Zan, the Wanderer's Companion (Healthy Appetite)
	-- Fel-Bloated Venom Sac
	["128941.139253"] = 196236, -- Scepter of Sargeras (Soulsnatcher)
	["128476.139253"] = 197369, -- Fangs of the Devourer (Fortune's Bite)
	["127829.139253"] = 201458, -- Twinblades of the Deceiver (Demon Rage)
	["128943.139253"] = 211105, -- Skull of the Man'ari (Dirty Hands)
	["128832.139253"] = 212816, -- The Aldrachi Warblades (Embrace the Pain)
	-- Hex-Cleansed Charm
	["128306.133110"] = 189749, -- G'Hanir, the Mother Tree (Natural Mending)
	["128826.133110"] = 190529, -- Thas'dorah, Legacy of the Windrunners (Marked for Death)
	["128825.133110"] = 196429, -- T'uure, Beacon of the Naaru (Hallowed Ground)
	["128937.133110"] = 199380, -- Sheilun, Staff of the Mists (Infusion of Life)
	["128821.133110"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128823.133110"] = 200298, -- The Silver Hand (Blessings of the Silver Hand)
	["128858.133110"] = 202466, -- Scythe of Elune (Sunfire Burns)
	["128911.133110"] = 207285, -- Sharas'dal, Scepter of Tides (Queen Ascendant)
	["128860.133110"] = 210637, -- Fangs of Ashamane (Sharpened Claws)
	["128938.133110"] = 213133, -- Fu Zan, the Wanderer's Companion (Healthy Appetite)
	-- Shrieking Bloodstone
	["128289.139254"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128403.139254"] = 224466, -- Apocalypse (Runic Tattoos)
	["128402.139254"] = 192457, -- Maw of the Damned (Veinrender)
	["128826.139254"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128870.139254"] = 192326, -- The Kingslayers (Balanced Blades)
	["128827.139254"] = 193645, -- Xal'atath, Blade of the Black Empire (Death's Embrace)
	["128942.139254"] = 199152, -- Ulthalesh, the Deadwind Harvester (Inherently Unstable)
	["128821.139254"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128872.139254"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.139254"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128910.139254"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128860.139254"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	-- Vengeful Skyhorn Spirit
	["128292.133111"] = 189147, -- Blades of the Fallen Prince (Bad to the Bone)
	["128403.133111"] = 191488, -- Apocalypse (The Darkest Crusade)
	["128402.133111"] = 192544, -- Maw of the Damned (Vampiric Fangs)
	["128870.133111"] = 192349, -- The Kingslayers (Master Assassin)
	["128827.133111"] = 194016, -- Xal'atath, Blade of the Black Empire (Void Corruption)
	["128476.133111"] = 197386, -- Fangs of the Devourer (Soul Shadows)
	["128868.133111"] = 197729, -- Light's Wrath (Shield of Faith)
	["128942.133111"] = 199158, -- Ulthalesh, the Deadwind Harvester (Perdition)
	["127829.133111"] = 201460, -- Twinblades of the Deceiver (Unleashed Demons)
	["128910.133111"] = 209492, -- Strom'kar, the Warbreaker (Precise Strikes)
	["128943.133111"] = 211119, -- Skull of the Man'ari (Infernal Furnace)
	-- Scything Quill
	["128289.139255"] = 216272, -- Scale of the Earth-Warder (Rage of the Fallen)
	["128402.139255"] = 192453, -- Maw of the Damned (Meat Shield)
	["128870.139255"] = 192315, -- The Kingslayers (Serrated Edge)
	["128940.139255"] = 195263, -- Fists of the Heavens (Rising Winds)
	["128861.139255"] = 197047, -- Titanstrike (Furious Swipes)
	["128819.139255"] = 198236, -- Doomhammer (Forged in Lava)
	["128908.139255"] = 216273, -- Warswords of the Valarjar (Wild Slashes)
	["128872.139255"] = 202507, -- The Dreadblades (Blade Dancer)
	["128808.139255"] = 203577, -- Talonclaw, Spear of the Wild Gods (My Beloved Monster)
	["128832.139255"] = 207347, -- The Aldrachi Warblades (Aura of Pain)
	["128866.139255"] = 209217, -- Truthguard (Stern Judgment)
	["128910.139255"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128938.139255"] = 227687, -- Fu Zan, the Wanderer's Companion (Hot Blooded)
	-- Tears of the Skyhorn
	-- Sloshing Core of Hatred
	["120978.139256"] = 186941, -- Ashbringer (Highlord's Judgment)
	["128289.139256"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128403.139256"] = 191419, -- Apocalypse (Deadliest Coil)
	["128820.139256"] = 194224, -- Felo'melorn (Fire at Will)
	["128941.139256"] = 196211, -- Scepter of Sargeras (Master of Disaster)
	["128819.139256"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128821.139256"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128908.139256"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128943.139256"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Skyhorn Eagle Feather
	["128935.133113"] = 191577, -- The Fist of Ra-den (Electric Discharge)
	["128826.133113"] = 190529, -- Thas'dorah, Legacy of the Windrunners (Marked for Death)
	["128940.133113"] = 195291, -- Fists of the Heavens (Fists of the Wind)
	["128861.133113"] = 197162, -- Titanstrike (Jaws of Thunder)
	["128819.133113"] = 198349, -- Doomhammer (Gathering of the Maelstrom)
	["128937.133113"] = 199380, -- Sheilun, Staff of the Mists (Infusion of Life)
	["128908.133113"] = 200860, -- Warswords of the Valarjar (Unrivaled Strength)
	["128872.133113"] = 202530, -- The Dreadblades (Fortune Strikes)
	["128808.133113"] = 203670, -- Talonclaw, Spear of the Wild Gods (Explosive Force)
	["128938.133113"] = 213133, -- Fu Zan, the Wanderer's Companion (Healthy Appetite)
	-- Gore-Drenched Fetish
	["128289.139257"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128402.139257"] = 192464, -- Maw of the Damned (All-Consuming Rot)
	["128826.139257"] = 190567, -- Thas'dorah, Legacy of the Windrunners (Gust of Wind)
	["128870.139257"] = 192376, -- The Kingslayers (Poison Knives)
	["128827.139257"] = 194002, -- Xal'atath, Blade of the Black Empire (Creeping Shadows)
	["128942.139257"] = 199163, -- Ulthalesh, the Deadwind Harvester (Shadowy Incantations)
	["128821.139257"] = 200415, -- Claws of Ursoc (Sharpened Instincts)
	["128872.139257"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.139257"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128403.139257"] = 208598, -- Apocalypse (Eternal Agony)
	["128910.139257"] = 209494, -- Strom'kar, the Warbreaker (Exploit the Weakness)
	["128860.139257"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	-- Valor of the Stonedark
	["120978.133114"] = 186934, -- Ashbringer (Embrace the Light)
	["128825.133114"] = 196489, -- T'uure, Beacon of the Naaru (Power of the Naaru)
	["128868.133114"] = 197711, -- Light's Wrath (Vestments of Discipline)
	["128823.133114"] = 200327, -- The Silver Hand (Share the Burden)
	["128866.133114"] = 209224, -- Truthguard (Resolve of Truth)
	-- Radiating Metallic Shard
	["120978.139258"] = 186944, -- Ashbringer (Protector of the Ashen Blade)
	["128825.139258"] = 196430, -- T'uure, Beacon of the Naaru (Words of Healing)
	["128868.139258"] = 197762, -- Light's Wrath (Borrowed Time)
	["128866.139258"] = 209216, -- Truthguard (Bastion of Truth)
	["128823.139258"] = 200482, -- The Silver Hand (Second Sunrise)
	-- Stonedark Focus
	["127857.133115"] = 187321, -- Aluneth, Greatstaff of the Magna (Aegwynn's Wrath)
	["128820.133115"] = 194312, -- Felo'melorn (Burning Gaze)
	["128862.133115"] = 195322, -- Ebonchill, Greatstaff of Alodi (Let It Go)
	["128861.133115"] = 197080, -- Titanstrike (Pack Leader)
	["128858.133115"] = 202426, -- Scythe of Elune (Solar Stabbing)
	["128832.133115"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128866.133115"] = 209220, -- Truthguard (Unflinching Defense)
	-- Cube of Malice
	["127857.139259"] = 187321, -- Aluneth, Greatstaff of the Magna (Aegwynn's Wrath)
	["128292.139259"] = 189086, -- Blades of the Fallen Prince (Blast Radius)
	["128306.139259"] = 189760, -- G'Hanir, the Mother Tree (Essence of Nordrassil)
	["128935.139259"] = 191504, -- The Fist of Ra-den (Lava Imbued)
	["128862.139259"] = 195322, -- Ebonchill, Greatstaff of Alodi (Let It Go)
	["128937.139259"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128911.139259"] = 210029, -- Sharas'dal, Scepter of Tides (Pull of the Sea)
	["128860.139259"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	-- Bloodsinger Essence
	["128289.133116"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128403.133116"] = 224466, -- Apocalypse (Runic Tattoos)
	["128402.133116"] = 192457, -- Maw of the Damned (Veinrender)
	["128826.133116"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128870.133116"] = 192326, -- The Kingslayers (Balanced Blades)
	["128827.133116"] = 193645, -- Xal'atath, Blade of the Black Empire (Death's Embrace)
	["128942.133116"] = 199152, -- Ulthalesh, the Deadwind Harvester (Inherently Unstable)
	["128821.133116"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128872.133116"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.133116"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128910.133116"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128860.133116"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	-- Bloodied Bear Fang
	["128289.139260"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128403.139260"] = 191485, -- Apocalypse (Plaguebearer)
	["128402.139260"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128826.139260"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128870.139260"] = 192318, -- The Kingslayers (Master Alchemist)
	["128827.139260"] = 193644, -- Xal'atath, Blade of the Black Empire (To the Pain)
	["128942.139260"] = 199120, -- Ulthalesh, the Deadwind Harvester (Drained to a Husk)
	["128821.139260"] = 208762, -- Claws of Ursoc (Mauler)
	["128872.139260"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.139260"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128910.139260"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128860.139260"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	-- Torok's Heart
	["128941.133117"] = 196236, -- Scepter of Sargeras (Soulsnatcher)
	["128476.133117"] = 197369, -- Fangs of the Devourer (Fortune's Bite)
	["127829.133117"] = 201458, -- Twinblades of the Deceiver (Demon Rage)
	["128943.133117"] = 211105, -- Skull of the Man'ari (Dirty Hands)
	["128832.133117"] = 212816, -- The Aldrachi Warblades (Embrace the Pain)
	-- Tuft of Ironfur
	["128289.139261"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128402.139261"] = 192460, -- Maw of the Damned (Coagulopathy)
	["128870.139261"] = 192329, -- The Kingslayers (Gushing Wound)
	["128940.139261"] = 195269, -- Fists of the Heavens (Power of a Thousand Cranes)
	["128861.139261"] = 197140, -- Titanstrike (Spitting Cobras)
	["128819.139261"] = 198299, -- Doomhammer (Gathering Storms)
	["128908.139261"] = 200856, -- Warswords of the Valarjar (Uncontrolled Rage)
	["128872.139261"] = 202524, -- The Dreadblades (Fatebringer)
	["128808.139261"] = 203669, -- Talonclaw, Spear of the Wild Gods (Fluffy, Go)
	["128866.139261"] = 209223, -- Truthguard (Scatter the Shadows)
	["128910.139261"] = 209481, -- Strom'kar, the Warbreaker (Deathblow)
	["128832.139261"] = 212816, -- The Aldrachi Warblades (Embrace the Pain)
	["128938.139261"] = 213055, -- Fu Zan, the Wanderer's Companion (Staggering Around)
	-- Demonkindre Fangs
	["120978.133118"] = 185368, -- Ashbringer (Might of the Templar)
	["128289.133118"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128403.133118"] = 191488, -- Apocalypse (The Darkest Crusade)
	["128820.133118"] = 194314, -- Felo'melorn (Everburning Consumption)
	["128941.133118"] = 196432, -- Scepter of Sargeras (Burning Hunger)
	["128819.133118"] = 198349, -- Doomhammer (Gathering of the Maelstrom)
	["128821.133118"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128908.133118"] = 200860, -- Warswords of the Valarjar (Unrivaled Strength)
	["128943.133118"] = 211119, -- Skull of the Man'ari (Infernal Furnace)
	-- Reverberating Femur
	["128935.139262"] = 191504, -- The Fist of Ra-den (Lava Imbued)
	["128826.139262"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128940.139262"] = 218607, -- Fists of the Heavens (Tiger Claws)
	["128861.139262"] = 197080, -- Titanstrike (Pack Leader)
	["128819.139262"] = 198247, -- Doomhammer (Wind Surge)
	["128937.139262"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128908.139262"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128872.139262"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.139262"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128938.139262"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Bloodtotems' Fear
	["127857.133119"] = 187287, -- Aluneth, Greatstaff of the Magna (Aegwynn's Fury)
	["128292.133119"] = 189097, -- Blades of the Fallen Prince (Over-Powered)
	["128306.133119"] = 189744, -- G'Hanir, the Mother Tree (Blessing of the World Tree)
	["128935.133119"] = 191598, -- The Fist of Ra-den (Earthen Attunement)
	["128862.133119"] = 195352, -- Ebonchill, Greatstaff of Alodi (The Storm Rages)
	["128937.133119"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128911.133119"] = 207348, -- Sharas'dal, Scepter of Tides (Floodwaters)
	["128860.133119"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	-- Blessing of Cenarius
	["128306.139263"] = 189754, -- G'Hanir, the Mother Tree (Armor of the Ancients)
	["128826.139263"] = 190520, -- Thas'dorah, Legacy of the Windrunners (Precision)
	["128825.139263"] = 196422, -- T'uure, Beacon of the Naaru (Holy Hands)
	["128937.139263"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128821.139263"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128823.139263"] = 200294, -- The Silver Hand (Deliver the Light)
	["128858.139263"] = 202445, -- Scythe of Elune (Falling Star)
	["128911.139263"] = 207255, -- Sharas'dal, Scepter of Tides (Empowered Droplets)
	["128860.139263"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	["128938.139263"] = 213055, -- Fu Zan, the Wanderer's Companion (Staggering Around)
	-- Frag's Core
	["128289.133120"] = 188644, -- Scale of the Earth-Warder (Thunder Crash)
	["128402.133120"] = 192538, -- Maw of the Damned (Bonebreaker)
	["128870.133120"] = 192345, -- The Kingslayers (Shadow Walker)
	["128940.133120"] = 195380, -- Fists of the Heavens (Healing Winds)
	["128861.133120"] = 197138, -- Titanstrike (Natural Reflexes)
	["128819.133120"] = 198248, -- Doomhammer (Elemental Healing)
	["128908.133120"] = 200859, -- Warswords of the Valarjar (Bloodcraze)
	["128872.133120"] = 202533, -- The Dreadblades (Ghostly Shell)
	["128808.133120"] = 203749, -- Talonclaw, Spear of the Wild Gods (Hunter's Bounty)
	["128866.133120"] = 211912, -- Truthguard (Faith's Armor)
	["128910.133120"] = 209541, -- Strom'kar, the Warbreaker (Touch of Zakajz)
	["128832.133120"] = 212827, -- The Aldrachi Warblades (Shatter the Souls)
	["128938.133120"] = 213116, -- Fu Zan, the Wanderer's Companion (Face Palm)
	-- Uplifting Emerald
	["128935.139264"] = 191740, -- The Fist of Ra-den (Firestorm)
	["128826.139264"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128940.139264"] = 195266, -- Fists of the Heavens (Death Art)
	["128861.139264"] = 197139, -- Titanstrike (Focus of the Titans)
	["128819.139264"] = 198292, -- Doomhammer (Wind Strikes)
	["128937.139264"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128908.139264"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128872.139264"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.139264"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128938.139264"] = 213062, -- Fu Zan, the Wanderer's Companion (Dark Side of the Moon)
	-- Instincts of the Elderhorn
	["128306.133121"] = 189772, -- G'Hanir, the Mother Tree (Knowledge of the Ancients)
	["128826.133121"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128825.133121"] = 196434, -- T'uure, Beacon of the Naaru (Holy Guidance)
	["128937.133121"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128821.133121"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128823.133121"] = 200326, -- The Silver Hand (Focused Healing)
	["128858.133121"] = 202384, -- Scythe of Elune (Dark Side of the Moon)
	["128911.133121"] = 207088, -- Sharas'dal, Scepter of Tides (Tidal Chains)
	["128860.133121"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	["128938.133121"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Radiant Dragon Egg
	["120978.139265"] = 184759, -- Ashbringer (Sharpened Edge)
	["128825.139265"] = 196358, -- T'uure, Beacon of the Naaru (Say Your Prayers)
	["128868.139265"] = 197713, -- Light's Wrath (Pain is in Your Mind)
	["128823.139265"] = 200316, -- The Silver Hand (Justice through Sacrifice)
	["128866.139265"] = 209217, -- Truthguard (Stern Judgment)
	-- Betrayal of the Bloodtotem
	["128292.133122"] = 189092, -- Blades of the Fallen Prince (Ambidexterity)
	["128403.133122"] = 191442, -- Apocalypse (Rotten Touch)
	["128402.133122"] = 192453, -- Maw of the Damned (Meat Shield)
	["128870.133122"] = 192315, -- The Kingslayers (Serrated Edge)
	["128827.133122"] = 193643, -- Xal'atath, Blade of the Black Empire (Mind Shattering)
	["128476.133122"] = 197233, -- Fangs of the Devourer (Demon's Kiss)
	["128868.133122"] = 197713, -- Light's Wrath (Pain is in Your Mind)
	["128942.133122"] = 199112, -- Ulthalesh, the Deadwind Harvester (Hideous Corruption)
	["127829.133122"] = 201455, -- Twinblades of the Deceiver (Critical Chaos)
	["128910.133122"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128943.133122"] = 211126, -- Skull of the Man'ari (Legionwrath)
	-- Fragment of Eternal Spite
	["120978.139266"] = 186945, -- Ashbringer (Wrath of the Ashbringer)
	["128289.139266"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128403.139266"] = 224466, -- Apocalypse (Runic Tattoos)
	["128820.139266"] = 210182, -- Felo'melorn (Blue Flame Special)
	["128941.139266"] = 196227, -- Scepter of Sargeras (Residual Flames)
	["128819.139266"] = 198292, -- Doomhammer (Wind Strikes)
	["128821.139266"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128908.139266"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128943.139266"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	-- Azsharan Councillor's Clasp
	["128941.139267"] = 196258, -- Scepter of Sargeras (Fire From the Sky)
	["128476.139267"] = 197239, -- Fangs of the Devourer (Energetic Stabbing)
	["127829.139267"] = 201464, -- Twinblades of the Deceiver (Overwhelming Power)
	["128943.139267"] = 211099, -- Skull of the Man'ari (Maw of Shadows)
	["128832.139267"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	-- Ironbull's Last Words
	["128935.133124"] = 191504, -- The Fist of Ra-den (Lava Imbued)
	["128826.133124"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128940.133124"] = 218607, -- Fists of the Heavens (Tiger Claws)
	["128861.133124"] = 197080, -- Titanstrike (Pack Leader)
	["128819.133124"] = 198247, -- Doomhammer (Wind Surge)
	["128937.133124"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128908.133124"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128872.133124"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.133124"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128938.133124"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Nightmarish Elm Branch
	["128292.139268"] = 189144, -- Blades of the Fallen Prince (Nothing but the Boots)
	["128403.139268"] = 191494, -- Apocalypse (Scourge the Unbeliever)
	["128402.139268"] = 192460, -- Maw of the Damned (Coagulopathy)
	["128870.139268"] = 192329, -- The Kingslayers (Gushing Wound)
	["128827.139268"] = 194007, -- Xal'atath, Blade of the Black Empire (Touch of Darkness)
	["128476.139268"] = 197369, -- Fangs of the Devourer (Fortune's Bite)
	["128868.139268"] = 197727, -- Light's Wrath (Doomsayer)
	["128942.139268"] = 199153, -- Ulthalesh, the Deadwind Harvester (Seeds of Doom)
	["127829.139268"] = 201458, -- Twinblades of the Deceiver (Demon Rage)
	["128910.139268"] = 209481, -- Strom'kar, the Warbreaker (Deathblow)
	["128943.139268"] = 211105, -- Skull of the Man'ari (Dirty Hands)
	-- Confluence of the Tribes
	["120978.133125"] = 186944, -- Ashbringer (Protector of the Ashen Blade)
	["128825.133125"] = 196430, -- T'uure, Beacon of the Naaru (Words of Healing)
	["128868.133125"] = 197762, -- Light's Wrath (Borrowed Time)
	["128866.133125"] = 209216, -- Truthguard (Bastion of Truth)
	["128823.133125"] = 200482, -- The Silver Hand (Second Sunrise)
	-- Crystallized Drop of Eternity
	["127857.139269"] = 187276, -- Aluneth, Greatstaff of the Magna (Ethereal Sensitivity)
	["128820.139269"] = 194314, -- Felo'melorn (Everburning Consumption)
	["128862.139269"] = 195351, -- Ebonchill, Greatstaff of Alodi (Clarity of Thought)
	["128861.139269"] = 197162, -- Titanstrike (Jaws of Thunder)
	["128858.139269"] = 202466, -- Scythe of Elune (Sunfire Burns)
	["128866.139269"] = 209218, -- Truthguard (Consecration in Flame)
	["128832.139269"] = 212817, -- The Aldrachi Warblades (Fiery Demise)
	-- Captured Time Scar
	["127857.133126"] = 187287, -- Aluneth, Greatstaff of the Magna (Aegwynn's Fury)
	["128820.133126"] = 194239, -- Felo'melorn (Pyroclasmic Paranoia)
	["128862.133126"] = 195352, -- Ebonchill, Greatstaff of Alodi (The Storm Rages)
	["128858.133126"] = 202464, -- Scythe of Elune (Empowerment)
	["128861.133126"] = 206910, -- Titanstrike (Unleash the Beast)
	["128866.133126"] = 209216, -- Truthguard (Bastion of Truth)
	["128832.133126"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	-- Blood of Neltharion
	["128289.133127"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128402.133127"] = 192464, -- Maw of the Damned (All-Consuming Rot)
	["128826.133127"] = 190567, -- Thas'dorah, Legacy of the Windrunners (Gust of Wind)
	["128870.133127"] = 192376, -- The Kingslayers (Poison Knives)
	["128827.133127"] = 194002, -- Xal'atath, Blade of the Black Empire (Creeping Shadows)
	["128942.133127"] = 199163, -- Ulthalesh, the Deadwind Harvester (Shadowy Incantations)
	["128821.133127"] = 200415, -- Claws of Ursoc (Sharpened Instincts)
	["128872.133127"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.133127"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128403.133127"] = 208598, -- Apocalypse (Eternal Agony)
	["128910.133127"] = 209494, -- Strom'kar, the Warbreaker (Exploit the Weakness)
	["128860.133127"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	-- Corrupted Earthrender Fragment
	["128941.133128"] = 196258, -- Scepter of Sargeras (Fire From the Sky)
	["128476.133128"] = 197239, -- Fangs of the Devourer (Energetic Stabbing)
	["127829.133128"] = 201464, -- Twinblades of the Deceiver (Overwhelming Power)
	["128943.133128"] = 211099, -- Skull of the Man'ari (Maw of Shadows)
	["128832.133128"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	-- Smoldering Crux
	["120978.133129"] = 186944, -- Ashbringer (Protector of the Ashen Blade)
	["128289.133129"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128820.133129"] = 194239, -- Felo'melorn (Pyroclasmic Paranoia)
	["128941.133129"] = 196258, -- Scepter of Sargeras (Fire From the Sky)
	["128819.133129"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128821.133129"] = 200415, -- Claws of Ursoc (Sharpened Instincts)
	["128908.133129"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128403.133129"] = 208598, -- Apocalypse (Eternal Agony)
	["128943.133129"] = 211099, -- Skull of the Man'ari (Maw of Shadows)
	-- Coldscale Basilisk Eyes
	["127857.133130"] = 187287, -- Aluneth, Greatstaff of the Magna (Aegwynn's Fury)
	["128292.133130"] = 189097, -- Blades of the Fallen Prince (Over-Powered)
	["128306.133130"] = 189744, -- G'Hanir, the Mother Tree (Blessing of the World Tree)
	["128935.133130"] = 191598, -- The Fist of Ra-den (Earthen Attunement)
	["128862.133130"] = 195352, -- Ebonchill, Greatstaff of Alodi (The Storm Rages)
	["128937.133130"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128911.133130"] = 207348, -- Sharas'dal, Scepter of Tides (Floodwaters)
	["128860.133130"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	-- Obsidian Reclaimer Scale
	["128289.133131"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128402.133131"] = 192464, -- Maw of the Damned (All-Consuming Rot)
	["128870.133131"] = 192376, -- The Kingslayers (Poison Knives)
	["128819.133131"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128908.133131"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128872.133131"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.133131"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128940.133131"] = 195267, -- Fists of the Heavens (Strength of Xuen)
	["128861.133131"] = 206910, -- Titanstrike (Unleash the Beast)
	["128866.133131"] = 209216, -- Truthguard (Bastion of Truth)
	["128910.133131"] = 209494, -- Strom'kar, the Warbreaker (Exploit the Weakness)
	["128832.133131"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	["128938.133131"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Echo of Neltharion
	["128306.133132"] = 189744, -- G'Hanir, the Mother Tree (Blessing of the World Tree)
	["128826.133132"] = 190567, -- Thas'dorah, Legacy of the Windrunners (Gust of Wind)
	["128825.133132"] = 196430, -- T'uure, Beacon of the Naaru (Words of Healing)
	["128937.133132"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128821.133132"] = 200415, -- Claws of Ursoc (Sharpened Instincts)
	["128858.133132"] = 202464, -- Scythe of Elune (Empowerment)
	["128911.133132"] = 207348, -- Sharas'dal, Scepter of Tides (Floodwaters)
	["128860.133132"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	["128823.133132"] = 200482, -- The Silver Hand (Second Sunrise)
	["128938.133132"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Sha Splinters
	["128292.133133"] = 189097, -- Blades of the Fallen Prince (Over-Powered)
	["128402.133133"] = 192464, -- Maw of the Damned (All-Consuming Rot)
	["128870.133133"] = 192376, -- The Kingslayers (Poison Knives)
	["128827.133133"] = 194002, -- Xal'atath, Blade of the Black Empire (Creeping Shadows)
	["128476.133133"] = 197239, -- Fangs of the Devourer (Energetic Stabbing)
	["128868.133133"] = 197762, -- Light's Wrath (Borrowed Time)
	["128942.133133"] = 199163, -- Ulthalesh, the Deadwind Harvester (Shadowy Incantations)
	["127829.133133"] = 201464, -- Twinblades of the Deceiver (Overwhelming Power)
	["128403.133133"] = 208598, -- Apocalypse (Eternal Agony)
	["128910.133133"] = 209494, -- Strom'kar, the Warbreaker (Exploit the Weakness)
	["128943.133133"] = 211099, -- Skull of the Man'ari (Maw of Shadows)
	-- Time-Lost Eddy
	-- Pride of Highmountain
	["128935.133135"] = 191598, -- The Fist of Ra-den (Earthen Attunement)
	["128826.133135"] = 190567, -- Thas'dorah, Legacy of the Windrunners (Gust of Wind)
	["128819.133135"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128937.133135"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128908.133135"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128872.133135"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.133135"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128940.133135"] = 195267, -- Fists of the Heavens (Strength of Xuen)
	["128861.133135"] = 206910, -- Titanstrike (Unleash the Beast)
	["128938.133135"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Glory of Highmountain
	["120978.133136"] = 184778, -- Ashbringer (Deflection)
	["128825.133136"] = 196355, -- T'uure, Beacon of the Naaru (Trust in the Light)
	["128868.133136"] = 216212, -- Light's Wrath (Darkest Shadows)
	["128823.133136"] = 200302, -- The Silver Hand (Knight of the Silver Hand)
	["128866.133136"] = 211912, -- Truthguard (Faith's Armor)
	-- Wisps of Illusion
	["127857.133137"] = 187264, -- Aluneth, Greatstaff of the Magna (Aegwynn's Imperative)
	["128820.133137"] = 210182, -- Felo'melorn (Blue Flame Special)
	["128862.133137"] = 195323, -- Ebonchill, Greatstaff of Alodi (Orbital Strike)
	["128861.133137"] = 197139, -- Titanstrike (Focus of the Titans)
	["128858.133137"] = 202433, -- Scythe of Elune (Scythe of the Stars)
	["128866.133137"] = 209226, -- Truthguard (Righteous Crusader)
	["128832.133137"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	-- Time-Lost Dragon Heart
	["128289.133138"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128403.133138"] = 191494, -- Apocalypse (Scourge the Unbeliever)
	["128402.133138"] = 192460, -- Maw of the Damned (Coagulopathy)
	["128826.133138"] = 190520, -- Thas'dorah, Legacy of the Windrunners (Precision)
	["128870.133138"] = 192329, -- The Kingslayers (Gushing Wound)
	["128827.133138"] = 194007, -- Xal'atath, Blade of the Black Empire (Touch of Darkness)
	["128942.133138"] = 199153, -- Ulthalesh, the Deadwind Harvester (Seeds of Doom)
	["128821.133138"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128872.133138"] = 202524, -- The Dreadblades (Fatebringer)
	["128808.133138"] = 203669, -- Talonclaw, Spear of the Wild Gods (Fluffy, Go)
	["128910.133138"] = 209481, -- Strom'kar, the Warbreaker (Deathblow)
	["128860.133138"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	-- Feltotem Sigil
	["128941.133139"] = 196432, -- Scepter of Sargeras (Burning Hunger)
	["128476.133139"] = 197386, -- Fangs of the Devourer (Soul Shadows)
	["127829.133139"] = 201460, -- Twinblades of the Deceiver (Unleashed Demons)
	["128943.133139"] = 211119, -- Skull of the Man'ari (Infernal Furnace)
	["128832.133139"] = 212817, -- The Aldrachi Warblades (Fiery Demise)
	-- Time-Lost Dragonfire
	["120978.133140"] = 184843, -- Ashbringer (Righteous Blade)
	["128289.133140"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128403.133140"] = 191485, -- Apocalypse (Plaguebearer)
	["128820.133140"] = 194312, -- Felo'melorn (Burning Gaze)
	["128941.133140"] = 196222, -- Scepter of Sargeras (Fire and the Flames)
	["128819.133140"] = 198247, -- Doomhammer (Wind Surge)
	["128821.133140"] = 208762, -- Claws of Ursoc (Mauler)
	["128908.133140"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128943.133140"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Flawless Kun-Lai Blossom
	["127857.133141"] = 187301, -- Aluneth, Greatstaff of the Magna (Everywhere At Once)
	["128292.133141"] = 189154, -- Blades of the Fallen Prince (Ice in Your Veins)
	["128306.133141"] = 186396, -- G'Hanir, the Mother Tree (Persistence)
	["128935.133141"] = 191569, -- The Fist of Ra-den (Protection of the Elements)
	["128862.133141"] = 195354, -- Ebonchill, Greatstaff of Alodi (Shield of Alodi)
	["128937.133141"] = 199365, -- Sheilun, Staff of the Mists (Shroud of Mist)
	["128911.133141"] = 207351, -- Sharas'dal, Scepter of Tides (Ghost in the Mist)
	["128860.133141"] = 210557, -- Fangs of Ashamane (Honed Instincts)
	-- Stonedark Brul Brand
	["128289.133142"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128402.133142"] = 192450, -- Maw of the Damned (Iron Heart)
	["128870.133142"] = 192310, -- The Kingslayers (Toxic Blades)
	["128940.133142"] = 195243, -- Fists of the Heavens (Inner Peace)
	["128861.133142"] = 197038, -- Titanstrike (Wilderness Expert)
	["128819.133142"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128908.133142"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128872.133142"] = 216230, -- The Dreadblades (Black Powder)
	["128808.133142"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128832.133142"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128866.133142"] = 209229, -- Truthguard (Hammer Time)
	["128910.133142"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128938.133142"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Spark of Khaz'goroth
	["128306.133143"] = 189768, -- G'Hanir, the Mother Tree (Seeds of the World Tree)
	["128826.133143"] = 190457, -- Thas'dorah, Legacy of the Windrunners (Windrunner's Guidance)
	["128825.133143"] = 196358, -- T'uure, Beacon of the Naaru (Say Your Prayers)
	["128937.133143"] = 199366, -- Sheilun, Staff of the Mists (Way of the Mistweaver)
	["128821.133143"] = 200399, -- Claws of Ursoc (Ursoc's Endurance)
	["128823.133143"] = 200316, -- The Silver Hand (Justice through Sacrifice)
	["128858.133143"] = 202386, -- Scythe of Elune (Twilight Glow)
	["128911.133143"] = 207092, -- Sharas'dal, Scepter of Tides (Buffeting Waves)
	["128860.133143"] = 210571, -- Fangs of Ashamane (Feral Power)
	["128938.133143"] = 227687, -- Fu Zan, the Wanderer's Companion (Hot Blooded)
	-- Memory of Neltharion
	["128292.133144"] = 189086, -- Blades of the Fallen Prince (Blast Radius)
	["128403.133144"] = 191485, -- Apocalypse (Plaguebearer)
	["128402.133144"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128870.133144"] = 192318, -- The Kingslayers (Master Alchemist)
	["128827.133144"] = 193644, -- Xal'atath, Blade of the Black Empire (To the Pain)
	["128476.133144"] = 197234, -- Fangs of the Devourer (Gutripper)
	["128868.133144"] = 197715, -- Light's Wrath (The Edge of Dark and Light)
	["128942.133144"] = 199120, -- Ulthalesh, the Deadwind Harvester (Drained to a Husk)
	["127829.133144"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128910.133144"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128943.133144"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Anguish of Princes
	-- The Four Winds
	["128935.133146"] = 191740, -- The Fist of Ra-den (Firestorm)
	["128826.133146"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128940.133146"] = 195266, -- Fists of the Heavens (Death Art)
	["128861.133146"] = 197139, -- Titanstrike (Focus of the Titans)
	["128819.133146"] = 198292, -- Doomhammer (Wind Strikes)
	["128937.133146"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128908.133146"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128872.133146"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.133146"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128938.133146"] = 213062, -- Fu Zan, the Wanderer's Companion (Dark Side of the Moon)
	-- Imp-Eye Diamond
	["128941.141520"] = 196222, -- Scepter of Sargeras (Fire and the Flames)
	["128476.141520"] = 197234, -- Fangs of the Devourer (Gutripper)
	["127829.141520"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128832.141520"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128943.141520"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Pillaged Titan Disc
	["120978.141519"] = 185368, -- Ashbringer (Might of the Templar)
	["128825.141519"] = 196429, -- T'uure, Beacon of the Naaru (Hallowed Ground)
	["128868.141519"] = 197729, -- Light's Wrath (Shield of Faith)
	["128823.141519"] = 200298, -- The Silver Hand (Blessings of the Silver Hand)
	["128866.141519"] = 209218, -- Truthguard (Consecration in Flame)
	-- "Liberated" Un'goro Relic
	["128306.141516"] = 189768, -- G'Hanir, the Mother Tree (Seeds of the World Tree)
	["128826.141516"] = 190457, -- Thas'dorah, Legacy of the Windrunners (Windrunner's Guidance)
	["128825.141516"] = 196358, -- T'uure, Beacon of the Naaru (Say Your Prayers)
	["128937.141516"] = 199366, -- Sheilun, Staff of the Mists (Way of the Mistweaver)
	["128821.141516"] = 200399, -- Claws of Ursoc (Ursoc's Endurance)
	["128823.141516"] = 200316, -- The Silver Hand (Justice through Sacrifice)
	["128858.141516"] = 202386, -- Scythe of Elune (Twilight Glow)
	["128911.141516"] = 207092, -- Sharas'dal, Scepter of Tides (Buffeting Waves)
	["128860.141516"] = 210571, -- Fangs of Ashamane (Feral Power)
	["128938.141516"] = 227687, -- Fu Zan, the Wanderer's Companion (Hot Blooded)
	-- Leystone Nugget
	["127857.141515"] = 187264, -- Aluneth, Greatstaff of the Magna (Aegwynn's Imperative)
	["128820.141515"] = 210182, -- Felo'melorn (Blue Flame Special)
	["128862.141515"] = 195323, -- Ebonchill, Greatstaff of Alodi (Orbital Strike)
	["128861.141515"] = 197139, -- Titanstrike (Focus of the Titans)
	["128858.141515"] = 202433, -- Scythe of Elune (Scythe of the Stars)
	["128866.141515"] = 209226, -- Truthguard (Righteous Crusader)
	["128832.141515"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	-- Barnacled Mistcaller Orb
	["128935.141514"] = 191572, -- The Fist of Ra-den (Molten Blast)
	["128826.141514"] = 190520, -- Thas'dorah, Legacy of the Windrunners (Precision)
	["128940.141514"] = 195269, -- Fists of the Heavens (Power of a Thousand Cranes)
	["128861.141514"] = 197140, -- Titanstrike (Spitting Cobras)
	["128819.141514"] = 198299, -- Doomhammer (Gathering Storms)
	["128937.141514"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128908.141514"] = 200856, -- Warswords of the Valarjar (Uncontrolled Rage)
	["128872.141514"] = 202524, -- The Dreadblades (Fatebringer)
	["128808.141514"] = 203669, -- Talonclaw, Spear of the Wild Gods (Fluffy, Go)
	["128938.141514"] = 213055, -- Fu Zan, the Wanderer's Companion (Staggering Around)
	-- Howling Echoes
	["128935.137270"] = 191499, -- The Fist of Ra-den (The Ground Trembles)
	["128826.137270"] = 190457, -- Thas'dorah, Legacy of the Windrunners (Windrunner's Guidance)
	["128940.137270"] = 195263, -- Fists of the Heavens (Rising Winds)
	["128861.137270"] = 197047, -- Titanstrike (Furious Swipes)
	["128819.137270"] = 198236, -- Doomhammer (Forged in Lava)
	["128937.137270"] = 199366, -- Sheilun, Staff of the Mists (Way of the Mistweaver)
	["128908.137270"] = 216273, -- Warswords of the Valarjar (Wild Slashes)
	["128872.137270"] = 202507, -- The Dreadblades (Blade Dancer)
	["128808.137270"] = 203577, -- Talonclaw, Spear of the Wild Gods (My Beloved Monster)
	["128938.137270"] = 227687, -- Fu Zan, the Wanderer's Companion (Hot Blooded)
	-- Cruelty of Dantalionax
	["127857.137272"] = 187321, -- Aluneth, Greatstaff of the Magna (Aegwynn's Wrath)
	["128292.137272"] = 189086, -- Blades of the Fallen Prince (Blast Radius)
	["128306.137272"] = 189760, -- G'Hanir, the Mother Tree (Essence of Nordrassil)
	["128935.137272"] = 191504, -- The Fist of Ra-den (Lava Imbued)
	["128862.137272"] = 195322, -- Ebonchill, Greatstaff of Alodi (Let It Go)
	["128937.137272"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128911.137272"] = 210029, -- Sharas'dal, Scepter of Tides (Pull of the Sea)
	["128860.137272"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	-- Misshapen Abomination Heart
	["128289.137302"] = 188632, -- Scale of the Earth-Warder (Toughness)
	["128403.137302"] = 191565, -- Apocalypse (Deadly Durability)
	["128402.137302"] = 192514, -- Maw of the Damned (Dance of Darkness)
	["128826.137302"] = 190503, -- Thas'dorah, Legacy of the Windrunners (Healing Shell)
	["128870.137302"] = 192323, -- The Kingslayers (Fade into Shadows)
	["128827.137302"] = 193642, -- Xal'atath, Blade of the Black Empire (From the Shadows)
	["128942.137302"] = 199212, -- Ulthalesh, the Deadwind Harvester (Shadows of the Flesh)
	["128821.137302"] = 200400, -- Claws of Ursoc (Wildflesh)
	["128872.137302"] = 202521, -- The Dreadblades (Fortune's Strike)
	["128808.137302"] = 224764, -- Talonclaw, Spear of the Wild Gods (Bird of Prey)
	["128910.137302"] = 209483, -- Strom'kar, the Warbreaker (Tactical Advance)
	["128860.137302"] = 210557, -- Fangs of Ashamane (Honed Instincts)
	-- Touch of Nightfall
	["127857.137303"] = 187287, -- Aluneth, Greatstaff of the Magna (Aegwynn's Fury)
	["128820.137303"] = 194239, -- Felo'melorn (Pyroclasmic Paranoia)
	["128862.137303"] = 195352, -- Ebonchill, Greatstaff of Alodi (The Storm Rages)
	["128858.137303"] = 202464, -- Scythe of Elune (Empowerment)
	["128861.137303"] = 206910, -- Titanstrike (Unleash the Beast)
	["128866.137303"] = 209216, -- Truthguard (Bastion of Truth)
	["128832.137303"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	-- Spellfire Oil
	["120978.141293"] = 185368, -- Ashbringer (Might of the Templar)
	["128289.141293"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128403.141293"] = 191488, -- Apocalypse (The Darkest Crusade)
	["128820.141293"] = 194314, -- Felo'melorn (Everburning Consumption)
	["128941.141293"] = 196432, -- Scepter of Sargeras (Burning Hunger)
	["128819.141293"] = 198349, -- Doomhammer (Gathering of the Maelstrom)
	["128821.141293"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128908.141293"] = 200860, -- Warswords of the Valarjar (Unrivaled Strength)
	["128943.141293"] = 211119, -- Skull of the Man'ari (Infernal Furnace)
	-- Crystallizing Mana
	["127857.141292"] = 187264, -- Aluneth, Greatstaff of the Magna (Aegwynn's Imperative)
	["128820.141292"] = 210182, -- Felo'melorn (Blue Flame Special)
	["128862.141292"] = 195323, -- Ebonchill, Greatstaff of Alodi (Orbital Strike)
	["128861.141292"] = 197139, -- Titanstrike (Focus of the Titans)
	["128858.141292"] = 202433, -- Scythe of Elune (Scythe of the Stars)
	["128866.141292"] = 209226, -- Truthguard (Righteous Crusader)
	["128832.141292"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	-- Shala'nir Sproutling
	["128403.141291"] = 191584, -- Apocalypse (Unholy Endurance)
	["128402.141291"] = 192538, -- Maw of the Damned (Bonebreaker)
	["128870.141291"] = 192345, -- The Kingslayers (Shadow Walker)
	["128827.141291"] = 193647, -- Xal'atath, Blade of the Black Empire (Thoughts of Insanity)
	["128476.141291"] = 197244, -- Fangs of the Devourer (Ghost Armor)
	["128868.141291"] = 216212, -- Light's Wrath (Darkest Shadows)
	["128942.141291"] = 199214, -- Ulthalesh, the Deadwind Harvester (Long Dark Night of the Soul)
	["127829.141291"] = 201463, -- Twinblades of the Deceiver (Deceiver's Fury)
	["128292.141291"] = 204875, -- Blades of the Fallen Prince (Frozen Skin)
	["128910.141291"] = 209541, -- Strom'kar, the Warbreaker (Touch of Zakajz)
	["128943.141291"] = 211131, -- Skull of the Man'ari (Firm Resolve)
	-- Dreamgrove Sproutling
	["128306.141290"] = 189749, -- G'Hanir, the Mother Tree (Natural Mending)
	["128826.141290"] = 190529, -- Thas'dorah, Legacy of the Windrunners (Marked for Death)
	["128825.141290"] = 196429, -- T'uure, Beacon of the Naaru (Hallowed Ground)
	["128937.141290"] = 199380, -- Sheilun, Staff of the Mists (Infusion of Life)
	["128821.141290"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128823.141290"] = 200298, -- The Silver Hand (Blessings of the Silver Hand)
	["128858.141290"] = 202466, -- Scythe of Elune (Sunfire Burns)
	["128911.141290"] = 207285, -- Sharas'dal, Scepter of Tides (Queen Ascendant)
	["128860.141290"] = 210637, -- Fangs of Ashamane (Sharpened Claws)
	["128938.141290"] = 213133, -- Fu Zan, the Wanderer's Companion (Healthy Appetite)
	-- Corruption of the Bloodtotem
	["128941.141289"] = 196222, -- Scepter of Sargeras (Fire and the Flames)
	["128476.141289"] = 197234, -- Fangs of the Devourer (Gutripper)
	["127829.141289"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128832.141289"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128943.141289"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Ettin Bone Fragment
	["128289.141288"] = 216272, -- Scale of the Earth-Warder (Rage of the Fallen)
	["128402.141288"] = 192453, -- Maw of the Damned (Meat Shield)
	["128870.141288"] = 192315, -- The Kingslayers (Serrated Edge)
	["128940.141288"] = 195263, -- Fists of the Heavens (Rising Winds)
	["128861.141288"] = 197047, -- Titanstrike (Furious Swipes)
	["128819.141288"] = 198236, -- Doomhammer (Forged in Lava)
	["128908.141288"] = 216273, -- Warswords of the Valarjar (Wild Slashes)
	["128872.141288"] = 202507, -- The Dreadblades (Blade Dancer)
	["128808.141288"] = 203577, -- Talonclaw, Spear of the Wild Gods (My Beloved Monster)
	["128832.141288"] = 207347, -- The Aldrachi Warblades (Aura of Pain)
	["128866.141288"] = 209217, -- Truthguard (Stern Judgment)
	["128910.141288"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128938.141288"] = 227687, -- Fu Zan, the Wanderer's Companion (Hot Blooded)
	-- Corrupted Knot
	["128306.137307"] = 189772, -- G'Hanir, the Mother Tree (Knowledge of the Ancients)
	["128826.137307"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128825.137307"] = 196434, -- T'uure, Beacon of the Naaru (Holy Guidance)
	["128937.137307"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128821.137307"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128823.137307"] = 200326, -- The Silver Hand (Focused Healing)
	["128858.137307"] = 202384, -- Scythe of Elune (Dark Side of the Moon)
	["128911.137307"] = 207088, -- Sharas'dal, Scepter of Tides (Tidal Chains)
	["128860.137307"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	["128938.137307"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Law of Strength
	["128289.141287"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128403.141287"] = 224466, -- Apocalypse (Runic Tattoos)
	["128402.141287"] = 192457, -- Maw of the Damned (Veinrender)
	["128826.141287"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128870.141287"] = 192326, -- The Kingslayers (Balanced Blades)
	["128827.141287"] = 193645, -- Xal'atath, Blade of the Black Empire (Death's Embrace)
	["128942.141287"] = 199152, -- Ulthalesh, the Deadwind Harvester (Inherently Unstable)
	["128821.141287"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128872.141287"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.141287"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128910.141287"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128860.141287"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	-- Rite of the Val'kyr
	["120978.141286"] = 184778, -- Ashbringer (Deflection)
	["128825.141286"] = 196355, -- T'uure, Beacon of the Naaru (Trust in the Light)
	["128868.141286"] = 216212, -- Light's Wrath (Darkest Shadows)
	["128823.141286"] = 200302, -- The Silver Hand (Knight of the Silver Hand)
	["128866.141286"] = 211912, -- Truthguard (Faith's Armor)
	-- Clotted Sap of the Grove
	["127857.137308"] = 187258, -- Aluneth, Greatstaff of the Magna (Blasting Rod)
	["128292.137308"] = 189092, -- Blades of the Fallen Prince (Ambidexterity)
	["128306.137308"] = 189768, -- G'Hanir, the Mother Tree (Seeds of the World Tree)
	["128935.137308"] = 191499, -- The Fist of Ra-den (The Ground Trembles)
	["128862.137308"] = 195317, -- Ebonchill, Greatstaff of Alodi (Ice Age)
	["128937.137308"] = 199366, -- Sheilun, Staff of the Mists (Way of the Mistweaver)
	["128911.137308"] = 207092, -- Sharas'dal, Scepter of Tides (Buffeting Waves)
	["128860.137308"] = 210571, -- Fangs of Ashamane (Feral Power)
	-- Nar'thalas Writ
	["128935.141285"] = 191493, -- The Fist of Ra-den (Call the Thunder)
	["128826.141285"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128940.141285"] = 195243, -- Fists of the Heavens (Inner Peace)
	["128861.141285"] = 197038, -- Titanstrike (Wilderness Expert)
	["128819.141285"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128937.141285"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128908.141285"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128872.141285"] = 216230, -- The Dreadblades (Black Powder)
	["128808.141285"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128938.141285"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Nor'danil Ampoule
	["127857.141284"] = 187313, -- Aluneth, Greatstaff of the Magna (Arcane Purification)
	["128292.141284"] = 189144, -- Blades of the Fallen Prince (Nothing but the Boots)
	["128306.141284"] = 189754, -- G'Hanir, the Mother Tree (Armor of the Ancients)
	["128935.141284"] = 191572, -- The Fist of Ra-den (Molten Blast)
	["128862.141284"] = 195345, -- Ebonchill, Greatstaff of Alodi (Frozen Veins)
	["128937.141284"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128911.141284"] = 207255, -- Sharas'dal, Scepter of Tides (Empowered Droplets)
	["128860.141284"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	-- Felbat Razorfang
	["128289.141283"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128403.141283"] = 191419, -- Apocalypse (Deadliest Coil)
	["128402.141283"] = 192450, -- Maw of the Damned (Iron Heart)
	["128826.141283"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128870.141283"] = 192310, -- The Kingslayers (Toxic Blades)
	["128827.141283"] = 194093, -- Xal'atath, Blade of the Black Empire (Unleash the Shadows)
	["128942.141283"] = 199111, -- Ulthalesh, the Deadwind Harvester (Inimitable Agony)
	["128821.141283"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128872.141283"] = 216230, -- The Dreadblades (Black Powder)
	["128808.141283"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128910.141283"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128860.141283"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	-- Legion Portalstone
	["128941.141281"] = 196432, -- Scepter of Sargeras (Burning Hunger)
	["128476.141281"] = 197386, -- Fangs of the Devourer (Soul Shadows)
	["127829.141281"] = 201460, -- Twinblades of the Deceiver (Unleashed Demons)
	["128943.141281"] = 211119, -- Skull of the Man'ari (Infernal Furnace)
	["128832.141281"] = 212817, -- The Aldrachi Warblades (Fiery Demise)
	-- Demonic Shackles
	["128289.141280"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128403.141280"] = 191494, -- Apocalypse (Scourge the Unbeliever)
	["128402.141280"] = 192460, -- Maw of the Damned (Coagulopathy)
	["128826.141280"] = 190520, -- Thas'dorah, Legacy of the Windrunners (Precision)
	["128870.141280"] = 192329, -- The Kingslayers (Gushing Wound)
	["128827.141280"] = 194007, -- Xal'atath, Blade of the Black Empire (Touch of Darkness)
	["128942.141280"] = 199153, -- Ulthalesh, the Deadwind Harvester (Seeds of Doom)
	["128821.141280"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128872.141280"] = 202524, -- The Dreadblades (Fatebringer)
	["128808.141280"] = 203669, -- Talonclaw, Spear of the Wild Gods (Fluffy, Go)
	["128910.141280"] = 209481, -- Strom'kar, the Warbreaker (Deathblow)
	["128860.141280"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	-- Prison Guard's Torchflame
	["120978.141279"] = 186941, -- Ashbringer (Highlord's Judgment)
	["128289.141279"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128403.141279"] = 191419, -- Apocalypse (Deadliest Coil)
	["128820.141279"] = 194224, -- Felo'melorn (Fire at Will)
	["128941.141279"] = 196211, -- Scepter of Sargeras (Master of Disaster)
	["128819.141279"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128821.141279"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128908.141279"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128943.141279"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Glaivemaster's Whetstone
	["128935.141278"] = 191504, -- The Fist of Ra-den (Lava Imbued)
	["128826.141278"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128940.141278"] = 218607, -- Fists of the Heavens (Tiger Claws)
	["128861.141278"] = 197080, -- Titanstrike (Pack Leader)
	["128819.141278"] = 198247, -- Doomhammer (Wind Surge)
	["128937.141278"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128908.141278"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128872.141278"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.141278"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128938.141278"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Bloodtotem Brand
	["128941.141277"] = 196217, -- Scepter of Sargeras (Chaotic Instability)
	["128476.141277"] = 197233, -- Fangs of the Devourer (Demon's Kiss)
	["127829.141277"] = 201455, -- Twinblades of the Deceiver (Critical Chaos)
	["128832.141277"] = 207347, -- The Aldrachi Warblades (Aura of Pain)
	["128943.141277"] = 211126, -- Skull of the Man'ari (Legionwrath)
	-- Vision of An'she
	["120978.141276"] = 184843, -- Ashbringer (Righteous Blade)
	["128825.141276"] = 196416, -- T'uure, Beacon of the Naaru (Serenity Now)
	["128868.141276"] = 197715, -- Light's Wrath (The Edge of Dark and Light)
	["128823.141276"] = 200315, -- The Silver Hand (Shock Treatment)
	["128866.141276"] = 209220, -- Truthguard (Unflinching Defense)
	-- Roiling Fog
	["128935.137313"] = 191577, -- The Fist of Ra-den (Electric Discharge)
	["128826.137313"] = 190529, -- Thas'dorah, Legacy of the Windrunners (Marked for Death)
	["128940.137313"] = 195291, -- Fists of the Heavens (Fists of the Wind)
	["128861.137313"] = 197162, -- Titanstrike (Jaws of Thunder)
	["128819.137313"] = 198349, -- Doomhammer (Gathering of the Maelstrom)
	["128937.137313"] = 199380, -- Sheilun, Staff of the Mists (Infusion of Life)
	["128908.137313"] = 200860, -- Warswords of the Valarjar (Unrivaled Strength)
	["128872.137313"] = 202530, -- The Dreadblades (Fortune Strikes)
	["128808.137313"] = 203670, -- Talonclaw, Spear of the Wild Gods (Explosive Force)
	["128938.137313"] = 213133, -- Fu Zan, the Wanderer's Companion (Healthy Appetite)
	-- Fertile Soil
	["128306.141275"] = 186320, -- G'Hanir, the Mother Tree (Grovewalker)
	["128826.141275"] = 190514, -- Thas'dorah, Legacy of the Windrunners (Survival of the Fittest)
	["128825.141275"] = 196355, -- T'uure, Beacon of the Naaru (Trust in the Light)
	["128937.141275"] = 199384, -- Sheilun, Staff of the Mists (Spirit Tether)
	["128821.141275"] = 200440, -- Claws of Ursoc (Vicious Bites)
	["128823.141275"] = 200302, -- The Silver Hand (Knight of the Silver Hand)
	["128858.141275"] = 203018, -- Scythe of Elune (Touch of the Moon)
	["128911.141275"] = 207354, -- Sharas'dal, Scepter of Tides (Caress of the Tidemother)
	["128860.141275"] = 210590, -- Fangs of Ashamane (Attuned to Nature)
	["128938.141275"] = 213116, -- Fu Zan, the Wanderer's Companion (Face Palm)
	-- Frozen Ley Scar
	["127857.141274"] = 187304, -- Aluneth, Greatstaff of the Magna (Torrential Barrage)
	["128292.141274"] = 189080, -- Blades of the Fallen Prince (Cold as Ice)
	["128306.141274"] = 189772, -- G'Hanir, the Mother Tree (Knowledge of the Ancients)
	["128935.141274"] = 191493, -- The Fist of Ra-den (Call the Thunder)
	["128862.141274"] = 195315, -- Ebonchill, Greatstaff of Alodi (Icy Caress)
	["128937.141274"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128911.141274"] = 207088, -- Sharas'dal, Scepter of Tides (Tidal Chains)
	["128860.141274"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	-- Echo of Eons
	["128292.141273"] = 189092, -- Blades of the Fallen Prince (Ambidexterity)
	["128403.141273"] = 191442, -- Apocalypse (Rotten Touch)
	["128402.141273"] = 192453, -- Maw of the Damned (Meat Shield)
	["128870.141273"] = 192315, -- The Kingslayers (Serrated Edge)
	["128827.141273"] = 193643, -- Xal'atath, Blade of the Black Empire (Mind Shattering)
	["128476.141273"] = 197233, -- Fangs of the Devourer (Demon's Kiss)
	["128868.141273"] = 197713, -- Light's Wrath (Pain is in Your Mind)
	["128942.141273"] = 199112, -- Ulthalesh, the Deadwind Harvester (Hideous Corruption)
	["127829.141273"] = 201455, -- Twinblades of the Deceiver (Critical Chaos)
	["128910.141273"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128943.141273"] = 211126, -- Skull of the Man'ari (Legionwrath)
	-- Mana-Saber Eye
	["127857.141272"] = 187301, -- Aluneth, Greatstaff of the Magna (Everywhere At Once)
	["128820.141272"] = 194318, -- Felo'melorn (Cauterizing Blink)
	["128862.141272"] = 195354, -- Ebonchill, Greatstaff of Alodi (Shield of Alodi)
	["128861.141272"] = 197160, -- Titanstrike (Mimiron's Shell)
	["128858.141272"] = 202302, -- Scythe of Elune (Bladed Feathers)
	["128866.141272"] = 209224, -- Truthguard (Resolve of Truth)
	["128832.141272"] = 212821, -- The Aldrachi Warblades (Devour Souls)
	-- Torch of Shaladrassil
	["120978.137316"] = 186945, -- Ashbringer (Wrath of the Ashbringer)
	["128289.137316"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128403.137316"] = 224466, -- Apocalypse (Runic Tattoos)
	["128820.137316"] = 210182, -- Felo'melorn (Blue Flame Special)
	["128941.137316"] = 196227, -- Scepter of Sargeras (Residual Flames)
	["128819.137316"] = 198292, -- Doomhammer (Wind Strikes)
	["128821.137316"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128908.137316"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128943.137316"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	-- Restless Dreams
	["128935.141270"] = 191569, -- The Fist of Ra-den (Protection of the Elements)
	["128826.141270"] = 190503, -- Thas'dorah, Legacy of the Windrunners (Healing Shell)
	["128940.141270"] = 195244, -- Fists of the Heavens (Light on Your Feet)
	["128861.141270"] = 197160, -- Titanstrike (Mimiron's Shell)
	["128819.141270"] = 198296, -- Doomhammer (Spiritual Healing)
	["128937.141270"] = 199365, -- Sheilun, Staff of the Mists (Shroud of Mist)
	["128908.141270"] = 200857, -- Warswords of the Valarjar (Battle Scars)
	["128872.141270"] = 202521, -- The Dreadblades (Fortune's Strike)
	["128808.141270"] = 224764, -- Talonclaw, Spear of the Wild Gods (Bird of Prey)
	["128938.141270"] = 213047, -- Fu Zan, the Wanderer's Companion (Potent Kick)
	-- Tranquil Clipping
	["128306.141269"] = 189757, -- G'Hanir, the Mother Tree (Infusion of Nature)
	["128826.141269"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128825.141269"] = 196418, -- T'uure, Beacon of the Naaru (Reverence)
	["128937.141269"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128821.141269"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128823.141269"] = 200296, -- The Silver Hand (Expel the Darkness)
	["128858.141269"] = 202433, -- Scythe of Elune (Scythe of the Stars)
	["128911.141269"] = 207206, -- Sharas'dal, Scepter of Tides (Wavecrash)
	["128860.141269"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	["128938.141269"] = 213062, -- Fu Zan, the Wanderer's Companion (Dark Side of the Moon)
	-- Xavius' Mad Whispers
	["128292.137317"] = 189164, -- Blades of the Fallen Prince (Dead of Winter)
	["128403.137317"] = 224466, -- Apocalypse (Runic Tattoos)
	["128402.137317"] = 192457, -- Maw of the Damned (Veinrender)
	["128870.137317"] = 192326, -- The Kingslayers (Balanced Blades)
	["128827.137317"] = 193645, -- Xal'atath, Blade of the Black Empire (Death's Embrace)
	["128476.137317"] = 197235, -- Fangs of the Devourer (Precision Strike)
	["128868.137317"] = 197716, -- Light's Wrath (Burst of Light)
	["128942.137317"] = 199152, -- Ulthalesh, the Deadwind Harvester (Inherently Unstable)
	["127829.137317"] = 201457, -- Twinblades of the Deceiver (Sharpened Glaives)
	["128910.137317"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128943.137317"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	-- Swordsinger's Counterweight
	["128289.141268"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128402.141268"] = 192450, -- Maw of the Damned (Iron Heart)
	["128870.141268"] = 192310, -- The Kingslayers (Toxic Blades)
	["128940.141268"] = 195243, -- Fists of the Heavens (Inner Peace)
	["128861.141268"] = 197038, -- Titanstrike (Wilderness Expert)
	["128819.141268"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128908.141268"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128872.141268"] = 216230, -- The Dreadblades (Black Powder)
	["128808.141268"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128832.141268"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128866.141268"] = 209229, -- Truthguard (Hammer Time)
	["128910.141268"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128938.141268"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Aspect of Disregard
	["127857.141267"] = 187287, -- Aluneth, Greatstaff of the Magna (Aegwynn's Fury)
	["128292.141267"] = 189097, -- Blades of the Fallen Prince (Over-Powered)
	["128306.141267"] = 189744, -- G'Hanir, the Mother Tree (Blessing of the World Tree)
	["128935.141267"] = 191598, -- The Fist of Ra-den (Earthen Attunement)
	["128862.141267"] = 195352, -- Ebonchill, Greatstaff of Alodi (The Storm Rages)
	["128937.141267"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128911.141267"] = 207348, -- Sharas'dal, Scepter of Tides (Floodwaters)
	["128860.141267"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	-- Manawracked Charm
	["127857.141266"] = 187313, -- Aluneth, Greatstaff of the Magna (Arcane Purification)
	["128820.141266"] = 194313, -- Felo'melorn (Great Balls of Fire)
	["128862.141266"] = 195345, -- Ebonchill, Greatstaff of Alodi (Frozen Veins)
	["128861.141266"] = 197140, -- Titanstrike (Spitting Cobras)
	["128858.141266"] = 202445, -- Scythe of Elune (Falling Star)
	["128866.141266"] = 209223, -- Truthguard (Scatter the Shadows)
	["128832.141266"] = 212816, -- The Aldrachi Warblades (Embrace the Pain)
	-- Gift of Flame
	["120978.141265"] = 184843, -- Ashbringer (Righteous Blade)
	["128289.141265"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128403.141265"] = 191485, -- Apocalypse (Plaguebearer)
	["128820.141265"] = 194312, -- Felo'melorn (Burning Gaze)
	["128941.141265"] = 196222, -- Scepter of Sargeras (Fire and the Flames)
	["128819.141265"] = 198247, -- Doomhammer (Wind Surge)
	["128821.141265"] = 208762, -- Claws of Ursoc (Mauler)
	["128908.141265"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128943.141265"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Bitestone Fury
	["128289.141264"] = 188632, -- Scale of the Earth-Warder (Toughness)
	["128403.141264"] = 191565, -- Apocalypse (Deadly Durability)
	["128402.141264"] = 192514, -- Maw of the Damned (Dance of Darkness)
	["128826.141264"] = 190503, -- Thas'dorah, Legacy of the Windrunners (Healing Shell)
	["128870.141264"] = 192323, -- The Kingslayers (Fade into Shadows)
	["128827.141264"] = 193642, -- Xal'atath, Blade of the Black Empire (From the Shadows)
	["128942.141264"] = 199212, -- Ulthalesh, the Deadwind Harvester (Shadows of the Flesh)
	["128821.141264"] = 200400, -- Claws of Ursoc (Wildflesh)
	["128872.141264"] = 202521, -- The Dreadblades (Fortune's Strike)
	["128808.141264"] = 224764, -- Talonclaw, Spear of the Wild Gods (Bird of Prey)
	["128910.141264"] = 209483, -- Strom'kar, the Warbreaker (Tactical Advance)
	["128860.141264"] = 210557, -- Fangs of Ashamane (Honed Instincts)
	-- Stonedark Idol
	["128289.141263"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128402.141263"] = 192460, -- Maw of the Damned (Coagulopathy)
	["128870.141263"] = 192329, -- The Kingslayers (Gushing Wound)
	["128940.141263"] = 195269, -- Fists of the Heavens (Power of a Thousand Cranes)
	["128861.141263"] = 197140, -- Titanstrike (Spitting Cobras)
	["128819.141263"] = 198299, -- Doomhammer (Gathering Storms)
	["128908.141263"] = 200856, -- Warswords of the Valarjar (Uncontrolled Rage)
	["128872.141263"] = 202524, -- The Dreadblades (Fatebringer)
	["128808.141263"] = 203669, -- Talonclaw, Spear of the Wild Gods (Fluffy, Go)
	["128866.141263"] = 209223, -- Truthguard (Scatter the Shadows)
	["128910.141263"] = 209481, -- Strom'kar, the Warbreaker (Deathblow)
	["128832.141263"] = 212816, -- The Aldrachi Warblades (Embrace the Pain)
	["128938.141263"] = 213055, -- Fu Zan, the Wanderer's Companion (Staggering Around)
	-- Rune-Etched Quill
	["128289.141262"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128402.141262"] = 192544, -- Maw of the Damned (Vampiric Fangs)
	["128870.141262"] = 192349, -- The Kingslayers (Master Assassin)
	["128940.141262"] = 195291, -- Fists of the Heavens (Fists of the Wind)
	["128861.141262"] = 197162, -- Titanstrike (Jaws of Thunder)
	["128819.141262"] = 198349, -- Doomhammer (Gathering of the Maelstrom)
	["128908.141262"] = 200860, -- Warswords of the Valarjar (Unrivaled Strength)
	["128872.141262"] = 202530, -- The Dreadblades (Fortune Strikes)
	["128808.141262"] = 203670, -- Talonclaw, Spear of the Wild Gods (Explosive Force)
	["128866.141262"] = 209218, -- Truthguard (Consecration in Flame)
	["128910.141262"] = 209492, -- Strom'kar, the Warbreaker (Precise Strikes)
	["128832.141262"] = 212817, -- The Aldrachi Warblades (Fiery Demise)
	["128938.141262"] = 213133, -- Fu Zan, the Wanderer's Companion (Healthy Appetite)
	-- Fires of Heaven
	["120978.141261"] = 186944, -- Ashbringer (Protector of the Ashen Blade)
	["128289.141261"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128820.141261"] = 194239, -- Felo'melorn (Pyroclasmic Paranoia)
	["128941.141261"] = 196258, -- Scepter of Sargeras (Fire From the Sky)
	["128819.141261"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128821.141261"] = 200415, -- Claws of Ursoc (Sharpened Instincts)
	["128908.141261"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128403.141261"] = 208598, -- Apocalypse (Eternal Agony)
	["128943.141261"] = 211099, -- Skull of the Man'ari (Maw of Shadows)
	-- Seawitch's Foci
	["127857.141259"] = 187276, -- Aluneth, Greatstaff of the Magna (Ethereal Sensitivity)
	["128820.141259"] = 194314, -- Felo'melorn (Everburning Consumption)
	["128862.141259"] = 195351, -- Ebonchill, Greatstaff of Alodi (Clarity of Thought)
	["128861.141259"] = 197162, -- Titanstrike (Jaws of Thunder)
	["128858.141259"] = 202466, -- Scythe of Elune (Sunfire Burns)
	["128866.141259"] = 209218, -- Truthguard (Consecration in Flame)
	["128832.141259"] = 212817, -- The Aldrachi Warblades (Fiery Demise)
	-- Promise of Rebirth
	["128306.141256"] = 189744, -- G'Hanir, the Mother Tree (Blessing of the World Tree)
	["128826.141256"] = 190567, -- Thas'dorah, Legacy of the Windrunners (Gust of Wind)
	["128825.141256"] = 196430, -- T'uure, Beacon of the Naaru (Words of Healing)
	["128937.141256"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128821.141256"] = 200415, -- Claws of Ursoc (Sharpened Instincts)
	["128858.141256"] = 202464, -- Scythe of Elune (Empowerment)
	["128911.141256"] = 207348, -- Sharas'dal, Scepter of Tides (Floodwaters)
	["128860.141256"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	["128823.141256"] = 200482, -- The Silver Hand (Second Sunrise)
	["128938.141256"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Mockery of Life
	["128941.141255"] = 196305, -- Scepter of Sargeras (Eternal Struggle)
	["128476.141255"] = 197244, -- Fangs of the Devourer (Ghost Armor)
	["127829.141255"] = 201463, -- Twinblades of the Deceiver (Deceiver's Fury)
	["128943.141255"] = 211131, -- Skull of the Man'ari (Firm Resolve)
	["128832.141255"] = 212827, -- The Aldrachi Warblades (Shatter the Souls)
	-- Mote of Fear
	["128292.141254"] = 189164, -- Blades of the Fallen Prince (Dead of Winter)
	["128403.141254"] = 224466, -- Apocalypse (Runic Tattoos)
	["128402.141254"] = 192457, -- Maw of the Damned (Veinrender)
	["128870.141254"] = 192326, -- The Kingslayers (Balanced Blades)
	["128827.141254"] = 193645, -- Xal'atath, Blade of the Black Empire (Death's Embrace)
	["128476.141254"] = 197235, -- Fangs of the Devourer (Precision Strike)
	["128868.141254"] = 197716, -- Light's Wrath (Burst of Light)
	["128942.141254"] = 199152, -- Ulthalesh, the Deadwind Harvester (Inherently Unstable)
	["127829.141254"] = 201457, -- Twinblades of the Deceiver (Sharpened Glaives)
	["128910.141254"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128943.141254"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	-- Fragmented Meteorite Whetstone
	["128289.137326"] = 188632, -- Scale of the Earth-Warder (Toughness)
	["128402.137326"] = 192514, -- Maw of the Damned (Dance of Darkness)
	["128870.137326"] = 192323, -- The Kingslayers (Fade into Shadows)
	["128940.137326"] = 195244, -- Fists of the Heavens (Light on Your Feet)
	["128861.137326"] = 197160, -- Titanstrike (Mimiron's Shell)
	["128819.137326"] = 198296, -- Doomhammer (Spiritual Healing)
	["128908.137326"] = 200857, -- Warswords of the Valarjar (Battle Scars)
	["128872.137326"] = 202521, -- The Dreadblades (Fortune's Strike)
	["128808.137326"] = 224764, -- Talonclaw, Spear of the Wild Gods (Bird of Prey)
	["128866.137326"] = 209224, -- Truthguard (Resolve of Truth)
	["128910.137326"] = 209483, -- Strom'kar, the Warbreaker (Tactical Advance)
	["128832.137326"] = 212821, -- The Aldrachi Warblades (Devour Souls)
	["128938.137326"] = 213047, -- Fu Zan, the Wanderer's Companion (Potent Kick)
	-- Relinquishing Grip of Helheim
	["128306.137327"] = 189754, -- G'Hanir, the Mother Tree (Armor of the Ancients)
	["128826.137327"] = 190520, -- Thas'dorah, Legacy of the Windrunners (Precision)
	["128825.137327"] = 196422, -- T'uure, Beacon of the Naaru (Holy Hands)
	["128937.137327"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128821.137327"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128823.137327"] = 200294, -- The Silver Hand (Deliver the Light)
	["128858.137327"] = 202445, -- Scythe of Elune (Falling Star)
	["128911.137327"] = 207255, -- Sharas'dal, Scepter of Tides (Empowered Droplets)
	["128860.137327"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	["128938.137327"] = 213055, -- Fu Zan, the Wanderer's Companion (Staggering Around)
	-- Quivering Blightshard Husk
	["128306.137339"] = 186320, -- G'Hanir, the Mother Tree (Grovewalker)
	["128826.137339"] = 190514, -- Thas'dorah, Legacy of the Windrunners (Survival of the Fittest)
	["128825.137339"] = 196355, -- T'uure, Beacon of the Naaru (Trust in the Light)
	["128937.137339"] = 199384, -- Sheilun, Staff of the Mists (Spirit Tether)
	["128821.137339"] = 200440, -- Claws of Ursoc (Vicious Bites)
	["128823.137339"] = 200302, -- The Silver Hand (Knight of the Silver Hand)
	["128858.137339"] = 203018, -- Scythe of Elune (Touch of the Moon)
	["128911.137339"] = 207354, -- Sharas'dal, Scepter of Tides (Caress of the Tidemother)
	["128860.137339"] = 210590, -- Fangs of Ashamane (Attuned to Nature)
	["128938.137339"] = 213116, -- Fu Zan, the Wanderer's Companion (Face Palm)
	-- Crystalline Energies
	["127857.137340"] = 187313, -- Aluneth, Greatstaff of the Magna (Arcane Purification)
	["128292.137340"] = 189144, -- Blades of the Fallen Prince (Nothing but the Boots)
	["128306.137340"] = 189754, -- G'Hanir, the Mother Tree (Armor of the Ancients)
	["128935.137340"] = 191572, -- The Fist of Ra-den (Molten Blast)
	["128862.137340"] = 195345, -- Ebonchill, Greatstaff of Alodi (Frozen Veins)
	["128937.137340"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128911.137340"] = 207255, -- Sharas'dal, Scepter of Tides (Empowered Droplets)
	["128860.137340"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	-- Reactive Intuition
	["127857.140412"] = 187287, -- Aluneth, Greatstaff of the Magna (Aegwynn's Fury)
	["128820.140412"] = 194239, -- Felo'melorn (Pyroclasmic Paranoia)
	["128862.140412"] = 195352, -- Ebonchill, Greatstaff of Alodi (The Storm Rages)
	["128858.140412"] = 202464, -- Scythe of Elune (Empowerment)
	["128861.140412"] = 206910, -- Titanstrike (Unleash the Beast)
	["128866.140412"] = 209216, -- Truthguard (Bastion of Truth)
	["128832.140412"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	-- Grisly Souvenir
	["128289.140413"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128403.140413"] = 191419, -- Apocalypse (Deadliest Coil)
	["128402.140413"] = 192450, -- Maw of the Damned (Iron Heart)
	["128826.140413"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128870.140413"] = 192310, -- The Kingslayers (Toxic Blades)
	["128827.140413"] = 194093, -- Xal'atath, Blade of the Black Empire (Unleash the Shadows)
	["128942.140413"] = 199111, -- Ulthalesh, the Deadwind Harvester (Inimitable Agony)
	["128821.140413"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128872.140413"] = 216230, -- The Dreadblades (Black Powder)
	["128808.140413"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128910.140413"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128860.140413"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	-- Murmuring Idol
	["120978.137346"] = 185368, -- Ashbringer (Might of the Templar)
	["128825.137346"] = 196429, -- T'uure, Beacon of the Naaru (Hallowed Ground)
	["128868.137346"] = 197729, -- Light's Wrath (Shield of Faith)
	["128823.137346"] = 200298, -- The Silver Hand (Blessings of the Silver Hand)
	["128866.137346"] = 209218, -- Truthguard (Consecration in Flame)
	-- Fragment of Loathing
	["128292.137347"] = 189080, -- Blades of the Fallen Prince (Cold as Ice)
	["128403.137347"] = 191419, -- Apocalypse (Deadliest Coil)
	["128402.137347"] = 192450, -- Maw of the Damned (Iron Heart)
	["128870.137347"] = 192310, -- The Kingslayers (Toxic Blades)
	["128827.137347"] = 194093, -- Xal'atath, Blade of the Black Empire (Unleash the Shadows)
	["128476.137347"] = 197231, -- Fangs of the Devourer (The Quiet Knife)
	["128868.137347"] = 197708, -- Light's Wrath (Confession)
	["128942.137347"] = 199111, -- Ulthalesh, the Deadwind Harvester (Inimitable Agony)
	["127829.137347"] = 201454, -- Twinblades of the Deceiver (Contained Fury)
	["128910.137347"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128943.137347"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Blindside Approach
	["128292.140419"] = 189080, -- Blades of the Fallen Prince (Cold as Ice)
	["128403.140419"] = 191419, -- Apocalypse (Deadliest Coil)
	["128402.140419"] = 192450, -- Maw of the Damned (Iron Heart)
	["128870.140419"] = 192310, -- The Kingslayers (Toxic Blades)
	["128827.140419"] = 194093, -- Xal'atath, Blade of the Black Empire (Unleash the Shadows)
	["128476.140419"] = 197231, -- Fangs of the Devourer (The Quiet Knife)
	["128868.140419"] = 197708, -- Light's Wrath (Confession)
	["128942.140419"] = 199111, -- Ulthalesh, the Deadwind Harvester (Inimitable Agony)
	["127829.140419"] = 201454, -- Twinblades of the Deceiver (Contained Fury)
	["128910.140419"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128943.140419"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Monstrous Gluttony
	["128289.137350"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128403.137350"] = 191419, -- Apocalypse (Deadliest Coil)
	["128402.137350"] = 192450, -- Maw of the Damned (Iron Heart)
	["128826.137350"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128870.137350"] = 192310, -- The Kingslayers (Toxic Blades)
	["128827.137350"] = 194093, -- Xal'atath, Blade of the Black Empire (Unleash the Shadows)
	["128942.137350"] = 199111, -- Ulthalesh, the Deadwind Harvester (Inimitable Agony)
	["128821.137350"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128872.137350"] = 216230, -- The Dreadblades (Black Powder)
	["128808.137350"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128910.137350"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128860.137350"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	-- Noxious Entrails
	["128941.137351"] = 196222, -- Scepter of Sargeras (Fire and the Flames)
	["128476.137351"] = 197234, -- Fangs of the Devourer (Gutripper)
	["127829.137351"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128832.137351"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128943.137351"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Performance Enhancing Curio
	["128941.140427"] = 196258, -- Scepter of Sargeras (Fire From the Sky)
	["128476.140427"] = 197239, -- Fangs of the Devourer (Energetic Stabbing)
	["127829.140427"] = 201464, -- Twinblades of the Deceiver (Overwhelming Power)
	["128943.140427"] = 211099, -- Skull of the Man'ari (Maw of Shadows)
	["128832.140427"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	-- Hate-Sculpted Magma
	["120978.137358"] = 186944, -- Ashbringer (Protector of the Ashen Blade)
	["128289.137358"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128820.137358"] = 194239, -- Felo'melorn (Pyroclasmic Paranoia)
	["128941.137358"] = 196258, -- Scepter of Sargeras (Fire From the Sky)
	["128819.137358"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128821.137358"] = 200415, -- Claws of Ursoc (Sharpened Instincts)
	["128908.137358"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128403.137358"] = 208598, -- Apocalypse (Eternal Agony)
	["128943.137358"] = 211099, -- Skull of the Man'ari (Maw of Shadows)
	-- Pebble of Ages
	["128289.137359"] = 216272, -- Scale of the Earth-Warder (Rage of the Fallen)
	["128402.137359"] = 192453, -- Maw of the Damned (Meat Shield)
	["128870.137359"] = 192315, -- The Kingslayers (Serrated Edge)
	["128940.137359"] = 195263, -- Fists of the Heavens (Rising Winds)
	["128861.137359"] = 197047, -- Titanstrike (Furious Swipes)
	["128819.137359"] = 198236, -- Doomhammer (Forged in Lava)
	["128908.137359"] = 216273, -- Warswords of the Valarjar (Wild Slashes)
	["128872.137359"] = 202507, -- The Dreadblades (Blade Dancer)
	["128808.137359"] = 203577, -- Talonclaw, Spear of the Wild Gods (My Beloved Monster)
	["128832.137359"] = 207347, -- The Aldrachi Warblades (Aura of Pain)
	["128866.137359"] = 209217, -- Truthguard (Stern Judgment)
	["128910.137359"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128938.137359"] = 227687, -- Fu Zan, the Wanderer's Companion (Hot Blooded)
	-- Cold Sweat
	["127857.140432"] = 187287, -- Aluneth, Greatstaff of the Magna (Aegwynn's Fury)
	["128292.140432"] = 189097, -- Blades of the Fallen Prince (Over-Powered)
	["128306.140432"] = 189744, -- G'Hanir, the Mother Tree (Blessing of the World Tree)
	["128935.140432"] = 191598, -- The Fist of Ra-den (Earthen Attunement)
	["128862.140432"] = 195352, -- Ebonchill, Greatstaff of Alodi (The Storm Rages)
	["128937.140432"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128911.140432"] = 207348, -- Sharas'dal, Scepter of Tides (Floodwaters)
	["128860.140432"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	-- Brilliant Sunstone
	["120978.140433"] = 186944, -- Ashbringer (Protector of the Ashen Blade)
	["128825.140433"] = 196430, -- T'uure, Beacon of the Naaru (Words of Healing)
	["128868.140433"] = 197762, -- Light's Wrath (Borrowed Time)
	["128866.140433"] = 209216, -- Truthguard (Bastion of Truth)
	["128823.140433"] = 200482, -- The Silver Hand (Second Sunrise)
	-- Bloodied Spearhead
	["128289.137363"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128402.137363"] = 192464, -- Maw of the Damned (All-Consuming Rot)
	["128826.137363"] = 190567, -- Thas'dorah, Legacy of the Windrunners (Gust of Wind)
	["128870.137363"] = 192376, -- The Kingslayers (Poison Knives)
	["128827.137363"] = 194002, -- Xal'atath, Blade of the Black Empire (Creeping Shadows)
	["128942.137363"] = 199163, -- Ulthalesh, the Deadwind Harvester (Shadowy Incantations)
	["128821.137363"] = 200415, -- Claws of Ursoc (Sharpened Instincts)
	["128872.137363"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.137363"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128403.137363"] = 208598, -- Apocalypse (Eternal Agony)
	["128910.137363"] = 209494, -- Strom'kar, the Warbreaker (Exploit the Weakness)
	["128860.137363"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	-- Steadfast Conviction
	["128289.140436"] = 188632, -- Scale of the Earth-Warder (Toughness)
	["128402.140436"] = 192514, -- Maw of the Damned (Dance of Darkness)
	["128870.140436"] = 192323, -- The Kingslayers (Fade into Shadows)
	["128940.140436"] = 195244, -- Fists of the Heavens (Light on Your Feet)
	["128861.140436"] = 197160, -- Titanstrike (Mimiron's Shell)
	["128819.140436"] = 198296, -- Doomhammer (Spiritual Healing)
	["128908.140436"] = 200857, -- Warswords of the Valarjar (Battle Scars)
	["128872.140436"] = 202521, -- The Dreadblades (Fortune's Strike)
	["128808.140436"] = 224764, -- Talonclaw, Spear of the Wild Gods (Bird of Prey)
	["128866.140436"] = 209224, -- Truthguard (Resolve of Truth)
	["128910.140436"] = 209483, -- Strom'kar, the Warbreaker (Tactical Advance)
	["128832.140436"] = 212821, -- The Aldrachi Warblades (Devour Souls)
	["128938.140436"] = 213047, -- Fu Zan, the Wanderer's Companion (Potent Kick)
	-- Condensed Saltsea Globule
	["128935.137365"] = 191504, -- The Fist of Ra-den (Lava Imbued)
	["128826.137365"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128940.137365"] = 218607, -- Fists of the Heavens (Tiger Claws)
	["128861.137365"] = 197080, -- Titanstrike (Pack Leader)
	["128819.137365"] = 198247, -- Doomhammer (Wind Surge)
	["128937.137365"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128908.137365"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128872.137365"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.137365"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128938.137365"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Gift of the Ocean Empress
	["120978.137366"] = 184759, -- Ashbringer (Sharpened Edge)
	["128825.137366"] = 196358, -- T'uure, Beacon of the Naaru (Say Your Prayers)
	["128868.137366"] = 197713, -- Light's Wrath (Pain is in Your Mind)
	["128823.137366"] = 200316, -- The Silver Hand (Justice through Sacrifice)
	["128866.137366"] = 209217, -- Truthguard (Stern Judgment)
	-- Polished Shadowstone
	["128292.140440"] = 189164, -- Blades of the Fallen Prince (Dead of Winter)
	["128403.140440"] = 224466, -- Apocalypse (Runic Tattoos)
	["128402.140440"] = 192457, -- Maw of the Damned (Veinrender)
	["128870.140440"] = 192326, -- The Kingslayers (Balanced Blades)
	["128827.140440"] = 193645, -- Xal'atath, Blade of the Black Empire (Death's Embrace)
	["128476.140440"] = 197235, -- Fangs of the Devourer (Precision Strike)
	["128868.140440"] = 197716, -- Light's Wrath (Burst of Light)
	["128942.140440"] = 199152, -- Ulthalesh, the Deadwind Harvester (Inherently Unstable)
	["127829.140440"] = 201457, -- Twinblades of the Deceiver (Sharpened Glaives)
	["128910.140440"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128943.140440"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	-- Dead Man's Tale
	["128292.140441"] = 189154, -- Blades of the Fallen Prince (Ice in Your Veins)
	["128403.140441"] = 191565, -- Apocalypse (Deadly Durability)
	["128402.140441"] = 192514, -- Maw of the Damned (Dance of Darkness)
	["128870.140441"] = 192323, -- The Kingslayers (Fade into Shadows)
	["128827.140441"] = 193642, -- Xal'atath, Blade of the Black Empire (From the Shadows)
	["128476.140441"] = 210147, -- Fangs of the Devourer (Catlike Reflexes)
	["128868.140441"] = 197711, -- Light's Wrath (Vestments of Discipline)
	["128942.140441"] = 199212, -- Ulthalesh, the Deadwind Harvester (Shadows of the Flesh)
	["127829.140441"] = 201459, -- Twinblades of the Deceiver (Illidari Knowledge)
	["128910.140441"] = 209483, -- Strom'kar, the Warbreaker (Tactical Advance)
	["128943.140441"] = 211144, -- Skull of the Man'ari (Open Link)
	-- Heart of the Sea
	["127857.137370"] = 187264, -- Aluneth, Greatstaff of the Magna (Aegwynn's Imperative)
	["128292.137370"] = 189164, -- Blades of the Fallen Prince (Dead of Winter)
	["128306.137370"] = 189757, -- G'Hanir, the Mother Tree (Infusion of Nature)
	["128935.137370"] = 191740, -- The Fist of Ra-den (Firestorm)
	["128862.137370"] = 195323, -- Ebonchill, Greatstaff of Alodi (Orbital Strike)
	["128937.137370"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128911.137370"] = 207206, -- Sharas'dal, Scepter of Tides (Wavecrash)
	["128860.137370"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	-- Thundering Impact
	["128935.140442"] = 191740, -- The Fist of Ra-den (Firestorm)
	["128826.140442"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128940.140442"] = 195266, -- Fists of the Heavens (Death Art)
	["128861.140442"] = 197139, -- Titanstrike (Focus of the Titans)
	["128819.140442"] = 198292, -- Doomhammer (Wind Strikes)
	["128937.140442"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128908.140442"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128872.140442"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.140442"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128938.140442"] = 213062, -- Fu Zan, the Wanderer's Companion (Dark Side of the Moon)
	-- Tumultuous Aftershock
	["128289.137371"] = 188644, -- Scale of the Earth-Warder (Thunder Crash)
	["128402.137371"] = 192538, -- Maw of the Damned (Bonebreaker)
	["128870.137371"] = 192345, -- The Kingslayers (Shadow Walker)
	["128940.137371"] = 195380, -- Fists of the Heavens (Healing Winds)
	["128861.137371"] = 197138, -- Titanstrike (Natural Reflexes)
	["128819.137371"] = 198248, -- Doomhammer (Elemental Healing)
	["128908.137371"] = 200859, -- Warswords of the Valarjar (Bloodcraze)
	["128872.137371"] = 202533, -- The Dreadblades (Ghostly Shell)
	["128808.137371"] = 203749, -- Talonclaw, Spear of the Wild Gods (Hunter's Bounty)
	["128866.137371"] = 211912, -- Truthguard (Faith's Armor)
	["128910.137371"] = 209541, -- Strom'kar, the Warbreaker (Touch of Zakajz)
	["128832.137371"] = 212827, -- The Aldrachi Warblades (Shatter the Souls)
	["128938.137371"] = 213116, -- Fu Zan, the Wanderer's Companion (Face Palm)
	-- Roar of the Crowd
	["128935.140443"] = 191577, -- The Fist of Ra-den (Electric Discharge)
	["128826.140443"] = 190529, -- Thas'dorah, Legacy of the Windrunners (Marked for Death)
	["128940.140443"] = 195291, -- Fists of the Heavens (Fists of the Wind)
	["128861.140443"] = 197162, -- Titanstrike (Jaws of Thunder)
	["128819.140443"] = 198349, -- Doomhammer (Gathering of the Maelstrom)
	["128937.140443"] = 199380, -- Sheilun, Staff of the Mists (Infusion of Life)
	["128908.140443"] = 200860, -- Warswords of the Valarjar (Unrivaled Strength)
	["128872.140443"] = 202530, -- The Dreadblades (Fortune Strikes)
	["128808.140443"] = 203670, -- Talonclaw, Spear of the Wild Gods (Explosive Force)
	["128938.140443"] = 213133, -- Fu Zan, the Wanderer's Companion (Healthy Appetite)
	-- Blazing Hydra Flame Sac
	["120978.137375"] = 186934, -- Ashbringer (Embrace the Light)
	["128289.137375"] = 188632, -- Scale of the Earth-Warder (Toughness)
	["128403.137375"] = 191565, -- Apocalypse (Deadly Durability)
	["128820.137375"] = 194318, -- Felo'melorn (Cauterizing Blink)
	["128941.137375"] = 196301, -- Scepter of Sargeras (Devourer of Life)
	["128819.137375"] = 198296, -- Doomhammer (Spiritual Healing)
	["128821.137375"] = 200400, -- Claws of Ursoc (Wildflesh)
	["128908.137375"] = 200857, -- Warswords of the Valarjar (Battle Scars)
	["128943.137375"] = 211144, -- Skull of the Man'ari (Open Link)
	-- Serpentrix's Guile
	["128292.137377"] = 189097, -- Blades of the Fallen Prince (Over-Powered)
	["128402.137377"] = 192464, -- Maw of the Damned (All-Consuming Rot)
	["128870.137377"] = 192376, -- The Kingslayers (Poison Knives)
	["128827.137377"] = 194002, -- Xal'atath, Blade of the Black Empire (Creeping Shadows)
	["128476.137377"] = 197239, -- Fangs of the Devourer (Energetic Stabbing)
	["128868.137377"] = 197762, -- Light's Wrath (Borrowed Time)
	["128942.137377"] = 199163, -- Ulthalesh, the Deadwind Harvester (Shadowy Incantations)
	["127829.137377"] = 201464, -- Twinblades of the Deceiver (Overwhelming Power)
	["128403.137377"] = 208598, -- Apocalypse (Eternal Agony)
	["128910.137377"] = 209494, -- Strom'kar, the Warbreaker (Exploit the Weakness)
	["128943.137377"] = 211099, -- Skull of the Man'ari (Maw of Shadows)
	-- Tempestbinder's Crystal
	["127857.137379"] = 187258, -- Aluneth, Greatstaff of the Magna (Blasting Rod)
	["128820.137379"] = 194234, -- Felo'melorn (Reignition Overdrive)
	["128862.137379"] = 195317, -- Ebonchill, Greatstaff of Alodi (Ice Age)
	["128861.137379"] = 197047, -- Titanstrike (Furious Swipes)
	["128858.137379"] = 202386, -- Scythe of Elune (Twilight Glow)
	["128832.137379"] = 207347, -- The Aldrachi Warblades (Aura of Pain)
	["128866.137379"] = 209217, -- Truthguard (Stern Judgment)
	-- Rage of the Tides
	["127857.137380"] = 187276, -- Aluneth, Greatstaff of the Magna (Ethereal Sensitivity)
	["128292.137380"] = 189147, -- Blades of the Fallen Prince (Bad to the Bone)
	["128306.137380"] = 189749, -- G'Hanir, the Mother Tree (Natural Mending)
	["128935.137380"] = 191577, -- The Fist of Ra-den (Electric Discharge)
	["128862.137380"] = 195351, -- Ebonchill, Greatstaff of Alodi (Clarity of Thought)
	["128937.137380"] = 199380, -- Sheilun, Staff of the Mists (Infusion of Life)
	["128911.137380"] = 207285, -- Sharas'dal, Scepter of Tides (Queen Ascendant)
	["128860.137380"] = 210637, -- Fangs of Ashamane (Sharpened Claws)
	-- Pact of Vengeful Service
	["128306.137381"] = 189749, -- G'Hanir, the Mother Tree (Natural Mending)
	["128826.137381"] = 190529, -- Thas'dorah, Legacy of the Windrunners (Marked for Death)
	["128825.137381"] = 196429, -- T'uure, Beacon of the Naaru (Hallowed Ground)
	["128937.137381"] = 199380, -- Sheilun, Staff of the Mists (Infusion of Life)
	["128821.137381"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128823.137381"] = 200298, -- The Silver Hand (Blessings of the Silver Hand)
	["128858.137381"] = 202466, -- Scythe of Elune (Sunfire Burns)
	["128911.137381"] = 207285, -- Sharas'dal, Scepter of Tides (Queen Ascendant)
	["128860.137381"] = 210637, -- Fangs of Ashamane (Sharpened Claws)
	["128938.137381"] = 213133, -- Fu Zan, the Wanderer's Companion (Healthy Appetite)
	-- Cleansed Shrine Relic
	["120978.132279"] = 184843, -- Ashbringer (Righteous Blade)
	["128825.132279"] = 196416, -- T'uure, Beacon of the Naaru (Serenity Now)
	["128868.132279"] = 197715, -- Light's Wrath (The Edge of Dark and Light)
	["128823.132279"] = 200315, -- The Silver Hand (Shock Treatment)
	["128866.132279"] = 209220, -- Truthguard (Unflinching Defense)
	-- Ivanyr's Hunger
	["128292.137399"] = 189144, -- Blades of the Fallen Prince (Nothing but the Boots)
	["128403.137399"] = 191494, -- Apocalypse (Scourge the Unbeliever)
	["128402.137399"] = 192460, -- Maw of the Damned (Coagulopathy)
	["128870.137399"] = 192329, -- The Kingslayers (Gushing Wound)
	["128827.137399"] = 194007, -- Xal'atath, Blade of the Black Empire (Touch of Darkness)
	["128476.137399"] = 197369, -- Fangs of the Devourer (Fortune's Bite)
	["128868.137399"] = 197727, -- Light's Wrath (Doomsayer)
	["128942.137399"] = 199153, -- Ulthalesh, the Deadwind Harvester (Seeds of Doom)
	["127829.137399"] = 201458, -- Twinblades of the Deceiver (Demon Rage)
	["128910.137399"] = 209481, -- Strom'kar, the Warbreaker (Deathblow)
	["128943.137399"] = 211105, -- Skull of the Man'ari (Dirty Hands)
	-- Lost Priestess' Loop
	["120978.132280"] = 185368, -- Ashbringer (Might of the Templar)
	["128825.132280"] = 196429, -- T'uure, Beacon of the Naaru (Hallowed Ground)
	["128868.132280"] = 197729, -- Light's Wrath (Shield of Faith)
	["128823.132280"] = 200298, -- The Silver Hand (Blessings of the Silver Hand)
	["128866.132280"] = 209218, -- Truthguard (Consecration in Flame)
	-- Lunarwing Crystal
	["127857.132281"] = 187321, -- Aluneth, Greatstaff of the Magna (Aegwynn's Wrath)
	["128820.132281"] = 194312, -- Felo'melorn (Burning Gaze)
	["128862.132281"] = 195322, -- Ebonchill, Greatstaff of Alodi (Let It Go)
	["128861.132281"] = 197080, -- Titanstrike (Pack Leader)
	["128858.132281"] = 202426, -- Scythe of Elune (Solar Stabbing)
	["128832.132281"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128866.132281"] = 209220, -- Truthguard (Unflinching Defense)
	-- Enchanted Pool Garnet
	["127857.132282"] = 187276, -- Aluneth, Greatstaff of the Magna (Ethereal Sensitivity)
	["128820.132282"] = 194314, -- Felo'melorn (Everburning Consumption)
	["128862.132282"] = 195351, -- Ebonchill, Greatstaff of Alodi (Clarity of Thought)
	["128861.132282"] = 197162, -- Titanstrike (Jaws of Thunder)
	["128858.132282"] = 202466, -- Scythe of Elune (Sunfire Burns)
	["128866.132282"] = 209218, -- Truthguard (Consecration in Flame)
	["128832.132282"] = 212817, -- The Aldrachi Warblades (Fiery Demise)
	-- Cleansing Isotope
	["120978.137402"] = 184778, -- Ashbringer (Deflection)
	["128825.137402"] = 196355, -- T'uure, Beacon of the Naaru (Trust in the Light)
	["128868.137402"] = 216212, -- Light's Wrath (Darkest Shadows)
	["128823.137402"] = 200302, -- The Silver Hand (Knight of the Silver Hand)
	["128866.137402"] = 211912, -- Truthguard (Faith's Armor)
	-- Uncorrupted Val Blood
	["128289.132283"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128403.132283"] = 191485, -- Apocalypse (Plaguebearer)
	["128402.132283"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128826.132283"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128870.132283"] = 192318, -- The Kingslayers (Master Alchemist)
	["128827.132283"] = 193644, -- Xal'atath, Blade of the Black Empire (To the Pain)
	["128942.132283"] = 199120, -- Ulthalesh, the Deadwind Harvester (Drained to a Husk)
	["128821.132283"] = 208762, -- Claws of Ursoc (Mauler)
	["128872.132283"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.132283"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128910.132283"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128860.132283"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	-- Quarantine Catalyst
	["127857.137403"] = 187301, -- Aluneth, Greatstaff of the Magna (Everywhere At Once)
	["128292.137403"] = 189154, -- Blades of the Fallen Prince (Ice in Your Veins)
	["128306.137403"] = 186396, -- G'Hanir, the Mother Tree (Persistence)
	["128935.137403"] = 191569, -- The Fist of Ra-den (Protection of the Elements)
	["128862.137403"] = 195354, -- Ebonchill, Greatstaff of Alodi (Shield of Alodi)
	["128937.137403"] = 199365, -- Sheilun, Staff of the Mists (Shroud of Mist)
	["128911.137403"] = 207351, -- Sharas'dal, Scepter of Tides (Ghost in the Mist)
	["128860.137403"] = 210557, -- Fangs of Ashamane (Honed Instincts)
	-- Preserved Blood-Stained Claw
	["128289.132284"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128403.132284"] = 191488, -- Apocalypse (The Darkest Crusade)
	["128402.132284"] = 192544, -- Maw of the Damned (Vampiric Fangs)
	["128826.132284"] = 190529, -- Thas'dorah, Legacy of the Windrunners (Marked for Death)
	["128870.132284"] = 192349, -- The Kingslayers (Master Assassin)
	["128827.132284"] = 194016, -- Xal'atath, Blade of the Black Empire (Void Corruption)
	["128942.132284"] = 199158, -- Ulthalesh, the Deadwind Harvester (Perdition)
	["128821.132284"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128872.132284"] = 202530, -- The Dreadblades (Fortune Strikes)
	["128808.132284"] = 203670, -- Talonclaw, Spear of the Wild Gods (Explosive Force)
	["128910.132284"] = 209492, -- Strom'kar, the Warbreaker (Precise Strikes)
	["128860.132284"] = 210637, -- Fangs of Ashamane (Sharpened Claws)
	-- Small Nightmare Totem
	["128941.132285"] = 196222, -- Scepter of Sargeras (Fire and the Flames)
	["128476.132285"] = 197234, -- Fangs of the Devourer (Gutripper)
	["127829.132285"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128832.132285"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128943.132285"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Felshroom
	["128941.132286"] = 196432, -- Scepter of Sargeras (Burning Hunger)
	["128476.132286"] = 197386, -- Fangs of the Devourer (Soul Shadows)
	["127829.132286"] = 201460, -- Twinblades of the Deceiver (Unleashed Demons)
	["128943.132286"] = 211119, -- Skull of the Man'ari (Infernal Furnace)
	["128832.132286"] = 212817, -- The Aldrachi Warblades (Fiery Demise)
	-- Firewater Essence
	["120978.132287"] = 184843, -- Ashbringer (Righteous Blade)
	["128289.132287"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128403.132287"] = 191485, -- Apocalypse (Plaguebearer)
	["128820.132287"] = 194312, -- Felo'melorn (Burning Gaze)
	["128941.132287"] = 196222, -- Scepter of Sargeras (Fire and the Flames)
	["128819.132287"] = 198247, -- Doomhammer (Wind Surge)
	["128821.132287"] = 208762, -- Claws of Ursoc (Mauler)
	["128908.132287"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128943.132287"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Sealed Fel Fissure
	["128941.137407"] = 196217, -- Scepter of Sargeras (Chaotic Instability)
	["128476.137407"] = 197233, -- Fangs of the Devourer (Demon's Kiss)
	["127829.137407"] = 201455, -- Twinblades of the Deceiver (Critical Chaos)
	["128832.137407"] = 207347, -- The Aldrachi Warblades (Aura of Pain)
	["128943.137407"] = 211126, -- Skull of the Man'ari (Legionwrath)
	-- Trickster's Everburning Flames
	["120978.132288"] = 185368, -- Ashbringer (Might of the Templar)
	["128289.132288"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128403.132288"] = 191488, -- Apocalypse (The Darkest Crusade)
	["128820.132288"] = 194314, -- Felo'melorn (Everburning Consumption)
	["128941.132288"] = 196432, -- Scepter of Sargeras (Burning Hunger)
	["128819.132288"] = 198349, -- Doomhammer (Gathering of the Maelstrom)
	["128821.132288"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128908.132288"] = 200860, -- Warswords of the Valarjar (Unrivaled Strength)
	["128943.132288"] = 211119, -- Skull of the Man'ari (Infernal Furnace)
	-- Xakal's Determination
	["128289.137408"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128402.137408"] = 192450, -- Maw of the Damned (Iron Heart)
	["128870.137408"] = 192310, -- The Kingslayers (Toxic Blades)
	["128940.137408"] = 195243, -- Fists of the Heavens (Inner Peace)
	["128861.137408"] = 197038, -- Titanstrike (Wilderness Expert)
	["128819.137408"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128908.137408"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128872.137408"] = 216230, -- The Dreadblades (Black Powder)
	["128808.137408"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128832.137408"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128866.137408"] = 209229, -- Truthguard (Hammer Time)
	["128910.137408"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128938.137408"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Vale Shadow Frost
	["127857.132289"] = 187321, -- Aluneth, Greatstaff of the Magna (Aegwynn's Wrath)
	["128292.132289"] = 189086, -- Blades of the Fallen Prince (Blast Radius)
	["128306.132289"] = 189760, -- G'Hanir, the Mother Tree (Essence of Nordrassil)
	["128935.132289"] = 191504, -- The Fist of Ra-den (Lava Imbued)
	["128862.132289"] = 195322, -- Ebonchill, Greatstaff of Alodi (Let It Go)
	["128937.132289"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128911.132289"] = 210029, -- Sharas'dal, Scepter of Tides (Pull of the Sea)
	["128860.132289"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	-- Frozen Moss of the Den
	["127857.132290"] = 187276, -- Aluneth, Greatstaff of the Magna (Ethereal Sensitivity)
	["128292.132290"] = 189147, -- Blades of the Fallen Prince (Bad to the Bone)
	["128306.132290"] = 189749, -- G'Hanir, the Mother Tree (Natural Mending)
	["128935.132290"] = 191577, -- The Fist of Ra-den (Electric Discharge)
	["128862.132290"] = 195351, -- Ebonchill, Greatstaff of Alodi (Clarity of Thought)
	["128937.132290"] = 199380, -- Sheilun, Staff of the Mists (Infusion of Life)
	["128911.132290"] = 207285, -- Sharas'dal, Scepter of Tides (Queen Ascendant)
	["128860.132290"] = 210637, -- Fangs of Ashamane (Sharpened Claws)
	-- Nal'tira's Venom Gland
	["128306.137411"] = 189760, -- G'Hanir, the Mother Tree (Essence of Nordrassil)
	["128826.137411"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128825.137411"] = 196416, -- T'uure, Beacon of the Naaru (Serenity Now)
	["128937.137411"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128821.137411"] = 208762, -- Claws of Ursoc (Mauler)
	["128823.137411"] = 200315, -- The Silver Hand (Shock Treatment)
	["128858.137411"] = 202426, -- Scythe of Elune (Solar Stabbing)
	["128911.137411"] = 210029, -- Sharas'dal, Scepter of Tides (Pull of the Sea)
	["128860.137411"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	["128938.137411"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Fistful of Eyes
	["128289.137412"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128403.137412"] = 191494, -- Apocalypse (Scourge the Unbeliever)
	["128402.137412"] = 192460, -- Maw of the Damned (Coagulopathy)
	["128826.137412"] = 190520, -- Thas'dorah, Legacy of the Windrunners (Precision)
	["128870.137412"] = 192329, -- The Kingslayers (Gushing Wound)
	["128827.137412"] = 194007, -- Xal'atath, Blade of the Black Empire (Touch of Darkness)
	["128942.137412"] = 199153, -- Ulthalesh, the Deadwind Harvester (Seeds of Doom)
	["128821.137412"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128872.137412"] = 202524, -- The Dreadblades (Fatebringer)
	["128808.137412"] = 203669, -- Talonclaw, Spear of the Wild Gods (Fluffy, Go)
	["128910.137412"] = 209481, -- Strom'kar, the Warbreaker (Deathblow)
	["128860.137412"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	-- Stone of the Dream Den
	["128289.132294"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128402.132294"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128870.132294"] = 192318, -- The Kingslayers (Master Alchemist)
	["128940.132294"] = 218607, -- Fists of the Heavens (Tiger Claws)
	["128861.132294"] = 197080, -- Titanstrike (Pack Leader)
	["128819.132294"] = 198247, -- Doomhammer (Wind Surge)
	["128908.132294"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128872.132294"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.132294"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128832.132294"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128866.132294"] = 209220, -- Truthguard (Unflinching Defense)
	["128910.132294"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128938.132294"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Petrified Ancient Bark
	["128289.132295"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128402.132295"] = 192544, -- Maw of the Damned (Vampiric Fangs)
	["128870.132295"] = 192349, -- The Kingslayers (Master Assassin)
	["128940.132295"] = 195291, -- Fists of the Heavens (Fists of the Wind)
	["128861.132295"] = 197162, -- Titanstrike (Jaws of Thunder)
	["128819.132295"] = 198349, -- Doomhammer (Gathering of the Maelstrom)
	["128908.132295"] = 200860, -- Warswords of the Valarjar (Unrivaled Strength)
	["128872.132295"] = 202530, -- The Dreadblades (Fortune Strikes)
	["128808.132295"] = 203670, -- Talonclaw, Spear of the Wild Gods (Explosive Force)
	["128866.132295"] = 209218, -- Truthguard (Consecration in Flame)
	["128910.132295"] = 209492, -- Strom'kar, the Warbreaker (Precise Strikes)
	["128832.132295"] = 212817, -- The Aldrachi Warblades (Fiery Demise)
	["128938.132295"] = 213133, -- Fu Zan, the Wanderer's Companion (Healthy Appetite)
	-- Val'sharah Seed Pods
	["128306.132296"] = 189760, -- G'Hanir, the Mother Tree (Essence of Nordrassil)
	["128826.132296"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128825.132296"] = 196416, -- T'uure, Beacon of the Naaru (Serenity Now)
	["128937.132296"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128821.132296"] = 208762, -- Claws of Ursoc (Mauler)
	["128823.132296"] = 200315, -- The Silver Hand (Shock Treatment)
	["128858.132296"] = 202426, -- Scythe of Elune (Solar Stabbing)
	["128911.132296"] = 210029, -- Sharas'dal, Scepter of Tides (Pull of the Sea)
	["128860.132296"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	["128938.132296"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Everblooming Flower
	["128306.132297"] = 189749, -- G'Hanir, the Mother Tree (Natural Mending)
	["128826.132297"] = 190529, -- Thas'dorah, Legacy of the Windrunners (Marked for Death)
	["128825.132297"] = 196429, -- T'uure, Beacon of the Naaru (Hallowed Ground)
	["128937.132297"] = 199380, -- Sheilun, Staff of the Mists (Infusion of Life)
	["128821.132297"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128823.132297"] = 200298, -- The Silver Hand (Blessings of the Silver Hand)
	["128858.132297"] = 202466, -- Scythe of Elune (Sunfire Burns)
	["128911.132297"] = 207285, -- Sharas'dal, Scepter of Tides (Queen Ascendant)
	["128860.132297"] = 210637, -- Fangs of Ashamane (Sharpened Claws)
	["128938.132297"] = 213133, -- Fu Zan, the Wanderer's Companion (Healthy Appetite)
	-- Nightmare Cave Moss
	["128292.132298"] = 189086, -- Blades of the Fallen Prince (Blast Radius)
	["128403.132298"] = 191485, -- Apocalypse (Plaguebearer)
	["128402.132298"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128870.132298"] = 192318, -- The Kingslayers (Master Alchemist)
	["128827.132298"] = 193644, -- Xal'atath, Blade of the Black Empire (To the Pain)
	["128476.132298"] = 197234, -- Fangs of the Devourer (Gutripper)
	["128868.132298"] = 197715, -- Light's Wrath (The Edge of Dark and Light)
	["128942.132298"] = 199120, -- Ulthalesh, the Deadwind Harvester (Drained to a Husk)
	["127829.132298"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128910.132298"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128943.132298"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Satyr's Nightmare Fetish
	["128292.132299"] = 189147, -- Blades of the Fallen Prince (Bad to the Bone)
	["128403.132299"] = 191488, -- Apocalypse (The Darkest Crusade)
	["128402.132299"] = 192544, -- Maw of the Damned (Vampiric Fangs)
	["128870.132299"] = 192349, -- The Kingslayers (Master Assassin)
	["128827.132299"] = 194016, -- Xal'atath, Blade of the Black Empire (Void Corruption)
	["128476.132299"] = 197386, -- Fangs of the Devourer (Soul Shadows)
	["128868.132299"] = 197729, -- Light's Wrath (Shield of Faith)
	["128942.132299"] = 199158, -- Ulthalesh, the Deadwind Harvester (Perdition)
	["127829.132299"] = 201460, -- Twinblades of the Deceiver (Unleashed Demons)
	["128910.132299"] = 209492, -- Strom'kar, the Warbreaker (Precise Strikes)
	["128943.132299"] = 211119, -- Skull of the Man'ari (Infernal Furnace)
	-- Firewater Infusion
	-- Split Second
	["127857.137420"] = 187304, -- Aluneth, Greatstaff of the Magna (Torrential Barrage)
	["128820.137420"] = 194224, -- Felo'melorn (Fire at Will)
	["128862.137420"] = 195315, -- Ebonchill, Greatstaff of Alodi (Icy Caress)
	["128861.137420"] = 197038, -- Titanstrike (Wilderness Expert)
	["128858.137420"] = 202384, -- Scythe of Elune (Dark Side of the Moon)
	["128832.137420"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128866.137420"] = 209229, -- Truthguard (Hammer Time)
	-- Vial of Pure Vale Water
	-- Accelerating Torrent
	["128935.137421"] = 191598, -- The Fist of Ra-den (Earthen Attunement)
	["128826.137421"] = 190567, -- Thas'dorah, Legacy of the Windrunners (Gust of Wind)
	["128819.137421"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128937.137421"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128908.137421"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128872.137421"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.137421"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128940.137421"] = 195267, -- Fists of the Heavens (Strength of Xuen)
	["128861.137421"] = 206910, -- Titanstrike (Unleash the Beast)
	["128938.137421"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Rustling of the Forest
	["128935.132302"] = 191504, -- The Fist of Ra-den (Lava Imbued)
	["128826.132302"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128940.132302"] = 218607, -- Fists of the Heavens (Tiger Claws)
	["128861.132302"] = 197080, -- Titanstrike (Pack Leader)
	["128819.132302"] = 198247, -- Doomhammer (Wind Surge)
	["128937.132302"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128908.132302"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128872.132302"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.132302"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128938.132302"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Drugon's Snowglobe
	["127857.141517"] = 187287, -- Aluneth, Greatstaff of the Magna (Aegwynn's Fury)
	["128292.141517"] = 189097, -- Blades of the Fallen Prince (Over-Powered)
	["128306.141517"] = 189744, -- G'Hanir, the Mother Tree (Blessing of the World Tree)
	["128935.141517"] = 191598, -- The Fist of Ra-den (Earthen Attunement)
	["128862.141517"] = 195352, -- Ebonchill, Greatstaff of Alodi (The Storm Rages)
	["128937.141517"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128911.141517"] = 207348, -- Sharas'dal, Scepter of Tides (Floodwaters)
	["128860.141517"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	-- Enchanted Stoneblood Feather
	["128935.132303"] = 191577, -- The Fist of Ra-den (Electric Discharge)
	["128826.132303"] = 190529, -- Thas'dorah, Legacy of the Windrunners (Marked for Death)
	["128940.132303"] = 195291, -- Fists of the Heavens (Fists of the Wind)
	["128861.132303"] = 197162, -- Titanstrike (Jaws of Thunder)
	["128819.132303"] = 198349, -- Doomhammer (Gathering of the Maelstrom)
	["128937.132303"] = 199380, -- Sheilun, Staff of the Mists (Infusion of Life)
	["128908.132303"] = 200860, -- Warswords of the Valarjar (Unrivaled Strength)
	["128872.132303"] = 202530, -- The Dreadblades (Fortune Strikes)
	["128808.132303"] = 203670, -- Talonclaw, Spear of the Wild Gods (Explosive Force)
	["128938.132303"] = 213133, -- Fu Zan, the Wanderer's Companion (Healthy Appetite)
	-- Decaying Dragonfang
	["128292.141518"] = 189092, -- Blades of the Fallen Prince (Ambidexterity)
	["128403.141518"] = 191442, -- Apocalypse (Rotten Touch)
	["128402.141518"] = 192453, -- Maw of the Damned (Meat Shield)
	["128870.141518"] = 192315, -- The Kingslayers (Serrated Edge)
	["128827.141518"] = 193643, -- Xal'atath, Blade of the Black Empire (Mind Shattering)
	["128476.141518"] = 197233, -- Fangs of the Devourer (Demon's Kiss)
	["128868.141518"] = 197713, -- Light's Wrath (Pain is in Your Mind)
	["128942.141518"] = 199112, -- Ulthalesh, the Deadwind Harvester (Hideous Corruption)
	["127829.141518"] = 201455, -- Twinblades of the Deceiver (Critical Chaos)
	["128910.141518"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128943.141518"] = 211126, -- Skull of the Man'ari (Legionwrath)
	-- Elothir's Sympathy
	["127857.132305"] = 187258, -- Aluneth, Greatstaff of the Magna (Blasting Rod)
	["128820.132305"] = 194234, -- Felo'melorn (Reignition Overdrive)
	["128862.132305"] = 195317, -- Ebonchill, Greatstaff of Alodi (Ice Age)
	["128861.132305"] = 197047, -- Titanstrike (Furious Swipes)
	["128858.132305"] = 202386, -- Scythe of Elune (Twilight Glow)
	["128832.132305"] = 207347, -- The Aldrachi Warblades (Aura of Pain)
	["128866.132305"] = 209217, -- Truthguard (Stern Judgment)
	-- Varethos' Fortitude
	["128289.132306"] = 216272, -- Scale of the Earth-Warder (Rage of the Fallen)
	["128403.132306"] = 191442, -- Apocalypse (Rotten Touch)
	["128402.132306"] = 192453, -- Maw of the Damned (Meat Shield)
	["128826.132306"] = 190457, -- Thas'dorah, Legacy of the Windrunners (Windrunner's Guidance)
	["128870.132306"] = 192315, -- The Kingslayers (Serrated Edge)
	["128827.132306"] = 193643, -- Xal'atath, Blade of the Black Empire (Mind Shattering)
	["128942.132306"] = 199112, -- Ulthalesh, the Deadwind Harvester (Hideous Corruption)
	["128821.132306"] = 200399, -- Claws of Ursoc (Ursoc's Endurance)
	["128872.132306"] = 202507, -- The Dreadblades (Blade Dancer)
	["128808.132306"] = 203577, -- Talonclaw, Spear of the Wild Gods (My Beloved Monster)
	["128910.132306"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128860.132306"] = 210571, -- Fangs of Ashamane (Feral Power)
	-- Sea Giant Toothpick Fragment
	["128289.141521"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128402.141521"] = 192457, -- Maw of the Damned (Veinrender)
	["128870.141521"] = 192326, -- The Kingslayers (Balanced Blades)
	["128940.141521"] = 195266, -- Fists of the Heavens (Death Art)
	["128861.141521"] = 197139, -- Titanstrike (Focus of the Titans)
	["128819.141521"] = 198292, -- Doomhammer (Wind Strikes)
	["128908.141521"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128872.141521"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.141521"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128866.141521"] = 209226, -- Truthguard (Righteous Crusader)
	["128910.141521"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128832.141521"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	["128938.141521"] = 213062, -- Fu Zan, the Wanderer's Companion (Dark Side of the Moon)
	-- Twisted Branch of Shaladrassil
	["128941.132307"] = 196217, -- Scepter of Sargeras (Chaotic Instability)
	["128476.132307"] = 197233, -- Fangs of the Devourer (Demon's Kiss)
	["127829.132307"] = 201455, -- Twinblades of the Deceiver (Critical Chaos)
	["128832.132307"] = 207347, -- The Aldrachi Warblades (Aura of Pain)
	["128943.132307"] = 211126, -- Skull of the Man'ari (Legionwrath)
	-- Calamir's Jaw
	["120978.141522"] = 186927, -- Ashbringer (Deliver the Justice)
	["128289.141522"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128403.141522"] = 191494, -- Apocalypse (Scourge the Unbeliever)
	["128820.141522"] = 194313, -- Felo'melorn (Great Balls of Fire)
	["128941.141522"] = 196236, -- Scepter of Sargeras (Soulsnatcher)
	["128819.141522"] = 198299, -- Doomhammer (Gathering Storms)
	["128821.141522"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128908.141522"] = 200856, -- Warswords of the Valarjar (Uncontrolled Rage)
	["128943.141522"] = 211105, -- Skull of the Man'ari (Dirty Hands)
	-- Shaladrassil's Anger
	["120978.132308"] = 184759, -- Ashbringer (Sharpened Edge)
	["128289.132308"] = 216272, -- Scale of the Earth-Warder (Rage of the Fallen)
	["128403.132308"] = 191442, -- Apocalypse (Rotten Touch)
	["128820.132308"] = 194234, -- Felo'melorn (Reignition Overdrive)
	["128941.132308"] = 196217, -- Scepter of Sargeras (Chaotic Instability)
	["128819.132308"] = 198236, -- Doomhammer (Forged in Lava)
	["128821.132308"] = 200399, -- Claws of Ursoc (Ursoc's Endurance)
	["128908.132308"] = 216273, -- Warswords of the Valarjar (Wild Slashes)
	["128943.132308"] = 211126, -- Skull of the Man'ari (Legionwrath)
	-- Fel-Scented Bait
	["128289.141523"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128403.141523"] = 191488, -- Apocalypse (The Darkest Crusade)
	["128402.141523"] = 192544, -- Maw of the Damned (Vampiric Fangs)
	["128826.141523"] = 190529, -- Thas'dorah, Legacy of the Windrunners (Marked for Death)
	["128870.141523"] = 192349, -- The Kingslayers (Master Assassin)
	["128827.141523"] = 194016, -- Xal'atath, Blade of the Black Empire (Void Corruption)
	["128942.141523"] = 199158, -- Ulthalesh, the Deadwind Harvester (Perdition)
	["128821.141523"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128872.141523"] = 202530, -- The Dreadblades (Fortune Strikes)
	["128808.141523"] = 203670, -- Talonclaw, Spear of the Wild Gods (Explosive Force)
	["128910.141523"] = 209492, -- Strom'kar, the Warbreaker (Precise Strikes)
	["128860.141523"] = 210637, -- Fangs of Ashamane (Sharpened Claws)
	-- Rimed Worldtree Blossom
	["127857.132309"] = 187258, -- Aluneth, Greatstaff of the Magna (Blasting Rod)
	["128292.132309"] = 189092, -- Blades of the Fallen Prince (Ambidexterity)
	["128306.132309"] = 189768, -- G'Hanir, the Mother Tree (Seeds of the World Tree)
	["128935.132309"] = 191499, -- The Fist of Ra-den (The Ground Trembles)
	["128862.132309"] = 195317, -- Ebonchill, Greatstaff of Alodi (Ice Age)
	["128937.132309"] = 199366, -- Sheilun, Staff of the Mists (Way of the Mistweaver)
	["128911.132309"] = 207092, -- Sharas'dal, Scepter of Tides (Buffeting Waves)
	["128860.132309"] = 210571, -- Fangs of Ashamane (Feral Power)
	-- Uncorrupted Soil
	["128289.132310"] = 216272, -- Scale of the Earth-Warder (Rage of the Fallen)
	["128402.132310"] = 192453, -- Maw of the Damned (Meat Shield)
	["128870.132310"] = 192315, -- The Kingslayers (Serrated Edge)
	["128940.132310"] = 195263, -- Fists of the Heavens (Rising Winds)
	["128861.132310"] = 197047, -- Titanstrike (Furious Swipes)
	["128819.132310"] = 198236, -- Doomhammer (Forged in Lava)
	["128908.132310"] = 216273, -- Warswords of the Valarjar (Wild Slashes)
	["128872.132310"] = 202507, -- The Dreadblades (Blade Dancer)
	["128808.132310"] = 203577, -- Talonclaw, Spear of the Wild Gods (My Beloved Monster)
	["128832.132310"] = 207347, -- The Aldrachi Warblades (Aura of Pain)
	["128866.132310"] = 209217, -- Truthguard (Stern Judgment)
	["128910.132310"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128938.132310"] = 227687, -- Fu Zan, the Wanderer's Companion (Hot Blooded)
	-- Blossom of Promise
	["128306.132311"] = 189768, -- G'Hanir, the Mother Tree (Seeds of the World Tree)
	["128826.132311"] = 190457, -- Thas'dorah, Legacy of the Windrunners (Windrunner's Guidance)
	["128825.132311"] = 196358, -- T'uure, Beacon of the Naaru (Say Your Prayers)
	["128937.132311"] = 199366, -- Sheilun, Staff of the Mists (Way of the Mistweaver)
	["128821.132311"] = 200399, -- Claws of Ursoc (Ursoc's Endurance)
	["128823.132311"] = 200316, -- The Silver Hand (Justice through Sacrifice)
	["128858.132311"] = 202386, -- Scythe of Elune (Twilight Glow)
	["128911.132311"] = 207092, -- Sharas'dal, Scepter of Tides (Buffeting Waves)
	["128860.132311"] = 210571, -- Fangs of Ashamane (Feral Power)
	["128938.132311"] = 227687, -- Fu Zan, the Wanderer's Companion (Hot Blooded)
	-- Twisted Nightmare Totem
	["128292.132312"] = 189092, -- Blades of the Fallen Prince (Ambidexterity)
	["128403.132312"] = 191442, -- Apocalypse (Rotten Touch)
	["128402.132312"] = 192453, -- Maw of the Damned (Meat Shield)
	["128870.132312"] = 192315, -- The Kingslayers (Serrated Edge)
	["128827.132312"] = 193643, -- Xal'atath, Blade of the Black Empire (Mind Shattering)
	["128476.132312"] = 197233, -- Fangs of the Devourer (Demon's Kiss)
	["128868.132312"] = 197713, -- Light's Wrath (Pain is in Your Mind)
	["128942.132312"] = 199112, -- Ulthalesh, the Deadwind Harvester (Hideous Corruption)
	["127829.132312"] = 201455, -- Twinblades of the Deceiver (Critical Chaos)
	["128910.132312"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128943.132312"] = 211126, -- Skull of the Man'ari (Legionwrath)
	-- Moonrest Dewdrop
	-- Desiccated Breeze
	["128935.132314"] = 191499, -- The Fist of Ra-den (The Ground Trembles)
	["128826.132314"] = 190457, -- Thas'dorah, Legacy of the Windrunners (Windrunner's Guidance)
	["128940.132314"] = 195263, -- Fists of the Heavens (Rising Winds)
	["128861.132314"] = 197047, -- Titanstrike (Furious Swipes)
	["128819.132314"] = 198236, -- Doomhammer (Forged in Lava)
	["128937.132314"] = 199366, -- Sheilun, Staff of the Mists (Way of the Mistweaver)
	["128908.132314"] = 216273, -- Warswords of the Valarjar (Wild Slashes)
	["128872.132314"] = 202507, -- The Dreadblades (Blade Dancer)
	["128808.132314"] = 203577, -- Talonclaw, Spear of the Wild Gods (My Beloved Monster)
	["128938.132314"] = 227687, -- Fu Zan, the Wanderer's Companion (Hot Blooded)
	-- Mana-Fused Seedling
	["127857.132316"] = 187287, -- Aluneth, Greatstaff of the Magna (Aegwynn's Fury)
	["128820.132316"] = 194239, -- Felo'melorn (Pyroclasmic Paranoia)
	["128862.132316"] = 195352, -- Ebonchill, Greatstaff of Alodi (The Storm Rages)
	["128858.132316"] = 202464, -- Scythe of Elune (Empowerment)
	["128861.132316"] = 206910, -- Titanstrike (Unleash the Beast)
	["128866.132316"] = 209216, -- Truthguard (Bastion of Truth)
	["128832.132316"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	-- Sap of the Worldtree
	["128289.132317"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128402.132317"] = 192464, -- Maw of the Damned (All-Consuming Rot)
	["128826.132317"] = 190567, -- Thas'dorah, Legacy of the Windrunners (Gust of Wind)
	["128870.132317"] = 192376, -- The Kingslayers (Poison Knives)
	["128827.132317"] = 194002, -- Xal'atath, Blade of the Black Empire (Creeping Shadows)
	["128942.132317"] = 199163, -- Ulthalesh, the Deadwind Harvester (Shadowy Incantations)
	["128821.132317"] = 200415, -- Claws of Ursoc (Sharpened Instincts)
	["128872.132317"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.132317"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128403.132317"] = 208598, -- Apocalypse (Eternal Agony)
	["128910.132317"] = 209494, -- Strom'kar, the Warbreaker (Exploit the Weakness)
	["128860.132317"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	-- Corrupted Grovewalker Core
	["128941.132318"] = 196258, -- Scepter of Sargeras (Fire From the Sky)
	["128476.132318"] = 197239, -- Fangs of the Devourer (Energetic Stabbing)
	["127829.132318"] = 201464, -- Twinblades of the Deceiver (Overwhelming Power)
	["128943.132318"] = 211099, -- Skull of the Man'ari (Maw of Shadows)
	["128832.132318"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	-- Charred Imp Claw
	["120978.132319"] = 186944, -- Ashbringer (Protector of the Ashen Blade)
	["128289.132319"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128820.132319"] = 194239, -- Felo'melorn (Pyroclasmic Paranoia)
	["128941.132319"] = 196258, -- Scepter of Sargeras (Fire From the Sky)
	["128819.132319"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128821.132319"] = 200415, -- Claws of Ursoc (Sharpened Instincts)
	["128908.132319"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128403.132319"] = 208598, -- Apocalypse (Eternal Agony)
	["128943.132319"] = 211099, -- Skull of the Man'ari (Maw of Shadows)
	-- Varethos' Frozen Heart
	["127857.132320"] = 187287, -- Aluneth, Greatstaff of the Magna (Aegwynn's Fury)
	["128292.132320"] = 189097, -- Blades of the Fallen Prince (Over-Powered)
	["128306.132320"] = 189744, -- G'Hanir, the Mother Tree (Blessing of the World Tree)
	["128935.132320"] = 191598, -- The Fist of Ra-den (Earthen Attunement)
	["128862.132320"] = 195352, -- Ebonchill, Greatstaff of Alodi (The Storm Rages)
	["128937.132320"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128911.132320"] = 207348, -- Sharas'dal, Scepter of Tides (Floodwaters)
	["128860.132320"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	-- Petrified Ancient Branch
	["128289.132321"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128402.132321"] = 192464, -- Maw of the Damned (All-Consuming Rot)
	["128870.132321"] = 192376, -- The Kingslayers (Poison Knives)
	["128819.132321"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128908.132321"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128872.132321"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.132321"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128940.132321"] = 195267, -- Fists of the Heavens (Strength of Xuen)
	["128861.132321"] = 206910, -- Titanstrike (Unleash the Beast)
	["128866.132321"] = 209216, -- Truthguard (Bastion of Truth)
	["128910.132321"] = 209494, -- Strom'kar, the Warbreaker (Exploit the Weakness)
	["128832.132321"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	["128938.132321"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Lifelink to Elothir
	["128306.132322"] = 189744, -- G'Hanir, the Mother Tree (Blessing of the World Tree)
	["128826.132322"] = 190567, -- Thas'dorah, Legacy of the Windrunners (Gust of Wind)
	["128825.132322"] = 196430, -- T'uure, Beacon of the Naaru (Words of Healing)
	["128937.132322"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128821.132322"] = 200415, -- Claws of Ursoc (Sharpened Instincts)
	["128858.132322"] = 202464, -- Scythe of Elune (Empowerment)
	["128911.132322"] = 207348, -- Sharas'dal, Scepter of Tides (Floodwaters)
	["128860.132322"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	["128823.132322"] = 200482, -- The Silver Hand (Second Sunrise)
	["128938.132322"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Varethos' Last Breath
	["128292.132323"] = 189097, -- Blades of the Fallen Prince (Over-Powered)
	["128402.132323"] = 192464, -- Maw of the Damned (All-Consuming Rot)
	["128870.132323"] = 192376, -- The Kingslayers (Poison Knives)
	["128827.132323"] = 194002, -- Xal'atath, Blade of the Black Empire (Creeping Shadows)
	["128476.132323"] = 197239, -- Fangs of the Devourer (Energetic Stabbing)
	["128868.132323"] = 197762, -- Light's Wrath (Borrowed Time)
	["128942.132323"] = 199163, -- Ulthalesh, the Deadwind Harvester (Shadowy Incantations)
	["127829.132323"] = 201464, -- Twinblades of the Deceiver (Overwhelming Power)
	["128403.132323"] = 208598, -- Apocalypse (Eternal Agony)
	["128910.132323"] = 209494, -- Strom'kar, the Warbreaker (Exploit the Weakness)
	["128943.132323"] = 211099, -- Skull of the Man'ari (Maw of Shadows)
	-- Purged Decanter
	-- Nightmare Zephyr
	["128935.132325"] = 191598, -- The Fist of Ra-den (Earthen Attunement)
	["128826.132325"] = 190567, -- Thas'dorah, Legacy of the Windrunners (Gust of Wind)
	["128819.132325"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128937.132325"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128908.132325"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128872.132325"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.132325"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128940.132325"] = 195267, -- Fists of the Heavens (Strength of Xuen)
	["128861.132325"] = 206910, -- Titanstrike (Unleash the Beast)
	["128938.132325"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Blessed Cup of the Moon
	["120978.132334"] = 186941, -- Ashbringer (Highlord's Judgment)
	["128825.132334"] = 196434, -- T'uure, Beacon of the Naaru (Holy Guidance)
	["128868.132334"] = 197708, -- Light's Wrath (Confession)
	["128823.132334"] = 200326, -- The Silver Hand (Focused Healing)
	["128866.132334"] = 209229, -- Truthguard (Hammer Time)
	-- Tower Magi's Eye
	["127857.132335"] = 187304, -- Aluneth, Greatstaff of the Magna (Torrential Barrage)
	["128820.132335"] = 194224, -- Felo'melorn (Fire at Will)
	["128862.132335"] = 195315, -- Ebonchill, Greatstaff of Alodi (Icy Caress)
	["128861.132335"] = 197038, -- Titanstrike (Wilderness Expert)
	["128858.132335"] = 202384, -- Scythe of Elune (Dark Side of the Moon)
	["128832.132335"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128866.132335"] = 209229, -- Truthguard (Hammer Time)
	-- The Jailer's Cat Tail
	["128289.132336"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128403.132336"] = 191419, -- Apocalypse (Deadliest Coil)
	["128402.132336"] = 192450, -- Maw of the Damned (Iron Heart)
	["128826.132336"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128870.132336"] = 192310, -- The Kingslayers (Toxic Blades)
	["128827.132336"] = 194093, -- Xal'atath, Blade of the Black Empire (Unleash the Shadows)
	["128942.132336"] = 199111, -- Ulthalesh, the Deadwind Harvester (Inimitable Agony)
	["128821.132336"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128872.132336"] = 216230, -- The Dreadblades (Black Powder)
	["128808.132336"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128910.132336"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128860.132336"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	-- Araxxas's Badge
	["128941.132337"] = 196211, -- Scepter of Sargeras (Master of Disaster)
	["128476.132337"] = 197231, -- Fangs of the Devourer (The Quiet Knife)
	["127829.132337"] = 201454, -- Twinblades of the Deceiver (Contained Fury)
	["128832.132337"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128943.132337"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Everflame Arrowhead
	["120978.132338"] = 186941, -- Ashbringer (Highlord's Judgment)
	["128289.132338"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128403.132338"] = 191419, -- Apocalypse (Deadliest Coil)
	["128820.132338"] = 194224, -- Felo'melorn (Fire at Will)
	["128941.132338"] = 196211, -- Scepter of Sargeras (Master of Disaster)
	["128819.132338"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128821.132338"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128908.132338"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128943.132338"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Death's Chill Mirror Shard
	["127857.132339"] = 187304, -- Aluneth, Greatstaff of the Magna (Torrential Barrage)
	["128292.132339"] = 189080, -- Blades of the Fallen Prince (Cold as Ice)
	["128306.132339"] = 189772, -- G'Hanir, the Mother Tree (Knowledge of the Ancients)
	["128935.132339"] = 191493, -- The Fist of Ra-den (Call the Thunder)
	["128862.132339"] = 195315, -- Ebonchill, Greatstaff of Alodi (Icy Caress)
	["128937.132339"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128911.132339"] = 207088, -- Sharas'dal, Scepter of Tides (Tidal Chains)
	["128860.132339"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	-- Rook Fired Ore
	["128289.132340"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128402.132340"] = 192450, -- Maw of the Damned (Iron Heart)
	["128870.132340"] = 192310, -- The Kingslayers (Toxic Blades)
	["128940.132340"] = 195243, -- Fists of the Heavens (Inner Peace)
	["128861.132340"] = 197038, -- Titanstrike (Wilderness Expert)
	["128819.132340"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128908.132340"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128872.132340"] = 216230, -- The Dreadblades (Black Powder)
	["128808.132340"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128832.132340"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128866.132340"] = 209229, -- Truthguard (Hammer Time)
	["128910.132340"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128938.132340"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Nourishmoss
	["128306.132341"] = 189772, -- G'Hanir, the Mother Tree (Knowledge of the Ancients)
	["128826.132341"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128825.132341"] = 196434, -- T'uure, Beacon of the Naaru (Holy Guidance)
	["128937.132341"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128821.132341"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128823.132341"] = 200326, -- The Silver Hand (Focused Healing)
	["128858.132341"] = 202384, -- Scythe of Elune (Dark Side of the Moon)
	["128911.132341"] = 207088, -- Sharas'dal, Scepter of Tides (Tidal Chains)
	["128860.132341"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	["128938.132341"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Vial of Dormant Shadowswarm
	["128292.132342"] = 189080, -- Blades of the Fallen Prince (Cold as Ice)
	["128403.132342"] = 191419, -- Apocalypse (Deadliest Coil)
	["128402.132342"] = 192450, -- Maw of the Damned (Iron Heart)
	["128870.132342"] = 192310, -- The Kingslayers (Toxic Blades)
	["128827.132342"] = 194093, -- Xal'atath, Blade of the Black Empire (Unleash the Shadows)
	["128476.132342"] = 197231, -- Fangs of the Devourer (The Quiet Knife)
	["128868.132342"] = 197708, -- Light's Wrath (Confession)
	["128942.132342"] = 199111, -- Ulthalesh, the Deadwind Harvester (Inimitable Agony)
	["127829.132342"] = 201454, -- Twinblades of the Deceiver (Contained Fury)
	["128910.132342"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128943.132342"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Last Drops of Uncorrupted Water
	-- Fealty of Nerub
	["128292.137463"] = 189086, -- Blades of the Fallen Prince (Blast Radius)
	["128403.137463"] = 191485, -- Apocalypse (Plaguebearer)
	["128402.137463"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128870.137463"] = 192318, -- The Kingslayers (Master Alchemist)
	["128827.137463"] = 193644, -- Xal'atath, Blade of the Black Empire (To the Pain)
	["128476.137463"] = 197234, -- Fangs of the Devourer (Gutripper)
	["128868.137463"] = 197715, -- Light's Wrath (The Edge of Dark and Light)
	["128942.137463"] = 199120, -- Ulthalesh, the Deadwind Harvester (Drained to a Husk)
	["127829.137463"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128910.137463"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128943.137463"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Guile of the Hold's Sky Terrors
	["128935.132344"] = 191493, -- The Fist of Ra-den (Call the Thunder)
	["128826.132344"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128940.132344"] = 195243, -- Fists of the Heavens (Inner Peace)
	["128861.132344"] = 197038, -- Titanstrike (Wilderness Expert)
	["128819.132344"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128937.132344"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128908.132344"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128872.132344"] = 216230, -- The Dreadblades (Black Powder)
	["128808.132344"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128938.132344"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Tendril of Darkness
	["128292.137464"] = 189154, -- Blades of the Fallen Prince (Ice in Your Veins)
	["128403.137464"] = 191565, -- Apocalypse (Deadly Durability)
	["128402.137464"] = 192514, -- Maw of the Damned (Dance of Darkness)
	["128870.137464"] = 192323, -- The Kingslayers (Fade into Shadows)
	["128827.137464"] = 193642, -- Xal'atath, Blade of the Black Empire (From the Shadows)
	["128476.137464"] = 210147, -- Fangs of the Devourer (Catlike Reflexes)
	["128868.137464"] = 197711, -- Light's Wrath (Vestments of Discipline)
	["128942.137464"] = 199212, -- Ulthalesh, the Deadwind Harvester (Shadows of the Flesh)
	["127829.137464"] = 201459, -- Twinblades of the Deceiver (Illidari Knowledge)
	["128910.137464"] = 209483, -- Strom'kar, the Warbreaker (Tactical Advance)
	["128943.137464"] = 211144, -- Skull of the Man'ari (Open Link)
	-- Elune Graced Signet
	["120978.132345"] = 186945, -- Ashbringer (Wrath of the Ashbringer)
	["128825.132345"] = 196418, -- T'uure, Beacon of the Naaru (Reverence)
	["128868.132345"] = 197716, -- Light's Wrath (Burst of Light)
	["128823.132345"] = 200296, -- The Silver Hand (Expel the Darkness)
	["128866.132345"] = 209226, -- Truthguard (Righteous Crusader)
	-- Festerface's Rotted Gut
	["128289.137465"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128403.137465"] = 224466, -- Apocalypse (Runic Tattoos)
	["128402.137465"] = 192457, -- Maw of the Damned (Veinrender)
	["128826.137465"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128870.137465"] = 192326, -- The Kingslayers (Balanced Blades)
	["128827.137465"] = 193645, -- Xal'atath, Blade of the Black Empire (Death's Embrace)
	["128942.137465"] = 199152, -- Ulthalesh, the Deadwind Harvester (Inherently Unstable)
	["128821.137465"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128872.137465"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.137465"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128910.137465"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128860.137465"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	-- Small Highborne Figurine
	["127857.132346"] = 187264, -- Aluneth, Greatstaff of the Magna (Aegwynn's Imperative)
	["128820.132346"] = 210182, -- Felo'melorn (Blue Flame Special)
	["128862.132346"] = 195323, -- Ebonchill, Greatstaff of Alodi (Orbital Strike)
	["128861.132346"] = 197139, -- Titanstrike (Focus of the Titans)
	["128858.132346"] = 202433, -- Scythe of Elune (Scythe of the Stars)
	["128866.132346"] = 209226, -- Truthguard (Righteous Crusader)
	["128832.132346"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	-- Frostwyrm Heart
	["127857.137466"] = 187287, -- Aluneth, Greatstaff of the Magna (Aegwynn's Fury)
	["128292.137466"] = 189097, -- Blades of the Fallen Prince (Over-Powered)
	["128306.137466"] = 189744, -- G'Hanir, the Mother Tree (Blessing of the World Tree)
	["128935.137466"] = 191598, -- The Fist of Ra-den (Earthen Attunement)
	["128862.137466"] = 195352, -- Ebonchill, Greatstaff of Alodi (The Storm Rages)
	["128937.137466"] = 199485, -- Sheilun, Staff of the Mists (Essence of the Mists)
	["128911.137466"] = 207348, -- Sharas'dal, Scepter of Tides (Floodwaters)
	["128860.137466"] = 210631, -- Fangs of Ashamane (Feral Instinct)
	-- The Interrogator's Vial
	["128289.132347"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128403.132347"] = 224466, -- Apocalypse (Runic Tattoos)
	["128402.132347"] = 192457, -- Maw of the Damned (Veinrender)
	["128826.132347"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128870.132347"] = 192326, -- The Kingslayers (Balanced Blades)
	["128827.132347"] = 193645, -- Xal'atath, Blade of the Black Empire (Death's Embrace)
	["128942.132347"] = 199152, -- Ulthalesh, the Deadwind Harvester (Inherently Unstable)
	["128821.132347"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128872.132347"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.132347"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128910.132347"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128860.132347"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	-- Gul'dan's Commission
	["128941.132348"] = 196227, -- Scepter of Sargeras (Residual Flames)
	["128476.132348"] = 197235, -- Fangs of the Devourer (Precision Strike)
	["127829.132348"] = 201457, -- Twinblades of the Deceiver (Sharpened Glaives)
	["128943.132348"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	["128832.132348"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	-- Bonecrushing Hail
	["128935.137468"] = 191569, -- The Fist of Ra-den (Protection of the Elements)
	["128826.137468"] = 190503, -- Thas'dorah, Legacy of the Windrunners (Healing Shell)
	["128940.137468"] = 195244, -- Fists of the Heavens (Light on Your Feet)
	["128861.137468"] = 197160, -- Titanstrike (Mimiron's Shell)
	["128819.137468"] = 198296, -- Doomhammer (Spiritual Healing)
	["128937.137468"] = 199365, -- Sheilun, Staff of the Mists (Shroud of Mist)
	["128908.137468"] = 200857, -- Warswords of the Valarjar (Battle Scars)
	["128872.137468"] = 202521, -- The Dreadblades (Fortune's Strike)
	["128808.137468"] = 224764, -- Talonclaw, Spear of the Wild Gods (Bird of Prey)
	["128938.137468"] = 213047, -- Fu Zan, the Wanderer's Companion (Potent Kick)
	-- Inquisitor's Fire-Brand Tip
	["120978.132349"] = 186945, -- Ashbringer (Wrath of the Ashbringer)
	["128289.132349"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128403.132349"] = 224466, -- Apocalypse (Runic Tattoos)
	["128820.132349"] = 210182, -- Felo'melorn (Blue Flame Special)
	["128941.132349"] = 196227, -- Scepter of Sargeras (Residual Flames)
	["128819.132349"] = 198292, -- Doomhammer (Wind Strikes)
	["128821.132349"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128908.132349"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128943.132349"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	-- Thorium-Plated Egg
	["128289.137469"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128402.137469"] = 192464, -- Maw of the Damned (All-Consuming Rot)
	["128870.137469"] = 192376, -- The Kingslayers (Poison Knives)
	["128819.137469"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128908.137469"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128872.137469"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.137469"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128940.137469"] = 195267, -- Fists of the Heavens (Strength of Xuen)
	["128861.137469"] = 206910, -- Titanstrike (Unleash the Beast)
	["128866.137469"] = 209216, -- Truthguard (Bastion of Truth)
	["128910.137469"] = 209494, -- Strom'kar, the Warbreaker (Exploit the Weakness)
	["128832.137469"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	["128938.137469"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Defiant Frozen Fist
	["127857.132350"] = 187264, -- Aluneth, Greatstaff of the Magna (Aegwynn's Imperative)
	["128292.132350"] = 189164, -- Blades of the Fallen Prince (Dead of Winter)
	["128306.132350"] = 189757, -- G'Hanir, the Mother Tree (Infusion of Nature)
	["128935.132350"] = 191740, -- The Fist of Ra-den (Firestorm)
	["128862.132350"] = 195323, -- Ebonchill, Greatstaff of Alodi (Orbital Strike)
	["128937.132350"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128911.132350"] = 207206, -- Sharas'dal, Scepter of Tides (Wavecrash)
	["128860.132350"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	-- Rocket Chicken Rocket Fuel
	["120978.137470"] = 186941, -- Ashbringer (Highlord's Judgment)
	["128289.137470"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128403.137470"] = 191419, -- Apocalypse (Deadliest Coil)
	["128820.137470"] = 194224, -- Felo'melorn (Fire at Will)
	["128941.137470"] = 196211, -- Scepter of Sargeras (Master of Disaster)
	["128819.137470"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128821.137470"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128908.137470"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128943.137470"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- The Forgemaster's Hammer Head
	["128289.132351"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128402.132351"] = 192457, -- Maw of the Damned (Veinrender)
	["128870.132351"] = 192326, -- The Kingslayers (Balanced Blades)
	["128940.132351"] = 195266, -- Fists of the Heavens (Death Art)
	["128861.132351"] = 197139, -- Titanstrike (Focus of the Titans)
	["128819.132351"] = 198292, -- Doomhammer (Wind Strikes)
	["128908.132351"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128872.132351"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.132351"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128866.132351"] = 209226, -- Truthguard (Righteous Crusader)
	["128910.132351"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128832.132351"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	["128938.132351"] = 213062, -- Fu Zan, the Wanderer's Companion (Dark Side of the Moon)
	-- Drop of True Blood
	["128289.137471"] = 188644, -- Scale of the Earth-Warder (Thunder Crash)
	["128403.137471"] = 191584, -- Apocalypse (Unholy Endurance)
	["128402.137471"] = 192538, -- Maw of the Damned (Bonebreaker)
	["128826.137471"] = 190514, -- Thas'dorah, Legacy of the Windrunners (Survival of the Fittest)
	["128870.137471"] = 192345, -- The Kingslayers (Shadow Walker)
	["128827.137471"] = 193647, -- Xal'atath, Blade of the Black Empire (Thoughts of Insanity)
	["128942.137471"] = 199214, -- Ulthalesh, the Deadwind Harvester (Long Dark Night of the Soul)
	["128821.137471"] = 200440, -- Claws of Ursoc (Vicious Bites)
	["128872.137471"] = 202533, -- The Dreadblades (Ghostly Shell)
	["128808.137471"] = 203749, -- Talonclaw, Spear of the Wild Gods (Hunter's Bounty)
	["128910.137471"] = 209541, -- Strom'kar, the Warbreaker (Touch of Zakajz)
	["128860.137471"] = 210590, -- Fangs of Ashamane (Attuned to Nature)
	-- Revitalizing Incense
	["128306.132352"] = 189757, -- G'Hanir, the Mother Tree (Infusion of Nature)
	["128826.132352"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128825.132352"] = 196418, -- T'uure, Beacon of the Naaru (Reverence)
	["128937.132352"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128821.132352"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128823.132352"] = 200296, -- The Silver Hand (Expel the Darkness)
	["128858.132352"] = 202433, -- Scythe of Elune (Scythe of the Stars)
	["128911.132352"] = 207206, -- Sharas'dal, Scepter of Tides (Wavecrash)
	["128860.132352"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	["128938.132352"] = 213062, -- Fu Zan, the Wanderer's Companion (Dark Side of the Moon)
	-- Betrug's Vigor
	["128289.137472"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128402.137472"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128870.137472"] = 192318, -- The Kingslayers (Master Alchemist)
	["128940.137472"] = 218607, -- Fists of the Heavens (Tiger Claws)
	["128861.137472"] = 197080, -- Titanstrike (Pack Leader)
	["128819.137472"] = 198247, -- Doomhammer (Wind Surge)
	["128908.137472"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128872.137472"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.137472"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128832.137472"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128866.137472"] = 209220, -- Truthguard (Unflinching Defense)
	["128910.137472"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128938.137472"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Patch of Risen Saber Pelt
	["128292.132353"] = 189164, -- Blades of the Fallen Prince (Dead of Winter)
	["128403.132353"] = 224466, -- Apocalypse (Runic Tattoos)
	["128402.132353"] = 192457, -- Maw of the Damned (Veinrender)
	["128870.132353"] = 192326, -- The Kingslayers (Balanced Blades)
	["128827.132353"] = 193645, -- Xal'atath, Blade of the Black Empire (Death's Embrace)
	["128476.132353"] = 197235, -- Fangs of the Devourer (Precision Strike)
	["128868.132353"] = 197716, -- Light's Wrath (Burst of Light)
	["128942.132353"] = 199152, -- Ulthalesh, the Deadwind Harvester (Inherently Unstable)
	["127829.132353"] = 201457, -- Twinblades of the Deceiver (Sharpened Glaives)
	["128910.132353"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128943.132353"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	-- Phase Spider Mandible
	["127857.137473"] = 187264, -- Aluneth, Greatstaff of the Magna (Aegwynn's Imperative)
	["128820.137473"] = 210182, -- Felo'melorn (Blue Flame Special)
	["128862.137473"] = 195323, -- Ebonchill, Greatstaff of Alodi (Orbital Strike)
	["128861.137473"] = 197139, -- Titanstrike (Focus of the Titans)
	["128858.137473"] = 202433, -- Scythe of Elune (Scythe of the Stars)
	["128866.137473"] = 209226, -- Truthguard (Righteous Crusader)
	["128832.137473"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	-- Hold Surgeon's Tonic
	-- Loyalty to the Matriarch
	["120978.137474"] = 186941, -- Ashbringer (Highlord's Judgment)
	["128825.137474"] = 196434, -- T'uure, Beacon of the Naaru (Holy Guidance)
	["128868.137474"] = 197708, -- Light's Wrath (Confession)
	["128823.137474"] = 200326, -- The Silver Hand (Focused Healing)
	["128866.137474"] = 209229, -- Truthguard (Hammer Time)
	-- Wind-Whipped Hold Banner Strip
	["128935.132355"] = 191740, -- The Fist of Ra-den (Firestorm)
	["128826.132355"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128940.132355"] = 195266, -- Fists of the Heavens (Death Art)
	["128861.132355"] = 197139, -- Titanstrike (Focus of the Titans)
	["128819.132355"] = 198292, -- Doomhammer (Wind Strikes)
	["128937.132355"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128908.132355"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128872.132355"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.132355"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128938.132355"] = 213062, -- Fu Zan, the Wanderer's Companion (Dark Side of the Moon)
	-- Brand of Tyranny
	["128941.137476"] = 196227, -- Scepter of Sargeras (Residual Flames)
	["128476.137476"] = 197235, -- Fangs of the Devourer (Precision Strike)
	["127829.137476"] = 201457, -- Twinblades of the Deceiver (Sharpened Glaives)
	["128943.137476"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	["128832.137476"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	-- Reflection of Sorrow
	["128306.137478"] = 189757, -- G'Hanir, the Mother Tree (Infusion of Nature)
	["128826.137478"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128825.137478"] = 196418, -- T'uure, Beacon of the Naaru (Reverence)
	["128937.137478"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128821.137478"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128823.137478"] = 200296, -- The Silver Hand (Expel the Darkness)
	["128858.137478"] = 202433, -- Scythe of Elune (Scythe of the Stars)
	["128911.137478"] = 207206, -- Sharas'dal, Scepter of Tides (Wavecrash)
	["128860.137478"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	["128938.137478"] = 213062, -- Fu Zan, the Wanderer's Companion (Dark Side of the Moon)
	-- Self-Forging Credentials
	["127857.137490"] = 210716, -- Aluneth, Greatstaff of the Magna (Mana Shield)
	["128820.137490"] = 194315, -- Felo'melorn (Molten Skin)
	["128862.137490"] = 214626, -- Ebonchill, Greatstaff of Alodi (Jouster)
	["128861.137490"] = 197138, -- Titanstrike (Natural Reflexes)
	["128858.137490"] = 203018, -- Scythe of Elune (Touch of the Moon)
	["128866.137490"] = 211912, -- Truthguard (Faith's Armor)
	["128832.137490"] = 212827, -- The Aldrachi Warblades (Shatter the Souls)
	-- Felsworn Covenant
	["128941.137491"] = 196236, -- Scepter of Sargeras (Soulsnatcher)
	["128476.137491"] = 197369, -- Fangs of the Devourer (Fortune's Bite)
	["127829.137491"] = 201458, -- Twinblades of the Deceiver (Demon Rage)
	["128943.137491"] = 211105, -- Skull of the Man'ari (Dirty Hands)
	["128832.137491"] = 212816, -- The Aldrachi Warblades (Embrace the Pain)
	-- Flamewreath Spark
	["120978.137492"] = 185368, -- Ashbringer (Might of the Templar)
	["128289.137492"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128403.137492"] = 191488, -- Apocalypse (The Darkest Crusade)
	["128820.137492"] = 194314, -- Felo'melorn (Everburning Consumption)
	["128941.137492"] = 196432, -- Scepter of Sargeras (Burning Hunger)
	["128819.137492"] = 198349, -- Doomhammer (Gathering of the Maelstrom)
	["128821.137492"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128908.137492"] = 200860, -- Warswords of the Valarjar (Unrivaled Strength)
	["128943.137492"] = 211119, -- Skull of the Man'ari (Infernal Furnace)
	-- Edge of the First Blade
	["128935.137493"] = 191572, -- The Fist of Ra-den (Molten Blast)
	["128826.137493"] = 190520, -- Thas'dorah, Legacy of the Windrunners (Precision)
	["128940.137493"] = 195269, -- Fists of the Heavens (Power of a Thousand Cranes)
	["128861.137493"] = 197140, -- Titanstrike (Spitting Cobras)
	["128819.137493"] = 198299, -- Doomhammer (Gathering Storms)
	["128937.137493"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128908.137493"] = 200856, -- Warswords of the Valarjar (Uncontrolled Rage)
	["128872.137493"] = 202524, -- The Dreadblades (Fatebringer)
	["128808.137493"] = 203669, -- Talonclaw, Spear of the Wild Gods (Fluffy, Go)
	["128938.137493"] = 213055, -- Fu Zan, the Wanderer's Companion (Staggering Around)
	-- Crux of Blind Faith
	["120978.137495"] = 186927, -- Ashbringer (Deliver the Justice)
	["128825.137495"] = 196422, -- T'uure, Beacon of the Naaru (Holy Hands)
	["128868.137495"] = 197727, -- Light's Wrath (Doomsayer)
	["128823.137495"] = 200294, -- The Silver Hand (Deliver the Light)
	["128866.137495"] = 209223, -- Truthguard (Scatter the Shadows)
	-- Metamorphosis Spark
	["128941.137542"] = 196211, -- Scepter of Sargeras (Master of Disaster)
	["128476.137542"] = 197231, -- Fangs of the Devourer (The Quiet Knife)
	["127829.137542"] = 201454, -- Twinblades of the Deceiver (Contained Fury)
	["128832.137542"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128943.137542"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Soulsap Shackles
	["128289.137543"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128402.137543"] = 192544, -- Maw of the Damned (Vampiric Fangs)
	["128870.137543"] = 192349, -- The Kingslayers (Master Assassin)
	["128940.137543"] = 195291, -- Fists of the Heavens (Fists of the Wind)
	["128861.137543"] = 197162, -- Titanstrike (Jaws of Thunder)
	["128819.137543"] = 198349, -- Doomhammer (Gathering of the Maelstrom)
	["128908.137543"] = 200860, -- Warswords of the Valarjar (Unrivaled Strength)
	["128872.137543"] = 202530, -- The Dreadblades (Fortune Strikes)
	["128808.137543"] = 203670, -- Talonclaw, Spear of the Wild Gods (Explosive Force)
	["128866.137543"] = 209218, -- Truthguard (Consecration in Flame)
	["128910.137543"] = 209492, -- Strom'kar, the Warbreaker (Precise Strikes)
	["128832.137543"] = 212817, -- The Aldrachi Warblades (Fiery Demise)
	["128938.137543"] = 213133, -- Fu Zan, the Wanderer's Companion (Healthy Appetite)
	-- Prisoner's Wail
	["128289.137544"] = 188635, -- Scale of the Earth-Warder (Vrykul Shield Training)
	["128403.137544"] = 191419, -- Apocalypse (Deadliest Coil)
	["128402.137544"] = 192450, -- Maw of the Damned (Iron Heart)
	["128826.137544"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128870.137544"] = 192310, -- The Kingslayers (Toxic Blades)
	["128827.137544"] = 194093, -- Xal'atath, Blade of the Black Empire (Unleash the Shadows)
	["128942.137544"] = 199111, -- Ulthalesh, the Deadwind Harvester (Inimitable Agony)
	["128821.137544"] = 200395, -- Claws of Ursoc (Reinforced Fur)
	["128872.137544"] = 216230, -- The Dreadblades (Black Powder)
	["128808.137544"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128910.137544"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128860.137544"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	-- Flashfrozen Ember
	["127857.137545"] = 210716, -- Aluneth, Greatstaff of the Magna (Mana Shield)
	["128306.137545"] = 186320, -- G'Hanir, the Mother Tree (Grovewalker)
	["128935.137545"] = 191582, -- The Fist of Ra-den (Shamanistic Healing)
	["128862.137545"] = 214626, -- Ebonchill, Greatstaff of Alodi (Jouster)
	["128937.137545"] = 199384, -- Sheilun, Staff of the Mists (Spirit Tether)
	["128292.137545"] = 204875, -- Blades of the Fallen Prince (Frozen Skin)
	["128911.137545"] = 207354, -- Sharas'dal, Scepter of Tides (Caress of the Tidemother)
	["128860.137545"] = 210590, -- Fangs of Ashamane (Attuned to Nature)
	-- Molten Giant's Eye
	["120978.137546"] = 184843, -- Ashbringer (Righteous Blade)
	["128289.137546"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128403.137546"] = 191485, -- Apocalypse (Plaguebearer)
	["128820.137546"] = 194312, -- Felo'melorn (Burning Gaze)
	["128941.137546"] = 196222, -- Scepter of Sargeras (Fire and the Flames)
	["128819.137546"] = 198247, -- Doomhammer (Wind Surge)
	["128821.137546"] = 208762, -- Claws of Ursoc (Mauler)
	["128908.137546"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128943.137546"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Pulsing Prism
	["127857.137547"] = 187301, -- Aluneth, Greatstaff of the Magna (Everywhere At Once)
	["128820.137547"] = 194318, -- Felo'melorn (Cauterizing Blink)
	["128862.137547"] = 195354, -- Ebonchill, Greatstaff of Alodi (Shield of Alodi)
	["128861.137547"] = 197160, -- Titanstrike (Mimiron's Shell)
	["128858.137547"] = 202302, -- Scythe of Elune (Bladed Feathers)
	["128866.137547"] = 209224, -- Truthguard (Resolve of Truth)
	["128832.137547"] = 212821, -- The Aldrachi Warblades (Devour Souls)
	-- Elune's Light
	["120978.137548"] = 186934, -- Ashbringer (Embrace the Light)
	["128825.137548"] = 196489, -- T'uure, Beacon of the Naaru (Power of the Naaru)
	["128868.137548"] = 197711, -- Light's Wrath (Vestments of Discipline)
	["128823.137548"] = 200327, -- The Silver Hand (Share the Burden)
	["128866.137548"] = 209224, -- Truthguard (Resolve of Truth)
	-- Shade of the Vault
	["128292.137549"] = 189147, -- Blades of the Fallen Prince (Bad to the Bone)
	["128403.137549"] = 191488, -- Apocalypse (The Darkest Crusade)
	["128402.137549"] = 192544, -- Maw of the Damned (Vampiric Fangs)
	["128870.137549"] = 192349, -- The Kingslayers (Master Assassin)
	["128827.137549"] = 194016, -- Xal'atath, Blade of the Black Empire (Void Corruption)
	["128476.137549"] = 197386, -- Fangs of the Devourer (Soul Shadows)
	["128868.137549"] = 197729, -- Light's Wrath (Shield of Faith)
	["128942.137549"] = 199158, -- Ulthalesh, the Deadwind Harvester (Perdition)
	["127829.137549"] = 201460, -- Twinblades of the Deceiver (Unleashed Demons)
	["128910.137549"] = 209492, -- Strom'kar, the Warbreaker (Precise Strikes)
	["128943.137549"] = 211119, -- Skull of the Man'ari (Infernal Furnace)
	-- Moonglaive Dervish
	["128935.137550"] = 191493, -- The Fist of Ra-den (Call the Thunder)
	["128826.137550"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128940.137550"] = 195243, -- Fists of the Heavens (Inner Peace)
	["128861.137550"] = 197038, -- Titanstrike (Wilderness Expert)
	["128819.137550"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128937.137550"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128908.137550"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128872.137550"] = 216230, -- The Dreadblades (Black Powder)
	["128808.137550"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128938.137550"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Battle-Touched Elemental Spark
	["127857.135565"] = 187264, -- Aluneth, Greatstaff of the Magna (Aegwynn's Imperative)
	["128820.135565"] = 210182, -- Felo'melorn (Blue Flame Special)
	["128862.135565"] = 195323, -- Ebonchill, Greatstaff of Alodi (Orbital Strike)
	["128861.135565"] = 197139, -- Titanstrike (Focus of the Titans)
	["128858.135565"] = 202433, -- Scythe of Elune (Scythe of the Stars)
	["128866.135565"] = 209226, -- Truthguard (Righteous Crusader)
	["128832.135565"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	-- Battle-Touched Blood of the Fallen
	["128289.135568"] = 216272, -- Scale of the Earth-Warder (Rage of the Fallen)
	["128403.135568"] = 191442, -- Apocalypse (Rotten Touch)
	["128402.135568"] = 192453, -- Maw of the Damned (Meat Shield)
	["128826.135568"] = 190457, -- Thas'dorah, Legacy of the Windrunners (Windrunner's Guidance)
	["128870.135568"] = 192315, -- The Kingslayers (Serrated Edge)
	["128827.135568"] = 193643, -- Xal'atath, Blade of the Black Empire (Mind Shattering)
	["128942.135568"] = 199112, -- Ulthalesh, the Deadwind Harvester (Hideous Corruption)
	["128821.135568"] = 200399, -- Claws of Ursoc (Ursoc's Endurance)
	["128872.135568"] = 202507, -- The Dreadblades (Blade Dancer)
	["128808.135568"] = 203577, -- Talonclaw, Spear of the Wild Gods (My Beloved Monster)
	["128910.135568"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128860.135568"] = 210571, -- Fangs of Ashamane (Feral Power)
	-- Petrified Ancient's Thumb
	["128306.140438"] = 186320, -- G'Hanir, the Mother Tree (Grovewalker)
	["128826.140438"] = 190514, -- Thas'dorah, Legacy of the Windrunners (Survival of the Fittest)
	["128825.140438"] = 196355, -- T'uure, Beacon of the Naaru (Trust in the Light)
	["128937.140438"] = 199384, -- Sheilun, Staff of the Mists (Spirit Tether)
	["128821.140438"] = 200440, -- Claws of Ursoc (Vicious Bites)
	["128823.140438"] = 200302, -- The Silver Hand (Knight of the Silver Hand)
	["128858.140438"] = 203018, -- Scythe of Elune (Touch of the Moon)
	["128911.140438"] = 207354, -- Sharas'dal, Scepter of Tides (Caress of the Tidemother)
	["128860.140438"] = 210590, -- Fangs of Ashamane (Attuned to Nature)
	["128938.140438"] = 213116, -- Fu Zan, the Wanderer's Companion (Face Palm)
	-- Battle-Touched Infernal Shard
	["128941.135569"] = 196211, -- Scepter of Sargeras (Master of Disaster)
	["128476.135569"] = 197231, -- Fangs of the Devourer (The Quiet Knife)
	["127829.135569"] = 201454, -- Twinblades of the Deceiver (Contained Fury)
	["128832.135569"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128943.135569"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Tombweed Bloom
	["128306.140437"] = 189754, -- G'Hanir, the Mother Tree (Armor of the Ancients)
	["128826.140437"] = 190520, -- Thas'dorah, Legacy of the Windrunners (Precision)
	["128825.140437"] = 196422, -- T'uure, Beacon of the Naaru (Holy Hands)
	["128937.140437"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128821.140437"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128823.140437"] = 200294, -- The Silver Hand (Deliver the Light)
	["128858.140437"] = 202445, -- Scythe of Elune (Falling Star)
	["128911.140437"] = 207255, -- Sharas'dal, Scepter of Tides (Empowered Droplets)
	["128860.140437"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	["128938.140437"] = 213055, -- Fu Zan, the Wanderer's Companion (Staggering Around)
	-- Battle-Touched Helfrost
	["127857.135570"] = 187313, -- Aluneth, Greatstaff of the Magna (Arcane Purification)
	["128292.135570"] = 189144, -- Blades of the Fallen Prince (Nothing but the Boots)
	["128306.135570"] = 189754, -- G'Hanir, the Mother Tree (Armor of the Ancients)
	["128935.135570"] = 191572, -- The Fist of Ra-den (Molten Blast)
	["128862.135570"] = 195345, -- Ebonchill, Greatstaff of Alodi (Frozen Veins)
	["128937.135570"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128911.135570"] = 207255, -- Sharas'dal, Scepter of Tides (Empowered Droplets)
	["128860.135570"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	-- Unflinching Grit
	["128289.140435"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128402.140435"] = 192544, -- Maw of the Damned (Vampiric Fangs)
	["128870.140435"] = 192349, -- The Kingslayers (Master Assassin)
	["128940.140435"] = 195291, -- Fists of the Heavens (Fists of the Wind)
	["128861.140435"] = 197162, -- Titanstrike (Jaws of Thunder)
	["128819.140435"] = 198349, -- Doomhammer (Gathering of the Maelstrom)
	["128908.140435"] = 200860, -- Warswords of the Valarjar (Unrivaled Strength)
	["128872.140435"] = 202530, -- The Dreadblades (Fortune Strikes)
	["128808.140435"] = 203670, -- Talonclaw, Spear of the Wild Gods (Explosive Force)
	["128866.140435"] = 209218, -- Truthguard (Consecration in Flame)
	["128910.140435"] = 209492, -- Strom'kar, the Warbreaker (Precise Strikes)
	["128832.140435"] = 212817, -- The Aldrachi Warblades (Fiery Demise)
	["128938.140435"] = 213133, -- Fu Zan, the Wanderer's Companion (Healthy Appetite)
	-- Radiance of Dawn
	["120978.140434"] = 184778, -- Ashbringer (Deflection)
	["128825.140434"] = 196355, -- T'uure, Beacon of the Naaru (Trust in the Light)
	["128868.140434"] = 216212, -- Light's Wrath (Darkest Shadows)
	["128823.140434"] = 200302, -- The Silver Hand (Knight of the Silver Hand)
	["128866.140434"] = 211912, -- Truthguard (Faith's Armor)
	-- Battle-Touched Ember
	["120978.135571"] = 186934, -- Ashbringer (Embrace the Light)
	["128289.135571"] = 188632, -- Scale of the Earth-Warder (Toughness)
	["128403.135571"] = 191565, -- Apocalypse (Deadly Durability)
	["128820.135571"] = 194318, -- Felo'melorn (Cauterizing Blink)
	["128941.135571"] = 196301, -- Scepter of Sargeras (Devourer of Life)
	["128819.135571"] = 198296, -- Doomhammer (Spiritual Healing)
	["128821.135571"] = 200400, -- Claws of Ursoc (Wildflesh)
	["128908.135571"] = 200857, -- Warswords of the Valarjar (Battle Scars)
	["128943.135571"] = 211144, -- Skull of the Man'ari (Open Link)
	-- Superiority's Contempt
	["127857.140431"] = 187264, -- Aluneth, Greatstaff of the Magna (Aegwynn's Imperative)
	["128292.140431"] = 189164, -- Blades of the Fallen Prince (Dead of Winter)
	["128306.140431"] = 189757, -- G'Hanir, the Mother Tree (Infusion of Nature)
	["128935.140431"] = 191740, -- The Fist of Ra-den (Firestorm)
	["128862.140431"] = 195323, -- Ebonchill, Greatstaff of Alodi (Orbital Strike)
	["128937.140431"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128911.140431"] = 207206, -- Sharas'dal, Scepter of Tides (Wavecrash)
	["128860.140431"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	-- Torch of Competition
	["120978.140430"] = 185368, -- Ashbringer (Might of the Templar)
	["128289.140430"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128403.140430"] = 191488, -- Apocalypse (The Darkest Crusade)
	["128820.140430"] = 194314, -- Felo'melorn (Everburning Consumption)
	["128941.140430"] = 196432, -- Scepter of Sargeras (Burning Hunger)
	["128819.140430"] = 198349, -- Doomhammer (Gathering of the Maelstrom)
	["128821.140430"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128908.140430"] = 200860, -- Warswords of the Valarjar (Unrivaled Strength)
	["128943.140430"] = 211119, -- Skull of the Man'ari (Infernal Furnace)
	-- Battle-Touched Martyr Stone
	["120978.135572"] = 185368, -- Ashbringer (Might of the Templar)
	["128825.135572"] = 196429, -- T'uure, Beacon of the Naaru (Hallowed Ground)
	["128868.135572"] = 197729, -- Light's Wrath (Shield of Faith)
	["128823.135572"] = 200298, -- The Silver Hand (Blessings of the Silver Hand)
	["128866.135572"] = 209218, -- Truthguard (Consecration in Flame)
	-- Flame of the Fallen
	["120978.140429"] = 186927, -- Ashbringer (Deliver the Justice)
	["128289.140429"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128403.140429"] = 191494, -- Apocalypse (Scourge the Unbeliever)
	["128820.140429"] = 194313, -- Felo'melorn (Great Balls of Fire)
	["128941.140429"] = 196236, -- Scepter of Sargeras (Soulsnatcher)
	["128819.140429"] = 198299, -- Doomhammer (Gathering Storms)
	["128821.140429"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128908.140429"] = 200856, -- Warswords of the Valarjar (Uncontrolled Rage)
	["128943.140429"] = 211105, -- Skull of the Man'ari (Dirty Hands)
	-- Battle-Touched Chain Link
	["128289.135573"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128402.135573"] = 192464, -- Maw of the Damned (All-Consuming Rot)
	["128870.135573"] = 192376, -- The Kingslayers (Poison Knives)
	["128819.135573"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128908.135573"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128872.135573"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.135573"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128940.135573"] = 195267, -- Fists of the Heavens (Strength of Xuen)
	["128861.135573"] = 206910, -- Titanstrike (Unleash the Beast)
	["128866.135573"] = 209216, -- Truthguard (Bastion of Truth)
	["128910.135573"] = 209494, -- Strom'kar, the Warbreaker (Exploit the Weakness)
	["128832.135573"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	["128938.135573"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Alliance of Convenience
	["128941.140428"] = 196301, -- Scepter of Sargeras (Devourer of Life)
	["128476.140428"] = 210147, -- Fangs of the Devourer (Catlike Reflexes)
	["127829.140428"] = 201459, -- Twinblades of the Deceiver (Illidari Knowledge)
	["128943.140428"] = 211144, -- Skull of the Man'ari (Open Link)
	["128832.140428"] = 212821, -- The Aldrachi Warblades (Devour Souls)
	-- Battle-Touched Blossom
	["128306.135574"] = 186320, -- G'Hanir, the Mother Tree (Grovewalker)
	["128826.135574"] = 190514, -- Thas'dorah, Legacy of the Windrunners (Survival of the Fittest)
	["128825.135574"] = 196355, -- T'uure, Beacon of the Naaru (Trust in the Light)
	["128937.135574"] = 199384, -- Sheilun, Staff of the Mists (Spirit Tether)
	["128821.135574"] = 200440, -- Claws of Ursoc (Vicious Bites)
	["128823.135574"] = 200302, -- The Silver Hand (Knight of the Silver Hand)
	["128858.135574"] = 203018, -- Scythe of Elune (Touch of the Moon)
	["128911.135574"] = 207354, -- Sharas'dal, Scepter of Tides (Caress of the Tidemother)
	["128860.135574"] = 210590, -- Fangs of Ashamane (Attuned to Nature)
	["128938.135574"] = 213116, -- Fu Zan, the Wanderer's Companion (Face Palm)
	-- Thrill of Battle
	["128289.140426"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128403.140426"] = 191488, -- Apocalypse (The Darkest Crusade)
	["128402.140426"] = 192544, -- Maw of the Damned (Vampiric Fangs)
	["128826.140426"] = 190529, -- Thas'dorah, Legacy of the Windrunners (Marked for Death)
	["128870.140426"] = 192349, -- The Kingslayers (Master Assassin)
	["128827.140426"] = 194016, -- Xal'atath, Blade of the Black Empire (Void Corruption)
	["128942.140426"] = 199158, -- Ulthalesh, the Deadwind Harvester (Perdition)
	["128821.140426"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128872.140426"] = 202530, -- The Dreadblades (Fortune Strikes)
	["128808.140426"] = 203670, -- Talonclaw, Spear of the Wild Gods (Explosive Force)
	["128910.140426"] = 209492, -- Strom'kar, the Warbreaker (Precise Strikes)
	["128860.140426"] = 210637, -- Fangs of Ashamane (Sharpened Claws)
	-- Thirsty Bloodstone
	["128289.140425"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128403.140425"] = 191494, -- Apocalypse (Scourge the Unbeliever)
	["128402.140425"] = 192460, -- Maw of the Damned (Coagulopathy)
	["128826.140425"] = 190520, -- Thas'dorah, Legacy of the Windrunners (Precision)
	["128870.140425"] = 192329, -- The Kingslayers (Gushing Wound)
	["128827.140425"] = 194007, -- Xal'atath, Blade of the Black Empire (Touch of Darkness)
	["128942.140425"] = 199153, -- Ulthalesh, the Deadwind Harvester (Seeds of Doom)
	["128821.140425"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128872.140425"] = 202524, -- The Dreadblades (Fatebringer)
	["128808.140425"] = 203669, -- Talonclaw, Spear of the Wild Gods (Fluffy, Go)
	["128910.140425"] = 209481, -- Strom'kar, the Warbreaker (Deathblow)
	["128860.140425"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	-- Taboo Knowledge
	["127857.140424"] = 187264, -- Aluneth, Greatstaff of the Magna (Aegwynn's Imperative)
	["128820.140424"] = 210182, -- Felo'melorn (Blue Flame Special)
	["128862.140424"] = 195323, -- Ebonchill, Greatstaff of Alodi (Orbital Strike)
	["128861.140424"] = 197139, -- Titanstrike (Focus of the Titans)
	["128858.140424"] = 202433, -- Scythe of Elune (Scythe of the Stars)
	["128866.140424"] = 209226, -- Truthguard (Righteous Crusader)
	["128832.140424"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	-- Exhaustive Research
	["127857.140423"] = 187321, -- Aluneth, Greatstaff of the Magna (Aegwynn's Wrath)
	["128820.140423"] = 194312, -- Felo'melorn (Burning Gaze)
	["128862.140423"] = 195322, -- Ebonchill, Greatstaff of Alodi (Let It Go)
	["128861.140423"] = 197080, -- Titanstrike (Pack Leader)
	["128858.140423"] = 202426, -- Scythe of Elune (Solar Stabbing)
	["128832.140423"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128866.140423"] = 209220, -- Truthguard (Unflinching Defense)
	-- Battle-Touched Fetish
	["128292.135576"] = 189086, -- Blades of the Fallen Prince (Blast Radius)
	["128403.135576"] = 191485, -- Apocalypse (Plaguebearer)
	["128402.135576"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128870.135576"] = 192318, -- The Kingslayers (Master Alchemist)
	["128827.135576"] = 193644, -- Xal'atath, Blade of the Black Empire (To the Pain)
	["128476.135576"] = 197234, -- Fangs of the Devourer (Gutripper)
	["128868.135576"] = 197715, -- Light's Wrath (The Edge of Dark and Light)
	["128942.135576"] = 199120, -- Ulthalesh, the Deadwind Harvester (Drained to a Husk)
	["127829.135576"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128910.135576"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128943.135576"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Battle-Touched Dewdrop
	-- Battering Tempest
	["128935.140420"] = 191493, -- The Fist of Ra-den (Call the Thunder)
	["128826.140420"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128940.140420"] = 195243, -- Fists of the Heavens (Inner Peace)
	["128861.140420"] = 197038, -- Titanstrike (Wilderness Expert)
	["128819.140420"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128937.140420"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128908.140420"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128872.140420"] = 216230, -- The Dreadblades (Black Powder)
	["128808.140420"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128938.140420"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Battle-Touched Banner
	["128935.135578"] = 191493, -- The Fist of Ra-den (Call the Thunder)
	["128826.135578"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128940.135578"] = 195243, -- Fists of the Heavens (Inner Peace)
	["128861.135578"] = 197038, -- Titanstrike (Wilderness Expert)
	["128819.135578"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128937.135578"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128908.135578"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128872.135578"] = 216230, -- The Dreadblades (Black Powder)
	["128808.135578"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128938.135578"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- "Borrowed" Soul Essence
	["128306.140418"] = 189768, -- G'Hanir, the Mother Tree (Seeds of the World Tree)
	["128826.140418"] = 190457, -- Thas'dorah, Legacy of the Windrunners (Windrunner's Guidance)
	["128825.140418"] = 196358, -- T'uure, Beacon of the Naaru (Say Your Prayers)
	["128937.140418"] = 199366, -- Sheilun, Staff of the Mists (Way of the Mistweaver)
	["128821.140418"] = 200399, -- Claws of Ursoc (Ursoc's Endurance)
	["128823.140418"] = 200316, -- The Silver Hand (Justice through Sacrifice)
	["128858.140418"] = 202386, -- Scythe of Elune (Twilight Glow)
	["128911.140418"] = 207092, -- Sharas'dal, Scepter of Tides (Buffeting Waves)
	["128860.140418"] = 210571, -- Fangs of Ashamane (Feral Power)
	["128938.140418"] = 227687, -- Fu Zan, the Wanderer's Companion (Hot Blooded)
	-- Battle-Tempered Hilt
	["128289.140417"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128402.140417"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128870.140417"] = 192318, -- The Kingslayers (Master Alchemist)
	["128940.140417"] = 218607, -- Fists of the Heavens (Tiger Claws)
	["128861.140417"] = 197080, -- Titanstrike (Pack Leader)
	["128819.140417"] = 198247, -- Doomhammer (Wind Surge)
	["128908.140417"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128872.140417"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.140417"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128832.140417"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128866.140417"] = 209220, -- Truthguard (Unflinching Defense)
	["128910.140417"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128938.140417"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Conscience of the Victorious
	["127857.140416"] = 187258, -- Aluneth, Greatstaff of the Magna (Blasting Rod)
	["128292.140416"] = 189092, -- Blades of the Fallen Prince (Ambidexterity)
	["128306.140416"] = 189768, -- G'Hanir, the Mother Tree (Seeds of the World Tree)
	["128935.140416"] = 191499, -- The Fist of Ra-den (The Ground Trembles)
	["128862.140416"] = 195317, -- Ebonchill, Greatstaff of Alodi (Ice Age)
	["128937.140416"] = 199366, -- Sheilun, Staff of the Mists (Way of the Mistweaver)
	["128911.140416"] = 207092, -- Sharas'dal, Scepter of Tides (Buffeting Waves)
	["128860.140416"] = 210571, -- Fangs of Ashamane (Feral Power)
	-- Blaze of Glory
	["120978.140415"] = 184759, -- Ashbringer (Sharpened Edge)
	["128289.140415"] = 216272, -- Scale of the Earth-Warder (Rage of the Fallen)
	["128403.140415"] = 191442, -- Apocalypse (Rotten Touch)
	["128820.140415"] = 194234, -- Felo'melorn (Reignition Overdrive)
	["128941.140415"] = 196217, -- Scepter of Sargeras (Chaotic Instability)
	["128819.140415"] = 198236, -- Doomhammer (Forged in Lava)
	["128821.140415"] = 200399, -- Claws of Ursoc (Ursoc's Endurance)
	["128908.140415"] = 216273, -- Warswords of the Valarjar (Wild Slashes)
	["128943.140415"] = 211126, -- Skull of the Man'ari (Legionwrath)
	-- Fel-Loaded Dice
	["128941.140414"] = 196236, -- Scepter of Sargeras (Soulsnatcher)
	["128476.140414"] = 197369, -- Fangs of the Devourer (Fortune's Bite)
	["127829.140414"] = 201458, -- Twinblades of the Deceiver (Demon Rage)
	["128943.140414"] = 211105, -- Skull of the Man'ari (Dirty Hands)
	["128832.140414"] = 212816, -- The Aldrachi Warblades (Embrace the Pain)
	-- Clarity of Conviction
	["120978.140411"] = 184843, -- Ashbringer (Righteous Blade)
	["128825.140411"] = 196416, -- T'uure, Beacon of the Naaru (Serenity Now)
	["128868.140411"] = 197715, -- Light's Wrath (The Edge of Dark and Light)
	["128823.140411"] = 200315, -- The Silver Hand (Shock Treatment)
	["128866.140411"] = 209220, -- Truthguard (Unflinching Defense)
	-- Terrorspike
	["128289.136683"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128403.136683"] = 191485, -- Apocalypse (Plaguebearer)
	["128402.136683"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128826.136683"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128870.136683"] = 192318, -- The Kingslayers (Master Alchemist)
	["128827.136683"] = 193644, -- Xal'atath, Blade of the Black Empire (To the Pain)
	["128942.136683"] = 199120, -- Ulthalesh, the Deadwind Harvester (Drained to a Husk)
	["128821.136683"] = 208762, -- Claws of Ursoc (Mauler)
	["128872.136683"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.136683"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128910.136683"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128860.136683"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	-- Gleaming Iron Spike
	["128289.136684"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128402.136684"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128870.136684"] = 192318, -- The Kingslayers (Master Alchemist)
	["128940.136684"] = 218607, -- Fists of the Heavens (Tiger Claws)
	["128861.136684"] = 197080, -- Titanstrike (Pack Leader)
	["128819.136684"] = 198247, -- Doomhammer (Wind Surge)
	["128908.136684"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128872.136684"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.136684"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128832.136684"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128866.136684"] = 209220, -- Truthguard (Unflinching Defense)
	["128910.136684"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128938.136684"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Consecrated Spike
	["120978.136685"] = 184843, -- Ashbringer (Righteous Blade)
	["128825.136685"] = 196416, -- T'uure, Beacon of the Naaru (Serenity Now)
	["128868.136685"] = 197715, -- Light's Wrath (The Edge of Dark and Light)
	["128823.136685"] = 200315, -- The Silver Hand (Shock Treatment)
	["128866.136685"] = 209220, -- Truthguard (Unflinching Defense)
	-- Flamespike
	["120978.136686"] = 184843, -- Ashbringer (Righteous Blade)
	["128289.136686"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128403.136686"] = 191485, -- Apocalypse (Plaguebearer)
	["128820.136686"] = 194312, -- Felo'melorn (Burning Gaze)
	["128941.136686"] = 196222, -- Scepter of Sargeras (Fire and the Flames)
	["128819.136686"] = 198247, -- Doomhammer (Wind Surge)
	["128821.136686"] = 208762, -- Claws of Ursoc (Mauler)
	["128908.136686"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128943.136686"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- "The Felic"
	["128941.136687"] = 196222, -- Scepter of Sargeras (Fire and the Flames)
	["128476.136687"] = 197234, -- Fangs of the Devourer (Gutripper)
	["127829.136687"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128832.136687"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128943.136687"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Shockinator
	["128935.136688"] = 191504, -- The Fist of Ra-den (Lava Imbued)
	["128826.136688"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128940.136688"] = 218607, -- Fists of the Heavens (Tiger Claws)
	["128861.136688"] = 197080, -- Titanstrike (Pack Leader)
	["128819.136688"] = 198247, -- Doomhammer (Wind Surge)
	["128937.136688"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128908.136688"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128872.136688"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.136688"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128938.136688"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Soul Fibril
	["128292.136689"] = 189086, -- Blades of the Fallen Prince (Blast Radius)
	["128403.136689"] = 191485, -- Apocalypse (Plaguebearer)
	["128402.136689"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128870.136689"] = 192318, -- The Kingslayers (Master Alchemist)
	["128827.136689"] = 193644, -- Xal'atath, Blade of the Black Empire (To the Pain)
	["128476.136689"] = 197234, -- Fangs of the Devourer (Gutripper)
	["128868.136689"] = 197715, -- Light's Wrath (The Edge of Dark and Light)
	["128942.136689"] = 199120, -- Ulthalesh, the Deadwind Harvester (Drained to a Husk)
	["127829.136689"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128910.136689"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128943.136689"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Immaculate Fibril
	["127857.136691"] = 187321, -- Aluneth, Greatstaff of the Magna (Aegwynn's Wrath)
	["128820.136691"] = 194312, -- Felo'melorn (Burning Gaze)
	["128862.136691"] = 195322, -- Ebonchill, Greatstaff of Alodi (Let It Go)
	["128861.136691"] = 197080, -- Titanstrike (Pack Leader)
	["128858.136691"] = 202426, -- Scythe of Elune (Solar Stabbing)
	["128832.136691"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128866.136691"] = 209220, -- Truthguard (Unflinching Defense)
	-- Aqual Mark
	["127857.136692"] = 187321, -- Aluneth, Greatstaff of the Magna (Aegwynn's Wrath)
	["128292.136692"] = 189086, -- Blades of the Fallen Prince (Blast Radius)
	["128306.136692"] = 189760, -- G'Hanir, the Mother Tree (Essence of Nordrassil)
	["128935.136692"] = 191504, -- The Fist of Ra-den (Lava Imbued)
	["128862.136692"] = 195322, -- Ebonchill, Greatstaff of Alodi (Let It Go)
	["128937.136692"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128911.136692"] = 210029, -- Sharas'dal, Scepter of Tides (Pull of the Sea)
	["128860.136692"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	-- Straszan Mark
	["128306.136693"] = 189760, -- G'Hanir, the Mother Tree (Essence of Nordrassil)
	["128826.136693"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128825.136693"] = 196416, -- T'uure, Beacon of the Naaru (Serenity Now)
	["128937.136693"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128821.136693"] = 208762, -- Claws of Ursoc (Mauler)
	["128823.136693"] = 200315, -- The Silver Hand (Shock Treatment)
	["128858.136693"] = 202426, -- Scythe of Elune (Solar Stabbing)
	["128911.136693"] = 210029, -- Sharas'dal, Scepter of Tides (Pull of the Sea)
	["128860.136693"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	["128938.136693"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Absolved Ravencrest Brooch
	["120978.136717"] = 186945, -- Ashbringer (Wrath of the Ashbringer)
	["128825.136717"] = 196418, -- T'uure, Beacon of the Naaru (Reverence)
	["128868.136717"] = 197716, -- Light's Wrath (Burst of Light)
	["128823.136717"] = 200296, -- The Silver Hand (Expel the Darkness)
	["128866.136717"] = 209226, -- Truthguard (Righteous Crusader)
	-- Mark of Varo'then
	["128289.136718"] = 203227, -- Scale of the Earth-Warder (Intolerance)
	["128403.136718"] = 191488, -- Apocalypse (The Darkest Crusade)
	["128402.136718"] = 192544, -- Maw of the Damned (Vampiric Fangs)
	["128826.136718"] = 190529, -- Thas'dorah, Legacy of the Windrunners (Marked for Death)
	["128870.136718"] = 192349, -- The Kingslayers (Master Assassin)
	["128827.136718"] = 194016, -- Xal'atath, Blade of the Black Empire (Void Corruption)
	["128942.136718"] = 199158, -- Ulthalesh, the Deadwind Harvester (Perdition)
	["128821.136718"] = 200414, -- Claws of Ursoc (Bestial Fortitude)
	["128872.136718"] = 202530, -- The Dreadblades (Fortune Strikes)
	["128808.136718"] = 203670, -- Talonclaw, Spear of the Wild Gods (Explosive Force)
	["128910.136718"] = 209492, -- Strom'kar, the Warbreaker (Precise Strikes)
	["128860.136718"] = 210637, -- Fangs of Ashamane (Sharpened Claws)
	-- Curdled Soul Essence
	["128403.136719"] = 191584, -- Apocalypse (Unholy Endurance)
	["128402.136719"] = 192538, -- Maw of the Damned (Bonebreaker)
	["128870.136719"] = 192345, -- The Kingslayers (Shadow Walker)
	["128827.136719"] = 193647, -- Xal'atath, Blade of the Black Empire (Thoughts of Insanity)
	["128476.136719"] = 197244, -- Fangs of the Devourer (Ghost Armor)
	["128868.136719"] = 216212, -- Light's Wrath (Darkest Shadows)
	["128942.136719"] = 199214, -- Ulthalesh, the Deadwind Harvester (Long Dark Night of the Soul)
	["127829.136719"] = 201463, -- Twinblades of the Deceiver (Deceiver's Fury)
	["128292.136719"] = 204875, -- Blades of the Fallen Prince (Frozen Skin)
	["128910.136719"] = 209541, -- Strom'kar, the Warbreaker (Touch of Zakajz)
	["128943.136719"] = 211131, -- Skull of the Man'ari (Firm Resolve)
	-- Snapped Emerald Pendant
	["128306.136720"] = 189768, -- G'Hanir, the Mother Tree (Seeds of the World Tree)
	["128826.136720"] = 190457, -- Thas'dorah, Legacy of the Windrunners (Windrunner's Guidance)
	["128825.136720"] = 196358, -- T'uure, Beacon of the Naaru (Say Your Prayers)
	["128937.136720"] = 199366, -- Sheilun, Staff of the Mists (Way of the Mistweaver)
	["128821.136720"] = 200399, -- Claws of Ursoc (Ursoc's Endurance)
	["128823.136720"] = 200316, -- The Silver Hand (Justice through Sacrifice)
	["128858.136720"] = 202386, -- Scythe of Elune (Twilight Glow)
	["128911.136720"] = 207092, -- Sharas'dal, Scepter of Tides (Buffeting Waves)
	["128860.136720"] = 210571, -- Fangs of Ashamane (Feral Power)
	["128938.136720"] = 227687, -- Fu Zan, the Wanderer's Companion (Hot Blooded)
	-- Mo'arg Eyepatch
	["128941.136721"] = 196258, -- Scepter of Sargeras (Fire From the Sky)
	["128476.136721"] = 197239, -- Fangs of the Devourer (Energetic Stabbing)
	["127829.136721"] = 201464, -- Twinblades of the Deceiver (Overwhelming Power)
	["128943.136721"] = 211099, -- Skull of the Man'ari (Maw of Shadows)
	["128832.136721"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	-- Northern Gale
	["128935.133682"] = 191740, -- The Fist of Ra-den (Firestorm)
	["128826.133682"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128940.133682"] = 195266, -- Fists of the Heavens (Death Art)
	["128861.133682"] = 197139, -- Titanstrike (Focus of the Titans)
	["128819.133682"] = 198292, -- Doomhammer (Wind Strikes)
	["128937.133682"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128908.133682"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128872.133682"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.133682"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128938.133682"] = 213062, -- Fu Zan, the Wanderer's Companion (Dark Side of the Moon)
	-- Seacursed Mist
	["127857.133683"] = 187304, -- Aluneth, Greatstaff of the Magna (Torrential Barrage)
	["128292.133683"] = 189080, -- Blades of the Fallen Prince (Cold as Ice)
	["128306.133683"] = 189772, -- G'Hanir, the Mother Tree (Knowledge of the Ancients)
	["128935.133683"] = 191493, -- The Fist of Ra-den (Call the Thunder)
	["128862.133683"] = 195315, -- Ebonchill, Greatstaff of Alodi (Icy Caress)
	["128937.133683"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128911.133683"] = 207088, -- Sharas'dal, Scepter of Tides (Tidal Chains)
	["128860.133683"] = 210570, -- Fangs of Ashamane (Razor Fangs)
	-- Screams of the Unworthy
	["128292.133684"] = 189092, -- Blades of the Fallen Prince (Ambidexterity)
	["128403.133684"] = 191442, -- Apocalypse (Rotten Touch)
	["128402.133684"] = 192453, -- Maw of the Damned (Meat Shield)
	["128870.133684"] = 192315, -- The Kingslayers (Serrated Edge)
	["128827.133684"] = 193643, -- Xal'atath, Blade of the Black Empire (Mind Shattering)
	["128476.133684"] = 197233, -- Fangs of the Devourer (Demon's Kiss)
	["128868.133684"] = 197713, -- Light's Wrath (Pain is in Your Mind)
	["128942.133684"] = 199112, -- Ulthalesh, the Deadwind Harvester (Hideous Corruption)
	["127829.133684"] = 201455, -- Twinblades of the Deceiver (Critical Chaos)
	["128910.133684"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128943.133684"] = 211126, -- Skull of the Man'ari (Legionwrath)
	-- Odyn's Boon
	["120978.133685"] = 186944, -- Ashbringer (Protector of the Ashen Blade)
	["128825.133685"] = 196430, -- T'uure, Beacon of the Naaru (Words of Healing)
	["128868.133685"] = 197762, -- Light's Wrath (Borrowed Time)
	["128866.133685"] = 209216, -- Truthguard (Bastion of Truth)
	["128823.133685"] = 200482, -- The Silver Hand (Second Sunrise)
	-- Stormforged Inferno
	["120978.133686"] = 186927, -- Ashbringer (Deliver the Justice)
	["128289.133686"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128403.133686"] = 191494, -- Apocalypse (Scourge the Unbeliever)
	["128820.133686"] = 194313, -- Felo'melorn (Great Balls of Fire)
	["128941.133686"] = 196236, -- Scepter of Sargeras (Soulsnatcher)
	["128819.133686"] = 198299, -- Doomhammer (Gathering Storms)
	["128821.133686"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128908.133686"] = 200856, -- Warswords of the Valarjar (Uncontrolled Rage)
	["128943.133686"] = 211105, -- Skull of the Man'ari (Dirty Hands)
	-- Fenryr's Bloodstained Fang
	["128289.133687"] = 216272, -- Scale of the Earth-Warder (Rage of the Fallen)
	["128403.133687"] = 191442, -- Apocalypse (Rotten Touch)
	["128402.133687"] = 192453, -- Maw of the Damned (Meat Shield)
	["128826.133687"] = 190457, -- Thas'dorah, Legacy of the Windrunners (Windrunner's Guidance)
	["128870.133687"] = 192315, -- The Kingslayers (Serrated Edge)
	["128827.133687"] = 193643, -- Xal'atath, Blade of the Black Empire (Mind Shattering)
	["128942.133687"] = 199112, -- Ulthalesh, the Deadwind Harvester (Hideous Corruption)
	["128821.133687"] = 200399, -- Claws of Ursoc (Ursoc's Endurance)
	["128872.133687"] = 202507, -- The Dreadblades (Blade Dancer)
	["128808.133687"] = 203577, -- Talonclaw, Spear of the Wild Gods (My Beloved Monster)
	["128910.133687"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128860.133687"] = 210571, -- Fangs of Ashamane (Feral Power)
	-- Ravencrest's Wrath
	["120978.136769"] = 184778, -- Ashbringer (Deflection)
	["128289.136769"] = 188644, -- Scale of the Earth-Warder (Thunder Crash)
	["128403.136769"] = 191584, -- Apocalypse (Unholy Endurance)
	["128820.136769"] = 194315, -- Felo'melorn (Molten Skin)
	["128941.136769"] = 196305, -- Scepter of Sargeras (Eternal Struggle)
	["128819.136769"] = 198248, -- Doomhammer (Elemental Healing)
	["128821.136769"] = 200440, -- Claws of Ursoc (Vicious Bites)
	["128908.136769"] = 200859, -- Warswords of the Valarjar (Bloodcraze)
	["128943.136769"] = 211131, -- Skull of the Man'ari (Firm Resolve)
	-- Eyir's Blessing
	["120978.136771"] = 184843, -- Ashbringer (Righteous Blade)
	["128825.136771"] = 196416, -- T'uure, Beacon of the Naaru (Serenity Now)
	["128868.136771"] = 197715, -- Light's Wrath (The Edge of Dark and Light)
	["128823.136771"] = 200315, -- The Silver Hand (Shock Treatment)
	["128866.136771"] = 209220, -- Truthguard (Unflinching Defense)
	-- Skovald's Resolve
	["128289.136778"] = 188632, -- Scale of the Earth-Warder (Toughness)
	["128402.136778"] = 192514, -- Maw of the Damned (Dance of Darkness)
	["128870.136778"] = 192323, -- The Kingslayers (Fade into Shadows)
	["128940.136778"] = 195244, -- Fists of the Heavens (Light on Your Feet)
	["128861.136778"] = 197160, -- Titanstrike (Mimiron's Shell)
	["128819.136778"] = 198296, -- Doomhammer (Spiritual Healing)
	["128908.136778"] = 200857, -- Warswords of the Valarjar (Battle Scars)
	["128872.136778"] = 202521, -- The Dreadblades (Fortune's Strike)
	["128808.136778"] = 224764, -- Talonclaw, Spear of the Wild Gods (Bird of Prey)
	["128866.136778"] = 209224, -- Truthguard (Resolve of Truth)
	["128910.136778"] = 209483, -- Strom'kar, the Warbreaker (Tactical Advance)
	["128832.136778"] = 212821, -- The Aldrachi Warblades (Devour Souls)
	["128938.136778"] = 213047, -- Fu Zan, the Wanderer's Companion (Potent Kick)
	-- Key to the Halls
	["128289.133763"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128402.133763"] = 192460, -- Maw of the Damned (Coagulopathy)
	["128870.133763"] = 192329, -- The Kingslayers (Gushing Wound)
	["128940.133763"] = 195269, -- Fists of the Heavens (Power of a Thousand Cranes)
	["128861.133763"] = 197140, -- Titanstrike (Spitting Cobras)
	["128819.133763"] = 198299, -- Doomhammer (Gathering Storms)
	["128908.133763"] = 200856, -- Warswords of the Valarjar (Uncontrolled Rage)
	["128872.133763"] = 202524, -- The Dreadblades (Fatebringer)
	["128808.133763"] = 203669, -- Talonclaw, Spear of the Wild Gods (Fluffy, Go)
	["128866.133763"] = 209223, -- Truthguard (Scatter the Shadows)
	["128910.133763"] = 209481, -- Strom'kar, the Warbreaker (Deathblow)
	["128832.133763"] = 212816, -- The Aldrachi Warblades (Embrace the Pain)
	["128938.133763"] = 213055, -- Fu Zan, the Wanderer's Companion (Staggering Around)
	-- Ragnarok Ember
	["128941.133764"] = 196432, -- Scepter of Sargeras (Burning Hunger)
	["128476.133764"] = 197386, -- Fangs of the Devourer (Soul Shadows)
	["127829.133764"] = 201460, -- Twinblades of the Deceiver (Unleashed Demons)
	["128943.133764"] = 211119, -- Skull of the Man'ari (Infernal Furnace)
	["128832.133764"] = 212817, -- The Aldrachi Warblades (Fiery Demise)
	-- Harbaron's Tether
	["127857.133768"] = 187276, -- Aluneth, Greatstaff of the Magna (Ethereal Sensitivity)
	["128820.133768"] = 194314, -- Felo'melorn (Everburning Consumption)
	["128862.133768"] = 195351, -- Ebonchill, Greatstaff of Alodi (Clarity of Thought)
	["128861.133768"] = 197162, -- Titanstrike (Jaws of Thunder)
	["128858.133768"] = 202466, -- Scythe of Elune (Sunfire Burns)
	["128866.133768"] = 209218, -- Truthguard (Consecration in Flame)
	["128832.133768"] = 212817, -- The Aldrachi Warblades (Fiery Demise)
	-- Glinting Shard of Sciallax
	["127857.131731"] = 187264, -- Aluneth, Greatstaff of the Magna (Aegwynn's Imperative)
	["128820.131731"] = 210182, -- Felo'melorn (Blue Flame Special)
	["128862.131731"] = 195323, -- Ebonchill, Greatstaff of Alodi (Orbital Strike)
	["128861.131731"] = 197139, -- Titanstrike (Focus of the Titans)
	["128858.131731"] = 202433, -- Scythe of Elune (Scythe of the Stars)
	["128866.131731"] = 209226, -- Truthguard (Righteous Crusader)
	["128832.131731"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	-- Blessing of the Watchers
	["120978.132775"] = 186945, -- Ashbringer (Wrath of the Ashbringer)
	["128825.132775"] = 196418, -- T'uure, Beacon of the Naaru (Reverence)
	["128868.132775"] = 197716, -- Light's Wrath (Burst of Light)
	["128823.132775"] = 200296, -- The Silver Hand (Expel the Darkness)
	["128866.132775"] = 209226, -- Truthguard (Righteous Crusader)
	-- Yotnar's Pride
	["127857.132776"] = 187264, -- Aluneth, Greatstaff of the Magna (Aegwynn's Imperative)
	["128820.132776"] = 210182, -- Felo'melorn (Blue Flame Special)
	["128862.132776"] = 195323, -- Ebonchill, Greatstaff of Alodi (Orbital Strike)
	["128861.132776"] = 197139, -- Titanstrike (Focus of the Titans)
	["128858.132776"] = 202433, -- Scythe of Elune (Scythe of the Stars)
	["128866.132776"] = 209226, -- Truthguard (Righteous Crusader)
	["128832.132776"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	-- Offering of Spilled Blood
	["128289.132777"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128403.132777"] = 224466, -- Apocalypse (Runic Tattoos)
	["128402.132777"] = 192457, -- Maw of the Damned (Veinrender)
	["128826.132777"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128870.132777"] = 192326, -- The Kingslayers (Balanced Blades)
	["128827.132777"] = 193645, -- Xal'atath, Blade of the Black Empire (Death's Embrace)
	["128942.132777"] = 199152, -- Ulthalesh, the Deadwind Harvester (Inherently Unstable)
	["128821.132777"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128872.132777"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.132777"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128910.132777"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128860.132777"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	-- Skovald's Betrayal
	["128941.132778"] = 196227, -- Scepter of Sargeras (Residual Flames)
	["128476.132778"] = 197235, -- Fangs of the Devourer (Precision Strike)
	["127829.132778"] = 201457, -- Twinblades of the Deceiver (Sharpened Glaives)
	["128943.132778"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	["128832.132778"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	-- Pillaged Honor
	["120978.132779"] = 186945, -- Ashbringer (Wrath of the Ashbringer)
	["128289.132779"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128403.132779"] = 224466, -- Apocalypse (Runic Tattoos)
	["128820.132779"] = 210182, -- Felo'melorn (Blue Flame Special)
	["128941.132779"] = 196227, -- Scepter of Sargeras (Residual Flames)
	["128819.132779"] = 198292, -- Doomhammer (Wind Strikes)
	["128821.132779"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128908.132779"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128943.132779"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	-- Grasp of the God-King
	["127857.132780"] = 187264, -- Aluneth, Greatstaff of the Magna (Aegwynn's Imperative)
	["128292.132780"] = 189164, -- Blades of the Fallen Prince (Dead of Winter)
	["128306.132780"] = 189757, -- G'Hanir, the Mother Tree (Infusion of Nature)
	["128935.132780"] = 191740, -- The Fist of Ra-den (Firestorm)
	["128862.132780"] = 195323, -- Ebonchill, Greatstaff of Alodi (Orbital Strike)
	["128937.132780"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128911.132780"] = 207206, -- Sharas'dal, Scepter of Tides (Wavecrash)
	["128860.132780"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	-- Archived Record of Might
	["128289.132781"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128402.132781"] = 192457, -- Maw of the Damned (Veinrender)
	["128870.132781"] = 192326, -- The Kingslayers (Balanced Blades)
	["128940.132781"] = 195266, -- Fists of the Heavens (Death Art)
	["128861.132781"] = 197139, -- Titanstrike (Focus of the Titans)
	["128819.132781"] = 198292, -- Doomhammer (Wind Strikes)
	["128908.132781"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128872.132781"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.132781"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128866.132781"] = 209226, -- Truthguard (Righteous Crusader)
	["128910.132781"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128832.132781"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	["128938.132781"] = 213062, -- Fu Zan, the Wanderer's Companion (Dark Side of the Moon)
	-- Yotnar's Gratitude
	["128306.132782"] = 189757, -- G'Hanir, the Mother Tree (Infusion of Nature)
	["128826.132782"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128825.132782"] = 196418, -- T'uure, Beacon of the Naaru (Reverence)
	["128937.132782"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128821.132782"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128823.132782"] = 200296, -- The Silver Hand (Expel the Darkness)
	["128858.132782"] = 202433, -- Scythe of Elune (Scythe of the Stars)
	["128911.132782"] = 207206, -- Sharas'dal, Scepter of Tides (Wavecrash)
	["128860.132782"] = 210579, -- Fangs of Ashamane (Ashamane's Energy)
	["128938.132782"] = 213062, -- Fu Zan, the Wanderer's Companion (Dark Side of the Moon)
	-- Echo of Aggramar
	["128292.132783"] = 189164, -- Blades of the Fallen Prince (Dead of Winter)
	["128403.132783"] = 224466, -- Apocalypse (Runic Tattoos)
	["128402.132783"] = 192457, -- Maw of the Damned (Veinrender)
	["128870.132783"] = 192326, -- The Kingslayers (Balanced Blades)
	["128827.132783"] = 193645, -- Xal'atath, Blade of the Black Empire (Death's Embrace)
	["128476.132783"] = 197235, -- Fangs of the Devourer (Precision Strike)
	["128868.132783"] = 197716, -- Light's Wrath (Burst of Light)
	["128942.132783"] = 199152, -- Ulthalesh, the Deadwind Harvester (Inherently Unstable)
	["127829.132783"] = 201457, -- Twinblades of the Deceiver (Sharpened Glaives)
	["128910.132783"] = 216274, -- Strom'kar, the Warbreaker (Many Will Fall)
	["128943.132783"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	-- Sorrow of Thwarted Champions
	-- Whispers of the Thorignir
	["128935.132785"] = 191740, -- The Fist of Ra-den (Firestorm)
	["128826.132785"] = 190467, -- Thas'dorah, Legacy of the Windrunners (Called Shot)
	["128940.132785"] = 195266, -- Fists of the Heavens (Death Art)
	["128861.132785"] = 197139, -- Titanstrike (Focus of the Titans)
	["128819.132785"] = 198292, -- Doomhammer (Wind Strikes)
	["128937.132785"] = 199372, -- Sheilun, Staff of the Mists (Extended Healing)
	["128908.132785"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128872.132785"] = 202522, -- The Dreadblades (Gunslinger)
	["128808.132785"] = 203638, -- Talonclaw, Spear of the Wild Gods (Raptor's Cry)
	["128938.132785"] = 213062, -- Fu Zan, the Wanderer's Companion (Dark Side of the Moon)
	-- Archived Record of Valor
	["120978.132786"] = 186927, -- Ashbringer (Deliver the Justice)
	["128825.132786"] = 196422, -- T'uure, Beacon of the Naaru (Holy Hands)
	["128868.132786"] = 197727, -- Light's Wrath (Doomsayer)
	["128823.132786"] = 200294, -- The Silver Hand (Deliver the Light)
	["128866.132786"] = 209223, -- Truthguard (Scatter the Shadows)
	-- Vault Guardian Core
	["127857.132787"] = 187313, -- Aluneth, Greatstaff of the Magna (Arcane Purification)
	["128820.132787"] = 194313, -- Felo'melorn (Great Balls of Fire)
	["128862.132787"] = 195345, -- Ebonchill, Greatstaff of Alodi (Frozen Veins)
	["128861.132787"] = 197140, -- Titanstrike (Spitting Cobras)
	["128858.132787"] = 202445, -- Scythe of Elune (Falling Star)
	["128866.132787"] = 209223, -- Truthguard (Scatter the Shadows)
	["128832.132787"] = 212816, -- The Aldrachi Warblades (Embrace the Pain)
	-- Yotnar's Turmoil
	["128289.132788"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128403.132788"] = 191494, -- Apocalypse (Scourge the Unbeliever)
	["128402.132788"] = 192460, -- Maw of the Damned (Coagulopathy)
	["128826.132788"] = 190520, -- Thas'dorah, Legacy of the Windrunners (Precision)
	["128870.132788"] = 192329, -- The Kingslayers (Gushing Wound)
	["128827.132788"] = 194007, -- Xal'atath, Blade of the Black Empire (Touch of Darkness)
	["128942.132788"] = 199153, -- Ulthalesh, the Deadwind Harvester (Seeds of Doom)
	["128821.132788"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128872.132788"] = 202524, -- The Dreadblades (Fatebringer)
	["128808.132788"] = 203669, -- Talonclaw, Spear of the Wild Gods (Fluffy, Go)
	["128910.132788"] = 209481, -- Strom'kar, the Warbreaker (Deathblow)
	["128860.132788"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	-- Twisted Tideskorn Rune
	["128941.132789"] = 196236, -- Scepter of Sargeras (Soulsnatcher)
	["128476.132789"] = 197369, -- Fangs of the Devourer (Fortune's Bite)
	["127829.132789"] = 201458, -- Twinblades of the Deceiver (Demon Rage)
	["128943.132789"] = 211105, -- Skull of the Man'ari (Dirty Hands)
	["128832.132789"] = 212816, -- The Aldrachi Warblades (Embrace the Pain)
	-- Rumblehoof's Flameheart
	["120978.132790"] = 186927, -- Ashbringer (Deliver the Justice)
	["128289.132790"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128403.132790"] = 191494, -- Apocalypse (Scourge the Unbeliever)
	["128820.132790"] = 194313, -- Felo'melorn (Great Balls of Fire)
	["128941.132790"] = 196236, -- Scepter of Sargeras (Soulsnatcher)
	["128819.132790"] = 198299, -- Doomhammer (Gathering Storms)
	["128821.132790"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128908.132790"] = 200856, -- Warswords of the Valarjar (Uncontrolled Rage)
	["128943.132790"] = 211105, -- Skull of the Man'ari (Dirty Hands)
	-- Archived Record of Will
	["127857.132791"] = 187313, -- Aluneth, Greatstaff of the Magna (Arcane Purification)
	["128292.132791"] = 189144, -- Blades of the Fallen Prince (Nothing but the Boots)
	["128306.132791"] = 189754, -- G'Hanir, the Mother Tree (Armor of the Ancients)
	["128935.132791"] = 191572, -- The Fist of Ra-den (Molten Blast)
	["128862.132791"] = 195345, -- Ebonchill, Greatstaff of Alodi (Frozen Veins)
	["128937.132791"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128911.132791"] = 207255, -- Sharas'dal, Scepter of Tides (Empowered Droplets)
	["128860.132791"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	-- Tideskorn War Brand
	["128289.132792"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128402.132792"] = 192460, -- Maw of the Damned (Coagulopathy)
	["128870.132792"] = 192329, -- The Kingslayers (Gushing Wound)
	["128940.132792"] = 195269, -- Fists of the Heavens (Power of a Thousand Cranes)
	["128861.132792"] = 197140, -- Titanstrike (Spitting Cobras)
	["128819.132792"] = 198299, -- Doomhammer (Gathering Storms)
	["128908.132792"] = 200856, -- Warswords of the Valarjar (Uncontrolled Rage)
	["128872.132792"] = 202524, -- The Dreadblades (Fatebringer)
	["128808.132792"] = 203669, -- Talonclaw, Spear of the Wild Gods (Fluffy, Go)
	["128866.132792"] = 209223, -- Truthguard (Scatter the Shadows)
	["128910.132792"] = 209481, -- Strom'kar, the Warbreaker (Deathblow)
	["128832.132792"] = 212816, -- The Aldrachi Warblades (Embrace the Pain)
	["128938.132792"] = 213055, -- Fu Zan, the Wanderer's Companion (Staggering Around)
	-- Spark of Will
	["128306.132793"] = 189754, -- G'Hanir, the Mother Tree (Armor of the Ancients)
	["128826.132793"] = 190520, -- Thas'dorah, Legacy of the Windrunners (Precision)
	["128825.132793"] = 196422, -- T'uure, Beacon of the Naaru (Holy Hands)
	["128937.132793"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128821.132793"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128823.132793"] = 200294, -- The Silver Hand (Deliver the Light)
	["128858.132793"] = 202445, -- Scythe of Elune (Falling Star)
	["128911.132793"] = 207255, -- Sharas'dal, Scepter of Tides (Empowered Droplets)
	["128860.132793"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	["128938.132793"] = 213055, -- Fu Zan, the Wanderer's Companion (Staggering Around)
	-- Runetwister Talisman
	["128292.132794"] = 189144, -- Blades of the Fallen Prince (Nothing but the Boots)
	["128403.132794"] = 191494, -- Apocalypse (Scourge the Unbeliever)
	["128402.132794"] = 192460, -- Maw of the Damned (Coagulopathy)
	["128870.132794"] = 192329, -- The Kingslayers (Gushing Wound)
	["128827.132794"] = 194007, -- Xal'atath, Blade of the Black Empire (Touch of Darkness)
	["128476.132794"] = 197369, -- Fangs of the Devourer (Fortune's Bite)
	["128868.132794"] = 197727, -- Light's Wrath (Doomsayer)
	["128942.132794"] = 199153, -- Ulthalesh, the Deadwind Harvester (Seeds of Doom)
	["127829.132794"] = 201458, -- Twinblades of the Deceiver (Demon Rage)
	["128910.132794"] = 209481, -- Strom'kar, the Warbreaker (Deathblow)
	["128943.132794"] = 211105, -- Skull of the Man'ari (Dirty Hands)
	-- Havi's Special Chowder
	-- Breath of the Vault
	["128935.132796"] = 191572, -- The Fist of Ra-den (Molten Blast)
	["128826.132796"] = 190520, -- Thas'dorah, Legacy of the Windrunners (Precision)
	["128940.132796"] = 195269, -- Fists of the Heavens (Power of a Thousand Cranes)
	["128861.132796"] = 197140, -- Titanstrike (Spitting Cobras)
	["128819.132796"] = 198299, -- Doomhammer (Gathering Storms)
	["128937.132796"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128908.132796"] = 200856, -- Warswords of the Valarjar (Uncontrolled Rage)
	["128872.132796"] = 202524, -- The Dreadblades (Fatebringer)
	["128808.132796"] = 203669, -- Talonclaw, Spear of the Wild Gods (Fluffy, Go)
	["128938.132796"] = 213055, -- Fu Zan, the Wanderer's Companion (Staggering Around)
	-- Thrymjaris' Grace
	["127857.132799"] = 210716, -- Aluneth, Greatstaff of the Magna (Mana Shield)
	["128820.132799"] = 194315, -- Felo'melorn (Molten Skin)
	["128862.132799"] = 214626, -- Ebonchill, Greatstaff of Alodi (Jouster)
	["128861.132799"] = 197138, -- Titanstrike (Natural Reflexes)
	["128858.132799"] = 203018, -- Scythe of Elune (Touch of the Moon)
	["128866.132799"] = 211912, -- Truthguard (Faith's Armor)
	["128832.132799"] = 212827, -- The Aldrachi Warblades (Shatter the Souls)
	-- Drekirjar Lifeblood
	["128289.132800"] = 188644, -- Scale of the Earth-Warder (Thunder Crash)
	["128403.132800"] = 191584, -- Apocalypse (Unholy Endurance)
	["128402.132800"] = 192538, -- Maw of the Damned (Bonebreaker)
	["128826.132800"] = 190514, -- Thas'dorah, Legacy of the Windrunners (Survival of the Fittest)
	["128870.132800"] = 192345, -- The Kingslayers (Shadow Walker)
	["128827.132800"] = 193647, -- Xal'atath, Blade of the Black Empire (Thoughts of Insanity)
	["128942.132800"] = 199214, -- Ulthalesh, the Deadwind Harvester (Long Dark Night of the Soul)
	["128821.132800"] = 200440, -- Claws of Ursoc (Vicious Bites)
	["128872.132800"] = 202533, -- The Dreadblades (Ghostly Shell)
	["128808.132800"] = 203749, -- Talonclaw, Spear of the Wild Gods (Hunter's Bounty)
	["128910.132800"] = 209541, -- Strom'kar, the Warbreaker (Touch of Zakajz)
	["128860.132800"] = 210590, -- Fangs of Ashamane (Attuned to Nature)
	-- Soul of Azariah
	["128941.132801"] = 196305, -- Scepter of Sargeras (Eternal Struggle)
	["128476.132801"] = 197244, -- Fangs of the Devourer (Ghost Armor)
	["127829.132801"] = 201463, -- Twinblades of the Deceiver (Deceiver's Fury)
	["128943.132801"] = 211131, -- Skull of the Man'ari (Firm Resolve)
	["128832.132801"] = 212827, -- The Aldrachi Warblades (Shatter the Souls)
	-- Hrydshal Forgeflame
	["120978.132802"] = 184778, -- Ashbringer (Deflection)
	["128289.132802"] = 188644, -- Scale of the Earth-Warder (Thunder Crash)
	["128403.132802"] = 191584, -- Apocalypse (Unholy Endurance)
	["128820.132802"] = 194315, -- Felo'melorn (Molten Skin)
	["128941.132802"] = 196305, -- Scepter of Sargeras (Eternal Struggle)
	["128819.132802"] = 198248, -- Doomhammer (Elemental Healing)
	["128821.132802"] = 200440, -- Claws of Ursoc (Vicious Bites)
	["128908.132802"] = 200859, -- Warswords of the Valarjar (Bloodcraze)
	["128943.132802"] = 211131, -- Skull of the Man'ari (Firm Resolve)
	-- Thorim's Peak Snowcap
	["127857.132803"] = 210716, -- Aluneth, Greatstaff of the Magna (Mana Shield)
	["128306.132803"] = 186320, -- G'Hanir, the Mother Tree (Grovewalker)
	["128935.132803"] = 191582, -- The Fist of Ra-den (Shamanistic Healing)
	["128862.132803"] = 214626, -- Ebonchill, Greatstaff of Alodi (Jouster)
	["128937.132803"] = 199384, -- Sheilun, Staff of the Mists (Spirit Tether)
	["128292.132803"] = 204875, -- Blades of the Fallen Prince (Frozen Skin)
	["128911.132803"] = 207354, -- Sharas'dal, Scepter of Tides (Caress of the Tidemother)
	["128860.132803"] = 210590, -- Fangs of Ashamane (Attuned to Nature)
	-- Sigil of Hrydshal
	["128289.132804"] = 188644, -- Scale of the Earth-Warder (Thunder Crash)
	["128402.132804"] = 192538, -- Maw of the Damned (Bonebreaker)
	["128870.132804"] = 192345, -- The Kingslayers (Shadow Walker)
	["128940.132804"] = 195380, -- Fists of the Heavens (Healing Winds)
	["128861.132804"] = 197138, -- Titanstrike (Natural Reflexes)
	["128819.132804"] = 198248, -- Doomhammer (Elemental Healing)
	["128908.132804"] = 200859, -- Warswords of the Valarjar (Bloodcraze)
	["128872.132804"] = 202533, -- The Dreadblades (Ghostly Shell)
	["128808.132804"] = 203749, -- Talonclaw, Spear of the Wild Gods (Hunter's Bounty)
	["128866.132804"] = 211912, -- Truthguard (Faith's Armor)
	["128910.132804"] = 209541, -- Strom'kar, the Warbreaker (Touch of Zakajz)
	["128832.132804"] = 212827, -- The Aldrachi Warblades (Shatter the Souls)
	["128938.132804"] = 213116, -- Fu Zan, the Wanderer's Companion (Face Palm)
	-- Stormborn Courage
	["128306.132805"] = 186320, -- G'Hanir, the Mother Tree (Grovewalker)
	["128826.132805"] = 190514, -- Thas'dorah, Legacy of the Windrunners (Survival of the Fittest)
	["128825.132805"] = 196355, -- T'uure, Beacon of the Naaru (Trust in the Light)
	["128937.132805"] = 199384, -- Sheilun, Staff of the Mists (Spirit Tether)
	["128821.132805"] = 200440, -- Claws of Ursoc (Vicious Bites)
	["128823.132805"] = 200302, -- The Silver Hand (Knight of the Silver Hand)
	["128858.132805"] = 203018, -- Scythe of Elune (Touch of the Moon)
	["128911.132805"] = 207354, -- Sharas'dal, Scepter of Tides (Caress of the Tidemother)
	["128860.132805"] = 210590, -- Fangs of Ashamane (Attuned to Nature)
	["128938.132805"] = 213116, -- Fu Zan, the Wanderer's Companion (Face Palm)
	-- Azariah's Last Moments
	["128403.132806"] = 191584, -- Apocalypse (Unholy Endurance)
	["128402.132806"] = 192538, -- Maw of the Damned (Bonebreaker)
	["128870.132806"] = 192345, -- The Kingslayers (Shadow Walker)
	["128827.132806"] = 193647, -- Xal'atath, Blade of the Black Empire (Thoughts of Insanity)
	["128476.132806"] = 197244, -- Fangs of the Devourer (Ghost Armor)
	["128868.132806"] = 216212, -- Light's Wrath (Darkest Shadows)
	["128942.132806"] = 199214, -- Ulthalesh, the Deadwind Harvester (Long Dark Night of the Soul)
	["127829.132806"] = 201463, -- Twinblades of the Deceiver (Deceiver's Fury)
	["128292.132806"] = 204875, -- Blades of the Fallen Prince (Frozen Skin)
	["128910.132806"] = 209541, -- Strom'kar, the Warbreaker (Touch of Zakajz)
	["128943.132806"] = 211131, -- Skull of the Man'ari (Firm Resolve)
	-- Mountainside Downpour
	-- Breath of Vethir
	["128935.132808"] = 191582, -- The Fist of Ra-den (Shamanistic Healing)
	["128826.132808"] = 190514, -- Thas'dorah, Legacy of the Windrunners (Survival of the Fittest)
	["128940.132808"] = 195380, -- Fists of the Heavens (Healing Winds)
	["128861.132808"] = 197138, -- Titanstrike (Natural Reflexes)
	["128819.132808"] = 198248, -- Doomhammer (Elemental Healing)
	["128937.132808"] = 199384, -- Sheilun, Staff of the Mists (Spirit Tether)
	["128908.132808"] = 200859, -- Warswords of the Valarjar (Bloodcraze)
	["128872.132808"] = 202533, -- The Dreadblades (Ghostly Shell)
	["128808.132808"] = 203749, -- Talonclaw, Spear of the Wild Gods (Hunter's Bounty)
	["128938.132808"] = 213116, -- Fu Zan, the Wanderer's Companion (Face Palm)
	-- Erratic Stormforce
	["127857.132810"] = 187321, -- Aluneth, Greatstaff of the Magna (Aegwynn's Wrath)
	["128820.132810"] = 194312, -- Felo'melorn (Burning Gaze)
	["128862.132810"] = 195322, -- Ebonchill, Greatstaff of Alodi (Let It Go)
	["128861.132810"] = 197080, -- Titanstrike (Pack Leader)
	["128858.132810"] = 202426, -- Scythe of Elune (Solar Stabbing)
	["128832.132810"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128866.132810"] = 209220, -- Truthguard (Unflinching Defense)
	-- Crystallized Tideskorn Cruelty
	["128289.132811"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128403.132811"] = 191485, -- Apocalypse (Plaguebearer)
	["128402.132811"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128826.132811"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128870.132811"] = 192318, -- The Kingslayers (Master Alchemist)
	["128827.132811"] = 193644, -- Xal'atath, Blade of the Black Empire (To the Pain)
	["128942.132811"] = 199120, -- Ulthalesh, the Deadwind Harvester (Drained to a Husk)
	["128821.132811"] = 208762, -- Claws of Ursoc (Mauler)
	["128872.132811"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.132811"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128910.132811"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128860.132811"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	-- Ritual Binding Stone
	["128941.132812"] = 196222, -- Scepter of Sargeras (Fire and the Flames)
	["128476.132812"] = 197234, -- Fangs of the Devourer (Gutripper)
	["127829.132812"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128832.132812"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128943.132812"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Thrymjaris' Fury
	["120978.132813"] = 184843, -- Ashbringer (Righteous Blade)
	["128289.132813"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128403.132813"] = 191485, -- Apocalypse (Plaguebearer)
	["128820.132813"] = 194312, -- Felo'melorn (Burning Gaze)
	["128941.132813"] = 196222, -- Scepter of Sargeras (Fire and the Flames)
	["128819.132813"] = 198247, -- Doomhammer (Wind Surge)
	["128821.132813"] = 208762, -- Claws of Ursoc (Mauler)
	["128908.132813"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128943.132813"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Drekirjar Jarl's Disdain
	["127857.132814"] = 187321, -- Aluneth, Greatstaff of the Magna (Aegwynn's Wrath)
	["128292.132814"] = 189086, -- Blades of the Fallen Prince (Blast Radius)
	["128306.132814"] = 189760, -- G'Hanir, the Mother Tree (Essence of Nordrassil)
	["128935.132814"] = 191504, -- The Fist of Ra-den (Lava Imbued)
	["128862.132814"] = 195322, -- Ebonchill, Greatstaff of Alodi (Let It Go)
	["128937.132814"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128911.132814"] = 210029, -- Sharas'dal, Scepter of Tides (Pull of the Sea)
	["128860.132814"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	-- Storm-Charged Lodestone
	["128289.132815"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128402.132815"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128870.132815"] = 192318, -- The Kingslayers (Master Alchemist)
	["128940.132815"] = 218607, -- Fists of the Heavens (Tiger Claws)
	["128861.132815"] = 197080, -- Titanstrike (Pack Leader)
	["128819.132815"] = 198247, -- Doomhammer (Wind Surge)
	["128908.132815"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128872.132815"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.132815"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128832.132815"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128866.132815"] = 209220, -- Truthguard (Unflinching Defense)
	["128910.132815"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128938.132815"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Hrydshal Weald
	["128306.132816"] = 189760, -- G'Hanir, the Mother Tree (Essence of Nordrassil)
	["128826.132816"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128825.132816"] = 196416, -- T'uure, Beacon of the Naaru (Serenity Now)
	["128937.132816"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128821.132816"] = 208762, -- Claws of Ursoc (Mauler)
	["128823.132816"] = 200315, -- The Silver Hand (Shock Treatment)
	["128858.132816"] = 202426, -- Scythe of Elune (Solar Stabbing)
	["128911.132816"] = 210029, -- Sharas'dal, Scepter of Tides (Pull of the Sea)
	["128860.132816"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	["128938.132816"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Shade of Thorim's Peak
	["128292.132817"] = 189086, -- Blades of the Fallen Prince (Blast Radius)
	["128403.132817"] = 191485, -- Apocalypse (Plaguebearer)
	["128402.132817"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128870.132817"] = 192318, -- The Kingslayers (Master Alchemist)
	["128827.132817"] = 193644, -- Xal'atath, Blade of the Black Empire (To the Pain)
	["128476.132817"] = 197234, -- Fangs of the Devourer (Gutripper)
	["128868.132817"] = 197715, -- Light's Wrath (The Edge of Dark and Light)
	["128942.132817"] = 199120, -- Ulthalesh, the Deadwind Harvester (Drained to a Husk)
	["127829.132817"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128910.132817"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128943.132817"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Raging Tempest Crux
	-- Thorignir Slipstream
	["128935.132819"] = 191504, -- The Fist of Ra-den (Lava Imbued)
	["128826.132819"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128940.132819"] = 218607, -- Fists of the Heavens (Tiger Claws)
	["128861.132819"] = 197080, -- Titanstrike (Pack Leader)
	["128819.132819"] = 198247, -- Doomhammer (Wind Surge)
	["128937.132819"] = 199367, -- Sheilun, Staff of the Mists (Protection of Shaohao)
	["128908.132819"] = 200849, -- Warswords of the Valarjar (Wrath and Fury)
	["128872.132819"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.132819"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128938.132819"] = 213180, -- Fu Zan, the Wanderer's Companion (Overflow)
	-- Helheim Waylight
	["120978.132824"] = 185368, -- Ashbringer (Might of the Templar)
	["128825.132824"] = 196429, -- T'uure, Beacon of the Naaru (Hallowed Ground)
	["128868.132824"] = 197729, -- Light's Wrath (Shield of Faith)
	["128823.132824"] = 200298, -- The Silver Hand (Blessings of the Silver Hand)
	["128866.132824"] = 209218, -- Truthguard (Consecration in Flame)
	-- Val'kyra Boon
	["127857.132825"] = 187304, -- Aluneth, Greatstaff of the Magna (Torrential Barrage)
	["128820.132825"] = 194224, -- Felo'melorn (Fire at Will)
	["128862.132825"] = 195315, -- Ebonchill, Greatstaff of Alodi (Icy Caress)
	["128861.132825"] = 197038, -- Titanstrike (Wilderness Expert)
	["128858.132825"] = 202384, -- Scythe of Elune (Dark Side of the Moon)
	["128832.132825"] = 207343, -- The Aldrachi Warblades (Aldrachi Design)
	["128866.132825"] = 209229, -- Truthguard (Hammer Time)
	-- Cursed Kvaldir Blood
	["128289.132826"] = 216272, -- Scale of the Earth-Warder (Rage of the Fallen)
	["128403.132826"] = 191442, -- Apocalypse (Rotten Touch)
	["128402.132826"] = 192453, -- Maw of the Damned (Meat Shield)
	["128826.132826"] = 190457, -- Thas'dorah, Legacy of the Windrunners (Windrunner's Guidance)
	["128870.132826"] = 192315, -- The Kingslayers (Serrated Edge)
	["128827.132826"] = 193643, -- Xal'atath, Blade of the Black Empire (Mind Shattering)
	["128942.132826"] = 199112, -- Ulthalesh, the Deadwind Harvester (Hideous Corruption)
	["128821.132826"] = 200399, -- Claws of Ursoc (Ursoc's Endurance)
	["128872.132826"] = 202507, -- The Dreadblades (Blade Dancer)
	["128808.132826"] = 203577, -- Talonclaw, Spear of the Wild Gods (My Beloved Monster)
	["128910.132826"] = 209462, -- Strom'kar, the Warbreaker (One Against Many)
	["128860.132826"] = 210571, -- Fangs of Ashamane (Feral Power)
	-- Gaze of Helya
	["128941.132827"] = 196222, -- Scepter of Sargeras (Fire and the Flames)
	["128476.132827"] = 197234, -- Fangs of the Devourer (Gutripper)
	["127829.132827"] = 201456, -- Twinblades of the Deceiver (Chaos Vision)
	["128832.132827"] = 207352, -- The Aldrachi Warblades (Honed Warblades)
	["128943.132827"] = 211106, -- Skull of the Man'ari (The Doom of Azeroth)
	-- Helhound Core
	["120978.132828"] = 186945, -- Ashbringer (Wrath of the Ashbringer)
	["128289.132828"] = 203230, -- Scale of the Earth-Warder (Leaping Giants)
	["128403.132828"] = 224466, -- Apocalypse (Runic Tattoos)
	["128820.132828"] = 210182, -- Felo'melorn (Blue Flame Special)
	["128941.132828"] = 196227, -- Scepter of Sargeras (Residual Flames)
	["128819.132828"] = 198292, -- Doomhammer (Wind Strikes)
	["128821.132828"] = 200402, -- Claws of Ursoc (Perpetual Spring)
	["128908.132828"] = 200853, -- Warswords of the Valarjar (Unstoppable)
	["128943.132828"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	-- Sliver of Helfrost
	["127857.132829"] = 187313, -- Aluneth, Greatstaff of the Magna (Arcane Purification)
	["128292.132829"] = 189144, -- Blades of the Fallen Prince (Nothing but the Boots)
	["128306.132829"] = 189754, -- G'Hanir, the Mother Tree (Armor of the Ancients)
	["128935.132829"] = 191572, -- The Fist of Ra-den (Molten Blast)
	["128862.132829"] = 195345, -- Ebonchill, Greatstaff of Alodi (Frozen Veins)
	["128937.132829"] = 199377, -- Sheilun, Staff of the Mists (Soothing Remedies)
	["128911.132829"] = 207255, -- Sharas'dal, Scepter of Tides (Empowered Droplets)
	["128860.132829"] = 210593, -- Fangs of Ashamane (Tear the Flesh)
	-- Cursebinder Chains
	["128289.132830"] = 188639, -- Scale of the Earth-Warder (Shatter the Bones)
	["128402.132830"] = 192464, -- Maw of the Damned (All-Consuming Rot)
	["128870.132830"] = 192376, -- The Kingslayers (Poison Knives)
	["128819.132830"] = 198238, -- Doomhammer (Spirit of the Maelstrom)
	["128908.132830"] = 200861, -- Warswords of the Valarjar (Raging Berserker)
	["128872.132830"] = 202907, -- The Dreadblades (Fortune's Boon)
	["128808.132830"] = 203673, -- Talonclaw, Spear of the Wild Gods (Hellcarver)
	["128940.132830"] = 195267, -- Fists of the Heavens (Strength of Xuen)
	["128861.132830"] = 206910, -- Titanstrike (Unleash the Beast)
	["128866.132830"] = 209216, -- Truthguard (Bastion of Truth)
	["128910.132830"] = 209494, -- Strom'kar, the Warbreaker (Exploit the Weakness)
	["128832.132830"] = 212819, -- The Aldrachi Warblades (Will of the Illidari)
	["128938.132830"] = 213136, -- Fu Zan, the Wanderer's Companion (Gifted Student)
	-- Worthy Soul
	["128306.132831"] = 186396, -- G'Hanir, the Mother Tree (Persistence)
	["128826.132831"] = 190503, -- Thas'dorah, Legacy of the Windrunners (Healing Shell)
	["128825.132831"] = 196489, -- T'uure, Beacon of the Naaru (Power of the Naaru)
	["128937.132831"] = 199365, -- Sheilun, Staff of the Mists (Shroud of Mist)
	["128821.132831"] = 200400, -- Claws of Ursoc (Wildflesh)
	["128823.132831"] = 200327, -- The Silver Hand (Share the Burden)
	["128858.132831"] = 202302, -- Scythe of Elune (Bladed Feathers)
	["128911.132831"] = 207351, -- Sharas'dal, Scepter of Tides (Ghost in the Mist)
	["128860.132831"] = 210557, -- Fangs of Ashamane (Honed Instincts)
	["128938.132831"] = 213047, -- Fu Zan, the Wanderer's Companion (Potent Kick)
	-- Bones of Geir
	["128403.132832"] = 191584, -- Apocalypse (Unholy Endurance)
	["128402.132832"] = 192538, -- Maw of the Damned (Bonebreaker)
	["128870.132832"] = 192345, -- The Kingslayers (Shadow Walker)
	["128827.132832"] = 193647, -- Xal'atath, Blade of the Black Empire (Thoughts of Insanity)
	["128476.132832"] = 197244, -- Fangs of the Devourer (Ghost Armor)
	["128868.132832"] = 216212, -- Light's Wrath (Darkest Shadows)
	["128942.132832"] = 199214, -- Ulthalesh, the Deadwind Harvester (Long Dark Night of the Soul)
	["127829.132832"] = 201463, -- Twinblades of the Deceiver (Deceiver's Fury)
	["128292.132832"] = 204875, -- Blades of the Fallen Prince (Frozen Skin)
	["128910.132832"] = 209541, -- Strom'kar, the Warbreaker (Touch of Zakajz)
	["128943.132832"] = 211131, -- Skull of the Man'ari (Firm Resolve)
	-- Wailing Winds
	["128935.132834"] = 191493, -- The Fist of Ra-den (Call the Thunder)
	["128826.132834"] = 190449, -- Thas'dorah, Legacy of the Windrunners (Deadly Aim)
	["128940.132834"] = 195243, -- Fists of the Heavens (Inner Peace)
	["128861.132834"] = 197038, -- Titanstrike (Wilderness Expert)
	["128819.132834"] = 215381, -- Doomhammer (Weapons of the Elements)
	["128937.132834"] = 199364, -- Sheilun, Staff of the Mists (Coalescing Mists)
	["128908.132834"] = 200846, -- Warswords of the Valarjar (Deathdealer)
	["128872.132834"] = 216230, -- The Dreadblades (Black Powder)
	["128808.132834"] = 203566, -- Talonclaw, Spear of the Wild Gods (Sharpened Fang)
	["128938.132834"] = 213051, -- Fu Zan, the Wanderer's Companion (Obsidian Fists)
	-- Embrace of the Valkyra
	["120978.132844"] = 186944, -- Ashbringer (Protector of the Ashen Blade)
	["128825.132844"] = 196430, -- T'uure, Beacon of the Naaru (Words of Healing)
	["128868.132844"] = 197762, -- Light's Wrath (Borrowed Time)
	["128866.132844"] = 209216, -- Truthguard (Bastion of Truth)
	["128823.132844"] = 200482, -- The Silver Hand (Second Sunrise)
	-- Odyn's Veil
	["127857.132845"] = 187258, -- Aluneth, Greatstaff of the Magna (Blasting Rod)
	["128820.132845"] = 194234, -- Felo'melorn (Reignition Overdrive)
	["128862.132845"] = 195317, -- Ebonchill, Greatstaff of Alodi (Ice Age)
	["128861.132845"] = 197047, -- Titanstrike (Furious Swipes)
	["128858.132845"] = 202386, -- Scythe of Elune (Twilight Glow)
	["128832.132845"] = 207347, -- The Aldrachi Warblades (Aura of Pain)
	["128866.132845"] = 209217, -- Truthguard (Stern Judgment)
	-- Felbound Plasma
	["128289.132846"] = 188683, -- Scale of the Earth-Warder (Will to Survive)
	["128403.132846"] = 191485, -- Apocalypse (Plaguebearer)
	["128402.132846"] = 192447, -- Maw of the Damned (Grim Perseverance)
	["128826.132846"] = 190462, -- Thas'dorah, Legacy of the Windrunners (Quick Shot)
	["128870.132846"] = 192318, -- The Kingslayers (Master Alchemist)
	["128827.132846"] = 193644, -- Xal'atath, Blade of the Black Empire (To the Pain)
	["128942.132846"] = 199120, -- Ulthalesh, the Deadwind Harvester (Drained to a Husk)
	["128821.132846"] = 208762, -- Claws of Ursoc (Mauler)
	["128872.132846"] = 202514, -- The Dreadblades (Fate's Thirst)
	["128808.132846"] = 203578, -- Talonclaw, Spear of the Wild Gods (Lacerating Talons)
	["128910.132846"] = 209472, -- Strom'kar, the Warbreaker (Crushing Blows)
	["128860.132846"] = 210575, -- Fangs of Ashamane (Powerful Bite)
	-- Valgrinn's Heart
	["128941.132847"] = 196227, -- Scepter of Sargeras (Residual Flames)
	["128476.132847"] = 197235, -- Fangs of the Devourer (Precision Strike)
	["127829.132847"] = 201457, -- Twinblades of the Deceiver (Sharpened Glaives)
	["128943.132847"] = 211123, -- Skull of the Man'ari (Sharpened Dreadfangs)
	["128832.132847"] = 207375, -- The Aldrachi Warblades (Infernal Force)
	-- Flame of Valhallas
	["120978.132848"] = 186927, -- Ashbringer (Deliver the Justice)
	["128289.132848"] = 203225, -- Scale of the Earth-Warder (Dragon Skin)
	["128403.132848"] = 191494, -- Apocalypse (Scourge the Unbeliever)
	["128820.132848"] = 194313, -- Felo'melorn (Great Balls of Fire)
	["128941.132848"] = 196236, -- Scepter of Sargeras (Soulsnatcher)
	["128819.132848"] = 198299, -- Doomhammer (Gathering Storms)
	["128821.132848"] = 200409, -- Claws of Ursoc (Jagged Claws)
	["128908.132848"] = 200856, -- Warswords of the Valarjar (Uncontrolled Rage)
	["128943.132848"] = 211105, -- Skull of the Man'ari (Dirty Hands)
	-- Dravak's Jailing Shard
	["127857.132849"] = 187276, -- Aluneth, Greatstaff of the Magna (Ethereal Sensitivity)
	["128292.132849"] = 189147, -- Blades of the Fallen Prince (Bad to the Bone)
	["128306.132849"] = 189749, -- G'Hanir, the Mother Tree (Natural Mending)
	["128935.132849"] = 191577, -- The Fist of Ra-den (Electric Discharge)
	["128862.132849"] = 195351, -- Ebonchill, Greatstaff of Alodi (Clarity of Thought)
	["128937.132849"] = 199380, -- Sheilun, Staff of the Mists (Infusion of Life)
	["128911.132849"] = 207285, -- Sharas'dal, Scepter of Tides (Queen Ascendant)
	["128860.132849"] = 210637, -- Fangs of Ashamane (Sharpened Claws)
	-- Stormforged Horn
	["128289.132850"] = 188632, -- Scale of the Earth-Warder (Toughness)
	["128402.132850"] = 192514, -- Maw of the Damned (Dance of Darkness)
	["128870.132850"] = 192323, -- The Kingslayers (Fade into Shadows)
	["128940.132850"] = 195244, -- Fists of the Heavens (Light on Your Feet)
	["128861.132850"] = 197160, -- Titanstrike (Mimiron's Shell)
	["128819.132850"] = 198296, -- Doomhammer (Spiritual Healing)
	["128908.132850"] = 200857, -- Warswords of the Valarjar (Battle Scars)
	["128872.132850"] = 202521, -- The Dreadblades (Fortune's Strike)
	["128808.132850"] = 224764, -- Talonclaw, Spear of the Wild Gods (Bird of Prey)
	["128866.132850"] = 209224, -- Truthguard (Resolve of Truth)
	["128910.132850"] = 209483, -- Strom'kar, the Warbreaker (Tactical Advance)
	["128832.132850"] = 212821, -- The Aldrachi Warblades (Devour Souls)
	["128938.132850"] = 213047, -- Fu Zan, the Wanderer's Companion (Potent Kick)
	-- Sprig of Valhallas
	["128306.132851"] = 186320, -- G'Hanir, the Mother Tree (Grovewalker)
	["128826.132851"] = 190514, -- Thas'dorah, Legacy of the Windrunners (Survival of the Fittest)
	["128825.132851"] = 196355, -- T'uure, Beacon of the Naaru (Trust in the Light)
	["128937.132851"] = 199384, -- Sheilun, Staff of the Mists (Spirit Tether)
	["128821.132851"] = 200440, -- Claws of Ursoc (Vicious Bites)
	["128823.132851"] = 200302, -- The Silver Hand (Knight of the Silver Hand)
	["128858.132851"] = 203018, -- Scythe of Elune (Touch of the Moon)
	["128911.132851"] = 207354, -- Sharas'dal, Scepter of Tides (Caress of the Tidemother)
	["128860.132851"] = 210590, -- Fangs of Ashamane (Attuned to Nature)
	["128938.132851"] = 213116, -- Fu Zan, the Wanderer's Companion (Face Palm)
	-- Horn of Helheim
	["128292.132852"] = 189080, -- Blades of the Fallen Prince (Cold as Ice)
	["128403.132852"] = 191419, -- Apocalypse (Deadliest Coil)
	["128402.132852"] = 192450, -- Maw of the Damned (Iron Heart)
	["128870.132852"] = 192310, -- The Kingslayers (Toxic Blades)
	["128827.132852"] = 194093, -- Xal'atath, Blade of the Black Empire (Unleash the Shadows)
	["128476.132852"] = 197231, -- Fangs of the Devourer (The Quiet Knife)
	["128868.132852"] = 197708, -- Light's Wrath (Confession)
	["128942.132852"] = 199111, -- Ulthalesh, the Deadwind Harvester (Inimitable Agony)
	["127829.132852"] = 201454, -- Twinblades of the Deceiver (Contained Fury)
	["128910.132852"] = 209459, -- Strom'kar, the Warbreaker (Unending Rage)
	["128943.132852"] = 211108, -- Skull of the Man'ari (Summoner's Prowess)
	-- Fel-Tainted Haze
	["128935.132854"] = 191499, -- The Fist of Ra-den (The Ground Trembles)
	["128826.132854"] = 190457, -- Thas'dorah, Legacy of the Windrunners (Windrunner's Guidance)
	["128940.132854"] = 195263, -- Fists of the Heavens (Rising Winds)
	["128861.132854"] = 197047, -- Titanstrike (Furious Swipes)
	["128819.132854"] = 198236, -- Doomhammer (Forged in Lava)
	["128937.132854"] = 199366, -- Sheilun, Staff of the Mists (Way of the Mistweaver)
	["128908.132854"] = 216273, -- Warswords of the Valarjar (Wild Slashes)
	["128872.132854"] = 202507, -- The Dreadblades (Blade Dancer)
	["128808.132854"] = 203577, -- Talonclaw, Spear of the Wild Gods (My Beloved Monster)
	["128938.132854"] = 227687, -- Fu Zan, the Wanderer's Companion (Hot Blooded)

	-- BEGIN 7.1 Relic Data
	["128832.143523"] = 207375,
	["128820.143523"] = 210182,
	["128858.143523"] = 202433,
	["128862.143523"] = 195323,
	["128866.143523"] = 209226,
	["127857.143523"] = 187264,
	["128861.143523"] = 197139,

	["128826.143524"] = 190520,
	["128942.143524"] = 199153,
	["128403.143524"] = 191494,
	["128808.143524"] = 203669,
	["128910.143524"] = 209481,
	["128289.143524"] = 203225,
	["128402.143524"] = 192460,
	["128872.143524"] = 202524,
	["128821.143524"] = 200409,
	["128860.143524"] = 210593,
	["128827.143524"] = 194007,
	["128870.143524"] = 192329,

	["128943.143525"] = 211106,
	["128832.143525"] = 207352,
	["128941.143525"] = 196222,
	["127829.143525"] = 201456,
	["128476.143525"] = 197234,

	["128941.143526"] = 196217,
	["128821.143526"] = 200399,
	["128820.143526"] = 194234,
	["128819.143526"] = 198236,
	["128403.143526"] = 191442,
	["120978.143526"] = 184759,
	["128908.143526"] = 216273,
	["128943.143526"] = 211126,
	["128289.143526"] = 216272,

	["128860.143527"] = 210631,
	["128306.143527"] = 189744,
	["128911.143527"] = 207348,
	["128862.143527"] = 195352,
	["128292.143527"] = 189097,
	["127857.143527"] = 187287,
	["128935.143527"] = 191598,
	["128937.143527"] = 199485,

	["128866.143528"] = 209229,
	["128823.143528"] = 200326,
	["128825.143528"] = 196434,
	["128868.143528"] = 197708,
	["120978.143528"] = 186941,

	["128819.143529"] = 198349,
	["128832.143529"] = 212817,
	["128289.143529"] = 203227,
	["128402.143529"] = 192542,
	["128910.143529"] = 209492,
	["128908.143529"] = 200860,
	["128938.143529"] = 213133,
	["128940.143529"] = 195291,
	["128808.143529"] = 203670,
	["128866.143529"] = 209218,
	["128861.143529"] = 197162,
	["128872.143529"] = 202530,
	["128870.143529"] = 192349,

	["128826.143530"] = 190462,
	["128937.143530"] = 199367,
	["128825.143530"] = 196416,
	["128938.143530"] = 213180,
	["128821.143530"] = 208762,
	["128858.143530"] = 202426,
	["128306.143530"] = 189760,
	["128860.143530"] = 210575,
	["128911.143530"] = 207118,
	["128823.143530"] = 200315,

	["128870.143531"] = 192310,
	["128827.143531"] = 194093,
	["127829.143531"] = 201454,
	["128476.143531"] = 197231,
	["128292.143531"] = 189080,
	["128402.143531"] = 192450,
	["128943.143531"] = 211108,
	["128910.143531"] = 209459,
	["128868.143531"] = 197708,
	["128942.143531"] = 199111,
	["128403.143531"] = 191419,

	["128935.143532"] = 191493,
	["128938.143532"] = 213051,
	["128940.143532"] = 195243,
	["128808.143532"] = 203566,
	["128908.143532"] = 200846,
	["128937.143532"] = 199364,
	["128826.143532"] = 190449,
	["128819.143532"] = 215381,
	["128861.143532"] = 197038,
	["128872.143532"] = 216230,

	["128832.142176"] = 212819,
	["128820.142176"] = 194239,
	["128858.142176"] = 202464,
	["128866.142176"] = 209216,
	["128862.142176"] = 195352,
	["127857.142176"] = 187287,
	["128861.142176"] = 206910,

	["128860.142180"] = 210570,
	["128827.142180"] = 194093,
	["128870.142180"] = 192310,
	["128872.142180"] = 216230,
	["128821.142180"] = 200395,
	["128808.142180"] = 203566,
	["128910.142180"] = 209459,
	["128289.142180"] = 188635,
	["128402.142180"] = 192450,
	["128826.142180"] = 190449,
	["128942.142180"] = 199111,
	["128403.142180"] = 191419,

	["128832.142181"] = 207343,
	["128943.142181"] = 211108,
	["128476.142181"] = 197231,
	["128941.142181"] = 196211,
	["127829.142181"] = 201454,

	["128476.142182"] = 197235,
	["127829.142182"] = 201457,
	["128941.142182"] = 196227,
	["128832.142182"] = 207375,
	["128943.142182"] = 211123,

	["128832.142305"] = 212816,
	["128820.142305"] = 194313,
	["127857.142305"] = 187313,
	["128861.142305"] = 197140,
	["128858.142305"] = 202445,
	["128862.142305"] = 195345,
	["128866.142305"] = 209223,

	["128819.142306"] = 215381,
	["128910.142306"] = 209459,
	["128938.142306"] = 213051,
	["128908.142306"] = 200846,
	["128808.142306"] = 203566,
	["128940.142306"] = 195243,
	["128832.142306"] = 207343,
	["128289.142306"] = 188635,
	["128402.142306"] = 192450,
	["128861.142306"] = 197038,
	["128872.142306"] = 216230,
	["128866.142306"] = 209229,
	["128870.142306"] = 192310,

	["128820.142307"] = 194314,
	["128821.142307"] = 200414,
	["128941.142307"] = 196432,
	["128289.142307"] = 203227,
	["128943.142307"] = 211119,
	["128908.142307"] = 200860,
	["120978.142307"] = 185368,
	["128403.142307"] = 191488,
	["128819.142307"] = 198349,

	["128862.142308"] = 195323,
	["127857.142308"] = 187264,
	["128292.142308"] = 189164,
	["128911.142308"] = 207206,
	["128860.142308"] = 210579,
	["128306.142308"] = 189757,
	["128937.142308"] = 199372,
	["128935.142308"] = 191740,

	["128938.142309"] = 213062,
	["128937.142309"] = 199372,
	["128825.142309"] = 196418,
	["128826.142309"] = 190467,
	["128860.142309"] = 210579,
	["128306.142309"] = 189757,
	["128823.142309"] = 200296,
	["128911.142309"] = 207206,
	["128821.142309"] = 200402,
	["128858.142309"] = 202433,

	["128943.142310"] = 211119,
	["128402.142310"] = 192542,
	["128910.142310"] = 209492,
	["128403.142310"] = 191488,
	["128942.142310"] = 199158,
	["128868.142310"] = 197729,
	["128870.142310"] = 192349,
	["128827.142310"] = 194016,
	["128476.142310"] = 197386,
	["127829.142310"] = 201460,
	["128292.142310"] = 189147,

	["128935.140040"] = 191598,
	["128937.140040"] = 199485,
	["128306.140040"] = 189744,
	["128860.140040"] = 210631,
	["128911.140040"] = 207348,
	["128292.140040"] = 189097,
	["127857.140040"] = 187287,
	["128862.140040"] = 195352,

	["128861.140069"] = 197140,
	["128872.140069"] = 202524,
	["128937.140069"] = 199377,
	["128826.140069"] = 190520,
	["128819.140069"] = 198299,
	["128935.140069"] = 191572,
	["128938.140069"] = 213055,
	["128940.140069"] = 195269,
	["128908.140069"] = 200856,
	["128808.140069"] = 203669,

	["128402.140071"] = 192447,
	["128943.140071"] = 211106,
	["128910.140071"] = 209472,
	["128942.140071"] = 199120,
	["128868.140071"] = 197715,
	["128403.140071"] = 191485,
	["128870.140071"] = 192318,
	["128827.140071"] = 193644,
	["127829.140071"] = 201456,
	["128476.140071"] = 197234,
	["128292.140071"] = 189086,

	["120978.140072"] = 184759,
	["128825.140072"] = 196358,
	["128868.140072"] = 197713,
	["128823.140072"] = 200316,
	["128866.140072"] = 209217,

	["128820.140073"] = 194224,
	["128941.140073"] = 196211,
	["128821.140073"] = 200395,
	["120978.140073"] = 186941,
	["128908.140073"] = 200846,
	["128943.140073"] = 211108,
	["128289.140073"] = 188635,
	["128819.140073"] = 215381,
	["128403.140073"] = 191419,

	["128289.140074"] = 188644,
	["128402.140074"] = 192538,
	["128808.140074"] = 203749,
	["128910.140074"] = 209541,
	["128942.140074"] = 199214,
	["128403.140074"] = 191584,
	["128826.140074"] = 190514,
	["128870.140074"] = 192345,
	["128827.140074"] = 193647,
	["128860.140074"] = 210590,
	["128821.140074"] = 200440,
	["128872.140074"] = 202533,

	["128870.140075"] = 192323,
	["128872.140075"] = 202521,
	["128861.140075"] = 197160,
	["128866.140075"] = 209224,
	["128940.140075"] = 195244,
	["128908.140075"] = 200857,
	["128938.140075"] = 213047,
	["128808.140075"] = 224764,
	["128910.140075"] = 209483,
	["128402.140075"] = 192514,
	["128289.140075"] = 188632,
	["128832.140075"] = 212821,
	["128819.140075"] = 198296,

	["128943.140076"] = 211099,
	["128832.140076"] = 212819,
	["128941.140076"] = 196258,
	["127829.140076"] = 201464,
	["128476.140076"] = 197239,

	["127857.140077"] = 187276,
	["128861.140077"] = 197162,
	["128858.140077"] = 202466,
	["128862.140077"] = 195351,
	["128866.140077"] = 209218,
	["128820.140077"] = 194314,
	["128832.140077"] = 212817,

	["128858.140078"] = 202445,
	["128821.140078"] = 200409,
	["128911.140078"] = 207255,
	["128823.140078"] = 200294,
	["128860.140078"] = 210593,
	["128306.140078"] = 189754,
	["128825.140078"] = 196422,
	["128937.140078"] = 199377,
	["128826.140078"] = 190520,
	["128938.140078"] = 213055,

	["128832.142175"] = 207352,
	["128820.142175"] = 194312,
	["128866.142175"] = 209220,
	["128862.142175"] = 195322,
	["128858.142175"] = 202426,
	["128861.142175"] = 197080,
	["127857.142175"] = 187321,

	["128289.142177"] = 203230,
	["128402.142177"] = 192457,
	["128832.142177"] = 207375,
	["128908.142177"] = 200853,
	["128940.142177"] = 195266,
	["128938.142177"] = 213062,
	["128808.142177"] = 203638,
	["128910.142177"] = 216274,
	["128819.142177"] = 198292,
	["128870.142177"] = 192326,
	["128866.142177"] = 209226,
	["128872.142177"] = 202522,
	["128861.142177"] = 197139,

	["128872.142178"] = 202514,
	["128861.142178"] = 197080,
	["128866.142178"] = 209220,
	["128870.142178"] = 192318,
	["128819.142178"] = 198247,
	["128808.142178"] = 203578,
	["128908.142178"] = 200849,
	["128938.142178"] = 213180,
	["128940.142178"] = 218607,
	["128910.142178"] = 209472,
	["128402.142178"] = 192447,
	["128289.142178"] = 188683,
	["128832.142178"] = 207352,

	["128870.142179"] = 192315,
	["128827.142179"] = 193643,
	["128860.142179"] = 210571,
	["128821.142179"] = 200399,
	["128872.142179"] = 202507,
	["128402.142179"] = 192453,
	["128289.142179"] = 216272,
	["128808.142179"] = 203577,
	["128910.142179"] = 209462,
	["128942.142179"] = 199112,
	["128403.142179"] = 191442,
	["128826.142179"] = 190457,

	["128820.142183"] = 194239,
	["128821.142183"] = 200415,
	["128941.142183"] = 196258,
	["128289.142183"] = 188639,
	["128943.142183"] = 211099,
	["128908.142183"] = 200861,
	["120978.142183"] = 186944,
	["128403.142183"] = 208598,
	["128819.142183"] = 198238,

	["128941.142184"] = 196236,
	["128821.142184"] = 200409,
	["128820.142184"] = 194313,
	["128819.142184"] = 198299,
	["128403.142184"] = 191494,
	["120978.142184"] = 186927,
	["128908.142184"] = 200856,
	["128943.142184"] = 211105,
	["128289.142184"] = 203225,

	["128937.142185"] = 199366,
	["128935.142185"] = 191499,
	["128292.142185"] = 189092,
	["127857.142185"] = 187258,
	["128862.142185"] = 195317,
	["128306.142185"] = 189768,
	["128860.142185"] = 210571,
	["128911.142185"] = 207092,

	["128937.142186"] = 199364,
	["128935.142186"] = 191493,
	["128862.142186"] = 195315,
	["127857.142186"] = 187304,
	["128292.142186"] = 189080,
	["128911.142186"] = 207088,
	["128860.142186"] = 210570,
	["128306.142186"] = 189772,

	["128866.142187"] = 209218,
	["128823.142187"] = 200298,
	["128825.142187"] = 196429,
	["128868.142187"] = 197729,
	["120978.142187"] = 185368,

	["128868.142188"] = 197727,
	["128825.142188"] = 196422,
	["120978.142188"] = 186927,
	["128866.142188"] = 209223,
	["128823.142188"] = 200294,

	["128860.142189"] = 210557,
	["128306.142189"] = 186396,
	["128911.142189"] = 207351,
	["128823.142189"] = 200327,
	["128821.142189"] = 200400,
	["128858.142189"] = 202302,
	["128938.142189"] = 213047,
	["128937.142189"] = 199365,
	["128825.142189"] = 196489,
	["128826.142189"] = 190503,

	["128858.142190"] = 202386,
	["128821.142190"] = 200399,
	["128823.142190"] = 200316,
	["128911.142190"] = 207092,
	["128860.142190"] = 210571,
	["128306.142190"] = 189768,
	["128825.142190"] = 196358,
	["128937.142190"] = 199366,
	["128826.142190"] = 190457,
	["128938.142190"] = 213049,

	["128868.142191"] = 197715,
	["128942.142191"] = 199120,
	["128403.142191"] = 191485,
	["128910.142191"] = 209472,
	["128943.142191"] = 211106,
	["128402.142191"] = 192447,
	["128292.142191"] = 189086,
	["127829.142191"] = 201456,
	["128476.142191"] = 197234,
	["128827.142191"] = 193644,
	["128870.142191"] = 192318,

	["128476.142192"] = 197239,
	["127829.142192"] = 201464,
	["128292.142192"] = 189097,
	["128870.142192"] = 192376,
	["128827.142192"] = 194002,
	["128403.142192"] = 208598,
	["128942.142192"] = 199163,
	["128868.142192"] = 197762,
	["128943.142192"] = 211099,
	["128402.142192"] = 192464,
	["128910.142192"] = 209494,

	["128872.142193"] = 202507,
	["128861.142193"] = 197047,
	["128935.142193"] = 191499,
	["128938.142193"] = 213049,
	["128940.142193"] = 195263,
	["128808.142193"] = 203577,
	["128908.142193"] = 216273,
	["128937.142193"] = 199366,
	["128819.142193"] = 198236,
	["128826.142193"] = 190457,

	["128938.142194"] = 213133,
	["128940.142194"] = 195291,
	["128808.142194"] = 203670,
	["128908.142194"] = 200860,
	["128935.142194"] = 191577,
	["128819.142194"] = 198349,
	["128826.142194"] = 190529,
	["128937.142194"] = 199380,
	["128872.142194"] = 202530,
	["128861.142194"] = 197162,

	["128403.142510"] = 191488,
	["128942.142510"] = 199158,
	["128826.142510"] = 190529,
	["128289.142510"] = 203227,
	["128402.142510"] = 192542,
	["128910.142510"] = 209492,
	["128808.142510"] = 203670,
	["128821.142510"] = 200414,
	["128872.142510"] = 202530,
	["128870.142510"] = 192349,
	["128860.142510"] = 210637,
	["128827.142510"] = 194016,

	["128866.142511"] = 209226,
	["128872.142511"] = 202522,
	["128861.142511"] = 197139,
	["128870.142511"] = 192326,
	["128819.142511"] = 198292,
	["128289.142511"] = 203230,
	["128402.142511"] = 192457,
	["128832.142511"] = 207375,
	["128908.142511"] = 200853,
	["128940.142511"] = 195266,
	["128938.142511"] = 213062,
	["128808.142511"] = 203638,
	["128910.142511"] = 216274,

	["128402.142512"] = 192464,
	["128943.142512"] = 211099,
	["128910.142512"] = 209494,
	["128942.142512"] = 199163,
	["128868.142512"] = 197762,
	["128403.142512"] = 208598,
	["128870.142512"] = 192376,
	["128827.142512"] = 194002,
	["127829.142512"] = 201464,
	["128476.142512"] = 197239,
	["128292.142512"] = 189097,

	["128832.142513"] = 207352,
	["128943.142513"] = 211106,
	["128476.142513"] = 197234,
	["128941.142513"] = 196222,
	["127829.142513"] = 201456,

	["128832.142514"] = 207375,
	["128858.142514"] = 202433,
	["128866.142514"] = 209226,
	["128862.142514"] = 195323,
	["127857.142514"] = 187264,
	["128861.142514"] = 197139,
	["128820.142514"] = 210182,

	["128937.142515"] = 199364,
	["128935.142515"] = 191493,
	["128862.142515"] = 195315,
	["128292.142515"] = 189080,
	["127857.142515"] = 187304,
	["128860.142515"] = 210570,
	["128306.142515"] = 189772,
	["128911.142515"] = 207088,

	["128820.142516"] = 194314,
	["128941.142516"] = 196432,
	["128821.142516"] = 200414,
	["128908.142516"] = 200860,
	["120978.142516"] = 185368,
	["128943.142516"] = 211119,
	["128289.142516"] = 203227,
	["128819.142516"] = 198349,
	["128403.142516"] = 191488,

	["128938.142517"] = 213049,
	["128826.142517"] = 190457,
	["128937.142517"] = 199366,
	["128825.142517"] = 196358,
	["128860.142517"] = 210571,
	["128306.142517"] = 189768,
	["128911.142517"] = 207092,
	["128823.142517"] = 200316,
	["128858.142517"] = 202386,
	["128821.142517"] = 200399,

	["128872.142518"] = 202524,
	["128861.142518"] = 197140,
	["128819.142518"] = 198299,
	["128826.142518"] = 190520,
	["128937.142518"] = 199377,
	["128938.142518"] = 213055,
	["128908.142518"] = 200856,
	["128940.142518"] = 195269,
	["128808.142518"] = 203669,
	["128935.142518"] = 191572,

	["128866.142519"] = 209218,
	["128823.142519"] = 200298,
	["128825.142519"] = 196429,
	["128868.142519"] = 197729,
	["120978.142519"] = 185368,

	["128935.140070"] = 191740,
	["128937.140070"] = 199372,
	["128911.140070"] = 207206,
	["128306.140070"] = 189757,
	["128860.140070"] = 210579,
	["127857.140070"] = 187264,
	["128292.140070"] = 189164,
	["128862.140070"] = 195323,

	["128872.140039"] = 202907,
	["128861.140039"] = 206910,
	["128937.140039"] = 199485,
	["128819.140039"] = 198238,
	["128826.140039"] = 190567,
	["128935.140039"] = 191598,
	["128938.140039"] = 213136,
	["128908.140039"] = 200861,
	["128940.140039"] = 195267,
	["128808.140039"] = 203673,

	["127829.140046"] = 201464,
	["128941.140046"] = 196258,
	["128476.140046"] = 197239,
	["128943.140046"] = 211099,
	["128832.140046"] = 212819,

	["128938.140048"] = 213136,
	["128937.140048"] = 199485,
	["128825.140048"] = 196430,
	["128826.140048"] = 190567,
	["128860.140048"] = 210631,
	["128306.140048"] = 189744,
	["128823.140048"] = 200482,
	["128911.140048"] = 207348,
	["128821.140048"] = 200415,
	["128858.140048"] = 202464,

	["128827.140041"] = 194002,
	["128870.140041"] = 192376,
	["128292.140041"] = 189097,
	["127829.140041"] = 201464,
	["128476.140041"] = 197239,
	["128910.140041"] = 209494,
	["128943.140041"] = 211099,
	["128402.140041"] = 192464,
	["128942.140041"] = 199163,
	["128868.140041"] = 197762,
	["128403.140041"] = 208598,

	["128866.140042"] = 209216,
	["128823.140042"] = 200482,
	["128825.140042"] = 196430,
	["128868.140042"] = 197762,
	["120978.140042"] = 186944,

	["128289.140043"] = 203227,
	["128943.140043"] = 211119,
	["120978.140043"] = 185368,
	["128908.140043"] = 200860,
	["128403.140043"] = 191488,
	["128819.140043"] = 198349,
	["128820.140043"] = 194314,
	["128941.140043"] = 196432,
	["128821.140043"] = 200414,

	["128860.140044"] = 210579,
	["128827.140044"] = 193645,
	["128870.140044"] = 192326,
	["128872.140044"] = 202522,
	["128821.140044"] = 200402,
	["128808.140044"] = 203638,
	["128910.140044"] = 216274,
	["128402.140044"] = 192457,
	["128289.140044"] = 203230,
	["128826.140044"] = 190467,
	["128942.140044"] = 199152,
	["128403.140044"] = 191592,

	["128870.140045"] = 192315,
	["128861.140045"] = 197047,
	["128872.140045"] = 202507,
	["128866.140045"] = 209217,
	["128910.140045"] = 209462,
	["128940.140045"] = 195263,
	["128908.140045"] = 216273,
	["128938.140045"] = 213049,
	["128808.140045"] = 203577,
	["128832.140045"] = 207347,
	["128402.140045"] = 192453,
	["128289.140045"] = 216272,
	["128819.140045"] = 198236,

	["128820.140047"] = 210182,
	["128858.140047"] = 202433,
	["128866.140047"] = 209226,
	["128862.140047"] = 195323,
	["127857.140047"] = 187264,
	["128861.140047"] = 197139,
	["128832.140047"] = 207375,

	["128872.140079"] = 216230,
	["128861.140079"] = 197038,
	["128937.140079"] = 199364,
	["128819.140079"] = 215381,
	["128826.140079"] = 190449,
	["128935.140079"] = 191493,
	["128938.140079"] = 213051,
	["128940.140079"] = 195243,
	["128808.140079"] = 203566,
	["128908.140079"] = 200846,

	["127857.140080"] = 187313,
	["128292.140080"] = 189144,
	["128862.140080"] = 195345,
	["128911.140080"] = 207255,
	["128306.140080"] = 189754,
	["128860.140080"] = 210593,
	["128937.140080"] = 199377,
	["128935.140080"] = 191572,

	["128476.140086"] = 197231,
	["128941.140086"] = 196211,
	["127829.140086"] = 201454,
	["128832.140086"] = 207343,
	["128943.140086"] = 211108,

	["128306.140088"] = 189754,
	["128860.140088"] = 210593,
	["128911.140088"] = 207255,
	["128823.140088"] = 200294,
	["128858.140088"] = 202445,
	["128821.140088"] = 200409,
	["128938.140088"] = 213055,
	["128826.140088"] = 190520,
	["128937.140088"] = 199377,
	["128825.140088"] = 196422,

	["128910.143682"] = 209492,
	["128808.143682"] = 203670,
	["128289.143682"] = 203227,
	["128402.143682"] = 192542,
	["128826.143682"] = 190529,
	["128403.143682"] = 191488,
	["128942.143682"] = 199158,
	["128860.143682"] = 210637,
	["128827.143682"] = 194016,
	["128870.143682"] = 192349,
	["128872.143682"] = 202530,
	["128821.143682"] = 200414,

	["128820.143683"] = 194313,
	["128941.143683"] = 196236,
	["128821.143683"] = 200409,
	["120978.143683"] = 186927,
	["128908.143683"] = 200856,
	["128943.143683"] = 211105,
	["128289.143683"] = 203225,
	["128819.143683"] = 198299,
	["128403.143683"] = 191494,

	["128826.143684"] = 190457,
	["128403.143684"] = 191442,
	["128942.143684"] = 199112,
	["128910.143684"] = 209462,
	["128808.143684"] = 203577,
	["128402.143684"] = 192453,
	["128289.143684"] = 216272,
	["128872.143684"] = 202507,
	["128821.143684"] = 200399,
	["128860.143684"] = 210571,
	["128827.143684"] = 193643,
	["128870.143684"] = 192315,

	["128910.143685"] = 209472,
	["128938.143685"] = 213180,
	["128908.143685"] = 200849,
	["128808.143685"] = 203578,
	["128940.143685"] = 218607,
	["128832.143685"] = 207352,
	["128289.143685"] = 188683,
	["128402.143685"] = 192447,
	["128819.143685"] = 198247,
	["128870.143685"] = 192318,
	["128861.143685"] = 197080,
	["128872.143685"] = 202514,
	["128866.143685"] = 209220,

	["128866.143686"] = 209229,
	["128823.143686"] = 200326,
	["128825.143686"] = 196434,
	["128868.143686"] = 197708,
	["120978.143686"] = 186941,

	["128476.143687"] = 197369,
	["127829.143687"] = 201458,
	["128941.143687"] = 196236,
	["128832.143687"] = 212816,
	["128943.143687"] = 211105,

	["128872.143688"] = 202522,
	["128861.143688"] = 197139,
	["128937.143688"] = 199372,
	["128819.143688"] = 198292,
	["128826.143688"] = 190467,
	["128935.143688"] = 191740,
	["128908.143688"] = 200853,
	["128938.143688"] = 213062,
	["128940.143688"] = 195266,
	["128808.143688"] = 203638,

	["128937.143689"] = 199366,
	["128825.143689"] = 196358,
	["128826.143689"] = 190457,
	["128938.143689"] = 213049,
	["128858.143689"] = 202386,
	["128821.143689"] = 200399,
	["128860.143689"] = 210571,
	["128306.143689"] = 189768,
	["128823.143689"] = 200316,
	["128911.143689"] = 207092,

	["128292.143690"] = 189154,
	["127829.143690"] = 201459,
	["128476.143690"] = 197241,
	["128827.143690"] = 193642,
	["128870.143690"] = 192323,
	["128942.143690"] = 199212,
	["128868.143690"] = 197711,
	["128403.143690"] = 191565,
	["128910.143690"] = 209483,
	["128943.143690"] = 211144,
	["128402.143690"] = 192514,

	["128942.143691"] = 199120,
	["128403.143691"] = 191485,
	["128826.143691"] = 190462,
	["128289.143691"] = 188683,
	["128402.143691"] = 192447,
	["128808.143691"] = 203578,
	["128910.143691"] = 209472,
	["128821.143691"] = 208762,
	["128872.143691"] = 202514,
	["128870.143691"] = 192318,
	["128860.143691"] = 210575,
	["128827.143691"] = 193644,

	["128832.143692"] = 207352,
	["128858.143692"] = 202426,
	["128866.143692"] = 209220,
	["128862.143692"] = 195322,
	["127857.143692"] = 187321,
	["128861.143692"] = 197080,
	["128820.143692"] = 194312,

	["128292.143693"] = 189080,
	["127829.143693"] = 201454,
	["128476.143693"] = 197231,
	["128827.143693"] = 194093,
	["128870.143693"] = 192310,
	["128942.143693"] = 199111,
	["128868.143693"] = 197708,
	["128403.143693"] = 191419,
	["128910.143693"] = 209459,
	["128402.143693"] = 192450,
	["128943.143693"] = 211108,

	["128827.143694"] = 194016,
	["128870.143694"] = 192349,
	["128292.143694"] = 189147,
	["128476.143694"] = 197386,
	["127829.143694"] = 201460,
	["128910.143694"] = 209492,
	["128402.143694"] = 192542,
	["128943.143694"] = 211119,
	["128403.143694"] = 191488,
	["128942.143694"] = 199158,
	["128868.143694"] = 197729,

	["128866.143695"] = 209217,
	["128823.143695"] = 200316,
	["128825.143695"] = 196358,
	["128868.143695"] = 197713,
	["120978.143695"] = 184759,

	["128943.143696"] = 211099,
	["128832.143696"] = 212819,
	["128941.143696"] = 196258,
	["127829.143696"] = 201464,
	["128476.143696"] = 197239,

	["128935.143697"] = 191740,
	["128938.143697"] = 213062,
	["128940.143697"] = 195266,
	["128908.143697"] = 200853,
	["128808.143697"] = 203638,
	["128937.143697"] = 199372,
	["128826.143697"] = 190467,
	["128819.143697"] = 198292,
	["128861.143697"] = 197139,
	["128872.143697"] = 202522,

	["128937.143698"] = 199365,
	["128825.143698"] = 196489,
	["128826.143698"] = 190503,
	["128938.143698"] = 213047,
	["128858.143698"] = 202302,
	["128821.143698"] = 200400,
	["128860.143698"] = 210557,
	["128306.143698"] = 186396,
	["128911.143698"] = 207351,
	["128823.143698"] = 200327,

	["128861.143699"] = 197047,
	["127857.143699"] = 187258,
	["128862.143699"] = 195317,
	["128866.143699"] = 209217,
	["128858.143699"] = 202386,
	["128820.143699"] = 194234,
	["128832.143699"] = 207347,

	["128937.143700"] = 199367,
	["128935.143700"] = 191504,
	["128862.143700"] = 195322,
	["128292.143700"] = 189086,
	["127857.143700"] = 187321,
	["128860.143700"] = 210575,
	["128306.143700"] = 189760,
	["128911.143700"] = 207118,

	["128941.143701"] = 196305,
	["128821.143701"] = 200440,
	["128820.143701"] = 194315,
	["128819.143701"] = 198248,
	["128403.143701"] = 191584,
	["120978.143701"] = 184778,
	["128908.143701"] = 200859,
	["128943.143701"] = 211131,
	["128289.143701"] = 188644,

	["128826.143702"] = 190462,
	["128825.143702"] = 196416,
	["128937.143702"] = 199367,
	["128938.143702"] = 213180,
	["128821.143702"] = 208762,
	["128858.143702"] = 202426,
	["128911.143702"] = 207118,
	["128823.143702"] = 200315,
	["128860.143702"] = 210575,
	["128306.143702"] = 189760,

	["128935.143703"] = 191577,
	["128937.143703"] = 199380,
	["128911.143703"] = 207285,
	["128860.143703"] = 210637,
	["128306.143703"] = 189749,
	["128862.143703"] = 195351,
	["127857.143703"] = 187276,
	["128292.143703"] = 189147,

	["128861.143704"] = 197140,
	["128872.143704"] = 202524,
	["128937.143704"] = 199377,
	["128826.143704"] = 190520,
	["128819.143704"] = 198299,
	["128935.143704"] = 191572,
	["128938.143704"] = 213055,
	["128940.143704"] = 195269,
	["128908.143704"] = 200856,
	["128808.143704"] = 203669,

	["128819.143705"] = 198292,
	["128289.143705"] = 203230,
	["128402.143705"] = 192457,
	["128832.143705"] = 207375,
	["128908.143705"] = 200853,
	["128938.143705"] = 213062,
	["128940.143705"] = 195266,
	["128808.143705"] = 203638,
	["128910.143705"] = 216274,
	["128866.143705"] = 209226,
	["128872.143705"] = 202522,
	["128861.143705"] = 197139,
	["128870.143705"] = 192326,

	["120978.143796"] = 184843,
	["128868.143796"] = 197715,
	["128825.143796"] = 196416,
	["128823.143796"] = 200315,
	["128866.143796"] = 209220,

	["128861.143797"] = 206910,
	["127857.143797"] = 187287,
	["128862.143797"] = 195352,
	["128866.143797"] = 209216,
	["128858.143797"] = 202464,
	["128820.143797"] = 194239,
	["128832.143797"] = 212819,

	["128827.143798"] = 194093,
	["128860.143798"] = 210570,
	["128870.143798"] = 192310,
	["128872.143798"] = 216230,
	["128821.143798"] = 200395,
	["128808.143798"] = 203566,
	["128910.143798"] = 209459,
	["128289.143798"] = 188635,
	["128402.143798"] = 192450,
	["128826.143798"] = 190449,
	["128942.143798"] = 199111,
	["128403.143798"] = 191419,

	["128943.143799"] = 211105,
	["128832.143799"] = 212816,
	["128941.143799"] = 196236,
	["127829.143799"] = 201458,
	["128476.143799"] = 197369,

	["128820.143800"] = 194234,
	["128821.143800"] = 200399,
	["128941.143800"] = 196217,
	["128289.143800"] = 216272,
	["128943.143800"] = 211126,
	["128908.143800"] = 216273,
	["120978.143800"] = 184759,
	["128403.143800"] = 191442,
	["128819.143800"] = 198236,

	["128935.143801"] = 191499,
	["128937.143801"] = 199366,
	["128911.143801"] = 207092,
	["128306.143801"] = 189768,
	["128860.143801"] = 210571,
	["127857.143801"] = 187258,
	["128292.143801"] = 189092,
	["128862.143801"] = 195317,

	["128819.143802"] = 198247,
	["128938.143802"] = 213180,
	["128908.143802"] = 200849,
	["128940.143802"] = 218607,
	["128808.143802"] = 203578,
	["128910.143802"] = 209472,
	["128402.143802"] = 192447,
	["128289.143802"] = 188683,
	["128832.143802"] = 207352,
	["128872.143802"] = 202514,
	["128861.143802"] = 197080,
	["128866.143802"] = 209220,
	["128870.143802"] = 192318,

	["128938.143803"] = 213049,
	["128826.143803"] = 190457,
	["128825.143803"] = 196358,
	["128937.143803"] = 199366,
	["128911.143803"] = 207092,
	["128823.143803"] = 200316,
	["128306.143803"] = 189768,
	["128860.143803"] = 210571,
	["128858.143803"] = 202386,
	["128821.143803"] = 200399,

	["128910.143804"] = 209459,
	["128402.143804"] = 192450,
	["128943.143804"] = 211108,
	["128403.143804"] = 191419,
	["128868.143804"] = 197708,
	["128942.143804"] = 199111,
	["128827.143804"] = 194093,
	["128870.143804"] = 192310,
	["128292.143804"] = 189080,
	["128476.143804"] = 197231,
	["127829.143804"] = 201454,

	["128826.143805"] = 190449,
	["128819.143805"] = 215381,
	["128937.143805"] = 199364,
	["128938.143805"] = 213051,
	["128940.143805"] = 195243,
	["128808.143805"] = 203566,
	["128908.143805"] = 200846,
	["128935.143805"] = 191493,
	["128861.143805"] = 197038,
	["128872.143805"] = 216230,

	["128832.143806"] = 207352,
	["128820.143806"] = 194312,
	["128866.143806"] = 209220,
	["128862.143806"] = 195322,
	["128858.143806"] = 202426,
	["128861.143806"] = 197080,
	["127857.143806"] = 187321,

	["128832.143807"] = 207375,
	["128820.143807"] = 210182,
	["128858.143807"] = 202433,
	["128866.143807"] = 209226,
	["128862.143807"] = 195323,
	["127857.143807"] = 187264,
	["128861.143807"] = 197139,

	["128289.143808"] = 203225,
	["128402.143808"] = 192460,
	["128808.143808"] = 203669,
	["128910.143808"] = 209481,
	["128942.143808"] = 199153,
	["128403.143808"] = 191494,
	["128826.143808"] = 190520,
	["128870.143808"] = 192329,
	["128827.143808"] = 194007,
	["128860.143808"] = 210593,
	["128821.143808"] = 200409,
	["128872.143808"] = 202524,

	["128872.143809"] = 202530,
	["128821.143809"] = 200414,
	["128860.143809"] = 210637,
	["128827.143809"] = 194016,
	["128870.143809"] = 192349,
	["128826.143809"] = 190529,
	["128403.143809"] = 191488,
	["128942.143809"] = 199158,
	["128910.143809"] = 209492,
	["128808.143809"] = 203670,
	["128289.143809"] = 203227,
	["128402.143809"] = 192542,

	["128832.143810"] = 212819,
	["128943.143810"] = 211099,
	["128476.143810"] = 197239,
	["128941.143810"] = 196258,
	["127829.143810"] = 201464,

	["128476.143811"] = 197241,
	["128941.143811"] = 196301,
	["127829.143811"] = 201459,
	["128832.143811"] = 212821,
	["128943.143811"] = 211144,

	["128941.143812"] = 196236,
	["128821.143812"] = 200409,
	["128820.143812"] = 194313,
	["128403.143812"] = 191494,
	["128819.143812"] = 198299,
	["128289.143812"] = 203225,
	["128943.143812"] = 211105,
	["128908.143812"] = 200856,
	["120978.143812"] = 186927,

	["128289.143813"] = 203227,
	["128943.143813"] = 211119,
	["120978.143813"] = 185368,
	["128908.143813"] = 200860,
	["128403.143813"] = 191488,
	["128819.143813"] = 198349,
	["128820.143813"] = 194314,
	["128941.143813"] = 196432,
	["128821.143813"] = 200414,

	["128937.143814"] = 199372,
	["128935.143814"] = 191740,
	["128862.143814"] = 195323,
	["128292.143814"] = 189164,
	["127857.143814"] = 187264,
	["128860.143814"] = 210579,
	["128306.143814"] = 189757,
	["128911.143814"] = 207206,

	["128292.143815"] = 189097,
	["127857.143815"] = 187287,
	["128862.143815"] = 195352,
	["128306.143815"] = 189744,
	["128860.143815"] = 210631,
	["128911.143815"] = 207348,
	["128937.143815"] = 199485,
	["128935.143815"] = 191598,

	["128823.143816"] = 200482,
	["128866.143816"] = 209216,
	["120978.143816"] = 186944,
	["128868.143816"] = 197762,
	["128825.143816"] = 196430,

	["128868.143817"] = 216212,
	["128825.143817"] = 196355,
	["120978.143817"] = 184778,
	["128866.143817"] = 209225,
	["128823.143817"] = 200302,

	["128832.143818"] = 212817,
	["128402.143818"] = 192542,
	["128289.143818"] = 203227,
	["128910.143818"] = 209492,
	["128908.143818"] = 200860,
	["128940.143818"] = 195291,
	["128938.143818"] = 213133,
	["128808.143818"] = 203670,
	["128819.143818"] = 198349,
	["128870.143818"] = 192349,
	["128866.143818"] = 209218,
	["128861.143818"] = 197162,
	["128872.143818"] = 202530,

	["128870.143819"] = 192323,
	["128866.143819"] = 209224,
	["128861.143819"] = 197160,
	["128872.143819"] = 202521,
	["128832.143819"] = 212821,
	["128289.143819"] = 188632,
	["128402.143819"] = 192514,
	["128910.143819"] = 209483,
	["128908.143819"] = 200857,
	["128938.143819"] = 213047,
	["128808.143819"] = 224764,
	["128940.143819"] = 195244,
	["128819.143819"] = 198296,

	["128825.143820"] = 196422,
	["128937.143820"] = 199377,
	["128826.143820"] = 190520,
	["128938.143820"] = 213055,
	["128858.143820"] = 202445,
	["128821.143820"] = 200409,
	["128823.143820"] = 200294,
	["128911.143820"] = 207255,
	["128860.143820"] = 210593,
	["128306.143820"] = 189754,

	["128858.143821"] = 203018,
	["128821.143821"] = 200440,
	["128860.143821"] = 210590,
	["128306.143821"] = 186320,
	["128911.143821"] = 207354,
	["128823.143821"] = 200302,
	["128937.143821"] = 199384,
	["128825.143821"] = 196355,
	["128826.143821"] = 190514,
	["128938.143821"] = 213116,

	["128292.143822"] = 189164,
	["128476.143822"] = 197235,
	["127829.143822"] = 201457,
	["128827.143822"] = 193645,
	["128870.143822"] = 192326,
	["128403.143822"] = 191592,
	["128942.143822"] = 199152,
	["128868.143822"] = 197716,
	["128910.143822"] = 216274,
	["128943.143822"] = 211123,
	["128402.143822"] = 192457,

	["128292.143823"] = 189154,
	["128476.143823"] = 197241,
	["127829.143823"] = 201459,
	["128827.143823"] = 193642,
	["128870.143823"] = 192323,
	["128403.143823"] = 191565,
	["128942.143823"] = 199212,
	["128868.143823"] = 197711,
	["128910.143823"] = 209483,
	["128402.143823"] = 192514,
	["128943.143823"] = 211144,

	["128872.143824"] = 202522,
	["128861.143824"] = 197139,
	["128937.143824"] = 199372,
	["128819.143824"] = 198292,
	["128826.143824"] = 190467,
	["128935.143824"] = 191740,
	["128938.143824"] = 213062,
	["128940.143824"] = 195266,
	["128908.143824"] = 200853,
	["128808.143824"] = 203638,

	["128861.143825"] = 197162,
	["128872.143825"] = 202530,
	["128826.143825"] = 190529,
	["128819.143825"] = 198349,
	["128937.143825"] = 199380,
	["128940.143825"] = 195291,
	["128938.143825"] = 213133,
	["128808.143825"] = 203670,
	["128908.143825"] = 200860,
	["128935.143825"] = 191577,

	-- BEGIN 7.1.5 Updated Nighthold Relic Data
	["128868.140843"] = 197716,
	["128825.140843"] = 196418,
	["128823.140843"] = 200296,
	["120978.140843"] = 186945,
	["128866.140843"] = 209226,

	["128866.140844"] = 209229,
	["120978.140844"] = 186941,
	["128823.140844"] = 200326,
	["128868.140844"] = 197708,
	["128825.140844"] = 196434,

	["128823.140845"] = 200294,
	["128825.140845"] = 196422,
	["128868.140845"] = 197727,
	["128866.140845"] = 209223,
	["120978.140845"] = 186927,

	["128819.140840"] = 198236,
	["128826.140840"] = 190457,
	["128938.140840"] = 213049,
	["128908.140840"] = 216273,
	["128940.140840"] = 195263,
	["128935.140840"] = 191499,
	["128937.140840"] = 199366,
	["128808.140840"] = 203577,
	["128861.140840"] = 197047,
	["128872.140840"] = 202507,

	["128908.140841"] = 200860,
	["128940.140841"] = 195291,
	["128937.140841"] = 199380,
	["128808.140841"] = 203670,
	["128935.140841"] = 191577,
	["128872.140841"] = 202530,
	["128861.140841"] = 197162,
	["128819.140841"] = 198349,
	["128938.140841"] = 213133,
	["128826.140841"] = 190529,

	["128861.140842"] = 197038,
	["128872.140842"] = 216230,
	["128935.140842"] = 191493,
	["128937.140842"] = 199364,
	["128808.140842"] = 203566,
	["128908.140842"] = 200846,
	["128940.140842"] = 195243,
	["128826.140842"] = 190449,
	["128938.140842"] = 213051,
	["128819.140842"] = 215381,

	["128825.140838"] = 196416,
	["128938.140838"] = 213180,
	["128823.140838"] = 200315,
	["128826.140838"] = 190462,
	["128860.140838"] = 210575,
	["128306.140838"] = 189760,
	["128858.140838"] = 202426,
	["128821.140838"] = 208762,
	["128937.140838"] = 199367,
	["128911.140838"] = 207118,

	["128860.140839"] = 210631,
	["128306.140839"] = 189744,
	["128825.140839"] = 196430,
	["128938.140839"] = 213136,
	["128823.140839"] = 200482,
	["128826.140839"] = 190567,
	["128937.140839"] = 199485,
	["128911.140839"] = 207348,
	["128858.140839"] = 202464,
	["128821.140839"] = 200415,

	["120978.140834"] = 186944,
	["128908.140834"] = 200861,
	["128403.140834"] = 208598,
	["128821.140834"] = 200415,
	["128943.140834"] = 211099,
	["128819.140834"] = 198238,
	["128820.140834"] = 194239,
	["128289.140834"] = 188639,
	["128941.140834"] = 196258,

	["120978.140835"] = 184843,
	["128908.140835"] = 200849,
	["128403.140835"] = 191485,
	["128821.140835"] = 208762,
	["128943.140835"] = 211106,
	["128819.140835"] = 198247,
	["128820.140835"] = 194312,
	["128289.140835"] = 188683,
	["128941.140835"] = 196222,

	["128403.140836"] = 191442,
	["128821.140836"] = 200399,
	["120978.140836"] = 184759,
	["128908.140836"] = 216273,
	["128289.140836"] = 216272,
	["128941.140836"] = 196217,
	["128943.140836"] = 211126,
	["128819.140836"] = 198236,
	["128820.140836"] = 194234,

	["128908.140837"] = 200860,
	["120978.140837"] = 185368,
	["128821.140837"] = 200414,
	["128403.140837"] = 191488,
	["128820.140837"] = 194314,
	["128819.140837"] = 198349,
	["128943.140837"] = 211119,
	["128941.140837"] = 196432,
	["128289.140837"] = 203227,

	["128860.140831"] = 210637,
	["128292.140831"] = 189147,
	["128306.140831"] = 189749,
	["127857.140831"] = 187276,
	["128937.140831"] = 199380,
	["128862.140831"] = 195351,
	["128935.140831"] = 191577,
	["128911.140831"] = 207285,

	["127857.140832"] = 187258,
	["128862.140832"] = 195317,
	["128911.140832"] = 207092,
	["128935.140832"] = 191499,
	["128937.140832"] = 199366,
	["128306.140832"] = 189768,
	["128860.140832"] = 210571,
	["128292.140832"] = 189092,

	["128860.140833"] = 210579,
	["128292.140833"] = 189164,
	["128306.140833"] = 189757,
	["127857.140833"] = 187264,
	["128937.140833"] = 199372,
	["128935.140833"] = 191740,
	["128862.140833"] = 195323,
	["128911.140833"] = 207206,

	["128820.140810"] = 194239,
	["128866.140810"] = 209216,
	["127857.140810"] = 187287,
	["128862.140810"] = 195352,
	["128858.140810"] = 202464,
	["128832.140810"] = 212819,
	["128861.140810"] = 206910,

	["128862.140812"] = 195345,
	["128866.140812"] = 209223,
	["127857.140812"] = 187313,
	["128861.140812"] = 197140,
	["128858.140812"] = 202445,
	["128832.140812"] = 212816,
	["128820.140812"] = 194313,

	["128866.140813"] = 209229,
	["127857.140813"] = 187304,
	["128862.140813"] = 195315,
	["128858.140813"] = 202384,
	["128832.140813"] = 207343,
	["128861.140813"] = 197038,
	["128820.140813"] = 194224,

	["128820.140827"] = 194312,
	["128866.140827"] = 209220,
	["127857.140827"] = 187321,
	["128862.140827"] = 195322,
	["128858.140827"] = 202426,
	["128832.140827"] = 207352,
	["128861.140827"] = 197080,

	["128476.140824"] = 197233,
	["128832.140824"] = 207347,
	["127829.140824"] = 201455,
	["128943.140824"] = 211126,
	["128941.140824"] = 196217,

	["128941.140825"] = 196301,
	["128943.140825"] = 211144,
	["127829.140825"] = 201459,
	["128832.140825"] = 212821,
	["128476.140825"] = 197241,

	["128943.140826"] = 211119,
	["127829.140826"] = 201460,
	["128941.140826"] = 196432,
	["128476.140826"] = 197386,
	["128832.140826"] = 212817,

	["128292.140821"] = 189080,
	["128943.140821"] = 211108,
	["127829.140821"] = 201454,
	["128827.140821"] = 194093,
	["128870.140821"] = 192310,
	["128402.140821"] = 192450,
	["128476.140821"] = 197231,
	["128910.140821"] = 209459,
	["128868.140821"] = 197708,
	["128403.140821"] = 191419,
	["128942.140821"] = 199111,

	["128402.140822"] = 192542,
	["128827.140822"] = 194016,
	["128870.140822"] = 192349,
	["128943.140822"] = 211119,
	["127829.140822"] = 201460,
	["128292.140822"] = 189147,
	["128942.140822"] = 199158,
	["128868.140822"] = 197729,
	["128403.140822"] = 191488,
	["128910.140822"] = 209492,
	["128476.140822"] = 197386,

	["128402.140823"] = 192447,
	["128827.140823"] = 193644,
	["128870.140823"] = 192318,
	["128943.140823"] = 211106,
	["128292.140823"] = 189086,
	["127829.140823"] = 201456,
	["128942.140823"] = 199120,
	["128403.140823"] = 191485,
	["128868.140823"] = 197715,
	["128910.140823"] = 209472,
	["128476.140823"] = 197234,

	["128821.140818"] = 200399,
	["128942.140818"] = 199112,
	["128403.140818"] = 191442,
	["128872.140818"] = 202507,
	["128910.140818"] = 209462,
	["128808.140818"] = 203577,
	["128826.140818"] = 190457,
	["128289.140818"] = 216272,
	["128402.140818"] = 192453,
	["128870.140818"] = 192315,
	["128827.140818"] = 193643,
	["128860.140818"] = 210571,

	["128289.140819"] = 203225,
	["128826.140819"] = 190520,
	["128860.140819"] = 210593,
	["128402.140819"] = 192460,
	["128827.140819"] = 194007,
	["128870.140819"] = 192329,
	["128403.140819"] = 191494,
	["128910.140819"] = 209481,
	["128872.140819"] = 202524,
	["128821.140819"] = 200409,
	["128942.140819"] = 199153,
	["128808.140819"] = 203669,

	["128942.140820"] = 199111,
	["128821.140820"] = 200395,
	["128403.140820"] = 191419,
	["128872.140820"] = 216230,
	["128910.140820"] = 209459,
	["128808.140820"] = 203566,
	["128826.140820"] = 190449,
	["128289.140820"] = 188635,
	["128402.140820"] = 192450,
	["128870.140820"] = 192310,
	["128827.140820"] = 194093,
	["128860.140820"] = 210570,

	["128908.140815"] = 200860,
	["128940.140815"] = 195291,
	["128866.140815"] = 209218,
	["128808.140815"] = 203670,
	["128832.140815"] = 212817,
	["128872.140815"] = 202530,
	["128910.140815"] = 209492,
	["128861.140815"] = 197162,
	["128870.140815"] = 192349,
	["128402.140815"] = 192542,
	["128819.140815"] = 198349,
	["128938.140815"] = 213133,
	["128289.140815"] = 203227,

	["128808.140816"] = 203577,
	["128940.140816"] = 195263,
	["128908.140816"] = 216273,
	["128866.140816"] = 209217,
	["128861.140816"] = 197047,
	["128910.140816"] = 209462,
	["128872.140816"] = 202507,
	["128832.140816"] = 207347,
	["128819.140816"] = 198236,
	["128402.140816"] = 192453,
	["128870.140816"] = 192315,
	["128289.140816"] = 216272,
	["128938.140816"] = 213049,

	["128808.140817"] = 203578,
	["128940.140817"] = 218607,
	["128908.140817"] = 200849,
	["128866.140817"] = 209220,
	["128861.140817"] = 197080,
	["128910.140817"] = 209472,
	["128872.140817"] = 202514,
	["128832.140817"] = 207352,
	["128819.140817"] = 198247,
	["128402.140817"] = 192447,
	["128870.140817"] = 192318,
	["128289.140817"] = 188683,
	["128938.140817"] = 213180,

	-- BEGIN 7.2 New Relic Data --------------------------
	["128858.147076"] = 202466,
	["128861.147076"] = 197162,
	["128832.147076"] = 212817,
	["128862.147076"] = 195351,
	["128820.147076"] = 194314,
	["128866.147076"] = 209218,
	["127857.147076"] = 187276,

	["127857.147077"] = 187313,
	["128866.147077"] = 209223,
	["128861.147077"] = 197140,
	["128832.147077"] = 212816,
	["128820.147077"] = 194313,
	["128862.147077"] = 195345,
	["128858.147077"] = 202445,

	["128861.147078"] = 197080,
	["128862.147078"] = 195322,
	["128832.147078"] = 207352,
	["128820.147078"] = 194312,
	["128858.147078"] = 202426,
	["127857.147078"] = 187321,
	["128866.147078"] = 209220,

	["128861.147079"] = 238051,
	["128820.147079"] = 238055,
	["128832.147079"] = 238046,
	["128862.147079"] = 238056,
	["128858.147079"] = 238047,
	["127857.147079"] = 238054,
	["128866.147079"] = 238061,

	["128826.147080"] = 190457,
	["128870.147080"] = 192315,
	["128289.147080"] = 216272,
	["128402.147080"] = 192453,
	["128403.147080"] = 191442,
	["128808.147080"] = 203577,
	["128942.147080"] = 199112,
	["128821.147080"] = 200399,
	["128860.147080"] = 210571,
	["128827.147080"] = 193643,
	["128910.147080"] = 209462,
	["128872.147080"] = 202507,

	["128808.147081"] = 203669,
	["128942.147081"] = 199153,
	["128403.147081"] = 191494,
	["128402.147081"] = 192460,
	["128910.147081"] = 209481,
	["128872.147081"] = 202524,
	["128860.147081"] = 210593,
	["128827.147081"] = 194007,
	["128821.147081"] = 200409,
	["128870.147081"] = 192329,
	["128826.147081"] = 190520,
	["128289.147081"] = 203225,

	["128289.147082"] = 238077,
	["128826.147082"] = 238052,
	["128870.147082"] = 238066,
	["128860.147082"] = 238048,
	["128821.147082"] = 238049,
	["128827.147082"] = 238065,
	["128910.147082"] = 238075,
	["128872.147082"] = 238067,
	["128402.147082"] = 238042,
	["128403.147082"] = 238044,
	["128808.147082"] = 238053,
	["128942.147082"] = 238072,

	["128943.147084"] = 211106,
	["127829.147084"] = 201456,
	["128476.147084"] = 197234,
	["128832.147084"] = 207352,
	["128941.147084"] = 196222,

	["128941.147085"] = 238074,
	["128832.147085"] = 238046,
	["128476.147085"] = 238068,
	["127829.147085"] = 238045,
	["128943.147085"] = 238073,

	["127829.147086"] = 201455,
	["128943.147086"] = 211126,
	["128941.147086"] = 196217,
	["128832.147086"] = 207347,
	["128476.147086"] = 197233,

	["128941.147087"] = 196211,
	["128832.147087"] = 207343,
	["128476.147087"] = 197231,
	["127829.147087"] = 201454,
	["128943.147087"] = 211108,

	["120978.147088"] = 186945,
	["128943.147088"] = 211123,
	["128819.147088"] = 198292,
	["128820.147088"] = 210182,
	["128908.147088"] = 200853,
	["128289.147088"] = 203230,
	["128403.147088"] = 191592,
	["128941.147088"] = 196227,
	["128821.147088"] = 200402,

	["128908.147089"] = 200861,
	["128820.147089"] = 194239,
	["128289.147089"] = 188639,
	["120978.147089"] = 186944,
	["128943.147089"] = 211099,
	["128819.147089"] = 198238,
	["128821.147089"] = 200415,
	["128941.147089"] = 196258,
	["128403.147089"] = 208598,

	["128821.147090"] = 200409,
	["128941.147090"] = 196236,
	["128403.147090"] = 191494,
	["128289.147090"] = 203225,
	["128908.147090"] = 200856,
	["128820.147090"] = 194313,
	["128819.147090"] = 198299,
	["128943.147090"] = 211105,
	["120978.147090"] = 186927,

	["128820.147091"] = 194314,
	["128908.147091"] = 200860,
	["128289.147091"] = 203227,
	["120978.147091"] = 185368,
	["128943.147091"] = 211119,
	["128819.147091"] = 198349,
	["128941.147091"] = 196432,
	["128821.147091"] = 200414,
	["128403.147091"] = 191488,

	["128935.147092"] = 191499,
	["128306.147092"] = 189768,
	["128911.147092"] = 207092,
	["127857.147092"] = 187258,
	["128937.147092"] = 199366,
	["128860.147092"] = 210571,
	["128862.147092"] = 195317,
	["128292.147092"] = 189092,

	["128937.147093"] = 199364,
	["128860.147093"] = 210570,
	["128862.147093"] = 195315,
	["128292.147093"] = 189080,
	["128911.147093"] = 207088,
	["127857.147093"] = 187304,
	["128935.147093"] = 191493,
	["128306.147093"] = 189772,

	["128860.147094"] = 210631,
	["128937.147094"] = 199485,
	["128292.147094"] = 189097,
	["128862.147094"] = 195352,
	["128911.147094"] = 207348,
	["127857.147094"] = 187287,
	["128306.147094"] = 189744,
	["128935.147094"] = 191598,

	["128911.147095"] = 207255,
	["127857.147095"] = 187313,
	["128306.147095"] = 189754,
	["128935.147095"] = 191572,
	["128860.147095"] = 210593,
	["128937.147095"] = 199377,
	["128292.147095"] = 189144,
	["128862.147095"] = 195345,

	["120978.147096"] = 184843,
	["128823.147096"] = 200315,
	["128868.147096"] = 197715,
	["128866.147096"] = 209220,
	["128825.147096"] = 196416,

	["120978.147097"] = 186927,
	["128825.147097"] = 196422,
	["128868.147097"] = 197727,
	["128866.147097"] = 209223,
	["128823.147097"] = 200294,

	["120978.147098"] = 238062,
	["128825.147098"] = 238064,
	["128823.147098"] = 238060,
	["128866.147098"] = 238061,
	["128868.147098"] = 238063,

	["128866.147099"] = 209217,
	["128868.147099"] = 197713,
	["128823.147099"] = 200316,
	["128825.147099"] = 196358,
	["120978.147099"] = 184759,

	["128870.147100"] = 192326,
	["128938.147100"] = 213062,
	["128819.147100"] = 198292,
	["128908.147100"] = 200853,
	["128289.147100"] = 203230,
	["128940.147100"] = 195266,
	["128808.147100"] = 203638,
	["128402.147100"] = 192457,
	["128866.147100"] = 209226,
	["128872.147100"] = 202522,
	["128861.147100"] = 197139,
	["128832.147100"] = 207375,
	["128910.147100"] = 216274,

	["128940.147101"] = 195263,
	["128808.147101"] = 203577,
	["128402.147101"] = 192453,
	["128866.147101"] = 209217,
	["128861.147101"] = 197047,
	["128872.147101"] = 202507,
	["128832.147101"] = 207347,
	["128910.147101"] = 209462,
	["128870.147101"] = 192315,
	["128938.147101"] = 213049,
	["128819.147101"] = 198236,
	["128908.147101"] = 216273,
	["128289.147101"] = 216272,

	["128938.147102"] = 213051,
	["128870.147102"] = 192310,
	["128819.147102"] = 215381,
	["128908.147102"] = 200846,
	["128289.147102"] = 188635,
	["128808.147102"] = 203566,
	["128940.147102"] = 195243,
	["128402.147102"] = 192450,
	["128866.147102"] = 209229,
	["128910.147102"] = 209459,
	["128832.147102"] = 207343,
	["128872.147102"] = 216230,
	["128861.147102"] = 197038,

	["128938.147104"] = 213055,
	["128826.147104"] = 190520,
	["128911.147104"] = 207255,
	["128306.147104"] = 189754,
	["128823.147104"] = 200294,
	["128825.147104"] = 196422,
	["128858.147104"] = 202445,
	["128937.147104"] = 199377,
	["128821.147104"] = 200409,
	["128860.147104"] = 210593,

	["128306.147105"] = 189749,
	["128911.147105"] = 207285,
	["128938.147105"] = 213133,
	["128826.147105"] = 190529,
	["128937.147105"] = 199380,
	["128858.147105"] = 202466,
	["128821.147105"] = 200414,
	["128860.147105"] = 210637,
	["128825.147105"] = 196429,
	["128823.147105"] = 200298,

	["128911.147106"] = 207088,
	["128826.147106"] = 190449,
	["128938.147106"] = 213051,
	["128306.147106"] = 189772,
	["128823.147106"] = 200326,
	["128860.147106"] = 210570,
	["128821.147106"] = 200395,
	["128858.147106"] = 202384,
	["128937.147106"] = 199364,
	["128825.147106"] = 196434,

	["128306.147107"] = 189757,
	["128938.147107"] = 213062,
	["128826.147107"] = 190467,
	["128911.147107"] = 207206,
	["128825.147107"] = 196418,
	["128858.147107"] = 202433,
	["128937.147107"] = 199372,
	["128860.147107"] = 210579,
	["128821.147107"] = 200402,
	["128823.147107"] = 200296,

	["128942.147108"] = 199152,
	["128403.147108"] = 191592,
	["128402.147108"] = 192457,
	["128868.147108"] = 197716,
	["128476.147108"] = 197235,
	["128910.147108"] = 216274,
	["128292.147108"] = 189164,
	["128827.147108"] = 193645,
	["128870.147108"] = 192326,
	["128943.147108"] = 211123,
	["127829.147108"] = 201457,

	["127829.147109"] = 201464,
	["128943.147109"] = 211099,
	["128870.147109"] = 192376,
	["128827.147109"] = 194002,
	["128292.147109"] = 189097,
	["128910.147109"] = 209494,
	["128868.147109"] = 197762,
	["128476.147109"] = 197239,
	["128403.147109"] = 208598,
	["128402.147109"] = 192464,
	["128942.147109"] = 199163,

	["128943.147110"] = 211119,
	["128870.147110"] = 192349,
	["127829.147110"] = 201460,
	["128910.147110"] = 209492,
	["128292.147110"] = 189147,
	["128827.147110"] = 194016,
	["128942.147110"] = 199158,
	["128402.147110"] = 192542,
	["128403.147110"] = 191488,
	["128868.147110"] = 197729,
	["128476.147110"] = 197386,

	["128942.147111"] = 199120,
	["128868.147111"] = 197715,
	["128476.147111"] = 197234,
	["128403.147111"] = 191485,
	["128402.147111"] = 192447,
	["128292.147111"] = 189086,
	["128910.147111"] = 209472,
	["128827.147111"] = 193644,
	["128870.147111"] = 192318,
	["128943.147111"] = 211106,
	["127829.147111"] = 201456,

	["128937.147112"] = 238058,
	["128872.147112"] = 238067,
	["128861.147112"] = 238051,
	["128808.147112"] = 238053,
	["128940.147112"] = 238059,
	["128935.147112"] = 238069,
	["128908.147112"] = 238076,
	["128819.147112"] = 238070,
	["128826.147112"] = 238052,
	["128938.147112"] = 238057,

	["128935.147113"] = 191577,
	["128908.147113"] = 200860,
	["128819.147113"] = 198349,
	["128938.147113"] = 213133,
	["128826.147113"] = 190529,
	["128937.147113"] = 199380,
	["128872.147113"] = 202530,
	["128861.147113"] = 197162,
	["128808.147113"] = 203670,
	["128940.147113"] = 195291,

	["128935.147114"] = 191598,
	["128908.147114"] = 200861,
	["128819.147114"] = 198238,
	["128826.147114"] = 190567,
	["128938.147114"] = 213136,
	["128937.147114"] = 199485,
	["128872.147114"] = 202907,
	["128861.147114"] = 206910,
	["128808.147114"] = 203673,
	["128940.147114"] = 195267,

	["128826.147115"] = 190462,
	["128938.147115"] = 213180,
	["128819.147115"] = 198247,
	["128908.147115"] = 200849,
	["128935.147115"] = 191504,
	["128940.147115"] = 218607,
	["128808.147115"] = 203578,
	["128872.147115"] = 202514,
	["128861.147115"] = 197080,
	["128937.147115"] = 199367,

	["128289.147754"] = 188644,
	["128826.147754"] = 190514,
	["128870.147754"] = 192345,
	["128827.147754"] = 193647,
	["128860.147754"] = 210590,
	["128821.147754"] = 200440,
	["128872.147754"] = 202533,
	["128910.147754"] = 209541,
	["128403.147754"] = 191584,
	["128402.147754"] = 192538,
	["128808.147754"] = 203749,
	["128942.147754"] = 199214,

	["128943.147755"] = 211119,
	["127829.147755"] = 201460,
	["128832.147755"] = 212817,
	["128941.147755"] = 196432,
	["128476.147755"] = 197386,

	["128403.147756"] = 191419,
	["128821.147756"] = 200395,
	["128941.147756"] = 196211,
	["128943.147756"] = 211108,
	["120978.147756"] = 186941,
	["128819.147756"] = 215381,
	["128908.147756"] = 200846,
	["128820.147756"] = 194224,
	["128289.147756"] = 188635,

	["128862.147757"] = 195322,
	["128292.147757"] = 189086,
	["128937.147757"] = 199367,
	["128860.147757"] = 210575,
	["128935.147757"] = 191504,
	["128306.147757"] = 189760,
	["127857.147757"] = 187321,
	["128911.147757"] = 207118,

	["128823.147758"] = 200326,
	["128868.147758"] = 197708,
	["128866.147758"] = 209229,
	["128825.147758"] = 196434,
	["120978.147758"] = 186941,

	["128819.147759"] = 198296,
	["128870.147759"] = 192323,
	["128938.147759"] = 213047,
	["128289.147759"] = 188632,
	["128908.147759"] = 200857,
	["128402.147759"] = 192514,
	["128866.147759"] = 209224,
	["128940.147759"] = 195244,
	["128808.147759"] = 224764,
	["128861.147759"] = 197160,
	["128872.147759"] = 202521,
	["128910.147759"] = 209483,
	["128832.147759"] = 212821,

	["128911.147760"] = 207092,
	["128938.147760"] = 213049,
	["128826.147760"] = 190457,
	["128306.147760"] = 189768,
	["128823.147760"] = 200316,
	["128858.147760"] = 202386,
	["128937.147760"] = 199366,
	["128860.147760"] = 210571,
	["128821.147760"] = 200399,
	["128825.147760"] = 196358,

	["128937.147761"] = 199372,
	["128872.147761"] = 202522,
	["128861.147761"] = 197139,
	["128940.147761"] = 195266,
	["128808.147761"] = 203638,
	["128935.147761"] = 191740,
	["128908.147761"] = 200853,
	["128819.147761"] = 198292,
	["128826.147761"] = 190467,
	["128938.147761"] = 213062,

	["128938.146925"] = 213180,
	["128826.146925"] = 190462,
	["128911.146925"] = 207118,
	["128306.146925"] = 189760,
	["128823.146925"] = 200315,
	["128825.146925"] = 196416,
	["128858.146925"] = 202426,
	["128937.146925"] = 199367,
	["128821.146925"] = 208762,
	["128860.146925"] = 210575,

	["128476.146926"] = 197234,
	["128832.146926"] = 207352,
	["128941.146926"] = 196222,
	["128943.146926"] = 211106,
	["127829.146926"] = 201456,

	["128403.146927"] = 191485,
	["128821.146927"] = 208762,
	["128941.146927"] = 196222,
	["120978.146927"] = 184843,
	["128943.146927"] = 211106,
	["128819.146927"] = 198247,
	["128908.146927"] = 200849,
	["128820.146927"] = 194312,
	["128289.146927"] = 188683,

	["128306.146928"] = 189772,
	["128935.146928"] = 191493,
	["127857.146928"] = 187304,
	["128911.146928"] = 207088,
	["128292.146928"] = 189080,
	["128862.146928"] = 195315,
	["128860.146928"] = 210570,
	["128937.146928"] = 199364,

	["128808.146929"] = 203638,
	["128940.146929"] = 195266,
	["128402.146929"] = 192457,
	["128866.146929"] = 209226,
	["128910.146929"] = 216274,
	["128832.146929"] = 207375,
	["128861.146929"] = 197139,
	["128872.146929"] = 202522,
	["128938.146929"] = 213062,
	["128870.146929"] = 192326,
	["128819.146929"] = 198292,
	["128908.146929"] = 200853,
	["128289.146929"] = 203230,

	["128866.146930"] = 209216,
	["128861.146930"] = 206910,
	["128832.146930"] = 212819,
	["128862.146930"] = 195352,
	["128858.146930"] = 202464,
	["127857.146930"] = 187287,
	["128820.146930"] = 194239,

	["128870.146931"] = 192376,
	["128943.146931"] = 211099,
	["127829.146931"] = 201464,
	["128942.146931"] = 199163,
	["128476.146931"] = 197239,
	["128868.146931"] = 197762,
	["128402.146931"] = 192464,
	["128403.146931"] = 208598,
	["128292.146931"] = 189097,
	["128910.146931"] = 209494,
	["128827.146931"] = 194002,

	["128940.146932"] = 195291,
	["128808.146932"] = 203670,
	["128937.146932"] = 199380,
	["128861.146932"] = 197162,
	["128872.146932"] = 202530,
	["128819.146932"] = 198349,
	["128938.146932"] = 213133,
	["128826.146932"] = 190529,
	["128935.146932"] = 191577,
	["128908.146932"] = 200860,

	["128821.146933"] = 200409,
	["128860.146933"] = 210593,
	["128827.146933"] = 194007,
	["128910.146933"] = 209481,
	["128872.146933"] = 202524,
	["128402.146933"] = 192460,
	["128403.146933"] = 191494,
	["128942.146933"] = 199153,
	["128808.146933"] = 203669,
	["128289.146933"] = 203225,
	["128826.146933"] = 190520,
	["128870.146933"] = 192329,

	["128823.146934"] = 200296,
	["128866.146934"] = 209226,
	["128868.146934"] = 197716,
	["128825.146934"] = 196418,
	["120978.146934"] = 186945,

	["128823.144458"] = 200482,
	["128825.144458"] = 196430,
	["128821.144458"] = 200415,
	["128860.144458"] = 210631,
	["128858.144458"] = 202464,
	["128937.144458"] = 199485,
	["128826.144458"] = 190567,
	["128938.144458"] = 213136,
	["128911.144458"] = 207348,
	["128306.144458"] = 189744,

	["128943.144459"] = 211144,
	["127829.144459"] = 201459,
	["128832.144459"] = 212821,
	["128941.144459"] = 196301,
	["128476.144459"] = 197241,

	["128943.144460"] = 211126,
	["120978.144460"] = 184759,
	["128819.144460"] = 198236,
	["128908.144460"] = 216273,
	["128820.144460"] = 194234,
	["128289.144460"] = 216272,
	["128403.144460"] = 191442,
	["128821.144460"] = 200399,
	["128941.144460"] = 196217,

	["128860.144461"] = 210631,
	["128937.144461"] = 199485,
	["128292.144461"] = 189097,
	["128862.144461"] = 195352,
	["128911.144461"] = 207348,
	["127857.144461"] = 187287,
	["128306.144461"] = 189744,
	["128935.144461"] = 191598,

	["128910.144462"] = 216274,
	["128832.144462"] = 207375,
	["128872.144462"] = 202522,
	["128861.144462"] = 197139,
	["128808.144462"] = 203638,
	["128940.144462"] = 195266,
	["128402.144462"] = 192457,
	["128866.144462"] = 209226,
	["128908.144462"] = 200853,
	["128289.144462"] = 203230,
	["128938.144462"] = 213062,
	["128870.144462"] = 192326,
	["128819.144462"] = 198292,

	["128858.144463"] = 202426,
	["128861.144463"] = 197080,
	["128832.144463"] = 207352,
	["128862.144463"] = 195322,
	["128866.144463"] = 209220,
	["128820.144463"] = 194312,
	["127857.144463"] = 187321,

	["128870.144464"] = 192318,
	["128943.144464"] = 211106,
	["127829.144464"] = 201456,
	["128942.144464"] = 199120,
	["128402.144464"] = 192447,
	["128403.144464"] = 191485,
	["128476.144464"] = 197234,
	["128868.144464"] = 197715,
	["128910.144464"] = 209472,
	["128292.144464"] = 189086,
	["128827.144464"] = 193644,

	["128819.144465"] = 198296,
	["128938.144465"] = 213047,
	["128826.144465"] = 190503,
	["128935.144465"] = 191569,
	["128908.144465"] = 200857,
	["128940.144465"] = 195244,
	["128808.144465"] = 224764,
	["128937.144465"] = 199365,
	["128861.144465"] = 197160,
	["128872.144465"] = 202521,

	["128289.144466"] = 188683,
	["128870.144466"] = 192318,
	["128826.144466"] = 190462,
	["128872.144466"] = 202514,
	["128910.144466"] = 209472,
	["128860.144466"] = 210575,
	["128827.144466"] = 193644,
	["128821.144466"] = 208762,
	["128808.144466"] = 203578,
	["128942.144466"] = 199120,
	["128403.144466"] = 191485,
	["128402.144466"] = 192447,

	["128823.144467"] = 200326,
	["128868.144467"] = 197708,
	["128866.144467"] = 209229,
	["128825.144467"] = 196434,
	["120978.144467"] = 186941,

	["128820.144504"] = 194239,
	["127857.144504"] = 187287,
	["128862.144504"] = 195352,
	["128832.144504"] = 212819,
	["128861.144504"] = 206910,
	["128858.144504"] = 202464,
	["128866.144504"] = 209216,

	["128820.144505"] = 194312,
	["127857.144505"] = 187321,
	["128858.144505"] = 202426,
	["128861.144505"] = 197080,
	["128832.144505"] = 207352,
	["128862.144505"] = 195322,
	["128866.144505"] = 209220,

	["128862.144506"] = 195323,
	["128832.144506"] = 207375,
	["128861.144506"] = 197139,
	["128858.144506"] = 202433,
	["128866.144506"] = 209226,
	["128820.144506"] = 210182,
	["127857.144506"] = 187264,

	["128289.144507"] = 188635,
	["128826.144507"] = 190449,
	["128870.144507"] = 192310,
	["128827.144507"] = 194093,
	["128860.144507"] = 210570,
	["128821.144507"] = 200395,
	["128872.144507"] = 216230,
	["128910.144507"] = 209459,
	["128403.144507"] = 191419,
	["128402.144507"] = 192450,
	["128808.144507"] = 203566,
	["128942.144507"] = 199111,

	["128403.144508"] = 191494,
	["128402.144508"] = 192460,
	["128942.144508"] = 199153,
	["128808.144508"] = 203669,
	["128827.144508"] = 194007,
	["128860.144508"] = 210593,
	["128821.144508"] = 200409,
	["128872.144508"] = 202524,
	["128910.144508"] = 209481,
	["128826.144508"] = 190520,
	["128870.144508"] = 192329,
	["128289.144508"] = 203225,

	["128860.144509"] = 210637,
	["128821.144509"] = 200414,
	["128827.144509"] = 194016,
	["128910.144509"] = 209492,
	["128872.144509"] = 202530,
	["128402.144509"] = 192542,
	["128403.144509"] = 191488,
	["128942.144509"] = 199158,
	["128808.144509"] = 203670,
	["128289.144509"] = 203227,
	["128826.144509"] = 190529,
	["128870.144509"] = 192349,

	["128943.144510"] = 211105,
	["127829.144510"] = 201458,
	["128476.144510"] = 197369,
	["128832.144510"] = 212816,
	["128941.144510"] = 196236,

	["128943.144511"] = 211099,
	["127829.144511"] = 201464,
	["128476.144511"] = 197239,
	["128832.144511"] = 212819,
	["128941.144511"] = 196258,

	["128832.144512"] = 212821,
	["128941.144512"] = 196301,
	["128476.144512"] = 197241,
	["128943.144512"] = 211144,
	["127829.144512"] = 201459,

	["128941.144513"] = 196217,
	["128821.144513"] = 200399,
	["128403.144513"] = 191442,
	["128820.144513"] = 194234,
	["128908.144513"] = 216273,
	["128289.144513"] = 216272,
	["128943.144513"] = 211126,
	["120978.144513"] = 184759,
	["128819.144513"] = 198236,

	["128403.144514"] = 191494,
	["128941.144514"] = 196236,
	["128821.144514"] = 200409,
	["128819.144514"] = 198299,
	["128943.144514"] = 211105,
	["120978.144514"] = 186927,
	["128289.144514"] = 203225,
	["128820.144514"] = 194313,
	["128908.144514"] = 200856,

	["128821.144515"] = 200414,
	["128941.144515"] = 196432,
	["128403.144515"] = 191488,
	["128289.144515"] = 203227,
	["128908.144515"] = 200860,
	["128820.144515"] = 194314,
	["128819.144515"] = 198349,
	["120978.144515"] = 185368,
	["128943.144515"] = 211119,

	["128911.144516"] = 207092,
	["127857.144516"] = 187258,
	["128935.144516"] = 191499,
	["128306.144516"] = 189768,
	["128937.144516"] = 199366,
	["128860.144516"] = 210571,
	["128862.144516"] = 195317,
	["128292.144516"] = 189092,

	["128935.144517"] = 191740,
	["128306.144517"] = 189757,
	["128911.144517"] = 207206,
	["127857.144517"] = 187264,
	["128937.144517"] = 199372,
	["128860.144517"] = 210579,
	["128862.144517"] = 195323,
	["128292.144517"] = 189164,

	["128935.144518"] = 191598,
	["128306.144518"] = 189744,
	["128911.144518"] = 207348,
	["127857.144518"] = 187287,
	["128937.144518"] = 199485,
	["128860.144518"] = 210631,
	["128862.144518"] = 195352,
	["128292.144518"] = 189097,

	["128825.144519"] = 196416,
	["128823.144519"] = 200315,
	["128866.144519"] = 209220,
	["128868.144519"] = 197715,
	["120978.144519"] = 184843,

	["128825.144520"] = 196430,
	["128823.144520"] = 200482,
	["128866.144520"] = 209216,
	["128868.144520"] = 197762,
	["120978.144520"] = 186944,

	["120978.144521"] = 184778,
	["128866.144521"] = 209225,
	["128868.144521"] = 216212,
	["128823.144521"] = 200302,
	["128825.144521"] = 196355,

	["128910.144522"] = 209472,
	["128832.144522"] = 207352,
	["128872.144522"] = 202514,
	["128861.144522"] = 197080,
	["128866.144522"] = 209220,
	["128402.144522"] = 192447,
	["128808.144522"] = 203578,
	["128940.144522"] = 218607,
	["128289.144522"] = 188683,
	["128908.144522"] = 200849,
	["128819.144522"] = 198247,
	["128938.144522"] = 213180,
	["128870.144522"] = 192318,

	["128872.144523"] = 202530,
	["128861.144523"] = 197162,
	["128832.144523"] = 212817,
	["128910.144523"] = 209492,
	["128866.144523"] = 209218,
	["128402.144523"] = 192542,
	["128940.144523"] = 195291,
	["128808.144523"] = 203670,
	["128289.144523"] = 203227,
	["128908.144523"] = 200860,
	["128819.144523"] = 198349,
	["128870.144523"] = 192349,
	["128938.144523"] = 213133,

	["128910.144524"] = 209483,
	["128832.144524"] = 212821,
	["128872.144524"] = 202521,
	["128861.144524"] = 197160,
	["128402.144524"] = 192514,
	["128866.144524"] = 209224,
	["128940.144524"] = 195244,
	["128808.144524"] = 224764,
	["128289.144524"] = 188632,
	["128908.144524"] = 200857,
	["128819.144524"] = 198296,
	["128938.144524"] = 213047,
	["128870.144524"] = 192323,

	["128826.144525"] = 190457,
	["128938.144525"] = 213049,
	["128911.144525"] = 207092,
	["128306.144525"] = 189768,
	["128823.144525"] = 200316,
	["128825.144525"] = 196358,
	["128821.144525"] = 200399,
	["128860.144525"] = 210571,
	["128858.144525"] = 202386,
	["128937.144525"] = 199366,

	["128306.144526"] = 189754,
	["128911.144526"] = 207255,
	["128938.144526"] = 213055,
	["128826.144526"] = 190520,
	["128858.144526"] = 202445,
	["128937.144526"] = 199377,
	["128821.144526"] = 200409,
	["128860.144526"] = 210593,
	["128825.144526"] = 196422,
	["128823.144526"] = 200294,

	["128823.144527"] = 200302,
	["128825.144527"] = 196355,
	["128858.144527"] = 203018,
	["128937.144527"] = 199384,
	["128821.144527"] = 200440,
	["128860.144527"] = 210590,
	["128938.144527"] = 213116,
	["128826.144527"] = 190514,
	["128911.144527"] = 207354,
	["128306.144527"] = 186320,

	["128943.144528"] = 211108,
	["128870.144528"] = 192310,
	["127829.144528"] = 201454,
	["128942.144528"] = 199111,
	["128476.144528"] = 197231,
	["128868.144528"] = 197708,
	["128403.144528"] = 191419,
	["128402.144528"] = 192450,
	["128292.144528"] = 189080,
	["128910.144528"] = 209459,
	["128827.144528"] = 194093,

	["128870.144529"] = 192326,
	["128943.144529"] = 211123,
	["127829.144529"] = 201457,
	["128942.144529"] = 199152,
	["128476.144529"] = 197235,
	["128868.144529"] = 197716,
	["128403.144529"] = 191592,
	["128402.144529"] = 192457,
	["128292.144529"] = 189164,
	["128910.144529"] = 216274,
	["128827.144529"] = 193645,

	["127829.144530"] = 201459,
	["128943.144530"] = 211144,
	["128870.144530"] = 192323,
	["128827.144530"] = 193642,
	["128910.144530"] = 209483,
	["128292.144530"] = 189154,
	["128402.144530"] = 192514,
	["128403.144530"] = 191565,
	["128868.144530"] = 197711,
	["128476.144530"] = 197241,
	["128942.144530"] = 199212,

	["128908.144531"] = 200846,
	["128935.144531"] = 191493,
	["128938.144531"] = 213051,
	["128826.144531"] = 190449,
	["128819.144531"] = 215381,
	["128861.144531"] = 197038,
	["128872.144531"] = 216230,
	["128937.144531"] = 199364,
	["128940.144531"] = 195243,
	["128808.144531"] = 203566,

	["128808.144532"] = 203638,
	["128940.144532"] = 195266,
	["128937.144532"] = 199372,
	["128861.144532"] = 197139,
	["128872.144532"] = 202522,
	["128819.144532"] = 198292,
	["128826.144532"] = 190467,
	["128938.144532"] = 213062,
	["128935.144532"] = 191740,
	["128908.144532"] = 200853,

	["128819.144533"] = 198349,
	["128826.144533"] = 190529,
	["128938.144533"] = 213133,
	["128935.144533"] = 191577,
	["128908.144533"] = 200860,
	["128808.144533"] = 203670,
	["128940.144533"] = 195291,
	["128937.144533"] = 199380,
	["128861.144533"] = 197162,
	["128872.144533"] = 202530,

	["128866.145346"] = 209216,
	["128858.145346"] = 202464,
	["128862.145346"] = 195352,
	["128832.145346"] = 212819,
	["128861.145346"] = 206910,
	["127857.145346"] = 187287,
	["128820.145346"] = 194239,

	["127857.145347"] = 187321,
	["128820.145347"] = 194312,
	["128866.145347"] = 209220,
	["128832.145347"] = 207352,
	["128862.145347"] = 195322,
	["128861.145347"] = 197080,
	["128858.145347"] = 202426,

	["128820.145348"] = 210182,
	["127857.145348"] = 187264,
	["128861.145348"] = 197139,
	["128862.145348"] = 195323,
	["128832.145348"] = 207375,
	["128858.145348"] = 202433,
	["128866.145348"] = 209226,

	["128808.145349"] = 203566,
	["128942.145349"] = 199111,
	["128403.145349"] = 191419,
	["128402.145349"] = 192450,
	["128872.145349"] = 216230,
	["128910.145349"] = 209459,
	["128860.145349"] = 210570,
	["128827.145349"] = 194093,
	["128821.145349"] = 200395,
	["128870.145349"] = 192310,
	["128826.145349"] = 190449,
	["128289.145349"] = 188635,

	["128872.145350"] = 202524,
	["128910.145350"] = 209481,
	["128860.145350"] = 210593,
	["128821.145350"] = 200409,
	["128827.145350"] = 194007,
	["128942.145350"] = 199153,
	["128808.145350"] = 203669,
	["128403.145350"] = 191494,
	["128402.145350"] = 192460,
	["128289.145350"] = 203225,
	["128870.145350"] = 192329,
	["128826.145350"] = 190520,

	["128870.145351"] = 192349,
	["128910.145351"] = 209492,
	["128821.145351"] = 200414,
	["128872.145351"] = 202530,
	["128942.145351"] = 199158,
	["128289.145351"] = 203227,
	["128827.145351"] = 194016,
	["128402.145351"] = 192542,
	["128808.145351"] = 203670,
	["128403.145351"] = 191488,
	["128860.145351"] = 210637,
	["128826.145351"] = 190529,

	["127829.145352"] = 201458,
	["128832.145352"] = 212816,
	["128476.145352"] = 197369,
	["128943.145352"] = 211105,
	["128941.145352"] = 196236,

	["127829.145353"] = 201464,
	["128832.145353"] = 212819,
	["128941.145353"] = 196258,
	["128476.145353"] = 197239,
	["128943.145353"] = 211099,

	["128821.145355"] = 200399,
	["128941.145355"] = 196217,
	["128403.145355"] = 191442,
	["128289.145355"] = 216272,
	["128908.145355"] = 216273,
	["128820.145355"] = 194234,
	["128819.145355"] = 198236,
	["120978.145355"] = 184759,
	["128943.145355"] = 211126,

	["128819.145356"] = 198299,
	["120978.145356"] = 186927,
	["128943.145356"] = 211105,
	["128289.145356"] = 203225,
	["128908.145356"] = 200856,
	["128820.145356"] = 194313,
	["128403.145356"] = 191494,
	["128821.145356"] = 200409,
	["128941.145356"] = 196236,

	["128403.145357"] = 191488,
	["128821.145357"] = 200414,
	["128941.145357"] = 196432,
	["128819.145357"] = 198349,
	["120978.145357"] = 185368,
	["128943.145357"] = 211119,
	["128289.145357"] = 203227,
	["128908.145357"] = 200860,
	["128820.145357"] = 194314,

	["128860.145358"] = 210571,
	["128937.145358"] = 199366,
	["128292.145358"] = 189092,
	["128862.145358"] = 195317,
	["128306.145358"] = 189768,
	["128935.145358"] = 191499,
	["128911.145358"] = 207092,
	["127857.145358"] = 187258,

	["128911.145359"] = 207206,
	["127857.145359"] = 187264,
	["128306.145359"] = 189757,
	["128935.145359"] = 191740,
	["128860.145359"] = 210579,
	["128937.145359"] = 199372,
	["128292.145359"] = 189164,
	["128862.145359"] = 195323,

	["128911.145360"] = 207348,
	["127857.145360"] = 187287,
	["128935.145360"] = 191598,
	["128306.145360"] = 189744,
	["128937.145360"] = 199485,
	["128860.145360"] = 210631,
	["128862.145360"] = 195352,
	["128292.145360"] = 189097,

	["128866.145361"] = 209220,
	["128868.145361"] = 197715,
	["128823.145361"] = 200315,
	["128825.145361"] = 196416,
	["120978.145361"] = 184843,

	["128825.145362"] = 196430,
	["128868.145362"] = 197762,
	["128866.145362"] = 209216,
	["128823.145362"] = 200482,
	["120978.145362"] = 186944,

	["120978.145363"] = 184778,
	["128825.145363"] = 196355,
	["128823.145363"] = 200302,
	["128866.145363"] = 209225,
	["128868.145363"] = 216212,

	["128908.145364"] = 200849,
	["128289.145364"] = 188683,
	["128938.145364"] = 213180,
	["128870.145364"] = 192318,
	["128819.145364"] = 198247,
	["128910.145364"] = 209472,
	["128832.145364"] = 207352,
	["128861.145364"] = 197080,
	["128872.145364"] = 202514,
	["128808.145364"] = 203578,
	["128940.145364"] = 218607,
	["128402.145364"] = 192447,
	["128866.145364"] = 209220,

	["128819.145365"] = 198349,
	["128870.145365"] = 192349,
	["128938.145365"] = 213133,
	["128289.145365"] = 203227,
	["128908.145365"] = 200860,
	["128402.145365"] = 192542,
	["128866.145365"] = 209218,
	["128808.145365"] = 203670,
	["128940.145365"] = 195291,
	["128861.145365"] = 197162,
	["128872.145365"] = 202530,
	["128832.145365"] = 212817,
	["128910.145365"] = 209492,

	["128819.145366"] = 198296,
	["128938.145366"] = 213047,
	["128870.145366"] = 192323,
	["128289.145366"] = 188632,
	["128908.145366"] = 200857,
	["128866.145366"] = 209224,
	["128402.145366"] = 192514,
	["128940.145366"] = 195244,
	["128808.145366"] = 224764,
	["128910.145366"] = 209483,
	["128832.145366"] = 212821,
	["128861.145366"] = 197160,
	["128872.145366"] = 202521,

	["128823.145367"] = 200316,
	["128860.145367"] = 210571,
	["128821.145367"] = 200399,
	["128858.145367"] = 202386,
	["128937.145367"] = 199366,
	["128825.145367"] = 196358,
	["128911.145367"] = 207092,
	["128826.145367"] = 190457,
	["128938.145367"] = 213049,
	["128306.145367"] = 189768,

	["128911.145368"] = 207255,
	["128938.145368"] = 213055,
	["128826.145368"] = 190520,
	["128306.145368"] = 189754,
	["128823.145368"] = 200294,
	["128858.145368"] = 202445,
	["128937.145368"] = 199377,
	["128860.145368"] = 210593,
	["128821.145368"] = 200409,
	["128825.145368"] = 196422,

	["128306.145369"] = 186320,
	["128938.145369"] = 213116,
	["128826.145369"] = 190514,
	["128911.145369"] = 207354,
	["128825.145369"] = 196355,
	["128937.145369"] = 199384,
	["128858.145369"] = 203018,
	["128860.145369"] = 210590,
	["128821.145369"] = 200440,
	["128823.145369"] = 200302,

	["128943.145370"] = 211108,
	["128870.145370"] = 192310,
	["127829.145370"] = 201454,
	["128292.145370"] = 189080,
	["128910.145370"] = 209459,
	["128827.145370"] = 194093,
	["128942.145370"] = 199111,
	["128868.145370"] = 197708,
	["128476.145370"] = 197231,
	["128402.145370"] = 192450,
	["128403.145370"] = 191419,

	["128827.145371"] = 193645,
	["128910.145371"] = 216274,
	["128292.145371"] = 189164,
	["128402.145371"] = 192457,
	["128403.145371"] = 191592,
	["128476.145371"] = 197235,
	["128868.145371"] = 197716,
	["128942.145371"] = 199152,
	["127829.145371"] = 201457,
	["128870.145371"] = 192326,
	["128943.145371"] = 211123,

	["128942.145372"] = 199212,
	["128402.145372"] = 192514,
	["128403.145372"] = 191565,
	["128868.145372"] = 197711,
	["128476.145372"] = 197241,
	["128910.145372"] = 209483,
	["128292.145372"] = 189154,
	["128827.145372"] = 193642,
	["128870.145372"] = 192323,
	["128943.145372"] = 211144,
	["127829.145372"] = 201459,

	["128861.145373"] = 197038,
	["128872.145373"] = 216230,
	["128937.145373"] = 199364,
	["128808.145373"] = 203566,
	["128940.145373"] = 195243,
	["128908.145373"] = 200846,
	["128935.145373"] = 191493,
	["128826.145373"] = 190449,
	["128938.145373"] = 213051,
	["128819.145373"] = 215381,

	["128819.145374"] = 198292,
	["128826.145374"] = 190467,
	["128938.145374"] = 213062,
	["128935.145374"] = 191740,
	["128908.145374"] = 200853,
	["128808.145374"] = 203638,
	["128940.145374"] = 195266,
	["128937.145374"] = 199372,
	["128861.145374"] = 197139,
	["128872.145374"] = 202522,

	["128940.145375"] = 195291,
	["128808.145375"] = 203670,
	["128872.145375"] = 202530,
	["128861.145375"] = 197162,
	["128937.145375"] = 199380,
	["128826.145375"] = 190529,
	["128938.145375"] = 213133,
	["128819.145375"] = 198349,
	["128908.145375"] = 200860,
	["128935.145375"] = 191577,
}
