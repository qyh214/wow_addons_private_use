--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Razorgore the Untamed", 469, 1529)
if not mod then return end
mod:RegisterEnableMob(12435, 12557) -- Razorgore, Grethok the Controller
mod:SetEncounterID(610)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local eggs = 0
local timer = nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.start_trigger = "Intruders have breached"

	L.eggs = "Count Eggs"
	L.eggs_desc = "Count the destroyed eggs."
	L.eggs_icon = "inv_egg_03"
	L.eggs_message = "%d/30 eggs destroyed"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		14515, -- Dominate Mind
		23023, -- Conflagration
		"eggs",
		"stages",
		"adds",
	},nil,{
		[14515] = CL.mind_control, -- Dominate Mind (Mind Control)
	}
end

if mod:GetSeason() == 2 then
	function mod:GetOptions()
		return {
			14515, -- Dominate Mind
			23023, -- Conflagration
			367873, -- Blinding Ash
			366909, -- Ruby Flames
			367740, -- Creeping Chill
			"eggs",
			"stages",
		},nil,{
			[14515] = CL.mind_control, -- Dominate Mind (Mind Control)
			[367873] = CL.underyou:format(CL.fire), -- Blinding Ash (Fire under YOU)
			[366909] = CL.underyou:format(CL.fire), -- Ruby Flames (Fire under YOU)
		}
	end
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:Log("SPELL_AURA_APPLIED", "DominateMind", 14515)
	self:Log("SPELL_CAST_SUCCESS", "DestroyEgg", 19873)
	self:Log("SPELL_CAST_SUCCESS", "Conflagration", 23023)
	self:Log("SPELL_AURA_APPLIED", "ConflagrationApplied", 23023)
	if self:GetSeason() == 2 then
		self:Log("SPELL_AURA_APPLIED", "GroundDamage", 367873, 366909) -- Blinding Ash, Ruby Flames
		self:Log("SPELL_PERIODIC_DAMAGE", "GroundDamage", 367873, 366909)
		self:Log("SPELL_PERIODIC_MISSED", "GroundDamage", 367873, 366909)
		self:Log("SPELL_AURA_APPLIED", "CreepingChillApplied", 367740)
		self:Log("SPELL_AURA_APPLIED_DOSE", "CreepingChillApplied", 367740)
	end
end

function mod:OnEngage()
	eggs = 0
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:Bar("adds", 45, CL.adds, "Spell_Holy_PrayerOfHealing")
	self:ScheduleTimer(function() self:Message("adds", "cyan", CL.adds_spawning, false) end, 45)
	if self:GetPlayerAura(467047) then -- Black Essence
		self:Bar("adds", 120, CL.big_add, "inv_misc_head_dragon_01")
		timer = self:ScheduleTimer("BigAdd", 120)
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.start_trigger, nil, true) then
		self:Engage()
	end
end

function mod:DominateMind(args)
	self:TargetMessage(args.spellId, "red", args.destName, CL.mind_control)
	if self:Me(args.destGUID) or self:Dispeller("magic") then
		self:PlaySound(args.spellId, "alert", nil, args.destName)
	end
end

function mod:BigAdd()
	self:StopBar(CL.big_add)
	if timer then
		self:CancelTimer(timer)
		timer = nil
	end
	self:Message("adds", "cyan", CL.big_add, "inv_misc_head_dragon_01")
	self:PlaySound("adds", "long")
end

function mod:DestroyEgg()
	eggs = eggs + 1
	self:Message("eggs", "green", L.eggs_message:format(eggs), L.eggs_icon, nil, eggs < 30 and self:Classic() and 3) -- Stay onscreen for 3s
	if eggs == 30 then
		self:SetStage(2)
		self:Message("stages", "cyan", CL.stage:format(2), false)
		self:PlaySound("stages", "long")
	elseif eggs == 10 and self:GetPlayerAura(467047) then -- Black Essence
		self:BigAdd()
	end
end

do
	local playerList = {}
	function mod:Conflagration()
		playerList = {}
	end

	function mod:ConflagrationApplied(args)
		if self:Player(args.destFlags) then -- Players only, can apply to enemy NPCs
			playerList[#playerList+1] = args.destName
			self:TargetsMessage(args.spellId, "orange", playerList)
			self:PlaySound(args.spellId, "info", nil, playerList)
		end
	end
end

do
	local prev = 0
	function mod:GroundDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou", CL.fire)
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

function mod:CreepingChillApplied(args)
	if self:Me(args.destGUID) then
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 3)
		if args.amount and args.amount >= 3 then
			self:PlaySound(args.spellId, "alarm", nil, args.destName)
		end
	end
end
