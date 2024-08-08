local addon_name, addon = ...
local config = addon.new_module("config")

-- ---------------------------------------------------------------------------------------------------------------------
local config_gui
local main

local default_npc_progress_sl

-- ---------------------------------------------------------------------------------------------------------------------
local CONFIG_VALUES = {
  -- options
  objective_time = true,
  objective_time_perlevel = false,
  objective_time_perlevelaffix = true,
  objective_time_perrun = false,
  objective_time_delta_only = false,
  objective_time_inchat = true,
  show_deathcounter = true,
  progress_tooltip = true,
  show_percent_numbers = true,
  show_absolute_numbers = false,
  show_enemy_forces_bar = false,
  insert_keystone = true,
  show_affixes_as_text = true,
  show_affixes_as_icons = false,
  hide_default_objectivetracker = true,
  scale = 1.0,
  show_pull_values = false,
  --
  position = {left = -260, top = 220, relative_point = "RIGHT"},
  align_right = false,
  --
  color_dungeon_name = "FFFFD100",
  color_affixes = "FFFFFFFF",
  color_timeleft = "FF00FF00",
  color_timeleft_expired = "FFFF0000",
  color_time = "FFFFFFFF",
  color_chest_timeleft = "FF00FF00",
  color_chest_time = "FFFFFFFF",
  color_chest_time_expired = "FF808080",
  color_objective = "FFFFFFFF",
  color_objective_completed = "FF808080",
  color_objective_completed_time = "FF808080",
  color_current_pull = "FF00FF00",
  color_deathcounter = "FFFFFFFF",
  color_deathcounter_timelost = "FFFF0000",
}

-- ---------------------------------------------------------------------------------------------------------------------
-- Options category
local category
local category_colors

-- ---------------------------------------------------------------------------------------------------------------------
local function on_button_click(button)
  local button_name = button.button_name

  if button_name == "delete_besttimes" then
    addon.set_config_value("best_times", {})
    addon.set_config_value("best_runs", {})
  elseif button_name == "delete_npcprogress" then
    addon.set_config_value("npc_progress", {})
    addon.set_config_value("npc_progress_teeming", {})
  elseif button_name == "reset_scale" then
    addon.set_config_value("scale", CONFIG_VALUES.scale)
    addon.set_config_value("position", CONFIG_VALUES.position)
    ReloadUI()
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
local function export_data()
  local npc_progress = addon.c("npc_progress")
  if not npc_progress then
    addon.print("no data found")
    return
  end

  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetPoint("CENTER", 0, 0)
  frame:SetWidth(300)
  frame:SetHeight(100)

  local data = "{"
  for npc_id, _ in pairs(npc_progress) do
    local value, occurrences = nil, -1
    for val, val_occurrences in pairs(npc_progress[npc_id]) do
      if val_occurrences > occurrences then
        value, occurrences = val, val_occurrences
      end
    end

    data = data .. "[" .. npc_id .. "]={[" .. value .. "]=1},"
  end
  data = data .. "}"

  local f = CreateFrame("EditBox", "MPTExport", frame, "InputBoxTemplate")
  f:SetSize(300, 50)
  f:SetPoint("CENTER", 0, 0)
  f:SetScript("OnEnterPressed", frame.Hide)
  f:SetText(data)

  frame:Show()
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_category_default()
  MythicPlusTimerDB.config = CONFIG_VALUES
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_category_colors_default()
  local colors = {
    "color_dungeon_name",
    "color_affixes",
    "color_timeleft",
    "color_timeleft_expired",
    "color_time",
    "color_chest_timeleft",
    "color_chest_time",
    "color_chest_time_expired",
    "color_objective",
    "color_objective_completed",
    "color_objective_completed_time",
    "color_current_pull",
    "color_deathcounter",
    "color_deathcounter_timelost",
  }

  for _, key in ipairs(colors) do
    MythicPlusTimerDB.config[key] = CONFIG_VALUES[key]
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
local category_initialized = false
local unlock_checkbox

local function on_category_refresh(self)
  if category_initialized then
    unlock_checkbox.checkbox:SetChecked(main.is_frame_moveable())
    return
  end
  category_initialized = true

  local frame = CreateFrame("ScrollFrame", nil, self, "UIPanelScrollFrameTemplate")
  frame:SetPoint("TOPLEFT", 3, -4)
  frame:SetPoint("BOTTOMRIGHT", -27, 4)

  local container = CreateFrame("Frame")
  frame:SetScrollChild(container)
  container:SetWidth(SettingsPanel.Container:GetWidth()-25)
  container:SetHeight(1) 

  local name = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  local font_path, _, font_flags = name:GetFont()
  name:SetFont(font_path, 16, font_flags)
  name:SetPoint("TOPLEFT", 10, -16)
  name:SetText(addon_name)

  -- unlock checkbox
  local unlock_name = addon.t("config_unlock_frame")

  local tooltip = {}
  table.insert(tooltip, unlock_name)
  table.insert(tooltip, "|cFFFFFFFF" .. addon.t("config_desc_unlock_frame"))

  unlock_checkbox = config_gui.create_checkbox("unlock_frame", unlock_name, addon.c(key), function(config_key, checked)
    main.toggle_frame_movement()
  end, tooltip, container)
  
  unlock_checkbox:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -5)
  unlock_checkbox.checkbox:SetChecked(main.is_frame_moveable())

  -- general
  local general = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  local font_path, _, font_flags = general:GetFont()
  general:SetFont(font_path, 12, font_flags)
  general:SetPoint("TOPLEFT", unlock_checkbox, "BOTTOMLEFT", 0, -10)
  general:SetText(addon.t("config_general"))

  local checkboxes_general = {
    "insert_keystone",
   "progress_tooltip", 
    "objective_time_inchat",
  }

  local checkboxes_general_frames = {}
  local checkboxes_general_frames_bykey = {}
  for i, key in ipairs(checkboxes_general) do
    local config_name = addon.t("config_" .. key)

    local tooltip = {}
    table.insert(tooltip, config_name)
    table.insert(tooltip, "|cFFFFFFFF" .. addon.t("config_desc_" .. key))

    local checkbox = config_gui.create_checkbox(key, config_name, addon.c(key), function(config_key, checked)
      local current_run = main.get_current_run()
      if current_run and current_run.is_completed then
        main.show_demo()
      end

      addon.set_config_value(config_key, checked)
    end, tooltip, container)

    if i == 1 then
      checkbox:SetPoint("TOPLEFT", general, "BOTTOMLEFT", 0, -5)
    else
      checkbox:SetPoint("TOPLEFT", checkboxes_general_frames[i - 1], "BOTTOMLEFT", 0, 0)
    end

    checkboxes_general_frames[i] = checkbox
    checkboxes_general_frames_bykey[key] = checkbox
  end


  -- position
  local position = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  local font_path, _, font_flags = position:GetFont()
  position:SetFont(font_path, 12, font_flags)
  position:SetPoint("TOPLEFT", checkboxes_general_frames[#checkboxes_general_frames], "BOTTOMLEFT", 0, -10)
  position:SetText(addon.t("config_position"))

  local checkboxes_position = {
    "hide_default_objectivetracker",
    "align_right"
  }

  local checkboxes_position_frames = {}
  local checkboxes_position_frames_bykey = {}
  for i, key in ipairs(checkboxes_position) do
    local config_name = addon.t("config_" .. key)

    local tooltip = {}
    table.insert(tooltip, config_name)
    table.insert(tooltip, "|cFFFFFFFF" .. addon.t("config_desc_" .. key))

    local checkbox = config_gui.create_checkbox(key, config_name, addon.c(key), function(config_key, checked)
      local current_run = main.get_current_run()
      if current_run and current_run.is_completed then
        main.show_demo()
      end
      addon.set_config_value(config_key, checked)

      if config_key == "align_right" then
        ReloadUI()
      end
    end, tooltip, container)

    if i == 1 then
      checkbox:SetPoint("TOPLEFT", position, "BOTTOMLEFT", 0, -5)
    else
      checkbox:SetPoint("TOPLEFT", checkboxes_position_frames[i - 1], "BOTTOMLEFT", 0, 0)
    end

    checkboxes_position_frames[i] = checkbox
    checkboxes_position_frames_bykey[key] = checkbox
  end

  -- - scale slider
  local slider_tooltip = {}
  table.insert(slider_tooltip, addon.t("config_scale"))
  table.insert(slider_tooltip, "|cFFFFFFFF" .. addon.t("config_desc_scale"))

  local slider = config_gui.create_slider(addon.t("config_scale"), function(val)
    addon.set_config_value("scale", val)
  end, 0.5, 3, 0.1, addon.c("scale"), slider_tooltip, container)

  slider:SetPoint("TOPLEFT", checkboxes_position_frames[#checkboxes_position_frames], "BOTTOMLEFT", 0, -10)

  local scale_reset_button_name = addon.t("config_reset_scale")

  local tooltip = {}
  table.insert(tooltip, scale_reset_button_name)
  table.insert(tooltip, "|cFFFFFFFF" .. addon.t("config_desc_reset_scale"))

  local scale_reset_button = config_gui.create_button("reset_scale", scale_reset_button_name, on_button_click, tooltip, container)
  scale_reset_button:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -3)
  scale_reset_button:SetWidth(scale_reset_button.Text:GetStringWidth() + 30)

  -- data
  local data = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  local font_path, _, font_flags = data:GetFont()
  data:SetFont(font_path, 12, font_flags)
  data:SetPoint("TOPLEFT", scale_reset_button, "BOTTOMLEFT", 0, -10)
  data:SetText(addon.t("config_data"))

  local checkboxes_data = {
    "objective_time",
    "objective_time_perlevel",
    "objective_time_perlevelaffix",
    "objective_time_perrun",
    "objective_time_delta_only",

    "__separator__",

    "show_pull_values",      
    -- "show_percent_numbers",   -- :OnlyPercentValue
    -- "show_absolute_numbers",  -- :OnlyPercentValue

    "__separator__",  
    
    "show_affixes_as_text",
    "show_affixes_as_icons",
    "show_enemy_forces_bar",
  }

  local checkboxes_data_frames = {}
  local checkboxes_data_frames_bykey = {}
  local checkbox_margin_top = 0
  local i = 0
  for _, key in ipairs(checkboxes_data) do
    if key == "__separator__" then
      checkbox_margin_top = -15
    else 
      i = i + 1
      local config_name = addon.t("config_" .. key)

      local tooltip = {}
      table.insert(tooltip, config_name)
      table.insert(tooltip, "|cFFFFFFFF" .. addon.t("config_desc_" .. key))

      local checkbox = config_gui.create_checkbox(key, config_name, addon.c(key), function(config_key, checked)
        local current_run = main.get_current_run()
        if current_run and current_run.is_completed then
          main.show_demo()
        end

        if config_key == "objective_time_perlevel" and checked then
          addon.set_config_value("objective_time_perlevelaffix", false)
          checkboxes_data_frames_bykey["objective_time_perlevelaffix"].checkbox:SetChecked(false)

          addon.set_config_value("objective_time_perrun", false)
          checkboxes_data_frames_bykey["objective_time_perrun"].checkbox:SetChecked(false)
        end

        if config_key == "objective_time_perlevelaffix" and checked then
          addon.set_config_value("objective_time_perlevel", false)
          checkboxes_data_frames_bykey["objective_time_perlevel"].checkbox:SetChecked(false)

          addon.set_config_value("objective_time_perrun", false)
          checkboxes_data_frames_bykey["objective_time_perrun"].checkbox:SetChecked(false)
        end

        if config_key == "objective_time_perrun" and checked then
          addon.set_config_value("objective_time_perlevel", false)
          checkboxes_data_frames_bykey["objective_time_perlevel"].checkbox:SetChecked(false)

          addon.set_config_value("objective_time_perlevelaffix", false)
          checkboxes_data_frames_bykey["objective_time_perlevelaffix"].checkbox:SetChecked(false)
        end

        if config_key == "show_percent_numbers" and not checked and not addon.c("show_absolute_numbers") then
          addon.set_config_value("show_absolute_numbers", true)
          checkboxes_data_frames_bykey["show_absolute_numbers"].checkbox:SetChecked(true)
        end

        if config_key == "show_absolute_numbers" and not checked and not addon.c("show_percent_numbers") then
          addon.set_config_value("show_percent_numbers", true)
          checkboxes_data_frames_bykey["show_percent_numbers"].checkbox:SetChecked(true)
        end

        addon.set_config_value(config_key, checked)
      end, tooltip, container)

      if i == 1 then
        checkbox:SetPoint("TOPLEFT", data, "BOTTOMLEFT", 0, -5)
      else
        checkbox:SetPoint("TOPLEFT", checkboxes_data_frames[i - 1], "BOTTOMLEFT", 0, checkbox_margin_top)
        checkbox_margin_top = 0
      end

      checkboxes_data_frames[i] = checkbox
      checkboxes_data_frames_bykey[key] = checkbox
    end
  end

  -- infos
  local infos = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  local font_path, _, font_flags = infos:GetFont()
  infos:SetFont(font_path, 12, font_flags)
  infos:SetPoint("TOPLEFT", checkboxes_data_frames[#checkboxes_data_frames], "BOTTOMLEFT", 0, -10)
  infos:SetText(addon.t("config_information"))

  local checkboxes_infos = {
    "show_deathcounter",
  }

  local checkboxes_infos_frames = {}
  local checkboxes_infos_frames_bykey = {}
  local checkbox_margin_top = 0
  local i = 0
  for i, key in ipairs(checkboxes_infos) do
    local config_name = addon.t("config_" .. key)

    local tooltip = {}
    table.insert(tooltip, config_name)
    table.insert(tooltip, "|cFFFFFFFF" .. addon.t("config_desc_" .. key))

    local checkbox = config_gui.create_checkbox(key, config_name, addon.c(key), function(config_key, checked)
      local current_run = main.get_current_run()
      if current_run and current_run.is_completed then
        main.show_demo()
      end

      addon.set_config_value(config_key, checked)
    end, tooltip, container)

    if i == 1 then
      checkbox:SetPoint("TOPLEFT", infos, "BOTTOMLEFT", 0, -5)
    else
      checkbox:SetPoint("TOPLEFT", checkboxes_infos_frames[i - 1], "BOTTOMLEFT", 0, checkbox_margin_top)
      checkbox_margin_top = 0
    end

    checkboxes_infos_frames[i] = checkbox
    checkboxes_infos_frames_bykey[key] = checkbox
  end
  
  -- line
  local line = config_gui.create_line(container)
  line:SetPoint("TOPLEFT", checkboxes_infos_frames[#checkboxes_infos_frames], "BOTTOMLEFT", 0, -3)

  -- scary buttons
  local scary_buttons = {"delete_besttimes", "delete_npcprogress"}

  local scary_buttons_frames = {}
  for i, key in ipairs(scary_buttons) do
    local button_name = addon.t("config_" .. key)

    local tooltip = {}
    table.insert(tooltip, button_name)
    table.insert(tooltip, "|cFFFFFFFF" .. addon.t("config_desc_" .. key))

    local button = config_gui.create_button(key, button_name, on_button_click, tooltip, container)
    if i == 1 then
      button:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 0, -3)
    else
      button:SetPoint("TOPLEFT", scary_buttons_frames[i - 1], "BOTTOMLEFT", 0, -3)
    end

    button:SetPoint("RIGHT", -10, 0)

    scary_buttons_frames[i] = button
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
local category_colors_initialized = false

local function on_category_colors_refresh(self)
  if category_colors_initialized then
    return
  end
  category_colors_initialized = true

  local name = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  local font_path, _, font_flags = name:GetFont()
  name:SetFont(font_path, 16, font_flags)
  name:SetPoint("TOPLEFT", 10, -16)
  name:SetText(addon_name .. " - " .. addon.t("lbl_colors"))

  -- colors
  local colors = {
    "color_dungeon_name",
    "color_affixes",
    "_line",
    "color_timeleft",
    "color_timeleft_expired",
    "color_time",
    "_line",
    "color_chest_timeleft",
    "color_chest_time",
    "color_chest_time_expired",
    "_line",
    "color_objective",
    "color_objective_completed",
    "color_objective_completed_time",
    "color_current_pull",
    "_line",
    "color_deathcounter",
    "color_deathcounter_timelost",
    -- "_line",
  }

  local colors_frames = {}
  local colors_frames_bykey = {}
  for i, key in ipairs(colors) do
    if key == "_line" then
      local line = config_gui.create_line(self, 6)
      line:SetPoint("TOPLEFT", colors_frames[i - 1], "BOTTOMLEFT", 0, -3)
      colors_frames[i] = line
    else
      local config_name = addon.t("config_" .. key)

      local tooltip = {}
      table.insert(tooltip, config_name)
      table.insert(tooltip, "|cFFFFFFFF" .. addon.t("config_desc_" .. key))

      local picker = config_gui.create_color_picker(key, config_name, addon.c(key), false, function(config_key, color)
        local current_run = main.get_current_run()
        if current_run and current_run.is_completed then
          main.show_demo()
        end

        addon.set_config_value(config_key, color)
      end, tooltip, self)

      if i == 1 then
        picker:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -5)
      else
        picker:SetPoint("TOPLEFT", colors_frames[i - 1], "BOTTOMLEFT", 0, 0)
      end

      colors_frames[i] = picker
      colors_frames_bykey[key] = picker
    end
  end

  -- line
  local line = config_gui.create_line(self)
  line:SetPoint("TOPLEFT", colors_frames[#colors_frames], "BOTTOMLEFT", 0, -3)

  -- reset button
  local tooltip = {}
  table.insert(tooltip, addon.t("config_colorsresetbtn"))
  table.insert(tooltip, "|cFFFFFFFF" .. addon.t("config_desc_" .. "colorsresetbtn"))

  local button = config_gui.create_button("colorsresetbtn", addon.t("config_colorsresetbtn"), function()
    on_category_colors_default()
    ReloadUI()
  end, tooltip, self)

  button:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 0, -3)
  button:SetPoint("RIGHT", -10, 0)
end

-- ---------------------------------------------------------------------------------------------------------------------
local function create_options_category()
  -- main
  local frame = CreateFrame("Frame")
  frame.name = addon_name
  frame.OnDefault = on_category_default
  frame.OnRefresh = on_category_refresh

  local settings_category, _ = Settings.RegisterCanvasLayoutCategory(frame, frame.name)
  settings_category.ID = frame.name
	Settings.RegisterAddOnCategory(settings_category)
  category = settings_category

  -- colors
  local frame_colors = CreateFrame("Frame")
  frame_colors.name = addon.t("lbl_colors")
  frame_colors.parent = category.name
  frame_colors.OnDefault = on_category_colors_default
  frame_colors.OnRefresh = on_category_colors_refresh

  local settings_category_colors, _ = Settings.RegisterCanvasLayoutSubcategory(category, frame_colors, frame_colors.name)
  settings_category_colors.ID = frame_colors.name
  Settings.RegisterAddOnCategory(settings_category_colors)
  category_colors = settings_category_colors
end

-- ---------------------------------------------------------------------------------------------------------------------
local function print_debug_table(data, table, prefix)
  if not prefix then
    prefix = ""
  end

  for k, v in pairs(table) do
    if type(v) == "table" then
      -- addon.print(k)
      data = data .. prefix .. k .. "\n"
      data = print_debug_table(data, v, prefix .. "- ")
    else
      data = data .. prefix .. k .. ": " .. tostring(v) .. "\n"
      -- addon.print(prefix .. k .. ": " .. tostring(v))
    end
  end

  return data
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Slash Commands
local function on_slash_command(msg)
  -- toggle
  if msg == "toggle" then
    main.toggle_frame_movement()
    return
  end

  -- config
  if msg == "config" then
    if not category then
      return
    end

    InterfaceOptionsFrame_OpenToCategory(category)
    InterfaceOptionsFrame_OpenToCategory(category)
    return
  end

  -- export
  if msg == "export" then
    export_data()
    return
  end

  -- debug
  if msg == "debug" then
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetPoint("CENTER", 0, 0)
    frame:SetWidth(300)
    frame:SetHeight(100)

    local data = ""

    data = data .. "BEST RUNS\n"
    local best_runs = addon.c("best_runs")
    data = print_debug_table(data, best_runs)

    data = data .. "BEST TIMES\n"
    local best_times = addon.c("best_times")
    data = print_debug_table(data, best_times)

    local current_run = main.get_current_run()
    if current_run then
      data = data .. "CURRENT RUN\n"
      data = print_debug_table(data, current_run)
    end

    local f = CreateFrame("EditBox", "MPTExport", frame, "InputBoxTemplate")
    f:SetSize(300, 100)
    f:SetPoint("CENTER", 0, 0)
    f:SetScript("OnEnterPressed", frame.Hide)
    f:SetText(data)
    return
  end

  -- help
  addon.print("/mpt toggle|cCCCCCCCC: " .. addon.t("lbl_togglecommandtext"))
  addon.print("/mpt config|cCCCCCCCC: " .. addon.t("lbl_configcommandtext"))
end

SLASH_MYTHICPLUSTIMER1 = "/mpt"
SLASH_MYTHICPLUSTIMER2 = "/mythicplustimer"
SlashCmdList["MYTHICPLUSTIMER"] = on_slash_command

-- ---------------------------------------------------------------------------------------------------------------------
function config.update_unlock_checkbox()
  if not unlock_checkbox then
    return
  end

  unlock_checkbox.checkbox:SetChecked(main.is_frame_moveable())
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Init
function config:init()
  config_gui = addon.get_module("config_gui")
  main = addon.get_module("main")

  -- config values
  if MythicPlusTimerDB == nil then
    MythicPlusTimerDB = {}
  end

  if not MythicPlusTimerDB.config then
    MythicPlusTimerDB.config = CONFIG_VALUES
  end

  for key, value in pairs(CONFIG_VALUES) do
    if MythicPlusTimerDB.config[key] == nil then
      -- set default
      MythicPlusTimerDB.config[key] = value

      -- set object time per level and affixes as default
      if key == "objective_time_perlevelaffix" then
        MythicPlusTimerDB.config["objective_time_perlevel"] = false
      end

      -- if show_absolute_numbers set default from 2.x values
      if key == "show_absolute_numbers" and MythicPlusTimerDB.config.showAbsoluteNumbers then
        MythicPlusTimerDB.config[key] = MythicPlusTimerDB.config.showAbsoluteNumbers
      end
    end
  end

  -- add data from 2.x
  if MythicPlusTimerDB.config["best_times"] == nil and MythicPlusTimerDB["bestTimes"] ~= nil then
    MythicPlusTimerDB.config["best_times"] = MythicPlusTimerDB["bestTimes"]
    MythicPlusTimerDB["bestTimes"] = nil
  end

  if MythicPlusTimerDB.config["npc_progress"] == nil and MythicPlusTimerDB["npcProgress"] ~= nil then
    MythicPlusTimerDB.config["npc_progress"] = MythicPlusTimerDB["npcProgress"]
    MythicPlusTimerDB["npcProgress"] = nil
  end

  if MythicPlusTimerDB["pos"] ~= nil and MythicPlusTimerDB["pos"].left ~= nil and MythicPlusTimerDB["pos"].top ~= nil and MythicPlusTimerDB["pos"].relativePoint ~= nil then
    MythicPlusTimerDB.config["position"] = {
      left = MythicPlusTimerDB["pos"].left,
      top = MythicPlusTimerDB["pos"].top,
      relative_point = MythicPlusTimerDB["pos"].relativePoint,
    }
    MythicPlusTimerDB["pos"] = nil
  end

  -- set default progress values
  if MythicPlusTimerDB.config["npc_progress"] == nil then
    MythicPlusTimerDB.config["npc_progress"] = default_npc_progress_sl
    MythicPlusTimerDB.config["npc_progress_id"] = "sl_1"
  end

  if MythicPlusTimerDB.config["npc_progress_id"] ~= "sl_1" then
    MythicPlusTimerDB.config["npc_progress_id"] = "sl_1"

    for k, v in pairs(default_npc_progress_sl) do
      MythicPlusTimerDB.config["npc_progress"][k] = v
    end
  end

  -- set config
  addon.set_config(MythicPlusTimerDB.config)

  -- options category
  create_options_category()
end

-- ---------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------
default_npc_progress_sl = {}
