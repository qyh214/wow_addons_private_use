-- Translate RCLootCouncil to your language at:
-- http://wow.curseforge.com/addons/rclootcouncil/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("RCLootCouncil", "frFR")
if not L then return end

L[" is not active in this raid."] = "n'est pas activé pour ce raid."
L[" you are now the Master Looter and RCLootCouncil is now handling looting."] = "vous êtes le maître du butin et RCLootCouncil gère à présent le butin."
L["&p was awarded with &i for &r!"] = "&p a reçu &i pour &r !"
--Translation missing 
-- L["2 Piece"] = ""
--Translation missing 
-- L["2nd Tier Piece"] = ""
--Translation missing 
-- L["4 Piece"] = ""
--Translation missing 
-- L["4th Tier Piece"] = ""
L["A format to copy/paste to another player."] = "Format à copier/coller à un autre joueur."
L["A new session has begun, type '/rc open' to open the voting frame."] = "Une nouvelle session a débuté, tapez '/rc open' pour ouvrir la fenêtre de vote."
L["A tab delimited output for Excel. Might work with other spreadsheets."] = "Format pour Excel, délimité par des onglets. Peut également fonctionner avec d'autres tableurs."
L["Abort"] = "Annuler"
L["Accept Whispers"] = "Autoriser les chuchotements"
L["accept_whispers_desc"] = "Permet aux joueurs de vous chuchoter leur(s) objet(s) équipé(s) pour qu'il(s) soit(-ent) ajouté à la fenêtre de vote."
L["Active"] = "Activé"
L["active_desc"] = "Décocher pour désactiver RCLootCouncil. Cette option est utile si vous faites partie d'un groupe de raid, mais que vous n'y participez pas. Remarque : cette option est réinitialisée après chaque déconnexion."
L["Add Item"] = "Ajouter un objet"
L["Add Note"] = "Ajouter une note"
L["Add ranks"] = "Ajouter des rangs"
L["Add rolls"] = "Ajouter un lancer de dés"
--Translation missing 
-- L["Add Rolls"] = ""
L["add_ranks_desc"] = "Définir le rang minimum pour pouvoir participer au conseil du butin :"
L["add_ranks_desc2"] = [=[Sélectionnez un rang ci-dessus pour ajouter au conseil tous les membres de ce rang et au-dessus.
Cliquez sur les rangs à gauche pour ajouter des joueurs précis au conseil.
Cliquez sur l'onglet 'Conseil actuel' pour afficher votre sélection.]=]
--Translation missing 
-- L["add_rolls_desc"] = ""
L["All items"] = "Tous les objets"
L["All items has been awarded and  the loot session concluded"] = "Tous les objets ont été attribués, la session de butin est terminée"
--Translation missing 
-- L["All items usable by the candidate"] = ""
--Translation missing 
-- L["All unawarded items"] = ""
L["Alt click Looting"] = "Butin en Alt-clic"
L["alt_click_looting_desc"] = "Active le butin en Alt-clic, c.-à-d. qu'une session sera lancée en laissant appuyer le bouton Alt et en cliquant (clic gauche) avec la souris sur un objet."
L["Alternatively, flag the loot as award later."] = "Sinon, désigner le butin comme devant être attribué plus tard."
L["Always use RCLootCouncil when I'm Master Looter"] = "Toujours utiliser RCLootCouncil lorsque je suis maître du butin"
L["Always use when leader"] = "Toujours utiliser lorsque je suis chef"
--Translation missing 
-- L["always_show_tooltip_howto"] = ""
L["Announce Awards"] = "Annoncer les attributions"
L["Announce Considerations"] = "Annoncer les objets en examen"
--Translation missing 
-- L["announce_&i_desc"] = ""
--Translation missing 
-- L["announce_&l_desc"] = ""
--Translation missing 
-- L["announce_&n_desc"] = ""
--Translation missing 
-- L["announce_&p_desc"] = ""
--Translation missing 
-- L["announce_&r_desc"] = ""
--Translation missing 
-- L["announce_&s_desc"] = ""
--Translation missing 
-- L["announce_&t_desc"] = ""
L["announce_awards_desc"] = "Active l'annonce des attributions dans la fenêtre de discussion."
L["announce_awards_desc2"] = [=[Choisissez dans quel(s) canal(-aux) vous voulez que les annonces soient faites et quel message y soit annoncé.
Utilisez &p en lieu du nom du joueur à qui l'objet est attribué, &i pour l'objet attribué et &r pour le motif.]=]
L["announce_considerations_desc"] = "Active, à chaque début de session, l'annonce des objets en train d'être examinés."
L["announce_considerations_desc2"] = [=[Définissez le canal dans lequel vous voulez que les annonces soient faites et quel message y soit annoncé.
Votre message servira d'en-tête à la liste d'objets.]=]
--Translation missing 
-- L["announce_item_string_desc"] = ""
L["Announcements"] = "Annonces"
L["Anonymous Voting"] = "Vote anonyme"
L["anonymous_voting_desc"] = "Activer le vote anonyme, c.-à-d. que les joueurs ne verront pas qui a voté pour qui."
L["Append realm names"] = "Ajouter le nom du royaume"
L["Are you sure you want to abort?"] = "Êtes-vous certain de vouloir quitter ?"
L["Are you sure you want to give #item to #player?"] = "Êtes-vous certain de vouloir attribuer %s à %s ?"
--Translation missing 
-- L["Are you sure you want to reannounce all unawarded items to %s?"] = ""
--Translation missing 
-- L["Are you sure you want to request rolls for all unawarded items from %s?"] = ""
L["Armor Token"] = "Jeton d'armure"
L["Ask me every time I become Master Looter"] = "Me demander à chaque fois que je suis maître du butin"
L["Ask me when leader"] = "Me demander lorsque je suis chef"
L["Auto Award"] = "Attribution automatique"
L["Auto Award to"] = "Attribuer automatiquement à"
L["Auto awarded 'item'"] = "%s a été attribué automatiquement"
L["Auto Close"] = "Fermeture Auto"
L["Auto Enable"] = "Activation automatique"
--Translation missing 
-- L["Auto extracted from whisper"] = ""
L["Auto Open"] = "Ouverture automatique"
L["Auto Pass"] = "Passer automatiquement"
L["Auto pass BoE"] = "Passer automatiquement sur les objets LqE"
--Translation missing 
-- L["Auto Pass Trinkets"] = ""
L["Auto Start"] = "Lancement automatique"
L["auto_award_desc"] = "Active l'attribution automatique."
L["auto_award_to_desc"] = "Joueur à qui les objets seront automatiquement attribués. Une liste de sélection des membres du raid s'affichera si vous êtes dans un groupe de raid. "
L["auto_close_desc"] = "Cocher pour fermer la fenêtre de vote automatiquement lorsque le Maître de Butin termine la session"
L["auto_enable_desc"] = "Cochez cette case pour que le butin soit toujours géré par RCLootCouncil. En laissant cette case vide, l'add-on vous demandera à chaque fois que vous entrez dans un raid ou que vous êtes nommé maître du butin si vous voulez l'utiliser."
L["auto_loot_desc"] = "Active la fouille automatique de tous les objets pouvant être équipés"
L["auto_open_desc"] = "Cochez cette case pour que la fenêtre de vote s'ouvre automatiquement lorsque nécessaire. La fenêtre de vote peut indifféremment être ouverte en tapant /rc open. Remarque : cette option nécessite la permission du maître du butin."
L["auto_pass_boe_desc"] = "Décocher pour ne jamais passer automatiquement sur des objets liés quand équipés."
L["auto_pass_desc"] = "Cocher pour passer automatiquement sur les objets inutilisables par votre classe."
--Translation missing 
-- L["auto_pass_trinket_desc"] = ""
L["auto_start_desc"] = "Active le lancement automatique, c.-à-d. qu'une session sera lancée avec tous les objets éligibles. En désactivant cette option, une liste d'objets modifiable s'affichera avant chaque début de session. "
--Translation missing 
-- L["Autoloot all BoE"] = ""
L["Autoloot BoE"] = "Butin automatique des LqE"
L["autoloot_BoE_desc"] = "Active la fouille automatique des objets LqE (liés quand équipés)."
--Translation missing 
-- L["autoloot_others_BoE_desc"] = ""
--Translation missing 
-- L["autoloot_others_item_combat"] = ""
L["Autopass"] = "Passer automatiquement"
L["Autopassed on 'item'"] = "Vous avez automatiquement passé sur %s"
L["Autostart isn't supported when testing"] = "Le lancement automatique n'est pas pris en charge dans la fonction de test"
L["award"] = "attribuer"
L["Award"] = "Attribuer"
L["Award Announcement"] = "Annonces des attributions"
L["Award for ..."] = "Attribuer à ..."
--Translation missing 
-- L["Award later"] = ""
--Translation missing 
-- L["Award later isn't supported when testing."] = ""
L["Award later?"] = "Attribuer plus tard ?"
L["Award Reasons"] = "Motifs de l'attribution"
L["award_reasons_desc"] = [=[Motifs d'attribution ne pouvant être choisis lors de la sélection d'une réponse.
Utilisés lorsque vous modifiez une réponse en passant par le menu du clic droit ou en cas d'attribution automatique.]=]
--Translation missing 
-- L["Awarded"] = ""
--Translation missing 
-- L["Awarded item cannot be awarded later."] = ""
L["Awards"] = "Attributions"
L["Background"] = "Fond"
L["Background Color"] = "Couleur de fond"
L["Banking"] = "La banque"
L["BBCode export, tailored for SMF."] = "Exporter en BBCode, adapté pour SMF."
L["Border"] = "Bordure"
L["Border Color"] = "Couleur de bordure"
L["Button"] = "Bouton"
L["Buttons and Responses"] = "Boutons et réponses"
L["buttons_and_responses_desc"] = [=[Configurer les boutons de réponse qui s'afficheront dans la fenêtre de butin des joueurs.
L'ordre des réponses ci-dessous détermine l'ordre dans lequel seront triées les réponses dans la fenêtre de vote, et s'affiche de gauche à droite dans la fenêtre de butin. Utilisez le curseur pour définir le nombre de boutons que vous voulez voire apparaître (max. %d).
Un bouton 'Passer' est automatiquement ajouté tout à droite.]=]
L["Candidate didn't respond on time"] = "Le candidat n'a pas répondu dans le temps imparti."
L["Candidate has disabled RCLootCouncil"] = "Le candidat a désactivé RCLootCouncil"
L["Candidate is not in the instance"] = "Le candidat n'est pas dans l'instance"
L["Candidate is selecting response, please wait"] = "Le candidat est en train de répondre, veuillez patienter."
L["Candidate removed"] = "Candidat retiré"
--Translation missing 
-- L["Candidates that can't use the item"] = ""
L["Cannot autoaward:"] = "Attribution automatique impossible :"
L["Cannot give 'item' to 'player' due to Blizzard limitations. Gave it to you for distribution."] = "Impossible d'attribuer %s à %s en raisons des restrictions fixées par Blizzard. L'objet vous a été attribué pour que vous puissiez le distribuer."
--Translation missing 
-- L["Change Award"] = ""
L["Change Response"] = "Modifier la réponse"
L["Changing loot threshold to enable Auto Awarding"] = "Le seuil de qualité est en train d'être modifié afin que l'attribution automatique puisse être activée"
L["Changing LootMethod to Master Looting"] = "Le système de butin a été changé en Maître du butin"
L["channel_desc"] = "Le canal dans lequel sera envoyé le message."
L["chat tVersion string"] = "|cFF87CEFARCLootCouncil |cFFFFFFFFversion |cFFFFA500 %s - %s"
L["chat version String"] = "|cFF87CEFARCLootCouncil |cFFFFFFFFversion |cFFFFA500 %s"
--Translation missing 
-- L["chat_commands_add"] = ""
--Translation missing 
-- L["chat_commands_award"] = ""
--Translation missing 
-- L["chat_commands_config"] = ""
--Translation missing 
-- L["chat_commands_council"] = ""
--Translation missing 
-- L["chat_commands_history"] = ""
--Translation missing 
-- L["chat_commands_open"] = ""
--Translation missing 
-- L["chat_commands_reset"] = ""
--Translation missing 
-- L["chat_commands_sync"] = ""
--Translation missing 
-- L["chat_commands_test"] = ""
--Translation missing 
-- L["chat_commands_version"] = ""
--Translation missing 
-- L["chat_commands_whisper"] = ""
--Translation missing 
-- L["chat_commands_winners"] = ""
L["Check this to loot the items and distribute them later."] = "Cocher cette case pour récupérer les objets et les attribuer plus tard."
L["Check to append the realmname of a player from another realm"] = "Cocher pour ajouter le nom du royaume d'un joueur provenant d'un autre royaume"
L["Check to have all frames minimize when entering combat"] = "Cocher pour minimiser toutes les fenêtres en entrant en combat. "
L["Choose timeout length in seconds"] = "Fixer le délai de vote (en secondes)"
L["Choose when to use RCLootCouncil"] = "Choisir quand utiliser RCLootCouncil"
L["Clear Loot History"] = "Effacer l'historique du butin"
L["Clear Selection"] = "Effacer la sélection"
L["clear_loot_history_desc"] = "Supprimer la totalité de l'historique du butin."
L["Click to add note to send to the council."] = "Cliquer pour ajouter une note qui sera transmise au conseil."
--Translation missing 
-- L["Click to change your note."] = ""
L["Click to expand/collapse more info"] = "Cliquer pour afficher ou masquer des informations supplémentaires"
L["Click to switch to 'item'"] = "Cliquer pour passer à %s"
L["config"] = "configuration"
--Translation missing 
-- L["confirm_award_later_text"] = ""
L["confirm_usage_text"] = [=[|cFF87CEFA RCLootCouncil |r
Souhaitez-vous utiliser RCLootCouncil avec ce groupe ?]=]
--Translation missing 
-- L["Conqueror Token"] = ""
L["Could not Auto Award i because the Loot Threshold is too high!"] = "Attribution automatique de %s impossible car le seuil de qualité est trop élevé !"
L["Could not find 'player' in the group."] = "Le joueur %s n'a pas été trouvé dans le groupe."
L["Couldn't find any councilmembers in the group"] = "Aucun membre du conseil n'a été trouvé dans le groupe"
L["council"] = "conseil"
L["Council"] = "Conseil"
L["Current Council"] = "Conseil actuel"
L["current_council_desc"] = "Cliquer pour retirer certains joueurs du conseil."
L["Customize appearance"] = "Personnaliser l'apparence"
L["customize_appearance_desc"] = "Dans ce menu, vous pouvez entièrement personnaliser l'apparence de RCLootCouncil. Utilisez la fonction sauvegarder ci-dessus pour changer rapidement d'apparence."
--Translation missing 
-- L["Data Received"] = ""
L["Date"] = true
L["days and x months"] = "%s et %d mois"
L["days, x months, y years"] = "%s, %d mois et %d ans"
L["Delete Skin"] = "Supprimer l'apparence"
L["delete_skin_desc"] = "Supprimer l'apparence sélectionnée dans la liste."
L["Deselect responses to filter them"] = "Désélectionner les réponses avant de pouvoir les filtrer"
L["Diff"] = true
L["disenchant_desc"] = "Sélectionner cette option pour que ce motif soit choisi lorsque vous attribuez un objet par le biais du bouton 'Désenchanter'"
--Translation missing 
-- L["Done syncing"] = ""
L["Double click to delete this entry."] = "Double cliquez pour supprimer cette occurence."
L["Dropped by:"] = "Dépouillé sur :"
--Translation missing 
-- L["Edit Entry"] = ""
L["Enable Loot History"] = "Activer l'historique du butin"
--Translation missing 
-- L["Enable Relic Buttons"] = ""
--Translation missing 
-- L["Enable Tier Buttons"] = ""
L["Enable Timeout"] = "Activer le délai de vote"
L["enable_loot_history_desc"] = "Active l'historique. RCLootCouncil ne répertoriera rien si cette option est désactivée."
--Translation missing 
-- L["enable_relicbuttons_desc"] = ""
--Translation missing 
-- L["enable_tierbuttons_desc"] = ""
L["enable_timeout_desc"] = "Cocher pour activer le délai de vote dans la fenêtre de butin"
L["Enter your note:"] = "Saisissez votre note"
L["EQdkp-Plus XML output, tailored for Enjin import."] = "Exporter en EQdkp-Plus XML, adapté pour être importé sur Enjin."
L["Everyone have voted"] = "Tout le monde a voté"
L["Export"] = "Exporter"
--Translation missing 
-- L["Following items were registered in the award later list:"] = ""
L["Following winners was registered:"] = "Les vainqueurs suivants ont été répertoriés :"
--Translation missing 
-- L["Frame options"] = ""
L["Free"] = "Gratuit"
L["g1"] = true
L["g2"] = true
--Translation missing 
-- L["Gave the item to you for distribution."] = ""
L["General options"] = "Paramètres généraux"
L["Group Council Members"] = "Membres du groupe au conseil"
L["group_council_members_desc"] = "Ajouter au conseil des joueurs provenant d'un autre royaume ou d'une autre guilde."
L["group_council_members_head"] = "Ajouter au conseil des membres de votre groupe actuel."
L["Guild Council Members"] = "Membres de la guilde au conseil"
L["Hide Votes"] = "Masquer les votes"
L["hide_votes_desc"] = "Seuls les joueurs ayant déjà voté pourront voir le résultat des votes."
--Translation missing 
-- L["How to sync"] = ""
--Translation missing 
-- L["huge_export_desc"] = ""
L["Ignore List"] = "Objets ignorés"
L["Ignore Options"] = "Paramètres des objets ignorés"
L["ignore_input_desc"] = "Introduisez l'ID d'un objet pour l'ajouter à la liste des objets ignorés, empêchant ainsi à RCLootCouncil de l'ajouter à l'avenir à une session"
L["ignore_input_usage"] = "Cette fonction n'accepte que l'ID des objets (numéro)"
L["ignore_list_desc"] = "Objets ignorés par RCLootCouncil. Cliquez sur un objet pour le retirer de la liste."
L["ignore_options_desc"] = "Gérez quels objets devraient être ignorés par RCLootCouncil. Si vous ajoutez un objet qui n'a pas été mis en cache, vous devez changer d'onglet puis revenir dans celui-ci pour que vous puissiez voir l'objet en question apparaître dans la liste."
--Translation missing 
-- L["import_desc"] = ""
L["Item"] = "Objet"
--Translation missing 
-- L["'Item' is added to the award later list."] = ""
--Translation missing 
-- L["Item quality is below the loot threshold"] = ""
L["Item received and added from 'player'"] = "Objet reçu de %s et ajouté."
--Translation missing 
-- L["Item was awarded to"] = ""
L["Item(s) replaced:"] = "Objet(s) remplacés :"
--Translation missing 
-- L["item_in_bags_low_trade_time_remaining_reminder"] = ""
--Translation missing 
-- L["Items stored in the loot master's bag for award later cannot be awarded later."] = ""
L["Items under consideration:"] = "Objets en train d'être examinés"
L["Latest item(s) won"] = "Dernier(s) objet(s) attribué(s)."
L["leaderUsage_desc"] = "Utiliser les mêmes paramètres en entrant dans une instance en tant que chef"
L["Length"] = "Durée"
L["Log"] = "Journal"
L["log_desc"] = "Active le répertoriage dans l'historique du butin."
L["Loot announced, waiting for answer"] = "Butin divulgué, en attente d'une réponse"
L["Loot Everything"] = "Tout fouiller"
L["Loot History"] = "Historique du butin"
L["Loot won:"] = "Butin remporté :"
L["loot_everything_desc"] = "Active la fouille automatique des non-objets (p. ex. les montures, les jetons de sets de tier)"
L["loot_history_desc"] = [=[RCLootCouncil enregistre automatiquement les informations pertinentes durant les sessions.
Les données brutes sont enregistrées dans le fichier ".../SavedVariables/RCLootCouncil.lua".
Remarque : les joueurs autres que le maître du butin peuvent uniquement enregistrer les données qui leur sont envoyées par ce dernier.]=]
L["Looting options"] = "Paramètres de fouille"
L["Lower Quality Limit"] = "Seuil inférieur de qualité"
L["lower_quality_limit_desc"] = [=[Déterminez le seuil inférieur de qualité des objets qui seront automatiquement attribués (cette qualité est comprise).
Remarque : cette option prime le seuil de qualité par défaut. ]=]
L["Mainspec/Need"] = "Spécialisation principale / besoin"
L["Master Looter"] = "Maître du butin"
L["master_looter_desc"] = "Remarque : ces paramètres ne sont utilisés que lorsque vous êtes maître du butin."
L["Message"] = true
--Translation missing 
-- L["Message for each item"] = ""
L["message_desc"] = "Message à envoyer au canal prédéfini."
L["Minimize in combat"] = "Minimiser en combat"
L["Minor Upgrade"] = "Légère amél."
L["ML sees voting"] = "MdB voit les votes"
L["ml_sees_voting_desc"] = "Permet au maître du butin de voir qui a voté pour qui."
--Translation missing 
-- L["module_tVersion_outdated_msg"] = ""
--Translation missing 
-- L["module_version_outdated_msg"] = ""
L["Modules"] = true
L["More Info"] = "Plus d'info"
--Translation missing 
-- L["more_info_desc"] = ""
L["Multi Vote"] = "Vote multiple"
L["multi_vote_desc"] = "Active le vote multiple, ce qui permet aux votants de voter pour plusieurs candidats."
L["'n days' ago"] = "il y a %s"
L["Never use RCLootCouncil"] = "Ne jamais utiliser RCLootCouncil"
--Translation missing 
-- L["new_ml_bagged_items_reminder"] = ""
L["No (dis)enchanters found"] = "Aucun (dés)enchanteur trouvé"
L["No entries in the Loot History"] = "Aucune entrée dans l'historique du butin"
--Translation missing 
-- L["No entry in the award later list is removed."] = ""
L["No items to award later registered"] = "Aucun objet devant être attribué plus tard enregistré"
--Translation missing 
-- L["No recipients available"] = ""
L["No session running"] = "Aucune session en cours"
L["No winners registered"] = "Aucun vainqueur répertorié"
L["Not announced"] = "Non annoncé"
L["Not cached, please reopen."] = "Pas gardé en cache, veuillez rouvrir."
L["Not Found"] = "Introuvable"
--Translation missing 
-- L["Not in your guild"] = ""
L["Not installed"] = "Pas installé"
L["Notes"] = true
L["notes_desc"] = "Permet aux candidats d'envoyer une note au conseil en plus du choix de leur réponse."
L["Now handles looting"] = "Gère à présent l'attribution du butin"
L["Number of buttons"] = "Nombre de boutons"
--Translation missing 
-- L["Number of raids received loot from:"] = ""
L["Number of reasons"] = "Nombre de motifs"
L["Number of responses"] = "Nombre de réponses"
L["number_of_buttons_desc"] = "Glisser pour modifier le nombre de boutons."
L["number_of_reasons_desc"] = "Glisser pour modifier le nombre de motifs."
L["Observe"] = "Observateurs"
L["observe_desc"] = "Autorise aux joueurs qui ne sont pas membres du conseil de voir la fenêtre de vote. Ils ne pourront néanmoins pas prendre part au vote."
L["Offline or RCLootCouncil not installed"] = "Hors ligne ou RCLootCouncil n'est pas installé"
L["Offspec/Greed"] = "Spécialisation secondaire / cupidité"
L["Only use in raids"] = "N'utiliser qu'en raid"
L["onlyUseInRaids_desc"] = "Cocher pour que RCLootCouncil soit automatiquement désactivé en groupe."
L["open"] = "ouvrir"
L["Open the Loot History"] = "Ouvrir l'historique du butin"
L["open_the_loot_history_desc"] = "Cliquer pour ouvrir l'historique du butin."
--Translation missing 
-- L["Opens the synchronizer"] = ""
--Translation missing 
-- L["Other piece"] = ""
--Translation missing 
-- L["'player' can't receive 'type'"] = ""
--Translation missing 
-- L["'player' declined your sync request"] = ""
L["'player' has asked you to reroll"] = "%s a demandé que vous relanciez les dés"
L["'player' has ended the session"] = "%s a mis fin à la session"
--Translation missing 
-- L["'player' has rolled 'roll' for: 'item'"] = ""
--Translation missing 
-- L["'player' hasn't opened the sync window"] = ""
--Translation missing 
-- L["Player is not in the group"] = ""
--Translation missing 
-- L["Player is not in this instance or his inventory is full"] = ""
--Translation missing 
-- L["Player is not in this instance or is ineligible for this item"] = ""
--Translation missing 
-- L["Player is offline"] = ""
--Translation missing 
-- L["Please wait a few seconds until all data has been synchronized."] = ""
--Translation missing 
-- L["Please wait before trying to sync again."] = ""
--Translation missing 
-- L["Print Responses"] = ""
--Translation missing 
-- L["print_response_desc"] = ""
--Translation missing 
-- L["Protector Token"] = ""
L["Raw lua output. Doesn't work well with date selection."] = "Exporter données lua brutes. Ne fonctionne pas bien avec la sélection de dates."
--Translation missing 
-- L["RCLootCouncil - Synchronizer"] = ""
L["RCLootCouncil Loot Frame"] = "Fenêtre du butin de RCLootCouncil"
L["RCLootCouncil Loot History"] = "Historique du butin de RCLootCouncil"
L["RCLootCouncil Session Setup"] = "Paramétrage de session de RCLootCouncil"
L["RCLootCouncil Version Checker"] = "Vérificateur de version de RCLootCouncil"
L["RCLootCouncil Voting Frame"] = "Fenêtre de vote de RCLootCouncil"
--Translation missing 
-- L["rclootcouncil_trade_add_item_confirm"] = ""
L["Reannounce ..."] = "Réannoncer ..."
--Translation missing 
-- L["Reannounced 'item' to 'target'"] = ""
L["Reason"] = "Motif"
L["reason_desc"] = "Motif d'attribution qui sera indiqué dans l'historique du butin lorsqu'un objet sera automatiquement attribué."
--Translation missing 
-- L["Relic Buttons and Responses"] = ""
--Translation missing 
-- L["relic_buttons_desc"] = ""
L["Remove All"] = "Retirer tous les joueurs"
L["Remove from consideration"] = "Retirer de la liste"
L["remove_all_desc"] = "Retirer tous les membres du conseil"
--Translation missing 
-- L["Requested rolls for 'item' from 'target'"] = ""
L["Reset Skin"] = "Réinitialiser l'apparence"
L["Reset skins"] = "Réinitialiser les apparences"
L["reset_announce_to_default_desc"] = "Réinitialise tous les paramètres des annonces avec les paramètres par défaut."
L["reset_buttons_to_default_desc"] = "Réinitialise tous les boutons, les couleurs et les réponses avec les paramètres par défaut."
L["reset_skin_desc"] = "Réinitialiser les couleurs et le fond de l'apparence sélectionnée."
L["reset_skins_desc"] = "Réinitialiser les apparences par défaut."
L["reset_to_default_desc"] = "Réinitialise les motifs d'attribution avec les paramètres par défaut."
L["Response"] = "Réponse"
L["Response color"] = "Couleur de la réponse"
--Translation missing 
-- L["Response isn't available. Please upgrade RCLootCouncil."] = ""
--Translation missing 
-- L["Response options"] = ""
--Translation missing 
-- L["Response to 'item'"] = ""
--Translation missing 
-- L["Response to 'item' acknowledged as 'response'"] = ""
L["response_color_desc"] = "Définir une couleur pour la réponse."
--Translation missing 
-- L["Responses"] = ""
L["Responses from Chat"] = "Réponses de la fenêtre de discussion"
L["responses_from_chat_desc"] = [=[Dans le cas où un joueur n'a pas installé l'add-on (le bouton 1 sera utilisé par défaut si aucun mot-clef n'a été saisi).
Par exemple : "/w Nom_du_maître_du_butin [Objet] cupidité" indiquera que vous avez choisi l'option cupidité pour un objet.
Vous pouvez définir ci-dessous les mots-clef qui pourront être utilisés pour chaque bouton. Seuls les caractères A-Z, a-z et 0-9 sont acceptés dans les mots-clef. Tous les autres caractères sont considérés comme une séparation.
Les joueurs peuvent afficher une liste des mots-clef en chuchotant 'rchelp' au maître du butin une fois l'add-on activé (p. ex. dans un raid).
]=]
L["Save Skin"] = "Sauvegarder l'apparence"
L["save_skin_desc"] = "Donnez un nom à votre apparence puis appuyez sur \"Okay\" pour la sauvegarder. Vous pouvez écraser n'importe quelle autre apparence que celles par défaut."
L["Self Vote"] = "Vote pour soi"
L["self_vote_desc"] = "Permet aux votants de voter pour eux."
L["Send History"] = "Envoyer l'historique"
L["send_history_desc"] = "Envoyer les données à tous les membres du raid, que vous enregistriez vous-même les données ou non. RCLootCouncil n'enverra de données que si vous êtes le maître du butin."
--Translation missing 
-- L["Sending 'type' to 'player'..."] = ""
L["Sent whisper help to 'player'"] = "Chuchotement d'aide envoyé à %s"
L["session_error"] = "Une erreur est survenue, veuillez relancer la session"
--Translation missing 
-- L["session_help_from_bag"] = ""
--Translation missing 
-- L["session_help_not_direct"] = ""
L["Set the text for button i's response."] = "Définir le texte pour la réponse du bouton %d"
L["Set the text on button 'number'"] = "Définir le texte du bouton %i"
L["Set the whisper keys for button i."] = "Définissez les mots-clef de chuchotement du bouton &d."
--Translation missing 
-- L["Show Spec Icon"] = ""
--Translation missing 
-- L["show_spec_icon_desc"] = ""
L["Silent Auto Pass"] = "Passer automatiquement (silencieux)"
L["silent_auto_pass_desc"] = "Cocher pour masquer les messages liés à la fonction \"passer automatiquement\""
L["Simple BBCode output."] = "Exporter en BBCode simple."
L["Skins"] = "Apparences"
L["skins_description"] = "Sélectionnez une des apparences par défaut ou créez en une vous-même. Ces options sont purement esthétiques. Ouvrez le vérificateur de version pour immédiatement voir les changements (\"/rc version\")."
--Translation missing 
-- L["Socket"] = ""
L["Something went wrong :'("] = "Une erreur s'est produite :'("
--Translation missing 
-- L["Something went wrong during syncing, please try again."] = ""
--Translation missing 
-- L["Sort Items"] = ""
--Translation missing 
-- L["sort_items_desc"] = ""
L["Standard .csv output."] = "Exporter en .csv standard."
L["Status texts"] = "Textes de statut"
--Translation missing 
-- L["Store in bag and award later"] = ""
--Translation missing 
-- L["Successfully imported 'number' entries."] = ""
--Translation missing 
-- L["Successfully received 'type' from 'player'"] = ""
--Translation missing 
-- L["Sync"] = ""
--Translation missing 
-- L["sync_detailed_description"] = ""
L["test"] = true
L["Test"] = true
L["test_desc"] = "Cliquer pour simuler pour vous et tous les membres de votre raid une session de butin où vous êtes le maître du butin."
L["Text color"] = "Couleur du texte"
L["Text for reason #i"] = "Texte du motif #"
L["text_color_desc"] = "Couleur du texte lorsqu'il sera affiché."
--Translation missing 
-- L["The award later list has been cleared."] = ""
--Translation missing 
-- L["The award later list is empty."] = ""
L["The following council members have voted"] = "Les membres du conseil suivants ont voté"
--Translation missing 
-- L["The following entries are removed from the award later list:"] = ""
--Translation missing 
-- L["The following items are removed from the award later list and traded to 'player'"] = ""
--Translation missing 
-- L["The item can only be looted by you but it is not bind on pick up"] = ""
--Translation missing 
-- L["The item will be awarded later"] = ""
L["The item would now be awarded to 'player'"] = "L'objet serait attribué à %s dans ces conditions"
L["The loot is already on the list"] = "Le butin fait déjà partie de la liste"
--Translation missing 
-- L["The loot master"] = ""
L["The Master Looter doesn't allow multiple votes."] = "Le maître du butin n'a pas autorisé le vote multiple."
L["The Master Looter doesn't allow votes for yourself."] = "Le maître du butin n'a pas autorisé de voter pour soi."
L["The session has ended."] = "La session est terminée."
L["This item"] = "Cet objet"
L["This item has been awarded"] = "Cet objet a été attribué"
L["Tier 19"] = true
L["Tier 20"] = true
--Translation missing 
-- L["Tier 21"] = ""
--Translation missing 
-- L["Tier Buttons and Responses"] = ""
--Translation missing 
-- L["Tier Piece that doesn't complete a set"] = ""
--Translation missing 
-- L["Tier Tokens ..."] = ""
L["Tier tokens received from here:"] = "Jetons d'armure obtenus dans cette instance :"
--Translation missing 
-- L["tier_buttons_desc"] = ""
L["tier_token_heroic"] = "Héroïque"
L["tier_token_mythic"] = "Mythique"
L["tier_token_normal"] = "Normal"
L["Time"] = "Temps"
L["Timeout"] = "Délai de vote"
--Translation missing 
-- L["Timeout when giving 'item' to 'player'"] = ""
--Translation missing 
-- L["To target"] = ""
L["Tokens received"] = "Jetons obtenus"
--Translation missing 
-- L["Total awards"] = ""
L["Total items received:"] = "Nombre total d'objets reçus :"
L["Total items won:"] = "Nombre total d'objets remportés :"
L["tVersion_outdated_msg"] = "La dernière version de test de RCLootCouncil est : %s"
--Translation missing 
-- L["Unable to give 'item' to 'player'"] = ""
L["Unable to give 'item' to 'player' - (player offline, left group or instance?)"] = "Impossible d'attribuer %s à %s - (joueur déconnecté, a quitté le groupe ou l'instance ?)"
L["Unable to give out loot without the loot window open."] = "Impossible d'attribuer d'objet sans que la fenêtre de butin ne soit ouverte."
--Translation missing 
-- L["Unawarded"] = ""
L["Unguilded"] = "Sans guilde"
L["Unknown date"] = "Date inconnue"
L["Unknown/Chest"] = "Inconnu / Plastron"
L["Unvote"] = "Annuler"
--Translation missing 
-- L["Upgrade to existing tier/random upgrade"] = ""
L["Upper Quality Limit"] = "Seuil supérieur de qualité"
L["upper_quality_limit_desc"] = [=[Déterminez le seuil supérieur de qualité des objets qui seront automatiquement attribués (cette qualité est comprise).
Remarque : cette option prime le seuil de qualité par défaut. ]=]
L["Usage"] = "Utilisation"
L["Usage Options"] = "Options d'utilisation"
--Translation missing 
-- L["Vanquisher Token"] = ""
L["version"] = true
L["Version"] = true
L["Version Check"] = "Vérifier la version"
L["version_check_desc"] = "Lance le module du vérificateur de version."
L["version_outdated_msg"] = "Votre version %s est dépassée. La dernière version est %s, veuillez mettre à jour RCLootCouncil."
L["Vote"] = "Voter"
L["Voters"] = "Votants"
L["Votes"] = true
L["Voting options"] = "Paramètres de vote"
L["Waiting for response"] = "En attente d'une réponse"
L["whisper_guide"] = "[RCLootCouncil] : numéro réponse [objet1] [objet2]. Numéro : numéro de l'objet que vous désirez. Réponse : un des mots-clef prédéfinis. Insérez le lien de(s) l'objet(s) en question (numéro) dans la fenêtre de discussion en ajoutant le mot-clef adéquat. Par exemple : en tapant '1 cupidité [objet1]', vous auriez choisi cupidité pour l'objet numéro 1."
L["whisper_guide2"] = "[RCLootCouncil] : vous recevrez un message de confirmation si vous avez été ajouté à la session."
L["whisper_help"] = [=[Les membres du raid peuvent utiliser le système de chuchotement si un joueur n'a pas installé cet add-on.
En chuchotant 'rchelp' au maître du butin, ils verront s'afficher un guide en plus d'une liste de mots-clef, qui peuvent être modifiés dans l'onglet 'Boutons et réponses'.
Le maître du butin est conseillé d'activer l'option 'Annoncer les objets en examen', puisque le numéro de chaque objet est nécessaire pour pouvoir utiliser le système de chuchotement.
Remarque : les joueurs devraient malgré tout installer l'add-on, sans quoi toutes les informations concernant les joueurs ne seront pas disponibles.]=]
L["whisperKey_greed"] = "cupidité, spésecondaire, offspé, os, 2"
L["whisperKey_minor"] = "petitup, petit, 3"
L["whisperKey_need"] = "besoin, spéprincipale, mainspé, ms, 1"
L["Windows reset"] = "Réinitialisation des fenêtres"
L["winners"] = "vainqueurs"
L["x days"] = "%d jours"
L["x out of x have voted"] = "%d sur %d ont voté"
L["You are not allowed to see the Voting Frame right now."] = "Vous n'êtes pas autorisé à voir la fenêtre de vote pour le moment."
L["You can only auto award items with a quality lower than 'quality' to yourself due to Blizaard restrictions"] = "En raison des restrictions fixées par Blizzard, vous ne pouvez vous attribuer automatiquement que des objets de qualité inférieure à %s."
L["You cannot initiate a test while in a group without being the MasterLooter."] = "Vous ne pouvez lancer de test dans un groupe sans être le maître du butin."
L["You cannot start an empty session."] = "Impossible de lancer une session vide."
L["You cannot use the menu when the session has ended."] = "Vous ne pouvez utiliser le menu si la session est terminée."
L["You cannot use this command without being the Master Looter"] = "Vous ne pouvez utiliser cette commande sans être le maître du butin"
L["You can't start a loot session while in combat."] = "Impossible de débuter une session de butin en combat."
L["You can't start a session before all items are loaded!"] = "Impossible de lancer une session tant que tous les objets n'ont pas été chargés !"
--Translation missing 
-- L["You haven't selected an award reason to use for disenchanting!"] = ""
L["You haven't set a council! You can edit your council by typing '/rc council'"] = "Vous n'avez pas choisi de conseil ! Vous pouvez modifier votre conseil en tapant '/rc council'"
--Translation missing 
-- L["You must select a target"] = ""
L["Your note:"] = "Votre note :"
L["You're already running a session."] = "Une session est déjà en cours"

