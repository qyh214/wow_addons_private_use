------------------------------------------------------------
-- TheNighthold.lua
--
-- Abin
-- 2019/09/13
------------------------------------------------------------

local module = CompactRaid:FindModule("RaidDebuff")
if not module then return end

local TIER = 7 -- Legion
local INSTANCE = 786 -- The Nighthold
local BOSS

BOSS = 1706
module:RegisterDebuff(TIER, INSTANCE, BOSS, 204531)

BOSS = 1725
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206607)

BOSS = 1731
module:RegisterDebuff(TIER, INSTANCE, BOSS, 208506)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206788)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206641)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 208924)

BOSS = 1751
module:RegisterDebuff(TIER, INSTANCE, BOSS, 212587)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 213328)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 212494)

BOSS = 1762
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206480)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206365)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 212795)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 216040)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 208230)

BOSS = 1713
module:RegisterDebuff(TIER, INSTANCE, BOSS, 205348)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 205420)

BOSS = 1761
module:RegisterDebuff(TIER, INSTANCE, BOSS, 218424)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 218780)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 218438)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 218502)

BOSS = 1732
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206936)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 205649)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206464)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 207720)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206585)

BOSS = 1743
module:RegisterDebuff(TIER, INSTANCE, BOSS, 210387)

BOSS = 1737
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206222)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206883)
