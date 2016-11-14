local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

--------------------------
-- SavedVariables Setup --
--------------------------
local DejaCharacterStats, gdbprivate = ...

gdbprivate.gdbdefaults = {
}
gdbprivate.gdbdefaults.gdbdefaults = {
}

----------------------------
-- Saved Variables Loader --
----------------------------
local loader = CreateFrame("Frame")
	loader:RegisterEvent("ADDON_LOADED")
	loader:SetScript("OnEvent", function(self, event, arg1)
		if event == "ADDON_LOADED" and arg1 == "DejaCharacterStats" then
			local function initDB(gdb, gdbdefaults)
				if type(gdb) ~= "table" then gdb = {} end
				if type(gdbdefaults) ~= "table" then return gdb end
				for k, v in pairs(gdbdefaults) do
					if type(v) == "table" then
						gdb[k] = initDB(gdb[k], v)
					elseif type(v) ~= type(gdb[k]) then
						gdb[k] = v
					end
				end
				return gdb
			end

			DejaCharacterStatsDB = initDB(DejaCharacterStatsDB, gdbprivate.gdbdefaults)
			gdbprivate.gdb = DejaCharacterStatsDB

			self:UnregisterEvent("ADDON_LOADED")
		end
	end)

local DejaCharacterStats, private = ...

private.defaults = {
}
private.defaults.dcsdefaults = {
}

DejaCharacterStats = {};

----------------------------
-- Saved Variables Loader --
----------------------------
local loader = CreateFrame("Frame")
	loader:RegisterEvent("ADDON_LOADED")
	loader:SetScript("OnEvent", function(self, event, arg1)
		if event == "ADDON_LOADED" and arg1 == "DejaCharacterStats" then
			local function initDB(db, defaults)
				if type(db) ~= "table" then db = {} end
				if type(defaults) ~= "table" then return db end
				for k, v in pairs(defaults) do
					if type(v) == "table" then
						db[k] = initDB(db[k], v)
					elseif type(v) ~= type(db[k]) then
						db[k] = v
					end
				end
				return db
			end

			DejaCharacterStatsDBPC = initDB(DejaCharacterStatsDBPC, private.defaults)
			private.db = DejaCharacterStatsDBPC

			self:UnregisterEvent("ADDON_LOADED")
		end
	end)

--------------------------
-- Open Categaories Fix --
--------------------------
do
	local function get_panel_name(panel)
		local tp = type(panel)
		local cat = INTERFACEOPTIONS_ADDONCATEGORIES
		if tp == "string" then
			for i = 1, #cat do
				local p = cat[i]
				if p.name == panel then
					if p.parent then
						return get_panel_name(p.parent)
					else
						return panel
					end
				end
			end
		elseif tp == "table" then
			for i = 1, #cat do
				local p = cat[i]
				if p == panel then
					if p.parent then
						return get_panel_name(p.parent)
					else
						return panel.name
					end
				end
			end
		end
	end

	local function InterfaceOptionsFrame_OpenToCategory_Fix(panel)
		if doNotRun or InCombatLockdown() then return end
		local panelName = get_panel_name(panel)
		if not panelName then return end -- if its not part of our list return early
		local noncollapsedHeaders = {}
		local shownpanels = 0
		local mypanel
		local t = {}
		local cat = INTERFACEOPTIONS_ADDONCATEGORIES
		for i = 1, #cat do
			local panel = cat[i]
			if not panel.parent or noncollapsedHeaders[panel.parent] then
				if panel.name == panelName then
					panel.collapsed = true
					t.element = panel
					InterfaceOptionsListButton_ToggleSubCategories(t)
					noncollapsedHeaders[panel.name] = true
					mypanel = shownpanels + 1
				end
				if not panel.collapsed then
					noncollapsedHeaders[panel.name] = true
				end
				shownpanels = shownpanels + 1
			end
		end
		local Smin, Smax = InterfaceOptionsFrameAddOnsListScrollBar:GetMinMaxValues()
		if shownpanels > 15 and Smin < Smax then 
		  local val = (Smax/(shownpanels-15))*(mypanel-2)
		  InterfaceOptionsFrameAddOnsListScrollBar:SetValue(val)
		end
		doNotRun = true
		InterfaceOptionsFrame_OpenToCategory(panel)
		doNotRun = false
	end

	hooksecurefunc("InterfaceOptionsFrame_OpenToCategory", InterfaceOptionsFrame_OpenToCategory_Fix)
end

-- Uncomment below the following three database saved variables setup lines for DejaView integration.
-- SavedVariables Setup
-- local DejaCharacterStats, private = ...
-- private.defaults = {}
-- DejaCharacterStats = {};

---------------------
-- DCS Slash Setup --
---------------------
local RegisteredEvents = {};
local dcsslash = CreateFrame("Frame", "DejaCharacterStatsSlash", UIParent)

dcsslash:SetScript("OnEvent", function (self, event, ...) 
	if (RegisteredEvents[event]) then 
	return RegisteredEvents[event](self, event, ...) 
	end
end)

function RegisteredEvents:ADDON_LOADED(event, addon, ...)
	if (addon == "DejaCharacterStats") then
		SLASH_DEJACHARACTERSTATS1 = (L["/dcstats"])
		SlashCmdList["DejaCharacterStats"] = function (msg, editbox)
			DejaCharacterStats.SlashCmdHandler(msg, editbox)	
	end
	--	DEFAULT_CHAT_FRAME:AddMessage("DejaCharacterStats loaded successfully. For options: Esc>Interface>AddOns or type /dcstats.",0,192,255)
	end
end

for k, v in pairs(RegisteredEvents) do
	dcsslash:RegisterEvent(k)
end

function DejaCharacterStats.ShowHelp()
	print(L["DejaCharacterStats Slash commands (/dcstats):"])
	print(L["  /dcstats config: Open the DejaCharacterStats addon config menu."])
	print(L["  /dcstats reset:  Resets DejaCharacterStats frames to default positions."])
end

function DejaCharacterStats.SetConfigToDefaults()
	print(L["Resetting config to defaults"])
	DejaCharacterStatsDBPC = DefaultConfig
	RELOADUI()
end

function DejaCharacterStats.GetConfigValue(key)
	return DejaCharacterStatsDBPC[key]
end

function DejaCharacterStats.PrintPerformanceData()
	UpdateAddOnMemoryUsage()
	local mem = GetAddOnMemoryUsage("DejaCharacterStats")
	print(L["DejaCharacterStats is currently using "] .. mem .. L[" kbytes of memory"])
	collectgarbage(collect)
	UpdateAddOnMemoryUsage()
	mem = GetAddOnMemoryUsage("DejaCharacterStats")
	print(L["DejaCharacterStats is currently using "] .. mem .. L[" kbytes of memory after garbage collection"])
end

function DejaCharacterStats.SlashCmdHandler(msg, editbox)
	--print("command is " .. msg .. "\n")
	if (string.lower(msg) == L["config"]) then
		InterfaceOptionsFrame_OpenToCategory("DejaCharacterStats");
	elseif (string.lower(msg) == L["dumpconfig"]) then
		print(L["With defaults"])
		for k,v in pairs(DCSDefaultConfig) do
			print(k,DejaCharacterStats.GetConfigValue(k))
		end
		print(L["Direct table"])
		for k,v in pairs(DCSDefaultConfig) do
			print(k,v)
		end
	elseif (string.lower(msg) == L["reset"]) then
		DejaCharacterStatsDBPC = private.defaults;
		ReloadUI();
	elseif (string.lower(msg) == L["perf"]) then
		DejaCharacterStats.PrintPerformanceData()
	else
		DejaCharacterStats.ShowHelp()
	end
end
	SlashCmdList["DEJACHARACTERSTATS"] = DejaCharacterStats.SlashCmdHandler;

-----------------------
-- DCS Options Panel --
-----------------------
DejaCharacterStats.panel = CreateFrame( "Frame", "DejaCharacterStatsPanel", UIParent );
DejaCharacterStats.panel.name = "DejaCharacterStats";
InterfaceOptions_AddCategory(DejaCharacterStats.panel);

-- DCS, DejaView Child Panel
-- DejaViewPanel.DejaCharacterStatsPanel = CreateFrame( "Frame", "DejaCharacterStatsPanel", DejaViewPanel);
-- DejaViewPanel.DejaCharacterStatsPanel.name = "DejaCharacterStats";
-- Specify childness of this panel (this puts it under the little red [+], instead of giving it a normal AddOn category)
-- DejaViewPanel.DejaCharacterStatsPanel.parent = DejaViewPanel.name;
-- Add the child to the Interface Options
-- InterfaceOptions_AddCategory(DejaViewPanel.DejaCharacterStatsPanel);

local dcstitle=CreateFrame("Frame", "DCSTitle", DejaCharacterStatsPanel)
	dcstitle:SetPoint("TOPLEFT", 5, -5)
	dcstitle:SetScale(2.0)
	dcstitle:SetWidth(150)
	dcstitle:SetHeight(50)
	dcstitle:Show()

local dcstitleFS = dcstitle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dcstitleFS:SetText('|cff00c0ffDejaCharacterStats|r')
	dcstitleFS:SetPoint("TOPLEFT", 0, 0)
	dcstitleFS:SetFont("Fonts\\FRIZQT__.TTF", 10)
	
local dcsresetcheck = CreateFrame("Button", "DCSResetButton", DejaCharacterStatsPanel, "UIPanelButtonTemplate")
	dcsresetcheck:ClearAllPoints()
	dcsresetcheck:SetPoint("BOTTOMLEFT", 5, 5)
	dcsresetcheck:SetScale(1.25)

	local LOCALE = GetLocale()
		--print (LOCALE)

	if (LOCALE == "ptBR" or LOCALE == "frFR" or LOCALE == "deDE") then
		--print ("ptBR, frFR, deDE = 175")
		LOCALE = 175
	else
		--print ("enUS = 125")
		LOCALE = 125
	end

	dcsresetcheck:SetWidth(LOCALE)

	dcsresetcheck:SetHeight(30)
	_G[dcsresetcheck:GetName() .. "Text"]:SetText(L["Reset to Default"])
	dcsresetcheck:SetScript("OnClick", function(self, button, down)
 		gdbprivate.gdb.gdbdefaults = gdbprivate.gdbdefaults.gdbdefaults;
		ReloadUI();
	end)

----------------------------
-- DCS Functions & Arrays --
----------------------------

function PaperDollFrame_UpdateStats()
	local level = UnitLevel("player");
	local categoryYOffset = -5;
	local statYOffset = 0;

	PaperDollFrame_SetItemLevel(CharacterStatsPane.ItemLevelFrame, "player");
	CharacterStatsPane.ItemLevelFrame.Value:SetTextColor(GetItemLevelColor());
	CharacterStatsPane.ItemLevelCategory:Show();
	CharacterStatsPane.ItemLevelFrame:Show();
	CharacterStatsPane.AttributesCategory:SetPoint("TOP", 0, -76);

	local spec = GetSpecialization();
	local role = GetSpecializationRole(spec);

	CharacterStatsPane.statsFramePool:ReleaseAll();
	-- we need a stat frame to first do the math to know if we need to show the stat frame
	-- so effectively we'll always pre-allocate
	local statFrame = CharacterStatsPane.statsFramePool:Acquire();

	local lastAnchor;

	for catIndex = 1, #PAPERDOLL_STATCATEGORIES do
		local catFrame = CharacterStatsPane[PAPERDOLL_STATCATEGORIES[catIndex].categoryFrame];
		local numStatInCat = 0;
		for statIndex = 1, #PAPERDOLL_STATCATEGORIES[catIndex].stats do
			local stat = PAPERDOLL_STATCATEGORIES[catIndex].stats[statIndex];
			local showStat = true;
			if ( showStat and stat.primary ) then
				local primaryStat = select(7, GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player")));
				if ( stat.primary ~= primaryStat ) then
					showStat = false;
				end
			end
			if ( showStat and stat.roles ) then
				local foundRole = false;
				for _, statRole in pairs(stat.roles) do
					if ( role == statRole ) then
						foundRole = true;
						break;
					end
				end
				showStat = foundRole;
			end
			if ( showStat ) then
				statFrame.onEnterFunc = nil;
				PAPERDOLL_STATINFO[stat.stat].updateFunc(statFrame, "player");
				if ( not stat.hideAt or stat.hideAt ~= statFrame.numericValue ) then
					if ( numStatInCat == 0 ) then
						if ( lastAnchor ) then
							catFrame:SetPoint("TOP", lastAnchor, "BOTTOM", 0, categoryYOffset);
						end
						lastAnchor = catFrame;
						statFrame:SetPoint("TOP", catFrame, "BOTTOM", 0, -2);
					else
						statFrame:SetPoint("TOP", lastAnchor, "BOTTOM", 0, statYOffset);
					end
					if statFrame:IsShown() then
						numStatInCat = numStatInCat + 1;
						statFrame.Background:SetShown((numStatInCat % 2) == 0);
						lastAnchor = statFrame;
					end
					-- done with this stat frame, get the next one
					statFrame = CharacterStatsPane.statsFramePool:Acquire();
				end
			end
		end
		catFrame:SetShown(numStatInCat > 0);
	end
	-- release the current stat frame
	CharacterStatsPane.statsFramePool:Release(statFrame);
end

PAPERDOLL_STATINFO = {

	-- General
	["HEALTH"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetHealth(statFrame, unit); end
	},
	["POWER"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetPower(statFrame, unit); end
	},
	["ALTERNATEMANA"] = {
		-- Only appears for Druids when in shapeshift form
		updateFunc = function(statFrame, unit) PaperDollFrame_SetAlternateMana(statFrame, unit); end
	},
	["ITEMLEVEL"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetItemLevel(statFrame, unit); end
	},
	["MOVESPEED"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetMovementSpeed(statFrame, unit); end
	},

	-- Base stats
	["STRENGTH"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetStat(statFrame, unit, LE_UNIT_STAT_STRENGTH); end
	},
	["AGILITY"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetStat(statFrame, unit, LE_UNIT_STAT_AGILITY); end
	},
	["INTELLECT"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetStat(statFrame, unit, LE_UNIT_STAT_INTELLECT); end
	},
	["STAMINA"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetStat(statFrame, unit, LE_UNIT_STAT_STAMINA); end
	},

	-- Enhancements
	["CRITCHANCE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetCritChance(statFrame, unit); end
	},
	["HASTE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetHaste(statFrame, unit); end
	},
	["MASTERY"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetMastery(statFrame, unit); end
	},
	["VERSATILITY"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetVersatility(statFrame, unit); end
	},
	["LIFESTEAL"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetLifesteal(statFrame, unit); end
	},
	["AVOIDANCE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetAvoidance(statFrame, unit); end
	},

	-- Attack
	["ATTACK_DAMAGE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetDamage(statFrame, unit); end
	},
	["ATTACK_AP"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetAttackPower(statFrame, unit); end
	},
	["ATTACK_ATTACKSPEED"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetAttackSpeed(statFrame, unit); end
	},
	["ENERGY_REGEN"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetEnergyRegen(statFrame, unit); end
	},
	["RUNE_REGEN"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetRuneRegen(statFrame, unit); end
	},
	["FOCUS_REGEN"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetFocusRegen(statFrame, unit); end
	},

	-- Spell
	["SPELLPOWER"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetSpellPower(statFrame, unit); end
	},
	["MANAREGEN"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetManaRegen(statFrame, unit); end
	},

	-- Defense
	["ARMOR"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetArmor(statFrame, unit); end
	},
	["DODGE"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetDodge(statFrame, unit); end
	},
	["PARRY"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetParry(statFrame, unit); end
	},
	["BLOCK"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetBlock(statFrame, unit); end
	},
	
	-- Durability & Repair
	["DURABILITY"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetDurability(statFrame, unit); end
	},
	["REPAIRTOTAL"] = {
		updateFunc = function(statFrame, unit) PaperDollFrame_SetRepairTotal(statFrame, unit); end
	},
};

--------------------------
-- Relevant Stats Array --
--------------------------

local function DCS_RelevantStats()
	-- primary: only show the 1 for the player's current spec
	-- roles: only show if the player's current spec is one of the roles
	-- hideAt: only show if it's not this value

	PAPERDOLL_STATCATEGORIES= {
		[1] = {
			categoryFrame = "AttributesCategory",
			stats = {
				[1] = { stat = "ARMOR" },
				[2] = { stat = "STRENGTH", primary = LE_UNIT_STAT_STRENGTH },
				[3] = { stat = "AGILITY", primary = LE_UNIT_STAT_AGILITY },
				[4] = { stat = "INTELLECT", primary = LE_UNIT_STAT_INTELLECT },
				[5] = { stat = "STAMINA" },
				[6] = { stat = "ATTACK_DAMAGE", primary = LE_UNIT_STAT_STRENGTH, roles =  { "TANK", "DAMAGER" } },
				[7] = { stat = "ATTACK_AP", hideAt = 0, primary = LE_UNIT_STAT_STRENGTH, roles =  { "TANK", "DAMAGER" } },
				[8] = { stat = "ATTACK_ATTACKSPEED", primary = LE_UNIT_STAT_STRENGTH, roles =  { "TANK", "DAMAGER" } },
				[9] = { stat = "ATTACK_DAMAGE", primary = LE_UNIT_STAT_AGILITY, roles =  { "TANK", "DAMAGER" } },
				[10] = { stat = "ATTACK_AP", hideAt = 0, primary = LE_UNIT_STAT_AGILITY, roles =  { "TANK", "DAMAGER" } },
				[11] = { stat = "ATTACK_ATTACKSPEED", primary = LE_UNIT_STAT_AGILITY, roles =  { "TANK", "DAMAGER" } },
				[12] = { stat = "SPELLPOWER", hideAt = 0, primary = LE_UNIT_STAT_INTELLECT },
				[13] = { stat = "MANAREGEN", hideAt = 0, primary = LE_UNIT_STAT_INTELLECT },
				[14] = { stat = "ENERGY_REGEN", hideAt = 0, primary = LE_UNIT_STAT_AGILITY },
				[15] = { stat = "RUNE_REGEN", hideAt = 0, primary = LE_UNIT_STAT_STRENGTH },
				[16] = { stat = "FOCUS_REGEN", hideAt = 0, primary = LE_UNIT_STAT_AGILITY },
				[17] = { stat = "MOVESPEED" },
			},
		},
		[2] = {
			categoryFrame = "EnhancementsCategory",
			stats = {
				[1] = { stat = "CRITCHANCE", hideAt = 0 },
				[2] = { stat = "HASTE", hideAt = 0 },
				[3] = { stat = "VERSATILITY", hideAt = 0 },
				[4] = { stat = "MASTERY", hideAt = 0 },
				[5] = { stat = "LIFESTEAL", hideAt = 0 },
				[6] = { stat = "AVOIDANCE", hideAt = 0 },
				[7] = { stat = "DODGE", hideAt = 0, roles =  { "TANK" } },
				[8] = { stat = "PARRY", hideAt = 0, roles =  { "TANK" } },
				[9] = { stat = "BLOCK", hideAt = 0, roles =  { "TANK" } },
	--			[10] = { stat = "HEALTH", },
	--			[11] = { stat = "POWER", },
			},
		},
	};
	
		local durabilitychecked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsDurabilityStatChecked.DurabilityStatSetChecked
		if durabilitychecked == true then 
			table.insert(PAPERDOLL_STATCATEGORIES[1].stats, { stat = "DURABILITY" })
			PaperDollFrame_UpdateStats();
		end
		local repairchecked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsRepairTotalStatChecked.RepairTotalStatSetChecked
		if repairchecked == true then 
			table.insert(PAPERDOLL_STATCATEGORIES[1].stats, { stat = "REPAIRTOTAL" })
			PaperDollFrame_UpdateStats();
		end
	PaperDollFrame_UpdateStats();
end

--------------------------
-- Show All Stats Array --
--------------------------
local function DCS_AllStats()
	PAPERDOLL_STATCATEGORIES= {
		[1] = {
			categoryFrame = "AttributesCategory",
			stats = {
				[1] = { stat = "HEALTH" },
				[2] = { stat = "POWER" },
				[3] = { stat = "ARMOR" },
				[4] = { stat = "STRENGTH" },
				[5] = { stat = "AGILITY" },
				[6] = { stat = "INTELLECT" },
				[7] = { stat = "STAMINA" },
				[8] = { stat = "ATTACK_DAMAGE" },
				[9] = { stat = "ATTACK_AP" },
				[10] = { stat = "ATTACK_ATTACKSPEED" },
				[11] = { stat = "SPELLPOWER" },
				[12] = { stat = "MANAREGEN", hideAt = 0 },
				[13] = { stat = "ENERGY_REGEN", hideAt = 0 },
				[14] = { stat = "RUNE_REGEN", hideAt = 0 },
				[15] = { stat = "FOCUS_REGEN", hideAt = 0 },
				[16] = { stat = "MOVESPEED" },
				[17] = { stat = "DURABILITY" },
				[18] = { stat = "REPAIRTOTAL" },
			},
		},
		[2] = {
			categoryFrame = "EnhancementsCategory",
			stats = {
				[1] = { stat = "CRITCHANCE" },
				[2] = { stat = "HASTE" },
				[3] = { stat = "VERSATILITY" },
				[4] = { stat = "MASTERY" },
				[5] = { stat = "LIFESTEAL" },
				[6] = { stat = "AVOIDANCE" },
				[7] = { stat = "DODGE" },
				[8] = { stat = "PARRY" },
				[9] = { stat = "BLOCK" },
			},
		},
	};
	PaperDollFrame_UpdateStats();
end

------------------------------------------------------------------
-- Various Options Selection Initialization and Logic Functions --
------------------------------------------------------------------
local function DCS_SelectStats()
	PAPERDOLL_STATCATEGORIES= {
		[1] = {	categoryFrame = "AttributesCategory", stats = {}, },
		[2] = { categoryFrame = "EnhancementsCategory", stats = {}, },
	}
	PaperDollFrame_UpdateStats();
end

local function DCS_FillSelectStatsTable()
	for k, v in ipairs(PAPERDOLL_AttributesIndexDefaultStats) do
	local checked = private.db.dcsdefaults.dejacharacterstatsSelectedStats[v]
		if checked == true then 
			table.insert(PAPERDOLL_STATCATEGORIES[1].stats, { stat = format("%s", v) })
			PaperDollFrame_UpdateStats();
		end
	end
	
	for k, v in ipairs(PAPERDOLL_EnhancementsIndexDefaultStats) do
	local checked = private.db.dcsdefaults.dejacharacterstatsSelectedStats[v]
		if checked == true then 
			table.insert(PAPERDOLL_STATCATEGORIES[2].stats, { stat = format("%s", v) })
			PaperDollFrame_UpdateStats();
		end
	end
	PaperDollFrame_UpdateStats();
end

local function DCS_SelectStatsReInit()
	DCS_SelectStats()
	DCS_FillSelectStatsTable()
	PaperDollFrame_UpdateStats();
end

local function DCS_CheckShowSelectChecks()
	if DCS_SelectStatsCheck:GetChecked(true) then
		private.db.dcsdefaults.dejacharacterstatsScrollbarMax.DCS_ScrollbarMax = 142
		DCS_SelectStatsReInit()
	elseif not DCS_SelectStatsCheck:GetChecked(true) then
		if DCS_ShowAllStatsCheck:GetChecked(true) then
			private.db.dcsdefaults.dejacharacterstatsScrollbarMax.DCS_ScrollbarMax = 128
			DCS_AllStats()
		elseif not DCS_ShowAllStatsCheck:GetChecked(true) then
			private.db.dcsdefaults.dejacharacterstatsScrollbarMax.DCS_ScrollbarMax = 34
			DCS_RelevantStats()
		end
	end
end

------------------------------
-- DCS Show All Stats Check --
------------------------------
local _, private = ...
private.defaults.dcsdefaults.dejacharacterstatsShowAllStatsChecked = {
	ShowAllStatsSetChecked = false,
}	

local DCS_ShowAllStatsCheck = CreateFrame("CheckButton", "DCS_ShowAllStatsCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowAllStatsCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ShowAllStatsCheck:ClearAllPoints()
	DCS_ShowAllStatsCheck:SetPoint("TOP", 0, -35)
	DCS_ShowAllStatsCheck:SetScale(1.25)
	DCS_ShowAllStatsCheck.tooltipText = L['Checked displays all stats. Unchecked displays relevant stats. Use Shift-scroll to snap to the top or bottom.'] --Creates a tooltip on mouseover.
	_G[DCS_ShowAllStatsCheck:GetName() .. "Text"]:SetText(L["Show All Stats"])
	
	DCS_ShowAllStatsCheck:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
		local checked = private.db.dcsdefaults.dejacharacterstatsShowAllStatsChecked.ShowAllStatsSetChecked
			self:SetChecked(checked)
			if self:GetChecked(true) then
				private.db.dcsdefaults.dejacharacterstatsScrollbarMax.DCS_ScrollbarMax = 128
				DCS_AllStats()
				DCS_SelectStatsCheck:SetChecked(false)
				private.db.dcsdefaults.dejacharacterstatsSelectStatsChecked.SelectStatsSetChecked = false
				private.db.dcsdefaults.dejacharacterstatsShowAllStatsChecked.ShowAllStatsSetChecked = true
			elseif not self:GetChecked(true) then
				DCS_CheckShowSelectChecks()
				private.db.dcsdefaults.dejacharacterstatsShowAllStatsChecked.ShowAllStatsSetChecked = false
			end
		end
	end)

	DCS_ShowAllStatsCheck:SetScript("OnClick", function(self, button, down)
		if self:GetChecked(true) then
			private.db.dcsdefaults.dejacharacterstatsScrollbarMax.DCS_ScrollbarMax = 128
			DCS_AllStats()
			DCS_SelectStatsCheck:SetChecked(false)
			private.db.dcsdefaults.dejacharacterstatsSelectStatsChecked.SelectStatsSetChecked = false
			private.db.dcsdefaults.dejacharacterstatsShowAllStatsChecked.ShowAllStatsSetChecked = true
		elseif not self:GetChecked(true) then
			DCS_CheckShowSelectChecks()
			private.db.dcsdefaults.dejacharacterstatsShowAllStatsChecked.ShowAllStatsSetChecked = false
		end
	end)
	
--------------------------
-- Select-A-Stat™ Check --
--------------------------
local _, private = ...
private.defaults.dcsdefaults.dejacharacterstatsSelectStatsChecked = {
	SelectStatsSetChecked = false,
}	

local _, private = ...
private.defaults.dcsdefaults.dejacharacterstatsSelectedStats = {
	HEALTH = true,POWER = true,ARMOR = true,
	STRENGTH = true,AGILITY = true,INTELLECT = true,STAMINA = true,
	ATTACK_DAMAGE = false,ATTACK_AP = false,ATTACK_ATTACKSPEED = false,SPELLPOWER = false,
	MANAREGEN = false,ENERGY_REGEN = false,RUNE_REGEN = false,FOCUS_REGEN = false,MOVESPEED = true,
	CRITCHANCE = true,HASTE = true,VERSATILITY = true,MASTERY = true,
	LIFESTEAL = true,AVOIDANCE = true,
	DODGE = false,PARRY = false,BLOCK = false,DURABILITY = true,REPAIRTOTAL = true,
}

PAPERDOLL_AttributesIndexDefaultStats ={
	[1] = "HEALTH",[2] = "POWER",[3] = "ALTERNATEMANA",[4] = "ARMOR",
	[5] = "STRENGTH",[6] = "AGILITY",[7] = "INTELLECT",[8] = "STAMINA",
	[9] = "ATTACK_DAMAGE",[10] = "ATTACK_AP",[11] = "ATTACK_ATTACKSPEED",[12] = "SPELLPOWER",
	[13] = "MANAREGEN",[14] = "ENERGY_REGEN",[15] = "RUNE_REGEN",[16] = "FOCUS_REGEN",[17] = "MOVESPEED",
	[18] = "DURABILITY",[19] = "REPAIRTOTAL",
}

PAPERDOLL_EnhancementsIndexDefaultStats ={
	[1] = "CRITCHANCE",[2] = "HASTE",[3] = "VERSATILITY",[4] = "MASTERY",
	[5] = "LIFESTEAL",[6] = "AVOIDANCE",
	[7] = "DODGE",[8] = "PARRY",[9] = "BLOCK",
}

local DCS_SelectStatsCheck = CreateFrame("CheckButton", "DCS_SelectStatsCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_SelectStatsCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_SelectStatsCheck:ClearAllPoints()
	DCS_SelectStatsCheck:SetPoint("TOP", 0, -60)
	DCS_SelectStatsCheck:SetScale(1.25)
	DCS_SelectStatsCheck.tooltipText = L['Select which stats to display. Use Shift-scroll to snap to the top or bottom.'] --Creates a tooltip on mouseover.
	_G[DCS_SelectStatsCheck:GetName() .. "Text"]:SetText(L["Select-A-Stat™"])
	
	DCS_SelectStatsCheck:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
		local checked = private.db.dcsdefaults.dejacharacterstatsSelectStatsChecked.SelectStatsSetChecked
			self:SetChecked(checked)
			if self:GetChecked(true) then
				DCS_SelectStatsReInit()
				DCS_ShowAllStatsCheck:SetChecked(false)
				private.db.dcsdefaults.dejacharacterstatsShowAllStatsChecked.ShowAllStatsSetChecked = false
				private.db.dcsdefaults.dejacharacterstatsSelectStatsChecked.SelectStatsSetChecked = true
			elseif not self:GetChecked(true) then
				DCS_CheckShowSelectChecks()
				private.db.dcsdefaults.dejacharacterstatsSelectStatsChecked.SelectStatsSetChecked = false
			end
		end
	end)

	DCS_SelectStatsCheck:SetScript("OnClick", function(self, button, down)
		if self:GetChecked(true) then
			private.db.dcsdefaults.dejacharacterstatsScrollbarMax.DCS_ScrollbarMax = 142
			DCS_SelectStatsReInit()
			DCS_ShowAllStatsCheck:SetChecked(false)
			private.db.dcsdefaults.dejacharacterstatsShowAllStatsChecked.ShowAllStatsSetChecked = false
			private.db.dcsdefaults.dejacharacterstatsSelectStatsChecked.SelectStatsSetChecked = true
		elseif not self:GetChecked(true) then
			DCS_CheckShowSelectChecks()
			private.db.dcsdefaults.dejacharacterstatsSelectStatsChecked.SelectStatsSetChecked = false
		end
	end)	

--------------------------
-- Stat Selection Loops --
--------------------------
local function tchelper(first, rest)
  return first:upper()..rest:lower()
end

--local attributesCategoryIsShown = CharacterStatsPane.AttributesCategory:IsShown()
local yAttributes

for k, v in ipairs(PAPERDOLL_AttributesIndexDefaultStats) do
	local strreplace = v:gsub("%_", " ")
	local str = strreplace:gsub("(%a)([%w_']*)", tchelper)
	if v == "HEALTH" then str = L["Health"] end
	if v == "POWER" then str = L["Power"] end
	if v == "ALTERNATEMANA" then str = L["Druid Mana"] end
	if v == "ARMOR" then str = L["Armor"] end
	if v == "STRENGTH" then str = L["Strength"] end
	if v == "AGILITY" then str = L["Agility"] end
	if v == "INTELLECT" then str = L["Intellect"] end
	if v == "STAMINA" then str = L["Stamina"] end
	if v == "ATTACK_DAMAGE" then str = L["Damage"] end
	if v == "ATTACK_AP" then str = L["Attack Power"] end
	if v == "ATTACK_ATTACKSPEED" then str = L["Attack Speed"] end
	if v == "SPELLPOWER" then str = L["Spell Power"] end
	if v == "MANAREGEN" then str = L["Mana Regen"] end
	if v == "ENERGY_REGEN" then str = L["Energy Regen"] end
	if v == "RUNE_REGEN" then str = L["Rune Regen"] end
	if v == "FOCUS_REGEN" then str = L["Focus Regen"] end
	if v == "MOVESPEED" then str = L["Movement Speed"] end
	if v == "DURABILITY" then str = L["Durability"] end
	if v == "REPAIRTOTAL" then str = L["Repair Total"] end

	if yAttributes == nil then
		yAttributes = 0
	else
		yAttributes = yAttributes
	end
	
	local counter = (yAttributes + 1)
	yAttributes = counter
	local statframeofy = (-86 - (yAttributes*25))
	
	_G["KStatFrame"..v] = KStatFrame

	KStatFrame = CreateFrame("CheckButton", "KStatFrame"..v, DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	KStatFrame:RegisterEvent("PLAYER_LOGIN")
	KStatFrame:ClearAllPoints()
	KStatFrame:SetPoint("TOP", 30, statframeofy)
	KStatFrame:SetScale(0.95)
	_G[KStatFrame:GetName() .. "Text"]:SetText(format("%s", str))		
	
	KStatFrame:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
			local setchecked = private.db.dcsdefaults.dejacharacterstatsSelectedStats[v]
			self:SetChecked(setchecked)
			if self:GetChecked(true) then
				DCS_SelectStatsReInit()
				private.db.dcsdefaults.dejacharacterstatsSelectedStats[v] = true;
			elseif not self:GetChecked(true) then
				private.db.dcsdefaults.dejacharacterstatsSelectedStats[v] = false;
			end
		end
		DCS_CheckShowSelectChecks()
	end)

	KStatFrame:SetScript("OnClick", function(self, button, up)
		if self:GetChecked(true) then
			private.db.dcsdefaults.dejacharacterstatsSelectedStats[v] = true;
		elseif not self:GetChecked(true) then
			private.db.dcsdefaults.dejacharacterstatsSelectedStats[v] = false;
		end
		DCS_CheckShowSelectChecks()
	end)
	yAttributes = yAttributes
end

local yEnhancements

for k, v in ipairs(PAPERDOLL_EnhancementsIndexDefaultStats) do
	local strreplace = v:gsub("%_", " ")
	local str = strreplace:gsub("(%a)([%w_']*)", tchelper)
	if v == "CRITCHANCE" then str = L["Critical Strike"] end
	if v == "HASTE" then str = L["Haste"] end
	if v == "VERSATILITY" then str = L["Versatility"] end
	if v == "MASTERY" then str = L["Mastery"] end
	if v == "LIFESTEAL" then str = L["Leech"] end
	if v == "AVOIDANCE" then str = L["Avoidance"] end
	if v == "DODGE" then str = L["Dodge"] end
	if v == "PARRY" then str = L["Parry"] end
	if v == "BLOCK" then str = L["Block"] end

	if yEnhancements == nil then
		yEnhancements = 0
	else
		yEnhancements = yEnhancements
	end
	
	local counter = (yEnhancements + 1)
	yEnhancements = counter
	local statframeofy = (-86 - (yEnhancements*25))
	
	_G["KStatFrame"..v] = KStatFrame

	--print(KStatFrame)
	KStatFrame = CreateFrame("CheckButton", "KStatFrame"..v, DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	KStatFrame:RegisterEvent("PLAYER_LOGIN")
	KStatFrame:ClearAllPoints()
	KStatFrame:SetPoint("TOP", 180, statframeofy)
	KStatFrame:SetScale(0.95)
	_G[KStatFrame:GetName() .. "Text"]:SetText(format("%s", str))		

	KStatFrame:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
			local setchecked = private.db.dcsdefaults.dejacharacterstatsSelectedStats[v]
			self:SetChecked(setchecked)
			if self:GetChecked(true) then
				DCS_SelectStatsReInit()
				private.db.dcsdefaults.dejacharacterstatsSelectedStats[v] = true;
			elseif not self:GetChecked(true) then
				private.db.dcsdefaults.dejacharacterstatsSelectedStats[v] = false;
			end
		end
		DCS_CheckShowSelectChecks()
	end)

	KStatFrame:SetScript("OnClick", function(self, button, down)
		if self:GetChecked(true) then
			private.db.dcsdefaults.dejacharacterstatsSelectedStats[v] = true;
		elseif not self:GetChecked(true) then
			private.db.dcsdefaults.dejacharacterstatsSelectedStats[v] = false;
		end
		DCS_CheckShowSelectChecks()
	end)
	yEnhancements = yEnhancements
end

-------------------------------
-- DCS Durability Stat Check --
-------------------------------
local _, gdbprivate = ...
gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsDurabilityStatChecked = {
	DurabilityStatSetChecked = true,
}	

local DCS_DurabilityStatCheck = CreateFrame("CheckButton", "DCS_DurabilityStatCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_DurabilityStatCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_DurabilityStatCheck:ClearAllPoints()
	DCS_DurabilityStatCheck:SetPoint("TOPLEFT", 25, -95)
	DCS_DurabilityStatCheck:SetScale(1.25)
	DCS_DurabilityStatCheck.tooltipText = L['Displays the average Durability percentage for equipped items in the stat frame.'] --Creates a tooltip on mouseover.
	_G[DCS_DurabilityStatCheck:GetName() .. "Text"]:SetText(L['Durability '])

	DCS_DurabilityStatCheck:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
			local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsDurabilityStatChecked.DurabilityStatSetChecked
			self:SetChecked(checked)
			if self:GetChecked(true) then
				gdbprivate.gdb.gdbdefaults.dejacharacterstatsDurabilityStatChecked.DurabilityStatSetChecked = true
			elseif not self:GetChecked(true) then
				gdbprivate.gdb.gdbdefaults.dejacharacterstatsDurabilityStatChecked.DurabilityStatSetChecked = false
			end
		end
	end)

	DCS_DurabilityStatCheck:SetScript("OnClick", function(self, button, down)
		if self:GetChecked(true) then
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsDurabilityStatChecked.DurabilityStatSetChecked = true
		elseif not self:GetChecked(true) then
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsDurabilityStatChecked.DurabilityStatSetChecked = false
		end
		DCS_CheckShowSelectChecks()
	end)
	
---------------------------------
-- DCS Repair Total Stat Check --
---------------------------------
local _, gdbprivate = ...
gdbprivate.gdbdefaults.gdbdefaults.dejacharacterstatsRepairTotalStatChecked = {
	RepairTotalStatSetChecked = true,
}	

local DCS_RepairTotalStatCheck = CreateFrame("CheckButton", "DCS_RepairTotalStatCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_RepairTotalStatCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_RepairTotalStatCheck:ClearAllPoints()
	DCS_RepairTotalStatCheck:SetPoint("TOPLEFT", 25, -120)
	DCS_RepairTotalStatCheck:SetScale(1.25)
	DCS_RepairTotalStatCheck.tooltipText = L['Displays the Repair Total before discounts for equipped items in the stat frame.'] --Creates a tooltip on mouseover.
	_G[DCS_RepairTotalStatCheck:GetName() .. "Text"]:SetText(L['Repair Total '])

	DCS_RepairTotalStatCheck:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
			local checked = gdbprivate.gdb.gdbdefaults.dejacharacterstatsRepairTotalStatChecked.RepairTotalStatSetChecked
			self:SetChecked(checked)
			if self:GetChecked(true) then
				gdbprivate.gdb.gdbdefaults.dejacharacterstatsRepairTotalStatChecked.RepairTotalStatSetChecked = true
			elseif not self:GetChecked(true) then
				gdbprivate.gdb.gdbdefaults.dejacharacterstatsRepairTotalStatChecked.RepairTotalStatSetChecked = false
			end
		end
	end)

	DCS_RepairTotalStatCheck:SetScript("OnClick", function(self, button, down)
		if self:GetChecked(true) then
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsRepairTotalStatChecked.RepairTotalStatSetChecked = true
		elseif not self:GetChecked(true) then
			gdbprivate.gdb.gdbdefaults.dejacharacterstatsRepairTotalStatChecked.RepairTotalStatSetChecked = false
		end
		DCS_CheckShowSelectChecks()
	end)
	
------------------------
-- DCS Stat Functions --
------------------------

-- Attack Speed --
function PaperDollFrame_SetAttackSpeed(statFrame, unit)
	local meleeHaste = GetMeleeHaste();
	local speed, offhandSpeed = UnitAttackSpeed(unit);

	local displaySpeed = format("%.2f", speed);
	if ( offhandSpeed ) then
		offhandSpeed = format("%.2f", offhandSpeed);
	end
	if ( offhandSpeed ) then
		displaySpeedxt =  BreakUpLargeNumbers(displaySpeed).." / ".. offhandSpeed;
	else
		displaySpeedxt =  BreakUpLargeNumbers(displaySpeed);
	end
	PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, displaySpeed, false, speed);

	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..displaySpeed..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste));
	
	statFrame:Show();
end

-- Movement Speed Mouseover --
function MovementSpeed_OnEnter(statFrame)
	GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT");
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, L[STAT_MOVEMENT_SPEED]).." "..format("%d%%", statFrame.speed+0.5)..FONT_COLOR_CODE_CLOSE);

	GameTooltip:AddLine(L[format(STAT_MOVEMENT_GROUND_TOOLTIP, statFrame.runSpeed+0.5)]);
	if (statFrame.unit ~= "pet") then
		GameTooltip:AddLine(L[format(STAT_MOVEMENT_FLIGHT_TOOLTIP, statFrame.flightSpeed+0.5)]);
	end
	GameTooltip:AddLine(L[format(STAT_MOVEMENT_SWIM_TOOLTIP, statFrame.swimSpeed+0.5)]);

	GameTooltip:Show();
end

-- Movement Speed --
function PaperDollFrame_SetMovementSpeed(statFrame, unit)
	statFrame.wasSwimming = nil;
	statFrame.unit = unit;
	MovementSpeed_OnUpdate(statFrame);
	
	statFrame.onEnterFunc = MovementSpeed_OnEnter;
	-- TODO: Fix if we decide to show movement speed
	-- statFrame:SetScript("OnUpdate", MovementSpeed_OnUpdate);

	PaperDollFrame_SetLabelAndText(statFrame, L[STAT_MOVEMENT_SPEED], format("%d%%", statFrame.speed+0.5), false, statFrame.speed+0.5);

	statFrame:Show();
end

-- Energy Regen --
function PaperDollFrame_SetEnergyRegen(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	local powerType, powerToken = UnitPowerType(unit);
	if (powerToken ~= "ENERGY") then
		PaperDollFrame_SetLabelAndText(statFrame, STAT_ENERGY_REGEN, NOT_APPLICABLE, false, 0);
		statFrame.tooltip = nil;
		statFrame:Hide();
		return;
	end
	
	local regenRate = GetPowerRegen();
	local regenRateText = BreakUpLargeNumbers(regenRate);
	PaperDollFrame_SetLabelAndText(statFrame, STAT_ENERGY_REGEN, regenRateText, false, regenRate);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_ENERGY_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = STAT_ENERGY_REGEN_TOOLTIP;
	statFrame:Show();
end

-- Focus Regen --
function PaperDollFrame_SetFocusRegen(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	local powerType, powerToken = UnitPowerType(unit);
	if (powerToken ~= "FOCUS") then
		PaperDollFrame_SetLabelAndText(statFrame, STAT_FOCUS_REGEN, NOT_APPLICABLE, false, 0);
		statFrame.tooltip = nil;
		statFrame:Hide();
		return;
	end
	
	local regenRate = GetPowerRegen();
	local regenRateText = BreakUpLargeNumbers(regenRate);
	PaperDollFrame_SetLabelAndText(statFrame, STAT_FOCUS_REGEN, regenRateText, false, regenRate);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_FOCUS_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = STAT_FOCUS_REGEN_TOOLTIP;
	statFrame:Show();
end

-- Rune Speed --
function PaperDollFrame_SetRuneRegen(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end
	
	local _, class = UnitClass(unit);
	if (class ~= "DEATHKNIGHT") then
		PaperDollFrame_SetLabelAndText(statFrame, STAT_RUNE_REGEN, NOT_APPLICABLE, false, 0);
		statFrame.tooltip = nil;
		statFrame:Hide();
		return;
	end
	
	local _, regenRate = GetRuneCooldown(1); -- Assuming they are all the same for now
	local regenRateText = (format(STAT_RUNE_REGEN_FORMAT, regenRate));
	PaperDollFrame_SetLabelAndText(statFrame, STAT_RUNE_REGEN, regenRateText, false, regenRate);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_RUNE_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = STAT_RUNE_REGEN_TOOLTIP;
	statFrame:Show();
end