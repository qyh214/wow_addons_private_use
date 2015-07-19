local me, ns = ...
ns.Configure()
local addon=addon --#addon
local over=over --#over
local _G=_G
local GSF=GSF
local G=C_Garrison
local pairs=pairs
local format=format
local strsplit=strsplit
local generated
local GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY=GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY
local GARRISON_CURRENCY=GARRISON_CURRENCY
local GARRISON_SHIP_OIL_CURRENCY=GARRISON_SHIP_OIL_CURRENCY
local GARRISON_FOLLOWER_MAX_LEVEL=GARRISON_FOLLOWER_MAX_LEVEL
local LE_FOLLOWER_TYPE_GARRISON_6_0=LE_FOLLOWER_TYPE_GARRISON_6_0
local LE_FOLLOWER_TYPE_SHIPYARD_6_2=LE_FOLLOWER_TYPE_SHIPYARD_6_2
local module=addon:NewSubClass('ShipYard') --#Module
function sprint(nome,this,...)
	print(nome,this:GetName(),...)
end
function module:OnInitialize()
	if IsAddOnLoaded("MasterPlanA") then
		-- less efficient,  but survive MasterPlan
		self:SafeSecureHook("GarrisonFollowerButton_UpdateCounters")
		self:SafeSecureHook("GarrisonShipyardMapMission_SetTooltip")
	else
		self:SafeSecureHook(GSF,"OnClickMission","HookedGSF_OnClickMission")
--[===[@debug@
		self:SafeSecureHook("GarrisonShipyardMapMission_SetTooltip")
--@end-debug@]===]
	end
	local ref=GSFMissions.CompleteDialog.BorderFrame.ViewButton
	print(ref)
	local bt = CreateFrame('BUTTON','GCQuickShipMissionCompletionButton', ref, 'UIPanelButtonTemplate')
	bt.missionType=LE_FOLLOWER_TYPE_SHIPYARD_6_2
	bt:SetWidth(300)
	bt:SetText(L["Garrison Comander Quick Mission Completion"])
	bt:SetPoint("CENTER",0,-50)
	addon:ActivateButton(bt,"MissionComplete",L["Complete all missions without confirmation"])
	self:SafeSecureHook("GarrisonShipyardMap_UpdateMissions")
	self:SafeSecureHook("GarrisonShipyardMap_SetupBonus")
	self:SafeHookScript(GSF,"OnShow","Setup",true)
	self:SafeHookScript(GSF.MissionTab.MissionList.CompleteDialog,"OnShow",function(... ) sprint("CompleteDialog",...) end,true)
	self:SafeHookScript(GSF.MissionTab,"OnShow",function(... ) sprint("MissionTab",...) end,true)
	self:SafeHookScript(GSF.FollowerTab,"OnShow",function(... ) sprint("FollowerTab",...) end,true)
	--GarrisonShipyardFrameFollowersListScrollFrameButton1
	--GarrisonShipyardMapMission1
--@end-debug@
end
---
--Invoked on every mission display, only for available missions
--
local i=0
function module:HookedGarrisonShipyardMap_SetupBonus(missionList,frame,mission)
	if not GSF:IsShown() then return end
	print(frame:GetWidth(),mission)
	addon:AddExtraData(mission)
	local perc=addon:MatchMaker(mission)
	local addendum=frame.GcAddendum
	if not addendum then
		if mission.inProgress then return end
		i=i+1
		addendum=CreateFrame("Frame",nil,frame)
		addendum:SetPoint("TOPLEFT",frame,"TOPRIGHT",-15,0)
		addendum:SetWidth(100)
		addendum:SetHeight(70)
		addendum.chance=addendum:CreateFontString(nil,"OVERLAY","GameFontHighlightMedium")
		addendum.chance:SetPoint("TOPLEFT")
		--addendum.expire=addendum:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
		--addendum.expire:SetPoint("TOPLEFT",addendum.chance,"BOTTOMLEFT")
		--addendum.duration=addendum:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
		--addendum.duration:SetPoint("TOPLEFT",addendum.expire,"BOTTOMLEFT")
		frame.GcAddendum=addendum
	end
	if mission.inProgress then addendum:Hide() return end
	addendum:Show()
	addendum.chance:SetFormattedText("%d%%",perc)
	addendum.chance:SetTextColor(self:GetDifficultyColors(perc))
	--addendum.expire:SetText(mission.class)
	--addendum.duration:SetText(mission.duration)
end
function module:HookedGarrisonShipyardMap_UpdateMissions()
	local list = GSF.MissionTab.MissionList
	for i=1,#list.missions do
		local frame = list.missionFrames[i]
		if not self:IsHooked(frame,"PostClick") then
			self:SafeHookScript(frame,"PostClick","HookedMapButtonOnClick",true)
		end
	end

end
function module:HookedMapButtonOnClick(this)
	self:FillMissionPage(this.info)
end
function module:HookedGSF_OnClickMission(this,missionInfo)
	self:FillMissionPage(missionInfo)
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
	--print(follower)
--@end-debug@]===]
end


function module:Setup(this,...)
	print("Doing one time initialization for",this:GetName(),...)
	self:SafeHookScript(GSF,"OnShow","OnShow",true)
	GSF:EnableMouse(true)
	GSF:SetMovable(true)
	GSF:RegisterForDrag("LeftButton")
	GSF:SetScript("OnDragStart",function(frame)if (self:GetBoolean("MOVEPANEL")) then frame:StartMoving() end end)
	GSF:SetScript("OnDragStop",function(frame) frame:StopMovingOrSizing() end)
end
function module:OnShow()
	print("Doing all time initialization")
end
function module:HookedGarrisonShipyardMapMission_SetTooltip(info,inProgress)
	local tooltipFrame = GarrisonShipyardMapMissionTooltip;
	local extra=10
	if (not tooltipFrame.msg) then
		tooltipFrame.msg=tooltipFrame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
		tooltipFrame.msg:SetPoint("BOTTOMLEFT",10,extra)
	end
	tooltipFrame.msg:Show()
	tooltipFrame.msg:SetText("Left click to let GC autofill mission");
	tooltipFrame.msg:SetTextColor(C:Yellow());
	extra=extra+10
--@debug@
	if (not tooltipFrame.dbg) then
		tooltipFrame.dbg=tooltipFrame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
		tooltipFrame.dbg:SetPoint("BOTTOMLEFT",10,extra)
	end
	tooltipFrame.dbg:Show()
	tooltipFrame.dbg:SetFormattedText("Mission ID: %d" ,info.missionID);
	extra=extra+20
--@end-debug
	tooltipFrame:SetHeight(tooltipFrame:GetHeight()+extra)
end

function module:OpenLastTab()
print("Should restore tab")
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