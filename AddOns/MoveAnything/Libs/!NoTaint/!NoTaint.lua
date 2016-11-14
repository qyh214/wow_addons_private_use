do
	local function hook()
		PlayerTalentFrame_Toggle = function() 
			if not PlayerTalentFrame:IsShown() then 
				ShowUIPanel(PlayerTalentFrame)
				TalentMicroButtonAlert:Hide()
			else 
				PlayerTalentFrame_Close()
			end 
		end
		for i = 1, 10 do
			local tab = _G["PlayerTalentFrameTab"..i]
			if not tab then
				break
			end
			tab:SetScript("PreClick", function()
				for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
					local frame = _G["StaticPopup"..index]
					if not issecurevariable(frame, "which") then
						local info = StaticPopupDialogs[frame.which]
						if frame:IsShown() and info and not issecurevariable(info, "OnCancel") then
							info.OnCancel()
						end
						frame:Hide()
						frame.which = nil
					end
				end
			end)
		end
	end
	if IsAddOnLoaded("Blizzard_TalentUI") then
		hook()
	else
		local f = CreateFrame("Frame")
		f:RegisterEvent("ADDON_LOADED")
		f:SetScript("OnEvent", function(self, event, addon)
			if addon == "Blizzard_TalentUI" then
				self:UnregisterEvent("ADDON_LOADED")
				hook()
			end
		end)
	end
end