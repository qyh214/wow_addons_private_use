local E = select(2, ...):unpack()
local P, CM, CD = E.Party, E.Comm, E.Cooldowns

local pairs, type, tonumber, unpack, tinsert, wipe, strmatch, min, max, abs = pairs, type, tonumber, unpack, table.insert, table.wipe, string.match, math.min, math.max, math.abs
local GetTime, UnitBuff, UnitTokenFromGUID, UnitHealth, UnitHealthMax, UnitLevel, UnitChannelInfo, UnitAffectingCombat = GetTime, UnitBuff, UnitTokenFromGUID, UnitHealth, UnitHealthMax, UnitLevel, UnitChannelInfo, UnitAffectingCombat
local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture
local AuraUtil_ForEachAura = AuraUtil and AuraUtil.ForEachAura
local C_Timer_After, C_Timer_NewTimer, C_Timer_NewTicker = C_Timer.After, C_Timer.NewTimer, C_Timer.NewTicker
local band = bit.band
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local COMBATLOG_OBJECT_TYPE_GUARDIAN = COMBATLOG_OBJECT_TYPE_GUARDIAN
local COMBATLOG_OBJECT_REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY
local COMBATLOG_OBJECT_TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER
local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local COMBATLOG_OBJECT_TYPE_PET = COMBATLOG_OBJECT_TYPE_PET

local BOOKTYPE_CATEGORY = E.BOOKTYPE_CATEGORY
local groupInfo = P.groupInfo
local userGUID = E.userGUID

local isUserDisabled
local isHighlightEnabled

local totemGUIDS = {}
local petGUIDS = {}
local diedHostileGUIDS = {}
local dispelledHostileGUIDS = {}

E.auraMultString = {}

function CD:Enable()
	if self.enabled then
		return
	end
	self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	self:RegisterEvent('UNIT_PET')
	self:SetScript("OnEvent", function(self, event, ...)
		self[event](self, ...)
	end)

	self.enabled = true
end

function CD:Disable()
	if not self.enabled then
		return
	end
	self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	self:UnregisterEvent('UNIT_PET')

	wipe(totemGUIDS)
	wipe(petGUIDS)
	wipe(diedHostileGUIDS)
	wipe(dispelledHostileGUIDS)
	self.enabled = false
end

function CD:UpdateCombatLogVar()
	isUserDisabled = P.isUserDisabled
	isHighlightEnabled = E.db.highlight.glowBuffs
end

local function GetHolyWordReducedTime(info, reducedTime)

	local naaruRank = info.talentData[196985]
	if naaruRank then
		reducedTime = reducedTime + reducedTime * (E.isDF and 0.1 * naaruRank or .33)
	end

	if info.auras.isApotheosisActive then
		reducedTime = reducedTime * 4
	end

	if info.talentData[453677] then
		reducedTime = reducedTime * (P.isPvP and 1.05 or 1.1)
	end

	return reducedTime
end

local priestHolyWordSpells = {
	[88625] = true,
	[34861] = true,
	[2050] = true,
	[265202] = true,
}

local function UpdateCdByReducer(info, t, isHolyPriest)
	local talent, pvpMult, duration, target, aura = t[1], t[2], t[3], t[4], t[5]
	if aura and not info.auras[aura] then
		return
	end

	local talentRank = P:IsSpecOrTalentForPvpStatus(talent, info, true)
	if talentRank then
		if type(target) == "table" then
			for targetID, reducedTime in pairs(target) do
				local icon = info.spellIcons[targetID]
				if icon and icon.active then
					if type(reducedTime) == "table" then
						if reducedTime[1] > 999 then
							reducedTime = info.talentData[ reducedTime[1] ] and reducedTime[2] or reducedTime[3]
							if type(reducedTime) == "table" then
								reducedTime = reducedTime[talentRank] or reducedTime[1]
							end
						else
							reducedTime = reducedTime[talentRank] or reducedTime[1]
						end
					end
					if reducedTime then
						reducedTime = P.isPvP and pvpMult * reducedTime or reducedTime
						P:UpdateCooldown(icon, isHolyPriest and priestHolyWordSpells[targetID] and GetHolyWordReducedTime(info, reducedTime) or reducedTime)
					end
				end
			end
		elseif target then
			local icon = info.spellIcons[target]
			if icon and icon.active then
				duration = type(duration) == "table" and (duration[talentRank] or duration[1]) or duration
				if duration then
					duration = P.isPvP and pvpMult * duration or duration
					P:UpdateCooldown(icon, isHolyPriest and priestHolyWordSpells[target] and GetHolyWordReducedTime(info, duration) or duration)
				end
			end

		elseif talent == 382523 then
			duration = type(duration) == "table" and (duration[talentRank] or duration[1]) or duration
			duration = P.isPvP and pvpMult * duration or duration
			for spellID, icon in pairs(info.spellIcons) do
				if icon.active and spellID ~= 1856 and (icon.isBookType) then
					P:UpdateCooldown(icon, duration)
				end
			end
		end
	end
end

local wotlkcReadinessExcluded = {
	[23989] = true,
	[19574] = true,
	[53480] = true,
	[54044] = true,
	[53490] = true,
	[53517] = true,
	[26090] = true,
}

local function ResetCdByCast(info, reset)
	for i = 1, #reset do
		local resetID = reset[i]
		if i > 1 then
			if type(resetID) == "table" then
				ResetCdByCast(info, resetID)
			elseif resetID == "*" then
				for id, icon in pairs(info.spellIcons) do
					if icon.active and icon.isBookType and not wotlkcReadinessExcluded[id] then
						P:ResetCooldown(icon)
					end
				end
			else
				local icon = info.spellIcons[resetID]
				if icon and icon.active then

					if resetID == 6143 then
						if info.active[resetID] and resetID == info.active[resetID].castedLink then
							local linkedIcon = info.spellIcons[543]
							if linkedIcon and linkedIcon.active then
								P:ResetCooldown(linkedIcon)
							end
							P:ResetCooldown(icon)
						end
					elseif resetID ~= 120 or not info.talentData[417493] then
						P:ResetCooldown(icon)
					end
				end
			end
		elseif resetID and not P:IsTalentForPvpStatus(resetID, info) then
			return
		end
	end
end

local function ProcessSpell(spellID, guid)
	if E.spell_dispel_cdstart[spellID] then
		return
	end

	local info = groupInfo[guid]
	if not info then
		return
	end

	if P.isInShadowlands and guid ~= userGUID and not CM.syncedGroupMembers[guid] then
		local covenantID = E.covenant_abilities[spellID]
		if covenantID then
			P.loginsessionData[guid] = P.loginsessionData[guid] or {}
			local currID = P.loginsessionData[guid].covenantID
			if covenantID ~= currID then
				if currID then
					local currSpellID = E.covenant_to_spellid[currID]
					P.loginsessionData[guid][currSpellID] = nil
					info.talentData[currSpellID] = nil
					if currID == 3 then
						info.talentData[319217] = nil
					end
				end

				local covenantSpellID = E.covenant_to_spellid[covenantID]
				P.loginsessionData[guid][covenantSpellID] = "C"
				P.loginsessionData[guid].covenantID = covenantID
				info.talentData[covenantSpellID] = "C"
				info.shadowlandsData.covenantID = covenantID
				if spellID == 319217 then
					info.talentData[spellID] = 0
				end
				P:UpdateUnitBar(guid)
			else
				if spellID == 319217 and not info.talentData[spellID] then
					info.talentData[spellID] = 0
					P:UpdateUnitBar(guid)
				end
			end
		end
	end

	local mergedID = E.spell_merged[spellID]

	local linked = E.spell_linked[mergedID or spellID]
	if linked then
		for _, linkedID in pairs(linked) do
			local icon = info.spellIcons[linkedID]
			if icon then

				if isHighlightEnabled and mergedID and linkedID == mergedID then
					icon.buff = spellID
				end

				P:StartCooldown(icon, (E.isWOTLKC or E.isCata) and (spellID == 6552 and 10 or (spellID == 72 and 12)) or icon.duration)

				if E.preMoP then
					info.active[linkedID].castedLink = mergedID or spellID
				end
			end
		end
		return
	end

	local mergedIcon = mergedID and (info.spellIcons[mergedID] or info.spellIcons[ E.spell_merged[mergedID] ])
	local icon = mergedIcon or info.spellIcons[spellID]
	if icon and icon.duration > 0 then

		if isHighlightEnabled and mergedIcon then
			icon.buff = spellID
		end

		if E.spell_auraremoved_cdstart_preactive[spellID] then
			local statusBar = icon.statusBar
			if icon.active then
				if statusBar then
					P.OmniCDCastingBarFrame_OnEvent(statusBar.CastingBar, 'UNIT_SPELLCAST_STOP')
				end
				icon.cooldown:Clear()
			end
			if statusBar then
				if E.db.extraBars[statusBar.key].useIconAlpha then
					icon:SetAlpha(E.db.icons.activeAlpha)
				end
				statusBar.BG:SetVertexColor(0.7, 0.7, 0.7)
			else
				icon:SetAlpha(E.db.icons.activeAlpha)
			end
			info.preactiveIcons[icon.spellID] = icon

			if not P:HighlightIcon(icon) then
				icon.icon:SetVertexColor(0.4, 0.4, 0.4)
			end

			if spellID == 5384 then
				info.bar:RegisterUnitEvent('UNIT_AURA', info.unit)
			end
			return
		end

		local updateSpell = E.spell_merged_updateoncast[spellID]
		if updateSpell then
			local cd = updateSpell[1] or icon.duration

			if mergedID == 272651 and P.isPvP and info.talentData[356962] then
				cd = cd / 2
			end
			local iconID = info.talentData[ updateSpell[3] ] and updateSpell[4] or updateSpell[2]
			if iconID then
				icon.icon:SetTexture(iconID)
			end
			P:StartCooldown(icon, cd)
			return
		end

		P:StartCooldown(icon, icon.duration)
	end


	local shared = E.spellcast_shared_cdstart[spellID]
	if shared then
		local now = GetTime()
		for i = 1, #shared, 2 do
			local sharedID = shared[i]
			local sharedCD = shared[i+1]
			local sharedIcon = info.spellIcons[sharedID]
			if sharedIcon then
				local active = sharedIcon.active and info.active[sharedID]
				if not active or (active.startTime + active.duration - now < sharedCD) then
					P:StartCooldown(sharedIcon, sharedCD)
				end
				if not E.preMoP then
					break
				end
			end
		end
		return
	end

	local reset = E.spellcast_cdreset[spellID]
	if reset then
		if type(reset[1]) == "table" then
			for i = 1, #reset do
				local t = reset[i]
				ResetCdByCast(info, t)
			end
		else
			ResetCdByCast(info, reset)
		end
	end

	local reducer = E.spellcast_cdr[spellID]
	if reducer then
		local isHolyPriest = info.class == "PRIEST"
		if type(reducer[1]) == "table" then
			for i = 1, #reducer do
				local t = reducer[i]
				UpdateCdByReducer(info, t, spellID ~= 88625 and isHolyPriest)
			end
		else
			UpdateCdByReducer(info, reducer, spellID ~= 88625 and isHolyPriest)
		end
	end

	if not E.isBFA then return end

	local azerite = E.spellcast_cdr_azerite[spellID]
	if azerite and info.talentData[azerite.azerite] then
		for k, reducedTime in pairs(azerite.target) do
			local targetIcon = info.spellIcons[k]
			if targetIcon then
				if targetIcon.active then
					P:UpdateCooldown(targetIcon, reducedTime)
				end
				break
			end
		end
	end
end

local mt = {
	__index = function(t, k)
		t[k] = {}
		return t[k]
	end
}

local registeredEvents = setmetatable({}, mt)
local registeredHostileEvents = setmetatable({}, mt)
local registeredUserEvents = setmetatable({}, mt)





local function RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
	if isHighlightEnabled and destGUID == srcGUID then
		local icon = info.glowIcons[spellID]
		if icon then
			P:RemoveHighlight(icon)
		end
	end
end
for k in pairs(E.spell_highlighted) do
	registeredEvents['SPELL_AURA_REMOVED'][k] = RemoveHighlightByCLEU
end

function CD:RegisterRemoveHighlightByCLEU(spellID)
	local func = registeredEvents['SPELL_AURA_REMOVED'][spellID]
	if not func then
		registeredEvents['SPELL_AURA_REMOVED'][spellID] = RemoveHighlightByCLEU
	elseif func ~= RemoveHighlightByCLEU then
		registeredEvents['SPELL_AURA_REMOVED'][spellID] = function(...)
			func(...)
			RemoveHighlightByCLEU(...)
		end
	end
end






E.spell_aura_freespender = {
	[219788] = "Ossuary",
	[454871] = "BloodDraw",
	[135286] = "ToothandClaw",
	[201671] = "GoryFur",
	[260242] = "PreciseShot",

	[448814] = "FuriousAssault",
	[392883] = "VivaciousVivification",
	[451462] = "OrderedElements",

	[327510] = "ShiningLight",




	[387356] = "CrashingChaos",
	[387157] = "RitualOfRuin",
	[5302] = "Revenge",
	[52437] = "SuddenDeath",
	[32216] = "Victorious",
	[439601] = "StormofSwords",
}


registeredEvents['SPELL_AURA_APPLIED'][393039] = function(info, _,_,_,_,_,_, amount) info.auras["TheEmperorsCapacitor"] = amount or 1 end
registeredEvents['SPELL_AURA_APPLIED_DOSE'][393039] = registeredEvents['SPELL_AURA_APPLIED'][393039]
registeredEvents['SPELL_AURA_REMOVED'][393039] = function(info) info.auras["TheEmperorsCapacitor"] = nil end

for k, v in pairs(E.spell_aura_freespender) do
	registeredEvents['SPELL_AURA_REMOVED'][k] = E.spell_highlighted[k] and function(info, srcGUID, spellID, destGUID)
		info.auras[v] = nil
		RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
	end or function(info)
		info.auras[v] = nil
	end
	registeredEvents['SPELL_AURA_APPLIED'][k] = function(info)
		info.auras[v] = k
	end
end






local function ForceUpdatePeriodicSync(id)
	local cooldownInfo = CM.cooldownSyncIDs[id]
	if cooldownInfo then
		if cooldownInfo[1] == 0 then
			cooldownInfo[1] = 1
		end
		cooldownInfo[2] = -0.1
		CM:ForceSyncCooldowns()
	end
end

for id in pairs(E.sync_reset) do
	registeredEvents['SPELL_CAST_SUCCESS'][id] = function(_, srcGUID)
		if srcGUID == userGUID then
			ForceUpdatePeriodicSync(id)
		end
	end
	registeredUserEvents['SPELL_CAST_SUCCESS'][id] = function()
		ForceUpdatePeriodicSync(id)
	end
end





local playerInterrupts = {
	47528,
	183752,
	106839,
	93985,
	97547,
	351338,
	147362,
	187707,
	2139,
	116705,
	96231,
	31935,
	220543,
	1766,
	57994,
	132409,
	6552,
	386071,
}

local function AppendInterruptExtras(info, _, spellID, _,_,_, extraSpellId, extraSpellName, _,_, destRaidFlags)
	local icon = info.spellIcons[E.spell_merged[spellID] or spellID]
	local statusBar = icon and icon.type == "interrupt" and icon.statusBar
	if statusBar then
		local frame = icon:GetParent():GetParent()
		if frame.index == 1 then
			if frame.db.showInterruptedSpell then
				local extraSpellTexture = GetSpellTexture(extraSpellId)
				if extraSpellTexture then
					icon.icon:SetTexture(extraSpellTexture)
					icon.tooltipID = extraSpellId
					if not E.db.icons.showTooltip and icon.isPassThrough then
						icon:EnableMouse(true)
					end
				end
			end
			if frame.db.showRaidTargetMark then
				local mark = E.RAID_TARGET_MARKERS[destRaidFlags]
				if mark then
					statusBar.CastingBar.Text:SetFormattedText("%s %s", statusBar.name, mark)
				end
			end
		end
	end
end

for _, id in pairs(playerInterrupts) do
	registeredEvents['SPELL_INTERRUPT'][id] = AppendInterruptExtras
end





local function StartCdOnAuraRemoved(info, srcGUID, spellID, destGUID)
	if srcGUID == destGUID then
		spellID = E.spell_auraremoved_cdstart_preactive[spellID]
		local icon = info.spellIcons[spellID]
		if icon then
			local statusBar = icon.statusBar
			if statusBar then
				P:SetExStatusBarColor(icon, statusBar.key)
			end
			info.preactiveIcons[spellID] = nil
			icon.icon:SetVertexColor(1, 1, 1)

			RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)

			P:StartCooldown(icon, icon.duration)
		end
	end
	if E.sync_reset[spellID] and srcGUID == userGUID then
		ForceUpdatePeriodicSync(spellID)
	end
end

for k, v in pairs(E.spell_auraremoved_cdstart_preactive) do
	if v > 0 then
		registeredEvents['SPELL_AURA_REMOVED'][k] = StartCdOnAuraRemoved
	end
end





local function ProcessSpellOnAuraApplied(_, srcGUID, spellID)
	spellID = E.spell_auraapplied_processspell[spellID]
	ProcessSpell(spellID, srcGUID)
end
for k in pairs(E.spell_auraapplied_processspell) do
	if k == 454871 then
		registeredEvents['SPELL_AURA_APPLIED'][k] = function(info, srcGUID, spellID)
			info.auras[k] = true
			spellID = E.spell_auraapplied_processspell[spellID]
			ProcessSpell(spellID, srcGUID)
		end
	else
		registeredEvents['SPELL_AURA_APPLIED'][k] = ProcessSpellOnAuraApplied
	end
end





for id in pairs(E.spell_dispel_cdstart) do
	registeredEvents['SPELL_DISPEL'][id] = function(info)
		local icon = info.spellIcons[id]
		if icon then
			P:StartCooldown(icon, icon.duration)
		end
	end
end







registeredEvents['SPELL_ENERGIZE'][378849] = function(info)
	local icon = info.spellIcons[47528]
	if icon and icon.active then
		P:UpdateCooldown(icon, 3)
	end
end


registeredEvents['SPELL_CAST_SUCCESS'][219809] = function(info)
	local numShields = info.auras.numBoneShields
	if not numShields or numShields == 1 then
		return
	end

	local consumed = min(5, numShields)

	local icon = info.spellIcons[221699]
	if icon and icon.active then
		P:UpdateCooldown(icon, 2 * consumed)
	end

	if info.talentData[377637] then
		icon = info.spellIcons[49028]
		if icon and icon.active then
			P:UpdateCooldown(icon, 5 * consumed)
		end
	end
end
registeredEvents['SPELL_CAST_SUCCESS'][194844] = registeredEvents['SPELL_CAST_SUCCESS'][219809]

local function ReduceBloodTapDancingRuneWeaponCD(info, _,_,_,_,_,_, amount)
	local numShields = info.auras.numBoneShields
	if not numShields then
		return
	end

	amount = amount or 0
	info.auras.numBoneShields = amount

	local consumed = numShields - amount
	if consumed ~= 1 then
		return
	end

	local icon = info.spellIcons[221699]
	if icon and icon.active then
		P:UpdateCooldown(icon, 2)
	end


	if info.talentData[377637] then
		icon = info.spellIcons[49028]
		if icon and icon.active then
			P:UpdateCooldown(icon, 5)
		end
	end
end
registeredEvents['SPELL_AURA_REMOVED_DOSE'][195181] = ReduceBloodTapDancingRuneWeaponCD
registeredEvents['SPELL_AURA_REMOVED'][195181] = ReduceBloodTapDancingRuneWeaponCD

registeredEvents['SPELL_AURA_APPLIED_DOSE'][195181] = function(info, _,_,_,_,_,_, amount)
	if amount and (info.spellIcons[221699] or info.spellIcons[49028]) then
		info.auras.numBoneShields = amount
	end
end


local runicPowerSpenders = {
	[49998] = 45,
	[47541] = 30,


}

registeredEvents['SPELL_AURA_APPLIED'][81256] = function(info)
	info.auras.isDancingRuneWeapon = true
end
registeredEvents['SPELL_AURA_REMOVED'][81256] = function(info, srcGUID, spellID, destGUID)
	info.auras.isDancingRuneWeapon = nil
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end

local function ReduceVampiricBloodCD(info, _, spellID)
	if info.talentData[205723] then
		local icon = info.spellIcons[55233]
		if icon and icon.active then
			local usedRP = runicPowerSpenders[spellID]
			if spellID == 49998 then

				--[[
				if info.talentData[374277] then
					usedRP = usedRP - 5
				end
				]]
				if info.auras["Ossuary"] then
					usedRP = usedRP - 5
				end
				if info.auras["BloodDraw"] then
					usedRP = usedRP - 10
				end
			elseif spellID == 47541 then

				if info.auras["Ossuary"] then
					usedRP = usedRP - 5
				end
			end
			P:UpdateCooldown(icon, usedRP/10 * 2)
		end
	end
end

for id in pairs(runicPowerSpenders) do
	registeredEvents['SPELL_CAST_SUCCESS'][id] = ReduceVampiricBloodCD
end


registeredEvents['SPELL_DAMAGE'][436304] = function(info)
	local icon = info.spellIcons[48743]
	if icon and icon.active then
		P:UpdateCooldown(icon, 5)
	end
end


registeredEvents['PARTY_KILL']['DEATHKNIGHT'] = function(info, _,_, destGUID)
	local unit = UnitTokenFromGUID(destGUID)
	if unit then
		if abs(info.level - UnitLevel(unit)) <= 8 then
			local icon = info.talentData[276079] and info.spellIcons[49576]
			if icon and icon.active then
				P:ResetCooldown(icon)
			end
			icon = info.talentData[434136] and info.spellIcons[48792]
			if icon and icon.active then
				P:UpdateCooldown(icon, 3)
			end
		end
	end

end







registeredEvents['SPELL_AURA_APPLIED'][212800] = function(info)
	if info.talentData[205411] then
		local icon = info.spellIcons[198589]
		if icon and ( not icon.active ) then
			P:StartCooldown(icon, icon.duration/2)
		end
	end
end


registeredEvents['SPELL_HEAL'][203794] = function(info)
	local talentRank = info.talentData[218612]
	if talentRank then
		local icon = info.spellIcons[203720]
		if icon and icon.active then
			P:UpdateCooldown(icon, talentRank == 2 and .5 or .25)
		end
	end
end


registeredEvents['SPELL_AURA_REMOVED'][162264] = function(info, srcGUID, spellID, destGUID)
	if info.talentData[390142] then
		local icon = info.spellIcons[195072]
		if icon and icon.active then
			P:ResetCooldown(icon)
		end
	end
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end



registeredEvents['SPELL_ENERGIZE'][391345] = function(info, _,_,_,_,_, amount)
	local icon = info.spellIcons[212084]
	if icon and icon.active then
		P:UpdateCooldown(icon, icon.duration * amount/100)
	end
end


local demonHunterSigils = {
	[204596] = 204598,
	[207684] = 207685,
	[202137] = 204490,
	[202138] = 204843,
	[390163] = 389860,

}

local function ReduceSigilsCD(info, _,_,_,_,_,_,_,_,_,_, timestamp)
	if info.talentData[389718] then
		if timestamp > (info.auras.time_cycleofbinding or 0) then
			for castID in pairs(demonHunterSigils) do
				local icon = info.spellIcons[castID]
				if icon and icon.active then
					P:UpdateCooldown(icon, 2)
				end
			end
			info.auras.time_cycleofbinding = timestamp + 0.1
		end
	end
end

for _, auraID in pairs(demonHunterSigils) do
	if ( auraID == 389860 or auraID == 204598 ) then
		registeredEvents['SPELL_DAMAGE'][auraID] = ReduceSigilsCD
	else
		registeredEvents['SPELL_AURA_APPLIED'][auraID] = ReduceSigilsCD
		registeredEvents['SPELL_AURA_REFRESH'][auraID] = ReduceSigilsCD
	end
end







registeredEvents['SPELL_AURA_REMOVED'][50334] = function(info, srcGUID, spellID, destGUID)
	info.auras["berserkRavage"] = nil
	info.auras["berserkPersistence"] = nil
	info.auras["isBerserkUnchecdAggression"] = nil
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end

registeredEvents['SPELL_AURA_APPLIED'][50334] = function(info)

	if info.talentData[343240] then
		local icon = info.spellIcons[6795]
		if icon and icon.active then
			P:ResetCooldown(icon)
		end
		info.auras["berserkRavage"] = true
	end

	if info.talentData[377779] then
		local icon = info.spellIcons[22842]
		if icon and icon.active then
			for i = 1, (icon.maxcharges or 1) do
				P:ResetCooldown(icon)
			end
		end
		info.auras["berserkPersistence"] = true
	end

	if info.talentData[377623] then
		info.auras["isBerserkUnchecdAggression"] = true
	end
end

registeredEvents['SPELL_AURA_REMOVED'][102558] = registeredEvents['SPELL_AURA_REMOVED'][50334]
registeredEvents['SPELL_AURA_APPLIED'][102558] = registeredEvents['SPELL_AURA_APPLIED'][50334]


registeredEvents['SPELL_CAST_SUCCESS'][157982] = function(info)
	if info.talentData[392162] then
		for _, icon in pairs(info.spellIcons) do
			if icon and icon.active and icon.isBookType and icon.spellD ~= 740 then
				P:UpdateCooldown(icon, 4)
			end
		end
	end
end


registeredEvents['SPELL_INTERRUPT'][97547] = function(info, _, spellID, _,_,_, extraSpellId, extraSpellName, _,_, destRaidFlags)
	if info.talentData[202918] then
		local icon = info.spellIcons[78675]
		if icon and icon.active then
			P:UpdateCooldown(icon, 15)
		end
	end
	AppendInterruptExtras(info, nil, spellID, nil,nil,nil, extraSpellId, extraSpellName, nil,nil, destRaidFlags)
end


local savageMomentumIDs = {
	5217,
	61336,
	1850,
	252216,
}

registeredEvents['SPELL_INTERRUPT'][93985] = function(info, _, spellID, _,_,_, extraSpellId, extraSpellName, _,_, destRaidFlags)
	if P.isPvP and info.talentData[205673] then
		for i = 1, 4 do
			local id = savageMomentumIDs[i]
			local icon = info.spellIcons[id]
			if icon and icon.active then
				P:UpdateCooldown(icon, 10)
			end
		end
	end
	AppendInterruptExtras(info, nil, spellID, nil,nil,nil, extraSpellId, extraSpellName, nil,nil, destRaidFlags)
end


registeredEvents['SPELL_AURA_REMOVED'][319454] = function(info, srcGUID, spellID, destGUID)
	if info.auras.isHeartOfTheWild then
		local icon = info.spellIcons[22842]
		if icon then
			local active = icon.active and info.active[22842]
			if active and active.charges then
				if active.charges == 0 then
					active.charges = nil
					icon.active = 0
				else
					P:ResetCooldown(icon)
				end
				P:SetCooldownElements(info, icon, nil)
			end
			icon.maxcharges = nil
			icon.count:SetText("")
		end
		info.auras.isHeartOfTheWild = nil
	end
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end

registeredEvents['SPELL_AURA_APPLIED'][319454] = function(info)
	if info.spec ~= 104 then
		local icon = info.spellIcons[22842]
		if icon then
			local active = icon.active and info.active[22842]
			if active then
				active.charges = 1
				icon.active = 1
				icon.count:SetText(1)
				P:SetCooldownElements(info, icon, 1)
			else
				icon.count:SetText(2)
			end
			icon.maxcharges = 2
		end
		info.auras.isHeartOfTheWild = true
	end
end



local ReduceIncarnTree_OnDelayEnd = function(srcGUID)
	local info = groupInfo[srcGUID]
	if info then
		local icon = info.spellIcons[33891]
		if icon and icon.active then
			P:UpdateCooldown(icon, 5)
		end
	end
end
registeredEvents['SPELL_SUMMON'][102693] = function(info, srcGUID)
	if info.talentData[393371] and not CM.syncedGroupMembers[srcGUID] then
		local icon = info.spellIcons[33891]
		if icon then
			C_Timer_After(15, function() ReduceIncarnTree_OnDelayEnd(srcGUID) end)
		end
	end
end


local guardianRageSpenders = {
	[22842] = 10,
	[192081] = 40,
	[20484] = 30,
	[6807] = 40,
	[400254] = 40,
	[441605] = 40,
}

local function ReduceGuardianIncarnationCD(info, srcGUID, spellID)
	if info.talentData[393414] then
		local icon = info.spellIcons[102558]
		if icon and icon.active then
			local rCD = guardianRageSpenders[spellID] / 25
			if spellID == 22842 then

				if info.talentData[441689] then
					AuraUtil_ForEachAura(info.unit, "HELPFUL", nil, function(_,_,_,_,_,_,_,_,_, id)
						if id == 768 then
							rCD = 1.6
							return true
						end
					end)
				end
			elseif spellID == 6807 or spellID == 400254 or spellID == 441605 then
				if info.auras["ToothandClaw"] then
					return
				end
				if info.auras["isBerserkUnchecdAggression"] then
					rCD = rCD * .5
				end
			elseif spellID == 192081 then
				if info.auras["berserkPersistence"] then
					rCD = rCD * .5
				end
				if info.auras["GoryFur"] then
					rCD = rCD * .75
				end
			end
			P:UpdateCooldown(icon, rCD)
		end
	end
	if spellID == 22842 and srcGUID == userGUID then
		ForceUpdatePeriodicSync(spellID)
	end
end

for id in pairs(guardianRageSpenders) do
	registeredEvents['SPELL_CAST_SUCCESS'][id] = ReduceGuardianIncarnationCD
end


registeredEvents['SPELL_AURA_APPLIED'][117679] = function(info)
	info.auras.isTreeOfLife = true
end
registeredEvents['SPELL_AURA_REMOVED'][117679] = function(info, srcGUID, spellID, destGUID)
	info.auras.isTreeOfLife = nil
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end
registeredEvents['SPELL_CAST_SUCCESS'][33891] = function(info, _,_,_,_,_,_,_,_,_,_, timestamp)
	if not info.auras.isTreeOfLife then
		local icon = info.spellIcons[33891]
		if icon then
			C_Timer_After(0.1, function()
				P:StartCooldown(icon, icon.duration)

				if info.talentData[434249] then
					P:UpdateCooldown(icon, min(timestamp - (info.auras.time_treeOfLife or 0), 15))
					info.auras.time_treeOfLife = timestamp
				end
			end)
		end
	end
end


registeredEvents['SPELL_AURA_REMOVED'][132158] = function(info, srcGUID, spellID, destGUID, _,_,_,_,_,_,_, timestamp)
	if srcGUID == destGUID then
		spellID = E.spell_auraremoved_cdstart_preactive[spellID]
		local icon = info.spellIcons[spellID]
		if icon then
			local statusBar = icon.statusBar
			if statusBar then
				P:SetExStatusBarColor(icon, statusBar.key)
			end
			info.preactiveIcons[spellID] = nil
			icon.icon:SetVertexColor(1, 1, 1)

			RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)

			P:StartCooldown(icon, icon.duration)

			if info.talentData[434249] then
				P:UpdateCooldown(icon, min(timestamp - (info.auras.time_naturesswiftness or 0), 15))
				info.auras.time_naturesswiftness = timestamp
			end
		end
	end
	if E.sync_reset[spellID] then
		if srcGUID == userGUID then
			ForceUpdatePeriodicSync(spellID)
		end
	end
end


registeredEvents['SPELL_CAST_SUCCESS'][391528] = function(info, _,_,_,_,_,_,_,_,_,_, timestamp)
	if info.talentData[434249] then
		local icon = info.spellIcons[391528]
		if icon and icon.active then
			P:UpdateCooldown(icon, min(timestamp - (info.auras.time_convoke or 0), 15))
			info.auras.time_convoke = timestamp
		end
	end
end

registeredEvents['SPELL_CAST_SUCCESS'][194223] = function(info, _,_,_,_,_,_,_,_,_,_, timestamp)
	if info.talentData[434249] then
		local icon = info.spellIcons[194223]
		if icon and icon.active then
			P:UpdateCooldown(icon, min(timestamp - (info.auras.time_celestialalignment or 0), 15))
			info.auras.time_celestialalignment = timestamp
		end
	end
end
registeredEvents['SPELL_CAST_SUCCESS'][383410] = registeredEvents['SPELL_CAST_SUCCESS'][194223]

registeredEvents['SPELL_CAST_SUCCESS'][102560] = function(info, _,_,_,_,_,_,_,_,_,_, timestamp)
	if info.talentData[434249] then
		local icon = info.spellIcons[102560]
		if icon and icon.active then
			P:UpdateCooldown(icon, min(timestamp - (info.auras.time_chosenofelune or 0), 15))
			info.auras.time_chosenofelune = timestamp
		end
	end
end
registeredEvents['SPELL_CAST_SUCCESS'][390414] = registeredEvents['SPELL_CAST_SUCCESS'][102560]

registeredEvents['SPELL_CAST_SUCCESS'][205636] = function(info, _,_,_,_,_,_,_,_,_,_, timestamp)
	if info.spec == 102 and info.talentData[434249] then
		local icon = info.spellIcons[205636]
		if icon and icon.active then
			P:UpdateCooldown(icon, min(timestamp - (info.auras.time_forceofnature or 0), 15))
			info.auras.time_forceofnature = timestamp
		end
	end
end


registeredEvents['SPELL_CAST_SUCCESS'][16979] = function(info)
	if info.talentData[443046] then
		local icon = info.spellIcons[102401]
		if icon and icon.active then
			P:UpdateCooldown(icon, 3)
		end
	end
end
registeredEvents['SPELL_CAST_SUCCESS'][102383] = registeredEvents['SPELL_CAST_SUCCESS'][16979]







E.majorMovementAbilities = {
	[381732] = { 48265, 444347 },
	[381741] = { 195072, 189110 },
	[381746] = { 1850, 252216 },
	[381748] = 358267,
	[381749] = 186257,
	[381750] = { 1953, 212653 },
	[381751] = { 109132, 115008 },
	[381752] = 190784,
	[381753] = 73325,
	[381754] = 2983,
	[381756] = { 79206, 58875, 192063 },
	[381757] = 48020,
	[381758] = 6544,
}

E.majorMovementAbilitiesByIDs = {}
for buffID, spellID in pairs(E.majorMovementAbilities) do
	if type(spellID) == "table" then
		for _, id in pairs(spellID) do
			E.majorMovementAbilitiesByIDs[id] = buffID
		end
	else
		E.majorMovementAbilitiesByIDs[spellID] = buffID
	end
end

local updateCDonBronzeRemoval = {
	[381732] = true,
	[381741] = true,
	[381748] = true,
	[381750] = true,
	[381751] = true,
	[381752] = true,
	[381753] = true,
	[381758] = true,
}

registeredEvents['SPELL_AURA_REMOVED'][381748] = function(_,_, spellID, destGUID)
	local destInfo = groupInfo[destGUID]
	if destInfo and destInfo.auras["blessingOfTheBronze"] then
		if ( updateCDonBronzeRemoval[spellID] ) then
			local id = E.majorMovementAbilities[spellID]
			if type(id) == "table" then
				for _, target in pairs(id) do
					local icon = destInfo.spellIcons[target]
					if icon and icon.active then
						P:UpdateCooldown(icon, 0, 1/0.85)
					end
				end
			else
				local icon = destInfo.spellIcons[id]
				if icon and icon.active then
					P:UpdateCooldown(icon, 0, 1/0.85)
				end
			end
		end
		destInfo.auras["blessingOfTheBronze"] = nil
	end
end

registeredEvents['SPELL_AURA_REMOVED'][381732] = registeredEvents['SPELL_AURA_REMOVED'][381748]
registeredEvents['SPELL_AURA_REMOVED'][381741] = registeredEvents['SPELL_AURA_REMOVED'][381748]
registeredEvents['SPELL_AURA_REMOVED'][381746] = registeredEvents['SPELL_AURA_REMOVED'][381748]
registeredEvents['SPELL_AURA_REMOVED'][381749] = registeredEvents['SPELL_AURA_REMOVED'][381748]
registeredEvents['SPELL_AURA_REMOVED'][381750] = registeredEvents['SPELL_AURA_REMOVED'][381748]
registeredEvents['SPELL_AURA_REMOVED'][381751] = registeredEvents['SPELL_AURA_REMOVED'][381748]
registeredEvents['SPELL_AURA_REMOVED'][381752] = registeredEvents['SPELL_AURA_REMOVED'][381748]
registeredEvents['SPELL_AURA_REMOVED'][381753] = registeredEvents['SPELL_AURA_REMOVED'][381748]
registeredEvents['SPELL_AURA_REMOVED'][381754] = registeredEvents['SPELL_AURA_REMOVED'][381748]
registeredEvents['SPELL_AURA_REMOVED'][381756] = registeredEvents['SPELL_AURA_REMOVED'][381748]
registeredEvents['SPELL_AURA_REMOVED'][381757] = registeredEvents['SPELL_AURA_REMOVED'][381748]
registeredEvents['SPELL_AURA_REMOVED'][381758] = registeredEvents['SPELL_AURA_REMOVED'][381748]

registeredEvents['SPELL_AURA_APPLIED'][381748] = function(_,_, spellID, destGUID)
	local destInfo = groupInfo[destGUID]
	if destInfo and not destInfo.auras["blessingOfTheBronze"] then
		local id = E.majorMovementAbilities[spellID]
		if type(id) == "table" then
			for _, target in pairs(id) do
				local icon = destInfo.spellIcons[target]
				if icon and icon.active then
					P:UpdateCooldown(icon, 0, 0.85)
				end
			end
		else
			local icon = destInfo.spellIcons[id]
			if icon and icon.active then
				P:UpdateCooldown(icon, 0, 0.85)
			end
		end
		destInfo.auras["blessingOfTheBronze"] = true
	end
end

registeredEvents['SPELL_AURA_APPLIED'][381732] = registeredEvents['SPELL_AURA_APPLIED'][381748]
registeredEvents['SPELL_AURA_APPLIED'][381741] = registeredEvents['SPELL_AURA_APPLIED'][381748]
registeredEvents['SPELL_AURA_APPLIED'][381746] = registeredEvents['SPELL_AURA_APPLIED'][381748]
registeredEvents['SPELL_AURA_APPLIED'][381749] = registeredEvents['SPELL_AURA_APPLIED'][381748]
registeredEvents['SPELL_AURA_APPLIED'][381750] = registeredEvents['SPELL_AURA_APPLIED'][381748]
registeredEvents['SPELL_AURA_APPLIED'][381751] = registeredEvents['SPELL_AURA_APPLIED'][381748]
registeredEvents['SPELL_AURA_APPLIED'][381752] = registeredEvents['SPELL_AURA_APPLIED'][381748]
registeredEvents['SPELL_AURA_APPLIED'][381753] = registeredEvents['SPELL_AURA_APPLIED'][381748]
registeredEvents['SPELL_AURA_APPLIED'][381754] = registeredEvents['SPELL_AURA_APPLIED'][381748]
registeredEvents['SPELL_AURA_APPLIED'][381756] = registeredEvents['SPELL_AURA_APPLIED'][381748]
registeredEvents['SPELL_AURA_APPLIED'][381757] = registeredEvents['SPELL_AURA_APPLIED'][381748]
registeredEvents['SPELL_AURA_APPLIED'][381758] = registeredEvents['SPELL_AURA_APPLIED'][381748]

E.auraMultString[381748] = "blessingOfTheBronze"
E.auraMultString[381732] = "blessingOfTheBronze"
E.auraMultString[381741] = "blessingOfTheBronze"
E.auraMultString[381746] = "blessingOfTheBronze"
E.auraMultString[381749] = "blessingOfTheBronze"
E.auraMultString[381750] = "blessingOfTheBronze"
E.auraMultString[381751] = "blessingOfTheBronze"
E.auraMultString[381752] = "blessingOfTheBronze"
E.auraMultString[381753] = "blessingOfTheBronze"
E.auraMultString[381754] = "blessingOfTheBronze"
E.auraMultString[381756] = "blessingOfTheBronze"
E.auraMultString[381757] = "blessingOfTheBronze"
E.auraMultString[381758] = "blessingOfTheBronze"


registeredEvents['SPELL_AURA_REMOVED'][375234] = function(info, srcGUID, spellID, destGUID)
	local destInfo = groupInfo[destGUID]
	if destInfo then
		destInfo.auras["timeSpiral"] = nil
	end
	if spellID == 375234 then
		RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
	end
end
registeredEvents['SPELL_AURA_REMOVED'][375226] = registeredEvents['SPELL_AURA_REMOVED'][375234]
registeredEvents['SPELL_AURA_REMOVED'][375229] = registeredEvents['SPELL_AURA_REMOVED'][375234]
registeredEvents['SPELL_AURA_REMOVED'][375230] = registeredEvents['SPELL_AURA_REMOVED'][375234]
registeredEvents['SPELL_AURA_REMOVED'][375238] = registeredEvents['SPELL_AURA_REMOVED'][375234]
registeredEvents['SPELL_AURA_REMOVED'][375240] = registeredEvents['SPELL_AURA_REMOVED'][375234]
registeredEvents['SPELL_AURA_REMOVED'][375252] = registeredEvents['SPELL_AURA_REMOVED'][375234]
registeredEvents['SPELL_AURA_REMOVED'][375253] = registeredEvents['SPELL_AURA_REMOVED'][375234]
registeredEvents['SPELL_AURA_REMOVED'][375254] = registeredEvents['SPELL_AURA_REMOVED'][375234]
registeredEvents['SPELL_AURA_REMOVED'][375255] = registeredEvents['SPELL_AURA_REMOVED'][375234]
registeredEvents['SPELL_AURA_REMOVED'][375256] = registeredEvents['SPELL_AURA_REMOVED'][375234]
registeredEvents['SPELL_AURA_REMOVED'][375257] = registeredEvents['SPELL_AURA_REMOVED'][375234]
registeredEvents['SPELL_AURA_REMOVED'][375258] = registeredEvents['SPELL_AURA_REMOVED'][375234]

registeredEvents['SPELL_AURA_APPLIED'][375234] = function(_,_,_, destGUID)
	local destInfo = groupInfo[destGUID]
	if destInfo then
		destInfo.auras["timeSpiral"] = true
	end
end
registeredEvents['SPELL_AURA_APPLIED'][375226] = registeredEvents['SPELL_AURA_APPLIED'][375234]
registeredEvents['SPELL_AURA_APPLIED'][375229] = registeredEvents['SPELL_AURA_APPLIED'][375234]
registeredEvents['SPELL_AURA_APPLIED'][375230] = registeredEvents['SPELL_AURA_APPLIED'][375234]
registeredEvents['SPELL_AURA_APPLIED'][375238] = registeredEvents['SPELL_AURA_APPLIED'][375234]
registeredEvents['SPELL_AURA_APPLIED'][375240] = registeredEvents['SPELL_AURA_APPLIED'][375234]
registeredEvents['SPELL_AURA_APPLIED'][375252] = registeredEvents['SPELL_AURA_APPLIED'][375234]
registeredEvents['SPELL_AURA_APPLIED'][375253] = registeredEvents['SPELL_AURA_APPLIED'][375234]
registeredEvents['SPELL_AURA_APPLIED'][375254] = registeredEvents['SPELL_AURA_APPLIED'][375234]
registeredEvents['SPELL_AURA_APPLIED'][375255] = registeredEvents['SPELL_AURA_APPLIED'][375234]
registeredEvents['SPELL_AURA_APPLIED'][375256] = registeredEvents['SPELL_AURA_APPLIED'][375234]
registeredEvents['SPELL_AURA_APPLIED'][375257] = registeredEvents['SPELL_AURA_APPLIED'][375234]
registeredEvents['SPELL_AURA_APPLIED'][375258] = registeredEvents['SPELL_AURA_APPLIED'][375234]

E.auraMultString[375234] = "timeSpiral"
E.auraMultString[375226] = "timeSpiral"
E.auraMultString[375229] = "timeSpiral"
E.auraMultString[375230] = "timeSpiral"
E.auraMultString[375238] = "timeSpiral"
E.auraMultString[375240] = "timeSpiral"
E.auraMultString[375252] = "timeSpiral"
E.auraMultString[375253] = "timeSpiral"
E.auraMultString[375254] = "timeSpiral"
E.auraMultString[375255] = "timeSpiral"
E.auraMultString[375256] = "timeSpiral"
E.auraMultString[375257] = "timeSpiral"
E.auraMultString[375258] = "timeSpiral"


local empoweredSpells = {
	357208,
	359073,
}

registeredEvents['SPELL_PERIODIC_DAMAGE'][356995] = function(info)
	if info.talentData[375777] then
		for _, id in pairs(empoweredSpells) do
			local icon = info.spellIcons[id]
			if icon and icon.active then
				P:UpdateCooldown(icon, .5)
			end
		end
	end
end

local ReduceEmpowredSpellCD_OnDelayEnd = function(srcGUID)
	local info = groupInfo[srcGUID]
	if info then
		local reducedTime = info.auras.numhits_Pyre * 0.4
		for _, id in pairs(empoweredSpells) do
			local icon = info.spellIcons[id]
			if icon and icon.active then
				P:UpdateCooldown(icon, reducedTime)
			end
		end
		info.auras.numhits_Pyre = 0
		info.callbackTimers[357212] = nil
	end
end

registeredEvents['SPELL_DAMAGE'][357212] = function(info, srcGUID)
	if info.talentData[375777] then
		if info.active[357208] or info.active[359073] then
			info.auras.numhits_Pyre = info.auras.numhits_Pyre or 0
			if info.auras.numhits_Pyre <= 5 then
				info.auras.numhits_Pyre = info.auras.numhits_Pyre + 1
				if info.auras.numhits_Pyre == 1 then
					info.callbackTimers[357212] = E.TimerAfter(0.1, ReduceEmpowredSpellCD_OnDelayEnd, srcGUID)
				end
			end
		end
	end
end


registeredEvents['SPELL_SUMMON'][368415] = function(info)
	local icon = info.spellIcons[368412]
	if icon then
		P:StartCooldown(icon, icon.duration)
	end
end


registeredEvents['SPELL_AURA_APPLIED'][370818] = function(info)
	info.auras["snapFire"] = true
end
registeredEvents['SPELL_AURA_REMOVED'][370818] = function(info)
	info.auras["snapFire"] = nil
end
E.auraMultString[370818] = "snapFire"




registeredEvents['SPELL_EMPOWER_INTERRUPT'][367226] = function(info, _, spellID)
	local icon = info.spellIcons[E.spell_merged[spellID] or spellID]
	if icon and icon.active then
		P:ResetCooldown(icon)
	end
end
registeredEvents['SPELL_EMPOWER_INTERRUPT'][382731] = registeredEvents['SPELL_EMPOWER_INTERRUPT'][367226]
registeredEvents['SPELL_EMPOWER_INTERRUPT'][355936] = registeredEvents['SPELL_EMPOWER_INTERRUPT'][367226]
registeredEvents['SPELL_EMPOWER_INTERRUPT'][382614] = registeredEvents['SPELL_EMPOWER_INTERRUPT'][367226]
registeredEvents['SPELL_EMPOWER_INTERRUPT'][357208] = registeredEvents['SPELL_EMPOWER_INTERRUPT'][367226]
registeredEvents['SPELL_EMPOWER_INTERRUPT'][382266] = registeredEvents['SPELL_EMPOWER_INTERRUPT'][367226]
registeredEvents['SPELL_EMPOWER_INTERRUPT'][396286] = registeredEvents['SPELL_EMPOWER_INTERRUPT'][367226]
registeredEvents['SPELL_EMPOWER_INTERRUPT'][408092] = registeredEvents['SPELL_EMPOWER_INTERRUPT'][367226]
registeredEvents['SPELL_EMPOWER_INTERRUPT'][359073] = registeredEvents['SPELL_EMPOWER_INTERRUPT'][367226]
registeredEvents['SPELL_EMPOWER_INTERRUPT'][382411] = registeredEvents['SPELL_EMPOWER_INTERRUPT'][367226]


local UpdateAllBars_OnDelayEnd = function() P:UpdateAllBars() end
registeredEvents['SPELL_CAST_SUCCESS'][408233] = function(info, _,_, destGUID)
	info = info or groupInfo[destGUID]
	if info then
		C_Timer_After(0.5, UpdateAllBars_OnDelayEnd)
	end
end
registeredUserEvents['SPELL_CAST_SUCCESS'][408233] = registeredEvents['SPELL_CAST_SUCCESS'][408233]







registeredEvents['SPELL_AURA_APPLIED'][385646] = function(info)
	local icon = info.spellIcons[186387] or info.spellIcons[213691]
	if icon and icon.active then
		P:ResetCooldown(icon)
	end
end


registeredEvents['SPELL_AURA_REMOVED'][360952] = function(info, srcGUID, spellID, destGUID)
	if info.talentData[389880] then
		local icon = info.spellIcons[259495]
		if icon and icon.active then
			for i = 1, (icon.maxcharges or 1) do
				P:ResetCooldown(icon)
			end
		end
	end
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end

registeredEvents['SPELL_AURA_APPLIED'][459859] = function(info)
	info.auras["bombardier"] = true
end
registeredEvents['SPELL_AURA_REMOVED'][459859] = function(info)
	info.auras["bombardier"] = nil
end
E.auraMultString[459859] = "bombardier"


registeredEvents['SPELL_AURA_APPLIED'][194594] = function(info)
	info.auras["LockAndLoad"] = true
end
local RemoveLockAndLoad_OnDelayEnd = function(srcGUID)
	local info = groupInfo[srcGUID]
	if info then
		info.auras["LockAndLoad"] = nil
	end
end
registeredEvents['SPELL_AURA_REMOVED'][194594] = function(_, srcGUID)
	C_Timer_After(0.1, function() RemoveLockAndLoad_OnDelayEnd(srcGUID) end)
end

registeredEvents['SPELL_AURA_APPLIED'][288613] = function(info)
	info.auras.isTrueshot = true
	local icon = info.spellIcons[257044]
	if icon and icon.active then
		P:UpdateCooldown(icon, 0, 0.3)
	end
end
registeredEvents['SPELL_AURA_REMOVED'][288613] = function(info, srcGUID, spellID, destGUID)
	info.auras.isTrueshot = nil
	local icon = info.spellIcons[257044]
	if icon and icon.active then
		P:UpdateCooldown(icon, 0, 1/0.3)
	end
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end

--[[
registeredEvents['SPELL_CAST_SUCCESS'][288613] = function(info)
	if info.talentData[260404] and info.spellIcons[288613] then
		info.auras.usedFocus_trueshot = 0
	end
end
]]

registeredEvents['SPELL_CAST_SUCCESS'][109304] = function(info)
	if info.talentData[270581] and info.spellIcons[109304] then
		info.auras.usedFocus_exhilaration = 0
	end
end

local focusSpenders = {
	[34026] = 30,
	[320976] = 10,
	[53351] = 10,
	[2643] = 40,
	[257620] = 30,
	[1513] = 25,
	[19434] = 35,
	[195645] = 20,
	[193455] = 35,
	[212431] = 20,
	[186270] = 30,
	[265189] = 30,
	[259387] = 30,
	[212436] = 30,
	[259495] = 10,
	[269751] = 15,
	[185358] = 40,
	[342049] = 40,
	[186387] = 10,
	[392060] = 15,
	[203155] = 40,
	[208652] = 30,
	[205691] = 60,
	[982] = { [255]=10,["d"]=35 },
	[120360] = { [254]=30,["d"]=60 },
	[459796] = 30,
	[430703] = 10,
}

local function ReduceNaturalMendingCD(info, _, spellID)
	local exhilarationIcon = info.spellIcons[109304]
	local naturalMendingRank = exhilarationIcon and exhilarationIcon.active and info.talentData[270581]
	local trueShotIcon = info.spellIcons[288613]
	local isTrueshotOnCD = trueShotIcon and trueShotIcon.active and info.talentData[260404]
	if naturalMendingRank or isTrueshotOnCD then
		local rCD = focusSpenders[spellID]
		if type(rCD) == "table" then
			rCD = rCD[info.spec] or rCD.d
		end
		if info.spec == 255 then
			if spellID == 186270 then
				if info.auras["FuriousAssault"] then
					return
				end
			elseif spellID == 212431 then
				if info.auras.bombardier then
					return
				end
			end
		elseif info.spec == 254 then
			if spellID == 19434 then

				if info.auras["LockAndLoad"] then
					return
				end

				if info.auras.isTrueshot and info.talentData[389449] then
					rCD = rCD / 2
				end
			elseif spellID == 185358 or spellID == 342049 then

				if info.talentData[321293] then
					rCD = rCD - 20
				end

				if info.auras["PreciseShot"] then
					rCD = rCD / (spellID == 342049 and 4 or 2)
				end
			elseif spellID == 257620 then

				if info.auras["PreciseShot"] then
					rCD = rCD / 2
				end
			end
			if isTrueshotOnCD then
				local focus = (info.auras.usedFocus_trueshot or 0) + rCD
				if focus >= 50 then
					P:UpdateCooldown(trueShotIcon, 2.5)
					focus = focus - 50
				end
				info.auras.usedFocus_trueshot = focus
			end
		end
		if naturalMendingRank then
			local focus = (info.auras.usedFocus_exhilaration or 0) + rCD
			if focus >= 10 then
				local rem = focus%10
				focus = focus - rem
				P:UpdateCooldown(exhilarationIcon, focus/10)
				focus = rem
			end
			info.auras.usedFocus_exhilaration = focus
		end
	end
end

for id in pairs(focusSpenders) do
	registeredEvents['SPELL_CAST_SUCCESS'][id] = ReduceNaturalMendingCD
end


registeredEvents['SPELL_DAMAGE'][203413] = function(info, _,_,_, critical, _,_,_,_,_,_, timestamp)
	if critical then
		local talentRank = info.talentData[385718]
		if talentRank then
			if timestamp > (info.auras.time_ruthlessmarauder or 0) then
				local icon = info.spellIcons[269751]
				if icon and icon.active then
					P:UpdateCooldown(icon, reducedTime or (0.5 * talentRank))
				end
				info.auras.time_ruthlessmarauder = timestamp + 0.1
			end
		end
	end
end


registeredEvents['SPELL_AURA_REMOVED_DOSE'][408518] = function(info, _,_,_,_,_,_,_,_,_,_, timestamp)
	if P.isPvP and info.talentData[248443] then
		local icon = info.spellIcons[186265]
		if icon and icon.active then
			if timestamp > (info.auras.time_rangersfinesse or 0) then
				P:UpdateCooldown(icon, 20)
				info.auras.time_rangersfinesse = timestamp + 1
			end
		end
	end
end


registeredEvents['SPELL_CAST_SUCCESS'][19801] = function(info, srcGUID)
	if info.talentData[459991] then
		local icon = info.spellIcons[19801]
		if icon then
			info.auras.devilsaurTranquilizer = true
			C_Timer_After(0.5, function()
				local info = groupInfo[srcGUID]
				if info then
					if info.auras.devilsaurTranquilizer == 1 then
						local icon = info.spellIcons[19801]
						if icon and icon.active then
							P:UpdateCooldown(icon, 5)
						end
					end
					info.auras.devilsaurTranquilizer = nil
				end
			end)
		end
	end
end

registeredEvents['SPELL_DISPEL'][19801] = function(info, _,_,_,_,_,_,_,_,_,_,_, extraSchool)
	if info.auras.devilsaurTranquilizer == true then
		info.auras.devilsaurTranquilizer = band(extraSchool, 1)
	elseif info.auras.devilsaurTranquilizer then
		info.auras.devilsaurTranquilizer = info.auras.devilsaurTranquilizer * band(extraSchool, 1)
	end
end


local function ClearSrcBlackArrow_OnDurationEnd(srcGUID, spellID, destGUID)
	if diedHostileGUIDS[destGUID] and diedHostileGUIDS[destGUID][srcGUID] and diedHostileGUIDS[destGUID][srcGUID][spellID] then
		diedHostileGUIDS[destGUID][srcGUID][spellID] = nil
	end
end

registeredEvents['SPELL_CAST_SUCCESS'][430703] = function(info, srcGUID, spellID, destGUID)
	if info.talentData[430719] and info.spellIcons[spellID] then
		diedHostileGUIDS[destGUID] = diedHostileGUIDS[destGUID] or {}
		diedHostileGUIDS[destGUID][srcGUID] = diedHostileGUIDS[destGUID][srcGUID] or {}
		diedHostileGUIDS[destGUID][srcGUID][spellID] = E.TimerAfter(18, ClearSrcBlackArrow_OnDurationEnd, srcGUID, spellID, destGUID)
	end
	ReduceNaturalMendingCD(info, nil, spellID)
end


registeredEvents['SPELL_DAMAGE'][450412] = function(info)
	local c = info.auras.numCDR_sentinelwatch
	if c then
		local icon = info.spellIcons[288613] or info.spellIcons[360952]
		if icon and icon.active then
			P:UpdateCooldown(icon, 1)
			c = c - 1
			info.auras.numCDR_sentinelwatch = c > 0 and c or nil
		end
	end
end

registeredEvents['SPELL_AURA_REMOVED_DOSE'][450387] = function(info, _, spellID, _,_,_,_, amount)
	local c = info.auras.numCDR_sentinelwatch
	if c then
		local icon = info.spellIcons[288613] or info.spellIcons[360952]
		if icon and icon.active then
			P:UpdateCooldown(icon, 1)
			c = c - 1
			info.auras.numCDR_sentinelwatch = c > 0 and c or nil
		end
	end
end

registeredEvents['SPELL_CAST_SUCCESS'][288613] = function(info, _, spellID)
	if info.talentData[260404] and info.spellIcons[spellID] then
		info.auras.usedFocus_trueshot = 0
	end
	if info.spellIcons[spellID] and info.talentData[451546] then
		info.auras.numCDR_sentinelwatch = 30
	end
end
registeredEvents['SPELL_CAST_SUCCESS'][360952] = function(info, _, spellID)
	if info.spellIcons[spellID] and info.talentData[451546] then
		info.auras.numCDR_sentinelwatch = 30
	end
end







local mageLossOfControlAbilities = {
	[122] = true,
	[120] = true,
	[157997] = true,
	[113724] = true,
	[31661] = true,
	[383121] = true,
	[389794] = true,

}


registeredEvents['SPELL_AURA_REMOVED'][263725] = function(info)
	info.auras.isClearcasting = nil
end
registeredEvents['SPELL_AURA_APPLIED'][263725] = function(info)
	if info.talentData[387807] then
		info.auras.isClearcasting = true
	end
end
registeredEvents['SPELL_CAST_SUCCESS'][5143] = function(info)
	if not info.auras.isClearcasting then
		return
	end
	for id in pairs(mageLossOfControlAbilities) do
		local icon = info.spellIcons[id]
		if icon and icon.active and (id ~= 120 or info.talentData[386763]) then
			P:UpdateCooldown(icon, 2)
		end
	end
end


registeredEvents['SPELL_CAST_SUCCESS'][108853] = function(info)
	if info.talentData[387807] then
		for id in pairs(mageLossOfControlAbilities) do
			local icon = info.spellIcons[id]
			if icon and icon.active and (id ~= 120 or info.talentData[386763]) then
				P:UpdateCooldown(icon, 2)
			end
		end
	end
end
registeredEvents['SPELL_CAST_SUCCESS'][319836] = registeredEvents['SPELL_CAST_SUCCESS'][108853]


local frozenDebuffs = {
	[122] = true,
	[386770] = true,
	[157997] = true,
	[82691] = true,
	[228358] = true,
	[228600] = true,
	[33395] = true,
}

registeredEvents['SPELL_AURA_REMOVED'][44544] = function(info)
	info.auras.hasFingerOfFrost = nil
end

registeredEvents['SPELL_AURA_APPLIED'][44544] = function(info)
	info.auras.hasFingerOfFrost = true
end

registeredEvents['SPELL_CAST_SUCCESS'][30455] = function(info, _,_, destGUID)
	if info.talentData[387807] then
		if info.auras.hasFingerOfFrost then
			for id in pairs(mageLossOfControlAbilities) do
				local icon = info.spellIcons[id]
				if icon and icon.active and (id ~= 120 or (info.talentData[386763] and not info.talentData[417493])) then
					P:UpdateCooldown(icon, 2)
				end
			end
		else
			local unit = UnitTokenFromGUID(destGUID)
			if unit then
				AuraUtil_ForEachAura(unit, "HARMFUL", nil, function(_,_,_,_,_,_,_,_,_, id)
					if frozenDebuffs[id] then
						for id in pairs(mageLossOfControlAbilities) do
							local icon = info.spellIcons[id]
							if icon and icon.active and (id ~= 120 or (info.talentData[386763] and not info.talentData[417493])) then
								P:UpdateCooldown(icon, 2)
							end
						end
						return true
					end
				end)
			end
		end
	end
end


local fireMageDirectDamageIDs = {
	133,
	11366,
	319836,
	108853,
	2948,
}

local function ReduceDirectDamageCD(info, _, spellID, _, critical, _,_,_,_,_,_, timestamp)
	local icon = info.spellIcons[190319]
	if icon and icon.active then
		local cdr = 0
		if critical and info.talentData[155148] then
			cdr = cdr + 1
		end
		if info.auras.isCombustion and info.talentData[416506] then
			cdr = cdr + 1.25
		end
		if cdr > 0 then
			P:UpdateCooldown(icon, cdr)
		end
	end

	if info.talentData[342344] then
		icon = info.spellIcons[257541]
		if icon and icon.active then
			if timestamp > (info.auras.time_phoenixflames or 0) then
				P:UpdateCooldown(icon, 1)
				info.auras.time_phoenixflames = timestamp + 0.1
			end
		end
	end
end
for _, id in pairs(fireMageDirectDamageIDs) do
	registeredEvents['SPELL_DAMAGE'][id] = ReduceDirectDamageCD
end

--[[
registeredEvents['SPELL_CAST_SUCCESS'][257541] = function(info, _,_, destGUID)
	info.auras.phoenixFlameTargetGUID = destGUID
end
]]

registeredEvents['SPELL_DAMAGE'][257542] = function(info, _,_, destGUID, critical)
	if destGUID == info.auras.phoenixFlameTargetGUID then
		local icon = info.spellIcons[190319]
		if icon and icon.active then
			local cdr
			if critical and info.talentData[155148] then
				cdr = 1
			end
			if info.auras.isCombustion and info.talentData[416506] then
				cdr = (cdr or 0) + 1.25
			end
			if cdr then
				P:UpdateCooldown(icon, cdr)
			end
		end
		info.auras.phoenixFlameTargetGUID = nil
	end
end

registeredEvents['SPELL_CAST_SUCCESS'][2120] = function(info)
	info.auras.numHits_flamestrike = 0
end

registeredEvents['SPELL_DAMAGE'][2120] = function(info, _,_,_, critical)
	if critical then
		local icon = info.spellIcons[190319]
		if icon and icon.active and info.auras.numHits_flamestrike <= 5 then
			local cdr
			if info.talentData[155148] then
				cdr = 0.2
			end
			if info.auras.isCombustion and info.talentData[416506] then
				cdr = (cdr or 0) + 0.25
			end
			if cdr then
				P:UpdateCooldown(icon, cdr)
			end
			info.auras.numHits_flamestrike = info.auras.numHits_flamestrike + 1
		end
	end
end

registeredEvents['SPELL_AURA_APPLIED'][190319] = function(info) info.auras.isCombustion = true end
registeredEvents['SPELL_AURA_REMOVED'][190319] = function(info, srcGUID, spellID, destGUID)
	info.auras.isCombustion = nil
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end


registeredEvents['SPELL_CAST_SUCCESS'][382445] = function(info)
	for id in pairs(info.active) do
		local icon = info.spellIcons[id]
		if icon and icon.active and icon.isBookType and id ~= 382440 and (id ~= 120 or not info.talentData[417493]) then
			P:UpdateCooldown(icon, 3)
		end
	end
end




registeredEvents['SPELL_AURA_REMOVED'][342246] = function(info, srcGUID, spellID, destGUID)
	if info.talentData[342249] then
		local icon = info.spellIcons[1953] or info.spellIcons[212653]
		if icon and icon.active then
			P:ResetCooldown(icon)

			local talentRank = info.talentData[382268]
			if talentRank then
				P:UpdateCooldown(icon, 2 * talentRank)
			end
		end
	end
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end


registeredEvents['SPELL_INTERRUPT'][2139] = function(info, _, spellID, _,_,_, extraSpellId, extraSpellName, _,_, destRaidFlags)
	if info.talentData[382297] then
		local icon = info.spellIcons[spellID]
		if icon and icon.active then
			P:UpdateCooldown(icon, 4)
		end
	end
	AppendInterruptExtras(info, nil, spellID, nil,nil,nil, extraSpellId, extraSpellName, nil,nil, destRaidFlags)
end

registeredEvents['SPELL_CAST_SUCCESS'][2139] = function(info, _, spellID, destGUID)
	if info.talentData[382297] then
		local icon = info.spellIcons[spellID]
		if icon and icon.active then
			local unit = UnitTokenFromGUID(destGUID)
			if unit then
				local _,_,_,_,_,_, notInterruptable, channelID = UnitChannelInfo(unit)
				if notInterruptable ~= false then
					return
				end
				if channelID == 47758 then
					P:UpdateCooldown(icon, 4)
				end
			end
		end
	end
end


registeredEvents['SPELL_DAMAGE'][190357] = function(info)
	if info.talentData[236662] then
		local icon = info.spellIcons[84714]
		if icon and icon.active then
			P:UpdateCooldown(icon, .5)
		end
	end
end


local reduceBlinkCD = function(srcGUID)
	local info = groupInfo[srcGUID]
	if info and info.auras.numEtherealBlinkSlow then
		local icon = info.spellIcons[1953] or info.spellIcons[212653]
		if icon and icon.active and info.auras.numEtherealBlinkSlow > 0 then
			P:UpdateCooldown(icon, min(5, info.auras.numEtherealBlinkSlow))
		end
		info.auras.numEtherealBlinkSlow = nil
	end
end
registeredEvents['SPELL_CAST_SUCCESS'][1953] = function(info, srcGUID)
	if P.isPvP and info.talentData[410939] and (info.spellIcons[1953] or info.spellIcons[212653]) then
		info.auras.numEtherealBlinkSlow = 0
		C_Timer_After(0.3, function() reduceBlinkCD(srcGUID) end)
	end
end
registeredEvents['SPELL_CAST_SUCCESS'][212653] = registeredEvents['SPELL_CAST_SUCCESS'][1953]

registeredEvents['SPELL_AURA_APPLIED'][31589] = function(info)
	if info.auras.numEtherealBlinkSlow then
		info.auras.numEtherealBlinkSlow = info.auras.numEtherealBlinkSlow + 1
	end
end
registeredEvents['SPELL_AURA_REFRESH'][31589] = registeredEvents['SPELL_AURA_APPLIED'][31589]
registeredEvents['SPELL_MISSED'][31589] = registeredEvents['SPELL_AURA_APPLIED'][31589]



registeredEvents['SPELL_CAST_SUCCESS'][120] = function(info)
	if info.talentData[417493] then
		info.auras.numHits_coneOfCold = 0
	end
end

registeredEvents['SPELL_DAMAGE'][120] = function(info)
	if info.talentData[417493] then
		info.auras.numHits_coneOfCold = (info.auras.numHits_coneOfCold or 0) + 1
		if info.auras.numHits_coneOfCold == 3 then
			local icon = info.spellIcons[153595]
			if icon and icon.active then
				P:ResetCooldown(icon)
			end
			icon = info.spellIcons[84714]
			if icon and icon.active then
				P:ResetCooldown(icon)
			end
		end
	end
end


registeredEvents['SPELL_AURA_APPLIED'][438611] = function(info)
	info.auras.excessFrost = true
end
registeredEvents['SPELL_CAST_SUCCESS'][44614] = function(info)
	if info.auras.excessFrost then
		local icon = info.spellIcons[153595]
		if icon and icon.active then
			P:UpdateCooldown(icon, 5)
		end
	end
end
registeredEvents['SPELL_CAST_SUCCESS'][257541] = function(info, _,_, destGUID)
	if info.auras.excessFrost then
		local icon = info.spellIcons[153561]
		if icon and icon.active then
			P:UpdateCooldown(icon, 5)
		end
	end
	info.auras.phoenixFlameTargetGUID = destGUID
end
registeredEvents['SPELL_AURA_REMOVED'][438611] = function(info)
	info.auras.excessFrost = nil
end


registeredEvents['SPELL_AURA_APPLIED'][190446] = function(info)
	local icon = info.spellIcons[44614]
	if icon and icon.active then
		P:ResetCooldown(icon)
	end
end




registeredEvents['SPELL_AURA_APPLIED'][458411] = function(info)
	local icon = info.spellIcons[84714]
	if icon and icon.active then
		P:ResetCooldown(icon)
	end
end


if E.isDF then
	local fireMageFrostSpellIDs = {
		120,
		122,
		113724,
		157997,

	}
	registeredEvents['SPELL_AURA_APPLIED'][87023] = function(info)
		for _, id in pairs(fireMageFrostSpellIDs) do
			local icon = info.spellIcons[id]
			if icon and icon.active then
				P:ResetCooldown(icon, id == 122 and info.talentData[205036])
			end
		end
	end
end






local monkBrews = {
	115203,
	322507,
	119582,
	115399,
}


registeredEvents['SWING_DAMAGE']['MONK'] = function(info, _,_, destGUID)
	if info.talentData[418359] then
		local rt = info.auras.bonedustTargetGUID and info.auras.bonedustTargetGUID[destGUID] and 1.5 or 0.5
		for i = 1, 5 do
			local id = monkBrews[i]
			local icon = info.spellIcons[id]
			if icon and icon.active then
				P:UpdateCooldown(icon, rt)
			end
		end
	end
end


registeredEvents['SPELL_AURA_APPLIED'][228563] = function(info)
	info.auras.isBlackoutCombo = true
end

registeredEvents['SPELL_AURA_REMOVED'][228563] = function(info)
	info.auras.isBlackoutCombo = nil
end


registeredEvents['SPELL_AURA_REMOVED'][387184] = function(info, srcGUID, spellID, destGUID)
	info.auras["isWeaponsOfOrder"] = nil
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end
registeredEvents['SPELL_AURA_APPLIED'][387184] = function(info)
	info.auras["isWeaponsOfOrder"] = true
end


registeredEvents['SPELL_AURA_APPLIED'][393786] = function(info)
	local active = info.active[387184]
	if active then
		active.numHits = (active.numHits or 0) + 1
		if active.numHits <= 5 then
			local icon = info.spellIcons[387184]
			if icon and icon.active then
				P:UpdateCooldown(icon, 4)
			end
		end
	end
end


local stunDebuffs = {
	108194,
	221562,
	91800,
	91797,
	287254,
	210141,
	377048,
	179057,
	211881,
	205630,
	208618,
	200166,
	213491,
	5211,
	203123,
	163505,
	202244,
	372245,
	24394,
	357021,
	389831,
	119381,
	202346,
	853,
	255941,
	385149,
	64044,
	200200,
	408,
	1833,
	305485,
	118905,
	77505,
	118345,
	30283,
	89766,
	22703,
	213688,
	171017,
	171018,
	385954,
	46968,
	132168,
	132169,
	199085,
	20549,
	255723,
	287712,
}

for _, id in pairs(stunDebuffs) do
	registeredHostileEvents['SPELL_AURA_APPLIED'][id] = function(destInfo)
		if P.isPvP and destInfo.talentData[353584] and destInfo.spellIcons[119996] then
			local c = destInfo.auras.isStunned
			c = c and c + 1 or 1
			destInfo.auras.isStunned = c
		end
	end
	registeredHostileEvents['SPELL_AURA_REMOVED'][id] = function(destInfo)
		local c = destInfo.auras.isStunned
		if c then
			destInfo.auras.isStunned = max(c - 1, 0)
		end
	end
end

registeredEvents['SPELL_CAST_SUCCESS'][119996] = function(info, _, spellID)
	local icon = info.spellIcons[spellID]
	if icon and not info.auras.isEscapeFromReality then
		P:StartCooldown(icon, P.isPvP and info.talentData[353584] and (not info.auras.isStunned or info.auras.isStunned < 1) and icon.duration - 15 or icon.duration )
	end
end





registeredEvents['SPELL_AURA_REMOVED'][394112] = function(info)
	if info and info.auras.isEscapeFromReality then
		info.auras.isEscapeFromReality = nil
		local icon = info.spellIcons[119996]
		if icon and not icon.active then
			P:StartCooldown(icon, 35)
		end
	end
end

registeredEvents['SPELL_AURA_APPLIED'][394112] = function(info)
	if info.spellIcons[119996] then
		info.auras.isEscapeFromReality = true
	end
end


registeredEvents['SPELL_HEAL'][191894] = function(info)
	if info.talentData[388031] then
		local icon = info.spellIcons[322118] or info.spellIcons[325197]
		if icon and icon.active then
			P:UpdateCooldown(icon, .5)
		end
	end
end


registeredEvents['SPELL_AURA_REMOVED'][393099] = function(info)
	info.auras.isForbiddenTechnique = nil
	local icon = info.spellIcons[322109]
	if icon then
		P:StartCooldown(icon, icon.duration)
	end
end

registeredEvents['SPELL_AURA_APPLIED'][393099] = function(info)
	info.auras.isForbiddenTechnique = true
end

registeredEvents['SPELL_CAST_SUCCESS'][322109] = function(info)
	local icon = info.spellIcons[322109]
	if icon and not info.auras.isForbiddenTechnique then
		P:StartCooldown(icon, icon.duration)
	end
end


registeredEvents['SPELL_DAMAGE'][322109] = function(info, _,_,_,_, destFlags, _, overkill)
	if overkill > -1 and P:IsTalentForPvpStatus(345829, info) and band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
		local icon = info.spellIcons[122470]
		if icon and icon.active then
			P:UpdateCooldown(icon, 60)
		end
	end
end


local function ReduceBrewCD(destInfo, _,_, missType, _,_, timestamp)
	local talentRank = destInfo.talentData[386937]
	if talentRank and (missType == "DODGE" or missType == "MISS" ) then


			local talentValue = talentRank == 2 and 1 or .5
			for i = 1, 5 do
				local id = monkBrews[i]
				local icon = destInfo.spellIcons[id]
				if icon and icon.active then
					P:UpdateCooldown(icon, talentValue)
				end
			end


	end
end
registeredHostileEvents['SWING_MISSED']['MONK'] = function(destInfo,_,spellID,_,_,_,timestamp) ReduceBrewCD(destInfo,nil,nil,spellID,nil,nil,timestamp) end
registeredHostileEvents['RANGE_MISSED']['MONK'] = ReduceBrewCD
registeredHostileEvents['SPELL_MISSED']['MONK'] = ReduceBrewCD


registeredEvents['SPELL_AURA_APPLIED'][388203] = function(info)
	local icon = info.spellIcons[388193]
	if icon and icon.active then
		P:ResetCooldown(icon)
	end
end


registeredEvents['SPELL_AURA_APPLIED'][137639] = function(info)
	info.auras.isSEF = true
	if info.talentData[451463] then
		info.auras.isSEFwithOrderedElements = true
	end
end
registeredEvents['SPELL_AURA_REMOVED'][137639] = function(info, srcGUID, spellID, destGUID)
	info.auras.isSEF = nil
	info.auras.isSEFwithOrderedElements = nil
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end


local wwChiSpenders = {
	[113656] = 3,
	[392983] = 2,
	[116847] = 1,
	[107428] = 2,
	[100784] = 1,
	[101546] = 2,
}

local function ReduceSEFSerenityCD(info, _, spellID)
	if info.talentData[280197] then
		local icon = info.spellIcons[137639]
		if icon and icon.active then
			local e = wwChiSpenders[spellID]
			if info.auras["OrderedElements"] then
				e = e - 1
			end
			e = (info.auras.spentChi_spiritualFocus or 0) + e
			if e >= 2 then
				local rem = e%2
				P:UpdateCooldown(icon, (e-rem)/4)
				e = rem
			end
			info.auras.spentChi_spiritualFocus = e
		end
	end
end
for id in pairs(wwChiSpenders) do
	registeredEvents['SPELL_CAST_SUCCESS'][id] = ReduceSEFSerenityCD
end


registeredEvents['SPELL_AURA_REMOVED'][116680] = function(info, srcGUID, spellID, destGUID)
	info.auras["thunderousFocusTeaPVP"] = nil
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end
registeredEvents['SPELL_AURA_APPLIED'][116680] = function(info)
	if P.isPvP and info.talentData[353936] then
		info.auras["thunderousFocusTeaPVP"] = true
	end
end
E.auraMultString[116680] = "thunderousFocusTeaPVP"


registeredEvents['SPELL_HEAL'][116670] = function(info, _,_,_,_,_,_,_,_, criticalHeal)
	if info.talentData[388551] and criticalHeal then
		local icon = info.spellIcons[115310] or info.spellIcons[388615]
		if icon and icon.active then
			P:UpdateCooldown(icon, 1)
		end
	end
end

registeredEvents['SPELL_DAMAGE'][185099] = function(info, _,_,_, critical)
	if info.talentData[388551] then
		local icon = info.spellIcons[115310] or info.spellIcons[388615]
		if icon and icon.active then
			P:UpdateCooldown(icon, 1)
		end
	end
	if critical then
		if info.talentData[392993] then
			local icon = info.spellIcons[113656]
			if icon and icon.active then
				P:UpdateCooldown(icon, P.isPvP and 2 or 4)
			end
		end
	end
end



registeredEvents['SPELL_DAMAGE'][121253] = function(info, _,_,_,_,_,_,_,_,_,_, timestamp)
	local talentRank = info.talentData[387219]
	if talentRank then
		local icon = info.spellIcons[132578]
		if icon and icon.active then
			if timestamp > (info.auras.time_shuffle or 0) then
				P:UpdateCooldown(icon, .25 * talentRank)
				info.auras.time_shuffle = timestamp + .1
			end
		end
	end
end
registeredEvents['SPELL_DAMAGE'][107270] = registeredEvents['SPELL_DAMAGE'][121253]
registeredEvents['SPELL_DAMAGE'][205523] = registeredEvents['SPELL_DAMAGE'][121253]


local bmEnergySpenders = {

	[117952] = 20,
	[116095] = 15,
	[322101] = 15,
	[115078] = 20,
	[322729] = 25,
	[100780] = 25,
	[116670] = 30,
	[121253] = 40,
	[115175] = 15,
	[218164] = 10,
}

local wwEnergySpenders = {
	[117952] = 20,
	[116095] = 15,
	[115078] = 20,
	[100780] = 60,
	[116670] = 30,
	[115175] = 15,
	[218164] = 10,
}

registeredEvents['SPELL_CAST_SUCCESS'][387184] = function(info)
	info.auras.usedenergy_woosef = 0
end
registeredEvents['SPELL_CAST_SUCCESS'][137639] = registeredEvents['SPELL_CAST_SUCCESS'][387184]

local function ReduceWoOSEFCD(info, _, spellID)
	if info.talentData[450989] then
		if info.spec == 268 then
			local icon = info.spellIcons[387184]
			if icon and icon.active then
				local e = bmEnergySpenders[spellID]
				if spellID == 116670 and info.auras["VivaciousVivification"] then
					e = e/4
				end
				e = (info.auras.usedenergy_woosef or 0) + e
				if e >= 50 then
					local rem = e%50
					e = e - rem
					P:UpdateCooldown(icon, e/50)
					e = rem
				end
				info.auras.usedenergy_woosef = e
			end
		elseif info.spec == 269 then
			local icon = info.spellIcons[137639]
			if icon and icon.active then
				local e = wwEnergySpenders[spellID]
				if spellID == 100780 then
					if info.talentData[397768] then
						e = e - 5
					end
				elseif spellID == 117952 then
					if info.auras["TheEmperorsCapacitor"] then
						e = e * (1 - .05 * info.auras["TheEmperorsCapacitor"])
					end
				elseif spellID == 116670 then
					if info.auras["VivaciousVivification"] then
						e = e/4
					end
				end
				e = (info.auras.usedenergy_woosef or 0) + e
				if e >= 50 then
					local rem = e%50
					e = e - rem
					P:UpdateCooldown(icon, e/50)
					e = rem
				end
				info.auras.usedenergy_woosef = e
			end
		end
	end
end
for id in pairs(bmEnergySpenders) do
	if ( id == 115175 ) then
		registeredEvents['SPELL_PERIODIC_HEAL'][115175] = ReduceWoOSEFCD
	elseif ( id == 117952 ) then
		registeredEvents['SPELL_PERIODIC_DAMAGE'][117952] = ReduceWoOSEFCD
	else
		registeredEvents['SPELL_CAST_SUCCESS'][id] = ReduceWoOSEFCD
	end
end


registeredEvents['SPELL_INTERRUPT'][116705] = function(info, _, spellID, _,_,_, extraSpellId, extraSpellName, _,_, destRaidFlags)
	if info.talentData[450631] then
		local icon = info.spellIcons[115078]
		if icon and icon.active then
			P:UpdateCooldown(icon, 5)
		end
	end
	AppendInterruptExtras(info, nil, spellID, nil,nil,nil, extraSpellId, extraSpellName, nil,nil, destRaidFlags)
end







registeredEvents['SPELL_HEAL'][633] = function(info, _,_, destGUID, _,_, amount, overhealing)
	local icon = info.spellIcons[633]
	if icon then
		P:StartCooldown(icon, icon.duration)
		if info.talentData[326734] then
			local unit = UnitTokenFromGUID(destGUID)
			if unit then
				local maxHP = UnitHealthMax(unit)
				if maxHP > 0 then
					local actualhealing = amount - overhealing
					local reducedMult = min(actualhealing / maxHP * 6/7, 0.6)
					if reducedMult > 0 then
						if icon.active then
							P:UpdateCooldown(icon, icon.duration * reducedMult)
						end
					end
				end
			end
		end
	end
end


registeredEvents['SPELL_AURA_REMOVED'][327193] = function(info, srcGUID, spellID, destGUID)
	info.auras["momentOfGlory"] = nil
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end
registeredEvents['SPELL_AURA_APPLIED'][327193] = function(info)
	local icon = info.spellIcons[31935]
	if icon then
		if icon.active then
			P:ResetCooldown(icon)
		end
		info.auras["momentOfGlory"] = true
	end
end
E.auraMultString[327193] = "momentOfGlory"

registeredEvents['SPELL_CAST_SUCCESS'][31935] = function(info)
	local icon = info.spellIcons[31935]
	if icon then
		P:StartCooldown(icon, icon.duration)
	end
end


registeredEvents['SPELL_AURA_APPLIED'][383329] = function(info)
	local icon = info.spellIcons[24275]
	if icon and icon.active then
		P:ResetCooldown(icon)
	end
end


registeredEvents['SPELL_AURA_APPLIED'][383283] = function(info)
	local icon = info.spellIcons[255937]
	if icon and icon.active then
		P:ResetCooldown(icon)
	end
end


registeredEvents['SPELL_AURA_APPLIED'][85416] = function(info)
	local icon = info.spellIcons[31935]
	if icon and icon.active then
		P:ResetCooldown(icon)
	end
end


local forbearanceIDs = E.isBCC and {
	[1022] = 0,
	[5599] = 0,
	[10278] = 0,
	[498] = 60,
	[5573] = 60,
	[642] = 60,
	[1020] = 60,
	[31884] = 60,
} or (E.isWOTLKC and {
	[1022] = 0,
	[633] = 0,
	[498] = 120,
	[642] = 120,
	[31884] = 30,
}) or (E.isCata and {
	[1022] = 0,
	[642] = 60,
	[633] = 0,
}) or {
	[1022] = 0,
	[204018] = 0,
	[642] = 30,
	[633] = 0,

}

registeredEvents['SPELL_AURA_REMOVED'][25771] = function(_,_,_, destGUID)
	local destInfo = groupInfo[destGUID]
	if destInfo then
		if destInfo.auras.isForbearanceOnUsableShown then
			for id in pairs(forbearanceIDs) do
				local icon = destInfo.preactiveIcons[id]
				if icon then
					icon.icon:SetVertexColor(1, 1, 1)
					destInfo.preactiveIcons[id] = nil
				end
			end
			destInfo.auras.isForbearanceOnUsableShown = nil
		end
	end
end
registeredEvents['SPELL_AURA_APPLIED'][25771] = function(_,_,_, destGUID)
	if ( E.db.icons.showForbearanceCounter ) then
		local destInfo = groupInfo[destGUID]
		if destInfo then
			for id in pairs(forbearanceIDs) do
				local icon = destInfo.spellIcons[id]
				if icon then
					if ( not icon.isHighlighted ) then
						icon.icon:SetVertexColor(0.4, 0.4, 0.4)
					end
					destInfo.preactiveIcons[id] = icon
					destInfo.auras.isForbearanceOnUsableShown = true
				end
			end
		end
	end
end

registeredUserEvents['SPELL_AURA_APPLIED'][25771] = registeredEvents['SPELL_AURA_APPLIED'][25771]
registeredUserEvents['SPELL_AURA_REMOVED'][25771] = registeredEvents['SPELL_AURA_REMOVED'][25771]










local holyPowerSpenders = {
	85673,
	156322,
	427453,
	53600,
	391054,
	85222,
	415091,
	2812,
	85256,
	383328,
	215661,
	53385,
	343527,
	384052
}

local righteousProtectorTargetIDs = {
	31884,
	389539,
	86659,
	228049
}

local function HolyPowerSpenderCDR(info, _, spellID, _,_,_,_,_,_,_,_, timestamp)
	if spellID == 391054 and info.spec ~= 66 then
		return
	end
	local HP = spellID == 427453 and 5 or 3


	local talentRank = info.talentData[234299]
	if talentRank then
		if timestamp > (info.auras.time_FoJ or 0) then
			local icon = info.spellIcons[853]
			if icon and icon.active then

				P:UpdateCooldown(icon, HP * talentRank)
			end
			info.auras.time_FoJ = timestamp + 1
		end
	end

	if info.talentData[414720] and spellID ~= 2812 then

			local icon = info.spellIcons[633]
			if icon and icon.active then
				P:UpdateCooldown(icon, HP * 1.5)
			end


		return
	end

	if info.spec ~= 66 then return end
	HP = 3

	talentRank = info.talentData[385422]
	if talentRank then
		local icon = info.spellIcons[642]
		if icon and icon.active then
			P:UpdateCooldown(icon, HP/3 * talentRank)
		end
		icon = info.spellIcons[31850]
		if icon and icon.active then
			P:UpdateCooldown(icon, HP/3 * talentRank)
		end
	end
	if spellID == 427453 then return end

	if info.talentData[392928] then

			local icon = info.spellIcons[633]
			if icon and icon.active then
				P:UpdateCooldown(icon, HP)
			end


	end

	if info.talentData[204074] then

			for _, id in pairs(righteousProtectorTargetIDs) do
				local icon = info.spellIcons[id]
				if icon and icon.active then
					P:UpdateCooldown(icon, P.isPvP and 1.0 or 1.5)
				end
			end


	end
end
for _, id in pairs(holyPowerSpenders) do
	registeredEvents['SPELL_CAST_SUCCESS'][id] = HolyPowerSpenderCDR
end


registeredEvents['SPELL_DAMAGE'][31935] = function(info)
	local talentRank = info.talentData[378279]
	if talentRank then
		local icon = info.spellIcons[86659] or info.spellIcons[228049]
		if icon and icon.active then
			P:UpdateCooldown(icon, 0.5 * talentRank)
		end
	end
end


registeredEvents['SPELL_AURA_REMOVED'][432496] = function(info, srcGUID, _, destGUID)
	if srcGUID == destGUID then
		local icon = info.spellIcons[633]
		if icon and icon.active then
			P:UpdateCooldown(icon, 15)
		end
	end
end
registeredEvents['SPELL_AURA_REMOVED'][432502] = registeredEvents['SPELL_AURA_REMOVED'][432496]
registeredEvents['SPELL_AURA_REFRESH'][432496] = registeredEvents['SPELL_AURA_REMOVED'][432496]
registeredEvents['SPELL_AURA_REFRESH'][432502] = registeredEvents['SPELL_AURA_REMOVED'][432496]


registeredEvents['SPELL_AURA_REMOVED'][54149] = function(info)
	info.auras["hasInfusionOfLight"] = nil
end
registeredEvents['SPELL_AURA_APPLIED'][54149] = function(info)
	info.auras["hasInfusionOfLight"] = true
end






registeredEvents['SPELL_AURA_REMOVED'][200183] = function(info, srcGUID, spellID, destGUID)
	info.auras.isApotheosisActive = nil
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end

registeredEvents['SPELL_AURA_APPLIED'][200183] = function(info)
	info.auras.isApotheosisActive = true
end


registeredEvents['SPELL_CAST_SUCCESS'][32379] = function(info, _,_, destGUID, _,_,_,_,_,_,_, timestamp)
	if info.talentData[321291] and info.spellIcons[32379] then
		if timestamp > (info.auras.time_shadowworddeath_reset or 0) then
			local unit = UnitTokenFromGUID(destGUID)
			if unit then
				local maxHP = UnitHealthMax(unit)
				if maxHP > 0 then
					info.auras.isDeathTargetUnder20 = UnitHealth(unit) /  maxHP <= .2
				end
			end
		end
	end
end

registeredEvents['SPELL_DAMAGE'][32379] = function(info, _,_,_,_,_,_, overkill, _,_,_, timestamp)
	if info.talentData[321291] then
		if overkill == -1 and info.auras.isDeathTargetUnder20 then
			local icon = info.spellIcons[32379]
			if icon and icon.active then
				P:ResetCooldown(icon)
			end
			info.auras.time_shadowworddeath_reset = timestamp + 10
		end
		info.auras.isDeathTargetUnder20 = nil
	end
end


registeredEvents['SPELL_AURA_APPLIED'][392511] = function(info)

	--[[
	local icon = info.spellIcons[32379]
	if icon and icon.active then
		P:ResetCooldown(icon)
	end
	]]
	info.auras["deathSpeaker"] = true
end
registeredEvents['SPELL_AURA_REMOVED'][392511] = function(info)
	info.auras["deathSpeaker"] = nil
end
E.auraMultString[392511] = "deathSpeaker"


local onGSRemoval = function(srcGUID, spellID, destGUID)
	local info = groupInfo[srcGUID]
	if info then
		if info.auras.isSavedByGS then
			info.auras.isSavedByGS = nil
		else
			local icon = info.spellIcons[47788]
			if icon and info.talentData[200209] or info.talentData[63231] then
				P:StartCooldown(icon, 60)
			end
		end
		RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
	end
end

registeredEvents['SPELL_AURA_REMOVED'][47788] = function(info, srcGUID, spellID, destGUID)
	local icon = info.spellIcons[47788]
	if icon then
		C_Timer_After(0.1, function() onGSRemoval(srcGUID, spellID, destGUID) end)
	end
end

registeredEvents['SPELL_HEAL'][48153] = function(info)
	if info.spellIcons[47788] then
		info.auras.isSavedByGS = true
	end
end


registeredEvents['SPELL_AURA_REMOVED'][194249] = function(info, srcGUID, spellID, destGUID)
	if info.callbackTimers.isVoidForm then
		if srcGUID ~= userGUID then
			info.callbackTimers.isVoidForm:Cancel()
		end
		info.callbackTimers.isVoidForm = nil
	end
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end
registeredEvents['SPELL_AURA_REMOVED'][391109] = registeredEvents['SPELL_AURA_REMOVED'][194249]

local removeVoidForm
removeVoidForm = function(srcGUID, spellID, destGUID)
	local info = groupInfo[srcGUID]
	if info and info.callbackTimers.isVoidForm then
		local duration, expTime = P:GetBuffDuration(info.unit, spellID)
		if duration and duration > 0 then
			duration = expTime - GetTime()
			if duration > 0 then
				info.callbackTimers.isVoidForm = C_Timer_NewTimer(duration + 1, function() removeVoidForm(srcGUID, spellID, destGUID) end)
			end
			return
		end
		info.callbackTimers.isVoidForm = nil
		RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
	end
end
registeredEvents['SPELL_AURA_APPLIED'][194249] = function(info, srcGUID, spellID, destGUID)
	if P.isPvP and info.talentData[199259] and info.spellIcons[228260] then
		info.auras.isPvpAndDrivenToMadness = true
		info.callbackTimers.isVoidForm = srcGUID == userGUID or C_Timer_NewTimer(20.1, function() removeVoidForm(srcGUID, spellID, destGUID) end)
	else
		info.auras.isPvpAndDrivenToMadness = nil
	end
end
registeredEvents['SPELL_AURA_APPLIED'][391109] = function(info, srcGUID, spellID, destGUID)
	if P.isPvP and info.talentData[199259] and info.spellIcons[391109] then
		info.auras.isPvpAndDrivenToMadness = true
		info.callbackTimers.isVoidForm = srcGUID == userGUID or C_Timer_NewTimer(20.1, function() removeVoidForm(srcGUID, spellID, destGUID) end)
	else
		info.auras.isPvpAndDrivenToMadness = nil
	end
end

local function ReduceVoidEruptionCD(destInfo, _,_,_,_,_, timestamp, _,_, missType)
	if missType and missType ~= "ABSORB" then
		return
	end
	if destInfo.auras.isPvpAndDrivenToMadness and not destInfo.callbackTimers.isVoidForm then
		local icon = destInfo.spellIcons[228260] or destInfo.spellIcons[391109]
		if icon and icon.active then
			if timestamp > (destInfo.auras.time_driventomadness or 0) then
				P:UpdateCooldown(icon, 3)
				destInfo.auras.time_driventomadness = timestamp + 1
			end
		end
	end
end
registeredHostileEvents['SWING_DAMAGE']['PRIEST'] = ReduceVoidEruptionCD
registeredHostileEvents['RANGE_DAMAGE']['PRIEST'] = ReduceVoidEruptionCD
registeredHostileEvents['SPELL_DAMAGE']['PRIEST'] = ReduceVoidEruptionCD
registeredHostileEvents['SWING_MISSED']['PRIEST'] = function(destInfo,_,missType,_,_,_,timestamp) ReduceVoidEruptionCD(destInfo,nil,nil,nil,nil,nil,timestamp,nil,nil,missType) end
registeredHostileEvents['RANGE_MISSED']['PRIEST'] = function(destInfo,_,_,missType,_,_,timestamp) ReduceVoidEruptionCD(destInfo,nil,nil,nil,nil,nil,timestamp,nil,nil,missType) end
registeredHostileEvents['SPELL_MISSED']['PRIEST'] = registeredHostileEvents['RANGE_MISSED']['PRIEST']



registeredEvents['SPELL_AURA_APPLIED'][322431] = function(info)
	local icon = info.spellIcons[316262]
	if icon then
		local statusBar = icon.statusBar
		if icon.active then
			if statusBar then
				P.OmniCDCastingBarFrame_OnEvent(statusBar.CastingBar, 'UNIT_SPELLCAST_STOP')
			end
			icon.cooldown:Clear()
		end
		if statusBar then
			statusBar.BG:SetVertexColor(0.7, 0.7, 0.7)
		end
		info.preactiveIcons[316262] = icon
		if not icon.isHighlighted then
			icon.icon:SetVertexColor(0.4, 0.4, 0.4)
		end
	end
end

registeredEvents['SPELL_AURA_REMOVED'][322431] = function(info)
	local icon = info.spellIcons[316262]
	if icon then
		local statusBar = icon.statusBar
		if statusBar then
			P:SetExStatusBarColor(icon, statusBar.key)
		end
		info.preactiveIcons[316262] = nil
		icon.icon:SetVertexColor(1, 1, 1)
		P:StartCooldown(icon, icon.duration)
	end
end


registeredEvents['SPELL_DAMAGE'][47666] = function(info)
	local talentRank = info.talentData[421558]
	if ( talentRank ) then
		local icon = info.spellIcons[421453]
		if ( icon and icon.active ) then
			P:UpdateCooldown(icon, talentRank)
		end
	end
end


registeredEvents['SPELL_AURA_REMOVED'][372760] = function(info, srcGUID, spellID, destGUID)
	info.auras.hasDivineWord = nil
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end
registeredEvents['SPELL_AURA_APPLIED'][372760] = function(info)
	info.auras.hasDivineWord = true
end


registeredEvents['SPELL_AURA_APPLIED'][375981] = function(info)
	local icon = info.spellIcons[8092]
	if icon and icon.active then
		P:ResetCooldown(icon)
	end
end


registeredEvents['SPELL_AURA_APPLIED'][458650] = function(info)
	info.auras["saveTheDay"] = true
end
registeredEvents['SPELL_AURA_REMOVED'][458650] = function(info)
	info.auras["saveTheDay"] = nil
end
E.auraMultString[458650] = "saveTheDay"


registeredEvents['SPELL_AURA_APPLIED'][428933] = function(info)
	info.auras.premonitionOfInsight = true
end
registeredEvents['SPELL_AURA_REMOVED'][428933] = function(info, srcGUID, spellID, destGUID)
	info.auras.premonitionOfInsight = nil
	RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
end
E.auraMultString[428933] = "premonitionOfInsight"


registeredEvents['SPELL_AURA_APPLIED'][114255] = function(info)
	info.auras.surgeOfLight = true
end
registeredEvents['SPELL_AURA_REMOVED'][114255] = function(info)
	info.auras.surgeOfLight = nil
end

registeredEvents['SPELL_HEAL'][2061] = function(info, _,_,_,_,_, amount, _,_, critical, _, ts)
	if info.talentData[453828] and info.auras.surgeOfLight then
		local icon = info.spellIcons[34861]
		if icon and icon.active then
			P:UpdateCooldown(icon, 4)
		end
	end

	if info.talentData[453678] then
		local icon = info.spellIcons[2050]
		if icon and icon.active then
			amount = critical and amount / (P.isPvP and 1.5 or 2) or amount
			if ts - (info.auras.time_flashHeal or 0) < 0.3 and amount / (info.auras.lastFlashHealAmount or 0) < .5 then
				P:UpdateCooldown(icon, GetHolyWordReducedTime(info, 6 * (P.isPvP and .175 or .35)))
			end
			info.auras.time_flashHeal = ts
			info.auras.lastFlashHealAmount = amount
		end
	end
end

registeredEvents['SPELL_HEAL'][596] = function(info, srcGUID, _, destGUID, _,_, amount, _,_, critical, _, ts)
	if info.talentData[453678] and srcGUID == destGUID then
		local icon = info.spellIcons[34861]
		if icon and icon.active then
			amount = critical and amount / (P.isPvP and 1.5 or 2) or amount
			if ts - (info.auras.time_prayerHeal or 0) < 0.3 and amount / (info.auras.lastPrayerhHealAmount or 0) < .5 then
				P:UpdateCooldown(icon, GetHolyWordReducedTime(info, 6 * (P.isPvP and .175 or .35)))
			end
			info.auras.time_prayerHeal = ts
			info.auras.lastPrayerhHealAmount = amount
		end
	end
end






registeredEvents['SPELL_CAST_SUCCESS'][36554] = function(info, _, spellID, destGUID, _, destFlags)
	local icon = info.spellIcons[spellID]
	if icon and icon.active then
		if info.talentData[197899] then
			if P.isPvP and band(destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0 then
				P:UpdateCooldown(icon, icon.duration * .67)
			end
		elseif info.talentData[381630] then
			local unit = UnitTokenFromGUID(destGUID)
			if unit then
				if P:GetDebuffDuration(unit, 703) then
					P:UpdateCooldown(icon, icon.duration * .33)
				end
			end
		end
	end
end




registeredEvents['SPELL_AURA_REMOVED'][57934] = function(info, srcGUID, spellID, destGUID)
	local icon = info.spellIcons[spellID] or info.spellIcons[221622]
	if icon then
		local statusBar = icon.statusBar
		if statusBar then
			P:SetExStatusBarColor(icon, statusBar.key)
		end
		info.preactiveIcons[spellID] = nil
		icon.icon:SetVertexColor(1, 1, 1)
		RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
	end
end

local function StartTricksCD(info, srcGUID, spellID, destGUID)
	local icon = info.spellIcons[57934]
	if icon and srcGUID == destGUID then
		local statusBar = icon.statusBar
		if statusBar then
			P:SetExStatusBarColor(icon, statusBar.key)
		end
		info.preactiveIcons[57934] = nil
		icon.icon:SetVertexColor(1, 1, 1)
		RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)

		P:StartCooldown(icon, icon.duration)
	end
end
registeredEvents['SPELL_AURA_APPLIED'][59628] = StartTricksCD
registeredEvents['SPELL_AURA_APPLIED'][221630] = StartTricksCD


registeredEvents['SPELL_AURA_APPLIED'][375939] = function(info)
	info.auras.targetLastedSepsisFullDuration = true
end
registeredEvents['SPELL_AURA_REMOVED'][385408] = function(info)
	if not info.auras.targetLastedSepsisFullDuration then
		local icon = info.spellIcons[385408]
		if icon and icon.active then
			P:UpdateCooldown(icon, 30)
		end
	end
	info.auras.targetLastedSepsisFullDuration = nil
end


local outlawRestlessBladesIDs = {
	13750,
	315341,
	13877,
	271877,
	196937,
	195457,
	381989,
	51690,
	315508,
	2983,
	1856,
}

local floatLikeAButterfly = {
	5277,
	1966,
}

local subtletyDeepeningShadowsIDs = {
	185313, 0.5,
	280719, 1.0,
}

local function ConsumedComboPoints(info, _, spellID)
	local numCP
	local animacharge = info.auras.consumedAnimacharge
	local isKidnyShot = spellID == 408
	if isKidnyShot then
		numCP = 5
	elseif animacharge then
		numCP = 7
	else
		numCP = info.talentData[193531] and 6 or 5
	end
	if info.spec == 260 then
		if not isKidnyShot and not animacharge and info.talentData[394321] then
			numCP = numCP + 1
		end

		local et = 0
		if info.auras.isTrueBearing then
			et = numCP * 0.5
		end
		local rt = numCP + et
		for _, id in pairs(outlawRestlessBladesIDs) do
			local icon = info.spellIcons[id]
			if icon and icon.active then
				P:UpdateCooldown(icon, rt)
			end
		end

		if info.talentData[354897] then
			rt = P.isPvP and (numCP/2 + et) / 2 or (numCP/2 + et)
			for _, id in pairs(floatLikeAButterfly) do
				local icon = info.spellIcons[id]
				if icon and icon.active then
					P:UpdateCooldown(icon, rt)
				end
			end
		end
	else
		if not isKidnyShot and not animacharge and info.talentData[394320] then
			numCP = numCP + 1
		end
		for i = 1, 4, 2 do
			local id = subtletyDeepeningShadowsIDs[i]
			if id == 280719 or info.talentData[185314] then
				local reducedTime = subtletyDeepeningShadowsIDs[i + 1] * numCP
				local icon = info.spellIcons[id]
				if icon and icon.active and (spellID ~= 280719 or spellID ~= id) then
					P:UpdateCooldown(icon, reducedTime)
				end
			end
		end
	end
end

local comboPointSpenders = {

	2098,
	196819,
	462140,
	462241,
	315496,
	408,
	315341,
	319175,
	1943,
	280719,
	51690,
}
for _, id in pairs(comboPointSpenders) do
	if id == 196819 or id == 2098 or id == 462140 or id == 462241 then
		registeredEvents['SPELL_DAMAGE'][id] = ConsumedComboPoints
	else
		registeredEvents['SPELL_CAST_SUCCESS'][id] = ConsumedComboPoints
	end
end


local RemoveEchoingRepromand_OnDelayEnd = function(srcGUID)
	local info = groupInfo[srcGUID]
	if info then
		info.auras.consumedAnimacharge = nil
	end
end
local function RemoveEchoingRepromand(info, srcGUID)
	info.auras.consumedAnimacharge = true
	C_Timer_After(0.1, function() RemoveEchoingRepromand_OnDelayEnd(srcGUID) end)
end

registeredEvents['SPELL_AURA_REMOVED'][354838] = RemoveEchoingRepromand
registeredEvents['SPELL_AURA_REMOVED'][323560] = RemoveEchoingRepromand
registeredEvents['SPELL_AURA_REMOVED'][323559] = RemoveEchoingRepromand



registeredEvents['SPELL_AURA_REMOVED'][193359] = function(info)
	info.auras.isTrueBearing = nil
end
registeredEvents['SPELL_AURA_APPLIED'][193359] = function(info)
	info.auras.isTrueBearing = true
end


registeredEvents['SPELL_DAMAGE'][457157] = function(info)
	local icon = info.spellIcons[36554]
	if icon and icon.active then
		P:UpdateCooldown(icon, 3)
	end
end


registeredEvents['SPELL_AURA_APPLIED'][457333] = function(info)
	info.auras["deathsArrival"] = true
end
registeredEvents['SPELL_AURA_REMOVED'][457333] = function(info)
	info.auras["deathsArrival"] = nil
end
registeredEvents['SPELL_AURA_APPLIED'][457343] = function(info)
	info.auras["deathsArrival"] = true
end
registeredEvents['SPELL_AURA_REMOVED'][457343] = function(info)
	info.auras["deathsArrival"] = nil
end
E.auraMultString[457333] = "deathsArrival"
E.auraMultString[457343] = "deathsArrival"










registeredEvents['SPELL_CAST_SUCCESS'][21169] = function(info)
	local icon = info.spellIcons[20608]
	if icon then
		P:StartCooldown(icon, icon.duration)
	end
end


registeredEvents['SPELL_SUMMON'][192058] = function(info, srcGUID, spellID, destGUID)
	if info.talentData[265046] or info.talentData[445027] then
		local icon = info.spellIcons[spellID]
		if icon then
			local capGUID = info.auras.capTotemGUID
			if capGUID then
				totemGUIDS[capGUID] = nil
			end
			totemGUIDS[destGUID] = srcGUID
			info.auras.capTotemGUID = destGUID
		end
	end
end

registeredEvents['SPELL_SUMMON'][383013] = function(info, srcGUID, spellID, destGUID)
	if info.talentData[445027] then
		local icon = info.spellIcons[spellID]
		if icon then
			local poiGUID = info.auras.poisonCleansingTotemGUID
			if poiGUID then
				totemGUIDS[poiGUID] = nil
			end
			totemGUIDS[destGUID] = srcGUID
			info.auras.poisonCleansingTotemGUID = destGUID
		end
	end
end

registeredEvents['SPELL_SUMMON'][51485] = function(info, srcGUID, spellID, destGUID)
	if info.talentData[445027] then
		local icon = info.spellIcons[spellID]
		if icon then
			local earGUID = info.auras.earthgrabTotemGUID
			if earGUID then
				totemGUIDS[earGUID] = nil
			end
			totemGUIDS[destGUID] = srcGUID
			info.auras.earthgrabTotemGUID = destGUID
		end
	end
end



registeredEvents['SPELL_HEAL'][31616] = function(info)
	local icon = info.spellIcons[30884]
	if icon then
		P:StartCooldown(icon, icon.duration)
	end
end


registeredEvents['SPELL_AURA_APPLIED'][344179] = function(info)
	local icon = info.auras.feralSpiritIcon
	if icon and icon.active then
		P:UpdateCooldown(icon, 2)
	end
end
registeredEvents['SPELL_AURA_APPLIED_DOSE'][344179] = function(info, _,_,_,_,_,_, amount)
	if amount == 2 then
		local icon = info.auras.feralSpiritIcon
		if icon and icon.active then
			P:UpdateCooldown(icon, 2)
		end
	end
end
registeredEvents['SPELL_AURA_REFRESH'][344179] = registeredEvents['SPELL_AURA_APPLIED'][344179]

registeredEvents['SPELL_CAST_SUCCESS'][51533] = function(info)
	info.auras.feralSpiritIcon = info.talentData[384447] and info.spellIcons[51533]
end


registeredEvents['SPELL_PERIODIC_DAMAGE'][188389] = function(info, _,_,_, critical)
	if critical then
		if info.talentData[378310] then
			local icon = info.spellIcons[198067] or info.spellIcons[192249]
			if icon and icon.active then
				P:UpdateCooldown(icon, 1)
			end
		end
	end
end


local RemoveSurgeOfPower_OnDelayEnd = function(srcGUID)
	local info = groupInfo[srcGUID]
	if info then
		info.auras.isSurgeOfPower = nil
	end
end

registeredEvents['SPELL_AURA_REMOVED'][285514] = function(info, srcGUID)
	if info.spellIcons[198067] or info.spellIcons[192249] then
		C_Timer_After(0.1, function() RemoveSurgeOfPower_OnDelayEnd(srcGUID) end)
	end
end

registeredEvents['SPELL_AURA_APPLIED'][285514] = function(info)
	if info.spellIcons[198067] or info.spellIcons[192249] then
		info.auras.isSurgeOfPower = true
	end
end

registeredEvents['SPELL_CAST_SUCCESS'][51505] = function(info)
	if info.auras.isSurgeOfPower then
		local icon = info.spellIcons[198067] or info.spellIcons[192249]
		if icon and icon.active then
			P:UpdateCooldown(icon, 4)
		end
		info.auras.isSurgeOfPower = nil
	end
end


local elementalShamanNatureAbilities = {
	5394,
	383013,
	383017,
	383019,
	192077,
	192058,
	355580,
	204331,
	204336,
	2484,
	51485,
	8143,
	108270,
	57994,
	191634,
	51490,
	204406,
	378779,
	108271,
	2825,
	51514,
	356736,
	79206,
	378773,
	305483,
	108281,
	198103,
	192063,
	108287,
	108285,
	378081,
	443454,
	192249,
	51886,
	375982,
}
local numElementalShamanNatureAbilities = #elementalShamanNatureAbilities

local function ReduceNatureAbilityCD(info)
	if info.talentData[381936] then
		for i = 1, numElementalShamanNatureAbilities do
			local id = elementalShamanNatureAbilities[i]
			local icon = info.spellIcons[id]
			if icon and icon.active then
				P:UpdateCooldown(icon, 1)
			end
		end
	end
end
registeredEvents['SPELL_CAST_SUCCESS'][188443] = ReduceNatureAbilityCD
registeredEvents['SPELL_CAST_SUCCESS'][188196] = ReduceNatureAbilityCD
registeredEvents['SPELL_CAST_SUCCESS'][452201] = ReduceNatureAbilityCD



local shamanTotems = {
	5394,
	383013,
	383017,
	383019,
	192222,
	157153,
	198838,
	51485,
	192077,
	192058,
	355580,
	204331,
	204336,
	2484,
	8143,
	108270,
	444995,
}

local function CacheLastTotemUsed(info, _, spellID)
	if info.talentData[108285] then
		info.auras.lastTotemUsed = info.auras.lastTotemUsed or {}
		if info.auras.lastTotemUsed[1] ~= spellID then
			tinsert(info.auras.lastTotemUsed, 1, spellID)
			for i = 3, #info.auras.lastTotemUsed do
				info.auras.lastTotemUsed[i] = nil
			end
		end
	end
end

for _, id in pairs(shamanTotems) do
	registeredEvents['SPELL_CAST_SUCCESS'][id] = CacheLastTotemUsed
end

registeredEvents['SPELL_CAST_SUCCESS'][108285] = function(info)
	local lastTotemUsed = info.auras.lastTotemUsed
	if lastTotemUsed then
		for i = 1, info.talentData[383012] and 2 or 1 do
			local id = lastTotemUsed[i]
			local icon = info.spellIcons[id]
			if icon and icon.active then
				P:ResetCooldown(icon)
			end
		end
	end
end


registeredEvents['SPELL_SUMMON'][445624] = function(info)
	local icon = info.spellIcons[198067] or info.spellIcons[192249]
	if icon and icon.active then
		P:UpdateCooldown(icon, 10)
	end
end


registeredEvents['SPELL_AURA_REMOVED'][453406] = function(info)
	info.auras.whirlingEarth = nil
end
registeredEvents['SPELL_AURA_APPLIED'][453406] = function(info)
	info.auras.whirlingEarth = true
end
registeredEvents['SPELL_CAST_SUCCESS'][197214] = function(info, _, spellID)
	if info.auras.whirlingEarth then
		local icon = info.spellIcons[spellID]
		if icon and icon.active then
			P:UpdateCooldown(icon, 12)
		end
	end
end








local function ReduceUnendingResolveCD(destInfo, destName, _, amount, _,_, timestamp, spellSchool, _, missType)
	if missType and missType ~= "ABSORB" then
		return
	end

	if P.isPvP and destInfo.talentData[409835] and spellSchool and band(spellSchool,1) > 0 then
		local icon = destInfo.spellIcons[48020]
		if icon and icon.active then
			if timestamp > (destInfo.auras.time_impishinstinct or 0) then
				P:UpdateCooldown(icon, 3)
				destInfo.auras.time_impishinstinct = timestamp + 5
			end
		end
	end

	local talentRank = destInfo.talentData[389359]
	if talentRank then
		local icon = destInfo.spellIcons[104773]
		if icon and icon.active then
			if timestamp > (destInfo.auras.time_resolutebarrier or 0) then
				local maxHP = UnitHealthMax(destName)
				if maxHP > 0 and (amount / maxHP) > 0.05 then
					P:UpdateCooldown(icon, 10)
					destInfo.auras.time_resolutebarrier = timestamp + 30 - (5 * talentRank)
				end
			end
		end
	end
end
registeredHostileEvents['SWING_DAMAGE']['WARLOCK'] = function(destInfo,destName,amount,_,_,_,timestamp,school) ReduceUnendingResolveCD(destInfo,destName,nil,amount,nil,nil,timestamp,school) end
registeredHostileEvents['RANGE_DAMAGE']['WARLOCK'] = ReduceUnendingResolveCD
registeredHostileEvents['SPELL_DAMAGE']['WARLOCK'] = ReduceUnendingResolveCD

registeredHostileEvents['SWING_MISSED']['WARLOCK'] = function(destInfo,destName,missType,_,_,_,timestamp,amountMissed) ReduceUnendingResolveCD(destInfo,destName,nil,amountMissed,nil,nil,timestamp,1,nil,missType) end
registeredHostileEvents['RANGE_MISSED']['WARLOCK'] = function(destInfo,destName,_,missType,_,_,timestamp,spellSchool,amountMissed) ReduceUnendingResolveCD(destInfo,destName,nil,amountMissed,nil,nil,timestamp,spellSchool,nil,missType) end
registeredHostileEvents['SPELL_MISSED']['WARLOCK'] = registeredHostileEvents['RANGE_MISSED']['WARLOCK']


registeredEvents['SPELL_AURA_APPLIED'][457555] = function(info)
	local icon = info.spellIcons[6353]
	if icon and icon.active then
		P:ResetCooldown(icon)
	end
end







registeredEvents['SPELL_AURA_APPLIED'][32216] = function(info)
	local icon = info.spellIcons[202168]
	if icon and icon.active then
		P:ResetCooldown(icon)
		info.auras["Victorious"] = true
	end
end



local rageSpenders = {
	[184367] = { 4.0, { 1719, 228920, 227847 } },

	[280735] = { 2.0, { 1719, 228920, 227847 }, { 316402, 0 } },
	[12294] = { 1.5, { 262161, 167105, 228920, 227847 } },
	[845] = { 1.0, { 262161, 167105, 228920, 227847 }, nil, { "StormofSwords", 0 } },
	[772] = { 1.0, { 262161, 167105, 228920, 227847 }  },
	[394062] = { 2.0, { 401150, 871 } },
	[190456] = { 3.5, { 401150, 871 } },
	[6572] = { 2.0, { 401150, 871}, { 390675, 1 }, { "Revenge", 0 } },
	[6343] = { { [71]=1, [72]=1 }, { 262161, 167105, 227847, 1719, 228920 } },
	[1680] = { { [73]=2 }, { 401150, 871 } },
	[163201] = { { [73]=4, [71]=2 }, { 262161, 167105, 227847, 401150, 871 }, { 316402, 0 }, { "SuddenDeath", 0 } },
	[281000] = { { [73]=4, [71]=2 }, { 262161, 167105, 227847, 401150, 871 }, { 316402, 0 }, { "SuddenDeath", 0 } },
	[1464] = { { [73]=2, [71]=1 }, { 262161, 167105, 227847, 401150, 871, 1719, 228920 } },
	[2565] = { { [73]=3, ["d"]=1.5 }, { 262161, 167105, 227847, 401150, 871, 1719, 228920 } },
	[202168] = { { [73]=1, ["d"]=0.5 }, { 262161, 167105, 227847, 401150, 871, 1719, 228920 }, nil, { "Victorious", 0 } },
	[1715] = { { [73]=1, ["d"]=0.5 }, { 262161, 167105, 227847, 401150, 871, 1719, 228920 } },
}

for id, t in pairs(rageSpenders) do
	local duration, target, modif, aura = t[1], t[2], t[3], t[4]
	registeredEvents['SPELL_CAST_SUCCESS'][id] = function(info)
		if id == 280735 or id == 163201 or id == 281000 then
			registeredEvents['SPELL_CAST_SUCCESS'][5308](info)
		elseif id == 6343 then
			if info.talentData[385840] then
				local active = info.active[1160]
				if active then
					active.numHits = 0
				end
			end
		end

		if not info.talentData[152278] then return end

		local rCD
		if type(duration) == "table" then
			rCD = duration[info.spec] or duration.d
			if not rCD then return end
		else
			rCD = duration
		end

		if aura then
			for i = 1, #aura, 2 do
				local buff, rt = aura[i], aura[i+1]
				if info.auras[buff] then
					if rt == 0 then return end
					rCD = rCD + rt
				end
			end
		end
		if modif then
			for i = 1, #modif, 2 do
				local tal, rt = modif[i], modif[i+1]
				if info.talentData[tal] then
					if rt == 0 then return end
					rCD = rCD + rt
				end
			end
		end

		--[[if info.spec == 72 and P.isPvP then
			rCD = rCD * 1.33
		end]]

		for _, spellID in pairs(target) do
			local icon = info.spellIcons[spellID]
			if icon and icon.active and (spellID ~= 228920 or info.spec == 72) then
				P:UpdateCooldown(icon, rCD)
			end
		end
	end
end


registeredEvents['SPELL_DAMAGE'][46968] = function(info)
	if info.talentData[275339] then
		local active = info.active[46968]
		if active then
			active.numHits = (active.numHits or 0) + 1
			if active.numHits == 3 then
				local icon = info.spellIcons[46968]
				if icon and icon.active then
					P:UpdateCooldown(icon, 15)
				end
			end
		end
	end
end


registeredEvents['SPELL_DAMAGE'][6343] = function(info)
	if info.talentData[385840] then
		local active = info.active[1160]
		if active then
			active.numHits = (active.numHits or 0) + 1
			if active.numHits <= 3 then
				local icon = info.spellIcons[1160]
				if icon and icon.active then
					P:UpdateCooldown(icon, 1.5)
				end
			end
		end
	end
end
--[[
registeredEvents['SPELL_CAST_SUCCESS'][6343] = function(info)
	if info.talentData[385840] then
		local active = info.active[1160]
		if active then
			active.numHits = 0
		end
	end
end
]]


local RemoveMarkedForExecution_OnDelayEnd = function(srcGUID)
	local info = groupInfo[srcGUID]
	if info then
		info.auras.hasMarkedForExecution = nil
	end
end
registeredEvents['SPELL_AURA_REMOVED'][445584] = function(info, srcGUID)
	if info.talentData[444780] then
		C_Timer_After(0.1, function() RemoveMarkedForExecution_OnDelayEnd(srcGUID) end)
	end
end
registeredEvents['SPELL_AURA_APPLIED'][445584] = function(info)
	if info.talentData[444780] then
		info.auras.hasMarkedForExecution = 1
	end
end
registeredEvents['SPELL_AURA_APPLIED_DOSE'][445584] = function(info, _,_,_,_,_,_, overkill)
	if info.talentData[444780] then
		info.auras.hasMarkedForExecution = overkill
	end
end

registeredEvents['SPELL_CAST_SUCCESS'][5308] = function(info)
	local amount = info.auras.hasMarkedForExecution
	if amount and type(amount) == "number" and amount > 0 then
		local icon = info.spellIcons[227847]
		if icon and icon.active then
			P:UpdateCooldown(icon, amount * 5)
		end
	end
end


registeredEvents['SPELL_AURA_APPLIED_DOSE'][440989] = function(info, _,_,_,_,_,_, overkill)
	if info.talentData[429636] then
		info.auras.colossalMightStacks = overkill
	end
end
registeredEvents['SPELL_AURA_REFRESH'][440989] = function(info, _,_,_,_,_,_, overkill)
	if info.talentData[429636] and info.auras.colossalMightStacks >= 10 then
		if info.auras.colossalMightStacks == 10 then
			info.auras.colossalMightStacks = 11
		else
			local icon = info.spellIcons[436358]
			if icon and icon.active then
				P:UpdateCooldown(icon, 2)
			end
		end
	end
end




registeredEvents['SPELL_EMPOWER_INTERRUPT'][436344] = function(info, _, spellID)
	local icon = info.spellIcons[spellID]
	if icon and icon.active then
		P:ResetCooldown(icon)
	end
end















local function UpdateSpellRR(info, spellID, modRate, icon, now)
	icon = icon or info.spellIcons[spellID]
	if icon then
		local newRate = icon.modRate * modRate
		local active = icon.active and info.active[spellID]
		if active then
			now = now or GetTime()
			local elapsed = (now - active.startTime) * modRate
			local newTime = now - elapsed
			local newCd = active.duration * modRate
			icon.cooldown:SetCooldown(newTime, newCd, newRate)
			active.startTime = newTime
			active.duration = newCd
			active.modRate = newRate
			local statusBar = icon.statusBar
			if statusBar then
				P.OmniCDCastingBarFrame_OnEvent(statusBar.CastingBar, E.db.extraBars[statusBar.key].reverseFill and 'UNIT_SPELLCAST_CHANNEL_UPDATE' or 'UNIT_SPELLCAST_CAST_UPDATE')
			end
		end
		info.spellModRates[spellID] = newRate
		icon.modRate = newRate
	end
end

local function UpdateCDRR(info, modRate, excludeID, forcedIDs)
	local now = GetTime()
	for spellID, icon in pairs(info.spellIcons) do
		if icon and (icon.isBookType and spellID ~= excludeID or (forcedIDs and forcedIDs[spellID])) then
			UpdateSpellRR(info, spellID, modRate, icon, now)
		end
	end
end





local evokerRacials = {
	[368970] = true,
	[357214] = true,
	[369536] = true,
}


registeredEvents['SPELL_AURA_REMOVED'][404977] = function(info, srcGUID, spellID, destGUID)
	info = info or groupInfo[srcGUID]
	if info then
		if info.callbackTimers[spellID] then
			UpdateCDRR(info, 11, nil, evokerRacials)
			if srcGUID ~= userGUID then
				info.callbackTimers[spellID]:Cancel()
			end
			info.callbackTimers[spellID] = nil
		end
		RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
	end
end
registeredEvents['SPELL_AURA_APPLIED'][404977] = function(info, srcGUID, spellID, destGUID)

	info.callbackTimers[spellID] = srcGUID == userGUID or C_Timer_NewTimer(info.talentData[412723] and 3.05 or 2.05, function() registeredEvents['SPELL_AURA_REMOVED'][404977](nil, srcGUID, spellID, destGUID) end)
	UpdateCDRR(info, 1/11, nil, evokerRacials)
end


registeredEvents['SPELL_AURA_APPLIED'][431698] = function(info, srcGUID, spellID)
	local rr = 1/1.3
	UpdateCDRR(info, rr, nil, evokerRacials)
	info.auras.modrate_temporalburst = rr
	info.callbackTimers[spellID] = srcGUID == userGUID or C_Timer_NewTimer(30.1, function() registeredEvents['SPELL_AURA_REMOVED'][431698](nil, srcGUID, spellID) end)
end
registeredEvents['SPELL_AURA_REMOVED_DOSE'][431698] = function(info, _, spellID, _,_,_,_, amount)

	if info.auras.modrate_temporalburst then
		local rr = 1/(1 + (amount/100))
		UpdateCDRR(info, 1/info.auras.modrate_temporalburst * rr, nil, evokerRacials)
		info.auras.modrate_temporalburst = rr
	end
end
registeredEvents['SPELL_AURA_REMOVED'][431698] = function(info, srcGUID, spellID)
	info = info or groupInfo[srcGUID]
	if info and info.auras.modrate_temporalburst then
		UpdateCDRR(info, 1/info.auras.modrate_temporalburst, nil, evokerRacials)
		info.auras.modrate_temporalburst = nil
		if info.callbackTimers[spellID] then
			if srcGUID ~= userGUID then
				info.callbackTimers[spellID]:Cancel()
			end
			info.callbackTimers[spellID] = nil
		end
	end
end


registeredEvents['SPELL_AURA_REMOVED'][378441] = function(info, srcGUID, spellID, destGUID)
	info = info or groupInfo[srcGUID]
	if info then
		RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
	end
	info = groupInfo[destGUID]
	if info and info.callbackTimers[spellID] then
		if destGUID ~= userGUID then
			info.callbackTimers[spellID]:Cancel()
		end
		info.callbackTimers[spellID] = nil
		UpdateCDRR(info, .01, spellID, evokerRacials)
	end
end
registeredEvents['SPELL_AURA_APPLIED'][378441] = function(info, srcGUID, spellID, destGUID)
	info = groupInfo[destGUID]
	if info then
		info.callbackTimers[spellID] = destGUID == userGUID or C_Timer_NewTimer(4.1, function() registeredEvents['SPELL_AURA_REMOVED'][spellID](nil, srcGUID, spellID, destGUID) end)
		UpdateCDRR(info, 100, spellID, evokerRacials)
	end
end

registeredUserEvents['SPELL_AURA_REMOVED'][378441] = registeredEvents['SPELL_AURA_REMOVED'][378441]
registeredUserEvents['SPELL_AURA_APPLIED'][378441] = registeredEvents['SPELL_AURA_APPLIED'][378441]


local OnFlowStateTimerEnd
OnFlowStateTimerEnd = function(srcGUID, spellID)
	local info = groupInfo[srcGUID]
	if info and info.callbackTimers[spellID] then
		UpdateCDRR(info, info.auras.flowStateRankValue, nil, evokerRacials)
		info.auras.flowStateRankValue = nil
		info.callbackTimers[spellID] = nil
	end
end

registeredEvents['SPELL_AURA_REMOVED'][390148] = function(info, srcGUID, spellID)
	if info.callbackTimers[spellID] then
		if srcGUID ~= userGUID then
			info.callbackTimers[spellID]:Cancel()
		end
		UpdateCDRR(info, info.auras.flowStateRankValue, nil, evokerRacials)
		info.callbackTimers[spellID] = nil
		info.auras.flowStateRankValue = nil
	end
end

registeredEvents['SPELL_AURA_REFRESH'][390148] = function(info, srcGUID, spellID)
	if info.callbackTimers[spellID] and srcGUID ~= userGUID then
		info.callbackTimers[spellID]:Cancel()
		info.callbackTimers[spellID] = C_Timer_NewTimer(10.1, function() OnFlowStateTimerEnd(srcGUID, spellID) end)
	end
end

registeredEvents['SPELL_AURA_APPLIED'][390148] = function(info, srcGUID, spellID)
	if not info.auras.flowStateRankValue then
		local talentValue = info.talentData[385696] == 2 and 1.1 or 1.05
		info.auras.flowStateRankValue = talentValue
		info.callbackTimers[spellID] = srcGUID == userGUID or C_Timer_NewTimer(10.1, function() OnFlowStateTimerEnd(srcGUID, spellID) end)
		UpdateCDRR(info, 1/talentValue, nil, evokerRacials)
	end
end


registeredEvents['SPELL_AURA_REMOVED'][329042] = function(info, srcGUID, spellID, destGUID)
	info = info or groupInfo[srcGUID]
	if info then
		if info.callbackTimers[spellID] then
			UpdateCDRR(info, 5, spellID)
			if srcGUID ~= userGUID then
				info.callbackTimers[spellID]:Cancel()
			end
			info.callbackTimers[spellID] = nil
		end
		RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)
	end
end
registeredEvents['SPELL_AURA_APPLIED'][329042] = function(info, srcGUID, spellID, destGUID)

	if srcGUID == destGUID then
		info.callbackTimers[spellID] = srcGUID == userGUID or C_Timer_NewTimer(10.1, function() registeredEvents['SPELL_AURA_REMOVED'][329042](nil, srcGUID, spellID, destGUID) end)
		UpdateCDRR(info, 0.2, spellID)
	end
end


registeredEvents['SPELL_AURA_REMOVED'][388010] = function(_, srcGUID, spellID, destGUID)
	local destInfo = groupInfo[destGUID]
	if destInfo then
		if destInfo.callbackTimers[spellID] then
			if destGUID ~= userGUID then
				destInfo.callbackTimers[spellID]:Cancel()
			end
			destInfo.callbackTimers[spellID] = nil
			UpdateCDRR(destInfo, 1.3)
		end
		RemoveHighlightByCLEU(destInfo, srcGUID, spellID, destGUID)
	end
end

registeredEvents['SPELL_AURA_APPLIED'][388010] = function(_, srcGUID, spellID, destGUID)
	local destInfo = groupInfo[destGUID]
	if destInfo then
		destInfo.callbackTimers[spellID] = destGUID == userGUID or C_Timer_NewTimer(30.5, function() registeredEvents['SPELL_AURA_REMOVED'][388010](nil, srcGUID, spellID, destGUID) end)
		UpdateCDRR(destInfo, 1/1.3)
	end
end

registeredUserEvents['SPELL_AURA_REMOVED'][388010] = registeredEvents['SPELL_AURA_REMOVED'][388010]
registeredUserEvents['SPELL_AURA_APPLIED'][388010] = registeredEvents['SPELL_AURA_APPLIED'][388010]








local mageBarriers = {
	11426,
	235450,
	235313,
}

for _, id in pairs(mageBarriers) do
	registeredEvents['SPELL_AURA_REMOVED'][id] = function(info, srcGUID, spellID, destGUID)
		if info.auras.rr_mageBarrier then
			UpdateSpellRR(info, spellID, 1.3)
			info.auras.rr_mageBarrier = nil
		end
		RemoveHighlightByCLEU(info, srcGUID, spellID, destGUID)


		if info.talentData[455428] then
			local icon = info.spellIcons[spellID]
			if icon and icon.active then
				P:UpdateCooldown(icon, 4)
			end
		end
	end
	registeredEvents['SPELL_AURA_APPLIED'][id] = function(info, _, spellID)
		if info.talentData[382800] then
			UpdateSpellRR(info, spellID, 1/1.3)
			info.auras.rr_mageBarrier = true
		end
	end
end


local mwHotJSTargetIDs = {


	116849,
	116680,
}

registeredEvents['SPELL_AURA_APPLIED'][443421] = function(info)
	for _, id in pairs(mwHotJSTargetIDs) do
		UpdateSpellRR(info, id, 1/1.75)
	end
	info.auras.rr_HotJS = true
end
registeredEvents['SPELL_AURA_REMOVED'][443421] = function(info)
	if info.auras.rr_HotJS then
		for _, id in pairs(mwHotJSTargetIDs) do
			UpdateSpellRR(info, id, 1.75)
		end
		info.auras.rr_HotJS = nil
	end
end



local wwHotJSTargetIDs = {

	113656,
	392983,
	152175,
}

registeredEvents['SPELL_AURA_APPLIED'][456368] = function(info, srcGUID)
	for _, id in pairs(wwHotJSTargetIDs) do
		UpdateSpellRR(info, id, 1/1.75)
	end
	C_Timer_After(8, function()
		local info = groupInfo[srcGUID]
		if info and info.auras.rr_HotJS then
			for _, id in pairs(wwHotJSTargetIDs) do
				UpdateSpellRR(info, id, 1.75)
			end
			info.auras.rr_HotJS = nil
		end
	end)
	info.auras.rr_HotJS = true
end


local holyPowerGenerators = {







	375576,
}

registeredEvents['SPELL_AURA_REMOVED'][385126] = function(info, srcGUID, spellID, destGUID)
	if info.auras.rr_sealoforder then
		for i = 1, #holyPowerGenerators do
			local id = holyPowerGenerators[i]
			UpdateSpellRR(info, id, 1.1)
		end
		info.auras.rr_sealoforder = nil
	end
end

registeredEvents['SPELL_AURA_APPLIED'][385126] = function(info, srcGUID, spellID, destGUID)
	if info.talentData[385129] then
		for i = 1, #holyPowerGenerators do
			local id = holyPowerGenerators[i]
			UpdateSpellRR(info, id, 1/1.1)
		end
		info.auras.rr_sealoforder = true
	end
end


local symbolOfHopeIDs = {
	[71]=118038,	[72]=184364,	[73]=871,
	[65]=498,	[66]=31850,	[70]=403876,
	[253]=109304,	[254]=109304,	[255]=109304,
	[259]=185311,	[260]=185311,	[261]=185311,
	[256]=19236,	[257]=19236,	[258]=19236,
	[250]=48792,	[251]=48792,	[252]=48792,
	[262]=108271,	[263]=108271,	[264]=108271,
	[62]=55342,	[63]=55342,	[64]=55342,
	[265]=104773,	[266]=104773,	[267]=104773,
	[268]=115203,	[269]=115203,	[270]=115203,
	[102]=22812,	[103]=22812,	[104]=22812,	[105]=22812,
	[577]=198589,	[581]=204021,
	[1467]=363916,	[1468]=363916,	[1473]=363916,
}

registeredEvents['SPELL_AURA_REMOVED'][265144] = function(_,_,_, destGUID)
	local destInfo = groupInfo[destGUID]
	if destInfo then
		local id = symbolOfHopeIDs[destInfo.spec]
		if id then
			local rr = destInfo.auras.rr_symbolofhope
			if rr then
				UpdateSpellRR(destInfo, id, 1/rr)
				destInfo.auras.rr_symbolofhope = nil
			end
		end
	end
end
registeredEvents['SPELL_AURA_APPLIED'][265144] = function(info, _,_, destGUID)
	local destInfo = groupInfo[destGUID]
	if destInfo then
		local id = symbolOfHopeIDs[destInfo.spec]
		if id then

			local _,_,_, startTimeMS, endTimeMS = UnitChannelInfo(info and info.unit or "player")
			if startTimeMS and endTimeMS then
				local channelTime = (endTimeMS - startTimeMS) / 1000
				local rr = 1 / ((30 + channelTime) / channelTime)
				UpdateSpellRR(destInfo, id, rr)
				destInfo.auras.rr_symbolofhope = rr
			end
		end
	end
end

registeredUserEvents['SPELL_AURA_REMOVED'][265144] = registeredEvents['SPELL_AURA_REMOVED'][265144]
registeredUserEvents['SPELL_AURA_APPLIED'][265144] = registeredEvents['SPELL_AURA_APPLIED'][265144]


registeredEvents['SPELL_AURA_REMOVED'][381684] = function(info)
	if info.auras.rr_brimmingwithlife then
		UpdateSpellRR(info, 20608, 1.75)
	end
end
registeredEvents['SPELL_AURA_APPLIED'][381684] = function(info)
	local icon = info.spellIcons[20608]
	if icon then
		UpdateSpellRR(info, 20608, 1/1.75)
		info.auras.rr_brimmingwithlife = true
	end
end







registeredEvents['SPELL_HEAL'][214200] = function(info, _,_,_,_,_,_,_,_,_,_, timestamp)
	local icon = info.spellIcons[214198]
	if icon then
		if timestamp > (info.auras.time_expellight or 0) then
			P:StartCooldown(icon, icon.duration)
			info.auras.time_expellight = timestamp + 10
		end
	end
end


registeredEvents['SPELL_DAMAGE'][443124] = function(info, _,_,_,_, destFlags, _, overkill)
	if ( overkill > -1 ) then
		local icon = info.spellIcons[443124]
		if ( icon and icon.active ) then
			P:UpdateCooldown(icon, 60)
		end
	end
end


registeredEvents['SPELL_AURA_APPLIED'][450157] = function(info, _,_,_,_,_,_,_,_,_,_, timestamp)
	if ( info.spellIcons[443556] ) then
		info.auras.time_twinFang = timestamp
	end
end
registeredEvents['SPELL_AURA_REMOVED'][450157] = function(info)
	info.auras.twinFang = nil
end


registeredEvents['SPELL_CAST_SUCCESS'][443556] = function(info, _,_,_,_,_,_,_,_,_,_, timestamp)
	if ( info.auras.time_twinFang ) then
		local icon = info.spellIcons[443556]
		if ( icon ) then
			info.auras.twinFang = true
			C_Timer_After(0, function()
				if ( not info.auras.twinFang ) then
					P:StartCooldown(icon, icon.duration)
					P:UpdateCooldown(icon, timestamp - info.auras.time_twinFang)
				end
			end)
		end
	end
end


registeredEvents['SPELL_AURA_APPLIED'][113942] = function(info, srcGUID, spellID)
	local icon = info.spellIcons[spellID]
	if not icon and P.spell_enabled[spellID] then
		info.sessionItemData[0] = true
		P:UpdateUnitBar(srcGUID)
		icon = info.spellIcons[spellID]
	end
	if icon then
		if AuraUtil_ForEachAura then
			AuraUtil_ForEachAura(info.unit, "HARMFUL", nil, function(_,_,_,_, duration, _,_,_,_, id)
				if id == spellID then
					if duration > 0 then
						icon.duration = duration
					end
					P:StartCooldown(icon, icon.duration)
					return true
				end
			end)
		else
			for i = 1, 50 do
				local _,_,_,_, duration, _,_,_,_, id = UnitDebuff(info.unit, i)
				if not id then return end
				if id == spellID then
					if duration > 0 then
						icon.duration = duration
					end
					P:StartCooldown(icon, icon.duration)
					break
				end
			end
		end
	end
end


local consumables = {
	323436,
	6262,

}
E.consumableIDs = {}
for _, v in pairs(consumables) do
	E.consumableIDs[v] = 3
end

local startCdOutOfCombat = function(guid)
	local info = groupInfo[guid]
	if not info or UnitAffectingCombat(info.unit) then
		return
	end
	for i = 1, #consumables do
		local spellID = consumables[i]
		local icon = info.preactiveIcons[spellID]
		if icon then
			local statusBar = icon.statusBar
			if statusBar then
				P:SetExStatusBarColor(icon, statusBar.key)
			end
			info.preactiveIcons[spellID] = nil
			icon.icon:SetVertexColor(1, 1, 1)

			P:StartCooldown(icon, icon.duration)

			ForceUpdatePeriodicSync(spellID)
		end
	end

	if info.callbackTimers.inCombatTicker then
		info.callbackTimers.inCombatTicker:Cancel()
		info.callbackTimers.inCombatTicker = nil
	end
end

local function StartConsumablesCD(info, srcGUID, spellID)
	local icon = info.spellIcons[spellID]

	if not icon and spellID == 6262 and P.spell_enabled[spellID] then
		info.sessionItemData[5512] = true
		P:UpdateUnitBar(srcGUID)
		icon = info.spellIcons[spellID]
	end
	if icon then

		if spellID == 323436 or spellID == 6262 then
			local stacks = icon.count:GetText()
			stacks = tonumber(stacks)
			stacks = (stacks and stacks > 0 and stacks or 3) - 1
			icon.count:SetText(stacks)
			if spellID == 6262 then
				info.auras.healthStoneStacks = stacks
			else
				info.auras.purifySoulStacks = stacks
			end
		end

		if info.callbackTimers.inCombatTicker then
			info.callbackTimers.inCombatTicker:Cancel()
			info.callbackTimers.inCombatTicker = nil
		end
		if UnitAffectingCombat(info.unit) then
			local statusBar = icon.statusBar
			if icon.active then
				if statusBar then
					P.OmniCDCastingBarFrame_OnEvent(statusBar.CastingBar, 'UNIT_SPELLCAST_STOP')
				end
				icon.cooldown:Clear()
			end
			if not info.preactiveIcons[spellID] then
				if statusBar then
					statusBar.BG:SetVertexColor(0.7, 0.7, 0.7)
				end
				info.preactiveIcons[spellID] = icon
				icon.icon:SetVertexColor(0.4, 0.4, 0.4)
			end
			info.callbackTimers.inCombatTicker = C_Timer_NewTicker(1, function() startCdOutOfCombat(icon.guid) end, 900)
		else
			info.preactiveIcons[spellID] = nil
			icon.icon:SetVertexColor(1, 1, 1)
			P:StartCooldown(icon, icon.duration)
		end
	end

	if spellID == 6262 and srcGUID == userGUID then
		ForceUpdatePeriodicSync(spellID)
	end
end

for i = 1, #consumables do
	local spellID = consumables[i]
	if spellID == 323436 then
		registeredEvents['SPELL_HEAL'][spellID] = function(info, srcGUID)
			if not info.auras.ignorePurifySoul then
				info.auras.ignorePurifySoul = true
				C_Timer_After(0.1, function() info.auras.ignorePurifySoul = false end)
				StartConsumablesCD(info, srcGUID, spellID)
			end
		end
		registeredEvents['SPELL_CAST_SUCCESS'][spellID] = registeredEvents['SPELL_HEAL'][spellID]
	else
		registeredEvents['SPELL_CAST_SUCCESS'][spellID] = StartConsumablesCD
	end
end






if ( E.isCata ) then

	registeredEvents['SPELL_DAMAGE'][78674] = function(info)
		if info.talentData[62971] then
			local icon = info.spellIcons[48505]
			if icon and icon.active then
				P:UpdateCooldown(icon, 5)
			end
		end
	end


	registeredEvents['SPELL_CAST_SUCCESS'][5185] = function(info)
		if info.talentData[54825] then
			local icon = info.spellIcons[17116]
			if icon and icon.active then
				P:UpdateCooldown(icon, 10)
			end
		end
	end


	registeredEvents['SPELL_CAST_SUCCESS'][2060] = function(info)
		if info.talentData[92297] then
			local icon = info.spellIcons[89485]
			if icon and icon.active then
				P:UpdateCooldown(icon, 5)
			end
		end
	end
	registeredEvents['SPELL_CAST_SUCCESS'][585] = function(info)
		if info.talentData[92297] then
			local icon = info.spellIcons[47540]
			if icon and icon.active then
				P:UpdateCooldown(icon, 0.5)
			end
		end
	end


	registeredEvents['SPELL_PERIODIC_DAMAGE'][15407] = function(info, _,_,_, critical)
		if critical then
			local rt = info.talentData[87099] and 5 or (info.talentData[87100] and 10)
			if rt then
				local icon = info.spellIcons[34433]
				if icon and icon.active then
					P:UpdateCooldown(icon, rt)
				end
			end
		end
	end


	registeredEvents['SPELL_INTERRUPT'][1766] = function(info, _, spellID, _,_,_, extraSpellId, extraSpellName, _,_, destRaidFlags)
		if info.talentData[56805] then
			local icon = info.spellIcons[spellID]
			if icon and icon.active then
				P:UpdateCooldown(icon, 6)
			end
		end
		AppendInterruptExtras(info, nil, spellID, nil,nil,nil, extraSpellId, extraSpellName, nil,nil, destRaidFlags)
	end
	local arenaUnits = { "arena1", "arena2", "arena3", "arena4", "arena5", "target" }
	registeredEvents['SPELL_CAST_SUCCESS'][1766] = function(info, _, spellID, destGUID)
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
							P:UpdateCooldown(icon, 6)
						end
					end
				end
			end
		end
	end


	registeredEvents['SPELL_CAST_SUCCESS'][403] = function(info)
		local icon = info.spellIcons[16166]
		if icon and icon.active then
			local rt = info.talentData[86183] and 1 or (info.talentData[86184] and 2) or (info.talentData[86185] and 3)
			if rt then
				P:UpdateCooldown(icon, rt)
			end
		end
	end
	registeredEvents['SPELL_CAST_SUCCESS'][421] = function(info)
		local icon = info.spellIcons[16166]
		if icon and icon.active then
			local rt = info.talentData[86183] and 1 or (info.talentData[86184] and 2) or (info.talentData[86185] and 3)
			if rt then
				P:UpdateCooldown(icon, rt)
			end
		end
	end
end

setmetatable(registeredEvents, nil)
setmetatable(registeredUserEvents, nil)
setmetatable(registeredHostileEvents, nil)

function P:SetDisabledColorScheme(destInfo)
	if not destInfo.isDisabledColor then
		destInfo.isDisabledColor = true
		for id, icon in pairs(destInfo.spellIcons) do
			local statusBar = icon.statusBar
			if statusBar then
				if icon.active then
					local castingBar = statusBar.CastingBar
					castingBar:SetStatusBarColor(0.3, 0.3, 0.3)
					castingBar.BG:SetVertexColor(0.3, 0.3, 0.3)
					castingBar.Text:SetVertexColor(0.3, 0.3, 0.3)
				end
				statusBar.BG:SetVertexColor(0.3, 0.3, 0.3)
				statusBar.Text:SetTextColor(0.3, 0.3, 0.3)
			end
			icon.icon:SetDesaturated(true)
			icon.icon:SetVertexColor(0.3, 0.3, 0.3)
			if icon.glowBorder then
				icon.Glow:Hide()
			end

			if ( E.summonedBuffDuration[id] and destInfo.glowIcons[id] ) then
				self:RemoveHighlight(icon)
			end
		end
		for key, frame in pairs(self.extraBars) do
			if frame.shouldRearrangeInterrupts then
				P:SetExIconLayout(key, true)
			end
		end
	end
end

local function UpdateDeadStatus(destInfo)
	if E.preMoP and UnitHealth(destInfo.unit) > 1 then
		return
	end
	destInfo.isDead = true
	destInfo.isDeadOrOffline = true
	P:SetDisabledColorScheme(destInfo)
	destInfo.bar:RegisterUnitEvent('UNIT_HEALTH', destInfo.unit)
end

if E.isClassic then
	local spellNameToID = E.spellNameToID
	local spell_enabled = P.spell_enabled
	local spell_modifiers = E.spell_modifiers

	function CD:COMBAT_LOG_EVENT_UNFILTERED()
		local _, event, _, srcGUID, _, srcFlags, _, destGUID, destName, destFlags, _,_, spellName, _, amount, overkill, _, resisted, _,_, critical = CombatLogGetCurrentEventInfo()

		if band(srcFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) == 0 then
			local destInfo = groupInfo[destGUID]
			if destInfo and event == 'UNIT_DIED' then
				UpdateDeadStatus(destInfo)
			end
			return
		end


		local spellID = spellNameToID[spellName]
		if not spellID then
			return
		end

		srcGUID = petGUIDS[srcGUID] or srcGUID
		local info = groupInfo[srcGUID]
		if not info then
			return
		end

		if spellID == 17116 or spellID == 16188 then
			spellID = info.class == "DRUID" and 17116 or 16188
		end

		if event == 'SPELL_CAST_SUCCESS' then
			if spell_enabled[spellID] or spell_modifiers[spellID] then
				ProcessSpell(spellID, srcGUID)
			end
		end

		local func = registeredEvents[event] and registeredEvents[event][spellID]
		if func then
			func(info, srcGUID, spellID, destGUID, critical, destFlags, amount, overkill, destName, resisted)
		end
	end
elseif E.preMoP then
	function CD:COMBAT_LOG_EVENT_UNFILTERED()
		local _, event, _, srcGUID, _, srcFlags, _, destGUID, destName, destFlags, _, spellID, _,_, amount, overkill, _, resisted, _,_, critical = CombatLogGetCurrentEventInfo()

		if band(srcFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) == 0 then
			local destInfo = groupInfo[destGUID]
			if destInfo and event == 'UNIT_DIED' then
				UpdateDeadStatus(destInfo)
			end
			return
		end

		if band(srcFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			if band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 and isUserDisabled then
				local func = registeredUserEvents[event] and registeredUserEvents[event][spellID]
				if func and destGUID ~= userGUID then
					func(nil, srcGUID, spellID, destGUID)
				end
				return
			end

			local info = groupInfo[srcGUID]
			if not info then
				return
			end

			local func = registeredEvents[event] and registeredEvents[event][spellID]
			if func then
				func(info, srcGUID, spellID, destGUID, critical, destFlags, amount, overkill, destName, resisted, destRaidFlags)
			end
		end
	end
else



	function CD:COMBAT_LOG_EVENT_UNFILTERED()
		local timestamp, event, _, srcGUID, _, srcFlags, _, destGUID, destName, destFlags, destRaidFlags, spellID, _, spellSchool, amount, overkill, school, resisted, _,_, critical = CombatLogGetCurrentEventInfo()


		local info = groupInfo[srcGUID]
		if info then
			if srcGUID == userGUID and isUserDisabled then
				local func = registeredUserEvents[event] and registeredUserEvents[event][spellID]
				if func and destGUID ~= userGUID then
					func(nil, srcGUID, spellID, destGUID, critical, destFlags, amount, overkill, destName, resisted, destRaidFlags, timestamp)
				end
			else
				local func = registeredEvents[event] and (registeredEvents[event][spellID] or registeredEvents[event][info.class])
				if func then
					func(info, srcGUID, spellID, destGUID, critical, destFlags, amount, overkill, destName, resisted, destRaidFlags, timestamp, school)
				end









			end
			return
		end


		local ownerGUID = totemGUIDS[srcGUID]
		info = groupInfo[ownerGUID]
		if info then
			if event == 'SPELL_AURA_APPLIED' then

				if spellID == 118905 then
					local icon = info.spellIcons[192058]
					local active = icon and icon.active and info.active[192058]
					if active then
						if info.talentData[265046] then
							active.numHits = (active.numHits or 0) + 1
							if active.numHits > 4 then
								return
							end
							P:UpdateCooldown(icon, 5)
						end

						if info.talentData[445027] and timestamp > (info.auras.time_capTotem or 0) then
							P:UpdateCooldown(icon, 5)
							info.auras.time_capTotem = timestamp + 20
						end
					end

				elseif spellID == 64695 then
					local icon = info.spellIcons[51485]
					if icon and icon.active then
						if timestamp > (info.auras.time_earthgrabTotem or 0) then
							P:UpdateCooldown(icon, 5)
							info.auras.time_earthgrabTotem = timestamp + 20
						end
					end
				end
			elseif event == 'SPELL_DISPEL' then

				if spellID == 383015 then
					local icon = info.spellIcons[383013]
					if icon and icon.active then
						if timestamp > (info.auras.time_poisonCleansingTotem or 0) then
							P:UpdateCooldown(icon, 5)
							info.auras.time_poisonCleansingTotem = timestamp + 20
						end
					end
				end
			end
			return
		end


		ownerGUID = petGUIDS[srcGUID]
		info = groupInfo[ownerGUID]
		if info then
			if event == 'SPELL_INTERRUPT' then
				AppendInterruptExtras(info, nil, spellID, nil,nil,nil, amount, overkill, nil,nil, destRaidFlags)
			end
			return
		end


		if band(srcFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) == 0 then
			info = groupInfo[destGUID]
			if info then
				local func = registeredHostileEvents[event] and (registeredHostileEvents[event][spellID] or registeredHostileEvents[event][info.class])
				if func then
					func(info, destName, spellID, amount, overkill, destGUID, timestamp, spellSchool, school)
				elseif event == 'UNIT_DIED' then
					UpdateDeadStatus(info)
				end
			elseif event == 'UNIT_DIED' then

				if destGUID == userGUID then
					E.Libs.CBH:Fire("OnDisabledUserDied")
					return
				end

				local watched = diedHostileGUIDS[destGUID]
				if watched then
					for guid, t in pairs(watched) do
						local info = groupInfo[guid]
						if info then
							for id in pairs(t) do
								local icon = info.spellIcons[id]
								if icon and icon.active then

									if id == 370965 or id == 430703 then
										P:UpdateCooldown(icon, 12)
									else
										P:ResetCooldown(icon)
									end
								end
							end
						end
					end
					diedHostileGUIDS[destGUID] = nil
				end
			end
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
	if info and (info.class == "WARLOCK" or info.spec == 252) then
		local petGUID = info.petGUID
		if petGUID then
			petGUIDS[petGUID] = nil
		end
		petGUID = UnitGUID(unitPet)
		if petGUID then
			info.petGUID = petGUID
			petGUIDS[petGUID] = guid
		end
	end
end

E.ProcessSpell = ProcessSpell
CD.totemGUIDS = totemGUIDS
CD.petGUIDS = petGUIDS
CD.diedHostileGUIDS = diedHostileGUIDS
CD.dispelledHostileGUIDS = dispelledHostileGUIDS
