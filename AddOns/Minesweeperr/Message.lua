local L = LibStub ("AceLocale-3.0"):GetLocale("Minesweeperr", true)
local MS = Minesweeperr

function MS:OnCommReceived(prefix, message, distribution, sender)
    if prefix == "MS" and MS.Data.initialed then
        local func = "tmpMsg = "..message
        loadstring(func)()
        if not tmpMsg then
            return
        end

        if tmpMsg["type"] == "VERSION" then
            if tonumber(tmpMsg["body"]) > MS.Const.VERSION then
                MS.Const.VERSION = tonumber(tmpMsg["body"])
                MS:Print(L["updateNeeded"])
            end
        elseif tmpMsg["type"] == "REQUEST_KEYSTONE" then
            MS.Data:shareKeystone()
        elseif tmpMsg["type"] == "KEYSTONE_INFORMATION" then
            local keystoneInfoBody = tmpMsg["body"]
            local guid = keystoneInfoBody["PlayerGUID"]
            local keystoneInfo = keystoneInfoBody["keystoneInfo"]
            if guid and keystoneInfo then
                MS.Data:insertDatatoDB(guid, "keystoneInfo", keystoneInfo)
                MS:SendMessage("MSCustomEvent", "REFRESH_PANEL", MS.Data:selectUnitfromDB(guid))
                MS:SendMessage("MSCustomEvent", "UPDATE_DETAILS", MS.Data:selectUnitfromDB(guid))
            end
        elseif tmpMsg["type"] == "REQUEST_RATINGTABLE" then
            MS.Data:shareRatingTable()
            
        elseif tmpMsg["type"] == "RATINGTABLE" then
            local ratingTable = tmpMsg["body"]
            if ratingTable then
                if ratingTable["SenderGUID"] ~= MS.Data.playerGUID then
                    for guid, score in pairs(ratingTable)
                    do
                        if guid ~= "SenderGUID" then
                            if tonumber(score) == 1 then
                                MS.Data:insertDatatoDBTable(guid, "goodRatingCount", ratingTable["SenderGUID"])
                                MS.Data:removeDatafromDBTable(guid, "badRatingCount", ratingTable["SenderGUID"])
                            else
                                MS.Data:insertDatatoDBTable(guid, "badRatingCount", ratingTable["SenderGUID"])
                                MS.Data:removeDatafromDBTable(guid, "goodRatingCount", ratingTable["SenderGUID"])
                            end
                            MS:SendMessage("MSCustomEvent", "REFRESH_PANEL", MS.Data:selectUnitfromDB(guid))
                            MS:SendMessage("MSCustomEvent", "UPDATE_DETAILS", MS.Data:selectUnitfromDB(guid))
                        end
                    end
                end
            end
        end
    elseif prefix == "AngryKeystones" and MS.Data.initialed  then
        local matcher = "Schedule|"
        message = string.sub(message, #matcher + 1)
        if message ~= "request" and message ~= 0 then
            local arg1, arg2 = message:match("^(%d+):(%d+)$")
            local keystoneMapID = arg1 and tonumber(arg1)
            local keystoneLevel = arg2 and tonumber(arg2)
            local guid = MS.Data:selectDatafromDBByNameServer(sender, "GUID")
            if guid then
                local keystoneInfo = MS.Data:selectDatafromDB(guid, "keystoneInfo")
                if not keystoneInfo then
                    keystoneInfo = {}
                end
                    keystoneInfo["c"] = {}
                    keystoneInfo["c"]["lvl"]= keystoneLevel
                    keystoneInfo["c"]["nm"]= MS.Const.dungeonChallengeMapNames[keystoneMapID]
                MS.Data:insertDatatoDB(guid, "keystoneInfo", keystoneInfo)
                
                MS:SendMessage("MSCustomEvent", "REFRESH_PANEL", MS.Data:selectUnitfromDB(guid))
            end
        end
    end
end