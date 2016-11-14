local pp=print
local me, ns = ...
ns.Configure()
local GarrisonMissionFrame_SetItemRewardDetails=GarrisonMissionFrame_SetItemRewardDetails
local GetItemCount=GetItemCount
local addon=addon --#addon
local over=over --#over
local _G=_G
local GSF=GSF
local GSFMissions=GSFMissions
local G=C_Garrison
local pairs=pairs
local format=format
local strsplit=strsplit
local select=select
local GetCurrencyInfo=GetCurrencyInfo
local generated
local GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY=GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY
local GARRISON_CURRENCY=GARRISON_CURRENCY
local GARRISON_SHIP_OIL_CURRENCY=GARRISON_SHIP_OIL_CURRENCY
local GARRISON_FOLLOWER_MAX_LEVEL=GARRISON_FOLLOWER_MAX_LEVEL
local LE_FOLLOWER_TYPE_GARRISON_6_0=LE_FOLLOWER_TYPE_GARRISON_6_0
local LE_FOLLOWER_TYPE_SHIPYARD_6_2=LE_FOLLOWER_TYPE_SHIPYARD_6_2
local module=addon:NewSubClass('ShipYard') --#Module
local GameTooltip=GameTooltip
local GarrisonShipyardMapMissionTooltip=GarrisonShipyardMapMissionTooltip
local GCS
local shipEnhancement={
	127882,
	127883,
	127884,
	127663,
	125787,
	127662,
	127880,
	127881,
	127894,
	127886
}

function module:Test()

--[===[@debug@
print("test")
--@end-debug@]===]
end
function module:OnInitialize()
	--GARRISON_SHIPYARD_NPC_OPEN
	--GARRISON_SHIPYARD_NPC_CLOSE
	self:SafeSecureHook("GarrisonFollowerButton_UpdateCounters")
	self:SafeSecureHook(GSF,"OnClickMission","HookedGSF_OnClickMission")
	self:SafeSecureHook("GarrisonShipyardMapMission_OnEnter")
	self:SafeSecureHook("GarrisonShipyardMapMission_OnLeave")
	local ref=GSFMissions.CompleteDialog.BorderFrame.ViewButton
	local bt = CreateFrame('BUTTON','GCQuickShipMissionCompletionButton', ref, 'UIPanelButtonTemplate')
	bt.missionType=LE_FOLLOWER_TYPE_SHIPYARD_6_2
	bt:SetWidth(300)
	bt:SetText(L["Garrison Comander Quick Mission Completion"])
	bt:SetPoint("CENTER",0,-50)
	addon:ActivateButton(bt,"MissionComplete",L["Complete all missions without confirmation"])
	if IsAddOnLoaded("MasterPlanA") then
		self:SafeSecureHook("GarrisonShipyardMap_UpdateMissions") -- low efficiency, but survives MasterPlan
	end
	self:SafeSecureHook("GarrisonShipyardMap_SetupBonus")
	self:SafeSecureHookScript(GSF,"OnShow","Setup",true)
	self:SafeRegisterEvent("GARRISON_SHIPYARD_NPC_CLOSED")
	self:SafeRegisterEvent("GARRISON_MISSION_STARTED")
	--GarrisonShipyardFrameFollowersListScrollFrameButton1
	--GarrisonShipyardMapMission1
	addon:AddLabel(L["Shipyard Appearance"])
	addon:AddToggle("SHIPMOVEPANEL",true,L["Unlock Panel"],L["Makes shipyard panel movable"])
	--addon:AddToggle("BIGSCREEN",true,L["Use big screen"],L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"])
	addon:AddToggle("SHIPPIN",true,L["Show Garrison Commander menu"],L["Disable if you dont want the full Garrison Commander Header."])
end
function module:GetMain()
	return GSF
end
function module:GetMissions()
	return GSFMissions
end
function module:GetBigScreen()
	return false
end
---
--Invoked on every mission display, only for available missions
--
local i=0

function module:HookedGarrisonShipyardMap_SetupBonus(missionList,frame,mission)
	if not GSF:IsShown() then return end
	addon:AddExtraData(mission)
	local perc=addon:MatchMaker(mission)
	local addendum=frame.GcAddendum
	if not addendum then
		if mission.inProgress then return end
		i=i+1
		addendum=CreateFrame("Frame",nil,frame)
		addendum:SetPoint("TOPLEFT",frame,"TOPRIGHT",-10,-15)

		AddBackdrop(addendum)
		addendum:SetBackdropColor(0,0,0,0.5)
		addendum:SetWidth(50)
		addendum:SetHeight(25)
		addendum.chance=addendum:CreateFontString(nil,"TOOLTIP","GameFontHighlightMedium")
		addendum.chance:SetAllPoints()
		addendum.chance:SetJustifyH("CENTER")
		addendum.chance:SetJustifyV("CENTER")
		frame.GcAddendum=addendum
	end
	if mission.inProgress then addendum:Hide() return end
	addendum:Show()
	addendum.chance:SetFormattedText("%d%%",perc)
	addendum.chance:SetTextColor(self:GetDifficultyColors(perc))
	local cost=mission.cost
	local currency=mission.costCurrencyTypesID
	if not mission.canStart then
		addendum:SetBackdropBorderColor(0,0,0)
		return
	end
	if cost and currency then
		local _,available=GetCurrencyInfo(currency)
		if cost>available then
			addendum:SetBackdropBorderColor(1,0,0)
		else
			addendum:SetBackdropBorderColor(0,1,0)
		end
	else
		addendum:SetBackdropBorderColor(1,1,1)

	end
	--addendum.expire:SetText(mission.class)
	--addendum.duration:SetText(mission.duration)
end
function module:HookedGarrisonShipyardMap_UpdateMissions()
	local list = GSF.MissionTab.MissionList
	for i=1,#list.missions do
		local frame = list.missionFrames[i]
		if not self:IsHooked(frame,"PostClick") then
			self:SafeHookScript(frame,"PostClick","ScriptMapButtonOnClick",true)
		end
	end

end
function module:ScriptMapButtonOnClick(this)
	self:FillMissionPage(this.info)
end
function module:HookedGSF_OnClickMission(this,missionInfo)
	self:FillMissionPage(missionInfo)
	self:RefreshFollowerStatus()
end
function module:HookedGarrisonFollowerButton_UpdateCounters(gsf,frame,follower,showcounter,lastupdate)
	if follower.followerTypeID~=LE_FOLLOWER_TYPE_SHIPYARD_6_2 then return end
	if not frame.GCXp then
		frame.GCXp=frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
	end
	if follower.isCollected and follower.quality < GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY  then
		frame.GCXp:SetPoint("TOPRIGHT",frame,"TOPRIGHT",0,-5)
		frame.GCXp:SetFormattedText("Xp to go: %d",follower.levelXP-follower.xp)
		frame.GCXp:Show()
	else
		frame.GCXp:Hide()
	end
--[===[@debug@
	print(follower)
--@end-debug@]===]
end


function module:Setup(this,...)
--[===[@debug@
print("Doing one time initialization for",this:GetName(),...)
--@end-debug@]===]
	addon:CheckMP()
	self:SafeSecureHookScript("GarrisonShipyardFrame","OnShow")
	self:SafeSecureHookScript(GSF.FollowerTab,"OnShow","FollowerOnShow")
	GCS=addon:CreateHeader(self,'SHIPPIN')
	GSF.FollowerStatusInfo=GSF.BorderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	GSF.ResourceInfo=GSF.BorderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	GSF.ResourceFormat="|TInterface\\Icons\\garrison_oil:0|t %s " .. GetCurrencyInfo(GARRISON_SHIP_OIL_CURRENCY)
	GSF.ResourceInfo:SetPoint("TOPLEFT",5,0)
	GSF.ResourceInfo:SetHeight(25)
	GSF.FollowerStatusInfo:SetPoint("TOPRIGHT",-30,0)
	GSF.FollowerStatusInfo:SetHeight(25)
	GSF.FollowerStatusInfo:Show()
	self:ScriptGarrisonShipyardFrame_OnShow()
	self:SafeHookScript(GSF,"OnShow")
	ns.tabCO:ClearAllPoints()
	ns.tabCO:SetParent(GSF)
	ns.tabCO:SetPoint('TOPRIGHT',GSF,'TOPLEFT',0,0)

end
function module:ScriptGarrisonShipyardFrame_OnShow()
--[===[@debug@
	print("Doing all time initialization")
	print(GetTime())
--@end-debug@]===]
	GCS:Show()
	GCS:SetWidth(GSF:GetWidth())
	GSF:ClearAllPoints()
	GSF:SetPoint("TOPLEFT",GCS,"BOTTOMLEFT",0,23)
	GSF:SetPoint("TOPRIGHT",GCS,"BOTTOMRIGHT",0,23)
	self:RefreshMenu()
	self:RefrreshCurrency()
	self:RefreshFollowerStatus()
--[===[@debug@
	print("Doing all time initialization")
	print(GetTime())
--@end-debug@]===]
end
function module:HookedGarrisonShipyardMapMission_OnLeave()

--[===[@debug@
print("OnLeave")
--@end-debug@]===]
	GameTooltip:Hide()
end
function module:HookedGarrisonShipyardMapMission_OnEnter(frame)
	local g=GameTooltip
	g:SetOwner(GarrisonShipyardMapMissionTooltip, "ANCHOR_NONE")
	g:SetPoint("TOPLEFT",GarrisonShipyardMapMissionTooltip,"BOTTOMLEFT")
	local mission=frame.info
	local missionID=mission.missionID
	addon:AddFollowersToTooltip(missionID,LE_FOLLOWER_TYPE_SHIPYARD_6_2)
--[===[@debug@
	g:AddDoubleLine("MissionID:",missionID)
	g:AddDoubleLine("Class",mission.class)
--@end-debug@]===]
	g:Show()
	if g:GetWidth() < GarrisonShipyardMapMissionTooltip:GetWidth() then
		g:SetWidth(GarrisonShipyardMapMissionTooltip:GetWidth())
	end
end
function addon:EventGARRISON_SHIPYARD_NPC_CLOSED(event,...)
--[===[@debug@
print("NPC CLOSED")
--@end-debug@]===]
	if (GCS) then
		self:RemoveMenu()
		GCS:Hide()
	end
end
function module:EventCHAT_MSG_CURRENCY(event)
	self:RefrreshCurrency()
end
function module:RefrreshCurrency()
	if GSF:IsVisible() then
		local qt=select(2,GetCurrencyInfo(GARRISON_SHIP_OIL_CURRENCY))
		GSF.ResourceInfo:SetFormattedText(GSF.ResourceFormat,qt)
		if qt > 1000 then
			GSF.ResourceInfo:SetTextColor(C.Green())
		elseif qt > 200 then
			GSF.ResourceInfo:SetTextColor(C.Orange())
		else
			GSF.ResourceInfo:SetTextColor(C.Red())
		end
	end
end
function module:EventGARRISON_MISSION_STARTED(event,missionType,missionID,...)
	--[===[@debug@
	print(event,missionID)
	--@end-debug@]===]
	self:RefreshFollowerStatus()
	self:ScheduleTimer("RefrreshCurrency",0.2)
end
function module:RefreshMenu()
	if not GCS then return end  -- This could be called befaur header is built
	if not self.currentmenu or not self.currentmenu:IsVisible() then
		self:RemoveMenu()
		self:AddMenu()
	end
end
function module:AddMenu()
--[===[@debug@
print("Adding Menu",GCS.Menu,GSF.MissionTab:IsVisible(),GSF.FollowerTab:IsVisible())
--@end-debug@]===]
	if GCS.Menu then
		return
	end
	local menu,size

	if GSF.MissionTab:IsVisible() then
		self.currentmenu=GSF.MissionTab
		menu,size=self:CreateOptionsLayer('SHIPMOVEPANEL')
	elseif GSF.FollowerTab:IsVisible() then
		self.currentmenu=GSF.FollowerTab
		menu,size=self:CreateOptionsLayer('SHIPMOVEPANEL')
	--elseif GSF.MissionControlTab:IsVisible() then
	--	self.currentmenu=GSF.MissionControlTab
	--	menu,size=self:CreateOptionsLayer('BIGSCREEN','GCSKIPRARE','GCSKIPEPIC')
	else
		self.currentmenu=nil
		menu,size=self:CreateOptionsLayer('SHIPMOVEPANEL')
	end
--[===[@debug@
	self:AddOptionToOptionsLayer(menu,'DBG')
	self:AddOptionToOptionsLayer(menu,'TRC')
--@end-debug@]===]
	local frame=menu.frame
	frame:Show()
	frame:SetParent(GCS)
	frame:SetFrameStrata(GCS:GetFrameStrata())
	frame:SetFrameLevel(GCS:GetFrameLevel()+2)
	menu:ClearAllPoints()
	menu:SetPoint("TOPLEFT",GCS,"TOPLEFT",25,-18)
	menu:SetWidth(GCS:GetWidth()-50)
	menu:SetHeight(GCS:GetHeight()-50)
	menu:DoLayout()
	GCS.Menu=menu
end
function module:RemoveMenu()
--[===[@debug@
print("Removing menu")
--@end-debug@]===]
	if (GCS.Menu) then
		local rc,message=pcall(GCS.Menu.Release,GCS.Menu)
		--[===[@debug@
		print("Removed menu",rc,message)
		--@end-debug@]===]
		GCS.Menu=nil
	end
end

function module:OpenLastTab()
--[===[@debug@
print("Should restore tab")
--@end-debug@]===]
end
function module:FollowerOnShow()
	self:ShowEnhancements()
end
local upgrades
function module:ShowEnhancements()
	if not upgrades then
		upgrades=CreateFrame("Frame","UPG",GarrisonShipyardFrame.FollowerTab)
		upgrades.items={}

		upgrades:ClearAllPoints()
		upgrades:SetPoint("TOPLEFT",10,-100)
		upgrades:SetPoint("BOTTOMLEFT",0,0)
		upgrades:SetWidth(50)
	end
	for i,itemID in pairs(shipEnhancement) do
		local e
		if  not  upgrades.items[i] then
			upgrades.items[i]=CreateFrame("Button","But"..i,u,"GarrisonCommanderUpgradeButton,SecureActionButtonTemplate")
			e=upgrades.items[i]
			e.itemID=itemID
			e.Icon:SetSize(40,40)
			e:SetPoint("TOPLEFT",0,-45*(i-1))
			GarrisonMissionFrame_SetItemRewardDetails(e)
			e:EnableMouse(true)
			e:RegisterForClicks("LeftButtonDown")
			e:SetAttribute("type","item")
			e:SetAttribute("item",select(2,GetItemInfo(itemID)))
		else
			e=upgrades.items[i]
		end
		local qt=GetItemCount(itemID)
		e.Quantity:SetText(qt)
		e.Quantity:Show()
		e.Icon:SetDesaturated(qt==0)
		e:Show()
	end
	upgrades:Show()
end
do
	local s=setmetatable({},{__index=function(t,k) return 0 end})
	local FOLLOWER_STATUS_FORMAT="Ship status: " ..
								C(AVAILABLE..':%d ','green') ..
								C(GARRISON_FOLLOWER_ON_MISSION .. ":%d ",'red')
	function module:RefreshFollowerStatus()

		wipe(s)
		for _,followerID in self:GetShipsIterator() do
			local status=self:GetFollowerStatus(followerID)
			s[status]=s[status]+1
		end
		if (GSF.FollowerStatusInfo) then
			GSF.FollowerStatusInfo:SetWidth(0)
			GSF.FollowerStatusInfo:SetFormattedText(
				FOLLOWER_STATUS_FORMAT,
				s[AVAILABLE],
				s[GARRISON_FOLLOWER_ON_MISSION]
				)
		end
	end
	function module:GetTotFollowers(status)
		if not status then
			return s[AVAILABLE]+
				s[GARRISON_FOLLOWER_ON_MISSION]
		else
			return s[status] or 0
		end
	end
end
--[[ Follower
displayHeight = 0.25
followerTypeID = 2
iLevel = 600
isCollected = true
classAtlas = Ships_TroopTransport-List
garrFollowerID = 0x00000000000001E2
displayScale = 95
level = 100
quality = 3
portraitIconID = 0
isFavorite = false
xp = 1500
texPrefix = Ships_TroopTransport
className = Transport
classSpec = 53
name = Chen's Favorite Brew
followerID = 0x00000000011E4D8F
height = 0.30000001192093
displayID = 63894
scale = 110
levelXP = 40000
--]]
--[[ Mission
followerTypeID = 2
description = Hellscream has posted a sub near the Horde's main base on Ashran. Take that sub out. Alliance, that means you, too. Factional hatreds have no place here.
cost = 150
adjustedPosX = 798
duration = 8 hr
adjustedPosY = -246
durationSeconds = 28800
state = -2
inProgress=false
typePrefix = ShipMissionIcon-Treasure
typeAtlas = ShipMissionIcon-Treasure-Mission
offerTimeRemaining = 19 days 1 hr
level = 100
offeredGarrMissionTextureID = 0
offerEndTime = 1681052.25
mapPosY = -246
type = Ship-Treasure
name = Warspear Fishing
iLevel = 0
numRewards = 1
rewards = [table: 000000004D079210]
hasBonusEffect = false
numFollowers = 2
costCurrencyTypesID = 1101
followers = [table: 000000004D0791C0]
missionID = 563
canStart = false
location = [ph]
isRare = false
mapPosX = 798
locPrefix = GarrMissionLocation-TannanSea
--]]
--view mission button GSF.MissionTab.MissionList.CompleteDialog.BorderFrame.ViewButton