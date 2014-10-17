-- X-Perl UnitFrames
-- Author: Zek <Boodhoof-EU>
-- License: GNU GPL v3, 29 June 2007 (see LICENSE.txt)

XPerlLocked		= 1
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

XPerl_SetModuleRevision("$Revision: 791 $")

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

	if (XPerlConfigSavePerCharacter) then
		if (not XPerlConfigNew[GetRealmName()]) then
			XPerlConfigNew[GetRealmName()] = {}
		end

		if (not XPerlConfigNew[GetRealmName()][playerName] or not QuickValidate(XPerlConfigNew[GetRealmName()][playerName])) then
			local new = {}
			XPerl_Defaults(new)
			XPerlConfigNew[GetRealmName()][playerName] = new		-- TODO use last used config
		end

		ret = XPerlConfigNew[GetRealmName()][playerName]
	else
		if (not XPerlConfigNew.global or not QuickValidate(XPerlConfigNew.global)) then
			local new = {}
			XPerl_Defaults(new)
			XPerlConfigNew.global = new					-- TODO use last used config
		end

		ret = XPerlConfigNew.global
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

	if (XPerlConfigSavePerCharacter) then
		XPerlConfigNew[GetRealmName()][playerName] = conf
	else
		XPerlConfigNew.global = conf
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

	local new = XPerl_GetReusableTable()

	for k,v in pairs(old) do
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
	if (XPerlConfig_Global) then
		-- Convert old global configs
		XPerlConfigNew = {}

		for realm,realmList in pairs(XPerlConfig_Global) do
			XPerlConfigNew[realm] = {}
			for player,settings in pairs(realmList) do
				XPerlConfigNew[realm][player] = XPerl_ImportOldConfig(settings)
			end
		end

		XPerlConfig_Global = nil
	end
	if (XPerlConfig) then
		-- Convert old config
		if (not XPerlConfigNew) then
			XPerlConfigNew = {}
		end

		if (XPerlConfig) then
			XPerlConfigNew.global = XPerl_ImportOldConfig(XPerlConfig)
			XPerlConfig = nil
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

        --WoW 4.0 UNIT_POWER change, thanks Brounks helps me fix this.
        
        
        --local events = {"UNIT_POWER", "UNIT_MAXPOWER", "UNIT_HEALTH", "UNIT_MAXHEALTH",
        --                "UNIT_LEVEL", "UNIT_DISPLAYPOWER", "UNIT_NAME_UPDATE"}

        --if (self ~= XPerl_Player or not GetCVarBool("predictedPower")) then
        --        tinsert(events, "UNIT_POWER")
        --end
   
	local events = { "UNIT_POWER", "UNIT_MAXPOWER", "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_LEVEL", "UNIT_DISPLAYPOWER", "UNIT_NAME_UPDATE"}

        if (self ~= XPerl_Player or not GetCVarBool("predictedPower")) then
                tinsert(events, "UNIT_POWER")
        end
               
	XPerl_UnitEvents(self, eventArray, events)
end

--[[
-- XPerl_GuildStatusUpdate()
function XPerl_GuildRoster_Update()
	if (conf.colour.class and conf.colour.guildList) then
		local col = _G.GuildRosterColumnButton4
		if (_G.GuildFrame.selectedTab ~= 2 or not col or col.sortType ~= "zone") then
			return
		end

		local myZone = GetRealZoneText()

		local scrollFrame = GuildRosterContainer
		local offset = HybridScrollFrame_GetOffset(scrollFrame)
		local buttons = scrollFrame.buttons
		local numButtons = #buttons
		local button, index, class
		local totalMembers, onlineMembers = GetNumGuildMembers()
		local selectedGuildMember = GetGuildRosterSelection()

		for i = 1, numButtons do
			button = buttons[i]
			index = offset + i
			local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile = GetGuildRosterInfo(index)

			local color = GetQuestDifficultyColor(level)
			if (online) then
				_G["GuildRosterContainerButton"..i.."String1"]:SetTextColor(color.r, color.g, color.b)
			else
				_G["GuildRosterContainerButton"..i.."String1"]:SetTextColor(color.r / 2, color.g / 2, color.b / 2)
			end

			if (zone == myZone) then
				if (online) then
					_G["GuildRosterContainerButton"..i.."String3"]:SetTextColor(0, 1, 0)
				else
					_G["GuildRosterContainerButton"..i.."String3"]:SetTextColor(0, 0.5, 0)
				end
			end

		end
	end
end

if (_G.GuildRoster_Update) then
	hooksecurefunc("GuildRoster_Update", XPerl_GuildRoster_Update)
end ]]

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
		--print("dsadasd")
		if (XPerl_OutOfCombatOptionSet) then
			XPerl_OutOfCombatOptionSet = nil
			XPerl_OptionActions()
		end
		for func,arg in pairs(XPerl_OutOfCombatQueue) do
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


local function settingspart1(self,event)
	playerName = UnitName("player")
	self:UnregisterEvent(event)

	local newUser = not XPerlConfigNew and not XPerlConfig

	if (not XPerlConfigNew) then
		if (XPerlConfig_Global or XPerlConfig) then
			XPerl_pcall(ImportOldConfigs)
		else
			XPerlConfigNew = {}
		end
	end

	GiveConfig()

	-- Variable checking only occurs for new install and version number change
	if (not XPerlConfigNew.ConfigVersion or XPerlConfigNew.ConfigVersion ~= XPerl_VersionNumber) then
		XPerl_pcall(XPerl_UpgradeSettings)
		XPerlConfigNew.ConfigVersion = XPerl_VersionNumber
	end

	ImportOldConfigs = nil
	XPerl_ImportOldConfig = nil
	XPerl_UpgradeSettings = nil

	XPerl_pcall(XPerl_ValidateSettings)
end
	


local function startupCheckSettings(self,event)


	XPerl_Init()
	XPerl_BlizzFrameDisable = nil
	XPerl_RegisterLDB()

	lastConfigMode = XPerlConfigSavePerCharacter
	XPerl_Globals_AddonLoaded = nil
end

-- XPerl_Globals_OnEvent
function XPerl_Globals_OnEvent(self, event, arg1, ...)

	--if (event == "VARIABLES_LOADED") then
	if (event == "ADDON_LOADED" and arg1 == "XPerl") then
		self:UnregisterEvent(event)
		settingspart1(self,event)
		-- Tell DHUD to hide Blizzard default Player and Target frames
		if (type(DHUD_Config) == "table") then
			if (XPerl_Player) then
				DHUD_Config["bplayer"] = 0
			end
			if (XPerl_Target) then
				DHUD_Config["btarget"] = 0
			end
		end

--	elseif (event == "ADDON_LOADED") then
--		if (arg1 == "Blizzard_GuildUI") then
--			hooksecurefunc("GuildRoster_Update", XPerl_GuildRoster_Update)
--		end

	elseif (event == "PLAYER_LOGIN") then
		self:UnregisterEvent(event)
		startupCheckSettings(self,event)
		XPerl_MinimapButton_Init(XPerl_MinimapButton_Frame)

	elseif (event == "PLAYER_ENTERING_WORLD") then
		self:UnregisterEvent(event)
		self:UnregisterAllEvents();
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
		self:SetScript("OnEvent", onEventPostSetup)
		XPerl_Globals_OnEvent = nil
	end
end

-- XPerl_SetMyGlobal
function XPerl_SetMyGlobal()
	local realm = GetRealmName()

	if (not lastConfigMode and XPerlConfigSavePerCharacter) then
		if (not XPerlConfigNew[realm]) then
			XPerlConfigNew[realm] = {}
		end
		if (XPerlConfigNew.global) then
			XPerlConfigNew[realm][playerName] = XPerl_CopyTable(XPerlConfigNew.global)
		else
			XPerl_LoadOptions()
			XPerlConfigNew[realm][playerName] = {}
			XPerl_Options_Defaults(XPerlConfigNew[realm][playerName])
		end

	elseif (lastConfigMode and not XPerlConfigSavePerCharacter) then
		if (XPerlConfigNew[realm] and XPerlConfigNew[realm][playerName]) then
			XPerlConfigNew.global = XPerl_CopyTable(XPerlConfigNew[realm][playerName])
		else
			XPerl_LoadOptions()
			XPerlConfigNew.global = {}
			XPerl_Options_Defaults(XPerlConfigNew.global)
		end
	end

	lastConfigMode = XPerlConfigSavePerCharacter

	GiveConfig()
end

-- XPerl_LoadOptions
function XPerl_LoadOptions()
	if (not IsAddOnLoaded("XPerl_Options")) then
		EnableAddOn("XPerl_Options")
		local ok, reason = LoadAddOn("XPerl_Options")

		if (not ok) then
			XPerl_Notice("Failed to load X-Perl Options ("..tostring(reason)..")")
		else
			collectgarbage()			-- Reclaims about 1.4Mb from loading options
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

	for k,v in pairs(list) do
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
			enable	= 1,
			s	= {r = 0.25, g = 0.25, b = 0.25, a = 1},
			e	= {r = 0.1, g = 0.1, b = 0.1, a = 0}
		}
	end

	XPerl_ValidateSettings = nil
end
