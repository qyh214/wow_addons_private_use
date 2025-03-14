local _, MazeHelper = ...;

local locale = GetLocale();
local convert = {
    enGB = 'enUS',
    ptPT = 'ptBR',
};
local gameLocale = convert[locale] or locale or 'enUS';

MazeHelper.currentLocale = gameLocale;

MazeHelper.L = {};
local L = MazeHelper.L;

-- https://www.wowhead.com/npc=164501/mistcaller
MazeHelper.MISTCALLER_QUOTES = {
    enUS = {
        'No fooling you!',
        'You did it! Good guess!',
        'Hooray! You\'re almost there!',
    },

    ruRU = {
        'Вас не обдурить!',
        'Получилось! Хорошая догадка!',
        'Ура! Вы почти справились!',
    },

    deDE = {
        'Euch legt man nicht rein!',
        'Geschafft! Gut geraten!',
        'Hurra! Fast geschafft!',
    },

    frFR = {
        'On ne vous la fait pas, à vous !',
        'Vous avez réussi ! Bien vu !',
        'Youpi, vous y êtes presque !',
    },

    itIT = {
        'Non ti si può ingannare!',
        'Ce l\'hai fatta! Hai indovinato!',
        'Urrà! Ci sei quasi!',
    },

    ptBR = {
        'Ninguém engana você!',
        'Você conseguiu! Belo palpite!',
        'Eba! Você está quase lá!',
    },

    esES = {
        '¡Sois la monda!',
        '¡Lo habéis logrado! ¡Bravo!',
        '¡Viva! ¡Ya casi estás!',
    },

    esMX = {

    },

    -- RainbowUI (https://www.curseforge.com/members/rainbowui)
    zhTW = {
        '瞞不過你呢！',
        '成功了！猜得好！',
        '好棒！你快到了！',
    },

    -- nanjuekaien1 (https://github.com/nanjuekaien1)
    zhCN = {
        '被你看穿了！ ',
        '你成功了！猜得真准！',
        '噢耶！你快赢了！',
    },

    koKR = {
        '안 속네?',
        '맞췄잖아? 감이 좋은데!',
        '만세! 거의 다 왔어!',
    },
};

MazeHelper.MISTCALLER_QUOTES_CURRENT = MazeHelper.MISTCALLER_QUOTES[gameLocale];

-- Common
L['SOLUTION'] = '|cff33cc66%s|r';
L['ANNOUNCE_SOLUTION'] = '%s';
L['ANNOUNCE_SOLUTION_WITH_ENGLISH'] = '%s / %s';
L['MAZE_HELPER_PRINT'] = '|cffffb833Maze Helper:|r %s';

-- English announce solution
L['ENGLISH_LEAF_FULL_CIRCLE'] = 'Filled leaf in a circle';
L['ENGLISH_LEAF_FULL_NOCIRCLE'] = 'Filled leaf without a circle';
L['ENGLISH_LEAF_NOFULL_CIRCLE'] = 'Empty leaf in a circle';
L['ENGLISH_LEAF_NOFULL_NOCIRCLE'] = 'Empty leaf without a circle';
L['ENGLISH_FLOWER_FULL_CIRCLE'] = 'Filled flower in a circle';
L['ENGLISH_FLOWER_FULL_NOCIRCLE'] = 'Filled flower without a circle';
L['ENGLISH_FLOWER_NOFULL_CIRCLE'] = 'Empty flower in a circle';
L['ENGLISH_FLOWER_NOFULL_NOCIRCLE'] = 'Empty flower without a circle';

-- Default to enUS (Google Translated from Russian with some my knowledge)
L['ZONE_NAME'] = 'Mistveil Tangle';
L['MISTCALLER_NAME'] = 'Mistcaller';
L['RESET'] = 'Reset';
L['CHOOSE_SYMBOLS_4'] = 'Select 4 symbols';
L['CHOOSE_SYMBOLS_3'] = 'Select 3 more symbols';
L['CHOOSE_SYMBOLS_2'] = 'Select 2 more symbols';
L['CHOOSE_SYMBOLS_1'] = 'Select 1 more symbol';
L['SOLUTION_NA'] = '|cffffb833There is no solution|r';
L['LEAF_FULL_CIRCLE'] = 'Filled leaf in a circle';
L['LEAF_FULL_NOCIRCLE'] = 'Filled leaf without a circle';
L['LEAF_NOFULL_CIRCLE'] = 'Empty leaf in a circle';
L['LEAF_NOFULL_NOCIRCLE'] = 'Empty leaf without a circle';
L['FLOWER_FULL_CIRCLE'] = 'Filled flower in a circle';
L['FLOWER_FULL_NOCIRCLE'] = 'Filled flower without a circle';
L['FLOWER_NOFULL_CIRCLE'] = 'Empty flower in a circle';
L['FLOWER_NOFULL_NOCIRCLE'] = 'Empty flower without a circle';
L['SENDED_BY'] = 'Sended by %s';
L['CLEARED_BY'] = 'Cleared by %s';
L['PASSED'] = 'Passed';
L['RESETED_PLAYER'] = '%s |cffff0537resetted|r this mini-game';
L['PASSED_PLAYER'] = '%s clicked on «|cff66ff6ePassed|r» button';
L['SETTINGS_REVEAL_RESETTER_LABEL'] = 'Reveal resetter of the mini-game';
L['SETTINGS_REVEAL_RESETTER_TOOLTIP'] = 'Type in the chat the name of the player who did click on the «Reset» or «Passed» button (only for yourself)';
L['SETTINGS_AUTOANNOUNCER_LABEL'] = 'Enable auto announcer';
L['SETTINGS_AUTOANNOUNCER_TOOLTIP'] = 'Automatically send a ready-made solution to the group chat';
L['SETTINGS_START_IN_MINMODE_LABEL'] = 'Start in minimized mode';
L['SETTINGS_START_IN_MINMODE_TOOLTIP'] = 'The first appearance will occur in minimized mode';
L['SETTINGS_AA_PARTY_LEADER'] = 'Party leader';
L['SETTINGS_AA_ALWAYS'] = 'Always';
L['SETTINGS_AA_TANK'] = 'Tank';
L['SETTINGS_AA_HEALER'] = 'Healer';
L['SETTINGS_SHOW_AT_BOSS_LABEL'] = 'Show at Boss';
L['SETTINGS_SHOW_AT_BOSS_TOOLTIP'] = 'Show this helper when fight with «Mistcaller»';
L['SETTINGS_SYNC_ENABLED_LABEL'] = 'Group sync';
L['SETTINGS_SYNC_ENABLED_TOOLTIP'] = 'Enable syncing of symbols selections with other group members|n|n|cffff6a00It is not recommended to turn off|r';
L['SETTINGS_USE_COLORED_SYMBOLS_LABEL'] = 'Use colored symbols';
L['SETTINGS_USE_COLORED_SYMBOLS_TOOLTIP'] = 'Use colored symbols instead of black and white';
L['SETTINGS_SHOW_SEQUENCE_NUMBERS_LABEL'] = 'Show sequence numbers';
L['SETTINGS_SHOW_SEQUENCE_NUMBERS_TOOLTIP'] = 'Show sequence numbers when clicking on symbols (1, 2, 3, 4)';
L['SETTINGS_PREDICT_SOLUTION_LABEL'] = 'Predict solution';
L['SETTINGS_PREDICT_SOLUTION_TOOLTIP'] = 'Predict the solution on 2-3 steps, but |cffff6a00first|r picked symbol |cffff6a00must be|r the entrance symbol|n|nYou can temporarily disable the prediction by clicking on the first symbol with the SHIFT pressed (or by double-click)';
L['SETTINGS_SHOW_LARGE_SYMBOL_LABEL'] = 'Show large symbol';
L['SETTINGS_SHOW_LARGE_SYMBOL_TOOLTIP'] = 'Show a large symbol at the top of the screen if there is a ready-made solution|n|nRight click to close';
L['SETTINGS_SCALE_LABEL'] = 'Scale';
L['SETTINGS_SCALE_TOOLTIP'] = 'Set the scale of the main window';
L['SETTINGS_SCALE_LARGE_SYMBOL_LABEL'] = 'Scale of large symbol';
L['SETTINGS_SCALE_LARGE_SYMBOL_TOOLTIP'] = 'Set the scale of the large symbol';
L['SETTINGS_USE_CLONE_AUTOMARKER_LABEL'] = 'Auto-marker on a clone';
L['SETTINGS_USE_CLONE_AUTOMARKER_TOOLTIP'] = 'Automatically set markers on Illusionary Clones in a boss fight|n|n|cffff6a00Note: These are markers for ease of communication, not for the solution|r';
L['SETTINGS_ANNOUNCE_WITH_ENGLISH_LABEL'] = 'Duplicate solution in English';
L['SETTINGS_ANNOUNCE_WITH_ENGLISH_TOOLTIP'] = 'Send the solution to the chat along with English phrases, for example, «Empty flower without a circle / Empty flower without a circle»';
L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_LABEL'] = 'Solution in English only';
L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_TOOLTIP'] = 'Send the solution to the chat in English only';
L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_LABEL'] = 'Set marker on player';
L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_TOOLTIP'] = 'Automatically set green marker on player if he clicked on symbol that became the solution';
L['SETTINGS_ALPHA_BACKGROUND_LABEL'] = 'Background alpha';
L['SETTINGS_ALPHA_BACKGROUND_TOOLTIP'] = 'Set the alpha for the background of the main window';
L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_LABEL'] = 'Large symbol\'s background alpha';
L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_TOOLTIP'] = 'Set the alpha for the background of the large symbol';
L['PRACTICE_TITLE'] = 'Select a symbol that differs in one way from the others';
L['PRACTICE_PLAY_AGAIN'] = 'Play again';
L['PRACTICE_BUTTON_TOOLTIP'] = 'Practice';
L['MINIMAP_BUTTON_LMB'] = 'LMB';
L['MINIMAP_BUTTON_RMB'] = 'RMB';
L['MINIMAP_BUTTON_TOGGLE_MAZEHELPER'] = 'Toggle «Maze Helper» frame';
L['MINIMAP_BUTTON_HIDE'] = 'Hide minimap button';
L['MINIMAP_BUTTON_COMMAND_SHOW'] = 'Use /mh minimap to show the minimap button again';
L['SETTINGS_AUTO_PASS_LABEL'] = 'Auto pass';
L['SETTINGS_AUTO_PASS_TOOLTIP'] = 'Auto «|cff66ff6ePassed|r» on successful passage through the mists';
L['SETTINGS_BORDERS_COLORS'] = 'Borders colors';
L['SETTINGS_ACTIVE_COLORPICKER'] = 'Selected';
L['SETTINGS_RECEIVED_COLORPICKER'] = 'Received';
L['SETTINGS_SOLUTION_COLORPICKER'] = 'Solution';
L['SETTINGS_PREDICTED_COLORPICKER'] = 'Predicted';
L['SETTINGS_SKULLMARKER_CLONE_LABEL'] = 'Skull on Clone';
L['SETTINGS_SKULLMARKER_CLONE_TOOLTIP'] = 'Automatically set the skull marker |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t to the targeted Illusionary Clone';
L['SETTINGS_SKULLMARKER_USE_MODIFIER_TOOLTIP'] = 'Use modifier key';
L['SETTINGS_AUTO_TOGGLE_VISIBILITY_LABEL'] = 'Auto show/hide';
L['SETTINGS_AUTO_TOGGLE_VISIBILITY_TOOLTIP'] = 'Automatically toggle the visibility of the main window';
L['SETTINGS_AUTOANNOUNCE_CHANNEL'] = 'Chat channel';
L['SETTINGS_AUTOANNOUNCE_CHANNEL_TOOLTIP'] = 'Select the chat channel to which the solution will be sent';
L['LOCKED_DRAG_BUTTON_TOOLTIP'] = 'Dragging is locked';
L['UNLOCKED_DRAG_BUTTON_TOOLTIP'] = 'Dragging is unlocked';

-- Русский (я)
if gameLocale == 'ruRU' then
    L['ZONE_NAME'] = 'Туманная чащоба';
    L['MISTCALLER_NAME'] = 'Призывательница Туманов';
    L['RESET'] = 'Сбросить';
    L['CHOOSE_SYMBOLS_4'] = 'Выберите 4 символа';
    L['CHOOSE_SYMBOLS_3'] = 'Выберите еще 3 символа';
    L['CHOOSE_SYMBOLS_2'] = 'Выберите еще 2 символа';
    L['CHOOSE_SYMBOLS_1'] = 'Выберите еще 1 символ';
    L['SOLUTION_NA'] = '|cffffb833Решение отсутствует|r';
    L['LEAF_FULL_CIRCLE'] = 'Полный листок в круге';
    L['LEAF_FULL_NOCIRCLE'] = 'Полный листок без круга';
    L['LEAF_NOFULL_CIRCLE'] = 'Пустой листок в круге';
    L['LEAF_NOFULL_NOCIRCLE'] = 'Пустой листок без круга';
    L['FLOWER_FULL_CIRCLE'] = 'Полный цветок в круге';
    L['FLOWER_FULL_NOCIRCLE'] = 'Полный цветок без круга';
    L['FLOWER_NOFULL_CIRCLE'] = 'Пустой цветок в круге';
    L['FLOWER_NOFULL_NOCIRCLE'] = 'Пустой цветок без круга';
    L['SENDED_BY'] = 'Отправлено: %s';
    L['CLEARED_BY'] = 'Очищено: %s';
    L['PASSED'] = 'Прошли';
    L['RESETED_PLAYER'] = '%s |cffff0537сбросил|r символы';
    L['PASSED_PLAYER'] = '%s кликнул на кнопку «|cff66ff6eПрошли|r»';
    L['SETTINGS_REVEAL_RESETTER_LABEL'] = 'Имя игрока, сбросившего символы';
    L['SETTINGS_REVEAL_RESETTER_TOOLTIP'] = 'Писать в чате имя игрока, который нажал на кнопку «Сбросить» или «Прошли» (будет видно только Вам)';
    L['SETTINGS_AUTOANNOUNCER_LABEL'] = 'Включить авто-оповещатель';
    L['SETTINGS_AUTOANNOUNCER_TOOLTIP'] = 'Автоматически отправлять в чат группы готовое решение';
    L['SETTINGS_START_IN_MINMODE_LABEL'] = 'Запускать в свернутом режиме';
    L['SETTINGS_START_IN_MINMODE_TOOLTIP'] = 'Первое появление будет происходить в свернутом режиме';
    L['SETTINGS_AA_PARTY_LEADER'] = 'Лидер группы';
    L['SETTINGS_AA_ALWAYS'] = 'Всегда';
    L['SETTINGS_AA_TANK'] = 'Танк';
    L['SETTINGS_AA_HEALER'] = 'Лекарь';
    L['SETTINGS_SHOW_AT_BOSS_LABEL'] = 'Показывать в бою с боссом';
    L['SETTINGS_SHOW_AT_BOSS_TOOLTIP'] = 'Показывать в бою с боссом «Призывательница Туманов»';
    L['SETTINGS_SYNC_ENABLED_LABEL'] = 'Синхронизация с группой';
    L['SETTINGS_SYNC_ENABLED_TOOLTIP'] = 'Включить синхронизацию выбора символов с другими участниками группы|n|n|cffff6a00Не рекомендуется выключать|r';
    L['SETTINGS_USE_COLORED_SYMBOLS_LABEL'] = 'Использовать цветные символы';
    L['SETTINGS_USE_COLORED_SYMBOLS_TOOLTIP'] = 'Использовать цветные символы вместо черно-белых';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_LABEL'] = 'Показывать порядковые номера';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_TOOLTIP'] = 'Показывать порядковые номера при нажатии на символы (1, 2, 3, 4)';
    L['SETTINGS_PREDICT_SOLUTION_LABEL'] = 'Предсказывать решение';
    L['SETTINGS_PREDICT_SOLUTION_TOOLTIP'] = 'Предсказывать решение на 2–3 шагах, но |cffff6a00первый|r выбранный символ |cffff6a00должен быть|r символом входа|n|nВы можете временно выключить предсказывание решения по клику по первому символу с нажатой клавишей SHIFT (или по двойному клику)';
    L['SETTINGS_SHOW_LARGE_SYMBOL_LABEL'] = 'Показывать большой символ';
    L['SETTINGS_SHOW_LARGE_SYMBOL_TOOLTIP'] = 'Показывать большой символ вверху экрана при наличии решения|n|nПравый клик, чтобы закрыть';
    L['SETTINGS_SCALE_LABEL'] = 'Масштаб';
    L['SETTINGS_SCALE_TOOLTIP'] = 'Задать масштаб главного окна';
    L['SETTINGS_SCALE_LARGE_SYMBOL_LABEL'] = 'Масштаб большого символа';
    L['SETTINGS_SCALE_LARGE_SYMBOL_TOOLTIP'] = 'Задать масштаб большого символа';
    L['SETTINGS_USE_CLONE_AUTOMARKER_LABEL'] = 'Авто-метки на клонов';
    L['SETTINGS_USE_CLONE_AUTOMARKER_TOOLTIP'] = 'Автоматически ставить метки на Иллюзорных клонов в бою с боссом|n|n|cffff6a00Внимание! Это маркеры для удобства коммуникации, а не для решения|r';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_LABEL'] = 'Дублировать решение на английском';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_TOOLTIP'] = 'Отправлять решение в чат вместе с английскими фразами, например, «Пустой цветок без круга / Empty flower without a circle»';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_LABEL'] = 'Решение только на английском';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_TOOLTIP'] = 'Отправлять решение в чат только на английском языке';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_LABEL'] = 'Ставить метку на игрока';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_TOOLTIP'] = 'Автоматически ставить метку на игрока, если он кликнул по символу, который стал решением';
    L['SETTINGS_ALPHA_BACKGROUND_LABEL'] = 'Видимость фона';
    L['SETTINGS_ALPHA_BACKGROUND_TOOLTIP'] = 'Задать видимость фона главного окна';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_LABEL'] = 'Видимость фона большого символа';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_TOOLTIP'] = 'Задать видимость фона большого символа';
    L['PRACTICE_TITLE'] = 'Выберите символ, отличающийся чем-то одним от других';
    L['PRACTICE_PLAY_AGAIN'] = 'Сыграть ещё';
    L['PRACTICE_BUTTON_TOOLTIP'] = 'Практика';
    L['MINIMAP_BUTTON_LMB'] = 'ЛКМ';
    L['MINIMAP_BUTTON_RMB'] = 'ПКМ';
    L['MINIMAP_BUTTON_TOGGLE_MAZEHELPER'] = 'Открыть / закрыть окно помощника';
    L['MINIMAP_BUTTON_HIDE'] = 'Скрыть кнопку у миникарты';
    L['MINIMAP_BUTTON_COMMAND_SHOW'] = 'Напишите в чате /mh minimap, чтобы снова показать кнопку у миникарты';
    L['SETTINGS_AUTO_PASS_LABEL'] = 'Авто-проход';
    L['SETTINGS_AUTO_PASS_TOOLTIP'] = 'Авто «|cff66ff6eПрошли|r» при успешном прохождении сквозь туманы';
    L['SETTINGS_BORDERS_COLORS'] = 'Цвета рамок';
    L['SETTINGS_ACTIVE_COLORPICKER'] = 'Выбранный';
    L['SETTINGS_RECEIVED_COLORPICKER'] = 'Полученный';
    L['SETTINGS_SOLUTION_COLORPICKER'] = 'Решение';
    L['SETTINGS_PREDICTED_COLORPICKER'] = 'Предсказание';
    L['SETTINGS_SKULLMARKER_CLONE_LABEL'] = 'Череп на Клона';
    L['SETTINGS_SKULLMARKER_CLONE_TOOLTIP'] = 'Автоматически ставить метку черепа |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t на Иллюзорного клона, при взятии его в цель';
    L['SETTINGS_SKULLMARKER_USE_MODIFIER_TOOLTIP'] = 'Использовать клавишу-модификатор';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_LABEL'] = 'Авто показ/скрытие';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_TOOLTIP'] = 'Автоматически управлять отображением главного окна';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL'] = 'Канал чата';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL_TOOLTIP'] = 'Выберите канал чата, в который будет отправляться решение';
    L['LOCKED_DRAG_BUTTON_TOOLTIP'] = 'Перетаскивание заблокировано';
    L['UNLOCKED_DRAG_BUTTON_TOOLTIP'] = 'Перетаскивание разблокировано';

    return;
end

-- German
-- Udaberrico (https://github.com/Udaberrico)
-- robozu (https://github.com/robozu)
-- HalbHorst (https://www.curseforge.com/members/halbhorst)
if gameLocale == 'deDE' then
    L['ZONE_NAME'] = 'Nebelschleierdickicht';
    L['MISTCALLER_NAME'] = 'Nebelruferin';
    L['RESET'] = 'Zurücksetzen';
    L['CHOOSE_SYMBOLS_4'] = 'Wählen Sie 4 Symbole';
    L['CHOOSE_SYMBOLS_3'] = 'Wählen Sie 3 weitere Symbole';
    L['CHOOSE_SYMBOLS_2'] = 'Wählen Sie 2 weitere Symbole';
    L['CHOOSE_SYMBOLS_1'] = 'Wählen Sie 1 weiteres Symbol';
    L['SOLUTION_NA'] = '|cffffb833Keine Lösung gefunden|r';
    L['LEAF_FULL_CIRCLE'] = 'Gefülltes Blatt im Kreis';
    L['LEAF_FULL_NOCIRCLE'] = 'Gefülltes Blatt ohne Kreis';
    L['LEAF_NOFULL_CIRCLE'] = 'Leeres Blatt im Kreis';
    L['LEAF_NOFULL_NOCIRCLE'] = 'Leeres Blatt ohne Kreis';
    L['FLOWER_FULL_CIRCLE'] = 'Gefüllte Blume im Kreis';
    L['FLOWER_FULL_NOCIRCLE'] = 'Gefüllte Blume ohne Kreis';
    L['FLOWER_NOFULL_CIRCLE'] = 'Leere Blume im Kreis';
    L['FLOWER_NOFULL_NOCIRCLE'] = 'Leere Blume ohne Kreis';
    L['SENDED_BY'] = 'Gesendet von %s';
    L['CLEARED_BY'] = 'Gelöscht von %s';
    L['PASSED'] = 'Bestanden';
    L['RESETED_PLAYER'] = '%s hat dieses Minispiel |cffff0537zurückgesetzt|r';
    L['PASSED_PLAYER'] = '%s klickte auf «|cff66ff6eBestanden|r»';
    L['SETTINGS_REVEAL_RESETTER_LABEL'] = 'Verrate den Resetter des Minispiels';
    L['SETTINGS_REVEAL_RESETTER_TOOLTIP'] = 'Geben Sie im Chat den Namen des Spielers ein, der auf die Schaltfläche «Zurücksetzen» oder «Bestanden» geklickt hat (nur für Sie selbst)';
    L['SETTINGS_AUTOANNOUNCER_LABEL'] = 'Aktivieren Sie die automatische Ansage';
    L['SETTINGS_AUTOANNOUNCER_TOOLTIP'] = 'Senden Sie automatisch eine vorgefertigte Lösung an den Gruppenchat';
    L['SETTINGS_START_IN_MINMODE_LABEL'] = 'Starten Sie im minimierten Modus';
    L['SETTINGS_START_IN_MINMODE_TOOLTIP'] = 'Das erste Auftreten erfolgt im minimierten Modus';
    L['SETTINGS_AA_PARTY_LEADER'] = 'Gruppenleiter';
    L['SETTINGS_AA_ALWAYS'] = 'Immer';
    L['SETTINGS_AA_TANK'] = 'Tank';
    L['SETTINGS_AA_HEALER'] = 'Heiler';
    L['SETTINGS_SHOW_AT_BOSS_LABEL'] = 'Zeige bei Boss';
    L['SETTINGS_SHOW_AT_BOSS_TOOLTIP'] = 'Zeigen Sie diesen Helfer im Kampf mit «Nebelruferin»';
    L['SETTINGS_SYNC_ENABLED_LABEL'] = 'Gruppensynchronisation';
    L['SETTINGS_SYNC_ENABLED_TOOLTIP'] = 'Aktivieren der Synchronisierung der Symbolauswahl mit anderen Gruppenmitgliedern|n|n|cffff6a00Es wird nicht empfohlen, das Gerät auszuschalten|r';
    L['SETTINGS_USE_COLORED_SYMBOLS_LABEL'] = 'Verwenden Sie farbige Symbole';
    L['SETTINGS_USE_COLORED_SYMBOLS_TOOLTIP'] = 'Verwenden Sie farbige Symbole anstelle von Schwarzweiß';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_LABEL'] = 'Sequenznummern anzeigen';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_TOOLTIP'] = 'Zeigen Sie Sequenznummern an, wenn Sie auf Symbole klicken (1, 2, 3, 4)';
    L['SETTINGS_PREDICT_SOLUTION_LABEL'] = 'Vorhersage der Lösung';
    L['SETTINGS_PREDICT_SOLUTION_TOOLTIP'] = 'Sagen Sie die Lösung in 2-3 Schritten voraus, aber |cffff6a00zuerst|r ausgewähltes Symbol |cffff6a00muss|r das Eingangssymbol sein|n|nSie können die Vorhersage vorübergehend deaktivieren, indem Sie bei gedrückter UMSCHALTTASTE auf das erste Symbol klicken (oder per Doppelklick)';
    L['SETTINGS_SHOW_LARGE_SYMBOL_LABEL'] = 'Großes Symbol anzeigen';
    L['SETTINGS_SHOW_LARGE_SYMBOL_TOOLTIP'] = 'Zeigen Sie oben auf dem Bildschirm ein großes Symbol an, wenn eine fertige Lösung vorhanden ist|n|nRechtsklick zum Schließen';
    L['SETTINGS_SCALE_LABEL'] = 'Rahmen';
    L['SETTINGS_SCALE_TOOLTIP'] = 'Stellen Sie den Maßstab des Hauptfensters ein';
    L['SETTINGS_SCALE_LARGE_SYMBOL_LABEL'] = 'Skala des großen Symbols';
    L['SETTINGS_SCALE_LARGE_SYMBOL_TOOLTIP'] = 'Stellen Sie die Skalierung des großen Symbols ein';
    L['SETTINGS_USE_CLONE_AUTOMARKER_LABEL'] = 'Auto-Marker auf einem Klon';
    L['SETTINGS_USE_CLONE_AUTOMARKER_TOOLTIP'] = 'Setze in einem Bosskampf automatisch Marker auf Illusionärer Klon|n|n|cffff6a00Achtung: Dies sind Markierungen zur Erleichterung der Kommunikation, nicht zur Lösung|r';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_LABEL'] = 'Doppelte Lösung in Englisch';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_TOOLTIP'] = 'Senden Sie die Lösung zusammen mit englischen Phrasen an den Chat, z. B. «Leere Blume ohne Kreis / Empty flower without a circle»';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_LABEL'] = 'Lösung nur auf Englisch';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_TOOLTIP'] = 'Senden Sie die Lösung nur auf Englisch an den Chat';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_LABEL'] = 'Setzen Sie einen Marker auf den Player';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_TOOLTIP'] = 'Setzen Sie automatisch eine grüne Markierung auf den Spieler, wenn er auf das Symbol klickt, das zur Lösung wurde';
    L['SETTINGS_ALPHA_BACKGROUND_LABEL'] = 'Hintergrundtransparenz';
    L['SETTINGS_ALPHA_BACKGROUND_TOOLTIP'] = 'Stellen Sie die Deckkraft für den Hintergrund des Hauptfensters ein';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_LABEL'] = 'Hintergrundtransparenz des großen Symbols';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_TOOLTIP'] = 'Stellen Sie die Deckkraft für den Hintergrund des großen Symbols ein';
    L['PRACTICE_TITLE'] = 'Wählen Sie ein Symbol aus, das sich in einer Hinsicht von den anderen unterscheidet';
    L['PRACTICE_PLAY_AGAIN'] = 'Nochmal abspielen';
    L['PRACTICE_BUTTON_TOOLTIP'] = 'Trainieren';
    L['MINIMAP_BUTTON_LMB'] = 'Linke Maustaste';
    L['MINIMAP_BUTTON_RMB'] = 'Rechte Maustaste';
    L['MINIMAP_BUTTON_TOGGLE_MAZEHELPER'] = '«Maze Helper» Rahmen an/aus';
    L['MINIMAP_BUTTON_HIDE'] = 'Minikartenschaltfläche ausblenden';
    L['MINIMAP_BUTTON_COMMAND_SHOW'] = 'Verwenden Sie /mh minimap, um das Minikartensymbol erneut anzuzeigen.';
    L['SETTINGS_AUTO_PASS_LABEL'] = 'Auto-pass';
    L['SETTINGS_AUTO_PASS_TOOLTIP'] = 'Auto «|cff66ff6eBestanden|r» bei erfolgreichem Durchgang durch die Nebel';
    L['SETTINGS_BORDERS_COLORS'] = 'Farben der Umrandung';
    L['SETTINGS_ACTIVE_COLORPICKER'] = 'Ausgewählt';
    L['SETTINGS_RECEIVED_COLORPICKER'] = 'Empfangen';
    L['SETTINGS_SOLUTION_COLORPICKER'] = 'Lösung';
    L['SETTINGS_PREDICTED_COLORPICKER'] = 'Vorausgesagt';
    L['SETTINGS_SKULLMARKER_CLONE_LABEL'] = 'Schädel auf Klon';
    L['SETTINGS_SKULLMARKER_CLONE_TOOLTIP'] = 'Setze den Schädelmarker |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t automatisch auf den Ziel-Illusionärer Klon';
    L['SETTINGS_SKULLMARKER_USE_MODIFIER_TOOLTIP'] = 'Verwenden Sie die Modifizierertaste';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_LABEL'] = 'Auto ein-/ausblenden';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_TOOLTIP'] = 'Schaltet die Sichtbarkeit des Hauptfensters automatisch um';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL'] = 'Chat-Kanal';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL_TOOLTIP'] = 'Wählen Sie den Chat-Kanal, an den die Lösung gesendet werden soll';
    L['LOCKED_DRAG_BUTTON_TOOLTIP'] = 'Ziehen ist gesperrt';
    L['UNLOCKED_DRAG_BUTTON_TOOLTIP'] = 'Ziehen ist freigeschaltet';

    return;
end

-- French
-- BlondeLegendaire (https://www.curseforge.com/members/blondelegendaire/)
if gameLocale == 'frFR' then
    L['ZONE_NAME'] = 'Maquis Voile-de-Brume';
    L['MISTCALLER_NAME'] = 'Mandebrume';
    L['RESET'] = 'Reset';
    L['CHOOSE_SYMBOLS_4'] = 'Sélectionnez 4 symboles';
    L['CHOOSE_SYMBOLS_3'] = 'Sélectionnez 3 autres symboles';
    L['CHOOSE_SYMBOLS_2'] = 'Sélectionnez 2 autres symboles';
    L['CHOOSE_SYMBOLS_1'] = 'Sélectionnez 1 autre symbole';
    L['SOLUTION_NA'] = '|cffffb833Il n\'y a pas de solution|r';
    L['LEAF_FULL_CIRCLE'] = 'Feuille remplie dans un cercle';
    L['LEAF_FULL_NOCIRCLE'] = 'Feuille remplie sans cercle';
    L['LEAF_NOFULL_CIRCLE'] = 'Feuille vide dans un cercle';
    L['LEAF_NOFULL_NOCIRCLE'] = 'Feuille vide sans cercle';
    L['FLOWER_FULL_CIRCLE'] = 'Fleur remplie dans un cercle';
    L['FLOWER_FULL_NOCIRCLE'] = 'Fleur remplie sans cercle';
    L['FLOWER_NOFULL_CIRCLE'] = 'Fleur vide dans un cercle';
    L['FLOWER_NOFULL_NOCIRCLE'] = 'Fleur vide sans cercle';
    L['SENDED_BY'] = 'Envoyé par %s';
    L['CLEARED_BY'] = 'Innocenté par %s';
    L['PASSED'] = 'Passer';
    L['RESETED_PLAYER'] = '%s a |cffff0537réinitialisé|r ce mini-jeu';
    L['PASSED_PLAYER'] = '%s a cliqué sur le bouton «|cff66ff6ePasser|r»';
    L['SETTINGS_REVEAL_RESETTER_LABEL'] = 'Reveal resetter du mini-jeu';
    L['SETTINGS_REVEAL_RESETTER_TOOLTIP'] = 'Tapez dans le chat le nom du joueur qui a cliqué sur le bouton «Réinitialiser» ou «Passé» (uniquement pour vous)';
    L['SETTINGS_AUTOANNOUNCER_LABEL'] = 'Activer l\'annonceur automatique';
    L['SETTINGS_AUTOANNOUNCER_TOOLTIP'] = 'Envoyez automatiquement une solution prête à l\'emploi au chat de groupe';
    L['SETTINGS_START_IN_MINMODE_LABEL'] = 'Démarrez en mode réduit';
    L['SETTINGS_START_IN_MINMODE_TOOLTIP'] = 'La première apparition se produira en mode réduit';
    L['SETTINGS_AA_PARTY_LEADER'] = 'Le chef du parti';
    L['SETTINGS_AA_ALWAYS'] = 'Toujours';
    L['SETTINGS_AA_TANK'] = 'Tank';
    L['SETTINGS_AA_HEALER'] = 'Soins';
    L['SETTINGS_SHOW_AT_BOSS_LABEL'] = 'Montrer chez Boss';
    L['SETTINGS_SHOW_AT_BOSS_TOOLTIP'] = 'Montrez cet assistant lorsque vous vous battez avec «Mandebrume»';
    L['SETTINGS_SYNC_ENABLED_LABEL'] = 'Synchronisation de groupe';
    L['SETTINGS_SYNC_ENABLED_TOOLTIP'] = 'Activer la synchronisation des sélections de symboles avec d\'autres membres du groupe|n|n|cffff6a00Il n\'est pas recommandé de désactiver|r';
    L['SETTINGS_USE_COLORED_SYMBOLS_LABEL'] = 'Utilisez des symboles colorés';
    L['SETTINGS_USE_COLORED_SYMBOLS_TOOLTIP'] = 'Utilisez des symboles colorés au lieu du noir et blanc';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_LABEL'] = 'Afficher les numéros de séquence';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_TOOLTIP'] = 'Afficher les numéros de séquence en cliquant sur les symboles (1, 2, 3, 4)';
    L['SETTINGS_PREDICT_SOLUTION_LABEL'] = 'Solution de prédiction';
    L['SETTINGS_PREDICT_SOLUTION_TOOLTIP'] = 'Prédire la solution sur 2-3 étapes, mais |cffff6a00en premier|r symbole choisi |cffff6a00doit être|r le symbole d\'entrée|n|nVous pouvez désactiver temporairement la prédiction en cliquant sur le premier symbole avec la touche SHIFT enfoncée (ou par double clic)';
    L['SETTINGS_SHOW_LARGE_SYMBOL_LABEL'] = 'Afficher le grand symbole';
    L['SETTINGS_SHOW_LARGE_SYMBOL_TOOLTIP'] = 'Afficher un grand symbole en haut de l\'écran s\'il existe une solution toute faite|n|nClic droit pour fermer';
    L['SETTINGS_SCALE_LABEL'] = 'Échelle';
    L['SETTINGS_SCALE_TOOLTIP'] = 'Réglez l\'échelle de la fenêtre principale';
    L['SETTINGS_SCALE_LARGE_SYMBOL_LABEL'] = 'Échelle du grand symbole';
    L['SETTINGS_SCALE_LARGE_SYMBOL_TOOLTIP'] = 'Définir l\'échelle du grand symbole';
    L['SETTINGS_USE_CLONE_AUTOMARKER_LABEL'] = 'Auto-marqueur sur un clone';
    L['SETTINGS_USE_CLONE_AUTOMARKER_TOOLTIP'] = 'Mettre automatiquement des marqueurs sur les Clones illusoires dans un combat de boss|n|n|cffff6a00Attention: Il s\'agit de repères pour faciliter la communication, et non d\'une solution.|r';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_LABEL'] = 'Dupliquer la solution en anglais';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_TOOLTIP'] = 'Envoyez la solution au chat avec des phrases en anglais, par exemple, «Fleur vide sans cercle / Empty flower without a circle»';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_LABEL'] = 'Solution en anglais uniquement';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_TOOLTIP'] = 'Envoyez la solution au chat en anglais uniquement';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_LABEL'] = 'Placer un marqueur sur le joueur';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_TOOLTIP'] = 'Définir automatiquement le marqueur vert sur le joueur s\'il clique sur le symbole qui est devenu la solution';
    L['SETTINGS_ALPHA_BACKGROUND_LABEL'] = 'Opacité de l\'arrière-plan';
    L['SETTINGS_ALPHA_BACKGROUND_TOOLTIP'] = 'Définir l\'opacité de l\'arrière-plan de la fenêtre principale';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_LABEL'] = 'Opacité d\'arrière-plan du grand symbole';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_TOOLTIP'] = 'Définir l\'opacité de l\'arrière-plan du grand symbole';
    L['PRACTICE_TITLE'] = 'Sélectionnez un symbole qui diffère d\'une manière des autres';
    L['PRACTICE_PLAY_AGAIN'] = 'Rejouer';
    L['PRACTICE_BUTTON_TOOLTIP'] = 'La pratique';
    L['MINIMAP_BUTTON_LMB'] = 'Bouton gauche';
    L['MINIMAP_BUTTON_RMB'] = 'Bouton de droite';
    L['MINIMAP_BUTTON_TOGGLE_MAZEHELPER'] = 'Basculer la fenêtre «Maze Helper»';
    L['MINIMAP_BUTTON_HIDE'] = 'Masquer le bouton de la minicarte';
    L['MINIMAP_BUTTON_COMMAND_SHOW'] = 'Utiliser /mh minimap pour afficher à nouveau l\'icône de minicarte';
    L['SETTINGS_AUTO_PASS_LABEL'] = 'Auto pass';
    L['SETTINGS_AUTO_PASS_TOOLTIP'] = 'Auto «|cff66ff6ePasser|r» sur un passage réussi dans les brumes';
    L['SETTINGS_BORDERS_COLORS'] = 'Couleurs des bordures';
    L['SETTINGS_ACTIVE_COLORPICKER'] = 'Choisi';
    L['SETTINGS_RECEIVED_COLORPICKER'] = 'A reçu';
    L['SETTINGS_SOLUTION_COLORPICKER'] = 'Solution';
    L['SETTINGS_PREDICTED_COLORPICKER'] = 'Prédite';
    L['SETTINGS_SKULLMARKER_CLONE_LABEL'] = 'Crâne sur Clone';
    L['SETTINGS_SKULLMARKER_CLONE_TOOLTIP'] = 'Définissez automatiquement le marqueur de crâne |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t sur le Clone illusoire ciblé';
    L['SETTINGS_SKULLMARKER_USE_MODIFIER_TOOLTIP'] = 'Utiliser la touche de modification';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_LABEL'] = 'Afficher/masquer automatiquement';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_TOOLTIP'] = 'Basculer automatiquement la visibilité de la fenêtre principale';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL'] = 'Canal de chat';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL_TOOLTIP'] = 'Sélectionnez le canal de chat auquel la solution sera envoyée.';
    L['LOCKED_DRAG_BUTTON_TOOLTIP'] = 'La drague est verrouillée';
    L['UNLOCKED_DRAG_BUTTON_TOOLTIP'] = 'Le glisser est déverrouillé';

    return;
end

-- Italian (Google Translate)
if gameLocale == 'itIT' then
    L['ZONE_NAME'] = 'Intrico Velofosco';
    L['MISTCALLER_NAME'] = 'Evocanebbie';
    L['RESET'] = 'Ripristina';
    L['CHOOSE_SYMBOLS_4'] = 'Seleziona 4 simboli';
    L['CHOOSE_SYMBOLS_3'] = 'Seleziona altri 3 simboli';
    L['CHOOSE_SYMBOLS_2'] = 'Seleziona altri 2 simboli';
    L['CHOOSE_SYMBOLS_1'] = 'Seleziona 1 altro simbolo';
    L['SOLUTION_NA'] = '|cffffb833Non c\'è soluzione|r';
    L['LEAF_FULL_CIRCLE'] = 'Foglia piena in un cerchio';
    L['LEAF_FULL_NOCIRCLE'] = 'Foglia piena senza cerchio';
    L['LEAF_NOFULL_CIRCLE'] = 'Foglia vuota in un cerchio';
    L['LEAF_NOFULL_NOCIRCLE'] = 'Foglia vuota senza cerchio';
    L['FLOWER_FULL_CIRCLE'] = 'Fiore pieno in un cerchio';
    L['FLOWER_FULL_NOCIRCLE'] = 'Fiore pieno senza cerchio';
    L['FLOWER_NOFULL_CIRCLE'] = 'Fiore vuoto in un cerchio';
    L['FLOWER_NOFULL_NOCIRCLE'] = 'Fiore vuoto senza cerchio';
    L['SENDED_BY'] = 'Inviato da %s';
    L['CLEARED_BY'] = 'Cancellato da %s';
    L['PASSED'] = 'Passato';
    L['RESETED_PLAYER'] = '%s |cffff0537ha ripristinato|r questo minigioco';
    L['PASSED_PLAYER'] = '%s ha fatto clic sul pulsante «|cff66ff6ePassato|r»';
    L['SETTINGS_REVEAL_RESETTER_LABEL'] = 'Rivela il resetter del mini-gioco';
    L['SETTINGS_REVEAL_RESETTER_TOOLTIP'] = 'Digita nella chat il nome del giocatore che ha fatto clic sul pulsante «Ripristina» o «Passato» (solo per te)';
    L['SETTINGS_AUTOANNOUNCER_LABEL'] = 'Abilita annunciatore automatico';
    L['SETTINGS_AUTOANNOUNCER_TOOLTIP'] = 'Invia automaticamente una soluzione già pronta alla chat di gruppo';
    L['SETTINGS_START_IN_MINMODE_LABEL'] = 'Inizia in modalità ridotta a icona';
    L['SETTINGS_START_IN_MINMODE_TOOLTIP'] = 'La prima apparizione si verificherà in modalità ridotta a icona';
    L['SETTINGS_AA_PARTY_LEADER'] = 'Leader del partito';
    L['SETTINGS_AA_ALWAYS'] = 'Sempre';
    L['SETTINGS_AA_TANK'] = 'Difensore';
    L['SETTINGS_AA_HEALER'] = 'Guaritore';
    L['SETTINGS_SHOW_AT_BOSS_LABEL'] = 'Mostra al Boss';
    L['SETTINGS_SHOW_AT_BOSS_TOOLTIP'] = 'Mostra questo aiutante quando combatti con «Evocanebbie»';
    L['SETTINGS_SYNC_ENABLED_LABEL'] = 'Sincronizzazione di gruppo';
    L['SETTINGS_SYNC_ENABLED_TOOLTIP'] = 'Abilita la sincronizzazione delle selezioni dei simboli con altri membri del gruppo|n|n|cffff6a00Non è consigliabile disattivare|r';
    L['SETTINGS_USE_COLORED_SYMBOLS_LABEL'] = 'Usa simboli colorati';
    L['SETTINGS_USE_COLORED_SYMBOLS_TOOLTIP'] = 'Usa simboli colorati invece del bianco e nero';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_LABEL'] = 'Mostra i numeri di sequenza';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_TOOLTIP'] = 'Mostra i numeri di sequenza quando si fa clic sui simboli (1, 2, 3, 4)';
    L['SETTINGS_PREDICT_SOLUTION_LABEL'] = 'Predire soluzione';
    L['SETTINGS_PREDICT_SOLUTION_TOOLTIP'] = 'Prevedere la soluzione su 2-3 passaggi, ma |cffff6a00il primo|r scelto simbolo |cffff6a00deve essere|r il simbolo di entrata|n|nÈ possibile disabilitare temporaneamente la previsione facendo clic sul primo simbolo con MAIUSC premuto (o con doppio clic)';
    L['SETTINGS_SHOW_LARGE_SYMBOL_LABEL'] = 'Mostra il simbolo grande';
    L['SETTINGS_SHOW_LARGE_SYMBOL_TOOLTIP'] = 'Mostra un grande simbolo nella parte superiore dello schermo se c\'è una soluzione già pronta|n|nFare clic con il tasto destro per chiudere';
    L['SETTINGS_SCALE_LABEL'] = 'Scala';
    L['SETTINGS_SCALE_TOOLTIP'] = 'Imposta la scala della finestra principale';
    L['SETTINGS_SCALE_LARGE_SYMBOL_LABEL'] = 'Scala di grande simbolo';
    L['SETTINGS_SCALE_LARGE_SYMBOL_TOOLTIP'] = 'Imposta la scala del simbolo grande';
    L['SETTINGS_USE_CLONE_AUTOMARKER_LABEL'] = 'Auto-marcatore su un clone';
    L['SETTINGS_USE_CLONE_AUTOMARKER_TOOLTIP'] = 'Metti automaticamente i segnalini sui Clone Illusorio in una lotta con un boss|n|n|cffff6a00Attenzione: questi sono marcatori per facilitare la comunicazione, non una soluzione|r';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_LABEL'] = 'Soluzione duplicata in inglese';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_TOOLTIP'] = 'Invia la soluzione alla chat insieme a frasi in inglese, ad esempio, «Fiore vuoto senza cerchio / Empty flower without a circle»';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_LABEL'] = 'Soluzione solo in inglese';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_TOOLTIP'] = 'Invia la soluzione alla chat solo in inglese';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_LABEL'] = 'Imposta un indicatore sul giocatore';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_TOOLTIP'] = 'Imposta automaticamente l\'indicatore verde sul giocatore se ha cliccato sul simbolo che è diventato la soluzione';
    L['SETTINGS_ALPHA_BACKGROUND_LABEL'] = 'Opacità dello sfondo';
    L['SETTINGS_ALPHA_BACKGROUND_TOOLTIP'] = 'Imposta l\'opacità per lo sfondo della finestra principale';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_LABEL'] = 'Opacità dello sfondo del simbolo grande';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_TOOLTIP'] = 'Imposta l\'opacità per lo sfondo del simbolo grande';
    L['PRACTICE_TITLE'] = 'Seleziona un simbolo che differisce in un modo dagli altri';
    L['PRACTICE_PLAY_AGAIN'] = 'Gioca di nuovo';
    L['PRACTICE_BUTTON_TOOLTIP'] = 'Pratica';
    L['MINIMAP_BUTTON_LMB'] = 'Pulsante di sinistra';
    L['MINIMAP_BUTTON_RMB'] = 'Pulsante destro';
    L['MINIMAP_BUTTON_TOGGLE_MAZEHELPER'] = 'Attiva / disattiva la finestra «Maze Helper»';
    L['MINIMAP_BUTTON_HIDE'] = 'Nascondi pulsante minimappa';
    L['MINIMAP_BUTTON_COMMAND_SHOW'] = 'Usa /mh minimap per mostrare di nuovo il pulsante minimappa';
    L['SETTINGS_AUTO_PASS_LABEL'] = 'Passaggio automatico';
    L['SETTINGS_AUTO_PASS_TOOLTIP'] = 'Automatico «|cff66ff6ePassato|r» sul passaggio riuscito attraverso le nebbie';
    L['SETTINGS_BORDERS_COLORS'] = 'Colori dei bordi';
    L['SETTINGS_ACTIVE_COLORPICKER'] = 'Selezionato';
    L['SETTINGS_RECEIVED_COLORPICKER'] = 'Ricevuto';
    L['SETTINGS_SOLUTION_COLORPICKER'] = 'Soluzione';
    L['SETTINGS_PREDICTED_COLORPICKER'] = 'Predetto';
    L['SETTINGS_SKULLMARKER_CLONE_LABEL'] = 'Teschio su Clone';
    L['SETTINGS_SKULLMARKER_CLONE_TOOLTIP'] = 'Imposta automaticamente l\'indicatore del teschio |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t sul Clone Illusorio scelto';
    L['SETTINGS_SKULLMARKER_USE_MODIFIER_TOOLTIP'] = 'Usa il tasto modificatore';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_LABEL'] = 'Mostra/nascondi automaticamente';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_TOOLTIP'] = 'Attiva/disattiva automaticamente la visibilità della finestra principale';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL'] = 'Canale chat';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL_TOOLTIP'] = 'Seleziona il canale di chat a cui verrà inviata la soluzione';
    L['LOCKED_DRAG_BUTTON_TOOLTIP'] = 'Il trascinamento è bloccato';
    L['UNLOCKED_DRAG_BUTTON_TOOLTIP'] = 'Il trascinamento è sbloccato';

    return;
end

-- Brazilian Portuguese
-- edsonsv1 (https://www.curseforge.com/members/edsonsv1)
if gameLocale == 'ptBR' then
    L['ZONE_NAME'] = 'Enleio do Véu da Névoa';
    L['MISTCALLER_NAME'] = 'Chamabruma';
    L['RESET'] = 'Redefinir';
    L['CHOOSE_SYMBOLS_4'] = 'Selecione 4 símbolos';
    L['CHOOSE_SYMBOLS_3'] = 'Selecione mais 3 símbolos';
    L['CHOOSE_SYMBOLS_2'] = 'Selecione mais 2 símbolos';
    L['CHOOSE_SYMBOLS_1'] = 'Selecione mais 1 símbolo';
    L['SOLUTION_NA'] = '|cffffb833Não há solução|r';
    L['LEAF_FULL_CIRCLE'] = 'Folha preenchida em um círculo';
    L['LEAF_FULL_NOCIRCLE'] = 'Folha preenchida sem círculo';
    L['LEAF_NOFULL_CIRCLE'] = 'Folha vazia em um círculo';
    L['LEAF_NOFULL_NOCIRCLE'] = 'Folha vazia sem círculo';
    L['FLOWER_FULL_CIRCLE'] = 'Flor cheia em um círculo';
    L['FLOWER_FULL_NOCIRCLE'] = 'Flor cheia sem círculo';
    L['FLOWER_NOFULL_CIRCLE'] = 'Flor vazia em um círculo';
    L['FLOWER_NOFULL_NOCIRCLE'] = 'Flor vazia sem círculo';
    L['SENDED_BY'] = 'Enviado por %s';
    L['CLEARED_BY'] = 'Apagado por %s';
    L['PASSED'] = 'Passado';
    L['RESETED_PLAYER'] = '%s |cffff0537redefiniu|r este minijogo';
    L['PASSED_PLAYER'] = '%s clicou no botão «|cff66ff6ePassado|r»';
    L['SETTINGS_REVEAL_RESETTER_LABEL'] = 'Revelar a reinicialização do minijogo';
    L['SETTINGS_REVEAL_RESETTER_TOOLTIP'] = 'Digite no chat o nome do jogador que clicou no botão «Redefinir» ou «Passado» (apenas para você)';
    L['SETTINGS_AUTOANNOUNCER_LABEL'] = 'Ativar locutor automático';
    L['SETTINGS_AUTOANNOUNCER_TOOLTIP'] = 'Envie automaticamente uma solução pronta para o chat em grupo';
    L['SETTINGS_START_IN_MINMODE_LABEL'] = 'Comece no modo minimizado';
    L['SETTINGS_START_IN_MINMODE_TOOLTIP'] = 'A primeira aparição ocorrerá no modo minimizado';
    L['SETTINGS_AA_PARTY_LEADER'] = 'Líder de partido';
    L['SETTINGS_AA_ALWAYS'] = 'Sempre';
    L['SETTINGS_AA_TANK'] = 'Tanque';
    L['SETTINGS_AA_HEALER'] = 'Cura';
    L['SETTINGS_SHOW_AT_BOSS_LABEL'] = 'Mostrar no Boss';
    L['SETTINGS_SHOW_AT_BOSS_TOOLTIP'] = 'Mostre este ajudante quando lutar com «Chamabruma»';
    L['SETTINGS_SYNC_ENABLED_LABEL'] = 'Sincronização de grupo';
    L['SETTINGS_SYNC_ENABLED_TOOLTIP'] = 'Habilite a sincronização de seleções de símbolos com outros membros do grupo|n|n|cffff6a00Não é recomendado desligar|r';
    L['SETTINGS_USE_COLORED_SYMBOLS_LABEL'] = 'Use símbolos coloridos';
    L['SETTINGS_USE_COLORED_SYMBOLS_TOOLTIP'] = 'Use símbolos coloridos em vez de preto e branco';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_LABEL'] = 'Mostrar números de sequência';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_TOOLTIP'] = 'Mostrar números de sequência ao clicar nos símbolos (1, 2, 3, 4)';
    L['SETTINGS_PREDICT_SOLUTION_LABEL'] = 'Solução de previsão';
    L['SETTINGS_PREDICT_SOLUTION_TOOLTIP'] = 'Preveja a solução em 2-3 etapas, mas |cffff6a00primeiro|r escolheu o símbolo |cffff6a00deve ser|r o símbolo de entrada|n|nVocê pode desativar temporariamente a previsão clicando no primeiro símbolo com a tecla SHIFT pressionada (ou por duplo clique)';
    L['SETTINGS_SHOW_LARGE_SYMBOL_LABEL'] = 'Mostrar símbolo grande';
    L['SETTINGS_SHOW_LARGE_SYMBOL_TOOLTIP'] = 'Mostra um grande símbolo no topo da tela se houver uma solução pronta|n|nClique com o botão direito para fechar';
    L['SETTINGS_SCALE_LABEL'] = 'Escala';
    L['SETTINGS_SCALE_TOOLTIP'] = 'Defina a escala da janela principal';
    L['SETTINGS_SCALE_LARGE_SYMBOL_LABEL'] = 'Escala de grande símbolo';
    L['SETTINGS_SCALE_LARGE_SYMBOL_TOOLTIP'] = 'Defina a escala do símbolo grande';
    L['SETTINGS_USE_CLONE_AUTOMARKER_LABEL'] = 'Auto-marcador em um clone';
    L['SETTINGS_USE_CLONE_AUTOMARKER_TOOLTIP'] = 'Colocar marcadores automaticamente em Clones Ilusórios em uma luta de chefe|n|n|cffff6a00Cuidado: Estes são marcadores para facilitar a comunicação, não uma solução|r';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_LABEL'] = 'Solução duplicada em inglês';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_TOOLTIP'] = 'Envie a solução para o chat junto com frases em inglês, por exemplo, «Flor vazia sem círculo / Empty flower without a circle»';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_LABEL'] = 'Solução apenas em inglês';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_TOOLTIP'] = 'Envie a solução para o chat apenas em inglês';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_LABEL'] = 'Definir marcador no jogador';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_TOOLTIP'] = 'Definir marcador verde automaticamente no jogador se ele clicar no símbolo que se tornou a solução';
    L['SETTINGS_ALPHA_BACKGROUND_LABEL'] = 'Opacidade de Fundo';
    L['SETTINGS_ALPHA_BACKGROUND_TOOLTIP'] = 'Defina a opacidade do plano de fundo da janela principal';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_LABEL'] = 'Opacidade de fundo do símbolo grande';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_TOOLTIP'] = 'Defina a opacidade do fundo do símbolo grande';
    L['PRACTICE_TITLE'] = 'Selecione um símbolo que difere de uma forma dos outros';
    L['PRACTICE_PLAY_AGAIN'] = 'Jogar de novo';
    L['PRACTICE_BUTTON_TOOLTIP'] = 'Prática';
    L['MINIMAP_BUTTON_LMB'] = 'Botão esquerdo';
    L['MINIMAP_BUTTON_RMB'] = 'Botão direito';
    L['MINIMAP_BUTTON_TOGGLE_MAZEHELPER'] = 'Alternar a janela «Maze Helper»';
    L['MINIMAP_BUTTON_HIDE'] = 'Ocultar botão de minimapa';
    L['MINIMAP_BUTTON_COMMAND_SHOW'] = 'Use /mh minimap para mostrar o ícone do mini mapa novamente';
    L['SETTINGS_AUTO_PASS_LABEL'] = 'Passe automático';
    L['SETTINGS_AUTO_PASS_TOOLTIP'] = 'Automático «|cff66ff6ePassado|r» na passagem bem sucedida pelas brumas';
    L['SETTINGS_BORDERS_COLORS'] = 'Cor das bordas';
    L['SETTINGS_ACTIVE_COLORPICKER'] = 'Selecionado';
    L['SETTINGS_RECEIVED_COLORPICKER'] = 'Recebido';
    L['SETTINGS_SOLUTION_COLORPICKER'] = 'Solução';
    L['SETTINGS_PREDICTED_COLORPICKER'] = 'Previsto';
    L['SETTINGS_SKULLMARKER_CLONE_LABEL'] = 'Crânio em um Clone';
    L['SETTINGS_SKULLMARKER_CLONE_TOOLTIP'] = 'Defina automaticamente o marcador de caveira |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t para o Clone Ilusório visado';
    L['SETTINGS_SKULLMARKER_USE_MODIFIER_TOOLTIP'] = 'Use a tecla modificadora';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_LABEL'] = 'Mostrar/ocultar automaticamente';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_TOOLTIP'] = 'Alterna automaticamente a visibilidade da janela principal';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL'] = 'Canal de bate-papo';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL_TOOLTIP'] = 'Selecione o canal de bate-papo para o qual a solução será enviada';
    L['LOCKED_DRAG_BUTTON_TOOLTIP'] = 'O arrasto está bloqueado';
    L['UNLOCKED_DRAG_BUTTON_TOOLTIP'] = 'O arrasto é desbloqueado';

    return;
end

-- Spanish (Google Translate)
if gameLocale == 'esES' then
    L['ZONE_NAME'] = 'Espesura Velo de Niebla';
    L['MISTCALLER_NAME'] = 'Clamaneblina';
    L['RESET'] = 'Reiniciar';
    L['CHOOSE_SYMBOLS_4'] = 'Seleccione 4 símbolos';
    L['CHOOSE_SYMBOLS_3'] = 'Seleccione 3 símbolos más';
    L['CHOOSE_SYMBOLS_2'] = 'Seleccione 2 símbolos más';
    L['CHOOSE_SYMBOLS_1'] = 'Seleccione 1 símbolo más';
    L['SOLUTION_NA'] = '|cffffb833No hay solución|r';
    L['LEAF_FULL_CIRCLE'] = 'Hoja llena en un círculo';
    L['LEAF_FULL_NOCIRCLE'] = 'Hoja llena sin círculo';
    L['LEAF_NOFULL_CIRCLE'] = 'Hoja vacía en un círculo';
    L['LEAF_NOFULL_NOCIRCLE'] = 'Hoja vacía sin círculo';
    L['FLOWER_FULL_CIRCLE'] = 'Flor llena en un círculo';
    L['FLOWER_FULL_NOCIRCLE'] = 'Flor llena sin círculo';
    L['FLOWER_NOFULL_CIRCLE'] = 'Flor vacía en un círculo';
    L['FLOWER_NOFULL_NOCIRCLE'] = 'Flor vacía sin círculo';
    L['SENDED_BY'] = 'Enviado por %s';
    L['CLEARED_BY'] = 'Despejado por %s';
    L['PASSED'] = 'Aprobado';
    L['RESETED_PLAYER'] = '%s |cffff0537resetted|r este minijuego';
    L['PASSED_PLAYER'] = '%s hizo clic en el botón «|cff66ff6eAprobado|r»';
    L['SETTINGS_REVEAL_RESETTER_LABEL'] = 'Revelar reiniciador del minijuego';
    L['SETTINGS_REVEAL_RESETTER_TOOLTIP'] = 'Escribe en el chat el nombre del jugador que hizo clic en el botón «Reiniciar» o «Aprobado» (solo para ti)';
    L['SETTINGS_AUTOANNOUNCER_LABEL'] = 'Habilitar auto locutor';
    L['SETTINGS_AUTOANNOUNCER_TOOLTIP'] = 'Envíe automáticamente una solución preparada al chat grupal';
    L['SETTINGS_START_IN_MINMODE_LABEL'] = 'Comience en modo minimizado';
    L['SETTINGS_START_IN_MINMODE_TOOLTIP'] = 'La primera aparición ocurrirá en modo minimizado';
    L['SETTINGS_AA_PARTY_LEADER'] = 'Líder del partido';
    L['SETTINGS_AA_ALWAYS'] = 'Siempre';
    L['SETTINGS_AA_TANK'] = 'Tanque';
    L['SETTINGS_AA_HEALER'] = 'Sanador';
    L['SETTINGS_SHOW_AT_BOSS_LABEL'] = 'Mostrar al jefe';
    L['SETTINGS_SHOW_AT_BOSS_TOOLTIP'] = 'Mostrar este ayudante cuando lucha con «Clamaneblina»';
    L['SETTINGS_SYNC_ENABLED_LABEL'] = 'Sincronización grupal';
    L['SETTINGS_SYNC_ENABLED_TOOLTIP'] = 'Habilitar la sincronización de selecciones de símbolos con otros miembros del grupo|n|n|cffff6a00No se recomienda desactivar|r';
    L['SETTINGS_USE_COLORED_SYMBOLS_LABEL'] = 'Usa símbolos de colores';
    L['SETTINGS_USE_COLORED_SYMBOLS_TOOLTIP'] = 'Utilice símbolos de colores en lugar de blanco y negro';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_LABEL'] = 'Mostrar números de secuencia';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_TOOLTIP'] = 'Mostrar números de secuencia al hacer clic en los símbolos (1, 2, 3, 4)';
    L['SETTINGS_PREDICT_SOLUTION_LABEL'] = 'Predecir solución';
    L['SETTINGS_PREDICT_SOLUTION_TOOLTIP'] = 'Predecir la solución en 2-3 pasos, pero |cffff6a00el primer|r símbolo elegido |cffff6a00debe ser|r el símbolo de entrada|n|nPuede deshabilitar temporalmente la predicción haciendo clic en el primer símbolo con la tecla MAYÚS presionada (o haciendo doble clic)';
    L['SETTINGS_SHOW_LARGE_SYMBOL_LABEL'] = 'Mostrar símbolo grande';
    L['SETTINGS_SHOW_LARGE_SYMBOL_TOOLTIP'] = 'Muestre un símbolo grande en la parte superior de la pantalla si hay una solución preparada|n|nClick derecho para cerrar';
    L['SETTINGS_SCALE_LABEL'] = 'Escala';
    L['SETTINGS_SCALE_TOOLTIP'] = 'Establecer la escala de la ventana principal';
    L['SETTINGS_SCALE_LARGE_SYMBOL_LABEL'] = 'Escala de símbolo grande';
    L['SETTINGS_SCALE_LARGE_SYMBOL_TOOLTIP'] = 'Establecer la escala del símbolo grande';
    L['SETTINGS_USE_CLONE_AUTOMARKER_LABEL'] = 'Auto-marcador en un clon';
    L['SETTINGS_USE_CLONE_AUTOMARKER_TOOLTIP'] = 'Coloca marcadores automáticamente en Clones ilusorios en una pelea de jefes|n|n|cffff6a00Precaución: Estos son marcadores para facilitar la comunicación, no una solución|r';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_LABEL'] = 'Solución duplicada en inglés';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_TOOLTIP'] = 'Envía la solución al chat junto con frases en inglés, por ejemplo, «Flor vacía sin círculo / Empty flower without a circle»';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_LABEL'] = 'Solución sólo en inglés';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_TOOLTIP'] = 'Enviar la solución al chat sólo en inglés';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_LABEL'] = 'Establecer marcador en el jugador';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_TOOLTIP'] = 'Establece automáticamente un marcador verde en el jugador si hace clic en el símbolo que se convirtió en la solución';
    L['SETTINGS_ALPHA_BACKGROUND_LABEL'] = 'Opacidad de fondo';
    L['SETTINGS_ALPHA_BACKGROUND_TOOLTIP'] = 'Establecer opacidad para el fondo de la ventana principal';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_LABEL'] = 'Opacidad de fondo de un símbolo grande';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_TOOLTIP'] = 'Establecer la opacidad para el fondo del símbolo grande';
    L['PRACTICE_TITLE'] = 'Seleccione un símbolo que difiera en un sentido de los demás';
    L['PRACTICE_PLAY_AGAIN'] = 'Juega de nuevo';
    L['PRACTICE_BUTTON_TOOLTIP'] = 'Práctica';
    L['MINIMAP_BUTTON_LMB'] = 'Botón izquierdo';
    L['MINIMAP_BUTTON_RMB'] = 'Botón derecho';
    L['MINIMAP_BUTTON_TOGGLE_MAZEHELPER'] = 'Alternar la ventana «Maze Helper»';
    L['MINIMAP_BUTTON_HIDE'] = 'Ocultar botón de minimapa';
    L['MINIMAP_BUTTON_COMMAND_SHOW'] = 'Use /mh minimap para mostrar el botón del minimapa nuevamente';
    L['SETTINGS_AUTO_PASS_LABEL'] = 'Pase automático';
    L['SETTINGS_AUTO_PASS_TOOLTIP'] = 'Automático «|cff66ff6eAprobado|r» en el paso exitoso a través de las nieblas';
    L['SETTINGS_BORDERS_COLORS'] = 'Colores de las fronteras';
    L['SETTINGS_ACTIVE_COLORPICKER'] = 'Seleccionado';
    L['SETTINGS_RECEIVED_COLORPICKER'] = 'Recibido';
    L['SETTINGS_SOLUTION_COLORPICKER'] = 'Solución';
    L['SETTINGS_PREDICTED_COLORPICKER'] = 'Predicho';
    L['SETTINGS_SKULLMARKER_CLONE_LABEL'] = 'Cráneo en Clon';
    L['SETTINGS_SKULLMARKER_CLONE_TOOLTIP'] = 'Establece automáticamente el marcador de cráneo |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t en el Clon ilusorio objetivo';
    L['SETTINGS_SKULLMARKER_USE_MODIFIER_TOOLTIP'] = 'Usar tecla modificadora';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_LABEL'] = 'Mostrar/ocultar automáticamente';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_TOOLTIP'] = 'Alternar automáticamente la visibilidad de la ventana principal';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL'] = 'Canal de chat';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL_TOOLTIP'] = 'Seleccione el canal de chat al que se enviará la solución';
    L['LOCKED_DRAG_BUTTON_TOOLTIP'] = 'El arrastre está bloqueado';
    L['UNLOCKED_DRAG_BUTTON_TOOLTIP'] = 'El arrastre está desbloqueado';

    return;
end

 -- Latin American Spanish
if gameLocale == 'esMX' then
    L['ZONE_NAME'] = 'Espesura Veloniebla';
    L['MISTCALLER_NAME'] = 'Clamaneblina';

    return;
end

-- Chinese Traditional
-- BNS333 (https://www.curseforge.com/members/bns333)
-- RainbowUI (https://www.curseforge.com/members/rainbowui)
if gameLocale == 'zhTW' then
    L['ZONE_NAME'] = '霧紗密林';
    L['MISTCALLER_NAME'] = '喚霧者';
    L['CHOOSE_SYMBOLS_1'] = '再點選一個標誌';
    L['CHOOSE_SYMBOLS_2'] = '再點選兩個標誌';
    L['CHOOSE_SYMBOLS_3'] = '再點選三個標誌';
    L['CHOOSE_SYMBOLS_4'] = '點選四個標誌';
    L['CLEARED_BY'] = '被 %s 清除了';
    L['FLOWER_FULL_CIRCLE'] = '有外環實心的花';
    L['FLOWER_FULL_NOCIRCLE'] = '無外環實心的花';
    L['FLOWER_NOFULL_CIRCLE'] = '有外環空心的花';
    L['FLOWER_NOFULL_NOCIRCLE'] = '無外環空心的花';
    L['LEAF_FULL_CIRCLE'] = '有外環實心的葉';
    L['LEAF_FULL_NOCIRCLE'] = '無外環實心的葉';
    L['LEAF_NOFULL_CIRCLE'] = '有外環空心的葉';
    L['LEAF_NOFULL_NOCIRCLE'] = '無外環空心的葉';
    L['RESETED_PLAYER'] = '%s |cffff0537已重置|r此小遊戲';
    L['PASSED'] = '已通過';
    L['PASSED_PLAYER'] = '%s 點擊了«|cff66ff6e已通過|r»按鈕';
    L['RESET'] = '重置';
    L['SENDED_BY'] = '由 %s 發送';
    L['SETTINGS_AA_ALWAYS'] = '總是';
    L['SETTINGS_AA_HEALER'] = '治療者';
    L['SETTINGS_AA_PARTY_LEADER'] = '隊長';
    L['SETTINGS_AA_TANK'] = '坦克';
    L['SETTINGS_AUTOANNOUNCER_LABEL'] = '啟用自動通報';
    L['SETTINGS_AUTOANNOUNCER_TOOLTIP'] = '自動向隊伍發送現有的解決方案';
    L['SETTINGS_REVEAL_RESETTER_LABEL'] = '揭示迷你游戲的重置者';
    L['SETTINGS_REVEAL_RESETTER_TOOLTIP'] = '在聊天中輸入有點擊過“重置”或“已通過”按鈕的玩家的名字（僅供您自己使用）';
    L['SETTINGS_SHOW_AT_BOSS_LABEL'] = '在首領戰時顯示';
    L['SETTINGS_SHOW_AT_BOSS_TOOLTIP'] = '與«喚霧者»戰鬥時顯示此助手';
    L['SETTINGS_START_IN_MINMODE_LABEL'] = '以最小化模式啟動';
    L['SETTINGS_START_IN_MINMODE_TOOLTIP'] = '首次出現將以最小化模式進行';
    L['SOLUTION_NA'] = '|cffffb833沒有解決方案|r';
    L['SETTINGS_SYNC_ENABLED_LABEL'] = '組同步';
    L['SETTINGS_SYNC_ENABLED_TOOLTIP'] = '啟用符號選擇與其他組成員的同步|n|n|cffff6a00不建議關閉|r';
    L['SETTINGS_USE_COLORED_SYMBOLS_LABEL'] = '使用彩色符號';
    L['SETTINGS_USE_COLORED_SYMBOLS_TOOLTIP'] = '使用彩色符號代替黑白';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_LABEL'] = '顯示序列號';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_TOOLTIP'] = '單擊符號時顯示序列號（1、2、3、4）';
    L['SETTINGS_PREDICT_SOLUTION_LABEL'] = '預測解決方案';
    L['SETTINGS_PREDICT_SOLUTION_TOOLTIP'] = '在2-3步上預測解決方案，但是|cffff6a00第一個|r選擇的符號|cffff6a00必須是|r入口符號|n|n您可以通過按住SHIFT的方式單擊第一個符號來暫時禁用預測（或雙擊）';
    L['SETTINGS_SHOW_LARGE_SYMBOL_LABEL'] = '顯示大符號';
    L['SETTINGS_SHOW_LARGE_SYMBOL_TOOLTIP'] = '如果有現成的解決方案，請在屏幕頂部顯示一個大符號|n|n右鍵單擊以關閉';
    L['SETTINGS_SCALE_LABEL'] = '規模';
    L['SETTINGS_SCALE_TOOLTIP'] = '設置主窗口的比例';
    L['SETTINGS_SCALE_LARGE_SYMBOL_LABEL'] = '大符號的比例';
    L['SETTINGS_SCALE_LARGE_SYMBOL_TOOLTIP'] = '設置大符號的比例';
    L['SETTINGS_USE_CLONE_AUTOMARKER_LABEL'] = '克隆上的自動標記';
    L['SETTINGS_USE_CLONE_AUTOMARKER_TOOLTIP'] = '在老闆戰鬥中自動在幻影克隆上放置標記|n|n|cffff6a00注意力！ 這些是便於溝通的標記，而不是用於解決方案|r';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_LABEL'] = '英文重複解決方案';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_TOOLTIP'] = '將解決方案與英語短語一起發送至聊天，例如，“無外環空心的花/Empty flower without a circle”';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_LABEL'] = '解決方案僅用英文';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_TOOLTIP'] = '僅用英語發送解決方案';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_LABEL'] = '在玩家上設置標記';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_TOOLTIP'] = '如果玩家點擊成為解決方案的標誌，則自動在他身上設置綠色標記';
    L['SETTINGS_ALPHA_BACKGROUND_LABEL'] = '背景不透明度';
    L['SETTINGS_ALPHA_BACKGROUND_TOOLTIP'] = '為主窗口的背景設置不透明度';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_LABEL'] = '大符號的背景不透明度';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_TOOLTIP'] = '設置大符號背景的不透明度';
    L['PRACTICE_TITLE'] = '選擇一個符號與其他符號不同的符號';
    L['PRACTICE_PLAY_AGAIN'] = '再玩一次';
    L['PRACTICE_BUTTON_TOOLTIP'] = '實踐';
    L['MINIMAP_BUTTON_LMB'] = '左鍵';
    L['MINIMAP_BUTTON_RMB'] = '右鍵';
    L['MINIMAP_BUTTON_TOGGLE_MAZEHELPER'] = '切換“Maze Helper”窗口';
    L['MINIMAP_BUTTON_HIDE'] = '隱藏小地圖按鈕';
    L['MINIMAP_BUTTON_COMMAND_SHOW'] = '使用/mh minimap再次顯示小地圖按鈕';
    L['SETTINGS_AUTO_PASS_LABEL'] = '自動通過';
    L['SETTINGS_AUTO_PASS_TOOLTIP'] = '成功通過霧氣時自動«|cff66ff6e已通過|r»';
    L['SETTINGS_BORDERS_COLORS'] = '邊框顏色';
    L['SETTINGS_ACTIVE_COLORPICKER'] = '已選';
    L['SETTINGS_RECEIVED_COLORPICKER'] = '已收到';
    L['SETTINGS_SOLUTION_COLORPICKER'] = '解決方案';
    L['SETTINGS_PREDICTED_COLORPICKER'] = '預料到的';
    L['SETTINGS_SKULLMARKER_CLONE_LABEL'] = '複製體上骷髏標記';
    L['SETTINGS_SKULLMARKER_CLONE_TOOLTIP'] = '自動將頭骨標記|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t設置為目標幻影克隆';
    L['SETTINGS_SKULLMARKER_USE_MODIFIER_TOOLTIP'] = '使用修飾鍵';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_LABEL'] = '自動顯示/隱藏';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_TOOLTIP'] = '自動切換主窗口的可見性';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL'] = '聊天頻道';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL_TOOLTIP'] = '選擇解決方案將發送到的聊天頻道';
    L['LOCKED_DRAG_BUTTON_TOOLTIP'] = '拖動被鎖定';
    L['UNLOCKED_DRAG_BUTTON_TOOLTIP'] = '拖動已解鎖';

    return;
end

-- Chinese Simplified
-- Geminil82 (https://www.curseforge.com/members/Geminil82)
-- gjfLeo (https://github.com/gjfLeo)
-- NeoS0923 (https://www.curseforge.com/members/neos0923)
if gameLocale == 'zhCN' then
    L['ZONE_NAME'] = '纱雾迷结';
    L['MISTCALLER_NAME'] = '唤雾者';
    L['CHOOSE_SYMBOLS_1'] = '再点一个标志';
    L['CHOOSE_SYMBOLS_2'] = '再点两个标志';
    L['CHOOSE_SYMBOLS_3'] = '再点三个标志';
    L['CHOOSE_SYMBOLS_4'] = '点选四个标志';
    L['CLEARED_BY'] = '被 %s 清除了';
    L['FLOWER_FULL_CIRCLE'] = '有环 实心 花';
    L['FLOWER_FULL_NOCIRCLE'] = '无环 实心 花';
    L['FLOWER_NOFULL_CIRCLE'] = '有环 空心 花';
    L['FLOWER_NOFULL_NOCIRCLE'] = '无环 空心 花';
    L['LEAF_FULL_CIRCLE'] = '有环 实心 叶';
    L['LEAF_FULL_NOCIRCLE'] = '无环 实心 叶';
    L['LEAF_NOFULL_CIRCLE'] = '有环 空心 叶';
    L['LEAF_NOFULL_NOCIRCLE'] = '无环 空心 叶';
    L['PASSED'] = '通过';
    L['PASSED_PLAYER'] = '%s 点击了«|cff66ff6e通过|r»按钮';
    L['RESET'] = '重置';
    L['RESETED_PLAYER'] = '%s |cffff0537已重置|r此小游戏';
    L['SENDED_BY'] = '由 %s 发送';
    L['SETTINGS_AA_ALWAYS'] = '总是';
    L['SETTINGS_AA_HEALER'] = '治疗者';
    L['SETTINGS_AA_PARTY_LEADER'] = '队长';
    L['SETTINGS_AA_TANK'] = '坦克';
    L['SETTINGS_AUTOANNOUNCER_LABEL'] = '启用自动通报';
    L['SETTINGS_AUTOANNOUNCER_TOOLTIP'] = '自动向群聊发送现有的答案';
    L['SETTINGS_REVEAL_RESETTER_LABEL'] = '提示迷你游戏的重置者';
    L['SETTINGS_REVEAL_RESETTER_TOOLTIP'] = '在聊天框中显示点击“重置”或“通过”按钮的玩家（仅自己可见）';
    L['SETTINGS_SHOW_AT_BOSS_LABEL'] = '首领战时显示';
    L['SETTINGS_SHOW_AT_BOSS_TOOLTIP'] = '与唤雾者战斗时显示';
    L['SETTINGS_START_IN_MINMODE_LABEL'] = '启动时最小化';
    L['SETTINGS_START_IN_MINMODE_TOOLTIP'] = '首次出现将以最小化模式运行';
    L['SETTINGS_SYNC_ENABLED_LABEL'] = '队伍同步';
    L['SETTINGS_SYNC_ENABLED_TOOLTIP'] = '启用符号选择与其他队伍成员的同步|n|n|cffff6a00不建议关闭|r';
    L['SETTINGS_USE_COLORED_SYMBOLS_LABEL'] = '使用彩色符号';
    L['SETTINGS_USE_COLORED_SYMBOLS_TOOLTIP'] = '使用彩色符号代替黑白';
    L['SOLUTION_NA'] = '|cffffb833没有答案|r';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_LABEL'] = '显示序号';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_TOOLTIP'] = '单击符号时显示序号(1/2/3/4)';
    L['SETTINGS_PREDICT_SOLUTION_LABEL'] = '预测答案';
    L['SETTINGS_PREDICT_SOLUTION_TOOLTIP'] = '在2-3步预测答案，但是|cffff6a00第一个|r选择的符号|cffff6a00必须是|r入口符号|n|n您可以通过按住SHIFT的方式单击第一个符号来暂时禁用预测（或双击）';
    L['SETTINGS_SHOW_LARGE_SYMBOL_LABEL'] = '显示大符号';
    L['SETTINGS_SHOW_LARGE_SYMBOL_TOOLTIP'] = '如果有现成的解决方案，请在屏幕顶部显示一个大符号|n|n右键单击以关闭';
    L['SETTINGS_SCALE_LABEL'] = '规模';
    L['SETTINGS_SCALE_TOOLTIP'] = '设置主窗口的比例';
    L['SETTINGS_SCALE_LARGE_SYMBOL_LABEL'] = '大符号的比例';
    L['SETTINGS_SCALE_LARGE_SYMBOL_TOOLTIP'] = '设置大符号的比例';
    L['SETTINGS_USE_CLONE_AUTOMARKER_LABEL'] = '克隆上的自动标记';
    L['SETTINGS_USE_CLONE_AUTOMARKER_TOOLTIP'] = '在老板战斗中自动在幻影克隆上放置标记|n|n|cffff6a00注意：这些是便于沟通的标记，不是解决方案。|r';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_LABEL'] = '英文重复解决方案';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_TOOLTIP'] = '将解决方案与英语短语一起发送给聊天，例如，“无环 空心 花/Empty flower without a circle”';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_LABEL'] = '仅有英文版本的解决方案';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_TOOLTIP'] = '只用英语发送聊天的解决方案';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_LABEL'] = '在播放器上设置标记';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_TOOLTIP'] = '如果他单击成为解决方案的符号，则自动在玩家上设置绿色标记';
    L['SETTINGS_ALPHA_BACKGROUND_LABEL'] = '背景不透明度';
    L['SETTINGS_ALPHA_BACKGROUND_TOOLTIP'] = '为主窗口的背景设置不透明度';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_LABEL'] = '大符号的背景不透明度';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_TOOLTIP'] = '设置大符号背景的不透明度';
    L['PRACTICE_TITLE'] = '选择一个符号与其他符号不同的符号';
    L['PRACTICE_PLAY_AGAIN'] = '再玩一次';
    L['PRACTICE_BUTTON_TOOLTIP'] = '实践';
    L['MINIMAP_BUTTON_LMB'] = '左键';
    L['MINIMAP_BUTTON_RMB'] = '右键';
    L['MINIMAP_BUTTON_TOGGLE_MAZEHELPER'] = '切换«Maze Helper»窗口';
    L['MINIMAP_BUTTON_HIDE'] = '隐藏小地图按钮';
    L['MINIMAP_BUTTON_COMMAND_SHOW'] = '使用/mh minimap再次显示小地图按钮';
    L['SETTINGS_AUTO_PASS_LABEL'] = '自动通过';
    L['SETTINGS_AUTO_PASS_TOOLTIP'] = '成功通过雾气时自动«|cff66ff6e通过|r»';
    L['SETTINGS_BORDERS_COLORS'] = '边框颜色';
    L['SETTINGS_ACTIVE_COLORPICKER'] = '已选';
    L['SETTINGS_RECEIVED_COLORPICKER'] = '已收到';
    L['SETTINGS_SOLUTION_COLORPICKER'] = '解决方案';
    L['SETTINGS_PREDICTED_COLORPICKER'] = '预料到的';
    L['SETTINGS_SKULLMARKER_CLONE_LABEL'] = '头骨上克隆';
    L['SETTINGS_SKULLMARKER_CLONE_TOOLTIP'] = '自动将头骨标记|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t设置为目标幻影克隆';
    L['SETTINGS_SKULLMARKER_USE_MODIFIER_TOOLTIP'] = '使用修饰键';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_LABEL'] = '自动显示/隐藏';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_TOOLTIP'] = '自动切换主窗口的可见性';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL'] = '聊天频道';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL_TOOLTIP'] = '选择解决方案将发送到的聊天频道';
    L['LOCKED_DRAG_BUTTON_TOOLTIP'] = '拖动被锁定';
    L['UNLOCKED_DRAG_BUTTON_TOOLTIP'] = '拖动已解锁';

    return;
end

-- Korean
-- hinski (https://www.curseforge.com/members/hinski)
if gameLocale == 'koKR' then
    L['ZONE_NAME'] = '안개장막 덩굴숲';
    L['MISTCALLER_NAME'] = '미스트콜러';
    L['CHOOSE_SYMBOLS_1'] = '1개의 모양을 더 고르세요';
    L['CHOOSE_SYMBOLS_2'] = '2개의 모양을 더 고르세요';
    L['CHOOSE_SYMBOLS_3'] = '3개의 모양을 더 고르세요';
    L['CHOOSE_SYMBOLS_4'] = '4개의 모양을 고르세요';
    L['CLEARED_BY'] = '%s에 의해 초기화됨';
    L['FLOWER_FULL_CIRCLE'] = '원 안의 색칠한 꽃';
    L['FLOWER_FULL_NOCIRCLE'] = '원 없는 색칠한 꽃';
    L['FLOWER_NOFULL_CIRCLE'] = '원 안의 빈 꽃';
    L['FLOWER_NOFULL_NOCIRCLE'] = '원 없는 빈 꽃';
    L['LEAF_FULL_CIRCLE'] = '원 안의 색칠한 잎';
    L['LEAF_FULL_NOCIRCLE'] = '원 없는 색칠한 잎';
    L['LEAF_NOFULL_CIRCLE'] = '원 안의 빈 잎';
    L['LEAF_NOFULL_NOCIRCLE'] = '원 없는 빈 잎';
    L['PASSED'] = '통과';
    L['PASSED_PLAYER'] = '%s이(가) «|cff66ff6e통과|r» 버튼을 눌렀습니다';
    L['RESET'] = '초기화';
    L['RESETED_PLAYER'] = '%s이(가) 이 퍼즐을 |cffff0537초기화|r했습니다';
    L['SENDED_BY'] = '%s의 전송';
    L['SETTINGS_AA_ALWAYS'] = '항상';
    L['SETTINGS_AA_HEALER'] = '힐러';
    L['SETTINGS_AA_PARTY_LEADER'] = '파티장';
    L['SETTINGS_AA_TANK'] = '탱커';
    L['SETTINGS_AUTOANNOUNCER_LABEL'] = '자동 알리기 활성화';
    L['SETTINGS_AUTOANNOUNCER_TOOLTIP'] = '자동으로 완성된 정답을 파티 채팅에 보냄';
    L['SETTINGS_PREDICT_SOLUTION_LABEL'] = '정답 예측';
    L['SETTINGS_PREDICT_SOLUTION_TOOLTIP'] = '2-3 단계로 정답을 예측할 수 있지만, |cffff6a00첫 번째|r로 선택한 모양은 |cffff6a00반드시|r 입구 방향의 모양이여야 합니다|n|nSHIFT를 누른 상태에서 첫 번째 기호를 클릭하여 예측을 일시적으로 비활성화 할 수 있습니다 (또는 더블 클릭으로)';
    L['SETTINGS_REVEAL_RESETTER_LABEL'] = '퍼즐을 초기화한 사람 공개';
    L['SETTINGS_REVEAL_RESETTER_TOOLTIP'] = '채팅에 «초기화» 혹은 «통과» 버튼을 누른 사람의 이름을 넣습니다 (자신만 해당)';
    L['SETTINGS_SHOW_AT_BOSS_LABEL'] = '보스에서 나오게 하기';
    L['SETTINGS_SHOW_AT_BOSS_TOOLTIP'] = '«미스트콜러»와 전투 시 이 애드온을 보이게 함';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_LABEL'] = '순서 표시';
    L['SETTINGS_SHOW_SEQUENCE_NUMBERS_TOOLTIP'] = '모양을 선택할 때 누른 순서를 표시함 (1, 2, 3, 4)';
    L['SETTINGS_START_IN_MINMODE_LABEL'] = '접은 상태에서 시작';
    L['SETTINGS_START_IN_MINMODE_TOOLTIP'] = '처음엔 접은 상태로 나옴';
    L['SETTINGS_SYNC_ENABLED_LABEL'] = '파티 동기화';
    L['SETTINGS_SYNC_ENABLED_TOOLTIP'] = '다른 파티원과 선택한 모양 공유 활성화|n|n|cffff6a00끄지 않는 것을 권장합니다|r';
    L['SETTINGS_USE_COLORED_SYMBOLS_LABEL'] = '색이 있는 모양 사용';
    L['SETTINGS_USE_COLORED_SYMBOLS_TOOLTIP'] = '흑백 대신 색칠된 모양 사용';
    L['SOLUTION_NA'] = '|cffffb833정답이 없습니다|r';
    L['SETTINGS_SHOW_LARGE_SYMBOL_LABEL'] = '큰 기호 표시';
    L['SETTINGS_SHOW_LARGE_SYMBOL_TOOLTIP'] = '기성 솔루션이있는 경우 화면 상단에 큰 기호 표시|n|n닫으려면 오른쪽 클릭';
    L['SETTINGS_SCALE_LABEL'] = '비율';
    L['SETTINGS_SCALE_TOOLTIP'] = '기본 창의 배율 설정';
    L['SETTINGS_SCALE_LARGE_SYMBOL_LABEL'] = '큰 심볼의 스케일';
    L['SETTINGS_SCALE_LARGE_SYMBOL_TOOLTIP'] = '큰 기호의 배율 설정';
    L['SETTINGS_USE_CLONE_AUTOMARKER_LABEL'] = '클론의 자동 마커';
    L['SETTINGS_USE_CLONE_AUTOMARKER_TOOLTIP'] = '보스전에서 환영 분신들에 징표를 자동으로 분배|n|n|cffff6a00주의! 이것들은 해결을위한 것이 아니라 의사 소통의 용이함을위한 마커입니다|r';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_LABEL'] = '영어로도 중복해서 표시';
    L['SETTINGS_ANNOUNCE_WITH_ENGLISH_TOOLTIP'] = '예를 들어 «원 없는 빈 꽃 / Empty flower without a circle»과 같이 영어 구문과 함께 정답을 채팅에 보냅니다';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_LABEL'] = '영어로만 솔루션';
    L['SETTINGS_ANNOUNCE_ONLY_ENGLISH_TOOLTIP'] = '영어로만 채팅에 솔루션을 보냅니다';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_LABEL'] = '플레이어에 징표 설정';
    L['SETTINGS_SET_MARKER_SOLUTION_PLAYER_TOOLTIP'] = '답을 고르면 플레이어에게 자동으로 녹색 징표가 설정됩니다';
    L['SETTINGS_ALPHA_BACKGROUND_LABEL'] = '배경 불투명도';
    L['SETTINGS_ALPHA_BACKGROUND_TOOLTIP'] = '기본 창의 배경 불투명도 설정';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_LABEL'] = '큰 모양의 배경 불투명도';
    L['SETTINGS_ALPHA_BACKGROUND_LARGE_SYMBOL_TOOLTIP'] = '큰 모양의 배경 불투명도 설정';
    L['PRACTICE_TITLE'] = '한 조건이 나머지와 다른 모양을 선택하십시오';
    L['PRACTICE_PLAY_AGAIN'] = '다시 하기';
    L['PRACTICE_BUTTON_TOOLTIP'] = '연습';
    L['MINIMAP_BUTTON_LMB'] = '좌클릭';
    L['MINIMAP_BUTTON_RMB'] = '우클릭';
    L['MINIMAP_BUTTON_TOGGLE_MAZEHELPER'] = '«Maze Helper»창 토글';
    L['MINIMAP_BUTTON_HIDE'] = '미니맵 버튼 숨기기';
    L['MINIMAP_BUTTON_COMMAND_SHOW'] = '/mh minimap 으로 미니맵 버튼을 표시할 수 있습니다';
    L['SETTINGS_AUTO_PASS_LABEL'] = '자동 통과';
    L['SETTINGS_AUTO_PASS_TOOLTIP'] = '안개를 성공적으로 지나가면 자동으로 «|cff66ff6e통과|r»';
    L['SETTINGS_BORDERS_COLORS'] = '테두리 색상';
    L['SETTINGS_ACTIVE_COLORPICKER'] = '선택함';
    L['SETTINGS_RECEIVED_COLORPICKER'] = '전송받음';
    L['SETTINGS_SOLUTION_COLORPICKER'] = '정답';
    L['SETTINGS_PREDICTED_COLORPICKER'] = '예상';
    L['SETTINGS_SKULLMARKER_CLONE_LABEL'] = '분신에 해골';
    L['SETTINGS_SKULLMARKER_CLONE_TOOLTIP'] = '해골 징표 |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t를 대상으로 지정한 환영 분신에 자동으로 설정합니다';
    L['SETTINGS_SKULLMARKER_USE_MODIFIER_TOOLTIP'] = '모드 키 사용';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_LABEL'] = '자동 표시 / 숨기기';
    L['SETTINGS_AUTO_TOGGLE_VISIBILITY_TOOLTIP'] = '기본 창의 가시성을 자동으로 전환';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL'] = '채팅 채널';
    L['SETTINGS_AUTOANNOUNCE_CHANNEL_TOOLTIP'] = '솔루션을 보낼 채팅 채널을 선택하십시오.';
    L['LOCKED_DRAG_BUTTON_TOOLTIP'] = '드래그가 잠겨 있습니다.';
    L['UNLOCKED_DRAG_BUTTON_TOOLTIP'] = '드래그가 잠금 해제되었습니다.';

    return;
end
