local AceGUI			= LibStub("AceGUI-3.0")
local AceConfig			= LibStub("AceConfig-3.0")
local AceConfigDialog	= LibStub("AceConfigDialog-3.0")
local AceDB				= LibStub("AceDB-3.0")
local AceDBOptions		= LibStub("AceDBOptions-3.0")
local LibDualSpec		= LibStub("LibDualSpec-1.0")
local L					= LibStub("AceLocale-3.0"):GetLocale("Stats+")
local CallbackHandler	= LibStub("CallbackHandler-1.0")
local LSM				= LibStub("LibSharedMedia-3.0")
local LDB				= LibStub("LibDataBroker-1.1")
local LDBIcon			= LibStub("LibDBIcon-1.0")

local db

local CURRENT_VERSION		= L["Version"] .. " 1.55"
local tempPreview			= {}


local defaults = {
	profile = {
		fontSize = 14,
		spacing = 3,
		decimalPlaces = 2,
		locked = false,
		useBackground = false,
		useBackgroundBorder = false,
		backgroundOpacity = 1,
		outline = true,
		oneLineLayout = false,
		showItemLevel = true,
		showMainStat = true,
		showSecondaries = true,
		showLeech = false,
		showAvoidance = false,
		showSpeed = false,
		showBlock = false,
		showParry = false,
		showDodge = false,
		showArmor = false,
		autoHideIrrelevantDefensives = false,
		fontName = "GameFontNormal",
		align = "RIGHT",	
		frameStrata = "HIGH",
		showStatsMode = "ALWAYS",
		itemlevelDisplay = "Auto",
		secondaryFormat = "NUMBER_PERCENT",
		versatilityDisplay = "VERS_ONLY",
		tertiariesFormat = "NUMBER_PERCENT",
		versatilityDisplay = "VERS_ONLY",
		speedFormat = "CURRENT",
		secondaryOrdering = "PRIO",
		globalStatOrdering = "DEFAULT",
		customGlobalStatText = "",
		customSecondaryText = "",
		useGlobalPosition = false,
		backgroundTexture = "None",
		backgroundExtendUp = 0,
		backgroundExtendRight = 0,
		backgroundExtendDown = 0,
		backgroundExtendLeft = 0,
		borderStyle = "1 Pixel",
		borderSize = 1,
		borderOffset = 0,
		borderOpacity = 1,
		colors = {
			ilvl = {r=1,g=1,b=1},
			main = {r=0.46,g=0.76,b=0.77},
			crit = {r=0.77,g=0.29,b=0.28},
			haste = {r=0.34,g=0.77,b=0.40},
			mastery = {r=0.77,g=0.77,b=0.25},
			vers = {r=0.32,g=0.42,b=0.77},
			leech = {r=0.81,g=0.39,b=0.99},
			avoidance = {r=0.99,g=0.62,b=0.19},
			speed = {r=1,g=1,b=0.4},
			block = {r=0.75,g=0.75,b=0.75},
			parry = {r=0.65,g=0.85,b=0.85},
			dodge = {r=0.85,g=0.85,b=0.65},
			armor = {r=0.6,g=0.6,b=0.9},
			bgColor = {r=0,g=0,b=0},
			borderColor = {r=1,g=1,b=1},
		},
		customStatText = {
			Ilvl = "",
			Main = "",
			Crit = "",
			Haste = "",
			Mastery = "",
			Vers = "",
			Leech = "",
			Avoidance = "",
			Speed = "",
			Armor = "",
			Block = "",
			Parry = "",
			Dodge = "",
		},
		minimap = {
			hide = false,
			minimapPos = 180,
		},
		pos = { point="CENTER", relativeTo="UIParent", relativePoint="CENTER", x=0, y=0 },
	},
	global = {
		updateInterval = 0.35,
		version = nil,
		seenOptions = nil,
		pos = { point="CENTER", relativeTo="UIParent", relativePoint="CENTER", x=0, y=0 },
	},
}

local f = CreateFrame("Frame", "statsFrame", UIParent, "BackdropTemplate")

f.bg = f:CreateTexture(nil, "BACKGROUND")
f.bg:SetColorTexture(0, 0, 0, 0.7)
f.bg:SetAllPoints(f)
f.bg:Hide()

f.bgTexture = f:CreateTexture(nil, "BORDER")
f.bgTexture:SetAllPoints(f)
f.bgTexture:Hide()

f.borderFrame = CreateFrame("Frame", "statsFrameBorder", f, "BackdropTemplate")
f.borderFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
f.borderFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)

f:SetSize(260, 150)
f:SetMovable(true)
f:EnableMouse(false)
f:RegisterForDrag("LeftButton")
f:Hide()

local function ApplyLockState()
	if not db then return end
	if db.profile.locked then
		f:EnableMouse(false)
		f:RegisterForDrag()
	else
		f:EnableMouse(true)
		f:RegisterForDrag("LeftButton")
	end
end

f:SetScript("OnDragStart", function()
	if not db then return end
	if not db.profile.locked then f:StartMoving() end
end)

f:SetScript("OnDragStop", function()
	if not db then return end
	f:StopMovingOrSizing()
	local point, relativeTo, relativePoint, x, y = f:GetPoint(1)
	local posData = { point = point or "CENTER", relativeTo = relativeTo and relativeTo:GetName() or "UIParent", relativePoint = relativePoint or "CENTER", x = x or 0, y = y or 0, }

	if db.profile.useGlobalPosition then
		db.global.pos = posData
	else
		db.profile.pos = posData
	end
end)

local text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
text:SetFont(text:GetFont(), 14)
text:SetJustifyH("RIGHT")
text:SetShadowOffset(0, 0)

local function EnsureColors()
	if not db then return end
	db.profile.colors			= db.profile.colors				or {}
	db.profile.colors.ilvl		= db.profile.colors.ilvl		or {r=1,g=1,b=1}
	db.profile.colors.main		= db.profile.colors.main		or {r=0.46,g=0.76,b=0.77}
	db.profile.colors.crit		= db.profile.colors.crit		or {r=0.77,g=0.29,b=0.28}
	db.profile.colors.haste		= db.profile.colors.haste		or {r=0.34,g=0.77,b=0.40}
	db.profile.colors.mastery	= db.profile.colors.mastery		or {r=0.77,g=0.77,b=0.25}
	db.profile.colors.vers		= db.profile.colors.vers		or {r=0.32,g=0.42,b=0.77}
	db.profile.colors.leech		= db.profile.colors.leech		or {r=0.81,g=0.39,b=0.99}
	db.profile.colors.avoidance	= db.profile.colors.avoidance	or {r=0.99,g=0.62,b=0.19}
	db.profile.colors.speed		= db.profile.colors.speed		or {r=1, g=1, b=0.4 }
	db.profile.colors.block		= db.profile.colors.block		or {r=0.75,g=0.75,b=0.75}
	db.profile.colors.parry		= db.profile.colors.parry		or {r=0.65,g=0.85,b=0.85}
	db.profile.colors.dodge		= db.profile.colors.dodge		or {r=0.85,g=0.85,b=0.65}
	db.profile.colors.armor		= db.profile.colors.armor		or {r=0.6,g=0.6,b=0.9}
	db.profile.colors.bgColor	= db.profile.colors.bgColor		or {r=0,g=0,b=0}
	db.profile.colors.borderColor	= db.profile.colors.borderColor	or {r=1,g=1,b=1}
end

local inCombat = false
local restrictionActive = false
local loadedStatPosition = nil  -- 1=Strength, 2=Agility, 4=Intellect
local loadedStatName = nil

local function LoadMainStat()
	-- SPEICHERN: Vergleiche EINMAL beim Login/Spec-Wechsel
	local str = UnitStat("player", 1)
	local agi = UnitStat("player", 2)
	local int = UnitStat("player", 4)
	if str >= agi and str >= int then 
		loadedStatPosition = 1
		loadedStatName = L["Strength"]
	elseif agi >= int then 
		loadedStatPosition = 2
		loadedStatName = L["Agility"]
	else 
		loadedStatPosition = 4
		loadedStatName = L["Intellect"]
	end
end

local function GetMainStat()
	-- LADEN: Nutze NUR die gespeicherte Position, KEINE Vergleiche!
	if loadedStatPosition then
		return loadedStatName, UnitStat("player", loadedStatPosition)
	end
	return L["Unknown"], 0
end

local function GetItemLevel()
	local overall, equipped = GetAverageItemLevel()
	return equipped, overall
end

local function GetSecondaries()
	return {
		crit = { GetCombatRating(CR_CRIT_MELEE), GetCritChance() },
		haste = { GetCombatRating(CR_HASTE_MELEE), GetHaste() },
		mastery = { GetCombatRating(CR_MASTERY), GetMasteryEffect() },
		vers = { GetCombatRating(CR_VERSATILITY_DAMAGE_DONE), GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE), GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE) },
	}
end

local function GetTertiaries()
	return {
		leech = { GetCombatRating(CR_LIFESTEAL), GetLifesteal() },
		avoidance = { GetCombatRating(CR_AVOIDANCE), GetAvoidance() },
	}
end

local function GetDefensives()
	local _, effectiveArmor = UnitArmor("player")

	return {
		block = GetBlockChance(),
		parry = GetParryChance(),
		dodge = GetDodgeChance(),
		armor = {
			rating	= effectiveArmor,
			percent = 0
		}
	}
end

local function FormatNumber(val, isPercent)
	if not db then return tostring(val) end
	local decimals = db.profile.decimalPlaces or 0
	local fmt = "%." .. decimals .. "f"
	if isPercent then
		return string.format(fmt .. "%%", val)
	end
	return string.format(fmt, val)
end

local function FormatSecondary(statName, rating, percent)
	if not db then return "" end
	local fmt = db.profile.secondaryFormat
	if fmt == "NUMBER" then
		return string.format("%s: %d", statName, rating)
	elseif fmt == "PERCENT" then
		return string.format("%s: %s", statName, FormatNumber(percent, true))
	elseif fmt == "PERCENT_NUMBER" then
		return string.format("%s: %s - %d", statName, FormatNumber(percent, true), rating)
	else
		return string.format("%s: %d - %s", statName, rating, FormatNumber(percent, true))
	end
end

local lastVersatilityPercent = 0

local function FormatVersatility(rating, bonusPercent, versPercent)
	if not db then return "" end
	local displayPercent = lastVersatilityPercent  -- Fallback auf letzten Wert
	pcall(function()
		displayPercent = (bonusPercent or 0) + (versPercent or 0)
		lastVersatilityPercent = displayPercent  -- Speichere neuen Wert
	end)
	
	local versatilityDisplay = db.profile.versatilityDisplay or "VERS_ONLY"
	local mode = db.profile.secondaryFormat
	local decimals = db.profile.decimalPlaces or 0
	local percentFormat = "%." .. decimals .. "f%%"
	
	-- Berechne DR % (vers% durch 2)
	local drPercent = 0
	if versatilityDisplay == "VERS_DR" then
		drPercent = displayPercent / 2
	end
	
	if mode == "NUMBER" then
		return string.format("%s: %d", L["Versatility"], rating)
	elseif mode == "PERCENT" then
		if versatilityDisplay == "VERS_DR" then
			return string.format("%s: " .. percentFormat .. " / " .. percentFormat, L["Versatility"], displayPercent, drPercent)
		else
			return string.format("%s: " .. percentFormat, L["Versatility"], displayPercent)
		end
	elseif mode == "PERCENT_NUMBER" then
		if versatilityDisplay == "VERS_DR" then
			return string.format("%s: " .. percentFormat .. " / " .. percentFormat .. " - %d", L["Versatility"], displayPercent, drPercent, rating)
		else
			return string.format("%s: " .. percentFormat .. " - %d", L["Versatility"], displayPercent, rating)
		end
	else
		if versatilityDisplay == "VERS_DR" then
			return string.format("%s: %d - " .. percentFormat .. " / " .. percentFormat, L["Versatility"], rating, displayPercent, drPercent)
		else
			return string.format("%s: %d - " .. percentFormat, L["Versatility"], rating, displayPercent)
		end
	end
end

local function FormatTertiaries(statName, rating, percent)
	if not db then return "" end
	local fmt = db.profile.tertiariesFormat
	if fmt == "NUMBER" then
		return string.format("%s: %d", statName, rating)
	elseif fmt == "PERCENT" then
		return string.format("%s: %s", statName, FormatNumber(percent, true))
	elseif fmt == "PERCENT_NUMBER" then
		return string.format("%s: %s - %d", statName, FormatNumber(percent, true), rating)
	else
		return string.format("%s: %d - %s", statName, rating, FormatNumber(percent, true))
	end
end

local function FormatArmor(armorLabel, rating, percent)
	if not db then return "" end
	return string.format("%s: %d", armorLabel, rating)
end

local function GetSpeedText()
	if not db then return "0%" end
	
	local current, run = GetUnitSpeed("player")
	local cur = FormatNumber((current / 7) * 100, true)
	local sta = FormatNumber((run / 7) * 100, true)

	local fmt = db.profile.speedFormat or "CURRENT"

	if fmt == "CURRENT" then
		return cur
	elseif fmt == "STATIC" then
		return sta
	elseif fmt == "CURRENT_STATIC" then
		return cur .. " / " .. sta
	else
		return sta .. " / " .. cur
	end
end

local function GetStatLabel(key, defaultText)
	if not db or not db.profile.customStatText then
		return defaultText
	end

	local custom = db.profile.customStatText[key]
	if custom and custom:trim() ~= "" then
		return custom
	end

	return defaultText
end

local measureText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
measureText:Hide()
measureText:SetWordWrap(false)

local lastCalculatedWidth = 200

local function CalculateTextWidth(lines, fontPath, fontSize, outline)
	-- Nur out of combat berechnen
	if inCombat or restrictionActive then
		return lastCalculatedWidth
	end
	
	-- Out of combat: echte Berechnung - in pcall wegen möglicher taint
	local success = pcall(function()
		measureText:SetFont(fontPath, fontSize, outline)
		measureText:SetShadowOffset(0, 0)
		local maxWidth = 0
		for i = 1, #lines do
			if lines[i] then
				measureText:SetText(lines[i])
				local w = measureText:GetStringWidth() or 0
				maxWidth = math.max(maxWidth, w)
			end
		end
		local calculatedWidth = math.min(maxWidth + 2, 800)
		lastCalculatedWidth = calculatedWidth  -- Speichere für Combat
	end)
	
	if not success then
		return lastCalculatedWidth
	end
	return lastCalculatedWidth
end

local function GetPlayerSpecID()
	local spec = GetSpecialization()
	if spec then return GetSpecializationInfo(spec) end
end

local function ParseTokens(text)
	local tokens = {}
	if not text or text == "" then return tokens end

	for word in text:gmatch("%S+") do
		tokens[word] = true
	end
	return tokens
end

local function GetAvailableGlobalStats()
	if not db then return {} end
	local used = ParseTokens(db.profile.customGlobalStatText)
	local values = {}

	local stats = {
		Ilvl = L["Ilvl"],
		Main = L["Primary Stat"],
		Secondaries = L["Secondaries"],
		Leech = L["Leech"],
		Avoidance = L["Avoidance"],
		Speed = L["Speed"],
		Block = L["Block"],
		Parry = L["Parry"],
		Dodge = L["Dodge"],
		Armor = L["Armor"]
	}

	for key, localized in pairs(stats) do
		if not used[key] then
			values[key] = localized
		end
	end

	return values
end

local function ParseGlobalStatText(text)
	local order, seen = {}, {}

	for word in (text or ""):gmatch("%S+") do
		if (word == "Ilvl" or word == "Main" or word == "Secondaries" or word == "Leech" or word == "Avoidance" or word == "Speed" or word == "Block" or word == "Parry" or word == "Armor" or word == "Dodge")
		   and not seen[word] then
			table.insert(order, word)
			seen[word] = true
		end
	end

	if #order == 0 then
		order = {"Ilvl","Main","Secondaries","Leech","Avoidance","Speed","Armor","Block","Parry","Dodge"}
	end

	return order
end

local function GetAvailableSecondaries()
	if not db then return {} end
	local used = ParseTokens(db.profile.customSecondaryText)
	local values = {}

	local secondaries = {
		Crit	= L["Critical Strike"],
		Haste	= L["Haste"],
		Mastery = L["Mastery"],
		Vers	= L["Versatility"]
	}

	for key, localized in pairs(secondaries) do
		if not used[key] then
			values[key] = localized
		end
	end

	return values
end

local function ParseSecondaryText(text)
	local order = {}
	local seen = {}

	for word in (text or ""):gmatch("%S+") do
		if (word == "Crit" or word == "Haste" or word == "Mastery" or word == "Vers")
		   and not seen[word] then
			table.insert(order, word)
			seen[word] = true
		end
	end

	return (#order > 0) and order or {"Crit","Haste","Mastery","Vers"}
end

local function ApplyGlobalOrder(blocks)
	if not db then return {} end
	local result = {}
	local used = {}

	if db.profile.globalStatOrdering == "CUSTOM" then
		local order = ParseGlobalStatText(db.profile.customGlobalStatText)

		for _, key in ipairs(order) do
			if blocks[key] then
				for _, line in ipairs(blocks[key]) do
					table.insert(result, line)
				end
				used[key] = true
			end
		end
	end

	for _, key in ipairs({"Ilvl","Main","Secondaries","Leech","Avoidance","Speed","Armor","Block","Parry","Dodge"}) do
		if not used[key] and blocks[key] then
			for _, line in ipairs(blocks[key]) do
				table.insert(result, line)
			end
		end
	end

	return result
end

local function SortSecondaries(secondaries)
	if not db then return end
	local orderType = db.profile.secondaryOrdering or "PRIO"
	local priority

	if orderType == "PRIO" then
		local specID = GetPlayerSpecID()
		local specData = SpecPriorityByID and SpecPriorityByID[specID]
		if type(specData) == "table" and specData.default then
			local heroSpecID = C_ClassTalents.GetActiveHeroTalentSpec()
			if heroSpecID and specData.heroTalents and specData.heroTalents[heroSpecID] then
				priority = specData.heroTalents[heroSpecID]
			else
				priority = specData.default
			end
		else
			priority = specData or {"Crit","Haste","Mastery","Vers"}
		end
	elseif orderType == "CUSTOM" then
		priority = ParseSecondaryText(db.profile.customSecondaryText)
	end

	local index = {}
	for i=1,#priority do index[priority[i]] = i end
	table.sort(secondaries, function(a,b) return (index[a.key] or 99) < (index[b.key] or 99) end)
end

local function Colorize(c, txt)
	return string.format("|cff%02x%02x%02x%s|r", c.r * 255, c.g * 255, c.b * 255, txt)
end

local function UpdateVisibility()
	if not db then return end
	local mode = db.profile.showStatsMode or "ALWAYS"

	if mode == "ALWAYS" then
		f:Show()
	elseif mode == "IN_COMBAT" then
		if InCombatLockdown() then
			f:Show()
		else
			f:Hide()
		end
	elseif mode == "OUT_OF_COMBAT" then
		if InCombatLockdown() then
			f:Hide()
		else
			f:Show()
		end
	end
end

local lastSpeedValue = nil	
local speedLineIndex = nil
local speedTimer = 0

local function SpeedOnUpdate(self, elapsed)
	speedTimer = speedTimer + elapsed
	local interval = (db and db.global.updateInterval) or 0.35
	if speedTimer < interval then return end
	speedTimer = 0

	if speedLineIndex and db and db.profile.showSpeed then
		local speedText = GetSpeedText() 
		if speedText == lastSpeedValue then return end
		lastSpeedValue = speedText

		local speedLabel = GetStatLabel("Speed", L["Speed"])
		local coloredLine = Colorize(db.profile.colors.speed, speedLabel .. ": " .. speedText)
		
		local oldText = text:GetText()
		if not oldText then return end
		
		if db.profile.oneLineLayout then
			local start, end_pos
			pcall(function()
				start, end_pos = oldText:find(speedLabel .. ":[^|]*")
			end)
			if start then
				local before = oldText:sub(1, start - 1)
				local after = oldText:sub(end_pos + 1)
				text:SetText(before .. speedLabel .. ": " .. speedText .. after)
			end
		else
			local lines = {strsplit("\n", oldText)}
			for i, line in ipairs(lines) do
				local found = false
				pcall(function()
					found = line:find(speedLabel) ~= nil
				end)
				if found then
					lines[i] = coloredLine
					break
				end
			end
			text:SetText(table.concat(lines, "\n"))
		end
	end
end

local function UpdateSpeedState()
	if not db then return end
	if db.profile.showSpeed then
		f:SetScript("OnUpdate", SpeedOnUpdate)
	else
		f:SetScript("OnUpdate", nil)
		speedLineIndex = nil
	end
end

local function IsTankSpec()
	local playerSpecID = GetPlayerSpecID()
	
	if not playerSpecID then 
		return false 
	end
	
	local specName, _, _, _, role = GetSpecializationInfoByID(playerSpecID)
	local isTank = role == "TANK"
	
	return isTank
end

local reusableSecondaries = {
	{key="Crit"},
	{key="Haste"},
	{key="Mastery"},
	{key="Vers"},
}

local function GatherStats()
	local statName, statValue = GetMainStat()
	local ilvlEquipped, ilvlOverall = GetItemLevel()
	local s = GetSecondaries()
	local t = GetTertiaries()
	local d = GetDefensives()

	for i, sec in ipairs(reusableSecondaries) do
		if sec.key == "Crit" then
			sec.name = GetStatLabel("Crit", L["Critical Strike"])
			sec.rating = s.crit[1]
			sec.percent = s.crit[2]
			sec.color = db.profile.colors.crit
		elseif sec.key == "Haste" then
			sec.name = GetStatLabel("Haste", L["Haste"])
			sec.rating = s.haste[1]
			sec.percent = s.haste[2]
			sec.color = db.profile.colors.haste
		elseif sec.key == "Mastery" then
			sec.name = GetStatLabel("Mastery", L["Mastery"])
			sec.rating = s.mastery[1]
			sec.percent = s.mastery[2]
			sec.color = db.profile.colors.mastery
		elseif sec.key == "Vers" then
			sec.name = GetStatLabel("Vers", L["Versatility"])
			sec.rating = s.vers[1]
			sec.percent = s.vers[2]
			sec.percent2 = s.vers[3]
			sec.color = db.profile.colors.vers
		end
	end
	
	local tertiaries = {
		{key="Leech", name=GetStatLabel("Leech", L["Leech"]),		rating=t.leech[1], percent=t.leech[2], color=db.profile.colors.leech},
		{key="Avoidance", name=GetStatLabel("Avoidance", L["Avoidance"]),	rating=t.avoidance[1], percent=t.avoidance[2], color=db.profile.colors.avoidance},
	}
	
	local defensives = {
		{ key="Block", name=L["Block"],	rating=d.block, color=db.profile.colors.block },
		{ key="Parry", name=L["Parry"],	rating=d.parry, color=db.profile.colors.parry },
		{ key="Dodge", name=L["Dodge"],	rating=d.dodge, color=db.profile.colors.dodge },
		{ key="Armor", name=L["Armor"],	rating=d.armor.rating, percent=d.armor.percent, color=db.profile.colors.armor},
	}
	SortSecondaries(reusableSecondaries)

	return statName, statValue, ilvlEquipped, ilvlOverall, reusableSecondaries, tertiaries, defensives
end

local function BuildText(statName, statValue, ilvlEquipped, ilvlOverall, secondaries, tertiaries, defensives)
	local rawLines = {}
	local textLines = {}
	local speedIndex = nil
	local blocks = {}
	local class = select(2, UnitClass("player"))
	local relevantDefensives = {}
	if IsTankSpec() then
		relevantDefensives = {
			DEATHKNIGHT	= {parry=true},
			PALADIN		= {block=true, parry=true},
			DRUID		= {dodge=true},
			MONK		= {dodge=true},
			WARRIOR		= {block=true, parry=true},
			DEMONHUNTER	= {parry=true},
		}
	end
	
	local function ShowDefensive(statKey, dbKey)
		if tempPreview[statKey:lower()] then
			return true
		end

		if not db.profile[dbKey] then
			return false
		end

		if db.profile.autoHideIrrelevantDefensives then
			local allowed = relevantDefensives[class] or {}
			return allowed[statKey:lower()] ~= nil
		end
		
		return true
	end
	
	local function PushBlock(key, raw, colored)
		blocks[key] = blocks[key] or {}
		table.insert(blocks[key], colored)
		table.insert(rawLines, raw)
	end
	
	if not defensives then
		defensives = GetDefensives()
	end
	
	if db.profile.showItemLevel or tempPreview.ilvl then
		local ilvlText
		local ilvlLabel = GetStatLabel("Ilvl", L["Ilvl"])
		if db.profile.itemlevelDisplay == "Equipped" then
			ilvlText = string.format("%s: %s", ilvlLabel, FormatNumber(ilvlEquipped, false))
		elseif db.profile.itemlevelDisplay == "Auto" then
			if math.abs(ilvlEquipped - ilvlOverall) < 0.01 then
				ilvlText = string.format("%s: %s", ilvlLabel, FormatNumber(ilvlEquipped, false))
			else
				ilvlText = string.format("%s: %s / %s", ilvlLabel, FormatNumber(ilvlEquipped, false), FormatNumber(ilvlOverall, false))
			end
		else
			ilvlText = string.format("%s: %s / %s", ilvlLabel, FormatNumber(ilvlEquipped, false), FormatNumber(ilvlOverall, false))
		end
		PushBlock("Ilvl", ilvlText, Colorize(db.profile.colors.ilvl, ilvlText))
	end
	
	if db.profile.showMainStat or tempPreview.main then
		local mainLabel = GetStatLabel("Main", statName)
		local line = string.format("%s: %d", mainLabel, statValue)
		PushBlock("Main", line, Colorize(db.profile.colors.main, line))
	end

	if db.profile.showSecondaries or tempPreview.secondaries then
		for _, sec in ipairs(secondaries) do
			local line
			if sec.name ~= L["Versatility"] then
				line = FormatSecondary(sec.name, sec.rating, sec.percent)
			else
				line = FormatVersatility(
					sec.rating,
					sec.percent,
					sec.percent2
				)
			end

			blocks.Secondaries = blocks.Secondaries or {}
			table.insert(blocks.Secondaries, Colorize(sec.color, line))
			table.insert(rawLines, line)
		end
	end

	for _, ter in ipairs(tertiaries or {}) do
		if ter.key == "Leech" and (db.profile.showLeech or tempPreview.leech) then
			local line = FormatTertiaries(ter.name, ter.rating, ter.percent)
			PushBlock("Leech", line, Colorize(ter.color, line))

		elseif ter.key == "Avoidance" and (db.profile.showAvoidance or tempPreview.avoidance) then
			local line = FormatTertiaries(ter.name, ter.rating, ter.percent)
			PushBlock("Avoidance", line, Colorize(ter.color, line))
		end
	end

	if db.profile.showSpeed or tempPreview.speed then
		local speedLabel = GetStatLabel("Speed", L["Speed"])
		local speedText = speedLabel .. ": " .. GetSpeedText()
		blocks.Speed = blocks.Speed or {}
		table.insert(blocks.Speed, Colorize(db.profile.colors.speed, speedText))
		table.insert(rawLines, speedText)
	end
	
	if ShowDefensive("Block", "showBlock") then
		local blockLabel = GetStatLabel("Block", L["Block"])
		local line = string.format("%s: %s", blockLabel, FormatNumber(defensives.block, true))
		PushBlock("Block", line, Colorize(db.profile.colors.block, line))
	elseif tempPreview.block then
		local blockLabel = GetStatLabel("Block", L["Block"])
		local line = string.format("%s: %s", blockLabel, FormatNumber(defensives.block, true))
		PushBlock("Block", line, Colorize(db.profile.colors.block, line))
	end

	if ShowDefensive("Parry", "showParry") then
		local parryLabel = GetStatLabel("Parry", L["Parry"])
		local line = string.format("%s: %s", parryLabel, FormatNumber(defensives.parry, true))
		PushBlock("Parry", line, Colorize(db.profile.colors.parry, line))
	elseif tempPreview.parry then
		local parryLabel = GetStatLabel("Parry", L["Parry"])
		local line = string.format("%s: %s", parryLabel, FormatNumber(defensives.parry, true))
		PushBlock("Parry", line, Colorize(db.profile.colors.parry, line))
	end

	if ShowDefensive("Dodge", "showDodge") then
		local dodgeLabel = GetStatLabel("Dodge", L["Dodge"])
		local line = string.format("%s: %s", dodgeLabel, FormatNumber(defensives.dodge, true))
		PushBlock("Dodge", line, Colorize(db.profile.colors.dodge, line))
	elseif tempPreview.dodge then
		local dodgeLabel = GetStatLabel("Dodge", L["Dodge"])
		local line = string.format("%s: %s", dodgeLabel, FormatNumber(defensives.dodge, true))
		PushBlock("Dodge", line, Colorize(db.profile.colors.dodge, line))
	end
	
	if db.profile.showArmor or tempPreview.armor then
		local armorLabel = GetStatLabel("Armor", L["Armor"])
		local line = FormatArmor(armorLabel, defensives.armor.rating, defensives.armor.percent)
		PushBlock("Armor", line, Colorize(db.profile.colors.armor, line))
	end
	
	textLines = ApplyGlobalOrder(blocks)

	for i, line in ipairs(textLines) do
		local speedLabel = GetStatLabel("Speed", L["Speed"])
		local found = false
		pcall(function()
			found = line:find(speedLabel) ~= nil
		end)
		if found then
			speedIndex = i
			break
		end
	end

	return rawLines, textLines, speedIndex
end

local function ApplyLayout(rawLines, textLines)
	if not db then return end
	local spacing = db.profile.spacing or 5

	local outline = db.profile.outline and "OUTLINE" or nil
	local fontPath = LSM:Fetch("font", db.profile.fontName or "GameFontNormal")
	text:SetFont(fontPath, db.profile.fontSize or 14, outline)
	text:SetShadowOffset(0, 0)

	if text.SetSpacing then
		text:SetSpacing(spacing)
	end

	text:SetText("")

	if db.profile.oneLineLayout then
		local separator = string.rep(" ", 1) .. "|" .. string.rep(" ", 1)
		
		-- Filter nil values für table.concat
		local finalText = ""
		local isFirst = true
		for i = 1, #textLines do
			if textLines[i] then
				if not isFirst then
					finalText = finalText .. separator
				end
				finalText = finalText .. textLines[i]
				isFirst = false
			end
		end
		text:SetText(finalText)

		measureText:SetFont(fontPath, db.profile.fontSize, outline)
		measureText:SetText(finalText)
		local w = measureText:GetStringWidth() + 14
		if db.profile.showSpeed then
			local speedLabel = GetStatLabel("Speed", L["Speed"])
			local maxSpeedNum = FormatNumber(100, true)
			local maxSpeedText = speedLabel .. ": " .. maxSpeedNum .. " / " .. maxSpeedNum
			measureText:SetText(maxSpeedText)
			local maxSpeedWidth = measureText:GetStringWidth()
			w = math.max(w, maxSpeedWidth) + 14
		end
		f:SetWidth(w)
		text:SetWidth(w)
		f:SetHeight(db.profile.fontSize or 14 + 4)

		text:ClearAllPoints()
		text:SetPoint("TOP", f, "TOP", 0, 0)
		text:SetJustifyH("Left")
	else
		local maxWidth = CalculateTextWidth(rawLines, fontPath, db.profile.fontSize or 14, outline)

		if db.profile.showSpeed then
			local speedLabel = GetStatLabel("Speed", L["Speed"])
			local speedFormat = db.profile.speedFormat or "CURRENT"

			local maxSpeedNum = FormatNumber(100, true)
			local maxSpeedText = speedLabel .. ": " .. maxSpeedNum .. " / " .. maxSpeedNum

			local coloredSpeedText = Colorize(db.profile.colors.speed, maxSpeedText)
			
			measureText:SetFont(fontPath, db.profile.fontSize or 14, outline)
			measureText:SetText(coloredSpeedText)
			local speedWidth = measureText:GetStringWidth() + 4
			maxWidth = math.max(maxWidth, speedWidth)
		end
		
		maxWidth = math.floor(maxWidth + 0.5)

		text:SetWidth(maxWidth)
		f:SetWidth(maxWidth)

		-- Filter nil values für table.concat
		local finalText = ""
		local isFirst = true
		for i = 1, #textLines do
			if textLines[i] then
				if not isFirst then
					finalText = finalText .. "\n"
				end
				finalText = finalText .. textLines[i]
				isFirst = false
			end
		end
		text:SetText(finalText)
		text:SetJustifyH(db.profile.align)

		text:ClearAllPoints()
		if db.profile.align == "RIGHT" then
			text:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
		elseif db.profile.align == "CENTER" then
			text:SetPoint("TOP", f, "TOP", 0, 0)
		else
			text:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
		end

		local lineCount = #textLines
		local lineHeight = (db.profile.fontSize or 14)
		f:SetHeight(lineCount * lineHeight + (lineCount - 1) * spacing)
	end

	f.bg:SetAllPoints(f)
	f.bgTexture:SetAllPoints(f)

	if db.profile.useBackground then
		EnsureColors()
		local bgColor = db.profile.colors.bgColor or { r = 0, g = 0, b = 0 }
		local opacity = db.profile.backgroundOpacity or 0.7
		local bgUp = db.profile.backgroundExtendUp or 0
		local bgRight = db.profile.backgroundExtendRight or 0
		local bgDown = db.profile.backgroundExtendDown or 0
		local bgLeft = db.profile.backgroundExtendLeft or 0

		if db.profile.backgroundTexture and db.profile.backgroundTexture ~= "Solid Color Black" then
			local texturePath = LSM:Fetch("background", db.profile.backgroundTexture)
			if texturePath then
				f.bgTexture:SetTexture(texturePath)
				f.bgTexture:SetAlpha(opacity)
				f.bgTexture:Show()
			else
				f.bgTexture:Hide()
			end
		else
			f.bgTexture:Hide()
		end

		f.bg:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, opacity)
		f.bg:Show()

		f.bg:SetPoint("TOPLEFT", f, "TOPLEFT", -bgLeft, bgUp)
		f.bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", bgRight, -bgDown)
		f.bgTexture:SetPoint("TOPLEFT", f, "TOPLEFT", -bgLeft, bgUp)
		f.bgTexture:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", bgRight, -bgDown)
	else
		f.bg:Hide()
		f.bgTexture:Hide()
	end

	local borderSize = db.profile.borderSize or 8
	if borderSize > 0 and db.profile.useBackgroundBorder then
		local borderFile = LSM:Fetch("border", db.profile.borderStyle or "Tooltip")
		local borderOffset = db.profile.borderOffset or 0
		local borderOpacity = db.profile.borderOpacity or 1

		local bgUp = db.profile.backgroundExtendUp or 0
		local bgRight = db.profile.backgroundExtendRight or 0
		local bgDown = db.profile.backgroundExtendDown or 0
		local bgLeft = db.profile.backgroundExtendLeft or 0

		f.borderFrame:SetPoint("TOPLEFT", f, "TOPLEFT", -bgLeft - borderOffset, bgUp + borderOffset)
		f.borderFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", bgRight + borderOffset, -bgDown - borderOffset)
		
		f.borderFrame:SetBackdrop({
			edgeFile = borderFile,
			edgeSize = borderSize,
		})
		local borderColor = db.profile.colors.borderColor or { r = 1, g = 1, b = 1 }
		f.borderFrame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderOpacity)
		f.borderFrame:Show()
	else
		f.borderFrame:Hide()
	end

	if not db.profile.locked then
		f.bg:Hide()
		f.bgTexture:Hide()
		f:SetBackdrop(nil)
	end

	if not db.profile.locked then
		EnsureColors()
		local bgColor = db.profile.colors.bgColor or { r = 0, g = 0, b = 0 }
		local opacity = db.profile.backgroundOpacity or 0.7
		local bgUp = db.profile.backgroundExtendUp or 0
		local bgRight = db.profile.backgroundExtendRight or 0
		local bgDown = db.profile.backgroundExtendDown or 0
		local bgLeft = db.profile.backgroundExtendLeft or 0

		if db.profile.useBackground then
			if db.profile.backgroundTexture and db.profile.backgroundTexture ~= "Solid Color Black" then
				local texturePath = LSM:Fetch("background", db.profile.backgroundTexture)
				if texturePath then
					f.bgTexture:SetTexture(texturePath)
					f.bgTexture:SetAlpha(opacity)
					f.bgTexture:Show()
				else
					f.bgTexture:Hide()
				end
			else
				f.bgTexture:Hide()
			end
		else
			f.bgTexture:Hide()
		end

		local displayColor = db.profile.useBackground and bgColor or { r = 0, g = 0, b = 0 }
		local displayOpacity = db.profile.useBackground and opacity or 0.7
		f.bg:SetColorTexture(displayColor.r, displayColor.g, displayColor.b, displayOpacity)
		f.bg:ClearAllPoints()
		f.bg:SetPoint("TOPLEFT", f, "TOPLEFT", -bgLeft, bgUp)
		f.bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", bgRight, -bgDown)
		f.bgTexture:ClearAllPoints()
		f.bgTexture:SetPoint("TOPLEFT", f, "TOPLEFT", -bgLeft, bgUp)
		f.bgTexture:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", bgRight, -bgDown)
		f.bg:Show()

		if not f.bgText then
			f.bgText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			f.bgText:SetTextColor(1, 1, 1, 1)
			f.bgText:SetFont(f.bgText:GetFont() or "GameFontNormal", 16, outline)
		end

		local bgUp = db.profile.backgroundExtendUp or 0
		f.bgText:ClearAllPoints()
		f.bgText:SetPoint("BOTTOM", f, "TOP", 0, bgUp + 5)

		local positionStateText = db.profile.useGlobalPosition and L["Global Position"] or L["Profile Position"]
		local positionStateColor = db.profile.useGlobalPosition and "|cff0070dd" or "|cffffff00"
		f.bgText:SetText(positionStateColor .. positionStateText .. "|r\n" .. L["Drag to move"])
		f.bgText:Show()
	else
		if db.profile.useBackground then
			EnsureColors()
			local bgColor = db.profile.colors.bgColor or { r = 0, g = 0, b = 0 }
			local opacity = db.profile.backgroundOpacity or 0.7
			local bgUp = db.profile.backgroundExtendUp or 0
			local bgRight = db.profile.backgroundExtendRight or 0
			local bgDown = db.profile.backgroundExtendDown or 0
			local bgLeft = db.profile.backgroundExtendLeft or 0

			if db.profile.backgroundTexture and db.profile.backgroundTexture ~= "Solid Color Black" then
				local texturePath = LSM:Fetch("background", db.profile.backgroundTexture)
				if texturePath then
					f.bgTexture:SetTexture(texturePath)
					f.bgTexture:SetAlpha(opacity)
					f.bgTexture:Show()
				else
					f.bgTexture:Hide()
				end
			else
				f.bgTexture:Hide()
			end

			f.bg:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, opacity)
			f.bg:Show()

			f.bg:SetPoint("TOPLEFT", f, "TOPLEFT", -bgLeft, bgUp)
			f.bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", bgRight, -bgDown)
			f.bgTexture:SetPoint("TOPLEFT", f, "TOPLEFT", -bgLeft, bgUp)
			f.bgTexture:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", bgRight, -bgDown)
		else
			f.bg:Hide()
			f.bgTexture:Hide()
		end
		
		if f.bgText then
			f.bgText:Hide()
		end
	end

end

local function Update()
	if not db then return end
	EnsureColors()
	local statName, statValue, ilvlEquipped, ilvlOverall, secondaries, tertiaries = GatherStats()
	local rawLines, textLines, idx = BuildText(statName, statValue, ilvlEquipped, ilvlOverall, secondaries, tertiaries)

	speedLineIndex = idx
	ApplyLayout(rawLines, textLines)
end

local function UpdateChangedStats()
	if not db then return end
	Update()
end

local pendingUpdate = false
local function ScheduleUpdate()
	if pendingUpdate then
		return
	end
	
	pendingUpdate = true
	C_Timer.After(0.1, function()
		UpdateChangedStats()
		pendingUpdate = false
	end)
end

local function OpenColorPicker(statKey, button, allColors, aceFrame)
	if not db then return end
	EnsureColors()
	local restoreKey = false
	
	if not allColors and statKey then
		if statKey == "leech" or statKey == "avoidance" then
			if db.profile.autoHideTertiaries or not db.profile["show" .. statKey:gsub("^%l", string.upper)] then
				tempPreview[statKey] = true
				restoreKey = true
				Update()
			end
		elseif statKey == "block" or statKey == "parry" or statKey == "dodge" then
			if db.profile.autoHideIrrelevantDefensives or not db.profile["show" .. statKey:gsub("^%l", string.upper)] then
				tempPreview[statKey] = true
				restoreKey = true
				Update()
			end
		elseif not db.profile["show" .. statKey:gsub("^%l", string.upper)] then
			tempPreview[statKey] = true
			restoreKey = true
			Update()
		end
	end

	local c = db.profile.colors[statKey]
	if not c then return end

	local activeBtn = button
	local frameRef = aceFrame

	local allColorsPrev
	if allColors then
		allColorsPrev = {}
		for k,v in pairs(db.profile.colors) do
			allColorsPrev[k] = { r=v.r, g=v.g, b=v.b }
		end
	end

	local info = {
		r = c.r, g = c.g, b = c.b,
		hasOpacity = false,

		swatchFunc = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			if allColors then
				local statColorKeys = {"ilvl", "main", "crit", "haste", "mastery", "vers", "leech", "avoidance", "speed", "armor", "block", "parry", "dodge"}
				for _, k in ipairs(statColorKeys) do
					if db.profile.colors[k] then
						db.profile.colors[k].r, db.profile.colors[k].g, db.profile.colors[k].b = r, g, b
						if frameRef and frameRef.colorBoxes and frameRef.colorBoxes[k] then
							frameRef.colorBoxes[k]:SetBackdropColor(r,g,b,1)
						end
					end
				end
			else
				local v = db.profile.colors[statKey]
				v.r, v.g, v.b = r, g, b
				if activeBtn then
					activeBtn:SetBackdropColor(r,g,b,1)
				end
			end
			Update()
		end,

		cancelFunc = function(prev)
			if allColors and allColorsPrev then
				local statColorKeys = {"ilvl", "main", "crit", "haste", "mastery", "vers", "leech", "avoidance", "speed", "armor", "block", "parry", "dodge"}
				for _, k in ipairs(statColorKeys) do
					if allColorsPrev[k] then
						local v = allColorsPrev[k]
						db.profile.colors[k].r = v.r
						db.profile.colors[k].g = v.g
						db.profile.colors[k].b = v.b
						if frameRef and frameRef.colorBoxes and frameRef.colorBoxes[k] then
							frameRef.colorBoxes[k]:SetBackdropColor(v.r,v.g,v.b,1)
						end
					end
				end
			else
				c.r, c.g, c.b = prev.r, prev.g, prev.b
				if activeBtn then
					activeBtn:SetBackdropColor(prev.r,prev.g,prev.b,1)
				end
			end
			Update()
		end,
	}
	ColorPickerFrame:HookScript("OnHide", function()
		if restoreKey then
			tempPreview[statKey] = nil
			Update()
		end
	end)

	ColorPickerFrame:SetupColorPickerAndShow(info)
end

local AceFrame

local function OpenAceOptions()
	if not db then return end
	ColorPickerFrame:SetFrameStrata("TOOLTIP")
	if AceFrame then
		AceFrame:Show()
		return
	end

	AceFrame = AceGUI:Create("Frame")
	local optionsFrame = AceFrame.frame
	AceFrame.frame:SetResizable(true)
	AceFrame:SetTitle(L["Stats Settings /stats /st"])
	AceFrame:SetStatusText(CURRENT_VERSION)
	AceFrame:SetLayout("Flow")
	AceFrame:SetWidth(800)
	AceFrame:SetHeight(690)
	--[[FrameSizeDebug
	AceFrame.frame:HookScript("OnSizeChanged", function(self, width, height)
		print(string.format("AceGUI Fenster Größe: %.0f x %.0f", width, height))
	end)]]
	
	local function AddSeparator(content, text)
		local header = AceGUI:Create("Heading")
		header:SetText(text or "")
		header:SetFullWidth(true)
		content:AddChild(header)
	end

	local function ClearTooltip(widget)
		if not widget or not widget.frame then return end
		widget.frame:SetScript("OnEnter", nil)
		widget.frame:SetScript("OnLeave", nil)
	end

	local function SetSimpleTooltip(widget, text)
		if not widget or not widget.frame then return end

		widget.frame:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
			GameTooltip:SetText(text, 1, 1, 1, 1, true)
			GameTooltip:Show()
		end)

		widget.frame:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
	end

	function DrawGeneralTab(content)
		local scroll = AceGUI:Create("ScrollFrame")
		scroll:SetFullWidth(true)
		scroll:SetFullHeight(true)
		scroll:SetLayout("Flow")
		content:AddChild(scroll)
		
		local scrollContent = scroll
		
		local function AddCheckbox(label, getValue, setValue)
			local cb = AceGUI:Create("CheckBox")
			cb:SetLabel(label)
			cb:SetValue(getValue())
			cb:SetWidth(240)
			cb:SetCallback("OnValueChanged", function(_, _, val)
				setValue(val)
				Update()
			end)
			scrollContent:AddChild(cb)
			ClearTooltip(cb)
			return cb
		end
		
		local function AddSlider(label, min, max, step, getValue, setValue)
			local s = AceGUI:Create("Slider")
			s:SetLabel(label)
			s:SetSliderValues(min, max, step)
			s:SetValue(getValue())
			s:SetWidth(240)
			s:SetCallback("OnValueChanged", function(_, _, val)
				setValue(math.floor(val))
				Update()
			end)
			scrollContent:AddChild(s)
			ClearTooltip(s)
			return s
		end
		
		local function AddDropdown(label, values, getValue, setValue, order)
			local dd = AceGUI:Create("Dropdown")
			dd:SetLabel(label)
			if order then
				dd:SetList(values, order)
			else
				dd:SetList(values)
			end
			dd:SetValue(getValue())
			dd:SetWidth(240)
			dd:SetCallback("OnValueChanged", function(_, _, val)
				setValue(val)
				Update()
			end)
			
			if dd.label then
				dd.label:ClearAllPoints()
				dd.label:SetPoint("TOPLEFT", dd.frame, "TOPLEFT", 2, 1)
			end
			ClearTooltip(dd)
			scrollContent:AddChild(dd)
		end
		
		local lockCheckbox
		lockCheckbox = AddCheckbox(L["Lock Frame Position"], function() return db.profile.locked end,
			function(val)
				db.profile.locked = val
				ApplyLockState()
				if val then
					lockCheckbox:SetLabel(L["Lock Frame Position"])
				else
					lockCheckbox:SetLabel("|cffff0000" .. L["Lock Frame Position"] .. "|r")
				end
				Update()
			end
		)
		lockCheckboxRef = lockCheckbox
		
		AddCheckbox(L["Font Outline"], function() return db.profile.outline end, function(val) db.profile.outline = val end)
		AddCheckbox(L["Use One Line Layout"], function() return db.profile.oneLineLayout end, function(val) db.profile.oneLineLayout = val end)
		
		AddCheckbox(L["Show Minimap Button"], function() return not db.profile.minimap.hide end,
			function(val) db.profile.minimap.hide = not val
				if val then LDBIcon:Show("StatsPlus") else LDBIcon:Hide("StatsPlus") end
			end
		)
		 
		AddCheckbox(L["Use Global Position"], function() return db.profile.useGlobalPosition end, 
			function(val) 
				db.profile.useGlobalPosition = val
				f:ClearAllPoints()
				local posSource = val and db.global.pos or db.profile.pos
				local pos = posSource or { point="CENTER", relativeTo="UIParent", relativePoint="CENTER", x=0, y=0 }
				local relative = _G[pos.relativeTo] or UIParent
				f:SetPoint(pos.point, relative, pos.relativePoint, pos.x, pos.y)
				if f.bgText and not db.profile.locked then
					local positionStateText = val and L["Global Position"] or L["Profile Position"]
					local positionStateColor = val and "|cff0070dd" or "|cffffff00"
					f.bgText:SetText(positionStateColor .. positionStateText .. "|r\n" .. L["Drag to move"])
				end
				Update()
			end
		)

		AddSeparator(scrollContent, "")
		AddCheckbox(L["Show Item Level"], function() return db.profile.showItemLevel end, function(val) db.profile.showItemLevel = val end)
		AddCheckbox(L["Show Primary Stat"], function() return db.profile.showMainStat end, function(val) db.profile.showMainStat = val end)
		AddCheckbox(L["Show Secondaries"], function() return db.profile.showSecondaries end, function(val) db.profile.showSecondaries = val end)
		AddCheckbox(L["Show Leech"], function() return db.profile.showLeech end, function(val) db.profile.showLeech = val end)
		AddCheckbox(L["Show Avoidance"], function() return db.profile.showAvoidance end, function(val) db.profile.showAvoidance = val end)
		local speedCheckbox = AddCheckbox(L["Show Speed"], function() return db.profile.showSpeed end, function(val) db.profile.showSpeed = val; UpdateSpeedState() end)
		SetSimpleTooltip(speedCheckbox, "|cFFFF0000" .. L["SpeedTooltip"] .. "|r")

		AddSeparator(scrollContent, "")
		
		AddCheckbox(L["Show Block"], function() return db.profile.showBlock end, function(val) db.profile.showBlock = val end)
		AddCheckbox(L["Show Parry"], function() return db.profile.showParry end, function(val) db.profile.showParry = val end)
		AddCheckbox(L["Show Dodge"], function() return db.profile.showDodge end, function(val) db.profile.showDodge = val end)
		AddCheckbox(L["Show Armor"], function() return db.profile.showArmor end, function(val) db.profile.showArmor = val end)
		local autoHideTankStatsCheckbox = AddCheckbox(L["Auto Hide Tank Stats"], function() return db.profile.autoHideIrrelevantDefensives end, function(val) db.profile.autoHideIrrelevantDefensives = val end)
		SetSimpleTooltip(autoHideTankStatsCheckbox, "|cFF006FA0" .. L["Auto Hide Tank Stats TOOLTIP"] .. "|r")

		AddSeparator(scrollContent, "")

		AddSlider(L["Font Size"], 8, 40, 1, function() return db.profile.fontSize or 14 end, function(val) db.profile.fontSize = val end)
		AddSlider(L["Line Spacing"], 0, 20, 1, function() return db.profile.spacing or 3 end, function(val) db.profile.spacing = val end)
		AddSlider(L["Decimal Places"], 0, 3, 1, function() return db.profile.decimalPlaces or 2 end, function(val) db.profile.decimalPlaces = val end)
		
		AddSeparator(scrollContent, "")

		fontDD = AceGUI:Create("LSM30_Font")
		fontDD:SetLabel(L["Font Family"])
		fontDD:SetList(LSM:HashTable("font"))
		fontDD:SetValue(db.profile.fontName or "GameFontNormal")
		fontDD:SetWidth(240)
		fontDD:SetCallback("OnValueChanged", function(_, _, val)
			db.profile.fontName = val
			fontDD:SetValue(val)
			C_Timer.After(0.1, Update)
		end)
		scrollContent:AddChild(fontDD)
		
		AddDropdown(L["Text Alignment"], {LEFT=L["Left"], CENTER=L["Center"], RIGHT=L["Right"]},
			function() return db.profile.align end, function(val) db.profile.align = val end, {"LEFT", "CENTER", "RIGHT"})

		AddDropdown(L["Visibility"], {ALWAYS = L["Always"], IN_COMBAT = L["In Combat"], OUT_OF_COMBAT = L["Out of Combat"]}, 
			function() return db.profile.showStatsMode or "ALWAYS" end, function(val) db.profile.showStatsMode = val; UpdateVisibility() end, {"ALWAYS", "IN_COMBAT", "OUT_OF_COMBAT"})
		
		AddDropdown(L["Item Level Format"], {Auto=L["Auto (show both if different)"], EquippedInventory =L["Equipped + Inventory"], Equipped=L["Equipped Only"]}, 
			function() return db.profile.itemlevelDisplay end, function(val) db.profile.itemlevelDisplay = val end, {"Auto", "Equipped", "EquippedInventory"})

		local versatilityDropdown
		AddDropdown(L["Secondary Stat Format"], {NUMBER_PERCENT=L["Rating + Percentage"], PERCENT_NUMBER=L["Percentage + Rating"], NUMBER=L["Rating Only"], PERCENT=L["Percentage Only"]}, 
			function() return db.profile.secondaryFormat end, 
			function(val) 
				db.profile.secondaryFormat = val
				if versatilityDropdown then
					versatilityDropdown:SetDisabled(val == "NUMBER")
				end
			end, 
			{"NUMBER", "PERCENT", "NUMBER_PERCENT","PERCENT_NUMBER"})

		versatilityDropdown = AceGUI:Create("Dropdown")
		versatilityDropdown:SetLabel(L["Versatility Format"])
		versatilityDropdown:SetList({VERS_ONLY=L["Versatility Only"], VERS_DR=L["Versatility + Damage Reduction"]})
		versatilityDropdown:SetValue(db.profile.versatilityDisplay)
		versatilityDropdown:SetWidth(240)
		versatilityDropdown:SetDisabled(db.profile.secondaryFormat == "NUMBER")
		versatilityDropdown:SetCallback("OnValueChanged", function(_, _, val)
			db.profile.versatilityDisplay = val
			Update()
		end)
		scrollContent:AddChild(versatilityDropdown)

		AddDropdown(L["Tertiary Format"], {NUMBER_PERCENT=L["Rating + Percentage"], PERCENT_NUMBER=L["Percentage + Rating"], NUMBER=L["Rating Only"], PERCENT=L["Percentage Only"]}, 
			function() return db.profile.tertiariesFormat end, function(val) db.profile.tertiariesFormat = val end, {"NUMBER", "PERCENT", "NUMBER_PERCENT","PERCENT_NUMBER"})
		
		AddDropdown(L["Speed Format"], {CURRENT = L["Current Speed"], STATIC = L["Static Speed"], CURRENT_STATIC = L["Current + Static"], STATIC_CURRENT = L["Static + Current"]}, 
			function() return db.profile.speedFormat or "CURRENT" end, function(val) db.profile.speedFormat = val end, {"CURRENT", "STATIC", "CURRENT_STATIC", "STATIC_CURRENT"})

		AddDropdown(L["Frame Strata"], {BACKGROUND="BACKGROUND", LOW="LOW", MEDIUM="MEDIUM", HIGH="HIGH", DIALOG="DIALOG", FULLSCREEN="FULLSCREEN", FULLSCREEN_DIALOG="FULLSCREEN_DIALOG", TOOLTIP="TOOLTIP"},
			function() return db.profile.frameStrata end, function(val) db.profile.frameStrata = val; f:SetFrameStrata(val) end, {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP"})

	end
	
	function DrawAppearanceTab(content)
		local scroll = AceGUI:Create("ScrollFrame")
		scroll:SetFullWidth(true)
		scroll:SetFullHeight(true)
		scroll:SetLayout("Flow")
		content:AddChild(scroll)
		
		local scrollContent = scroll
		
		local function AddCheckbox(label, getValue, setValue)
			local cb = AceGUI:Create("CheckBox")
			cb:SetLabel(label)
			cb:SetValue(getValue())
			cb:SetWidth(240)
			cb:SetCallback("OnValueChanged", function(_, _, val)
				setValue(val)
				Update()
			end)
			scrollContent:AddChild(cb)
			return cb
		end
		
		local function AddDropdown(label, values, getValue, setValue, order)
			local dd = AceGUI:Create("Dropdown")
			dd:SetLabel(label)
			if order then
				dd:SetList(values, order)
			else
				dd:SetList(values)
			end
			dd:SetValue(getValue())
			dd:SetWidth(240)
			dd:SetCallback("OnValueChanged", function(_, _, val)
				setValue(val)
				Update()
			end)
			
			if dd.label then
				dd.label:ClearAllPoints()
				dd.label:SetPoint("TOPLEFT", dd.frame, "TOPLEFT", 2, 1)
			end
			
			scrollContent:AddChild(dd)
		end
		
		AddSeparator(scrollContent, L["Stat Ordering"])
		local customSecEdit
		local customSecDropdown	

		AddDropdown(L["All Stats"], {DEFAULT = L["Default"], CUSTOM = L["Custom"]}, 
		function() return db.profile.globalStatOrdering or "DEFAULT" end, function(val)
			db.profile.globalStatOrdering = val
			edit:SetDisabled(val ~= "CUSTOM")
			addDropdown:SetDisabled(val ~= "CUSTOM")
			Update()
		end)

		addDropdown = AceGUI:Create("Dropdown")
		addDropdown:SetList(GetAvailableGlobalStats())
		addDropdown:SetWidth(240)
		addDropdown:SetLabel(L["Stat Ordering Label"])
		addDropdown:SetCallback("OnValueChanged", function(_, _, value)
			if not value then return end

			local text = db.profile.customGlobalStatText or ""
			if text ~= "" then
				text = text .. " "
			end
			text = text .. value

			db.profile.customGlobalStatText = text
			edit:SetText(text)

			addDropdown:SetList(GetAvailableGlobalStats())
			addDropdown:SetValue(nil)

			Update()
		end)
		scrollContent:AddChild(addDropdown)

		edit = AceGUI:Create("EditBox")
		edit:SetText(db.profile.customGlobalStatText)
		edit:SetWidth(240)
		edit:SetCallback("OnTextChanged", function(_, _, text)
			db.profile.customGlobalStatText = text
			addDropdown:SetList(GetAvailableGlobalStats())
			Update()
		end)
		edit:SetCallback("OnEnterPressed", function(_, _, text)
			db.profile.customGlobalStatText = text
			addDropdown:SetList(GetAvailableGlobalStats())
			Update()
		end)
		scrollContent:AddChild(edit)

		local isCustom2 = db.profile.globalStatOrdering == "CUSTOM"
		edit:SetDisabled(not isCustom2)
		addDropdown:SetDisabled(not isCustom2)
		
		AddDropdown(L["Secondaries"], {PRIO = L["Prio Based (murlok.io)"], CUSTOM = L["Custom"]}, 
		function() return db.profile.secondaryOrdering or "PRIO" end, function(val)
			db.profile.secondaryOrdering = val

			local show = (val == "CUSTOM")
			if customSecEdit then customSecEdit:SetDisabled(not show) end
			if customSecDropdown then customSecDropdown:SetDisabled(not show) end

			Update()
		end)
		
		customSecDropdown = AceGUI:Create("Dropdown")
		customSecDropdown:SetList(GetAvailableSecondaries())
		customSecDropdown:SetWidth(240)
		customSecDropdown:SetLabel(L["Stat Ordering Label"])
		customSecDropdown:SetCallback("OnValueChanged", function(_, _, value)
			if not value then return end

			local text = db.profile.customSecondaryText or ""
			if text ~= "" then
				text = text .. " "
			end
			text = text .. value

			db.profile.customSecondaryText = text
			customSecEdit:SetText(text)

			customSecDropdown:SetList(GetAvailableSecondaries())
			customSecDropdown:SetValue(nil)

			Update()
		end)
		scrollContent:AddChild(customSecDropdown)
		
		customSecEdit = AceGUI:Create("EditBox")
		customSecEdit:SetText(db.profile.customSecondaryText)
		customSecEdit:SetWidth(240)
		customSecEdit:SetCallback("OnTextChanged", function(_, _, text)
			db.profile.customSecondaryText = text
			customSecDropdown:SetList(GetAvailableSecondaries())
			Update()
		end)

		customSecEdit:SetCallback("OnEnterPressed", function(_, _, text)
			db.profile.customSecondaryText = text
			customSecDropdown:SetList(GetAvailableSecondaries())
			Update()
		end)
		scrollContent:AddChild(customSecEdit)

		
		local isCustom = (db.profile.secondaryOrdering == "CUSTOM")
		customSecEdit:SetDisabled(not isCustom)
		customSecDropdown:SetDisabled(not isCustom)

		AddSeparator(scrollContent, L["Custom Text"])
		
		local function AddCustomTextBox(label, key)
			local edit = AceGUI:Create("EditBox")
			edit:SetLabel(label)
			edit:SetWidth(120)
			edit:SetText(db.profile.customStatText[key] or "")
			edit:SetCallback("OnTextChanged", function(_, _, text)
				db.profile.customStatText[key] = text
				Update()
			end)
			scrollContent:AddChild(edit)
		end

		AddCustomTextBox(L["Ilvl"], "Ilvl")
		AddCustomTextBox(L["Primary Stat"], "Main")
		AddCustomTextBox(L["Critical Strike"], "Crit")
		AddCustomTextBox(L["Haste"], "Haste")
		AddCustomTextBox(L["Mastery"], "Mastery")
		AddCustomTextBox(L["Versatility"], "Vers")
		AddCustomTextBox(L["Leech"], "Leech")
		AddCustomTextBox(L["Avoidance"], "Avoidance")
		AddCustomTextBox(L["Speed"], "Speed")
		AddCustomTextBox(L["Armor"], "Armor")
		AddCustomTextBox(L["Block"], "Block")
		AddCustomTextBox(L["Parry"], "Parry")
		AddCustomTextBox(L["Dodge"], "Dodge")
		
		--local newBG = "|cff00ff00" .. L["New"] .. L["Background"] .. "|r"
		AddSeparator(scrollContent, L["Background"] )
		
		AddCheckbox(L["Use Background"], function() return db.profile.useBackground end,
			function(val) 
				db.profile.useBackground = val
				Update()
			end
		)
		
		AddCheckbox(L["Use Border"], function() return db.profile.useBackgroundBorder or false end,
			function(val) 
				db.profile.useBackgroundBorder = val
				Update()
			end
		)
		
		local bgExtendEdit = AceGUI:Create("EditBox")
		bgExtendEdit:SetLabel(L["Extend Background"])
		bgExtendEdit:SetText((db.profile.backgroundExtendUp or 0) .. " " .. (db.profile.backgroundExtendRight or 0) .. " " .. (db.profile.backgroundExtendDown or 0) .. " " .. (db.profile.backgroundExtendLeft or 0))
		bgExtendEdit:SetWidth(240)
		bgExtendEdit:SetCallback("OnEnterPressed", function(_, _, text)
			if text == "" or text:match("^%s*$") then
				db.profile.backgroundExtendUp = 0
				db.profile.backgroundExtendRight = 0
				db.profile.backgroundExtendDown = 0
				db.profile.backgroundExtendLeft = 0
				bgExtendEdit:SetText("0 0 0 0")
				Update()
			else
				local values = {}
				for val in text:gmatch("%d+") do
					table.insert(values, tonumber(val))
				end
				
				if #values >= 4 then
					db.profile.backgroundExtendUp = values[1]
					db.profile.backgroundExtendRight = values[2]
					db.profile.backgroundExtendDown = values[3]
					db.profile.backgroundExtendLeft = values[4]
					Update()
					bgExtendEdit:SetText(values[1] .. " " .. values[2] .. " " .. values[3] .. " " .. values[4])
				end
			end
		end)
		scrollContent:AddChild(bgExtendEdit)

		local bgTextureDD = AceGUI:Create("LSM30_Background")
		bgTextureDD:SetLabel(L["Background Texture"])
		bgTextureDD:SetList(LSM:HashTable("background"))
		bgTextureDD:SetValue(db.profile.backgroundTexture or "Solid Color Black")
		bgTextureDD:SetWidth(240)
		bgTextureDD:SetCallback("OnValueChanged", function(_, _, val)
			db.profile.backgroundTexture = val
			bgTextureDD:SetValue(val)
			C_Timer.After(0.2, Update)
			C_Timer.After(0.4, Update)
		end)
		scrollContent:AddChild(bgTextureDD)

		local borderStyleDD = AceGUI:Create("LSM30_Border")
		borderStyleDD:SetLabel(L["Border Style"])
		borderStyleDD:SetList(LSM:HashTable("border"))
		borderStyleDD:SetValue(db.profile.borderStyle or "Tooltip")
		borderStyleDD:SetWidth(240)
		borderStyleDD:SetCallback("OnValueChanged", function(_, _, val)
			db.profile.borderStyle = val
			borderStyleDD:SetValue(val)
			C_Timer.After(0.1, Update)
		end)
		scrollContent:AddChild(borderStyleDD)

		local borderSizeSlider = AceGUI:Create("Slider")
		borderSizeSlider:SetLabel(L["Border Size"])
		borderSizeSlider:SetSliderValues(0, 100, 1)
		borderSizeSlider:SetValue(db.profile.borderSize or 8)
		borderSizeSlider:SetWidth(240)
		borderSizeSlider:SetCallback("OnValueChanged", function(_, _, val)
			db.profile.borderSize = math.floor(val)
			Update()
		end)
		scrollContent:AddChild(borderSizeSlider)

		local bgOpacitySlider = AceGUI:Create("Slider")
		bgOpacitySlider:SetLabel(L["Background Opacity"])
		bgOpacitySlider:SetSliderValues(0, 100, 1)
		bgOpacitySlider:SetValue((db.profile.backgroundOpacity or 0.7) * 100)
		bgOpacitySlider:SetWidth(240)
		bgOpacitySlider:SetCallback("OnValueChanged", function(_, _, val)
			db.profile.backgroundOpacity = val / 100
			f.bgTexture:SetAlpha(db.profile.backgroundOpacity)
			f.bg:SetAlpha(db.profile.backgroundOpacity)
		end)
		scrollContent:AddChild(bgOpacitySlider)

		local borderOpacitySlider = AceGUI:Create("Slider")
		borderOpacitySlider:SetLabel(L["Border Opacity"])
		borderOpacitySlider:SetSliderValues(0, 100, 1)
		borderOpacitySlider:SetValue((db.profile.borderOpacity or 1) * 100)
		borderOpacitySlider:SetWidth(240)
		borderOpacitySlider:SetCallback("OnValueChanged", function(_, _, val)
			db.profile.borderOpacity = val / 100
			Update()
		end)
		scrollContent:AddChild(borderOpacitySlider)

		local borderOffsetSlider = AceGUI:Create("Slider")
		borderOffsetSlider:SetLabel(L["Border Offset"])
		borderOffsetSlider:SetSliderValues(-100, 100, 1)
		borderOffsetSlider:SetValue(db.profile.borderOffset or 0)
		borderOffsetSlider:SetWidth(240)
		borderOffsetSlider:SetCallback("OnValueChanged", function(_, _, val)
			db.profile.borderOffset = math.floor(val)
			Update()
		end)
		scrollContent:AddChild(borderOffsetSlider)

		local function AddColorRow(labelText, key, boxType)
			boxType = boxType or "stat"
			
			local row = AceGUI:Create("SimpleGroup")
			row:SetLayout("Flow")
			row:SetWidth(240)
			row:SetHeight(30)
			scrollContent:AddChild(row)

			local colorBox = AceGUI:Create("SimpleGroup")
			colorBox:SetLayout("Fill")
			colorBox:SetWidth(24)
			colorBox:SetHeight(24)
			row:AddChild(colorBox)

			local boxTable
			if boxType == "bg" then
				AceFrame.bgColorBox = AceFrame.bgColorBox or {}
				boxTable = AceFrame.bgColorBox
			elseif boxType == "border" then
				AceFrame.borderColorBox = AceFrame.borderColorBox or {}
				boxTable = AceFrame.borderColorBox
			else
				AceFrame.colorBoxes = AceFrame.colorBoxes or {}
				boxTable = AceFrame.colorBoxes
			end
			
			local frame = boxTable[key]
			if not frame then
				frame = CreateFrame("Frame", nil, colorBox.frame, "BackdropTemplate")
				frame:SetAllPoints()
				frame:SetBackdrop({
					bgFile = "Interface/ChatFrame/ChatFrameBackground",
					edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
					edgeSize = 12,
					insets = { left = 3, right = 3, top = 3, bottom = 3 },
				})
				boxTable[key] = frame

				frame:SetScript("OnMouseUp", function()
					OpenColorPicker(key, frame)
				end)
			end

			local c = db.profile.colors[key] or { r = 1, g = 1, b = 1 }
			frame:SetParent(colorBox.frame)
			frame:SetAllPoints()
			frame:SetBackdropColor(c.r, c.g, c.b, 1)

			local spacer = AceGUI:Create("Label")
			spacer:SetWidth(5)
			spacer:SetText("")
			row:AddChild(spacer)

			local lbl = AceGUI:Create("Label")
			lbl:SetText(labelText)
			row:AddChild(lbl)
		end

		AddColorRow(L["Background Color"], "bgColor", "bg")
		AddColorRow(L["Border Color"], "borderColor", "border")

		AddSeparator(scrollContent, L["Colors"])
		

		AddColorRow(L["Ilvl"], "ilvl")
		AddColorRow(L["Primary Stat"], "main")
		AddColorRow(L["Critical Strike"], "crit")
		AddColorRow(L["Haste"], "haste")
		AddColorRow(L["Mastery"], "mastery")
		AddColorRow(L["Versatility"], "vers")
		AddColorRow(L["Leech"], "leech")
		AddColorRow(L["Avoidance"], "avoidance")
		AddColorRow(L["Speed"], "speed")
		AddColorRow(L["Armor"], "armor")
		AddColorRow(L["Block"], "block")
		AddColorRow(L["Parry"], "parry")
		AddColorRow(L["Dodge"], "dodge")
		
		local allColorsBtn = AceGUI:Create("Button")
		allColorsBtn:SetText(L["All Colors"])
		allColorsBtn:SetWidth(240)
		allColorsBtn:SetCallback("OnClick", function()
			OpenColorPicker("ilvl", nil, true, AceFrame)
		end)
		scrollContent:AddChild(allColorsBtn)

		local resetColorsBtn = AceGUI:Create("Button")
		resetColorsBtn:SetText(L["Reset Colors"])
		resetColorsBtn:SetWidth(240)
		resetColorsBtn:SetCallback("OnClick", function()
			for k, col in pairs(defaults.profile.colors) do
				db.profile.colors[k].r = col.r
				db.profile.colors[k].g = col.g
				db.profile.colors[k].b = col.b

				if AceFrame.colorBoxes and AceFrame.colorBoxes[k] then
					AceFrame.colorBoxes[k]:SetBackdropColor(col.r, col.g, col.b, 1)
				end
			end
			Update()
		end)
		scrollContent:AddChild(resetColorsBtn)
		
	end
	
	function DrawInfosTab(content)
		local scroll = AceGUI:Create("ScrollFrame")
		scroll:SetFullWidth(true)
		scroll:SetFullHeight(true)
		scroll:SetLayout("Flow")
		content:AddChild(scroll)
		
		local scrollContent = scroll
		local fontPath = LSM:Fetch("font", db.profile.fontName or "GameFontNormal")

		local titleLabel = AceGUI:Create("Heading")
		titleLabel:SetText("|cff00ff00" .. L["Addon Name"] .. "|r")
		titleLabel:SetFullWidth(true)
		scrollContent:AddChild(titleLabel)

		local infoText = AceGUI:Create("Label")
		local infoContent = L["StatsInfoText"]
		infoText:SetText(infoContent)
		infoText:SetFullWidth(true)

		local infoLabelText = infoText.label
		if infoLabelText then
			infoLabelText:SetFont(fontPath, 12)
		end
		
		scrollContent:AddChild(infoText)

		local spacer = AceGUI:Create("Label")
		spacer:SetText(" ")
		spacer:SetFullWidth(true)
		scrollContent:AddChild(spacer)

		local changelogHeader = AceGUI:Create("Heading")
		changelogHeader:SetText("|cff00ff00" .. L["Changelog"] .. "|r")
		changelogHeader:SetFullWidth(true)
		scrollContent:AddChild(changelogHeader)

		local changelogText_current = AceGUI:Create("Label")
		local changelogContent_current = STATS_PLUS_CHANGELOG_CURRENT
		changelogText_current:SetText(changelogContent_current)
		changelogText_current:SetFullWidth(true)
		local currentLabelText = changelogText_current.label
		if currentLabelText then
			currentLabelText:SetFont(fontPath, 14)
		end
		scrollContent:AddChild(changelogText_current)

		local changelogText = AceGUI:Create("Label")
		local changelogContent = STATS_PLUS_CHANGELOG
		changelogText:SetText(changelogContent)
		changelogText:SetFullWidth(true)
		local oldLabelText = changelogText.label
		if oldLabelText then
			oldLabelText:SetFont(fontPath, 11)
		end
		scrollContent:AddChild(changelogText)
	end

	local tabs = AceGUI:Create("TabGroup")
	tabs:SetFullWidth(true)
	tabs:SetFullHeight(true)
	
	tabs:SetTabs({
		{ text = L["Infos"], value = "infos" },
		{ text = L["General"], value = "general" },
		{ text = L["Appearance"] , value = "appearance" },
		{ text = L["Profiles"], value = "profiles" },
	})

	AceFrame:AddChild(tabs)
	
	tabs:SetCallback("OnGroupSelected", function(container, _, group)
		container:ReleaseChildren()
		container:SetLayout("Flow")
		if group == "general" then
			DrawGeneralTab(container)
		elseif group == "appearance" then
			DrawAppearanceTab(container)
		elseif group == "infos" then
			DrawInfosTab(container)
		elseif group == "profiles" then
			AceConfigDialog:Open("Stats+_Profiles", container)
		end
	end)

	tabs:SelectTab("infos")
end

local function OnProfileChangedCallback()
	if db.profile and db.profile.locked == nil then
		db.profile.locked = false
	end

	f:ClearAllPoints()
	local posSource = db.profile.useGlobalPosition and db.global.pos or db.profile.pos
	local pos = posSource or { point="CENTER", relativeTo="UIParent", relativePoint="CENTER", x=0, y=0 }
	local relative = _G[pos.relativeTo] or UIParent
	f:SetPoint(pos.point, relative, pos.relativePoint, pos.x, pos.y)
	f:SetFrameStrata(db.profile.frameStrata)

	Update()
	ApplyLockState()
end

local lockCheckboxRef
local function InitializeLockCheckbox()
	if db and not lockCheckboxRef then
		lockCheckboxRef = {
			GetValue = function() return db.profile.locked end,
			SetValue = function(self, val) db.profile.locked = val end,
			Fire = function(self, event, val)
				if event == "OnValueChanged" then
					ApplyLockState()
					Update()
				end
			end
		}
	end
end

local ldbObj = LDB:NewDataObject("StatsPlus", {
	type = "launcher",
	text = "Stats+",
	icon = "Interface\\Icons\\inv_10_jewelcrafting_gem3primal_air_cut_bronze",
	OnClick = function(self, button)
		if button == "LeftButton" then
			OpenAceOptions()
		elseif button == "RightButton" then
			if lockCheckboxRef then
				local newVal = not db.profile.locked
				lockCheckboxRef:SetValue(newVal)
				lockCheckboxRef:Fire("OnValueChanged", newVal)
			end
		end
	end,
	OnTooltipShow = function(tt)
		tt:AddLine("Statsplus (Stats+)")
		tt:AddLine(L["Minimap Button L"], 1,1,1)
		tt:AddLine(L["Minimap Button R"], 1,1,1)
	end,
})

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UNIT_STATS")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
f:RegisterEvent("COMBAT_RATING_UPDATE")
f:RegisterEvent("TRAIT_CONFIG_UPDATED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("UNIT_TARGET")
f:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")

local function UpdateSpellcastEvent()
	local isTank = IsTankSpec()
	
	if isTank then
		if not f:IsEventRegistered("UNIT_SPELLCAST_SENT") then
			f:RegisterEvent("UNIT_SPELLCAST_SENT")
		end
	else
		if f:IsEventRegistered("UNIT_SPELLCAST_SENT") then
			f:UnregisterEvent("UNIT_SPELLCAST_SENT")
		end
	end
end

f:SetScript("OnEvent", function(_, event, unit, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		if not db then
			db = AceDB:New("StatsDB", defaults, true)
			LibDualSpec:EnhanceDatabase(db, "Stats")
			local profileOptions = AceDBOptions:GetOptionsTable(db)
			profileOptions.name = ""

			AceConfig:RegisterOptionsTable("Stats+_Profiles", profileOptions)
			LibDualSpec:EnhanceOptions(profileOptions, db)
			LDBIcon:Register("StatsPlus", ldbObj, db.profile.minimap)

			db:RegisterCallback("OnProfileChanged", OnProfileChangedCallback)
			db:RegisterCallback("OnProfileCopied", OnProfileChangedCallback)
			db:RegisterCallback("OnProfileReset", OnProfileChangedCallback)
		end
		InitializeLockCheckbox()
		-- === DB RESET LOGIC ===
		StatsDB = StatsDB or {}
		
		local function GetVersionNumber(versionString)
			if not versionString then return 999 end
			local num = versionString:match("([0-9.]+)$")
			return tonumber(num) or 999
		end

		local oldDbVersion = StatsDB.version
		local currentVersion = GetVersionNumber(oldDbVersion or db.global.version)
		
		if (oldDbVersion and currentVersion < 1.30) or currentVersion < 1.30 then
			StaticPopupDialogs["STATSDB_RESET"] = {
				text = L["RELOADWARNING"],
				button1 = "RELOAD",
				timeout = 0,
				whileDead = true,
				hideOnEscape = false,
				OnAccept = function()
					for k in pairs(StatsDB) do
						StatsDB[k] = nil
					end
					
					db.global.version = L["Version"] .. " 1.30"
					ReloadUI()
				end,
			}
			StaticPopup_Show("STATSDB_RESET")
		end
		-- === END DB RESET LOGIC ===
		
		f:ClearAllPoints()
		local posSource = db.profile.useGlobalPosition and db.global.pos or db.profile.pos
		local pos = posSource or { point="CENTER", relativeTo="UIParent", relativePoint="CENTER", x=0, y=0 }
		local relative = _G[pos.relativeTo] or UIParent
		f:SetPoint(pos.point, relative, pos.relativePoint, pos.x, pos.y)
		f:SetFrameStrata(db.profile.frameStrata or "HIGH")
		
		UpdateVisibility()
		LoadMainStat()  -- Speichere Primary Stat beim Login
		Update()
		UpdateSpeedState()
		ApplyLockState()
		UpdateSpellcastEvent()

		if not db.global.version or db.global.version ~= CURRENT_VERSION then
			db.global.version = CURRENT_VERSION
			--db.global.seenOptions = nil
		end
		if not db.global.seenOptions then
			OpenAceOptions()
			db.global.seenOptions = true
		end

	elseif event == "TRAIT_CONFIG_UPDATED" then
		LoadMainStat()  -- Speichere Primary Stat bei Spec-Wechsel
		UpdateSpellcastEvent()
		Update()
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		C_Timer.After(0.1, Update)
		C_Timer.After(0.2, Update)
	elseif event == "PLAYER_REGEN_DISABLED" then
		-- Ignoriere wenn ADDON_RESTRICTION_STATE_CHANGED aktiv ist
		if not restrictionActive then
			inCombat = true
			C_Timer.After(0.05, UpdateVisibility)
			C_Timer.After(0.1, Update)
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		-- Ignoriere wenn ADDON_RESTRICTION_STATE_CHANGED aktiv ist
		if not restrictionActive then
			inCombat = true
			C_Timer.After(0.05, UpdateVisibility)
			C_Timer.After(0.1, Update)
		end
	elseif event == "UNIT_TARGET" then
		if not unit or unit == "player" then
			Update()
		end
	elseif event == "ADDON_RESTRICTION_STATE_CHANGED" then
		-- type = 2 (immer relevant), state = 0 (frei) oder 1/2 (restricted)
		local restrictionType = unit
		local restrictionState = select(1, ...)
		if restrictionType == 2 then
			restrictionActive = (restrictionState ~= 0)
			inCombat = restrictionActive
			C_Timer.After(0.05, Update)
		end
	elseif event == "UNIT_SPELLCAST_SENT" then
		if not unit or unit == "player" then
			ScheduleUpdate()
		end
	elseif not unit or unit == "player" then
		ScheduleUpdate()
	end
end)

SLASH_STATS1 = "/stats"
SLASH_STATS2 = "/st"
SlashCmdList.STATS = function(msg)
	if not db then return end
	local cmd, arg = msg:match("^(%S*)%s*(.-)$")
	
	if cmd == "update" then
		local val = tonumber(arg)
		local current = db.global.updateInterval or 0.35

		if val then
			if val < 0.20 then val = 0.20
			elseif val > 0.80 then val = 0.80
			end
			db.global.updateInterval = val
			print("|cff00ff00[Stats+]|r |cff88ff88" .. L["UpdateIntervalSet"]:format(val) .. "|r")
		else
			print("|c00000000--------------------------------|r")
			print("|cff00ff00[Stats+]|r |cffff4444" .. L["SpeedNoticeLine1"] .. "|r")
			print("|cff00ff00[Stats+]|r |cffff8888" .. L["SpeedNoticeLine2"] .. "|r")
			print("|cff00ff00[Stats+]|r |cff00ff00" .. L["SpeedNoticeLine3"] .. " |cffffff00[" .. current .. "]|r|r")
			print("|c00000000--------------------------------|r")
		end
	elseif cmd == "reset" then
		db:ResetProfile()
		Update()
		UpdateSpeedState()
		ApplyLockState()
		ReloadUI()
	else
		OpenAceOptions()
	end
end

local blizzOpt = CreateFrame("Frame")
blizzOpt.name = L["Addon Name"]

local title = blizzOpt:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -40)
title:SetText(L["Stats+ Options"])

local button = CreateFrame("Button", nil, blizzOpt, "UIPanelButtonTemplate")
button:SetSize(220, 40)
button:SetPoint("TOP", title, "BOTTOM", 0, -20)
button:SetText(L["Click or use /st /stats"])

button:SetScript("OnClick", function()
	OpenAceOptions()
end)

if Settings then
	local category = Settings.RegisterCanvasLayoutCategory(blizzOpt, L["Addon Name"])
	Settings.RegisterAddOnCategory(category)
else
	InterfaceOptions_AddCategory(blizzOpt)
end

-------------