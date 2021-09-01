		-------------------------------------------------
		-- Paragon Reputation 1.37 by Fail US-Ragnaros --
		-------------------------------------------------

		  --[[	  Special thanks to Ammako for
				  helping me with the vars and
				  the options.						]]--	

local ADDON_NAME,ParagonReputation = ...
local PR = ParagonReputation

local LOCALE = GetLocale()
PR.L = {}

-- Spanish
if LOCALE == "esES" or LOCALE == "esMX" then
	PR.L["PARAGON"] = "Paragón"
	PR.L["OPTIONDESC"] = "Estas opciones te permiten personalizar algunas cosas de Paragon Reputation."
	PR.L["TOASTDESC"] = "Activa o desactiva una ventana que te avisara cuando tengas una Recompensa Paragón."
	PR.L["LABEL001"] = "Colores de las Barras"
	PR.L["LABEL002"] = "Formato del Texto"
	PR.L["LABEL003"] = "Aviso de Recompensa"
	PR.L["BLUE"] = "Azul Paragón"
	PR.L["GREEN"] = "Verde Predeterminado"
	PR.L["YELLOW"] = "Amarillo Neutral"
	PR.L["ORANGE"] = "Naranja Adverso"
	PR.L["RED"] = "Rojo Clarito"
	PR.L["DEFICIT"] = "Déficit de Reputación"
	PR.L["SOUND"] = "Sonido de Advertencia"
	PR.L["ANCHOR"] = "Posicionar el Ancla"
	
-- Italian (Google Translated this ones... should work because I speak spanish and they are similar to some extent)
elseif LOCALE == "itIT" then
	PR.L["PARAGON"] = "Eccellenza"
	PR.L["OPTIONDESC"] = "Queste opzioni ti consentono di personalizzare alcune cose di Paragon Reputation."
	PR.L["TOASTDESC"] = "Attiva o disattiva una finestra che ti avviserà quando hai una Ricompensa Eccellenza."
	PR.L["LABEL001"] = "Colori delle Barre"
	PR.L["LABEL002"] = "Formato di Testo"
	PR.L["LABEL003"] = "Avviso di Ricompensa"
	PR.L["BLUE"] = "Blue Eccellenza"
	PR.L["GREEN"] = "Verde Predefinito"
	PR.L["YELLOW"] = "Giallo Neutro"
	PR.L["ORANGE"] = "Arancione Avverso"
	PR.L["RED"] = "Clarito Rosso"
	PR.L["DEFICIT"] = "Deficit di Reputazione"
	PR.L["SOUND"] = "Suono di Avviso"
	PR.L["ANCHOR"] = "Posiziona l'Ancora"
	--Also, apparently nobody speaks Italian :(

-- Portuguese (Thanks tiagopl)
elseif LOCALE == "ptBR" then
	PR.L["PARAGON"] = "Paragão"
	PR.L["OPTIONDESC"] = "Essas opções permitem que você customize algumas configurações do Paragon Reputation."
	PR.L["TOASTDESC"] = "Ativa uma janela que vai te avisar quando você tiver uma Recompensa de Paragão."
	PR.L["LABEL001"] = "Cor das Barras"
	PR.L["LABEL002"] = "Formato do Texto"
	PR.L["LABEL003"] = "Janela de Recompensa"
	PR.L["BLUE"] = "Azul Paragão"
	PR.L["GREEN"] = "Verde Padrão"
	PR.L["YELLOW"] = "Amarelo Neutro"
	PR.L["ORANGE"] = "Laranja Hostil"
	PR.L["RED"] = "Vermelho Lavado"
	PR.L["DEFICIT"] = "Déficit de Reputação"
	PR.L["SOUND"] = "Aviso Sonoro"
	PR.L["ANCHOR"] = "Alternar Âncora"

-- German (Thanks flow0284 & z3r0t3n)
elseif LOCALE == "deDE" then
	PR.L["PARAGON"] = "Huldigend"
	PR.L["OPTIONDESC"] = "Mit diesen Einstellungen können einige Anpassungen an Paragon Reputation vorgenommen werden."
	PR.L["TOASTDESC"] = "Aktiviert/Deaktiviert die Benachrichtigung, die angezeigt wird wenn eine Huldigend Rufbelohnung verfügbar ist."
	PR.L["LABEL001"] = "Balkenfarbe"
	PR.L["LABEL002"] = "Textformatierung"
	PR.L["LABEL003"] = "Benachrichtigung"
	PR.L["BLUE"] = "Blau"
	PR.L["GREEN"] = "Grün"
	PR.L["YELLOW"] = "Gelb"
	PR.L["ORANGE"] = "Orange"
	PR.L["RED"] = "Leuchtendrot"
	PR.L["DEFICIT"] = "Rufdefizit"
	PR.L["SOUND"] = "Benachrichtungston"
	PR.L["ANCHOR"] = "Position zeigen/verbergen"

-- French (Thanks HipNoTiK_007)
elseif LOCALE == "frFR" then
	PR.L["PARAGON"] = "Parangon"
	PR.L["OPTIONDESC"] = "Ces options permettent de régler plusieurs paramètres de l'addon."
	PR.L["TOASTDESC"] = "Affiche une alerte lorsque vous avez une récompenses de Parangon disponible."
	PR.L["LABEL001"] = "Couleur Barres"
	PR.L["LABEL002"] = "Format Texte"
	PR.L["LABEL003"] = "Notification Récompense"
	PR.L["BLUE"] = "Bleu Parangon"
	PR.L["GREEN"] = "Vert Par défaut"
	PR.L["YELLOW"] = "Jaune Neutre"
	PR.L["ORANGE"] = "Orange Inamical"
	PR.L["RED"] = "Rosé"
	PR.L["DEFICIT"] = "Réputation manquante"
	PR.L["SOUND"] = "Alerte sonore"
	PR.L["ANCHOR"] = "Activer/Désactiver Ancre"

-- Russian (Thanks Wolfeg)
elseif LOCALE == "ruRU" then
	PR.L["PARAGON"] = "Парагон"
	PR.L["OPTIONDESC"] = "Эти опции позволяют вам кастомизировать настройки аддона Paragon Reputation."
	PR.L["TOASTDESC"] = "Включить информационное окно о достижении достаточной репутации для получения награды."
	PR.L["LABEL001"] = "Цвет полос"
	PR.L["LABEL002"] = "Формат текста"
	PR.L["LABEL003"] = "Окно награды"
	PR.L["BLUE"] = "Совершенный голубой"
	PR.L["GREEN"] = "Стандартный зеленый"
	PR.L["YELLOW"] = "Нейтрально желтый"
	PR.L["ORANGE"] = "Враждебный оранжевый"
	PR.L["RED"] = "Высветленный красный"
	PR.L["DEFICIT"] = "Необходимая репутация"
	PR.L["SOUND"] = "Звуковое предупреждение"
	PR.L["ANCHOR"] = "Показать фиксатор"

-- Korean (Thanks yuk6196)
elseif LOCALE == "koKR" then
	PR.L["PARAGON"] = "불멸의 동맹"
	PR.L["OPTIONDESC"] = "Paragon Reputation의 여러 설정을 변경할 수 있는 옵션입니다."
	PR.L["TOASTDESC"] = "불멸의 동맹 보상을 받을 수 있을 때 알려주는 알림창을 켜고 끕니다."
	PR.L["LABEL001"] = "바 색상"
	PR.L["LABEL002"] = "문자 형식"
	PR.L["LABEL003"] = "보상 알림창"
	PR.L["BLUE"] = "불멸의 동맹 푸른색"
	PR.L["GREEN"] = "기본 녹색"
	PR.L["YELLOW"] = "중립 노란색"
	PR.L["ORANGE"] = "적대적 주황색"
	PR.L["RED"] = "밝은 붉은색"
	PR.L["DEFICIT"] = "평판 결손치"
	PR.L["SOUND"] = "소리 경보"
	PR.L["ANCHOR"] = "고정기 위치"

-- Chinese (Simplified) (Thanks dxlmike)
elseif LOCALE == "zhCN" then 
	PR.L["PARAGON"] = "巅峰"
	PR.L["OPTIONDESC"] = "可以自定巅峰声望条的一些设定."
	PR.L["TOASTDESC"] = "切换获得巅峰奖励时是否弹出通知."
	PR.L["LABEL001"] = "声望条颜色"
	PR.L["LABEL002"] = "文字格式"
	PR.L["LABEL003"] = "弹出奖励通知"
	PR.L["BLUE"] = "巅峰蓝"
	PR.L["GREEN"] = "预设绿"
	PR.L["YELLOW"] = "中立黄"
	PR.L["ORANGE"] = "敌对橙"
	PR.L["RED"] = "淡红"
	PR.L["DEFICIT"] = "还需要多少声望"
	PR.L["SOUND"] = "音效通知"
	PR.L["ANCHOR"] = "锚点"

-- Chinese (Traditional) (Thanks gaspy10 & BNSSNB)
elseif LOCALE == "zhTW" then
	PR.L["PARAGON"] = "巅峰"
	PR.L["OPTIONDESC"] = "這些選項可讓你自訂巔峰聲望條的一些設定。"
	PR.L["TOASTDESC"] = "切換獲得巔峰聲望獎勵時的彈出式通知。"
	PR.L["LABEL001"] = "聲望條顏色"
	PR.L["LABEL002"] = "文字格式"
	PR.L["LABEL003"] = "彈出獎勵通知"
	PR.L["BLUE"] = "巔峰藍"
	PR.L["GREEN"] = "預設綠"
	PR.L["YELLOW"] = "中立黃"
	PR.L["ORANGE"] = "不友好橘"
	PR.L["RED"] = "淡紅色"
	PR.L["DEFICIT"] = "還需要多少聲望"
	PR.L["SOUND"] = "音效通知"
	PR.L["ANCHOR"] = "切換錨點"

-- English (DEFAULT)
else
	PR.L["PARAGON"] = "Paragon"
	PR.L["OPTIONDESC"] = "This options allow you to customize some settings of Paragon Reputation."
	PR.L["TOASTDESC"] = "Toggle a toast window that will warn you when you have a Paragon Reward."
	PR.L["LABEL001"] = "Bars Color"
	PR.L["LABEL002"] = "Text Format"
	PR.L["LABEL003"] = "Reward Toast"
	PR.L["BLUE"] = "Paragon Blue"
	PR.L["GREEN"] = "Default Green"
	PR.L["YELLOW"] = "Neutral Yellow"
	PR.L["ORANGE"] = "Unfriendly Orange"
	PR.L["RED"] = "Lightish Red"
	PR.L["DEFICIT"] = "Reputation Deficit"
	PR.L["SOUND"] = "Sound Warning"
	PR.L["ANCHOR"] = "Toggle Anchor"
	
end