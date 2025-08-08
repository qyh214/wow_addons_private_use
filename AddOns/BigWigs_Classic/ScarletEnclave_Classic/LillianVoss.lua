--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Lillian Voss", 2856)
if not mod then return end
mod:RegisterEnableMob(243021)
mod:SetEncounterID(3190)
mod:SetRespawnTime(15)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Locals
--

local markerCount = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Lillian Voss"
end

--------------------------------------------------------------------------------
-- Initialization
--

local unstableConcoctionMarker = mod:AddMarkerOption(false, "player", 1, 1233849, 1, 2, 3, 4) -- Unstable Concoction
function mod:GetOptions()
	return {
		1233847, -- Scarlet Grasp
		1232192, -- Debilitate
		{1233901, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Noxious Poison
		{1233849, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Unstable Concoction
		unstableConcoctionMarker,
		{1233883, "EMPHASIZE"}, -- Intoxicating Venom
		{1234540, "EMPHASIZE"}, -- Ignite
		"berserk",
	},nil,{
		[1233847] = CL.pull_in, -- Scarlet Grasp (Pull In)
		[1232192] = CL.tank_debuff, -- Debilitate (Tank Debuff)
		[1233901] = CL.poison, -- Noxious Poison (Poison)
		[1233849] = CL.bomb, -- Unstable Concoction (Bomb)
		[1233883] = CL.keep_moving, -- Intoxicating Venom (Keep moving)
		[1234540] = CL.spread, -- Ignite (Spread)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
	self:SetSpellRename(1233847, CL.pull_in) -- Scarlet Grasp (Pull In)
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "ScarletGrasp", 1233847)
	self:Log("SPELL_AURA_REMOVED", "DebilitatingStrikeRemoved", 1232190)
	self:Log("SPELL_AURA_APPLIED", "NoxiousPoisonApplied", 1233901)
	self:Log("SPELL_AURA_REMOVED", "NoxiousPoisonRemoved", 1233901)
	self:Log("SPELL_CAST_SUCCESS", "UnstableConcoction", 1233849)
	self:Log("SPELL_AURA_APPLIED", "UnstableConcoctionApplied", 1233849)
	self:Log("SPELL_AURA_REMOVED", "UnstableConcoctionRemoved", 1233849)
	self:Log("SPELL_AURA_APPLIED", "IntoxicatingVenomApplied", 1233883)
	self:Log("SPELL_CAST_SUCCESS", "Ignite", 1234540)
end

function mod:OnEngage()
	markerCount = 0
	self:CDBar(1233847, 34, CL.pull_in) -- Scarlet Grasp
	self:Berserk(600)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:ScarletGrasp(args)
	self:CDBar(args.spellId, 30, CL.pull_in)
	self:Message(args.spellId, "red", CL.extra:format(args.spellName, CL.pull_in))
	self:PlaySound(args.spellId, "long")
end

function mod:DebilitatingStrikeRemoved(args)
	-- Debilitating Strike (1232190) applies to the current target >> Debilitate (1232192) instantly applies
	-- 0.6 seconds elapses
	-- Debilitating Strike expires from the player >> 2nd stack of Debilitate instantly applies
	-- Generally you should only taunt after the 2nd stack applies, but we use this REMOVED event as we can't guarantee the same person will get 2 stacks
	-- This is because some guilds have a DPS or other tank take a stack, so warning after 2 stacks wouldn't work
	-- We could show 2 messages (1 for 1st stack, and another for 2nd stack) but if 99% of guilds have the tank take both stacks, then 2 messages would be spam
	self:TargetMessage(1232192, "purple", args.destName, CL.tank_debuff)
end

function mod:NoxiousPoisonApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, nil, CL.poison)
		self:Say(args.spellId, CL.poison, nil, "Poison")
		self:SayCountdown(args.spellId, 8)
		self:PlaySound(args.spellId, "alarm", nil, args.destName)
	end
end

function mod:NoxiousPoisonRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
end

function mod:UnstableConcoction()
	markerCount = 0
end

function mod:UnstableConcoctionApplied(args)
	markerCount = markerCount + 1
	self:CustomIcon(unstableConcoctionMarker, args.destName, markerCount)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, false, CL.you_icon:format(CL.bomb, markerCount))
		self:Say(args.spellId, CL.rticon:format(CL.bomb, markerCount), nil, ("Bomb ({rt%d})"):format(markerCount))
		self:SayCountdown(args.spellId, 7, markerCount)
		self:PlaySound(args.spellId, "alert", nil, args.destName)
	end
end

function mod:UnstableConcoctionRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
	self:CustomIcon(unstableConcoctionMarker, args.destName)
end

do
	local prev = 0
	local function KeepMoving()
		if mod:IsEngaged() then
			mod:Message(1233883, "blue", CL.keep_moving)
			mod:PlaySound(1233883, "warning")
		end
	end
	local function StopMoving()
		if mod:IsEngaged() then
			mod:Message(1233883, "green", CL.safe_to_stop, nil, true) -- Disable emphasize
		end
	end
	function mod:IntoxicatingVenomApplied(args)
		if args.time - prev > 17 then
			prev = args.time
			KeepMoving()
			self:SimpleTimer(KeepMoving, 8) -- Midway reminder
			self:SimpleTimer(StopMoving, 15) -- Safe
		end
	end
end

function mod:Ignite(args)
	self:Message(args.spellId, "yellow", CL.spread)
	self:PlaySound(args.spellId, "info")
end
