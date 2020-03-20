local mod	= DBM:NewMod("Ragnaros-Classic", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20200218153056")
mod:SetCreatureID(11502)
mod:SetEncounterID(672)
mod:SetModelID(11121)
mod:SetHotfixNoticeRev(20200218000000)--2020, 02, 18
mod:SetMinSyncRevision(20200218000000)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_CAST_START 19774",
	"SPELL_CAST_SUCCESS 20566 19773",
	"CHAT_MSG_MONSTER_YELL"
)
mod:RegisterEventsInCombat(
	"UNIT_DIED",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
ability.id = 20566 and type = "cast" or target.id = 12143 and type = "death"
--]]
local warnWrathRag		= mod:NewSpellAnnounce(20566, 3)
local warnSubmerge		= mod:NewAnnounce("WarnSubmerge", 2, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
local warnEmerge		= mod:NewAnnounce("WarnEmerge", 2, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")

local timerWrathRag		= mod:NewCDTimer(25, 20566, nil, nil, nil, 2)--25-30
local timerSubmerge		= mod:NewTimer(180, "TimerSubmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp", nil, nil, 6)
local timerEmerge		= mod:NewTimer(90, "TimerEmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp", nil, nil, 6)
local timerCombatStart	= mod:NewTimer(73, "timerCombatStart", "132349", nil, nil, nil, nil, nil, 1, 3)

mod.vb.addLeft = 8
mod.vb.ragnarosEmerged = true
local addsGuidCheck = {}

mod:AddRangeFrameOption("10", nil, "-Melee")

function mod:OnCombatStart(delay)
	table.wipe(addsGuidCheck)
	self.vb.addLeft = 0
	self.vb.ragnarosEmerged = true
	timerWrathRag:Start(26.7-delay)
	timerSubmerge:Start(180-delay)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(10)
	end
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

local function emerged(self)
	self.vb.ragnarosEmerged = true
	timerEmerge:Cancel()
	warnEmerge:Show()
	timerWrathRag:Start(26.7)
	timerSubmerge:Start(180)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 19774 and self:AntiSpam(5, 4) then
		self:SendSync("SummonRag")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 20566 then
		warnWrathRag:Show()
		timerWrathRag:Start()
	elseif args.spellId == 19773 then
		self:SendSync("DomoDeath")
	end
end

function mod:UNIT_DIED(args)
	local guid = args.destGUID
	local cid = self:GetCIDFromGUID(guid)
	if cid == 12143 then--Son of Flame
		self:SendSync("AddDied", guid)--Send sync it died do to combat log range and size of room
		--We're in range of event, no reason to wait for sync, especially in a raid that might not have many DBM users
		if not addsGuidCheck[guid] then
			addsGuidCheck[guid] = true
			self.vb.addLeft = self.vb.addLeft - 1
			if not self.vb.ragnarosEmerged and self.vb.addLeft == 0 then--After all 8 die he emerges immediately
				self:Unschedule(emerged)
				emerged(self)
			end
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.Submerge then
		self:SendSync("Submerge")
	elseif msg == L.Pull and self:AntiSpam(5, 4) then
		self:SendSync("SummonRag")
	end
end

--Retail only, no UNIT events in classic
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 20567 then--Ragnaros Submerge Visual
		self:Unschedule(emerged)
		timerWrathRag:Cancel()
		warnSubmerge:Show()
		timerEmerge:Start(90)
		self:Schedule(90, emerged, self)
	end
end

function mod:OnSync(msg, arg)
	if not self:IsInCombat() then return end
	if msg == "Submerge" then
		self.vb.ragnarosEmerged = false
		self:Unschedule(emerged)
		timerWrathRag:Cancel()
		warnSubmerge:Show()
		timerEmerge:Start(90)
		self:Schedule(90, emerged, self)
		self.vb.addLeft = self.vb.addLeft + 8
	elseif msg == "AddDied" and arg and not addsGuidCheck[arg] then
		--A unit died we didn't detect ourselves, so we correct our adds counter from sync
		addsGuidCheck[arg] = true
		self.vb.addLeft = self.vb.addLeft - 1
		if not self.vb.ragnarosEmerged and self.vb.addLeft == 0 then--After all 8 die he emerges immediately
			self:Unschedule(emerged)
			emerged(self)
		end
	elseif msg == "SummonRag" and self:AntiSpam(5, 2) then
		timerCombatStart:Start()
	elseif msg == "DomoDeath" and self:AntiSpam(5, 3) then
		--The timer between yell/summon start and ragnaros being attackable is variable, but time between domo death and him being attackable is not.
		--As such, we start lowest timer of that variation on the RP start, but adjust timer if it's less than 10 seconds at time domo dies
		local remaining = timerCombatStart:GetRemaining()
		if remaining < 10 then
			local adjust = 10 - remaining
			timerCombatStart:AddTime(adjust)
		end
	end
end
