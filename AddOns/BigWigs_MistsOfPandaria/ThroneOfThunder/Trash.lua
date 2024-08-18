
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Throne of Thunder Trash", 1098)
if not mod then return end
mod.displayName = CL.trash
mod:RegisterEnableMob(
	70236, -- Zandalari Storm-Caller
	70445, -- Stormbringer Draz'kil
	70440, -- Monara
	70430, -- Rocky Horror
	69821 -- Thunder Lord
)

--------------------------------------------------------------------------------
-- Locals
--

local debuffTargets = mod:NewTargetList()
local scheduled = nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.stormcaller = "Zandalari Storm-Caller"
	L.stormbringer = "Stormbringer Draz'kil"
	L.monara = "Monara"
	L.rockyhorror = "Rocky Horror"
	L.thunderlord_guardian = "Thunder Lord / Lightning Guardian"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{139322, "FLASH", "PROXIMITY", "SAY"},
		{139900, "FLASH", "PROXIMITY", "SAY"},
		{139899, "FLASH"},
		140673,
		{140296, "FLASH"},
	}, {
		[139322] = L.stormcaller,
		[139900] = L.stormbringer,
		[139899] = L.monara,
		[140673] = L.rockyhorror,
		[140296] = L.thunderlord_guardian
	}
end

function mod:OnBossEnable()
	scheduled = nil
	debuffTargets = mod:NewTargetList()

	self:Log("SPELL_AURA_APPLIED", "Storms", 139322, 139900) -- Storm Energy, Stormcloud
	self:Log("SPELL_AURA_REMOVED", "StormsRemoved", 139322, 139900)

	self:Log("SPELL_CAST_START", "HorrifyingRoar", 140673)

	self:Log("SPELL_AURA_APPLIED", "ConductiveShield", 140296)

	self:Log("SPELL_CAST_START", "ShadowNova", 139899)
	self:RegisterMessage("BigWigs_BossComm")

	self:Death("Disable", 70236, 70445, 70430, 69821)
	self:Death("MonaraDies", 70440)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local function warnStorms(spellId)
		scheduled = nil
		mod:TargetMessageOld(spellId, debuffTargets, "orange", "alert")
	end
	function mod:Storms(args)
		debuffTargets[#debuffTargets+1] = args.destName
		if self:Me(args.destGUID) then
			self:Flash(args.spellId)
			self:OpenProximity(args.spellId, 10)
			if args.spellId == 139900 then
				self:Say(args.spellId, nil, nil, "Stormcloud")
			else
				self:Say(args.spellId, nil, nil, "Storm Energy")
			end
		end
		if not scheduled then
			scheduled = self:ScheduleTimer(warnStorms, 0.2, args.spellId)
		end
	end
	function mod:StormsRemoved(args)
		if self:Me(args.destGUID) then
			self:CloseProximity(args.spellId)
		end
	end
end

function mod:HorrifyingRoar(args)
	self:Bar(args.spellId, 26.6) -- Either 29 or 26.6, which is picked may or may not be random
	self:MessageOld(args.spellId, "yellow", "long", CL["casting"]:format(args.spellName))
end

function mod:ConductiveShield(args)
	if self:UnitGUID("target") == args.destGUID then
		self:Flash(args.spellId)
		self:PlaySound(args.spellId, "info")
	end
	if self:MobId(args.destGUID) == 69821 then -- Thunder Lord cooldown
		self:Bar(args.spellId, 20.5)
	end
	self:Bar(args.spellId, 10, CL["other"]:format(self:SpellName(133249), args.destName)) -- "Shielded"
	self:MessageOld(args.spellId, "yellow", nil, CL["other"]:format(args.spellName, args.destName))
end

do
	-- Sync for corpse runners
	local times = {
		["MonaraDies"] = 0,
		["MonaraSN"] = 0,
	}
	function mod:BigWigs_BossComm(_, msg)
		if times[msg] then
			local t = GetTime()
			if t-times[msg] > 5 then
				times[msg] = t
				if msg == "MonaraDies" then
					self:Disable()
				elseif msg == "MonaraSN" then
					local spellId = 139899
					local name = self:SpellName(spellId)
					self:MessageOld(spellId, "orange", "long", CL["incoming"]:format(name))
					self:Bar(spellId, 3, CL["cast"]:format(name))
					self:Bar(spellId, 14.4)
					self:Flash(spellId)
				end
			end
		end
	end
	function mod:ShadowNova(args)
		self:Sync("MonaraSN")
	end
	function mod:MonaraDies()
		self:Sync("MonaraDies")
	end
end
