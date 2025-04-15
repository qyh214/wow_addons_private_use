local addonName,ns = ...

local spellCooldowns = {}
local CDcalltimer

local function CheckCooldown(spellID)
    local SC = C_Spell.GetSpellCooldown(spellID)

    if SC.startTime == 0 and SC.duration == 0 and spellCooldowns[spellID] then
        local spellName = ns.GetSpellName(spellID)
        local text = (CDAlertDB["SpellIds"][spellID]["start"] or "")..spellName ..(CDAlertDB["SpellIds"][spellID]["end"] or "")
        C_VoiceChat.SpeakText(0, text, Enum.VoiceTtsDestination.LocalPlayback, 1, 100)
        spellCooldowns[spellID] = nil
    end
end

local cdstar = C_Timer.NewTicker(2,function()
	for spellID, spelltrue in pairs(CDAlertDB["SpellIds"]) do
		if spelltrue then
			local SC = C_Spell.GetSpellCooldown(spellID)
			if SC.startTime > 0 and SC.duration > 5 then
				spellCooldowns[spellID] = true
			end
		end
	end
end)

--定时器检测
local cdover = C_Timer.NewTicker(1, function()
	if not CDAlertDB or not CDAlertDB["SpellIds"] then return end
	for spellID, _ in pairs(spellCooldowns) do
		CheckCooldown(spellID)
	end
end)



--显示法术ID
--法术ID
local function ShowID(self,data)
	if CDAlertDB.tipid and data.id then
		self:AddDoubleLine("|cffBA55D3法术ID:|r|cff00FF00"..data.id.."|r")
	end
end
--TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, ShowID)