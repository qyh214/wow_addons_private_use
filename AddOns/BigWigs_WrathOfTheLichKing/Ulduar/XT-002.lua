--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("XT-002 Deconstructor", 603, 1640)
if not mod then return end
mod:RegisterEnableMob(33293)
mod:SetEncounterID(BigWigsLoader.isWrath and 747 or 1142)
-- mod:SetRespawnTime(0) -- resets, doesn't respawn

--------------------------------------------------------------------------------
-- Locals
--

local exposed1 = false
local exposed2 = false
local exposed3 = false

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.lightbomb_other = "Light"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{64234, "ICON", "SAY", "SAY_COUNTDOWN", "PROXIMITY", "ME_ONLY_EMPHASIZE"}, -- Gravity Bomb
		{65121, "ICON", "SAY", "PROXIMITY", "ME_ONLY_EMPHASIZE"}, -- Searing Light
		62776, -- Tympanic Tantrum
		64193, -- Heartbreak
		63849, -- Exposed Heart
		"berserk",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "ExposedHeart", 63849)
	self:Log("SPELL_AURA_APPLIED", "Heartbreak", 64193, 65737) -- ??, 10m
	self:Log("SPELL_AURA_APPLIED", "GravityBomb", 64234, 63024) -- 25m, 10m
	self:Log("SPELL_AURA_REMOVED", "GravityBombRemoved", 64234, 63024) -- 25m, 10m
	self:Log("SPELL_AURA_APPLIED", "SearingLight", 65121, 63018) --25m, 10m
	self:Log("SPELL_AURA_REMOVED", "SearingLightRemoved", 65121, 63018) --25m, 10m
	self:Log("SPELL_CAST_START", "TympanicTantrum", 62776)

	self:RegisterEvent("UNIT_HEALTH")
end

function mod:OnEngage()
	exposed1 = false
	exposed2 = false
	exposed3 = false
	self:Berserk(self:Classic() and 360 or 600)
	self:CDBar(62776, 32) -- Tympanic Tantrum
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:ExposedHeart(args)
	self:MessageOld(args.spellId, "yellow", "long")
	self:Bar(args.spellId, 30)
end

function mod:Heartbreak()
	self:MessageOld(64193, "orange", "info")
end

function mod:TympanicTantrum(args)
	self:MessageOld(args.spellId, "yellow", "warning")
	self:CDBar(args.spellId, 62)
end

function mod:GravityBomb(args)
	if self:Me(args.destGUID) then
		self:OpenProximity(64234, 10)
		self:Say(64234, nil, nil, "Gravity Bomb")
		self:SayCountdown(64234, 9)
	end
	self:TargetMessageOld(64234, args.destName, "red", "alert")
	self:TargetBar(64234, 9, args.destName, CL.bomb)
	self:SecondaryIcon(64234, args.destName)
end

function mod:GravityBombRemoved(args)
	if self:Me(args.destGUID) then
		self:CloseProximity(64234)
		self:CancelSayCountdown(64234)
	end
	self:StopBar(CL.bomb, args.destName)
	self:SecondaryIcon(64234)
end

function mod:SearingLight(args)
	if self:Me(args.destGUID) then
		self:OpenProximity(65121, 10)
		self:Say(65121, nil, nil, "Searing Light")
	end
	self:TargetMessageOld(65121, args.destName, "red", "alert")
	self:TargetBar(65121, 9, args.destName, L.lightbomb_other)
	self:PrimaryIcon(65121, args.destName)
end

function mod:SearingLightRemoved(args)
	if self:Me(args.destGUID) then
		self:CloseProximity(65121)
	end
	self:StopBar(L.lightbomb_other, args.destName)
	self:PrimaryIcon(65121)
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) ~= 33293 then return end
	local hp = self:GetHealth(unit)
	if not exposed1 and hp > 86 and hp < 90 then
		exposed1 = true
		self:MessageOld(63849, "yellow", nil, CL.soon:format(self:SpellName(63849))) -- Exposed Heart soon
	elseif not exposed2 and hp > 56 and hp < 58 then
		exposed2 = true
		self:MessageOld(63849, "yellow", nil, CL.soon:format(self:SpellName(63849)))
	elseif not exposed3 and hp > 26 and hp < 28 then
		exposed3 = true
		self:UnregisterEvent(event, unit)
		self:MessageOld(63849, "yellow", nil, CL.soon:format(self:SpellName(63849)))
	end
end
