-- ♡ Translation // ZamestoTV (Hubbotu)
-- Переводчик ZamestoTV

---@class addon
local addon = select(2, ...)
local L = addon.C.AddonInfo.Locales

--------------------------------

L.ruRU = {}
local NS = L.ruRU; L.ruRU = NS

--------------------------------

function NS:Load()
	if GetLocale() ~= "ruRU" then
		return
	end

	--------------------------------
	-- GENERAL
	--------------------------------

	do

	end

	--------------------------------
	-- WAYPOINT SYSTEM
	--------------------------------

	do
		-- PINPOINT
		L["WaypointSystem - Pinpoint - Quest - Complete"] = "Готов к сдаче"
	end

	--------------------------------
	-- SLASH COMMAND
	--------------------------------

	do
		L["SlashCommand - /way - Map ID - Prefix"] = "Текущий ID карты: "
		L["SlashCommand - /way - Map ID - Suffix"] = ""
		L["SlashCommand - /way - Position - Axis (X) - Prefix"] = "X: "
		L["SlashCommand - /way - Position - Axis (X) - Suffix"] = ""
		L["SlashCommand - /way - Position - Axis (Y) - Prefix"] = ", Y: "
		L["SlashCommand - /way - Position - Axis (Y) - Suffix"] = ""
	end

	--------------------------------
	-- CONFIG
	--------------------------------

	do
		L["Config - General"] = "Общие"
		L["Config - General - Title"] = "Общие"
		L["Config - General - Title - Subtext"] = "Настройте общие параметры."
		L["Config - General - Preferences"] = "Предпочтения"
		L["Config - General - Preferences - Meter"] = "Используйте метры вместо ярдов"
		L["Config - General - Preferences - Meter - Description"] = "Изменяет единицу измерения на метрическую."
		L["Config - General - Preferences - Font"] = "Шрифт"
		L["Config - General - Preferences - Font - Description"] = "Шрифт, используемый во всем аддоне."
		L["Config - General - Reset"] = "Сбросить"
		L["Config - General - Reset - Button"] = "Сброс по умолчанию"
		L["Config - General - Reset - Confirm"] = "Вы уверены, что хотите сбросить все настройки?"
		L["Config - General - Reset - Confirm - Yes"] = "Подтвердить"
		L["Config - General - Reset - Confirm - No"] = "Отмена"

		L["Config - WaypointSystem"] = "Точка маршрута"
		L["Config - WaypointSystem - Title"] = "Точка маршрута"
		L["Config - WaypointSystem - Title - Subtext"] = "Управлять поведением маркера внутри мира и значка цели внутри мира."
		L["Config - WaypointSystem - Type"] = "Включить"
		L["Config - WaypointSystem - Type - Both"] = "ВСЕ"
		L["Config - WaypointSystem - Type - Waypoint"] = "Точка маршрута"
		L["Config - WaypointSystem - Type - Pinpoint"] = "Точка привязки"
		L["Config - WaypointSystem - General"] = "Общие"
		L["Config - WaypointSystem - General - RightClickToClear"] = "Right-Click To Clear"
		L["Config - WaypointSystem - General - RightClickToClear - Description"] = "Allows you to clear the Waypoint/Pinpoint/Navigator by right-clicking it."
		L["Config - WaypointSystem - General - Transition Distance"] = "Точное расстояние"
		L["Config - WaypointSystem - General - Transition Distance - Description"] = "Показано максимальное расстояние до точечного обнаружения."
		L["Config - WaypointSystem - General - Hide Distance"] = "Минимальное расстояние"
		L["Config - WaypointSystem - General - Hide Distance - Description"] = "Расстояние до точки маршрута/точке привязки скрыто."
		L["Config - WaypointSystem - Waypoint"] = "Точка маршрута"
		L["Config - WaypointSystem - Waypoint - Footer - Type"] = "Дополнительная информация"
		L["Config - WaypointSystem - Waypoint - Footer - Type - Both"] = "Все"
		L["Config - WaypointSystem - Waypoint - Footer - Type - Distance"] = "Расстояние"
		L["Config - WaypointSystem - Waypoint - Footer - Type - ETA"] = "Время прибытия"
		L["Config - WaypointSystem - Waypoint - Footer - Type - None"] = "Нет"
		L["Config - WaypointSystem - Pinpoint"] = "Точка привязки"
		L["Config - WaypointSystem - Pinpoint - Info"] = "Показать информацию"
		L["Config - WaypointSystem - Pinpoint - Info - Extended"] = "Показать расширенную информацию"
		L["Config - WaypointSystem - Pinpoint - Info - Extended - Description"] = "Включите дополнительную информацию, например, имя/описание."
		L["Config - WaypointSystem - Navigator"] = "Навигатор"
		L["Config - WaypointSystem - Navigator - Enable"] = "Показать"
		L["Config - WaypointSystem - Navigator - Enable - Description"] = "Если точка маршрута или точка привязки находятся за пределами экрана, навигатор укажет направление."

		L["Config - Appearance"] = "Появление"
		L["Config - Appearance - Title"] = "Появление"
		L["Config - Appearance - Title - Subtext"] = "Настройте внешний вид пользовательского интерфейса."
		L["Config - Appearance - Waypoint"] = "Точка маршрута"
		L["Config - Appearance - Waypoint - Scale"] = "Размер точки маршрута"
		L["Config - Appearance - Waypoint - Scale - Description"] = "Размер точки маршрута меняется в зависимости от расстояния. Эта опция задает общий размер."
		L["Config - Appearance - Waypoint - Scale - Min"] = "Минимум %"
		L["Config - Appearance - Waypoint - Scale - Min - Description"] = "Минимальный % размер, до которого можно уменьшить."
		L["Config - Appearance - Waypoint - Scale - Max"] = "Максимум %"
		L["Config - Appearance - Waypoint - Scale - Max - Description"] = "Максимальный % размер, до которого можно увеличить."
		L["Config - Appearance - Waypoint - Beam"] = "Показать Луч"
		L["Config - Appearance - Waypoint - Beam - Alpha"] = "Прозрачность"
		L["Config - Appearance - Waypoint - Footer"] = "Показать текст информации"
		L["Config - Appearance - Waypoint - Footer - Scale"] = "Размер"
		L["Config - Appearance - Waypoint - Footer - Alpha"] = "Прозрачность текста информации"
		L["Config - Appearance - Pinpoint"] = "Точка привязки"
		L["Config - Appearance - Pinpoint - Scale"] = "Размер точки привязки"
		L["Config - Appearance - Navigator"] = "Навигатор"
		L["Config - Appearance - Navigator - Scale"] = "Размер"
		L["Config - Appearance - Navigator - Alpha"] = "Прозрачность"
		L['Config - Appearance - Navigator - Distance'] = "Distance"
		L["Config - Appearance - Visual"] = "Внешний вид"
		L["Config - Appearance - Visual - UseCustomColor"] = "Использовать пользовательский цвет"
		L["Config - Appearance - Visual - UseCustomColor - Color"] = "Цвет"
		L["Config - Appearance - Visual - UseCustomColor - TintIcon"] = "Оттенок иконки"
		L["Config - Appearance - Visual - UseCustomColor - Reset"] = "Сброс"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Default"] = "Обычное задание"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Repeatable"] = "Повторяемое задание"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Important"] = "Важное задание"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Incomplete"] = "Незавершенное задание"
		L["Config - Appearance - Visual - UseCustomColor - Neutral"] = "Общая точка маршрута"

		L["Config - Audio"] = "Аудио"
		L["Config - Audio - Title"] = "Аудио"
		L["Config - Audio - Title - Subtext"] = "Конфигурация звуковых эффектов интерфейса точки маршрута."
		L["Config - Audio - General"] = "Общие"
		L["Config - Audio - General - EnableGlobalAudio"] = "Включить аудио"
		L["Config - Audio - Customize"] = "Настроить"
		L["Config - Audio - Customize - UseCustomAudio"] = "Использовать пользовательский звук"
		L["Config - Audio - Customize - UseCustomAudio - Sound ID"] = "Идентификатор звука"
		L["Config - Audio - Customize - UseCustomAudio - Sound ID - Placeholder"] = "Пользовательский идентификатор"
		L["Config - Audio - Customize - UseCustomAudio - Preview"] = "Предпросмотр"
		L["Config - Audio - Customize - UseCustomAudio - Reset"] = "Сбросить"
		L["Config - Audio - Customize - UseCustomAudio - WaypointShow"] = "Показать путевую точку"
		L["Config - Audio - Customize - UseCustomAudio - PinpointShow"] = "Показать точное местоположение"

		L["Config - About"] = "О"
		L["Config - About - Contributors"] = "Участники"
		L["Config - About - Developer"] = "Разработчик"
	end

	--------------------------------
	-- CONTRIBUTORS
	--------------------------------

	do
		L["Contributors - ZamestoTV"] = "ZamestoTV"
		L["Contributors - ZamestoTV - Description"] = "Переводчик — на русский язык"
		L["Contributors - huchang47"] = "huchang47"
		L["Contributors - huchang47 - Description"] = "Переводчик — на китайский (упрощенный) язык"
		L["Contributors - BlueNightSky"] = "BlueNightSky"
		L["Contributors - BlueNightSky - Description"] = "Переводчик — на китайский (традиционный) язык"
		L["Contributors - Crazyyoungs"] = "Crazyyoungs"
		L["Contributors - Crazyyoungs - Description"] = "Переводчик — на корейский язык"
		L["Contributors - Klep"] = "Klep"
		L["Contributors - Klep - Description"] = "Переводчик — на французский язык"
		L["Contributors - Kroffy"] = "Kroffy"
		L["Contributors - Kroffy - Description"] = "Переводчик — на французский язык"
		L["Contributors - cathtail"] = "cathtail"
		L["Contributors - cathtail - Description"] = "Translator - Brazilian Portuguese"
		L["Contributors - Larsj02"] = "Larsj02"
		L["Contributors - Larsj02 - Description"] = "Переводчик — на немецкий язык"
		L["Contributors - dabear78"] = "dabear78"
		L["Contributors - dabear78 - Description"] = "Переводчик — на немецкий язык"
		L["Contributors - y45853160"] = "y45853160"
		L["Contributors - y45853160 - Description"] = "Код — Исправление ошибок в бета-версии"
		L["Contributors - lemieszek"] = "lemieszek"
		L["Contributors - lemieszek - Description"] = "Код — Исправление ошибок в бета-версии"
		L["Contributors - BadBoyBarny"] = "BadBoyBarny"
		L["Contributors - BadBoyBarny - Description"] = "Code — Bug Fix"
		L["Contributors - SyverGiswold"] = "SyverGiswold"
		L["Contributors - SyverGiswold - Description"] = "Code - Feature"
	end
end

NS:Load()
