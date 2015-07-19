--[[

Learning Aid is copyright © 2008-2015 Jamash (Kil'jaeden US Horde)
Email: jamashkj@gmail.com

Spell.lua is part of Learning Aid.

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

-- Transforms a spellbook ID into a global spell ID
function LA:SpellGlobalID(id)
  -- CATA --
  -- local link = GetSpellLink(id, BOOKTYPE_SPELL)
  -- if link then
  --   local globalID = string.match(link, "Hspell:([^\124]+)\124")
  --   return tonumber(globalID)
  -- end
  return select(2, GetSpellBookItemInfo(id, BOOKTYPE_SPELL))
end
-- GetSpellLink(bookID, "spell") will return current spec link, which will fail when fed to IsSpellKnown and company
function LA:UnlinkSpell(link)
  assert(link, "LearningAid:UnlinkSpell(link): bad link", tostring(link))
  local globalID, name = string.match(link, "Hspell:([^|]+)|h%[([^]]+)%]")
  return name, tonumber(globalID)
end
function LA:RealSpellBookItemInfo(slot, bookType)
  -- returns status, globalID, spec-specific name, spec-specific globalID
  if not bookType then bookType = BOOKTYPE_SPELL end
  assert(slot and slot > 0, "LearningAid:RealSpellBookItemInfo(spellBookID [, bookType]): bad spellBookID")
  local spellStatus, spellGlobalID = GetSpellBookItemInfo(slot, bookType)
  if "SPELL" == spellStatus or "FUTURESPELL" == spellStatus then
    return spellStatus, spellGlobalID, self:UnlinkSpell(GetSpellLink(slot, bookType))
  end
  return spellStatus, spellGlobalID
end

function LA:FlyoutInfo(flyoutID)
  local flyoutName, flyoutDescription, numFlyoutSpells, flyoutKnown = GetFlyoutInfo(flyoutID)
  return {
    known = flyoutKnown,
    name = flyoutName,
    count = numFlyoutSpells,
    description = flyoutDescription
  }
end

function LA:UpdateSpellBook()
  wipe(self.flyoutCache)
  local known = self.knownSpells
  wipe(known)
  local total = 0
  local professions = { GetProfessions() }
  -- { Primary1, Primary2, Archaeology, Fishing, Cooking, First Aid }
  local numKnown = 0
  for i = 1, self.numProfessions do
    if professions[i] then
      local name, texture, rank, maxRank, numSpells, spellOffset, skillLine, rankModifier = GetProfessionInfo(professions[i])
      numKnown = numKnown + numSpells
      total = total + numSpells
    end
  end
  --local racial = self.Spell.Global[self.racialSpell].SubName
  --local racialPassive = self.Spell.Global[self.racialPassiveSpell].SubName
  -- tab 1 is general, tab 2 is current spec, tabs 3, 4 (and possibly 5 if druid)
  -- are other specs. The remaining tabs are all professions, I think.
  local s2g = self.specToGlobal
  local g2s = self.globalToSpec
  
  for tab = 1, 2 do
    local tabName, tabTexture, tabOffset, tabSpells, tabIsGuild, offspecID = GetSpellTabInfo(tab)
    for slot = tabOffset + 1, tabOffset + tabSpells do
      -- using RealSpellBookItemInfo instead of Spell.Book for spells
      -- because this is where the SpellAPI gets specToGlobal and globalToSpec
      local status, globalID, specName, specGlobalID = self:RealSpellBookItemInfo(slot, BOOKTYPE_SPELL)
      if "FLYOUT" == status then
        -- flyout spells are not included in the regular spell tabs, they're
        -- in gaps between the last index of one tab and the first index of
        -- the next tab
        local flyout = self.Spell.Book[slot]
        -- SpellBookSlotBySpellID doesn't work on flyouts. Storing slot
        -- information in self.flyoutCache provides an equivalent mechanism
        -- for flyouts
        self.flyoutCache[globalID] = slot
        for spell in flyout.Spells do
          -- all flyout spells are class-based as of 4.1.0
          if spell.Known then -- should always be true, but why take chances?
            numKnown = numKnown + 1
            total = total + 1
          end
        end
      elseif "SPELL" == status then -- unknown spells would have status "FUTURESPELL"
        known[globalID] = slot
        if specGlobalID ~= globalID then
          -- sometimes it's difficult to tell which spells are which (Mangle in particular)
          s2g[specGlobalID] = globalID
          g2s[globalID] = specGlobalID
          self.nameToGlobal[strlower(specName)] = globalID
        else
          -- Both IDs are the same.
          -- Sometimes certain spells, such as Monk's Flying Serpent Kick go
          -- from having different IDs to having the same ID.
          -- Check for old invalid cache entries.
          -- If new ID is N, old global id is G, and old spec id is S
          --- s2g[G] == S
          --- g2s[S] == G
          --- Both entries are now wrong and should be deleted
          --- if N == S, then s2g[N] == G, so delete g2s[s2g[N]] and s2g[N]
          if s2g[globalID] then
            g2s[s2g[globalID]] = nil -- 
            s2g[globalID] = nil
          --- if N == G, then g2s[N] == S, so delete s2g[g2s[N]] and g2s[N]
          elseif g2s[globalID] then
            s2g[g2s[globalID]] = nil
            g2s[globalID] = nil
          end
          -- Are you confused yet? I know I am.
        end
        numKnown = numKnown + 1
      end
      total = total + 1
    end
  end
  self:DebugPrint("Updated Spellbook, "..total.." entries found, "..numKnown.." spells known.")
  self.numSpells = total
end

-- if new is true, a spell has been added to the spellbook
-- if new is false, an existing spell has been newly learned

function LA:AddSpell(id, new)
  --[[ if self.state.retalenting then -- DEBUG FIXME
    print("AddSpell called during retalent!") -- DEBUG FIXME
  end ]]-- DEBUG FIXME
  local action = "SHOW"
  if new then
    action = "LEARN"
  end
  if InCombatLockdown() then
    table.insert(self.queue, { action = action, id = id })
  else
    if new then
      self:LearnSpell(id)
    end
    local spell = self.Spell.Global[id]
    if (not self.state.retalenting) and
       (not spell.Passive) --and
    then
      -- Display button with draggable spell icon
      self:AddButton(spell)
    end
  end
end
-- a spell has been removed from the spellbook
function LA:RemoveSpell(id)
  if InCombatLockdown() then
    table.insert(self.queue, { action = "FORGET", id = id })
  else
    self:ClearButtonID(id)
    self:ForgetSpell(id)
  end
end
function LA:DiffSpellBook()
  -- print("Diffing spellbook!") -- DEBUG FIXME
  if self.state.retalenting then
    -- print("DiffSpellBook called during retalent!") -- DEBUG FIXME
    return 0
  end
  -- swap caches
  --self.oldSpellBookCache, self.spellBookCache = self.spellBookCache, self.oldSpellBookCache
  self.oldKnownSpells, self.knownSpells = self.knownSpells, self.oldKnownSpells
  self:UpdateSpellBook()
  --local old = self.oldSpellBookCache
  --local new = self.spellBookCache
  local old = self.oldKnownSpells
  local new = self.knownSpells
  local updated = 0
  for newID, newItem in pairs(new) do -- look for things learned
    if newItem then
      if not old[newID] then -- spell added to spellbook
        updated = updated + 1
        
        self:AddSpell(newID, true)
      --elseif not old[newID].known then -- spell changed from unkown to known
      --  self:AddSpell(newID)
      --  updated = updated + 1
      end
    end
  end
  for oldID, oldItem in pairs(old) do -- look for things forgotten
    if oldItem then
      if not new[oldID] then
        self:RemoveSpell(oldID)
        updated = updated + 1
      --elseif not new[oldID].known then
      --  self:DebugPrint("Spell "..oldItem.info.name.." with globalID "..oldID.." forgotten but not removed")
      --  updated = updated + 1
      end
    end
  end
  if updated > 1 then
    self:DebugPrint("Multiple updates ("..updated..") in DiffSpellBook")
  end
  -- TODO: Detect flyout changes
  return updated
end
-- A new spellbook ID has been added, bumping existing spellbook IDs up by one
function LA:LearnSpell(id)
  local frame = self.frame
  local buttons = self.buttons
  --[[ MOP using global ids, don't need to munge book ids anymore, yay!
  for i = 1, self:GetVisible() do
    local button = buttons[i]
    local buttonID = button:GetID()
    if button.kind == kind and buttonID >= bookID then
      button:SetID(buttonID + 1)
      self:UpdateButton(button)
    end
  end
  ]]
  local spec = GetActiveSpecGroup()
  if self.saved.restoreActions and
      (not self.state.retalenting) and
      -- MOP -- kind == BOOKTYPE_SPELL and
      self.character.unlearned and
      self.character.unlearned[spec] then    
    --local globalID = self:SpellBookInfo(bookID).info.globalID
    for slot, oldIDs in pairs(self.character.unlearned[spec]) do
      local actionType = GetActionInfo(slot) -- local actionType, actionID, actionSubType, globalID = GetActionInfo(slot)
      for oldID in pairs(oldIDs) do
        if oldID == id and actionType == nil then
          PickupSpell(id)
          PlaceAction(slot)
          self.character.unlearned[spec][slot][oldID] = nil
        end
      end
    end
  end
end
-- An old spellbook ID has been deleted, shifting spellbook IDs down by one
function LA:ForgetSpell(bookID)
  --[[local frame = self.frame
  local buttons = self.buttons
  for i = 1, self:GetVisible() do
    local button = buttons[i]
    local buttonID = button:GetID()
    if button.kind == BOOKTYPE_SPELL and buttonID > bookID then
      button:SetID(buttonID - 1)
      self:UpdateButton(button)
    end
  end]]
end
