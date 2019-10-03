# Deadly Boss Mods Core

## [8.2.22](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/8.2.22) (2019-09-28)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/8.2.21...8.2.22)

- Prep new tag  
- 8.2.5 introduced some erratic UnitPosition behaviors where x and y return nil in non instanced areas briefly on zone change, this causes arrows when changing between zones to throw nil errors. This update adds a check that if x and y are nil in an area that should not be nil in, it'll skip updates on those frames until x and y start returning again.  
- Tweak option default for Toxic spine, too spammy for my liking. it was only on by default for healers so I didn't know how spammy it felt til I saw a healer PoV stream tonight.  
- Tweaks to GUI (#75)  
    - Use the correct script function for editframes  
    - Removed dropdowns "OnShow", as it's built into dropdowns code  
    - Removed dropdowns "OnClick", as its passed as an argument, and is more reliable  
- Fix  
- Fixed Several bugs with the checkForSafeSender refactor  
    - Prevent C\_BattleNet.GetAccountInfoByID() getting used on non presenceID whispers to fix lua error  
    - Fixed a bug where auto reply didn't reply to a realId friend that was not logged into a game client, since previous check aborted if they weren't.  
    - Fixed a bug where a realId friend that send a whisper over non realId whisper, would not get an auto reply.  
    - Fixed bug where auto accept invites would fail on realId friends, and throw a lua error instead.  
- Rename some callbacks to eliminate common name and ensure they are recognized as DBM events  
- Further optimize checkForSafeSender, there is no reason to scan all friends when we have the presence ID, just request accountinfo by ID instead.  
- Needs to be here too  
- Fixed Overflowing venom warnings/yells, as they have NEVER worked (and it took MANY months for someone to notice/report it, NANI?)  
- Improve bnet logic for safe sender, and add support for filtering people who might send bnet whispers to each other mid fight, who are in same raid group.  
- Pruned option redundancy with status whispers.  
- Revert "Performing Bot Test"  
- Performing Bot Test  
- add discord notifications on failure  
- Fixed lua errors with BNSendGameData api in 8.2.5 by correctly using gameaccount ID instead of battle.net account Id. Made other checks robust while at it to avoid doing anything at all if insufficient game account data  
