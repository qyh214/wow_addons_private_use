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
		20228, -- Pyroblast
	}
end

if mod:GetSeason() == 2 then
	function mod:GetOptions()
		return {
			13880, -- Magma Splash
			{460858, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE", "ME_ONLY"}, -- Pyroblast
			461463, -- Falling Rocks
		},nil,{
			[460858] = CL.explosion, -- Pyroblast (Explosion)
		}
	end
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED_DOSE", "MagmaSplashApplied", 13880)
	self:Log("SPELL_AURA_APPLIED", "PyroblastApplied", 20228) -- Normal, Level 1
	self:Log("SPELL_AURA_REFRESH", "PyroblastApplied", 20228)
	if self:GetSeason() == 2  then
		self:Log("SPELL_AURA_APPLIED", "PyroblastAppliedSoD", 460858) -- Level 2 & 3
		self:Log("SPELL_AURA_REFRESH", "PyroblastAppliedSoD", 460858)
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
		local unit, targetUnit = self:GetUnitIdByGUID(args.sourceGUID), self:UnitTokenFromGUID(args.destGUID)
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
end

function mod:PyroblastAppliedSoD(args) -- On heat level 2 & 3 you cast explosion (465155) when it expires
	self:TargetMessage(args.spellId, "orange", args.destName)
	self:TargetBar(args.spellId, 8, args.destName, CL.explosion)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
		self:Say(args.spellId, CL.extra:format(args.spellName, CL.explosion), nil, "Pyroblast (Explosion)")
		self:SayCountdown(args.spellId, 8, CL.explosion, nil, "Explosion")
	end
	self:PlaySound(args.spellId, "alarm", nil, args.destName)
end

function mod:PyroblastRemovedSoD(args)
	self:StopBar(CL.explosion, args.destName)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
end

function mod:FallingRocks(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "warning")
end
