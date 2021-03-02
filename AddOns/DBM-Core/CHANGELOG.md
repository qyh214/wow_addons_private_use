# Deadly Boss Mods Core

## [9.0.21](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/9.0.21) (2021-02-19)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/9.0.20...9.0.21) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prepare hotfix update for council regression fixes  
- Fix phase changes on council again.  
- Actually make callbacks fire before the returns exit the function  
- Add pause and resume callbacks for timer modification weak auras to be able to understand these events.  
- Bar pause and resume now operational.  
    Applying it to council asap for testing. it passed debug testing though.  
- Fixed a bug where phase change timers could all be 3 seconds off on council of blood do to a spellID addition that shouldn't have been added  
- Attempt to Fix Dark recital timer not updating when it began casting but didn't finish casting.  
    Slightly improved dance timer correctly as well.  
- Force Sound\_NumChannels to 128 from now. if blizzard doesn't like it,  they can fix the damn problem we reported YEARS ago https://www.patreon.com/posts/addon-sound-work-16575915  
