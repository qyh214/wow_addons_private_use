# WIM

## [3.8.16](https://github.com/sylvanaar/wow-instant-messenger/tree/3.8.16) (2021-01-24)
[Full Changelog](https://github.com/sylvanaar/wow-instant-messenger/compare/3.8.15...3.8.16) [Previous Releases](https://github.com/sylvanaar/wow-instant-messenger/releases)

- update TOC  
- Fix weak aura links Closes #39. Credits to pmuellerda  
- bump toc for retail  
- zhCN(Chinese) translation (#36)  
- Merge pull request #37 from fubaWoW/master  
    fixed and updated URLHandler.lua  
- fixed and updated URLHandler.lua  
    Fixed "format" error in "URLHandler.lua"  
    **removed:**  
    WoW-Heroes (no longer exist)  
    WoWTrack (no longer exist)  
    **fixed:**  
    askmrrobot  
    **added:**  
    Character Name (often Helpful!)  
- Fix inviting users on 9.0 client. Closes #34  
- attempt to avoid more errors caused by falling back to classic apis on retail by reversing the logic to now actually check classic first and then retail being fallback. Classic is never going to fallback to else unlike retail tends to do when magic tables are nil.  
    on that note, added more nil checks to the magic tables that aren't that magical sometimes  
    Closes #33  
