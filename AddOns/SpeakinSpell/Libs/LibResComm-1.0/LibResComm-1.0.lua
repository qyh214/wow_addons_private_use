--[[
	Name: LibResComm-1.0
	Revision: $Revision: 91 $
	Author(s): DathRarhek (Polleke) (polleke@gmail.com)
	Continued for Cataclysm by Myrroddin and Phanx
	Documentation: http://www.wowace.com/index.php/LibResComm-1.0
	SVN:  svn://svn.wowace.com/wow/librescomm-1-0/mainline/trunk
	Description: Keeps track of resurrection spells cast in the raid group
	Dependencies: LibStub, CallbackHandler-1.0
]]

local MAJOR_VERSION = "LibResComm-1.0"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 91 $"):match("%d+"))

local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

if lib.disable then
	lib.disable()
end

------------------------------------------------------------------------
--	Localization
--

local L = {
	-- use global string for locale independence
	CORPSE_OF = "^" .. CORPSE_TOOLTIP:gsub("%%s", "(.+)"),

	-- needs to match return values from HasSoulstone()
	["Reincarnate"] = USE_SOULSTONE or "Reincarnate",
	["Twisting Nether"] = GetSpellInfo(23701) or "Twisting Nether",
	["Use Soulstone"] = GetSpellInfo(3026) or "Use Soulstone",

	-- sensible text to show
	["Soulstone"] = GetItemInfo(5232) or "Soulstone",
}

local LOCALE = GetLocale()
if LOCALE == "deDE" then
L[" is OFF"] = "ist AUS"
L[" is ON"] = "ist AN"
L["/ss macro things you type"] = "Nur /ss makro Sachen die du schreibst"
L["_ Show All Types of Events _"] = "Zeige alle Typen von Ereignissen"
L["1. About SpeakinSpell"] = "1. Über SpeakinSpell"
L["1. Search..."] = "Suche..."
L["2. Select..."] = "Auswählen..."
L["3. Edit..."] = "Ändere..."
L["3.1.2.05 /macro"] = "macro"
L["3.2.2.02 <newline>"] = "<newline>"
L["3.2.2.14 Entering Combat"] = "Kampf beigetreten."
L["3.2.2.14 Exiting Combat"] = "Kampf verlassen."
L["3.2.2.14 Whispered While In-Combat"] = "Whispered While In-Combat"
L["A Battleground"] = "Ein Schlachtfeld"
L["a Guild Member"] = "ein Gildenmitglied."
L["A guild member said \"ding\""] = "Ein Gildenmitglied sagt \"ding\" "
L["A Party"] = "Eine Gruppe"
L["A party member said \"ding\""] = "Ein Gruppenmitglied sagt \"ding\" "
L["a player sent me a rez"] = "Ein Spieler hat mich wiederbelebt."
L["A Raid"] = "Einen Schlachtzug"
L["achievement"] = "Erfolg"
L["Achievement Earned by "] = "Erfolg erreicht von"
L["ad "] = "weitersagen "
L["ad /p"] = "weitersagen /p"
L["ad /ra"] = "weitersagen /ra"
L["ad /s"] = "weitersagen /s"
L["advertise"] = "weitersagen"
L["all automated SpeakinSpell announcements are disabled (except for /ss macro events)"] = "Alle automatischen SpeakinSpell Ansagen sind deaktiviert (Ausser /ss macro Ereignisse)"
L["All Ranks"] = "Alle Ränge"
L["All sending is complete (for now)"] = "Alles erfolgreich gesendet (vorerst)"
L["An empty template containing no data at all"] = "Eine leere Vorlage enthält keine Daten."
L["Any Rank"] = "Jeden Rang"
L["Anything you type here might be used as a substitution for <selected>"] = "Alles was du hier eingibst kann mit <selected> ausgetauscht werden."
L["Arcane"] = "Arkan"
L["Automatic event detection and announcements are disabled."] = "Automatische Ereigniserkennung und Ankündigungen sind deaktiviert."
L["Automatic event detection and announcements are enabled."] = "Automatische Ereigniserkennung und Ankündigungen sind aktiviert."
L["Auto-sync at Login"] = "Auto-Sync beim Einloggen"
L["Auto-Sync Options"] = "Auto-Sync Optionen"
L["Auto-Sync With Player"] = "Auto-Sync mit Spieler"
L["BATTLEGROUND"] = "Schlachtfeld (/bg)"
L["Begin /follow"] = "Beginne /folgen"
L["Buffs from Others (includes totems)"] = "Nur Buffs von Anderen"
L["By yourself"] = "von dir"
L["caster"] = "zauberwirker"
L["Changed Sub-Zone"] = "AndereSub-Zone"
L["Changed Zone"] = "andere Zone"
L["Channeled Spells Start"] = "Beginne Kanalisieren"
L["Channeled Spells Stop"] = "Beende Kanalisieren"
L["Chat Channel Colors"] = "Chat Kanal Faben"
L["Chat Event: "] = "Chat Ereignis:"
L["Chat Events"] = "Chat Ereignis"
L["Click here to create settings for a new spell, ability, effect, macro, or other event"] = "Klicke hier um Einstellungen für einen neuen Zauber, Fähigkeit, Effekt, Makro oder anderem Ereignis zu erstellen."
L["Click to go to the Import New Data screen to browse the speeches and <randomsub> lists that you've collected from others"] = "Klicke um anzusehen welche Daten du von von anderen gesammelt hast."
L["Click|r to toggle SpeakinSpell on/off"] = "Klicke um SpeakinSpell an oder aus zu schalten."
L["Collect and save speeches written by other SpeakinSpell users"] = "Sammle und speichere Speechen von anderen Usern."
L["Collect New Event Hooks"] = "Sammle neue Ereignissanhängepunkte"
L["Collect Speeches"] = "Sammle Speeches"
L["Colors"] = "Farben"
L["Combat Event: "] = "Kampfereignis"
L["COMM TRAFFIC RX"] = "Comm Traffic Received (Rx)"
L["COMM TRAFFIC TX"] = "Comm Traffic Sent (Tx)"
L["Cooldown (seconds)"] = "Abklingzeit bis zum nächsten Spruch (In Sekunden)."
L["create"] = "erstelle"
L["Create New..."] = "Erstelle neu..."
L["damage"] = "schaden"
L["Data Sharing"] = "Daten teilen"
L["Debuffs from Others"] = "Nur Debuffs von Anderen"
L["Default settings restored"] = "Standarteinstellungen wiederhergestellt."
L["Delete"] = "Löschen"
L["Delete all of the speeches for the selected event, INCLUDING read-only speeches"] = "Lösche alle Speeches für das ausgewählte Ereigniss, AUCH schreibgeschützte."
L["Delete All Speeches"] = "Lösche alle Speeches"
L["Delete the selected word list and <substitution> word"] = "Lösche die Ausgewählte Wortliste und <substitution> Wörter."
L["Delete this Event"] = "Dieses Ereignis löschen."
L["Delete this speech"] = "Diesen Speech löschen."
L["Delete Word List"] = "Lösche die Wortliste"
L["Diagnostics"] = "Diagnose."
L["Disable announcements for this Speech Event"] = "Ankündigung für dieses Speech-Ereignis deaktiveren."
L["Discovered <n> new event hooks from <sender> (<channel>)"] = "<n> neue Ereignis Hooks von <sender> entdeckt (<channel>)"
L[ [=[Do not announce this event more than once in a row for the same <target> name.

Note that for spells and events that only ever target you, you're name will never change, so this would limit the announcement to once per login session.]=] ] = [=[Aktiviere diesen Event höchstens einmal hintereinandern beim selben <target> namen.

Beachte, dass Zauber und Ereignisse welche nur dich als Ziel haben dann nur 1x pro Sitzung auftreten.]=]
L["DO NOT PRESS THIS BUTTON"] = "NIE DRÜCKEN (Ernsthaft, lass es!)"
L["EMOTE"] = "Emote (/em)"
L["Enable Automatic SpeakinSpell Event Announcements"] = "Aktiviere SpeakinSpell."
L[ [=[Enable this option to make SpeakinSpell show you (and only you) all of your own spell casting events and other events that can be announced.

This includes any spell, ability, item, /ss macro things, or automatically obtained effect (e.g. Trinkets or Talents) that you cast or use.]=] ] = [=[Aktiviere diese Funktion damit SpeakinSpell nur für dich sichtbar im Chat alle gewirkten Ereignisse anzeigt die SpeakinSpell automatisch erkennt.

Das beinhaltet alle Zauber, Fähigkeiten, Gegenstände oder selbstauslösende Effekte (z.B. Schmuckstücke oder Talente) die du benutzt oder automatisch wirkst.]=]
L[ [=[Enable whispering the announcement to the friendly <target> of your spell.

Non-spell Speech Events also have a <target>. This uses the same target as the <target> substitution, and will not whisper to yourself.]=] ] = [=[Aktiviere das Flüstern zu einem "freundlichen" Ziel.
Funktioniert nicht falls du einen Zauber oder eine Fähigkeit auf dich selbst wirkst, oder einen Feind anwählst.]=]
L["Entering Combat"] = "Kampf beigetreten."
L["Exiting Combat"] = "Kampf verlassen."
L["Fire"] = "Feuer"
L["Firestorm"] = "Feuersturm"
L["focus"] = "fokus"
L["Found a SpeakinSpell User <username> running v<version>"] = "SpeakinSpeall Benutzer <username> mit Version <version> gefunden"
L["Frost"] = "Frost"
L["General"] = "Allgemein"
L["General Settings"] = "Allgemeine Einstellungen."
L["General Settings for SpeakinSpell"] = "Allgemeine Einstellungen für SpeakinSpell."
L["Global Cooldown"] = "Globale Abklingzeit"
L["guild"] = "Gilde"
L["GUILD"] = "Guild (/g)"
L["help"] = "hilfe"
L["hm"] = "hm"
L["hms"] = "hms"
L["Holy"] = "Heilig"
L["home"] = "Zuhause"
L["In a Battleground"] = "... in einem Schlachtfeld bist."
L["In a Party"] = "... in einer Gruppe bist."
L["In a Raid"] = "... in einem Schlachtzug bist."
L["In Arena"] = "... in der Arena bist."
L["macro"] = "makro"
L["Message Settings"] = "Nachrichteneinstellungen"
L["messages"] = "nachrichten"
L["Misc. Event: "] = "Systemereignis: "
L["Misc. Events"] = "Nur Systemereignisse"
L["MYSTERIOUS VOICE"] = "[Mysterious Voice] whispers:"
L["options"] = "optionen"
L["PARTY"] = "Gruppe (/p)"
L["pet"] = "begleiter"
L["player"] = "spieler"
L["RAID"] = "Schlachtzug (/ra)"
L["RAID_BOSS_WHISPER"] = "Boss Whisper"
L["RAID_WARNING"] = "Schlachtzugswarnung (/sw)"
L["Random Chance (%)"] = "Prozentchance für das Auftreten eines Spruchs."
L["Random Speech <number>"] = "Zufälliger Spruch <number>."
L["Remove the selected spell from the list"] = "Löscht den ausgewählten Zauber/Fähigkeit oder das Ereignis von der Liste."
L["reset"] = "zurücksetzen"
L["SAY"] = "Sagen (/s)"
L["Select a Category of Events"] = "Wähle eine bestimmte Kategorie von Ereignissen."
L["Select a Speech Event"] = "Wähle einen Zauber/Fähigkeit oder ein anderes Ereignis."
L["Select a spell from the list to configure the random announcements for that spell."] = "Wähle einen hinzugefügten Zauber, eine Fähigkeit oder anderes Ereignis von der Liste um zufällige Sprüche dafür zu konfigurieren."
L["Select the channel to use for this spell, while..."] = "Wähle den Kanal aus in den der oben ausgewählte Zauber oder die Fähigkeit die Sprüche sendet, während du..."
L["Select the new spell event you want to announce in chat above, then push this button"] = "Wähle oberhalb das neue Ereignis, für das du Ansagen in den Chat einstellen willst und bestätige hiermit."
L["Select which channel to use for this spell while in a Battleground"] = "Wähle welcher Kanal für den oben ausgewählten Zauber oder die Fähigkeit genutzt wird, während du in einem Schlachtfeld bist."
L["Select which channel to use for this spell while in a Party"] = "Wähle welcher Kanal für den oben ausgewählten Zauber oder die Fähigkeit genutzt wird, während du in einer Gruppe bist."
L["Select which channel to use for this spell while in a Raid"] = "Wähle welcher Kanal für die Ansagen des oben ausgewählten Zauber oder die Fähigkeit genutzt wird, während du in einem Schlachtzug bist."
L["Select which channel to use for this spell while playing in the Arena"] = "Wähle welcher Kanal für den oben ausgewählten Zauber oder die Fähigkeit genutzt wird, während du in der Arena bist."
L["Select which channel to use for this spell while playing solo"] = "Wähle welcher Kanal für den oben ausgewählten Zauber oder die Fähigkeit genutzt wird, während du alleine bist."
L["Self Buffs (includes procs)"] = "Nur Selbstbuffs (Beinhaltet Proc-Effekte)"
L["Self Debuffs"] = "Nur Selbstdebuffs"
L["SELF RAID WARNING CHANNEL"] = "Self-Only Raid Warning"
L["Show Debugging Messages (verbose)"] = "Zeige ausführliche SpeakinSpell-Nachrichten zu Fehlersuche."
L["Show only this kind of event in the list below"] = "Zeige lediglich die ausgewählte Art von Ereignissen in der Liste unterhalb."
L["Silent"] = "Deaktiviert"
L["speakinspell"] = "speakinspell"
L["SPEAKINSPELL CHANNEL"] = "Self-Chat (SpeakinSpell:)"
L["SpeakinSpell Help"] = "SpeakinSpell Hilfe"
L["SpeakinSpell Loaded"] = "SpeakinSpell geladen."
L["spelllink"] = "zauberlink"
L["spellname"] = "zaubername"
L["spellrank"] = "zauberrang"
L["Spells, Abilities, and Items (Start Casting)"] = "Nur Zauber und Fähigkeiten"
L["ss"] = "ss"
L["Stop SpeakinSpell from announcing the selected spell or event"] = "Stoppe Ansagen für den angewählten Zauber/Fähigkeit oder das Ereignis."
L["Talk to Flight Master"] = "Flugmeister angesprochen"
L["Talk to Quest-Giver"] = "Questgeber angesprochen"
L["Talk to Trainer"] = "Lehrer angesprochen"
L["Talk to Vendor"] = "Verkäufer angesprochen"
L["target"] = "Ziel"
L["targetclass"] = "Zielklasse"
L["targetrace"] = "Zielrasse"
L["Test Event: "] = "Testereignis:"
L["Test Events"] = "Testereignisse"
L["text"] = "Text"
L["The Arena"] = "Testgebiet"
L["This is a list of all the detected spells, abilities, items, and procced effects which SpeakinSpell has seen you cast or receive recently."] = "Dies ist eine Liste von allen Zaubern, Fähigkeiten, Items, Proc-Effekten und anderen Ereignissen, welche Speakinspell kürzlich automatisch erkannt hat."
L["To prevent SpeakinSpell from speaking in the chat too often for this spell, you can set a cooldown for how many seconds must pass before SpeakinSpell will announce this spell again."] = [=[
Um zu verhindern das SpeakinSpell für den ausgewählten Zauber/Fähigkeit oder Ereignis zu oft Sprüche in den Chat sendet kann eine Abklingzeit festgesetzt werden. 

Damit kann man bestimmen, wieviele Sekunden vergangen sein müssen bis SpeakinSpell für diesen Zauber, die Fähigkeit oder das Ereignis erneut einen Spruch senden kann.]=]
L["Toggle showing single-line or multi-line edit boxes for speeches"] = "Umschalten zwischen ein- und mehrzeiligen Bearbeitungsfeldern."
L["Transfer Complete"] = "Übertragung beendet"
L["WARNING: can't execute protected command: <text>"] = "WARNUNG: Kann den verbotenen Befehl nicht ausführen: <text>"
L["When I buff myself with: "] = "Wenn ich mich selbst buffe mit: "
L["When I debuff myself with: "] = "Wenn ich mich selbst debuffe mit: "
L["When I Start Casting: "] = "Wenn ich das Zauberwirken starte: "
L["When I Type: /ss "] = "Wenn ich folgendes tippe: /ss "
L["When someone else buffs me with: "] = "Wenn sonst jemand mich bufft mit: "
L["When someone else debuffs me with: "] = "Wenn sonst jemand mich debufft mit: "
L["Whisper the message to your <target>"] = "Flüstere den Spruch zu deinem <Ziel>."
L[ [=[Write an announcement for this event.

Duplicates of speeches listed above will not be accepted]=] ] = "Gib hier etwas Witziges ein das gesagt werden soll."
L["YELL"] = "Schreien (/y)"
L[ [=[You have a random chance to say a message each time you use the selected spell, based on this selected percentage.

100% will always speak. 0% will never speak.]=] ] = [=[
Jedes mal wenn du den oben ausgewählten Zauber oder die Fähigkeit benutzt, hast du basierend auf deinem ausgewählten Prozentwert eine Chance einen Spruch in den Chat zu senden. 

Bei 100% erscheint immer ein Spruch, bei 0% niemals.]=]
elseif LOCALE == "esES" then
elseif LOCALE == "esMX" then
elseif LOCALE == "frFR" then
L[" is OFF"] = "est OFF"
L[" is ON"] = "est ON"
L["(<type>) <name>"] = "(<type>)<nom>"
L["*"] = "*"
L["* <player> <emotes> *"] = "* <player> <emotes> *"
L["/ss macro things you type"] = "/ss macro trucs que vous tapez"
L["[/ss guides]"] = "[/ss guides]"
L["[/ss recent]"] = "[/ss recent]"
L["[Click Here]"] = "[Cliquez ici]"
L["[Edit Speeches]"] = "[Éditer les paroles]"
L["[Mysterious Voice] whispers:"] = "[Une voix mystérieuse] chuchote: "
L["[Mysterious Voice] whispers: "] = "[Une voix mystérieuse] chuchote: "
L["[Setup New Event]"] = "[Configurer un nouvel évènement]"
L["_"] = "_"
L["_ Show All Types of Events _"] = "_ Monter tous les types d'évènements _"
L["_(.-)_"] = "_(.-)_"
L["|"] = "|"
L["<"] = "<"
L["<(.-)>"] = "<(.-)>"
L["<clickhere> to review recent events and speeches"] = "<cliquez> pour voir les événements recents"
L[">"] = ">"
L["1. About SpeakinSpell"] = "1. À propos de SpeakinSpell"
L["1. Search..."] = "1. Rechercher..."
L["2. Select..."] = "2. Sélectionner..."
L["3. Edit..."] = "3. Éditer..."
L["3.1.2.05 /macro"] = "macro"
L["3.2.2.02 <newline>"] = "<nouvelle ligne>"
L["3.2.2.14 Entering Combat"] = "Entrée en combat"
L["3.2.2.14 Exiting Combat"] = "Sortie de combat"
L["3.2.2.14 Whispered While In-Combat"] = "Chuchotement pendant un combat"
L["A Battleground"] = "Un champ de bataille"
L["a Guild Member"] = "un membre de guilde"
L["A guild member said \"ding\""] = "Un membre de guilde dit \"ding\""
L["A Party"] = "Un groupe"
L["A party member said \"ding\""] = "Un membre du groupe dit \"ding\""
L["a player sent me a rez"] = "un joueur veut me ressusciter"
L["A Raid"] = "Un raid"
L["achievement"] = "haut-fait"
L["Achievement Earned by "] = "Haut-fait accompli par "
L["Achievements"] = "Hauts-faits"
L["all automated SpeakinSpell announcements are disabled (except for /ss macro events)"] = "toutes les annonces automatiques de SpeakinSpell sont désactivées (mis à part les évènements de macros /ss)"
L["All Ranks"] = "Tous les rangs"
L["All sending is complete (for now)"] = "Tous les envois sont terminés (pour l'instant)"
L["ALT"] = "ALT"
L["An empty template containing no data at all"] = "Un modèle vide ne contenant aucune donnée"
L["Any Rank"] = "N'importe quel rang"
L["Anything you type here might be used as a substitution for <selected>"] = "Tout ce qui est écrit ic sert de substitution à <sélection>"
L["Arcane"] = "Arcane"
L["AUTO"] = "AUTO"
L["Automatic event detection and announcements are disabled."] = "La détection automatique des évènements et les annonces  sont désactivées."
L["Automatic event detection and announcements are enabled."] = "La détection automatique des évènements et les annonces  sont activées."
L["Auto-sync at Login"] = "Synchroniser automatiquement à la connection"
L["Auto-Sync Options"] = "Options de synchronisation automatique"
L["Auto-Sync With Player"] = "Synchroniser automatiquement avec le joueur"
L["BATTLEGROUND"] = "Champ de bataille (/cb)"
L["Begin /follow"] = "Début de /suivre"
L["Browse Collected Content"] = "Naviguer dans le contenu rassemblé"
L["Buffs from Others (includes totems)"] = "Améliorations des autres (totems inclus)"
L["BUILT-IN"] = "INTERNE"
L["By yourself"] = "Par vous-même"
L["c"] = "c"
L["caster"] = "caster"
L["Changed Sub-Zone"] = "Changement de sous-zone"
L["Changed Zone"] = "Changement de zone"
L["changes"] = "changements"
L["Channeled Spells Start"] = "Début de sort canalisé"
L["Channeled Spells Stop"] = "Arrêt des sorts canalisés"
L["Chat Channel Colors"] = "Couleurs des canaux de discussion"
L["Chat Event: "] = "Évènement de discussion:"
L["Chat Events"] = "Évènements de discussion"
L["class"] = "classe"
L["Click here to create settings for a new spell, ability, effect, macro, or other event"] = "Cliquez ici pour créer des paramètres pour un nouveau sort, capacité, effet, macro, ou autre évènement"
L["Click|r to toggle SpeakinSpell on/off"] = "Cliquez pour (dés-)activer SpeakinSpell"
L["Collect and save speeches written by other SpeakinSpell users"] = "Récupère et sauvegarde des paroles écrites par d'autres utilisateurs de SpeakinSpell"
L["Collect from others"] = "Récupérer depuis d'autres joueurs"
L["Collect Speeches"] = "Récupérer les paroles"
L["Collected Event Table (Speeches)"] = "Tableau des évènements récupérés (Paroles)"
L["Collected Random Substitutions"] = "Substitutions aléatoires récupérées"
L["Colors"] = "Couleurs"
L["colors"] = "couleurs"
L["Colors of SpeakinSpell's special chat channels."] = "Couleurs des canaux de discussion spéciaux de SpeakinSpell."
L["Colors used by SpeakinSpell"] = "Couleurs utilisées par SpeakinSpell"
L["Colors used in the SS options GUI"] = "Couleurs utilisées dans l'interface des options SS"
L["Combat Event: "] = "Évènement de combat:"
L["Combat Events"] = "Évènements de combat"
L["Cooldown (seconds)"] = "Temps de recharge (secondes)"
L["create"] = "créer"
L["damage"] = "dégâts"
L["Data format compatible with v >="] = "Format de données compatible avec v >="
L["Data Sharing"] = "Partage des données"
L["Data Sharing Event (Rx): "] = "Évènement de partage de données (réception): "
L["Data Sharing Event (Tx): "] = "Évènement de partage de données (émission): "
L["Data Sharing Events (Received)"] = "Évènement de partage de données (reçus)"
L["Data Sharing Events (Sent)"] = "Évènement de partage de données (émis)"
L["Debuffs from Others"] = "Affaiblissements des autres"
L["Default settings restored"] = "Paramètres par défauts restaurés"
L["Delete"] = "Supprimer"
L["Delete All Speeches"] = "Supprimer toutes les paroles"
L["desc"] = "description"
L["ding"] = "ding"
L["displaylink"] = "lien d'affichage"
L["displayname"] = "nom d'affichage"
L["Each of these packs contain new content which you might enjoy using in SpeakinSpell"] = "Chacun de ces packs contient du contenu nouveau que vous pourriez apprécier d'utiliser dans SpeakinSpell"
L["Each Packet Sent"] = "Chaque paquet envoyé"
L["Edit"] = "Éditer"
L["Edit Macro Event"] = "Éditer un évènement de macro"
L["Edit Speech / Announcement Settings"] = "Éditer les paramètres de paroles et d'annonces"
L["Edit Speeches"] = "Éditer les paroles"
L["EMOTE"] = "Émote (/em)"
L["Empty Template"] = "Modèle vide"
L["End /follow"] = "Fin de /suivre"
L["End Casting (I'm not involved)"] = "Fin d'incantation (je ne suis pas concerné)"
L["End Casting (I'm the caster)"] = "Fin d'incantation (j'ai incanté)"
L["End Casting (I'm the target)"] = "Fin d'incantation (je suis la cible)"
L["Enter Barber Chair"] = "Montée sur la chaise du coiffeur"
L["Entering Combat"] = "Entrée en combat"
L["eventtype"] = "type d'évènement"
L["eventtypeprefix"] = "préfixe du type d'évènement"
L["Exit Barber Chair"] = "Descente de la chaise du coiffeur"
L["Exiting Combat"] = "Sortie de combat"
L["Expand /ss macros as lists-only"] = "Étendre les macros /ss comme listes seules"
L["extremely"] = "extrêmement"
L["focus"] = "focus"
L["General"] = "Général"
L["General Auto-Sync"] = "Synchronisation automatique générale"
L["General Auto-Sync Failed"] = "La synchronisation automatique générale a échoué"
L["General Settings"] = "Paramètres généraux"
L["General Settings for SpeakinSpell"] = "Paramètres généraux pour SpeakinSpell"
L["Global Cooldown"] = "Temps de recharge global"
L["Global Sync"] = "Synchronisation globale"
L["guides"] = "guides"
L["guild"] = "guilde"
L["Headings"] = "Rubriques"
L["Help"] = "Aide"
L["help"] = "aide"
L["Hide"] = "Cacher"
L["hm"] = "hm"
L["hms"] = "hms"
L["home"] = "accueil"
L["However, \"/ss macro something\" will still trigger announcements if run manually"] = "Cependant, \"/ss macro machin\" va toujours déclencher des annonces si lancé manuellement"
L["I Died"] = "Je suis mort"
L["If you have an event trigger that does not appear to be firing, this option will tell you which setting silenced the announcement of that event, for example because it's on cooldown, or the random chance failed."] = "Si vous avez un déclencheur d'évènement qui n'a pas l'air de s'activer, cette option vous indiquera quel paramètre a empêché l'annoncement de cet évènement, par exemple parce qu'il est en recharge, ou parce que le tirage aléatoire ne l'a pas sélectionné."
L["import"] = "importer"
L["Import All Speech Events for the Selected Template"] = "Importer tous les évènements et les paroles pour le modèle sélectionné"
L["Import all speech events, and their speeches, for the selected content pack"] = "Importer tous les évènements et leurs paroles pour le pack de contenu sélectionné"
L["Import all speeches for the selected event"] = "Importer toutes les paroles pour l'évènement sélectionné"
L["Import All speeches for the Selected Speech Event"] = "Importer toutes les paroles pour le modèle sélectionné"
L["Import All Templates"] = "Importer tous les modèles"
L["Import All Words"] = "Importer tous les mots"
L["Import Events"] = "Importer les évènements"
L["Import From: "] = "Importer depuis: "
L["In a Battleground"] = "Dans un champ de bataille"
L["In a Party"] = "Dans un groupe"
L["In a Raid"] = "Dans un raid"
L["In Arena"] = "En arène"
L["In Wintergrasp"] = "Au Joug-d'Hiver"
L["Information"] = "Informations"
L["Interaction with NPCs"] = "Interaction avec les PNJs"
L["key"] = "clé"
L["lasttarget"] = "cible précédente"
L["Message Settings"] = "Paramètres des messages"
L["messages"] = "messages"
L["Misc. Event: "] = "Évènements divers: "
L["Misc. Events"] = "Évènements divers"
L["Mounts and Pets"] = "Montures et compagnons"
L["name"] = "nom"
L["Nature"] = "Nature"
L["network"] = "reseau"
L["Network Error"] = "Erreur de réseau"
L["No channels are available. For global syncs, join a guild, party, raid, or battleground."] = "Aucun canal n'est disponible. Pour les synchronisations globales, entrez dans une guilde, un groupe, un raid ou un champ de bataille."
L["No Matching Search Results Found"] = "Pas de résultats correspondants aux critères de recherche"
L["no speeches are defined"] = "aucune parole n'est définie"
L["no target selected"] = "aucune cible n'est sélectionnée"
L["NPC: "] = "PNJ: "
L[ [=[OFF = All of your characters will use separate lists of event triggers and random speeches, which you can copy from one to the other using "/ss import"

ON = All of your characters will share the same event triggers and speeches

Toggling this option will merge or split your settings between all of your characters]=] ] = [=[OFF = Tous vos personnages vont utiliser des listes d'évènements et de paroles aléatoires séparées, que vous pouvez copier de l'un à l'autre en utilisant "/ss import"

ON = Tous vos personnages vont partager les mêmes évènements et paroles.

Basculer cette option va fusionner ou séparer vos paramètres pour tous vos personnages.]=]
L["OFF|r"] = "OFF|r"
L["ON|r"] = "ON|r"
L["Open Gossip Window"] = "Ouverture d'une fenêtre de dialogue"
L["Open Mailbox"] = "Ouverture d'une boîte aux lettres"
L["Open the User's Manual"] = "Ouverture du manuel d'utilisateur"
L["Open Trade Window"] = "Ouverture d'une fenêtre d'échange"
L["options"] = "options"
L["overkill"] = "extermination"
L["pet"] = "familier"
L["player"] = "joueur"
L["playerclass"] = "classe du joueur"
L["playerfulltitle"] = "titre complet du joueur"
L["playerrace"] = "race du joueur"
L["playertitle"] = "titre du joueur"
L["points"] = "points"
L["r"] = "r"
L["race"] = "race"
L["RAID"] = "Raid (/ra)"
L["Raid Leader"] = "Chef de raid"
L["Raid Leadership Mode"] = "Mode de direction de raid"
L["Raid Officer"] = "Officier de raid"
L["Raid Officer Mode"] = "Mode d'officier de raid"
L["RAID_BOSS_WHISPER"] = "Chuchotement de boss"
L["RAID_WARNING"] = "Alerte de raid (/ar)"
L["Random"] = "Aléatoire"
L["random"] = "aléatoire"
L["Random Chance (%)"] = "Chance aléatoire (%)"
L["rank"] = "rang"
L["realm"] = "royaume"
L["Received new event hooks"] = "Réception de nouveaux évènements"
L["recent"] = "récent"
L["Recent Events Detected..."] = "Évènements récents détectés..."
L["Recent Speech Announcements..."] = "Annonces récentes..."
L["Remove the selected spell from the list"] = "Supprimer de la liste le sort sélectionné"
L["Report import processing results in the chat frame"] = "Indiquer les résultats du processus d'importation dans la fenêtre de discussion"
L["reset"] = "réinitialisation"
L["Reset Event List"] = "Liste des évènements récents"
L["Reset the list of event hooks to the default basic list, removing all discovered and collected event hooks"] = "Réinitialiser la liste des évènements à la liste basique par défaut, en supprimant tous les évènements découverts ou rassemblés"
L["Resurrection Events (LibResComm)"] = "Évènements de résurrection (LibResComm)"
L["Resurrection: "] = "Résurrection: "
L["reward"] = "récompense"
L["Right-click|r to open the options"] = "Click droit|r pour ouvrir les options"
L["scenario"] = "scénario"
L["school"] = "école"
L["Select a Category of Events"] = "Sélectionnez une catégorie d'évènements"
L["Select a Content Pack"] = "Sélectionnez un pack de contenu"
L[ [=[Select a Randomized Substitution

These substitutions may be used in speeches when announcing events, and a random result from the list below will be selected.]=] ] = [=[Sélectionnez une substitution aléatoire

Ces substitutions peuvent être utilisées dans les paroles des annonces d'évènements, une entrée aléatoire de la liste ci-dessous sera sélectionnée.]=]
L["Select a Speech Event"] = "Sélectionnez un évènement"
L["Select a spell from the list to configure the random announcements for that spell."] = "Sélectionnez un sort de la liste pour configurer les annonces aléatoires pour ce sort."
L["Select a Template"] = "Sélectionnez un modèle"
L["Select a topic..."] = "Sélectionnez un thème..."
L["Select and Create"] = "Sélectionner et créer"
L["Select the channel to use for this spell, while..."] = "Sélectionnez le canal à utiliser pour ce sort, pendant que..."
L["Select the new spell event you want to announce in chat above, then push this button"] = "Sélectionnez au-dessus le nouvel évènement que vous voulez annoncer dans la discussion, puis activez ce bouton"
L[ [=[Select the racial game language you want to use to announce these speeches

This option will be ignored if you set the "Always Use Common" option under general settings.]=] ] = [=[Selectionner la langue racial pour annoncer ces phrases
Option ignorée si "toujours en langue commune" activé dans les options générales.]=]
L["selected"] = "sélectionné"
L["Self Buffs (includes procs)"] = "Améliorations personnelles (procs inclus)"
L["Self Debuffs"] = "Affaiblissements personnels"
L["Self Raid Warnings"] = "Avertissements de raid personnels"
L["Self-Chat"] = "Discussion personnelle"
L["Send a data sharing request to GUILD, RAID, PARTY, and BATTLEGROUND channels every time you login or /reloadui"] = "Envoyer une requête de partage de données aux canaux GUILD, RAID, PARTY et BATTLEGROUND à chaque fois que vous vous connectez ou que vous rechargez l'interface (/reloadui)"
L[ [=[Send a data sharing request to GUILD, RAID, PARTY, and BATTLEGROUND channels.

Same as "/ss sync"]=] ] = [=[Envoyer une requête de partage de données aux canaux GUILD, RAID, PARTY et BATTLEGROUND.

Identique à "/ss sync"]=]
L[ [=[Send a data sharing request to your selected target.

Same as "/ss sync <target>"]=] ] = [=[Envoyer une requête de partage de données à votre cible.

Identique à "/ss sync <target>"]=]
L["Send Data"] = "Envoyer des données"
L["Share my speeches"] = "Partager mes paroles"
L["Share speeches and other data with other SpeakinSpell users"] = "Partager les paroles et autres données avec les autres utilisateurs de SpeakinSpell"
L["Share the speeches I have written for SpeakinSpell events"] = "Partager les paroles que j'ai écrites pour les évènements de SpeakinSpell"
L["Sharing vs. Privacy"] = "Partage et protection des renseignements personnels"
L["Show All Ranks"] = "Montrer tous les rangs"
L["Show Comm Traffic"] = "Montrer le trafic de communication"
L["Show Debugging Messages (verbose)"] = "Montrer les messages de débogage (verbeux)"
L["Show Import Progress"] = "Montrer la progression de l'importation"
L["speakinspell"] = "speakinspell"
L["spelllink"] = "lien du sort"
L["spellname"] = "nom du sort"
L["spellrank"] = "rang du sort"
L["ss"] = "ss"
L["subzone"] = "sous-zone"
L["swimmer"] = "nageur"
L["sync"] = "synchronisation"
L["sync "] = "synchronisation"
L["target"] = "cible"
L["targetclass"] = "classe de la cible"
L["targetrace"] = "race de la cible"
L["text"] = "texte"
L["the /ss macro would keep calling itself forever"] = "la macro /ss se serait appelée elle-même à l'infini"
L["the global cooldown is in effect"] = "le temps de rechargement global est en cours"
L["the random chance failed"] = "la chance aléatoire a échoué"
L["the selected chat channel is \"Silent\" while in <Scenario>"] = "le canal sélectionné est 'muet' quand vous êtes en <Scenario>"
L["this event trigger is disabled"] = "ce déclenchement d'évènement est désactivé"
L["this event trigger is limited to once per combat / once per out-of-combat"] = "ce déclenchement d'évènement est limité à un par combat / un par hors-combat"
L["this event trigger is limited to once per target (<target>)"] = "Ce déclencheur est limité à une fois par cible (<cible>)"
L["this event trigger's cooldown is in effect"] = "le temps de rechargement de ce déclencheur d'évènement est en cours"
L["tm"] = "tm"
L["toggle"] = "basculer"
L["type"] = "type"
L["very"] = "très"
L["What you say (Speeches)"] = "Ce que vous dites (paroles)"
L["When I buff myself with: "] = "Quand je lance l'amélioration suivante sur moi: "
L["When I debuff myself with: "] = "Lors d'un auto-débuff avec :"
L["When I Fail to Cast: "] = "Quand mon incantation échoue: "
L["When I Start Casting: "] = "Quand je commence à incanter: "
L["When I Start Channeling: "] = "Quand je commence à canaliser: "
L["When I Stop Casting: "] = "Quand je finis d'incanter: "
L["When I Stop Channeling: "] = "Quand je finis de canaliser: "
L["When I Successfully Cast: "] = "Quand je réussis à incanter: "
L["When I Type: /ss "] = "Quand je tape: /ss "
L["When I'm interrupted while casting: "] = "Lors de l'interruption de :"
L["When someone else buffs me with: "] = "Quand quelqu'un me buff avec :"
L["When someone else debuffs me with: "] = "Quand quelqu'un me débuff avec :"
L["Whisper the message to your <target>"] = "Chuchoter le message à <cible>"
L["Whispered While In-Combat"] = "Chuchoter en combat"
L["Wintergrasp"] = "Berceau-d'Hiver"
L["Wintergrasp GetZoneText"] = "Berceau-d'Hiver"
L[ [=[Write an announcement for this event.

Duplicates of speeches listed above will not be accepted]=] ] = [=[Écrivez une annonce pour cet évènement.

Les doubles de paroles listées ci-dessus ne seront pas acceptés]=]
L["YELL"] = "Crier (/y)"
L["You are already using all of the available content"] = "Vous utilisez déjà tout le contenu disponible"
L[ [=[You have a random chance to say a message each time you use the selected spell, based on this selected percentage.

100% will always speak. 0% will never speak.]=] ] = [=[Vous avez une chance aléatoire de dire un message chaque fois que vous utilisez le sort sélectionné, basée sur le pourcentage sélectionné.

100% parlera à chaque fois, 0% ne parlera jamais.]=]
L["Your friends"] = "Vos amis"
L["zone"] = "zone"
elseif LOCALE == "ruRU" then
L[" is OFF"] = "выключено"
L[" is ON"] = "включено"
L["*"] = "*"
L["* <player> <emotes> *"] = "* <игрок> <эмоция> *"
L["<"] = "<"
L["<(.-)>"] = "<(.-)>"
L["<clickhere> to review recent events and speeches"] = "<clickhere> чтобы увидеть последние события и фразы"
L["<creator's> random <susbtitution> word lists, shared with you over the network"] = "<creator's> random <susbtitution> списки слов, расшаренные через сеть"
L["<creator's> shared random substitutions"] = "<creator's> расшаренные случайные подстановки"
L["<creator's> shared speeches"] = "<creator's> расшаренные фразы"
L["<creator's> speeches, shared with you over the network"] = "<creator's> фразы, расшаренные через сеть"
L["<hidden> of <total> speeches are read-only / hidden"] = "<hidden> of <total> фразы только для чтения/скрытые"
L["<red>Don't<normalcolor> Use this Random Speech for the selected Event"] = "<red>Не<normalcolor> Используйте эту Случайную Фразу для выбранного События"
L["<red>Don't<normalcolor> Use this Random Word for the selected <substitution>"] = "<red>Не<normalcolor> Используйте эту Случайную Фразу для выбранной <substitution>"
L["<toon's> speeches (your alternate character on <realm>)"] = "<toon's> фразы (Ваш альт на <realm>)"
L[">"] = ">"
L["1. About SpeakinSpell"] = "1. Об аддоне SpeakinSpell"
L["1. Search..."] = "1. Поиск..."
L["2. Select..."] = "2. Выбор..."
L["3. Edit..."] = "3. Исправление..."
L["3.1.2.05 /macro"] = "макрос"
L["3.2.2.14 Entering Combat"] = "Вход в Битву"
L["3.2.2.14 Exiting Combat"] = "Выход из Битвы"
L["3.2.2.14 Whispered While In-Combat"] = "Получено сообщение в бою"
L["A Battleground"] = "Поле Боя"
L["A guild member said \"ding\""] = "Согильдиец сказал \"дзынь\""
L["A Party"] = "Группа"
L["A party member said \"ding\""] = "Член группы сказал \"дзынь\""
L["A Raid"] = "Рейд"
L["Achievement Earned by "] = "Достижение получено"
L["Achievements"] = "Достижения"
L["Added <randomkey>: <newword>"] = "Добавлено <randomkey>: <newword>"
L["Added speech: <speech>"] = "Добавлена фраза <speech>"
L["Added speeches for <displayname>"] = "Добавлены фразы для <displayname>"
L["Added word list for <keyword>"] = "Добавлен список слов для <keyword>"
L["All Ranks"] = "Все звания"
L["All sending is complete (for now)"] = "Отправка завершена(пока что)"
L["ALT"] = "Альт"
L["Always use <language>"] = "Всегда использовать <language>"
L["An empty template containing no data at all"] = "Пустой шаблон не содержащий никаких данных"
L["Announcement of \"<displaylink>\" was silenced because <reason>. <clickhere> to change this setting."] = "Сообщение \"<displaylink>\" было отключено потому что <reason>. <clickhere> чтобы изменить эту настройку"
L["Any Rank"] = "Любое звание"
L["Anything you type here might be used as a substitution for <selected>"] = "Все что вы наберете здесь может быть использовано для подстановки для <selected>"
L["Arcane"] = "Тайная магия"
L["AUTO"] = "Авто"
L["Automatic event detection and announcements are disabled."] = "Автоматическое обнаружение событий и объявления отключены"
L["Automatic event detection and announcements are enabled."] = "Автоматическое обнаружение событий и объявления включены"
L["Auto-sync at Login"] = "Авто-синхронизация при Входе"
L["Auto-Sync Options"] = "Настройки авто-синхронизации"
L["Auto-Sync With Player"] = "Авто-синхронизация с Игроком"
L["BATTLEGROUND"] = "Поле Боя(/пб)"
L["Begin /follow"] = "Начать /следовать"
L["Browse Collected Content"] = "Осмотреть собранный контент"
L["Buffs from Others (includes totems)"] = "Бафы от других(включая тотемы)"
L["BUILT-IN"] = "Встроенный"
elseif LOCALE == "koKR" then
L["/ss macro things you type"] = "/마법알림 매크로"
L["_ Show All Types of Events _"] = "_ 모든 형태의 이벤트를 보여줌 _"
L["<newline>"] = "<새줄>"
L["3.1.2.05 /macro"] = "macro"
L["3.2.2.02 <newline>"] = "<새줄>"
L["3.2.2.14 Entering Combat"] = "전투 시작"
L["3.2.2.14 Exiting Combat"] = "전투 종료"
L["3.2.2.14 Whispered While In-Combat"] = "Whispered While In-Combat"
L["ad "] = "광고 "
L["ad /p"] = "광고 /파"
L["ad /ra"] = "광고 /공"
L["ad /s"] = "광고 /말"
L["advertise"] = "광고"
L["Any Rank"] = "등급 무관"
L["BATTLEGROUND"] = "전장 (/bg)"
L["Buffs from Others (includes totems)"] = "타인으로부터의 버프들 (토템 포함)"
L["By yourself"] = "단독플레이"
L["caster"] = "시전자"
L["Changed Sub-Zone"] = "하위지역 변경"
L["Changed Zone"] = "지역 변경"
L["Click here to create settings for a new spell, ability, effect, macro, or other event"] = "새로운 마법, 능력, 효과, 매크로, 또는 다른 이벤트를 위한 설정을 만들려면 이곳을 클릭하시오"
L["COMM TRAFFIC RX"] = "Comm Traffic Received (Rx)"
L["COMM TRAFFIC TX"] = "Comm Traffic Sent (Tx)"
L["Cooldown (seconds)"] = "마법에 대한 알림 쿨타임 (초)"
L["create"] = "만들기"
L["Create New..."] = "새로 만들기..."
L["Debuffs from Others"] = "타인으로부터의 디버프들"
L["Default settings restored"] = "기본 설정 복구"
L[ [=[Do not announce this event more than once in a row for the same <target> name.

Note that for spells and events that only ever target you, you're name will never change, so this would limit the announcement to once per login session.]=] ] = [=[같은 <대상> 이름에 대해서 한번만 해당 이벤트를 알립니다. 

당신만을 대상으로 하는 마법이나 이벤트의 경우는 당신의 이름이 절대 바뀌지 않으므로 당신이 로그인 하고 나서 딱 한번만 알린다는 것을 고려하시기 바랍니다.]=]
L["Do not announce this event more than once until you either leave combat, or enter combat."] = "전투 시작 또는 전투 종료 둘중 하나가 이루어질때까지 해당 이벤트는 한번만 알립니다."
L["EMOTE"] = "감정표현 (/em)"
L["Enable Automatic SpeakinSpell Event Announcements"] = "SpeakinSpell 활성화"
L[ [=[Enable this option to make SpeakinSpell show you (and only you) all of your own spell casting events and other events that can be announced.

This includes any spell, ability, item, /ss macro things, or automatically obtained effect (e.g. Trinkets or Talents) that you cast or use.]=] ] = "당신 스스로 또는 타인에 의한 감지된 모든 이벤트를 볼 수 있도록 하기 위해서는 이 옵션을 활성화 시키시오.  이것은 당신이 시전하거나 사용한 어떠한 마법, 능력, 아이템, 또는 자동획득효과(예를 들어, 장신구 또는 특성)도 전부 포함한다.  이것은 아이템에 의해 시전된 마법이름은 일반적으로 아이템이름 자체가 아니기 때문에 이를 알아내는데 유용할 수 있다."
L[ [=[Enable whispering the announcement to the friendly <target> of your spell.

Non-spell Speech Events also have a <target>. This uses the same target as the <target> substitution, and will not whisper to yourself.]=] ] = [=[
당신의 마법대상에게 귓속말로 메세지를 전달하도록 활성화 한다. 당신 자신에게 마법을 사용할 경우에는 대상이 선택되어있다 할지라도 귓속말을 보내지 않는다.
]=]
L["Entering Combat"] = "전투 시작"
L["Exiting Combat"] = "전투 종료"
L["focus"] = "주시대상"
L["General Settings"] = "일반 설정"
L["General Settings for SpeakinSpell"] = "SpeakinSpell에 대한 일반 설정"
L["GUILD"] = "길드 (/g)"
L["help"] = "도움말"
L["In a Battleground"] = "전장"
L["In a Party"] = "파티"
L["In a Raid"] = "공격대"
L["In Arena"] = "투기장"
L["In Wintergrasp"] = "겨울손아귀 호수 전투중에"
L["Limit once per <target>"] = "<대상> 이름당 한번으로 제한"
L["Limit once per combat"] = "전투당 한번으로 제한"
L["macro"] = "매크로"
L["Message Settings"] = "메세지 설정"
L["messages"] = "메세지"
L["Misc. Event: "] = "시스템 이벤트: "
L["Misc. Events"] = "시스템 이벤트"
L["MYSTERIOUS VOICE"] = "[Mysterious Voice] whispers:"
L["options"] = "옵션"
L["PARTY"] = "파티 (/p)"
L["pet"] = "소환수"
L["player"] = "플레이어"
L["playertitle"] = "플레이어칭호"
L["RAID"] = "공격대 (/ra)"
L["RAID_BOSS_WHISPER"] = "Boss Whisper"
L["RAID_WARNING"] = "공격대 경보 (/rw)"
L["Random Chance (%)"] = "이 마법에 대한 문구를 얼마나 자주 알리고 싶은가?"
L["Random Speech <number>"] = "무작위 문구 <number>"
L["realm"] = "서버"
L["Remove the selected spell from the list"] = "선택된 마법을 목록에서 삭제합니다"
L["reset"] = "초기화"
L["SAY"] = "일반 (/s)"
L["Select a Category of Events"] = "이벤트의 종류를 선택하시오."
L["Select a Speech Event"] = "마법 또는 다른 이벤트를 선택하시오"
L["Select a spell from the list to configure the random announcements for that spell."] = "마법에 쓰여질 무작위 문구들을 설정하려면 목록에서 마법을 선택하시오."
L["Select the channel to use for this spell, while..."] = "... 에 있을때 이 마법알림에 사용할 채널을 선택하시오."
L["Select the new spell event you want to announce in chat above, then push this button"] = "위에서 당신이 채팅상에서 알리고 싶은 새로은 마법 또는 이벤트를 선택하고 이 버튼을 누르시오"
L["Select which channel to use for this spell while in a Battleground"] = "전장에 있는 동안 이 마법알림을 위해 어떤 채널을 사용할지 선택하시오"
L["Select which channel to use for this spell while in a Party"] = "파티에 있는 동안 이 마법알림을 위해 어떤 채널을 사용할지 선택하시오"
L["Select which channel to use for this spell while in a Raid"] = "공격대에 있는 동안 이 마법알림을 위해 어떤 채널을 사용할지 선택하시오"
L["Select which channel to use for this spell while playing in a Wintergrasp battle.  This only applies during an active battle."] = [=[겨울손아귀 호수 전투중에 있는 동안 이 마법알림을 위해 어떤 채널을 사용할지 선택하시오

이 시나리오는 단지 겨손전투가 진행될때에만 적용됩니다 - 현재 겨손전투가 진행중이 아닐때에는 공대, 파티 또는 단독플레이 옵션들이 적용될 것입니다.

겨울손아귀 호수에 있는지의 여부를 감지하는 것은 번역된 텍스트에 의존한다는 것을 알아두시기 바랍니다. 따라서 만일 SpeakinSpell이 아직 당신의 언어로 번역되어있지 않다면, 겨울손아귀 호수 전투들은 공대 시나리오 옵션을 사용할것입니다.]=]
L["Select which channel to use for this spell while playing in the Arena"] = "투기장에 있는 동안 이 마법알림을 위해 어떤 채널을 사용할지 선택하시오"
L["Select which channel to use for this spell while playing solo"] = "단독플레이를 하는 동안 이 마법알림을 위해 어떤 채널을 사용할지 선택하시오"
L["Self Buffs (includes procs)"] = "자신의 버프들 (지속효과 포함)"
L["Self Debuffs"] = "자신의 디버프들"
L["SELF RAID WARNING CHANNEL"] = "Self-Only Raid Warning"
L["Show Debugging Messages (verbose)"] = "디버깅 메세지 표시 (장문)"
L["Show only this kind of event in the list below"] = "아래 목록에서 선택된 이벤트 종류만을 보여줍니다."
L["Silent"] = "침묵"
L["speakinspell"] = "마법알림"
L["SPEAKINSPELL CHANNEL"] = "혼자보기 (SpeakinSpell:)"
L["SpeakinSpell Help"] = "SpeakinSpell 도움말"
L["SpeakinSpell Loaded"] = "SpeakingSpell 메모리 탑재"
L["spelllink"] = "마법링크"
L["spellname"] = "마법이름"
L["spellrank"] = "마법등급"
L["Spells, Abilities, and Items (Start Casting)"] = "자신이 시전한 마법과 능력들 (아이템 포함)"
L["ss"] = "마법알림"
L["Stop SpeakinSpell from announcing the selected spell or event"] = "선택한 마법 또는 이벤트 알림을 비활성화 한다"
L["subzone"] = "하위지역"
L["target"] = "대상"
L["targetclass"] = "대상직업"
L["targetrace"] = "대상종족"
L["This is a list of all the detected spells, abilities, items, and procced effects which SpeakinSpell has seen you cast or receive recently."] = "이것은 최근에 당신이 시전했거나 받았던 마법, 능력, 아이템 기타 등등 중 SpeakinSpell이 감지한 것들의 목록입니다."
L["To prevent SpeakinSpell from speaking in the chat too often for this spell, you can set a cooldown for how many seconds must pass before SpeakinSpell will announce this spell again."] = [=[
SpeakinSpell이 해당 마법에 대해서 너무 자주 채팅상에 알리는 것을 막아줍니다. 설정된 쿨타임이 지난 이후에만 해당 마법을 다시 알릴 것입니다.]=]
L["WARNING: can't execute protected command: <text>"] = "경고: 실행 보호 명령어는 할 수 없습니다 : <text>"
L["When I buff myself with: "] = "자신의 마법 시전으로 인한 버프: "
L["When I debuff myself with: "] = "자신의 마법 시전으로 인한 디버프: "
L["When I Start Casting: "] = "자신의 마법 시전: "
L["When I Type: /ss "] = "사용자 작성 이벤트: /마법알림 "
L["When someone else buffs me with: "] = "타인의 마법 시전으로 인한 버프: "
L["When someone else debuffs me with: "] = "타인의 마법 시전으로 인한 디버프: "
L["Whisper the message to your <target>"] = "대상에게 메세지를 귓속말로 보내기"
L["Wintergrasp GetZoneText"] = "겨울손아귀 호수"
L[ [=[Write an announcement for this event.

Duplicates of speeches listed above will not be accepted]=] ] = "여기에 말하고 싶은 재미있는 문구들을 입력하시오"
L["YELL"] = "외침 (/y)"
L[ [=[You have a random chance to say a message each time you use the selected spell, based on this selected percentage.

100% will always speak. 0% will never speak.]=] ] = [=[
선택된 확률를 기반으로 선택마법을 사용할때 문구 알림 확률을 얻습니다. 예를 들어 100%로 설정하면 항상 알리고, 0%로 설정하면 한번도 알리지 않습니다.
]=]
L["zone"] = "지역"
elseif LOCALE == "zhCN" then
L[" is OFF"] = "已关闭"
L[" is ON"] = "已打开"
L[ [=[
Send queue
size:<queuesize>
peek:<queuepeek>

Total Sent
user data:<rawqueued>
actual:<sentactual>
Compressed to <sendcompression>%

Total Received
actual:<receivedactual>
user data:<receiveduser>
Compressed to <receivedcompression>%

Actual Sent - Received = <deficit>

LibSmartComm overhead
for packets:<overheadpacket>
for addonid:<overheadid>
total:<overheadlsc>
percent overhead:<overheadpercent>%

Overhead per packet
compressed:<packovercomp>
uncompressed:<packoverraw>
total packets:<numpackets>

addonid prefix:<prefixsize>
total segments:<segments>
]=] ] = [=[
发送序列
大小:<queuesize>
预览:<queuepeek>

总计已发送
用户数据:<rawqueued>
目前:<sentactual>
压缩到 <sendcompression>%

总计已接收
目前:<receivedactual>
用户数据:<receiveduser>
压缩到 <receivedcompression>%

目前 发送 - 接收 = <deficit>

LibSmartComm 开销
包:<overheadpacket>
addonid:<overheadid>
总计<overheadlsc>
开销百分比:<overheadpercent>%

每包的开销
压缩的:<packovercomp>
未压缩的:<packoverraw>
总计包:<numpackets>

addonid 前缀:<prefixsize>
总计分段:<segments>
]=]
L["(<type>) <name>"] = [=[(<type>) <name>
]=]
L["*"] = "*"
L["* <player> <emotes> *"] = [=[* <player> <emotes> *
]=]
L["/ss macro things you type"] = "/ss 把你输入的东西作成宏"
L["[Click Here]"] = "[点这里]"
L["[Edit Speeches]"] = "[编辑讲话]"
L["[Setup New Event]"] = "[设置新事件]"
L["_ Show All Types of Events _"] = "_ 显示所有类型的事件 _"
L["<"] = "<"
L["<(.-)>"] = "<(.-)>"
L["<basecolor><colormatchedname>"] = [=[<basecolor><colormatchedname>
]=]
L["<basecolor><eventtypeprefix><colormatchedname>"] = [=[<basecolor><eventtypeprefix><colormatchedname>
]=]
L["<basecolor><eventtypeprefix><colormatchedname> (<rank>)"] = [=[<basecolor><eventtypeprefix><colormatchedname> (<rank>)
]=]
L["<clickhere> to review recent events and speeches"] = "<点这里> 查看最近的事件和对话"
L["<creator's> random <susbtitution> word lists, shared with you over the network"] = "<creator's> 随机 <susbtitution> 词汇列表，在网络上共享"
L["<creator's> shared random substitutions"] = "<creator's> 共享的随机替换"
L["<EventTypePrefix><name>"] = "<EventTypePrefix><name>"
L["<hidden> of <total> speeches are read-only / hidden"] = "<total> 中 <hidden> 讲话为只读 / 隐藏"
L["<red>Don't<normalcolor> Use this Random Speech for the selected Event"] = "<red>不要<normalcolor> 对选择的事件使用随机讲话"
L["<red>Don't<normalcolor> Use this Random Word for the selected <substitution>"] = "<red>不要<normalcolor> 对选择的 <substitution> 使用随机词"
L["<toon's> speeches (<realm>)"] = "<toon's> 讲话 (<realm>)"
L["1. About SpeakinSpell"] = "1. 关于 SpeakinSpell"
L["1. Search..."] = "1. 搜索..."
L["2. Select..."] = "2. 选择..."
L["3. Edit..."] = "3. 编辑..."
L["3.1.2.05 /macro"] = "宏"
L["3.2.2.02 <newline>"] = "<新一行>"
L["3.2.2.14 Entering Combat"] = "进入战斗"
L["3.2.2.14 Exiting Combat"] = "退出战斗"
L["3.2.2.14 Whispered While In-Combat"] = "战斗中密语"
L["A Battleground"] = "一个战场"
L["a Guild Member"] = "一个工会成员"
L["A guild member said \"ding\""] = "一个公会成员升级"
L["A Party"] = "一个小队"
L["A party member said \"ding\""] = "一个队友升级"
L["a player sent me a rez"] = "一个玩家给我上绷带"
L["A Raid"] = "一个团队"
L["achievement"] = "成就"
L["Achievement Earned by "] = "获得成就 "
L["Achievements"] = "成就"
L["Added <randomkey>: <newword>"] = "添加 <randomkey>: <newword>"
L["Added speech: <speech>"] = "添加讲话: <speech>"
L["Added speeches for <displayname>"] = "为 <displayname> 添加讲话"
L["Added word list for <keyword>"] = "为 <keyword> 添加词汇列表"
L["advertise"] = "广告"
L["All Ranks"] = "所有声望"
L["All sending is complete (for now)"] = "全部发送完成 (现在)"
L["Always use <language>"] = "一直使用 <language>"
L["An empty template containing no data at all"] = "空模板里什么都没有"
L["Any Rank"] = "任意声望"
L["Arcane"] = "奥术"
L["AUTO"] = "自动"
L["Automatic event detection and announcements are disabled."] = "自动事件检测与通知已禁用"
L["Automatic event detection and announcements are enabled."] = "自动事件检测与通知已启用"
L["Auto-sync at Login"] = "登录时自动同步"
L["Auto-Sync Options"] = "自动同步选项"
L["Auto-Sync With Player"] = "随玩家自动同步"
L["BATTLEGROUND"] = "战场 (/bg)"
L["Begin /follow"] = "开始 /follow"
L["Browse Collected Content"] = "浏览已收集的内容"
L["Buffs from Others (includes totems)"] = "别人给的增益 (包括图腾)"
L["By yourself"] = "你自己"
L["caster"] = "施法者"
L["Changed Sub-Zone"] = "更换子区域"
L["Changed Zone"] = "更换区域"
L["changes"] = "变化"
L["Channeled Spells Start"] = "引导法术开始"
L["Channeled Spells Stop"] = "引导法术结束"
L["Chat Channel Colors"] = "聊天通道颜色"
L["Chat Event: "] = "聊天事件："
L["Chat Events"] = "聊天事件"
L["class"] = "种族"
L["Click here to create settings for a new spell, ability, effect, macro, or other event"] = "点击这里创建新的 施法、技能、效果、宏或其他事件 的设置"
L["Click|r to toggle SpeakinSpell on/off"] = "点击|r 切换 SpeakinSpell 开/关"
L["Collect Speeches"] = "收集讲话"
L["Colors"] = "颜色"
L["colors"] = "颜色"
L["Colors used by SpeakinSpell"] = "SpeakinSpell 用的颜色"
L["Colors used in the SS options GUI"] = "SpeakinSpell 选项窗口用的颜色"
L["Combat Event: "] = "战斗事件："
L["Combat Events"] = "战斗事件"
L["Cooldown (seconds)"] = "冷却 (秒)"
L["create"] = "创建"
L["Create a New Speech Event"] = "创建一个新的讲话事件"
L["Create New..."] = "创建新的..."
L["Create Speech Event"] = "创建讲话事件"
L["Critical Strike"] = "暴击"
L["damage"] = "伤害"
L["Data Sharing"] = "数据共享"
L["Data Sharing Events (Received)"] = "数据共享事件（接收）"
L["Data Sharing Events (Sent)"] = "数据共享事件（发送）"
L["Debuffs from Others"] = "别人给的减益"
L["Default settings restored"] = "恢复默认设置"
L["Delete"] = "删除"
L["Delete all of the speeches for the selected event, INCLUDING read-only speeches"] = "删除已选择事件的所有讲话内容，包括只读讲话内容"
L["Delete All Speeches"] = "删除所有讲话"
L["Delete the selected word list and <substitution> word"] = "删除选择的词汇表和<substitution>词汇"
L["Delete this Event"] = "删除此事件"
L["Delete this speech"] = "删除此讲话"
L["Delete Word List"] = "删除词汇列表"
L["desc"] = "描述"
L["Diagnostics"] = "诊断"
L["Disable announcements for this Speech Event"] = "禁用此对话事件"
L["DO NOT PRESS THIS BUTTON"] = "`别`按`这`个`按`钮`"
L["Each Packet Sent"] = "逐包发送"
L["Edit"] = "编辑"
L["Edit Macro Event"] = "编辑宏事件"
L["Edit Speech / Announcement Settings"] = "编辑讲话/通告设置"
L["Edit Speeches"] = "编辑讲话"
L["Edit the values that may be used for random <substitutions>"] = "为随机 <substitutions> 编辑值"
L["EMOTE"] = "表情 (/em)"
L["Empty Template"] = "空模版"
L["Enable Automatic SpeakinSpell Event Announcements"] = "允许 SpeakinSpell 自动事件"
L[ [=[Enable this option to make SpeakinSpell show you (and only you) all of your own spell casting events and other events that can be announced.

This includes any spell, ability, item, /ss macro things, or automatically obtained effect (e.g. Trinkets or Talents) that you cast or use.]=] ] = [=[让 SpeakinSpell 只显示你自己的法术事件和其他事件。

包含所有你能使用的法术、技能、物品、/ss macro 事件，或自动触发效果（如饰品或天赋）。]=]
L["Enable this option to show an overwhelming amount of information"] = "显示详细信息"
L[ [=[Enable to show different ranks of spells and abilities, including Polymorph critters.

If disabled, any rank of the spell will count.]=] ] = [=[显示法术、技能等级，包括变形技能。

禁止此选项，所有法术等级将被忽略]=]
L[ [=[Enable to show more than 100 search results in the drop-down list below.

Enabling this option can slow down the performance of this window (capped at 200 max to avoid memory overflows).]=] ] = [=[允许下拉列表中显示超过100个搜索结果。

开启后将减慢系统运行速度（200最大上限，以避免内存溢出）。]=]
L[ [=[Enable to show more than 100 search results in the drop-down list below.

Enabling this option can slow down the performance of this window. (capped at 200 max to avoid memory overflows)]=] ] = [=[允许下拉列表中显示超过100个搜索结果。

开启后将减慢系统运行速度（200最大上限，以避免内存溢出）。]=]
L["Enable to show the event hooks that you already use."] = "显示已经使用的事件钩子"
L["End /follow"] = "结束 /follow"
L["End Casting (I'm not involved)"] = "施法结束 (跟我无关)"
L["End Casting (I'm the caster)"] = "施法结束 (我是施法者)"
L["End Casting (I'm the target)"] = "施法结束 (我是目标)"
L["Enemy of <name>"] = "<name> 的目标"
L["Enter Barber Chair"] = "坐上理发椅"
L["Entering Combat"] = "进入战斗"
L["eventtype"] = "事件类型"
L["eventtypeprefix"] = "事件类型前缀"
L["Exit Barber Chair"] = "离开理发椅"
L["Exiting Combat"] = "退出战斗"
L["Expand /ss macros as lists-only"] = "仅展开 /ss macros 列表"
L["Expired or Declined"] = "过期或拒绝"
L["extremely"] = "极其"
L["focus"] = "焦点"
L["Found a SpeakinSpell User <username> running v<version>"] = "找到一个 SpeakinSpell 用户 <username> 正在运行 v<version>"
L["General"] = "常规"
L["General Auto-Sync"] = "自动同步"
L["General Auto-Sync Failed"] = "自动同步失败"
L["General Settings"] = "常规设置"
L["General Settings for SpeakinSpell"] = "SpeakinSpell 常规设置"
L["Global Cooldown"] = "公共冷却"
L["Global Sync"] = "全局同步"
L["guides"] = "向导"
L["guild"] = "工会"
L["GUILD"] = "工会 (/g)"
L["Headings"] = "标题"
L["Help"] = "帮助"
L["help"] = "帮助"
L["Hide"] = "隐藏"
L["Hide All"] = "全部隐藏"
L["Hide all <randomsub> word lists for the selected content pack, and unload them from memory"] = "为选择的内容包隐藏所有 <randomsub> 词汇列表，并从内存卸载"
L["Hide all remaining new content and unload it from memory"] = "隐藏所有剩余新内容并从内存卸载"
L["Hide all remaining new content in the selected content pack and unload it from memory"] = "在选择的内容包中隐藏所有剩余新内容，并从内存中卸载"
L["Hide all remaining speech events for the selected content pack, and unload them from memory"] = "在选择的内容包中隐藏所有剩余对话事件，并从内存中卸载"
L["Hide all remaining speeches for the selected event, and unload the selected event template from memory"] = "在选择的事件中，隐藏所有剩余台词，并从内容中卸载选择的事件"
L["Holy"] = "神圣"
L["home"] = "家"
L["How often you say (Cooldowns/Limits)"] = "你说的频率 (冷却/限制) "
L["How Often? <selectedevent>"] = "频率? <selectedevent>"
L["However, \"/ss macro something\" will still trigger announcements if run manually"] = "“/ss macro something” 在手动模式将一直工作"
L["I Died"] = "我死了"
L["If you have an event trigger that does not appear to be firing, this option will tell you which setting silenced the announcement of that event, for example because it's on cooldown, or the random chance failed."] = "如果你有一个事件触发器不工作，这个选项将告诉你哪个设定禁言了事件广播，比如因为会话没有冷却，或随机改变失败。"
L["import"] = "导入"
L["Import All <randomsubs>"] = "导入所有 <randomsubs>"
L["Import all content from all templates"] = "从所有模板导入所有内容"
L["Import All Speech Events for the Selected Template"] = "为选择的模板导入所有对话事件"
L["Import all speech events, and their speeches, for the selected content pack"] = "为选择的内容包导入所有对话事件和它们的台词"
L["Import all speeches for the selected event"] = "为选择的事件导入所有台词"
L["Import All speeches for the Selected Speech Event"] = "为选择的对话事件导入所有台词"
L["Import All Templates"] = "导入所有模板"
L["Import All Words"] = "导入所有词汇"
L["Import Events"] = "导入事件"
L["Import Macro's List"] = "导入宏列表"
L["Import New Content"] = "导入新内容"
L["Import New Data"] = "导入新数据"
L["Import Whole Template"] = "导入整个模板"
L["Importing Template: <name>"] = "导入模板: <name>"
L["In a Battleground"] = "在战场中"
L["In a Party"] = "在队伍中"
L["In a Raid"] = "在团队中"
L["In Arena"] = "在竞技场中"
L["In Wintergrasp"] = "在冬泳湖战斗中"
L["Information"] = "信息"
L["Interaction with NPCs"] = "与 NPC 交互"
L["Killing Blow"] = "致死打击"
L["Language"] = "语言"
L["lasttarget"] = "最后的目标"
L["Level Up"] = "升级"
L["Limit once per <target>"] = "限制每 <target> 一次"
L["Limit once per combat"] = "限制每战斗一次"
L["macro"] = "宏"
L["macro "] = "宏 "
L["me"] = "我"
L["Melee Swing"] = "打斗间隔"
L["memory"] = "内存"
L["Memory Used: <kb> kb"] = "内存占用: <kb> kb"
L["Merged speeches for <displayname>"] = "与 <displayname> 合并台词"
L["Merged word list for <keyword>"] = "与 <keyword> 合并单词列表"
L["Message Settings"] = "信息设置"
L["messages"] = "信息"
L["Misc. Event: "] = "杂项: "
L["Misc. Events"] = "杂项"
L["Mounts and Pets"] = "坐骑与宠物"
L["mouseover"] = "鼠标划过"
L["MYSTERIOUS VOICE"] = "[神秘的声音] 密语:"
L["name"] = "名字"
L["Nature"] = "自然"
L["network"] = "网络"
L["Network Error"] = "网络错误"
L["Network Error: "] = "网络错误："
L["Network stats unavailable"] = "网络状态不可用"
L["Networking Options and Commands"] = "网络选项和命令"
L["New Content Browser"] = "新的内容浏览器"
L[ [=[New content is not currently loaded in memory.

Click the button below to continue.

This will scan for new content among:
- The default speeches that come with SpeakinSpell
- Your alternate characters
- Data collected from other SpeakinSpell users
]=] ] = [=[新内容当前未加载到内存。

点击下面的按钮继续。

将扫描下列内容：
－SpeakinSpell 默认台词
－你的备选角色
－从其他 SpeakinSpell 使用者收集数据]=]
L["New Word List"] = "新建词汇列表"
L["NEW? reply canceled - all event hooks are already known to <target>"] = "新的？应答已取消－所有事件钩子挂到 <target>"
L["Newer version available: "] = "新版本可用: "
L["No channels are available. For global syncs, join a guild, party, raid, or battleground."] = "无可用频道。如要全局同步，加入一个公会、小队、团队或战场。"
L["No Matching Search Results Found"] = "没有匹配的搜索结果"
L["No New Events to Send to <target>"] = "没有新事件发送到 <target>"
L["no speeches are defined"] = "没有定义讲话"
L["no target selected"] = "没选择目标"
L[ [=[OFF = All of your characters will use separate lists of event triggers and random speeches, which you can copy from one to the other using "/ss import"

ON = All of your characters will share the same event triggers and speeches

Toggling this option will merge or split your settings between all of your characters]=] ] = [=[关 ＝ 所有角色使用独立的事件触发器和随机台词，你能使用“/ss import”在角色间拷贝这些设置。

开 ＝ 所有角色共享同样的事件触发器和随机台词。

开关这个选项将分割或合并你角色间的设置。]=]
L["OFF|r"] = "关|r"
L["ON|r"] = "开|r"
L["Open Mailbox"] = "打开邮箱"
L["Open the event settings to edit speeches and other options for When I Type: "] = "当我键入 …… 打开事件设置编辑台词和其他选项："
L["Open the User's Manual"] = "打开用户手册"
L["Open Trade Window"] = "打开交易窗口"
L["options"] = "选项"
L["Outland"] = "外域"
L["overkill"] = "过量伤害"
L["PARTY"] = "小队 (/p)"
L["Party Leader"] = "队长"
L["Party Leadership Mode"] = "队长模式"
L["pet"] = "宠物"
L["Physical"] = "物理"
L["PLAYER"] = "玩家"
L["player"] = "玩家"
L["playerclass"] = "玩家职业"
L["playerfulltitle"] = "玩家完整头衔"
L["playerrace"] = "玩家种族"
L["playertitle"] = "玩家头衔"
L["points"] = "点"
L["race"] = "种族"
L["RAID"] = "团队 (/ra)"
L["Raid Leader"] = "团队领袖"
L["Raid Leadership Mode"] = "团队领袖模式"
L["Raid Officer"] = "团队指挥官"
L["Raid Officer Mode"] = "团队指挥官模式"
L["RAID_BOSS_WHISPER"] = "首领密语"
L["RAID_WARNING"] = "团队警告 (/rw)"
L["Random"] = "随机"
L["random"] = "随机"
L["Random Chance (%)"] = "概率 (%)"
L["Random Chance to use <language>"] = "使用 <language> 的概率"
L["Random Speech <number>"] = "随机讲话 <number>"
L["Random Substitutions"] = "随机替换"
L["Random Substitutions like <randomtaunt> and <randomfaction>"] = "随机替换如 <randomtaunt> 和 <randomfaction>"
L["Random Substutitions"] = "随机替换"
L["Random Word <number>"] = "随机词 <number>"
L["rank"] = "声望"
L["Read-Only"] = "只读"
L["realm"] = "所处服务器"
L["Receive Data"] = "接收数据"
L["Received new event hooks"] = "收到新事件钩子"
L["recent"] = "最近的"
L["Recent Events Detected..."] = "最近侦测到的事件"
L["Remove the selected spell from the list"] = "从列表移除选择的法术"
L["Report import processing results in the chat frame"] = "在聊天框体报告导入进度结果"
L["reset"] = "重置"
L["Reset Event List"] = "重置事件列表"
L["Reset the list of event hooks to the default basic list, removing all discovered and collected event hooks"] = "重置事件钩子列表到初始状态，移除所有侦测和收集到的事件钩子"
L["Resurrection: "] = "恢复: "
L["reward"] = "奖励"
L["Right-click|r to open the options"] = "右键|r 打开选项"
L["SAY"] = "说 (/s)"
L["scenario"] = "剧情"
L["school"] = "学校"
L["Search"] = "搜索"
L["Search Filter Options"] = "搜索过滤选项"
L["Search for New Data"] = "搜索新数据"
L["Search Match"] = "搜索适配"
L["Select a Category of Events"] = "选择一个事件类别"
L["Select a Content Pack"] = "选择一个事件包"
L["Select a Speech Event"] = "选择讲话事件"
L["Select a spell from the list to configure the random announcements for that spell."] = "为法术选择随机通告配置"
L["Select a Template"] = "选择模板"
L["Select a topic..."] = "选择一个主题"
L["Select and Create"] = "选择并创建"
L["Select the channel to use for this spell, while..."] = "当……的时候，为此语句选择频道"
L["Select the new spell event you want to announce in chat above, then push this button"] = "选择你想在聊天窗口通告的法术事件，然后按这个键"
L[ [=[Select the racial game language you want to use to announce these speeches

This option will be ignored if you set the "Always Use Common" option under general settings.]=] ] = [=[为这些语句选择种族语言

当你在综合设置中选上了“总是使用通用语言”时，此选项就不会起作用。]=]
L[ [=[Select the random chance to use your racial/roleplay language for this event
0% will always use <common>. 100% will always use <racial>.]=] ] = [=[为事件选择种族、角色语言的使用几率
0%：将总是使用<common>，100%将总是使用<racial>。]=]
L["Select which channel to use for this spell while in a Battleground"] = "战场中使用哪个聊天频道"
L["Select which channel to use for this spell while in a Party"] = "小队中使用哪个聊天频道"
L["Select which channel to use for this spell while in a Raid"] = "团队中使用哪个聊天频道"
L["Select which channel to use for this spell while playing in a Wintergrasp battle.  This only applies during an active battle."] = "冬泳湖中使用哪个聊天频道。仅在冬泳湖战斗激活情况下生效。"
L["Select which channel to use for this spell while playing in the Arena"] = "竞技场中使用哪个聊天频道"
L["Select which channel to use for this spell while playing solo"] = "单人时使用哪个聊天频道"
L["selected"] = "选择的"
L["Selected Event: "] = "选择事件"
L["Selected Item"] = "选择物品"
L["Self Buffs (includes procs)"] = "自身增益（包括特效）"
L["Self Debuffs"] = "自身减益"
L["SELF RAID WARNING CHANNEL"] = "自己的团队警告"
L["Self Raid Warnings"] = "自身团队警告"
L["Self-Chat"] = "自言自语"
L["Send a data sharing request to GUILD, RAID, PARTY, and BATTLEGROUND channels every time you login or /reloadui"] = "每次登录或重载界面就发送一个数据共享请求到 公会，团队，小队和战场频道"
L[ [=[Send a data sharing request to GUILD, RAID, PARTY, and BATTLEGROUND channels.

Same as "/ss sync"]=] ] = "发送一个数据共享请求到 公会，团队，小队和战场频道"
L[ [=[Send a data sharing request to your selected target.

Same as "/ss sync <target>"]=] ] = "发送一个数据共享请求到你选择的目标"
L["Send Complete: <command> -> <target>"] = "发送完成：<command> -> <target>"
L["Send Data"] = "发送数据"
L["Send to <target> <command>"] = "发送到 <target> <command>"
L["Setup guides are enabled. <clickhere> to disable them"] = "安装指南已启用。<clickhere> 关闭它"
L["Setup guides have been disabled. <clickhere> to enable them"] = "安装指南已关闭。<clickhere> 启用它"
L["Shadow"] = "阴影"
L["Share my detected event hooks"] = "共享我侦测到的事件钩子（如使用了某样物品，改变了某个区域）"
L["Share my list of New Events Detected from the \"/ss create\" interface"] = "共享使用“/ss create”命令后侦测到的新事件列表"
L["Share my random <substitutions>"] = "共享我的随机 <substitutions>"
L["Share my speeches"] = "共享我的台词"
L["Share Speeches for All Characters"] = "共享台词到所有角色"
L["Share the speeches I have written for SpeakinSpell events"] = "共享我为 SpeakinSpell 事件撰写的台词"
L["Sharing vs. Privacy"] = "共享 对 隐私"
L["Show All Ranks"] = "显示所有声望"
L["Show Comm Traffic"] = "显示通讯流量"
L["Show Debugging Messages (verbose)"] = "显示调试信息（详细）"
L["Show Import Progress"] = "显示导入进程"
L["Show Minimap Button"] = "显示小地图按钮"
L["Show More than 100 Search Results"] = "显示超过 100 搜索结果"
L["Show network transfer statistics"] = "显示网络传输统计"
L["Show only this kind of event in the list below"] = "只显示下面列表中的事件"
L["Show outbound data transfer progress"] = "显示出站数据传输进度"
L["Show Read-Only Speeches"] = "显示只读讲话"
L["Show Ready-Only Speeches"] = "显示仅就绪讲话"
L["Show Setup Guides"] = "显示设置向导"
L["Show Statistics"] = "显示状态"
L["Show the SpeakinSpell minimap button"] = "显示 SpeakinSpell 小地图按钮"
L["Show the version number in chat when loading SpeakinSpell during login"] = "在 SpeakinSpell 加载时显示版本号"
L["Show These Options"] = "显示这些选项"
L["Show these options for chat channel selections"] = "显示选择的聊天频道选项"
L["Show these options for chat frequency, cooldowns, and other limits"] = "显示说话频率，冷却，和其他限制的选项。"
L["Show Transfer Progress"] = "显示传输进度"
L["Show Used Event Hooks"] = "显示使用的事件钩子"
L["Show Welcome Message"] = "显示欢迎辞"
L["Show Why Event Triggers Do Not Fire"] = "显示为什么触发器不起作用"
L["Silent"] = "安静"
L["Solo Mode"] = "独行侠模式"
L["Someone Nearby"] = "附近某人"
L["SPEAKINSPELL CHANNEL"] = "自言自语 (SpeakinSpell:)"
L["SpeakinSpell Colors"] = "SpeakinSpell 颜色"
L["SpeakinSpell Help"] = "SpeakinSpell 帮助"
L[ [=[SpeakinSpell is <off>

Enable this option to turn SpeakinSpell <on> and resume announcing SpeakinSpell Speech Events

/ss macro events are always enabled if you manually type it or click a button for it.
]=] ] = [=[SpeakinSpell 已 <关闭>

把 SpeakinSpell <开启> 以激活此选项并恢复 SpeakinSpell 讲话事件

/ss 宏事件 如果手动输入或用按钮则一直有效。
]=]
L[ [=[SpeakinSpell is <on>

Disable this option to turn SpeakinSpell <off> and silence all SpeakinSpell speeches

/ss macro events are always enabled if you manually type it or click a button for it.
]=] ] = [=[SpeakinSpell 是 <on>

禁止这个选项会 <off> SpeakinSpell ，并且禁言所有 SpeakinSpell 台词。

/ss macro 事件总是生效的，如果你手动键入它，或者点击这个键。]=]
L["SpeakinSpell Loaded"] = "SpeakinSpell 载入"
L["SpeakinSpell Options GUI Colors"] = "SpeakinSpell 选项 GUI 颜色"
L["spelllink"] = "法术链接"
L["spellname"] = "法术名称"
L["spellrank"] = "法术等级"
L["Spells, Abilities, and Items (Failed)"] = "施法, 技能, 和物品 (失败)"
L["Spells, Abilities, and Items (Interrupted)"] = "施法, 技能, 和物品 (打断)"
L["Spells, Abilities, and Items (Start Casting)"] = "施法, 技能, 和物品 (开始施放)"
L["Spells, Abilities, and Items (Stop Casting)"] = "施法, 技能, 和物品 (停止施放)"
L["Spells, Abilities, and Items (Successful Cast)"] = "施法, 技能, 和物品 (成功施放)"
L["SS Network "] = "SS 网络 "
L["Start Casting (I'm not involved)"] = "开始施放 (与我无关)"
L["Start Casting (I'm the caster)"] = "开始施放 (我是施法者)"
L["Start Casting (I'm the target)"] = "开始施放 (我是目标)"
L["Starting Sync with <target>"] = "开始与目标同步 <target>"
L["Stop SpeakinSpell from announcing the selected spell or event"] = "在选择的法术或事件中禁用 SpeakinSpell"
L["subzone"] = "子区域"
L["swimmer"] = "游泳者"
L["sync"] = "同步"
L["sync "] = "同步 "
L["Sync with Target"] = "与目标同步"
L["Talk to Flight Master"] = "跟飞行点管理员说话"
L["Talk to Quest-Giver"] = "跟给任务者说话"
L["Talk to Trainer"] = "跟训练师说话"
L["Talk to Vendor"] = "跟商人说话"
L["target"] = "目标"
L["targetclass"] = "目标类型"
L["targetrace"] = "目标种族"
L["Test Event: "] = "测试事件: "
L["Test Events"] = "测试事件"
L["testallsubs"] = "测试所有子句"
L["text"] = "文字"
L["the /ss macro would keep calling itself forever"] = "这个 /ss 会一直自我调用"
L["The Arena"] = "竞技场"
L["The color of self-only raid warnings generated by SpeakinSpell"] = "针对自己的 SpeakinSpell 团队警告颜色"
L["the global cooldown is in effect"] = "公共冷却正在作用"
L["the random chance failed"] = "随机选择失败"
L["the selected chat channel is \"Silent\" while in <Scenario>"] = "选择的聊天频道在 <Scenario> 进行时是“静音”的"
L["this event trigger is disabled"] = "此事件触发器已禁用"
L["this event trigger is limited to once per combat / once per out-of-combat"] = "此事件触发器限制为每场战斗一次  / 每脱离战斗一次"
L["this event trigger is limited to once per target (<target>)"] = "此事件触发器限制为每目标一次 (<target>)"
L["this event trigger's cooldown is in effect"] = "此事件触发器正在冷却"
L["This is a list of all the detected spells, abilities, items, and procced effects which SpeakinSpell has seen you cast or receive recently."] = "这是 SpeakinSpell 所能侦测的到所有法术、技能、物品和效果"
L["This option will silence SpeakinSpell for this many seconds after any event announcement."] = "SpeakinSpell 事件之间的触发间隔（单位：秒）"
L["To prevent SpeakinSpell from speaking in the chat too often for this spell, you can set a cooldown for how many seconds must pass before SpeakinSpell will announce this spell again."] = "针对某种使用频繁的法术触发讲话过多的情况，你可以设定一个冷却时间，在此时间之内同样的法术不会再触发 SpeakinSpell 事件。"
L["toggle"] = "开关"
L["Toggle showing single-line or multi-line edit boxes for speeches"] = "转换讲话的单行或者多行编辑模式"
L["Transfer Complete"] = "传输完毕"
L["type"] = "类型"
L["Unknown Damage Type"] = "未知伤害类型"
L["Use"] = "使用"
L["Use All"] = "全部使用"
L["Use Multi-Line Edit Boxes"] = "使用多行输入框"
L["Use this channel if you are promoted to assist in a raid group"] = "如果晋升为团队助理就使用这个信道"
L["Use this channel if you are the leader of a 5-man party"] = "如果你领导一个5人小队就使用这个信道"
L["Use this channel if you are the leader of a raid group"] = "如果你是团长就使用这个信道"
L["Use this Random Speech for the selected Event"] = "在选择的事件中使用这个随机讲话"
L["User's Manual"] = "用户手册"
L["Version "] = "版本 "
L["very"] = "非常"
L["WARNING: can't execute protected command: <text>"] = "警告：不能执行保护的命令：<text>"
L["Welcome to SpeakinSpell v<version> <clickhere> to edit options"] = "欢迎到 SpeakinSpell v<version> <clickhere> 编辑选项"
L["What to Say? <selectedevent>"] = "要说什么? <selectedevent>"
L["What you say (Speeches)"] = "你说什么 (Speeches)"
L["When I buff myself with: "] = "当我给自己增益: "
L["When I debuff myself with: "] = "当我给自己减益: "
L["When I Fail to Cast: "] = "当我施法失败: "
L["When I Start Casting: "] = "当我开始施法: "
L["When I Start Channeling: "] = "当我开始引导: "
L["When I Stop Casting: "] = "当我停止施法: "
L["When I Stop Channeling: "] = "当我停止引导: "
L["When I Successfully Cast: "] = "当我施法成功: "
L["When I Type: /ss "] = "当我输入: /ss "
L["When I'm interrupted while casting: "] = "当我施法被打断: "
L["When someone else buffs me with: "] = "当某人给我增益: "
L["When someone else debuffs me with: "] = "当某人给我减益: "
L["Where you say (Channels/Whisper)"] = "你在哪说 (频道/密语)"
L["Which Channel? <selectedevent>"] = "哪个频道？ <selectedevent>"
L["Whisper the message to your <target>"] = "Whisper the message to your <target>"
L["Whispered While In-Combat"] = "战斗中密语"
L["Wintergrasp"] = "冬拥湖"
L["Wintergrasp GetZoneText"] = "冬拥湖"
L[ [=[Write an announcement for this event.

Duplicates of speeches listed above will not be accepted]=] ] = "为当前事件写一个讲话"
L["YELL"] = "大喊 (/y)"
L["You are already using all of the available content"] = "你已经使用了所有可用内容"
L[ [=[You have a random chance to say a message each time you use the selected spell, based on this selected percentage.

100% will always speak. 0% will never speak.]=] ] = [=[你每次施放法术都有一定几率随机说一句话，触发几率基于下面的百分比。
100%表示每次都说，0%表示从不说。]=]
L["Your friends"] = "你的朋友"
L["zone"] = "区域"
elseif LOCALE == "zhTW" then
L[" is OFF"] = " 關閉"
L[" is ON"] = " 開啟"
L["*"] = "*"
L["<"] = "<"
L["<(.-)>"] = "<(.-)>"
L[">"] = ">"
L["1. Search..."] = "1. 搜尋..."
L["2. Select..."] = "2. 選擇..."
L["3.1.2.05 /macro"] = "巨集"
L["3.2.2.14 Entering Combat"] = "進入戰鬥"
L["3.2.2.14 Exiting Combat"] = "離開戰鬥"
L["A Battleground"] = "戰場"
L["A Party"] = "隊伍"
L["A Raid"] = "團隊"
L["Achievements"] = "成就"
L["ALT"] = "ALT"
L["Arcane"] = "秘法"
L["AUTO"] = "自動"
L["BATTLEGROUND"] = "戰場 (/bg)"
L["Begin /follow"] = "開始 /跟隨"
elseif LOCALE == "ptPR" then
elseif LOCALE == "itIT" then
end

local soulstoneToken = {
	[L["Use Soulstone"]] = "SS",
	[L["Reincarnate"]] = "RE",
	[L["Twisting Nether"]] = "TN",
}

local soulstoneText = {
	["SS"] = L["Soulstone"],
	["RE"] = GetSpellInfo(20608), -- just use Reincarnation spell name
	["TN"] = L["Twisting Nether"],
}

------------------------------------------------------------------------
--	Event frame
--

lib.eventFrame = lib.eventFrame or CreateFrame("Frame")
lib.eventFrame:SetScript("OnEvent", function(this, event, ...)
	this[event](this, ...)
end)
lib.eventFrame:UnregisterAllEvents()

------------------------------------------------------------------------
--	Embed CallbackHandler-1.0
--

if not lib.Callbacks then
	lib.Callbacks = LibStub("CallbackHandler-1.0"):New(lib)
end

------------------------------------------------------------------------
--	Locals
--

local playerName = UnitName("player")
local _, playerClass = UnitClass("player")
local isResser = (playerClass == "PRIEST") or (playerClass == "SHAMAN") or (playerClass == "PALADIN") or (playerClass == "DRUID") or (playerClass == "MONK")

-- Last target name from UNIT_SPELLCAST_SENT
local sentTargetName = nil

-- Mouse down target
local mouseDownTarget = nil
local worldFrameHook = nil

-- Battleground/Arena/Group Indicators
local inBattlegroundOrArena = nil

-- For tracking STOP messages
local isCasting = nil

-- Tracking resses
local activeRes = {}

local resSpell, combatResSpell -- avoid creating tables we're just going to discard immediately
if playerClass == "DRUID" then
	resSpell = GetSpellInfo(50769) -- Revive
	combatResSpell = GetSpellInfo(20484) -- Rebirth
elseif playerClass == "PALADIN" then
	resSpell = GetSpellInfo(7328) -- Redemption
elseif playerClass == "PRIEST" then
	resSpell = GetSpellInfo(2006) -- Resurrection
elseif playerClass == "SHAMAN" then
	resSpell = GetSpellInfo(2008) -- Ancestral Spirit
elseif playerClass == "MONK" then
	resSpell = GetSpellInfo(115178) -- Resuscitate
end

------------------------------------------------------------------------
--	Utilities
--

local function commSend(contents, distribution, target)
	if not (oRA and oRA:HasModule("ParticipantPassive") and oRA:IsModuleActive("ParticipantPassive") or CT_RA_Stats) then
		SendAddonMessage("CTRA", contents, distribution or (inBattlegroundOrArena and "BATTLEGROUND" or "RAID"), target)
	end
end

------------------------------------------------------------------------
--	Event Handlers
--

function lib.eventFrame:UNIT_SPELLCAST_SENT(unit, _, _, targetName)
	sentTargetName = targetName:match("^([^%-]+)")
end

function lib.eventFrame:UNIT_SPELLCAST_START(unit, spellName)
	if spellName ~= resSpell and spellName ~= combatResSpell then return end

	isCasting = true

	local target = sentTargetName
	if not sentTargetName or sentTargetName == UNKNOWN then
		target = mouseDownTarget
	end

	if not target and GameTooltipTextLeft1:IsVisible() then
		-- check tooltip in case of mouseover casting on a corpse whose spirit has been released
		target = GameTooltipTextLeft1:GetText():match(L.CORPSE_OF)
	end

	if not target then
		-- still nothing :(
		return
	end

	local endTime = select(6, UnitCastingInfo(unit)) or (GetTime() + 10) * 1000
	endTime = endTime / 1000

	activeRes[playerName] = target

	lib.Callbacks:Fire("ResComm_ResStart", playerName, endTime, target)
	commSend(("RES %s"):format(target))
end

function lib.eventFrame:CHAT_MSG_ADDON(prefix, msg, distribution, sender)
	if prefix ~= "CTRA" then return end
	if sender == playerName then return end
	sender = sender:match("^([^%-]+)")

	local target
	for cmd, targetName in msg:gmatch("(%a+)%s?([^#]*)") do
		-- A lot of garbage can come in, make absolutely sure we have a decent message
		if cmd == "RES" and targetName ~= "" and targetName ~= UNKNOWN then

			local endTime = select(6, UnitCastingInfo(sender)) or (GetTime() + 10)*1000

			if endTime and targetName then
				endTime = endTime / 1000
				activeRes[sender] = targetName
				lib.Callbacks:Fire("ResComm_ResStart", sender, endTime, targetName)
			end
		elseif cmd == "RESNO" then
			if activeRes[sender] then
				target = activeRes[sender]
				activeRes[sender] = nil
			end
			lib.Callbacks:Fire("ResComm_ResEnd", sender, target)
		elseif cmd == "RESSED" then
			if activeRes[sender] then
				target = activeRes[sender]
				activeRes[sender] = nil
			end
			lib.Callbacks:Fire("ResComm_Ressed", sender)
		elseif cmd == "CANRES" then
			lib.Callbacks:Fire("ResComm_CanRes", sender, targetName, targetName and soulstoneText[targetName]) -- send token and text with callback
		elseif cmd == "NORESSED" then
			lib.Callbacks:Fire("ResComm_ResExpired", sender)
		end
	end
end

function lib.eventFrame:UNIT_SPELLCAST_SUCCEEDED(unit, spellName)
	if not isCasting then return end

	local target = activeRes[playerName]
	if activeRes[playerName] then
		activeRes[playerName] = nil
	end
	
	local complete = true
	lib.Callbacks:Fire("ResComm_ResEnd", playerName, target, complete)
	commSend("RESNO")
	isCasting = false
end

function lib.eventFrame:UNIT_SPELLCAST_STOP(unit, spellName)
	if not isCasting then return end

	local target = activeRes[playerName]
	if activeRes[playerName] then
		activeRes[playerName] = nil
	end

	local complete = false
	lib.Callbacks:Fire("ResComm_ResEnd", playerName, target, complete)
	commSend("RESNO")
	isCasting = false
end

lib.eventFrame.UNIT_SPELLCAST_FAILED = lib.eventFrame.UNIT_SPELLCAST_STOP
lib.eventFrame.UNIT_SPELLCAST_INTERRUPTED = lib.eventFrame.UNIT_SPELLCAST_STOP

function lib.eventFrame:PLAYER_ENTERING_WORLD()
	local it = select(2, IsInInstance())
	inBattlegroundOrArena = (it == "pvp") or (it == "arena")
end

------------------------------------------------------------------------
-- Public Functions

--[[
	IsUnitBeingRessed(unit)
	Checks if a unit is being ressurected at that moment.
	Arguments:
		unit - string; name of a friendly player
	Returns:
		isBeingRessed - boolean; true when unit is being ressed, false otherwise
		resser - string; name of the player ressing the unit
]]--

function lib:IsUnitBeingRessed(unit)
	for resser, ressed in pairs(activeRes) do
		if unit == ressed then
			return true, resser
		end
	end
	return false
end

------------------------------------------------------------------------
-- Hooks
--

-- Credits to Ora2
function lib:worldFrameOnMouseDown()
	if GameTooltipTextLeft1:IsVisible() then
		mouseDownTarget = GameTooltipTextLeft1:GetText():match(L.CORPSE_OF)
	end
end

function lib:popupFuncRessed()
	lib.Callbacks:Fire("ResComm_Ressed", playerName)
	commSend("RESSED")
end

function lib:popupFuncCanRes()
	local kind = HasSoulstone()
	if not kind then return end

	lib.Callbacks:Fire("ResComm_CanRes", playerName)
	commSend("CANRES")

	local token = soulstoneToken[kind]
	if token then
		-- send a second comm with a token representing the type of self-res available
		commSend("CANRES " .. token)
	end
end

function lib:popupFuncExpired()
	lib.Callbacks:Fire("ResComm_ResExpired", playerName)
	commSend("NORESSED")
end

function lib:noop()
end

------------------------------------------------------------------------
-- Register events and hooks
--

function lib:start()
	lib.eventFrame:RegisterEvent("CHAT_MSG_ADDON")
	RegisterAddonMessagePrefix("CTRA")

	if isResser then
		lib.eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
		lib.eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
		lib.eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_SENT", "player")
		lib.eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
		lib.eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
		lib.eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
	end

	lib.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

	worldFrameHook = WorldFrame:GetScript("OnMouseDown")
	if not worldFrameHook then
		worldFrameHook = lib.noop
	end

	WorldFrame:SetScript("OnMouseDown", function(...)
		lib:worldFrameOnMouseDown()
		worldFrameHook(...)
	end)

	local res = StaticPopupDialogs["RESURRECT"].OnShow
	StaticPopupDialogs["RESURRECT"].OnShow = function(...)
		lib:popupFuncRessed()
		res(...)
	end

	local resNoSick = StaticPopupDialogs["RESURRECT_NO_SICKNESS"].OnShow
	StaticPopupDialogs["RESURRECT_NO_SICKNESS"].OnShow = function(...)
		lib:popupFuncRessed()
		resNoSick(...)
	end

	local resNoTimer = StaticPopupDialogs["RESURRECT_NO_TIMER"].OnShow
	StaticPopupDialogs["RESURRECT_NO_TIMER"].OnShow =  function(...)
		lib:popupFuncRessed()
		resNoTimer(...)
	end

	local death = StaticPopupDialogs["DEATH"].OnShow
	StaticPopupDialogs["DEATH"].OnShow =  function(...)
		lib:popupFuncCanRes()
		death(...)
	end

	if not StaticPopupDialogs["RESURRECT"].OnHide then
		StaticPopupDialogs["RESURRECT"].OnHide = function() lib:popupFuncExpired() end
	else
		local resurrect = StaticPopupDialogs["RESURRECT"].OnHide
		StaticPopupDialogs["RESURRECT"].OnHide = function(...)
			lib:popupFuncExpired()
			resurrect(...)
		end
	end

	if not StaticPopupDialogs["RESURRECT_NO_SICKNESS"].OnHide then
		StaticPopupDialogs["RESURRECT_NO_SICKNESS"].OnHide = function() lib:popupFuncExpired() end
	else
		local resNoSick = StaticPopupDialogs["RESURRECT_NO_SICKNESS"].OnHide
		StaticPopupDialogs["RESURRECT_NO_SICKNESS"].OnHide = function(...)
			lib:popupFuncExpired()
			resNoSick(...)
		end
	end

	if not StaticPopupDialogs["RESURRECT_NO_TIMER"].OnHide then
		StaticPopupDialogs["RESURRECT_NO_TIMER"].OnHide = function()
			if not StaticPopup_FindVisible("DEATH") then lib:popupFuncExpired() end
		end
	else
		local resNoTimer = StaticPopupDialogs["RESURRECT_NO_TIMER"].OnHide
		StaticPopupDialogs["RESURRECT_NO_TIMER"].OnHide = function(...)
			if not StaticPopup_FindVisible("DEATH") then lib:popupFuncExpired() end
			resNoTimer(...)
		end
	end

end

------------------------------------------------------------------------
-- Start library
--

lib.disable = function()
	lib.worldFrameOnMouseDown = lib.noop
	lib.popupFuncRessed = lib.noop
	lib.popupFuncCanRes = lib.noop
	lib.popupFuncExpired = lib.noop
	lib.eventFrame:UnregisterAllEvents()
end
lib:start()