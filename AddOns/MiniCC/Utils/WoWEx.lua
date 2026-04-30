---@type string, Addon
local _, addon = ...

---@class WoWEx
local M = {}

addon.Utils.WoWEx = M

function M:IsAddOnEnabled(addonName)
    return C_AddOns.GetAddOnEnableState(addonName, UnitName("player")) == 2
end

function M:IsDandersEnabled()
    return M:IsAddOnEnabled("DandersFrames")
end

-- Resolves the TTS voice ID to use, validating storedID against available voices.
-- If storedID is valid it is returned as-is; if the voice list is available but
-- storedID is absent or unrecognised the first available voice is returned;
-- if no voice list is available the system default (or storedID) is used.
---@param storedID number?
---@return number
function M:ResolveVoiceID(storedID)
    local voices = C_VoiceChat and C_VoiceChat.GetTtsVoices and C_VoiceChat.GetTtsVoices() or nil
    if voices and #voices > 0 then
        if storedID ~= nil then
            for _, v in ipairs(voices) do
                if v.voiceID == storedID then
                    return storedID
                end
            end
        end
        return voices[1].voiceID
    end
    return storedID or C_TTSSettings.GetVoiceOptionID(0)
end

---Creates and populates a DurationObject from a start time and duration.
---@param startTime number  GetTime()-style timestamp when the effect began
---@param duration number   Total duration in seconds
---@param modRate number?   Optional haste modifier (defaults to 1.0)
---@return table DurationObject
function M:CreateDuration(startTime, duration, modRate)
    local d = C_DurationUtil.CreateDuration()
    d:SetTimeFromStart(startTime, duration, modRate)
    return d
end
