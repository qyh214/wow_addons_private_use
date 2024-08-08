--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ossirian the Unscarred", 509, 1542)
if not mod then return end
mod:RegisterEnableMob(15339)
mod:SetEncounterID(723)
mod:SetRespawnTime(mod:Retail() and 30 or 7)

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-- General
		{25189, "ME_ONLY_EMPHASIZE"}, -- Enveloping Winds
		25195, -- Curse of Tongues
		25188, -- War Stomp
		{25176, "COUNTDOWN"}, -- Strength of Ossirian
		-- Weakened
		25177, -- Fire Weakness
		25178, -- Frost Weakness
		25180, -- Nature Weakness
		25181, -- Arcane Weakness
		25183, -- Shadow Weakness
	},{
		[25189] = "general",
		[25177] = CL.weakened,
	},{
		[25195] = CL.curse, -- Curse of Tongues (Curse)
		[25188] = CL.knockback, -- War Stomp (Knockback)
	}
end

function mod:OnBossEnable()
	-- General
	self:Log("SPELL_AURA_APPLIED", "EnvelopingWindsApplied", 25189)
	self:Log("SPELL_AURA_REMOVED", "EnvelopingWindsRemoved", 25189)
	self:Log("SPELL_CAST_SUCCESS", "CurseOfTongues", 25195)
	self:Log("SPELL_CAST_SUCCESS", "WarStomp", 25188)
	self:Log("SPELL_AURA_APPLIED", "StrengthOfOssirian", 25176)

	-- Weakened
	self:Log("SPELL_AURA_APPLIED", "Weakness", 25177, 25178, 25180, 25181, 25183)
	self:Log("SPELL_AURA_REMOVED", "WeaknessRemoved", 25177, 25178, 25180, 25181, 25183)
end

function mod:OnEngage()
	self:Message(25176, "red") -- Strength of Ossirian
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:EnvelopingWindsApplied(args)
	self:TargetMessage(args.spellId, "red", args.destName)
	self:TargetBar(args.spellId, 10, args.destName)
	self:PlaySound(args.spellId, "warning")
end

function mod:EnvelopingWindsRemoved(args)
	self:StopBar(args.spellName, args.destName)
end

function mod:CurseOfTongues(args)
	self:Message(args.spellId, "orange", CL.on_group:format(CL.curse))
	self:PlaySound(args.spellId, "long")
end

function mod:WarStomp(args)
	self:Message(args.spellId, "orange", CL.knockback)
end

function mod:StrengthOfOssirian(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alert")
end

function mod:Weakness(args)
	self:Bar(25176, 45) -- Strength of Ossirian

	self:Message(args.spellId, "yellow")
	self:Bar(args.spellId, 45)
	self:PlaySound(args.spellId, "info")
end

function mod:WeaknessRemoved(args)
	self:Message(args.spellId, "yellow", CL.over:format(args.spellName))
end
