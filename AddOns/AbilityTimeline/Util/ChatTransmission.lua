local appName, app = ...
---@class AbilityTimeline
local private = app
local AceCom = LibStub("AceComm-3.0")
local CHAT_LINK_FORMAT = "|cffffff00|Hgarrmission:abilitytimeline-%s:%i|h[Ability Timeline Reminder]|h|r"
local CHAT_LINK_MESSAGE = "BetterTimeline Reminder: %i"
local COM_CHAT_PREFIX = "AbilityTimeline"
local CHAT_REQUEST_PREFIX = "request:"
local CHAT_REQUEST_MESSAGE = CHAT_REQUEST_PREFIX .. "%i"
local CHAT_REMINDERS_PREFIX = "reminders-"
-- Format: reminders-dungeonID-journalID-instanceID-encodedData
local CHAT_REMINDERS_MESSAGE = CHAT_REMINDERS_PREFIX .. "%i-%i-%i-%s"
local FindComChannel = function()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT"
    elseif IsInRaid() then
        return "RAID"
    elseif IsInGroup() then
        return "PARTY"
    else
        return nil
    end
end
local ExportToChat = function(reminders, encounterID, target)
    local encodedReminders = private.ImportUtil:ExportAsEncoded(reminders, encounterID)
    if C_ChatInfo.InChatMessagingLockdown() then
        private.Debug("ExportToChat: In chat messaging lockdown, cannot send reminders.")
        return
    elseif FindComChannel() == nil then
        private.Debug("ExportToChat: Not in a group, cannot send reminders.")
        return
    end

    local journalEncounterID = private.TIMINGS_EDITOR_WINDOW.journalEncounterID
    local journalInstanceID = private.TIMINGS_EDITOR_WINDOW.journalInstanceID


    if not journalEncounterID or not journalInstanceID then
        private.Debug("ExportToChat: Cannot send reminders - missing journal metadata for encounter " .. encounterID)
        private.Debug("ExportToChat: journalEncounterID=" ..
        tostring(journalEncounterID) .. ", journalInstanceID=" .. tostring(journalInstanceID))
        return
    end

    local exportText = CHAT_REMINDERS_MESSAGE:format(encounterID, journalEncounterID, journalInstanceID, encodedReminders)
    AceCom:SendCommMessage(COM_CHAT_PREFIX, exportText,
        "WHISPER",
        target, 'BULK', nil, nil)
end

local ChatHandler = function(prefix, message, _, sender)
    if C_ChatInfo.InChatMessagingLockdown() or prefix ~= COM_CHAT_PREFIX or sender == UnitName("player") then return end
    if string.find(message, CHAT_REQUEST_PREFIX) then
        private.Debug("ChatHandler: Received reminder request from " .. sender)
        local encounterID = tonumber(string.match(message, CHAT_REQUEST_PREFIX .. "(%d+)"))
        if encounterID then
            local reminders = private.db.profile.reminders[encounterID]
            if reminders and #reminders > 0 then
                ExportToChat(reminders, encounterID, sender)
            else
                private.Debug("ChatHandler: No reminders found for encounter ID " .. encounterID)
            end
        else
            private.Debug("ChatHandler: Invalid request format couldn't find encounter ID" .. message)
        end
    elseif string.find(message, CHAT_REMINDERS_PREFIX) then
        local prefix, encounterIDStr, journalIDStr, instanceIDStr, encodedReminders = strsplit("-", message, 5)
        private.Debug("ChatHandler: Received reminders from " .. sender .. " for encounter ID " .. encounterIDStr)

        local encounterID = tonumber(encounterIDStr)
        local journalEncounterID = tonumber(journalIDStr)
        local journalInstanceID = tonumber(instanceIDStr)

        if not encounterID or not encodedReminders or encodedReminders == "" then
            private.Debug("ChatHandler: Invalid reminders data received - missing encounterID or encodedReminders")
            return
        end

        if not journalEncounterID or not journalInstanceID then
            private.Debug("ChatHandler: Invalid reminders data received - missing journal metadata")
            return
        end

        local name = EJ_GetEncounterInfo(journalEncounterID)
        if not name then
            private.Debug("ChatHandler: Failed to lookup encounter name for journalEncounterID " .. journalEncounterID)
            return
        end

        private.RegisterEncounter(encounterID, {
            name = name,
            instanceID = journalInstanceID,
            journalID = journalEncounterID
        }, true)

        local params = {
            journalEncounterID = journalEncounterID,
            journalInstanceID = journalInstanceID,
            dungeonEncounterID = encounterID,
        }

        -- Open timings editor and show import dialog with the received data
        private.openTimingsEditor(params)
        private.showImportDialog(encounterID, private.TIMINGS_EDITOR_WINDOW, encodedReminders)
    end
end

private.StartExportingToChat = function(encounterID)
    if C_ChatInfo.InChatMessagingLockdown() then
        private.Debug("ExportToChat: In chat messaging lockdown, cannot send reminders.")
        return
    elseif FindComChannel() == nil then
        private.Debug("ExportToChat: Not in a group, cannot send reminders.")
        return
    end
    local name = UnitNameUnmodified("player")
    local realm = GetNormalizedRealmName()
    local msg = CHAT_LINK_MESSAGE:format(encounterID)
    private.Debug("Sending reminder link to " ..
        FindComChannel() .. " for encounter ID " .. encounterID .. " link: " .. msg)
    C_ChatInfo.SendChatMessage(msg, FindComChannel())
end

AceCom:RegisterComm(COM_CHAT_PREFIX, ChatHandler)

-- this is inspired by WeakAuras / MDT link handling
hooksecurefunc("SetItemRef", function(link, text)
    if C_ChatInfo.InChatMessagingLockdown() then
        private.Debug("SetItemRef: In chat messaging lockdown, cannot request reminders.")
        return
    end
    if (link and link:sub(0, 27) == "garrmission:abilitytimeline") then
        local rest = link:sub(29, string.len(link))
        local sender, encounterIDStr = string.match(rest, "([^:]+):(%d+)")

        -- If shift-clicked, insert the original message into chat frame for forwarding (only own links)
        if IsShiftKeyDown() and sender and encounterIDStr then
            local name, realm = string.match(sender, "([^-]+)-(.+)")
            -- Only allow forwarding our own links
            if name == UnitName("player") and (not realm or realm == GetNormalizedRealmName()) then
                local encounterID = tonumber(encounterIDStr)
                local originalMessage = CHAT_LINK_MESSAGE:format(encounterID)
                local chatFrame = DEFAULT_CHAT_FRAME
                if chatFrame and chatFrame.editBox then
                    if not chatFrame.editBox:IsShown() then
                        ChatEdit_ActivateChat(chatFrame.editBox)
                    end
                    chatFrame.editBox:Insert(originalMessage)
                end
            end
            return
        end

        if sender and encounterIDStr then
            local name, realm = string.match(sender, "([^-]+)-(.+)")
            if name == UnitName("player") and (not realm or realm == GetNormalizedRealmName()) then
                private.Debug("Ignoring reminder link from self: " .. sender)
                return
            end
            local encounterID = tonumber(encounterIDStr)
            private.Debug("Requesting Reminders from " .. sender .. " for encounter " .. encounterID)
            local requestText = CHAT_REQUEST_MESSAGE:format(encounterID)
            AceCom:SendCommMessage(COM_CHAT_PREFIX, requestText,
                "WHISPER",
                sender, 'NORMAL', nil, nil)
        else
            private.Debug("Failed to parse reminder link: " .. link)
        end
        return
    end
end)

local filterfunc = function(self, event, msg, author, ...)
    if msg and string.find(msg, CHAT_LINK_MESSAGE:sub(1, 24)) then
        local encounterID = tonumber(string.match(msg, "(%d+)"))
        return false, CHAT_LINK_FORMAT:format(author, encounterID), author, ...
    end
    return false, msg, author, ...
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filterfunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", filterfunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", filterfunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", filterfunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", filterfunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", filterfunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filterfunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filterfunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filterfunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", filterfunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", filterfunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", filterfunc)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", filterfunc)
