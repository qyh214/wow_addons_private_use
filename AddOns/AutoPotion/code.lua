local L = LibStub("AceLocale-3.0"):GetLocale("AutoPotion")
local addonName, ham = ...
local macroName = L["AutoPotion"]
local isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
local isWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
local isCata = (WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC)
local isMop = (WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC)

-- Configuration options
-- Use in-memory options as HAMDB updates are not persisted instantly.
-- We'll also use lazy initialization to prevent early access issues.
setmetatable(ham, {
  __index = function(t, k)
    if k == "options" then
      t.options = {
        cdReset = HAMDB.cdReset or false,
        stopCast = HAMDB.stopCast or false,
        raidStone = HAMDB.raidStone or false,
        witheringPotion = HAMDB.witheringPotion or false,
        witheringDreamsPotion = HAMDB.witheringDreamsPotion or false,
        cavedwellerDelight = HAMDB.cavedwellerDelight or true,
        heartseekingInjector = HAMDB.heartseekingInjector or false,
      }
      return t.options
    end
  end
})

ham.debug = false
ham.tinkerSlot = nil
ham.myPlayer = ham.Player.new()

local spellsMacroString = ''
local itemsMacroString = ''
local macroStr = ''
local resetType = "combat"
local shortestCD = nil
local bagUpdates = false -- debounce watcher for BAG_UPDATE events
local debounceTime = 3   -- seconds
local combatRetry = 0    -- number of combat retries

-- MegaMacro addon compatibility
local megaMacro = {
  name = "MegaMacro", -- the addon name
  retries = 0,        -- number of loaded checks to prevent infinite loop
  checked = false,    -- did we check for the addon?
  installed = false,  -- is the addon installed?
  loaded = false,     -- is the addon loaded?
}

-- Slots to check for tinkers
-- As of 2024-10-27, only Head, Wrist and Guns can have tinkers.
local tinkerSlots = {
  1,  -- Head
  9,  -- Wrist
  18, -- Gun
  14, -- Trinket 2 (for debugging)
}

local function log(message)
  if ham.debug then
    print("|cffb48ef9AutoPotion:|r " .. message)
  end
end

local function addPlayerHealingItemIfAvailable()
  if isRetail and ham.options.heartseekingInjector and ham.tinkerSlot then
    table.insert(ham.itemIdList, "slot:" .. ham.tinkerSlot)
  end
  for i, value in ipairs(ham.myPlayer.getHealingItems()) do
    if value.getCount() > 0 then
      table.insert(ham.itemIdList, value.getId())
      break;
    end
  end
end

local function addHealthstoneIfAvailable()
  if isClassic == true or isWrath == true or isCata == true or isMop == true then
    for i, value in ipairs(ham.getHealthstonesClassic()) do
      if value.getCount() > 0 then
        table.insert(ham.itemIdList, value.getId())
        --we break because all Healthstones share a cd so we only want the highest healing one
        break;
      end
    end
  else
    if ham.healthstone.getCount() > 0 then
      table.insert(ham.itemIdList, ham.healthstone.getId())
    end
    if ham.demonicHealthstone.getCount() > 0 then
      table.insert(ham.itemIdList, ham.demonicHealthstone.getId())
      if ham.options.cdReset then
        if shortestCD == nil then
          shortestCD = 60
        end
        if 60 < shortestCD then
          shortestCD = 60
        end
      end
    end
  end
end

local function addPotIfAvailable(useDelightPots)
  log("Updating pot counts...")
  useDelightPots = useDelightPots or false
  local pots = useDelightPots and ham.getDelightPots() or ham.getPots()
  for i, value in ipairs(pots) do
    log("Item: " .. tostring(value.getId()) .. " Count: " .. tostring(value.getCount()))
    if value.getCount() > 0 then
      table.insert(ham.itemIdList, value.getId())
      --we break because all Pots share a cd so we only want the highest healing one
      break;
    end
  end
end

function ham.updateHeals()
  ham.itemIdList = {}
  ham.spellIDs = ham.myPlayer.getHealingSpells()

  -- Priority 1: Add player items, including tinkers
  addPlayerHealingItemIfAvailable()

  -- Priority 2: Add Healthstone if NOT set to lower priority
  if not ham.options.raidStone then
    addHealthstoneIfAvailable()
  end

  -- Priority 3: Add Health Pots if available, and Heartseeking is NOT available or enabled
  if not ham.options.heartseekingInjector or not ham.tinkerSlot then
    addPotIfAvailable()
  end

  -- Priority 4: Add Cavedweller's Delight if enabled
  if ham.options.cavedwellerDelight then
    addPotIfAvailable(true)
  end

  -- Priority 5: Add Healthstone if set to lower priority
  if ham.options.raidStone then
    addHealthstoneIfAvailable()
  end
end

local function createMacroIfMissing()
  -- dont create macro if MegaMacro is installed and loaded
  if megaMacro.installed and megaMacro.loaded then
    return
  end
  local name = GetMacroInfo(macroName)
  if name == nil then
    CreateMacro(macroName, "INV_Misc_QuestionMark")
  end
end

local function setShortestSpellCD(newSpell)
  if ham.options.cdReset then
    local cd
    cd = GetSpellBaseCooldown(newSpell) / 1000
    if shortestCD == nil then
      shortestCD = cd
    end
    if cd < shortestCD then
      shortestCD = cd
    end
  end
end

local function setResetType()
  if ham.options.cdReset == true and shortestCD ~= nil then
    resetType = "combat/" .. shortestCD
  else
    resetType = "combat"
  end
end

local function buildSpellMacroString()
  spellsMacroString = ''

  if next(ham.spellIDs) ~= nil then
    for i, spell in ipairs(ham.spellIDs) do
      local name
      if isRetail == true then
        name = C_Spell.GetSpellName(spell)
      else
        name = GetSpellInfo(spell)
      end

      setShortestSpellCD(spell)

      --TODO HEALING Elixir Twice because it has two charges ?! kinda janky but will work for now
      if spell == ham.healingElixir then
        name = name .. ", " .. name
      end
      if i == 1 then
        spellsMacroString = name;
      else
        spellsMacroString = spellsMacroString .. ", " .. name;
      end
    end
  end
end

local function buildItemMacroString()
  if next(ham.itemIdList) ~= nil then
    for i, name in ipairs(ham.itemIdList) do
      local entry
      -- Check if the entry starts with "slot:" and extract the slot number
      if type(name) == "string" and name:match("^slot:") then
        entry = name:sub(6)               -- Extract everything after "slot:"
      else
        entry = "item:" .. tostring(name) -- Default to item ID formatting
      end
      -- Add the entry to the macro string
      if i == 1 then
        itemsMacroString = entry
      else
        itemsMacroString = itemsMacroString .. ", " .. entry
      end
    end
  end
end

local function UpdateMegaMacro(newCode)
  for _, macro in pairs(MegaMacroGlobalData.Macros) do
    if macro.DisplayName == macroName then
      MegaMacro.UpdateCode(macro, newCode)
      log("MegaMacro updated with: " .. newCode)
      return
    end
  end
  print(
    "|cffff0000AutoPotion Error:|r Missing global 'AutoPotion' macro in MegaMacro. Please create it then reload your game.")
end

local function checkMegaMacroAddon()
  -- MegaMacro is only available for retail
  if not isRetail then
    megaMacro.checked = true
    return
  end

  -- is MegaMacro installed?
  local name = C_AddOns.GetAddOnInfo(megaMacro.name)
  if not name then
    megaMacro.installed = false
    megaMacro.checked = true
    return
  end

  megaMacro.installed = true

  -- is the addon loaded?
  if C_AddOns.IsAddOnLoaded(megaMacro.name) then
    megaMacro.loaded = true
    megaMacro.checked = true
    return
  end

  -- Retry loading if not yet loaded
  if megaMacro.retries < 3 then
    megaMacro.retries = megaMacro.retries + 1
    C_Timer.After(debounceTime, checkMegaMacroAddon)
  else
    megaMacro.checked = true
  end
end

-- check if player has the engineering tinker: Heartseeking Health Injector
function ham.checkTinker()
  if not isRetail then return end
  ham.tinkerSlot = nil -- always reset
  for _, slot in ipairs(tinkerSlots) do
    local itemID = GetInventoryItemID("player", slot)
    if itemID then
      local spellName, spellID = C_Item.GetItemSpell(itemID)
      if spellName then
        -- note: i'm not an engineer, so i use a trinket with a use effect for debugging.
        -- this is why the "Phylactery" reference exists if debugging is enabled --- phuze.
        -- note: Using "spellName" to find "Heartseeking" can only support English region.
        -- So I add spellID to support other region, e.g. Taiwan (TW), China (CN) and Korea (KR) --- Nephits
        if ham.debug then
          if spellName:find("Phylactery") or spellName:find("Heartseeking") or spellID == 452767 then
            ham.tinkerSlot = slot
          end
        else
          if spellName:find("Heartseeking") or spellID == 452767 then
            ham.tinkerSlot = slot
          end
        end
      end
    end
  end
end

function ham.updateMacro()
  if next(ham.itemIdList) == nil and next(ham.spellIDs) == nil then
    macroStr = "#showtooltip"
    if ham.options.stopCast then
      macroStr = macroStr .. "\n/stopcasting \n"
    end
  else
    resetType = "combat"
    buildItemMacroString()
    buildSpellMacroString()
    setResetType()
    macroStr = "#showtooltip \n"
    if ham.options.stopCast then
      macroStr = macroStr .. "/stopcasting \n"
    end
    macroStr = macroStr .. "/castsequence [@player] reset=" .. resetType .. " "
    if spellsMacroString ~= "" then
      macroStr = macroStr .. spellsMacroString
    end
    if spellsMacroString ~= "" and itemsMacroString ~= "" then
      macroStr = macroStr .. ", "
    end
    if itemsMacroString ~= "" then
      macroStr = macroStr .. itemsMacroString
    end
  end

  if not megaMacro.checked then
    log("MegaMacro not checked. Retrying.")
    checkMegaMacroAddon()
    return
  end

  if megaMacro.installed and megaMacro.loaded then
    UpdateMegaMacro(macroStr)
    return
  end

  log('MegaMacro not in use. Creating default macro.')
  createMacroIfMissing()

  -- Use pcall to suppress LUA errors
  local success, err = pcall(function()
    EditMacro(macroName, macroName, nil, macroStr)
  end)
  if success then
    log('Macro updated.')
  end
end

local function MakeMacro()
  -- dont attempt to create macro until MegaMacro addon is checked
  if not megaMacro.checked then
    log("MegaMacro not checked or loaded. Retrying.")
    checkMegaMacroAddon()
    return
  end

  -- retry if player is still in combat
  if InCombatLockdown() then
    if combatRetry < 4 then
      combatRetry = combatRetry + 1
      log("Player in combat. Retry attempt: " .. combatRetry)
      C_Timer.After(0.5, MakeMacro)
    else
      log("Failed to update macro after 4 attempts.")
    end
    return
  end

  -- safe to update macro
  combatRetry = 0
  ham.checkTinker()
  ham.updateHeals()
  ham.updateMacro()
  ham.settingsFrame:updatePrio()
end

-- debounce handler for BAG_UPDATE events which can fire very rapidly
local function onBagUpdate()
  if bagUpdates then
    return
  end
  log("event: BAG_UPDATE")
  bagUpdates = true
  C_Timer.After(debounceTime, function()
    MakeMacro()
    bagUpdates = false
  end)
end

local updateFrame = CreateFrame("Frame")
updateFrame:RegisterEvent("ADDON_LOADED")
updateFrame:RegisterEvent("BAG_UPDATE")
updateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
updateFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
if isClassic == false then
  updateFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
end
updateFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
updateFrame:RegisterEvent("UNIT_PET")
updateFrame:SetScript("OnEvent", function(self, event, arg1, ...)
  -- when addon is loaded
  if event == "ADDON_LOADED" and arg1 == addonName then
    updateFrame:UnregisterEvent("ADDON_LOADED")
    log("event: ADDON_LOADED")
    MakeMacro()
    return
  end
  -- player is in combat, do nothing
  if InCombatLockdown() then
    return
  end
  -- bag update events
  if event == "BAG_UPDATE" then
    onBagUpdate()
    -- on loading/reloading
  elseif event == "UNIT_PET" then
    log("event: UNIT_PET")
    MakeMacro()
    -- when pet is called
  elseif event == "PLAYER_ENTERING_WORLD" then
    log("event: PLAYER_ENTERING_WORLD")
    MakeMacro()
    -- on exiting combat
  elseif event == "PLAYER_REGEN_ENABLED" then
    log("event: PLAYER_REGEN_ENABLED")
    -- Wait a second after combat ends to update the macro
    -- as the UI may still be cleaning up a protected state.
    C_Timer.After(0.5, MakeMacro)
    -- when talents change and classic is false
  elseif isClassic == false and event == "TRAIT_CONFIG_UPDATED" then
    log("event: TRAIT_CONFIG_UPDATED")
    MakeMacro()
    -- when player changes equipment
  elseif event == "PLAYER_EQUIPMENT_CHANGED" then
    log("event: PLAYER_EQUIPMENT_CHANGED")
    MakeMacro()
  end
end)
