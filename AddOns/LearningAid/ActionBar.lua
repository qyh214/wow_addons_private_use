--[[

Learning Aid is copyright © 2008-2015 Jamash (Kil'jaeden US Horde)
Email: jamashkj@gmail.com

ActionBar.lua is part of Learning Aid.

  Learning Aid is free software: you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation, either version 3 of the
  License, or (at your option) any later version.

  Learning Aid is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with Learning Aid.  If not, see
  <http://www.gnu.org/licenses/>.

To download the latest official version of Learning Aid, please visit 
either Curse or WowInterface at one of the following URLs: 

http://wow.curse.com/downloads/wow-addons/details/learningaid.aspx

http://www.wowinterface.com/downloads/info10622-LearningAid.html

Other sites that host Learning Aid are not official and may contain 
outdated or modified versions. If you have obtained Learning Aid from 
any other source, I strongly encourage you to use Curse or WoWInterface 
for updates in the future. 

]]

local addonName, private = ...
local LA = private.LA

local strLower = string.lower

local castPrefixes = {
  --"USE",
  --"USERANDOM",
  "CAST",
  "CASTRANDOM",
  "CASTSEQUENCE"
}
local castSlashCommands = { }
-- build table of all /cast and similar macro command aliases
for _, castPrefix in ipairs(castPrefixes) do
  local str
  local command
  local index = 1
  while true do
    str = "SLASH_"..castPrefix..index
    command = _G[str]
    if not command then
      break
    end
    command = strLower(command)
    LA:DebugPrint("Cast Slash Command "..str.." = "..command)
    castSlashCommands[command] = true
    index = index + 1
  end
end
LA.castSlashCommands = castSlashCommands
--[[{
  [SLASH_USE1] = true,
  [SLASH_USE2] = true,
  [SLASH_USERANDOM1] = true,
  [SLASH_USERANDOM2] = true,
  [SLASH_CAST1] = true,
  [SLASH_CAST2] = true,
  [SLASH_CAST3] = true,
  [SLASH_CAST4] = true,
  [SLASH_CASTRANDOM1] = true,
  [SLASH_CASTRANDOM2] = true,
  [SLASH_CASTSEQUENCE1] = true,
  [SLASH_CASTSEQUENCE2] = true
} ]]
-- macroText is the text of a macro from the official Macro UI or an addon
-- returns a table of spells found in the macro of the form
-- { "spellName1" = true, spellGlobalID1 = true, "spellName2" = true, spellGlobalID2 = true, ...}
-- spell names are all lower case, global ids are integers
function LA:MacroSpells(macroText)
  macroText = strLower(macroText)
  local spells = {}
  local first, last, line
  first, last, line = macroText:find("([^\n]+)[\n]?")
  while first ~= nil do
    self:DebugPrint("Line",line)
    -- catch /cast, /castsequence, /castrandom
    local lineFirst, lineLast, slash = line:find("^(/cast[sequncradom]*)%s+")
    if lineFirst ~= nil then
      self:DebugPrint('Slash "'..slash..'"')
      if self.castSlashCommands[slash] then
        --self:DebugPrint("found slash command")
        local token
        local linePos = lineLast
        local found = true
        while found do
          while found do
            found = false
            -- skip reset=
            lineFirst, lineLast = line:find("^reset=%S+%s*", linePos + 1)
            if lineLast ~= nil then linePos = lineLast; found = true end
            -- skip macro options inside square brackets [ ]
            lineFirst, lineLast = line:find("^%[[^%]]*]", linePos + 1)
            if lineLast ~= nil then linePos = lineLast; found = true end
            -- skip whitespace and delimiters
            lineFirst, lineLast = line:find("^[%s,;]+", linePos + 1)
            if lineLast ~= nil then linePos = lineLast; found = true end
          end
          found = false
          lineFirst, lineLast, token = line:find("^([^%[,;]+)", linePos + 1)
          if lineLast ~= nil then
            token = strtrim(token)
            linePos = lineLast
            found = true
            self:DebugPrint('Token: "'..token..'"')
            -- spells[token] = true
            -- not self:GetRealSpellBookItemInfo because the extra info is not needed,
            -- and <token> may contain strings like mount names that are not in the spellbook
            local status, globalID = GetSpellBookItemInfo(token)
            if (not status) and self.nameToGlobal[token] then 
              status, globalID = "SPELL", self.nameToGlobal[token]
            end
            if "SPELL" == status then
              local spell = self.Spell.Global[globalID]
              spells[spell.ID] = true
              spells[spell.SpecID] = true
              self:DebugPrint("Adding "..tostring(spell))
            else
              self:DebugPrint("Status is "..tostring(status))
            end
          end
        end
      end
    end
    first, last, line = macroText:find("([^\n]+)\n?", last + 1)
  end
  return spells
end
function LA:DiffActionBars()
  local spec = GetActiveSpecGroup()
  for slot = 1, 120 do
    local actionType = GetActionInfo(slot)
    -- local actionType, actionID, actionSubType, globalID = GetActionInfo(slot)
    -- If this slot once held a spell
    if self.character.actions and 
       self.character.actions[spec] and
       self.character.actions[spec][slot] and
       not actionType
    then
      -- Ensure self.character.unlearned[spec][slot] exists
      if not self.character.unlearned then self.character.unlearned = { } end
      if not self.character.unlearned[spec] then self.character.unlearned[spec] = { } end
      if not self.character.unlearned[spec][slot] then self.character.unlearned[spec][slot] = { } end
      -- Save the old unlearned spell info in the "unlearned" table for future restoration
      self.character.unlearned[spec][slot][self.character.actions[spec][slot]] = true
    end
  end
end
function LA:SaveActionBars()
  local spec = GetActiveSpecGroup()
  if self.character.actions == nil then self.character.actions = {} end
  if self.character.actions[spec] then
    wipe(self.character.actions[spec])
  else
    self.character.actions[spec] = { }
  end
  local savedActions = self.character.actions[spec]
  for actionSlot = 1, 120 do
    local actionType, globalID, actionSubType = GetActionInfo(actionSlot)
    if actionType == "spell" then
      savedActions[actionSlot] = globalID
    end
  end
end
function LA:FindMissingActions()
  if InCombatLockdown() then
    DEFAULT_CHAT_FRAME:AddMessage(self:GetText("title")..": "..self:GetText("errorInCombat"))
    return
  end
  local spells = {}
  local types = {}
  local subTypes = {}
  --local tracking = {}
  --local shapeshift = {}
  --local totem = {}
  local results = {}
  local macroSpells = {}
  local flyouts = {}
  local numTrackingTypes = GetNumTrackingTypes()
  --local bookCache = self.spellBookCache
  --local infoCache = self.spellInfoCache

  --[[
  if not self.saved.tracking then
    for trackingType = 1, numTrackingTypes do
      local name, texture, active, category = GetTrackingInfo(trackingType)
      if category == BOOKTYPE_SPELL then
        tracking[name] = true
      end
    end
  end
  ]]
  if (not self.saved.totem) and self.enClass == "SHAMAN" then
    -- Treat all Totem spells as though already on an action bar.
    self:DebugPrint("Searching for totems")
    for totemType = 1, MAX_TOTEMS do
      local totemSpells = {GetMultiCastTotemSpells(totemType)}
      for index, globalID in ipairs(totemSpells) do
        -- name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(spell)
        --local totemName = GetSpellInfo(globalID)
        spells[globalID] = true
        --self:DebugPrint("Found totem "..totemName)
      end
    end
  end
  for slot = 1, 120 do
    local actionType, actionID, actionSubType = GetActionInfo(slot)
    if actionSubType == nil then
      actionSubType = "nil"
    end
    if actionType == nil then
      actionType = "nil"
    end
    -- development info
    if not types[actionType] then
      self:DebugPrint("Type of "..slot.." = "..actionType)
      types[actionType] = true
    end
    if not subTypes[actionSubType] then
      self:DebugPrint("Subtype of"..slot.." = "..actionSubType)
      subTypes[actionSubType] = true
    end
    if actionType == "spell" then
      local spell = self.Spell.Global[actionID]
      --self:DebugPrint("Found globalID for spell "..actionID..'='..self.specSpellCache[actionID])
      local gID = spell.ID
      local sID = spell.SpecID
      self:DebugPrint(self.name..":FindMissingActions() found spell "..actionID.."/"..gID.."/"..sID.." in action slot "..slot)
      spells[gID] = true
      spells[sID] = true
      
    elseif actionType == "flyout" then
      -- flyoutID = actionID
      -- local name, description, size, flyoutKnown = GetFlyoutInfo(actionID)
      local flyout = LearningAid.Spell.Flyout[actionID]
      if flyout.Known then
        flyouts[actionID] = true
        for flyoutSlot = 1, flyout.Size do
          --local globalID, known = GetFlyoutSlotInfo(actionID, flyoutSlot)
          local flyoutSpell = flyout[flyoutSlot]
          if flyoutSpell.Known then
            -- local spellBookID = FindSpellBookSlotBySpellID(globalID)
            spells[flyoutSpell.ID] = true
          end
        end
      end
    elseif actionType == "macro" and actionID ~= 0 and self.saved.macros then
      self:DebugPrint("Macro in slot "..slot.." with ID "..actionID)
      local body = GetMacroBody(actionID)
      local foundSpells = self:MacroSpells(body)
      for spell in pairs(foundSpells) do
        macroSpells[spell] = true
      end
    end
  end
  -- Macaroon support code
  if self.saved.macros and Macaroon and Macaroon.Buttons then
    for index, button in ipairs(Macaroon.Buttons) do
      local buttonType = button[1].config.type
      local macroText = button[1].config.macro
      local storage = button[2]
      if (buttonType == "macro") and (storage == 0) then
        self:DebugPrint("Macaroon macro in slot", index)
        local foundSpells = self:MacroSpells(macroText)
        for spell in pairs(foundSpells) do
          macroSpells[spell] = true
        end
      end
    end
  end
  -- End Macaroon code
  if not self.saved.shapeshift then
    -- Treat all Shapeshift/stance/presence/aspect spells as though already on an action bar
    local numForms = GetNumShapeshiftForms()
    for form = 1, numForms do
      local formTexture, formName, formIsCastable, formIsActive, globalID = GetShapeshiftFormInfo(form)
      assert(globalID)
      spells[globalID] = true
    end
  end
  if not self.saved.autoAttack then
    -- Treat Auto Shot, Auto Attack and Shoot (Wand) as though already on an action bar
    spells[self.autoAttack] = true
    spells[self.autoShot] = true
    spells[self.shootWand] = true
  end
  for tab = 1, 2 do
    local _, _, start, count = GetSpellTabInfo(tab) -- the current spec
    for i = start + 1, start + count do
      local spell = self.Spell.Book[i]
      assert(spell, "Spell "..i.." doesn't exist!")
      if "SPELL" == spell.Status then
        local spellName = spell.Name
        local spellNameLower = strLower(spellName)
        local globalID = spell.ID
        local specID = spell.SpecID
        if spell.Known and not (
          self:IsIgnored(spell) or
          spells[globalID] or
          spells[specID] or -- spell is on any action bar
          spell.Passive or
          -- spell is not a tracking spell, or displaying tracking spells has been enabled
          --(not tracking[spellName]) and
          -- spells[globalID] or
          -- totem[globalID] or
          macroSpells[spellNameLower] or
          macroSpells[globalID]
        )
        then
          self:DebugPrint("Spell "..globalID..' "'..spellName..'" is not on any action bar.')
        --if macroSpells[spellNameLower] then self:DebugPrint("Found spell in macro") end
          table.insert(results, spell)
        end
      elseif "FLYOUT" == spell.Status and not flyouts[spell.ID] then
        -- print("you have not got "..spell.Name.." on your action bar bro") -- DEBUG FIXME DEBUG FIXME
        table.insert(results, spell)
      end
    end
  end
  table.sort(results, function (a, b) return a.Slot < b.Slot end)
  for index = 1, #results do
    self:AddButton(results[index])
  end
end

function LA:RestoreAction(globalID)
  -- self.character.actions[spec][slot] = globalID
  local spec = GetActiveSpecGroup()
  if self.character.actions and self.character.actions[spec] then -- and self.character.actions[spec][globalID]
    for actionSlot, id in pairs(self.character.actions[spec]) do
      if id == globalID then
        self:DebugPrint("RestoreAction("..globalID.."): Found action at action slot "..actionSlot)
        --local actionType, actionID, actionSubType, slotGlobalID = GetActionInfo(actionSlot)
        local actionType = GetActionInfo(actionSlot)
        if actionType == nil then
          local bookID
          if self.spellBookCache[globalID] then
            bookID = self.spellBookCache[globalID].bookID
            self:DebugPrint("RestoreAction("..globalID.."): Found action at Spellbook slot "..bookID)
            PickupSpell(bookID, BOOKTYPE_SPELL)
            PlaceAction(actionSlot)
          end
        end
      end
    end
  end
end
local actionBarAliases = {
  default = 1,
  lowerleft = 1,
  alternate = 2,
  farright = RIGHT_ACTIONBAR_PAGE, -- 3
  nearright = LEFT_ACTIONBAR_PAGE, -- 4
  bottomright = BOTTOMRIGHT_ACTIONBAR_PAGE, -- 5
  left = BOTTOMLEFT_ACTIONBAR_PAGE, -- 6
  bottomleft = BOTTOMLEFT_ACTIONBAR_PAGE,
  cat = 7,
  stealth = 7,
  battle = 7,
  shadowform = 7,
  shadow = 7,
  defensive = 8,
  bear = 9,
  berserker = 9,
  moonkin = 10,
  __index = function (index)
    if nil == index or 'current' == index or '' == index or 0 == index then
      -- bar runs from 1 to NUM_ACTIONBAR_PAGES (6)
      local bar = GetActionBarPage()
      -- offset is from the first NUM_ACTIONBAR_PAGES (6) "normal" action bars, 0 if not offset
      local offset = GetBonusBarOffset()
      if 1 == bar and 0 ~= offset then
        return offset + NUM_ACTIONBAR_PAGES
      else
        return bar
      end
    end
  end
}
local function cleanChatInput(msg)
  if type(msg) == "string" then
    msg = strtrim(msg)
    if strmatch(msg, "^%d+$") then
      msg = tonumber(msg)
    end
  end
  return msg
end

function LA:CopyActionBar(barID, barClipboard)
  self.barClipboard = self.barClipboard or { }
  if not barClipboard then
    barClipboard = self.barClipboard
  end
  barID = cleanChatInput(barID)
  if type(barID) == "number" then
    barID = math.floor(tonumber(barID))
    assert(barID >= 1 and barID <= 10)
  elseif type(barID) == "string" and actionBarAliases[barID] then
    barID = actionBarAliases[barID]
  end
  local barOffset = (barID - 1) * NUM_ACTIONBAR_BUTTONS
  for i = 1, NUM_ACTIONBAR_BUTTONS do
    local id = i + barOffset
    if HasAction(id) then
      local slot = {}
      slot.type, slot.ID, slot.subType = GetActionInfo(id)
      barClipboard[i] = slot
    end
  end
end
function LA:PasteActionBar(barID, barClipboard)
  barID = cleanChatInput(barID)
  if self.barClipboard then
    if type(barID) == "string" then
      barID = actionBarAliases[barID]
    end
    local barOffset = (barID - 1) * NUM_ACTIONBAR_BUTTONS
    for i = 1, NUM_ACTIONBAR_BUTTONS do
      local slot = self.barClipboard[i]
      if slot then
        if slot.type == "spell" then
          self.Spell.Global[slot.ID]:Pickup()
        elseif slot.type == "companion" then
          PickupCompanion(slot.subType, self.companionCache[slot.subType][slot.ID].index)
        elseif slot.type == "macro" then
          PickupMacro(slot.ID)
        elseif slot.type == "equipmentset" then
          PickupEquipmentSetByName(slot.ID)
        elseif slot.type == "item" then
          PickupItem(slot.ID)
        elseif slot.type == "flyout" then
          self.Spell.Flyout[slot.ID]:Pickup()
        end
        PlaceAction(i + barOffset)
      else
        PickupAction(i + barOffset)
      end
      ClearCursor()
    end
  end
end