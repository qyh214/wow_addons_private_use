local L = LibStub ("AceLocale-3.0"):GetLocale("Minesweeperr", true)
local MS = Minesweeperr
MS.Data = {}
MS.Data.db = {}
MS.Data.initialed = false
-- -----------------------
-- Database

function MS.Data:selectUnitfromDB(guid)
    if not self.db[guid] then
        return nil
    end
    return self.db[guid]
end

function MS.Data:insertUnittoDB(guid, unitInfo)
    self.db[guid] = unitInfo
end

function MS.Data:selectDatafromDB(guid, key)
    if not self.db[guid] then
        return nil
    end
    if not self.db[guid][key] then
        return nil
    end
    return self.db[guid][key]
end

function MS.Data:selectUnitfromDB(guid)
    if not self.db[guid] then
        return nil
    end
    return self.db[guid]
end

function MS.Data:insertDatatoDB(guid, key, value)
    if not self.db[guid] then
        self.db[guid] = {}
    end
    self.db[guid][key] = value
end

function MS.Data:insertDatatoDBTable(guid, key, value)
    if not self.db[guid] then
        return
    end
    self.db[guid][key][value] = 1
end

function MS.Data:removeDatafromDBTable(guid, key, value)
    if not self.db[guid] then
        return
    end
    self.db[guid][key][value] = nil
end

function MS.Data:selectDatafromDBByNameServer(nameserver, key)
    for guid, unitInfo in pairs(self.db)
    do
        if unitInfo["name"].."-"..unitInfo["server"] == nameserver then
            return unitInfo[key]
        end
        if not string.find(nameserver, "-") then
            if unitInfo["name"] == nameserver then
                return unitInfo[key]
            end
        end
    end
    return nil
end


function MS.Data:getCurrentKeyStone()
    local mapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
    if not mapID then
        return ""
    end
    local mapName = MS.Const.dungeonChallengeMapNames[mapID]
    local level = C_MythicPlus.GetOwnedKeystoneLevel()
    if not level then
        return ""
    end
    local curKeystoneInfo = {["nm"] = mapName, ["lvl"] = level}

    local maxInTimeLevel, maxOverTimeLevel = -1, -1
    local maxInTimeName, maxOverTimeName = nil, nil

    for mapID, mapName in pairs(MS.Const.dungeonChallengeMapNames)
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

function MS.Data:getUnitBasicData(uid)
    local guid = UnitGUID(uid)
    local unitInfo = self:selectUnitfromDB(guid)
    if not unitInfo then
        unitInfo = {}
    end

    -- ------------
    -- GUID
    unitInfo["GUID"] = guid
    if uid == "player"
    then
        self.playerGUID = guid
    end
    
    -- UID
    unitInfo["uid"] = uid

    -- Name and Server
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

    -- Guild
    local guild, _, _, _ = GetGuildInfo(uid)
    unitInfo["guild"] = guild

    -- Class Idx
    local localizedClass, englishClass, classIndex = UnitClass(uid);
    unitInfo["classIndex"] = classIndex

    -- Class Color
    local r, g, b = GetClassColor(MS.Const.classIdx[classIndex])
    unitInfo["classColorR"] = r
    unitInfo["classColorG"] = g
    unitInfo["classColorB"] = b

    -- Race
    local _, _, race = UnitRace(uid)
    unitInfo["race"] = race

    -- Role
    local role = UnitGroupRolesAssigned(uid);
    unitInfo["role"] = role

    -- Rating
    if MS.db.global.ratings[guid]
    then
        unitInfo["rating"] = MS.db.global.ratings[guid]
    end
    unitInfo["badRatingCount"] = {}
    unitInfo["goodRatingCount"] = {}
    local message = 
    MS:SendCommMessage(
        "MS", 
        MS:createMessage("REQUEST_RATINGTABLE", nil),
        "PARTY"
    )

    self.partyMembers[uid] = unitInfo["GUID"]

    -- Keystones
    if uid == "player" then
        local playerKeystoneInfo = self:getCurrentKeyStone()
        unitInfo["keystoneInfo"] = playerKeystoneInfo
    else
        MS:SendCommMessage(
            "MS",
            MS:createMessage("REQUEST_KEYSTONE", nil),
            "WHISPER", unitInfo["name"].."-"..unitInfo["server"]
        )
    end

    self:insertUnittoDB(guid, unitInfo)
    MS:SendMessage("MSCustomEvent", "REFRESH_PANEL", unitInfo)
end

function MS.Data:getMemberBasicData(membersNum)
    self:getUnitBasicData("player")
    for i = 1, membersNum-1, 1
    do
        self:getUnitBasicData("party"..i)
    end
end

function MS.Data:getMemberRatings()
    local ratingTable = {}
    for uid, guid in pairs(self.partyMembers)
    do
        if uid ~= "player" then
            local score = MS.db.global.ratings[guid]
            ratingTable[guid] = score
        end
    end
    return ratingTable
end

function MS.Data:saveRating(guid, score)
    if not guid then
        return
    end
    self:insertDatatoDB(guid, "rating", score)
    MS.db.global.ratings[guid] = score
    MS:SendMessage("MSCustomEvent", "REFRESH_PANEL", MS.Data:selectUnitfromDB(guid))
    MS:SendMessage("MSCustomEvent", "REFRESH_DETAILS", MS.Data:selectUnitfromDB(guid))
    
    self:shareRatingTable()
end

function MS.Data:saveRatingFromHistory(guid, score)
    if not guid then
        return
    end
    self:insertDatatoDB(guid, "rating", score)
    MS.db.global.ratings[guid] = score
    for idx, historyBody in pairs(MS.db.global.history) do
        if type(historyBody) == "table" then
            if historyBody["key"] == guid then
                MS.db.global.history[idx]["value"]["rating"] = score
            end
        end
    end
    self:shareRatingTable()
    MS:SendMessage("MSCustomEvent", "REFRESH_HISTORY")
end

function MS.Data:saveRatingFromQC(guid, score)
    if not guid then
        return
    end
    self:insertDatatoDB(guid, "rating", score)
    MS.db.global.ratings[guid] = score
    self:shareRatingTable()
    MS:SendMessage("MSCustomEvent", "REFRESH_QC_PANEL", self:selectDatafromDB(guid, "uid"))
end

-- ---------------
-- Advanced
function MS.Data:getUnitAdvancedData(unit)
    ClearAchievementComparisonUnit()
    ClearInspectPlayer()

    if unit.uid then
        local gearSuccess = self:getUnitGearData(unit.uid)
        local achiSuccess = self:getUnitAchievementData(unit.uid)
        return gearSuccess or achiSuccess
    else
        return false
    end
end

function MS.Data:getUnitAchievementData(uid)
    local success = false
    local guid = self.partyMembers[uid]
    if guid then
        if SetAchievementComparisonUnit(uid) then
            success = true
        else
            success = false
        end
    end
    return success
end

function MS.Data:getUnitGearData(uid)
    local success = false
    local guid = self.partyMembers[uid]
    if guid then
        NotifyInspect(uid)
        success = true
    end
    return success
end


function MS.Data:getAchievementDataHandler(event, guid)
    local uid = self:selectDatafromDB(guid, "uid")
    if not uid then
        return
    end
    local mainAchi = nil
    local completed, month, day, year = GetAchievementComparisonInfo(MS.db.profile.mainAchiID)
    if completed then
        mainAchi = year.."/"..month.."/"..day
    else
        mainAchi = 0
    end
    local IDNumber, mainAchiName, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText, isGuildAch = GetAchievementInfo(MS.db.profile.mainAchiID)

    local cAchi1 = nil
    local completed, month, day, year = GetAchievementComparisonInfo(MS.db.profile.childAchi1ID)
    if completed then
        cAchi1 = year.."/"..month.."/"..day
    else
        cAchi1 = 0
    end
    local IDNumber, cAchi1Name, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText, isGuildAch = GetAchievementInfo(MS.db.profile.childAchi1ID)

    local cAchi2 = nil
    local completed, month, day, year = GetAchievementComparisonInfo(MS.db.profile.childAchi2ID)
    if completed then
        cAchi2 = year.."/"..month.."/"..day
    else
        cAchi2 = 0
    end
    local IDNumber, cAchi2Name, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText, isGuildAch = GetAchievementInfo(MS.db.profile.childAchi2ID)

    local cAchi3 = nil
    local completed, month, day, year = GetAchievementComparisonInfo(MS.db.profile.childAchi3ID)
    if completed then
        cAchi3 = year.."/"..month.."/"..day
    else
        cAchi3 = 0
    end
    local IDNumber, cAchi3Name, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText, isGuildAch = GetAchievementInfo(MS.db.profile.childAchi3ID)

    local dungeonCount = {}
    for i = 1, table.getn(MS.Const.dungeonIds), 1
    do
        dungeonCount[MS.Const.dungeonIds[i]] = GetComparisonStatistic(MS.Const.dungeonIds[i])
    end
    if guid == self.agent.curGUID then
        self:insertDatatoDB(guid, "mainAchi", mainAchi)
        self:insertDatatoDB(guid, "cAchi1", cAchi1)
        self:insertDatatoDB(guid, "cAchi2", cAchi2)
        self:insertDatatoDB(guid, "cAchi3", cAchi3)
        self:insertDatatoDB(guid, "mainAchiName", mainAchiName)
        self:insertDatatoDB(guid, "cAchi1Name", cAchi1Name)
        self:insertDatatoDB(guid, "cAchi2Name", cAchi2Name)
        self:insertDatatoDB(guid, "cAchi3Name", cAchi3Name)
        self:insertDatatoDB(guid, "dungeonCount", dungeonCount)
        MS:SendMessage("MSCustomEvent", "REFRESH_PANEL", MS.Data:selectUnitfromDB(guid))
    end
end


MS.Data.linkCache = {}
function MS.Data:searchCorruption(link)
    local value = self.linkCache[link]
    if not value then
        local itemString = strmatch(link, "item:([%-?%d:]+)")
        for index in gmatch(itemString, "%d+") do
            if MS.Const.corruptionData[index] then
                value = MS.Const.corruptionData[index]
                self.linkCache[link] = value
                break
            end
        end
    end
    return value
end

function MS.Data:getGearDataHandler(event, guid)
    local totalIlvl = 0
    local mainHandEquipLoc, offHandEquipLoc
    local totalCorruption = 0
    local totalC = 0
    local totalH = 0
    local totalM = 0
    local totalV = 0
    local totalCpercent = 0
    local totalHpercent = 0
    local totalMpercent = 0
    local totalVpercent = 0
    local totalDarkHeart = 0
    local essenseFlag = false

    local uid = self:selectDatafromDB(guid, "uid")
    if not uid then
        return
    end
    -- --------------------
    -- Spec
    local specID = GetInspectSpecialization(uid)
    local _, currentSpecName = GetSpecializationInfoByID(specID)

    -- --------------------
    -- 计算精华腐蚀减免
    local resistance = 0
    self.tmpTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    self.tmpTooltip:SetInventoryItem(uid, 2)
    for i = 1, 10 do
        local tex = _G[self.tmpTooltip:GetName().."Texture"..i]
        local texture = tex and tex:IsShown() and tex:GetTexture()
        if texture and MS.Const.essenceTextureIDs[texture] then
            resistance = 10
            break
        end
    end

    -- ---------------------
    -- 计算披风减免
    self.tmpTooltip:SetInventoryItem(uid, 15)
    for i = 1, self.tmpTooltip:NumLines() do
        local line = _G[self.tmpTooltip:GetName().."TextLeft"..i]
        local text = line and line:GetText()
        local value = text and strmatch(text, "(%d+)%s?"..ITEM_MOD_CORRUPTION_RESISTANCE)
        if value then
            resistance = resistance + value
        end
    end

    -- -----------------------
    -- 检索所有装备, 获取宝石，腐蚀
    local slotCount = 0
    local corruptionList = {}
    local links = {}
    for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
        if slot ~= INVSLOT_BODY and slot ~= INVSLOT_TABARD then
            local link = GetInventoryItemLink(uid, slot)
            if link then
                -- iLvl
                local _, _, _, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(link)
                if itemLevel then 
                    totalIlvl = totalIlvl + itemLevel
                end
                links[slot] = {["lvl"] = itemLevel, ["link"] = link}
                if slot == INVSLOT_MAINHAND then
                    mainHandEquipLoc = itemEquipLoc
                elseif slot == INVSLOT_OFFHAND then
                    offHandEquipLoc = itemEquipLoc
                end

                -- Corruption
                if IsCorruptedItem(link) then
                    local corruptionInfo = self:searchCorruption(link)
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
                        if(MS.Const.gemSlots[k]) then
                            slotCount = slotCount + v
                        end
                    end
                end

                -- Attribute

                self.tmpTooltip:SetInventoryItem(uid, slot)
                for i = 1, self.tmpTooltip:NumLines() do
                    local line = _G[self.tmpTooltip:GetName().."TextLeft"..i]
                    local text = line and line:GetText()
                    local valueC = text and strmatch(text, "+(%d+)%s?"..ITEM_MOD_CRIT_RATING_SHORT)
                    if valueC then
                        totalC = totalC + valueC
                    end

                    local valueH = text and strmatch(text, "+(%d+)%s?"..ITEM_MOD_HASTE_RATING_SHORT)
                    if valueH then
                        totalH = totalH + valueH
                    end

                    local valueM = text and strmatch(text, "+(%d+)%s?"..ITEM_MOD_MASTERY_RATING_SHORT)
                    if valueM then
                        totalM = totalM + valueM
                    end

                    local valueV = text and strmatch(text, "+(%d+)%s?"..ITEM_MOD_VERSATILITY)
                    if valueV then
                        totalV = totalV + valueV
                    end
                    
                    -- AzeriteEnssence
                    if slot == 2 then
                        if strmatch(text, "%s?"..L["Vision of Perfection"].."%s?") then
                            totalV = totalV + ((itemLevel - 517) / 3 * 2 + 113)
                        end
                    end

                    -- AzeriteEnpowered
                    if slot == 1 or slot == 3 or slot == 5 then
                        if strmatch(text, "- %s?"..L["Heart of Darkness"].."%s?") then
                            if MS.Const.darkHeartValue[itemLevel] then 
                                totalC = totalC + MS.Const.darkHeartValue[itemLevel]
                                totalH = totalH + MS.Const.darkHeartValue[itemLevel]                            
                                totalM = totalM + MS.Const.darkHeartValue[itemLevel]                          
                                totalV = totalV + MS.Const.darkHeartValue[itemLevel]
                            end
                        end
                        if strmatch(text, "- %s?"..L["Endless Hunger"].."%s?") then
                            if MS.Const.endlessHungerValue[itemLevel] then                     
                                totalV = totalV + MS.Const.endlessHungerValue[itemLevel]
                            end
                        end
                        if strmatch(text, "- %s?"..L["Blood Siphon"].."%s?") then
                            if MS.Const.bloodSiphonValue[itemLevel] then                
                                totalM = totalM + MS.Const.bloodSiphonValue[itemLevel]
                            end
                        end
                        if strmatch(text, "- %s?"..L["On My Way"].."%s?") then
                            if MS.Const.onMyWayValue[itemLevel] then
                                totalV = totalV + MS.Const.onMyWayValue[itemLevel]
                            end
                        end
                        if strmatch(text, "- %s?"..L["Lifespeed"].."%s?") then
                            if MS.Const.lifeSpeedValue[itemLevel] then
                                totalH = totalH + MS.Const.lifeSpeedValue[itemLevel]
                            end
                        end
                    end
                end

            end
        end
    end

    -- Apply Race Ability to Attributes
    local race = MS.Data:selectDatafromDB(guid, "race")
    local attrFactor = MS.Const.raceAttributeFactor[race]
    if attrFactor then
        if race == 4 then
            -- Night El
            local h, m = GetGameTime()
            if h < 6 or h >= 18 then
                totalHpercent = totalHpercent + 100 * attrFactor["H"]
            else
                totalCpercent = totalCpercent + 100 * attrFactor["C"]
            end
        elseif race == 1 then
            totalC = totalC * attrFactor["C"]
            totalH = totalH * attrFactor["H"]
            totalM = totalM * attrFactor["M"]
            totalV = totalV * attrFactor["V"]
        else
            totalCpercent = totalCpercent + 100 * attrFactor["C"]
            totalHpercent = totalHpercent + 100 * attrFactor["H"]
            totalMpercent = totalMpercent + 100 * attrFactor["M"]
            totalVpercent = totalVpercent + 100 * attrFactor["V"]

        end
    end
    -- Apply Corruption
    -- Crit
    local critFactor = 0
    if corruptionList[315554] then
        critFactor = critFactor + corruptionList[315554]["count"] * 6
    end
    if corruptionList[315557] then
        critFactor = critFactor + corruptionList[315557]["count"] * 9
    end
    if corruptionList[315558] then
        critFactor = critFactor + corruptionList[315558]["count"] * 12
    end
    totalC = totalC * (1 + 0.01*critFactor)

    -- Haste
    local hasteFactor = 0
    if corruptionList[315544] then
        hasteFactor = hasteFactor + corruptionList[315544]["count"] * 6
    end
    if corruptionList[315545] then
        hasteFactor = hasteFactor + corruptionList[315545]["count"] * 9
    end
    if corruptionList[315546] then
        hasteFactor = hasteFactor + corruptionList[315546]["count"] * 12
    end
    totalH = totalH * (1 + 0.01*hasteFactor)

    -- Mastery
    local masteryFactor = 0
    if corruptionList[315529] then
        masteryFactor = masteryFactor + corruptionList[315529]["count"] * 6
    end
    if corruptionList[315530] then
        masteryFactor = masteryFactor + corruptionList[315530]["count"] * 9
    end
    if corruptionList[315531] then
        masteryFactor = masteryFactor + corruptionList[315531]["count"] * 12
    end
    totalM = totalM * (1 + 0.01*masteryFactor)

    -- Versality
    local verFactor = 0
    if corruptionList[315549] then
        verFactor = verFactor + corruptionList[315549]["count"] * 6
    end
    if corruptionList[315552] then
        verFactor = verFactor + corruptionList[315552]["count"] * 9
    end
    if corruptionList[315553] then
        verFactor = verFactor + corruptionList[315553]["count"] * 12
    end
    totalV = totalV * (1 + 0.01*verFactor)

    -- Calculate attribute percent
    totalCpercent = totalCpercent + totalC / MS.Const.attributePersentBase[self:selectDatafromDB(guid, "classIndex")][specID]["C"] + MS.Const.attributeBasic[self:selectDatafromDB(guid, "classIndex")][specID]["C"]
    totalHpercent = totalHpercent + totalH / MS.Const.attributePersentBase[self:selectDatafromDB(guid, "classIndex")][specID]["H"] + MS.Const.attributeBasic[self:selectDatafromDB(guid, "classIndex")][specID]["H"]
    totalMpercent = totalMpercent + totalM / MS.Const.attributePersentBase[self:selectDatafromDB(guid, "classIndex")][specID]["M"] + MS.Const.attributeBasic[self:selectDatafromDB(guid, "classIndex")][specID]["M"]
    totalVpercent = totalVpercent + totalV / MS.Const.attributePersentBase[self:selectDatafromDB(guid, "classIndex")][specID]["V"] + MS.Const.attributeBasic[self:selectDatafromDB(guid, "classIndex")][specID]["V"]

    local stat = {
        ["C"] = totalCpercent,
        ["H"] = totalHpercent,
        ["M"] = totalMpercent,
        ["V"] = totalVpercent,
    }

    local numSlots
    if mainHandEquipLoc and offHandEquipLoc then
        numSlots = 16
    else
        numSlots = 15
    end

    if guid == self.agent.curGUID then
        self:insertDatatoDB(guid, "specID", specID)
        self:insertDatatoDB(guid, "currentSpecName", currentSpecName)
        self:insertDatatoDB(guid, "ilvl", math.modf(totalIlvl / numSlots))
        self:insertDatatoDB(guid, "corruptionValue", totalCorruption - resistance)
        self:insertDatatoDB(guid, "corruptionList", corruptionList)
        self:insertDatatoDB(guid, "gemSlot", slotCount)
        self:insertDatatoDB(guid, "stat", stat)
        self:insertDatatoDB(guid, "gearLinks", links)
        MS:SendMessage("MSCustomEvent", "REFRESH_PANEL", self:selectUnitfromDB(guid))
    end
end


-- ---------------
-- Sharing
function MS.Data:shareVersion()
    MS:SendCommMessage(
        "MS",
        MS:createMessage("VERSION", MS.Const.VERSION),
        "PARTY"
    )
end

function MS.Data:shareKeystone()
    local keystoneInfoBody = {}
    keystoneInfoBody["PlayerGUID"] = self.playerGUID
    keystoneInfoBody["keystoneInfo"] = self:selectDatafromDB(self.playerGUID, "keystoneInfo")
    MS:SendCommMessage(
        "MS",
        MS:createMessage("KEYSTONE_INFORMATION", keystoneInfoBody),
        "PARTY"
    )

    -- ---------------
    -- AngreKeystones
    -- ---------------
    MS:SendCommMessage(
        "AngryKeystones",
        "Schedule|request",
        "PARTY"
    )
end

function MS.Data:shareRatingTable()
    local ratingTable = MS.Data:getMemberRatings()
    ratingTable["SenderGUID"] = self.playerGUID
    MS:SendCommMessage(
        "MS",
        MS:createMessage("RATINGTABLE", ratingTable),
        "PARTY"
    )
end

function MS.Data:shareData()
    self:shareVersion()
    self:shareKeystone()
    self:shareRatingTable()
end

-- ----------------
-- Refresh

function MS.Data:refreshAll()
    local membersNum = GetNumGroupMembers()
    if membersNum >= 6 then
        return
    end

    self.partyMembers = {}

    -- Get basic information
    self:getMemberBasicData(membersNum)

    MS:SendMessage("MSCustomEvent", "TOGGLE_PANEL", self.partyMembers)
    MS:SendMessage("MSCustomEvent", "REFRESH_QC", unitInfo)

    local newDB = {}
    for uid, guid in pairs(self.partyMembers)
    do
        newDB[guid] = self:selectUnitfromDB(guid)
        -- Add unit to refresh agent's queue
        self.agent:addUnit({uid = uid, guid = guid})
    end
    self.db = nil
    self.db = newDB
    -- Garbage relase
    collectgarbage("collect")

    -- Share Data
    self:shareData()

    -- Handle Unit Advanced Information
    self.agent:handleUnitQueue()
end

function MS.Data:refreshUnit(idx)
    local uid = MS.Const.partyMembersTempl[idx+1]
    self:getUnitBasicData(uid)
    MS:SendMessage("MSCustomEvent", "TOGGLE_PANEL", self.partyMembers)
    local guid = self.partyMembers[uid]
    -- Add unit to refresh agent's queue
    self.agent:addUnit({uid = uid, guid = guid})
    self.agent:handleUnitQueue()
end


function MS.Data:onPartyChanged()
    self:refreshAll()
end


-- ----------------------------------
-- Refresh Core
-- ----------------------------------

-- Define Queue

MS.Data.Queue = {}
function MS.Data.Queue:new(obj)
    local queue = obj or {first = nil, last = nil, keys={}}
    setmetatable(queue, self)
    self.__index = self
    return queue
end

function MS.Data.Queue:push(key, value)
    if self.keys[key] then
        return
    end
    if not self.first then
        self[key] = {value = value, next = nil}
        self.keys[key] = 1
        self.first = self[key]
        self.last = self[key]
    else
        self[key] = {value = value, next = nil}
        self.keys[key] = 1
        self.last.next = self[key]
        self.last = self[key]
    end
end

function MS.Data.Queue:pop()
    local cur = self.first
    if cur then
        self.first = cur.next
        return cur.value
    else
        self.first = nil
        self.last = nil
        return nil
    end
end

function MS.Data.Queue:removeKeys(key)
    self.keys[key] = nil
end

function MS.Data.Queue:ifInQueue (key)
    return self.keys[key]
end

-- Define Agent

MS.Data.Agent = {}
function MS.Data.Agent:new(obj)
    local agent = obj or {queue = MS.Data.Queue:new(), lockValue = false, curGUID = nil}
    setmetatable(agent, self)
    self.__index = self
    return agent
end

function MS.Data.Agent:addUnit(unit)
    if not self.queue:ifInQueue(unit.guid) then
        self.queue:push(unit.guid, unit)
        MS:SendMessage("MSCustomEvent", "TRIGGER_REFRESH_ICON", unit.uid)
    end
end


function MS.Data.Agent:getLock()
    return self.lockValue
end

function MS.Data.Agent:lock()
    self.lockValue = true
end

function MS.Data.Agent:release()
    self.lockValue = false
end

function MS.Data.Agent:handleUnitQueue()
    if not self:getLock() then
        self:lock()
        self:handleUnitQueueOnce()
    end
end

function MS.Data.Agent:handleUnitQueueOnce()
    local unit = self.queue:pop()
    if self.curGUID then
        self.queue:removeKeys(self.curGUID)
        MS:SendMessage("MSCustomEvent", "SHUTDOWN_REFRESH_ICON", self.curUID)
        MS:SendMessage("MSCustomEvent", "REFRESH_PANEL", MS.Data:selectUnitfromDB(self.curGUID))
        MS:SendMessage("MSCustomEvent", "UPDATE_DETAILS", MS.Data:selectUnitfromDB(self.curGUID))
        MS.Data:addHistory(MS.Data:selectUnitfromDB(self.curGUID))
    end
    if unit then
        self.curGUID = unit.guid
        self.curUID = unit.uid
        local success = MS.Data:getUnitAdvancedData(unit)
        if success then
            MS:wait(3, self.handleUnitQueueOnce, self)
        else
            self:handleUnitQueueOnce()
        end
    else
        self.curGUID = nil
        self.curUID = nil
        self:release()
    end
end


-- ------------------------------------
-- History

-- ----------
-- List

MS.Data.List = {}
function MS.Data:createHistory()
    local list = {first = 0, cur = nil, keys = {}}
    return list
end

function MS.Data:pushHistory(list, key, value)
    if list.keys[key] then
        return
    end
    list.keys[key] = 1
    local first = list.first + 1
    list.first = first
    list[first] = {}
    list[first]["key"] = key
    list[first]["value"] = value
    if getn(list) > 10 then
        list.keys[list[first-10]["key"]] = nil
        list[first-10] = nil
    end
end

function MS.Data:addHistory(unitInfo)
    if not unitInfo then
        return
    end
    if not MS.db.global.history or MS:getN(MS.db.global.history) == 0 then
        MS.db.global.history = MS.Data:createHistory()
    end
    if unitInfo["GUID"] ~= MS.Data.playerGUID then
        self:pushHistory(MS.db.global.history, unitInfo["GUID"], unitInfo)
    end

    MS:SendMessage("MSCustomEvent", "REFRESH_HISTORY")
end



-- ------------------------------------
-- Register Event

function MS.Data:registerEvent()
    MS:RegisterEvent("INSPECT_ACHIEVEMENT_READY", function(...)
        self:getAchievementDataHandler(...)
    end)

    MS:RegisterEvent("INSPECT_READY", function(...)
        self:getGearDataHandler(...)
    end)

    MS:RegisterEvent("GROUP_ROSTER_UPDATE", function(...)
        self:onPartyChanged(...)
    end)
end



-- ------------------------------------
-- Initialize

function MS.Data:Initialize()
    if not MS.Data.initialed then
        MS.Data.initialed = true
        MS:Print("Initializing data engine...")
        self.tmpTooltip = CreateFrame("GameTooltip", "TempTooltip", nil, "GameTooltipTemplate")
        MS.Data:registerEvent()
        self.agent = self.Agent:new()
        MS:wait(3, self.refreshAll, self)
    end
end