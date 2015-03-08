local me,ns=...
local lang=GetLocale()
local l=LibStub("AceLocale-3.0")
local L=l:NewLocale(me,"enUS",true,true)
L["Click to toggle Garrison Mission Frame"] = true
L["Click to toggle Help page"] = true
L["Consider again"] = true
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = true
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = true
L["Do not prefill mission page"] = true
L["Ignore for all missions"] = true
L["Ignore for this mission"] = true
L["Ignore \"maxed\" followers"] = true
L["Left Click to see available missions"] = true
L["Level 100 epic followers are not used for match making unless they are needed to fill up the roster."] = true
L["Minimun chance success under which ignore missions"] = true
L["Mission shown for follower"] = true
L["Must reload interface to apply"] = true
L["Number of followers"] = true
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = true
L["Original method"] = true
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = true
L["Other useful followers"] = true
L["Right click to open ignore menu"] = true
L["Sort missions by:"] = true
L["Success Chance"] = true
L["Switches between Garrison Commander and Master Plan mission interface. Tested with MP 0.20.x"] = true
L["Unlock Panel"] = true
L["Use big screen"] = true
L["Use GC Interface"] = true
L["You have ignored followers"] = true

L=l:NewLocale(me,"ptBR")
if (L) then
-- L["Click to toggle Garrison Mission Frame"] = ""
-- L["Click to toggle Help page"] = ""
-- L["Consider again"] = ""
-- L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = ""
-- L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = ""
-- L["Do not prefill mission page"] = ""
-- L["Ignore for all missions"] = ""
-- L["Ignore for this mission"] = ""
-- L["Ignore \"maxed\" followers"] = ""
-- L["Left Click to see available missions"] = ""
-- L["Level 100 epic followers are not used for match making unless they are needed to fill up the roster."] = ""
-- L["Minimun chance success under which ignore missions"] = ""
-- L["Mission shown for follower"] = ""
-- L["Must reload interface to apply"] = ""
-- L["Number of followers"] = ""
-- L["Only first %1$d missions with over %2$d%% chance of success are shown"] = ""
-- L["Original method"] = ""
-- L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = ""
-- L["Other useful followers"] = ""
-- L["Right click to open ignore menu"] = ""
-- L["Sort missions by:"] = ""
-- L["Success Chance"] = ""
-- L["Switches between Garrison Commander and Master Plan mission interface. Tested with MP 0.20.x"] = ""
-- L["Unlock Panel"] = ""
-- L["Use big screen"] = ""
-- L["Use GC Interface"] = ""
-- L["You have ignored followers"] = ""

return
end
L=l:NewLocale(me,"frFR")
if (L) then
-- L["Click to toggle Garrison Mission Frame"] = ""
L["Click to toggle Help page"] = "Cliquez ici pour basculer vers la page d'aide" -- Needs review
L["Consider again"] = "Reconsid\195\169rer" -- Needs review
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "D\195\169sactiver le remplissage automatique des personnages sur la page de mission. Vous pouvez appuyer sur 'CTRL' tout en cliquant sur une seule mission" -- Needs review
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "D\195\169sactiver ceci vous donnera l'interface du 1.1.8. Besoin de recharger l'interface" -- Needs review
L["Do not prefill mission page"] = "Ne pas pr\195\169-remplir la page de mission" -- Needs review
L["Ignore for all missions"] = "Ignorer pour toutes les missions" -- Needs review
L["Ignore for this mission"] = "Ignorer pour cette mission" -- Needs review
L["Ignore \"maxed\" followers"] = "Ignorer les sujets \"maxi.\"" -- Needs review
L["Left Click to see available missions"] = "Clic gauche pour voir les missions disponible" -- Needs review
-- L["Level 100 epic followers are not used for match making unless they are needed to fill up the roster."] = ""
-- L["Minimun chance success under which ignore missions"] = ""
-- L["Mission shown for follower"] = ""
L["Must reload interface to apply"] = "Doit recharger l'interface pour appliquer" -- Needs review
L["Number of followers"] = "Nombre de sujets" -- Needs review
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "Seuls les %1$d premi\195\168res missions avec plus de %2$d%% de chances de succ\195\168s sont affich\195\169s" -- Needs review
L["Original method"] = "M\195\169thode originale" -- Needs review
-- L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = ""
L["Other useful followers"] = "Autres sujets utiles" -- Needs review
L["Right click to open ignore menu"] = "Clic droit pour ouvrir le menu 'ignorer'" -- Needs review
L["Sort missions by:"] = "Trier les missions par:" -- Needs review
L["Success Chance"] = "Chance de succ\195\168s" -- Needs review
L["Switches between Garrison Commander and Master Plan mission interface. Tested with MP 0.20.x"] = "Bascule entre l'interface de Garrison Commander et Master Plan. Test\195\169 avec MP 0.20.x" -- Needs review
L["Unlock Panel"] = "D\195\169verrouille le panneau" -- Needs review
L["Use big screen"] = "Utilise la gd taille" -- Needs review
L["Use GC Interface"] = "Utiliser l'interface de GC" -- Needs review
L["You have ignored followers"] = "Vous avez ignor\195\169 des sujets" -- Needs review

return
end
L=l:NewLocale(me,"deDE")
if (L) then
-- L["Click to toggle Garrison Mission Frame"] = ""
-- L["Click to toggle Help page"] = ""
-- L["Consider again"] = ""
-- L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = ""
-- L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = ""
-- L["Do not prefill mission page"] = ""
-- L["Ignore for all missions"] = ""
-- L["Ignore for this mission"] = ""
-- L["Ignore \"maxed\" followers"] = ""
-- L["Left Click to see available missions"] = ""
-- L["Level 100 epic followers are not used for match making unless they are needed to fill up the roster."] = ""
-- L["Minimun chance success under which ignore missions"] = ""
-- L["Mission shown for follower"] = ""
-- L["Must reload interface to apply"] = ""
-- L["Number of followers"] = ""
-- L["Only first %1$d missions with over %2$d%% chance of success are shown"] = ""
-- L["Original method"] = ""
-- L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = ""
-- L["Other useful followers"] = ""
-- L["Right click to open ignore menu"] = ""
-- L["Sort missions by:"] = ""
-- L["Success Chance"] = ""
-- L["Switches between Garrison Commander and Master Plan mission interface. Tested with MP 0.20.x"] = ""
-- L["Unlock Panel"] = ""
-- L["Use big screen"] = ""
-- L["Use GC Interface"] = ""
-- L["You have ignored followers"] = ""

return
end
L=l:NewLocale(me,"itIT")
if (L) then
L["Click to toggle Garrison Mission Frame"] = "Clicca per ridurre/ingrandire il pannello Missioni"
L["Click to toggle Help page"] = "Clicca per aprire/chiudere l'aiuto"
L["Consider again"] = "Prendi in considerazione di nuovo"
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "Disabilita la popolazione automatica della pagina di missione. Puoi anche tenere premuto ctrl mentre clicchi il pulsante missione per non popolare quella specifica missione"
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "Disabilitando questo avrete la vecchia interfaccia (1.1.8). Verr\195\160 effettuato un reload dell' interfaccia"
L["Do not prefill mission page"] = "Non prepolare la pagina di missione"
L["Ignore for all missions"] = "Ignora per tutte le missioni"
L["Ignore for this mission"] = "Ignore per questa missione"
L["Ignore \"maxed\" followers"] = "Ignora i seguaci \"maxati\""
L["Left Click to see available missions"] = "Clicca colo sinistro per vedere le missioni disponibili"
L["Level 100 epic followers are not used for match making unless they are needed to fill up the roster."] = "I seguaci di livello 100 e qualit\195\160 epica verranno usati solo se indispensabili per completare il party."
L["Minimun chance success under which ignore missions"] = "Chance di successo minima sotto cui ignorare le missioni"
L["Mission shown for follower"] = "Numero di missioni mostrato per seguace"
L["Must reload interface to apply"] = "E' necessario ricaricare l'interfaccia per applicarlo"
L["Number of followers"] = "Numero di seguaci"
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "Vengono mostrare solo le prime %1$d missions con una speranza di successo supseriore al %2$d%%"
L["Original method"] = "Ordinamento originale"
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = "Ripristina il metodo di ordinamento originale, Se avete un altro addon che oridna le missioni, sara\195\160 questo addon a agestirlo."
L["Other useful followers"] = "Altri seguagi che possono aiutare"
L["Right click to open ignore menu"] = "Clicca col destro per aprire il menu di ignora"
L["Sort missions by:"] = "Ordina le missioni per:"
L["Success Chance"] = "Probabilit\195\160 di successo"
L["Switches between Garrison Commander and Master Plan mission interface. Tested with MP 0.20.x"] = "Permette di scegliere fra l'interfaccia di Garrison Commander e quella di Master Plan per la schermata delle missioni. Testato con MP 0.20"
L["Unlock Panel"] = "Sblocca il pannello"
L["Use big screen"] = "Utilizza il pannello ingrandito"
L["Use GC Interface"] = "Usa l'interfaccia di GC"
L["You have ignored followers"] = "Hai seguaci ignorati"

return
end
L=l:NewLocale(me,"koKR")
if (L) then
-- L["Click to toggle Garrison Mission Frame"] = ""
-- L["Click to toggle Help page"] = ""
-- L["Consider again"] = ""
-- L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = ""
-- L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = ""
-- L["Do not prefill mission page"] = ""
-- L["Ignore for all missions"] = ""
-- L["Ignore for this mission"] = ""
-- L["Ignore \"maxed\" followers"] = ""
-- L["Left Click to see available missions"] = ""
-- L["Level 100 epic followers are not used for match making unless they are needed to fill up the roster."] = ""
-- L["Minimun chance success under which ignore missions"] = ""
-- L["Mission shown for follower"] = ""
-- L["Must reload interface to apply"] = ""
-- L["Number of followers"] = ""
-- L["Only first %1$d missions with over %2$d%% chance of success are shown"] = ""
-- L["Original method"] = ""
-- L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = ""
-- L["Other useful followers"] = ""
-- L["Right click to open ignore menu"] = ""
-- L["Sort missions by:"] = ""
-- L["Success Chance"] = ""
-- L["Switches between Garrison Commander and Master Plan mission interface. Tested with MP 0.20.x"] = ""
-- L["Unlock Panel"] = ""
-- L["Use big screen"] = ""
-- L["Use GC Interface"] = ""
-- L["You have ignored followers"] = ""

return
end
L=l:NewLocale(me,"esMX")
if (L) then
-- L["Click to toggle Garrison Mission Frame"] = ""
-- L["Click to toggle Help page"] = ""
-- L["Consider again"] = ""
-- L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = ""
-- L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = ""
-- L["Do not prefill mission page"] = ""
-- L["Ignore for all missions"] = ""
-- L["Ignore for this mission"] = ""
-- L["Ignore \"maxed\" followers"] = ""
-- L["Left Click to see available missions"] = ""
-- L["Level 100 epic followers are not used for match making unless they are needed to fill up the roster."] = ""
-- L["Minimun chance success under which ignore missions"] = ""
-- L["Mission shown for follower"] = ""
-- L["Must reload interface to apply"] = ""
-- L["Number of followers"] = ""
-- L["Only first %1$d missions with over %2$d%% chance of success are shown"] = ""
-- L["Original method"] = ""
-- L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = ""
-- L["Other useful followers"] = ""
-- L["Right click to open ignore menu"] = ""
-- L["Sort missions by:"] = ""
-- L["Success Chance"] = ""
-- L["Switches between Garrison Commander and Master Plan mission interface. Tested with MP 0.20.x"] = ""
-- L["Unlock Panel"] = ""
-- L["Use big screen"] = ""
-- L["Use GC Interface"] = ""
-- L["You have ignored followers"] = ""

return
end
L=l:NewLocale(me,"ruRU")
if (L) then
-- L["Click to toggle Garrison Mission Frame"] = ""
-- L["Click to toggle Help page"] = ""
-- L["Consider again"] = ""
-- L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = ""
-- L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = ""
-- L["Do not prefill mission page"] = ""
-- L["Ignore for all missions"] = ""
-- L["Ignore for this mission"] = ""
-- L["Ignore \"maxed\" followers"] = ""
-- L["Left Click to see available missions"] = ""
-- L["Level 100 epic followers are not used for match making unless they are needed to fill up the roster."] = ""
-- L["Minimun chance success under which ignore missions"] = ""
-- L["Mission shown for follower"] = ""
-- L["Must reload interface to apply"] = ""
-- L["Number of followers"] = ""
-- L["Only first %1$d missions with over %2$d%% chance of success are shown"] = ""
-- L["Original method"] = ""
-- L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = ""
-- L["Other useful followers"] = ""
-- L["Right click to open ignore menu"] = ""
-- L["Sort missions by:"] = ""
-- L["Success Chance"] = ""
-- L["Switches between Garrison Commander and Master Plan mission interface. Tested with MP 0.20.x"] = ""
-- L["Unlock Panel"] = ""
-- L["Use big screen"] = ""
-- L["Use GC Interface"] = ""
-- L["You have ignored followers"] = ""

return
end
L=l:NewLocale(me,"zhCN")
if (L) then
-- L["Click to toggle Garrison Mission Frame"] = ""
-- L["Click to toggle Help page"] = ""
-- L["Consider again"] = ""
-- L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = ""
-- L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = ""
-- L["Do not prefill mission page"] = ""
-- L["Ignore for all missions"] = ""
-- L["Ignore for this mission"] = ""
-- L["Ignore \"maxed\" followers"] = ""
-- L["Left Click to see available missions"] = ""
-- L["Level 100 epic followers are not used for match making unless they are needed to fill up the roster."] = ""
-- L["Minimun chance success under which ignore missions"] = ""
-- L["Mission shown for follower"] = ""
-- L["Must reload interface to apply"] = ""
-- L["Number of followers"] = ""
-- L["Only first %1$d missions with over %2$d%% chance of success are shown"] = ""
-- L["Original method"] = ""
-- L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = ""
-- L["Other useful followers"] = ""
-- L["Right click to open ignore menu"] = ""
-- L["Sort missions by:"] = ""
-- L["Success Chance"] = ""
-- L["Switches between Garrison Commander and Master Plan mission interface. Tested with MP 0.20.x"] = ""
-- L["Unlock Panel"] = ""
-- L["Use big screen"] = ""
-- L["Use GC Interface"] = ""
-- L["You have ignored followers"] = ""

return
end
L=l:NewLocale(me,"esES")
if (L) then
-- L["Click to toggle Garrison Mission Frame"] = ""
-- L["Click to toggle Help page"] = ""
-- L["Consider again"] = ""
-- L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = ""
-- L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = ""
-- L["Do not prefill mission page"] = ""
-- L["Ignore for all missions"] = ""
-- L["Ignore for this mission"] = ""
-- L["Ignore \"maxed\" followers"] = ""
-- L["Left Click to see available missions"] = ""
-- L["Level 100 epic followers are not used for match making unless they are needed to fill up the roster."] = ""
-- L["Minimun chance success under which ignore missions"] = ""
-- L["Mission shown for follower"] = ""
-- L["Must reload interface to apply"] = ""
-- L["Number of followers"] = ""
-- L["Only first %1$d missions with over %2$d%% chance of success are shown"] = ""
-- L["Original method"] = ""
-- L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = ""
-- L["Other useful followers"] = ""
-- L["Right click to open ignore menu"] = ""
-- L["Sort missions by:"] = ""
-- L["Success Chance"] = ""
-- L["Switches between Garrison Commander and Master Plan mission interface. Tested with MP 0.20.x"] = ""
-- L["Unlock Panel"] = ""
-- L["Use big screen"] = ""
-- L["Use GC Interface"] = ""
-- L["You have ignored followers"] = ""

return
end
L=l:NewLocale(me,"zhTW")
if (L) then
L["Click to toggle Garrison Mission Frame"] = "\233\187\158\230\147\138\228\190\134\229\136\135\230\143\155\232\166\129\229\161\158\228\187\187\229\139\153\232\166\150\231\170\151"
L["Click to toggle Help page"] = "\233\187\158\230\147\138\229\136\135\230\143\155\229\185\171\229\138\169\233\160\129"
L["Consider again"] = "\229\134\141\230\172\161\232\128\131\233\135\143"
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "\229\143\150\230\182\136\232\135\170\229\139\149\229\136\134\230\180\190\229\156\168\228\187\187\229\139\153\233\160\129\231\175\169\233\129\184\227\128\130\230\130\168\228\185\159\229\143\175\228\187\165\229\156\168\229\150\174\228\184\128\228\187\187\229\139\153\228\184\138\233\187\158\230\147\138Ctrl\228\190\134\229\143\150\230\182\136\227\128\130"
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "\229\143\150\230\182\136\230\173\164\230\156\131\231\181\166\230\130\1681.1.8\228\187\165\228\190\134\231\154\132\228\187\139\233\157\162\239\188\140\231\181\166\228\186\136\230\136\150\229\143\150\229\190\151\227\128\130\233\156\128\232\166\129\233\135\141\232\188\137UI\227\128\130"
L["Do not prefill mission page"] = "\228\184\141\232\166\129\233\160\144\229\133\136\229\161\171\229\133\133\228\187\187\229\139\153\233\160\129"
L["Ignore for all missions"] = "\229\191\189\231\149\165\230\137\128\230\156\137\228\187\187\229\139\153"
L["Ignore for this mission"] = "\229\191\189\231\149\165\230\173\164\228\187\187\229\139\153"
L["Ignore \"maxed\" followers"] = "\229\191\189\231\149\165 \"\229\183\178\229\176\129\233\160\130\"\231\154\132\232\191\189\233\154\168\232\128\133"
L["Left Click to see available missions"] = "\229\183\166\233\141\181\233\187\158\230\147\138\228\187\165\230\170\162\232\166\150\229\143\175\231\148\168\228\187\187\229\139\153"
L["Level 100 epic followers are not used for match making unless they are needed to fill up the roster."] = "\231\173\137\231\180\154100\231\154\132\231\180\171\232\137\178\232\191\189\233\154\168\232\128\133\228\184\141\230\156\131\228\189\191\231\148\168\229\156\168\228\187\187\229\139\153\230\144\173\233\133\141\228\184\138\239\188\140\233\153\164\233\157\158\233\154\138\228\188\141\233\153\163\229\174\185\233\156\128\232\166\129\228\187\150\229\128\145\228\190\134\229\161\171\230\187\191\227\128\130"
L["Minimun chance success under which ignore missions"] = "\228\189\142\230\150\188\229\164\154\229\176\145\230\136\144\229\138\159\230\169\159\231\142\135\231\154\132\228\187\187\229\139\153\232\166\129\232\162\171\229\191\189\231\149\165"
L["Mission shown for follower"] = "\228\187\187\229\139\153\228\184\138\233\161\175\231\164\186\232\191\189\233\154\168\232\128\133"
L["Must reload interface to apply"] = "\233\156\128\232\166\129\233\135\141\232\188\137UI\228\187\165\231\148\159\230\149\136"
L["Number of followers"] = "\232\191\189\233\154\168\232\128\133\230\149\184\233\135\143"
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "\229\143\170\230\156\137\233\171\152\230\150\188%2$d%%\230\136\144\229\138\159\230\169\159\231\142\135\231\154\132\229\137\141%1$d\228\187\187\229\139\153\230\156\131\233\161\175\231\164\186"
L["Original method"] = "\229\142\159\229\167\139\231\154\132\230\150\185\230\179\149"
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = "\229\142\159\229\167\139\230\142\146\229\186\143\229\176\135\230\129\162\229\190\169\229\142\159\229\167\139\230\142\146\229\186\143\230\150\185\230\179\149\239\188\140\228\184\141\231\174\161\229\174\131\230\152\175\228\187\128\233\186\188(\229\166\130\230\158\156\228\189\160\230\156\137\229\143\166\228\184\128\229\128\139\230\143\146\228\187\182\230\142\146\229\186\143\228\187\187\229\139\153\239\188\140\229\174\131\230\135\137\232\169\178\229\134\141\229\149\159\229\139\149)"
L["Other useful followers"] = "\229\133\182\228\187\150\230\156\137\231\148\168\231\154\132\232\191\189\233\154\168\232\128\133"
L["Right click to open ignore menu"] = "\229\143\179\233\141\181\233\187\158\230\147\138\228\187\165\233\150\139\229\149\159\229\191\189\231\149\165\233\129\184\229\150\174"
L["Sort missions by:"] = "\230\142\146\229\186\143\228\187\187\229\139\153\228\190\157\230\147\154\239\188\154"
L["Success Chance"] = "\230\136\144\229\138\159\230\169\159\231\142\135"
L["Switches between Garrison Commander and Master Plan mission interface. Tested with MP 0.20.x"] = "\229\156\168Garrison Commander\232\136\135Master Plan\231\154\132\228\187\187\229\139\153\228\187\139\233\157\162\233\150\147\229\136\135\230\143\155\227\128\130\229\183\178\230\184\172\232\169\166\229\156\168MP 0.20.X"
L["Unlock Panel"] = "\232\167\163\233\142\150\233\157\162\230\157\191"
L["Use big screen"] = "\228\189\191\231\148\168\229\164\167\232\158\162\229\185\149"
L["Use GC Interface"] = "\228\189\191\231\148\168GC\228\187\139\233\157\162"
L["You have ignored followers"] = "\230\130\168\230\156\137\229\191\189\231\149\165\231\154\132\232\191\189\233\154\168\232\128\133"

return
end
