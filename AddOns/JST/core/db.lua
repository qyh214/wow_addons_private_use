local T, C, L, G = unpack(select(2, ...))

local Character_default_Settings = {
	FramePoints = {},
	LoadOption = {
		role_enable_tag = "no-rl",
	},
	SettingOption = {
		settings = "character",
		reset_settings = "character",
		reset_role_enable_tag = "no-rl",		
	},
	GeneralOption = {
		role_enable = true,
		disable_all = false,
		disable_sound = false,
		disable_rf = false,
		disable_plate = false,
		mynickname = "",
		nickname_check = false,
		name_format = "nickname",
		sound_pack = "JST_SoundPackCN",
		sound_file = "",
		sound_channel = "Master",
		tts_speaker = 0,
		disable_rmark = false,
		IconMiniMapLeft = 12,
		IconMiniMapTop = -80,
		hide_minimap = false,
		rm = true,
		tl = true,
		tl_use_self = true,
		tl_use_raid = true,
		tl_advance = 60,
		tl_font_size = 18,
		tl_filter_class = true,
		tl_filter_role = true,
		tl_filter_pos = true,
		tl_filter_party = true,
		tl_filter_all = true,
		tl_glowtarget = true,
		tl_bar = true,
		tl_bar_dur = 10,
		tl_sound = true,
		tl_sound_volume = 100,
		tl_sound_dur = 5,
		tl_text = true,
		tl_text_dur = 5,
		tl_text_show_dur = false,
		moving_boss = 0,
		moving_name = true,
		cs = true,
		cs_msg = false,
		cs_sound = "speak",
		group_spell_enable = false,
		group_spell_msg = false,
		group_spell_size = 40,
		group_spell_dir = "LEFT",
		personal_spell_enable = true,
		personal_spell_size = 40,
		personal_spell_dir = "LEFT",
		personal_spell_sound = "none",
		personal_spell_low_hp = true,
		personal_spell_low_hp_value = 30,
		gui_scale = 100,
		raid_pa = true,
		raid_pa_width = 50,
		raid_pa_height = 20,
		raid_pa_fsize = 14,
		raid_pa_icon_num = 2,
		control_spell_enable = true,
		control_always_show = false,
		control_spell_size = 55,
		control_tts = true,
		control_oochide = true,
		control_bossfighthide = true,
		control_assign = true,
		control_spells = {},
	},
	IconAlertOption = {		
		test = false,
		show_spelldur = false,
		icon_size = 65,
		icon_space = 5,
		grow_dir = "RIGHT",
		font_size = 18,
		ifont_size = 12,
		enable_pa = true,
		privateaura_icon_size = 65,
		privateaura_icon_alpha = 1,		
	},	
	TimerbarOption = {
		bar_width = 200,
		bar_height = 25,
	},
	TextAlertOption = {
		font_size = 35,
		font_size_big = 50,
	},	
	PlateAlertOption = {
		size = 25,
		y = 20,
		x = 0,
		interrupt_auto_mark = false,
		interrupt_auto_mark_msg = false,
		interrupt_auto_mark_leader = true,
		interrupt_auto_marks = {
			[1] = false,
			[2] = false,
			[3] = false,
			[4] = false,
			[5] = true,
			[6] = true,
			[7] = true,
			[8] = true,
		},
		interrupt_sound = "interrupt",
		interrupt_sound_cast = "interrupt_cast",
		focus_key_bind = false,
		focus_key_bind_modifier = "shift",
		interrupt_focus_msg = true,
		interrupt_focus_msg_dungeon = true,
		interrupt_focus_textalert = true,
		interrupt_focus_soundalert = true,
		interrupt_only_mine = false,
		interrupt_bar = true,
		interrupt_focus_fliter = true,		
	},
	RFIconOption = {
		RFIcon_size = 25,
		RFIcon_x_offset = 0,
		RFIcon_y_offset = 0,
		
		RFIndex_size = 40,
		RFIndex_color = {r = .49, g = .91, b = 1},
		RFIndex_anchor = "CENTER",
		RFIndex_x_offset = 0,
		RFIndex_y_offset = 0,	
		
		RFValue_size = 12,
		RFValue_color = {r = .94, g = .8, b = .33},
		RFValue_anchor = "BOTTOM",
		RFValue_x_offset = 0,
		RFValue_y_offset = 0,
		
		glow_type = "proc",
		x_offset = 4,
		y_offset = 4,
	},
}

for _, spellID in pairs(G.DungeonCCSpells) do
	Character_default_Settings.GeneralOption.control_spells[spellID] = true
end

local Character_alert_Settings = {}

local LoadNewSettings = function(enable_tag)
	local role_enable_tag = C.DB["LoadOption"]["role_enable_tag"]
	if role_enable_tag == "none" then -- 全部禁用
		return false
	elseif role_enable_tag == "rl" then -- 全部启用
		return true
	elseif enable_tag then -- 有加载标签
		if enable_tag == "rl" then
			return false
		elseif enable_tag == "disable" then
			return false
		else
			return true
		end
	else -- 无标记全部加载
		return true
	end
end

local only_character_keys = {
	["option_list_btn"] = true
}

local InitSettings = function(path, enable_tag, ficon, details)	
	local detail_table = details or {}
	detail_table.enable = LoadNewSettings(enable_tag)
	
	for key, value in pairs(detail_table) do
		local key_path = T.CopyTableInsertElement(path, key)	
		if only_character_keys[key] then
			local DB_setting = T.ValueFromPath(JST_CDB, key_path)
			if DB_setting == nil then
				T.ValueToPath(JST_CDB, key_path, value)
			end
		else
			local DB_setting = T.ValueFromDB(key_path)
			if DB_setting == nil then
				T.ValueToDB(key_path, value)
			end
		end		
	end
end
T.InitSettings = InitSettings

local Update_default_Settings = function()
	Character_alert_Settings = table.wipe(Character_alert_Settings)
	for ENCID, info in pairs(G.Encounters) do
		if info.alerts then
			for section_index, data in pairs(info.alerts) do
				for index, args in pairs(data.options) do
					local category = args.category
					local alert_type = args.type
					if not Character_alert_Settings[category] then
						Character_alert_Settings[category] = {}
					end
					if alert_type and not Character_alert_Settings[category][alert_type] then
						Character_alert_Settings[category][alert_type] = {}
					end
					if category == "BossMod" then
						Character_alert_Settings[category][args.spellID] = {
							enable = LoadNewSettings(args.enable_tag)
						}
						if args.custom then
							for i, t in pairs(args.custom) do -- 细节选项
								Character_alert_Settings[category][args.spellID][t.key] = t.default
							end
						end
					elseif category == "AlertIcon" then
						Character_alert_Settings[category][alert_type][args.spellID] = {
							enable = LoadNewSettings(args.enable_tag)
						}
						if args.sound then
							Character_alert_Settings[category][alert_type][args.spellID].sound_bool = true
						end
						if args.msg then
							Character_alert_Settings[category][alert_type][args.spellID].msg_bool = true		
						end
					elseif category == "AlertTimerbar" then
						Character_alert_Settings[category][alert_type][args.spellID] = {
							enable = LoadNewSettings(args.enable_tag)
						}
						if args.sound then
							Character_alert_Settings[category][alert_type][args.spellID].sound_bool = true
						end
					elseif category == "TextAlert" then	
						if alert_type == "hp" or alert_type == "pp" then
							Character_alert_Settings[category][alert_type][args.data.npc_id] = {
								enable = LoadNewSettings(args.enable_tag)
							}
						else
							Character_alert_Settings[category][alert_type][args.data.spellID] = {
								enable = LoadNewSettings(args.enable_tag)
							}
							if args.data.sound then
								Character_alert_Settings[category][alert_type][args.data.spellID].sound_bool = true
							end
						end
					elseif category == "PlateAlert" then
						if alert_type == "PlatePower" or alert_type == "PlateNpcID" then
							Character_alert_Settings[category][alert_type][args.mobID] = {
								enable = LoadNewSettings(args.enable_tag)
							}
						else
							Character_alert_Settings[category][alert_type][args.spellID] = {
								enable = LoadNewSettings(args.enable_tag)
							}
							if alert_type == "PlateInterrupt" then
								Character_alert_Settings[category][alert_type][args.spellID].interrupt_sl = args.interrupt
							end
						end
					elseif category == "Sound" then
						local sound_type = G.sound_suffix[args.sub_event][1]
						if not Character_alert_Settings[category][sound_type] then
							Character_alert_Settings[category][sound_type] = {}
						end
						Character_alert_Settings[category][sound_type][args.spellID] = {
							enable = LoadNewSettings(args.enable_tag)
						}
					elseif category == "RFIcon" then
						Character_alert_Settings[category][alert_type][args.spellID] = {
							enable = LoadNewSettings(args.enable_tag)
						}
					elseif category == "HPWatch" then
						Character_alert_Settings[category][alert_type][args.spellID] = {
							enable = LoadNewSettings(args.enable_tag)
						}
					end
				end
			end
		end	
	end
end

local LoadSettings
do
	LoadSettings = function(DB, t)
		for k, v in pairs(t) do
			if type(v) ~= "table" then
				if DB[k] == nil then
					DB[k] = v
				end
			else
				if DB[k] == nil then
					DB[k] = {}
				end
				LoadSettings(DB[k], v)
			end
		end
	end
end

local LoadVariables = function()	
	if JST_CDB == nil then
		JST_CDB = {}
	end
	
	LoadSettings(JST_CDB, Character_default_Settings)
end
T.LoadVariables = LoadVariables

local LoadAccountVariables = function()
	if JST_DB == nil then
		JST_DB = {}
	end
	
	if JST_DB.NpcNames == nil then
		JST_DB.NpcNames = {}
	end
	
	if JST_DB.CDB == nil then
		JST_DB.CDB = {}
	end
	
	if JST_DB.CDB then
		for category, data in pairs(Character_default_Settings) do
			if category ~= "SettingOption" then
				if not JST_DB.CDB[category] then
					JST_DB.CDB[category] = {}
				end
				
				for setting, value in pairs(data) do
					if type(value) == "table" then
						if not JST_DB.CDB[category][setting] then
							JST_DB.CDB[category][setting] = {}
						end
						for k, v in pairs(value) do
							if JST_DB.CDB[category][setting][k] == nil then
								JST_DB.CDB[category][setting][k] = v
							end
						end
					else
						if JST_DB.CDB[category][setting] == nil then
							JST_DB.CDB[category][setting] = value
						end
					end
				end
			end
		end
	end
end
T.LoadAccountVariables = LoadAccountVariables

T.CharacterToAccount = function()
	StaticPopupDialogs[G.addon_name.."Reset Confirm"].text = L["确认复制角色配置"]
	StaticPopupDialogs[G.addon_name.."Reset Confirm"].OnAccept = function()
		for category, data in pairs(JST_CDB) do
			if JST_DB.CDB[category] and category ~= "SettingOption" then
				JST_DB.CDB[category] = table.wipe(JST_DB.CDB[category])
				LoadSettings(JST_DB.CDB[category], data)
			end
		end
		JST_CDB["SettingOption"]["settings"] = "account"
		ReloadUI()
	end
	StaticPopup_Show(G.addon_name.."Reset Confirm")
end

T.AccountToCharacter = function()
	StaticPopupDialogs[G.addon_name.."Reset Confirm"].text = L["确认复制账号配置"]
	StaticPopupDialogs[G.addon_name.."Reset Confirm"].OnAccept = function()
		for category, data in pairs(JST_DB.CDB) do
			if JST_CDB[category] and category ~= "SettingOption" then
				JST_CDB[category] = table.wipe(JST_CDB[category])
				LoadSettings(JST_CDB[category], data)
			end
		end
		JST_CDB["SettingOption"]["settings"] = "character"
		ReloadUI()
	end
	StaticPopup_Show(G.addon_name.."Reset Confirm")
end

local ValueToString = T.ValueToString
local StringToValue = T.StringToValue

T.ExportSettings = function()
	local str = G.addon_name.." Export".."~"..G.Version
	
	for OptionCategroy, OptionTable in pairs(Character_default_Settings) do
		if string.find(OptionCategroy, "Option") then
			for setting, value in pairs(OptionTable) do
				if type(value) == "table" then
					for k, v in pairs(value) do
						local db_value = JST_CDB[OptionCategroy][setting][k]
						if db_value ~= v then
							str = str.."^"..OptionCategroy.."~"..setting.."~"..ValueToString(k).."~"..ValueToString(db_value)
						end
					end
				else
					local db_value = JST_CDB[OptionCategroy][setting]
					if db_value ~= value then
						str = str.."^"..OptionCategroy.."~"..setting.."~"..ValueToString(db_value)
					end
				end
			end
		end	
	end
	
	for frame_name, info in pairs(JST_CDB["FramePoints"]) do
		local frame = _G[frame_name]
		if frame and frame.point then
			for key, value in pairs(info) do
				if value ~= frame.point[key] then
					str = str.."^FramePoints~"..frame_name.."~"..key.."~"..value
				end
			end
		end
	end
	
	Update_default_Settings()
	
	for OptionCategroy, OptionTable in pairs(Character_alert_Settings) do
		if OptionCategroy == "BossMod" then -- no sub type
			for frame_key, info in pairs(OptionTable) do
				for setting, value in pairs(info) do
					if T.ValueFromPath(JST_CDB, {OptionCategroy, frame_key, setting}) then
						local db_value = JST_CDB[OptionCategroy][frame_key][setting]
						if db_value ~= value then
							if setting == "option_list_btn" then
								for index, data in pairs(db_value) do
									for key, v in pairs(data) do
										if key == "spec_info" then
											for specID, a in pairs(v) do
												str = str.."^"..OptionCategroy.."~"..ValueToString(frame_key).."~"..setting.."~"..ValueToString(index).."~"..key.."~"..ValueToString(specID).."~"..ValueToString(a)
											end
										else
											str = str.."^"..OptionCategroy.."~"..ValueToString(frame_key).."~"..setting.."~"..ValueToString(index).."~"..key.."~"..ValueToString(v)
										end
									end
								end
							else
								str = str.."^"..OptionCategroy.."~"..ValueToString(frame_key).."~"..setting.."~"..ValueToString(db_value)
							end
						end
					end
				end
			end
		else -- with sub type
			for subCategroy, data in pairs(OptionTable) do
				for frame_key, info in pairs(data) do
					for setting, value in pairs(info) do
						if T.ValueFromPath(JST_CDB, {OptionCategroy, subCategroy, frame_key, setting}) then
							local db_value = JST_CDB[OptionCategroy][subCategroy][frame_key][setting]
							if db_value ~= value then		
								str = str.."^"..OptionCategroy.."~"..subCategroy.."~"..ValueToString(frame_key).."~"..setting.."~"..ValueToString(db_value)
							end
						end
					end
				end
			end
		end
	end
	
	return str
end

T.ImportSettings = function(str)
	local optionlines = strsplittable("^", str)
	local addon_name, version = string.split("~", optionlines[1])
	local sameversion
	
	if addon_name ~= G.addon_name.." Export" then
		StaticPopup_Show(G.addon_name.."Cannot Import")
	else
		local import_str = ""
		if version ~= G.Version then
			import_str = import_str..format(L["版本不符合"], version, G.Version)
		else
			sameversion = true
		end
		
		if not sameversion then
			import_str = import_str..L["不完整导入"]
		end
		
		StaticPopupDialogs[G.addon_name.."Import Confirm"].text = format(L["导入确认"]..import_str, G.addon_name)
		StaticPopupDialogs[G.addon_name.."Import Confirm"].OnAccept = function()
			JST_CDB = table.wipe(JST_CDB)
			LoadSettings(JST_CDB, Character_default_Settings)	
			Update_default_Settings()
			LoadSettings(JST_CDB, Character_alert_Settings)
			
			for index, v in pairs(optionlines) do
				if index ~= 1 then
					local path = strsplittable("~", v)
					for i, key in pairs(path) do
						path[i] = StringToValue(key)
					end
					local value = table.remove(path)
					if path[1] ~= "Account_Settings" then
						T.ValueToPath(JST_CDB, path, value)
					end
				end
			end
			
			ReloadUI()
		end
		StaticPopup_Show(G.addon_name.."Import Confirm")
	end
end