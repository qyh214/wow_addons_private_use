local _, AddOn = ...

AddOn.worldBosses = {
  {
    instanceID = 322,                          -- Pandaria
    numEncounters = 6,
    encounters = {
      { encounterID = 691, questID = 32099 },  -- Sha of Anger
      { encounterID = 725, questID = 32098 },  -- Salyis's Warband
      { encounterID = 814, questID = 32518 },  -- Nalak, The Storm Lord
      { encounterID = 826, questID = 32519 },  -- Oondasta
      { name        = "" , questID = 33117 },  -- The Four Celestials
      { encounterID = 861, questID = 33118 }   -- Ordos, Fire-God of the Yaungol
    }
  },
  {
    instanceID = 557,                          -- Draenor
    numEncounters = 3,
    encounters = {
      { encounterID = 1291, questID = 37460 }, -- Drov the Ruiner
      { encounterID = 1211, questID = 37462 }, -- Tarlna the Ageless
      { encounterID = 1262, questID = 37464 }, -- Rukhmar
      { encounterID = 1452, questID = 39380 }  -- Supreme Lord Kazzak
    }
  },
  {
    instanceID = 822,                          -- Broken Isles
    numEncounters = 1,
    encounters = {
      { encounterID = 1790, questID = 43512 }, -- Ana-Mouz
      { encounterID = 1956, questID = 47061 }, -- Apocron
      { encounterID = 1883, questID = 46947 }, -- Brutallus
      { encounterID = 1774, questID = 43193 }, -- Calamir
      { encounterID = 1789, questID = 43448 }, -- Drugon the Frostblood
      { encounterID = 1795, questID = 43985 }, -- Flotsam
      { encounterID = 1770, questID = 42819 }, -- Humongris
      { encounterID = 1769, questID = 43192 }, -- Levantus
      { encounterID = 1884, questID = 46948 }, -- Malificus
      { encounterID = 1783, questID = 43513 }, -- Na'zak the Fiend
      { encounterID = 1749, questID = 42270 }, -- Nithogg
      { encounterID = 1763, questID = 42779 }, -- Shar'thos
      { encounterID = 1885, questID = 46945 }, -- Si'vash
      { encounterID = 1756, questID = 42269 }, -- The Soultakers
      { encounterID = 1796, questID = 44287 }  -- Withered Jim
    }
  },
  {
    instanceID = 959,                          -- Invasion Points
    numEncounters = 1,
    encounters = {
      { encounterID = 2010, questID = 49199 }, -- Matron Folnuna
      { encounterID = 2011, questID = 48620 }, -- Mistress Alluradel
      { encounterID = 2012, questID = 49198 }, -- Inquisitor Meto
      { encounterID = 2013, questID = 49195 }, -- Occularus
      { encounterID = 2014, questID = 49197 }, -- Sotanathor
      { encounterID = 2015, questID = 49196 }  -- Pit Lord Vilemus
    }
  },
  {
    instanceID = 1028,                         -- Azeroth
    numEncounters = 3,
    encounters = {
      { encounterID = 2139, questID = 52181 }, -- T'zane
      { encounterID = 2141, questID = 52169 }, -- Ji'arak
      { encounterID = 2197, questID = 52157 }, -- Hailstone Construct
      { encounterID = nil , questID = nil   }, -- The Lion's Roar/Doom's Howl
      { encounterID = 2199, questID = 52163 }, -- Azurethos, The Winged Typhoon
      { encounterID = 2198, questID = 52166 }, -- Warbringer Yenajz
      { encounterID = 2210, questID = 52196 }, -- Dunegorger Kraulok
      { encounterID = nil , questID = nil   }, -- Ivus the Forest Lord/Ivus the Decayed
      { encounterID = 2362, questID = 56057 }, -- Ulmath, the Soulbinder
      { encounterID = 2363, questID = 56056 }, -- Wekemara
      { encounterID = 2381, questID = 55466 }, -- Vuk'laz the Earthbreaker
      { encounterID = 2378, questID = 58705 }  -- Grand Empress Shek'zara
    }
  }
}
