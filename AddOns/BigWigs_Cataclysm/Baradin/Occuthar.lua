--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Occu'thar", 757, 140)
if not mod then return end
mod:RegisterEnableMob(52363)

local fireCount = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.shadows_bar = "~Shadows"
	L.destruction_bar = "<Explosion>"
	L.eyes_bar = "~Eyes"

	L.fire_message = "Lazer, Pew Pew"
	L.fire_bar = "~Lazer"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {96913, {96920, "FLASH"}, 96884, "berserk"}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "SearingShadows", 96913)
	self:Log("SPELL_CAST_START", "Eyes", 96920)
	self:Log("SPELL_CAST_SUCCESS", "FocusedFire", 96884)

	--No CheckBossStatus() here as event does not fire.
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")

	self:Death("Win", 52363)
end

function mod:OnEngage()
	self:Bar(96920, 25, L["eyes_bar"])
	self:Bar(96884, 13.1, L["fire_bar"])
	self:Bar(96913, 6.5, L["shadows_bar"])
	fireCount = 3
	self:Berserk(300)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:SearingShadows(args)
	self:TargetMessageOld(args.spellId, args.destName, "red")
	self:Bar(args.spellId, 24, L["shadows_bar"]) --23-26
end

function mod:Eyes(args)
	self:Flash(args.spellId)
	self:MessageOld(args.spellId, "orange", "alert")
	self:Bar(args.spellId, 10, L["destruction_bar"], 96968) -- 96968 is Occu'thar's Destruction
	self:Bar(args.spellId, 58, L["eyes_bar"])
	fireCount = 0
	self:Bar(96884, 18.5, L["fire_bar"]) --18.5-19.2
end

function mod:FocusedFire(args)
	self:MessageOld(args.spellId, "yellow", nil, L["fire_message"])
	fireCount = fireCount + 1
	if fireCount < 3 then
		self:Bar(args.spellId, 15.7, L["fire_bar"]) --15.5-16
	end
end

