--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ysondre", -1444)
if not mod then return end
mod:RegisterEnableMob(14887)
mod:SetAllowWin(true)
mod.otherMenu = -947
mod.worldBoss = 14887

--------------------------------------------------------------------------------
-- Locals
--

local warnHP = 80

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Ysondre"

	L.engage_trigger = "The strands of LIFE have been severed! The Dreamers must be avenged!"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-- 24819, -- Lightning Wave
		24795, -- Summon Demented Druid Spirit
		-- Shared
		24818, -- Noxious Breath
		24814, -- Seeping Fog
	},{
		[24818] = CL.general,
	},{
		[24795] = CL.adds, -- Summon Demented Druid Spirit (Adds)
		[24818] = CL.breath, -- Noxious Breath (Breath)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:Log("SPELL_CAST_SUCCESS", "NoxiousBreath", 24818)
	self:Log("SPELL_AURA_APPLIED", "NoxiousBreathApplied", 24818)
	self:Log("SPELL_AURA_APPLIED_DOSE", "NoxiousBreathApplied", 24818)
	self:Log("SPELL_CAST_SUCCESS", "SeepingFog", 24814)
	self:Log("SPELL_CAST_SUCCESS", "SummonDementedDruidSpirit", 24795)

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")

	self:Death("Win", 14887)
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
		self:Engage()
		self:Message(24818, "yellow", CL.custom_start_s:format(self.displayName, CL.breath, 10), false)
		self:Bar(24818, 10, CL.breath) -- Noxious Breath
	end
end

function mod:NoxiousBreath(args)
	self:Bar(args.spellId, 10, CL.breath)
end

function mod:NoxiousBreathApplied(args)
	if not self:Damager() and self:Tank(args.destName) then
		local amount = args.amount or 1
		self:StackMessage(args.spellId, "purple", args.destName, amount, 3, CL.breath)
		if self:Tank() and amount > 3 then
			self:PlaySound(args.spellId, "warning")
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

function mod:SummonDementedDruidSpirit(args)
	self:Message(args.spellId, "cyan", CL.incoming:format(CL.adds), false)
	self:PlaySound(args.spellId, "long")
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 14887 then
		local hp = self:GetHealth(unit)
		if hp < warnHP then -- 80, 55, 30
			warnHP = warnHP - 25
			if hp > warnHP then -- avoid multiple messages when joining mid-fight
				self:Message(24795, "cyan", CL.soon:format(CL.adds), false)
			end
			if warnHP < 30 then
				self:UnregisterEvent(event)
			end
		end
	end
end
