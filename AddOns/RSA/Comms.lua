local RSA =  RSA or LibStub("AceAddon-3.0"):GetAddon("RSA")
local L = LibStub("AceLocale-3.0"):GetLocale("RSA")

local HighNumber = time()*time()
local CanAnnounce
local GroupMembers = {}
local GroupLeader
local GroupAssistants = {}

RSA.Comm = {}
RSA.Comm.GroupStatus = {}



function RSA.Comm.Registry()
	C_ChatInfo.RegisterAddonMessagePrefix("RSA")
	--RSA:RegisterComm("RSA", "OnCommReceived")

	C_ChatInfo.RegisterAddonMessagePrefix("RSA_Status")
	RSA:RegisterComm("RSA_Status","OnStatusReceived")

	C_ChatInfo.RegisterAddonMessagePrefix("RSA_Version")
	RSA:RegisterComm("RSA_Version","OnVersionCheckReceived")
end

function RSA.VersionCheck(Guild)
	if IsInRaid() then
		RSA.SendCommMessage("RSA","RSA_Version",RSA.db.global.revision, (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID")
	elseif IsInGroup() then
		RSA.SendCommMessage("RSA","RSA_Version",RSA.db.global.revision, (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY")
	elseif IsInGuild() and Guild == true then
		RSA.SendCommMessage("RSA","RSA_Version",RSA.db.global.revision, "GUILD")
	end
end

function RSA.OnVersionCheckReceived(addon, prefix, message, channel, sender)
	local revision = tonumber(message)
	if sender == UnitName("player") then return end -- Don't compare with self.
	if (tonumber(RSA.db.global.revision) < revision) and not RSA.Comm.OutOfDateMessage then -- Someone else has a newer version
		RSA.Comm.OutOfDateMessage = true
		RSA.Print_Self(L["Your version of RSA is out of date. You may want to grab the latest version from https://www.curseforge.com/wow/addons/rsa"])
	elseif tonumber(RSA.db.global.revision) > revision then -- We're on a newer version, but they should know this because we sent a comm message
	else -- their version is our version
	end
end

function RSA.CheckGroupStatus(self,Status,event)
	if not RSA.db.global.ID then
		RSA.db.global.ID = RSA.GetMyRandomNumber()
	end
	if IsInRaid() then
		RSA.SendCommMessage("RSA","RSA_Status",RSA.db.global.ID, (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID")
	elseif IsInGroup() then
		RSA.SendCommMessage("RSA","RSA_Status",RSA.db.global.ID, (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY")
	else
		RSA.Comm.GroupAnnouncer = nil
		wipe(GroupMembers)
		wipe(GroupAssistants)
	end
	if Status == "Joined" then
		RSA.VersionCheck()
	end
end

function RSA.OnStatusReceived(addon, prefix, message, channel, sender)
	--[[local random = string.gsub(message,"%d*%-","")
	local namebytes = string.gsub(message,"%-%d*","")
	local fullnumber = string.gsub(message,"%-*","")]]--

	local SenderInfo = {
		["Name"] = sender,
		--["Random"] = tonumber(random),
		--["Bytes"] = tonumber(namebytes),
		["ID"] = tonumber(message),
	}
	GroupMembers[sender] = SenderInfo

	for k,v in pairs(GroupMembers) do
		if GroupMembers[k].ID < HighNumber then
			RSA.Comm.GroupAnnouncer = GroupMembers[k].ID
		end
	end
	if RSA.Comm.GroupAnnouncer == tonumber(RSA.db.global.ID) then -- Group Announcer is me.
	else -- Group Announcer is someone else.
	end

end

function RSA.GroupLeft()
	RSA.Comm.GroupAnnouncer = nil
	wipe(GroupMembers)
	wipe(GroupAssistants)
end


--RSA:RegisterEvent("PLAYER_TARGET_CHANGED","CheckGroupStatus") -- TESTING ONLY
--RSA:RegisterEvent("PLAYER_STARTED_MOVING","GroupLeft") -- TESTING ONLY

RSA:RegisterEvent("PLAYER_ENTERING_WORLD","CheckGroupStatus")
RSA:RegisterEvent("GROUP_ROSTER_UPDATE","CheckGroupStatus")
RSA:RegisterEvent("GROUP_FORMED","CheckGroupStatus","Joined")
RSA:RegisterEvent("GROUP_JOINED","CheckGroupStatus","Joined")
RSA:RegisterEvent("GROUP_LEFT","GroupLeft")
