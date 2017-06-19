local mod	= DBM:NewMod("ArtifactHealer", "DBM-Challenges", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 84 $"):sub(12, -3))
mod:SetZone()--Healer (1710), Tank (1698), DPS (1703-The God-Queen's Fury), DPS (Fel Totem Fall)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED 235984 237188",
	"SPELL_AURA_APPLIED_DOSE 235833",
	"UNIT_DIED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1 boss2 boss3 boss4 boss5",--need all 5?
--	"SCENARIO_UPDATE"
)
mod.noStatistics = true
--Notes:
--TODO, all. mapids, mob iDs, win event to stop timers (currently only death event stops them)
--Healer
-- Need ignite soul equiv name/ID.
-- Need fear name/Id

local warnArcaneBlitz			= mod:NewStackAnnounce(235833, 2)

local specWarnManaSling			= mod:NewSpecialWarningMoveTo(235984, nil, nil, nil, 1, 2)
local specWarnArcaneBlitz		= mod:NewSpecialWarningStack(235833, nil, 4, nil, nil, 1, 6)--Fine tune the numbers
local specWarnIgniteSoul		= mod:NewSpecialWarningYou(237188, nil, nil, nil, 3, 2)


--local timerEarthquakeCD		= mod:NewNextTimer(60, 237950, nil, nil, nil, 2)
local timerIgniteSoulCD			= mod:NewAITimer(25, 237188, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON)

local countdownIngiteSoul		= mod:NewCountdownFades("AltTwo9", 237188)

local voiceManaSling			= mod:NewVoice(235984)--findshelter
local voiceArcaneBlitz			= mod:NewVoice(235833)--stackhigh
local voiceIgniteSoul			= mod:NewVoice(237188)

mod:RemoveOption("HealthFrame")

--local started = false
--local activeBossGUIDS = {}

--[[
function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 234423 then
	
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 237950 then
		specWarnEarthquake:Show(args.sourceName)
		voiceEarthquake:Play("aesoon")
		timerEarthquakeCD:Start()
	elseif spellId == 242730 then
		warnFelShock:Show()
	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 235833 then
		local amount = args.amount or 1
		if amount % 2 == 0 then
			if amount >= 4 then
				specWarnArcaneBlitz:Show(amount)
				voiceArcaneBlitz:Play("stackhigh")
			else
				warnArcaneBlitz:Show(args.destName, amount)
			end
		end
	elseif spellId == 235984 and args:IsPlayer() then
		specWarnManaSling:Show(DBM_ALLY)
		voiceManaSling:Play("findshelter")
	elseif spellId == 237188 then
		countdownIngiteSoul:Start()
		specWarnIgniteSoul:Show()
		voiceIgniteSoul:Play("targetyou")
		timerIgniteSoulCD:Start()
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	if args.destGUID == UnitGUID("player") then--Solo scenario, a player death is a wipe
		--started = false
		--table.wipe(activeBossGUIDS)
		timerIgniteSoulCD:Stop()
	end
	--local cid = self:GetCIDFromGUID(args.destGUID)
--	if cid == 177933 then--Variss

--	end
end

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, spellGUID)
	local spellId = tonumber(select(5, strsplit("-", spellGUID)), 10)
	if spellId == 234428 then--Summon Tormenting Eye

	end
end

function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	for i = 1, 5 do
		local unitID = "boss"..i
		local unitGUID = UnitGUID(unitID)
		if UnitExists(unitID) and not activeBossGUIDS[unitGUID] then
			local bossName = UnitName(unitID)
			local cid = self:GetUnitCreatureId(unitID)
			--Tank
			if cid == 177933 then--Variss (Tank/Kruul Scenario)
				started = true
				timerTormentingEyeCD:Start(1)--3.8?
				timerHolyWardCD:Start(1)--8?
				timerDrainLifeCD:Start(1)--9?
				timerNetherAbberationCD:Start(1)
			elseif cid == 117230 then--Tugar Bloodtotem (DPS Fel Totem Fall)
				started = true
				timerFelRuptureCD:Start(7.5)
				timerEarthquakeCD:Start(20.5)
				timerFelSurgeCD:Start(62)--Correct place to do it?
			end
		end
	end
end

function mod:SCENARIO_UPDATE(newStep)
	local diffID, currWave, maxWave, duration = C_Scenario.GetProvingGroundsInfo()
	if diffID > 0 then
		started = true
		countdownTimer:Cancel()
		countdownTimer:Start(duration)
		if DBM.Options.AutoRespond then--Use global whisper option
			self:RegisterShortTermEvents(
				"CHAT_MSG_WHISPER"
			)
		end
	elseif started then
		started = false
		countdownTimer:Cancel()
		self:UnregisterShortTermEvents()
	end
end

local mode = {
	[1] = CHALLENGE_MODE_MEDAL1,
	[2] = CHALLENGE_MODE_MEDAL2,
	[3] = CHALLENGE_MODE_MEDAL3,
	[4] = L.Endless,
}
function mod:CHAT_MSG_WHISPER(msg, name, _, _, _, status)
	if status ~= "GM" then--Filter GMs
		name = Ambiguate(name, "none")
		local diffID, currWave, maxWave, duration = C_Scenario.GetProvingGroundsInfo()
		local message = L.ReplyWhisper:format(UnitName("player"), mode[diffID], currWave)
		if msg == "status" then
			SendChatMessage(message, "WHISPER", nil, name)
		elseif self:AntiSpam(20, name) then--If not "status" then auto respond only once per 20 seconds per person.
			SendChatMessage(message, "WHISPER", nil, name)
		end
	end
end
--]]
