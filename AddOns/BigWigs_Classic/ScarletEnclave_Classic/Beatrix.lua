--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("High Commander Beatrix", 2856)
if not mod then return end
mod:RegisterEnableMob(240812)
mod:SetEncounterID(3187)
mod:SetAllowWin(true)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "High Commander Beatrix"

	L.meteor = CL.meteor
	L.meteor_desc = 28884
	L.meteor_icon = "spell_fire_meteorstorm"
	L.meteor_yell_trigger = "As you wish" -- As you wish, High Commander!

	L.waves = CL.waves
	L.waves_icon = "spell_holy_prayerofhealing"
	L.waves_footmen_yell_trigger = "Form up" -- Form up and hold the line!
	L.waves_cavalry_yell_trigger = "Ready your lances" -- Understood! Ready your lances!

	L.arrows = 1231642 -- Scarlet Arrows
	L.arrows_icon = "ability_searingarrow"
	L.arrows_yell_trigger = "Archers," -- Archers, unleash hell!

	L.bombing = 1980 -- Bombard
	L.bombing_icon = "ability_golemstormbolt"
	L.bombing_yell_trigger = "At once," -- At once, Beatrix!
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{"meteor", "EMPHASIZE", "COUNTDOWN"},
		"waves",
		"arrows",
		"bombing",
		1237324, -- Explosive Shell
		1232390, -- Rose's Thorn
		{1231873, "EMPHASIZE"}, -- Confession
		1232389, -- Unwavering Blade
		{1232637, "CASTBAR"}, -- Stock Break
		"stages",
		"berserk",
	},nil,{
		[1237324] = CL.underyou:format(CL.fire), -- Explosive Shell (Fire under YOU)
		[1231873] = CL.spread, -- Confession (Spread)
		[1232389] = CL.tank_debuff, -- Unwavering Blade (Tank Debuff)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:RegisterMessage("BigWigs_UNIT_TARGET")
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterMessage("BigWigs_BossComm")
	self:Log("SPELL_CAST_SUCCESS", "RosesThorn", 1232390)
	self:Log("SPELL_AURA_APPLIED", "RosesThornApplied", 1232390)
	self:Log("SPELL_AURA_APPLIED", "ConfessionApplied", 1231873)
	self:Log("SPELL_CAST_SUCCESS", "UnwaveringBlade", 1232389)
	self:Log("SPELL_AURA_APPLIED", "UnwaveringBladeApplied", 1232389)
	self:Log("SPELL_AURA_REFRESH", "UnwaveringBladeApplied", 1232389)
	self:Log("SPELL_CAST_START", "StockBreak", 1232637)
	self:Log("SPELL_AURA_APPLIED", "StockBreakApplied", 1232637)
	self:Log("SPELL_DAMAGE", "ExplosiveShellDamage", 1237324)
	self:Log("SPELL_MISSED", "ExplosiveShellDamage", 1237324)
end

function mod:OnEngage()
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:Bar("stages", 120, CL.stage:format(2), "ability_mount_charger")
	self:Berserk(600, true) -- No engage message
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:BigWigs_UNIT_TARGET(event, mobId, unitTarget)
	if mobId == 240812 and UnitCanAttack(unitTarget, "player") then -- High Commander Beatrix
		self:SetStage(2)
		local msg = CL.stage:format(2)
		self:StopBar(msg)
		self:UnregisterMessage(event)
		self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
		self:CDBar(1232389, 16, CL.tank_debuff) -- Unwavering Blade
		self:Bar(1232637, 45) -- Stock Break, Bar instead of CBBar because sometimes it isn't used
		self:Message("stages", "cyan", msg, false)
		self:PlaySound("stages", "long")
	end
end

function mod:NAME_PLATE_UNIT_ADDED(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 240812 then -- High Commander Beatrix
		self:SetStage(2)
		local msg = CL.stage:format(2)
		self:StopBar(msg)
		self:UnregisterMessage("BigWigs_UNIT_TARGET")
		self:UnregisterEvent(event)
		self:CDBar(1232389, 16, CL.tank_debuff) -- Unwavering Blade
		self:Bar(1232637, 45) -- Stock Break, Bar instead of CBBar because sometimes it isn't used
		self:Message("stages", "cyan", msg, false)
		self:PlaySound("stages", "long")
	end
end

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.meteor_yell_trigger, nil, true) then
		self:Sync("meteor")
	elseif msg:find(L.waves_footmen_yell_trigger, nil, true) then
		self:Sync("foot")
	elseif msg:find(L.waves_cavalry_yell_trigger, nil, true) then
		self:Sync("horse")
	elseif msg:find(L.arrows_yell_trigger, nil, true) then
		self:Sync("arrow")
	elseif msg:find(L.bombing_yell_trigger, nil, true) then
		self:Sync("bombing")
	end
end

do
	local function Footmen()
		mod:Message("waves", "yellow", CL.incoming:format(L.waves), L.waves_icon)
		mod:Bar("waves", 30, L.waves, L.waves_icon)
		mod:PlaySound("waves", "info")
	end
	local function Cavalry()
		mod:Message("waves", "yellow", CL.incoming:format(L.waves), L.waves_icon)
		mod:Bar("waves", 16, L.waves, L.waves_icon)
		mod:PlaySound("waves", "info")
	end
	local function Bombing()
		mod:Message("bombing", "yellow", L.bombing, L.bombing_icon)
		mod:Bar("bombing", 16, L.bombing, L.bombing_icon)
		mod:PlaySound("bombing", "info")
	end

	local times = {
		["meteor"] = 0,
		["foot"] = 0,
		["horse"] = 0,
		["arrow"] = 0,
		["bombing"] = 0,
	}
	function mod:BigWigs_BossComm(_, msg)
		if times[msg] and self:IsEngaged() then
			local t = GetTime()
			if t-times[msg] > 5 then
				times[msg] = t
				if msg == "meteor" then
					self:Message("meteor", "orange", L.meteor, L.meteor_icon)
					self:Bar("meteor", 16, L.meteor, L.meteor_icon)
					self:PlaySound("meteor", "alert")
				elseif msg == "foot" then
					self:ScheduleTimer(Footmen, 3)
				elseif msg == "horse" then
					self:ScheduleTimer(Cavalry, 3)
				elseif msg == "arrow" then
					self:Message("arrows", "yellow", L.arrows, L.arrows_icon)
					self:Bar("arrows", 13, L.arrows, L.arrows_icon)
					self:PlaySound("arrows", "info")
				elseif msg == "bombing" then
					self:ScheduleTimer(Bombing, 2)
				end
			end
		end
	end
end

do
	local playerList = {}
	function mod:RosesThorn()
		playerList = {}
	end

	local function PrintThorns()
		if #playerList > 3 then
			mod:Message(1232390, "red", CL.on_group:format(mod:SpellName(1232390)))
		else
			mod:TargetsMessage(1232390, "red", playerList, nil, nil, nil, 0) -- Force the delay to 0s as we've already had a 0.3s delay
		end
	end

	function mod:RosesThornApplied(args)
		local count = #playerList + 1
		playerList[count] = args.destName
		if count == 1 then
			self:ScheduleTimer(PrintThorns, 0.3)
		end
	end
end

do
	local prev = 0
	local function PrintSafe()
		if mod:IsEngaged() then
			mod:Message(1231873, "blue", CL.safe)
		end
	end
	function mod:ConfessionApplied(args)
		if args.time - prev > 17 then
			prev = args.time
			self:SimpleTimer(PrintSafe, 10) -- Safe
			self:Message(args.spellId, "blue", CL.spread)
			self:PlaySound(args.spellId, "warning")
		end
	end
end

function mod:UnwaveringBlade(args)
	self:CDBar(args.spellId, 16.1, CL.tank_debuff)
end

function mod:UnwaveringBladeApplied(args)
	self:TargetMessage(args.spellId, "purple", args.destName, CL.tank_debuff)
	self:PlaySound(args.spellId, "alarm", nil, args.destName)
end

do
	local playerList = {}
	function mod:StockBreak(args)
		playerList = {}
		self:Message(args.spellId, "red", CL.incoming:format(args.spellName))
		self:CDBar(args.spellId, 44.5)
		self:CastBar(args.spellId, 3)
		self:PlaySound(args.spellId, "warning")
	end

	function mod:StockBreakApplied(args)
		playerList[#playerList + 1] = args.destName
		self:TargetsMessage(args.spellId, "red", playerList, 3)
	end
end

do
	local prev = 0
	function mod:ExplosiveShellDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 3 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou", CL.fire)
			self:PlaySound(args.spellId, "underyou")
		end
	end
end
