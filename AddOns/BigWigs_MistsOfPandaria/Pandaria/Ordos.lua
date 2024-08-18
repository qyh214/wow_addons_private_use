
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ordos", -554, 861)
if not mod then return end
mod:RegisterEnableMob(72057)
mod.otherMenu = -424
mod.worldBoss = 72057

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_yell = "You will take my place on the eternal brazier."

	L.burning_soul_bar = "Explosions"
	L.burning_soul_self_bar = "You explode!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		144688, {144689, "FLASH", "PROXIMITY"}, 144692, 144695,
		"berserk",
	}
end

function mod:OnBossEnable()
	self:BossYell("Engage", L.engage_yell)

	self:Log("SPELL_CAST_START", "MagmaCrush", 144688)
	self:Log("SPELL_AURA_APPLIED", "BurningSoul", 144689)
	self:Log("SPELL_AURA_REMOVED", "BurningSoulRemoved", 144689)
	self:Log("SPELL_CAST_SUCCESS", "PoolOfFire", 144692)
	self:Log("SPELL_DAMAGE", "PoolOfFireDamage", 144694)
	self:Log("SPELL_MISSED", "PoolOfFireDamage", 144694)
	self:Log("SPELL_SUMMON", "AncientFlame", 144695)
	self:Log("SPELL_DAMAGE", "AncientFlameDamage", 144699)
	self:Log("SPELL_MISSED", "AncientFlameDamage", 144699)

	self:Death("Win", 72057) -- Ordos
end

function mod:OnEngage()
	self:Berserk(300) -- Eternal Agony
	self:Bar(144688, 10) -- Magma Crush
	self:Bar(144689, 23) -- Burning Soul
	self:Bar(144695, 44) -- Ancient Flame
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:MagmaCrush(args)
	self:MessageOld(args.spellId, "orange", nil, CL["casting"]:format(args.spellName))
	self:Bar(args.spellId, 12)
end

function mod:PoolOfFire(args)
	self:MessageOld(args.spellId, "yellow", "alarm")
	self:Bar(args.spellId, 32)
end

do
	local prev = 0
	function mod:PoolOfFireDamage(args)
		if self:Me(args.destGUID) then
			local t = GetTime()
			if t-prev > 4 then
				prev = t
				self:MessageOld(144692, "blue", "info", CL["underyou"]:format(args.spellName))
			end
		end
	end
end

function mod:AncientFlame(args)
	self:MessageOld(args.spellId, "yellow")
	self:Bar(args.spellId, 44)
end

do
	local prev = 0
	function mod:AncientFlameDamage(args)
		if self:Me(args.destGUID) then
			local t = GetTime()
			if t-prev > 4 then
				prev = t
				self:MessageOld(144695, "blue", "info", CL["you"]:format(args.spellName))
			end
		end
	end
end

do
	local coloredNames, burningSoulList, isOnMe, scheduled = mod:NewTargetList(), {}, nil, nil
	local function warnBurningSoul(spellId)
		mod:Bar(spellId, 24)
		mod:Bar(spellId, 10, L.burning_soul_bar)
		if isOnMe then
			mod:Bar(spellId, 10, L.burning_soul_self_bar)
		else
			mod:OpenProximity(spellId, 10, burningSoulList)
			mod:Bar(spellId, 10, L.burning_soul_bar)
		end
		for i,v in ipairs(burningSoulList) do
			coloredNames[i] = v
			burningSoulList[i] = nil
		end
		mod:TargetMessageOld(spellId, coloredNames, "orange", "alert", nil, nil, true)
		scheduled = nil
	end

	function mod:BurningSoulRemoved(args)
		self:CloseProximity(args.spellId)
		isOnMe = nil
	end

	function mod:BurningSoul(args)
		if self:Me(args.destGUID) then
			self:Flash(args.spellId)
			self:OpenProximity(args.spellId, 10)
			isOnMe = true
		end

		burningSoulList[#burningSoulList+1] = args.destName
		if not scheduled then
			scheduled = self:ScheduleTimer(warnBurningSoul, 0.1, args.spellId)
		end
	end
end

