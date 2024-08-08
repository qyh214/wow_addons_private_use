--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Argaloth", 757, 139)
if not mod then return end
mod:RegisterEnableMob(47120)
mod:SetEncounterID(1033)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Locals
--

local fireStormHP = 100
local darknessCount = 0
local darknessTime = 0

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{88942, "EMPHASIZE"}, -- Meteor Slash
		88954, -- Consuming Darkness
		{88972, "CASTBAR"}, -- Fel Firestorm
		89000, -- Fel Flames
		"berserk",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "MeteorSlashStart", 88942)
	self:Log("SPELL_CAST_SUCCESS", "MeteorSlash", 88942)
	self:Log("SPELL_CAST_SUCCESS", "ConsumingDarkness", 88954)
	self:Log("SPELL_AURA_APPLIED", "ConsumingDarknessApplied", 88954)
	self:Log("SPELL_AURA_REMOVED", "ConsumingDarknessRemoved", 88954)
	self:Log("SPELL_CAST_START", "FelFirestorm", 88972)
	self:Log("SPELL_AURA_APPLIED", "FelFirestormApplied", 88972)
	self:Log("SPELL_AURA_REMOVED", "FelFirestormRemoved", 88972)
	self:Log("SPELL_DAMAGE", "FelFlamesDamage", 89000)
	self:Log("SPELL_MISSED", "FelFlamesDamage", 89000)
end

function mod:OnEngage()
	fireStormHP = 100
	darknessCount = 0
	darknessTime = 0
	self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1")
	self:Berserk(300)
	self:CDBar(88954, 5.5) -- Consuming Darkness
	self:CDBar(88942, 10) -- Meteor Slash
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:MeteorSlashStart(args)
	self:Message(args.spellId, "red", CL.casting:format(args.spellName), nil, true) -- Disable emphasize
	self:CDBar(args.spellId, 17)
	self:PlaySound(args.spellId, "alarm")
end

function mod:MeteorSlash(args)
	local bossUnit = self:GetUnitIdByGUID(args.sourceGUID)
	if bossUnit and self:Tank() then
		if not self:Tanking(bossUnit, args.destName) then
			self:Message(args.spellId, "red")
			self:PlaySound(args.spellId, "warning")
		else
			self:Message(args.spellId, "red", nil, nil, true) -- Disable emphasize
		end
	end
end

function mod:ConsumingDarkness(args)
	darknessCount = 0
	darknessTime = args.time
	self:Message(args.spellId, "yellow", CL.on_group:format(args.spellName))
	self:CDBar(args.spellId, 21.4)
	self:PlaySound(args.spellId, "alert")
end

function mod:ConsumingDarknessApplied()
	darknessCount = darknessCount + 1
end

function mod:ConsumingDarknessRemoved(args)
	darknessCount = darknessCount - 1
	if darknessCount == 0 then
		self:Message(args.spellId, "green", CL.removed_after:format(args.spellName, args.time-darknessTime))
	end
end

function mod:FelFirestorm(args)
	self:StopBar(88942) -- Meteor Slash
	self:StopBar(88954) -- Consuming Darkness
	self:Message(args.spellId, "orange", CL.percent:format(fireStormHP, args.spellName))
	self:PlaySound(args.spellId, "long")
end

function mod:FelFirestormApplied(args)
	self:CastBar(args.spellId, 15)
end

function mod:FelFirestormRemoved(args)
	self:StopBar(CL.cast:format(args.spellName))
	self:Message(args.spellId, "orange", CL.over:format(args.spellName))
	self:CDBar(88954, 10.3) -- Consuming Darkness
	self:CDBar(88942, 14) -- Meteor Slash
	self:PlaySound(args.spellId, "info")
end

do
	local prev = 0
	function mod:FelFlamesDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

function mod:UNIT_HEALTH(event, unit)
	local hp = self:GetHealth(unit)
	if hp < 69 and fireStormHP > 70 then
		fireStormHP = 66
		if hp > 66 then
			self:Message(88972, "cyan", CL.soon:format(self:SpellName(88972)), false)
		end
	elseif hp < 36 and fireStormHP > 50 then
		fireStormHP = 33
		self:UnregisterUnitEvent(event, unit)
		if hp > 33 then
			self:Message(88972, "cyan", CL.soon:format(self:SpellName(88972)), false)
		end
	end
end
