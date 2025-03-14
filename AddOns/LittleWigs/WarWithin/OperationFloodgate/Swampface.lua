--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Swampface", 2773, 2650)
if not mod then return end
mod:RegisterEnableMob(226396) -- Swampface
mod:SetEncounterID(3053)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.warmup_icon = "inv_achievement_dungeon_waterworks"
end

--------------------------------------------------------------------------------
-- Locals
--

local awakenTheSwampCount = 1
local sludgeClawsCount = 1

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"warmup",
		473070, -- Awaken the Swamp
		473114, -- Mudslide
		{469478, "TANK_HEALER"}, -- Sludge Claws
		-- Mythic
		470039, -- Razorchoke Vines
	}, {
		[470039] = CL.mythic,
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "AwakenTheSwamp", 473070)
	self:Log("SPELL_CAST_START", "Mudslide", 473114)
	self:Log("SPELL_CAST_START", "SludgeClaws", 469478)

	-- Mythic
	self:Log("SPELL_CAST_SUCCESS", "RazorchokeVines", 470039)
	self:Log("SPELL_AURA_APPLIED", "RazorchokeVinesPreApplied", 470038)
	self:Log("SPELL_AURA_APPLIED", "RazorchokeVinesApplied", 472819)
end

function mod:OnEngage()
	awakenTheSwampCount = 1
	sludgeClawsCount = 1
	self:StopBar(CL.active)
	if self:Mythic() then
		self:CDBar(470039, 1.0) -- Razorchoke Vines
	end
	self:CDBar(469478, 2.0, CL.count:format(self:SpellName(469478), sludgeClawsCount)) -- Sludge Claws
	self:CDBar(473114, 9.0) -- Mudslide
	self:CDBar(473070, 19.0, CL.count:format(self:SpellName(473070), awakenTheSwampCount)) -- Awaken the Swamp
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Warmup() -- called from trash module
	-- 20.14 [CLEU] SPELL_CAST_SUCCESS#Player-5764#Creature-0-5770-2773-5861-234373#Bomb Pile#1214337#Plant Bombs
	-- 37.72 [NAME_PLATE_UNIT_ADDED] Swampface#Creature-0-5770-2773-5861-226396
	self:Bar("warmup", 17.6, CL.active, L.warmup_icon)
end

function mod:AwakenTheSwamp(args)
	self:StopBar(CL.count:format(args.spellName, awakenTheSwampCount))
	self:Message(args.spellId, "yellow", CL.count:format(args.spellName, awakenTheSwampCount))
	awakenTheSwampCount = awakenTheSwampCount + 1
	self:CDBar(args.spellId, 30.0, CL.count:format(args.spellName, awakenTheSwampCount))
	self:PlaySound(args.spellId, "long")
end

function mod:Mudslide(args)
	self:Message(args.spellId, "orange")
	self:CDBar(args.spellId, 30.0)
	self:PlaySound(args.spellId, "alarm")
end

function mod:SludgeClaws(args)
	self:StopBar(CL.count:format(args.spellName, sludgeClawsCount))
	self:Message(args.spellId, "purple", CL.count:format(args.spellName, sludgeClawsCount))
	sludgeClawsCount = sludgeClawsCount + 1
	self:CDBar(args.spellId, 30.0, CL.count:format(args.spellName, sludgeClawsCount))
	self:PlaySound(args.spellId, "alert")
end

-- Mythic

do
	local firstPlayerName, firstPlayerMe = nil, false

	function mod:RazorchokeVines(args)
		firstPlayerName = nil
		firstPlayerMe = false
		self:CDBar(args.spellId, 30.0)
	end

	function mod:RazorchokeVinesPreApplied(args)
		-- the order of this debuff is not a reliable indicator of who will be linked with whom
		if self:Me(args.destGUID) then
			self:Message(470039, "blue", CL.custom_sec:format(CL.you:format(CL.link), 5))
		end
	end

	function mod:RazorchokeVinesApplied(args)
		-- up to 2 sets of links go out at a time
		if firstPlayerName == nil then -- first debuff
			firstPlayerName = args.destName
			firstPlayerMe = self:Me(args.destGUID)
		else -- second debuff, linked with first debuff
			if firstPlayerMe then
				firstPlayerMe = false
				self:PersonalMessage(470039, "link_with", self:ColorName(args.destName))
				self:PlaySound(470039, "info")
			elseif self:Me(args.destGUID) then
				self:PersonalMessage(470039, "link_with", self:ColorName(firstPlayerName))
				self:PlaySound(470039, "info")
			end
			firstPlayerName = nil
		end
	end
end
