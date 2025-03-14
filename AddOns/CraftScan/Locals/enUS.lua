local CraftScan = select(2, ...)

CraftScan.LOCAL_EN = {}

function CraftScan.LOCAL_EN:GetData()
        local LID = CraftScan.CONST.TEXT;
        return {
                -- I eventually got tired of the whole LID enum tedium copy/pasted from
                -- CraftSim, so newer short ones are just the raw English string as the
                -- key, which is easier to read in the code anyway.
                ["CraftScan"]                         = "CraftScan",
                [LID.CRAFT_SCAN]                      = "CraftScan",
                [LID.CHAT_ORDERS]                     = "Chat Orders",
                [LID.DISABLE_ADDONS]                  = "Disable Addons",
                [LID.RENABLE_ADDONS]                  = "Re-enable Addons",
                [LID.DISABLE_ADDONS_TOOLTIP]          =
                "Save your list of addons, and then disable them, allowing for a quick swap to an alt. This button can be clicked again to re-enable the addons at any time.",
                [LID.GREETING_I_CAN_CRAFT_ITEM]       = "I can craft {item}.",                  -- ItemLink
                [LID.GREETING_ALT_CAN_CRAFT_ITEM]     = "My alt, {crafter}, can craft {item}.", -- Crafter Name, ItemLink
                [LID.GREETING_LINK_BACKUP]            = "that",
                [LID.GREETING_I_HAVE_PROF]            = "I have {profession}.",                 -- Profession Name
                [LID.GREETING_ALT_HAS_PROF]           = "My alt, {crafter}, has {profession}.", -- Crafter Name, Profession Name
                [LID.GREETING_ALT_SUFFIX]             = "Let me know if you send an order so I can log over.",
                [LID.MAIN_BUTTON_BINDING_NAME]        = "Toggle Order Page",
                [LID.GREET_BUTTON_BINDING_NAME]       = "Greet Banner Customer",
                [LID.DISMISS_BUTTON_BINDING_NAME]     = "Dismiss Banner Customer",
                [LID.TOGGLE_CHAT_TOOLTIP]             = "Toggle chat orders%s", -- Keybind
                [LID.SCANNER_CONFIG_SHOW]             = "Show CraftScan",
                [LID.SCANNER_CONFIG_HIDE]             = "Hide CraftScan",
                [LID.CRAFT_SCAN_OPTIONS]              = "CraftScan Options",
                [LID.ITEM_SCAN_CHECK]                 = "Scan chat for this item",
                [LID.HELP_PROFESSION_KEYWORDS]        =
                "A message must contain one of these terms. To match a message such as 'LF Lariat', 'lariet' should be listed here. To generate an item link for the Elemental Lariat in the response, 'lariat' should also be included in the item configuration keywords for the Elemental Lariat.",
                [LID.HELP_PROFESSION_EXCLUSIONS]      =
                "A message will be ignored if it contains one of these terms, even if it would otherwise be a match. To avoid responding to 'LF JC Lariat' with 'I have Jewelcrafting' when you do not have the Lariat recipe, 'lariat' should be listed here.",
                [LID.HELP_SCAN_ALL]                   = "Enable scanning for all recipes in the same expansion as the selected recipe.",
                [LID.HELP_PRIMARY_EXPANSION]          =
                "Use this greeting when responding to a generic request such as 'LF Blacksmith'. When a new expansion launches, you will likely want a greeting describing what items you can craft instead of stating that you have max knowledge from the prior expansion.",
                [LID.HELP_EXPANSION_GREETING]         =
                "An initial intro is always generated stating that you can craft the item. This text is appended to it. New lines are allowed and will be sent as a separate response. If the text is too long, it will be broken into multiple responses.",
                [LID.HELP_CATEGORY_KEYWORDS]          =
                "If a profession has been matched, check for these category specific keywords to refine the greeting. For example, you could put 'toxic' or 'slimy' here to attempt to detect Leatherworking patterns that require the Alter of Decay.",
                [LID.HELP_CATEGORY_GREETING]          =
                "When this category is detected in a message, via either a keyword or an item link, this additional greeting will appended after the profession greeting.",
                [LID.HELP_CATEGORY_OVERRIDE]          = "Omit the profession greeting and start with the category greeting.",
                [LID.HELP_ITEM_KEYWORDS]              =
                "If a profession has been matched, check for these item specific keywords to refine the greeting. When matched, the response will include the item link instead of the generic profession greeting. If 'lariat' is a profession keyword, but not an item keyword, the response will says 'I have Jewelcrafting.' If 'lariat' is only an item keyword, 'LF Lariat' will not match a profession and is not considered a match. If 'lariat' is both a profession and item keyword, the response to 'LF Lariat' will be 'I can craft [Elemental Lariat].'",
                [LID.HELP_ITEM_GREETING]              =
                "When this item is detected in a message, via either a keyword or the item link, this additional greeting will be appended after the profession and category greetings.",
                [LID.HELP_ITEM_OVERRIDE]              = "Omit the profession and category greeting and start with the item greeting.",
                [LID.HELP_GLOBAL_KEYWORDS]            = "A message must include one of these terms.",
                [LID.HELP_GLOBAL_EXCLUSIONS]          = "A message will be ignored if it contains one of these terms.",
                [LID.SCAN_ALL_RECIPES]                = 'Scan all recipes',
                [LID.SCANNING_ENABLED]                = "Scanning is enabled because '%s' is checked.", -- SCAN_ALL_RECIPES or ITEM_SCAN_CHECK
                [LID.SCANNING_DISABLED]               = "Scanning is disabled.",
                [LID.PRIMARY_KEYWORDS]                = "Primary Keywords",
                [LID.HELP_PRIMARY_KEYWORDS]           =
                "All messages are filtered by these terms, which are common across all professions. A matching message is further processed to look for profession related content.",
                [LID.HELP_CATEGORY_SECTION]           =
                "The category is the collapsible section containing the recipe in the list to the left. 'Favorites' is not a category. This is intended mainly for things like the toxic Leatherworking recipes that are more difficult to craft. It might also be useful at the start of expansions when you can only specialize in a single category.",
                [LID.HELP_EXPANSION_SECTION]          = "Knowledge trees differ per expansion, so the greeting can also differ.",
                [LID.HELP_PROFESSION_SECTION]         =
                "From a customer point of view, there is no difference between expansions. These terms combine with the 'Primary expansion' selection to provide a generic greeting (e.g. 'I have <profession>.') when we can not match something more specific.",
                [LID.RECIPE_NOT_LEARNED]              = "You have not learned this recipe. Scanning is disabled.",
                [LID.PING_SOUND_LABEL]                = "Alert sound",
                [LID.PING_SOUND_TOOLTIP]              = "The sound that plays when a customer has been detected.",
                [LID.BANNER_SIDE_LABEL]               = "Banner direction",
                [LID.BANNER_SIDE_TOOLTIP]             = "The banner will grow from the button in this direction.",
                Left                                  = "Left",
                Right                                 = "Right",
                Minute                                = "Minute",
                Minutes                               = "Minutes",
                Second                                = "Second",
                Seconds                               = "Seconds",
                Millisecond                           = "Millisecond",
                Milliseconds                          = "Milliseconds",
                Version                               = "New in",
                ["CraftScan Release Notes"]           = "CraftScan Release Notes",
                [LID.CUSTOMER_TIMEOUT_LABEL]          = "Customer timeout",
                [LID.CUSTOMER_TIMEOUT_TOOLTIP]        = "Automatically dismiss customers after this many minutes.",
                [LID.BANNER_TIMEOUT_LABEL]            = "Banner timeout",
                [LID.BANNER_TIMEOUT_TOOLTIP]          =
                "The customer notification banner will remain displayed for this duration after a match is detected.",
                ["All crafters"]                      = "All crafters",
                ["Crafter Name"]                      = "Crafter Name",
                ["Profession"]                        = "Profession",
                ["Customer Name"]                     = "Customer Name",
                ["Replies"]                           = "Replies",
                ["Keywords"]                          = "Keywords",
                ["Profession greeting"]               = "Profession greeting",
                ["Category greeting"]                 = "Category greeting",
                ["Item greeting"]                     = "Item greeting",
                ["Primary expansion"]                 = "Primary expansion",
                ["Override greeting"]                 = "Override greeting",
                ["Excluded keywords"]                 = "Excluded keywords",
                [LID.EXCLUSION_INSTRUCTIONS]          = "Do not match messages containing these comma separated tokens.",
                [LID.KEYWORD_INSTRUCTIONS]            = "Match messages containing one of these comma separated keywords.",
                [LID.GREETING_INSTRUCTIONS]           = "A greeting to send to customers looking for a craft.",
                [LID.GLOBAL_INCLUSION_DEFAULT]        = "LF, LFC, WTB, recraft",
                [LID.GLOBAL_EXCLUSION_DEFAULT]        = "LFW, WTS, LF work",
                [LID.DEFAULT_KEYWORDS_BLACKSMITHING]  = "BS, Blacksmith, Armorsmith, Weaponsmith",
                [LID.DEFAULT_KEYWORDS_LEATHERWORKING] = "LW, Leatherworking, Leatherworker",
                [LID.DEFAULT_KEYWORDS_ALCHEMY]        = "Alc, Alchemist, Stone",
                [LID.DEFAULT_KEYWORDS_TAILORING]      = "Tailor",
                [LID.DEFAULT_KEYWORDS_ENGINEERING]    = "Engineer, Eng",
                [LID.DEFAULT_KEYWORDS_ENCHANTING]     = "Enchanter, Crest",
                [LID.DEFAULT_KEYWORDS_JEWELCRAFTING]  = "JC, Jewelcrafter",
                [LID.DEFAULT_KEYWORDS_INSCRIPTION]    = "Inscription, Inscriptionist, Scribe",

                -- Release notes
                [LID.RN_WELCOME]                      = "Welcome to CraftScan!",
                [LID.RN_WELCOME + 1]                  =
                "This addon scans chat for messages that look like requests for crafting. If the configuration indicates you can craft the requested item, a notification will be triggered and the customer information stored to facilitate communication.",

                [LID.RN_INITIAL_SETUP]                = "Initial Setup",
                [LID.RN_INITIAL_SETUP + 1]            =
                "To get started, open a profession and click the new 'Show CraftScan' button along the bottom.",
                [LID.RN_INITIAL_SETUP + 2]            =
                "Scroll to the bottom of this new window and work your way up. The things you need to rarely change are at the bottom, but those are the setting to care about first.",
                [LID.RN_INITIAL_SETUP + 3]            =
                "Click the help icon in the top left corner of the window if you need an explanation of any input.",

                [LID.RN_INITIAL_TESTING]              = "Initial Testing",
                [LID.RN_INITIAL_TESTING + 1]          =
                "Once configured, type a message in /say chat, such as 'LF BS' for Blacksmithing, assuming you have left the 'LF' and 'BS' keywords. A notification should pop up.",
                [LID.RN_INITIAL_TESTING + 2]          =
                "Click the notification to immediately send a response, right click it to dismiss the customer, or click on the circular profession button itself to open the orders window.",
                [LID.RN_INITIAL_TESTING + 3]          =
                "Duplicate notifications are suppressed unless they have already been dismissed, so right click your test notification to dismiss it if you want to try again.",

                [LID.RN_MANAGING_CRAFTERS]            = "Managing Your Crafters",
                [LID.RN_MANAGING_CRAFTERS + 1]        =
                "The left hand side of the orders window lists your crafters. This list will be populated as you log in to your various characters and configure their professions. You can select which characters should be actively scanned at any time, as well as whether the visual and auditory notifications are enabled for each of your crafters.",

                [LID.RN_MANAGING_CUSTOMERS]           = "Managing Customers",
                [LID.RN_MANAGING_CUSTOMERS + 1]       =
                "The right hand side of the orders window will populate with crafting orders detected in chat. Left click a row to send the greeting if you did not already do so from the pop-up banner. Left click again to open a whisper to the customer. Right click to dismiss the row.",
                [LID.RN_MANAGING_CUSTOMERS + 2]       =
                "Rows in this table will persist across all characters, so you can log over to an alt and then click the customer again to restore communication. Rows time out after 10 minutes by default. This duration can be configured in the main settings page (Esc -> Options -> AddOns -> CraftScan).",
                [LID.RN_MANAGING_CUSTOMERS + 3]       =
                "Hopefully most the table is self explanatory. The 'Replies' column has 3 icons. The left X or check mark is whether you have sent a message to the customer. The right X or check mark is whether the customer has replied. The chat bubble is a button that will open a temporary whisper window with the customer, and populate it with your chat history.",

                [LID.RN_KEYBINDS]                     = "Keybinds",
                [LID.RN_KEYBINDS + 1]                 =
                "Keybinds are available for opening the orders page, responding to the latest customer, and dismissing the latest customer. Search for 'CraftScan' to find all available settings.",

                [LID.RN_CLEANUP]                      = "Configuration Cleanup",
                [LID.RN_CLEANUP + 1]                  =
                "Your crafters on the left hand side of the 'Chat Orders' page now have a context menu when right clicked. Use this menu to keep the list clean and remove stale characters/professions.",

                ["Disable"]                           = "Disable",
                [LID.DELETE_CONFIG_TOOLTIP_TEXT]      =
                "Permanently delete any saved %s data for %s.\n\nAn 'Enable CraftScan' button will be present on the profession page to enable it again with default settings.\n\nUse this if you want to continue using the profession, but with no CraftScan interaction (e.g. when you have Alchemy on every alt for long flasks).", -- profession-name, character-name
                [LID.DELETE_CONFIG_CONFIRM]           = "Type 'DELETE' to proceed:",
                [LID.SCANNER_CONFIG_DISABLED]         = "Enable CraftScan",

                ["Cleanup"]                           = "Cleanup",
                [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]     =
                "Permanently delete any saved %s data for %s.\n\nThe profession will be left in a state as if it was never configured. Simply opening the profession again will restore a default configuration.\n\nUse this if you want to completely reset a profession, have deleted the character, or have dropped a profession.", -- profession-name, character-name
                [LID.CLEANUP_CONFIG_CONFIRM]          = "Type 'CLEANUP' to proceed:",

                ["Primary Crafter"]                   = "Primary Crafter",
                [LID.PRIMARY_CRAFTER_TOOLTIP]         =
                "Flag %s as your primary crafter for %s. This crafter will be given priority over others if there are multiple matches to the same request.",
                ["Chat History"]                      = "Chat history with %s", -- customer
                ["Greet Help"]                        = "|cffffd100Left click: Greet customer%s|r",
                ["Chat Help"]                         = "|cffffd100Left click: Open whisper|r",
                ["Chat Override"]                     = "|cffffd100Middle click: Open whisper%s|r",
                ["Dismiss"]                           = "|cffffd100Right click: Dismiss%s|r",
                ["Proposed Greeting"]                 = "Proposed greeting:",
                [LID.CHAT_BUTTON_BINDING_NAME]        = "Whisper Banner Customer",
                ["Customer Request"]                  = "Request from %s",
                [LID.ADDON_WHITELIST_LABEL]           = "Addon whitelist",
                [LID.ADDON_WHITELIST_TOOLTIP]         =
                "When you hit the button to temporarily disable all addons, keep the addons selected here enabled. CraftScan will always stay enabled. Keep only what you need to craft effectively.",
                [LID.MULTI_SELECT_BUTTON_TEXT]        = "%d selected", -- Count
                [LID.ACCOUNT_LINK_DESC]               =
                "Share crafters between multiple accounts.\n\nAt login or after a configuration change, CraftScan will propagate the latest information to and from crafters that have been configured on either account to ensure both sides of a linked account are always in sync.",
                [LID.ACCOUNT_LINK_PROMPT_CHARACTER]   = "Enter the name of an online character on your other account:",
                [LID.ACCOUNT_LINK_PROMPT_NICKNAME]    = "Enter a nickname for the other account:",
                ["Link Account"]                      = "Link Account",
                ["Linked Accounts"]                   = "Linked Accounts",
                ["Accept Linked Account"]             = "Accept Linked Account",
                ["Delete Linked Account"]             = "Delete Linked Account",
                ["OK"]                                = "OK",
                [LID.VERSION_MISMATCH]                =
                "|cFFFF0000Error: CraftScan version mismatch. Other account version: %s. Your version: %s.|r",

                [LID.REMOTE_CRAFTER_TOOLTIP]          =
                "This character belongs to a linked account. It can only be disabled on the account that owns the character. You can completely remove this character via 'Cleanup', but will need to do so manually on all linked accounts, or it will be restored by a linked account on login.",
                [LID.REMOTE_CRAFTER_SUMMARY]          = "Synced with %s.",
                ["proxy_send_enabled"]                = "Proxy Orders",
                ["proxy_send_enabled_tooltip"]        = "When a customer order is detected, send it linked accounts.",
                ["proxy_receive_enabled"]             = "Receive Proxied Orders",
                ["proxy_receive_enabled_tooltip"]     =
                "When another account detects and sends a customer order, this account will receive it. The CraftScan button will be displayed to show the alert banner if necessary.",
                [LID.LINK_ACTIVE]                     = "|cFF00FF00%s (last seen %s)|r", -- Crafter, Time
                [LID.ACCOUNT_LINK_DELETE_INFO]        =
                "Delete the link to '%s' and delete all imported characters. This account will cease all communication with the other side. The other side will still attempt to establish connections until the link is manually removed there as well.\n\nImported crafters that will be removed:\n%s",
                [LID.ACCOUNT_LINK_ADD_CHAR]           =
                "By default, the character you initially linked to, any crafters, and any characters that have logged in while this account was online are known to CraftScan. Add additional characters owned by the other account so that it can be used as well. '/reload' to force sync with the new character if it is online.",
                ["Backup characters"]                 = "Additional characters",
                ["Unlink account"]                    = "Unlink account",
                ["Add"]                               = "Add",
                ["Remove"]                            = "Remove",
                ["Rename account"]                    = "Rename account",
                ["New name"]                          = "New name:",


                [LID.RN_LINKED_ACCOUNTS]                  = "Linked Accounts",
                [LID.RN_LINKED_ACCOUNTS + 1]              =
                "Link multiple WoW accounts together to share crafting information and scan for any account from any account.",
                [LID.RN_LINKED_ACCOUNTS + 2]              =
                "Optionally, proxy customer orders from one account to the others so you can park a trial account in town while your main is out and about.",
                [LID.RN_LINKED_ACCOUNTS + 3]              =
                "To get started, click the 'Link Account' button in the bottom left corner of the CraftScan window and follow the instruction.",
                [LID.RN_LINKED_ACCOUNTS + 4]              =
                "Demo: https://www.youtube.com/watch?v=x1JLEph6t_c",

                ["Open Settings"]                         = "Open Settings",
                ["Customize Greeting"]                    = "Customize Greeting",
                [LID.CUSTOM_GREETING_INFO]                =
                "CraftScan uses these sentences to create the initial greeting sent to customers depending on the situation. Override some or all of them below to create your own greeting.",
                ["Default"]                               = "Default",
                [LID.MISSING_PLACEHOLDERS]                = "The following placeholders are also supported: %s.",
                [LID.EXTRA_PLACEHOLDERS]                  = "Error: %s are not valid placeholders.",
                [LID.LEGACY_PLACEHOLDERS]                 =
                "Warning: The use of %s is now deprecated. Please use named placeholders, like so: {placeholder}",

                ["Pixels"]                                = "Pixels",
                ["Show button height"]                    = "Show button height",
                ["Alert icon scale"]                      = "Alert icon scale",
                ["Total"]                                 = "Total",
                ["Repeat"]                                = "Repeat",
                ["Avg Per Day"]                           = "Avg/Day",
                ["Peak Per Hour"]                         = "Peak/Hour",
                ["Median Per Customer"]                   = "Mdn/Cust",
                ["Median Per Customer Filtered"]          = "Mdn/Cust Repeat",
                ["No analytics data"]                     = "No analytics data",
                ["Reset Analytics"]                       = "Reset Analytics",
                ["Analytics Options"]                     = "Analytics Options",

                ["1 minute"]                              = "1 minute",
                ["15 minutes "]                           = "15 minutes ",
                ["1 hour"]                                = "1 hour",
                ["1 day"]                                 = "1 day",
                ["1 week "]                               = "1 week ",
                ["30 days"]                               = "30 days",
                ["180 days"]                              = "180 days",
                ["1 year"]                                = "1 year",
                ["Clear recent data"]                     = "Clear recent data",
                ["Newer than"]                            = "Newer than",
                ["Clear old data"]                        = "Clear old data",
                ["Older than"]                            = "Older than",
                ["1 Minute Bins"]                         = "1 Minute Bins",
                ["5 Minute Bins"]                         = "5 Minute Bins",
                ["10 Minute Bins"]                        = "10 Minute Bins",
                ["30 Minute Bins"]                        = "30 Minute Bins",
                ["1 Hour Bins"]                           = "1 Hour Bins",
                ["6 Hour Bins"]                           = "6 Hour Bins",
                ["12 Hour Bins"]                          = "12 Hour Bins",
                ["24 Hour Bins"]                          = "24 Hour Bins",
                ["1 Week Bins"]                           = "1 Week Bins",

                [LID.ANALYTICS_ITEM_TOOLTIP]              =
                "Items are matched by ensuring a message matches the global inclusion and exclusion keywords, and then looking for the quality icon in an item link. There is no global list of crafted items or way to determine if an itemID is crafted, so this is the best we can do.",
                [LID.ANALYTICS_PROFESSION_TOOLTIP]        =
                "There is no reverse look up from item to profession that crafts it. If one of your characters can craft the item, the profession is automatically assigned. When a profession is opened, any unknown items belonging to that profession are assigned. You can also manually assign the profession.",
                [LID.ANALYTICS_TOTAL_TOOLTIP]             =
                "The total number of times this item has been requested. Duplicate requests from the same customer within the same hour are not included.",
                [LID.ANALYTICS_REPEAT_TOOLTIP]            =
                "The total number of times this item has been requested by the same customer multiple times within the same hour.\n\nIf this value is close to the Total, then supply for this item is likely lacking.\n\nDuplicate requests within 15 seconds of the initial request are ignored.",
                [LID.ANALYTICS_AVERAGE_TOOLTIP]           = "The average number of total requests for this item per day.",
                [LID.ANALYTICS_PEAK_TOOLTIP]              = "The peak number of requests for this item per hour.",
                [LID.ANALYTICS_MEDIAN_TOOLTIP]            =
                "The median number of times the same customer has requested the same item within the same hour.\n\nA value of 1 indicates that at least half of all requests are being fulfilled by someone and the demand for this item is likely satisfied.\n\nIf this value is high, this is likely a good item to pursue being able to craft.",
                [LID.ANALYTICS_MEDIAN_TOOLTIP_FILTERED]   =
                "The median number of times the same customer has requested the same item within the same hour, filtered to only those requests where the requestor asked multiple times.\n\nIf this value is not 1 but the unfiltered median is 1, that indicates that there are times when demand is not being met.",
                ["Request Count"]                         = "Request Count",
                [LID.ACCOUNT_LINK_ACCEPT_DST_INFO]        =
                "'%s' has sent a request to link accounts.\n\nThe following permissions were requested:\n\n%s\n\nDo not accept full permission unless you sent the request.\n\nEnter a nickname for the other account:",
                [LID.LINKED_ACCOUNT_REJECTED]             = "CraftScan: Linked account request failed. Reason: %s",
                [LID.LINKED_ACCOUNT_USER_REJECTED]        = "Target account rejected the request.",

                [LID.LINKED_ACCOUNT_PERMISSION_FULL]      = "Full Control",
                [LID.LINKED_ACCOUNT_PERMISSION_ANALYTICS] = "Analytics Sync",
                [LID.ACCOUNT_LINK_PERMISSIONS_DESC]       = "Request the following permissions with the linked account.",
                [LID.ACCOUNT_LINK_FULL_CONTROL_DESC]      =
                "Syncs all character data and supports all other permissions as well.",
                [LID.ACCOUNT_LINK_ANALYTICS_DESC]         =
                "Synchronize only analytics data between the two account manually via the account's menu. Either account can trigger a two-way sync at any time. It is never done automatically. Since no characters are imported, you will only sync with the character specified here. You can manually add more alts of the linked account from the account menu.",
                ["Sync Analytics"]                        = "Sync Analytics",
                ["Sync Recent Analytics"]                 = "Sync Recent Analytics",
                [LID.ANALYTICS_PROF_MISMATCH]             =
                "|cFFFF0000CraftScan: Warning: Analytics sync profession mismatch. Item: %s. Local profession: %s. Linked profession: %s.|r",
                [LID.RN_ANALYTICS]                        = "Analytics",
                [LID.RN_ANALYTICS + 1]                    =
                "CraftScan now scans chat for any crafted item combined with your global keywords (e.g. LF, recraft, etc...), even if you cannot craft the item. The time is recorded and detected items are displayed below the usual orders found in chat.",
                [LID.RN_ANALYTICS + 2]                    =
                "The concept of 'repeats' is used to determine if an item is lacking supply. CraftScan remembers who requested what for the last hour, and if they request the same thing again, it is recorded as a repeat. The column headers of the new grid have tooltips explaining their intent.",
                [LID.RN_ANALYTICS + 3]                    =
                "With a character parked in trade chat long enough, this should build up a good view of what branches of the profession tree are worth investment.",
                [LID.RN_ANALYTICS + 4]                    =
                "Analytics can be synchronized across multiple accounts. You can park a trial account in trade all day to collect data, then sync it over to your main account. You can also now create an analytics-only account link with a friend, supporting a two way sync that merges your analytics together. Once the collection gets large, there is an option to only sync data since the last time the accounts were synced.",
                [LID.RN_ALERT_ICON_ANCHOR]                = "Alert Icon Anchoring Updates",
                [LID.RN_ALERT_ICON_ANCHOR + 1]            =
                "The alert icon's will now be hidden correctly when the UI is hidden. The change moved and scaled it on my screen slightly. If the button has moved off your screen because of this, there is a reset option if you right click the 'Open Settings' button at the top right of the chat orders page.",
                [LID.BUSY_RIGHT_NOW]                      = "Busy Mode",
                [LID.GREETING_BUSY]                       = "I am busy now, but can craft that later if you send it.",
                [LID.BUSY_HELP]                           =
                "|cFFFFFFFFWhen checked, append the busy greeting in your response. Edit your busy greeting with the button below.\n\nThis is intended for use with a second account proxying orders so you can catch orders while out and about on your main.\n\nCurrent busy greeting: |cFF00FF00%s|r|r",
                ["Custom Explanations"]                   = "Custom Explanations",
                ["Create"]                                = "Create",
                ["Modify"]                                = "Modify",
                ["Delete"]                                = "Delete",
                [LID.EXPLANATION_LABEL_DESC]              =
                "Enter a label that you will see when right clicking the customer name in chat.",
                [LID.EXPLANATION_DUPLICATE_LABEL]         = "This label is already in use.",
                [LID.EXPLANATION_TEXT_DESC]               =
                "Enter a message to send to the customer when the label is clicked. New lines are sent as separate messages. Long lines are split to fit within the max message length.",
                ["Create an Explanation"]                 = "Create an Explanation",
                ["Save"]                                  = "Save",
                ["Reset"]                                 = "Reset",
                [LID.MANUAL_MATCHING_TITLE]               = "Manual Matching",
                [LID.MANUAL_MATCH]                        = "%s - %s",  -- crafter, profession
                [LID.MANUAL_MATCHING_DESC]                =
                "Ignore primary keywords and force a match for this message. CraftScan will attempt to find the correct crafter based on the message, but if no matches are found, the default greeting for the specified crafter will be used. The match is reported via the usual means, allowing you to click the banner or table row to send the greeting.",

                [LID.RN_MANUAL_MATCH]                     = "Manual Matching",
                [LID.RN_MANUAL_MATCH + 1]                 =
                "The context menu when right clicking a player name in chat now includes CraftScan options.",
                [LID.RN_MANUAL_MATCH + 2]                 =
                "This menu includes all of your crafters and professions. Clicking one of these will force another pass on the message to look for a match without considering the 'Primary Keywords' (e.g. LF, WTB, recraft, etc...), in case the customer is using non-standard terminology.",
                [LID.RN_MANUAL_MATCH + 3]                 =
                "If the message still does not match, a match is forced with the default greeting for the crafter and profession you clicked.",
                [LID.RN_MANUAL_MATCH + 4]                 =
                "This click will not automatically message the customer. It generates the match in the usual way, and then you can inspect the generated response and choose to send it or not.",
                [LID.RN_MANUAL_MATCH + 5]                 = "(Sorry, no machine learning.)",
                [LID.RN_CUSTOM_EXPLANATIONS]              = "Custom Explanations",
                [LID.RN_CUSTOM_EXPLANATIONS + 1]          =
                "The 'Chat Orders' page now includes a 'Custom Explanations' button. Explanations configured here also appear in the chat context menu, and clicking them will immediately send the explanation.",
                [LID.RN_CUSTOM_EXPLANATIONS + 2]          =
                "Explanations are sorted alphabetically, so you can number them to force a desired order.",
                [LID.RN_BUSY_MODE]                        = "Busy Mode",
                [LID.RN_BUSY_MODE + 1]                    =
                "This has been in for a few releases, but was never explained. There is a new 'Busy Mode' check box on the 'Chat Orders' page. When checked, append the busy greeting in your response. Edit your busy greeting with the 'Customize Greeting' button.",
                [LID.RN_BUSY_MODE + 2]                    =
                "This is intended for use with a second account proxying orders so you can catch orders while out and about on your main, and the customer will know you can't craft it immediately.",
                ["Release Notes"]                         = "Release Notes",

                ["Secondary Keywords"]                    = "Secondary Keywords",
                [LID.SECONDARY_KEYWORD_INSTRUCTIONS]      =
                "For example: 'pvp, 610, algari' or '606, 610, 636' or '590', to differentiate the same keyword on multiple items.",
                [LID.HELP_ITEM_SECONDARY_KEYWORDS]        =
                "After matching a keyword above, check for any secondary keywords to refine the match, allowing the various crafts for the same item slot to be differentiated.",
                [LID.RN_SECONDARY_KEYWORDS]               = "Secondary Keywords",
                [LID.RN_SECONDARY_KEYWORDS + 1]           =
                "Items now support secondary keywords to refine a match. Each item slot usually has a Spark, PVP, and Blue version. Secondary keywords can be setup to differentiate them.",
                [LID.RN_SECONDARY_KEYWORDS + 2]           = "Example secondary keywords:",
                [LID.RN_SECONDARY_KEYWORDS + 3]           = "606, 619, 636",
                [LID.RN_SECONDARY_KEYWORDS + 4]           = "610, pvp, algari",
                [LID.RN_SECONDARY_KEYWORDS + 5]           = "590",

                ["Find Crafter"]                          = "Find Crafter",
                ["No Crafters Found"]                     = "No Crafters Found",
                [LID.FOUND_CRAFTER_NAME_ENTRY]            = "%s [%s]",
                [LID.GREET_FOUND_CRAFTER]                 = "|cffffd100Left click: Request craft|r",
                ["Crafter Greeting"]                      = "|cFFFFFFFFCrafter Greeting|r",
                [LID.BUSY_ICON]                           =
                "|cFFFFFFFFThe crafter has indicated they are currently busy, but can craft the item later.\n\nCheck their greeting for details.|r",
                ["Potential Crafters"]                    = "Potential Crafters",
                [LID.FOUND_VIA_CRAFT_SCAN]                =
                "I found you via CraftScan and have seen your greeting. Can you craft %s for me now?",
                [LID.COMMISSION_INSTRUCTIONS]             =
                "e.g. '10000g', Default: 'Any'\nThis text appears in the customer's 'Find Crafter' table.",
                ["Commission"]                            = "Commission",
                ["Crafter [Currently Playing]"]           = "Crafter [Currently Playing]",
                ["Profession commission"]                 = "Profession commission",
                [LID.DEFAULT_COMMISSION]                  = "Any",
                [LID.HELP_ITEM_COMMISSION]                =
                "CraftScan provides customers with a 'Find Crafter' button on personal orders. You name, greeting, and this commission will appear in the table along with other crafters. The length is limited to 12 characters to fit nicely in the customer's table.",
                ["Discoverable"]                          = "Discoverable to customers",
                [LID.DISCOVERABLE_SETTING]                =
                "When enabled, when a customer hits 'Find Crafter', your name will appear in the generated table if you can craft the item.",
                [LID.RN_CUSTOMER_SEARCH]                  = "Find a Crafter",
                [LID.RN_CUSTOMER_SEARCH + 1]              =
                "The page to send a Personal Order now has a 'Find Crafter' button. This button sends a request to all CraftScan users to see who can craft the item and presents the results in a table with the crafter's configured commission.",
                [LID.RN_CUSTOMER_SEARCH + 2]              =
                "Each profession and item now has a 'Commission' box to configure what will show up in this table, and the text is limited to 12 characters to fit in the table.",
                [LID.RN_CUSTOMER_SEARCH + 3]              =
                "You have joined the 'CraftScan' channel, but you don't need to enable it or see any messages in the channel. It exists to allow CraftScan to privately broadcast requests like players usually do in Trade chat.",
                [LID.RN_CUSTOMER_SEARCH + 4]              =
                "As a crafter, you might now receive unprompted whispers from customers that already know what you can craft.",
                [LID.RN_CUSTOMER_SEARCH + 5]              =
                "This one is a bit difficult to test since trial accounts aren't allowed access to the crafting table. If you run into any issues, you can disable the feature until I can fix it.",
                [LID.RN_CUSTOMER_SEARCH + 6]              =
                "You can opt out of being included in this table via the new 'Discoverable' setting in main Blizzard Settings menu.",
                [LID.RN_CUSTOMER_SEARCH + 7]              =
                "Since customers might start using the addon, the Analytics feature can be completely disabled, and defaults to being disabled now. If you already collected data, it will remain enabled.",
                ["Permissive keyword matching"]           = "Permissive keyword matching",
                [LID.PERMISSIVE_MATCH_SETTING]            =
                "When checked, CraftScan will stop caring about spaces and other delimiters when checking for keyword matches. By default, CraftScan will only match a keyword if it is clearly delimited from the surrounding text to avoid incorrectly matching short keywords embedded in other words. For languages that don't use spaces to delimit keywords, enable this option.",
                ["Show chat orders tab"]                  = "Show chat orders tab",
                [LID.SHOW_CHAT_ORDER_TAB]                 =
                "Show or hide the 'Chat Orders' tab on the profession window. If hidden, you can open the chat orders page by clicking the CraftScan button where alerts appear.",
                [LID.IGNORE]                              = "Ignore",
                [LID.IGNORE_TOOLTIP]                      =
                "Add this player to your CraftScan ignore list. CraftScan will ignore all messages sent by this player. This menu can be used to remove the player from the list.",
                [LID.UNIGNORE]                            = "Remove Ignore",
                [LID.UNIGNORE_TOOLTIP]                    =
                "This player is on your CraftScan ignore list. This option will remove them from the list.",
                ["Collapse chat context menu"]            = "Collapse chat context menu",
                [LID.COLLAPSE_CHAT_CONTEXT_TOOLTIP]       =
                "When right clicking a player name in chat, collapse all context menu items into a single CraftScan sub-menu.",

                [LID.PROXY_ORDERS_TOOLTIP]                =
                "Send orders detected by this account to linked accounts with 'Full Control' permissions. The receiving account will show the usual notification as if it detected the order.",
                [LID.RECEIVE_PROXY_ORDERS_TOOLTIP]        =
                "Receive orders that were detected and proxied by a linked 'Full Control' account. When an order is received from the linked account, the usual notification will appear on this account.",
                ["Local Notifications Only"]              = "Local Notifications Only",
                [LID.LOCAL_ALERTS_TOOLTIP]                =
                "Visual and auditory notifications regarding this crafter and profession will only be made when you are currently playing this crafter. Note that this does not enable or disable notifications in general. It is only a filter. Notifications are still managed for the crafter via the quest and headset icons on the right side of the crafter list.",

                -- Translations complete above this line

                -- ChatGPT prompt:
                -- I'm writing a world of warcraft addon. I'm going to give you entries from my catalog of english messages. I want you to translate it to deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, and zhTW. Please ouput each language in its own copy/paste box. Please do not change the keys of the catalog. I want to be able to copy paste your output directly into the other language files. Please keep translations concise and use a world of warcraft context when possible. Here are the entries.

        }
end
