
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Hyjal Summit Trash", 534)
if not mod then return end
mod.displayName = CL.trash
mod:RegisterEnableMob(
	17772, -- Lady Jaina Proudmoore
	17852, -- Thrall
	17895 -- Ghoul
)

--------------------------------------------------------------------------------
-- Locals
--

local allianceWaveTimes = {127.5, 127.5, 127.5, 127.5, 127.5, 127.5, 127.5, 185}
local RWCwaveTimes = allianceWaveTimes
local KRwaveTimes = {135, 160, 190, 165, 140, 130, 195, 222}
local hordeWaveTimes = {135, 190, 190, 195, 140, 165, 195, 225}

local nextBoss = ""
local waveBar = ""
local currentWave = 0
local enemies = 0
local fmt = string.format

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.waves = "Wave Warnings"
	L.waves_desc = "Announce approximate warning messages for the next wave."

	L.ghoul = "Ghouls"
	L.fiend = "Crypt Fiends"
	L.abom = "Abominations"
	L.necro = "Necromancers"
	L.banshee = "Banshees"
	L.garg = "Gargoyles"
	L.wyrm = "Frost Wyrm"
	L.fel = "Fel Stalkers"
	L.infernal = "Infernals"
	L.one = "Wave %d! %d %s"
	L.two = "Wave %d! %d %s, %d %s"
	L.three = "Wave %d! %d %s, %d %s, %d %s"
	L.four = "Wave %d! %d %s, %d %s, %d %s, %d %s"
	L.five = "Wave %d! %d %s, %d %s, %d %s, %d %s, %d %s"
	L.barWave = "Wave %d spawn"

	L.waveInc = "Wave %d incoming!"
	L.message = "%s in ~%d sec!"
	L.waveMessage = "Wave %d in ~%d sec!"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"waves",
		"warmup",
	}
end

function mod:OnBossEnable()
	nextBoss = ""
	waveBar = ""
	currentWave = 0
	enemies = 0

	self:RegisterMessage("BigWigs_OnBossWin")

	self:RegisterEvent("GOSSIP_SHOW")
	self:RegisterMessage("BigWigs_BossComm")
	if self:Classic() then
		self:RegisterWidgetEvent(3093, "UpdateEnemies")
		self:RegisterWidgetEvent(3121, "UpdateWaves")
	else
		self:RegisterWidgetEvent(500, "UpdateEnemies")
		self:RegisterWidgetEvent(528, "UpdateWaves")
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:BigWigs_OnBossWin(_, module)
	if module.moduleName == "Rage Winterchill" then
		nextBoss = self:BossName(1578) -- Anetheron
		self:StopBar(CL.active) -- Boss kill triggers a Trash module reboot
	elseif module.moduleName == "Anetheron" then
		nextBoss = self:BossName(1579) -- Kaz'rogal
		self:StopBar(CL.active)
	elseif module.moduleName == "Kaz'rogal" then
		nextBoss = self:BossName(1580) -- Azgalor
		self:StopBar(CL.active)
	elseif module.moduleName == "Azgalor" then
		self:Disable()
	end
end

function mod:GOSSIP_SHOW()
	if self:GetGossipID(32918) then -- "My companions and I are with you, Lady Proudmoore."
		self:Sync("SummitNext", "Rage") -- Rage Winterchill is next
	elseif self:GetGossipID(32919) then -- "We are ready for whatever Archimonde might send our way, Lady Proudmoore."
		self:Sync("SummitNext", "Anetheron") -- Anetheron is next
	elseif self:GetGossipID(32920) then -- "Until we meet again, Lady Proudmoore."
		self:Sync("SummitNext", "Kazrogal") -- Kaz'rogal is next
	elseif self:GetGossipID(35378) then -- "I am with you, Thrall."
		self:Sync("SummitNext", "Kazrogal") -- Kaz'rogal is next
	elseif self:GetGossipID(35377) then -- "We have nothing to fear."
		self:Sync("SummitNext", "Azgalor") -- Azgalor is next
	else
		local tbl = self:GetGossipOptions()
		if tbl then
			for i = 1, #tbl do
				if tbl[i].name == "My companions and I are with you, Lady Proudmoore." or
				tbl[i].name == "We are ready for whatever Archimonde might send our way, Lady Proudmoore." or
				tbl[i].name == "Until we meet again, Lady Proudmoore." or
				tbl[i].name == "I am with you, Thrall." or
				tbl[i].name == "We have nothing to fear." then
					BigWigs:Error("Unknown gossip ID ".. tostring(tbl[i].gossipOptionID) .." with name: ".. tostring(tbl[i].name))
				end
			end
		end
	end
end

local function Restart(self, saveNextBoss)
	self:Reboot()
	self:Bar("warmup", 300, CL.active, "achievement_bg_returnxflags_def_wsg") -- XXX icon doesn't exist on classic
	nextBoss = saveNextBoss
end

function mod:UpdateEnemies(_, text)
	local enemiesStr = text:match("%d")
	if enemiesStr then
		local remaining = tonumber(enemiesStr)
		if remaining then
			enemies = remaining
			if remaining == 0 and currentWave == 0 then
				Restart(self, nextBoss) -- 0 enemies on wave 0? It's a wipe
			end
		end
	end
end

function mod:UpdateWaves(_, text)
	local waveStr = text:match("%d")
	if waveStr then
		local wave = tonumber(waveStr)
		if wave and wave > currentWave then
			currentWave = wave
			self:StopBar(CL.active) -- Starting at Thrall can fire with a 0 just before wave 1

			if nextBoss == "" then
				self:Sync("SummitNext", "None")
				return
			end

			local waveTime = 0
			if nextBoss == self:BossName(1577) then -- Rage Winterchill
				waveTime = RWCwaveTimes[wave]
				if wave == 1 then
					self:MessageOld("waves", "cyan", nil, fmt(L.one, wave, 10, L.ghoul), false)
				elseif wave == 2 then
					self:MessageOld("waves", "cyan", nil, fmt(L.two, wave, 10, L.ghoul, 2, L.fiend), false)
				elseif wave == 3 then
					self:MessageOld("waves", "cyan", nil, fmt(L.two, wave, 6, L.ghoul, 6, L.fiend), false)
				elseif wave == 4 then
					self:MessageOld("waves", "cyan", nil, fmt(L.three, wave, 6, L.ghoul, 4, L.fiend, 2, L.necro), false)
				elseif wave == 5 then
					self:MessageOld("waves", "cyan", nil, fmt(L.three, wave, 2, L.ghoul, 6, L.fiend, 4, L.necro), false)
				elseif wave == 6 then
					self:MessageOld("waves", "cyan", nil, fmt(L.two, wave, 6, L.ghoul, 6, L.abom), false)
				elseif wave == 7 then
					self:MessageOld("waves", "cyan", nil, fmt(L.three, wave, 4, L.ghoul, 4, L.necro, 4, L.abom), false)
				elseif wave == 8 then
					self:MessageOld("waves", "cyan", nil, fmt(L.four, wave, 6, L.ghoul, 4, L.fiend, 2, L.abom, 2, L.necro), false)
				end
			elseif nextBoss == self:BossName(1578) then -- Anetheron
				waveTime = allianceWaveTimes[wave]
				if wave == 1 then
					self:MessageOld("waves", "cyan", nil, fmt(L.one, wave, 10, L.ghoul), false)
				elseif wave == 2 then
					self:MessageOld("waves", "cyan", nil, fmt(L.two, wave, 4, L.abom, 8, L.ghoul), false)
				elseif wave == 3 then
					self:MessageOld("waves", "cyan", nil, fmt(L.three, wave, 4, L.necro, 4, L.fiend, 4, L.ghoul), false)
				elseif wave == 4 then
					self:MessageOld("waves", "cyan", nil, fmt(L.three, wave, 2, L.banshee, 6, L.fiend, 4, L.necro), false)
				elseif wave == 5 then
					self:MessageOld("waves", "cyan", nil, fmt(L.three, wave, 6, L.ghoul, 2, L.necro, 4, L.banshee), false)
				elseif wave == 6 then
					self:MessageOld("waves", "cyan", nil, fmt(L.three, wave, 2, L.abom, 4, L.necro, 6, L.ghoul), false)
				elseif wave == 7 then
					self:MessageOld("waves", "cyan", nil, fmt(L.four, wave, 4, L.abom, 4, L.fiend, 2, L.banshee, 2, L.ghoul), false)
				elseif wave == 8 then
					self:MessageOld("waves", "cyan", nil, fmt(L.five, wave, 4, L.abom, 3, L.fiend, 2, L.banshee, 2, L.necro, 3, L.ghoul), false)
				end
			elseif nextBoss == self:BossName(1579) then -- Kaz'rogal
				waveTime = KRwaveTimes[wave]
				if wave == 1 then
					self:MessageOld("waves", "cyan", nil, fmt(L.four, wave, 4, L.abom, 2, L.banshee, 4, L.ghoul, 2, L.necro), false)
				elseif wave == 2 then
					self:MessageOld("waves", "cyan", nil, fmt(L.two, wave, 4, L.ghoul, 10, L.garg), false)
				elseif wave == 3 then
					self:MessageOld("waves", "cyan", nil, fmt(L.three, wave, 6, L.fiend, 2, L.necro, 6, L.ghoul), false)
				elseif wave == 4 then
					self:MessageOld("waves", "cyan", nil, fmt(L.three, wave, 6, L.garg, 6, L.fiend, 2, L.necro), false)
				elseif wave == 5 then
					self:MessageOld("waves", "cyan", nil, fmt(L.three, wave, 4, L.ghoul, 4, L.necro, 6, L.abom), false)
				elseif wave == 6 then
					self:MessageOld("waves", "cyan", nil, fmt(L.two, wave, 8, L.garg, 1, L.wyrm), false)
				elseif wave == 7 then
					self:MessageOld("waves", "cyan", nil, fmt(L.three, wave, 6, L.ghoul, 4, L.abom, 1, L.wyrm), false)
				elseif wave == 8 then
					self:MessageOld("waves", "cyan", nil, fmt(L.five, wave, 6, L.ghoul, 2, L.fiend, 2, L.necro, 4, L.abom, 2, L.banshee), false)
				end
			elseif nextBoss == self:BossName(1580) then -- Azgalor
				waveTime = hordeWaveTimes[wave]
				if wave == 1 then
					self:MessageOld("waves", "cyan", nil, fmt(L.two, wave, 6, L.abom, 6, L.necro), false)
				elseif wave == 2 then
					self:MessageOld("waves", "cyan", nil, fmt(L.three, wave, 5, L.ghoul, 8, L.garg, 1, L.wyrm), false)
				elseif wave == 3 then
					self:MessageOld("waves", "cyan", nil, fmt(L.two, wave, 6, L.ghoul, 8, L.infernal), false)
				elseif wave == 4 then
					self:MessageOld("waves", "cyan", nil, fmt(L.two, wave, 6, L.fel, 8, L.infernal), false)
				elseif wave == 5 then
					self:MessageOld("waves", "cyan", nil, fmt(L.three, wave, 4, L.abom, 6, L.fel, 4, L.necro), false)
				elseif wave == 6 then
					self:MessageOld("waves", "cyan", nil, fmt(L.two, wave, 6, L.necro, 6, L.banshee), false)
				elseif wave == 7 then
					self:MessageOld("waves", "cyan", nil, fmt(L.four, wave, 2, L.ghoul, 2, L.fiend, 2, L.fel, 8, L.infernal), false)
				elseif wave == 8 then
					self:MessageOld("waves", "cyan", nil, fmt(L.five, wave, 4, L.fiend, 2, L.necro, 4, L.abom, 2, L.banshee, 4, L.fel), false)
				end
			else
				self:MessageOld("waves", "cyan", nil, fmt(L.waveInc, wave), false)
			end

			self:CancelDelayedMessage(fmt(L.message, nextBoss, 90))
			self:CancelDelayedMessage(fmt(L.message, nextBoss, 60))
			self:CancelDelayedMessage(fmt(L.message, nextBoss, 30))
			self:CancelDelayedMessage(fmt(L.waveMessage, wave, 90))
			self:CancelDelayedMessage(fmt(L.waveMessage, wave, 60))
			self:CancelDelayedMessage(fmt(L.waveMessage, wave, 30))
			self:StopBar(waveBar)

			if wave == 8 then
				self:DelayedMessage("waves", waveTime - 90, "yellow", fmt(L.message, nextBoss, 90))
				self:DelayedMessage("waves", waveTime - 60, "yellow", fmt(L.message, nextBoss, 60))
				self:DelayedMessage("waves", waveTime - 30, "orange", fmt(L.message, nextBoss, 30))
				waveBar = fmt(CL.incoming, nextBoss)
				self:CDBar("waves", waveTime, waveBar, "Spell_Fire_FelImmolation")
			else
				self:DelayedMessage("waves", waveTime - 90, "yellow", fmt(L.waveMessage, wave + 1, 90))
				self:DelayedMessage("waves", waveTime - 60, "yellow", fmt(L.waveMessage, wave + 1, 60))
				self:DelayedMessage("waves", waveTime - 30, "orange", fmt(L.waveMessage, wave + 1, 30))
				waveBar = fmt(L.barWave, wave + 1)
				self:CDBar("waves", waveTime, waveBar, "Spell_Holy_Crusade")
			end
		elseif wave and wave == 0 then
			currentWave = wave
			if enemies == 0 then -- It's a wipe
				Restart(self, nextBoss)
			else -- Boss spawned
				self:CancelDelayedMessage(fmt(L.message, nextBoss, 90))
				self:CancelDelayedMessage(fmt(L.message, nextBoss, 60))
				self:CancelDelayedMessage(fmt(L.message, nextBoss, 30))
				self:StopBar(waveBar)
			end
		end
	end
end

do
	local prev = 0
	function mod:BigWigs_BossComm(_, msg, data)
		if msg == "SummitNext" and data then
			if nextBoss == "" then
				if data == "Rage" then
					nextBoss = self:BossName(1577) -- Rage Winterchill
				elseif data == "Anetheron" then
					nextBoss = self:BossName(1578) -- Anetheron
				elseif data == "Kazrogal" then
					nextBoss = self:BossName(1579) -- Kaz'rogal
				elseif data == "Azgalor" then
					nextBoss = self:BossName(1580) -- Azgalor
				end
			else
				if data == "None" and (GetTime() - prev) > 2 then
					prev = GetTime()
					if nextBoss == self:BossName(1577) then -- Rage Winterchill
						self:Sync("SummitNext", "Rage")
					elseif nextBoss == self:BossName(1578) then -- Anetheron
						self:Sync("SummitNext", "Anetheron")
					elseif nextBoss == self:BossName(1579) then -- Kaz'rogal
						self:Sync("SummitNext", "Kazrogal")
					elseif nextBoss == self:BossName(1580) then -- Azgalor
						self:Sync("SummitNext", "Azgalor")
					end
				end
			end
		end
	end
end
