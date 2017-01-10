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
			linkall_show = "Link button visibility",

			autolooting_text = "XLoot's autolooting features act separately from the default UI. As such, if both are enabled, you may recieve warnings like 'that object is busy'. They are safe to ignore, but can be resolved by picking one autoloot method to use exclusively.",

			autolooting_list = "To automatically loot specific items, list them below.\n  Example: Linen Cloth,Ashbringer,Copper Ore",

			autolooting_details = "XLoot will choose the highest setting when deciding to loot a slot. This allows, for example, auto looting everything while solo yet only quest items and money while in a group.",
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
			name_width = "Player name width",
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
		scale = "Scale",
		width = "Width",
		alpha = "Opacity",
		spacing = "Spacing",
		offset = "Offset",
		visible = "Visible",
		items_others = "Others' items",
		items_own = "Own items",
		up = "Up",
		down = "Down",
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
locales.deDE["alpha"] = "Transparenz"
locales.deDE["confirm_reset_profile"] = "Dies wird alle Einstellungen für dieses Profil auf den Standard zurücksetzen. Bist du sicher?"
locales.deDE["desc_channel_auto"] = "Höchste Verfügbare"
locales.deDE["down"] = "Ab"
locales.deDE["font"] = "Schriftart"
locales.deDE["font_size_loot"] = "Beute"
locales.deDE["font_size_quantity"] = "Menge"
locales.deDE["font_sizes"] = "Größen"
locales.deDE["growth_direction"] = "Wachstumsrichtung"
locales.deDE["items_others"] = "Gegenstand anderer"
locales.deDE["items_own"] = "Eigene Gegenstände"
locales.deDE["minimum_quality"] = "Minimale Qualität"
locales.deDE["profile"] = "Profil"
locales.deDE["scale"] = "Skalierung"
locales.deDE["up"] = "Hoch"
locales.deDE["visible"] = "Sichtbar"
locales.deDE["when_always"] = "Immer"
locales.deDE["when_auto"] = "Automatisch"
locales.deDE["when_group"] = "In Gruppe"
locales.deDE["when_never"] = "Niemals"
locales.deDE["when_party"] = "In Gruppen"
locales.deDE["when_raid"] = "In Schlachtzügen"
locales.deDE["when_solo"] = "Solo"
locales.deDE["width"] = "Breite"
locales.koKR["alpha"] = "투명도"
locales.koKR["confirm_reset_profile"] = "이 프로필에 대한 모든 옵션을 초기화합니다. 계속할까요?"
locales.koKR["down"] = "아래"
locales.koKR["font"] = "글꼴"
locales.koKR["font_size_loot"] = "전리품"
locales.koKR["font_size_quantity"] = "수량"
locales.koKR["font_sizes"] = "크기"
locales.koKR["growth_direction"] = "성장 방향"
locales.koKR["items_others"] = "기타 아이템"
locales.koKR["items_own"] = "내 아이템"
locales.koKR["minimum_quality"] = "최소 품질"
locales.koKR["profile"] = "프로필"
locales.koKR["scale"] = "크기"
locales.koKR["up"] = "위"
locales.koKR["visible"] = "보기"
locales.koKR["when_always"] = "항상"
locales.koKR["when_auto"] = "자동"
locales.koKR["when_group"] = "그룹에서"
locales.koKR["when_never"] = "안함"
locales.koKR["when_party"] = "파티에서"
locales.koKR["when_raid"] = "공격대에서"
locales.koKR["when_solo"] = "혼자일 때"
locales.koKR["width"] = "너비"
locales.ruRU["alpha"] = "Прозрачность"
locales.ruRU["confirm_reset_profile"] = "Это сбросит все параметры этого профиля. Вы уверены?"
locales.ruRU["desc_channel_auto"] = "Наивысший из доступных"
locales.ruRU["down"] = "Вниз"
locales.ruRU["font"] = "Шрифт "
locales.ruRU["font_flag"] = "Флажок"
locales.ruRU["font_size_loot"] = "Добыча "
locales.ruRU["font_size_quantity"] = "Количество "
locales.ruRU["font_sizes"] = "Размеры "
locales.ruRU["growth_direction"] = "Добавлять новые строки"
locales.ruRU["items_others"] = "Остальные вещи"
locales.ruRU["items_own"] = "Ваши вещи"
locales.ruRU["minimum_quality"] = "Минимальное качество"
locales.ruRU["profile"] = "Профиль"
locales.ruRU["scale"] = "Масштаб"
locales.ruRU["up"] = "Вверх"
locales.ruRU["visible"] = "Видимый"
locales.ruRU["when_always"] = "Всегда"
locales.ruRU["when_auto"] = "Автоматически"
locales.ruRU["when_group"] = "В группе "
locales.ruRU["when_never"] = "Никогда"
locales.ruRU["when_party"] = "В группе "
locales.ruRU["when_raid"] = "В рейде "
locales.ruRU["when_solo"] = "Соло"
locales.ruRU["width"] = "Ширина"
locales.zhCN["alpha"] = "透明度"
locales.zhCN["confirm_reset_profile"] = "这将重置此配置文件的全部选项。确定？"
locales.zhCN["desc_channel_auto"] = "最高可得"
locales.zhCN["down"] = "下"
locales.zhCN["font"] = "字体"
locales.zhCN["font_flag"] = "轮廓"
locales.zhCN["font_size_loot"] = "战利品"
locales.zhCN["font_size_quantity"] = "品质"
locales.zhCN["font_sizes"] = "大小"
locales.zhCN["growth_direction"] = "扩展方向"
locales.zhCN["items_others"] = "其他人的物品"
locales.zhCN["items_own"] = "自己的物品"
locales.zhCN["minimum_quality"] = "最低品质"
locales.zhCN["profile"] = "配置文件"
locales.zhCN["scale"] = "比例"
locales.zhCN["up"] = "上"
locales.zhCN["visible"] = "可见"
locales.zhCN["when_always"] = "总是"
locales.zhCN["when_auto"] = "自动"
locales.zhCN["when_group"] = "在队伍/团队中"
locales.zhCN["when_never"] = "从不"
locales.zhCN["when_party"] = "在队伍中"
locales.zhCN["when_raid"] = "在团队中"
locales.zhCN["when_solo"] = "单人"
locales.zhCN["width"] = "宽度"
locales.esES["confirm_reset_profile"] = "Esto reseteará todas las opciones de este perfil. ¿Estás seguro?"
locales.esES["font"] = "Fuente"
locales.esES["font_size_loot"] = "Botín"
locales.esES["font_size_quantity"] = "Cantidad"
locales.esES["font_sizes"] = "Tamaños"
locales.esES["profile"] = "Perfil"
locales.esES["when_always"] = "Siempre"
locales.esES["when_auto"] = "Automático"
locales.esES["when_never"] = "Nunca"
locales.esES["when_solo"] = "Solo"
locales.zhTW["alpha"] = "透明度"
locales.zhTW["confirm_reset_profile"] = "將會重置此設定檔的所有設定。你確定要重置嗎？"
locales.zhTW["desc_channel_auto"] = "最高可得"
locales.zhTW["down"] = "下"
locales.zhTW["font"] = "字型"
locales.zhTW["font_flag"] = "標示"
locales.zhTW["font_size_loot"] = "戰利品"
locales.zhTW["font_size_quantity"] = "品質"
locales.zhTW["font_sizes"] = "大小"
locales.zhTW["growth_direction"] = "擴展方向"
locales.zhTW["items_others"] = "他人物品"
locales.zhTW["items_own"] = "自己物品"
locales.zhTW["minimum_quality"] = "最低品質"
locales.zhTW["profile"] = "設定檔"
locales.zhTW["scale"] = "比例"
locales.zhTW["up"] = "上"
locales.zhTW["visible"] = "可見"
locales.zhTW["when_always"] = "總是"
locales.zhTW["when_auto"] = "自動"
locales.zhTW["when_group"] = "隊伍/團隊中"
locales.zhTW["when_never"] = "從不"
locales.zhTW["when_party"] = "隊伍中"
locales.zhTW["when_raid"] = "團隊中"
locales.zhTW["when_solo"] = "單人"
locales.zhTW["width"] = "寬度"

XLoot:Localize("Options", locales)
