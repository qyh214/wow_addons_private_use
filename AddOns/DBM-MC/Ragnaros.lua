local mod	= DBM:NewMod("Ragnaros-Classic", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 539 $"):sub(12, -3))
mod:SetCreatureID(11502)
--mod:SetEncounterID(672)
mod:SetModelID(11121)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_DIED"
)

local warnWrathRag		= mod:NewSpellAnnounce(20566)
local warnSubmerge		= mod:NewAnnounce("WarnSubmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
local warnEmerge		= mod:NewAnnounce("WarnEmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")

local timerWrathRag		= mod:NewNextTimer(30, 20566)
local timerSubmerge		= mod:NewTimer(180, "TimerSubmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
local timerEmerge		= mod:NewTimer(90, "TimerEmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")
local timerCombatStart	= mod:NewCombatTimer(73)

local addDied = 0

function mod:OnCombatStart(delay)
	addDied = 0
	timerSubmerge:Start(-delay)
	timerWrathRag:Start(27-delay)
end

local function emerged()
	timerEmerge:Cancel()
	warnEmerge:Show()
	timerSubmerge:Start()
--	timerWrathRag:Start()--need to find out what it is first.
	addDied = 0
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 20566 then
		warnWrathRag:Show()
		timerWrathRag:Start()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.Submerge then
		self:SendSync("Submerge")
	elseif msg == L.Pull then
		timerCombatStart:Start()
	end
end

function mod:OnSync(msg)
	if msg == "Submerge" then
		self:Unschedule(emerged)
		timerWrathRag:Cancel()
		warnSubmerge:Show()
		timerEmerge:Start()
		self:Schedule(90, emerged)
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 12143 then--Son of Flame
		addDied = addDied + 1
		if addDied == 8 then--After all 8 die he emerges immediately
			self:Unschedule(emerged)
			emerged()
		end
	end
end