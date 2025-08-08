

--mythic+ extension for Details! Damage Meter
---@diagnostic disable-next-line: undefined-global
local Details = Details
local detailsFramework = DetailsFramework
local _

---@type string, private
local tocFileName, private = ...

---@type detailsmythicplus
local addon = private.addon

--localization
local L = detailsFramework.Language.GetLanguageTable(tocFileName)
local Translit = LibStub("LibTranslit-1.0")

local CONST_COMM_PREFIX = "DMPE" --details mythic plus extension
local CONST_COMM_LIKE_PREFIX = "L"

addon.Comm.RegisteredCallbacks = {} --table to store the registered callbacks for the comms

--register the addon comm
function addon.Comm.Initialize()
    --register the prefix
	if (C_ChatInfo) then
        ---@diagnostic disable-next-line: undefined-field
		C_ChatInfo.RegisterAddonMessagePrefix(CONST_COMM_PREFIX)
	else
		RegisterAddonMessagePrefix(CONST_COMM_PREFIX)
	end

    --frame to receive the events from the comms
    local commEventFrame = CreateFrame("frame")

    --funcion to handle the received comms
    local onReceiveComm = function(self, event, prefix, text, channel, sender, target, zoneChannelId, localId, name, instanceId)
        if (prefix == CONST_COMM_PREFIX) then
            sender = Ambiguate(sender, "none")

            --decode the data
            if (C_EncodingUtil) then
                text = C_EncodingUtil.DecodeBase64(text)
                if (text) then
                    ---@diagnostic disable-next-line: undefined-global
                    text = C_EncodingUtil.DecompressString(text, Enum.CompressionMethod.Deflate)
                    if (text) then
                        local dataPrefix = text:match("^(.-),")
                        text = text:sub(#dataPrefix + 2) --remove the prefix from the text
                        text = C_EncodingUtil.DeserializeCBOR(text)
                        if (text) then
                            --process the data
                            local callback = addon.Comm.RegisteredCallbacks[dataPrefix]
                            if (callback) then
                                --call the callback with the sender and data
                                xpcall(callback, geterrorhandler(), sender, text)
                            else
                                private.log("No callback registered for prefix: " .. dataPrefix)
                            end
                        end
                    end
                end
            end
        end
    end

    --register the event to receive addon messages
    commEventFrame:RegisterEvent("CHAT_MSG_ADDON")
    commEventFrame:SetScript("OnEvent", onReceiveComm)
end

--which function should be called when the prefix is received
---@param prefix string
---@param callback fun(sender: string, data: any)
function addon.Comm.Register(prefix, callback)
    assert(type(prefix) == "string", "addon.Comm.Register: prefix must be a string")
    assert(type(callback) == "function", "addon.Comm.Register: callback must be a function")

    --store the function to be called when the prefix is received
    addon.Comm.RegisteredCallbacks[prefix] = callback
end

function addon.Comm.Send(prefix, data, channel)
    assert(type(prefix) == "string", "addon.Comm.Send: prefix must be a string")
    assert(data, "addon.Comm.Send: data can't be nil")
    assert(type(channel) == "string" or channel == nil, "addon.Comm.Send: channel must be a string or nil (default is 'PARTY')")

    channel = channel or "PARTY"

    --is this mop friendly? (challenge mode)
	if (C_EncodingUtil) then
		local dataSerialized = C_EncodingUtil.SerializeCBOR(data)
		if (dataSerialized) then
            dataSerialized = prefix .. "," .. dataSerialized
            ---@diagnostic disable-next-line: undefined-global
			local dataCompressed = C_EncodingUtil.CompressString(dataSerialized, Enum.CompressionMethod.Deflate, Enum.CompressionLevel.OptimizeForSize)
			if (dataCompressed) then
                --encode the data to base64
				local dataEncoded = C_EncodingUtil.EncodeBase64(dataCompressed)
                if (dataEncoded) then
                    ---@diagnostic disable-next-line: undefined-field
                    C_ChatInfo.SendAddonMessage(CONST_COMM_PREFIX, dataEncoded, channel)
                end
			end
		end
	end
end
