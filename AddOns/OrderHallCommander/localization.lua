local me,ns=...
local lang=GetLocale()
local l=LibStub("AceLocale-3.0")
local L=l:NewLocale(me,"enUS",true,true)
L["Always counter increased resource cost"] = true
L["Always counter increased time"] = true
L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = true
L["Always counter no bonus loot threat"] = true
L["Better parties available in next future"] = true
L["Building Final report"] = true
L["Capped %1$s. Spend at least %2$d of them"] = true
L["Changes the sort order of missions in Mission panel"] = true
L["Combat ally is proposed for missions so you can consider unassigning him"] = true
L["Complete all missions without confirmation"] = true
L["Configuration for mission party builder"] = true
L["Dont kill Troops"] = true
L["Duration reduced"] = true
L["Duration Time"] = true
L["Expiration Time"] = true
L["Favours leveling follower for xp missions"] = true
L["General"] = true
L["Global approx. xp reward"] = true
L["HallComander Quick Mission Completion"] = true
L[ [=[If you %s,  you will lose them
Click on %s to abort]=] ] = [=[If you %s, you will lose them
Click on %s to abort]=]
L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = true
L["Keep cost low"] = true
L["Keep extra bonus"] = true
L["Keep time short"] = true
L["Keep time VERY short"] = true
L["Level"] = true
L["Make Order Hall Mission Panel movable"] = true
L["Maximize xp gain"] = true
L["Missions"] = true
L["No follower gained xp"] = true
L["Nothing to report"] = true
L["Notifies you when you have troops ready to be collected"] = true
L["Only accept missions with time improved"] = true
L[ [=[OrderHallCommander overrides GarrisonCommander for Order Hall Management.
 You can revert to GarrisonCommander simpy disabling OrderhallCommander]=] ] = true
L["Original method"] = true
L["Position is not saved on logout"] = true
L["Resurrect troops effect"] = true
L["Reward type"] = true
L["Show/hide OrderHallCommander mission menu"] = true
L["Sort missions by:"] = true
L["Success Chance"] = true
L["Troop ready alert"] = true
L["Upgrading to |cff00ff00%d|r"] = true
L["Use combat ally"] = true
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = true
L=l:NewLocale(me,"ptBR")
if (L) then
L["Always counter increased resource cost"] = "Sempre contra o aumento do custo de recursos"
L["Always counter increased time"] = "Sempre contra o aumento do tempo"
L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = "Sempre counter kill tropas (ignorado se podemos apenas usar tropas com apenas 1 durabilidade à esquerda)"
L["Better parties available in next future"] = "Festas melhores disponíveis no próximo futuro"
L["Building Final report"] = "Relatório final do edifício"
L["Capped %1$s. Spend at least %2$d of them"] = "Capped% 1 $ s. Gaste pelo menos% 2 $ d deles"
L["Changes the sort order of missions in Mission panel"] = "Altera a ordem de classificação das missões no painel da Missão"
L["Complete all missions without confirmation"] = "Complete todas as missões sem confirmação"
L["Configuration for mission party builder"] = "Configuração para o construtor de parte da missão"
L["Dont kill Troops"] = "Não mate tropas"
L["Duration reduced"] = "Duração reduzida"
L["Duration Time"] = "Tempo de duração"
L["Expiration Time"] = "Data de validade"
L["Favours leveling follower for xp missions"] = "Favors leveling follower para missões xp"
L["General"] = "Geral"
L["Global approx. xp reward"] = "Global aprox. Recompensa xp"
L["HallComander Quick Mission Completion"] = "Conclusão Rápida da Missão HallComander"
L[ [=[If you %s,  you will lose them
Click on %s to abort]=] ] = "Se você% s, você os perderá  nClique em% s para abortar"
L["Keep cost low"] = "Mantenha o custo baixo"
L["Keep time short"] = "Mantenha o tempo curto"
L["Keep time VERY short"] = "Mantenha o tempo MUITO curto"
L["Level"] = "Nível"
L["Make Order Hall Mission Panel movable"] = "Faça a encomenda Hall Missão Painel móvel"
L["Maximize xp gain"] = "Maximize o ganho de xp"
L["Missions"] = "Missões"
L["No follower gained xp"] = "Nenhum seguidor ganhou xp"
L["Nothing to report"] = "Nada a declarar"
L["Notifies you when you have troops ready to be collected"] = "Notifica você quando você tem tropas prontas para serem coletadas"
L["Only accept missions with time improved"] = "Aceitar apenas missões com o tempo melhorado"
L[ [=[OrderHallCommander overrides GarrisonCommander for Order Hall Management.
 You can revert to GarrisonCommander simpy disabling OrderhallCommander]=] ] = "OrderHallCommander substitui o GarrisonCommander para a Gestão de Hall de Ordem.  N Você pode reverter para GarrisonCommander simplesmente desativando o OrderhallCommander"
L["Original method"] = "Método original"
L["Position is not saved on logout"] = "A posição não é salva no logout"
L["Resurrect troops effect"] = "Resurrect efeito tropas"
L["Reward type"] = "Tipo de recompensa"
L["Show/hide OrderHallCommander mission menu"] = "Mostrar / ocultar o menu da missão OrderHallCommander"
L["Sort missions by:"] = "Classifique missões por:"
L["Success Chance"] = "Chance de sucesso"
L["Troop ready alert"] = "Alerta de tropas"
L["Upgrading to |cff00ff00%d|r"] = "Atualizando para | cff00ff00% d | r"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "Você está desperdiçando | cffff0000% d | cffffd200 point (s) !!!"
return
end
L=l:NewLocale(me,"frFR")
if (L) then
L["Always counter increased resource cost"] = "Toujours contrer les coûts accrus des ressources"
L["Always counter increased time"] = "Toujours contrer le temps accru"
L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = "Toujours contre tuer les troupes (ignoré si nous ne pouvons utiliser des troupes avec une seule durabilité à gauche)"
L["Better parties available in next future"] = "De meilleures parties disponibles au prochain avenir"
L["Building Final report"] = "Rapport final du bâtiment"
L["Capped %1$s. Spend at least %2$d of them"] = "Plafonné% 1 $ s. Dépenser au moins% 2 $ d d'entre eux"
L["Changes the sort order of missions in Mission panel"] = "Modifie l'ordre de tri des missions dans le panneau Mission"
L["Complete all missions without confirmation"] = "Terminer toutes les missions sans confirmation"
L["Configuration for mission party builder"] = "Configuration pour le constructeur de mission"
L["Dont kill Troops"] = "Ne tuez pas les troupes"
L["Duration reduced"] = "Durée réduite"
L["Duration Time"] = "Durée"
L["Expiration Time"] = "Date d'expiration"
L["Favours leveling follower for xp missions"] = "Favors level follower pour les missions xp"
L["General"] = "Général"
L["Global approx. xp reward"] = "Global env. Xp récompense"
L["HallComander Quick Mission Completion"] = "Achèvement rapide de mission HallComander"
L[ [=[If you %s,  you will lose them
Click on %s to abort]=] ] = "Si vous% s, vous les perdrez  nCliquez sur% s pour annuler"
L["Keep cost low"] = "Garder le coût bas"
L["Keep time short"] = "Garde le temps court"
L["Keep time VERY short"] = "Gardez le temps très court"
L["Level"] = "Niveau"
L["Make Order Hall Mission Panel movable"] = "Commande Hall Mission Panneau mobile"
L["Maximize xp gain"] = "Maximiser le gain de xp"
L["Missions"] = true
L["No follower gained xp"] = "Aucun adepte n'a gagné xp"
L["Nothing to report"] = "Rien à signaler"
L["Notifies you when you have troops ready to be collected"] = "Vous avertit lorsque vous avez des troupes prêtes à être recueillies"
L["Only accept missions with time improved"] = "N'acceptez que les missions avec le temps améliorées"
L[ [=[OrderHallCommander overrides GarrisonCommander for Order Hall Management.
 You can revert to GarrisonCommander simpy disabling OrderhallCommander]=] ] = "OrderHallCommander annule GarrisonCommander pour la gestion des commandes Hall.  N Vous pouvez revenir à GarrisonCommander simpy désactiver OrderhallCommander"
L["Original method"] = "Méthode originale"
L["Position is not saved on logout"] = "La position n'est pas enregistrée lors de la déconnexion"
L["Resurrect troops effect"] = "Effet Résurrection des troupes"
L["Reward type"] = "Type de récompense"
L["Show/hide OrderHallCommander mission menu"] = "Afficher / masquer le menu de mission OrderHallCommander"
L["Sort missions by:"] = "Missions de tri par:"
L["Success Chance"] = "Chance de succès"
L["Troop ready alert"] = "Alerte prêt des troupes"
L["Upgrading to |cff00ff00%d|r"] = "Mise à niveau vers | cff00ff00% d | r"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "Vous perdez | cffff0000% d | cffffd200 point (s) !!!"
return
end
L=l:NewLocale(me,"deDE")
if (L) then
L["Always counter increased resource cost"] = "Immer erhöhte Ressourcenkosten kontern"
L["Always counter increased time"] = "Immer erhöhte Missionsdauer kontern"
L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = "Töten der Trupps immer kontern (dies wird ignoriert, falls nur Truppen mit 1 Haltbarkeit benutzt werden können)"
L["Always counter no bonus loot threat"] = "Kontert immer Bedrohungen, die Bonusbeute verhindern"
L["Better parties available in next future"] = "Bessere Gruppen sind in absehbarer Zeit verfügbar"
L["Building Final report"] = "Erstelle Abschlussbericht"
L["Capped %1$s. Spend at least %2$d of them"] = "Maximal %1$ s. Gib mindestens %2$d davon aus"
L["Changes the sort order of missions in Mission panel"] = "Verändert die Sortierreihenfolge der Missionen in der Missionsübersicht"
L["Combat ally is proposed for missions so you can consider unassigning him"] = "Der Kampfgefährte wird für Missionen vorgeschlagen, du kannst dann entscheiden, ob du ihn abziehen möchtest"
L["Complete all missions without confirmation"] = "Alle Missionen ohne Bestätigung abschließen"
L["Configuration for mission party builder"] = "Konfiguration des Gruppenerstellers für Missionen"
L["Dont kill Troops"] = "Trupps nicht töten"
L["Duration reduced"] = "Dauer reduziert"
L["Duration Time"] = "Dauer"
L["Expiration Time"] = "Ablaufzeit"
L["Favours leveling follower for xp missions"] = "Bevorzugt niedrigstufige Anhänger für EP-Missionen"
L["General"] = "Allgemein"
L["Global approx. xp reward"] = "Ca. Insgesamte EP-Belohnung"
L["HallComander Quick Mission Completion"] = "HallComander Schneller Missionsabschluss"
L[ [=[If you %s,  you will lose them
Click on %s to abort]=] ] = [=[Wenn du %s, wirst du sie verlieren.
Klicke auf %s, um abzubrechen]=]
L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = [=[Wenn du %s, wirst du sie verlieren.
Klicke auf %s, um abzubrechen]=]
L["Keep cost low"] = "Kosten niedrig halten"
L["Keep extra bonus"] = "Bonusbeute behalten"
L["Keep time short"] = "Zeit kurz halten"
L["Keep time VERY short"] = "Zeit SEHR kurz halten"
L["Level"] = "Stufe"
L["Make Order Hall Mission Panel movable"] = "Ordenshallen-Missionsfenster beweglich machen"
L["Maximize xp gain"] = "Erfahrungszunahme maximieren"
L["Missions"] = "Missionen"
L["No follower gained xp"] = "Kein Anhänger erhielt EP"
L["Nothing to report"] = "Nichts zu berichten"
L["Notifies you when you have troops ready to be collected"] = "Benachrichtigt, wenn Truppen bereit sind, gesammelt zu werden"
L["Only accept missions with time improved"] = "Nur Missionen mit verkürzter Dauer annehmen"
L[ [=[OrderHallCommander overrides GarrisonCommander for Order Hall Management.
 You can revert to GarrisonCommander simpy disabling OrderhallCommander]=] ] = "OrderHallCommander überschreibt GarrisonCommander für die Verwaltung der Ordenshalle. Sie können GarrisonCommander wiederherstellen, indem Sie OrderhallCommander deaktivieren"
L["Original method"] = "Ursprüngliche Methode"
L["Position is not saved on logout"] = "Die Position wird beim Ausloggen nicht gespeichert"
L["Resurrect troops effect"] = "Truppen wiederbeleben"
L["Reward type"] = "Belohnungsart"
L["Show/hide OrderHallCommander mission menu"] = "OrderHallCommander-Missionsmenü zeigen/ausblenden"
L["Sort missions by:"] = "Sortieren nach:"
L["Success Chance"] = "Erfolgschance"
L["Troop ready alert"] = "Warnung Trupp bereit"
L["Upgrading to |cff00ff00%d|r"] = "Aktualisieren auf | cff00ff00% d | r"
L["Use combat ally"] = "Kampfgefährten verwenden"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "Sie verschwenden | cffff0000% d | cffffd200 Punkt (e) !!!"
return
end
L=l:NewLocale(me,"itIT")
if (L) then
L["Always counter increased resource cost"] = "Contrasta sempre incremento risorse"
L["Always counter increased time"] = "Contrasta sempre incremento durata"
L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = "Contrasta sempre morte milizie (ignorato tutte le milizie hanno solo una vita rimanente)"
L["Always counter no bonus loot threat"] = "Contrasta sempre il \"no bonus\""
L["Better parties available in next future"] = "Ci sono combinazioni migliori nel futuro"
L["Building Final report"] = "Sto preparando il rapporto finale"
L["Capped %1$s. Spend at least %2$d of them"] = "%1$s ha un limite. Spendine almeno %2%d"
L["Changes the sort order of missions in Mission panel"] = "Cambia l'ordine delle mission nel Pannello Missioni"
L["Combat ally is proposed for missions so you can consider unassigning him"] = "Viene proposto l'alleato, per poter valutare se rimuoverlo dalla missione di scorta"
L["Complete all missions without confirmation"] = "Completa tutte le missioni senza chiedere conferma"
L["Configuration for mission party builder"] = "Configurazioni per il generatore di gruppi"
L["Dont kill Troops"] = "Non uccidere le truppe"
L["Duration reduced"] = "Durata"
L["Duration Time"] = "Scadenza"
L["Expiration Time"] = "Scadenza"
L["Favours leveling follower for xp missions"] = "Preferisci i campioni che devono livellare"
L["General"] = "Generale"
L["Global approx. xp reward"] = "Approssimativi PE globali"
L["HallComander Quick Mission Completion"] = "OrderHallCommander Completamento rapido"
L["Keep cost low"] = "Mantieni il costo basso"
L["Keep extra bonus"] = "Ottieni il bonus aggiuntivo"
L["Keep time short"] = "Riduci la durata"
L["Keep time VERY short"] = "Riduci MOLTO la durata"
L["Level"] = "Livello"
L["Make Order Hall Mission Panel movable"] = "Rendi spostabile il pannello missioni"
L["Maximize xp gain"] = "Massimizza il guadagno di PE"
L["Missions"] = "Missioni"
L["No follower gained xp"] = "Nessun campione ha guaagnato PE"
L["Nothing to report"] = "Niente da segnalare"
L["Notifies you when you have troops ready to be collected"] = "Notificami quando ho truppe pronte per essere raccolte"
L["Only accept missions with time improved"] = "Accetta solo missioni con bonus durata ridotta"
L[ [=[OrderHallCommander overrides GarrisonCommander for Order Hall Management.
 You can revert to GarrisonCommander simpy disabling OrderhallCommander]=] ] = [=[OrderHallCommander sostituisce l'interfaccia di GarrisonComamnder per le missioni di classe
Disabilitalo se preferisci GarrisonCommander]=]
L["Position is not saved on logout"] = "La posizione non è salvata alla disconnessione"
L["Resurrect troops effect"] = "Resurrezione truppe possibile"
L["Reward type"] = "Tipo ricompensa"
L["Show/hide OrderHallCommander mission menu"] = "Mostra/ascondi il menu di missione di OrderHallCommander"
L["Troop ready alert"] = "Avviso truppe pronte"
L["Use combat ally"] = "Usa l'alleato"
return
end
L=l:NewLocale(me,"koKR")
if (L) then
L["Always counter increased resource cost"] = "자원 비용 증가 항상 대응"
L["Always counter increased time"] = "소요 시간 증가 항상 대응"
L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = "병력 죽이기 항상 대응 (활력이 1만 남은 병력만 있을 땐 무시)"
L["Always counter no bonus loot threat"] = "추가 전리품 획득 불가 항상 대응"
L["Better parties available in next future"] = "다음 시간 후엔 더 나은 파티가 가능합니다"
L["Building Final report"] = "최종 보고서 작성"
L["Capped %1$s. Spend at least %2$d of them"] = "%1$s 상한선에 도달했습니다. 최소 %2$d개를 소모하세요"
L["Changes the sort order of missions in Mission panel"] = "임무 창 내 임무의 정렬 방법을 변경합니다"
L["Combat ally is proposed for missions so you can consider unassigning him"] = "전투 동료가 임무에 제안되며 전투 동료 지정 해제를 해야 할 수 있습니다"
L["Complete all missions without confirmation"] = "확인 없이 모든 임무를 완료합니다"
L["Configuration for mission party builder"] = "임무 파티 구성 설정"
L["Dont kill Troops"] = "병력 죽이지 않기"
L["Duration reduced"] = "수행 시간 감소됨"
L["Duration Time"] = "수행 시간"
L["Expiration Time"] = "만료 시간"
L["Favours leveling follower for xp missions"] = "레벨 육성 중인 추종자를 경험치 임무에 우선 지정합니다"
L["General"] = "일반"
L["Global approx. xp reward"] = "전체 경험치 보상 추정치"
L["HallComander Quick Mission Completion"] = "HallCommander 빠른 임무 완료"
L[ [=[If you %s,  you will lose them
Click on %s to abort]=] ] = [=[만약 %s\1241이라면;라면;, 그들을 잃게 됩니다
취소하려면 %s\1241을;를; 클릭하세요]=]
L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = [=[만약 %s\1241이라면;라면;, 그들을 잃게 됩니다
취소하려면 %s\1241을;를; 클릭하세요]=]
L["Keep cost low"] = "비용 절감 유지"
L["Keep extra bonus"] = "추가 전리품 유지"
L["Keep time short"] = "시간 절약 유지"
L["Keep time VERY short"] = "시간 매우 절약 유지"
L["Level"] = "레벨"
L["Make Order Hall Mission Panel movable"] = "직업 전당 임무 창 이동 가능 설정"
L["Maximize xp gain"] = "경험치 획득 최대화"
L["Missions"] = "임무"
L["No follower gained xp"] = "경험치를 획득한 추종자 없음"
L["Nothing to report"] = "보고할 내용 없음"
L["Notifies you when you have troops ready to be collected"] = "병력을 회수할 준비가 되면 당신에게 알립니다"
L["Only accept missions with time improved"] = "소요 시간이 감소한 임무만 수락합니다"
L[ [=[OrderHallCommander overrides GarrisonCommander for Order Hall Management.
 You can revert to GarrisonCommander simpy disabling OrderhallCommander]=] ] = [=[OrderHallCommander는 직업 전당 관리를 위해 GarrisonCommander보다 우선됩니다.
OrderHallCommander를 사용 하지 않으면 GarrisonCommander로 전환할 수 있습니다.]=]
L["Original method"] = "원래의 방법"
L["Position is not saved on logout"] = "접속 종료시 위치는 저장되지 않습니다"
L["Resurrect troops effect"] = "병력 부활 효과"
L["Reward type"] = "보상 유형"
L["Show/hide OrderHallCommander mission menu"] = "OrderHallCommander 임무 메뉴 표시/숨기기"
L["Sort missions by:"] = "임무 정렬 방법:"
L["Success Chance"] = "성공 확률"
L["Troop ready alert"] = "병력 준비 경보"
L["Upgrading to |cff00ff00%d|r"] = "|cff00ff00%d|r\\1241으로;로; 향상시키기"
L["Use combat ally"] = "전투 동료 사용"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "|cffff0000%d|cffffd200점을 낭비하고 있습니다!!!"
return
end
L=l:NewLocale(me,"esMX")
if (L) then
L["Always counter increased resource cost"] = "Siempre contrarreste el mayor costo de recursos"
L["Always counter increased time"] = "Siempre contrarreste el tiempo incrementado"
L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = "Siempre contra las tropas de matar (ignorado si sólo podemos utilizar tropas con sólo 1 durabilidad a la izquierda)"
L["Better parties available in next future"] = "Mejores fiestas disponibles en el próximo futuro"
L["Building Final report"] = "Informe final del edificio"
L["Capped %1$s. Spend at least %2$d of them"] = "% 1 $ s cubierto. Gasta al menos% 2 $ d de ellos"
L["Changes the sort order of missions in Mission panel"] = "Cambia el orden de las misiones en el panel de la Misión"
L["Complete all missions without confirmation"] = "Completa todas las misiones sin confirmación"
L["Configuration for mission party builder"] = "Configuración para el constructor de la misión"
L["Dont kill Troops"] = "No matar a las tropas"
L["Duration reduced"] = "Duración reducida"
L["Duration Time"] = "Duración"
L["Expiration Time"] = "Tiempo de expiración"
L["Favours leveling follower for xp missions"] = "Favors nivelando seguidor para las misiones xp"
L["General"] = true
L["Global approx. xp reward"] = "Global aprox. Recompensa xp"
L["HallComander Quick Mission Completion"] = "Conclusión de la misión rápida de HallComander"
L[ [=[If you %s,  you will lose them
Click on %s to abort]=] ] = "Si% s, los perderá  nHaga clic en% s para abortar"
L["Keep cost low"] = "Mantenga el costo bajo"
L["Keep time short"] = "Mantenga el tiempo corto"
L["Keep time VERY short"] = "Mantener el tiempo muy corto"
L["Level"] = "Nivel"
L["Make Order Hall Mission Panel movable"] = "Hacer pedido Hall Misión Panel móvil"
L["Maximize xp gain"] = "Maximizar la ganancia de xp"
L["Missions"] = "Misiones"
L["No follower gained xp"] = "Ningún seguidor ganó xp"
L["Nothing to report"] = "Nada que reportar"
L["Notifies you when you have troops ready to be collected"] = "Notifica cuando hay tropas listas para ser recolectadas"
L["Only accept missions with time improved"] = "Sólo aceptar misiones mejoradas con el tiempo"
L[ [=[OrderHallCommander overrides GarrisonCommander for Order Hall Management.
 You can revert to GarrisonCommander simpy disabling OrderhallCommander]=] ] = "OrderHallCommander reemplaza a GarrisonCommander para la Gestión de Hall de Orden.  N Puede volver a GarneyCommander simplemente inhabilitando OrderhallCommander"
L["Original method"] = "Método original"
L["Position is not saved on logout"] = "La posición no se guarda al cerrar la sesión"
L["Resurrect troops effect"] = "Efecto de las tropas de resurrección"
L["Reward type"] = "Tipo de recompensa"
L["Show/hide OrderHallCommander mission menu"] = "Mostrar / ocultar el menú de la misión OrderHallCommander"
L["Sort missions by:"] = "Ordenar misiones por:"
L["Success Chance"] = "Éxito"
L["Troop ready alert"] = "Alerta lista de tropas"
L["Upgrading to |cff00ff00%d|r"] = "Actualizando a | cff00ff00% d | r"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "Está perdiendo | cffff0000% d | cffffd200 punto (s)!"
return
end
L=l:NewLocale(me,"ruRU")
if (L) then
L["Always counter increased resource cost"] = "Учитывать увеличение стоимости ресурсов."
L["Always counter increased time"] = "Учитывать увеличение времени на задание"
L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = "Учитывать жизни валарьяров. (Игнорируется, если остались войска только с 1 ед.здоровья)"
L["Always counter no bonus loot threat"] = [=[Игнорировать миссии, если
нет шанса на дополнительную добычу]=]
L["Better parties available in next future"] = "Лучшая партия будет скоро доступна"
L["Building Final report"] = "Создать отчет."
L["Capped %1$s. Spend at least %2$d of them"] = "Достигнуто %1$. Потратьте  по крайней мере 2%$"
L["Changes the sort order of missions in Mission panel"] = "Изменение порядка сортировки миссий"
L["Combat ally is proposed for missions so you can consider unassigning him"] = [=[Использовать боевого соратника в расчетах.
Перед отправкой освободите соратника.]=]
L["Complete all missions without confirmation"] = "Завершить все миссии без подтверждения"
L["Configuration for mission party builder"] = "Конфигурация для построения мисии"
L["Dont kill Troops"] = "Не убивать валарьяров"
L["Duration reduced"] = "Продолжительность уменьшена"
L["Duration Time"] = "Продолжительность"
L["Expiration Time"] = "Время окончания"
L["Favours leveling follower for xp missions"] = "В миссиях на опыт, использовать гибкую прокачку соратников"
L["General"] = "Основные"
L["Global approx. xp reward"] = "Опыт"
L["HallComander Quick Mission Completion"] = "HallComander Быстрое завершение миссий"
L[ [=[If you %s,  you will lose them
Click on %s to abort]=] ] = [=[Если вы %, вы потеряете их. 
Нажмите на %, чтобы прервать]=]
L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = [=[Если вы %, вы потеряете их.
Нажмите на %, чтобы прервать]=]
L["Keep cost low"] = "Дешевые миссии"
L["Keep extra bonus"] = "Дополнительная добыча"
L["Keep time short"] = "Короткие миссии"
L["Keep time VERY short"] = "Быстрые миссии"
L["Level"] = "Уровень"
L["Make Order Hall Mission Panel movable"] = "  Разрешить перемещать панель Order Hall"
L["Maximize xp gain"] = "Максимальный опыт"
L["Missions"] = "Миссии"
L["No follower gained xp"] = "Соратник не получает опыт"
L["Nothing to report"] = "Без отчета"
L["Notifies you when you have troops ready to be collected"] = "Уведомлять о готовности свежих войск"
L["Only accept missions with time improved"] = "Разрешать миссии только с ускоренным выполнением"
L[ [=[OrderHallCommander overrides GarrisonCommander for Order Hall Management.
 You can revert to GarrisonCommander simpy disabling OrderhallCommander]=] ] = "OrderHallCommander переопределяет GarrisonCommander для управления оплотом. Вы можете вернуться к GarrisonCommander отключив OrderhallCommander"
L["Original method"] = "Обычный метод"
L["Position is not saved on logout"] = "Позиция не сохранится при выходе из системы"
L["Resurrect troops effect"] = "Эффект воскрешения войск"
L["Reward type"] = "Награда"
L["Show/hide OrderHallCommander mission menu"] = "Показать/скрыть меню OrderHallCommander"
L["Sort missions by:"] = "Сортировать миссии по:"
L["Success Chance"] = "Шанс успеха"
L["Troop ready alert"] = "Предупреждать о готовности войск"
L["Upgrading to |cff00ff00%d|r"] = "Обновление до |cff00ff00%d|r"
L["Use combat ally"] = "Боевой соратник"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "Вы тратите |cffff0000%d|cffffd200 очков !!!"
return
end
L=l:NewLocale(me,"zhCN")
if (L) then
L["Always counter increased resource cost"] = "总是反制增加资源花费"
L["Always counter increased time"] = "总是反制增加任务时间"
L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = "总是反制杀死部队(如果我们用只剩一次耐久的部队则忽略)"
L["Always counter no bonus loot threat"] = "总是反制没有额外奖励的威胁"
L["Better parties available in next future"] = "在将来有更好的队伍"
L["Building Final report"] = "构建最终报告"
L["Capped %1$s. Spend at least %2$d of them"] = "%1$s封顶了。花费至少%2$d在它身上"
L["Changes the sort order of missions in Mission panel"] = "改变任务面板上的任务排列顺序"
L["Combat ally is proposed for missions so you can consider unassigning him"] = "战斗盟友被建议到任务，所以你可以考虑取消指派他"
L["Complete all missions without confirmation"] = "完成所有任务不须确认"
L["Configuration for mission party builder"] = "任务队伍构建设置"
L["Dont kill Troops"] = "别让部队被杀死"
L["Duration reduced"] = "持续时间已缩短"
L["Duration Time"] = "持续时间"
L["Expiration Time"] = "到期时间"
L["Favours leveling follower for xp missions"] = "倾向于使用升级中追隨者在经验值任务"
L["General"] = "一般"
L["Global approx. xp reward"] = "整体大约经验值奖励"
L["HallComander Quick Mission Completion"] = "大厅指挥官快速任务完成"
L[ [=[If you %s,  you will lose them
Click on %s to abort]=] ] = [=[如果你继续，你会失去它们
点击%s來取消]=]
L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = [=[如果你继续，你会失去它们
点击%s來取消]=]
L["Keep cost low"] = "节省大厅资源"
L["Keep extra bonus"] = "优先额外奖励"
L["Keep time short"] = "减少任务时间"
L["Keep time VERY short"] = "最短任务时间"
L["Level"] = "等级"
L["Make Order Hall Mission Panel movable"] = "让大厅任务面板可移动"
L["Maximize xp gain"] = "最大化经验获取"
L["Missions"] = "任务"
L["No follower gained xp"] = "没有追随者获得经验"
L["Nothing to report"] = "没什么可报告"
L["Notifies you when you have troops ready to be collected"] = "当部队已准备好获取时提醒你"
L["Only accept missions with time improved"] = "只允许有时间改善的任务"
L[ [=[OrderHallCommander overrides GarrisonCommander for Order Hall Management.
 You can revert to GarrisonCommander simpy disabling OrderhallCommander]=] ] = [=[OrderHallCommander覆盖GarrisonCommander订单厅管理。
  你可以恢复到GarrisonCommander simpy禁用OrderhallCommander]=]
L["Original method"] = "原始方法"
L["Position is not saved on logout"] = "位置不会在登出后储存"
L["Resurrect troops effect"] = "复活部队效果"
L["Reward type"] = "奖励类型"
L["Show/hide OrderHallCommander mission menu"] = "显示/隐藏大厅指挥官任务选单"
L["Sort missions by:"] = "排列任务根据："
L["Success Chance"] = "成功机率"
L["Troop ready alert"] = "部队装备提醒"
L["Upgrading to |cff00ff00%d|r"] = "升级到|cff00ff00%d|r"
L["Use combat ally"] = "使用战斗盟友"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "你浪费了|cffff0000%d|cffffd200 点数!!!"
return
end
L=l:NewLocale(me,"esES")
if (L) then
L["Always counter increased resource cost"] = "Siempre contrarreste el mayor costo de recursos"
L["Always counter increased time"] = "Siempre contrarreste el tiempo incrementado"
L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = "Siempre contrarrestar la muerte de tropas (ignorado si sólo podemos utilizar tropas con un solo punto de durabilidad)"
L["Always counter no bonus loot threat"] = "Siempre contrarresta la falta de bonificación de botín"
L["Better parties available in next future"] = "Mejores fiestas disponibles en el próximo futuro"
L["Building Final report"] = "Informe final del edificio"
L["Capped %1$s. Spend at least %2$d of them"] = "% 1 $ s cubierto. Gasta al menos% 2 $ d de ellos"
L["Changes the sort order of missions in Mission panel"] = "Cambia el orden de las misiones en el panel de la Misión"
L["Complete all missions without confirmation"] = "Completa todas las misiones sin confirmación"
L["Configuration for mission party builder"] = "Configuración para el constructor de la misión"
L["Dont kill Troops"] = "No matar a las tropas"
L["Duration reduced"] = "Duración reducida"
L["Duration Time"] = "Duración"
L["Expiration Time"] = "Tiempo de expiración"
L["Favours leveling follower for xp missions"] = "Favors nivelando seguidor para las misiones xp"
L["General"] = true
L["Global approx. xp reward"] = "Global aprox. Recompensa xp"
L["HallComander Quick Mission Completion"] = "Conclusión de la misión rápida de HallComander"
L[ [=[If you %s,  you will lose them
Click on %s to abort]=] ] = "Si% s, los perderá  nHaga clic en% s para abortar"
L["Keep cost low"] = "Mantenga el costo bajo"
L["Keep extra bonus"] = "Mantener bonificación extra"
L["Keep time short"] = "Mantenga el tiempo corto"
L["Keep time VERY short"] = "Mantener el tiempo muy corto"
L["Level"] = "Nivel"
L["Make Order Hall Mission Panel movable"] = "Hacer pedido Hall Misión Panel móvil"
L["Maximize xp gain"] = "Maximizar la ganancia de xp"
L["Missions"] = "Misiones"
L["No follower gained xp"] = "Ningún seguidor ganó xp"
L["Nothing to report"] = "Nada que reportar"
L["Notifies you when you have troops ready to be collected"] = "Notifica cuando hay tropas listas para ser recolectadas"
L["Only accept missions with time improved"] = "Sólo aceptar misiones mejoradas con el tiempo"
L[ [=[OrderHallCommander overrides GarrisonCommander for Order Hall Management.
 You can revert to GarrisonCommander simpy disabling OrderhallCommander]=] ] = "OrderHallCommander reemplaza a GarrisonCommander para la Gestión de Hall de Orden.  N Puede volver a GarneyCommander simplemente inhabilitando OrderhallCommander"
L["Original method"] = "Método original"
L["Position is not saved on logout"] = "La posición no se guarda al cerrar la sesión"
L["Resurrect troops effect"] = "Efecto de las tropas de resurrección"
L["Reward type"] = "Tipo de recompensa"
L["Show/hide OrderHallCommander mission menu"] = "Mostrar / ocultar el menú de la misión OrderHallCommander"
L["Sort missions by:"] = "Ordenar misiones por:"
L["Success Chance"] = "Éxito"
L["Troop ready alert"] = "Alerta lista de tropas"
L["Upgrading to |cff00ff00%d|r"] = "Actualizando a | cff00ff00% d | r"
L["Use combat ally"] = "Usar aliado de combate"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "Está perdiendo | cffff0000% d | cffffd200 punto (s)!"
return
end
L=l:NewLocale(me,"zhTW")
if (L) then
L["Always counter increased resource cost"] = "總是反制增加資源花費"
L["Always counter increased time"] = "總是反制增加任務時間"
L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = "總是反制殺死部隊(如果我們用只剩一次耐久的部隊則忽略)"
L["Always counter no bonus loot threat"] = "總是反制沒有額外獎勵的威脅"
L["Better parties available in next future"] = "在將來有更好的隊伍"
L["Building Final report"] = "構建最終報告"
L["Capped %1$s. Spend at least %2$d of them"] = "%1$s封頂了。花費至少%2$d在它身上"
L["Changes the sort order of missions in Mission panel"] = "改變任務面板上的任務排列順序"
L["Combat ally is proposed for missions so you can consider unassigning him"] = "戰鬥盟友被建議到任務，所以你可以考慮取消指派他"
L["Complete all missions without confirmation"] = "完成所有任務不須確認"
L["Configuration for mission party builder"] = "任務隊伍構建設置"
L["Dont kill Troops"] = "別讓部隊被殺死"
L["Duration reduced"] = "持續時間已縮短"
L["Duration Time"] = "持續時間"
L["Expiration Time"] = "到期時間"
L["Favours leveling follower for xp missions"] = "傾向於使用升級中追隨者在經驗值任務"
L["General"] = "(G) 一般"
L["Global approx. xp reward"] = "整體大約經驗值獎勵"
L["HallComander Quick Mission Completion"] = "大廳指揮官快速任務完成"
L[ [=[If you %s,  you will lose them
Click on %s to abort]=] ] = [=[如果您繼續，您會失去它們
點擊%s來取消]=]
L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = [=[如果您繼續，您會失去它們
點擊%s來取消]=]
L["Keep cost low"] = "保持低花費"
L["Keep extra bonus"] = "保持額外獎勵"
L["Keep time short"] = "保持短時間"
L["Keep time VERY short"] = "保持非常短的時間"
L["Level"] = "等級"
L["Make Order Hall Mission Panel movable"] = "讓大廳任務面板可移動"
L["Maximize xp gain"] = "最大化經驗獲取"
L["Missions"] = "(M) 任務"
L["No follower gained xp"] = "沒有追隨者獲得經驗"
L["Nothing to report"] = "沒什麼可報告"
L["Notifies you when you have troops ready to be collected"] = "當部隊已準備好獲取時提醒你"
L["Only accept missions with time improved"] = "只允許有時間改善的任務"
L[ [=[OrderHallCommander overrides GarrisonCommander for Order Hall Management.
 You can revert to GarrisonCommander simpy disabling OrderhallCommander]=] ] = [=[大廳指揮官會覆蓋要塞指揮官為大廳管理。
你可以返回使用要塞指揮官只要簡單的停用大廳指揮官]=]
L["Original method"] = "原始方法"
L["Position is not saved on logout"] = "位置不會在登出後儲存"
L["Resurrect troops effect"] = "復活部隊效果"
L["Reward type"] = "獎勵類型"
L["Show/hide OrderHallCommander mission menu"] = "顯示/隱藏大廳指揮官任務選單"
L["Sort missions by:"] = "排列任務根據："
L["Success Chance"] = "成功機率"
L["Troop ready alert"] = "部隊整備提醒"
L["Upgrading to |cff00ff00%d|r"] = "升級到|cff00ff00%d|r"
L["Use combat ally"] = "使用戰鬥盟友"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "你浪費了|cffff0000%d|cffffd200 點數!!!"
return
end
