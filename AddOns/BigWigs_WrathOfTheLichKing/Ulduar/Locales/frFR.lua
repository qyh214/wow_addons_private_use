local L = BigWigs:NewBossLocale("Auriaya", "frFR")
if not L then return end
if L then
	L.swarm_message = "Essaim gardien"

	L.defender = "Défenseur farouche"
	L.defender_desc = "Prévient quand le Défenseur farouche apparaît et quand il perd une vie."
	L.defender_message = "Défenseur actif %d/9 !"
end

L = BigWigs:NewBossLocale("Freya", "frFR")
if L then
	L.wave = "Vagues"
	L.wave_desc = "Prévient de l'arrivée des vagues."
	L.wave_bar = "Prochaine vague"
	L.conservator_trigger = "Eonar, ta servante a besoin d'aide !"
	L.detonate_trigger = "La nuée des éléments va vous submerger !"
	L.elementals_trigger = "Mes enfants, venez m'aider !"
	L.tree_trigger = "Un |cFF00FFFFdon de la Lieuse-de-vie|r commence à pousser !"
	L.conservator_message = "Ancien conservateur !"
	L.detonate_message = "Flagellants explosifs !"
	L.elementals_message = "Élémentaires !"

	L.tree = "Cadeau d'Eonar"
	L.tree_desc = "Prévient quand Freya fait apparaître un Cadeau d'Eonar."
	L.tree_message = "Un arbre pousse !"

	L.fury_message = "Fureur de la nature"

	L.tremor_warning = "Tremblement de terre imminent !"
	L.tremor_bar = "~Prochain Tremblement"
	L.energy_message = "Energie instable sur VOUS !"
	L.sunbeam_message = "Rayons de soleil actif !"
	L.sunbeam_bar = "~Prochains Rayons de soleil"
end

L = BigWigs:NewBossLocale("Hodir", "frFR")
if L then
	L.hardmode = "Jouons à casse-cache"
	L.hardmode_desc = "Affiche le délai avant qu'Hodir ne détruise sa cache rare."
end

L = BigWigs:NewBossLocale("Ignis the Furnace Master", "frFR")
if L then
	L.brittle_message = "Un Assemblage est devenu Fragile !"
end

L = BigWigs:NewBossLocale("The Iron Council", "frFR")
if L then
	L.stormcaller_brundir = "Mande-foudre Brundir"
	L.steelbreaker = "Brise-acier"
	L.runemaster_molgeim = "Maître des runes Molgeim"

	L.summoning_message = "Arrivée des élémentaires !"

	L.chased_other = "%s est poursuivi(e) !"
	L.chased_you = "VOUS êtes poursuivi(e) !"
end

L = BigWigs:NewBossLocale("Kologarn", "frFR")
if L then
	L.arm = "Destruction des bras"
	L.arm_desc = "Prévient quand le bras gauche et/ou droit est détruit."
	L.left_dies = "Bras gauche détruit"
	L.right_dies = "Bras droit détruit"
	L.left_wipe_bar = "Repousse bras gauche"
	L.right_wipe_bar = "Repousse bras droit"

	L.eyebeam = "Rayon de l'oeil"
	L.eyebeam_desc = "Prévient quand un Rayon de l'oeil focalisé est incanté."
end

L = BigWigs:NewBossLocale("Mimiron", "frFR")
if L then
	L.phase = "Phases"
	L.phase_desc = "Prévient quand la rencontre change de phase."
	L.engage_warning = "Phase 1"
	L.engage_trigger = "^Nous n'avons pas beaucoup de temps, les amis !"
	L.phase2_warning = "Arrivée de la phase 2"
	L.phase2_trigger = "^MERVEILLEUX ! Résultats parfaitement formidables !"
	L.phase3_warning = "Arrivée de la phase 3"
	L.phase3_trigger = "^Merci, les amis !"
	L.phase4_warning = "Arrivée de la phase 4"
	L.phase4_trigger = "^Fin de la phase d'essais préliminaires"
	L.phase_bar = "Phase %d"

	L.hardmode_trigger = "^Mais, pourquoi"

	L.plasma_warning = "Plasma en incantation !"
	L.plasma_soon = "Explosion de plasma imminente !"
	L.plasma_bar = "Plasma"

	L.shock_next = "Prochain Horion"

	L.laser_soon = "Accélération !"
	L.laser_bar = "Barrage"

	L.magnetic_message = "UCA au sol !"

	L.suppressant_warning = "Arrivée d'un Coupe-flamme !"

	L.fbomb_bar = "Prochaine Bombe de givre"

	L.bomb_message = "Robo-bombe apparu !"
end

L = BigWigs:NewBossLocale("Razorscale", "frFR")
if L then
	L.ground_trigger = "Faites vite ! Elle va pas rester au sol très longtemps !"
	L.ground_message = "Tranchécaille enchaînée !"
	L.air_message = "Décollage !"

	L.harpoon = "Tourelle à harpon"
	L.harpoon_desc = "Prévient quand une tourelle à harpon est prête."
	L.harpoon_message = "Tourelle à harpon %d prête !"
	L.harpoon_trigger = "Tourelle à harpon prête à l'action !"
	L.harpoon_nextbar = "Tourelle %d"
end

L = BigWigs:NewBossLocale("Thorim", "frFR")
if L then
	L.phase2_trigger = "Des intrus ! Mortels, vous qui osez me déranger en plein divertissement allez pay - Attendez, vous -"
	L.phase3_trigger = "Avortons impertinents, vous osez me défier sur mon piédestal ? Je vais vous écraser moi-même !"

	L.hardmode = "Sifonné"
	L.hardmode_desc = "Affiche le délai avant que Sif ne disparaisse."
	L.hardmode_warning = "Sif a disparue"

	L.barrier_message = "Barrière runique actif !"

	L.charge_message = "Charge de foudre x%d !"
	L.charge_bar = "Charge %d"
end

L = BigWigs:NewBossLocale("General Vezax", "frFR")
if L then
	L.surge_bar = "Vague %d"

	L.animus = "Animus de saronite"
	L.animus_desc = "Prévient quand l'Animus de saronite apparaît."
	L.animus_trigger = "Les vapeurs saronitiques s'amassent et tourbillonnent violemment pour former un amas monstrueux !"
	L.animus_message = "Animus apparu !"

	L.vapor = "Vapeurs de saronite"
	L.vapor_desc = "Prévient quand des Vapeurs de saronite apparaissent."
	L.vapor_message = "Vapeurs de saronite %d !"
	L.vapor_bar = "Vapeurs"
	L.vapor_trigger = "Un nuage de vapeurs saronitiques se forme non loin !"

	L.vaporstack = "Cumul des Vapeurs"
	L.vaporstack_desc = "Prévient quand vous avez 5 cumuls ou plus de Vapeurs de saronite."
	L.vaporstack_message = "Vapeurs de saronite x%d !"

	L.crash_say = "Déferlante d'ombre"

	L.mark_message = "Marque"
end

L = BigWigs:NewBossLocale("XT-002 Deconstructor", "frFR")
if L then
	L.lightbomb_other = "Lumière"
end

L = BigWigs:NewBossLocale("Yogg-Saron", "frFR")
if L then
	L.engage_trigger = "^Il sera bientôt temps de"
	L.phase2_trigger = "^Je suis le rêve éveillé"
	L.phase3_trigger = "^Contemplez le vrai visage de la mort"

	L.portal = "Portail"
	L.portal_desc = "Prévient de l'arrivée des portails."
	L.portal_message = "Portails ouverts !"
	L.portal_bar = "Prochains portails"

	L.fervor_message = "Ferveur sur %s !"

	L.sanity_message = "Vous allez devenir fou !"

	L.weakened = "Étourdi"
	L.weakened_desc = "Prévient quand Yogg-Saron est étourdi."
	L.weakened_message = "%s est étourdi !"

	L.madness_warning = "Susciter la folie dans 10 sec. !"
	L.malady_message = "Mal" -- short for Malady of the Mind (63830)

	L.tentacle = "Tentacule écraseur"
	L.tentacle_desc = "Prévient quand un Tentacule écraseur apparaît."
	L.tentacle_message = "Écraseur %d !"

	--L.small_tentacles = "Small Tentacles"
	--L.small_tentacles_desc = "Warn for Corruptor Tentacle and Constrictor Tentacle spawns."

	L.link_warning = "Votre cerveau est lié !"

	L.guardian_message = "Gardien %d !"

	L.roar_warning = "Rugissement dans 5 sec. !"
	L.roar_bar = "Prochain Rugissement"
end
