local GlobalAddonName, ExRT = ...

-- RELOAD UI short command
SLASH_RELOADUI1 = "/rl"
SlashCmdList["RELOADUI"] = ReloadUI

if ExRT.isClassic then
	if not SpecializationSpecName then
		CreateFrame("Frame"):CreateFontString("SpecializationSpecName")
	end
end

if C_Spell and C_Spell.GetSpellInfo then	--11.0
	ExRT.F.GetSpellInfo = function(spellID)
		if not spellID then
			return nil;
		end

		local spellInfo = C_Spell.GetSpellInfo(spellID)
		if spellInfo then
			return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID
		end
	end

	ExRT.F.GetSpellCooldown = function(spellID)
		local spellCooldownInfo = C_Spell.GetSpellCooldown(spellID)
		if spellCooldownInfo then
			return spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.isEnabled, spellCooldownInfo.modRate
		end
	end

	local null_table_charges = {currentCharges = 0, maxCharges = 0, cooldownStartTime = 0, cooldownDuration = 0, chargeModRate = 0}
	ExRT.F.GetSpellCharges = function(spellID)
		local chargeInfo = C_Spell.GetSpellCharges(spellID) or null_table_charges
		return chargeInfo.currentCharges, chargeInfo.maxCharges, chargeInfo.cooldownStartTime, chargeInfo.cooldownDuration
	end
end