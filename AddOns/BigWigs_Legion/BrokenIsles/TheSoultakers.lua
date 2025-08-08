
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("The Soultakers", -634, 1756)
if not mod then return end
mod:RegisterEnableMob(106981) -- Captain Hring
mod.otherMenu = -619
mod.worldBoss = 106981

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{213625, "SAY"}, -- Expel Soul
		213606, -- Soul Rend
		213665, -- Marauding Mists
		{213588, "SAY"}, -- Seadog's Scuttle
		213420, -- Tentacle Bash
		213532, -- Shatter Crewmen
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "ExpelSoul", 213625)
	self:Log("SPELL_CAST_START", "SoulRend", 213606)
	self:Log("SPELL_CAST_START", "MaraudingMists", 213665)
	self:Log("SPELL_CAST_START", "SeadogsScuttle", 213588)
	self:Log("SPELL_CAST_START", "TentacleBash", 213420)
	self:Log("SPELL_CAST_SUCCESS", "CursedCrew", 213522)

	self:ScheduleTimer("CheckForEngage", 1)
	self:RegisterEvent("BOSS_KILL")
end

function mod:OnEngage()
	self:CheckForWipe()
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:ExpelSoul(args)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, nil, nil, "Expel Soul")
		self:TargetMessageOld(args.spellId, args.destName, "blue", "alarm")
	end
end

function mod:SoulRend(args)
	self:MessageOld(args.spellId, "yellow", "warning", CL.incoming:format(args.spellName))
end

function mod:MaraudingMists(args)
	if self:Melee() then
		self:CDBar(args.spellId, 11)
		if self:MobId(self:UnitGUID("target")) == 106982 then -- Reaver Jdorn
			self:MessageOld(args.spellId, "orange", "info", CL.casting:format(args.spellName))
		end
	end
end

do
	local function printTarget(self, player, guid)
		if self:Me(guid) then
			self:Say(213588, nil, nil, "Seadog's Scuttle")
		end
		self:TargetMessageOld(213588, player, "red", "alert", nil, nil, true)
	end

	function mod:SeadogsScuttle(args)
		self:GetUnitTarget(printTarget, 0.3, args.sourceGUID)
	end
end

function mod:TentacleBash(args)
	self:MessageOld(args.spellId, "green", "long", CL.casting:format(args.spellName))
end

function mod:CursedCrew()
	self:MessageOld(213532, "red", "warning", CL.custom_sec:format(self:SpellName(213532), 11))
	self:Bar(213532, 11)
end

function mod:BOSS_KILL(_, id)
	if id == 1879 then
		self:Win()
	end
end
