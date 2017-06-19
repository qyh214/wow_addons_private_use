------------------------------------------------------------
-- TombofSargeras.lua
--
-- Abin
-- 2017/06/06
------------------------------------------------------------

local module = CompactRaid:GetModule("RaidDebuff")
if not module then return end

local TIER = 7 -- Legion
local INSTANCE = 875 -- Tomb of Sargeras
local BOSS

BOSS = 1862
module:RegisterDebuff(TIER, INSTANCE, BOSS, 233279)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 230345)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 231363, 5)

BOSS = 1867
module:RegisterDebuff(TIER, INSTANCE, BOSS, 233104)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 233430)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 233983, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 239358)

BOSS = 1856
module:RegisterDebuff(TIER, INSTANCE, BOSS, 231770)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 231998, 5)

BOSS = 1903
module:RegisterDebuff(TIER, INSTANCE, BOSS, 236603)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 234995)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 234996)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 236519)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 236547, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 236550)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 239264)

BOSS = 1861
module:RegisterDebuff(TIER, INSTANCE, BOSS, 230959)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 230201)

BOSS = 1896
module:RegisterDebuff(TIER, INSTANCE, BOSS, 236449)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 236515)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 236513)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 235989, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 236340, 4)

BOSS = 1897
module:RegisterDebuff(TIER, INSTANCE, BOSS, 235213)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 235240)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 235117)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 235534)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 235538)

BOSS = 1873
module:RegisterDebuff(TIER, INSTANCE, BOSS, 239739)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 236494)

BOSS = 1898
module:RegisterDebuff(TIER, INSTANCE, BOSS, 239155)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 238999)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 234295)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 237725)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 239932, 5)

BOSS = 0
