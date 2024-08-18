--------------------------------------------------------------------------------
-- Module declaration
--

local mod, CL = BigWigs:NewBoss("The Four Horsemen", 533, 1609)
if not mod then return end
mod:RegisterEnableMob(
	16063, -- Sir Zeliek
	16064, -- Thane Korth'azz
	16065, -- Lady Blaumeux
	30549  -- Baron Rivendare
)
mod:SetEncounterID(1121)

--------------------------------------------------------------------------------
-- Locals
--

local deaths = 0
local markCount = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale()
if L then
	L.mark = "Mark"
	L.mark_desc = "Warn for marks."
	L.mark_icon = 28835 -- Mark of Zeliek

	L.engage_message = "The Four Horsemen engaged！"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"mark",
		{57369, "TANK_HEALER"}, -- Unholy Shadow (Rivendare)
		28884, -- Meteor (Korth'azz)
		28863, -- Void Zone (Blaumeux)
		28883, -- Holy Wrath (Zeliek)
		"stages",
		"berserk",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "Mark", 28832, 28833, 28834, 28835) -- Mark of Korth'azz, Mark of Blaumeux, Mark of Rivendare, Mark of Zeliek
	self:Log("SPELL_CAST_START", "Meteor", 28884, 57467)
	self:Log("SPELL_CAST_SUCCESS", "VoidZone", 28863, 57463)
	self:Log("SPELL_CAST_SUCCESS", "HolyWrath", 28883, 57466)
	self:Log("SPELL_AURA_APPLIED", "UnholyShadow", 57369)
	self:Log("SPELL_AURA_REFRESH", "UnholyShadow", 57369)

	self:Death("Deaths", 16063, 16064, 16065, 30549) -- Zeliek, Korth'azz, Blaumeux, Rivendare
end

function mod:OnEngage()
	deaths = 0
	markCount = 1

	self:Berserk(1200)
	self:CDBar("mark", 20.7, CL.count:format(L.mark, markCount), L.mark_icon)

	self:CDBar(57369, 15) -- Unholy Shadow
	self:CDBar(28863, 17) -- Void Zone
	self:CDBar(28883, 22) -- Holy Wrath
	self:CDBar(28884, 22) -- Meteor
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Deaths(args)
	deaths = deaths + 1
	self:Message("stages", "green", CL.mob_killed:format(args.destName, deaths, 4), false)
end

function mod:VoidZone(args)
	self:Message(28863, "orange")
	self:CDBar(28863, 12) -- 12~17
end

function mod:Meteor(args)
	self:Message(28884, "red")
	self:CDBar(28884, 12) -- 12~17
end

function mod:HolyWrath(args)
	self:Message(28883, "yellow")
	self:CDBar(28883, 12) -- 12~17
end

function mod:UnholyShadow(args)
	self:TargetMessage(args.spellId, "purple", args.destName)
	self:CDBar(args.spellId, 12) -- 12~17
end

do
	local prev = 0
	function mod:Mark(args)
		local t = args.time
		if t - prev > 11.5 then -- can desync over time, try to keep it tight
			prev = t
			self:StopBar(CL.count:format(L.mark, markCount))
			self:Message("mark", "cyan", CL.count:format(L.mark, markCount), L.mark_icon)
			markCount = markCount + 1
			self:CDBar("mark", 12.1, CL.count:format(L.mark, markCount), L.mark_icon)
		end
	end
end
