local RSA = LibStub('AceAddon-3.0'):GetAddon('RSA')
RSA.SendMessage = {}

function RSA.SendMessage.ChatFrame(message) -- Send a message to your default chat window.
	ChatFrame1:AddMessage("|cFFFF75B3RSA:|r " .. format(message))
end

function RSA.SendMessage.LibSink(message)
	RSA:Pour("|cFFFF75B3RSA:|r " .. message, 1, 1, 1)
end

function RSA.SendMessage.Instance(message) -- Send a message to /instance.
	if RSA.AnnouncementCheck() == false then return end
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
		SendChatMessage(format(message), "INSTANCE_CHAT", nil)
		return true
	end
end

function RSA.SendMessage.SmartGroup(message) -- Send a message to /instance, /raid, or /party in that order of priority.
	if RSA.AnnouncementCheck() == false then return end
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
		SendChatMessage(format(message), "INSTANCE_CHAT", nil)
	elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
		SendChatMessage(format(message), "RAID", nil)
	elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		SendChatMessage(format(message), "PARTY", nil)
	end
end

function RSA.SendMessage.Raid(message) -- Send a message to /raid or /instance. Prefers /raid if you are in an instance raid group and a home raid group.
	if RSA.AnnouncementCheck() == false then return end
	if IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
		if IsInRaid(LE_PARTY_CATEGORY_HOME) then
			SendChatMessage(format(message), "RAID", nil)
			return true
		else
			SendChatMessage(format(message), "INSTANCE_CHAT", nil)
			return true
		end
	elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
		SendChatMessage(format(message), "RAID", nil)
		return true
	end
end

function RSA.SendMessage.Party(message) -- Send a message to /party or /instance. Prefers /party if you are in an instance raid group and a home raid group.
	if RSA.AnnouncementCheck() == false then return end
	if IsInRaid(LE_PARTY_CATEGORY_INSTANCE) and IsInGroup(LE_PARTY_CATEGORY_HOME) then -- In LFR, and Home Party
		SendChatMessage(format(message), "PARTY", nil)
		return true
	elseif IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then -- In LFR
		SendChatMessage(format(message), "INSTANCE_CHAT", nil)
		return true
	elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and IsInGroup(LE_PARTY_CATEGORY_HOME) then -- In LFG, and Home Party
		SendChatMessage(format(message), "PARTY", nil)
		return true
	elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then -- In LFG
		SendChatMessage(format(message), "INSTANCE_CHAT", nil)
		return true
	elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		SendChatMessage(format(message), "PARTY", nil)
		return true
	end
end

function RSA.SendMessage.Say(message) -- Send a message to Say.
	if IsInInstance() then
		if RSA.AnnouncementCheck() == true then
			if RSA.db.profile.general.globalAnnouncements.groupToggles.say == true then
				if GetNumGroupMembers() > 0 or GetNumSubgroupMembers() > 0 then
					SendChatMessage(format(message), "SAY", nil)
				end
			elseif RSA.db.profile.general.globalAnnouncements.groupToggles.say == false then
				SendChatMessage(format(message), "SAY", nil)
			end
		end
	end
end

function RSA.SendMessage.Emote(message) -- Send a message to Emote.
	if RSA.AnnouncementCheck() == true then
		if RSA.db.profile.general.globalAnnouncements.groupToggles.emote == true then
			if GetNumGroupMembers() > 0 or GetNumSubgroupMembers() > 0 then
				SendChatMessage(format(message), "EMOTE", nil)
			end
		elseif RSA.db.profile.general.globalAnnouncements.groupToggles.emote == false then
			SendChatMessage(format(message), "EMOTE", nil)
		end
	end
end

function RSA.SendMessage.Yell(message) -- Send a message to Yell.
	if IsInInstance() then
		if RSA.AnnouncementCheck() == true then
			if RSA.db.profile.general.globalAnnouncements.groupToggles.yell == true then
				if GetNumGroupMembers() > 0 or GetNumSubgroupMembers() > 0 then
					SendChatMessage(format(message), "YELL", nil)
				end
			elseif RSA.db.profile.general.globalAnnouncements.groupToggles.yell == false then
				SendChatMessage(format(message), "YELL", nil)
			end
		end
	end
end

function RSA.SendMessage.RaidWarningFrame(message) -- Send a message locally to the raid warning frame. Only visible to the user.
	local RWColor = {r=1, g=1, b=1}
	RaidNotice_AddMessage(RaidWarningFrame, "|cFFFF75B3RSA:|r " .. format(message), RWColor)
end

function RSA.SendMessage.RaidWarning(message) -- Send a proper message to the raid warning frame.
	if RSA.AnnouncementCheck() == true then
		SendChatMessage(format(message), "RAID_WARNING", nil)
	end
end

function RSA.SendMessage.Whisper(message, target, replacements, destName)
	if RSA.db.profile.general.globalAnnouncements.alwaysWhisper == false then
		if RSA.AnnouncementCheck() == false then return end
	end
	if RSA.db.profile.general.globalAnnouncements.groupToggles.whisper == true then
		if not (GetNumGroupMembers() > 1) then return end
	end
	if replacements and destName then -- Until we replace all instances where this function is used, check if we have all args before trying to create new format message.
		if RSA.db.profile.general.replacements.target.alwaysUseName == true then
			replacements["[TARGET]"] = destName
		else
			replacements["[TARGET]"] = RSA.db.profile.general.replacements.target.replacement
		end
		local tosend = gsub(message, ".%a+.", replacements)
		SendChatMessage(format(tosend), "WHISPER", nil, target)
	else
		SendChatMessage(format(message), "WHISPER", nil, target)
	end

	-- Return to original value after whispering, so any subsequent messages for the same event use the correct value.
	replacements["[TARGET]"] = destName
end