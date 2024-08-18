--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Sindragosa", 631, 1635)
if not mod then return end
mod:RegisterEnableMob(36853, 37533, 37534) -- Sindragosa, Rimefang, Spinestalker
-- mod:SetEncounterID(1105)
-- mod:SetRespawnTime(30)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local phase = 0
local beaconCount = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale()
if L then
	L.engage_trigger = "You are fools to have come to this place."

	L.phase2 = "Phase 2"
	L.phase2_desc = "Warn when Sindragosa goes into phase 2, at 35%."
	L.phase2_trigger = "Now, feel my master's limitless power and despair!"
	L.phase2_message = "Phase 2!"

	L.airphase = "Air phase"
	L.airphase_desc = "Warn when Sindragosa will lift off."
	L.airphase_trigger = "Your incursion ends here! None shall survive!"
	L.airphase_message = "Air phase!"
	L.airphase_bar = "Next air phase"

	L.boom_message = "Explosion!"
	L.boom_bar = "Explosion"

	L.instability_message = "Unstable x%d!"
	L.chilled_message = "Chilled x%d!"
	L.buffet_message = "Magic x%d!"
	L.buffet_cd = "Next Magic"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

local beaconMarker = mod:AddMarkerOption(false, "player", 1, 70126, 1, 2, 3, 4, 5, 6) -- Frost Beacon
function mod:GetOptions()
	return {
		-- Phase 1
		"airphase",
		-- Phase 2
		"phase2",
		70127, -- Mystic Buffet
		-- General
		{69762, "FLASH"}, -- Unchained Magic
		69766, -- Instability
		70106, -- Chilled to the Bone
		70123, -- Blistering Cold
		{70126, "FLASH"}, -- Frost Beacon
		beaconMarker,
		"proximity",
		"berserk",
	}, {
		["airphase"] = CL.phase:format(1),
		["phase2"] = CL.phase:format(2),
		[69762] = "general",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Unchained", 69762)
	self:Log("SPELL_AURA_REMOVED", "UnchainedRemoved", 69762)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Instability", 69766)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Chilled", 70106)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Buffet", 70127)

	self:Log("SPELL_AURA_APPLIED", "FrostBeacon", 70126)
	self:Log("SPELL_AURA_REMOVED", "FrostBeaconRemoved", 70126)
	self:Log("SPELL_AURA_APPLIED", "Tombed", 70157)

	-- 70123 is the actual blistering cold
	self:Log("SPELL_CAST_SUCCESS", "Grip", 70117)

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:BossYell("Warmup", L["engage_trigger"])
	self:BossYell("AirPhase", L["airphase_trigger"])
	self:BossYell("Phase2", L["phase2_trigger"])
	self:Death("Win", 36853)
end

function mod:Warmup()
	self:Bar("berserk", 10, self.displayName, "achievement_boss_sindragosa")
	self:ScheduleTimer("Engage", 10)
end

function mod:OnEngage(diff)
	self:SetStage(1)
	phase = 1
	beaconCount = 1
	self:Berserk(600)
	self:Bar("airphase", 63, L["airphase_bar"], 23684)
	self:Bar(69762, 15) -- Unchained Magic
	self:Bar(70123, 34, 70117) -- Icy Grip
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Tombed(args)
	if self:Me(args.destGUID) then
		self:CloseProximity()
	end
end

do
	local beaconTargets, scheduled = mod:NewTargetList(), nil
	local function baconWarn()
		mod:TargetMessageOld(70126, beaconTargets, "orange")
		mod:Bar(70126, 7)
		scheduled = nil
	end
	function mod:FrostBeacon(args)
		beaconTargets[#beaconTargets + 1] = args.destName
		if self:Me(args.destGUID) then
			self:OpenProximity("proximity", 10)
			self:Flash(70126)
		end
		if not scheduled then
			scheduled = self:ScheduleTimer(baconWarn, 0.2)
		end

		self:CustomIcon(beaconMarker, args.destName, beaconCount)
		beaconCount = beaconCount + 1
		if beaconCount > 6 then -- reset fail safe
			beaconCount = 1
		end
	end
end

function mod:FrostBeaconRemoved(args)
	self:CustomIcon(beaconMarker, args.destName)
end

function mod:Grip()
	self:MessageOld(70123, "red", "alarm", L["boom_message"])
	self:Bar(70123, 5, L["boom_bar"])
	if phase == 2 then
		self:Bar(70123, 67, 70117) -- Icy Grip
	end
end

function mod:AirPhase()
	self:SetStage(1.5)
	beaconCount = 1
	self:MessageOld("airphase", "green", nil, L["airphase_message"], 23684)
	self:Bar("airphase", 110, L["airphase_bar"], 23684)
	self:Bar(70123, 80, 70117) -- Icy Grip
	self:Bar(69762, 57) -- Unchained Magic
	self:ScheduleTimer("GroundPhase", 20)
end

function mod:GroundPhase()
	if self:GetStage() ~= 2 then
		self:SetStage(1)
	end
end

function mod:Phase2()
	self:SetStage(2)
	phase = 2
	self:StopBar(L["airphase_bar"])
	self:MessageOld("phase2", "green", "long", L["phase2_message"], false)
	self:Bar(70123, 38, 70117) -- Icy Grip
end

function mod:Buffet(args)
	self:Bar(70127, 6, L["buffet_cd"])
	if (args.amount % 2 == 0) and self:Me(args.destGUID) then
		self:MessageOld(70127, "yellow", "info", L["buffet_message"]:format(args.amount))
	end
end

function mod:Instability(args)
	if args.amount > 4 and self:Me(args.destGUID) then
		self:MessageOld(69766, "blue", nil, L["instability_message"]:format(args.amount))
	end
end

function mod:Chilled(args)
	if args.amount > 4 and self:Me(args.destGUID) then
		self:MessageOld(70106, "blue", nil, L["chilled_message"]:format(args.amount))
	end
end

function mod:Unchained(args)
	if phase == 1 then
		self:Bar(69762, 30)
	elseif phase == 2 then
		self:Bar(69762, 80)
	end
	if self:Me(args.destGUID) then
		self:MessageOld(69762, "blue", "alert", CL["you"]:format(args.spellName))
		self:Flash(69762)
		if self:Heroic() then
			self:OpenProximity("proximity", 20)
			self:ScheduleTimer("CloseProximity", 30)
		end
	end
end

function mod:UnchainedRemoved(args)
	self:CloseProximity()
end

