local mod	= DBM:NewMod("Vashj", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 546 $"):sub(12, -3))
mod:SetCreatureID(21212)
mod:SetModelID(20748)
mod:SetZone()
mod:SetUsedIcons(1)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"UNIT_DIED",
	"CHAT_MSG_MONSTER_YELL",
	"CHAT_MSG_LOOT"
)

local warnCharge		= mod:NewTargetAnnounce(38280, 4)
local warnEntangle		= mod:NewSpellAnnounce(38316, 3)
local warnPhase2		= mod:NewPhaseAnnounce(2)
local warnElemental		= mod:NewAnnounce("WarnElemental", 4, 31687)
local warnStrider		= mod:NewAnnounce("WarnStrider", 3, 475)
local warnNaga			= mod:NewAnnounce("WarnNaga", 3, 2120)
local warnShield		= mod:NewAnnounce("WarnShield", 3)
local warnLoot			= mod:NewAnnounce("WarnLoot", 4, 38132)
local warnPhase3		= mod:NewPhaseAnnounce(3)

local specWarnCharge	= mod:NewSpecialWarningYou(38280)
local specWarnElemental	= mod:NewSpecialWarning("SpecWarnElemental")--Changed from soon to a now warning. the soon warning not accurate because of 11 second variation so not useful special warning.
local specWarnToxic		= mod:NewSpecialWarningMove(38575)

local timerCharge		= mod:NewTargetTimer(20, 38280)
local timerElemental	= mod:NewTimer(22, "TimerElementalActive", 39088)--Blizz says they are active 20 seconds per patch notes, but my logs don't match those results. 22 second up time.
local timerElementalCD	= mod:NewTimer(45, "TimerElemental", 39088)--46-57 variation. because of high variation the pre warning special warning not useful, fortunately we can detect spawns with precise timing.
local timerStrider		= mod:NewTimer(63, "TimerStrider", 475)
local timerNaga			= mod:NewTimer(47.5, "TimerNaga", 2120)

mod:AddBoolOption("RangeFrame", true)
mod:AddBoolOption("ChargeIcon", false)
mod:AddBoolOption("AutoChangeLootToFFA", true)

local shieldLeft = 4
local nagaCount = 1
local striderCount = 1
local elementalCount = 1
local lootmethod, masterlooterRaidID
local elementals = {}

function mod:StriderSpawn()
	striderCount = striderCount + 1
	timerStrider:Start(nil, tostring(striderCount))
	warnStrider:Schedule(57, tostring(striderCount))
	self:ScheduleMethod(63, "StriderSpawn")
end

function mod:NagaSpawn()
	nagaCount = nagaCount + 1
	timerNaga:Start(nil, tostring(nagaCount))
	warnNaga:Schedule(42.5, tostring(nagaCount))
	self:ScheduleMethod(47.5, "NagaSpawn")
end

function mod:OnCombatStart(delay)
	table.wipe(elementals)
	shieldLeft = 4
	nagaCount = 1
	striderCount = 1
	elementalCount = 1
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show()
	end
	if IsInGroup() and DBM:GetRaidRank() == 2 then
		lootmethod, _, masterlooterRaidID = GetLootMethod()
	end
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
	if IsInGroup() and self.Options.AutoChangeLootToFFA and DBM:GetRaidRank() == 2 then
		if masterlooterRaidID then
			SetLootMethod(lootmethod, "raid"..masterlooterRaidID)
		else
			SetLootMethod(lootmethod)
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 38280 then
		warnCharge:Show(args.destName)
		timerCharge:Start(args.destName)
		if args:IsPlayer() then
			specWarnCharge:Show()
		end
		if self.Options.ChargeIcon then
			self:SetIcon(args.destName, 1, 20)
		end
	elseif args.spellId == 38575 and args:IsPlayer() and self:AntiSpam() then
		specWarnToxic:Show()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 38280 then
		timerCharge:Cancel(args.destName)
		if self.Options.ChargeIcon then
			self:SetIcon(args.destName, 0)
		end
	elseif args.spellId == 38132 then
		if self.Options.LootIcon then
			self:SetIcon(args.destName, 0)
		end
	--[[elseif args.spellId == 38112 then
		shieldLeft = shieldLeft - 1
		warnShield:Show(shieldLeft)]]
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 38253 and not elementals[args.sourceGUID] then
		specWarnElemental:Show()
		timerElemental:Start()
		elementals[args.sourceGUID] = true
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 38316 then
		warnEntangle:Show()
	end
end

--[[
--Tainted elemental spawns and deaths. always cast Poison Bolt on spawn, so spawn time is good. In my log i missed first two.
--seem to respawn faster if you don't kill.
"<3.1 02:34:55> [CLEU] SPELL_CAST_SUCCESS#false#0x0400000002203642#Omegathree#1297#0#0xF13052DC0000633D#Lady Vashj#199240#0#879#Exorcism#2", -- [5]

"<19.4 02:35:12> [CHAT_MSG_MONSTER_YELL] CHAT_MSG_MONSTER_YELL#The time is now! Leave none standing! #Lady Vashj#####0#0##0#385#nil#0#false#false", -- [138]

"<67.2 02:35:59> [CLEU] SPELL_CAST_START#false#0xF13055F90000732F#Unknown#2632#0##nil#-2147483648#-2147483648#38253#Poison Bolt#8", -- [324]
"<88.5 02:36:21> [CLEU] SPELL_CAST_SUCCESS#false#0xF13055F90000732F#Tainted Elemental#2632#0#0x0400000002203642#Omegathree#1297#0#38253#Poison Bolt#8", -- [457]

"<90.3 02:36:23> [CLEU] SPELL_CAST_START#false#0xF13055F90000737E#Tainted Elemental#2632#0##nil#-2147483648#-2147483648#38253#Poison Bolt#8", -- [464] +23
"<112.0 02:36:44> [CLEU] SPELL_CAST_SUCCESS#false#0xF13055F90000737E#Tainted Elemental#2632#32#0x0400000002203642#Omegathree#1297#0#38253#Poison Bolt#8", -- [570]

"<119.5 02:36:52> [CLEU] SPELL_CAST_START#false#0xF13055F9000073CF#Tainted Elemental#2632#0##nil#-2147483648#-2147483648#38253#Poison Bolt#8", -- [618] +29
"<140.2 02:37:12> [CLEU] UNIT_DIED#true##nil#-2147483648#-2147483648#0xF13055F9000073CF#Tainted Elemental#68168#8", -- [734]

"<192.6 02:38:05> [CLEU] SPELL_CAST_START#false#0xF13055F900007474#Tainted Elemental#2632#0##nil#-2147483648#-2147483648#38253#Poison Bolt#8", -- [970]
"<201.0 02:38:13> [CLEU] UNIT_DIED#true##nil#-2147483648#-2147483648#0xF13055F900007474#Tainted Elemental#68168#0", -- [1031]

"<258.3 02:39:11> [CLEU] SPELL_CAST_START#false#0xF13055F900007509#Tainted Elemental#2632#0##nil#-2147483648#-2147483648#38253#Poison Bolt#8", -- [1301]
"<261.1 02:39:13> [CLEU] UNIT_DIED#true##nil#-2147483648#-2147483648#0xF13055F900007509#Tainted Elemental#68168#0", -- [1320]

"<307.7 02:40:00> [CLEU] SPELL_CAST_START#false#0xF13055F90000766B#Tainted Elemental#2632#0##nil#-2147483648#-2147483648#38253#Poison Bolt#8", -- [1520]
"<312.2 02:40:04> [CLEU] UNIT_DIED#true##nil#-2147483648#-2147483648#0xF13055F90000766B#Tainted Elemental#68168#0", -- [1542]
--]]
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 22009 then
		elementalCount = elementalCount + 1
		timerElementalCD:Start(nil, tostring(elementalCount))
		warnElemental:Schedule(45, tostring(elementalCount))
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.DBM_VASHJ_YELL_PHASE2 or msg:find(L.DBM_VASHJ_YELL_PHASE2) then
		nagaCount = 1
		striderCount = 1
		elementalCount = 1
		shieldLeft = 4
		warnPhase2:Show()
		timerNaga:Start(nil, tostring(nagaCount))
		warnNaga:Schedule(42.5, tostring(elementalCount))
		self:ScheduleMethod(47.5, "NagaSpawn")
		timerElementalCD:Start(nil, tostring(elementalCount))
		warnElemental:Schedule(45, tostring(elementalCount))
		timerStrider:Start(nil, tostring(striderCount))
		warnStrider:Schedule(57, tostring(striderCount))
		self:ScheduleMethod(63, "StriderSpawn")
		if IsInGroup() and self.Options.AutoChangeLootToFFA and DBM:GetRaidRank() == 2 then
			SetLootMethod("freeforall")
		end
	elseif msg == L.DBM_VASHJ_YELL_PHASE3 or msg:find(L.DBM_VASHJ_YELL_PHASE3) then
		warnPhase3:Show()
		timerNaga:Cancel()
		warnNaga:Cancel()
		timerElementalCD:Cancel()
		warnElemental:Cancel()
		timerStrider:Cancel()
		warnStrider:Cancel()
		self:UnscheduleMethod("NagaSpawn")
		self:UnscheduleMethod("StriderSpawn")
		if IsInGroup() and self.Options.AutoChangeLootToFFA and DBM:GetRaidRank() == 2 then
			if masterlooterRaidID then
				SetLootMethod(lootmethod, "raid"..masterlooterRaidID)
			else
				SetLootMethod(lootmethod)
			end
		end
	end
end

function mod:CHAT_MSG_LOOT(msg)
	-- DBM:AddMsg(msg) --> Meridium receives loot: [Magnetic Core]
	local player, itemID = msg:match(L.LootMsg)
	player = DBM:GetUnitFullName(player)
	if player and itemID and tonumber(itemID) == 31088 and self:IsInCombat() then
		self:SendSync("LootMsg", player)
	end
end

function mod:OnSync(event, args)
	if event == "LootMsg" and args then
		warnLoot:Show(args)
	end
end
