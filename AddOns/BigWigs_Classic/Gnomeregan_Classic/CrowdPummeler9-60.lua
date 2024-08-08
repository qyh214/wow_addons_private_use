--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Crowd Pummeler 9-60 Discovery", 90)
if not mod then return end
mod:RegisterEnableMob(215728) -- Crowd Pummeler 9-60
mod:SetEncounterID(2899)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Crowd Pummeler 9-60"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		432423, -- Gnomeregan Smash
		{432062, "SAY", "ICON", "ME_ONLY_EMPHASIZE"}, -- The Claw!
		431839, -- Off Balanced
	},nil,{
		[432423] = CL.knockback, -- Gnomeregan Smash (Knockback)
		[432062] = CL.charge, -- The Claw! (Charge)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "GnomereganSmash", 432423)
	self:Log("SPELL_CAST_START", "TheClawStart", 432062)
	self:Log("SPELL_CAST_SUCCESS", "TheClaw", 432062)
	self:Log("SPELL_AURA_APPLIED", "OffBalancedApplied", 431839)
	self:Log("SPELL_AURA_APPLIED_DOSE", "OffBalancedApplied", 431839)
end

function mod:OnEngage()
	self:CDBar(432423, 6, CL.knockback) -- Gnomeregan Smash
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:GnomereganSmash(args)
	self:Message(args.spellId, "orange", CL.knockback)
	self:CDBar(args.spellId, 11.4, CL.knockback)
	self:PlaySound(args.spellId, "warning")
end

do
	local function printTarget(self, name, guid)
		self:PrimaryIcon(432062, name)
		self:TargetMessage(432062, "yellow", name, CL.charge)
		if self:Me(guid) then
			self:Say(432062, CL.charge, nil, "Charge")
			self:PlaySound(432062, "alarm", nil, name)
		end
	end

	function mod:TheClawStart(args)
		self:GetUnitTarget(printTarget, 0.3, args.sourceGUID)
	end
end

function mod:TheClaw(args)
	self:PrimaryIcon(args.spellId)
end

function mod:OffBalancedApplied(args)
	if self:Me(args.destGUID) then
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 3)
	end
end
