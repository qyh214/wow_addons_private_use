# RSA 5.11.0
## Evoker
* Added Naturalize to Expunge announcement.

## Paladin
* Added Turn Evil (Dragonflight & Wrath)
* Fixed an issue with Blessing of Summer incorrectly announcing Blessing of Autumn.

# RSA 5.10.0
## Evoker
* Added Mass Return
* Added Dream Flight
* Dream Breath should function correctly now
## Mage
* Added Ice Block (Dragonflight & Wrath)
## Paladin
* Added Blessing of the Seasons
## Known Issues
* Per Spell environment settings are currently not functioning, despite the options showing in game.
* UNIT_DIED events are not currently tracked.
* Various announcements that existed in the prior release of RSA are not currently implemented. Examples such as Misdirection and Tricks of the Trade being able to announce how much threat they transferred.
* Utility spells such as Cauldrons are not currently implemented, but will be returning shortly. The Utility options panel is supposed to be blank right now.
# RSA 5.9.2
* Fixed a bug preventing proper randomisation of multiple messages
* Fixed a bug when updating default spell data from a prior version (If you play a Rogue and changed setting related to Sap, this should fix RSA being broken in versions past 5.7.0)
* Added clarification on per-spell Environment settings clarifying that they are not currently functional yet.

### Priest
* Power Infusion with Twins of the Sun Priestess should now only announce once per event (In the future there will be more granular options to specify if it will only announce on targets and not yourself)