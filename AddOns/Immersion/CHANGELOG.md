# Immersion

## [1.4.2-B](https://github.com/seblindfors/Immersion/tree/1.4.2-B) (2022-05-29)
[Full Changelog](https://github.com/seblindfors/Immersion/commits/1.4.2-B) [Previous Releases](https://github.com/seblindfors/Immersion/releases)

- Update .pkgmeta  
- Update .gitignore  
- Create .pkgmeta  
- Create .gitignore  
- Update Immersion.toc  
- Create release.yml  
- 1.4.1  
    - Fix backdrop bug  
    - Fix unsafe fade management  
    - Fix tooltip size bug on uncached items  
- 1.3.8  
- 1.3.7  
- 1.3.5  
- Merge branch 'master' of https://github.com/seblindfors/Immersion  
- 1.3.4  
- Merge pull request #9 from LudiusMaximus/master  
    Close TalkBox with left click.  
- Merge pull request #8 from metthal/friendship-progress-bar  
    Fixed progress bar with NPC friendship reputation to display correct progress  
- Close TalkBox with left click.  
- Fixed progress bar with NPC friendship reputation to display correct progress  
- rm git  
- 9.0.0  
- 1.2.1-A  
- 1.2.0  
    - Refactoring  
    - Added cross compat interface for Classic/Retail  
    - Removed nameplate anchor due to new restriction  
- 1.0.7  
- 1.0.7  
- 0.7.3  
- 1.7.0-C  
- 0.7.0  
- 0.6.0  
    Refactoring, new fade management  
- 0.5.4  
    Fixed pattern replacement for triple dots.  
- 0.5.3  
- 0.4.3  
    Bugs fixed related to scaling, moving and dynamic offset calculations.  
- 0.4.0  
    - Streamlined options.  
    - Frames are now mouse movable instead of using sliders.  
    - Quest objectives and rewards can now be scaled separately.  
    - Added option to disable sheen animation.  
    - Removed fly-in animation option and replaced it with a selection of  
    four dynamic offset modifiers: off, instant, fast and slow.  
    - Added Khadgar seal quest.  
- Patch 0.3.0  
    • Changed step size of frame offsets to 10.  
    • Added frame fade conflict detection.  
    • Added 'on-the-fly' mode.  
    • Added immersive mode (click mimics accept input).  
    • Gossip options can now be moved with the mouse, or alternatively,  
    appear at the mouse cursor.  
- Traditional chinese locale, fixed model paths  
- Fade fixes, title scrolling, model changes  
    Fixed issues with UI fading; excluded tooltips and popups. Frames now  
    have to be explicitly mouse enabled to fade back in.  
    Added custom quest progress content handler.  
    A quest marker is now shown instead of the player when a quest comes  
    from 'the ether'.  
    Buttons are now readjusted in height after scaling up/down to account  
    for UI scale inconsistency.  
    Buttons can now be scrolled vertically to account for the rare case when  
    they collectively exceed the height of the viewport.  
    The main content frame is now dynamically readjusting to whatever  
    content is displayed.  
- Locale prepared, item update bug fix  
    Refactored all settings lookups to addon metatable.  
    Fixed bug with item updates in an already visible dialog.  
    Added option to fade out interface when interacting with an NPC.  
- Reward textures, item cache handling  
    - Restyled reward buttons.  
    - Added handling for uncached items.  
- New options, reward bug fixed  
- Smart option selection on hotkey, quest handling  
- Status bar added, fixed quest -> gossip bug.  
    - Text truncation should no longer be possible. Newline strings are  
    capped at 200 characters before broken up into sentences.  
    - Popup quests should no longer show an empty detail frame.  
    - Gossip interaction is now cancelled when transitioning into a quest  
    event.  
    - Added a custom friendship statusbar since the default one isn't always  
    shown when it should. (probably moved by default UI)  
    - Model frame is now animated in response to its own visibility state  
    instead of the last event that occurred.  
- Slash handler, NomiCakes compat  
    - Added slash handler to open config window.  
    - Added compatibility for NomiCakes.  
- Titles mixin, bug fixes  
    - Revamped gossip / quest title handling.  
    - Fixed number shortcut bug.  
- Dynamic anchoring, refactoring  
    - Refactored.  
    - Fixed flickering update bug on QUEST\_GREETING.  
    - Fixed a bunch of wonky sliders in the settings.  
    - Added ability to re-anchor the talking head.  
    - Clarified some strings.  
    - Added model mixin with function wrappers.  
- Box scale, added hilite to talkbox  
    - Nerfed default box scale to 1 (more naturally aligned with the UI)  
    - Added hilite to clickable talkbox when it can be clicked.  
- Added ace embeds  
- Fixed unit is dead bug  
- Merge branch 'master' of https://github.com/seblindfors/Immersion  
- Options added, bug fixes  
    - Added Ace config libraries to deal with options.  
    - Added logo.  
    - Added customizable keybindings.  
    - Handled case where options frame is open.  
    - Added more actions to the all-in-one progress button.  
- Update README.md  
- Create README.md  
- Initial commit  
    - Hello world :)  
    - Added talking head style replacements for quest & gossip  
- :boom::camel: Added .gitattributes & .gitignore files  
