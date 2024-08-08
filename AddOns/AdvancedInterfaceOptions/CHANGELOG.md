# Advanced Interface Options

## [2.0.0](https://github.com/Stanzilla/AdvancedInterfaceOptions/tree/2.0.0) (2024-07-28)
[Full Changelog](https://github.com/Stanzilla/AdvancedInterfaceOptions/compare/1.9.1...2.0.0) [Previous Releases](https://github.com/Stanzilla/AdvancedInterfaceOptions/releases)

- Fixups  
- Adjust spell queue option text  
    Co-authored-by: Dimitris Lilis-Kokkoris <32920285+DimitrisLK@users.noreply.github.com>  
- Fix #93  
- Reenable /cvar command  
    Thanks @Xepheris for the hint  
- Add additional SharedXML paths from TWW and SoD phase 4  
- Cleanup all files and add more notes  
- Add StyLua and format all files  
- convert remaining files to LF  
- Ace3 port (#87)  
    * Add Ace3 libs  
    * Buggy, but initial functionality is present  
    Stubbed in the rough outline for our graphical options. The settings still need to be fixed to work between clients, and only 1 panel is done so far. This is most a proof of concept.  
    * Create chat panel  
    * Add combat panel, add headers under the main descriptions  
    * Create Nameplates panel  
    * Add Floating Combat Text panel  
    * Create cVar Panel  
    * Add getCustomVar and setCustomVar back, not sure what they do  
    * Adjust margins in cVar browser to match Ace3 styles  
    * add horizontal separator after general panel desc to match other panels  
    * Remove libs from repo and pull them in via pkgmeta instead  
    * Update CI scripts  
    * Don't scan libs folder in CI  
    * Update .editorconfig  
    * Delete unused tempfix file  
    * Add Status Text panel, fix FCT panel deprecated functionality  
    Add in a Status Text panel, however a few of the frames have been deprecated in wow Retail. I have hidden the affected options from the GUI for Retail. Likewise, I fixed the lost functionality in FCT earlier in the porting process.  
    * no need for FCT\_SetValue() to be on the addon namespace, make it local  
    * No need for setStatusTextBars or setStatusText to be on the addon namespace  
    * Return original reverse-loot and reverse-cleanup functionality  
    * hack for SetInsertItemsRightToLeft() not being instant  
    SetInsertItemsLeftToRight() and SetSortBagsRightToLeft() don't happen instantly, thus the UI will retain the old value since the refresh happens too clickly for the "Get" counterparts to reflect the new values. This is a hack wherein we set a 1/2 second timer to refresh the GUI to allow time for the setting to go through.  
    * Use hidden instead of disabled for client-specific options  
    * fix CI  
    * rename CVar browser section  
    ---------  
    Co-authored-by: Benjamin Staneck <staneck@gmail.com>  