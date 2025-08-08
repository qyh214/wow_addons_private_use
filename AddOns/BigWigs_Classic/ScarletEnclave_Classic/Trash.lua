--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Scarlet Enclave Trash", 2856)
if not mod then return end
mod.displayName = CL.trash
mod:RegisterEnableMob(
	242224, -- Cardinal Stiltz
	242308, -- Shield Warden Stein
	242304, -- Knight-Captain Fratley
	242310, -- Arcanist Hilda
	242301, -- Cannon Mistress Lind
	242296 -- Bowmaster Puck
)

--------------------------------------------------------------------------------
-- Locals
--

local guardiansAlive = 6
local guardiansDefeated = {}
local nameCollector = {}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.big_adds = CL.big_adds
end

--------------------------------------------------------------------------------
-- Initialization
--

local guardianMarker = mod:AddMarkerOption(true, "npc", 8, "big_adds", 8)
function mod:GetOptions()
	return {
		"stages",
		guardianMarker,
	}
end

function mod:OnBossEnable()
	guardiansAlive = 6
	guardiansDefeated = {}
	nameCollector = {}
	self:RegisterMessage("BigWigs_OnBossWin", "Disable") -- Not using Engage because of false ENCOUNTER_START for Beatrix that I doubt will ever be fixed
	self:RegisterEvent("UNIT_TARGETABLE_CHANGED")
	self:RegisterMessage("BigWigs_UNIT_TARGET")
	self:RegisterMessage("BigWigs_BossComm")
	self:Death("GuardianKilled", 242224, 242308, 242304, 242310, 242301, 242296)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local guardians = {
		[242224] = true, -- Cardinal Stiltz
		[242308] = true, -- Shield Warden Stein
		[242304] = true, -- Knight-Captain Fratley
		[242310] = true, -- Arcanist Hilda
		[242301] = true, -- Cannon Mistress Lind
		[242296] = true, -- Bowmaster Puck
	}
	function mod:UNIT_TARGETABLE_CHANGED(_, unit)
		local id = self:MobId(self:UnitGUID(unit))
		if guardians[id] and not guardiansDefeated[id] then
			guardiansDefeated[id] = true
			local idAsString = tostring(id)
			self:Sync(idAsString)
		end
	end

	function mod:BigWigs_UNIT_TARGET(_, mobId, unitTarget, guid)
		if guardians[mobId] then
			if not nameCollector[mobId] then
				nameCollector[mobId] = self:UnitName(unitTarget)
			end
			if nameCollector.prev ~= guid then
				nameCollector.prev = guid
				self:CustomIcon(guardianMarker, unitTarget, 8)
			end
		end
	end
end

do
	local times = {
		["242224"] = 0, -- Cardinal Stiltz
		["242308"] = 0, -- Shield Warden Stein
		["242304"] = 0, -- Knight-Captain Fratley
		["242310"] = 0, -- Arcanist Hilda
		["242301"] = 0, -- Cannon Mistress Lind
		["242296"] = 0, -- Bowmaster Puck
	}
	function mod:BigWigs_BossComm(_, msg)
		if times[msg] then
			local t = GetTime()
			if t-times[msg] > 100 then
				times[msg] = t
				local id = tonumber(msg)
				guardiansAlive = guardiansAlive - 1
				self:Message("stages", "cyan", CL.mob_killed:format(nameCollector[id] or "??", 6-guardiansAlive, 6), false, nil, 8) -- Stay onscreen for 8s
				if guardiansAlive == 0 then
					self:Disable()
				end
			end
		end
	end
end

function mod:GuardianKilled(args)
	if not guardiansDefeated[args.mobId] then
		guardiansAlive = guardiansAlive - 1
		self:Message("stages", "cyan", CL.mob_killed:format(args.destName, 6-guardiansAlive, 6), false, nil, 8) -- Stay onscreen for 8s
		if guardiansAlive == 0 then
			self:Disable()
		end
	end
end
