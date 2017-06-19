local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization
local name,addon = ...

--local _, private = ...
--local _, gdbprivate = ...
local dcs_format = format
local _, DCS_TableData = ...
local _, gdbprivate = ...
local ilvl_two_decimals, ilvl_one_decimals
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
	
	DCS_ILvl_EQ_AV_Check:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_LOGIN" then
			local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelEQ_AV_SetChecked
			self:SetChecked(checked)
		end
	end)

	DCS_ILvl_EQ_AV_Check:SetScript("OnClick", function(self)
		local checked = self:GetChecked()
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelEQ_AV_SetChecked = checked
		--[[
		if self:GetChecked(true) then
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelEQ_AV_SetChecked = true
		else
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelEQ_AV_SetChecked = false
		end
		--]]
		PaperDollFrame_UpdateStats()
	end)

local DCS_ItemLevelDecimalPlacesCheck = CreateFrame("CheckButton", "DCS_ItemLevelDecimalPlacesCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ItemLevelDecimalPlacesCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ItemLevelDecimalPlacesCheck:ClearAllPoints()
	DCS_ItemLevelDecimalPlacesCheck:SetPoint("TOPLEFT", 65, -100)
	DCS_ItemLevelDecimalPlacesCheck:SetScale(1.00)
	DCS_ItemLevelDecimalPlacesCheck.tooltipText = L["Displays average item level to one decimal place."] --Creates a tooltip on mouseover.
	_G[DCS_ItemLevelDecimalPlacesCheck:GetName() .. "Text"]:SetText(L["Item Level 1 Decimal Place"])
	
	DCS_ItemLevelDecimalPlacesCheck:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_LOGIN" then
			local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked
			ilvl_one_decimals = checked
			self:SetChecked(checked)
		end
	end)

	DCS_ItemLevelDecimalPlacesCheck:SetScript("OnClick", function(self)
		local checked = self:GetChecked()
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked = checked
		ilvl_one_decimals = checked
		if checked then
			DCS_ItemLevelTwoDecimalsCheck:SetChecked(false)
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked = false
			ilvl_two_decimals = false
		end
		--[[
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked
		if self:GetChecked(true) then
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked = true
			DCS_ItemLevelTwoDecimalsCheck:SetChecked(false)
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked = false
		else
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked = false
		end
		--]]
		PaperDollFrame_UpdateStats()
	end)
	
local DCS_ItemLevelTwoDecimalsCheck = CreateFrame("CheckButton", "DCS_ItemLevelTwoDecimalsCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ItemLevelTwoDecimalsCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ItemLevelTwoDecimalsCheck:ClearAllPoints()
	DCS_ItemLevelTwoDecimalsCheck:SetPoint("TOPLEFT", 65, -120)
	DCS_ItemLevelTwoDecimalsCheck:SetScale(1.00)
	DCS_ItemLevelTwoDecimalsCheck.tooltipText = L["Displays average item level to two decimal places."] --Creates a tooltip on mouseover.
	_G[DCS_ItemLevelTwoDecimalsCheck:GetName() .. "Text"]:SetText(L["Item Level 2 Decimal Places"])
	
	DCS_ItemLevelTwoDecimalsCheck:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_LOGIN" then
			local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked
			self:SetChecked(checked)
			ilvl_two_decimals = checked
		end
	end)

	DCS_ItemLevelTwoDecimalsCheck:SetScript("OnClick", function(self) 
		local checked = self:GetChecked()
		gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked = checked
		ilvl_two_decimals = checked
		if checked then
			DCS_ItemLevelDecimalPlacesCheck:SetChecked(false)
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked = false
			ilvl_one_decimals = false
		end
		--[[
		local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked
		if self:GetChecked(true) then
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked = true
			DCS_ItemLevelDecimalPlacesCheck:SetChecked(false)
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelDecimalsSetChecked = false
		else
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsItemLevelChecked.ItemLevelTwoDecimalsSetChecked = false
		end
		--]]
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
		--if DCS_ItemLevelTwoDecimalsCheck:GetChecked(true) then
		if ilvl_two_decimals then
			DCS_DecimalPlaces = ("%.2f")
			multiplier = 100
		elseif ilvl_one_decimals then
		--elseif DCS_ItemLevelDecimalPlacesCheck:GetChecked(true) then
			DCS_DecimalPlaces = ("%.1f")
			multiplier = 10
		else
			DCS_DecimalPlaces = ("%.0f")
			multiplier = 1
		end
		avgItemLevel = floor(multiplier*avgItemLevel)/multiplier;
		avgItemLevelEquipped = floor(multiplier*avgItemLevelEquipped)/multiplier;
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..dcs_format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL).." "..dcs_format(DCS_DecimalPlaces, avgItemLevel);
		if not DCS_ILvl_EQ_AV_Check:GetChecked(true) or (avgItemLevel == avgItemLevelEquipped) then
			PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, dcs_format(DCS_DecimalPlaces,avgItemLevelEquipped), false, avgItemLevelEquipped)
		else
			PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, dcs_format(DCS_DecimalPlaces .. ("/") .. DCS_DecimalPlaces,avgItemLevelEquipped,avgItemLevel), false, avgItemLevelEquipped)
			local temp = DCS_DecimalPlaces .. ")"
			local format_for_avg_equipped = gsub(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, "d%)", temp,  1)
			statFrame.tooltip = statFrame.tooltip .. "  " .. dcs_format(format_for_avg_equipped, avgItemLevelEquipped);
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
		local powerType = SPELL_POWER_MANA --changing here as well for similarity
		local power = UnitPowerMax(unit,powerType);
		local powerText = BreakUpLargeNumbers(power);
		if power > 0 then
			PaperDollFrame_SetLabelAndText(statFrame, MANA, powerText, false, power);
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..dcs_format(PAPERDOLLFRAME_TOOLTIP_FORMAT, MANA).." "..powerText..FONT_COLOR_CODE_CLOSE;
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
			PaperDollFrame_SetLabelAndText(statFrame, _G[powerToken], powerText, false, power);
			statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..dcs_format(PAPERDOLLFRAME_TOOLTIP_FORMAT, _G[powerToken]).." "..powerText..FONT_COLOR_CODE_CLOSE;
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

		local displaySpeed = dcs_format("%.2f", speed);
		if ( offhandSpeed ) then
			offhandSpeed = dcs_format("%.2f", offhandSpeed);
		end
		if ( offhandSpeed ) then
			displaySpeed =  BreakUpLargeNumbers(displaySpeed).." / ".. offhandSpeed;
		else
			displaySpeed =  BreakUpLargeNumbers(displaySpeed);
		end
		PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, displaySpeed, false, speed);

		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..dcs_format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..displaySpeed..FONT_COLOR_CODE_CLOSE;
		statFrame.tooltip2 = dcs_format(STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste));

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
		
		local regenRateText = (dcs_format(STAT_RUNE_REGEN_FORMAT, regenRate));
		PaperDollFrame_SetLabelAndText(statFrame, STAT_RUNE_REGEN, regenRateText, false, regenRate);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..dcs_format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_RUNE_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
		statFrame.tooltip2 = STAT_RUNE_REGEN_TOOLTIP;
		statFrame:Show();
	end
}

DCS_TableData.StatData.WEAPON_DPS = {
    updateFunc = function(statFrame, unit)
		local function JustGetDamage(unit)
			if IsRangedWeapon() then
				local attackTime, minDamage, maxDamage = UnitRangedDamage(unit);
				return minDamage, maxDamage, nil, nil;
			else
				return UnitDamage(unit);
			end
		end
		local speed, offhandSpeed = UnitAttackSpeed(unit);
		local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage = JustGetDamage(unit);
		local fullDamage = (minDamage + maxDamage)/2;
		local white_dps = fullDamage/speed
		local main_oh_dps = dcs_format("%.2f", white_dps)
		local tooltip2 = (L["Main Hand"])
		-- If there's an offhand speed then add the offhand info to the tooltip
		if ( offhandSpeed and minOffHandDamage and maxOffHandDamage ) then
			local offhandFullDamage = (minOffHandDamage + maxOffHandDamage)/2;
			local oh_dps = offhandFullDamage/offhandSpeed
			main_oh_dps = main_oh_dps .. "/" .. dcs_format("%.2f",oh_dps)
			white_dps = (white_dps + oh_dps)*(1-DUAL_WIELD_HIT_PENALTY/100)
			tooltip2 = tooltip2 .. (L["/Off Hand"])
		end
		tooltip2 = tooltip2 .. L[" weapon auto attack (white) DPS."]
		local misses_etc = (1+BASE_MISS_CHANCE_PHYSICAL[3]/100)*(1+BASE_ENEMY_DODGE_CHANCE[3]/100)*(1+BASE_ENEMY_PARRY_CHANCE[3]/100) -- hopefully the right formula
		white_dps = white_dps*(1 + GetCritChance()/100)/misses_etc --assumes crits do twice as damage
		white_dps = dcs_format("%.2f", white_dps)
		PaperDollFrame_SetLabelAndText(statFrame, L["Weapon DPS"], white_dps, false, white_dps)
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..dcs_format(PAPERDOLLFRAME_TOOLTIP_FORMAT, dcs_format(L["Weapon DPS"], main_oh_dps)).." "..dcs_format("%s", main_oh_dps)..FONT_COLOR_CODE_CLOSE;
		statFrame.tooltip2 = (tooltip2);
	end
}

local function casterGCD()
	local haste = GetHaste()
	local gcd = max(0.75, 1.5 * 100 / (100+haste))
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
			if (primaryStat == LE_UNIT_STAT_INTELLECT) or (classfilename == "HUNTER") or (primaryStat == LE_UNIT_STAT_STRENGTH) or (classfilename == "DEMONHUNTER")then 
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
		PaperDollFrame_SetLabelAndText(statFrame, L["Global Cooldown"], dcs_format("%.2fs",gcd), false, gcd)
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..dcs_format(PAPERDOLLFRAME_TOOLTIP_FORMAT, dcs_format(L["Global Cooldown"], gcd)).." "..dcs_format("%.2fs", gcd)..FONT_COLOR_CODE_CLOSE;
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
		--beware of strange mathematical calculations below
		local try_to_predict_more_accurately = false -- placeholder for the checkbox
		local multiplier
		local upperbound, lowerbound
		local reaction
		if try_to_predict_more_accurately then
			reaction = UnitReaction("target", "player")
			if not UnitIsPVP("target") then reaction = 4 end -- should take care of repair bots/repair mounts
			--if not reaction then reaction = 4 end --if no target then neutral faction; seems like isn't needed
			multiplier = (24 - reaction)/20 -- friendly faction has 5% discount, and exalted 20% discount
			--print("mult= ",multiplier)
			upperbound, lowerbound = 0, 0
		end
        local totalCost = 0
        local _, repairCost
        for _, index in ipairs({1,3,5,6,7,8,9,10,16,17}) do
            statFrame.scanTooltip:ClearLines()
            _, _, repairCost = statFrame.scanTooltip:SetInventoryItem(unit, index)
            if (repairCost and repairCost > 0) then
                totalCost = totalCost + repairCost
				if try_to_predict_more_accurately then
					upperbound = upperbound + floor((repairCost+0.5)/multiplier)
					lowerbound = lowerbound + ceil((repairCost-0.5)/multiplier)
				end
            end
        end

		--local repairAllCost, canRepair = GetRepairAllCost()
		--print(repairAllCost)
--		print("----")
		if try_to_predict_more_accurately then
			--print("between ",lowerbound," and ",upperbound)
			totalCost = floor(0.5+multiplier*(upperbound + lowerbound)/2)
			--print(totalCost)
		end
        MoneyFrame_Update(statFrame.MoneyFrame, totalCost)
		statFrame.MoneyFrame:Hide()
		
		local totalRepairCost = GetCoinTextureString(totalCost)
		
		local gold = floor(abs(totalCost / 10000))
		local silver = floor(abs(mod(totalCost / 100, 100)))
		local copper = floor(abs(mod(totalCost, 100)))
		--print(dcs_format("I have %d gold %d silver %d copper.", gold, silver, copper))

		local displayRepairTotal = dcs_format("%dg %ds %dc", gold, silver, copper);

		--STAT_FORMAT
		-- PaperDollFrame_SetLabelAndText(statFrame, label, text, isPercentage, numericValue) -- Formatting

		PaperDollFrame_SetLabelAndText(statFrame, (L["Repair Total"]), totalRepairCost, false, displayRepairTotal);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..dcs_format(PAPERDOLLFRAME_TOOLTIP_FORMAT, dcs_format(L["Repair Total"], totalRepairCost)).." "..dcs_format("%s", totalRepairCost)..FONT_COLOR_CODE_CLOSE;
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
		
		local displayDura = dcs_format("%.2f%%", addon.duraMean);

		PaperDollFrame_SetLabelAndText(statFrame, (L["Durability"]), displayDura, false, addon.duraMean);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..dcs_format(PAPERDOLLFRAME_TOOLTIP_FORMAT, dcs_format(L["Durability %s"], displayDura));
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
	statFrame.tooltip2 = dcs_format(rating_and_percentage, ratingname, BreakUpLargeNumbers(rating), name, percentage);
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
		--local spellCrit;
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
		local percentage = dcs_format("%.2f",GetCombatRatingBonus(stat));
		PaperDollFrame_SetLabelAndText(statFrame, "Critical Strike Rating", rating, false, rating);
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE.."Critical Strike Rating".." "..percentage..FONT_COLOR_CODE_CLOSE;
		--statFrame.tooltip2 = dcs_format("Critical Strike Rating of %s increases chance to crit by %.2f%%", BreakUpLargeNumbers(rating), percentage);
		statFrame.tooltip2 = dcs_format(rating_and_percentage, "Critical Strike", BreakUpLargeNumbers(rating), "crit", percentage);
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
		statFrame.tooltip2 = dcs_format(rating_and_percentage,"Versatility Rating", BreakUpLargeNumbers(versatility), "versatility", versatilityDamageBonus);
		--statFrame.tooltip2 = dcs_format("Versatility Rating of %s increases damage and healing done by %.2f%% and reduces damage taken by %.2f%%", BreakUpLargeNumbers(versatility), versatilityDamageBonus, versatilityDamageTakenReduction);
		statFrame:Show();
	end
}

DCS_TableData.StatData.MASTERY_RATING = {
	--TODO: localisation of format here
	updateFunc = function(statFrame, unit)
		if ( unit ~= "player" ) then
			statFrame:Hide();
			return;
		end
		local color_rating1 = "Mastery Rating"
		local color_rating2 = color_rating1 .. ":"
		local color_format = "%d"
		local add_text = ""
		--if (UnitLevel("player") < SHOW_MASTERY_LEVEL) then
		--	statFrame.numericValue = 0;
		--	statFrame:Hide();
		--	return;
		--end
		local _, bonuscoeff = GetMasteryEffect();
		local stat = CR_MASTERY
		local rating = GetCombatRating(stat)
		if (UnitLevel("player") < SHOW_MASTERY_LEVEL) then
			color_rating1 = "|cff7f7f7f" .. color_rating1 .. "|r"
			color_rating2 = "|cff7f7f7f" .. color_rating2 .. "|r"
			color_format = "|cff7f7f7f" .. color_format .. "|r"
			add_text = " |cffff0000(Requires Level " .. SHOW_MASTERY_LEVEL ..")|r"
		end
		local percentage = format("%.2f",GetCombatRatingBonus(stat)*bonuscoeff)
		PaperDollFrame_SetLabelAndText(statFrame, "", format(color_format,rating), false, rating);
		statFrame.Label:SetText(color_rating2)
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..color_rating1.." "..format(color_format,rating)..add_text..FONT_COLOR_CODE_CLOSE;
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