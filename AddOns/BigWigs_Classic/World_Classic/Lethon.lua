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
	self:Log("SPELL_CAST_SUCCESS", "SeepingFog", 24814)
	self:Log("SPELL_CAST_SUCCESS", "DrawSpirit", 24811)
	self:Log("SPELL_CAST_SUCCESS", "ShadowBoltWhirl", 24821)

	self:RegisterMessage("BigWigs_BossComm")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")

	self:Death("Win", 14888)
end

function mod:OnEngage()
	warnHP = 80
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
	function mod:BigWigs_BossComm(_, msg, extra)
		if msg ~= "ShadowBoltWhirl" then return end

		local t = GetTime()
		if t-prev > 2 then
			prev = t
			whirlCount = extra
			-- cast every 5s, announce on the 4th for swapping sides
			if whirlCount == 4 then
				whirlCount = 0
				self:Message(24821, "yellow", CL.count:format(self:SpellName(24821), extra))
				self:PlaySound(24821, "alert")
			end
			whirlCount = whirlCount + 1
		end
	end
end

function mod:ShadowBoltWhirl()
	-- I'm really worried about this getting out of sync and being annoying (yay combat log range)
	if whirlCount > 0 then
		self:Sync("ShadowBoltWhirl", whirlCount)
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
