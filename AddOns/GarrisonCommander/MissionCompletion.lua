local me, ns = ...
ns.Configure()
local addon=addon --#addon
local shipyard
local _G=_G
local GMF=GMF
local GSF=GSF
local GHF=GHF
local GMFMissions=GarrisonMissionFrameMissions
local GSFMissions=GarrisonMissionFrameMissions
local GHFMissions=GarrisonMissionFrameMissions
local GARRISON_CURRENCY=GARRISON_CURRENCY
local GARRISON_SHIP_OIL_CURRENCY=_G.GARRISON_SHIP_OIL_CURRENCY
local SEAL_CURRENCY=994
local LE_FOLLOWER_TYPE_GARRISON_6_0=_G.LE_FOLLOWER_TYPE_GARRISON_6_0 -- 1
local LE_FOLLOWER_TYPE_SHIPYARD_6_2=_G.LE_FOLLOWER_TYPE_SHIPYARD_6_2 -- 2
local LE_FOLLOWER_TYPE_GARRISON_7_0=_G.LE_FOLLOWER_TYPE_GARRISON_7_0 -- 4
local pairs=pairs
local format=format
local strsplit=strsplit
local generated
local shipsnumber=0
local salvages={
114120,114119,114116}
local module=addon:NewSubClass('MissionCompletion') --#Module
function module:GenerateMissionCompleteList(title,anchor)
	local w=AceGUI:Create("GCMCList")
--[===[@debug@
	title=format("%s %s %s",title,w.frame:GetName(),GetTime()*1000)
--@end-debug@]===]
	w:SetTitle(title)
	w:SetCallback("OnClose",function(widget) widget:Release() return module:MissionsCleanup() end)
	--report:SetPoint("TOPLEFT",GMFMissions.CompleteDialog.BorderFrame)
	--report:SetPoint("BOTTOMRIGHT",GMFMissions.CompleteDialog.BorderFrame)
	w:ClearAllPoints()
	w:SetPoint("TOP",anchor)
	w:SetPoint("BOTTOM",anchor)
	w:SetWidth(500)
	w:SetParent(anchor)
	w.frame:SetFrameStrata("HIGH")
	return w
end
--[===[@debug@
function addon.ShowRewards()
	module:GenerateMissionCompleteList("Test",UIParent)
end
--@end-debug@]===]
local cappedCurrencies={
	GARRISON_CURRENCY,
	GARRISON_SHIP_OIL_CURRENCY
}

local missions={}
local followerType=LE_FOLLOWER_TYPE_GARRISON_6_0
local missionsFrame
local panel
local states={}
local rewards={
	items={},
	followerBase={},
	followerXP=setmetatable({},{__index=function() return 0 end}),
	currencies=setmetatable({},{__index=function(t,k) rawset(t,k,{icon="",qt=0}) return t[k] end}),
}
local scroller
local report
local timer
local function stopTimer()
	if (timer) then
		module:CancelTimer(timer)
		timer=nil
	end
end
local function startTimer(delay,event,...)
	delay=delay or 0.2
	event=event or "LOOP"
	stopTimer()
	timer=module:ScheduleRepeatingTimer("MissionAutoComplete",delay,event,...)
	--[===[@debug@
	print("Timer rearmed for",event,delay)
	--@end-debug@]===]
end
function module:MissionsCleanup()
	local f=panel
	local fmissions=missionsFrame
	local module=followerType==LE_FOLLOWER_TYPE_GARRISON_6_0 and addon or addon:GetModule(LE_FOLLOWER_TYPE_SHIPYARD_6_2 and "ShipYard" or "OrderHall")
	self:Events(false)
	stopTimer()
	f.MissionTab.MissionList.CompleteDialog:Hide()
	f.MissionComplete:Hide()
	f.MissionCompleteBackground:Hide()
	f.MissionComplete.currentIndex = nil
	f.MissionTab:Show()
	-- Re-enable "view" button
	fmissions.CompleteDialog.BorderFrame.ViewButton:SetEnabled(true)
	module:OpenLastTab()
	if panel==GHF then return end
	f:UpdateMissions()
	f:CheckCompleteMissions()
end
function module:Events(on)
	if (on) then
		self:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_LOOT","MissionAutoComplete")
		self:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE","MissionAutoComplete")
		self:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE","MissionAutoComplete")
		self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED","MissionAutoComplete")
		self:RegisterEvent("GARRISON_FOLLOWER_REMOVED","MissionAutoComplete")
	else
		self:UnregisterAllEvents()
	end
end
function module:CloseReport()
	if report then pcall(report.Close,report) report=nil end
	if GSF and GSF:IsVisible() then
	--[===[@debug@
		print "Ship close mission"
	--@end-debug@]===]
		GSF:CloseMissionComplete()
	elseif GMF and GMF:IsVisible() then
	--[===[@debug@
		print "Garr close mission"
	--@end-debug@]===]
		GMF:CloseMissionComplete()
	elseif GHF and GHF:IsVisible() then
	--[===[@debug@
		print "Hall close mission"
	--@end-debug@]===]
		GHF:CloseMissionComplete()
	end
	addon:OpenMissionsTab()
	addon:RefreshParties()
	addon:RefreshMissions()
end
function module:MissionComplete(this,button,skiprescheck)
	followerType=this.missionType
	missions=G.GetCompleteMissions(followerType)
	shipyard=addon:GetModule("ShipYard")
	shipsnumber=shipyard:GetTotFollowers()
	local module=self:GetMissionModule(followerType)
	missionsFrame=module:GetMissions()
	panel=module:GetMain()
	if (missions and #missions > 0) then
		this:SetEnabled(false)
		missionsFrame.CompleteDialog.BorderFrame.ViewButton:SetEnabled(false) -- Disabling standard Blizzard Completion
		wipe(rewards.followerBase)
		wipe(rewards.followerXP)
		wipe(rewards.currencies)
		wipe(rewards.items)
		local message=C("WARNING",'red')
		local wasted={}

		for i=1,#missions do
			for k,v in pairs(missions[i].followers) do
--				rewards.followerBase[v]=self:GetAnyData(followerType,v,'qLevel',0)
				rewards.followerBase[v]=self:GetAnyData(followerType,v)
			end
			for k,v in pairs(missions[i].rewards) do
				if v.itemID then GetItemInfo(v.itemID) end -- tickling server
				if v.currencyID and tContains(cappedCurrencies,v.currencyID) then
					wasted[v.currencyID]=(wasted[v.currencyID] or 0) + v.quantity
				end
			end
			local m=missions[i]
--totalTimeString, totalTimeSeconds, isMissionTimeImproved, successChance, partyBuffs, isEnvMechanicCountered, xpBonus, materialMultiplier, goldMultiplier = C_Garrison.GetPartyMissionInfo(MISSION_PAGE_FRAME.missionInfo.missionID);

			local _
			_,_,m.isMissionTimeImproved,m.successChance,_,_,m.xpBonus,m.resourceMultiplier,m.goldMultiplier=G.GetPartyMissionInfo(m.missionID)
		end
		local stop
		for id,qt in pairs(wasted) do
			local name,current,_,_,_,cap=GetCurrencyInfo(id)
			--[===[@debug@
			print(name,current,qt,cap)
			--@end-debug@]===]
			current=current+qt
			if current+qt > cap then
				message=message.."\n"..format(L["Capped %1$s. Spend at least %2$d of them"],name,current+qt-cap)
				stop =true
			end
		end
		if stop and not skiprescheck then
			self:Popup(message.."\n" ..format(L["If you %s, you will loose them\nClick on %s to abort"],ACCEPT,CANCEL),0,
				function()
					StaticPopup_Hide("LIBINIT_POPUP")
					module:MissionComplete(this,button,true)
				end,
				function()
					StaticPopup_Hide("LIBINIT_POPUP")
					this:SetEnabled(true)
					missionsFrame.CompleteDialog.BorderFrame.ViewButton:SetEnabled(true)
					panel:Hide()
					ns.quick=false

				end
			)
			return
		end
		report=self:GenerateMissionCompleteList("Missions' results",panel)
		report:SetUserData('missions',missions)
		report:SetUserData('current',1)
		self:Events(true)
		self:MissionAutoComplete("INIT")
		this:SetEnabled(true)
	end
end
function module:GetMission(missionID)
	if not report then
		return
	end
	local missions=report:GetUserData('missions')
	if missions then
		for i=1,#missions do
			if missions[i].missionID==missionID then
				return missions[i]
			end
		end
	end
end
function module:MissionAutoComplete(event,ID,arg1,arg2,arg3,arg4,...)
-- C_Garrison.MarkMissionComplete Mark mission as complete and prepare it for bonus roll, da chiamare solo in caso di successo
-- C_Garrison.MissionBonusRoll
--[===[@debug@
	print("evt",event,ID,arg1 or'',arg2 or '',arg3 or '',...)
--@end-debug@]===]
	if event=="LOOT" then
		return self:MissionsPrintResults()
	end
	local current=report:GetUserData('current')
	local currentMission=report:GetUserData('missions')[current]
	local missionID=currentMission and currentMission.missionID or 0
	-- GARRISON_FOLLOWER_XP_CHANGED: followerID, xpGained, actualXp, newLevel, quality
	if (event=="GARRISON_FOLLOWER_XP_CHANGED") then
		ID=arg1
		arg1=arg2
		if tonumber(arg1,0) then
			--report:AddFollower(ID,arg1,arg2)
			rewards.followerXP[ID]=rewards.followerXP[ID]+tonumber(arg1) or 0
		end
		return
	-- GARRISON_MISSION_BONUS_ROLL_LOOT: itemID
	elseif (event=="GARRISON_MISSION_BONUS_ROLL_LOOT") then
		if (missionID) then
			rewards.items[format("%d:%s",missionID,ID)]=1
		else
			rewards.items[format("%d:%s",0,ID)]=1
		end
		return
	-- GARRISON_FOLLOWER_REMOVED
	elseif (event=="GARRISON_FOLLOWER_REMOVED") then
		-- gestire la distruzione di un follower... senza il follower
	-- GARRISON_MISSION_COMPLETE_RESPONSE: missionID, requestCompleted, succeeded
	elseif (event=="GARRISON_MISSION_COMPLETE_RESPONSE") then
		if (not arg1) then
			-- We need to call server again
			currentMission.state=0
		elseif (arg2) then -- success, we need to roll
			currentMission.state=1
		else -- failure, just print results
			currentMission.state=2
		end
		startTimer(0.1)
		return
	-- GARRISON_MISSION_BONUS_ROLL_COMPLETE: missionID, requestCompleted; happens after C_Garrison.MissionBonusRoll
	elseif (event=="GARRISON_MISSION_BONUS_ROLL_COMPLETE") then
		if (not arg1) then
			-- We need to call server again
			currentMission.state=1
		else
			currentMission.state=3
		end
		startTimer(0.1)
		return
	else -- event == LOOP or INIT
		if (currentMission) then
			local step=currentMission.state or -1
			if (step<1) then
				step=0
				currentMission.state=0
				currentMission.goldMultiplier=currentMission.goldMultiplier or 1
				currentMission.xp=select(2,G.GetMissionInfo(currentMission.missionID))
				report:AddMissionButton(currentMission,addon:GetParty(currentMission.missionID),currentMission.successChance,"report")
			end
			if (step==0) then
				--[===[@debug@
				print("Fired mission complete for",currentMission.missionID)
				--@end-debug@]===]
				G.MarkMissionComplete(currentMission.missionID)
				startTimer(2)
			elseif (step==1) then
				--[===[@debug@
				print("Fired bonus roll complete for",currentMission.missionID)
				--@end-debug@]===]
				G.MissionBonusRoll(currentMission.missionID)
				startTimer(2)
			elseif (step>=2) then
				self:GetMissionResults(step==3,currentMission)
				addon:RefreshFollowerStatus()
				shipyard:RefreshFollowerStatus()
				local current=report:GetUserData('current')
				report:SetUserData('current',current+1)
				startTimer()
				return
			end
			currentMission.state=step
		else
			report:AddButton(L["Building Final report"])
			startTimer(1,"LOOT")
		end
	end
end
function module:GetMissionResults(success,currentMission)
	stopTimer()
	if (success) then
		report:AddMissionResult(currentMission.missionID,true)
		PlaySound("UI_Garrison_Mission_Complete_Mission_Success")
	else
		report:AddMissionResult(currentMission.missionID,false)
		PlaySound("UI_Garrison_Mission_Complete_Encounter_Fail")
	end
	if success then
		local resourceMultiplier=currentMission.resourceMultiplier or {}
		local goldMultiplier=currentMission.goldMultiplier or 1
		for k,v in pairs(currentMission.rewards) do
			v.quantity=v.quantity or 0
			if v.currencyID then
				rewards.currencies[v.currencyID].icon=v.icon
				local multi=resourceMultiplier[v.currencyID]
				if v.currencyID == 0 then
					rewards.currencies[v.currencyID].qt=rewards.currencies[v.currencyID].qt+v.quantity * goldMultiplier
				elseif resourceMultiplier[v.currencyID] then
					rewards.currencies[v.currencyID].qt=rewards.currencies[v.currencyID].qt+v.quantity * multi
				else
					rewards.currencies[v.currencyID].qt=rewards.currencies[v.currencyID].qt+v.quantity
				end
			elseif v.itemID then
				rewards.items[format("%d:%s",currentMission.missionID,v.itemID)]=1
			end
		end
	end
end
function module:MissionsPrintResults(success)
	stopTimer()
	local reported
	local followers
	for k,v in pairs(rewards.currencies) do
		reported=true
		if k == 0 then
			-- Money reward
			report:AddIconText(v.icon,GetMoneyString(v.qt))
		else
			-- Other currency reward
			report:AddIconText(v.icon,GetCurrencyLink(k),v.qt)
		end
	end
	local items=new()
	for k,v in pairs(rewards.items) do
		local missionid,itemid=strsplit(":",k)
		if (not items[itemid]) then
			items[itemid]=1
		else
			items[itemid]=items[itemid]+1
		end
	end
	for itemid,qt in pairs(items) do
		reported=true
		report:AddItem(itemid,qt)
	end
	del(items)
	for k,v in pairs(rewards.followerXP) do
		reported=true
		followers=true
		report:AddFollower(self:GetAnyData(followerType,k),v,self:GetAnyData(followerType,k,'qLevel',0) > tonumber(rewards.followerBase[k].qLevel,0))
	end
	if not reported then
		report:AddRow(L["Nothing to report"])
	end
	if not followers then
		report:AddRow(L["No follower gained xp"])
	end
	if followerType==LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
		local shipyard=addon:GetModule("ShipYard")
		local newshipsnumber=shipyard:GetTotFollowers()
		if shipsnumber ~= newshipsnumber then
			report:AddRow(C(format(L["You lost %d ships"],shipsnumber - newshipsnumber),"red"))
			for k,v in pairs(rewards.followerBase) do
				if not self:GetAnyData(followerType,k) then
					report:AddFollower(v,-1)
				end
			end
		end
		local fogFrames = GSF.MissionTab.MissionList.FogFrames
		for j=1, #fogFrames do
			fogFrames[j]:Hide()
		end
		GarrisonShipyardMap_UpdateMissions()
		addon:ScheduleTimer(GarrisonShipyardMap_UpdateMissions,0.1)
	end
	report:AddRow(DONE)
	if ns.quick then
		self:ScheduleTimer("CloseReport",0.1)
		local qm=addon:GetModule("Quick")
		addon.ScheduleTimer(qm,"RunQuick",0.2)
	end
end
function addon:MissionComplete(...)
	return module:MissionComplete(...)
end
function addon:CloseMissionComplete()
	return module:CloseReport()
end
