--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Malygos", 616, 1617)
if not mod then return end
mod:RegisterEnableMob(28859)
-- mod:SetEncounterID(1094)
-- mod:SetRespawnTime(30)
mod.toggleOptions = {"phase", "sparks", "sparkbuff", "vortex", "breath", {"surge", "FLASH"}, 57429, "berserk"}

--------------------------------------------------------------------------------
-- Locals
--

local phase = nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.sparks = "Spark Spawns"
	L.sparks_desc = "Warns on Power Spark spawns."
	L.sparks_message = "Power Spark spawns!"
	L.sparks_warning = "Power Spark in ~5sec!"

	L.sparkbuff = "Power Spark on Malygos"
	L.sparkbuff_desc = "Warns when Malygos gets a Power Spark."
	L.sparkbuff_message = "Malygos gains Power Spark!"

	L.vortex = "Vortex"
	L.vortex_desc = "Warn for Vortex in phase 1."
	L.vortex_message = "Vortex!"
	L.vortex_warning = "Possible Vortex in ~5sec!"
	L.vortex_next = "Vortex Cooldown"

	L.breath = "Deep Breath"
	L.breath_desc = "Warn when Malygos is using Deep Breath in phase 2."
	L.breath_message = "Deep Breath!"
	L.breath_warning = "Deep Breath in ~5sec!"

	L.surge = "Surge of Power"
	L.surge_desc = "Warn when Malygos uses Surge of Power on you in phase 3."
	L.surge_you = "Surge of Power on YOU!"
	L.surge_trigger = "%s fixes his eyes on you!"

	L.phase = "Phases"
	L.phase_desc = "Warn for phase changes."
	L.phase2_warning = "Phase 2 soon!"
	L.phase2_trigger = "I had hoped to end your lives quickly"
	L.phase2_message = "Phase 2 - Nexus Lord & Scion of Eternity!"
	L.phase2_end_trigger = "ENOUGH! If you intend to reclaim Azeroth's magic"
	L.phase3_warning = "Phase 3 soon!"
	L.phase3_trigger = "Now your benefactors make their"
	L.phase3_message = "Phase 3!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Static", 57429)
	self:Log("SPELL_AURA_APPLIED", "Spark", 56152)
	self:Log("SPELL_CAST_SUCCESS", "Vortex", 56105)
	self:Death("Win", 28859)

	self:BossYell("Phase2", L["phase2_trigger"])
	self:BossYell("P2End", L["phase2_end_trigger"])
	self:BossYell("Phase3", L["phase3_trigger"])

	self:RegisterEvent("RAID_BOSS_WHISPER")
	self:RegisterEvent("RAID_BOSS_EMOTE")

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
end

function mod:OnEngage()
	phase = 1
	self:Bar("vortex", 29, L["vortex_next"], 56105)
	self:DelayedMessage("vortex", 24, "yellow", L["vortex_warning"])
	self:Bar("sparks", 25, L["sparks"], 56152)
	self:DelayedMessage("sparks", 20, "yellow", L["sparks_warning"])
	self:Berserk(600)
	self:RegisterEvent("UNIT_HEALTH")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Spark(args)
	if self:MobId(args.destGUID) == 28859 then
		self:MessageOld("sparkbuff", "red", nil, L["sparkbuff_message"], args.spellId)
	end
end

function mod:Static(args)
	if self:Me(args.destGUID) then
		self:MessageOld(args.spellId, "orange")
	end
end

function mod:Vortex(args)
	self:Bar("vortex", 10, L["vortex"], args.spellId)
	self:MessageOld("vortex", "yellow", nil, L["vortex_message"], args.spellId)
	self:Bar("vortex", 59, L["vortex_next"], args.spellId)
	self:DelayedMessage("vortex", 54, "yellow", L["vortex_warning"])

	self:Bar("sparks", 17, L["sparks"], 56152)
	self:DelayedMessage("sparks", 12, "yellow", L["sparks_warning"])
end

function mod:RAID_BOSS_WHISPER(event, msg, mob)
	if phase == 3 and msg == L["surge_trigger"] then
		self:MessageOld("surge", "blue", "alarm", L["surge_you"], 60936) -- 60936 for phase 3, not 56505
		self:Flash("surge", 60936)
	end
end

function mod:RAID_BOSS_EMOTE(event, msg)
	if phase == 1 then
		self:MessageOld("sparks", "red", "alert", L["sparks_message"], 56152)
		self:Bar("sparks", 30, L["sparks"], 56152)
		self:DelayedMessage("sparks", 25, "yellow", L["sparks_warning"])
	elseif phase == 2 then
		-- 43810 Frost Wyrm, looks like a dragon breathing 'deep breath' :)
		-- Correct spellId for 'breath" in phase 2 is 56505
		self:MessageOld("breath", "red", "alert", L["breath_message"], 43810)
		self:Bar("breath", 59, L["breath"], 43810)
		self:DelayedMessage("breath", 54, "yellow", L["breath_warning"])
	end
end

function mod:Phase2()
	phase = 2
	self:UnregisterEvent("UNIT_HEALTH")
	self:CancelDelayedMessage(L["vortex_warning"])
	self:CancelDelayedMessage(L["sparks_warning"])
	self:StopBar(L["sparks"])
	self:StopBar(L["vortex_next"])
	self:MessageOld("phase", "yellow", nil, L["phase2_message"], false)
	self:Bar("breath", 92, L["breath"], 43810)
	self:DelayedMessage("breath", 87, "yellow", L["breath_warning"])
end

function mod:P2End()
	self:CancelDelayedMessage(L["breath_warning"])
	self:StopBar(L["breath"])
	self:MessageOld("phase", "yellow", nil, L["phase3_warning"], false)
end

function mod:Phase3()
	phase = 3
	self:MessageOld("phase", "yellow", nil, L["phase3_message"], false)
end

function mod:UNIT_HEALTH(event, unit)
	if phase == 1 and self:MobId(self:UnitGUID(unit)) == 28859 then
		local hp = self:GetHealth(unit)
		if hp < 54 then
			self:MessageOld("phase", "yellow", nil, L["phase2_warning"], false)
			self:UnregisterEvent(event)
		end
	end
end

