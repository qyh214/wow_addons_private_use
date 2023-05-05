# <DBM> Icecrown Citadel

## [r313](https://github.com/DeadlyBossMods/DBM-WotLK/tree/r313) (2023-05-02)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-WotLK/compare/r312...r313) [Previous Releases](https://github.com/DeadlyBossMods/DBM-WotLK/releases)

- bump tocs  
- Update koKR (#34)  
    * Update koKR (Wrath)  
    * Update localization.kr.lua  
    Fix whitespace  
    * Update koKR (Wrath)  
    * Update koKR  
    ---------  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- Fix stating on mimiron for classic, which has been broken entire tier since classic path never actually incremented the phase count Closes https://github.com/DeadlyBossMods/DBM-WotLK/issues/35  
- Fix mistake in last  
- move ulduar to new stage api  
- Update Thorim range check to the correct value of 8 yards (#33)  
    The Classic range options in raids allow for 8 yards, and it is an 8 yard ability according to the wago.tools database `EffectChainTargets` value of "8".  
    This can also be seen ingame when a player is in the 10yd range indicator and chain lightning does not bounce to them.  
    This is mostly problematic for melee, that have a false sense of positioning to both attack the boss and not destroy your raid.  
    The https://wago.tools/db2/SpellEffect\?build\=3.4.1.48632\&filter\[SpellID\]\=64390\&page\=1 link shows an 8 for `EffectChainTargets`, which seems to be the effective bounce chain range.  
- Add IconTexture  
