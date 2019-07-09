LibResInfo-1.0
=================

LibResInfo detects resurrection spell casts and identifies who they are being cast on, and provides that information to addons through callbacks and API methods. It supports both single and mass resurrections, as well as soulstones. It is fully embeddable, completely locale-independent, and does not require any other players in your group to have anything installed.

Requires [LibStub](https://www.wowace.com/addons/libstub/) and [CallbackHandler-1.0](https://www.wowace.com/addons/callbackhandler/).

* [Download on CurseForge](https://wow.curseforge.com/addons/libresinfo/)
* [Download on WoWInterface](https://www.wowinterface.com/downloads/info21467-LibResInfo-1.0.html)


## API Documentation

* [API methods](https://github.com/Phanx/LibResInfo/wiki/API-Methods)
* [Callbacks](https://github.com/Phanx/LibResInfo/wiki/Callbacks)


## Additional Notes

Support for Reincarnation is under consideration, but would require some guesswork, since until you actually see a shaman resurrect themselves, there's no way to tell if the ability is on cooldown or not.

No callbacks are fired for players who die while a mass res is being cast, but the API will return correct information (that the player has an incoming res) so if it important for your addon, just check the player's status when they die.

No callbacks are fired for players who resurrect themselves by returning to their corpse while a mass res is the only res casting on them, but the API will (again) return correct information (that the player has no incoming res) so if it important for your addon, just check the player's status when they resurrect.


## Limitations

Due to limitations of the WoW API, it is **not possible** to detect:

* ...when someone declines a resurrection manually by clicking "Decline" on the dialog box.
* ...when someone has a wait time before they can accept a resurrection. In this case, the 60-second expiration time will be extended by the amount of time they are forced to wait, but the ResExpired callback will be fired at the 60-second mark since there's no way for LRI to know about the wait time.
* ...who a player who joins the group while casting a resurrection spell is targeting.
* ...whether a player who joins the group while dead has a resurrection being cast on them.
* ...whether a player who joins the group while dead has a resurrection already available.


## License

LibResInfo-1.0 is released under the zlib License.
