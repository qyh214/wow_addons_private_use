
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Garr", 409, 1522)
if not mod then return end
mod:RegisterEnableMob(12057, 228432) -- Garr, Garr (Season of Discovery)
mod:SetEncounterID(666)

--------------------------------------------------------------------------------
-- Locals
--

local prevId = 0

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
	self:Log("SPELL_AURA_REMOVED", "BuffRemoved", "*")
	self:Log("SPELL_DISPEL", "BuffDispelled", "*")
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

function mod:BuffRemoved(args)
	if self:Me(args.destGUID) then
		prevId = args.spellId
	end
end

function mod:BuffDispelled(args)
	if args.spellId == 19492 and self:Me(args.destGUID) then
		local icon = self:SpellName(prevId) == args.extraSpellName and prevId or false -- Love extraSpellId being 0 on classic era
		self:Message(19492, "red", CL.removed:format(args.extraSpellName), icon, nil, 4) -- Stay onscreen for 4s
	end
end
