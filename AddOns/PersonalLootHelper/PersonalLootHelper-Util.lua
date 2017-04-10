local PLH_LONG_ADDON_NAME_PREFIX = '<' .. PLH_LONG_ADDON_NAME .. '> '
local PLH_SHORT_ADDON_NAME_PREFIX = '<' .. PLH_SHORT_ADDON_NAME .. '> '
PLH_ITEM_LEVEL_PATTERN = _G.ITEM_LEVEL
PLH_ITEM_LEVEL_PATTERN = PLH_ITEM_LEVEL_PATTERN:gsub('%%d', '(%%d+)')  -- 'Item Level (%d+)'
PLH_RELIC_TOOLTIP_TYPE_PATTERN = _G.RELIC_TOOLTIP_TYPE
PLH_RELIC_TOOLTIP_TYPE_PATTERN = PLH_RELIC_TOOLTIP_TYPE_PATTERN:gsub('%%s', '(.+)')  -- '(.+) Artifact Relic'
	  
local tooltip

local waitTable = {};     -- used by PLH_wait
local waitFrame = nil;    -- used by PLH_wait

local waitTable2 = {};     -- used by PLH_wait
local waitFrame2 = nil;    -- used by PLH_wait

local waitTable3 = {};     -- used by PLH_wait
local waitFrame3 = nil;    -- used by PLH_wait

--[[
informational - possible tooltip item type row arrangements

Ranged				Bow
Ranged				Crossbow
Ranged				Gun
Ranged				Wand

One-Hand			Dagger
One-Hand			Fist Weapon
One-Hand			Axe
One-Hand			Mace
One-Hand			Sword

Two-Hand			Polearm
Two-Hand			Staff
Two-Hand			Axe
Two-Hand			Mace
Two-Hand			Sword

Off Hand			Shield

Held In Off-hand	nil

Head				[Cloth/Leather/Mail/Plate]
Neck				nil
Shoulder			[Cloth/Leather/Mail/Plate]
Back				nil
Chest				[Cloth/Leather/Mail/Plate]
ALSO SHIRT AND TABARAD
Wrist				[Cloth/Leather/Mail/Plate]
Hands				[Cloth/Leather/Mail/Plate]
Waist				[Cloth/Leather/Mail/Plate]
Legs				[Cloth/Leather/Mail/Plate]
Feet				[Cloth/Leather/Mail/Plate]
Finger				nil
Trinket				nil
]]--

--[[
creates an empty tooltip that is ready to be populated with the information from an item
-- note: a complicated tooltip could have the following lines (ex):
	1 - Oathclaw Helm, nil
	2 - Mythic, nil
	3 - Item Level 735
	4 - Upgrade Level: 2/2, nil
	5 - Binds when picked up, nil
	6 - Head, Leather
]]--
local function CreateEmptyTooltip()
    local tip = CreateFrame('GameTooltip')
	local leftside = {}
	local rightside = {}
	local L, R
    for i = 1, 6 do
        L, R = tip:CreateFontString(), tip:CreateFontString()
        L:SetFontObject(GameFontNormal)
        R:SetFontObject(GameFontNormal)
        tip:AddFontStrings(L, R)
        leftside[i] = L
		rightside[i] = R
    end
    tip.leftside = leftside
	tip.rightside = rightside
    return tip
end

function PLH_GetRelicType(item)
	local relicType = nil
	
	if item ~= nil then
		tooltip = tooltip or CreateEmptyTooltip()
		tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
		tooltip:ClearLines()
		tooltip:SetHyperlink(item)

		local index = 1
		local t
		while not relicType and tooltip.leftside[index] do
			t = tooltip.leftside[index]:GetText()
			if t ~= nil then
--				relicType = t:match('(.+) Artifact Relic')
				relicType = t:match(PLH_RELIC_TOOLTIP_TYPE_PATTERN)				
			end
			index = index + 1
		end

		tooltip:Hide()
	end
	
	return relicType
end

--[[
function PLH_IsBoundToPlayer(item)
	local isBoundToPlayer = false
	
	if item ~= nil then
		tooltip = tooltip or CreateEmptyTooltip()
		tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
		tooltip:ClearLines()
		tooltip:SetHyperlink(item)

		-- scan the leftside lines for any signs of the item being bound to the player
		local index = 1
		local t
		while not isBoundToPlayer and tooltip.leftside[index] do
			t = tooltip.leftside[index]:GetText()
			if t ~= nil then
--				if (string.find(t, 'Binds when picked up') or string.find(t, 'Soulbound') or string.find(t, 'Binds to Battle.net account')) then
				if (string.find(t, _G.ITEM_SOULBOUND) or string.find(t, _G.ITEM_BIND_ON_PICKUP) or string.find(t, _G.ITEM_BIND_TO_BNETACCOUNT) or string.find(t, _G.ITEM_BNETACCOUNTBOUND)) then
					isBoundToPlayer = true
				end
			end
			index = index + 1
		end

		tooltip:Hide()

	end
	return isBoundToPlayer
end
]]--

function PLH_GetRealILVL(item)
	local realILVL = nil
	
	if item ~= nil then
		tooltip = tooltip or CreateEmptyTooltip()
		tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
		tooltip:ClearLines()
		tooltip:SetHyperlink(item)
		local t = tooltip.leftside[2]:GetText()
		if t ~= nil then
--			realILVL = t:match('Item Level (%d+)')
			realILVL = t:match(PLH_ITEM_LEVEL_PATTERN)
		end
		-- ilvl can be in the 2nd or 3rd line dependng on the tooltip; if we didn't find it in 2nd, try 3rd
		if realILVL == nil then
			t = tooltip.leftside[3]:GetText()
			if t ~= nil then
--				realILVL = t:match('Item Level (%d+)')
				realILVL = t:match(PLH_ITEM_LEVEL_PATTERN)
			end
		end
		tooltip:Hide()
		
		-- if realILVL is still nil, we couldn't find it in the tooltip - try grabbing it from getItemInfo, even though
		--   that doesn't return upgrade levels
		if realILVL == nil then
			_, _, _, realILVL, _, _, _, _, _, _, _ = GetItemInfo(item)
		end
	end
	
	if realILVL == nil then
		return 0
	else		
		return tonumber(realILVL)
	end
end

function PLH_GetFullName(name, realm)
	if name == nil then
		return nil
	elseif realm == nil then
		return name
	else
		return name .. '-' .. realm
	end
end

function PLH_GetUnitNameWithRealm(unit)
	local guid
	if unit ~= nil then
		guid = UnitGUID(unit)
	end
	if guid ~= nil then
		local _, _, _, _, _, name, realm = GetPlayerInfoByGUID(guid)
		if not realm or realm == '' then
			realm = GetRealmName()
		end
		return PLH_GetFullName(name, realm)
	else
		return nil
	end
end

function PLH_GetNameWithoutRealm(name)
	return (Ambiguate(name, 'short'))
end

-- given a name-realm combo, returns the GUID for that character
function PLH_GetUnitGUIDFromFullname(fullname)
	local guid = UnitGUID(fullname)
	if guid == nil then
		guid = UnitGUID(Ambiguate(fullname, 'short'))
	end
	return guid
end

function PLH_IsInLFR()
	return IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and IsInRaid()
end

local function CanUseRaidWarning()
	return UnitIsGroupLeader('player') or UnitIsRaidOfficer('player')
end

local function GetBroadcastChannel(isHighPriority)
	local channel
	if IsInGroup() then
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			if CanUseRaidWarning() and isHighPriority then 
				channel = 'RAID_WARNING'
			else
				channel = 'INSTANCE_CHAT'
			end
		elseif IsInRaid() then
			if CanUseRaidWarning() and isHighPriority then 
				channel = 'RAID_WARNING'
			else
				channel = 'RAID'
			end
		else	
			channel = 'PARTY'
		end
	else
		channel = 'EMOTE'  -- for testing purposes
	end
	return channel
end

local function GetColoredMessage(message, color)
	if message ~= nil then
		message = color .. message   							-- set desired color at the start
		message = string.gsub(message, '|r', '|r' .. color)		-- set to our color if the message sets color to default (ex: end of an item link)
		message = message .. _G.FONT_COLOR_CODE_CLOSE			-- set color back to default
	end
	return message
end

function PLH_SendBroadcast(message, isHighPriority)
	SendChatMessage(PLH_SHORT_ADDON_NAME_PREFIX .. message, GetBroadcastChannel(isHighPriority))
end	

function PLH_SendWhisper(message, person)
	SendChatMessage(PLH_SHORT_ADDON_NAME_PREFIX .. message, 'WHISPER', nil, person)
end

function PLH_SendAlert(message)
	print(GetColoredMessage(PLH_SHORT_ADDON_NAME_PREFIX, _G.YELLOW_FONT_COLOR_CODE) .. GetColoredMessage(message, _G.GREEN_FONT_COLOR_CODE))
end	

function PLH_SendUserMessage(message)
	print(GetColoredMessage(PLH_SHORT_ADDON_NAME_PREFIX, _G.YELLOW_FONT_COLOR_CODE) .. GetColoredMessage(message, _G.LIGHTYELLOW_FONT_COLOR_CODE))
end	

function PLH_SendDebugMessage(message)
	if PLH_DEBUG then
		print(GetColoredMessage(PLH_SHORT_ADDON_NAME_PREFIX, _G.YELLOW_FONT_COLOR_CODE) .. GetColoredMessage(message, _G.GRAY_FONT_COLOR_CODE))
	end		
end	

-- having 3 of the same function is very much a hack...multiple waits can happen during inspect loop, so we need different global vars to track separate timers
-- I could consolidate to a single function with a param determining which globals to use, but I'm not even sure this will
-- solve the inspect issues, hence the quick-and-dirty approach
function PLH_wait(delay, func, ...)
  if(type(delay)~='number' or type(func)~='function') then
  print('bad types')
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame('Frame','WaitFrame', UIParent);
    waitFrame:SetScript('onUpdate',function (self,elapse)
      local count = #waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable,{delay,func,{...}});
  return true;
end

function PLH_wait2(delay, func, ...)
  if(type(delay)~='number' or type(func)~='function') then
  print('bad types')
    return false;
  end
  if(waitFrame2 == nil) then
    waitFrame2 = CreateFrame('Frame','WaitFrame2', UIParent);
    waitFrame2:SetScript('onUpdate',function (self,elapse)
      local count = #waitTable2;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable2,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable2,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable2,{delay,func,{...}});
  return true;
end

--[[
-- not used, but keeping for educational purposes
function GetEscapedItemLink(item)
	return string.gsub(item, '|', '||')
end

-- not used, but keeping for educational purposes
function GetRaidRosterInfoByName(playerName)
	local index = 1
	local name
	while GetRaidRosterInfo(index) ~= nil do
		name, _, _, _, _, _, _, _, _, _, _ = GetRaidRosterInfo(index)
		if (name == playerName) then 
			return GetRaidRosterInfo(index)
		end
		index = index + 1
	end
	return nil
end

-- not used, but keeping for educational purposes
function GetClassByName(playerName)
	local name, class
	if GetNumGroupMembers() < 2 then  -- you're solo, or have started a group and nobody has joined yet
		class, _, _, _, _, name, _ = GetPlayerInfoByGUID(UnitGUID('player'))
		if name == playerName then
			return class
		end
	else 
		_, _, _, _, class, _, _, _, _, _, _ = GetRaidRosterInfoByName(playerName)
		return class
	end
	return ''
end
]]--
