local RSA = LibStub("AceAddon-3.0"):NewAddon("RSA", "AceConsole-3.0", "LibSink-2.0", "AceEvent-3.0", "AceComm-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RSA")
local _, PlayerClass = UnitClass('player')
local ModuleName

function RSA:TempOptions()
	-- Register Various Options
	local Options = {
		type = "group",
		name = "RSA [|c5500DBBDRaeli's Spell Announcer|r] - ".."|cffFFCC00"..L["Current Version: %s"]:format("r|r|c5500DBBD"..RSA.db.global.revision).."|r",
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
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RSA_Blizz", "RSA")
end

function RSA:ChatCommand(input)
	if not InCombatLockdown() then
		if not IsAddOnLoaded("RSA_Options") then
			local loaded, reason = LoadAddOn("RSA_Options")
			if not loaded then
				ChatFrame1:AddMessage(L["%s is disabled. If you want to configure RSA, you need to enable it."]:format("|cFFFF75B3RSA|r [|cffFFCC00Options|r]"))
			else
				LibStub("AceConfigDialog-3.0"):Open("RSA")
			end
		else
			LibStub("AceConfigDialog-3.0"):Open("RSA")
		end
	end
end

function RSA:RefreshConfig()
	local Modules = {
		["DEATHKNIGHT"] = "DeathKnight",
		["DEMONHUNTER"] = "DemonHunter",
		["DRUID"] = "Druid",
		["HUNTER"] = "Hunter",
		["MAGE"] = "Mage",
		["MONK"] = "Monk",
		["PALADIN"] = "Paladin",
		["PRIEST"] = "Priest",
		["ROGUE"] = "Rogue",
		["SHAMAN"] = "Shaman",
		["WARLOCK"] = "Warlock",
		["WARRIOR"] = "Warrior",
	}
	for k,v in pairs(Modules) do
		if k == PlayerClass then
			ModuleName = RSA:GetModule(v)
			ModuleName:Disable()
			ModuleName:Enable()
		end
	end

	RSA.db.profile = self.db.profile
	RSA:FixDB()
	RSA:UpdateOptions()


	if RSA.db.profile.Modules.Reminders == true then
		local loaded, reason = LoadAddOn("RSA_Reminders")
		if not loaded then
			if reason == "DISABLED" or reason == "INTERFACE_VERSION" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Reminders "..L.OptionsDisabled)
			elseif reason == "MISSING" or reason == "CORRUPT" then
				ChatFrame1:AddMessage("|cFFFF75B3RSA:|r Reminders "..L.OptionsMissing)
			end
		else
			RSA:EnableModule("Reminders")
		end
	else
		if LoadAddOn("RSA_Reminders") == 1 then
			RSA:DisableModule("Reminders")
		end
	end
end
