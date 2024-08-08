--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Atal'alarion Discovery", 109)
if not mod then return end
mod:RegisterEnableMob(218624) -- Atal'alarion
mod:SetAllowWin(true)
mod:SetEncounterID(2952)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Atal'alarion"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		437597, -- Demolishing Smash
		437503, -- Pillars of Might
	},nil,{
		[437597] = CL.knockback, -- Demolishing Smash (Knockback)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "DemolishingSmashStart", 437597)
	self:Log("SPELL_CAST_SUCCESS", "PillarsOfMight", 437503)
end

function mod:OnEngage()
	self:CDBar(437503, 6) -- Pillars of Might
	self:CDBar(437597, 24, CL.knockback) -- Demolishing Smash
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:DemolishingSmashStart(args)
	self:Message(args.spellId, "red", CL.knockback)
	self:CDBar(args.spellId, 27.6, CL.knockback)
	self:PlaySound(args.spellId, "warning")
end

function mod:PillarsOfMight(args)
	self:Message(args.spellId, "yellow")
	self:CDBar(args.spellId, 13)
	self:PlaySound(args.spellId, "info")
end
