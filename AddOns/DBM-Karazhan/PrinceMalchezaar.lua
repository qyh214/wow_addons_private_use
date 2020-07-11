local mod	= DBM:NewMod("Prince", "DBM-Karazhan")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20200524145731")
mod:SetCreatureID(15690)
mod:SetEncounterID(661)
mod:SetModelID(19274)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 30852",
	"SPELL_AURA_APPLIED 30854 30898 39095 30843",
	"CHAT_MSG_MONSTER_YELL"
)

local warningNovaCast			= mod:NewCastAnnounce(30852, 3)
local warningInfernal			= mod:NewSpellAnnounce(37277, 2)
local warningEnfeeble			= mod:NewTargetNoFilterAnnounce(30843, 4)
local warnPhase2				= mod:NewPhaseAnnounce(2)
local warnPhase3				= mod:NewPhaseAnnounce(3)
local warningAmpMagic			= mod:NewTargetNoFilterAnnounce(39095, 3)
local warningSWP				= mod:NewTargetNoFilterAnnounce(30898, 2, nil, "RemoveMagic")

local specWarnEnfeeble			= mod:NewSpecialWarningYou(37277, nil, nil, nil, 3, 2)
local specWarnNova				= mod:NewSpecialWarningRun(30852, "Melee", nil, nil, 4, 2)

local timerNovaCD				= mod:NewNextTimer(30, 30852, nil, nil, nil, 2)
local timerNextInfernal			= mod:NewCDTimer(45, 37277, nil, nil, nil, 1)
local timerEnfeebleCD			= mod:NewNextTimer(30, 30843, nil, nil, nil, 3, nil, DBM_CORE_L.DEADLY_ICON)
local timerEnfeeble				= mod:NewBuffFadesTimer(9, 30843)

mod.vb.phase = 1
mod.vb.firstInfernal = false
local enfeebleTargets = {}

local function showEnfeebleWarning()
	warningEnfeeble:Show(table.concat(enfeebleTargets, "<, >"))
	timerEnfeebleCD:Start()
	table.wipe(enfeebleTargets)
end

local function Infernals(self)
	warningInfernal:Show()
	timerNextInfernal:Start(self.vb.phase == 3 and 22.5 or 45)
end

function mod:OnCombatStart(delay)
	self.vb.phase = 1
	self.vb.firstInfernal = false
	timerNextInfernal:Start(40-delay)
	table.wipe(enfeebleTargets)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 30852 then
		if self.Options.SpecWarn30852run then
			specWarnNova:Show()--Trivial damage, but because of enfeeble, don't want to do a blind level check here
			specWarnNova:Play("justrun")
		else
			warningNovaCast:Show()
		end
		timerNovaCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(30854, 30898) then
		warningSWP:Show(args.destName)
	elseif args.spellId == 39095 then
		warningAmpMagic:Show(args.destName)
	elseif args.spellId == 30843 then
		enfeebleTargets[#enfeebleTargets + 1] = args.destName
		if args:IsPlayer() then
			timerEnfeeble:Start()
			specWarnEnfeeble:Show()
			specWarnEnfeeble:Play("targetyou")
		end
		self:Unschedule(showEnfeebleWarning)
		self:Schedule(0.3, showEnfeebleWarning)
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.DBM_PRINCE_YELL_INF1 or msg == L.DBM_PRINCE_YELL_INF2 then
		self:Schedule(18.5, Infernals, self)--Infernal actually spawns 18.5sec after yell.
		if not self.vb.firstInfernal then
			timerNextInfernal:Start(18.5)
			self.vb.firstInfernal = true
		end
		if self.vb.phase == 3 then
			timerNextInfernal:Update(3.5, 22.5)--we attempt to update bars to show 18.5sec left. this will more than likely error out, it's not tested.
		else
			timerNextInfernal:Update(26.5, 45)--we attempt to update bars to show 18.5sec left. this will more than likely error out, it's not tested.
		end
	elseif msg == L.DBM_PRINCE_YELL_P3 then
		self.vb.phase = 3
		warnPhase3:Show()
	elseif msg == L.DBM_PRINCE_YELL_P2 then
		self.vb.phase = 2
		warnPhase2:Show()
	end
end
