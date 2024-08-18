--------------------------------------------------------------------------------
-- Module declaration
--

local mod, CL = BigWigs:NewBoss("Instructor Razuvious", 533, 1607)
if not mod then return end
mod:RegisterEnableMob(16061, 16803) -- Instructor Razuvious, Death Knight Understudy
mod:SetEncounterID(1113)

--------------------------------------------------------------------------------
-- Locals
--

local activeUnderstudy
local understudyIcons = {}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale()
if L then
	L.understudy = "Death Knight Understudy"

	L.shout_warning = "Disrupting Shout in 5 sec!"
	L.taunt_warning = "Taunt ready in 5 sec!"
	L.shieldwall_warning = "Barrier gone in 5 sec!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		55543, -- Disrupting Shout
		55550, -- Jagged Knife
		29060, -- Taunt
		29061, -- Bone Barrier
		29051, -- Mind Exhaustion
	}, {
		[29060] = L.understudy,
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "DisruptingShout", 29107, 55543)
	self:Log("SPELL_AURA_APPLIED", "JaggedKnife", 55550)

	self:Log("SPELL_AURA_APPLIED", "MindControl", 605) -- from player
	self:Log("SPELL_AURA_APPLIED", "MindExhaustion", 29051)
	self:Log("SPELL_CAST_SUCCESS", "Taunt", 29060)
	self:Log("SPELL_CAST_SUCCESS", "BoneBarrier", 29061)
	self:Death("Deaths", 16803) -- Death Knight Understudy

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:Death("Win", 16061)
end

function mod:OnEngage()
	understudyIcons = {}

	self:Bar(55543, 15) -- Disrupting Shout
	self:DelayedMessage(55543, 10, "orange", CL.soon:format(self:SpellName(55543)), 55543, "alert")
end

function mod:OnBossDisable()
	activeUnderstudy = nil
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:DisruptingShout(args)
	self:Message(55543, "red")
	self:PlaySound(55543, "alarm")
	self:Bar(55543, 15)
	self:DelayedMessage(55543, 10, "orange", CL.soon:format(args.spellName), 55543, "alert")
end

function mod:JaggedKnife(args)
	self:TargetMessage(args.spellId, "cyan", args.destName)
end

function mod:MindControl(args)
	local icon = self:GetIconTexture(self:GetIcon(args.destRaidFlags))
	if icon then
		understudyIcons[args.destGUID] = icon
	end
	activeUnderstudy = args.destGUID
end

function mod:MindExhaustion(args)
	local icon = understudyIcons[args.destGUID]
	if icon then -- Not much of a point if they aren't marked
		self:Bar(29051, 60, icon .. args.spellName)
	end
end

function mod:Deaths(args)
	if args.destGUID == activeUnderstudy then
		self:StopBar(29060) -- Taunt
		self:CancelDelayedMessage(L.taunt_warning)
		self:StopBar(29061) -- Shield Wall
		self:CancelDelayedMessage(L.shieldwall_warning)
	end
	local icon = understudyIcons[args.destGUID]
	if icon then
		self:StopBar(icon .. self:SpellName(29051))
	end
end

function mod:BoneBarrier(args)
	self:Message(args.spellId, "green")
	self:Bar(args.spellId, 20)
	self:DelayedMessage(args.spellId, 15, "yellow", L.shieldwall_warning)
end

function mod:Taunt(args)
	self:Message(args.spellId, "green")
	self:PlaySound(args.spellId, "info")
	self:Bar(args.spellId, 20)
	self:DelayedMessage(args.spellId, 15, "yellow", L.taunt_warning)
end
