local L = LibStub("AceLocale-3.0"):NewLocale("WorldQuestTrackerAddon", "itIT") 
if not L then return end 

L["S_APOWER_AVAILABLE"] = "Disponibile"
L["S_APOWER_DOWNVALUE"] = "Le Missioni con %s scadono dopo il completamento della ricerca artefatto."
L["S_APOWER_NEXTLEVEL"] = "Prox Livello"
L["S_ENABLED"] = "Abilitato"
L["S_ERROR_NOTIMELEFT"] = "E' scaduto il tempo per questa missione."
--Translation missing 
-- L["S_ERROR_NOTLOADEDYET"] = ""
L["S_FLYMAP_SHOWTRACKEDONLY"] = "Solo Tracciati"
L["S_FLYMAP_SHOWTRACKEDONLY_DESC"] = "Mostra solo le missioni tracciate"
L["S_FLYMAP_SHOWWORLDQUESTS"] = "Mostra Missioni Mondiali"
--Translation missing 
-- L["S_MAPBAR_AUTOWORLDMAP"] = ""
L["S_MAPBAR_AUTOWORLDMAP_DESC"] = [=[Quando ti trovi a Dalaran o nell'Enclave di Classe, premendo 'M' viene mostrata la mappa delle Isole Disperse.

Premendo due volte 'M' viene mostrata la mappa corrente.]=]
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
L["S_MAPBAR_OPTIONSMENU_SHARE"] = "Condividi Add-on"
L["S_MAPBAR_OPTIONSMENU_SOUNDENABLED"] = "Abilita Suoni"
--Translation missing 
-- L["S_MAPBAR_OPTIONSMENU_STATUSBARANCHOR"] = ""
L["S_MAPBAR_OPTIONSMENU_TOMTOM_WPPERSISTENT"] = "Ricorda Tappe"
L["S_MAPBAR_OPTIONSMENU_TRACKER_CURRENTZONE"] = "Solo Questa Zona"
L["S_MAPBAR_OPTIONSMENU_TRACKER_SCALE"] = "Scala Tracciatore: %s"
L["S_MAPBAR_OPTIONSMENU_TRACKERCONFIG"] = "Tracciamento"
L["S_MAPBAR_OPTIONSMENU_TRACKERMOVABLE_AUTO"] = "Posizione Automatica"
L["S_MAPBAR_OPTIONSMENU_TRACKERMOVABLE_CUSTOM"] = "Posizione Personalizzata"
L["S_MAPBAR_OPTIONSMENU_TRACKERMOVABLE_LOCKED"] = "Bloccato"
L["S_MAPBAR_OPTIONSMENU_UNTRACKQUESTS"] = "Annulla Tracciamento"
L["S_MAPBAR_OPTIONSMENU_WORLDMAPCONFIG"] = "Mappa Continentale"
L["S_MAPBAR_OPTIONSMENU_YARDSDISTANCE"] = "Mostra Distanza in Iarde"
L["S_MAPBAR_OPTIONSMENU_ZONE_QUESTSUMMARY"] = "Sommario Missione (schermo intero)"
L["S_MAPBAR_OPTIONSMENU_ZONEMAPCONFIG"] = "Mappa Territoriale"
L["S_MAPBAR_RESOURCES_TOOLTIP_TRACKALL"] = "Clicca per tracciare tutte le missioni |cFFFFFFFF%s|r."
L["S_MAPBAR_SORTORDER"] = "Ordinamento"
--Translation missing 
-- L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_FADE"] = ""
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_OPTION"] = "Meno di %d Ore"
--Translation missing 
-- L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_SHOWTEXT"] = ""
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_SORTBYTIME"] = "Ordina per Tempo"
L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_TITLE"] = "Tempo Rimasto"
L["S_MAPBAR_SUMMARY"] = "Sommario"
L["S_MAPBAR_SUMMARYMENU_ACCOUNTWIDE"] = "Legata all'Account"
L["S_MAPBAR_SUMMARYMENU_MOREINFO"] = "Clicca per maggiori info"
--Translation missing 
-- L["S_MAPBAR_SUMMARYMENU_NOATTENTION"] = ""
L["S_MAPBAR_SUMMARYMENU_REQUIREATTENTION"] = "Richiede Attenzione"
L["S_MAPBAR_SUMMARYMENU_TODAYREWARDS"] = "Ricompense Odierne"
L["S_OVERALL"] = "Totale"
L["S_PARTY"] = "Gruppo"
--Translation missing 
-- L["S_PARTY_DESC1"] = ""
--Translation missing 
-- L["S_PARTY_DESC2"] = ""
L["S_PARTY_PLAYERSWITH"] = "Giocatori nel gruppo Con WQT:"
L["S_PARTY_PLAYERSWITHOUT"] = "Giocatori nel gruppo Senza WQT:"
L["S_QUESTSCOMPLETED"] = "Missioni Completate"
L["S_QUESTTYPE_ARTIFACTPOWER"] = "Potere Artefatto"
L["S_QUESTTYPE_DUNGEON"] = "Spedizione"
L["S_QUESTTYPE_EQUIPMENT"] = "Equipaggiamento"
L["S_QUESTTYPE_GOLD"] = "Oro"
--Translation missing 
-- L["S_QUESTTYPE_PETBATTLE"] = ""
L["S_QUESTTYPE_PROFESSION"] = "Professione"
L["S_QUESTTYPE_PVP"] = "PvP"
L["S_QUESTTYPE_RESOURCE"] = "Risorse"
L["S_QUESTTYPE_TRADESKILL"] = "Creazioni"
L["S_SHAREPANEL_THANKS"] = [=[Grazie per aver Condiviso World Quest Tracker!
Manda il nostro link ai tuoi amici su facebook, twitter o al colosseo.]=]
--Translation missing 
-- L["S_SHAREPANEL_TITLE"] = ""
L["S_SUMMARYPANEL_EXPIRED"] = "SCADUTO"
L["S_SUMMARYPANEL_LAST15DAYS"] = "Ultimi 15 Giorni"
--Translation missing 
-- L["S_SUMMARYPANEL_LIFETIMESTATISTICS_ACCOUNT"] = ""
--Translation missing 
-- L["S_SUMMARYPANEL_LIFETIMESTATISTICS_CHARACTER"] = ""
L["S_SUMMARYPANEL_OTHERCHARACTERS"] = "Altri Personaggi"
L["S_TUTORIAL_AMOUNT"] = "indica la quantità da ricevere"
L["S_TUTORIAL_CLICKTOTRACK"] = "Clicca per tracciare una missione."
L["S_TUTORIAL_CLOSE"] = "Chiudi Tutorial"
--Translation missing 
-- L["S_TUTORIAL_FACTIONBOUNTY"] = ""
--Translation missing 
-- L["S_TUTORIAL_FACTIONBOUNTY_AMOUNTQUESTS"] = ""
--Translation missing 
-- L["S_TUTORIAL_HOWTOADDTRACKER"] = ""
--Translation missing 
-- L["S_TUTORIAL_PARTY"] = ""
L["S_TUTORIAL_RARITY"] = "indica la rarità (comune, rara, epica)"
L["S_TUTORIAL_REWARD"] = "indica la ricompensa (equipaggiamento, oro, potere artefatto, risorse, reagenti)"
L["S_TUTORIAL_TIMELEFT"] = "indica il tempo rimasto (+4 ore, +90 minuti, + 30 minuti, meno di 30 minuti)"
L["S_TUTORIAL_WORLDMAPBUTTON"] = "Questo pulsante mostra la mappa delle Isole Disperse."
L["S_UNKNOWNQUEST"] = "Missione Sconosciuta"
L["S_WORLDQUESTS"] = "Missioni Mondiali"

