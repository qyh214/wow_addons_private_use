local T, C, L, G = unpack(select(2, ...))
local addon_name = G.addon_name

---------------------------------------------------------
------------------[[    法术请求    ]]-------------------
---------------------------------------------------------
local send_text_frames = {}
local received_text_frames = {}

local ASFrame = CreateFrame("Frame", addon_name.."ASFrame", FrameHolder)

function ASFrame:CreateSendTextFrame(tag)
	local ind = #send_text_frames + 1	
	local frame = T.CreateAlertTextShared("ASFrameSend"..ind, 1)

	frame:HookScript("OnHide", function(self)
		self.active = false
	end)
	
	table.insert(send_text_frames, frame)
	
	return frame
end

function ASFrame:GetAvailableSendTextFrame(tag)
	for i, frame in pairs(send_text_frames) do
		if not frame.active then
			frame.active = true
			return frame
		end
	end
	
	local new_frame = self:CreateSendTextFrame(tag)
	new_frame.active = true
	return new_frame
end

function ASFrame:CreateReceivedTextFrame(tag)
	local ind = #received_text_frames + 1
	local frame = T.CreateAlertTextShared("ASFrameReceived"..ind, 2)

	frame:HookScript("OnHide", function(self)
		self.active = false
	end)
	
	table.insert(received_text_frames, frame)
	
	return frame
end

function ASFrame:GetAvailableReceivedTextFrame(tag)
	for i, frame in pairs(received_text_frames) do
		if not frame.active then
			frame.active = true
			return frame
		end
	end
	
	local new_frame = self:CreateReceivedTextFrame(tag)
	new_frame.active = true
	return new_frame
end

local Play_askspell_sound = function(player, spell)
	if C.DB["GeneralOption"]["cs_sound"] ~= "none" then
		if C.DB["GeneralOption"]["cs_sound"] ~= "speak" then
			T.PlaySound(C.DB["GeneralOption"]["cs_sound"])
		else
			T.SpeakText(spell..player)
		end
	end
end
T.Play_askspell_sound = Play_askspell_sound

---------------------------------------------------------
-----------------[[    法术请求 API   ]]-----------------
---------------------------------------------------------

local FormatAskedSpell = function(GUID, spellID, dur)
	local name = T.GetNameByGUID(GUID)
	local format_name = T.ColorNickNameByGUID(GUID)
	local unit = T.GUIDToUnit(GUID)
	local spell_name = C_Spell.GetSpellName(spellID)
	
	if name and format_name and spell_name then		
		Play_askspell_sound(name, spell_name)
		
		local text_frame = ASFrame:GetAvailableReceivedTextFrame()
		local str = string.format("%1$s %2$s %1$s", T.GetSpellIcon(spellID), format_name)
		T.Start_Text_Timer(text_frame, dur, str)
	
		T.GlowRaidFramebyUnit_Show("proc", "asspell", unit, {0, 1, 0}, dur)
	end
end
T.FormatAskedSpell = FormatAskedSpell

local HideAskedSpell = function(GUID)
	if GUID then
		local info = T.GetGroupInfobyGUID(GUID)
		if info then
			T.GlowRaidFramebyUnit_Hide("proc", "asspell", info.unit)
		end
	else
		T.GlowRaidFrame_HideAll("proc", "asspell")
	end
	T.Stop_Text_Timer(ASFrame.text_frame)
end
T.HideAskedSpell = HideAskedSpell

local SendSpellRequest = function(target, format_name, spellID)
	local spell_name = T.GetIconLink(spellID)
	
	T.addon_msg("AskSpell,"..spellID, "WHISPER", target)
	T.msg(string.format(L["法术请求已发送完整"], format_name, spell_name))
	
	local spell_icon = T.GetSpellIcon(spellID)
	local text_frame = ASFrame:GetAvailableSendTextFrame()
	T.Start_Text_Timer(text_frame, 3, string.format(L["法术请求已发送简略"], format_name, spell_icon))
end
T.SendSpellRequest = SendSpellRequest

local function UpdateAskSpell(event, ...)
	local channel, sender, GUID, message, spell = ...
	if message == "AskSpell" and spell then
		local spellID = tonumber(spell)
		local format_name = T.ColorNickNameByGUID(GUID)
		if spellID and C_Spell.GetSpellName(spellID) and format_name then
			T.msg(string.format(L["收到法术请求"], format_name, T.GetIconLink(spellID)))
			FormatAskedSpell(GUID, spellID, 3)
		end
	end
end

T.EditASFrame = function(option)
	if option == "all" or option == "enable" then
		if C.DB["GeneralOption"]["cs"] then
			if not ASFrame.registed then
				T.RegisterCallback("ADDON_MSG", UpdateAskSpell)
				ASFrame.registed = true
			end
		else
			if ASFrame.registed then
				T.UnregisterCallback("ADDON_MSG", UpdateAskSpell)
				ASFrame.registed = nil
			end
		end
	end
end

