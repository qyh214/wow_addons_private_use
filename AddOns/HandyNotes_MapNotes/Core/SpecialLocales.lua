local ADDON_NAME, ns = ...
ns.locale = GetLocale()

ns.ABOUT = { -- RetailOptions.lua
  deDE = "Über",
  enUS = "About",
  frFR = "À propos",
  esES = "Acerca de",
  esMX = "Acerca de",
  itIT = "Informazioni",
  ptBR = "Sobre",
  ruRU = "О дополнении",
  zhCN = "关于",
  zhTW = "關於",
  koKR = "정보",
}

ns.CHANGE_VERSIONS_CHECK = { -- RetailVersionsCheck.lua
  deDE = "Neue Version |cff00ff00%s|r verfügbar, deine Version |cffffff00%s|r ist veraltet!",
  enUS = "New version |cff00ff00%s|r available, your version |cffffff00%s|r is outdated!",
  frFR = "Nouvelle version |cff00ff00%s|r disponible, votre version |cffffff00%s|r est obsolète!",
  esES = "Nueva versión |cff00ff00%s|r disponible, tu versión |cffffff00%s|r está obsoleta!",
  esMX = "Nueva versión |cff00ff00%s|r disponible, tu versión |cffffff00%s|r está obsoleta!",
  itIT = "Nuova versione |cff00ff00%s|r disponibile, la tua versione |cffffff00%s|r è obsoleta!",
  ptBR = "Nova versão |cff00ff00%s|r disponível, sua versão |cffffff00%s|r está desatualizada!",
  ruRU = "Доступна новая версия |cff00ff00%s|r, ваша версия |cffffff00%s|r устарела!",
  zhCN = "有新版本 |cff00ff00%s|r 可用, 你的版本 |cffffff00%s|r 已过时!",
  zhTW = "有新版本 |cff00ff00%s|r 可用, 你的版本 |cffffff00%s|r 已過時!",
  koKR = "새 버전 |cff00ff00%s|r 사용 가능, 현재 버전 |cffffff00%s|r 은(는) 오래되었습니다!",
}

ns.CHANGE_LOG_CONFIRMED = { -- RetailChangelog.lua
  deDE = "Das Änderungsprotokoll wird bis zu einer neuen Version nicht mehr automatisch angezeigt",
  enUS = "The changelog will no longer be displayed automatically until a new version is released",
  frFR = "Le journal des modifications ne sera plus affiché automatiquement jusqu’à la sortie d’une nouvelle version",
  esES = "El registro de cambios ya no se mostrará automáticamente hasta que se lance una nueva versión",
  esMX = "El registro de cambios ya no se mostrará automáticamente hasta que se lance una nueva versión",
  itIT = "Il registro delle modifiche non verrà più mostrato automaticamente fino al rilascio di una nuova versione",
  ptBR = "O registro de alterações não será mais exibido automaticamente até o lançamento de uma nova versão",
  ruRU = "Журнал изменений больше не будет автоматически отображаться до выхода новой версии",
  zhCN = "在新版本发布之前，更新日志将不再自动显示",
  zhTW = "在新版本發布之前，更新日誌將不再自動顯示",
  koKR = "새 버전이 출시될 때까지 변경 로그는 더 이상 자동으로 표시되지 않습니다",
}

ns.LOCALE_USE_IN_COMBAT_NAME = { -- RetailOptions.lua
  enUS = "Use in combat anyway",
  deDE = "Im Kampf trotzdem verwenden",
  frFR = "Utiliser en combat quand même",
  esES = "Usar en combate de todos modos",
  esMX = "Usar en combate de todos modos",
  itIT = "Usare comunque in combattimento",
  ptBR = "Usar em combate mesmo assim",
  ruRU = "Использовать в бою всё равно",
  koKR = "전투 중에도 강제로 사용",
  zhCN = "战斗中仍然使用",
  zhTW = "戰鬥中仍然使用",
}

ns.LOCALE_USE_IN_COMBAT_1 = { -- RetailOptions.lua
  enUS = "I understand that enabling and continuing to use this feature with MapNotes icons or functions before, during, or after combat to change the world map may cause Blizzard errors",
  deDE = "Ich verstehe, dass die Aktivierung und weitere Nutzung dieser Funktion mit MapNotes-Symbolen oder -Funktionen vor, während oder nach dem Kampf beim Wechseln der Weltkarte zu Blizzard-Fehlern führen kann",
  frFR = "Je comprends qu’activer et continuer à utiliser cette fonction avec les icônes ou fonctions de MapNotes avant, pendant ou après un combat pour changer la carte du monde peut provoquer des erreurs de Blizzard",
  esES = "Entiendo que activar y seguir usando esta función con iconos o funciones de MapNotes antes, durante o después del combate para cambiar el mapa del mundo puede provocar errores de Blizzard",
  esMX = "Entiendo que activar y continuar usando esta función con iconos o funciones de MapNotes antes, durante o después del combate para cambiar el mapa del mundo puede causar errores de Blizzard",
  itIT = "Capisco che abilitare e continuare a usare questa funzione con le icone o funzioni di MapNotes prima, durante o dopo il combattimento per cambiare la mappa del mondo può causare errori di Blizzard",
  ptBR = "Entendo que ativar e continuar usando este recurso com ícones ou funções do MapNotes antes, durante ou após o combate para mudar o mapa do mundo pode causar erros da Blizzard",
  ruRU = "Я понимаю, что включение и дальнейшее использование этой функции с иконками или функциями MapNotes до, во время или после боя для смены карты мира может вызвать ошибки Blizzard",
  koKR = "전투 전후 또는 전투 중에 MapNotes 아이콘이나 기능으로 세계 지도를 변경하면 블리자드 오류가 발생할 수 있음을 이해합니다",
  zhCN = "我明白，在战斗前、战斗中或战斗后使用 MapNotes 图标或功能切换世界地图可能会导致暴雪错误",
  zhTW = "我了解，在戰鬥前、戰鬥中或戰鬥後使用 MapNotes 圖示或功能切換世界地圖可能會導致暴雪錯誤",
}

ns.LOCALE_USE_IN_COMBAT_2 = { -- RetailOptions.lua
  enUS = "Once the “ADDON_ACTION_BLOCKED” error has been triggered, it usually does not occur again during this play session, and you can still use MapNotes to switch the world map in combat. However, in some cases, further errors may occur that require reloading the UI",
  deDE = "Sobald der Fehler „ADDON_ACTION_BLOCKED“ einmal ausgelöst wurde, tritt er normalerweise nicht erneut in dieser Spielsitzung auf, und die Weltkartenumschaltung mit MapNotes kann weiterhin im Kampf genutzt werden. In manchen Fällen können jedoch weitere Fehler auftreten, die ein Neuladen der Benutzeroberfläche erfordern",
  frFR = "Une fois l’erreur « ADDON_ACTION_BLOCKED » déclenchée, elle ne se reproduit généralement pas durant cette session de jeu, et vous pouvez continuer à utiliser MapNotes pour changer la carte du monde en combat. Cependant, dans certains cas, d’autres erreurs peuvent survenir et nécessiter un rechargement de l’interface",
  esES = "Una vez que se ha producido el error «ADDON_ACTION_BLOCKED», normalmente no vuelve a ocurrir durante esta sesión de juego, y aún puedes usar MapNotes para cambiar el mapa del mundo en combate. Sin embargo, en algunos casos, pueden producirse errores adicionales que requieran recargar la interfaz",
  esMX = "Una vez que se ha producido el error «ADDON_ACTION_BLOCKED», por lo general no vuelve a ocurrir durante esta sesión de juego, y todavía puedes usar MapNotes para cambiar el mapa del mundo en combate. Sin embargo, en algunos casos, pueden ocurrir errores adicionales que requieran recargar la interfaz",
  itIT = "Una volta che si è verificato l’errore «ADDON_ACTION_BLOCKED», di solito non si ripete durante questa sessione di gioco e puoi continuare a usare MapNotes per cambiare la mappa del mondo in combattimento. Tuttavia, in alcuni casi, possono verificarsi ulteriori errori che richiedono di ricaricare l’interfaccia",
  ptBR = "Uma vez que o erro «ADDON_ACTION_BLOCKED» foi acionado, normalmente ele não ocorre novamente durante esta sessão de jogo, e você ainda pode usar o MapNotes para mudar o mapa do mundo em combate. No entanto, em alguns casos, podem ocorrer erros adicionais que exigem recarregar a interface",
  ruRU = "После того как ошибка «ADDON_ACTION_BLOCKED» была вызвана один раз, обычно она больше не возникает в текущей игровой сессии, и вы всё ещё можете использовать MapNotes для переключения карты мира в бою. Однако в некоторых случаях могут возникнуть дополнительные ошибки, требующие перезагрузки интерфейса",
  koKR = "일단 «ADDON_ACTION_BLOCKED» 오류가 발생하면 이 게임 세션 동안에는 보통 다시 발생하지 않으며, 전투 중에도 MapNotes로 세계 지도를 전환할 수 있습니다. 다만 경우에 따라 추가 오류가 발생하여 UI를 다시 불러와야 할 수도 있습니다",
  zhCN = "一旦触发了“ADDON_ACTION_BLOCKED”错误，通常在本次游戏会话期间不会再次发生，并且你仍然可以在战斗中使用 MapNotes 切换世界地图。不过，在某些情况下，可能会出现其他错误，需要重新加载界面",
  zhTW = "一旦觸發「ADDON_ACTION_BLOCKED」錯誤，通常在本次遊戲會話期間不會再次發生，並且你仍然可以在戰鬥中使用 MapNotes 切換世界地圖。然而，在某些情況下，可能會出現其他錯誤，需要重新載入介面",
}

ns.LOCALE_SUPPRESS_ERRORS_DESC_1 = { -- RetailOptions.lua
  enUS = "Attempts to suppress and hide all errors that may arise from switching the world map via MapNotes, so that only very rare and specific errors get through, which can only be resolved with a /reload of the user interface",
  deDE = "Versucht, alle Fehler zu unterdrücken und auszublenden, die durch das Wechseln der Weltkarte über MapNotes entstehen können, sodass nur sehr seltene und spezielle Fehler durchkommen, die sich nur mit einem /reload der Benutzeroberfläche beheben lassen",
  frFR = "Essaie de supprimer et de masquer toutes les erreurs susceptibles de survenir lors du changement de la carte du monde via MapNotes, afin que seules des erreurs très rares et spécifiques passent, lesquelles ne peuvent être corrigées qu’avec un /reload de l’interface utilisateur",
  esES = "Intenta suprimir y ocultar todos los errores que puedan surgir al cambiar el mapa del mundo mediante MapNotes, de modo que solo aparezcan errores muy raros y específicos que solo se pueden resolver con un /reload de la interfaz de usuario",
  esMX = "Intenta suprimir y ocultar todos los errores que puedan surgir al cambiar el mapa del mundo mediante MapNotes, de modo que solo aparezcan errores muy raros y específicos que solo se pueden resolver con un /reload de la interfaz de usuario",
  itIT = "Cerca di sopprimere e nascondere tutti gli errori che possono insorgere cambiando la mappa del mondo tramite MapNotes, così che passino solo errori molto rari e specifici, risolvibili soltanto con un /reload dell’interfaccia utente",
  ptBR = "Tenta suprimir e ocultar todos os erros que podem surgir ao trocar o mapa-múndi via MapNotes, de modo que apenas erros muito raros e específicos passem, os quais só podem ser resolvidos com um /reload da interface do usuário",
  ruRU = "Пытается подавить и скрыть все ошибки, которые могут возникнуть при переключении карты мира через MapNotes, так что проходят только очень редкие и специфические ошибки, которые можно исправить лишь с помощью /reload интерфейса пользователя",
  koKR = "MapNotes로 세계 지도를 전환할 때 발생할 수 있는 모든 오류를 억제하고 숨기려고 시도하여, /reload로만 해결 가능한 매우 드물고 특정한 오류만 표시되도록 합니다",
  zhCN = "尝试抑制并隐藏通过 MapNotes 切换世界地图时可能产生的所有错误，使只有极少数特定错误会显示，这些错误只能通过 /reload 用户界面来解决",
  zhTW = "嘗試抑制並隱藏透過 MapNotes 切換世界地圖時可能產生的所有錯誤，僅讓極少數特定錯誤顯示，而這些錯誤只能透過 /reload 使用者介面來解決",
}

ns.LOCALE_SUPPRESS_ERRORS_DESC_2 = { -- RetailOptions.lua
  enUS = "In these cases, MapNotes creates a separate window with the option to quickly reload the user interface so that the error is resolved",
  deDE = "In diesen speziellen Fällen erstellt MapNotes ein Fenster mit der Option, die Benutzeroberfläche neu zu laden, sodass der Fehler bereinigt wird",
  frFR = "Dans ces cas, MapNotes crée une fenêtre distincte avec l’option de recharger rapidement l’interface utilisateur afin que l’erreur soit résolue",
  esES = "En estos casos, MapNotes crea una ventana separada con la opción de recargar rápidamente la interfaz de usuario para que el error quede resuelto",
  esMX = "En estos casos, MapNotes crea una ventana separada con la opción de recargar rápidamente la interfaz de usuario para que el error quede resuelto",
  itIT = "In questi casi, MapNotes crea una finestra separata con l’opzione di ricaricare rapidamente l’interfaccia utente, così che l’errore venga risolto",
  ptBR = "Nesses casos, o MapNotes cria uma janela separada com a opção de recarregar rapidamente a interface do usuário, resolvendo o erro",
  ruRU = "В этих случаях MapNotes создаёт отдельное окно с возможностью быстро перезагрузить интерфейс пользователя, чтобы ошибка была устранена",
  koKR = "이러한 경우, MapNotes는 사용자 인터페이스를 빠르게 다시 불러올 수 있는 별도의 창을 만들어 오류를 해결합니다",
  zhCN = "在这些情况下，MapNotes 会创建一个单独的窗口，提供快速重载用户界面的选项，从而解决错误",
  zhTW = "在這些情況下，MapNotes 會建立一個單獨的視窗，提供快速重新載入使用者介面的選項，從而解決錯誤",
}

ns.LOCALE_SUPPRESS_ERRORS_DESC_3 = { -- RetailOptions.lua
  enUS = "If you don't mind a short /reload in these rare cases, this option can be used",
  deDE = "Wenn dich ein kurzer /reload in diesen seltenen Fällen nicht stört, kann diese Variante verwendet werden",
  frFR = "Si un court /reload dans ces cas rares ne vous dérange pas, vous pouvez utiliser cette option",
  esES = "Si no te molesta hacer un breve /reload en estos casos poco frecuentes, puedes usar esta opción",
  esMX = "Si no te molesta hacer un breve /reload en estos casos poco frecuentes, puedes usar esta opción",
  itIT = "Se non ti disturba fare un breve /reload in questi casi rari, puoi usare questa opzione",
  ptBR = "Se não se importar em fazer um breve /reload nesses casos raros, pode usar esta opção",
  ruRU = "Если вас не беспокоит короткий /reload в этих редких случаях, можно использовать эту опцию",
  koKR = "이러한 드문 경우에 짧은 /reload이 괜찮다면 이 옵션을 사용할 수 있습니다",
  zhCN = "如果你不介意在这些少见情况下执行一次简短的 /reload，就可以使用此选项",
  zhTW = "如果你不介意在這些少見情況下執行一次簡短的 /reload，就可以使用此選項",
}

ns.LOCALE_SUPPRESS_ERRORS_NAME = { -- RetailOptions.lua
  enUS = "Suppress Errors",
  deDE = "Fehler unterdrücken",
  frFR = "Supprimer les erreurs",
  esES = "Suprimir errores",
  esMX = "Suprimir errores",
  itIT = "Sopprimi errori",
  ptBR = "Suprimir erros",
  ruRU = "Подавление ошибок",
  koKR = "오류 억제",
  zhCN = "抑制错误",
  zhTW = "抑制錯誤",
}

ns.LOCALE_ERRORS_CURSEFORGE = { -- RetailOptions.lua
  deDE = [[

Falls ihr irgendwelche Fehler findet, die von MapNotes ausgehen, und ihr sie auf „www.Curseforge.com/wow/addons/mapnotes“ meldet, dann füllt ein Fehlerprotokoll aus, damit man an diesen Fehler gezielt und auch schnell arbeiten kann.


Eine allgemeine Nachricht im Chat innerhalb der Kommentarsektion ist dazu selten wirklich hilfreich.


Dieses Fehlerprotokoll wird automatisch erstellt, wenn ihr unter „www.Curseforge.com/wow/addons/mapnotes“ auf „Probleme“ klickt und ein neues Problem eröffnet (www.Curseforge.com/wow/addons/mapnotes/issues/create).


Da die Fehlersuche ohne wirkliche Hinweise oder zusätzliche Informationen der Spieler für den Addon-Entwickler oft sehr langwierig und komplex sein kann, ist jede zusätzliche Information immer hilfreich, um Fehler schnell zu finden und zu beheben.
  

  Vielen lieben Dank


                    BadBoyBarny
]],

  enUS = [[
If you find any errors originating from MapNotes, and you report them on “www.Curseforge.com/wow/addons/mapnotes”, please fill out a bug report so that the error can be addressed in a targeted and speedy manner.


A general message in chat within the comment section is rarely truly helpful.


This bug report is created automatically when you click “Issues” under “www.Curseforge.com/wow/addons/mapnotes” and open a new issue (www.Curseforge.com/wow/addons/mapnotes/issues/create).


Since debugging without real hints or additional information from the players can often be very time-consuming and complex for the addon developer, any extra information is always helpful in identifying and fixing bugs quickly.


  Many thanks


                    BadBoyBarny
]],

  frFR = [[
Si vous trouvez des erreurs provenant de MapNotes et que vous les signalez sur « www.Curseforge.com/wow/addons/mapnotes », merci de remplir un rapport de bug afin que l’erreur puisse être traitée de façon ciblée et rapide.


Un message général dans le chat, dans la section des commentaires, est rarement vraiment utile.


Ce rapport de bug est créé automatiquement lorsque vous cliquez sur « Issues » sous « www.Curseforge.com/wow/addons/mapnotes » et ouvrez un nouvel incident (www.Curseforge.com/wow/addons/mapnotes/issues/create).


Étant donné que le débogage sans véritables indices ou informations supplémentaires des joueurs peut être très long et complexe pour le développeur de l’addon, toute information supplémentaire est toujours utile pour identifier et corriger les bogues rapidement.


  Un grand merci


                    BadBoyBarny
]],

  itIT = [[
Se trovate degli errori che provengono da MapNotes e li segnalate su “www.Curseforge.com/wow/addons/mapnotes”, compilate un report di bug in modo che l’errore possa essere affrontato in modo mirato e rapido.


Un messaggio generico nella chat, nella sezione dei commenti, è raramente veramente utile.


Questo report di bug viene creato automaticamente quando cliccate su “Issues” sotto “www.Curseforge.com/wow/addons/mapnotes” e aprite una nuova segnalazione (www.Curseforge.com/wow/addons/mapnotes/issues/create).


Poiché il debug senza veri indizi o informazioni aggiuntive dai giocatori può essere spesso molto lungo e complesso per lo sviluppatore dell’addon, qualsiasi informazione aggiuntiva è sempre utile per identificare e correggere i bug rapidamente.


  Molte grazie


                    BadBoyBarny
]],

  esES = [[
Si encuentran errores que provienen de MapNotes y los informan en “www.Curseforge.com/wow/addons/mapnotes”, por favor completen un informe de error para que el fallo pueda ser tratado de manera focalizada y rápida.


Un mensaje general en el chat dentro de la sección de comentarios rara vez es realmente útil.


Este informe de error se crea automáticamente cuando hacen clic en “Issues” bajo “www.Curseforge.com/wow/addons/mapnotes” y abren un nuevo problema (www.Curseforge.com/wow/addons/mapnotes/issues/create).


Dado que la depuración sin pistas reales o información adicional de los jugadores puede ser muy prolongada y compleja para el desarrollador del addon, cualquier información adicional siempre es útil para identificar y corregir errores rápidamente.
  

  Muchas gracias


                    BadBoyBarny
]],

  esMX = [[
Si encuentran errores que provienen de MapNotes y los reportan en “www.Curseforge.com/wow/addons/mapnotes”, por favor llenen un reporte de error para que el fallo pueda ser atendido de manera puntual y rápida.


Un mensaje general en el chat dentro de la sección de comentarios rara vez resulta realmente útil.


Este reporte de error se genera automáticamente cuando hacen clic en “Issues” bajo “www.Curseforge.com/wow/addons/mapnotes” y abren un nuevo problema (www.Curseforge.com/wow/addons/mapnotes/issues/create).


Dado que la depuración sin pistas reales o información adicional de los jugadores puede resultar muy larga y compleja para el desarrollador del addon, cualquier información adicional siempre es útil para identificar y corregir los errores rápidamente.
  

  Muchas gracias


                    BadBoyBarny
]],

  ptBR = [[
Se você encontrar qualquer erro proveniente do MapNotes e relatá-lo em “www.Curseforge.com/wow/addons/mapnotes”, por favor preencha um relatório de bug para que o erro possa ser tratado de forma direcionada e rápida.


Uma mensagem geral no chat, dentro da seção de comentários, raramente é realmente útil.


Este relatório de bug é criado automaticamente quando você clica em “Issues” sob “www.Curseforge.com/wow/addons/mapnotes” e abre um novo problema (www.Curseforge.com/wow/addons/mapnotes/issues/create).


Como depurar sem pistas reais ou informações adicionais dos jogadores pode ser muitas vezes muito demorado e complexo para o desenvolvedor do addon, qualquer informação extra é sempre útil para identificar e corrigir bugs rapidamente.


  Muito obrigado


                    BadBoyBarny
]],

  ruRU = [[
Если вы обнаружите какие-либо ошибки, исходящие из MapNotes, и сообщите о них на «www.Curseforge.com/wow/addons/mapnotes», пожалуйста, заполните отчёт об ошибке, чтобы её можно было исправить целенаправленно и оперативно.


Общий комментарий в чате в разделе комментариев редко бывает действительно полезен.


Этот отчёт об ошибке создаётся автоматически, когда вы нажимаете «Issues» на «www.Curseforge.com/wow/addons/mapnotes» и открываете новую задачу (www.Curseforge.com/wow/addons/mapnotes/issues/create).


Поскольку отладка без реальных подсказок или дополнительной информации от игроков часто оказывается очень трудоёмкой и сложной для разработчика аддона, любая дополнительная информация всегда полезна для быстрого обнаружения и исправления ошибок.
  

  Большое спасибо


                    BadBoyBarny
]],

  zhCN = [[
如果你发现任何源自 MapNotes 的错误，并在 “www.Curseforge.com/wow/addons/mapnotes” 上报告，请填写错误报告，以便该错误能够被有针对性和快速地处理。


在评论区的聊天中发布一条通用消息很少真正有帮助。


当你在 “www.Curseforge.com/wow/addons/mapnotes” 下点击“问题”（Issues）并创建一个新问题 (www.Curseforge.com/wow/addons/mapnotes/issues/create) 时，将自动生成此错误报告。


由于没有真实提示或玩家提供的额外信息时调试通常对插件开发者而言非常耗时且复杂，任何额外信息始终有助于快速识别和修复错误。


  万分感谢


                    BadBoyBarny
]],

  zhTW = [[
如果你發現任何來自 MapNotes 的錯誤，並在 “www.Curseforge.com/wow/addons/mapnotes” 上回報，請填寫錯誤報告，以便錯誤能被有針對性且快速地處理。


在評論區聊天中發送一條通用訊息很少真正有用。


當你在 “www.Curseforge.com/wow/addons/mapnotes” 下點擊 “Issues”（問題）並創建新問題 (www.Curseforge.com/wow/addons/mapnotes/issues/create) 時，會自動生成此錯誤報告。


由於在沒有實際提示或玩家提供額外資訊時進行除錯，對插件開發者而言通常非常耗時且複雜，任何額外資訊始終有助於快速識別並修復錯誤。


  非常感謝


                    BadBoyBarny
]],

  koKR = [[
MapNotes에서 발생하는 오류를 발견하여 “www.Curseforge.com/wow/addons/mapnotes” 에 보고할 경우, 오류를 보다 정확하고 신속하게 처리할 수 있도록 버그 리포트를 작성해 주세요.


댓글 섹션 내 채팅에 일반적인 메시지를 남기는 것은 거의 도움이 되지 않습니다.


이 버그 리포트는 “www.Curseforge.com/wow/addons/mapnotes” 아래의 “Issues” 항목을 클릭하고 새 문제를 열면 자동으로 생성됩니다 (www.Curseforge.com/wow/addons/mapnotes/issues/create).


플레이어로부터의 실질적인 단서나 추가 정보 없이 디버깅하는 것은 애드온 개발자에게 매우 시간 소모적이고 복잡할 수 있으므로, 추가 정보는 항상 오류를 신속하게 파악하고 수정하는 데 유용합니다.


  진심으로 감사드립니다


                    BadBoyBarny
]],
}

ns.LOCALE_COMBAT_LOCKED = { -- RetailErrorMessage.lua
  enUS = "> Map switching is blocked during combat ! <",
  deDE = "> Kartenwechsel im Kampf blockiert ! <",
  frFR = "> Changement de carte bloqué en combat ! <",
  esES = "> Cambio de mapa bloqueado en combate ! <",
  esMX = "> Cambio de mapa bloqueado en combate ! <",
  itIT = "> Cambio mappa bloccato in combattimento ! <",
  ptBR = "> Mudança de mapa bloqueada em combate ! <",
  ruRU = "> Смена карты заблокирована в бою ! <",
  koKR = "> 전투 중 지도 전환이 차단되었습니다 ! <",
  zhCN = "> 战斗中地图切换已被阻止 ! <",
  zhTW = "> 戰鬥中地圖切換已被阻止 ! <",
}

ns.LOCALE_AFTER_COMBAT_ALLOWED = { -- RetailErrorMessage.lua
  enUS = "> Map switching blocked in combat ! <\n> will be executed after combat <",
  deDE = "> Kartenwechsel im Kampf blockiert ! <\n> Dieser wird nach dem Kampf nachgeholt <",
  frFR = "> Changement de carte bloqué en combat ! <\n> il sera effectué après le combat <",
  esES = "> Cambio de mapa bloqueado en combate ! <\n> se realizará después del combate <",
  esMX = "> Cambio de mapa bloqueado en combate ! <\n> se realizará después del combate <",
  itIT = "> Cambio mappa bloccato in combattimento ! <\n> verrà eseguito dopo il combattimento <",
  ptBR = "> Mudança de mapa bloqueada em combate ! <\n> será executada após o combate <",
  ruRU = "> Смена карты заблокирована в бою ! <\n> будет выполнена после боя <",
  koKR = "> 전투 중 지도 전환이 차단됨 ! <\n> 전투 후에 실행됩니다 <",
  zhCN = "> 战斗中地图切换已被阻止 ! <\n> 战斗结束后将执行 <",
  zhTW = "> 戰鬥中地圖切換已被阻止 ! <\n> 戰鬥結束後將執行 <",
}

ns.LOCALE_OPEN_AFTER_COMBAT = { -- RetailErrorMessage.lua
  enUS = "> Map switching executed after combat <",
  deDE = "> Kartenwechsel nachgeholt <",
  frFR = "> Changement de carte effectué après le combat <",
  esES = "> Cambio de mapa realizado después del combate <",
  esMX = "> Cambio de mapa realizado después de la batalla <",
  itIT = "> Cambio mappa eseguito dopo il combattimento <",
  ptBR = "> Mudança de mapa executada após o combate <",
  ruRU = "> Смена карты выполнена после боя <",
  koKR = "> 전투 후 지도 전환이 실행되었습니다 <",
  zhCN = "> 战斗结束后已执行地图切换 <",
  zhTW = "> 戰鬥結束後已執行地圖切換 <",
}

ns.LOCALE_BLOCKPANEL_MSG = { -- RetailErrorMessage.lua
  deDE = [[Bitte einmal die Benutzeroberfläche erneuern, um die Funktion an Blizzard zurückzugeben.]],
  enUS = [[Please reload the UI to return this function to the Blizzard UI.]],
  frFR = [[Veuillez recharger l’interface afin de restituer cette fonction à l’interface de Blizzard.]],
  itIT = [[Ricarica l’interfaccia per restituire questa funzione all’interfaccia di Blizzard.]],
  esES = [[Recarga la interfaz para devolver esta función a la interfaz de Blizzard.]],
  esMX = [[Recarga la interfaz para devolver esta función a la interfaz de Blizzard.]],
  ptBR = [[Recarregue a interface para devolver esta função à interface da Blizzard.]],
  ruRU = [[Пожалуйста, перезагрузите интерфейс, чтобы вернуть эту функцию интерфейсу Blizzard.]],
  koKR = [[이 기능을 블리자드 UI로 되돌리려면 UI를 다시 불러와 주세요.]],
  zhCN = [[请重新加载界面，以将此功能交还给暴雪界面。]],
  zhTW = [[請重新載入介面，以將此功能交還給暴雪介面。]],
}

ns.bugSackTriggers = { -- RetailErrorMessage.lua
  deDE = "bugsack: du hast einen fehler entdeckt",
  enUS = "bugsack: you have found an error",
  enGB = "bugsack: you have found an error",
  frFR = "bugsack: vous avez trouvé une erreur",
  esES = "bugsack: ¡ha ocurrido un error!",
  esMX = "bugsack: ¡ha ocurrido un error!",
  itIT = "bugsack: hai trovato un bug",
  ptBR = "bugsack: você encontrou um erro",
  ruRU = "bugsack: у тебя муха в супе",
  zhCN = "bugsack: 这里有一个恶心的错误",
  zhTW = "bugsack: 在你的湯裡有一隻臭蟲啊！",
  koKR = "bugsack: 수프에 벌레가 있습니다",
}

ns.LOCALE_TARGETING = { -- RetailNpc.lua
  enUS = [[target]],
  deDE = [[anvisieren]],
  frFR = [[cibler]],
  esES = [[apuntar]],
  esMX = [[apuntar]],
  itIT = [[mirare]],
  ptBR = [[mirar]],
  ruRU = [[нацелить]],
  koKR = [[대상 지정]],
  zhCN = [[选定目标]],
  zhTW = [[選定目標]],
}

ns.LOCALE_CACHING = { -- RetailNpc.lua
  enUS = [[update npc name database]],
  deDE = [[Aktualisiere NPC-Namen Datenbank]],
  frFR = [[Mise à jour de la base de données des noms de PNJ]],
  esES = [[Actualizando base de datos de nombres de PNJ]],
  esMX = [[Actualizando base de datos de nombres de PNJ]],
  itIT = [[Aggiornamento del database dei nomi degli NPC]],
  ptBR = [[Atualizando banco de dados de nomes de NPC]],
  ruRU = [[Обновление базы данных имён NPC]],
  koKR = [[NPC 이름 데이터베이스 업데이트 중]],
  zhCN = [[正在更新NPC名称数据库]],
  zhTW = [[正在更新NPC名稱資料庫]],
}

ns.LOCALE_RETRY = { -- RetailNpc.lua
  enUS = [[Database is being updated, please wait]],
  deDE = [[Datenbank wird aktualisiert, bitte warten]],
  frFR = [[Mise à jour de la base de données, veuillez patienter]],
  esES = [[La base de datos se está actualizando, por favor espere]],
  esMX = [[La base de datos se está actualizando, por favor espere]],
  itIT = [[Il database è in fase di aggiornamento, attendere prego]],
  ptBR = [[O banco de dados está sendo atualizado, por favor aguarde]],
  ruRU = [[База данных обновляется, пожалуйста, подождите]],
  koKR = [[데이터베이스를 업데이트하는 중입니다. 잠시만 기다려주세요]],
  zhCN = [[数据库正在更新，请稍候]],
  zhTW = [[資料庫正在更新，請稍候]],
}

ns.LOCALE_RETRY_DONE = { -- RetailNpc.lua
  enUS = [[Database update completed]],
  deDE = [[Datenbankaktualisierung abgeschlossen]],
  frFR = [[Mise à jour de la base de données terminée]],
  esES = [[Actualización de la base de datos completada]],
  esMX = [[Actualización de la base de datos completada]],
  itIT = [[Aggiornamento del database completato]],
  ptBR = [[Atualização do banco de dados concluída]],
  ruRU = [[Обновление базы данных завершено]],
  koKR = [[데이터베이스 업데이트 완료]],
  zhCN = [[数据库更新完成]],
  zhTW = [[資料庫更新完成]],
}

ns.LOCALE_CACHING_DONE = { -- RetailNpc.lua
  enUS = [[Database check completed]],
  deDE = [[Datenbanküberprüfung abgeschlossen]],
  frFR = [[Vérification de la base de données terminée]],
  esES = [[Comprobación de la base de datos completada]],
  esMX = [[Comprobación de la base de datos completada]],
  itIT = [[Verifica del database completata]],
  ptBR = [[Verificação do banco de dados concluída]],
  ruRU = [[Проверка базы данных завершена]],
  koKR = [[데이터베이스 확인 완료]],
  zhCN = [[数据库检查完成]],
  zhTW = [[資料庫檢查完成]],
}

ns.LOCALE_FOUND_MISSING = { -- RetailNpc.lua
  enUS = "%s %s - %d found, %d missing",
  deDE = "%s %s - %d gefunden, %d fehlen",
  frFR = "%s %s - %d trouvés, %d manquants",
  esES = "%s %s - %d encontrados, %d faltan",
  esMX = "%s %s - %d encontrados, %d faltan",
  itIT = "%s %s - %d trovati, %d mancanti",
  ptBR = "%s %s - %d encontrados, %d faltando",
  ruRU = "%s %s - %d найдено, %d отсутствуют",
  koKR = "%s %s - %d 발견됨, %d 누락됨",
  zhCN = "%s %s - 已找到 %d 个，缺少 %d 个",
  zhTW = "%s %s - 已找到 %d 個，缺少 %d 個",
}

ns.reset_Character_SavedVariables_Text = {
  deDE = "Löscht das aktuell benutzte MapNotes Profile und alle gespeicherten MapNotes Daten dieses Profils!\n\nDanach wird das Interface des Spiels neu geladen",
  enUS = "Deletes the currently selected MapNotes profile and all data belonging to it!\n\nAfterwards, the game's interface will be reloaded",
  frFR = "Supprime le profil MapNotes actuellement sélectionné ainsi que toutes ses données !\n\nEnsuite, l’interface du jeu sera rechargée",
  esES = "Elimina el perfil de MapNotes seleccionado actualmente y todos sus datos.\n\nDespués de esto, se recargará la interfaz del juego",
  esMX = "Elimina el perfil de MapNotes seleccionado actualmente y todos sus datos.\n\nDespués de esto, se recargará la interfaz del juego",
  itIT = "Elimina il profilo MapNotes attualmente selezionato e tutti i dati ad esso associati!\n\nSuccessivamente verrà ricaricata l’interfaccia di gioco",
  ptBR = "Exclui o perfil do MapNotes atualmente selecionado e todos os dados associados!\n\nApós isso, a interface do jogo será recarregada",
  ruRU = "Удаляет текущий выбранный профиль MapNotes и все связанные с ним данные!\n\nПосле этого интерфейс игры будет перезагружен",
  zhCN = "删除当前选定的 MapNotes 配置档及其所有数据！\n\n之后将重新载入游戏界面",
  zhTW = "刪除目前所選的 MapNotes 設定檔及其所有資料！\n\n之後將重新載入遊戲介面",
  koKR = "현재 선택된 MapNotes 프로필과 그에 속한 모든 데이터를 삭제합니다!\n\n이후 게임 인터페이스가 다시 불러와집니다",
}

ns.keep_Only_Current_Character_SavedVariables_Text = {
  deDE = "Behalte das aktuell benutzte MapNotes Profil, aber löscht alle anderen MapNotes Profile und die gespeicherten MapNotes Daten der Profile!\n\nDanach wird das Interface des Spiels neu geladen",
  enUS = "Keeps the currently used MapNotes profile but deletes all other profiles and all stored MapNotes data belonging to them.\n\nAfterwards, the game's interface will be reloaded",
  frFR = "Conserve le profil MapNotes actuellement utilisé mais supprime tous les autres profils ainsi que toutes les données MapNotes qui leur appartiennent.\n\nEnsuite, l’interface du jeu sera rechargée",
  esES = "Conserva el perfil actual de MapNotes, pero elimina todos los demás perfiles y todos los datos de MapNotes asociados a ellos.\n\nDespués de esto, se recargará la interfaz del juego",
  esMX = "Conserva el perfil actual de MapNotes, pero elimina todos los demás perfiles y todos los datos de MapNotes asociados a ellos.\n\nDespués de esto, se recargará la interfaz del juego",
  itIT = "Mantiene il profilo MapNotes attualmente utilizzato ma elimina tutti gli altri profili e tutti i dati di MapNotes ad essi associati.\n\nSuccessivamente verrà ricaricata l’interfaccia di gioco",
  ptBR = "Mantém o perfil do MapNotes atualmente usado, mas exclui todos os outros perfis e todos os dados do MapNotes associados a eles.\n\nApós isso, a interface do jogo será recarregada",
  ruRU = "Сохраняет используемый в данный момент профиль MapNotes, но удаляет все остальные профили и все связанные с ними данные MapNotes.\n\nПосле этого интерфейс игры будет перезагружен",
  zhCN = "仅保留当前使用的 MapNotes 配置档，但会删除所有其他配置档及其所有关联的 MapNotes 数据。\n\n之后将重新载入游戏界面",
  zhTW = "僅保留目前使用的 MapNotes 設定檔，但會刪除所有其他設定檔及其所有相關的 MapNotes 資料。\n\n之後將重新載入遊戲介面",
  koKR = "현재 사용 중인 MapNotes 프로필만 유지하고 다른 모든 프로필과 관련된 모든 MapNotes 데이터를 삭제합니다.\n\n이후 게임 인터페이스가 다시 불러와집니다",
}

ns.reset_ALL_SavedVariables_Text = {
  deDE = "Löscht alle vorhandene MapNotes Profile inklusive des aktuell benutzen MapNotes Profiles und löscht alle gespeicherten MapNotes Daten!\n\nDanach wird das Interface des Spiels neu geladen",
  enUS = "Deletes all existing MapNotes profiles, including the currently used one, and removes all stored MapNotes data!\n\nAfterwards, the game's interface will be reloaded",
  frFR = "Supprime tous les profils MapNotes existants, y compris celui actuellement utilisé, ainsi que toutes les données MapNotes enregistrées !\n\nEnsuite, l’interface du jeu sera rechargée",
  esES = "Elimina todos los perfiles existentes de MapNotes, incluido el que se está usando actualmente, y borra todos los datos almacenados de MapNotes.\n\nDespués de esto, se recargará la interfaz del juego",
  esMX = "Elimina todos los perfiles existentes de MapNotes, incluido el que se está usando actualmente, y borra todos los datos almacenados de MapNotes.\n\nDespués de esto, se recargará la interfaz del juego",
  itIT = "Elimina tutti i profili MapNotes esistenti, incluso quello attualmente in uso, e rimuove tutti i dati MapNotes memorizzati!\n\nSuccessivamente verrà ricaricata l’interfaccia di gioco",
  ptBR = "Exclui todos os perfis existentes do MapNotes, incluindo o que está sendo usado atualmente, e remove todos os dados do MapNotes armazenados!\n\nApós isso, a interface do jogo será recarregada",
  ruRU = "Удаляет все существующие профили MapNotes, включая тот, который используется в данный момент, и удаляет все сохранённые данные MapNotes!\n\nПосле этого интерфейс игры будет перезагружен",
  zhCN = "删除所有现有的 MapNotes 配置档，包括当前使用的配置，并清除所有 MapNotes 存储的数据！\n\n之后将重新载入游戏界面",
  zhTW = "刪除所有現有的 MapNotes 設定檔，包括目前使用的設定檔，並清除所有 MapNotes 儲存的資料！\n\n之後將重新載入遊戲介面",
  koKR = "현재 사용 중인 프로필을 포함하여 모든 기존 MapNotes 프로필과 저장된 모든 MapNotes 데이터를 삭제합니다!\n\n이후 게임 인터페이스가 다시 불러와집니다",
}

ns.reset_header_1 = { -- Options.lua
  deDE = "Aktuelles MapNotes Profil",
  enUS = "Current MapNotes profile",
  frFR = "Profil MapNotes actuel",
  esES = "Perfil actual de MapNotes",
  esMX = "Perfil actual de MapNotes",
  itIT = "Profilo MapNotes attuale",
  ptBR = "Perfil atual do MapNotes",
  ruRU = "Текущий профиль MapNotes",
  zhCN = "当前的 MapNotes 配置档",
  zhTW = "目前的 MapNotes 設定檔",
  koKR = "현재 MapNotes 프로필",
}

ns.reset_header_2 = {
  deDE = "Alle MapNotes Profile",
  enUS = "All MapNotes profiles",
  frFR = "Tous les profils MapNotes",
  esES = "Todos los perfiles de MapNotes",
  esMX = "Todos los perfiles de MapNotes",
  itIT = "Tutti i profili MapNotes",
  ptBR = "Todos os perfis do MapNotes",
  ruRU = "Все профили MapNotes",
  zhCN = "所有的 MapNotes 配置档",
  zhTW = "所有的 MapNotes 設定檔",
  koKR = "모든 MapNotes 프로필",
}

ns.reset_name_1 = {
  deDE = "Lösche aktuelles MapNotes Profil",
  enUS = "Delete current MapNotes profile",
  frFR = "Supprimer le profil MapNotes actuel",
  esES = "Eliminar el perfil actual de MapNotes",
  esMX = "Eliminar el perfil actual de MapNotes",
  itIT = "Elimina il profilo MapNotes attuale",
  ptBR = "Excluir o perfil atual do MapNotes",
  ruRU = "Удалить текущий профиль MapNotes",
  zhCN = "删除当前的 MapNotes 配置档",
  zhTW = "刪除目前的 MapNotes 設定檔",
  koKR = "현재 MapNotes 프로필 삭제",
}

ns.reset_name_2 = {
  deDE = "Behalte aktuelles MapNotes Profil aber …",
  enUS = "Keep current MapNotes profile but …",
  frFR = "Conserver le profil MapNotes actuel mais …",
  esES = "Conservar el perfil actual de MapNotes pero …",
  esMX = "Conservar el perfil actual de MapNotes pero …",
  itIT = "Mantieni il profilo MapNotes attuale ma …",
  ptBR = "Manter o perfil atual do MapNotes mas …",
  ruRU = "Сохранить текущий профиль MapNotes, но …",
  zhCN = "保留当前的 MapNotes 配置档，但…",
  zhTW = "保留目前的 MapNotes 設定檔，但…",
  koKR = "현재 MapNotes 프로필을 유지하지만 …",
}

ns.reset_name_3 = {
  deDE = "Lösche alle MapNotes Profile",
  enUS = "Delete all MapNotes profiles",
  frFR = "Supprimer tous les profils MapNotes",
  esES = "Eliminar todos los perfiles de MapNotes",
  esMX = "Eliminar todos los perfiles de MapNotes",
  itIT = "Elimina tutti i profili MapNotes",
  ptBR = "Excluir todos os perfis do MapNotes",
  ruRU = "Удалить все профили MapNotes",
  zhCN = "删除所有的 MapNotes 配置档",
  zhTW = "刪除所有的 MapNotes 設定檔",
  koKR = "모든 MapNotes 프로필 삭제",
}