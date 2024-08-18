
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Garr", 409, 1522)
if not mod then return end
mod:RegisterEnableMob(12057, 228432) -- Garr, Garr (Season of Discovery)
mod:SetEncounterID(666)

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		19492, -- Antimagic Pulse
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "AntimagicPulse", 19492)
end

function mod:OnEngage()
	self:CDBar(19492, 11.3) -- Antimagic Pulse
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:AntimagicPulse(args)
	self:Message(args.spellId, "yellow")
	self:CDBar(args.spellId, 17)
	self:PlaySound(args.spellId, "info")
end
