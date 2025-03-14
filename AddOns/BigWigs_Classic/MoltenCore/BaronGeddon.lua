--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Baron Geddon", 409, 1524)
if not mod then return end
mod:RegisterEnableMob(12056, 228433) -- Baron Geddon, Baron Geddon (Season of Discovery)
mod:SetEncounterID(668)

--------------------------------------------------------------------------------
-- Locals
--

local debuffCount = 0
local debuffTime = 0

--------------------------------------------------------------------------------
-- Initialization
--

local livingBombMarker = mod:GetSeason() == 2 and mod:AddMarkerOption(true, "player", 8, 20475, 8, 7, 6) or mod:AddMarkerOption(true, "player", 8, 20475, 8) -- Living Bomb
function mod:GetOptions()
	return {
		{20475, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Living Bomb
		livingBombMarker,
		{19695, "CASTBAR"}, -- Inferno
		{20478, "CASTBAR", "EMPHASIZE", "CASTBAR_COUNTDOWN"}, -- Armageddon
		19659, -- Ignite Mana
	},nil,{
		[20475] = CL.bomb, -- Living Bomb (Bomb)
		[20478] = CL.explosion, -- Armageddon (Explosion)
	}
end

if mod:GetSeason() == 2 then
	function mod:GetOptions()
		return {
			{20475, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Living Bomb
			livingBombMarker,
			{19695, "CASTBAR"}, -- Inferno
			{20478, "CASTBAR", "EMPHASIZE", "CASTBAR_COUNTDOWN"}, -- Armageddon
			19659, -- Ignite Mana
			461103, -- Living Fallout
		},nil,{
			[20475] = CL.bomb, -- Living Bomb (Bomb)
			[20478] = CL.explosion, -- Armageddon (Explosion)
			[461103] = CL.underyou:format(CL.fire), -- Living Fallout (Fire under YOU)
		}
	end
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "LivingBombApplied", 20475)
	self:Log("SPELL_AURA_REMOVED", "LivingBombRemoved", 20475)
	self:Log("SPELL_CAST_SUCCESS", "Inferno", 19695)
	self:Log("SPELL_CAST_SUCCESS", "Armageddon", 20478)
	self:Log("SPELL_CAST_SUCCESS", "IgniteMana", 19659)
	self:Log("SPELL_AURA_APPLIED", "IgniteManaApplied", 19659)
	self:Log("SPELL_AURA_REMOVED", "IgniteManaRemoved", 19659)
	if self:GetSeason() == 2 then
		self:Log("SPELL_CAST_SUCCESS", "LivingBomb", 465725, 461090, 461105) -- Level 1, Level 2, Level 3
		self:Log("SPELL_AURA_APPLIED", "LivingBombAppliedSoD", 465725, 461090, 461105) -- Level 1, Level 2, Level 3
		self:Log("SPELL_AURA_REMOVED", "LivingBombRemoved", 465725, 461090, 461105) -- Level 1, Level 2, Level 3
		self:Log("SPELL_CAST_SUCCESS", "Inferno", 461087, 461110) -- Level 1, Level 2 & 3
		self:Log("SPELL_CAST_SUCCESS", "ArmageddonSoD", 461121)
		self:Log("SPELL_AURA_APPLIED", "LivingFalloutDamage", 461103, 461111) -- Living Fallout, Inferno (Leaves a fire patch at level 2 & 3, just re-using the same living fallout option)
		self:Log("SPELL_PERIODIC_DAMAGE", "LivingFalloutDamage", 461103, 461111)
		self:Log("SPELL_PERIODIC_MISSED", "LivingFalloutDamage", 461103, 461111)
	end
end

function mod:OnEngage()
	debuffCount = 0
	debuffTime = 0
	self:CDBar(19659, 6) -- Ignite Mana
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local playerList = {}
	local icon = 8
	function mod:LivingBomb()
		playerList = {}
		icon = 8
		self:PlaySound(20475, "warning")
	end

	function mod:LivingBombAppliedSoD(args)
		playerList[#playerList+1] = args.destName
		self:TargetsMessage(20475, "orange", playerList, args.spellId == 461105 and 3 or 2, CL.bomb)
		self:CustomIcon(livingBombMarker, args.destName, icon)
		if self:Me(args.destGUID) then
			self:Say(20475, CL.bomb, nil, "Bomb")
			self:SayCountdown(20475, 8, icon)
			self:TargetBar(20475, 8, args.destName, CL.bomb)
		end
		icon = icon - 1
	end
end

function mod:LivingBombApplied(args)
	if self:Me(args.destGUID) then
		self:Say(20475, CL.bomb, nil, "Bomb")
		self:SayCountdown(20475, 8, 8)
	end
	self:TargetMessage(20475, "red", args.destName, CL.bomb)
	self:TargetBar(20475, 8, args.destName, CL.bomb)
	self:CustomIcon(livingBombMarker, args.destName, 8)
	self:PlaySound(20475, "warning")
end

function mod:LivingBombRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(20475)
	end
	self:StopBar(CL.bomb, args.destName)
	self:CustomIcon(livingBombMarker, args.destName)
end

function mod:Inferno()
	self:Message(19695, "red")
	self:CastBar(19695, 8)
	self:CDBar(19695, 21) -- 21-29
	self:PlaySound(19695, "alarm")
end

function mod:Armageddon(args)
	self:StopBar(19659) -- Ignite Mana
	self:StopBar(19695) -- Inferno
	self:CastBar(args.spellId, 8, CL.explosion)
	self:Message(args.spellId, "orange")
	self:PlaySound(args.spellId, "long")
end

function mod:ArmageddonSoD(args)
	self:StopBar(19659) -- Ignite Mana
	self:StopBar(19695) -- Inferno
	self:CastBar(20478, 15, CL.explosion)
	if self:GetPlayerAura(458841) then -- Level 1
		self:Message(20478, "orange", CL.percent:format(5, args.spellName))
	else -- Level 2 & 3
		self:Message(20478, "orange", CL.percent:format(10, args.spellName))
	end
	self:PlaySound(20478, "long")
end

function mod:IgniteMana(args)
	debuffTime = args.time
	self:CDBar(args.spellId, 27)
	self:Message(args.spellId, "yellow", CL.on_group:format(args.spellName))
	self:PlaySound(args.spellId, "info")
end

function mod:IgniteManaApplied(args)
	if self:Player(args.destFlags) and UnitPowerType(args.destName) == 0 then -- Players that are using mana, not pets
		debuffCount = debuffCount + 1
	end
end

function mod:IgniteManaRemoved(args)
	if self:Player(args.destFlags) and UnitPowerType(args.destName) == 0 then -- Players that are using mana, not pets
		debuffCount = debuffCount - 1
		if debuffCount == 0 then
			self:Message(args.spellId, "green", CL.removed_after:format(args.spellName, args.time-debuffTime))
		end
	end
end

do
	local prev = 0
	function mod:LivingFalloutDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:PersonalMessage(461103, "underyou", CL.fire)
			self:PlaySound(461103, "underyou")
		end
	end
end
