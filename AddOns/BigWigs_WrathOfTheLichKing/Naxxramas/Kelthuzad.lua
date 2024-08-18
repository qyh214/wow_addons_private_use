--------------------------------------------------------------------------------
-- Module declaration
--

local mod, CL = BigWigs:NewBoss("Kel'Thuzad Naxxramas", 533, 1615)
if not mod then return end
mod:RegisterEnableMob(15990)
-- mod:SetEncounterID(1114)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale()
if L then
	L.KELTHUZADCHAMBERLOCALIZEDLOLHAX = "Kel'Thuzad's Chamber"

	L.phase1_trigger = "Minions, servants, soldiers of the cold dark! Obey the call of Kel'Thuzad!"
	L.phase2_trigger1 = "Pray for mercy!"
	L.phase2_trigger2 = "Scream your dying breath!"
	L.phase2_trigger3 = "The end is upon you!"
	L.phase3_trigger = "Master, I require aid!"
	L.guardians_trigger = "Very well. Warriors of the frozen wastes, rise up! I command you to fight, kill and die for your master! Let none survive!"

	L.phase2_warning = "Phase 2 - Kel'Thuzad Incoming!"
	L.phase2_bar = "Kel'Thuzad active"

	L.phase3_warning = "Stage 3 - Guardians in ~15 sec!"

	L.detonate = mod:SpellName(20789)
	L.mind_control = mod:SpellName(605)

	L.guardians = "Guardian Spawns"
	L.guardians_desc = "Warn for incoming Icecrown Guardians in phase 3."
	L.guardians_icon = "inv_trinket_naxxramas04"
	L.guardians_warning = "Guardians incoming in ~10sec!"
	L.guardians_bar = "Guardians incoming!"

	L.engage_message = "Kel'Thuzad encounter started!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		27808, -- Frost Blast
		27810, -- Shadow Fissure
		28410, -- Chains of Kel'Thuzad
		{27819, "ICON", "FLASH"}, -- Detonate Mana
		"guardians",
		"stages",
		"proximity",
	}, nil, {
		[28410] = L.mind_control,
		[27819] = L.detonate,
	}
end

-- Big evul hack to enable the module when entering Kel'Thuzads chamber.
function mod:OnRegister()
	local f = CreateFrame("Frame")
	local func = function()
		if not mod:IsEnabled() and GetSubZoneText() == L.KELTHUZADCHAMBERLOCALIZEDLOLHAX then
			mod:Enable()
		end
	end
	f:SetScript("OnEvent", func)
	f:RegisterEvent("ZONE_CHANGED_INDOORS")
	func()
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "ShadowFissure", 27810)
	self:Log("SPELL_AURA_APPLIED", "FrostBlast", 27808)
	self:Log("SPELL_AURA_APPLIED", "DetonateMana", 27819)
	self:Log("SPELL_AURA_APPLIED", "ChainsOfKelThuzad", 28410)

	self:RegisterEvent("ENCOUNTER_START") -- Fires with P2, like to M'uru
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")

	self:BossYell("Engage", L.phase1_trigger)
	self:BossYell("Phase2", L.phase2_trigger1, L.phase2_trigger2, L.phase2_trigger3)
	self:BossYell("Phase3", L.phase3_trigger)
	self:BossYell("Guardians", L.guardians_trigger)
	self:Death("Win", 15990)
end

function mod:OnEngage()
	self:Message("stages", "yellow", CL.custom_start:format(self.displayName, CL.active, 3), false)
	self:Bar("stages", 210, CL.phase:format(2), "spell_shadow_raisedead")

	self:CloseProximity("proximity")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Phase2()
	self:StopBar(CL.phase:format(2))

	self:Message("stages", "cyan", L.phase2_warning, false)
	self:PlaySound("stages", "info")
	self:Bar("stages", 15, L.phase2_bar, "Spell_Shadow_Charm")
	self:CDBar(27810, 30) -- Shadow Fissure

	self:OpenProximity("proximity", 10)
end

function mod:ENCOUNTER_START()
	self:StopBar(L.phase2_bar)
	self:Message("stages", "cyan", self.displayName, false)
	self:PlaySound("stages", "long")

	self:OpenProximity("proximity", 10)

	self:RegisterEvent("UNIT_HEALTH")
end

function mod:ShadowFissure(args)
	self:Message(args.spellId, "red")
	self:CDBar(args.spellId, 16) -- 11~34
end

do
	local targets = {}
	local prev = 0
	function mod:FrostBlast(args)
		if args.time - prev > 3 then
			prev = args.time
			targets = {}
			self:CDBar(args.spellId, 37)
			self:DelayedMessage(args.spellId, 32, "yellow", CL.soon:format(args.spellName))
		end
		targets[#targets + 1] = args.destName
		self:TargetsMessage(args.spellId, "red", targets, 0, nil, nil, 0.4)
		if self:Me(args.destGUID) then
			self:PlaySound(args.spellId, "alert")
		end
	end
end

function mod:DetonateMana(args)
	self:TargetMessage(args.spellId, "yellow", args.destName)
	if self:Me(args.destGUID) then
		self:PlaySound(args.spellId, "alert")
		self:Flash(args.spellId)
	end
	self:PrimaryIcon(args.spellId, args.destName)
	self:TargetBar(args.spellId, 5, args.destName, L.detonate)
	self:CDBar(args.spellId, 20)
	self:DelayedMessage(args.spellId, 15, "yellow", CL.soon:format(args.spellName))
end

do
	local targets = {}
	local prev = 0
	function mod:ChainsOfKelThuzad(args)
		if args.time - prev > 3 then
			prev = args.time
			targets = {}
			self:Bar(28410, 20, CL.over:format(L.mind_control))
			self:CDBar(28410, 68, L.mind_control)
			self:DelayedMessage(28410, 63, "orange", CL.soon:format(L.mind_control))
		end
		targets[#targets + 1] = args.destName
		self:TargetsMessage(28410, "red", targets, 3, L.mind_control, nil, 0.5)
		if self:Me(args.destGUID) then
			self:PlaySound(28410, "alert")
		end
	end
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 15990 then
		local hp = self:GetHealth(unit)
		if hp < 46 then
			self:UnregisterEvent(event)
			self:Message("stages", "cyan", CL.soon:format(CL.stage:format(3)), false)
			self:PlaySound("stages", "info")
		end
	end
end

function mod:Phase3()
	self:Message("stages", "cyan", L.phase3_warning, false)
	self:PlaySound("stages", "info")
end

function mod:Guardians()
	self:Message("guardians", "red", L.guardians_warning, L.guardians_icon)
	self:Bar("guardians", 10, L.guardians_bar, L.guardians_icon)
end
