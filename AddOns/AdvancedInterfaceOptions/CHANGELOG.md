# Advanced Interface Options

## [1.3.0](https://github.com/Stanzilla/AdvancedInterfaceOptions/tree/1.3.0) (2019-06-25)
[Full Changelog](https://github.com/Stanzilla/AdvancedInterfaceOptions/compare/1.2.12...1.3.0)

- Update TOC for Patch 8.2  
- Fixed UVARINFO table (#11)  
    uvars have to be updated when setting their related cvar, or the floating combat text options would not work until after a reload  
- Embedded ketho's UVARINFO table which is no longer global, did not check what this actually does or whether we should keep it  
