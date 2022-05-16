local mod	= DBM:NewMod("Loatheb", "DBM-Naxx", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220221020029")
mod:SetCreatureID(16011)
mod:SetEncounterID(1115)
mod:SetModelID(16110)
mod:RegisterCombat("combat")--Maybe change to a yell later so pull detection works if you chain pull him from tash gauntlet

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 29185 29194 29196 29198",-- 29184 29195 29197 29199
	"SPELL_AURA_REMOVED 29185 29194 29196 29198",-- 29184 29195 29197 29199
	"SPELL_CAST_SUCCESS 29234 29204 30281 55052 55593",
	"UNIT_DIED"
)

--TODO, verify infoframe and spellIds ported from Classic as accurate, they didn't have to be accurate in classic since it just matched name, but here it does
local warnSporeNow			= mod:NewSpellAnnounce(29234, 2, "134530")
local warnSporeSoon			= mod:NewSoonAnnounce(29234, 1, "134530")
local warnDoomNow			= mod:NewSpellAnnounce(29204, 3)
local warnRemoveCurse		= mod:NewSpellAnnounce(30281, 3)
local warnHealSoon			= mod:NewAnnounce("WarningHealSoon", 4, 55593, nil, nil, nil, 55593)
local warnHealNow			= mod:NewAnnounce("WarningHealNow", 1, 55593, false, nil, nil, 55593)

local timerSpore			= mod:NewNextCountTimer(36, 29234, nil, nil, nil, 5, "134530", DBM_COMMON_L.DAMAGE_ICON)
local timerDoom				= mod:NewNextTimer(180, 29204, nil, nil, nil, 2)
--local timerRemoveCurseCD	= mod:NewNextTimer(30.8, 30281, nil, nil, nil, 5)
--local timerAura				= mod:NewBuffActiveTimer(17, 55593, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)

mod:AddInfoFrameOption(29184, "Tank|Healer")
mod:AddDropdownOption("CorruptedSorting", {"Alphabetical", "Duration"}, "Alphabetical", "misc", nil, 29184)

mod.vb.doomCounter	= 0
mod.vb.sporeTimer	= 36
mod.vb.sporeCounter = 0
local hadCorrupted	= {}

local updateInfoFrame
do
	local ipairs, pairs, tostring = ipairs, pairs, tostring
	local mfloor, mmax, tinsert, tsort, twipe = math.floor, math.max, table.insert, table.sort, table.wipe
	local lines, sortedLines, corruptKeys, durToName = {}, {}, {}, {}
	local function addLine(key, value)
		-- sort by insertion order
		lines[key] = value
		sortedLines[#sortedLines + 1] = key
	end
	updateInfoFrame = function()
		twipe(lines)
		twipe(sortedLines)
		twipe(corruptKeys)

		local refreshTime = GetTime()

		for name, _ in pairs(hadCorrupted) do
			tinsert(corruptKeys, name)
		end
		if mod.Options.CorruptedSorting == "Duration" then
			tsort(corruptKeys, function (a, b) return (hadCorrupted[a] or refreshTime) > (hadCorrupted[b] or refreshTime) end)
		else
			tsort(corruptKeys)
		end

		for _, name in ipairs(corruptKeys) do
			addLine(name, tostring(mfloor(mmax(hadCorrupted[name] - refreshTime, 0))))
		end

		return lines, sortedLines
	end
end

function mod:OnCombatStart(delay)
	self.vb.doomCounter = 0
	self.vb.sporeCounter = 0
--	timerRemoveCurseCD:Start(3 - delay)
	if self:IsDifficulty("normal25") then
		self.vb.sporeTimer = 18
	else
		self.vb.sporeTimer = 36
	end
	timerSpore:Start(self.vb.sporeTimer - delay, 1)
	warnSporeSoon:Schedule(self.vb.sporeTimer - 5 - delay)
	timerDoom:Start(120 - delay, self.vb.doomCounter + 1)

	local startTime = GetTime()
	table.wipe(hadCorrupted)
	for unit in DBM:GetGroupMembers() do
		local _, cls = UnitClass(unit)
		local _, _, _, mapId = UnitPosition(unit)
		if not UnitIsDeadOrGhost(unit) and mapId == 533 and (cls == "DRUID" or cls == "PALADIN" or cls == "PRIEST" or cls == "SHAMAN") then
			hadCorrupted[UnitName(unit)] = startTime
		end
	end
	if self.Options.InfoFrame and not DBM.InfoFrame:IsShown() then
		DBM.InfoFrame:SetHeader(DBM:GetSpellInfo(29184))
		DBM.InfoFrame:Show(25, "function", updateInfoFrame, false, false)
		DBM.InfoFrame:SetColumns(2)
	end
end

function mod:OnCombatEnd()
	if DBM.InfoFrame:IsShown() then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 29234 then
		self.vb.sporeCounter = self.vb.sporeCounter + 1
		timerSpore:Start(self.vb.sporeTimer, self.vb.sporeCounter+1)
		warnSporeNow:Show()
		warnSporeSoon:Schedule(self.vb.sporeTimer - 5)
	elseif args:IsSpellID(29204, 55052) then
		self.vb.doomCounter = self.vb.doomCounter + 1
		local timer = 30
		if self.vb.doomCounter >= 7 then
			if self.vb.doomCounter % 2 == 0 then timer = 17
			else timer = 12 end
		end
		warnDoomNow:Show(self.vb.doomCounter)
		timerDoom:Start(timer, self.vb.doomCounter + 1)
	elseif args.spellId == 30281 then
		warnRemoveCurse:Show()
--		timerRemoveCurseCD:Start()
--	elseif args.spellId == 55593 then
--		timerAura:Start()
--		warnHealSoon:Schedule(14)
--		warnHealNow:Schedule(17)
	end
end


function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(29194, 29196, 29185, 29198) and DBM:UnitDebuff(args.destName, 29184, 29195, 29197, 29199) then
		hadCorrupted[args.destName] = GetTime() + 60
		if args:IsPlayer() then
			warnHealSoon:Schedule(55)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(29194, 29196, 29185, 29198) and not DBM:UnitDebuff(args.destName, 29184, 29195, 29197, 29199) then
		if args:IsPlayer() then
			warnHealNow:Show()
		end
	end
end

--because in all likelyhood, pull detection failed (cause 90s like to charge in there trash and all and pull it
--We unschedule the pre warnings on death as a failsafe
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 16011 then
		warnSporeSoon:Cancel()
--		warnHealSoon:Cancel()
--		warnHealNow:Cancel()
	elseif hadCorrupted[args.destName] then
		hadCorrupted[args.destName] = nil
	end
end
