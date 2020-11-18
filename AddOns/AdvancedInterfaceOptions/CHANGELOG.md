# Advanced Interface Options

## [1.4.1](https://github.com/Stanzilla/AdvancedInterfaceOptions/tree/1.4.1) (2020-10-29)
[Full Changelog](https://github.com/Stanzilla/AdvancedInterfaceOptions/compare/1.4.0...1.4.1) [Previous Releases](https://github.com/Stanzilla/AdvancedInterfaceOptions/releases)

- Remove unsupported cvars from cvar browser  
    - We have cvars that have been removed from the game hard-coded into the addon;  
    these were previously being stripped out using the CVarExists function, which no longer works  
    - The hard-coded list is now only being used to provide descriptions for cvars  
