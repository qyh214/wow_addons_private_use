-- French localization file for frFR.
local L = ElvUI[1].Libs.ACL:NewLocale("ElvUI", "frFR")
if not L then return; end

-- Translation by: Alex586, Deadse10

-- Init
L["ENH_LOGIN_MSG"] = "Vous utilisez |cff1784d1ElvUI Enhanced Again|r |cffff8000)|r version %s%s|r."
L["ENH_LOGIN_MSG_WRATH"] = "You are using |cff1784d1ElvUI Enhanced Again|r |cffff8000(Wrath Classic)|r version %s%s|r."
L["Your version of ElvUI is to old (required 11.52 or higher). Please, download the latest version from tukui.org."] = "Votre version d'ElvUI est trop ancienne (requiert v6.51 ou plus). Merci de télécharger une version plus récente sur tukui.org."

-- Equipment
L["Equipment"] = "Équipement"
L["EQUIPMENT_DESC"] = "Ajustez les réglages pour passer d'un équipement à l'autre lorsque vous changez de spécialisation ou lorsque que vous effectuez un Champs de Bataille."
L["No Change"] = "Ne pas changer"

L["Specialization"] = "Spécialisation"
L["Enable/Disable the specialization switch."] = "Activer / Désactiver la fonction du changement d'équipement lorsque vous changez de spécialisation."

L["Primary Talent"] = "Spécialisation principale"
L["Choose the equipment set to use for your primary specialization."] = "Choisissez le set d'équipement à utiliser pour votre spécialisation principale."

L["Secondary Talent"] = "Spécialisaion secondaire"
L["Choose the equipment set to use for your secondary specialization."] = "Choisissez le set d'équipement à utiliser pour votre spécialisation secondaire."

L["Battleground"] = "Champs de Bataille"
L['Enable/Disable the battleground switch.'] = "Activer / Désactiver la fonction du changement d'équipement lorsque vous entrez dans un Champs de Bataille ou une Arène."

L["Equipment Set"] = "Set d'équipement"
L["Choose the equipment set to use when you enter a battleground or arena."] = "Choisissez le set d'équipement à utiliser quant vous entrez dans un Champs de Bataille ou une Arène."

L["You have equipped equipment set: "] = "Vous avez équipez le set d'équipement: "

L["DURABILITY_DESC"] = "Ajustez les réglages pour afficher la durabilité sur l'écran d'infos de personnage."
L['Enable/Disable the display of durability information on the character screen.'] = "Activer / Désactiver l'affichage des informations de durabilité sur l'écran d'infos de personnage."
L["Damaged Only"] = "Dégâts seulement"
L["Only show durabitlity information for items that are damaged."] = "Afficher la durabilité seulement quand l'équipement est endommagé."

L["ITEMLEVEL_DESC"] = "Réglez les paramètres pour afficher le niveau d'objet sur l'écran d'infos de personnage."
L["Enable/Disable the display of item levels on the character screen."] = "Activer / Désactiver l'affichage des informations du niveau d'objet sur l'écran d'infos de personnage."

L["Miscellaneous"] = "Divers"
L['Equipment Set Overlay'] = "Nom du set d'équipement"
L['Show the associated equipment sets for the items in your bags (or bank).'] = "Affiche le nom associés au set d'équipement sur vos objets dans vos sacs et votre banque."

-- Movers
L["Mover Transparency"] = "Transparence des Ancres"
L["Changes the transparency of all the movers."] = "Change la transparence des Ancres"

-- Automatic Role Assignment
L['Automatic Role Assignment'] = "Assigner automatiquement le rôle"
L['Enables the automatic role assignment based on specialization for party / raid members (only work when you are group leader or group assist).'] = "Active l'assignation automatique des rôles des membres selon la spécialisation dans le Groupe / Raid (Fonctionne seulement quand vous êtes le leader ou que vous possédez une assiste.)"

-- Auto Hide Role Icons in combat
L['Hide Role Icon in combat'] = "Cachez les icônes de rôle en combat"
L['All role icons (Damage/Healer/Tank) on the unit frames are hidden when you go into combat.'] = "Cachez toutes les icônes de rôle (Dommages/Healer/Tank) sur les cadres d'unité quand vous serait en combat."

-- GPS module
L['GPS'] = "GPS"
L['Show the direction and distance to the selected party or raid member.'] = "Affiche la direction et la distance entre vous et la cible du groupe ou du raid."

-- Attack Icon
L['Attack Icon'] = "Icône d'Attaque"
L['Show attack icon for units that are not tapped by you or your group, but still give kill credit when attacked.'] = "Affiche une icône d'attaque sur les unités que vous ou votre groupe n'avez pas encore tapé, mais dont vous pouvez revendiquer la paternité."

-- Class Icon
L['Show class icon for units.'] = true

-- Minimap Location
L['Above Minimap'] = "Sous la minicarte"
L['Location Digits'] = "Chiffres d'emplacement"
L['Number of digits for map location.'] = "Nombre de chiffres pour l'emplacement."

-- Minimap Combat Hide
L["Hide minimap while in combat."] = "Cacher la minicarte quand vous êtes en combat"
L["FadeIn Delay"] = "Délais d'estompage"
L["The time to wait before fading the minimap back in after combat hide. (0 = Disabled)"] = "Le temps à attendre avant que la minicarte s'estompe avec que le combat ait commencé. (0 = désactié)"

-- Minimap Buttons
L['Skin Buttons'] = "Boutons Skin"
L['Skins the minimap buttons in Elv UI style.'] = "Habillez les boutons de la minicarte avec le style ElvUI."
L['Skin Style'] = "Skin Style"
L['Change settings for how the minimap buttons are skinned.'] = "Change les réglages pour comment sont habillés les boutons."
L['The size of the minimap buttons.'] = "Taille des boutons de la minicarte."

L['No Anchor Bar'] = "Ne pas ancré à une Barre"
L['Horizontal Anchor Bar'] = "Ancrer honrizontalement à la Barre"
L['Vertical Anchor Bar'] = "Ancrer verticalement à la Barre"

L['Layout Direction'] = true
L['Normal is right to left or top to bottom, or select reversed to switch directions.'] = true
L['Normal'] = true
L['Reversed'] = true

-- PvP Autorelease
L['PvP Autorelease'] = "Libération automatique en PVP"
L['Automatically release body when killed inside a battleground.'] = "Libère automatiquement votre corps quand vous êtes tué en Champs de Bataille."

-- Track Reputation
L['Track Reputation'] = "Suivre la Réputation"
L['Automatically change your watched faction on the reputation bar to the faction you got reputation points for.'] = "Change automatiquement la réputation suivie sur la barre de réputation avec la faction que vous êtes en train de faire."

-- Select Quest Reward
L['Select Quest Reward'] = "Sélection de la récompense de quête"
L['Automatically select the quest reward with the highest vendor sell value.'] = "Sélectionne automatiquement la récompense de quête qui vaut la plus chère chez le vendeur."

-- Item Level Datatext
L['Item Level'] = "Niveau d'objet"

-- Range Datatext
L['Target Range'] = true
L['Distance'] = "Distance"

-- Extra Datatexts
L['Actionbar1DataPanel'] = "Barre d'actions 1"
L['Actionbar3DataPanel'] = "Barre d'actions 3"
L['Actionbar5DataPanel'] = "Barre d'actions 5"

-- Farmer Module
L["Sunsong Ranch"] = "Ferme Chant du Soleil"
L["The Halfhill Market"] = "Marché de Micolline"
L["Tilled Soil"] = "Terre labourée"
L['Right-click to drop the item.'] = "Clique droit pour lacher l'objet."

L['Farmer'] = "Ferme"
L["FARMER_DESC"] = "Réglez les paramètres des outils qui vous aideront à pratiquer une agriculture plus efficace avec votre Ferme (Ferme Chant du Soleil)."
L['Farmer Bars'] = "Barre d'agriculture"
L['Farmer Portal Bar'] = "Barre des portails"
L['Farmer Seed Bar'] = "Barre des graines"
L['Farmer Tools Bar'] = "Barre des outils"
L['Enable/Disable the farmer bars.'] = "Activer / Désactiver la barre d'agriculture"
L['Only active buttons'] = "Seulement les boutons actifs"
L['Only show the buttons for the seeds, portals, tools you have in your bags.'] = "Affiche seulement les boutons pour les graines, portails et outils que vous avez dans vos sacs."
L['Drop Tools'] = "Jeter les outils"
L['Automatically drop tools from your bags when leaving the farming area.'] = "Jeter automatiquement les outils de votre sac après avoir quitté la ferme."
L['Seed Bar Direction'] = "Direction de la barre des graines."
L['The direction of the seed bar buttons (Horizontal or Vertical).'] = "Sélectionnez la direction de la barre de graine (Horizontal ou Vertical)."

-- Nameplates
L["Threat Text"] = "Texte de menace"
L["Display threat level as text on targeted, boss or mouseover nameplate."] = "Affiche le niveau de menace sur le cadre d'unité de la cible, du boss, ou en passant votre souris."
L["Target Count"] = true
L["Display the number of party / raid members targetting the nameplate unit."] = true

-- HealGlow
L['Heal Glow'] = "Prédiction des soins"
L['Direct AoE heals will let the unit frames of the affected party / raid members glow for the defined time period.'] = "Les soins directs d'AoE laisserons sur les cadres d'unités du groupe / raid un montant fixe défini pour la période du soin."
L["Glow Duration"] = "Durée de la prédiction"
L["The amount of time the unit frames of party / raid members will glow when affected by a direct AoE heal."] = "Le temps que les cadres d'unités du groupe / Raid seront affectés par la prédiction de soin."
L["Glow Color"] = "Couleur de la prédiction"

-- Raid Marker Bar
L['Raid Marker Bar'] = "Barre d'action de marquage d'icône ou terrain"
L['Display a quick action bar for raid targets and world markers.'] = "Affiche une barre d'action pour ajouter une icône sur les cibles ou marquer le terrain"
L['Modifier Key'] = "Touche de marquage de terrain"
L['Set the modifier key for placing world markers.'] = "Configurez la touche de modification pour placer des marquages de terrain rapidement.|cff1784d1Fonctionne seulement en groupe ou en raid.|r"
L['Shift Key'] = "Touche MAJ"
L['Ctrl Key'] = "Touche CTRL"
L['Alt Key'] = "Touche ALT "
L["Raid Markers"] = "Icône ou Marquage de terrain"
L["Click to clear the mark."] = "Cliquez pour supprimer l'icône sur la cible."
L["Click to mark the target."] = "Cliquez pour placer une icône sur la cible."
L["%sClick to remove all worldmarkers."] = "%sClic pour supprimer tous les marquages de terrain."
L["%sClick to place a worldmarker."] = "%sClic pour placer un marqueur de terrain."

-- WatchFrame
L['WatchFrame'] = "Fenêtre d'objectifs"
L['WATCHFRAME_DESC'] = "Réglez les paramètres pour la visibilité de la fenêtre d'objectifs (journal de quête) avec vos préférences personnelles."
L['Hidden'] = "Caché"
L['Collapsed'] = "Replié"
L['Settings'] = "Paramètres"
L['City (Resting)'] = "Ville (repos)"
L['PvP'] = "PvP"
L['Arena'] = "Arêne"
L['Party'] = "Groupe"
L['Raid'] = "Raid"

-- Tooltips
L['Progression Info'] = "Information de progression"
L['Display the players raid progression in the tooltip, this may not immediately update when mousing over a unit.'] = "Affiche la progression (Raid) du joueur dans une infos-bulle (ne peut être mis à jour immédiatement lorsque la souris survole une unité)."
