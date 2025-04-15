--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Lillian Voss", 2856)
if not mod then return end
mod:RegisterEnableMob(243021)
mod:SetEncounterID(3190)
mod:SetRespawnTime(15)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Lillian Voss"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		1233847, -- Scarlet Grasp
		1232192, -- Debilitate
		{1233901, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Noxious Poison
		{1233849, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Unstable Concoction
		{1233883, "EMPHASIZE"}, -- Intoxicating Venom
		1234540, -- Ignite
		"berserk",
	},nil,{
		[1233847] = CL.pull_in, -- Scarlet Grasp (Pull In)
		[1233883] = CL.keep_moving, -- Intoxicating Venom (Keep moving)
		[1234540] = CL.spread, -- Ignite (Spread)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
	self:SetSpellRename(1233847, CL.pull_in) -- Scarlet Grasp (Pull In)
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "ScarletGrasp", 1233847)
	self:Log("SPELL_AURA_APPLIED", "DebilitateApplied", 1232192)
	self:Log("SPELL_AURA_APPLIED", "NoxiousPoisonApplied", 1233901)
	self:Log("SPELL_AURA_REMOVED", "NoxiousPoisonRemoved", 1233901)
	self:Log("SPELL_CAST_SUCCESS", "UnstableConcoction", 1233849)
	self:Log("SPELL_AURA_APPLIED", "UnstableConcoctionApplied", 1233849)
	self:Log("SPELL_AURA_REMOVED", "UnstableConcoctionRemoved", 1233849)
	self:Log("SPELL_AURA_APPLIED", "IntoxicatingVenomApplied", 1233883)
	self:Log("SPELL_AURA_REMOVED", "IntoxicatingVenomRemoved", 1233883)
	self:Log("SPELL_CAST_SUCCESS", "Ignite", 1234540)
end

function mod:OnEngage()
	self:CDBar(1233849, 30) -- Unstable Concoction
	self:CDBar(1233847, 34, CL.pull_in) -- Scarlet Grasp
	self:Berserk(180)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:ScarletGrasp(args)
	self:CDBar(args.spellId, 30, CL.pull_in)
	self:Message(args.spellId, "red", CL.extra:format(args.spellName, CL.pull_in))
	self:PlaySound(args.spellId, "long")
end

function mod:DebilitateApplied(args)
	self:TargetMessage(1232192, "orange", args.destName)
end

function mod:NoxiousPoisonApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:Say(args.spellId, nil, nil, "Noxious Poison")
		self:SayCountdown(args.spellId, 8)
		self:PlaySound(args.spellId, "alarm", nil, args.destName)
	end
end

function mod:NoxiousPoisonRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
end

function mod:UnstableConcoction(args)
	self:CDBar(args.spellId, 30)
end

function mod:UnstableConcoctionApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:Say(args.spellId, nil, nil, "Unstable Concoction")
		self:SayCountdown(args.spellId, 7)
		self:PlaySound(args.spellId, "alert", nil, args.destName)
	end
end

function mod:UnstableConcoctionRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
end

do
	local prev = 0
	function mod:IntoxicatingVenomApplied(args)
		if self:Me(args.destGUID) then
			local disableEmphasize = true
			if args.time - prev > 10 then -- Only emphasize the first as it gets applied/removed a lot in a short period of time
				prev = args.time
				disableEmphasize = false
			end
			self:Message(args.spellId, "blue", CL.keep_moving, nil, disableEmphasize)
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		end
	end
end

function mod:IntoxicatingVenomRemoved(args)
	if self:Me(args.destGUID) then
		self:Message(args.spellId, "green", CL.safe_to_stop, nil, true) -- Disable emphasize
	end
end

function mod:Ignite(args)
	self:Message(args.spellId, "yellow", CL.extra:format(args.spellName, CL.spread))
	self:PlaySound(args.spellId, "info")
end
