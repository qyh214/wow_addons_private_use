Fork of [AceEvent-3.0](https://github.com/WoWUIDev/Ace3/tree/master/AceEvent-3.0), which aims to resolve CPU profiling attributing CPU usage to the addon who first loads AceEvent.

You can update .pkgmeta, your toc/xml, and your AceAddon call like this:
```diff
- Libs/AceEvent-3.0: https://repos.wowace.com/wow/ace3/trunk/AceEvent-3.0
+ Libs/NumyAceEvent-3.0: https://github.com/NumyAddon/NumyAceEvent-3.0.git

- Libs/AceEvent-3.0/AceEvent-3.0.xml
+ Libs/NumyAceEvent-3.0/NumyAceEvent-3.0.xml

- <Include file="AceEvent-3.0\AceEvent-3.0.xml"/>
+ <Include file="NumyAceEvent-3.0\NumyAceEvent-3.0.xml"/>

- local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0");
+ local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "NumyAceEvent-3.0");
```

All other usages should remain identical
