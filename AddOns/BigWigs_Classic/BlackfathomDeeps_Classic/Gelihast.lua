--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Gelihast Discovery", 48)
if not mod then return end
mod:RegisterEnableMob(204921) -- Gelihast Season of Discovery
mod:SetEncounterID(2704)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Gelihast"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		412072, -- Shadow Strike
		411956, -- Curse of Blackfathom
		411959, -- Fear
		412456, -- March of the Murlocs
	},nil,{
		[411956] = CL.curse, -- Curse of Blackfathom (Curse)
		[411959] = CL.fear, -- Fear (Fear)
		[412456] = CL.immune, -- March of the Murlocs (Immune)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "ShadowStrike", 412072, 412079, 412080)
	self:Log("SPELL_AURA_APPLIED", "ShadowStrikeApplied", 412072, 412079, 412080)
	self:Log("SPELL_AURA_APPLIED_DOSE", "ShadowStrikeApplied", 412072, 412079, 412080)
	self:Log("SPELL_CAST_SUCCESS", "CurseOfBlackfathom", 411973)
	self:Log("SPELL_AURA_APPLIED", "CurseOfBlackfathomApplied", 411956)
	self:Log("SPELL_AURA_APPLIED", "Fear", 411959)
	self:Log("SPELL_CAST_SUCCESS", "MarchOfTheMurlocs", 412456)
end

function mod:OnEngage()
	self:CDBar(411956, 6, CL.curse) -- Curse of Blackfathom
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:ShadowStrike()
	self:Bar(412072, 11)
end

function mod:ShadowStrikeApplied(args)
	local amount = args.amount or 1
	self:StackMessage(412072, "purple", args.destName, amount, 3)
	if amount >= 3 then
		self:PlaySound(412072, "warning")
	end
end

do
	local playerList = {}
	function mod:CurseOfBlackfathom()
		playerList = {}
		self:Bar(411956, 11, CL.curse)
	end

	function mod:CurseOfBlackfathomApplied(args)
		playerList[#playerList+1] = args.destName
		self:TargetsMessage(args.spellId, "yellow", playerList, nil, CL.curse)
		if self:Me(args.destGUID) then
			self:PlaySound(args.spellId, "alert", nil, args.destName)
		end
	end
end

function mod:Fear(args)
	self:TargetMessage(args.spellId, "red", args.destName, CL.fear)
	if self:Dispeller("magic") then
		self:PlaySound(args.spellId, "alert")
	end
end

do
	local prev = 0
	function mod:MarchOfTheMurlocs(args)
		if args.time - prev > 30 then
			prev = args.time
			self:StopBar(412072) -- Shadow Strike
			self:StopBar(CL.curse) -- Curse of Blackfathom
			self:Message(args.spellId, "cyan")
			self:Bar(args.spellId, 24, CL.immune)
			self:Bar(args.spellId, 33)
			self:PlaySound(args.spellId, "long")
		end
	end
end
