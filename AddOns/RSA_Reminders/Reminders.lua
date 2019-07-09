------------------------------------------------------
---- Raeli's Spell Announcer Buff Reminder Module ----
------------------------------------------------------
local RSA = LibStub("AceAddon-3.0"):GetAddon("RSA")
local L = LibStub("AceLocale-3.0"):GetLocale("RSA")
local RSA_R = RSA:NewModule("Reminders")
function RSA_R:OnInitialize()
	self.db = RSA.db
	-- Check what class we are and save it. Used to determine what options to show.
	local pClass = select(2, UnitClass("player"))
	self.db.profile.General.Class = pClass
	if RSA.db.profile.Modules.Reminders == true then -- Is the Reminders Module Enabled?
		RSA_R:SetEnabledState(true)
	else
		RSA_R:SetEnabledState(false)
	end
end -- End OnInitialize
function RSA_R:OnEnable()
	RSA.db.profile.Modules.Reminders_Loaded = true -- Set state to loaded, to know if we should announce when a spell is refreshed.
	local ReminderTimeElapsed = 0.0
	RSA.Reminder = CreateFrame("Frame", "RSA:R") -- Reminder Frame
	local ReminderSpell
	local function Reminder(self, elapsed) -- Reminder Function
		if RSA.db.profile.General.Class == "DEATHKNIGHT" then -- Check Class, Set the Spell we're reminding about.
			ReminderSpell = RSA.db.profile.DeathKnight.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "DRUID" then
			ReminderSpell = RSA.db.profile.Druid.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "HUNTER" then
			ReminderSpell = RSA.db.profile.Hunter.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "MAGE" then
			ReminderSpell = RSA.db.profile.Mage.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "MONK" then
			ReminderSpell = RSA.db.profile.Monk.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "PALADIN" then
			ReminderSpell = RSA.db.profile.Paladin.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "PRIEST" then
			ReminderSpell = RSA.db.profile.Priest.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "ROGUE" then
			ReminderSpell = RSA.db.profile.Rogue.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "SHAMAN" then
			ReminderSpell = RSA.db.profile.Shaman.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "WARLOCK" then
			ReminderSpell = RSA.db.profile.Warlock.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "WARRIOR" then
			ReminderSpell = RSA.db.profile.Warrior.Reminders.SpellName
		end
		if ReminderSpell == "" then return end -- If the player sets no spell, do nothing.
		if RSA.db.profile.Reminders.DisableInPvP == true and UnitIsPVP("player") then return end -- If Disabled in PvP is on, and we are in PvP, do nothing.
		ReminderTimeElapsed = ReminderTimeElapsed + elapsed
		if ReminderTimeElapsed < RSA.db.profile.Reminders.RemindInterval then return end -- Do nothing until we have reached the time set for the Reminder Interval.
		ReminderTimeElapsed = ReminderTimeElapsed - floor(ReminderTimeElapsed)
		local name = UnitBuff("player", ReminderSpell) -- Look for the Buff
		if name == ReminderSpell then -- If it's up, we can stop reminding, if we haven't done already.
			RSA.Reminder:SetScript("OnUpdate", nil)
		end
		if UnitIsDeadOrGhost("player") == 1 then return end -- If we're dead, we don't want to spam.
		if RSA.db.profile.Reminders.EnableInSpec1 == true then -- Enable in primary spec?
			if GetActiveSpecGroup("player") == 1 then -- Are we in that spec?
				if RSA.db.profile.Reminders.RemindChannels.Chat == true then
					RSA.Print_Self(ReminderSpell .. L[" is Missing!"])
				end
				if RSA.db.profile.Reminders.RemindChannels.RaidWarn == true then
					RSA.Print_Self_RW(ReminderSpell .. L[" is Missing!"])
				end
			end
		end
		if RSA.db.profile.Reminders.EnableInSpec2 == true then -- Enable in secondary spec?
			if GetActiveSpecGroup("player") == 2 then -- Are we in that spec?
				if RSA.db.profile.Reminders.RemindChannels.Chat == true then
					RSA.Print_Self(ReminderSpell .. L[" is Missing!"])
				end
				if RSA.db.profile.Reminders.RemindChannels.RaidWarn == true then
					RSA.Print_Self_RW(ReminderSpell .. L[" is Missing!"])
				end
			end
		end
	end
	RSA.Monitor = CreateFrame("Frame", "RSA:M") -- Monitor Frame
	local MonitorTimeElapsed = 0.0
	local function Monitor(self, elapsed) -- Monitor Function
		MonitorTimeElapsed = MonitorTimeElapsed + elapsed
		if MonitorTimeElapsed < RSA.db.profile.Reminders.CheckInterval then return end -- Have we reached the time set to Check for buffs yet?
		MonitorTimeElapsed = MonitorTimeElapsed - floor(MonitorTimeElapsed)
		if RSA.db.profile.General.Class == "DEATHKNIGHT" then -- Check Class, Set the Spell we're reminding about.
			ReminderSpell = RSA.db.profile.DeathKnight.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "DRUID" then
			ReminderSpell = RSA.db.profile.Druid.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "HUNTER" then
			ReminderSpell = RSA.db.profile.Hunter.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "MAGE" then
			ReminderSpell = RSA.db.profile.Mage.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "MONK" then
			ReminderSpell = RSA.db.profile.Monk.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "PALADIN" then
			ReminderSpell = RSA.db.profile.Paladin.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "PRIEST" then
			ReminderSpell = RSA.db.profile.Priest.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "ROGUE" then
			ReminderSpell = RSA.db.profile.Rogue.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "SHAMAN" then
			ReminderSpell = RSA.db.profile.Shaman.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "WARLOCK" then
			ReminderSpell = RSA.db.profile.Warlock.Reminders.SpellName
		elseif RSA.db.profile.General.Class == "WARRIOR" then
			ReminderSpell = RSA.db.profile.Warrior.Reminders.SpellName
		end
		if ReminderSpell == "" then return end -- If the buff is up, do nothing.
		local name = UnitBuff("player", ReminderSpell)
		if name ~= ReminderSpell then -- If the buff isn't up, start the Reminder!
			RSA.Reminder:SetScript("OnUpdate", Reminder)
		end
	end
	RSA.Monitor:SetScript("OnUpdate", Monitor)
end -- End OnEnable
function RSA_R:OnDisable() -- Stop running timers. We can't unload from memory, but we can stop the timers.
	RSA.Reload_Link("Reminders Module disabled, you should ", " your UI.") -- Send Message to remind the user to reload UI, with a reload hyperlink.
	RSA.db.profile.Modules.Reminders_Loaded = false
	RSA.Monitor:SetScript("OnUpdate", nil)
	RSA.Reminder:SetScript("OnUpdate", nil)
end -- End OnDisable
