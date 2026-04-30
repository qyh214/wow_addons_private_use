local appName, app = ...
---@class AbilityTimeline
local private = app
local SharedMedia = LibStub("LibSharedMedia-3.0")

local VOICE_LINES = {
    "5",
    "4",
    "3",
    "2",
    "1",
}
local VOICES = {
    "Male_1",
    "Male_2",
    "Female_1",
    "AI_Male_1",
    "AI_Male_2",
    "AI_Female_1",
    "AI_Female_2",
}
for _, voice in ipairs(VOICES) do
    for _, line in ipairs(VOICE_LINES) do
        SharedMedia:Register("sound", voice .. "_" .. line,
            [[Interface\AddOns\AbilityTimeline\Media\Sounds\]] .. voice .. [[\]] .. line .. [[.ogg]])
    end
end

local active_voices = {}

local getVoice = function()
    for _, voice in ipairs(VOICES) do
        if not active_voices[voice] then
            return voice
        end
    end
    return VOICES[math.random(1, #VOICES)]
end

private.AUDIO_ALERT_FRAME = CreateFrame("Frame", "AT_AudioAlertFrame", UIParent)

local SOUND_ALERTS = {
    [5] = "5",
    [4] = "4",
    [3] = "3",
    [2] = "2",
    [1] = "1",
}
private.REGISTERED_AUDIO_ALERTS = {}
private.AUDIO_ALERT_FRAME:SetScript("OnUpdate", function(self, elapsed)
    for id, value in pairs(private.REGISTERED_AUDIO_ALERTS) do
        local remaining = C_EncounterTimeline.GetEventTimeRemaining(id)

        if not remaining or remaining <= 0 then
            active_voices[value.voice] = nil
            private.REGISTERED_AUDIO_ALERTS[id] = nil
            return
        end
        for soundTime, soundName in pairs(SOUND_ALERTS) do
            if remaining and remaining <= soundTime and not tContains(value.played, soundTime) then
                table.insert(value.played, soundTime)
                local soundFile = SharedMedia:Fetch("sound", value.voice .. "_" .. soundName)
                if soundFile then
                    PlaySoundFile(soundFile, "Master")
                end
            end
        end
    end
end)
private.playAudioAlert = function(eventInfo)
    if private.REGISTERED_AUDIO_ALERTS[eventInfo.id] then
        return
    end
    local voice = getVoice()
    active_voices[voice] = true
    private.REGISTERED_AUDIO_ALERTS[eventInfo.id] = { voice = voice, played = {} }
end
