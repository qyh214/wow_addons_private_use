--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Razorscale", 603, 1639)
if not mod then return end
mod:RegisterEnableMob(
	33816, -- Expedition Defender
	33210, -- Expedition Commander
	33287, -- Expedition Engineer
	33259, -- Expedition Trapper
	33186  -- Razorscale
)
mod:SetEncounterID(BigWigsLoader.isWrath and 746 or 1139)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Locals
--

local count = 0
local stage = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.ground_trigger = "Move quickly! She won't remain grounded for long!"
	L.ground_message = "Razorscale Chained up!"
	L.air_message = "Takeoff!"

	L.harpoon = "Harpoons"
	L.harpoon_desc = "Announce when the harpoons are ready for use."
	L.harpoon_message = "Harpoon %d ready!"
	L.harpoon_trigger = "Harpoon Turret is ready for use!"
	L.harpoon_nextbar = "Harpoon %d"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		64021, -- Flame Breath
		64733, -- Devouring Flame
		"harpoon",
		62794, -- Harpooned
		64771, -- Fuse Armor
		"berserk",
	}
end

function mod:OnBossEnable()
	-- ENCOUNTER_END wasn't firing (for wipes)
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")
	self:Death("Win", 33186)

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")

	self:Log("SPELL_DAMAGE", "DevouringFlameDamage", 64733)
	self:Log("SPELL_MISSED", "DevouringFlameDamage", 64733)

	self:RegisterEvent("UNIT_HEALTH")
	self:Log("SPELL_CAST_SUCCESS", "WingBuffetCastEnd", 62666)
	self:Log("SPELL_AURA_APPLIED", "Harpooned", 62794)
	self:Log("SPELL_AURA_REMOVED", "HarpoonedOver", 62794)

	self:Log("SPELL_CAST_START", "FlameBreath", 64021)

	self:Log("SPELL_AURA_APPLIED", "FuseArmor", 64771)
	self:Log("SPELL_AURA_APPLIED_DOSE", "FuseArmor", 64771)
end

function mod:OnEngage()
	count = 0
	stage = 1
	self:Berserk(self:Classic() and 360 or 900)
	self:Bar("harpoon", 50, L.harpoon_nextbar:format(1), "INV_Spear_06")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg == L.ground_trigger then -- Grounded stage begins
		self:MessageOld("stages", "cyan", "long", L.ground_message, false)
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg)
	if msg == L.harpoon_trigger then -- Next harpoon ready
		count = count + 1
		self:MessageOld("harpoon", "yellow", "info", L.harpoon_message:format(count), "INV_Spear_06")
		if count < 4 then
			self:Bar("harpoon", 18, L.harpoon_nextbar:format(count+1), "INV_Spear_06")
		end
	end
end

do
	local prev = 0
	function mod:DevouringFlameDamage(args)
		if self:Me(args.destGUID) then
			local t = GetTime()
			if t-prev > 2 then
				prev = t
				self:MessageOld(args.spellId, "blue", "alarm", CL.underyou:format(args.spellName))
			end
		end
	end
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) ~= 33186 then return end -- Razorscale
	local hp = self:GetHealth(unit)
	if hp > 51 and hp < 56 then
		self:MessageOld("stages", "green", nil, CL.soon:format(CL.stage:format(2)), false)
		self:UnregisterEvent(event)
	end
end

function mod:WingBuffetCastEnd() -- Air stage begins again
	count = 0
	if stage == 1 then
		self:Bar("harpoon", 55, L.harpoon_nextbar:format(1), "INV_Spear_06")
		self:MessageOld("stages", "cyan", "long", L.air_message, false)
	end
end

function mod:Harpooned(args)
	count = 0
	self:Bar(args.spellId, 30)
end

function mod:HarpoonedOver(args)
	self:StopBar(args.spellName)
	local boss = self:GetUnitIdByGUID(args.destGUID)
	if boss and self:GetHealth(boss) < 50 then -- Stage 2 (Permanently grounded) begins
		stage = 2
		self:MessageOld("stages", "yellow", nil, CL.stage:format(2), false)
	end
end

function mod:FlameBreath(args)
	self:MessageOld(args.spellId, "yellow", "warning")
	if stage == 2 then
		self:CDBar(args.spellId, 21)
	end
end

function mod:FuseArmor(args)
	if self:Me(args.destGUID) or (self:Tank() and self:Tank(args.destName)) then
		local amount = args.amount or 1
		self:StackMessageOld(args.spellId, args.destName, amount, "orange", amount > 1 and "info")
	end
end
