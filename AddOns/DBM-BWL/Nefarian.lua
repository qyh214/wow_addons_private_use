local mod	= DBM:NewMod("Nefarian-Classic", "DBM-BWL", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20200329220248")
mod:SetCreatureID(11583)
mod:SetEncounterID(617)
mod:SetModelID(11380)
mod:RegisterCombat("combat_yell", L.YellP1)--ENCOUNTER_START appears to fire when he lands, so start of phase 2, ignoring all of phase 1
mod:SetWipeTime(50)--guesswork
mod:SetHotfixNoticeRev(20200310000000)--2020, Mar, 10th
mod:SetMinSyncRevision(20200310000000)--2020, Mar, 10th

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 22539 22686",
	"SPELL_AURA_APPLIED 22687 22667",
	"UNIT_HEALTH boss1",
	"CHAT_MSG_MONSTER_YELL"
)

local WarnAddsLeft		= mod:NewAnnounce("WarnAddsLeft", 2, "136116")
local warnClassCall		= mod:NewAnnounce("WarnClassCall", 3, "136116")
local warnPhase			= mod:NewPhaseChangeAnnounce()
local warnPhase3Soon	= mod:NewPrePhaseAnnounce(3)
local warnShadowFlame	= mod:NewCastAnnounce(22539, 2)
local warnFear			= mod:NewCastAnnounce(22686, 2)

local specwarnMC		= mod:NewSpecialWarningTarget(22667, nil, nil, 2, 1, 2)
local specwarnVeilShadow= mod:NewSpecialWarningDispel(22687, "RemoveCurse", nil, nil, 1, 2)

local timerPhase		= mod:NewPhaseTimer(15)
local timerClassCall	= mod:NewTimer(30, "TimerClassCall", "136116", nil, nil, 5)
local timerFearNext		= mod:NewCDTimer(26.7, 22686, nil, nil, nil, 2)--26-42.5

mod.vb.phase = 1
mod.vb.addLeft = 20
local addsGuidCheck = {}

function mod:OnCombatStart(delay, yellTriggered)
	table.wipe(addsGuidCheck)
	if yellTriggered then--Triggered by Phase 1 yell from talking to Nefarian (uncomment if ENCOUNTER_START isn't actually fixed with weekly reset)
		self.vb.phase = 1
		self.vb.addLeft = 42
	else--Blizz can't seem to figure out ENCOUNTER_START, so any pull not triggered by yell will be treated as if it's already phase 2
		self.vb.phase = 2
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 22539 then
		warnShadowFlame:Show()
	elseif args.spellId == 22686 then
		warnFear:Show()
		timerFearNext:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 22687 then
		if self:CheckDispelFilter() then
			specwarnVeilShadow:Show(args.destName)
			specwarnVeilShadow:Play("dispelnow")
		end
	elseif args.spellId == 22667 then
		specwarnMC:Show(args.destName)
		specwarnMC:Play("findmc")
	end
end

function mod:UNIT_DIED(args)
	local guid = args.destGUID
	local cid = self:GetCIDFromGUID(guid)
	if cid == 14264 or cid == 14263 or cid == 14261 or cid == 14265 or cid == 14262 or cid == 14302 then--Red, Bronze, Blue, Black, Green, Chromatic
		self:SendSync("AddDied", guid)--Send sync it died do to combat log range and size of room
		--We're in range of event, no reason to wait for sync, especially in a raid that might not have many DBM users
		if not addsGuidCheck[guid] then
			addsGuidCheck[guid] = true
			self.vb.addLeft = self.vb.addLeft - 1
			if self.vb.addLeft >= 1 and (self.vb.addLeft % 3 == 0) then
				WarnAddsLeft:Show(self.vb.addLeft)
			end
		end
	end
end

function mod:UNIT_HEALTH(uId)
	if UnitHealth(uId) / UnitHealthMax(uId) <= 0.25 and self:GetUnitCreatureId(uId) == 11583 and self.vb.phase < 2.5 then
		warnPhase3Soon:Show()
		self.vb.phase = 2.5
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellDK or msg:find(L.YellDK) then
		self:SendSync("ClassCall", "DEATHKNIGHT")
	elseif msg == L.YellDH or msg:find(L.YellDH) then
		self:SendSync("ClassCall", "DEMONHUNTER")
	elseif msg == L.YellDruid or msg:find(L.YellDruid) then
		self:SendSync("ClassCall", "DRUID")
	elseif msg == L.YellHunter or msg:find(L.YellHunter) then
		self:SendSync("ClassCall", "HUNTER")
	elseif msg == L.YellWarlock or msg:find(L.YellWarlock) then
		self:SendSync("ClassCall", "WARLOCK")
	elseif msg == L.YellMage or msg:find(L.YellMage) then
		self:SendSync("ClassCall", "MAGE")
	elseif msg == L.YellPaladin or msg:find(L.YellPaladin) then
		self:SendSync("ClassCall", "PALADIN")
	elseif msg == L.YellPriest or msg:find(L.YellPriest) then
		self:SendSync("ClassCall", "PRIEST")
	elseif msg == L.YellRogue or msg:find(L.YellRogue) then
		self:SendSync("ClassCall", "ROGUE")
	elseif msg == L.YellShaman or msg:find(L.YellShaman) then
		self:SendSync("ClassCall", "SHAMAN")
	elseif msg == L.YellWarrior or msg:find(L.YellWarrior) then
		self:SendSync("ClassCall", "WARRIOR")
	elseif msg == L.YellMonk or msg:find(L.YellMonk) then
		self:SendSync("ClassCall", "MONK")
	elseif msg == L.YellP2 or msg:find(L.YellP2) then
		self:SendSync("Phase", 2)
	elseif msg == L.YellP3 or msg:find(L.YellP3) then
		self:SendSync("Phase", 3)
	end
end

function mod:OnSync(msg, arg)
	if msg == "ClassCall" then
		warnClassCall:Show(LOCALIZED_CLASS_NAMES_MALE[arg])
		timerClassCall:Start(30, LOCALIZED_CLASS_NAMES_MALE[arg])
	elseif msg == "Phase" then
		local phase = tonumber(arg) or 0
		if phase == 2 then
			self.vb.phase = 2
			timerPhase:Start(15)
		elseif phase == 3 then
			self.vb.phase = 3
		end
		warnPhase:Show(DBM_CORE_AUTO_ANNOUNCE_TEXTS.stage:format(arg))
	elseif msg == "AddDied" and arg and not addsGuidCheck[arg] then
		--A unit died we didn't detect ourselves, so we correct our adds counter from sync
		addsGuidCheck[arg] = true
		self.vb.addLeft = self.vb.addLeft - 1
		if self.vb.addLeft >= 1 and (self.vb.addLeft % 3 == 0) then
			WarnAddsLeft:Show(self.vb.addLeft)
		end
	end
end
