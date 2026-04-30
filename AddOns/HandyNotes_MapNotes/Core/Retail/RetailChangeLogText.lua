local ADDON_NAME, ns = ...

ns.CurrentAddonVersion = "3.4.9"
ns.PreviousAddonVersion = "3.4.8" -- Only increase this number if you want to see changelogs and NPC updates after an add-on update. Only important for actual changes to NPCs or major updates

ns.LOCALE_CHANGELOGS = {
  { version = "3.4.9", table = ns.LOCALE_CHANGELOG_3_4_9 },
  { version = "3.4.8", table = "smallChanges" },
  { version = "3.4.7", table = ns.LOCALE_CHANGELOG_3_4_7 },
  { version = "3.4.6", table = "smallChanges" },
  { version = "3.4.5", table = ns.LOCALE_CHANGELOG_3_4_5 },
  { version = "3.4.4", table = "smallChanges" },
  { version = "3.4.3", table = ns.LOCALE_CHANGELOG_3_4_3 },
  { version = "3.4.2", table = "tocUpdate" },
  { version = "3.4.1", table = "partialUpdate" },
  { version = "3.4.0", table = ns.LOCALE_CHANGELOG_3_4_0 },
  { version = "3.3.9", table = ns.LOCALE_CHANGELOG_3_3_9 },
  { version = "3.3.8", table = ns.LOCALE_CHANGELOG_3_3_8 },
  { version = "3.3.7", table = "partialUpdate" },
  { version = "3.3.6", table = ns.LOCALE_CHANGELOG_3_3_6 },
  { version = "3.3.5", table = ns.LOCALE_CHANGELOG_3_3_5 },
  { version = "3.3.4", table = ns.LOCALE_CHANGELOG_3_3_4 },
  { version = "3.3.3", table = "partialUpdate" },
  { version = "3.3.2", table = ns.LOCALE_CHANGELOG_3_3_2 },
  { version = "3.3.1", table = "partialUpdate" },
  { version = "3.3.0", table = "partialUpdate" },
  { version = "3.3.0", table = ns.LOCALE_CHANGELOG_3_3_0 },
  { version = "3.2.9", table = ns.LOCALE_CHANGELOG_3_2_9 },
  { version = "3.2.8", table = "partialUpdate" },
  { version = "3.2.7", table = "partialUpdate" },
  { version = "3.2.6", table = "partialUpdate" },
  { version = "3.2.5", table = ns.LOCALE_CHANGELOG_3_2_5 },
}

ns.LOCALE_CHANGELOG_3_4_ = { -- empty backup file
  deDE = [[

]],

  enUS = [[

]],

  frFR = [[

]],

  itIT = [[

]],

  esES = [[

]],

  esMX = [[

]],

  ptBR = [[

]],

  ruRU = [[

]],

  zhCN = [[

]],

  zhTW = [[

]],

  koKR = [[

]],
}

ns.LOCALE_CHANGELOG_3_4_9 = {
  deDE = [[
• Verbesserung der Koreanischen Übersetzungsdatei
]],

  enUS = [[
• Improvement of the Korean translation file
]],

  frFR = [[
• Amélioration du fichier de traduction coréenne
]],

  itIT = [[
• Miglioramento del file di traduzione coreana
]],

  esES = [[
• Mejora del archivo de traducción coreana
]],

  esMX = [[
• Mejora del archivo de traducción coreana
]],

  ptBR = [[
• Melhoria do arquivo de tradução coreana
]],

  ruRU = [[
• Улучшение файла корейского перевода
]],

  zhCN = [[
• 改进韩语翻译文件
]],

  zhTW = [[
• 改進韓文翻譯檔案
]],

  koKR = [[
• 한국어 번역 파일 개선
]],
}

ns.LOCALE_CHANGELOG_3_4_7 = {
  deDE = [[
• Fehlerbehebung nicht gefundenes Profil für die Nebel-, Weltkarten- und Koordinaten-Funktion
]],

  enUS = [[
• Bugfix for missing profile for fog, world map, and coordinate function
]],

  frFR = [[
• Correction d’un profil introuvable pour le brouillard, la carte du monde et la fonction de coordonnées
]],

  itIT = [[
• Correzione di un profilo non trovato per la nebbia, la mappa del mondo e la funzione delle coordinate
]],

  esES = [[
• Corrección de un perfil no encontrado para la niebla, el mapa del mundo y la función de coordenadas
]],

  esMX = [[
• Corrección de un perfil no encontrado para la niebla, el mapa del mundo y la función de coordenadas
]],

  ptBR = [[
• Correção de perfil não encontrado para a névoa, o mapa-múndi e a função de coordenadas
]],

  ruRU = [[
• Исправлена ошибка отсутствующего профиля для тумана, карты мира и функции координат
]],

  zhCN = [[
• 修复了雾效、世界地图和坐标功能中未找到配置文件的问题
]],

  zhTW = [[
• 修復了霧效、世界地圖與座標功能中未找到設定檔的問題
]],

  koKR = [[
• 안개, 월드맵 및 좌표 기능에서 프로필을 찾을 수 없는 문제 수정
]],
}

ns.LOCALE_CHANGELOG_3_4_5 = {
  deDE = [[
• Berufserkennung: Wurde geändert. Ist diese Funktion aktiviert und es wurden noch keine 2 Hauptberufe erlernt, werden alle möglichen Hauptberufssymbole angezeigt. Dasselbe gilt für die Nebenberufe, wurden weniger als 2 Nebenberufe erlernt, werden alle möglichen Nebenberufssymbole angezeigt.

• Das Symbol für die Ruhm-Rüstmeister wurde angepasst und entspricht nun der Optik des Blizzard-Interfaces.
]],

  enUS = [[
• Profession detection: Updated. If this feature is enabled and fewer than 2 primary professions are learned, all possible primary profession icons will be shown. The same applies to secondary professions: if fewer than 2 secondary professions are learned, all possible secondary profession icons will be shown.

• The icon for Renown Quartermasters has been updated and now matches the Blizzard interface style.
]],

  frFR = [[
• Détection des métiers : mise à jour. Si cette fonction est activée et que moins de 2 métiers principaux sont appris, toutes les icônes possibles des métiers principaux seront affichées. Il en va de même pour les métiers secondaires : si moins de 2 métiers secondaires sont appris, toutes les icônes possibles des métiers secondaires seront affichées.

• L’icône des intendants de renom a été mise à jour et correspond désormais au style de l’interface Blizzard.
]],

  itIT = [[
• Rilevamento delle professioni: aggiornato. Se questa funzione è attiva e sono state apprese meno di 2 professioni principali, verranno mostrate tutte le icone possibili delle professioni principali. Lo stesso vale per le professioni secondarie: se sono state apprese meno di 2 professioni secondarie, verranno mostrate tutte le icone possibili delle professioni secondarie.

• L’icona dei Quartiermastri della Fama è stata aggiornata e ora corrisponde allo stile dell’interfaccia Blizzard.
]],

  esES = [[
• Detección de profesiones: actualizada. Si esta función está activada y se han aprendido menos de 2 profesiones principales, se mostrarán todos los iconos posibles de profesiones principales. Lo mismo se aplica a las profesiones secundarias: si se han aprendido menos de 2 profesiones secundarias, se mostrarán todos los iconos posibles de profesiones secundarias.

• El icono de los intendentes de Renombre ha sido actualizado y ahora coincide con el estilo de la interfaz de Blizzard.
]],

  esMX = [[
• Detección de profesiones: actualizada. Si esta función está activada y se han aprendido menos de 2 profesiones principales, se mostrarán todos los íconos posibles de profesiones principales. Lo mismo aplica para las profesiones secundarias: si se han aprendido menos de 2 profesiones secundarias, se mostrarán todos los íconos posibles de profesiones secundarias.

• El ícono de los intendentes de Renombre ha sido actualizado y ahora coincide con el estilo de la interfaz de Blizzard.
]],

  ptBR = [[
• Detecção de profissões: atualizada. Se esta função estiver ativada e menos de 2 profissões principais forem aprendidas, todos os ícones possíveis de profissões principais serão exibidos. O mesmo se aplica às profissões secundárias: se menos de 2 profissões secundárias forem aprendidas, todos os ícones possíveis de profissões secundárias serão exibidos.

• O ícone dos intendentes de Renome foi atualizado e agora corresponde ao estilo da interface da Blizzard.
]],

  ruRU = [[
• Обнаружение профессий: обновлено. Если функция включена и изучено менее 2 основных профессий, будут отображаться все возможные значки основных профессий. То же самое относится к дополнительным профессиям: если изучено менее 2 дополнительных профессий, будут отображаться все возможные значки дополнительных профессий.

• Значок интендантов известности был обновлён и теперь соответствует стилю интерфейса Blizzard.
]],

  zhCN = [[
• 专业检测：已更新。如果启用此功能且学习的主专业少于2个，则会显示所有可能的主专业图标。副专业也是如此：如果学习的副专业少于2个，则会显示所有可能的副专业图标。

• 名望军需官的图标已更新，现在与暴雪界面风格一致。
]],

  zhTW = [[
• 專業偵測：已更新。如果啟用此功能且學會的主要專業少於2個，將顯示所有可能的主要專業圖示。次要專業也是如此：如果學會的次要專業少於2個，將顯示所有可能的次要專業圖示。

• 名望軍需官的圖示已更新，現在與暴雪介面風格一致。
]],

  koKR = [[
• 전문 기술 감지: 업데이트됨. 이 기능이 활성화되어 있고 주요 전문 기술을 2개 미만으로 배운 경우 모든 가능한 주요 전문 기술 아이콘이 표시됩니다. 보조 전문 기술도 동일하게, 2개 미만으로 배운 경우 모든 가능한 보조 전문 기술 아이콘이 표시됩니다.

• 평판 병참장교 아이콘이 업데이트되어 이제 블리자드 인터페이스 스타일과 일치합니다.
]],
}

ns.LOCALE_CHANGELOG_3_4_3 = {
  deDE = [[
• Den Zeitwege-Portalnamen wurden nun auch die zugehörigen Dungeons innerhalb der Zonen- bzw. Hauptstadtanzeige hinzugefügt.
]],

  enUS = [[
• The corresponding dungeons have now been added to the Timewalking portal names within the zone and capital city display.
]],

  frFR = [[
• Les donjons correspondants ont été ajoutés aux noms des portails Marcheurs du temps dans l’affichage des zones et des capitales.
]],

  itIT = [[
• I dungeon corrispondenti sono stati aggiunti ai nomi dei portali Viaggi nel Tempo nella visualizzazione delle zone e delle capitali.
]],

  esES = [[
• Se han añadido las mazmorras correspondientes a los nombres de los portales de Paseo en el Tiempo en la visualización de zonas y capitales.
]],

  esMX = [[
• Se han agregado las mazmorras correspondientes a los nombres de los portales de Caminata en el Tiempo en la visualización de zonas y capitales.
]],

  ptBR = [[
• As masmorras correspondentes foram adicionadas aos nomes dos portais de Caminhada Temporal na visualização de zonas e capitais.
]],

  ruRU = [[
• К названиям порталов путешествий во времени добавлены соответствующие подземелья в отображении зон и столиц.
]],

  zhCN = [[
• 在区域和主城显示中，时光漫游传送门名称现在也包含了对应的地下城。
]],

  zhTW = [[
• 在區域與主城顯示中，時光漫遊傳送門名稱現在也包含了對應的地下城。
]],

  koKR = [[
• 시간여행 포탈 이름에 해당 던전이 지역 및 수도 표시에도 추가되었습니다.
]],
}

ns.LOCALE_CHANGELOG_3_4_0 = {
  deDE = [[
• Für die Areamap-Funktion wurden zusätzliche IDs hinzugefügt.

• Wenn die Funktion "MapNotes deaktivieren" aktiviert wird, ändert sich das Symbol des Minimap-Buttons und des Weltkarten-Buttons. Statt des MapNotes-Icons wird ein rotes X angezeigt, um besser darzustellen, dass alle MapNotes-Symbole ausgeblendet sind.

• Auch die Tooltip-Anzeige des Minimap-Buttons und des Weltkarten-Buttons ändert sich, wenn die Funktion aktiviert ist.

• Ein Fehler wurde behoben, der unter bestimmten Umständen die MapNotes-Tiefenanzeige wieder aktiviert hat, obwohl sie deaktiviert war.
]],

  enUS = [[
• Added additional IDs for the area map functionality.

• When the "Disable MapNotes" option is enabled, the minimap button and world map button icons change to a red X to better indicate that all MapNotes icons are hidden.

• The tooltip of the minimap button and the world map button also changes when this option is enabled.

• Fixed an issue where the MapNotes Delve display could be re-enabled under certain conditions even though it was disabled.
]],

  frFR = [[
• Ajout d’identifiants supplémentaires pour la fonctionnalité de carte de zone.

• Lorsque l’option « Désactiver MapNotes » est activée, l’icône du bouton de la minicarte et de la carte du monde change pour afficher un X rouge, indiquant que toutes les icônes MapNotes sont masquées.

• L’infobulle du bouton de la minicarte et de la carte du monde change également lorsque cette option est activée.

• Correction d’un problème où l’affichage des Gouffres MapNotes pouvait se réactiver dans certaines conditions même lorsqu’il était désactivé.
]],

  itIT = [[
• Aggiunti ID aggiuntivi per la funzionalità della mappa dell’area.

• Quando l’opzione "Disattiva MapNotes" è attiva, l’icona del pulsante della minimappa e della mappa del mondo cambia in una X rossa per indicare che tutte le icone di MapNotes sono nascoste.

• Anche il tooltip del pulsante della minimappa e della mappa del mondo cambia quando questa opzione è attiva.

• Risolto un problema per cui la visualizzazione delle Profondità di MapNotes poteva riattivarsi in alcune condizioni anche se disattivata.
]],

  esES = [[
• Se añadieron IDs adicionales para la funcionalidad del mapa de zona.

• Cuando la opción "Desactivar MapNotes" está activada, el icono del botón del minimapa y del mapa del mundo cambia a una X roja para indicar que todos los iconos de MapNotes están ocultos.

• El tooltip del botón del minimapa y del mapa del mundo también cambia cuando esta opción está activada.

• Se solucionó un problema por el cual la visualización de Profundidades de MapNotes podía volver a activarse en ciertas condiciones incluso estando desactivada.
]],

  esMX = [[
• Se añadieron IDs adicionales para la funcionalidad del mapa de zona.

• Cuando la opción "Desactivar MapNotes" está activada, el ícono del botón del minimapa y del mapa del mundo cambia a una X roja para indicar que todos los íconos de MapNotes están ocultos.

• El tooltip del botón del minimapa y del mapa del mundo también cambia cuando esta opción está activada.

• Se corrigió un problema por el cual la visualización de Profundidades de MapNotes podía volver a activarse en ciertas condiciones incluso estando desactivada.
]],

  ptBR = [[
• IDs adicionais foram adicionados para a funcionalidade do mapa de área.

• Quando a opção "Desativar MapNotes" está ativada, o ícone do botão do minimapa e do mapa do mundo muda para um X vermelho, indicando que todos os ícones do MapNotes estão ocultos.

• O tooltip do botão do minimapa e do mapa do mundo também muda quando essa opção está ativada.

• Corrigido um problema em que a exibição de Mergulhos do MapNotes podia ser reativada em certas condições mesmo estando desativada.
]],

  ruRU = [[
• Добавлены дополнительные ID для функции карты области.

• При включении опции «Отключить MapNotes» значок кнопки миникарты и карты мира меняется на красный X, показывая, что все значки MapNotes скрыты.

• Подсказка (tooltip) кнопки миникарты и карты мира также изменяется при включении этой опции.

• Исправлена ошибка, из-за которой отображение вылазок MapNotes могло снова включаться при определённых условиях, даже если оно было отключено.
]],

  zhCN = [[
• 为区域地图功能添加了额外的ID。

• 当启用“禁用 MapNotes”选项时，小地图按钮和世界地图按钮的图标会变为红色 X，以更清晰地表示所有 MapNotes 图标已被隐藏。

• 当该选项启用时，小地图按钮和世界地图按钮的提示信息也会发生变化。

• 修复了在某些情况下即使已禁用，MapNotes 深潜显示仍会被重新启用的问题。
]],

  zhTW = [[
• 為區域地圖功能新增了額外的ID。

• 當啟用「停用 MapNotes」選項時，小地圖按鈕與世界地圖按鈕的圖示會變為紅色 X，以清楚表示所有 MapNotes 圖示已被隱藏。

• 啟用此選項時，小地圖按鈕與世界地圖按鈕的提示也會改變。

• 修正了一個在某些情況下即使已停用，MapNotes 深淵顯示仍會重新啟用的問題。
]],

  koKR = [[
• 지역 지도 기능을 위해 추가 ID가 추가되었습니다.

• "MapNotes 비활성화" 옵션이 활성화되면 미니맵 버튼과 월드맵 버튼의 아이콘이 빨간 X로 변경되어 모든 MapNotes 아이콘이 숨겨졌음을 표시합니다.

• 이 옵션이 활성화되면 미니맵 버튼과 월드맵 버튼의 툴팁도 변경됩니다.

• 특정 상황에서 비활성화되어 있음에도 MapNotes 탐험 표시가 다시 활성화되던 문제가 수정되었습니다.
]],
}

ns.LOCALE_CHANGELOG_3_3_9 = {
  deDE = [[
• Ein Fehler wurde behoben, durch den die "Großzügigen Tiefen" auf der Kontinentkarte nicht angezeigt wurden.
]],

  enUS = [[
• Fixed an issue where "Bountiful Delves" were not displayed on the continent map.
]],

  frFR = [[
• Correction d’un problème où les « Gouffres abondants » n’étaient pas affichés sur la carte du continent.
]],

  itIT = [[
• Risolto un problema per cui le "Spedizioni nelle Profondità abbondanti" non venivano visualizzate sulla mappa del continente.
]],

  esES = [[
• Se solucionó un problema por el cual las "Profundidades abundantes" no se mostraban en el mapa del continente.
]],

  esMX = [[
• Se corrigió un problema por el cual las "Profundidades abundantes" no se mostraban en el mapa del continente.
]],

  ptBR = [[
• Corrigido um problema em que os "Mergulhos abundantes" não eram exibidos no mapa do continente.
]],

  ruRU = [[
• Исправлена ошибка, из-за которой «Изобильные вылазки» не отображались на карте континента.
]],

  zhCN = [[
• 修复了“丰饶深潜”未在大陆地图上显示的问题。
]],

  zhTW = [[
• 修正了「豐饒深淵」未在大陸地圖上顯示的問題。
]],

  koKR = [[
• "풍요로운 탐험"이 대륙 지도에 표시되지 않던 문제가 수정되었습니다.
]],
}

ns.LOCALE_CHANGELOG_3_3_8 = {
  deDE = [[
• Ein Fehler wurde behoben, bei dem das Addon RareScanner die MapNotes-"POIs"-Funktion ausgehebelt hat.
]],

  enUS = [[
• Fixed an issue where the RareScanner addon caused the MapNotes "POIs" function to stop working.
]],

  frFR = [[
• Correction d’un problème où l’addon RareScanner empêchait le fonctionnement de la fonction « POIs » de MapNotes.
]],

  itIT = [[
• Risolto un problema per cui l’addon RareScanner impediva il funzionamento della funzione "POIs" di MapNotes.
]],

  esES = [[
• Se solucionó un problema por el cual el addon RareScanner impedía el funcionamiento de la función "POIs" de MapNotes.
]],

  esMX = [[
• Se corrigió un problema por el cual el addon RareScanner impedía el funcionamiento de la función "POIs" de MapNotes.
]],

  ptBR = [[
• Corrigido um problema em que o addon RareScanner impedia o funcionamento da função "POIs" do MapNotes.
]],

  ruRU = [[
• Исправлена ошибка, из-за которой аддон RareScanner нарушал работу функции «POIs» в MapNotes.
]],

  zhCN = [[
• 修复了当启用 RareScanner 插件时导致 MapNotes“POI”功能无法正常工作的错误。
]],

  zhTW = [[
• 修正了一個在啟用 RareScanner 插件時導致 MapNotes「POI」功能無法正常運作的問題。
]],

  koKR = [[
• RareScanner 애드온이 활성화되어 있을 때 MapNotes의 "POIs" 기능이 정상적으로 작동하지 않던 문제가 수정되었습니다.
]],
}

ns.LOCALE_CHANGELOG_3_3_6 = {
  deDE = [[
• Die Anzeige der Tiefensymbole wurde wieder hinzugefügt, um einen neuen Lösungsansatz zu testen.

• Es ist nun möglich, auf den Tiefensymbolen von MapNotes einen TomTom- oder Blizzard-Wegpunkt zu setzen.

• Ein Fehler wurde behoben, der die Darstellung von Icons anderer Addons (z. B. PetTracker) verhindert hat.

• Sollte diese Version einen Fehler verursachen, den die vorherige Version nicht hatte, meldet ihn bitte.

• Danke!
]],

  enUS = [[
• The display of Delve icons has been restored to test a new possible solution.

• It is now possible to set a TomTom or Blizzard waypoint directly on MapNotes Delve icons.

• Fixed an issue that prevented icons from other addons (e.g. PetTracker) from being displayed.

• If this version causes an error that the previous version did not have, please report it.

• Thank you!
]],

  frFR = [[
• L’affichage des icônes de Gouffres a été réactivé afin de tester une nouvelle solution.

• Il est désormais possible de placer un point de cheminement TomTom ou Blizzard directement sur les icônes de Gouffres de MapNotes.

• Correction d’un problème qui empêchait l’affichage des icônes d’autres addons (par exemple PetTracker).

• Si cette version provoque une erreur qui n’existait pas dans la version précédente, veuillez la signaler.

• Merci !
]],

  itIT = [[
• La visualizzazione delle icone delle Spedizioni nelle Profondità è stata riattivata per testare una nuova possibile soluzione.

• Ora è possibile impostare un punto di percorso TomTom o Blizzard direttamente sulle icone delle Profondità di MapNotes.

• Risolto un problema che impediva la visualizzazione delle icone di altri addon (ad esempio PetTracker).

• Se questa versione causa un errore che la versione precedente non aveva, segnalatelo.

• Grazie!
]],

  esES = [[
• La visualización de los iconos de Profundidades se ha vuelto a activar para probar una nueva posible solución.

• Ahora es posible colocar un punto de ruta de TomTom o de Blizzard directamente sobre los iconos de Profundidades de MapNotes.

• Se solucionó un problema que impedía mostrar iconos de otros addons (por ejemplo PetTracker).

• Si esta versión provoca un error que la versión anterior no tenía, por favor repórtalo.

• ¡Gracias!
]],

  esMX = [[
• La visualización de los íconos de Profundidades se ha vuelto a activar para probar una nueva posible solución.

• Ahora es posible colocar un punto de ruta de TomTom o de Blizzard directamente sobre los íconos de Profundidades de MapNotes.

• Se corrigió un problema que impedía mostrar íconos de otros addons (por ejemplo PetTracker).

• Si esta versión provoca un error que la versión anterior no tenía, por favor repórtalo.

• ¡Gracias!
]],

  ptBR = [[
• A exibição dos ícones de Mergulhos foi reativada para testar uma nova possível solução.

• Agora é possível definir um ponto de rota do TomTom ou da Blizzard diretamente nos ícones de Mergulhos do MapNotes.

• Corrigido um problema que impedia a exibição de ícones de outros addons (por exemplo PetTracker).

• Se esta versão causar um erro que não existia na versão anterior, por favor reporte-o.

• Obrigado!
]],

  ruRU = [[
• Отображение значков Вылазок снова включено для тестирования нового возможного решения.

• Теперь можно устанавливать точку маршрута TomTom или Blizzard прямо на значках вылазок MapNotes.

• Исправлена ошибка, из-за которой не отображались значки других аддонов (например PetTracker).

• Если эта версия вызывает ошибку, которой не было в предыдущей версии, пожалуйста, сообщите о ней.

• Спасибо!
]],

  zhCN = [[
• 深潜图标的显示已重新启用，以测试一种新的解决方案。

• 现在可以直接在 MapNotes 的深潜图标上设置 TomTom 或暴雪导航点。

• 修复了一个导致其他插件图标（例如 PetTracker）无法显示的问题。

• 如果此版本出现之前版本没有的错误，请进行反馈。

• 谢谢！
]],

  zhTW = [[
• 深淵圖示的顯示已重新啟用，以測試新的解決方案。

• 現在可以直接在 MapNotes 的深淵圖示上設定 TomTom 或暴雪導航點。

• 修正了一個導致其他插件圖示（例如 PetTracker）無法顯示的問題。

• 如果此版本出現先前版本沒有的錯誤，請回報。

• 謝謝！
]],

  koKR = [[
• 새로운 해결 방법을 테스트하기 위해 탐험(Delve) 아이콘 표시가 다시 활성화되었습니다.

• 이제 MapNotes의 탐험 아이콘에서 TomTom 또는 블리자드 길찾기 지점을 직접 설정할 수 있습니다.

• 다른 애드온(예: PetTracker)의 아이콘이 표시되지 않던 문제가 수정되었습니다.

• 이전 버전에는 없던 오류가 이 버전에서 발생하면 제보해 주세요.

• 감사합니다!
]],
}

ns.LOCALE_CHANGELOG_3_3_5 = {
  deDE = [[
• Vorübergehend wurde die Anzeige der Tiefensymbole entfernt, bis eine dauerhafte Lösung gefunden wurde, da Änderungen an den Blizzard-Tiefen aktuell zu mehreren Taint-Fehlern führen.

• Der Minimap-Button-Fehler wurde behoben. Nachdem der Button deaktiviert wurde, sollte er nach einem Reload oder Ein-/Ausloggen nun seinen eingestellten Wert beibehalten.

• Der fehlende Briefkasten und Gastwirt wurden im Immersangwald hinzugefügt.
]],

  enUS = [[
• The display of Delve icons has been temporarily removed until a permanent solution is found, as modifying Blizzard Delves currently causes multiple taint errors.

• Fixed an issue with the minimap button. After being disabled, it should now keep its set state after a reload or relog.

• The missing mailbox and innkeeper have been added in Eversong Woods.
]],

  frFR = [[
• L’affichage des icônes de Gouffres a été temporairement désactivé jusqu’à ce qu’une solution permanente soit trouvée, car la modification des Gouffres de Blizzard provoque actuellement plusieurs erreurs de taint.

• Correction d’un problème avec le bouton de la minicarte. Après avoir été désactivé, il conserve désormais son état après un rechargement de l’interface ou une reconnexion.

• La boîte aux lettres et l’aubergiste manquants ont été ajoutés dans les Bois des Chants éternels.
]],

  itIT = [[
• La visualizzazione delle icone delle Spedizioni nelle Profondità è stata temporaneamente rimossa finché non verrà trovata una soluzione permanente, poiché modificare le Profondità di Blizzard causa attualmente diversi errori di taint.

• Risolto un problema con il pulsante della minimappa. Dopo essere stato disattivato, ora mantiene il suo stato dopo un reload dell’interfaccia o una riconnessione.

• La cassetta della posta e il locandiere mancanti sono stati aggiunti a Bosco Cantoeterno.
]],

  esES = [[
• La visualización de los iconos de Profundidades se ha eliminado temporalmente hasta que se encuentre una solución permanente, ya que modificar las Profundidades de Blizzard actualmente provoca varios errores de taint.

• Se solucionó un problema con el botón del minimapa. Después de desactivarlo, ahora mantiene su estado tras recargar la interfaz o volver a iniciar sesión.

• El buzón y el tabernero que faltaban se han añadido en Bosque Canción Eterna.
]],

  esMX = [[
• La visualización de los íconos de Profundidades se ha eliminado temporalmente hasta que se encuentre una solución permanente, ya que modificar las Profundidades de Blizzard actualmente provoca varios errores de taint.

• Se corrigió un problema con el botón del minimapa. Después de desactivarlo, ahora mantiene su estado tras recargar la interfaz o volver a iniciar sesión.

• El buzón y el tabernero faltantes se han añadido en Bosque Canción Eterna.
]],

  ptBR = [[
• A exibição dos ícones de Mergulhos foi temporariamente removida até que uma solução permanente seja encontrada, pois modificar os Mergulhos da Blizzard atualmente causa vários erros de taint.

• Corrigido um problema com o botão do minimapa. Após ser desativado, agora ele mantém seu estado após um reload da interface ou ao reconectar.

• A caixa de correio e o estalajadeiro que estavam faltando foram adicionados em Floresta do Canto Eterno.
]],

  ruRU = [[
• Отображение значков Вылазок временно отключено, пока не будет найдено постоянное решение, поскольку изменение вылазок Blizzard в настоящее время вызывает несколько ошибок taint.

• Исправлена ошибка с кнопкой миникарты. После отключения она теперь сохраняет своё состояние после перезагрузки интерфейса или повторного входа в игру.

• Отсутствующие почтовый ящик и трактирщик были добавлены в Леса Вечной Песни.
]],

  zhCN = [[
• 深潜图标的显示已被暂时移除，直到找到永久解决方案，因为当前修改暴雪的深潜会导致多个 taint 错误。

• 修复了小地图按钮的问题。禁用后，在界面重载或重新登录后现在会保持其设置状态。

• 在永歌森林中添加了缺失的邮箱和旅店老板。
]],

  zhTW = [[
• 深淵圖示的顯示已暫時移除，直到找到永久解決方案，因為目前修改暴雪的深淵會導致多個 taint 錯誤。

• 修正了小地圖按鈕的問題。停用後，在重新載入介面或重新登入後現在會保持其設定狀態。

• 在永歌森林中新增了缺少的郵箱與旅店老闆。
]],

  koKR = [[
• 영구적인 해결책이 발견될 때까지 탐험(Delve) 아이콘 표시가 일시적으로 제거되었습니다. 현재 블리자드 탐험을 수정하면 여러 taint 오류가 발생하기 때문입니다.

• 미니맵 버튼 문제가 수정되었습니다. 비활성화한 후 인터페이스를 다시 불러오거나 재접속해도 설정 상태가 이제 유지됩니다.

• 영원노래 숲에 누락되었던 우체통과 여관주인이 추가되었습니다.
]],
}

ns.LOCALE_CHANGELOG_3_3_4 = {

  deDE = [[
• Die Darstellung der Tiefensymbole wurde überarbeitet.

• Leider können die erzeugten Tiefensymbole im Kampf eine Fehlermeldung verursachen. Daher werden sie im Kampf nun automatisch ausgeblendet und nach dem Kampf wieder automatisch angezeigt, sobald man die Karte öffnet oder auf eine andere Karte wechselt.

• Es ist nun möglich, die Tiefensymbole zu vergrößern oder zu verkleinern – sowohl auf der Zonenkarte als auch auf der Kontinentkarte.

• Die Blizzard-Tiefenanzeige auf der Zonenkarte wird durch MapNotes automatisch deaktiviert und durch die MapNotes-Anzeige ersetzt.

• Zusätzlich ist es nun möglich, auf der Zonen- und Kontinentkarte festzulegen, ob nur Tiefen, nur Großzügige Tiefen oder beide angezeigt werden sollen. Zu finden im jeweiligen Reiter.

• Leider gibt es noch mögliche Fehler, die durch Blizzards Änderungen an den APIs verursacht werden. Daran wird gearbeitet.

• Solltet ihr einen solchen Fehler finden, überprüft bitte zuerst, ob dieser nicht bereits gemeldet wurde, bevor ihr ihn erneut meldet.

• Da ich dieses Addon alleine in meiner Freizeit verwalte, ist es nicht hilfreich, die gleiche Fehlermeldung mehrfach zu erhalten oder einen Bericht ohne Details zu bekommen.

• Bitte nehmt euch daher kurz die Zeit und meldet einen Fehler nur, wenn er noch nicht gemeldet wurde – und verwendet dabei das Fehlerprotokoll, da dies die Fehlersuche und Behebung erheblich erleichtert.

• Danke
]],


  enUS = [[
• The display of Delve icons has been revised.

• Unfortunately, the generated Delve icons can cause an error during combat. Therefore, they are now automatically hidden while in combat and will automatically reappear after combat once you open the map or switch to another map.

• It is now possible to increase or decrease the size of Delve icons on both the zone map and the continent map.

• The Blizzard Delve display on the zone map is automatically disabled by MapNotes and replaced with the MapNotes version.

• Additionally, you can now choose on both the zone and continent maps whether to display only Delves, only Bountiful Delves, or both. This can be configured in the respective tab.

• There may still be issues caused by Blizzard’s API changes. These are currently being worked on.

• If you encounter such an issue, please first check whether it has already been reported before submitting the same error again.

• Since I maintain this addon alone in my spare time, it is not helpful to receive the same error report multiple times or reports without useful details.

• Please take a moment to check whether the issue has already been reported before submitting it – and use the error log, as it significantly helps with troubleshooting and fixing the problem.

• Thank you
]],


  frFR = [[
• L’affichage des icônes de Gouffre a été révisé.

• Malheureusement, les icônes générées peuvent provoquer une erreur en combat. Elles sont désormais automatiquement masquées en combat et réapparaîtront après le combat lorsque vous ouvrez la carte ou changez de carte.

• Il est désormais possible d’agrandir ou de réduire la taille des icônes sur la carte de zone ainsi que sur la carte du continent.

• L’affichage Blizzard sur la carte de zone est automatiquement désactivé par MapNotes et remplacé par celui de MapNotes.

• Il est également possible de choisir d’afficher uniquement les Gouffres, uniquement les Gouffres Abondants (Bountiful Delves) ou les deux.

• Des erreurs peuvent encore survenir en raison des modifications des API de Blizzard. Elles sont en cours de correction.

• Si vous rencontrez une telle erreur, veuillez d’abord vérifier si elle n’a pas déjà été signalée.

• Je gère cet addon seul pendant mon temps libre ; recevoir plusieurs fois le même rapport ou des rapports sans détails utiles n’est pas utile.

• Merci de vérifier si le problème a déjà été signalé et d’utiliser le journal d’erreurs, car cela facilite grandement la recherche et la correction du problème.

• Merci
]],


  itIT = [[
• La visualizzazione delle icone delle Spedizioni è stata rivista.

• Le icone generate possono causare un errore durante il combattimento. Ora vengono automaticamente nascoste in combattimento e riappariranno dopo il combattimento quando si apre o si cambia mappa.

• È possibile aumentare o diminuire la dimensione delle icone sia sulla mappa di zona sia su quella del continente.

• La visualizzazione Blizzard sulla mappa di zona viene automaticamente disattivata da MapNotes e sostituita dalla versione di MapNotes.

• È possibile scegliere se visualizzare solo Spedizioni, solo Spedizioni Generose (Bountiful Delves) oppure entrambe.

• Potrebbero ancora verificarsi errori dovuti alle modifiche delle API Blizzard. Si sta lavorando alla loro risoluzione.

• Se trovate un errore, verificate prima che non sia già stato segnalato.

• Gestisco questo addon da solo nel mio tempo libero; ricevere la stessa segnalazione più volte o senza dettagli utili non è di aiuto.

• Vi prego di controllare prima se il problema è già stato segnalato e di utilizzare il registro degli errori, poiché facilita notevolmente la risoluzione.

• Grazie
]],


  esES = [[
• La visualización de los iconos de Abismo ha sido revisada.

• Los iconos generados pueden causar un error durante el combate. Ahora se ocultan automáticamente en combate y reaparecen después al abrir o cambiar de mapa.

• Es posible aumentar o reducir el tamaño de los iconos en el mapa de zona y en el mapa del continente.

• La visualización de Blizzard en el mapa de zona es desactivada automáticamente por MapNotes y reemplazada por la versión de MapNotes.

• Puedes elegir mostrar solo Abismos, solo Abismos Abundantes (Bountiful Delves) o ambos.

• Aún pueden producirse errores debido a cambios en las API de Blizzard.

• Si encuentras un error, verifica primero si ya ha sido reportado.

• Mantengo este addon yo solo en mi tiempo libre; recibir el mismo informe varias veces o sin detalles útiles no es de ayuda.

• Por favor, comprueba antes si el problema ya fue reportado y utiliza el registro de errores para facilitar la solución.

• Gracias
]],

}

ns.LOCALE_CHANGELOG_3_3_2 = {
  deDE = [[
• Nun ist es möglich, dass Änderungsprotokollfenster permanent zu deaktivieren. 

Einfach das Häckchen setzen bei "Änderungsprotokoll dauerhaft ausblenden" über das Änderungsprotokollfenster direkt nach einer neuen Version 

oder 

über das Addon Menü unter "Über Mapnotes > Änderungesprotokoll > Änderungsprotokoll dauerhaft ausblenden"

• Diese Optionen werden Accountweit gespeichert, und muss nicht für jeden Charakter einzeln aktiviert werden
]],

  enUS = [[
• It is now possible to permanently disable the changelog window.

Simply check "Permanently hide changelog" in the changelog window directly after a new version update

or

via the addon menu under "About MapNotes > Changelog > Permanently hide changelog"

• These options are saved account-wide and do not need to be activated separately for each character
]],

  frFR = [[
• Il est désormais possible de désactiver définitivement la fenêtre du journal des modifications.

Cochez simplement « Masquer définitivement le journal des modifications » dans la fenêtre du journal après une nouvelle version

ou

via le menu de l’addon sous « À propos de MapNotes > Journal des modifications > Masquer définitivement le journal des modifications »

• Ces options sont enregistrées pour tout le compte et n’ont pas besoin d’être activées séparément pour chaque personnage
]],

  itIT = [[
• Ora è possibile disattivare permanentemente la finestra del registro delle modifiche.

Basta selezionare "Nascondi permanentemente il registro delle modifiche" nella finestra del registro dopo una nuova versione

oppure

tramite il menu dell'addon in "Informazioni su MapNotes > Registro delle modifiche > Nascondi permanentemente il registro delle modifiche"

• Queste opzioni vengono salvate a livello di account e non devono essere attivate separatamente per ogni personaggio
]],

  esES = [[
• Ahora es posible desactivar permanentemente la ventana del registro de cambios.

Simplemente marca "Ocultar permanentemente el registro de cambios" en la ventana del registro tras una nueva versión

o

desde el menú del addon en "Acerca de MapNotes > Registro de cambios > Ocultar permanentemente el registro de cambios"

• Estas opciones se guardan a nivel de cuenta y no es necesario activarlas por separado para cada personaje
]],

  esMX = [[
• Ahora es posible desactivar permanentemente la ventana del registro de cambios.

Simplemente marca "Ocultar permanentemente el registro de cambios" en la ventana del registro después de una nueva versión

o

desde el menú del addon en "Acerca de MapNotes > Registro de cambios > Ocultar permanentemente el registro de cambios"

• Estas opciones se guardan a nivel de cuenta y no es necesario activarlas por separado para cada personaje
]],

  ptBR = [[
• Agora é possível desativar permanentemente a janela do registro de alterações.

Basta marcar "Ocultar permanentemente o registro de alterações" na janela do registro após uma nova versão

ou

pelo menu do addon em "Sobre MapNotes > Registro de alterações > Ocultar permanentemente o registro de alterações"

• Essas opções são salvas para toda a conta e não precisam ser ativadas separadamente para cada personagem
]],

  ruRU = [[
• Теперь можно навсегда отключить окно журнала изменений.

Просто установите флажок «Скрывать журнал изменений навсегда» в окне журнала после выхода новой версии

или

в меню аддона: «О MapNotes > Журнал изменений > Скрывать журнал изменений навсегда»

• Эти параметры сохраняются для всей учетной записи и не требуют отдельной активации для каждого персонажа
]],

  zhCN = [[
• 现在可以永久禁用更新日志窗口。

在新版本发布后，直接在更新日志窗口中勾选“永久隐藏更新日志”

或者

通过插件菜单进入“关于 MapNotes > 更新日志 > 永久隐藏更新日志”

• 这些选项为账号范围保存，无需为每个角色单独启用
]],

  zhTW = [[
• 現在可以永久停用更新日誌視窗。

在新版本發布後，直接在更新日誌視窗中勾選「永久隱藏更新日誌」

或者

透過插件選單進入「關於 MapNotes > 更新日誌 > 永久隱藏更新日誌」

• 這些選項為帳號共用儲存，無需為每個角色單獨啟用
]],

  koKR = [[
• 이제 변경 로그 창을 영구적으로 비활성화할 수 있습니다.

새 버전 이후 변경 로그 창에서 "변경 로그 영구 숨기기"를 체크하세요

또는

애드온 메뉴의 "MapNotes 정보 > 변경 로그 > 변경 로그 영구 숨기기"에서 설정할 수 있습니다

• 이 옵션은 계정 전체에 저장되며 각 캐릭터마다 따로 설정할 필요가 없습니다
]],
}

ns.LOCALE_CHANGELOG_3_3_0 = {
  deDE = [[
• Es wurde die Funktion entfernt, im Kampf die Karte über Symbole wechseln zu können, da dies nicht mehr ohne Fehler möglich ist.
• Das Wechseln der Karte außerhalb des Kampfes ist weiterhin ohne Probleme möglich.
]],

  enUS = [[
• The ability to switch maps via icons while in combat has been removed, as it is no longer possible without causing errors.
• Switching maps outside of combat is still possible without any issues.
]],

  frFR = [[
• La possibilité de changer de carte via les icônes pendant le combat a été supprimée, car cela n’est plus possible sans provoquer d’erreurs.
• Le changement de carte en dehors du combat reste possible sans aucun problème.
]],

  itIT = [[
• La funzione che permetteva di cambiare mappa tramite icone durante il combattimento è stata rimossa, poiché non è più possibile farlo senza causare errori.
• Il cambio della mappa al di fuori del combattimento è ancora possibile senza problemi.
]],

  esES = [[
• Se ha eliminado la función que permitía cambiar el mapa mediante iconos durante el combate, ya que ya no es posible hacerlo sin causar errores.
• Cambiar el mapa fuera de combate sigue siendo posible sin problemas.
]],

  esMX = [[
• Se eliminó la función que permitía cambiar el mapa mediante íconos durante el combate, ya que ya no es posible hacerlo sin causar errores.
• Cambiar el mapa fuera de combate sigue siendo posible sin problemas.
]],

  ptBR = [[
• A função que permitia alternar o mapa por meio de ícones durante o combate foi removida, pois não é mais possível fazê-lo sem causar erros.
• A troca de mapa fora de combate continua possível sem problemas.
]],

  ruRU = [[
• Возможность переключать карту с помощью значков во время боя была удалена, так как это больше невозможно без возникновения ошибок.
• Переключение карты вне боя по-прежнему возможно без каких-либо проблем.
]],

  zhCN = [[
• 已移除在战斗中通过图标切换地图的功能，因为该操作已无法在不产生错误的情况下使用。
• 在非战斗状态下切换地图仍然可以正常使用。
]],

  zhTW = [[
• 已移除在戰鬥中透過圖示切換地圖的功能，因為該操作已無法在不產生錯誤的情況下使用。
• 在非戰鬥狀態下切換地圖仍然可以正常使用。
]],

  koKR = [[
• 전투 중 아이콘을 통해 지도를 전환하는 기능이 오류를 발생시키지 않고는 더 이상 사용할 수 없어 제거되었습니다.
• 전투 외 상태에서는 지도 전환이 계속해서 문제없이 가능합니다.
]],
}

ns.LOCALE_CHANGELOG_3_2_9 = {
  deDE = [[
• Es wurde ein neues Symbol für neutrale Städte hinzugefügt. Anstelle des klassischen MapNotes-Symbols gibt es nun ein eigenes Symbol, das sowohl das Horde- als auch das Allianz-Wappen darstellt.

• Es wurde eine neue Kategorie in den Hauptstädte-Optionen unter „Allgemeine Symbole -> Dekorationsexperte“ hinzugefügt. Dieses Symbol zeigt nun den Standort der Dekorationshändler an.

• Folgende Karten wurden auf den Midnight-Stand aktualisiert:
  • Flugmeisterkarte
  • Hauptstädte (90 %)
  • Zone
  • Minimap
  • Kontinente
  • Azeroth
  • Worldmap
]],

  enUS = [[
• A new icon for neutral cities has been added. Instead of the classic MapNotes icon, there is now a dedicated icon displaying both the Horde and Alliance crests.

• A new category has been added to the capital city options under “General Icons -> Decoration Expert”. This icon now shows the location of decoration vendors.

• The following maps have been updated to the Midnight state:
  • Flight Master map
  • Capital cities (90%)
  • Zone
  • Minimap
  • Continents
  • Azeroth
  • World map
]],

  frFR = [[
• Une nouvelle icône pour les villes neutres a été ajoutée. Au lieu de l’icône MapNotes classique, une icône dédiée affichant les emblèmes de la Horde et de l’Alliance est désormais utilisée.

• Une nouvelle catégorie a été ajoutée dans les options des capitales sous « Icônes générales -> Expert en décoration ». Cette icône indique désormais l’emplacement des marchands de décorations.

• Les cartes suivantes ont été mises à jour vers l’état Midnight :
  • Carte des maîtres de vol
  • Capitales (90 %)
  • Zone
  • Mini-carte
  • Continents
  • Azeroth
  • Carte du monde
]],

  itIT = [[
• È stata aggiunta una nuova icona per le città neutrali. Al posto della classica icona MapNotes, ora viene utilizzata un’icona dedicata che mostra gli stemmi di Orda e Alleanza.

• È stata aggiunta una nuova categoria nelle opzioni delle capitali sotto “Icone generali -> Esperto di decorazioni”. Questa icona mostra ora la posizione dei mercanti di decorazioni.

• Le seguenti mappe sono state aggiornate allo stato Midnight:
  • Mappa dei maestri di volo
  • Capitali (90%)
  • Zona
  • Minimappa
  • Continenti
  • Azeroth
  • Mappa del mondo
]],

  esES = [[
• Se ha añadido un nuevo icono para las ciudades neutrales. En lugar del icono clásico de MapNotes, ahora se utiliza un icono dedicado que muestra los emblemas de la Horda y la Alianza.

• Se ha añadido una nueva categoría en las opciones de capitales bajo “Iconos generales -> Experto en decoración”. Este icono ahora muestra la ubicación de los vendedores de decoración.

• Los siguientes mapas se han actualizado al estado Midnight:
  • Mapa de maestros de vuelo
  • Capitales (90 %)
  • Zona
  • Minimapa
  • Continentes
  • Azeroth
  • Mapa del mundo
]],

  esMX = [[
• Se agregó un nuevo ícono para las ciudades neutrales. En lugar del ícono clásico de MapNotes, ahora se usa un ícono dedicado que muestra los emblemas de la Horda y la Alianza.

• Se agregó una nueva categoría en las opciones de capitales bajo “Iconos generales -> Experto en decoración”. Este ícono ahora muestra la ubicación de los vendedores de decoración.

• Los siguientes mapas se actualizaron al estado Midnight:
  • Mapa de maestros de vuelo
  • Capitales (90 %)
  • Zona
  • Minimapa
  • Continentes
  • Azeroth
  • Mapa del mundo
]],

  ptBR = [[
• Um novo ícone para cidades neutras foi adicionado. Em vez do ícone clássico do MapNotes, agora há um ícone dedicado que exibe os emblemas da Horda e da Aliança.

• Uma nova categoria foi adicionada às opções das capitais em “Ícones gerais -> Especialista em decoração”. Este ícone agora mostra a localização dos vendedores de decoração.

• Os seguintes mapas foram atualizados para o estado Midnight:
  • Mapa de mestres de voo
  • Capitais (90%)
  • Zona
  • Minimapa
  • Continentes
  • Azeroth
  • Mapa do mundo
]],

  ruRU = [[
• Добавлен новый значок для нейтральных городов. Вместо классического значка MapNotes теперь используется отдельный значок с эмблемами Орды и Альянса.

• В настройках столиц добавлена новая категория в разделе «Общие значки -> Эксперт по декору». Этот значок теперь показывает местоположение торговцев украшениями.

• Следующие карты были обновлены до состояния Midnight:
  • Карта распорядителей полётов
  • Столицы (90 %)
  • Зона
  • Миникарта
  • Континенты
  • Азерот
  • Карта мира
]],

  zhCN = [[
• 新增了一个用于中立城市的图标。取代经典的 MapNotes 图标，现在使用一个同时显示部落与联盟徽记的专用图标。

• 在主城选项中的“常规图标 -> 装饰专家”下新增了一个分类。该图标现在会显示装饰品商人的位置。

• 以下地图已更新至 Midnight 状态：
  • 飞行管理员地图
  • 主城（90%）
  • 区域
  • 小地图
  • 大陆
  • 艾泽拉斯
  • 世界地图
]],

  zhTW = [[
• 新增了一個用於中立城市的圖示。取代經典的 MapNotes 圖示，現在使用一個同時顯示部落與聯盟徽章的專用圖示。

• 在主城選項中的「一般圖示 -> 裝飾專家」下新增了一個分類。此圖示現在會顯示裝飾品商人的位置。

• 以下地圖已更新至 Midnight 狀態：
  • 飛行管理員地圖
  • 主城（90%）
  • 區域
  • 小地圖
  • 大陸
  • 艾澤拉斯
  • 世界地圖
]],

  koKR = [[
• 중립 도시를 위한 새로운 아이콘이 추가되었습니다. 기존 MapNotes 아이콘 대신, 호드와 얼라이언스 문장을 모두 표시하는 전용 아이콘이 사용됩니다.

• “일반 아이콘 -> 장식 전문가” 아래의 수도 옵션에 새로운 카테고리가 추가되었습니다. 이 아이콘은 이제 장식 상인의 위치를 표시합니다.

• 다음 지도들이 Midnight 상태로 업데이트되었습니다:
  • 비행 조련사 지도
  • 수도 (90%)
  • 지역
  • 미니맵
  • 대륙
  • 아제로스
  • 세계 지도
]],
}

ns.LOCALE_CHANGELOG_3_2_5 = { 
  deDE = [[
• Einige Funktionen und Symbole wurden bereits auf den Midnight-Stand aktualisiert
  • Unerforschte Gebiete
  • Wegesymbole
  • Tiefenanzeige + Funktion zum direkten Anzeigen der Karten

• Die restlichen Symbole und Funktionen werden in den nächsten Tagen und Wochen auf den neuesten Stand gebracht.
• Solltet ihr irgendwelche Fehler finden, meldet diese bitte über die CurseForge-Addon-Seite:
  https://legacy.curseforge.com/wow/addons/mapnotes/issues

• Ich versuche, das Addon so schnell wie möglich auf den neuesten Stand zu bringen. Da es sich jedoch um ein Ein-Personen-Addon handelt, kann es gelegentlich zu Verzögerungen kommen.
]],

  enUS = [[
• Some functions and icons have already been updated to the Midnight standard
  • Unexplored areas
  • Path icons
  • Delve display + function to directly open the maps

• The remaining icons and functions will be updated to the latest standard over the next days and weeks.
• If you find any bugs, please report them on the CurseForge addon page:
  https://legacy.curseforge.com/wow/addons/mapnotes/issues

• I am trying to update the addon as quickly as possible. However, since this is a one-person addon, delays may occasionally occur.
]],

  frFR = [[
• Certaines fonctionnalités et icônes ont déjà été mises à jour selon le standard Midnight
  • Zones inexplorées
  • Icônes de chemins
  • Affichage des Gouffres + fonction pour ouvrir directement les cartes

• Les icônes et fonctionnalités restantes seront mises à jour dans les prochains jours et semaines.
• Si vous trouvez des erreurs, veuillez les signaler sur la page CurseForge de l’addon :
  https://legacy.curseforge.com/wow/addons/mapnotes/issues

• Je fais de mon mieux pour mettre l’addon à jour rapidement. Cependant, comme il s’agit d’un addon développé par une seule personne, des retards peuvent survenir.
]],

  itIT = [[
• Alcune funzioni e icone sono già state aggiornate allo standard Midnight
  • Aree inesplorate
  • Icone dei percorsi
  • Visualizzazione delle Incursioni + funzione per aprire direttamente le mappe

• Le restanti icone e funzioni verranno aggiornate nei prossimi giorni e settimane.
• Se riscontrate errori, segnalateli sulla pagina CurseForge dell’addon:
  https://legacy.curseforge.com/wow/addons/mapnotes/issues

• Sto cercando di aggiornare l’addon il più rapidamente possibile. Tuttavia, trattandosi di un addon sviluppato da una sola persona, potrebbero verificarsi dei ritardi.
]],

  esES = [[
• Algunas funciones e iconos ya han sido actualizados al estándar Midnight
  • Zonas inexploradas
  • Iconos de caminos
  • Visualización de Profundidades + función para abrir los mapas directamente

• Los iconos y funciones restantes se actualizarán en los próximos días y semanas.
• Si encontráis algún error, informadlo en la página del addon en CurseForge:
  https://legacy.curseforge.com/wow/addons/mapnotes/issues

• Intento actualizar el addon lo más rápido posible. Sin embargo, al tratarse de un addon desarrollado por una sola persona, pueden producirse retrasos ocasionales.
]],

  esMX = [[
• Algunas funciones e iconos ya han sido actualizados al estándar Midnight
  • Zonas inexploradas
  • Iconos de caminos
  • Visualización de Profundidades + función para abrir los mapas directamente

• Los iconos y funciones restantes se actualizarán en los próximos días y semanas.
• Si encuentran algún error, repórtenlo en la página del addon en CurseForge:
  https://legacy.curseforge.com/wow/addons/mapnotes/issues

• Intento actualizar el addon lo más rápido posible. Sin embargo, al ser un addon desarrollado por una sola persona, pueden presentarse retrasos ocasionales.
]],

  ptBR = [[
• Algumas funções e ícones já foram atualizados para o padrão Midnight
  • Áreas inexploradas
  • Ícones de caminhos
  • Exibição de Delves + função para abrir os mapas diretamente

• Os ícones e funções restantes serão atualizados nos próximos dias e semanas.
• Caso encontre algum erro, reporte-o na página do addon no CurseForge:
  https://legacy.curseforge.com/wow/addons/mapnotes/issues

• Estou tentando atualizar o addon o mais rápido possível. No entanto, por se tratar de um addon desenvolvido por apenas uma pessoa, podem ocorrer atrasos ocasionais.
]],

  ruRU = [[
• Некоторые функции и значки уже были обновлены до стандарта Midnight
  • Неисследованные области
  • Значки путей
  • Отображение Вылазок + функция прямого открытия карт

• Остальные значки и функции будут обновлены в ближайшие дни и недели.
• Если вы обнаружите ошибки, пожалуйста, сообщите о них на странице аддона CurseForge:
  https://legacy.curseforge.com/wow/addons/mapnotes/issues

• Я стараюсь как можно быстрее обновлять аддон. Однако, поскольку аддон разрабатывается одним человеком, иногда возможны задержки.
]],

  zhCN = [[
• 部分功能和图标已更新至 Midnight 标准
  • 未探索区域
  • 路径图标
  • 深渊显示 + 直接打开地图的功能

• 其余图标和功能将在接下来的几天和几周内更新。
• 如果你发现任何错误，请在 CurseForge 插件页面反馈：
  https://legacy.curseforge.com/wow/addons/mapnotes/issues

• 我会尽力尽快更新该插件。但由于这是一个由单人维护的插件，更新过程中可能会出现延迟。
]],

  zhTW = [[
• 部分功能與圖示已更新至 Midnight 標準
  • 未探索區域
  • 路徑圖示
  • 深淵顯示 + 可直接開啟地圖的功能

• 其餘圖示與功能將於未來幾天與數週內更新。
• 若發現任何錯誤，請至 CurseForge 插件頁面回報：
  https://legacy.curseforge.com/wow/addons/mapnotes/issues

• 我會盡力盡快更新插件，但由於這是單人維護的插件，偶爾可能會有更新延遲。
]],

  koKR = [[
• 일부 기능과 아이콘이 이미 Midnight 기준에 맞게 업데이트되었습니다
  • 미탐험 지역
  • 경로 아이콘
  • 심층(Delve) 표시 + 지도 바로 열기 기능

• 나머지 아이콘과 기능은 향후 며칠 및 몇 주에 걸쳐 업데이트될 예정입니다.
• 오류를 발견하시면 CurseForge 애드온 페이지를 통해 제보해 주세요:
  https://legacy.curseforge.com/wow/addons/mapnotes/issues

• 가능한 한 빠르게 애드온을 최신 상태로 유지하려고 노력하고 있습니다. 다만 1인 개발 애드온이기 때문에 업데이트가 지연될 수 있습니다.
]],
}

ns.partialUpdate = {
  deDE = [[
• Kleinere Anpassungen
]],

  enUS = [[
• Minor adjustments
]],

  frFR = [[
• Ajustements mineurs
]],

  itIT = [[
• Modifiche minori
]],

  esES = [[
• Ajustes menores
]],

  esMX = [[
• Ajustes menores
]],

  ptBR = [[
• Pequenos ajustes
]],

  ruRU = [[
• Незначительные изменения
]],

  zhCN = [[
• 小幅调整
]],

  zhTW = [[
• 小幅調整
]],

  koKR = [[
• 소규모 조정
]],
}

ns.prepatchUpdate = {
  deDE = [[
• Vorbereitung für zukünftiges Update
]],

  enUS = [[
• Preparation for a future update
]],

  frFR = [[
• Préparation pour une mise à jour future
]],

  itIT = [[
• Preparazione per un aggiornamento futuro
]],

  esES = [[
• Preparación para una actualización futura
]],

  esMX = [[
• Preparación para una actualización futura
]],

  ptBR = [[
• Preparação para uma atualização futura
]],

  ruRU = [[
• Подготовка к будущему обновлению
]],

  zhCN = [[
• 为未来更新做准备
]],

  zhTW = [[
• 為未來更新做準備
]],

  koKR = [[
• 향후 업데이트 준비
]],
}

ns.classicUpdate = {
  deDE = [[
• Update Classic
]],

  enUS = [[
• Classic update
]],

  frFR = [[
• Mise à jour Classic
]],

  itIT = [[
• Aggiornamento Classic
]],

  esES = [[
• Actualización de Classic
]],

  esMX = [[
• Actualización de Classic
]],

  ptBR = [[
• Atualização do Classic
]],

  ruRU = [[
• Обновление Classic
]],

  zhCN = [[
• Classic 更新
]],

  zhTW = [[
• Classic 更新
]],

  koKR = [[
• Classic 업데이트
]],
}

ns.smallChanges = {
  deDE = [[
• kleinere Anpassungen
]],

  enUS = [[
• minor adjustments
]],

  frFR = [[
• ajustements mineurs
]],

  itIT = [[
• piccoli aggiustamenti
]],

  esES = [[
• ajustes menores
]],

  esMX = [[
• ajustes menores
]],

  ptBR = [[
• pequenos ajustes
]],

  ruRU = [[
• небольшие изменения
]],

  zhCN = [[
• 小幅调整
]],

  zhTW = [[
• 小幅調整
]],

  koKR = [[
• 소소한 조정
]],
}

ns.tocUpdate = {
  deDE = [[
• toc update
]],

  enUS = [[
• TOC update
]],

  frFR = [[
• Mise à jour du TOC
]],

  itIT = [[
• Aggiornamento del TOC
]],

  esES = [[
• Actualización del TOC
]],

  esMX = [[
• Actualización del TOC
]],

  ptBR = [[
• Atualização do TOC
]],

  ruRU = [[
• Обновление TOC
]],

  zhCN = [[
• TOC 更新
]],

  zhTW = [[
• TOC 更新
]],

  koKR = [[
• TOC 업데이트
]],
}