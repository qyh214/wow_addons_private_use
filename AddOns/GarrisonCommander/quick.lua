local me, ns = ...
ns.Configure()
local addon=addon --#addon
local _G=_G
local qm=addon:NewSubModule("Quick") --#qm
function qm:OnInitialized()
	ns.step="none"
end
local watchdog=0
function qm:RunQuick()
	if not ns.quick then return end
--[===[@debug@
	print("qm.RunQuick",watchdog)
--@end-debug@]===]
	while not qm.Mission do
		if GarrisonCommanderQuickMissionComplete:IsVisible() then
--[===[@debug@
			print("Quickcompletion")
--@end-debug@]===]
			GarrisonCommanderQuickMissionComplete:Click()
			return -- Waits to be rescheeduled by mission completion
		end
		if not GMF.MissionControlTab:IsVisible() then
--[===[@debug@
			print("MissionControl")
--@end-debug@]===]
			GMF.tabMC:Click()
			break
		end
		if (GMF.MissionControlTab.runButton:IsEnabled()) then
--[===[@debug@
			print("Run Missions")
--@end-debug@]===]
			GMF.MissionControlTab.runButton:Click()
		end
		break -- Never loop or we get stuck
	end
	watchdog=watchdog+1
	if watchdog > 10 then
		ns.quick=false
	end
	if ns.quick then
		return addon.ScheduleTimer(qm,"RunQuick",1)
	end

end
function addon:RunQuick(force)
--[===[@debug@
print("Runquick called")
--@end-debug@]===]
	if GMF.tabMC:GetChecked() then
		self:OpenMissionControlTab()
		self:ScheduleTimer("RunQuick",0.2)
		return
	end
	if not IsShiftKeyDown()  and not force then
		self:Popup(L["Are you sure to start Garrison Commander Auto Pilot?\n(Keep shift pressed while clicking to avoid this question)"],10,
			function()
				StaticPopup_Hide("LIBINIT_POPUP")
				return addon:RunQuick(true)
			end,
			function()
				StaticPopup_Hide("LIBINIT_POPUP")
			end)
	else
		ns.quick=true
		qm.watchdog=0
		return addon.ScheduleTimer(qm,"RunQuick",0.2)
	end
end