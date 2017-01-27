local __FILE__=tostring(debugstack(1,2,0):match("(.*):1:")) -- Always check line number in regexp and file, must be 1
local function pp(...) print(GetTime(),"|cff009900",__FILE__:sub(-15),strjoin(",",tostringall(...)),"|r") end
--*TYPE module
--*CONFIG noswitch=false,profile=true,enhancedProfile=true
--*MIXINS "AceHook-3.0","AceEvent-3.0","AceTimer-3.0"
--*MINOR 35
-- Generated on 20/01/2017 08:15:04
local me,ns=...
local addon=ns --#Addon (to keep eclipse happy)
ns=nil
local module=addon:NewSubModule('Core',"AceHook-3.0","AceEvent-3.0","AceTimer-3.0")  --#Module
function addon:GetCoreModule() return module end
-- Template
local G=C_Garrison
local _
local AceGUI=LibStub("AceGUI-3.0")
local C=addon:GetColorTable()
local L=addon:GetLocale()
local new=addon.NewTable
local del=addon.DelTable
local kpairs=addon:GetKpairs()
local empty=addon:GetEmpty()
local OHF=OrderHallMissionFrame
local OHFMissionTab=OrderHallMissionFrame.MissionTab --Container for mission list and single mission
local OHFMissions=OrderHallMissionFrame.MissionTab.MissionList -- same as OrderHallMissionFrameMissions Call Update on this to refresh Mission Listing
local OHFFollowerTab=OrderHallMissionFrame.FollowerTab -- Contains model view
local OHFFollowerList=OrderHallMissionFrame.FollowerList -- Contains follower list (visible in both follower and mission mode)
local OHFFollowers=OrderHallMissionFrameFollowers -- Contains scroll list
local OHFMissionPage=OrderHallMissionFrame.MissionTab.MissionPage -- Contains mission description and party setup 
local OHFMapTab=OrderHallMissionFrame.MapTab -- Contains quest map
local followerType=LE_FOLLOWER_TYPE_GARRISON_7_0
local garrisonType=LE_GARRISON_TYPE_7_0
local FAKE_FOLLOWERID="0x0000000000000000"
local MAXLEVEL=110

local ShowTT=OrderHallCommanderMixin.ShowTT
local HideTT=OrderHallCommanderMixin.HideTT

local dprint=print
local ddump
--[===[@debug@
LoadAddOn("Blizzard_DebugTools")
ddump=DevTools_Dump
LoadAddOn("LibDebug")

if LibDebug then LibDebug() dprint=print end
local safeG=addon.safeG

--@end-debug@]===]
--@non-debug@
dprint=function() end
ddump=function() end
local print=function() end
--@end-non-debug@

-- End Template - DO NOT MODIFY ANYTHING BEFORE THIS LINE
--*BEGIN 
--local missionPanelMissionList=OrderHallMissionFrameMissions
--[[
Su OrderHallMissionFrameMissions viene chiamato Update() per aggiornare le missioni
.listScroll = padre della scrolllist delle missioni
<code>
	local scrollFrame = self.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
</code>
--]]
--[[
OHC- OrderHallMissionFrame.FollowerTab.DurabilityFrame : OnShow :  table: 0000000033557BD0
OHC- OrderHallMissionFrame.FollowerTab.QualityFrame : OnShow :  table: 0000000033557C20
OHC- OrderHallMissionFrame.FollowerTab.PortraitFrame : OnShow :  table: 0000000033557D60
OHC- OrderHallMissionFrame.FollowerTab.ModelCluster : OnShow :  table: 0000000033557F40
OHC- OrderHallMissionFrame.FollowerTab.XPBar : OnShow :  table: 00000000335585D0
--]]
-- Upvalued functions
--local I=LibStub("LibItemUpgradeInfo-1.0",true)
local GetItemInfo=GetItemInfo
--if I then GetItemInfo=I:GetCachingGetItemInfo() end
local select,CreateFrame,pairs,type,tonumber,math=select,CreateFrame,pairs,type,tonumber,math
local QuestDifficultyColors,GameTooltip=QuestDifficultyColors,GameTooltip
local tinsert,tremove,tContains=tinsert,tremove,tContains
local format=format
local resolve=addon.resolve
local colors=addon.colors
local menu
local menuType="OHCMenu"
local menuOptions={mission={},follower={}}
function addon:ApplyMOVEPANEL(value)
	OHF:EnableMouse(value)
	OHF:SetMovable(value)
end
function addon:OnInitialized()
  _G.dbOHCperChar=_G.dbOHCperChar or {}
	menu=CreateFrame("Frame")
--[===[@debug@
	local f=menu
	f:RegisterAllEvents()
	self:RawHookScript(f,"OnEvent","ShowGarrisonEvents")
--@end-debug@]===]
	self:AddLabel(L["General"])
	self:AddBoolean("MOVEPANEL",true,L["Make Order Hall Mission Panel movable"],L["Position is not saved on logout"])
	self:AddBoolean("TROOPALERT",true,L["Troop ready alert"],L["Notifies you when you have troops ready to be collected"])
	OHF:RegisterForDrag("LeftButton")
	OHF:SetScript("OnDragStart",function(frame) if self:GetBoolean('MOVEPANEL') then frame:StartMoving() end end)
	OHF:SetScript("OnDragStop",function(frame) frame:StopMovingOrSizing() end)
	self:ApplyMOVEPANEL(self:GetBoolean('MOVEPANEL'))	
end
function addon:ClearMenu()
	if menu.widget then 
		pcall(AceGUI.Release,AceGUI,menu.widget) 
		menu.widget=nil 
	end
	menu:Hide()
end
function addon:RegisterForMenu(menu,...)
	for i=1,select('#',...) do
		local value=(select(i,...))
		if not tContains(menuOptions[menu],value) then
			tinsert(menuOptions[menu],value)
		end
	end
end
function addon:GetRegisteredForMenu(menu)
	return menuOptions[menu]
end
do

end
-- my implementation of tonumber which accounts for nan and inf
function addon:tonumber(value,default)
	if value~=value then return default
	elseif value==math.huge then return default
	else return tonumber(value) or default
	end
end
-- my implementation of type which accounts for nan and inf
function addon:type(value)
	if value~=value then return nil
	elseif value==math.huge then return nil
	else return type(value)
	end
end

function addon:ActivateButton(button,OnClick,Tooltiptext,persistent)
	button:SetScript("OnClick",function(...) self[OnClick](self,...) end )
	if (Tooltiptext) then
		button.tooltip=Tooltiptext
		button:SetScript("OnEnter",ShowTT)
			button:SetScript("OnLeave",HideTT)
	else
		button:SetScript("OnEnter",nil)
		button:SetScript("OnLeave",nil)
	end
end
--- Helpers
-- 
function addon:SetBackdrop(frame,r,g,b,a)
	r=r or 1
	g=g or 0
	b=b or 0
	a=a or 1
   frame:SetBackdrop({
         bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
         xedgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
         tile = true, tileSize = 16, edgeSize = 16, 
         insets = { left = 4, right = 4, top = 4, bottom =   4}
      }
   )	
   frame:SetBackdropColor(r,g,b,a)
end
function addon:GetDifficultyColors(...)
	local q=self:GetDifficultyColor(...)
	return q.r,q.g,q.b
end
function addon:GetDifficultyColor(perc,usePurple)
	if perc>=100 then
		return C.Green
	elseif(perc >90) then
		return QuestDifficultyColors['standard']
	elseif (perc >74) then
		return QuestDifficultyColors['difficult']
	elseif(perc>49) then
		return QuestDifficultyColors['verydifficult']
	elseif(perc >20) then
		return QuestDifficultyColors['impossible']
	else
		return not usePurple and C.Silver or C.Fuchsia
	end
end
function addon:GetAgeColor(age)
		age=tonumber(age) or 0
		if age>GetTime() then age=age-GetTime() end
		if age < 0 then age=0 end
		local hours=floor(age/3600)
		local q=self:GetDifficultyColor(hours+20,true)
		return q.r,q.g,q.b
end
local function tContains(table, item)
	local index = 1;
	while table[index] do
		if ( item == table[index] ) then
			return index;
		end
		index = index + 1;
	end
	return nil;
end
local emptyTable={}
local function Reward2Class(self,mission)
	local overReward=mission.overmaxRewards
	if not overReward then overReward=mission.OverRewards end
	local reward=mission.rewards
	if not reward then reward=mission.Rewards end
	if not overReward or not reward then
		return "Generic",0
	end
	overReward=overReward[1]
	reward=reward[1]
	if not reward then return "Generic",0 end
	if not overReward then overReward = emptyTable end
	if reward.currencyID then
		local name=GetCurrencyInfo(reward.currencyID)
		if name=="" then name = MONEY end
		return name,reward.quantity/10000
	elseif reward.followerXP then
			return "FollowerXp",reward.followerXP
	elseif type(reward.itemID) == "number" then
		if tContains(self:GetData('ArtifactPower'),reward.itemID) then
			return "Artifact",0
		elseif overReward.itemID==1447868 then
			return "PlayerXP",0
		elseif overReward.itemID==141344 then
			return "Reputation",0
		elseif tContains(self:GetData('Equipment'),reward.itemID) then
			return "Equipment",0
		elseif tContains(self:GetData("Upgrades"),reward.itemID) then
			return "Upgrades",0
		else
			local class,subclass=select(12,GetItemInfo(reward.itemID))
			class=class or -1
			if class==12 then
				return "Quest",0
			elseif class==7 then
				return "Reagent",reward.quantity or 1
			end
		end
	end
	return "Generic",reward.quantity or 1
end
local classSort={
	[MONEY]=11,
	Artifact=12,
	Equipment=13,
	Quest=14,
	Upgrades=15,
	Reputation=16,
	PlayerXP=17,
	FollowerXP=18,
	Generic=19
}
function addon:Reward2Class(mission)
	if not mission.missionClass then
		mission.missionClass,mission.missionValue=Reward2Class(self,mission)
		mission.missionSort=classSort[mission.missionClass]
	end
	return mission.missionSort
end
--[===[@debug@
local events={}
function addon:Trace(frame, method)
	if true then return end
	method=method or "OnShow"
	if type(frame)=="string" then frame=_G[frame] end
	if not frame then return end
	if not self:IsHooked(frame,method) and frame:GetObjectType()~="GameTooltip" then
		self:HookScript(frame,method,function(...)
			local name=resolve(frame)
			tinsert(dbOHCperChar,resolve(frame:GetParent())..'/'..name)
			print(("OHC [%s] %s:%s %s %d"):format(frame:GetObjectType(),name,method,frame:GetFrameStrata(),frame:GetFrameLevel()))
			end
		)
	end
end
local lastevent=""
function addon:ShowGarrisonEvents(this,event,...)
	if event:find("GARRISON") then
		if event=="GARRISON_MISSION_LIST_UPDATE" and event==lastevent then
			return
		end
		if event=="GARRISON_MISSION_COMPLETE_RESPONSE" then
			local _,_,_,followers=...
			if type(followers)=="table" then
				tinsert(dbOHCperChar,followers)			
			end
		end
		lastevent=event
		tinsert(events,{event,...})
		return self:PushEvent(event,...)
	end
end
function addon:PushEvent(event,...)
	if not AlarLog then AlarLog={} end
	if not AlarLog[me] then AlarLog[me]={} end
	tinsert(AlarLog[me],event.. " : '" .. strjoin(tostringall("' '",...)) .. "'")
end
function addon:DumpEvents()
	return events
end
addon:PushEvent("ADDON_LOADED")
_G.OHC=addon
--@end-debug@]===]
