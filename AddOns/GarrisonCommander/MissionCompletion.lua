local me, ns = ...
local addon=ns.addon --#addon
local L=ns.L
local D=ns.D
local C=ns.C
local AceGUI=ns.AceGUI
local _G=_G
local new, del, copy =ns.new,ns.del,ns.copy
local GMF=GarrisonMissionFrame
local GMFMissions=GarrisonMissionFrameMissions
local G=C_Garrison
local GARRISON_CURRENCY=GARRISON_CURRENCY
ns.missionautocompleting=false
local generated
function addon:GenerateMissionCompleteList(title)
	if not generated then
		generated=true
		self:GenerateContainer()
		do
			local Type="GCMCList"
			local Version=1
			local m={} --#Widget
			local function onEnter(self)
				if (self.itemlink) then
					GameTooltip:SetHyperlink(self.itemlink)
					GameTooltip:Show()
				end
			end
			function m:ScrollDown()
				local obj=self.scroll
				if (#self.missions >1 and obj.scrollbar and obj.scrollbar:IsShown()) then
					obj:SetScroll(80)
					obj.scrollbar.ScrollDownButton:Click()
				end
			end
			function m:OnAcquire()
				wipe(self.missions)
			end
			function m:OnClose()
				print("azzero completing")
				ns.missionautocompleting=nil
			end
			function m:Show()
				self.frame:Show()
			end
			function m:Hide()
				self.frame:Hide()
				self:Release()
			end
			function m:AddMissionButton(mission)
				local obj=self.scroll
				local b=AceGUI:Create("GMCSlimMissionButton")
				b:SetMission(mission,addon:GetParty(mission.missionID))
				b:SetScale(0.7)
				b:SetFullWidth(true)
				self.missions[mission.missionID]=b
				obj:AddChild(b)
			end
			function m:AddMissionName(missionID,success)
				local mission=self.missions[missionID]
				if mission then
					local frame=mission.frame
					if success then
						frame.Success:Show()
						frame.Failure:Hide()
						for i=1,#frame.Rewards do
							frame.Rewards[i].Icon:SetDesaturated(false)
						end
					else
						frame.Success:Hide()
						frame.Failure:Show()
						for i=1,#frame.Rewards do
							frame.Rewards[i].Icon:SetDesaturated(true)
							frame.Rewards[i].Quantity:Hide()
						end
					end
				end
			end
			function m:AddRow(data,...)
				local obj=self.scroll
				local l=AceGUI:Create("InteractiveLabel")
				l:SetFontObject(GameFontNormalSmall)
				l:SetText(data)
				l:SetColor(...)
				l:SetFullWidth(true)
				obj:AddChild(l)

			end
			function m:AddFollower(followerID,xp,levelup)
				local follower=addon:GetFollowerData(followerID)
				if follower.maxed and not levelup then
					return self:AddRow(format("%s is already at maximum xp",addon:GetFollowerData(followerID,'fullname')))
				end
				local quality=G.GetFollowerQuality(followerID) or follower.quality
				local level=G.GetFollowerLevel(followerID) or follower.level
				if levelup then
					PlaySound("UI_Garrison_CommandTable_Follower_LevelUp");
				end
				return self:AddRow(format("%s gained %d xp%s%s",addon:GetFollowerData(followerID,'fullname',true),xp,
				levelup and " |cffffed1a*** Level Up ***|r ." or ".",
				format(" %d to go.",addon:GetFollowerData(followerID,'levelXP')-addon:GetFollowerData(followerID,'xp'))))
			end
			function m:AddIconText(icon,text,qt)
				local obj=self.scroll
				local l=AceGUI:Create("Label")
				l:SetFontObject(GameFontNormalSmall)
				if (qt) then
					l:SetText(format("%s x %s",text,qt))
				else
					l:SetText(text)
				end
				l:SetImage(icon)
				l:SetImageSize(24,24)
				l:SetFullWidth(true)
				obj:AddChild(l)
				if (obj.scrollbar and obj.scrollbar:IsShown()) then
					obj:SetScroll(80)
					obj.scrollbar.ScrollDownButton:Click()
				end
				return l
			end
			function m:AddItem(itemID,qt)
				local obj=self.scroll
				local _,itemlink,itemquality,_,_,_,_,_,_,itemtexture=GetItemInfo(itemID)
				if not itemlink then
					self:AddIconText(itemtexture,itemID)
				else
					self:AddIconText(itemtexture,itemlink)
				end
			end
			local function Constructor()
				local widget=AceGUI:Create("GCGUIContainer")
				widget:SetLayout("Fill")
				widget.missions={}
				local scroll = AceGUI:Create("ScrollFrame")
				scroll:SetLayout("List") -- probably?
				scroll:SetFullWidth(true)
				scroll:SetFullHeight(true)
				widget:AddChild(scroll)
				for k,v in pairs(m) do widget[k]=v end
				widget:Show()
				widget.scroll=scroll
				return widget
			end
			AceGUI:RegisterWidgetType(Type,Constructor,Version)
		end
	end
	local w=AceGUI:Create("GCMCList")
	w:SetTitle(title)
	w:SetCallback("OnClose", function() ns.missionautocompleting=nil end)
	return w
end

--TODO: Portare la stampa dei risultati in fondo, e togliere il delay fra le missioni
do
	local missions={}
	local states={}
	local currentMission
	local rewards={
		items=setmetatable({},{__index=function() return 0 end}),
		followerBase={},
		followerXP=setmetatable({},{__index=function() return 0 end}),
		currencies=setmetatable({},{__index=function(t,k) rawset(t,k,{icon="",qt=0}) return t[k] end}),
	}
	local scroller
	local report
	local timer
	local function startTimer(delay,event)
		delay=delay or 0.2
		event=event or "LOOP"
		addon:ScheduleTimer("MissionAutoComplete",delay,event)
	end
	local function stopTimer()
		timer=nil
	end
	function addon:MissionsCleanup()
		stopTimer()
		self:MissionEvents(false)
		GMF.MissionTab.MissionList.CompleteDialog:Hide()
		GMF.MissionComplete:Hide()
		GMF.MissionCompleteBackground:Hide()
		GMF.MissionComplete.currentIndex = nil
		GMF.MissionTab:Show()
		GarrisonMissionList_UpdateMissions()
		-- Re-enable "view" button
		GMFMissions.CompleteDialog.BorderFrame.ViewButton:SetEnabled(true)
		ns.missionautocompleting=nil
		GarrisonMissionFrame_SelectTab(1)
		GarrisonMissionFrame_CheckCompleteMissions()
	end
	function addon:MissionEvents(start)
		self:UnregisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE")
		self:UnregisterEvent("GARRISON_MISSION_BONUS_ROLL_LOOT")
		self:UnregisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")
		self:UnregisterEvent("GARRISON_FOLLOWER_XP_CHANGED")
		self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
		if start then
			self:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_LOOT","MissionAutoComplete")
			self:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE","MissionAutoComplete")
			self:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE","MissionAutoComplete")
			self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED","MissionAutoComplete")
			self:RegisterEvent("GET_ITEM_INFO_RECEIVED","MissionAutoComplete")
		else
			self:SafeRegisterEvent("GARRISON_MISSION_BONUS_ROLL_LOOT")
			self:SafeRegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE")
			self:SafeRegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")
			self:SafeRegisterEvent("GARRISON_FOLLOWER_XP_CHANGED")
		end
	end
	function addon:MissionComplete(this,button)
		GMFMissions.CompleteDialog.BorderFrame.ViewButton:SetEnabled(false)
		missions=G.GetCompleteMissions()
		--GMFMissions.CompleteDialog.BorderFrame.ViewButton:SetEnabled(false) -- Disabling standard Blizzard Completion
		if (missions and #missions > 0) then
			ns.missionautocompleting=true
			report=self:GenerateMissionCompleteList("Missions' results")
			--report:SetPoint("TOPLEFT",GMFMissions.CompleteDialog.BorderFrame)
			--report:SetPoint("BOTTOMRIGHT",GMFMissions.CompleteDialog.BorderFrame)
			report:SetParent(GMF)
			report:SetPoint("TOP",GMF)
			report:SetPoint("BOTTOM",GMF)
			report:SetWidth(500)
			report:SetCallback("OnClose",function() return addon:MissionsCleanup() end)
			wipe(rewards.followerBase)
			wipe(rewards.followerXP)
			wipe(rewards.currencies)
			wipe(rewards.items)
			for i=1,#missions do
				for k,v in pairs(missions[i].followers) do
					rewards.followerBase[v]=self:GetFollowerData(v,'qLevel')
				end
			end
			currentMission=tremove(missions)
			self:MissionEvents(true)
			self:MissionAutoComplete("LOOP")
		end
	end
	function addon:MissionAutoComplete(event,ID,arg1,arg2,arg3,arg4)
-- C_Garrison.MarkMissionComplete Mark mission as complete and prepare it for bonus roll, da chiamare solo in caso di successo
-- C_Garrison.MissionBonusRoll
	--[===[@debug@
		print("evt",event,ID,arg1,arg2,agr3)
	--@end-debug@]===]
		if self['Event'..event] then
			self['Event'..event](self,event,ID,arg1,arg2,arg3,arg4)
		end
		if event=="LOOT" then
			return addon:MissionsPrintResults()
		end

		if (event =="LOOP" ) then
			ID=currentMission and currentMission.missionID or "none"
			arg1=currentMission and currentMission.state or "none"
		end
		-- GARRISON_FOLLOWER_XP_CHANGED: followerID, xpGained, actualXp, newLevel, quality
		if (event=="GARRISON_FOLLOWER_XP_CHANGED") then
			if (arg1 > 0) then
				--report:AddFollower(ID,arg1,arg2)
				rewards.followerXP[ID]=rewards.followerXP[ID]+tonumber(arg1) or 0
			end
			return
		-- GET_ITEM_INFO_RECEIVED: itemID
		elseif (event=="GET_ITEM_INFO_RECEIVED") then
			rewards.items[format("%d:%s",currentMission.missionID,ID)]=1
			return
		-- GET_ITEM_INFO_RECEIVED: itemID
		elseif (event=="GARRISON_MISSION_BONUS_ROLL_LOOT") then
			if (currentMissission) then
				rewards.items[format("%d:%s",currentMission.missionID,ID)]=1
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
				startTimer(0.1)
				return
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
				startTimer(0.1)
				return
			end
			startTimer(0.1)
			return
		else
			if (currentMission) then
				local step=currentMission.state or -1
				if (step<1) then
					step=0
					currentMission.state=0
					local _
					_,_,_,currentMission.successChance,_,_,currentMission.xpBonus,currentMission.multiplier,currentMission.golds=G.GetPartyMissionInfo(currentMission.missionID)
					currentMission.golds=currentMission.golds or 1
					currentMission.xp=select(2,G.GetMissionInfo(currentMission.missionID))
					report:AddMissionButton(currentMission)
				end
				if (step==0) then
					G.MarkMissionComplete(currentMission.missionID)
				elseif (step==1) then
					G.MissionBonusRoll(currentMission.missionID)
				elseif (step>=2) then
					self:GetMissionResults(step==3)
					self:RefreshFollowerStatus()
					currentMission=tremove(missions)
					startTimer()
					return
				end
				currentMission.state=step
			else
				report:AddRow(L["              Final Report                "])
				startTimer(0.3,"LOOT")
			end
		end
	end
	function addon:GetMissionResults(success)
		stopTimer()
		if (success) then
			report:AddMissionName(currentMission.missionID,true)
			PlaySound("UI_Garrison_Mission_Complete_Mission_Success")
		else
			report:AddMissionName(currentMission.missionID,false)
			PlaySound("UI_Garrison_Mission_Complete_Encounter_Fail")
		end
		if success then
			for k,v in pairs(currentMission.rewards) do
				v.quantity=v.quantity or 0
				v.multiplier=v.multiplier or 1
				v.golds=v.golds or 1
				if v.currencyID then
					rewards.currencies[v.currencyID].icon=v.icon
					if v.currencyID == 0 then
						rewards.currencies[v.currencyID].qt=rewards.currencies[v.currencyID].qt+v.quantity * v.golds
					elseif v.currencyID == GARRISON_CURRENCY then
						rewards.currencies[v.currencyID].qt=rewards.currencies[v.currencyID].qt+v.quantity * v.multiplier
					else
						rewards.currencies[v.currencyID].qt=rewards.currencies[v.currencyID].qt+v.quantity
					end
				elseif v.itemID then
					GetItemInfo(v.itemID) -- Triggering the cache
					rewards.items[format("%d:%s",currentMission.missionID,v.itemID)]=1
				end
			end
		end
	end
	function addon:MissionsPrintResults(success)
		stopTimer()
		self:FollowerCacheInit()
--[===[@debug@
		--self:Dump("Ended Mission",rewards)
--@end-debug@]===]
		for k,v in pairs(rewards.currencies) do
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
		for k,v in pairs(rewards.items) do
			local missionid,itemid=strsplit(":",k)
			report:AddItem(itemid,v)
		end
		for k,v in pairs(rewards.followerXP) do
			report:AddFollower(k,v,self:GetFollowerData(k,'qLevel') > rewards.followerBase[k])
		end
	end
end
