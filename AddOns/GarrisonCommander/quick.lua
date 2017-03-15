local me, ns = ...
ns.Configure()
local addon=addon --#addon
local _G=_G
local GMF=GMF
local GSF=GSF
local qm=addon:NewSubModule("Quick") --#qm
local missionDone
local shipyardDone
local format=format
local ipairs=ipairs
local NavalDomination={
	Alliance=39068,
	Horde=39246
}
local autologout=false
local questid=NavalDomination[UnitFactionGroup("player")]
function qm:OnInitialized()
	ns.step="none"
end
local watchdog=0
local function HasShipTable()
	return ns.quests[39068] or ns.quests[39246] -- Naval Domination
end
function addon:missionDone()
	missionDone=true
end
function addon:shipyardDone()
	shipyardDone=true
end

-- backported from LibInit 41
function addon:Popup(msg,timeout,OnAccept,OnCancel,data,StopCasting)
	if InCombatLockdown() then
		return self:ScheduleLeaveCombatAction("Popup",msg,timeout,OnAccept,OnCancel,data,StopCasting)
	end
	msg=msg or "Something strange happened"
	if type(timeout)=="function" then
		StopCasting=data
		data=OnCancel
		OnAccept=timeout
		timeout=60
	end
	StaticPopupDialogs["LIBINIT_POPUP"] = StaticPopupDialogs["LIBINIT_POPUP"] or
	{
	text = msg,
	showAlert = true,
	timeout = timeout or 60,
	exclusive = true,
	whileDead = true,
	interruptCinematic = true
	};
	local popup=StaticPopupDialogs["LIBINIT_POPUP"]
	if StopCasting then
		popup.OnShow=StopSpellCasting
		popup.OnHide=StopSpellCastingCleanup
	else
		popup.OnShow=nil
		popup.OnHide=nil
	end
	popup.timeout=timeout
	popup.text=msg
	popup.OnCancel=nil
	popup.OnAccept=OnAccept
	popup.button1=ACCEPT
	popup.button2=nil
	if (OnCancel) then
		if (type(OnCancel)=="function") then
			popup.OnCancel=OnCancel
		end
		popup.button2=CANCEL
	else
		popup.button1=OKAY
	end
	return StaticPopup_Show("LIBINIT_POPUP",timeout,SECONDS,data);
end
function addon:LogoutTimer(dialog,elapsed)
	if dialog.which ~="LIBINIT_POPUP" then return end
	local text = _G[dialog:GetName().."Text"];
	local timeleft = ceil(dialog.timeleft);
	local which=dialog.which	
	if ( timeleft < 60 ) then
		text:SetFormattedText(StaticPopupDialogs[which].text, timeleft, SECONDS);
	else
		text:SetFormattedText(StaticPopupDialogs[which].text, ceil(timeleft / 60), MINUTES);
	end	
end
function addon:LogoutPopup(timeout)
	local msg=''
	if addon:HasSalvageYard() then
		local salvage=0
		local freeSlots=0
		for i=0,NUM_BAG_SLOTS do
			freeSlots=freeSlots+(GetContainerNumFreeSlots(i) or 0)
		end
		for _,id in ipairs(ns.allSalvages) do 
			salvage=salvage+(GetItemCount(id) or 0)
		end
		if salvage > 5 then
			timeout=timeout+5
			msg=format(L["You have %d items to salvage"],salvage)
			if freeSlots < 5 then
				msg=msg .. format(L[" and only %d free slots in your bags"],freeSlots)
			end
			msg=C(msg,'green').."\n"
		end
	end
	if not autologout then
		msg=msg .. LOGOUT
	else
		msg=msg .. CAMP_TIMER
	end
	local popup=addon:Popup(msg,timeout or 10,
		function(dialog,data,data2)
			addon:Unhook(dialog,"OnUpdate")
			Logout()
		end,
		function(dialog,data,timeout)
			addon:Unhook(dialog,"OnUpdate")
			if timeout=="timeout" and autologout then Logout() end
			autologout=false
			missionDone=false
			shipyardDone=false
			StaticPopup_Hide("LIBINIT_POPUP")
		end
	)
	if autologout then
		self:SecureHookScript(popup, "OnUpdate", "LogoutTimer")
	end
end
function qm:RunQuick()
	local completeButton=GMF:IsVisible() and GarrisonCommanderQuickMissionComplete or GCQuickShipMissionCompletionButton
	local main=GMF:IsVisible() and GMF or GSF
	if not ns.quick then 
		HideUIPanel(main)
		if not G.HasShipyard() then
			shipyardDone=true
		end
		if missionDone and shipyardDone then
			addon:LogoutPopup(5)
		else 
			autologout=false
		end
		return 
	end
	while not qm.Mission do
		if completeButton:IsVisible() then
			completeButton:Click()
			return -- Waits to be rescheduled by mission completion
		end
		if not main.MissionControlTab:IsVisible() then
			main.tabMC:Click()
			break
		end
		if (main.MissionControlTab.runButton:IsEnabled()) then
			main.MissionControlTab.runButton:Click()
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
function addon:EnableAutoLogout()
	autologout=true
end
function addon:RunQuick(force)
	local main=GMF:IsVisible() and GMF or GSF
	if main.tabMC:GetChecked() then
		self:OpenMissionControlTab()
		self:ScheduleTimer("RunQuick",0.2)
		return
	end
	if not IsShiftKeyDown()  and not force then
		self:Popup(L["Are you sure to start Garrison Commander Auto Pilot?\n(Keep shift pressed while clicking to avoid this question)"].."\n" ..
				C(format(L["Keep pressed %s while opening table to automate processing"],CTRL_KEY),"green"),10,
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
