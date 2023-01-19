local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
local uClass = string.lower(select(2, UnitClass('player')))
RSA.Monitor = {}

local curTracking = {}
local curThrottled = {}
local curTimers = {}
local messageCache = {}
local cacheTagSpellName = {}
local cacheTagSpellLink = {}
local replacements = {}
local missTypes = {
	'ABSORB',
	'BLOCK',
	'DEFLECT',
	'DODGE',
	'EVADE',
	'IMMUNE',
	'MISS',
	'PARRY',
	'REFLECT',
	'RESIST',
}

local function CommCheck(currentSpell)
	-- Track group announced spells using RSA.Comm (AddonMessages)
	local canAnnounce = true
	if currentSpell.comm then
		if RSA.Comm.groupAnnouncer then
			canAnnounce = true
			if RSA.Comm.groupAnnouncer == tonumber(RSA.db.global.ID) then -- This is us, continue as normal.
				canAnnounce = true
			else -- Someone else is announcing.
				canAnnounce = false
			end
		else -- No Group, continue as normal.
			canAnnounce = true
		end
	end
	return canAnnounce
end

local function BuildMessageCache(currentSpell, monitorData, event, fakeEvent)
	local currentSpellData = currentSpell.events[event]
	if fakeEvent then
		currentSpellData = currentSpell.events[fakeEvent]
	end

	-- Build Cache of valid messages
	-- We store empty strings when users blank a default message so we know not to use the default. An empty string can also be stored when a user deletes extra messages.
	-- We need to validate the list of messages so when we pick a message at random, we don't accidentally pick the blanked message.
	local messageCacheProfile = messageCache[monitorData]
	if not messageCacheProfile then
		messageCacheProfile = {}
		messageCache[monitorData] = {}
	end
	local validMessages = messageCacheProfile[currentSpellData]
	if not validMessages then
		validMessages = {}
		for i = 1, #currentSpellData.messages do
			if currentSpellData.messages[i] ~= '' then
				validMessages[i] = currentSpellData.messages[i]
			end
		end
		messageCache[monitorData][currentSpellData] = validMessages
	end
	if #validMessages == 0 then return end
	local message = validMessages[math.random(#validMessages)]
	if not message then return end
	message = gsub(message,'%%','%%%%')
	return message
end

function RSA:WipeMessageCache()
	wipe(messageCache)
end

function RSA.Monitor.UpdateTimer()
	for k in pairs(curTimers) do
		if curTimers[k].startTime < GetTime() then
			local fakeEvent = curTimers[k].fakeEvent
			local profileName = curTimers[k].profileName
			local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlag, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, ex1, ex2, ex3, ex4, ex5, ex6, ex7, ex8 = unpack(curTimers[k].logData)
			RSA.Monitor.ProcessSpell(profileName, nil, nil, nil, timestamp, fakeEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlag, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, ex1, ex2, ex3, ex4, ex5, ex6, ex7, ex8)
			curTimers[k] = nil
		end
	end
end

local function CreateTimer(currentSpell, profileName, logData, fakeEvent)
	-- Called in ProcessSpell when we check a profile for fake events
	-- Stores data from the initiating spell event in a table since we can't pass arguments with C_Timer
	-- I think this is better than using OnUpdate though it may look worse.
	if fakeEvent == 'RSA_END_TIMER' then
		local timerDuration = currentSpell.events['RSA_END_TIMER'].duration or 0
		if timerDuration <= 0 then return end
		if not curTimers[profileName] then
			curTimers[profileName] = {
				fakeEvent = 'RSA_END_TIMER',
				profileName = profileName,
				logData = logData,
				startTime = GetTime(),
				duration = timerDuration,
			}
			C_Timer.After(curTimers[profileName].duration, RSA.Monitor.UpdateTimer)
		end
	end
end

local function Throttle(currentSpell, profileName)
	local throttle = currentSpell.throttle or nil
	if throttle then
		if throttle <= 0 then
			return false
		end
		if not curThrottled[profileName] then
			curThrottled[profileName] = GetTime()
			return false
		elseif curThrottled[profileName] + throttle >= GetTime() then
			return true
		else
			curThrottled[profileName] = GetTime()
			return false
		end
	end
	return false
end

local bor,band = bit.bor, bit.band -- get a local reference to some bitlib functions for faster lookups
local CL_OBJECT_PLAYER_MINE = bor(COMBATLOG_OBJECT_TYPE_PLAYER,COMBATLOG_OBJECT_AFFILIATION_MINE) -- construct a bitmask for a player controlled by me
function RSA.IsMe(unitFlags)
	if unitFlags == "Me" then return true end
	if unitFlags == true then return true end
	if unitFlags == false then return false end
	if band(CL_OBJECT_PLAYER_MINE,unitFlags) == CL_OBJECT_PLAYER_MINE then
		return true
	end
end

local function MatchUnit(compareUnit, unitGUID, unitFlags, destRaidFlags)
	local flag
	if compareUnit == 'party' then
		flag = COMBATLOG_OBJECT_AFFILIATION_PARTY
	elseif compareUnit == 'raid' then
		flag = COMBATLOG_OBJECT_AFFILIATION_RAID
	end
	if flag then
		if bit.band(flag, unitFlags) == flag then
			return true
		end
	end

	--TODO support raid flags for target marks for additional dest units for custom spells
	if type(compareUnit) == 'table' then
		for i = 1, #compareUnit do
			if unitGUID == UnitGUID(compareUnit[i]) then
				return true
			end
		end
	end

	return false
end

function RSA.Monitor.ProcessSpell(profileName, extraSpellID, extraSpellName, extraSchool, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlag, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, ex1, ex2, ex3, ex4, ex5, ex6, ex7, ex8)

	local currentSpell = RSA.db.profile[uClass][profileName] or nil
	if not currentSpell then return end
	if not currentSpell.events[event] then return end

	if currentSpell.events[event].targetIsMe and not RSA.IsMe(destFlags) then return end
	if currentSpell.events[event].targetNotMe and RSA.IsMe(destFlags) then return end
	if currentSpell.events[event].sourceIsMe and not RSA.IsMe(sourceFlags) then return end

	-- TODO: Iterate customSourceUnits, see spell Reflect setup
	if not currentSpell.events[event].customSourceUnit and not RSA.IsMe(sourceFlags) then return end
	if currentSpell.events[event].dest then
		-- TODO currentSpell.events[event].dest is a table or valid units
		if not MatchUnit(currentSpell.events[event].dest, destGUID, destFlags, destRaidFlags) then return end
	end

	-- TODO: handle customDestUnit and parse it as well as customSourceUnit for valid units.

	if Throttle(currentSpell, profileName) then return end

	local fakeEvent
	if event == 'SPELL_MISSED' then
		if ex1 == 'IMMUNE' then
			fakeEvent = 'RSA_SPELL_IMMUNE'
		end
		if ex1 == 'REFLECT' then
			fakeEvent = 'RSA_SPELL_REFLECT'
		end
	end

	if currentSpell.events['RSA_END_TIMER'] and event ~= 'RSA_END_TIMER' then
		local logData = {CombatLogGetCurrentEventInfo()}
		CreateTimer(currentSpell, profileName, logData, 'RSA_END_TIMER')
	end

	if currentSpell.events['SPELL_CAST_START'] then
		if UnitExists('mouseover') then
			destName = UnitName('mouseover')
			destGUID = UnitGUID('mouseover')
		elseif UnitExists('target') then
			destName = UnitName('target')
			destGUID = UnitGUID('target')
		end
	end

	local message = BuildMessageCache(currentSpell, profileName, event, fakeEvent)
	if not message then return end

	-- Build Spell Name and Link Cache
	local tagSpellName = cacheTagSpellName[spellID]
	if not tagSpellName then
		tagSpellName = RSA.GetSpellInfo(spellID)
		cacheTagSpellName[spellID] = tagSpellName
	end

	local tagSpellLink = cacheTagSpellLink[spellID]
	if not tagSpellLink then
		tagSpellLink = GetSpellLink(spellID)
		cacheTagSpellLink[spellID] = tagSpellLink
	end

	if currentSpell.events[event].uniqueSpellID then -- Replace cached data with 'real' spell name/link to announce the expected spell.
		local parentSpell = currentSpell.spellID

		tagSpellName = RSA.GetSpellInfo(parentSpell)
		cacheTagSpellName[spellID] = tagSpellName

		tagSpellLink = GetSpellLink(parentSpell)
		cacheTagSpellLink[spellID] = tagSpellLink
	end

	-- Trim Server Names
	local longName = destName
	if RSA.db.profile.general.globalAnnouncements.removeServerNames == true then
		if destName and destGUID then
			local _, _, _, _, _, _, _, realmName = GetPlayerInfoByGUID(destGUID)
			if realmName then
					destName = gsub(destName, '-'..realmName, '')
			end
		end
	end

	-- Build Tag replacements
	wipe(replacements)
	replacements['[SPELL]'] = tagSpellName
	replacements['[LINK]'] = tagSpellLink
	local tagReplacements = currentSpell.events[event].tags or {}
	-- TODO: Add fallbacks in case people try to enable tags where there is no appropriate replacement.
	if destName then
		if tagReplacements.TARGET then replacements['[TARGET]'] = destName end
	end
	if tagReplacements.SOURCE then replacements['[SOURCE]'] = sourceName end
	if tagReplacements.AMOUNT then replacements['[AMOUNT]'] = ex1 end
	if tagReplacements.EXTRA then
		local name = cacheTagSpellName[extraSpellID]
		if not name then
			name = RSA.GetSpellInfo(extraSpellID)
			cacheTagSpellName[extraSpellID] = name
		end
		local link = cacheTagSpellLink[extraSpellID]
		if not link then
			link = GetSpellLink(extraSpellID)
			cacheTagSpellLink[extraSpellID] = link
		end
		replacements['[EXTRA]'] = name
		replacements['[EXTRALINK]'] = link
	end

	if tagReplacements.MISSTYPE then

		if RSA.db.profile.general.replacements.missType.useGenericReplacement == true then
			for i = 1,#missTypes do
				if ex1 == missTypes[i] then
					replacements['[MISSTYPE]'] = RSA.db.profile.general.replacements.missType.genericReplacementString
				end
			end
		else
			replacements['[MISSTYPE]'] = RSA.db.profile.general.replacements.missType[string.lower(ex1)]
		end
	end

	if currentSpell.events[event].channels.personal == true then
		if currentSpell.events[event].groupRequired then -- Used in Mage Teleports, only locally announces if you are in a group.
			if not (GetNumSubgroupMembers() > 0 or GetNumGroupMembers() > 0) then return end
		end
		RSA.SendMessage.LibSink(gsub(message, '.%a+.', replacements))
	end

	if currentSpell.comm then -- Track group announced spells using RSA.Comm (AddonMessages)
		if not CommCheck(currentSpell) then return end
		--Local messages can always go through, so only check this after sending the local message.
	end

	if currentSpell.events[event].channels.yell == true then
		RSA.SendMessage.Yell(gsub(message, '.%a+.', replacements))
	end
	if currentSpell.events[event].channels.whisper == true and RSA.Whisperable(destFlags) then --UnitExists(longName) and RSA.Whisperable(destFlags) then
		RSA.SendMessage.Whisper(message, longName, replacements, destName)
	end
	if currentSpell.events[event].channels.say == true then
		RSA.SendMessage.Say(gsub(message, '.%a+.', replacements))
	end
	if currentSpell.events[event].channels.emote == true then
		RSA.SendMessage.Emote(gsub(message, '.%a+.', replacements))
	end

	local announced = false
	if currentSpell.events[event].channels.party == true then
		if RSA.SendMessage.Party(gsub(message, '.%a+.', replacements)) == true then announced = true end
	end
	if currentSpell.events[event].channels.raid == true then
		if RSA.SendMessage.Raid(gsub(message, '.%a+.', replacements)) == true then announced = true end
	end
	if currentSpell.events[event].channels.instance == true then
		if RSA.SendMessage.Instance(gsub(message, '.%a+.', replacements)) == true then announced = true end
	end
	if currentSpell.events[event].channels.smartGroup == true and announced == false then
		RSA.SendMessage.SmartGroup(gsub(message, '.%a+.', replacements))
	end

end

local function FutureEventTracking()
	local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlag, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, ex1, ex2, ex3, ex4, ex5, ex6, ex7, ex8 = CombatLogGetCurrentEventInfo()
	for k in pairs(curTracking) do
		if curTracking[k].futureEvent == event then
			local profileName = curTracking[k].profileName
			local fullProfile = RSA.db.profile[uClass][curTracking[k].profileName] or nil
			local logData = curTracking[k].logData
			local passedEvent
			if logData.ex1 ~= ex1 then return end -- Do for all args, change into table and do in pairs k,v comparison
			if not fullProfile.events[event] then
				if not fullProfile.events[logData.fakeEvent] then
					return
				else
					passedEvent = logData.fakeEvent
				end
			else
				passedEvent = event
			end
			if fullProfile.events[event] == curTracking[k].currentEvent then return end
			--if fullProfile.events[event] == logData.event then return end
			RSA.Monitor.ProcessSpell(profileName, spellID, spellName, spellSchool, timestamp, passedEvent, hideCaster, destGUID, destName, destFlags, destRaidFlags, sourceGUID, sourceName, sourceFlags, sourceRaidFlag, logData.extraSpellID, logData.extraSpellName, logData.extraSpellSchool, ex1, ex2, ex3, ex4, ex5, ex6, ex7, ex8)
			curTracking[k] = nil
			local trackingFrame = _G['RSACombatLogTracker'] or nil
			if trackingFrame then
				trackingFrame:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
			end
		end
	end
end

local function SetupFutureEventData(profileName, extraSpellID, extraSpellName, extraSchool, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlag, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, ex1, ex2, ex3, ex4, ex5, ex6, ex7, ex8)
	local currentSpell = RSA.db.profile[uClass][profileName] or nil
	if not currentSpell then return end
	for k in pairs(currentSpell.events) do
		if currentSpell.events[k] then
			--TODO: loop through monitorData for multiple matching profiles
			if currentSpell.events[k].trackFutureEvent then
				local futureEvent = currentSpell.events[k].trackFutureEvent
				local logData = {
					event = futureEvent.event or nil,
					fakeEvent = futureEvent.fakeEvent or nil,
					sourceGUID = futureEvent.sourceGUID or nil,
					sourceName = futureEvent.sourceName or nil,
					sourceFlags = futureEvent.sourceFlags or nil,
					sourceRaidFlag = futureEvent.sourceRaidFlag or nil,
					destGUID = futureEvent.destGUID or nil,
					destName = futureEvent.destName or nil,
					destFlags = futureEvent.destFlags or nil,
					destRaidFlags = futureEvent.destRaidFlags or nil,
					spellID = futureEvent.spellID or nil,
					spellName = futureEvent.spellName or nil,
					spellSchool = futureEvent.spellSchool or nil,
					ex1 = futureEvent.ex1 or nil,
					ex2 = futureEvent.ex2 or nil,
					ex3 = futureEvent.ex3 or nil,
					ex4 = futureEvent.ex4 or nil,
					ex5 = futureEvent.ex5 or nil,
					ex6 = futureEvent.ex6 or nil,
					ex7 = futureEvent.ex7 or nil,
					ex8 = futureEvent.ex8 or nil,
					extraSpellID = spellID or nil,
					extraSpellName = spellName or nil,
					extraSchool = spellSchool or nil,
				}
				if not curTracking[profileName] then
					curTracking[profileName] = {
						currentEvent = event,
						futureEvent = futureEvent.event,
						profileName = profileName,
						logData = logData,
					}
				end

				local trackingFrame = _G['RSACombatLogTracker'] or nil
				if not trackingFrame then RSA.Monitor.Start() end
				trackingFrame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
			end
		end
	end
end

local function HandleEvents()
	local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlag, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, ex1, ex2, ex3, ex4, ex5, ex6, ex7, ex8 = CombatLogGetCurrentEventInfo()

	local extraSpellID, extraSpellName, extraSchool = ex1, ex2, ex3

	local monitorData = RSA.monitorData[uClass][spellID]
	if not monitorData then
		if RSA.monitorData['utilities'][spellID] then
			monitorData = RSA.monitorData['utilities'][spellID]
		elseif RSA.monitorData['racials'][spellID] then
			monitorData = RSA.monitorData['racials'][spellID]
		else
			for k in pairs(RSA.monitorData.customCategories) do
				if RSA.monitorData.customCategories[k][spellID] then
					monitorData = RSA.monitorData.customCategories[k][spellID]
				end
			end
		end
	end

	if event == 'SPELL_DISPEL' or event == 'SPELL_STOLEN' then
		if not monitorData then
			spellID, extraSpellID = extraSpellID, spellID
			spellName, extraSpellName = extraSpellName, spellName
			spellSchool, extraSchool = extraSchool, spellSchool
			monitorData = RSA.monitorData[uClass][spellID]
		end
	end

	if not monitorData then return end
	if #monitorData > 1 then
		for i = 1, #monitorData do
			local profileName = monitorData[i]
			SetupFutureEventData(profileName, extraSpellID, extraSpellName, extraSchool, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlag, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, ex1, ex2, ex3, ex4, ex5, ex6, ex7, ex8)
			RSA.Monitor.ProcessSpell(profileName, extraSpellID, extraSpellName, extraSchool, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlag, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, ex1, ex2, ex3, ex4, ex5, ex6, ex7, ex8)
		end
	else
		local profileName = monitorData[1]
		SetupFutureEventData(profileName, extraSpellID, extraSpellName, extraSchool, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlag, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, ex1, ex2, ex3, ex4, ex5, ex6, ex7, ex8)
		RSA.Monitor.ProcessSpell(profileName, extraSpellID, extraSpellName, extraSchool, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlag, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, ex1, ex2, ex3, ex4, ex5, ex6, ex7, ex8)
	end
end

function RSA.Monitor.Start()
	local monitorFrame
	if not _G['RSACombatLogMonitor'] then
		monitorFrame = CreateFrame('Frame', 'RSACombatLogMonitor')
	end

	monitorFrame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	monitorFrame:SetScript('OnEvent', HandleEvents)

	local trackingFrame
	if not _G['RSACombatLogTracker'] then
		trackingFrame = CreateFrame('Frame', 'RSACombatLogTracker')
	end

	trackingFrame:SetScript('OnEvent', FutureEventTracking)
end

function RSA.Monitor.Stop()
	local monitorFrame = _G['RSACombatLogMonitor'] or nil
	if not monitorFrame then return end
	monitorFrame:SetScript('OnEvent', nil)
end


