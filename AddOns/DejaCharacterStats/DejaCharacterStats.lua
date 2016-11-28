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
