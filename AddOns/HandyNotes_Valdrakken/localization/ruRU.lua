local L = LibStub("AceLocale-3.0"):NewLocale("HandyNotes_Valdrakken", "ruRU", false, true)

if not L then return end
-- Russian localization by Werloz ( https://www.curseforge.com/members/werloz ) and dartraiden ( https://www.curseforge.com/members/dartraiden )
if L then
----------------------------------------------------------------------------------------------------
-----------------------------------------------CONFIG-----------------------------------------------
----------------------------------------------------------------------------------------------------

L["config_plugin_name"] = "Valdrakken"
L["config_plugin_desc"] = "Показывает на карте мира и миникарте местоположения НИПов и достопримечательности в Вальдраккене."

L["config_tab_general"] = "Общие"
L["config_tab_scale_alpha"] = "Размер / Прозрачность"
L["config_icon_scale"] = "Размер значков"
L["config_icon_scale_desc"] = "Изменяет размер значков"
L["config_icon_alpha"] = "Прозрачность значков"
L["config_icon_alpha_desc"] = "Изменяет прозрачность значков"
L["config_what_to_display"] = "Что отображать?"
L["config_what_to_display_desc"] = "Эти настройки определяют, значки каких типов будут отображаться."

L["config_auctioneer"] = "Аукционист"
L["config_auctioneer_desc"] = "Показать местонахождение аукциониста."

L["config_banker"] = "Банкир"
L["config_banker_desc"] = "Показать местонахождение банкира."

L["config_barber"] = "Парикмахер"
L["config_barber_desc"] = "Показать местонахождение парикмахера."

L["config_craftingorders"] = "Заказы на предметы"
L["config_craftingorders_desc"] = "Показать местонахождение НИПов, размещающих заказы на предметы."

L["config_flightmaster"] = "Распорядитель полётов"
L["config_flightmaster_desc"] = "Показать местонахождение распорядителя полётов."

L["config_guildvault"] = "Хранилище гильдии"
L["config_guildvault_desc"] = "Показать расположение хранилища гильдии."

L["config_innkeeper"] = "Хозяин таверны"
L["config_innkeeper_desc"] = "Показать местонахождение хозяина таверны."

L["config_mail"] = "Почтовый ящик"
L["config_mail_desc"] = "Показать расположение почтовых ящиков."

L["config_portal"] = "Портал"
L["config_portal_desc"] = "Показать расположения порталов."

L["config_portaltrainer"] = "Мастер порталов"
L["config_portaltrainer_desc"] = "Показать местонахождение мастера порталов."

L["config_tpplatform"] = "Платформа телепортации"
L["config_tpplatform_desc"] = "Показать расположение платформы телепортации."

L["config_travelguide_note"] = "|cFFFF0000*Уже активен через HandyNotes: TravelGuide.|r"

L["config_reforge"] = "Улучшение предметов"
L["config_reforge_desc"] = "Показать местонахождение улучшателя предметов."

L["config_rostrum"] = "Постамент трансформации"
L["config_rostrum_desc"] = "Показать расположение Постамента трансформации."

L["config_stablemaster"] = "Смотритель стойл"
L["config_stablemaster_desc"] = "Показать местонахождение смотрителя стойл."

L["config_trainer"] = "Учитель профессии"
L["config_trainer_desc"] = "Показать местонахождение учителя профессии."

L["config_transmogrifier"] = "Трансмогрификатор"
L["config_transmogrifier_desc"] = "Показать местонахождение трансмогрификатора."

L["config_vendor"] = "Торговец"
L["config_vendor_desc"] = "Показать местонахождение торговцев."

L["config_void"] = "Хранилище Бездны"
L["config_void_desc"] = "Показать расположение Хранилища Бездны."

L["config_others"] = "Другое"
L["config_others_desc"] = "Показать все остальные достопримечательности."

L["config_onlymytrainers"] = "Показывать только учителей и торговцев моих профессий"
L["config_onlymytrainers_desc"] = [[
Действует только в отношении учителей и торговцев основных профессий.

|cFFFF0000ПРИМЕЧАНИЕ: Действует только тогда, когда изучены две основные профессии.|r
]]

L["config_fmaster_waypoint"] = "Путевая точка распорядителя полётов"
L["config_fmaster_waypoint_desc"] = "Автоматически устанавливает путевую точку для распорядителя полётов, когда вы входите в Кольцо Перенаправления."

L["config_easy_waypoints"] = "Упрощённые путевые точки"
L["config_easy_waypoints_desc"] = "Активирует упрощённое создание путевой точки. Позволяет установить путевую точку, щёлкнув правой кнопкой мыши, и получить доступ к дополнительным параметрам, нажав CtrL+[ПКМ]."

L["config_waypoint_dropdown"] = "Выбрать"
L["config_waypoint_dropdown_desc"] = "Выберите способ создания путевой точки."
L["Blizzard"] = true
L["TomTom"] = true
L["Both"] = "Оба"

L["config_picons"] = "Показывать значки профессий для:"
L["config_picons_vendor_desc"] = "Показывать значки профессий вместо значков торговцев."
L["config_picons_trainer_desc"] = "Показывать значки профессий вместо значков учителей."
L["config_use_old_picons"] = "Использовать старые значки профессий"
L["config_use_old_picons_desc"] = "Показывать старые значки профессий вместо новых (которые появились с выходом Dragonflight)."

L["config_restore_nodes"] = "Восстановить скрытые значки"
L["config_restore_nodes_desc"] = "Восстановить все значки, которые были скрыты через контекстное меню."
L["config_restore_nodes_print"] = "Все скрытые значки были восстановлены"

----------------------------------------------------------------------------------------------------
-------------------------------------------------DEV------------------------------------------------
----------------------------------------------------------------------------------------------------

L["dev_config_tab"] = "РАЗРАБОТЧИКАМ"

L["dev_config_force_nodes"] = "Принудительно показать"
L["dev_config_force_nodes_desc"] = "Принудительное отображение всех значков независимо от класса, фракции или ковенанта."

L["dev_config_show_prints"] = "Показать print()"
L["dev_config_show_prints_desc"] = "Показывать сообщения print() в окне чата."

----------------------------------------------------------------------------------------------------
-----------------------------------------------HANDLER----------------------------------------------
----------------------------------------------------------------------------------------------------

--==========================================CONTEXT_MENU==========================================--

L["handler_context_menu_addon_name"] = "HandyNotes: Valdrakken"
L["handler_context_menu_add_tomtom"] = "Добавить в TomTom"
L['handler_context_menu_add_map_pin'] = "Установить путевую точку"
L["handler_context_menu_hide_node"] = "Скрыть этот значок"

--============================================TOOLTIPS============================================--

L["handler_tooltip_requires"] = "Требуется"
L["handler_tooltip_requires_level"] = "Требуется как минимум уровень игрока"
L["handler_tooltip_data"] = "ПОЛУЧЕНИЕ ДАННЫХ..."
L["handler_tooltip_quest"] = "Открывается с помощью задания"

----------------------------------------------------------------------------------------------------
----------------------------------------------DATABASE----------------------------------------------
----------------------------------------------------------------------------------------------------

L["Crafting Orders"] = "Заказы на предметы"
L["Mailbox"] = "Почтовый ящик"
L["Portal to Dalaran"] = "Портал в Даларан"
L["Portal to Jade Forest"] = "Портал в Нефритовый лес"
L["Portal to Orgrimmar"] = "Портал в Оргриммар"
L["Portal to Shadowmoon Valley"] = "Портал в Долину Призрачной Луны"
L["Portal to Stormwind"] = "Портал в Штормград"
L["Rostrum of Transformation"] = "Постамент трансформации"
L["Teleport to Seat of the Aspects"] = "Телепорт к Престолу Аспектов"
L["Visage of True Self"] = "Истинный облик"

end