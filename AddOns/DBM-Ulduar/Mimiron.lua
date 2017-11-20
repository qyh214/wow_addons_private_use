local mod	= DBM:NewMod("Mimiron", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 247 $"):sub(12, -3))
mod:SetCreatureID(33432)
mod:SetEncounterID(1138)
mod:DisableESCombatDetection()
mod:SetModelID(28578)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)

mod:RegisterCombat("yell", L.YellPull)
mod:RegisterCombat("yell", L.YellHardPull)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 63631 64529 62997 64570 64623",
	"SPELL_CAST_SUCCESS 63027 63414 65192",
	"SPELL_AURA_APPLIED 63666 65026 64529 62997",
	"SPELL_AURA_REMOVED",--ALL EVENTS on purpose
	"SPELL_SUMMON 63811",
	"UNIT_SPELLCAST_CHANNEL_STOP boss1 boss2 boss3 boss4",
	"CHAT_MSG_LOOT"
)

local blastWarn					= mod:NewTargetAnnounce(64529, 4)
local shellWarn					= mod:NewTargetAnnounce(63666, 2)
local lootannounce				= mod:NewAnnounce("MagneticCore", 1, 64444)
local warnBombSpawn				= mod:NewAnnounce("WarnBombSpawn", 3, 63811)
local warnFrostBomb				= mod:NewSpellAnnounce(64623, 3)

local warnShockBlast			= mod:NewSpecialWarningRun(63631, "Melee", nil, nil, 4, 2)
local warnDarkGlare				= mod:NewSpecialWarningDodge(63293, nil, nil, nil, 3, 2)
local warnPlasmaBlast			= mod:NewSpecialWarningDefensive(63293, nil, nil, nil, 1, 2)

local enrage 					= mod:NewBerserkTimer(900)
local timerHardmode				= mod:NewTimer(610, "TimerHardmode", 64582)
local timerP1toP2				= mod:NewTimer(41.5, "TimeToPhase2", "Interface\\Icons\\Spell_Nature_WispSplode", nil, nil, 6)
local timerP2toP3				= mod:NewTimer(25, "TimeToPhase3", "Interface\\Icons\\Spell_Nature_WispSplode", nil, nil, 6)
local timerP3toP4				= mod:NewTimer(26.5, "TimeToPhase4", "Interface\\Icons\\Spell_Nature_WispSplode", nil, nil, 6)
local timerProximityMines		= mod:NewNextTimer(35, 63027)
local timerShockBlast			= mod:NewCastTimer(63631, nil, nil, nil, 2)
local timerSpinUp				= mod:NewCastTimer(4, 63414, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON)
local timerDarkGlareCast		= mod:NewCastTimer(10, 63274, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON)
local timerNextDarkGlare		= mod:NewNextTimer(41, 63274, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON)
local timerNextShockblast		= mod:NewNextTimer(34, 63631, nil, nil, nil, 2)
local timerPlasmaBlastCD		= mod:NewCDTimer(30, 64529, nil, "Tank", 2, 5)
local timerShell				= mod:NewBuffActiveTimer(6, 63666)
local timerNextFlameSuppressant	= mod:NewNextTimer(60, 64570)
local timerFlameSuppressant		= mod:NewBuffActiveTimer(10, 65192)
local timerNextFrostBomb		= mod:NewNextTimer(30, 64623, nil, nil, nil, 3)
local timerBombExplosion		= mod:NewCastTimer(15, 65333, nil, nil, nil, 3)

local voiceShockBlast			= mod:NewVoice(64412, "Melee")--runout
local voiceDarkGlare			= mod:NewVoice(63293)--watchstep/keepmove
local voicePlasmaBlast			= mod:NewVoice(63293)--defensive

mod:AddBoolOption("HealthFramePhase4", true)
mod:AddBoolOption("SetIconOnNapalm", false)
mod:AddBoolOption("SetIconOnPlasmaBlast", false)
mod:AddBoolOption("RangeFrame")

mod.vb.hardmode = false
mod.vb.phase = 0
mod.vb.napalmShellIcon = 7
local spinningUp = GetSpellInfo(63414)
local lastSpinUp = 0
local is_spinningUp = false
local napalmShellTargets = {}

local function warnNapalmShellTargets(self)
	shellWarn:Show(table.concat(napalmShellTargets, "<, >"))
	table.wipe(napalmShellTargets)
	self.vb.napalmShellIcon = 7
end

local function show_warning_for_spinup()
	if is_spinningUp then
		warnDarkGlare:Show()
		voiceDarkGlare:Play("watchstep")
		voiceDarkGlare:Schedule(1, "keepmove")
	end
end

function mod:OnCombatStart(delay)
	self.vb.hardmode = false
	enrage:Start(-delay)
	self.vb.phase = 0
	is_spinningUp = false
	self.vb.napalmShellIcon = 7
	table.wipe(napalmShellTargets)
	self:NextPhase()
	timerPlasmaBlastCD:Start(20-delay)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(6)
	end
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 63631 then
		warnShockBlast:Show()
		voiceShockBlast:Play("runout")
		timerShockBlast:Start()
		timerNextShockblast:Start()
	end
	if args:IsSpellID(64529, 62997) then -- plasma blast
		local tanking, status = UnitDetailedThreatSituation("player", "boss1")--Change boss unitID if it's not boss 1
		if tanking or (status == 3) then
			warnPlasmaBlast:Show()
			voicePlasmaBlast:Play("defensive")
		end
		timerPlasmaBlastCD:Start()
	end
	if args.spellId == 64570 then
		timerFlameSuppressant:Start()
	end
	if args.spellId == 64623 then
		warnFrostBomb:Show()
		timerBombExplosion:Start()
		timerNextFrostBomb:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 63027 then				-- mines
		timerProximityMines:Start()
	elseif args.spellId == 63414 then			-- Spinning UP (before Dark Glare)
		is_spinningUp = true
		timerSpinUp:Start()
		timerDarkGlareCast:Schedule(4)
		timerNextDarkGlare:Schedule(19)			-- 4 (cast spinup) + 15 sec (cast dark glare)
		DBM:Schedule(0.15, show_warning_for_spinup)	-- wait 0.15 and then announce it, otherwise it will sometimes fail
		lastSpinUp = GetTime()
	elseif args.spellId == 65192 then
		timerNextFlameSuppressant:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(63666, 65026) and args:IsDestTypePlayer() then -- Napalm Shell
		napalmShellTargets[#napalmShellTargets + 1] = args.destName
		timerShell:Start()
		if self.Options.SetIconOnNapalm then
			self:SetIcon(args.destName, self.vb.napalmShellIcon, 6)
		end
		self.vb.napalmShellIcon = self.vb.napalmShellIcon - 1
		self:Unschedule(warnNapalmShellTargets)
		self:Schedule(0.3, warnNapalmShellTargets, self)
	elseif args:IsSpellID(64529, 62997) then -- Plasma Blast
		blastWarn:Show(args.destName)
		if self.Options.SetIconOnPlasmaBlast then
			self:SetIcon(args.destName, 8, 6)
		end
	end
end

do 
	local count = 0
	local last = 0
	local lastPhaseChange = 0
	function mod:SPELL_AURA_REMOVED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if GetTime() - lastPhaseChange > 30 and (cid == 33432 or cid == 33651 or cid == 33670) then
			if args.timestamp == last then	-- all events in the same tick to detect the phases earlier (than the yell) and localization-independent
				count = count + 1
				if (self:IsDifficulty("normal10") and count > 4) or (self:IsDifficulty("normal25") and count > 9) then
					lastPhaseChange = GetTime()
					self:NextPhase()
				end
			else
				count = 1
			end
			last = args.timestamp
		elseif args:IsSpellID(63666, 65026) then -- Napalm Shell
			if self.Options.SetIconOnNapalm then
				self:SetIcon(args.destName, 0)
			end
		end
	end
end

function mod:SPELL_SUMMON(args)
	if args.spellId == 63811 then -- Bomb Bot
		warnBombSpawn:Show()
	end
end


function mod:UNIT_SPELLCAST_CHANNEL_STOP(unit, spell)
	if spell == spinningUp and GetTime() - lastSpinUp < 3.9 then
		is_spinningUp = false
		self:SendSync("SpinUpFail")
	end
end

function mod:CHAT_MSG_LOOT(msg)
	-- DBM:AddMsg(msg) --> Meridium receives loot: [Magnetic Core]
	local player, itemID = msg:match(L.LootMsg)
	player = DBM:GetUnitFullName(player)
	if player and itemID and tonumber(itemID) == 46029 and self:IsInCombat() then
		self:SendSync("LootMsg", player)
	end
end

function mod:NextPhase()
	self.vb.phase = self.vb.phase + 1
	if self.vb.phase == 1 then
		if DBM.BossHealth:IsShown() then
			DBM.BossHealth:Clear()
			DBM.BossHealth:AddBoss(33432, L.MobPhase1)
		end

	elseif self.vb.phase == 2 then
		timerNextShockblast:Stop()
		timerProximityMines:Stop()
		timerFlameSuppressant:Stop()
		timerNextFlameSuppressant:Stop()
		timerPlasmaBlastCD:Stop()
		timerP1toP2:Start()
		if DBM.BossHealth:IsShown() then
			DBM.BossHealth:Clear()
			DBM.BossHealth:AddBoss(33651, L.MobPhase2)
		end
		if self.Options.RangeFrame then
			DBM.RangeCheck:Hide()
		end
		if self.vb.hardmode then
			timerNextFrostBomb:Start(42)
		end
	elseif self.vb.phase == 3 then
		timerDarkGlareCast:Cancel()
		timerNextDarkGlare:Cancel()
		timerNextFrostBomb:Cancel()
		timerP2toP3:Start()
		if DBM.BossHealth:IsShown() then
			DBM.BossHealth:Clear()
			DBM.BossHealth:AddBoss(33670, L.MobPhase3)
		end

	elseif self.vb.phase == 4 then
		timerP3toP4:Start()
		if self.Options.HealthFramePhase4 or DBM.BossHealth:IsShown() then
			DBM.BossHealth:Clear()
			DBM.BossHealth:Show(L.name)
			DBM.BossHealth:AddBoss(33670, L.MobPhase3)
			DBM.BossHealth:AddBoss(33651, L.MobPhase2)
			DBM.BossHealth:AddBoss(33432, L.MobPhase1)
		end
--		if self.vb.hardmode then
--			timerNextFrostBomb:Start(73)
--		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if (msg == L.YellPhase2 or msg:find(L.YellPhase2)) then
		--DBM:AddMsg("ALPHA: yell detect phase2, syncing to clients")
		self:SendSync("Phase2")	-- untested alpha! (this will result in a wrong timer)

	elseif (msg == L.YellPhase3 or msg:find(L.YellPhase3)) then
		--DBM:AddMsg("ALPHA: yell detect phase3, syncing to clients")
		self:SendSync("Phase3")	-- untested alpha! (this will result in a wrong timer)

	elseif (msg == L.YellPhase4 or msg:find(L.YellPhase4)) then
		--DBM:AddMsg("ALPHA: yell detect phase3, syncing to clients")
		self:SendSync("Phase4") -- SPELL_AURA_REMOVED detection might fail in phase 3...there are simply not enough debuffs on him

	elseif msg == L.YellHardPull or msg:find(L.YellHardPull) then
		timerHardmode:Start()
		timerNextFlameSuppressant:Start()
		enrage:Stop()
		self.vb.hardmode = true
	end
end


function mod:OnSync(event, args)
	if event == "SpinUpFail" then
		is_spinningUp = false
		timerSpinUp:Cancel()
		timerDarkGlareCast:Cancel()
		timerNextDarkGlare:Cancel()
		warnDarkGlare:Cancel()
	elseif event == "Phase2" and self.vb.phase == 1 then -- alternate localized-dependent detection
		self:NextPhase()
	elseif event == "Phase3" and self.vb.phase == 2 then
		self:NextPhase()
	elseif event == "Phase4" and self.vb.phase == 3 then
		self:NextPhase()
	elseif event == "LootMsg" and args then
		lootannounce:Show(args)
	end
end
