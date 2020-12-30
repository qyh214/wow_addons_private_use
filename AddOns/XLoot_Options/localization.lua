-- See: http://wow.curseforge.com/addons/xloot/localization/ to create or fix translations
local locales = {
	enUS = {
		Core = {
			panel_title = "Global options",
			details = "Skin is applied to all XLoot modules. Most other settings currently require a /reload to be applied. Please open a ticket with any issues.\nTo turn off a single module, disable it like any normal addon.",
			skin = "Skin",
			skin_desc = "Select skin to use. Includes Masque skins",
			skin_anchors = "Apply to anchors",
			skin_anchors_desc = "Apply skin to anchors that XLoot uses",
			module_header = "Module options",
		},
		Frame = {
			panel_title = "Loot Frame",
			panel_desc = "Provides a adjustable loot frame",
			-- Group labels
			frame_options = "Frame settings",
			slot_options = "Loot slots",
			link_button = "Link all button",
			autolooting = "Auto-looting",
			colors = "Colors",

			-- Option labels
			autoloot_currency = "Auto loot currency",
			autoloot_currency_desc = "When to automatically loot currency",
			autoloot_quest = "Auto loot quest items",
			autoloot_quest_desc = "When to automatically loot quest items",
			autoloot_tradegoods = "Auto loot trade goods",
			autoloot_tradegoods_desc = "When to automatically loot any item of Trade Goods type",
			autoloot_all = "Auto loot everything",
			autoloot_list = "Auto loot listed items",
			autoloot_list_desc = "When to automatically loot listed items",
			autoloot_item_list = "Items to loot",
			-- frame_scale = "Frame scale",
			-- frame_alpha = "Frame alpha",
			frame_color_border = "Frame border color",
			frame_color_backdrop = "Frame backdrop color",
			frame_color_gradient = "Frame gradient color",
			frame_width_automatic = "Automatically expand frame",
			frame_width = "Frame width",
			old_close_button = "Use old close button",
			loot_highlight = "Highlight slots on mouseover",
			-- loot_alpha = "Slot alpha",
			loot_color_border = "Loot border color",
			loot_color_backdrop = "Loot backdrop color",
			loot_color_gradient = "Loot gradient color",
			loot_color_info = "Information text color",
			loot_collapse = "Collapse looted slots",
			loot_icon_size = "Loot icon size",
			loot_row_height = "Loot row height",
			quality_color_frame = "Color frame border by top quality",
			quality_color_slot = "Color loot border by quality",
			loot_texts_info = "Show detailed information",
			loot_texts_bind = "Show loot bind type",
			loot_texts_lock = "Show locked status",
			loot_buttons_auto = "Autoloot shortcut",
			loot_buttons_auto_desc = "A button to add any item to your auto-looting list (See below)\nOnly shown when the item would be autolooted",
			font_size_info = "Loot information",
			font_size_bottombuttons = "Linkall/Close",
			frame_snap = "Snap frame to mouse",
			frame_snap_offset_x = "Horizontal snap offset",
			frame_snap_offset_y = "Vertical snap offset",
			frame_grow_upwards = "Expand frame upwards",
			frame_draggable = "Loot frame draggable",
			linkall_threshold = "Minimum chat link quality",
			linkall_channel = "Default chat link channel",
			linkall_channel_secondary = "Secondary chat link channel",
			linkall_show = "Link button visibility",
			linkall_first_only = "Only link top item",

			autolooting_text = "XLoot's autolooting features act separately from the default UI. As such, if both are enabled, you may recieve warnings like 'that object is busy'. They are safe to ignore, but can be resolved by picking one autoloot method to use exclusively.",

			autolooting_list = "To automatically loot specific items, list them below.\n  Example: Linen Cloth,Ashbringer,Copper Ore",

			autolooting_details = "XLoot will choose the highest setting when deciding to loot a slot. This allows, for example, auto looting everything while solo yet only quest items and money while in a group.",

			show_slot_errors = "Looting errors in chat",
			show_slot_errors_details = "Print a chat message when a loot item cannot be shown for some reason. Most of these should be able to be safely ignored.",
		},
		Group = {
			panel_title = "Group Loot",
			-- Group labels
			anchors = "Anchors",
			rolls = "Roll frames",
			other_frames = "Other frames",
			roll_tracking = "What rolls to show",
			alerts = "Loot alerts",
			extra_info = "Details",

			-- Header labels
			expiration = "Expiration (in seconds)",

			-- Option labels
			text_outline = "Outline text",
			text_outline_desc = "Draws a dark outline around text on roll frames",
			text_time = "Show time remaining",
			text_time_desc = "Displays seconds remaining to roll over item icon",
			text_ilvl = "Show item level",
			role_icon = "Show role icons",
			win_icon = "Show winning type icon",
			show_decided = "Show decided",
			show_undecided = "List waiting players",
			show_undecided_desc = "List players who have not chosen how to roll",
			hook_alert = "Modify loot alerts",
			hook_alert_desc = "('You won..' popups)\nAttach loot alerts to a movable anchor.\n\nDisabling this can improve compatibility with other loot addons. \n\n(Requires ReloadUI)",
			alert_skin = "Skin loot alert frames",
			alert_offset = "Vertical spacing",
			alert_background = "Show background",
			alert_icon_frame = "Show icon frame",
			hook_bonus = "Modify bonus rolls",
			hook_bonus_desc = "Attach bonus loot rolls to a movable anchor.\n\nDisabling this can improve compatibility with other loot addons. \n\n(Requires ReloadUI)",
			bonus_skin = "Skin bonus roll frame",
			roll_width = "Roll frame width",
			roll_button_size = "Roll button size",
			roll_anchor_visible = "Roll anchor visible",
			alert_anchor_visible = "Loot alerts anchor visible",
			alert_anchor_visible_desc = "Refers to 'You won..' popups",
			track_all = "Track all rolls",
			track_player_roll = "Track items you roll on",
			track_by_threshold = "Track items by minimum quality",
			expire_won = "Won rolls",
			expire_lost = "Lost/Passed rolls",
			preview_show = "Show Preview",
			equip_prefix = "Show equippable prefix",
			equip_prefix_desc = "Prefixes item names to indicate if a item can be equipped or is a upgrade. (Upgrade prefix requires the Pawn addon)",
			prefix_equippable = "Equippable prefix",
			prefix_upgrade = "Upgrade prefix",

			hook_warning_text = "Hooking the loot alert and bonus roll frames has rarely been reported to cause issues such as not seeing bonus rolls.\n\nBy enabling these options you acknowledge that you understand and accept that risk.\n",
		},
		Monitor = {
			panel_title = "Loot Monitor",
			-- Group labels
			testing = "Testing",
			anchor = "Anchor",
			thresholds = "Quality thresholds",
			fading = "Row fade times (in seconds)",
			details = "Details",
			-- Option labels
			test_settings = "Click to test settings",
			visible = "Anchor visible",
			show_crafted = "Crafted",
			show_totals = "Show total items in inventory",
			totals_delay = "Totals delay",
			totals_delay_desc = "Time to wait before asking the game how many items you have, as the item events do not reliably match up to inventory counts",
			use_altoholic = "Include bank (Altoholic)",
			show_ilvl = "Show item level",
			font_size_ilvl = "Item level",
			name_width = "Player name width",
			gradients = "Gradients",
		},
		Master = {
			panel_title = "Loot Master",
			-- Group labels
			specialrecipients = "Special Recipients Menu",
			raidroll = "Special Rolls Menu",
			awardannounce = "Announce Item Distribution",
			-- Option labels
			confirm_qualitythreshold = "Minimum confirm quality",
			menu_roll = "Show raid roll",
			menu_disenchant = "Show disenchanter",
 			menu_disenchanters = "Disenchant character names",
			menu_bank = "Show banker",
			menu_bankers = "Banker character names",
			menu_self = "Show self",
			award_qualitythreshold = "Minimum announce quality",
			award_channel = "Default chat announce channel",
			award_channel_secondary = "Secondary chat announce channel",
			award_guildannounce = "Echo in guild chat",
			award_special = "Announce special recipients",
		},
		font = "Font",
		font_sizes = "Sizes",
		font_size_loot = "Loot",
		font_size_quantity = "Quantity",
		font_flag = "Flag",
		desc_channel_auto = "Highest available",
		growth_direction = "Growth direction",
		alignment = "Alignment",
		scale = "Scale",
		width = "Width",
		alpha = "Opacity",
		spacing = "Spacing",
		offset = "Offset",
		visible = "Visible",
		padding = "Padding",
		items_others = "Others' items",
		items_own = "Own items",
		up = "Up",
		down = "Down",
		left = "Left",
		right = "Right",
		top = "Top",
		bottom = "Bottom",
		minimum_quality = "Minimum quality",
		when_never = "Never",
		when_solo = "Solo",
		when_always = "Always",
		when_auto = "Automatic",
		when_group = "In groups",
		when_party = "In parties",
		when_raid = "In raids",
		confirm_reset_profile = "This will reset all options for this profile. Are you sure?",
		profile = "Profile",
		message_reloadui_warning = "|c2244dd22%s|r: Changing |c2244dd22%s|r requires you to reload your UI before continuing to play: |c2244dd22/reload ui|r",
	},
	-- Possibly localized
	ptBR = {

	},
	frFR = {

	},
	deDE = {

	},
	koKR = {

	},
	esMX = {

	},
	ruRU = {

	},
	zhCN = {

	},
	esES = {

	},
	zhTW = {

	},
}

-- Automatically inserted translations
locales.ptBR["Options"] = {
}

locales.frFR["Options"] = {
}

locales.deDE["Options"] = {
	["alpha"] = "Transparenz",
	["confirm_reset_profile"] = "Dies wird alle Einstellungen für dieses Profil auf den Standard zurücksetzen. Bist du sicher?",
	["desc_channel_auto"] = "Höchste Verfügbare",
	["down"] = "Ab",
	["font"] = "Schriftart",
	["font_size_loot"] = "Beute",
	["font_size_quantity"] = "Menge",
	["font_sizes"] = "Größen",
	["growth_direction"] = "Wachstumsrichtung",
	["items_others"] = "Gegenstand anderer",
	["items_own"] = "Eigene Gegenstände",
	["minimum_quality"] = "Minimale Qualität",
	["profile"] = "Profil",
	["scale"] = "Skalierung",
	["up"] = "Hoch",
	["visible"] = "Sichtbar",
	["when_always"] = "Immer",
	["when_auto"] = "Automatisch",
	["when_group"] = "In Gruppe",
	["when_never"] = "Niemals",
	["when_party"] = "In Gruppen",
	["when_raid"] = "In Schlachtzügen",
	["when_solo"] = "Solo",
	["width"] = "Breite",
}

locales.koKR["Options"] = {
	["alpha"] = "투명도",
	["confirm_reset_profile"] = "이 프로필에 대한 모든 옵션을 초기화합니다. 계속할까요?",
	["down"] = "아래",
	["font"] = "글꼴",
	["font_flag"] = "속성",
	["font_size_loot"] = "전리품",
	["font_size_quantity"] = "수량",
	["font_sizes"] = "크기",
	["growth_direction"] = "확장 방향",
	["items_others"] = "기타 아이템",
	["items_own"] = "자기 아이템",
	["minimum_quality"] = "최소 품질",
	["profile"] = "프로필",
	["scale"] = "크기 비율",
	["up"] = "위",
	["visible"] = "보기",
	["when_always"] = "항상",
	["when_auto"] = "자동",
	["when_group"] = "그룹에서",
	["when_never"] = "안 함",
	["when_party"] = "파티에서",
	["when_raid"] = "공격대에서",
	["when_solo"] = "혼자일 때",
	["width"] = "너비",
}

locales.esMX["Options"] = {
}

locales.ruRU["Options"] = {
	["alpha"] = "Прозрачность",
	["bottom"] = [=[Внизу
]=],
	["confirm_reset_profile"] = "Это сбросит все параметры этого профиля. Вы уверены?",
	["desc_channel_auto"] = "Наивысший из доступных",
	["down"] = "Вниз",
	["font"] = "Шрифт ",
	["font_flag"] = "Флажок",
	["font_size_loot"] = "Добыча ",
	["font_size_quantity"] = "Количество ",
	["font_sizes"] = "Размеры ",
	["growth_direction"] = "Добавлять новые строки",
	["items_others"] = "Остальные вещи",
	["items_own"] = "Ваши вещи",
	["minimum_quality"] = "Минимальное качество",
	["padding"] = [=[Заполнение
]=],
	["profile"] = "Профиль",
	["scale"] = "Масштаб",
	["top"] = [=[Вверх
]=],
	["up"] = "Вверх",
	["visible"] = "Видимый",
	["when_always"] = "Всегда",
	["when_auto"] = "Автоматически",
	["when_group"] = "В группе ",
	["when_never"] = "Никогда",
	["when_party"] = "В группе ",
	["when_raid"] = "В рейде ",
	["when_solo"] = "Соло",
	["width"] = "Ширина",
}

locales.zhCN["Options"] = {
	["alpha"] = "透明度",
	["confirm_reset_profile"] = "这将重置此配置文件的全部选项。确定？",
	["desc_channel_auto"] = "最高可得",
	["down"] = "下",
	["font"] = "字体",
	["font_flag"] = "轮廓",
	["font_size_loot"] = "战利品",
	["font_size_quantity"] = "品质",
	["font_sizes"] = "大小",
	["growth_direction"] = "扩展方向",
	["items_others"] = "其他人的物品",
	["items_own"] = "自己的物品",
	["minimum_quality"] = "最低品质",
	["profile"] = "配置文件",
	["scale"] = "比例",
	["up"] = "上",
	["visible"] = "可见",
	["when_always"] = "总是",
	["when_auto"] = "自动",
	["when_group"] = "在队伍/团队中",
	["when_never"] = "从不",
	["when_party"] = "在队伍中",
	["when_raid"] = "在团队中",
	["when_solo"] = "单人",
	["width"] = "宽度",
}

locales.esES["Options"] = {
	["confirm_reset_profile"] = "Esto reseteará todas las opciones de este perfil. ¿Estás seguro?",
	["font"] = "Fuente",
	["font_size_loot"] = "Botín",
	["font_size_quantity"] = "Cantidad",
	["font_sizes"] = "Tamaños",
	["profile"] = "Perfil",
	["when_always"] = "Siempre",
	["when_auto"] = "Automático",
	["when_never"] = "Nunca",
	["when_solo"] = "Solo",
}

locales.zhTW["Options"] = {
	["alpha"] = "透明度",
	["bottom"] = "底部",
	["confirm_reset_profile"] = "將會重置此設定檔的所有設定。你確定要重置嗎？",
	["desc_channel_auto"] = "最高可得",
	["down"] = "下",
	["font"] = "字型",
	["font_flag"] = "標示",
	["font_size_loot"] = "戰利品",
	["font_size_quantity"] = "品質",
	["font_sizes"] = "大小",
	["growth_direction"] = "擴展方向",
	["items_others"] = "他人物品",
	["items_own"] = "自己物品",
	["minimum_quality"] = "最低品質",
	["padding"] = "填充",
	["profile"] = "設定檔",
	["scale"] = "比例",
	["top"] = "頂部",
	["up"] = "上",
	["visible"] = "可見",
	["when_always"] = "總是",
	["when_auto"] = "自動",
	["when_group"] = "隊伍/團隊中",
	["when_never"] = "從不",
	["when_party"] = "隊伍中",
	["when_raid"] = "團隊中",
	["when_solo"] = "單人",
	["width"] = "寬度",
}


-- Manually express subtables because apparently I'm the only one who thought to use namespaces the simple way

locales.ptBR["Core"] = {
}

locales.frFR["Core"] = {
}

locales.deDE["Core"] = {
	["anchor_hide"] = "verstecken",
	["skin_legacy"] = "XLoot: Legacy",
	["skin_smooth"] = "XLoot: Smooth",
	["skin_svelte"] = "XLoot: Svelte",
}

locales.koKR["Core"] = {
	["anchor_hide"] = "감춤",
	["anchor_hide_desc"] = [=[이 모듈을 제 위치에 잠급니다.
이는 표시기를 숨기지만,
옵션에서 다시 표시할 수 있습니다.]=],
	["skin_legacy"] = "XLoot: Legacy",
	["skin_smooth"] = "XLoot: Smooth",
	["skin_svelte"] = "XLoot: Svelte",
}

locales.esMX["Core"] = {
}

locales.ruRU["Core"] = {
	["anchor_hide"] = "скрыть ",
	["anchor_hide_desc"] = [=[Заблокируйте положение этого модуля
Это позволит скрыть якорь,
но он может быть показан еще раз в настройках]=],
	["skin_legacy"] = "XLoot: Legacy",
	["skin_smooth"] = "XLoot: Smooth",
	["skin_svelte"] = "XLoot: Svelte",
}

locales.zhCN["Core"] = {
	["anchor_hide"] = "隐藏",
	["anchor_hide_desc"] = [=[在此位置锁定此模块
这将隐藏锚点
但可通过选项重新显示]=],
	["skin_legacy"] = "XLoot: Legacy",
	["skin_smooth"] = "XLoot: Smooth",
	["skin_svelte"] = "XLoot: Svelte",
}

locales.esES["Core"] = {
}

locales.zhTW["Core"] = {
	["anchor_hide"] = "隱藏",
	["anchor_hide_desc"] = [=[鎖定此模組在此位置上
這會隱藏此錨點,
但它可以藉由選項再次顯示]=],
	["skin_legacy"] = "XLoot: 傳統",
	["skin_smooth"] = "XLoot: 滑順",
	["skin_svelte"] = "XLoot: 苗條",
}


locales.ptBR["Frame"] = {
}

locales.frFR["Frame"] = {
	["bind_on_equip_short"] = "LqE",
	["bind_on_pickup_short"] = "LqR",
	["bind_on_use_short"] = "LqU",
	["button_close"] = "Fermer",
	["button_link"] = "Lien",
	["linkall_threshold_missed"] = "Aucun butin ne correspond à votre seuil de qualité",
}

locales.deDE["Frame"] = {
	["bind_on_equip_short"] = "BoE",
	["bind_on_pickup_short"] = "BoP",
	["bind_on_use_short"] = "BoU",
	["button_close"] = "Schließen",
	["button_link"] = "Senden",
	["linkall_threshold_missed"] = "Beute entspricht nicht deinen Qualitätsansprüchen",
}

locales.koKR["Frame"] = {
	["bind_on_equip_short"] = "착귀",
	["bind_on_pickup_short"] = "획귀",
	["bind_on_use_short"] = "사귀",
	["button_close"] = "닫기",
	["button_link"] = "링크",
	["linkall_threshold_missed"] = "당신의 품질 기준을 만족하는 전리품 없음",
}

locales.esMX["Frame"] = {
}

locales.ruRU["Frame"] = {
	["bind_on_equip_short"] = "БоЕ",
	["bind_on_pickup_short"] = "БоП",
	["bind_on_use_short"] = "Становится персональным при использовании",
	["button_close"] = "Закрыть",
	["button_link"] = "Ссылка",
	["linkall_threshold_missed"] = "Нет добычи, удовлетворяющей установленному порогу качества",
}

locales.zhCN["Frame"] = {
	["bind_on_equip_short"] = "装备后绑定",
	["bind_on_pickup_short"] = "拾取后绑定",
	["bind_on_use_short"] = "使用后绑定",
	["button_close"] = "关闭",
	["button_link"] = "链接",
	["linkall_threshold_missed"] = "没有达到拾取品质门槛的物品",
}

locales.esES["Frame"] = {
}

locales.zhTW["Frame"] = {
	["bind_on_equip_short"] = "裝綁",
	["bind_on_pickup_short"] = "拾榜",
	["bind_on_use_short"] = "使綁",
	["button_close"] = "關閉",
	["button_link"] = "連結",
	["linkall_threshold_missed"] = "沒有達到品質門檻的戰利品",
}


locales.ptBR["Group"] = {
	["alert_anchor"] = "Aparecer Saques",
}

locales.frFR["Group"] = {
}

locales.deDE["Group"] = {
	["alert_anchor"] = "Beute Popups",
	["anchor"] = "Gruppenwürfe",
	["undecided"] = "Unentschlossen",
}

locales.koKR["Group"] = {
	["alert_anchor"] = "전리품 팝업",
	["anchor"] = "그룹 주사위",
	["undecided"] = "미결정",
}

locales.esMX["Group"] = {
	["alert_anchor"] = "Ventanas emergentes de botín",
}

locales.ruRU["Group"] = {
	["alert_anchor"] = "Всплывающие фреймы добычи.",
	["anchor"] = "Броски группы",
	["undecided"] = "Не принял решения",
}

locales.zhCN["Group"] = {
	["alert_anchor"] = "掷骰弹窗锚点",
	["anchor"] = "团队掷骰锚点",
	["undecided"] = "未决定的",
}

locales.esES["Group"] = {
}

locales.zhTW["Group"] = {
	["alert_anchor"] = "拾取彈出視窗定位",
	["anchor"] = "團體擲骰定位",
	["undecided"] = "未決",
}


locales.ptBR["Monitor"] = {
}

locales.frFR["Monitor"] = {
}

locales.deDE["Monitor"] = {
	["anchor"] = "Beutemonitor",
}

locales.koKR["Monitor"] = {
	["anchor"] = "전리품 모니터",
}

locales.esMX["Monitor"] = {
}

locales.ruRU["Monitor"] = {
	["anchor"] = "Монитор добычи",
}

locales.zhCN["Monitor"] = {
	["anchor"] = "掷骰监控",
}

locales.esES["Monitor"] = {
}

locales.zhTW["Monitor"] = {
	["anchor"] = "拾取監控",
}


locales.ptBR["Master"] = {
}

locales.frFR["Master"] = {
}

locales.deDE["Master"] = {
	["BINDING_BANKER"] = "Setze Bankier",
	["BINDING_DISENCHANTER"] = "Setze Entzauberer",
	["ITEM_AWARDED"] = "%s erhielt: %s",
	["ML_BANKER"] = "Bankier",
	["ML_DISENCHANTER"] = "Entzauberer",
	["ML_RANDOM"] = "Schlachtzugswurf",
	["ML_SELF"] = "Eigenständiges Plündern",
	["RECIPIENTS"] = "Spezieller Empfänger",
	["SPECIALROLLS"] = "Spezielle Würfe",
}

locales.koKR["Master"] = {
	["BINDING_BANKER"] = "은행원 설정",
	["BINDING_DISENCHANTER"] = "마법부여사 설정",
	["ITEM_AWARDED"] = "%s |1을;를; 획득했습니다: %s",
	["ML_BANKER"] = "은행인",
	["ML_DISENCHANTER"] = "마법부여사",
	["ML_RANDOM"] = "공격대 주사위",
	["RECIPIENTS"] = "특별 수령인",
	["SPECIALROLLS"] = "특별 주사위",
}

locales.esMX["Master"] = {
}

locales.ruRU["Master"] = {
	["BINDING_BANKER"] = "Назначить банкира",
	["BINDING_DISENCHANTER"] = "Назначить дизенчантера",
	["ITEM_AWARDED"] = "%s получает: %s",
	["ML_BANKER"] = "Банкир",
	["ML_DISENCHANTER"] = "Дизенчантер",
	["ML_RANDOM"] = "Raid Roll",
	["ML_SELF"] = "Своя добыча",
	["RECIPIENTS"] = "Особые получатели",
	["SPECIALROLLS"] = "Особые броски",
}

locales.zhCN["Master"] = {
	["BINDING_BANKER"] = "设置银行存放者",
	["BINDING_DISENCHANTER"] = "设置附魔分解者",
	["ITEM_AWARDED"] = "%s 获得了： %s",
	["ML_BANKER"] = "银行存放者",
	["ML_DISENCHANTER"] = "附魔分解者",
	["ML_RANDOM"] = "团队掷骰",
	["ML_SELF"] = "自己掷骰",
	["RECIPIENTS"] = "特殊接收者",
	["SPECIALROLLS"] = "特殊掷骰",
}

locales.esES["Master"] = {
}

locales.zhTW["Master"] = {
	["BINDING_BANKER"] = "設定存放銀行者",
	["BINDING_DISENCHANTER"] = "設定附魔分解者",
	["ITEM_AWARDED"] = "%s 給與: %s",
	["ML_BANKER"] = "銀行存放者",
	["ML_DISENCHANTER"] = "附魔分解者",
	["ML_RANDOM"] = "團隊擲骰",
	["ML_SELF"] = "自己拾取",
	["RECIPIENTS"] = "特殊接受者",
	["SPECIALROLLS"] = "特殊擲骰",
}


XLoot:Localize("Options", locales)
