local addonName,ns = ...

local itemCooldowns = {}

local function CheckCooldown(ItemID)
    local start, duration, _ = GetItemCooldown(ItemID)

    if start == 0 and duration == 0 and itemCooldowns[ItemID] then
        local itemName = ns.GetItemName(ItemID)
        local text = (CDAlertDB["ItemIds"][ItemID]["start"] or "")..itemName ..(CDAlertDB["ItemIds"][ItemID]["end"] or "")
        C_VoiceChat.SpeakText(0, text, Enum.VoiceTtsDestination.LocalPlayback, 1, 100)
        itemCooldowns[ItemID] = nil
    end
end

--定时检测物品cd
local cdstar = C_Timer.NewTicker(2, function()
	if not CDAlertDB or not CDAlertDB["ItemIds"] then return end
	for ItemID, _ in pairs(CDAlertDB["ItemIds"]) do
		local start,duration = GetItemCooldown(ItemID)
		if start > 0 and duration > 5 then
			itemCooldowns[ItemID] = true
		end
	end
end)

--定时器检测
local cdover = C_Timer.NewTicker(1, function()
	if not CDAlertDB or not CDAlertDB["ItemIds"] then return end
	for ItemID, _ in pairs(itemCooldowns) do
		CheckCooldown(ItemID)
	end
end)