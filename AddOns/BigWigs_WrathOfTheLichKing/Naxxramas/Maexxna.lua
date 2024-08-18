--------------------------------------------------------------------------------
-- Module declaration
--

local mod, CL = BigWigs:NewBoss("Maexxna", 533, 1603)
if not mod then return end
mod:RegisterEnableMob(15952)
mod:SetEncounterID(1116)
-- mod:SetRespawnTime(0) -- resets, doesn't respawn

--------------------------------------------------------------------------------
-- Locals
--

local poisonThrottle = {}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale()
if L then
	L.webspraywarn30sec = "Cocoons in 10 sec"
	L.webspraywarn20sec = "Cocoons! Spiders in 10 sec!"
	L.webspraywarn10sec = "Spiders! Spray in 10 sec!"
	L.webspraywarn5sec = "WEB SPRAY in 5 seconds!"

	L.enragewarn = "Frenzy - SQUISH SQUISH SQUISH!"
	L.enragesoonwarn = "Frenzy Soon - Bugsquatters out!"

	L.web_wrap = 28622 -- Web Wrap (use a different icon)
	L.web_wrap_icon = "spell_nature_earthbind"
	L.cocoons = "Cocoons"

	L.spiders = "Spiders"
	L.spiders_icon = "inv_misc_monsterspidercarapace_01"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{28741, "TANK"}, -- Poison Shock
		28776, -- Necrotic Poison
		29484, -- Web Spray
		"web_wrap", -- Web Spray
		"spiders",
		28747, -- Frenzy
	}, nil, {
		["web_wrap"] = L.cocoons, -- Web Wrap (Cocoons)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "PoisonShock", 28741, 54122)
	self:Log("SPELL_AURA_APPLIED", "NecroticPoison", 28776, 54121)
	self:Log("SPELL_AURA_APPLIED", "WebWrap", 28622)
	self:Log("SPELL_CAST_SUCCESS", "WebSpray", 29484, 54125)
	self:Log("SPELL_AURA_APPLIED", "Frenzy", 28747, 54123, 54124)
end

function mod:OnEngage()
	poisonThrottle = {}

	self:Message(29484, "yellow", CL.custom_start_s:format(self.displayName, self:SpellName(29484), 40), false)

	self:Bar(28741, 6) -- Poison Shock
	self:Bar("web_wrap", 20, L.cocoons, L.web_wrap_icon) -- Web Wrap
	self:Bar("spiders", 30, L.spiders, L.spiders_icon) -- Spiders
	self:Bar(29484, 40) -- Web Spray

	self:DelayedMessage("web_wrap", 10, "yellow", L.webspraywarn30sec, L.web_wrap_icon)
	self:DelayedMessage("web_wrap", 20, "orange", L.webspraywarn20sec, L.web_wrap_icon, "warning")
	self:DelayedMessage("spiders", 30, "yellow", L.webspraywarn10sec, L.spiders_icon, "alert")
	self:DelayedMessage(29484, 35, "yellow", L.webspraywarn5sec, 29484)

	self:RegisterEvent("UNIT_HEALTH")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:PoisonShock(args)
	self:Message(28741, "purple")
	self:CDBar(28741, 10)
end

function mod:NecroticPoison(args)
	-- Don't spam if someone is getting swarmed
	if args.time - (poisonThrottle[args.destName] or 0) > 3 then
		poisonThrottle[args.destName] = args.time
		-- I feel bad using hard checks, but everyone else doesn't care
		if self:Me(args.destGUID) or self:Healer() or self:Dispeller("poison") then
			self:TargetMessage(28776, "cyan", args.destName)
			self:PlaySound(28776, "info")
		end
	end
end

do
	local inCocoon = mod:NewTargetList()
	function mod:WebWrap(args)
		inCocoon[#inCocoon + 1] = args.destName
		self:TargetsMessageOld("web_wrap", "red", inCocoon, 0, L.cocoons, L.web_wrap_icon)
		-- "on me" is "Cocoons on YOU!" and I hate it.
		if self:Me(args.destGUID) then
			self:PlaySound("web_wrap", "alarm")
		end
	end
end

function mod:WebSpray(args)
	self:Message(29484, "red")
	self:PlaySound(29484, "info")
	self:Bar(29484, 40)
	self:DelayedMessage("web_wrap", 10, "yellow", L.webspraywarn30sec, L.web_wrap_icon)
	self:DelayedMessage("web_wrap", 20, "orange", L.webspraywarn20sec, L.web_wrap_icon, "warning")
	self:DelayedMessage("spiders", 30, "yellow", L.webspraywarn10sec, L.spiders_icon, "alert")
	self:DelayedMessage(29484, 35, "yellow", L.webspraywarn5sec, 29484)

	self:Bar("web_wrap", 20, L.cocoons, L.web_wrap_icon)
	self:Bar("spiders", 30, L.spiders, L.spiders_icon)
end

function mod:Frenzy(args)
	self:Message(28747, "red", L.enragewarn)
	self:PlaySound(28747, "long")
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 15952 then
		local hp = self:GetHealth(unit)
		if hp < 35 then
			if hp > 30 then
				self:Message(28747, "orange", L.enragesoonwarn)
				self:PlaySound(28747, "alarm")
			end
			self:UnregisterEvent(event)
		end
	end
end
