local L = LibStub("AceLocale-3.0"):NewLocale("WorldQuestTrackerAddon", "itIT") 
if not L then return end 

L["S_APOWER_AVAILABLE"] = "Disponibile"
L["S_APOWER_NEXTLEVEL"] = "Prossimo Livello"
L["S_DECREASESIZE"] = "Diminuisci le Dimensioni"
L["S_ENABLED"] = "Abilitato"
L["S_ERROR_NOTIMELEFT"] = "Il tempo per questa missione è scaduto."
L["S_ERROR_NOTLOADEDYET"] = "Questa quest non è ancora pronta, per favore aspetta qualche secondo. "
L["S_FACTION_TOOLTIP_SELECT"] = "Click: seleziona questa fazione"
L["S_FACTION_TOOLTIP_TRACK"] = "Shift + Click: tiene traccia delle quest di questa fazione"
L["S_FLYMAP_SHOWTRACKEDONLY"] = "Solo Tracciati"
L["S_FLYMAP_SHOWTRACKEDONLY_DESC"] = "Mostra solo le missioni tracciate"
L["S_FLYMAP_SHOWWORLDQUESTS"] = "Mostra Missioni Mondiali"
L["S_GROUPFINDER_ACTIONS_CANCEL_APPLICATIONS"] = "clicca per annullare le applicazioni....."
L["S_GROUPFINDER_ACTIONS_CANCELING"] = "Cancellando..."
L["S_GROUPFINDER_ACTIONS_CREATE"] = "Non hai trovato nessun gruppo?, Premi qui per crearne uno"
L["S_GROUPFINDER_ACTIONS_CREATE_DIRECT"] = "Crea un gruppo"
L["S_GROUPFINDER_ACTIONS_LEAVEASK"] = "Vuoi abbandonare il gruppo?"
L["S_GROUPFINDER_ACTIONS_LEAVINGIN"] = "Lasciando il gruppo in (clicca per lasciare adesso):"
L["S_GROUPFINDER_ACTIONS_RETRYSEARCH"] = "Riprova ricerca"
L["S_GROUPFINDER_ACTIONS_SEARCH"] = "clicca per iniziare la ricerca di un gruppo"
L["S_GROUPFINDER_ACTIONS_SEARCH_RARENPC"] = "Cerca un gruppo per uccidere questo raro"
L["S_GROUPFINDER_ACTIONS_SEARCH_TOOLTIP"] = "Unisciti ad un gruppo che stia facendo questa missione"
L["S_GROUPFINDER_ACTIONS_SEARCHING"] = "cercando..."
L["S_GROUPFINDER_ACTIONS_SEARCHMORE"] = "clicca per cercare altri membri per il gruppo"
L["S_GROUPFINDER_ACTIONS_SEARCHOTHER"] = "Lasciare l'attuale gruppo e cercarne un altro?"
L["S_GROUPFINDER_ACTIONS_UNAPPLY1"] = "premi qui per rimuovere la coda e creare un nuovo gruppo"
L["S_GROUPFINDER_ACTIONS_UNLIST"] = "premi qui per rimuovere dalla ricerca il tuo gruppo"
L["S_GROUPFINDER_ACTIONS_UNLISTING"] = "esco dalla ricerca..."
L["S_GROUPFINDER_ACTIONS_WAITING"] = "attendi..."
L["S_GROUPFINDER_AUTOOPEN_RARENPC_TARGETED"] = "Apri automaticamente quando il bersaglio e' di tipo raro"
--[[Translation missing --]]
L["S_GROUPFINDER_ENABLED"] = "Auto Open On New Quest"
--[[Translation missing --]]
L["S_GROUPFINDER_LEAVEOPTIONS"] = "Leave Group Options"
--[[Translation missing --]]
L["S_GROUPFINDER_LEAVEOPTIONS_AFTERX"] = "Leave After X Seconds"
--[[Translation missing --]]
L["S_GROUPFINDER_LEAVEOPTIONS_ASKX"] = "Don't Auto Leave, Just Ask for X Seconds"
--[[Translation missing --]]
L["S_GROUPFINDER_LEAVEOPTIONS_DONTLEAVE"] = "Don't Show Leave Panel"
--[[Translation missing --]]
L["S_GROUPFINDER_LEAVEOPTIONS_IMMEDIATELY"] = "Leave Immediately on Quest Completed"
--[[Translation missing --]]
L["S_GROUPFINDER_NOPVP"] = "Avoid PVP Servers"
--[[Translation missing --]]
L["S_GROUPFINDER_OT_ENABLED"] = "Show Buttons on the Objective Tracker"
--[[Translation missing --]]
L["S_GROUPFINDER_QUEUEBUSY"] = "you are already in a queue."
--[[Translation missing --]]
L["S_GROUPFINDER_QUEUEBUSY2"] = "couldn't show the group finder window: you're already in group or in queue."
--[[Translation missing --]]
L["S_GROUPFINDER_RESULTS_APPLYING"] = "There's %d remaining groups, click again"
--[[Translation missing --]]
L["S_GROUPFINDER_RESULTS_APPLYING1"] = "There's 1 remaining group to join, click again"
--[[Translation missing --]]
L["S_GROUPFINDER_RESULTS_FOUND"] = [=[found %d groups
click to start joining]=]
--[[Translation missing --]]
L["S_GROUPFINDER_RESULTS_FOUND1"] = [=[found 1 group
click to start joining]=]
--[[Translation missing --]]
L["S_GROUPFINDER_RESULTS_UNAPPLY"] = "%d applications remaining..."
--[[Translation missing --]]
L["S_GROUPFINDER_RIGHTCLICKCLOSE"] = "right click to close"
--[[Translation missing --]]
L["S_GROUPFINDER_SECONDS"] = "Seconds"
--[[Translation missing --]]
L["S_GROUPFINDER_TITLE"] = "Group Finder"
--[[Translation missing --]]
L["S_GROUPFINDER_TUTORIAL1"] = "Do world quests faster by joining a group doing the same quest!"
--[[Translation missing --]]
L["S_INCREASESIZE"] = "Increase Size"
L["S_MAPBAR_FILTER"] = "Filtro"
L["S_MAPBAR_FILTERMENU_FACTIONOBJECTIVES"] = "Obiettivi Fazione"
L["S_MAPBAR_FILTERMENU_FACTIONOBJECTIVES_DESC"] = "Mostra missioni fazioni anche se filtrate."
L["S_MAPBAR_OPTIONS"] = "Opzioni"
L["S_MAPBAR_OPTIONSMENU_ARROWSPEED"] = "Aggiornamento Indicatore"
L["S_MAPBAR_OPTIONSMENU_ARROWSPEED_HIGH"] = "Veloce"
L["S_MAPBAR_OPTIONSMENU_ARROWSPEED_MEDIUM"] = "Media"
L["S_MAPBAR_OPTIONSMENU_ARROWSPEED_REALTIME"] = "Tempo Reale"
L["S_MAPBAR_OPTIONSMENU_ARROWSPEED_SLOW"] = "Lenta"
L["S_MAPBAR_OPTIONSMENU_EQUIPMENTICONS"] = "Icone Equipaggiamento"
L["S_MAPBAR_OPTIONSMENU_QUESTTRACKER"] = "Abilita Tracciamento Missione"
L["S_MAPBAR_OPTIONSMENU_REFRESH"] = "Aggiorna"
L["S_MAPBAR_OPTIONSMENU_SOUNDENABLED"] = "Abilita Suoni"
--[[Translation missing --]]
L["S_MAPBAR_OPTIONSMENU_STATUSBAR_ONDISABLE"] = "use '/wqt statusbar' or the addon option under the Interface options to restore the statusbar."
--[[Translation missing --]]
L["S_MAPBAR_OPTIONSMENU_STATUSBAR_VISIBILITY"] = "Show Statusbar"
--[[Translation missing --]]
L["S_MAPBAR_OPTIONSMENU_STATUSBARANCHOR"] = "Anchor on Top"
L["S_MAPBAR_OPTIONSMENU_TRACKER_CURRENTZONE"] = "Solo Questa Zona"
L["S_MAPBAR_OPTIONSMENU_TRACKER_SCALE"] = "Scala Tracciatore: %s"
L["S_MAPBAR_OPTIONSMENU_TRACKERCONFIG"] = "Opzioni Tracciamento"
L["S_MAPBAR_OPTIONSMENU_TRACKERMOVABLE_AUTO"] = "Posizione Automatica"
L["S_MAPBAR_OPTIONSMENU_TRACKERMOVABLE_CUSTOM"] = "Posizione Personalizzata"
L["S_MAPBAR_OPTIONSMENU_TRACKERMOVABLE_LOCKED"] = "Bloccato"
L["S_MAPBAR_OPTIONSMENU_UNTRACKQUESTS"] = "Annulla Tutti i Tracciamenti"
L["S_MAPBAR_OPTIONSMENU_WORLDMAPCONFIG"] = "Opzioni Mappa Continentale"
L["S_MAPBAR_OPTIONSMENU_YARDSDISTANCE"] = "Mostra Distanza in Iarde"
L["S_MAPBAR_OPTIONSMENU_ZONE_QUESTSUMMARY"] = "Sommario Missione (schermo intero)"
L["S_MAPBAR_OPTIONSMENU_ZONEMAPCONFIG"] = "Opzioni Mappa Territoriale"
L["S_MAPBAR_RESOURCES_TOOLTIP_TRACKALL"] = "Clicca per tracciare tutte le missioni |cFFFFFFFF%s|r."
L["S_MAPBAR_SORTORDER"] = "Ordinamento"
--[[Translation missing --]]
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_FADE"] = "Fade Quests"
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_OPTION"] = "Meno di %d Ore"
--[[Translation missing --]]
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_SHOWTEXT"] = "Time Left Text"
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_SORTBYTIME"] = "Ordina per Tempo"
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_TITLE"] = "Tempo Rimanente"
L["S_MAPBAR_SUMMARYMENU_ACCOUNTWIDE"] = "Legata all'Account"
--[[Translation missing --]]
L["S_OPTIONS_ACCESSIBILITY"] = "Accessibility"
--[[Translation missing --]]
L["S_OPTIONS_ACCESSIBILITY_EXTRATRACKERMARK"] = "Extra Tracker Mark"
--[[Translation missing --]]
L["S_OPTIONS_ACCESSIBILITY_SHOWBOUNTYRING"] = "Show Bounty Ring"
--[[Translation missing --]]
L["S_OPTIONS_ANIMATIONS"] = "Do Animations"
--[[Translation missing --]]
L["S_OPTIONS_MAPFRAME_ALIGN"] = "Map Window Centralized"
--[[Translation missing --]]
L["S_OPTIONS_MAPFRAME_ERROR_SCALING_DISABLED"] = "You need to enable 'Map Window Scale' first, no value has changed."
--[[Translation missing --]]
L["S_OPTIONS_MAPFRAME_SCALE"] = "Map Window Scale"
--[[Translation missing --]]
L["S_OPTIONS_MAPFRAME_SCALE_ENABLED"] = "Enable Map Window Scaling"
--[[Translation missing --]]
L["S_OPTIONS_QUESTBLACKLIST"] = "Quest Blacklist"
--[[Translation missing --]]
L["S_OPTIONS_RESET"] = "Reset"
--[[Translation missing --]]
L["S_OPTIONS_SHOWFACTIONS"] = "Show Factions"
--[[Translation missing --]]
L["S_OPTIONS_TIMELEFT_NOPRIORITY"] = "No Priority by Time Left"
--[[Translation missing --]]
L["S_OPTIONS_TRACKER_RESETPOSITION"] = "Reset Position"
--[[Translation missing --]]
L["S_OPTIONS_WORLD_ANCHOR_LEFT"] = "Anchor to Left Side"
--[[Translation missing --]]
L["S_OPTIONS_WORLD_ANCHOR_RIGHT"] = "Anchor to Right Side"
--[[Translation missing --]]
L["S_OPTIONS_WORLD_DECREASEICONSPERROW"] = "Decrease Squares per Row"
--[[Translation missing --]]
L["S_OPTIONS_WORLD_INCREASEICONSPERROW"] = "Increase Squares per Row"
--[[Translation missing --]]
L["S_OPTIONS_WORLD_ORGANIZE_BYMAP"] = "Organize by Map"
--[[Translation missing --]]
L["S_OPTIONS_WORLD_ORGANIZE_BYTYPE"] = "Organize by Quest Type"
--[[Translation missing --]]
L["S_OPTIONS_ZONE_SHOWONLYTRACKED"] = "Only Tracked"
L["S_OVERALL"] = "Totale"
L["S_PARTY"] = "Gruppo"
--[[Translation missing --]]
L["S_PARTY_DESC1"] = "Quests with a blue star means all party members have the quest."
--[[Translation missing --]]
L["S_PARTY_DESC2"] = "If a red star is shown, a party member isn't elegible to world quests or doesn't have WQT installed yet."
L["S_PARTY_PLAYERSWITH"] = "Giocatori nel gruppo Con WQT:"
L["S_PARTY_PLAYERSWITHOUT"] = "Giocatori nel gruppo Senza WQT:"
L["S_QUESTSCOMPLETED"] = "Missioni Completate"
L["S_QUESTTYPE_ARTIFACTPOWER"] = "Potere Artefatto"
L["S_QUESTTYPE_DUNGEON"] = "Spedizione"
L["S_QUESTTYPE_EQUIPMENT"] = "Equipaggiamento"
L["S_QUESTTYPE_GOLD"] = "Oro"
L["S_QUESTTYPE_PETBATTLE"] = "Battaglia tra mascotte"
L["S_QUESTTYPE_PROFESSION"] = "Professione"
L["S_QUESTTYPE_PVP"] = "PvP"
L["S_QUESTTYPE_RESOURCE"] = "Risorse"
L["S_QUESTTYPE_TRADESKILL"] = "Creazioni"
--[[Translation missing --]]
L["S_RAREFINDER_ADDFROMPREMADE"] = "Add Rares Found on Premade Groups"
L["S_RAREFINDER_NPC_NOTREGISTERED"] = "NPC Raro non è nel Database"
L["S_RAREFINDER_OPTIONS_ENGLISHSEARCH"] = "Cerca solo in lingua Inglese"
L["S_RAREFINDER_OPTIONS_SHOWICONS"] = "Visualizza icona per i Rari Attivi"
L["S_RAREFINDER_SOUND_ALWAYSPLAY"] = "Suona lo stesso anche se gli effetti sonori sono disattivati"
L["S_RAREFINDER_SOUND_ENABLED"] = "Suona quando c'è un Raro nella minimappa"
--[[Translation missing --]]
L["S_RAREFINDER_SOUNDWARNING"] = "sound played due to a rare on the minimap, you may disable this sound at the options menu > rare finder sub menu."
--[[Translation missing --]]
L["S_RAREFINDER_TITLE"] = "Rare Finder"
--[[Translation missing --]]
L["S_RAREFINDER_TOOLTIP_REMOVE"] = "Remove"
--[[Translation missing --]]
L["S_RAREFINDER_TOOLTIP_SEACHREALM"] = "Search on other realms"
--[[Translation missing --]]
L["S_RAREFINDER_TOOLTIP_SPOTTEDBY"] = "Spotted By"
--[[Translation missing --]]
L["S_RAREFINDER_TOOLTIP_TIMEAGO"] = "minutes ago"
L["S_SUMMARYPANEL_EXPIRED"] = "SCADUTO"
L["S_SUMMARYPANEL_LAST15DAYS"] = "Ultimi 15 Giorni"
--[[Translation missing --]]
L["S_SUMMARYPANEL_LIFETIMESTATISTICS_ACCOUNT"] = "Account Life Time Statistics"
--[[Translation missing --]]
L["S_SUMMARYPANEL_LIFETIMESTATISTICS_CHARACTER"] = "Character Life Time Statistics"
L["S_SUMMARYPANEL_OTHERCHARACTERS"] = "Altri Personaggi"
L["S_TUTORIAL_AMOUNT"] = "indica la quantità da ricevere"
L["S_TUTORIAL_CLICKTOTRACK"] = "Clicca per tracciare una missione."
--[[Translation missing --]]
L["S_TUTORIAL_PARTY"] = "When in party, a blue star is shown on quests that all party members have!"
--[[Translation missing --]]
L["S_TUTORIAL_STATISTICS_BUTTON"] = "Click here to see statistics and a saved list of quests on other characters."
L["S_TUTORIAL_TIMELEFT"] = "indica il tempo rimasto (+4 ore, +90 minuti, + 30 minuti, meno di 30 minuti)"
--[[Translation missing --]]
L["S_TUTORIAL_WORLDBUTTONS"] = [=[Click here to cycle among three types of summaries:

- |cFFFFAA11By Quest Type|r
- |cFFFFAA11By Zone|r
- |cFFFFAA11None|r

Click |cFFFFAA11Toggle Quests|r to hide quest locations.]=]
L["S_TUTORIAL_WORLDMAPBUTTON"] = "Questo pulsante mostra la mappa delle Isole Disperse."
L["S_UNKNOWNQUEST"] = "Missione Sconosciuta"
L["S_WHATSNEW"] = "Cosa c'è di nuovo?"
L["S_WORLDBUTTONS_SHOW_TYPE"] = "Ordina per tipo"
--[[Translation missing --]]
L["S_WORLDBUTTONS_SHOW_ZONE"] = "Order by Zone"
--[[Translation missing --]]
L["S_WORLDBUTTONS_TOGGLE_QUESTS"] = "Toggle Quests"
--[[Translation missing --]]
L["S_WORLDMAP_QUESTLOCATIONS"] = "Show Quest Locations"
--[[Translation missing --]]
L["S_WORLDMAP_QUESTSUMMARY"] = "Show Quest Summary"
--[[Translation missing --]]
L["S_WORLDMAP_TOOLTIP_TRACKALL"] = "track all quests on this list"
L["S_WORLDQUESTS"] = "Missioni Mondiali"
