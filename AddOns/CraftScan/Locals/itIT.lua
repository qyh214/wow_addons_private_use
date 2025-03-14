local CraftScan = select(2, ...)

CraftScan.LOCAL_IT = {}

function CraftScan.LOCAL_IT:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        ["CraftScan"]                             = "CraftScan",
        [LID.CRAFT_SCAN]                          = "CraftScan",
        [LID.CHAT_ORDERS]                         = "Ordini Chat",
        [LID.DISABLE_ADDONS]                      = "Disabilita Addon",
        [LID.RENABLE_ADDONS]                      = "Riabilita Addon",
        [LID.DISABLE_ADDONS_TOOLTIP]              =
        "Salva la lista dei tuoi addon e disabilitali, consentendo uno scambio rapido ad un alt. Questo pulsante può essere premuto nuovamente per riabilitare gli addon in qualsiasi momento.",
        [LID.GREETING_I_CAN_CRAFT_ITEM]           = "Posso creare {item}.",                        -- ItemLink
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]         = "Il mio alter, {crafter}, può creare {item}.", -- Crafter Name, ItemLink
        [LID.GREETING_LINK_BACKUP]                = "quello",
        [LID.GREETING_I_HAVE_PROF]                = "Ho {profession}.",                            -- Profession Name
        [LID.GREETING_ALT_HAS_PROF]               = "Il mio alter, {crafter}, ha {profession}.",   -- Crafter Name, Profession Name
        [LID.GREETING_ALT_SUFFIX]                 = "Fammi sapere se invii un ordine così posso cambiare personaggio.",
        [LID.MAIN_BUTTON_BINDING_NAME]            = "Mostra Pagina Ordini",
        [LID.GREET_BUTTON_BINDING_NAME]           = "Saluta Cliente",
        [LID.DISMISS_BUTTON_BINDING_NAME]         = "Rimuovi Cliente",
        [LID.TOGGLE_CHAT_TOOLTIP]                 = "Attiva/Disattiva ordini chat%s", -- Keybind
        [LID.SCANNER_CONFIG_SHOW]                 = "Mostra CraftScan",
        [LID.SCANNER_CONFIG_HIDE]                 = "Nascondi CraftScan",
        [LID.CRAFT_SCAN_OPTIONS]                  = "Opzioni CraftScan",
        [LID.ITEM_SCAN_CHECK]                     = "Scansiona chat per questo oggetto",
        [LID.HELP_PROFESSION_KEYWORDS]            =
        "Un messaggio deve contenere uno di questi termini. Per corrispondere a un messaggio come 'LF Lariat', 'lariet' dovrebbe essere elencato qui. Per generare un link dell'oggetto per il Lariat Elementale nella risposta, 'lariat' dovrebbe essere incluso anche nei termini di configurazione dell'oggetto per il Lariat Elementale.",
        [LID.HELP_PROFESSION_EXCLUSIONS]          =
        "Un messaggio verrà ignorato se contiene uno di questi termini, anche se altrimenti sarebbe una corrispondenza. Per evitare di rispondere a 'LF JC Lariat' con 'Ho la Gioielleria' quando non hai la ricetta del Lariat, 'lariat' dovrebbe essere elencato qui.",
        [LID.HELP_SCAN_ALL]                       =
        "Abilita la scansione per tutte le ricette nella stessa espansione della ricetta selezionata.",
        [LID.HELP_PRIMARY_EXPANSION]              =
        "Usa questo saluto quando rispondi a una richiesta generica come 'LF Blacksmith'. Quando viene lanciata una nuova espansione, probabilmente desidererai un saluto che descriva quali oggetti puoi creare anziché affermare di avere conoscenze massime dall'espansione precedente.",
        [LID.HELP_EXPANSION_GREETING]             =
        "Viene sempre generata un'introduzione iniziale affermando che puoi creare l'oggetto. Questo testo viene aggiunto. Le nuove righe sono consentite e verranno inviate come risposta separata. Se il testo è troppo lungo, verrà diviso in più risposte.",
        [LID.HELP_CATEGORY_KEYWORDS]              =
        "Se una professione viene abbinata, controlla questi termini specifici della categoria per raffinare il saluto. Ad esempio, potresti mettere 'toxic' o 'slimy' qui per tentare di rilevare schemi di Conciatura che richiedono l'Altare del Decadimento.",
        [LID.HELP_CATEGORY_GREETING]              =
        "Quando viene rilevata questa categoria in un messaggio, tramite una parola chiave o un link all'oggetto, questo saluto aggiuntivo verrà aggiunto dopo il saluto della professione.",
        [LID.HELP_CATEGORY_OVERRIDE]              = "Ometti il saluto della professione e inizia con il saluto della categoria.",
        [LID.HELP_ITEM_KEYWORDS]                  =
        "Se una professione viene abbinata, controlla questi termini specifici dell'oggetto per raffinare il saluto. Quando viene abbinato, la risposta includerà il link all'oggetto invece del saluto generico della professione. Se 'lariat' è una parola chiave della professione, ma non una parola chiave dell'oggetto, la risposta dirà 'Ho la Gioielleria'. Se 'lariat' è solo una parola chiave dell'oggetto, 'LF Lariat' non corrisponderà a una professione e non è considerato un abbinamento. Se 'lariat' è sia una parola chiave della professione che dell'oggetto, la risposta a 'LF Lariat' sarà 'Posso creare [Lariat Elementale].'",
        [LID.HELP_ITEM_GREETING]                  =
        "Quando viene rilevato questo oggetto in un messaggio, tramite una parola chiave o il link all'oggetto, questo saluto aggiuntivo verrà aggiunto dopo i saluti della professione e della categoria.",
        [LID.HELP_ITEM_OVERRIDE]                  =
        "Ometti il saluto della professione e della categoria e inizia con il saluto dell'oggetto.",
        [LID.HELP_GLOBAL_KEYWORDS]                = "Un messaggio deve includere uno di questi termini.",
        [LID.HELP_GLOBAL_EXCLUSIONS]              = "Un messaggio verrà ignorato se contiene uno di questi termini.",
        [LID.SCAN_ALL_RECIPES]                    = 'Scansiona tutte le ricette',
        [LID.SCANNING_ENABLED]                    = "La scansione è abilitata perché '%s' è selezionato.", -- SCAN_ALL_RECIPES o ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]                   = "La scansione è disabilitata.",
        [LID.PRIMARY_KEYWORDS]                    = "Parole chiave primarie",
        [LID.HELP_PRIMARY_KEYWORDS]               =
        "Tutti i messaggi sono filtrati da questi termini, che sono comuni a tutte le professioni. Un messaggio corrispondente viene ulteriormente elaborato per cercare contenuti correlati alla professione.",
        [LID.HELP_CATEGORY_SECTION]               =
        "La categoria è la sezione espandibile che contiene la ricetta nell'elenco a sinistra. 'Preferiti' non è una categoria. È destinato principalmente a cose come le ricette di Conciatura tossiche che sono più difficili da creare. Potrebbe anche essere utile all'inizio delle espansioni quando puoi solo specializzarti in una singola categoria.",
        [LID.HELP_EXPANSION_SECTION]              =
        "I rami della conoscenza differiscono per espansione, quindi il saluto può anche differire.",
        [LID.HELP_PROFESSION_SECTION]             =
        "Dal punto di vista del cliente, non c'è differenza tra le espansioni. Questi termini si combinano con la selezione della 'Espansione primaria' per fornire un saluto generico (ad es. 'Ho <professione>.') quando non possiamo corrispondere a qualcosa di più specifico.",
        [LID.RECIPE_NOT_LEARNED]                  = "Non hai appreso questa ricetta. La scansione è disabilitata.",
        [LID.PING_SOUND_LABEL]                    = "Suono di avviso",
        [LID.PING_SOUND_TOOLTIP]                  = "Il suono che si attiva quando viene rilevato un cliente.",
        [LID.BANNER_SIDE_LABEL]                   = "Direzione del banner",
        [LID.BANNER_SIDE_TOOLTIP]                 = "Il banner si espanderà dal pulsante in questa direzione.",
        Sinistra                                  = "Sinistra",
        Destra                                    = "Destra",
        Minuto                                    = "Minuto",
        Minuti                                    = "Minuti",
        Secondo                                   = "Secondo",
        Secondi                                   = "Secondi",
        Millisecondo                              = "Millisecondo",
        Millisecondi                              = "Millisecondi",
        Versione                                  = "Nuovo in",
        ["Note sulla versione di CraftScan"]      = "Note sulla versione di CraftScan",
        [LID.CUSTOMER_TIMEOUT_LABEL]              = "Timeout cliente",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]            = "Rimuovi automaticamente i clienti dopo questo numero di minuti.",
        [LID.BANNER_TIMEOUT_LABEL]                = "Timeout del banner",
        [LID.BANNER_TIMEOUT_TOOLTIP]              =
        "Il banner di notifica del cliente rimarrà visualizzato per questa durata dopo che è stata rilevata una corrispondenza.",
        ["Tutti i creatori"]                      = "Tutti i creatori",
        ["Nome del creatore"]                     = "Nome del creatore",
        ["Professione"]                           = "Professione",
        ["Nome del cliente"]                      = "Nome del cliente",
        ["Risposte"]                              = "Risposte",
        ["Parole chiave"]                         = "Parole chiave",
        ["Saluto della professione"]              = "Saluto della professione",
        ["Saluto della categoria"]                = "Saluto della categoria",
        ["Saluto dell'oggetto"]                   = "Saluto dell'oggetto",
        ["Espansione primaria"]                   = "Espansione primaria",
        ["Saluto di override"]                    = "Saluto di override",
        ["Parole chiave escluse"]                 = "Parole chiave escluse",
        [LID.EXCLUSION_INSTRUCTIONS]              = "Non corrispondere ai messaggi contenenti questi token separati da virgola.",
        [LID.KEYWORD_INSTRUCTIONS]                =
        "Corrispondere ai messaggi contenenti una di queste parole chiave separate da virgola.",
        [LID.GREETING_INSTRUCTIONS]               = "Un saluto da inviare ai clienti in cerca di una creazione.",
        [LID.GLOBAL_INCLUSION_DEFAULT]            = "LF, LFC, WTB, ricreare",
        [LID.GLOBAL_EXCLUSION_DEFAULT]            = "LFW, WTS, LF lavoro",
        [LID.DEFAULT_KEYWORDS_BLACKSMITHING]      = "BS, Fabbro, Fabbro d'armature, Fabbro d'armi",
        [LID.DEFAULT_KEYWORDS_LEATHERWORKING]     = "LW, Conciatura, Conciatore",
        [LID.DEFAULT_KEYWORDS_ALCHEMY]            = "Alc, Alchimista, Pietra",
        [LID.DEFAULT_KEYWORDS_TAILORING]          = "Sarto",
        [LID.DEFAULT_KEYWORDS_ENGINEERING]        = "Ingegnere, Ing",
        [LID.DEFAULT_KEYWORDS_ENCHANTING]         = "Incantatore, Cresta",
        [LID.DEFAULT_KEYWORDS_JEWELCRAFTING]      = "GC, Gioielliere",
        [LID.DEFAULT_KEYWORDS_INSCRIPTION]        = "Iscrip, Iscrizione, Iscrivano",

        -- Note sulla versione
        [LID.RN_WELCOME]                          = "Benvenuto in CraftScan!",
        [LID.RN_WELCOME + 1]                      =
        "Questo addon analizza la chat per messaggi che sembrano richieste di creazioni. Se la configurazione indica che puoi creare l'oggetto richiesto, verrà attivata una notifica e le informazioni sul cliente verranno memorizzate per facilitare la comunicazione.",

        [LID.RN_INITIAL_SETUP]                    = "Impostazione iniziale",
        [LID.RN_INITIAL_SETUP + 1]                =
        "Per iniziare, apri una professione e clicca sul nuovo pulsante 'Mostra CraftScan' lungo il fondo.",
        [LID.RN_INITIAL_SETUP + 2]                =
        "Scorri fino in fondo a questa nuova finestra e procedi dall'alto verso il basso. Le cose che raramente devi cambiare sono in fondo, ma quelle sono le impostazioni a cui devi prestare attenzione per prima cosa.",
        [LID.RN_INITIAL_SETUP + 3]                =
        "Clicca sull'icona di aiuto nell'angolo in alto a sinistra della finestra se hai bisogno di spiegazioni su qualsiasi input.",

        [LID.RN_INITIAL_TESTING]                  = "Test iniziale",
        [LID.RN_INITIAL_TESTING + 1]              =
        "Una volta configurato, digita un messaggio nella chat /say, come 'LF BS' per la Fabbro, assumendo di aver lasciato le parole chiave 'LF' e 'BS'. Dovrebbe apparire una notifica.",

        [LID.RN_INITIAL_TESTING + 2]              =
        "Clicca sulla notifica per inviare immediatamente una risposta, clicca con il tasto destro per rimuovere il cliente, o clicca sul pulsante circolare della professione per aprire la finestra degli ordini.",
        [LID.RN_INITIAL_TESTING + 3]              =
        "Le notifiche duplicate vengono soppresso a meno che non siano già state rimosse, quindi clicca con il tasto destro sulla tua notifica di test per rimuoverla se vuoi riprovare.",

        [LID.RN_MANAGING_CRAFTERS]                = "Gestione dei tuoi creatori",
        [LID.RN_MANAGING_CRAFTERS + 1]            =
        "Nella parte sinistra della finestra degli ordini sono elencati i tuoi creatori. Questo elenco verrà popolato man mano che accedi ai tuoi vari personaggi e configuri le loro professioni. Puoi selezionare quali personaggi devono essere attivamente scannerizzati in qualsiasi momento, nonché se le notifiche visive e uditive sono abilitate per ciascuno dei tuoi creatori.",

        [LID.RN_MANAGING_CUSTOMERS]               = "Gestione dei clienti",
        [LID.RN_MANAGING_CUSTOMERS + 1]           =
        "Nella parte destra della finestra degli ordini verranno elencati gli ordini di creazione rilevati nella chat. Fai clic sinistro su una riga per inviare il saluto se non lo hai già fatto dal banner a comparsa. Fai clic sinistro nuovamente per aprire un sussurro al cliente. Fai clic destro per rimuovere la riga.",
        [LID.RN_MANAGING_CUSTOMERS + 2]           =
        "Le righe in questa tabella persistono tra tutti i personaggi, quindi puoi passare ad un alter e quindi fare nuovamente clic sul cliente per ripristinare la comunicazione. Le righe scadono dopo 10 minuti per impostazione predefinita. Questa durata può essere configurata nella pagina delle impostazioni principali (Esc -> Opzioni -> AddOns -> CraftScan).",
        [LID.RN_MANAGING_CUSTOMERS + 3]           =
        "Si spera che la maggior parte della tabella sia autoesplicativa. La colonna 'Risposte' ha 3 icone. La spunta o la X sinistra indica se hai inviato un messaggio al cliente. La spunta o la X destra indica se il cliente ha risposto. La bolla di chat è un pulsante che aprirà una finestra di sussurro temporanea con il cliente e la popolerà con la tua cronologia delle chat.",

        [LID.RN_KEYBINDS]                         = "Tasti di scelta rapida",
        [LID.RN_KEYBINDS + 1]                     =
        "I tasti di scelta rapida sono disponibili per aprire la pagina degli ordini, rispondere all'ultimo cliente e rimuovere l'ultimo cliente. Cerca 'CraftScan' per trovare tutte le impostazioni disponibili.",

        [LID.RN_CLEANUP]                          = "Pulizia della Configurazione",
        [LID.RN_CLEANUP + 1]                      =
        "I tuoi artigiani sul lato sinistro della pagina 'Ordini Chat' hanno ora un menu contestuale quando fai clic con il pulsante destro del mouse. Usa questo menu per mantenere pulita la lista e rimuovere personaggi/professioni obsolete.",
        ["Disable"]                               = "Disabilita",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]          =
        "Elimina permanentemente qualsiasi dato %s salvato per %s.\n\nUn pulsante 'Abilita CraftScan' sarà presente nella pagina della professione per abilitarlo nuovamente con le impostazioni predefinite.\n\nUsa questo se vuoi continuare a utilizzare la professione, ma senza l'interazione di CraftScan (ad esempio, quando hai l'Alchimia su tutti i personaggi secondari per le pozioni lunghe).", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]               = "Digita 'DELETE' per procedere:",
        [LID.SCANNER_CONFIG_DISABLED]             = "Abilita CraftScan",

        ["Cleanup"]                               = "Pulizia",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]         =
        "Elimina permanentemente qualsiasi dato %s salvato per %s.\n\nLa professione verrà lasciata in uno stato come se non fosse mai stata configurata. Semplicemente aprendo di nuovo la professione verrà ripristinata una configurazione predefinita.\n\nUsa questo se vuoi resettare completamente una professione, hai eliminato il personaggio o hai abbandonato una professione.", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]              = "Digita 'CLEANUP' per procedere:",

        ["Primary Crafter"]                       = "Artigiano Principale",
        [LID.PRIMARY_CRAFTER_TOOLTIP]             =
        "Segna %s come il tuo artigiano principale per %s. Questo artigiano avrà la priorità sugli altri se ci sono più corrispondenze con la stessa richiesta.",
        ["Chat History"]                          = "Cronologia chat con %s", -- customer, left-click-help
        ["Greet Help"]                            = "|cffffd100Clic sinistro: Saluta il cliente%s|r",
        ["Chat Help"]                             = "|cffffd100Clic sinistro: Apri sussurro|r",
        ["Chat Override"]                         = "|cffffd100Clic centrale: Apri sussurro%s|r",
        ["Dismiss"]                               = "|cffffd100Clic destro: Ignora%s|r",
        ["Proposed Greeting"]                     = "Saluto proposto:",
        [LID.CHAT_BUTTON_BINDING_NAME]            = "Cliente Banner Sussurro",
        ["Customer Request"]                      = "Richiesta da %s",
        [LID.ADDON_WHITELIST_LABEL]               = "Lista bianca degli addon",
        [LID.ADDON_WHITELIST_TOOLTIP]             =
        "Quando premi il pulsante per disattivare temporaneamente tutti gli addon, mantieni attivi gli addon selezionati qui. CraftScan rimarrà sempre attivo. Mantieni solo ciò che ti serve per craftare efficacemente.",
        [LID.MULTI_SELECT_BUTTON_TEXT]            = "%d selezionati", -- Count

        [LID.ACCOUNT_LINK_DESC]                   =
        "Condividi gli artigiani tra più account.\n\nAl login o dopo una modifica della configurazione, CraftScan propaga le ultime informazioni tra gli artigiani configurati su entrambi gli account per garantire che entrambi i lati di un account collegato siano sempre sincronizzati.",
        [LID.ACCOUNT_LINK_PROMPT_CHARACTER]       = "Inserisci il nome di un personaggio online sull'altro tuo account:",
        [LID.ACCOUNT_LINK_PROMPT_NICKNAME]        = "Inserisci un soprannome per l'altro account:",
        ["Link Account"]                          = "Collega Account",
        ["Linked Accounts"]                       = "Account Collegati",
        ["Accept Linked Account"]                 = "Accetta Account Collegato",
        ["Delete Linked Account"]                 = "Elimina Account Collegato",
        ["OK"]                                    = "OK",
        [LID.VERSION_MISMATCH]                    =
        "|cFFFF0000Errore: versione di CraftScan non compatibile. Versione dell'altro account: %s. La tua versione: %s.|r",

        [LID.REMOTE_CRAFTER_TOOLTIP]              =
        "Questo personaggio appartiene a un account collegato. Può essere disattivato solo sull'account a cui appartiene. Puoi rimuovere completamente questo personaggio tramite 'Pulizia', ma dovrai farlo manualmente su tutti gli account collegati, altrimenti sarà ripristinato da un account collegato al login.",
        [LID.REMOTE_CRAFTER_SUMMARY]              = "Sincronizzato con %s.",
        ["proxy_send_enabled"]                    = "Ordini Proxy",
        ["proxy_send_enabled_tooltip"]            = "Quando viene rilevato un ordine cliente, invialo agli account collegati.",
        ["proxy_receive_enabled"]                 = "Ricevi Ordini Proxy",
        ["proxy_receive_enabled_tooltip"]         =
        "Quando un altro account rileva e invia un ordine cliente, questo account lo riceverà. Il pulsante CraftScan sarà visualizzato per mostrare l'avviso se necessario.",
        [LID.LINK_ACTIVE]                         = "|cFF00FF00%s (visto l'ultima volta %s)|r", -- Crafter, Time
        [LID.ACCOUNT_LINK_DELETE_INFO]            =
        "Elimina il collegamento con '%s' e tutti i personaggi importati. Questo account cesserà ogni comunicazione con l'altro lato. L'altro lato continuerà a tentare di stabilire connessioni fino a quando il collegamento non sarà eliminato manualmente anche lì.\n\nArtigiani importati che saranno eliminati:\n%s",
        [LID.ACCOUNT_LINK_ADD_CHAR]               =
        "Per impostazione predefinita, il personaggio che hai inizialmente collegato, qualsiasi artigiano e qualsiasi personaggio che si è connesso mentre questo account era online sono conosciuti da CraftScan. Aggiungi personaggi aggiuntivi appartenenti all'altro account in modo che possano essere utilizzati anche loro. '/reload' per forzare la sincronizzazione con il nuovo personaggio se è online.",
        ["Backup characters"]                     = "Personaggi Aggiuntivi",
        ["Unlink account"]                        = "Scollega Account",
        ["Add"]                                   = "Aggiungi",
        ["Remove"]                                = "Rimuovi",
        ["Rename account"]                        = "Rinomina Account",
        ["New name"]                              = "Nuovo Nome:",

        [LID.RN_LINKED_ACCOUNTS]                  = "Account Collegati",
        [LID.RN_LINKED_ACCOUNTS + 1]              =
        "Collega più account WoW insieme per condividere informazioni di crafting e scannerizzare da qualsiasi account.",
        [LID.RN_LINKED_ACCOUNTS + 2]              =
        "Facoltativamente, invia ordini cliente per proxy da un account agli altri così puoi lasciare un account di prova in città mentre il tuo main è in giro.",
        [LID.RN_LINKED_ACCOUNTS + 3]              =
        "Per iniziare, clicca sul pulsante 'Collega Account' nell'angolo in basso a sinistra della finestra di CraftScan e segui le istruzioni.",
        [LID.RN_LINKED_ACCOUNTS + 4]              = "Demo: https://www.youtube.com/watch?v=x1JLEph6t_c",
        ["Open Settings"]                         = "Apri Impostazioni",
        ["Customize Greeting"]                    = "Personalizza Saluto",
        [LID.CUSTOM_GREETING_INFO]                =
        "CraftScan utilizza queste frasi per creare il saluto iniziale inviato ai clienti a seconda della situazione. Sovrascrivi alcune o tutte qui sotto per creare il tuo saluto.",
        ["Default"]                               = "Predefinito",
        [LID.MISSING_PLACEHOLDERS]                = "I segnaposto seguenti sono anche supportati: %s.",
        [LID.EXTRA_PLACEHOLDERS]                  = "Errore: %s non sono segnaposto validi.",
        [LID.LEGACY_PLACEHOLDERS]                 =
        "Attenzione: l'uso di %s è ora deprecato. Si prega di utilizzare segnaposto denominati, come segue: {placeholder}",

        ["Pixels"]                                = "Pixeli",
        ["Show button height"]                    = "Mostra altezza del pulsante",
        ["Alert icon scale"]                      = "Scala icona di avviso",
        ["Total"]                                 = "Totale",
        ["Repeat"]                                = "Ripeti",
        ["Avg Per Day"]                           = "Media/Giorno",
        ["Peak Per Hour"]                         = "Picco/Ora",
        ["Median Per Customer"]                   = "Mediana/Cliente",
        ["Median Per Customer Filtered"]          = "Mediana/Cliente Ripetuto",
        ["No analytics data"]                     = "Nessun dato analitico",
        ["Reset Analytics"]                       = "Ripristina Analitica",
        ["Analytics Options"]                     = "Opzioni Analitica",

        ["1 minute"]                              = "1 minuto",
        ["15 minutes "]                           = "15 minuti ",
        ["1 hour"]                                = "1 ora",
        ["1 day"]                                 = "1 giorno",
        ["1 week "]                               = "1 settimana ",
        ["30 days"]                               = "30 giorni",
        ["180 days"]                              = "180 giorni",
        ["1 year"]                                = "1 anno",
        ["Clear recent data"]                     = "Pulisci dati recenti",
        ["Newer than"]                            = "Più recente di",
        ["Clear old data"]                        = "Pulisci dati vecchi",
        ["Older than"]                            = "Più vecchio di",
        ["1 Minute Bins"]                         = "Scaglioni da 1 Minuto",
        ["5 Minute Bins"]                         = "Scaglioni da 5 Minuti",
        ["10 Minute Bins"]                        = "Scaglioni da 10 Minuti",
        ["30 Minute Bins"]                        = "Scaglioni da 30 Minuti",
        ["1 Hour Bins"]                           = "Scaglioni da 1 Ora",
        ["6 Hour Bins"]                           = "Scaglioni da 6 Ore",
        ["12 Hour Bins"]                          = "Scaglioni da 12 Ore",
        ["24 Hour Bins"]                          = "Scaglioni da 24 Ore",
        ["1 Week Bins"]                           = "Scaglioni da 1 Settimana",

        [LID.ANALYTICS_ITEM_TOOLTIP]              =
        "Gli oggetti vengono abbinati assicurandosi che un messaggio corrisponda alle parole chiave globali di inclusione ed esclusione, e poi cercando l'icona di qualità in un link dell'oggetto. Non esiste un elenco globale di oggetti creati o un modo per determinare se un itemID è creato, quindi questo è il meglio che possiamo fare.",
        [LID.ANALYTICS_PROFESSION_TOOLTIP]        =
        "Non esiste un ricerca inversa dall'oggetto alla professione che lo crea. Se uno dei tuoi personaggi può creare l'oggetto, la professione viene assegnata automaticamente. Quando viene aperta una professione, gli oggetti sconosciuti appartenenti a quella professione vengono assegnati. Puoi anche assegnare manualmente la professione.",
        [LID.ANALYTICS_TOTAL_TOOLTIP]             =
        "Il numero totale di volte che questo oggetto è stato richiesto. Le richieste duplicate dallo stesso cliente nella stessa ora non sono incluse.",
        [LID.ANALYTICS_REPEAT_TOOLTIP]            =
        "Il numero totale di volte che questo oggetto è stato richiesto dallo stesso cliente più volte nella stessa ora.\n\nSe questo valore è vicino al Totale, la fornitura per questo oggetto è probabilmente insufficiente.\n\nLe richieste duplicate entro 15 secondi dalla richiesta iniziale vengono ignorate.",
        [LID.ANALYTICS_AVERAGE_TOOLTIP]           = "Il numero medio di richieste totali per questo oggetto al giorno.",
        [LID.ANALYTICS_PEAK_TOOLTIP]              = "Il numero massimo di richieste per questo oggetto all'ora.",
        [LID.ANALYTICS_MEDIAN_TOOLTIP]            =
        "Il numero mediano di volte in cui lo stesso cliente ha richiesto lo stesso oggetto nella stessa ora.\n\nUn valore di 1 indica che almeno la metà di tutte le richieste viene soddisfatta da qualcuno e la domanda per questo oggetto è probabilmente soddisfatta.\n\nSe questo valore è alto, è probabile che questo sia un buon oggetto da perseguire per la creazione.",
        [LID.ANALYTICS_MEDIAN_TOOLTIP_FILTERED]   =
        "Il numero mediano di volte in cui lo stesso cliente ha richiesto lo stesso oggetto nella stessa ora, filtrato per includere solo quelle richieste in cui il richiedente ha chiesto più volte.\n\nSe questo valore non è 1 ma la mediana non filtrata è 1, ciò indica che ci sono momenti in cui la domanda non è soddisfatta.",
        ["Request Count"]                         = "Conteggio Richieste",
        [LID.ACCOUNT_LINK_ACCEPT_DST_INFO]        =
        "'%s' ha inviato una richiesta per collegare gli account.\n\nLe seguenti autorizzazioni sono state richieste:\n\n%s\n\nNon accettare l'autorizzazione completa a meno che tu non abbia inviato la richiesta.\n\nInserisci un soprannome per l'altro account:",
        [LID.LINKED_ACCOUNT_REJECTED]             = "CraftScan: Richiesta di collegamento dell'account non riuscita. Motivo: %s",
        [LID.LINKED_ACCOUNT_USER_REJECTED]        = "L'account target ha rifiutato la richiesta.",

        [LID.LINKED_ACCOUNT_PERMISSION_FULL]      = "Controllo Completo",
        [LID.LINKED_ACCOUNT_PERMISSION_ANALYTICS] = "Sincronizzazione Analitica",
        [LID.ACCOUNT_LINK_PERMISSIONS_DESC]       = "Richiedi le seguenti autorizzazioni con l'account collegato.",
        [LID.ACCOUNT_LINK_FULL_CONTROL_DESC]      =
        "Sincronizza tutti i dati dei personaggi e supporta anche tutte le altre autorizzazioni.",
        [LID.ACCOUNT_LINK_ANALYTICS_DESC]         =
        "Sincronizza solo i dati analitici tra i due account manualmente tramite il menu dell'account. Qualsiasi account può attivare una sincronizzazione bidirezionale in qualsiasi momento. Non viene mai eseguita automaticamente. Poiché nessun personaggio viene importato, sincronizzerai solo con il personaggio specificato qui. Puoi aggiungere manualmente più alts dell'account collegato dal menu dell'account.",
        ["Sync Analytics"]                        = "Sincronizza Analitica",
        ["Sync Recent Analytics"]                 = "Sincronizza Analitica Recenti",
        [LID.ANALYTICS_PROF_MISMATCH]             =
        "|cFFFF0000CraftScan: Attenzione: Discrepanza nella professione di sincronizzazione analitica. Oggetto: %s. Professione locale: %s. Professione collegata: %s.|r",
        [LID.RN_ANALYTICS]                        = "Analitica",
        [LID.RN_ANALYTICS + 1]                    =
        "CraftScan ora scansiona la chat per qualsiasi oggetto creato combinato con le tue parole chiave globali (ad es. LF, recraft, ecc...), anche se non puoi creare l'oggetto. Il tempo viene registrato e gli oggetti rilevati sono visualizzati sotto gli ordini usuali trovati in chat.",
        [LID.RN_ANALYTICS + 2]                    =
        "Il concetto di 'ripetizioni' è utilizzato per determinare se un oggetto è privo di fornitura. CraftScan ricorda chi ha richiesto cosa nell'ultima ora, e se richiedono la stessa cosa di nuovo, viene registrato come una ripetizione. Le intestazioni delle colonne della nuova griglia hanno tooltip che spiegano il loro intento.",
        [LID.RN_ANALYTICS + 3]                    =
        "Con un personaggio parcheggiato nella chat commerciale abbastanza a lungo, questo dovrebbe costruire una buona visione di quali rami dell'albero delle professioni valgano un investimento.",
        [LID.RN_ANALYTICS + 4]                    =
        "Le analitiche possono essere sincronizzate attraverso più account. Puoi parcheggiare un account trial nel commercio tutto il giorno per raccogliere dati, poi sincronizzarli con il tuo account principale. Puoi anche ora creare un collegamento solo per le analitiche con un amico, supportando una sincronizzazione bidirezionale che unisce le tue analitiche. Una volta che la raccolta diventa ampia, c'è un'opzione per sincronizzare solo i dati dall'ultima volta che gli account sono stati sincronizzati.",
        [LID.RN_ALERT_ICON_ANCHOR]                = "Aggiornamenti di Ancoraggio Icona di Avviso",
        [LID.RN_ALERT_ICON_ANCHOR + 1]            =
        "L'icona di avviso ora verrà nascosta correttamente quando l'interfaccia è nascosta. La modifica l'ha spostata e scalata leggermente sul mio schermo. Se il pulsante è stato spostato fuori dal tuo schermo a causa di questo, c'è un'opzione di ripristino se fai clic con il tasto destro sul pulsante 'Apri Impostazioni' in alto a destra della pagina degli ordini chat.",
        [LID.BUSY_RIGHT_NOW]                      = "Modalità Occupata",
        [LID.GREETING_BUSY]                       = "Sono occupato ora, ma posso creare questo più tardi se me lo invii.",
        [LID.BUSY_HELP]                           =
        "|cFFFFFFFFQuando selezionato, aggiungi il saluto occupato nella tua risposta. Modifica il tuo saluto occupato con il pulsante qui sotto.\n\nQuesto è destinato all'uso con un secondo account che proxy gli ordini in modo da poter catturare ordini mentre sei in giro con il tuo principale.\n\nSaluto occupato attuale: |cFF00FF00%s|r|r",
        ["Custom Explanations"]                   = "Spiegazioni Personalizzate",
        ["Create"]                                = "Crea",
        ["Modify"]                                = "Modifica",
        ["Delete"]                                = "Elimina",
        [LID.EXPLANATION_LABEL_DESC]              =
        "Inserisci un'etichetta che vedrai quando fai clic con il tasto destro sul nome del cliente nella chat.",
        [LID.EXPLANATION_DUPLICATE_LABEL]         = "Questa etichetta è già in uso.",
        [LID.EXPLANATION_TEXT_DESC]               =
        "Inserisci un messaggio da inviare al cliente quando l'etichetta viene cliccata. Le nuove righe vengono inviate come messaggi separati. Le righe lunghe vengono suddivise per rientrare nella lunghezza massima del messaggio.",
        ["Create an Explanation"]                 = "Crea una Spiegazione",
        ["Save"]                                  = "Salva",
        ["Reset"]                                 = "Ripristina",
        [LID.MANUAL_MATCHING_TITLE]               = "Abbinamento Manuale",
        [LID.MANUAL_MATCH]                        = "%s - %s", -- artigiano, professione
        [LID.MANUAL_MATCHING_DESC]                =
        "Ignora parole chiave primarie e forza un abbinamento per questo messaggio. CraftScan tenterà di trovare l'artigiano corretto in base al messaggio, ma se non vengono trovati abbinamenti, il saluto predefinito per l'artigiano specificato verrà utilizzato. L'abbinamento viene segnalato tramite i mezzi usuali, permettendoti di fare clic sul banner o sulla riga della tabella per inviare il saluto.",

        [LID.RN_MANUAL_MATCH]                     = "Abbinamento Manuale",
        [LID.RN_MANUAL_MATCH + 1]                 =
        "Il menu di contesto quando fai clic con il tasto destro su un nome di giocatore nella chat ora include opzioni di CraftScan.",
        [LID.RN_MANUAL_MATCH + 2]                 =
        "Questo menu include tutti i tuoi artigiani e professioni. Facendo clic su uno di questi forzerai un'altra passata sul messaggio per cercare un abbinamento senza considerare le 'Parole Chiave Primarie' (ad es. LF, WTB, recraft, ecc...), nel caso in cui il cliente stia usando una terminologia non standard.",
        [LID.RN_MANUAL_MATCH + 3]                 =
        "Se il messaggio ancora non corrisponde, viene forzato un abbinamento con il saluto predefinito per l'artigiano e la professione che hai cliccato.",
        [LID.RN_MANUAL_MATCH + 4]                 =
        "Questo clic non messaggerà automaticamente il cliente. Genera l'abbinamento nel modo usuale, e poi puoi ispezionare la risposta generata e scegliere di inviarla o meno.",
        [LID.RN_MANUAL_MATCH + 5]                 = "(Spiacente, niente apprendimento automatico.)",
        [LID.RN_CUSTOM_EXPLANATIONS]              = "Spiegazioni Personalizzate",
        [LID.RN_CUSTOM_EXPLANATIONS + 1]          =
        "La pagina 'Ordini Chat' ora include un pulsante 'Spiegazioni Personalizzate'. Le spiegazioni configurate qui appaiono anche nel menu contestuale della chat, e facendoci clic invieranno immediatamente l spiegazione.",
        [LID.RN_CUSTOM_EXPLANATIONS + 2]          =
        "Le spiegazioni sono ordinate alfabeticamente, quindi puoi numerarle per forzare un ordine desiderato.",
        [LID.RN_BUSY_MODE]                        = "Modalità Occupata",
        [LID.RN_BUSY_MODE + 1]                    =
        "Questo è stato in vigore per alcune versioni, ma non è mai stato spiegato. C'è una nuova casella di controllo 'Modalità Occupata' nella pagina 'Ordini Chat'. Quando selezionata, aggiungi il saluto occupato nella tua risposta. Modifica il tuo saluto occupato con il pulsante 'Personalizza Saluto'.",
        [LID.RN_BUSY_MODE + 2]                    =
        "Questo è destinato all'uso con un secondo account che proxy gli ordini in modo da poter catturare ordini mentre sei in giro con il tuo principale, e il cliente saprà che non puoi crearlo immediatamente.",
        ["Release Notes"]                         = "Note di Rilascio",
        ["Secondary Keywords"]                    = "Parole chiave secondarie",
        [LID.SECONDARY_KEYWORD_INSTRUCTIONS]      =
        "Ad esempio: 'pvp, 610, algari' o '606, 610, 636' o '590', per differenziare la stessa parola chiave su più oggetti.",
        [LID.HELP_ITEM_SECONDARY_KEYWORDS]        =
        "Dopo aver trovato una corrispondenza con una parola chiave sopra, controlla le parole chiave secondarie per perfezionare la corrispondenza, consentendo di distinguere le diverse professioni per lo stesso slot di oggetto.",
        [LID.RN_SECONDARY_KEYWORDS]               = "Parole chiave secondarie",
        [LID.RN_SECONDARY_KEYWORDS + 1]           =
        "Gli oggetti ora supportano parole chiave secondarie per perfezionare una corrispondenza. Ogni slot di oggetto di solito ha una versione Scintilla, PVP e Blu. Le parole chiave secondarie possono essere impostate per differenziarle.",
        [LID.RN_SECONDARY_KEYWORDS + 2]           = "Esempio di parole chiave secondarie:",
        [LID.RN_SECONDARY_KEYWORDS + 3]           = "606, 619, 636",
        [LID.RN_SECONDARY_KEYWORDS + 4]           = "610, pvp, algari",
        [LID.RN_SECONDARY_KEYWORDS + 5]           = "590",
        ["Find Crafter"]                          = "Trova Artigiano",
        ["No Crafters Found"]                     = "Nessun artigiano trovato",
        [LID.FOUND_CRAFTER_NAME_ENTRY]            = "%s [%s]",
        [LID.GREET_FOUND_CRAFTER]                 = "|cffffd100Clic sinistro: Richiedi la creazione|r",
        ["Crafter Greeting"]                      = "|cFFFFFFFFSaluto dell'artigiano|r",
        [LID.BUSY_ICON]                           =
        "|cFFFFFFFFL'artigiano ha indicato che è attualmente occupato, ma può creare l'oggetto in seguito.\n\nControlla il suo saluto per ulteriori dettagli.|r",
        ["Potential Crafters"]                    = "Artigiani potenziali",
        [LID.FOUND_VIA_CRAFT_SCAN]                =
        "Ti ho trovato tramite CraftScan e ho visto il tuo saluto. Puoi creare %s per me adesso?",
        [LID.COMMISSION_INSTRUCTIONS]             =
        "es. '10000g', Predefinito: 'Qualsiasi'\nQuesto testo appare nella tabella 'Trova Artigiano' del cliente.",
        ["Commission"]                            = "Commissione",
        ["Crafter [Currently Playing]"]           = "Artigiano [Attualmente in gioco]",
        ["Profession commission"]                 = "Commissione della professione",
        [LID.DEFAULT_COMMISSION]                  = "Qualsiasi",
        [LID.HELP_ITEM_COMMISSION]                =
        "CraftScan fornisce ai clienti un pulsante 'Trova Artigiano' negli ordini personali. Il tuo nome, saluto e questa commissione appariranno nella tabella insieme ad altri artigiani. La lunghezza è limitata a 12 caratteri per adattarsi alla tabella del cliente.",
        ["Discoverable"]                          = "Visibile ai clienti",
        [LID.DISCOVERABLE_SETTING]                =
        "Se abilitato, quando un cliente clicca su 'Trova Artigiano', il tuo nome apparirà nella tabella generata se puoi creare l'oggetto.",
        [LID.RN_CUSTOMER_SEARCH]                  = "Trova Artigiano",
        [LID.RN_CUSTOMER_SEARCH + 1]              =
        "La pagina per inviare un Ordine Personale ora ha un pulsante 'Trova Artigiano'. Questo pulsante invia una richiesta a tutti gli utenti di CraftScan per vedere chi può creare l'oggetto e presenta i risultati in una tabella con la commissione configurata dell'artigiano.",
        [LID.RN_CUSTOMER_SEARCH + 2]              =
        "Ogni professione e oggetto ha ora una casella 'Commissione' per configurare ciò che apparirà in questa tabella, e il testo è limitato a 12 caratteri per adattarsi alla tabella.",
        [LID.RN_CUSTOMER_SEARCH + 3]              =
        "Sei entrato nel canale 'CraftScan', ma non devi attivarlo o vedere i messaggi nel canale. Serve per consentire a CraftScan di inviare richieste private come solitamente avviene nel canale Commercio.",
        [LID.RN_CUSTOMER_SEARCH + 4]              =
        "Come artigiano, potresti ora ricevere sussurri non richiesti da clienti che già sanno cosa puoi creare.",
        [LID.RN_CUSTOMER_SEARCH + 5]              =
        "Questo è un po' difficile da testare poiché gli account di prova non hanno accesso alla tabella delle creazioni. Se riscontri problemi, puoi disattivare la funzione fino a quando non potrò risolverla.",
        [LID.RN_CUSTOMER_SEARCH + 6]              =
        "Puoi scegliere di non essere incluso in questa tabella tramite la nuova impostazione 'Visibile' nel menu delle Impostazioni principali di Blizzard.",
        [LID.RN_CUSTOMER_SEARCH + 7]              =
        "Poiché i clienti potrebbero iniziare a utilizzare l'addon, la funzione Analytics può essere completamente disabilitata e ora è disabilitata per impostazione predefinita. Se hai già raccolto dati, rimarrà abilitata.",
        ["Permissive keyword matching"]           = "Corrispondenza permissiva delle parole chiave",
        [LID.PERMISSIVE_MATCH_SETTING]            =
        "Quando selezionato, CraftScan smetterà di preoccuparsi degli spazi e di altri delimitatori durante la ricerca di corrispondenze di parole chiave. Per impostazione predefinita, CraftScan corrisponderà a una parola chiave solo se è chiaramente delimitata dal testo circostante per evitare di corrispondere erroneamente a parole chiave brevi inserite in altre parole. Per le lingue che non utilizzano spazi per delimitare le parole chiave, abilita questa opzione.",
        ["Show chat orders tab"]                  = "Mostra scheda ordini chat",
        [LID.SHOW_CHAT_ORDER_TAB]                 =
        "Mostra o nasconde la scheda 'Ordini Chat' nella finestra delle professioni. Se nascosta, puoi aprire la pagina ordini chat cliccando sul pulsante CraftScan dove appaiono gli avvisi.",
        [LID.IGNORE]                              = "Ignora",
        [LID.IGNORE_TOOLTIP]                      =
        "Aggiungi questo giocatore alla lista di ignorati di CraftScan. CraftScan ignorerà tutti i messaggi inviati da questo giocatore. Questo menu può essere utilizzato per rimuovere il giocatore dalla lista.",
        [LID.UNIGNORE]                            = "Rimuovi Ignora",
        [LID.UNIGNORE_TOOLTIP]                    =
        "Questo giocatore è nella tua lista di ignorati di CraftScan. Questa opzione lo rimuoverà dalla lista.",
        ["Collapse chat context menu"]            = "Comprimi menu contestuale della chat",
        [LID.COLLAPSE_CHAT_CONTEXT_TOOLTIP]       =
        "Facendo clic destro su un nome giocatore nella chat, comprime tutte le voci del menu contestuale in un unico sottomenu CraftScan.",

        [LID.PROXY_ORDERS_TOOLTIP]                =
        "Invia gli ordini rilevati da questo account agli account collegati con permessi di 'Controllo Completo'. L'account ricevente mostrerà la notifica come se avesse rilevato l'ordine.",
        [LID.RECEIVE_PROXY_ORDERS_TOOLTIP]        =
        "Ricevi ordini rilevati e inoltrati da un account collegato con 'Controllo Completo'. Quando un ordine viene ricevuto dall'account collegato, comparirà la notifica abituale su questo account.",
        [LID.LOCAL_ALERTS_TOOLTIP]                =
        "Le notifiche visive e sonore per questo artigiano e questa professione verranno mostrate solo quando stai giocando con questo personaggio. Questo è solo un filtro e non attiva né disattiva le notifiche in generale. Le notifiche vengono comunque gestite tramite le icone della missione e delle cuffie sul lato destro della lista degli artigiani.",
["Local Notifications Only"] = "Solo notifiche locali",

    }
end
