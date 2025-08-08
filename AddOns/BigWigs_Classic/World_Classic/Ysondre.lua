--------------------------------------------------------------------------------
-- Module Declaration
--

if BigWigsLoader.isSeasonOfDiscovery then return end
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
local castCollector = {}
local tankDebuffOnMe = false
local addsPercent = 100

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

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterMessage("BigWigs_BossComm")

	self:Death("Win", 14887)
end

function mod:OnEngage()
	warnHP = 80
	castCollector = {}
	tankDebuffOnMe = false
	addsPercent = 100
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, castGUID, spellId)
	if spellId == 24796 and not castCollector[castGUID] then -- Summon Demented Druid Spirit (Normal, Season of Discovery)
		castCollector[castGUID] = true
		self:Sync("summ")
	end
end

do
	local times = {
		["summ"] = 0,
	}
	function mod:BigWigs_BossComm(_, msg)
		if times[msg] then
			local t = GetTime()
			if t-times[msg] > 5 then
				times[msg] = t
				if msg == "summ" then
					addsPercent = addsPercent - 25
					self:Message(24795, "cyan", CL.percent:format(addsPercent, CL.adds), false)
					self:PlaySound(24795, "long")
				end
			end
		end
	end
end

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
