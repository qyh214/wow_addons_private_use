-- ENGLISH (default)
local L = LibStub("AceLocale-3.0"):NewLocale("Stats+", "enUS", true) --enUS
if L then
    -- Stats
    L["Ilvl"] = "iLvl"
	L["Strength"] = "Strength"
    L["Intellect"] = "Intellect"
    L["Agility"] = "Agility"
    L["Haste"] = "Haste"
    L["Versatility"] = "Vers"
    L["Critical Strike"] = "Crit"
    L["Mastery"] = "Mastery"

    -- Frame Options
    L["Lock Frame Position"] = "Lock Frame Position"
    L["Font Outline"] = "Font Outline"
    L["Show Item Level"] = "Show Item Level"
    L["Show Primary Stat"] = "Show Primary Stat"
    L["Use One Line Layout"] = "Use One Line Layout"
    L["Font Size"] = "Font Size"
    L["Line Spacing"] = "Line Spacing"
    L["Text Alignment"] = "Text Alignment"
    L["Item Level Format"] = "Item Level Format"
    L["Secondary Stat Format"] = "Secondary Stat Format"
    L["Versatility Format"] = "Versatility Format"
    L["Font Family"] = "Font Family"
    L["Frame Strata"] = "Frame Strata"

    -- Alignment
    L["Left"] = "Left"
    L["Right"] = "Right"
    L["Center"] = "Center"

    -- Item Level Display
    L["Auto (show both if different)"] = "Auto (show both if different)"
    L["Equipped + Inventory"] = "Equipped + Inventory"
    L["Equipped Only"] = "Equipped Only"

    -- Secondary Stat Format
    L["Rating + Percentage"] = "Rating + Percentage"
    L["Percentage + Rating"] = "Percentage + Rating"
    L["Rating Only"] = "Rating Only"
    L["Percentage Only"] = "Percentage Only"
    L["Versatility Only"] = "Versatility Only"
    L["Versatility + Damage Reduction"] = "Versatility + Damage Reduction"
	
	L["Missing Stats"] = "Missing Stats"
	L["Drag to move"] = "Drag to move\n/stats or /st to open Settings\nUse |cffff0000'Lock Frame Position'|r to hide text"
	L["Stats Settings /stats /st"]  = "Stats Settings /stats /st"
	L["Addon Name"] = "Statsplus (Stats+)"
	L["Stats+ Options"] = "Stats+ Options"
	L["Click or use /st /stats"] = "Click or use /st /stats"
	
	L["Leech"] = "Leech"
	L["Avoidance"] = "Avoidance"
	L["Show Leech"] = "Show Leech"
	L["Show Avoidance"] = "Show Avoidance"
	L["Tertiary Format"] = "Tertiary Stat Format"
	
	L["Primary Stat"] = "Primary Stat"
	L["All Colors"] = "All Colors"
	L["Reset Colors"] = "Reset Colors"
	
	L["Speed"] = "Speed"
	L["Show Speed"] = "Show Speed"
	L["SpeedNoticeLine1"] = "Showing the Speed stat may have a slight performance impact, though it's negligible."
	L["SpeedNoticeLine2"] = "Lower VALUE = more frequent updates and slightly more performance hit."
	L["SpeedNoticeLine3"] = "Use '/stats update <VALUE>' to change it. Current interval:"
	L["UpdateIntervalSet"] = "Update interval set to %s seconds."
	
	L["Decimal Places"] = "Decimal Places"
	L["New"]  = "New: "
	
	--Speed Stuff
	L["Speed Format"] = "Speed Format"
	L["Static + Current"] = "Static + Current"
	L["Current + Static"] = "Current + Static"
	L["Static Speed"] = "Static Speed"
	L["Current Speed"] = "Current Speed"

	--Visibility
	L["Visibility"] = "Visibility"
	L["Always"] = "Always"
	L["In Combat"] = "In Combat"
	L["Out of Combat"] = "Out of Combat"
	
	--Stats Ordering
	L["Stat Ordering"] = "Stat Ordering"
	L["All Stats"] = "All Stats"
	L["Secondaries"] = "Secondaries"
	L["Default"] = "Default"
	L["Custom"] = "Custom"
	L["Prio Based (murlok.io)"] = "Priority based (murlok.io)"
	L["Version"] = "Version"
	
	L["Block"] = "Block"
	L["Parry"] = "Parry"
	L["Dodge"] = "Dodge"
	L["Armor"] = "Armor"
	L["Show Secondaries"] = "Show Secondaries"
	L["Show Block"] = "Show Block"
	L["Show Parry"] = "Show Parry"
	L["Show Dodge"] = "Show Dodge"
	L["Show Armor"] = "Show Armor"
	
	L["General"] = "General"
	L["Profiles"] = "Profiles"
	L["RELOADWARNING"] = "Your settings will be reset with this update.\n Please 'RELOAD or use /reload' before making any changes to ensure your new settings are not corrupted.\n This is required for the profile system to work correctly.\n Have fun :)"
	
	L["Appearance"] = "Appearance"
	L["Auto Hide Tertiaries"] = "Auto Hide Tertiaries"
	L["Auto Hide Tank Stats"] = "Auto Hide Tank Stats"
	L["Custom Text"] = "Custom Text"
	L["Colors"] = "Colors"

	
	L["Use Background"] = "Use Background"
	L["Background Opacity"] = "Background Opacity"
	
	L["Show Minimap Button"] = "Show Minimap Button"
	L["Minimap Button L"] = "Leftclick: Show Options"
	L["Minimap Button R"] = "Rightclick: Toggle Lock Frame"

	L["Damage Reduction"] = "Damage Reduction"
	L["Damage Reduction + Armor"] = "Damage Reduction + Armor"
	L["Armor + Damage Reduction"] = "Armor + Damage Reduction"
	L["Armor Format"] = "Armor Format"

	L["Global Position"] = "Global Position"
	L["Profile Position"] = "Profile Position"
	L["Use Global Position"] = "Use Global Position"

	L["Infos"] = "Infos"
	L["Changelog"]  = "Changelog"

	L["Stat Ordering Label"] = "Clear the text block to the right first, then use the dropdown to set the order"
	L["Auto Hide Tertiaries TOOLTIP"] = "Automatically hide (Leech/Avoidance) when enabled and their rating is 0"
	L["Auto Hide Tank Stats TOOLTIP"] = "Automatically hide (Parry/Dodge/Block) when enabled and not relevant for your spec"
	L["SpeedTooltip"] = "This may slightly increase performance impact. Use '/stats update' for more info"

	L["Background"] = "Background"
	L["Background Color"] = "Background Color"
	L["Background Texture"] = "Background Texture"
	L["Border Color"] = "Border Color"
	L["Border Offset"] = "Border Offset"
	L["Border Opacity"] = "Border Opacity"
	L["Border Size"] = "Border Size"
	L["Border Style"] = "Border Style"
	L["Use Border"] = "Use Border"
	L["Extend Background"] = "Extend Background (Up Right Down Left)"

	L["StatsInfoText"] = [[Shows your character statistics including Item Level, Primary Stats, Secondary Stats, Tertiaries, Defensives, and much more

General:
- While "Lock Frame Position" is disabled, Background use will be temporarily disabled.
- Enable "Use One Line Layout" if you want the stats to be displayed in a single line.
- "Use Global Position" is for the Stats Frame Position. You have to change that setting on every profile.

- "Show Speed" will use more cpu resources (if enabled), because it updates every X seconds. Use /stats update to change X
- "Auto Hide Tertiaries" will hide Leech / Avoidance if their rating is at 0.
- "Auto Hide Tank Stats" will only show Block/Parry/Dodge if it's used by your current Tank Specialization. Armor is not included in that.

Appearance:
- "Stat Ordering" is done based on (murlok.io). It takes the top 50 rated players and orders your stats based on that priority. This will be updated weekly (saved in SpecPriority.lua)
But you can also use Custom ordering. Basically delete the text in the textblock, and then use the Dropdown to customize it.
- Custom Text is for customizing your lines. Instead of Haste, you could use H

|cffff2200Localization:
Stats+ supports multiple languages, but I need help with more translations
If you want to contribute, feel free to comment or message me on curseforge via DM|r]]
end

-- DEUTSCH
local L = LibStub("AceLocale-3.0"):NewLocale("Stats+", "deDE") --deDE
if L then
    -- Stats
    L["Ilvl"] = "iLvl"
    L["Strength"] = "Stärke"
    L["Intellect"] = "Intelligenz"
    L["Agility"] = "Beweglichkeit"
    L["Haste"] = "Tempo"
    L["Versatility"] = "Vielseitigkeit"
    L["Critical Strike"] = "Krit"
    L["Mastery"] = "Meisterschaft"

    -- Frame Options
    L["Lock Frame Position"] = "Fensterposition sperren"
    L["Font Outline"] = "Schriftkontur"
    L["Show Item Level"] = "Gegenstandsstufe anzeigen"
    L["Show Primary Stat"] = "Primärwert anzeigen"
    L["Use One Line Layout"] = "Einzeiliges Layout verwenden"
    L["Font Size"] = "Schriftgröße"
    L["Line Spacing"] = "Zeilenabstand"
    L["Text Alignment"] = "Textausrichtung"
    L["Item Level Format"] = "Gegenstandst. Format"
    L["Secondary Stat Format"] = "Sekundärwert Format"
    L["Versatility Format"] = "Vielseitigkeit Format"
    L["Font Family"] = "Schriftart"
    L["Frame Strata"] = "Fensterebene"

    -- Alignment
    L["Left"] = "Links"
    L["Right"] = "Rechts"
    L["Center"] = "Zentriert"

    -- Item Level Display
    L["Auto (show both if different)"] = "Automatisch (beide anzeigen, wenn unterschiedlich)"
    L["Equipped + Inventory"] = "Angelegt + Inventar"
    L["Equipped Only"] = "Nur Angelegt"

    -- Secondary Stat Format
    L["Rating + Percentage"] = "Wertung + Prozentsatz"
    L["Percentage + Rating"] = "Prozentsatz + Wertung"
    L["Rating Only"] = "Nur Wertung"
    L["Percentage Only"] = "Nur Prozentsatz"
    L["Versatility Only"] = "Nur Vielseitigkeit"
    L["Versatility + Damage Reduction"] = "Vielseitigkeit + Schadensreduktion"
	
	L["Missing Stats"] = "Fehlende Werte"
	L["Drag to move"] = "Ziehen zum bewegen\n/stats oder /st für Einstellungen\nNutze |cffff0000'Fensterposition sperren'|r um den Text zu verstecken"
	L["Stats Settings /stats /st"]  = "Stats Einstellungen /stats /st"
	L["Addon Name"] = "Statsplus (Stats+)"
	L["Stats+ Options"] = "Stats+ Einstellungen"
	L["Click or use /st /stats"] = "Klicken oder /st /stats benutzen"
	
	L["Leech"] = "Lebensraub"
	L["Avoidance"] = "Vermeidung"
	L["Show Leech"] = "Lebensraub anzeigen"
	L["Show Avoidance"] = "Vermeidung anzeigen"
	L["Tertiary Format"] = "Tertiärwert Format"
	
	L["Primary Stat"] = "Primärwert"
	L["All Colors"] = "Alle Farben"
	L["Reset Colors"] = "Farben zurücksetzen"
	
	L["Speed"] = "Geschwindigkeit"
	L["Show Speed"] = "Bewegungsgeschwindigkeit anzeigen"
	L["SpeedNoticeLine1"] = "Die Anzeige der Geschwindigkeit kann einen leichten Performance-Einfluss haben, ist aber vernachlässigbar."
	L["SpeedNoticeLine2"] = "Kleinere WERTE = häufigere Updates und leicht höhere Performance-Belastung."
	L["SpeedNoticeLine3"] = "Verwende '/stats update <WERT>' zum ändern. Aktueller Intervall:"
	L["UpdateIntervalSet"] = "Update-Intervall auf %s Sekunden gesetzt."
	
	L["Decimal Places"] = "Dezimalstellen"
	L["New"]  = "Neu: "
	
	L["Stat Ordering"] = "Werte anordnen"
	L["Static + Current"] = "Statisch + Aktuell"
	L["Current + Static"] = "Aktuell + Statisch"
	L["Static Speed"] = "Statische Geschwindigkeit"
	L["Current Speed"] = "Aktuelle Geschwindigkeit"
	L["Speed Format"] = "Geschwindigkeit Format"
	L["Out of Combat"] = "Außerhalb vom Kampf"
	L["In Combat"] = "Im Kampf"
	L["Always"] = "Immer"
	L["Visibility"] = "Sichtbarkeit"
	L["Prio Based (murlok.io)"] = "Priorität basierend (murlok.io)"
	L["Secondaries"] = "Sekundärwerte"
	L["Custom"] = "Benutzerdefiniert"
	L["Default"] = "Standard"
	L["All Stats"] = "Alle Werte"
	L["Version"] = "Version"
	
	L["Block"] = "Blocken"
	L["Parry"] = "Parieren"
	L["Dodge"] = "Ausweichen"
	L["Armor"] = "Rüstung"
	L["Show Secondaries"] = "Sekundärwerte anzeigen"
	L["Show Block"] = "Blocken anzeigen"
	L["Show Parry"] = "Parieren anzeigen"
	L["Show Dodge"] = "Ausweichen anzeigen"
	L["Show Armor"] = "Rüstung anzeigen"
	
	L["General"] = "Allgemein"
	L["Profiles"] = "Profile"
	L["RELOADWARNING"] = "Deine Einstellungen werden mit diesem Update einmalig zurückgesetzt.\nBitte 'RELOAD' oder /reload ausführen, bevor du änderungen vornimmst, um sicherzustellen, dass deine neuen Einstellungen nicht beschädigt werden.\nDies ist erforderlich, damit das Profilsystem korrekt funktioniert.\nViel Spaß :)"
	
	L["Appearance"] = "Aussehen"
	L["Auto Hide Tertiaries"] = "Tertiärwerte automatisch ausblenden"
	L["Auto Hide Tank Stats"] = "Tank Werte automatisch ausblenden"
	L["Custom Text"] = "Benutzerdefinierter Text"
	L["Colors"] = "Farben"
	
	
	L["Use Background"] = "Hintergrund verwenden"
	L["Background Opacity"] = "Hintergrundtransparenz"
	
	L["Show Minimap Button"] = "Minikarten-Symbol anzeigen"
	L["Minimap Button L"] = "Linksklick: Einstellungen öffnen"
	L["Minimap Button R"] = "Rechtsklick: Fensterpositionsperre wechseln"

	L["Damage Reduction"] = "Schadensreduktion"
	L["Damage Reduction + Armor"] = "Schadensreduktion + Rüstung"
	L["Armor + Damage Reduction"] = "Rüstung + Schadensreduktion"
	L["Armor Format"] = "Rüstung Format"

	L["Global Position"] = "Globale Fensterposition"
	L["Profile Position"] = "Profil Fensterposition"
	L["Use Global Position"] = "Verwende Globale Fensterposition"

	L["Infos"] = "Infos"
	L["Changelog"]  = "Änderungen (nur auf English)"

	L["Stat Ordering Label"] = "Lösche zuerst den Textblock rechts und nutze dann das Dropdown, um die Reihenfolge festzulegen"
	L["SpeedTooltip"] = "Dies hat einen minimalen Performance-Einfluss – nutze ‘/stats update’ für weitere Infos"
	L["Auto Hide Tank Stats TOOLTIP"] = "(Parieren/Blocken/Ausweichen) automatisch ausblenden, wenn aktiviert und nicht relevant für deine Spezialisierung"
	L["Auto Hide Tertiaries TOOLTIP"] = "(Lebensraub/Vermeidung) automatisch ausblenden, wenn aktiviert und deren Wertung 0 ist"

	L["Background"] = "Hintergrund"
	L["Background Color"] = "Hintergrundfarbe"
	L["Background Texture"] = "Hintergrundtextur"
	L["Border Color"] = "Rahmenfarbe"
	L["Border Offset"] = "Rahmenversatz"
	L["Border Opacity"] = "Rahmentransparenz"
	L["Border Size"] = "Rahmengröße"
	L["Border Style"] = "Rahmenstil"
	L["Use Border"] = "Verwende Rahmen"
	L["Extend Background"] = "Hintergrund erweitern (Oben Rechts Unten Links)"

	L["StatsInfoText"] = [[Zeigt deine Charakterstatistiken an, einschließlich Gegenstandstufe, Primärwert, Sekundärwerte, Tertiärwerte, Defensive Werte und vieles mehr.

Allgemein:
- Wenn "Fensterposition sperren" deaktiviert ist, wird die Nutzung des Hintergrunds vorübergehend deaktiviert
- Aktiviere "Einzeiliges Layout verwenden", wenn die Werte in einer einzelnen Zeile angezeigt werden sollen
- "Verwende Globale Fensterposition" gilt für die Position des Stats Frames. Diese Einstellung musst du für jedes Profil separat ändern

- "Bewegungsgeschwindigkeit anzeigen" verbraucht mehr CPU-Ressourcen (wenn aktiviert), da die Werte alle X Sekunden aktualisiert werden. Verwende /stats update, um X zu ändern
- "Tertiärwerte automatisch ausblenden" blendet Lebensraub/Vermeidung aus, wenn deren Wert 0 ist
- "Tank Werte automatisch ausblenden" zeigt Blocken/Parieren/Ausweichen nur an, wenn sie von deiner aktuellen Tank-Spezialisierung genutzt werden. Rüstung ist davon nicht betroffen

Aussehen:
- "Werte anordnen" basiert auf (murlok.io). Dabei werden die Top 50 bewerteten Spieler genommen und deine Sekundärwerte nach dieser Priorität sortiert. Dies wird wöchentlich aktualisiert (gespeichert in SpecPriority.lua)
Du kannst aber auch eine eigene Sortierung verwenden: Lösche dazu einfach den Text im Textfeld und nutze anschließend das Dropdown-Menü zur Anpassung
- "Benutzerdefinierter Text" dient dazu, den Text deiner Werte anzupassen. Statt "Tempo" könntest du z.B. "T" verwenden

|cffff2200Lokalisierung:
Stats+ unterstützt mehrere Sprachen, aber ich benötige Hilfe bei weiteren Übersetzungen
Wenn du mithelfen möchtest, kommentiere unter dem Addon oder schreibe mir eine Nachricht auf CurseForge|r]]
end

-- Simplified Chinese
local L = LibStub("AceLocale-3.0"):NewLocale("Stats+", "zhCN") --zhCN
if L then
	L["Addon Name"] = "Statsplus (Stats+)"
	L["Agility"] = "敏捷"
	L["All Colors"] = "使用同一颜色"
	L["All Stats"] = "所有属性"
	L["Always"] = "始终"
	L["Armor"] = "护甲"
	L["Auto (show both if different)"] = "自动（若不同则同时显示）"
	L["Avoidance"] = "闪避"
	L["Block"] = "格挡"
	L["Center"] = "居中"
	L["Click or use /st /stats"] = "点击或使用/st /stats打开"
	L["Critical Strike"] = "爆击"
	L["Current + Static"] = "当前 + 静态"
	L["Current Speed"] = "当前速度"
	L["Custom"] = "自定义"
	L["Decimal Places"] = "小数位数"
	L["Default"] = "默认"
	L["Dodge"] = "躲闪"
	L["Drag to move"] = "拖拽以移动\n/stats或/st打开设置\n使用|cffff0000“锁定框架”|r隐藏此文本"
	L["Equipped + Inventory"] = "实装 + 虚装"
	L["Equipped Only"] = "仅实装"
	L["Font Family"] = "字体"
	L["Font Outline"] = "字体轮廓"
	L["Font Size"] = "字体尺寸"
	L["Frame Strata"] = "框架层级"
	L["Haste"] = "急速"
	L["Ilvl"] = "装等"
	L["In Combat"] = "战斗中"
	L["Intellect"] = "智力"
	L["Item Level Format"] = "装等格式"
	L["Leech"] = "吸血"
	L["Left"] = "左对齐"
	L["Line Spacing"] = "行距"
	L["Lock Frame Position"] = "锁定框架"
	L["Mastery"] = "精通"
	L["Missing Stats"] = "缺失属性"
	L["New"] = "新： "
	L["Out of Combat"] = "战斗外"
	L["Parry"] = "招架"
	L["Percentage + Rating"] = "百分比 + 点数"
	L["Percentage Only"] = "仅百分比"
	L["Primary Stat"] = "主属性"
	L["Prio Based (murlok.io)"] = "基于优先级（murlok.io）"
	L["Rating + Percentage"] = "点数 + 百分比"
	L["Rating Only"] = "仅点数"
	L["Reset Colors"] = "重置颜色"
	L["Right"] = "右对齐"
	L["Secondaries"] = "副属性"
	L["Secondary Stat Format"] = "副属性格式"
	L["Show Armor"] = "展示护甲"
	L["Show Avoidance"] = "展示闪避"
	L["Show Block"] = "展示格挡"
	L["Show Dodge"] = "展示躲闪"
	L["Show Item Level"] = "展示装备等级"
	L["Show Leech"] = "展示吸血"
	L["Show Parry"] = "展示招架"
	L["Show Primary Stat"] = "展示主属性"
	L["Show Secondaries"] = "展示副属性"
	L["Show Speed"] = "显示移动速度"
	L["Speed"] = "移速"
	L["Speed Format"] = "移速格式"
	L["SpeedNoticeLine1"] = "显示移动速度可能会对游戏性能产生轻微影响，不过通常可以忽略不计。"
	L["SpeedNoticeLine2"] = "数值越低 = 更新越频繁，性能损失更大。"
	L["SpeedNoticeLine3"] = "使用“/stats update <数值>”来更改。当前更新频率："
	L["Stat Ordering"] = "属性排序"
	L["Static + Current"] = "静态 + 当前"
	L["Static Speed"] = "静态速度"
	L["Stats Settings /stats /st"] = "属性统计设置 /stats /st"
	L["Stats+ Options"] = "Stats+ 设置"
	L["Strength"] = "力量"
	L["Tertiary Format"] = "第三属性格式"
	L["Text Alignment"] = "文本对齐"
	L["UpdateIntervalSet"] = "更新频率已设置为%s秒。"
	L["Use One Line Layout"] = "使用单行布局"
	L["Versatility"] = "全能"
	L["Versatility + Damage Reduction"] = "全能 + 减伤比例"
	L["Versatility Format"] = "全能格式"
	L["Versatility Only"] = "仅全能"
	L["Version"] = "版本"
	L["Visibility"] = "可见性"
	L["General"] = "常规"
	L["Profiles"] = "配置"
	L["RELOADWARNING"] = "本次更新将重置您的插件设置。\n在进行任何更改之前，请重新加载界面或输入“/reload”以确保新设置不被损坏。\n这是让配置文件正常运行的必备步骤。\n祝您玩得开心 :)"
	
	L["Appearance"] = "外观"
	L["Auto Hide Tertiaries"] = "自动隐藏第三属性"
	L["Auto Hide Tank Stats"] = "自动隐藏坦克属性"
	L["Custom Text"] = "自定义文本"
	L["Colors"] = "颜色"
	L["Use Background"] = "使用背景"
	L["Background Opacity"] = "背景不透明度"
	L["Show Minimap Button"] = "展示小地图按钮"
	L["Minimap Button L"] = "左键点击：打开设置"
	L["Minimap Button R"] = "右键点击：切换框架锁定"

	L["Damage Reduction"] = "减伤"
	L["Damage Reduction + Armor"] = "减伤 + 护甲"
	L["Armor + Damage Reduction"] = "护甲 + 减伤"
	L["Armor Format"] = "护甲格式"

	L["Global Position"] = "全局位置"
	L["Profile Position"] = "独立位置"
	L["Use Global Position"] = "使用全局位置"

	L["Infos"] = "信息"
	L["Changelog"]  = "更新日志（仅英文）"

	L["Stat Ordering Label"] = "请先清空右侧的文本框，然后使用下拉菜单设置顺序"
	L["Auto Hide Tertiaries TOOLTIP"] = "启用后，如果（吸血/闪避）的数值为0，则自动将其隐藏"
	L["Auto Hide Tank Stats TOOLTIP"] = "启用后，若（招架/躲闪/格挡）非当前专精所使用，则自动将其隐藏"
	L["SpeedTooltip"] = "这可能会轻微影响性能。输入“/stats update”获取更多信息"

	L["Background"] = "背景"
	L["Background Color"] = "背景颜色"
	L["Background Texture"] = "背景纹理"
	L["Border Color"] = "边框颜色"
	L["Border Offset"] = "边框偏移"
	L["Border Opacity"] = "边框不透明度"
	L["Border Size"] = "边框粗细"
	L["Border Style"] = "边框样式"
	L["Use Border"] = "使用边框"
	L["Extend Background"] = "扩展背景（上 右 下 左）"


	L["StatsInfoText"] = [[显示您的角色属性面板，涵盖物品等级、主属性、副属性、第三属性、防御属性等更多内容。

常规：
- 当“锁定框架”未勾选时，背景功能将暂时失效。
- 若希望将属性显示为一行，请启用“使用单行布局”。
- “使用全局位置”仅针对属性框架的位置。您需要在每个配置文件中单独调整此设置。

- “显示移动速度”开启后会占用更多 CPU 资源，因为它每隔 X 秒更新一次。使用 /stats update 命令可更改 X 的数值。
- “自动隐藏第三属性”将在 吸血/闪避 数值为 0 时隐藏它们。
- “自动隐藏坦克属性”仅在您当前为坦克专精时显示 格挡/招架/躲闪。护甲 不包含在此规则内。

外观：
- “属性排序”依据 murlok.io 的数据进行。它根据排名前 50 的玩家数据来决定您的属性显示优先级。该数据每周更新（保存在 SpecPriority.lua 文件中）。
不过您也可以使用自定义排序。只需清空文本框中的内容，然后使用下拉菜单进行自定义设置即可。
- “自定义文本”用于自定义属性标签。例如，您可以将“急速”简写为“急”。

|cffff2200本地化：
Stats+ 支持多种语言，但我仍需协助完成更多翻译工作。
如果您有意贡献，欢迎在 Curseforge 上发表评论或私信联系我。|r]]
end

-- Traditional Chinese
local L = LibStub("AceLocale-3.0"):NewLocale("Stats+", "zhTW") --zhTW
if L then
	L["Addon Name"] = "Statsplus (Stats+)"
	L["Agility"] = "敏捷"
	L["All Colors"] = "使用同樣顏色"
	L["All Stats"] = "所有屬性"
	L["Always"] = "始終"
	L["Armor"] = "護甲"
	L["Auto (show both if different)"] = "自動（若不同則同時顯示）"
	L["Avoidance"] = "迴避"
	L["Block"] = "格擋"
	L["Center"] = "居中"
	L["Click or use /st /stats"] = "點擊或使用/st /stats打開"
	L["Critical Strike"] = "致命一擊"
	L["Current + Static"] = "當前 + 靜態"
	L["Current Speed"] = "當前速度"
	L["Custom"] = "自訂"
	L["Decimal Places"] = "小數位數"
	L["Default"] = "預設"
	L["Dodge"] = "閃躲"
	L["Drag to move"] = "拖曳以移動\n/stats或/st開啟設定\n使用|cffff0000「鎖定框架」|r隱藏此文字"
	L["Equipped + Inventory"] = "實裝 + 虛裝"
	L["Equipped Only"] = "僅實裝"
	L["Font Family"] = "字型"
	L["Font Outline"] = "字型輪廓"
	L["Font Size"] = "字型尺寸"
	L["Frame Strata"] = "框架層級"
	L["Haste"] = "加速"
	L["Ilvl"] = "裝等"
	L["In Combat"] = "戰鬥中"
	L["Intellect"] = "智力"
	L["Item Level Format"] = "裝等格式"
	L["Leech"] = "汲取"
	L["Left"] = "靠左對齊"
	L["Line Spacing"] = "行距"
	L["Lock Frame Position"] = "鎖定框架"
	L["Mastery"] = "精通"
	L["Missing Stats"] = "缺失屬性"
	L["New"] = "新： "
	L["Out of Combat"] = "戰鬥外"
	L["Parry"] = "招架"
	L["Percentage + Rating"] = "百分比 + 點數"
	L["Percentage Only"] = "僅百分比"
	L["Primary Stat"] = "主屬性"
	L["Prio Based (murlok.io)"] = "基於優先級（murlok.io）"
	L["Rating + Percentage"] = "點數 + 百分比"
	L["Rating Only"] = "僅點數"
	L["Reset Colors"] = "重置顏色"
	L["Right"] = "靠右對齊"
	L["Secondaries"] = "副屬性"
	L["Secondary Stat Format"] = "副屬性格式"
	L["Show Armor"] = "展示護甲"
	L["Show Avoidance"] = "展示迴避"
	L["Show Block"] = "展示格擋"
	L["Show Dodge"] = "展示閃躲"
	L["Show Item Level"] = "展示裝備等級"
	L["Show Leech"] = "展示汲取"
	L["Show Parry"] = "展示招架"
	L["Show Primary Stat"] = "展示主屬性"
	L["Show Secondaries"] = "展示副屬性"
	L["Show Speed"] = "展示移速"
	L["Speed"] = "移速"
	L["Speed Format"] = "移動速度格式"
	L["SpeedNoticeLine1"] = "顯示移動速度可能會對遊戲效能產生輕微影響，不過通常可以忽略不計。"
	L["SpeedNoticeLine2"] = "數值越低 = 更新越頻繁，效能損失更大。"
	L["SpeedNoticeLine3"] = "使用“/stats update <數值>”來更改。當前更新頻率："
	L["Stat Ordering"] = "屬性排序"
	L["Static + Current"] = "靜態 + 當前"
	L["Static Speed"] = "靜態速度"
	L["Stats Settings /stats /st"] = "屬性統計設定 /stats /st"
	L["Stats+ Options"] = "Stats+ 設定"
	L["Strength"] = "力量"
	L["Tertiary Format"] = "第三屬性格式"
	L["Text Alignment"] = "文字對齊"
	L["UpdateIntervalSet"] = "更新頻率已設定為%s秒。"
	L["Use One Line Layout"] = "使用單行佈局"
	L["Versatility"] = "臨機應變"
	L["Versatility + Damage Reduction"] = "臨機應變 + 減傷比例"
	L["Versatility Format"] = "臨機應變格式"
	L["Versatility Only"] = "僅臨機應變"
	L["Version"] = "版本"
	L["Visibility"] = "可見性"
	L["General"] = "一般"
	L["Profiles"] = "設定檔"
	L["RELOADWARNING"] = "本次更新將重置您的插件設定。\n在進行任何更改之前，請重新載入介面或輸入“/reload”以確保新設定不被損壞。\n這是讓設定檔正常運作的必備步驟。\n祝您玩得開心 :)"
	
	L["Appearance"] = "外觀"
	L["Auto Hide Tertiaries"] = "自動隱藏第三屬性"
	L["Auto Hide Tank Stats"] = "自動隱藏坦克屬性"
	L["Custom Text"] = "自訂文字"
	L["Colors"] = "顏色"
	L["Use Background"] = "使用背景"
	L["Background Opacity"] = "背景不透明度"
	L["Show Minimap Button"] = "展示小地圖按鈕"
	L["Minimap Button L"] = "左鍵點擊：打開設置"
	L["Minimap Button R"] = "右鍵點擊：切換框架鎖定"

	L["Damage Reduction"] = "減傷"
	L["Damage Reduction + Armor"] = "減傷 + 護甲"
	L["Armor + Damage Reduction"] = "護甲 + 減傷"
	L["Armor Format"] = "護甲格式"

	L["Global Position"] = "全域位置"
	L["Profile Position"] = "個別位置"
	L["Use Global Position"] = "使用全域位置"

	L["Infos"] = "資訊"
	L["Changelog"]  = "更新日誌（僅限英文）"

	L["Stat Ordering Label"] = "請先清空右側的文字方塊，然後使用下拉選單設定順序"
	L["Auto Hide Tertiaries TOOLTIP"] = "啟用後，如果（吸血/迴避）的數值為0，則自動將其隱藏"
	L["Auto Hide Tank Stats TOOLTIP"] = "啟用後，若（招架/閃躲/格擋）非當前專精所使用，則自動將其隱藏"
	L["SpeedTooltip"] = "這可能會稍微影響效能。輸入「/stats update」了解更多資訊"

	L["Background"] = "背景"
	L["Background Color"] = "背景顏色"
	L["Background Texture"] = "背景紋理"
	L["Border Color"] = "邊框顏色"
	L["Border Offset"] = "邊框偏移"
	L["Border Opacity"] = "邊框不透明度"
	L["Border Size"] = "邊框粗細"
	L["Border Style"] = "邊框樣式"
	L["Use Border"] = "使用邊框"
	L["Extend Background"] = "擴展背景（上 右 下 左）"

	L["StatsInfoText"] = [[顯示您的角色屬性面板，涵蓋物品等級、主屬性、副屬性、第三屬性、防禦屬性等更多內容。

一般：
- 當「鎖定框架」未勾選時，背景功能將暫時停用。
- 若希望將屬性顯示為單行，請啟用「使用單行佈局」。
- 「使用全域位置」僅針對屬性框架的位置。您需要在每個設定檔中單獨調整此設定。

- 「顯示移動速度」開啟後會佔用更多 CPU 資源，因為它每隔 X 秒更新一次。使用 /stats update 指令可更改 X 的數值。
- 「自動隱藏第三屬性」將在 吸血/迴避 數值為 0 時隱藏它們。
- 「自動隱藏坦克屬性」僅在您當前為坦克專精時顯示 格擋/招架/閃躲。護甲 不包含在此規則內。

外觀：
- 「屬性排序」依據 murlok.io 的數據進行。它根據排名前 50 的玩家數據來決定您的屬性顯示優先順序。該數據每週更新（保存在 SpecPriority.lua 檔案中）。
不過您也可以使用自訂排序。只需清空文字方塊中的內容，然後使用下拉式選單進行自訂設定即可。
- 「自訂文字」用於自訂屬性標籤。例如，您可以將「加速」簡寫為「H」。

|cffff2200在地化：
Stats+ 支援多種語言，但我仍需協助完成更多翻譯工作。
如果您有意貢獻，歡迎在 Curseforge 上發表評論或私訊聯絡我。|r]]
end

-- Russian
local L = LibStub("AceLocale-3.0"):NewLocale("Stats+", "ruRU") --ruRU
if L then
	L["Addon Name"] = "Statsplus (Stats+)"
	L["Agility"] = "Ловкость"
	L["All Colors"] = "Все цвета"
	L["All Stats"] = "Вся статистика"
	L["Always"] = "Всегда"
	L["Armor"] = "Броня"
	L["Auto (show both if different)"] = "Авто (показать оба варианта, если они разные)"
	L["Avoidance"] = "Избегание"
	L["Block"] = "Блок"
	L["Center"] = "Центр"
	L["Click or use /st /stats"] = "Нажмите или введите в чат - /st, /stats"
	L["Critical Strike"] = "Крит"
	L["Current + Static"] = "Текущая + Статическая"
	L["Current Speed"] = "Текущая скорость передвижения"
	L["Custom"] = "Пользовательская"
	L["Decimal Places"] = "Десятичные знаки"
	L["Default"] = "По умолчанию"
	L["Dodge"] = "Уклонение"
	L["Drag to move"] = "Перемещение рамки\n/stats или /st, чтобы открыть настройки\nИспользуйте |cffff0000'Заблокировать положение рамки'|r, чтобы скрыть текст"
	L["Equipped + Inventory"] = "Экипировка + Инвентарь"
	L["Equipped Only"] = "Только экипировка"
	L["Font Family"] = "Шрифт"
	L["Font Outline"] = "Контур шрифта"
	L["Font Size"] = "Размер шрифта"
	L["Frame Strata"] = "Слой рамки"
	L["Haste"] = "Скорость"
	L["Ilvl"] = "Ур. предм."
	L["In Combat"] = "В бою"
	L["Intellect"] = "Интеллект"
	L["Item Level Format"] = "Уровень предметов"
	L["Leech"] = "Самоисцеление"
	L["Left"] = "Слева"
	L["Line Spacing"] = "Межстрочный интервал"
	L["Lock Frame Position"] = "Перемещение рамки"
	L["Mastery"] = "Искусность"
	L["Missing Stats"] = "Отсутствующие характеристики"
	L["New"] = "Новое: "
	L["Out of Combat"] = "Вне боя"
	L["Parry"] = "Парирование"
	L["Percentage + Rating"] = "Процент + Рейтинг"
	L["Percentage Only"] = "Только проценты"
	L["Primary Stat"] = "Основная характеристика"
	L["Prio Based (murlok.io)"] = "Приоритетная система (murlok.io)"
	L["Rating + Percentage"] = "Рейтинг + Процент"
	L["Rating Only"] = "Только рейтинг"
	L["Reset Colors"] = "Сбросить цвета"
	L["Right"] = "Справа"
	L["Secondaries"] = "Вторичные"
	L["Secondary Stat Format"] = "Вторичная статистика"
	L["Show Armor"] = "Показать броню"
	L["Show Avoidance"] = "Показать избегание"
	L["Show Block"] = "Показать блок"
	L["Show Dodge"] = "Показать уклонение"
	L["Show Item Level"] = "Показать уровень предметов"
	L["Show Leech"] = "Показать самоисцеление"
	L["Show Parry"] = "Показать парирование"
	L["Show Primary Stat"] = "Показать основную характеристику"
	L["Show Secondaries"] = "Показать вторичные"
	L["Show Speed"] = "Показать скорость передвижения"
	L["Speed"] = "Скорость передвижения"
	L["Speed Format"] = "Формат скорости передвижения"
	L["SpeedNoticeLine1"] = "Отображение показателя скорости передвижения может незначительно повлиять на производительность, хотя это влияние будет несущественным."
	L["SpeedNoticeLine2"] = "Чем ниже значение, тем чаще будут обновления и тем сильнее будет снижение производительности."
	L["SpeedNoticeLine3"] = "Используйте команду '/stats update <VALUE>' для изменения значения. Текущий интервал:"
	L["Stat Ordering"] = "Упорядочивание статистики"
	L["Static + Current"] = "Статическая + Текущая"
	L["Static Speed"] = "Статическая скорость передвижения"
	L["Stats Settings /stats /st"] = "Настройки статистики [/stats, /st]"
	L["Stats+ Options"] = "Настройки Stats+"
	L["Strength"] = "Сила"
	L["Tertiary Format"] = "Третичная статистика"
	L["Text Alignment"] = "Выравнивание текста"
	L["UpdateIntervalSet"] = "Интервал обновления установлен на %s секунд."
	L["Use One Line Layout"] = "Однострочный макет"
	L["Versatility"] = "Верса"
	L["Versatility + Damage Reduction"] = "Верса + Снижение урона"
	L["Versatility Format"] = "Универсальность"
	L["Versatility Only"] = "Только универсальность"
	L["Version"] = "Версия"
	L["Visibility"] = "Видимость"
	L["General"] = "Общие"
	L["Profiles"] = "Профили"
	L["RELOADWARNING"] = "Ваши настройки будут сброшены с этим обновлением.\n Пожалуйста, перезагрузите страницу или используйте команду /reload перед внесением каких-либо изменений, чтобы убедиться, что Ваши новые настройки не будут повреждены.\n Это необходимо для корректной работы системы профилей.\n Приятной игры :)"

	L["Appearance"] = "Внешний вид"
	L["Auto Hide Tertiaries"] = "Автоскрытие третичных характеристик"
	L["Auto Hide Tank Stats"] = "Автоскрытие характеристик танка"
	L["Custom Text"] = "Пользовательский текст"
	L["Colors"] = "Цвета"
	L["Use Background"] = "Использовать фон"
	L["Background Opacity"] = "Прозрачность фона"
	L["Show Minimap Button"] = "Показать кнопку на миникарте"
	L["Minimap Button L"] = "ЛКМ: Показать параметры"
	L["Minimap Button R"] = "ПКМ: Вкл./выкл. блокировку фрейма"

	L["Damage Reduction"] = "Снижение урона"
	L["Damage Reduction + Armor"] = "Снижение урона + Броня"
	L["Armor + Damage Reduction"] = "Броня + Снижение урона"
	L["Armor Format"] = "Формат брони"

	L["Global Position"] = "Глобальная позиция"
	L["Profile Position"] = "Положение профиля"
	L["Use Global Position"] = "Использовать глобальное положение"

	L["Infos"] = "Информация"
	L["Changelog"]  = "Список изменений (только на английском языке)"

	L["Stat Ordering Label"] = "Сначала очистите текстовый блок справа, затем используйте выпадающее меню, чтобы задать порядок"
	L["Auto Hide Tertiaries TOOLTIP"] = "Автоматически скрывать (самоисцеление/избегание), если эта функция включена и их рейтинг равен 0"
	L["Auto Hide Tank Stats TOOLTIP"] = "Автоматически скрывать (Парирование/Уклонение/Блокирование), если эта функция включена и не актуальна для Вашей специализации"
	L["SpeedTooltip"] = "Это может незначительно повлиять на производительность. Для получения дополнительной информации используйте команду '/stats update'"
	
	L["Background"] = "Фон"
	L["Background Color"] = "Цвет фона"
	L["Background Texture"] = "Фоновая текстура"
	L["Border Color"] = "Цвет границы"
	L["Border Offset"] = "Смещение границы"
	L["Border Opacity"] = "Прозрачность границы"
	L["Border Size"] = "Размер границы"
	L["Border Style"] = "Стиль границы"
	L["Use Border"] = "Использовать границу"
	L["Extend Background"] = "Расширить фон (вверх, вправо, вниз, влево)"

	L["StatsInfoText"] = [[Отображает статистику Вашего персонажа, включая уровень предметов, основные характеристики, второстепенные характеристики, третичные характеристики, защитные характеристики и многое другое.

Общее:
- Пока отключена опция 'Блокировка положения фрейма', использование в фоновом режиме будет временно отключено.
- Включите опцию «Использовать однострочный макет», если хотите, чтобы статистика отображалась в одной строке.
- Опция 'Использовать глобальное положение' предназначена для положения рамки статистики. Вам необходимо изменить этот параметр в каждом профиле.

- Опция 'Показать скорость передвижения' будет использовать больше ресурсов процессора (если включена), поскольку она обновляется каждые X секунд. Используйте команду /stats update, чтобы изменить X.
- Опция 'Автоматически скрывать третичные характеристики' скроет самоисцеление/уклонение, если их рейтинг равен 0.
- Опция 'Автоматически скрывать характеристики танка' будет отображать блок/парирование/уклонение только в том случае, если они используются Вашей текущей специализацией танка. Броня в это не входит.

Внешний вид:
- 'Порядок отображения характеристик' определяется на основе (murlok.io).
Он берет 50 лучших игроков и упорядочивает Ваши характеристики в соответствии с этим приоритетом. Это будет обновляться еженедельно (сохраняется в SpecPriority.lua).
Вы также можете использовать пользовательский порядок. По сути, удалите текст в текстовом блоке, а затем используйте выпадающее меню для его настройки.
- Пользовательский текст предназначен для настройки Ваших строк. Вместо 'Скорость' Вы можете использовать 'С'.

|cffff2200Локализация:
Stats+ поддерживает несколько языков, но мне нужна помощь с переводами.
Если Вы хотите внести свой вклад, не стесняйтесь писать мне в личные сообщения.|r]]
end

-- Korean
local L = LibStub("AceLocale-3.0"):NewLocale("Stats+", "koKR") --koKR
if L then
	L["Addon Name"] = "Statsplus (Stats+)"
	L["Agility"] = "민첩성"
	L["All Colors"] = "모든 색상 일괄"
	L["All Stats"] = "모든 항목"
	L["Always"] = "항상"
	L["Appearance"] = "외형"
	L["Armor"] = "방어도"
	L["Armor + Damage Reduction"] = "절댓값 + 물리 데미지 감소율"
	L["Armor Format"] = "방어도 표시 형식"
	L["Auto (show both if different)"] = "자동 (장착/보유 다르면 둘 다 표시)"
	L["Auto Hide Tank Stats"] = "탱커 스탯 자동 숨김"
	L["Auto Hide Tertiaries"] = "3차 스탯 0인 경우 숨김"
	L["Avoidance"] = "회피율"
	L["Background Opacity"] = "배경 투명도"
	L["Block"] = "방패 막기"
	L["Center"] = "가운데"
	L["Click or use /st /stats"] = "클릭하거나 /st /stats를 입력하세요."
	L["Colors"] = "색상"
	L["Critical Strike"] = "치명타 및 극대화"
	L["Current + Static"] = "실시간 + 고정값"
	L["Current Speed"] = "실시간"
	L["Custom"] = "직접 입력하여 설정"
	L["Custom Text"] = "항목 이름 커스터마이징"
	L["Damage Reduction"] = "물리 데미지 감소율"
	L["Damage Reduction + Armor"] = "물리 데미지 감소율 + 절댓값"
	L["Decimal Places"] = "소수점"
	L["Default"] = "기본 설정"
	L["Dodge"] = "회피율"
	L["Drag to move"] = "드래그하여 이동"
	L["Equipped + Inventory"] = "장착 + 보유"
	L["Equipped Only"] = "장착만"
	L["Font Family"] = "글꼴"
	L["Font Outline"] = "글자 외곽선"
	L["Font Size"] = "글자 크기"
	L["Frame Strata"] = "프레임 우선순위"
	L["General"] = "일반"
	L["Global Position"] = "전역 위치 (프로필 무관)"
	L["Haste"] = "가속"
	L["Ilvl"] = "아이템 레벨"
	L["In Combat"] = "전투 중"
	L["Intellect"] = "지능"
	L["Item Level Format"] = "아이템 레벨 표시 형식"
	L["Leech"] = "생기흡수"
	L["Left"] = "왼쪽"
	L["Line Spacing"] = "줄 간격"
	L["Lock Frame Position"] = "프레임 위치 잠금"
	L["Mastery"] = "특화"
	L["Minimap Button L"] = "좌클릭: 설정 창 열기"
	L["Minimap Button R"] = "우클릭: 위치 잠금 토글"
	L["Missing Stats"] = "없는 스탯들"
	L["New"] = "신규 기능: "
	L["Out of Combat"] = "비전투 중"
	L["Parry"] = "무기 막기"
	L["Percentage + Rating"] = "백분율 + 절댓값"
	L["Percentage Only"] = "백분율만"
	L["Primary Stat"] = "주 스탯"
	L["Prio Based (murlok.io)"] = "murlok.io의 우선순위 기반"
	L["Profile Position"] = "프로필 귀속 위치"
	L["Profiles"] = "프로필"
	L["Rating + Percentage"] = "절댓값 + 백분율"
	L["Rating Only"] = "절댓값만"
	L["RELOADWARNING"] = "이번 업데이트로 인해 기존 설정은 초기화 됐습니다. \\n 새로 세팅하시기 전에 리로드(/reload)를 하세요.\\n 이 과정은 프로필 기능을 정상 작동 시키기 위해 필요합니다. \\n Have fun :)"
	L["Reset Colors"] = "색상 초기화"
	L["Right"] = "오른쪽"
	L["Secondaries"] = "2차 스탯"
	L["Secondary Stat Format"] = "2차 스탯  표시 형식"
	L["Show Armor"] = "방어도 표시"
	L["Show Avoidance"] = "광역 회피 표시"
	L["Show Block"] = "방패 막기 표시"
	L["Show Dodge"] = "회피율 표시"
	L["Show Item Level"] = "아이템 레벨 표시"
	L["Show Leech"] = "생기흡수 표시"
	L["Show Minimap Button"] = "미니맵 버튼 표시"
	L["Show Parry"] = "무기 막기 표시"
	L["Show Primary Stat"] = "주 스탯 표시"
	L["Show Secondaries"] = "2차 스탯 표시"
	L["Show Speed"] = "이동 속도 표시"
	L["Speed"] = "이동 속도"
	L["Speed Format"] = "이동 속도 표시 형식"
	L["SpeedNoticeLine1"] = "이동 속도 스탯 표시는 성능에 약간의 영향을 줄 수도 있습니다. 무시할만 하다고 생각합니다만."
	L["SpeedNoticeLine2"] = "낮은 값일 수록 자주 갱신하고, 성능에는 불리합니다."
	L["SpeedNoticeLine3"] = "'/stats update <숫자>'를 입력해 설정하세요. 현재 주기값:"
	L["Stat Ordering"] = "순서 설정"
	L["Static + Current"] = "고정값 + 실시간"
	L["Static Speed"] = "고정값"
	L["Stats Settings /stats /st"] = "Stats+ 설정 (/stats /st)"
	L["Stats+ Options"] = "Stats+ 설정"
	L["Strength"] = "힘"
	L["Tertiary Format"] = "3차 스탯 표시 형식"
	L["Text Alignment"] = "문자열 정렬"
	L["UpdateIntervalSet"] = "업데이트 주기가 %s초로 설정 됨."
	L["Use Background"] = "배경 사용"
	L["Use Global Position"] = "전역 위치(프로필 무관) 사용"
	L["Use One Line Layout"] = "단일 행 레이아웃 사용"
	L["Versatility"] = "유연성"
	L["Versatility + Damage Reduction"] = "절대값 + 데미지 감소율"
	L["Versatility Format"] = "유연성 표시 형식"
	L["Versatility Only"] = "절대값 만"
	L["Version"] = "버전"
	L["Visibility"] = "보이기 (전투/비전투)"
	L["Infos"] = "정보"
	L["Changelog"]  = "변경 사항 (영어로만 제공됩니다.)"

	L["Stat Ordering Label"] = "우측 텍스트를 먼저 지운 뒤에 드롭다운을 클릭해야 목록이 보입니다"
	L["Auto Hide Tertiaries TOOLTIP"] = "생기 흡수와 광역 회피 값이 0인 경우 숨깁니다"
	L["Auto Hide Tank Stats TOOLTIP"] = "전문화와 관계 없는 스탯을 숨깁니다. 딜러/힐러라면 전부 숨깁니다. 탱커라면 직업에 따라 주요 스탯만 보여주고 나머지를 숨깁니다"
	L["SpeedTooltip"] = "성능에 영향을 미칩니다. - 자세한 설명과 설정 방법은 '/stats update'를 입력하여 확인하세요"

	L["Background"] = "배경"
	L["Background Color"] = "배경 색상"
	L["Background Texture"] = "배경 텍스쳐"
	L["Border Color"] = "테두리 색상"
	L["Border Offset"] = "테두리 여백"
	L["Border Opacity"] = "테두리 불투명도"
	L["Border Size"] = "테두리 크기"
	L["Border Style"] = "테두리 스타일"
	L["Use Border"] = "테두리 사용"
	L["Extend Background"] = "배경 확장 (위 오른쪽 아래 왼쪽)"

	L["StatsInfoText"] = [[Stats+는 아이템레벨, 주 스탯, 2차 스탯, 3차 스탯, 방어 관련 스탯 등을 표시해줍니다.

일반 탭:
- "프레임 위치 잠금"을 비활성화 한 동안은, 배경과 관련된 설정은 일시적으로 비활성화됩니다.
- "단일 행 레이아웃 사용"을 활성화하면, 모든 정보가 한 줄로 표시됩니다.
- "전역 위치(프로필 무관) 사용"을 활성화하면, 프로필에 귀속되지 않은 위치를 설정 및 사용할 수 있습니다.

- "이동 속도 표시"를 활성화하면, cpu 자원을 약간 더 사용합니다. 주기를 변경하려면 /stats update <주기(초)>를 입력하세요.
- "3차 스탯 0인 경우 숨김"을 활성화 하면, 생기흡수 / 광역회피가 0일 때 표시하지 않습니다.
- "탱커 스탯 자동 숨김"을 활성화 하면, 탱커 전문화가 아닌 경우 방패 막기/무기 막기/회피를 숨깁니다. 탱커 전문화인 경우에도 전문화와 관련된 스탯만 보여줍니다. (방어도는 이 설정과 관련이 없습니다.)

외형 탭:
- <순서 설정>구역의 "기본 설정"은 murlok.io에서 상위 50명의 스탯 우선순위를 제공합니다. 이는 매 주 업데이트 됩니다. (SpecPriority.lua에 저장됨)
"직접 입력하여 설정"할 수도 있습니다. 최우측의 텍스트를 지우고 나면, 중앙의 드롭다운 목록에서 하나씩 선택할 수 있습니다.
- <항목 이름 커스터마이징>구역에서는 모든 항목의 이름을 수동으로 설정 할 수 있습니다. 예를들면, '가속'대신 '가' 혹은 'H'를 쓰는 식으로요.

|cffff2200번역:
Stats+는 다양한 언어를 지원합니다. 이를 위해 여러분의 도움이 필요합니다.
만약 번역에 도움을 주고 싶으시다면, 커스포지의 Comments에 남겨 주시거나, 저에게 커스포지 메세지로 연락 주시길 바랍니다.|r]]
end