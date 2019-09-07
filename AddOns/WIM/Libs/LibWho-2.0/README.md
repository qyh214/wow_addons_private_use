# Addon Control Panel (ACP)
Stop logging out of the game just to change your addons!
ACP adds the "Addons" button to the game's main menu (The one you get when you hit ESC). It allows you to manage your addons in game, with an interface which looks similar to the blizzard addon manager. ACP will help you deal with the "Clutter" that multi-part addons and libraries introduce by displaying your addons in logical arrangements. ACP has many features to make your addon list easy to manage, help you with missing libraries, and provide you with detailed information about each addon.

## Slash Commands
`/acp` - show and hide the ACP window

`/acp addset <set #>` - enable an addon set

`/acp removeset <set #>` - disable an addon set

`/acp disableall` - disable all addons (except protected and ACP)

`/acp default` - restore the enabled addons to what was enabled last time the UI was loaded

## Icon meaning
`Star`: Protected addon - this addon will not be disabled when you choose disable all, also if it is not enabled when you log into the game, it will be re-enabled and you will be prompted to reload the ui.

`Dk Grey Open Lock`: Addon does not supply compatibility information

`Lt Grey Closed Lock`: Addon has provided compatibility information

## Addon compatibility

Helps you determine if the addon supports the current version of the game that you are running. You will see further information in the tooltip for the addon, and incompatible/out of date addons will be labeled in the main addon list.

## Credits
ACP is based on the work of 2 other projects rMCP, which is a version of MCP modified by Rophy, and MCP originally by Saien.