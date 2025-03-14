--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Golemagg the Incinerator", 409, 1526)
if not mod then return end
mod:RegisterEnableMob(11988, 228435) -- Golemagg the Incinerator, Golemagg the Incinerator (Season of Discovery)
mod:SetEncounterID(670)

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		13880, -- Magma Splash
		{20228, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE", "ME_ONLY"}, -- Pyroblast
	}
end

if mod:GetSeason() == 2 then
	function mod:GetOptions()
		return {
			13880, -- Magma Splash
			{20228, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE", "ME_ONLY"}, -- Pyroblast
			461463, -- Falling Rocks
		},nil,{
			[20228] = CL.explosion, -- Pyroblast (Explosion)
		}
	end
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED_DOSE", "MagmaSplashApplied", 13880)
	self:Log("SPELL_AURA_APPLIED", "PyroblastApplied", 20228)
	if self:GetSeason() == 2  then
		self:Log("SPELL_AURA_APPLIED", "PyroblastAppliedSoD", 460858)
		self:Log("SPELL_AURA_REMOVED", "PyroblastRemovedSoD", 460858)
		self:Log("SPELL_CAST_SUCCESS", "FallingRocks", 461463)
	end
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
		local unit, targetUnit = self:GetUnitIdByGUID(args.sourceGUID), self:UnitTokenFromGUID(args.destGUID, true)
		if unit and targetUnit and self:Tanking(unit, targetUnit) then
			self:StackMessage(args.spellId, "purple", args.destName, args.amount, 4)
			if args.amount >= 4 then
				self:PlaySound(args.spellId, "alert")
			end
		end
	end
end

function mod:PyroblastApplied(args)
	self:TargetMessage(args.spellId, "orange", args.destName)
	if self:Me(args.destGUID) then
		self:PlaySound(args.spellId, "alarm", nil, args.destName)
	end
end

function mod:PyroblastAppliedSoD(args)
	self:TargetMessage(20228, "orange", args.destName)
	if self:Me(args.destGUID) then
		self:Say(20228, nil, nil, "Pyroblast")
		self:SayCountdown(20228, 8, CL.explosion, nil, "Explosion")
		self:TargetBar(20228, 8, args.destName, CL.explosion)
		self:PlaySound(20228, "alarm", nil, args.destName)
	end
end

function mod:PyroblastRemovedSoD(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(20228)
		self:StopBar(CL.explosion, args.destName)
	end
end

function mod:FallingRocks(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "warning")
end
