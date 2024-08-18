-- Keys for the waitFrames and waitTables arrays
PLH_WAIT_FOR_ENABLE_OR_DISABLE = 1
PLH_WAIT_FOR_INSPECT = 2

local waitFrames = {}
local waitTables = {}

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


local function GetNameWithoutSpacesInRealm(name)
	if name == nil or string.find(name, '-') == nil then
		return name
	else
		local shortname, realm = name:match('(.+)-(.+)')
		realm = realm:gsub("%s+","")
		return shortname .. '-' .. realm
	end
end

function PLH_GetFullName(name)
	if name == nil then
		return nil
	elseif string.find(name, '-') ~= nil then
		return GetNameWithoutSpacesInRealm(name)
	else
		local guid = UnitGUID(name)
		if guid ~= nil then
			local _, _, _, _, _, shortname, realm = GetPlayerInfoByGUID(guid)
			if not realm or realm == '' then
				realm = GetRealmName()
			end
			if shortname == nil then
				return nil
			elseif realm == nil then
				return shortname
			else
				return GetNameWithoutSpacesInRealm(shortname .. '-' .. realm)
			end
		else
			return name
		end
	end
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
	SendChatMessage('<PLH> ' .. message, GetBroadcastChannel(isHighPriority))
end	

function PLH_SendWhisper(message, person)
	SendChatMessage('<PLH> ' .. message, 'WHISPER', nil, person)
end

function PLH_SendAlert(message)
	print(GetColoredMessage('<PLH> ', _G.YELLOW_FONT_COLOR_CODE) .. GetColoredMessage(message, _G.GREEN_FONT_COLOR_CODE))
end	

function PLH_SendUserMessage(message)
	print(GetColoredMessage('<PLH> ', _G.YELLOW_FONT_COLOR_CODE) .. GetColoredMessage(message, _G.LIGHTYELLOW_FONT_COLOR_CODE))
end	

function PLH_SendDebugMessage(message)
	if PLH_PREFS[PLH_PREFS_DEBUG] then
		print(GetColoredMessage('<PLH> ', _G.YELLOW_FONT_COLOR_CODE) .. GetColoredMessage(message, _G.GRAY_FONT_COLOR_CODE))
	end		
end	

-- Returns the message that would be whispered when player requests an item
function PLH_GetWhisperMessage(itemLink, message)
	if message == nil then
		message = PLH_PREFS[PLH_PREFS_WHISPER_MESSAGE]
	end
	return message:gsub('%%item', itemLink)
end

-- Waits for delay seconds before executing func
-- the waitType parameter allows us to have multiple wait loops going on at once; pass in a unique ID for each possible type of wait loop
function PLH_wait(waitType, delay, func, ...)
	if (type(delay) == 'number' and type(func) == 'function') then
		if waitTables[waitType] == nil then
			waitTables[waitType] = {}
		end
		if waitFrames[waitType] == nil then
			waitFrames[waitType] = CreateFrame('Frame', 'PLH_WaitFrame' .. waitType, UIParent)
			waitFrames[waitType]:SetScript('onUpdate', function (self, elapse)
				local count = #waitTables[waitType]
				local i = 1
				while i <= count do
					local waitRecord = tremove(waitTables[waitType], i)
					local d = tremove(waitRecord, 1)
					local f = tremove(waitRecord, 1)
					local p = tremove(waitRecord, 1)
					if d > elapse then
						tinsert(waitTables[waitType], i, {d - elapse, f, p})
						i = i + 1
					else
						count = count - 1
						f(unpack(p))
					end
				end
			end);
		end
		tinsert(waitTables[waitType], {delay, func, {...}});
	else
		print('Bad types in PLH_wait')
	end
end

function PLH_PreemptWait(waitType)
	local waiting = #waitTables[waitType] ~= nil and #waitTables[waitType] > 0
	waitTables[waitType] = {}
	return waiting
end

--[[
-- not used, but keeping for educational purposes
function GetEscapedItemLink(item)
	return string.gsub(item, '|', '||')
end
]]--
