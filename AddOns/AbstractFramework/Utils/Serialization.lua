---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- compress and serialize
---------------------------------------------------------------------
local LibDeflate = AF.Libs.LibDeflate
local deflateConfig = {level = 9}
local LibSerialize = AF.Libs.LibSerialize

---@param data any
---@param isForAddonChannel boolean?
---@return string encoded
function AF.Serialize(data, isForAddonChannel)
    -- serialize
    local serialized = LibSerialize:Serialize(data)

    -- compress
    local compressed = LibDeflate:CompressDeflate(serialized, deflateConfig)

    -- encode
    if isForAddonChannel then
        return LibDeflate:EncodeForWoWAddonChannel(compressed)
    else
        return LibDeflate:EncodeForPrint(compressed)
    end
end

---@param encoded string
---@param isForAddonChannel boolean?
---@return any data
function AF.Deserialize(encoded, isForAddonChannel)
    -- decode
    local decoded
    if isForAddonChannel then
        decoded = LibDeflate:DecodeForWoWAddonChannel(encoded)
    else
        decoded = LibDeflate:DecodeForPrint(encoded)
    end

    -- decompress
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then
        AF.Debug("Error decompressing")
        return
    end

    -- deserialize
    local success, data = LibSerialize:Deserialize(decompressed)
    if not success then
        AF.Debug("Error deserializing")
        return
    end
    return data
end