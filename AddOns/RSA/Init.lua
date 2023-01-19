local RSA = LibStub("AceAddon-3.0"):NewAddon("RSA", "AceConsole-3.0", "LibSink-2.0", "AceEvent-3.0", "AceComm-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RSA")
local ACD = LibStub('AceConfigDialog-3.0')
local uClass = string.lower(select(2, UnitClass('player')))

RSA.configData = {}
RSA.monitorData = {}

local function BuildDefaults()
	local defaults = {
		profile = {
			deathknight = RSA.configData.deathknight or {},
			demonhunter = RSA.configData.demonhunter or {},
			druid = RSA.configData.druid or {},
			evoker = RSA.configData.evoker or {},
			hunter = RSA.configData.hunter or {},
			mage = RSA.configData.mage or {},
			monk = RSA.configData.monk or {},
			paladin = RSA.configData.paladin or {},
			priest = RSA.configData.priest or {},
			rogue = RSA.configData.rogue or {},
			shaman = RSA.configData.shaman or {},
			warlock = RSA.configData.warlock or {},
			warrior = RSA.configData.warrior or {},
			racials = RSA.configData.racials or {},
			utilities = RSA.configData.utilities or {},
			general = {
				advancedConfig = false,
				globalAnnouncements = {
					--useGlobal = true, -- Implement as button in config to toggle this ON for all sub spells.
					alwaysWhisper = false, -- Allows whispers to always be sent.
					removeServerNames = true,
					enableIn = {
						arenas = false,
						bgs = false,
						warModeWorld = false, -- Enable in War Mode world zones.
						nonWarWorld = false, -- Enable in world zones without war mode enabled.
						dungeons = false,
						raids = false,
						lfg = false,
						lfr = false,
						scenarios = false,
					},
					groupToggles = { -- When true, only announce to these channels if you are in a group
						emote = true,
						say = true,
						yell = true,
						whisper = true,
					},
					combatState = {
						inCombat = true, -- Announce only in Combat
						noCombat = false, -- Announce not in Combat
					},
				},
				replacements = {
					target = {
						alwaysUseName = false,
						replacement = "You",
					},
					missType = {
						useGeneralReplacement = false,
						generalReplacement = "missed",
						miss = "missed",
						resist = "was resisted by",
						absorb = "was absorbed by",
						block = "was blocked by",
						deflect = "was deflected by",
						dodge = "was dodged by",
						evade = "was evaded by",
						parry = "was parried by",
						immune = "is immune to",
						reflect = "was reflected by",
					},
				},
			},
		},
	}

	return defaults
end

local function BlizzPanelOptions()
	-- Register Various Options
	local Options = {
		type = "group",
		name = "RSA [|c5500DBBDRaeli's Spell Announcer|r] - ".."|cffFFCC00"..L["Current Version: %s"]:format("|r|c5500DBBD"..RSA.db.global.version).."|r",
		order = 0,
		args = {
				Open = {
					name = L["Open Configuration Panel"],
					type = "execute",
					order = 0,
					func = function()
						if not InCombatLockdown() then
							-- Ensure we don't taint the UI from 8.2 change when trying to call HideUIPanel in combat
							HideUIPanel(InterfaceOptionsFrame)
							HideUIPanel(GameMenuFrame)
							RSA:ChatCommand()
						end
					end,
				},
			},
		}
	LibStub("AceConfig-3.0"):RegisterOptionsTable("RSA_Blizz", Options) -- Register Options
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RSA_Blizz", "RSA")
end

function RSA.IsRetail()
	return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
end

function RSA.IsWrath()
	return WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
end

function RSA:ChatCommand(input)
	if not InCombatLockdown() then
		self:EnableModule('Options')
		if ACD.OpenFrames['RSA'] then
			ACD:Close('RSA')
		else
			ACD:Open('RSA')
		end
	else
		RSA.SendMessage.ChatFrame(L["Cannot configure while in combat."])
	end
end

function RSA:OnInitialize()

	RSA.configData.customCategories = {
		['General'] = {

		},
	}
	RSA.monitorData.customCategories = {
		['General'] = {

		},
	}

	local defaults = BuildDefaults()

	self.db = LibStub("AceDB-3.0"):New("RSA5", defaults, UnitClass('player')) -- Setup Saved Variables
	self:SetSinkStorage(self.db.profile) -- Setup Saved Variables for LibSink

	RSA.monitorData['racials'] = RSA.PrepareDataTables(self.db.profile['racials'], 'racials')
	RSA.monitorData['utilities'] = RSA.PrepareDataTables(self.db.profile['utilities'], 'utilities')
	RSA.monitorData[uClass] = RSA.PrepareDataTables(self.db.profile[uClass], uClass)

	-- project-revision
	self.db.global.version = GetAddOnMetadata("RSA","Version")

	if not RSA.db.global.personalID then
		RSA.db.global.personalID = RSA.GetPersonalID() --RSA.GetGetMyRandomNumber()
	end

	local LibDualSpec = LibStub('LibDualSpec-1.0')
	LibDualSpec:EnhanceDatabase(self.db, "RSA")

	self:RegisterChatCommand("RSA", "ChatCommand")

	BlizzPanelOptions()

	-- Profile Management
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

	RSA.Comm.Registry()

	RSA.Monitor.Start()
end