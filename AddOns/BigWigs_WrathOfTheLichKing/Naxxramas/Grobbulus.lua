--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Grobbulus", 533, 1611)
if not mod then return end
mod:RegisterEnableMob(15931)
mod:SetEncounterID(1111)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.injection = "Injection"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{28169, "ICON", "SAY", "ME_ONLY_EMPHASIZE"}, -- Mutating Injection
		28240, -- Poison Cloud
		"adds",
		"berserk",
	},nil,{
		[28169] = L.injection, -- Mutating Injection (Injection)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "MutatingInjectionApplied", 28169)
	self:Log("SPELL_AURA_REMOVED", "MutatingInjectionRemoved", 28169)
	self:Log("SPELL_CAST_SUCCESS", "PoisonCloud", 28240)
	self:Log("SPELL_CAST_SUCCESS", "SlimeSpray", 28157, 54364) -- 10 player, 25 player
end

function mod:OnEngage()
	self:Berserk(540)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local prevTarget, prevApply = nil, 0
	function mod:MutatingInjectionApplied(args)
		prevTarget, prevApply = args.destGUID, args.time
		self:TargetMessage(args.spellId, "red", args.destName, L.injection)
		self:TargetBar(args.spellId, 10, args.destName, L.injection)
		self:PrimaryIcon(args.spellId, args.destName)
		if self:Me(args.destGUID) then
			self:Say(args.spellId, L.injection, nil, "Injection")
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		end
	end

	function mod:MutatingInjectionRemoved(args)
		self:StopBar(L.injection, args.destName)
		-- Next one is sometimes applied just before previous one expires
		if args.destGUID == prevTarget and args.time - prevApply < 9 then
			self:PrimaryIcon(args.spellId)
		end
		if self:Me(args.destGUID) then
			self:PersonalMessage(args.spellId, "removed", L.injection)
		end
	end
end

function mod:PoisonCloud(args)
	self:Message(args.spellId, "yellow")
	self:CDBar(args.spellId, 14.6) -- 14.6-16.2
	self:PlaySound(args.spellId, "info")
end

function mod:SlimeSpray() -- Adds
	self:Message("adds", "orange", CL.adds, false)
	self:PlaySound("adds", "long")
end
