--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Nefarian Classic", 469, 1536)
if not mod then return end
mod:RegisterEnableMob(11583, 10162, 14261, 14262, 14263, 14264, 14265, 14302) -- Nefarian, Lord Victor Nefarius, Blue, Green, Bronze, Red, Black, Chromatic
mod:SetEncounterID(617)
if mod:GetSeason() ~= 2 then
	mod:SetRespawnTime(900)
end
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local classCallYellTable = {}
local classCallSpellTable = {}
local adds_dead = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.engage_yell_trigger = "Let the games begin"
	L.stage3_yell_trigger = "Impossible! Rise my"

	L.shaman_class_call_yell_trigger = "Shamans"
	L.deathknight_class_call_yell_trigger = "Death Knights" -- Death Knights... get over here!
	L.monk_class_call_yell_trigger = "Monks"
	L.hunter_class_call_yell_trigger = "Hunters" -- Hunters and your annoying pea-shooters!

	L.warnshaman = "Shamans - Totems spawned!"
	L.warndruid = "Druids - Stuck in cat form!"
	L.warnwarlock = "Warlocks - Incoming Infernals!"
	L.warnpriest = "Priests - Heals hurt!"
	L.warnhunter = "Hunters - Bows/Guns broken!"
	L.warnwarrior = "Warriors - Stuck in berserking stance!"
	L.warnrogue = "Rogues - Ported and rooted!"
	L.warnpaladin = "Paladins - Blessing of Protection!"
	L.warnmage = "Mages - Incoming polymorphs!"
	L.warndeathknight = "Death Knights - Death Grip"
	L.warnmonk = "Monks - Stuck Rolling"
	L.warndemonhunter = "Demon Hunters - Blinded"

	L["22686_icon"] = "spell_shadow_psychicscream"

	L.classcall = "Class Call"
	L.classcall_desc = "Warn for Class Calls."

	L.add = "Drakonid deaths"
	L.add_desc = "Announce the number of adds killed in stage 1 before Nefarian lands."
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		{22667, "ICON"}, -- Shadow Command
		{22539, "CASTBAR"}, -- Shadow Flame
		{22686, "CASTBAR"}, -- Bellowing Roar
		22687, -- Veil of Shadow
		"classcall",
		"add"
	},nil,{
		[22667] = CL.mind_control, -- Shadow Command (Mind Control)
		[22686] = CL.fear, -- Bellowing Roar (Fear)
		[22687] = CL.curse, -- Veil of Shadow (Curse)
	}
end

function mod:VerifyEnable(unit, mobId)
	if mobId == 10162 then -- Lord Victor Nefarius, prevent enabling at Vael
		return self:UnitIsInteractable(unit)
	else -- Nefarian, adds
		return true
	end
end

function mod:OnRegister()
	classCallYellTable = {
		[L.shaman_class_call_yell_trigger] = L.warnshaman,
		[L.deathknight_class_call_yell_trigger] = L.warndeathknight,
		[L.monk_class_call_yell_trigger] = L.warnmonk,
		[L.hunter_class_call_yell_trigger] = L.warnhunter, -- Backup for Hunter spell not working
	}
	classCallSpellTable = {
		[23414] = L.warnrogue,
		[23398] = L.warndruid,
		[350567] = L.warndruid,
		[23397] = L.warnwarrior,
		[23401] = L.warnpriest,
		[23410] = L.warnmage,
		[23418] = L.warnpaladin,
		[23427] = L.warnwarlock,
		[204813] = L.warndemonhunter,
		[23436] = L.warnhunter, -- Hunter sometimes doesn't work
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "ShadowCommandApplied", 22667)
	self:Log("SPELL_AURA_REMOVED", "ShadowCommandRemoved", 22667)
	self:Log("SPELL_CAST_START", "BellowingRoar", 22686)
	self:Log("SPELL_CAST_START", "ShadowFlame", 22539)
	self:Log("SPELL_AURA_APPLIED", "VeilOfShadow", 22687)
	self:Log("SPELL_DISPEL", "VeilOfShadowDispelled", "*")

	-- Rogue, Druid, Warrior, Priest, Mage, Paladin, Warlock
	self:Log("SPELL_AURA_APPLIED", "ClassCall", 23414, 23398, 23397, 23401, 23410, 23418, 23427)
	if self:Retail() then
		-- Druid (Retail WoW), Demon Hunter
		self:Log("SPELL_AURA_APPLIED", "ClassCall", 350567, 204813)
	end
	self:Log("SPELL_DURABILITY_DAMAGE", "ClassCall", 23436) -- Hunter, sometimes doesn't work, keeping yell for backup

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:Death("AddDied", 14261, 14262, 14263, 14264, 14265, 14302) -- Blue, Green, Bronze, Red, Black, Chromatic
end

function mod:OnEngage()
	adds_dead = 0
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local prevMindControl = nil
	function mod:ShadowCommandApplied(args) -- Mind control
		prevMindControl = args.destGUID
		self:TargetMessage(args.spellId, "yellow", args.destName, CL.mind_control)
		self:TargetBar(args.spellId, 15, args.destName, CL.mind_control_short)
		self:PrimaryIcon(args.spellId, args.destName)
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
	function mod:ShadowCommandRemoved(args)
		self:StopBar(CL.mind_control_short, args.destName)
		if args.destGUID == prevMindControl then
			prevMindControl = nil
			self:PrimaryIcon(args.spellId)
		end
	end
end

function mod:BellowingRoar(args)
	self:CDBar(args.spellId, 32, CL.fear, L["22686_icon"])
	self:Message(args.spellId, "red", CL.incoming:format(CL.fear), L["22686_icon"])
	self:CastBar(args.spellId, 1.5, CL.fear, L["22686_icon"])
	self:PlaySound(args.spellId, "alert")
end

function mod:ShadowFlame(args)
	if self:MobId(args.sourceGUID) == 11583 then -- Shared with Ebonroc/Firemaw/Flamegor
		self:Message(args.spellId, "yellow")
		self:CastBar(args.spellId, 2)
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:VeilOfShadow(args)
	self:TargetMessage(args.spellId, "yellow", args.destName, CL.curse)
	if self:Dispeller("curse") then
		self:PlaySound(args.spellId, "warning")
	end
end

function mod:VeilOfShadowDispelled(args)
	if args.extraSpellName == self:SpellName(22687) then
		self:Message(22687, "green", CL.removed_by:format(CL.curse, self:ColorName(args.sourceName)))
	end
end

do
	local prev = 0
	function mod:ClassCall(args)
		if args.time-prev > 2 then
			prev = args.time
			self:CDBar("classcall", 30, L.classcall, "Spell_Shadow_Charm")
			self:Message("classcall", "orange", classCallSpellTable[args.spellId], "Spell_Shadow_Charm")
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.engage_yell_trigger, nil, true) then
		self:Engage()
	elseif msg:find(L.stage3_yell_trigger, nil, true) then
		self:SetStage(3)
		self:Message("stages", "cyan", CL.percent:format(20, CL.stage:format(3)), false)
		self:PlaySound("stages", "long")
	else
		for yellTrigger, bwMessage in next, classCallYellTable do
			if msg:find(yellTrigger, nil, true) then
				self:CDBar("classcall", 30, L.classcall, "Spell_Shadow_Charm")
				self:Message("classcall", "orange", bwMessage, "Spell_Shadow_Charm")
				return
			end
		end
	end
end

do
	local function Stage2(self)
		self:SetStage(2)
		self:Message("stages", "cyan", CL.stage:format(2), false)
		self:PlaySound("stages", "info")
	end
	function mod:AddDied()
		adds_dead = adds_dead + 1
		self:Message("add", "green", CL.add_killed:format(adds_dead, 41), "INV_Misc_Head_Dragon_Black")
		if adds_dead == 41 then
			self:Message("stages", "cyan", CL.custom_sec:format(CL.stage:format(2), 12), false)
			self:Bar("stages", 12, CL.stage:format(2), "INV_Misc_Head_Dragon_Black")
			self:ScheduleTimer(Stage2, 12, self)
			self:PlaySound("stages", "long")
		end
	end
end
