--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ysondre Season of Discovery", 2832)
if not mod then return end
mod:RegisterEnableMob(235232)
mod:SetEncounterID(3114)
mod:SetAllowWin(true)

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
end

--------------------------------------------------------------------------------
-- Initialization
--

local divergentLightningMarker = mod:AddMarkerOption(true, "player", 8, 1214136, 8, 7, 6) -- Divergent Lightning
function mod:GetOptions()
	return {
		24795, -- Summon Demented Druid Spirit
		{1214136, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Divergent Lightning
		divergentLightningMarker,
		-- Shared
		1213170, -- Noxious Breath
		24814, -- Seeping Fog
	},{
		[1213170] = CL.general,
	},{
		[24795] = CL.adds, -- Summon Demented Druid Spirit (Adds)
		[1214136] = CL.soak, -- Divergent Lightning (Soak)
		[1213170] = CL.breath, -- Noxious Breath (Breath)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "DivergentLightning", 1214136)
	self:Log("SPELL_AURA_APPLIED", "DivergentLightningApplied", 1214136)
	self:Log("SPELL_AURA_REMOVED", "DivergentLightningRemoved", 1214136)
	self:Log("SPELL_CAST_SUCCESS", "NoxiousBreath", 1213170, 24818)
	self:Log("SPELL_AURA_APPLIED", "NoxiousBreathApplied", 1213170, 24818)
	self:Log("SPELL_AURA_APPLIED_DOSE", "NoxiousBreathApplied", 1213170, 24818)
	self:Log("SPELL_AURA_REMOVED", "NoxiousBreathRemoved", 1213170, 24818)
	self:Log("SPELL_CAST_SUCCESS", "SeepingFog", 24814)
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterMessage("BigWigs_BossComm")
end

function mod:OnEngage()
	warnHP = 80
	castCollector = {}
	tankDebuffOnMe = false
	addsPercent = 100
	self:RegisterEvent("UNIT_HEALTH")
	self:Message(1213170, "yellow", CL.custom_start_s:format(self.displayName, CL.breath, 10), false)
	self:Bar(1213170, 10, CL.breath) -- Noxious Breath
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, castGUID, spellId)
	if spellId == 1214082 and not castCollector[castGUID] then -- Summon Demented Druid Spirit
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

do
	local playerList = {}
	local icon = 8
	function mod:DivergentLightning(args)
		playerList = {}
		icon = 8
		self:Bar(args.spellId, 8, CL.soak)
		self:PlaySound(args.spellId, "warning")
	end

	function mod:DivergentLightningApplied(args)
		playerList[#playerList+1] = args.destName
		playerList[args.destName] = icon -- Set raid marker
		self:TargetsMessage(args.spellId, "orange", playerList, 3, CL.soak)
		self:CustomIcon(divergentLightningMarker, args.destName, icon)
		if self:Me(args.destGUID) then
			self:Yell(args.spellId, CL.soak, nil, "Soak")
			self:YellCountdown(args.spellId, 8, icon, 4)
		end
		icon = icon - 1
	end
end

function mod:DivergentLightningRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelYellCountdown(args.spellId)
	end
	self:CustomIcon(divergentLightningMarker, args.destName)
end

function mod:NoxiousBreath(args)
	self:Bar(1213170, 10, CL.breath)
end

function mod:NoxiousBreathApplied(args)
	local unit, targetUnit = self:GetUnitIdByGUID(args.sourceGUID), self:UnitTokenFromGUID(args.destGUID)
	if unit and targetUnit then
		local tanking = self:Tanking(unit, targetUnit)
		if self:Me(args.destGUID) then
			tankDebuffOnMe = true
			if not tanking then -- Not tanking, 1+
				self:StackMessage(1213170, "purple", args.destName, args.amount, 1, CL.breath)
			elseif args.amount then -- Tanking, 2+
				self:StackMessage(1213170, "purple", args.destName, args.amount, 100, CL.breath) -- No emphasize when on you
			end
		elseif tanking and args.amount then -- On a tank that isn't me, 2+
			self:StackMessage(1213170, "purple", args.destName, args.amount, (tankDebuffOnMe or args.amount >= 6) and 100 or 3, CL.breath)
			if not tankDebuffOnMe and args.amount >= 3 and args.amount <= 5 then
				self:PlaySound(1213170, "warning", nil, args.destName)
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
			-- self:CDBar(1213170, 20)
		end
	end
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 235232 then
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
