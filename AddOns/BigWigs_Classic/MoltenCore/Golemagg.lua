--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Golemagg the Incinerator", 409, 1526)
if not mod then return end
mod:RegisterEnableMob(11988, 228435) -- Golemagg the Incinerator, Golemagg the Incinerator (Season of Discovery)
mod:SetEncounterID(670)

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		13880, -- Magma Splash
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED_DOSE", "MagmaSplashApplied", 13880)
 end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:MagmaSplashApplied(args)
	if self:Me(args.destGUID) then
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 4)
		if args.amount >= 4 then
			self:PlaySound(args.spellId, "alert")
		end
	elseif self:Player(args.destFlags) and args.amount >= 3 then -- Players, not pets
		local unit = self:GetUnitIdByGUID(args.sourceGUID)
		if unit and self:Tanking(unit, args.destName) then
			self:StackMessage(args.spellId, "purple", args.destName, args.amount, 4)
			if args.amount >= 4 then
				self:PlaySound(args.spellId, "alert")
			end
		end
	end
end
