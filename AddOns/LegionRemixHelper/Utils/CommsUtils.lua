---@class AddonPrivate
local Private = select(2, ...)

local const = Private.constants

---@class CommsUtils
local commsUtils = {
    ---@type CallbackUtils
    callbackutils = nil,
    ---@type table<string, number>
    prefixes = {}
}
Private.CommsUtils = commsUtils

function commsUtils:Init()
    self.callbackUtils = Private.CallbackUtils
    if not C_ChatInfo.IsAddonMessagePrefixRegistered(const.ADDON_COMMS.PREFIX) then
        C_ChatInfo.RegisterAddonMessagePrefix(const.ADDON_COMMS.PREFIX)
    end

    Private.Addon:RegisterEvent("CHAT_MSG_ADDON", "CommsUtils_OnReceivedMessage", function(_, _, ...)
        self:OnReceivedMessage(...)
    end)
end

---@param encoded string
---@return table|nil data
function commsUtils:Decode(encoded)
    if not encoded then return end
    local decoded = C_EncodingUtil.DecodeBase64(encoded, Enum.Base64Variant.Standard)
    if not decoded then return end
    local decompressed = C_EncodingUtil.DecompressString(decoded, Enum.CompressionMethod.Deflate)
    if not decompressed then return end
    local data = C_EncodingUtil.DeserializeCBOR(decompressed)
    return data
end

---@param data table
---@return string encoded
function commsUtils:Encode(data)
    if not data then return "" end
    local serialized = C_EncodingUtil.SerializeCBOR(data)
    if not serialized then return "" end
    local compressed = C_EncodingUtil.CompressString(serialized, Enum.CompressionMethod.Deflate)
    if not compressed then return "" end
    local encoded = C_EncodingUtil.EncodeBase64(compressed, Enum.Base64Variant.Standard)
    return encoded or ""
end

---@param prefix string
---@param data string
---@param channel string
---@param sender string
function commsUtils:OnReceivedMessage(prefix, data, channel, sender)
    if prefix ~= const.ADDON_COMMS.PREFIX then return end
    if not data then return end
    local decoded = self:Decode(data)
    if not decoded then return end

    if type(decoded) == "table" and decoded.subPrefix then
        decoded.channel = channel
        decoded.sender = sender
        self:TriggerCallbacks(decoded.subPrefix, decoded)
    end
end

---@param unit UnitToken.base
---@return string target
function commsUtils:GetTargetFromUnitToken(unit)
    local name, realm = UnitName(unit)
    if realm and realm ~= "" then
        name = name .. "-" .. realm
    end
    return name
end

---@param subPrefix string
---@param data table
---@param channel string
---@param target string
function commsUtils:SendMessage(subPrefix, data, channel, target)
    data.subPrefix = subPrefix
    local encoded = self:Encode(data)
    if not encoded then return end

    C_ChatInfo.SendAddonMessage(const.ADDON_COMMS.PREFIX, encoded, channel, target)
end

---@param prefix string
---@param callbackFunction fun(data: table|nil|{sender:string, channel:string})
---@return CallbackObject|nil callbackObject
function commsUtils:AddCallback(prefix, callbackFunction)
    if not self.prefixes[prefix] then
        self.prefixes[prefix] = 0
    end
    self.prefixes[prefix] = self.prefixes[prefix] + 1
    return self.callbackUtils:AddCallback(prefix, callbackFunction)
end

---@param callbackObj CallbackObject
function commsUtils:RemoveCallback(callbackObj)
    local category = callbackObj:GetCategory()
    if category and self.prefixes[category] then
        local callbacks = self.callbackUtils:GetCallbacks(category)
        self.prefixes[category] = #callbacks > 0 and #callbacks or nil
    end
    self.callbackUtils:RemoveCallback(callbackObj)
end

---@param prefix string
---@param data table|nil|{sender:string, channel:string}
function commsUtils:TriggerCallbacks(prefix, data)
    local callbacks = self.callbackUtils:GetCallbacks(prefix)
    for _, callback in ipairs(callbacks) do
        callback:Trigger(data)
    end
end
