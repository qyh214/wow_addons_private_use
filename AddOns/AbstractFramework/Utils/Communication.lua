---@class AbstractFramework
local AF = _G.AbstractFramework

local LibDeflate = AF.Libs.LibDeflate
local deflateConfig = {level = 9}
local LibSerialize = AF.Libs.LibSerialize
local Comm = AF.Libs.Comm
local GetChannelName = GetChannelName

local function Serialize(data)
    local serialized = LibSerialize:Serialize(data) -- serialize
    local compressed = LibDeflate:CompressDeflate(serialized, deflateConfig) -- compress
    return LibDeflate:EncodeForWoWAddonChannel(compressed) -- encode
end

local function Deserialize(encoded)
    local decoded = LibDeflate:DecodeForWoWAddonChannel(encoded) -- decode
    local decompressed = LibDeflate:DecompressDeflate(decoded) -- decompress
    if not decompressed then
        AF.Debug("Error decompressing")
        return
    end
    local success, data = LibSerialize:Deserialize(decompressed) -- deserialize
    if not success then
        AF.Debug("Error deserializing")
        return
    end
    return data
end

---@param prefix string max 16 characters
---@param callback fun(data: any?, sender: string, channel: string)
function AF.RegisterComm(prefix, callback)
    Comm:RegisterComm(prefix, function(prefix, encoded, channel, sender)
        local data = Deserialize(encoded)
        callback(data, sender, channel)
    end)
end

---@param prefix string max 16 characters
---@param data any
---@param target string
---@param priority string "BULK", "NORMAL", "ALERT".
---@param callbackFn fun(callbackArg: any?, sentBytes: number, totalBytes: number)
---@param callbackArg any? any data you want to pass to the callback function
function AF.SendCommMessage_Whisper(prefix, data, target, priority, callbackFn, callbackArg)
    local encoded = Serialize(data)
    Comm:SendCommMessage(prefix, encoded, "WHISPER", target, priority, callbackFn, callbackArg)
end

---@param prefix string max 16 characters
---@param data any
---@param priority string "BULK", "NORMAL", "ALERT".
---@param callbackFn fun(callbackArg: any?, sentBytes: number, totalBytes: number)
---@param callbackArg any? any data you want to pass to the callback function
function AF.SendCommMessage_Group(prefix, data, priority, callbackFn, callbackArg)
    local encoded = Serialize(data)
    local channel
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        channel = "INSTANCE_CHAT"
    elseif IsInRaid() then
        channel = "RAID"
    else
        channel = "PARTY"
    end
    Comm:SendCommMessage(prefix, encoded, channel, nil, priority, callbackFn, callbackArg)
end

---@param prefix string max 16 characters
---@param data any
---@param isOfficer boolean if true, send to officer chat, otherwise guild chat
---@param priority string "BULK", "NORMAL", "ALERT".
---@param callbackFn fun(callbackArg: any?, sentBytes: number, totalBytes: number)
---@param callbackArg any? any data you want to pass to the callback function
function AF.SendCommMessage_Guild(prefix, data, isOfficer, priority, callbackFn, callbackArg)
    local encoded = Serialize(data)
    Comm:SendCommMessage(prefix, encoded, isOfficer and "OFFICER" or "GUILD", nil, priority, callbackFn, callbackArg)
end

---@param prefix string max 16 characters
---@param data any
---@param channelName string
---@param priority string "BULK", "NORMAL", "ALERT".
---@param callbackFn fun(callbackArg: any?, sentBytes: number, totalBytes: number)
---@param callbackArg any? any data you want to pass to the callback function
function AF.SendCommMessage_Channel(prefix, data, channelName, priority, callbackFn, callbackArg)
    local encoded = Serialize(data)
    local channelId = GetChannelName(channelName)
    if channelId == 0 then
        AF.Debug("Channel not found: " .. channelName)
    else
        Comm:SendCommMessage(prefix, encoded, "CHANNEL", channelId, priority, callbackFn, callbackArg)
    end
end