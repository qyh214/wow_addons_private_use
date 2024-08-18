--------------------------------------------------------------------------------
-- Module declaration
--

local mod, CL = BigWigs:NewBoss("Loatheb", 533, 1606)
if not mod then return end
mod:RegisterEnableMob(16011)
mod:SetEncounterID(1115)
-- mod:SetRespawnTime(0) -- resets, doesn't respawn

--------------------------------------------------------------------------------
-- Locals
--

local doomTime = false
local sporeCount = 1
local doomCount = 1
local sporeTime = 15.8

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale()
if L then
	L.doomtime_bar = "Doom every 15 sec"
	L.doomtime_now = "Doom now happens every 15 sec!"

	L.spore_warn = "Spore (%d)"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{55593, "TANK_HEALER"}, -- Necrotic Aura
		29865, -- Deathbloom
		29204, -- Inevitable Doom
		29234, -- Summon Spore
		"berserk",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "NecroticAuraApplied", 55593)
	self:Log("SPELL_AURA_REMOVED", "NecroticAuraRemoved", 55593)
	self:Log("SPELL_CAST_SUCCESS", "Deathbloom", 29865, 55053)
	self:Log("SPELL_CAST_SUCCESS", "Doom", 29204, 55052)
	self:Log("SPELL_CAST_SUCCESS", "Spore", 29234)
end

function mod:OnEngage(diff)
	doomTime = false
	sporeCount = 1
	doomCount = 1
	sporeTime = diff == 3 and 35.5 or 15.8

	self:Berserk(721, true)
	-- Inevitable Doom
	if diff == 3 then
		self:Message(29204, "yellow", CL.custom_start:format(self.displayName, self:SpellName(29204), 2), false)
		self:Bar(29204, 120, CL.count:format(self:SpellName(29204), doomCount))
	else
		self:Message(29204, "yellow", CL.custom_start_s:format(self.displayName, self:SpellName(29204), 90), false)
		self:Bar(29204, 90, CL.count:format(self:SpellName(29204), doomCount))
	end
	self:Bar(29204, 300, L.doomtime_bar)
	self:ScheduleTimer("UpdateDoomTimer", 300)

	self:Bar(29865, 6.5) -- Deathbloom
	self:Bar(55593, 10) -- Necrotic Aura
	self:Bar(29234, 10, CL.count:format(self:SpellName(29234), sporeCount), "spell_nature_regeneration_02")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:NecroticAuraApplied(args)
	if self:Me(args.destGUID) then
		self:Message(55593, "red")
		self:TargetBar(55593, 17, args.spellName)
	end
end

function mod:NecroticAuraRemoved(args)
	if self:Me(args.destGUID) then
		self:Message(55593, "green", CL.removed:format(args.spellName))
		self:PlaySound(55593, "info")
		self:Bar(55593, 3.7)
	end
end

function mod:Deathbloom(args)
	self:Message(29865, "yellow")
	self:PlaySound(29865, "alert")
	self:Bar(29865, 30.5)
end

function mod:UpdateDoomTimer()
	doomTime = true
	self:Message(29204, "red", L.doomtime_now)
	self:PlaySound(29204, "long")
end

function mod:Doom(args)
	self:StopBar(CL.count:format(args.spellName, doomCount))
	self:Message(29204, "orange", CL.count:format(args.spellName, doomCount))
	self:PlaySound(29204, "alarm")
	doomCount = doomCount + 1
	local cd = 30.4
	if doomTime then
		-- 15s average, lol
		if self:Difficulty() == 3 then
			cd = doomCount % 2 == 0 and 13.4 or 17.0
		else -- one extra cast
			cd = doomCount % 2 == 0 and 18.3 or 12.2
		end
	end
	self:Bar(29204, cd, CL.count:format(args.spellName, doomCount))
end

function mod:Spore(args)
	self:StopBar(CL.count:format(args.spellName, sporeCount))
	self:Message(29234, "green", L.spore_warn:format(sporeCount), "spell_nature_regeneration_02")
	sporeCount = sporeCount + 1
	self:Bar(29234, sporeTime, CL.count:format(args.spellName, sporeCount), "spell_nature_regeneration_02")
end
