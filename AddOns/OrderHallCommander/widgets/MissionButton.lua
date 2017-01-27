local me,addon=...
local C=addon:GetColorTable()
local module=addon:GetWidgetsModule()
local Type,Version="OHCMissionButton",1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end
local m={} --#Widget
function m:OnAcquire()
	local frame=self.frame
	frame.info=nil
	frame:SetAlpha(1)
	frame:SetScale(1.0)
	frame:Enable()
	for i=1,#self.scripts do
		frame:SetScript(self.scripts[i],nil)
	end
	for i=1,#frame.Rewards do
		frame.Rewards[i].Icon:SetDesaturated(false)
	end
	wipe(self.scripts)
	return
end
function m:Show()
	return self.frame:Show()
end
function m:RunSpinner(start)
	if start then
		self.Spinner:Start()
	else
		self.Spinner:Stop()
	end
end
function m:SetHeight(h)
	return self.frame:SetHeight(h)
end
function m:Hide()
	self.frame:SetHeight(1)
	self.frame:SetAlpha(0)
	return self.frame:Disable()
end
function m:SetScript(name,method)
	tinsert(self.scripts,name)
	return self.frame:SetScript(name,method)
end
function m:SetScale(s)
	return self.frame:SetScale(s)
end
function m:Blacklist(blacklisted)
	local mb=self.frame
	if blacklisted then
--[===[@debug@
		print("Blacklisting",mb:GetName())
--@end-debug@]===]
		mb.Overlay:Show()
		mb.Overlay.Overlay:SetAlpha(1)
		for i,v in pairs(mb.gcPANEL.Party) do
			v.PortraitFrame.Portrait:SetDesaturated(true)
			v.PortraitFrame.PortraitRingQuality:Hide()
			v.PortraitFrame.LevelBorder:Hide()
		end
		for i,v in pairs(mb.Rewards) do
			v.Icon:SetDesaturated(true)
			v.Quantity:Hide()
		end
		return true
	else
		mb.Overlay:Hide()
		mb.Overlay.Overlay:SetAlpha(0.4)
		for i,v in pairs(mb.gcPANEL.Party) do
			v.PortraitFrame.Portrait:SetDesaturated(false)
			v.PortraitFrame.PortraitRingQuality:Show()
			v.PortraitFrame.LevelBorder:Show()
		end
		for i,v in pairs(mb.Rewards) do
			v.Icon:SetDesaturated(false)
			v.Quantity:Show()
		end
		return false
	end
end
function m:SetMission(mission,followers,perc,source)
	local frame=self.frame
	frame.info=mission
	if not mission.followers or #mission.followers==0 then
		frame.info.followers=followers
	end
	frame:EnableMouse(true)
	frame.Title:SetText(mission.name)
	local nrewards=type(mission.rewards)=="table" and #mission.rewards or 0
	local rc,message =pcall(GarrisonMissionButton_SetRewards,frame,mission.rewards,nrewards)
	addon:GetMissionlistModule():AdjustMissionButton(frame,mission.rewards)
--	if #frame.Rewards > 0 then
--		local Reward=frame.Rewards[1]
--		Reward:ClearAllPoints()
--		Reward:SetPoint("RIGHT")
--	end
	--[===[@debug@
	if not rc then frame.Title:SetText(message) end
	--@end-debug@]===]
end
function m._Constructor()
	local frame=CreateFrame("Button",Type..AceGUI:GetNextWidgetNum(Type),nil,"OHCMissionButton")
	--frame.Title:SetFontObject("QuestFont_Shadow_Small")
	--frame.Summary:SetFontObject("QuestFont_Shadow_Small")
	frame:SetScript("OnEnter",function(self) self.obj:Fire("OnEnter") end)
	frame:SetScript("OnLeave",function(self)self.obj:Fire("OnLeave") end)
	frame:RegisterForClicks("LeftButtonUp","RightButtonUp")
	frame:SetScript("OnClick",function(self,button) print(button) return button=="RightButton" and self.obj:Fire("OnRightClick",self,button) or  self.obj:Fire("OnClick",self,button) end)
	frame.LocBG:SetPoint("LEFT")
	frame.MissionType:SetPoint("TOPLEFT",5,-2)
	frame.isResult=true
	local widget={}
	setmetatable(widget,{__index=frame})
	widget.frame=frame
	widget.scripts={}
	frame.obj=widget
	for k,v in pairs(m) do widget[k]=v end
	widget._Constructor=nil
	-- Spinner
	widget.Spinner=CreateFrame("Frame",nil,frame,"OHCSpinner")
	-- Failed text string
	widget.Spinner:SetPoint("CENTER")
	widget.Result=frame:CreateFontString(nil,"OVERLAY","GameFontNormalHuge")
	widget.Result:SetPoint("TOPLEFT",frame.Title,"BOTTOMLEFT",0,-10)
	widget.Result:Hide()
	return AceGUI:RegisterAsWidget(widget)
end
AceGUI:RegisterWidgetType(Type,m._Constructor,Version)
	
