if not BigWigsLoader.isBeta then return end
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Shadowcrown", 2662, 2580)
if not mod then return end
mod:RegisterEnableMob(211087) -- Speaker Shadowcrown
mod:SetEncounterID(2837)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Initialization
--

local darknessComesCount = 1

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{451026, "CASTBAR"}, -- Darkness Comes
		{426735, "DISPEL"}, -- Burning Shadows
		-- Normal / Heroic
		425264, -- Obsidian Blast
		445996, -- Collapsing Darkness
		-- Mythic
		453212, -- Obsidian Beam
		453140, -- Collapsing Night
	}, {
		[425264] = CL.normal.." / "..CL.heroic,
		[453212] = CL.mythic,
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "DarknessComes", 451026)
	self:Log("SPELL_CAST_SUCCESS", "BurningShadows", 426734)
	self:Log("SPELL_AURA_APPLIED", "BurningShadowsApplied", 426735)

	-- Normal / Heroic
	self:Log("SPELL_CAST_START", "ObsidianBlast", 425264)
	self:Log("SPELL_CAST_START", "CollapsingDarkness", 445996)

	-- Mythic
	self:Log("SPELL_CAST_START", "ObsidianBeam", 453212)
	self:Log("SPELL_CAST_START", "CollapsingNight", 453140)
end

function mod:OnEngage()
	darknessComesCount = 1
	if self:Mythic() then
		self:CDBar(453212, 7.2) -- Obsidian Beam
		self:CDBar(426735, 21.2) -- Burning Shadows
		self:CDBar(453140, 23.4) -- Collapsing Night
	elseif self:Story() then
		-- Obsidian Blast and Collapsing Darkness are not cast in Follower difficulty
		self:CDBar(426735, 11.4) -- Burning Shadows
	else -- Normal, Heroic
		self:CDBar(425264, 6.1) -- Obsidian Blast
		self:CDBar(426735, 11.4) -- Burning Shadows
		self:CDBar(445996, 12.9) -- Collapsing Darkness
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:DarknessComes(args)
	local percent
	if darknessComesCount == 1 then
		darknessComesCount = darknessComesCount + 1
		percent = 50
		if self:Mythic() then
			self:CDBar(453140, 23.8) -- Collapsing Night
			self:CDBar(426735, 29.2) -- Burning Shadows
			self:CDBar(453212, 30.9) -- Obsidian Beam
		elseif self:Story() then
			self:CDBar(426735, 26.3) -- Burning Shadows
		else -- Normal, Heroic
			self:CDBar(425264, 21.6) -- Obsidian Blast
			self:CDBar(426735, 26.3) -- Burning Shadows
			self:CDBar(445996, 27.5) -- Collapsing Darkness
		end
	else
		percent = 0
		self:StopBar(426735) -- Burning Shadows
		if self:Mythic() then
			self:StopBar(453212) -- Obsidian Beam
			self:StopBar(453140) -- Collapsing Night
		else -- Normal, Heroic
			self:StopBar(425264) -- Obsidian Blast
			self:StopBar(445996) -- Collapsing Darkness
		end
	end
	self:Message(args.spellId, "cyan", CL.percent:format(percent, args.spellName))
	self:PlaySound(args.spellId, "warning")
	self:CastBar(args.spellId, 15)
end

function mod:BurningShadows()
	self:CDBar(426735, 19.1)
end

function mod:BurningShadowsApplied(args)
	-- this snares, but isn't dispelled by movement-dispelling effects
	if self:Me(args.destGUID) or self:Dispeller("magic", nil, args.spellId) then
		self:TargetMessage(args.spellId, "yellow", args.destName)
		self:PlaySound(args.spellId, "alert", nil, args.destName)
	end
end

-- Normal / Heroic

function mod:ObsidianBlast(args)
	self:Message(args.spellId, "purple")
	self:PlaySound(args.spellId, "alarm")
	self:CDBar(args.spellId, 11.6)
end

function mod:CollapsingDarkness(args)
	self:Message(args.spellId, "orange")
	self:PlaySound(args.spellId, "long")
	self:CDBar(args.spellId, 14.7)
end

-- Mythic

function mod:ObsidianBeam(args)
	self:Message(args.spellId, "purple")
	self:PlaySound(args.spellId, "alarm")
	self:CDBar(args.spellId, 24.3)
end

function mod:CollapsingNight(args)
	self:Message(args.spellId, "orange")
	self:PlaySound(args.spellId, "long")
	self:CDBar(args.spellId, 25.9)
end
