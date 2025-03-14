local E = select(2, ...):unpack()
local P, CM = E.Party, E.Comm

local pairs, next, concat, tonumber, strmatch, strsplit, format, gsub, floor, abs = pairs, next, table.concat, tonumber, strmatch, strsplit, format, gsub, floor, abs
local GetTime = GetTime
local GetSpellCooldown = GetSpellCooldown or function(spellID)
	local spellCooldownInfo = C_Spell.GetSpellCooldown(spellID)
	if spellCooldownInfo then
		return spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.isEnabled and 1 or 0, spellCooldownInfo.modRate
	end
end
local GetSpellCharges = GetSpellCharges or function(spellID)
	local spellChargeInfo = C_Spell.GetSpellCharges(spellID)
	if spellChargeInfo then
		return spellChargeInfo.currentCharges, spellChargeInfo.maxCharges, spellChargeInfo.cooldownStartTime, spellChargeInfo.cooldownDuration, spellChargeInfo.chargeModRate
	end
end

local LibDeflate = LibStub("LibDeflate")
local CooldownSyncFrame = CreateFrame("Frame")
local COOLDOWN_SYNC_INTERVAL = 2
local MSG_DESYNC = "DESYNC"
local MSG_INFO_REQUEST = "REQ"
local MSG_INFO_UPDATE = "UPD"
local MSG_STRIVE_PVP = "STRIVE"
local MSG_COOLDOWN_SYNC = "CD"
local NULL = ""

CM.syncedGroupMembers = {}
CM.cooldownSyncIDs = {}
CM.serializedSyncData = NULL

function CM:SendComm(...)
	local message = strjoin(",", ...)




	if IsInRaid() then

		self:SendCommMessage(self.AddonPrefix, message, (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID")
	elseif IsInGroup() then

		self:SendCommMessage(self.AddonPrefix, message, (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY")
	end
end

function CM:RequestSync()
	self:SendComm(MSG_INFO_REQUEST, E.userGUID, self.serializedSyncData)
end

function CM:SendUserSyncData(sender)
	if self.serializedSyncData == NULL then
		self:InspectUser()
	end
	self:SendComm(sender or MSG_INFO_UPDATE, E.userGUID, self.serializedSyncData)
end

function CM:DesyncFromGroup()
	wipe(self.syncedGroupMembers)
	CooldownSyncFrame:Hide()
	self:SendComm(MSG_DESYNC, E.userGUID, 1)
end

function CM:IsVersionIncompatible(serializationVersion)
	return serializationVersion ~= self.SERIALIZATION_VERSION
end

local aceUserNameFix = CM.ACECOMM and E.userName or gsub(E.userNameWithRealm, " ", "")

function CM:CHAT_MSG_ADDON(prefix, message, _, sender)
	if prefix ~= self.AddonPrefix or sender == aceUserNameFix then
		return
	end

	local header, guid, body = strmatch(message, "(.-),(.-),(.+)")
	local info = P.groupInfo[guid]
	if not info then
		return
	end

	local isSyncedUnit = self.syncedGroupMembers[guid]
	if header == MSG_COOLDOWN_SYNC then
		if isSyncedUnit then
			self.SyncCooldowns(guid, body)
		end
		return
	elseif header == MSG_INFO_REQUEST then
		self:SendUserSyncData(guid)
	elseif header == MSG_INFO_UPDATE then
		if not isSyncedUnit then
			return
		end
	elseif header == MSG_DESYNC then
		if isSyncedUnit then
			self.syncedGroupMembers[guid] = nil
		end
		self:ToggleCooldownSync()
		return
	elseif header == MSG_STRIVE_PVP then
		if isSyncedUnit and (not P.loginsessionData[guid] or not P.loginsessionData[guid]["strivedPvpCD"]) then
			local elapsed, cd = strsplit(":", body, 3)
			self:SyncStrivePvpTalentCD(guid, tonumber(elapsed), tonumber(cd))
		end
		return
	elseif header ~= E.userGUID then
		return
	end

	local decodedData = LibDeflate:DecodeForWoWAddonChannel(body)
	if not decodedData then
		error("Error decoding sync message from " .. info.name)
	end
	local decompressedData = LibDeflate:DecompressDeflate(decodedData)
	if not decompressedData then
		error("Error decompressing sync message from " .. info.name)
	end

	while ( decompressedData ) do
		local t, rest = strsplit("^", decompressedData, 2)
		decompressedData = rest

		local k, v = strsplit(",", t, 2)
		if ( k == "T" ) then
			while ( v ) do
				local id, idlist = strsplit(",", v, 2)
				v = idlist
				local spellID, rank = strsplit(":", id)
				spellID = tonumber(spellID)
				if ( spellID ) then
					if ( spellID > 0 ) then
						info.talentData[spellID] = tonumber(rank) or 1
					else
						info.talentData[-spellID] = "PVP"
					end
				end
			end
		elseif ( k == "M" ) then
			while ( v ) do
				local id, idlist = strsplit(",", v, 2)
				v = idlist
				local key, src = strsplit(":", id)
				local spellID = tonumber(key)
				local value = tonumber(src) or src or true
				if ( not spellID ) then
					info.talentData[key] = value
				elseif ( spellID > 0 ) then
					if ( src == "AE" ) then
						local rank1 = CM.essencePowerIDs[spellID]
						if ( rank1 ) then
							info.talentData[rank1] = src
							info.talentData["essMajorRank1"] = rank1
							info.talentData["essMajorID"] = spellID
						end
					elseif ( src == "ae" ) then
						info.talentData["essStriveMult"] = spellID
					else
						info.talentData[spellID] = value
					end
				else
					info.talentData[-spellID] = value
				end
			end
		elseif ( k == "E" ) then
			while ( v ) do
				local id, idlist = strsplit(",", v, 2)
				v = idlist
				id = tonumber(id)
				if ( id ) then
					if ( id > 0 ) then
						info.itemData[id] = true
					else
						info.rangedWeaponSpeed = -id
					end
				end
			end
		elseif ( k == "C" ) then
			wipe(info.shadowlandsData)
			local covenantID, soulbindID, conduits = strsplit(",", v, 3)
			covenantID = tonumber(covenantID)
			soulbindID = tonumber(soulbindID)
			local covenantSpellID = E.covenant_to_spellid[covenantID]
			info.shadowlandsData.covenantID = covenantSpellID
			info.shadowlandsData.soulbindID = soulbindID
			info.talentData[covenantSpellID] = "C"
			while ( conduits ) do
				local id, idlist = strsplit(",", conduits, 2)
				conduits = idlist
				local conduitSpellID, rankValue = strsplit(":", id)
				conduitSpellID = tonumber(conduitSpellID)
				rankValue = tonumber(rankValue)
				if ( rankValue ) then
					info.talentData[conduitSpellID] = rankValue
				elseif ( conduitSpellID ) then
					info.talentData[conduitSpellID] = 0
				end
			end
		else
			k = tonumber(k)
			if ( not k or self:IsVersionIncompatible(k) ) then
				return
			end
			info.spec = tonumber(v)
			wipe(info.talentData)
			wipe(info.itemData)
		end
	end

	local unit = info.unit
	if info.name == "" or info.name == "Unknown" then
		info.name = GetUnitName(unit, true)
	end
	if info.level == 200 then
		local lvl = UnitLevel(unit)
		if lvl > 0 then
			info.level = lvl
		end
	end

	self.syncedGroupMembers[guid] = true
	self:DequeueInspect(guid)
	P:UpdateUnitBar(guid)

	self:ToggleCooldownSync()
end

local function SendUpdatedUserSyncData()
	CM:InspectUser()
	CM:SendUserSyncData()
end

function CM:CHARACTER_POINTS_CHANGED(change)
	if change == -1 then
		SendUpdatedUserSyncData()
	end
end

local equipmentTimer

local SendUserSyncData_OnTimerEnd = function()
	SendUpdatedUserSyncData()
	equipmentTimer = nil
end

function CM:PLAYER_EQUIPMENT_CHANGED(slotID)
	if not equipmentTimer then
		equipmentTimer = C_Timer.NewTicker(0.1, SendUserSyncData_OnTimerEnd, 1)
	end
end

CM.PLAYER_TALENT_UPDATE = SendUpdatedUserSyncData
CM.PLAYER_SPECIALIZATION_CHANGED = SendUpdatedUserSyncData
CM.COVENANT_CHOSEN = SendUpdatedUserSyncData
CM.SOULBIND_ACTIVATED = SendUpdatedUserSyncData
CM.SOULBIND_NODE_LEARNED = SendUpdatedUserSyncData
CM.SOULBIND_NODE_UNLEARNED = SendUpdatedUserSyncData
CM.SOULBIND_NODE_UPDATED = SendUpdatedUserSyncData
CM.SOULBIND_CONDUIT_INSTALLED = SendUpdatedUserSyncData
CM.SOULBIND_PATH_CHANGED = SendUpdatedUserSyncData
CM.COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED = SendUpdatedUserSyncData
CM.TRAIT_CONFIG_UPDATED = SendUpdatedUserSyncData



CM.PLAYER_LEAVING_WORLD = CM.DesyncFromGroup

function CM:SyncStrivePvpTalentCD(guid, cd)
	local info = P.groupInfo[guid]
	if not info then
		return
	end

	local spellID = info.talentData["essStrivedPvpID"]
	local icon = info.spellIcons[spellID]
	if icon then
		local active = info.active[spellID]
		if active then
			local modRate = active.modRate or 1
			local newCd = cd * modRate
			icon.cooldown:SetCooldown(active.startTime, newCd, modRate)
			active.duration = newCd
		end
		icon.duration = cd
	end
	P.loginsessionData[guid] = P.loginsessionData[guid] or {}
	P.loginsessionData[guid]["strivedPvpCD"] = cd
end

function CM.SendStrivePvpTalentCD(spellID)
	local st, cd, _, modRate = GetSpellCooldown(spellID)
	if cd < 2 then
		return
	end

	cd = cd/modRate
	if not P.isUserDisabled then
		CM:SyncStrivePvpTalentCD(E.userGUID, cd)
	end
	CM:SendComm(MSG_STRIVE_PVP, E.userGUID, cd)
end

function CM:FindSpellIcon(info, spellID)
	local icon = info.spellIcons[spellID]
	if icon then
		return icon, spellID
	end
	spellID = E.spell_merged[spellID]
	if spellID then
		return self:FindSpellIcon(info, spellID)
	end
end

function CM:SetHealthstoneCD(info, icon, charges, isEnabled)
	if isEnabled then
		icon.cooldown:Clear()
		icon.icon:SetVertexColor(0.4, 0.4, 0.4)
		local statusBar = icon.statusBar
		if statusBar then
			statusBar.BG:SetVertexColor(0.7, 0.7, 0.7)
		end
	else
		icon.icon:SetVertexColor(1, 1, 1)
	end
	icon.count:SetText(charges)
	info.auras.healthStoneStacks = charges
	info.preactiveIcons[6262] = isEnabled and icon
end

function CM.SyncCooldowns(guid, encodedData)
	local info = P.groupInfo[guid]
	if not info then return end

	local compressedData = LibDeflate:DecodeForWoWAddonChannel(encodedData)
	if not compressedData then return end

	local serializedCooldownData = LibDeflate:DecompressDeflate(compressedData)
	if not serializedCooldownData then return end

	local now = GetTime()
	while ( serializedCooldownData ) do
		local spellID, duration, remainingTime, modRate, charges, rest = strsplit(",", serializedCooldownData, 6)
		serializedCooldownData = rest
		spellID = tonumber(spellID)
		if ( spellID ) then
			local icon, iconSpellID = CM:FindSpellIcon(info, spellID)
			if ( icon ) then
				duration, remainingTime, modRate, charges = tonumber(duration), tonumber(remainingTime), tonumber(modRate), tonumber(charges)
				local normalizedCharges = icon.maxcharges and charges ~= -1 and charges or nil
				local active = icon.active and info.active[iconSpellID]

				if ( active and duration == 0 ) then
					icon:ResetCooldown(true)
					info.spellModRates[iconSpellID] = modRate
					icon.modRate = modRate
					if iconSpellID == 6262 then
						CM:SetHealthstoneCD(info, icon, charges, now - active.startTime < 10)
					end

				elseif ( active and (abs(active.duration - (now - active.startTime) - remainingTime) > 1 or active.charges ~= normalizedCharges) )
					or ( not active and duration > 0 and E.sync_reset[spellID] ) then

					local startTime = now - (duration - remainingTime)
					icon.cooldown:SetCooldown(startTime, duration, modRate)
					icon:SetCooldownElements(normalizedCharges)
					if not active then
						active = {}
						info.active[iconSpellID] = active
					end
					active.startTime = startTime
					active.duration = duration
					active.modRate = modRate
					if normalizedCharges then
						active.charges = normalizedCharges
						icon.count:SetText(normalizedCharges)
					end
					icon.active = normalizedCharges or 1
					icon.modRate = modRate
					info.spellModRates[iconSpellID] = modRate
					if iconSpellID == 6262 then
						CM:SetHealthstoneCD(info, icon, charges)
					end

					local statusBar = icon.statusBar
					if statusBar then
						statusBar.CastingBar:OnEvent(statusBar.CastingBar.channeling and 'UNIT_SPELLCAST_CHANNEL_UPDATE' or 'UNIT_SPELLCAST_CAST_UPDATE')
					end
				end
			end
		end
	end
end



local function GetCooldownFix(spellID)
	local start, duration, enabled, modRate = GetSpellCooldown(spellID)
	local currentCharges, maxCharges, cooldownStart, cooldownDuration, chargeModRate = GetSpellCharges(spellID)
	local charges = maxCharges and maxCharges > 1 and currentCharges or -1
	if enabled == 1 then
		if start and start > 0 then
			if duration < 1.5 or (currentCharges and currentCharges > 0) then
				return nil
			end
			return start, duration, modRate, charges
		elseif maxCharges and maxCharges > currentCharges then
			return cooldownStart, cooldownDuration, chargeModRate, charges
		end
	end
	return 0, 0, 1, charges, enabled
end

local cooldownData = {}
local elapsedTime = 0
local OFF_CD, THIRD_DECIMAL, TRUNCATE_ZEROS = "0,0,1", "%.3f", "%.?0+$"

local function CooldownSyncFrame_OnUpdate(_, elapsed)
	elapsedTime = elapsedTime + elapsed
	if elapsedTime < COOLDOWN_SYNC_INTERVAL then
		return
	end

	local now = GetTime()
	local c = 0
	for id, cooldownInfo in pairs(CM.cooldownSyncIDs) do
		local start, duration, modRate, charges, enabled = GetCooldownFix(id)
		if start then
			if id == 6262 then
				charges = C_Item.GetItemCount(5512, false, true)
			end
			local prevStart, prevCharges = cooldownInfo[1], cooldownInfo[2]
			local isSyncResetID = E.sync_reset[id]
			if duration == 0 then
				if isSyncResetID and (prevStart ~= 0 or enabled == 0) then
					cooldownInfo[1] = start
					cooldownInfo[2] = charges
					cooldownData[c + 1] = id
					cooldownData[c + 2] = OFF_CD
					cooldownData[c + 3] = charges
					c = c + 3
				end

			else

				if prevStart == 0 or abs(start - prevStart) > .49 or charges > prevCharges then
					cooldownInfo[1] = start
					cooldownInfo[2] = charges
					local remainingTime = start + duration - now
					if modRate == 1 then
						remainingTime = floor(remainingTime)
					else
						duration = format(THIRD_DECIMAL, duration):gsub(TRUNCATE_ZEROS, NULL)
						modRate = format(THIRD_DECIMAL, modRate):gsub(TRUNCATE_ZEROS, NULL)
						remainingTime = format(THIRD_DECIMAL, remainingTime):gsub(TRUNCATE_ZEROS, NULL)
					end
					cooldownData[c + 1] = id
					cooldownData[c + 2] = duration
					cooldownData[c + 3] = remainingTime
					cooldownData[c + 4] = modRate
					cooldownData[c + 5] = charges
					c = c + 5
				elseif start == prevStart and charges > -1 and charges < prevCharges then
					cooldownInfo[2] = charges
				end
			end
		end




	end

	elapsedTime = 0

	if c == 0 then
		return
	end

	for i = #cooldownData, c + 1, -1 do
		cooldownData[i] = nil
	end

	local serializedCooldownData = concat(cooldownData, ",")
	local compressedData = LibDeflate:CompressDeflate(serializedCooldownData)
	local encodedData = LibDeflate:EncodeForWoWAddonChannel(compressedData)
	if not P.isUserDisabled then
		CM.SyncCooldowns(E.userGUID, encodedData)
	end
	if next(CM.syncedGroupMembers) then
		CM:SendComm(MSG_COOLDOWN_SYNC, E.userGUID, encodedData)
	end
end

function CM:ForceSyncCooldowns()
	elapsedTime = 100
end

function CM:ToggleCooldownSync()
	if E.preCata then
		return
	end
	if next(self.cooldownSyncIDs) and P.disabled == false and (not P.isUserDisabled or next(self.syncedGroupMembers)) then
		CooldownSyncFrame:Show()
	else
		CooldownSyncFrame:Hide()
	end
end

local CooldownSyncFrame_OnShow = function(self)
	self.isShown = true
end

local CooldownSyncFrame_OnHide = function(self)
	self.isShown = false
end

function CM:InitCooldownSync()
	if self.initCooldownSync or E.preCata then
		return
	end
	CooldownSyncFrame:Hide()

	CooldownSyncFrame:SetScript("OnShow", CooldownSyncFrame_OnShow)
	CooldownSyncFrame:SetScript("OnHide", CooldownSyncFrame_OnHide)
	CooldownSyncFrame:SetScript("OnUpdate", CooldownSyncFrame_OnUpdate)

	self.initCooldownSync = true
end
