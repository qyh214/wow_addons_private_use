--------------------------------------------------------------------------------
-- Module Declaration
--

if BigWigsLoader.isSeasonOfDiscovery then return end
local mod, CL = BigWigs:NewBoss("Lethon", -1425)
if not mod then return end
mod:RegisterEnableMob(14888)
mod:SetAllowWin(true)
mod.otherMenu = -947
mod.worldBoss = 14888

--------------------------------------------------------------------------------
-- Locals
--

local warnHP = 80
local whirlCount = 0
local tankDebuffOnMe = false
local drawSpiritPercent = 100

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Lethon"

	L.engage_trigger = "I can sense the SHADOW on your hearts. There can be no rest for the wicked!"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{24821, "TANK"}, -- Shadow Bolt Whirl
		24811, -- Draw Spirit
		-- Shared
		24818, -- Noxious Breath
		24814, -- Seeping Fog
	},{
		[24818] = CL.general,
	},{
		[24818] = CL.breath, -- Noxious Breath (Breath)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	whirlCount = 0 -- don't want to reset if OnEngage is late
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:Log("SPELL_CAST_SUCCESS", "NoxiousBreath", 24818)
	self:Log("SPELL_AURA_APPLIED", "NoxiousBreathApplied", 24818)
	self:Log("SPELL_AURA_APPLIED_DOSE", "NoxiousBreathApplied", 24818)
	self:Log("SPELL_AURA_REMOVED", "NoxiousBreathRemoved", 24818)
	self:Log("SPELL_CAST_SUCCESS", "SeepingFog", 24814)
	self:Log("SPELL_CAST_SUCCESS", "DrawSpirit", 24811)
	self:Log("SPELL_DAMAGE", "ShadowBoltWhirlDamage", 24820, 24821, 24822, 24823, 24835, 24836, 24837, 24838)
	self:Log("SPELL_MISSED", "ShadowBoltWhirlDamage", 24820, 24821, 24822, 24823, 24835, 24836, 24837, 24838)

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")

	self:Death("Win", 14888)
end

function mod:OnEngage()
	warnHP = 80
	tankDebuffOnMe = false
	drawSpiritPercent = 100
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.engage_trigger, nil, true) then
		whirlCount = 1
		self:Engage()
		self:Message(24818, "yellow", CL.custom_start_s:format(self.displayName, CL.breath, 10), false)
		self:Bar(24818, 10, CL.breath) -- Noxious Breath
	end
end

function mod:NoxiousBreath(args)
	self:Bar(args.spellId, 10, CL.breath)
end

function mod:NoxiousBreathApplied(args)
	local unit, targetUnit = self:GetUnitIdByGUID(args.sourceGUID), self:UnitTokenFromGUID(args.destGUID)
	if unit and targetUnit then
		local tanking = self:Tanking(unit, targetUnit)
		if self:Me(args.destGUID) then
			tankDebuffOnMe = true
			if not tanking then -- Not tanking, 1+
				self:StackMessage(args.spellId, "purple", args.destName, args.amount, 1, CL.breath)
			elseif args.amount then -- Tanking, 2+
				self:StackMessage(args.spellId, "purple", args.destName, args.amount, 100, CL.breath) -- No emphasize when on you
			end
		elseif tanking and args.amount then -- On a tank that isn't me, 2+
			self:StackMessage(args.spellId, "purple", args.destName, args.amount, (tankDebuffOnMe or args.amount >= 6) and 100 or 3, CL.breath)
			if not tankDebuffOnMe and args.amount >= 3 and args.amount <= 5 then
				self:PlaySound(args.spellId, "warning", nil, args.destName)
			end
		end
	end
end

function mod:NoxiousBreathRemoved(args)
	if self:Me(args.destGUID) then
		tankDebuffOnMe = false
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
	drawSpiritPercent = drawSpiritPercent - 25
	self:Message(args.spellId, "red", CL.percent:format(drawSpiritPercent, args.spellName))
	self:Bar(args.spellId, 5)
	self:PlaySound(args.spellId, "long")
end

do
	local prev = 0
	function mod:ShadowBoltWhirlDamage(args) -- Bolts are fired 4x on left side then 4x on right side of the dragon, we warn on the 4th to turn the dragon 180 degrees
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
	if self:MobId(self:UnitGUID(unit)) == 14888 then
		local hp = self:GetHealth(unit)
		if hp < warnHP then -- 80, 55, 30
			warnHP = warnHP - 25
			if hp > warnHP then -- avoid multiple messages when joining mid-fight
				self:Message(24811, "red", CL.soon:format(self:SpellName(24811)), false) -- Draw Spirit
			end
			if warnHP < 30 then
				self:UnregisterEvent(event)
			end
		end
	end
end
