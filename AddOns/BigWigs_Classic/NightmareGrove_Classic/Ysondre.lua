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
		-- 24819, -- Lightning Wave
		24795, -- Summon Demented Druid Spirit
		{1214136, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Divergent Lightning
		divergentLightningMarker,
		-- Shared
		24818, -- Noxious Breath
		24814, -- Seeping Fog
	},{
		[24818] = CL.general,
	},{
		[24795] = CL.adds, -- Summon Demented Druid Spirit (Adds)
		[1214136] = CL.soaks, -- Divergent Lightning (Soaks)
		[24818] = CL.breath, -- Noxious Breath (Breath)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "DivergentLightning", 1214136)
	self:Log("SPELL_AURA_APPLIED", "DivergentLightningApplied", 1214136)
	self:Log("SPELL_AURA_REMOVED", "DivergentLightningRemoved", 1214136)
	self:Log("SPELL_CAST_SUCCESS", "NoxiousBreath", 24818)
	self:Log("SPELL_AURA_APPLIED", "NoxiousBreathApplied", 24818)
	self:Log("SPELL_AURA_APPLIED_DOSE", "NoxiousBreathApplied", 24818)
	self:Log("SPELL_CAST_SUCCESS", "SeepingFog", 24814)
	self:Log("SPELL_CAST_SUCCESS", "SummonDementedDruidSpirit", 24795, 1214086)
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterMessage("BigWigs_BossComm")
end

function mod:OnEngage()
	warnHP = 80
	castCollector = {}
	self:RegisterEvent("UNIT_HEALTH")
	self:Message(24818, "yellow", CL.custom_start_s:format(self.displayName, CL.breath, 10), false)
	self:Bar(24818, 10, CL.breath) -- Noxious Breath
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, castGUID, spellId)
	if (spellId == 24795 or spellId == 1214086) and not castCollector[castGUID] then -- Summon Demented Druid Spirit (Normal, Season of Discovery)
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
					self:Message(24795, "cyan", CL.incoming:format(CL.adds), false)
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
		self:Bar(args.spellId, 8, CL.soaks)
		self:PlaySound(args.spellId, "warning")
	end

	function mod:DivergentLightningApplied(args)
		playerList[#playerList+1] = args.destName
		self:TargetsMessage(args.spellId, "orange", playerList, 3, CL.soaks)
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

function mod:SummonDementedDruidSpirit() -- Seems to be hidden
	self:Sync("summ")
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
