--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Lord Jaraxxus", 649, 1619)
if not mod then return end
mod:RegisterEnableMob(34780)
-- mod:SetEncounterID(1087) -- Can fire repeatedly during a wipe
-- mod:SetRespawnTime(30)
mod.toggleOptions = {66237, {66197, "ICON", "FLASH"}, 66228, "adds", {66334, "FLASH"}, "berserk"}
mod.optionHeaders = {
	[66237] = "normal",
	[66334] = "heroic",
}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.enable_trigger = "Trifling gnome! Your arrogance will be your undoing!"

	L.engage = "Engage"
	L.engage_trigger = "You face Jaraxxus, Eredar Lord of the Burning Legion!"
	L.engage_trigger1 = "But I'm in charge here"

	L.adds = "Portals and volcanos"
	L.adds_desc = "Show a timer and warn for when Jaraxxus summons portals and volcanos."

	L.incinerate_message = "Incinerate"
	L.incinerate_other = "%s goes boom!"
	L.incinerate_bar = "Next Incinerate"
	L.incinerate_safe = "%s is safe, yay :)"

	L.legionflame_message = "Flame"
	L.legionflame_other = "Flame on %s!"
	L.legionflame_bar = "Next Flame"

	L.infernal_bar = "Volcano spawns"
	L.netherportal_bar = "Portal spawns"

	L.kiss_message = "Kiss on YOU!"
	L.kiss_interrupted = "Interrupted!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnRegister()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
end
mod.OnBossDisable = mod.OnRegister

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "IncinerateFlesh", 66237)
	self:Log("SPELL_AURA_REMOVED", "IncinerateFleshRemoved", 66237)
	self:Log("SPELL_AURA_APPLIED", "LegionFlame", 66197)
	self:Log("SPELL_AURA_APPLIED", "NetherPower", 66228)
	self:Log("SPELL_CAST_SUCCESS", "NetherPortal", 66269)
	self:Log("SPELL_CAST_SUCCESS", "InfernalEruption", 66258)
	self:Log("SPELL_AURA_APPLIED", "MistressKiss", 66334) -- debuff before getting interrupted
	self:Log("SPELL_AURA_REMOVED", "MistressKissRemoved", 66334)
	self:Log("SPELL_INTERRUPT", "MistressKissInterrupted", 66335, 66359) -- debuff after getting interrupted

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:Death("Win", 34780)
end

function mod:OnEngage()
	self:Bar("adds", 20, L["netherportal_bar"], 66269)
	if self:Heroic() then
		self:Berserk(600)
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg == L.enable_trigger or msg:find(L.enable_trigger, nil, true) then
		self:Enable()
	elseif msg == L.engage_trigger1 or msg:find(L.engage_trigger1, nil, true) then
		-- Only happens the first time we engage Jaraxxus, still 11 seconds left until he really engages.
		self:Bar("adds", 12, L["engage"], "INV_Gizmo_01")
	elseif msg == L.engage_trigger or msg:find(L.engage_trigger, nil, true) then
		self:Engage()
	end
end

function mod:IncinerateFlesh(args)
	self:TargetMessageOld(args.spellId, args.destName, "orange", "info", L["incinerate_message"])
	self:Bar(args.spellId, 12, L["incinerate_other"]:format(args.destName))
end

function mod:IncinerateFleshRemoved(args)
	self:MessageOld(args.spellId, "green", nil, L["incinerate_safe"]:format(args.destName), 17) -- Power Word: Shield icon.
	self:StopBar(L["incinerate_other"]:format(args.destName))
end

function mod:LegionFlame(args)
	self:TargetMessageOld(args.spellId, args.destName, "blue", "alert", L["legionflame_message"])
	if self:Me(args.destGUID) then
		self:Flash(args.spellId)
	end
	self:Bar(args.spellId, 8, L["legionflame_other"]:format(args.destName))
	self:PrimaryIcon(args.spellId, args.destName)
end

function mod:NetherPower(args)
	if self:MobId(args.destGUID) == 34780 then
		self:MessageOld(args.spellId, "yellow")
		self:CDBar(args.spellId, 44)
	end
end

function mod:NetherPortal(args)
	self:MessageOld("adds", "orange", "alarm", args.spellId)
	self:Bar("adds", 60, L["infernal_bar"], 66258)
end

function mod:InfernalEruption(args)
	self:MessageOld("adds", "orange", "alarm", args.spellId)
	self:Bar("adds", 60, L["netherportal_bar"], 66269)
end

function mod:MistressKiss(args)
	if self:Me(args.destGUID) then
		self:MessageOld(args.spellId, "blue", nil, L["kiss_message"])
		self:Bar(args.spellId, 15, L["kiss_message"])
		self:Flash(args.spellId)
	end
end

function mod:MistressKissRemoved(args)
	if self:Me(args.destGUID) then
		self:StopBar(L["kiss_message"])
	end
end

function mod:MistressKissInterrupted(args)
	if self:Me(args.destGUID) then
		self:MessageOld(66334, "blue", nil, L["kiss_interrupted"])
	end
end

