local _, addon = ...
local progress = addon.new_module("progress")

-- ---------------------------------------------------------------------------------------------------------------------
local main

-- ---------------------------------------------------------------------------------------------------------------------
local last_kill
local last_quantity

-- ---------------------------------------------------------------------------------------------------------------------
local function resolve_npc_id(guid)
  local target_type, _, _, _, _, npc_id = strsplit("-", guid)
  if target_type == "Vehicle" or target_type == "Creature" and npc_id then
    return tonumber(npc_id)
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
local function update_progress_value(npc_id, value, is_teeming)
  -- resolve npc progress data
  local progress_key = "npc_progress"
  if is_teeming then
    progress_key = "npc_progress_teeming"
  end

  local npc_progress = addon.c(progress_key)
  if npc_progress == nil then
    npc_progress = {}
  end

  if not npc_progress[npc_id] then
    npc_progress[npc_id] = {}
  end

  -- add 1 to the current value weight
  if npc_progress[npc_id][value] == nil then
    npc_progress[npc_id][value] = 1
  else
    npc_progress[npc_id][value] = npc_progress[npc_id][value] + 1
  end

  -- reduce the weight of all other values so the current one will eventually overtake the most seen one
  for val, occurrences in pairs(npc_progress[npc_id]) do
    if val ~= value then
      npc_progress[npc_id][val] = occurrences * 0.80
    end
  end

  addon.set_config_value(progress_key, npc_progress)
end

-- ---------------------------------------------------------------------------------------------------------------------
local function get_progress_value(npc_id, is_teeming)
  -- resolve npc progress data
  local progress_key = "npc_progress"
  if is_teeming then
    progress_key = "npc_progress_teeming"
  end

  local npc_progress = addon.c(progress_key)
  if not npc_progress then
    return
  end

  if not npc_progress[npc_id] then
    return
  end

  -- get progress value
  local value, occurrences = nil, -1
  for val, val_occurrences in pairs(npc_progress[npc_id]) do
    if val_occurrences > occurrences then
      value, occurrences = val, val_occurrences
    end
  end

  return value
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_combat_log_event_unfiltered()
  local _, sub_event, _, _, _, _, _, dest_guid = CombatLogGetCurrentEventInfo()

  -- remove guid from pull on unit died
  if sub_event == "UNIT_DIED" then
    local current_run = main.get_current_run()
    if current_run and current_run.pull and current_run.pull[dest_guid] then
      current_run.pull[dest_guid] = nil
    end
  end

  -- skip if not a party kill event
  if sub_event ~= "PARTY_KILL" then
    return
  end

  -- skip if not in cm
  if not main.is_in_cm() then
    return
  end

  -- setup
  if not last_kill then
    last_kill = {}
  end

  local kill_time = GetTime() * 1000

  if not last_kill[1] or last_kill[1] == nil then
    last_kill[1] = kill_time
  end

  -- resolve last_kill data
  local npc_id = resolve_npc_id(dest_guid)
  if npc_id then
    local valid = ((kill_time) - last_kill[1]) > 100
    last_kill = {kill_time, npc_id, valid}
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_scenario_criteria_update()
  -- check if we have an run
  local current_run = main.get_current_run()
  if not current_run then
    return
  end

  -- skip if run is completed
  if current_run.is_completed then
    return
  end

  -- resolve enemy forces quantity
  local _, _, steps = C_Scenario.GetStepInfo()
  if not steps or steps <= 0 then
    return
  end

  local _, _, _, _, final_value, _, _, quantity = C_Scenario.GetCriteriaInfo(steps)
  local quantity_number = string.sub(quantity, 1, string.len(quantity) - 1)
  quantity_number = tonumber(quantity_number)

  if quantity_number == nil then
    return
  end

  -- set last_quantity if not set (first kill after start / restart will not be calculated)
  if last_quantity == nil then
    last_quantity = quantity_number
    return
  end

  if last_quantity >= final_value or quantity_number >= final_value then
    return
  end

  -- resolve progress
  local delta = quantity_number - last_quantity
  if delta > 0 and last_kill then
    local timestamp, npc_id, valid = unpack(last_kill)

    if timestamp and npc_id and delta and valid then
      if (GetTime() * 1000) - timestamp <= 100 then
        update_progress_value(npc_id, delta, current_run.is_teeming)
      end
    end
  end

  last_quantity = quantity_number
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_tooltip_set_unit(tooltip)
  -- check if tooltip must be updated
  if not addon.c("progress_tooltip") then
    return
  end

  local unit = select(2, tooltip:GetUnit())
  if not unit then
    return
  end

  if not main.is_in_cm() then
    return
  end

  local current_run = main.get_current_run()
  if not current_run then
    return
  end

  if not UnitCanAttack("player", unit) or UnitIsDead(unit) then
    return
  end

  -- resolve value
  local guid = UnitGUID(unit)
  local npc_id = resolve_npc_id(guid)
  if not npc_id then
    return
  end

  local value, is_mdt_value = progress.resolve_npc_progress_value(npc_id, current_run.is_teeming)
  if not value or value == 0 then
    return
  end

  -- calculate percent
  local _, _, steps = C_Scenario.GetStepInfo()
  if not steps or steps <= 0 then
    return
  end

  local _, _, _, _, final_value = C_Scenario.GetCriteriaInfo(steps)
  local quantity_percent = (value / final_value) * 100
  local mult = 10 ^ 2
  quantity_percent = math.floor(quantity_percent * mult + 0.5) / mult
  if (quantity_percent > 100) then
    quantity_percent = 100
  end

  -- create tooltip info
  local name = C_Scenario.GetCriteriaInfo(steps)

  local text = ""
  if addon.c("show_percent_numbers") then
    text = text .. quantity_percent .. "%"
  end

  if addon.c("show_absolute_numbers") then
    if addon.c("show_percent_numbers") then
      text = text .. " (+" .. value .. ")"
    else
      text = text .. value
    end
  end

  local mdt_info = ""
  -- if is_mdt_value then
  --   mdt_info = " [MDT]"
  -- end

  GameTooltip:AddDoubleLine(name .. ": +" .. text .. mdt_info)
  GameTooltip:Show()
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_unit_threat_list_update(unit)
  -- skip if not in combat
  if not InCombatLockdown() or not unit or not UnitExists(unit) or UnitIsDead(unit) then
    return
  end

  -- skip if not in cm
  if not main.is_in_cm() then
    return
  end

  -- check if we have an run
  local current_run = main.get_current_run()
  if not current_run then
    return
  end

  if not current_run.pull then
    current_run.pull = {}
  end

  -- resolve npc id & value
  local guid = UnitGUID(unit)
  if not guid or current_run.pull[guid] then
    return
  end

  local npc_id = resolve_npc_id(guid)
  if not npc_id then
    return
  end

  local _, _, steps = C_Scenario.GetStepInfo()
  if not steps or steps <= 0 then
    return
  end

  local _, _, _, _, final_value = C_Scenario.GetCriteriaInfo(steps)

  local value = progress.resolve_npc_progress_value(npc_id, current_run.is_teeming)
  if value and value ~= 0 then
    local in_percent = (value / final_value) * 100
    local mult = 10 ^ 2
    in_percent = math.floor(in_percent * mult + 0.5) / mult

    current_run.pull[guid] = {value, in_percent}
  end
end

-- ---------------------------------------------------------------------------------------------------------------------
local function on_combat_end()
  -- check if we have an run
  local current_run = main.get_current_run()
  if not current_run then
    return
  end

  -- reset pull
  if not current_run.pull then
    return
  end

  current_run.pull = {}
end

-- ---------------------------------------------------------------------------------------------------------------------
function progress.on_challenge_mode_start()
  last_kill = nil
  last_quantity = nil
end

-- ---------------------------------------------------------------------------------------------------------------------
function progress.on_player_entering_world()
  last_kill = nil
  last_quantity = nil
end

-- ---------------------------------------------------------------------------------------------------------------------
function progress.resolve_npc_progress_value(npc_id, is_teeming)
  local value = nil
  local is_mdt_value = false
  if MDT ~= nil then
    local mdtValue, _, _, mdtTeemingValue = MDT:GetEnemyForces(npc_id)

    if is_teeming and mdtTeemingValue then
      value = mdtTeemingValue
    else
      value = mdtValue
    end

    is_mdt_value = true
  end

  if not value or value == 0 then
    value = get_progress_value(npc_id, is_teeming)
    is_mdt_value = false
  end

  return value, is_mdt_value
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Init
function progress:init()
  main = addon.get_module("main")
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Enable
function progress:enable()
  -- register events
  addon.register_event("COMBAT_LOG_EVENT_UNFILTERED", on_combat_log_event_unfiltered)
  addon.register_event("SCENARIO_CRITERIA_UPDATE", on_scenario_criteria_update)
  addon.register_event("UNIT_THREAT_LIST_UPDATE", on_unit_threat_list_update)
  addon.register_event("ENCOUNTER_END", on_combat_end)
  addon.register_event("PLAYER_REGEN_ENABLED", on_combat_end)
  addon.register_event("PLAYER_DEAD", on_combat_end)

  -- hook into tooltip
  GameTooltip:HookScript("OnTooltipSetUnit", on_tooltip_set_unit)
end
