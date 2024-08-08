--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Warlord Zon'ozz", 967, 324)
if not mod then return end
mod:RegisterEnableMob(55308)

local ballTimer = 0
local shadowsMarkCounter = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "Zzof Shuul'wah. Thoq fssh N'Zoth!"

	L.ball = "Void ball"
	L.ball_desc = "Void ball that bounces off of players and the boss."
	L.ball_icon = 28028 -- void sphere icon
	L.ball_yell = "Gul'kafh an'qov N'Zoth."

	L.bounce = "Void ball bounce"
	L.bounce_desc = "Counter for the void ball bounces."
	L.bounce_icon = 132563 -- inv_misc_soccerball / Kick Foot Ball

	L.darkness = "Tentacle disco party!"
	L.darkness_desc = "This phase starts when the void ball hits the boss."
	L.darkness_icon = 109413

	L.shadows = "Shadows"

	L.drain = -3971 -- Psychic Drain
	L.drain_icon = 104322

	L.custom_off_shadows_marker = "Disrupting Shadows marker"
	L.custom_off_shadows_marker_desc = "Mark Disrupting Shadows targets with {rt1}{rt2}{rt3}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r"
	L.custom_off_shadows_marker_icon = 1
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"ball", "bounce", "darkness",
		"drain", {103434, "FLASH", "SAY", "PROXIMITY"}, "custom_off_shadows_marker",
		"berserk",
	}, {
		ball = -3973,
		drain = "general",
	}
end

function mod:OnBossEnable()
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "Darkness", "boss1")
	self:Log("SPELL_CAST_SUCCESS", "PsychicDrain", 104322)
	self:Log("SPELL_AURA_APPLIED", "ShadowsApplied", 103434)
	self:Log("SPELL_AURA_REMOVED", "ShadowsRemoved", 103434)
	self:Log("SPELL_CAST_SUCCESS", "ShadowsCast", 103434)
	self:Log("SPELL_AURA_APPLIED", "VoidDiffusion", 106836)
	self:Log("SPELL_AURA_APPLIED_DOSE", "VoidDiffusion", 106836)

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")
	self:BossYell("VoidoftheUnmaking", L["ball_yell"])

	self:Death("Win", 55308)
end

function mod:OnEngage()
	if not self:LFR() then
		self:Berserk(360) -- confirmed 10 man heroic
	end
	self:Bar("ball", 6, L["ball"], L["ball_icon"])
	self:CDBar(103434, 23) -- Shadows
	self:Bar("drain", 17, L["drain"], 104322)
	ballTimer = 0
	shadowsMarkCounter = 1
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Darkness(_, _, _, spellId)
	if spellId == 109413 then
		self:Bar("darkness", 30, L["darkness"], spellId)
		self:MessageOld("darkness", "red", "info", L["darkness"], spellId)
		self:CDBar(103434, 37) -- Shadows
		local isHC = self:Heroic() and 45 or 54
		if (GetTime() - ballTimer) > isHC then
			self:Bar("ball", isHC == 45 and isHC or 36, L["ball"], L["ball_icon"])
		end
		self:StopBar(L["drain"])
	end
end

function mod:VoidDiffusion(args)
	self:MessageOld("bounce", "red", nil, ("%s (%d)"):format(L["bounce"], args.amount or 1), L.bounce_icon)
end

function mod:PsychicDrain(args)
	self:CDBar("drain", 20, args.spellId)
	self:MessageOld("drain", "orange", nil, args.spellId)
end

function mod:VoidoftheUnmaking()
	if ballTimer ~= 0 then
		self:Bar("drain", 8.3, L["drain"], L["drain_icon"])
	end
	ballTimer = GetTime()
	self:Bar("ball", 90, L["ball"], L["ball_icon"])
	self:MessageOld("ball", "orange", "alarm", L["ball"], L["ball_icon"])
end

function mod:ShadowsCast(args)
	self:MessageOld(args.spellId, "yellow")
	self:CDBar(args.spellId, 26) -- 26-29
	shadowsMarkCounter = 1
end

function mod:ShadowsApplied(args)
	if not self:LFR() and self:Me(args.destGUID) then
		self:MessageOld(args.spellId, "blue", "alert", CL["you"]:format(L["shadows"]), args.spellId)
		self:Say(args.spellId, L["shadows"], nil, "Shadows")
		self:Flash(args.spellId)
		if self:Heroic() then
			self:OpenProximity(args.spellId, 10)
		end
	end
	if self.db.profile.custom_off_shadows_marker then
		self:CustomIcon(false, args.destName, shadowsMarkCounter)
		shadowsMarkCounter = shadowsMarkCounter + 1
	end
end

function mod:ShadowsRemoved(args)
	if not self:LFR() and self:Me(args.destGUID) then
		self:CloseProximity(args.spellId)
	end
	if self.db.profile.custom_off_shadows_marker then
		self:CustomIcon(false, args.destName)
	end
end

