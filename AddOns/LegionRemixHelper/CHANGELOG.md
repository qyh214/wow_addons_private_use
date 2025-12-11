# Legion Remix Helper

## [1.6.4](https://github.com/Larsj02/LegionRemixHelper/tree/1.6.4) (2025-11-21)
[Full Changelog](https://github.com/Larsj02/LegionRemixHelper/compare/1.6.3...1.6.4) [Previous Releases](https://github.com/Larsj02/LegionRemixHelper/releases)

- Merge pull request #114 from Larsj02/Larsj02-patch-1  
    Update version number to 1.6.4  
- Update version number to 1.6.4  
- Merge pull request #109 from 007bbb/main  
    Update koKR.lua  
- Merge pull request #110 from NORPG/zhTW  
    [Locale] Update zhTW: unified terms.  
- [Locale] Update zhTW: unified terms.  
- Update koKR.lua  
- Merge pull request #107 from nanjuekaien1/patch-15  
    Update zhCN.lua  
- Merge pull request #108 from Hubbotu/patch-10  
    Update ruRU.lua  
- Merge pull request #106 from BradMJustice/hide-collected-items-fix  
    Fix issue #105 - Hide Collected Merchant Items option does not consistently work  
- Update ruRU.lua  
- Update zhCN.lua  
- Update zhCN.lua  
- Refactor: introduce RefreshMerchant and preserve OnMerchantShow wrapper  
    Replace the merchant show/update filtering logic with a generic  
    RefreshMerchant() method and make OnMerchantShow() a thin wrapper  
    for compatibility. Update the MERCHANT\_UPDATE handler to call the new  
    method. This clarifies intent (handles both show and update events) and  
    avoids breaking existing external references.  
- Revert change to GetNpcID  
- Removed .gitignore from .gitignore  
- Reapply merchant filter on merchant frame/data updates  
    Register MERCHANT\_UPDATE and hook MerchantFrame\_Update so the addon  
    rebuilds/applies the filtered vendor list whenever merchant data or  
    the UI updates. Also fallback to UnitGUID("target") when resolving the  
    NPC ID. Fixes collected items sometimes remaining visible until the  
    option was toggled.  
    Modified: Utils/MerchantUtils.lua  
- Merge pull request #104 from nanjuekaien1/patch-14  
    Update zhCN.lua  
- Update zhCN.lua  