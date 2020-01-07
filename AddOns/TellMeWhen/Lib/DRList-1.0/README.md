# DRList (Diminishing Returns Database)

Library that contains (hopefully) the most up to date [diminishing returns](https://wow.gamepedia.com/Diminishing_returns) categorization. This is purely the diminishing return data itself with API's to determine if a spellID has a diminishing return, if it diminishes in PvE and the category it diminishes in.
  
**This addon is a fork/rewrite of [DRData-1.0.](https://www.wowace.com/projects/drdata-1-0) which seems to be abandoned.**  
DRList is updated to seamlessly support both Classic and Retail World of Warcraft. (Classic spell list is still WIP)
  
[API Documentation.](https://wardz.github.io/DRList-1.0/)

## Upgrading from DRData to DRList

- All occurances of `DRData` must be renamed to `DRList`.
- There's a new category added for Disarms, depending on how your addon is coded you might need to account for this. (In Classic there's several new categories added.)
- If you used to access the tables directly, you'll now need to add the current expansion as an extra table property.
  E.g `DRData.categoryNames` to `DRList.categoryNames.retail` or `DRList.categoryNames.classic`. The only exception for this is
  the spell list table. For API functions there should be no need for changes.

## Manual Install

Installing from source/master is not guaranteed to work. You should download a packaged version here instead:

- [Curseforge Download](https://wow.curseforge.com/projects/drlist-1-0)  
- [Github Download](https://github.com/wardz/drlist/releases)
Unzip it into ```WoW/Interface/AddOns/YourAddon/libs``` and add an entry for it in your addon's .toc file. (See Example Usage).
You may also install it as a standalone addon by putting it directly in ```WoW/Interface/AddOns/```. This is recommended when
forking the library or creating addon packs/plugins where multiple addons use the lib.

## Usage with Curseforge Packager

You can ignore this section if you don't use the [Curseforge packager](https://authors.curseforge.com/knowledge-base/world-of-warcraft/527-preparing-the-packagemeta-file).
  
**addon/.pkgmeta**

```
externals:
  libs/DRList-1.0:
    url: git://github.com/wardz/DRList-1.0
    tag: latest

ignore:
  - libs/DRList-1.0/DRList-1.0.toc # Optional
  - libs/DRList-1.0/libs/LibStub # Optional if LibStub already exists
```

## Example Usage

- [Example usage for Retail](https://github.com/wardz/DRList-1.0/wiki/Example-Usage-Retail)
- [Example usage for Classic](https://github.com/wardz/DRList-1.0/wiki/Example-Usage-Classic)
Feel free to open an issue ticket if you have any questions.

## Contributing

- [Submit a pull request.](https://github.com/wardz/DRList-1.0/pulls)  
  I recommend creating a symlink between your WoW addons folder and `DRList-1.0/DRList-1.0/` when forking.  
  Tests will be ran automatically on pull requests but you can also run them ingame by typing `/drlist`.  
- [Report bugs, requests or missing spells.](https://github.com/wardz/drlist-1.0/issues)
- [Help translate.](https://www.curseforge.com/wow/addons/drlist-1-0/localization)

## License

Copyright (C) 2019 Wardz | [MIT License](https://opensource.org/licenses/mit-license.php).
