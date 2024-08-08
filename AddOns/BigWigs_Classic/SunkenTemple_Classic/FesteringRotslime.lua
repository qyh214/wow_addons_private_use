--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Festering Rotslime Discovery", 109)
if not mod then return end
mod:RegisterEnableMob(218819) -- Festering Rotslime
mod:SetEncounterID(2953)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Locals
--

local diseaseCount = 0
local diseaseTime = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Festering Rotslime"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		438142, -- Gunk
		438136, -- Nauseous Gas
	},nil,{
		[438142] = CL.disease, -- Gunk (Disease)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "Gunk", 438142)
	self:Log("SPELL_AURA_APPLIED", "GunkApplied", 438142)
	self:Log("SPELL_AURA_REMOVED", "GunkRemoved", 438142)

	self:Log("SPELL_AURA_APPLIED", "NauseousGasDamage", 438136)
	self:Log("SPELL_PERIODIC_DAMAGE", "NauseousGasDamage", 438136)
	self:Log("SPELL_PERIODIC_MISSED", "NauseousGasDamage", 438136)
end

function mod:OnEngage()
	diseaseCount = 0
	diseaseTime = 0
	self:CDBar(438142, 13.8, CL.disease) -- Gunk
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Gunk(args)
	diseaseCount = 0
	diseaseTime = args.time
	self:Message(args.spellId, "yellow", CL.on_group:format(CL.disease))
	self:CDBar(args.spellId, 17.8, CL.disease)
	self:PlaySound(args.spellId, "alert")
end

function mod:GunkApplied()
	diseaseCount = diseaseCount + 1
end

function mod:GunkRemoved(args)
	diseaseCount = diseaseCount - 1
	if diseaseCount == 0 then
		self:Message(args.spellId, "green", CL.removed_after:format(CL.disease, args.time-diseaseTime))
	end
end

do
	local prev = 0
	function mod:NauseousGasDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 3 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end
