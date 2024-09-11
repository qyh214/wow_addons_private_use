--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ragnaros Classic", 409, 1528)
if not mod then return end
mod:RegisterEnableMob(
	11502, -- Ragnaros
	12143, -- Son of Flame
	12018, -- Majordomo Executus
	54404, -- Majordomo Executus (Retail)
	228438, -- Ragnaros (Season of Discovery)
	228437 -- Majordomo Executus (Season of Discovery)
)
mod:SetEncounterID(672)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local sonsDead = 0
local timer = nil
local warmupTimer = mod:Retail() and 74 or mod:GetSeason() == 2 and 86 or 83
local sonsTracker = {}
local sonsMarker = 8
local lineCount = 3
local castCollector = {}
local firstSubmerge = true
local UpdateInfoBoxList

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.warmup_icon = "Achievement_boss_ragnaros"
	L.adds_icon = "spell_fire_elemental_totem"

	L.submerge_trigger = "COME FORTH,"
	L.son = "Son of Flame" -- NPC ID 12143
end

--------------------------------------------------------------------------------
-- Initialization
--

local sonOfFlameMarker = mod:AddMarkerOption(true, "npc", 8, "son", 8, 7, 6, 5, 4, 3, 2, 1) -- Son of Flame
function mod:GetOptions()
	return {
		"warmup",
		"stages",
		"adds",
		sonOfFlameMarker,
		{"health", "INFOBOX"},
		20566, -- Wrath of Ragnaros
	},nil,{
		[20566] = CL.knockback, -- Wrath of Ragnaros (Knockback)
	}
end

if mod:GetSeason() == 2 then
	function mod:GetOptions()
		return {
			"warmup",
			"stages",
			"adds",
			sonOfFlameMarker,
			{"health", "INFOBOX"},
			20566, -- Wrath of Ragnaros
			461062, -- Pool of Fire
		},nil,{
			[20566] = CL.knockback, -- Wrath of Ragnaros (Knockback)
			[461062] = CL.underyou:format(CL.fire), -- Pool of Fire (Fire under YOU)
		}
	end
end

function mod:OnRegister()
	-- Delayed for custom locale
	sonOfFlameMarker = mod:AddMarkerOption(true, "npc", 8, "son", 8, 7, 6, 5, 4, 3, 2, 1) -- Son of Flame
end

function mod:VerifyEnable(unit, mobId)
	if mobId == 11502 or mobId == 228438 or mobId == 12143 then -- Ragnaros, Ragnaros (Season of Discovery), Son of Flame
		return true
	else -- Majordomo Executus
		return not UnitCanAttack(unit, "player")
	end
end

function mod:OnBossEnable()
	self:RegisterMessage("BigWigs_BossComm")

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:Log("SPELL_CAST_SUCCESS", "RagnarosSubmergeVisual", 20567)
	self:Log("SPELL_CAST_SUCCESS", "WrathOfRagnaros", 20566)
	self:Log("SPELL_CAST_START", "SummonRagnarosStart", 19774)
	self:Log("SPELL_CAST_SUCCESS", "SummonRagnaros", 19774)
	self:Log("SPELL_CAST_SUCCESS", "ElementalFire", 19773)

	self:Death("SonDeaths", 12143)

	if self:GetSeason() == 2 then
		self:Log("SPELL_AURA_APPLIED", "PoolOfFireDamage", 461062)
		self:Log("SPELL_DAMAGE", "PoolOfFireDamage", 461812) -- Damage is different ID
		self:Log("SPELL_MISSED", "PoolOfFireDamage", 461812)
	end
end

function mod:OnEngage()
	sonsDead = 0
	timer = nil
	sonsTracker = {}
	sonsMarker = 8
	lineCount = 3
	castCollector = {}
	firstSubmerge = true
	self:SetStage(1)
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:CDBar(20566, 26, CL.knockback) -- Wrath of Ragnaros
	if self:GetSeason() == 2 then -- He doesn't submerge until 50% on SoD
		self:RegisterEvent("UNIT_HEALTH")
	else
		self:Bar("stages", 180, CL.stage:format(2), L.warmup_icon)
		self:DelayedMessage("stages", 170, "cyan", CL.custom_sec:format(CL.stage:format(2), 10))
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.submerge_trigger, nil, true) then
		self:Sync("s2")
	end
end

function mod:RagnarosSubmergeVisual()
	self:Sync("s2")
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, castGUID, spellId)
	if spellId == 20567 and not castCollector[castGUID] then -- Ragnaros Submerge Visual
		castCollector[castGUID] = true
		self:Sync("s2")
	end
end

function mod:WrathOfRagnaros(args)
	self:Message(args.spellId, "red", CL.knockback)
	self:CDBar(args.spellId, 27, CL.knockback)
	self:PlaySound(args.spellId, "info")
end

function mod:SummonRagnarosStart()
	self:Sync("RagWarmup") -- Speedrunners like to have someone start it as soon as the Executus encounter ends
end

do
	local times = {
		["RagWarmup"] = 0,
		["s2"] = 0,
	}
	function mod:BigWigs_BossComm(_, msg)
		if times[msg] then
			local t = GetTime()
			if t-times[msg] > 60 then
				times[msg] = t
				if msg == "RagWarmup" and not self:IsEngaged() then
					self:Bar("warmup", warmupTimer, CL.active, L.warmup_icon)
				elseif msg == "s2" and self:IsEngaged() and self:GetStage() == 1 then
					self:Submerge()
				end
			end
		end
	end

	function mod:SummonRagnaros()
		times.RagWarmup = GetTime()+100 -- No more sync allowed
		self:Bar("warmup", {warmupTimer-10, warmupTimer}, CL.active, L.warmup_icon)
	end
end

function mod:ElementalFire()
	-- it takes exactly 10 seconds for combat to start after Majodromo dies, while
	-- the time between starting the RP/summon and killing Majordomo varies
	self:Bar("warmup", {10, warmupTimer}, CL.active, L.warmup_icon)
end

function mod:Emerge()
	sonsDead = 10 -- Block this firing again if sons are killed after he emerges
	timer = nil
	self:SetStage(1)
	self:CloseInfo("health")
	self:CDBar(20566, 27, CL.knockback)
	self:Message("stages", "cyan", CL.stage:format(1), L.warmup_icon)
	if not self:GetPlayerAura(458841) then -- He doesn't submerge again on level 1
		self:Bar("stages", 180, CL.stage:format(2), L.warmup_icon)
		self:DelayedMessage("stages", 170, "cyan", CL.custom_sec:format(CL.stage:format(2), 10))
	end
	self:RemoveLog("SWING_DAMAGE", "*")
	self:RemoveLog("RANGE_DAMAGE", "*")
	self:RemoveLog("SPELL_DAMAGE", "*")
	self:RemoveLog("SPELL_PERIODIC_DAMAGE", "*")
	self:PlaySound("stages", "long")
end

function mod:Submerge()
	sonsDead = 0 -- reset counter
	sonsTracker = {}
	sonsMarker = 8
	lineCount = 3
	self:OpenInfo("health", CL.other:format("BigWigs", CL.health))
	self:SetInfo("health", 1, L.son)
	-- No SUMMON events unfortunately, using CLEU damage events so that everyone assigns markers in the same (combat log) order
	self:Log("SWING_DAMAGE", "Damage", "*")
	self:Log("RANGE_DAMAGE", "Damage", "*")
	self:Log("SPELL_DAMAGE", "Damage", "*")
	self:Log("SPELL_PERIODIC_DAMAGE", "Damage", "*")
	self:SetStage(2)
	timer = self:ScheduleTimer("Emerge", 90)
	self:StopBar(CL.knockback)
	if self:GetSeason() == 2 and firstSubmerge then
		firstSubmerge = false
		self:Message("stages", "cyan", CL.percent:format(50, CL.stage:format(2)), L.warmup_icon)
	else
		self:Message("stages", "cyan", CL.stage:format(2), L.warmup_icon)
	end
	self:Bar("stages", 90, CL.stage:format(1), L.warmup_icon)
	self:DelayedMessage("stages", 80, "cyan", CL.custom_sec:format(CL.stage:format(1), 10))
	self:SimpleTimer(UpdateInfoBoxList, 1)
	self:PlaySound("stages", "long")
end

function mod:SonDeaths(args)
	sonsDead = sonsDead + 1
	if sonsDead < 9 then
		self:Message("adds", "green", CL.add_killed:format(sonsDead, 8), L.adds_icon)
		local tbl = sonsTracker[args.destGUID]
		if tbl then
			sonsTracker[args.destGUID] = nil
			local line = tbl[1]
			local marker = tbl[2]
			local icon = self:GetIconTexture(marker)
			self:SetInfo("health", line, ("%s %s"):format(icon, CL.dead))
		end
	end
	if sonsDead == 8 then
		self:CancelTimer(timer)
		self:StopBar(CL.stage:format(1))
		self:CancelDelayedMessage(CL.custom_sec:format(CL.stage:format(1), 10))
		self:Emerge()
	end
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 228438 then -- Ragnaros
		local hp = self:GetHealth(unit)
		if hp < 56 then
			self:UnregisterEvent(event)
			if hp > 50 then
				self:Message("stages", "cyan", CL.soon:format(CL.stage:format(2)), false)
			end
		end
	end
end

function mod:Damage(args)
	if not sonsTracker[args.destGUID] and self:MobId(args.destGUID) == 12143 then -- Son of Flame
		sonsTracker[args.destGUID] = {lineCount, sonsMarker, 4, "target"}
		self:SetInfo("health", lineCount, ("%s 99%%"):format(self:GetIconTexture(sonsMarker)))
		lineCount = lineCount + 1
		sonsMarker = sonsMarker - 1
		if sonsMarker == 0 then
			self:RemoveLog("SWING_DAMAGE", "*")
			self:RemoveLog("RANGE_DAMAGE", "*")
			self:RemoveLog("SPELL_DAMAGE", "*")
			self:RemoveLog("SPELL_PERIODIC_DAMAGE", "*")
		end
	end
end

function UpdateInfoBoxList()
	if not mod:IsEngaged() or mod:GetStage() == 1 then return end
	mod:SimpleTimer(UpdateInfoBoxList, 0.5)

	for guid, tbl in next, sonsTracker do
		local unitToken = tbl[4]
		if mod:UnitGUID(unitToken) ~= guid then
			unitToken = mod:GetUnitIdByGUID(guid)
		end
		if unitToken then
			tbl[4] = unitToken
			local line = tbl[1]
			local marker = tbl[2]
			tbl[3] = tbl[3]+1
			local currentHealthPercent = math.floor(mod:GetHealth(unitToken))
			local icon = mod:GetIconTexture(marker)
			mod:SetInfo("health", line, ("%s %d%%"):format(icon, currentHealthPercent))
			if tbl[3] % 5 == 0 then
				mod:CustomIcon(sonOfFlameMarker, unitToken, marker)
			end
		end
	end
end

do
	local prev = 0
	function mod:PoolOfFireDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:PersonalMessage(461062, "underyou", CL.fire)
			self:PlaySound(461062, "underyou")
		end
	end
end
