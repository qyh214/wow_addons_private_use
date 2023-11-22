--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Primal Tsunami", 2527, 2511)
if not mod then return end
mod:RegisterEnableMob(
	189729, -- Primal Tsunami
	196043  -- Primalist Infuser
)
mod:SetEncounterID(2618)
mod:SetRespawnTime(30)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local stageOneCount = 1
local infusedGlobulesRemaining = 2
local tempestsFuryRemaining = 2
local addsAlive = 0

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		-- Stage One: Violent Squalls
		387559, -- Infused Globules
		388424, -- Tempest's Fury
		{387504, "TANK_HEALER"}, -- Squall Buffet
		389875, -- Undertow
		-- Stage Two: Infused Waters
		388882, -- Inundate
	}, {
		[387559] = -25529, -- Stage One: Violent Swells
		[388882] = -25531, -- Stage Two: Infused Waters
	}
end

function mod:OnBossEnable()
	-- Stages
	self:Log("SPELL_CAST_START", "Submerge", 387585)
	self:Log("SPELL_AURA_REMOVED", "SubmergeOver", 387585)

	-- Stage 1
	self:Log("SPELL_CAST_START", "InfusedGlobules", 387559)
	self:Log("SPELL_CAST_START", "TempestsFury", 388424)
	self:Log("SPELL_CAST_START", "SquallBuffet", 387504)
	self:Log("SPELL_CAST_START", "Undertow", 389875)

	-- Stage 2
	self:Log("SPELL_CAST_START", "Inundate", 388882)
	self:Death("AddDeath", 196043) -- Primalist Infuser
end

function mod:OnEngage()
	stageOneCount = 1
	infusedGlobulesRemaining = 2
	tempestsFuryRemaining = 2
	addsAlive = 0
	self:SetStage(1)
	self:Bar(388424, 4.0) -- Tempest's Fury
	self:Bar(387559, 8.0) -- Infused Globules
	self:Bar(387504, 16.0) -- Squall Buffet
	self:Bar("stages", 51.9, self:SpellName(387585), 387585) -- Submerge
end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- Stages

function mod:Submerge(args)
	addsAlive = 4
	self:SetStage(2)
	self:StopBar(args.spellName)
	self:Message("stages", "cyan", args.spellName, args.spellId)
	self:PlaySound("stages", "long")
	self:CDBar("stages", 131.1, CL.onboss:format(args.spellName), args.spellId)
end

function mod:SubmergeOver(args)
	addsAlive = 0
	stageOneCount = stageOneCount + 1
	infusedGlobulesRemaining = 2
	tempestsFuryRemaining = 2
	self:SetStage(1)
	self:StopBar(CL.onboss:format(args.spellName))
	self:Message("stages", "cyan", CL.over:format(args.spellName), args.spellId)
	self:PlaySound("stages", "info")
	self:CDBar(388424, 7.6) -- Tempest's Fury
	self:CDBar(387559, 11.6) -- Infused Globules
	self:CDBar(387504, 19.6) -- Squall Buffet
	self:Bar("stages", 56.5, args.spellName, args.spellId)
end

-- Stage 1

function mod:InfusedGlobules(args)
	infusedGlobulesRemaining = infusedGlobulesRemaining - 1
	self:Message(args.spellId, "yellow")
	self:PlaySound(args.spellId, "alarm")
	if infusedGlobulesRemaining > 0 then
		-- often slightly delayed
		self:CDBar(args.spellId, 17.0)
	else
		self:StopBar(args.spellId)
	end
end

function mod:TempestsFury(args)
	tempestsFuryRemaining = tempestsFuryRemaining - 1
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alert")
	if tempestsFuryRemaining > 0 then
		self:Bar(args.spellId, 31.0)
		-- fix other bars
		if stageOneCount > 1 then
			self:Bar(387559, {4.0, 11.6}) -- Infused Globules
			self:Bar(387504, {12.0, 19.6}) -- Squall Buffet
		end
	end
end

function mod:SquallBuffet(args)
	self:Message(args.spellId, "purple")
	self:PlaySound(args.spellId, "alert")
end

function mod:Undertow(args)
	self:Message(args.spellId, "purple")
	if self:Tank() then
		-- this is only cast when the tank is out of range
		self:PlaySound(args.spellId, "warning")
	else
		self:PlaySound(args.spellId, "alert")
	end
end

-- Stage 2

do
	local prev = 0
	function mod:Inundate(args)
		if self:Friendly(args.sourceFlags) -- these NPCs can be mind-controlled by Priests
			or self:MobId(args.sourceGUID) ~= 196043 then -- Primalist Infuser
			return
		end
		local t = args.time
		if t - prev > 1 then
			prev = t
			self:Message(args.spellId, "yellow")
			self:PlaySound(args.spellId, "alert")
		end
	end
end

function mod:AddDeath(args)
	addsAlive = addsAlive - 1
	if addsAlive > 0 then
		self:Message("stages", "cyan", CL.add_remaining:format(addsAlive), false)
		self:PlaySound("stages", "info")
	end
end
