# <DBM> Challenges

## [r125](https://github.com/DeadlyBossMods/DBM-Challenges/tree/r125) (2020-03-10)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Challenges/compare/r124...r125)

- Toned down Toxic Breath warning. It's used by more mobs than i realized and doesn't need a special warning anyways. Standard warning suits it fine  
    Added defiled ground yell since it was missing one.  
    Added horrifying Shout general announce if interrupt is on CD or it's an off target.  
    Added Nameplate aura for horrifying Shout as well to visual which of the two mobs is casting it, if it's an off target.  
    Improved Nameplate aura clearning for Touch of Abyss if cast is just flat out never interrupted in any way what so ever.  
- Tweak last, to make sure ignores always added to table regardless  
- Attempt to throttle false positives for haunting shadows, when they are running off screen but clip into nameplate range for brief moments while doing it.  
