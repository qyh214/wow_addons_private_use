
local name, addon = ...

--------------------------------------------------------------------------------
-- Locals
--

local tostring = tostring
local format = format
addon.SendMessage = BigWigsLoader.SendMessage

--------------------------------------------------------------------------------
-- Event Handlers
--

local path = "Interface\\AddOns\\BigWigs_Voice_JINGJING\\Sounds\\%s.ogg"
local pathYou = "Interface\\AddOns\\BigWigs_Voice_JINGJING\\Sounds\\%sy.ogg"
local function handler(event, module, key, sound, isOnMe)
	local success = PlaySoundFile(format(isOnMe and pathYou or path, tostring(key)), "Master")
	if not success then
		addon:SendMessage("BigWigs_Sound", module, key, sound) 
	end
end

BigWigsLoader.RegisterMessage(addon, "BigWigs_Voice", handler)
BigWigsAPI.RegisterVoicePack("temp")
