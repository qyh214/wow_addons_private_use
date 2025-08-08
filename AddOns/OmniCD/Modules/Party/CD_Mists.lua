local E = select(2, ...):unpack()
if not E.isMoP then
	return
end

local P, CM, CD = E.Party, E.Comm, E.Cooldowns
local pairs, ipairs, type, tonumber, abs, min, max = pairs, ipairs, type, tonumber, abs, min, max
local UnitTokenFromGUID, UnitHealth, UnitHealthMax, UnitChannelInfo = UnitTokenFromGUID, UnitHealth, UnitHealthMax, UnitChannelInfo
local C_Timer_After = C_Timer.After
local band = bit.band
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local COMBATLOG_OBJECT_REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY

local groupInfo = P.groupInfo
local userGUID = E.userGUID

local auraMultString = {}
local minionGUIDS = {}

function CD:Enable()
	if self.isEnabled then
		return
	end
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UNIT_PET")
	self:SetScript("OnEvent", function(self, event, ...)
		self[event](self, ...)
	end)
	self.isEnabled = true
end

function CD:Disable()
	if not self.isEnabled then
		return
	end
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:UnregisterEvent("UNIT_PET")
	wipe(minionGUIDS)
	self.isEnabled = false
end

local mt = {
	__index = function(t, k)
		t[k] = {}
		return t[k]
	end
}

local registeredEvents = setmetatable({}, mt)
local registeredHostileEvents = setmetatable({}, mt)






local function RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
	if P.isHighlightEnabled and destGUID == srcGUID then
		local icon = info.glowIcons[spellID]
		if icon then
			icon:RemoveHighlight()
			icon:SetCooldownElements()
			icon:SetOpacity()
			icon:SetColorSaturation()
		end
	end
end

for k in pairs(E.spell_highlighted) do
	registeredEvents["SPELL_AURA_REMOVED"][k] = RemoveHighlightByCLEU
end

function CD:RegisterRemoveHighlightByCLEU(spellID)
	local func = registeredEvents["SPELL_AURA_REMOVED"][spellID]
	if not func then
		registeredEvents["SPELL_AURA_REMOVED"][spellID] = RemoveHighlightByCLEU
	elseif func ~= RemoveHighlightByCLEU then
		registeredEvents["SPELL_AURA_REMOVED"][spellID] = function(...)
			func(...)
			RemoveHighlightByCLEU(...)
		end
	end
end






local playerInterrupts = {
	47528,
	93985,
	97547,
	113288,
	147362,
	2139,
	116705,
	96231,
	31935,
	220543,
	32747,
	1766,
	57994,
	132409,
	6552,
	102060,
}

local function AppendInterruptExtras(info, _, spellID, _,_,_, extraSpellId, extraSpellName, _,_, destRaidFlags)
	local icon = info.spellIcons[E.spellcast_merged[spellID] or spellID]
	local statusBar = icon and icon.type == "interrupt" and icon.statusBar
	if statusBar then
		local frame = icon:GetParent():GetParent()
		if frame.index == 1 then
			if frame.db.showInterruptedSpell then
				local extraSpellTexture = C_Spell.GetSpellTexture(extraSpellId)
				if extraSpellTexture then
					icon.icon:SetTexture(extraSpellTexture)
					icon.tooltipID = extraSpellId
					if not E.db.icons.showTooltip and icon.isPassThrough then
						icon:EnableMouse(true)
					end
				end
			end
			if frame.db.showRaidTargetMark then
				local mark = CombatLog_String_GetIcon(destRaidFlags)
				if mark then
					statusBar.CastingBar.Text:SetFormattedText("%s %s", statusBar.name, mark)
				end
			end
		end
	end
end

for _, id in pairs(playerInterrupts) do
	registeredEvents["SPELL_INTERRUPT"][id] = AppendInterruptExtras
end






local function StartCdOnAuraRemoved(info, srcGUID, spellID, destGUID)
	if srcGUID == destGUID then
		spellID = E.spell_auraremoved_cdstart_preactive[spellID]
		local icon = info.spellIcons[spellID]
		if icon then
			RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
			icon:StartCooldown()
		end
	end
end

for k, v in pairs(E.spell_auraremoved_cdstart_preactive) do
	if v > 0 then
		registeredEvents["SPELL_AURA_REMOVED"][k] = StartCdOnAuraRemoved
	end
end






local function ProcessSpellOnAuraApplied(info, srcGUID, spellID)
	spellID = E.spell_auraapplied_processspell[spellID]
	info:ProcessSpell(spellID)
end

for k in pairs(E.spell_auraapplied_processspell) do
	registeredEvents["SPELL_AURA_APPLIED"][k] = ProcessSpellOnAuraApplied
end






for id in pairs(E.spell_dispel_cdstart) do
	registeredEvents["SPELL_DISPEL"][id] = function(info)
		local icon = info.spellIcons[id]
		if icon then
			icon:StartCooldown()
		end
	end
end












registeredEvents["SPELL_AURA_APPLIED"][108294] = function(info)
	if info.spec == 104 then
		return
	end
	local icon = info.spellIcons[55694]
	if icon then
		icon.maxcharges = 2
		local active = icon.active and info.active[55694]
		if active then
			active.charges = 1
			icon.active = 1
			icon.count:SetText(1)
			icon:SetCooldownElements()
			icon:SetBorderGlow(info.isDeadOrOffline, E.db.highlight.glowBorderCondition)
		else
			icon.count:SetText(2)
		end
	end
end
registeredEvents["SPELL_AURA_APPLIED"][108291] = registeredEvents["SPELL_AURA_APPLIED"][108294]
registeredEvents["SPELL_AURA_APPLIED"][108292] = registeredEvents["SPELL_AURA_APPLIED"][108294]

registeredEvents["SPELL_AURA_REMOVED"][108294] = function(info, srcGUID, spellID, destGUID)
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)

	if info.spec == 104 then
		return
	end
	local icon = info.spellIcons[55694]
	if icon then
		icon.maxcharges = nil
		icon.count:SetText("")
		local active = icon.active and info.active[55694]
		if active and active.charges then
			if active.charges == 0 then
				active.charges = nil
				icon.active = 0
				icon:SetCooldownElements()
			else
				icon:ResetCooldown()
			end
		end
	end
end
registeredEvents["SPELL_AURA_REMOVED"][108291] = registeredEvents["SPELL_AURA_REMOVED"][108294]
registeredEvents["SPELL_AURA_REMOVED"][108292] = registeredEvents["SPELL_AURA_REMOVED"][108294]


local UpdateAllBars_OnDelayEnd = function()
	P:UpdateAllBars()
end

registeredEvents["SPELL_CAST_SUCCESS"][110309] = function()
	C_Timer_After(0.5, UpdateAllBars_OnDelayEnd)
end

registeredEvents["SPELL_AURA_REMOVED"][110309] = function(info)
	local id = info.auras.symbiosisId
	if id then
		info.talentData[id] = nil
		info.auras.symbiosisId = nil
		C_Timer_After(0.4, UpdateAllBars_OnDelayEnd)
	end
end



registeredEvents["SPELL_CAST_SUCCESS"][33891] = function(info)
	if info.auras.isTreeOfLife then
		return
	end
	local icon = info.spellIcons[102558]
	if icon then
		C_Timer_After(0, function()
			icon:StartCooldown()
		end)
	end
end

registeredEvents["SPELL_AURA_APPLIED"][117679] = function(info)
	info.auras.isTreeOfLife = true
end

registeredEvents["SPELL_AURA_REMOVED"][117679] = function(info, srcGUID, spellID, destGUID)
	info.auras.isTreeOfLife = nil
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end


registeredEvents["SPELL_AURA_APPLIED"][5487] = function(info)
	info.auras.isBearForm = true
end

registeredEvents["SPELL_AURA_REMOVED"][5487] = function(info)
	info.auras.isBearForm = nil
end

registeredEvents["SPELL_CAST_SUCCESS"][770] = function(info)
	if info.auras.isBearForm and info.talentData[114237] then
		local icon = info.spellIcons[770]
		if icon then
			icon:StartCooldown(15)
		end
	end
end


registeredEvents["SPELL_CAST_SUCCESS"][5185] = function(info)
	if info.talentData[54825] then
		local icon = info.spellIcons[132158]
		if icon and icon.active then
			icon:UpdateCooldown(3)
		end
	end
end







registeredEvents["SPELL_CAST_SUCCESS"][131894] = function(info, _,_, destGUID)
	local icon = info.spellIcons[131894]
	if icon then
		local unit = UnitTokenFromGUID(destGUID)
		if unit then
			local maxHP = UnitHealthMax(unit)
			if maxHP > 0 and UnitHealth(unit) / maxHP < .2 then
				icon:UpdateCooldown(60)
			end
		end
	end
end


registeredEvents["SPELL_CAST_SUCCESS"][34477] = function(info, _,_, destGUID)
	if info.talentData[56829] then
		local icon = info.spellIcons[34477]
		if icon then
			info.auras.isMisdirectOnPet = strfind(destGUID, "^Pet")
		end
	end
end

registeredEvents["SPELL_AURA_REMOVED"][34477] = function(info, srcGUID, spellID, destGUID)
	if srcGUID == destGUID then
		local icon = info.spellIcons[spellID]
		if icon then
			icon:StartCooldown()


			if info.auras.isMisdirectOnPet then
				icon:ResetCooldown()
			end
			RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
		end
	end
end








registeredEvents["SPELL_AURA_APPLIED"][110909] = function(info)
	info:ProcessSpell(108978)
end

registeredEvents["SPELL_AURA_REMOVED"][110909] = function(info, srcGUID, spellID, destGUID)
	local icon = info.spellIcons[108978]
	if icon then
		RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
		icon:StartCooldown()
	end
end


registeredEvents["SPELL_INTERRUPT"][2139] = function(info, _, spellID, _, _, _, amount, overkill, _, _, destRaidFlags)
	if info.talentData[131618] then
		local icon = info.spellIcons[spellID]
		if icon and icon.active then
			icon:UpdateCooldown(4)
		end
	end
	AppendInterruptExtras(info, nil, spellID, nil, nil, nil, amount, overkill, nil, nil, destRaidFlags)
end







registeredEvents["SPELL_CAST_SUCCESS"][115072] = function(info, _, spellID)
	if info.spec == 268 then
		local icon = info.spellIcons[spellID]
		if icon and icon.active then
			local unit = info.unit
			if unit then
				local maxHP = UnitHealthMax(unit)
				if maxHP > 0 then
					if UnitHealth(unit) / maxHP <= 0.35 then
						icon:ResetCooldown()
					end
				end
			end
		end
	end
end







local forbearanceIDs = {
	[1022] = 0,
	[642] = 60,
	[633] = 0,
}

registeredEvents["SPELL_AURA_REMOVED"][25771] = function(_,_,_, destGUID)
	local destInfo = groupInfo[destGUID]
	if destInfo then
		for id in pairs(forbearanceIDs) do
			local icon = destInfo.preactiveIcons[id]
			if icon then
				destInfo.preactiveIcons[id] = nil
				icon:SetColorSaturation()
				if icon.statusBar then
					icon.statusBar:SetColors()
				end
			end
		end
	end
end

registeredEvents["SPELL_AURA_APPLIED"][25771] = function(_,_,_, destGUID)

	if not E.db.icons.showForbearanceCounter then
		return
	end
	local destInfo = groupInfo[destGUID]
	if destInfo then
		for id in pairs(forbearanceIDs) do
			if id ~= 642 or not destInfo.talentData[146956] then
				local icon = destInfo.spellIcons[id]
				if icon then
					destInfo.preactiveIcons[id] = icon
					icon:SetColorSaturation()
					if icon.statusBar then
						icon.statusBar:SetColors()
					end
				end
			end
		end
	end
end


registeredEvents["SPELL_AURA_APPLIED"][85416] = function(info)
	local icon = info.spellIcons[31935]
	if icon and icon.active then
		icon:ResetCooldown()
	end
end


registeredEvents["SPELL_AURA_APPLIED"][59578] = function(info)
	local icon = info.spellIcons[879]
	if icon and icon.active then
		icon:ResetCooldown()
	end
end







registeredEvents["SPELL_CAST_SUCCESS"][129176] = function(info, _,_, destGUID, _,_,_,_,_,_,_, timestamp)
	if info.spellIcons[129176] then
		if timestamp > (info.auras.time_shadowWordDeathReset or 0) then
			local unit = UnitTokenFromGUID(destGUID)
			if unit then
				local maxHP = UnitHealthMax(unit)
				if maxHP > 0 then
					info.auras.isDeathTargetUnder20 = UnitHealth(unit) / maxHP < .2
				end
			end
		end
	end
end

registeredEvents["SPELL_DAMAGE"][129176] = function(info, _,_,_,_,_,_, overkill, _,_,_, timestamp)
	if overkill == -1 and info.auras.isDeathTargetUnder20 then
		local icon = info.spellIcons[129176]
		if icon and icon.active then
			icon:ResetCooldown()
		end
		info.auras.time_shadowWordDeathReset = timestamp + 10
	end
	info.auras.isDeathTargetUnder20 = nil
end









registeredEvents["SPELL_AURA_REMOVED"][57934] = function(info, srcGUID, spellID, destGUID)
	local icon = info.spellIcons[spellID]
	if icon then
		RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)

		info.preactiveIcons[spellID] = nil
		icon:SetColorSaturation()
		if icon.statusBar then
			icon.statusBar:SetColors()
		end
	end
end

local function StartTricksCD(info, srcGUID, spellID, destGUID)
	local icon = info.spellIcons[57934]
	if icon and srcGUID == destGUID then
		RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
		icon:StartCooldown()
	end
end

registeredEvents["SPELL_AURA_APPLIED"][59628] = StartTricksCD


local comboPointSpenders = {
	2098,
	1943,
	121411,
	26679,
}

local restlessBladesIDs = {
	13750,
	51690,
	73981,
	121471,
	2983,
}

local function ReduceCDByRestlessBlades(info)
	if info.spec == 260 then
		for _, id in ipairs(restlessBladesIDs) do
			local icon = info.spellIcons[id]
			if icon and icon.active then
				icon:UpdateCooldown(10)
			end
		end
	end
end

for _, id in ipairs(comboPointSpenders) do
	registeredEvents["SPELL_CAST_SUCCESS"][id] = ReduceCDByRestlessBlades
end


registeredEvents["SPELL_INTERRUPT"][1766] = function(info, _, spellID, _,_,_, extraSpellId, extraSpellName, _,_, destRaidFlags)
	if info.talentData[56805] then
		local icon = info.spellIcons[spellID]
		if icon and icon.active then
			icon:UpdateCooldown(6)
		end
	end
	AppendInterruptExtras(info, nil, spellID, nil,nil,nil, extraSpellId, extraSpellName, nil,nil, destRaidFlags)
end

local arenaUnits = { "arena1", "arena2", "arena3", "arena4", "arena5", "target" }
registeredEvents["SPELL_CAST_SUCCESS"][1766] = function(info, _, spellID, destGUID)
	if info.talentData[56805] then
		local icon = info.spellIcons[spellID]
		if icon and icon.active then
			for i = 1, #arenaUnits do
				local unit = arenaUnits[i]
				local guid = UnitGUID(unit)
				if guid == destGUID then
					local _,_,_,_,_,_, notInterruptable, channelID = UnitChannelInfo(unit)
					if notInterruptable ~= false then
						return
					end
					if channelID == 47758 then
						icon:UpdateCooldown(6)
					end
				end
			end
		end
	end
end







registeredEvents["SPELL_HEAL"][31616] = function(info)
	local icon = info.spellIcons[30884]
	if icon then
		icon:StartCooldown()
	end
end













registeredEvents["SPELL_AURA_APPLIED"][32216] = function(info)
	local icon = info.spellIcons[103840]
	if icon and icon.active then
		icon:ResetCooldown()
	end
end







registeredEvents["SPELL_AURA_APPLIED"][113942] = function(info, _, spellID)
	local icon = info.spellIcons[spellID] or info:AddOnCast(spellID, 0)
	if icon then

		for i = 1, 50 do
			local _,_,_,_, duration, _,_,_,_, id = UnitDebuff(info.unit, i)
			if not id then return end
			if id == spellID then
				if duration > 0 then
					icon.duration = duration
				end
				icon:StartCooldown()
				break
			end
		end
	end
end


registeredEvents["SPELL_CAST_SUCCESS"][6262] = function(info, srcGUID, spellID)
	local icon = info.spellIcons[spellID] or info:AddOnCast(spellID, 5512)
	if icon then
		local stacks = icon.count:GetText()
		stacks = tonumber(stacks)
		stacks = (stacks and stacks > 0 and stacks or 3) - 1
		icon.count:SetText(stacks)
		info.auras.healthStoneStacks = stacks
		icon:StartCooldown()
	end
end

setmetatable(registeredEvents, nil)
setmetatable(registeredHostileEvents, nil)

local function UpdateDeadStatus(destInfo)

	if E.preMoP and UnitHealth(destInfo.unit) > 1 then
		return
	end
	destInfo.isDead = true
	destInfo.isDeadOrOffline = true
	destInfo:UpdateColorScheme()
end

function CD:COMBAT_LOG_EVENT_UNFILTERED()
	local timestamp, event, _, srcGUID, _, srcFlags, _, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, _, amount, overkill, school, resisted, _,_, critical = CombatLogGetCurrentEventInfo()

	local info = groupInfo[srcGUID]
	if info then
		local func = registeredEvents[event] and registeredEvents[event][spellID]
		if func then
			func(info, srcGUID, spellID, destGUID, critical, destFlags, amount, overkill, destName, resisted, destRaidFlags, timestamp, school)
		end
		return
	end

	local ownerGUID = minionGUIDS[srcGUID]
	if ownerGUID then
		info = groupInfo[ownerGUID]
		if not info then
			return
		end

		if event == "SPELL_INTERRUPT" then
			AppendInterruptExtras(info, nil, spellID, nil, nil, nil, amount, overkill, nil, nil, destRaidFlags)
		end
		return
	end

	if band(srcFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) == 0 then
		local destInfo = groupInfo[destGUID]
		if destInfo and event == "UNIT_DIED" then
			UpdateDeadStatus(destInfo)
		end
	end
end

function CD:UNIT_PET(unit)
	local unitPet = E.UNIT_TO_PET[unit]
	if not unitPet then
		return
	end

	local guid = UnitGUID(unit)
	local info = groupInfo[guid]
	if info and (info.class == "WARLOCK" or info.class == "HUNTER" or info.spec == 252) then
		local petGUID = info.petGUID
		if petGUID then
			minionGUIDS[petGUID] = nil
		end
		petGUID = UnitGUID(unitPet)
		if petGUID then
			minionGUIDS[petGUID] = guid
		end
		info.petGUID = petGUID
	end
end

E.forbearanceIDs = forbearanceIDs
E.auraMultString = auraMultString
CD.minionGUIDS = minionGUIDS
