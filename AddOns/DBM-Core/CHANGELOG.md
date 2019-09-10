# Deadly Boss Mods Core

## [8.2.17](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/8.2.17) (2019-09-09)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/8.2.16...8.2.17)

- Prepare to draft a new retail release, i imagine quite a few more people affected by that sound issue since twitch client messed up installs for a lot of users that day.  
- Add additional failsafe for reverse. don't want the repairer to run if someone uses retail DBM on classic :D  
- Automatically repair bad sound configuration from using an old DBM-Classic on retail. Closes #65  
- Push debug to have users run when their sounds are screwed up  
- Slight document tweak, and bump alpha revision  
- Fixed adds and addscustom special warning type assignments to conform to standards rest of them do (all lower case)  
    Include icon in special warning callback, for uniformity.  
    Added a new boolean value to DBM\_Announce to say whether or not it's a special warning object  
    Improved documentation of DBM\_Announce callback types  
- Fix args lengths for DBM\_Announce (#63)  
    In the first case, we have icon as the 2nd arg. We should keep it standard and parse nil in the second usage here so they're of fixed args length.  
- Fire a playsound event (#64)  
    * Fire a playsound event  
    This will be useful for checking when cases like "stackhigh" are used, which we can't detect elsewhere.  
    Requested by Alaror.  
- Allow SetColor to allow a table without keys (#62)  
    * Allow SetColor to allow a table without keys  
    Convert a table without keys into the required table with keys  
- Forgot a rename here  
- Delete decree timer entirely, they happen on phase changes, and people know when they happen.  
    Adjust hulk timer by 2 seconds for hulk 2 mythic  
- Fix incorrect usage of :Show instead of :Play  
