local _, _MS = ...

_MS.DATACORE = {}
_MS.EVENTUI = {}

local _DC = _MS.DATACORE
local _U = _MS.UTILS
local _CD = _MS.CONSTDATA
local _EVENTUI = _MS.EVENTUI


function _DC.getCurrentKeyStone()
    local mapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
    if not mapID then
        return ""
    end
    local mapName = _CD.dungeonChallengeMapNames[mapID]
    local level = C_MythicPlus.GetOwnedKeystoneLevel()
    if not level then
        return ""
    end
    local curKeystoneInfo = {["nm"] = mapName, ["lvl"] = level}

    local maxInTimeLevel, maxOverTimeLevel = -1, -1
    local maxInTimeName, maxOverTimeName = nil, nil

    for mapID, mapName in pairs(_CD.dungeonChallengeMapNames)
    do
        intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(mapID)
        if intimeInfo then
            if tonumber(intimeInfo["level"]) > maxInTimeLevel then
                maxInTimeLevel = intimeInfo["level"]
                maxInTimeName = mapName
            end
        end
        if overtimeInfo then
            if tonumber(overtimeInfo["level"]) > maxOverTimeLevel then
                maxOverTimeLevel = overtimeInfo["level"]
                maxOverTimeName = mapName
            end
        end
    end

    local keystoneInfo = {}
    keystoneInfo["c"] = curKeystoneInfo

    local maxInInfo = {}
    maxInInfo["nm"] = maxInTimeName
    maxInInfo["lvl"] = maxInTimeLevel
    keystoneInfo["mi"] = maxInInfo

    local maxOverInfo = {}
    maxOverInfo["nm"] = maxOverTimeName
    maxOverInfo["lvl"]= maxOverTimeLevel
    keystoneInfo["mo"] = maxOverInfo
    return keystoneInfo
end


function _DC.insertDatatoDB(self, guid, key, value)
    if not _MS.DB[guid] then
        _MS.DB[guid] = {}
    end
    _MS.DB[guid][key] = value
end

function _DC.insertDatatoDBTable(self, guid, key, value)
    if not _MS.DB[guid] then
        return
    end
    _MS.DB[guid][key][value] = 1
end

function _DC.removeDatatoDBTable(self, guid, key, value)
    if not _MS.DB[guid] then
        return
    end
    _MS.DB[guid][key][value] = nil
end

function _DC.insertUnittoDB(self, guid, unitInfo)
    _MS.DB[guid] = unitInfo
end

function _DC.selectDatafromDB(self, guid, key)
    if not _MS.DB[guid] then
        -- print("Their is no this GUID."..guid.."  "..key)
        return nil
    end
    if not _MS.DB[guid][key] then
        -- print("Their is not this data.")
        return nil
    end
    return _MS.DB[guid][key]
end

function _DC.selectDatafromDBByNameServer(self, nameserver, key)
    for guid, unitInfo in pairs(_MS.DB)
    do
        if unitInfo["name"].."-"..unitInfo["server"] == nameserver then
            return unitInfo[key]
        end
    end
    return nil
end

function _DC.selectUnitfromDB(self, guid)
    if not _MS.DB[guid] then
        -- print("Their is no this GUID.")
        return nil
    end
    return _MS.DB[guid]
end

-- ---------------------------

function _DC.searchCorruption(self, link)
    local value = _CD.linkCache[link]
    if not value then
        local itemString = strmatch(link, "item:([%-?%d:]+)")
        for index in gmatch(itemString, "%d+") do
            if _CD.corruptionData[index] then
                value = _CD.corruptionData[index]
                _CD.linkCache[link] = value
                break
            end
        end
    end
    return value
end

-- ----------------------------



function _DC.getAchievementDataHandler(self, event, guid)
    local uid = _DC:selectDatafromDB(guid, "uid")
    if not uid then
        return
    end
    local mainAchi = nil
    local completed, month, day, year = GetAchievementComparisonInfo(_CD.mainAchiID)
    if completed then
        mainAchi = year.."/"..month.."/"..day
    else
        mainAchi = 0
    end
    local IDNumber, mainAchiName, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText, isGuildAch = GetAchievementInfo(_CD.mainAchiID)

    local cAchi1 = nil
    local completed, month, day, year = GetAchievementComparisonInfo(_CD.childAchi1ID)
    if completed then
        cAchi1 = year.."/"..month.."/"..day
    else
        cAchi1 = 0
    end
    local IDNumber, cAchi1Name, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText, isGuildAch = GetAchievementInfo(_CD.childAchi1ID)

    local cAchi2 = nil
    local completed, month, day, year = GetAchievementComparisonInfo(_CD.childAchi2ID)
    if completed then
        cAchi2 = year.."/"..month.."/"..day
    else
        cAchi2 = 0
    end
    local IDNumber, cAchi2Name, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText, isGuildAch = GetAchievementInfo(_CD.childAchi2ID)

    local cAchi3 = nil
    local completed, month, day, year = GetAchievementComparisonInfo(_CD.childAchi3ID)
    if completed then
        cAchi3 = year.."/"..month.."/"..day
    else
        cAchi3 = 0
    end
    local IDNumber, cAchi3Name, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText, isGuildAch = GetAchievementInfo(_CD.childAchi3ID)

    local dungeonCount = {}
    for i = 1, table.getn(_CD.dungeonIds), 1
    do
        dungeonCount[_CD.dungeonIds[i]] = GetComparisonStatistic(_CD.dungeonIds[i])
    end
    if guid == _CD.curRequestGUID then
        _DC:insertDatatoDB(guid, "mainAchi", mainAchi)
        _DC:insertDatatoDB(guid, "cAchi1", cAchi1)
        _DC:insertDatatoDB(guid, "cAchi2", cAchi2)
        _DC:insertDatatoDB(guid, "cAchi3", cAchi3)
        _DC:insertDatatoDB(guid, "mainAchiName", mainAchiName)
        _DC:insertDatatoDB(guid, "cAchi1Name", cAchi1Name)
        _DC:insertDatatoDB(guid, "cAchi2Name", cAchi2Name)
        _DC:insertDatatoDB(guid, "cAchi3Name", cAchi3Name)
        _DC:insertDatatoDB(guid, "dungeonCount", dungeonCount)
        _DC:triggerRefreshPanel(uid)
    end
end


function _DC.getGearDataHandler(self, event, guid)
    local totalIlvl = 0
    local mainHandEquipLoc, offHandEquipLoc
    local totalCorruption = 0

    local uid = _DC:selectDatafromDB(guid, "uid")
    if not uid then
        return
    end
    -- --------------------
    -- 获取专精
    local specID = GetInspectSpecialization(uid)
    local _, currentSpecName = GetSpecializationInfoByID(specID)

    -- --------------------
    -- 计算精华腐蚀减免
    local resistance = 0
    _EVENTUI.tmpTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    _EVENTUI.tmpTooltip:SetInventoryItem(uid, 2)
    for i = 1, 10 do
        local tex = _G[_EVENTUI.tmpTooltip:GetName().."Texture"..i]
        local texture = tex and tex:IsShown() and tex:GetTexture()
        if texture and _CD.essenceTextureIDs[texture] then
            resistance = 10
            break
        end
    end

    -- ---------------------
    -- 计算披风减免
    _EVENTUI.tmpTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    _EVENTUI.tmpTooltip:SetInventoryItem(uid, 15)
    for i = 1, _EVENTUI.tmpTooltip:NumLines() do
        local line = _G[_EVENTUI.tmpTooltip:GetName().."TextLeft"..i]
        local text = line and line:GetText()
        local value = text and strmatch(text, _CD.cloakResString)
        if value then
            resistance = resistance + value
        end
    end


    -- -----------------------
    -- 检索所有装备, 获取宝石，腐蚀
    local slotCount = 0
    local corruptionList = {}

    for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
        if slot ~= INVSLOT_BODY and slot ~= INVSLOT_TABARD then
            local link = GetInventoryItemLink(uid, slot)
            if link then
                -- iLvl
                local _, _, _, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(link)
                if itemLevel then 
                    totalIlvl = totalIlvl + itemLevel
                end
                if slot == INVSLOT_MAINHAND then
                    mainHandEquipLoc = itemEquipLoc
                elseif slot == INVSLOT_OFFHAND then
                    offHandEquipLoc = itemEquipLoc
                end

                -- Corruption
                if IsCorruptedItem(link) then
                    local corruptionInfo = _DC:searchCorruption(link)
                    totalCorruption = totalCorruption + corruptionInfo["value"]
                    if corruptionList[corruptionInfo["spellID"]] then
                        corruptionList[corruptionInfo["spellID"]]["count"] = corruptionList[corruptionInfo["spellID"]]["count"] + 1
                    else
                        corruptionList[corruptionInfo["spellID"]] = {}
                        corruptionList[corruptionInfo["spellID"]]["count"] = 1
                    end
                    corruptionList[corruptionInfo["spellID"]]["name"] = corruptionInfo["name"]
                    corruptionList[corruptionInfo["spellID"]]["level"] = corruptionInfo["level"]
                end

                -- Gem slot
                local itemStatTable = {}
                wipe(itemStatTable)
                local stats = GetItemStats(link, itemStatTable)
                if stats
                then 
                    for k, v in next, stats do
                        if(_CD.gemSlots[k]) then
                            slotCount = slotCount + v
                        end
                    end
                end
            end
        end
    end
    
    local numSlots
    if mainHandEquipLoc and offHandEquipLoc then
        numSlots = 16
    else
        numSlots = 15
    end

    if guid == _CD.curRequestGUID then
        _DC:insertDatatoDB(guid, "currentSpecName", currentSpecName)
        _DC:insertDatatoDB(guid, "ilvl", math.modf(totalIlvl / numSlots))
        _DC:insertDatatoDB(guid, "corruptionValue", totalCorruption - resistance)
        _DC:insertDatatoDB(guid, "corruptionList", corruptionList)
        _DC:insertDatatoDB(guid, "gemSlot", slotCount)

        _DC:triggerRefreshPanel(uid)
    end
end

function _DC.getUnitAchievementData(self, uid)
    ClearAchievementComparisonUnit()
    local guid = _CD.partyMembers[uid]
    local success = false
    if guid then
        if SetAchievementComparisonUnit(uid) then
            success = true
        else
            success = false
        end
    end
    return success
end

function _DC.getUnitGearData(self, uid)
    ClearInspectPlayer()
    local success = false
    if CanInspect(uid) then
        local guid = _CD.partyMembers[uid]
        if guid then
            NotifyInspect(uid)
            success = true
        end
    end
    return success
end


function _DC.getUnitBasicData(self, uid)
    local unitInfo = {}
    unitInfo["uid"] = uid
    local namestr = GetUnitName(uid, true)
    if namestr == UNKNOWNOBJECT or not namestr
    then
        return nil
    end
    local ts = string.reverse(namestr)  
    local param1, param2 = string.find(ts, "-")
    local name, server
    if param2
    then
       local m = string.len(namestr) - param2 + 1     
       server = string.sub(namestr, m+1, string.len(namestr))   
       name = string.sub(namestr, 1, m-1)  
    else
       name = namestr
       server = GetRealmName()
    end
    unitInfo["name"] = name
    unitInfo["server"] = server
    local guid = UnitGUID(uid)
    unitInfo["GUID"] =  guid
    if uid == "player"
    then
        _CD.playerGUID = guid
    end

    local localizedClass, englishClass, classIndex = UnitClass(uid);
    unitInfo["classIndex"] = classIndex

    local role = UnitGroupRolesAssigned(uid);
    unitInfo["role"] = role

    if _MS.MSDB[guid]
    then
        unitInfo["rating"] = _MS.MSDB[guid]
    end

    unitInfo["badRatingCount"] = {}
    unitInfo["goodRatingCount"] = {}
    _CD.partyMembers[uid] = unitInfo["GUID"]

    if uid == "player" then
        local playerKeystoneInfo = _DC:getCurrentKeyStone()
        unitInfo["keystoneInfo"] = playerKeystoneInfo
    end

    _DC:insertUnittoDB(guid, unitInfo)
    _DC:triggerRefreshPanel(uid)

    if uid ~= "player" then
        local message = _U:createMessage("REQUEST_KEYSTONE", nil)
        C_ChatInfo.SendAddonMessage("MS", message, "WHISPER", unitInfo["name"].."-"..unitInfo["server"])
        _DC:addHistory(unitInfo)
    end
    local message = _U:createMessage("REQUEST_RATINGTABLE", nil)
    C_ChatInfo.SendAddonMessage("MS", message, "PARTY")
end

function _DC.getUnitData(self, uid)
    if _U.FLAG:getRefreshFlag() then
        return
    end
    _U.FLAG:lockRefreshFlag()

    -- Get Unit Basic Data
    _DC:getUnitBasicData(uid)

    -- Get Unit Advantage Data
    C_ChatInfo.SendAddonMessage("AngryKeystones", "Schedule|request", "PARTY")
    local guid = _CD.partyMembers[uid]
    _CD.curRequestGUID = guid
    _CD.curRequestUID = uid
    local gearSuccess = _DC:getUnitGearData(uid)
    local achiSuccess = _DC:getUnitAchievementData(uid)
    if gearSuccess or achiSuccess then
        _U:wait(3, _DC.getUnitDataDone, uid)
    else
        _U.FLAG:releaseRefreshFlag()
    end
end

function _DC.getUnitDataDone(uid)
    ClearAchievementComparisonUnit()
    ClearInspectPlayer()
    -- print("Release")
    _U.FLAG:releaseRefreshFlag()
    local message = _U:createMessage("REFRESH_DONE", uid)
    C_ChatInfo.SendAddonMessage("MS", message, "WHISPER", _DC:selectDatafromDB(_CD.playerGUID, "name").."-".._DC:selectDatafromDB(_CD.playerGUID, "server"))
end

function _DC.addHistory(self, unitInfo)
    if not _CD.historyMembers then
        _CD.historyMembers = _U.List:new()
    end
    unitInfo["time"] = date("%H:%M")
    _U.List:push(_CD.historyMembers, unitInfo, unitInfo["GUID"])
end


function _DC.partyChanged()
    local membersNum = GetNumGroupMembers()
    if membersNum < 6 and membersNum ~= 1 then

        _CD.firstInRaid = true
        -- membersNum = GetNumSubgroupMembers()
        if _U.FLAG:getRefreshFlag() then
            return
        end
        _U.FLAG:lockRefreshFlag()

        -- Update party members list
        _CD.partyMembers = {}
        _CD.partyMembers["player"] = _CD.playerGUID

        -- Get basic information
        _DC:getMemberBasicData()
        _DC.triggerTogglePanel()

        -- Garbage relase
        local newDB = {}
        for uid, guid in pairs(_CD.partyMembers)
        do
            newDB[guid] = _DC:selectUnitfromDB(guid)
        end
        _MS.DB = newDB

        collectgarbage("collect")
        _CD.curRequestUID = nil
        _DC:getMemberAdvancedData()

        _DC:shareData()
        -- Request Angrystone
        C_ChatInfo.SendAddonMessage("AngryKeystones", "Schedule|request", "PARTY")
    else
        if _CD.firstInRaid and membersNum ~= 1 then
            print("|cFFFFFF00" .. L["InRaid"])
            _CD.firstInRaid = false
        end
    end
end



function _DC.getMemberBasicData()
    local membersNum = GetNumGroupMembers()

    for i = 1, membersNum, 1
    do
        local uid = "party"..i
        _DC:getUnitBasicData(uid)
    end
end


function _DC.getMemberAdvancedData()
    ClearAchievementComparisonUnit()
    ClearInspectPlayer()

    if _CD.curRequestUID then
        local message = _U:createMessage("REFRESH_DONE", _CD.curRequestUID)
        C_ChatInfo.SendAddonMessage("MS", message, "WHISPER", _DC:selectDatafromDB(_CD.playerGUID, "name").."-".._DC:selectDatafromDB(_CD.playerGUID, "server"))
    end

    local uid, guid = next(_CD.partyMembers, _CD.curRequestUID)
    _CD.curRequestUID = uid
    if uid then
        _CD.curRequestGUID = guid
        local gearSuccess = _DC:getUnitGearData(uid)
        local achiSuccess = _DC:getUnitAchievementData(uid)
        if gearSuccess or achiSuccess then
            local message = _U:createMessage("REFRESH_START", _CD.curRequestUID)
            C_ChatInfo.SendAddonMessage("MS", message, "WHISPER", _DC:selectDatafromDB(_CD.playerGUID, "name").."-".._DC:selectDatafromDB(_CD.playerGUID, "server"))
            _U:wait(3, _DC.getMemberAdvancedData)
        end
    else
        _U.FLAG:releaseRefreshFlag()
        -- print("Release Member.")
    end
end

function _DC.getMemberRatings()
    local ratingTable = {}
    for uid, guid in pairs(_CD.partyMembers)
    do
        if uid ~= "player" then
            local score = _MS.MSDB[guid]
            ratingTable[guid] = score
        end
    end
    return ratingTable
end


function _DC.saveRating(self, guid, score)
    _MS.MSDB[guid] = score
    _DC:shareRatingTable()
end

function _DC.shareRatingTable()
    local ratingTable = _DC:getMemberRatings()
    ratingTable["SenderGUID"] = _CD.playerGUID
    local message = _U:createMessage("RATINGTABLE", ratingTable)
    C_ChatInfo.SendAddonMessage("MS", message, "PARTY")
end

function _DC.shareKeystoneMessage()
    local keystoneInfoBody = {}
    keystoneInfoBody["PlayerGUID"] = _CD.playerGUID
    keystoneInfoBody["keystoneInfo"] = _DC:getCurrentKeyStone()
    local message = _U:createMessage("KEYSTONE_INFORMATION", keystoneInfoBody)
    C_ChatInfo.SendAddonMessage("MS", message, "PARTY")
end

function _DC.shareVersion()
    local message = _U:createMessage("VERSION", _MS.VERSION)
    C_ChatInfo.SendAddonMessage("MS", message, "PARTY")
end

function _DC.shareData()
    _DC:shareKeystoneMessage()
    _DC:shareRatingTable()
    _DC:shareVersion()
end



function _DC.createDataEventFrame()
    local tmpTooltip = CreateFrame("GameTooltip", "TempTooltip", nil, "GameTooltipTemplate")
    _EVENTUI.tmpTooltip = tmpTooltip
    
    local eventFrame = CreateFrame("Frame", "EventFrame", nil)
    _EVENTUI.eventFrame = eventFrame

    local achievementEventFrame = CreateFrame("Frame", "AchievementEventFrame", eventFrame)
    achievementEventFrame:RegisterEvent("INSPECT_ACHIEVEMENT_READY")
    achievementEventFrame:SetScript("OnEvent", _DC.getAchievementDataHandler);
    _EVENTUI.achievementEventFrame = achievementEventFrame

    local gearEventFrame = CreateFrame("Frame", "GearEventFrame", eventFrame)
    gearEventFrame:RegisterEvent("INSPECT_READY")
    gearEventFrame:SetScript("OnEvent", _DC.getGearDataHandler);
    _EVENTUI.gearEventFrame = gearEventFrame


    local groupChangedEventFrame = CreateFrame("Frame", "GroupChangedEventFrame", eventFrame)
    groupChangedEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    groupChangedEventFrame:SetScript("OnEvent", _DC.partyChanged);
    _EVENTUI.groupChangedEventFrame = groupChangedEventFrame

end

function _DC.triggerRefreshPanel(self, uid)
    if not uid then
        uid = self
    end
    local message = _U:createMessage("REFRESH_PANEL", uid)
    C_ChatInfo.SendAddonMessage("MS", message, "WHISPER", _DC:selectDatafromDB(_CD.playerGUID, "name"))
end

function _DC.triggerTogglePanel()
    local message = _U:createMessage("TOGGLE_PANEL", nil)
    C_ChatInfo.SendAddonMessage("MS", message, "WHISPER", _DC:selectDatafromDB(_CD.playerGUID, "name"))
end


-- ----------------------------

function _DC.Initial()
    print("DataCore Initial...")
    _DC:createDataEventFrame()
    _DC:getUnitData("player")
    _U:wait(3.5, _DC.partyChanged)
end