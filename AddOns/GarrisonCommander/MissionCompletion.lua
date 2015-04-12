local me, ns = ...
local addon=ns.addon --#addon
local L=ns.L
local D=ns.D
local C=ns.C
local AceGUI=ns.AceGUI
local _G=_G
--[===[@debug@
--if LibDebug() then LibDebug() end
--@end-debug@]===]
local xprint=ns.xprint
local new, del, copy =ns.new,ns.del,ns.copy
local GMF=GarrisonMissionFrame
local GMFMissions=GarrisonMissionFrameMissions
local G=C_Garrison
local GARRISON_CURRENCY=GARRISON_CURRENCY
local pairs=pairs
local format=format
local strsplit=strsplit
local generated
local salvages={
114120,114119,114116}
local module=addon:NewSubClass('MissionCompletion') --#Module
function module:GenerateMissionCompleteList(title)
	local w=AceGUI:Create("GCMCList")
--[===[@debug@
	title=format("%s %s %s",title,w.frame:GetName(),GetTime()*1000)
--@end-debug@]===]
	w:SetTitle(title)
	w:SetCallback("OnClose",function(widget) widget:Release() return module:MissionsCleanup() end)
	--report:SetPoint("TOPLEFT",GMFMissions.CompleteDialog.BorderFrame)
	--report:SetPoint("BOTTOMRIGHT",GMFMissions.CompleteDialog.BorderFrame)
	w:ClearAllPoints()
	w:SetPoint("TOP",GMF)
	w:SetPoint("BOTTOM",GMF)
	w:SetWidth(500)
	w:SetParent(GMF)
	w.frame:SetFrameStrata("HIGH")
	return w
end
--[===[@debug@
function addon.ShowRewards()
	module:GenerateMissionCompleteList("Test")
end
--@end-debug@]===]
local missions={}
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
	--[===[@alpha@
	addon:Dprint("Timer rearmed for",event,delay)
	--@end-alpha@]===]
end
function module:MissionsCleanup()
	self:Events(false)
	stopTimer()
	GMF.MissionTab.MissionList.CompleteDialog:Hide()
	GMF.MissionComplete:Hide()
	GMF.MissionCompleteBackground:Hide()
	GMF.MissionComplete.currentIndex = nil
	GMF.MissionTab:Show()
	GarrisonMissionList_UpdateMissions()
	-- Re-enable "view" button
	GMFMissions.CompleteDialog.BorderFrame.ViewButton:SetEnabled(true)
	GarrisonMissionFrame_SelectTab(1)
	GarrisonMissionFrame_CheckCompleteMissions()
end
function module:Events(on)
	if (on) then
		self:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_LOOT","MissionAutoComplete")
		self:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE","MissionAutoComplete")
		self:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE","MissionAutoComplete")
		self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED","MissionAutoComplete")
	else
		self:UnregisterAllEvents()
	end
end
function module:CloseReport()
	if report then pcall(report.Close,report) report=nil end
end
function module:MissionComplete(this,button)
	missions=G.GetCompleteMissions()
	if (missions and #missions > 0) then
		GMFMissions.CompleteDialog.BorderFrame.ViewButton:SetEnabled(false) -- Disabling standard Blizzard Completion
		report=self:GenerateMissionCompleteList("Missions' results")
		wipe(rewards.followerBase)
		wipe(rewards.followerXP)
		wipe(rewards.currencies)
		wipe(rewards.items)
		for i=1,#missions do
			for k,v in pairs(missions[i].followers) do
				rewards.followerBase[v]=self:GetFollowerData(v,'qLevel')
			end
			for k,v in pairs(missions[i].rewards) do
				if v.itemID then GetItemInfo(v.itemID) end -- tickling server
			end
			local m=missions[i]
--totalTimeString, totalTimeSeconds, isMissionTimeImproved, successChance, partyBuffs, isEnvMechanicCountered, xpBonus, materialMultiplier, goldMultiplier = C_Garrison.GetPartyMissionInfo(MISSION_PAGE_FRAME.missionInfo.missionID);

			local _
			_,_,m.isMissionTimeImproved,m.successChance,_,_,m.xpBonus,m.resourceMultiplier,m.goldMultiplier=G.GetPartyMissionInfo(m.missionID)
		end
--[===[@debug@
		self:Dump("Completed missions",missions)
--@end-debug@]===]
		report:SetUserData('missions',missions)
		report:SetUserData('current',1)
		self:Events(true)
		self:MissionAutoComplete("INIT")
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
function module:MissionAutoComplete(event,ID,arg1,arg2,arg3,arg4)
-- C_Garrison.MarkMissionComplete Mark mission as complete and prepare it for bonus roll, da chiamare solo in caso di successo
-- C_Garrison.MissionBonusRoll
--[===[@alpha@
	self:Dprint("evt",event,ID,arg1 or'',arg2 or '',arg3 or '')
--@end-alpha@]===]
	if event=="LOOT" then
		return self:MissionsPrintResults()
	end
	local current=report:GetUserData('current')
	local currentMission=report:GetUserData('missions')[current]
	local missionID=currentMission and currentMission.missionID or 0
	-- GARRISON_FOLLOWER_XP_CHANGED: followerID, xpGained, actualXp, newLevel, quality
	if (event=="GARRISON_FOLLOWER_XP_CHANGED") then
		if (arg1 > 0) then
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
	else -- event == LOOP
		if (currentMission) then
			local step=currentMission.state or -1
			if (step<1) then
				step=0
				currentMission.state=0
				currentMission.goldMultiplier=currentMission.goldMultiplier or 1
				currentMission.xp=select(2,G.GetMissionInfo(currentMission.missionID))
				report:AddMissionButton(currentMission,addon:GetParty(currentMission.missionID),currentMission.successChance)
			end
			if (step==0) then
				--[===[@alpha@
				self:Dprint("Fired mission complete for",currentMission.missionID)
				--@end-alpha@]===]
				G.MarkMissionComplete(currentMission.missionID)
				startTimer(2)
			elseif (step==1) then
				--[===[@alpha@
				self:Dprint("Fired bonus roll complete for",currentMission.missionID)
				--@end-alpha@]===]
				G.MissionBonusRoll(currentMission.missionID)
				startTimer(2)
			elseif (step>=2) then
				self:GetMissionResults(step==3,currentMission)
				self:RefreshFollowerStatus()
				local current=report:GetUserData('current')
				report:SetUserData('current',current+1)
				startTimer()
				return
			end
			currentMission.state=step
		else
			report:AddButton(L["Building Final report"],function() addon:MissionsPrintResult() end)
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
		local resourceMultiplier=currentMission.resourceMultiplier or 1
		local goldMultiplier=currentMission.goldMultiplier or 1
		for k,v in pairs(currentMission.rewards) do
			v.quantity=v.quantity or 0
			if v.currencyID then
				rewards.currencies[v.currencyID].icon=v.icon
				if v.currencyID == 0 then
					rewards.currencies[v.currencyID].qt=rewards.currencies[v.currencyID].qt+v.quantity * goldMultiplier
				elseif v.currencyID == GARRISON_CURRENCY then
					rewards.currencies[v.currencyID].qt=rewards.currencies[v.currencyID].qt+v.quantity * resourceMultiplier
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
	self:FollowerCacheInit()
--[===[@debug@
	--self:Dump("Ended Mission",rewards)
--@end-debug@]===]
	local reported
	for k,v in pairs(rewards.currencies) do
		reported=true
		if k == 0 then
			-- Money reward
			report:AddIconText(v.icon,GetMoneyString(v.qt))
		elseif k == GARRISON_CURRENCY then
			-- Garrison currency reward
			report:AddIconText(v.icon,GetCurrencyLink(k),v.qt)
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
		report:AddFollower(k,v,self:GetFollowerData(k,'qLevel') > rewards.followerBase[k])
	end
	if (not reported) then
		report:AddRow(L["Nothing to report"])
	end
end
