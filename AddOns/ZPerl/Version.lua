local AddonName, Addon = ...

local ZPerl = CreateFrame("Frame")

ZPerl:RegisterEvent("ADDON_LOADED")

ZPerl:SetScript("OnEvent", function(self, event, ...)
	if not ZPerl[event] then
		return
	end

	ZPerl[event](ZPerl, ...)
end)

function ZPerl:ADDON_LOADED(addon)
	if addon ~= AddonName then
		return
	end

	RegisterAddonMessagePrefix("ZPerlVersion")

	self:RegisterEvents()

	self.playerName = string.gsub(UnitName("player").."-"..GetRealmName(), "%s+", "")
	self.version = GetAddOnMetadata("ZPerl", "Version")

	self:UnregisterEvent("ADDON_LOADED")
end

function ZPerl:PLAYER_ENTERING_WORLD()
	if self:GetScript("OnUpdate") then
		self.timer = 0
	else
		self:SetScript("OnUpdate", self.VersionOnUpdate)
	end

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function ZPerl:GROUP_ROSTER_UPDATE()
	if self:GetScript("OnUpdate") then
		self.timer = 0
	else
		self:SetScript("OnUpdate", self.VersionOnUpdate)
	end
end

function ZPerl:CHAT_MSG_ADDON(prefix, msg, channel, sender)
	if prefix ~= "ZPerlVersion" or sender == self.playerName then
		return
	end

	if self:CompareVersion(msg) then
		print("|cFF50C0FFZ-Perl|r:", XPERL_NEW_VERSION_DETECTED, "|cFFFF0000"..msg.."|r")

		self.newVersion = msg

		self:UnregisterEvent("CHAT_MSG_ADDON")
	end
end

function ZPerl:RegisterEvents()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("CHAT_MSG_ADDON")
end

function ZPerl:VersionOnUpdate(elapsed)
	self.time = (self.time or 0) + elapsed
	if self.time < 3 then
		return
	end
	self.time = 0

	ZPerl:SendVersion()

	self:SetScript("OnUpdate", nil)
end

function ZPerl:CompareVersion(version)
	local _, _, major, minor, build = string.find(self.version, "(%d+)%.(%d+)%.(%d+)")

	local _, _, newMajor, newMinor, newBuild = string.find(version, "(%d+)%.(%d+)%.(%d+)")

	if newMajor > major then
		return true
	elseif newMajor < major then
		return false
	end

	if newMinor > minor then
		return true
	elseif newMinor < minor then
		return false
	end

	if newBuild > build then
		return true
	elseif newBuild < build then
		return false
	end

	return false
end

function ZPerl:SendVersion()
	local channel

	if IsInRaid() then
		channel = (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID"
	elseif IsInGroup() then
		channel = (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY"
	elseif IsInGuild() then
		channel = "GUILD"
	end

	if channel then
		local version = self.version

		if self.newVersion then
			version = self.newVersion
		end

		SendAddonMessage("ZPerlVersion", version, channel)
	end
end
