local _, addon = ...
local infos = addon.new_module("infos")

-- ---------------------------------------------------------------------------------------------------------------------
local main
local criteria

-- ---------------------------------------------------------------------------------------------------------------------
local deathcounter_frame
local pull_frame

-- ---------------------------------------------------------------------------------------------------------------------
local function create_deathcounter_frame()
  if deathcounter_frame then
    return deathcounter_frame
  end

  -- frame
  local frame = CreateFrame("Frame", nil, main.get_frame())
  frame:ClearAllPoints()

  -- text
  frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  local font_path, _, font_flags = frame.text:GetFont()
  frame.text:SetFont(font_path, 12, font_flags)

  if addon.c("align_right") then
    frame.text:SetPoint("TOPRIGHT")
    frame.text:SetJustifyH("RIGHT")
  else 
    frame.text:SetPoint("TOPLEFT")
    frame.text:SetJustifyH("LEFT")
  end

  -- tooltip
  local on_enter = function()
    if not deathcounter_frame.tooltip then
      return
    end

    GameTooltip:Hide()
    GameTooltip:ClearLines()

    if addon.c("align_right") then
      GameTooltip:SetOwner(deathcounter_frame, "ANCHOR_TOPRIGHT")
    else 
      GameTooltip:SetOwner(deathcounter_frame, "ANCHOR_TOPLEFT")
    end
    
    for _, v in pairs(deathcounter_frame.tooltip) do
      GameTooltip:AddLine(v)
    end
    GameTooltip:Show()
  end

  frame:SetScript("OnEnter", on_enter)
  frame:SetScript("OnLeave", GameTooltip_Hide)

  deathcounter_frame = frame
  return deathcounter_frame
end

-- ---------------------------------------------------------------------------------------------------------------------
local function create_pull_frame()
  if pull_frame then
    return pull_frame
  end

  local frame = CreateFrame("Frame", nil, main.get_frame())
  frame:ClearAllPoints()

  frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  local font_path, _, font_flags = frame.text:GetFont()
  frame.text:SetFont(font_path, 12, font_flags)

  if addon.c("align_right") then
    frame.text:SetPoint("TOPRIGHT")
    frame.text:SetJustifyH("RIGHT")
  else 
    frame.text:SetPoint("TOPLEFT")
    frame.text:SetJustifyH("LEFT")
  end

  pull_frame = frame
  return pull_frame
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_config_change()
  local current_run = main.get_current_run()
  if not current_run then
    return
  end

  -- update demo
  if current_run.is_demo then
    -- deathcounter
    current_run.deathcount = -1
    infos.update_deathcounter_info(current_run, 2, 10)
    return
  end

  -- update deathcounter
  current_run.deathcount = -1 -- reset count in cache to trigger the rerender
  infos.update_deathcounter()
end

-- ---------------------------------------------------------------------------------------------------------------------
local function update_deathcounter_tooltip(current_run)
  if not deathcounter_frame then
    return
  end

  if current_run.death_names then
    local tooltip = {}
    table.insert(tooltip, addon.t("lbl_deaths"))
    for name, count in pairs(current_run.death_names) do
      table.insert(tooltip, "|cFFFFFFFF" .. name .. ": " .. count)
    end

    deathcounter_frame.tooltip = tooltip
  else
    deathcounter_frame.tooltip = nil
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
local function update_deathcounter(current_run, deathcount, death_timelost)
  -- check deathcount
  if not death_timelost or death_timelost == 0 or not deathcount or deathcount == 0 or not addon.c("show_deathcounter") then
    current_run.deathcount_visible = false

    if deathcounter_frame then
      deathcounter_frame:Hide()
    end
    return
  end

  -- check if we can skip the update
  local last_criteria_frame = criteria.get_last_frame(current_run)
  if current_run.deathcount == deathcount and deathcounter_frame and deathcounter_frame.ref_frame == last_criteria_frame and current_run.deathcount_visible then
    return
  end

  current_run.deathcount = deathcount
  current_run.deathcount_visible = true

  -- update
  create_deathcounter_frame()

  local deathcounter_text = string.format("|c%s%s %s|r|c%s -%s", addon.c("color_deathcounter"), deathcount, addon.t("lbl_deaths"), addon.c("color_deathcounter_timelost"), main.format_seconds(death_timelost))
  local current_deathcounter_text = deathcounter_frame.text:GetText()

  if current_deathcounter_text ~= deathcounter_text then
    deathcounter_frame.text:SetText(deathcounter_text)

    -- update size (needed for tooltip)
    if not current_deathcounter_text or not deathcounter_text or string.len(current_deathcounter_text) ~= string.len(deathcounter_text) then
      deathcounter_frame:SetHeight(deathcounter_frame.text:GetStringHeight())
      deathcounter_frame:SetWidth(deathcounter_frame.text:GetStringWidth())
    end
  end

  -- update point (last criteria frame can be different in every dungeon)
  if not deathcounter_frame.ref_frame or deathcounter_frame.ref_frame ~= last_criteria_frame then
    if addon.c("align_right") then
      deathcounter_frame:SetPoint("TOPRIGHT", last_criteria_frame, "BOTTOMRIGHT", 0, -5)
    else 
      deathcounter_frame:SetPoint("TOPLEFT", last_criteria_frame, "BOTTOMLEFT", 0, -5)
    end

    deathcounter_frame.ref_frame = last_criteria_frame
  end

  -- show
  deathcounter_frame:Show()

  -- update tooltip
  update_deathcounter_tooltip(current_run)
end

-- ---------------------------------------------------------------------------------------------------------------------
local function update_pull(current_run)
  -- is called at criteria update
  if not current_run.pull then
    return
  end

  -- update
  create_pull_frame()

  -- skip if enemy forces is not known (criterias are not always known on cm start ... update gets called anyway)
  if current_run.final_quantity_number == nil then
    pull_frame:Hide()
    return
  end

  -- update point
  local ref_frame = nil

  if deathcounter_frame and current_run.deathcount_visible then
    ref_frame = deathcounter_frame
  else
    ref_frame = criteria.get_last_frame(current_run)
  end

  if not pull_frame.ref_frame or pull_frame.ref_frame ~= ref_frame then
    if addon.c("align_right") then
      pull_frame:SetPoint("TOPRIGHT", ref_frame, "BOTTOMRIGHT", 0, -5)
    else 
      pull_frame:SetPoint("TOPLEFT", ref_frame, "BOTTOMLEFT", 0, -5)
    end

    pull_frame.ref_frame = ref_frame
  end

  -- resolve pull value
  local enemies = 0
  local value = 0
  for _, v in pairs(current_run.pull) do
    enemies = enemies + 1
    value = value + v[1]
  end

  if enemies == 0 then
    pull_frame:Hide()
    return
  end

  local in_percent = (value / current_run.final_quantity_number) * 100
  local mult = 10 ^ 2
  in_percent = math.floor(in_percent * mult + 0.5) / mult

  -- update text
  local text = "|c" .. addon.c("color_current_pull") .. addon.t("lbl_currentpull") .. " |c" .. addon.c("color_current_pull") .. "" .. in_percent .. "%"
  if addon.c("show_absolute_numbers") then
    text = text .. " (" .. value .. ")"
  end

  -- set text
  local current_text = pull_frame.text:GetText()

  if current_text ~= text then
    pull_frame.text:SetText(text)

    if not current_text or not text or string.len(current_text) ~= string.len(text) then
      pull_frame:SetHeight(pull_frame.text:GetStringHeight())
      pull_frame:SetWidth(pull_frame.text:GetStringWidth())
    end
  end

  pull_frame:Show()
end

-- ---------------------------------------------------------------------------------------------------------------------
local surrendered_soul

local function on_combat_log_event_unfiltered()
  local _, sub_event, _, _, _, _, _, dest_guid, dest_name = CombatLogGetCurrentEventInfo()

  -- skip if not a unit death event
  if sub_event ~= "UNIT_DIED" then
    return
  end

  -- skip if not in cm
  if not main.is_in_cm() then
    return
  end

  -- skip if not a player
  local is_player = strfind(dest_guid, "Player")
  if not is_player then
    return
  end

  -- skip if feign death
  local is_feign = UnitIsFeignDeath(dest_name)
  if is_feign then
    return
  end

  -- player death happened
  local current_run = main.get_current_run()
  if not current_run then
    return
  end

  if not current_run.death_names then
    current_run.death_names = {}
  end

  if current_run.death_names[dest_name] == nil then
    current_run.death_names[dest_name] = 1
  else
    current_run.death_names[dest_name] = current_run.death_names[dest_name] + 1
  end

  -- update tooltip
  update_deathcounter_tooltip(current_run)
end

-- ---------------------------------------------------------------------------------------------------------------------
function infos.hide_frames()
  -- deathcounter frame
  if deathcounter_frame then
    deathcounter_frame:Hide()
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
function infos.update_deathcounter()
  -- is called every second by the timer
  local current_run = main.get_current_run()
  if not current_run then
    return
  end

  -- skip if run is completed
  if current_run.is_completed then
    return
  end

  -- update demo
  if current_run.is_demo then
    current_run.deathcount = -1
    infos.update_deathcounter_info(current_run, 2, 10)
    return
  end

  -- update from C_ChallengeMode
  local deathcount, death_timelost = C_ChallengeMode.GetDeathCount()
  update_deathcounter(current_run, deathcount, death_timelost)
end

-- ---------------------------------------------------------------------------------------------------------------------
function infos.update_deathcounter_info(current_run, deathcount, death_timelost)
  -- used to update the deathcounter directly (demo)
  update_deathcounter(current_run, deathcount, death_timelost)
end

-- ---------------------------------------------------------------------------------------------------------------------
function infos.update_pull()
  local current_run = main.get_current_run()
  if not current_run then
    return
  end

  update_pull(current_run)
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Init
function infos:init()
  main = addon.get_module("main")
  criteria = addon.get_module("criteria")
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Enable
function infos:enable()
  -- register events
  addon.register_event("COMBAT_LOG_EVENT_UNFILTERED", on_combat_log_event_unfiltered)

  -- config listeners
  addon.register_config_listener("show_deathcounter", on_config_change)
  addon.register_config_listener("show_absolute_numbers", on_config_change)
  addon.register_config_listener("show_enemy_forces_bar", on_config_change)
  addon.register_config_listener("color_deathcounter", on_config_change)
  addon.register_config_listener("color_deathcounter_timelost", on_config_change)
  addon.register_config_listener("show_percent_numbers", on_config_change)
end
