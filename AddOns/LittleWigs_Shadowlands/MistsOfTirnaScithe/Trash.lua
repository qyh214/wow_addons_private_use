--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Mists of Tirna Scithe Trash", 2290)
if not mod then return end
mod.displayName = CL.trash
mod:RegisterEnableMob(
	164929, -- Tirnenn Villager
	164921, -- Drust Harvester
	164920, -- Drust Soulcleaver
	164926, -- Drust Boughbreaker
	163058, -- Mistveil Defender
	171772, -- Mistveil Defender
	173720, -- Mistveil Gorgegullet
	166276, -- Mistveil Guardian
	173655, -- Mistveil Matriarch
	173714, -- Mistveil Nightblossom
	166275, -- Mistveil Shaper
	166301, -- Mistveil Stalker
	166304, -- Mistveil Stinger
	166299, -- Mistveil Tender
	167113, -- Spinemaw Acidgullet
	167111, -- Spinemaw Staghorn
	172312 -- Spinemaw Gorger
)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.tirnenn_villager = "Tirnenn Villager"
	L.drust_harvester = "Drust Harvester"
	L.drust_soulcleaver = "Drust Soulcleaver"
	L.drust_boughbreaker = "Drust Boughbreaker"
	L.mistveil_defender = "Mistveil Defender"
	L.mistveil_gorgegullet = "Mistveil Gorgegullet"
	L.mistveil_guardian = "Mistveil Guardian"
	L.mistveil_matriarch = "Mistveil Matriarch"
	L.mistveil_nightblossom = "Mistveil Nightblossom"
	L.mistveil_shaper = "Mistveil Shaper"
	L.mistveil_stalker = "Mistveil Stalker"
	L.mistveil_stinger = "Mistveil Stinger"
	L.mistveil_tender = "Mistveil Tender"
	L.spinemaw_acidgullet = "Spinemaw Acidgullet"
	L.spinemaw_staghorn = "Spinemaw Staghorn"
	L.spinemaw_gorger = "Spinemaw Gorger"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-- Tirnenn Villager
		321968, -- Bewildering Pollen
		322486, -- Overgrowth
		-- Drust Harvester
		322938, -- Harvest Essence
		-- Drust Soulcleaver
		{322569, "TANK"}, -- Hand of Thros
		{322557, "DISPEL"}, -- Soul Split
		-- Drust Boughbreaker
		324909, -- Furious Thrashing
		324923, -- Bramble Burst
		-- Mistveil Defender
		463256, -- Mist Ward
		463248, -- Expel
		-- Mistveil Gorgegullet
		340304, -- Poisonous Secretions
		340305, -- Crushing Leap
		{340300, "TANK_HEALER"}, -- Tongue Lashing
		-- Mistveil Guardian
		{463217, "TANK_HEALER"}, -- Anima Slash
		331743, -- Bucking Rampage
		-- Mistveil Matriarch
		340189, -- Pool of Radiance
		340160, -- Radiant Breath
		{340208, "TANK_HEALER"}, -- Shred Armor
		-- Mistveil Nightblossom
		{340289, "TANK_HEALER"}, -- Triple Bite
		{340279, "DISPEL"}, -- Poisonous Discharge
		-- Mistveil Shaper
		324776, -- Bramblethorn Coat
		-- Mistveil Stalker
		{325021, "ME_ONLY"}, -- Mistveil Tear
		-- Mistveil Stinger
		{325224, "DISPEL"}, -- Anima Injection
		-- Mistveil Tender
		{324914, "DISPEL"}, -- Nourish the Forest
		-- Spinemaw Acidgullet
		{325418, "ME_ONLY", "SAY"}, -- Volatile Acid
		-- Spinemaw Staghorn
		340544, -- Stimulate Regeneration
		{326046, "DISPEL"}, -- Stimulate Resistance
		-- Spinemaw Gorger
		326021, -- Acid Globule
	}, {
		[321968] = L.tirnenn_villager,
		[322938] = L.drust_harvester,
		[322569] = L.drust_soulcleaver,
		[324909] = L.drust_boughbreaker,
		[463256] = L.mistveil_defender,
		[340304] = L.mistveil_gorgegullet,
		[463217] = L.mistveil_guardian,
		[340189] = L.mistveil_matriarch,
		[340289] = L.mistveil_nightblossom,
		[324776] = L.mistveil_shaper,
		[325021] = L.mistveil_stalker,
		[325224] = L.mistveil_stinger,
		[324914] = L.mistveil_tender,
		[325418] = L.spinemaw_acidgullet,
		[340544] = L.spinemaw_staghorn,
		[326021] = L.spinemaw_gorger,
	}
end

-- XXX remove when 11.0.2 is live everywhere
if not BigWigsLoader.isBeta then
	function mod:GetOptions()
		return {
			-- Tirnenn Villager
			321968, -- Bewildering Pollen
			322486, -- Overgrowth
			-- Drust Harvester
			322938, -- Harvest Essence
			-- Drust Soulcleaver
			{322569, "TANK"}, -- Hand of Thros
			{322557, "DISPEL"}, -- Soul Split
			-- Drust Boughbreaker
			324909, -- Furious Thrashing
			324923, -- Bramble Burst
			-- Mistveil Defender
			331718, -- Spear Flurry
			-- Mistveil Gorgegullet
			340304, -- Poisonous Secretions
			340305, -- Crushing Leap
			{340300, "TANK_HEALER"}, -- Tongue Lashing
			-- Mistveil Guardian
			331743, -- Bucking Rampage
			-- Mistveil Matriarch
			340189, -- Pool of Radiance
			340160, -- Radiant Breath
			{340208, "TANK_HEALER"}, -- Shred Armor
			-- Mistveil Nightblossom
			{340289, "TANK_HEALER"}, -- Triple Bite
			{340279, "DISPEL"}, -- Poisonous Discharge
			-- Mistveil Shaper
			324776, -- Bramblethorn Coat
			-- Mistveil Stalker
			{325021, "ME_ONLY"}, -- Mistveil Tear
			-- Mistveil Stinger
			{325224, "DISPEL"}, -- Anima Injection
			-- Mistveil Tender
			{324914, "DISPEL"}, -- Nourish the Forest
			-- Spinemaw Acidgullet
			{325418, "ME_ONLY", "SAY"}, -- Volatile Acid
			-- Spinemaw Staghorn
			340544, -- Stimulate Regeneration
			{326046, "DISPEL"}, -- Stimulate Resistance
			-- Spinemaw Gorger
			326021, -- Acid Globule
		}, {
			[321968] = L.tirnenn_villager,
			[322938] = L.drust_harvester,
			[322569] = L.drust_soulcleaver,
			[324909] = L.drust_boughbreaker,
			[331718] = L.mistveil_defender,
			[340304] = L.mistveil_gorgegullet,
			[331743] = L.mistveil_guardian,
			[340189] = L.mistveil_matriarch,
			[340289] = L.mistveil_nightblossom,
			[324776] = L.mistveil_shaper,
			[325021] = L.mistveil_stalker,
			[325224] = L.mistveil_stinger,
			[324914] = L.mistveil_tender,
			[325418] = L.spinemaw_acidgullet,
			[340544] = L.spinemaw_staghorn,
			[326021] = L.spinemaw_gorger,
		}
	end
end

function mod:OnBossEnable()
	-- Tirnenn Villager
	self:Log("SPELL_CAST_START", "BewilderingPollen", 321968)
	self:Log("SPELL_CAST_SUCCESS", "Overgrowth", 322486)

	-- Drust Harvester
	self:Log("SPELL_CAST_SUCCESS", "HarvestEssence", 322938)

	-- Drust Soulcleaver
	self:Log("SPELL_AURA_APPLIED", "HandOfThrosApplied", 322569)
	self:Log("SPELL_CAST_START", "SoulSplit", 322557)
	self:Log("SPELL_AURA_APPLIED", "SoulSplitApplied", 322557)
	self:Log("SPELL_AURA_APPLIED_DOSE", "SoulSplitApplied", 322557)

	-- Drust Boughbreaker
	self:Log("SPELL_CAST_START", "FuriousThrashing", 324909)
	self:Log("SPELL_CAST_START", "BrambleBurst", 324923)

	-- Mistveil Defender
	if BigWigsLoader.isBeta then
		self:Log("SPELL_CAST_START", "MistWard", 463256)
		self:Log("SPELL_CAST_START", "Expel", 463248)
	else
		-- XXX remove when 11.0.2 is live everywhere
		self:Log("SPELL_CAST_START", "SpearFlurry", 331718)
	end

	-- Mistveil Gorgegullet
	self:Log("SPELL_CAST_START", "PoisonousSecretions", 340304)
	self:Log("SPELL_CAST_SUCCESS", "CrushingLeap", 340305)
	self:Log("SPELL_CAST_START", "TongueLashing", 340300)
	self:Death("MistveilGorgegulletDeath", 173720)

	-- Mistveil Guardian
	if BigWigsLoader.isBeta then
		self:Log("SPELL_CAST_START", "AnimaSlash", 463217)
	end
	self:Log("SPELL_CAST_START", "BuckingRampage", 331743)

	-- Mistveil Matriarch
	self:Log("SPELL_CAST_START", "PoolOfRadiance", 340189)
	self:Log("SPELL_CAST_START", "RadiantBreath", 340160)
	self:Log("SPELL_CAST_START", "ShredArmor", 340208)
	self:Death("MistveilMatriarchDeath", 173655)

	-- Mistveil Nightblossom
	self:Log("SPELL_CAST_START", "TripleBite", 340289)
	self:Log("SPELL_CAST_SUCCESS", "PoisonousDischarge", 340279)
	self:Log("SPELL_AURA_APPLIED", "PoisonousDischargeApplied", 340283)

	-- Mistveil Shaper
	self:Log("SPELL_CAST_START", "BramblethornCoat", 324776)

	-- Mistveil Stalker
	self:Log("SPELL_AURA_APPLIED", "MistveilTear", 325021)

	-- Mistveil Stinger
	self:Log("SPELL_AURA_APPLIED", "AnimaInjectionApplied", 325224)

	-- Mistveil Tender
	self:Log("SPELL_CAST_START", "NourishTheForest", 324914)
	self:Log("SPELL_CAST_SUCCESS", "NourishTheForestSuccess", 324914)

	-- Spinemaw Acidgullet
	self:Log("SPELL_AURA_APPLIED", "VolatileAcidApplied", 325418)

	-- Spinemaw Staghorn
	self:Log("SPELL_CAST_SUCCESS", "StimulateRegeneration", 340544)
	self:Log("SPELL_CAST_START", "StimulateResistance", 326046)
	self:Log("SPELL_CAST_SUCCESS", "StimulateResistanceSuccess", 326046)

	-- Spinemaw Gorger
	self:Log("SPELL_CAST_START", "AcidGlobule", 326021)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- Tirnenn Villager

function mod:BewilderingPollen(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alarm")
end

do
	local function printTarget(self, name, guid)
		self:TargetMessage(322486, "yellow", name)
		self:PlaySound(322486, "alert", nil, name)
	end

	function mod:Overgrowth(args)
		self:GetUnitTarget(printTarget, 0.4, args.sourceGUID)
	end
end

-- Drust Harvester

function mod:HarvestEssence(args)
	self:Message(args.spellId, "orange", CL.casting:format(args.spellName))
	self:PlaySound(args.spellId, "alert")
end

-- Drust Soulcleaver

do
	local prev = 0
	function mod:HandOfThrosApplied(args)
		if self:MobId(args.sourceGUID) == 172991 then
			-- this version of the mob only RP fights and cannot be engaged by players
			return
		end
		local t = args.time
		if t - prev > 1.5 then
			local unit = self:UnitTokenFromGUID(args.destGUID)
			if unit and UnitAffectingCombat(unit) then
				prev = t
				self:Message(args.spellId, "red", CL.on:format(args.spellName, args.destName))
				self:PlaySound(args.spellId, "alert")
			end
		end
	end
end

do
	local prev = 0
	function mod:SoulSplit(args)
		if self:MobId(args.sourceGUID) == 172991 then
			-- this version of the mob only RP fights and cannot be engaged by players
			return
		end
		local t = args.time
		if t - prev > 1.5 and self:Tank() then
			local unit = self:UnitTokenFromGUID(args.sourceGUID)
			if unit and UnitAffectingCombat(unit) then
				prev = t
				self:Message(args.spellId, "purple")
				self:PlaySound(args.spellId, "alarm")
			end
		end
	end
end

function mod:SoulSplitApplied(args)
	-- Some mobs fight each other before being engaged by players.
	-- Only show messages when the target is a player controlled unit.
	if self:Dispeller("magic", nil, args.spellId) and self:Player(args.destFlags) then
		self:StackMessageOld(args.spellId, args.destName, args.amount, "yellow")
		self:PlaySound(args.spellId, "info", nil, args.destName)
	end
end

-- Drust Boughbreaker

function mod:FuriousThrashing(args)
	self:Message(args.spellId, "red", CL.percent:format(50, args.spellName))
	self:PlaySound(args.spellId, "alarm")
end

function mod:BrambleBurst(args)
	self:Message(args.spellId, "orange")
	self:PlaySound(args.spellId, "alert")
end

-- Mistveil Defender

function mod:MistWard(args)
	self:Message(args.spellId, "cyan")
	self:PlaySound(args.spellId, "info")
end

function mod:Expel(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alarm")
end

-- XXX remove when 11.0.2 is live everywhere
do
	local prev = 0
	function mod:SpearFlurry(args)
		local t = args.time
		if t - prev > 1.5 then
			local unit = self:UnitTokenFromGUID(args.sourceGUID)
			if unit and UnitAffectingCombat(unit) then
				prev = t
				self:Message(args.spellId, "purple")
				self:PlaySound(args.spellId, "alert")
			end
		end
	end
end

-- Mistveil Gorgegullet

do
	local timer

	function mod:PoisonousSecretions(args)
		if timer then
			self:CancelTimer(timer)
		end
		self:Message(args.spellId, "red")
		self:PlaySound(args.spellId, "alarm")
		--self:CDBar(args.spellId, 16) -- TODO get timer
		timer = self:ScheduleTimer("MistveilGorgegulletDeath", 30)
	end

	function mod:CrushingLeap(args)
		if timer then
			self:CancelTimer(timer)
		end
		self:Message(args.spellId, "orange")
		self:PlaySound(args.spellId, "alert")
		--self:CDBar(args.spellId, 16) -- TODO get timer
		timer = self:ScheduleTimer("MistveilGorgegulletDeath", 30)
	end

	function mod:TongueLashing(args)
		if timer then
			self:CancelTimer(timer)
		end
		self:Message(args.spellId, "purple")
		self:PlaySound(args.spellId, "alert")
		self:CDBar(args.spellId, 9) -- TODO check
		timer = self:ScheduleTimer("MistveilGorgegulletDeath", 30)
	end

	function mod:MistveilGorgegulletDeath(args)
		if timer then
			self:CancelTimer(timer)
			timer = nil
		end
		self:StopBar(340304) -- Poisonous Secretions
		self:StopBar(340305) -- Crushing Leap
		self:StopBar(340300) -- Tongue Lashing
	end
end

-- Mistveil Guardian

function mod:AnimaSlash(args)
	self:Message(args.spellId, "purple")
	self:PlaySound(args.spellId, "alert")
end

do
	local prev = 0
	function mod:BuckingRampage(args)
		local t = args.time
		if t - prev > 1.5 then
			prev = t
			self:Message(args.spellId, "red")
			self:PlaySound(args.spellId, "alarm")
		end
	end
end

-- Mistveil Matriarch

do
	local timer

	function mod:PoolOfRadiance(args)
		if timer then
			self:CancelTimer(timer)
		end
		self:Message(args.spellId, "cyan")
		self:PlaySound(args.spellId, "info")
		self:CDBar(args.spellId, 27.9)
		timer = self:ScheduleTimer("MistveilMatriarchDeath", 30)
	end

	function mod:RadiantBreath(args)
		if timer then
			self:CancelTimer(timer)
		end
		self:Message(args.spellId, "orange")
		self:PlaySound(args.spellId, "alarm")
		self:CDBar(args.spellId, 12.1)
		timer = self:ScheduleTimer("MistveilMatriarchDeath", 30)
	end

	function mod:ShredArmor(args)
		if timer then
			self:CancelTimer(timer)
		end
		self:Message(args.spellId, "purple")
		self:PlaySound(args.spellId, "alert")
		self:CDBar(args.spellId, 13.4)
		timer = self:ScheduleTimer("MistveilMatriarchDeath", 30)
	end

	function mod:MistveilMatriarchDeath(args)
		if timer then
			self:CancelTimer(timer)
			timer = nil
		end
		self:StopBar(340189) -- Pool of Radiance
		self:StopBar(340160) -- Radiant Breath
		self:StopBar(340208) -- Shred Armor
	end
end

-- Mistveil Nightblossom

do
	local timer

	function mod:TripleBite(args)
		if timer then
			self:CancelTimer(timer)
		end
		self:Message(args.spellId, "purple")
		self:PlaySound(args.spellId, "alert")
		self:CDBar(args.spellId, 12.1)
		timer = self:ScheduleTimer("MistveilNightblossomDeath", 30)
	end

	do
		local playerList = {}

		function mod:PoisonousDischarge(args)
			playerList = {}
			if timer then
				self:CancelTimer(timer)
			end
			self:Message(args.spellId, "orange")
			self:PlaySound(args.spellId, "alarm")
			--self:CDBar(args.spellId, 16) -- TODO get timer
			timer = self:ScheduleTimer("MistveilNightblossomDeath", 30)
		end

		function mod:PoisonousDischargeApplied(args)
			if self:Dispeller("poison", nil, 340279) then
				playerList[#playerList + 1] = args.destName
				self:PlaySound(340279, "info", nil, playerList)
				self:TargetsMessage(340279, "yellow", playerList, 5)
			end
		end
	end

	function mod:MistveilNightblossomDeath(args)
		if timer then
			self:CancelTimer(timer)
			timer = nil
		end
		self:StopBar(340289) -- Triple Bite
		self:StopBar(340279) -- Poisonous Discharge
	end
end

-- Mistveil Shaper

function mod:BramblethornCoat(args)
	self:Message(args.spellId, "orange", CL.casting:format(args.spellName))
	self:PlaySound(args.spellId, "alert")
end

-- Mistveil Stalker

function mod:MistveilTear(args)
	self:TargetMessage(args.spellId, "yellow", args.destName)
	self:PlaySound(args.spellId, "alert", nil, args.destName)
end

-- Mistveil Stinger

function mod:AnimaInjectionApplied(args)
	if self:Dispeller("magic") then
		self:TargetMessage(args.spellId, "yellow", args.destName)
		self:PlaySound(args.spellId, "info", nil, args.destName)
	end
end

-- Mistveil Tender

function mod:NourishTheForest(args)
	self:Message(args.spellId, "orange", CL.casting:format(args.spellName))
	self:PlaySound(args.spellId, "alert")
end

function mod:NourishTheForestSuccess(args)
	if self:Dispeller("magic", true, args.spellId) then
		self:Message(args.spellId, "red")
		self:PlaySound(args.spellId, "warning")
	end
end

-- Spinemaw Acidgullet

function mod:VolatileAcidApplied(args)
	self:TargetMessage(args.spellId, "orange", args.destName)
	self:PlaySound(args.spellId, "alert", nil, args.destName)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, nil, nil, "Volatile Acid")
	end
end

-- Spinemaw Staghorn

function mod:StimulateRegeneration(args)
	self:Message(args.spellId, "red", CL.casting:format(args.spellName))
	self:PlaySound(args.spellId, "alert")
end

function mod:StimulateResistance(args)
	self:Message(args.spellId, "orange", CL.casting:format(args.spellName))
	self:PlaySound(args.spellId, "alert")
end

function mod:StimulateResistanceSuccess(args)
	if self:Dispeller("magic", true, args.spellId) then
		self:Message(args.spellId, "red")
		self:PlaySound(args.spellId, "warning")
	end
end

-- Spinemaw Gorger

do
	local prev = 0
	function mod:AcidGlobule(args)
		local t = args.time
		if t - prev > 2 then
			prev = t
			self:Message(args.spellId, "yellow")
			self:PlaySound(args.spellId, "alarm")
		end
	end
end
