--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Auriaya", 603, 1643)
if not mod then return end
mod:RegisterEnableMob(33515)
mod:SetEncounterID(BigWigsLoader.isWrath and 750 or 1131)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.swarm_message = "Swarm"

	L.defender = "Feral Defender"
	L.defender_desc = "Warn for Feral Defender lives."
	L.defender_message = "Defender up %d/9!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		64386, -- Terrifying Screech
		64678, -- Sentinel Blast
		64396, -- Guardian Swarm
		64688, -- Sonic Screech
		"defender",
		"berserk",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "SonicScreech", 64688)
	self:Log("SPELL_CAST_START", "TerrifyingScreech", 64386)
	self:Log("SPELL_CAST_START", "SentinelBlast", 64678)
	self:Log("SPELL_AURA_APPLIED", "GuardianSwarm", 64396)
	self:Log("SPELL_CAST_SUCCESS", "DefenderSpawn", 64455) -- Feral Essence
	self:Log("SPELL_AURA_REMOVED_DOSE", "DefenderKill", 64455) -- Feral Essence
end

function mod:OnEngage()
	self:Bar("defender", 60, L["defender_message"]:format(9), 64455)
	local fear = self:SpellName(5782) -- 5782 = "Fear"
	self:Bar(64386, 32, fear)
	self:DelayedMessage(64386, 32, "yellow", CL.soon:format(fear))
	self:Berserk(600)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:SonicScreech(args)
	self:MessageOld(args.spellId, "yellow", "warning")
	self:Bar(args.spellId, 28)
end

function mod:DefenderSpawn(args)
	-- Spawns with 9 lives
	self:MessageOld("defender", "yellow", nil, L.defender_message:format(9), args.spellId)
end

function mod:DefenderKill(args)
	-- Looses 1 life every time it dies, then respawns
	local amount = args.amount or 1
	self:Bar("defender", 34, L.defender_message:format(amount), args.spellId)
end

function mod:GuardianSwarm(args)
	self:TargetMessageOld(args.spellId, args.destName, "yellow", "alert", L.swarm_message, nil, self:Healer())
	self:CDBar(args.spellId, 37, L.swarm_message)
end

function mod:TerrifyingScreech(args)
	local fear = self:SpellName(5782) -- 5782 = "Fear"
	self:MessageOld(args.spellId, "orange", "info", fear)
	self:CDBar(args.spellId, 35, fear)
	self:DelayedMessage(args.spellId, 32, "orange", CL.soon:format(fear))
end

function mod:SentinelBlast(args)
	self:MessageOld(args.spellId, "red", "long")
end

