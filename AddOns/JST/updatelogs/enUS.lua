local T, C, L, G = unpack(select(2, ...))

--if G.Client ~= "zhTW" then return end

L["更新日志内容"]			= [[
6.24
Update version tag.

6.23
Dimensius Crushing Gravity/Inverse Gravity assignment index bug fix.

6.22
Salhadaar Subjugation Rule soak prompt bug fix.
Add CC Spells: Disrupting Shout and Implosive Trap.

6.21
Salhadaar Subjugation Rule soak prompt bug fix.

6.20
Salhadaar Count the number of Vengeful Oath missed.
Salhadaar Subjugation Rule supports the tactic of 'Sock 1st Conquer'.(You need to click on the small gear button and manually turn it on in the detailed settings)
Dimensius Voidgrasp raid frame glow bug fix(H).
Streets of Wonder Myza's Oasis add notes countdown.

6.18
Dimensius Big/small circles assignment Phase 3 add "Pull against" or "Don't move" prompts.

6.17
Dimensius Big/small circles assignment adds option Phase 2 assignments rotate 90 degrees counterclockwise.
Dimensius Big/small circles assignment Update Phase 3 map.

6.15
Salhadaar added Banishment timing circle.
Dimensius Reverse Gravity arrangement prioritizes healers in the front row.
Dimensius Excess Mass assignment bug fix.
Text Alert (General) Font Size Correction.

6.13
Dimensius Excess Mass assignment bug fix.
Dimensius The Airborne quantity is only displayed when player has Excess Mass.
Other error corrections.

6.10
Halls of Atonement Echelon Stonefiend quantity monitor bug fix.
The Dawnbreaker Nightfall Tactician removes the Black Edge dispeling sound prompt.
The Dawnbreaker adds Nightfall Darkcaster control data and removes Sureki Webmage control data.
Delete the fear control data for Undead and Mechanical monsters.
The CC Spells options add related spell tooltips.

6.09
Halls of Atonement Aleez added Unstable Anima dispel text prompt.
New Feature: Raid leaders can modify the nicknames of team members(Requires member version 6.09 or above).

6.07
Halls of Atonement Echelon add Stonefiend quantity monitor.
Halls of Atonement Aleez added Vessle countdown text and appearance reminders,
Halls of Atonement Depraved Collector added interrupt timing bar and nameplate number for Siphon Life.
So'leah's Gambit Hylbrande added Purifying Burst timing bar and sound prompt.
Other error corrections.

6.06
CC spell monitor:Add Mythic+ CC monitor and auto assignment.
Other error corrections.

6.04
Salhadaar Subdivision Rule timing bar bug fix.

6.03
Plexus Sentinel Protocol: Purge timing bar add sound prompt.
Dimensius Excess Mass assignment bug fix.
Operation: Floodgate the Demolition Duo add countdown text for Big Bada Boom.
Added recommendation settings function: Most options in the GUI can be sent to teammates using shift + left button.
Timeline prompt fixed bug with glowing raid frames.
Other error corrections.

6.01
Salhadaar Subdivision Rule changed to soak conquer 1 or 3, and do not soak other conquers.

6.00
Dimensius Crushing Gravity/Inverse Gravity assignment.
Salhadaar Subdivision Rule timing bar glow border bug fix.

5.99
Dimensius Reverse Gravity assignment.
Fractillus Tank wall spawn assignment bug fix.

5.97
Forgeweaver Araz Arcane Collector HP comparison nameplate mark.
Forgeweaver Araz Arcane Convergence Add timing bars and self-protection spell prompts.
Salhadaar Netherbreaker Add sound prompts.
Dimensius Living Mass auto-mark.
Dimensius Living Mass HP comparison nameplate mark.
Dimensius Soaring Reshii countdown text.
Dimensius Devour(P3) raid mark assignment (say spawn).
Other error corrections.

5.95
Fractillus Add a countdown text for the tank wall, displayed 10 seconds in advance. (The original assignment text is retained and will only be displayed when the boss starts casting Shockwave Slam.)
Dimensius Devour effective countdown.
Dimensius Living Mass HP monitor.
Dimensius Airborne Rescue player quantity monitoring.
Dimensius Stellar Core group debuff monitoring.
Dimensius Starrard Nova soaking MRT assignment. 
Dimensius Supernova timing bar adds sound effects.
Other error corrections.

5.94
Salhadaar Starkiller assign bug fix
The Dawnbreaker Manifested Shadow correct Black Hail target determination errors.
Eco-Dome Al'dani Azhiccar Toxic Regurgitation add drop pool sound.
Organize the control/interruption timing bar data of Mythic+ and separate it from other timing bars in the same group.
Organize the tank timing bar of the Mythic+.
Organize self-protection prompt of the Mythic+.
The self-protection prompt can now display a preview effect and select the direction of icon arrangement.
The self-protection prompt will now monitor activated group cooldown buffs.
The self-protection prompt now correctly prompts for the heal potion cooldown.
The sound effects of the self-protection prompt should be spaced at least 10 seconds apart.
Delete some Mythic+ trash spell countdown. (Abyssal Rot/Abysal Blast/Gluttonous Miasma)
Cancel Evoker's reminder to dispel Enrage.
Other error corrections.

5.92
Fractillus spawn/break wall assignment display the direction and distance of the assigned location.
Fractillus spawn/break wall assignment group status display allocation position.
Salhadaar When soak the Conquer, indicate danger when debuffed with Banishment.
Salhadaar Twilight Massacre adds a timing circle for casting on me.
Salhadaar Netherbreaker adds mythic difficulty countdown and timing bar.
Salhadaar Besiege delete timing bar.
Salhadaar Dimension Breath adds mythic difficulty timing bar.
Salhadaar Behead adds timing bar in Intermission Two: King's Hunger.
Dimensius Remake Dark Matter timing circle.
Dimensius Soaring Reshii adds a aura icon.
Dimensius Gamma Burst adds a timing circle.
Dimensius Crushing Gravity/Inverse Gravity adds timing circles.
Streets of Wonder Zo'phex the Sentinel Interrogation timing bar adds immune spell monitoring.
Streets of Wonder Mailroom Mayhem Money Order timing bar adds immune spell monitoring.
Streets of Wonder Force Multiplier delete nameplate interrupt icon, changed to timing bar.
Operation: Floodgate Big M.O.M.M.A. adds a nameplate glow and spell icon for Maximum Distortion.
Operation: Floodgate Big M.O.M.M.A. delete Maximum Distortion nameplate interrupt number, changed to timing bar, prompt the bar when your interrupt spell is ready to use.
Ara-Kara, City of Echoes adds a nameplate glow and spell icon for Alarm Shrill.
Ara-Kara, City of Echoes Add self-protection spell prompt for several spells.
Eco-Dome Al'dani Soul-Scribe delete Whispers of Fate countdown.
Eco-Dome Al'dani Soul-Scribe add a sound prompt for Fatebound spirit soak.
Eco-Dome Al'dani add a sound prompt for Unstable Core.
Eco-Dome Al'dani Add dark filters to Al'dani Sands.
Eco-Dome Al'dani Add self-protection spell prompt for several spells.
Other error corrections.

5.90
Forgeweaver Araz Arcane Collector mark error correction.
The Soul Hunters the Hunt damage soak assignment.
The Soul Hunters delete the Hunt timing bar sound prompt.
The Soul Hunters intermission position assignment options moved to Soul Tether column.
Priory of the Sacred Flame Taener Duelmal add Fireball nameplate interrupt prompt in boss fight. 
Priory of the Sacred Flame Forge Master Damian Heat Wave countdown text prompt bug fix.
Eco-Dome Al'dani Ravenous Destroyer Volatile Ejection target correction.
Eco-Dome Al'dani Ravenous Destroyer add Gluttonous Miasma casting on me icon prompt.
Other error corrections.
]]