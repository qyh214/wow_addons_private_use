local L = BigWigs:NewBossLocale("Lord Marrowgar", "frFR")
if not L then return end
if L then
	L.bone_spike = "Pointe d'os" -- NPC ID 36619
end

L = BigWigs:NewBossLocale("Lady Deathwhisper", "frFR")
if L then
	L.touch = "Toucher"
	L.deformed_fanatic = "Fanatique déformé" -- NPC ID 38135
	L.empowered_adherent = "Adhérent investi" -- NPC ID 38136
end

L = BigWigs:NewBossLocale("Icecrown Gunship Battle", "frFR")
if L then
	L.adds_trigger_alliance = "Saccageurs, sergents, à l'attaque !"
	L.adds_trigger_horde = "Soldats, sergents, à l'attaque !"

	L.mage = "Mage"
	L.mage_desc = "Prévient quand un mage apparaît pour congeler vos canons."
	-- Alliance: We're taking hull damage, get a battle-mage out here to shut down those cannons!
	-- Horde: We're taking hull damage, get a sorcerer out here to shut down those cannons!
	--L.mage_yell_trigger = "taking hull damage"

	L.warmup_trigger_alliance = "Faites chauffer les moteurs"
	L.warmup_trigger_horde = "Levez%-vous, fils et filles"

	L.disable_trigger_alliance = "Mes frères et sœurs, en avant"
	L.disable_trigger_horde = "Sus au roi%-liche"
end

L = BigWigs:NewBossLocale("Deathbringer Saurfang", "frFR")
if L then
	L.blood_beast = "Bête de sang" --  NPC ID 38508

	L.warmup_alliance = "Bon allez, on se bouge ! En route -"
	L.warmup_horde = "Kor'krons, en route ! Champions, surveillez bien vos arrières. Le Fléau a été -"
end

L = BigWigs:NewBossLocale("Blood Prince Council", "frFR")
if L then
	L.switch_message = "Nouvelle cible : %s"
	L.switch_bar = "~Prochain chgt de cible"

	L.empowered_flames = "L'Embrasement surpuissant"

	L.empowered_shock_message = "Vortex de choc surpuissant en incantation !"
	L.regular_shock_message = "Vortex de choc"
	L.shock_bar = "~Prochain Vortex"

	L.iconprince = "Crâne sur le prince surpuissant"
	L.iconprince_desc = "Place l'icône de raid principale sur le prince de sang actuellement surpuissant (nécessite d'être assistant ou mieux)."

	L.prison_message = "Prison de l'ombre x%d !"
end

L = BigWigs:NewBossLocale("Festergut", "frFR")
if L then
	L.engage_trigger = "On joue ?"

	L.inhale_bar = "Inhalation %d"
	L.blight_warning = "Chancre âcre dans ~5 sec. !"
	L.ball_message = "Arrivée d'une Gelée malléable !"
end

L = BigWigs:NewBossLocale("Blood-Queen Lana'thel", "frFR")
if L then
	L.engage_trigger = "Ce n'est pas une décision... très sage." -- à vérifier

	L.shadow = "Les ombres"
	L.shadow_message = "Ombres"
	L.shadow_bar = "Prochaines Ombres"

	L.feed_message = "Besoin de se nourrir imminent !"

	L.pact_message = "Pacte"
	L.pact_bar = "Prochain Pacte"

	L.phase_message = "Arrivée d'une phase aérienne !"
	L.phase1_bar = "Retour sur le sol"
	L.phase2_bar = "Phase aérienne"
end

L = BigWigs:NewBossLocale("The Lich King", "frFR")
if L then
	L.warmup_trigger = "Voici donc qu’arrive la fameuse justice de la Lumière ?"
	L.engage_trigger = "Je vais te laisser en vie, que tu sois témoin de la fin, Fordring."

	L.horror_message = "Horreur titubante"
	L.horror_bar = "~Prochaine Horreur"

	L.valkyr_message = "Val'kyr(s)"
	L.valkyr_bar = "Prochaine(s) val'kyr(s)"
	L.valkyrhug_message = "Étreinte val'kyrienne"

	L.cave_phase = "Phase Deuillegivre"
	L.last_phase_bar = "Dernière phase"

	L.frenzy_bar = "%s s'enrage !"
	L.frenzy_survive_message = "%s survivra après la Peste"
	L.frenzy_message = "Horreur enragée !"
	L.frenzy_soon_message = "5 sec. avant Enrager !"

	--L.custom_on_valkyr_marker = "Val'kyr marker"
	--L.custom_on_valkyr_marker_desc = "Mark the Val'kyr with {rt8}{rt7}{rt6}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r\n|cFFADFF2FTIP: If the raid has chosen you to turn this on, quickly mousing over the Val'kyr is the fastest way to mark them.|r"
end

L = BigWigs:NewBossLocale("Professor Putricide", "frFR")
if L then
	L.engage_trigger = "Grande nouvelle, mes amis ! Je crois que j'ai mis au point une peste qui va détruire toute vie sur Azeroth !"

	L.phase = "Phases"
	L.phase_desc = "Prévient quand la rencontre change de phase."
	L.phase_warning = "Phase %d imminente !"
	L.phase_bar = "Prochaine phase"

	L.ball_bar = "Prochaine Gelée malléable"
	L.ball_say = "Gelée malléable moi !"

	L.experiment_message = "Arrivée d'une nouvelle expérience !"
	L.experiment_heroic_message = "Arrivée de nouvelles expériences !"
	L.experiment_bar = "Prochaine expérience"
	L.blight_message = "Nuage de gaz"
	L.violation_message = "Limon volatil"

	L.gasbomb_bar = "D'autres Bombes de gaz !"
	L.gasbomb_message = "Bombes de gaz !"
end

L = BigWigs:NewBossLocale("Rotface", "frFR")
if L then
	L.engage_trigger = "Wiiiiiiiiiii !"

	L.infection_message = "Infection"

	L.ooze = "Fusion de limons"
	L.ooze_desc = "Prévient quand un limon fusionne avec un autre."
	L.ooze_message = "Limon %dx"

	L.spray_bar = "Prochaine Projection"
end

L = BigWigs:NewBossLocale("Sindragosa", "frFR")
if L then
	L.engage_trigger = "Qu'il est stupide d'être venus ici."

	L.phase2 = "Phase 2"
	L.phase2_desc = "Prévient quand la rencontre passe en phase 2 à 35%."
	L.phase2_trigger = "Sentez maintenant le pouvoir infini de mon maître, et désespérez !"
	L.phase2_message = "Phase 2 !"

	L.airphase = "Phase aérienne"
	L.airphase_desc = "Prévient quand Sindragosas décolle."
	L.airphase_trigger = "Votre incursion s'arrête ici ! Personne n'en réchappera !"
	L.airphase_message = "Phase aérienne !"
	L.airphase_bar = "Prochaine phase aérienne"

	L.boom_message = "Explosion !"
	L.boom_bar = "Explosion"

	L.instability_message = "Magie débridée x%d !"
	L.chilled_message = "Transi jusqu'aux os x%d !"
	L.buffet_message = "Rafale mystique x%d !"
	L.buffet_cd = "Prochaine Rafale mystique"
end

L = BigWigs:NewBossLocale("Valithria Dreamwalker", "frFR")
if L then
	L.engage_trigger = "Des intrus se sont introduits dans le sanctuaire. Hâtez-vous d'achever le dragon vert ! Ne gardez que les os et les tendons, pour la réanimation !"

	L.portal = "Portails du Cauchemar"
	L.portal_desc = "Prévient quand Valithria ouvre des portails."
	L.portal_message = "Portails actifs !"
	L.portal_bar = "Arrivée des portails"
	L.portalcd_message = "Portails %d ouverts dans 14 sec. !"
	L.portalcd_bar = "Prochains portails %d"
	L.portal_trigger = "J'ai ouvert un portail vers le Rêve. Vous y trouverez votre salut, héros…"

	L.suppresser = "Apparition de Suppresseurs"
	L.suppresser_desc = "Prévient quand une meute de Suppresseurs apparaît."
	L.suppresser_message = "~Suppresseurs"

	L.blazing = "Squelette flamboyant"
	L.blazing_desc = "Délai de réapparition |cffff0000estimé|r des Squelettes flamboyants. Ce délai est sans doute imprécis, utilisez-le donc comme un repère."
	L.blazing_warning = "Squelette flamboyant imminent !"
end

L = BigWigs:NewBossLocale("Icecrown Citadel Trash", "frFR")
if L then
	L.deathbound_ward = "Gardien lié par la mort"
	L.deathspeaker_high_priest = "Grand prêtre nécrorateur" -- NPC ID 36829
	L.putricide_dogs = "Bijou & Kifouette"
end
