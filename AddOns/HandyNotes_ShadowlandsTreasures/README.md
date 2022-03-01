# HandyNotes: Shadowlands Treasures

A [HandyNotes](https://www.curseforge.com/wow/addons/handynotes) plugin to show the Shadowlands treasure items on your map. (That means it **requires** [HandyNotes](https://www.curseforge.com/wow/addons/handynotes), so go install it as well.)

This includes:

* Items found in one-off chests that're mysteriously glowing purple.
* Items dropped by rare mobs.

Items that you've already collected and mobs you've already killed won't be displayed. This uses the "flag" quests that the game relies on to keep track of the items. Sometimes these glitch; generally if they do so, you also won't have gotten achievement-credit / the item, so you'll likely still be interested in the item.

You can right-click on any treasure node and hide it, if you just don't want to see that one. If you have [TomTom](https://www.curseforge.com/wow/addons/tomtom) installed, you can also add a waypoint for that node.

To edit the settings, visit the HandyNotes config panel, expand the "Plugins" section, and click on "Battle for Azeroth". You can then choose which treasures to show, and whether to show ones you've already found.

## Want to help?

If you'd like to submit corrections, please go into the settings as mentioned above and turn on "show quest ids". Then let me know the quest id for the node you want to correct, which will now appear in its tooltip.

If you'd like to submit a new node, you have two options:

1. Tell me where it is. I'll go find it eventually and track down the more obscure details I need to add it.
1. Gather these details yourself and send them to me:
    * Zone and coordinates.
    * What it gives you. This is mostly "a random gray, and some Azurite".
    * The quest id associated with it. This is the tricky one. The easiest way to get it is to install [QuestsChanged](https://www.wowace.com/addons/questschanged/) before you open the treasure, then open the treasure and check it to see what quest was triggered.