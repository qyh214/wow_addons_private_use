local addonName,ns = ...


--检查本地化
ns.L = ns.L or {}
for key,value in pairs(ns.DefaultL) do
	if not ns.L[key] then
		--print(ns.DefaultL[key])
		ns.L[key] = ns.DefaultL[key]	
	end
end

--事件加载
function ns.event(event, handler)
    if ns.events == nil then
        ns.events = CreateFrame("Frame")
        ns.events.handler = {}
        ns.events.OnEvent = function(frame, event, ...)
            for key, handler in pairs(ns.events.handler[event]) do
                handler(...)
            end
        end
        ns.events:SetScript("OnEvent", ns.events.OnEvent)
    end
    if ns.events.handler[event] == nil then
        ns.events.handler[event] = {}
        ns.events:RegisterEvent(event)
    end
    table.insert(ns.events.handler[event], handler)
end

--获取NPC名字,@hopeasd/MDT
local scanTooltip = CreateFrame("GameTooltip", "NPCNameToolTip", nil, "GameTooltipTemplate") --fake tooltipframe used for reading localized npc names -- by lunaic
local function GetNameFromNpcID(npcID)
	scanTooltip:SetOwner(UIParent,"ANCHOR_NONE")
	scanTooltip:SetHyperlink(format("unit:Creature-0-0-0-0-%d-0000000000", npcID))
	if scanTooltip:NumLines()>0 then
		local name = NPCNameToolTipTextLeft1:GetText()
		scanTooltip:Hide()
		return name
	end
end

--返回NPC名字
function ns.GetNpcName(npcID)
	return GetNameFromNpcID(npcID)
end
--返回法术名称
function ns.GetSpellName(id)
	local v = strsplit(".",GetBuildInfo())
	if tonumber(v) < 11 then
		return GetSpellInfo(id) or SPELLS..ID..ERRORS
	else
		return C_Spell.GetSpellInfo(id).name or SPELLS..ID..ERRORS
	end
end

--返回法术图标
function ns.GetSpellIcon(id)
	local v = strsplit(".",GetBuildInfo())
	if tonumber(v) < 11 then
		return select(3,GetSpellInfo(id)) or 132321
	else
		return C_Spell.GetSpellInfo(id).iconID or 132321
	end
end

--返回物品名称
function ns.GetItemName(id)
	return C_Item.GetItemNameByID(id) or ITEMS..ID..ERRORS
end
--返回物品图标
function ns.GetItemIcon(id)
	return C_Item.GetItemIconByID(id) or 132321
end

--计算字节数量
local function SubStringGetByteCount(str)
    local curByte = string.byte(str)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<=223 then
        byteCount = 2
    elseif curByte>=224 and curByte<=239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount;
end

function ns.RCTexts(text)
    local colors = {
		"|cffff5900", -- 1
		"|cffffb300", -- 2
		"|cfff0ff00", -- 3
		"|cff96ff00", -- 4
		"|cff3cff00", -- 5
		"|cff00ffd2", -- 6
		"|cff00d1ff", -- 7
		"|cff00B3FF", -- 8
		"|cffD56AFF", -- 9
		"|cffFF6BED", -- 0
		"|cffFF2AA5", -- A
		"|cffFF546A", -- B
		"|cffff5900", -- 1
		"|cffffb300", -- 2
		"|cfff0ff00", -- 3
		"|cff96ff00", -- 4
		"|cff3cff00", -- 5
		"|cff00ffd2", -- 6
		"|cff00d1ff", -- 7
		"|cff00B3FF", -- 8
		"|cffD56AFF", -- 9
		"|cffFF6BED", -- 0
		"|cffFF2AA5", -- A
		"|cffFF546A", -- B
	}
    local result = ""
    local colorIndex = math.random(1, 24)
    local i = 1
    while i <= #text do
        local chars = string.sub(text, i, i)
        local byteCount = SubStringGetByteCount(chars)
        local truncatedChars = string.sub(text, i, i + byteCount - 1)
        result = result .. colors[colorIndex] .. truncatedChars .. "|r"
        i = i + byteCount
        colorIndex = colorIndex % #colors + 1
    end
    return result
end