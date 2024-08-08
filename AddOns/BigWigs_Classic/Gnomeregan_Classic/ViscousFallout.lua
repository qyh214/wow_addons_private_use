--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Viscous Fallout Discovery", 90)
if not mod then return end
mod:RegisterEnableMob(220007) -- Viscous Fallout
mod:SetEncounterID(2928)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Viscous Fallout"
	L.desiccated_fallout = "Desiccated Fallout" -- NPC ID 216810
end

--------------------------------------------------------------------------------
-- Initialization
--

local desiccatedFalloutMarker = mod:AddMarkerOption(true, "npc", 8, "desiccated_fallout", 8, 7, 6) -- Desiccated Fallout
function mod:GetOptions()
	return {
		434358, -- Summon Irradiated Goo
		desiccatedFalloutMarker,
		433546, -- Radiation Burn
		434434, -- Sludge
	},nil,{
		[434358] = CL.adds, -- Summon Irradiated Goo (Adds)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
	-- Delayed for custom locale
	desiccatedFalloutMarker = mod:AddMarkerOption(true, "npc", 8, "desiccated_fallout", 8, 7, 6) -- Desiccated Fallout
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "SummonIrradiatedGooStart", 434358)
	self:Log("SPELL_CAST_SUCCESS", "SummonIrradiatedGoo", 434358)
	self:Log("SPELL_AURA_APPLIED", "ToxicEmissionApplied", 434399)
	self:Log("SPELL_CAST_START", "RadiationBurnStart", 433546)
	self:Log("SPELL_CAST_SUCCESS", "RadiationBurn", 433546)
	self:Log("SPELL_CAST_SUCCESS", "Sludge", 434434)
	self:Log("SPELL_AURA_APPLIED", "SludgeDamage", 434433)
	self:Log("SPELL_PERIODIC_DAMAGE", "SludgeDamage", 434433)
	self:Log("SPELL_PERIODIC_MISSED", "SludgeDamage", 434433)
end

function mod:OnEngage()
	self:CDBar(434358, 11, CL.adds) -- Summon Irradiated Goo
	self:CDBar(434434, 15.8) -- Sludge
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local gooCollector, gooIcon, falloutIcon = {}, 8, 8
	function mod:GooMarking(_, unit, guid)
		if gooCollector[guid] then
			self:CustomIcon(desiccatedFalloutMarker, unit, gooCollector[guid])
		end
	end

	function mod:SummonIrradiatedGooStart(args)
		self:Message(args.spellId, "cyan", CL.incoming:format(CL.adds))
		self:CDBar(args.spellId, 63, CL.adds)
		self:PlaySound(args.spellId, "long")
	end

	function mod:SummonIrradiatedGoo(args)
		gooCollector = {}
		gooIcon, falloutIcon = 8, 8
		self:RegisterTargetEvents("GooMarking")
	end

	function mod:ToxicEmissionApplied(args)
		if not gooCollector[args.destGUID] then -- Mark Irradiated Goo
			gooCollector[args.destGUID] = gooIcon
			gooIcon = gooIcon - 1
			local unit = self:GetUnitIdByGUID(args.destGUID)
			if unit then
				self:CustomIcon(desiccatedFalloutMarker, unit, gooCollector[args.destGUID])
			end
		end
	end

	function mod:RadiationBurnStart(args)
		if not gooCollector[args.sourceGUID] then -- Mark Desiccated Fallout
			gooCollector[args.sourceGUID] = falloutIcon
			falloutIcon = falloutIcon - 1
		end
		local icon = self:GetIconTexture(gooCollector[args.sourceGUID])
		self:Message(args.spellId, "orange", icon.. CL.casting:format(args.spellName))
		if self:Interrupter() then
			self:PlaySound(args.spellId, "info")
		end
	end
end

function mod:RadiationBurn(args)
	self:Message(args.spellId, "orange", CL.on_group:format(args.spellName))
	self:PlaySound(args.spellId, "warning")
end

function mod:Sludge(args)
	self:Message(args.spellId, "red")
	self:Bar(args.spellId, 16.1)
	self:PlaySound(args.spellId, "alarm")
end

do
	local prev = 0
	function mod:SludgeDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 3 then
			prev = args.time
			self:PersonalMessage(434434, "underyou")
			self:PlaySound(434434, "underyou")
		end
	end
end
