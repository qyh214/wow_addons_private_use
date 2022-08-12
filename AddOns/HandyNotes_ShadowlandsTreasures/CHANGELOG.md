# Changelog

## Changed in v68

* Some cosmetic items were incorrectly saying they don't drop for the current character, so special-case cosmetics a bit

## Changed in v67

* New behavior: only show loot that should drop for the current character. Turn it off from the menu if you'd prefer.
* Better labels for loot, showing item types
* Item-sets shown in loot now show numeric completion ("3/7") rather than just whether they're complete
* Better fix for the C_TransmogCollection errors

## Changed in v66

* Updated for 9.2.5, fixing errors about C_TransmogCollection (in a rush, so there might be followup fixes)
* Always show loot info on vignettes, bypassing my normal "should I show this point?" check

## Changed in v65

* Venthyr Broken Mirrors are now shown (only the available three for the current day)
* Improve the amount of information shown in tooltips about reward items which aren't fully loaded yet

## Changed in v64

* Various quality of life improvements for points related to other points (hovering them will show a link to the related point)
* Show Apocopocolypse Now progress on coreless automa in Zereth Mortis
* Show Synthe-supersized! progress on the protoform points
* Add a missing vignette ID to the Protector of the First Ones
* A typo was stopping mount-completion from being shown on the Fallen Charger
* Stop always-showing the Sinrunners and Carriages in Revendreth; since flying has been available that's much less useful

## Changed in v63

* Added Explorer achievements, via a map icon that shows a spot that'll definitely get you the map completion for the achievement
* Improved paths to some points in several maps
* Zereth Mortis: some schematics were shown as available too soon (before you'd unlocked protoform synthesis)
* Group names in tooltips could sometimes be improperly formatted

## Changed in v62

* Show where some Automa Scraps are inside the Locrian Esper
* Changes to how routes are drawn, which should be completely unnoticed
* Bundle Taintless, which might(?) help with complaints about the upload dialog

## Changed in v61

* Show the Creation Catalyst on the Zereth Mortis map
* Minor Zereth Mortis note/point tweaks
* The last set of Lunarlight Buds was finally up in Ardenweald, so they're added with proper questids

## Changed in v60

* Add some new non-quest points to Zereth Mortis (hidden by default in the "Junk" group):
    * Shrouded Cypher Caches (a Soulshape and some Pocopoc loot)
    * Discarded Automa Scrap (Pocopoc cores)

## Changed in v59

* Pocopoc customization items are now available. The known ones in fixed locations have been added. (The ones that're in every random chest or on any rare, I've left out. Also, nobody knows where two of them are yet.)
* Dominance Key has been hotfixed to drop from more mobs
* A few Korthia improvements: include the really rare cache contents, and add some more vignettes

## Changed in v58

* Added the Mawsworn Supply Chest locations to Zereth Mortis because it (very rarely) contains the Spectral Mawrat's Tail
* Fill in various vignette IDs from earlier zones in the expansion, e.g. the daily calling treasures now have notable loot shown, as do the anima calling rares
* Spent perhaps too much time getting the Ardenweald Large Lunarlight Pod to have helpful nearby points on your minimap (I'm missing one set of options because it hasn't come up in the last few days so I can't narrow down which one ties to which quest...)

## Changed in v57

* Try to show point information on zone-map vignettes and POIs (this requires me to add the IDs for those to the points, so I need to gather more data before it's consistently available)
* Added the loot to Sand, Sand Everywhere! now I'm confident it's consistent
* ...Sand, Sand Everywhere! was accidentally being hidden by one of the Coreless Automa points
* Library Vault in ZM was hotfixed to require Dealic Understanding, apparently
* Cleaned up some points in Korthia
* Night Mare in Ardenweald's instructions were cut off by a typo
* Show the possible path for the Meandering Tale in Ardenweald

## Changed in v56

* Minor performance improvement: code checking whether you could learn an appearance from an item wasn't caching negative results and so was running more than it needed to
* You can hide all points related to an achievement from the right-click menu
* Cleaned up some duplication between point-groups and achievements
* Coreless Automa locations in Zereth Mortis (disabled by default, there's a lot)
* Missing Dormant Alcove Arrangement added, and explain the Requisites Originator it leads to
* Better explain the branching jumping puzzle routes for the Rondue Cache / Omnipotential Core schematic
* Show the Bulging Roots near Gluttonous Overgrowth, but only on your minimap
* Chicken Soul crittershape: position very slightly fixed
* Loyal Gorger and Dead Blancy: show progress like the newer mounts

## Changed in v55

* Add the locations of the Locus Alcove Arrangements for the optional rooms (Camber, Fulgore, Rondure, Dormant)
* Add a point for the Sand Sand Everywhere achievement
* Add a point for Olea Manu, the Jiro vendor after their questline, not at all because I'm bitter that I didn't notice them and so missed out on a week of +50% cyphers, no
* Add various soulshapes / crittershapes across the Shadowlands (mostly this is the 9.1.5 ones)
* Domination Cache: note that the key can also drop from the Dreadlord Infiltrators
* Give the Pulp-Covered Relic its own icon so it's easier to pick out

## Changed in v54

* Show which group a point is assigned to in its tooltip
* Made it easier for myself to add points that show the path to another point, and used that in a few places
* Minor tweaks to earlier zones: Nilganihmaht's tooltip shows which rings you've already put on; the Playful Vulpin's tooltip shows the emotes you'll have to use
* Removed the "show non-achievement" option, since it's been replaced with groups in-practice and I never flagged anything as junk this expansion (it made more sense back in Legion, which had a lot of boring non-achievement respawning treasures)

## Changed in v53

* Locus Shift treasures and schematics are filled out
* Tweaked the flying requirements on a few treasures
* Achieved-as-found fix went too far, interfered with quest completion sometimes (todo: rewrite this check more comprehensively...)

## Changed in v52

* Pull the point-groups in the current zone (groups and achievements) up to the top-level of the menu for easier access
* "Count achieved as found" should only apply to points with quests, as its description claimed
* Caches of Creation are not-visible by default
* Put the Pulp-Covered Relic in the Schematics group
* Note that one of the Crystallized Echo of the First Song locations requires flying
* Show the locus shift on the minimap as well

## Changed in v51

* Show the Crystallized Echo of the First Song locations
* Forgotten Proto-Vault: show as inactive if you don't have flying or the Frog'it WQ
* Prying Eye Discovery: show as inactive if you don't have flying or the Portal Play quest item
* Improve display if the tooltip's label is coming from the loot (remove the [] around it)
* Maw: add the pickup quest to the Soulforger's Tools on Rhovus

## Changed in v50

* Fix an error if collectables weren't counting for completion
* Explain Tahkwitz

## Changed in v49

* Add Protoform Synthesis pattern locations within the Sepulcher of the First Ones raid
* Maw: add the Infused Etherwyrm pet to the Night Fae assault

## Changed in v48

* Add Protoform Synthesis pet pattern locations (still missing: the ones in the raid)
* Minor tweaks to some points and notes

## Changed in v47

* Add Protoform Synthesis mount pattern locations (still to come: pet patterns)
* Add a point for the Locus Shift in the Gravid Repose

## Changed in v46

* Fixed an error when mousing over Anima Shards in Bastion

## Changed in v45

* The right-click menu on points now shows an option to open the Achievements UI to the related achievement
* Dune Dominance mobs: show individual status in the tooltip
* Add the Protoform Repository to the map once it's unlocked
* Hide the Architect's Reserve until the entire protoform chain is complete
* The Protopear only needs to be ripened once now
* Add other Moss-Choked Guardian spawns

## Changed in v44

* Dune Dominance mobs: more loot, show notes so you know which mob drops which items
* Ripened Protopear: show icon on the main map for the entrance to the Blooming Foundry
* Show spell tooltips on lore concordances and the wellspring so you know what buff you can get
* Minor tweaks to map icon sizes

## Changed in v43

* March 3rd hotfix: Interrogator's Vicious Dirk now drops from all the Dune Domination mobs
* Last lore concordance questids added
* Orixal has moved
* Assorted minor point tweaks

## Changed in v42

* A hotfix on March 1st put the Ancient Translocators on the Zereth Mortis map (*so* on the map that they're the only thing you can see if you've got no map-completion at all 😁), so I'm removing mine
* Added some notes to schematic loot drops indicating whether they're for a mount or a pet
* Remove an item from Hirukon that was incorrectly flagged as being a pet -- it's just an ingredient for a pet
* Prep-work for adding points for schematic-gathering, all hidden for now

## Changed in v41

* Explain the Syntactic Vault and add points for the runic syllables
* Utility points:
    * The Ancient Translocator to the Sepulchur
    * The Wellspring of the First Ones
* Changed the color of Glissandian caches to be more distinct
* More questids and note tweaks

## Changed in v40

* Pulled in more loot from Wowhead
* Now have the correct research levels for the lore concordances
* Show the Synthesis Forge on the map once you've unlocked it

## Changed in v39

* Show Completing the Code mobs on the minimap
* Show the transporter to the Antecedent Isle
* Show a point for Mai Toa on day 6 of the Patient Bufonid
* Show whether you've used the lure on Hirukon this week
* Explain the Provis Cache

## Changed in v38

* Various quest and loot updates for Zereth Mortis
* Show little dots for spawn points of the Lost Ovoids needed for the Mistaken Ovoid treasure
* Minor improvements to the appearance of item names in text and loot tooltips
* Points with multiple questids weren't displaying them correctly if you had that enabled

## Changed in v37

* A bunch of new loot on rares
* Better labeling on caches
* Split up the lore concordances

## Changed in v36

* This is the "I had to play a fresh character through Zereth Mortis with nothing unlocked yet" release
* Rewrote my "is this point active?" system so it's a lot easier for me to set complicated conditions
* Better flag conditions for Lore Concordances. (I'm not sure what the exact conditions are for some.)
* Hide the Completing the Code rares before you've done Firim's quests
* Hide the Patient Bufonid before it's available
* Show the puzzle caches on the minimap, and color them by type
* Added various questids, explained a few jumping routes, fixed some typos

## Changed in v35

* Updated for 9.2
* New data for Zereth Mortis
* Korthia: Xyraxz the Unknowable doesn't drop Gnashtooth after all
* Bastion: some Collector Astorestes loot is shared with the Relic Hoarder

## Changed in v34

* Added a new Maelie location in Korthia
* Fixed an issue for some people causing errors when viewing the map

## Changed in v33

* Added a lot of nodes to groups for easier hiding of clutter: Fractured Faerie Tales, Playful Vulpin, Shard Labor, Wardrobe Makeover, Harvester of Sorrow, Spectral Keys, Stolen Anima Vessels, Rift Hidden Caches, and various transportation hints

## Changed in v32

* Updated for 9.1.5 (no real API changes)
* New Maw teleporters added
* Cloudwalker's Coffer in Bastion was missing loot
* Mastercraft Gravewalker in Korthia got a mountid finally
* Explain how to get Tahonta in Maldraxxus
* Better-explain the Shimmermist Runner in Ardenweald
* Better hiding of the Cache of the Moon tools during various stages of that quest
* Improve the location for the Wild Worldcracker - show it at the end of Popo's patrol, not the beginning
* Improved display for Zovaal's vault

## Changed in v31

* Korthia: include Invasive Mawshrooms and Nests of Unusual Materials
* Maldraxxus: say whether the arena mount has been attempted today
* Listen to the CRITERIA_UPDATE event again, as it seems to no longer be spammed constantly, which should make things like the Spectral Key get removed from your minimap more promptly

## Changed in v30

* Maw Kyrian Assault: added the Sinfall Screecher pet
* A Sly Fox will now show on the minimap as well as the world map
* Xyraxz and Yarxhov will be labeled as such, rather than as the relics they're guarding
* Observer Yorik's quest id has been updated
* A new Maelie location has been added
* Maelie's progress will show better when you're at 6/6 and haven't turned in the quest to get the mount yet
* Removed the Glimmerfly Cocoon toy finally, it's definitely not dropping

## Changed in v29

* Maw Night Fae Assault: include the Jailer's Personal Stash achievement
* Maw Necrolord Assault: include the second Stolen Anima Vessel
* Better explanation in the tooltip for things which are hidden in the rift
* New feature: some points are in "groups", so you can now use the menu or right-clicking to hide all the points of that type. E.g. all the Korthia daily mounts, mawsworn chests, etc
* Missing Maw rares: Deomen the Vortex, Guard Orguluus
* Minor missing loot in Riftbound Caches

## Changed in v28

* You can now share a point to chat by shift-clicking a point or selecting it from the right-click menu (thanks, answering so many Maelie questions)
* Covenant-gated points will now show as inactive rather than hidden, as you can generally participate and get loot if a covenant-member triggers them
* Korthia now includes Mawsworn Caches
* A Sly Fox is shown during the Maw Kyrian assaults
* The Night Fae assault stolen anima vessels now have questids
* The Skittering Broodmother in the Maw has moved
* Added another Maelie location
* Added another spectral key location
* Missing Maw mob: Traitor Balthier
* Added some missing loot from the Inquisitors in Revendreth

## Changed in v27

* Added rares in Maw: Blinding Shadow, Fallen Charger
* Mine new loot; lots added to the Maw rares

## Changed in v26

* Nilganihmaht
    * Better explain the Domination chest
    * Show some of the quartered ancient ring pieces during the Necrolord assault
    * Flag Torglluun as being in the rift
* Show you how many razorwing eggs you've looted so far today (of the two you can get)

## Changed in v25

* Fix an error when trying to show loot for Ylava in the Maw (`C_Item.RequestLoadItemDataByID`)
* Add some missing loot, and a missing Helgarde Supply Cache

## Changed in v24

* Added to the Maw:
    * Nilganihmaht mount (apart from the necrolord assault bits)
    * Stolen Anima Vessels
    * Rift Hidden Caches
    * Zovaal's Vault
* Added Riftbound caches and Rift portals to Korthia
* Explain Consumption's mechanic so you can maybe actually get loot from it

## Changed in v23

* Notes for transporters and waystone in Korthia
* Add the new 9.1 treasures that're actually in the Maw
* Add the various mounts via daily actions in Korthia
* Improved ability to show progress in tooltips
* Add some missing items from the Blackhound Cache in Maldraxxus

## Changed in v22

* Updated for 9.1
* Korthia rares and treasures
* Maw got animaflow teleporter waypoints

## Changed in v21

* Updated for 9.0.5
* All the Blanchy steps now
* Many improvements to Bastion
* Much new loot pulled in from wowhead

## Changed in v20

* Add the inquisitors for It's Always Sinny In Revendreth
* Pull in datamined loot from [SilverDragon](https://www.curseforge.com/wow/addons/silver-dragon), because I might as well share data I've acquired with myself...
* Better type labels for items in tooltips
* Count transmog for completion purposes. This will only consider items for which your current character could learn the appearance
* Various improved descriptions
* Show where to get Handful of Oats for Blanchy in Westfall

## Changed in v19

* Support items with associated quests for completion purposes
* In tooltips, show a check/cross next to collectable items so it's easier to tell whether you've got them

## Changed in v18

* Maldraxxus: improve Sorrowbane description further; added some missing loot to Gieger
* Ardenweald: confirmed that Macabre doesn't require the dance-loop any more, updated notes
* "Path" nodes were sometimes not showing the correct icon

## Changed in v17

* Fix anchoring for tooltips on minimap icons
* Minor treasure updates in Maldraxxus and Bastion

## Changed in v16

* Add achievements:
    * Bat!
    * What We Ride In The Shadows
    * Wardrobe Makeover
* Properly explain acquiring Sorrowbane
* Show when loot is covenant-specific
* Fix Dead Blanchy's position, show where you are in the questline in its note
* Change how the tooltip anchors, so it's less likely to be in the way; there's an option for the old behavior if you prefer it

## Changed in v15

* Many Ardenweald improvements, but mostly to the Night Mare questline

## Changed in v14

* Routes on the map will highlight when you mouse over the relevant point
* The Maw now has a marker for the Waystone
* Bastion achievement What is that Melody? now included
* Various Bastion cleanups and some notes on Anima Shard locations
* Revendreth: explain the Forgotten Angler's Rod, since you may have to re-phase for it

## Changed in v13

* Can now show paths on the map; use this for the carriage routes in Revendreth and to link the teleporters in the Maw
* Some treasures don't count as "done" until you've used an item collected from them or completed a quest they start. These will now be hidden while you're carrying that item / are on that quest
    * I probably haven't flagged all of these ones yet
* Updates to Ardenweald's initial leveling portion
* Small updates to Maldraxxus
* Small updates to Revendreth
* Maw now has some lore nodes

## Changed in v12

* Add config to let achievement status override quest status. Enabling this will stop the daily rares from showing after you've killed them once.
* Add config to let account-knowable loot (mounts, toys, pets) which is known count as "found". This is enabled by default.

## Changed in v11

* Add a toggle so you can turn that world map button off if you don't want it
* Tweaked the default icon scale to be slightly smaller
* Improved Ardenweald, mostly so that icons for sub-objectives are easier to pick out from the main treasures
* More Maw loot has shown up

## Changed in v10

* Add a button to the world map for easy config access

## Changed in v9

* Better display for quests in tooltips
* Updated loot and notes for all zones

## Changed in v8

* Improved the data for Bastion and Maldraxxus
* Better display when treasures aren't currently available, though data is very incomplete as to which ones do (because it's difficult to tell without visiting them all... and it might turn out to *really* be "are you in any covenant?" and I need 
to get a leveling character to the right point to test this)
    * By default unavailable mobs/treasures will still show up, but tinted red. If this is very annoying, there's a setting for it in the options

## Changed in v7

* Add Chaotic Riftstones to the Maw
* Fix check that was stopping collected jellycats from being hidden before you'd completed the entire Nine Afterlives achievement

## Changed in v6

* Add achievement: Nine Afterlives (the jellycats)
* Flag Bastion Abandoned Stockpile as being max-level, and highlight its entrance.
* Fix the Larion Tamer's Harness location and loot
* Explain the Corrupted Clawguard better
* Make path-to-treasure nodes display on the minimap automatically
* Cache loot when opening the zone map, so there's less "loading..."
* Change the default point icon to the blizzard default chest vignette icon (which looks way better than it did in the last expansion)
* Add some config for setting a default icon, if you'd prefer something different

## Changed in v5

* Update loot and some spawn locations

## Changed in v4

* Fix an error in the Maw if you were using item icons
* Basilofos seems to not have that toy now we're out of beta
* Change some mount drops in Maldraxxus

## Changed in v3

* Rares for all zones
* Add config for hiding specific achievements
* Fix the check that should have been hiding the Anima Shards in Bastion before you're 60

## Changed in v2

* Filled out questids for per-character completion
* A lot more information about Blanchy
* The Shard Labor achievement in Bastion

## Changed in v1

* Created with the achievement-related treasures
