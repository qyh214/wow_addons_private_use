--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Aku'mai Discovery", 48)
if not mod then return end
mod:RegisterEnableMob(213334) -- Aku'mai Season of Discovery
mod:SetEncounterID(2891)
mod:SetRespawnTime(10)
mod:SetAllowWin(true)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Aku'mai"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		-- Stage 1
		{429168, "CASTBAR"}, -- Corrosive Blast
		427625, -- Corrosion
		-- Stage 2
		{429356, "CASTBAR"}, -- Void Blast
		428482, -- Shadow Seep
	},{
		[429168] = CL.stage:format(1),
		[429356] = CL.stage:format(2),
	},{
		[429168] = CL.breath, -- Corrosive Blast (Breath)
		[429356] = CL.breath, -- Void Blast (Breath)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "CorrosiveBlastOrVoidBlast", 429168, 429356) -- Corrosive Blast, Void Blast
	self:Log("SPELL_AURA_APPLIED", "DarkProtectionApplied", 429541)
	self:Log("SPELL_AURA_REMOVED", "DarkProtectionRemoved", 429541)
	self:Log("SPELL_AURA_APPLIED", "CorrosionOrShadowSeepApplied", 427625, 428482) -- Corrosion, Shadow Seep
	self:Log("SPELL_AURA_APPLIED_DOSE", "CorrosionOrShadowSeepApplied", 427625, 428482) -- Corrosion, Shadow Seep
	self:Log("SPELL_AURA_REMOVED", "CorrosionOrShadowSeepRemoved", 427625, 428482) -- Corrosion, Shadow Seep
end

function mod:OnEngage()
	self:SetStage(1)
	self:CDBar(429168, 21, CL.breath) -- Corrosive Blast
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CorrosiveBlastOrVoidBlast(args)
	self:Message(args.spellId, "red", CL.incoming:format(CL.breath))
	self:Bar(args.spellId, 21, CL.breath)
	self:CastBar(args.spellId, 3, CL.breath)
	self:PlaySound(args.spellId, "warning")
end

function mod:DarkProtectionApplied(args)
	self:StopBar(CL.breath) -- Corrosive Blast
	self:SetStage(1.5)
	self:Message("stages", "cyan", CL.percent:format(50, CL.intermission), args.spellId)
	self:CDBar("stages", 17, CL.intermission, args.spellId)
	self:PlaySound("stages", "long")
end

function mod:DarkProtectionRemoved()
	self:StopBar(CL.intermission)
	self:SetStage(2)
	self:Message("stages", "cyan", CL.stage:format(2), false)
	self:Bar(429356, 22, CL.breath) -- Void Blast
	self:PlaySound("stages", "info")
end

function mod:CorrosionOrShadowSeepApplied(args)
	if self:Me(args.destGUID) then
		local amount = args.amount or 1
		self:StackMessage(args.spellId, "blue", args.destName, amount, 3)
		if amount >= 3 then
			self:PlaySound(args.spellId, "alarm", nil, args.destName)
		end
	end
end

function mod:CorrosionOrShadowSeepRemoved(args)
	if self:Me(args.destGUID) then
		self:Message(args.spellId, "green", CL.removed:format(args.spellName))
	end
end
