--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Yor'sahj the Unsleeping", 967, 325)
if not mod then return end
mod:RegisterEnableMob(55312)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "Iilth qi'uothk shn'ma yeh'glu Shath'Yar! H'IWN IILTH!"

	L.bolt = mod:SpellName(105416)
	L.bolt_desc = "Count the stacks of void bolt and show a duration bar."
	L.bolt_icon = 105416
	L.bolt_message = "%2$dx Bolt on %1$s"

	L.blue = "|cFF0080FFBlue|r"
	L.green = "|cFF088A08Green|r"
	L.purple = "|cFF9932CDPurple|r"
	L.yellow = "|cFFFFA901Yellow|r"
	L.black = "|cFF424242Black|r"
	L.red = "|cFFFF0404Red|r"

	L.blobs = "Blobs"
	L.blobs_bar = "Next blob spawn"
	L.blobs_desc = "Blobs moving towards the boss"
	L.blobs_icon = "achievement_doublerainbow"

	L.acid = -4320 -- Digestive Acid
	L.acid_icon = "spell_nature_corrosivebreath"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Locals
--

local colorCombinations = {
	[105420] = { L.purple, L.green, L.blue, L.black },
	[105435] = { L.green, L.red, L.black, L.blue },
	[105436] = { L.green, L.yellow, L.red, L.black },
	[105437] = { L.purple, L.blue, L.yellow, L.green },
	[105439] = { L.blue, L.black, L.yellow, L.purple },
	[105440] = { L.purple, L.red, L.black, L.yellow },
	--[105441] this is some generic thing, don't use it
}

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"blobs", {"bolt", "TANK"}, "acid", -4321, "proximity", "berserk"
	}
end

function mod:OnBossEnable()
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "Blobs", "boss1", "boss2", "boss3", "boss4")
	self:Log("SPELL_AURA_APPLIED", "AcidicApplied", 104898)
	self:Log("SPELL_AURA_REMOVED", "AcidicRemoved", 104898)
	self:Log("SPELL_CAST_SUCCESS", "DeepCorruption", 105171)
	self:Log("SPELL_AURA_APPLIED", "Bolt", 104849, 105416)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Bolt", 104849, 105416)
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Log("SPELL_DAMAGE", "AcidPulse", 105573)
	self:Log("SPELL_MISSED", "AcidPulse", 105573)

	self:Death("Win", 55312)
end

function mod:OnEngage()
	self:Berserk(600)
	self:Bar("blobs", 21, L["blobs_bar"], L["blobs_icon"])
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Bolt(args)
	local buffStack = args.amount or 1
	self:StopBar(L["bolt_message"]:format(args.destName, buffStack - 1))
	self:Bar("bolt", 12, L["bolt_message"]:format(args.destName, buffStack), args.spellId)
	self:StackMessageOld("bolt", args.destName, buffStack, "orange", buffStack > 2 and "info", args.spellId)
end

function mod:Blobs(_, _, _, spellId)
	if colorCombinations[spellId] then
		if self:Heroic() then
			self:MessageOld("blobs", "orange", "alarm", ("%s %s %s %s"):format(colorCombinations[spellId][1], colorCombinations[spellId][2], colorCombinations[spellId][4], colorCombinations[spellId][3]), L["blobs_icon"])
			self:Bar("blobs", 75, L["blobs_bar"], L["blobs_icon"])
		else
			self:MessageOld("blobs", "orange", "alarm", ("%s %s %s"):format(colorCombinations[spellId][1], colorCombinations[spellId][2], colorCombinations[spellId][3]), L["blobs_icon"])
			self:Bar("blobs", 90, L["blobs_bar"], L["blobs_icon"])
		end
	end
end

function mod:AcidicApplied()
	if not self:LFR() then
		self:OpenProximity("proximity", 4)
	end
end

function mod:AcidicRemoved()
	if not self:LFR() then
		self:CloseProximity()
	end
end

function mod:DeepCorruption(args)
	self:MessageOld(-4321, "blue", "alert", 23401, args.spellId) -- Corrupted Healing
end

do
	local prev = 0
	function mod:AcidPulse()
		if GetTime() - prev > 1.5 then
			prev = GetTime()
			-- Time when it's actually going to hit you
			self:Bar("acid", 8, L["acid"], L["acid_icon"])
		end
	end
end

