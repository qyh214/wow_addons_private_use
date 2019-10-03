local mod	= DBM:NewMod("Ragnaros-Classic", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20190905050401")
mod:SetCreatureID(11502)
mod:SetEncounterID(672)
mod:SetModelID(11121)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)
mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 20566",
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
local timerCombatStart	= mod:NewCombatTimer(73)

mod.vb.addLeft = 8
local addsGuidCheck = {}

function mod:OnCombatStart(delay)
	table.wipe(addsGuidCheck)
	self.vb.addLeft = 8
	timerWrathRag:Start(26.7-delay)
	timerSubmerge:Start(180-delay)
end

local function emerged(self)
	timerEmerge:Cancel()
	warnEmerge:Show()
	timerWrathRag:Start(26.7)
	timerSubmerge:Start(180)
	table.wipe(addsGuidCheck)
	self.vb.addLeft = 8
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 20566 then
		warnWrathRag:Show()
		timerWrathRag:Start()
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
			if self.vb.addLeft == 0 then--After all 8 die he emerges immediately
				self:Unschedule(emerged)
				emerged(self)
			end
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	--"<264.91 00:32:46> [UNIT_SPELLCAST_SUCCEEDED] Ragnaros(??) -Ragnaros Submerge Visual- [[boss1:Cast-3-3882-409-7508-20567-0000F08FEE:20567]]", -- [475]
	--"<265.01 00:32:46> [CHAT_MSG_MONSTER_YELL] COME FORTH, MY SERVANTS! DEFEND YOUR MASTER!#Ragnaros#####0#0##0#91#nil#0#false#false#false#false", -- [481]
	if msg == L.Submerge then
		self:SendSync("Submerge")
	--Could also use this instead
	--"<37.8 22:36:31> [CLEU] SPELL_CAST_START#false#Creature-0-3137-409-16929-54404-00007003D3#Majordomo Executus#2584#0##nil#-2147483648#-2147483648#19774#Summon Ragnaros#4", -- [1677]
	--"<38.0 22:36:31> [CHAT_MSG_MONSTER_YELL] CHAT_MSG_MONSTER_YELL#Impudent whelps! You've rushed headlong to your own deaths! See now, the master stirs!\r\n#Majordomo Executus###Shiramura
	elseif msg == L.Pull then
		timerCombatStart:Start()
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

function mod:OnSync(msg)
	if not self:IsInCombat() then return end
	if msg == "Submerge" then
		self:Unschedule(emerged)
		timerWrathRag:Cancel()
		warnSubmerge:Show()
		timerEmerge:Start(90)
		self:Schedule(90, emerged, self)
	elseif msg == "AddDied" and guid and not addsGuidCheck[guid] then
		--A unit died we didn't detect ourselves, so we correct our adds counter from sync
		addsGuidCheck[guid] = true
		self.vb.addLeft = self.vb.addLeft - 1
		if self.vb.addLeft == 0 then--After all 8 die he emerges immediately
			self:Unschedule(emerged)
			emerged(self)
		end
	end
end
