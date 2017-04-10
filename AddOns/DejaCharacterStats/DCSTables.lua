local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization
local name,addon = ...

local _, private = ...
local _, gdbprivate = ...
local _, DCS_TableData = ...
local _, gdbprivate = ...
	gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsItemLevelChecked = {
		ItemLevelEQ_AV_SetChecked = true,
		ItemLevelDecimalsSetChecked = false,
		ItemLevelTwoDecimalsSetChecked = true,
	}	


-----------------------
-- Item Level Checks --
-----------------------

	local DCS_ILvl_EQ_AV_Check = CreateFrame("CheckButton", "DCS_ILvl_EQ_AV_Check", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ILvl_EQ_AV_Check:RegisterEvent("PLAYER_LOGIN")
	DCS_ILvl_EQ_AV_Check:ClearAllPoints()
	DCS_ILvl_EQ_AV_Check:SetPoint("TOPLEFT", 25, -35)
	DCS_ILvl_EQ_AV_Check:SetScale(1.25)
	DCS_ILvl_EQ_AV_Check.tooltipText = L["Displays Equipped/Available item levels unless equal."] --Creates a tooltip on mouseover.
	_G[DCS_ILvl_EQ_AV_Check:GetName() .. "Text"]:SetText(L["Equipped/Available"])
	
	DCS_ILvl_EQ_AV_Check:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
			weekday, month, day, year = CalendarGetDate();
			mystrangefunction()
			local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelEQ_AV_SetChecked
			self:SetChecked(checked)
		end
	end)

	DCS_ILvl_EQ_AV_Check:SetScript("OnClick", function(self,event,arg1) 
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelEQ_AV_SetChecked
		if self:GetChecked(true) then
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelEQ_AV_SetChecked = true
		else
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelEQ_AV_SetChecked = false
		end
		PaperDollFrame_UpdateStats()
	end)

local DCS_ItemLevelDecimalPlacesCheck = CreateFrame("CheckButton", "DCS_ItemLevelDecimalPlacesCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ItemLevelDecimalPlacesCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ItemLevelDecimalPlacesCheck:ClearAllPoints()
	DCS_ItemLevelDecimalPlacesCheck:SetPoint("TOPLEFT", 65, -100)
	DCS_ItemLevelDecimalPlacesCheck:SetScale(1.00)
	DCS_ItemLevelDecimalPlacesCheck.tooltipText = L["Displays average item level to one decimal place."] --Creates a tooltip on mouseover.
	_G[DCS_ItemLevelDecimalPlacesCheck:GetName() .. "Text"]:SetText(L["Item Level 1 Decimal Place"])
	
	DCS_ItemLevelDecimalPlacesCheck:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked
			self:SetChecked(checked)
		end
	end)

	DCS_ItemLevelDecimalPlacesCheck:SetScript("OnClick", function(self,event,arg1) 
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked
		if self:GetChecked(true) then
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked = true
			DCS_ItemLevelTwoDecimalsCheck:SetChecked(false)
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked = false
		else
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked = false
		end
		PaperDollFrame_UpdateStats()
	end)
	
local DCS_ItemLevelTwoDecimalsCheck = CreateFrame("CheckButton", "DCS_ItemLevelTwoDecimalsCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ItemLevelTwoDecimalsCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ItemLevelTwoDecimalsCheck:ClearAllPoints()
	DCS_ItemLevelTwoDecimalsCheck:SetPoint("TOPLEFT", 65, -120)
	DCS_ItemLevelTwoDecimalsCheck:SetScale(1.00)
	DCS_ItemLevelTwoDecimalsCheck.tooltipText = L["Displays average item level to two decimal places."] --Creates a tooltip on mouseover.
	_G[DCS_ItemLevelTwoDecimalsCheck:GetName() .. "Text"]:SetText(L["Item Level 2 Decimal Places"])
	
	DCS_ItemLevelTwoDecimalsCheck:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked
			self:SetChecked(checked)
		end
	end)

	DCS_ItemLevelTwoDecimalsCheck:SetScript("OnClick", function(self,event,arg1) 
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked
		if self:GetChecked(true) then
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked = true
			DCS_ItemLevelDecimalPlacesCheck:SetChecked(false)
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked = false
		else
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked = false
		end
		PaperDollFrame_UpdateStats()
	end)

	
----------------------------
-- DCS Functions & Arrays --
----------------------------

function DCS_TableData:CopyTable(tab)
	local copy = {}
	for k, v in pairs(tab) do
		if k == "RUNE_REGEN" or k == "ATTACK_ATTACKSPEED" or k == "POWER" or k == "ALTERNATEMANA" then
			tab [k] = nil
		else
			copy[k] = (type(v) == "table") and DCS_TableData:CopyTable(v) or v
			--print(k)
		end	
	end
	return copy
end

function DCS_TableData:MergeTable(tab)
    local exists
	for i, v in ipairs(tab) do
        if (not self.StatData[v.statKey]) then
            table.remove(tab, i)
        end
    end
    for k in pairs(self.StatData) do
        exists = false 
        for _, v in ipairs(tab) do
            if (k == v.statKey) then exists = true end
        end
        if (not exists) then
            table.insert(tab, { statKey = k })
        end
    end
    return tab
end

function DCS_TableData:SwapStat(tab, statKey, dst)
    local src
    for i, v in ipairs(tab) do
        if (v.statKey == statKey) then
            src = v
            table.remove(tab, i)
        end
    end
    for i, v in ipairs(tab) do
        if (v.statKey == dst.statKey) then
            table.insert(tab, i, src or {statKey = statKey})
            break
        end
    end
    return tab
end

DCS_TableData.StatData = DCS_TableData:CopyTable(PAPERDOLL_STATINFO)

DCS_TableData.StatData.ItemLevelFrame = {
    category   = true,
    frame      = CharacterStatsPane.ItemLevelFrame,
    updateFunc = function(statFrame, unit)
		local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
		local DCS_DecimalPlaces
		local multiplier 
		if DCS_ItemLevelTwoDecimalsCheck:GetChecked(true) then
			DCS_DecimalPlaces = ("%.2f")
			multiplier = 100
		elseif DCS_ItemLevelDecimalPlacesCheck:GetChecked(true) then
			DCS_DecimalPlaces = ("%.1f")
			multiplier = 10
		else
			DCS_DecimalPlaces = ("%.0f")
			multiplier = 1
		end
		avgItemLevel = floor(multiplier*avgItemLevel)/multiplier;
		avgItemLevelEquipped = floor(multiplier*avgItemLevelEquipped)/multiplier;
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL).." "..format(DCS_DecimalPlaces, avgItemLevel);
		if not DCS_ILvl_EQ_AV_Check:GetChecked(true) or (avgItemLevel == avgItemLevelEquipped) then
			PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, format(DCS_DecimalPlaces,avgItemLevelEquipped), false, avgItemLevelEquipped)
		else
			PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, format(DCS_DecimalPlaces .. ("/") .. DCS_DecimalPlaces,avgItemLevelEquipped,avgItemLevel), false, avgItemLevelEquipped)
			local temp = DCS_DecimalPlaces .. ")"
			local format_for_avg_equipped = gsub(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, "d%)", temp,  1)
			statFrame.tooltip = statFrame.tooltip .. "  " .. format(format_for_avg_equipped, avgItemLevelEquipped);
		end
		statFrame.tooltip = statFrame.tooltip .. FONT_COLOR_CODE_CLOSE;
		statFrame.tooltip2 = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP;
		statFrame:Show()
    end
}

DCS_TableData.StatData.AttributesCategory = {
    category   = true,
    frame      = CharacterStatsPane.AttributesCategory,
    updateFunc = function() end
}
DCS_TableData.StatData.EnhancementsCategory = {
    category   = true,
    frame      = CharacterStatsPane.EnhancementsCategory,
    updateFunc = function() end
}

DCS_TableData.StatData.DCS_POWER = {
	updateFunc = function(statFrame, unit)
		powerToken = SPELL_POWER_MANA
		local power = UnitPowerMax(unit,powerToken);
		local powerText = BreakUpLargeNumbers(power);
		if power > 0 then
			--print("TABLES",weekday,month,day,year)
			if month==4 and day==1 then --April Fools
				PaperDollFrame_SetLabelAndText(statFrame, "Power", powerText, false, power);
			else
				PaperDollFrame_SetLabelAndText(statFrame, MANA, powerText, false, power);
			end
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, MANA).." "..powerText..FONT_COLOR_CODE_CLOSE;
			statFrame.tooltip2 = _G["STAT_MANA_TOOLTIP"];
			statFrame:Show();
		else
			statFrame:Hide();
		end
	end
}

DCS_TableData.StatData.DCS_ALTERNATEMANA = {
	updateFunc = function(statFrame, unit)
		local powerType, powerToken = UnitPowerType(unit);
		if (powerToken == "MANA") then
			statFrame:Hide();
			return;
		end
		local power = UnitPowerMax(unit,powerType);
		local powerText = BreakUpLargeNumbers(power);
		
		if (powerToken and _G[powerToken]) then
			if month==4 and day==1 then --April Fools
				PaperDollFrame_SetLabelAndText(statFrame, "Alt Power", powerText, false, power);
			else
				PaperDollFrame_SetLabelAndText(statFrame, _G[powerToken], powerText, false, power);
			end
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, _G[powerToken]).." "..powerText..FONT_COLOR_CODE_CLOSE;
			statFrame.tooltip2 = _G["STAT_"..powerToken.."_TOOLTIP"];
			statFrame:Show();
		else
			statFrame:Hide();
		end
	end
}

DCS_TableData.StatData.DCS_ATTACK_ATTACKSPEED = {
	updateFunc = function(statFrame, unit)
		local meleeHaste = GetMeleeHaste();
		local speed, offhandSpeed = UnitAttackSpeed(unit);

		local displaySpeed = format("%.2f", speed);
		if ( offhandSpeed ) then
			offhandSpeed = format("%.2f", offhandSpeed);
		end
		if ( offhandSpeed ) then
			displaySpeed =  BreakUpLargeNumbers(displaySpeed).." / ".. offhandSpeed;
		else
			displaySpeed =  BreakUpLargeNumbers(displaySpeed);
		end
		if month==4 and day==1 then --April Fools
			PaperDollFrame_SetLabelAndText(statFrame, "Twitter Speed", displaySpeed, false, speed);
		else	
			PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, displaySpeed, false, speed);
		end
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..displaySpeed..FONT_COLOR_CODE_CLOSE;
		statFrame.tooltip2 = format(STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste));
		statFrame:Show();
	end
}

DCS_TableData.StatData.DCS_RUNEREGEN = {
	updateFunc = function(statFrame, unit)
		if ( unit ~= "player" ) then
			statFrame:Hide();
			return;
		end

		local _, class = UnitClass(unit);
		if (class ~= "DEATHKNIGHT") then
			statFrame:Hide();
			return;
		end

		local _, regenRate = GetRuneCooldown(1); -- Assuming they are all the same for now
		if regenRate == nil then
			regenRate = 0
		end
		regenRate = tonumber(regenRate)
		
		local regenRateText = (format(STAT_RUNE_REGEN_FORMAT, regenRate));
		
		if month==4 and day==1 then --April Fools
			PaperDollFrame_SetLabelAndText(statFrame, "Восст. рун", regenRateText, false, regenRate);
		else
			PaperDollFrame_SetLabelAndText(statFrame, STAT_RUNE_REGEN, regenRateText, false, regenRate);
		end
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_RUNE_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
		statFrame.tooltip2 = STAT_RUNE_REGEN_TOOLTIP;
		statFrame:Show();
	end
}

DCS_TableData.StatData.WEAPON_DPS = {
    updateFunc = function(statFrame, unit)
		local function JustGetDamage(unit)
			if IsRangedWeapon() then
				local attackTime, minDamage, maxDamage, bonusPos, bonusNeg, percent = UnitRangedDamage(unit);
				return minDamage, maxDamage, nil, nil;
			else
				return UnitDamage(unit);
			end
		end
		local speed, offhandSpeed = UnitAttackSpeed(unit);
		local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage = JustGetDamage(unit);
		local fullDamage = (minDamage + maxDamage)/2;
		local white_dps = fullDamage/speed
		local main_oh_dps = format("%.2f", white_dps)
		local tooltip2 = (L["Main Hand"])
		-- If there's an offhand speed then add the offhand info to the tooltip
		if ( offhandSpeed and minOffHandDamage and maxOffHandDamage ) then
			local offhandFullDamage = (minOffHandDamage + maxOffHandDamage)/2;
			local oh_dps = offhandFullDamage/offhandSpeed
			main_oh_dps = main_oh_dps .. "/" .. format("%.2f",oh_dps)
			white_dps = (white_dps + oh_dps)*(1-DUAL_WIELD_HIT_PENALTY/100)
			tooltip2 = tooltip2 .. (L["/Off Hand"])
		end
		tooltip2 = tooltip2 .. L[" weapon auto attack (white) DPS."]
		local misses_etc = (1+BASE_MISS_CHANCE_PHYSICAL[3]/100)*(1+BASE_ENEMY_DODGE_CHANCE[3]/100)*(1+BASE_ENEMY_PARRY_CHANCE[3]/100) -- hopefully the right formula
		white_dps = white_dps*(1 + GetCritChance()/100)/misses_etc --assumes crits do twice as damage
		white_dps = format("%.2f", white_dps)
		if month==4 and day==1 then --April Fools
			PaperDollFrame_SetLabelAndText(statFrame, "WMDs", white_dps, false, white_dps)
		else
			PaperDollFrame_SetLabelAndText(statFrame, L["Weapon DPS"], white_dps, false, white_dps)
		end
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, format(L["Weapon DPS"], main_oh_dps)).." "..format("%s", main_oh_dps)..FONT_COLOR_CODE_CLOSE;
		statFrame.tooltip2 = (tooltip2);
	end
}

local function casterGCD()
	local haste = GetHaste()
	gcd = max(0.75, 1.5 * 100 / (100+haste))
	return gcd
end

DCS_TableData.StatData.GCD = {
    updateFunc = function(statFrame, unit)
		local spec = GetSpecialization();
		local primaryStat = select(6, GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player")));
		local gcd
		local _, classfilename = UnitClass("player")
		--print(classfilename)
		if (classfilename == "DRUID") then
			local id = GetShapeshiftFormID()
			if (id == 1) then --cat form
				gcd = 1
			else 
				-- strangely, bear form seems to have the same formula for gcd as casters
				gcd = casterGCD()
			end
		else
			if (primaryStat == LE_UNIT_STAT_INTELLECT) or (classfilename == "HUNTER") or (primaryStat == LE_UNIT_STAT_STRENGTH) then 
				-- adding wariors, paladins
				-- tested with Crusader Strike, Judgment on retribution paladin
				-- tested with Consecration, Avenger's Shield, Judgment on protection paladin
				-- tested with Slam on level 1 warior
				-- tested with Cobra shot and Multi-shot for hunter. Have troll hunter but don't have pet with Ancient Hysteria //Kakjens
				-- adding DK-s as reported by Mpstark
				gcd = casterGCD()
			else
				gcd = 1 -- tested with mutilate for assasination rogues.
			end
		end
		if month==4 and day==1 then --April Fools
			PaperDollFrame_SetLabelAndText(statFrame, "Global Warming", format("%.2fs",gcd), false, gcd)
		else
			PaperDollFrame_SetLabelAndText(statFrame, L["Global Cooldown"], format("%.2fs",gcd), false, gcd)
		end
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, format(L["Global Cooldown"], gcd)).." "..format("%.2fs", gcd)..FONT_COLOR_CODE_CLOSE;
		statFrame.tooltip2 = (L["General global cooldown refresh time."]);
	end
}

DCS_TableData.StatData.REPAIR_COST = {
    updateFunc = function(statFrame, unit)
        if (not statFrame.scanTooltip) then
            statFrame.scanTooltip = CreateFrame("GameTooltip", "StatRepairCostTooltip", statFrame, "GameTooltipTemplate")
            statFrame.scanTooltip:SetOwner(statFrame, "ANCHOR_NONE")
            statFrame.MoneyFrame = CreateFrame("Frame", "StatRepairCostMoneyFrame", statFrame, "TooltipMoneyFrameTemplate")
            MoneyFrame_SetType(statFrame.MoneyFrame, "TOOLTIP")
            statFrame.MoneyFrame:SetPoint("RIGHT", 3, -1)
            local font, size, flag = statFrame.Label:GetFont()
			--print (font, size, flag)
            statFrame.Label:SetFont(font, size, flag)
        end
        local totalCost = 0
        local _, repairCost
        for _, index in ipairs({1,3,5,6,7,8,9,10,16,17}) do
            statFrame.scanTooltip:ClearLines()
            _, _, repairCost = statFrame.scanTooltip:SetInventoryItem(unit, index)
            if (repairCost and repairCost > 0) then
                totalCost = totalCost + repairCost
            end
        end

        MoneyFrame_Update(statFrame.MoneyFrame, totalCost)
		statFrame.MoneyFrame:Hide()
		
		totalRepairCost = GetCoinTextureString(totalCost)
		
		local gold = floor(abs(totalCost / 10000))
		local silver = floor(abs(mod(totalCost / 100, 100)))
		local copper = floor(abs(mod(totalCost, 100)))
		--print(format("I have %d gold %d silver %d copper.", gold, silver, copper))

		local displayRepairTotal = format("%dg %ds %dc", gold, silver, copper);

		--STAT_FORMAT
		-- PaperDollFrame_SetLabelAndText(statFrame, label, text, isPercentage, numericValue) -- Formatting
		if month==4 and day==1 then --April Fools
			PaperDollFrame_SetLabelAndText(statFrame, "Thanks Obama!", totalRepairCost, false, displayRepairTotal);
		else
			PaperDollFrame_SetLabelAndText(statFrame, (L["Repair Total"]), totalRepairCost, false, displayRepairTotal);
		end
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, format(L["Repair Total"], totalRepairCost)).." "..format("%s", totalRepairCost)..FONT_COLOR_CODE_CLOSE;
		statFrame.tooltip2 = (L["Total equipped item repair cost before discounts."]);
    end
}

DCS_TableData.StatData.DURABILITY_STAT = {
    updateFunc = function(statFrame, unit)
		if ( unit ~= "player" ) then
			statFrame:Hide();
			return;
		end

		DCS_Mean_DurabilityCalc()
		--print(addon.duraMean)
		
		local displayDura = format("%.2f%%", addon.duraMean);
		if month==4 and day==1 then --April Fools
			PaperDollFrame_SetLabelAndText(statFrame, "Constitution", displayDura, false, addon.duraMean);
		else
			PaperDollFrame_SetLabelAndText(statFrame, (L["Durability"]), displayDura, false, addon.duraMean);
		end
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, format(L["Durability %s"], displayDura));
		statFrame.tooltip2 = (L["Average equipped item durability percentage."]);

		local duraFinite = 0
		statFrame:Show();
	end
}

local rating_and_percentage = "%s of %s increases %s by %.2f%%"

local statnames = {
 [CR_HASTE_MELEE] = {name1 = "Haste Rating", name2 = "haste"},
 [CR_LIFESTEAL] = {name1 = "Leech Rating", name2 = "leech"},
 [CR_AVOIDANCE] = {name1 = "Avoidance Rating", name2 = "avoidance"},
 [CR_DODGE] = {name1 = "Dodge Rating", name2 = "dodge"},
 [CR_PARRY] = {name1 = "Parry Rating", name2 = "parry"},
}

local function statframeratings(statFrame, unit, stat)
	--outliers crit, versatility, mastery
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	local rating = GetCombatRating(stat)
	local percentage = GetCombatRatingBonus(stat)
	local ratingname = statnames [stat].name1
	local name = statnames [stat].name2
	PaperDollFrame_SetLabelAndText(statFrame, ratingname, rating, false, rating);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..ratingname.." "..rating..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(rating_and_percentage, ratingname, BreakUpLargeNumbers(rating), name, percentage);
	statFrame:Show();
end

DCS_TableData.StatData.CRITCHANCE_RATING = { -- maybe add 3 different stats - melee, ranged and spell crit ratings?
	updateFunc = function(statFrame, unit)
		if ( unit ~= "player" ) then
			statFrame:Hide();
			return;
		end
		local stat;
		local spellCrit, rangedCrit, meleeCrit;
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
			stat = CR_CRIT_SPELL;
		elseif (rangedCrit >= meleeCrit) then
			stat = CR_CRIT_RANGED;
		else
			stat = CR_CRIT_MELEE;
		end
		local rating = GetCombatRating(stat);
		local percentage = format("%.2f",GetCombatRatingBonus(stat));
		PaperDollFrame_SetLabelAndText(statFrame, "Critical Strike Rating", rating, false, rating);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE.."Critical Strike Rating".." "..percentage..FONT_COLOR_CODE_CLOSE;
		--statFrame.tooltip2 = format("Critical Strike Rating of %s increases chance to crit by %.2f%%", BreakUpLargeNumbers(rating), percentage);
		statFrame.tooltip2 = format(rating_and_percentage, "Critical Strike", BreakUpLargeNumbers(rating), "crit", percentage);
		statFrame:Show();
	end
}

DCS_TableData.StatData.VERSATILITY_RATING = {
	updateFunc = function(statFrame, unit)
		if ( unit ~= "player" ) then
			statFrame:Hide();
			return;
		end
		local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
		local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE);
		--local versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN);
		PaperDollFrame_SetLabelAndText(statFrame, "Versatility Rating", versatility, false, versatility);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE.."Versatility Rating".." "..versatility..FONT_COLOR_CODE_CLOSE;
		statFrame.tooltip2 = format(rating_and_percentage,"Versatility Rating", BreakUpLargeNumbers(versatility), "versatility", versatilityDamageBonus);
		--statFrame.tooltip2 = format("Versatility Rating of %s increases damage and healing done by %.2f%% and reduces damage taken by %.2f%%", BreakUpLargeNumbers(versatility), versatilityDamageBonus, versatilityDamageTakenReduction);
		statFrame:Show();
	end
}

DCS_TableData.StatData.MASTERY_RATING = {
	updateFunc = function(statFrame, unit)
		if ( unit ~= "player" ) then
			statFrame:Hide();
			return;
		end
		if (UnitLevel("player") < SHOW_MASTERY_LEVEL) then
			statFrame.numericValue = 0;
			statFrame:Hide();
			return;
		end
		local _, bonuscoeff = GetMasteryEffect();
		local stat = CR_MASTERY
		local rating = GetCombatRating(stat)
		local percentage = format("%.2f",GetCombatRatingBonus(stat)*bonuscoeff)
		PaperDollFrame_SetLabelAndText(statFrame, "Mastery Rating", rating, false, rating);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE.."Mastery Rating".." "..rating..FONT_COLOR_CODE_CLOSE;
		statFrame.tooltip2 = format("Mastery Rating of %s increases mastery by %.2f%%", BreakUpLargeNumbers(rating), percentage);
		statFrame:Show();
	end
}

DCS_TableData.StatData.HASTE_RATING = {
	updateFunc = function(statFrame, unit)
		statframeratings(statFrame, unit, CR_HASTE_MELEE)
	end
}

DCS_TableData.StatData.LIFESTEAL_RATING = {
	updateFunc = function(statFrame, unit)
		statframeratings(statFrame, unit, CR_LIFESTEAL)
	end
}

DCS_TableData.StatData.AVOIDANCE_RATING = {
	updateFunc = function(statFrame, unit)
		statframeratings(statFrame, unit, CR_AVOIDANCE)
	end
}

DCS_TableData.StatData.DODGE_RATING = {
	updateFunc = function(statFrame, unit)
		statframeratings(statFrame, unit, CR_DODGE)
	end
}

DCS_TableData.StatData.PARRY_RATING = {
	updateFunc = function(statFrame, unit)
		statframeratings(statFrame, unit, CR_PARRY)
	end
}

-- ############## April Fools ###################

function mystrangefunction()
	if month==4 and day==1 then --April Fools
	local AltStats = CharacterStatsPane.AttributesCategory:CreateFontString("FontString","OVERLAY","GameTooltipText")
	AltStats:SetPoint("CENTER",CharacterStatsPane.AttributesCategory,"CENTER",0,0)
	AltStats:SetFont("Fonts\\FRIZQT__.TTF", 18, "THICKOUTLINE")
	AltStats:SetText("Alternative Stats");
	AltStats:SetTextColor(1, 1, 1);
	
	local AltStatsframe=CharacterStatsPane.AttributesCategory:CreateTexture(nil,"ARTWORK")
		AltStatsframe:SetAllPoints(CharacterStatsPane.AttributesCategory)
		--AltStatsframe:SetColorTexture(0, 192, 255, 0.7)
			
			
	local FAKEStats = CharacterStatsPane.EnhancementsCategory:CreateFontString("FontString","OVERLAY","GameTooltipText")

		FAKEStats:SetPoint("CENTER",CharacterStatsPane.EnhancementsCategory,"CENTER",0,0)
		FAKEStats:SetFont("Fonts\\FRIZQT__.TTF", 18, "THICKOUTLINE")
		FAKEStats:SetText("FAKE Stats");
		FAKEStats:SetTextColor(1, 1, 1);
		
	local FAKEStatsframe=CharacterStatsPane.EnhancementsCategory:CreateTexture(nil,"ARTWORK")
		FAKEStatsframe:SetAllPoints(CharacterStatsPane.EnhancementsCategory)
		
		function PaperDollFrame_SetHealth(statFrame, unit)
			if (not unit) then
				unit = "player";
			end
			local health = UnitHealthMax(unit);
			local healthText = BreakUpLargeNumbers(health);
			PaperDollFrame_SetLabelAndText(statFrame, "Life", healthText, false, health);
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, HEALTH).." "..healthText..FONT_COLOR_CODE_CLOSE;
			if (unit == "player") then
				statFrame.tooltip2 = STAT_HEALTH_TOOLTIP;
			elseif (unit == "pet") then
				statFrame.tooltip2 = STAT_HEALTH_PET_TOOLTIP;
			end
			statFrame:Show();
		end
		function PaperDollFrame_SetStat(statFrame, unit, statIndex)
			if (unit ~= "player") then
				statFrame:Hide();
				return;
			end

			local stat;
			local effectiveStat;
			local posBuff;
			local negBuff;
			stat, effectiveStat, posBuff, negBuff = UnitStat(unit, statIndex);

			local effectiveStatDisplay = BreakUpLargeNumbers(effectiveStat);
			-- Set the tooltip text
			local statName = _G["SPELL_STAT"..statIndex.."_NAME"];
			local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." ";

			if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
				statFrame.tooltip = tooltipText..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
			else
				tooltipText = tooltipText..effectiveStatDisplay;
				if ( posBuff > 0 or negBuff < 0 ) then
					tooltipText = tooltipText.." ("..BreakUpLargeNumbers(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
				end
				if ( posBuff > 0 ) then
					tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..BreakUpLargeNumbers(posBuff)..FONT_COLOR_CODE_CLOSE;
				end
				if ( negBuff < 0 ) then
					tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..BreakUpLargeNumbers(negBuff)..FONT_COLOR_CODE_CLOSE;
				end
				if ( posBuff > 0 or negBuff < 0 ) then
					tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
				end
				statFrame.tooltip = tooltipText;

				-- If there are any negative buffs then show the main number in red even if there are
				-- positive buffs. Otherwise show in green.
				if ( negBuff < 0 and not GetPVPGearStatRules() ) then
					effectiveStatDisplay = RED_FONT_COLOR_CODE..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
				end
			end
			PaperDollFrame_SetLabelAndText(statFrame, statName, effectiveStatDisplay, false, effectiveStat);
			statFrame.tooltip2 = _G["DEFAULT_STAT"..statIndex.."_TOOLTIP"];

			if (unit == "player") then
				local _, unitClass = UnitClass("player");
				unitClass = strupper(unitClass);

				local primaryStat, spec;
				spec = GetSpecialization();
				local role = GetSpecializationRole(spec);
				if (spec) then
					primaryStat = select(6, GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player")));
				end
				-- Strength
				if ( statIndex == LE_UNIT_STAT_STRENGTH ) then
					PaperDollFrame_SetLabelAndText(statFrame, "Tremendousness", effectiveStatDisplay, false, effectiveStat);
					local attackPower = GetAttackPowerForStat(statIndex,effectiveStat);
					if (HasAPEffectsSpellPower()) then
						statFrame.tooltip2 = STAT_TOOLTIP_BONUS_AP_SP;
					end
					if (not primaryStat or primaryStat == LE_UNIT_STAT_STRENGTH) then
						statFrame.tooltip2 = format(statFrame.tooltip2, BreakUpLargeNumbers(attackPower));
						if ( role == "TANK" ) then
							local increasedParryChance = GetParryChanceFromAttribute();
							if ( increasedParryChance > 0 ) then
								statFrame.tooltip2 = statFrame.tooltip2.."|n|n"..format(CR_PARRY_BASE_STAT_TOOLTIP, increasedParryChance);
							end
						end	
					else
						statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
					end
				-- Agility
				elseif ( statIndex == LE_UNIT_STAT_AGILITY ) then
					PaperDollFrame_SetLabelAndText(statFrame, "Dexterity", effectiveStatDisplay, false, effectiveStat);
					local attackPower = GetAttackPowerForStat(statIndex,effectiveStat);
					local tooltip = STAT_TOOLTIP_BONUS_AP;
					if (HasAPEffectsSpellPower()) then
						tooltip = STAT_TOOLTIP_BONUS_AP_SP;
					end
					if (not primaryStat or primaryStat == LE_UNIT_STAT_AGILITY) then
						statFrame.tooltip2 = format(tooltip, BreakUpLargeNumbers(attackPower));
						if ( role == "TANK" ) then
							local increasedDodgeChance = GetDodgeChanceFromAttribute();
							if ( increasedDodgeChance > 0 ) then
								statFrame.tooltip2 = statFrame.tooltip2.."|n|n"..format(CR_DODGE_BASE_STAT_TOOLTIP, increasedDodgeChance);
							end
						end
					else
						statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
					end
				-- Stamina
				elseif ( statIndex == LE_UNIT_STAT_STAMINA ) then
					PaperDollFrame_SetLabelAndText(statFrame, "Endurance", effectiveStatDisplay, false, effectiveStat);
					statFrame.tooltip2 = format(statFrame.tooltip2, BreakUpLargeNumbers(((effectiveStat*UnitHPPerStamina("player")))*GetUnitMaxHealthModifier("player")));
				-- Intellect
				elseif ( statIndex == LE_UNIT_STAT_INTELLECT ) then
					PaperDollFrame_SetLabelAndText(statFrame, "Intelligence", effectiveStatDisplay, false, effectiveStat);
					if ( UnitHasMana("player") ) then
						if (HasAPEffectsSpellPower()) then
							statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
						else
							local result, druid = HasSPEffectsAttackPower();
							if (result and druid) then
								statFrame.tooltip2 = format(STAT_TOOLTIP_SP_AP_DRUID, max(0, effectiveStat), max(0, effectiveStat));
							elseif (result) then
								statFrame.tooltip2 = format(STAT_TOOLTIP_BONUS_AP_SP, max(0, effectiveStat));
							elseif (not primaryStat or primaryStat == LE_UNIT_STAT_INTELLECT) then
								statFrame.tooltip2 = format(statFrame.tooltip2, max(0, effectiveStat));
							else
								statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
							end
						end
					else
						statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
					end
				end
			end
			statFrame:Show();
		end
		function PaperDollFrame_SetArmor(statFrame, unit)
			local baselineArmor, effectiveArmor, armor, posBuff, negBuff = UnitArmor(unit);
			PaperDollFrame_SetLabelAndText(statFrame, "Damage Control", effectiveArmor, false, effectiveArmor);
			local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel(unit));

			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ARMOR).." "..string.format("%s", effectiveArmor)..FONT_COLOR_CODE_CLOSE;
			statFrame.tooltip2 = format(STAT_ARMOR_TOOLTIP, armorReduction);
			statFrame:Show();
		end

		local function GetAppropriateDamage(unit)
			if IsRangedWeapon() then
				local attackTime, minDamage, maxDamage, bonusPos, bonusNeg, percent = UnitRangedDamage(unit);
				return minDamage, maxDamage, nil, nil, 0, 0, percent;
			else
				return UnitDamage(unit);
			end
		end

		function PaperDollFrame_SetDamage(statFrame, unit)
			local speed, offhandSpeed = UnitAttackSpeed(unit);
			local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = GetAppropriateDamage(unit);

			-- remove decimal points for display values
			local displayMin = max(floor(minDamage),1);
			local displayMinLarge = BreakUpLargeNumbers(displayMin);
			local displayMax = max(ceil(maxDamage),1);
			local displayMaxLarge = BreakUpLargeNumbers(displayMax);

			-- calculate base damage
			minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
			maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;

			local baseDamage = (minDamage + maxDamage) * 0.5;
			local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
			local totalBonus = (fullDamage - baseDamage);
			-- set tooltip text with base damage
			local damageTooltip = BreakUpLargeNumbers(max(floor(minDamage),1)).." - "..BreakUpLargeNumbers(max(ceil(maxDamage),1));

			local colorPos = "|cff20ff20";
			local colorNeg = "|cffff2020";

			-- epsilon check
			if ( totalBonus < 0.1 and totalBonus > -0.1 ) then
				totalBonus = 0.0;
			end

			local value;
			if ( totalBonus == 0 ) then
				if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then
					value = displayMinLarge.." - "..displayMaxLarge;
				else
					value = displayMinLarge.."-"..displayMaxLarge;
				end
			else
				-- set bonus color and display
				local color;
				if ( totalBonus > 0 ) then
					color = colorPos;
				else
					color = colorNeg;
				end
				if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then
					value = color..displayMinLarge.." - "..displayMaxLarge.."|r";
				else
					value = color..displayMinLarge.."-"..displayMaxLarge.."|r";
				end
				if ( physicalBonusPos > 0 ) then
					damageTooltip = damageTooltip..colorPos.." +"..physicalBonusPos.."|r";
				end
				if ( physicalBonusNeg < 0 ) then
					damageTooltip = damageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
				end
				if ( percent > 1 ) then
					damageTooltip = damageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
				elseif ( percent < 1 ) then
					damageTooltip = damageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
				end

			end
			PaperDollFrame_SetLabelAndText(statFrame, "Урон", value, false, displayMax);
			statFrame.damage = damageTooltip;
			statFrame.attackSpeed = speed;
			statFrame.unit = unit;

			-- If there's an offhand speed then add the offhand info to the tooltip
			if ( offhandSpeed and minOffHandDamage and maxOffHandDamage ) then
				minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;
				maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;

				local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
				local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent;
				local offhandDamageTooltip = BreakUpLargeNumbers(max(floor(minOffHandDamage),1)).." - "..BreakUpLargeNumbers(max(ceil(maxOffHandDamage),1));
				if ( physicalBonusPos > 0 ) then
					offhandDamageTooltip = offhandDamageTooltip..colorPos.." +"..physicalBonusPos.."|r";
				end
				if ( physicalBonusNeg < 0 ) then
					offhandDamageTooltip = offhandDamageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
				end
				if ( percent > 1 ) then
					offhandDamageTooltip = offhandDamageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
				elseif ( percent < 1 ) then
					offhandDamageTooltip = offhandDamageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
				end
				statFrame.offhandDamage = offhandDamageTooltip;
				statFrame.offhandAttackSpeed = offhandSpeed;
			else
				statFrame.offhandAttackSpeed = nil;
			end

			statFrame.onEnterFunc = CharacterDamageFrame_OnEnter;

			statFrame:Show();
		end
		function PaperDollFrame_SetAttackPower(statFrame, unit)
			local base, posBuff, negBuff;

			local rangedWeapon = IsRangedWeapon();

			local tag, tooltip;
			if ( rangedWeapon ) then
				base, posBuff, negBuff = UnitRangedAttackPower(unit);
				tag, tooltip = RANGED_ATTACK_POWER, RANGED_ATTACK_POWER_TOOLTIP;
			else
				base, posBuff, negBuff = UnitAttackPower(unit);
				tag, tooltip = MELEE_ATTACK_POWER, MELEE_ATTACK_POWER_TOOLTIP;
			end

			local damageBonus =  BreakUpLargeNumbers(max((base+posBuff+negBuff), 0)/ATTACK_POWER_MAGIC_NUMBER);
			local spellPower = 0;
			local value, valueText, tooltipText;
			if (GetOverrideAPBySpellPower() ~= nil) then
				local holySchool = 2;
				-- Start at 2 to skip physical damage
				spellPower = GetSpellBonusDamage(holySchool);
				for i=(holySchool+1), MAX_SPELL_SCHOOLS do
					spellPower = min(spellPower, GetSpellBonusDamage(i));
				end
				spellPower = min(spellPower, GetSpellBonusHealing()) * GetOverrideAPBySpellPower();

				value = spellPower;
				valueText, tooltipText = PaperDollFormatStat(tag, spellPower, 0, 0);
				damageBonus = BreakUpLargeNumbers(spellPower / ATTACK_POWER_MAGIC_NUMBER);
			else
				value = base;
				valueText, tooltipText = PaperDollFormatStat(tag, base, posBuff, negBuff);
			end
			PaperDollFrame_SetLabelAndText(statFrame, "Twitter Power", valueText, false, value);
			statFrame.tooltip = tooltipText;

			local effectiveAP = max(0,base + posBuff + negBuff);
			if (GetOverrideSpellPowerByAP() ~= nil) then
				statFrame.tooltip2 = format(MELEE_ATTACK_POWER_SPELL_POWER_TOOLTIP, damageBonus, BreakUpLargeNumbers(effectiveAP * GetOverrideSpellPowerByAP() + 0.5));
			else
				statFrame.tooltip2 = format(tooltip, damageBonus);
			end
			statFrame:Show();
		end
		function PaperDollFrame_SetSpellPower(statFrame, unit)
			local minModifier = 0;

			if (unit == "player") then
				local holySchool = 2;
				-- Start at 2 to skip physical damage
				minModifier = GetSpellBonusDamage(holySchool);

				if (statFrame.bonusDamage) then
					table.wipe(statFrame.bonusDamage);
				else
					statFrame.bonusDamage = {};
				end
				statFrame.bonusDamage[holySchool] = minModifier;
				for i=(holySchool+1), MAX_SPELL_SCHOOLS do
					local bonusDamage = GetSpellBonusDamage(i);
					minModifier = min(minModifier, bonusDamage);
					statFrame.bonusDamage[i] = bonusDamage;
				end
			elseif (unit == "pet") then
				minModifier = GetPetSpellBonusDamage();
				statFrame.bonusDamage = nil;
			end

			PaperDollFrame_SetLabelAndText(statFrame, "Literacy", BreakUpLargeNumbers(minModifier), false, minModifier);
			statFrame.tooltip = STAT_SPELLPOWER;
			statFrame.tooltip2 = STAT_SPELLPOWER_TOOLTIP;

			statFrame.minModifier = minModifier;
			statFrame.unit = unit;
			statFrame.onEnterFunc = CharacterSpellBonusDamage_OnEnter;
			statFrame:Show();
		end

		function PaperDollFrame_SetEnergyRegen(statFrame, unit)
			if ( unit ~= "player" ) then
				statFrame:Hide();
				return;
			end

			local powerType, powerToken = UnitPowerType(unit);
			if (powerToken ~= "ENERGY") then
				statFrame:Hide();
				return;
			end

			local regenRate = GetPowerRegen();
			local regenRateText = BreakUpLargeNumbers(regenRate);
			PaperDollFrame_SetLabelAndText(statFrame, "Red Bull", regenRateText, false, regenRate);
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_ENERGY_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
			statFrame.tooltip2 = STAT_ENERGY_REGEN_TOOLTIP;
			statFrame:Show();
		end

		function PaperDollFrame_SetFocusRegen(statFrame, unit)
			if ( unit ~= "player" ) then
				statFrame:Hide();
				return;
			end

			local powerType, powerToken = UnitPowerType(unit);
			if (powerToken ~= "FOCUS") then
				statFrame:Hide();
				return;
			end

			local regenRate = GetPowerRegen();
			local regenRateText = BreakUpLargeNumbers(regenRate);
			PaperDollFrame_SetLabelAndText(statFrame, "Adderall", regenRateText, false, regenRate);
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_FOCUS_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
			statFrame.tooltip2 = STAT_FOCUS_REGEN_TOOLTIP;
			statFrame:Show();
		end

		function PaperDollFrame_SetRuneRegen(statFrame, unit)
			if ( unit ~= "player" ) then
				statFrame:Hide();
				return;
			end

			local _, class = UnitClass(unit);
			if (class ~= "DEATHKNIGHT") then
				statFrame:Hide();
				return;
			end

			local _, regenRate = GetRuneCooldown(1); -- Assuming they are all the same for now
			local regenRateText = (format(STAT_RUNE_REGEN_FORMAT, regenRate));
			PaperDollFrame_SetLabelAndText(statFrame, "Восст. рун", regenRateText, false, regenRate);
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_RUNE_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
			statFrame.tooltip2 = STAT_RUNE_REGEN_TOOLTIP;
			statFrame:Show();
		end

		function PaperDollFrame_SetManaRegen(statFrame, unit)
			if ( unit ~= "player" ) then
				statFrame:Hide();
				return;
			end

			if ( not UnitHasMana("player") ) then
				PaperDollFrame_SetLabelAndText(statFrame, "Man-a-Lago", NOT_APPLICABLE, false, 0);
				statFrame.tooltip = nil;
				return;
			end

			local base, combat = GetManaRegen();
			-- All mana regen stats are displayed as mana/5 sec.
			base = floor(base * 5.0);
			combat = floor(combat * 5.0);
			local baseText = BreakUpLargeNumbers(base);
			local combatText = BreakUpLargeNumbers(combat);
			-- Combat mana regen is most important to the player, so we display it as the main value
			PaperDollFrame_SetLabelAndText(statFrame, "Man-a-Lago", combatText, false, combat);
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, MANA_REGEN) .. " " .. combatText .. FONT_COLOR_CODE_CLOSE;
			-- Base (out of combat) regen is displayed only in the subtext of the tooltip
			statFrame.tooltip2 = format(MANA_REGEN_TOOLTIP, baseText);
			statFrame:Show();
		end

		function MovementSpeed_OnUpdate(statFrame, elapsedTime)
			local unit = statFrame.unit;
			local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed(unit);
			runSpeed = runSpeed/BASE_MOVEMENT_SPEED*100;
			flightSpeed = flightSpeed/BASE_MOVEMENT_SPEED*100;
			swimSpeed = swimSpeed/BASE_MOVEMENT_SPEED*100;

			-- Pets seem to always actually use run speed
			if (unit == "pet") then
				swimSpeed = runSpeed;
			end

			-- Determine whether to display running, flying, or swimming speed
			local speed = runSpeed;
			local swimming = IsSwimming(unit);
			if (swimming) then
				speed = swimSpeed;
			elseif (IsFlying(unit)) then
				speed = flightSpeed;
			end

			-- Hack so that your speed doesn't appear to change when jumping out of the water
			if (IsFalling(unit)) then
				if (statFrame.wasSwimming) then
					speed = swimSpeed;
				end
			else
				statFrame.wasSwimming = swimming;
			end

			local valueText = format("%d%%", speed+0.5);
			PaperDollFrame_SetLabelAndText(statFrame, "Скорость движения", valueText, false, speed);
			statFrame.speed = speed;
			statFrame.runSpeed = runSpeed;
			statFrame.flightSpeed = flightSpeed;
			statFrame.swimSpeed = swimSpeed;
		end

	end
end