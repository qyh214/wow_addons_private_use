# Hekili

## [v11.2.5-1.0.0](https://github.com/Hekili/hekili/tree/v11.2.5-1.0.0) (2025-11-01)
[Full Changelog](https://github.com/Hekili/hekili/compare/v11.2.0-1.0.1h...v11.2.5-1.0.0) [Previous Releases](https://github.com/Hekili/hekili/releases)

- TOC  
- Merge pull request #5344 from eXhausted/patch-1  
    Update Targets.lua  
- Merge pull request #5343 from syrifgit/legion-remix  
    Support Legion Remix Hard Mode Target Detection  
- Merge pull request #5342 from syrifgit/guardian-apl  
    Guardian Header Update  
- Merge pull request #5341 from syrifgit/fire-apl  
    Fire Mage APL Sync  
- Merge pull request #5340 from syrifgit/bm-apl  
    Hunter APL Sync  
- Merge pull request #5323 from johnnylam88/fix/setting-purify-for-niuzao  
    fix: using Purifying Brew to trigger Niuzao Stomp is baseline  
- Update Targets.lua  
    Adding exception for Araz encounter in Manaforge Omega  
- Update Targets.lua  
- Support Legion Remix Hard Mode Target Detection  
- Guardian Header Update  
    No actual changes needed, it just removes prowl which you already commented out  
- Fire Mage APL Sync  
    Standard sync: https://github.com/simulationcraft/simc/commit/1a1f68bbc5fbd69d5155a97e5a69dfc6a46223dd  
- Hunter APL Sync  
    # Standard syncs  
    ## BM  
    - https://github.com/simulationcraft/simc/commit/69f166b9bde8faf03d5042291c9c74e455441e0b  
    - https://github.com/simulationcraft/simc/commit/66444322d45efbe39d172bc8d3ee36afacd0ff6b  
    - https://github.com/simulationcraft/simc/commit/07fcac77e140c923d37232299153513cc8ee4504  
    ## MM  
    - https://github.com/simulationcraft/simc/commit/96226625caa584b265367686c1fff943b7b69625  
- fix: using Purifying Brew to trigger Niuzao Stomp is baseline  
- Merge pull request #5309 from syrifgit/outlaw-disorienting-strikes  
    Unseen Blade Stuff Again  
- Merge pull request #5318 from johnnylam88/fix/dk-visceral-strength  
    fix: track the strength buff from San'layn Visceral Strength  
- fix: track the strength buff from San'layn Visceral Strength  
    In SimulationCraft, the strength buff is simply `visceral_strength` for  
    both Blood and Unholy, so rename `visceral_strength_buff` to match.  
    Apply the buff when Crimson Scourge is consumed as Blood or if Sudden  
    Doom is consumed as Unholy.  
- Update Sub  
- Unseen Blade Stuff Again  
