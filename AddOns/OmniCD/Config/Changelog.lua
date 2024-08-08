local E, L, C = select(2, ...):unpack()

if E.isClassic then E.changelog = [=[
v1.15.3.2802
	bump toc
	Interrupt Bar can now be sorted by spell priority.
	NameBar nil err fix.
	Fixed multicharged spell opacity when it still has a charge left.
	zhTW localization update.

v1.15.2.2800
	RaidCD/Spell option revamped.
	Queued inspections while in combat will be processed upon leaving combat. (doesn't affect synced units)

]=]
elseif E.isBCC then E.changelog = [=[
v2.5.4.2722
	Fixed sync for cross realm group members

]=]
elseif E.isWOTLKC then E.changelog = [=[
v3.4.3.2773
	Added season 8 Wrathful Gladiator's set bonuses
	Fixed incorrect sorting when a unit dies or resurrects on ver.2772
	Added option to change icon texture for 'Trinket, Main Hand, Consumables' spell type.

]=]
elseif E.isCata then E.changelog = [=[
v4.4.0.2802
	Interrupt Bar can now be sorted by spell priority.
	NameBar nil err fix.
	Fixed multicharged spell opacity when it still has a charge left.
	zhTW localization update.

v4.4.0.2800
	RaidCD/Spell option revamped.
	Fixed Scatter Shot (Hunter) as a base ability.
	Fixed Word of Glory showing for Holy Paladin (no CD).
	Fixed Combat readiness and Cloak of Shadow CD sharing.
	Fixed Outbreak CD for Blood spec.
	Glyphs will correctly update when switching talents.
	Queued inspections while in combat will be processed upon leaving combat. (doesn't affect synced units)

]=]
else E.changelog = [=[
v10.2.7.2802
	Interrupt Bar can now be sorted by spell priority.
	NameBar nil err fix.
	Fixed multicharged spell opacity when it still has a charge left.
	zhTW localization update.

v10.2.7.2801
	Raidframe icons can be sorted primarily by spelltype or spell priority.
	Breath of Eons will correctly replace Deep Breath.
	Frame option fixed and spelltype selector added back in ExtraBars. Use whichever is more convenient for you.

v10.2.7.2800
	- Updates
	11.0 TWW compatibility updates.
	RaidCD/Spell option revamped. (ExtraBar settings will reset)
	Priority and Frame# can be set for each spell and/or batch processed by spelltype.
	New option to redirect spells from disabled extrabars to raidframes.
	New option to add border glow.
	Custom on-use items are no longer limited to trinkets and mainhand.
	Default profile updated with new settings.
	Edited default spells will be cleared from your db.
	Old profile strings are no longer compatible.
	- Spells
	Healthstone and Demonic Gateway can be tracked on all group members (added on cast).
	Healthstone will sync in arena and party dungeons (start time may be off w/o sync).
	Added Avenging Wrath (Holy, Paladin) as a separate Heal.
	Added Blind (w/ Airborne Irritant) as a separate AOE CC.
	Added Deep Breath (w/ Terror of the Skies) as a separate AOE CC.
	Added Naturalize as a separate Dispel (was merged with Expunge).
	Added Immolation Aura (w/ Cleansed by Flame) as a separate Dispel.
	Added Thunderstorm w/ Thundershock as a separate Knockback.
	Updated Voice of Harmony CDR to 1 sec per talent point (was 2 sec) - June 5, 2024 Hotfix.
	Exhilaration for Survival Hunter added to sync. (4pc set bonus RNG)
	- Bug Fixes
	Queued inspections while in combat will be processed upon leaving combat. (doesn't affect synced units)
	Fixed timer nil error.
	Fixed incorrect empowered spellIDs.
	Fixed Blinding Powder CDR.
	Fixed Weyrnstone not showing when player is disabled.
	Fixed Searing Glare's icon texture.
	Fixed Incarnation: Tree of Life highlighting.
	Fixed interrupted spell icon showing on other bars.
	Fixed multicharged spells being sorted as active when it still has a charge left.

]=]
end

E.changelog = E.changelog .. "\n\n|cff808080Full list of changes can be found in the CHANGELOG file"
