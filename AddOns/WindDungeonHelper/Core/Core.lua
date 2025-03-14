local W, F, L = unpack(select(2, ...))

local LibStub = _G.LibStub
local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix
local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")

local select = select
local GetInstanceInfo = GetInstanceInfo

local C_Timer_After = C_Timer.After

W:InitializeMetadata()

function W:OnInitialize()
	self:BuildDatabase()
	self:BuildOptions()

	C_ChatInfo_RegisterAddonMessagePrefix(self.AddonMsgPrefix)
end

local OpenRaidSupport = W:NewModule("OpenRaidSupport", "AceEvent-3.0")
function OpenRaidSupport:EventHandler()
	-- WindTools also has OpenRaid support
	if _G.WindTools then
		return
	end

	-- Disable OpenRaid support in Delve
	local difficulty = select(3, GetInstanceInfo())
	if difficulty and difficulty == 208 then
		return
	end

	if not openRaidLib.RequestKeystoneDataFromRaid() then
		openRaidLib.RequestKeystoneDataFromParty()
	end
end

OpenRaidSupport:RegisterEvent("GROUP_ROSTER_UPDATE", "EventHandler")
OpenRaidSupport:RegisterEvent("CHALLENGE_MODE_COMPLETED", "EventHandler")
OpenRaidSupport:RegisterEvent("CHALLENGE_MODE_START", "EventHandler")
OpenRaidSupport:RegisterEvent("CHALLENGE_MODE_RESET", "EventHandler")
C_Timer_After(1, OpenRaidSupport.EventHandler)

function W:OnProfileChanged()
	self.db = self.Database.profile
	for _, module in self:IterateModules() do
		if module.ProfileUpdate then
			module:ProfileUpdate()
		end
	end
end
