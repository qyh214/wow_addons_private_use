if not(GetLocale() == "frFR") then
  return
end

local L = WeakAuras.L

-- WeakAuras/Options
	L[" by "] = "de"
	L["-- Do not remove this comment, it is part of this trigger: "] = "-- Ne retirez pas ce commentaire, il fait partie de ce déclencheur : "
	L[" to version "] = "vers version"
	L["% of Progress"] = "% de progression"
	L["%i auras selected"] = "%i auras sélectionnées"
	L["%i Matches"] = "%i Correspondances"
	L["%s Color"] = "%s Couleur"
	L["%s total auras"] = "%s auras au total"
	--[[Translation missing --]]
	L["|cFFFF0000Duplicate Keys Found!|nPlease change the keys of the following options!|r"] = "|cFFFF0000Duplicate Keys Found!|nPlease change the keys of the following options!|r"
	L["1 Match"] = "1 Correspondance"
	L["1. Text"] = "1. Texte"
	L["1. Text Settings"] = "1. Paramètres du Texte"
	L["2. Text"] = "2. Texte"
	L["2. Text Settings"] = "2. Paramètres du Texte"
	L["A 20x20 pixels icon"] = "Une icône de 20x20 pixels."
	L["A 32x32 pixels icon"] = "Une icône de 32x32 pixels."
	L["A 40x40 pixels icon"] = "Une icône de 40x40 pixels."
	L["A 48x48 pixels icon"] = "Une icône de 48x48 pixels."
	L["A 64x64 pixels icon"] = "Une icône de 64x64 pixels."
	L["A group that dynamically controls the positioning of its children"] = "Un groupe qui contrôle dynamiquement le positionnement de ses enfants"
	--[[Translation missing --]]
	L["A Unit ID (e.g., party1)."] = "A Unit ID (e.g., party1)."
	L["Actions"] = "Actions"
	L["Add a new display"] = "Ajouter un nouvelle affichage"
	L["Add Condition"] = "Ajouter une Condition"
	L["Add Option"] = "Ajouter Option"
	L["Add Overlay"] = "Ajouter un Overlay"
	L["Add Property Change"] = "Ajouter un Changement de Propriété"
	L["Add to group %s"] = "Ajouter au groupe %s"
	L["Add to new Dynamic Group"] = "Ajouter à un nouveau groupe dynamique"
	L["Add to new Group"] = "Ajouter à un nouveau groupe"
	L["Add Trigger"] = "Ajouter un déclencheur"
	L["Addon"] = "Addon"
	L["Addons"] = "Addons"
	L["Advanced"] = "Avancé"
	L["Align"] = "Aligner"
	L["All of"] = "Tous vos"
	L["Allow Full Rotation"] = "Permettre une rotation complète"
	L["Alpha"] = "Alpha"
	L["Anchor"] = "Ancrage"
	L["Anchor Point"] = "Point d'ancrage"
	L["Anchored To"] = "Accrocher à"
	L["And "] = "Et"
	L["and Trigger %s"] = "et Déclencheur %s"
	L["Angle"] = "Angle"
	L["Animate"] = "Animer"
	L["Animated Expand and Collapse"] = "Expansion et réduction animés"
	L["Animates progress changes"] = "Animer les changement de progression"
	L["Animation relative duration description"] = [=[La durée de l'animation par rapport à la durée du graphique, exprimée en fraction (1/2), pourcentage (50%), ou décimal (0.5).
|cFFFF0000Note :|r si un graphique n'a pas de progression (déclencheur d'événement sans durée définie, aura sans durée, etc), l'animation ne jouera pas.

|cFF4444FFPar exemple :|r
Si la durée de l'animation est définie à |cFF00CC0010%|r, et le déclencheur du graphique est une amélioration qui dure 20 secondes, l'animation de début jouera pendant 2 secondes.
Si la durée de l'animation est définie à |cFF00CC0010%|r, et le déclencheur du graphique n'a pas de durée définie, aucune d'animation de début ne jouera (mais elle jouerait si vous aviez spécifié une durée en secondes).
]=]
	L["Animation Sequence"] = "Séquence d'animation"
	L["Animations"] = "Animations"
	L["Any of"] = "Un de"
	L["Apply Template"] = "Appliquer le modèle"
	L["Arcane Orb"] = "Orbe d'arcane"
	L["At a position a bit left of Left HUD position."] = "Une position à gauche de la Position ATH Gauche."
	L["At a position a bit left of Right HUD position"] = "Une position à droite de la Position ATH Droite."
	L["At the same position as Blizzard's spell alert"] = "À la même position que l'alerte de sort de Blizzard."
	L["Aura Name"] = "Nom de l'aura"
	--[[Translation missing --]]
	L["Aura Name Pattern"] = "Aura Name Pattern"
	L["Aura Type"] = "Type de l'aura"
	L["Aura(s)"] = "Aura(s)"
	L["Author Options"] = "Options de l'Auteur"
	L["Auto"] = "Auto"
	L["Auto-Clone (Show All Matches)"] = "Clonage Automatique (Afficher tous les résultats)"
	L["Auto-cloning enabled"] = "Auto-clonage activé"
	L["Automatic Icon"] = "Icône automatique"
	L["Backdrop Color"] = "Couleur de Fond"
	L["Backdrop in Front"] = "Fond Devant"
	L["Backdrop Style"] = "Style de Fond"
	L["Background"] = "Arrière-plan"
	L["Background Color"] = "Couleur de fond"
	L["Background Inset"] = "Encart d'arrière-plan"
	L["Background Offset"] = "Décalage du Fond "
	L["Background Texture"] = "Texture du Fond"
	L["Bar Alpha"] = "Alpha de la Barre"
	L["Bar Color"] = "Couleur de barre"
	L["Bar Color Settings"] = "Réglages Couleur de Barre"
	L["Bar Texture"] = "Texture de barre"
	L["Big Icon"] = "Grande icône"
	L["Blend Mode"] = "Mode du fusion"
	L["Blue Rune"] = "Rune bleue"
	L["Blue Sparkle Orb"] = "Orbe pétillant bleu"
	L["Border"] = "Bordure"
	L["Border Color"] = "Couleur de Bordure"
	L["Border in Front"] = "Bordure Devant"
	L["Border Inset"] = "Encart Fond"
	L["Border Offset"] = "Décalage Bordure"
	L["Border Settings"] = "Réglages de Bordure"
	L["Border Size"] = "Taille de Bordure"
	L["Border Style"] = "Style de Bordure"
	L["Bottom Text"] = "Texte du bas"
	L["Bracket Matching"] = "Crochet Correspondant"
	L["Button Glow"] = "Bouton en surbrillance"
	L["Can be a name or a UID (e.g., party1). A name only works on friendly players in your group."] = "Peut être un nom ou un UID (ex: party1). Un nom ne fonctionne que sur un joueur allié dans votre groupe."
	--[[Translation missing --]]
	L["Can be a Name or a Unit ID (e.g. party1). A name only works on friendly players in your group."] = "Can be a Name or a Unit ID (e.g. party1). A name only works on friendly players in your group."
	L["Cancel"] = "Annuler"
	L["Channel Number"] = "Numéro de canal"
	L["Chat Message"] = "Message dans le chat"
	L["Check On..."] = "Vérifier sur..."
	L["Children:"] = "Enfant :"
	L["Choose"] = "Choisir"
	L["Choose Trigger"] = "Choisir un déclencheur"
	L["Choose whether the displayed icon is automatic or defined manually"] = "Choisir si l'icône affichée est automatique ou définie manuellement"
	--[[Translation missing --]]
	L["Clip Overlays"] = "Clip Overlays"
	L["Clone option enabled dialog"] = [=[
Vous avez activé une option qui utilise l'|cFFFF0000Auto-clonage|r.

L'|cFFFF0000Auto-clonage|r permet à un graphique d'être automatiquement dupliqué pour afficher plusieurs sources d'information.
A moins que vous mettiez ce graphique dans un |cFF22AA22Groupe Dynamique|r, tous les clones seront affichés en tas l'un sur l'autre.

Souhaitez-vous que ce graphiques soit placé dans un nouveau |cFF22AA22Groupe Dynamique|r ?]=]
	L["Close"] = "Fermer"
	L["Collapse"] = "Réduire"
	L["Collapse all loaded displays"] = "Réduire tous les graphiques chargés"
	L["Collapse all non-loaded displays"] = "Réduire tous les graphiques non-chargés"
	L["Color"] = "Couleur"
	L["color"] = "couleur"
	L["Combinations"] = "Combinaisons"
	L["Combine Matches Per Unit"] = "Combiner toutes les Correspondances Par Unité"
	L["Compare against the number of units affected."] = "Comparer contre le nombre d'unités affectées."
	L["Compress"] = "Compresser"
	L["Condition %i"] = "Condition %i"
	L["Conditions"] = "Conditions"
	L["Configure what options appear on this pannel."] = "Configurez les options qui apparaissent sur ce panneau."
	L["Constant Factor"] = "Facteur constant"
	L["Control-click to select multiple displays"] = "Ctrl-clic pour sélectionner plusieurs affichages"
	L["Controls the positioning and configuration of multiple displays at the same time"] = "Contrôle la position et la configuration de plusieurs graphiques en même temps"
	L["Convert to New Aura Trigger"] = "Convertir au nouveau déclencheur d'aura"
	L["Convert to..."] = "Convertir en..."
	L["Cooldown"] = "Recharge"
	--[[Translation missing --]]
	L["Cooldown Edge"] = "Cooldown Edge"
	--[[Translation missing --]]
	L["Cooldown Settings"] = "Cooldown Settings"
	--[[Translation missing --]]
	L["Cooldown Swipe"] = "Cooldown Swipe"
	L["Copy settings..."] = "Copier les paramètres..."
	L["Copy to all auras"] = "Copier toutes les auras"
	L["Copy URL"] = "Copier l'URL"
	L["Count"] = "Compte"
	--[[Translation missing --]]
	L["Counts the number of matches over all units."] = "Counts the number of matches over all units."
	L["Creating buttons: "] = "Création de boutons :"
	L["Creating options: "] = "Création d'options :"
	L["Crop X"] = "Couper X"
	L["Crop Y"] = "Couper Y"
	L["Custom"] = "Personnalisé"
	L["Custom Code"] = "Code personnalisé"
	L["Custom Configuration"] = "Configuration Personnalisée"
	L["Custom Function"] = "Fonction personnalisée"
	L["Custom Options"] = "Options Personnalisées"
	L["Custom Trigger"] = "Déclencheur personnalisé"
	L["Custom trigger event tooltip"] = [=[
Choisissez quels évènements peuvent activer le déclencheur.
Plusieurs évènements peuvent être spécifiés avec des virgules ou des espaces.

|cFF4444FFPar exemple:|r
UNIT_POWER, UNIT_AURA PLAYER_TARGET_CHANGED
]=]
	L["Custom trigger status tooltip"] = [=[
Choisissez quels évènements peuvent activer le déclencheur.
Comme c'est un déclencheur de type statut, les évènements spécifiés peuvent être appelés par WeakAuras sans les arguments attendus.
Plusieurs évènements peuvent être spécifiés avec des virgules ou des espaces.

|cFF4444FFPar exemple:|r
UNIT_POWER, UNIT_AURA PLAYER_TARGET_CHANGED
]=]
	L["Custom Untrigger"] = "Désactivation personnalisée"
	L["Custom Variables"] = "Variables Personnalisées"
	L["Debuff Type"] = "Type d'affaiblissement"
	L["Default"] = "Par défaut"
	L["Delete"] = "Supprimer"
	L["Delete all"] = "Supprimer tout"
	L["Delete children and group"] = "Supprimer enfants et groupe"
	L["Delete Trigger"] = "Supprimer le déclencheur"
	L["Desaturate"] = "Dé-saturer"
	L["Description"] = "Description"
	L["Description Text"] = "Texte de Description"
	L["Differences"] = "Différences"
	L["Disable Import"] = "Désactiver l'Import"
	L["Disabled"] = "Désactivé"
	L["Discrete Rotation"] = "Rotation individuelle"
	L["Display"] = "Graphique"
	L["Display Icon"] = "Icône du graphique"
	--[[Translation missing --]]
	L["Display Name"] = "Display Name"
	L["Display Text"] = "Texte du graphique"
	L["Displays a text, works best in combination with other displays"] = "Affiche du texte. Marche le mieux en le combinant à d'autres graphiques."
	L["Distribute Horizontally"] = "Distribuer horizontalement"
	L["Distribute Vertically"] = "Distribuer verticalement"
	L["Do not group this display"] = "Ne pas grouper cette affichage"
	L["Done"] = "Terminé"
	--[[Translation missing --]]
	L["Don't skip this Version"] = "Don't skip this Version"
	L["Down"] = "Vers le bas"
	L["Drag to move"] = "Glisser pour déplacer"
	L["Duplicate"] = "Doubler"
	L["Duplicate All"] = "Doubler Tous"
	L["Duration (s)"] = "Durée (s)"
	L["Duration Info"] = "Info de durée"
	L["Dynamic Duration"] = "Durée Dynamique"
	L["Dynamic Group"] = "Groupe Dynamique"
	L["Dynamic Group Settings"] = "Paramètres de Groupe Dynamiques"
	L["Dynamic Information"] = "Information Dynamique"
	L["Dynamic information from first active trigger"] = "Information dynamique depuis le premier déclencheur"
	L["Dynamic information from Trigger %i"] = "Information dynamique du Déclencheur %i"
	L["Dynamic text tooltip"] = [=[Il y a plusieurs codes spéciaux disponibles pour rendre ce texte dynamique :

|cFFFF0000%p|r - Progression - Le temps restant sur un compteur, ou une valeur autre
|cFFFF0000%t|r - Total - La durée maximum d'un compteur, ou le maximum d'une valeur autre
|cFFFF0000%n|r - Nom - Le nom du graphique (souvent le nom d'une aura), ou l'ID du graphique s'il n'y a pas de nom dynamique
|cFFFF0000%i|r - Icône - L'icône associée à l'affichage
|cFFFF0000%s|r - Pile - La taille de la pile d'une aura (généralement)
|cFFFF0000%c|r - Personnalisé - Vous permet de définir une fonction Lua personnalisée qui donne un texte à afficher]=]
	L["Enable"] = "Activer"
	L["Enabled"] = "Activé"
	L["End Angle"] = "Angle de fin"
	L["Enter a Spell ID"] = "Entrer un ID de sort"
	L["Enter an aura name, partial aura name, or spell id"] = "Entrez un nom d'aura, nom d'aura partiel ou ID de sort"
	--[[Translation missing --]]
	L["Enter an Aura Name, partial Aura Name, or Spell ID. A Spell ID will match any spells with the same name."] = "Enter an Aura Name, partial Aura Name, or Spell ID. A Spell ID will match any spells with the same name."
	L["Enter Author Mode"] = "Entrer en Mode Auteur"
	L["Enter User Mode"] = "Entrer en Mode Utilisateur."
	L["Enter user mode."] = "Entrer en Mode Utilisateur."
	L["Event"] = "Évènement"
	L["Event Type"] = "Type d'évènement"
	L["Event(s)"] = "Évènement(s)"
	L["Everything"] = "Tous"
	L["Exact Spell ID(s)"] = "ID(s) de sort exacte(s)"
	L["Exact Spell Match"] = "Correspondance Exacte du Sort"
	L["Expand"] = "Etendre"
	L["Expand all loaded displays"] = "Agrandir tous graphiques chargés"
	L["Expand all non-loaded displays"] = "Agrandir tous graphiques non-chargés"
	L["Expansion is disabled because this group has no children"] = "L'expansion est désactivée car ce groupe n'a pas d'enfants"
	L["Export to Lua table..."] = "Exporter vers une table Lua..."
	L["Export to string..."] = "Exporter vers une chaîne..."
	L["External"] = "Externe"
	L["Fade"] = "Fondu"
	L["Fade In"] = "Fondu entrant"
	L["Fade Out"] = "Fondu sortant"
	L["False"] = "Faux"
	--[[Translation missing --]]
	L["Fetch Affected/Unaffected Names"] = "Fetch Affected/Unaffected Names"
	L["Filter by Group Role"] = "Filtrer par Rôle de Groupe"
	L["Finish"] = "Finir"
	L["Fire Orb"] = "Orbe de feu"
	L["Font"] = "Police"
	L["Font Flags"] = "Style de Police"
	L["Font Size"] = "Taille de Police"
	L["Font Type"] = "Type de police"
	L["Foreground Color"] = "Couleur premier-plan"
	L["Foreground Texture"] = "Texture premier-plan"
	L["Frame"] = "Cadre"
	L["Frame Strata"] = "Strate du cadre"
	L["From Template"] = "D'après un modèle"
	L["From version "] = "Depuis la version"
	L["General Text Settings"] = "Paramètres Généraux du Texte"
	L["Global Conditions"] = "Conditions globales"
	L["Glow Action"] = "Action de l'éclat"
	--[[Translation missing --]]
	L["Glow Color"] = "Glow Color"
	--[[Translation missing --]]
	L["Glow Settings"] = "Glow Settings"
	--[[Translation missing --]]
	L["Glow Type"] = "Glow Type"
	L["Green Rune"] = "Rune verte"
	L["Group"] = "Groupe"
	L["Group (verb)"] = "Groupe (verbe)"
	L["Group aura count description"] = [=[Le nombre de membres du %s qui doivent être affectés par une ou plusieurs des auras sélectionnées pour que l'affichage soit déclenché.
Si le nombre entré est un entier (ex. 5), le nombre de membres du raid affectés sera comparé au nombre entré.
Si le nombre entré est decimal (ex. 0.5), une fraction (ex. 1/2), ou un pourcentage (ex. 50%%), alors cette fraction du %s doit être affectée.

|cFF4444FFPar exemple :|r
|cFF00CC00> 0|r se déclenchera quand n'importe quel membre du %s est affecté
|cFF00CC00= 100%%|r se déclenchera quand tous les membres du %s sont affectés
|cFF00CC00!= 2|r se déclenchera quand le nombre de membres du %s affectés est différent de 2
|cFF00CC00<= 0.8|r se déclenchera quand moins de 80%% du %s est affecté (4 des 5 membres du groupe, 8 des 10 ou 20 des 25 membres du raid )
|cFF00CC00> 1/2|r se déclenchera quand plus de la moitié du %s est affecté
|cFF00CC00>= 0|r se déclenchera toujours, quoi qu'il arrive
]=]
	--[[Translation missing --]]
	L["Group contains updates from Wago"] = "Group contains updates from Wago"
	L["Group Member Count"] = "Nombre de membres du groupe"
	L["Group Role"] = "Rôle du Groupe"
	L["Group Scale"] = "Échelle du Groupe"
	--[[Translation missing --]]
	L["Group Settings"] = "Group Settings"
	L["Grow"] = "Grandir"
	L["Hawk"] = "Faucon"
	L["Height"] = "Hauteur"
	L["Hide"] = "Cacher"
	L["Hide on"] = "Cacher à"
	L["Hide this group's children"] = "Cacher les enfants de ce groupe"
	L["Hide When Not In Group"] = "Cacher hors d'un groupe"
	L["Horizontal Align"] = "Aligner horizontalement"
	L["Horizontal Bar"] = "Barre horizontale"
	L["Huge Icon"] = "Énorme icône"
	L["Hybrid Position"] = "Position hybride"
	L["Hybrid Sort Mode"] = "Mode de tri hybride"
	L["Icon"] = "Icône"
	L["Icon Alpha"] = "Alpha de l'Icône"
	L["Icon Color"] = "Couleur d'icône"
	L["Icon Info"] = "Info d'icône"
	L["Icon Inset"] = "Objet inséré"
	--[[Translation missing --]]
	L["Icon Settings"] = "Icon Settings"
	L["If"] = "Si"
	--[[Translation missing --]]
	L["If checked, then this separator will include text. Otherwise, it will be just a horizontal line."] = "If checked, then this separator will include text. Otherwise, it will be just a horizontal line."
	--[[Translation missing --]]
	L["If checked, then this space will span across multiple lines."] = "If checked, then this space will span across multiple lines."
	L["If this option is enabled, you are no longer able to import auras."] = "Si cette option est activé, vous ne pourrez plus importé des auras."
	L["If Trigger %s"] = "Si Déclencheur %s"
	--[[Translation missing --]]
	L["If unchecked, then a default color will be used (usually yellow)"] = "If unchecked, then a default color will be used (usually yellow)"
	--[[Translation missing --]]
	L["If unchecked, then this space will fill the entire line it is on in User Mode."] = "If unchecked, then this space will fill the entire line it is on in User Mode."
	--[[Translation missing --]]
	L["Ignore all Updates"] = "Ignore all Updates"
	--[[Translation missing --]]
	L["Ignore Self"] = "Ignore Self"
	L["Ignore self"] = "Ignorer soi-même"
	L["Ignored"] = "Ignoré"
	L["Import"] = "Importer"
	L["Import a display from an encoded string"] = "Importer un graphique d'un texte encodé"
	L["Invalid Item Name/ID/Link"] = "Nom/ID/Lien Invalide"
	L["Invalid Spell ID"] = "ID du Sort Invalide"
	L["Invalid Spell Name/ID/Link"] = "Nom du Sort/ID/Lien Invalide"
	L["Inverse"] = "Inverser"
	L["Inverse Slant"] = "Inverser l'Inclinaison"
	--[[Translation missing --]]
	L["Is Stealable"] = "Is Stealable"
	L["Justify"] = "Justification"
	L["Keep Aspect Ratio"] = "Conserver les Proportions"
	--[[Translation missing --]]
	L["Key for aura_env.config at which the user value can be found."] = "Key for aura_env.config at which the user value can be found."
	L["Leaf"] = "Feuille"
	L["Left 2 HUD position"] = "Position ATH Gauche 2"
	L["Left HUD position"] = "Position ATH Gauche"
	L["Left Text"] = "Texte de gauche"
	--[[Translation missing --]]
	L["Legacy Aura Trigger"] = "Legacy Aura Trigger"
	--[[Translation missing --]]
	L["Length"] = "Length"
	L["Load"] = "Charger"
	L["Loaded"] = "Chargé"
	L["Loop"] = "Boucle"
	L["Low Mana"] = "Mana bas"
	L["Main"] = "Principal"
	L["Manage displays defined by Addons"] = "Gérer graphiques définis par addons"
	--[[Translation missing --]]
	L["Match Count"] = "Match Count"
	--[[Translation missing --]]
	L["Max"] = "Max"
	--[[Translation missing --]]
	L["Max Length"] = "Max Length"
	L["Medium Icon"] = "Icône moyenne"
	L["Message"] = "Message"
	L["Message Prefix"] = "Préfixe du message"
	L["Message Suffix"] = "Suffixe du message"
	L["Message Type"] = "Type de message"
	--[[Translation missing --]]
	L["Min"] = "Min"
	L["Mirror"] = "Miroir"
	L["Model"] = "Modèle"
	--[[Translation missing --]]
	L["Model Settings"] = "Model Settings"
	L["Move Down"] = "Déplacer vers le bas"
	L["Move this display down in its group's order"] = "Déplacer cet affichage vers le bas dans l'ordre de son groupe"
	L["Move this display up in its group's order"] = "Déplacer cet affichage vers le haut dans l'ordre de son groupe"
	L["Move Up"] = "Déplacer vers le haut"
	L["Multiple Displays"] = "Graphiques multiples"
	L["Multiple Triggers"] = "Déclencheur multiples"
	L["Multiselect ignored tooltip"] = [=[
|cFFFF0000Ignoré|r - |cFF777777Unique|r - |cFF777777Multiple|r
Cette option ne sera pas utilisée pour déterminer quand ce graphique doit être chargé]=]
	L["Multiselect multiple tooltip"] = [=[
|cFF777777Ignoré|r - |cFF777777Unique|r - |cFF00FF00Multiple|r
Plusieurs valeurs peuvent être choisies]=]
	L["Multiselect single tooltip"] = [=[
|cFF777777Ignoré|r - |cFF00FF00Unique|r - |cFF777777Multiple|r
Seule une unique valeur peut être choisie]=]
	L["Name Info"] = "Info du nom"
	--[[Translation missing --]]
	L["Name Pattern Match"] = "Name Pattern Match"
	--[[Translation missing --]]
	L["Name(s)"] = "Name(s)"
	L["Negator"] = "Pas"
	L["Never"] = "Jamais"
	L["New"] = "Nouveau"
	--[[Translation missing --]]
	L["New Value"] = "New Value"
	L["No"] = "Non"
	L["No Children"] = "Pas d'Enfants"
	L["No tooltip text"] = "Pas d'infobulle"
	L["None"] = "Aucun"
	L["Not all children have the same value for this option"] = "Tous les enfants n'ont pas la même valeur pour cette option"
	L["Not Loaded"] = "Non chargé"
	L["Offer a guided way to create auras for your class"] = "Un guide pour aider à créer des auras pour votre classe."
	L["Okay"] = "Okay"
	L["On Hide"] = "Au masquage"
	L["On Init"] = "À l'initialisation"
	L["On Show"] = "A l'affichage"
	L["Only match auras cast by people other than the player"] = "Ne considérer que les auras lancées par d'autres que le joueur"
	--[[Translation missing --]]
	L["Only match auras cast by people other than the player or his pet"] = "Only match auras cast by people other than the player or his pet"
	L["Only match auras cast by the player"] = "Ne considérer que les auras lancées par le joueur"
	--[[Translation missing --]]
	L["Only match auras cast by the player or his pet"] = "Only match auras cast by the player or his pet"
	L["Operator"] = "Opérateur"
	--[[Translation missing --]]
	L["Option #%i"] = "Option #%i"
	--[[Translation missing --]]
	L["Option %i"] = "Option %i"
	--[[Translation missing --]]
	L["Option key"] = "Option key"
	--[[Translation missing --]]
	L["Option Type"] = "Option Type"
	L["Options will open after combat ends."] = "Les options s'ouvriront après la fin du combat."
	L["or"] = "ou"
	L["or Trigger %s"] = "ou Déclencheur %s"
	L["Orange Rune"] = "Rune orange"
	L["Orientation"] = "Orientation"
	L["Outline"] = "Contour"
	L["Overflow"] = "Débordement"
	--[[Translation missing --]]
	L["Overlay %s Info"] = "Overlay %s Info"
	--[[Translation missing --]]
	L["Overlays"] = "Overlays"
	L["Own Only"] = "Le mien uniquement"
	L["Paste Action Settings"] = "Coller les Paramètres d'Action"
	L["Paste Animations Settings"] = "Coller les Paramètres d'Animation"
	--[[Translation missing --]]
	L["Paste Author Options Settings"] = "Paste Author Options Settings"
	L["Paste Condition Settings"] = "Coller les Paramètres de Condition"
	--[[Translation missing --]]
	L["Paste Custom Configuration"] = "Paste Custom Configuration"
	L["Paste Display Settings"] = "Coller les Paramètres d'Affichage"
	L["Paste Group Settings"] = "Coller les Paramètres du Groupe"
	L["Paste Load Settings"] = "Coller les Paramètres de Chargement"
	L["Paste Settings"] = "Coller Paramètres"
	L["Paste text below"] = "Coller le texte ci-dessous"
	L["Paste Trigger Settings"] = "Coller les Paramètres de Déclenchements"
	L["Play Sound"] = "Jouer un son"
	L["Portrait Zoom"] = "Zoom Portrait"
	L["Position Settings"] = "Paramètres de Position"
	--[[Translation missing --]]
	L["Preferred Match"] = "Preferred Match"
	L["Preset"] = "Preset"
	L["Prevents duration information from decreasing when an aura refreshes. May cause problems if used with multiple auras with different durations."] = "Empêche l'info de durée de décroitre quand une aura est rafraichie. Peut causer des problèmes si utilisé avec plusieurs auras de différentes durées."
	L["Processed %i chars"] = "Traité %i caractères"
	L["Progress Bar"] = "Barre de progression"
	--[[Translation missing --]]
	L["Progress Bar Settings"] = "Progress Bar Settings"
	L["Progress Texture"] = "Texture de progression"
	--[[Translation missing --]]
	L["Progress Texture Settings"] = "Progress Texture Settings"
	L["Purple Rune"] = "Rune violette"
	L["Put this display in a group"] = "Mettre cet affichage dans un groupe"
	L["Radius"] = "Rayon"
	L["Re-center X"] = "Recentrer X"
	L["Re-center Y"] = "Recentrer Y"
	L["Regions of type \"%s\" are not supported."] = "Les régions de type \"%s\" ne sont pas prises en charge."
	L["Remaining Time"] = "Temps restant"
	L["Remaining Time Precision"] = "Précision du temps restant"
	L["Remove"] = "Retirer"
	L["Remove this display from its group"] = "Retirer cet affichage de son groupe"
	L["Remove this property"] = "Retirer cette propriété"
	L["Rename"] = "Renommer"
	L["Repeat After"] = "Répéter Après"
	L["Repeat every"] = "Répéter tous les"
	L["Required for Activation"] = "Requis pour l'activation"
	--[[Translation missing --]]
	L["Reset all options in this group to their default values."] = "Reset all options in this group to their default values."
	--[[Translation missing --]]
	L["Reset all options to their default values."] = "Reset all options to their default values."
	--[[Translation missing --]]
	L["Reset ALL to Defaults"] = "Reset ALL to Defaults"
	--[[Translation missing --]]
	L["Reset to Defaults"] = "Reset to Defaults"
	L["Right 2 HUD position"] = "Position ATH Droite 2"
	L["Right HUD position"] = "Position ATH Droite"
	L["Right Text"] = "Texte de droite"
	L["Right-click for more options"] = "Clic-droit pour plus d'options"
	L["Rotate"] = "Tourner"
	L["Rotate In"] = "Rotation entrante"
	L["Rotate Out"] = "Rotation sortante"
	L["Rotate Text"] = "Tourner le texte"
	L["Rotation"] = "Rotation"
	L["Rotation Mode"] = "Mode de rotation"
	L["Same"] = "Le même"
	L["Scale"] = "Échelle"
	L["Search"] = "Chrecher"
	L["Select the auras you always want to be listed first"] = "Choisissez les auras que vous voulez toujours voir apparaître en premier dans la liste"
	L["Send To"] = "Envoyer vers"
	--[[Translation missing --]]
	L["Separator"] = "Separator"
	--[[Translation missing --]]
	L["Separator Text"] = "Separator Text"
	--[[Translation missing --]]
	L["Separator text"] = "Separator text"
	L["Set Parent to Anchor"] = "Définir Parent à l'Ancrage"
	L["Set tooltip description"] = "Définir la description de l'info-bulle"
	--[[Translation missing --]]
	L["Sets the anchored frame as the aura's parent, causing the aura to inherit attributes such as visiblility and scale."] = "Sets the anchored frame as the aura's parent, causing the aura to inherit attributes such as visiblility and scale."
	L["Settings"] = "Paramètres"
	L["Shift-click to create chat link"] = "Maj-clic pour créer un lien de discussion"
	L["Show all matches (Auto-clone)"] = "Montrer toutes correspondances (Auto-Clone)"
	L["Show Cooldown Text"] = "Afficher le Texte du Temps de Recharge"
	--[[Translation missing --]]
	L["Show Glow Effect"] = "Show Glow Effect"
	--[[Translation missing --]]
	L["Show If Unit Does Not Exist"] = "Show If Unit Does Not Exist"
	L["Show If Unit Is Invalid"] = "Afficher Si l'Unité Est Invalide"
	--[[Translation missing --]]
	L["Show Matches for"] = "Show Matches for"
	--[[Translation missing --]]
	L["Show Matches for Units"] = "Show Matches for Units"
	L["Show model of unit "] = "Montrer le modèle de l'unité"
	L["Show On"] = "Afficher Sur"
	L["Show this group's children"] = "Afficher les enfants de ce groupe"
	L["Shows a 3D model from the game files"] = "Montre un modèle 3D tiré du jeu"
	L["Shows a custom texture"] = "Montre une texture personnalisée"
	L["Shows a progress bar with name, timer, and icon"] = "Affiche une barre de progression avec nom, temps, icône"
	L["Shows a spell icon with an optional cooldown overlay"] = "Affiche une icône de sort avec optionnellement la recharge sur-imprimée"
	L["Shows a texture that changes based on duration"] = "Affiche une texture qui change selon la durée"
	L["Shows one or more lines of text, which can include dynamic information such as progress or stacks"] = "Affiche une ligne de texte ou plus, qui peut inclure des infos dynamiques telles que progression ou piles."
	L["Simple"] = "Simple"
	L["Size"] = "Taille"
	--[[Translation missing --]]
	L["Skip this Version"] = "Skip this Version"
	--[[Translation missing --]]
	L["Slant Amount"] = "Slant Amount"
	--[[Translation missing --]]
	L["Slant Mode"] = "Slant Mode"
	--[[Translation missing --]]
	L["Slanted"] = "Slanted"
	L["Slide"] = "Glisser"
	L["Slide In"] = "Glisser entrant"
	L["Slide Out"] = "Glisser sortant"
	--[[Translation missing --]]
	L["Slider Step Size"] = "Slider Step Size"
	L["Small Icon"] = "Petite icône"
	L["Smooth Progress"] = "Progrès Doux"
	--[[Translation missing --]]
	L["Soft Max"] = "Soft Max"
	--[[Translation missing --]]
	L["Soft Min"] = "Soft Min"
	L["Sort"] = "Trier"
	L["Sound"] = "Son"
	L["Sound Channel"] = "Canal sonore"
	L["Sound File Path"] = "Chemin fichier son"
	L["Sound Kit ID"] = "ID Kit Son"
	L["Space"] = "Espacer"
	L["Space Horizontally"] = "Espacer horizontalement"
	L["Space Vertically"] = "Espacer verticalement"
	L["Spark"] = "Étincelle"
	L["Spark Settings"] = "Réglage Étincelle"
	L["Spark Texture"] = "Texture Étincelle"
	L["Specific Unit"] = "Unité spécifique"
	L["Spell ID"] = "ID de sort"
	L["Stack Count"] = "Nombre de Piles"
	L["Stack Info"] = "Info de Piles"
	L["Stacks"] = "Piles"
	L["Stacks Settings"] = "Réglages de Piles"
	L["Stagger"] = "Report"
	L["Star"] = "Étoile"
	L["Start"] = "Début"
	L["Start Angle"] = "Angle de départ"
	L["Status"] = "Statut"
	L["Stealable"] = "Volable"
	--[[Translation missing --]]
	L["Step Size"] = "Step Size"
	L["Sticky Duration"] = "Durée épinglée"
	--[[Translation missing --]]
	L["Stop ignoring Updates"] = "Stop ignoring Updates"
	L["Stop Sound"] = "Arrêter Son"
	L["Symbol Settings"] = "Réglages de symbole"
	L["Temporary Group"] = "Groupe temporaire"
	L["Text"] = "Texte"
	L["Text Color"] = "Couleur Texte"
	L["Text Position"] = "Position du Texte"
	--[[Translation missing --]]
	L["Text Settings"] = "Text Settings"
	L["Texture"] = "Texture"
	L["Texture Info"] = "Info Texture"
	--[[Translation missing --]]
	L["Texture Settings"] = "Texture Settings"
	--[[Translation missing --]]
	L["Texture Wrap"] = "Texture Wrap"
	L["The duration of the animation in seconds."] = "La durée de l'animation en secondes."
	L["The duration of the animation in seconds. The finish animation does not start playing until after the display would normally be hidden."] = "La durée de l'animation en quelques secondes. L'animation de fin ne commence qu'après le moment où l'affichage est normalement caché."
	L["The type of trigger"] = "Le type de déclencheur"
	L["Then "] = "Alors"
	--[[Translation missing --]]
	L["This adds %tooltip, %tooltip1, %tooltip2, %tooltip3 as text replacements."] = "This adds %tooltip, %tooltip1, %tooltip2, %tooltip3 as text replacements."
	--[[Translation missing --]]
	L["This aura has legacy aura trigger(s). Convert them to the new system to benefit from enhanced performance and features"] = "This aura has legacy aura trigger(s). Convert them to the new system to benefit from enhanced performance and features"
	L["This display is currently loaded"] = "Cet affichage est actuellement chargé"
	L["This display is not currently loaded"] = "Cet affichage n'est pas actuellement chargé"
	L["This region of type \"%s\" is not supported."] = "Cette région de type \"%s\" n'est pas supportée."
	--[[Translation missing --]]
	L["This setting controls what widget is generated in user mode."] = "This setting controls what widget is generated in user mode."
	L["Time in"] = "Temps entrant"
	L["Tiny Icon"] = "Très petite icône"
	--[[Translation missing --]]
	L["To Frame's"] = "To Frame's"
	L["to group's"] = "au groupe..."
	--[[Translation missing --]]
	L["To Personal Ressource Display's"] = "To Personal Ressource Display's"
	--[[Translation missing --]]
	L["To Screen's"] = "To Screen's"
	L["Toggle the visibility of all loaded displays"] = "Change la visibilité de tous les graphiques chargés"
	L["Toggle the visibility of all non-loaded displays"] = "Change la visibilité de tous les graphiques non-chargés"
	L["Toggle the visibility of this display"] = "Activer/Désactiver la visibilité de cet affichage"
	L["Tooltip"] = "Infobulle"
	--[[Translation missing --]]
	L["Tooltip Content"] = "Tooltip Content"
	L["Tooltip on Mouseover"] = "Infobulle à la souris"
	--[[Translation missing --]]
	L["Tooltip Pattern Match"] = "Tooltip Pattern Match"
	--[[Translation missing --]]
	L["Tooltip Text"] = "Tooltip Text"
	--[[Translation missing --]]
	L["Tooltip Value"] = "Tooltip Value"
	--[[Translation missing --]]
	L["Tooltip Value #"] = "Tooltip Value #"
	L["Top HUD position"] = "Position ATH Haute"
	L["Top Text"] = "Texte du Haut"
	L["Total Time Precision"] = "Précision Temps total"
	L["Trigger"] = "Déclencheur"
	L["Trigger %d"] = "Déclencheur %d"
	L["Trigger %s"] = "Déclencheur %s"
	L["True"] = "Vrai"
	L["Type"] = "Type"
	L["Ungroup"] = "Dissocier"
	L["Unit"] = "Unité"
	--[[Translation missing --]]
	L["Unit Count"] = "Unit Count"
	L["Unlike the start or finish animations, the main animation will loop over and over until the display is hidden."] = "Contrairement aux animations de début et de fin, l'animation principale bouclera tant que le graphique est visible."
	L["Up"] = "Vers le haut"
	--[[Translation missing --]]
	L["Update "] = "Update "
	L["Update Custom Text On..."] = "Mettre à jour Texte Perso sur..."
	L["Update in Group"] = "Mettre à jour dans le Groupe"
	L["Update this Aura"] = "Mettre à jour cette Aura"
	L["Use Full Scan (High CPU)"] = "Utiliser Scan Complet (CPU élevé)"
	L["Use nth value from tooltip:"] = "Utilisez la nième valeur de l'info-bulle:"
	L["Use SetTransform"] = "Utiliser SetTransform"
	L["Use tooltip \"size\" instead of stacks"] = "Utiliser la \"taille\" de l'infobulle plutôt que la pile"
	L["Use Tooltip Information"] = "Utiliser l'information de la boite de dialogue"
	L["Used in Auras:"] = "Utilisé(e) dans les Auras:"
	L["Used in auras:"] = "Utilisé dans les auras:"
	L["Value %i"] = "Valeur %i"
	L["Values are in normalized rgba format."] = "Les valeurs sont normalisées dans le format rvba"
	L["Values:"] = "Valeurs:"
	L["Version: "] = "Version: "
	L["Vertical Align"] = "Aligner verticalement"
	L["Vertical Bar"] = "Barre verticale"
	L["View"] = "Vue"
	--[[Translation missing --]]
	L["Wago Update"] = "Wago Update"
	L["Width"] = "Largeur"
	L["X Offset"] = "Décalage X"
	L["X Rotation"] = "Rotation X"
	L["X Scale"] = "Echelle X"
	L["Y Offset"] = "Décalage Y"
	L["Y Rotation"] = "Rotation Y"
	L["Y Scale"] = "Echelle Y"
	L["Yellow Rune"] = "Rune jaune"
	L["Yes"] = "Oui"
	L["You are about to delete %d aura(s). |cFFFF0000This cannot be undone!|r Would you like to continue?"] = "Vous êtes sur le point de supprimer %d aura. |cFFFF0000Cela ne peut pas être annulé! | r Voulez-vous continuer?"
	L["Z Offset"] = "Décalage Z"
	L["Z Rotation"] = "Rotation Z"
	L["Zoom"] = "Zoom"
	L["Zoom In"] = "Zoom entrant"
	L["Zoom Out"] = "Zoom sortant"
