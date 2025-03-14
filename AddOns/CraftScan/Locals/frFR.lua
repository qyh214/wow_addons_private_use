local CraftScan = select(2, ...)

CraftScan.LOCAL_FR = {}

function CraftScan.LOCAL_FR:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        ["CraftScan"]                             = "CraftScan",
        [LID.CRAFT_SCAN]                          = "CraftScan",
        [LID.CHAT_ORDERS]                         = "Commandes de discussion",
        [LID.DISABLE_ADDONS]                      = "Désactiver les addons",
        [LID.RENABLE_ADDONS]                      = "Réactiver les addons",
        [LID.DISABLE_ADDONS_TOOLTIP]              =
        "Enregistrez votre liste d'addons, puis désactivez-les, permettant un changement rapide vers un personnage alternatif. Ce bouton peut être cliqué à nouveau pour réactiver les addons à tout moment.",
        [LID.GREETING_I_CAN_CRAFT_ITEM]           = "Je peux fabriquer {item}.",                    -- ItemLink
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]         = "Mon alter, {crafter}, peut fabriquer {item}.", -- Nom du fabriquant, ItemLink
        [LID.GREETING_LINK_BACKUP]                = "ça",
        [LID.GREETING_I_HAVE_PROF]                = "J'ai {profession}.",                           -- Nom du métier
        [LID.GREETING_ALT_HAS_PROF]               = "Mon alter, {crafter}, a {profession}.",        -- Nom du fabriquant, Nom du métier
        [LID.GREETING_ALT_SUFFIX]                 = "Faites-le moi savoir si vous envoyez une commande pour que je puisse me connecter.",
        [LID.MAIN_BUTTON_BINDING_NAME]            = "Basculer la page de commande",
        [LID.GREET_BUTTON_BINDING_NAME]           = "Saluer le client de la bannière",
        [LID.DISMISS_BUTTON_BINDING_NAME]         = "Rejeter le client de la bannière",
        [LID.TOGGLE_CHAT_TOOLTIP]                 = "Basculer les commandes de discussion%s", -- Raccourci
        [LID.SCANNER_CONFIG_SHOW]                 = "Afficher CraftScan",
        [LID.SCANNER_CONFIG_HIDE]                 = "Masquer CraftScan",
        [LID.CRAFT_SCAN_OPTIONS]                  = "Options de CraftScan",
        [LID.ITEM_SCAN_CHECK]                     = "Analyser la discussion pour cet objet",
        [LID.HELP_PROFESSION_KEYWORDS]            =
        "Un message doit contenir l'un de ces termes. Pour faire correspondre un message tel que 'LF Lariat', 'lariet' doit être répertorié ici. Pour générer un lien d'objet pour le Lariat élémentaire dans la réponse, 'lariat' doit également être inclus dans les mots-clés de configuration de l'objet pour le Lariat élémentaire.",
        [LID.HELP_PROFESSION_EXCLUSIONS]          =
        "Un message sera ignoré s'il contient l'un de ces termes, même s'il serait autrement une correspondance. Pour éviter de répondre à 'LF JC Lariat' avec 'J'ai la joaillerie' lorsque vous n'avez pas la recette du Lariat, 'lariat' doit être répertorié ici.",
        [LID.HELP_SCAN_ALL]                       =
        "Activer la numérisation pour toutes les recettes de la même extension que la recette sélectionnée.",
        [LID.HELP_PRIMARY_EXPANSION]              =
        "Utilisez cette salutation lors de la réponse à une demande générique telle que 'LF Forgeron'. Lors du lancement d'une nouvelle extension, vous voudrez probablement une salutation décrivant les objets que vous pouvez fabriquer au lieu de déclarer que vous avez une connaissance maximale de l'extension précédente.",
        [LID.HELP_EXPANSION_GREETING]             =
        "Une introduction initiale est toujours générée indiquant que vous pouvez fabriquer l'objet. Ce texte est ajouté à celui-ci. Les sauts de ligne sont autorisés et seront envoyés en tant que réponse distincte. Si le texte est trop long, il sera découpé en plusieurs réponses.",
        [LID.HELP_CATEGORY_KEYWORDS]              =
        "Si un métier a été trouvé, vérifiez ces mots-clés spécifiques à la catégorie pour affiner la salutation. Par exemple, vous pouvez mettre 'toxique' ou 'visqueux' ici pour tenter de détecter les patrons de travail du cuir nécessitant l'Autel de la décomposition.",
        [LID.HELP_CATEGORY_GREETING]              =
        "Lorsque cette catégorie est détectée dans un message, via un mot-clé ou un lien d'objet, cette salutation supplémentaire sera ajoutée après la salutation du métier.",
        [LID.HELP_CATEGORY_OVERRIDE]              = "Omettez la salutation du métier et commencez par la salutation de la catégorie.",
        [LID.HELP_ITEM_KEYWORDS]                  =
        "Si un métier a été trouvé, vérifiez ces mots-clés spécifiques à l'objet pour affiner la salutation. Lorsqu'une correspondance est trouvée, la réponse inclura le lien d'objet au lieu de la salutation générique du métier. Si 'lariat' est un mot-clé de métier, mais pas un mot-clé d'objet, la réponse indiquera 'J'ai la joaillerie.' Si 'lariat' est uniquement un mot-clé d'objet, 'LF Lariat' ne correspondra pas à un métier et ne sera pas considéré comme une correspondance. Si 'lariat' est à la fois un mot-clé de métier et d'objet, la réponse à 'LF Lariat' sera 'Je peux fabriquer [Lariat élémentaire].'",
        [LID.HELP_ITEM_GREETING]                  =
        "Lorsque cet objet est détecté dans un message, via un mot-clé ou un lien d'objet, cette salutation supplémentaire sera ajoutée après la salutation du métier et de la catégorie.",
        [LID.HELP_ITEM_OVERRIDE]                  =
        "Omettez la salutation du métier et de la catégorie et commencez par la salutation de l'objet.",
        [LID.HELP_GLOBAL_KEYWORDS]                = "Un message doit inclure l'un de ces termes.",
        [LID.HELP_GLOBAL_EXCLUSIONS]              = "Un message sera ignoré s'il contient l'un de ces termes.",
        [LID.SCAN_ALL_RECIPES]                    = 'Scanner toutes les recettes',
        [LID.SCANNING_ENABLED]                    = "La numérisation est activée car '%s' est cochée.", -- SCAN_ALL_RECIPES or ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]                   = "La numérisation est désactivée.",
        [LID.PRIMARY_KEYWORDS]                    = "Mots-clés primaires",
        [LID.HELP_PRIMARY_KEYWORDS]               =
        "Tous les messages sont filtrés par ces termes, qui sont communs à tous les métiers. Un message correspondant est ensuite traité pour rechercher du contenu lié au métier.",
        [LID.HELP_CATEGORY_SECTION]               =
        "La catégorie est la section pliable contenant la recette dans la liste à gauche. 'Favoris' n'est pas une catégorie. Cela est principalement destiné aux recettes de travail du cuir toxiques qui sont plus difficiles à fabriquer. Cela pourrait également être utile au début des extensions lorsque vous ne pouvez vous spécialiser que dans une seule catégorie.",
        [LID.HELP_EXPANSION_SECTION]              =
        "Les arbres de connaissances diffèrent par extension, donc la salutation peut également différer.",
        [LID.HELP_PROFESSION_SECTION]             =
        "Du point de vue du client, il n'y a pas de différence entre les extensions. Ces termes se combinent avec la sélection de 'l'expansion primaire' pour fournir une salutation générique (par exemple 'J'ai <métier>.') lorsque nous ne pouvons pas faire correspondre quelque chose de plus spécifique.",
        [LID.RECIPE_NOT_LEARNED]                  = "Vous n'avez pas appris cette recette. La numérisation est désactivée.",
        [LID.PING_SOUND_LABEL]                    = "Son d'alerte",
        [LID.PING_SOUND_TOOLTIP]                  = "Le son qui se joue lorsqu'un client est détecté.",
        [LID.BANNER_SIDE_LABEL]                   = "Direction de la bannière",
        [LID.BANNER_SIDE_TOOLTIP]                 = "La bannière se développera depuis le bouton dans cette direction.",
        Left                                      = "Gauche",
        Right                                     = "Droite",
        Minute                                    = "Minute",
        Minutes                                   = "Minutes",
        Second                                    = "Seconde",
        Seconds                                   = "Secondes",
        Millisecond                               = "Milliseconde",
        Milliseconds                              = "Millisecondes",
        Version                                   = "Nouveau dans",
        ["CraftScan Release Notes"]               = "Notes de version de CraftScan",
        [LID.CUSTOMER_TIMEOUT_LABEL]              = "Délai d'attente client",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]            = "Renvoie automatiquement les clients après ce nombre de minutes.",
        [LID.BANNER_TIMEOUT_LABEL]                = "Délai d'attente de la bannière",
        [LID.BANNER_TIMEOUT_TOOLTIP]              =
        "La bannière de notification client restera affichée pendant cette durée après qu'une correspondance ait été détectée.",
        ["All crafters"]                          = "Tous les fabricants",
        ["Crafter Name"]                          = "Nom du fabricant",
        ["Profession"]                            = "Métier",
        ["Customer Name"]                         = "Nom du client",
        ["Replies"]                               = "Réponses",
        ["Keywords"]                              = "Mots-clés",
        ["Profession greeting"]                   = "Salutation du métier",
        ["Category greeting"]                     = "Salutation de la catégorie",
        ["Item greeting"]                         = "Salutation de l'objet",
        ["Primary expansion"]                     = "Expansion primaire",
        ["Override greeting"]                     = "Remplacement de la salutation",
        ["Excluded keywords"]                     = "Mots-clés exclus",
        [LID.EXCLUSION_INSTRUCTIONS]              =
        "Ne faites pas correspondre les messages contenant ces jetons séparés par des virgules.",
        [LID.KEYWORD_INSTRUCTIONS]                =
        "Faites correspondre les messages contenant l'un de ces mots-clés séparés par des virgules.",
        [LID.GREETING_INSTRUCTIONS]               = "Une salutation à envoyer aux clients recherchant une fabrication.",
        [LID.GLOBAL_INCLUSION_DEFAULT]            = "LF, LFC, WTB, recraft",
        [LID.GLOBAL_EXCLUSION_DEFAULT]            = "LFW, WTS, LF work",
        [LID.DEFAULT_KEYWORDS_BLACKSMITHING]      = "BS, Forgeron, Armurier, Forgeron d'armes",
        [LID.DEFAULT_KEYWORDS_LEATHERWORKING]     = "TC, Travail du cuir, Travailleur du cuir",
        [LID.DEFAULT_KEYWORDS_ALCHEMY]            = "Alch, Alchimiste, Pierre",
        [LID.DEFAULT_KEYWORDS_TAILORING]          = "Tailleur",
        [LID.DEFAULT_KEYWORDS_ENGINEERING]        = "Ingénieur, Ing",
        [LID.DEFAULT_KEYWORDS_ENCHANTING]         = "Enchanteur, Blason",
        [LID.DEFAULT_KEYWORDS_JEWELCRAFTING]      = "JJ, Joaillier",
        [LID.DEFAULT_KEYWORDS_INSCRIPTION]        = "Calligraphie, Calligraphe, Scribe",

        -- Notes de version
        [LID.RN_WELCOME]                          = "Bienvenue dans CraftScan!",
        [LID.RN_WELCOME + 1]                      =
        "Cet addon analyse la discussion à la recherche de messages ressemblant à des demandes de fabrication. Si la configuration indique que vous pouvez fabriquer l'objet demandé, une notification sera déclenchée et les informations du client seront stockées pour faciliter la communication.",

        [LID.RN_INITIAL_SETUP]                    = "Configuration initiale",
        [LID.RN_INITIAL_SETUP + 1]                =
        "Pour commencer, ouvrez un métier et cliquez sur le nouveau bouton 'Afficher CraftScan' en bas.",
        [LID.RN_INITIAL_SETUP + 2]                =
        "Faites défiler jusqu'au bas de cette nouvelle fenêtre et remontez. Les choses que vous avez rarement besoin de changer sont en bas, mais ce sont les réglages auxquels il faut d'abord faire attention.",
        [LID.RN_INITIAL_SETUP + 3]                =
        "Cliquez sur l'icône d'aide dans le coin supérieur gauche de la fenêtre si vous avez besoin d'explications sur une entrée quelconque.",

        [LID.RN_INITIAL_TESTING]                  = "Tests initiaux",
        [LID.RN_INITIAL_TESTING + 1]              =
        "Une fois configuré, saisissez un message dans le chat /dire, tel que 'LF BS' pour la forge, en supposant que les mots-clés 'LF' et 'BS' sont activés. Une notification devrait apparaître.",
        [LID.RN_INITIAL_TESTING + 2]              =
        "Cliquez sur la notification pour envoyer immédiatement une réponse, cliquez avec le bouton droit pour rejeter le client, ou cliquez sur le bouton de métier circulaire lui-même pour ouvrir la fenêtre des commandes.",
        [LID.RN_INITIAL_TESTING + 3]              =
        "Les notifications en double sont supprimées sauf si elles ont déjà été rejetées, alors cliquez avec le bouton droit sur votre notification de test pour la rejeter si vous souhaitez réessayer.",

        [LID.RN_MANAGING_CRAFTERS]                = "Gestion de vos fabricants",
        [LID.RN_MANAGING_CRAFTERS + 1]            =
        "La liste de gauche de la fenêtre des commandes répertorie vos fabricants. Cette liste se remplira au fur et à mesure que vous vous connecterez à vos différents personnages et configurerez leurs métiers. Vous pouvez sélectionner quels personnages doivent être scannés en permanence, ainsi que si les notifications visuelles et auditives sont activées pour chacun de vos fabricants.",

        [LID.RN_MANAGING_CUSTOMERS]               = "Gestion des clients",
        [LID.RN_MANAGING_CUSTOMERS + 1]           =
        "La partie droite de la fenêtre des commandes se remplira avec les commandes de fabrication détectées dans la discussion. Cliquez sur une ligne pour envoyer la salutation si vous ne l'avez pas déjà fait à partir de la bannière contextuelle. Cliquez à nouveau pour ouvrir un chuchotement au client. Cliquez avec le bouton droit pour rejeter la ligne.",
        [LID.RN_MANAGING_CUSTOMERS + 2]           =
        "Les lignes de ce tableau persisteront sur tous les personnages, vous pouvez donc passer à un alter et cliquer à nouveau sur le client pour restaurer la communication. Les lignes expirent après 10 minutes par défaut. Cette durée peut être configurée dans la page de paramètres principale (Échap -> Options -> AddOns -> CraftScan).",
        [LID.RN_MANAGING_CUSTOMERS + 3]           =
        "Espérons que la plupart du tableau est explicite. La colonne 'Réponses' dispose de 3 icônes. La coche ou la croix de gauche indique si vous avez envoyé un message au client. La coche ou la croix de droite indique si le client a répondu. La bulle de discussion est un bouton qui ouvrira une fenêtre de chuchotement temporaire avec le client et la remplira avec votre historique de discussion.",

        [LID.RN_KEYBINDS]                         = "Raccourcis clavier",
        [LID.RN_KEYBINDS + 1]                     =
        "Des raccourcis clavier sont disponibles pour ouvrir la page des commandes, répondre au dernier client et rejeter le dernier client. Recherchez 'CraftScan' pour trouver tous les paramètres disponibles.",

        [LID.RN_CLEANUP]                          = "Nettoyage de la Configuration",
        [LID.RN_CLEANUP + 1]                      =
        "Vos artisans sur le côté gauche de la page 'Ordres de Chat' ont maintenant un menu contextuel lorsque vous faites un clic droit. Utilisez ce menu pour garder la liste propre et supprimer les personnages/métiers obsolètes.",
        ["Disable"]                               = "Désactiver",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]          =
        "Supprimez définitivement toutes les données %s enregistrées pour %s.\n\nUn bouton 'Activer CraftScan' sera présent sur la page du métier pour l'activer à nouveau avec les paramètres par défaut.\n\nUtilisez ceci si vous souhaitez continuer à utiliser le métier, mais sans l'interaction de CraftScan (par exemple, lorsque vous avez l'Alchimie sur tous les rerolls pour les flacons longs).", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]               = "Tapez 'DELETE' pour continuer :",
        [LID.SCANNER_CONFIG_DISABLED]             = "Activer CraftScan",

        ["Cleanup"]                               = "Nettoyer",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]         =
        "Supprimez définitivement toutes les données %s enregistrées pour %s.\n\nLe métier sera laissé dans un état comme s'il n'avait jamais été configuré. Il suffit d'ouvrir à nouveau le métier pour restaurer une configuration par défaut.\n\nUtilisez ceci si vous souhaitez réinitialiser complètement un métier, avez supprimé le personnage ou avez abandonné un métier.", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]              = "Tapez 'CLEANUP' pour continuer :",
        ["Primary Crafter"]                       = "Artisan Principal",
        [LID.PRIMARY_CRAFTER_TOOLTIP]             =
        "Marquez %s comme votre artisan principal pour %s. Cet artisan sera priorisé sur les autres s'il y a plusieurs correspondances avec la même demande.",
        ["Chat History"]                          = "Historique de chat avec %s", -- customer, left-click-help
        ["Greet Help"]                            = "|cffffd100Clic gauche : Saluer le client%s|r",
        ["Chat Help"]                             = "|cffffd100Clic gauche : Ouvrir un chuchotement|r",
        ["Chat Override"]                         = "|cffffd100Clic du milieu : Ouvrir un chuchotement%s|r",
        ["Dismiss"]                               = "|cffffd100Clic droit : Ignorer%s|r",
        ["Proposed Greeting"]                     = "Salutation proposée :",
        [LID.CHAT_BUTTON_BINDING_NAME]            = "Client Bannière Chuchotement",
        ["Customer Request"]                      = "Demande de %s",

        [LID.ADDON_WHITELIST_LABEL]               = "Liste blanche d'addons",
        [LID.ADDON_WHITELIST_TOOLTIP]             =
        "Lorsque vous appuyez sur le bouton pour désactiver temporairement tous les addons, gardez les addons sélectionnés ici activés. CraftScan restera toujours activé. Gardez uniquement ce dont vous avez besoin pour fabriquer efficacement.",
        [LID.MULTI_SELECT_BUTTON_TEXT]            = "%d sélectionnés", -- Count

        [LID.ACCOUNT_LINK_DESC]                   =
        "Partagez les artisans entre plusieurs comptes.\n\nLors de la connexion ou après un changement de configuration, CraftScan propagera les dernières informations entre les artisans configurés sur les deux comptes pour s'assurer que les deux côtés d'un compte lié soient toujours synchronisés.",
        [LID.ACCOUNT_LINK_PROMPT_CHARACTER]       = "Entrez le nom d'un personnage en ligne sur votre autre compte :",
        [LID.ACCOUNT_LINK_PROMPT_NICKNAME]        = "Entrez un surnom pour l'autre compte :",
        ["Link Account"]                          = "Lier le compte",
        ["Linked Accounts"]                       = "Comptes liés",
        ["Accept Linked Account"]                 = "Accepter le compte lié",
        ["Delete Linked Account"]                 = "Supprimer le compte lié",
        ["OK"]                                    = "OK",
        [LID.VERSION_MISMATCH]                    =
        "|cFFFF0000Erreur : incompatibilité de version de CraftScan. Version de l'autre compte : %s. Votre version : %s.|r",

        [LID.REMOTE_CRAFTER_TOOLTIP]              =
        "Ce personnage appartient à un compte lié. Il ne peut être désactivé que sur le compte auquel il appartient. Vous pouvez complètement supprimer ce personnage via 'Nettoyage', mais vous devrez le faire manuellement sur tous les comptes liés, sinon il sera restauré par un compte lié lors de la connexion.",
        [LID.REMOTE_CRAFTER_SUMMARY]              = "Synchronisé avec %s.",
        ["proxy_send_enabled"]                    = "Ordres Proxy",
        ["proxy_send_enabled_tooltip"]            = "Lorsqu'une commande client est détectée, envoyez-la aux comptes liés.",
        ["proxy_receive_enabled"]                 = "Recevoir les ordres proxy",
        ["proxy_receive_enabled_tooltip"]         =
        "Lorsqu'un autre compte détecte et envoie une commande client, ce compte la recevra. Le bouton CraftScan s'affichera pour montrer la bannière d'alerte si nécessaire.",
        [LID.LINK_ACTIVE]                         = "|cFF00FF00%s (vu pour la dernière fois %s)|r", -- Crafter, Time
        [LID.ACCOUNT_LINK_DELETE_INFO]            =
        "Supprimez la liaison avec '%s' et supprimez tous les personnages importés. Ce compte cessera toute communication avec l'autre côté. L'autre côté continuera à essayer d'établir des connexions jusqu'à ce que la liaison soit manuellement supprimée également.\n\nArtisans importés qui seront supprimés :\n%s",
        [LID.ACCOUNT_LINK_ADD_CHAR]               =
        "Par défaut, le personnage que vous avez initialement lié, ainsi que tous les artisans et personnages qui se sont connectés alors que ce compte était en ligne, sont connus de CraftScan. Ajoutez des personnages supplémentaires appartenant à l'autre compte afin qu'il puisse également être utilisé. '/reload' pour forcer la synchronisation avec le nouveau personnage s'il est en ligne.",
        ["Backup characters"]                     = "Personnages supplémentaires",
        ["Unlink account"]                        = "Dissocier le compte",
        ["Add"]                                   = "Ajouter",
        ["Remove"]                                = "Supprimer",
        ["Rename account"]                        = "Renommer le compte",
        ["New name"]                              = "Nouveau nom :",

        [LID.RN_LINKED_ACCOUNTS]                  = "Comptes liés",
        [LID.RN_LINKED_ACCOUNTS + 1]              =
        "Liez plusieurs comptes WoW ensemble pour partager les informations de fabrication et scanner depuis n'importe quel compte.",
        [LID.RN_LINKED_ACCOUNTS + 2]              =
        "Optionnellement, envoyez des commandes clients par proxy d'un compte aux autres afin que vous puissiez stationner un compte d'essai en ville pendant que votre personnage principal est en déplacement.",
        [LID.RN_LINKED_ACCOUNTS + 3]              =
        "Pour commencer, cliquez sur le bouton 'Lier le compte' en bas à gauche de la fenêtre CraftScan et suivez les instructions.",
        [LID.RN_LINKED_ACCOUNTS + 4]              = "Démo : https://www.youtube.com/watch?v=x1JLEph6t_c",

        ["Open Settings"]                         = "Ouvrir les paramètres",
        ["Customize Greeting"]                    = "Personnaliser le message",
        [LID.CUSTOM_GREETING_INFO]                =
        "CraftScan utilise ces phrases pour créer le message initial envoyé aux clients en fonction de la situation. Remplacez certaines ou toutes ci-dessous pour créer votre propre message.",
        ["Default"]                               = "Par défaut",
        [LID.MISSING_PLACEHOLDERS]                = "Les espaces réservés suivants sont également pris en charge : %s.",
        [LID.EXTRA_PLACEHOLDERS]                  = "Erreur : %s ne sont pas des espaces réservés valides.",
        [LID.LEGACY_PLACEHOLDERS]                 =
        "Attention : l'utilisation de %s est désormais obsolète. Veuillez utiliser des espaces réservés nommés, comme ceci : {placeholder}",

        ["Pixels"]                                = "Pixels",
        ["Show button height"]                    = "Afficher la hauteur du bouton",
        ["Alert icon scale"]                      = "Échelle de l'icône d'alerte",
        ["Total"]                                 = "Total",
        ["Repeat"]                                = "Répéter",
        ["Avg Per Day"]                           = "Moy/Jour",
        ["Peak Per Hour"]                         = "Pico/Heure",
        ["Median Per Customer"]                   = "Mdn/Client",
        ["Median Per Customer Filtered"]          = "Mdn/Client Répété",
        ["No analytics data"]                     = "Aucune donnée analytique",
        ["Reset Analytics"]                       = "Réinitialiser l'analyse",
        ["Analytics Options"]                     = "Options d'analyse",

        ["1 minute"]                              = "1 minute",
        ["15 minutes "]                           = "15 minutes ",
        ["1 hour"]                                = "1 heure",
        ["1 day"]                                 = "1 jour",
        ["1 week "]                               = "1 semaine ",
        ["30 days"]                               = "30 jours",
        ["180 days"]                              = "180 jours",
        ["1 year"]                                = "1 an",
        ["Clear recent data"]                     = "Effacer les données récentes",
        ["Newer than"]                            = "Plus récent que",
        ["Clear old data"]                        = "Effacer les anciennes données",
        ["Older than"]                            = "Plus ancien que",
        ["1 Minute Bins"]                         = "Intervalles de 1 minute",
        ["5 Minute Bins"]                         = "Intervalles de 5 minutes",
        ["10 Minute Bins"]                        = "Intervalles de 10 minutes",
        ["30 Minute Bins"]                        = "Intervalles de 30 minutes",
        ["1 Hour Bins"]                           = "Intervalles de 1 heure",
        ["6 Hour Bins"]                           = "Intervalles de 6 heures",
        ["12 Hour Bins"]                          = "Intervalles de 12 heures",
        ["24 Hour Bins"]                          = "Intervalles de 24 heures",
        ["1 Week Bins"]                           = "Intervalles de 1 semaine",

        [LID.ANALYTICS_ITEM_TOOLTIP]              =
        "Les objets sont appariés en s'assurant qu'un message correspond aux mots-clés d'inclusion et d'exclusion globaux, puis en recherchant l'icône de qualité dans un lien d'objet. Il n'existe pas de liste globale d'objets fabriqués ni de moyen de déterminer si un itemID est fabriqué, donc c'est la meilleure chose que nous puissions faire.",
        [LID.ANALYTICS_PROFESSION_TOOLTIP]        =
        "Il n'y a pas de recherche inverse d'un objet à la profession qui le fabrique. Si l'un de vos personnages peut fabriquer l'objet, la profession est automatiquement assignée. Lorsque une profession est ouverte, tous les objets inconnus appartenant à cette profession sont assignés. Vous pouvez également assigner manuellement la profession.",
        [LID.ANALYTICS_TOTAL_TOOLTIP]             =
        "Le nombre total de fois que cet objet a été demandé. Les demandes en double du même client dans la même heure ne sont pas incluses.",
        [LID.ANALYTICS_REPEAT_TOOLTIP]            =
        "Le nombre total de fois que cet objet a été demandé par le même client plusieurs fois dans la même heure.\n\nSi cette valeur est proche du total, il est probable que l'offre de cet objet soit insuffisante.\n\nLes demandes en double dans les 15 secondes suivant la demande initiale sont ignorées.",
        [LID.ANALYTICS_AVERAGE_TOOLTIP]           = "Le nombre moyen de demandes totales pour cet objet par jour.",
        [LID.ANALYTICS_PEAK_TOOLTIP]              = "Le nombre de demandes maximum pour cet objet par heure.",
        [LID.ANALYTICS_MEDIAN_TOOLTIP]            =
        "Le nombre médian de fois que le même client a demandé le même objet dans la même heure.\n\nUne valeur de 1 indique qu'au moins la moitié de toutes les demandes sont satisfaites par quelqu'un et que la demande pour cet objet est probablement satisfaite.\n\nSi cette valeur est élevée, c'est probablement un bon objet à envisager de fabriquer.",
        [LID.ANALYTICS_MEDIAN_TOOLTIP_FILTERED]   =
        "Le nombre médian de fois que le même client a demandé le même objet dans la même heure, filtré pour ne conserver que les demandes où le demandeur a demandé plusieurs fois.\n\nSi cette valeur n'est pas 1 mais que la médiane non filtrée est 1, cela indique qu'il y a des moments où la demande n'est pas satisfaite.",
        ["Request Count"]                         = "Nombre de demandes",
        [LID.ACCOUNT_LINK_ACCEPT_DST_INFO]        =
        "'%s' a envoyé une demande pour lier des comptes.\n\nLes permissions suivantes ont été demandées :\n\n%s\n\nN'acceptez pas les permissions complètes à moins que vous ayez envoyé la demande.\n\nEntrez un surnom pour l'autre compte :",
        [LID.LINKED_ACCOUNT_REJECTED]             = "CraftScan : La demande de compte lié a échoué. Raison : %s",
        [LID.LINKED_ACCOUNT_USER_REJECTED]        = "Le compte cible a rejeté la demande.",

        [LID.LINKED_ACCOUNT_PERMISSION_FULL]      = "Contrôle Complet",
        [LID.LINKED_ACCOUNT_PERMISSION_ANALYTICS] = "Synchronisation Analytique",
        [LID.ACCOUNT_LINK_PERMISSIONS_DESC]       = "Demandez les permissions suivantes avec le compte lié.",
        [LID.ACCOUNT_LINK_FULL_CONTROL_DESC]      =
        "Synchronise toutes les données de personnage et prend en charge toutes les autres permissions également.",
        [LID.ACCOUNT_LINK_ANALYTICS_DESC]         =
        "Synchronisez uniquement les données analytiques entre les deux comptes manuellement via le menu du compte. N'importe quel compte peut déclencher une synchronisation bidirectionnelle à tout moment. Cela ne se fait jamais automatiquement. Comme aucun personnage n'est importé, vous ne synchroniserez qu'avec le personnage spécifié ici. Vous pouvez ajouter manuellement d'autres alts du compte lié depuis le menu du compte.",
        ["Sync Analytics"]                        = "Synchroniser les Analyses",
        ["Sync Recent Analytics"]                 = "Synchroniser les Analyses Récentes",
        [LID.ANALYTICS_PROF_MISMATCH]             =
        "|cFFFF0000CraftScan : Avertissement : Désaccord de profession d'analyse. Objet : %s. Profession locale : %s. Profession liée : %s.|r",
        [LID.RN_ANALYTICS]                        = "Analytique",
        [LID.RN_ANALYTICS + 1]                    =
        "CraftScan analyse désormais le chat à la recherche de tout objet fabriqué combiné avec vos mots-clés globaux (par exemple, LF, recraft, etc.), même si vous ne pouvez pas fabriquer l'objet. Le temps est enregistré et les objets détectés sont affichés sous les commandes habituelles trouvées dans le chat.",
        [LID.RN_ANALYTICS + 2]                    =
        "Le concept de 'répétitions' est utilisé pour déterminer si un objet manque d'approvisionnement. CraftScan se souvient de qui a demandé quoi pendant la dernière heure, et s'ils reviennent pour demander la même chose, cela est enregistré comme une répétition. Les en-têtes de colonne de la nouvelle grille ont des tooltips qui expliquent leur intention.",
        [LID.RN_ANALYTICS + 3]                    =
        "Avec un personnage stationné dans le chat commercial suffisamment longtemps, cela devrait construire une bonne vision de quelles branches de l'arbre de profession valent la peine d'investir.",
        [LID.RN_ANALYTICS + 4]                    =
        "Les analyses peuvent être synchronisées entre plusieurs comptes. Vous pouvez stationner un compte d'essai dans le commerce toute la journée pour collecter des données et ensuite les synchroniser avec votre compte principal. Vous pouvez également créer un lien de compte uniquement pour les analyses avec un ami, soutenant une synchronisation bidirectionnelle qui fusionne vos analyses. Une fois la collection suffisamment grande, il y a une option pour synchroniser uniquement les données depuis la dernière fois que les comptes ont été synchronisés.",
        [LID.RN_ALERT_ICON_ANCHOR]                = "Mises à jour de l'ancrage de l'icône d'alerte",
        [LID.RN_ALERT_ICON_ANCHOR + 1]            =
        "L'icône d'alerte sera désormais masquée correctement lorsque l'interface utilisateur est masquée. Le changement a légèrement déplacé et redimensionné l'icône sur mon écran. Si le bouton a été déplacé hors de votre écran à cause de cela, il y a une option de réinitialisation si vous faites un clic droit sur le bouton 'Ouvrir les Paramètres' en haut à droite de la page de commandes de chat.",
        [LID.BUSY_RIGHT_NOW]                      = "Mode Occupé",
        [LID.GREETING_BUSY]                       = "Je suis occupé maintenant, mais je peux le fabriquer plus tard si vous l'envoyez.",
        [LID.BUSY_HELP]                           =
        "|cFFFFFFFFLorsque sélectionné, ajoute le salut occupé dans votre réponse. Modifiez votre salut occupé avec le bouton ci-dessous.\n\nCeci est destiné à être utilisé avec un second compte qui prend des commandes pour que vous puissiez capturer des commandes pendant que vous êtes dehors avec votre compte principal.\n\nSalut occupé actuel : |cFF00FF00%s|r|r",
        ["Custom Explanations"]                   = "Explications Personnalisées",
        ["Create"]                                = "Créer",
        ["Modify"]                                = "Modifier",
        ["Delete"]                                = "Supprimer",
        [LID.EXPLANATION_LABEL_DESC]              =
        "Entrez une étiquette que vous verrez lorsque vous ferez un clic droit sur le nom du client dans le chat.",
        [LID.EXPLANATION_DUPLICATE_LABEL]         = "Cette étiquette est déjà utilisée.",
        [LID.EXPLANATION_TEXT_DESC]               =
        "Entrez un message à envoyer au client lorsque l'étiquette est cliquée. Les nouvelles lignes sont envoyées comme des messages séparés. Les longues lignes sont divisées pour s'ajuster à la longueur maximale du message.",
        ["Create an Explanation"]                 = "Créer une Explication",
        ["Save"]                                  = "Sauvegarder",
        ["Reset"]                                 = "Réinitialiser",
        [LID.MANUAL_MATCHING_TITLE]               = "Appariement Manuel",
        [LID.MANUAL_MATCH]                        = "%s - %s", -- crafter, profession
        [LID.MANUAL_MATCHING_DESC]                =
        "Ignore les mots-clés primaires et force un appariement pour ce message. CraftScan tentera de trouver le fabricant correct basé sur le message, mais si aucune correspondance n'est trouvée, le salut par défaut pour le fabricant spécifié sera utilisé. La correspondance est signalée par les moyens habituels, vous permettant de cliquer sur la bannière ou la ligne du tableau pour envoyer le salut.",

        [LID.RN_MANUAL_MATCH]                     = "Appariement Manuel",
        [LID.RN_MANUAL_MATCH + 1]                 =
        "Le menu contextuel à clic droit sur le nom d'un joueur dans le chat inclut maintenant les options CraftScan.",
        [LID.RN_MANUAL_MATCH + 2]                 =
        "Ce menu comprend tous vos fabricants et professions. Cliquer sur l'un d'eux forcera un nouveau passage sur le message pour rechercher une correspondance sans considérer les 'Mots Clés Primaires' (par exemple, LF, WTB, recraft, etc.), au cas où le client utiliserait une terminologie non standard.",
        [LID.RN_MANUAL_MATCH + 3]                 =
        "Si le message ne correspond toujours pas, un appariement sera forcé avec le salut par défaut pour le fabricant et la profession sur laquelle vous avez cliqué.",
        [LID.RN_MANUAL_MATCH + 4]                 =
        "Ce clic n'enverra pas automatiquement un message au client. Cela génère la correspondance de la manière habituelle et vous pouvez ensuite examiner la réponse générée et décider de l'envoyer ou non.",
        [LID.RN_MANUAL_MATCH + 5]                 = "(Désolé, pas d'apprentissage automatique.)",
        [LID.RN_CUSTOM_EXPLANATIONS]              = "Explications Personnalisées",
        [LID.RN_CUSTOM_EXPLANATIONS + 1]          =
        "La page 'Commandes de Chat' inclut maintenant un bouton 'Explications Personnalisées'. Les explications configurées ici apparaissent également dans le menu contextuel du chat, et cliquer dessus enverra immédiatement l'explication.",
        [LID.RN_CUSTOM_EXPLANATIONS + 2]          =
        "Les explications sont triées par ordre alphabétique, donc vous pouvez les numéroter pour forcer un ordre souhaité.",
        [LID.RN_BUSY_MODE]                        = "Mode Occupé",
        [LID.RN_BUSY_MODE + 1]                    =
        "Cela a été présent depuis plusieurs versions, mais n'a jamais été expliqué. Il y a une nouvelle case à cocher 'Mode Occupé' sur la page 'Commandes de Chat'. Lorsqu'elle est activée, elle ajoute le salut occupé dans votre réponse. Modifiez votre salut occupé avec le bouton 'Personnaliser le Salut'.",
        [LID.RN_BUSY_MODE + 2]                    =
        "Cela est destiné à être utilisé avec un second compte qui prend des commandes pour que vous puissiez recevoir des commandes pendant que vous êtes en déplacement avec votre compte principal, et le client saura que vous ne pouvez pas le fabriquer immédiatement.",
        ["Release Notes"]                         = "Notes de Version",
        ["Secondary Keywords"]                    = "Mots-clés secondaires",
        [LID.SECONDARY_KEYWORD_INSTRUCTIONS]      =
        "Par exemple : 'pvp, 610, algari' ou '606, 610, 636' ou '590', pour différencier le même mot-clé sur plusieurs objets.",
        [LID.HELP_ITEM_SECONDARY_KEYWORDS]        =
        "Après avoir trouvé une correspondance avec un mot-clé ci-dessus, recherchez des mots-clés secondaires pour affiner la correspondance, permettant de différencier les divers métiers pour le même emplacement d'objet.",
        [LID.RN_SECONDARY_KEYWORDS]               = "Mots-clés secondaires",
        [LID.RN_SECONDARY_KEYWORDS + 1]           =
        "Les objets prennent désormais en charge des mots-clés secondaires pour affiner une correspondance. Chaque emplacement d'objet a généralement une version Étincelle, PVP et Bleue. Les mots-clés secondaires peuvent être configurés pour les différencier.",
        [LID.RN_SECONDARY_KEYWORDS + 2]           = "Exemple de mots-clés secondaires :",
        [LID.RN_SECONDARY_KEYWORDS + 3]           = "606, 619, 636",
        [LID.RN_SECONDARY_KEYWORDS + 4]           = "610, pvp, algari",
        [LID.RN_SECONDARY_KEYWORDS + 5]           = "590",
        ["Find Crafter"]                          = "Trouver un Artisan",
        ["No Crafters Found"]                     = "Aucun artisan trouvé",
        [LID.FOUND_CRAFTER_NAME_ENTRY]            = "%s [%s]",
        [LID.GREET_FOUND_CRAFTER]                 = "|cffffd100Clic gauche: Demander une fabrication|r",
        ["Crafter Greeting"]                      = "|cFFFFFFFFSalutation de l'artisan|r",
        [LID.BUSY_ICON]                           =
        "|cFFFFFFFFL'artisan a indiqué qu'il est actuellement occupé, mais pourra fabriquer l'objet plus tard.\n\nVérifiez sa salutation pour plus de détails.|r",
        ["Potential Crafters"]                    = "Artisans potentiels",
        [LID.FOUND_VIA_CRAFT_SCAN]                =
        "Je vous ai trouvé via CraftScan et j'ai vu votre salutation. Pouvez-vous fabriquer %s pour moi maintenant?",
        [LID.COMMISSION_INSTRUCTIONS]             =
        "par exemple '10000g', Défaut : 'N'importe lequel'\nCe texte apparaît dans la table 'Trouver un Artisan' du client.",
        ["Commission"]                            = "Commission",
        ["Crafter [Currently Playing]"]           = "Artisan [Actuellement en jeu]",
        ["Profession commission"]                 = "Commission de profession",
        [LID.DEFAULT_COMMISSION]                  = "N'importe lequel",
        [LID.HELP_ITEM_COMMISSION]                =
        "CraftScan fournit aux clients un bouton 'Trouver un Artisan' pour les commandes personnelles. Votre nom, votre salutation et cette commission apparaîtront dans la table avec d'autres artisans. La longueur est limitée à 12 caractères pour tenir dans la table du client.",
        ["Discoverable"]                          = "Découvrable par les clients",
        [LID.DISCOVERABLE_SETTING]                =
        "Si activé, lorsque le client clique sur 'Trouver un Artisan', votre nom apparaîtra dans la table générée si vous pouvez fabriquer l'objet.",
        [LID.RN_CUSTOMER_SEARCH]                  = "Trouver un Artisan",
        [LID.RN_CUSTOMER_SEARCH + 1]              =
        "La page pour envoyer une commande personnelle comporte maintenant un bouton 'Trouver un Artisan'. Ce bouton envoie une requête à tous les utilisateurs de CraftScan pour voir qui peut fabriquer l'objet, et affiche les résultats dans une table avec la commission configurée de l'artisan.",
        [LID.RN_CUSTOMER_SEARCH + 2]              =
        "Chaque profession et objet dispose désormais d'une case 'Commission' pour configurer ce qui apparaîtra dans cette table, et le texte est limité à 12 caractères pour s'adapter à la table.",
        [LID.RN_CUSTOMER_SEARCH + 3]              =
        "Vous avez rejoint le canal 'CraftScan', mais vous n'avez pas besoin de l'activer ou de voir des messages dans le canal. Il permet à CraftScan d'envoyer des demandes privées, comme dans le chat commercial.",
        [LID.RN_CUSTOMER_SEARCH + 4]              =
        "En tant qu'artisan, vous pourriez maintenant recevoir des chuchotements non sollicités de clients qui savent déjà ce que vous pouvez fabriquer.",
        [LID.RN_CUSTOMER_SEARCH + 5]              =
        "C'est un peu difficile à tester car les comptes d'essai n'ont pas accès à la table d'artisanat. Si vous rencontrez des problèmes, vous pouvez désactiver cette fonction jusqu'à ce que je puisse la corriger.",
        [LID.RN_CUSTOMER_SEARCH + 6]              =
        "Vous pouvez choisir de ne pas être inclus dans cette table via le nouveau paramètre 'Découvrable' dans le menu principal des paramètres de Blizzard.",
        [LID.RN_CUSTOMER_SEARCH + 7]              =
        "Comme les clients peuvent commencer à utiliser l'addon, la fonction d'analyse peut être complètement désactivée, et elle est désormais désactivée par défaut. Si vous avez déjà collecté des données, elles resteront activées.",
        ["Permissive keyword matching"]           = "Correspondance permissive des mots-clés",
        [LID.PERMISSIVE_MATCH_SETTING]            =
        "Lorsqu'elle est cochée, CraftScan ne tiendra pas compte des espaces et autres délimiteurs lors de la recherche de correspondances de mots-clés. Par défaut, CraftScan ne correspondra à un mot-clé que s'il est clairement délimité du texte environnant pour éviter une correspondance incorrecte de mots-clés courts intégrés dans d'autres mots. Pour les langues qui n'utilisent pas d'espaces pour délimiter les mots-clés, activez cette option.",
        ["Show chat orders tab"]                  = "Afficher l'onglet des commandes de chat",
        [LID.SHOW_CHAT_ORDER_TAB]                 =
        "Affiche ou masque l'onglet 'Commandes de Chat' dans la fenêtre des métiers. Si masqué, vous pouvez l'ouvrir en cliquant sur le bouton CraftScan où les alertes apparaissent.",
        [LID.IGNORE]                              = "Ignorer",
        [LID.IGNORE_TOOLTIP]                      =
        "Ajoute ce joueur à votre liste d'ignorés CraftScan. CraftScan ignorera tous les messages envoyés par ce joueur. Ce menu peut être utilisé pour retirer le joueur de la liste.",
        [LID.UNIGNORE]                            = "Retirer l'ignorance",
        [LID.UNIGNORE_TOOLTIP]                    =
        "Ce joueur est dans votre liste d'ignorés CraftScan. Cette option le retire de la liste.",
        ["Collapse chat context menu"]            = "Réduire le menu contextuel du chat",
        [LID.COLLAPSE_CHAT_CONTEXT_TOOLTIP]       =
        "Lors d’un clic droit sur un nom de joueur dans le chat, réduisez tous les éléments du menu contextuel en un sous-menu unique CraftScan.",

        [LID.PROXY_ORDERS_TOOLTIP]                =
        "Envoyez les commandes détectées par ce compte vers les comptes liés ayant des permissions 'Contrôle total'. Le compte recevant affichera la notification habituelle comme s'il avait détecté la commande.",
        [LID.RECEIVE_PROXY_ORDERS_TOOLTIP]        =
        "Recevez les commandes détectées et transmises par un compte lié en 'Contrôle total'. Lorsqu'une commande est reçue du compte lié, la notification habituelle apparaîtra sur ce compte.",
        [LID.LOCAL_ALERTS_TOOLTIP]                =
        "Les notifications visuelles et sonores pour cet artisan et cette profession ne s'afficheront que lorsque vous jouez ce personnage. Il s'agit uniquement d'un filtre et cela n'active ni ne désactive les notifications en général. Elles restent gérées via les icônes de quête et de casque à droite de la liste des artisans.",
        ["Local Notifications Only"]              = "Notifications locales uniquement",

    }
end
