# [5.17.1](https://github.com/WeakAuras/WeakAuras2/tree/5.17.1) (2024-09-07)

[Full Changelog](https://github.com/WeakAuras/WeakAuras2/compare/5.17.0...5.17.1)

## Highlights

 - The options now have a "Thanks" button where we list all our supporters, thanks for being awesome!
- Fixed a bug with cooldown tracking
- Item Count triggers can now use reagent/account bank API 

## Commits

InfusOnWoW (7):

- Ensure that talent data is up to date on initial login
- Fix Lua Error in Cooldown Tracking
- Item Count: Add support for reagent/account bank api (#5389)
- Update Discord List
- Options: Add a Thanks button
- Update Atlas File List from wago.tools
- Update Atlas File List from wago.tools

Jon (1):

- Fix percent progress validation and parsing (#5381)

Stanzilla (2):

- Update WeakAurasModelPaths from wago.tools
- Update WeakAurasModelPaths from wago.tools

dependabot[bot] (1):

- Bump cbrgm/mastodon-github-action from 2.1.5 to 2.1.8

emptyrivers (2):

- fux a small mem leak as user edits custom code
- close a hole in the sandbox

mrbuds (4):

- fix (#5390)
- fix keys with wrong type after export from wago
- Fix data for auras with holes in multiEntry fields
- Removing an element of a multyEntry field could leave an empty space in the list, fix #5361

