local LibStub=LibStub
local MAJOR_VERSION="LibInit"
local libinit,MINOR_VERSION = LibStub("LibInit")
if not libinit then return end
local me=MAJOR_VERSION .. MINOR_VERSION
local l=LibStub("AceLocale-3.0")
local L=l:NewLocale(me,"enUS",true,true)
if L then
L["Configuration"] = "Configuration"
L["Description"] = "Description"
L["Libraries"] = "Libraries"
L["Profile"] = "Profile"
L["Purge_Desc"] = "You can delete all unused profiles with just one click"
L["Purge1"] = "Delete unused profiles"
L["Purge2"] = "Deletes all profiles that are not used by a character"
L["Release Notes"] = "Release Notes"
L["Toggles"] = "Toggles"
L["UseDefault_Desc"] = "You can force all your characters to use the \"%s\" profile in order to manage a single configuration"
L["UseDefault1"] = "Switch all characters to \"%s\" profile"
L["UseDefault2"] = "Uses the \"%s\" profiles for all your toons"
end
L=l:NewLocale(me,'ptBR')
if L then
L["Configuration"] = "configura\195\167\195\163o"
L["Description"] = "Descri\195\167\195\163o"
L["Libraries"] = "bibliotecas"
L["Profile"] = "Perfil"
L["Purge_Desc"] = "Voc\195\170 pode apagar todos os perfis n\195\163o utilizados com apenas um clique"
L["Purge1"] = "Excluir perfis n\195\163o utilizados"
L["Purge2"] = "Exclui todos os perfis que n\195\163o s\195\163o utilizados por um personagem"
L["Release Notes"] = "Notas de Lan\195\167amento"
L["Toggles"] = "Alterna"
L["UseDefault_Desc"] = "Voc\195\170 pode for\195\167ar todos os seus personagens para usar a \"% s\" perfil a fim de gerir uma \195\186nica configura\195\167\195\163o"
L["UseDefault1"] = "Mudar todos os caracteres para \"% s\" perfil"
L["UseDefault2"] = "Usa a \"% s\" perfis para todos os seus personagens"
end
L=l:NewLocale(me,'frFR')
if L then
L["Configuration"] = "configuration"
L["Description"] = "description"
L["Libraries"] = "biblioth\195\168ques"
L["Profile"] = "Profil"
L["Purge_Desc"] = "Vous pouvez supprimer tous les profils inutilis\195\169s en un seul clic"
L["Purge1"] = "Supprimer les profils inutilis\195\169s"
L["Purge2"] = "Supprime tous les profils qui ne sont pas utilis\195\169s par un caract\195\168re"
L["Release Notes"] = "notes de version"
L["Toggles"] = "Bascule"
L["UseDefault_Desc"] = "Vous pouvez forcer tous vos personnages \195\160 utiliser le profil du \"%s\" dans le but de g\195\169rer une configuration unique"
L["UseDefault1"] = "Mettez tous les caract\195\168res au profil \"%s\""
L["UseDefault2"] = "Utilise les profils du \"%s\" pour tous vos personnages"
end
L=l:NewLocale(me,'deDE')
if L then
L["Configuration"] = "Konfiguration"
L["Description"] = "Beschreibung"
L["Libraries"] = "Bibliotheken"
L["Profile"] = "Profil"
L["Purge_Desc"] = "Sie k\195\182nnen mit nur einem Klick alle nicht verwendeten Profile l\195\182schen"
L["Purge1"] = "L\195\182schen Sie nicht ben\195\182tigte Profile"
L["Purge2"] = "L\195\182scht alle Profile, die nicht von einem Charakter benutzt werden"
L["Release Notes"] = "Versionshinweise"
L["Toggles"] = "Schaltet"
L["UseDefault_Desc"] = "Sie k\195\182nnen alle Ihre Charaktere dazu zwingen, das Profil \"%s\" zu verwenden, um eine einzelne Konfiguration zu verwalten"
L["UseDefault1"] = "Alle Charaktere auf das Profil \"%s\" umschalten"
L["UseDefault2"] = "Verwendet die Profile \"%s\" f\195\188r alle Toons"
end
L=l:NewLocale(me,'itIT')
if L then
L["Configuration"] = "Configurazione"
L["Description"] = "Descrizione"
L["Libraries"] = "Librerie"
L["Profile"] = "Profilo"
L["Purge_Desc"] = "Puoi cancellare tutti i profili inutilizzati con un singolo click"
L["Purge1"] = "Cancella i profili inutilizzati"
L["Purge2"] = "Cancella tutti i profili che non sono usati da un personaggio"
L["Release Notes"] = "Note di rilascio"
L["Toggles"] = "Interruttori"
L["UseDefault_Desc"] = "Puoi far usare a tutti i tuoi personaggi il profilo \"%s\""
L["UseDefault1"] = "Imposta il profilo \"%s\" su tutti i personaggi"
L["UseDefault2"] = "Usa il profilo '%s\" per tutti i personaggi"
end
L=l:NewLocale(me,'koKR')
if L then
L["Configuration"] = "\234\181\172\236\132\177"
L["Description"] = "\236\132\164\235\170\133"
L["Libraries"] = "\235\157\188\236\157\180\235\184\140\235\159\172\235\166\172"
L["Profile"] = "\236\156\164\234\179\189"
L["Purge_Desc"] = "\235\139\185\236\139\160\236\157\128 \237\149\156 \235\178\136\236\157\152 \237\129\180\235\166\173\236\156\188\235\161\156 \235\170\168\235\147\160 \236\130\172\236\154\169\235\144\152\236\167\128 \236\149\138\236\157\128 \237\148\132\235\161\156\237\149\132\236\157\132 \236\130\173\236\160\156\237\149\160 \236\136\152 \236\158\136\236\138\181\235\139\136\235\139\164"
L["Purge1"] = "\236\130\172\236\154\169\237\149\152\236\167\128 \236\149\138\235\138\148 \237\148\132\235\161\156\237\149\132\236\157\132 \236\130\173\236\160\156"
L["Purge2"] = "\235\172\184\236\158\144\234\176\128 \236\130\172\236\154\169\235\144\152\236\167\128 \236\149\138\236\157\128 \235\170\168\235\147\160 \237\148\132\235\161\156\237\140\140\236\157\188\236\157\132 \236\130\173\236\160\156\237\149\169\235\139\136\235\139\164"
L["Release Notes"] = "\235\166\180\235\166\172\236\138\164 \235\133\184\237\138\184"
L["Toggles"] = "\236\160\132\237\153\152"
L["UseDefault_Desc"] = "\235\139\168\236\157\188 \234\181\172\236\132\177\236\157\132 \234\180\128\235\166\172\237\149\152\234\184\176 \236\156\132\237\149\180 \"% s\"\237\148\132\235\161\156\237\140\140\236\157\188\236\157\132 \236\130\172\236\154\169\237\149\152\236\151\172 \235\170\168\235\147\160 \235\172\184\236\158\144\235\165\188 \234\176\149\236\160\156"
L["UseDefault1"] = "\"%s\"\237\148\132\235\161\156\237\149\132\236\151\144 \235\170\168\235\147\160 \235\172\184\236\158\144\235\165\188 \236\160\132\237\153\152"
L["UseDefault2"] = "\235\170\168\235\147\160 \235\172\184\236\158\144\236\151\144 \235\140\128\237\149\180 \"%s\"\237\148\132\235\161\156\237\140\140\236\157\188\236\157\132 \236\130\172\236\154\169\237\149\152\236\151\172"
end
L=l:NewLocale(me,'esMX')
if L then
L["Configuration"] = "Configuraci\195\179n,"
L["Description"] = "Descripci\195\179n,"
L["Libraries"] = "bibliotecas,"
L["Profile"] = "Perfil,"
L["Purge_Desc"] = "Puede eliminar todos los perfiles utilizados con s\195\179lo un clic"
L["Purge1"] = "Eliminar los perfiles no utilizados"
L["Purge2"] = "Elimina todos los perfiles que no sean utilizadas por un personaje"
L["Release Notes"] = "Notas de la versi\195\179n"
L["Toggles"] = "Alterna"
L["UseDefault_Desc"] = "Puede forzar a todos tus personajes para usar el perfil \"%s\" con el fin de administrar una sola configuraci\195\179n"
L["UseDefault1"] = "Cambiar todos los caracteres de perfil \"%s\""
L["UseDefault2"] = "Utiliza los perfiles de la \"%s\" para todos sus caracteres"
end
L=l:NewLocale(me,'ruRU')
if L then
L["Configuration"] = "\208\154\208\190\208\189\209\132\208\184\208\179\209\131\209\128\208\176\209\134\208\184\209\143,"
L["Description"] = "\208\158\208\191\208\184\209\129\208\176\208\189\208\184\208\181,"
L["Libraries"] = "\208\145\208\184\208\177\208\187\208\184\208\190\209\130\208\181\208\186\208\184,"
L["Profile"] = "\208\159\209\128\208\190\209\132\208\184\208\187\209\140,"
L["Purge_Desc"] = "\208\156\208\190\208\182\208\189\208\190 \209\131\208\180\208\176\208\187\208\184\209\130\209\140 \208\178\209\129\208\181 \208\189\208\181\208\184\209\129\208\191\208\190\208\187\209\140\208\183\209\131\208\181\208\188\209\139\208\181 \208\191\209\128\208\190\209\132\208\184\208\187\208\184 \209\129 \208\191\208\190\208\188\208\190\209\137\209\140\209\142 \208\178\209\129\208\181\208\179\208\190 \208\190\208\180\208\189\208\190\208\179\208\190 \208\186\208\187\208\184\208\186\208\176"
L["Purge1"] = "\208\163\208\180\208\176\208\187\208\181\208\189\208\184\208\181 \208\189\208\181\208\184\209\129\208\191\208\190\208\187\209\140\208\183\209\131\208\181\208\188\209\139\209\133 \208\191\209\128\208\190\209\132\208\184\208\187\208\181\208\185"
L["Purge2"] = "\208\163\208\180\208\176\208\187\209\143\208\181\209\130 \208\178\209\129\208\181 \208\191\209\128\208\190\209\132\208\184\208\187\208\184, \208\186\208\190\209\130\208\190\209\128\209\139\208\181 \208\189\208\181 \208\184\209\129\208\191\208\190\208\187\209\140\208\183\209\131\209\142\209\130\209\129\209\143 \208\191\208\181\209\128\209\129\208\190\208\189\208\176\208\182\208\181\208\188"
L["Release Notes"] = "\208\159\209\128\208\184\208\188\208\181\209\135\208\176\208\189\208\184\209\143 \208\186 \208\178\209\139\208\191\209\131\209\129\208\186\209\131"
L["Toggles"] = "\208\146\208\186\208\187\209\142\209\135\208\181\208\189\208\184\208\181 \208\184\208\187\208\184 \208\178\209\139\208\186\208\187\209\142\209\135\208\181\208\189\208\184\208\181"
L["UseDefault_Desc"] = "\208\146\209\139 \208\188\208\190\208\182\208\181\209\130\208\181 \208\183\208\176\209\129\209\130\208\176\208\178\208\184\209\130\209\140 \208\178\209\129\208\181 \209\129\208\184\208\188\208\178\208\190\208\187\209\139 \208\184\209\129\208\191\208\190\208\187\209\140\208\183\208\190\208\178\208\176\209\130\209\140 \"%s\" \208\191\209\128\208\190\209\132\208\184\208\187\209\140 \208\180\208\187\209\143 \209\130\208\190\208\179\208\190, \209\135\209\130\208\190\208\177\209\139 \209\131\208\191\209\128\208\176\208\178\208\187\209\143\209\130\209\140 \208\190\208\180\208\189\208\190\208\185 \208\186\208\190\208\189\209\132\208\184\208\179\209\131\209\128\208\176\209\134\208\184\208\184"
L["UseDefault1"] = "\208\146\208\186\208\187\209\142\209\135\208\184\209\130\208\181 \208\178\209\129\208\181 \209\129\208\184\208\188\208\178\208\190\208\187\209\139 \"%s\" \208\191\209\128\208\190\209\132\208\184\208\187\209\140"
L["UseDefault2"] = "\208\152\209\129\208\191\208\190\208\187\209\140\208\183\209\131\208\181\209\130 \"%s\" \208\191\209\128\208\190\209\132\208\184\208\187\208\184 \208\180\208\187\209\143 \208\178\209\129\208\181\209\133 \208\178\208\176\209\136\208\184\209\133 \208\191\208\181\209\128\209\129\208\190\208\189\208\176\208\182\208\181\208\185"
end
L=l:NewLocale(me,'zhCN')
if L then
L["Configuration"] = "\231\187\132\230\128\129\239\188\140"
L["Description"] = "\230\143\143\232\191\176\239\188\140"
L["Libraries"] = "\229\155\190\228\185\166\233\166\134\239\188\140"
L["Profile"] = "\228\184\170\228\186\186\232\181\132\230\150\153\239\188\140"
L["Purge_Desc"] = "\230\130\168\229\143\175\228\187\165\229\136\160\233\153\164\230\137\128\230\156\137\230\156\170\228\189\191\231\148\168\231\154\132\233\133\141\231\189\174\230\150\135\228\187\182\239\188\140\229\143\170\233\156\128\231\130\185\229\135\187\228\184\128\228\184\139"
L["Purge1"] = "\229\136\160\233\153\164\230\156\170\228\189\191\231\148\168\231\154\132\233\133\141\231\189\174\230\150\135\228\187\182"
L["Purge2"] = "\229\136\160\233\153\164\230\156\170\228\189\191\231\148\168\231\154\132\229\173\151\231\172\166\230\137\128\230\156\137\233\133\141\231\189\174\230\150\135\228\187\182"
L["Release Notes"] = "\229\143\145\232\161\140\232\175\180\230\152\142"
L["Toggles"] = "\229\136\135\230\141\162"
L["UseDefault_Desc"] = "\230\130\168\229\143\175\228\187\165\229\188\186\229\136\182\230\137\128\230\156\137\232\167\146\232\137\178\228\189\191\231\148\168\226\128\156\239\188\133s\226\128\157\231\154\132\228\184\170\228\186\186\232\181\132\230\150\153\239\188\140\228\187\165\231\174\161\231\144\134\228\184\128\228\184\170\229\141\149\228\184\128\231\154\132\233\133\141\231\189\174"
L["UseDefault1"] = "\228\186\164\230\141\162\230\156\186\231\154\132\230\137\128\230\156\137\229\173\151\231\172\166\226\128\156\239\188\133s\226\128\157\231\154\132\228\184\170\228\186\186\232\181\132\230\150\153"
L["UseDefault2"] = "\228\189\191\231\148\168\226\128\156\239\188\133s\226\128\157\230\155\178\231\186\191\231\154\132\230\137\128\230\156\137\232\167\146\232\137\178"
end
L=l:NewLocale(me,'esES')
if L then
L["Configuration"] = "Configuraci\195\179n,"
L["Description"] = "Descripci\195\179n,"
L["Libraries"] = "bibliotecas,"
L["Profile"] = "Perfil,"
L["Purge_Desc"] = "Puede eliminar todos los perfiles utilizados con s\195\179lo un clic"
L["Purge1"] = "Eliminar los perfiles no utilizados"
L["Purge2"] = "Elimina todos los perfiles que no sean utilizadas por un personaje"
L["Release Notes"] = "Notas de la versi\195\179n"
L["Toggles"] = "Alterna"
L["UseDefault_Desc"] = "Puede forzar a todos tus personajes para usar el perfil \"%s\" con el fin de administrar una sola configuraci\195\179n"
L["UseDefault1"] = "Cambiar todos los caracteres de perfil \"%s\""
L["UseDefault2"] = "Utiliza los perfiles de la \"%s\" para todos sus caracteres"
end
L=l:NewLocale(me,'zhTW')
if L then
--[[Translation missing --]]
L["%1$d%% lower than %2$d%%. Lower %s"] = "%1$d%% lower than %2$d%%. Lower %s"
--[[Translation missing --]]
L[ [=[%1$s and %2$s switches work together to customize how you want your mission filled

The value you set for %1$s (right now %3$s%%) is the minimum acceptable chance for attempting to achieve bonus while the value to set for %2$s (right now %4$s%%) is the chance you want achieve when you are forfaiting bonus (due to not enough powerful followers)]=] ] = [=[%1$s and %2$s switches work together to customize how you want your mission filled

The value you set for %1$s (right now %3$s%%) is the minimum acceptable chance for attempting to achieve bonus while the value to set for %2$s (right now %4$s%%) is the chance you want achieve when you are forfaiting bonus (due to not enough powerful followers)]=]
L["%s |4follower:followers; with %s"] = "%s |4seguace:seguaci; con %s"
--[[Translation missing --]]
L["%s for a wowhead link popup"] = "%s for a wowhead link popup"
--[[Translation missing --]]
L["%s no longer blacklist missions"] = "%s no longer blacklist missions"
--[[Translation missing --]]
L["%s start the mission without even opening the mission page. No question asked"] = "%s start the mission without even opening the mission page. No question asked"
--[[Translation missing --]]
L["%s to actually start mission"] = "%s to actually start mission"
--[[Translation missing --]]
L["%s to blacklist"] = "%s to blacklist"
--[[Translation missing --]]
L["%s to remove from blacklist"] = "%s to remove from blacklist"
--[[Translation missing --]]
L[ [=[%s, please review the tutorial
(Click the icon to dismiss this message and start the tutorial)]=] ] = [=[%s, please review the tutorial
(Click the icon to dismiss this message and start the tutorial)]=]
L["(Ignores low bias ones)"] = "(Ignorati i seguaci di livello basso)"
--[[Translation missing --]]
L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = [=[A requested window is not open
Tutorial will resume as soon as possible]=]
L["Add %1$d levels to %2$s"] = "Aggiunge %1$d livelli a %2$s"
L["Adds a list of other useful followers to tooltip"] = "Aggiunge altri seguaci utili al tooltip"
L["Affects only little screen mode, hiding the per follower mission list if not checked"] = "Si applica solo alla modalità dimensioni native, nascode la lista missioni per seguace se inattivo"
L["Allowed Rewards"] = "Ricompense ammesse"
L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = "Accetta una minor percentuale di successo per le missioni che danno risorse. Con /gac gui puoi cambiare la percentuale (deault 80%)"
--[[Translation missing --]]
L["Always counter increased resource cost"] = "Always counter increased resource cost"
--[[Translation missing --]]
L["Always counter increased time"] = "Always counter increased time"
--[[Translation missing --]]
L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = "Always counter kill troops (ignored if we can only use troops with just 1 durability left)"
--[[Translation missing --]]
L["Always counter no bonus loot threat"] = "Always counter no bonus loot threat"
--[[Translation missing --]]
L["Analyze parties"] = "Analyze parties"
--[[Translation missing --]]
L["and then by:"] = "and then by:"
L["Applied when 'maximize result' is enabled. Default is 80%"] = "Si applica quando 'massimizza risultato' è abilitato. Default 80%"
L["Applies the best armor set"] = "Applica il miglior set di armatura"
L["Applies the best armor upgrade"] = "Applica il miglior incremento di armatura"
L["Applies the best weapon set"] = "Applica il miglior set di armi"
L["Applies the best weapon upgrade"] = "Applica il milgior incremento di armi"
L["Archaelogy"] = "Archeologia"
--[[Translation missing --]]
L["Artifact shown value is the base value without considering knowledge multiplier"] = "Artifact shown value is the base value without considering knowledge multiplier"
--[[Translation missing --]]
L["Attempting %s"] = "Attempting %s"
--[[Translation missing --]]
L["Base Chance"] = "Base Chance"
--[[Translation missing --]]
L["Better parties available in next future"] = "Better parties available in next future"
L["Big screen"] = "Pannello grande"
L["Blacklisted"] = "Blacklistato"
L["Blacklisted missions are ignored in Mission Control"] = "Le missioni blacklistate vengono ignorate in Controllo Missione"
--[[Translation missing --]]
L["Bonus Chance"] = "Bonus Chance"
L["Building Final report"] = "Preparo il report finale"
--[[Translation missing --]]
L["but using troops with just one durability left"] = "but using troops with just one durability left"
--[[Translation missing --]]
L["Capped"] = "Capped"
L["Capped %1$s. Spend at least %2$d of them"] = "Limitato a %1$s. Spendine almeno %2$d"
--[[Translation missing --]]
L["Changes the second sort order of missions in Mission panel"] = "Changes the second sort order of missions in Mission panel"
--[[Translation missing --]]
L["Changes the sort order of missions in Mission panel"] = "Changes the sort order of missions in Mission panel"
--[[Translation missing --]]
L[ [=[Clicking a party button will assign its followers to the current mission.
Use it to verify OHC calculated chance with Blizzard one.
If they differs please take a screenshot and open a ticket :).]=] ] = [=[Clicking a party button will assign its followers to the current mission.
Use it to verify OHC calculated chance with Blizzard one.
If they differs please take a screenshot and open a ticket :).]=]
--[[Translation missing --]]
L["Combat ally is proposed for missions so you can consider unassigning him"] = "Combat ally is proposed for missions so you can consider unassigning him"
L["Complete all missions without confirmation"] = "Completa tutte le mission senza conferme"
--[[Translation missing --]]
L["Configuration for mission party builder"] = "Configuration for mission party builder"
L["Consider again"] = "Prendi in considerazione di nuovo"
--[[Translation missing --]]
L["Cost reduced"] = "Cost reduced"
--[[Translation missing --]]
L["Could not fulfill mission, aborting"] = "Could not fulfill mission, aborting"
--[[Translation missing --]]
L["Counter kill Troops"] = "Counter kill Troops"
--[[Translation missing --]]
L["Customization options (non mission related)"] = "Customization options (non mission related)"
--[[Translation missing --]]
L["Disable blacklisting"] = "Disable blacklisting"
L["Disable if you dont want the full Garrison Commander Header."] = "Disabilita se vuoi la testata completa di Garrison Commander"
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "Disabilita la popolazione automatica della pagina di missione. Puoi anche tenere premuto ctrl mentre clicchi il pulsante missione per non popolare quella specifica missione"
--[[Translation missing --]]
L["Disables warning: "] = "Disables warning: "
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "Disabilitando questo avrete la vecchia interfaccia (1.1.8). Verrà effettuato un reload dell' interfaccia"
L["Do not show follower icon on plots"] = "Nascondi le icone dei seguaci dalle piazzole"
--[[Translation missing --]]
L["Dont use this slot"] = "Dont use this slot"
--[[Translation missing --]]
L["Don't use troops"] = "Don't use troops"
--[[Translation missing --]]
L["Duration reduced"] = "Duration reduced"
L["Duration Time"] = "Durata"
--[[Translation missing --]]
L["Elite: Prefer overcap"] = "Elite: Prefer overcap"
--[[Translation missing --]]
L["Elites mission mode"] = "Elites mission mode"
--[[Translation missing --]]
L["Empty missions sorted as last"] = "Empty missions sorted as last"
--[[Translation missing --]]
L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = "Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"
L["Enhance tooltip"] = "Migliora il tooltip"
L["Environment Preference"] = "Preferenze Ambientali"
L["Epic followers are NOT sent alone on xp only missions"] = "I seguaci epici NON vengono mandati da soli nelle missioni \"solo pe\""
--[[Translation missing --]]
L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=]
--[[Translation missing --]]
L["Equipped by following champions:"] = "Equipped by following champions:"
L["Expiration Time"] = "Ora di scadenza"
--[[Translation missing --]]
L["Favours leveling follower for xp missions"] = "Favours leveling follower for xp missions"
L["Follower"] = "Seguace"
L["Follower equipment set or upgrade"] = "Milgioramento armi seguace"
L["Follower experience"] = "Esperienza del seguace"
L["Follower set minimum upgrade"] = "Incremento miniimo del seguace"
L["Follower Training"] = "Istruzione seguace"
L["Followers status "] = "Stato del seguace"
--[[Translation missing --]]
L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = "For elite missions, tries hard to not go under 100% even at cost of overcapping"
--[[Translation missing --]]
L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=]
L["Garrison Appearance"] = "Aspetto della Garrison"
L["Garrison Comander Quick Mission Completion"] = "Completamento veloce missioni di Garrison Commander"
L["Garrison Commander Mission Control"] = "Controllo missione di Garrison Commander"
--[[Translation missing --]]
L["General"] = "General"
L["Global approx. xp reward"] = "Pe globali approssimativi"
--[[Translation missing --]]
L["Global approx. xp reward per hour"] = "Global approx. xp reward per hour"
L["Global success chance"] = "Chance globale di successo"
L["Gold incremented!"] = "Oro incrementato!"
--[[Translation missing --]]
L["HallComander Quick Mission Completion"] = "HallComander Quick Mission Completion"
L["Hide followers"] = "Nascondi seguaci"
--[[Translation missing --]]
L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = "If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."
L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = "Se marcato, cliccando un upgrade l'oggetto verrà consumato e il seguace aggiornato |cFFFF0000SENZA CONFERME|r"
L["IF checked, shows armors on the left and weapons on the right "] = "Inverte la posizione di armi e armature"
--[[Translation missing --]]
L["If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"] = "If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"
--[[Translation missing --]]
L["If not checked, inactive followers are used as last chance"] = "If not checked, inactive followers are used as last chance"
--[[Translation missing --]]
L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = [=[If you %s, you will lose them
Click on %s to abort]=]
L["If you continue, you will lose them"] = "Se continui, le perderai"
--[[Translation missing --]]
L[ [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=] ] = [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=]
L["IF you have a Salvage Yard you probably dont want to have this one checked"] = "Se avete il Salvage Yard probabilmente questo non lo volete attivo"
L["Ignore \"maxed\""] = "Ignora \"maxati\""
--[[Translation missing --]]
L["Ignore busy followers"] = "Ignore busy followers"
L["Ignore epic for xp missions."] = "Ignora gli epici per le missioni solo pe"
L["Ignore for all missions"] = "Ignora per tutte le missioni"
L["Ignore for this mission"] = "Ignore per questa missione"
--[[Translation missing --]]
L["Ignore inactive followers"] = "Ignore inactive followers"
L["Ignore rare missions"] = "Ignora le missioni rare"
L["Increased Rewards"] = "Ricompensa Migliorata"
L["Item minimum level"] = "Livello minimo oggetto"
L["Item Tokens"] = "Gettone per oggetti"
--[[Translation missing --]]
L["Keep cost low"] = "Keep cost low"
--[[Translation missing --]]
L["Keep extra bonus"] = "Keep extra bonus"
--[[Translation missing --]]
L["Keep time short"] = "Keep time short"
--[[Translation missing --]]
L["Keep time VERY short"] = "Keep time VERY short"
--[[Translation missing --]]
L[ [=[Launch the first filled mission with at least one locked follower.
Keep SHIFT pressed to actually launch, a simple click will only print mission name with its followers list]=] ] = [=[Launch the first filled mission with at least one locked follower.
Keep SHIFT pressed to actually launch, a simple click will only print mission name with its followers list]=]
L["Left Click to see available missions"] = "Clicca col sinistro per vedere le missioni disponibili"
L["Legendary Items"] = "Oggetti Leggendari"
--[[Translation missing --]]
L["Level"] = "Level"
L["Level 100 epic followers are not used for xp only missions."] = "I seguaci di livello 100 e qualità epica non sono usati per le missioni di soli pe"
--[[Translation missing --]]
L["Lock all"] = "Lock all"
--[[Translation missing --]]
L["Lock this follower"] = "Lock this follower"
--[[Translation missing --]]
L["Locked follower are only used in this mission"] = "Locked follower are only used in this mission"
--[[Translation missing --]]
L["Make Order Hall Mission Panel movable"] = "Make Order Hall Mission Panel movable"
L["Makes main mission panel movable"] = "Rende movibile il pannello principale"
L["Makes shipyard panel movable"] = "Rende movibile il pannello dela Baia"
--[[Translation missing --]]
L["Makes sure that no troops will be killed"] = "Makes sure that no troops will be killed"
--[[Translation missing --]]
L["Max champions"] = "Max champions"
L["Maximize result"] = "Massimizza risultato"
--[[Translation missing --]]
L["Maximize xp gain"] = "Maximize xp gain"
L["Maximum mission duration."] = "Durata massima"
L["Minimum chance"] = "Chance minima"
L["Minimum mission duration."] = "Durata minima"
L["Minimum needed chance"] = "Percentuale minima di successo"
L["Minimum requested level for equipment rewards"] = "Livello minimo richiesto per le ricompense di tipo equipaggiamento"
L["Minimum requested upgrade for followers set (Enhancements are always included)"] = "Livello minimo richiesto per gli upgrade dei followers (I token di miglioramenteo sono sempre inclusi)"
L["Minimun chance success under which ignore missions"] = "Chance di successo minima sotto cui ignorare le missioni"
L["Minumum needed chance"] = "Chance minima richiesta"
L["Mission Control"] = "Controllo Missione"
L["Mission Duration"] = "Durata della Missione"
--[[Translation missing --]]
L["Mission duration reduced"] = "Mission duration reduced"
L["Mission shown"] = "Missione mostrata"
L["Mission shown for follower"] = "Numero di missioni mostrato per seguace"
L["Mission Success"] = "Missione Completata"
L["Mission time reduced!"] = "Durata ridotta!"
--[[Translation missing --]]
L["Mission was capped due to total chance less than"] = "Mission was capped due to total chance less than"
L["Mission with lower success chance will be ignored"] = "Missioni con percentuale di successo inferiore verranno ignorate"
L["Missionlist"] = "Lista Missioni"
--[[Translation missing --]]
L["Missions"] = "Missions"
L["Must reload interface to apply"] = "E' necessario ricaricare l'interfaccia per applicarlo"
--[[Translation missing --]]
L["Never kill Troops"] = "Never kill Troops"
L["No confirmation"] = "Nessuna conferma"
L["No follower gained xp"] = "Nessun seguage ha ottenuto punti esperienza"
L["No mission prefill"] = "Non assegnare alle missioni"
--[[Translation missing --]]
L["No suitable missions. Have you reserved at least one follower?"] = "No suitable missions. Have you reserved at least one follower?"
L["Not blacklisted"] = "Non blacklistata"
--[[Translation missing --]]
L["Not Selected"] = "Not Selected"
L["Nothing to report"] = "Niente da riportare"
--[[Translation missing --]]
L["Notifies you when you have troops ready to be collected"] = "Notifies you when you have troops ready to be collected"
L["Number of followers"] = "Numero di seguaci"
--[[Translation missing --]]
L["Only accept missions with time improved"] = "Only accept missions with time improved"
--[[Translation missing --]]
L["Only consider elite missions"] = "Only consider elite missions"
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "Vengono mostrare solo le prime %1$d missions con una speranza di successo supseriore al %2$d%%"
L["Only meaningful upgrades are shown"] = "Vengono mostrati solo gli upgrade che hanno senso per il seguace corrente"
--[[Translation missing --]]
L["Only need %s instead of %s to start a mission from mission list"] = "Only need %s instead of %s to start a mission from mission list"
--[[Translation missing --]]
L["Only ready"] = "Only ready"
--[[Translation missing --]]
L["Only use champions even if troops are available"] = "Only use champions even if troops are available"
L["Original concept and interface by %s"] = "Concetto originale e interfaccia di %s"
L["Original method"] = "Ordinamento originale"
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = "Ripristina il metodo di ordinamento originale, Se avete un altro addon che oridna le missioni, saraà questo addon a agestirlo."
L["Other"] = "Altro"
L["Other rewards"] = "Atre ricompense"
L["Other settings"] = "Altre impostazioni"
L["Other useful followers"] = "Altri seguagi che possono aiutare"
--[[Translation missing --]]
L["Position is not saved on logout"] = "Position is not saved on logout"
--[[Translation missing --]]
L["Prefer high durability"] = "Prefer high durability"
L["Processing mission %d of %d"] = "Elaboro la missione %d di %d"
L["Profession"] = "Professione"
--[[Translation missing --]]
L["Quick start first mission"] = "Quick start first mission"
L["Racial Preference"] = "Intesa Razziale"
L["Rare missions will not be considered"] = "Le missioni rare non vengono considerate"
L["Reagents"] = "Reagenti"
--[[Translation missing --]]
L["Remove no champions warning"] = "Remove no champions warning"
L["Reputation Items"] = "Item di reputazione"
--[[Translation missing --]]
L["Restart the tutorial"] = "Restart the tutorial"
--[[Translation missing --]]
L["Restart tutorial from beginning"] = "Restart tutorial from beginning"
--[[Translation missing --]]
L["Resume tutorial"] = "Resume tutorial"
--[[Translation missing --]]
L["Resurrect troops effect"] = "Resurrect troops effect"
L["Reward type"] = "Tipo ricompensa"
L["Right-Click to blacklist"] = "Clicca col destro per blacklistare"
L["Right-Click to remove from blacklist"] = "Clicca col destro per rimuovere dalla blacklist"
L["Rush orders"] = "Commissione"
--[[Translation missing --]]
L["See all possible parties for this mission"] = "See all possible parties for this mission"
--[[Translation missing --]]
L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = "Sets all switches to a very permissive setup. Very similar to 1.4.4"
L["Shipyard Appearance"] = "Aspetto della Baia"
L["Show Garrison Commander menu"] = "Mostra il menu di Garrison Commander"
L["Show itemlevel"] = "Mostra il livello degli item"
L["Show upgrades"] = "Mostra miglioramenti"
L["Show xp"] = "Mostrape"
--[[Translation missing --]]
L["Show/hide OrderHallCommander mission menu"] = "Show/hide OrderHallCommander mission menu"
--[[Translation missing --]]
L["Shows only parties with available followers"] = "Shows only parties with available followers"
L["Slayer"] = "Sterminio"
--[[Translation missing --]]
L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=]
L["Some follower"] = "Un seguace"
L["Sort missions by:"] = "Ordina le missioni per:"
--[[Translation missing --]]
L["Started with "] = "Started with "
L["Submit all your mission at once. No question asked."] = "Lancia tutte le missioni con un click. Non chiede conferma"
L["Success Chance"] = "Probabilità di successo"
L["Swap upgrades positions"] = "Inverti la posizione degli upgrades"
L["Switch between Garrison Commander and Master Plan interface for missions"] = "Alterna fra l'interfaccia di Garrison Commander e quella di Master Plan"
--[[Translation missing --]]
L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = "Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"
--[[Translation missing --]]
L["Thank you for reading this, enjoy %s"] = "Thank you for reading this, enjoy %s"
--[[Translation missing --]]
L["There are %d tutorial step you didnt read"] = "There are %d tutorial step you didnt read"
L["Threat Counter"] = "Contrasto Minaccia"
L["To go: %d"] = "Mancano: %d"
L["Toggles Garrison Commander Menu Header on/off"] = "Attiva/disattiva il menu di Garrison Commander"
L["Toys and Mounts"] = "Giocattoli e Cavalcature"
--[[Translation missing --]]
L["Troop ready alert"] = "Troop ready alert"
--[[Translation missing --]]
L["Unable to fill missions, raise \"%s\""] = "Unable to fill missions, raise \"%s\""
--[[Translation missing --]]
L["Unable to fill missions. Check your switches"] = "Unable to fill missions. Check your switches"
--[[Translation missing --]]
L["Unable to start mission, aborting"] = "Unable to start mission, aborting"
--[[Translation missing --]]
L["Uncapped"] = "Uncapped"
L["Unchecking this will allow you to set specific success chance for each reward type"] = "Disabilita per impostare una percentuale specifica di successo per ogni ricompensa"
--[[Translation missing --]]
L["Unlock all"] = "Unlock all"
L["Unlock Panel"] = "Sblocca il pannello"
--[[Translation missing --]]
L["Unlock this follower"] = "Unlock this follower"
--[[Translation missing --]]
L["Unlocks all follower and slots at once"] = "Unlocks all follower and slots at once"
--[[Translation missing --]]
L["Unsafe mission start"] = "Unsafe mission start"
L["Upgrade %1$s to  %2$d itemlevel"] = "Aggiorna %1$s a %2$d itemlevel"
L["Upgrading to |cff00ff00%d|r"] = "Aggiorno a |cff00ff00%d|r"
--[[Translation missing --]]
L["URL Copy"] = "URL Copy"
--[[Translation missing --]]
L["Use at most this many champions"] = "Use at most this many champions"
L["Use big screen"] = "Utilizza il pannello ingrandito"
--[[Translation missing --]]
L["Use combat ally"] = "Use combat ally"
L["Use GC Interface"] = "Usa l'interfaccia di GC"
--[[Translation missing --]]
L["Use this slot"] = "Use this slot"
L["Uses armor token"] = "Usa il token per l'armatura"
--[[Translation missing --]]
L["Uses troops with the highest durability instead of the ones with the lowest"] = "Uses troops with the highest durability instead of the ones with the lowest"
L["Uses weapon token"] = "Usa il token per le armi"
--[[Translation missing --]]
L[ [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=] ] = [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=]
--[[Translation missing --]]
L[ [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=] ] = [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=]
L["When checked, show on each follower button missing xp to next level"] = "Se attivo, su ogni seguace vengono mostrati i pe mancanti al prossimo livello"
L["When checked, show on each follower button weapon and armor level for maxed followers"] = "Se attivo, su ogni seguace viene mostrato l'itemlevel di armi e armatura"
--[[Translation missing --]]
L["When no free followers are available shows empty follower"] = "When no free followers are available shows empty follower"
--[[Translation missing --]]
L["When we cant achieve the requested %1$s, we try to reach at least this one without (if possible) going over 100%%"] = "When we cant achieve the requested %1$s, we try to reach at least this one without (if possible) going over 100%%"
--[[Translation missing --]]
L[ [=[With %1$s you ask to always counter the Hazard kill troop.
This means that OHC will try to counter it OR use a troop with just one durability left.
The target for this switch is to avoid wasting durability point, NOT to avoid troops' death.]=] ] = [=[With %1$s you ask to always counter the Hazard kill troop.
This means that OHC will try to counter it OR use a troop with just one durability left.
The target for this switch is to avoid wasting durability point, NOT to avoid troops' death.]=]
--[[Translation missing --]]
L[ [=[With %2$s you ask to never let a troop die.
This not only implies %1$s and %3$s, but force OHC to never send to mission a troop which will die.
The target for this switch is to totally avoid killing troops, even it for this we cant fill the party]=] ] = [=[With %2$s you ask to never let a troop die.
This not only implies %1$s and %3$s, but force OHC to never send to mission a troop which will die.
The target for this switch is to totally avoid killing troops, even it for this we cant fill the party]=]
--[[Translation missing --]]
L["Would start with "] = "Would start with "
L["XP"] = "PX"
L["Xp incremented!"] = "Pe aumentati!"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "Stai sprecando |cffff0000%d|cffffd200 punti!!!"
L["You can also send mission one by one clicking on each button."] = "Puoi anche inviare le missioni una per una cliccando sui pulsanti"
--[[Translation missing --]]
L[ [=[You can blacklist missions right clicking mission button.
Since 1.5.1 you can start a mission witout passing from mission page shift-clicking the mission button.
Be sure you liked the party because no confirmation is asked]=] ] = [=[You can blacklist missions right clicking mission button.
Since 1.5.1 you can start a mission witout passing from mission page shift-clicking the mission button.
Be sure you liked the party because no confirmation is asked]=]
--[[Translation missing --]]
L["You can choose not to use a troop type clicking its icon"] = "You can choose not to use a troop type clicking its icon"
--[[Translation missing --]]
L[ [=[You can choose to limit how much champions are sent together.
Right now OHC is not using more than %3$s champions in the same mission-

Note that %2$s overrides it.]=] ] = [=[You can choose to limit how much champions are sent together.
Right now OHC is not using more than %3$s champions in the same mission-

Note that %2$s overrides it.]=]
L["You can open the menu clicking on the icon in top right corner"] = "Puoi aprire il menu cliccando l'icona in alto a destra"
L["You have ignored followers"] = "Hai seguaci ignorati"
--[[Translation missing --]]
L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=]
L["You never performed this mission"] = "Non hai mai fatto questa missione"
--[[Translation missing --]]
L["You now need to press both %s and %s to start mission"] = "You now need to press both %s and %s to start mission"
L["You performed this mission %d times with a win ratio of"] = "Hai fatto questa missione %d volde, con una percentuale di successo del"

L["Configuration"] = "\231\181\132\230\133\139\239\188\140"
L["Description"] = "\230\143\143\232\191\176\239\188\140"
L["Libraries"] = "\229\156\150\230\155\184\233\164\168\239\188\140"
L["Profile"] = "\229\128\139\228\186\186\232\179\135\230\150\153\239\188\140"
L["Purge_Desc"] = "\230\130\168\229\143\175\228\187\165\229\136\170\233\153\164\230\137\128\230\156\137\230\156\170\228\189\191\231\148\168\231\154\132\233\133\141\231\189\174\230\150\135\228\187\182\239\188\140\229\143\170\233\156\128\233\187\158\230\147\138\228\184\128\228\184\139"
L["Purge1"] = "\229\136\170\233\153\164\230\156\170\228\189\191\231\148\168\231\154\132\233\133\141\231\189\174\230\150\135\228\187\182"
L["Purge2"] = "\229\136\170\233\153\164\230\156\170\228\189\191\231\148\168\231\154\132\229\173\151\231\172\166\230\137\128\230\156\137\233\133\141\231\189\174\230\150\135\228\187\182"
L["Release Notes"] = "\231\153\188\232\161\140\232\170\170\230\152\142"
L["Toggles"] = "\229\136\135\230\143\155"
L["UseDefault_Desc"] = "\230\130\168\229\143\175\228\187\165\229\188\183\229\136\182\230\137\128\230\156\137\232\167\146\232\137\178\228\189\191\231\148\168\226\128\156\239\188\133s\226\128\157\231\154\132\229\128\139\228\186\186\232\179\135\230\150\153\239\188\140\228\187\165\231\174\161\231\144\134\228\184\128\229\128\139\229\150\174\228\184\128\231\154\132\233\133\141\231\189\174"
L["UseDefault1"] = "\228\186\164\230\143\155\230\169\159\231\154\132\230\137\128\230\156\137\229\173\151\231\172\166\226\128\156\239\188\133s\226\128\157\231\154\132\229\128\139\228\186\186\232\179\135\230\150\153"
L["UseDefault2"] = "\228\189\191\231\148\168\226\128\156\239\188\133s\226\128\157\230\155\178\231\183\154\231\154\132\230\137\128\230\156\137\232\167\146\232\137\178"
end
libinit:_SetLocalization(l:GetLocale(me,true))

