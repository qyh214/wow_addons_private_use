local _, addon = ...
local criteria = addon.new_module("criteria")

-- ---------------------------------------------------------------------------------------------------------------------
local main
local timer
local infos

-- ---------------------------------------------------------------------------------------------------------------------
local step_frames = {}
local enemy_forces_bar
local red_color_base = 0.8
local green_color_base = 0.4
local blue_color_base = 0.404
local red_color_diff = -0.235
local green_color_diff = 0.42
local blue_color_diff = 0.063

local demo_steps = {
  {name = "Boss 1", completed = true, cur_value = 1, final_value = 1},
  {name = "Boss 2", completed = false, cur_value = 0, final_value = 1},
  {name = "Boss 3", completed = false, cur_value = 0, final_value = 1},
  {name = "Boss 4", completed = false, cur_value = 0, final_value = 1},
  {
    name = addon.t("lbl_enemyforces"),
    completed = false,
    cur_value = 42,
    final_value = 123,
    quantity = "42%",
  },
}

-- ---------------------------------------------------------------------------------------------------------------------
local function create_enemy_forces_bar(step_index)
  if enemy_forces_bar then
    local prev_step_frame = step_frames[step_index - 1]
    if not enemy_forces_bar.ref_frame or enemy_forces_bar.ref_frame ~= prev_step_frame then
      enemy_forces_bar:SetPoint("TOPLEFT", prev_step_frame, "BOTTOMLEFT", 0, -5)
      enemy_forces_bar.ref_frame = prev_step_frame
    end

    step_frames[step_index] = enemy_forces_bar
    return step_frames[step_index]
  end

  -- frame
  enemy_forces_bar = CreateFrame("STATUSBAR", nil, main.get_frame(), BackdropTemplateMixin and "BackdropTemplate")
  enemy_forces_bar:SetPoint("TOPLEFT", step_frames[step_index - 1], "BOTTOMLEFT", 0, -5)

  enemy_forces_bar.text = enemy_forces_bar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  local font_path, _, font_flags = enemy_forces_bar.text:GetFont()
  enemy_forces_bar.text:SetFont(font_path, 12, font_flags)
  enemy_forces_bar.text:SetPoint("CENTER", enemy_forces_bar, "CENTER", 0, -0.5);

  enemy_forces_bar.text:SetJustifyH("CENTER")
  enemy_forces_bar.text:SetJustifyV("TOP")
  enemy_forces_bar.text:SetShadowColor(0.0, 0.0, 0.0, 1.0)
  enemy_forces_bar.text:SetShadowOffset(1, -1)

  enemy_forces_bar.Background = enemy_forces_bar:CreateTexture(nil, "BORDER")
  enemy_forces_bar.Background:SetAllPoints(enemy_forces_bar)

  enemy_forces_bar:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    insets = {top = -1, left = -1, bottom = -1, right = -1.5},
  })
  enemy_forces_bar:SetBackdropColor(0, 0, 0, 1)

  enemy_forces_bar:SetStatusBarTexture("Interface\\AddOns\\MythicPlusTimer\\barResource\\bar.tga")
  enemy_forces_bar.Background:SetTexture("Interface\\AddOns\\MythicPlusTimer\\barResource\\bar.tga")

  enemy_forces_bar.Background:SetVertexColor(0, 0, 0, 1)
  enemy_forces_bar:SetStatusBarColor(0, 1, 0, 1)
  enemy_forces_bar:SetHeight(18)
  enemy_forces_bar:SetWidth(250)

  enemy_forces_bar:SetMinMaxValues(0, 1)

  step_frames[step_index] = enemy_forces_bar
  return step_frames[step_index]
end

-- ---------------------------------------------------------------------------------------------------------------------
local function create_step_frame(step_index)
  if step_frames[step_index] then
    if step_frames[step_index] == enemy_forces_bar then
      enemy_forces_bar:Hide()
    else
      return step_frames[step_index]
    end
  end

  -- frame
  local frame = CreateFrame("Frame", nil, main.get_frame())
  if step_index == 1 then
    frame:SetPoint("TOPLEFT", timer.get_time_3_frame(), "BOTTOMLEFT", 0, -20)
  else
    frame:SetPoint("TOPLEFT", step_frames[step_index - 1], "BOTTOMLEFT", 0, -5)
  end

  -- text
  frame.text = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
  local font_path, _, font_flags = frame.text:GetFont()
  frame.text:SetFont(font_path, 12, font_flags)
  frame.text:SetPoint("TOPLEFT")
  frame.text:SetJustifyH("LEFT")

  step_frames[step_index] = frame
  return step_frames[step_index]
end

-- ---------------------------------------------------------------------------------------------------------------------
local function set_step_completed(step_index, current_run, name)
  -- check if step was already set to completed
  if current_run.times[step_index] ~= nil then
    return
  end

  -- set step time
  local step_frame = step_frames[step_index]

  local elapsed_time = current_run.elapsed_time
  current_run.times[step_index] = elapsed_time

  -- check best times
  local best_times = addon.c("best_times")

  local best_time_zone = best_times[current_run.current_zone_id][step_index]
  current_run.times[step_index .. "last_best_time_zone"] = best_time_zone
  if not best_time_zone or elapsed_time < best_time_zone then
    best_time_zone = elapsed_time
    best_times[current_run.current_zone_id][step_index] = elapsed_time
  end

  local best_time_zone_level = best_times[current_run.current_zone_id][current_run.level_key][step_index]
  current_run.times[step_index .. "last_best_time_zone_level"] = best_time_zone_level
  if not best_time_zone_level or elapsed_time < best_time_zone_level then
    best_time_zone_level = elapsed_time
    best_times[current_run.current_zone_id][current_run.level_key][step_index] = elapsed_time
  end

  local best_time_zone_level_affixes = best_times[current_run.current_zone_id][current_run.level_key .. current_run.affixes_key][step_index]
  current_run.times[step_index .. "last_best_time_zone_level_affixes"] = best_time_zone_level_affixes
  if not best_time_zone_level_affixes or elapsed_time < best_time_zone_level_affixes then
    best_time_zone_level_affixes = elapsed_time
    best_times[current_run.current_zone_id][current_run.level_key .. current_run.affixes_key][step_index] = elapsed_time
  end

  -- output step completion to chat if configured
  if addon.c("objective_time_inchat") and main.is_in_cm() then
    local text = name .. " " .. addon.t("lbl_completed") .. " (+" .. current_run.cm_level .. "). " .. addon.t("lbl_time") .. ": " .. main.format_seconds(elapsed_time) .. " " .. addon.t("lbl_besttime") .. ": "

    if addon.c("objective_time_perlevel") then
      text = text .. main.format_seconds(best_time_zone_level)
    end

    if addon.c("objective_time_perlevelaffix") then
      text = text .. main.format_seconds(best_time_zone_level_affixes)
    end

    if not addon.c("objective_time_perlevel") and not addon.c("objective_time_perlevelaffix") then
      text = text .. main.format_seconds(best_time_zone)
    end

    addon.print(text)
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
local function resolve_time_info(step_index, current_run)
  if not current_run.times[step_index] or not addon.c("objective_time") then
    return ""
  end

  -- time info
  local time = current_run.times[step_index]
  if time == 0 then
    return ""
  end

  local time_info = "  |c" .. addon.c("color_objective_completed_time") .. main.format_seconds(time)

  -- add best times
  local best_times = addon.c("best_times")

  --- best time per level and zone
  if addon.c("objective_time_perlevel") then
    local best_time_zone_level = best_times[current_run.current_zone_id][current_run.level_key][step_index]
    local last_best_time_zone_level = current_run.times[step_index .. "last_best_time_zone_level"]
    if not last_best_time_zone_level then
      last_best_time_zone_level = best_time_zone_level
    end

    if last_best_time_zone_level then
      local diff = time - last_best_time_zone_level
      local diff_info = ""
      if diff > 0 then
        diff_info = ", +" .. main.format_seconds(diff)
      elseif diff < 0 then
        diff_info = ", -" .. main.format_seconds(diff * -1)
      end

      time_info = time_info .. " (" .. addon.t("lbl_best") .. ": " .. main.format_seconds(best_time_zone_level) .. diff_info .. ")"
    end
  end

  --- best time per level and zone and affix
  if addon.c("objective_time_perlevelaffix") then
    local best_time_zone_level_affixes = best_times[current_run.current_zone_id][current_run.level_key .. current_run.affixes_key][step_index]
    local last_best_time_zone_level_affixes = current_run.times[step_index .. "last_best_time_zone_level_affixes"]
    if not last_best_time_zone_level_affixes then
      last_best_time_zone_level_affixes = best_time_zone_level_affixes
    end

    if last_best_time_zone_level_affixes then
      local diff = time - last_best_time_zone_level_affixes
      local diff_info = ""
      if diff > 0 then
        diff_info = ", +" .. main.format_seconds(diff)
      elseif diff < 0 then
        diff_info = ", -" .. main.format_seconds(diff * -1)
      end

      time_info = time_info .. " (" .. addon.t("lbl_best") .. ": " .. main.format_seconds(best_time_zone_level_affixes) .. diff_info .. ")"
    end
  end

  --- best time per zone
  if not addon.c("objective_time_perlevelaffix") and not addon.c("objective_time_perlevel") then
    local best_time_zone = best_times[current_run.current_zone_id][step_index]
    local last_best_time_zone = current_run.times[step_index .. "last_best_time_zone"]
    if not last_best_time_zone then
      last_best_time_zone = best_time_zone
    end

    if last_best_time_zone then
      local diff = time - last_best_time_zone
      local diff_info = ""
      if diff > 0 then
        diff_info = ", +" .. main.format_seconds(diff)
      elseif diff < 0 then
        diff_info = ", -" .. main.format_seconds(diff * -1)
      end

      time_info = time_info .. " (" .. addon.t("lbl_best") .. ": " .. main.format_seconds(best_time_zone) .. diff_info .. ")"
    end
  end

  return time_info
end

-- ---------------------------------------------------------------------------------------------------------------------
local function resolve_step_info(step_index, current_run, name, completed, cur_value, final_value, quantity)
  -- enemy forces
  if final_value >= 100 then
    -- absolute number
    local quantity_number = string.sub(quantity, 1, string.len(quantity) - 1)

    -- percentage
    local quantity_percent = (quantity_number / final_value) * 100
    local mult = 10 ^ 2
    quantity_percent = math.floor(quantity_percent * mult + 0.5) / mult
    if quantity_percent > 100 then
      quantity_percent = 100
    end

    -- set to 100% if completed (needed if enemy forces is the last criteria which gets completed, quantity is not updated to 100% in this case)
    if completed then
      quantity_percent = 100
      quantity_number = final_value
      current_run.quantity_completed = true
    end

    -- save to current_run
    current_run.quantity_number = quantity_number
    current_run.final_quantity_number = final_value

    -- resolve pull value
    local pull_enemies = 0
    local pull_value = 0
    local pull_in_percent = 0
    if current_run.pull then
      for _, v in pairs(current_run.pull) do
        pull_enemies = pull_enemies + 1
        pull_value = pull_value + v[1]
        pull_in_percent = pull_in_percent + v[2]
      end
    end

    local pull_value_text = " "
    if pull_enemies > 0 and addon.c("show_pull_values") and not completed then
      pull_value_text = pull_value_text .. "|c" .. addon.c("color_current_pull")

      if addon.c("show_percent_numbers") then
        pull_value_text = pull_value_text .. "+" .. pull_in_percent .. "%"
      end

      if addon.c("show_absolute_numbers") then
        if addon.c("show_percent_numbers") then
          pull_value_text = pull_value_text .. " (" .. pull_value .. ")"
        else
          pull_value_text = pull_value_text .. "+" .. pull_value
        end
      end

      pull_value_text = pull_value_text .. "|r "
    end

    -- resolve text
    local percent_text = ""
    if addon.c("show_percent_numbers") then
      percent_text = " " .. quantity_percent .. "% "
    end

    local absolute_number = ""
    if addon.c("show_absolute_numbers") then
      local missing_absolute = final_value - quantity_number
      if missing_absolute == 0 then
        missing_absolute = ""
      else
        missing_absolute = " - " .. missing_absolute
      end

      absolute_number = quantity_number .. "/" .. final_value .. missing_absolute

      if addon.c("show_percent_numbers") then
        absolute_number = " (" .. absolute_number .. ")"
      else
        absolute_number = " " .. absolute_number
      end
    end

    if completed or not addon.c("show_enemy_forces_bar") then
      return "-" .. percent_text .. absolute_number .. pull_value_text .. name
    else
      return percent_text .. absolute_number .. pull_value_text
    end
  end

  -- boss
  if completed then
    cur_value = final_value
  end

  return "- " .. cur_value .. "/" .. final_value .. " " .. name
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_scenario_criteria_update()
  -- check if we have an run
  local current_run = main.get_current_run()
  if not current_run then
    return
  end

  -- resolve steps
  local _, _, steps = C_Scenario.GetStepInfo()
  if not steps or steps <= 0 then
    return
  end

  -- check if all are completed
  local completed_steps = 0
  for i = 1, steps do
    local _, _, completed = C_Scenario.GetCriteriaInfo(i)

    if completed then
      completed_steps = completed_steps + 1
    end
  end

  if completed_steps == steps then
    current_run.is_completed = true
    criteria.update()
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_config_change()
  local current_run = main.get_current_run()
  if not current_run then
    return
  end

  -- update demo
  if current_run.is_demo then
    criteria.update_demo_criteria(current_run)
    return
  end

  -- update criteria
  criteria.update()
end

-- ---------------------------------------------------------------------------------------------------------------------
function criteria.on_challenge_mode_start()
  criteria.update()
end

-- ---------------------------------------------------------------------------------------------------------------------
function criteria.on_player_entering_world()
  -- update if in cm
  if main.is_in_cm() then
    criteria.update()
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
function criteria.update()
  -- called every second by the timer module

  -- update all
  local current_run = main.get_current_run()
  if not current_run then
    return
  end

  local _, _, steps = C_Scenario.GetStepInfo()
  if not steps or steps <= 0 then
    return
  end

  for i = 1, steps do
    local name, _, completed, cur_value, final_value, _, _, quantity = C_Scenario.GetCriteriaInfo(i)
    criteria.update_step(i, current_run, name, completed, cur_value, final_value, quantity)
  end

  -- update prideful
  infos.update_prideful()

  -- update reaping
  infos.update_reaping()
end

-- ---------------------------------------------------------------------------------------------------------------------
function criteria.update_step(step_index, current_run, name, completed, cur_value, final_value, quantity)
  -- resolve frame
  local step_frame
  if final_value >= 100 and (not completed) and addon.c("show_enemy_forces_bar") then
    if step_frames[step_index] then
      step_frames[step_index]:Hide()
    end
    step_frame = create_enemy_forces_bar(step_index)
  else
    if final_value >= 100 and enemy_forces_bar then
      enemy_forces_bar:Hide()
    end

    step_frame = create_step_frame(step_index)
  end

  -- update times
  local color = addon.c("color_objective")
  if completed then
    set_step_completed(step_index, current_run, name)
    color = addon.c("color_objective_completed")
  else
    -- set font
    if not step_frame.text.current_font or step_frame.text.current_font ~= "GameFontHighlight" then
      step_frame.text:SetFontObject("GameFontHighlight")
      step_frame.text.current_font = "GameFontHighlight"
    end

    -- enemy forces bar
    if step_frame == enemy_forces_bar then
      local quantity_number = string.sub(quantity, 1, string.len(quantity) - 1)
      local quantity_percent = tonumber(quantity_number) / final_value
      local a = tonumber(1)

      enemy_forces_bar:SetValue(quantity_percent)

      local finalRedColor = red_color_base + red_color_diff * quantity_percent
      local finalGreenColor = green_color_base + green_color_diff * quantity_percent
      local finalBlueColor = blue_color_base + blue_color_diff * quantity_percent

      enemy_forces_bar:SetStatusBarColor(finalRedColor, finalGreenColor, finalBlueColor, 1)
    end

    -- reset current run time
    if current_run.times[step_index] then
      current_run.times[step_index] = nil
    end
  end

  -- resolve time info
  local time_info = resolve_time_info(step_index, current_run)

  -- resolve step info
  local step_info = resolve_step_info(step_index, current_run, name, completed, cur_value, final_value, quantity)

  -- set text
  local objective_text = string.format("|c%s%s%s", color, step_info, time_info)
  local current_objective_text = step_frame.text:GetText()

  if current_objective_text ~= objective_text then
    step_frame.text:SetText(objective_text)

    if (not current_objective_text or not objective_text or string.len(current_objective_text) ~= string.len(objective_text)) and step_frame ~= enemy_forces_bar then
      step_frame:SetHeight(step_frame.text:GetStringHeight())
      step_frame:SetWidth(step_frame.text:GetStringWidth())
    end
  end

  -- show frame
  if step_index == 1 then
    step_frame:SetPoint("TOPLEFT", timer.get_time_3_frame(), "BOTTOMLEFT", 0, -20)
  end

  step_frame:Show()
end

-- ---------------------------------------------------------------------------------------------------------------------
function criteria.hide_frames()
  for _, frame in pairs(step_frames) do
    frame:Hide()
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
function criteria.get_last_frame(current_run)
  -- check if demo
  if current_run.is_demo then
    return step_frames[#demo_steps]
  end

  local _, _, steps = C_Scenario.GetStepInfo()
  return step_frames[steps]
end

-- ---------------------------------------------------------------------------------------------------------------------
function criteria.update_demo_criteria(demo_run)
  for i, step in ipairs(demo_steps) do
    criteria.update_step(i, demo_run, step.name, step.completed, step.cur_value, step.final_value, step.quantity)
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Init
function criteria:init()
  main = addon.get_module("main")
  timer = addon.get_module("timer")
  infos = addon.get_module("infos")
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Enable
function criteria:enable()
  -- register events
  addon.register_event("SCENARIO_CRITERIA_UPDATE", on_scenario_criteria_update)

  -- config listeners
  addon.register_config_listener("best_times", on_config_change)
  addon.register_config_listener("objective_time_inchat", on_config_change)
  addon.register_config_listener("objective_time_perlevel", on_config_change)
  addon.register_config_listener("objective_time_perlevelaffix", on_config_change)
  addon.register_config_listener("objective_time", on_config_change)
  addon.register_config_listener("show_percent_numbers", on_config_change)
  addon.register_config_listener("show_absolute_numbers", on_config_change)
  addon.register_config_listener("show_pull_values", on_config_change)
  addon.register_config_listener("show_enemy_forces_bar", on_config_change)
  addon.register_config_listener("color_objective", on_config_change)
  addon.register_config_listener("color_objective_completed", on_config_change)
  addon.register_config_listener("color_objective_completed_time", on_config_change)
  addon.register_config_listener("color_current_pull", on_config_change)
end
