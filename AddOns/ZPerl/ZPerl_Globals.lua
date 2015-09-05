-- X-Perl UnitFrames
-- Author: Zek <Boodhoof-EU>
-- License: GNU GPL v3, 29 June 2007 (see LICENSE.txt)

XPerlLocked = 1
local conf
local ConfigRequesters = {}
XPerl_OutOfCombatQueue	= {}
local playerName
local iFixed1
local totalBlocked = 0
local xperlBlocked = 0
local lastConfigMode
local maxRevision

function XPerl_GetRevision()
	return (maxRevision and "r"..maxRevision) or ""
end
function XPerl_SetModuleRevision(rev)
	if (rev) then
		rev = strmatch(rev, "Revision: (%d+)")
		if (rev) then
			rev = tonumber(rev)
			if (not maxRevision or rev > maxRevision) then
				maxRevision = rev
			end
		end
	end
end
local AddRevision = XPerl_SetModuleRevision

XPerl_SetModuleRevision("$Revision: 974 $")

function XPerl_Notice(...)
	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage(XPerl_ProductName.." - |c00FFFF80"..format(...))
	end
end

do
	local function DisableOther(modName, issues)
		local name, title, notes, enabled = GetAddOnInfo(modName)
		if (name and enabled) then
			DisableAddOn(modName)
			local notice = "Disabled '"..modName.."' addon. It is not compatible or needed with X-Perl"
			if (issues) then
				notice = notice..", and creates display issues."
			end
			XPerl_Notice(notice)
		end
	end

	DisableOther("PerlButton")		-- PerlButton was made for Nymbia's Perl UnitFrames. We have our own minimap button
	DisableOther("WT_ZoningTimeFix", true)

	local name,_,_,enabled,loadable = GetAddOnInfo("XPerl_Party")
	if (enabled) then
		DisableOther("CT_PartyBuffs", true)
	end

	local name,_,_,enabled,loadable = GetAddOnInfo("XPerl_GrimReaper")
	if (enabled) then
		DisableAddOn("XPerl_GrimReaper")
		XPerl_Notice("Disabled XPerl_GrimReaper. This has been replaced by a standalone version 'GrimReaper' available on the WoW Ace Updater or from files.wowace.com")
	end
end

-- XPerl_RequestConfig
-- Setup a callback to give config around to local variables
function XPerl_RequestConfig(getConfig, rev)
	tinsert(ConfigRequesters, getConfig)
	if (XPerlDB) then
		getConfig(XPerlDB)
	end
	AddRevision(rev)
end

-- CurrentConfig()
local function CurrentConfig()
	local ret

	local function QuickValidate(set)
		return set.player and set.pet and set.colour and set.target and set.targettarget and set.focus and set.party and set.partypet and set.raid and set.rangeFinder and set.highlight and set.highlightDebuffs and set.buffs and set.buffHelper and set.bar
	end

	if (ZPerlConfigSavePerCharacter) then
		if (not ZPerlConfigNew[GetRealmName()]) then
			ZPerlConfigNew[GetRealmName()] = {}
		end

		if (not ZPerlConfigNew[GetRealmName()][playerName] or not QuickValidate(ZPerlConfigNew[GetRealmName()][playerName])) then
			local new = {}
			XPerl_Defaults(new)
			ZPerlConfigNew[GetRealmName()][playerName] = new		-- TODO use last used config
		end

		ret = ZPerlConfigNew[GetRealmName()][playerName]
	else
		if (not ZPerlConfigNew.global or not QuickValidate(ZPerlConfigNew.global)) then
			local new = {}
			XPerl_Defaults(new)
			ZPerlConfigNew.global = new					-- TODO use last used config
		end

		ret = ZPerlConfigNew.global
	end

	return ret
end

-- GiveConfig
local function GiveConfig()
	conf = CurrentConfig()
	XPerlDB = conf

	for k,v in pairs(ConfigRequesters) do
		v(conf)
	end
end

XPerl_GiveConfig = GiveConfig

-- XPerl_ResetDefaults
function XPerl_ResetDefaults()

	local conf = {}

	XPerl_Defaults(conf)

	if (ZPerlConfigSavePerCharacter) then
		ZPerlConfigNew[GetRealmName()][playerName] = conf
	else
		ZPerlConfigNew.global = conf
	end

	GiveConfig()

	XPerl_OptionActions()

	if (XPerl_Options and XPerl_Options:IsShown()) then
		XPerl_Options:Hide()
		XPerl_Options:Show()
	end
end

-- CopyTable
function XPerl_CopyTable(old)
	if (not old) then
		return
	end

	--local new = XPerl_GetReusableTable()
	local new = { }

	for k, v in pairs(old) do
		if (type(v) == "table") then
			new[k] = XPerl_CopyTable(v)
		else
			new[k] = v
		end
	end

	return new
end

-- ImportOldConfigs()
local function ImportOldConfigs()
	if (ZPerlConfig_Global) then
		-- Convert old global configs
		ZPerlConfigNew = {}

		for realm, realmList in pairs(ZPerlConfig_Global) do
			ZPerlConfigNew[realm] = {}
			for player, settings in pairs(realmList) do
				ZPerlConfigNew[realm][player] = XPerl_ImportOldConfig(settings)
			end
		end

		ZPerlConfig_Global = nil
	end
	if (ZPerlConfig) then
		-- Convert old config
		if (not ZPerlConfigNew) then
			ZPerlConfigNew = {}
		end

		if (ZPerlConfig) then
			ZPerlConfigNew.global = XPerl_ImportOldConfig(ZPerlConfig)
			ZPerlConfig = nil
		end
	end
end

-- XPerl_UnitEvents
local unitEvents = {}
function XPerl_UnitEvents(self, eventArray, eventList)

	local unit = self.partyid
	if (not unit) then
		unit = self:GetAttribute("unit")
		if (not unit) then
			return
		end
	end

	local a = unitEvents[unit]
	if (not a) then
		a = {}
		unitEvents[unit] = a
	end

	a.array = eventArray
	for k,v in pairs(eventList) do
		local selves = a[v]
		if (not selves) then
			selves = {}
			a[v] = selves
		end
		tinsert(selves, self)
		XPerl_Globals:RegisterEvent(v)
	end
end

-- XPerl_UnitEvent
local function XPerl_UnitEvent(unit, event, a, b, c, d)
	local a = unitEvents[unit]
	if (a) then
		local selves = a[event]
		if (selves) then
			local array = a.array
			if (array) then
				for k,v in pairs(selves) do
					array[event](v, a, b, c, d)
				end
				return true
			end
		end
	end
end

-- XPerl_RegisterBasics
function XPerl_RegisterBasics(self, eventArray)
	local events = {
		"UNIT_POWER", "UNIT_MAXPOWER", "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_LEVEL", "UNIT_DISPLAYPOWER", "UNIT_NAME_UPDATE"
	}

	if (self ~= XPerl_Player or not GetCVarBool("predictedPower")) then
		tinsert(events, "UNIT_POWER")
	end
	XPerl_UnitEvents(self, eventArray, events)
end

-- onEventPostSetup
local function onEventPostSetup(self, event, unit, ...)
	--if (unit and XPerl_UnitEvent(unit, event, unit, ...)) then
	--	return
	--end
	--print(event)
	--if (event == "PLAYER_REGEN_ENABLED") then
		--print("something useful")
		if (not XPerlDB) then
			return
		end
		if (XPerl_OutOfCombatOptionSet) then
			XPerl_OutOfCombatOptionSet = nil
			XPerl_OptionActions()
		end
		for func, arg in pairs(XPerl_OutOfCombatQueue) do
			assert(type(func) == "function")
			func(arg)
			--print("out of combat magiczzz:" .. tostring(arg))
			--if (type(v) == "function") then
			--	v()
			--elseif (type(v) == "table") then
			--	v[1](v[2])
			--elseif (type(v) == "string") then
			--	RunScript(v)
			--end
			XPerl_OutOfCombatQueue[func] = nil
		end
	--end
end

-- XPerl_RegisterLDB
local function XPerl_RegisterLDB()
	local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
	if (LDB) then
		local ldbSource = LDB:NewDataObject("X-Perl UnitFrames", {
			type = "launcher",
			text = XPerl_ShortProductName,
			icon = XPerl_ModMenuIcon,
		})

		if (ldbSource) then
			function ldbSource:Update()
				self.text = XPerl_Version
			end
			ldbSource.OnClick = XPerl_MinimapButton_OnClick
			ldbSource.OnTooltipShow = function(tooltip) XPerl_MinimapButton_Details(tooltip, true) end
		end
	end
	XPerl_RegisterLDB = nil
end


local function settingspart1(self, event)
	playerName = UnitName("player")
	self:UnregisterEvent(event)

	local newUser = not ZPerlConfigNew and not ZPerlConfig

	if (not ZPerlConfigNew) then
		if (ZPerlConfig_Global or ZPerlConfig) then
			XPerl_pcall(ImportOldConfigs)
		else
			ZPerlConfigNew = {}
		end
	end

	GiveConfig()

	-- Variable checking only occurs for new install and version number change
	if (not ZPerlConfigNew.ConfigVersion or ZPerlConfigNew.ConfigVersion ~= XPerl_VersionNumber) then
		XPerl_pcall(XPerl_UpgradeSettings)
		ZPerlConfigNew.ConfigVersion = XPerl_VersionNumber
	end

	ImportOldConfigs = nil
	XPerl_ImportOldConfig = nil
	XPerl_UpgradeSettings = nil

	XPerl_pcall(XPerl_ValidateSettings)
end
	


local function startupCheckSettings(self,event)
	ZPerl_Init()
	XPerl_BlizzFrameDisable = nil
	XPerl_RegisterLDB()

	lastConfigMode = ZPerlConfigSavePerCharacter
	XPerl_Globals_AddonLoaded = nil
end

function ZPerl_ForceImportAll()
	if IsAddOnLoaded("XPerl") then
		if (XPerlConfig) then
			ZPerlConfig = XPerlConfig
		end
		if (XPerlConfig_Global) then
			ZPerlConfig_Global = XPerlConfig_Global
		end
		if (XPerlConfigNew) then
			ZPerlConfigNew = XPerlConfigNew
		end
		if (XPerlConfigSavePerCharacter) then
			ZPerlConfigSavePerCharacter = XPerlConfigSavePerCharacter
		end
		DisableAddOn("XPerl")
		print("Z-Perl: Profile importing done, please reload you UI for the process to complete.")
	else
		print("X-Perl is not loaded. You must load it first, to access it's variables for the import.")
	end
end

-- XPerl_GetLayout
function XPerl_GetLayout(self, name)
	if (ZPerlConfigNew.savedPositions) then
		for realmName, realmList in pairs(ZPerlConfigNew.savedPositions) do
			for playerName, frames in pairs(realmList) do
				local find
				if (realmName == "saved") then
					find = playerName
				else
					find = format("%s(%s)", realmName, playerName)
				end

				if (name == find) then
					return frames
				end
			end
		end
	end
end

-- XPerl_LoadFrameLayout
function XPerl_LoadFrameLayout(name)
	local layout = XPerl_GetLayout(self, name)

	if (layout) then
		local name = UnitName("player")
		local realm = GetRealmName()

		if (not ZPerlConfigNew.savedPositions) then
			ZPerlConfigNew.savedPositions = { }
		end
		local c = ZPerlConfigNew.savedPositions
		if (not c[realm]) then
			c[realm] = { }
		end
		if (not c[realm][name]) then
			c[realm][name] = { }
		end

		XPerl_RestoreAllPositions()
	end
end

-- XPerl_Raid_GetGap
function XPerl_Raid_GetGap()
	if (XPerl_Raid_Grp2) then
		if (XPerlDB.raid.anchor == "TOP" or XPerlDB.raid.anchor == "BOTTOM") then
			return tonumber(floor(floor(((XPerl_Raid_Grp2:GetLeft() or 0) - (XPerl_Raid_Grp1:GetRight() or XPerl_Raid_Grp2:GetLeft() or 80) + 0.5) * 100) / 100))
		else
			return tonumber(floor((floor(((XPerl_Raid_Grp1:GetTop() or XPerl_Raid_Grp2:GetTop() or 200) - (XPerl_Raid_Grp2:GetBottom() or 200) + 0.5) * 100) / 100) - 46))
		end
	end
	return 0
end

-- XPerl_Globals_OnEvent
function XPerl_Globals_OnEvent(self, event, arg1, ...)
	if (event == "ADDON_LOADED" and arg1 == "ZPerl") then
		if not IsAddOnLoaded("XPerl") and (not ZPerlConfig and not ZPerlConfig_Global and not ZPerlConfigNew and not ZPerlConfigSavePerCharacter) then
			EnableAddOn("XPerl")
		end
		if IsAddOnLoaded("XPerl") and not ZPerlImportDone then
			if (XPerlConfig) then
				ZPerlConfig = XPerlConfig
			end
			if (XPerlConfig_Global) then
				ZPerlConfig_Global = XPerlConfig_Global
			end
			if (XPerlConfigNew) then
				ZPerlConfigNew = XPerlConfigNew
			end
			if (XPerlConfigSavePerCharacter) then
				ZPerlConfigSavePerCharacter = XPerlConfigSavePerCharacter
			end
			DisableAddOn("XPerl")
			ZPerlImportDone = true
			print("Z-Perl: Profile importing done, please reload you UI for the process to complete.")
		end
		if IsAddOnLoaded("XPerl") then
			DisableAddOn("XPerl")
		end
		self:UnregisterEvent(event)
		settingspart1(self, event)
	elseif (event == "PLAYER_LOGIN") then
		self:UnregisterEvent(event)
		startupCheckSettings(self,event)
		ZPerl_MinimapButton_Init(XPerl_MinimapButton_Frame)
		-- Load the player's layout, will be profile dependent later.
		local layout = format("%s(%s)", GetRealmName(), UnitName("player"))
		XPerl_LoadFrameLayout(layout)
	elseif (event == "PLAYER_ENTERING_WORLD") then
		self:UnregisterEvent(event)
		self:UnregisterAllEvents()
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:SetScript("OnEvent", onEventPostSetup)
		XPerl_Globals_OnEvent = nil
	end
end

-- XPerl_SetMyGlobal
function XPerl_SetMyGlobal()
	local realm = GetRealmName()

	if (not lastConfigMode and ZPerlConfigSavePerCharacter) then
		if (not ZPerlConfigNew[realm]) then
			ZPerlConfigNew[realm] = {}
		end
		if (ZPerlConfigNew.global) then
			ZPerlConfigNew[realm][playerName] = XPerl_CopyTable(ZPerlConfigNew.global)
		else
			XPerl_LoadOptions()
			ZPerlConfigNew[realm][playerName] = {}
			XPerl_Options_Defaults(ZPerlConfigNew[realm][playerName])
		end

	elseif (lastConfigMode and not ZPerlConfigSavePerCharacter) then
		if (ZPerlConfigNew[realm] and ZPerlConfigNew[realm][playerName]) then
			ZPerlConfigNew.global = XPerl_CopyTable(ZPerlConfigNew[realm][playerName])
		else
			XPerl_LoadOptions()
			ZPerlConfigNew.global = {}
			XPerl_Options_Defaults(ZPerlConfigNew.global)
		end
	end

	lastConfigMode = ZPerlConfigSavePerCharacter

	GiveConfig()
end

-- XPerl_LoadOptions
function XPerl_LoadOptions()
	if (not IsAddOnLoaded("ZPerl_Options")) then
		EnableAddOn("ZPerl_Options")
		local ok, reason = LoadAddOn("ZPerl_Options")

		if (not ok) then
			XPerl_Notice("Failed to load Z-Perl Options ("..tostring(reason)..")")
		--[[else
			collectgarbage()]]			-- Reclaims about 1.4Mb from loading options
		end
	end

	return XPerl_Options_Defaults
end

-- XPerl_ImportOldConfig
function XPerl_ImportOldConfig(old)
	if (XPerl_LoadOptions()) then
		return XPerl_Options_ImportOldConfig(old)
	end

	return {}
end

-- XPerl_Defaults()
function XPerl_Defaults(new)
	if (XPerl_LoadOptions()) then
		XPerl_Options_Defaults(new)
	end
end

-- XPerl_UpgradeSettings
function XPerl_UpgradeSettings()
	if (XPerl_LoadOptions()) then
		XPerl_Options_UpgradeSettings()
	end
end

-- XPerl_ValidateSettings()
function XPerl_ValidateSettings()

	local function validate(set)
		if (set) then
			if (not set.buffs) then
				set.buffs = {enable = 1, size = 20, maxrows = 2}
			else
				if (not set.buffs.size) then
					set.buffs.size = 20
				end
				if (not set.buffs.maxrows) then
					set.buffs.maxrows = 2
				end
			end
			if (not set.debuffs) then
				set.debuffs = {enable = 1, size = 20}
			elseif (not set.debuffs.size) then
				set.debuffs.size = set.buffs.size
			end

			if (not set.healerMode) then
				set.healerMode = {type = 1}
			end
			if (not set.size) then
				set.size = {width = 0}
			end
		end
	end

	local list = {"player", "pet", "party", "partypet", "target", "focus", "targettarget", "targettargettarget", "focustarget", "pettarget", "raid"}

	for k, v in pairs(list) do
		validate(conf[v])
	end

	if (not conf.pet) then
		conf.pet = {enable = 1}
	end
	if (not conf.pet.castBar) then
		conf.pet.castBar = {enable = 1}
	end

	if (conf.colour and not conf.colour.gradient) then
		conf.colour.gradient = {
			enable = 1,
			s = {r = 0.25, g = 0.25, b = 0.25, a = 1},
			e = {r = 0.1, g = 0.1, b = 0.1, a = 0}
		}
	end

	XPerl_ValidateSettings = nil
end
