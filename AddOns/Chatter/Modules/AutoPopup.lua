local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Automatic Whisper Windows", "AceHook-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Automatic Whisper Windows"]

-- built in now, just toggle the Blizzard cvars
function mod:OnEnable()
	SetCVar("whisperMode", "popout")
	InterfaceOptionsSocialPanelChatStyle_SetChatStyle("im")
end

function mod:OnDisable()
	SetCVar("whisperMode", "inline")
	InterfaceOptionsSocialPanelChatStyle_SetChatStyle("classic")
end