local CraftScan = select(2, ...)

CraftScan.LOCAL_DE = {}

function CraftScan.LOCAL_DE:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        ["CraftScan"]                             = "CraftScan",
        [LID.CRAFT_SCAN]                          = "CraftScan",
        [LID.CHAT_ORDERS]                         = "Chat-Aufträge",
        [LID.DISABLE_ADDONS]                      = "Addons deaktivieren",
        [LID.RENABLE_ADDONS]                      = "Addons reaktivieren",
        [LID.DISABLE_ADDONS_TOOLTIP]              =
        "Speichern Sie Ihre Addon-Liste und deaktivieren Sie sie dann, um schnell zu einem anderen Charakter zu wechseln. Dieser Button kann erneut geklickt werden, um die Addons jederzeit wieder zu aktivieren.",
        [LID.GREETING_I_CAN_CRAFT_ITEM]           = "Ich kann {item} herstellen.",                    -- ItemLink
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]         = "Mein Twink, {crafter}, kann {item} herstellen.", -- Crafter Name, ItemLink
        [LID.GREETING_LINK_BACKUP]                = "das",
        [LID.GREETING_I_HAVE_PROF]                = "Ich habe {profession}.",                         -- Profession Name
        [LID.GREETING_ALT_HAS_PROF]               = "Mein Twink, {crafter}, hat {profession}.",       -- Crafter Name, Profession Name
        [LID.GREETING_ALT_SUFFIX]                 = "Lassen Sie es mich wissen, wenn Sie einen Auftrag senden, damit ich umloggen kann.",
        [LID.MAIN_BUTTON_BINDING_NAME]            = "Auftragsseite umschalten",
        [LID.GREET_BUTTON_BINDING_NAME]           = "Kunden begrüßen",
        [LID.DISMISS_BUTTON_BINDING_NAME]         = "Kunden ablehnen",
        [LID.TOGGLE_CHAT_TOOLTIP]                 = "Chat-Aufträge umschalten%s", -- Keybind
        [LID.SCANNER_CONFIG_SHOW]                 = "CraftScan anzeigen",
        [LID.SCANNER_CONFIG_HIDE]                 = "CraftScan ausblenden",
        [LID.CRAFT_SCAN_OPTIONS]                  = "CraftScan-Optionen",
        [LID.ITEM_SCAN_CHECK]                     = "Chat nach diesem Gegenstand durchsuchen",
        [LID.HELP_PROFESSION_KEYWORDS]            =
        "Eine Nachricht muss einen dieser Begriffe enthalten. Um eine Nachricht wie 'LF Lariat' zu erkennen, sollte 'lariet' hier aufgelistet sein. Um einen Gegenstandslink für den Elementar-Lariat in der Antwort zu erzeugen, sollte 'lariat' auch in den Gegenstandskonfigurations-Keywords für den Elementar-Lariat enthalten sein.",
        [LID.HELP_PROFESSION_EXCLUSIONS]          =
        "Eine Nachricht wird ignoriert, wenn sie einen dieser Begriffe enthält, auch wenn sie ansonsten übereinstimmt. Um zu vermeiden, auf 'LF JC Lariat' mit 'Ich habe Juwelenschleifen' zu antworten, wenn Sie das Lariat-Rezept nicht haben, sollte 'lariat' hier aufgeführt sein.",
        [LID.HELP_SCAN_ALL]                       = "Scannen aller Rezepte derselben Erweiterung wie das ausgewählte Rezept aktivieren.",
        [LID.HELP_PRIMARY_EXPANSION]              =
        "Verwenden Sie diese Begrüßung, wenn Sie auf eine allgemeine Anfrage wie 'LF Schmied' antworten. Wenn eine neue Erweiterung erscheint, möchten Sie wahrscheinlich eine Begrüßung, die beschreibt, welche Gegenstände Sie herstellen können, anstatt zu sagen, dass Sie das maximale Wissen aus der vorherigen Erweiterung haben.",
        [LID.HELP_EXPANSION_GREETING]             =
        "Ein anfängliches Intro wird immer generiert, das besagt, dass Sie den Gegenstand herstellen können. Dieser Text wird daran angehängt. Neue Zeilen sind erlaubt und werden als separate Antwort gesendet. Wenn der Text zu lang ist, wird er in mehrere Antworten aufgeteilt.",
        [LID.HELP_CATEGORY_KEYWORDS]              =
        "Wenn ein Beruf erkannt wurde, überprüfen Sie diese kategoriespezifischen Keywords, um die Begrüßung zu verfeinern. Zum Beispiel könnten Sie 'giftig' oder 'schleimig' hier eintragen, um Lederverarbeitungsmuster zu erkennen, die den Altar der Verwesung erfordern.",
        [LID.HELP_CATEGORY_GREETING]              =
        "Wenn diese Kategorie in einer Nachricht erkannt wird, sei es durch ein Keyword oder einen Gegenstandslink, wird diese zusätzliche Begrüßung nach der Berufsbegrüßung angehängt.",
        [LID.HELP_CATEGORY_OVERRIDE]              =
        "Lassen Sie die Berufsbegrüßung weg und beginnen Sie mit der Kategoriespezifischen Begrüßung.",
        [LID.HELP_ITEM_KEYWORDS]                  =
        "Wenn ein Beruf erkannt wurde, überprüfen Sie diese gegenstandsspezifischen Keywords, um die Begrüßung zu verfeinern. Wenn sie übereinstimmen, enthält die Antwort den Gegenstandslink anstelle der allgemeinen Berufsbegrüßung. Wenn 'lariat' ein Berufsschlüsselwort, aber kein Gegenstandsschlüsselwort ist, sagt die Antwort 'Ich habe Juwelenschleifen.' Wenn 'lariat' nur ein Gegenstandsschlüsselwort ist, wird 'LF Lariat' nicht als Beruf erkannt und nicht als Treffer gewertet. Wenn 'lariat' sowohl ein Berufs- als auch ein Gegenstandsschlüsselwort ist, lautet die Antwort auf 'LF Lariat' 'Ich kann [Elementar-Lariat] herstellen.'",
        [LID.HELP_ITEM_GREETING]                  =
        "Wenn dieser Gegenstand in einer Nachricht erkannt wird, sei es durch ein Keyword oder den Gegenstandslink, wird diese zusätzliche Begrüßung nach der Berufs- und Kategoriespezifischen Begrüßung angehängt.",
        [LID.HELP_ITEM_OVERRIDE]                  =
        "Lassen Sie die Berufs- und Kategoriespezifische Begrüßung weg und beginnen Sie mit der Gegenstandsspezifischen Begrüßung.",
        [LID.HELP_GLOBAL_KEYWORDS]                = "Eine Nachricht muss einen dieser Begriffe enthalten.",
        [LID.HELP_GLOBAL_EXCLUSIONS]              = "Eine Nachricht wird ignoriert, wenn sie einen dieser Begriffe enthält.",
        [LID.SCAN_ALL_RECIPES]                    = 'Alle Rezepte scannen',
        [LID.SCANNING_ENABLED]                    = "Das Scannen ist aktiviert, weil '%s' ausgewählt ist.", -- SCAN_ALL_RECIPES or ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]                   = "Das Scannen ist deaktiviert.",
        [LID.PRIMARY_KEYWORDS]                    = "Primäre Schlüsselwörter",
        [LID.HELP_PRIMARY_KEYWORDS]               =
        "Alle Nachrichten werden durch diese Begriffe gefiltert, die für alle Berufe gemeinsam sind. Eine übereinstimmende Nachricht wird weiterverarbeitet, um berufsbezogene Inhalte zu suchen.",
        [LID.HELP_CATEGORY_SECTION]               =
        "Die Kategorie ist der zusammenklappbare Abschnitt, der das Rezept in der Liste links enthält. 'Favoriten' ist keine Kategorie. Dies ist hauptsächlich für Dinge wie die giftigen Lederverarbeitungsrezepte gedacht, die schwieriger herzustellen sind. Es könnte auch nützlich sein zu Beginn von Erweiterungen, wenn Sie sich nur auf eine Kategorie spezialisieren können.",
        [LID.HELP_EXPANSION_SECTION]              =
        "Wissensbäume unterscheiden sich je nach Erweiterung, daher kann auch die Begrüßung unterschiedlich sein.",
        [LID.HELP_PROFESSION_SECTION]             =
        "Aus Kundensicht gibt es keinen Unterschied zwischen Erweiterungen. Diese Begriffe kombinieren sich mit der Auswahl der 'Primären Erweiterung', um eine allgemeine Begrüßung zu bieten (z.B. 'Ich habe <Beruf>.'), wenn wir nichts Spezifischeres erkennen können.",
        [LID.RECIPE_NOT_LEARNED]                  = "Sie haben dieses Rezept nicht gelernt. Das Scannen ist deaktiviert.",
        [LID.PING_SOUND_LABEL]                    = "Alarmton",
        [LID.PING_SOUND_TOOLTIP]                  = "Der Ton, der abgespielt wird, wenn ein Kunde erkannt wird.",
        [LID.BANNER_SIDE_LABEL]                   = "Banner-Richtung",
        [LID.BANNER_SIDE_TOOLTIP]                 = "Das Banner wird von der Schaltfläche in diese Richtung wachsen.",
        Left                                      = "Links",
        Right                                     = "Rechts",
        Minute                                    = "Minute",
        Minutes                                   = "Minuten",
        Second                                    = "Sekunde",
        Seconds                                   = "Sekunden",
        Millisecond                               = "Millisekunde",
        Milliseconds                              = "Millisekunden",
        Version                                   = "Neu in",
        ["CraftScan Release Notes"]               = "CraftScan Release Notes",
        [LID.CUSTOMER_TIMEOUT_LABEL]              = "Kunden-Timeout",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]            = "Kunden automatisch nach dieser Anzahl von Minuten abweisen.",
        [LID.BANNER_TIMEOUT_LABEL]                = "Banner-Timeout",
        [LID.BANNER_TIMEOUT_TOOLTIP]              =
        "Das Kundenbenachrichtigungsbanner bleibt für diese Dauer nach Erkennung eines Treffers angezeigt.",
        ["All crafters"]                          = "Alle Handwerker",
        ["Crafter Name"]                          = "Handwerkername",
        ["Profession"]                            = "Beruf",
        ["Customer Name"]                         = "Kundenname",
        ["Replies"]                               = "Antworten",
        ["Keywords"]                              = "Schlüsselwörter",
        ["Profession greeting"]                   = "Berufsbegrüßung",
        ["Category greeting"]                     = "Kategoriebegrüßung",
        ["Item greeting"]                         = "Gegenstandsbegrüßung",
        ["Primary expansion"]                     = "Primäre Erweiterung",
        ["Override greeting"]                     = "Begrüßung überschreiben",
        ["Excluded keywords"]                     = "Ausgeschlossene Schlüsselwörter",
        [LID.EXCLUSION_INSTRUCTIONS]              =
        "Nachrichten, die diese durch Kommas getrennten Tokens enthalten, nicht übereinstimmen.",
        [LID.KEYWORD_INSTRUCTIONS]                =
        "Nachrichten, die eines dieser durch Kommas getrennten Schlüsselwörter enthalten, übereinstimmen.",
        [LID.GREETING_INSTRUCTIONS]               = "Eine Begrüßung, die an Kunden gesendet wird, die eine Herstellung suchen.",
        [LID.GLOBAL_INCLUSION_DEFAULT]            = "LF, LFC, WTB, neuherstellen",
        [LID.GLOBAL_EXCLUSION_DEFAULT]            = "LFW, WTS, LF Arbeit",
        [LID.DEFAULT_KEYWORDS_BLACKSMITHING]      = "BS, Schmied, Waffenschmied, Rüstungsschmied",
        [LID.DEFAULT_KEYWORDS_LEATHERWORKING]     = "LW, Lederverarbeitung, Lederarbeiter",
        [LID.DEFAULT_KEYWORDS_ALCHEMY]            = "Alch, Alchemist, Stein",
        [LID.DEFAULT_KEYWORDS_TAILORING]          = "Schneider",
        [LID.DEFAULT_KEYWORDS_ENGINEERING]        = "Ingenieur, Ing",
        [LID.DEFAULT_KEYWORDS_ENCHANTING]         = "Verzauberer, Wappen",
        [LID.DEFAULT_KEYWORDS_JEWELCRAFTING]      = "JC, Juwelenschleifer",
        [LID.DEFAULT_KEYWORDS_INSCRIPTION]        = "Inschriftenkunde, Schreiber",

        -- Release notes
        [LID.RN_WELCOME]                          = "Willkommen bei CraftScan!",
        [LID.RN_WELCOME + 1]                      =
        "Dieses Addon scannt den Chat nach Nachrichten, die wie Anfragen für das Herstellen aussehen. Wenn die Konfiguration anzeigt, dass Sie den gewünschten Gegenstand herstellen können, wird eine Benachrichtigung ausgelöst und die Kundeninformation gespeichert, um die Kommunikation zu erleichtern.",

        [LID.RN_INITIAL_SETUP]                    = "Erste Einrichtung",
        [LID.RN_INITIAL_SETUP + 1]                =
        "Um zu beginnen, öffnen Sie einen Beruf und klicken Sie auf die neue Schaltfläche 'CraftScan anzeigen' unten.",
        [LID.RN_INITIAL_SETUP + 2]                =
        "Scrollen Sie bis zum unteren Rand dieses neuen Fensters und arbeiten Sie sich nach oben. Die Dinge, die Sie selten ändern müssen, befinden sich unten, aber diese Einstellungen sind zuerst wichtig.",
        [LID.RN_INITIAL_SETUP + 3]                =
        "Klicken Sie auf das Hilfe-Symbol in der oberen linken Ecke des Fensters, wenn Sie eine Erklärung zu einem Eingabefeld benötigen.",

        [LID.RN_INITIAL_TESTING]                  = "Erste Tests",
        [LID.RN_INITIAL_TESTING + 1]              =
        "Sobald Sie konfiguriert sind, geben Sie eine Nachricht im /say-Chat ein, wie 'LF BS' für Schmiedekunst, vorausgesetzt, Sie haben die 'LF' und 'BS' Schlüsselwörter beibehalten. Eine Benachrichtigung sollte erscheinen.",
        [LID.RN_INITIAL_TESTING + 2]              =
        "Klicken Sie auf die Benachrichtigung, um sofort eine Antwort zu senden, klicken Sie mit der rechten Maustaste, um den Kunden abzulehnen, oder klicken Sie auf die runde Berufsschaltfläche selbst, um das Auftragsfenster zu öffnen.",
        [LID.RN_INITIAL_TESTING + 3]              =
        "Doppelte Benachrichtigungen werden unterdrückt, es sei denn, sie wurden bereits abgelehnt, daher klicken Sie mit der rechten Maustaste auf Ihre Testbenachrichtigung, um sie abzulehnen, wenn Sie es erneut versuchen möchten.",

        [LID.RN_MANAGING_CRAFTERS]                = "Verwalten Ihrer Handwerker",
        [LID.RN_MANAGING_CRAFTERS + 1]            =
        "Die linke Seite des Auftragsfensters listet Ihre Handwerker auf. Diese Liste wird gefüllt, während Sie sich bei Ihren verschiedenen Charakteren einloggen und deren Berufe konfigurieren. Sie können jederzeit auswählen, welche Charaktere aktiv gescannt werden sollen und ob die visuellen und akustischen Benachrichtigungen für jeden Ihrer Handwerker aktiviert sind.",

        [LID.RN_MANAGING_CUSTOMERS]               = "Verwalten der Kunden",
        [LID.RN_MANAGING_CUSTOMERS + 1]           =
        "Die rechte Seite des Auftragsfensters wird mit im Chat erkannten Herstellungsaufträgen gefüllt. Klicken Sie auf eine Zeile, um die Begrüßung zu senden, wenn Sie dies nicht bereits über das Pop-up-Banner getan haben. Klicken Sie erneut, um ein Flüstern an den Kunden zu öffnen. Klicken Sie mit der rechten Maustaste, um die Zeile abzulehnen.",
        [LID.RN_MANAGING_CUSTOMERS + 2]           =
        "Zeilen in dieser Tabelle bleiben über alle Charaktere hinweg erhalten, sodass Sie zu einem Twink umloggen und dann erneut auf den Kunden klicken können, um die Kommunikation wiederherzustellen. Zeilen laufen standardmäßig nach 10 Minuten ab. Diese Dauer kann auf der Hauptseite der Einstellungen konfiguriert werden (Esc -> Optionen -> AddOns -> CraftScan).",
        [LID.RN_MANAGING_CUSTOMERS + 3]           =
        "Hoffentlich ist die Tabelle weitgehend selbsterklärend. Die 'Antworten'-Spalte hat 3 Symbole. Das linke X oder Häkchen zeigt an, ob Sie dem Kunden eine Nachricht gesendet haben. Das rechte X oder Häkchen zeigt an, ob der Kunde geantwortet hat. Die Sprechblase ist eine Schaltfläche, die ein temporäres Flüsterfenster mit dem Kunden öffnet und es mit Ihrem Chatverlauf füllt.",

        [LID.RN_KEYBINDS]                         = "Tastenkombinationen",
        [LID.RN_KEYBINDS + 1]                     =
        "Tastenkombinationen sind verfügbar, um die Auftragsseite zu öffnen, auf den neuesten Kunden zu antworten und den neuesten Kunden abzulehnen. Suchen Sie nach 'CraftScan', um alle verfügbaren Einstellungen zu finden.",

        [LID.RN_CLEANUP]                          = "Konfigurationsbereinigung",
        [LID.RN_CLEANUP + 1]                      =
        "Ihre Handwerker auf der linken Seite der 'Chat-Aufträge'-Seite haben jetzt ein Kontextmenü, wenn Sie mit der rechten Maustaste klicken. Verwenden Sie dieses Menü, um die Liste sauber zu halten und veraltete Charaktere/Berufe zu entfernen.",

        ["Disable"]                               = "Deaktivieren",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]          =
        "Löschen Sie dauerhaft alle gespeicherten %s-Daten für %s.\n\nEine Schaltfläche 'CraftScan aktivieren' wird auf der Berufsseite angezeigt, um es wieder mit den Standardeinstellungen zu aktivieren.\n\nVerwenden Sie dies, wenn Sie den Beruf weiter nutzen möchten, aber ohne CraftScan-Interaktion (z.B. wenn Sie Alchemie auf jedem Twink für lange Fläschchen haben).", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]               = "Geben Sie 'DELETE' ein, um fortzufahren:",
        [LID.SCANNER_CONFIG_DISABLED]             = "CraftScan aktivieren",

        ["Cleanup"]                               = "Bereinigen",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]         =
        "Löschen Sie dauerhaft alle gespeicherten %s-Daten für %s.\n\nDer Beruf wird in einem Zustand zurückgelassen, als wäre er nie konfiguriert worden. Einfaches Öffnen des Berufs wird eine Standardkonfiguration wiederherstellen.\n\nVerwenden Sie dies, wenn Sie einen Beruf komplett zurücksetzen möchten, den Charakter gelöscht haben oder den Beruf abgelegt haben.", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]              = "Geben Sie 'CLEANUP' ein, um fortzufahren:",

        ["Primary Crafter"]                       = "Haupt-Handwerker",
        [LID.PRIMARY_CRAFTER_TOOLTIP]             =
        "Markiere %s als deinen Haupt-Handwerker für %s. Dieser Handwerker wird Vorrang vor anderen haben, wenn es mehrere Übereinstimmungen mit derselben Anfrage gibt.",
        ["Chat History"]                          = "Chatverlauf mit %s", -- customer, left-click-help
        ["Greet Help"]                            = "|cffffd100Linksklick: Kunde begrüßen%s|r",
        ["Chat Help"]                             = "|cffffd100Linksklick: Flüstern öffnen|r",
        ["Chat Override"]                         = "|cffffd100Mittelklick: Flüstern öffnen%s|r",
        ["Dismiss"]                               = "|cffffd100Rechtsklick: Verwerfen%s|r",
        ["Proposed Greeting"]                     = "Vorgeschlagene Begrüßung:",
        [LID.CHAT_BUTTON_BINDING_NAME]            = "Flüster-Banner-Kunde",
        ["Customer Request"]                      = "Anfrage von %s",

        [LID.ADDON_WHITELIST_LABEL]               = "Addon-Whitelist",
        [LID.ADDON_WHITELIST_TOOLTIP]             =
        "Wenn du den Button drückst, um alle Addons vorübergehend zu deaktivieren, bleiben die hier ausgewählten Addons aktiviert. CraftScan bleibt immer aktiviert. Behalte nur das, was du zum effektiven Handwerk benötigst.",
        [LID.MULTI_SELECT_BUTTON_TEXT]            = "%d ausgewählt", -- Count

        [LID.ACCOUNT_LINK_DESC]                   =
        "Teile Handwerker zwischen mehreren Accounts.\n\nBeim Einloggen oder nach einer Konfigurationsänderung wird CraftScan die neuesten Informationen zwischen den konfigurierten Accounts synchronisieren, um sicherzustellen, dass beide Seiten eines verlinkten Accounts immer auf dem neuesten Stand sind.",
        [LID.ACCOUNT_LINK_PROMPT_CHARACTER]       = "Gib den Namen eines Charakters auf deinem anderen Account ein:",
        [LID.ACCOUNT_LINK_PROMPT_NICKNAME]        = "Gib einen Spitznamen für den anderen Account ein:",
        ["Link Account"]                          = "Account verlinken",
        ["Linked Accounts"]                       = "Verlinkte Accounts",
        ["Accept Linked Account"]                 = "Verlinkten Account akzeptieren",
        ["Delete Linked Account"]                 = "Verlinkten Account löschen",
        ["OK"]                                    = "OK",
        [LID.VERSION_MISMATCH]                    =
        "|cFFFF0000Fehler: CraftScan-Version nicht kompatibel. Andere Account-Version: %s. Deine Version: %s.|r",

        [LID.REMOTE_CRAFTER_TOOLTIP]              =
        "Dieser Charakter gehört zu einem verlinkten Account. Er kann nur auf dem Account, dem er gehört, deaktiviert werden. Du kannst diesen Charakter vollständig über 'Bereinigung' entfernen, musst dies jedoch manuell auf allen verlinkten Accounts tun, sonst wird er beim Einloggen wiederhergestellt.",
        [LID.REMOTE_CRAFTER_SUMMARY]              = "Synchronisiert mit %s.",
        ["proxy_send_enabled"]                    = "Proxy-Aufträge",
        ["proxy_send_enabled_tooltip"]            = "Wenn eine Kundenbestellung erkannt wird, sende sie an verlinkte Accounts.",
        ["proxy_receive_enabled"]                 = "Proxy-Aufträge empfangen",
        ["proxy_receive_enabled_tooltip"]         =
        "Wenn ein anderer Account eine Kundenbestellung erkennt und sendet, empfängt dieser Account sie. Der CraftScan-Button wird angezeigt, um bei Bedarf das Benachrichtigungsbanner zu zeigen.",
        [LID.LINK_ACTIVE]                         = "|cFF00FF00%s (zuletzt gesehen %s)|r", -- Crafter, Time
        [LID.ACCOUNT_LINK_DELETE_INFO]            =
        "Lösche die Verlinkung zu '%s' und alle importierten Charaktere. Dieser Account wird jegliche Kommunikation mit der anderen Seite einstellen. Die andere Seite wird weiterhin versuchen, Verbindungen herzustellen, bis die Verlinkung auch dort manuell entfernt wird.\n\nEntfernte importierte Handwerker:\n%s",
        [LID.ACCOUNT_LINK_ADD_CHAR]               =
        "Standardmäßig sind der Charakter, den du zunächst verlinkt hast, alle Handwerker und alle Charaktere, die eingeloggt waren, während dieser Account online war, bei CraftScan bekannt. Füge weitere Charaktere des anderen Accounts hinzu, damit sie ebenfalls verwendet werden können. '/reload', um die Synchronisierung mit dem neuen Charakter zu erzwingen, wenn dieser online ist.",
        ["Backup characters"]                     = "Zusätzliche Charaktere",
        ["Unlink account"]                        = "Account entkoppeln",
        ["Add"]                                   = "Hinzufügen",
        ["Remove"]                                = "Entfernen",
        ["Rename account"]                        = "Account umbenennen",
        ["New name"]                              = "Neuer Name:",

        [LID.RN_LINKED_ACCOUNTS]                  = "Verlinkte Accounts",
        [LID.RN_LINKED_ACCOUNTS + 1]              =
        "Verlinke mehrere WoW-Accounts, um Handwerksinformationen zu teilen und von jedem Account aus zu scannen.",
        [LID.RN_LINKED_ACCOUNTS + 2]              =
        "Optional: Proxy-Kundenaufträge von einem Account zu den anderen senden, damit du einen Testaccount in der Stadt parken kannst, während dein Hauptcharakter unterwegs ist.",
        [LID.RN_LINKED_ACCOUNTS + 3]              =
        "Um loszulegen, klicke auf den 'Account verlinken'-Button in der unteren linken Ecke des CraftScan-Fensters und folge den Anweisungen.",
        [LID.RN_LINKED_ACCOUNTS + 4]              = "Demo: https://www.youtube.com/watch?v=x1JLEph6t_c",

        ["Open Settings"]                         = "Einstellungen öffnen",
        ["Customize Greeting"]                    = "Begrüßung anpassen",
        [LID.CUSTOM_GREETING_INFO]                =
        "CraftScan verwendet diese Sätze, um die anfängliche Begrüßung je nach Situation an Kunden zu senden. Überschreiben Sie unten einige oder alle, um Ihre eigene Begrüßung zu erstellen.",
        ["Default"]                               = "Standard",
        [LID.MISSING_PLACEHOLDERS]                = "Die folgenden Platzhalter werden ebenfalls unterstützt: %s.",
        [LID.EXTRA_PLACEHOLDERS]                  = "Fehler: %s sind keine gültigen Platzhalter.",
        [LID.LEGACY_PLACEHOLDERS]                 =
        "Achtung: Die Verwendung von %s ist mittlerweile veraltet. Bitte verwenden Sie benannte Platzhalter, wie folgt: {placeholder}",

        ["Pixels"]                                = "Pixel",
        ["Show button height"]                    = "Buttonhöhe anzeigen",
        ["Alert icon scale"]                      = "Alarm-Icon-Skalierung",
        ["Total"]                                 = "Gesamt",
        ["Repeat"]                                = "Wiederholen",
        ["Avg Per Day"]                           = "Durchschn./Tag",
        ["Peak Per Hour"]                         = "Spitze/Stunde",
        ["Median Per Customer"]                   = "Median/Kunde",
        ["Median Per Customer Filtered"]          = "Median/Kunde Wiederholung",
        ["No analytics data"]                     = "Keine Analysedaten",
        ["Reset Analytics"]                       = "Analysen zurücksetzen",
        ["Analytics Options"]                     = "Analyseoptionen",

        ["1 minute"]                              = "1 Minute",
        ["15 minutes "]                           = "15 Minuten",
        ["1 hour"]                                = "1 Stunde",
        ["1 day"]                                 = "1 Tag",
        ["1 week "]                               = "1 Woche",
        ["30 days"]                               = "30 Tage",
        ["180 days"]                              = "180 Tage",
        ["1 year"]                                = "1 Jahr",
        ["Clear recent data"]                     = "Kürzliche Daten löschen",
        ["Newer than"]                            = "Jünger als",
        ["Clear old data"]                        = "Alte Daten löschen",
        ["Older than"]                            = "Älter als",
        ["1 Minute Bins"]                         = "1-Minuten-Intervalle",
        ["5 Minute Bins"]                         = "5-Minuten-Intervalle",
        ["10 Minute Bins"]                        = "10-Minuten-Intervalle",
        ["30 Minute Bins"]                        = "30-Minuten-Intervalle",
        ["1 Hour Bins"]                           = "1-Stunden-Intervalle",
        ["6 Hour Bins"]                           = "6-Stunden-Intervalle",
        ["12 Hour Bins"]                          = "12-Stunden-Intervalle",
        ["24 Hour Bins"]                          = "24-Stunden-Intervalle",
        ["1 Week Bins"]                           = "1-Wochen-Intervalle",

        [LID.ANALYTICS_ITEM_TOOLTIP]              =
        "Items werden durch Abgleich mit globalen Ein- und Ausschluss-Schlüsselwörtern sowie durch Erkennen des Qualitätsicons in einem Itemlink gefunden. Es gibt keine globale Liste von hergestellten Items oder eine Möglichkeit, zu bestimmen, ob eine ItemID hergestellt ist, daher ist dies die beste Methode.",
        [LID.ANALYTICS_PROFESSION_TOOLTIP]        =
        "Es gibt keinen Rückwärtsverweis von einem Item zu dem Beruf, der es herstellt. Wenn einer deiner Charaktere das Item herstellen kann, wird der Beruf automatisch zugewiesen. Wenn ein Beruf geöffnet wird, werden unbekannte Items zugeordnet. Du kannst auch manuell einen Beruf zuweisen.",
        [LID.ANALYTICS_TOTAL_TOOLTIP]             =
        "Die Gesamtanzahl der Anfragen für dieses Item. Doppelte Anfragen vom selben Kunden innerhalb einer Stunde werden nicht berücksichtigt.",
        [LID.ANALYTICS_REPEAT_TOOLTIP]            =
        "Die Gesamtanzahl der Anfragen für dieses Item von demselben Kunden mehrmals innerhalb einer Stunde.\n\nWenn dieser Wert nah am Gesamtwert liegt, fehlt wahrscheinlich das Angebot für dieses Item.\n\nDoppelte Anfragen innerhalb von 15 Sekunden nach der ersten Anfrage werden ignoriert.",
        [LID.ANALYTICS_AVERAGE_TOOLTIP]           = "Die durchschnittliche Anzahl von Anfragen für dieses Item pro Tag.",
        [LID.ANALYTICS_PEAK_TOOLTIP]              = "Die maximale Anzahl von Anfragen pro Stunde für dieses Item.",
        [LID.ANALYTICS_MEDIAN_TOOLTIP]            =
        "Der Median der Anzahl von Anfragen durch denselben Kunden für dasselbe Item innerhalb einer Stunde.\n\nEin Wert von 1 deutet darauf hin, dass mindestens die Hälfte der Anfragen erfüllt wird und die Nachfrage für dieses Item wahrscheinlich gedeckt ist.\n\nIst dieser Wert hoch, ist es wahrscheinlich lohnenswert, das Item herstellen zu können.",
        [LID.ANALYTICS_MEDIAN_TOOLTIP_FILTERED]   =
        "Der Median der Anzahl von Anfragen durch denselben Kunden für dasselbe Item innerhalb einer Stunde, gefiltert nach Anfragen, bei denen der Kunde mehrfach angefragt hat.\n\nWenn dieser Wert nicht 1 ist, aber der ungefilterte Median 1 ist, deutet das darauf hin, dass die Nachfrage manchmal nicht erfüllt wird.",
        ["Request Count"]                         = "Anzahl der Anfragen",
        [LID.ACCOUNT_LINK_ACCEPT_DST_INFO]        =
        "'%s' hat eine Anfrage zum Verknüpfen von Accounts gesendet.\n\nFolgende Berechtigungen wurden angefordert:\n\n%s\n\nNimm keine volle Berechtigung an, es sei denn, du hast die Anfrage gesendet.\n\nGib einen Spitznamen für den anderen Account ein:",
        [LID.LINKED_ACCOUNT_REJECTED]             = "CraftScan: Verknüpfungsanfrage abgelehnt. Grund: %s",
        [LID.LINKED_ACCOUNT_USER_REJECTED]        = "Zielaccount hat die Anfrage abgelehnt.",

        [LID.LINKED_ACCOUNT_PERMISSION_FULL]      = "Vollzugriff",
        [LID.LINKED_ACCOUNT_PERMISSION_ANALYTICS] = "Analyse-Synchronisierung",
        [LID.ACCOUNT_LINK_PERMISSIONS_DESC]       = "Fordere folgende Berechtigungen mit dem verknüpften Account an.",
        [LID.ACCOUNT_LINK_FULL_CONTROL_DESC]      =
        "Synchronisiert alle Charakterdaten und unterstützt alle anderen Berechtigungen.",
        [LID.ACCOUNT_LINK_ANALYTICS_DESC]         =
        "Synchronisiert nur Analysedaten manuell über das Accountmenü zwischen beiden Accounts. Jeder Account kann zu jeder Zeit eine Zwei-Wege-Synchronisation auslösen. Da keine Charaktere importiert werden, wird nur der hier angegebene Charakter synchronisiert. Weitere Alts des verknüpften Accounts können manuell hinzugefügt werden.",
        ["Sync Analytics"]                        = "Analysen synchronisieren",
        ["Sync Recent Analytics"]                 = "Aktuelle Analysen synchronisieren",
        [LID.ANALYTICS_PROF_MISMATCH]             =
        "|cFFFF0000CraftScan: Warnung: Analyse-Synchronisations-Berufsunterschied. Item: %s. Lokaler Beruf: %s. Verknüpfter Beruf: %s.|r",
        [LID.RN_ANALYTICS]                        = "Analysen",
        [LID.RN_ANALYTICS + 1]                    =
        "CraftScan scannt jetzt den Chat nach hergestellten Items in Verbindung mit deinen globalen Schlüsselwörtern (z.B. LF, recraft usw.), auch wenn du das Item nicht herstellen kannst. Die Zeit wird aufgezeichnet und erkannte Items werden unter den üblichen Aufträgen im Chat angezeigt.",
        [LID.RN_ANALYTICS + 2]                    =
        "Das Konzept der 'Wiederholungen' wird verwendet, um festzustellen, ob es bei einem Item an Angebot mangelt. CraftScan merkt sich, wer welches Item in der letzten Stunde angefordert hat. Wenn die gleiche Anfrage erneut gestellt wird, wird dies als Wiederholung erfasst. Die Spaltenköpfe des neuen Rasters enthalten Tooltips, die ihre Absicht erklären.",
        [LID.RN_ANALYTICS + 3]                    =
        "Mit einem Charakter, der lange genug im Handelschat parkt, solltest du einen guten Überblick darüber bekommen, welche Bereiche des Berufszweigs es wert sind, investiert zu werden.",
        [LID.RN_ANALYTICS + 4]                    =
        "Analysen können über mehrere Accounts synchronisiert werden. Du kannst einen Probeaccount den ganzen Tag im Handelschat parken, um Daten zu sammeln, und diese dann mit deinem Hauptaccount synchronisieren. Es ist jetzt auch möglich, eine reine Analyse-Verknüpfung mit einem Freund zu erstellen, die eine Zwei-Wege-Synchronisation unterstützt, bei der deine Analysen zusammengeführt werden. Sobald die Sammlung groß genug ist, gibt es eine Option, nur Daten seit dem letzten Synchronisationszeitpunkt zu synchronisieren.",
        [LID.RN_ALERT_ICON_ANCHOR]                = "Alarm-Icon-Verankerungs-Updates",
        [LID.RN_ALERT_ICON_ANCHOR + 1]            =
        "Das Alarm-Icon wird jetzt korrekt ausgeblendet, wenn das UI ausgeblendet ist. Die Änderung hat es auf meinem Bildschirm leicht verschoben und skaliert. Wenn der Button von deinem Bildschirm verschwunden ist, gibt es eine Reset-Option, wenn du mit Rechtsklick auf den 'Einstellungen öffnen'-Button oben rechts auf der Chat-Auftragsseite klickst.",
        [LID.BUSY_RIGHT_NOW]                      = "Beschäftigt-Modus",
        [LID.GREETING_BUSY]                       = "Ich bin gerade beschäftigt, kann das aber später herstellen, wenn du es schickst.",
        [LID.BUSY_HELP]                           =
        "|cFFFFFFFFWenn aktiviert, wird die beschäftigte Begrüßung in deine Antwort eingefügt. Bearbeite deine beschäftigte Begrüßung mit dem Button unten.\n\nDies ist für die Verwendung mit einem zweiten Account gedacht, der Aufträge übernimmt, damit du Aufträge erhalten kannst, während du mit deinem Hauptaccount unterwegs bist.\n\nAktuelle beschäftigte Begrüßung: |cFF00FF00%s|r|r",
        ["Custom Explanations"]                   = "Benutzerdefinierte Erklärungen",
        ["Create"]                                = "Erstellen",
        ["Modify"]                                = "Ändern",
        ["Delete"]                                = "Löschen",
        [LID.EXPLANATION_LABEL_DESC]              =
        "Gib eine Bezeichnung ein, die du siehst, wenn du mit Rechtsklick auf den Kundennamen im Chat klickst.",
        [LID.EXPLANATION_DUPLICATE_LABEL]         = "Diese Bezeichnung wird bereits verwendet.",
        [LID.EXPLANATION_TEXT_DESC]               =
        "Gib eine Nachricht ein, die an den Kunden gesendet wird, wenn die Bezeichnung angeklickt wird. Neue Zeilen werden als separate Nachrichten gesendet. Lange Zeilen werden gekürzt, um in die maximale Nachrichtenlänge zu passen.",
        ["Create an Explanation"]                 = "Eine Erklärung erstellen",
        ["Save"]                                  = "Speichern",
        ["Reset"]                                 = "Zurücksetzen",
        [LID.MANUAL_MATCHING_TITLE]               = "Manuelles Abgleichen",
        [LID.MANUAL_MATCH]                        = "%s - %s", -- Handwerker, Beruf
        [LID.MANUAL_MATCHING_DESC]                =
        "Ignoriere primäre Schlüsselwörter und zwinge ein Abgleich für diese Nachricht. CraftScan wird versuchen, den richtigen Handwerker basierend auf der Nachricht zu finden, aber wenn keine Übereinstimmungen gefunden werden, wird die Standardbegrüßung für den angegebenen Handwerker verwendet. Die Übereinstimmung wird über die üblichen Mittel gemeldet, sodass du auf das Banner oder die Tabellenzeile klicken kannst, um die Begrüßung zu senden.",

        [LID.RN_MANUAL_MATCH]                     = "Manuelles Abgleichen",
        [LID.RN_MANUAL_MATCH + 1]                 =
        "Das Kontextmenü beim Rechtsklick auf einen Spielernamen im Chat enthält jetzt CraftScan-Optionen.",
        [LID.RN_MANUAL_MATCH + 2]                 =
        "Dieses Menü enthält alle deine Handwerker und Berufe. Ein Klick auf eines dieser Elemente zwingt einen weiteren Durchgang der Nachricht, um nach einer Übereinstimmung zu suchen, ohne die 'Primären Schlüsselwörter' zu berücksichtigen (z.B. LF, WTB, recraft usw.), falls der Kunde nicht-standardisierte Begriffe verwendet.",
        [LID.RN_MANUAL_MATCH + 3]                 =
        "Wenn die Nachricht immer noch nicht übereinstimmt, wird eine Übereinstimmung mit der Standardbegrüßung für den Handwerker und Beruf erzwungen, auf den du geklickt hast.",
        [LID.RN_MANUAL_MATCH + 4]                 =
        "Dieser Klick sendet nicht automatisch eine Nachricht an den Kunden. Es wird die Übereinstimmung auf die übliche Weise generiert, und dann kannst du die generierte Antwort inspizieren und entscheiden, ob du sie senden möchtest oder nicht.",
        [LID.RN_MANUAL_MATCH + 5]                 = "(Entschuldigung, kein maschinelles Lernen.)",
        [LID.RN_CUSTOM_EXPLANATIONS]              = "Benutzerdefinierte Erklärungen",
        [LID.RN_CUSTOM_EXPLANATIONS + 1]          =
        "Die Seite 'Chat-Aufträge' enthält jetzt einen Button für 'Benutzerdefinierte Erklärungen'. Hier konfigurierte Erklärungen erscheinen auch im Kontextmenü des Chats, und ein Klick darauf sendet sofort die Erklärung.",
        [LID.RN_CUSTOM_EXPLANATIONS + 2]          =
        "Erklärungen werden alphabetisch sortiert, daher kannst du sie nummerieren, um eine gewünschte Reihenfolge zu erzwingen.",
        [LID.RN_BUSY_MODE]                        = "Beschäftigt-Modus",
        [LID.RN_BUSY_MODE + 1]                    =
        "Das war schon seit einigen Versionen drin, wurde aber nie erklärt. Es gibt eine neue 'Beschäftigt-Modus'-Checkbox auf der Seite 'Chat-Aufträge'. Wenn aktiviert, wird die beschäftigte Begrüßung in deiner Antwort angehängt. Bearbeite deine beschäftigte Begrüßung mit dem Button 'Begrüßung anpassen'.",
        [LID.RN_BUSY_MODE + 2]                    =
        "Dies ist für die Verwendung mit einem zweiten Account gedacht, der Aufträge übernimmt, damit du Aufträge erhalten kannst, während du mit deinem Hauptaccount unterwegs bist, und der Kunde weiß, dass du es nicht sofort herstellen kannst.",
        ["Release Notes"]                         = "Versionshinweise",

        ["Secondary Keywords"]                    = "Sekundäre Schlüsselwörter",
        [LID.SECONDARY_KEYWORD_INSTRUCTIONS]      =
        "Zum Beispiel: 'pvp, 610, algari' oder '606, 610, 636' oder '590', um dasselbe Schlüsselwort auf mehreren Gegenständen zu unterscheiden.",
        [LID.HELP_ITEM_SECONDARY_KEYWORDS]        =
        "Nachdem ein Schlüsselwort oben übereinstimmt, prüfen Sie auf sekundäre Schlüsselwörter, um die Übereinstimmung zu verfeinern und die verschiedenen Handwerke für denselben Gegenstandsslot zu unterscheiden.",
        [LID.RN_SECONDARY_KEYWORDS]               = "Sekundäre Schlüsselwörter",
        [LID.RN_SECONDARY_KEYWORDS + 1]           =
        "Gegenstände unterstützen nun sekundäre Schlüsselwörter, um eine Übereinstimmung zu verfeinern. Jeder Gegenstandsslot hat normalerweise eine Funkens-, PVP- und Blaue Version. Sekundäre Schlüsselwörter können eingerichtet werden, um sie zu unterscheiden.",
        [LID.RN_SECONDARY_KEYWORDS + 2]           = "Beispiel für sekundäre Schlüsselwörter:",
        [LID.RN_SECONDARY_KEYWORDS + 3]           = "606, 619, 636",
        [LID.RN_SECONDARY_KEYWORDS + 4]           = "610, pvp, algari",
        [LID.RN_SECONDARY_KEYWORDS + 5]           = "590",

        ["Find Crafter"]                          = "Handwerker finden",
        ["No Crafters Found"]                     = "Keine Handwerker gefunden",
        [LID.FOUND_CRAFTER_NAME_ENTRY]            = "%s [%s]",
        [LID.GREET_FOUND_CRAFTER]                 = "|cffffd100Linksklick: Handwerksauftrag anfragen|r",
        ["Crafter Greeting"]                      = "|cFFFFFFFFHandwerker Begrüßung|r",
        [LID.BUSY_ICON]                           =
        "|cFFFFFFFFDer Handwerker hat angegeben, dass er derzeit beschäftigt ist, aber später das Item herstellen kann.\n\nÜberprüfen Sie seine Begrüßung für Details.|r",
        ["Potential Crafters"]                    = "Mögliche Handwerker",
        [LID.FOUND_VIA_CRAFT_SCAN]                =
        "Ich habe dich über CraftScan gefunden und deine Begrüßung gesehen. Kannst du %s jetzt für mich herstellen?",
        [LID.COMMISSION_INSTRUCTIONS]             =
        "z.B. '10000g', Standard: 'Beliebig'\nDieser Text erscheint in der 'Handwerker finden'-Tabelle des Kunden.",
        ["Commission"]                            = "Provision",
        ["Crafter [Currently Playing]"]           = "Handwerker [Zurzeit im Spiel]",
        ["Profession commission"]                 = "Berufsprovision",
        [LID.DEFAULT_COMMISSION]                  = "Beliebig",
        [LID.HELP_ITEM_COMMISSION]                =
        "CraftScan bietet Kunden einen 'Handwerker finden'-Button bei persönlichen Aufträgen. Dein Name, deine Begrüßung und diese Provision erscheinen zusammen mit anderen Handwerkern in der Tabelle. Die Länge ist auf 12 Zeichen begrenzt, um gut in die Tabelle des Kunden zu passen.",
        ["Discoverable"]                          = "Für Kunden auffindbar",
        [LID.DISCOVERABLE_SETTING]                =
        "Wenn aktiviert, erscheint dein Name in der generierten Tabelle, wenn ein Kunde 'Handwerker finden' auswählt und du den Gegenstand herstellen kannst.",
        [LID.RN_CUSTOMER_SEARCH]                  = "Handwerker finden",
        [LID.RN_CUSTOMER_SEARCH + 1]              =
        "Die Seite zum Senden eines persönlichen Auftrags hat jetzt einen 'Handwerker finden'-Button. Dieser Button sendet eine Anfrage an alle CraftScan-Nutzer, um zu sehen, wer den Gegenstand herstellen kann, und zeigt die Ergebnisse in einer Tabelle mit der konfigurierten Provision des Handwerkers an.",
        [LID.RN_CUSTOMER_SEARCH + 2]              =
        "Jeder Beruf und Gegenstand hat jetzt ein 'Provision'-Feld, um anzugeben, was in dieser Tabelle angezeigt wird. Der Text ist auf 12 Zeichen begrenzt, um in die Tabelle zu passen.",
        [LID.RN_CUSTOMER_SEARCH + 3]              =
        "Du bist dem 'CraftScan'-Kanal beigetreten, aber du musst ihn nicht aktivieren oder Nachrichten im Kanal sehen. Er dient dazu, dass CraftScan private Anfragen wie üblich im Handelschat senden kann.",
        [LID.RN_CUSTOMER_SEARCH + 4]              =
        "Als Handwerker kannst du jetzt unaufgeforderte Flüsternachrichten von Kunden erhalten, die bereits wissen, was du herstellen kannst.",
        [LID.RN_CUSTOMER_SEARCH + 5]              =
        "Das ist etwas schwierig zu testen, da Testaccounts keinen Zugang zur Handwerkstabelle haben. Wenn du auf Probleme stößt, kannst du das Feature deaktivieren, bis ich es beheben kann.",
        [LID.RN_CUSTOMER_SEARCH + 6]              =
        "Du kannst über die neue 'Auffindbar'-Einstellung im Hauptmenü der Blizzard-Einstellungen von dieser Tabelle ausgeschlossen werden.",
        [LID.RN_CUSTOMER_SEARCH + 7]              =
        "Da Kunden möglicherweise anfangen, das Addon zu nutzen, kann die Analysefunktion vollständig deaktiviert werden. Standardmäßig ist sie jetzt deaktiviert. Wenn du bereits Daten gesammelt hast, bleibt sie aktiviert.",
        ["Permissive keyword matching"]           = "Erlaubte Schlüsselwortübereinstimmung",
        [LID.PERMISSIVE_MATCH_SETTING]            =
        "Wenn diese Option aktiviert ist, wird CraftScan keine Rücksicht auf Leerzeichen und andere Trennzeichen nehmen, wenn es nach Schlüsselwortübereinstimmungen sucht. Standardmäßig wird CraftScan nur ein Schlüsselwort abgleichen, wenn es klar vom umgebenden Text abgegrenzt ist, um falsche Übereinstimmungen von kurzen Schlüsselwörtern, die in anderen Wörtern eingebettet sind, zu vermeiden. Für Sprachen, die keine Leerzeichen zur Abgrenzung von Schlüsselwörtern verwenden, aktivieren Sie diese Option.",
        ["Show chat orders tab"]                  = "Chat-Bestellungen-Tab anzeigen",
        [LID.SHOW_CHAT_ORDER_TAB]                 =
        "Zeigt oder versteckt den Tab 'Chat-Bestellungen' im Berufsfenster. Wenn ausgeblendet, kann die Seite der Chat-Bestellungen durch Klicken auf die CraftScan-Schaltfläche bei den Warnungen geöffnet werden.",
        [LID.IGNORE]                              = "Ignorieren",
        [LID.IGNORE_TOOLTIP]                      =
        "Fügt diesen Spieler zur CraftScan-Ignoreliste hinzu. CraftScan wird alle Nachrichten von diesem Spieler ignorieren. Über dieses Menü kann der Spieler aus der Liste entfernt werden.",
        [LID.UNIGNORE]                            = "Ignorieren entfernen",
        [LID.UNIGNORE_TOOLTIP]                    =
        "Dieser Spieler ist auf deiner CraftScan-Ignoreliste. Diese Option entfernt ihn aus der Liste.",
        ["Collapse chat context menu"]            = "Chat-Kontextmenü reduzieren",
        [LID.COLLAPSE_CHAT_CONTEXT_TOOLTIP]       =
        "Beim Rechtsklick auf einen Spielernamen im Chat alle Kontextmenüeinträge in ein einzelnes CraftScan-Untermenü reduzieren.",

        [LID.PROXY_ORDERS_TOOLTIP]                =
        "Sende Aufträge, die von diesem Konto erkannt wurden, an verknüpfte Konten mit 'Vollzugriff'-Berechtigungen. Das empfangende Konto zeigt die übliche Benachrichtigung an, als hätte es den Auftrag selbst erkannt.",
        [LID.RECEIVE_PROXY_ORDERS_TOOLTIP]        =
        "Empfange Aufträge, die von einem verknüpften 'Vollzugriff'-Konto erkannt und weitergeleitet wurden. Wenn ein Auftrag vom verknüpften Konto empfangen wird, erscheint die übliche Benachrichtigung auf diesem Konto.",

        [LID.LOCAL_ALERTS_TOOLTIP]                =
        "Visuelle und akustische Benachrichtigungen für diesen Handwerker und Beruf werden nur angezeigt, wenn du diesen Charakter spielst. Dies ist nur ein Filter und aktiviert oder deaktiviert Benachrichtigungen nicht generell. Die Benachrichtigungen werden weiterhin über die Quest- und Headset-Symbole rechts in der Handwerkerliste verwaltet.",
        ["Local Notifications Only"]              = "Nur lokale Benachrichtigungen",

    }
end
