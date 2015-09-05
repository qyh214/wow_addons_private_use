--[[

Learning Aid is copyright © 2008-2015 Jamash (Kil'jaeden US Horde)
Email: jamashkj@gmail.com

SpellAPI.lua is part of Learning Aid.

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

--[[
PROBLEM

The search dingus can't find stuff because...?

I don't actually know. I thought it was related to spec spell IDs,
because those are the ones that fail
However, it appears that the API consistently uses the global ID, not
the spec ID for action bar buttons and for the spellbook
So why isn't it matching???
]]

--[[

DESIGN WORK

bottom-up

A Spell is an object with slot obj._slot, Global ID obj._gID, 
spec-specific ID obj._sid and getter methods Name(),
Slot(), Status(), Link(), Known(), etc

As is normal for Lua OOP, the metatable contains the methods. Attempting
to index an instance object retrieves any missing entries from the metatable.
The methods are then called on the object.
spell.Name -> meta.Name(spell) -> GetSpellBookItemName(spell.Slot) ->
GetSpellBookItemName(

BookID is an object that instantiates a new Spell object whenever a 
nonexistent index is accessed
BookID[n] -> bookIDMeta.__index (t, n) -> setmetatable({ globalID = g }, SpellMeta)

Why look up the slot each time with SpellBookSlotBySpellID? Because
slots change. It's easier to always use the globalID than try to
track spellbook ID changes dynamically. I've tried.

Concern: Neither SpellBookIDs nor GlobalIDs are stable across spec changes.
]]
local addonName, private = ...
local LA = private.LA

-- backend data

-- Metatable._method.Foo = true indicates that Foo will be called as object:Foo() rather than object.Foo

local bookMeta = { }
local globalMeta = { }
local spellMeta = { _method = { Pickup = true } }
local flyoutBookMeta = { }
local flyoutMeta = { _method = { Pickup = true } }

-- Lua optimization: locals are faster than globals
local SpellInfo = GetSpellInfo
local SpellKnown = IsSpellKnown
local SpellBookItemInfo = GetSpellBookItemInfo
local SpellBookSlotBySpellID = FindSpellBookSlotBySpellID
local SpellLink = GetSpellLink
local SpellPassive = IsPassiveSpell

-- Top level
LA.Spell = {
  Global = { },
  Book = { },
  Flyout = { },
}

setmetatable(LA.Spell.Global, globalMeta)
setmetatable(LA.Spell.Book,   bookMeta)
setmetatable(LA.Spell.Flyout, flyoutBookMeta)

-- Spell Global ID object factory
function globalMeta.__index (t, index)
  index = tonumber(index)
  assert(index > 0)
  local gID = LA.specToGlobal[index] or index -- get base spell ID
  local sID = LA.globalToSpec[index] or LA.globalToSpec[gID] or index -- get spec spell ID
  --local sID = select(2, LA:UnlinkSpell(SpellLink(gID))) -- get spec spell id
  local newSpell = { _gid = gID, _sid = sID }
  setmetatable(newSpell, spellMeta)
  -- rawset(t, index, newSpell) -- Save this object for faster future retrieval
  -- TODO -- Expiration mechanism for cached spell objects
  return newSpell
end

-- Spell Book ID object factory

function bookMeta.__index(t, index)
  index = tonumber(index)
  assert(index > 0)
  local gType, gID = SpellBookItemInfo(index, BOOKTYPE_SPELL)
  if "SPELL" == gType or "FUTURESPELL" == gType then
    local spell = LA.Spell.Global[gID]
    spell._slot = index -- Remember which Spellbook slot the spell is in
    -- rawset(t, index, spell) -- Save this object for faster future retrieval
    -- TODO -- Expiration mechanism for cached spell objects
    return spell
  elseif "FLYOUT" == gType then
    return LA.Spell.Flyout[gID]
  elseif nil == gType then
    return nil
  else
    error("LearningAid.Spell.Book: Type of spellbook slot #"..tostring(index).." ("..tostring(gType)..") is not known", 2)
  end
end

-- Spell object instances
function spellMeta.__index(spell, index)
  -- Use rawget to avoid an infinite loop if _gid doesn't exist for some reason
  -- LA:DebugPrint("SpellMeta "..index.."("..tostring(rawget(spell, "_gid"))..")")
  if not spellMeta[index] then
    error("SpellAPI: Invalid Spell object method '"..tostring(index).."'", 2)
  end
  if spellMeta._method[index] then
    -- return value will be called as a method, see spellMeta._method
    LA:DebugPrint("SpellMeta "..index.."("..tostring(spell)..")")
    return spellMeta[index]
  else
    -- simple return value
    local result = spellMeta[index](spell)
    LA:DebugPrint(tostring(result).." = SpellMeta "..tostring(index).."("..tostring(spell)..")")
    return result
  end
end

function spellMeta.__eq(spell1, spell2)
  return spell1._gid == spell2._gid
end
function spellMeta.Name(spell)
  return select(1, SpellInfo(spell._gid))
end
function spellMeta.SpecName(spell)
  return select(1, SpellInfo(spell._sid))
end

function spellMeta.Info(spell)
  local info = { }
  info.name, info.rank, info.icon, info.powerCost, info.isFunnel, info.powerType, info.castingTime, info.minRange, info.maxRange =
    SpellInfo(spell._gid)
  return info
end
function spellMeta.SpecInfo(spell)
  local info = { }
  info.name, info.rank, info.icon, info.powerCost, info.isFunnel, info.powerType, info.castingTime, info.minRange, info.maxRange =
    SpellInfo(spell._sid)
  return info
end
function spellMeta.SubName(spell)
  return select(2, SpellInfo(spell._gid))
end
function spellMeta.SpecSubName(spell)
  return select(2, SpellInfo(spell._sid))
end
function spellMeta.SpecID(spell)
  return spell._sid
end
function spellMeta.Known(spell)
  -- Only works on gid, not sid. SpellKnown(sid) will always return nil
  return SpellKnown(spell._gid)
end
function spellMeta.Status(spell)
  if spell.Slot then 
    return SpellBookItemInfo(spell.Slot, BOOKTYPE_SPELL)
  end
end
function spellMeta.ID(spell)
  return spell._gid
end
function spellMeta.Slot(spell)
  --local name = spell.Name
  --local infoName = spell.Info.name
  --local globalID = spell._gid
  -- use rawget because _slot might be nil, which would call metatable._slot as a method and fail
  local oldSlot = rawget(spell, "_slot")
  local newSlot = SpellBookSlotBySpellID(spell._gid)
  spell._slot = newSlot
  if newSlot ~= oldSlot then
    -- tostring to guard against nil values
    LA:DebugPrint("Spell ".. spell._gid .." slot changed from ".. tostring(oldSlot).." to ".. tostring(newSlot))
  end
  return newSlot
end
function spellMeta.Link(spell)
  return SpellLink(spell._gid) or ""
end
function spellMeta.SpecLink(spell)
  return SpellLink(spell._sid) or ""
end
-- use spell link in debug printing statements
spellMeta.__tostring = spellMeta.SpecLink
function spellMeta.Spec(spell)
  return select(1, IsSpellClassOrSpec(spell.Slot, BOOKTYPE_SPELL))
end
function spellMeta.Class(spell)
  return select(2, IsSpellClassOrSpec(spell.Slot, BOOKTYPE_SPELL))
end
function spellMeta.Selected(spell)
  return IsSelectedSpellBookItem(spell.Slot, BOOKTYPE_SPELL)
end
function spellMeta.Perk(spell)
  return LA.guildSpells[spell._gid]
end
function spellMeta.Passive(spell)
  return SpellPassive(spell._gid)
end
function spellMeta:Pickup()
  return PickupSpell(self._gid)
end
function spellMeta.Texture(spell)
  return GetSpellTexture(spell._gid)
end
function spellMeta.SpecTexture(spell)
  -- GetSpellTexture returns two values, one for the base spell and one for the override spell
  return select(2, GetSpellTexture(spell._sid))
end
-- Flyout object factory

-- Note: Uses flyout IDs which are discontinuous, analogous to global spellIDs.
-- Does not use flyout indexes, which are continuous and run from 1..GetNumFlyouts()

function flyoutBookMeta.__index(t, index)
  index = tonumber(index)
  assert(index > 0)
  local newFlyout = { _fid = index }
  setmetatable(newFlyout, flyoutMeta)
  return newFlyout
end

-- Flyout object instances
function flyoutMeta.__index(flyout, index)
  if "string" == type(index) then
     -- call method (index) on the flyout object
    assert(flyoutMeta[index], index.." is not a known flyout method")
    if flyoutMeta._method[index] then
      LA:DebugPrint("FlyoutMeta "..index.."("..tostring(rawget(flyout, "_fid"))..")")
      return flyoutMeta[index] -- return value will be called as a method, see flyoutMeta._method
    else
      return flyoutMeta[index](flyout)
    end
  elseif "number" == type(index) then
    -- get the spell number (index) from the flyout
    local globalID, isKnown = GetFlyoutSlotInfo(flyout._fid, index)
    if globalID then
      return LA.Spell.Global[globalID]
    else
      return nil
    end
  end
end

function flyoutMeta.__eq(flyout1, flyout2)
  return flyout1._fid == flyout2._fid
end
function flyoutMeta.ID(flyout)
  return flyout._fid
end

function flyoutMeta.Info(flyout)
  return LA:FlyoutInfo(flyout._fid)
end

function flyoutMeta.Size(flyout)
  --local name, description, size, flyoutKnown = GetFlyoutInfo(flyoutID)
  return select(3, GetFlyoutInfo(flyout._fid))
end
function flyoutMeta.Status(flyout)
  return "FLYOUT"
end
function flyoutMeta.Name(flyout)
  --local name, description, size, flyoutKnown = GetFlyoutInfo(flyoutID)
  return GetFlyoutInfo(flyout._fid) -- passes on only the first return value, which is the localized name
end
flyoutMeta.__tostring = flyoutMeta.Name
function flyoutMeta.SubName(flyout)
  return ""
end
function flyoutMeta.Selected(flyout)
  -- FIXME TODO activate when flyout is open -- FIXME TODO
end
function flyoutMeta.Known(flyout)
  --local name, description, size, flyoutKnown = GetFlyoutInfo(flyoutID)
  return select(4, GetFlyoutInfo(flyout._fid))
end
-- Pickup is a method, call as flyout:Pickup() rather than flyout.Pickup
function flyoutMeta:Pickup()
  PickupSpellBookItem(self.Slot, BOOKTYPE_SPELL)
end
function flyoutMeta.Slot(flyout)
  return LA.flyoutCache[flyout._fid]
end

-- Usage: for spell in flyout.Spells do x y z end
function flyoutMeta.Spells(flyout)
  local size = flyout.Size
  local index = 0
  return function()
    index = index + 1
    if index <= size then
      return flyout[index]
    end
  end
end