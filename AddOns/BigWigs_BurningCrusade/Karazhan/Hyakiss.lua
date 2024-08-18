--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Hyakiss the Lurker", 532, 1552)
if not mod then return end
mod:RegisterEnableMob(16179)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.name = "Hyakiss the Lurker"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {29896}
end

function mod:OnRegister()
	self.displayName = L.name
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Web", 29896)

	self:Death("Win", 16179)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Web(args)
	self:TargetMessageOld(args.spellId, args.destName, "orange")
	self:TargetBar(args.spellId, 10, args.destName)
end

