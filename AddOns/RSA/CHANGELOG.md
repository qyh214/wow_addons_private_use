# RSA r524-Release
### Changed
* Support for custom channels has been removed. Blizzard made a change to the SendChatMessage API for **classic** to limit the usefulness of [ClassicLFG](https://www.curseforge.com/wow/addons/classiclfg). Apparently they liked the change so much that they put it into 8.2.5 as well. Completely unannounced! Don't you just love how Blizzard promise to improve communication every six months only to then proceed in not communicating at all.
* As an addition, Say and Yell also only function inside instances now. Even if checked, RSA will not attempt to announce to these channels unless you are in an instance.

### Fixed
* Blessing of Freedom PvP talent Unbound Freedom now works with the Blessing of Freedom announcement.