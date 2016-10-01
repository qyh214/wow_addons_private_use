------------------------------------------------------------
-- PartyDungeons.lua
--
-- Abin
-- 2016/09/13
------------------------------------------------------------

local module = CompactRaid:FindModule("RaidDebuff")
if not module then return end

local TIER = 7 -- Legion

-- Maw of Souls (727)
module:RegisterDebuff(TIER, 727, 0, 193364)
module:RegisterDebuff(TIER, 727, 0, 197262)

-- Neltharion's Lair (767)
module:RegisterDebuff(TIER, 767, 0, 192800)
module:RegisterDebuff(TIER, 767, 0, 199176)
module:RegisterDebuff(TIER, 767, 0, 210150)

-- Vault of the Wardens (707)
module:RegisterDebuff(TIER, 707, 0, 200904)
module:RegisterDebuff(TIER, 707, 0, 192656)

-- Violet Hold (777)
module:RegisterDebuff(TIER, 777, 0, 201476)
module:RegisterDebuff(TIER, 777, 0, 201672)
module:RegisterDebuff(TIER, 777, 0, 201379)
module:RegisterDebuff(TIER, 777, 0, 202779, 5)
module:RegisterDebuff(TIER, 777, 0, 202804, 4)
module:RegisterDebuff(TIER, 777, 0, 202217, 4)
module:RegisterDebuff(TIER, 777, 0, 202300)
module:RegisterDebuff(TIER, 777, 0, 202306)

-- Court of Stars (800)
module:RegisterDebuff(TIER, 800, 0, 207278)
module:RegisterDebuff(TIER, 800, 0, 208165)

-- Eye of Azshara (716)
module:RegisterDebuff(TIER, 716, 0, 191977)
module:RegisterDebuff(TIER, 716, 0, 193018)
module:RegisterDebuff(TIER, 716, 0, 191855)
module:RegisterDebuff(TIER, 716, 0, 192708)

-- Halls of Valor (721)
module:RegisterDebuff(TIER, 721, 0, 193083)
module:RegisterDebuff(TIER, 721, 0, 192048)
module:RegisterDebuff(TIER, 721, 0, 192305)
module:RegisterDebuff(TIER, 721, 0, 196495)
module:RegisterDebuff(TIER, 721, 0, 196838)
module:RegisterDebuff(TIER, 721, 0, 193765)
module:RegisterDebuff(TIER, 721, 0, 197961)

-- The Arcway (726)
module:RegisterDebuff(TIER, 726, 0, 196562)
module:RegisterDebuff(TIER, 726, 0, 196070)
module:RegisterDebuff(TIER, 726, 0, 200227)
module:RegisterDebuff(TIER, 726, 0, 203882)

-- Darkheart Thicket (762)
module:RegisterDebuff(TIER, 762, 0, 196376)
module:RegisterDebuff(TIER, 762, 0, 204611)
module:RegisterDebuff(TIER, 762, 0, 200359)
module:RegisterDebuff(TIER, 762, 0, 200243)

-- Black Rook Hold (740)
module:RegisterDebuff(TIER, 740, 0, 194960)
module:RegisterDebuff(TIER, 740, 0, 197478)
module:RegisterDebuff(TIER, 740, 0, 197418)
module:RegisterDebuff(TIER, 740, 0, 198080)
module:RegisterDebuff(TIER, 740, 0, 199168)
module:RegisterDebuff(TIER, 740, 0, 198635, 5)
module:RegisterDebuff(TIER, 740, 0, 199092)