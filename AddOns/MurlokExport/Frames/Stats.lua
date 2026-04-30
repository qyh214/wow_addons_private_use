local _, core = ...

local function GetPlayerStats()
	local playerStats = {}

	local spellCrit, rangedCrit, meleeCrit
	local critChance

	local holySchool = 2
	local minCrit = GetSpellCritChance(holySchool)
	for i=(holySchool+1), MAX_SPELL_SCHOOLS do
		spellCrit = GetSpellCritChance(i)
		minCrit = min(minCrit, spellCrit)
	end
	spellCrit = minCrit
	rangedCrit = GetRangedCritChance()
	meleeCrit = GetCritChance()

	if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
		critChance = spellCrit
	elseif (rangedCrit >= meleeCrit) then
		critChance = rangedCrit
	else
		critChance = meleeCrit
	end
	playerStats["crit"] = critChance
	playerStats["haste"] = GetHaste()
	playerStats["mastery"] = GetMasteryEffect()
	playerStats["versatility"] = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
	playerStats["avoidance"] = GetAvoidance()
	playerStats["leech"] = GetLifesteal()
	playerStats["speed"] = GetSpeed()

	return playerStats
end

StatsFrameMixin = {}
function StatsFrameMixin:OnClick(stats)
    local playerStats = GetPlayerStats()

    local index = 1
    for k, v in core:IPairs(stats.secondary_stats, function (k1, k2) return k1 ~= nil and k2 ~= nil and k1[2].value > k2[2].value end) do
        self.stats["secStatIcon" .. index]:SetTexture(core:Artwork("Attribute_" .. k))
		if v.value == nil then v.value = 0 end
		if v.percent == nil then v.percent = 0 end
        self.stats["secStatName" .. index]:SetText(_G["MURLOKEXPORT_STATS_" .. string.upper(k)] .. "\n" .. v.value .. " / " .. v.percent .. "%\n" .. "[" .. format("%d%%", playerStats[k] + 0.5) .. "]")
        index = index + 1
    end

    local index = 1
    for k, v in core:IPairs(stats.minor_stats, function (k1, k2) return k1 ~= nil and k2 ~= nil and k1[2].value > k2[2].value end) do
        self.stats["minorStatIcon" .. index]:SetTexture(core:Artwork("Attribute_" .. k))
		if v.value == nil then v.value = 0 end
		if v.percent == nil then v.percent = 0 end
        self.stats["minorStatName" .. index]:SetText(_G["MURLOKEXPORT_STATS_" .. string.upper(k)] .. "\n" .. v.value .. " / " .. v.percent .. "%\n" .. "[" .. format("%d%%", playerStats[k] + 0.5) .. "]")
        index = index + 1
    end
    self.stats.ratingStatName:SetText(core:GetRankColor(0) .. stats.rating .. "|r")
end