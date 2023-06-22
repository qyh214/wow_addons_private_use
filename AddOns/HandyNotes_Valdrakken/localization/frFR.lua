local L = LibStub("AceLocale-3.0"):NewLocale("HandyNotes_Valdrakken", "frFR", false, true)

if not L then return end
-- French localization by Zickwik ( https://www.curseforge.com/members/zickwik ) & Machou (https://github.com/Machou)
if L then
----------------------------------------------------------------------------------------------------
-----------------------------------------------CONFIG-----------------------------------------------
----------------------------------------------------------------------------------------------------

L["config_plugin_name"] = "Valdrakken"
L["config_plugin_desc"] = "Affiche les emplacements des PnJs et des endroits importants à Valdrakken sur la carte du monde et la mini-carte."

L["config_tab_general"] = "Général"
L["config_tab_scale_alpha"] = "Échelle / Transparence"
--L["config_scale_alpha_desc"] = "PH"
L["config_icon_scale"] = "Échelle de l’icône"
L["config_icon_scale_desc"] = "Échelle des icônes"
L["config_icon_alpha"] = "Transparence de l’icône"
L["config_icon_alpha_desc"] = "Transparence des icônes"
L["config_what_to_display"] = "Que souhaitez-vous afficher ?"
L["config_what_to_display_desc"] = "Ces paramètres déterminent le type d’icônes à afficher."

L["config_auctioneer"] = "Commissaire-priseur"
L["config_auctioneer_desc"] = "Affiche l’emplacement du commissaire-priseur."

L["config_banker"] = "Banque"
L["config_banker_desc"] = "Affiche l’emplacement de la banque."

L["config_barber"] = "Salon de coiffure"
L["config_barber_desc"] = "Affiche l’emplacement du salon de coiffure."

L["config_craftingorders"] = "Commandes d’artisanat"
L["config_craftingorders_desc"] = "Affiche l’emplacement des commandes d’artisanats."

L["config_flightmaster"] = "Maître de vol"
L["config_flightmaster_desc"] = "Affiche l’emplacement du maître de vol."

L["config_guildvault"] = "Coffre-fort de guilde"
L["config_guildvault_desc"] = "Affiche l’emplacement du coffre-fort de guilde."

L["config_innkeeper"] = "Aubergiste"
L["config_innkeeper_desc"] = "Affiche l’emplacement des aubergistes."

L["config_mail"] = "Boîte aux lettres"
L["config_mail_desc"] = "Affiche l’emplacement des boîtes aux lettres."

L["config_portal"] = "Portails"
L["config_portal_desc"] = "Affiche l’emplacement des portails."

L["config_portaltrainer"] = "Maître des Portails"
L["config_portaltrainer_desc"] = "Affiche l’emplacement du maître des portails des mages."

L["config_tpplatform"] = "Plateforme de téléportation"
L["config_tpplatform_desc"] = "Affiche l’emplacement de la plateforme de téléportation."

L["config_travelguide_note"] = "|cFFFF0000*Déjà actif via HandyNotes: TravelGuide.|r"

L["config_reforge"] = "Améliorations d’objets"
L["config_reforge_desc"] = "Affiche l’emplacement de l’améliorations d’objets."

L["config_rostrum"] = "Tribune de transformation"
L["config_rostrum_desc"] = "Affiche l’emplacement de la tribune de transformation."

L["config_stablemaster"] = "Maître des écuries"
L["config_stablemaster_desc"] = "Affiche l’emplacement du maître des écuries."

L["config_trainer"] = "Maître des métiers"
L["config_trainer_desc"] = "Affiche l’emplacements des maîtres des métiers."

L["config_transmogrifier"] = "Transmogrifieur"
L["config_transmogrifier_desc"] = "Affiche l’emplacement du transmogrifieur."

L["config_vendor"] = "Vendeurs"
L["config_vendor_desc"] = "Affiche l’emplacements des vendeurs."

L["config_void"] = "Chambre du Vide"
L["config_void_desc"] = "Affiche l’emplacement de la Chambre du Vide."

L["config_others"] = "Autres"
L["config_others_desc"] = "Affiche l’emplacements des autres endroits importants."

L["config_onlymytrainers"] = "Affiche uniquement les maîtres de métiers et vendeurs pour mes métiers"
L["config_onlymytrainers_desc"] = [[
N’affecte que les maîtres des métiers et les vendeurs de mes métiers principales.

|cFFFF0000NOTE: n’affecte uniquement lorsque 2 métiers ont été appris.|r
]]

L["config_fmaster_waypoint"] = "Point de passage du Maître de vol"
L["config_fmaster_waypoint_desc"] = "Définit automatiquement un point de passage au maître de vol si vous entrez dans l’Anneau de Transfert."

L["config_easy_waypoints"] = "Points de passages faciles"
L["config_easy_waypoints_desc"] = "Active la création simplifiée de points de passages.\nPermet de définir un point de passage par un Clic droit et d’accéder à plus d’options par Ctrel + Clic droit."

L["config_waypoint_dropdown"] = "Choisir"
L["config_waypoint_dropdown_desc"] = "Choisir comment le point de passage va être créé."
L["Blizzard"] = true
L["TomTom"] = true
L["Both"] = "Les deux"

L["config_picons"] = "Affiche les icônes de métiers pour :"
L["config_picons_vendor_desc"] = "Afficher les icônes de métiers pour les vendeurs au lieu des icônes des vendeurs."
L["config_picons_trainer_desc"] = "Afficher les icônes de métiers pour les maîtres de métiers au lieu des icônes des maîtres de métiers."
L["config_use_old_picons"] = "Affiche les anciennes icônes de métiers"
L["config_use_old_picons_desc"] = "Affiche à nouveau les anciennes icônes de métiers au lieu des nouvelles (avant Dragonflight)."

L["config_restore_nodes"] = "Restaurer les nœuds cachés"
L["config_restore_nodes_desc"] = "Restaurez tous les nœuds qui étaient cachés via le menu contextuel."
L["config_restore_nodes_print"] = "Tous les nœuds cachés ont été restaurés"

----------------------------------------------------------------------------------------------------
-------------------------------------------------DEV------------------------------------------------
----------------------------------------------------------------------------------------------------

L["dev_config_tab"] = "DEV"

L["dev_config_force_nodes"] = "Force Nodes"
L["dev_config_force_nodes_desc"] = "Force the display of all nodes regardless of class, faction or covenant."

L["dev_config_show_prints"] = "Show print()"
L["dev_config_show_prints_desc"] = "Show print() messages in the chat window."

----------------------------------------------------------------------------------------------------
-----------------------------------------------HANDLER----------------------------------------------
----------------------------------------------------------------------------------------------------

--==========================================CONTEXT_MENU==========================================--

L["handler_context_menu_addon_name"] = "HandyNotes : Valdrakken"
L["handler_context_menu_add_tomtom"] = "Ajouter à TomTom"
L['handler_context_menu_add_map_pin'] = "Marque les waypoint sur la carte"
L["handler_context_menu_hide_node"] = "Masque cet endroit"

--============================================TOOLTIPS============================================--

L["handler_tooltip_requires"] = "Requis"
L["handler_tooltip_requires_level"] = "Nécessite au moins le niveau du joueur"
L["handler_tooltip_data"] = "RÉCUPÉRATION DES DONNÉES..."
L["handler_tooltip_quest"] = "Débloqué avec une quête"

----------------------------------------------------------------------------------------------------
----------------------------------------------DATABASE----------------------------------------------
----------------------------------------------------------------------------------------------------

L["Crafting Orders"] = true
L["Mailbox"] = "Boite aux lettres"
L["Portal to Orgrimmar"] = "Portail vers Orgrimmar"
L["Portal to Stormwind"] = "Portail vers Hurlevent"
L["Rostrum of Transformation"] = true
L["Teleport to Seat of the Aspects"] = true
L["Visage of True Self"] = true
L["Portal to Nazmir"] = "Portail vers Nazmir"
L["Portal to Tiragarde Sound"] = "Portail vers la rade de Tiragarde"
L["Portal to Uldum"] = "Portail vers Uldum"
L["Portal to Badlands"] = "Portail vers les terres Ingrates"

-- L["Portal to Dalaran"] = "Portail vers Dalaran"
-- L["Portal to Jade Forest"] = "Portail vers la forêt de Jade"
-- L["Portal to Shadowmoon Valley"] = "Portail vers la vallée d’Ombrelune"
end
