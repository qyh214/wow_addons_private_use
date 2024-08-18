
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Salyis's Warband", -376, 725)
if not mod then return end
mod:RegisterEnableMob(62346)
mod.otherMenu = -424
mod.worldBoss = 62346

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_yell = "Bring me their corpses!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		121600, 121787, -6200,
	}
end

function mod:OnBossEnable()
	self:BossYell("Engage", L.engage_yell)

	self:Emote("CannonBarrage", "121600")
	self:Emote("Stomp", "121787")

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:Death("Win", 62346) --Galleon
end

function mod:OnEngage()
	self:Bar(121600, 23) -- Cannon Barrage
	self:Bar(121787, 50) -- Stomp
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CannonBarrage()
	self:MessageOld(121600, "orange", nil, CL["incoming"]:format(self:SpellName(121600)))
	self:Bar(121600, 60)
end

function mod:Stomp()
	self:MessageOld(121787, "red", "alarm", CL["incoming"]:format(self:SpellName(121787)))
	self:Bar(121787, 60)
	self:DelayedMessage(-6200, 10, "yellow", CL["adds"], 121747) -- Salyin Warmonger
end

