--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Noth the Plaguebringer", 533, 1604)
if not mod then return end
mod:RegisterEnableMob(15954)
mod:SetEncounterID(1117)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local timeroom = 90
local timebalcony = 70
local wave1time = 10
local wave2time = 41
local addsCount = 1
local curseCount = 0
local curseTime = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.adds_yell_trigger = "Rise, my soldiers" -- Rise, my soldiers! Rise and fight once more!
	L.adds_icon = "inv_misc_bone_dwarfskull_01"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		"adds",
		29212, -- Cripple
		29213, -- Curse of the Plaguebringer
		29214, -- Wrath of the Plaguebringer
		29208, -- Blink
	},nil,{
		[29213] = CL.curse, -- Curse of the Plaguebringer (Curse)
		[29214] = CL.explosion, -- Wrath of the Plaguebringer (Explosion)
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:Log("SPELL_AURA_APPLIED", "Cripple", 29212, 54814) -- 10, 25
	self:Log("SPELL_CAST_SUCCESS", "CurseOfThePlaguebringer", 29213, 54835) -- 10, 25
	self:Log("SPELL_AURA_APPLIED", "CurseOfThePlaguebringerApplied", 29213, 54835)
	self:Log("SPELL_AURA_REMOVED", "CurseOfThePlaguebringerRemoved", 29213, 54835)
	self:Log("SPELL_AURA_APPLIED", "WrathOfThePlaguebringerApplied", 29214, 54836) -- 10, 25
	self:Log("SPELL_CAST_SUCCESS", "Blink", 29208, 29209, 29210, 29211)
end

function mod:OnEngage()
	timeroom = 90
	timebalcony = 70
	addsCount = 1
	curseCount = 0
	curseTime = 0
	self:SetStage(1)

	self:CDBar(29213, 9, CL.curse) -- Curse of the Plaguebringer
	self:CDBar("adds", 14, CL.count:format(CL.adds, addsCount), L.adds_icon) -- Adds

	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:DelayedMessage("stages", timeroom - 10, "cyan", CL.custom_sec:format(CL.stage:format(2), 10))
	self:Bar("stages", timeroom, CL.stage:format(2), "Spell_Magic_LesserInvisibilty")
	self:ScheduleTimer("TeleportToBalcony", timeroom)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local function NextAdds()
		mod:Message("adds", "orange", CL.count:format(CL.adds, addsCount), L.adds_icon)
		addsCount = addsCount + 1
		if mod:GetStage() == 1 then
			mod:CDBar("adds", 32, CL.count:format(CL.adds, addsCount), L.adds_icon) -- 30~42
		end
		mod:PlaySound("adds", "info")
	end
	function mod:CHAT_MSG_MONSTER_YELL(_, msg)
		if msg:find(L.adds_yell_trigger, nil, true) then
			self:Bar("adds", {5, addsCount == 1 and 15 or 33}, CL.count:format(CL.adds, addsCount), L.adds_icon)
			self:ScheduleTimer(NextAdds, 5)
		end
	end
end

function mod:Cripple(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(29212)
	end
end

function mod:CurseOfThePlaguebringer(args)
	curseCount = 0
	curseTime = args.time
	self:Message(29213, "red", CL.curse)
	self:CDBar(29213, 51.7, CL.curse)
	self:Bar(29214, 10, CL.explosion) -- Wrath of the Plaguebringer
	self:PlaySound(29213, "warning")
end

function mod:CurseOfThePlaguebringerApplied()
	curseCount = curseCount + 1
end

function mod:CurseOfThePlaguebringerRemoved(args)
	curseCount = curseCount - 1
	if curseCount == 0 then
		self:StopBar(CL.explosion)
		self:Message(29213, "green", CL.removed_after:format(CL.curse, args.time-curseTime))
	end
end

do
	local prev = 0
	function mod:WrathOfThePlaguebringerApplied(args)
		if args.time - prev > 10 then
			prev = args.time
			self:Message(29214, "red", CL.explosion)
			self:PlaySound(29214, "alarm")
		end
	end
end

function mod:Blink(args)
	if self:MobId(args.sourceGUID) == 15954 then
		self:Message(29208, "yellow")
		self:PlaySound(29208, "alert")
	end
end

function mod:TeleportToBalcony()
	if timeroom == 90 then
		timeroom = 110
	elseif timeroom == 110 then
		timeroom = 180
	end
	self:StopBar(CL.count:format(CL.adds, addsCount)) -- Adds
	addsCount = 1
	self:SetStage(2)

	self:StopBar(29208) -- Blink
	self:StopBar(CL.curse) -- Curse of the Plaguebringer

	self:Message("stages", "cyan", CL.stage:format(2), false)
	self:Bar("stages", timebalcony, CL.stage:format(1), "Spell_Magic_LesserInvisibilty")
	self:DelayedMessage("stages", timebalcony - 10, "cyan", CL.custom_sec:format(CL.stage:format(1), 10))

	self:Bar("adds", wave1time, CL.count:format(CL.adds, 1), L.adds_icon)
	self:Bar("adds", wave2time, CL.count:format(CL.adds, 2), L.adds_icon)

	self:ScheduleTimer("TeleportToRoom", timebalcony)
	wave2time = wave2time + 15
	self:PlaySound("stages", "long")
end

function mod:TeleportToRoom()
	if timebalcony == 70 then
		timebalcony = 95
	elseif timebalcony == 95 then
		timebalcony = 120
	end
	addsCount = 1
	self:SetStage(1)

	self:CDBar(29213, 11, CL.curse) -- Curse of the Plaguebringer
	self:CDBar("adds", 15, CL.count:format(CL.adds, 1), L.adds_icon)
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:Bar("stages", timeroom, CL.stage:format(2), "Spell_Magic_LesserInvisibilty")
	self:DelayedMessage("stages", timeroom - 10, "cyan", CL.custom_sec:format(CL.stage:format(2), 10))
	self:ScheduleTimer("TeleportToBalcony", timeroom)
	self:PlaySound("stages", "long")
end
