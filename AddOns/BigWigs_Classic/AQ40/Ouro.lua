--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ouro", 531, 1550)
if not mod then return end
mod:RegisterEnableMob(15517)
mod:SetEncounterID(716)
mod:SetRespawnTime(70)

--------------------------------------------------------------------------------
-- Locals
--

local scarabCount = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.engage_message = "Ouro engaged! Possible Submerge in 90sec!"
	L.possible_submerge_bar = "Possible submerge"

	L.emerge_message = "Ouro has emerged"
	L.emerge_bar = "Emerge"

	L.submerge_message = "Ouro has submerged"
	L.submerge_bar = "Submerge"

	L.scarab = "Scarab Despawn"
	L.scarab_desc = "Warn for Scarab Despawn."
	L.scarab_icon = "inv_misc_ahnqirajtrinket_01"
	L.scarab_bar = "Scarabs despawn"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		26103, -- Sweep
		26102, -- Sand Blast
		26615, -- Berserk
		"scarab",
		"stages",
	},nil,{
		[26103] = CL.knockback, -- Sweep (Knockback)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "Sweep", 26103)
	self:Log("SPELL_CAST_START", "SandBlast", 26102)
	self:Log("SPELL_AURA_APPLIED", "BerserkApplied", 26615)
	self:Log("SPELL_CAST_SUCCESS", "SummonOuroMounds", 26058) -- Submerge
	self:Log("SPELL_SUMMON", "SummonOuroScarabs", 26060) -- Emerge
end

function mod:OnEngage()
	scarabCount = 0
	self:RegisterEvent("UNIT_HEALTH")
	self:Message("stages", "yellow", L.engage_message, false)
	self:Bar("stages", 90, L.possible_submerge_bar, "misc_arrowdown")
	self:Bar("stages", 180, L.submerge_bar, "misc_arrowdown")
	self:CDBar(26103, 22.6, CL.knockback) -- Sweep
	self:CDBar(26102, 24.2) -- Sand Blast
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Sweep(args)
	self:Message(args.spellId, "orange", CL.knockback)
	self:DelayedMessage(args.spellId, 16, "orange", CL.custom_sec:format(CL.knockback, 5))
	self:Bar(args.spellId, 21, CL.knockback)
	self:PlaySound(args.spellId, "alarm")
end

function mod:SandBlast(args)
	self:Message(args.spellId, "red")
	self:DelayedMessage(args.spellId, 17, "red", CL.custom_sec:format(args.spellName, 5))
	self:CDBar(args.spellId, 22)
	self:PlaySound(args.spellId, "alert")
end

function mod:BerserkApplied(args)
	self:StopBar(L.possible_submerge_bar)
	self:StopBar(L.submerge_bar)
	self:RemoveLog("SPELL_SUMMON", 26060) -- Summon Ouro Scarabs (Emerge) | He summons scarabs regularly after berserk without submerging
	self:Message(args.spellId, "yellow", CL.percent:format(20, args.spellName))
	self:PlaySound(args.spellId, "info")
end

function mod:SummonOuroMounds() -- Submerge
	self:CancelDelayedMessage(CL.custom_sec:format(CL.knockback, 5)) -- Sweep
	self:CancelDelayedMessage(CL.custom_sec:format(self:SpellName(26102), 5)) -- Sand Blast
	self:StopBar(L.possible_submerge_bar)
	self:StopBar(L.submerge_bar)
	self:StopBar(CL.knockback) -- Sweep
	self:StopBar(26102) -- Sand Blast

	self:Message("stages", "cyan", L.submerge_message, "misc_arrowdown")
	self:Bar("stages", 30, L.emerge_bar, "misc_arrowlup")

	self:PlaySound("stages", "long")
end

do
	local prev = 0
	function mod:SummonOuroScarabs(args) -- Emerge
		if args.time - prev > 5 then
			prev = args.time
			self:StopBar(L.emerge_bar)

			self:Message("stages", "cyan", L.emerge_message, "misc_arrowlup")
			self:Bar("stages", 90, L.possible_submerge_bar, "misc_arrowdown")
			self:Bar("stages", 180, L.submerge_bar, "misc_arrowdown")

			-- Sweep
			self:DelayedMessage(26103, 16, "orange", CL.custom_sec:format(CL.knockback, 5))
			self:Bar(26103, 21, CL.knockback)

			-- Sand Blast
			self:DelayedMessage(26102, 17, "red", CL.custom_sec:format(self:SpellName(26102), 5))
			self:Bar(26102, 22)

			-- Scarab Despawn
			scarabCount = scarabCount + 1
			self:Bar("scarab", 60, CL.count:format(L.scarab_bar, scarabCount), L.scarab_icon)

			self:PlaySound("stages", "long")
		end
	end
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 15517 then
		local hp = self:GetHealth(unit)
		if hp < 25 then
			self:UnregisterEvent(event)
			if hp > 20 then
				self:Message(26615, "green", CL.soon:format(self:SpellName(26615)), false)
			end
		end
	end
end
