local ADDONNAME, WIC = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDONNAME, "deDE")
if not L then return end

L["A "] = true
L["Active"] = "Aktive"
L["Active module"] = "Aktives Modul"
L["Add a new keyword."] = "Ein neues Schlüsselwort hinzufügen."
L["Add here your invite keywords, one per line."] = "Füge pro Zeile ein Schlüsselword hinzu."
L["Add keyword"] = "Schlüsselwort hinzufügen"
L["Addon name not found!"] = "Addonname nicht gefunden!"
L["Advanced"] = "Erweitert"
L["AFK/DND Protection"] = "AFK/DND Schutz"
L["All entry are case sensitive."] = "Alle Einträge achten auf Groß/-Kleinschreibung."
L["Alliance toons: %s"] = "Allianz-Charaktere: %s"
L["ALLOW"] = "Erlauben"
L["And show me this infos: %s"] = "Und zeige mir diese Informationen: %s"
L["Answer"] = "Antwort"
L["A%s"] = "E%s "
L["Auto convert"] = "Automatisch Konvertieren"
L["Basic"] = true
L["Battle.net Channels"] = "Battle.net-Kanäle"
L["Battle.net Channels where message will be checked for invite keywords."] = "Battle.net-Kanäle, deren Nachrichten auf Schlüsselwörter überprüft werden."
L["BLOCK"] = "Sperren"
L["Block invites"] = "Einladungen blockieren"
L["Block invites when you are AFK"] = "Wenn AFK werden Einladungen blockiert"
L["Block invites when you are DND"] = "Wenn DND werden Einladungen blockiert"
L["BNET_TAG"] = "Battle.net-Tag"
L["B%s"] = "S%s "
L["Cache has been cleaned."] = "Cache wurde bereinigt."
L["Cache has been reset."] = "Cache wurde zurückgesetzt."
L["Can't load module. %s"] = "Modul kann nicht geladen werden. %s"
L["Can't load module %s because %s"] = "Modul %s kann nicht geladen werden wegen %s"
L["Case sensitive"] = "Groß-/Kleinschreibung beachten "
L["Case sensitive keyword matching."] = "Groß-/Kleinschreibung wird beim Schlüsselwortvergleich beachtet."
L["Channels"] = "Kanäle"
L["Channels where message will be checked for invite keywords."] = "Kanäle, deren Nachrichten auf Schlüsselwörter überprüft werden."
L["CHAT_MSG_BN_CONVERSATION"] = "Chat"
L["CHAT_MSG_BN_INLINE_TOAST_BROADCAST"] = "Status"
L["CHAT_MSG_BN_WHISPER"] = "Flüstern"
L["CHAT_MSG_CHANNEL"] = "Alle Kanäle"
L["CHAT_MSG_GUILD"] = "Gilde"
L["CHAT_MSG_OFFICER"] = "Gildenoffizier"
L["CHAT_MSG_WHISPER"] = "Flüstern"
L["Choose active module."] = "Wähle aktives Modul."
L[ [=[Choose when you don't want to automatic invite other players when you are AFK or DND.
And if to send a message.]=] ] = [=[Wähle ob du nicht automatisch andere Spieler einladen möchtest wenn du AFK oder DND bist.
Und ob eine Nachricht gesendet werden soll.
]=]
L[ [=[Choose when you don't want to automatic invite other players when you are in a LF-Queue.
]=] ] = "Wähle die LF-Wartenschlangen aus, in der du keine automatischen Einladungen verschicken willst."
L[ [=[Choose which Type of filter you want to add, all entries are case sensitive.

|cFF70DBFF%s:|r Filter only on playername 
|cFF70DBFF%s:|r Filter on playername and realm
|cFF70DBFF%s:|r Filter on guild (this will mostly only work with player of your realm)
|cFF70DBFF%s:|r Filter on guild and realm 
|cFF70DBFF%s:|r Filter player on realm
|cFF70DBFF%s:|r Filter player on Battle.net Tag (this work only with yours Battle.net friends. This will save Battle.net Tags to your SavedVariables for caching.)
|cFF70DBFF%s:|r Enter an existing filter to remove.]=] ] = [=[Wähle, welchen Filtertyp du hinzufügen willst. Alle Einträge beachten Groß/-Kleinschreibung.

|cFF70DBFF%s:|r Filter nur auf den Spielernamen
|cFF70DBFF%s:|r Filter auf Spielernamen and Realm
|cFF70DBFF%s:|r Filter auf Gilde (Dies wird meistens nur mit Spielern funktionieren, welche auf deinem Realm sind)
|cFF70DBFF%s:|r Filter auf Gilde und Realm
|cFF70DBFF%s:|r Filter auf Spieler von dem Realm
|cFF70DBFF%s:|r Filter Spieler über den Battle.net-Tag (Dies funktioniert nur mit deinen Battle.net-Freunden. Mit diesem Filter werden Battle.net-Tags fürs Caching, in deinen „SavedVariables“ gespeichert.)
|cFF70DBFF%s:|r Gib einen existierenden Filter ein, um diesen zu entfernen.]=]
L[ [=[Choose which way the filter work.
|cFF70DBFF%s:|r Allow any where is not on the list
|cFF70DBFF%s:|r Allow only where is on the list]=] ] = [=[Wähle, wie der Filter funktionieren soll.
|cFF70DBFF%s:|r Erlaube alle, die nicht auf der Liste sind.
|cFF70DBFF%s:|r Erlaube nur diejenigen, die auf der Liste sind.]=]
L["<command>"] = "<Befehl>"
L["Convert group to raid when group has reached maximal size."] = "Konvertiere Gruppe zu Schlachtzug, wenn die maximale Gruppengröße erreicht wird."
L["CS "] = "KG "
L["Custom block message"] = "Eigene Blockiernachricht"
L["Delay(seconds) needed between to invites of the same player before, WhisperInvite can send a new invite."] = "Verzögerung (Sekunden), bis der gleiche Spieler noch mal von WhisperInvite eingeladen werden kann."
L["Delete"] = "Löschen"
L["disable"] = "deaktivieren"
L["Disabled"] = "Deaktiviert"
L["Display this custom message when a invite is blocked."] = "Diese Nachricht wird angezeigt, wenn eine Einladung blockiert wurde. "
L["Do you really want to remove the keyword %q?"] = "Willst du wirklich das Schlüsselwort %q entfernen?"
L["E.g: %s"] = "Z.B: %s "
L["enable"] = "aktivieren"
L["Enabled"] = "Aktiviert"
L["Entry"] = "Eintrag"
L["Entry is not valid."] = "Eintrag ist nicht gültig."
L["Entry Type"] = "Eintragart"
L["Filtering"] = "Filtern"
L["Filter type"] = "Filter Art"
L["FM "] = "VÜ "
L["Full match"] = "Vollständige Übereinstimmung"
L["G%s "] = true
L["GUILD"] = "Gilde"
L["Guild Name"] = "Gildenname"
L["GUILD_REALM"] = "Gilde-Realm"
L["help"] = "hilfe"
L["Horde toons: %s"] = "Horde-Charaktäre: %s"
L["I'm currently AFK"] = "Ich bin zurzeit AFK"
L["I'm currently DND"] = "Ich bin zurzeit DND"
L["I'm currently in a LF-Queue"] = "Bin gerade in einer LF-Warteschlange"
L["Incorrect Battle.net Tag. %s"] = "Inkorrekter Battle.net-Tag. %s"
L["Input"] = "Eingabe"
L["Invite player when they whisper you with a defined keyword."] = "Lade Spieler ein, wenn diese dich mit einem definierten Schlüsselwort anflüstern."
L["Invite player when they whisper you with a defined keyword where they are allowed to use."] = "Lade Spieler ein, wenn diese dich mit einem definierten Schlüsselwort anflüstern, falls sie erlaubt sind, dieses Schlüsselwort zu benutzen."
L["Invite Throttle"] = "Einladungsdrosselung"
L["Is blocked."] = "Ist blockiert."
L["Is not allowed."] = "Ist nicht berechtigt."
L["Is this keyword in use."] = "Wird diese Schlüsselwort benutzt."
L["Is this profile enabled."] = "Ist diese Profile aktiviert."
L["Keywords"] = "Schlüsselwort"
L["LF-Queue Protection"] = "LF-Warteschlange Schutz"
L["LIST_ENTRY_TYPES_REMOVE"] = "Filter entfernen"
L["Maximal group size"] = "Maximale Gruppengröße."
L["Maximal group size reached. Can't invite %s"] = "Kann %s nicht einladen. Maximale Gruppengröße erreicht."
L["Message has to exactly match with the keyword."] = "Nachricht muss genau mit dem Schlüsselwort übereinstimmen."
L["Module hasn't needed functions."] = "Modul hat nicht die nötigen Funktionen."
L["Module not found."] = "Modul nicht gefunden."
L["Modules: %s"] = "Module: %s"
L["No description for this module."] = "Keine Beschreibung für dieses Modul."
L["No module selected!"] = "Kein Modul ausgewählt!"
L["No Modules Registered"] = "Keine Module Registriert"
L["<No name given>"] = "<Kein Namen vorhanden>"
L["No realm entered. %s"] = "Kein Realm eingegeben. %s"
L["<No toon name given>"] = "<Kein Charaktername vorhanden>"
L["No value entered."] = "Kein Wert eingegeben. %s"
L["off"] = "aus"
L["on"] = "an"
L["Pattern free matching"] = "Musterfreie Übereinstimmung"
L["PF "] = true
L["PLAYER"] = "Spieler"
L["PLAYER_REALM"] = "Spieler-Realm"
L["Profile"] = true
L["REALM"] = "Realm"
L["Realm can't have '-' characters. %s"] = "Realm kann nicht das Zeichen \"z\"enthalten. %s"
L["Realm can't have white-space characters. %s"] = "Realm kann keine Leerzeichen enthalten. %s"
L["Remove this keyword."] = "Dieses Schlüsselwort entfernen."
L["Run /wi modules or /wi options to setup WisperInvite."] = "Führe /wi modules oder /wi options aus, um WhisperInvite einzurichten."
L["Send a message to inform that you are AFK."] = "Schicke eine Nachricht um zu informieren das du AFK bist."
L["Send a message to inform that you are DND."] = "Schicke eine Nachricht um zu informieren das du DND bist."
L["Send a message to inform that you have not send an invite because your are in a LF-Queue."] = "Schicke eine Nachricht, wenn du keine Einladung schicken konntest, weil du in einer LF-Warteschlange bist. "
L["Send an answer"] = "Schicke eine Antwort"
L["%s Filter: %s"] = true
L["Show a message when a invite is blocked because of filtering."] = "Zeige eine Nachricht, wenn eine Einladung aufgrund eines Filters blockiert wurde."
L["Show block message"] = "Zeige Nachricht bei Blockierung"
L["%s is not online in World of Warcraft."] = "%s ist nicht in World of Warcraft online."
L["%s is with more then one toon online. Choose which toons should be invited. Click on the name to invite."] = "%s ist mit mehr als einen Charakter online. Wähle, welcher eingeladen werden soll. Klicke auf den Namen, um diesen Charakter einzuladen."
L["%s - %s"] = true
L["%s (%s)"] = true
L["%s was not invited %s"] = "%s wurde nicht eingeladen %s"
L["%s was not invited: %s"] = "%s wurde nicht eingeladen: %s"
L["The message you will send."] = "Die Nachricht, welche du schicken wirst."
L["The size the group can reach before this keyword stops to invite."] = "Maximale Größe der Gruppe, welche erreicht werden kann, bis per Schlüsselwort nicht mehr eingeladen wird.."
L["toggle"] = "wechseln"
L["Type: %s"] = "Art: %s"
L["usage"] = "benutzung"
L["Usage: guild-realm e.g: %s-%s"] = "Benutzung: Gilde-Realm z.B: %s-%s"
L["Usage: name-realm e.g: %s-%s"] = "Benutzung: Name-Realm z.B: %s-%s"
L["Usage: /wia %s"] = "Benutzung: /wia %s"
L[ [=[Usage: /wi <command>
Commands: modules, options]=] ] = [=[Benutzung: /wi <Befehl>
Befehle: modules, options]=]
L["Usage: /wi modules moduleName (case sensitive)"] = "Benutzung: /wi modules modulName (Groß/-Kleinschreibung beachten)"
L["Use %s entry type."] = "Benutze %s Eintragsart"
L["When in the %q Queue block invites."] = "Wenn in der %q Warteschlange, werden Einladungen blockiert."
L["WhisperInvite Basic Settings"] = "WhisperInvite Basic Einstellungen"
L["/wia cache clean||reset – Clean-up or reset cache"] = "/wia cache clean||reset – Bereinigt oder setzt den Cache zurück"
L["/wia op||option – Open WhisperInviteAdvanced Options"] = "/wia op||option – Öffnet die WhisperInviteAdvanced Einstellungen"
L["WisperInvite Advanced Settings"] = "WisperInvite Advanced Einstellungen"
L["WisperInvite Core Settings"] = "WisperInvite Core Einstellungen"
L["Without pattern matching."] = "Ohne Musterübereinstimmung."
L["You are in an instance group and not in LFR or LFG group. When you can invite here players let me know it."] = "Du bist in einer Instanzgruppe und nicht in einer LFR- or LFG-Gruppe. Falls du hier andere Spieler einladen kannst, lass es mich wissen."
L["You can run /wienable to enable WisperInvite."] = "Du kannst /wienable ausführen, um WhisperInvite zu aktivieren"
L["Your are AFK. Invite to %s was not sent."] = "Du bist AFK. Einladung wurde nicht an %s gesendet"
L["Your are DND. Haven't send an invite to %s"] = "Du bist DND. Einladung wurde nicht an %s gesendet"
L["Your are DND. Invite to %s was not sent."] = "Du bist DND. Einladung wurde nicht an %s gesendet"
L["Your are in a LF-Queue. Can't invite %s"] = "Du bist ein einer LF-Warteschlange. Kann nicht %s einladen."
L["TOC/Notes"] = "Automatisches Einladen mit Schlüsselwörtern"
L["TOC/Notes.Advanced"] = "Erweitertes Einladungsmodul"
L["TOC/Notes.Basic"] = "Basic Einladungsmodul"
L["TOC/Title"] = "WhisperInvite"
L["TOC/Title.Advanced"] = "WhisperInvite Advanced"
L["TOC/Title.Basic"] = "WhisperInvite Basic"
