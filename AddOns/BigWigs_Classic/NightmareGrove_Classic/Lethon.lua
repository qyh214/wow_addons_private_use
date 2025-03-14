--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Lethon Season of Discovery", 2832)
if not mod then return end
mod:RegisterEnableMob(235180)
mod:SetEncounterID(3112)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Locals
--

local warnHP = 80
local whirlCount = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Lethon"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		24821, -- Shadow Bolt Whirl
		1214002, -- Draw Spirit
		-- Shared
		1213170, -- Noxious Breath
		24814, -- Seeping Fog
	},{
		[1213170] = CL.general,
	},{
		[1213170] = CL.breath, -- Noxious Breath (Breath)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "NoxiousBreath", 1213170)
	self:Log("SPELL_AURA_APPLIED", "NoxiousBreathApplied", 1213170)
	self:Log("SPELL_AURA_APPLIED_DOSE", "NoxiousBreathApplied", 1213170)
	self:Log("SPELL_CAST_SUCCESS", "SeepingFog", 24814)
	self:Log("SPELL_CAST_SUCCESS", "DrawSpirit", 1214002)
	self:Log("SPELL_DAMAGE", "ShadowBoltWhirlDamage", 24820, 24821, 24822, 24823, 24835, 24836, 24837, 24838)
	self:Log("SPELL_MISSED", "ShadowBoltWhirlDamage", 24820, 24821, 24822, 24823, 24835, 24836, 24837, 24838)
end

function mod:OnEngage()
	warnHP = 80
	whirlCount = 0
	self:RegisterEvent("UNIT_HEALTH")
	self:Message(1213170, "yellow", CL.custom_start_s:format(self.displayName, CL.breath, 10), false)
	self:Bar(1213170, 10, CL.breath) -- Noxious Breath
	self:Bar(24821, 20) -- Shadow Bolt Whirl
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:NoxiousBreath(args)
	self:Bar(args.spellId, 10, CL.breath)
end

function mod:NoxiousBreathApplied(args)
	local unit, targetUnit = self:GetUnitIdByGUID(args.sourceGUID), self:UnitTokenFromGUID(args.destGUID, true)
	if unit and targetUnit and self:Tanking(unit, targetUnit) then
		self:StackMessage(args.spellId, "purple", args.destName, args.amount, 4, CL.breath)
		if args.amount >= 4 then
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		end
	end
end

do
	local prev = 0
	function mod:SeepingFog(args)
		if args.time-prev > 2 then
			prev = args.time
			self:Message(args.spellId, "green")
			self:PlaySound(args.spellId, "info")
			-- self:CDBar(24818, 20)
		end
	end
end

function mod:DrawSpirit(args)
	self:Message(args.spellId, "red")
	self:Bar(args.spellId, 5)
	self:PlaySound(args.spellId, "long")
end

do
	local prev = 0
	function mod:ShadowBoltWhirlDamage(args) -- Bolts are fired 4x on left side then 4x on right side of the dragon, repeating
		if args.time-prev > 4 then
			prev = args.time
			whirlCount = whirlCount + 1
			if whirlCount == 4 then
				whirlCount = 0
				self:Message(24821, "yellow", CL.count:format(self:SpellName(24821), 4))
				self:Bar(24821, 20)
				self:PlaySound(24821, "alert")
			end
		end
	end
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 235180 then
		local hp = self:GetHealth(unit)
		if hp < warnHP then -- 80, 55, 30
			warnHP = warnHP - 25
			if hp > warnHP then -- avoid multiple messages when joining mid-fight
				self:Message(1214002, "red", CL.soon:format(self:SpellName(1214002)), false) -- Draw Spirit
			end
			if warnHP < 30 then
				self:UnregisterEvent(event)
			end
		end
	end
end
