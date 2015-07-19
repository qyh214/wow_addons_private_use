--[[

Learning Aid is copyright © 2008-2015 Jamash (Kil'jaeden US Horde)
Email: jamashkj@gmail.com

Debug.lua is part of Learning Aid.

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

function LA:TestAdd(kind, ...)
  print("Testing!")
  local t = {...}
  for i = 1, #t do
    local id = t[i]
    if kind == BOOKTYPE_SPELL then
      if not IsPassiveSpell(id, kind) then
        print(addonName..": Test: Adding button with spell id "..id)
        if InCombatLockdown() then
          table.insert(self.queue, { action = "SHOW", id = id, kind = kind })
        else
          self:AddButton(kind, id)
        end
      else
        print(addonName.." Test: Spell id "..id.." is passive or does not exist")
      end
    elseif kind == "CRITTER" or kind == "MOUNT" then
      if GetCompanionInfo(kind, id) then
        print(addonName..": Test: Adding companion type "..kind.." id "..id)
        if InCombatLockdown() then
          table.insert(self.queue, { action = "SHOW", id = id, kind = kind})
        else
          self:AddButton(kind, id)
        end
      else
        print(addonName.." Test: Companion type "..kind..", id "..id.." does not exist")
      end
    else
      print(addonName.." Test: Action type "..kind.." is not valid.  Valid types are spell, CRITTER or MOUNT.")
    end
  end
end
function LA:TestRemove(kind, ...)
  print(addonName.." Testing!")
  local t = {...}
  for i = 1, #t do
    local id = t[i]
    print(addonName.." Test: Removing "..kind.." id "..id)
    if InCombatLockdown() then
      table.insert(self.queue, { action = "CLEAR", id = id, kind = kind })
    else
      self:ClearButtonID(kind, id)
    end
  end
end

function LA:ListJoin(...)
  local str = ""
  local argc = select("#", ...)
  --if argc == 1 and type(...) == "table" then
  --  return self:ListJoin(unpack(...))
  --else
  if argc >= 1 then
    str = str..tostring(...)
    for i = 2, argc do
      str = str..", "..tostring(select(i, ...))
    end
  end
  return str
end

-- could be called as private:DebugPrint() or LearningAid:DebugPrint() so don't rely on self
function private:DebugPrint(...)
  local p = private
  p.debugCount = p.debugCount + 1
  local output = LA:ListJoin(...)
  LearningAid_DebugLog[p.debugCount] = output
  if p.debugWindow then
    p.debugWindow:AddMessage(p.debugCount..': '..output)
  end
  if p.debugCount > p.debugLimit then
    LearningAid_DebugLog[p.debugCount - p.debugLimit] = nil
  end
  -- When there are <p.debugLimit> nils in the list, shift everything back down to start at 1
  -- The next call to DebugPrint will set DebugLog[debugLimit + 1] and nil out DebugLog[1]
  if (2*p.debugLimit) == p.debugCount then
    for i = 1, p.debugLimit do
      LearningAid_DebugLog[i] = LearningAid_DebugLog[i + p.debugLimit]
      LearningAid_DebugLog[i + p.debugLimit] = nil
    end
    p.debugCount = p.debugLimit
  end
  -- allow inline use
  return ...
end
-- don't call the stub DebugPrint, call the real DebugPrint
private.wrappers.DebugPrint = private.DebugPrint

private.meta = {
  __index = function(t, key)
    local value = private.shadow[key]
    if type(value) == "function" then
      if private.debugFlags.CALL and not private.noLog[key] then
        return private:Wrap(key, value)
      else
        return value
      end
    elseif private.debugFlags.GET then
      private:DebugPrint("__index["..tostring(key).."] = "..tostring(value))
    end
    return value
  end,
  __newindex = function(t, key, value)
    if private.debugFlags.SET then
      private:DebugPrint("__newindex["..tostring(key).."] = "..tostring(value))
    end
    private.shadow[key] = value
  end
}
-- when debugging is enabled, calls to LA:DebugPrint will be diverted to private:DebugPrint
function LA:DebugPrint(...)
  return ...
end

--setmetatable(private.empty, private.meta)
local junk = { }
local function tset(t, ...)
  wipe(t)
	for i = 1, select("#", ...) do
	  t[i] = (select(i, ...))
  end
	return t
end
-- call after original LA is in private.LA and LA is empty
function private:Wrap(name, f)
  self.tokenCount[name] = self.tokenCount[name] or 0
  
  self.wrappers[name] = self.wrappers[name] or function(...)
	  self.tokenCount[name] = self.tokenCount[name] + 1
	  local count = self.tokenCount[name]
		self:DebugPrint(name.."["..count.."]("..LA:ListJoin(select(2,...))..")")
		tset(junk, f(...))
		self:DebugPrint(name.."["..count.."]() return "..LA:ListJoin(unpack(junk)))
		return unpack(junk)
	end
  return self.wrappers[name]
end

function LA:Debug(flag, newValue)
  -- Flags are "CALL", "GET", "SET"
  -- TOOD: probably ought to redesign this
	-- private.debug is the sum of the number of flags that are true
  local oldDebug = private.debug
  local newDebug = oldDebug
  local debugFlags = self.saved.debugFlags
  local oldValue = debugFlags[flag]
  
  if flag == nil then -- initialize
    newDebug = 0
    private.debugFlags = debugFlags
    for savedFlag, savedValue in pairs(debugFlags) do
      if savedValue then
        newDebug = newDebug + 1
      end
    end
  elseif newValue == nil then -- getter
    return oldValue
  elseif newValue ~= oldValue then -- setter
    debugFlags[flag] = newValue
    newDebug = newDebug + (newValue and 1 or -1) -- increment if true, decrement if false
  end

  local shadow = private.shadow

  if oldDebug == 0 and newDebug > 0 then -- we're turning debugging on
    for k, v in pairs(LA) do
      shadow[k] = LA[k]
      LA[k] = nil
    end
    setmetatable(LA, private.meta)
    LearningAid_DebugLog = { }
    if LearningAid_Saved then
      LearningAid_Saved.debugLog = LearningAid_DebugLog
    end
  elseif oldDebug > 0 and newDebug == 0 then -- we're turning debugging off
    setmetatable(LA, nil)
    for k, v in pairs(shadow) do
      LA[k] = shadow[k]
      shadow[k] = nil
    end
    if LearningAid_Saved then
      LearningAid_Saved.debugLog = nil
    end
  end

  private.debug = newDebug
end