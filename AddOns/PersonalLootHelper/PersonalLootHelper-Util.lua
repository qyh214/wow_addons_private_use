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

--[[
creates an empty tooltip that is ready to be populated with the information from an item
-- note: a complicated tooltip could have the following lines (ex):
	1 - Oathclaw Helm, nil
	2 - Mythic, nil
	3 - Item Level 735
	4 - Upgrade Level: 2/2, nil
	5 - Binds when picked up, nil
	6 - Head, Leather
	
	rows - how many rows of the tooltip to populate; prior to version 1.24 we only cared about the first 6 rows, but to find the 'classes:' row we have to go much deeper
]]--
function PLH_CreateEmptyTooltip(rows)
    local tooltip = CreateFrame('GameTooltip')
	local leftside = {}
	local rightside = {}
	local L, R
    for i = 1, rows do
        L, R = tooltip:CreateFontString(), tooltip:CreateFontString()
        L:SetFontObject(GameFontNormal)
        R:SetFontObject(GameFontNormal)
        tooltip:AddFontStrings(L, R)
        leftside[i] = L
		rightside[i] = R
    end
    tooltip.leftside = leftside
	tooltip.rightside = rightside
	tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
    return tooltip
end

function PLH_GetFullName(name)
	if name == nil then
		return nil
	elseif string.find(name, '-') then
		return name
	else
		local name, realm = UnitFullName(name)
		if name == nil then
			return nil
		elseif realm == nil or realm == '' then
			return name .. '-' .. GetRealmName()
		else
			return name .. '-' .. realm
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
