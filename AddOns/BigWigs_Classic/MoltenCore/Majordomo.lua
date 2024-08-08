--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Majordomo Executus", 409, 1527)
if not mod then return end
mod:RegisterEnableMob(
	12018, 11663, 11664, -- Majordomo Executus, Flamewaker Healer, Flamewaker Elite
	228437, 228837, 228836 -- Season of Discovery: Majordomo Executus, Flamewaker Healer, Flamewaker Elite
)
mod:SetEncounterID(671)

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{20619, "CASTBAR"}, -- Magic Reflection
		{21075, "CASTBAR"}, -- Damage Shield
		20534, -- Teleport
	},nil,{
		[20619] = CL.spell_reflection, -- Magic Reflection (Spell Reflection)
	}
end

if mod:GetSeason() == 2 then
	function mod:GetOptions()
		return {
			{20619, "CASTBAR"}, -- Magic Reflection
			{21075, "CASTBAR"}, -- Damage Shield
			20534, -- Teleport
			{461056, "CASTBAR", "SAY", "SAY_COUNTDOWN", "ICON", "ME_ONLY_EMPHASIZE"}, -- Raging Flare
		},nil,{
			[20619] = CL.spell_reflection, -- Magic Reflection (Spell Reflection)
		}
	end
end

function mod:VerifyEnable(_, npcId)
	if npcId ~= 12018 and npcId ~= 228437 then -- Majordomo Executus
		return true -- Only enable on his adds since he doesn't die, we keep him in enable mobs for his boss frame to trigger engage
	end
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "MagicReflection", 20619)
	self:Log("SPELL_CAST_SUCCESS", "DamageShield", 21075)
	self:Log("SPELL_CAST_SUCCESS", "Teleport", 20534)
	if self:GetSeason() == 2 then
		self:Log("SPELL_CAST_START", "RagingFlareStart", 461056)
		self:Log("SPELL_CAST_SUCCESS", "RagingFlare", 461056)
	end
end

function mod:OnEngage()
	self:CDBar(20534, 20) -- Teleport
	self:Bar(self:CheckOption(20619, "BAR") and 20619 or 21075, 27, CL.next_ability, "INV_Misc_QuestionMark")
	self:DelayedMessage(self:CheckOption(20619, "MESSAGE") and 20619 or 21075, 22, "orange", CL.custom_sec:format(CL.next_ability, 5))
	if self:GetPlayerAura(458843) then -- Level 3 only
		self:CDBar(461056, 16) -- Raging Flare
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:MagicReflection(args)
	self:CastBar(args.spellId, 10, CL.spell_reflection)
	self:Message(args.spellId, "red", CL.spell_reflection)
	self:Bar(self:CheckOption(20619, "BAR") and 20619 or 21075, 30, CL.next_ability, "INV_Misc_QuestionMark")
	self:DelayedMessage(self:CheckOption(20619, "MESSAGE") and 20619 or 21075, 25, "orange", CL.custom_sec:format(CL.next_ability, 5))
	self:PlaySound(args.spellId, "info")
end

function mod:DamageShield(args)
	self:CastBar(args.spellId, 10)
	self:Message(args.spellId, "red")
	self:Bar(self:CheckOption(20619, "BAR") and 20619 or 21075, 30, CL.next_ability, "INV_Misc_QuestionMark")
	self:DelayedMessage(self:CheckOption(20619, "MESSAGE") and 20619 or 21075, 25, "orange", CL.custom_sec:format(CL.next_ability, 5))
	self:PlaySound(args.spellId, "info")
end

function mod:Teleport(args)
	self:TargetMessage(args.spellId, "yellow", args.destName)
	self:CDBar(args.spellId, 25) -- 25-30
end

do
	local function printTarget(self, name, guid, elapsed)
		self:PrimaryIcon(461056, name)
		self:TargetMessage(461056, "red", name)
		if self:Me(guid) then
			self:Yell(461056, nil, nil, "Raging Flare")
			self:YellCountdown(461056, 4-elapsed, nil, 2)
		end
	end

	function mod:RagingFlareStart(args)
		self:StopBar(args.spellName)
		self:GetUnitTarget(printTarget, 0.4, args.sourceGUID)
		self:CastBar(args.spellId, 4)
		self:PlaySound(args.spellId, "warning")
	end

	function mod:RagingFlare(args)
		self:PrimaryIcon(args.spellId)
		self:CDBar(args.spellId, 26) -- Time to _START
	end
end
