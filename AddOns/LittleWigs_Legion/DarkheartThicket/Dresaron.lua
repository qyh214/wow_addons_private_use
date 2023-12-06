--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Dresaron", 1466, 1656)
if not mod then return end
mod:RegisterEnableMob(99200) -- Dresaron
mod:SetEncounterID(1838)
mod:SetRespawnTime(25)

--------------------------------------------------------------------------------
-- Locals
--

local breathOfCorruptionCount = 1

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		191325, -- Breath of Corruption
		199389, -- Earthshaking Roar
		199345, -- Down Draft
		199460, -- Falling Rocks
	}
end

function mod:OnBossEnable()
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1") -- Breath of Corruption
	self:Log("SPELL_CAST_START", "EarthshakingRoar", 199389)
	self:Log("SPELL_CAST_START", "DownDraft", 199345)
	self:Log("SPELL_AURA_APPLIED", "FallingRocksDamage", 199460)
	self:Log("SPELL_PERIODIC_DAMAGE", "FallingRocksDamage", 199460)
	self:Log("SPELL_PERIODIC_MISSED", "FallingRocksDamage", 199460)
end

function mod:OnEngage()
	breathOfCorruptionCount = 1
	self:CDBar(191325, 13.0) -- Breath of Corruption
	self:CDBar(199345, 19.3) -- Down Draft
	self:CDBar(199389, 31.4) -- Earthshaking Roar
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, _, spellId)
	if spellId == 199332 then -- Breath of Corruption
		self:Message(191325, "orange")
		self:PlaySound(191325, "alarm")
		breathOfCorruptionCount = breathOfCorruptionCount + 1
		-- 21.9 is likely the "true" cooldown, but after the first one
		-- this will always be delayed by the other two casts.
		if breathOfCorruptionCount == 1 then
			self:CDBar(191325, 21.9)
		else
			self:CDBar(191325, 30.4)
		end
		-- 6.1s before any ability can be cast
	end
end

function mod:EarthshakingRoar(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alert")
	self:CDBar(args.spellId, 30.4)
	-- 3.62s before any ability can be cast
end

function mod:DownDraft(args)
	self:Message(args.spellId, "yellow")
	self:PlaySound(args.spellId, "long")
	self:CDBar(args.spellId, 30.4)
	-- 12.1s before any ability can be cast (1s cast + 8s channel + 3.1s delay)
end

do
	local prev = 0
	function mod:FallingRocksDamage(args)
		if self:Me(args.destGUID) then
			local t = args.time
			if t - prev > 2 then
				prev = t
				self:PersonalMessage(args.spellId, "near")
				self:PlaySound(args.spellId, "underyou", nil, args.destName)
			end
		end
	end
end
