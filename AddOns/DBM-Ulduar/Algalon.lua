local mod	= DBM:NewMod("Algalon", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

if not mod:IsClassic() then--on classic, it's normal10,normal25, defined in toc, only retail overrides to remove timewalking
	mod.statTypes = "normal"
end

mod:SetRevision("20230414020000")
mod:SetCreatureID(32871)
if not mod:IsClassic() then--Assumed fixed in classic
	mod:SetEncounterID(1130)
	mod:DisableEEKillDetection()--EE always fires wipe
else
	mod:SetEncounterID(757)
end
mod:SetHotfixNoticeRev(20230120000000)
mod:SetMinSyncRevision(20230120000000)
mod:SetModelID(28641)
--mod:SetModelSound("Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_Aggro01.ogg", "Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_Slay02.ogg")

mod:RegisterCombat("combat")
mod:RegisterKill("yell", L.YellKill)
mod:SetWipeTime(60)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 64584 64443",
	"SPELL_CAST_SUCCESS 65108 64122 64598 62301 64412",
	"SPELL_AURA_APPLIED 64412",
	"SPELL_AURA_APPLIED_DOSE 64412",
	"SPELL_AURA_REMOVED 64412",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_SPELLCAST_SUCCEEDED",
	"UNIT_HEALTH"
)

--TODO, when wrath servers come out, FirstPull might be needed again, if boss unit Ids aren't enabled on WoTLK servers
--TODO, see if supermassive fail fires late enough to be picked up without boss unitIds, if not, have to rework initial timers again for classic
--[[
(ability.id = 64584 or ability.id = 64443) and type = "begincast"
 or (ability.id = 65108 or ability.id = 64122 or ability.id = 64598 or ability.id = 62301 or ability.id = 64412) and type = "cast"
 or (source.type = "NPC" and source.firstSeen = timestamp) or (target.type = "NPC" and target.firstSeen = timestamp)
--]]
local warnPhase2				= mod:NewPhaseAnnounce(2, 2)
local warnPhase2Soon			= mod:NewAnnounce("WarnPhase2Soon", 2)
local announcePreBigBang		= mod:NewPreWarnAnnounce(64584, 5, 3)
local announceBlackHole			= mod:NewSpellAnnounce(65108, 2)
local announcePhasePunch		= mod:NewStackAnnounce(64412, 4, nil, "Tank|Healer")

local specwarnStarLow			= mod:NewSpecialWarning("warnStarLow", "Tank|Healer", nil, nil, 1, 2)
local specWarnPhasePunch		= mod:NewSpecialWarningStack(64412, nil, 4, nil, nil, 1, 6)
local specWarnBigBang			= mod:NewSpecialWarningSpell(64584, nil, nil, nil, 3, 2)
local specWarnCosmicSmash		= mod:NewSpecialWarningDodge(64596, nil, nil, nil, 2, 2)

local timerCombatStart			= mod:NewCombatTimer(42)
local timerNextBigBang			= mod:NewNextTimer(90.5, 64584, nil, nil, nil, 2)
local timerBigBangCast			= mod:NewCastTimer(8, 64584, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)
local timerNextCollapsingStar	= mod:NewTimer(15, "NextCollapsingStar", "237016")
local timerCDCosmicSmash		= mod:NewCDTimer(24.6, 64596, nil, nil, nil, 3)
local timerCastCosmicSmash		= mod:NewCastTimer(4.5, 64596)
local timerPhasePunch			= mod:NewTargetTimer(45, 64412, nil, "Tank", 2, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerNextPhasePunch		= mod:NewNextTimer(15.5, 64412, nil, "Tank", 2, 5, nil, DBM_COMMON_L.TANK_ICON)
local enrageTimer				= mod:NewBerserkTimer(360)

--mod:AddInfoFrameOption(64122, true)--Disabled until post squish health is known. Wowhead is not parsing data correctly

local sentLowHP = {}
local warnedLowHP = {}
mod.vb.warned_preP2 = false
mod.vb.firstPull10 = true
mod.vb.firstPull25 = true

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.warned_preP2 = false
	table.wipe(sentLowHP)
	table.wipe(warnedLowHP)
	if self:IsClassic() then
		if self:IsDifficulty("normal10") then
			if self.vb.firstPull10 then--First pull, ENCOUNTER_START fires at end of extended first pull RP
				self.vb.firstPull10 = false
				timerCombatStart:Start(26)
				timerNextCollapsingStar:Start(42)
				timerCDCosmicSmash:Start(51.9)
				announcePreBigBang:Schedule(111)
				timerNextBigBang:Start(116)
				enrageTimer:Start(386)
			else--Not first pull, ENCOUNTER_START fires at start of 8 second rp
				timerCombatStart:Start(8)
				timerNextCollapsingStar:Start(24)
				timerCDCosmicSmash:Start(33.9)
				announcePreBigBang:Schedule(93)
				timerNextBigBang:Start(98)
				enrageTimer:Start(368)
			end
		else
			if self.vb.firstPull25 then--First pull, ENCOUNTER_START fires at end of extended first pull RP
				self.vb.firstPull25 = false
				timerCombatStart:Start(26)
				timerNextCollapsingStar:Start(42)
				timerCDCosmicSmash:Start(51.9)
				announcePreBigBang:Schedule(111)
				timerNextBigBang:Start(116)
				enrageTimer:Start(386)
			else--Not first pull, ENCOUNTER_START fires at start of 8 second rp
				timerCombatStart:Start(8)
				timerNextCollapsingStar:Start(24)
				timerCDCosmicSmash:Start(33.9)
				announcePreBigBang:Schedule(93)
				timerNextBigBang:Start(98)
				enrageTimer:Start(368)
			end
		end
	else
		if self.vb.firstPull10 then--First pull, ENCOUNTER_START fires at end of extended first pull RP
			self.vb.firstPull10 = false
			timerCombatStart:Start(26)
		else--Not first pull, ENCOUNTER_START fires at start of 8 second rp
			timerCombatStart:Start(8)
		end
	end
--	if self.Options.InfoFrame and not self:IsTrivial() then
--		DBM.InfoFrame:SetHeader(L.HealthInfo)
--		DBM.InfoFrame:Show(5, "health", 18000)
--	end
end

--function mod:OnCombatEnd()
--	if self.Options.InfoFrame then
--		DBM.InfoFrame:Hide()
--	end
--end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(64584, 64443) then 	-- Big Bang
		timerBigBangCast:Start()
		timerNextBigBang:Start()
		announcePreBigBang:Schedule(80)
		specWarnBigBang:Show()
		if self:IsTank() then
			specWarnBigBang:Play("defensive")
		else
			specWarnBigBang:Play("findshelter")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(65108, 64122) then 	-- Black Hole Explosion
		announceBlackHole:Show()
	elseif args:IsSpellID(64598, 62301) then	-- Cosmic Smash
		timerCastCosmicSmash:Start()
		timerCDCosmicSmash:Start()
		specWarnCosmicSmash:Show()
		specWarnCosmicSmash:Play("watchstep")
	elseif args.spellId == 64412 then
		timerNextPhasePunch:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 64412 then
		local amount = args.amount or 1
		if args:IsPlayer() and amount >= 4 then
			specWarnPhasePunch:Show(args.amount)
			specWarnPhasePunch:Play("stackhigh")
		end
		timerPhasePunch:Start(args.destName)
		announcePhasePunch:Show(args.destName, amount)
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 64412 then
		timerPhasePunch:Stop(args.destName)
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg == L.Emote_CollapsingStar or msg:find(L.Emote_CollapsingStar) then
		timerNextCollapsingStar:Start()
	end
end

--"<47.18 22:25:26> [CHAT_MSG_MONSTER_YELL] The stars come to my aid!#Algalon the Observer#####0#0##0#139#nil#0#false#false#false#false", -- [59]
--"<47.18 22:25:26> [CHAT_MSG_RAID_BOSS_EMOTE] %s begins to Summon Collapsing Stars!#Algalon the Observer#####0#0##0#140#nil#0#false#false#false#false", -- [60]
function mod:CHAT_MSG_MONSTER_YELL(msg)
	if (msg == L.Phase2 or msg:find(L.Phase2)) then
		self:SendSync("Phase2")
	end
end

function mod:UNIT_HEALTH(uId)
	local cid = self:GetUnitCreatureId(uId)
	local guid = UnitGUID(uId)
	if cid == 32871 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.23 and not self.vb.warned_preP2 then
		self.vb.warned_preP2 = true
		warnPhase2Soon:Show()
	elseif cid == 32955 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.25 and not sentLowHP[guid] then
		sentLowHP[guid] = true
		self:SendSync("lowhealth", guid)
	end
end

--Retail timeline (First Pull)
--"<4.84 22:24:43> [DBM_Debug] ENCOUNTER_START event fired: 1130 Algalon the Observer 14 10#nil", -- [3]
--"<4.90 22:24:43> [DBM_Debug] UNIT_TARGETABLE_CHANGED event fired for Algalon the Observer. Active: false#nil", -- [12]
--"<5.06 22:24:44> [CHAT_MSG_MONSTER_YELL] Your actions are illogical. All possible results for this encounter have been calculated.
--"<20.31 22:24:59> [CHAT_MSG_MONSTER_YELL] See your world through my eyes: A universe so vast as to be immeasurable - incomprehensible even to your greatest minds
--"<31.23 22:25:10> [UNIT_SPELLCAST_SUCCEEDED] Algalon the Observer(100.0%-0.0%){Target:??} -Supermassive Fail- [[boss1:Cast-3-4219-603-30708-65311-00024B5B16:65311]]", -- [19]
--"<31.24 22:25:10> [DBM_Debug] UNIT_TARGETABLE_CHANGED event fired for Algalon the Observer. Active: true#nil", -- [25]
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 65311 and not self:IsClassic() then--Supermassive Fail (fires when he becomes actually active)
		self:SendSync("Supermassive")
	elseif spellId == 65256 then--Self Stun (phase 2)
		self:SendSync("Phase2")
	end
end

function mod:OnSync(msg, guid)
	if not self:IsInCombat() then return end
	if msg == "lowhealth" and guid and not warnedLowHP[guid] then
		warnedLowHP[guid] = true
		if self:AntiSpam(2.5, 1) then
			specwarnStarLow:Show()
			specwarnStarLow:Play("aesoon")
		end
	elseif msg == "Supermassive" and not self:IsClassic() then
		timerNextCollapsingStar:Start(16)
		timerCDCosmicSmash:Start(26)
		announcePreBigBang:Schedule(85)
		timerNextBigBang:Start(90)
		enrageTimer:Start(360)
	elseif msg == "Phase2" and self:GetStage(2, 1) then
		self:SetStage(2)
		self.vb.warned_preP2 = true
		timerNextCollapsingStar:Stop()
		warnPhase2:Show()
	end
end
