--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ruins of Ahn'Qiraj Trash", 509)
if not mod then return end
mod.displayName = CL.trash
mod:RegisterEnableMob(15355) -- Anubisath Guardian

--------------------------------------------------------------------------------
-- Locals
--

local guardiansAlive = 8

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.guardian = "Anubisath Guardian"

	L["22997_desc"] = 26556 -- 22997 has no description, so using an alternative

	L["17430_icon"] = "spell_nature_insectswarm" -- Summon Anubisath Swarmguard
	L["17431_icon"] = "ability_warrior_savageblow" -- Summon Anubisath Warrior
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{22997, "SAY", "ME_ONLY_EMPHASIZE"}, -- Plague
		24340, -- Meteor
		14297, -- Shadow Storm
		8732, -- Thunderclap
		8269, -- Frenzy / Enrage (different name on classic era)
		{25698, "EMPHASIZE", "COUNTDOWN"}, -- Explode
		17430, -- Summon Anubisath Swarmguard
		17431, -- Summon Anubisath Warrior
		"stages",
	},{
		[22997] = L.guardian,
	},{
		[25698] = CL.explosion, -- Explode (Explosion)
	}
end

function mod:OnBossEnable()
	guardiansAlive = 8
	self:RegisterMessage("BigWigs_OnBossEngage", "Disable")

	self:Log("SPELL_AURA_APPLIED", "PlagueApplied", 22997)
	self:Log("SPELL_AURA_REFRESH", "PlagueApplied", 22997)
	self:Log("SPELL_AURA_REMOVED", "PlagueRemoved", 22997)

	self:Log("SPELL_DAMAGE", "Meteor", 24340)
	self:Log("SPELL_MISSED", "Meteor", 24340)

	-- Shadow Storm has no (miss) event?
	self:Log("SPELL_DAMAGE", "ShadowStorm", 14297)
	self:Log("SPELL_MISSED", "ShadowStorm", 14297)

	self:Log("SPELL_DAMAGE", "Thunderclap", 8732)
	self:Log("SPELL_MISSED", "Thunderclap", 8732)

	self:Log("SPELL_AURA_APPLIED", "FrenzyEnrage", 8269)
	self:Log("SPELL_AURA_APPLIED", "ExplodeApplied", 25698)
	self:Log("SPELL_AURA_REMOVED", "ExplodeRemoved", 25698)

	self:Log("SPELL_SUMMON", "SummonAnubisathSwarmguard", 17430)
	self:Log("SPELL_SUMMON", "SummonAnubisathWarrior", 17431)

	self:Death("GuardianKilled", 15355)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:PlagueApplied(args)
	self:TargetMessage(args.spellId, "yellow", args.destName)
	self:TargetBar(args.spellId, 40, args.destName)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, nil, nil, "Plague")
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
end

function mod:PlagueRemoved(args)
	self:StopBar(args.spellName, args.destName)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, "removed")
	end
end

do
	local prev = 0
	function mod:Meteor(args)
		if args.time-prev > 12 then
			prev = args.time
			self:Message(args.spellId, "red")
			self:PlaySound(args.spellId, "info")
		end
	end
end

do
	local prev = 0
	function mod:ShadowStorm(args)
		if args.time-prev > 12 then
			prev = args.time
			self:Message(args.spellId, "red")
			self:PlaySound(args.spellId, "alarm")
		end
	end
end

do
	local prev = 0
	function mod:Thunderclap(args)
		if args.time-prev > 12 then
			prev = args.time
			self:Message(args.spellId, "orange")
			self:PlaySound(args.spellId, "alert")
		end
	end
end

function mod:FrenzyEnrage(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "long")
end

function mod:ExplodeApplied(args)
	self:Message(args.spellId, "orange", CL.explosion)
	self:Bar(args.spellId, 6, CL.explosion) -- Duration is 7s but it expires after 6s
	self:PlaySound(args.spellId, "long")
end

function mod:ExplodeRemoved()
	self:StopBar(CL.explosion)
end

function mod:SummonAnubisathSwarmguard(args)
	self:Message(args.spellId, "green", args.spellName, L["17430_icon"])
end

function mod:SummonAnubisathWarrior(args)
	self:Message(args.spellId, "green", args.spellName, L["17431_icon"])
end

function mod:GuardianKilled()
	guardiansAlive = guardiansAlive - 1
	self:Message("stages", "cyan", CL.mob_remaining:format(L.guardian, guardiansAlive), false)
end
