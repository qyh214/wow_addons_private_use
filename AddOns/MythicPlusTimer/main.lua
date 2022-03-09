local _, addon = ...
local main = addon.new_module("main")

-- ---------------------------------------------------------------------------------------------------------------------
local config
local criteria
local timer
local progress
local infos

-- ---------------------------------------------------------------------------------------------------------------------
local main_frame
local info_frames = {}
local hidden_frame
local quest_frame

-- ---------------------------------------------------------------------------------------------------------------------
local function save_frame_position()
  local _, _, relative_point, x_offset, y_offset = main_frame:GetPoint()
  addon.set_config_value("position", {left = x_offset, top = y_offset, relative_point = relative_point})
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_frame_dragstop()
  main_frame:StopMovingOrSizing()

  if not main_frame.frame_toggle then
    return
  end

  save_frame_position()
end

-- ---------------------------------------------------------------------------------------------------------------------
local function create_main_frame()
  local frame = CreateFrame("Frame", "MythicPlusTimer", UIParent, BackdropTemplateMixin and "BackdropTemplate")
  frame.frame_toggle = false

  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", on_frame_dragstop)
  frame:SetWidth(200)
  frame:SetHeight(25)

  local frame_position = addon.c("position")
  if not frame_position then
    frame_position = {left = -260, top = 220, relative_point = "RIGHT"}

    addon.set_config_value("position", frame_position)
  end

  frame:SetScale(addon.c("scale"))
  frame:SetPoint(frame_position.relative_point, frame_position.left, frame_position.top)

  -- Drag text
  frame.drag_text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  local font_path, _, font_flags = frame.drag_text:GetFont()
  frame.drag_text:SetFont(font_path, 12, font_flags)
  frame.drag_text:SetPoint("TOPLEFT", 5, -5)
  frame.drag_text:SetText("MythicPlusTimer")
  frame.drag_text:Hide()

  --
  main_frame = frame
end

-- ---------------------------------------------------------------------------------------------------------------------
local function create_info_frame_dungeon()
  if info_frames.dungeon then
    return info_frames.dungeon
  end

  local frame = CreateFrame("Frame", nil, main_frame)
  frame:ClearAllPoints()
  frame:SetPoint("TOPLEFT", main_frame, 0, -30)

  frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  local font_path, _, font_flags = frame.text:GetFont()
  frame.text:SetFont(font_path, 16, font_flags)
  frame.text:SetPoint("TOPLEFT", 0, 0)

  local on_enter = function(self, motion)
    local dungeon_frame = info_frames.dungeon
    if not dungeon_frame.tooltip then
      return
    end

    GameTooltip:Hide()
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(dungeon_frame, "ANCHOR_BOTTOMLEFT")

    for _, l in pairs(dungeon_frame.tooltip) do
      GameTooltip:AddLine(l)
    end

    GameTooltip:Show()
  end

  frame:SetScript("OnEnter", on_enter)
  frame:SetScript("OnLeave", GameTooltip_Hide)

  info_frames.dungeon = frame
  return info_frames.dungeon
end

-- ---------------------------------------------------------------------------------------------------------------------
local function create_info_frame_affixes_text()
  if info_frames.affixes_text then
    return info_frames.affixes_text
  end

  local frame = CreateFrame("Frame", nil, main_frame)
  frame:ClearAllPoints()
  frame:SetPoint("TOPLEFT", info_frames.dungeon, "BOTTOMLEFT", 0, -3)

  frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  local font_path, _, font_flags = frame.text:GetFont()
  frame.text:SetFont(font_path, 12, font_flags)
  frame.text:SetPoint("TOPLEFT", 0, 0)

  info_frames.affixes_text = frame
  return info_frames.affixes_text
end

-- ---------------------------------------------------------------------------------------------------------------------
local function create_info_frame_affixes_icons()
  if info_frames.affixes_icons then
    return info_frames.affixes_icons
  end

  local frame = CreateFrame("Frame", nil, main_frame)
  frame:ClearAllPoints()
  frame:SetPoint("TOPLEFT", info_frames.dungeon, "BOTTOMLEFT", 0, -3)
  frame:SetHeight(16)

  info_frames.affixes_icons = frame
  return info_frames.affixes_icons
end

-- ---------------------------------------------------------------------------------------------------------------------
local function create_info_frame_affix_icon(icons_frame, affix_index)
  if not info_frames.affixes_icon then
    info_frames.affixes_icon = {}
  end

  if info_frames.affixes_icon[affix_index] then
    return info_frames.affixes_icon[affix_index]
  end

  local frame = CreateFrame("Frame", nil, icons_frame)
  frame:SetSize(16, 16)

  if affix_index == 1 then
    frame:SetPoint("TOPLEFT", icons_frame, "TOPLEFT", 0, 0)
  else
    frame:SetPoint("LEFT", info_frames.affixes_icon[affix_index - 1], "RIGHT", 5, 0)
  end

  local border = frame:CreateTexture(nil, "OVERLAY")
  border:SetAllPoints()
  border:SetAtlas("ChallengeMode-AffixRing-Sm")
  frame.Border = border

  local portrait = frame:CreateTexture(nil, "ARTWORK")
  portrait:SetSize(16, 16)
  portrait:SetPoint("CENTER", border)
  frame.Portrait = portrait

  frame.SetUp = ScenarioChallengeModeAffixMixin.SetUp
  frame:SetScript("OnEnter", ScenarioChallengeModeAffixMixin.OnEnter)
  frame:SetScript("OnLeave", GameTooltip_Hide)

  info_frames.affixes_icon[affix_index] = frame
  return info_frames.affixes_icon[affix_index]
end

-- ---------------------------------------------------------------------------------------------------------------------
local function update_dungeon_info(current_run)
  -- dungeon name
  local dungeon_frame = create_info_frame_dungeon()
  local dungeon_name = string.format("|c%s+%s - %s", addon.c("color_dungeon_name"), current_run.cm_level, current_run.zone_name)

  dungeon_frame.text:SetText(dungeon_name)
  dungeon_frame:SetHeight(dungeon_frame.text:GetStringHeight())
  dungeon_frame:SetWidth(dungeon_frame.text:GetStringWidth())

  local tooltip = {}
  table.insert(tooltip, dungeon_name)
  table.insert(tooltip, "|cFFFFFFFF" .. "+" .. C_ChallengeMode.GetPowerLevelDamageHealthMod(current_run.cm_level) .. "%")
  table.insert(tooltip, " ")

  -- affixes
  local affixes_text_frame = create_info_frame_affixes_text()
  local affixes_icons_frame = create_info_frame_affixes_icons()

  local text = ""
  for i, affix_id in ipairs(current_run.affixes) do
    -- resolve affix data
    local affix_name, affix_desc = C_ChallengeMode.GetAffixInfo(affix_id)

    -- update text
    if i ~= 1 then
      text = text .. " - " .. affix_name
    else
      text = affix_name
    end

    table.insert(tooltip, affix_name)
    table.insert(tooltip, "|cFFFFFFFF" .. affix_desc)
    table.insert(tooltip, "  ")

    -- update icons
    if addon.c("show_affixes_as_icons") then
      local affix_icon_frame = create_info_frame_affix_icon(affixes_icons_frame, i)

      if not affix_icon_frame.affix_id or affix_icon_frame.affix_id ~= affix_id then
        affix_icon_frame:SetUp(affix_id)
        affix_icon_frame.affix_id = affix_id
      end

      affix_icon_frame:Show()
    end
  end

  -- set name tooltip
  dungeon_frame.tooltip = tooltip

  -- set text
  affixes_text_frame.text:SetText(string.format("|c%s%s", addon.c("color_affixes"), text))
  affixes_text_frame:SetHeight(affixes_text_frame.text:GetStringHeight())
  affixes_text_frame:SetWidth(affixes_text_frame.text:GetStringWidth())

  if addon.c("show_affixes_as_text") then
    affixes_text_frame:Show()
    affixes_icons_frame:SetPoint("TOPLEFT", dungeon_frame, "BOTTOMLEFT", 0, -8 - affixes_text_frame:GetHeight())
  else
    affixes_text_frame:Hide()
    affixes_icons_frame:SetPoint("TOPLEFT", dungeon_frame, "BOTTOMLEFT", 0, -3)
  end

  -- update icons frame
  if addon.c("show_affixes_as_icons") then
    affixes_icons_frame:SetWidth(16 * #current_run.affixes)
    affixes_icons_frame:Show()
  else
    affixes_icons_frame:Hide()
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
local function show_demo()
  local current_id = -1

  local demo_run = {
    cm_level = 30,
    level_key = "l" .. 30,
    affixes = {9, 7, 13, 130},
    affixes_key = "affixes-9-7-13-130",
    zone_name = "Demo",
    current_zone_id = current_id,
    current_map_id = current_id,
    max_time = 2160,
    steps = 5,
    times = {},
    elapsed_time = 123,
    deathcount = 0,
    is_demo = true,
    is_teeming = false,
    pull = {guid = {4, 1.28}},
  }

  addon.set_config_value("current_run", demo_run)

  local best_times = addon.c("best_times")

  best_times[demo_run.current_zone_id] = {[1] = 50}
  best_times[demo_run.current_zone_id][demo_run.level_key] = {[1] = 110}
  best_times[demo_run.current_zone_id][demo_run.level_key .. demo_run.affixes_key] = {[1] = 150}

  -- name
  update_dungeon_info(demo_run)

  -- times
  timer.on_challenge_mode_start()
  timer.update_time(123)

  -- criteria
  criteria.update_demo_criteria(demo_run)

  -- deathcounter
  infos.update_deathcounter_info(demo_run, 2, 10)

  -- prideful
  infos.update_prideful_info(demo_run)

  -- reaping
  infos.update_reaping_info(demo_run)
end

-- ---------------------------------------------------------------------------------------------------------------------
local function toggle_frame_movement()
  local frame = main.get_frame()

  if frame.frame_toggle then
    frame:SetMovable(false)
    frame:SetBackdrop(nil)
    frame.frame_toggle = false

    save_frame_position()

    local _, _, difficulty, _, _, _, _, _ = GetInstanceInfo()
    if difficulty ~= 8 then
      main.hide_frame()
      main.show_default_tracker()
    end

    frame.drag_text:Hide()
  else
    if not main.is_in_cm() then
      show_demo()
    end

    frame:SetMovable(true)
    local backdrop = {
      bgFile = "Interface/Tooltips/UI-Tooltip-Background",
      edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
      tile = true,
      tileSize = 32,
      edgeSize = 1,
      insets = {left = 0, right = 0, top = 0, bottom = 0},
    }

    frame:SetBackdrop(backdrop)
    frame.frame_toggle = true
    frame:Show()
    frame.drag_text:Show()
  end

  config.update_unlock_checkbox()
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_scale_change()
  main_frame:SetScale(addon.c("scale"))
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_config_change()
  local current_run = main.get_current_run()
  if not current_run then
    return
  end

  update_dungeon_info(current_run)

  -- update timer to use the correct reference frames for positioning
  timer.elapsed_time = -1
  timer.update_time(current_run.elapsed_time)
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_objectivetracker_change(_, checked)
  if not checked then
    quest_frame:SetParent(UIParent)
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
local function resolve_time(seconds)
  local min = math.floor(seconds / 60)
  local sec = seconds - (min * 60)
  return min, sec
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_challenge_mode_start()
  local current_map_id = C_ChallengeMode.GetActiveChallengeMapID()
  -- current_map_id is null if the world is not fully loaded yet (on_challenge_mode_start is called twice in that case)
  if current_map_id == nil then
    return
  end

  main.on_challenge_mode_start()
  timer.on_challenge_mode_start()
  criteria.on_challenge_mode_start()
  progress.on_challenge_mode_start()
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_challenge_mode_completed()
  local current_run = main.get_current_run()
  if current_run then
    current_run.is_completed = true
  end

  main.show_default_tracker()
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_challenge_mode_reset()
  main.hide_frame()
  main.show_default_tracker()
  main.reset_current_run()
end

-- ---------------------------------------------------------------------------------------------------------------------
local function resolve_current_instance_data()
  local _, _, _, _, _, _, _, current_zone_id = GetInstanceInfo()
  local cm_level, affixes = C_ChallengeMode.GetActiveKeystoneInfo()
  local current_map_id = C_ChallengeMode.GetActiveChallengeMapID()
  local _, _, steps = C_Scenario.GetStepInfo()
  local zone_name, _, max_time = C_ChallengeMode.GetMapUIInfo(current_map_id)

  local affixes_ids = {}
  local is_teeming = false
  for _, affix_id in pairs(affixes) do
    table.insert(affixes_ids, affix_id)

    if affix_id == 5 then
      is_teeming = true
    end
  end

  local affixes_key = "affixes"
  for _, k in ipairs(affixes_ids) do
    affixes_key = affixes_key .. "-" .. k
  end

  return {
    cm_level = cm_level,
    level_key = "l" .. cm_level,
    affixes = affixes,
    affixes_key = affixes_key,
    zone_name = zone_name,
    current_zone_id = current_zone_id,
    current_map_id = current_map_id,
    max_time = max_time,
    steps = steps,
    is_teeming = is_teeming,
  }
end

-- ---------------------------------------------------------------------------------------------------------------------
local function restart_challenge_mode()
  -- check if in active run
  local current_run = main.get_current_run()
  if current_run and not current_run.is_demo then
    main.hide_default_tracker()

    local data = resolve_current_instance_data()

    if current_run.level_key .. current_run.affixes_key ~= data.level_key .. data.affixes_key then
      current_run.times = {}
    end

    current_run.cm_level = data.cm_level
    current_run.level_key = data.level_key
    current_run.affixes = data.affixes
    current_run.affixes_key = data.affixes_key
    current_run.zone_name = data.zone_name
    current_run.current_zone_id = data.current_zone_id
    current_run.current_map_id = data.current_map_id
    current_run.max_time = data.max_time
    current_run.steps = data.steps
    current_run.is_teeming = data.is_teeming

    addon.set_config_value("current_run", current_run)

    update_dungeon_info(current_run)
    main.show_frame()

    current_run.steps = -1
    return
  end

  -- start new cm
  on_challenge_mode_start()
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_player_entering_world()
  main.on_player_entering_world()
  timer.on_player_entering_world()
  criteria.on_player_entering_world()
  progress.on_player_entering_world()
end

-- ---------------------------------------------------------------------------------------------------------------------
function main.on_player_entering_world()
  -- restart if in cm
  if main.is_in_cm() then
    restart_challenge_mode()
    return
  end

  -- hide timer
  main.hide_frame()
  main.show_default_tracker()
end

-- ---------------------------------------------------------------------------------------------------------------------
function main.on_challenge_mode_start()
  -- restart if in cm
  local ative_run = main.get_current_run()
  if ative_run and not ative_run.is_demo then
    restart_challenge_mode()
    return
  end

  -- hide default tracker
  main.hide_default_tracker()

  -- hide frames
  infos.hide_frames()
  criteria.hide_frames()

  if info_frames.affixes_icon then
    for _, frame in pairs(info_frames.affixes_icon) do
      frame:Hide()
    end
  end

  -- resolve current instance data
  local data = resolve_current_instance_data()

  local current_run = {
    cm_level = data.cm_level,
    level_key = data.level_key,
    affixes = data.affixes,
    affixes_key = data.affixes_key,
    zone_name = data.zone_name,
    current_zone_id = data.current_zone_id,
    current_map_id = data.current_map_id,
    max_time = data.max_time,
    steps = data.steps,
    is_teeming = data.is_teeming,
    times = {},
  }

  addon.set_config_value("current_run", current_run)

  -- create initial best times config entries
  local best_times = addon.c("best_times")

  if not best_times[current_run.current_zone_id] then
    best_times[current_run.current_zone_id] = {}
  end

  if not best_times[current_run.current_zone_id][current_run.level_key] then
    best_times[current_run.current_zone_id][current_run.level_key] = {}
  end

  if not best_times[current_run.current_zone_id][current_run.level_key .. current_run.affixes_key] then
    best_times[current_run.current_zone_id][current_run.level_key .. current_run.affixes_key] = {}
  end

  -- update dungeon info
  update_dungeon_info(current_run)

  -- show
  main.show_frame()
end

-- ---------------------------------------------------------------------------------------------------------------------
function main.get_current_run()
  return addon.c("current_run")
end

-- ---------------------------------------------------------------------------------------------------------------------
function main.reset_current_run()
  addon.set_config_value("current_run", nil)
end

-- ---------------------------------------------------------------------------------------------------------------------
function main.get_frame()
  return main_frame
end

-- ---------------------------------------------------------------------------------------------------------------------
function main.get_info_frames()
  return info_frames
end

-- ---------------------------------------------------------------------------------------------------------------------
function main.get_quest_frame(frame)
  local parent = frame:GetParent()

  if (parent == UIParent or parent == hidden_frame or parent == nil) then
    return frame
  end

  return main.get_quest_frame(parent)
end

-- ---------------------------------------------------------------------------------------------------------------------
function main.format_seconds(seconds)
  local min, sec = resolve_time(seconds)
  if min < 10 then
    min = "0" .. min
  end

  if sec < 10 then
    sec = "0" .. sec
  end

  return min .. ":" .. sec
end

-- ---------------------------------------------------------------------------------------------------------------------
function main.is_in_cm()
  local _, _, difficulty, _, _, _, _, _ = GetInstanceInfo()
  local _, elapsed_time = GetWorldElapsedTime(1)

  return C_ChallengeMode.IsChallengeModeActive() and difficulty == 8 and elapsed_time >= 0
end

-- ---------------------------------------------------------------------------------------------------------------------
function main.hide_default_tracker()
  if not addon.c("hide_default_objectivetracker") then
    return
  end

  if not main.is_in_cm() then
    return
  end

  local in_combat = InCombatLockdown() or UnitAffectingCombat("player")
  if not in_combat then
    if quest_frame:GetParent() ~= hidden_frame then
      quest_frame:SetParent(hidden_frame)
    end
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
function main.show_default_tracker()
  if not addon.c("hide_default_objectivetracker") then
    return
  end

  local in_combat = InCombatLockdown() or UnitAffectingCombat("player")
  if not in_combat then
    quest_frame:SetParent(UIParent)
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
function main.show_frame()
  main_frame:Show()
end

-- ---------------------------------------------------------------------------------------------------------------------
function main.hide_frame()
  main_frame:Hide()
end

-- ---------------------------------------------------------------------------------------------------------------------
function main.toggle_frame_movement()
  toggle_frame_movement()
end

-- ---------------------------------------------------------------------------------------------------------------------
function main.is_frame_moveable()
  return main_frame.frame_toggle
end

-- ---------------------------------------------------------------------------------------------------------------------
function main.show_demo()
  show_demo()
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Init
function main:init()
  config = addon.get_module("config")
  criteria = addon.get_module("criteria")
  timer = addon.get_module("timer")
  progress = addon.get_module("progress")
  infos = addon.get_module("infos")
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Enable
function main:enable()
  -- create frame
  create_main_frame()

  -- create hidden frame (used to hide the objective tracker, otherwise other addons can show the tracker again)
  hidden_frame = CreateFrame("Frame")
  hidden_frame:Hide()

  -- find quest frame (used to find object tracker, other addons could have moved the tracker frame)
  quest_frame = main.get_quest_frame(ObjectiveTrackerFrame)

  -- create config entries if needed
  local best_times = addon.c("best_times")
  if not best_times then
    addon.set_config_value("best_times", {})
  end

  -- register events
  addon.register_event("CHALLENGE_MODE_START", on_challenge_mode_start)
  addon.register_event("CHALLENGE_MODE_COMPLETED", on_challenge_mode_completed)
  addon.register_event("CHALLENGE_MODE_RESET", on_challenge_mode_reset)
  addon.register_event("PLAYER_ENTERING_WORLD", on_player_entering_world)

  -- config listeners
  addon.register_config_listener("scale", on_scale_change)
  addon.register_config_listener("hide_default_objectivetracker", on_objectivetracker_change)
  addon.register_config_listener("show_affixes_as_icons", on_config_change)
  addon.register_config_listener("show_affixes_as_text", on_config_change)
  addon.register_config_listener("color_dungeon_name", on_config_change)
  addon.register_config_listener("color_affixes", on_config_change)
  addon.register_config_listener("color_timeleft", on_config_change)
  addon.register_config_listener("color_timeleft_expired", on_config_change)
  addon.register_config_listener("color_time", on_config_change)
  addon.register_config_listener("color_chest_timeleft", on_config_change)
  addon.register_config_listener("color_chest_time", on_config_change)
  addon.register_config_listener("color_chest_time_expired", on_config_change)
end
