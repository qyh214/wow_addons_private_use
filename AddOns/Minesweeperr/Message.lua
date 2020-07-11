local _, _MS = ...

_MS.MSG = {}

local _DC = _MS.DATACORE
local _U = _MS.UTILS
local _CD = _MS.CONSTDATA
local _EVENTUI = _MS.EVENTUI
local _UI = _MS.UI
local _MSG = _MS.MSG


-- --------------------------
-- Message part

_MSG.createMessage = _U.createMessage

function _MSG.messageHandler(self, event, prefix, message, distribution, sender)
    if prefix == "MS" then
        local func = "tmpMsg = "..message
        loadstring(func)()
        if not tmpMsg then
            return
        end
        if tmpMsg["type"] == "REFRESH_PANEL" then
            _UI:refreshInfoPanel(tmpMsg["body"])
        elseif tmpMsg["type"] == "REFRESH_DONE" then
            _UI:stopRefresh(tmpMsg["body"])
        elseif tmpMsg["type"] == "REFRESH_START" then
            _UI:startRefresh(tmpMsg["body"])
        elseif tmpMsg["type"] == "TOGGLE_PANEL" then
            _UI:togglePanel()
        elseif tmpMsg["type"] == "REQUEST_KEYSTONE" then
            _DC.shareKeystoneMessage()
        elseif tmpMsg["type"] == "KEYSTONE_INFORMATION" then
            local tmpInfo = tmpMsg["body"]
            local guid = tmpInfo["PlayerGUID"]
            local keystoneInfo = tmpInfo["keystoneInfo"]
            if guid and guid ~= _CD.playerGUID and _MS.DB[guid] and keystoneInfo then
                _DC:insertDatatoDB(guid, "keystoneInfo", keystoneInfo)
                
                local uid = _DC:selectDatafromDB(guid, "uid")
                _UI:refreshInfoPanel(uid)
            end
        elseif tmpMsg["type"] == "REQUEST_RATINGTABLE" then
            _DC.shareRatingTable()
        elseif tmpMsg["type"] == "RATINGTABLE" then
            local ratingTable = tmpMsg["body"]
            if ratingTable then
                if ratingTable["SenderGUID"] ~= _CD.playerGUID then
                    for guid, score in pairs(ratingTable)
                    do
                        if guid ~= "SenderGUID" then
                            if tonumber(score) == 1 then
                                _DC:insertDatatoDBTable(guid, "goodRatingCount", ratingTable["SenderGUID"])
                                _DC:removeDatatoDBTable(guid, "badRatingCount", ratingTable["SenderGUID"])
                            else
                                _DC:insertDatatoDBTable(guid, "badRatingCount", ratingTable["SenderGUID"])
                                _DC:removeDatatoDBTable(guid, "goodRatingCount", ratingTable["SenderGUID"])
                            end
                            
                            _UI:refreshInfoPanel(_DC:selectDatafromDB(guid, "uid"))
                        end
                    end
                end
            end
        elseif tmpMsg["type"] == "VERSION" then
            if tonumber(tmpMsg["body"]) > _MS.VERSION then
                _MS.VERSION = tonumber(tmpMsg["body"])
                print(L["updateNeeded"])
            end
        end
    elseif prefix == "AngryKeystones" then
        local matcher = "Schedule|"
        message = string.sub(message, #matcher + 1)
        if message ~= "request" and message ~= 0 then
            local arg1, arg2 = message:match("^(%d+):(%d+)$")
            local keystoneMapID = arg1 and tonumber(arg1)
            local keystoneLevel = arg2 and tonumber(arg2)
            local guid = _DC:selectDatafromDBByNameServer(sender, "GUID")
            if guid then
                local keystoneInfo = {}
                keystoneInfo["c"] = {}
                keystoneInfo["c"]["lvl"]= keystoneLevel
                keystoneInfo["c"]["nm"]= _CD.dungeonChallengeMapNames[keystoneMapID]
                _DC:insertDatatoDB(guid, "keystoneInfo", keystoneInfo)
                
                local uid = _DC:selectDatafromDB(guid, "uid")
                _UI:refreshInfoPanel(uid)
            end
        end
    end
end



if not C_ChatInfo.IsAddonMessagePrefixRegistered("MS") then
    C_ChatInfo.RegisterAddonMessagePrefix("MS")
	C_ChatInfo.RegisterAddonMessagePrefix("AngryKeystones")
end

local addonMSGEventFrame = CreateFrame("Frame", "AddonMSGEventFrame", _EVENTUI.eventFrame)
addonMSGEventFrame:RegisterEvent("CHAT_MSG_ADDON")
addonMSGEventFrame:SetScript("OnEvent", _MSG.messageHandler)
_EVENTUI.addonMSGEventFrame = addonMSGEventFrame