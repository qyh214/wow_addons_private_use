--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("High Priest Venoxis", 309)
if not mod then return end
mod:RegisterEnableMob(14507)
mod:SetEncounterID(784)
mod:SetAllowWin(true)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local castCollector = {}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "High Priest Venoxis"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		-- Stage 1
		23895, -- Renew
		{23860, "CASTBAR"}, -- Holy Fire
		-- Stage 2
		23861, -- Poison Cloud
		23865, -- Parasitic Serpent
		8269, -- Enrage
	},{
		[23895] = CL.stage:format(1),
		[23861] = CL.stage:format(2),
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterMessage("BigWigs_BossComm")

	self:Log("SPELL_AURA_APPLIED", "RenewApplied", 23895)
	self:Log("SPELL_DISPEL", "RenewDispelled", "*")
	self:Log("SPELL_CAST_START", "HolyFire", 23860)
	self:Log("SPELL_CAST_SUCCESS", "PoisonCloud", 23861)
	self:Log("SPELL_AURA_APPLIED", "PoisonCloudDamage", 23861)
	self:Log("SPELL_PERIODIC_DAMAGE", "PoisonCloudDamage", 23861)
	self:Log("SPELL_PERIODIC_MISSED", "PoisonCloudDamage", 23861)
	self:Log("SPELL_AURA_APPLIED", "ParasiticSerpentApplied", 23865)
	self:Log("SPELL_CAST_SUCCESS", "Enrage", 8269)
end

function mod:OnEngage()
	castCollector = {}
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:RegisterEvent("UNIT_HEALTH")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, castGUID, spellId)
	if spellId == 23849 and not castCollector[castGUID] then -- Venoxis Transform
		castCollector[castGUID] = true
		self:Sync("vs2")
	end
end

do
	local times = {
		["vs2"] = 0,
	}
	function mod:BigWigs_BossComm(_, msg)
		if times[msg] then
			local t = GetTime()
			if t-times[msg] > 5 then
				times[msg] = t
				self:SetStage(2)
				self:Message("stages", "cyan", CL.percent:format(50, CL.stage:format(2)), false)
				self:PlaySound("stages", "info")
			end
		end
	end
end

function mod:RenewApplied(args)
	self:Message(args.spellId, "orange", CL.on:format(args.spellName, args.destName))
	if self:Dispeller("magic", true) then
		self:PlaySound(args.spellId, "alert")
	end
end

function mod:RenewDispelled(args)
	if args.extraSpellName == self:SpellName(23895) then
		local id = self:MobId(args.destGUID)
		if id == 14507 or id == 11373 then -- High Priest Venoxis, Razzashi Cobra
			self:Message(23895, "green", CL.removed_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
		end
	end
end

function mod:HolyFire(args)
	self:Message(args.spellId, "yellow")
	self:CastBar(args.spellId, 3.5)
end

function mod:PoisonCloud(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alarm")
end

do
	local prev = 0
	function mod:PoisonCloudDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 3 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

function mod:ParasiticSerpentApplied(args)
	self:TargetMessage(args.spellId, "yellow", args.destName)
end

function mod:Enrage(args)
	if self:MobId(args.destGUID) == 14507 then -- So many NPCs use this spell ID
		self:Message(args.spellId, "orange", CL.percent:format(20, args.spellName))
		self:PlaySound(args.spellId, "long")
	end
end

function mod:UNIT_HEALTH(event, unit)
	if not self:UnitIsPlayer(unit) and self:MobId(self:UnitGUID(unit)) == 14507 then
		local hp = self:GetHealth(unit)
		if hp < 56 then
			self:UnregisterEvent(event)
			if hp > 50 then -- Make sure we're not too late
				self:Message("stages", "cyan", CL.soon:format(CL.stage:format(2)), false)
			end
		end
	end
end
