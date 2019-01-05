### v1.2.7
- Fixed an issue that was causing the add-on to be broken after updating the client to build 28822
- Added korean translation, thanks to ??28485

### v.1.2.6
- Attempt to implement new world bosses

### v1.2.5
- Changed add-on name to be more user-friendly

### v1.2.4
- Updated for patch 8.1
- New README, thanks to Willexan

### v1.2.3
- Warfront boss should no longer be flagged as killed if your faction doesn't have access to it

### v1.2.2
- Fixed a crash caused by the missing The Eye of Eternity raid in ``instancesData``
- Azeroth's World Bosses availability should now be fixed

### v1.2.1
- Fixed instances ``instanceID`` match with EJ

### v1.2.0
- Reworked the addon so frames will now be matched with EJ tiles according to its ``instanceID`` attribute instead of ``tooltipTitle``, so no more locale dependant!
- Azeroth's World Bosses lockout tooltip will now display the unavailable status of inactive bosses, as well as the status of the Warfront boss
- Changed Uldir lockout bosses name according to Encounter Journal
- Fixed an issue with flags displaying wrong difficulty in some cases
- Fixed an issue with flags displaying wrong world bosses count in some cases
- Added local reference for used functions to speed up things

### v.1.1.9
- Encounter Journal should now properly display current instance if you're inside

### v1.1.8
- Various improvements code-side
- Instance progress frames should now be updated by switching tab as intended, no more ``/reload`` needed

### v1.1.7
- Updated strings to use globals instead
- Added italian locale, thanks to z0fa

### v1.1.6
- Fixed King's Rest for german clients

### v1.1.5
- Fixed a major issue with locales wrongly creating a new table instead of replacing its values

### v1.1.4
- Fixed some BfA dungeons for deDE locale
- Added license

### v1.1.3
- Fixed wrong tooltip after previous fix

### v1.1.2
- Fixed wrong boss count for Siege of Boralus

### v1.1.1
- Fixed The Underrot for french clients

### v1.1.0
- Added zhTW locale, thanks to BNSSNB
- Fixed Deadmines for french clients

### v1.0.9
- Minor code changes

### v1.0.8
- Added Azurethos to BfA World Bosses

### v1.0.7
- Fixed Violet Hold for english clients

### v1.0.6
- Fixed all dungeons of The Burning Crusade

### v1.0.5
- Fixed wrong loop

### v1.0.4
- Updated for Battle for Azeroth
- Tooltips are now sorted according to encounters
- Cleaned up code
- Initial release

### v1.0.3
- Fixed Black Temple tracking for french clients
- Fixed AQ40 tracking for english clients

### v1.0.2
- Fixed Black Temple tracking

### v1.0.1
- Fixed some Worldbosses typos

### v1.0.0
- Initial fork commit
- Fixed Sunwell, SSC and Tempest Keep tracking
- Added LFR tracking
- Added Worldbosses tracking
- Removed the timer of lockouts weekly reset
- New display for tooltips
