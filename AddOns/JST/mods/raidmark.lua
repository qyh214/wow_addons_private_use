local T, C, L, G = unpack(select(2, ...))
local addon_name = G.addon_name

----------------------------------------------------------
----------------[[    获得团队标记提醒    ]]-----------------
----------------------------------------------------------
local RMFrame = CreateFrame("Frame", addon_name.."RMFrame", FrameHolder)

RMFrame.old = 0

RMFrame:SetScript("OnEvent", function(self, event)
	if C.DB["GeneralOption"]["rm"] then
		local index = GetRaidTargetIndex("player")
		if index and self.old ~= index then
			self.old = index
			T.Start_Text_Timer(self.text_frame, 3, string.format(L["当前标记"], T.FormatRaidMark(index)))
		elseif not index then	
			self.old = 0
			T.Stop_Text_Timer(self.text_frame)
		end
	else
		self.old = 0
		T.Stop_Text_Timer(self.text_frame)
	end
end)

T.EditRMFrame = function(option)
	if not RMFrame.text_frame then
		RMFrame.text_frame = T.CreateAlertTextShared("RMFrame", 2)
	end
	
	if option == "all" or option == "enable" then
		if C.DB["GeneralOption"]["rm"] then		
			RMFrame:RegisterEvent("RAID_TARGET_UPDATE")
		else
			RMFrame:UnregisterEvent("RAID_TARGET_UPDATE")
		end
	end
end

