# Premade Groups Filter

## [2.8.2](https://github.com/0xbs/premade-groups-filter/tree/2.8.2) (2022-04-08)
[Full Changelog](https://github.com/0xbs/premade-groups-filter/compare/2.8.1...2.8.2) [Previous Releases](https://github.com/0xbs/premade-groups-filter/releases)

- Set version to 2.8.2  
- Restore auto group text for players that do not have an authenticator attached to their account (fixes #86)  
    By overwriting C\_LFGList.GetPlaystyleString, we taint the code writing the tooltip (which does not matter), and also code related to the dropdows where you can select the playstyle. The only relevant protected function here is C\_LFGList.SetEntryTitle, which is only called from LFGListEntryCreation\_SetTitleFromActivityInfo. Players that do not have an authenticator attached to their account cannot set the title or comment when creating groups. Instead, Blizzard sets the title programmatically. If we taint this function, these players can not create groups anymore, so we check on an arbitrary mythic plus dungeon if the player is authenticated to create a group.  
- Create checklist-new-content.md  