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

