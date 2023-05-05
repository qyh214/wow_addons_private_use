local mod	= DBM:NewMod("Mimiron", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20230425015704")
mod:SetCreatureID(33432)
if not mod:IsClassic() then
	mod:SetEncounterID(1138)
else
	mod:SetEncounterID(754)
end
mod:DisableESCombatDetection()--fires for RP, and we need yells to identify hard mode anyways
mod:SetModelID(28578)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)
mod:SetHotfixNoticeRev(20230209000000)
mod:SetMinSyncRevision(20230113000000)

mod:RegisterCombat("combat_yell", L.YellPull)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 63631 64529 62997 64570 64623",
	"SPELL_CAST_SUCCESS 63027 63414",
	"SPELL_AURA_APPLIED 63666 65026 64529 62997",
	"SPELL_AURA_REMOVED 63666 65026 64529 62997",
	"SPELL_SUMMON 63811",
	"UNIT_SPELLCAST_CHANNEL_STOP",
	"UNIT_SPELLCAST_SUCCEEDED",--BOSS ids still left out because classic is still using it for rocket strike
	"CHAT_MSG_LOOT"
)

local blastWarn						= mod:NewTargetNoFilterAnnounce(64529, 4, nil, "Tank|Healer")
local shellWarn						= mod:NewTargetNoFilterAnnounce(63666, 2, nil, "Healer")
local lootannounce					= mod:NewAnnounce("MagneticCore", 1, 64444, nil, nil, nil, 64444)
local warnBombSpawn					= mod:NewAnnounce("WarnBombSpawn", 3, 63811, nil, nil, nil, 63811)
local warnFrostBomb					= mod:NewSpellAnnounce(64623, 3)

local warnShockBlast				= mod:NewSpecialWarningRun(63631, "Melee", nil, nil, 4, 2)
local warnRocketStrike				= mod:NewSpecialWarningDodge(64402, nil, nil, nil, 2, 2)
local warnP3Wx2LaserBarrage			= mod:NewSpecialWarningDodge(63274, nil, nil, nil, 3, 2)
local warnPlasmaBlast				= mod:NewSpecialWarningDefensive(64529, nil, nil, nil, 1, 2)

local enrage 						= mod:NewBerserkTimer(900)
local timerHardmode					= mod:NewTimer(610, "TimerHardmode", 64582)
local timerP1toP2					= mod:NewTimer(41.5, "TimeToPhase2", "136116", nil, nil, 6)
local timerP2toP3					= mod:NewTimer(24, "TimeToPhase3", "136116", nil, nil, 6)
local timerP3toP4					= mod:NewTimer(27.9, "TimeToPhase4", "136116", nil, nil, 6)
local timerProximityMines			= mod:NewCDTimer(30.2, 63027, nil, nil, nil, 3)
local timerShockBlast				= mod:NewCastTimer(4, 63631, nil, nil, nil, 2)
local timerShockBlastCD				= mod:NewCDTimer(35, 63631, nil, nil, nil, 2)
local timerRocketStrikeCD			= mod:NewCDTimer(20, 64402, nil, nil, nil, 3)--20-25
local timerSpinUp					= mod:NewCastTimer(4, 63414, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)--precast
local timerP3Wx2LaserBarrageCast	= mod:NewCastTimer(10, 63274, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)--channel
local timerNextP3Wx2LaserBarrage	= mod:NewNextTimer(48, 63414, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)--next cast
local timerNextShockblast			= mod:NewNextTimer(34, 63631, nil, nil, nil, 2)
local timerPlasmaBlastCD			= mod:NewCDTimer(30, 64529, nil, "Tank|Healer", 3, 5)
local timerShell					= mod:NewBuffActiveTimer(6, 63666, nil, "Healer", 2, 5, nil, DBM_COMMON_L.HEALER_ICON)
--local timerNextFlameSuppressant	= mod:NewNextTimer(60, 64570, nil, nil, nil, 3)
local timerFlameSuppressant			= mod:NewBuffActiveTimer(10, 65192, nil, nil, nil, 3)
--local timerNextFrostBomb			= mod:NewNextTimer(80, 64623, nil, nil, nil, 3, nil, DBM_COMMON_L.HEROIC_ICON)
local timerBombExplosion			= mod:NewCastTimer(15, 65333, nil, nil, nil, 3)

mod:AddSetIconOption("SetIconOnNapalm", 63666, false, false, {1, 2, 3, 4, 5, 6, 7})
mod:AddSetIconOption("SetIconOnPlasmaBlast", 64529, false, false, {8})
mod:AddRangeFrameOption("6")

mod:GroupSpells(63274, 63414)--Spinning Up and P3Wx2

mod.vb.hardmode = false
mod.vb.napalmShellIcon = 7
local spinningUp = DBM:GetSpellInfo(63414)
local lastSpinUp = 0
mod.vb.is_spinningUp = false
local napalmShellTargets = {}

local function warnNapalmShellTargets(self)
	shellWarn:Show(table.concat(napalmShellTargets, "<, >"))
	table.wipe(napalmShellTargets)
	self.vb.napalmShellIcon = 7
end

local function show_warning_for_spinup(self)
	if self.vb.is_spinningUp then
		warnP3Wx2LaserBarrage:Show()
		warnP3Wx2LaserBarrage:Play("watchstep")
		warnP3Wx2LaserBarrage:ScheduleVoice(1, "keepmove")
	end
end

function mod:OnCombatStart(delay)
	self.vb.hardmode = false
	enrage:Start(-delay)
	self:SetStage(1)
	self.vb.is_spinningUp = false
	self.vb.napalmShellIcon = 7
	table.wipe(napalmShellTargets)
	timerPlasmaBlastCD:Start(16.8-delay)
	timerShockBlastCD:Start(20.7-delay)
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
		warnShockBlast:Play("runout")
		timerShockBlast:Start()
		timerNextShockblast:Start()
	end
	if args:IsSpellID(64529, 62997) then -- plasma blast
		local tanking, status = UnitDetailedThreatSituation("player", "boss1")--Change boss unitID if it's not boss 1
		if tanking or (status == 3) then
			warnPlasmaBlast:Show()
			warnPlasmaBlast:Play("defensive")
		end
		timerPlasmaBlastCD:Start()
	end
	if args.spellId == 64570 then
		timerFlameSuppressant:Start()
	end
	if args.spellId == 64623 then
		warnFrostBomb:Show()
		timerBombExplosion:Start()
--		timerNextFrostBomb:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 63027 then				-- mines
		timerProximityMines:Start()
	elseif args.spellId == 63414 then			-- Spinning UP (before Dark Glare)
		self.vb.is_spinningUp = true
		timerSpinUp:Start()
		timerP3Wx2LaserBarrageCast:Schedule(4)
		timerNextP3Wx2LaserBarrage:Schedule(14)			-- 4 (cast spinup) + 10 sec (channel)
		DBM:Schedule(0.15, show_warning_for_spinup, self)	-- wait 0.15 and then announce it, otherwise it will sometimes fail
		lastSpinUp = GetTime()
--	elseif args.spellId == 65192 then
--		timerNextFlameSuppressant:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(63666, 65026) and args:IsDestTypePlayer() then -- Napalm Shell
		napalmShellTargets[#napalmShellTargets + 1] = args.destName
		timerShell:Start()
		if self.Options.SetIconOnNapalm and self.vb.napalmShellIcon > 0 then
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

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(63666, 65026) then -- Napalm Shell
		if self.Options.SetIconOnNapalm then
			self:SetIcon(args.destName, 0)
		end
	end
end

function mod:SPELL_SUMMON(args)
	if args.spellId == 63811 then -- Bomb Bot
		warnBombSpawn:Show()
	end
end

function mod:UNIT_SPELLCAST_CHANNEL_STOP(unit, _, spellId)
	local spell = DBM:GetSpellInfo(spellId)--DO BETTER with log
	if spell == spinningUp and GetTime() - lastSpinUp < 3.9 then
		self.vb.is_spinningUp = false
		self:SendSync("SpinUpFail")
	end
end

function mod:CHAT_MSG_LOOT(msg, _, _, _, player)
	if msg:find("Hitem:46029") and player then
		player = DBM:GetUnitFullName(player) or player
		lootannounce:Show(player)
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellHardPull or msg:find(L.YellHardPull) then
		timerHardmode:Start()
		--timerNextFlameSuppressant:Start()
		enrage:Stop()
		self.vb.hardmode = true
	elseif self:IsClassic() then--Legacy code
		if (msg == L.YellPhase2 or msg:find(L.YellPhase2)) then
			self:SendSync("Phase2")
		elseif (msg == L.YellPhase3 or msg:find(L.YellPhase3)) then
			self:SendSync("Phase3")
		elseif (msg == L.YellPhase4 or msg:find(L.YellPhase4)) then
			self:SendSync("Phase4")
		end
	end
end

--p1 to P2 Retail
--"<148.72 20:35:06> [CLEU] UNIT_DIED##nil#Creature-0-3134-603-12576-34071-00004DDF6F#Leviathan Mk II#-1#false#nil#nil", -- [715]
--"<149.92 20:35:08> [DBM_Debug] UNIT_TARGETABLE_CHANGED event fired for Leviathan Mk II. Active: false#nil", -- [724]
--"<153.97 20:35:12> [UNIT_SPELLCAST_SUCCEEDED] Leviathan Mk II(0.0%-0.0%){Target:??} -Freeze Anim- [[boss1:Cast-3-3134-603-12576-63354-00004DE450:63354]]", -- [732]
--"<153.97 20:35:12> [UNIT_SPELLCAST_SUCCEEDED] Leviathan Mk II(0.0%-0.0%){Target:??} -ClearAllDebuffs- [[boss1:Cast-3-3134-603-12576-34098-0000CDE450:34098]]", -- [733]
--"<158.18 20:35:16> [CHAT_MSG_MONSTER_YELL] WONDERFUL! Positively marvelous results! Hull integrity at 98.9 percent! Barely a dent! Moving right along.
--"<191.12 20:35:49> [CHAT_MSG_MONSTER_YELL] Behold the VX-001 Anti-personnel Assault Cannon! You might want to take cover.#Mimiron###Leviathan Mk II##0#0##0#150#nil#0#false#false#false#false",
--"<197.06 20:35:55> [DBM_Debug] UNIT_TARGETABLE_CHANGED event fired for VX-001. Active: true#nil", -- [783]

--P1 to P2 Classic
--"<7969.81 21:54:10> [CLEU] UNIT_DIED##nil#Creature-0-4445-603-16861-34071-00005FF300#Leviathan Mk II#-1#false#nil#nil", -- [209328]
--"<7971.42 21:54:12> [UNIT_TARGETABLE_CHANGED] -nameplate1- [CanAttack:false#Exists:false#IsVisible:true#Name:Leviathan Mk II#GUID:Vehicle-0-4445-603-16861-33432-00005FF300#Classification:worldboss#Health:1]", -- [209378
--"<7981.35 21:54:22> [CHAT_MSG_MONSTER_YELL] WONDERFUL! Positively marvelous results! Hull integrity at 98.9 percent! Barely a dent! Moving right along.#Mimiron###Leviathan Mk II##0#0##
--"<8015.20 21:54:56> [CHAT_MSG_MONSTER_YELL] Behold the VX-001 Anti-personnel Assault Cannon! You might want to take cover.#Mimiron###Leviathan Mk II##0#0##0#2974#nil#0#false#false#false#false",
--"<8021.61 21:55:02> [CLEU] SPELL_CAST_SUCCESS#Vehicle-0-4445-603-16861-33651-0000601793#VX-001##nil#64582#Emergency Mode#nil#nil", -- [209779]--Hard mode only

--p2 to P3 Retail
--"<295.88 20:37:34> [UNIT_SPELLCAST_SUCCEEDED] VX-001(0.0%-0.0%){Target:??} -Vehicle Damaged- [[boss2:Cast-3-3134-603-12576-63415-00004DE4DE:63415]]", -- [1032]
--"<295.88 20:37:34> [UNIT_SPELLCAST_SUCCEEDED] VX-001(0.0%-0.0%){Target:??} -ClearAllDebuffs- [[boss2:Cast-3-3134-603-12576-34098-0000CDE4DE:34098]]", -- [1033]
--"<295.90 20:37:34> [DBM_Debug] UNIT_TARGETABLE_CHANGED event fired for VX-001. Active: false#nil", -- [1039]
--"<303.00 20:37:41> [CHAT_MSG_MONSTER_YELL] Thank you, friends! Your efforts have yielded some fantastic data! Now, where did I put-- oh, there it is.
--"<317.62 20:37:55> [CHAT_MSG_MONSTER_YELL] Isn't it beautiful? I call it the magnificent aerial command unit!#Mimiron###VX-001##0#0##0#156#nil#0#false#false#false#false", -- [1051]
--"<319.89 20:37:58> [DBM_Debug] UNIT_TARGETABLE_CHANGED event fired for Aerial Command Unit. Active: true#nil", -- [1056]

--P2 to P3 Classic
--"<8093.04 21:56:13> [CHAT_MSG_MONSTER_YELL] Thank you, friends! Your efforts have yielded some fantastic data! Now, where did I put-- oh, there it is.#
--"<8115.73 21:56:36> [CHAT_MSG_MONSTER_YELL] Isn't it beautiful? I call it the magnificent aerial command unit!#Mimiron###VX-001##0#0##0#2983#nil#0#false#false#false#false", -- [213905]
--"<8118.78 21:56:39> [CLEU] SPELL_AURA_APPLIED#Vehicle-0-4445-603-16861-33670-00006017F2#Aerial Command Unit#Vehicle-0-4445-603-16861-33670-00006017F2#Aerial Command Unit#64582#Emergency Mode#BUFF#nil", -- [213921]

--P3 to P4 Retail
--"<367.17 20:38:45> [UNIT_SPELLCAST_SUCCEEDED] Aerial Command Unit(0.0%-0.0%){Target:Omegal} -Vehicle Damaged- [[boss3:Cast-3-3134-603-12576-63415-00004DE525:63415]]", -- [1174]
--"<370.79 20:38:49> [UNIT_SPELLCAST_SUCCEEDED] Aerial Command Unit(0.0%-0.0%){Target:??} -ClearAllDebuffs- [[boss3:Cast-3-3134-603-12576-34098-0000CDE528:34098]]", -- [1182]
--"<370.79 20:38:49> [DBM_Debug] UNIT_TARGETABLE_CHANGED event fired for Aerial Command Unit. Active: false#nil", -- [1190]
--"<374.62 20:38:52> [CHAT_MSG_MONSTER_YELL] Preliminary testing phase complete. Now comes the true test!#Mimiron
--"<393.25 20:39:11> [CHAT_MSG_MONSTER_YELL] Gaze upon its magnificence! Bask in its glorious, um, glory! I present you with... V-07-TR-0N!
--"<398.74 20:39:16> [DBM_Debug] UNIT_TARGETABLE_CHANGED event fired for Leviathan Mk II. Active: true#nil", -- [1260]
--"<398.74 20:39:16> [DBM_Debug] UNIT_TARGETABLE_CHANGED event fired for VX-001. Active: true#nil", -- [1262]
--"<398.74 20:39:16> [DBM_Debug] UNIT_TARGETABLE_CHANGED event fired for Aerial Command Unit. Active: true#nil", -- [1264]

--P3 to P4 Classic
--"<9657.41 22:22:18> [CHAT_MSG_MONSTER_YELL] Preliminary testing phase complete. Now comes the true test!#Mimiron###Aerial Command Unit##0#0##0#3185#nil#0#false#false#false#false", -- [248368]
--"<9676.85 22:22:37> [CHAT_MSG_MONSTER_YELL] Gaze upon its magnificence! Bask in its glorious, um, glory! I present you with... V-07-TR-0N!
--"<9683.01 22:22:43> [PLAYER_TARGET_CHANGED] -1 Hostile (worldboss Mechanical) - VX-001 # Vehicle-0-4445-603-16861-33651-0000601CE7", -- [248605]

--Classic can't use this for phase changes because boss isn't an active unit ID on stage changes without boss frames
--Classic can use it for rocket strike since that's cast while boss is actually active
--Filter exists in case boss unit Ids do get added at some point, wouldn't want double stage changes and would need time to review it before removing yells again
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	--Modern phasing path, where boss unit Ids exist.
	if spellId == 34098 and self:AntiSpam(5, 1) and not self:IsClassic() then--ClearAllDebuffs
		self:SetStage(0)
		if self:GetStage(2) then
			timerNextShockblast:Stop()
			timerProximityMines:Stop()
			timerFlameSuppressant:Stop()
			--timerNextFlameSuppressant:Stop()
			timerPlasmaBlastCD:Stop()
			timerP1toP2:Start()--41.5
--			if self.vb.hardmode then
--				timerNextFrostBomb:Start(42.2)--Disabled since i'm not entirely convinced this has a timer but instead is cast when a certain fire threshold is triggrred, i've seen from 42 all the way to never cast (solo raids with far less fire).
--			end
			timerRocketStrikeCD:Start(63)
			timerNextP3Wx2LaserBarrage:Start(75)
			if self.Options.RangeFrame then
				DBM.RangeCheck:Hide()
			end
		elseif self:GetStage(3) then
			timerP3Wx2LaserBarrageCast:Stop()
			timerNextP3Wx2LaserBarrage:Stop()
--			timerNextFrostBomb:Stop()
			timerRocketStrikeCD:Stop()
			timerP2toP3:Start()--24
		elseif self:GetStage(4) then
			timerP3toP4:Start()--27.9
			--Need to be reverified on live
--			if self.vb.hardmode then
--				timerNextFrostBomb:Start(32)
--			end
			timerRocketStrikeCD:Start(50)
			timerNextP3Wx2LaserBarrage:Start(59.8)
			timerNextShockblast:Start(75.5)
		end
	elseif (spellId == 64402 or spellId == 65034) then--P2, P4 Rocket Strike
		self:SendSync("RocketStrike")
	end
end

function mod:OnSync(event, args)
	if not self:IsInCombat() then return end
	if event == "SpinUpFail" then
		self.vb.is_spinningUp = false
		timerSpinUp:Cancel()
		timerP3Wx2LaserBarrageCast:Cancel()
		timerNextP3Wx2LaserBarrage:Cancel()
		warnP3Wx2LaserBarrage:Cancel()
	elseif event == "Phase2" and self:GetStage(1) then -- alternate localized-dependent detection
		self:SetStage(2)
		timerNextShockblast:Stop()
		timerProximityMines:Stop()
		timerFlameSuppressant:Stop()
		--timerNextFlameSuppressant:Stop()
		timerPlasmaBlastCD:Stop()
		--Timers are using retail adjusted to yell, need actual confirmation
		timerP1toP2:Start(37.2)
--		if self.vb.hardmode then
--			timerNextFrostBomb:Start(42.2)
--		end
		timerRocketStrikeCD:Start(58.7)
		timerNextP3Wx2LaserBarrage:Start(70.9)
		if self.Options.RangeFrame then
			DBM.RangeCheck:Hide()
		end
	elseif event == "Phase3" and self:GetStage(2) then
		self:SetStage(3)
		timerP3Wx2LaserBarrageCast:Stop()
		timerNextP3Wx2LaserBarrage:Stop()
--		timerNextFrostBomb:Stop()
		timerRocketStrikeCD:Stop()
		timerP2toP3:Start(16.8)--16.8-25, using yells is swell
	elseif event == "Phase4" and self:GetStage(3) then
		self:SetStage(4)
		--All these timers might be wrong because they are mashed between retail and legacy using math guesses
		timerP3toP4:Start(24)
		--Adjusted to live, but live timers might be wrong, plus need to be classic vetted anyways
--		if self.vb.hardmode then
--			timerNextFrostBomb:Start(28.5)
--		end
		timerRocketStrikeCD:Start(46.1)
		timerNextP3Wx2LaserBarrage:Start(55.9)
		timerNextShockblast:Start(71.6)
	elseif event == "RocketStrike" then
		warnRocketStrike:Show()
		warnRocketStrike:Play("watchstep")
		timerRocketStrikeCD:Start()
	end
end
