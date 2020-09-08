-- ---------------------------
-- Handle Achievement UI Error
-- These code inspired by Aibuyi Addon, Thanks!
-- ---------------------------
local MS = Minesweeperr

MS.Error = {}
function MS.Error:hook(name, func)
	self.origins = self.origins or {}
	self.hooks = self.hooks or {}

	if not self.origins[name] then
		self.origins[name] = _G[name]
		_G[name] = function(...) return self.hooks[name](...) end
	end
	self.hooks[name] = func
end


local errorHandleEventFrame = CreateFrame("Frame", "ErrorHandleEventFrame", eventFrame)
errorHandleEventFrame:RegisterEvent("ADDON_LOADED")
errorHandleEventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        if ...=="Blizzard_InspectUI" then
            if InspectGuildFrame_Update then
                MS.Error:hook("InspectGuildFrame_Update", function()
                    if InspectFrame.unit and GetGuildInfo(InspectFrame.unit) then
                        MS.Error.origins["InspectGuildFrame_Update"]()
                    end
                end);
            end
        elseif ...=="Blizzard_AchievementUI" then
            if AchievementFrameComparison_UpdateStatusBars then
                MS.Error:hook("AchievementFrameComparison_UpdateStatusBars", function(id)
                    if id and id~="summary" then
                        MS.Error.origins["AchievementFrameComparison_UpdateStatusBars"](id)
                    end
                end)
            end
        end
    end
end)

