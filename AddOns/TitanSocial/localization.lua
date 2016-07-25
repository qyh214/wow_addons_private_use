local addonName, addonTable = ...
local L = {}
addonTable.L = L

L.MENU_TEXT = "TitanSocial"

-- default (enUS)

L.BUTTON_TITLE = "Social: "
L.REMOTE_CHAT = "Remote Chat"

L.TOOLTIP = "Social"
L.TOOLTIP_REALID = "RealID Friends Online"
L.TOOLTIP_REALID_APP = "RealID Friends in Battle.Net App"
L.TOOLTIP_FRIENDS = "Friends Online"
L.TOOLTIP_GUILD = "Guild Members Online"
L.TOOLTIP_REMOTE_CHAT = "Remote Chat"
L.TOOLTIP_COLLAPSED = "(collapsed, click to expand)"

L.MENU_REALID = "RealID"
L.MENU_REALID_FRIENDS = "Show RealID Friends"
L.MENU_REALID_BROADCASTS = "Show RealID Broadcasts"
L.MENU_REALID_FACTIONS = "Show RealID Factions"
L.MENU_REALID_NOTE = "Show Notes"
L.MENU_REALID_APP = "Show Battle.Net App"

L.MENU_FRIENDS = "Friends"
L.MENU_FRIENDS_SHOW = "Show Friends"
L.MENU_FRIENDS_NOTE = "Show Notes"

L.MENU_GUILD = "Guild"
L.MENU_GUILD_MEMBERS = "Show Guild Members"
L.MENU_GUILD_LABEL = "Show Guild Label"
L.MENU_GUILD_NOTE = "Show Guild Note"
L.MENU_GUILD_ONOTE = "Show Officer Note"
L.MENU_GUILD_REMOTE_CHAT = "Separate Remote Chat"

L.MENU_GUILD_SORT = "Sort"
L.MENU_GUILD_SORT_DEFAULT = "Use Guild Roster Sort"
L.MENU_GUILD_SORT_NAME = "Name"
L.MENU_GUILD_SORT_RANK = "Rank"
L.MENU_GUILD_SORT_CLASS = "Class"
L.MENU_GUILD_SORT_NOTE = "Note"
L.MENU_GUILD_SORT_LEVEL = "Level"
L.MENU_GUILD_SORT_ZONE = "Zone"
L.MENU_GUILD_SORT_ASCENDING = "Ascending"
L.MENU_GUILD_SORT_DESCENDING = "Descending"

L.MENU_STATUS = "Show Status As"
L.MENU_STATUS_ICON = "Icon"
L.MENU_STATUS_TEXT = "Text"
L.MENU_STATUS_NONE = "None"

L.MENU_SHOW_GROUP_MEMBERS = "Show Group Members"

L.MENU_INTERACTION = "Tooltip Interaction"
L.MENU_INTERACTION_ALWAYS = "Always"
L.MENU_INTERACTION_OOC = "Out Of Combat"
L.MENU_INTERACTION_NEVER = "Never"

L.MENU_LABEL = "Show Label"
L.MENU_HIDE = "Hide"
L.MENU_OPTIONS = "Options"


-- frFR

if GetLocale() == "frFR" then
	-- Last Update by Sasmira: 10/30/2010

	L.BUTTON_TITLE = "Social: "

	L.TOOLTIP = "Social"
	L.TOOLTIP_REALID = "Amis R\195\169els:"
	L.TOOLTIP_FRIENDS = "Contacts:"
	L.TOOLTIP_GUILD = "Membres de la guilde:"

	L.MENU_REALID = "Amis R\195\169els"
	L.MENU_REALID_FRIENDS = "Afficher: Amis R\195\169els"
	L.MENU_REALID_BROADCASTS = "Afficher: Nombre d'Amis R\195\169els"

	L.MENU_FRIENDS = "Contacts"
	L.MENU_FRIENDS_SHOW = "Afficher: Contacts"
	L.MENU_FRIENDS_NOTE = "Afficher: Notes Contacts"

	L.MENU_GUILD = "Guilde"
	L.MENU_GUILD_MEMBERS = "Afficher: Membres de Guilde"
	L.MENU_GUILD_LABEL = "Afficher: Nom de Guilde"
	L.MENU_GUILD_NOTE = "Afficher: Notes de Guilde"
	L.MENU_GUILD_ONOTE = "Afficher: Notes d'Officier"

	L.MENU_LABEL = "Afficher le titre"
	L.MENU_HIDE = "Cacher"
	L.MENU_OPTIONS = "Options"
end


-- deDE

if GetLocale() == "deDE" then
	-- Last Update by Mistrahw: 10/19/2014

	L.TOOLTIP_REALID = "RealID Freunde Online" 
	L.TOOLTIP_REALID_APP = "RealID Freunde in der Battle.Net App" 
	L.TOOLTIP_FRIENDS = "Freunde Online" 
	L.TOOLTIP_GUILD = "Gildenmitglieder Online" 
	L.TOOLTIP_REMOTE_CHAT = "Remote Chat" 
	L.TOOLTIP_COLLAPSED = "(minimiert, klicken zum erweitern)"

	L.MENU_REALID_FRIENDS = "Zeige RealID Freunde" 
	L.MENU_REALID_BROADCASTS = "Zeige RealID Statusmeldungen" 
	L.MENU_REALID_FACTIONS = "Zeige RealID Fraktion" 
	L.MENU_REALID_NOTE = "Zeige Notiz" 
	L.MENU_REALID_APP = "Zeige Battle.Net App"

	L.MENU_FRIENDS = "Freunde" 
	L.MENU_FRIENDS_SHOW = "Zeige Freunde" 
	L.MENU_FRIENDS_NOTE = "Zeige Notizen"

	L.MENU_GUILD = "Gilde" 
	L.MENU_GUILD_MEMBERS = "Zeige Gildenmitglieder" 
	L.MENU_GUILD_LABEL = "Zeige Gildenname"
	L.MENU_GUILD_NOTE = "Zeige Gildennotiz" 
	L.MENU_GUILD_ONOTE = "Zeige Offiziersnotiz" 
	L.MENU_GUILD_REMOTE_CHAT = "Remote Chat anzeigen"

	L.MENU_GUILD_SORT = "Sortieren" 
	L.MENU_GUILD_SORT_DEFAULT = "Benutze Gildensortierung" 
	L.MENU_GUILD_SORT_RANK = "Rang" 
	L.MENU_GUILD_SORT_CLASS = "Klasse" 
	L.MENU_GUILD_SORT_ASCENDING = "Aufwärts" 
	L.MENU_GUILD_SORT_DESCENDING = "Abwärts"

	L.MENU_STATUS = "Zeige Status als" 
	L.MENU_STATUS_NONE = "Nichts"

	L.MENU_SHOW_GROUP_MEMBERS = "Zeige Gruppenmitglieder"

	L.MENU_INTERACTION = "Tooltip anzeigen" 
	L.MENU_INTERACTION_ALWAYS = "Immer" 
	L.MENU_INTERACTION_OOC = "Ausserhalb vom Kampf" 
	L.MENU_INTERACTION_NEVER = "Nie"

	L.MENU_LABEL = "Beschriftunstext anzeigen" 
	L.MENU_HIDE = "ausblenden" L.MENU_OPTIONS = "Optionen"
end


-- zhTW

if GetLocale() == "zhTW" then
	--L.BUTTON_TITLE = "Social: "

	--L.TOOLTIP = "Social"
	L.TOOLTIP_REALID = "在線RealID:"
	L.TOOLTIP_FRIENDS = "在線好友:"
	L.TOOLTIP_GUILD = "在線公會成員:"

	L.MENU_REALID = "RealID"
	L.MENU_REALID_FRIENDS = "顯示RealID"
	L.MENU_REALID_BROADCASTS = "顯示RealID廣播"

	L.MENU_FRIENDS = "好友"
	L.MENU_FRIENDS_SHOW = "顯示好友"
	L.MENU_FRIENDS_NOTE = "顯示好友註記"

	L.MENU_GUILD = "公會"
	L.MENU_GUILD_MEMBERS = "顯示公會成員"
	L.MENU_GUILD_LABEL = "顯示公會會階"
	L.MENU_GUILD_NOTE = "顯示公會註記"
	L.MENU_GUILD_ONOTE = "顯示公會幹部註記"

	L.MENU_LABEL = "顯示標籤"
	L.MENU_HIDE = "隱藏"
	L.MENU_OPTIONS = "選項"
end

-- esES

if GetLocale() == "esES" then
	--esES by Golpeadornat (Jsr1976)

	L.BUTTON_TITLE = "Social: "
	L.REMOTE_CHAT = "Chat Remoto"

	L.TOOLTIP = "Social"
	L.TOOLTIP_REALID = "Amigos conectados con RealID:"
	L.TOOLTIP_FRIENDS = "Amigos conectados:"
	L.TOOLTIP_GUILD = "Miembros Hermandad conectados:"
	L.TOOLTIP_REMOTE_CHAT = "Chat Remoto:"

	L.MENU_REALID = "RealID"
	L.MENU_REALID_FRIENDS = "Muestra Amigos con RealID"
	L.MENU_REALID_BROADCASTS = "Muestra Transmisiones RealID"

	L.MENU_FRIENDS = "Amigos"
	L.MENU_FRIENDS_SHOW = "Muestra Amigos"
	L.MENU_FRIENDS_NOTE = "Muestra Notas de Amigos"

	L.MENU_GUILD = "Hermandad"
	L.MENU_GUILD_MEMBERS = "Muestra Miembros de Hermandad"
	L.MENU_GUILD_LABEL = "Muestra Etiqueta de Hermandad"
	L.MENU_GUILD_NOTE = "Muestra Nota de Hermandad"
	L.MENU_GUILD_ONOTE = "Muestra Nota del Oficial"
	L.MENU_GUILD_REMOTE_CHAT = "Separa el Chat Remoto"

	L.MENU_LABEL = "Muestra Etiqueta"
	L.MENU_HIDE = "Oculta"
	L.MENU_OPTIONS = "Opciones"
end


-- ruRU

if GetLocale() == "ruRU" then
	--ruRU by Вишмастер@Термоштепсель 26.06.12

	L.BUTTON_TITLE = "Social: "

	L.TOOLTIP = "Social"
	L.TOOLTIP_REALID = "RealID друзья онлайн:"
	L.TOOLTIP_FRIENDS = "Друзья онлайн:"
	L.TOOLTIP_GUILD = "Члены гильдии онлайн:"

	L.MENU_REALID = "RealID"
	L.MENU_REALID_FRIENDS = "Показывать RealID друзей"
	L.MENU_REALID_BROADCASTS = "Показывать RealID уведомления"

	L.MENU_FRIENDS = "Друзья"
	L.MENU_FRIENDS_SHOW = "Показывать друзей"
	L.MENU_FRIENDS_NOTE = "Показывать заметки друзей"

	L.MENU_GUILD = "Гильдия"
	L.MENU_GUILD_MEMBERS = "Показывать членов гильдии"
	L.MENU_GUILD_LABEL = "Показывать название гильдии"
	L.MENU_GUILD_NOTE = "Показывать гильдийские заметки"
	L.MENU_GUILD_ONOTE = "Показывать офицерские заметки"

	L.MENU_LABEL = "Текст ярлыка"
	L.MENU_HIDE = "Скрыть"
	L.MENU_OPTIONS = "Опции"
end


-- ptBR by Kasth 10.4.2014

if GetLocale() == "ptBR" then
	L.BUTTON_TITLE = "Social: "
	L.REMOTE_CHAT = "Chat Remoto"

	L.TOOLTIP = "Social"
	L.TOOLTIP_REALID = "Amigos de RealID Online:"
	L.TOOLTIP_REALID_APP = "Amigos Online no Aplicativo Battle.net"
	L.TOOLTIP_FRIENDS = "Amigos Online:"
	L.TOOLTIP_GUILD = "Membros da Guilda Online:"
	L.TOOLTIP_REMOTE_CHAT = "Chat Remoto"
	L.TOOLTIP_COLLAPSED = "(comprimido, clique para expandir)"

	L.MENU_REALID = "RealID"
	L.MENU_REALID_FRIENDS = "Mostrar Amigos de RealID"
	L.MENU_REALID_BROADCASTS = "Mostrar Transmissões de RealID"
	L.MENU_REALID_FACTIONS = "Mostrar facções de RealID"
	L.MENU_REALID_NOTE = "Mostrar Notas"
	L.MENU_REALID_APP = "Mostrar Aplicativo Battle.net"

	L.MENU_FRIENDS = "Amigos"
	L.MENU_FRIENDS_SHOW = "Mostrar Amigos"
	L.MENU_FRIENDS_NOTE = "Mostrar Anotação dos Amigos"

	L.MENU_GUILD = "Guilda"
	L.MENU_GUILD_MEMBERS = "Mostrar Membros da Guilda"
	L.MENU_GUILD_LABEL = "Mostrar Nome da Guilda"
	L.MENU_GUILD_NOTE = "Mostrar Notas da Guilda"
	L.MENU_GUILD_ONOTE = "Mostrar Nota de Oficial"
	L.MENU_GUILD_REMOTE_CHAT = "Separar Chat Remoto"

	L.MENU_GUILD_SORT = "Sort"
	L.MENU_GUILD_SORT_DEFAULT = "Ordenar pela Lista da Guilda"
	L.MENU_GUILD_SORT_NAME = "Nome"
	L.MENU_GUILD_SORT_RANK = "Posto"
	L.MENU_GUILD_SORT_CLASS = "Classe"
	L.MENU_GUILD_SORT_LEVEL = "Nivel"
	L.MENU_GUILD_SORT_ZONE = "Zona"
	L.MENU_GUILD_SORT_ASCENDING = "Crescente"
	L.MENU_GUILD_SORT_DESCENDING = "Decrescente"

	L.MENU_STATUS = "Mostrar Status Como"
	L.MENU_STATUS_ICON = "Ícone"
	L.MENU_STATUS_TEXT = "Texto"
	L.MENU_STATUS_NONE = "Nada"

	L.MENU_SHOW_GROUP_MEMBERS = "Mostrar Membros do Grupo"

	L.MENU_INTERACTION = "Interação da Dica"
	L.MENU_INTERACTION_ALWAYS = "Sempre"
	L.MENU_INTERACTION_OOC = "Fora de Combate"
	L.MENU_INTERACTION_NEVER = "Nunca"

	L.MENU_LABEL = "Exibir Título"
	L.MENU_HIDE = "Esconder"
	L.MENU_OPTIONS = "Opções"
end

--itIT by itMax86 15.09.2012

if GetLocale() == "itIT" then
	L.BUTTON_TITLE = "Social: "
	L.REMOTE_CHAT = "Chat Remota"

	L.TOOLTIP = "Social"
	L.TOOLTIP_REALID = "Amici RealID Collegati:"
	L.TOOLTIP_FRIENDS = "Amici Collegati:"
	L.TOOLTIP_GUILD = "Membri di Gilda Collegati:"
	L.TOOLTIP_REMOTE_CHAT = "Chat Remota:"

	L.MENU_REALID = "RealID"
	L.MENU_REALID_FRIENDS = "Mostra Amici RealID"
	L.MENU_REALID_BROADCASTS = "Mostra Messaggio RealID"

	L.MENU_FRIENDS = "Amici"
	L.MENU_FRIENDS_SHOW = "Mostra Amici"
	L.MENU_FRIENDS_NOTE = "Mostra Nota Amici"

	L.MENU_GUILD = "Gilda"
	L.MENU_GUILD_MEMBERS = "Mostra Membri di Gilda"
	L.MENU_GUILD_LABEL = "Mostra Nome della Gilda"
	L.MENU_GUILD_NOTE = "Mostra Nota di Gilda"
	L.MENU_GUILD_ONOTE = "Mostra Nota degli Ufficiali"
	L.MENU_GUILD_REMOTE_CHAT = "Remote Chat Separata"

	L.MENU_LABEL = "Mostra Ettichetta"
	L.MENU_HIDE = "Nascondi"
	L.MENU_OPTIONS = "Opzioni"
end
