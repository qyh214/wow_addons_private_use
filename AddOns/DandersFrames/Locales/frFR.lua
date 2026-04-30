-- Populate DF_AllLocales["frFR"] so Core.lua's ADDON_LOADED handler
-- can apply this locale's translations as an overlay if the user's
-- languageOverride selects it. No AceLocale interaction here — the
-- overlay step happens once the SavedVariable is actually populated,
-- which is only guaranteed at ADDON_LOADED time (not file-scope).
DF_AllLocales = DF_AllLocales or {}
DF_AllLocales.frFR = {}
local L = DF_AllLocales.frFR
L["    Show Frame Glow"] = "    Afficher la lueur du cadre"
L["    Show ZZZ Icon"] = "    Afficher l'icône ZZZ"
L["— click to edit"] = "— cliquer pour modifier"
L[" indicator"] = " indicateur"
L[" indicators"] = " indicateurs"
L["⚠ Note: Click-through icons will not show tooltips."] = "⚠ Note : Les icônes cliquables à travers n'afficheront plus d'infobulles."
L["\"%s\" will be overwritten."] = "\"%s\" sera écrasé."
L["%d - %d players"] = "%d - %d joueurs"
L["%d binds"] = "%d raccourcis"
L["%d blacklisted"] = "%d sur liste noire"
L["%d override"] = "%d surcharge"
L["%d overrides"] = "%d surcharges"
L["%d players"] = "%d joueurs"
L["%d-%d players"] = "%d-%d joueurs"
L["%s (Copy)"] = "%s (Copie)"
L["%s (currently %s)"] = "%s (actuellement %s)"
L[ [=[%s detected.

Which click-casting addon would you like to use?]=] ] = "%s détecté. Quel addon de sort au clic souhaitez vous utiliser ?"
L[ [=[%s detected.

Which click-casting addon would you like to use?]=] ] = [=[%s détecté.

Quel addon de click-casting souhaitez-vous utiliser ?]=]
L["%s settings reset to defaults."] = "Paramètres de %s réinitialisés aux valeurs par défaut."
L["%sGlobal: 80%s %s— Setting matches global, no override stored%s"] = "%sGlobal : 80%s %s : le paramètre correspond à l'ensemble, aucun remplacement n'est stocké%s"
L["%sModified%s %s— Setting differs from global. Click%s %sreset%s %sto revert.%s"] = "%sModified%s %s : le paramètre diffère du paramètre global. Cliquez%s %sreset%s %spour revenir en arrière.%s"
L["(none)"] = "(aucun)"
L["(offline)"] = "(hors ligne)"
L["(skipped)"] = "(ignoré)"
L["[Linked]"] = "[lié]"
L["[Override]"] = "[Surcharge]"
L["[Unassigned]"] = "[Non assigné]"
L["+ Add"] = "+ Ajouter"
L["+ Add aura"] = "+ Ajouter une aura"
L["+ Add Indicator"] = "+ Ajouter un indicateur"
L["+ Add Layout"] = "+ Ajouter une disposition"
L["+ Add Option"] = "+ Ajouter une option"
L["+ Add Step"] = "+ Ajouter une étape"
L["+ Add Trigger"] = "+ Ajouter un déclencheur"
L["+ Create Group"] = "+ Créer un groupe"
L["+ New"] = "+ Nouveau"
L["+ New Wizard"] = "+ Nouvel assistant"
L[ [=[• Having trouble seeing certain buffs or debuffs?
• This wizard helps you pick the right aura settings]=] ] = "• Vous avez du mal à voir certains effets d’amélioration ou d’affaiblissement ? • Cet assistant vous aide à choisir le bon paramétrage des auras"
L[ [=[• Having trouble seeing certain buffs or debuffs?
• This wizard helps you pick the right aura settings]=] ] = [=[• Vous avez du mal à voir certains buffs ou debuffs ?
• Cet assistant vous aide à choisir les bons paramètres d'aura]=]
L[ [=[• Name Text
• Health Text
• Status Text (Dead/Offline)
• Buff Stack & Duration
• Debuff Stack & Duration
• Pet Frame Text
• Targeted Spell Duration
• Defensive Icon Duration
• Status Icon Text (Res, Summon, etc.)
• Group Labels (Raid)]=] ] = "• Texte de nom • Texte de vie • Texte de statut (Mort/Hors ligne) • Amélioration quantité et durée • Affaiblissement quantité et durée • Texte du cadre de familier • Durée du sort ciblé • Durée de l'icône défensive • Texte de l'icône de statut (Réssurection, Invocation, etc.) • Étiquettes de groupe (Raid)"
L[ [=[• Name Text
• Health Text
• Status Text (Dead/Offline)
• Buff Stack & Duration
• Debuff Stack & Duration
• Pet Frame Text
• Targeted Spell Duration
• Defensive Icon Duration
• Status Icon Text (Res, Summon, etc.)
• Group Labels (Raid)]=] ] = [=[• Texte du Nom
• Texte de la vie
• Texte du statut (Mort/Hors ligne)
• Nombre de piles et durée des buffs
• Nombre de piles et durée des debuffs
• Texte du cadre de familier
• Durée du sort ciblé
• Durée de l'icône défensive
• Texte de l'icône de statut (Res, Invocation, etc.)
• Labels de groupe (Raid)]=]
--[[Translation missing --]]
--[[ L[ [=[• Recommended defaults work well for most players
• Manual lets you fine-tune every filter option]=] ] = [=[• Recommended defaults work well for most players
• Manual lets you fine-tune every filter option]=]--]] 
L[ [=[• Recommended defaults work well for most players
• Manual lets you fine-tune every filter option]=] ] = [=[• Les paramètres par défaut recommandés fonctionnent bien pour la plupart des joueurs
• Le mode manuel vous permet d'affiner chaque option de filtrage]=]
L["0=Auto, Higher=On top of more elements"] = "0=Auto, Supérieur=Au-dessus de plus d'éléments"
L["1"] = "1"
L["1 = High"] = "1 = Élevé"
L["1. Open ElvUI config with %s/ec%s"] = "1. Ouvrez la configuration ElvUI avec %s/ec%s"
L["10 = Low"] = "10 = Bas"
L["2. Go to %sUnitFrames%s (left sidebar)"] = "2. Accédez à %sUnitFrames%s (barre latérale gauche)"
L["20 players (fixed)"] = "20 joueurs (fixe)"
L["3. Click %sGeneral%s at the top"] = "3. Cliquez sur %sGénéral%s en haut"
L["4. Scroll down to %sDisabled Blizzard Frames%s"] = "4. Faites défiler jusqu'à %sCadres Blizzard désactivés%s"
L["5. Under %sGroup Units%s, uncheck %sParty%s and %sRaid%s"] = "5. Sous %sGroup Units%s, décochez %sParty%s et %sRaid%s."
L["6. Click the reload button when prompted"] = "6. Cliquez sur le bouton de rechargement lorsque vous y êtes invité"
L["A layout with this name already exists in %s"] = "Une disposition avec ce nom existe déjà dans %s"
L["a placed indicator to remove it from the frame"] = "un indicateur placé pour le retirer du cadre"
L["a placed indicator to reposition it on the frame"] = "un indicateur placé pour le repositionner sur le cadre"
L["A profile with this name already exists"] = "Un profil avec ce nom existe déjà"
L["A to Z"] = "De A à Z"
L["Abbreviate (K/M)"] = "Abréger (K/M)"
L["Above Health Bar"] = "Au-dessus de la barre de vie"
L["Above Owner"] = "Au-dessus du joueur"
L["Above Party"] = "Au-dessus du groupe"
L["Above Raid"] = "Au-dessus du raid"
L["Absorb Shield"] = "Bouclier d'absorption"
L["Absorbs"] = "Absorptions"
L["Actions"] = "Actions"
L["Active"] = "Actif"
L["Active Bindings"] = "Raccourcis actifs"
L["Active Bindings (%d)"] = "Raccourcis actifs (%d)"
L["ACTIVE INDICATORS"] = "INDICATEURS ACTIFS"
L["Active:"] = "Actif :"
L["Actually, disable it"] = "En fait, le désactiver"
L["Add"] = "Ajouter"
L["Add #showtooltip"] = "Ajouter #showtooltip"
L["Add /stopcasting"] = "Ajouter /stopcasting"
L["Add Layout"] = "Ajouter une disposition"
L["Add New Binding"] = "Ajouter un nouveau raccourci"
L["Add Offline Player"] = "Ajouter un joueur hors ligne"
--[[Translation missing --]]
--[[ L[ [=[Add players from the roster
or use quick add buttons]=] ] = [=[Add players from the roster
or use quick add buttons]=]--]] 
L[ [=[Add players from the roster
or use quick add buttons]=] ] = [=[Ajouter des joueurs de la liste
ou utiliser les boutons d'ajout rapide]=]
L["Additive (ADD)"] = "Additif (AJOUT)"
L["Advanced"] = "Avancé"
L["Affected Elements"] = "Éléments affectés"
L["AFK"] = "AFK"
L["AFK Icon"] = "Icône AFK"
L["Aggro Highlight"] = "Surbrillance d'aggro"
L["Aggro Settings"] = "Paramètres d'aggro"
L["Alert if anyone is missing the buff"] = "Alerte si quelqu'un manque de l'amélioration"
L["Alert only if nobody has the buff"] = "Alerte seulement si personne n'a l'amélioration"
L["Alert When Expiring"] = "Alerte lors de l'expiration"
L["All"] = "Tout"
L["ALL (AND)"] = "TOUS (ET)"
L["All Buffs"] = "Toutes les améliorations"
L["All Debuffs"] = "Tous les affaiblissements"
L["All Dispellable"] = "Tous les dissipables"
L["All players in a unified grid. Sorting applies raid-wide."] = "Tous les joueurs dans une grille unique. Le tri s'applique à tout le raid."
L["ALL triggers must be active"] = "TOUS les déclencheurs doivent être actifs"
L["Alpha"] = "Opacité"
L["Alphabetical"] = "Alphabétique"
L["Alphabetical (within class/role)"] = "Alphabétique (par classe/rôle)"
L["Always"] = "Toujours"
L["Always First"] = "Toujours en premier"
L["Always Green"] = "Toujours vert"
L["Always Last"] = "Toujours en dernier"
L["an indicator on the frame to expand its settings"] = "un indicateur sur le cadre pour étendre ses paramètres"
L["Anchor"] = "Ancrage"
L["Anchor Point"] = "Point d'ancrage"
L["Anchor Position"] = "Position d'ancrage"
L["Anchor To"] = "Ancrer à"
L["Animated Border"] = "Bordure animée"
L["ANY (OR)"] = "N'IMPORTE LEQUEL (OU)"
L["Any Target"] = "N'importe quelle cible"
L["ANY trigger activates the effect"] = "N'IMPORTE QUEL déclencheur active l'effet"
L["Appearance"] = "Apparence"
L["Apply"] = "Appliquer"
L["Apply to All"] = "Appliquer à tous"
L["Apply to Frames:"] = "Appliquer aux cadres :"
L["Arcane Intellect (Mage)"] = "Intelligence des Arcanes (Mage)"
L["are secret-tracked"] = "sont suivis en secret"
L["Are you sure?"] = "Êtes-vous sûr(e) ?"
L["Arena"] = "Arène"
L["Arena header will show using raid1-5 unit IDs"] = "L'en-tête d'arène s'affichera en utilisant les ID d'unité raid1-5"
L["Arena mode %sDISABLED%s"] = "Mode Arène %sDESACTIVE%s"
L["Arena mode %sENABLED%s for testing"] = "Mode Arène %sACTIVE%s pour les tests"
L["Arrange Groups In"] = "Disposition des groupes en"
L["Arrange In"] = "Disposition en"
L["Arrange Players In"] = "Disposition des joueurs en"
L["Attach the handle to the container, the first visible unit, or the last visible unit."] = "Attacher l'ancre du conteneur, à la première unité visible ou à la dernière unité visible."
L["Attach To"] = "Attacher à"
L["Attached + Overflow"] = "Attaché + Débordement"
L["Attached to Health"] = "Attaché à la vie"
L["Attached to Owner"] = "Attaché au joueur"
L["Aura Blacklist"] = "Liste noire d'auras"
L["Aura Data Source"] = "Source de données des auras"
L["Aura Designer"] = "Concepteur d'auras"
L["Aura Designer Alpha"] = "Opacité du concepteur d'Auras"
L["Aura Designer is active alongside Buffs."] = "Le concepteur d'Auras est actif aux côtés des améliorations."
L["Aura Designer is disabled"] = "Le concepteur d'Auras est désactivé"
L[ [=[Aura Designer supports healer specs and Augmentation Evoker.

You can manually select a spec using the dropdown above to configure indicators in advance.]=] ] = "Le concepteur d'aura est compatible avec les spécialisations soigneurs et l'Évocateur Augmentation. Vous pouvez sélectionner manuellement une spécialisation en utilisant le menu déroulant ci-dessus afin de configurer les indicateurs à l'avance."
L[ [=[Aura Designer supports healer specs and Augmentation Evoker.

You can manually select a spec using the dropdown above to configure indicators in advance.]=] ] = [=[Le Designer d'Auras prend en charge les spécialisations de soigneur et l'Évocateur Augmentation.

Vous pouvez sélectionner manuellement une spécialisation à l'aide du menu déroulant ci-dessus pour configurer les indicateurs à l'avance.]=]
L["Aura Filter Setup"] = "Configuration du filtre d'aura"
L["Aura Filters"] = "Filtres d'auras"
L["Auras"] = "Auras"
L["Auras Alpha"] = "Opacité des Auras"
L["Auto (%s)"] = "Auto (%s)"
L["Auto (detect class)"] = "Auto (détecte la classe)"
L["Auto (detect spec)"] = "Auto (détecte la spé)"
L["Auto (detect)"] = "Auto (détecte)"
L["Auto (Spec Default)"] = "Auto (Défaut de la spé)"
L["Auto Layouts"] = "Dispositions Auto"
L["Auto Layouts is a Raid-only feature. Switch to Raid mode to configure automatic layout switching based on content type and group size."] = "Les mises en page automatiques sont une fonctionnalité réservée à Raid. Passez en mode Raid pour configurer le changement de mise en page automatique en fonction du type de contenu et de la taille du groupe."
L["Auto Layouts module not loaded."] = "Module des dispositions Auto non chargé."
L["Auto-add DPS"] = "Ajouter automatiquement les DPS"
L["Auto-add Healers"] = "Ajouter automatiquement les Soigneurs"
L["Auto-add Tanks"] = "Ajouter automatiquement les Tanks"
L["Auto-create disabled"] = "Création auto désactivée"
L["Auto-Create Profiles"] = "Créer automatiquement les profils"
L["Auto-create profiles for loadouts"] = "Créer automatiquement les profils pour les ensembles"
L["Auto-detect (your class's buff)"] = "Auto-détecte (buff de votre classe)"
L["Auto-Fit Border to Frame Size"] = "Ajustement auto de la bordure à la taille du cadre"
L["Automatically add players by role when they join your group."] = "Ajouter automatiquement les joueurs par rôle quand ils rejoignent le groupe."
L["Automatically detects player-dispellable debuffs via the RAID_PLAYER_DISPELLABLE filter. Configure the overlay on the Dispel Overlay page."] = "Détecte automatiquement les debuffs que les joueurs peuvent dissiper via le filtre RAID_PLAYER_DISPELLABLE. Configurez la superposition sur la page Superposition de dissipation."
L["Auto-Populate"] = "Auto-remplir"
L["Auto-profile \"%s\" activated (%s, %d players)"] = "Profil auto \"%s\" activé (%s, %d joueurs)"
L["Auto-profile deactivated (profile deleted)"] = "Profil auto désactivé (profil supprimé)"
L["Auto-profile deactivated, using global settings"] = "Profil auto désactivé, utilisation des paramètres globaux"
L["Auto-Switch by Spec"] = "Changement auto selon la spécialisation"
L["Auto-switched to profile: %s"] = "Changement auto vers le profil : %s"
L["Auto-switching disabled"] = "Changement auto désactivé"
L["Available Profiles"] = "Profils disponibles"
L["A-Z"] = "A-Z"
L["Back"] = "Retour"
L["Back to List"] = "Retour à la liste"
L["Background"] = "Arrière-plan"
L["Background Alpha"] = "Opacité du fond"
L["Background Color"] = "Couleur de fond"
L["Background Fill"] = "Remplissage du fond"
L["Background Mode"] = "Mode de fond"
L["Background Only"] = "Fond uniquement"
--[[Translation missing --]]
--[[ L[ [=[Background Only: Normal solid background
Missing Health Only: Shows colored bar where health is missing
Both: Shows both]=] ] = [=[Background Only: Normal solid background
Missing Health Only: Shows colored bar where health is missing
Both: Shows both]=]--]] 
L[ [=[Background Only: Normal solid background
Missing Health Only: Shows colored bar where health is missing
Both: Shows both]=] ] = [=[Fond uniquement : Arrière-plan solide normal
Santé manquante uniquement : Affiche la barre colorée là où la vie est en déficit
Les deux : Affiche les deux]=]
L["Background Texture"] = "Texture de fond"
L["Bar"] = "Barre"
L["Bar Color"] = "Couleur de la barre"
L["Bar Texture"] = "Texture de la barre"
L["Bars"] = "Barres"
L["Battle Shout (Warrior)"] = "Cri de guerre (Guerrier)"
L["Battlegrounds"] = "Champs de bataille"
L["Before You Enable"] = "Avant d'activer"
L["Below Health Bar"] = "Sous la barre de vie"
L["Below Owner"] = "Sous le joueur"
L["Below Party"] = "Sous le groupe"
L["Below Raid"] = "Sous le raid"
L["Big Defensives"] = "Gros temps de recharge défensifs"
L["Bind Action"] = "Lier l'action"
L["Bind Item"] = "Lier l'objet"
L["Bind Spell"] = "Lier le sort"
L["Binding Tooltips"] = "Infobulles de raccourcis"
L["Binding:"] = "Raccourci :"
L["Bindings only cast their assigned spell"] = "Les raccourcis lancent uniquement leur sort assigné"
L["BINDS"] = "RACCOURCIS"
L["Bleed / Enrage"] = "Saignement / Enrager"
L["Blend %"] = "% Fusion"
L["Blend Mode"] = "Mode de fusion"
L["Blessing of the Bronze (Evoker)"] = "Bénédiction de Bronze (Évocateur)"
L["Blizzard"] = "Blizzard"
L["Blizzard (Default)"] = "Blizzard (Défaut)"
L["Blizzard Click-Casting"] = "Lancement de sorts par clic (Blizzard)"
L["Blizzard Frame Settings"] = "Paramètres des cadres Blizzard"
L["Blizzard Frames"] = "Cadres Blizzard"
--[[Translation missing --]]
--[[ L[ [=[Blizzard:
• Mirrors the buffs/debuffs from default Blizzard frames
• Requires Blizzard raid settings to be configured correctly
• Slightly more performance heavy in large groups

Direct API:
• Gives you control over what shows on your frames
• Some filters may miss certain buffs/debuffs
• Others might show unwanted ones
• Can be fine-tuned for best results]=] ] = [=[Blizzard:
• Mirrors the buffs/debuffs from default Blizzard frames
• Requires Blizzard raid settings to be configured correctly
• Slightly more performance heavy in large groups

Direct API:
• Gives you control over what shows on your frames
• Some filters may miss certain buffs/debuffs
• Others might show unwanted ones
• Can be fine-tuned for best results]=]--]] 
L[ [=[Blizzard:
• Mirrors the buffs/debuffs from default Blizzard frames
• Requires Blizzard raid settings to be configured correctly
• Slightly more performance heavy in large groups

Direct API:
• Gives you control over what shows on your frames
• Some filters may miss certain buffs/debuffs
• Others might show unwanted ones
• Can be fine-tuned for best results]=] ] = [=[Blizzard:
• Reflète les buffs/debuffs des cadres par défaut de Blizzard
• Nécessite que les paramètres de raid de Blizzard soient correctement configurés
• Légèrement plus gourmand en ressources dans les grands groupes

API Directe:
• Vous donne le contrôle sur ce qui s'affiche sur vos cadres
• Certains filtres peuvent manquer certains buffs/debuffs
• D'autres peuvent afficher des éléments indésirables
• Peut être affiné pour de meilleurs résultats]=]
--[[Translation missing --]]
--[[ L[ [=[Blizzard's built-in click-casting may conflict with
DandersFrames click-casting settings.

We recommend clearing Blizzard's bindings from
frames where you use DandersFrames bindings.]=] ] = [=[Blizzard's built-in click-casting may conflict with
DandersFrames click-casting settings.

We recommend clearing Blizzard's bindings from
frames where you use DandersFrames bindings.]=]--]] 
L[ [=[Blizzard's built-in click-casting may conflict with
DandersFrames click-casting settings.

We recommend clearing Blizzard's bindings from
frames where you use DandersFrames bindings.]=] ] = [=[Le lancement de sorts à la souris intégré de Blizzard peut entrer en conflit avec
les paramètres de lancement de sorts à la souris de DandersFrames.

Nous vous recommandons de supprimer les raccourcis de Blizzard des
cadres où vous utilisez les raccourcis de DandersFrames.]=]
L["Border"] = "Bordure"
L["Border Color"] = "Couleur de la bordure"
L["Border Inset"] = "Encart de bordure"
L["Border Mode:"] = "Mode de bordure :"
L["Border Opacity"] = "Opacité de bordure"
L["Border Scale"] = "Échelle de bordure"
L["Border Size"] = "Taille de bordure"
L["Border Thickness"] = "Épaisseur de bordure"
L["Boss Debuffs"] = "Affaiblissements de boss"
L["Boss Debuffs (Private Auras) are special debuffs that Blizzard hides from addons."] = "Les affaiblissements de boss (Auras privées) sont des effets spéciaux que Blizzard cache aux addons."
L["Both"] = "Les deux"
L["Bottom"] = "Bas"
L["Bottom Edge"] = "Bord inférieur"
L["Bottom Left"] = "Bas Gauche"
L["Bottom Right"] = "Bas Droite"
L["Bottom to Top"] = "De bas en haut"
L["Bounce"] = "Rebond"
L["Bound: %s"] = "Lié : %s"
L["Branch"] = "Branche"
L["Branching Rules"] = "Règles de branchement"
L["BUFF BLACKLIST"] = "LISTE NOIRE D'AMÉLIORATIONS"
L["Buff Filters"] = "Filtres d'améliorations"
L["Buff Icon"] = "Icône d'amélioration"
L["Buff Icons"] = "Icônes d'Améliorations"
L["Buff Icons Click-Through"] = "Améliorations cliquables à travers"
L["Buff Tooltips"] = "Infobulles des améliorations"
L["Buffs"] = "Améliorations"
L["Buffs are disabled. Aura Designer is managing your auras."] = "Les buffs sont désactivés. Aura Designer gère vos auras."
L["Buffs flagged by Blizzard to show up on raid frames."] = "Buffs signalés par Blizzard pour apparaître sur les images de raid."
L["Buffs flagged to show on raid frames during combat, such as self-cast HoTs."] = "Buffs signalés pour s'afficher sur les images de raid pendant le combat, tels que les HoT auto-lancements."
L["Buffs that can be right-click cancelled."] = "Améliorations qui peuvent être annulées par un clic droit."
L["Buffs that cannot be cancelled by the player."] = "Améliorations qui ne peuvent pas être annulées par le joueur."
L["Buffs to Check (Manual Mode)"] = "Améliorations à vérifier (Mode manuel)"
L["Building: "] = "En construction : "
L["Built-in Wizards"] = "Assistants intégrés"
L["By Health %"] = "Par % de vie"
L["Cancel"] = "Annuler"
L["Cancel Fade on Dispellable Debuff"] = "Annuler l'estompage sur l'affaiblissement dissipable"
L["Cancelable"] = "Annulable"
L["Cannot delete Default profile."] = "Impossible de supprimer le profil par défaut."
L["Cannot disable test mode while frames are unlocked. Lock frames first."] = "Impossible de désactiver le mode test lorsque les cadres sont déverrouillés. Verrouillez les d'abord."
L["Cannot Edit"] = "Impossible à modifier"
L["Cannot enter test mode during combat."] = "Impossible de passer en mode test pendant le combat."
L["Cannot toggle arena mode during combat"] = "Impossible de changer le mode arène en combat"
L["Cannot toggle test mode during combat."] = "Impossible de basculer en mode test pendant le combat."
L["Cannot unlock - container doesn't exist!"] = "Impossible de déverrouiller : le conteneur n'existe pas !"
L["Cannot unlock - failed to create mover frame!"] = "Impossible de déverrouiller : échec de la création du cadre de déplacement !"
L["Cannot unlock frames during combat."] = "Impossible de déverrouiller les cadres pendant le combat."
L["Cannot use this action in combat."] = "Impossible d'utiliser cette action en combat."
L["Cast on DOWN"] = "Incantation à la PRESSION (bas)"
L["Categories"] = "Catégories"
L["Category Filters"] = "Filtres de catégories"
L["CC effects like stuns, roots, and incapacitates."] = "Effets CC comme étourdissements, immobilisations et neutralisation."
L["Center"] = "Centre"
L["Center (Horizontal)"] = "Centre (Horizontal)"
L["Center (Vertical)"] = "Centre (Vertical)"
L["Center of Group"] = "Centre du groupe"
L["Character"] = "Personnage"
L["Character Import"] = "Importation de Personnage"
L["Choose how DandersFrames reads aura data for buffs, debuffs, defensives, and dispel detection."] = "Choisissez comment DandersFrames lit les données d'auras pour les améliorations, affaiblissements, sorts défensifs et la détection de dissipation."
L["Choose Icon"] = "Choisir Icône"
L["Choose whether to enable the frame border overlay."] = "Choisissez d'activer ou non la superposition de bordure de cadre."
L["Choose which groups to display."] = "Choisissez les groupes à afficher."
L["Clamp Mode"] = "Mode restriction (Clamp)"
L["Class"] = "Classe"
L["Class Color"] = "Couleur de classe"
L["Class Color Alpha"] = "Opacité de couleur de classe"
L["Class Colors"] = "Couleurs de classe"
L["Class Filter"] = "Filtre de classe"
L["Class Power"] = "Ressource de classe"
L["Class Power Pips"] = "Points de ressource de classe"
L["Class Priority"] = "Priorité de classe"
L["Clear"] = "Effacer"
L["Clear All"] = "Tout effacer"
L["Clear All Bindings"] = "Effacer tous les raccourcis"
L["Clear Blizzard Bindings"] = "Effacer les raccourcis Blizzard"
L["Clear Log"] = "Effacer le journal"
L["Click"] = "Clic"
L["Click %sEdit Settings%s on a profile to customise it. This takes you to the settings tabs with an editing banner at the top. While editing, any setting you change is stored as an override for that profile only."] = "Cliquez sur %sModifier les paramètres%s sur un profil pour le personnaliser. Cela vous amène aux onglets de paramètres avec une bannière d'édition en haut. Lors de l'édition, tout paramètre que vous modifiez est stocké comme remplacement pour ce profil uniquement."
L["Click %sExit Editing%s when done. Your overrides are saved to the profile. If you change a setting back to match global, the override is automatically removed."] = "Cliquez sur %sQuitter l'édition%s lorsque vous avez terminé. Vos remplacements sont enregistrés dans le profil. Si vous modifiez un paramètre pour qu'il corresponde à global, le remplacement est automatiquement supprimé."
L["Click a color swatch to open the color picker. These settings are shared across party and raid frames."] = "Cliquez sur une couleur pour ouvrir le sélecteur de couleurs. Ces paramètres sont partagés entre les cadres de groupe et de raid."
L["Click a setting to link it to your wizard"] = "Cliquez sur un paramètre pour le lier à votre assistant"
L["Click item slot to bind"] = "Cliquez sur l'emplacement d'objet pour lier"
L["Click macro to bind"] = "Cliquez sur la macro pour lier"
L["Click or drag a spell onto the frame to place it"] = "Cliquez ou glissez un sort sur le cadre pour le placer"
L["Click spell to bind"] = "Cliquez sur le sort pour le lier"
L["Click to bind..."] = "Cliquez pour lier..."
L["Click to cycle through steps"] = "Cliquez pour parcourir les étapes"
L["Click to edit"] = "Cliquez pour modifier"
L["Click to edit range"] = "Cliquez pour modifier la portée"
L["Click to set branch target"] = "Cliquez pour définir la cible de la branche"
--[[Translation missing --]]
--[[ L[ [=[Click to sync Party & Raid %s settings.
Changes in one mode will automatically apply to the other.]=] ] = [=[Click to sync Party & Raid %s settings.
Changes in one mode will automatically apply to the other.]=]--]] 
L[ [=[Click to sync Party & Raid %s settings.
Changes in one mode will automatically apply to the other.]=] ] = [=[Cliquez pour synchroniser les paramètres de groupe et de raid %s.
Les modifications apportées dans un mode s'appliqueront automatiquement à l'autre.]=]
L["Click to toggle"] = "Cliquez pour basculer"
L["Click-cast profile: %s"] = "Profil de Click-cast : %s"
L["Click-Casting"] = "Click-Casting (lancement de sorts au clic)"
L["Click-Casting Addon Conflict"] = "Conflit d'Addon Click-Casting"
L["Click-Through Icons"] = "Icônes cliquables à travers"
L["Clip Border to Frame"] = "Couper la bordure au cadre"
L["Close"] = "Fermer"
L["Color"] = "Couleur"
L["Color and opacity of the empty/inactive pips."] = "Couleur et opacité des points de ressources vides/inactifs."
L["Color Bar by Duration"] = "Colorer la barre selon la durée"
L["Color by Dispel Type"] = "Colorer selon le type de dissipation"
L["Color by Time"] = "Colorer selon le temps"
L["Color by Time Remaining"] = "Colorer selon le temps restant"
L["Color Duration by Time"] = "Colorer la durée selon le temps"
L["Color Mode"] = "Mode de couleur"
L["Color Name Text"] = "Colorer le nom"
L["Color Picker"] = "Sélecteur de couleur"
L["Color shown when in combat to indicate the handle is locked."] = "Couleur affichée en combat pour indiquer que l'ancre est verrouillée."
L["Colors"] = "Couleurs"
L["Column Growth"] = "Croissance des colonnes"
L["Column Spacing"] = "Espacement des colonnes"
L["Columns"] = "Colonnes"
L["Columns Grow From"] = "Les colonnes croissent de"
L["Combat"] = "Combat"
L["Combat Color"] = "Couleur de Combat"
L["Combat Limitation: All groups will not update with new players that join mid-combat."] = "Limitation en combat : Les groupes ne seront pas mis à jour pour les joueurs rejoignant en cours de combat."
L["Combat Limitation: Your group will not update with new players that join mid-combat."] = "Limitation en combat : Votre groupe ne sera pas mis à jour pour les joueurs rejoignant en cours de combat."
L["Combat Mode"] = "Mode de combat"
L["Combat Only"] = "En combat uniquement"
L["Compatible (%d)"] = "Compatible (%d)"
L["Compatible Bindings"] = "Raccourcis compatibles"
L["Compatible Only"] = "Compatibles uniquement"
L["Confirm"] = "Confirmer"
L["Console"] = "Console"
L["Container"] = "Conteneur"
L["Content type filters configured in Party tab."] = "Filtres de type de contenu configurés dans l'onglet Groupe."
L["Content Types"] = "Types de contenu"
L["Content:"] = "Contenu :"
L["Controls Blizzard's debuff filtering (affects our display too)."] = "Contrôle le filtre d'affaiblissements de Blizzard (affecte aussi notre affichage)."
L["Controls how multiple defensive icons are arranged when using Direct aura mode."] = "Contrôle comment les icônes défensives sont arrangées en utilisant le mode d'aura Direct."
L["Copied %d settings from %s to %s."] = "%d paramètres copiés de %s vers %s."
L["Copied settings from %s to %s."] = "Paramètres copiés de %s vers %s."
L["Copies these settings from %s to %s."] = "Copie ces paramètres de %s vers %s."
L["Copy"] = "Copier"
L["Copy %s Settings"] = "Copier les paramètres %s"
L["Copy %s settings to %s?"] = "Copier les paramètres %s vers %s ?"
L["Copy all settings between Party and Raid modes."] = "Copier tous les paramètres entre les modes Groupe et Raid."
L["COPY APPEARANCE FROM"] = "COPIER L'APPARENCE DE"
L["Copy Layout"] = "Copier la disposition"
L["Copy Settings"] = "Copier les paramètres"
L["Copy Settings to %s"] = "Copier les paramètres vers %s"
L["Copy the string below to share this wizard:"] = "Copiez la chaîne de caractères ci-dessous pour partager cet assistant :"
L["Copy this string to share your profile:"] = "Copiez la chaîne de caractères pour partager votre profil :"
L["Copy To"] = "Copier vers"
L["Copy to Clipboard"] = "Copier dans le presse-papiers"
L["Copy to Party"] = "Copier vers le groupe"
L["Copy to Raid"] = "Copier vers le raid"
L["Corners Only"] = "Angles uniquement"
L["Create"] = "Créer"
L["Create and manage setup wizards that guide users through configuring addon settings. Wizards can be shared with others via import/export strings."] = "Créez et gérez des assistants de configuration qui guident les utilisateurs dans la configuration des paramètres du module complémentaire. Les assistants peuvent être partagés avec d’autres via des chaînes d’importation/exportation."
L["Create Custom Macro"] = "Créer une Macro personnalisée"
L["Create Empty"] = "Créer vide"
L["Create Layout"] = "Créer une Disposition"
L["Create layouts below for different player ranges within each content type. Layouts only store settings that %sdiffer%s from your global settings — everything else is inherited automatically."] = "Créez des mises en page ci-dessous pour différentes gammes de lecteurs au sein de chaque type de contenu. Les mises en page stockent uniquement les paramètres qui %sdiffèrent%s de vos paramètres globaux ; tout le reste est hérité automatiquement."
L["Create Macro"] = "Créer Macro"
L["Create New Profile"] = "Créer un nouveau profil"
L["Create separate frame groups to pin specific players like tanks, healers, or key raid members. Drag players from your group roster to add them."] = "Créez des cadres de groupes séparés pour épingler des joueurs spécifiques comme les tanks, soigneurs ou membres clés du raid. Glissez les joueurs de la liste de groupe pour les ajouter."
L["Created new profile: %s"] = "Nouveau profil créé : %s"
L["Crowd Control"] = "Contrôle de foule (CC)"
L["Current / Max"] = "Actuel / Max"
L["Current Health"] = "Vie actuelle"
L["Current Profile"] = "Profil actuel"
L["CURRENT STATUS"] = "STATUT ACTUEL"
L["Currently: Percent. Click for Seconds."] = "Actuellement : Pourcentage. Cliquez pour les Secondes."
L["Currently: Seconds. Click for Percent."] = "Actuellement : Secondes. Cliquez pour le Pourcentage."
L["Curse"] = "Malédiction"
L["Cursor"] = "Curseur"
L["Custom"] = "Personnalisé"
L["Custom Border"] = "Bordure personnalisée"
L["Custom buff and frame effect indicators"] = "Améliorations personnalisées et indicateurs d'effet de cadre"
L["Custom Color"] = "Couleur personnalisée"
L["Custom Dead Background"] = "Fond personnalisé de mort"
L["Custom Dispel Colors"] = "Couleurs d'interruption personnalisées"
L["Custom Health Color"] = "Couleur de vie personnalisée"
L["Custom Macro"] = "Macro personnalisée"
L["Custom Sound Path"] = "Chemin de son personnalisé"
L["Custom Spell ID"] = "ID de sort personnalisé"
L["Customise"] = "Personnaliser"
L["Customize class colors used throughout DandersFrames. Changes apply to health bars, name text, borders, and all other class-colored elements."] = "Personnaliser les couleurs de classe de DandersFrames. S'applique aux barres de vie, noms, bordures, etc."
L["Customize resource bar colors per power type. Shared across party and raid frames."] = "Personnaliser les couleurs des barres de ressources par type de pouvoir. Partagé entre les défis de groupe et raid."
L["Cut"] = "Couper"
--[[Translation missing --]]
--[[ L["Cycle Next CC Profile"] = "Cycle Next CC Profile"--]] 
--[[Translation missing --]]
--[[ L["Cycle Next Profile"] = "Cycle Next Profile"--]] 
L["Damage"] = "Dégât"
L["DandersFrames Auto-Profile Overrides:"] = "Surcharges de profils automatique DandersFrames :"
L["Darken Amount"] = "Quantité d'assombrissement"
L["Darken Behind Gradient"] = "Assombrir l'arrière du dégradé"
L["Darken Effect"] = "Effet d'assombrissement"
L["Dashed Border"] = "Bordure en pointillés"
L["Dead + In combat: Cast Battle Res (Rebirth, etc.)"] = "Mort + En combat : Lancer Résurrection de combat (Renaissance, etc.)"
L["Dead + Out of combat: Cast Mass Res or normal Res"] = "Mort + Hors combat : Lancer Résurrection de masse ou Résurrection normale"
L["Dead Background Color"] = "Couleur de fond (Mort)"
L["Dead/Offline Fading"] = "Estompage Mort/Hors ligne"
L["Death Knight"] = "Chevalier de la Mort"
L["DEBUFF BLACKLIST"] = "LISTE NOIRE D'AFFAIBLISSEMENTS"
L["Debuff Filters"] = "Filtres d'affaiblissements"
L["Debuff Icon"] = "Icône d'affaiblissement"
L["Debuff Icons"] = "Icônes d'affaiblissement"
L["Debuff Icons Click-Through"] = "Icônes d'affaiblissement Cliquables à travers"
L["Debuff Tooltips"] = "Infobulles d'affaiblissements"
L["Debuffs"] = "Affaiblissements"
L["Debuffs relevant during combat in a raid context."] = "Affaiblissements pertinents en combat dans un contexte de raid."
L["Debuffs relevant in a raid context."] = "Affaiblissements pertinents dans un contexte de raid."
L["Debug"] = "Débogage"
L["Debug Console"] = "Console de débogage"
L["Debug Log Export (Filtered)"] = "Exportation de journal de débogage (Filtré)"
L["Debug logging %s"] = "Journalisation de débogage %s"
L["Debug mode %s"] = "Mode débogage %s"
L["Debug Mode (print to chat)"] = "Mode débogage (impression dans le chat)"
L["Deduplication"] = "Déduplication"
L["Default (Slot Order)"] = "Défaut (Ordre d'apparition)"
L["Default Frame Level"] = "Niveau du cadre par défaut"
L["Default Frame Strata"] = "Strate du cadre par défaut"
L["Default Icon Size"] = "Taille d'icône par défaut"
L["Default Scale"] = "Échelle par défaut"
L["Defensive buffs from other players, like Pain Suppression or Blessing of Sacrifice."] = "Améliorations défensives provenant d'autres joueurs (ex: Suppression de la douleur)."
L["Defensive Icon"] = "Icône Défensive"
L["Defensive Icon Alpha"] = "Opacité de l'icône défensive"
L["Defensive Icon Click-Through"] = "L'icône défensive est cliquable à travers"
L["Defensive Icon Tooltips"] = "Infobulles des icônes défensives"
L["Defensives"] = "Défensifs"
L["Del"] = "Suppr"
L["Delete"] = "Supprimer"
L["Delete Current Profile"] = "Supprimer Profil Actuel"
--[[Translation missing --]]
--[[ L[ [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=] ] = [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=]--]] 
L[ [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=] ] = [=[Supprimer la macro importée '%s' ?
Tous les raccourcis utilisant cette macro seront supprimés.

(La macro WoW d'origine ne sera pas affectée)]=]
L["Delete Layout"] = "Supprimer Disposition"
L["Delete layout \"%s\"?"] = "Supprimer la mise en page \"%s\" ?"
--[[Translation missing --]]
--[[ L[ [=[Delete macro '%s'?
Any bindings using this macro will be removed.]=] ] = [=[Delete macro '%s'?
Any bindings using this macro will be removed.]=]--]] 
L[ [=[Delete macro '%s'?
Any bindings using this macro will be removed.]=] ] = [=[Supprimer la macro '%s' ?
Tous les raccourcis utilisant cette macro seront supprimés.]=]
--[[Translation missing --]]
--[[ L[ [=[Delete profile '%s'?

This cannot be undone.]=] ] = [=[Delete profile '%s'?

This cannot be undone.]=]--]] 
L[ [=[Delete profile '%s'?

This cannot be undone.]=] ] = [=[Supprimer le profil '%s' ?

Cette action ne peut pas être annulée.]=]
L["Delete Step"] = "Supprimer l'étape"
L["Deleted profile: %s"] = "Profil supprimé : %s"
L["Demon Hunter"] = "Chasseur de démons"
L["Desaturate When Missing"] = "Désaturer lorsque manquant"
L["Description"] = "Description"
L["Description (optional)"] = "Description (optionnelle)"
L["Dialog"] = "Dialogue"
L["Direct API"] = "API Directe"
L["Direction"] = "Direction"
L["Disable (set to false)"] = "Désactiver (mettre à false)"
L["Disable Buffs"] = "Désactiver Améliorations"
L["Disable in Combat"] = "Désactiver en Combat"
L["Disable Overlay"] = "Désactiver la Superposition"
L["Disable While Mounted"] = "Désactiver sur monture"
L["Disable while mounted/flying"] = "Désactiver en monture/vol"
L["Disabled"] = "Désactivé"
L["disabled"] = "désactivé"
L["Disease"] = "Maladie"
L["Dispel Detection"] = "Détection de dissipation"
L["Dispel Overlay"] = "Superposition de Dissipation"
L["Dispel Overlay Alpha"] = "Opacité Superposition Dissipation"
L["Dispel Type Colors"] = "Couleur par type de dissipation"
L["Dispel Type Icon"] = "Icône du type de dissipation"
L["Dispellable By Me"] = "Dissipable Par Moi"
L["Display"] = "Affichage"
L["Display labels above or beside each raid group."] = "Affiche les étiquettes au-dessus ou à coté de chaque groupe de raid"
L["Display Mode"] = "Mode d'affichage"
L["Displays class-specific resources (Holy Power, Chi, Combo Points, Soul Shards, Arcane Charges, Essence) as colored pips on your player frame."] = "Affiche les ressources spécifiques aux classes comme des points sur le cadre du joueur."
L["Done"] = "Terminé"
L["Don't show this warning again"] = "Ne plus afficher ce message"
L["Down"] = "Bas"
L["DPS"] = "dps"
L["Drag"] = "Glisser"
L["Drag to reorder groups. Top = first."] = "Glissez pour réorganiser les groupes. Haut = premier."
L["Drag to reorder. Top = first."] = "Glissez pour réorganiser. Haut = premier."
L["Drop on an anchor point to move %s"] = "Déposer sur un point d'origine pour déplacer %s"
L["Drop on an anchor point to place %s"] = "Déposer sur un point d'origine pour placer %s"
L["Druid"] = "Druide"
L["Dungeons"] = "Donjons"
L["Duplicate"] = "Dupliquer"
L["Duplicate Current"] = "Dupliquer Actuel"
L["Duplicated profile '%s' to '%s'."] = "Profil dupliqué '%s' vers '%s'."
L["Duration"] = "Durée"
L["Duration & stack display"] = "Affichage Durée & Pile"
L["Duration Anchor"] = "Point d'ancrage de la Durée"
L["Duration Color"] = "Couleur de la Durée"
L["Duration Font"] = "Police de Durée"
L["Duration in seconds for the Pull Timer quick action."] = "Durée en secondes pour l'action rapide de Minute de Pull."
L["Duration Offset X"] = "Décalage X de la Durée"
L["Duration Offset Y"] = "Décalage Y de la Durée"
L["Duration Outline"] = "Contour de la Durée"
L["Duration Position"] = "Position de la Durée"
L["Duration Scale"] = "Echelle de la Durée"
L["Duration Text"] = "Texte de Durée"
L["Duration Text Color"] = "Couleur de Texte de Durée"
L["Echo to Chat"] = "Echo dans le chat"
L["Edge Glow (All Sides)"] = "Lueur de Bord (Tous Côtés)"
L["Edit"] = "Modifier"
L["Edit Binding"] = "Editer le raccourci"
L["Edit Copy"] = "Editer la Copie"
L["Edit Layout Range"] = "Editer la portée de la disposition"
L["Edit Macro"] = "Editer la Macro"
L["Edit Settings"] = "Editer Paramètres"
L["Edit Steps"] = "Editer les étapes"
L["Editing"] = "Edition"
L["Editing:"] = "En cours d'édition :"
L["Editing: %s"] = "En cours d'édition : %s"
L["Effects"] = "Effets"
L["Ellipsis (...)"] = "Points de suspension (...)"
L["Enable"] = "Activer"
L["Enable (set to true)"] = "Activer (mettre à true)"
L["Enable AFK Icon"] = "Activer Icône ABS"
L["Enable Aura Designer"] = "Activer le concepteur d'aura"
L["Enable Binding Tooltips"] = "Activer Infobulles pour raccourcis"
L["Enable Boss Debuffs"] = "Activer Affaiblissements de boss"
L["Enable Buff Tooltips"] = "Activer les Infobulles d'améliorations"
L["Enable Buffs"] = "Activer Améliorations"
L["Enable Class Power Pips"] = "Activer Indicateurs de ressources de classe"
L["Enable Custom Sorting"] = "Activer Triage personnalisé"
L["Enable Dead Fade"] = "Activer fondu des morts"
L["Enable Debuff Tooltips"] = "Activer l'info-bulle des affaiblissements"
L["Enable Debug Logging"] = "Activer log de débogage"
L["Enable Defensive Icon"] = "Activer Icône Défensive"
L["Enable Defensive Icon Tooltips"] = "Activer Info-bulle Icône Déf."
L["Enable Dispel Overlay"] = "Activer superposition de Dissipation"
L["Enable Element-Specific Alpha"] = "Activer Opacité spécifique à l'élement"
L["Enable Expiring Indicators"] = "Activer indicateur d'Expiration"
L["Enable Frame Border Overlay"] = "Activer superposition de bordure cadre"
L["Enable Frame Tooltips"] = "Activer infobulles du Cadre"
L["Enable Group Labels"] = "Activer labels de Groupes"
L["Enable Heal Prediction"] = "Activer la prédiction de soins"
L["Enable Health Threshold Fade"] = "Activer l'Opacité au seuil de PV"
L["Enable Leader Icon"] = "Activer Icône du chef"
L["Enable Missing Buff Icon"] = "Activer Icône d'amélioration manquante"
L["Enable Offscreen Nameplates"] = "Activer les plaques On-Screen"
L["Enable Overlay"] = "Activer Superposition"
L["Enable Permanent Mover"] = "Activer l'ancre de déplacement permanente"
L["Enable Personal Targeted Spells"] = "Activer sorts ennemis vous ciblant"
L["Enable Pet Frames"] = "Activer le cadre du Familier"
L["Enable Phased Icon"] = "Activer Icône de Phasage"
L["Enable Raid Auto-Switching Layouts"] = "Activer la disposition Raid auto"
L["Enable Raid Role Icon"] = "Activer icône de rôle de raid"
L["Enable Raid Target Icon"] = "Activer Icône cible de raid"
L["Enable Ready Check Icon"] = "Activer icône de préparation"
L["Enable Resource Bar"] = "Activer Barre de ressources"
L["Enable Resurrection Icon"] = "Activer icône de Résurrection"
L["Enable Resurrection Icon Tooltips"] = "Activer Info-bulles Résurrection"
L["Enable Sound Alert"] = "Activer alerte sonore"
L["Enable Spec Auto-Switch"] = "Autoriser le changement selon la spécialisation."
L["Enable Status Text"] = "Activer Status Text"
L["Enable Summon Icon"] = "Activer Icônes d'Invocations"
L["Enable Targeted Spells"] = "Activer ciblages ciblés"
L["Enable the checkbox above to use"] = "Cochez pour utiliser les paramètres ci-haut."
L["Enable Vehicle Icon"] = "Activer icônes de véhicule"
L["enabled"] = "activé"
L["Enabled"] = "Activé"
--[[Translation missing --]]
--[[ L[ [=[Enabled: Players organized by raid groups (1-8).
Disabled: All players in one flat grid.]=] ] = [=[Enabled: Players organized by raid groups (1-8).
Disabled: All players in one flat grid.]=]--]] 
L[ [=[Enabled: Players organized by raid groups (1-8).
Disabled: All players in one flat grid.]=] ] = [=[Activé : Les joueurs sont organisés par groupes de raid (1-8).
Désactivé : Tous les joueurs dans une grille unique.]=]
L["End"] = "Fin"
L["END"] = "FIN"
L["End (Right/Bottom)"] = "Fin (Droite/Bas)"
L["End of Group"] = "Fin du Groupe"
L["Energy"] = "Énergie"
L["Enter a layout name"] = "Entrer un nom de disposition"
L["Enter a profile name"] = "Entrer un nom de profil"
L["Enter a spell name above..."] = "Entrez le nom d'un sort ci-dessus..."
L["Enter any spell ID for range checking. Press Enter to apply. Leave empty to use dropdown selection."] = "Entrez un ID de sort pour la vérification de la portée. Appuyez sur Entrée. Laissez vide pour utiliser la liste."
L["Enter name for copy of '%s':"] = "Entrez le nom pour la copie de '%s' :"
L["Enter new name for '%s':"] = "Entrez le nouveau nom pour '%s' :"
L["Enter new profile name:"] = "Entrez le nouveau nom de profil :"
L["Enter WoW texture paths (file extensions are stripped automatically). Leave empty to use DF Icons as fallback."] = "Entrez les chemins des textures WoW (les extensions sont supprimées). Laissez vide pour les icônes DF."
L["Errors Only"] = "Erreurs uniquement"
L["Evoker"] = "Évocateur"
L["Exit Editing"] = "Quitter l'édition"
L["Expire Alert"] = "Alerte d'expiration"
L["Expiring"] = "Expirant"
L["Expiring Alpha"] = "Opacité d'expiration"
L["Expiring Alpha Override"] = "Opacité d'expiration (Ecrasement)"
L["Expiring Color"] = "Couleur d'expiration"
L["Expiring Color Override"] = "Couleur d'expiration (Ecrasement)"
L["Expiring Indicator"] = "Indicateur d'expiration"
L["Expiring indicator tracks the trigger with the least time remaining."] = "L'indicateur d'expiration suit le déclencheur avec le moins de temps restant."
L["Expiring indicator tracks the trigger with the most time remaining."] = "L'indicateur d'expiration suit le déclencheur avec le plus de temps restant."
L["Expiring Threshold (%)"] = "Seuil d'expiration (%)"
L["Expiring Threshold (seconds)"] = "Seuil d'expiration (secondes)"
L["Export"] = "Exporter"
L["Export failed. Please try again or check for errors."] = "L'export a échoué. Veuillez réessayer."
L["Export Settings"] = "Exporter les paramètres"
L["Export Wizard"] = "Assistant d'export"
L["External"] = "Externe"
L["External Defensives"] = "Défensifs externes"
L["Fade frames or elements when a unit's health is above the set threshold (e.g. 100% or 80%)."] = "Estompe les cadres si la vie de l'unité dépasse le seuil fixé (ex: 100% ou 80%)."
L["Fading"] = "Estompage"
L["Fill Color"] = "Couleur de remplissage"
L["Fill Direction"] = "Direction de remplissage"
L["Fill Pulsate"] = "Pulsation de remplissage"
L["Finish"] = "Terminer"
L["First question"] = "Première question"
L["First Unit"] = "Première unité"
L["Fixed at 20 players (Mythic)"] = "Fixé à 20 joueurs (Mythique)"
L["Flat Grid Settings"] = "Paramètres de grille"
L["Floating Bar"] = "Barre flottante"
L["Floating Bar Anchor"] = "Ancrage de la barre flottante"
L["Floating Bar Position"] = "Position de la barre flottante"
L["Focus"] = "Focalisation"
L["Font"] = "Police"
L["Font Outline"] = "Contour de police"
L["Font Settings"] = "Paramètre de police"
L["Font settings for icons displayed as text (Summon, Res, AFK, etc.)"] = "Options de police pour icônes au format texte (Invoc, Rés, ABS, etc.)"
L["Font Size"] = "Taille de la police"
L["For items/macros that need @cursor, @mouseover, etc. Consumes the keybind and prevents action bar use."] = "Pour les macros nécessitant @cursor, etc. Consomme le raccourci."
L["For nameplates & world units. %sDoes not work with action bar binds.%s"] = "Pour les barres d'info et unités monde. %sNe marche pas avec les barres d'action.%s"
L["Frame"] = "Cadre"
L["Frame Alpha"] = "Opacité du cadre"
L["Frame Alpha (Above Threshold)"] = "Opacité du cadre (Au-dessus du seuil)"
L["Frame Alpha (Out of Range)"] = "Opacité du cadre (Hors de portée)"
L["Frame Border Overlay"] = "Superposition de bordure du cadre"
L["Frame Display"] = "Affichage du cadre"
L["Frame Growth"] = "Croissance du cadre"
L["Frame Height"] = "Hauteur du cadre"
L["Frame Level"] = "Niveau du cadre"
L["Frame Level Offset"] = "Décalage du niveau du cadre"
L["Frame opacity when health is above the threshold."] = "Opacité du cadre si les PV dépassent le seuil."
L["Frame Padding"] = "Remplissage du cadre"
L["FRAME PREVIEW"] = "APERÇU DU CADRE"
L["Frame Scale"] = "Échelle du cadre"
L["Frame Size"] = "Taille du cadre"
L["Frame Spacing"] = "Espacement de cadre"
L["Frame Strata"] = "Couche du cadre"
L["Frame Tooltips"] = "Infobulles de cadre"
L["Frame Width"] = "Largeur de cadre"
L["FRAME-LEVEL EFFECTS"] = "EFFETS AU NIVEAU DU CADRE"
L["Frames centered on screen."] = "Cadres centrés sur l'écran."
L["Frames Grow From"] = "Orientation des cadres"
L["Frames locked."] = "Cadres verrouillés."
L["Frames unlocked. Drag to move, right-click to lock."] = "Cadres déverrouillés. Glissez pour déplacer, clic droit pour verrouiller."
L["Frames: %s"] = "Cadres : %s"
--[[Translation missing --]]
--[[ L[ [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=] ] = [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=]--]] 
L[ [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=] ] = [=[L'addon FrameSort a été détecté. Activez-le pour permettre à FrameSort de contrôler l'ordre des cadres.

%sExpérimental:%s Cette fonctionnalité est nouvelle et peut ne pas fonctionner parfaitement dans tous les scénarios. Veuillez signaler tout problème.]=]
L["FrameSort Integration"] = "Intégration FrameSort"
L["Friendly Only"] = "Amical Uniquement"
L["Full Frame"] = "Cadre entier"
L["Fully Combat Safe: Frames will update normally during combat."] = "Sûr en combat : Les cadres se mettront à jour normalement."
L["Fury"] = "Fureur"
L["G1"] = "G1"
L["Game Default"] = "Par défaut"
L["Gap Between Pips"] = "Espace entre les points de ressources"
L["General"] = "Général"
L["General Import"] = "Importation générale"
L["Generate Export String"] = "Générer la chaîne d'export"
L["Gets its own independent border overlay. Multiple custom borders can be visible at the same time."] = "A sa propre superposition. Plusieurs bordures peuvent être visibles simultanément."
L["Global"] = "Global"
L["Global Font Settings"] = "Paramètres de police globaux"
L["Global Fonts"] = "Polices globales"
L["Global Keybind:"] = "Raccourci global :"
L["Glow"] = "Lueur"
L["Glow (ADD)"] = "Lueur (Ajout)"
L["Glow Alpha"] = "Opacité de la lueur"
L["Glow Color"] = "Couleur de lueur"
L["Glow Style"] = "Style de lueur"
L["Go Back"] = "Retourner"
L["Goes to: %s"] = "Va à : %s"
L["Gradient"] = "Dégradé"
L["Gradient Color Alpha"] = "Opacité couleur du dégradé"
L["Gradient Intensity"] = "Intensité du dégradé"
L["Gradient Opacity"] = "Opacité du dégradé"
L["Gradient Position"] = "Position du dégradé"
L["Gradient Size"] = "Taille du dégradé"
L["Grid"] = "Grille"
L["Grid Layout"] = "Disposition en grille"
L["Group"] = "Groupe"
L["Group 1"] = "Groupe 1"
L["Group Display Order"] = "Ordre d'affichage du groupe"
L["Group Labels"] = "Étiquettes de groupe"
--[[Translation missing --]]
--[[ L[ [=[Group labels are not available in Flat Grid layout.

Enable 'Use Group-Based Layout' in Frame settings
to use group labels.]=] ] = [=[Group labels are not available in Flat Grid layout.

Enable 'Use Group-Based Layout' in Frame settings
to use group labels.]=]--]] 
L[ [=[Group labels are not available in Flat Grid layout.

Enable 'Use Group-Based Layout' in Frame settings
to use group labels.]=] ] = [=[Les étiquettes de groupe ne sont pas disponibles dans la disposition en grille unique.

Activez 'Utiliser la disposition basée sur les groupes' dans les paramètres des cadres d'unités
pour utiliser les étiquettes de groupe.]=]
--[[Translation missing --]]
--[[ L[ [=[Group labels are only available for raid frames.

Switch to Raid mode using the toggle at the top
of the settings panel to configure group labels.]=] ] = [=[Group labels are only available for raid frames.

Switch to Raid mode using the toggle at the top
of the settings panel to configure group labels.]=]--]] 
L[ [=[Group labels are only available for raid frames.

Switch to Raid mode using the toggle at the top
of the settings panel to configure group labels.]=] ] = [=[Les étiquettes de groupe ne sont disponibles que pour les cadres d'unités de raid.

Activez le mode Raid en utilisant le bouton d'activation en haut
des paramètres pour configurer les étiquettes de groupe.]=]
L["Group Layout Settings"] = "Paramètres de disposition de groupes"
L["GROUP NAME"] = "NOM DU GROUPE"
L["Group Position"] = "Position du groupe"
L["Group Roster"] = "Liste des joueurs"
L["Group Settings"] = "Paramètres des groupes"
L["Group Spacing"] = "Espacement des groupes"
L["Group Visibility"] = "Visibilité des groupes"
L["Group X Offset"] = "Décalage X groupe"
L["Group Y Offset"] = "Décalage Y groupe"
L["Groups Grow From"] = "Les groupes croissent depuis"
L["Groups Per Column"] = "Groupes par colonne"
L["Groups Per Row"] = "Groupes par ligne"
L["Growth"] = "Croissance"
L["GROWTH"] = "CROISSANCE"
L["Growth Direction"] = "Direction de croissance"
L["GUI reset to default size, scale, and position."] = "UI réinitialisée (taille et position par défaut)."
L["Guided setup for configuring which buffs and debuffs appear on your frames."] = "Assistant pour pour configurer les auras sur vos cadres."
L["Guided setup for the frame border overlay that highlights boss debuffs."] = "Assistant pour la superposition de bordure (affaiblissements de boss)."
L["Handle Color"] = "Couleur de l'ancre"
L["Handle Height"] = "Hauteur de l'ancre"
L["Handle is invisible until you hover over it. Fades in and out smoothly."] = "L'ancre est invisible jusqu'au survol."
L["Handle Position"] = "Position de l'ancre"
L["Handle Width"] = "Largeur de l'ancre"
--[[Translation missing --]]
--[[ L[ [=[Having multiple click-casting addons enabled
may cause conflicts and unexpected behavior.

%sUse at your own risk!%s]=] ] = [=[Having multiple click-casting addons enabled
may cause conflicts and unexpected behavior.

%sUse at your own risk!%s]=]--]] 
L[ [=[Having multiple click-casting addons enabled
may cause conflicts and unexpected behavior.

%sUse at your own risk!%s]=] ] = [=[Avoir plusieurs addons de click-casting activés
peut causer des conflits et des comportements inattendus.

%sÀ utiliser en connaissance de cause!%s]=]
L["Having trouble with buffs or debuffs? Run the setup wizard for guided help."] = "Des problèmes avec les auras ? Lancez l'assistant."
L["Heal Absorb"] = "Absorption de soins"
L["Heal Prediction"] = "Prédiction de soins"
L["Heal Prediction Color"] = "Couleur de prédiction"
L["Healer"] = "Soigneur"
L["Healers"] = "Soigneurs"
L["Health"] = "Vie"
L["Health Bar"] = "Barre de vie"
L["Health Bar Alpha"] = "Opacité de la barre de vie"
L["Health Bar Color"] = "Couleur de la barre de vie"
L["Health Bar Texture"] = "Texture de la barre"
L["Health Deficit"] = "Déficit de vie"
L["Health Format"] = "Format de vie"
L["Health Gradient"] = "Dégradé de vie"
L["Health Text"] = "Texte de la vie"
L["Health Text Alpha"] = "Opacité du texte de vie"
L["Health Text Anchor"] = "Ancrage texte de vie"
L["Health Text Color"] = "Couleur texte de vie"
L["Health Threshold (%)"] = "Seuil de vie (%)"
L["Health Threshold Fading"] = "Estompage au seuil de vie"
L["Health X Offset"] = "Décalage X de vie"
L["Health Y Offset"] = "Décalage Y de vie"
L["Height"] = "Hauteur"
L["Height / Thickness"] = "Hauteur / Épaisseur"
L["Here's what we'll set up:"] = "Voici ce que nous allons régler :"
L["Hidden"] = "Caché"
L["Hide % Symbol"] = "Cacher le symbole %"
L["Hide Above (seconds)"] = "Cacher Au-dessus (secondes)"
L["Hide Above Threshold"] = "Cacher au-dessus du seuil"
L["Hide Blizzard Party Frames"] = "Masquer les cadres Blizzard de groupe"
L["Hide Blizzard Player Frame"] = "Masquer le cadre du joueur Blizzard"
L["Hide Blizzard Raid Frames"] = "Masquer les cadres de Raid Blizzard"
L["Hide buffs from the buff bar when they are already displayed by the Defensive Bar or Aura Designer."] = "Masquer les améliorations quand elles sont déjà visibles via le concepteur d'aura."
L["Hide Cooldown Swipe"] = "Masquer le lissage de temps de recharge"
L["Hide duplicate buffs"] = "Masquer les améliorations en double"
L["Hide Duration Above Threshold"] = "Masquer la durée pour >"
L["Hide Icon (Text Only)"] = "Masquer l'icône (Texte uni.)"
L["Hide in Combat"] = "Masquer en combat"
L["Hide raid buffs from buff bar"] = "Cacher les auras de raid de la barre"
L["Hide Self from Party Frames"] = "Masquer le joueur dans le groupe"
L["Hide specific buffs and debuffs from your frames. Click a spell to toggle blacklisting. Blacklisted auras will not appear on buff bars or Aura Designer indicators."] = "Cacher des auras spécifiques des cadres. Cliquez sur un sort pour l'ajouter à la liste noire."
L["Hide Tooltip on Mouseover"] = "Masquer au survol"
L["Hides Blizzard frames but keeps them active for aura filtering."] = "Masque les cadres Blizzard mais les garde pour le filtrage."
L["Hides the default Blizzard player portrait and health bar."] = "Masque la barre de vie et le cadre par défaut du joueur."
L["Hides the handle during combat. If disabled, the handle changes color to indicate it is locked."] = "Masque l'ancre en combat."
L["High"] = "Élevé"
L["High Health (100%)"] = "Vie haute (100%)"
L["High Threat (Yellow)"] = "Menace haute (Jaune)"
L["Higher values render the bar above other elements. Frame border is at level 10."] = "Dessine la barre au dessus des autres. (Bordure = 10)."
L["Highest Threat (Orange)"] = "Menace Max. (Orange)"
L["Highlight"] = "Surbrillance"
L["Highlight Color"] = "Couleurs surbrillance"
L["Highlight Dispellable"] = "Surbrillance des dissipables"
L["Highlight for User"] = "Surbrillance pour user"
L["Highlight for user to configure"] = "Surbrillance pour que l'utilisateur configure"
L["Highlight Important Spells"] = "Surbrillance Sorts Importants"
L["Highlight Settings"] = "Paramètres surbrillance"
L["Highlight Settings (comma-separated dbKeys)"] = "Paramètres (clés séparées par virgule)"
L["Highlight Style"] = "Style de surbrillance"
L["Highlighted Units"] = "Unités en surbr."
L["Highlights"] = "Surbrillances"
L["Highlights: %s"] = "Surbrillances : %s"
L["Horizontal"] = "Horizontal"
L["Horizontal anchors lay pips left-to-right. Left/Right anchors stack pips vertically along the frame side."] = "Ancrages horizontaux de gauche à droite."
L["Horizontal Spacing"] = "Espacement horizontal"
L["Horizontal: Players stack vertically, groups grow left-to-right."] = "Horizontal : Joueurs empilés, groupes gauche/droite."
L["Hostile Only"] = "Hostile"
L["Hover Highlight"] = "Surbrill. au survol"
L["Hover Settings"] = "Paramètres survol"
L["How it works"] = "Comment ça marche"
L["How often to check range (seconds). Lower = more responsive but higher CPU. Default: 0.5s"] = "Fréquence vérification portée. (Déf: 0.5s)."
L["How would you like to configure the filters?"] = "Comment configurer les filtres ?"
L["HP"] = "PV"
L["Hunter"] = "Chasseur"
L["I understand, enable it"] = "J'ai compris, l'activer"
L["I, II, III..."] = "I, II, III..."
L["Icon"] = "Icône"
L["Icon Height"] = "Hauteur d'icône"
L["Icon Offset X"] = "Décalage X d'Icône"
L["Icon Offset Y"] = "Décalage Y d'Icône"
L["Icon Opacity"] = "Opacité d'icône"
L["Icon Position"] = "Position d'icône"
L["Icon Ratio"] = "Ratio d'icône"
L["Icon Size"] = "Taille d'icône"
L["Icon size, scale & border"] = "Taille, ratio & bord"
L["Icon Spacing"] = "Espacement icône"
L["Icon Style"] = "Style icône"
L["Icon Width"] = "Largeur icône"
L["Icons"] = "Icônes"
L["Icons Alpha"] = "Opacité des icônes"
L["Icons Per Row"] = "Icônes / Ligne"
L["Ignore"] = "Ignorer"
L["Ignore Full Health Fade"] = "Ignorer l'estomp. full PV"
L["Import"] = "Importer"
L["Import All"] = "Tout Importer"
L["Import All (%d)"] = "Tout Importer (%d)"
L["Import Buffs Tab Defaults"] = "Import. tab Défaut amél."
L["Import Click Casting Profile"] = "Importer profil Click-Cast"
L["Import failed"] = "Échec d'importation"
L["Import from Buffs Tab"] = "Importer du Tab d'Améliorations"
L["Import Selected"] = "Importer sélection"
L["Import Settings"] = "Importer paramètres"
L["Import String"] = "Importer chaîne"
L["Import Wizard"] = "Assistant d'import"
L["Import WoW Macros"] = "Importer Macros WoW"
L["Import your existing Buffs tab settings as defaults for all auras. Compatible settings will be applied automatically."] = "Importe vos paramètres du tab 'Améliorations'."
L["Import/Export"] = "Import/Export"
L["Important Spells"] = "Sorts Importants"
L["Important Spells Only"] = "Sorts Impr. Uniqu."
L["Imported Profile"] = "Profil importé"
L["Imported!"] = "Importé !"
L["In Combat Only"] = "Combat Uni."
L["In Direct mode, all active big and external defensives are shown per unit (not just one). Adjust max count and layout on the Defensive Icon page."] = "Affiche les CDs défensifs actifs par unité."
L["Incompatible Bindings"] = "Raccourcis inc."
L["Indicators"] = "Indicateurs"
L["INFERRED TRACKING"] = "SUIVI SOUS-ENTENDU"
L["Info (All)"] = "Infos"
L["Inherit (Frame)"] = "Hériter (Cadre)"
L["Insanity"] = "Folie"
L["Inset"] = "Encart"
L["Inside (Bottom)"] = "À l'intérieur (Bas)"
L["Inside (Top)"] = "À l'intérieur (Haut)"
L["Instanced / PvP"] = "Instance / JcJ"
L["Integration"] = "Intégration"
L["Integration (advanced):"] = "Intégration (avancé) :"
L["Integrations"] = "Intégrations"
L["Interrupt Settings"] = "Options d'Interruption"
L["Interrupted Visual"] = "Visuel d'interruption"
L["is secret-tracked"] = "est suivi secrètement."
L["Items"] = "Objets"
L["Join a raid group (2-5 players works best)"] = "Rejoignez un groupe (2-5 jrs)"
L["Keep Buffs"] = "Garder les Améliorations"
L["Keep when offline/left"] = "Garder si hors ligne/quitté"
L["Label Color"] = "Couleur Étiquette"
L["Label Format"] = "Format d'Étiquette"
L["Label Name"] = "Nom Étiquette"
L["Label Position"] = "Posit. Étiquette"
L["Label:"] = "Étiquette :"
L["Last Unit"] = "Dernière Unité"
L["Layout"] = "Disposition"
L["Layout (Direct Mode)"] = "Disposition (Mode Direct)"
L["Layout Direction"] = "Direction de la disposition"
L["Layout Group"] = "Groupe de disposition"
L["Layout Groups"] = "Groupes de disposition"
L["Layout Mode"] = "Mode de disposition"
L["Layout Name"] = "Nom de la disposition"
L["Layout:"] = "Disposition :"
L["Leader Icon"] = "Icône de chef"
L["Left"] = "Gauche"
L["Left Click"] = "Clic Gauche"
L["Left Edge"] = "Bord Gauche"
L["Left of Health Bar"] = "À gauche de la barre de vie"
L["Left of Owner"] = "À gauche du joueur"
L["Left of Party"] = "À gauche du groupe"
L["Left of Raid"] = "À gauche du raid"
L["Left to Right"] = "Gauche à droite"
L["Left-click to add/edit binding"] = "Clic-gauche lier"
L["Left-click: Bind"] = "Clic-gauche lier"
L["Let Masque Control Aura Borders"] = "Laisser Masque gérer les Bordures d'Auras"
L["Let me configure it myself"] = "Je le configure"
L["Line"] = "Ligne"
L["Link: %s"] = "Lié : %s"
L["Linked Settings"] = "Paramètres liés"
L["List"] = "Liste"
L["Loading..."] = "Chargement..."
L["LOADOUT ASSIGNMENTS"] = "ATTRIBUTIONS D'ENSEMBLE"
L["Loadout expects: %s"] = "Ensemble attendu : %s"
L["Lock"] = "Verrouiller"
L["Lock Frames"] = "Verrouiller Cadres"
L["Lock Position"] = "Verrouiller Posi."
L["Log Viewer"] = "Log"
L["Loop Interval (sec)"] = "Fréq (sec)"
L["Low"] = "Bas"
L["Low Health (0%)"] = "0%"
L["Lunar Power"] = "Puissance Astrale"
L["Macro Options:"] = "Options Macro :"
L["Macro Text:"] = "Texte Macro :"
L["Macros"] = "Macros"
L["Mage"] = "Mage"
L["Magic"] = "Magique"
L["Major defensive cooldowns like Divine Shield, Ice Block, or Barkskin."] = "CD Défensifs majeurs comme Bouclier Divin, Bloc de Glace, etc."
L["Make icons click-through for external click-casting addons. Not needed for DF built-in click-casting."] = "Rendre les icônes non-cliquables pour les addons externes de click-casting. Pas nécessaire pour le click-casting intégré de DF."
L["Makes this binding work everywhere, consuming the keybind."] = "Faire fonctionner ce raccourci partout, le rendant indisponible pour les autres addons."
L["Mana"] = "Mana"
L["Manage"] = "Gérer"
L["Manage Profiles"] = "Gérer les Profils"
L["Marching Ants"] = "Fourmis"
L["Mark of the Wild (Druid)"] = "Marque du Fauve"
--[[Translation missing --]]
--[[ L[ [=[Masque addon is not installed.

Masque allows you to skin buff/debuff icons with custom textures. Install Masque from CurseForge to enable.]=] ] = [=[Masque addon is not installed.

Masque allows you to skin buff/debuff icons with custom textures. Install Masque from CurseForge to enable.]=]--]] 
L[ [=[Masque addon is not installed.

Masque allows you to skin buff/debuff icons with custom textures. Install Masque from CurseForge to enable.]=] ] = [=[L'addon Masque n'est pas installé.

Masque permet de styliser les icônes de buffs/debuffs avec des textures personnalisées. Installez Masque depuis CurseForge pour activer.]=]
L["Masque Integration"] = "Masque Intro."
L["Match Frame Height"] = "Ajust. Hauteur"
L["Match Frame Width"] = "Ajust. Largeur"
L["Match Health Bar Width/Height"] = "Ajust. PV"
L["Match Owner Height"] = "Ajust. Proprio H"
L["Match Owner Width"] = "Ajust. Proprio W"
L["Matched (not applied)"] = "Correspondance trouvée (non appliquée)"
L["Max Buffs"] = "Améliorations max"
L["Max Debuffs"] = "Affaiblissements max"
L["Max Health"] = "PV Max"
L["Max Icons"] = "Max Icônes"
L["Max Length (0=off)"] = "L. Max (0=off)"
L["Max Log Entries"] = "Entrées. Max"
L["Max Name Length"] = "L. Max Nom"
L["Max Slots"] = "Max"
L["Medium"] = "Moyen"
L["Medium Health (50%)"] = "50%"
--[[Translation missing --]]
--[[ L["Melee DPS"] = "Melee DPS"--]] 
L["MEMBERS"] = "MEMBRES"
L["Min Stacks to Show"] = "Min. Piles avant affich."
L["Minimum Log Level"] = "Min. Niveau"
L["Missing Buff Alpha"] = "Opacité des buffs manquants"
L["Missing Buffs"] = "Amélio manquantes"
L["Missing Health"] = "Vie manquante"
L["Missing Health Alpha"] = "Opacité des PV manquants"
L["Missing Health Color"] = "Couleur des PV manquants"
L["Missing Health Only"] = "PV manquants uniquement"
L["Missing Health Texture"] = "Texture PV"
L["Mode"] = "Mode"
L["Modified"] = "Modifié"
L["Monk"] = "Moine"
L["Monochrome"] = "Monochrome"
L["Moves the glow to the opposite side (no HP side instead of max HP side)."] = "Déplace lueur sur l'autre extrem."
L["Multi Select"] = "Choix Multi"
L["My Group First"] = "MonGrp 1"
L["My Wizards"] = "Mes assistants"
L["Mythic"] = "Mythique"
L["Mythic has fixed range"] = "Mythique a un max fixe"
L["Name"] = "Nom"
L["Name Alpha"] = "Opacité"
L["Name already exists"] = "Ce nom existe déjà"
L["Name Anchor"] = "Ancre du nom"
L["Name Color"] = "Couleur du nom"
L["Name Text"] = "Texte du nom"
L["Name Text Alpha"] = "Opacité du nom"
L["Name Text Color"] = "Couleur du nom"
L["Name X Offset"] = "X"
L["Name Y Offset"] = "Y"
L["Name:"] = "Nom :"
L["New"] = "Nouveau"
L["New Binding"] = "Nouveau Raccourci"
L["New Feature: Frame Border Overlay"] = "Nouvelle fonctionnalité : Superposition de bordure"
L["New Option"] = "Nouvelle Option"
L["New question"] = "Nouvelle question"
L["Next"] = "Suivant"
L["No"] = "Non"
L["No %s effects configured."] = "Aucun effet de %s configuré."
L["No action selected"] = "Aucune action sélectionnée"
L["No auto-profile is currently active or being edited."] = "Aucun profil automatique n'est actif ou en cours d'édition."
L["no branch"] = "no branch"
L["No built-in wizards available yet. Check back after updates!"] = "Aucun assistant intégré disponible. Revenez plus tard !"
L["No changelog available."] = "Aucune note de mise à jour disponible."
L["No custom wizards yet. Click 'New Wizard' to create one!"] = "Aucun assistant personnalisé. Cliquez sur 'Nouvel assistant' pour en créer un !"
L["No data to export"] = "Aucune donnée à exporter"
L["No default profile set"] = "Aucun profil par défaut défini"
--[[Translation missing --]]
--[[ L[ [=[No effects configured yet.
Click '+ Add Indicator' to get started.]=] ] = [=[No effects configured yet.
Click '+ Add Indicator' to get started.]=]--]] 
L[ [=[No effects configured yet.
Click '+ Add Indicator' to get started.]=] ] = "Aucun effet configuré. Cliquez sur '+ Ajouter un indicateur' pour commencer."
L["No item equipped"] = "Aucun objet équipé"
--[[Translation missing --]]
--[[ L[ [=[No layout groups created yet.
Click '+ Create Group' to get started.]=] ] = [=[No layout groups created yet.
Click '+ Create Group' to get started.]=]--]] 
L[ [=[No layout groups created yet.
Click '+ Create Group' to get started.]=] ] = "Aucun groupe de disposition créé. Cliquez sur '+ Créer un groupe' pour commencer."
L["No layout set. Using global settings."] = "Aucune disposition définie. Utilisation des paramètres globaux."
L["No loadout detected"] = "Aucun chargement détecté"
L["No macros match the current filter."] = "Aucune macro ne correspond au filtre actuel."
--[[Translation missing --]]
--[[ L[ [=[No macros yet.
Click '+ New' to create one or 'Import' to import from WoW.]=] ] = [=[No macros yet.
Click '+ New' to create one or 'Import' to import from WoW.]=]--]] 
L[ [=[No macros yet.
Click '+ New' to create one or 'Import' to import from WoW.]=] ] = "Aucune macro. Cliquez sur '+ Nouveau' pour en créer une ou 'Importer' pour en importer depuis WoW."
L["No members yet"] = "Pas encore de membres"
L["No saved position to reset to."] = "Aucune position enregistrée à réinitialiser."
L["No sound file selected. Choose a sound from the dropdown or enter a custom path."] = "Aucun fichier son sélectionné. Choisissez un son dans la liste déroulante ou entrez un chemin personnalisé."
L["No spells available for this class"] = "Aucun sort disponible pour cette classe"
L["No thanks"] = "Non merci"
L["No wizard selected. Go to 'My Wizards' tab to select or create a wizard first."] = "Aucun assistant sélectionné. Accédez à l'onglet « Mes assistants » pour sélectionner ou créer d'abord un assistant."
L["None"] = "Aucun"
L["None (no clamping)"] = "Aucun (pas de serrage)"
L["None / Physical"] = "Aucun / Physique"
L["None active (using global settings)"] = "Aucun actif (en utilisant les paramètres globaux)"
L["Normal (BLEND)"] = "Normal (MÉLANGE)"
L["Not Cancelable"] = "Non annulable"
L["Not in a raid group"] = "Pas dans un groupe de raid"
L["Not Set"] = "Non défini"
L["Note: Cmd + Left Click unavailable on Mac"] = "Remarque : Cmd + clic gauche indisponible sur Mac"
L["Note: Font sizes are not changed. Adjust sizes in each element's page."] = "Remarque : Les tailles de police ne sont pas modifiées. Ajustez les tailles dans la page de chaque élément."
L["Notice"] = "Avis"
L["Off"] = "Désactivé"
L["Offset X"] = "Décalage X"
L["Offset Y"] = "Décalage Y"
L["OK"] = "OK"
L["Only changed settings will be saved"] = "Seuls les paramètres modifiés seront enregistrés"
L["Only Dispellable Debuffs"] = "Uniquement les débuffs dispersables"
L["Only My Buffs"] = "Seulement mes buffs"
L["Only show buffs that you cast. Applies to all buff filters."] = "Affichez uniquement les buffs que vous lancez. S'applique à tous les filtres buff."
L["Only Show When Tanking"] = "Afficher uniquement lors du tanking"
--[[Translation missing --]]
--[[ L[ [=[Only the active layout can be edited
while auto layouts are running.]=] ] = [=[Only the active layout can be edited
while auto layouts are running.]=]--]] 
L[ [=[Only the active layout can be edited
while auto layouts are running.]=] ] = "Seule la disposition active peut être modifiée pendant l'exécution des dispositions automatiques."
L["OOC"] = "HDC"
L["Open Aura Designer"] = "Concepteur d'aura ouvert"
L["Open Cast History"] = "Historique de diffusion ouverte"
--[[Translation missing --]]
--[[ L["Open Settings"] = "Open Settings"--]] 
L["Open Settings Tab"] = "Ouvrir l'onglet Paramètres"
L["Open the Profiles tab to manage profiles"] = "Ouvrez l'onglet Profils pour gérer les profils"
L["Open Unit Menu"] = "Ouvrir le menu de l'unité"
L["Open World"] = "Monde ouvert"
L["Opens tab: %s"] = "Ouvre l'onglet : %s"
L["Option A"] = "Option A"
L["Option B"] = "Option B"
L["Options"] = "Options"
L["Options:    [S] = Link Setting    [->] = Branch    [x] = Delete"] = "Options : [S] = Paramètres de lien [->] = Branche [x] = Supprimer"
L["Or enter Icon ID:"] = "Ou entrez l'ID de l'icône :"
L["Orientation"] = "Orientation"
L["Other"] = "Autre"
L["Other (%d)"] = "Autre (%d)"
L["Other Frames"] = "Autres cadres"
L["Out of combat"] = "Hors combat"
L["Out of Combat Only"] = "Hors combat uniquement"
L["Out of Range"] = "Hors de portée"
L["Outline"] = "Contour"
L["Overlaps with \"%s\""] = "Chevauche avec \"%s\""
L["Overlaps with \"%s\" (%d-%d)"] = "Chevauche avec \"%s\" (%d-%d)"
L["Overlay (on health bar)"] = "Superposition (sur la barre de vie)"
L["Overridden by Auto Layout"] = "Remplacé par la mise en page automatique"
L["Overridden in this layout"] = "Remplacé dans cette mise en page"
L["Override Details"] = "Remplacer les détails"
L["Owner's Class Color"] = "Couleur de la classe du joueur"
L["Paladin"] = "Paladin"
L["Parse String"] = "Analyser la chaîne"
L["Party"] = "Groupe"
L["PARTY"] = "GROUPE"
--[[Translation missing --]]
--[[ L[ [=[Party & Raid %s settings are synced.
Click to stop syncing.]=] ] = [=[Party & Raid %s settings are synced.
Click to stop syncing.]=]--]] 
L[ [=[Party & Raid %s settings are synced.
Click to stop syncing.]=] ] = [=[Les paramètres du groupe et du raid %s sont synchronisés.
Cliquez pour arrêter la synchronisation.]=]
L["Party to Raid"] = "Groupe au raid"
L["Party: %s"] = "Groupe : %s"
L["Paste a profile string to import:"] = "Collez une chaîne de profil à importer :"
L["Paste the wizard export string below:"] = "Collez la chaîne d'exportation de l'assistant ci-dessous :"
L["Pattern:"] = "Modèle:"
L["Per-aura overrides"] = "Remplacements par aura"
L["Percent"] = "Pour cent"
L["Percentage"] = "Pourcentage"
L["Permanent Mover"] = "Ancre de déplacement permanente"
L["Per-setting reset is not available for Aura Designer"] = "La réinitialisation par paramètre n'est pas disponible pour Aura Designer"
L["Persist (sec)"] = "Persister (sec)"
L["Personal Targeted"] = "Ciblé personnel"
L["Personal Targeted Spells"] = "Sorts ciblés personnels"
L["Pet Frame Settings"] = "Paramètres du cadre pour familiers"
L["Pet Frames"] = "Cadres pour familiers"
L["Pet frames are grouped together in a separate container."] = "Les cadres pour familiers sont regroupés dans un groupe séparé."
L["Pet frames are positioned relative to their owner's frame."] = "Les cadres des familiers sont positionnés par rapport au cadre de leur joueur."
L["Pet Spacing"] = "Espacement des familiers"
L["Phased"] = "Par étapes"
L["Phased Icon"] = "Icône de phase"
L["Picked setting: %s%s%s from tab %s%s%s"] = "Paramètre sélectionné : %s%s%s dans l'onglet %s%s%s"
L["Pinned Frames"] = "Cadres épinglés"
L["Pip Color"] = "Couleur des points de ressources"
L["Pip Height"] = "Hauteur des points de ressources"
L["Pixel-Perfect Scaling"] = "Mise à l'échelle parfaite au pixel près"
L["Place %s at %s"] = "Placer %s à %s"
L["Placed"] = "Mis"
L["PLACED ON FRAME"] = "PLACÉ SUR CADRE"
L["PLACEMENT"] = "PLACEMENT"
L["Player Range"] = "Portée des joueurs"
L["Players Grow From"] = "Les joueurs grandissent à partir de"
L["Players Per Column"] = "Joueurs par colonne"
L["Players Per Row"] = "Joueurs par rangée"
L["Please enter a profile name."] = "Veuillez saisir un nom de profil."
L["Please select an action!"] = "Veuillez sélectionner une action !"
L["Poison"] = "Poison"
L["Position"] = "Position"
L["Position & anchors"] = "Positionnement et ancrages"
L["Position managed by: %s"] = "Poste géré par : %s"
L["Position reset."] = "Réinitialisation de la position."
L["Power Bar Alpha"] = "Opacité de la barre de ressource"
L["Power Word: Fortitude (Priest)"] = "Mot de pouvoir : Courage (Prêtre)"
L["Pre-configure players before they join the group"] = "Préconfigurer les joueurs avant qu'ils rejoignent le groupe"
--[[Translation missing --]]
--[[ L[ [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=] ] = [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=]--]] 
L[ [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=] ] = [=[Appuyez sur n'importe quelle touche, bouton de souris ou molette
(avec modificateurs si désiré)]=]
L["Press Ctrl+A to select all, then Ctrl+C to copy"] = "Appuyez sur Ctrl+A pour tout sélectionner, puis sur Ctrl+C pour copier"
L["Press Ctrl+C to copy, then Escape to close"] = "Appuyez sur Ctrl+C pour copier, puis sur Échap pour fermer"
L["Press key/click/scroll..."] = "Appuyez sur la touche/cliquez/faites défiler..."
L["Preview"] = "Aperçu"
L["Preview Scale"] = "Échelle d'aperçu"
L["Preview Sound"] = "Aperçu du son"
L["Preview:"] = "Aperçu :"
L["Priest"] = "Prêtre"
L["Priority"] = "Priorité"
L["Priority:"] = "Priorité:"
L["Private Aura Overlay Setup"] = "Configuration de la superposition d'aura privée"
L["Profile \"%s\" has no overrides."] = "Le profil \"%s\" n'a aucun remplacement."
L["Profile '%s' already exists."] = "Le profil '%s' existe déjà."
L["Profile Actions"] = "Actions de profil"
L["Profile imported successfully!"] = "Profil importé avec succès !"
L["Profile matched to loadout"] = "Profil adapté à l'ensemble"
L["Profile Name"] = "Nom du profil"
L["Profile not found"] = "Profil introuvable"
L["Profile Settings"] = "Paramètres du profil"
L["Profile:"] = "Profil:"
L["Profile: %s"] = "Profil : %s"
--[[Translation missing --]]
--[[ L[ [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=] ] = [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=]--]] 
L[ [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=] ] = [=[Profil : %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=]
L["Profiles"] = "Profils"
--[[Translation missing --]]
--[[ L["Pull Timer"] = "Pull Timer"--]] 
L["Pull Timer Duration"] = "Durée du minuteur du Pull Timer"
L["Pulsate"] = "Palpiter"
L["Pulsate Border"] = "Pulsation de la bordure"
L["Pulse"] = "Impulsion"
L["Pulse Animation"] = "Animation par impulsions"
L["Question"] = "Question"
L["Question:"] = "Question:"
L["Quick Bind"] = "Liaison rapide"
L["Quick Bind Mode"] = "Mode de liaison rapide"
L["Quick Macro"] = "Macro rapide"
L["Quick Macro Builder"] = "Générateur de macros rapide"
--[[Translation missing --]]
--[[ L["Quick Switch CC Profile"] = "Quick Switch CC Profile"--]] 
--[[Translation missing --]]
--[[ L["Quick Switch Profile"] = "Quick Switch Profile"--]] 
L["Rage"] = "Rage"
L["Raid"] = "Raid"
L["RAID"] = "RAID"
L["Raid Auto Layouts"] = "Dispositions automatiques de raid"
L["Raid Buffs"] = "Buffs de raid"
L["Raid Debuffs"] = "Affaiblissements de raid"
L["Raid frames centered."] = "Cadres de raid centrés."
L["Raid Group Labels"] = "Étiquettes de groupe de raid"
L["Raid In Combat"] = "Raid au combat"
L["Raid Layout Mode"] = "Mode de mise en page de raid"
L["Raid position reset."] = "Réinitialisation de la position du raid."
L["Raid Role (MT/MA)"] = "Rôle de raid (MT/MA)"
L["Raid Role Icon (MT/MA)"] = "Icône de rôle de raid (MT/MA)"
L["Raid Target Icon"] = "Icône de cible de raid"
L["Raid to Party"] = "Raid vers groupe"
L["Raid: %s"] = "Raid : %s"
--[[Translation missing --]]
--[[ L[ [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=] ] = [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=]--]] 
L[ [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=] ] = [=[Raid: La disposition de groupe trie à l'intérieur de chaque groupe.
La disposition en grille trie tous les joueurs ensemble.]=]
L["Raids"] = "Raids"
L["Raids, battlegrounds (1-40)"] = "Raids, champs de bataille (1-40)"
L["Range Check Interval"] = "Intervalle de vérification de la portée"
L["Range Check Spell"] = "Sort de vérification de portée"
--[[Translation missing --]]
--[[ L["Ranged DPS"] = "Ranged DPS"--]] 
--[[Translation missing --]]
--[[ L["Ready Check"] = "Ready Check"--]] 
L["Ready Check Icon"] = "Icône de préparation"
L["Ready to copy"] = "Prêt à copier"
L["Recovered %d raid settings from interrupted auto layout editing session."] = "%d paramètres de raid récupérés suite à une session d'édition automatique de mise en page interrompue."
L["Refresh"] = "Rafraîchir"
--[[Translation missing --]]
--[[ L["Reload UI"] = "Reload UI"--]] 
L["Remove all bindings from the current profile."] = "Supprimez toutes les liaisons du profil actuel."
L["Remove Offline"] = "Supprimer hors ligne"
L["Removes all Aura Designer overrides from this auto layout, restoring it to match your global profile."] = "Supprime tous les remplacements d'Aura Designer de cette disposition automatique, en la restaurant pour qu'elle corresponde à votre profil global."
L["Removes your player frame from the DandersFrames party display."] = "Supprime le cadre de votre joueur de l'affichage du groupe DandersFrames."
L["Rename"] = "Rebaptiser"
L["Replace"] = "Remplacer"
L["Replace Blizzard's color picker with the DandersFrames color picker for this addon."] = "Remplacez le sélecteur de couleurs de Blizzard par le sélecteur de couleurs DandersFrames pour cet addon."
L["Replace Buffs"] = "Remplacer les buffs"
L["Res + Mass"] = "Rés + Masse"
L["Res + Mass + Combat"] = "Rés + Masse + Combat"
L["Reset"] = "Réinitialiser"
L["Reset All Aura Configs"] = "Réinitialiser toutes les configurations Aura"
--[[Translation missing --]]
--[[ L[ [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=] ] = [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=]--]] 
L[ [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=] ] = [=[Réinitialiser tous les paramètres du Concepteur d'auras de cette mise en page automatique pour qu'ils correspondent à votre profil global ?

Cette action ne peut pas être annulée.]=]
--[[Translation missing --]]
--[[ L[ [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=] ] = [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=]--]] 
L[ [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=] ] = [=[Réinitialiser tous les raccourcis aux valeurs par défaut ?

Ceci définira :
• Clic gauche = Cibler l'unité
• Clic droit = Ouvrir le menu

%sCette action ne peut pas être annulée.%s]=]
L["Reset All to Default"] = "Réinitialiser tout par défaut"
L["Reset Aura Designer to Global"] = "Réinitialiser Aura Designer sur Global"
--[[Translation missing --]]
--[[ L[ [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=] ] = [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=]--]] 
L[ [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=] ] = [=[Réinitialiser le profil actuel aux valeurs par défaut ?
Cela réinitialisera les paramètres du groupe ET du raid.]=]
L["Reset Position"] = "Réinitialiser la position"
L["Reset Profile to Defaults"] = "Réinitialiser le profil aux valeurs par défaut"
L["Reset to Defaults"] = "Réinitialiser aux valeurs par défaut"
L["Reset to Global"] = "Réinitialiser à Global"
L["Reset to Global Order"] = "Réinitialiser à l'ordre global"
L["Resource Bar"] = "Barre de ressources"
L["Resource Bar Settings"] = "Paramètres de la barre de ressources"
L["Resource Colors"] = "Couleurs des ressources"
L["Rested Indicator"] = "Indicateur de repos"
L["Resurrection"] = "Résurrection"
L["Resurrection Icon"] = "Icône de résurrection"
L["Resurrection Icon Tooltips"] = "Info-bulles de l'icône de résurrection"
L["Reverse Fill"] = "Remplissage inversé"
L["Reverse Fill Direction"] = "Sens de remplissage inversé"
L["Reverse Order"] = "Ordre inversé"
L["Reverse Overlay Fill"] = "Remplissage par superposition inversée"
L["Reverse Position"] = "Position inversée"
L["Right"] = "Droite"
L["Right Click"] = "Clic droit"
L["Right Edge"] = "Bord droit"
L["Right of Health Bar"] = "À droite de la barre de vie"
L["Right of Owner"] = "À droite du joueur"
L["Right of Party"] = "À droite du groupe"
L["Right of Raid"] = "À droite du raid"
L["Right to Left"] = "De droite à gauche"
L["Right-click"] = "Clic droit"
L["Right-click: Edit/View"] = "Clic droit : Modifier/Afficher"
L["Rogue"] = "Voleur"
L["Role Icon"] = "Icône de rôle"
L["Role Priority"] = "Priorité de rôle"
L["Row Spacing"] = "Espacement des rangées"
L["Rows"] = "Lignes"
L["Rows Grow From"] = "Les lignes s'agrandissent à partir de"
L["Run"] = "Courir"
L["Run Overlay Setup Wizard"] = "Exécuter l'assistant de configuration de superposition"
L["Run Script"] = "Exécuter le script"
L["Run Setup Wizard"] = "Exécuter l'assistant d'installation"
L["Runic Power"] = "Pouvoir runique"
L["Runtime"] = "Durée d'exécution"
L["Save"] = "Sauvegarder"
L["Save & Close"] = "Enregistrer et fermer"
L["Save Changes"] = "Enregistrer les modifications"
L["Scale"] = "Échelle"
L["Script Runner"] = "Exécuteur de script"
L["Search fonts..."] = "Rechercher des polices..."
L["Search sounds..."] = "Rechercher des sons..."
L["Search spells..."] = "Rechercher des sorts..."
L["Search textures..."] = "Rechercher des textures..."
L["Search..."] = "Recherche..."
L["Seconds"] = "Secondes"
L["See Also:"] = "Voir aussi :"
L["Select a destination"] = "Sélectionnez une destination"
L["Select a spell"] = "Sélectionnez un sort"
L["Select a step to edit"] = "Sélectionnez une étape à modifier"
L["Select All Text"] = "Sélectionner tout le texte"
L["Select any tab"] = "Sélectionnez n'importe quel onglet"
L["Select Class"] = "Sélectionnez une classe"
L["Select indicator..."] = "Sélectionnez l'indicateur..."
L["Select or create a wizard"] = "Sélectionner ou créer un assistant"
L["Select trigger for %s"] = "Sélectionnez le déclencheur pour %s"
L["Select which spell to use for range checking. Auto will use your spec's default healing/friendly spell."] = "Sélectionnez le sort à utiliser pour la vérification de la portée. Auto utilisera le sort de guérison/ami par défaut de votre spécialisation."
L["Select..."] = "Sélectionner..."
L["Selected: %d"] = "Sélectionné : %d"
--[[Translation missing --]]
--[[ L[ [=[Selecting an option will disable the other addon(s)
and reload your UI.]=] ] = [=[Selecting an option will disable the other addon(s)
and reload your UI.]=]--]] 
L[ [=[Selecting an option will disable the other addon(s)
and reload your UI.]=] ] = "La sélection d'une option désactivera les autre(s) addon(s) et rechargera votre interface."
L["Selection Highlight"] = "Surbrillance de la sélection"
L["Selection Settings"] = "Paramètres de sélection"
L["Self Position"] = "Position personnelle"
L["Separate Melee & Ranged DPS"] = "DPS séparés (Mêlée / Distance)"
L["Separate Pet Group"] = "Groupe des familiers séparé"
L["Set a font and outline style, then click Apply to update ALL text elements."] = "Définissez une police et un style de contour, puis cliquez sur Appliquer pour mettre à jour TOUS les éléments de texte."
--[[Translation missing --]]
--[[ L[ [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=] ] = [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=] ] = [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=]--]] 
L[ [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=] ] = [=[Paramètre : %s
Valeur actuelle : %s

Entrez la valeur à définir, ou mettez en surbrillance pour l'utilisateur.]=]
L[ [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=] ] = [=[Paramètre : %s
Valeur actuelle : %s

Que doit-il se passer lorsque '%s' est sélectionné ?]=]
L["Settings"] = "Paramètres"
L["Settings to Apply"] = "Paramètres à appliquer"
L["Setup Wizards"] = "Assistants de configuration"
L["Shadow"] = "Ombre"
L["Shadow Color"] = "Couleur de l'ombre"
L["Shadow Settings"] = "Paramètres d'ombre"
L["Shadow settings are controlled in General > Global Fonts."] = "Les paramètres d'ombre sont contrôlés dans Général > Polices globales."
L["Shadow X Offset"] = "Décalage ombre X"
L["Shadow Y Offset"] = "Décalage ombre Y"
L["Shaman"] = "Chaman"
L["Shared"] = "Commun"
L["Shared Border"] = "Bordure partagée"
L["Shift+Left Click"] = "Maj+Clic gauche"
L["Shift+Right Click"] = "Maj+Clic droit"
L["Show a pulsing yellow glow around the frame."] = "Affichez une lueur jaune pulsée autour du cadre."
L["Show All Roles Out of Combat"] = "Afficher tous les rôles hors combat"
L["Show as Text"] = "Afficher sous forme de texte"
L["Show Background"] = "Afficher l'arrière-plan"
L["Show Border"] = "Afficher la bordure"
L["Show Buffs"] = "Afficher les améliorations"
L["Show Cooldown Swipe"] = "Afficher le balayage du temps de recharge"
L["Show Debuffs"] = "Afficher les affaiblissements"
L["Show Dispel Icon"] = "Afficher l'icône de dissipation"
L["Show DPS"] = "Afficher le DPS"
L["Show Duration"] = "Afficher la durée"
L["Show Duration Numbers"] = "Afficher les numéros de durée"
L["Show Duration Text"] = "Afficher le texte de durée"
L["Show every buff with no filtering."] = "Affichez tous les buffs sans filtrage."
L["Show every debuff with no filtering."] = "Afficher chaque débuff sans filtrage."
L["Show Expiring Border"] = "Afficher la bordure expirante"
L["Show Expiring Tint"] = "Afficher la teinte expirée"
L["Show for Roles"] = "Afficher pour les rôles"
L["Show Frame Border"] = "Afficher la bordure du cadre"
L["Show Gradient"] = "Afficher le dégradé"
L["Show Group Label"] = "Afficher l'étiquette du groupe"
L["Show Healer"] = "Afficher le guérisseur"
L["Show health bars for player and party/raid member pets, anchored to their owner's frame. Pet frames hide when owner dies."] = "Afficher les barres de vie des joueurs et des familiers des membres du groupe/raid, ancrées au cadre du joueur. Les cadres des familiers se cachent lorsque le joueur meurt."
L["Show Health Percentage"] = "Afficher le pourcentage de vie"
L["Show in content types:"] = "Afficher dans les types de contenu :"
L["Show in Solo Mode"] = "Afficher en mode Solo"
L["Show Interrupted Visual"] = "Afficher le visuel d'interruption"
L["Show Label"] = "Afficher l'étiquette"
L["Show LFG Eye for Cross-Instance"] = "Afficher LFG Eye pour plusieurs instances"
L["Show Main Assist"] = "Afficher l'assistance principale"
L["Show Main Tank"] = "Afficher le réservoir principal"
L["Show Minimap Button"] = "Afficher le bouton de la mini-carte"
L["Show On Current Health Only"] = "Afficher uniquement sur la vie actuelle"
L["Show on Hover Only"] = "Afficher au survol uniquement"
L["Show Overheal"] = "Afficher les soins excédentaires"
L["Show Overlay For"] = "Afficher la superposition pour"
L["Show Overshield Glow"] = "Afficher la lueur du bouclier supérieur"
L["Show Party/Raid Side Menu"] = "Afficher le menu latéral Groupe/Raid"
L["Show rested indicators when in a rested area (inn, city)."] = "Afficher les indicateurs de repos lorsque vous vous trouvez dans une zone de repos (auberge, ville)."
L["Show Shadow"] = "Afficher l'ombre"
L["Show Stacks"] = "Afficher les piles"
L["Show Tank"] = "Afficher le réservoir"
L["Show the animated ZZZ icon on the player frame."] = "Afficher l'icône ZZZ animée sur le cadre du lecteur."
L["Show the DF color picker when any addon opens a color picker."] = "Afficher le sélecteur de couleurs de DF lorsqu'un module complémentaire ouvre un sélecteur de couleurs."
L["Show Timer"] = "Afficher la minuterie"
L["Show When Missing"] = "Afficher en cas d'absence"
L["Show X Mark"] = "Afficher la marque X"
L["Show:"] = "Montrer:"
L["Shows a border ring around the entire frame when a boss debuff is active."] = "Affiche un anneau de bordure autour de tout le cadre lorsqu'un débuff de boss est actif."
L["Shows a colored border/glow when a dispellable debuff is present."] = "Affiche une bordure/lueur colorée lorsqu'un débuff dispersable est présent."
L["Shows a glow at max health when absorb exceeds the clamp limit."] = "Affiche une lueur lorsque les PV sont au max et que l'absorption dépasse la limite."
L["Shows an icon when an enemy is casting a spell targeting a party/raid member."] = "Affiche une icône lorsqu'un ennemi lance un sort ciblant un membre du groupe/raid."
L["Shows an icon when party members have a defensive cooldown active (Pain Suppression, Ironbark, etc.)."] = "Affiche une icône lorsque les membres du groupe ont un sort de protection actif (Suppression de la douleur, Écorce de fer, etc.)."
L["Shows effects that reduce incoming healing (like Necrotic stacks)."] = "Affiche les effets qui réduisent les soins reçus (comme les cumuls nécrotiques)."
L["Shows icon when party members are missing raid buffs."] = "Affiche l'icône lorsque les membres du groupe manquent de buffs de raid."
L["Shows incoming targeted spells on YOU in the center of your screen."] = "Affiche les sorts vous ciblant au centre de votre écran."
L["Shows the ping wheel & party management menu."] = "Affiche la roue de ping et le menu de gestion des groupes."
L["Single Select"] = "Sélection unique"
L["Size"] = "Taille"
L["Size & Orientation"] = "Taille et orientation"
L["Size & Spacing"] = "Taille et espacement"
L["Skip for now"] = "Passer pour l'instant"
L["Skyfury (Shaman)"] = "Furieciel (Chaman)"
L["Smart Res:"] = "Résolution intelligente :"
L["Smart Resurrection"] = "Résurrection intelligente"
L["Smooth Bar Animation"] = "Animation de barre fluide"
L["Snaps sizes and borders to exact pixels for crisp rendering."] = "Aligne les tailles et les bordures aux pixels exacts pour un rendu net."
L["Solid (BLEND)"] = "Solide (MÉLANGE)"
L["Solid Border"] = "Bordure solide"
L["Solo Mode"] = "Mode Solo"
L["Solo mode %s"] = "Mode solo %s"
L["Solo Mode: Show your player frame when not in a group."] = "Mode Solo : affichez le cadre de votre joueur lorsqu'il n'est pas en groupe."
--[[Translation missing --]]
--[[ L[ [=[Some bindings use spells that are not available
to your current class or specialization.]=] ] = [=[Some bindings use spells that are not available
to your current class or specialization.]=]--]] 
L[ [=[Some bindings use spells that are not available
to your current class or specialization.]=] ] = [=[Certains raccourcis utilisent des sorts qui ne sont pas disponibles
pour votre classe ou spécialisation actuelle.]=]
L["Sort by Class (within role)"] = "Trier par classe (au sein du rôle)"
L["Sort Order"] = "Ordre de tri"
--[[Translation missing --]]
--[[ L[ [=[Sort party members by role, class, and name.

Sort order: Self Position > Role > Class > Name]=] ] = [=[Sort party members by role, class, and name.

Sort order: Self Position > Role > Class > Name]=]--]] 
L[ [=[Sort party members by role, class, and name.

Sort order: Self Position > Role > Class > Name]=] ] = [=[Trier les membres du groupe par rôle, classe et nom.

Ordre de tri : Joueur > Rôle > Classe > Nom]=]
L["Sorted with Group"] = "Trié par groupe"
L["Sorting"] = "Tri"
L["Sound"] = "Son"
L["Sound Alert"] = "Alerte sonore"
L["Sound Alerts"] = "Alertes sonores"
L["Sound file could not be played: %s"] = "Le fichier son n'a pas pu être lu : %s"
L["Source Mode"] = "Mode source"
L["Spacing"] = "Espacement"
L["Spacing X"] = "Espacement X"
L["Spacing Y"] = "Espacement Y"
L["Spark"] = "Lueur"
L["Spec Default"] = "Spécialisation par défaut"
L["Spec:"] = "Spécialisation :"
L["Specialization data not available."] = "Données de spécialisation non disponibles."
L["Spell:"] = "Épeler:"
L["Spells"] = "Sorts"
L["Spells flagged as important by Blizzard."] = "Sorts signalés comme importants par Blizzard."
L["Square"] = "Carré"
L["Stack Anchor"] = "Ancre de pile"
L["Stack Count"] = "Compteur de pile"
L["Stack Font"] = "Police de pile"
L["Stack Minimum"] = "Minimum de pile"
L["Stack Offset X"] = "Décalage de pile X"
L["Stack Offset Y"] = "Décalage de pile Y"
L["Stack Outline"] = "Aperçu de la pile"
L["Stack Scale"] = "Échelle de pile"
L["Stack Text"] = "Texte de pile"
L["Stack Text Color"] = "Couleur du texte de la pile"
L["Standard Buffs are also visible on frames."] = "Les buffs standards sont également visibles sur les cadres d'unités."
L["START"] = "COMMENCER"
L["Start"] = "Commencer"
L["Start (Left/Top)"] = "Début (Gauche/Haut)"
L["Start = Left/Top, End = Right/Bottom depending on direction."] = "Début = Gauche/Haut, Fin = Droite/Bas selon la direction."
L["Start Delay (sec)"] = "Délai de démarrage (sec)"
L["Start of Group"] = "Début du groupe"
--[[Translation missing --]]
--[[ L[ [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=] ] = [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=]--]] 
L[ [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=] ] = [=[Début : au-dessus/à gauche des groupes.
Centre : au milieu du groupe.
Fin : en dessous/à droite des groupes.]=]
L["Status Icon Text Settings"] = "Paramètres de texte de l'icône d'état"
L["Status Text"] = "Texte d'état"
L["Status Text (Dead/Offline)"] = "Texte d'état (mort/hors ligne)"
L["Status Text Alpha"] = "Opacité du texte d'état"
L["Step %d of %d"] = "Étape %d sur %d"
L["Step 1: Click here with desired key combo"] = "Étape 1 : Cliquez ici avec la combinaison de touches souhaitée"
L["Step 2: Select Action"] = "Étape 2 : Sélectionnez une action"
L["Step 3: Combat Condition (optional)"] = "Étape 3 : Condition de combat (facultatif)"
L["Step Editor"] = "Éditeur d'étapes"
L["Step ID"] = "ID d'étape"
L["Steps"] = "Mesures"
L["Style"] = "Style"
L["Summary"] = "Résumé"
L["Summary Step"] = "Étape récapitulative"
L["Summon"] = "Convoquer"
L["Summon Icon"] = "Icône d'invocation"
L["Switched to profile: %s"] = "Basculé vers le profil : %s"
L["Sync"] = "Synchroniser"
--[[Translation missing --]]
--[[ L[ [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=] ] = [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=]--]] 
L[ [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=] ] = [=[Synchroniser les paramètres de %s ?

Ceci copiera les paramètres actuels de %s vers %s et les maintiendra synchronisés.]=]
L["Sync from WoW"] = "Synchronisation depuis WoW"
L["Sync with %s"] = "Synchroniser avec %s"
L["Sync: %s"] = "Synchronisation : %s"
L["Synced with %s"] = "Synchronisé avec %s"
L["Synced: %s"] = "Synchronisé : %s"
L["Tank"] = "Tank"
L["Tanking (Red)"] = "Tanking (rouge)"
L["Tanks"] = "Tanks"
L["Target Type:"] = "Type de cible :"
L["Target Unit"] = "Unité cible"
L["Targeted Spell Alpha"] = "Opacité du sort ciblé"
L["Targeted Spell Click-Through"] = "Clic sur un sort ciblé"
L["Targeted Spells"] = "Sorts ciblés"
L["Targeted Spells (on frames)"] = "Sorts ciblés (sur les cadres d'unités)"
L["Targeting Fallback:"] = "Ciblage de secours :"
L["Targeting: %s"] = "Ciblage : %s"
L["Test"] = "Test"
L["Test Mode"] = "Mode test"
L["Test mode disabled."] = "Mode test désactivé."
L["Test mode enabled."] = "Mode test activé."
L["Test mode ended — entering combat."] = "Le mode test est terminé – entrée en combat."
L["Test Mode: %s"] = "Mode test : %s"
L["Text"] = "Texte"
L["Text Color"] = "Couleur du texte"
L["Text Colors:"] = "Couleurs du texte :"
L["Text Format"] = "Format du texte"
L["Text Scale"] = "Échelle du texte"
L["Texture"] = "Texture"
L["Texture & Colors"] = "Textures et couleurs"
L["The first image shows the overlay border active on a frame. The second shows the standard boss debuff icon only."] = "La première image montre la bordure de superposition active sur un cadre. La seconde affiche uniquement l’icône de débuff de boss standard."
--[[Translation missing --]]
--[[ L[ [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=] ] = [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=]--]] 
L[ [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=] ] = [=[La bordure de superposition est entièrement gérée par Blizzard et présente des particularités visuelles qui ne peuvent pas être corrigées :

Des %sOrange borders%s apparaîtront pour les débuffs de boss qui ne sont pas %snot dispellable%s. Seuls les débuffs supprimables affichent la bordure colorée standard.

Du texte de %sstack count text%s peut apparaître sur le cadre, séparé de l'icône.

La superposition n'est pas une solution parfaite et peut sembler imparfaite dans certains combats. Activez en connaissance de cause.]=]
L["These settings apply when using 'Shadow' outline style. Use larger offsets for more dramatic shadows."] = "Ces paramètres s'appliquent lors de l'utilisation du style de contour « Ombre ». Utilisez des décalages plus grands pour des ombres plus imposantes."
L["Thick Outline"] = "Contour épais"
L["Thickness"] = "Épaisseur"
--[[Translation missing --]]
--[[ L[ [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=] ] = [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=]--]] 
L[ [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=] ] = [=[Cette fonctionnalité ajoute une bordure autour de l'ensemble du cadre d'unité lorsque des débuffs de boss privés sont actifs.

Important: La bordure apparaîtra pour TOUS les débuffs de boss, pas seulement ceux qui peuvent être supprimés. Les débuffs non supprimables affichent une bordure solide.

L'apparence de la bordure est contrôlée par Blizzard et ne peut pas être personnalisée — seule la taille peut être ajustée.

Voulez-vous configurer cette fonctionnalité maintenant ?]=]
L["this option"] = "cette option"
--[[Translation missing --]]
--[[ L[ [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=] ] = [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=]--]] 
L[ [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=] ] = [=[Ce profil a été créé pour %s%s%s.
Certains raccourcis peuvent ne pas être compatibles avec %s%s%s.]=]
L["This setting differs from the global profile value. Click the reset button to revert."] = "Ce paramètre diffère de la valeur du profil global. Cliquez sur le bouton de réinitialisation pour revenir en arrière."
L["This setting is being overridden by the active auto layout profile. To change it, edit the profile in the Auto Layouts tab."] = "Ce paramètre est remplacé par le profil de mise en page automatique actif. Pour le modifier, modifiez le profil dans l'onglet Mises en page automatiques."
L["This step automatically shows a review of all the user's answers. It's always the last step."] = "Cette étape affiche automatiquement un examen de toutes les réponses de l'utilisateur. C'est toujours la dernière étape."
L["This warning will not appear again after confirming."] = "Cet avertissement n'apparaîtra plus après confirmation."
L["Threat Colors"] = "Couleurs des menaces"
L["Threshold Mode"] = "Mode seuil"
L["Time Remaining"] = "Temps restant"
L["Timing"] = "Timing"
L["Tint"] = "Teinte"
L["Tint Color"] = "Couleur de teinte"
L["Tint Opacity"] = "Opacité de la teinte"
--[[Translation missing --]]
--[[ L[ [=[to customise
this profile's settings]=] ] = [=[to customise
this profile's settings]=]--]] 
L[ [=[to customise
this profile's settings]=] ] = [=[pour personnaliser
les paramètres de ce profil]=]
L["To fix the ElvUI compatibility issue:"] = "Pour résoudre le problème de compatibilité ElvUI :"
L["To reposition: Unlock frames (/df unlock) and drag the mover."] = "Pour repositionner : Déverrouillez les images (/df unlock) et faites glisser le déménageur."
--[[Translation missing --]]
--[[ L["Toggle Solo Mode"] = "Toggle Solo Mode"--]] 
--[[Translation missing --]]
--[[ L["Toggle Test Mode"] = "Toggle Test Mode"--]] 
L["Tooltips"] = "Info-bulles"
L["Top"] = "Haut"
L["Top Edge"] = "Bord supérieur"
L["Top Left"] = "Haut Gauche"
L["Top Right"] = "Haut Droite"
L["Top to Bottom"] = "De haut en bas"
L["Total:"] = "Total:"
L["Track Highest Duration"] = "Suivre la durée la plus élevée"
L["Track Lowest Duration"] = "Suivre la durée la plus basse"
L["Trigger"] = "Déclenchement"
L["Trigger Mode"] = "Mode de déclenchement"
L["TRIGGERED BY"] = "DÉCLENCHÉ PAR"
L["Truncate Mode"] = "Mode Tronquer"
L["Truncation"] = "Troncature"
L["Type"] = "Taper"
L["Type /dfarena again to disable"] = "Tapez à nouveau /dfarena pour désactiver"
L["Type:"] = "Taper:"
L["UI Scale:"] = "Échelle de l'interface utilisateur :"
L["Unit Frame"] = "Cadre de l'unité"
L["Unit Frame Sorting"] = "Tri des cadres d'unités"
L["Unit Selection"] = "Sélection d'unité"
L["Units at or above this health percent are faded."] = "Les unités égales ou supérieures à ce pourcentage de vie sont estompées."
L["Units Per Row"] = "Unités par ligne"
L["Unknown"] = "Inconnu"
L["Unknown error"] = "Erreur inconnue"
L["Unlock"] = "Déverrouiller"
L["Unlock Frames"] = "Déverrouiller les cadres d'unités"
L["Unnamed"] = "Anonyme"
L["Up"] = "En haut"
L["Use"] = "Utiliser"
L["USE"] = "UTILISER"
L["Use %s"] = "Utiliser %s"
L["Use /df overrides for full details in chat"] = "Utilisez les remplacements /df pour tous les détails dans le chat"
L["Use Class Color"] = "Utiliser la couleur de la classe"
L["Use Current (%s)"] = "Utiliser le courant (%s)"
L["Use Current Value"] = "Utiliser la valeur actuelle"
L["Use Custom Colors"] = "Utiliser des couleurs personnalisées"
L["Use Custom Pip Color"] = "Utiliser une couleur des points de ressources personnalisée"
L["Use DandersFrames"] = "Utiliser DandersFrames"
L["Use DF Color Picker"] = "Utiliser le sélecteur de couleurs de DF"
L["Use DF Color Picker for All Addons"] = "Utilisez le sélecteur de couleurs de DF pour tous les modules complémentaires"
L["Use FrameSort Addon"] = "Utiliser le module complémentaire FrameSort"
L["Use Group-Based Layout"] = "Utiliser la mise en page basée sur un groupe"
L["Use recommended defaults"] = "Utiliser les valeurs par défaut recommandées"
L["Use Seconds Instead of Percent"] = "Utilisez des secondes au lieu du pourcentage"
L["Uses a single border per frame. Highest priority wins."] = "Utilise une seule bordure par image. La priorité la plus élevée gagne."
L["Uses cast tracking to identify spells WoW marks as secret. Only tracks your own casts."] = "Utilise le suivi de lancement pour identifier les sorts que WoW marque comme secrets. Ne suit que vos propres lancers."
L["Uses party frame settings/position"] = "Utilise les paramètres/position du cadre de groupe"
L["Using highest duration trigger"] = "Utilisation du déclencheur de durée la plus élevée"
L["Using lowest duration trigger"] = "Utilisation du déclencheur de durée la plus basse"
L["Using spec default"] = "Utilisation des spécifications par défaut"
L["v%s loaded. Type %s/df%s for settings, %s/df resetgui%s if window is offscreen."] = "v%s chargé. Tapez %s/df%s pour les paramètres, %s/df resetgui%s si la fenêtre est hors écran."
L["Valid range"] = "Plage valide"
L["Value:"] = "Valeur:"
L["Vehicle"] = "Véhicule"
L["Vehicle Icon"] = "Icône du véhicule"
L["Vertical"] = "Vertical"
L["Vertical Spacing"] = "Espacement vertical"
L["View Imported Macro"] = "Afficher la macro importée"
L["Visibility"] = "Visibilité"
L["Volume"] = "Volume"
L["Warlock"] = "Sorcier"
L["Warnings + Errors"] = "Avertissements + erreurs"
L["Warrior"] = "Guerrier"
L["Weight"] = "Poids"
L["What should '%s' do with this setting?"] = "Que doit faire « %s » avec ce paramètre ?"
L["When \"%s\" selected:"] = "Lorsque \"%s\" est sélectionné :"
L["When auto-detect is OFF, select which raid buffs to monitor manually."] = "Lorsque la détection automatique est désactivée, sélectionnez les buffs de raid à surveiller manuellement."
L["When disabled: Click spell to open Binding Editor."] = "Lorsqu'il est désactivé : cliquez sur le sort pour ouvrir l'éditeur de liaison."
L["When enabled, a new profile will be automatically"] = "Lorsqu'il est activé, un nouveau profil sera automatiquement"
L["When enabled, all pips use a single custom color instead of the class-specific default."] = "Lorsqu'ils sont activés, tous les points de ressources utilisent une seule couleur personnalisée au lieu de la couleur par défaut spécifique à la classe."
L["When enabled, all role icons are shown outside of combat. The filters below only apply during combat."] = "Lorsqu'elle est activée, toutes les icônes de rôle sont affichées en dehors du combat. Les filtres ci-dessous ne s'appliquent que pendant le combat."
L["When enabled, click-casting bindings will be"] = "Lorsqu'elles sont activées, les liaisons de diffusion par clic seront"
L["When enabled, Masque skins aura icons and borders. DF border settings will be disabled."] = "Lorsqu'il est activé, Masque skins aura des icônes et des bordures. Les paramètres de bordure DF seront désactivés."
L["When enabled, shows incoming heals even if they would overheal."] = "Lorsqu'il est activé, affiche les soins entrants même s'ils risquent d'être excédentaires."
L["When enabled, the group you are in will always be displayed first."] = "Lorsqu'il est activé, le groupe dans lequel vous appartenez sera toujours affiché en premier."
L["When enabled: Click spell, press key to bind instantly."] = "Lorsqu'il est activé : cliquez sur un sort, puis appuyer sur une touche pour le mettre en raccourci instantanément."
L["When you enter matching content, the layout's overrides are applied on top of your global settings. If no layout matches, global settings are used as-is."] = "Lorsque vous saisissez un contenu correspondant, les remplacements de la mise en page sont appliqués en plus de vos paramètres globaux. Si aucune disposition ne correspond, les paramètres globaux sont utilisés tels quels."
L["Which aura data source would you like to use?"] = "Quelle source de données d’aura souhaitez-vous utiliser ?"
L["While editing, each setting shows its override status:"] = "Lors de l'édition, chaque paramètre affiche son état de remplacement :"
L["Whitelist buffs take priority for the expiring indicator."] = "Les buffs de la liste blanche sont prioritaires pour l’indicateur d’expiration."
L["WHITELISTED"] = "SUR LISTE BLANCHE"
L["Whole Alpha Pulse"] = "Pouls alpha entier"
L["Width"] = "Largeur"
L["Width / Length"] = "Largeur / Longueur"
L["Will auto-create on switch"] = "Créera automatiquement lors du changement"
L["Will replace existing Mythic layout"] = "Remplacera la mise en page Mythic existante"
L["Wizard"] = "Assistant"
L["Wizard '%s' saved!"] = "Assistant '%s' enregistré !"
L["Wizard Builder"] = "Générateur d'assistants"
L["Wizard Details"] = "Détails de l'assistant"
L["Wizard Name:"] = "Nom de l'assistant :"
L["Works when hovering frames. Action bars work when not hovering."] = "Fonctionne lors du survol des cadres d'unités. Les barres d'action fonctionnent lorsqu'elles ne sont pas en survol."
L["World bosses, outdoor raids (1-40)"] = "Boss mondiaux, raids extérieurs (1-40)"
--[[Translation missing --]]
--[[ L[ [=[Would you like to keep standard buff icons alongside
Aura Designer, or let it fully replace them?]=] ] = [=[Would you like to keep standard buff icons alongside
Aura Designer, or let it fully replace them?]=]--]] 
L[ [=[Would you like to keep standard buff icons alongside
Aura Designer, or let it fully replace them?]=] ] = [=[Souhaitez-vous conserver les icônes de buff standard avec ceux du
Concepteur d'auras, ou le laisser les remplacer complètement ?]=]
L["Would you like to set up your aura filters?"] = "Souhaitez-vous configurer vos filtres d’aura ?"
L["X Color"] = "X Couleur"
L["X Mark"] = "Marque X"
L["X Size"] = "Taille X"
L["Yellow=high, Orange=highest, Red=tanking."] = "Jaune = élevé, Orange = le plus élevé, Rouge = tank."
L["Yes"] = "Oui"
L["Yes, set it up"] = "Oui, configure-le"
L["YOUR PROFILES"] = "VOS PROFILS"
L["Z to A"] = "Z à A"

