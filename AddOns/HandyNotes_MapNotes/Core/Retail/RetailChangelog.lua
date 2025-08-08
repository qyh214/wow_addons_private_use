local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
ns.previousVersion = "3.0.2"
ns.currentVersion = "3.0.3"

ns.LOCALE_CHANGELOG = {
  enUS = [[
• Tooltip display for certain MapNotes symbols has been changed.
Symbols targeting a specific NPC now show the NPC's name and their profession or title in the tooltip.
Example: inn tooltip in Dornogal

before:   "Innkeeper"
after:    "Ronesh" "Innkeeper"

• It is now possible to use "/target name" from symbols in the in-game chat window to target certain people,
making it easier to find them when nearby.

• A new feature called "NPC targeting" has been added,
allowing you to target these NPCs without chat commands. (Enabled by default)
Shift + Middle Mouse Button on a symbol with one or more NPC names opens a confirmation window.
Click with left mouse button to target the NPC and mark it with an X.
If multiple names are listed, the first is targeted.
The option can be found under General > Advanced Options > NPC targeting.

• Currently only NPC names for a few capital cities are completed, but more will be added over time.
This affects nearly 90% of existing symbols, so as a solo developer it takes time.

• Patch 11.2.0 update:
Symbols for the new zone have been added, and now include NPC names.
]],

  deDE = [[
• Es wurden bei bestimmten MapNotes Symbole die Tooltip Anzeige geaendert.
Symbole mit einem bestimmten NPC als Ziel zeigen nun den Namen des NPCs
und zusatzlich deren Beruf oder Titel im Tooltip.
Beispiel: Gasthaustooltip in Dornogal

davor:    "Gastwirt"
nachher:  "Ronesh" "Gastwirt"

• Damit ist es nun möglich, bestimmte Personen mit "/target name" im ingame Chatfenster
direkt von Symbolen zu zoielen, was das Finden erleichtert, wenn man in der Naehe ist.

• Eine neue Funktion namens "NPC-Zielerfassung" wurde hinzugefuegt,
mit der man diese NPCs auch ohne Chatbefehl ins Visier nehmen kann (standardmässig aktiviert).
Shift + Mittlere Maustaste auf ein Symbol mit einem oder mehreren NPC-Namen öffnet ein
Bestaetigungsfenster. Mit der linken Maustaste wird das Ziel anvisiert und mit einem X markiert.
Bei mehreren Namen wird der erste in der Liste angesteuert.
Diese Funktion ist zu finden unter Allgemein > Erweiterte Option > NPC-Zielerfassung.

• Derzeit sind nur NPC-Namen fuer einige Hauptstädte fertig, weitere werden nach und nach hinzugefügt.
Das betrifft nahezu 90% der Symbole, was als Einzelperson zeitintensiv ist.

• Update fuer Patch 11.2.0:
Symbole fuer die neue Zone wurden hinzugefuegt und enthalten nun NPC-Namen.
]],

  frFR = [[
• L'affichage des info-bulles de certains symboles MapNotes a ete modifie.
Les symboles visant un PNJ affichent maintenant le nom du PNJ
ainsi que sa profession ou son titre dans l'info-bulle.
Exemple : info-bulle de l'auberge a Dornogal

avant:    "Aubergiste"
apres:    "Ronesh"  "Aubergiste"

• Il est desormais possible d'utiliser "/target name" depuis les symboles dans la fenetre de chat
en jeu pour cibler certaines personnes, ce qui facilite leur localisation si vous etes a proximite.

• Une nouvelle fonction nommee "NPC targeting" a ete ajoutee,
permettant de cibler ces PNJ sans commande de chat (active par defaut).
Majuscule + molette du milieu sur un symbole avec un ou plusieurs noms de PNJ ouvre une
fenetre de confirmation. Un clic gauche cible le PNJ et l'initiale une X.
Si plusieurs noms sont presentes, le premier est cible.
L'option se trouve sous General > Advanced Options > NPC targeting.

• Actuellement seuls les noms de PNJ pour quelques capitales sont completes, mais d'autres seront
ajoutes dans le temps.
Cela concerne pres de 90% des symboles existants, ce qui est long a faire en solo.

• Mise a jour pour le patch 11.2.0 :
Des symboles pour la nouvelle zone ont ete ajoutes et incluent maintenant les noms de PNJ.
]],

  itIT = [[
• La visualizzazione dei tooltip di alcuni simboli MapNotes e stata modificata.
I simboli che mirano a un NPC specifico mostrano ora il nome dell'NPC
e la sua professione o titolo nel tooltip.
Esempio: tooltip dell'osteria a Dornogal

prima:    "Oste"
dopo:     "Ronesh"  "Oste"

• Ora e possibile usare "/target name" dai simboli nella finestra di chat in gioco
per mirare determinate persone, facilitando il ritrovamento se vicini.

• E stata aggiunta una nuova funzione chiamata "NPC targeting",
che permette di mirare questi NPC senza comandi chat (abilitata di default).
Shift + tasto centrale del mouse su un simbolo con uno o piu nomi NPC apre una finestra
di conferma. Clic sinistro della conferma mira il NPC e lo marca con una X.
Se sono presenti piu nomi, viene scelto il primo.
L'opzione si trova in General > Advanced Options > NPC targeting.

• Attualmente solo alcuni nomi NPC delle capitali sono completi, altri verranno aggiunti nei prossimi tempi.
Questo riguarda quasi il 90% dei simboli esistenti ed e laborioso da gestire da soli.

• Aggiornamento per patch 11.2.0:
Sono stati aggiunti simboli per la nuova zona, ora con nomi NPC inclusi.
]],

  esES = [[
• Se ha modificado la visualizacion del tooltip de ciertos simbolos de MapNotes.
Los simbolos que apuntaban a un PNJ especifico ahora muestran el nombre del PNJ
y su profesion o titulo en el tooltip.
Ejemplo: tooltip de la posada en Dornogal

antes:    "Tabernero"
despues:  "Ronesh"  "Tabernero"

• Ahora es posible usar "/target name" desde los simbolos en la ventana de chat del juego
para apuntar a ciertas personas, facilitando su localizacion cuando estan cerca.

• Se ha añadido una nueva funcion llamada "NPC targeting",
que permite apuntar a estos PNJ sin comandos de chat (activada por defecto).
Mayuscula + clic con la rueda del raton sobre un simbolo con uno o varios nombres de PNJ abre
una ventana de confirmacion. Un clic izquierdo apunta al PNJ y lo marca con una X.
Si hay varios nombres, se toma el primero.
La opcion esta en General > Advanced Options > NPC targeting.

• Actualmente solo estan completos los nombres de PNJ para algunas capitales, pero se añadiran
mas con el tiempo.
Esto afecta casi el 90% de los simbolos existentes, y hacerlo como proyecto individual lleva tiempo.

• Actualizacion para parche 11.2.0:
Se han agregado simbolos para la nueva zona e incluyen ahora nombres de PNJ.
]],

  esMX = [[
• Se ha modificado la visualizacion del tooltip de ciertos simbolos de MapNotes.
Los simbolos que apuntaban a un PNJ especifico ahora muestran el nombre del PNJ
y su profesion o titulo en el tooltip.
Ejemplo: tooltip de la posada en Dornogal

antes:    "Tabernero"
despues:  "Ronesh"  "Tabernero"

• Ahora es posible usar "/target name" desde los simbolos en la ventana de chat del juego
para apuntar a ciertas personas, facilitando su localizacion cuando estan cerca.

• Se ha añadido una nueva funcion llamada "NPC targeting",
que permite apuntar a estos PNJ sin comandos de chat (activada por defecto).
Mayuscula + clic con la rueda del raton sobre un simbolo con uno o varios nombres de PNJ abre
una ventana de confirmacion. Un clic izquierdo apunta al PNJ y lo marca con una X.
Si hay varios nombres, se toma el primero.
La opcion esta en General > Advanced Options > NPC targeting.

• Actualmente solo estan completos los nombres de PNJ para algunas capitales, pero se añadiran
mas con el tiempo.
Esto afecta casi el 90% de los simbolos existentes, y hacerlo como proyecto individual lleva tiempo.

• Actualizacion para parche 11.2.0:
Se han agregado simbolos para la nueva zona e incluyen ahora nombres de PNJ.
]],

  ruRU = [[
• Была изменена отображаемая инфо-подсказка (tooltip) для некоторых символов MapNotes.
Символы, нацеленные на определенного NPC, теперь показывают имя NPC
и его профессию или титул в подсказке.
Пример: подсказка таверны в Dornogal

раньше:   "Тавернщик"
теперь:   "Ронеш" "Тавернщик"

• Теперь можно использовать "/target name" с символов в чате игры,
чтобы нацелиться на определенных NPC, что упрощает их поиск, если вы рядом.

• Добавлена новая функция под названием "NPC targeting",
позволяющая нацеливаться на этих NPC без команд в чате (включена по умолчанию).
Shift + средняя кнопка мыши на символе с одним или несколькими именами NPC откроет окно
подтверждения. Левый клик подтвердит – NPC будет нацелен и отмечен X.
Если указано несколько имен, будет выбрано первое.
Настройка находится в General > Advanced Options > NPC targeting.

• В настоящее время имена NPC заполнены лишь для некоторых столиц, дополнительные будут добавлены со временем.
Это касается почти 90% существующих символов, и реализация требует времени в одиночку.

• Обновление для патча 11.2.0:
Добавлены символы для новой зоны, которые теперь включают имена NPC.
]],

  ptBR = [[
• A exibicao do tooltip de certos simbolos MapNotes foi alterada.
Simbolos que visam um NPC especifico agora mostram o nome do NPC
e sua profissao ou titulo no tooltip.

Exemplo: tooltip da estalagem em Dornogal
antes:    "Estalajadeiro"
depois:   "Ronesh"  "Estalajadeiro"

• Agora e possivel usar "/target name" a partir dos simbolos na janela de chat do jogo
para mirar certas pessoas, facilitando localiza-las quando estao proximas.

• Foi adicionada uma nova funcao chamada "NPC targeting",
que permite mirar nesses NPC sem comandos de chat (ativo por padrao).
Shift + clique com o botao do meio do mouse em um simbolo com um ou mais nomes de NPC abre
uma janela de confirmacao. Um clique esquerdo mira o NPC e marca com um X.
Se houver varios nomes, o primeiro e escolhido.
A opcao esta em General > Advanced Options > NPC targeting.

• Atualmente, apenas os nomes de NPC de algumas capitais estao completos, mas outros serao adicionados com o tempo.
Isso afeta quase 90% dos simbolos existentes e fazer isso como projeto solo leva tempo.

• Atualizacao para patch 11.2.0:
Simbolos da nova zona foram adicionados e agora incluem nomes de NPC.
]],

  zhCN = [[
• 已修改部分 MapNotes 图标的工具提示显示。
原本指向特定 NPC 的图标现在会在工具提示中显示该 NPC 的名字
以及其职业或头衔。
示例：多诺加尔旅店的 tooltip

之前:   "旅店老板"
之后:   "罗内什"  "旅店老板"

• 现在可以在游戏聊天窗口使用 "/target name" 从图标定位某些 NPC，
当你靠近时更容易找到他们。

• 添加了一个名为 "NPC targeting" 的新功能，
允许你在不使用聊天命令的情况下锁定这些 NPC（默认启用）。
Shift + 中键点击带有一个或多个 NPC 名称的图标会弹出确认窗口。
点击左键确认后，NPC 将被锁定并以 X 标记。
如果有多个名字，将锁定第一个。
此选项可在 General > Advanced Options > NPC targeting 找到。

• 目前仅部分首都的 NPC 名称已完成，更多将陆续添加。
这影响了近 90% 的现有图标，作为单人开发需要时间。

• 适配补丁 11.2.0：
新区域图标已添加，并且现在包含 NPC 名称。
]],

  zhTW = [[
• 已修改部分 MapNotes 圖示的工具提示顯示。
原本指向特定 NPC 的圖示現在會在提示中顯示該 NPC 的名字
以及其職業或頭銜。
範例：多諾加爾旅館 tooltip

原先:   "旅店老闆"
現在:   "羅內什"  "旅店老闆"

• 現在可以在遊戲聊天框使用 "/target name" 從圖示定位某些 NPC，
使你在靠近時更容易找到他們。

• 新增名為 "NPC targeting" 的功能，
允許你不使用聊天命令也能鎖定這些 NPC（預設啟用）。
按住 Shift 鍵 + 滾輪中鍵點擊帶有一個或多個 NPC 名稱的圖示會彈出確認視窗。
點擊左鍵確認後，NPC 將會被鎖定並用 X 標記。
若有多個名稱，將鎖定第一個。
該選項可在 General > Advanced Options > NPC targeting 找到。

• 目前僅部分首都的 NPC 名稱已完成，更多將陸續加入。
涉及近 90% 的現有圖示，作為單人開發項目需要時間。

• 適配補丁 11.2.0：
新區域圖標已添加，並且現在包含 NPC 名稱。
]],
}


function ns.ShowChangelogWindow()
    if MapNotesChangelogFrame and MapNotesChangelogFrame:IsShown() or MapNotesChangelogFrameMenu and MapNotesChangelogFrameMenu:IsShown() then return end

    C_Timer.After(0.01, function()
        local LoginChangeLogFrame = CreateFrame("Frame", "MapNotesChangelogFrame", UIParent, "BasicFrameTemplateWithInset")
       LoginChangeLogFrame:SetSize(750, 400)
       LoginChangeLogFrame:SetPoint("CENTER")
       LoginChangeLogFrame:SetMovable(true)
       LoginChangeLogFrame:EnableMouse(true)
       LoginChangeLogFrame:RegisterForDrag("LeftButton")
       LoginChangeLogFrame:SetScript("OnDragStart", LoginChangeLogFrame.StartMoving)
       LoginChangeLogFrame:SetScript("OnDragStop", LoginChangeLogFrame.StopMovingOrSizing)
       LoginChangeLogFrame:SetFrameStrata("DIALOG")
       LoginChangeLogFrame:SetToplevel(true)
       LoginChangeLogFrame:SetClampedToScreen(true)

        LoginChangeLogFrame.title = LoginChangeLogFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        LoginChangeLogFrame.title:SetPoint("TOP", 0, -3)
        LoginChangeLogFrame.title:SetText(ns.COLORED_ADDON_NAME .. "|cffffd700 " .. L["Changelog"])

        LoginChangeLogFrame.fixedVersionText = LoginChangeLogFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        LoginChangeLogFrame.fixedVersionText:SetPoint("TOPLEFT", 10, -5)
        LoginChangeLogFrame.fixedVersionText:SetText("|cffffd700" .. GAME_VERSION_LABEL .. ":|r " .. "|cffff0000" .. ns.currentVersion)
        
        LoginChangeLogFrame.scrollFrame = CreateFrame("ScrollFrame", nil, LoginChangeLogFrame, "UIPanelScrollFrameTemplate")
        LoginChangeLogFrame.scrollFrame:SetPoint("TOPLEFT", 10, -40)
        LoginChangeLogFrame.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

        local content = CreateFrame("Frame", nil, LoginChangeLogFrame.scrollFrame) -- EditBox with padding inside frame
        content:SetSize(700, 1)

        LoginChangeLogFrame.editBox = CreateFrame("EditBox", nil, content)
        LoginChangeLogFrame.editBox:SetMultiLine(true)
        LoginChangeLogFrame.editBox:SetFontObject(GameFontHighlight)

        local padding = 38 -- = 1cm left and right
        LoginChangeLogFrame.editBox:SetWidth(700 - (padding * 2))
        LoginChangeLogFrame.editBox:SetPoint("TOPLEFT", padding, 0)
        LoginChangeLogFrame.editBox:SetPoint("RIGHT", content, "RIGHT", -padding, 0)
        LoginChangeLogFrame.editBox:SetAutoFocus(false)

        local changelogText = ns.LOCALE_CHANGELOG[GetLocale()] or ns.LOCALE_CHANGELOG["enUS"]
        LoginChangeLogFrame.editBox:SetText("|cffffd700" .. changelogText)
        LoginChangeLogFrame.scrollFrame:SetScrollChild(content)
        LoginChangeLogFrame.checkbox = CreateFrame("CheckButton", nil, LoginChangeLogFrame, "ChatConfigCheckButtonTemplate")
        LoginChangeLogFrame.checkbox:SetPoint("BOTTOMLEFT", 10, 10)
        LoginChangeLogFrame.checkbox.Text:SetText("|cffff0000" .. L["Do not show again until next version"])
        LoginChangeLogFrame.closeButton = CreateFrame("Button", nil, LoginChangeLogFrame, "GameMenuButtonTemplate")
        LoginChangeLogFrame.closeButton:SetPoint("BOTTOMRIGHT", -10, -10)
        LoginChangeLogFrame.closeButton:SetSize(100, 25)
        LoginChangeLogFrame.closeButton:SetText(CLOSE)
        LoginChangeLogFrame.closeButton:SetScript("OnClick", function()
            if LoginChangeLogFrame.checkbox:GetChecked() then
                HandyNotes_MapNotesRetailChangelogDB.lastChangelogVersion = ns.currentVersion
            end
            LoginChangeLogFrame:Hide()
        end)

        LoginChangeLogFrame:SetScript("OnHide", function()
            if LoginChangeLogFrame.checkbox:GetChecked() then
                HandyNotes_MapNotesRetailChangelogDB.lastChangelogVersion = ns.currentVersion
            end
        end)
    end)

    table.insert(UISpecialFrames, "MapNotesChangelogFrame")
end


function ns.ShowChangelogWindowMenu()
    if (MapNotesChangelogFrame and MapNotesChangelogFrame:IsShown()) or (MapNotesChangelogFrameMenu and MapNotesChangelogFrameMenu:IsShown()) then return end

    local ChangeLogFrameMenu = CreateFrame("Frame", "MapNotesChangelogFrameMenu", UIParent, "BasicFrameTemplateWithInset")
    ChangeLogFrameMenu:SetSize(750, 400)
    ChangeLogFrameMenu:SetPoint("CENTER")
    ChangeLogFrameMenu:SetMovable(true)
    ChangeLogFrameMenu:EnableMouse(true)
    ChangeLogFrameMenu:RegisterForDrag("LeftButton")
    ChangeLogFrameMenu:SetScript("OnDragStart", ChangeLogFrameMenu.StartMoving)
    ChangeLogFrameMenu:SetScript("OnDragStop", ChangeLogFrameMenu.StopMovingOrSizing)
    ChangeLogFrameMenu:SetFrameStrata("DIALOG")
    ChangeLogFrameMenu:SetToplevel(true)
    ChangeLogFrameMenu:SetClampedToScreen(true)

    ChangeLogFrameMenu.title = ChangeLogFrameMenu:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    ChangeLogFrameMenu.title:SetPoint("TOP", 0, -3)
    ChangeLogFrameMenu.title:SetText(ns.COLORED_ADDON_NAME .. "|cffffd700 " .. L["Changelog"])

    ChangeLogFrameMenu.fixedVersionText = ChangeLogFrameMenu:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    ChangeLogFrameMenu.fixedVersionText:SetPoint("TOPLEFT", 10, -5)
    ChangeLogFrameMenu.fixedVersionText:SetText("|cffffd700" .. GAME_VERSION_LABEL .. ":|r " .. "|cffff0000" .. ns.currentVersion)

    ChangeLogFrameMenu.scrollFrame = CreateFrame("ScrollFrame", nil, ChangeLogFrameMenu, "UIPanelScrollFrameTemplate")
    ChangeLogFrameMenu.scrollFrame:SetPoint("TOPLEFT", 10, -40)
    ChangeLogFrameMenu.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

    local content = CreateFrame("Frame", nil, ChangeLogFrameMenu.scrollFrame) -- EditBox with padding inside frame
    content:SetSize(700, 1)

    ChangeLogFrameMenu.editBox = CreateFrame("EditBox", nil, content)
    ChangeLogFrameMenu.editBox:SetMultiLine(true)
    ChangeLogFrameMenu.editBox:SetFontObject(GameFontHighlight)

    local padding = 38 -- = 1cm left and right
    ChangeLogFrameMenu.editBox:SetWidth(700 - padding * 2)
    ChangeLogFrameMenu.editBox:SetPoint("TOPLEFT", padding, 0)
    ChangeLogFrameMenu.editBox:SetPoint("RIGHT", content, "RIGHT", -padding, 0)
    ChangeLogFrameMenu.editBox:SetAutoFocus(false)

    local changelogText = ns.LOCALE_CHANGELOG[GetLocale()] or ns.LOCALE_CHANGELOG["enUS"]
    ChangeLogFrameMenu.editBox:SetText("|cffffd700" .. changelogText)
    ChangeLogFrameMenu.scrollFrame:SetScrollChild(content)
    ChangeLogFrameMenu.closeButton = CreateFrame("Button", nil, ChangeLogFrameMenu, "GameMenuButtonTemplate")
    ChangeLogFrameMenu.closeButton:SetPoint("BOTTOMRIGHT", -10, -10)
    ChangeLogFrameMenu.closeButton:SetSize(100, 25)
    ChangeLogFrameMenu.closeButton:SetText(CLOSE)
    ChangeLogFrameMenu.closeButton:SetScript("OnClick", function()
        ChangeLogFrameMenu:Hide()
        LibStub("AceConfigDialog-3.0"):Open("MapNotes")
    end)

    ChangeLogFrameMenu:SetScript("OnHide", function()
        LibStub("AceConfigDialog-3.0"):Open("MapNotes")
    end)

    table.insert(UISpecialFrames, "MapNotesChangelogFrameMenu")
end


local DBFrame = CreateFrame("Frame")
DBFrame:RegisterEvent("ADDON_LOADED")
DBFrame:SetScript("OnEvent", function(_, event, addonName)
    if addonName == "HandyNotes_MapNotes" then
        if not HandyNotes_MapNotesRetailChangelogDB then
            HandyNotes_MapNotesRetailChangelogDB = {}
        end
        if not HandyNotes_MapNotesRetailChangelogDB.lastChangelogVersion then
            HandyNotes_MapNotesRetailChangelogDB.lastChangelogVersion = ns.previousVersion
        end

        if HandyNotes_MapNotesRetailChangelogDB.lastChangelogVersion ~= ns.currentVersion then
            ns.ShowChangelogWindow()
        end
    end
end)