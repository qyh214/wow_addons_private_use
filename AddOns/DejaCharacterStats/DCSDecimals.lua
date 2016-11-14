local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

-- Decimal Check

local function get_gcd(haste)
	--TODO checks for cases when cooldown is not according to formula
	--print("INT",LE_UNIT_STAT_INTELLECT)
	--print("STR",LE_UNIT_STAT_STRENGTH)
	--print("AGI",LE_UNIT_STAT_AGILITY)
	--print(primary)
	local spec = GetSpecialization();
	local primaryStat = select(7, GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player")));
	local fn = "";
	if (primaryStat == LE_UNIT_STAT_INTELLECT) then
		fn = format("; Global CD %.2fs", 1.5/(1+haste/100))
	end
	return fn
end

local function DCS_DecimalsShow(self)
	-- Crit Chance
		function PaperDollFrame_SetCritChance(statFrame, unit)
			if ( unit ~= "player" ) then
				statFrame:Hide();
				return;
			end

			local rating;
			local spellCrit, rangedCrit, meleeCrit;
			local critChance;

			-- Start at 2 to skip physical damage
			local holySchool = 2;
			local minCrit = GetSpellCritChance(holySchool);
			statFrame.spellCrit = {};
			statFrame.spellCrit[holySchool] = minCrit;
			local spellCrit;
			for i=(holySchool+1), MAX_SPELL_SCHOOLS do
				spellCrit = GetSpellCritChance(i);
				minCrit = min(minCrit, spellCrit);
				statFrame.spellCrit[i] = spellCrit;
			end
			spellCrit = minCrit
			rangedCrit = GetRangedCritChance();
			meleeCrit = GetCritChance();

			if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
				critChance = spellCrit;
				rating = CR_CRIT_SPELL;
			elseif (rangedCrit >= meleeCrit) then
				critChance = rangedCrit;
				rating = CR_CRIT_RANGED;
			else
				critChance = meleeCrit;
				rating = CR_CRIT_MELEE;
			end
		-- PaperDollFrame_SetLabelAndText Format Change
			PaperDollFrame_SetLabelAndText(statFrame, STAT_CRITICAL_STRIKE, format("%.2f%%", critChance), false, critChance);

			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_CRITICAL_STRIKE).." "..format("%.2f%%", critChance)..FONT_COLOR_CODE_CLOSE;
			local extraCritChance = GetCombatRatingBonus(rating);
			local extraCritRating = GetCombatRating(rating);
			if (GetCritChanceProvidesParryEffect()) then
				statFrame.tooltip2 = format(CR_CRIT_PARRY_RATING_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance, GetCombatRatingBonusForCombatRatingValue(CR_PARRY, extraCritRating));
			else
				statFrame.tooltip2 = format(CR_CRIT_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance);
			end
			statFrame:Show();
		end

	-- Haste Chance
		function PaperDollFrame_SetHaste(statFrame, unit)
			if ( unit ~= "player" ) then
				statFrame:Hide();
				return;
			end

			local haste = GetHaste();
			local rating = CR_HASTE_MELEE;

			local hasteFormatString;
			if (haste < 0) then
				hasteFormatString = RED_FONT_COLOR_CODE.."%s"..FONT_COLOR_CODE_CLOSE;
			else
				hasteFormatString = "+%s";
			end
		-- PaperDollFrame_SetLabelAndText Format Change
			PaperDollFrame_SetLabelAndText(statFrame, STAT_HASTE, format(hasteFormatString, format("%.2f%%", haste)), false, haste);

			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HASTE) .. " " .. format(hasteFormatString, format("%.2f%%", haste)) .. get_gcd(haste) .. FONT_COLOR_CODE_CLOSE;

			local _, class = UnitClass(unit);
			statFrame.tooltip2 = _G["STAT_HASTE_"..class.."_TOOLTIP"];
			if (not statFrame.tooltip2) then
				statFrame.tooltip2 = STAT_HASTE_TOOLTIP;
			end
			statFrame.tooltip2 = statFrame.tooltip2 .. format(STAT_HASTE_BASE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(rating)), GetCombatRatingBonus(rating));

			statFrame:Show();
		end

	-- Versatility
		function PaperDollFrame_SetVersatility(statFrame, unit)
			if ( unit ~= "player" ) then
				statFrame:Hide();
				return;
			end

			local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
			local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE);
			local versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN);
		-- PaperDollFrame_SetLabelAndText Format Change
			PaperDollFrame_SetLabelAndText(statFrame, STAT_VERSATILITY, format("%.2f%%", versatilityDamageBonus) .. " / " .. format("%.2f%%", versatilityDamageTakenReduction), false, versatilityDamageBonus);

			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(VERSATILITY_TOOLTIP_FORMAT, STAT_VERSATILITY, versatilityDamageBonus, versatilityDamageTakenReduction) .. FONT_COLOR_CODE_CLOSE;
			statFrame.tooltip2 = format(CR_VERSATILITY_TOOLTIP, versatilityDamageBonus, versatilityDamageTakenReduction, BreakUpLargeNumbers(versatility), versatilityDamageBonus, versatilityDamageTakenReduction);

			statFrame:Show();
		end

	-- Mastery
		function PaperDollFrame_SetMastery(statFrame, unit)
			if ( unit ~= "player" ) then
				statFrame:Hide();
				return;
			end
			if (UnitLevel("player") < SHOW_MASTERY_LEVEL) then
				statFrame:Hide();
				return;
			end

			local mastery = GetMasteryEffect();
		-- PaperDollFrame_SetLabelAndText Format Change
			PaperDollFrame_SetLabelAndText(statFrame, STAT_MASTERY, format("%.2f%%", mastery), false, mastery);
			statFrame.onEnterFunc = Mastery_OnEnter;
			statFrame:Show();
		end

	-- Leech (Lifesteal)
		function PaperDollFrame_SetLifesteal(statFrame, unit)
			if ( unit ~= "player" ) then
				statFrame:Hide();
				return;
			end

			local lifesteal = GetLifesteal();
		-- PaperDollFrame_SetLabelAndText Format Change
			PaperDollFrame_SetLabelAndText(statFrame, STAT_LIFESTEAL, format("%.2f%%", lifesteal), false, lifesteal);
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_LIFESTEAL) .. " " .. format("%.2f%%", lifesteal) .. FONT_COLOR_CODE_CLOSE;

			statFrame.tooltip2 = format(CR_LIFESTEAL_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_LIFESTEAL)), GetCombatRatingBonus(CR_LIFESTEAL));

			statFrame:Show();
		end

	-- Avoidance
		function PaperDollFrame_SetAvoidance(statFrame, unit)
			if ( unit ~= "player" ) then
				statFrame:Hide();
				return;
			end

			local avoidance = GetAvoidance();
		-- PaperDollFrame_SetLabelAndText Format Change
			PaperDollFrame_SetLabelAndText(statFrame, STAT_AVOIDANCE, format("%.2f%%", avoidance), false, avoidance);
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVOIDANCE) .. " " .. format("%.2f%%", avoidance) .. FONT_COLOR_CODE_CLOSE;

			statFrame.tooltip2 = format(CR_AVOIDANCE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_AVOIDANCE)), GetCombatRatingBonus(CR_AVOIDANCE));

			statFrame:Show();
		end

	-- Dodge Chance
		function PaperDollFrame_SetDodge(statFrame, unit)
			if (unit ~= "player") then
				statFrame:Hide();
				return;
			end

			local chance = GetDodgeChance();
		-- PaperDollFrame_SetLabelAndText Format Change
			PaperDollFrame_SetLabelAndText(statFrame, STAT_DODGE, format("%.2f%%", chance), false, chance);
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, DODGE_CHANCE).." "..string.format("%.2f", chance).."%"..FONT_COLOR_CODE_CLOSE;
			statFrame.tooltip2 = format(CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE));
			statFrame:Show();
		end

	-- Parry Chance
		function PaperDollFrame_SetParry(statFrame, unit)
			if (unit ~= "player") then
				statFrame:Hide();
				return;
			end

			local chance = GetParryChance();
		-- PaperDollFrame_SetLabelAndText Format Change
			PaperDollFrame_SetLabelAndText(statFrame, STAT_PARRY, format("%.2f%%", chance), false, chance);
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, PARRY_CHANCE).." "..string.format("%.2f", chance).."%"..FONT_COLOR_CODE_CLOSE;
			statFrame.tooltip2 = format(CR_PARRY_TOOLTIP, GetCombatRating(CR_PARRY), GetCombatRatingBonus(CR_PARRY));
			statFrame:Show();
		end

	-- Block Chance
		function PaperDollFrame_SetBlock(statFrame, unit)
			if (unit ~= "player") then
				statFrame:Hide();
				return;
			end

			local chance = GetBlockChance();
		-- PaperDollFrame_SetLabelAndText Format Change
			PaperDollFrame_SetLabelAndText(statFrame, STAT_BLOCK, format("%.2f%%", chance), false, chance);
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, BLOCK_CHANCE).." "..string.format("%.2f", chance).."%"..FONT_COLOR_CODE_CLOSE;
			statFrame.tooltip2 = format(CR_BLOCK_TOOLTIP, GetShieldBlock());
			statFrame:Show();
		end
		PaperDollFrame_UpdateStats()
end
	
local function DCS_DecimalsHide(self)
	function PaperDollFrame_SetCritChance(statFrame, unit)
		if ( unit ~= "player" ) then
			statFrame:Hide();
			return;
		end

		local rating;
		local spellCrit, rangedCrit, meleeCrit;
		local critChance;

		-- Start at 2 to skip physical damage
		local holySchool = 2;
		local minCrit = GetSpellCritChance(holySchool);
		statFrame.spellCrit = {};
		statFrame.spellCrit[holySchool] = minCrit;
		local spellCrit;
		for i=(holySchool+1), MAX_SPELL_SCHOOLS do
			spellCrit = GetSpellCritChance(i);
			minCrit = min(minCrit, spellCrit);
			statFrame.spellCrit[i] = spellCrit;
		end
		spellCrit = minCrit
		rangedCrit = GetRangedCritChance();
		meleeCrit = GetCritChance();

		if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
			critChance = spellCrit;
			rating = CR_CRIT_SPELL;
		elseif (rangedCrit >= meleeCrit) then
			critChance = rangedCrit;
			rating = CR_CRIT_RANGED;
		else
			critChance = meleeCrit;
			rating = CR_CRIT_MELEE;
		end

		PaperDollFrame_SetLabelAndText(statFrame, STAT_CRITICAL_STRIKE, critChance, true, critChance);

		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_CRITICAL_STRIKE).." "..format("%.2f%%", critChance)..FONT_COLOR_CODE_CLOSE;
		local extraCritChance = GetCombatRatingBonus(rating);
		local extraCritRating = GetCombatRating(rating);
		if (GetCritChanceProvidesParryEffect()) then
			statFrame.tooltip2 = format(CR_CRIT_PARRY_RATING_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance, GetCombatRatingBonusForCombatRatingValue(CR_PARRY, extraCritRating));
		else
			statFrame.tooltip2 = format(CR_CRIT_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance);
		end
		statFrame:Show();
	end

	function PaperDollFrame_SetHaste(statFrame, unit)
		if ( unit ~= "player" ) then
			statFrame:Hide();
			return;
		end

		local haste = GetHaste();
		local rating = CR_HASTE_MELEE;

		local hasteFormatString;
		if (haste < 0) then
			hasteFormatString = RED_FONT_COLOR_CODE.."%s"..FONT_COLOR_CODE_CLOSE;
		else
			hasteFormatString = "+%s";
		end

		PaperDollFrame_SetLabelAndText(statFrame, STAT_HASTE, format(hasteFormatString, format("%d%%", haste + 0.5)), false, haste);

		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HASTE) .. " " .. format(hasteFormatString, format("%.2f%%", haste)) .. get_gcd(haste).. FONT_COLOR_CODE_CLOSE;

		local _, class = UnitClass(unit);
		statFrame.tooltip2 = _G["STAT_HASTE_"..class.."_TOOLTIP"];
		if (not statFrame.tooltip2) then
			statFrame.tooltip2 = STAT_HASTE_TOOLTIP;
		end
		statFrame.tooltip2 = statFrame.tooltip2 .. format(STAT_HASTE_BASE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(rating)), GetCombatRatingBonus(rating));

		statFrame:Show();
	end

	function PaperDollFrame_SetVersatility(statFrame, unit)
		if ( unit ~= "player" ) then
			statFrame:Hide();
			return;
		end

		local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
		local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE);
		local versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN);
		PaperDollFrame_SetLabelAndText(statFrame, STAT_VERSATILITY, versatilityDamageBonus, true, versatilityDamageBonus);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(VERSATILITY_TOOLTIP_FORMAT, STAT_VERSATILITY, versatilityDamageBonus, versatilityDamageTakenReduction) .. FONT_COLOR_CODE_CLOSE;

		statFrame.tooltip2 = format(CR_VERSATILITY_TOOLTIP, versatilityDamageBonus, versatilityDamageTakenReduction, BreakUpLargeNumbers(versatility), versatilityDamageBonus, versatilityDamageTakenReduction);

		statFrame:Show();
	end

	function PaperDollFrame_SetMastery(statFrame, unit)
		if ( unit ~= "player" ) then
			statFrame:Hide();
			return;
		end
		if (UnitLevel("player") < SHOW_MASTERY_LEVEL) then
			statFrame:Hide();
			return;
		end

		local mastery = GetMasteryEffect();
		PaperDollFrame_SetLabelAndText(statFrame, STAT_MASTERY, mastery, true, mastery);
		statFrame.onEnterFunc = Mastery_OnEnter;
		statFrame:Show();
	end

	function PaperDollFrame_SetLifesteal(statFrame, unit)
		if ( unit ~= "player" ) then
			statFrame:Hide();
			return;
		end

		local lifesteal = GetLifesteal();
		PaperDollFrame_SetLabelAndText(statFrame, STAT_LIFESTEAL, lifesteal, true, lifesteal);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_LIFESTEAL) .. " " .. format("%.2f%%", lifesteal) .. FONT_COLOR_CODE_CLOSE;

		statFrame.tooltip2 = format(CR_LIFESTEAL_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_LIFESTEAL)), GetCombatRatingBonus(CR_LIFESTEAL));

		statFrame:Show();
	end

	function PaperDollFrame_SetAvoidance(statFrame, unit)
		if ( unit ~= "player" ) then
			statFrame:Hide();
			return;
		end

		local avoidance = GetAvoidance();
		PaperDollFrame_SetLabelAndText(statFrame, STAT_AVOIDANCE, avoidance, true, avoidance);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVOIDANCE) .. " " .. format("%.2f%%", avoidance) .. FONT_COLOR_CODE_CLOSE;

		statFrame.tooltip2 = format(CR_AVOIDANCE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_AVOIDANCE)), GetCombatRatingBonus(CR_AVOIDANCE));

		statFrame:Show();
	end

	function PaperDollFrame_SetDodge(statFrame, unit)
		if (unit ~= "player") then
			statFrame:Hide();
			return;
		end

		local chance = GetDodgeChance();
		PaperDollFrame_SetLabelAndText(statFrame, STAT_DODGE, chance, true, chance);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, DODGE_CHANCE).." "..string.format("%.2f", chance).."%"..FONT_COLOR_CODE_CLOSE;
		statFrame.tooltip2 = format(CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE));
		statFrame:Show();
	end

	function PaperDollFrame_SetParry(statFrame, unit)
		if (unit ~= "player") then
			statFrame:Hide();
			return;
		end

		local chance = GetParryChance();
		PaperDollFrame_SetLabelAndText(statFrame, STAT_PARRY, chance, true, chance);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, PARRY_CHANCE).." "..string.format("%.2f", chance).."%"..FONT_COLOR_CODE_CLOSE;
		statFrame.tooltip2 = format(CR_PARRY_TOOLTIP, GetCombatRating(CR_PARRY), GetCombatRatingBonus(CR_PARRY));
		statFrame:Show();
	end

	function PaperDollFrame_SetBlock(statFrame, unit)
		if (unit ~= "player") then
			statFrame:Hide();
			return;
		end

		local chance = GetBlockChance();
		PaperDollFrame_SetLabelAndText(statFrame, STAT_BLOCK, chance, true, chance);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, BLOCK_CHANCE).." "..string.format("%.2f", chance).."%"..FONT_COLOR_CODE_CLOSE;
		statFrame.tooltip2 = format(CR_BLOCK_TOOLTIP, GetShieldBlock());
		statFrame:Show();
	end
	PaperDollFrame_UpdateStats()
end
	
	
local _, gdbprivate = ...
	gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsShowDecimalsChecked = {
		SetChecked = true,
	}	
local DCS_DecimalCheck = CreateFrame("CheckButton", "DCS_DecimalCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_DecimalCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_DecimalCheck:ClearAllPoints()
	DCS_DecimalCheck:SetPoint("TOPLEFT", 25, -60)
	DCS_DecimalCheck:SetScale(1.25)
	DCS_DecimalCheck.tooltipText = L['Displays "Enhancements" category stats to two decimal places.'] --Creates a tooltip on mouseover.
	_G[DCS_DecimalCheck:GetName() .. "Text"]:SetText(L["Decimals"])
	
	DCS_DecimalCheck:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDecimalsChecked
			self:SetChecked(checked.SetChecked)
			if self:GetChecked(true) then
				DCS_DecimalsShow()
				gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDecimalsChecked.SetChecked = true
			else
				DCS_DecimalsHide()
				gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDecimalsChecked.SetChecked = false
			end
		end
	end)

	DCS_DecimalCheck:SetScript("OnClick", function(self,event,arg1) 
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDecimalsChecked
		if self:GetChecked(true) then
			DCS_DecimalsShow()
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDecimalsChecked.SetChecked = true
		else
			DCS_DecimalsHide()
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsShowDecimalsChecked.SetChecked = false
		end
	end)